function Scan-OpenShares
{
<#

.SYNOPSIS
A poweshell script that Enumerate all open shares in a network
.DESCRIPTION
A poweshell script that Enumerate all open shares in a network and mark shares with read and write access seprately

 
.PARAMTER IPlist
List of ips to scan for open shares


.EXAMPLE
PS C:\> . .\Scan-OpenShares.ps1
PS C:\> Scan-OpenShares
PS C:\> Scan-OpenShares -IPlist .\iplist.txt

.LINK
https://gallery.technet.microsoft.com/scriptcenter/a231026a-3fdb-4190-9915-38d8cd827348

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
" http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
Student ID: PSP - 3224
#>

    param(
    [parameter(Mandatory = $true)]
    [string]
    $IPlist
    )


    $IPs = Get-Content $IPlist
    $ErrorActionPreference = 'SilentlyContinue'
    foreach ($target in $IPs)
    {
            try{
                #Listing all open shares including ADMIN$ C$ IPC$
                $Allshares = get-WmiObject -class Win32_Share -ComputerName $target
                if ($Allshares){ Write-Host "[+] Open Shares of $target :" -ForegroundColor Cyan }
                foreach ($Share in $Allshares.name)
                {
                    Write-Host "-> $Share" -ForegroundColor Cyan
                }

                #listing shares and permission
                $sharesec = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -ComputerName $Target -ea stop
                $sharereport = @() 
                #Credit for the foreach loop to "https://gallery.technet.microsoft.com/scriptcenter/a231026a-3fdb-4190-9915-38d8cd827348"
                ForEach ($Shares in $sharesec) { 
                    try{
                            #Try to get the security descriptor 
                            $SecurityDescriptor = $ShareS.GetSecurityDescriptor() 
                            #Iterate through each descriptor 
                            ForEach ($DACL in $SecurityDescriptor.Descriptor.DACL) { 
                                $arrshare = New-Object PSObject 
                                $arrshare | Add-Member NoteProperty ShareName $Shares.Name 
                                $arrshare | Add-Member NoteProperty "  Group  " $DACL.Trustee.Name 
                                #Convert the current output into something more readable 
                                Switch ($DACL.AccessMask) { 
                                    2032127 {$AccessMask = "FullControl"} 
                                    1179785 {$AccessMask = "Read"} 
                                    1180063 {$AccessMask = "Read, Write"} 
                                    1179817 {$AccessMask = "ReadAndExecute"} 
                                    -1610612736 {$AccessMask = "ReadAndExecuteExtended"} 
                                    1245631 {$AccessMask = "ReadAndExecute, Modify, Write"} 
                                    1180095 {$AccessMask = "ReadAndExecute, Write"} 
                                    268435456 {$AccessMask = "FullControl (Sub Only)"} 
                                    default {$AccessMask = $DACL.AccessMask} 
                                    } 
                                $arrshare | Add-Member NoteProperty AccessMask $AccessMask 
                                #Convert the current output into something more readable 
                                Switch ($DACL.AceType) { 
                                    0 {$AceType = "Allow"} 
                                    1 {$AceType = "Deny"} 
                                    2 {$AceType = "Audit"} 
                                    } 
                                #$arrshare | Add-Member NoteProperty AceType $AceType 
                                #Add to existing array 
                                $sharereport += $arrshare 
                               }
                          }
                          catch
                          { 
                             Write-host "unable To list $Shares"  -ForegroundColor red
                          }
                }
                    # Marking the output 
                    $full = $sharereport | Where-Object {$_.AccessMask -eq "FullControl"} | Out-String
                    if ($full) {
                    Write-Host "`n##### Full control #####" -ForegroundColor Magenta
                    Write-Host "$full" -ForegroundColor Green
                    }

                    $rw = $sharereport | Where-Object {$_.AccessMask -eq "Read, Write"} | Out-String
                    if ($rw) {
                    Write-Host "`n##### Read, Write #####" -ForegroundColor Magenta
                    Write-Host "$rw" -ForegroundColor Green
                    }

                    $re = $sharereport | Where-Object {$_.AccessMask -eq "ReadAndExecute"} | Out-String
                    if ($re) {
                    Write-Host "`n##### Read And Execute #####" -ForegroundColor Magenta
                    Write-Host "$re" -ForegroundColor Green
                    }

                    $other = $sharereport | Where-Object {$_.AccessMask -ne "FullControl" -and $_.AccessMask -ne "ReadAndExecute" -and $_.AccessMask -ne "Read, Write"} | Out-String
                    if ($other) {
                    Write-Host "`n##### Others #####" -ForegroundColor Magenta
                    Write-Host "$other" -ForegroundColor Green
                    }
           
           
     }
     catch{
      Write-host "[-] unable To connect to $target"  -ForegroundColor red
      }
    }
}