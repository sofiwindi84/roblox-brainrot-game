-- Brainrot Bay game state: the one place the whole server keeps its
-- mutable data. Server scripts read and change this table; nothing else
-- on the server holds player money, plots or conveyor brainrots.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local GameState = {}

-- One record per player in the game.
-- Cash: the player's spendable money.
-- Rebirths: how many times the player has rebirthed.
-- Multiplier: permanent income multiplier (1 + 0.5 per rebirth).
-- Plot: the plot number the player owns (nil when the island is full).
-- Brainrots: {[model] = { Id, Mutation, Income, Slot }}.
-- LockedUntil / LockCooldownUntil / StealCooldownUntil: os.time() stamps.
GameState.Players = {}

-- One record per plot: the plot Part and the player who owns it (or nil).
GameState.Plots = {}

-- Brainrots currently riding the conveyor:
-- { Model, Id, Mutation, Price, Income }.
GameState.Conveyor = {}

-- The tsunami clock: the os.time() stamp of the next wave. It starts
-- here, at module load, so the wave timer is correct no matter which
-- server script the engine happens to run first.
GameState.Tsunami = { NextWaveAt = os.time() + Config.TSUNAMI_INTERVAL_SECONDS }

-- A fresh player record for a plot number.
function GameState.NewPlayerData(plotNumber: number?)
	return {
		Cash = Config.START_CASH,
		Rebirths = 0,
		Multiplier = 1,
		Plot = plotNumber,
		Brainrots = {},
		LockedUntil = 0,
		LockCooldownUntil = 0,
		StealCooldownUntil = 0,
	}
end

-- The first plot nobody owns, or nil when all eight are taken.
function GameState.FirstFreePlot(): number?
	for number = 1, Config.PLOT_COUNT do
		if GameState.Plots[number].Owner == nil then
			return number
		end
	end
	return nil
end

-- The plot Part for a plot number.
function GameState.PlotPart(plotNumber: number): BasePart
	return GameState.Plots[plotNumber].Part
end

-- Where a brainrot sits on a plot: six slots in two rows of three.
function GameState.SlotPosition(plotNumber: number, slotIndex: number): Vector3
	local part = GameState.PlotPart(plotNumber)
	local center = part.Position
	local columns = { -6, 0, 6 }
	local rows = { -5, 5 }
	local column = columns[((slotIndex - 1) % 3) + 1]
	local row = rows[math.floor((slotIndex - 1) / 3) + 1]
	return Vector3.new(center.X + column, 1.3, center.Z + row)
end

-- The first free slot index on a player's plot, or nil when it is full.
function GameState.FreeSlot(data): number?
	for slot = 1, Config.PLOT_SLOTS do
		local taken = false
		for _, record in pairs(data.Brainrots) do
			if record.Slot == slot then
				taken = true
				break
			end
		end
		if not taken then
			return slot
		end
	end
	return nil
end

-- True when the player's character stands inside their own plot.
function GameState.IsPlayerOnOwnPlot(player: Player): boolean
	local data = GameState.Players[player]
	if data == nil or data.Plot == nil then
		return false
	end
	local character = player.Character
	if character == nil then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	local part = GameState.PlotPart(data.Plot)
	local position = root.Position
	return math.abs(position.X - part.Position.X) <= 11
		and math.abs(position.Z - part.Position.Z) <= 11
end

-- True while the player's base lock is holding.
function GameState.IsBaseLocked(data): boolean
	return os.time() < data.LockedUntil
end

return GameState
