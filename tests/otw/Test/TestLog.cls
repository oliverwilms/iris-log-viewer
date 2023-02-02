Class otw.Test.TestLog Extends %UnitTest.TestCase
{

ClassMethod Go() As %Status
{
	//Set ^UnitTestRoot="/opt/unittests"
	Set tSC = ##class(%UnitTest.Manager).RunTest("test-log","/loadudl")
	Quit tSC
}

ClassMethod StartDev(ByRef pDev) As %Status
{
	Set tDateTime = $ZDateTime($NOW(),8,1,3)
	Set tDT = $Translate(tDateTime,".:","_")
	Set tPath = "/home/irisowner/irisdev/tests/"
	// irisowner does not have write permission in tests
	Set tPath = "/home/irisowner/irisdev/"
	If (0 = ##class(%File).Exists(tPath)) {
		Set tSC = ##class(%File).CreateDirectory(tPath)
	}
	Set d = "_"
	Set tFilename = "Test_Log"_d_tDT
	Set pDev = tPath_tFilename
	Set timeout = 1
	Open pDev:("NRW"):timeout
	Else  Write "cannot Open",!
	//Use pDev
	Quit $$$OK
}

ClassMethod StopDev(ByRef pDev) As %Status
{
	Close pDev
	//Use 0
	Quit $$$OK
}

Method TestAlerts()
{
	Do ..StartDev(.dev)
	Set pMinDT = ""
	Set pMaxDT = ""
	Set pMinLevel = 0
	Set pMaxLevel = 0
	Set pFile = ""
	Set pImport = 1
	Set pMaxLines = 15
	Set pFilter("pMaxLines") = pMaxLines
	Set tSC = ##class(otw.log.Log).ImportMessages(pFile,.pLines,.pFilter,pImport)
	Do ..LogMessage("Imported "_pLines_" messages.")
	Use dev
	Set tSC = ##class(otw.log.Log).OutputTableData()
	Use 0
	Do $$$AssertEquals(pLines,(pMaxLines),"imported lines count")
	Do ..StopDev(.dev)
}

Method TestMessages()
{
	Do ..StartDev(.dev)
	Set pMinDT = ""
	Set pMaxDT = ""
	Set pMinLevel = 0
	Set pMaxLevel = 0
	Set pFile = ""
	Set pImport = 1
	Set pMaxLines = 15
	Set pFilter("pMaxLines") = pMaxLines
	Set tSC = ##class(otw.log.Log).ImportMessages(pFile,.pLines,.pFilter,pImport)
	Do ..LogMessage("Imported "_pLines_" messages.")
	Use dev
	Set tSC = ##class(otw.log.Log).OutputTableData()
	Use 0
	Do $$$AssertEquals(pLines,(pMaxLines),"imported lines count")
	Do ..StopDev(.dev)
}

}
