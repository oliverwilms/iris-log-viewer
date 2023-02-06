Class otw.log.EmbeddedPython
{

ClassMethod Hello() [ Language = python ]
{
    print ('\nHello ' + 'self.Name')
}

ClassMethod HelloWorld() As %Status
{
  Set sc = $$$OK
  Set b = ##class(%SYS.Python).Import("builtins")
  Do b.print("Hello world")
  Return sc
}

ClassMethod ReadFile() As %String
{
  Set maxq = ""
  Try {
    Set td = ##class(%SYS.Python).Import("iris-log-viewer")
    Set file = $System.Util.ManagerDirectory()_"messages.log"
    Set maxq = td.fileread(file)
  }
  Catch exp {
    IF 1=exp.%IsA("%Exception.SystemException") {
      WRITE "System exception",!
      WRITE "Name: ",$ZCVT(exp.Name,"O","HTML"),!
      WRITE "Location: ",exp.Location,!
      WRITE "Code: "
    }
    ELSEIF 1=exp.%IsA("%Exception.SQL") {
      WRITE "SQL exception",!
      WRITE "SQLCODE: "
    }
    ELSEIF 1=exp.%IsA("%Exception.StatusException") {
      WRITE "%Status exception",!
      DO $SYSTEM.Status.DisplayError(exp.AsStatus())
    }
    ELSEIF 1=exp.%IsA("%Exception.General") {
      WRITE "General ObjectScript exception",!
      WRITE "Name: ",$ZCVT(exp.Name,"O","HTML"),!
      WRITE "Code: "
    }
    ELSE { WRITE "Some other type of exception",! }
    WRITE exp.Code,!
    WRITE "Data: ",exp.Data,!     
  }
  Return maxq
}

ClassMethod ReadFileUsingPython(pFile As %String) [ Language = python ]
{
  from datetime import datetime
  import iris
  time1 = datetime.timestamp(datetime.now())
  print(time1)
  if pFile=="":
    raise Exception("filename is required.")

  with open(pFile,"r", encoding="utf-8", errors="ignore") as file:
    log = iris.cls('otw.log.Log')
    for line in file:
      status = log.ImportLine(line)

  time2 = datetime.timestamp(datetime.now())
  print(time2)
  print("Execution time: ",(time2-time1))
}

ClassMethod Today() As %Status
{
  Set sc = $$$OK
  Set dt = ##class(%SYS.Python).Import("datetime")
  Write dt.date.today().isoformat()
  Return sc
}

ClassMethod Write(pName As %String = "otw", pTaxID As %String = 123) [ Language = objectscript ]
{
    write !, "Name: ", pName, " TaxID: ", pTaxID
}

}
