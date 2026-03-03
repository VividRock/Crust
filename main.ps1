#--------------------------------------------------------------------------------------------
# Requirements
#--------------------------------------------------------------------------------------------
#Requires -RunAsAdministrator

#--------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------
# Parameters
#--------------------------------------------------------------------------------------------

[CmdletBinding()]
param (
  [Parameter(Mandatory=$true,
  HelpMessage="[TODO]")]
  [string]$Param
)

#--------------------------------------------------------------------------------------------
# Start-Transcript -Path ".\Logs\$(Get-Date -Format "yyyy-MM-dd_HHmmss")_Main.log" -ErrorAction SilentlyContinue
$Config_Initial = Get-Content -Path ".\configs\initial.json" -Raw | ConvertFrom-Json

#--------------------------------------------------------------------------------------------
# Header
#--------------------------------------------------------------------------------------------
#Region Header

  Write-Host "------------------------------------------------------------------------------"
  Write-Host "  $($Config_Initial.Application.Name)"
  Write-Host "------------------------------------------------------------------------------"
  foreach ($Item in ($Config_Initial.Application.PSObject.Properties | Where-Object -Property "Name" -ne "Name")) {
    Write-Host "    $($Item.Name.PadRight(($Config_Initial.Application.PSObject.Properties.Name | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)"
  }
  Write-Host "------------------------------------------------------------------------------"
  Write-Host ""

#EndRegion Header
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Variables
#   Error Range: 1200 - 1299
#--------------------------------------------------------------------------------------------
#Region Variables

  Write-Host "  Variables"

  # Parameters
    $Param_Configuration    = $Configuration

  # Metadata
    $Meta_Script_Start_DateTime     = Get-Date
    $Meta_Script_Complete_DateTime  = $null
    $Meta_Script_Complete_TimeSpan  = $null
    $Meta_Script_Execution_User     = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $Meta_Script_Result = $false,"Failure"

  # Preferences
    $ErrorActionPreference        = "Stop"
    $VerbosePreference            = "SilentlyContinue"
    $WarningPreference            = "SilentlyContinue"
    $ProgressPreference           = "Continue"

  # Names

  # Paths
    $Path_Temp          = "$($env:TEMP)\VividRock\ProductName"
    $Path_Datasets      = "$($env:TEMP)\VividRock\ProductName\Datasets"
    $Path_Logs          = "$($env:TEMP)\VividRock\ProductName\logs"
    $Path_Configs       = ".\configs"
    $Path_Modules       = ".\modules"


  # Files

  # Hashtables

  # Arrays

  # Registry

  # WMI

  # Datasets
    $Dataset_Snapshot_Pre   = $null
      # Stores the first snapshot information prior to an event or changes have occurred as the initial dataset for comparison
    $Dataset_Snapshot_Post  = $null
      # Stores the second snapshot information after an event or changes have occurred as the resultant dataset for comparison

  # Temporary

  # Output to Log
    Write-Host "    - Parameters"
    foreach ($Item in (Get-Variable -Name "Param_*")) {
      Write-Host "        $(($Item.Name) -replace 'Param_',''): $($Item.Value)"
    }
    Write-Host "    - Parameters"
    foreach ($Item in $PSBoundParameters.GetEnumerator()) {
      Write-Host "        $($Item.Key.PadRight(($PSBoundParameters.Keys | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)"
    }

    Write-Host "    - Paths"
    foreach ($Item in (Get-Variable -Name "Path_*")) {
      Write-Host "        $(($Item.Name) -replace 'Path_',''): $($Item.Value)"
    }
    Write-Host "    - Datasets"
    foreach ($Item in (Get-Variable -Name "Dataset_*")) {
      Write-Host "        $(($Item.Name) -replace 'Dataset_','')"
    }

  Write-Host "    - Complete"
  Write-Host ""

#EndRegion Variables
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Functions
#   Error Range: 1300 - 1399
#--------------------------------------------------------------------------------------------
#Region Functions

  Write-Host "  Functions"

  # Import Functions
    Write-Host "    - Import Functions"

    if (Test-Path -Path $Path_Modules) {
      foreach ($Item in (Get-ChildItem -Path $Path_Modules -Recurse -Filter "*.psm1")) {
        try {
          Write-Host "        $($Item.Name)"
          Write-Host "          Path: $($Item.FullName)"

          Import-Module $Item.FullName -Force
          Write-Host "          Status: Success"
        }
        catch {
          Throw "Error importing the Module file"
        }
      }
    }
    else {
      Throw "Invalid Module path"
    }

  Write-Host "    - Complete"
  Write-Host ""

#EndRegion Functions
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Environment
#   Error Range: 1400 - 1499
#--------------------------------------------------------------------------------------------
#Region Environment

  Write-Host "  Environment"

	# Import Configuration Files
    Write-Host "    - Import Configuration Files"

    if (Test-Path -Path $Path_Configs) {
      foreach ($Item in (Get-ChildItem -Path $Path_Configs -Recurse -Filter "*.json")) {
        try {
          Write-Host "        $($Item.Name)"
          Write-Host "          Path: $($Item.FullName)"

          Write-Host "          Name: $("Config_" + ($Item.Name -replace `".json`",`"`"))"
          if (Get-Variable -Name ("Config_" + ($Item.Name -replace ".json",""))) {
            Write-Host "          Status: Exists"
          }
          else {
            New-Variable -Name ("Config_" + ($Item.Name -replace ".json","")) -Value (Get-Content -Path $Item.FullName -Raw | ConvertFrom-Json)
            Write-Host "          Status: Success"
          }
        }
        catch {
          Throw "Error importing the Config file"
        }
      }
    }
    else {
      Write-vr_ErrorCode -Code 1401 -Exit $true -Object $PSItem
    }

	Write-Host "    - Complete"
	Write-Host ""

#EndRegion Environment
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Validation
#   Error Range: 1500 - 1599
#--------------------------------------------------------------------------------------------
#Region Validation

	Write-Host "  Validation"

  # Run As Administrator
    Write-Host "    - Run As Administrator"

    try {
      if ($Config_Initial.Settings.RunAsAdminRequired -eq $true) {
        if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
          Write-Host "        Status: Success"
        }
        else {
          Throw "You must execute this script in an Administrative context"
        }
      }
      else {
        Write-Host "        Status: Not Required"
      }

    }
    catch {
      Write-vr_ErrorCode -Code 1501 -Exit $true -Object $PSItem
    }

  # Paths
    Write-Host "    - Paths"

    foreach ($Item in (Get-Variable -Name "Path_*" | Where-Object -Property Name -NotMatch "Path_Imports")) {
      Write-Host "        $($Item.Name)"
      try {
        if (Test-Path -Path $Item.Value) {
          Write-Host "          Status: Exists"
        }
        else {
          New-RecursivePath -Path $Item.Value
          Write-Host "          Status: Created"
        }
      }
      catch {
        Write-vr_ErrorCode -Code 1502 -Exit $true -Object $PSItem
      }
    }

	Write-Host "    - Complete"
	Write-Host ""

#EndRegion Validation
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Data Gather
#   Error Range: 1600 - 1699
#--------------------------------------------------------------------------------------------
#Region Data Gather

	# Write-Host "  Data Gather"

	# # [StepName]
	# 	Write-Host "    - [StepName]"

	# 	try {

	# 		Write-Host "        Status: Success"
	# 	}
	# 	catch {
	# 		Write-vr_ErrorCode -Code 1601 -Exit $true -Object $PSItem
	# 	}

	# # [StepName]
	# 	foreach ($Item in (Get-Variable -Name "Path_*")) {
	# 		Write-Host "    - $($Item.Name)"

	# 		try {

	# 			Write-Host "        Status: Success"
	# 		}
	# 		catch {
	# 			Write-vr_ErrorCode -Code 1602 -Exit $true -Object $PSItem
	# 		}
	# 	}

	# Write-Host "    - Complete"
	# Write-Host ""

#EndRegion Data Gather
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Execution
#   Error Range: 1700 - 1799
#--------------------------------------------------------------------------------------------
#Region Execution

  Write-Host "  Execution"

	# # [StepName]
	# 	Write-Host "    - [StepName]"

	# 	try {

	# 		Write-Host "        Status: Success"
	# 	}
	# 	catch {
	# 		Write-vr_ErrorCode -Code 17XX -Exit $true -Object $PSItem
	# 	}

	# # [StepName]
  #   Write-Host "    - [StepName]"

  #   foreach ($Item in (Get-Variable -Name "Path_*")) {
	# 		Write-Host "        $($Item.Name)"

	# 		try {

	# 			Write-Host "          Status: Success"
	# 		}
	# 		catch {
	# 			Write-vr_ErrorCode -Code 17XX -Exit $true -Object $PSItem
	# 		}
	# 	}

	# Determine Script Result
		$Meta_Script_Result = $true,"Success"

	Write-Host "    - Complete"
	Write-Host ""

#EndRegion Execution
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Output
#   Error Range: 1800 - 1899
#--------------------------------------------------------------------------------------------
#Region Output

	Write-Host "  Output"

	# Write Datasets to Files
		Write-Host "    - Write Datasets to Files"
    foreach ($Item in (Get-Variable -Name "Dataset_*")) {
      try {
        Write-Host "        $($Item.Name)"
        Write-Verbose "          Path: $($Path_Temp)\Datasets\$($Item.Name).json"
        $Item.Value | ConvertTo-Json | Out-File -FilePath "$($Path_Temp)\Datasets\$($Item.Name).json"
        Write-Host "          Status: Success"
      }
      catch {
        Write-vr_ErrorCode -Code 1801 -Exit $true -Object $PSItem
      }
    }

	# # [StepName]
	# 	Write-Host "    - [StepName]"

	# 	try {

	# 		Write-Host "        Status: Success"
	# 	}
	# 	catch {
	# 		Write-vr_ErrorCode -Code 1801 -Exit $true -Object $PSItem
	# 	}

	Write-Host "    - Complete"
	Write-Host ""

#EndRegion Output
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Cleanup
#   Error Range: 1900 - 1999
#--------------------------------------------------------------------------------------------
#Region Cleanup

	# Write-Host "  Cleanup"

	# # # Confirm Cleanup
	# # 	Write-Host "    - Confirm Cleanup"

	# # 	do {
	# # 		$Input_Cleanup_Confirmation = Read-Host -Prompt "        Do you want to automatically clean up the unecessary content from this script? [Y]es or [N]o"
	# # 	} until (
	# # 		$Input_Cleanup_Confirmation -in "Y","Yes","N","No"
	# # 	)

  # $Input_Cleanup_Confirmation = "Yes"

  # # Destroy Credential Objects
	# 	Write-Host "    - Destroy Credential Objects"

	# 	try {
	# 		if ($Input_Cleanup_Confirmation -in "Y", "Yes") {
  #       foreach ($Item in $Dataset_Input_Configuration.HyperV.VirtualMachines) {
  #         Write-Host "        $($Item.Name)"

  #         Write-Host "        Status: Success"
  #       }
	# 		}
	# 		else {
	# 			Write-Host "            Status: Skipped"
	# 		}
	# 	}
	# 	catch {
	# 		Write-vr_ErrorCode -Code 1901 -Exit $true -Object $PSItem
	# 	}

	# Write-Host "    - Complete"
	# Write-Host ""

#EndRegion Cleanup
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Footer
#--------------------------------------------------------------------------------------------
#Region Footer

	# Gather Data
		$Meta_Script_Complete_DateTime  = Get-Date
		$Meta_Script_Complete_TimeSpan  = New-TimeSpan -Start $Meta_Script_Start_DateTime -End $Meta_Script_Complete_DateTime

	# Output
		Write-Host ""
		Write-Host "------------------------------------------------------------------------------"
		Write-Host "  Script Result: $($Meta_Script_Result[1])"
		Write-Host "  Script Started: $($Meta_Script_Start_DateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)"
		Write-Host "  Script Completed: $($Meta_Script_Complete_DateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)"
		Write-Host "  Total Time: $($Meta_Script_Complete_TimeSpan.Days) days, $($Meta_Script_Complete_TimeSpan.Hours) hours, $($Meta_Script_Complete_TimeSpan.Minutes) minutes, $($Meta_Script_Complete_TimeSpan.Seconds) seconds, $($Meta_Script_Complete_TimeSpan.Milliseconds) milliseconds"
		Write-Host "------------------------------------------------------------------------------"
		Write-Host "  End of Script"
		Write-Host "------------------------------------------------------------------------------"

#EndRegion Footer
#--------------------------------------------------------------------------------------------

Stop-Transcript
Return $Meta_Script_Result[0]