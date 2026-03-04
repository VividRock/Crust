#--------------------------------------------------------------------------------------------
# Parameters
#--------------------------------------------------------------------------------------------
#Region Parameters

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Default")]
param(
  [Parameter(Mandatory = $false,
    HelpMessage = "Specify an explicit language code if you want to override the user's preferred language.",
    ParameterSetName = "Language")]
    [ValidatePattern("[a-z]{2}-[A-Z]{2}")]
  [string]$Language = $($PSUICulture)
)

#EndRegion Parameters
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Initialize
#--------------------------------------------------------------------------------------------
#Region Initialize

Import-Module -Name ".\modules\initialize.psm1" -Force

#EndRegion Initialize
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Show Main Menu
#--------------------------------------------------------------------------------------------
#Region Show Main Menu

Out-File -InputObject "  Show Main Menu" @Params_Logging

$Menu_Choice = "Main"
Clear-Interface
while ($Menu_Choice -ne "Quit") {
  $Menu_Choice = Show-InterfaceMenu -MenuName $Menu_Choice
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
$Config_initialize.Metadata.ScriptResult = "Success"
$Config_initialize.Metadata.ScriptResultCode = 0
$Config_initialize.Metadata.CompleteDateTime = Get-Date
$Config_initialize.Metadata.CompleteTimeSpan = New-TimeSpan -Start $Config_initialize.Metadata.StartDateTime -End $Config_initialize.Metadata.CompleteDateTime

# Output
Out-File -InputObject " " @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
Out-File -InputObject "  Script Result: $($Config_initialize.Metadata.ScriptResult)" @Params_Logging
Out-File -InputObject "  Script Started: $($Config_initialize.Metadata.StartDateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)" @Params_Logging
Out-File -InputObject "  Script Completed: $($Config_initialize.Metadata.CompleteDateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)" @Params_Logging
Out-File -InputObject "  Total Time: $($Config_initialize.Metadata.CompleteTimeSpan.Days) days, $($Config_initialize.Metadata.CompleteTimeSpan.Hours) hours, $($Config_initialize.Metadata.CompleteTimeSpan.Minutes) minutes, $($Config_initialize.Metadata.CompleteTimeSpan.Seconds) seconds, $($Config_initialize.Metadata.CompleteTimeSpan.Milliseconds) milliseconds" @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
Out-File -InputObject "  End of Script" @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging

#EndRegion Footer
#--------------------------------------------------------------------------------------------

Return $Config_initialize.Metadata.ScriptResultCode