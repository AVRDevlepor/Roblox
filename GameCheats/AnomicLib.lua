local queuetp = (syn and syn.queue_on_teleport) or queue_on_teleport
assert(queuetp, "Trash exploit.")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TPS = game:GetService("TeleportService")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events")

local Lib = {}
function Lib.ResetCash()
	Remote.FillUpCar:FireServer(workspace.PlayerVehicles:GetChildren()[1], math.huge)
	TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end

function Lib.GiveCash(Plr, Amount)
	Remote.GiveMoneyToPlr:FireServer(Plr, tostring(Amount))
end

return Lib
