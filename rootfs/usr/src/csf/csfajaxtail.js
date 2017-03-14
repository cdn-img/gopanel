//#############################################################################
//# Copyright 2006-2016, Way to the Web Limited
//# URL: http://www.configserver.com
//# Email: sales@waytotheweb.com
//#############################################################################

var CSFscript = '';
var CSFcountval = 6;
var CSFlineval = 100;
var CSFcounter;
var CSFcount = 1;
var CSFpause = 0;
var CSFfrombot = 120;
var CSFfromright = 10;
var CSFsettimer = 1;
var CSFheight = 0;
var CSFwidth = 0;
var CSFajaxHTTP = CSFcreateRequestObject();

function CSFcreateRequestObject() {
	var CSFajaxRequest;
	if (window.XMLHttpRequest) {
		CSFajaxRequest = new XMLHttpRequest();
	}
	else if (window.ActiveXObject) {
		CSFajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else {
		alert('There was a problem creating the XMLHttpRequest object in your browser');
		CSFajaxRequest = '';
	}
	return CSFajaxRequest;
}

function CSFsendRequest(url) {
	var now = new Date();
	CSFajaxHTTP.open('get', url + '&nocache=' + now.getTime());
	CSFajaxHTTP.onreadystatechange = CSFhandleResponse;
	CSFajaxHTTP.send();
	document.getElementById("CSFrefreshing").style.display = "inline";
} 

function CSFhandleResponse() {
	if(CSFajaxHTTP.readyState == 4 && CSFajaxHTTP.status == 200){
		var response = CSFajaxHTTP.responseText;
		if(response) {
			var CSFobj = document.getElementById("CSFajax");
			CSFobj.innerHTML = CSFajaxHTTP.responseText;
			windowSize();
//			if (CSFheight > 0) {CSFobj.style.height = (CSFheight - CSFobj.offsetTop - CSFfrombot)  + "px";}
//			if (CSFwidth > 0) {CSFobj.style.width = '98%';}//(CSFwidth - CSFobj.offsetLeft - CSFfromright)  + "px";}
			CSFobj.scrollTop = CSFobj.scrollHeight;
			document.getElementById("CSFrefreshing").style.display = "none";
			if (CSFsettimer) {CSFcounter = setInterval(CSFtimer, 1000);}
		}
	}
}

function CSFgrep() {
	var CSFlogobj = document.getElementById("CSFlognum");
	var CSFlognum;
	if (CSFlogobj) {CSFlognum = '&lognum=' + CSFlogobj.options[CSFlogobj.selectedIndex].value}
	else {CSFlognum = ""}
	if (document.getElementById("CSFgrep_i").checked) {CSFlognum = CSFlognum + "&grepi=1"}
	if (document.getElementById("CSFgrep_E").checked) {CSFlognum = CSFlognum + "&grepE=1"}
	var CSFurl = CSFscript + '&grep=' + document.getElementById("CSFgrep").value + CSFlognum;
	if (document.getElementById("CSFgrep_D").checked) {
		window.open(CSFurl);
	} else {
		CSFsendRequest(CSFurl);
	}
}

function CSFtimer() {
	if (CSFpause) {return}
	CSFcount = CSFcount - 1;
	document.getElementById("CSFtimer").innerHTML = CSFcount;
	if (CSFcount <= 0) {
		clearInterval(CSFcounter);
		var CSFlogobj = document.getElementById("CSFlognum");
		var CSFlognum;
		if (CSFlogobj) {CSFlognum = '&lognum=' + CSFlogobj.options[CSFlogobj.selectedIndex].value}
		else {CSFlognum = ""}
		CSFsendRequest(CSFscript + '&lines=' + document.getElementById("CSFlines").value + CSFlognum);
		CSFcount = CSFcountval;
		return;
	}
}

function CSFpausetimer() {
	if (CSFpause) {
		CSFpause = 0;
		document.getElementById("CSFpauseID").innerHTML = "Pause";
	}
	else {
		CSFpause = 1;
		document.getElementById("CSFpauseID").innerHTML = "Continue";
	}
}

function CSFrefreshtimer() {
	var pause = CSFpause;
	CSFcount = 1;
	CSFpause = 0;
	CSFtimer();
	CSFpause = pause;
	CSFcount = CSFcountval - 1;
	document.getElementById("CSFtimer").innerHTML = CSFcount;
}

function windowSize() {
	if( typeof( window.innerHeight ) == 'number' ) {
		CSFheight = window.innerHeight;
		CSFwidth = window.innerWidth;
	}
	else if (document.documentElement && (document.documentElement.clientHeight)) {
		CSFheight = document.documentElement.clientHeight;
		CSFwidth = document.documentElement.clientWidth;
	}
	else if (document.body && (document.body.clientHeight)) {
		CSFheight = document.body.clientHeight;
		CSFwidth = document.body.clientWidth;
	}
}
//#############################################################################
//# Copyright 2006-2016, Way to the Web Limited
//# URL: http://www.configserver.com
//# Email: sales@waytotheweb.com
//#############################################################################
