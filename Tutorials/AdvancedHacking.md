Hey, you asked for help and you'll recieve help. I created this because I'm extremely lazy and I don't want to explain everything to 1000 people who want to learn how to make Roblox cheat scripts. Seriously, if you have questions about anything, you can always add me on discord (H3x0R#4231) and ask questions. I don't mind helping people, but if you're gonna be an arrogant person who doesn't want to dedicate time into learning, I won't help you out.

# Precursor
Real quickly, I want you to know a few terms so you understand what I'm talking about. A function prototype (proto) is not the same thing as a function. A proto is part of a function. Another thing I need you to know is that a closure is the same thing as a function.

# Scripts and Closures
A script is an instance, a closure is a function that the script is running as. You can use the `getscriptclosure` function to fetch the closure of your script.

# The Call Stack
You're gonna need to know how the call stack works to continue this tutorial. Don't worry, it's a lot simpler than you think it is. Whenever you execute a script, the first line of code is technically a function, but not a function. It's the main chunk, which is the first level of the call stack. If you call a function from the main chunk, then the code the function runs is in the second level of the call level. If you call a function in that function, the call stack level will go to three. This can just keep increasing by calling a function in a function until the stack overflows and the script will error. Here is a function I made that returns our call stack level:
```lua
local function getcallstacklevel()
    local i = 0
    while debug.getinfo(3 + i) do
        i = i + 1
    end

    return i
end
```
Some of you have mental retardation, so here's a visualization script:
```lua
print(tostring(getcallstacklevel())..": main chunk")
local function a()
    print(tostring(getcallstacklevel())..": function a")
end

local function b()
    print(tostring(getcallstacklevel())..": function b (before call)")
    a()
    print(tostring(getcallstacklevel())..": function b (after call)")
end

local function c()
    print(tostring(getcallstacklevel())..": function c (before call)")
    b()
    print(tostring(getcallstacklevel())..": function c (after call)")
end

c())
```
This should be your output, with the number as the call stack level:
```
1: main chunk
2: function c (before call)
3: function b (before call)
4: function a
3: function b (after call)
2: function c (after call)
```
You can go backwards in the call stack level, like with a few debug functions:
```lua
local function a()
    local function b()
        print(debug.getinfo(2).name) --> a
    end
end

a()
```

# Closures in Closures
There is a function called `debug.getprotos` that you can use to get the list of closures inside of a closure. This is helpful when the developer of your script defined a function as a local so you can still access it. The term 'getprotos' means get prototypes, which aren't closures, but the function will convert those prototypes into closures for you which are essentially the same thing, just that they aren't the exact same function even though they do the same actions. Here's a quick example of getprotos:
```lua
function FunctionOne() end -- Example global function.
local function FunctionTwo() end -- Example local function.

local Protos = debug.getprotos(1) -- Get the list of protos in the current chunk.
table.foreachi(Protos, function(i, Closure)
	local Name = debug.getinfo(Closure).name
	if Name == "" then
		print("Unnamed function")
	else
		print(Name)
	end
end)
```
If you execute what's above, you should get this output:
```
FunctionOne
FunctionTwo
Unnamed function
```
You can see that there's three protos, but there's only two functions? Well, there's actually a third function. The unnamed function is the anonymous function passed through `table.foreachi` to iterate the list of protos.

# Upvalues
Alright, now we can finally get some upvalue action in here. An upvalue is a reference to a local variable--but there's a drawback. An upvalue has to be up the call stack; it can't be down the call stack or in the same call stack level. It's confusing and you'll probably need a visualization to understand this:
```lua
local LocalVar1 = "Some local variable."
local function f()
    local LocalVar2 = "Another local variable!"
    local function f2()
        local LocalVar3 = "A third local variable!"
        print(LocalVar1) -- You have to travel up the call stack twice to get it; upvalue reference.
        print(LocalVar2) -- You have to travel up the call stack once to get it; upvalue reference.
        print(LocalVar3) -- Defined in the same call stack level; not an upvalue reference.
    end

    print(LocalVar1) -- Hey, look! Our call stack level is 2, and the local is at level 1, this is an upvalue reference.
    print(LocalVar2) -- Defined in the same call stack level; not an upvalue reference.
end

print(LocalVar1) -- Defined in the same call stack level; not an upvalue reference.
f()
```
Alright, what's the use if I don't know how to exploit scripts using upvalues? Think of a script that holds the nitro value for a car. Let's say there's a function that the exploiter knows of that updates the nitro value. The function has an upvalue that holds the nitro value. Here's a visualization of this script:
```lua
local Nitro = 100
local function DecrementNitro()
    Nitro = Nitro - 1
end
```
You can already tell that there's an upvalue here. We can use `debug.getupvalue` to get it and `debug.setupvalue` to get it. I need to use `debug.setupvalue` here because I want to set it to something infinite. `debug.setupvalue` takes two arguments: the function, and the upvalue index. I know for a fact that the nitro upvalue index is 1 because it's the first upvalue being accessed in that function. Now we can just do simple plugging in:
```lua
local Nitro = 100
local function DecrementNitro()
    Nitro = Nitro - 1
end

print(Nitro) --> 100
debug.setupvalue(DecrementNitro, 1, math.huge)
print(Nitro) --> inf
```
Congratulations, you just learned how to change an upvalue.

# Combining Our Knowledge
Okay, let's take this nitro script we made and exploit it as it was a legit script. We have to use `debug.getprotos` to find the function, then we need to get the first upvalue of that function and set it to `math.huge` to make it infinite. Here's the decompiled script source:
```lua
-- Script Path: game.Players.LegitH3x0R.Character.SuperNitroScript
local v0 = 1000
local function DecrementNitro()
    v0 = v0 - 1
end

while task.wait(1) do
    DecrementNitro()
    print("Nitro: "..v0)
end
```
You see something you can exploit? I sure do. Here's how I exploited it:
```lua
local Script = getscriptclosure(game:GetService("Players").LocalPlayer.Character.SuperNitroScript)
local DecrementNitro; for _, Closure in ipairs(debug.getprotos(Script)) do
    if debug.getinfo(Closure).name == "DecrementNitro" then
        DecrementNitro = Closure
    end
end
assert(DecrementNitro, "Failed to find closure.")
debug.setupvalue(DecrementNitro, 1, math.huge)
```
