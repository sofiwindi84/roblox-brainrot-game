-- Brainrot Bay server main: players join, get a base plot, earn income
-- every second, and talk to the client through the remotes. All money
-- rules live in Economy; this script only wires players to them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotData = require(ReplicatedStorage.Shared.BrainrotData)
local Config = require(ReplicatedStorage.Shared.Config)
local GameState = require(script.Parent.GameState)
local Economy = require(script.Parent.Economy)

local Remotes = ReplicatedStorage.Remotes

-- Find the eight plot Parts the project file built into the world.
for number = 1, Config.PLOT_COUNT do
	local part = Workspace:FindFirstChild("Plot" .. tostring(number))
	if part ~= nil then
		GameState.Plots[number] = { Part = part, Owner = nil }
	end
end

-- A floating label over each plot sign: the plot number, and who owns it.
local function UpdatePlotLabel(plotNumber: number)
	local plot = GameState.Plots[plotNumber]
	if plot == nil then
		return
	end
	local sign = Workspace:FindFirstChild("Plot" .. tostring(plotNumber) .. "Sign")
	if sign == nil then
		return
	end
	local billboard = sign:FindFirstChild("PlotLabel")
	if billboard == nil then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "PlotLabel"
		billboard.Size = UDim2.fromOffset(220, 70)
		billboard.ExtentsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = sign
		local label = Instance.new("TextLabel")
		label.Name = "PlotText"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		label.BackgroundTransparency = 0.4
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = billboard
	end
	local text = "PLOT " .. tostring(plotNumber)
	if plot.Owner ~= nil then
		text ..= "\n" .. plot.Owner.Name
	else
		text ..= "\nEmpty"
	end
	billboard.PlotText.Text = text
end

for number = 1, Config.PLOT_COUNT do
	UpdatePlotLabel(number)
end

-- Tell one player their numbers: cash, income, rebirths, lock state.
local function SendStatsUpdate(player: Player)
	local data = GameState.Players[player]
	if data == nil then
		return
	end
	local now = os.time()
	Remotes.StatsUpdate:FireClient(player, {
		Cash = data.Cash,
		Income = Economy.ComputeIncome(data),
		Rebirths = data.Rebirths,
		Multiplier = data.Multiplier,
		RebirthCost = Economy.RebirthCost(data),
		LockedUntil = data.LockedUntil,
		LockCooldownUntil = data.LockCooldownUntil,
		NextTsunamiIn = math.max(0, GameState.Tsunami.NextWaveAt - now),
		Plot = data.Plot,
	})
end

-- Tell one player something in the notification feed.
local function NotifyPlayer(player: Player, message: string, kind: string)
	Remotes.Notify:FireClient(player, message, kind or "info")
end

-- A player joins: give them Cash, a plot, and a leaderboard row.
local function OnPlayerAdded(player: Player)
	local plotNumber = GameState.FirstFreePlot()
	local data = GameState.NewPlayerData(plotNumber)
	GameState.Players[player] = data
	if plotNumber ~= nil then
		GameState.Plots[plotNumber].Owner = player
		UpdatePlotLabel(plotNumber)
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = data.Cash
	cashValue.Parent = leaderstats
	data.CashValue = cashValue

	SendStatsUpdate(player)
	if plotNumber ~= nil then
		NotifyPlayer(player, "Welcome to Brainrot Bay! Your base is Plot " .. tostring(plotNumber) .. ".", "good")
	else
		NotifyPlayer(player, "Welcome to Brainrot Bay! All base plots are taken — watch and enjoy.", "info")
	end
end

-- A player leaves: free their plot and clear their brainrots.
local function OnPlayerRemoving(player: Player)
	local data = GameState.Players[player]
	if data == nil then
		return
	end
	if data.Plot ~= nil then
		GameState.Plots[data.Plot].Owner = nil
		UpdatePlotLabel(data.Plot)
	end
	for model, _ in pairs(data.Brainrots) do
		model:Destroy()
	end
	GameState.Players[player] = nil
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	OnPlayerAdded(player)
end

-- The shop and the click detector buy through this RemoteFunction.
Remotes.BuyBrainrot.OnServerInvoke = function(player: Player, model: Model)
	local ok, message = Economy.HandleBrainrotClicked(player, model)
	if ok then
		NotifyPlayer(player, message, "good")
	else
		NotifyPlayer(player, message, "bad")
	end
	return ok, message
end

-- Locking and rebirthing arrive as RemoteEvents. (Stealing needs no
-- remote of its own: clicking a brainrot reaches the server through its
-- ClickDetector, and Economy routes the click to a buy or a steal.)
Remotes.LockBase.OnServerEvent:Connect(function(player: Player)
	local ok, message = Economy.LockBase(player)
	NotifyPlayer(player, message, ok and "good" or "bad")
	SendStatsUpdate(player)
end)

Remotes.RequestRebirth.OnServerEvent:Connect(function(player: Player)
	local ok, message = Economy.RequestRebirth(player)
	NotifyPlayer(player, message, ok and "good" or "bad")
	if ok then
		for _, other in ipairs(Players:GetPlayers()) do
			if other ~= player then
				NotifyPlayer(other, player.Name .. " rebirthed! Their income multiplier grew.", "info")
			end
		end
	end
	SendStatsUpdate(player)
end)

-- Every second: pay income, refresh the leaderboard, push stats to clients.
while true do
	task.wait(Config.INCOME_TICK_SECONDS)
	for player, data in pairs(GameState.Players) do
		data.Cash += Economy.ComputeIncome(data)
		if data.CashValue ~= nil then
			data.CashValue.Value = data.Cash
		end
		SendStatsUpdate(player)
	end
end
