function Initialize-Crust {
  # Configs
  New-Variable -Name "Crust" -Value (Get-Content -Path ".\configs\crust.json" -Raw | ConvertFrom-Json) -Scope Global -Force

  # Metadata
  $Crust.Metadata.StartDateTime = (Get-Date)
  $Crust.Metadata.CompleteDateTime = $null
  $Crust.Metadata.CompleteTimeSpan = $null
  $Crust.Metadata.ExecutionUser = $([System.Security.Principal.WindowsIdentity]::GetCurrent())

  # Preferences
  $ErrorActionPreference = "Stop"
  foreach ($Item in $Crust.Preferences.PSObject.Properties) {
    Set-Variable -Name $Item.Name -Value $Item.Value -Scope Global -Force
  }

  # Start Logging
  Write-CrustLog -Initialize
  Write-CrustLog -Header

  # Parameters
  Write-CrustLog -Message "  Initialize"
  Write-CrustLog -Message "    - Parameters"
  foreach ($Item in $PSBoundParameters.GetEnumerator()) {
    Write-CrustLog -Message "        $($Item.Key.PadRight(($PSBoundParameters.Keys | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)"
  }

  # Import Modules
  Write-CrustLog -Message "    - Modules"

  if (Test-Path -Path $Crust.Paths.Modules) {
    foreach ($Item in (Get-ChildItem -Path $Crust.Paths.Modules -Recurse -Filter "*.psm1" | Where-Object -Property "Name" -ne "crust.psm1")) {
      try {
        Write-CrustLog -Message "        $($Item.Name)"
        Write-CrustLog -Message "          Path: $($Item.FullName)"

        $Temp_Result = Import-Module $Item.FullName -Scope Global -Force -PassThru
        foreach ($Item in $Temp_Result.ExportedCommands.GetEnumerator()) {
          Write-CrustLog -Message "            $($Item.Key)"
        }
        Write-CrustLog -Message "          Status: Success"
      }
      catch {
        Write-CrustLog -Message "          Status: Failure"
        Throw "Failure - $($Error.Exception.Message)"
      }
    }
  }
  else {
    Write-CrustLog -Message "          Status: Failure"
    Throw "Failure - ($Error.Exception.Message)"
  }

  Write-CrustLog -Message "    - Complete"
  Write-CrustLog -Message " "

}

function Set-Tokens {
  # Configs
  New-Variable -Name "Language" -Value (Get-Content -Path "$($Crust.Paths.Languages)$($UICulture)\$($UICulture).json" -Raw | ConvertFrom-Json) -Scope Global -Force

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
    [string]  $SleepMilliseconds = $Crust.Settings.InterfaceSleepMilliseconds
  )

  begin {
    # Reset Interface
    Clear-Interface
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
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
    [string]  $SleepMilliseconds = $Crust.Settings.InterfaceSleepMilliseconds
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

function Get-InterfaceMenu {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [string] $File
  )

  begin {

  }

  process {
    # Get Object from Config File
    $Temp_Object = Get-Content -Path "$($Crust.Paths.Configs)\$($File)" -Raw | ConvertFrom-Json
  }

  end {
    # Return Object
    Return $Temp_Object
  }
}

function Show-InterfaceMenu {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [object] $Menu,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [string] $Name
  )

  begin {
    # Initialize Interface
    Initialize-Interface
    Write-Interface -Message $Menu.Name -IndentLevel 1
    Write-Interface -Message $Interface.LineBreak -IndentLevel 0

    # Set incremental integer for ensuring only one divider line is written to the screen
    $Divider_Increment = 0
  }

  process {
    foreach ($Item in $Menu.MenuItems) {
      # Write Divider
      if ($Item.Index -match '^[a-zA-Z]*$') {
        # Increase divider increment
        $Divider_Increment = $Divider_Increment + 1

        # Add White Space
        if ($Divider_Increment -lt 2) {
          Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
          Write-Interface -Message "-------------------------------------------------------" -IndentLevel 1
          Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
        }
      }

      # Write Menu Items
      Write-Interface -Message $Item.Index -IndentLevel 2 -NoNewLine
      Write-Interface -Message $Item.Label -IndentLevel 2
    }
  }

  end {
    # Get Menu Choice and Return to Main Loop
    $Result = Get-InterfaceMenuInput -Menu $Menu
    Return $Result
  }
}

function Get-InterfaceMenuInput {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Position = 0)]
    [object] $Menu
  )

  begin {
    # Prompt user for their choice
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
    Write-Interface -Message $Language.Component.LineBreak -IndentLevel 0
    do { $Input_User = Read-Host -Prompt "Choose: " }
    until (($Input_User -ne "") -and ($Input_User -in $Menu.MenuItems.Index))
  }

  process {
    # Execute Menu Item Scriptblock
    if (($Menu.MenuItems | Where-Object -Property "Index" -eq $Input_User).ScriptBlock -in "", $null, " ") {
      Return ($Menu.MenuItems | Where-Object -Property "Index" -eq $Input_User).Label
    }
    else {
      Invoke-Command -ScriptBlock $([ScriptBlock]::Create(($Menu.MenuItems | Where-Object -Property "Index" -eq $Input_User).ScriptBlock))
    }
  }

  end {

  }
}

function Get-UserCredential {
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Position = 0)]
    [string] $LaunchPoint,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Position = 1)]
    [switch] $Validate
  )

  begin {
    # Load the required .NET assembly
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
  }

  process {
    # Get Credential
    switch ($Crust.Security.Authentication.Method) {
      { $_ -eq "Popup" } {
        Write-Interface -Message $Language.Security.Authentication.Popup.Message_01 -IndentLevel 2
        $Credential = $host.ui.PromptForCredential($Language.Security.Authentication.Popup.Title, $Language.Security.Authentication.Body, "", "")
      }
      { $_ -eq "Inline" } {
        # Prompt for Inputs
        $Username = Read-Host -Prompt "    $($Language.Security.Authentication.Inline.Username)"
        $Password = Read-Host -Prompt "    $($Language.Security.Authentication.Inline.Password)" -AsSecureString

        # Create Credential Object
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password

        # Safely Discard Secure String
        $Password.Dispose()
      }
      Default {
        $Credential = $host.ui.PromptForCredential($Language.Security.Authentication.Popup.Title, $Language.Security.Authentication.Body, "", "")
      }
    }

    # Process Credential Object
    if ($Credential -in "", $null) {
      # Write to Interface
      Write-Interface -Message $Language.Security.Authentication.UserCancelled -IndentLevel 2
    }
    else {
      # Write to Interface
      Write-Interface -Message "$($Language.Security.Authentication.Inline.Username): $($Credential.Username)" -IndentLevel 3
      Write-Interface -Message "$($Language.Security.Authentication.Inline.Password): $($Credential.Password)" -IndentLevel 3

      # Validate Credential
      if (($credential -notin "", $null) -and ($Validate)) {
        $Validation = Confirm-UserCredential -Credential $Credential
      }
    }
  }

  end {
    # Process Return
    if ($Credential -in "", $null) {
      Return "UserCancelled"
    }
    elseif ($Validation -eq $false) {
      Return $false
    }
    elseif ($Credential.GetType().Name -eq "PSCredential") {
      Return $Credential
    }
    else {
      Return $false
    }
  }
}

function Confirm-UserCredential {
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, Position = 0)]
    [pscredential]$Credential
  )

  begin {

  }

  process {
    # Validate Credential
    switch ($Crust.Security.Authentication.Context) {
      { $_ -eq "Machine" } {
        $Validation = [System.DirectoryServices.AccountManagement.PrincipalContext]::new('Machine').ValidateCredentials($Credential.UserName, $Credential.GetNetworkCredential().Password)
      }
      { $_ -eq "Domain" } {
        $DomainName = $env:USERDOMAIN
        $Validation = [System.DirectoryServices.AccountManagement.PrincipalContext]::new([System.DirectoryServices.AccountManagement.ContextType]::Domain, $DomainName).ValidateCredentials($Credential.UserName, $Credential.GetNetworkCredential().Password, [System.DirectoryServices.AccountManagement.ContextOptions]::Negotiate)
      }
      { $_ -eq "ApplicationDirectory" } {
        # TODO Add this authentication context type
      }
      Default {}
    }
  }

  end {
    # Validate
    if ($Validation) {
      Return $true
    }
    else {
      Return $false
    }
  }
}

function Write-CrustLog {
  [CmdletBinding(DefaultParameterSetName = "Message")]
  param (
    [Parameter(Mandatory = $false,
      HelpMessage = "Initialize the log.",
      ParameterSetName = "Initialize")]
    [switch]$Initialize,
    [Parameter(Mandatory = $false,
      HelpMessage = "Writes the log header.",
      ParameterSetName = "Header")]
    [switch]$Header,
    [Parameter(Mandatory = $false,
      HelpMessage = "Writes the log footer.",
      ParameterSetName = "Footer")]
    [switch]$Footer,

    [Parameter(Mandatory = $false,
      HelpMessage = "Writes the log message.",
      ParameterSetName = "Message")]
    [string]$Message
  )

  begin {
    # Initialize
    if ($Initialize) {
      $Global:Params_Logging = @{
        FilePath = "Filesystem::$($Crust.Logging.Directory)$(Get-Date -Format $Crust.Logging.TimestampFormat)$($Crust.Logging.Filename)"
        Append   = $true
      }
      New-Item -Path $Crust.Logging.Directory -ItemType Directory -Force | Out-Null
      Write-CrustLog -Message ""
    }
  }

  process {
    # Write Header
    if ($Header) {
      Out-File -InputObject " " @Params_Logging
      Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
      Out-File -InputObject "  $($Crust.Application.Name)" @Params_Logging
      Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
      foreach ($Item in ($Crust.Application.PSObject.Properties | Where-Object -Property "Name" -ne "Name")) {
        Out-File -InputObject "  $($Item.Name.PadRight(($Crust.Application.PSObject.Properties.Name | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)" @Params_Logging
      }
      Out-File -InputObject "------------------------------------------------------------------------------" @Params_Logging
      Out-File -InputObject " " @Params_Logging
    }

    # Write Footer
    if ($Footer) {
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
    }

    # Write Message
    if ($Message) {
      Out-File -InputObject $Message @Params_Logging
    }
  }

  end {

  }
}