Class otw.log.irislogreader
{

ClassMethod Test1(
	pFile As %String,
	ByRef pLines,
	ByRef pFilter = -1,
	pImport,
	pDebug = 1) As %String
{
	Set time1 = $ZHOROLOG  // $ZHOROLOG contains the number of seconds elapsed since the most recent IRIS startup.
	If pDebug {
		Write "Test1 begins at ",$ZDATETIME($HOROLOG),!
	}
	Set tSC = $$$OK
	If ($Get(pImport) = "") {
		Set pImportDeleteExtent = 4
		Set pImportAlerts = 2
		Set pImport = pImportDeleteExtent + 1  // NOT Alerts
	}
	If (pImport > 2) {
		Set tSC = ##class(Log).%DeleteExtent()
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
	Set tSC = ##class(Log).ReadLogLines(pFile,.pLines,.pFilter,pImport,pDebug)
	If pDebug {
		Write "Test1 ends at ",$ZDATETIME($HOROLOG),!
	}
	Set time2 = $ZHOROLOG
	Set diff = time2 - time1
	Write "Test1 execution time: "_diff, !
	Quit ""
}

}
