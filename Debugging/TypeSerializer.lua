-- type serializer that handles pretty much every type (that i could imagine you would ever use) for use in like remote spies and stuff
function Round(n)
    if math.floor(n) ~= n then
        n = string.format("%.2f", n)
        if string.sub(n, -3) == ".00" then -- That's a pretty small number LOL
        	return string.sub(n, 1, -4)
		end
    end
    return tostring(n)
end

--[[
-- not sure if i like this style because its not aligned
function ToDict(t)
    if type(t) == "table" then
        for k, v in pairs(t) do
            t[v], t[k] = true, nil
        end
        return t
    elseif type(t) == "string" then
        local t2 = table.create(#t)
        for i = 1, #t do
            t2[string.sub(t, i, i)] = true
        end
        return t2
    end
end

local IdentStart, Numbers = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_", "0123456789"
local Ident = ToDict(IdentStart..Numbers)
IdentStart, Numbers = ToDict(IdentStart), ToDict(Numbers)

function ValidVariableName(Name)
    local c = string.sub(Name, 1, 1)
    if not IdentStart[c] or Numbers[c] then
        return false
    end

    for i = 2, #Name do
        if not Ident[string.sub(Name, i, i)] then
            return false
        end
    end
    return true
end]]

function SerializeTable(t, Depth)
    Depth = Depth or 0
    local Tab = string.rep("    ", Depth)
    local Tab2, Dump = "    "..Tab, "{\n"
    for k, v in pairs(t) do
        local Key, Fmt = (type(k) ~= "table") and Serialize(k) or "Table(\""..tostring(k).."\")", "%s[%s] = %s,\n"
        --if type(k) == "string" and ValidVariableName(k) then
        --    Fmt, Key = "%s%s = %s,\n", k
        --end

        if type(v) == "table" then
            Dump = Dump..string.format(Fmt, Tab2, Key, SerializeTable(v, Depth + 1))
            continue;
        end

        Dump = Dump..string.format(Fmt, Tab2, Key, Serialize(v))
    end
    return Dump..Tab.."}"
end

function Serialize(Value)
	local Type = typeof(Value)
	if Type == "nil" then
		return Type
	elseif Type == "string" then
		return string.format("%q", Value):gsub("\a", "a"):gsub("\b", "b"):gsub("\f", "f"):gsub("\n", "n"):gsub("\r", "r"):gsub("\v", "v")
    elseif Type == "number" then
        local Res = tostring(Round(Value))
        if Res == "inf" then
            Res = "math.huge"
        elseif Res == "-inf" then
            return "-math.huge"
        elseif Res == "-nan(ind)" then
            return "1/0" -- undefined
        elseif Res == "-0" then
            return "0" -- bruh
        end
        return Res
    elseif Type == "boolean" then
        return tostring(Value)
    elseif Type == "userdata" then
        local Address = tonumber(string.split(tostring(Value), ": 0x")[2], 16)
        return string.format("Userdata(0x%x)", Address)
    elseif Type == "table" then
        return SerializeTable(Value)
    elseif Type == "function" then
        local Name = debug.getinfo(Value).name
        return string.format("Function(%q)", (Name == "") and "anonymous function" or Name)
	elseif Type == "Instance" then
		return Value.GetFullName(Value) -- Better GetFullName
	elseif Type == "Vector2" then
		return string.format("Vector2.new(%s, %s)", Serialize(Value.X), Serialize(Value.Y))
    elseif Type == "Vector2int16" then
        return string.format("Vector2int16.new(%s, %s)", Serialize(Value.X), Serialize(Value.Y))
	elseif Type == "Vector3" then
		return string.format("Vector3.new(%s, %s, %s)", Serialize(Value.X), Serialize(Value.Y), Serialize(Value.Z))
    elseif Type == "Vector3int16" then
        return string.format("Vector3int16.new(%s, %s, %s)", Serialize(Value.X), Serialize(Value.Y), Serialize(Value.Z))
    elseif Type == "CFrame" then
        local rX, rY, rZ = Value:ToOrientation()
        if rX == 0 and rY == 0 and rZ == 0 then
            return string.format("CFrame.new(%s, %s, %s)", Serialize(Value.X), Serialize(Value.Y), Serialize(Value.Z))
        end
        return string.format("CFrame.new(%s, %s, %s) * CFrame.Angles(math.rad(%s), math.rad(%s), math.rad(%s))",
            Serialize(Value.X), Serialize(Value.Y), Serialize(Value.Z),
            Serialize(math.deg(rX)), Serialize(math.deg(rY)), Serialize(math.deg(rZ)))
    elseif Type == "UDim" then
        return string.format("UDim.new(%s, %s)", Serialize(Value.Scale), Serialize(Value.Offset))
    elseif Type == "UDim2" then
        return string.format("UDim2.new(%s, %s, %s, %s)", Serialize(Value.X.Scale), Serialize(Value.X.Offset), Serialize(Value.Y.Scale), Serialize(Value.Y.Offset))
    elseif Type == "BrickColor" then
        return string.format("BrickColor.new(%q)", Value.Name)
    elseif Type == "Color3" then
        return string.format("Color3.fromRGB(%s, %s, %s)", Serialize(Value.R * 0xFF), Serialize(Value.G * 0xFF), Serialize(Value.B * 0xFF))
    elseif Type == "DateTime" then
        return string.format("DateTime.fromIsoDate(%q)", Value:ToIsoDate())
        --local UTC = Value:ToUniversalTime()
        --return "DateTime.fromUniversalTime("..UTC.Year..", "..UTC.Month..", "..UTC.Day..", "..UTC.Hour..", "..UTC.Minute..", "..UTC.Second..", "..UTC.Millisecond..")"
    elseif Type == "Enums" then
        return "Enum"
    elseif Type == "Enum" then
        return string.format("Enum.%s", tostring(Value))
    elseif Type == "EnumItem" then
        return tostring(Value)
    elseif Type == "Ray" then
        return string.format("Ray.new(%s, %s)", Serialize(Value.Origin), Serialize(Value.Direction))
    elseif Type == "RBXScriptSignal" then -- Possible guess functionality??
        return string.format("Signal(%q)", string.split(tostring(Value), " ")[2])
    elseif Type == "RBXScriptConnection" then -- Maybe scan GC for relative connections?
        return "Connection()"
    elseif Type == "Region3" then -- I'm failing to do simple math so ill just put fuzzy here
        return string.format("FuzzyRegion3(%s, %s) --[[ Center, Area ]]", Serialize(Value.CFrame), Serialize(Value.Size))
	end
	return string.format("unk(\"%s\", %q)", Type, tostring(Value))
end

function SerializeArgs(...)
    local Serialized = ""
    for _, o in ipairs({...}) do
        Serialized = Serialized..Serialize(o)..", "
    end
    return string.sub(Serialized, 1, -3)
end

return {
    Serialize = Serialize,
    SerializeArgs = SerializeArgs
}
