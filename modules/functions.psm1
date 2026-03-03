#--------------------------------------------------------------------------------------------
# PowerShell RegInvestigator - Functions
#--------------------------------------------------------------------------------------------
#Region Validation

# Write Error Codes
  Write-Host "            Write-vr_ErrorCode"
  function Write-vr_ErrorCode () {
    [CmdletBinding()]
    param (
      [Parameter()]
      $Code,
      [Parameter()]
      $Exit,
      [Parameter()]
      $Object
    )
    # Code: XXXX   4-digit code to identify where in script the operation failed
    # Exit: Boolean option to define if  exits or not
    # Object: The error object created when the script encounters an error ($Error[0], $PSItem, etc.)

    begin {

    }

    process {
      Write-Host "        Error: $($Object.Exception.ErrorId)"
      Write-Host "        Command Name: $($Object.CategoryInfo.Activity)"
      Write-Host "        Message: $($Object.Exception.Message)"
      Write-Host "        Line/Position: $($Object.Exception.Line)/$($Object.Exception.Offset)"
    }

    end {
      switch ($Exit) {
        $true {
          Write-Host "        Exit: $($Code)"
          Stop-Transcript
          Exit $Code
        }
        $false {
          Write-Host "        Continue Processing..."
        }
        Default {
          Write-Host "        Unknown Exit option in Write-vr_ErrorCode parameter"
        }
      }
    }
  }

# New-RecursivePath
  Write-Host "            New-RecursivePath"
  function New-RecursivePath {
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$true)]
      [string]$Path
    )

    begin {

    }

    process {
      # Registry Path
        # TODO: Create logic for this scenario

      # File Path
        # TODO: Create logic for this scenario

      # Network Path
        # TODO: Create logic for this scenario


        if ((Test-Path -Path $Path) -ne $true) {
          foreach ($Item in ($Path -split "\\")) {
            $Temp_Path_Recurse += $Item + "\"
            if (Test-Path -Path $Temp_Path_Recurse) {
              # Write-Output "                $($Temp_Path_Recurse): Exists"
            }
            else {
              New-Item -Path $Temp_Path_Recurse -ItemType Directory | Out-Null
              # Write-Output "                $($Temp_Path_Recurse): Created"
            }
          }
        }
    }

    end {

    }
  }

# # [FunctionName]
#   Write-Host "            Verb-Noun"
#   function Verb-Noun {
#     [CmdletBinding()]
#     param (
#       [Parameter()]
#       $ParameterName
#     )

#     begin {

#     }

#     process {

#     }

#     end {

#     }
#   }

#EndRegion Validation
#--------------------------------------------------------------------------------------------
