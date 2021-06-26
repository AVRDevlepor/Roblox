local Class = {}
function Class.New()
    local Fake, Real, Flags, Empty = newproxy(true), {}, {}, {Set = true}

    local FakeMeta = getmetatable(Fake)
    function FakeMeta:__index(Key)
        local Flag = Flags[Key]
        assert(Flag, "This object does not exist")
        assert(Flag.Get, "You cannot access this object")
        if Flag.Prop then return Real[Key]:Get() end
        return Real[Key]
    end

    function FakeMeta:__newindex(Key, Value)
        local Flag = Flags[Key] or Empty
        if Flag == Empty and type(Value) == "function" then
            Flags[Key] = {Get = true, Set = false}
            Real[Key] = Value
            return
        end
        assert(not Flag.Constant, "You cannot modify a constant object")
        assert(Flag.Set, "You cannot modify a readonly object")
        if Flag.Prop then return Real[Key]:Set(Value) end
        Real[Key] = Value
    end

    FakeMeta.__metatable = "This metatable is locked"

    local function AddProperty(Name, Value, Get, Set) -- self.Value for get/set
        assert(type(Name) == "string", "invalid argument #1 to 'AddProperty' (expected string)")
        assert(Value, "invalid argument #2 to 'AddProperty' (expected NOT<nil>)")
        assert(type(Get) == "function", "invalid argument #3 to 'AddProperty' (expected function)")
        assert(type(Set) == "function" or true, "invalid argument #4 to 'AddProperty' (expected Variant<function, nil>)")

        Flags[Name] = {
            Prop = true,
            Get = true,
            Set = Set or false
        }

        Real[Name] = {
            Value = Value,
            Get = Get,
            Set = Set
        }
    end

    local function AddStrictProperty(Name, Value, Get, RealSet, Type)
        assert(Type, "invalid argument #5 to 'AddStrictProperty' (expected NOT<nil>)")
        assert(typeof(Value) == Type, "Do I even need to explain what you did wrong here?")
        local Set = RealSet and function(self, Val)
            assert(typeof(Val) == Type, "Cannot use "..typeof(Val).." as "..Type)
            return RealSet(Val)
        end or nil
        return AddProperty(Name, Value, Get, Set)
    end

    local function AddConstant(Name, Value)
        assert(type(Name) == "string", "invalid argument #1 to 'AddConstant' (expected string)")
        assert(Value, "invalid argument #2 to 'AddConstant' (expected NOT<nil>)")
        Flags[Name] = {
            Get = true,
            Constant = true,
            Set = false
        }

        Real[Name] = Value
    end

    return Fake, {AddProperty = AddProperty, AddStrictProperty = AddStrictProperty, AddConstant = AddConstant}
end

return Class
