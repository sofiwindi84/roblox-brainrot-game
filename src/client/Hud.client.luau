-- Brainrot Bay HUD: the cash, income, rebirth and tsunami panel, pinned
-- to the top-right corner of the screen so it never hides behind
-- Roblox's own menu buttons in the top-left.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StatsUpdate = Remotes:WaitForChild("StatsUpdate")

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
gui.Name = "BrainrotBayHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local panel = Instance.new("Frame")
panel.Name = "HudPanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -16, 0, 12)
panel.Size = UDim2.fromOffset(280, 150)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = gui

local function MakeLabel(name: string, y: number, size: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = Vector2.new(1, 0)
	label.Position = UDim2.new(1, -12, 0, y)
	label.Size = UDim2.new(1, -24, 0, size)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextSize = size
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Parent = panel
	return label
end

local cashLabel = MakeLabel("CashLabel", 8, 32, Color3.fromRGB(120, 255, 120))
local incomeLabel = MakeLabel("IncomeLabel", 44, 22, Color3.fromRGB(255, 255, 255))
local rebirthLabel = MakeLabel("RebirthLabel", 72, 22, Color3.fromRGB(255, 215, 0))
local tsunamiLabel = MakeLabel("TsunamiLabel", 100, 22, Color3.fromRGB(120, 200, 255))

cashLabel.Text = "$100"
incomeLabel.Text = "+$0/s"
rebirthLabel.Text = "Rebirth x0  •  Income x1"
tsunamiLabel.Text = "Next wave: --"

StatsUpdate.OnClientEvent:Connect(function(stats)
	cashLabel.Text = FormatMoney(stats.Cash)
	incomeLabel.Text = "+" .. FormatMoney(stats.Income) .. "/s"
	rebirthLabel.Text = "Rebirth x" .. tostring(stats.Rebirths) .. "  •  Income x" .. tostring(stats.Multiplier)
	if stats.NextTsunamiIn > 0 then
		tsunamiLabel.Text = "Next wave: " .. tostring(stats.NextTsunamiIn) .. "s"
	else
		tsunamiLabel.Text = "Tsunami NOW!"
	end
end)

gui.Parent = player:WaitForChild("PlayerGui")
