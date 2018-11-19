function Transfer-Files
{

<#

.SYNOPSIS
A PowerShell script that trasfer a files over PowerShell Remoting

.DESCRIPTION
A PowerShell script that trasfer a files over PowerShell Remoting

.PARAMETER LocalFilePath
Local file to transfer

.PARAMETER Target
The remote computer IP or Hostname.

.PARAMETER RemotefilePath
Path for the file you want to transfer on target machine.


.EXAMPLE
PS C:\> . .\Transfer-Files.ps1
PS C:\> TransferPsRemoting -Localfile .\file.txt -Remotefile "c:\users\admin\desktops\file.txt" -Target 192.168.1.111

.LINK
https://social.technet.microsoft.com/Forums/windows/en-US/17960e2b-bd47-44fd-b25e-c5092940bf40/how-to-pass-a-param-to-script-block-when-using-invokecommand?forum=winserverpowershell
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-6

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
" http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
Student ID: PSP - 3224


#>


[CmdletBinding()] Param( 

		[Parameter(Mandatory = $true)]
		[String]
		$LocalFilePath,

		[Parameter(Mandatory = $true)]
		[String]
		$RemotefilePath,

		[Parameter(Mandatory = $true)]
		[String]
		$Target
		
)

# creating a credential object to hide prompting the user.
$Username = "vmlab\admin"  
$Password = "P@ssw0rd"  
$Secstr = ConvertTo-SecureString $password -AsPlainText -Force  
$Pscreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $secstr  

#creating new session.
$Session = New-PSSession -ComputerName $Target -Credential $Pscreds
$Content = Get-Content $LocalFilePath

try {
    $Transfer = invoke-command -session $Session -script {param($Contents,$Filepath) $Contents | Out-File "$Filepath"} -argumentlist $Content,$RemotefilePath
    Write-Host "`n[+] File transferred successfully`n" -ForegroundColor Green
    }

catch {
    Write-Host "`n[-] Something Went Wrong`n" -ForegroundColor Red
}
}