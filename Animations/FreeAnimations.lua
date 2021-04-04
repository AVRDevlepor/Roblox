-- R15 Animation Overwriting
local Idle  = 5319828216
local Walk  = 5319847204
local Run   = 5319844329
local SIdle = 5319852613
local Swim  = 5319850266
local Fall  = 5319839762
local Jump  = 5319841935
local Climb = 5319816685


if not game:IsLoaded() then
    game.Loaded:Wait()
end

local split = string.split
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
Player.CharacterAdded:Connect(function(C)
    Character = C
end)

local AnimationsList = {
    ["idle.Animation1"] = tostring(Idle),
    ["idle.Animation2"] = tostring(Idle),
    ["walk.WalkAnim"] = tostring(Walk),
    ["run.RunAnim"] = tostring(Run),
    ["swimidle.SwimIdle"] = tostring(SIdle),
    ["swim.Swim"] = tostring(Swim),
    ["fall.FallAnim"] = tostring(Fall),
    ["jump.JumpAnim"] = tostring(Jump),
    ["climb.ClimbAnim"] = tostring(Climb)
}

function OverwriteAnimations(Character)
    local Hum = Character:WaitForChild("Humanoid")
    if Hum.RigType == Enum.HumanoidRigType.R15 then
        local AnimationScript = Character:WaitForChild("Animate")
        for Key, Value in pairs(AnimationsList) do
            local Children = split(Key, ".")
            local Container = AnimationScript:WaitForChild(Children[1])
            local Anim = Container:WaitForChild(Children[2])
            Anim.AnimationId = "rbxassetid://"..Value
        end
    else
        if not ANIM_WARNED then
            warn("Animations were not overwritten. Reason: R6.")
            getgenv().ANIM_WARNED = true
        end
    end
end

if Character then OverwriteAnimations(Character) end
Player.CharacterAdded:Connect(OverwriteAnimations)
