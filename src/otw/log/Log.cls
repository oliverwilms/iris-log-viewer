Class otw.log.Log Extends %Persistent
{

Property Alert As %String;

Property LogDate As %Date;

Property LogTime As %String;

Property LogDTun As %String;

Property Process As %Integer;

Property Severity As %Integer;

Property Text As %String(MAXLEN = 999999);

ClassMethod AddLineTest() As %Status
{
	Set pLog = ..%New()
	Set pLogDate = "10/13/22"
	If (pLogDate ? 1.2N1"/"1.2N1"/"1.4N) {
		Set pAA = $Piece(pLogDate,"/",1,2)
		Set pYY = +$Piece(pLogDate,"/",3)
		If (pYY < 100) Set pYY = pYY + 2000
		Set pLogDate = pAA_"/"_pYY
		Set pLogDateH = $ZDateH(pLogDate)
	}
	If ($Get(pLogDateH) '= "") Set pLog.LogDate = pLogDateH
	If ($Get(pLogTime) '= "") Set pLog.LogTime = pLogTime
	If ($Get(pLogText) '= "") Set pLog.Text = pLogText
	If ($Get(pProcess) '= "") Set pLog.Process = pProcess
	If ($Get(pSeverity) '= "") Set pLog.Severity = pSeverity
	Set tSC = pLog.%Save()
	If $$$ISERR(tSC) {
		Set x = $System.Status.GetErrorText(tSC)
		Write x,!
	}
	Quit tSC
}

ClassMethod CopyFile(pFrom As %String, pTo As %String, pDeleteBeforeCopy As %Boolean = 0, Output return As %Integer) As %Boolean
{
	If ($Get(pFrom) = "") {
		Set mgrDir = $ZU(12)
		Set pFrom = mgrDir_"messages.log"
	}
	If ($Get(pTo) = "") {
		Set mgrDir = $ZU(12)
		Set pTo = mgrDir_"messages.log"
	}
	Set tSC = ##class(%Library.File).CopyFile(pFrom,pTo,pDeleteBeforeCopy,.return)
	Quit tSC
}

ClassMethod ImportLine(pLine As %String = "", ByRef pLog As Log, ByRef pFilter, pImport = 1) As %Status
{
	Set tSC = $$$OK
	Set iMaxSeverity = $Get(pFilter("iMaxSeverity"),-1)
	Set iMinSeverity = $Get(pFilter("iMinSeverity"),0)
	If (pLine = "") Set pLine = "Journaling switched to: c:\intersystems\irishealth\mgr\journal\20221015.001"
	If (pLine = "") Set pLine = "01/21/23-11:30:25:402 (10888) 0 [Utility.Event] [SYSTEM MONITOR] Alert state cleared."
	Set pLogDate = ""
	If (pLine ? 1.2N1"/"1.2N1"/"2N.E) {
		Set pAA = $Piece(pLine,"/",1,2)
		Set pYY = +$Piece(pLine,"/",3)
		Set pLogDate = pAA_"/"_pYY
		Set pos = 1 + $Length(pLogDate)
		If (pYY < 100) {
			Set pYY = pYY + 2000
			Set pLogDate = pAA_"/"_pYY
		}
		Set pLogDateH = $ZDateH(pLogDate)
		Set pTest = $Extract(pLine,pos,pos)
		If (pTest = "-") {
			Set pos = pos + 1
			Set pTest = $Extract(pLine,pos,*)
			If (pTest ? 1.2N1":"1.2N1":"2N.E) {
				Set pHH = $Piece(pTest,":",1)
				Set pMM = $Piece(pTest,":",2)
				Set pSS = $Piece(pTest,":",3)
				Set pHMS = $Piece(pTest,":",1,3)
				Set pMS = $Piece(pTest,":",4)
				Set pFF = $Piece(pMS," ",1)
				Set pLogTime = pHMS_":"_pFF
				//Set pLogTimeH = $ZTimeH(pLogTime)  // <ILLEGAL VALUE>
				Set pos = pos + $Length(pLogTime)
				Set pTest = $Extract(pLine,pos,pos)
				If (pTest = " ") {
					Set pos = pos + 1
					Set pTest = $Extract(pLine,pos,pos)
					If (pTest = "(") {
						Set pos = pos + 1
						Set pTest = $Extract(pLine,pos,*)
						If (pTest ? 1.N1")".E) {
							Set pProcess = $Piece(pTest,")",1)
							Set pTest = $Piece(pTest,")",2,*)
							If (pTest ? 1" "1.N1" ".E) {
								Set pSeverity = $Piece(pTest," ",2)
								Set pTest = $Piece(pTest," ",3,*)
								Set pLogText = pTest
							}
						}
					}
				}
			}
		}
	}
	If (pLine ? 1A.E) {
		Set pLogDTunsure = 1  // Inherit Date and Time from previous line
		Try {
			Set pLogDateH = pLog.LogDate
			Set pLogTime = pLog.LogTime
		} Catch { }
		Set pLogText = pLine
	}
	If (iMaxSeverity > -1),($Get(pSeverity) > iMaxSeverity) Set pSkip = 1
	If ($Get(pSeverity) < iMinSeverity) Set pSkip = 1
	If ($Get(pSkip)) { Quit 0 }
	Set pLog = ..%New()
	Set pLog.LogDTun = $Get(pLogDTunsure)
	If ($Get(pLogDateH) '= "") Set pLog.LogDate = pLogDateH
	//If ($Get(pLogTimeH) '= "") Set pLog.LogTime = pLogTimeH
	If ($Get(pLogTime) '= "") Set pLog.LogTime = pLogTime
	If ($Get(pLogText) '= "") Set pLog.Text = pLogText
	If ($Get(pProcess) '= "") Set pLog.Process = pProcess
	If ($Get(pSeverity) '= "") Set pLog.Severity = pSeverity
	If pImport {
		Set tFlag = (pImport #4)
		If (tFlag > 1) Set pLog.Alert = 1
		Set tSC = pLog.%Save()
	}
	If $$$ISERR(tSC) {
		Set x = $System.Status.GetErrorText(tSC)
		Set ^TESTlog($I(^TESTlog)) = x
	}
	Quit tSC
}

ClassMethod ImportMessages(pFile As %String, ByRef pLines, ByRef pFilter = -1, pImport = 1, pDebug = 0) As %Status
{
	If pDebug {
		Write "Import Messages begins at ",$ZDATETIME($HOROLOG),!
	}
	Set tSC = $$$OK
	If (pImport > 2) {
		Set tSC = ..%DeleteExtent()
	}
	If $$$ISERR(tSC) {
		Set x = $System.Status.GetErrorText(tSC)
		If pDebug Write x,!
		Set ^TESTlog($I(^TESTlog)) = x
	}
	If ($Get(pFile) = "") {
		Set mgrDir = $ZU(12)
		Set pFile = mgrDir_"messages.log"
	}
	Set tSC = ..ReadLogLines(pFile,.pLines,.pFilter,pImport)
	If $$$ISERR(tSC) {
		Set x = $System.Status.GetErrorText(tSC)
		If pDebug Write x,!
		Set ^TESTlog($I(^TESTlog)) = x
	}
	If pDebug {
		Write "Import Messages ends at ",$ZDATETIME($HOROLOG),!
	}
	Quit tSC
}

ClassMethod OutputAlerts(pFile As %String = "", pFormat As %String = "", ByRef pLines) As %Status
{
	If (pFile = "") {
		Set mgrDir = $ZU(12)
		Set pFile = mgrDir_"alerts.log"
	}
	Set tSC = $$$OK
	Set tExists = ##class(%Library.File).Exists(pFile)
	If (0 = tExists) { Quit tSC }
	Set tStyle = "style=""color:red;"""
	Write "<h1 ",tStyle,">"
	Write "ALERTS from ",pFile
	Write "</h1>",!
	Write "<div ",tStyle,">",!
	If ($Get(pFormat,"DISPLAY") = "DISPLAY") {
		Set pAlertFlag = 1
		Set tSC = ##class(otw.log.Log).OutputTableData(pAlertFlag)
	}
	If ($Get(pFormat,"DISPLAY") = "RAW") {
		Set tSC = ##class(otw.log.Log).OutputRawData(.pLines)
	}
	Write "<br>&nbsp;<br>",!
	Write "</div>",!
	Quit tSC
}

ClassMethod OutputLogDate(pLogDate = 0) As %String
{
	Set tReturn = $ZDATE(pLogDate)
	Set tReturn = $Piece(tReturn,"/",1,2)  // Drop Year
	Quit tReturn
}

ClassMethod OutputRawData(ByRef pLines) As %Status
{
	Set tQuote = """"
	Set tSC = $$$OK
	Write !,"<tr><th>Raw Text</th></tr>"
	Set max = $Get(pLines,0)
	For ii = 1:1:max {
	 	Set tDisplay = pLines(ii)
		Set tValue = ii
	 	Set pTrClick = ""
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tValue),tQuote,">"
		Write !,"<td>",tDisplay,"</td>"
		Write !,"</tr>"
	}
	Quit tSC
}

ClassMethod OutputTableData(pAlertFlag = 0) As %Status
{
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	Set pWhere = "Alert is Null"
	If pAlertFlag Set pWhere = "Alert = 1"
	If (pWhere '= "") Set tWHERE = " WHERE "_pWhere
	Set tOrder = ""  // " ORDER BY TranDate ASC, TranTime ASC"
	Set tQuery = "SELECT * FROM otw_log.Log"_tWHERE_tOrder
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
	Write !,"<tr><th>Date</th><th>Time</th><th>Job</th><th>L</th><th>Text</th></tr>"
	While tResult.%Next() {
		Set tValue = tResult.ID
		Set tLogDTunsure = tResult.LogDTun
	 	Set tLogDate = ""
	 	Set tLogTime = ""
		If '(tLogDTunsure) {
			Set tLogDate = ..OutputLogDate(tResult.LogDate)
			Set tLogTime = tResult.LogTime
		}
	 	Set pTrClick = ""
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tValue),tQuote,">"
		Write !,"<td>",tLogDate,"</td>"
		//Write !,"<td>",$ZTIME(tResult.TranTime),"</td>"
		Write !,"<td>",tLogTime,"</td>"
		Write !,"<td>",tResult.Process,"</td>"
		Write !,"<td>",tResult.Severity,"</td>"
		Write !,"<td>",tResult.Text,"</td>"
		Write !,"</tr>"
	}
	Quit tSC
}

ClassMethod ReadLogLines(pFile As %String, ByRef pLines, ByRef pFilter = 10, pImport = 1, pDebug = 0) As %String
{
	Write:pDebug "ReadLogLines",!
	If ($Get(pFile) = "") {
		Set mgrDir = $ZU(12)
		Set pFile = mgrDir_"messages.log"
	}
	Set tAlert = ""
	If (pFile [ "alert") Set tAlert = 1
	If (pFile [ "message") Set tAlert = 0
	If ($Get(pFile) = "") Quit ""
	Write:pDebug pFile,!
	Set pLines = 0
	Set pMaxLines = $Get(pFilter("pMaxLines"),pFilter)
	Set pMaxDT = $Get(pFilter("iToPeriod"),"")
	If (pMaxDT ? 1.4N1"-"1.2N1"-"1.2N1"T".E) {
		Set pMaxDate = $Piece(pMaxDT,"T",1)
		Set pMaxDateH = $ZDateH(pMaxDate,8)
		Set pMaxTime = $Piece(pMaxDT,"T",2)
		Set pFilter("pMaxDateH") = pMaxDateH
		Set pFilter("pMaxTime") = pMaxTime
	}
	Set pMinDT = $Get(pFilter("iFromPeriod"),"")
	If (pMinDT ? 1.4N1"-"1.2N1"-"1.2N1"T".E) {
		Set pMinDate = $Piece(pMinDT,"T",1)
		Set pMinDateH = $ZDateH(pMinDate,8)
		Set pMinTime = $Piece(pMinDT,"T",2)
		Set pFilter("pMinDateH") = pMinDateH
		Set pFilter("pMinTime") = pMinTime
	}
	Set tReturn = ""
	Set timeout = 2
	Try {
		Open pFile:("R"):timeout  // read
		If $test {
			Write:pDebug "Open",!
			Use pFile
			Set pos = $ZPOS
			Set pos = $ZSEEK(0,0)
			For {
				Set pos = $ZPOS
				Read tText
				Set:pDebug ^DEBUG($I(DEBUG))=$GET(tText)
				//If pImport Set tSC = ..ImportLine(tText,.objLog)
				Set tSC = ..ImportLine(tText,.objLog,.pFilter,pImport)  // ImportLines applies pFilter
				If $$$ISOK(tSC) Set pLines($I(pLines)) = tText
				If (pMaxLines < 0) { Continue }
				If (pLines >= pMaxLines) { Quit }
			}
			Close pFile
		}
	}
	Catch exception {
		If exception.%IsA("%Exception.SystemException") {
			Do BACK^%ETN // Log error in error log
		} Else {
			Throw exception // We will just throw these to outer error handler
		}
		Close pFile
	}
	//Use 0
	Quit $$$OK
}

ClassMethod TimesCompareIsBefore(pTime1 As %String = "", pTime2 As %String = "") As %Boolean
{
	Set x = (pTime2 ] pTime1)
	Quit x
}

}
