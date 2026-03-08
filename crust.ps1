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

# Initialize Application
Import-Module -Name ".\modules\crust.psm1" -Force
Initialize-Crust
Set-Tokens

# Initialize Interface
Clear-Interface
Initialize-Interface
Write-Interface -Message $Language.Security.Authentication.SectionTitle -IndentLevel 1
Write-Interface -Message $Interface.LineBreak -IndentLevel 0

#EndRegion Initialize
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Get Credential Object: AtStartup
#--------------------------------------------------------------------------------------------
#Region Get Credential Object: AtStartup
Out-File -InputObject "  Get Credential Object: AtStartup" @Params_Logging

if (($Crust.Security.Authentication.Enabled -eq $true) -and ($Crust.Security.Authentication.LaunchPoint -eq "AtStartup")) {
  do {
    $Crust_Credential = Get-UserCredential -LaunchPoint $Crust.Security.Authentication.LaunchPoint  -Validate

    # Process Retun
    if ($Crust_Credential -eq $false) {
      Write-Interface -Message $Language.Security.Authentication.FailedAuthentication -IndentLevel 3
    }
  } until (
    ($Crust_Credential -ne $false) -or ($Crust_Credential -eq "UserCancelled")
  )
}
elseif ($Crust.Security.Authentication.Enabled -eq $false) {
  Out-File -InputObject "    - Skipped: Authentication not enabled in the crust.json config file " @Params_Logging
}
else {
  Out-File -InputObject "    - Skipped: Authentication LaunchPoint not configured for AtStartup in the crust.json config file" @Params_Logging
}

Out-File -InputObject "    - Complete" @Params_Logging
Out-File -InputObject " " @Params_Logging

#EndRegion Get Credential Object: AtStartup
#--------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------
# Show Main Menu
#--------------------------------------------------------------------------------------------
#Region Show Main Menu

Out-File -InputObject "  Show Main Menu" @Params_Logging

# Show Menu
if ($Crust_Credential -eq "UserCancelled") {
  <# Action to perform if the condition is true #>
}
elseif ((($Crust.Security.Authentication.Enabled -eq $true) -and ($Crust_Credential)) -or ($Crust.Security.Authentication.Enabled -eq $false)) {
  $Menu = Get-InterfaceMenu -File $File
  while ($Name -ne "Quit") {
    $Name = Show-InterfaceMenu -Menu ($Menu | Where-Object -Property "Name" -eq $Name) -Name $Name
  }
}
else {
  # Do Nothing
}

Out-File -InputObject "    - Complete" @Params_Logging
Out-File -InputObject " " @Params_Logging

#EndRegion Show Main Menu
#--------------------------------------------------------------------------------------------

Write-CrustLog -Footer

Return $Crust.Metadata.ScriptResultCode