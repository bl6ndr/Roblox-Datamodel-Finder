# Roblox Datamodel Finder

A robust utility for locating the Roblox Datamodel in memory using multiple redundant methods. This tool helps ensure reliable access to the Datamodel even across different Roblox versions.

## Features

- 7 different methods to locate the Datamodel pointer
- Automatic validation of found addresses
- Determines the most reliable Datamodel address across methods
- Uses updated memory offsets compatible with recent Roblox versions
- Comprehensive reporting of results with success rates

## Usage

```lua
local datamodelAddress = require("RobloxDatamodelFinder")
print("Final Datamodel address:", string.format("0x%X", datamodelAddress))

-- Use the address in your exploits/scripts
```

## Methods Used
- WaitingHybridScriptsJob via ScriptContext
- Fake DataModel pointer
- RenderJob direct reference
- VisualEngine pointer traversal
- DataModel Deleter pointer
- DataModelJob direct reference
- Jobs pointer traversal

