-- Brainrot Bay tsunami event: every few minutes the island gets a
-- warning, then a wave sweeps from west to east. Players standing on
-- their own base plot stay dry; anyone caught out in the open loses a
-- share of their Cash.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local GameState = require(script.Parent.GameState)

local Remotes = ReplicatedStorage.Remotes

-- Warn every player, then sweep the wave across the island.
local function RunTsunamiWave()
	for _, player in ipairs(Players:GetPlayers()) do
		Remotes.Notify:FireClient(player, "TSUNAMI INCOMING! Run to your base plot!", "warn")
	end
	task.wait(Config.TSUNAMI_WARNING_SECONDS)

	local wave = Instance.new("Part")
	wave.Name = "TsunamiWave"
	wave.Size = Vector3.new(12, 14, 240)
	wave.Color = Color3.fromRGB(30, 120, 220)
	wave.Material = Enum.Material.SmoothPlastic
	wave.Transparency = 0.4
	wave.Anchored = true
	wave.CanCollide = false
	wave.Parent = Workspace

	local x = -130
	while x <= 130 do
		wave.CFrame = CFrame.new(x, 4, 0)
		x += 4
		task.wait(0.08)
	end
	wave:Destroy()

	-- The wave has passed: charge everyone caught outside their own plot.
	for _, player in ipairs(Players:GetPlayers()) do
		local data = GameState.Players[player]
		if data ~= nil then
			if GameState.IsPlayerOnOwnPlot(player) then
				Remotes.Notify:FireClient(player, "You stayed dry on your base!", "good")
			else
				local lost = math.floor(data.Cash * Config.TSUNAMI_CASH_LOSS)
				data.Cash -= lost
				if data.CashValue ~= nil then
					data.CashValue.Value = data.Cash
				end
				Remotes.Notify:FireClient(
					player,
					"The tsunami caught you! You lost $" .. tostring(lost) .. ".",
					"bad"
				)
			end
		end
	end
end

-- The wave comes on a steady clock, forever.
while true do
	local waitSeconds = GameState.Tsunami.NextWaveAt - os.time()
	if waitSeconds > 0 then
		task.wait(waitSeconds)
	end
	RunTsunamiWave()
	GameState.Tsunami.NextWaveAt = os.time() + Config.TSUNAMI_INTERVAL_SECONDS
end
