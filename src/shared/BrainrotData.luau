-- Brainrot Bay cast: every brainrot the conveyor can bring, its rarity,
-- its price and what it earns a second. All twelve are invented for this
-- game — a coffee turtle, a durian dinosaur, a flying satay cow and the
-- rest — never copied from any existing brainrot game.

local BrainrotData = {}

-- Rarities, weakest first. Weight is the share of conveyor spawns.
BrainrotData.RARITIES = {
	{ Name = "Common", Weight = 55, Color = Color3.fromRGB(170, 170, 170) },
	{ Name = "Rare", Weight = 25, Color = Color3.fromRGB(80, 160, 255) },
	{ Name = "Epic", Weight = 12, Color = Color3.fromRGB(180, 90, 255) },
	{ Name = "Legendary", Weight = 6, Color = Color3.fromRGB(255, 190, 40) },
	{ Name = "Mythic", Weight = 2, Color = Color3.fromRGB(255, 70, 90) },
}

-- Mutations, rolled when a brainrot spawns. A Golden brainrot earns twice
-- as much, a Rainbow one five times as much.
BrainrotData.MUTATIONS = {
	{ Name = "Golden", Chance = 0.10, Multiplier = 2, Color = Color3.fromRGB(255, 215, 0) },
	{ Name = "Rainbow", Chance = 0.02, Multiplier = 5, Color = Color3.fromRGB(255, 100, 220) },
}

-- The cast. Cost is what the player pays on the conveyor; Income is the
-- Cash it pays every second on a base plot, before mutations and the
-- rebirth multiplier. Color is the brainrot's body colour.
BrainrotData.CAST = {
	{
		Id = "kopi-kura",
		Name = "Kopi Kura",
		Rarity = "Common",
		Cost = 50,
		Income = 2,
		Color = Color3.fromRGB(139, 90, 43),
		Blurb = "A sleepy turtle who brews coffee in its shell. Smells amazing.",
	},
	{
		Id = "durian-dino",
		Name = "Durian Dino",
		Rarity = "Common",
		Cost = 120,
		Income = 5,
		Color = Color3.fromRGB(120, 180, 60),
		Blurb = "A tiny dinosaur covered in durian spikes. Prickly, but loyal.",
	},
	{
		Id = "sate-sapi-terbang",
		Name = "Sate Sapi Terbang",
		Rarity = "Common",
		Cost = 250,
		Income = 9,
		Color = Color3.fromRGB(220, 150, 80),
		Blurb = "A cow on satay skewers that learned to fly. Nobody knows how.",
	},
	{
		Id = "nasi-goreng-naga",
		Name = "Nasi Goreng Naga",
		Rarity = "Rare",
		Cost = 600,
		Income = 20,
		Color = Color3.fromRGB(230, 120, 40),
		Blurb = "A dragon made of fried rice, breathing wok-fire. Extra spicy.",
	},
	{
		Id = "es-teh-manis-hiu",
		Name = "Es Teh Manis Hiu",
		Rarity = "Rare",
		Cost = 1200,
		Income = 38,
		Color = Color3.fromRGB(90, 180, 220),
		Blurb = "A shark swimming in sweet iced tea. Chills everything it touches.",
	},
	{
		Id = "bakso-balon",
		Name = "Bakso Balon",
		Rarity = "Rare",
		Cost = 2500,
		Income = 75,
		Color = Color3.fromRGB(200, 140, 120),
		Blurb = "A meatball balloon that floats over the bay, dripping broth.",
	},
	{
		Id = "rendang-robot",
		Name = "Rendang Robot",
		Rarity = "Epic",
		Cost = 6000,
		Income = 170,
		Color = Color3.fromRGB(150, 150, 160),
		Blurb = "A robot slow-cooked in rendang spice for 300 years. Worth it.",
	},
	{
		Id = "gado-gado-gajah",
		Name = "Gado-Gado Gajah",
		Rarity = "Epic",
		Cost = 12000,
		Income = 320,
		Color = Color3.fromRGB(180, 160, 140),
		Blurb = "An elephant tossed in peanut sauce with extra krupuk armour.",
	},
	{
		Id = "kerupuk-kucing",
		Name = "Kerupuk Kucing",
		Rarity = "Epic",
		Cost = 25000,
		Income = 600,
		Color = Color3.fromRGB(240, 220, 180),
		Blurb = "A cat made of crackers. Crunchy, quick, and impossible to catch.",
	},
	{
		Id = "sambal-singa",
		Name = "Sambal Singa",
		Rarity = "Legendary",
		Cost = 60000,
		Income = 1400,
		Color = Color3.fromRGB(220, 60, 30),
		Blurb = "A lion with a mane of pure sambal. Its roar makes eyes water.",
	},
	{
		Id = "tempe-titan",
		Name = "Tempe Titan",
		Rarity = "Legendary",
		Cost = 150000,
		Income = 3200,
		Color = Color3.fromRGB(210, 180, 120),
		Blurb = "A titan fermented from the finest tempeh. Ancient and unbothered.",
	},
	{
		Id = "raja-bintang-buah",
		Name = "Raja Bintang Buah",
		Rarity = "Mythic",
		Cost = 400000,
		Income = 8000,
		Color = Color3.fromRGB(255, 220, 80),
		Blurb = "The Star Fruit King, ruler of Brainrot Bay. It glows like sunset.",
	},
}

-- The Rebirth Soul is never on the conveyor: a rebirth grants one.
BrainrotData.REBIRTH_SOUL = {
	Id = "jiwa-rebirth",
	Name = "Jiwa Rebirth",
	Rarity = "Mythic",
	Cost = 0,
	Income = 250,
	Color = Color3.fromRGB(140, 230, 255),
	Blurb = "A glowing soul earned by starting over. It remembers everything.",
}

-- Find a brainrot by its Id, or nil.
function BrainrotData.GetById(id: string)
	for _, entry in ipairs(BrainrotData.CAST) do
		if entry.Id == id then
			return entry
		end
	end
	if BrainrotData.REBIRTH_SOUL.Id == id then
		return BrainrotData.REBIRTH_SOUL
	end
	return nil
end

-- Roll a rarity from the spawn weights.
function BrainrotData.RollRarity(): string
	local total = 0
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		total += rarity.Weight
	end
	local roll = math.random() * total
	local running = 0
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		running += rarity.Weight
		if roll <= running then
			return rarity.Name
		end
	end
	return "Common"
end

-- Roll one brainrot of the given rarity.
function BrainrotData.RollBrainrot(rarityName: string)
	local pool = {}
	for _, entry in ipairs(BrainrotData.CAST) do
		if entry.Rarity == rarityName then
			table.insert(pool, entry)
		end
	end
	if #pool == 0 then
		return BrainrotData.CAST[1]
	end
	return pool[math.random(1, #pool)]
end

-- Roll a mutation for a fresh spawn: "Rainbow", "Golden", or nil.
function BrainrotData.RollMutation(): string?
	local roll = math.random()
	if roll <= BrainrotData.MUTATIONS[2].Chance then
		return "Rainbow"
	end
	if roll <= BrainrotData.MUTATIONS[1].Chance + BrainrotData.MUTATIONS[2].Chance then
		return "Golden"
	end
	return nil
end

-- The income multiplier a mutation gives (1 for a plain brainrot).
function BrainrotData.MutationMultiplier(mutation: string?): number
	for _, entry in ipairs(BrainrotData.MUTATIONS) do
		if entry.Name == mutation then
			return entry.Multiplier
		end
	end
	return 1
end

-- The colour a rarity shows as in the shop and on name labels.
function BrainrotData.RarityColor(rarityName: string): Color3
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		if rarity.Name == rarityName then
			return rarity.Color
		end
	end
	return Color3.fromRGB(200, 200, 200)
end

return BrainrotData
