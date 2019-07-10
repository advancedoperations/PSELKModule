# PSELKModule
A PS Module to log to ELK stack server

Basic Usage:

Place the PSELKModule.psm1 and accompanying ElkConfig JSON file in the working directory
in which the script will run.
The JSON Config should be fairly easy to understand however:
    - ELKServer: IP or DNS name of ELK server
    - Protocol: TCP/UDP (Deprecated and used by the Write-ElkOutput function for syslogging)
    - SyslogPort: Port number used for syslog type messages
    - JSONPort: Port used for sending Object data in JSON format over HTTP.

Use Import-Module PSELKModule.psm1 to invoke the functions and set the required global variables

The included PSElkTemplateScript provides a wrapper to allow implementation of basic script logging.
       

0.4 - Added Write-ElkMessage 
    - Usage: Write-ElkMessage "<string>"
    - This function allows the sending of a single string this will be packaged into a 
      valid JSON object and will use Write-ELKHttp to send to the configured ELK server

0.3 - Added Write-ELKHttp function. Others now deprecated.
    - Usage: Write-ELKHttp -Payload [PSObject]
    - This function 

0.2 - JSON objecct to ELK

0.1 - Simple Syslog streamer to ELK (untested)
