function Initialize-Crust {
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
    foreach ($Item in (Get-ChildItem -Path $Config_initialize.Paths.Modules -Recurse -Filter "*.psm1" | Where-Object -Property "Name" -ne "crust.psm1")) {
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

}

function Set-Tokens {
  # Configs
  New-Variable -Name "Language" -Value (Get-Content -Path "$($Config_initialize.Paths.Languages)$($UICulture)\$($UICulture).json" -Raw | ConvertFrom-Json) -Scope Global -Force

  # Update Dynamic Tokens
  foreach ($Item in $Language.DynamicToken.PSObject.Properties) {
    $Language.DynamicToken.$($Item.Name) = Invoke-Expression $Language.DynamicToken.$($Item.Name)
  }

  # Replace Dynamic Tokens
  $Global:Temp_Language = $Language | ConvertTo-Json -Depth 100
  foreach ($Item in $Language.DynamicToken.PSObject.Properties) {
    $Global:Temp_Language = $Global:Temp_Language -replace "\{\{$($Item.Name)\}\}", $Language.DynamicToken.$($Item.Name)
  }
  Set-Variable -Name "Language" -Value ($Temp_Language | ConvertFrom-Json) -Scope Global -Force
}

function Clear-Interface {

  begin {

  }

  process {
    Clear-Host
  }

  end {

  }
}

function Initialize-Interface {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidatePattern("[0,10000]")]
    [string]  $SleepMilliseconds = 100
  )

  begin {

  }

  process {
    # Load Header
    foreach ($Item in ($Language.Header.psobject.Properties | Sort-Object -Property Name)) {
      Write-Interface -Message $Item.Value -IndentLevel 0
    }

    # Load Title Bar
    Write-Interface -Message $Language.Component.Divider -IndentLevel 0
    Write-Interface -Message $Language.TitleBar.Pattern
    Write-Interface -Message $Language.Component.Divider -IndentLevel 0

    # Add White Space
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
  }

  end {

  }
}

function Write-Interface {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]  $Message,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidatePattern("[0-9]")]
    [string]  $IndentLevel = 0,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
    [string]  $ForegroundColor = "DarkGray",
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 3)]
    [switch]  $NoNewLine,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 4)]
    [switch]  $LineBreakAfter,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 5)]
    [ValidatePattern("[0,1000]")]
    [string]  $SleepMilliseconds = $Config_initialize.Settings.InterfaceSleepMilliseconds
  )

  begin {

  }

  process {
    # Process the Indent Level
    If ($IndentLevel -ne 0) {
      $i = $IndentLevel
      do {
        $Message = $Language.Component.Indention + $Message
        $i = $i - 1
      }
      until ($i -le 0)
    }
    Else {
      # Do nothing, no indent is needed
    }

    # Process the SleepMilliseconds
    If ($SleepMilliseconds -ge 1) {
      Start-Sleep -Milliseconds $SleepMilliseconds
    }
    Else {
      # Do nothing, no sleep is needed
    }

    # Write the output
    If ($NoNewLine -eq $true) {
      Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline
    }
    ElseIf ($NoNewLine -eq $false) {
      Write-Host $Message -ForegroundColor $ForegroundColor
    }

    # Write line break if specified
    If ($LineBreakAfter -eq $true) {
      Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
    }
  }

  end {

  }
}

function Get-ConfirmationToContinue {

  begin {
    # Add White Space
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
  }

  process {
    # Prompt for user acceptance
    do {
      Write-Interface -Message "$($Language.Prompt.VerifyContinue)  ($($Language.Prompt.Response_VerifyYesNo_Yes)/$($Language.Prompt.Response_VerifyYesNo_No))" -IndentLevel 1
      $InputValue = Read-Host

      if ($InputValue -notin $Language.Prompt.Response_VerifyYesNo_Yes, $Language.Prompt.Response_VerifyYesNo_No) {
        Write-Interface -Message $Language.Prompt.Response_VerifyYesNo_IncorrectInput -IndentLevel 2
        Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
      }
    }
    until (($InputValue -ne "") -and ($InputValue -in $Language.Prompt.Response_VerifyYesNo_Yes, $Language.Prompt.Response_VerifyYesNo_No))
  }

  end {
    # Process Response
    if ($InputValue -eq $Language.Prompt.Response_VerifyYesNo_Yes) {
      # Do Nothing
    }
    elseif ($InputValue -eq $Language.Prompt.Response_VerifyYesNo_No) {
      Return
    }
    else {
      Get-ConfirmationToContinue
    }
  }
}

function Show-InterfaceMenu {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [string] $MenuName
  )

  begin {
    # Get Menu Object
    $MenuObject = ($Language.MenuStructure | Where-Object -Property "Name" -eq $MenuName | Sort-Object -Property "Index")

    # Clear Interface
    Clear-Interface
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0

    # Initialize Interface
    Initialize-Interface

    # Write- Message
    Write-Interface -Message $MenuObject.Name -IndentLevel 1

    # Add White Space
    Write-Interface -Message $Interface.LineBreak -IndentLevel 0

    # Set incremental integer for ensuring only one divider line is written to the screen
    $DividerLine_Increment = 0
  }

  process {
    foreach ($MenuItem in $MenuObject.MenuItems) {
      # Write Divider
      if ($MenuItem.Index -match '^[a-zA-Z]*$') {
        # Increase divider increment
        $DividerLine_Increment = $DividerLine_Increment + 1

        # Add White Space
        if ($DividerLine_Increment -lt 2) {
          Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
          Write-Interface -Message "-------------------------------------------------------" -IndentLevel 1
          Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
        }
      }

      # Write Menu Items
      Write-Interface -Message $MenuItem.Index -IndentLevel 2 -NoNewLine
      Write-Interface -Message $MenuItem.Label -IndentLevel 2
    }
  }

  end {
    # Get Menu Choice and Return to Main Loop
    $Menu_Choice = Get-InterfaceMenuInput -MenuObject $MenuObject
    Return $Menu_Choice
  }
}

function Get-InterfaceMenuInput {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Position = 0)]
    [object] $MenuObject
  )

  begin {
    # Prompt user for their choice
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
    do { $Input_User = Read-Host -Prompt "Choose: " }
    until (($Input_User -ne "") -and ($Input_User -in $MenuObject.MenuItems.Index))
  }

  process {
    # Execute Menu Item Scriptblock
    if (($MenuObject.MenuItems | Where-Object -Property "Index" -eq $Input_User).ScriptBlock -in "", $null, " ") {
      Return ($MenuObject.MenuItems | Where-Object -Property "Index" -eq $Input_User).Label
    }
    else {
      Invoke-Command -ScriptBlock $([ScriptBlock]::Create(($MenuObject.MenuItems | Where-Object -Property "Index" -eq $Input_User).ScriptBlock))
    }
  }

  end {

  }
}
