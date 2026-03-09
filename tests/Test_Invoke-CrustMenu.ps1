param (
  [string]$LocalPath = "$($env:TEMP)",
  [string]$CrustUri,
  [string]$LangUri,
  [string]$MenuUri,
  [string]$MenuName
)

# Import Module
Import-Module -Name ".\modules\crust.psm1" -Force

# Invoke Function
Invoke-CrustMenu -LocalPath $LocalPath -CrustUri $CrustUri -LangUri $LangUri -MenuUri $MenuUri -MenuName $MenuName