--[[
    H3x0Rs Netless Reanimation Script v2.5
    Changelog:
        1.0.1: Made hats less jittery.
        1.1.0: Added more ways to reset the reanimated character.
        2.0.0: Code revision, R15 support, different method.
        2.0.1: Fixed a bug where the HRP would detach on death.
        2.2.0: Added fling.
        2.3.0: Bugfixes, reanimation check.
        2.4.0: Lots of bug fixes and feature additions.
               Different method used for hat moving. Jitter is pretty much gone.
        2.4.1: Bug fixes, more understandable weld function.
        2.5.0: Update for FE script support.
               The script will export certain functions and hats.

    Issues that can't be fixed:
        Fling can break message bubbles, with it either not showing at all or moving all over the place due to root rotation.
        Head falls off when you are dead (This happens instantly with fling) and a player claims network ownership of it. I recommend shadowed head if you want your head still.
        Executing this script (Initilization only) too close to another player will cause them to claim ownership of your limbs and other body parts. Those parts will not exist.

    Fixable Issues:
        None.

    TODO:
        Nohead mode.
]]

ReanimateSettings = ReanimateSettings or {WeldHats = true, DoProxyCollision = false}
local WeldHats = ReanimateSettings.WeldHats
local Fling = ReanimateSettings.Fling
local ReloadCharacterScripts = ReanimateSettings.ReloadCharacterScripts
local DoProxyCollision = ReanimateSettings.DoProxyCollision























local MaidCreator = loadstring(game:HttpGet("https://pastebin.com/raw/2rKm8kKJ"))()
local Maid = MaidCreator.new()

-- Constants:
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local setsimulationradius = setsimulationradius or (sethiddenproperty and function(N) sethiddenproperty(Player, "SimulationRadius", N) end or function() end)
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Get hats
local Hats = {}
for _, Obj in next, Character:GetChildren() do -- Find hats.
    if Obj.ClassName == "Accessory" then
        Hats[Obj.Name] = Obj.Handle
    end
end

local Heartbeat = game:GetService("RunService").Heartbeat
local Stepped = game:GetService("RunService").Stepped
local RenderStepped = game:GetService("RunService").RenderStepped

local function wait(Duration) -- Fast wait implementation.
    Duration = Duration or 0 -- 1 render tick
    local T = os.clock()
    repeat RenderStepped:Wait() until os.clock() - T >= Duration
end

local Weld = loadstring(game:HttpGet("https://pastebin.com/raw/5TAPiShy"))()
if Character.Parent.ClassName == "Folder" and Character.Parent.Name == "Proxy" then
    return {Success = true, Message = "You are already reanimated", Hats = Hats, Weld = Weld, Wait = wait}
end

-- Start the script for real
local Container = Instance.new("Folder")
Container.Name = "Proxy"
Container.Parent = Character

local RegdParts = {}
local function Register(Part)
    if type(Part) == "table" then
        for _, aPart in next, Part do
            if aPart:IsA("BasePart") then
                RegdParts[#RegdParts + 1] = aPart
            end
        end
    else
        RegdParts[#RegdParts + 1] = Part
    end
end

Maid(Heartbeat:Connect(function()
    setsimulationradius(1000) -- Max allowed simulation radius.
    for _, Part in next, RegdParts do
        Part.Velocity = Vector3.new(26, 0, 0) -- Keeps the part in a physical state so others can't claim it back.
    end
end))

for _, Motor in next, Character:GetDescendants() do -- Break the motors off except the Root and Neck motor. (RootJoint motor for R6)
	if Motor.ClassName == "Motor6D" and Motor.Name ~= "Neck" then
        Motor:Destroy()
	end
end

local Proxy = game:GetObjects("rbxassetid://7110839130")[1] -- I would clone, but since this is for both rig types I will not.
if DoProxyCollision then
    Maid(Stepped:Connect(function()
        for _, Part in next, Character:GetDescendants() do
            if Part:IsA("BasePart") and not Part:IsDescendantOf(Proxy) then
                Part.CanCollide = false
            end
        end
    end))
else
    Maid(Stepped:Connect(function()
        for _, Part in next, Character:GetDescendants() do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end))
end

Proxy.Name = Player.Name
for _, Obj in next, Proxy:GetChildren() do
    if Obj:IsA("BasePart") then
        Obj.Transparency = 1
    end
end
Proxy.Parent = Container
Camera.CameraSubject = Proxy.Head
Proxy.Humanoid.BreakJointsOnDeath = false
Register(Character:GetChildren())
Proxy.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame

if Character:FindFirstChild("Animate") then -- Disable the character animator and clone one into the proxy.
    Character.Animate:Destroy()
end

for _, Anim in next, Character.Humanoid.Animator:GetPlayingAnimationTracks() do -- Stop all animations.
    Anim:Stop()
end

-- R6: Weld straight onto the parts. R15: Create attachments to fill in the parts then weld. (R15 gave me hand cancer from typing so much...)
if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
    local UpperTorsoAtt = Instance.new("Attachment", Proxy.Torso)
    UpperTorsoAtt.Name = "UpperTorsoAttachment"
    UpperTorsoAtt.Position = Vector3.new(0, 0.15, 0)

    local LowerTorsoAtt = Instance.new("Attachment", Proxy.Torso)
    LowerTorsoAtt.Name = "LowerTorsoAttachment"
    LowerTorsoAtt.Position = Vector3.new(0, -0.8, 0)

    local LUpperArmAttachment = Instance.new("Attachment", Proxy["Left Arm"])
    LUpperArmAttachment.Name = "UpperArmAttachment"
    LUpperArmAttachment.Position = Vector3.new(0, 0.4, 0)

    local LLowerArmAttachment = Instance.new("Attachment", Proxy["Left Arm"])
    LLowerArmAttachment.Name = "LowerArmAttachment"
    LLowerArmAttachment.Position = Vector3.new(0, -0.194, 0)

    local LHandAttachment = Instance.new("Attachment", Proxy["Left Arm"])
    LHandAttachment.Name = "HandAttachment"
    LHandAttachment.Position = Vector3.new(0, -0.85, 0)

    local RUpperArmAttachment = Instance.new("Attachment", Proxy["Right Arm"])
    RUpperArmAttachment.Name = "UpperArmAttachment"
    RUpperArmAttachment.Position = Vector3.new(0, 0.4, 0)

    local RLowerArmAttachment = Instance.new("Attachment", Proxy["Right Arm"])
    RLowerArmAttachment.Name = "LowerArmAttachment"
    RLowerArmAttachment.Position = Vector3.new(0, -0.194, 0)

    local RHandAttachment = Instance.new("Attachment", Proxy["Right Arm"])
    RHandAttachment.Name = "HandAttachment"
    RHandAttachment.Position = Vector3.new(0, -0.85, 0)

    local LUpperLegAttachment = Instance.new("Attachment", Proxy["Left Leg"])
    LUpperLegAttachment.Name = "UpperLegAttachment"
    LUpperLegAttachment.Position = Vector3.new(0, 0.4, 0)

    local LLowerLegAttachment = Instance.new("Attachment", Proxy["Left Leg"])
    LLowerLegAttachment.Name = "LowerLegAttachment"
    LLowerLegAttachment.Position = Vector3.new(0, -0.194, 0)

    local LFootAttachment = Instance.new("Attachment", Proxy["Left Leg"])
    LFootAttachment.Name = "FootAttachment"
    LFootAttachment.Position = Vector3.new(0, -0.85, 0)

    local RUpperLegAttachment = Instance.new("Attachment", Proxy["Right Leg"])
    RUpperLegAttachment.Name = "UpperLegAttachment"
    RUpperLegAttachment.Position = Vector3.new(0, 0.4, 0)

    local RLowerLegAttachment = Instance.new("Attachment", Proxy["Right Leg"])
    RLowerLegAttachment.Name = "LowerLegAttachment"
    RLowerLegAttachment.Position = Vector3.new(0, -0.194, 0)

    local RFootAttachment = Instance.new("Attachment", Proxy["Right Leg"])
    RFootAttachment.Name = "FootAttachment"
    RFootAttachment.Position = Vector3.new(0, -0.85, 0)

    Weld(Character.UpperTorso, UpperTorsoAtt)
    Weld(Character.LowerTorso, LowerTorsoAtt)
    Weld(Character.LeftUpperArm, LUpperArmAttachment)
    Weld(Character.LeftLowerArm, LLowerArmAttachment)
    Weld(Character.LeftHand, LHandAttachment)
    Weld(Character.RightUpperArm, RUpperArmAttachment)
    Weld(Character.RightLowerArm, RLowerArmAttachment)
    Weld(Character.RightHand, RHandAttachment)
    Weld(Character.LeftUpperLeg, LUpperLegAttachment)
    Weld(Character.LeftLowerLeg, LLowerLegAttachment)
    Weld(Character.LeftFoot, LFootAttachment)
    Weld(Character.RightUpperLeg, RUpperLegAttachment)
    Weld(Character.RightLowerLeg, RLowerLegAttachment)
    Weld(Character.RightFoot, RFootAttachment)
elseif Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
    Weld(Character.Torso, Proxy.Torso)
    Weld(Character["Left Arm"], Proxy["Left Arm"])
    Weld(Character["Right Arm"], Proxy["Right Arm"])
    Weld(Character["Left Leg"], Proxy["Left Leg"])
    Weld(Character["Right Leg"], Proxy["Right Leg"])
else -- If any future rigs come out...
    error("Rig not supported!")
end

local HatWeldDestination = Instance.new("Attachment", Proxy.Torso)
HatWeldDestination.Name = "HatWeldDst"

if WeldHats then
    Register(Hats)
    for _, Handle in next, Hats do
        local Att0 = Instance.new("Attachment", Handle)
        Att0.Name = "HatWeld"
        Att0.CFrame = Proxy.Torso.CFrame:ToObjectSpace(Handle.CFrame)
        Handle.Massless = true
        wait(0.05) -- random roblox bug made it so some hats wouldnt weld
        Handle:FindFirstChildOfClass("Weld"):Destroy()
    end
else
    for _, Handle in next, Hats do
        Handle:FindFirstChildOfClass("Weld"):Destroy()
    end
end

local Box;
if Fling then
    local Root = Character.HumanoidRootPart
    local Thrust = Instance.new("BodyThrust")
    Thrust.Name = "Flinger"
    Thrust.Force = Vector3.new(9e6, 9e6, 9e6)
    Thrust.Location = Vector3.new(0, 0, 500)
    Thrust.Parent = Root

    Box = Instance.new("SelectionBox")
    Box.Name = "View"
    Box.LineThickness = 0.1
    Box.Color3 = Color3.new(1, 0, 0)
    Box.Adornee = Root
    Box.Parent = Root

    Weld(Root, Proxy.HumanoidRootPart, true, false)
else
    Weld(Character.HumanoidRootPart, Proxy.HumanoidRootPart)
end

Maid(Heartbeat:Connect(function()
    Character.Head.CFrame = Proxy.Torso.CFrame * CFrame.new(0, 1.5, 0)
    if Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then-- Jitter fix for only R6 because im lazy.
        if Character:FindFirstChild("Torso") then Character.Torso.CFrame = Proxy.Torso.CFrame end
        if Character:FindFirstChild("Left Arm") then Character["Left Arm"].CFrame = Proxy["Left Arm"].CFrame end
        if Character:FindFirstChild("Right Arm") then Character["Right Arm"].CFrame = Proxy["Right Arm"].CFrame end
        if Character:FindFirstChild("Left Leg") then Character["Left Leg"].CFrame = Proxy["Left Leg"].CFrame end
        if Character:FindFirstChild("Right Leg") then Character["Right Leg"].CFrame = Proxy["Right Leg"].CFrame end
    end
    for Index, Handle in next, Hats do
        if not Handle:FindFirstChild("HatWeld") then Hats[Index] = nil end
        Handle.CFrame = Proxy.Torso.CFrame * Handle.HatWeld.CFrame -- Set position directly, this is a better idea than movers.
    end
end))

Maid(Camera:GetPropertyChangedSignal("CFrame"):Connect(function()
    if (Camera.CFrame.Position - Proxy.Head.CFrame.Position).Magnitude < 1 then
        for _, Obj in next, Character:GetDescendants() do
            if Obj:IsA("BasePart") then
                Obj.LocalTransparencyModifier = 1
            end
        end
    else
        for _, Obj in next, Character:GetDescendants() do
            if Obj:IsA("BasePart") then
                Obj.LocalTransparencyModifier = 0
            end
        end
    end
end))

Stepped:Wait() -- Wait a physics frame.
Player.Character = Proxy
Camera.CameraSubject = Proxy.Humanoid
coroutine.wrap(loadstring(game:HttpGet("https://raw.githubusercontent.com/LegitH3x0R/Roblox-Scripts/main/Animations/R6Animate.lua")))()

if ReloadCharacterScripts then
    for _, Obj in next, Character:GetDescendants() do
        if Obj.ClassName == "LocalScript" or Obj.ClassName == "ModuleScript" and Obj.Name ~= "Animate" then
            Obj:Clone().Parent = Proxy
        end
    end
end

local Respawning = false
local function Respawn()
    if not Respawning then -- Debounce just in case
        Respawning = true
        Maid:Clean()
        Player.Character = Character
        RenderStepped:Wait() -- Just in case
        Character:Destroy()
        StarterGui:SetCore("ResetButtonCallback", true) -- Reset the callback.
    end
end

local ResetBind = Instance.new("BindableEvent")
ResetBind.Event:Connect(Respawn)
StarterGui:SetCore("ResetButtonCallback", ResetBind) -- Dying via the "Reset Character" button. (Why do I need a BindableEvent? Seems like too much.)
Proxy.Humanoid.Died:Connect(Respawn) -- Obviously just dying via anything pretty much.
Character.ChildRemoved:Connect(function(Child) -- Dying via falling out of the map (Kinda hacky but works).
    if Child.Name == "Head" and Child:IsA("BasePart") then
        Respawn()
    end
end)

wait(Players.RespawnTime + 0.1) -- Wait until death is bypassed.
if Fling then -- When flinging it only flings well when the character is dead lol.
    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    Box.Color3 = Color3.new(0, 1, 0) -- Flinging will work now!
end

return {Success = true, Message = "Success", Hats = Hats, Weld = Weld, Wait = wait}
