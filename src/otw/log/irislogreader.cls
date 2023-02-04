Class otw.log.irislogreader
{

ClassMethod Test1(
	pFile As %String,
	ByRef pLines,
	ByRef pFilter = -1,
	pImport,
	pDebug = 1) As %String
{
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
		Write "Import Messages ends at ",$ZDATETIME($HOROLOG),!
	}
	Quit ""
}

}
