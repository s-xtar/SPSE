function Scan-Dir
{
<#

.SYNOPSIS
A poweshell script that enumerate directories inside folders which are writable by non-admin users.
.DESCRIPTION
A poweshell script that enumerate directories inside folders which are writable by non-admin users and print it out for the user.

 
.PARAMTER path
Path of folder you want to check. Default is c:\system32\


.EXAMPLE
PS C:\> . .\Scan-Dir.ps1
PS C:\> Scan-Dir
PS C:\> Scan-Dir -path c:\users\public\

.LINK
https://stackoverflow.com/questions/22943289/powershell-what-is-the-best-way-to-check-whether-the-current-user-has-permissio

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
" http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
Student ID: PSP - 3224
#>


[CmdletBinding()] Param( 

        [Parameter(Mandatory = $false, ValueFromPipeline=$true)]
		[String]
		$path = 'C:\Windows\System32\'

	    )

    
    $file = $path + "\test.txt"
    $checkdir = Get-ChildItem $path -Directory
    Write-Host "[*] Checking $path writable directories:" -foregroundColor Yellow
    Try
        {
        #Scaning all folders inside $path
        foreach ($dir in $checkdir)
        {
            #Attempting to open the file for write access, then immediately close it (without actually writing anything to the file)
            [io.file]::OpenWrite($file).close()
            Write-Host "[+] You have write permission in: $dir" -foregroundColor Green
            #Deleting the file
            [io.file]::Delete($file)
            }
        }
    Catch
        {
        Write-Host "[-] None of the folders have write permission" -foregroundColor Red
        }
}