-- Brainrot Bay economy: every rule about money, buying, stealing,
-- locking and rebirthing lives in this one module, so no other script can
-- hand out Cash or move a brainrot on its own.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotData = require(ReplicatedStorage.Shared.BrainrotData)
local Config = require(ReplicatedStorage.Shared.Config)
local GameState = require(script.Parent.GameState)
local BrainrotFactory = require(script.Parent.BrainrotFactory)

local Economy = {}

-- How much Cash a player earns every second: every brainrot on their plot,
-- its income times its mutation, times the player's rebirth multiplier.
function Economy.ComputeIncome(data): number
	local total = 0
	for _, record in pairs(data.Brainrots) do
		total += record.Income * BrainrotData.MutationMultiplier(record.Mutation)
	end
	return math.floor(total * data.Multiplier)
end

-- The Cash a rebirth costs at the player's current rebirth count.
function Economy.RebirthCost(data): number
	return Config.REBIRTH_BASE_COST * (data.Rebirths + 1)
end

-- Find who owns a plot brainrot, and their record for it.
function Economy.FindBrainrotOwner(model: Model): (Player?, any?)
	for player, data in pairs(GameState.Players) do
		local record = data.Brainrots[model]
		if record ~= nil then
			return player, record
		end
	end
	return nil, nil
end

-- Move a brainrot model onto a player's plot at a free slot.
function Economy.PlaceOnPlot(player: Player, model: Model, record)
	local data = GameState.Players[player]
	local slot = GameState.FreeSlot(data)
	if slot == nil then
		return false, "Your base is full!"
	end
	local position = GameState.SlotPosition(data.Plot, slot)
	BrainrotFactory.PlaceBrainrotModel(model, position.X, 0.3, position.Z)
	record.Slot = slot
	model:SetAttribute("State", "plot")
	model:SetAttribute("Slot", slot)
	data.Brainrots[model] = record
	return true, "Bought!"
end

-- Buy a brainrot riding the conveyor. Returns success and a message.
function Economy.BuyBrainrot(player: Player, model: Model): (boolean, string)
	local data = GameState.Players[player]
	if data == nil then
		return false, "You are not in the game yet."
	end
	if data.Plot == nil then
		return false, "No free base plot left on the island."
	end
	if model:GetAttribute("State") ~= "conveyor" then
		return false, "That brainrot already left the conveyor."
	end
	local price = model:GetAttribute("Price")
	if data.Cash < price then
		return false, "Not enough Cash! You need $" .. tostring(price) .. "."
	end
	-- Take it off the conveyor list so nobody else can buy it.
	for index, entry in ipairs(GameState.Conveyor) do
		if entry.Model == model then
			table.remove(GameState.Conveyor, index)
			break
		end
	end
	data.Cash -= price
	local record = {
		Id = model:GetAttribute("BrainrotId"),
		Mutation = model:GetAttribute("Mutation"),
		Income = model:GetAttribute("Income"),
		Slot = 0,
	}
	local placed, message = Economy.PlaceOnPlot(player, model, record)
	if not placed then
		data.Cash += price
		return false, message
	end
	return true, "Bought " .. BrainrotData.GetById(record.Id).Name .. " for $" .. tostring(price) .. "!"
end

-- Steal a brainrot from another player's plot. Returns success and a message.
function Economy.StealBrainrot(player: Player, model: Model): (boolean, string)
	local data = GameState.Players[player]
	if data == nil then
		return false, "You are not in the game yet."
	end
	if data.Plot == nil then
		return false, "You need a base plot of your own first."
	end
	local owner, record = Economy.FindBrainrotOwner(model)
	if owner == nil then
		return false, "That brainrot has no owner to steal from."
	end
	if owner == player then
		return false, "That brainrot is already yours."
	end
	local ownerData = GameState.Players[owner]
	if GameState.IsBaseLocked(ownerData) then
		return false, owner.Name .. "'s base is locked!"
	end
	if os.time() < data.StealCooldownUntil then
		return false, "Stealing needs a moment to recharge."
	end
	-- Check for a free slot before spending the cooldown: a steal that
	-- cannot land should not burn the thief's next chance.
	if GameState.FreeSlot(data) == nil then
		return false, "Your base is full!"
	end
	data.StealCooldownUntil = os.time() + Config.STEAL_COOLDOWN_SECONDS
	ownerData.Brainrots[model] = nil
	local placed, message = Economy.PlaceOnPlot(player, model, record)
	if not placed then
		ownerData.Brainrots[model] = record
		return false, message
	end
	return true, "You stole " .. BrainrotData.GetById(record.Id).Name .. " from " .. owner.Name .. "!"
end

-- Lock the player's own base for the lock duration, then start the recharge.
function Economy.LockBase(player: Player): (boolean, string)
	local data = GameState.Players[player]
	if data == nil then
		return false, "You are not in the game yet."
	end
	local now = os.time()
	if now < data.LockedUntil then
		return false, "Your base is already locked."
	end
	if now < data.LockCooldownUntil then
		return false, "The lock is still recharging."
	end
	data.LockedUntil = now + Config.LOCK_DURATION_SECONDS
	data.LockCooldownUntil = now + Config.LOCK_DURATION_SECONDS + Config.LOCK_COOLDOWN_SECONDS
	return true, "Base locked for " .. tostring(Config.LOCK_DURATION_SECONDS) .. " seconds!"
end

-- Rebirth: Cash and brainrots reset, the multiplier grows, and the player
-- gains a Rebirth Soul that only rebirths can grant.
function Economy.RequestRebirth(player: Player): (boolean, string)
	local data = GameState.Players[player]
	if data == nil then
		return false, "You are not in the game yet."
	end
	local cost = Economy.RebirthCost(data)
	if data.Cash < cost then
		return false, "Rebirth costs $" .. tostring(cost) .. ". Keep earning!"
	end
	for model, _ in pairs(data.Brainrots) do
		model:Destroy()
	end
	data.Brainrots = {}
	data.Cash = Config.START_CASH
	data.Rebirths += 1
	data.Multiplier = 1 + Config.REBIRTH_MULTIPLIER_STEP * data.Rebirths
	local soul = BrainrotData.REBIRTH_SOUL
	local soulModel = BrainrotFactory.BuildBrainrotModel(soul, nil)
	soulModel.Parent = Workspace
	local record = { Id = soul.Id, Mutation = nil, Income = soul.Income, Slot = 0 }
	local placed, _ = Economy.PlaceOnPlot(player, soulModel, record)
	if not placed then
		soulModel:Destroy()
		return false, "Your base is full — the Rebirth Soul had nowhere to go."
	end
	return true, "Rebirth " .. tostring(data.Rebirths) .. "! Your income is now x" .. tostring(data.Multiplier) .. " forever."
end

-- One click handler for every brainrot: conveyor brainrots are bought,
-- other players' plot brainrots are stolen.
function Economy.HandleBrainrotClicked(player: Player, model: Model): (boolean, string)
	local state = model:GetAttribute("State")
	if state == "conveyor" then
		return Economy.BuyBrainrot(player, model)
	elseif state == "plot" then
		return Economy.StealBrainrot(player, model)
	else
		return false, "That brainrot is not for sale."
	end
end

return Economy
