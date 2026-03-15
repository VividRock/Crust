param (
  [string]$Path,
  [string]$Identifier,
  [string]$Console,
  [string]$Title,
  [switch]$AlwaysOnTop
)

# Import Module
Import-Module -Name ".\modules\crust.psm1" -Force

# Invoke Function
Invoke-CrustMenu -LogDir $LogDir -CrustUri $CrustUri -LangUri $LangUri -MenuUri $MenuUri -MenuName $MenuName
