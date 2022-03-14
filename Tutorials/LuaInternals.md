This isn't even close to being done, but this is what I have right now. I might turn this into a powerpoint.

# Lua Internals
## The Stack
The stack is probably the most important thing in Lua. Lua cannot function without a stack. I'm assuming you know what a stack is, but if not, I'll briefly explain it. You can push and pop values to a stack. Pushing to the stack will add a new value to the top of the stack. You could think of this as `stack[#stack + 1] = value` or `table.insert(stack, value)` as a Lua equivalent to what I'm trying to explain to you. Popping from the stack will remove the top element from the stack. You could think of this as `table.remove(stack, #stack)`. Sometimes when you pop from the stack, you need to access it. In this case you will save it before deallocating it.

The stack stores structures in memory known as `TValue`s. `TValue` stands for "tagged value", with a property called `tt` that represents the type of the value (like `LUA_TFUNCTION`). `TValue`s also have a property called `value`. This property is a union called a `Value`. I'm hoping you know what a union is, if not you need to look it up because it can get complicated. A `Value` can be a `GCObject`, which is any Lua object that can be garbage collected. This could be a `UData` (userdata), a `Closure` (`LClosure` as a Lua function, and `CClosure` as a C function), a `Proto` (function prototype), a `Table`, and a few other types that can be garbage collected such as strings.

The Lua state has a value called `top` which tells you the top index of the stack. If I were to push a `TValue` to the stack, I would set the value to the index `L->top++` in the stack. There is also another property in the state called `base` which is similar to how assembly works when they set the base pointer (`ebp`) to the current stack pointer (`esp`) to initialize another base of the stack, which is why `lua_gettop` subtracts `L->top` by `L->base`.

## Closures and Prototypes
You probably know what a closure is if you've messed around with Lua more internally. If you don't know what a closure is, think of it like a function. There's more to it than just that, but that's all you need to know for a general knowledge base.

Prototypes (or protos) are usually misconcieved due to the `debug.getprotos` function since it returns a table of functions. Don't worry, it's just your common sense. I thought a prototype was the same thing as a closure in the beginning, until I started reverse engineering Lua. A prototype is not a closure, but it's a part of a closure. When Lua deserializes the bytecode it will turn it into a prototype then make a closure from it. If you want more information about this, I will probably make another tutorial out on how Lua's internals work for a deeper reference within the next month, which you can find where all my documentation files are found at.

### Bytecode in Relation With Prototypes
Most of Lua is ran off interpreting, and Lua has it's own style of bytecode that your code compiles to. Think of bytecode as a lower level form of your code, like x86 assembly.

Prototypes have a property called `k` which is an array of constants as `TValue`s in the prototype. These constants represent all literals written in your code, such as strings and numbers. Even though these are `TValue`s, a constant can only be serialized into four types in bytecode, so you won't have to screw with those other types unless you're doing something weird. These types are `LUA_TNIL`, `LUA_TBOOLEAN`, `LUA_TNUMBER`, and `LUA_TSTRING`. The property `sizek` tells you the size of the array.

Prototypes also have a property called `p` which represents it's child prototypes. These represent functions inside of functions. This is an array of prototypes stored on the heap. It's important to know that these are stored on the heap because you don't want to derefrence it. `sizep` is the size of the `p` array.

Another property I want to note here is the `code` property. This is an array of `Instruction`s which is important if you want to dump instructions from a prototype. Just like in the bytecode, there instructions are still bit masked but they're stored in an array as 32 bit integers. For more information on masking, I would look at [lopcodes.h](https://www.lua.org/source/5.1/lopcodes.h.html), which will show you the structure of an instruction.

There are quite a few more things in a prototype that I will not cover, and I encourage you to look for yourself if you want to learn how they work.

## The Call Stack
Whenever you run code in Lua, the first line of code is technically a prototype that is known as the main chunk. In this case I will let you treat this prototype as a function even though it isn't for better understanding. Say I called a function in this one script, and this function calls another function that finally calls print. Here is a code representation of that:
```lua
local function c()
    print("Hello, World!")
end

local function a()
    local function b()
        c()
    end

    b()
end

a()
```
In the main chunk the call stack level is `0`. This is the global level, and this will not change. First thing that happens is that we call `a`. When `a`'s code runs, we are in the next level of the call stack. Then we call `b` and we enter the next level. When `b`'s code runs, `c` will get called and `c`'s call stack level will be even another level up.

Why is this important? Well if you're using `debug` functions in Lua, you need to know how these work because some of them could be used with these level values.

As I explained, level zero is the chunk that the code originally came from (the main chunk). The first level is the current level. If I did `print(debug.getinfo(1).name)` inside of `a`, it will print out "a". If I did `print(debug.getinfo(1).name)` inside of `b`, it will print out "b". This will count backwards, so if I did `print(debug.getinfo(2).name)` inside of `c` it will print out `b`, etc.
```lua
local function c()
    print(debug.getinfo(2).name) --> a
end

local function a()
    local function b()
        print(debug.getinfo(2).name) --> a
    end

    b()
    c()
end

a()
```

Since this is a stack, it can overflow like any other stack. Here's a good example of a stack overflow in Lua:
```lua
function f()
    f()
end

f()
```

## Upvalues
Upvalues are really simple once you understand how the call stack works. An upvalue is a reference to a local variable--but there's a drawback. An upvalue has to be up the call stack; it can't be down the call stack (you can't even access local variables down the call stack) or in the same level. I'm not expecting you to understand this without some code:
```lua
local LocalVar1 = "Some local variable."
local function f()
    local LocalVar2 = "Another local variable!"
    local function f2()
        local LocalVar3 = "A third local variable!"
        print(LocalVar1) -- Travels up the call stack twice; upvalue.
        print(LocalVar2) -- Travels up the call stack once; upvalue.
        print(LocalVar3) -- Defined in the same level; not an upvalue.
    end

    print(LocalVar1) -- Travels up the call stack once; upvalue.
    print(LocalVar2) -- Defined in the same level; not an upvalue.
end

print(LocalVar1) -- Defined in the same level; not an upvalue.
f()
```

## Environments
Do you know what a global variable is? I sure hope you know. If you don't know then you probably shouldn't be reading this document until you learn Lua. These globals are stored as a key in a table that gets looked up when you access it. This table is called the environment. Consider `print` as an example. `print` is a global function in Lua, and whenever you access it, Lua needs to look up the string "print" in the environment table to get your print function. This does not apply for locals. If you define a local, it will not be in the environment table.

Well how do I get access to this table in Lua? Simple. Lua offers quite a few ways to do this. One way is using the `getfenv` function. `getfenv` accepts one parameter: a function or a level in the call stack. If you provide a level, `getfenv` will return the environment of the closure located at the level you provided, and it will error if you passed an invalid level as a parameter. Lua does offer another function called `debug.getfenv` that bypasses some checks that Lua puts in on the C side. `debug.getfenv` just checks that you passed something to the function as a parameter (even `nil`, just not nothing), but it's a straightforward C call after that. If you're up for learning more, I would recommend looking at the Lua source. It's very interesting, although messy in my eyes. The only use I could see here is you needing to get the environment of a C closure, which I doubt any of you would need.

Okay what about from C? This is probably even simpler. Lua's C library offers a low level function called `lua_getfenv` which you can use to get the environment from a `function`, `userdata`, or `thread`. If the type isn't specified, it will just push `nil` to the stack. It does not accept a level. If you want to get the closure from a level, you need to use the `getfunc` function.
