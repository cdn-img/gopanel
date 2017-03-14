#!/usr/bin/perl
#WHMADDON:csf:ConfigServer Security & Firewall
###############################################################################
# Copyright 2006-2017, Way to the Web Limited
# URL: http://www.configserver.com
# Email: sales@waytotheweb.com
###############################################################################
## no critic (RequireUseWarnings, ProhibitExplicitReturnUndef, ProhibitMixedBooleanOperators, RequireBriefOpen)
# start main
use strict;
use File::Find;
use Fcntl qw(:DEFAULT :flock);
use Sys::Hostname qw(hostname);
use IPC::Open3;

use lib '/usr/local/csf/lib';
use ConfigServer::DisplayUI;
use ConfigServer::DisplayResellerUI;
use ConfigServer::Config;

use lib '/usr/local/cpanel';
use Cpanel::Form			();
use Cpanel::Config          ();
use Cpanel::Template        ();
use Whostmgr::HTMLInterface ();
use Whostmgr::ACLS			();

Whostmgr::ACLS::init_acls();

our ($reseller, $script, $images, %rprivs, $myv, %FORM);

my $config = ConfigServer::Config->loadconfig();
my %config = $config->config;
my $ui = "new";

if (-e "/usr/local/cpanel/bin/register_appconfig") {
	$script = "csf.cgi";
	$images = "csf";
} else {
	$script = "addon_csf.cgi";
	$images = "csf";
}

print "Content-type: text/html\r\n\r\n";

open (my $RESELLERS,"<","/etc/csf/csf.resellers");
flock ($RESELLERS, LOCK_SH);
while (my $line = <$RESELLERS>) {
	my ($user,$alert,$privs) = split(/\:/,$line);
	$privs =~ s/\s//g;
	foreach my $priv (split(/\,/,$privs)) {
		$rprivs{$user}{$priv} = 1;
	}
	$rprivs{$user}{ALERT} = $alert;
}
close ($RESELLERS);
$reseller = 0;
if (!Whostmgr::ACLS::hasroot()) {
	if ($rprivs{$ENV{REMOTE_USER}}{USE}) {
		$reseller = 1;
	} else {
		print "You do not have access to ConfigServer Firewall.\n";
		exit();
	}
}

eval ('use Cpanel::Rlimit			();'); ##no critic
unless ($@) {Cpanel::Rlimit::set_rlimit_to_infinity()}

open (my $IN, "<", "/etc/csf/version.txt") or die $!;
$myv = <$IN>;
close ($IN);
chomp $myv;

%FORM = Cpanel::Form::parseform();

my $bootstrapcss = "<link rel='stylesheet' href='$images/bootstrap/css/bootstrap.min.css'>";
my $jqueryjs = "<script src='$images/jquery.min.js'></script>";
my $bootstrapjs = "<script src='$images/bootstrap/js/bootstrap.min.js'></script>";

my @header;
my @footer;
my $htmltag = "data-post='$FORM{action}'";
if (-e "/etc/csf/csf.header") {
	open (my $HEADER, "<", "/etc/csf/csf.header");
	flock ($HEADER, LOCK_SH);
	@header = <$HEADER>;
	close ($HEADER);
}
if (-e "/etc/csf/csf.footer") {
	open (my $FOOTER, "<", "/etc/csf/csf.footer");
	flock ($FOOTER, LOCK_SH);
	@footer = <$FOOTER>;
	close ($FOOTER);
}
unless ($config{STYLE_CUSTOM}) {
	undef @header;
	undef @footer;
	$htmltag = "";
}

if ($ui eq "new") {
	my $templatehtml;
	unless ($FORM{action} eq "tailcmd" or $FORM{action} eq "logtailcmd" or $FORM{action} eq "loggrepcmd") {
		open CSFOUT, '>', \$templatehtml;
		select CSFOUT;
		print <<EOF;
		</div>
	</div>
</div>
<style>
.toplink {
	top: 140px;
}
.mobilecontainer {
	display:none;
}
.normalcontainer {
	display:block;
}
EOF
		if ($config{STYLE_MOBILE} or $reseller) {
			print <<EOF;
\@media (max-width: 600px) {
	.mobilecontainer {
		display:block;
	}
	.normalcontainer {
		display:none;
	}
}
EOF
		}
		print "</style>\n";
		print @header;
		print <<EOF;
<div id="loader"></div>
<br />
<a id='toplink' class='toplink' title='Go to bottom'><span class='glyphicon glyphicon-hand-down'></span></a>
<div class='container-fluid'>
<div class='panel panel-default'>
<h4><img src='$images/csf_small.png' style='padding-left: 10px'> ConfigServer Security &amp; Firewall - csf v$myv</h4>
</div>
EOF
	} else {
		print <<EOF;
<!doctype html>
<html lang='en' $htmltag>
<head>
	<title>ConfigServer Security &amp; Firewall</title>
	<meta charset='utf-8'>
	<meta name='viewport' content='width=device-width, initial-scale=1'>
</head>
<body>
EOF
	}

	if ($reseller) {
		ConfigServer::DisplayResellerUI::main(\%FORM, $script, 0, $images, $myv);
	} else {
		ConfigServer::DisplayUI::main(\%FORM, $script, 0, $images, $myv);
	}

	unless ($FORM{action} eq "tailcmd" or $FORM{action} eq "logtailcmd" or $FORM{action} eq "loggrepcmd") {print "</div>\n"}
	print <<EOF;
<a class='botlink' id='botlink' title='Go to top'><span class='glyphicon glyphicon-hand-up'></span></a>
<script>
	function getCookie(cname) {
		var name = cname + "=";
		var ca = document.cookie.split(';');
		for(var i = 0; i <ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') {
				c = c.substring(1);
			}
			if (c.indexOf(name) == 0) {
				return c.substring(name.length,c.length);
			}
		}
		return "";
	} 
	\$("#loader").hide();
	\$.fn.scrollBottom = function() { 
	  return \$(document).height() - this.scrollTop() - this.height(); 
	};
	\$('#botlink').on("click",function(){
		\$('html,body').animate({ scrollTop: 0 }, 'slow', function () {});
	});
	\$('#toplink').on("click",function() {
		var window_height = \$(window).height();
		var document_height = \$(document).height();
		\$('html,body').animate({ scrollTop: window_height + document_height }, 'slow', function () {});
	});
	\$('#tabAll').click(function(){
		\$('#tabAll').addClass('active');  
		\$('.tab-pane').each(function(i,t){
			\$('#myTabs li').removeClass('active'); 
			\$(this).addClass('active');  
		});
	});
	\$(document).ready(function(){
		\$('.topFrameWrapper').css('font-family', 'Lucida Sans Unicode,Lucida Grande,sans-serif');
		\$('.topFrameWrapper').css('font-size', '13px');
		\$('#navigation').css('font-family', 'Lucida Sans Unicode,Lucida Grande,sans-serif');
		\$('#navigation').css('font-size', '13px');
		\$('[data-tooltip="tooltip"]').tooltip();
		\$(window).scroll(function () {
			if (\$(this).scrollTop() > 500) {
				\$('#botlink').fadeIn();
			} else {
				\$('#botlink').fadeOut();
			}
			if (\$(this).scrollBottom() > 500) {
				\$('#toplink').fadeIn();
			} else {
				\$('#toplink').fadeOut();
			}
		});
EOF
		if ($config{STYLE_MOBILE} or $reseller) {
			print <<EOF;
		var csfview = getCookie('csfview');
		if (csfview == 'mobile') {
			\$(".mobilecontainer").css('display','block');
			\$(".normalcontainer").css('display','none');
			\$("#csfreturn").addClass('btn-primary btn-lg btn-block').removeClass('btn-default');
		} else if (csfview == 'desktop') {
			\$(".mobilecontainer").css('display','none');
			\$(".normalcontainer").css('display','block');
			\$("#csfreturn").removeClass('btn-primary btn-lg btn-block').addClass('btn-default');
		}
		if (top.location == location) {
			\$("#cpframetr2").show();
		} else {
			\$("#cpframetr2").hide();
		}
		if (\$(".mobilecontainer").css('display') == 'block' ) {
			document.cookie = "csfview=mobile; path=/";
			if (top.location != location) {
				top.location.href = document.location.href ;
			}
		}
		\$(window).resize(function() {
			if (\$(".mobilecontainer").css('display') == 'block' ) {
				document.cookie = "csfview=mobile; path=/";
				if (top.location != location) {
					top.location.href = document.location.href ;
				}
			}
		});
EOF
		}
		print "});\n";
		if ($config{STYLE_MOBILE} or $reseller) {
			print <<EOF;
	\$("#NormalView").click(function(){
		document.cookie = "csfview=desktop; path=/";
		\$(".mobilecontainer").css('display','none');
		\$(".normalcontainer").css('display','block');
	});
	\$("#MobileView").click(function(){
		document.cookie = "csfview=mobile; path=/";
		if (top.location == location) {
			\$(".normalcontainer").css('display','none');
			\$(".mobilecontainer").css('display','block');
		} else {
			top.location.href = document.location.href;
		}
	});
EOF
		}
	print "</script>\n";
	print @footer;
	unless ($FORM{action} eq "tailcmd" or $FORM{action} eq "logtailcmd" or $FORM{action} eq "loggrepcmd") {
		print "<div><div><div>\n";
		close CSFOUT;
		select STDOUT;
		Cpanel::Template::process_template(
			'whostmgr',
			{
				'template_file' => 'csfalt.tmpl',
				'csf_output' => $templatehtml,
				'print'         => 1,
			}
		);
	} else {
		print "</body>\n";
		print "</html>\n";
	}
} else {
	print <<EOF;
<!doctype html>
<html lang='en' $htmltag>
<head>
	<title>ConfigServer Security &amp; Firewall</title>
	<meta charset='utf-8'>
	<meta name='viewport' content='width=device-width, initial-scale=1'>
EOF
	unless ($FORM{action} eq "tailcmd" or $FORM{action} eq "logtailcmd" or $FORM{action} eq "loggrepcmd") {
		print <<EOF;
	$bootstrapcss
	<link href='$images/configserver.css' rel='stylesheet' type='text/css'>
	$jqueryjs
	$bootstrapjs

<style>
.mobilecontainer {
	display:none;
}
.normalcontainer {
	display:block;
}
EOF
		if ($config{STYLE_MOBILE} or $reseller) {
			print <<EOF;
\@media (max-width: 600px) {
	.mobilecontainer {
		display:block;
	}
	.normalcontainer {
		display:none;
	}
}
EOF
		}
		print "</style>\n";
		print @header;
		print <<EOF;
</head>
<body>
<div id="loader"></div>
<a id='toplink' class='toplink' title='Go to bottom'><span class='glyphicon glyphicon-hand-down'></span></a>
<div class='container-fluid'>
<div class='panel panel-default'>
<h4><img src='$images/csf_small.png' style='padding-left: 10px'> ConfigServer Security &amp; Firewall - csf v$myv</h4>
</div>
EOF
	} else {
		print "</head>\n";
		print "<body>\n";
	}

	if ($reseller) {
		ConfigServer::DisplayResellerUI::main(\%FORM, $script, 0, $images, $myv);
	} else {
		ConfigServer::DisplayUI::main(\%FORM, $script, 0, $images, $myv);
	}

	unless ($FORM{action} eq "tailcmd" or $FORM{action} eq "logtailcmd" or $FORM{action} eq "loggrepcmd") {print "</div>\n"}
	print <<EOF;
<a class='botlink' id='botlink' title='Go to top'><span class='glyphicon glyphicon-hand-up'></span></a>
<script>
	function getCookie(cname) {
		var name = cname + "=";
		var ca = document.cookie.split(';');
		for(var i = 0; i <ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') {
				c = c.substring(1);
			}
			if (c.indexOf(name) == 0) {
				return c.substring(name.length,c.length);
			}
		}
		return "";
	} 
	\$("#loader").hide();
	\$.fn.scrollBottom = function() { 
	  return \$(document).height() - this.scrollTop() - this.height(); 
	};
	\$('#botlink').on("click",function(){
		\$('html,body').animate({ scrollTop: 0 }, 'slow', function () {});
	});
	\$('#toplink').on("click",function() {
		var window_height = \$(window).height();
		var document_height = \$(document).height();
		\$('html,body').animate({ scrollTop: window_height + document_height }, 'slow', function () {});
	});
	\$('#tabAll').click(function(){
		\$('#tabAll').addClass('active');  
		\$('.tab-pane').each(function(i,t){
			\$('#myTabs li').removeClass('active'); 
			\$(this).addClass('active');  
		});
	});
	\$(document).ready(function(){
		\$('[data-tooltip="tooltip"]').tooltip();
		\$(window).scroll(function () {
			if (\$(this).scrollTop() > 500) {
				\$('#botlink').fadeIn();
			} else {
				\$('#botlink').fadeOut();
			}
			if (\$(this).scrollBottom() > 500) {
				\$('#toplink').fadeIn();
			} else {
				\$('#toplink').fadeOut();
			}
		});
EOF
		if ($config{STYLE_MOBILE} or $reseller) {
			print <<EOF;
		var csfview = getCookie('csfview');
		if (csfview == 'mobile') {
			\$(".mobilecontainer").css('display','block');
			\$(".normalcontainer").css('display','none');
			\$("#csfreturn").addClass('btn-primary btn-lg btn-block').removeClass('btn-default');
		} else if (csfview == 'desktop') {
			\$(".mobilecontainer").css('display','none');
			\$(".normalcontainer").css('display','block');
			\$("#csfreturn").removeClass('btn-primary btn-lg btn-block').addClass('btn-default');
		}
		if (top.location == location) {
			\$("#cpframetr2").show();
		} else {
			\$("#cpframetr2").hide();
		}
		if (\$(".mobilecontainer").css('display') == 'block' ) {
			document.cookie = "csfview=mobile; path=/";
			if (top.location != location) {
				top.location.href = document.location.href ;
			}
		}
		\$(window).resize(function() {
			if (\$(".mobilecontainer").css('display') == 'block' ) {
				document.cookie = "csfview=mobile; path=/";
				if (top.location != location) {
					top.location.href = document.location.href ;
				}
			}
		});
EOF
		}
		print "});\n";
		if ($config{STYLE_MOBILE} or $reseller) {
			print <<EOF;
	\$("#NormalView").click(function(){
		document.cookie = "csfview=desktop; path=/";
		\$(".mobilecontainer").css('display','none');
		\$(".normalcontainer").css('display','block');
	});
	\$("#MobileView").click(function(){
		document.cookie = "csfview=mobile; path=/";
		if (top.location == location) {
			\$(".normalcontainer").css('display','none');
			\$(".mobilecontainer").css('display','block');
		} else {
			top.location.href = document.location.href;
		}
	});
EOF
		}
	print "</script>\n";
	print @footer;
	print "</body>\n";
	print "</html>\n";
}

1;
