# Lua Inheritance Explained

So, you've gotten curious, have you?

You want to learn the _dark secrets_ of Lua for Playdate...

Well, you've come to the right place, my friend. Scroll down and join the dark side...

### How does inheritance work in Lua?

First, the basics. Lua, by default, doesn't have any of the fancy object-oriented syntax like other languages where you can create and extend classes. In Lua, the built-in mechanism is much simpler, and it's up to you how you use it. Luckily, the Playdate SDK provides us with an implementation that we'll take a deeper look at after covering the basics, which are the ones offered by the Lua language itself.

Rather than explaining the details, let's take a look at some examples.

#### Example 1: Basic inheritance

```lua
-- Step 1: Create a table with some built-in functionality.

local parentTable = {}

function parentTable.testPrint()
    print("Test!")
end

-- Step 2: Create an (empty) table that will inherit that functionality

local table2 = {}

-- Step 3: Lua hand-wavey woo-woo magic trick!!
setmetatable(table2, { __index = parentTable })

-- Result: table2 can now perform what parentTable can.
table2.testPrint()
```

#### Example 2: Mixing fields and functions inheritance

Here's another example, using some fields and some interaction between child and parent fields.

```lua

-- Step 1: Define parent table, fields and functionality
local table1 = {
    count = 5
}

-- This prints the "count" field on the "self" object.
function table1:testPrint()
    print("Test!" .. self.count)
end

-- Step 2: Define child tables

-- Example 1: empty table
local table2 = {
}

-- Example 2: override "count" field.
local table3 = {
    count = 3
}

-- Step 3: More magic! (Both inherit from table1 / parent)
setmetatable(table2, { __index = table1 })
setmetatable(table3, { __index = table1 })

-- Result:
table2:testPrint() -- Prints "5"
table3:testPrint() -- Prints "3"
```

So you can see that the child can execute a parent function using its own fields.

#### Metatables Explained

So, you've maybe identified that we're using a fancy built-in lua function called `setmetatable`. That basically assigns a behind-the-scenes table to another table, which will act as a director for certain functionality.

For example, the `__index` field in the metatable allows a second-lookup if the field is missing from the former.

Taking [Example 2's](#example-2-mixing-fields-and-functions-inheritance) case:

```
--> Lookup field "count" on "table2": --> table2.count == nil --> Lookup field "count" on table2.metatable.__index --> Return "5"
```

There are other fields that can be applied on metatables in lua, notably:

- [Arithmetic Operators](https://www.lua.org/pil/13.1.html) e.g. functionality for "+", "-", "\*", ...
- [Relational Operators](https://www.lua.org/pil/13.2.html) e.g. functionality for "<", "<=", "==", ...
- [Library-defined methods](https://www.lua.org/pil/13.3.html), like defining a custom `toString` or even overriding what comes out of the `getmetatable` function.
- **Table-access fields or methods:** These are what we're after. They are as follows:
  - [`__index`](https://www.lua.org/pil/13.4.1.html) for a lookup when the value on the table is `nil`
  - [`__newIndex`](https://www.lua.org/pil/13.4.2.html) for assignment on the table.

_Lua.org has more examples on how to use these, notably [setting default return values](https://www.lua.org/pil/contents.html#13), [multiple inheritance](https://www.lua.org/pil/16.3.html), [making tables read-only](https://www.lua.org/pil/13.4.5.html) and [privacy-protecting tables](https://www.lua.org/pil/16.4.html) to make them read-only. Metatable-related guides are listed under [chapter 13](https://www.lua.org/pil/contents.html#13) and [chapter 16](https://www.lua.org/pil/contents.html#16)._

### Playdate SDK's Inheritance Explained

So, the next target is to understand what **we're** doing when we define a `class` using the Playdate SDK.

Thankfully, the lua-code is open-source, so we can take a look at it here.

Below is a commented version for better understanding:

```lua
--- A local table is being defined
local __NewClass = {}

--- `class` takes three parameters: "ClassName", "properties" and "namespace".
--- The function simply sets them on the __NewClass table without any additional functionality, and returns __NewClass.
function class(ClassName, properties, namespace)
    __NewClass.className = ClassName
    __NewClass.properties = properties
    __NewClass.namespace = namespace
	return __NewClass
end
```

So when you define a class using `class`, nothing really happens apart from adding a class to the \_\_NewClass table, which is not even exposed outside the file. You're just setting those three values.

Let's take a look at the `extends` method as that's what executes on the \_\_NewClass-returned value, and adds inheritance to it.

```lua
--- "extends" is thus defined on __NewClass so it can be called on the return value from "class", e.g.: class("MyClass").extends()
function __NewClass.extends(Parent)

	if type(Parent) == 'string' then
        -- This checks for whether "Parent" is a string, in which case it sets it to the table that's being referenced by the string.
        -- E.g. class("MyClass").extends("MyParentClass") will get the table-value of MyParentClass using the string name as a reference.
        Parent = _G[Parent]
    elseif Parent == nil then
        -- If there is no parent class, then it uses "Object" (also defined in the file) as a parent class.
	    Parent = Object
	end

    -- This initializes the table that will be used for the child class. Any "properties" passed through or an empty table.
	local Child = __NewClass.properties or {}

    -- This sets the "__index" that any instances of the Child class will inherit, therefore pointing to the Child class!
    -- i.e. this defines the "instance -> Child class" lookup.
	Child.__index = Child

    -- These fields are not necessary but are very helpful.
	Child.class = Child
	Child.className = __NewClass.className
	Child.super = Parent

    -- A bunch of operators are manually assigned to the Child class (if they are defined on the parent).
	Child.__gc 			= Parent.__gc
	Child.__newindex 	= Parent.__newindex
	Child.__mode 		= Parent.__mode
	Child.__tostring 	= Parent.__tostring
	Child.__len 		= Parent.__len
	Child.__unm 		= Parent.__unm
	Child.__add 		= Parent.__add
	Child.__sub 		= Parent.__sub
	Child.__mul 		= Parent.__mul
	Child.__div 		= Parent.__div
	Child.__mod 		= Parent.__mod
	Child.__pow 		= Parent.__pow
	Child.__concat 		= Parent.__concat
	Child.__eq 			= Parent.__eq
	Child.__lt 			= Parent.__lt
	Child.__le 			= Parent.__le

    -- This is the child class's metatable.
	local mt = {
        -- This defines the Child -> Parent inheritance.
		__index = Parent,

        -- NOTE: One more field is defined here, but we'll come back to that.
		}

    -- This sets the Child class's metatable, so that it's able to inherit from the Parent class.
	setmetatable(Child, mt)

    -- Check whether to assign the class to a custom namespace or to the default (global table) _G.
	if (__NewClass.namespace ~= nil) then
		__NewClass.namespace[__NewClass.className] = Child
	else
		_G[__NewClass.className] = Child
	end

    -- Reset the parameters on the "__NewClass".
	__NewClass.properties = nil
	__NewClass.className = nil
	__NewClass.namespace = nil
end
```

So, to recap, the "class" + "extends" functionality does this to create a `Child` class which inherits from `Parent`:

- `class` sets three values on an internal table: `className`, `properties` and `namespace`.
- `extends` creates a new table based on `properties` if defined, or an empty table.
- Then, `extends` assigns some fields to `Child` that will be inherited by its instances.
- It also manually assigns any operators defined on the `Parent`.
- Then, it sets the `metatable` of `Child` with `__index` pointing to `Parent`, thus inheriting `Parent`'s functionality when otherwise not defined.
- Finally, it assigns the class based on the `className` and the `namespace`, allowing access to it from all other files.

There's one piece we skipped, which is the `__call` function defined in the metatable. The `__call` function, called when the class is directly followed by parentheses (e.g. `MyClass()`), is what the PlaydateSDK uses to create **instances** of a class.

This is how it looks:

```lua
    -- This is the child class's metatable.
	local mt = {
        -- This defines the Child -> Parent inheritance.
        __index = Parent,

        -- "__call" will be called when the class "MySprite" is called upon directly, e.g. when calling "MySprite()".
        -- "self" and any args are passed through, similar to a colon (:) function.
		__call = function(self, ...)
            -- This creates a table using "baseObject()", which is defined on Parent class "Object".
            -- It can be overridden and otherwise returns an empty table.
			local instance = Child.baseObject()
            -- Our Lua magic line! This sets the inheritance from instance -> Child, since Child has an "__index" field defined.
			setmetatable(instance, Child)

            -- These are commented out in the SDK.
            -- They are kind of misleading since instances's "__index" and "class" fields point to Child, not to instance.
--			instance.__index = instance
-- 			instance.class = instance

            -- This sets the field "super" on instance and points it to "Child".
			instance.super = Child

            -- This is where our "init" functions get called! You can see all the args {...} get passed through to here, and "instance" is passed as the "self".
			Child.init(instance, ...)

            -- Finally, it returns the instance.
			return instance
		end
		}
```

So you can see how the following lines work:

```lua
-- Create a template parent class with functionality.
-- We should inherit the Playdate SDK's "Object" or else "baseObject" will not be defined.
class("TestParent").extends()

-- Define "printTest" function on TestParent.
function TestParent:printTest()
    print("Testing!")
end

-- Create "MyChild" Child-class, point to "TestParent" as the parent class.
class("MyChild").extends(TestParent)

print(MyChild) --> prints MyChild table
print(MyChild.className) --> prints "MyChild"
print(MyChild.class) --> prints MyChild table
print(MyChild.super) --> prints TestParent table
print(getmetatable(MyChild).__index) --> prints TestParent table

-- MyChild inherits from TestParent, so you can call "printTest" on it.
MyChild.printTest() -- Prints "Testing!"

-- Create an instance of MyChild.
-- This calls the __call() function we saw earlier, and assigns the metatable of "instance" to point to "MyChild".
local instance = MyChild()

print(getmetatable(instance) == MyChild) -- prints "true"
print(getmetatable(instance).__index == MyChild) -- prints "true"
print(instance.super.className) -- prints "MyChild"
print(instance.super.super.className) -- prints "TestParent"

-- Instance inherits from MyChild, which inherits from TestParent.
instance:printTest() -- Prints "Testing!"
```

Here are some notes on the above:

- It's important that all parent classes inherit from `Object`, i.e. using `class(..).extends()`. That's because `Object` defines the `baseObject()` function, and if missing, will break the initialization code for child classes. (Alternatively you could define it yourself on the Parent class, and that would work too.)
- The fields `class`, `className`, and `super` are **not essential** to any of the inheritance mechanisms. They are just there to help keep things convenient, easy to understand and organized when using or debugging your code. The inheritance purely relies on `setmetatable` and `__index` to inherit fields and functionality.

### Creating our own inheritance.

So as you've seen, Lua's inheritance mechanism is pretty simple. On the other hand, Playdate's SDK inheritance has a lot of built-in stuff we might not necessarily want all of.

Here are some examples of other functionality we might prefer:

- Instead of using a string-based class name, we can directly assign to a table and it would be **easier for type checking**.
- We might want to inherit from a **regular lua table** instead of always using `class`/`Object` as our parent classes.
- We may want **multiple inheritance**, i.e. multiple parent classes to inherit functionality from.
- A more flexible way of defining the parent class, for example being able to **assign it in real-time**.

Let's step through some basic examples.

#### Example 1: Child class inheriting from Parent

Here's a basic re-implementation of inheritance from a parent to a child class:

```lua
-- Create a template parent class with functionality. Use an empty table as a base.
TestParent = {}

-- Define "printTest" function on TestParent.
function TestParent:printTest()
    print("Testing!")
end

-- This is our new "class" function: You just need to pass in the parent class and the child will inherit from it.
function newClass(parentClass)
    -- Create the empty child table.
    local childClass = {}

    -- Using setmetatable, the childClass inherits from the parent class.
    setmetatable(childClass, {
        __index = parentClass
    })

    -- Return the child class.
    return childClass
end

-- Here we are creating the MyChild child class, inheriting from TestParent.
MyChild = newClass(TestParent)

-- As you can see, we can now call TestParent's functionality on the child class.
MyChild.printTest() -- Prints "Testing!"
```

#### Example 2: Instantiation of Child class

This example is very straight-forward, but is missing the _instantiation_ of the child class. Let's add that functionality to the `newClass` function:

```lua

-- This is our new "class" function: You just need to pass in the parent class and the child will inherit from it.
function newClass(parentClass)
    -- Create the empty child table.
    local childClass = {}

    -- Using setmetatable, the childClass inherits from the parent class.
    setmetatable(childClass, {
        __index = parentClass

        --- vvvvv -- ADD THESE LINES

        __call = function(self, ...)
            -- Create the instance object
            local instance = {}

            -- Set the metatable to inherit from "childClass".
            -- Note that we're not setting the childClass as the metatable directly, but using "__index" since that's what actually is needed to inherit.
            setmetatable(instance, {
                __index = childClass
            })

            -- If exists, call the "init" function, defined in the childClass on the instance.
            if childClass.init then
                childClass.init(instance, ...)
            end

            -- Return the instance.
            return instance
        end

        --- ^^^^^ -- ADD THESE LINES
    })

    -- Return the child class.
    return childClass
end

-- Here we are creating the MyChild child class, inheriting from TestParent.
MyChild = newClass(TestParent)

-- As you can see, we can now call TestParent's functionality on the child class.
MyChild.printTest() -- Prints "Testing!"

-- This calls our "__call" function, creating and returning an instance of MyChild!
local instance = MyChild()

instance.printTest() -- Prints "Testing!"

```

You can see the essentials are the same as what is in the CoreLibs/object defined in the PlaydateSDK. This one is simpler, however, boiled down to the essential functionality to get it to work.

_Note that the above do not have the previously mentioned convenience fields `class`, `className` and `super` defined. If you want those, you'll have to manually set them on the parent/child classes and instance._
