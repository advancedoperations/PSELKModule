#Hello World Log Out
Import-Module -Name .\PSELKModule.psm1 -Verbose

$object=New-Object -TypeName PSObject -Property @{
    Message = "This is some message data."
    OtherData = "Hello World!"
}

Write-ELKObject -payload $object
