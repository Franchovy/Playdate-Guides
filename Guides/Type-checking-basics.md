##### _So, you're sick of seeing squiggly lines all over your project? Not to worry, your guide to LuaCATS is here!_

# Type Checking Basics

**Lua is a language where any variable can be assigned any value**. That means defining types is entirely optional, and the type checking system will only go as far as you tell it to. Thankfully, the basics are pretty easy to grasp, so in here we'll try to cover the essentials of getting type checking to work in a Playdate project.

\_Please have a look at the [LuaCATS resource](https://luals.github.io/wiki/annotations/) for additional details on how to use annotations/comments in Lua, and [LuaCATS for Playdate](https://github.com/notpeter/playdate-luacats/) for details about type definitions and usage relating to the Playdate SDK.

### Direct Assignments

The easiest way to use LuaCATS comes right out of the box. It will automatically detect these **direct assignments** and will autocomplete methods and fields for you.

Examples of direct assignments:

```lua
local someString = "Hello there!"

local someTable = {
    say = "Hello there!"
}

function someTable.someFunction() end

local someSprite = playdate.graphics.sprite.new()
```

If I then type:

- `someString:`, I get auto-complete suggestions such as `gmatch`, `find`, `format`, `lower`, which are all standard lua functions on the `string` library.
- `someTable.`, I get the suggestion for `say`, which is a field that LuaCATS has detected in the table, and `someFunction`, which has been defined as a method on the same table.
- `someSprite.` or `someSprite:`, I get `playdate.graphics.sprite` values and functions respectively, such as `collisionResponse`, `add`, and so on.

#### Then why aren't my classes working?

### Defining classes

Let's quickly cover what's probably the most common and most practical use case of LuaCATS for Playdate.

When you define a class using the Playdate SDK, you typically write:

```lua
class("MyFirstSprite").extends(playdate.graphics.sprite)
```

What this does is it defines a new _table_ named `MyFirstSprite` in the _global table_ (`_G`) which you'll be able to refer to from that point on through the class name.

However, LuaCATS **only detects _direct assignments_**, not this fancy stuff.

Because the variable is being assigned _inside_ the `class` method, LuaCATS has no idea what has just happened behind the scenes.

Therefore, the simple solution is to **manually tell LuaCATS what has happened**.

We have to perform 1) a **direct assignment** so LuaCATS recognizes something has happened and 2) give it the expected type **explicitly**:

```lua
---@class MyFirstSprite : _Sprite
MyFirstSprite = class("MyFirstSprite").extends(playdate.graphics.sprite) or MyFirstSprite
```

**Notice how we used `_Sprite` instead of `playdate.graphics.sprite` for the type definition.**

This work-around does the following:

- `---@class MyFirstSprite : _Sprite` defines the type explicitly to be a _class_ that inherits from _`playdate.graphics.sprite`_.
  - The reason we use `_Sprite` instead of `playdate.graphics.sprite` is that `_Sprite` has explicitly defined the _instance_ properties and methods, while `playdate.graphics.sprite` is for the _static_ or _class-level_ properties and methods.
  - For example, if you do `---@class MyFirstSprite : playdate.graphics.sprite`, you'll find that sprite fields such as `x`, `y`, `width`, and `height` are not getting recognized, because they don't exist at the _class_ level, just at the _instance_ level.
- We then performed a **direct assignment** using `MyFirstSprite =`
- `class("MyFirstSprite").extends(playdate.graphics.sprite)` creates the class as usual...
- ...but because it doesn't return a value (i.e. it returns `nil`), we add the `or MyFirstSprite` work-around that will return the newly created table and use it for the direct assignment.

If that seems like too much, you can create your own `class` function:

```lua
--- Class - creates a class object globally.
--- @param name string name of the class
--- @param parentClass? table (optional) parent class to inherit
--- @return table NewClass class instance.
function Class(name, parentClass, ...)
    local newClass = class(name, ...)
    newClass.extends(parentClass)

    return _G[name]
end
```

And use it like this:

```lua
---@class MyFirstSprite : _Sprite
MyFirstSprite = Class("MyFirstSprite", playdate.graphics.sprite)
```

You still have to write the class name 3 times. Up to you if you think it's worth it.

**But congratulations! Now your classes are way easier to use since type-checking is properly detecting them!**

### Defining variables

Another common use case is defining **variables**. We'll go over _global/local variables_, as well as _fields/properties_.

#### Global & Local variables

Direct assignments usually detect a variable if it's given a value:

```lua
--- Type checking will correctly infer that this is a number.
local someVariable = 3
```

...But what if you want to define a local value that gets assigned later?

Then you can add the type like this:

```lua
---@type number?
local someVariable

---@type number? - Also works with globals.
SomeGlobalVariable

local function assignMyVar()
    someVariable = 3

    SomeGlobalVariable = 9
end
```

Now the type checker knows what that variable is, even without an assignment! The nice thing is that if you assign another type to someVariable, the type checker will also give you a head's up.

The `?` (question mark) marks the type as **optional**, which is equivalent to saying `number | nil` (number or nil). That means if you want to use the variable, you'll have to ensure it's not nil or the type-checker will detect is as a problem. More on that in the section [below](#dealing-with-optional-variables).

#### Properties/Fields (for tables and classes)

Usually, by using tables and classes, the direct assignments cover what the type-checker needs to know:

```lua
---@class MyFirstSprite : _Sprite
MyFirstSprite = class("MyFirstSprite").extends(playdate.graphics.sprite) or MyFirstSprite

function MyFirstSprite:init()
    MyFirstSprite.super.init(self)

    -- We define `self.awesomeField` here to be a number.
    self.awesomeField = 1
end

function MyFirstSprite:update()
    -- No complaints: `self.awesomeField` is known to be a number.
    self:moveBy(self.awesomeField, 1)
end
```

Similarly for tables:

```lua
local someTable = {
    -- This is detected as part of the assignment.
    awesomeField = 1
}

-- LuaCATS knows someTable.awesomeField is a number.
playdate.graphics.setDrawOffset(someTable.awesomeField, 0)
```

...But what if you're not initializing the value immediately?

In that case, we can use the `---@field` annotation for both classes and tables.

```lua
-- Sprites example:

---@class MyFirstSprite : _Sprite
---@field awesomeField number? - This explicitly defines the variable.
MyFirstSprite = class("MyFirstSprite").extends(playdate.graphics.sprite) or MyFirstSprite

-- No need to define "awesomeField" in the :init() call.

function MyFirstSprite:update()
    -- Checking if the value is nil before using it.
    if self.awesomeField then
        -- No complaints: `self.awesomeField` is known to be a number.
        self:moveBy(self.awesomeField, 1)
    end
end

-- Tables example:

---@field awesomeField number? - Explicitly defining it here!
local someTable = {}

-- LuaCATS knows someTable.awesomeField is an OPTIONAL number.
-- ...So we check if the value is nil before using it.
if someTable.awesomeField then
    -- No complaints: `self.awesomeField` is known to be a number.
    playdate.graphics.setDrawOffset(someTable.awesomeField, 0)
end
```

**Additional Note:**

Adding a function on a table or class like this (which you rarely have to do since it detects it when you write one) should be done equally with the `@field` annotation, and giving it the type `fun`, like this:

```lua
---@class MyFirstSprite : _Sprite
---@field someFunction fun(self:MyFirstSprite, myParam: number) : string
MyFirstSprite = class("MyFirstSprite").extends(playdate.graphics.sprite) or MyFirstSprite
```

That would tell LuaCATS you have a function on `MyFirstSprite` named `someFunction`, with the implicit `self` parameter and one `number` parameter `myParam`, and which returns a `string` value.

You can now use it like this:

```lua
function MyFirstSprite:update()
    -- Correctly detects parameters and assigns return value.
    -- Using ":" (colon) implicitly hands over `self` as the first parameter.
    -- The second parameter is then detected to be a number.
    local test = self:someFunction(1)
    -- `test` is detected to be a string value from the function return.
    print(test)
end
```

However, doing it like this, you're telling the type-checker that a function exists. _If it doesn't, then that's your problem!_ Use it when appropriate, in most cases the type checker can base itself on **function definitions**, which is our next topic.

### Function Definitions

The second-last handy LuaCATS feature is **function definitions**.

Functions have two important sets of values: **parameters** and **return values**.

Defining these (and their appropriate type) is relatively easy:

```lua
local function myTestFunction(param1, param2)
    return "value1", testValue2
end
```

In a lot of cases, there won't be explicit types for the type-checker to know what's happening, especially on the _parameter_ side of things. For the return value, for example, it can detect a `string` as the first return value, but not the type of the second.

(It will tell you that `myTestFunction` is a functon that expects 2 arguments and returns 2 values, which is still nice.)

Adding more specific types looks like this:

```lua

--- Some comment about the function. Super interesting!
---@param param1 number
---@param param2 string
---@return string
---@return number
local function myTestFunction(param1, param2)
    return param2 .. " there!", param1 + 1
end

-- Prints "Hello there!	2"
print(myTestFunction(1, "Hello"))
```

If you want to provide any additional explanation for each of the arguments, or more complex types, you can.

### Dealing with optional variables

The `?` (question mark) marks the type as **optional**, which is equivalent to saying `number | nil` (number or nil). That means if you want to use the variable, you'll have to ensure it's not nil or the type-checker will detect is as a problem.

```lua
---@type number?
local someVariable

local function assignMyVar()
    someVariable = 3
end

local function someTest()
    --- LuaCATS complains here: "Cannot assign `number?` to parameter `integer`."
    playdate.graphics.setDrawOffset(someVariable, 0)
end
```

So we can check that the variable is not `nil` by adding a check **in the code**. LuaCATS will automatically see that we checked:

```lua
local function someTest()
    -- A "Guard" statement only runs the function if the variable in use is not nil.
    if not someVariable then
        return
    end

    --- No more complaints.
    playdate.graphics.setDrawOffset(someVariable, 0)
end
```

Or, if we know **for sure** that the variable is not `nil`, or you want a warning (as a developer! Not for end users!) that the variable is `nil`, you can use an **`assert` statement**:

```lua
local function someTest()
    assert(someVariable, "This is my error message: Your variable is NIL!!!")

    --- No more complaints.
    playdate.graphics.setDrawOffset(someVariable, 0)
end
```

LuaCATS correctly notices that if `someVariable` is `nil`, then the code will throw an error and the rest of the function will not execute. Therefore, you're good to continue.

Lastly, you can **ignore** the optional status of the variable altogether by just telling the type-checker what you want. In most cases this is _not_ the right path, but it's useful to know anyways.

```lua
local function someTest()
    ---@cast someVariable number
    playdate.graphics.setDrawOffset(someVariable, 0)
end
```

This tells LuaCATS to reduce `someVariable` to only be a `number`, not a `number?` (optional number). By doing this, you might be lying to LuaCATS, in which case it won't be able to help you any further... so only do it if you know for sure that the variable is not `nil`!
