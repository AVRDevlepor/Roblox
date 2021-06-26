local function Import(LibName)
    return loadstring(game:HttpGet(string.format("https://raw.githubusercontent.com/LegitH3x0R/Roblox-Scripts/main/UniversalLibs/%s.lua", LibName)))()
end

getfenv().Get = Import("Get")
getfenv().AI = Import("Pathfinding")
getfenv().URL = Import("Url")
getfenv().Class = Import("Class")
