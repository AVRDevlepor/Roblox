# Method Calling
There are two ways to call functions from a table in Lua. You can use either a '.' (dot) or a ':' (colon). These both mean different things. Even if you define a function using a colon, you can still call it with a dot, and vice versa. When you call with a colon, the first argument is self (the table itself), then the rest of the arguments are inserted along with it. To visualize this, I will show you an example:
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
Why is this a thing? There is a simple answer to this: so you can access the current table. Well, why can't I just use 't' instead of 'self' if it means the same thing? That's where we get into metamethods. I will explain three of them that you need to know the most, but you can read more about them here.

# Metamethods
### __index
__index is called when you index a key in the table. It is invoked when you do "t[k]". If you use the 'rawget' function, it will bypass the metatable (mainly used so you don't get a stack overflow), which is why it's used in some scripts to get past client detection. Let me note here that if the key exists in the table, this callback does not apply. __index is only invoked if the key is not found. The first argument of __index is self. The second argument is the key, which is what you're indexing from the table. (For example, "ABC" in t["ABC"] and t.ABC is the key.) Back to the last topic: what's the point of self? Well, here's an example of using __index with a table that will answer your question:
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
Essentially, self isn't always equal to 't' because you can use metatables to use a table as another.
__index can also be a table which if a value exists in the table, it'll use that instead:
```lua
local t = setmetatable({}, { __index = { ["bruh"] = "yes", ["haha"] = "yes" } })
t.bruh = "no"

print(t.bruh) --> no
print(t.haha) --> yes
print(rawget(t, "haha")) --> nil (we're not using __index)
```
When you are calling functions with __index, it will be returning the function and you won't know the arguments. There is a metamethod that overrides __index when calling with a colon which is our next method, __namecall.

### __namecall
I think this is more of an optimization thing that Roblox decided to do (I don't know, Roblox has to standardize everything to their customs and it's disgusting). Pretty much whenever there's __namecall (regardless of if __index exists), then when you use a colon to call a function, it'll invoke that instead of __index. If there isn't a __namecall metamethod, it'll fall back to __index. The first argument is self, like always. The rest are returned as unpacked arguments so you want to make sure to use varargs (...) on it. Here is an example of me hooking FireServer (code needs some modification to work, untested):
```lua
GameMeta.__namecall = newcclosure(function(self, ...) -- Remote.FireServer(Remote, ...) invokes __index, not __namecall.
    local Args, Method, Caller = {...}, getnamecallmethod(), debug.getinfo(2).func
    if Method == "FireServer" and typeof(self) == "Instance" and self.ClassName == "RemoteEvent" then
        print(self.Name, unpack(Args)) -- When firing remote with ':', it'll print the remote's name and the arguments passed.
    end
    return OldNamecall(self, unpack(Args))
end)
```

### __newindex
This is pretty much equal to __index but there's a third argument for the value to be set to and no return is expected. It's invoked when you do "t[k] = v". The rules here are the same: if the key already exists, Lua won't invoke __newindex. The 'rawest' function is very helpful here, just like rawget. Here's a quick example:
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
