function Write-ELKOutput ()
{
    param(
        [Parameter(Mandatory=$True)]
        [string]$Message,
        #0=EMERG 1=Alert 2=CRIT 3=ERR 4=WARNING 5=NOTICE  6=INFO  7=DEBUG
        [string]$Severity = '5',
        #(16-23)=LOCAL0-LOCAL7
        [string]$Facility = '22'
    )
    #Hello World
    $NetClient=$null

    if($global:elkConfig.Protocol -eq "UDP")
    {
        $NetClient = New-Object System.Net.Sockets.UdpClient
        $NetClient.Connect($global:elkConfig.ElkServer, $global:elkConfig.SyslogPort)
    }
    else 
    {
        $NetClient = New-Object System.Net.Sockets.TcpClient
        $NetClient.Connect($global:elkConfig.ElkServer, $global:elkConfig.SyslogPort)
    }
    # Calculate the priority
    $Priority = ([int]$Facility * 8) + [int]$Severity
    $Hostname = $env:COMPUTERNAME
    #Time format the SW syslog understands
    $Timestamp = Get-Date -Format "MMM dd HH:mm:ss"
    # Assemble the full syslog formatted message
    $FullSyslogMessage = "<{0}>{1} {2} {3}" -f $Priority, $Timestamp, $Hostname, $Message
    # create an ASCII Encoding object
    $Encoding = [System.Text.Encoding]::ASCII
    # Convert into byte array representation
    $ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage)
    # Send the Message
    $NetClient.Send($ByteSyslogMessage, $ByteSyslogMessage.Length)
    $NetClient.Close()
}

function Write-ELKHttp ()
{
    param(
        [Parameter(Mandatory=$True)]
        [PSObject]$Payload
    )

    Add-Member -InputObject $payload -NotePropertyName ELKModuleVersion -NotePropertyValue $global:elkModuleVersion
    Add-Member -InputObject $payload -NotePropertyName PSTimestamp -NotePropertyValue "$(Get-Date -Format "dd-MM-yy HH:mm:ss.fff")"
    Add-Member -InputObject $payload -NotePropertyName Hostname -NotePropertyValue "$($env:computername)"
    Add-Member -InputObject $payload -NotePropertyName Source -NotePropertyValue "PSLogOutput"
    if($scriptName)
    {
        Add-Member -InputObject $payload -NotePropertyName ScriptName -NotePropertyValue $scriptName
    }
    else {
        Add-Member -InputObject $payload -NotePropertyName ScriptName -NotePropertyValue "UnNamedScript"
    }
    if($instanceId)
    {
        Add-Member -InputObject $payload -NotePropertyName Instance -NotePropertyValue $instanceId
    }
    else {
        Add-Member -InputObject $payload -NotePropertyName Instance -NotePropertyValue "NoGuid"
    }
    
    $jsonPayload=$payload | ConvertTo-Json -Depth 3
    Invoke-WebRequest -Method Put -Body $jsonPayload -Uri "http://$($global:elkConfig.elkserver):$($global:elkConfig.JSONPort)/"

}

function Write-ElkMessage ()
{
    param(
        [Parameter(Mandatory=$True)]
        [string]$Message,
        [bool]$Return, #If set true this will also return the message string back to the caller eg a variable for local or email logs
        [bool]$StdOut #If set true will also write the message string to the environemnt output stream
    )

    $object=new-object -TypeName psobject -Property @{
        Message = $Message
    }
    if($StdOut)
    {
        Write-Output $Message
    }

    Write-ELKHttp $object | Out-Null

    if($Return)
    {
        return $Message
    }
}

function Format-ElkDate()
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline)]
        [datetime]$DateToFormat
    )
    return $DateToFormat.ToString("dd-MM-yy HH:mm:ss.fff")
}

$global:elkConfig=Get-Content ./ElkConfig.json -Raw | ConvertFrom-Json
$global:elkModuleVersion="0.4"

Export-ModuleMember -Function "Write-*"
Export-ModuleMember -Function "Get-*"
Export-ModuleMember -Function "Format-*"
Export-ModuleMember -Variable 'global:elkConfig'