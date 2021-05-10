local ShowTeam = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Gui = Instance.new("ScreenGui")
Gui.Name = "RobloxGui" -- Mask the name of roblox's gui to avoid detection (FindFirstChild attacks) if you can't hide the gui.
if syn then
	syn.protect_gui(Gui)
	Gui.Parent = game:GetService("CoreGui")
elseif get_hidden_gui then
	Gui.Parent = get_hidden_gui()
else
	Gui.Parent = game:GetService("CoreGui")
end

local function NewBox(Part, Color, Size)
	local Box = Instance.new("BoxHandleAdornment")
	Box.Size = Size or Vector3.new(Part.Size.X + 0.05, Part.Size.Y + 0.05, Part.Size.Z + 0.05)
	Box.Adornee = Part
	Box.Name = ""
	Box.ZIndex = 0
	Box.Color3 = Color or Color3.fromRGB(255, 255, 255)
	Box.AlwaysOnTop = true
	Box.Parent = Gui
	Box:GetPropertyChangedSignal("Adornee"):Connect(function() Box:Destroy() end)
	return Box
end

local function MakeBoxes(Character, Color, Ignore)
	local Boxes = {}
	for _, Part in pairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") and (Ignore and not Ignore[Part.Name] or true) then
			if Part.Name == "Head" then
				Boxes[#Boxes + 1] = NewBox(Part, Color, Vector3.new(1.2, 1.2, 1.2))
			elseif Part.Name ~= "Handle" then
				Boxes[#Boxes + 1] = NewBox(Part, Color)
			end
		end
	end
	return Boxes
end

if game.PlaceId == 292439477 then -- PF
	local PlayersFolder, Registered = workspace.Players, {}
	local function Chams(Character)
		if LocalPlayer.Character == Character then return end
		Registered[Character] = true
		local Boxes, Conn = {}					
		if Character.Parent.Name == "Phantoms" then
			Boxes = MakeBoxes(Character, ShowTeam and BrickColor.new("Bright blue").Color or nil, {["HumanoidRootPart"] = true})
		else
			Boxes = MakeBoxes(Character, ShowTeam and BrickColor.new("Bright orange").Color or nil, {["HumanoidRootPart"] = true})
		end
		
		Conn = Character.Parent.ChildRemoved:Connect(function(C)
			if C == Character then
				Registered[Character] = nil
				Conn:Disconnect()
				for _, Box in pairs(Boxes) do
					Box:Destroy()
				end
			end
		end)
	end

	while wait(1) do
		for _, Character in pairs(PlayersFolder:GetDescendants()) do
			if Character.Name == "Player" and not Registered[Character] then
				Chams(Character)
			end
		end
	end
elseif game.PlaceId == 286090429 then -- Arsenal
	local function Chams(Player)
		if LocalPlayer == Player then return end
		
		local Character = Player.Character or Player.CharacterAdded:Wait()
		MakeBoxes(Character, ShowTeam and Player.TeamColor.Color or nil, {["Hitbox"] = true, ["HeadHB"] = true, ["ParticleArea"] = true, ["FakeHead"] = true, ["HumanoidRootPart"] = true}) -- why
		Player.CharacterAdded:Connect(function(C) MakeBoxes(C, ShowTeam and Player.TeamColor.Color or nil, {["Hitbox"] = true, ["HeadHB"] = true, ["ParticleArea"] = true, ["FakeHead"] = true, ["HumanoidRootPart"] = true}) end)
	end

	Players.PlayerAdded:Connect(Chams)
	for _, Player in pairs(Players:GetPlayers()) do
		Chams(Player)
	end
else
	local function Chams(Player)
		if LocalPlayer == Player then return end
		
		local Character = Player.Character or Player.CharacterAdded:Wait()
		MakeBoxes(Character, ShowTeam and Player.TeamColor.Color or nil, {["HumanoidRootPart"] = true})
		Player.CharacterAdded:Connect(function(C) MakeBoxes(C, ShowTeam and Player.TeamColor.Color or nil, {["HumanoidRootPart"] = true}) end)
	end

	Players.PlayerAdded:Connect(Chams)
	for _, Player in pairs(Players:GetPlayers()) do
		Chams(Player)
	end
end
