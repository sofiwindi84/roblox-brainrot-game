-- Brainrot Bay tuning: every number the game balances on, in one place.
-- Server scripts and the shop UI both read this module, so a balance
-- change here reaches the whole game without touching any other file.

local Config = {}

-- A new player starts with this much Cash.
Config.START_CASH = 100

-- How many base plots the island holds, and how many brainrot slots each
-- plot has.
Config.PLOT_COUNT = 8
Config.PLOT_SLOTS = 6

-- The conveyor: a new brainrot rides in this often, walking this fast
-- (studs per second) from the spawn pad to the end pad.
Config.CONVEYOR_SPAWN_INTERVAL = 8
Config.CONVEYOR_SPEED = 6
Config.CONVEYOR_START_X = -78
Config.CONVEYOR_END_X = 78
Config.CONVEYOR_Y = 2.5

-- Income is paid this often, in seconds.
Config.INCOME_TICK_SECONDS = 1

-- Base lock: how long a lock holds, and how long the button then needs to
-- recharge before it can lock again.
Config.LOCK_DURATION_SECONDS = 60
Config.LOCK_COOLDOWN_SECONDS = 60

-- After stealing a brainrot, a player waits this long before stealing again.
Config.STEAL_COOLDOWN_SECONDS = 30

-- The tsunami: how often the wave comes, how long the warning lasts, and
-- the share of Cash a player caught outside their own plot loses.
Config.TSUNAMI_INTERVAL_SECONDS = 180
Config.TSUNAMI_WARNING_SECONDS = 10
Config.TSUNAMI_CASH_LOSS = 0.10

-- Rebirth: the Cash a rebirth costs grows with each rebirth, and each one
-- adds this much to the permanent income multiplier.
Config.REBIRTH_BASE_COST = 50000
Config.REBIRTH_MULTIPLIER_STEP = 0.5

-- The Rebirth Soul, the brainrot only a rebirth can grant, pays this much
-- per second before multipliers.
Config.REBIRTH_SOUL_INCOME = 250

-- Mutations rolled when a brainrot spawns on the conveyor.
Config.MUTATION_GOLDEN_CHANCE = 0.10
Config.MUTATION_GOLDEN_MULTIPLIER = 2
Config.MUTATION_RAINBOW_CHANCE = 0.02
Config.MUTATION_RAINBOW_MULTIPLIER = 5

return Config
