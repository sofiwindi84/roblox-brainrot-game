-- Brainrot Bay base-lock button: locks the player's own base so nobody
-- can steal from it. The button sits at the bottom-right corner and shows
-- whether the lock is holding or recharging, from the stats the server
-- sends every second.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LockBase = Remotes:WaitForChild("LockBase")
local StatsUpdate = Remotes:WaitForChild("StatsUpdate")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayLock"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local button = Instance.new("TextButton")
button.Name = "LockButton"
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -16, 1, -16)
button.Size = UDim2.fromOffset(200, 64)
button.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 24
button.Font = Enum.Font.GothamBold
button.Text = "LOCK BASE"
button.Parent = gui

button.MouseButton1Click:Connect(function()
	LockBase:FireServer()
end)

-- Refresh the button text from the lock timers in the stats.
StatsUpdate.OnClientEvent:Connect(function(stats)
	local now = os.time()
	if now < stats.LockedUntil then
		button.Text = "LOCKED (" .. tostring(stats.LockedUntil - now) .. "s)"
		button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	elseif now < stats.LockCooldownUntil then
		button.Text = "Recharging (" .. tostring(stats.LockCooldownUntil - now) .. "s)"
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
	else
		button.Text = "LOCK BASE"
		button.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
	end
end)

gui.Parent = player:WaitForChild("PlayerGui")
