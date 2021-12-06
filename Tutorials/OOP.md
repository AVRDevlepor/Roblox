# Method Calling
There are two ways to call functions from a table in Lua. You can use either a `.` (dot) or a `:` (colon). These both mean different things. Even if you define a function using a colon, you can still call it with a dot, and vice versa. When you call with a colon, the first argument is `self` (the table itself), then the rest of the arguments are inserted along with it. To visualize this, I will show you an example:
```lua
local t = {}
function t.f(self, ...)
    print(self, select('#', ...)) -- select just tells you how much arguments are in "..."
end

function t:f2(...)
    print(self, select('#', ...))
end

t.f("Hello, World!") --> Hello, World! 0
t:f("Hello, World!") --> table: 0xdeadbeef 1 (where that 1st argument is "Hello, World!")

t.f2("Hello, World!") --> Hello, World! 0
t:f2("Hello, World!") --> table: 0xdeadbeef 1
```
Why is this a thing? There is a simple answer to this: so you can access the current table. Well, why can't I just use `t` instead of `self` if it means the same thing? That's where we get into metamethods.

# Metamethods
## __index
`__index` is called when you index a key in the table. It is invoked when you do `t[k]`. If you use the `rawget` function, it will bypass the metamethod (mainly used so you don't get a stack overflow), which is why it's used in some scripts to get past client detection. Let me note here that if the key exists in the table, this callback does not apply. `__index` is only invoked if the key is not found. The first argument of `__index` is `self`. The second argument is the key, which is what you're indexing from the table. (For example, "ABC" in `t["ABC"]` and `t.ABC` is the key.) Back to the last topic: what's the point of `self`? Well, here's an example of using `__index` with a table that will answer your question:
```lua
local t = {}
t.Metatable = {
    __index = function(self, Key)
        if Key == "bruh" then return "yes"; end -- Spoofs "bruh" even though its nil. If it did exist in the table, this wouldn't count.
        return rawget(self, Key) -- self[Key] would trigger an infinite chain of __index invokes which would eventually cause a stack overflow and error the script.
    end,
}

local c = setmetatable({ ["another_key"] = "ok" }, t.Metatable)
print(c.bruh) --> yes
print(rawget(c, "bruh")) --> nil (we're not invoking __index)

print(c.another_key) --> ok
print(rawget(c, "another_key")) --> ok
```
Essentially, `self` isn't always equal to `t` because you can use metatables to use a table as another.
`__index` can also be a table. If a value exists in a table and the index in `t` is nil, it'll use the value from `__index`:
```lua
local t = setmetatable({}, { __index = { ["bruh"] = "yes", ["haha"] = "yes" } })
t.bruh = "no"

print(t.bruh) --> no
print(t.haha) --> yes
print(rawget(t, "haha")) --> nil (we're not using __index)
```
When you are calling functions with `__index`, it will be returning the function and you won't know the arguments. There is a metamethod that overrides `__index`'s handling of function calling when you are calling with a colon which is our next method, `__namecall`.

## __namecall
I think this metamethod is more of an optimization that Roblox decided to do (I don't know, Roblox has to standardize everything to their customs and it's disgusting). Pretty much whenever there's `__namecall` (regardless of if `__index` exists in the metatable), then when you use a colon to call a function, it'll invoke `__namecall` instead of `__index`. If there isn't a `__namecall` metamethod in the metatable, it'll fall back to `__index`. The first argument is `self`, like always. The rest of the arguments are returned as unpacked arguments for the call so you want to make sure to use varargs (`...`) on it. Here is an example of me hooking `FireServer` (code needs some modification to work, untested):
```lua
GameMeta.__namecall = newcclosure(function(self, ...) -- Remote.FireServer(Remote, ...) invokes __index, not __namecall.
    local Args, Method, Caller = {...}, getnamecallmethod(), debug.getinfo(2).func
    if Method == "FireServer" and typeof(self) == "Instance" and self.ClassName == "RemoteEvent" then
        print(self.Name, unpack(Args)) -- When firing remote with ':', it'll print the remote's name and the arguments passed.
    end
    return OldNamecall(self, unpack(Args))
end)
```

## __newindex
This is pretty much equal to `__index` but there's a third argument for the value to be set to and no return is expected. It's invoked when you do `t[k] = v`. The rules here are the same: if the key already exists, Lua won't invoke `__newindex`. The `rawest` function is very helpful here, just like `rawget`. Here's a quick example:
```lua
local t = {}
t.Metatable = {
    __newindex = function(self, Key, Value)
        if Key == "bruh" or Key == "haha" then rawset(self, Key, "override"); return; end -- Sets the value to "override"
        rawset(self, Key, Value)
    end,
}

local c = setmetatable({ ["haha"] = "no" }, t.Metatable)
print(c.bruh) --> nil
c.bruh = "yes"
print(c.bruh) --> override

print(c.haha) --> no
c.haha = "yes"
print(c.haha) --> yes
```

## __call
Try executing `({})()` in your executor. You should get an error saying something like "attempt to call a table value", which is obvious behavior. What if we could change that though? I present to you, __call. The first argument is self (all metamethods start with argument as self), and the call arguments are the unpacked call arguments, so make sure you use `...`
```lua
local t = {}
t.Metatable = {
    __call = function(self, ...)
        local Args, Ret = {...}, table.create(select('#', ...))
        for i, v in ipairs(Args) do
            Ret[i] = v..", "
        end

        return table.concat(Ret).."haha"
    end,
}

local c = setmetatable({}, t.Metatable)
print(c('a', 'b', 'c')) --> a, b, c, haha
```

## __concat
Another game-changing metamethod that is invoked when you use the concatenate (`..`) operator on the table. The first argument is `self` and the second argument is the value you are concatenating by--the value's type DOES NOT need to be a `string`, it can be any type.
```lua
local t = setmetatable({}, {
    __concat = function(self, Value)
        return Value.." Oh, it's just a custom concatenation metamethod example!"
    end,
})

print(t.."Hmm...what's this?") --> Hmm...what's this? Oh, it's just a custom concatenation metamethod example!
```

## __unm
This metamethod's name stands for unary negative metamethod (I don't acutally know, but that's my guess). `__unm` gets invoked when you use the negative (`-`) operator on the table. As alwyas, the first argument is `self`.
```lua
local t = setmetatable({}, {
    __unm = function(self)
        return "Hello, World!"
    end,
})

print(-t) --> Hello, World!
```

## __add, __sub, __mul __div, __mod, and __pow
These all mimic the same behavior, it's just that the operators are different. The first argument is `self`, and the second argument is the value. There is no extra explaining that I need to do. These methods are self-explainatory.
```lua
local function Arithmetic(self, Value)
    return Value + Value
end

local t = setmetatable({}, { -- Make all arithmetic methods * the value by two.
    __add = Arithmetic,
    __sub = Arithmetic,
    __mul = Arithmetic,
    __div = Arithmetic,
    __mod = Arithmetic,
    __pow = Arithmetic,
})

print(t + 5)  --> 10
print(t - 6)  --> 12
print(t * 7)  --> 14
print(t / 8)  --> 16
print(t % 9)  --> 18
print(t ^ 10) --> 20
```

## __tostring
Whenever you call `tostring` on your table, if it has a `__tostring` metamethod, then it'll invoke `__tostring`. This metamethod is really simple. The first argument is `self`, and there are no more arguments.
```lua
local t = setmetatable({ ["tostring_ret"] = "Hello, World!" }, {
    __tostring = function(self)
        return self.tostring_ret
    end,
})

print(tostring(t)) --> Hello, World!
t.tostring_ret = "New return."
print(tostring(t)) --> New return.
```

## __eq, __lt, and __le
These magical metamethods can help you with making things such as comparing two tables that have the same properties. The first argument is `self` and the second argument is the value you are comparing. You should use `rawequal` to avoid a stack overflow when applicable.

## __len
This metamethod takes one argument as `self` and is invoked when you use the length (`#`) operator on the table. In our current Lua version (Lua 5.1), you can't use `__len` on a table, and only on userdatas. Here's an example of `__len` being used:
```lua
local ud = newproxy(true) -- Create a new userdata with an empty metatable.
local mt = getmetatable(ud) -- You can't use setmetatable with a userdata for some reason.
function mt:__len()
    return self
end

print(#ud) --> userdata: 0xdeadbeef
```

# Misc. Metatable Objects
## __metatable
If this value exists, it won't let you call `getmetatable` or `setmetatable` on itself and it'll return whatever the value is instead. Roblox does this so you can't tamper with their internals (It would return "The metatable is locked.") but we have `debug.getmetatable` and `getrawmetatable` which get around this little security feature.
```lua
local t = setmetatable({}, {
    __metatable = "bruh no tampering", -- This can be any value, but I like using a string.
})

print(getmetatable(t)) --> bruh no tampering
setmetatable(t, { __index = {} }) --> ERROR: cannot change a protected metatable
```

## __mode
Welcome, all of you optimization freaks! Are you too lazy to clear the keys of a table when you don't need an object in it anymore? Fear no more, as I have came to save the day! The `__mode` object can be either be `k` for using weak keys, `v` for weak values, or `vk` for weak keys and values. At this moment, you might be wondering what a weak reference is. Weak references means that the reference to the object is ignored by the garbage collector. If you remove all references to the values in a table that has weak values, then the next time the garbage collector runs, it will deallocate them for memory, thus removing them from the table as if they never existed. I will not provide an example since Roblox does not let you run the garbage collector on demand.
