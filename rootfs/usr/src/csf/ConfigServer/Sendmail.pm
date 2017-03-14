###############################################################################
# Copyright 2006-2017, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
## no critic (RequireUseWarnings, ProhibitExplicitReturnUndef, ProhibitMixedBooleanOperators, RequireBriefOpen)
# start main
package ConfigServer::Sendmail;

use strict;
use lib '/usr/local/csf/lib';
use Carp;
use POSIX qw(strftime);
use Fcntl qw(:DEFAULT :flock);
use ConfigServer::Config;

use Exporter qw(import);
our $VERSION     = 1.01;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw();

my $config = ConfigServer::Config->loadconfig();
my %config = $config->config();
my $tz = strftime("%z", localtime);
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
if ($config{LF_ALERT_SMTP}) {
	require Net::SMTP;
	import Net::SMTP;
}

# end main
###############################################################################
# start sendmail
sub relay {
	my ($to, $from, @message) = @_;
	my $time = localtime(time);
	if ($to eq "") {$to = $config{LF_ALERT_TO}} else {$config{LF_ALERT_TO} = $to}
	if ($from eq "") {$from = $config{LF_ALERT_FROM}} else {$config{LF_ALERT_FROM} = $from}
	my $data;

	if ($from =~ /([\w\.\=\-\_]+\@[\w\.\-\_]+)/) {$from = $1}
	if ($from eq "") {$from = "root"}
	if ($to =~ /([\w\.\=\-\_]+\@[\w\.\-\_]+)/) {$to = $1}
	if ($to eq "") {$to = "root"}

	my $header = 1;
	foreach my $line (@message) {
		$line =~ s/\r//;
		if ($line eq "") {$header = 0}
		$line =~ s/\[time\]/$time $tz/ig;
		$line =~ s/\[hostname\]/$hostname/ig;
		if ($header) {
			if ($line =~ /^To:\s*(.*)\s*$/i) {
				my $totxt = $1;
				if ($config{LF_ALERT_TO} ne "") {
					$line =~ s/^To:.*$/To: $config{LF_ALERT_TO}/i;
				} else {
					$to = $totxt;
				}
#				if ($totxt !~ /\@/) {
#					$line =~ s/^To:.*$/To: $totxt\@$hostname/i;
#				}
			}
			if ($line =~ /^From:\s*(.*)\s*$/i) {
				my $fromtxt = $1;
				if ($config{LF_ALERT_FROM} ne "") {
					$line =~ s/^From:.*$/From: $config{LF_ALERT_FROM}/i;
				} else {
					$from = $1;
				}
#				if ($fromtxt !~ /\@/) {
#					$line =~ s/^From:.*$/From: $fromtxt\@$hostname/i;
#				}
			}
		}
		$data .= $line."\n";
	}

	if ($config{LF_ALERT_SMTP}) {
		if ($from !~ /\@/) {$from .= '@'.$hostname}
		if ($to !~ /\@/) {$to .= '@'.$hostname}
		my $smtp = Net::SMTP->new($config{LF_ALERT_SMTP}, Timeout => 10) or croak("Unable to send SMTP alert via [$config{LF_ALERT_SMTP}]: $!");
		if (defined $smtp) {
			$smtp->mail($from);
			$smtp->to($to);
			$smtp->data();
			$smtp->datasend($data);
			$smtp->dataend();
			$smtp->quit();
		}
	} else {
		local $SIG{CHLD} = 'DEFAULT';
		open (my $MAIL, "|-", "$config{SENDMAIL} -f $from -t") or croak("Unable to send SENDMAIL alert via [$config{SENDMAIL}]: $!");
		print $MAIL $data;
		close ($MAIL);
	}

	return;
}
# end sendmail
###############################################################################

1;