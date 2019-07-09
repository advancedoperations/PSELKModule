#region Script Header

#region Import Modules
Import-Module ./PSELKModule.psm1 -Verbose
#endregion

#endregion

#region Script Body

#region Global variables

# Adjust the below as necessary for your script - Make sure you enter a descriptive script name
$global:scriptName="PSElkTemplateScript"

# Not implemented yet - placeholder
$global:localLogFile=""

# Instance ID - Don't change this
$global:instanceId=New-Guid

#endregion

#region Record script start time
$scriptStart = Get-Date
Write-ElkMessage "Script started"
#endregion

#// Your Code Goes Here...

#region Delete this region or use as examples
Start-Sleep -Seconds 10
$someVariable=@("Hello World","This is just a sample array","Delete this")


# Example object
$outputObject= New-Object -TypeName psobject -Property @{
    Data = "Here is some data."
    DataFromVariable = $someVariable
}

#endregion

#region Output data - Update the below with your script final output object if you want to log it to ELK

Write-ELKHttp -Payload $outputObject

#endregion

#// End of your code

#endregion

#region Script footer

#region Record Script End Time
$scriptEnd = Get-Date
Write-ElkMessage "Script Finished - Elapsed: $(($scriptEnd-$scriptStart).TotalSeconds) seconds"
#endregion

#endregion