local function Import(LibName)
    return loadstring(game:HttpGet(string.format("https://raw.githubusercontent.com/LegitH3x0R/Roblox-Scripts/main/UniversalLibs/%s.lua", LibName)))()
end

local BlockDiscordWebhooks = true
local DiscordWebhookCallback = function(Parsed, Old)
    local Res = Old({
        Url = Parsed.RawUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = '{"username":"WebProtection","avatar_url":"","content":"This webhook has been intercepted and deleted by WebProtection."}'
    })
    Old({ -- Delete the webhook
        Url = Parsed.RawUrl,
        Method = "DELETE" -- Script-Ware doesn't support DELETE?
    })
    warn("Webhook deleted.")
    return Res
end

local URL = Import("Url")
local function CheckURL(Url, Old)
    local Parsed = URL.Parse(Url)
    if BlockDiscordWebhooks and (Parsed.Domain == "discord.com" or Parsed.Domain == "discordapp.com") and Parsed.Path[1] == "api" and Parsed.Path[2] == "webhooks" then
        local Success, Res = pcall(DiscordWebhookCallback, Parsed, Old)
        return Success and Res or {
            Success = true,
            StatusCode = 200,
            StatusMessage = "OK",
            Headers = {},
            Cookies = {},
            Body = ""
        }
    elseif Parsed.Domain == "ident.me" then
        return {
            Success = true,
            StatusCode = 200,
            StatusMessage = "OK",
            Headers = {},
            Cookies = {},
            Body = "127.0.0.1"
        }
    elseif Parsed.Domain == "ipfy.org" then
        return {
            Success = true,
            StatusCode = 200,
            StatusMessage = "OK",
            Headers = {},
            Cookies = {},
            Body = "127.0.0.1"
        }
    elseif Parsed.Domain == "httpbin.org" then

    elseif Parsed.Domain == "icanhazip.com" then
        return {
            Success = true,
            StatusCode = 200,
            StatusMessage = "OK",
            Headers = {},
            Cookies = {},
            Body = "127.0.0.1"
        }
    elseif Parsed.Domain == "seeip.org" then
        local Body = "127.0.0.1"
        if Parsed.Path[1] == "json" or Parsed.Path[1] == "jsonip" then
            Body = '{"ip":"127.0.0.1"}'
        elseif Parsed.Path[1] == "geoip" then
            Body = '{"ip":"127.0.0.1","continent_code":"AN","country":"Australlia","country_code":"AU","country_code3":"AUS","region":"Tasmania","region_code":"TAS","city":"Tasmanian Devil\'s Cave","postal_code":"7000","latitude":0,"longitude":0,"timezone":"I LIVE IN ANTARTICA ITS ALWAYS NIGHT","offset":0,"asn":12345,"organization":"AS12345 Crappy Internet Services LLC."}'
        end
        return {
            Success = true,
            StatusCode = 200,
            StatusMessage = "OK",
            Headers = {},
            Cookies = {},
            Body = Body
        }
    elseif Parsed.Domain == "ip-api.com" then
        return {
            Success = true,
            StatusCode = 200,
            StatusMessage = "OK",
            Headers = {},
            Cookies = {},
            Body = '{"query":"127.0.0.1","status":"success","continent":"Antartica","continentCode":"AN","country":"Australlia","countryCode":"AU","region":"TAS","regionName":"Tasmania","city":"Tasmanian Devil\'s Cave","district":"","zip":"7000","lat":0,"lon":0,"timezone":"I LIVE IN ANTARTICA ITS ALWAYS NIGHT","offset":0,"currency":"BTC","isp":"Crappy Internet Services LLC.","org":"Crappy Internet Services LLC.","as":"AS12345 Crappy Internet Services LLC.","asname":"AS12345","mobile":false,"proxy":false,"hosting":false}'
        }
    end
    return false
end

local OldHttpGet;
OldHttpGet = hookfunction(game.HttpGet, function(self, Url) -- Second argument literally does nothing
    if Url then
        local Result = CheckURL(Url, OldRequest)
        if Result then
            return Result.Body
        end
    end
    return OldHttpGet(self, Url)
end)

if pcall(function() return game.HttpPost end) then
    local OldHttpPost;
    OldHttpPost = hookfunction(game.HttpPost, function(self, Url, Body, ...)
        if Url then
            local Result = CheckURL(Url, OldRequest)
            if Result then
                return Result.Body
            end
        end
        return OldHttpPost(self, Url, Body, ...)
    end)
end

if http_request then
    local OldRequest;
    OldRequest = hookfunction(http_request, newcclosure(function(Options, ...)
        if Options.Url then
            local Result = CheckURL(Options.Url, OldRequest)
            if Result then
                return Result
            end
        end
        return OldRequest(Options, ...)
    end))
end

if request then
    local OldRequest;
    OldRequest = hookfunction(request, newcclosure(function(Options, ...)
        if Options.Url then
            local Result = CheckURL(Options.Url, OldRequest)
            if Result then
                return Result
            end
        end
        return OldRequest(Options, ...)
    end))
end

if http and http.request then
    local OldRequest;
    OldRequest = hookfunction(http.request, newcclosure(function(Options, ...)
        if Options.Url then
            local Result = CheckURL(Options.Url, OldRequest)
            if Result then
                return Result
            end
        end
        return OldRequest(Options, ...)
    end))
end

if syn and syn.request then
    local OldRequest;
    OldRequest = hookfunction(syn.request, newcclosure(function(Options, ...)
        if Options.Url then
            local Result = CheckURL(Options.Url, OldRequest)
            if Result then
                return Result
            end
        end
        return OldRequest(Options, ...)
    end))
end
