local GunHatName    = "Meshes/RainbowSniperAccessory"
local BulletHatName = "Meshes/Bucket HatAccessory"
-- including the brown (man) hair and pai (bacon) hair
-- doesnt work well after the half-patch roblox pushed

local NetLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/OpenGamerTips/TextBin/master/netlib.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid, Root = Character:WaitForChild("Humanoid"), Character:WaitForChild("HumanoidRootPart")

-- Bullet
local Bullet = NetLib.GetHatByName(BulletHatName)
Bullet.Mesh:Destroy()
Bullet.Inst.Parent = workspace
Bullet.Part:WaitForChild("TouchInterest"):Destroy()

local BulletMover = Instance.new("BodyPosition", Bullet.Part)
BulletMover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

local function SetBulletPos(BulletPos)
    BulletMover.Position = BulletPos.Position
    Bullet.Part.Position = BulletPos.Position
end

NetLib.MakeFlingHat(Bullet, 1e3)
SetBulletPos(Root.CFrame * CFrame.new(0, 100, 0))
Bullet.Part.CanCollide = false

-- Arms
local LArm, RArm, LArmAtt, RArmAtt = NetLib.CustomArms()

-- Gun Weld
local Gun = NetLib.GetHatByName(GunHatName)
local Gun2ArmAtt = NetLib.Weld(Gun.Part, RArm.Part,
    Vector3.new(-0.6, 0.3, -2),
    Vector3.new(0, -90, 48)
)
Gun.Weld:Destroy()

local Last;
local function BasicPose()
    TweenService:Create(RArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(1.15, 0.3, -0.5),
        Orientation = Vector3.new(-90, 0, 0)
    }):Play()
    TweenService:Create(LArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(-1.15, 0.3, -0.5),
        Orientation = Vector3.new(-90, 0, 0)
    }):Play()
    Last = BasicPose
    wait(0.3)
end

local function TwoHandedPose()
    TweenService:Create(RArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(1.15, 0.3, -0.5),
        Orientation = Vector3.new(0, 0, 0)
    }):Play()
    TweenService:Create(LArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(-0.7, 0.3, -1),
        Orientation = Vector3.new(0, -40, 0)
    }):Play()
    Last = TwoHandedPose
    wait(0.3)
end

local function OneHandedAirPose()
    TweenService:Create(RArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(1.5, 1, 0),
        Orientation = Vector3.new(90, 0, 0)
    }):Play()
    TweenService:Create(LArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(-1.5, -0.2, 0),
        Orientation = Vector3.new(-90, 0, 0)
    }):Play()
    Last = OneHandedAirPose
    wait(0.3)
end

local function ShootPoseDown()
    TweenService:Create(RArmAtt, TweenInfo.new(0.1), {
        Position = Vector3.new(1.5, 0.2, -0.5),
        Orientation = Vector3.new(0, 0, 0)
    }):Play()
    wait(0.15)
end

local function ShootPoseUp()
    TweenService:Create(RArmAtt, TweenInfo.new(0.1), {
        Position = Vector3.new(1.5, 0.2, -0.5),
        Orientation = Vector3.new(14, 0, 0)
    }):Play()
    wait(0.1)
    TweenService:Create(RArmAtt, TweenInfo.new(0.2), {
        Position = Vector3.new(1.5, 0.2, -0.5),
        Orientation = Vector3.new(0, 0, 0)
    }):Play()
    wait(0.2)
    Last()
    wait(0.3)
end

local function ScopePose()
    TweenService:Create(RArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(1.15, 0.8, -0.2),
        Orientation = Vector3.new(0, 20, 20)
    }):Play()
    TweenService:Create(LArmAtt, TweenInfo.new(0.3), {
        Position = Vector3.new(-0.7, 0.5, -1),
        Orientation = Vector3.new(-0, -50, 10)
    }):Play()
    wait(0.3)
end

-- Shoot mechanics
TwoHandedPose()
local ShootDebounce = false
local IsScoping = false
local Input1 = UIS.InputBegan:Connect(function(Input, Proc)
    if not Proc then
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            local Code = Input.KeyCode
            if Code == Enum.KeyCode.Z then
                TwoHandedPose()
            elseif Code == Enum.KeyCode.X then
                OneHandedAirPose()
            end
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
            if (Camera.CFrame.Position - Character.Head.Position).Magnitude < 2 then
                IsScoping = true
                local OldWS = Humanoid.WalkSpeed
                Humanoid.WalkSpeed = 5
                local OldFOV = Camera.FieldOfView
                TweenService:Create(Camera, TweenInfo.new(0.3), {
                    FieldOfView = 10;
                }):Play()
                ScopePose()
                LArm.Part.LocalTransparencyModifier = 1
                RArm.Part.LocalTransparencyModifier = 1
                Gun.Part.LocalTransparencyModifier = 1
                while IsScoping do
                    RunService.RenderStepped:Wait()
                end
                TweenService:Create(Camera, TweenInfo.new(0.3), {
                    FieldOfView = OldFOV;
                }):Play()
                Humanoid.WalkSpeed = OldWS
                Last()
                wait(0.3)
            end
        elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not ShootDebounce then
                ShootDebounce = true
                local Hit = Mouse.Hit
                ShootPoseDown()
                spawn(function()
                    SetBulletPos(Hit)
                    wait(0.3)
                    SetBulletPos(Root.CFrame * CFrame.new(0, 100, 0))
                end)
                local Shoot = Instance.new("Sound", workspace)
                Shoot.SoundId = "rbxassetid://2661089695"
                Shoot:Play()
                spawn(function()
                    wait(Shoot.TimeLength)
                    Shoot:Destroy()
                end)
                ShootPoseUp()
                ShootDebounce = false
            end
        end
    end
end)

local Input2 = UIS.InputEnded:Connect(function(Input, Proc)
    if not Proc then
        if Input.UserInputType == Enum.UserInputType.MouseButton2 then
            IsScoping = false
        end
    end
end)

spawn(function()
    while wait(0.1) do
        if not pcall(function()
            if (Camera.CFrame.Position - Character.Head.Position).Magnitude < 2 and not IsScoping then
                LArm.Part.LocalTransparencyModifier = 0
                RArm.Part.LocalTransparencyModifier = 0
                Gun.Part.LocalTransparencyModifier = 0
            end
        end) then return end
    end
end)

Humanoid.Died:Wait()
Input1:Disconnect()
Input2:Disconnect()
