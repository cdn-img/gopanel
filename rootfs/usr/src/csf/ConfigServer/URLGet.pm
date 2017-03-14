###############################################################################
# Copyright 2006-2017, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
## no critic (RequireUseWarnings, ProhibitExplicitReturnUndef, ProhibitMixedBooleanOperators, RequireBriefOpen)
# start main
package ConfigServer::URLGet;

use strict;
use lib '/usr/local/csf/lib';
use Fcntl qw(:DEFAULT :flock);
use Carp;

use Exporter qw(import);
our $VERSION     = 1.02;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw();

my $agent = "ConfigServer";
my $option = 1;

# end main
###############################################################################
# start new
sub new {
	my $class = shift;
	$option = shift;
	$agent = shift;
	my $self = {};
	bless $self,$class;

	if ($option == 2) {
		eval ('use LWP::UserAgent;'); ##no critic
		if ($@) {return undef}
	} else {
		eval {
			local $SIG{__DIE__} = undef;
			eval ('use HTTP::Tiny;'); ##no critic
		};
	}

	return $self;
}
# end new
###############################################################################
# start urlget
sub urlget {
	my $self = shift;
	my $url = shift;
	my $file = shift;
	my $quiet = shift;
	my $status;
	my $text;

	if (!defined $url) {croak "url not specified"}

	if ($option == 2) {
		($status, $text) = &urlgetLWP($url,$file,$quiet);
	} else {
		($status, $text) = &urlgetTINY($url,$file,$quiet);
	}
	return ($status, $text);
}
# end urlget
###############################################################################
# start urlgetTINY
sub urlgetTINY {
	my $url = shift;
	my $file = shift;
	my $quiet = shift;
	my $status = 0;
	my $timeout = 1200;
	my $ua = HTTP::Tiny->new;
	$ua->agent($agent);
	$ua->timeout(300);
	my $res;
	my $text;
	($status, $text) = eval {
		local $SIG{__DIE__} = undef;
		local $SIG{'ALRM'} = sub {die "Download timeout after $timeout seconds"};
		alarm($timeout);
		if ($file) {
			local $|=1;
			my $expected_length;
			my $bytes_received = 0;
			my $per = 0;
			my $oldper = 0;
			open (my $OUT, ">", "$file\.tmp") or return (1, "Unable to open $file\.tmp: $!");
			flock ($OUT, LOCK_EX);
			binmode ($OUT);
			$res = $ua->request('GET', $url, {
				data_callback => sub {
					my($chunk, $res) = @_;
					$bytes_received += length($chunk);
					unless (defined $expected_length) {$expected_length = $res->{headers}->{'content-length'} || 0}
					if ($expected_length) {
						my $per = int(100 * $bytes_received / $expected_length);
						if ((int($per / 5) == $per / 5) and ($per != $oldper) and !$quiet) {
							print "...$per\%\n";
							$oldper = $per;
						}
					} else {
						unless ($quiet) {print "."}
					}
					print $OUT $chunk;
				}
			});
			close ($OUT);
			unless ($quiet) {print "\n"}
		} else {
			$res = $ua->request('GET', $url);
		}
		alarm(0);
		if ($res->{success}) {
			if ($file) {
				rename ("$file\.tmp","$file") or return (1, "Unable to rename $file\.tmp to $file: $!");
				return (0, $file);
			} else {
				return (0, $res->{content});
			}
		} else {
			my $reason = $res->{reason};
			if ($res->{status} == 599) {$reason = $res->{content}}
			return (1, "Unable to download: ".$res->{status}." - $reason");
		}
	};
	alarm(0);
	if ($@) {return (1, $@)}
	return ($status,$text);
}
# end urlgetTINY
###############################################################################
# start urlgetLWP
sub urlgetLWP {
	my $url = shift;
	my $file = shift;
	my $quiet = shift;
	my $status = 0;
	my $timeout = 1200;
	my $ua = LWP::UserAgent->new;
	$ua->agent($agent);
	$ua->timeout(30);
	my $req = HTTP::Request->new(GET => $url);
	my $res;
	my $text;
	($status, $text) = eval {
		local $SIG{__DIE__} = undef;
		local $SIG{'ALRM'} = sub {die "Download timeout after $timeout seconds"};
		alarm($timeout);
		if ($file) {
			local $|=1;
			my $expected_length;
			my $bytes_received = 0;
			my $per = 0;
			my $oldper = 0;
			open (my $OUT, ">", "$file\.tmp") or return (1, "Unable to open $file\.tmp: $!");
			flock ($OUT, LOCK_EX);
			binmode ($OUT);
			$res = $ua->request($req,
				sub {
				my($chunk, $res) = @_;
				$bytes_received += length($chunk);
				unless (defined $expected_length) {$expected_length = $res->content_length || 0}
				if ($expected_length) {
					my $per = int(100 * $bytes_received / $expected_length);
					if ((int($per / 5) == $per / 5) and ($per != $oldper) and !$quiet) {
						print "...$per\%\n";
						$oldper = $per;
					}
				} else {
					unless ($quiet) {print "."}
				}
				print $OUT $chunk;
			});
			close ($OUT);
			unless ($quiet) {print "\n"}
		} else {
			$res = $ua->request($req);
		}
		alarm(0);
		if ($res->is_success) {
			if ($file) {
				rename ("$file\.tmp","$file") or return (1, "Unable to rename $file\.tmp to $file: $!");
				return (0, $file);
			} else {
				return (0, $res->content);
			}
		} else {
			return (1, "Unable to download: ".$res->message);
		}
	};
	alarm(0);
	if ($@) {
		return (1, $@);
	}
	if ($text) {
		return ($status,$text);
	} else {
		return (1, "Download timeout after $timeout seconds");
	}
}
# end urlget
###############################################################################

1;