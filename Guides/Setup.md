# Setup / Your first game

Start by creating a new folder somewhere on your computer. If I have to teach you that, I think we better stop here.

In VSCode/VSCodium/\<insert your IDE here\>, use "Open Folder" to open up that folder as your project.

**Create a new directory named `source`**. This will be the basis for all the files that will end up in your Playdate game.

Inside `source`, **create a new file named `pdxinfo`**. Paste in the following contents:

```
name=My First Game
author=Your Name Here
description=Mom, my first game is here!!
bundleID=io.mybrand.myfirstgame
version=0.0.1
buildNumber=1
```

You can change all the values after the "=" to fit your creative inspiration. Just don't change the left-hand-side of the "=" or you'll confuse the machine overlords.

Then, create your first programming file by **creating a file in `source` called `main.lua`**. Your project should look like this:

```
(your project name)
├── source
│   ├── pdxinfo
│   ├── main.lua
```

And in terms of files, that's all you need!

...if you want to run `pdc` in the command line, or if you're using Nova. But for VSCode/VSCodium users, we'll need an extra piece:

In the top-level of your project, **create a folder called `.vscode`**. (Note the "dot" at the beginning).

Inside the folder, create two files and copy their contents from below:

1. First, **create a file called `tasks.json`**. This is basically a set of possible things for VSCode to do that will be used in a sec.

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "type": "pdc",
      "problemMatcher": ["$pdc-lua", "$pdc-external"],
      "label": "Playdate: Build"
    },
    {
      "type": "playdate-simulator",
      "problemMatcher": ["$pdc-external"],
      "label": "Playdate: Run"
    },
    {
      "label": "Playdate: Build and Run",
      "dependsOn": ["Playdate: Build", "Playdate: Run"],
      "dependsOrder": "sequence",
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```

2. Second, **create a file called `launch.json`**. This file tells what VSCode should do when you press "Run".

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "playdate",
      "request": "launch",
      "name": "Playdate: Debug",
      "preLaunchTask": "${defaultBuildTask}"
    }
  ]
}
```

Now, your project should look like this:

```
(your project name)
├── .vscode
│   ├── tasks.json
│   ├── launch.json
├── source
│   ├── pdxinfo
│   ├── main.lua
```

Ok, _NOW_ let's write some code!

Open up `main.lua` and type out:

```lua
import "CoreLibs/object"
```

That's your first "import" statement, meaning you're telling Lua to include all the basic Playdate functionality. **You need this line for your game to work on Playdate.**

Then, write the following:

```lua
function playdate.update()
    print("Hello World")
end
```

I know, basic code example. But this code runs in the **update loop** which should run once-per-tick, or 30 times per second by default on the console.

Now, navigate to the "Run and Debug" tab on the left and hit "Run", and see if your Playdate Simulator opens and the console spits out a few hundred "Hello World"'s to announce its coming into existence in this universe.

If you're all clear, and [you already have LuaCATS installed](Guides/Setup-LuaCATS), then you can navigate to **[your first sprite tutorial](Guides/Your-first-sprite.md)** to start adding some actual fun stuff into your game.
