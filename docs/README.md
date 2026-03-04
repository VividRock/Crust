# Crust - Documentation

TODO: If the usage of this tool becomes too complex to be easily articulated within the main project README.md file, then this folder and its contents will become the main location for documentation creation and reference.


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