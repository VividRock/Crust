# Crust - Languages

## Description
TODO: Provide information on the supported languages of the project

## Folder Structure

The language folders utilize the BCP-47 format representation of the names of languages for standardization. Within each language folder is a JSON file with the standard "[xx]-[XX].json" name. This translation file contains the key identifiers and their translation of the message meant for output to the user.

```
\lang
  \en-US
    en-US.json
  \[xx]-[XX]
    [xx]-[XX].json
  README.md
    -- document the usage and support of multiple languages within the project
```

## How To

In PowerShell, the following snippet will get you the first preferred language of the current user.

```powershell
# Windows & Linux
($env:LANG -split "\.")[0]
```