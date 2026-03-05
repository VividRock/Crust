#--------------------------------------------------------------------------------------------
# Parameters
#--------------------------------------------------------------------------------------------
#Region Parameters

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Default")]
param(
  [Parameter(Mandatory = $false,
    HelpMessage = "Specify the name of a menu json file.",
    ParameterSetName = "Default")]
  [string]$File = "menu.json",
  [Parameter(Mandatory = $false,
    HelpMessage = "Specify the name of a menu in the json file to load with Crust.",
    ParameterSetName = "Default")]
  [string]$Name = "Main",
  [Parameter(Mandatory = $false,
    HelpMessage = "Specify an explicit language code if you want to override the user's preferred language.",
    ParameterSetName = "Language")]
    [ValidatePattern("[a-z]{2}-[A-Z]{2}")]
  [string]$UICulture = $($PSUICulture)
)

#EndRegion Parameters
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Initialize
#--------------------------------------------------------------------------------------------
#Region Initialize

Import-Module -Name ".\modules\crust.psm1" -Force
Initialize-Crust
Set-Tokens

#EndRegion Initialize
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Show Main Menu
#--------------------------------------------------------------------------------------------
#Region Show Main Menu

Out-File -InputObject "  Show Main Menu" @Params_Logging

Clear-Interface
$Menu = Get-InterfaceMenu -File $File
while ($Name -ne "Quit") {
  $Name = Show-InterfaceMenu -Menu ($Menu | Where-Object -Property "Name" -eq $Name) -Name $Name
}

Out-File -InputObject "    - Complete" @Params_Logging
Out-File -InputObject " " @Params_Logging

#EndRegion Show Main Menu
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Footer
#--------------------------------------------------------------------------------------------
#Region Footer

# Gather Data
$Crust.Metadata.ScriptResult = "Success"
$Crust.Metadata.ScriptResultCode = 0
$Crust.Metadata.CompleteDateTime = Get-Date
$Crust.Metadata.CompleteTimeSpan = New-TimeSpan -Start $Crust.Metadata.StartDateTime -End $Crust.Metadata.CompleteDateTime

# Output
Out-File -InputObject " " @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
Out-File -InputObject "  Script Result: $($Crust.Metadata.ScriptResult)" @Params_Logging
Out-File -InputObject "  Script Started: $($Crust.Metadata.StartDateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)" @Params_Logging
Out-File -InputObject "  Script Completed: $($Crust.Metadata.CompleteDateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)" @Params_Logging
Out-File -InputObject "  Total Time: $($Crust.Metadata.CompleteTimeSpan.Days) days, $($Crust.Metadata.CompleteTimeSpan.Hours) hours, $($Crust.Metadata.CompleteTimeSpan.Minutes) minutes, $($Crust.Metadata.CompleteTimeSpan.Seconds) seconds, $($Crust.Metadata.CompleteTimeSpan.Milliseconds) milliseconds" @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
Out-File -InputObject "  End of Script" @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging

#EndRegion Footer
#--------------------------------------------------------------------------------------------

Return $Crust.Metadata.ScriptResultCode