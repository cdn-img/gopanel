###############################################################################
# Copyright 2006-2017, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
## no critic (RequireUseWarnings, ProhibitExplicitReturnUndef, ProhibitMixedBooleanOperators, RequireBriefOpen)
# start main
package ConfigServer::Config;

use strict;
use lib '/usr/local/csf/lib';
use version;
use Fcntl qw(:DEFAULT :flock);
use Carp;
use IPC::Open3;
use ConfigServer::Slurp qw(slurp);

use Exporter qw(import);
our $VERSION     = 1.05;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw();

our $ipv4reg = qr/(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;
our $ipv6reg = qr/((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?/;

my %config;
my %configsetting;
my $warning;
my $version;

my $slurpreg = ConfigServer::Slurp->slurpreg;
my $cleanreg = ConfigServer::Slurp->cleanreg;
my $configfile = "/etc/csf/csf.conf";

# end main
###############################################################################
# start loadconfig
sub loadconfig {
	my $class = shift;
	my $self = {};
	bless $self,$class;

	if (%config) {
		$self->{warning} = $warning;
		return $self;
	}

	undef %configsetting;
	undef %config;
	undef $warning;

	my @file = slurp($configfile);
	foreach my $line (@file) {
		$line =~ s/$cleanreg//g;
		if ($line =~ /^(\s|\#|$)/) {next}
		if ($line !~ /=/) {next}
		my ($name,$value) = split (/=/,$line,2);
		$name =~ s/\s//g;
		if ($value =~ /\"(.*)\"/) {
			$value = $1;
		} else {
			croak "*Error* Invalid configuration line [$line] in $configfile";
		}
		if ($configsetting{$name}) {
			croak "*Error* Setting $name is repeated in $configfile - you must remove the duplicates and then restart csf and lfd";
		}
		$config{$name} = $value;
		$configsetting{$name} = 1;
	}

	if ($config{LF_IPSET}) {
		unless ($config{LF_IPSET_HASHSIZE}) {
			$config{LF_IPSET_HASHSIZE} = "1024";
			$configsetting{LF_IPSET_HASHSIZE} = 1;
		}
		unless ($config{LF_IPSET_MAXELEM}) {
			$config{LF_IPSET_MAXELEM} = "65536";
			$configsetting{LF_IPSET_MAXELEM} = 1;
		}
	}

	my ($childin, $childout);
	my $cmdpid = open3($childin, $childout, $childout, $config{IPTABLES},"--version");
	close $childin;
	my @results = <$childout>;
	waitpid ($cmdpid, 0);
	chomp @results;
	if ($results[0] =~ /iptables v(\d+\.\d+\.\d+)/) {
		$version = $1;

		$config{IPTABLESWAIT} = "";
		if ($config{WAITLOCK}) {
			my @ipdata;
			eval {
				local $SIG{__DIE__} = undef;
				local $SIG{'ALRM'} = sub {die "alarm\n"};
				alarm($config{WAITLOCK_TIMEOUT});
				my ($childin, $childout);
				my $cmdpid = open3($childin, $childout, $childout, $config{IPTABLES},"--wait","-L","OUTPUT","-nv");
				@ipdata = <$childout>;
				waitpid ($cmdpid, 0);
				chomp @ipdata;
				alarm(0);
			};
			alarm(0);
			if ($@ eq "alarm\n") {
				croak "*ERROR* Timeout after $config{WAITLOCK_TIMEOUT} seconds for iptables --wait - WAITLOCK\n";
			}
			if ($ipdata[0] =~ /^Chain OUTPUT/) {
				$config{IPTABLESWAIT} = "--wait";
			} else {
				$warning .= "*WARNING* This version of iptables does not support the --wait option - disabling WAITLOCK\n";
				$config{WAITLOCK} = 0;
			}
		}
	}

	if ($config{IPV6} and -x $config{IP6TABLES} and $version) {
		if ($config{USE_CONNTRACK} and version->parse($version) <= version->parse("1.3.5")) {$config{USE_CONNTRACK} = 0}
		if ($config{PORTFLOOD} and version->parse($version) >= version->parse("1.4.3")) {$config{PORTFLOOD6} = 1}
		if ($config{CONNLIMIT} and version->parse($version) >= version->parse("1.4.3")) {$config{CONNLIMIT6} = 1}
		if ($config{MESSENGER} and version->parse($version) >= version->parse("1.4.17")) {$config{MESSENGER6} = 1}
		if ($config{SMTP_REDIRECT} and version->parse($version) >= version->parse("1.4.17")) {$config{SMTP_REDIRECT6} = 1}
		if (version->parse($version) >= version->parse("1.4.17") and ($config{MESSENGER} or $config{SMTP_REDIRECT})) {
			my ($childin, $childout);
			my $cmdpid = open3($childin, $childout, $childout, $config{IP6TABLES},"-t","nat","-L","POSTROUTING","-nv");
			my @ipdata = <$childout>;
			waitpid ($cmdpid, 0);
			chomp @ipdata;
			if ($ipdata[0] =~ /^Chain POSTROUTING/) {
				$config{NAT6} = 1;
			} else {
				if ($config{SMTP_REDIRECT}) {
					$warning .= "*WARNING* ip6tables nat table not present - disabling SMTP_REDIRECT and nat table flushing for IPv6\n";
					$config{SMTP_REDIRECT6} = 0;
				}
				if ($config{MESSENGER}) {
					$warning .= "*WARNING* ip6tables nat table not present - disabling MESSENGER Service and nat table flushing for IPv6\n";
					$config{MESSENGER6} = 0;
				}
			}
		}
	}
	elsif ($config{IPV6}) {
		$warning .= "*WARNING* incorrect ip6tables binary location [$config{IP6TABLES}] - IPV6 disabled\n";
		$config{IPV6} = 0;
	}
	if (-e "/var/cpanel/smtpgidonlytweak" and !$config{GENERIC}) {
		$warning .= "*WARNING* The option \"WHM > Tweak Settings > Restrict outgoing SMTP to root, exim, and mailman (FKA SMTP Tweak)\" is incompatible with this firewall. The option must be disabled in WHM and the SMTP_BLOCK alternative in csf used instead\n";
	}
	if (-e "/proc/vz/veinfo") {$config{VPS} = 1}
	else {
		foreach my $line (slurp("/proc/self/status")) {
			$line =~ s/$cleanreg//g;
			if ($line =~ /^envID:\s*(\d+)\s*$/) {
				if ($1 > 0) {
					$config{VPS} = 1;
					last;
				}
			}
		}
	}
	if ($config{DROP_IP_LOGGING} and $config{PS_INTERVAL}) {
		$warning .= "*WARNING* Cannot use PS_INTERVAL with DROP_IP_LOGGING enabled. DROP_IP_LOGGING disabled\n";
		$config{DROP_IP_LOGGING} = 0;
	}

	if ($config{FASTSTART}) {
		unless (-x $config{IPTABLES_RESTORE}) {
			$warning .= "*WARNING* Unable to use FASTSTART as [$config{IPTABLES_RESTORE}] is not executable or does not exist\n";
			$config{FASTSTART} = 0;
		}
		if ($config{IPV6}) {
			unless (-x $config{IP6TABLES_RESTORE}) {
				$warning .= "*WARNING* Unable to use FASTSTART as (IPv6) [$config{IP6TABLES_RESTORE}] is not executable or does not exist\n";
				$config{FASTSTART} = 0;
			}
		}
	}

	if ($config{MESSENGER}) {
		if ($config{MESSENGER_HTTPS_IN}) {
			eval {
				local $SIG{__DIE__} = undef;
				require IO::Socket::SSL;
			};
			if ($@) {
				$warning .= "*WARNING* Perl module IO::Socket::SSL missing - disabling MESSENGER HTTPS Service\n";
				$config{MESSENGER_HTTPS_IN} = "";
				$config{MESSENGER_HTTPS_DISABLED} = "*WARNING* Perl module IO::Socket::SSL missing - disabling MESSENGER HTTPS Service";
			}
			elsif (version->parse($IO::Socket::SSL::VERSION) < version->parse("1.83")) {
				$warning .= "*WARNING* Perl module IO::Socket::SSL v$IO::Socket::SSL::VERSION does not support SNI - disabling MESSENGER HTTPS Service\n";
				$config{MESSENGER_HTTPS_IN} = "";
				$config{MESSENGER_HTTPS_DISABLED} = "*WARNING* Perl module IO::Socket::SSL v$IO::Socket::SSL::VERSION does not support SNI - disabling MESSENGER HTTPS Service";
			}
		}
		my $pcnt = 0;
		foreach my $port (split(/\,/,$config{MESSENGER_HTML_IN})) {
			$pcnt++;
		}
		if ($pcnt > 15) {
			$warning .= "*WARNING* MESSENGER_HTML_IN contains more than 15 ports - disabling MESSENGER Service\n";
			$config{MESSENGER} = 0;
		} else {
			$pcnt = 0;
			foreach my $port (split(/\,/,$config{MESSENGER_TEXT_IN})) {
				$pcnt++;
			}
			if ($pcnt > 15) {
				$warning .= "*WARNING* MESSENGER_TEXT_IN contains more than 15 ports - disabling MESSENGER Service\n";
				$config{MESSENGER} = 0;
			} else {
				$pcnt = 0;
				foreach my $port (split(/\,/,$config{MESSENGER_HTTPS_IN})) {
					$pcnt++;
				}
				if ($pcnt > 15) {
					$warning .= "*WARNING* MESSENGER_HTTPS_IN contains more than 15 ports - disabling MESSENGER Service\n";
					$config{MESSENGER} = 0;
				}
			}
		}
	}
	
	if (!$config{GENERIC} and -e "/var/cpanel/dnsonly") {$config{DNSONLY} = 1}

	if ($config{IPV6} and $config{IPV6_SPI}) {
		open (my $FH, "<", "/proc/sys/kernel/osrelease");
		flock ($FH, LOCK_SH);
		my @data = <$FH>;
		close ($FH);
		chomp @data;
		if ($data[0] =~ /^(\d+)\.(\d+)\.(\d+)/) {
			my $maj = $1;
			my $mid = $2;
			my $min = $3;
			if (($maj > 2) or (($maj > 1) and ($mid > 6)) or (($maj > 1) and ($mid > 5) and ($min > 19))) {
			} else {
				$warning .=  "*WARNING* Kernel $data[0] may not support an ip6tables SPI firewall. You should set IPV6_SPI to \"0\" in /etc/csf/csf.conf\n\n";
			}
		}
	}

	$cmdpid = open3($childin, $childout, $childout, $config{IPTABLES},"-t","nat","-L","POSTROUTING","-nv");
	my @ipdata = <$childout>;
	waitpid ($cmdpid, 0);
	chomp @ipdata;
	if ($ipdata[0] =~ /^Chain POSTROUTING/) {
		$config{NAT} = 1;
	} else {
		if ($config{MESSENGER}) {
			$warning .= "*WARNING* iptables nat table not present - disabling MESSENGER Service\n";
			$config{MESSENGER} = 0;
		}
	}

	if ($config{PT_USERKILL}) {
		$warning .= "*WARNING* PT_USERKILL should not normally be enabled as it can easily lead to legitimate processes being terminated, use csf.pignore instead\n";
	}

	$self->{warning} = $warning;

	return $self;
}
# end loadconfig
###############################################################################
# start config
sub config {
	return %config;
}
# end config
###############################################################################
# start resetconfig
sub resetconfig {
	undef %config;
	undef %configsetting;
	undef $warning;

	return;
}
# end resetconfig
###############################################################################
# start configsetting
sub configsetting {
	return %configsetting;
}
# end configsetting
###############################################################################
# start ipv4reg
sub ipv4reg {
	return $ipv4reg;
}
# end ipv4reg
###############################################################################
# start ipv6reg
sub ipv6reg {
	return $ipv6reg;
}
# end ipv6reg
###############################################################################

1;