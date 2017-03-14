###############################################################################
# Copyright 2006-2017, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
## no critic (RequireUseWarnings, ProhibitExplicitReturnUndef, ProhibitMixedBooleanOperators, RequireBriefOpen)
# start main
package ConfigServer::LookUpIP;

use strict;
use lib '/usr/local/csf/lib';
use Carp;
use Fcntl qw(:DEFAULT :flock);
use Geo::IP;
use IPC::Open3;
use Net::IP;
use Socket;
use ConfigServer::CheckIP qw(checkip);
use ConfigServer::Config;

use Exporter qw(import);
our $VERSION     = 1.02;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw(iplookup);

my $config = ConfigServer::Config->loadconfig();
my %config = $config->config();

# end main
###############################################################################
# start iplookup
sub iplookup {
	my $ip = shift;
	my $cconly = shift;
	my $host = "-";
	my $iptype = checkip(\$ip);

	if ($config{LF_LOOKUPS} and !$cconly) {
		my $dnsip;
		my $dnsrip;
		my $dnshost;
		my $cachehit;
		open (my $DNS, "<", "/var/lib/csf/csf.dnscache");
		flock ($DNS, LOCK_SH);
		while (my $line = <$DNS>) {
			chomp $line;
			($dnsip,$dnsrip,$dnshost) = split(/\|/,$line);
			if ($ip eq $dnsip) {
				$cachehit = 1;
				last;
			}
		}
		close ($DNS);
		if ($cachehit) {
			$host = $dnshost;
		} else {
			if (-e $config{HOST} and -x $config{HOST}) {
				my $cmdpid;
				eval {
					local $SIG{__DIE__} = undef;
					local $SIG{'ALRM'} = sub {die};
					alarm(10);
					my ($childin, $childout);
					$cmdpid = open3($childin, $childout, $childout, $config{HOST},"-W","5",$ip);
					close $childin;
					my @results = <$childout>;
					waitpid ($cmdpid, 0);
					chomp @results;
					if ($results[0] =~ /(\S+)\.$/) {$host = $1}
					alarm(0);
				};
				alarm(0);
				if ($cmdpid =~ /\d+/ and $cmdpid > 1 and kill(0,$cmdpid)) {kill(9,$cmdpid)}
			} else {
				if ($iptype == 4) {
					eval {
						local $SIG{__DIE__} = undef;
						local $SIG{'ALRM'} = sub {die};
						alarm(10);
						my $ipaddr = inet_aton($ip);
						$host = gethostbyaddr($ipaddr, AF_INET);
						alarm(0);
					};
					alarm(0);
				}
				elsif ($iptype == 6) {
					eval {
						local $SIG{__DIE__} = undef;
						local $SIG{'ALRM'} = sub {die};
						alarm(10);
						eval('use Socket6;'); ##no critic
						my $ipaddr = inet_pton(AF_INET6, $ip);
						$host = gethostbyaddr($ipaddr, AF_INET6);
						alarm(0);
					};
					alarm(0);
				}
			}
			sysopen (DNS, "/var/lib/csf/csf.dnscache", O_WRONLY | O_APPEND | O_CREAT);
			flock (DNS, LOCK_EX);
			print DNS "$ip|$ip|$host\n";
			close (DNS);
		}
		if ($host eq "") {$host = "-"}
	}

	if ($config{CC_LOOKUPS}) {
		if ($iptype == 4) {
			my $ipcountry;
			if ($config{CC_LOOKUPS} == 2 or $config{CC_LOOKUPS} == 3) {
				if (-e "/var/lib/csf/Geo/GeoLiteCity.dat") {$ipcountry = Geo::IP->open("/var/lib/csf/Geo/GeoLiteCity.dat")}
				if (defined $ipcountry) {
					my $record = $ipcountry->record_by_addr($ip);
					if (defined $record) {
						my $cc = $record->country_code;
						if ($cconly) {return $cc}
						my $country = $record->country_name;
						my $region = $record->region_name;
						my $city = $record->city;
						unless ($cc) {$cc = "-"}
						unless ($country) {$country = "-"}
						unless ($region) {$region = "-"}
						unless ($city) {$city = "-"}
						my $result = "$ip ($cc/$country/$region/$city/$host)";
						$result =~ s/'//g;

						if ($config{CC_LOOKUPS} == 3) {
							my $ipasn;
							if (-e "/var/lib/csf/Geo/GeoIPASNum.dat") {$ipasn = Geo::IP->open("/var/lib/csf/Geo/GeoIPASNum.dat",GEOIP_STANDARD)}
							if (defined $ipasn) {
								my $asn = $ipasn->org_by_addr($ip);
								unless ($asn) {$asn = "-"}
								$result = "$ip ($cc/$country/$region/$city/$host/[$asn])";
								$result =~ s/'//g;
							}
						}

						return $result;
					} else {
						return "$ip (-/-/-/-/$host)";
					}
				}
			} else {
				if (-e "/var/lib/csf/Geo/GeoIP.dat") {$ipcountry = Geo::IP->open("/var/lib/csf/Geo/GeoIP.dat")}
				if (defined $ipcountry) {
					my $cc = $ipcountry->country_code_by_addr($ip);
					if ($cconly) {return $cc}
					my $country = $ipcountry->country_name_by_addr($ip);
					unless ($cc) {$cc = "-"}
					unless ($country) {$country = "-"}
					my $result = "$ip ($cc/$country/$host)";
					$result =~ s/'//g;
					return $result;
				}
			}
		}
		elsif ($config{CC6_LOOKUPS} and $iptype == 6) {
			if (-e "/var/lib/csf/Geo/GeoIPv6.csv") {
				my $netip;
				my $ipint;
				eval {
					local $SIG{__DIE__} = undef;
					$netip = Net::IP->new($ip);
					$ipint = ($netip->intip());
				};
				if ($ipint) {
					open (my $IN, "<", "/var/lib/csf/Geo/GeoIPv6.csv");
					flock ($IN, LOCK_SH);
					while (my $line = <$IN>) {
						chomp $line;
						my (undef, undef,$from,$to,$cc,$country) = split(/\,/,$line);
						$from =~ s/"|\s//g;
						$to =~ s/"|\s//g;
						$cc =~ s/"|\s//g;
						$country =~ s/"//g;
						$country =~ s/^\s+|\s+$//g;

#						my $ipv6 = Net::CIDR::Lite->new;
#						eval {local $SIG{__DIE__} = undef; $ipv6->add_range("$from - $to")};
#						if ($ipv6->find($ip)) {
						if ($ipint >= $from and $ipint <= $to) {
							if ($cconly) {return $cc}
							unless ($cc) {$cc = "-"}
							unless ($country) {$country = "-"}
							my $result = "$ip ($cc/$country/$host)";
							$result =~ s/'//g;
							return $result;
						}
					}
					close ($IN);
				}
			}
			return "$ip (-/-/$host)";
		}
	}

	if ($config{LF_LOOKUPS}) {
		if ($host eq "-") {$host = "Unknown"}
		my $result = "$ip ($host)";
		$result =~ s/'//g;
		return $result;
	} else {
		return $ip;
	}
}
# end iplookup
###############################################################################

1;