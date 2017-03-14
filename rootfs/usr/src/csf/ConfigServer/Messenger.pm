###############################################################################
# Copyright 2006-2017, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
## no critic (RequireUseWarnings, ProhibitExplicitReturnUndef, ProhibitMixedBooleanOperators, RequireBriefOpen)
# start main
package ConfigServer::Messenger;

use strict;
use lib '/usr/local/csf/lib';
use Fcntl qw(:DEFAULT :flock);
use JSON::Tiny;
use IO::Socket::INET;
use Net::CIDR::Lite;
use Net::IP;
use ConfigServer::Config;
use ConfigServer::CheckIP qw(checkip);
use ConfigServer::Logger qw(logfile);
use ConfigServer::URLGet;
use ConfigServer::Slurp qw(slurp);
use ConfigServer::GetIPs qw(getips);
use ConfigServer::GetEthDev;

use Exporter qw(import);
our $VERSION     = 1.00;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw();

my $config = ConfigServer::Config->loadconfig();
my %config = $config->config();
my $ipv4reg = ConfigServer::Config->ipv4reg;
my $ipv6reg = ConfigServer::Config->ipv6reg;
if ($config{MESSENGER6}) {
	eval('use IO::Socket::INET6;'); ##no critic
	if ($@) {$config{MESSENGER6} = "0"}
}

my $hostname;
if (-e "/proc/sys/kernel/hostname") {
	open (my $IN, "<", "/proc/sys/kernel/hostname");
	flock ($IN, LOCK_SH);
	$hostname = <$IN>;
	chomp $hostname;
	close ($IN);
} else {
	$hostname = "unknown";
}
my $hostshort = (split(/\./,$hostname))[0];

my %ips;
my $ipscidr6 = Net::CIDR::Lite->new;
&getethdev;
foreach my $ip (split(/,/,@$config{RECAPTCHA_NAT})) {
	$ip =~ s/\s*//g;
	$ips{$ip} = 1;
}

# end main
###############################################################################
# start messenger
sub messenger {
	my $port = shift;
	my $user = shift;
	my $type = shift;
	my $oldtype = $type;
	my $server;
	my %sslcerts;
	my %sslkeys;

	$SIG{CHLD} = 'IGNORE';
	$0 = "lfd $type messenger";

	if ($type eq "HTTPS") {
		require IO::Socket::SSL;
		import IO::Socket::SSL;

		my $start = 0;
		my $format = "apache";
		my $sslhost;
		my $sslcert;
		my $sslkey;
		my $sslaliases;
		my %messengerports;
		foreach my $serverports (split(/\,/,$config{MESSENGER_HTTPS_IN})) {$messengerports{$serverports} = 1}
		foreach my $file (glob($config{MESSENGER_HTTPS_CONF})) {
			if (-e $file) {
				foreach my $line (slurp($file)) {
					$line =~ s/\'|\"//g;
					if ($line =~ /^\s*<VirtualHost\s+[^\>]+>/) {
						$start = 1;
						$format = "apache";
					}
					if ($format eq "apache" and $start) {
						if ($line =~ /\s*ServerName\s+(\w+:\/\/)?([a-zA-Z0-9\.\-]+)(:\d+)?/) {$sslhost = $2}
						if ($line =~ /\s*ServerAlias\s+(.*)/) {$sslaliases .= " ".$1}
						if ($line =~ /\s*SSLCertificateFile\s+(\S+)/) {
							my $match = $1;
							if (-e $match) {$sslcert = $match}
						}
						if ($line =~ /\s*SSLCertificateKeyFile\s+(\S+)/) {
							my $match = $1;
							if (-e $match) {$sslkey = $match}
						}
					}

#					if ($line =~ /^\s*listen\s+(\S+)\s*\;/) {
#						$start = 1;
#						unless ($messengerports{$1}) {$start = 0}
#						$format = "nginx";
#					}
#					if ($format eq "nginx" and $start) {
#						if ($line =~ /\s*server_name\s+(\S+)(((\s+\S+)*)?)\s*\;/) {
#							$sslhost = $1;
#							$sslaliases = $2;
#							$sslhost =~ s/:\d+//g;
#						}
#						if ($line =~ /\s*ssl_certificate\s+(\S+)\s*\;/) {
#							my $match = $1;
#							if (-e $match) {$sslcert = $1}
#						}
#						if ($line =~ /\s*ssl_certificate_key\s+(\S+)\s*\;/) {
#							my $match = $1;
#							if (-e $match) {$sslkey = $1}
#						}
#					}
					
					if (($format eq "apache" and $line =~ /^\s*<\/VirtualHost\s*>/) or 
						($format eq "nginx" and $line =~ /^\s*\}/)) {

						$start = 0;
						if ($sslhost ne "" and !checkip($sslhost) and $sslcert ne "") {
							$sslcerts{$sslhost} = $sslcert;
							if ($sslkey eq "") {$sslkey = $sslcert}
							$sslkeys{$sslhost} = $sslkey;
							foreach my $alias (split(/\s+/,$sslaliases)) {
								if ($alias eq "") {next}
								if (checkip($alias)) {next}
								if ($alias =~ /^[a-zA-Z0-9\.\-]+$/) {
									if ($config{MESSENGER_HTTPS_SKIPMAIL} and $alias =~ /^mail\./) {next}
									$sslcerts{$alias} = $sslcert;
									$sslkeys{$alias} = $sslkey;
								}
							}
						}
						$sslhost = "";
						$sslcert = "";
						$sslkey = "";
						$sslaliases = "";
					}
				}
			}
		}
		if (scalar(keys %sslcerts < 1)) {
			return (1, "No SSL certs found in MESSENGER_HTTPS_CONF location");
		}
		if (-e $config{MESSENGER_HTTPS_KEY}) {
			$sslkeys{''} = $config{MESSENGER_HTTPS_KEY};
		}
		if (-e $config{MESSENGER_HTTPS_CRT}) {
			$sslcerts{''} = $config{MESSENGER_HTTPS_CRT};
		}
		if ($config{DEBUG} >= 1) {
			foreach my $key (keys %sslcerts) {
				logfile("SSL: [$key] [$sslcerts{$key}] [$sslkeys{$key}]");
			}
		}
		eval {
			local $SIG{__DIE__} = undef;
			if ($config{MESSENGER6}) {
				$server = IO::Socket::SSL->new(
							Domain => AF_INET6,
							LocalPort => $port,
							Type => SOCK_STREAM,
							ReuseAddr => 1,
							Listen => $config{MESSENGER_CHILDREN},
							SSL_server => 1,
							SSL_use_cert => 1,
							SSL_cert_file => \%sslcerts,
							SSL_key_file => \%sslkeys,
				) or die("MESSENGER: *Error* cannot open server on port $port: ".IO::Socket::SSL->errstr);
			} else {
				$server = IO::Socket::SSL->new(
							Domain => AF_INET,
							LocalPort => $port,
							Type => SOCK_STREAM,
							ReuseAddr => 1,
							Listen => $config{MESSENGER_CHILDREN},
							SSL_server => 1,
							SSL_use_cert => 1,
							SSL_cert_file => \%sslcerts,
							SSL_key_file => \%sslkeys,
				) or die("MESSENGER: *Error* cannot open server on port $port: ".IO::Socket::SSL->errstr);
			}
			&logfile("Messenger HTTPS Service started for ".scalar(keys %sslcerts)." domains");
			$type = "HTML";
		};
		if ($@) {
			return (1, $@);
		}
	}
	elsif ($config{MESSENGER6}) {
		$server = IO::Socket::INET6->new(
			LocalPort => $port, 
			Type => SOCK_STREAM, 
			ReuseAddr => 1, 
			Listen => $config{MESSENGER_CHILDREN}) or &childcleanup(__LINE__,"*Error* cannot open server on port $port: $!");
	} else {
		$server = IO::Socket::INET->new(
			LocalPort => $port, 
			Type => SOCK_STREAM, 
			ReuseAddr => 1, 
			Listen => $config{MESSENGER_CHILDREN}) or &childcleanup(__LINE__,"*Error* cannot open server on port $port: $!");
	}
	
	my $index;
	if ($type eq "HTML" and $config{RECAPTCHA_SITEKEY} ne "") {$index = "/etc/csf/messenger/index.recaptcha.html"}
	elsif ($type eq "HTML") {$index = "/etc/csf/messenger/index.html"}
	else {$index = "/etc/csf/messenger/index.text"}
	open (my $IN, "<", $index);
	flock ($IN, LOCK_SH);
	my @message = <$IN>;
	close ($IN);
	chomp @message;

	my %images;
	if ($type eq "HTML") {
		opendir (DIR, "/etc/csf/messenger");
		foreach my $file (readdir(DIR)) {
			if ($file =~ /\.(gif|png|jpg)$/) {
				open (my $IN, "<", "/etc/csf/messenger/$file");
				flock ($IN, LOCK_SH);
				my @data = <$IN>;
				close ($IN);
				chomp @data;
				foreach my $line (@data) {
					$images{$file} .= "$line\n";
				}
			}
		}
		closedir (DIR);
	}

	if ($user ne "") {
		my (undef,undef,$uid,$gid,undef,undef,undef,$homedir) = getpwnam($user);
		if (($uid > 0) and ($gid > 0)) {
			local $) = $gid;
			local $> = $uid;
			chdir("/");
			if (($) != $gid) or ($> != $uid)) {
				logfile("MESSENGER_USER unable to drop privileges - stopping $oldtype Messenger");
				exit;
			}
			my $loopcheck;
			while ($loopcheck < 1000) {
				$loopcheck++;
				while (my ($client, $c_addr) = $server->accept()) {
					$SIG{CHLD} = 'IGNORE';
					my $pid = fork;
					if ($pid == 0) {
						eval {
							local $SIG{__DIE__} = undef;
							local $SIG{'ALRM'} = sub {die};
							alarm(10);
							close $server;
							$0 = "lfd $oldtype messenger client";

							binmode $client;
							$| = 1;
							my $firstline;

							my $hostaddress = $client->sockhost();
							my $peeraddress = $client->peerhost();
							unless ($peeraddress) {
								my($cport,$iaddr) = sockaddr_in($c_addr);
								$peeraddress = inet_ntoa($iaddr);
							}
							$peeraddress =~ s/^::ffff://;
							$hostaddress =~ s/^::ffff://;

							if ($type eq "HTML") {
								sysread ($client,$firstline,2048);
								chomp $firstline;
							}

							my $error;
							my $success;
							my $failure;
							if (($type eq "HTML") and ($firstline =~ /^GET \/unblk\?g-recaptcha-response=(\S+)/i)) {
								my $recv = $1;
								my $status = 1;
								my $text;
								eval {
									local $SIG{__DIE__} = undef;
									eval("no lib '/usr/local/csf/lib'");
									my $urlget = ConfigServer::URLGet->new(2);
									my $url = "https://www.google.com/recaptcha/api/siteverify?secret=$config{RECAPTCHA_SECRET}&response=$recv";
									($status, $text) = $urlget->urlget($url);
								};
								if ($status) {
									if ($config{DEBUG} >= 1) {
										if ($@) {$error .= "Error:".$@}
										if ($!) {$error .= "Error:".$!}
										$error .= " Error Status: $status";
									}
									$error .= "Unable to verify with Google reCAPTCHA";
								} else {
									my $resp  = JSON::Tiny::decode_json($text);
									if ($resp->{success}) {
										my $ip = $resp->{hostname};
										unless ($ip =~ /^($ipv4reg|$ipv6reg)$/) {$ip = (getips($ip))[0]}
										if ($ips{$ip} or $ip eq $hostaddress or $ipscidr6->find($ip)) {
											sysopen (my $UNBLOCK, "$homedir/unblock.txt", O_WRONLY | O_APPEND | O_CREAT) or $error .= "Unable to write to [$homedir/unblock.txt] (make sure that MESSENGER_USER has a home directory)";
											flock($UNBLOCK, LOCK_EX);
											print $UNBLOCK "$peeraddress;$resp->{hostname};$ip\n";
											close ($UNBLOCK);
											$success = 1;
										} else {
											$error .= "Failed, [$resp->{hostname} ($ip)] does not appear to be hosted on this server.";
										}
									} else {
										$failure = 1;
									}
								}
							}
							if (($type eq "HTML") and ($firstline =~ /^GET\s+(\S*\/)?(\S*\.(gif|png|jpg))\s+/i)) {
								my $type = $3;
								if ($type eq "jpg") {$type = "jpeg"}
								print $client "HTTP/1.1 200 OK\r\n";
								print $client "Content-type: image/$type\r\n";
								print $client "\r\n";
								print $client $images{$2};
							} else {
								if ($type eq "HTML") {
									print $client "HTTP/1.1 403 OK\r\n";
									print $client "Content-type: text/html\r\n";
									print $client "\r\n";
								}
								foreach my $line (@message) {
									if ($line =~ /\[IPADDRESS\]/) {$line =~ s/\[IPADDRESS\]/$peeraddress/}
									if ($line =~ /\[HOSTNAME\]/) {$line =~ s/\[HOSTNAME\]/$hostname/}
									if ($line =~ /\[RECAPTCHA_SITEKEY\]/) {$line =~ s/\[RECAPTCHA_SITEKEY\]/$config{RECAPTCHA_SITEKEY}/}
									if ($line =~ /\[RECAPTCHA_ERROR=\"([^\"]+)\"\]/) {
										my $text = $1;
										if ($error ne "") {$line =~ s/\[RECAPTCHA_ERROR=\"([^\"]+)\"\]/$text $error/} else {$line =~ s/\[RECAPTCHA_ERROR=\"([^\"]+)\"\]//}
									}
									if ($line =~ /\[RECAPTCHA_SUCCESS=\"([^\"]+)\"\]/) {
										my $text = $1;
										if ($success) {$line =~ s/\[RECAPTCHA_SUCCESS=\"([^\"]+)\"\]/$text/} else {$line =~ s/\[RECAPTCHA_SUCCESS=\"([^\"]+)\"\]//}
									}
									if ($line =~ /\[RECAPTCHA_FAILURE=\"([^\"]+)\"\]/) {
										my $text = $1;
										if ($failure) {$line =~ s/\[RECAPTCHA_FAILURE=\"([^\"]+)\"\]/$text/} else {$line =~ s/\[RECAPTCHA_FAILURE=\"([^\"]+)\"\]//}
									}
									print $client "$line\r\n";
								}
							}
							shutdown ($client,2);
							close ($client);
							alarm(0);
							exit;
						};
						alarm(0);
						exit;
					}
				}
			}
		} else {
			logfile("MESSENGER_USER invalid - stopping $oldtype Messenger");
		}
	} else {
		logfile("MESSENGER_USER not set - stopping $oldtype Messenger");
	}
	return;
}
# end messenger
###############################################################################
# start childcleanup
sub childcleanup {
	$SIG{INT} = 'IGNORE';
	$SIG{TERM} = 'IGNORE';
	$SIG{HUP} = 'IGNORE';
	my $line = shift;
	my $message = shift;

	if (($message eq "") and $line) {
		$message = $line;
		$line = "";
	}

	$0 = "child - aborting";

	if ($message) {
		if ($line ne "") {$message .= ", at line $line"}
		logfile("$message");
	}
    exit;
}
# end childcleanup
###############################################################################
# start getethdev
sub getethdev {
	my $ethdev = ConfigServer::GetEthDev->new();
	my %g_ipv4 = $ethdev->ipv4;
	my %g_ipv6 = $ethdev->ipv6;
	foreach my $key (keys %g_ipv4) {
		my $netip = Net::IP->new($key);
		my $type = $netip->iptype();
		if ($type eq "PUBLIC") {$ips{$key} = 1}
	}
	if ($config{IPV6}) {
		foreach my $key (keys %g_ipv6) {
			if ($key !~ m[::1/128]) {
				eval {
					local $SIG{__DIE__} = undef;
					$ipscidr6->add($key);
				};
			}
		}
	}
	return;
}
# end getethdev
###############################################################################

1;
