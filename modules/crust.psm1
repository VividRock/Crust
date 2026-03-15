function Invoke-CrustMenu {
  <#
	.SYNOPSIS
		Launches a Crust menu to provide a simple, retro-stylized, menu-driven interface for use in your own projects.

	.DESCRIPTION
		Launches a Crust menu to provide a simple, retro-stylized, menu-driven interface for use in your own projects.

  .PARAMETER CrustUri
  Path to the crust.json config file.

  .PARAMETER LangUri
  Path to the language (i.e.  en-US.json) config file.

  .PARAMETER MenuUri
  Path to the menu.json config file.

  .PARAMETER MenuName
  Specify the name of a menu in the menu.json config file to load with Crust.

  .PARAMETER LogDir
    Path to a local folder where temporary files can be created. Default: "$($env:TEMP)\VividRock\Crust"

  .EXAMPLE
    PS> Invoke-CrustMenu -CrustUri $CrustUri -LangUri $LangUri -MenuUri $MenuUri -MenuName $MenuName -LogDir $-LogDir

    Launches a Crust interface using the provided config file URIs you pass to customize it. The files can be located anywhere with a valid web URL or Filesystem path.

	.INPUTS
		None

	.OUTPUTS
		None

	.LINK
		https://github.com/VividRock/Crust
  #>

  [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = "Default")]
  param (
    [Parameter(Mandatory = $false,
      HelpMessage = "Path to a local folder where temporary files can be created (logs, etc.).",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ })]
    [string]$LogDir = "$($env:TEMP)\VividRock\Crust",
    [Parameter(Mandatory = $true,
      HelpMessage = "Path to the crust.json config file.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$CrustUri,
    [Parameter(Mandatory = $true,
      HelpMessage = "Path to the language (i.e.  en-US.json) config file.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$LangUri,
    [Parameter(Mandatory = $true,
      HelpMessage = "Path to the menu.json config file.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$MenuUri,
    [Parameter(Mandatory = $true,
      HelpMessage = "Specify the name of a menu in the menu.json config file to load with Crust.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$MenuName
  )

  begin {
    # Initialize Application
    Initialize-Crust @PSBoundParameters
    Set-Tokens

    # Initialize Interface
    Clear-Interface
    Initialize-Interface
    Write-Interface -Message $Language.Security.Authentication.SectionTitle -IndentLevel 1
    Write-Interface -Message $Interface.LineBreak -IndentLevel 0
  }

  process {
    # Get Credentials
    Write-CrustLog -Message "  Get Credential Object: AtStartup"

    if (($Crust.Security.Authentication.Enabled -eq $true) -and ($Crust.Security.Authentication.LaunchPoint -eq "AtStartup")) {
      do {
        # Get Credential
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
      Write-CrustLog -Message "    - Skipped: Authentication not enabled in the crust.json config file "
    }
    else {
      Write-CrustLog -Message "    - Skipped: Authentication LaunchPoint not configured for AtStartup in the crust.json config file"
    }

    Write-CrustLog -Message "    - Complete"
    Write-CrustLog -Message " "

    # Show Menu
    Write-CrustLog -Message "  Show Menu"
    Write-CrustLog -Message "    Name: $($MenuName)"

    if ($Crust_Credential -eq "UserCancelled") {
      <# Action to perform if the condition is true #>
    }
    elseif ((($Crust.Security.Authentication.Enabled -eq $true) -and ($Crust_Credential)) -or ($Crust.Security.Authentication.Enabled -eq $false)) {
      Get-InterfaceMenu -MenuUri $MenuUri
      while ($MenuName -ne "Quit") {
        $MenuName = Show-InterfaceMenu -Menu ($Menu | Where-Object -Property "Name" -eq $MenuName) -Name $MenuName
      }
    }
    else {
      # Do Nothing
    }

    Write-CrustLog -Message "    - Complete"
  }

  end {
    # Write Footer to Log
    Write-CrustLog -Footer

    # Return Status
    Return $Crust.Metadata.ScriptResultCode
  }

  clean {
    # Cleanup Logs
    if ($Crust.Logging.CleanupAfterRun) {
      Get-Item -Path $Crust.Logging.FilePath | Remove-Item -Force

      if ((Get-ChildItem -Path $Crust.Logging.Directory).Count -eq 0) {
        Get-Item -Path ($Crust.Logging.Directory) | Remove-Item -Force
      }
      if ((Get-ChildItem -Path ($Crust.Logging.Directory | Split-Path -Parent)).Count -eq 0) {
        Get-Item -Path ($Crust.Logging.Directory | Split-Path -Parent) | Remove-Item -Force
      }
    }

    # Clear Environment
    $Crust = $null
    $Crust_Credential = $null
  }
}

function Initialize-Crust {
  [CmdletBinding(ConfirmImpact = 'Low', DefaultParameterSetName = "Default")]
  param (
    [Parameter(Mandatory = $false,
      HelpMessage = "Path to a local folder where temporary files can be created (logs, etc.).",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ })]
    [string]$LogDir = "$($env:TEMP)\VividRock\Crust",
    [Parameter(Mandatory = $true,
      HelpMessage = "Path to the crust.json config file.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$CrustUri,
    [Parameter(Mandatory = $true,
      HelpMessage = "Path to the language (i.e.  en-US.json) config file.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$LangUri,
    [Parameter(Mandatory = $true,
      HelpMessage = "Path to the menu.json config file.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$MenuUri,
    [Parameter(Mandatory = $true,
      HelpMessage = "Specify the name of a menu in the menu.json config file to load with Crust.",
      ParameterSetName = "Default")]
    [ValidateNotNullOrEmpty()]
    [string]$MenuName
  )

  # Import Crust Configuration
  if ([System.Uri]::IsWellFormedUriString($CrustUri, [System.UriKind]::Absolute)) {
    New-Variable -Name "Crust" -Value $(Invoke-RestMethod -Uri $CrustUri -UseBasicParsing) -Scope Global -Force
  }
  else {
    New-Variable -Name "Crust" -Value (Get-Content -Path $CrustUri -Raw | ConvertFrom-Json) -Scope Global -Force
  }

  # Set Crust Configuration Data
  $Crust.Logging.Directory = if ($LogDir -match "'\\VividRock\\Crust$'") {
    $LogDir
  }
  else {
    "$($LogDir)\VividRock\Crust\"
  }
  $Crust.Logging.Filepath = "Filesystem::$($Crust.Logging.Directory)$(Get-Date -Format $Crust.Logging.TimestampFormat)$($Crust.Logging.Filename)"
  $Crust.Paths.LangUri = $LangUri
  $Crust.Paths.MenuUri = $MenuUri
  $Crust.Metadata.StartDateTime = (Get-Date)
  $Crust.Metadata.CompleteDateTime = $null
  $Crust.Metadata.CompleteTimeSpan = $null
  $Crust.Metadata.ExecutionUser = $([System.Security.Principal.WindowsIdentity]::GetCurrent())

  # PowerShell Environment
  if ($PSVersionTable.PSVersion -lt $Crust.PowerShell.MinimumVersion) {
    throw "The current version of PowerShell ($($PSVersionTable.PSVersion)) is less than the minimum version required by Crust ($($Curst.PowerShell.MinimumVersion))"
  }
  foreach ($Item in $Crust.PowerShell.Preferences.PSObject.Properties) {
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

  Write-CrustLog -Message "    - Complete"
  Write-CrustLog -Message " "

}
Export-ModuleMember -Function Invoke-CrustMenu -Variable Crust, Crust_Credential

function Set-Tokens {
  # Import Configuration
  if ([System.Uri]::IsWellFormedUriString($LangUri, [System.UriKind]::Absolute)) {
    New-Variable -Name "Language" -Value $(Invoke-RestMethod -Uri $LangUri -UseBasicParsing) -Scope Global -Force
  }
  else {
    New-Variable -Name "Language" -Value (Get-Content -Path $LangUri -Raw | ConvertFrom-Json) -Scope Global -Force
  }

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
    if ($IndentLevel -ne 0) {
      $i = $IndentLevel
      do {
        $Message = $Language.Component.Indention + $Message
        $i = $i - 1
      }
      until ($i -le 0)
    }
    else {
      # Do nothing, no indent is needed
    }

    # Process the SleepMilliseconds
    if ($SleepMilliseconds -ge 1) {
      Start-Sleep -Milliseconds $SleepMilliseconds
    }
    else {
      # Do nothing, no sleep is needed
    }

    # Write the output
    if ($NoNewLine -eq $true) {
      Write-Host $Message -ForegroundColor $ForegroundColor -NoNewline
    }
    elseif ($NoNewLine -eq $false) {
      Write-Host $Message -ForegroundColor $ForegroundColor
    }

    # Write line break if specified
    if ($LineBreakAfter -eq $true) {
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
    [string] $MenuUri
  )

  begin {

  }

  process {
    # Get Object from Config File
    # $Temp_Object = Get-Content -Path "$($Crust.Paths.Configs)\$($MenuUri)" -Raw | ConvertFrom-Json

    # Import Configuration
    if ([System.Uri]::IsWellFormedUriString($MenuUri, [System.UriKind]::Absolute)) {
      New-Variable -Name "Menu" -Value $(Invoke-RestMethod -Uri $MenuUri -UseBasicParsing) -Scope Global -Force
    }
    else {
      New-Variable -Name "Menu" -Value (Get-Content -Path $MenuUri -Raw | ConvertFrom-Json) -Scope Global -Force
    }
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
    do {
      $Input_User = Read-Host -Prompt "Choose: "
    }
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
      Default {
      }
    }
  }

  end {
    Return $Validation
  }
}

function Invoke-CrustStatus {
  [CmdletBinding(DefaultParameterSetName = "Default")]
  param (
    [Parameter(Mandatory = $true,
      HelpMessage = "Provide the path to the log file that the status window should monitor.",
      ParameterSetName = "Default")]
    [string]$Path,
    [Parameter(Mandatory = $false,
      HelpMessage = "The identifier (name) given to the event object.",
      ParameterSetName = "Default")]
    [string]$Identifier,
    [Parameter(Mandatory = $false,
      HelpMessage = "Set the console application used when presenting the status window.",
      ParameterSetName = "Default")]
    [ValidateSet("PowerShell", "Terminal")]
    [string]$Console,
    [Parameter(Mandatory = $false,
      HelpMessage = "Set the title of the status window.",
      ParameterSetName = "Default")]
    [string]$Title = "Crust | VividRock",
    [Parameter(Mandatory = $false,
      HelpMessage = "Set the status window to remain on top of all windows.",
      ParameterSetName = "Default")]
    [switch]$AlwaysOnTop
  )

  begin {
    # Validate
    if ((Test-Path -Path $Path) -ne $true) {
      Throw "Error: the path provided for the log file is invalid."
    }

    # Initialize
  }

  process {
    # Using PowerShell
    if ($Console -eq "PowerShell") {
      $Temp_Process = Start-Process powershell "-NoExit -Command Get-Content $Path -Wait" -PassThru

      # Always On Top Logic
      if ($AlwaysOnTop) {
        # Use .NET to find the window handle and set it to TOPMOST
        Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class WinApi {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
  }
"@

        # Give the window a second to spawn
        Start-Sleep -Seconds 1
        [WinApi]::SetWindowPos($Temp_Process.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0001 -bor 0x0002)
      }
    }

    # Using Terminal
    # if ($Console -eq "Terminal") {
    #   $Temp_Process = Start-Process -FilePath "wt.exe" -ArgumentList "--title `"VividRock - Strata | Status Output`"", "-p", "Windows PowerShell", "powershell", "-NoExit", "-Command", "Get-Content -Path $Path -Wait" -PassThru
    # }

    Register-ObjectEvent -InputObject $Temp_Process -EventName "Exited" -Action {

    } | Out-Null

    # 3. Wait for the process to exit
    # This blocks the script and allows the event handler to fire
    $Temp_Process | Wait-Process

    "Testing Output" | Out-File -FilePath $Path -Append
  }

  end {

  }

  clean {

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
    if (($Initialize) -and ($Crust.Logging.Enabled)) {
      $Temp_Params = @{
        FilePath = $Crust.Logging.Filepath
        Append   = $true
      }
      $Crust.Logging.SplatParams = $Temp_Params
      if ((Test-Path -Path $Crust.Logging.Directory) -eq $false) {
        New-Item -Path $Crust.Logging.Directory -ItemType Directory -Force | Out-Null
      }
      Write-CrustLog -Message " "
    }

    # Setup Splat
    $SplatParams = $Crust.Logging.SplatParams
  }

  process {
    # Write Header
    if (($Header) -and ($Crust.Logging.Enabled)) {
      Out-File -InputObject " " @SplatParams
      Out-File -InputObject "------------------------------------------------------------------------------" @SplatParams
      Out-File -InputObject "  $($Crust.Application.Name)" @SplatParams
      Out-File -InputObject "------------------------------------------------------------------------------" @SplatParams
      foreach ($Item in ($Crust.Application.PSObject.Properties | Where-Object -Property "Name" -ne "Name")) {
        Out-File -InputObject "  $($Item.Name.PadRight(($Crust.Application.PSObject.Properties.Name | Measure-Object -Property Length -Maximum).Maximum + 1)): $($Item.Value)" @SplatParams
      }
      Out-File -InputObject "------------------------------------------------------------------------------" @SplatParams
      Out-File -InputObject " " @SplatParams
    }

    # Write Footer
    if (($Footer) -and ($Crust.Logging.Enabled)) {
      # Gather Data
      $Crust.Metadata.ScriptResult = "Success"
      $Crust.Metadata.ScriptResultCode = 0
      $Crust.Metadata.CompleteDateTime = Get-Date
      $Crust.Metadata.CompleteTimeSpan = New-TimeSpan -Start $Crust.Metadata.StartDateTime -End $Crust.Metadata.CompleteDateTime

      # Output
      Out-File -InputObject " " @SplatParams
      Out-File -InputObject "------------------------------------------------------------------------------" @SplatParams
      Out-File -InputObject "  Script Result: $($Crust.Metadata.ScriptResult)" @SplatParams
      Out-File -InputObject "  Script Started: $($Crust.Metadata.StartDateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)" @SplatParams
      Out-File -InputObject "  Script Completed: $($Crust.Metadata.CompleteDateTime.ToUniversalTime().ToString(`"yyyy-MM-dd HH:mm:ss`")) (UTC)" @SplatParams
      Out-File -InputObject "  Total Time: $($Crust.Metadata.CompleteTimeSpan.Days) days, $($Crust.Metadata.CompleteTimeSpan.Hours) hours, $($Crust.Metadata.CompleteTimeSpan.Minutes) minutes, $($Crust.Metadata.CompleteTimeSpan.Seconds) seconds, $($Crust.Metadata.CompleteTimeSpan.Milliseconds) milliseconds" @SplatParams
      Out-File -InputObject "------------------------------------------------------------------------------" @SplatParams
      Out-File -InputObject "  End of Script" @SplatParams
      Out-File -InputObject "------------------------------------------------------------------------------" @SplatParams
    }

    # Write Message
    if (($Message) -and ($Crust.Logging.Enabled)) {
      Out-File -InputObject $Message @SplatParams
    }
  }

  end {

  }
}
