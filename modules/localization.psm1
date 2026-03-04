# Configs
New-Variable -Name "Localized" -Value (Get-Content -Path "$($Config_initialize.Paths.Languages)$($Language)\$($Language).json" -Raw | ConvertFrom-Json) -Scope Global -Force

# Update Dynamic Tokens
foreach ($Item in $Localized.DynamicToken.PSObject.Properties) {
  $Localized.DynamicToken.$($Item.Name) = Invoke-Expression $Localized.DynamicToken.$($Item.Name)
}

# Replace Dynamic Tokens
$Global:Temp_Localized = $Localized | ConvertTo-Json -Depth 100
foreach ($Item in $Localized.DynamicToken.PSObject.Properties) {
  $Global:Temp_Localized = $Global:Temp_Localized -replace "\{\{$($Item.Name)\}\}", $Localized.DynamicToken.$($Item.Name)
}
Set-Variable -Name "Localized" -Value ($Temp_Localized | ConvertFrom-Json) -Scope Global -Force