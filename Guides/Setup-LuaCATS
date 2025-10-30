# Setting Up LuaCATS

_Have orange squiggly lines everywhere, or is autocomplete not working for you?_

[**Playdate LuaCATS**](https://github.com/notpeter/playdate-luacats), the Lua Comments and Type System, smoothly integrates with the Lua Language Server installed via the VSCode Extension or otherwise.

The setup thankfully is pretty easy with the right instructions. Just follow these three steps:

**1. Download the project**, by simply running `git clone https://github.com/notpeter/playdate-luacats` in a command line or terminal. (To navigate to your preferred location, use the `cd` command - or just move the folder after having copied it). On MacOS, that might be your `~/Developer` folder, while on Windows, that might be your `~/Documents` folder. Just remember to save the path for the next step.

**2. Add a `.luarc.json` file into your project**. Put it at the top level, so that might look like:

```
(your project name)
├── .vscode
│   ├── tasks.json
│   ├── launch.json
├── source
│   ├── pdxinfo
│   ├── main.lua
│   .luarc.json <--- Add file to project top-level folder
```

**3. Paste in the following body:**.

```json
{
  "$schema": "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
  "diagnostics.globals": ["import"],
  "format.enable": true,
  "format.defaultConfig": {
    "indent_style": "space",
    "indent_size": "4"
  },
  "runtime.builtin": { "io": "disable", "os": "disable", "package": "disable" },
  "runtime.nonstandardSymbol": [
    "+=",
    "-=",
    "*=",
    "/=",
    "//=",
    "%=",
    "<<=",
    ">>=",
    "&=",
    "|=",
    "^="
  ],
  "runtime.version": "Lua 5.4",
  "workspace.preloadFileSize": 1000,
  "workspace.library": ["/PATH/TO/YOUR/LUACATS"]
}
```

**...And change the `workspace.library` location to the LuaCATS folder on your computer**, e.g.:

`"workspace.library": ["/Users/peter/code/playdate-luacats"]`

or, for Windows:

`"workspace.library": ["C:\Users\peter\Documents\playdate-luacats"]`

_Make sure you write the **full path** to the LuaCATS library or else it might not work._

#####...And that's it!

Your project should detect autocomplete with `playdate.` and the incorrect highlighting on functions like `function playdate.update()` should be gone.
