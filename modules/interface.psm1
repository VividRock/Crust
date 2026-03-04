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
		foreach ($Item in ($Localized.Header.psobject.Properties | Sort-Object -Property Name)) {
			Write-Interface -Message $Item.Value -IndentLevel 0
		}

		# Load Title Bar
		Write-Interface -Message $Localized.Component.Divider -IndentLevel 0
		Write-Interface -Message $Localized.TitleBar.Pattern
		Write-Interface -Message $Localized.Component.Divider -IndentLevel 0

		# Add White Space
		Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
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
				$Message = $Localized.Component.Indention + $Message
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
			Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
		}
	}

	end {

	}
}

function Get-ConfirmationToContinue {

	begin {
		# Add White Space
		Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
		Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
	}

	process {
		# Prompt for user acceptance
		do {
			Write-Interface -Message "$($Localized.Prompt.VerifyContinue)  ($($Localized.Prompt.Response_VerifyYesNo_Yes)/$($Localized.Prompt.Response_VerifyYesNo_No))" -IndentLevel 1
			$InputValue = Read-Host

			if ($InputValue -notin $Localized.Prompt.Response_VerifyYesNo_Yes, $Localized.Prompt.Response_VerifyYesNo_No) {
				Write-Interface -Message $Localized.Prompt.Response_VerifyYesNo_IncorrectInput -IndentLevel 2
				Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
			}
		}
		until (($InputValue -ne "") -and ($InputValue -in $Localized.Prompt.Response_VerifyYesNo_Yes, $Localized.Prompt.Response_VerifyYesNo_No))
	}

	end {
		# Process Response
		if ($InputValue -eq $Localized.Prompt.Response_VerifyYesNo_Yes) {
			# Do Nothing
		}
		elseif ($InputValue -eq $Localized.Prompt.Response_VerifyYesNo_No) {
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
		$MenuObject = ($Localized.MenuStructure | Where-Object -Property "Name" -eq $MenuName | Sort-Object -Property "Index")

		# Clear Interface
		Clear-Interface
		Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0

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
					Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
					Write-Interface -Message "-------------------------------------------------------" -IndentLevel 1
					Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
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
		Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
		Write-Interface -Message $Localized.Component.LineBreak -IndentLevel 0
		do { $Input_User = Read-Host -Prompt "Choose: " }
		until (($Input_User -ne "") -and ($Input_User -in $MenuObject.MenuItems.Index))
	}

	process {
		# Execute Menu Item Scriptblock
		if (($MenuObject.MenuItems | Where-Object -Property "Index" -eq $Input_User).ScriptBlock -in "",$null," ") {
			Return ($MenuObject.MenuItems | Where-Object -Property "Index" -eq $Input_User).Label
		}
		else {
			Invoke-Command -ScriptBlock $([ScriptBlock]::Create(($MenuObject.MenuItems | Where-Object -Property "Index" -eq $Input_User).ScriptBlock))
		}
	}

	end {

	}
}
