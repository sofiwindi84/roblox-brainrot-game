-- Brainrot Bay notifications: a feed of game events at the top centre of
-- the screen, and a big banner for tsunami warnings. Messages arrive
-- from the server through the Notify remote.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Notify = Remotes:WaitForChild("Notify")

local KIND_COLORS = {
	good = Color3.fromRGB(120, 255, 120),
	bad = Color3.fromRGB(255, 100, 100),
	warn = Color3.fromRGB(255, 190, 60),
	info = Color3.fromRGB(255, 255, 255),
}

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayNotices"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- The feed: newest message on top, each fading out after a few seconds.
local feed = Instance.new("Frame")
feed.Name = "NoticeFeed"
feed.AnchorPoint = Vector2.new(0.5, 0)
feed.Position = UDim2.new(0.5, 0, 0, 70)
feed.Size = UDim2.fromOffset(520, 200)
feed.BackgroundTransparency = 1
feed.Parent = gui

local feedLayout = Instance.new("UIListLayout")
feedLayout.Padding = UDim.new(0, 6)
feedLayout.Parent = feed

-- The tsunami banner: a large warning across the middle of the screen.
local banner = Instance.new("TextLabel")
banner.Name = "TsunamiBanner"
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Position = UDim2.new(0.5, 0, 0.35, 0)
banner.Size = UDim2.fromOffset(640, 80)
banner.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
banner.BackgroundTransparency = 0.2
banner.TextColor3 = Color3.fromRGB(255, 220, 120)
banner.TextSize = 36
banner.Font = Enum.Font.GothamBold
banner.Text = "TSUNAMI INCOMING!"
banner.Visible = false
banner.Parent = gui

local function ShowNotice(message: string, kind: string)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 34)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.25
	label.TextColor3 = KIND_COLORS[kind] or KIND_COLORS.info
	label.Text = message
	label.TextSize = 22
	label.Font = Enum.Font.GothamBold
	label.Parent = feed
	task.delay(6, function()
		label:Destroy()
	end)
end

Notify.OnClientEvent:Connect(function(message: string, kind: string)
	ShowNotice(message, kind)
	if kind == "warn" then
		banner.Visible = true
		task.delay(10, function()
			banner.Visible = false
		end)
	end
end)

gui.Parent = player:WaitForChild("PlayerGui")
