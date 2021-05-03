-- R15 ONLY
local HatName = "jason"

local CharSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local function RandString(Len)
    local Rand = ""
    for _ = 1, Len do
        local Pos = math.random(1, #CharSet)
        Rand = Rand..CharSet:sub(Pos, Pos)
    end

    return Rand
end

local IsOwner = loadstring(game:HttpGet("https://bit.ly/gainownership"))()
if not IsOwner then error("Failed to claim ownership") return end

local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character
local LT = Character.LowerTorso

local ToGive;
for _, Hat in pairs(Character:GetChildren()) do
    if Hat.ClassName == "Accessory" and Hat:FindFirstChild("Handle") then
        if string.lower(Hat.Name) == string.lower(HatName) then
            ToGive = Hat
        end
    end
end
if not ToGive then error("Hat not found.") return end

local Att = ToGive.Handle:FindFirstChildOfClass("Attachment")
local Offset = Vector3.new(0, 0.6, 0) - Att.Position
ToGive.Handle.AccessoryWeld:Destroy()

local Mover = Instance.new("BodyPosition")
Mover.Name = RandString(10)
Mover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
Mover.Parent = ToGive.Handle

local RotLocker = Instance.new("BodyGyro")
RotLocker.Name = RandString(10)
RotLocker.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
RotLocker.P = 9e4
RotLocker.Parent = ToGive.Handle

local Connection;
Connection = RunService.Stepped:Connect(function()
    if not LT then Connection:Disconnect() end
    pcall(function()
        local Set = LT.Position + Offset
        Mover.Position = Set
        ToGive.Handle.Position = Set
        RotLocker.CFrame = LT.CFrame
    end)
end)

Character.UpperTorso.Waist:Destroy()
