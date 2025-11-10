##### _This guide is inspired by the video [linked here](https://www.youtube.com/watch?v=RUEGGXtdV-Q)._

# Creating your first sprite

_So... you've got your Playdate development setup up and running. Hopefully, you've added Type-checking support with LuaCATS as well. That means you're ready to start creating your first sprite!_

The basics of Playdate and other 2D game development orients around **sprites**. Sprites can represent anything from a simple image, with a position (an x- and y-coordinate) to a more complex object with lots of properties - which is how the Playdate SDK uses it.

Thus, we'll be able to use our first Sprite to do a decent amount of things, as we'll see in this and further tutorials.

##### In the Playdate SDK, Sprites can:

- Be **added and removed** from the screen
- **Move around** on the screen (including outside the screen bounds)
- Be placed **in front or behind** other sprites (using the Z-Index)
- **Stretch, scale and rotate** as desired
- Handle **collision detection**, including with collision groups or tags.
- Handles **drawing and re-drawing automatically** (or manually if desired).
- Display an animator, custom draw function, tileset or stencil pattern (instead of an image).
- _...And can be customized to do anything you can code!_

So, let's get started.

### First Steps:

In your `main.lua` file, you're gonna want to import the base object library. Add this line (if not already present) to the top of your file:

`import "CoreLibs/object"`

Then, you'll want to implement a basic structure for your game's execution, which will look like the following:

- **Initialize** -> The "initialization" code will run once when your game begins. This is where you want to set up your game before it starts playing.

- **Update** -> The "update" function will then run once per frame, so 30 times a second by default. The rest of your game happens here.

Add the following code to your `main.lua`:

```lua
-- Your Initialization/setup code here


function playdate.update()
    -- Your Update/play code here

end
```

`playdate.update` gets called by the Playdate SDK so you don't need to worry about calling it yourself.

## Adding a sprite

Start by creating a folder called `assets` **inside of `source`** and adding the [**following image**](/Materials/Your-first-sprite/ship.png) to it.

Your project should look like this:

```
(your project name)
├── .vscode
│   ├── tasks.json
│   ├── launch.json
├── source
│   ├── assets
│   │   ├── ship.png <-- Just Added
│   ├── pdxinfo
│   ├── main.lua
│   .luarc.json
```

Now, you can create your first sprite by referencing this image. Add the following line to your code in the _Initialization_ section:

```lua
-- Your Initialization/setup code here

local imageShip = playdate.graphics.image.new("assets/ship")
local spriteShip = playdate.graphics.sprite.new(imageShip)
```

So you've loaded the image, and put it into a sprite!

Now we need to tell the Playdate to add it to the screen, and somewhere visible, too. Add these lines after the ones you've just added:

```lua
spriteShip:moveTo(200, 120) -- Place the ship in the center of the screen
spriteShip:add() -- Add the ship to the screen!
```

**Last but not least!** Let's tell the Playdate to **update all the sprites** in the `playdate.update()` function, or else it won't draw anything to screen!

```lua
function playdate.update()
    -- Your Update/play code here

    -- Update (and draw) all the sprites!
    playdate.graphics.sprite.update()
end
```

...and you should be good to go!

Press the "Run" or "Run and Debug" in your IDE and watch your little sprite be added to the screen!

### Adding some movement

Feeling more ambitious already? Alright, let's add some movement to our little fella.

For this, we're gonna use the crank, cause developing for the Playdate is _all about 'dat Crank_!

The movement code will be going into `playdate.update()` as that's where the console will:

1. Read the input from the device,
2. Calculate the movement,
3. And move or otherwise transform the sprite.

So, let's start by reading the input:

```lua
function playdate.update()
    -- Your Update/play code here

    -- vvvvvvv == Add these lines ==

    -- Gets the crank direction in degrees.
    local crankDirection = playdate.getCrankPosition()

    -- Set the rotation of the sprite
    spriteShip:setRotation(crankDirection)

    -- ^^^^^^^^ ====================

    -- Update (and draw) all the sprites!
    playdate.graphics.sprite.update()
end
```

So you can now rotate your sprite! Let's make it move in the direction it's facing by pressing the **A Button**.

```lua
function playdate.update()
    -- Your Update/play code here

    -- Gets the crank direction in degrees.
    local crankDirection = playdate.getCrankPosition()

    -- Set the rotation of the sprite
    spriteShip:setRotation(crankDirection)

    -- vvvvvvv == Add these lines ==

    -- If-statement to detect if button A is pressed
    if playdate.buttonIsPressed(playdate.kButtonA) then
        -- Calculate the movement in the direction the ship is facing

        local speedMovement = 5
        local crankDirectionRadians = math.rad(crankDirection)

        local velX = math.cos(crankDirectionRadians)
        local velY = math.sin(crankDirectionRadians)

        -- Move the ship!

        spriteShip:moveBy(
            speedMovement * velX,
            speedMovement * velY
        )
    end

    -- ^^^^^^^^ ====================

    -- Update (and draw) all the sprites!
    playdate.graphics.sprite.update()
end
```

So, just to break it down, what we did was:

- Use **`math.rad()`** to convert the crank direction into _radians_ instead of degrees. (The same as doing `/ 360 * 2 * math.pi`)
  - The reason we do this is because `math.cos()` and `math.sin()` expect radians and not degrees. Sad, I know.
- Get the **"X" and "Y" component** from the angle that the crank is facing, using `math.cos()` and `math.sin()`.
- Move the ship by `velocity` x each direction!

Feel free to play around with different velocities. Notice how your ship can fly off-screen without any problems :)

### Final step: Add screen-wrapping

Let's implement a simple screen-wrapping by adding checks for the ship's position, and moving it to the opposite side if it's gone off-screen.

Add the following underneath the previous lines:

```lua
function playdate.update()
    -- Your Update/play code here

    -- Gets the crank direction in degrees.
    local crankDirection = playdate.getCrankPosition()

    -- Set the rotation of the sprite
    spriteShip:setRotation(crankDirection)

    -- If-statement to detect if button A is pressed
    if playdate.buttonIsPressed(playdate.kButtonA) then
        -- Calculate the movement in the direction the ship is facing

        local speedMovement = 5
        local crankDirectionRadians = math.rad(crankDirection)

        local velX = math.cos(crankDirectionRadians)
        local velY = math.sin(crankDirectionRadians)

        -- Move the ship!

        spriteShip:moveBy(
            speedMovement * velX,
            speedMovement * velY
        )
    end

    -- vvvvvvv == Add these lines ==

    -- Wrap the ship around the screen if it goes too far

    if spriteShip.x < -10 then
        spriteShip:moveTo(410, spriteShip.y)
    elseif spriteShip.x > 410 then
        spriteShip:moveTo(-10, spriteShip.y)
    end

    if spriteShip.y < -10 then
        spriteShip:moveTo(spriteShip.x, 250)
    elseif spriteShip.y > 250 then
        spriteShip:moveTo(spriteShip.x, -10)
    end

    -- ^^^^^^^^ ====================

    -- Update (and draw) all the sprites!
    playdate.graphics.sprite.update()
end

```

##### Congratulations! You should have your first sprite moving and wrapping around the edges of the screen!

Pretty exciting, huh?

Imagine all the other cool things you can add in there – baddies, obstacles, powerups, and more!

Stay tuned for more **Playdate Guides**, [**request a topic**](TODO.md) or [**submit your own!**](Contributing.md)
