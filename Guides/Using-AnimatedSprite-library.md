# AnimatedSprite basics

_A simple example outlining the essential functionality of using the AnimatedSprite library._

### Resources:

- **[1-bit-bot-character by Poppy Entertainment](https://poppy-entertainment.itch.io/1-bit-bot-character)**
- **[AnimatedSprite Library by Whitebrim](https://github.com/Whitebrim/AnimatedSprite/issues)**

### Setup:

1. Download and unzip the 1-bit-bot-character files. You will find an imagetable (sprite_sheet.png) as well as an .asesprite file.
2. Have a new project ready (copy the **[Template](Starter-Template)**), optionally with [**LuaCATS**](Guides/Setup-LuaCATS.md) enabled.

### Importing the Library

So, our AnimatedSprite project starts with... well... importing AnimatedSprite so we can use it. Navigate to **[the library link](https://github.com/Whitebrim/AnimatedSprite/issues)**, and let's take a better look at its contents.

Among some automated tests, documentation, and some luacheck files, there's our prized [**`AnimatedSprite.lua`**](https://github.com/Whitebrim/AnimatedSprite/blob/master/AnimatedSprite.lua) file. Navigate to it, and copy the entirety of its contents. Yup, that's the easiest way to import it.

In your project, inside the **`source`** folder, create a folder named **`libs`**. This will be where you can store all your imported libraries.

In the **`libs`** folder you just created, create a new file called **`AnimatedSprite.lua`** (like the one you just saw), and paste the contents of the library file into there.

The final step is in your **`main.lua`** file: simply add the following line, under the `import "CoreLibs/..."` statements.

```lua
import "libs/AnimatedSprite"
```

...And **there you go!** You have the library in your project and ready to run.

### Adding LuaCATS Support Manually - Optional, but Recommended.

So, you're quickly going to find out if you continue this tutorial that using AnimatedSprite proper LuaCATS is quite painful. Supposedly _LuaCheck_ is the default supported way to have LuaCATS working with the library, but doing our quick-and-dirty import, we don't have a way to enable it (at least to my knowledge).

But worry not, the fix is quick to do.

In the **`AnimatedSprite.lua`**, you'll need to add two lines right above the `class` definition, near the top of the file (on/around line 16).

```lua

-- vvvvvvv == Add these lines

---@class AnimatedSprite : _Sprite
AnimatedSprite = {}

-- ^^^^^^^ == Add these lines

class("AnimatedSprite").extends(gfx.sprite)
```

The comment + the placeholder table will tell LuaCATS that all those functions later in the file should get attached to this table called "AnimatedSprite". That way, when you use the class, all the `AnimatedSprite` functions + the `playdate.graphics.sprite` functionality will be correctly exposed.

There's a helpful addition you can do as well right underneath, which is to add a `return` type to the `AnimatedSprite.new()` function. That will come in handy in our tutorial.

Simply add this line right above the function definition, but below the other comments:

```lua
---@param imagetable table|string actual imagetable or path
---@param states? table If provided, calls `setStates(states)` after initialisation
---@param animate? boolean If `True`, then the animation of default state will start after initialisation. Default: `False`
---@return AnimatedSprite <<<<< == ADD THIS LINE
function AnimatedSprite.new(imagetable, states, animate)
    return AnimatedSprite(imagetable, states, animate)
end
```

And there you go! You're ready to get started and it should be smooth sailing from here.

### Importing the Spritesheet

Firstly, let's create a folder underneath **`source`** called **`assets`**.

So, **Animated-Sprites** use the Playdate SDK's **[imagetables](https://sdk.play.date/#C-graphics.imagetable)**. If you want to use an imagetable in your project, you need to give it a **specific naming format**.

That format looks like the following:

`<imagetable name>-table-<cell width>-<cell height>`

Where:

- "imagetable name" is whatever you want it to be
- `-table-`is the standard format that needs to be included, followed by:
- "cell width", which is the width in pixels of each image cell in the spritesheet (so 72 for our example)
- "cell height", which is the height in pixels of each image cell in the spritesheet (so 72 for our example)

So, for our example, we'll need to rename our spritesheet (sprite_sheet.png) to:

`sprite_sheet-table-72-72.png`

...and drop it in the **`assets`** folder.

_You can find the example spritesheet in the **[Materials](/Materials/Using-AnimatedSprite-library/sprite_sheet.png)** section as well. However, you need to rename it, cause you shouldn't forget to do that in the future!_

**Now you're ready to create your first Animated Sprite!**

### Creating your first AnimatedSprite

Let's start by creating the sprite using the imagetable. Add these lines to your initialization code:

```lua

-- Your Initialization Code here

local imagetableSprite = assert(playdate.graphics.imagetable.new("assets/sprite_sheet"))
local myAnimatedSprite = AnimatedSprite.new(imagetableSprite)

```

Note how **you don't need to include the `.png`** at the end of the file name.

Also note the small trick when importing the imagetable: Although the `assert()` statement can be omitted, it will ensure that when the code runs, the `imagetable` will be checked for `nil` (if it exists), and will throw and error if there was an issue creating the table.

**So, you've created your first sprite.** Let's now add it to the screen!

For that, we'll do the same as a usual sprite:

```lua
-- Your Initialization Code here

local imagetableSprite = assert(playdate.graphics.imagetable.new("assets/sprite_sheet"))
local myAnimatedSprite = AnimatedSprite.new(imagetableSprite)

-- vvvvvvv == Add these lines

myAnimatedSprite:moveTo(200, 120)
myAnimatedSprite:add()

-- ^^^^^^^ == Add these lines
```

In addition to that, we're gonna add the **default state** of the animated sprite, which will show the _`"idle"`_ animation.

```lua
-- Your Initialization Code here

local imagetableSprite = assert(playdate.graphics.imagetable.new("assets/sprite_sheet"))
local myAnimatedSprite = AnimatedSprite.new(imagetableSprite)

-- vvvvvvv == Add these lines

myAnimatedSprite:addState("idle", 1, 6).asDefault()

myAnimatedSprite:playAnimation()

-- ^^^^^^^ == Add these lines

myAnimatedSprite:moveTo(200, 120)
myAnimatedSprite:add()
```

_I've chosen to add the lines above the `moveTo()` and `add()`, but you can put them underneath. It's just for clarity that I do the setup first, and only then I add it to the screen._

Oh, and don't forget to add the `playdate.graphics.sprite.update()` to your `playdate.update()` function. _Or else you won't see anything and you'll be left scratching your head :\)_

```lua
function playdate.update()
    -- Your gameplay loop code here
    playdate.graphics.sprite.update()
end
```

**And that's it!** You've got your (_admittedly very fast-moving and tiny_) AnimatedSprite on screen!

Let's quickly break down the two lines above:

- In the `addState()` function, we provided the sprite with the first state, called `"idle"`, as well as the **frames** in the imagetable which correspond to the animation, that is, frames 1-6 (inclusive).
- We also **set the state as the default** state, which means we did not need to explicitly tell the sprite to play it. Instead, we just told the sprite to play its animation, regardless of what state it has.

We could have alternatively specified the two lines in one:

```lua
myAnimatedSprite:addState("idle", 1, 6, {}, true).asDefault()

-- myAnimatedSprite:playAnimation() -- We don't need this line anymore.
```

By specifying the `animate` param as true, we told the sprite to immediately start animating when we set that state.

The empty table (`{}`) is the `params` table, we'll see that right now.

### The Params Table

**My sprite moves too fast! What do I do?**

So, as you might have seen, our sprite is moving up and down at 30FPS, so that means it goes through the "idle" animation 5 times per second... which is quite fast for an "idle" state :\)

Thankfully, we have the **`params`** table that can help us here.

Let's specify two things to start:

- Let's make the sprite **animate slower**. (12 FPS, as intended by the sprite's creator)
- Let's make the sprite **bigger**. (So we can admire it in all its glory!!)

That means we'll start by specifying the following params:

```lua
{
    tickStep = 5, -- This means the animation frame changes every 5 ticks.
    xScale = 2,
    yScale = 2 -- Yep, we have to specify the x- and y-scale separately.
}
```

Enter this table in the `addState()` method, instead of the empty table (`{}`) we specified earlier.

```lua
myAnimatedSprite:addState("idle", 1, 6, {
    tickStep = 5, -- This means the animation frame changes every 5 ticks.
    xScale = 2,
    yScale = 2 -- Yep, we have to specify the x- and y-scale separately.
}, true).asDefault()
```

And if you run the code, you'll see **our sprite looks a lot better!**

_If you want to see all the different params, you can refer to the contents of the **`addState()`** method in the `AnimatedSprite.lua` file. There, you'll find all the possible values with accompanying explanations._

### More States, More Params

**Let's take a look at adding more states.**

Once you have the basics, adding more states is easy. Let's start by adding every state configuration underneath the default one:

```lua
myAnimatedSprite:addState("idle", 1, 6, {
    tickStep = 5, -- This means the animation frame changes every 5 ticks.
    xScale = 2,
    yScale = 2 -- Yep, we have to specify the x- and y-scale separately.
}, true).asDefault()

-- vvvvvvv == Add these lines

myAnimatedSprite:addState("fire", 7, 13, { tickStep = 2, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("walk", 14, 25, { tickStep = 2, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("jump", 25, 28, { tickStep = 2, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("fall", 29, 33, { tickStep = 2, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("hit", 34, 38, { tickStep = 3, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("death", 39, 50, { tickStep = 2, xScale = 2, yScale = 2 })

-- ^^^^^^^ == Add these lines
```

And there you go! 7 states in total... _what a sprite!_ However, we need a way of actually **playing** the animations or our sprite will forever remain in the "idle" state!

Let's add some listeners for **button input** to the **update loop** to activate the different states.

Add these lines to your `playdate.update()` function:

```lua
function playdate.update()
    -- Your gameplay loop code here
    playdate.graphics.sprite.update()

    -- vvvvvvv == Add these lines

    if playdate.buttonJustPressed(playdate.kButtonA) then
        myAnimatedSprite:changeState("fire")
    elseif playdate.buttonIsPressed(playdate.kButtonUp) then
        myAnimatedSprite:changeState("jump")
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        myAnimatedSprite:changeState("walk")
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        myAnimatedSprite:changeState("hit")
    end

    -- ^^^^^^^ == Add these lines
end
```

So now you'll find you can **switch between all the different animation states** using the _Up, Right, B and A keys_ on the device!

...But something still isn't quite right.

We're looping through every animation as if our Sprite has _infinite ammo and infinite health_, and he doesn't even do the full `"jump"` animation!

In addition to that, there's no way of returning to the `"idle"` state, which is supposed to activate by default! (As long as you don't press any button)

Thankfully, we have some params that will help us out here. Let's take a look at the **`nextAnimation`** and **`loop`** param.

- **`nextAnimation`:** name of the animation to play **directly after this one ends.**
- **`loop`:**
  - true: should loop infinitely (which is by default).
  - false: don't loop at all.
  - Any number: the number of loops to play.

Let's implement both so that our sprite acts a little more fluidly.

Replace the `addState` functions to have the following configurations:

```lua
myAnimatedSprite:addState("idle", 1, 6, { tickStep = 5, xScale = 2, yScale = 2 }, true).asDefault()
myAnimatedSprite:addState("fire", 7, 13, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = "idle" })
myAnimatedSprite:addState("walk", 14, 25, { tickStep = 2, xScale = 2, yScale = 2 })
myAnimatedSprite:addState("jump", 25, 28, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = "fall" })
myAnimatedSprite:addState("fall", 29, 33, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = "idle" })
myAnimatedSprite:addState("hit", 34, 38, { tickStep = 3, xScale = 2, yScale = 2, nextAnimation = "idle" })
myAnimatedSprite:addState("death", 39, 50, { tickStep = 2, xScale = 2, yScale = 2, loop = false })
```

As you can see, we're looping back into the `"idle"` animation for most, except for the `"jump"` animation which leads into `"fall"`, and then into `"jump"`, and the `"death"` animation which stops on the last frame without looping or leading back to `"idle"`. (A bit more logical, right?)

Let's make it more fun by **adding a "lives" counter**, which will keep track of hits, and animate the "death" animation if the lives have run out.

First, add this line **above** `playdate.update()` (in your initialization code).

```lua

-- vvvvvvv == Add this line

local lives = 3

-- ^^^^^^^ == Add this line

function playdate.update()
```

...and then add these lines around our button-state checker:

```lua

function playdate.update()
    -- Your gameplay loop code here
    playdate.graphics.sprite.update()

    -- vvvvvvv == Add this line

    if lives > 0 then

    -- ^^^^^^^ == Add this line

        if playdate.buttonJustPressed(playdate.kButtonA) then
            myAnimatedSprite:changeState("fire")
        elseif playdate.buttonIsPressed(playdate.kButtonUp) then
            myAnimatedSprite:changeState("jump")
        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            myAnimatedSprite:changeState("walk")
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            -- myAnimatedSprite:changeState("hit") <<<<< == Remove this line

            -- vvvvvvv == Add these lines
            lives -= 1

            if lives > 0 then
                myAnimatedSprite:changeState("hit")
            else
                myAnimatedSprite:changeState("death")
            end

            -- ^^^^^^^ == Add these lines
        end

    -- vvvvvvv == Add these lines

    else
        if playdate.buttonIsPressed(playdate.kButtonA) then
            myAnimatedSprite:changeState("idle")

            lives = 3
        end
    end

    -- ^^^^^^^ == Add these lines
end
```

What we're doing here is:

1. **Adding a check** for **lives remaining**, and if there are more than 0, then **do the normal state check.**
2. **Adding a check** in the **B button** branch code, which will **subtract a life** and check whether to play the **`"hit"`** or the **`"death"`** animation.
3. Add a **reset** condition if the lives have been exhausted by **pressing A**, setting the state to **`"idle"`** and the **lives back to 3**.

_Hopefully that was manageable!_

But now you should see your sprite is much more lively!! He's almost ready to be put into a game... :\)

### Setting the "Flip" parameter

However, our sprite only can walk in one direction. Not a bad game design constraint, but as a tutorial I'm supposed to help _give_ you options, not _limit_ them (that's _your_ choice).

So, if you've taken a look at the long list of parameters in `addState()`, you might have seen `flip`, which allows you to flip an animation horizontally (so that your sprite looks in the other direction), or vertically.

However, using this parameter would be a pain, as we need to set it on **every** state held in the AnimatedSprite:

```lua
-- WAIT! - Don't do this!

myAnimatedSprite.state["idle"].flip = 1
myAnimatedSprite.state["walk"].flip = 1
myAnimatedSprite.state["jump"].flip = 1
-- ...and so on...
```

Note that the `flip` argument should be set to `1` or `0`, not `true` or `false`.

> _Additional Note: The `flip` argument uses the [`imageFlip`](https://sdk.play.date/3.0.0/#m-graphics.imgDraw) argument under the hood, which can be one of the following values:_
>
> - `0`, or `playdate.graphics.kImageUnflipped`: the image is drawn normally
>
> - `1`, or `playdate.graphics.kImageFlippedX`: the image is flipped left to right
>
> - `2`, or `playdate.graphics.kImageFlippedY`: the image is flipped top to bottom
>
> - `3`, or `playdate.graphics.kImageFlippedXY`: the image if flipped both ways; i.e., rotated 180 degrees

Which would be painful, given that we have 7 different states to manage.

Instead, we can use the **`globalFlip`** property directly on the sprite iself:

```lua
myAnimatedSprite.globalFlip = 1 -- Horizontal flip
```

...Much easier! Let's implement it by letting our sprite walk **left and right**.

Add these lines after the **right button press:**

```lua

        elseif playdate.buttonIsPressed(playdate.kButtonRight) then
            myAnimatedSprite:changeState("walk")

        -- vvvvvvv == Add these lines

            myAnimatedSprite.globalFlip = 0
        elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
            myAnimatedSprite:changeState("walk")
            myAnimatedSprite.globalFlip = 1

        -- ^^^^^^^ == Add these lines

        elseif playdate.buttonJustPressed(playdate.kButtonB) then


```

Now our sprite can walk left and right! You'll notice that the `globalFlip` value is **persisted across animation states**, which is convenient.

### Checking the currentState

One last trick I'll leave you with...

Our sprite is capable of taking hits while he's still animating through the `"hit"` animation. Our player can theoretically die instantly when he takes damage! Let's fix that now.

We're gonna check to make sure the player **isn't taking damage** before inflicting further damage on him.

Thankfully we can check the **`currentState`** value on our sprite to see if he's still in the **`"hit"`** state before applying the damage again.

Modify the `if` statement for the **B Button Press** to add the additional condition:

```lua
        elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
            myAnimatedSprite:changeState("walk")
            myAnimatedSprite.globalFlip = 1
        elseif playdate.buttonJustPressed(playdate.kButtonB)
                and myAnimatedSprite.currentState ~= "hit" -- <<<< == Add this line
        then
            lives -= 1

            if lives > 0 then
                myAnimatedSprite:changeState("hit")
            else
                myAnimatedSprite:changeState("death")
            end
        end

```

And now, your sprite will no longer **take hits** while still in the **hit** animation!

_Of course, in practice, you may want to run a cooldown timer instead of relying on the animation state. But that wouldn't give me much to teach you in this tutorial!_

### Bonus: Using an enum to avoid "magic strings"

Having random bits of strings like **`"idle"`** in the code is prone to making typos, e.g. the day you write `"ilde` the type-checker will not be able to save you and you'll spend 15 minutes (or more) trying to find the source of your mistake.

**To avoid that,** we can use an **enum-style table:**

```lua
local ANIMATON_STATES = {
    Idle = 'idle',
    Walk = 'walk',
    Fire = 'fire',
    Jump = 'jump',
    Fall = 'fall',
    Hit = 'hit',
    Death = 'death'
}
```

And we can use it like this:

```lua
-- When defining animation states:

myAnimatedSprite:addState(ANIMATION_STATES.Idle, 1, 6, { tickStep = 5, xScale = 2, yScale = 2 }).asDefault()
myAnimatedSprite:addState(ANIMATION_STATES.Fire, 7, 13, { tickStep = 2, xScale = 2, yScale = 2, nextAnimation = ANIMATION_STATES.Idle })

-- When changing states:

myAnimatedSprite:changeState(ANIMATION_STATES.Fire)

-- Checking for state:

if myAnimatedSprite.currentState == ANIMATION_STATES.Idle then
    -- ...
end
```

I'll let you swap out the "magic strings" in the code for a real enum so you can see how the type-checker assists you in doing so.
