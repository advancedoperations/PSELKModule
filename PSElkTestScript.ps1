#Hello World Log Out
Import-Module -Name .\PSELKModule.psm1 -Verbose

$object=New-Object -TypeName PSObject -Property @{
    Message = "This is a test log message"
    Title = "Hello World!"
    ArrayData=@("Red","Green","Blue")
}

Write-ELKHttp -payload $object
