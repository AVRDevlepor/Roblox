local Pathfinding = game:GetService("PathfindingService")
local function GetWaypoints(From, To)
	local Path = Pathfinding:CreatePath()
	Path:ComputeAsync(From, To)
	if Path.Status == Enum.PathStatus.Success then
		return Path:GetWaypoints()
	else
		return false
	end
end

local function DrawWaypoints(Waypoints, YOffset)
	YOffset = YOffset and (YOffset + 3) or 3
	local Points = {}
	for Idx, Point in pairs(Waypoints) do
		local PointP = Instance.new("Part")
		PointP.Name = ""
		PointP.Anchored = true
		PointP.CanCollide = false
		PointP.Position = Point.Position
		PointP.Orientation = Vector3.new(-90, 0, 0)
		PointP.Size = Vector3.new(0.5, 0.5, 0.5)
		PointP.Material = Enum.Material.SmoothPlastic
		PointP.BrickColor = BrickColor.new("New Yeller")
		PointP.Parent = workspace
		Points[#Points + 1] = PointP
	end
	return Points
end

local function Navigate(Char, Waypoints, MaxTime)
	MaxTime = MaxTime or math.huge	
	local WaypointIdx, Done = 0, false
	local MoveToHasFinished;
	local function NextWaypoint()
		WaypointIdx = WaypointIdx + 1
		local Point = Waypoints[WaypointIdx]
		if Point.Action == Enum.PathWaypointAction.Jump then
			Char.Humanoid.Jump = true
		end
		Char.Humanoid:MoveTo(Point.Position)
		if WaypointIdx == #Waypoints then MoveToHasFinished:Disconnect() Done = true end
	end
	MoveToHasFinished = Char.Humanoid.MoveToFinished:Connect(NextWaypoint)
	local Start = tick()
	NextWaypoint()
	repeat wait(0.5) if (tick() - Start) > 120 then MoveToHasFinished:Disconnect() Done = true end until Done
end

return {
	GetWaypoints = GetWaypoints,
	DrawWaypoints = DrawWaypoints,
	Navigate = Navigate
}
