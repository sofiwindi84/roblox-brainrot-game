-- Brainrot Bay conveyor spawner: every few seconds a new brainrot rolls
-- in on the conveyor, walks from the spawn pad to the end pad, and leaves
-- if nobody buys it. Clicking one buys it through the Economy.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotData = require(ReplicatedStorage.Shared.BrainrotData)
local Config = require(ReplicatedStorage.Shared.Config)
local GameState = require(script.Parent.GameState)
local BrainrotFactory = require(script.Parent.BrainrotFactory)
local Economy = require(script.Parent.Economy)

local Remotes = ReplicatedStorage.Remotes

-- The conveyor list the shop UI shows: one row per brainrot riding now.
local function BroadcastConveyorUpdate()
	local rows = {}
	for _, entry in ipairs(GameState.Conveyor) do
		table.insert(rows, {
			ModelName = entry.Model.Name,
			Id = entry.Id,
			Name = BrainrotData.GetById(entry.Id).Name,
			Rarity = BrainrotData.GetById(entry.Id).Rarity,
			Mutation = entry.Mutation,
			Price = entry.Price,
			Income = entry.Income,
		})
	end
	Remotes.ConveyorUpdate:FireAllClients(rows)
end

-- Walk one brainrot along the conveyor until it is bought or reaches the
-- end pad, where it despawns.
local function WalkConveyorBrainrot(entry)
	local model = entry.Model
	local x = Config.CONVEYOR_START_X
	while model.Parent ~= nil and model:GetAttribute("State") == "conveyor" do
		x += Config.CONVEYOR_SPEED * 0.1
		if x >= Config.CONVEYOR_END_X then
			break
		end
		BrainrotFactory.PlaceBrainrotModel(model, x, 1, 0)
		task.wait(0.1)
	end
	if model.Parent ~= nil and model:GetAttribute("State") == "conveyor" then
		for index, other in ipairs(GameState.Conveyor) do
			if other == entry then
				table.remove(GameState.Conveyor, index)
				break
			end
		end
		model:Destroy()
		BroadcastConveyorUpdate()
	end
end

-- Roll a fresh brainrot and put it on the spawn pad.
local function SpawnConveyorBrainrot()
	local rarityName = BrainrotData.RollRarity()
	local entry = BrainrotData.RollBrainrot(rarityName)
	local mutation = BrainrotData.RollMutation()
	local income = entry.Income * BrainrotData.MutationMultiplier(mutation)
	local model = BrainrotFactory.BuildBrainrotModel(entry, mutation)
	model:SetAttribute("BrainrotId", entry.Id)
	model:SetAttribute("Mutation", mutation or "")
	model:SetAttribute("Price", entry.Cost)
	model:SetAttribute("Income", income)
	model:SetAttribute("State", "conveyor")
	model:SetAttribute("Slot", 0)
	model.Parent = Workspace
	BrainrotFactory.PlaceBrainrotModel(model, Config.CONVEYOR_START_X, 1, 0)

	local record = {
		Model = model,
		Id = entry.Id,
		Mutation = mutation,
		Price = entry.Cost,
		Income = income,
	}
	table.insert(GameState.Conveyor, record)
	BroadcastConveyorUpdate()

	-- Clicking the brainrot buys it (or steals it, once it has an owner).
	local clicker = model.Body.BrainrotClicker
	clicker.MouseClick:Connect(function(player: Player)
		local ok, message = Economy.HandleBrainrotClicked(player, model)
		if ok then
			Remotes.Notify:FireClient(player, message, "good")
			BroadcastConveyorUpdate()
		else
			Remotes.Notify:FireClient(player, message, "bad")
		end
	end)

	task.spawn(WalkConveyorBrainrot, record)
end

-- The conveyor never stops.
while true do
	task.wait(Config.CONVEYOR_SPAWN_INTERVAL)
	SpawnConveyorBrainrot()
end
