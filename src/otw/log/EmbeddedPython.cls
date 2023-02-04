Class otw.log.EmbeddedPython
{

/*
ClassMethod Print() [ Language = python ]
{
    print ('\nName: ' + self.Name + ' TaxID: ' + self.TaxID)
}
*/
ClassMethod Write(
	pName As %String = "otw",
	pTaxID As %String = 123) [ Language = objectscript ]
{
    write !, "Name: ", pName, " TaxID: ", pTaxID
}

}
