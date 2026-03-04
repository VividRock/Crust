# Crust - Documentation

- [Crust - Documentation](#crust---documentation)
  - [Folder Structure](#folder-structure)
  - [Language Localization](#language-localization)
  - [Folder Structure](#folder-structure-1)
  - [How To](#how-to)


## Folder Structure

```
  /assets
    -- image/video files for readme, web rendering, etc.
  /configs
    -- configuration files for specifying properties and settings for the application
  /docs
    -- documentation for the project
  /lang
    -- language files for localization of the text input/output
  / logs
    -- for outputting log files to the project for easy access from VS code when running tests
  / modules
    -- module files containing various functions utilized by the main controller script
  / tests
    -- test logic and scripts to perform for validation and regression testing
  crust.ps1
    -- the main controller script that collects input, configures the environment, calls the imported functions in the prescribed order, and outputs information for the user.
  README.md
    -- main readme to provide high-level project information for the github repository
```

## Language Localization

## Folder Structure

The language folders utilize the BCP-47 format representation of the names of languages for standardization. Within each language folder is a JSON file with the standard "[xx]-[XX].json" name. This translation file contains the key identifiers and their translation of the message meant for output to the user.

```
\lang
  \en-US
    en-US.json
  \[xx]-[XX]
    [xx]-[XX].json
```

## How To

In PowerShell, the following snippet will get you the first preferred language of the current user.

```powershell
# Windows & Linux
($env:LANG -split "\.")[0]
```