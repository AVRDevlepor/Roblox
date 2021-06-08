local HttpService = game:GetService("HttpService")
local substr, gsubstr, strrev, strfind, strchar, strbyte, strfmt = string.sub, string.gsub, string.reverse, string.find, string.char, string.byte, string.format
local tonumber, tblrem = tonumber, table.remove

local function URLEncode(Str)
    Str = gsubstr(Str, "\n", "%0A")
    Str = gsubstr(Str, " ", "+")
    return gsubstr(Str, "([^%w _%%%-%.~])", function(C)
        return strfmt("%%%02X", strbyte(C))
    end)
end

local function URLDecode(Str)
    Str = gsubstr(Str, "+", " ")
    return gsubstr(Str, "%%(%x%x)", function(CC)
        return strchar(tonumber(CC, 16))
    end)
end

local function ParseURL(Url)
    local Result = {
        RawUrl = Url,
        UsingHttpSecure = false
    }

    if substr(Url, -1) == "/" then Url = substr(Url, 0, -2) end -- Remove that trailing slash
    if substr(Url, 0, 7) == "http://" then
        Url = substr(Url, 8)
    elseif substr(Url, 0, 8) == "https://" then
        Url = substr(Url, 9)
        Result.UsingHttpSecure = true
    end

    local Path, Paths, FullDomain = "", {}, nil
    gsubstr(Url, "[^/]+", function(Split)
        if not FullDomain then FullDomain = Split return end
        Path = Path.."/"..Split
        Paths[#Paths + 1] = Split
    end)

    local DomainIter, Subdomains, Domain = 0, {}, ""
    gsubstr(strrev(FullDomain), "[^.]+", function(Split)
        DomainIter = DomainIter + 1
        if DomainIter == 1 then
            Domain = Domain.."."..strrev(Split)
            return
        elseif DomainIter == 2 then
            Domain = strrev(Split)..Domain
            return
        end
        Subdomains[#Subdomains + 1] = strrev(Split)
    end)

    local SubdomainsLen = #Subdomains
    for i = SubdomainsLen - 1, 1, -1 do
        Subdomains[SubdomainsLen] = tblrem(Subdomains, i)
    end

    local ParamsStart = strfind(Url, "?")
    if ParamsStart then
        local FullParams, Params = substr(Url, ParamsStart + 1), {}
        gsubstr(FullParams, "[^&]+", function(Split)
            local EqPoint = strfind(Split, "=")
            local Name, Value = substr(Split, 1, EqPoint - 1), URLDecode(substr(Split, EqPoint + 1))
            Params[Name] = Value
        end)

        Result.RawParams = FullParams
        Result.Params = Params
    end

    Result.RawPath = Path
    Result.Path = Paths
    Result.Domain = Domain
    Result.RawDomain = FullDomain
    Result.Subdomains = Subdomains
    return Result
end

local function DecodeJSON(Str)
    return HttpService.JSONDecode(HttpService, Str) -- Bypasses the metamethod hooks if you guys care about those.
end

local function SerializeJSON(Table)
    return HttpService.JSONEncode(HttpService, Table)
end

return {
    Encode = URLEncode,
    Decode = URLDecode,
    Parse = ParseURL,
    JSON = {
        Decode = DecodeJSON,
        Serialize = SerializeJSON
    }
}
