# Adding Multiple Inheritance

So, you've fully converted to the dark side. You're sick of having 14 superclasses that have nothing to do with each other and want to directly inherit from the 6 of those 14 superclasses.

Well, that's great. Inheritance trees can get messy if you're not careful. And Lua's [inheritance](./Lua-inheritance-explained.md) is super simple, so we can easily get around the Playdate SDK's limitations and add what you're here for... _multiple inheritance_.

### Trade-offs

Remember something when you're using the following code. The `__index` method is a lookup-method that will run everytime you check a value on a table that is `nil`.

For example, when you run `mySprite:add()`, the `add` function on `mySprite` is actually `nil`, and it's only thanks to the metatable's `__index`, which points to its parent class, that the `add` function is returned from `playdate.graphics.sprite`.

_No idea what this means? Read up on the Guide under **[Lua inheritance explained](./Lua-inheritance-explained.md)**._

Therefore, it's important to keep in mind, when we're adding multiple-inheritance, the **number of checks** our code needs to do in order to find a function in a parent class. If a lot of checks need to be run, then it could potentially slow our game down.

_With great power comes great lag spikes (if you're not careful)._

### Implementation 1: Basic multiple inheritance

_Thank you @matt for the [inspiration](https://devforum.play.date/t/lua-oop-mixin-support-supplements-corelibs-object/333) for this code example. This specific example also takes from the [Lua book's multiple-inheritance guide](https://www.lua.org/pil/16.3.html)._

```lua
import "CoreLibs/sprites"

-- This is our multiple-inheritance-defining method. It's defined on "Object" which is the base inheritance object when using "CoreLibs/object" or "CoreLibs/sprites" - therefore all objects created with class(..).extends() inherit from it.
function Object:implements(module)
    -- Check if modules have already been defined or not.
    if not self.__modules then
        -- Set up the modules table
        self.__modules = {}

        -- Fetch the metatable for this object
        local metatable = getmetatable(self)

        -- Redefine the __index functionality:
        -- Instead of a single table, we are defining a function.
        -- The function gets a table (which would be the same as "self") and a "key", which is the value to look up.
        function metatable.__index(tbl, key)
            -- We iterate over all the modules in the table.
            for i = 1, #tbl.__modules do
                -- We check if the module has a value under the "key"
                local v = tbl.__modules[i][key]

                -- If found, we return the value.
                if v then return v end
            end

            -- Else, we fall back on parent class.
            local v = tbl.super and tbl.super[key]
            return v
        end
    end

    -- Finally, we add the module to the list of modules.
    table.insert(self.__modules, module)
end

-- Create a test module

local TestModule = {}

function TestModule:printTest()
    print("Testing!")
end

-- Create a Sprite / test object

---@class MyClass : _Sprite
MyClass = class("MyClass").extends(playdate.graphics.sprite) or MyClass

-- Test sprite/object inherits from our module
MyClass:implements(TestModule)

MyClass.printTest() -- prints "Testing!"

-- Also works for instances:
local instance = MyClass()

instance.printTest() -- prints "Testing!"
```

You can now add as many modules as you want using the `:implements()` function.

However, keep in mind that the more modules you add, the more checks lua needs to perform for each parent-class or module call.

#### Example: Multiple inheritance slowing things down

Using the above, we can compare an instance where there are 4 modules implemented versus an instance with no modules.

This highlights how the `__index` checks for every function call that ultimately needs to go to the parent class will get slowed significantly.

```lua

-- Class 1: 4 Modules

---@class MyClass1 : _Sprite
MyClass1 = class("MyClass1").extends(playdate.graphics.sprite) or MyClass1

-- We simply add the test module multiple times for demonstration purposes.
MyClass1:implements(TestModule)
MyClass1:implements(TestModule)
MyClass1:implements(TestModule)
MyClass1:implements(TestModule)

-- Create an instance of Class 1.
local instance1 = MyClass1()

-- Class 2: No modules.

---@class MyClass2 : _Sprite
MyClass2 = class("MyClass2").extends(playdate.graphics.sprite) or MyClass2

-- Create an instance of Class 2.
local instance2 = MyClass2()

function playdate.update()
    -- Run a function belonging to the parent class (playdate.graphics.sprite.add), multiplied by 10000 to produce a mesurable output.

    -- Class 1 / With multiple inheritance
    sample("With Multiple Inheritance:", function()
        for i = 1, 10000 do
            instance1:add()
        end
    end)

    -- Class 2 / Without multiple inheritance
    sample("Without Multiple Inheritance:", function()
        for i = 1, 10000 do
            instance2:add()
        end
    end)
end
```

Output:

```
With Multiple Inheritance:	avg: 27ms	low: 26	high: 27
Without Multiple Inheritance:	avg: 7ms	low: 6	high: 7
```

So you can see that the multiple inheritance slows down the code almost by 4x in the worst case scenario.

A simple solution here would be flipping the module code such that the `super` is checked first, and `__modules` second.

Here's a snippet of the modified `Object:implements` function:

```lua
        function metatable.__index(tbl, key)
            -- Check super class first
            local v = tbl.super and tbl.super[key]
            if v then return v end

            -- Check modules second.
            for i = 1, #tbl.__modules do
                local v = tbl.__modules[i][key]

                if v then return v end
            end
        end
```

This simple switch assumes that we will more often check for super-class functionality instead of modules. Indeed, if that is the case, then we find the lookup time is significantly reduced:

```
With Multiple Inheritance:	avg: 11ms	low: 10	high: 11
Without Multiple Inheritance:	avg: 7ms	low: 6	high: 7
```

We've reduced search time to 1.5x compared to the no-modules version

### Implementation 2: Using direct assignment

Using direct assignment means that instead of relying on the `metatable`'s `__index` functionality, we can directly set the modules on the object that needs to inherit. This has a downside of taking up more memory, being slightly messier in-code, but with the benefit of avoiding additional lookups when using the class.

_Ok, now I'm basically copying @matt's code [here](https://devforum.play.date/t/lua-oop-mixin-support-supplements-corelibs-object/333) line-for-line._

```lua
function Object:implements(module)
    -- Simply loop over the functionality in "module" and assign to the object.

    for k, v in pairs(module) do
        -- Check we are not overriding other functionality.
        -- You may want to turn on this "assert" to throw errors while developing.
        -- assert(self[k], "Error: Overriding existing functionality!")

        if not self[k] then
            -- Assign value to class using key.
            self[k] = v
        end
    end
end
```

The performance difference is now completely reduced:

```
With Multiple Inheritance:	avg: 7ms	low: 6	high: 7
Without Multiple Inheritance:	avg: 7ms	low: 6	high: 7
```

Keeping the rest of the code the same, this essentially completely reduces any overhead for our multiple-inheritance. Given that the same code path is taken for looking up both super-class functionality and module functionality (checking the parent class first), we see that this is a much more efficient solution.

However, be careful about modules with conflicting names and overriding other modules or class fields. That's the trade-off here, in addition to copying the reference to all the functions for each subclass, which can potentially take a little more memory.
