# Configs
New-Variable -Name "Config_initialize" -Value (Get-Content -Path ".\configs\crust.json" -Raw | ConvertFrom-Json) -Scope Global -Force

# Metadata
$Global:Config_initialize.Metadata.StartDateTime = (Get-Date)
$Config_initialize.Metadata.CompleteDateTime = $null
$Config_initialize.Metadata.CompleteTimeSpan = $null
$Config_initialize.Metadata.ExecutionUser = $([System.Security.Principal.WindowsIdentity]::GetCurrent())

# Preferences
$ErrorActionPreference = "Stop"
foreach ($Item in $Config_initialize.Preferences.PSObject.Properties) {
  Set-Variable -Name $Item.Name -Value $Item.Value -Scope Global -Force
}

# Logging
$Global:Params_Logging = @{
  FilePath = "Filesystem::$($Config_initialize.Logging.Directory)$(Get-Date -Format $Config_initialize.Logging.TimestampFormat)$($Config_initialize.Logging.Filename)"
  Append   = $true
}
New-Item -Path $Config_initialize.Logging.Directory -ItemType Directory -Force | Out-Null

Out-File -InputObject " " @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
Out-File -InputObject "  $($Config_initialize.Application.Name)" @Params_Logging
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
foreach ($Item in ($Config_initialize.Application.PSObject.Properties | Where-Object -Property "Name" -ne "Name")) {
  Out-File -InputObject "  $($Item.Name.PadRight(($Config_initialize.Application.PSObject.Properties.Name | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)" @Params_Logging
}
Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
Out-File -InputObject " " @Params_Logging

# Parameters
Out-File -InputObject "  Initialize" @Params_Logging
Out-File -InputObject "    - Parameters" @Params_Logging
foreach ($Item in $PSBoundParameters.GetEnumerator()) {
  Out-File -InputObject "        $($Item.Key.PadRight(($PSBoundParameters.Keys | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)" @Params_Logging
}

# Import Configs
Out-File -InputObject "    - Configs" @Params_Logging

try {
  if (Test-Path -Path $Config_initialize.Paths.Configs) {
    Get-ChildItem -Path $Config_initialize.Paths.Configs -Filter "*.json" | Where-Object -Property "Name" -notin "crust.json" | ForEach-Object {
      $Temp_Name = $_.BaseName
      $Temp_VarName = "Config_$($Temp_Name)"
      $Temp_Path = $_.FullName
      $Temp_Content = Get-Content -Path $Temp_Path -Raw | ConvertFrom-Json
      New-Variable -Name $Temp_VarName -Value $Temp_Content -Scope Global -Force
      Out-File -InputObject "        $($Temp_Name)" @Params_Logging
      Out-File -InputObject "          Path: $($Temp_Path)" @Params_Logging
      Out-File -InputObject "          Variable Name: $($Temp_VarName)" @Params_Logging
    }
    Remove-Variable -Name "Temp_*" -Force
  }
  else {
    Out-File -InputObject "          Status: Failure - $($Error.Exception.Message)" @Params_Logging
    Throw "Failure - $($Error.Exception.Message)"
  }
}
catch {
  Out-File -InputObject "          Status: Failure - $($Error.Exception.Message)" @Params_Logging
  Throw "Failure - $($Error.Exception.Message)"
}

# Import Modules
Out-File -InputObject "    - Modules" @Params_Logging

if (Test-Path -Path $Config_initialize.Paths.Modules) {
  foreach ($Item in (Get-ChildItem -Path $Config_initialize.Paths.Modules -Recurse -Filter "*.psm1" | Where-Object -Property "Name" -ne "initialize.psm1")) {
    try {
      Out-File -InputObject "        $($Item.Name)" @Params_Logging
      Out-File -InputObject "          Path: $($Item.FullName)" @Params_Logging

      $Temp_Result = Import-Module $Item.FullName -Scope Global -Force -PassThru
      foreach ($Item in $Temp_Result.ExportedCommands.GetEnumerator()) {
        Out-File -InputObject "            $($Item.Key)" @Params_Logging
      }
      Out-File -InputObject "          Status: Success" @Params_Logging
    }
    catch {
      Out-File -InputObject "          Status: Failure" @Params_Logging
      Throw "Failure - $($Error.Exception.Message)"
    }
  }
}
else {
  Out-File -InputObject "          Status: Failure" @Params_Logging
  Throw "Failure - ($Error.Exception.Message)"
}

Out-File -InputObject "    - Complete" @Params_Logging
Out-File -InputObject " " @Params_Logging