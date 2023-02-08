/// View Console Log
Class otw.log.irislogviewer Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
	&html<<html>
		<head><title>Console Log Viewer</title></head>
        <body>>
    Set iAlerts = 0
	Set iFormat = "DISPLAY"
	Set pImportDeleteExtent = 4  // I want to Delete Extent ONCE
	Set thisHref = "otw.log.irislogviewer.cls"
	If ($data(%request.Data("iAlerts",1))) {
	 	Set iAlerts = %request.Data("iAlerts",1)
	}
	If ($data(%request.Data("iFormat",1))) {
	 	Set iFormat = %request.Data("iFormat",1)
	}
	If ($data(%request.Data("iFromPeriod",1))) {
	 	Set iFromPeriod = %request.Data("iFromPeriod",1)
	 	Set pFilter("iFromPeriod") = iFromPeriod
	}
	If ($data(%request.Data("iMaxSeverity",1))) {
	 	Set iMaxSeverity = %request.Data("iMaxSeverity",1)
	 	Set pFilter("iMaxSeverity") = iMaxSeverity
	}
	If ($data(%request.Data("iMinSeverity",1))) {
	 	Set iMinSeverity = %request.Data("iMinSeverity",1)
	 	Set pFilter("iMinSeverity") = iMinSeverity
	}
	If ($data(%request.Data("iToPeriod",1))) {
	 	Set iToPeriod = %request.Data("iToPeriod",1)
	 	Set pFilter("iToPeriod") = iToPeriod
	}
	If $get(%request.CgiEnvs("SERVER_NAME"))'="" {
		Set url="//"_%request.CgiEnvs("SERVER_NAME")_%request.URL
	} Else {
		Set url=%request.URL
	}
	Set dir = $$GetFilename^%apiCSP(url)
	If $$$isWINDOWS Set dir = $translate(dir,"\","/")
 	If $$$isVMS {
 		Set dir = $piece(dir,"]")_"]"
 	} Else {
 		Set dir = $piece(dir,"/",1,$length(dir,"/")-1)
 	}
	Set mgrdir = $system.Util.ManagerDirectory()  // $zu(12)
	Set alerts = mgrdir_"alerts.log"
	Set source = mgrdir_"messages.log"
	Set target = dir_"/download_messages.txt"
	Set pDeleteBeforeCopy = 1
	Set tSC = ##class(otw.log.Log).CopyFile(source,target,pDeleteBeforeCopy,.return)
	If ($Get(iAlerts) = "true") {
		Set tAlertsChecked = " checked"
	}
	&html<
		<P><B>Date/Time:</B>
		<label for="fromperiod">From</label>
		<input type="datetime-local" id="fromperiod" name="from" value="#($Get(iFromPeriod))#">
		<label for="toperiod">to</label>
		<input type="datetime-local" id="toperiod" name="to" value="#($Get(iToPeriod))#">
		<B>Levels:</B>
		<label for="fromlevel">From</label>
		<input type="text" id="fromlevel" name="from" value="#($Get(iMinSeverity))#">
		<label for="tolevel">to</label>
		<input type="text" id="tolevel" name="to" value="#($Get(iMaxSeverity))#">
		<a href="#(thisHref)#">Clear filters</a>
		<P><B>#(dir)#</B>
		<input type="checkbox" id="checkAlerts" name="checkAlerts" value="checkAlerts"#($Get(tAlertsChecked))#>
		<label for="checkAlerts">Show Alerts</label>
		<a href="download_messages.txt" download="messages.log" target="_blank">Download link</a>
 	>
	&html<<button type="button" onclick="goClickButton('DISPLAY')">Display</button>>
	&html<<button type="button" onclick="goClickButton('RAW')">Raw</button>>
	&html<<hr>>
	If ($Get(iAlerts) = "true") {
		&html<<table cellpadding=0 border=1 style="color:red;">>
		Set pImportDeleteExtent = $Get(pImportDeleteExtent,4)  // Delete Extent only ONCE
		Set pImportAlerts = 2
		Set pImport = pImportDeleteExtent + pImportAlerts
		Set pMaxLines = -1
		Set pFilter("pMaxLines") = pMaxLines
		Set tSC = ##class(otw.log.Log).ImportMessages(alerts,.pAlertLines,.pFilter,pImport)
		If pAlertLines {
			Set tSC = ##class(otw.log.Log).OutputAlerts(alerts,iFormat,.pAlertLines)
		}
		Set pImportDeleteExtent = 0  // Delete Extent already happened above
		&html<
			</table>
			<hr>>
	}
	&html<<table cellpadding=0 border=1>>
	If ($Get(iFormat,"DISPLAY") = "DISPLAY") {
		Set pFile = ""
		Set pImport = pImportDeleteExtent + 1  // I want to Delete Extent ONCE
		Set pMaxLines = 15
		Set pFilter("pMaxLines") = pMaxLines
		Set tSC = ##class(otw.log.Log).ImportMessages(pFile,.pLines,.pFilter,pImport)
		Set tSC = ##class(otw.log.Log).OutputTableData()
	}
	If ($Get(iFormat,"DISPLAY") = "RAW") {
		Set pFile = ""
		Set pImport = 0
		Set pMaxLines = -1
		Set pFilter("pMaxLines") = pMaxLines
		Set tSC = ##class(otw.log.Log).ReadLogLines(pFile,.pLines,.pFilter,pImport)
		Set tSC = ##class(otw.log.Log).OutputRawData(.pLines)
	}
	&html<
		</table>
		<hr>
		</body>
		<script language="JavaScript">
		function goClickButton(id)
		{
			if (id == 'MENU') {
				document.location = "menu.csp";
				return;
			}
			var iAlerts = document.getElementById("checkAlerts").checked;  // true or false
			var iFormat = "DISPLAY";
			if (id == 'RAW') {
				iFormat = "RAW";
			}
			var iFromPeriod = document.getElementById("fromperiod").value;
			var iToPeriod = document.getElementById("toperiod").value;
			var iMinSeverity = document.getElementById("fromlevel").value;
			var iMaxSeverity = document.getElementById("tolevel").value;
			var params1 = "&iFormat=" + iFormat + "&iFromPeriod=" + iFromPeriod + "&iToPeriod=" + iToPeriod;
			var params2 = "&iMinSeverity=" + iMinSeverity + "&iMaxSeverity=" + iMaxSeverity;
			var params = "iAlerts=" + iAlerts + params1 + params2;
			document.location = "#(thisHref)#?" + params
		}
		</script>
		</html>>
	Quit $$$OK
}

}
