-- Brainrot Bay shop panel: the brainrots riding the conveyor right now,
-- each with its price and income, a Buy button, and the Rebirth button.
-- The panel sits on the right edge of the screen.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BrainrotData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyBrainrot = Remotes:WaitForChild("BuyBrainrot")
local ConveyorUpdate = Remotes:WaitForChild("ConveyorUpdate")
local StatsUpdate = Remotes:WaitForChild("StatsUpdate")
local RequestRebirth = Remotes:WaitForChild("RequestRebirth")

-- "$1,234,567" out of a plain number.
local function FormatMoney(amount: number): string
	local text = tostring(math.floor(amount))
	local result = ""
	while #text > 3 do
		result = "," .. string.sub(text, -3) .. result
		text = string.sub(text, 1, #text - 3)
	end
	return "$" .. text .. result
end

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayShop"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local panel = Instance.new("Frame")
panel.Name = "ShopPanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -16, 0, 172)
panel.Size = UDim2.fromOffset(300, 420)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "ShopTitle"
title.Position = UDim2.new(0, 12, 0, 8)
title.Size = UDim2.new(1, -24, 0, 32)
title.BackgroundTransparency = 1
title.Text = "SHOP — On the conveyor"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Name = "ConveyorList"
list.Position = UDim2.new(0, 8, 0, 48)
list.Size = UDim2.new(1, -16, 0, 280)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Position = UDim2.new(0, 12, 0, 340)
rebirthButton.Size = UDim2.new(1, -24, 0, 60)
rebirthButton.BackgroundColor3 = Color3.fromRGB(140, 60, 220)
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.TextSize = 20
rebirthButton.Font = Enum.Font.GothamBold
-- Two short lines so the cost and the next multiplier always fit inside
-- the 276px-wide button instead of spilling past its edges.
rebirthButton.TextWrapped = true
rebirthButton.Text = "REBIRTH — $50,000\n(x1 next)"
rebirthButton.Parent = panel

rebirthButton.MouseButton1Click:Connect(function()
	RequestRebirth:FireServer()
end)

StatsUpdate.OnClientEvent:Connect(function(stats)
	rebirthButton.Text = "REBIRTH — " .. FormatMoney(stats.RebirthCost) .. "\n(x" .. tostring(stats.Rebirths + 1) .. " next)"
end)

-- Rebuild the shop rows from the conveyor list the server sends.
local function RebuildShop(rows)
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if #rows == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 30)
		empty.BackgroundTransparency = 1
		empty.Text = "Conveyor is empty — next brainrot soon!"
		empty.TextColor3 = Color3.fromRGB(200, 200, 200)
		empty.TextSize = 18
		empty.Font = Enum.Font.Gotham
		empty.Parent = list
		return
	end
	for _, row in ipairs(rows) do
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, 64)
		frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		frame.BorderSizePixel = 0
		frame.Parent = list

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Position = UDim2.new(0, 8, 0, 4)
		nameLabel.Size = UDim2.new(1, -100, 0, 28)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 20
		nameLabel.TextColor3 = BrainrotData.RarityColor(row.Rarity)
		local displayName = row.Name
		if row.Mutation ~= nil and row.Mutation ~= "" then
			displayName = row.Mutation .. " " .. displayName
		end
		nameLabel.Text = displayName
		nameLabel.Parent = frame

		local detailLabel = Instance.new("TextLabel")
		detailLabel.Position = UDim2.new(0, 8, 0, 32)
		detailLabel.Size = UDim2.new(1, -100, 0, 26)
		detailLabel.BackgroundTransparency = 1
		detailLabel.TextXAlignment = Enum.TextXAlignment.Left
		detailLabel.Font = Enum.Font.Gotham
		detailLabel.TextSize = 18
		detailLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		detailLabel.Text = row.Rarity .. "  •  " .. FormatMoney(row.Income) .. "/s"
		detailLabel.Parent = frame

		local buyButton = Instance.new("TextButton")
		buyButton.Position = UDim2.new(1, -84, 0, 10)
		buyButton.Size = UDim2.new(0, 76, 0, 44)
		buyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
		buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyButton.TextSize = 18
		buyButton.Font = Enum.Font.GothamBold
		buyButton.Text = FormatMoney(row.Price)
		buyButton.Parent = frame

		buyButton.MouseButton1Click:Connect(function()
			local model = Workspace:FindFirstChild(row.ModelName)
			if model ~= nil then
				BuyBrainrot:InvokeServer(model)
			end
		end)
	end
	list.CanvasSize = UDim2.new(0, 0, 0, #rows * 70)
end

ConveyorUpdate.OnClientEvent:Connect(RebuildShop)

gui.Parent = player:WaitForChild("PlayerGui")
