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

    Add-Member -InputObject $payload -NotePropertyName PSTimestamp -NotePropertyValue "$(Get-Date -Format "dd-MM-yy HH:mm:ss.fff")"
    Add-Member -InputObject $payload -NotePropertyName Hostname -NotePropertyValue "$($env:computername)"
    Add-Member -InputObject $payload -NotePropertyName Source -NotePropertyValue "PSLogOutput"
    $jsonPayload=$payload | ConvertTo-Json -Depth 3
    Invoke-WebRequest -Method Put -Body $jsonPayload -Uri "http://$($global:elkConfig.elkserver):$($global:elkConfig.JSONPort)/"

}

function Write-ElkMessage ()
{
    param(
        [Parameter(Mandatory=$True)]
        [string]$Message
    )

    $object=new-object -TypeName psobject -Property @{
        Message = $Message
    }

    Write-ELKHttp $object
}

$global:elkConfig=Get-Content ./ElkConfig.json -Raw | ConvertFrom-Json

Export-ModuleMember -Function "Write-*"
Export-ModuleMember -Variable 'global:elkConfig'