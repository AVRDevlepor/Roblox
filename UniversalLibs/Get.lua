local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Player.CharacterAdded:Connect(function(C)
    Character = C
end)

local function GetAllPlayers(CheckFunc)
    local Plrs = {}
    for _, Plr in pairs(Players:GetPlayers()) do
        if CheckFunc(Plr) and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plrs[#Plrs + 1] = Plr
        end
    end

    return Plrs
end

local function GetClosestPlayer(From, CheckFunc)
    CheckFunc = CheckFunc or function()
        return true
    end

    local Closest = {
        Distance = math.huge,
        User = nil,
        Char = nil,
        Root = nil
    }

    for _, Plr in pairs(Players:GetPlayers()) do
        if CheckFunc(Plr) and Plr ~= Player and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            local Dist = ((From or Character.HumanoidRootPart.Position) - Plr.Character.HumanoidRootPart.Position).Magnitude
            if (Dist < Closest.Distance) then
                Closest.Distance = Dist
                Closest.User = Plr
                Closest.Char = Plr.Character
                Closest.Root = Plr.Character.HumanoidRootPart.Position
            end
        end
    end

    return Closest
end

local function GetClosestObject(Objects)
    local Closest = {
        Distance = math.huge,
        Object = nil
    }

    for _, Object in pairs(Objects) do
        local Dist = (Character.HumanoidRootPart.Position - Object.Position).Magnitude
        if (Dist < Closest.Distance) then
            Closest.Distance = Dist
            Closest.Object = Object
        end
    end

    return Closest
end

local function GetClosestObjects(Objects)
    local Closest = {
        Distance = math.huge,
        Object = nil
    }

    for _, Object in pairs(Objects) do
        local Dist = (Character.HumanoidRootPart.Position - Object.Position).Magnitude
        if (Dist < Closest.Distance) then
            Closest.Distance = Dist
            Closest.Object = Object
        end
    end

    return Closest
end

return {
    AllPlayers = GetAllPlayers,
    ClosestPlayer = GetClosestPlayer,
    ClosestObject = GetClosestObject,
    ClosestObjects = GetClosestObjects
}
