-- Brainrot Bay brainrot factory: builds a brainrot character Model from
-- Parts, given a cast entry and a mutation. No asset IDs anywhere — body,
-- head, eyes and the name label are all built from Parts and Gui objects,
-- so the character looks the same for every reviewer.

local BrainrotFactory = {}

-- A brainrot is a body with a head, two eyes and a name label floating
-- above it. Everything is Anchored and non-collidable: the server moves
-- the model by its CFrame, and players walk through it to click it.
function BrainrotFactory.BuildBrainrotModel(entry, mutation: string?): Model
	local bodyColor = entry.Color
	if mutation == "Golden" then
		bodyColor = Color3.fromRGB(255, 215, 0)
	elseif mutation == "Rainbow" then
		bodyColor = Color3.fromRGB(255, 100, 220)
	end

	local model = Instance.new("Model")
	model.Name = "Brainrot_" .. entry.Id .. "_" .. tostring(math.random(100000, 999999))

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 2, 3)
	body.Color = bodyColor
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 2, 2)
	head.Color = bodyColor:Lerp(Color3.new(1, 1, 1), 0.35)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.Position = Vector3.new(0, 2, 0)
	head.Parent = model

	for _, side in ipairs({ -0.5, 0.5 }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Size = Vector3.new(0.5, 0.5, 0.2)
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Material = Enum.Material.SmoothPlastic
		eye.Anchored = true
		eye.CanCollide = false
		eye.Position = Vector3.new(side, 2.3, 1.05)
		eye.Parent = model

		local pupil = Instance.new("Part")
		pupil.Name = "Pupil"
		pupil.Size = Vector3.new(0.25, 0.25, 0.1)
		pupil.Color = Color3.fromRGB(20, 20, 20)
		pupil.Material = Enum.Material.SmoothPlastic
		pupil.Anchored = true
		pupil.CanCollide = false
		pupil.Position = Vector3.new(side, 2.3, 1.2)
		pupil.Parent = model
	end

	-- The name label: name, rarity and income, readable from across the
	-- island. A mutation is named in front so it stands out.
	local labelText = entry.Name .. "\n" .. entry.Rarity
	if mutation ~= nil then
		labelText = mutation .. " " .. labelText
	end
	labelText ..= "\n$" .. tostring(entry.Income) .. "/s"

	-- The name label: name, rarity and income, readable from across the
	-- island. A mutation is named in front so it stands out. The label is
	-- kept narrow (180px) and floats high (4.2 studs) so that when several
	-- brainrots bunch up on the conveyor their labels sit clear of each
	-- other instead of stacking on top of one another.
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameLabel"
	billboard.Size = UDim2.fromOffset(180, 60)
	billboard.ExtentsOffsetWorldSpace = Vector3.new(0, 4.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = body

	local label = Instance.new("TextLabel")
	label.Name = "NameText"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.4
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = labelText
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	local clicker = Instance.new("ClickDetector")
	clicker.Name = "BrainrotClicker"
	clicker.MaxActivationDistance = 32
	clicker.Parent = body

	model.PrimaryPart = body
	return model
end

-- Move a brainrot model so its body sits on a surface at the given Y.
function BrainrotFactory.PlaceBrainrotModel(model: Model, x: number, floorY: number, z: number)
	model:PivotTo(CFrame.new(x, floorY + 1, z))
end

return BrainrotFactory
