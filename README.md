# Brainrot Bay — a 3D Roblox brainrot game

[![Make the best AI Roblox brainrot game](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/sofiwindi84/roblox-brainrot-game/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/sofiwindi84/roblox-brainrot-game/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

An original 3D Roblox game in the "Steal a Brainrot" genre, built for the
[make.fun bounty "Make the best AI Roblox brainrot game"](https://make.fun/bounty/roblox-brainrot-01).
Every character, name and corner of the world is invented for this game —
nothing is copied from existing brainrot games.

## The game

You land on Brainrot Bay, a sunny tropical island at sunset. Absurd
brainrots ride the central conveyor to the spawn pad: buy one with Cash and
it walks to your base plot, where it earns money every second. Buy rarer
ones, steal from other players' bases, lock your own base, rebirth for a
permanent income multiplier, and survive the tsunami that sweeps the island
every three minutes.

## How to play

1. **Buy brainrots** — click a brainrot riding the conveyor, or use the Shop
   panel on the right. It moves to a free slot on your base plot.
2. **Earn** — every brainrot on your plot pays its $/sec rate into your Cash,
   once a second. Rarer brainrots pay far more.
3. **Steal** — click a brainrot on another player's plot to take it for
   yourself. A locked base cannot be stolen from: the Lock button (bottom
   right) locks your base for 60 seconds, then needs 60 seconds to recharge.
4. **Rebirth** — when you can afford it, press Rebirth in the Shop panel:
   your Cash and brainrots reset, but you keep a permanent +50% income
   multiplier per rebirth and gain a Rebirth Soul, a brainrot only rebirths
   can grant.
5. **Survive the tsunami** — every ~3 minutes a warning sounds and a wave
   sweeps the island. Stand on your own base plot to stay dry; anyone caught
   out in the open loses 10% of their Cash.

## The cast

12 original brainrots across 5 rarities, plus 2 mutations:

| Rarity | Brainrots | Cost | $/sec |
| --- | --- | --- | --- |
| Common | Kopi Kura, Durian Dino, Sate Sapi Terbang | 50 – 250 | 2 – 9 |
| Rare | Nasi Goreng Naga, Es Teh Manis Hiu, Bakso Balon | 600 – 2,500 | 20 – 75 |
| Epic | Rendang Robot, Gado-Gado Gajah, Kerupuk Kucing | 6,000 – 25,000 | 170 – 600 |
| Legendary | Sambal Singa, Tempe Titan | 60,000 – 150,000 | 1,400 – 3,200 |
| Mythic | Raja Bintang Buah | 400,000 | 8,000 |

Mutations: **Golden** (2x income, 10% of spawns) and **Rainbow** (5x income,
2% of spawns). The conveyor spawns a new brainrot every 8 seconds.

## The world

A tropical island built entirely from Parts in `default.project.json`: a
sand baseplate ringed by water, 8 coloured player base plots, the central
conveyor and spawn runway, a shop building, a lighthouse, palm trees, rocks,
beach umbrellas and a spawn point — all under a sunset sky. No external
asset IDs are used anywhere: every character and decoration is built from
Parts, BrickColors, materials and in-game text labels, so the game looks the
same for every reviewer.

## How it is built

- **Rojo 7.7** project (`default.project.json`): the static world lives in
  the project file, the scripts live under `src/`.
- **Luau, standard library only.** `src/shared/` holds the data
  (`BrainrotData`, the cast and rarity ladder) and the tuning (`Config`).
  `src/server/` holds the game logic: `ServerMain` (players, plots,
  remotes), `Economy` (buying, stealing, locking, rebirth — all money rules
  in one place), `ConveyorSpawner` (the walking brainrots),
  `BrainrotFactory` (building brainrot models from Parts) and
  `TsunamiEvent` (the wave). `src/client/` holds the interface: `Hud`
  (cash and income), `ShopGui` (shop and rebirth), `Notifications`
  (events and warnings) and `BaseLockButton`.
- `main.ts` (Node 22, standard library only) copies `game.rbxl`, `src/`,
  `screenshots/` and `PLAY.json` to the output and writes the dossier with
  the kit's vendored library.

Build it with Rojo and hand it in:

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

Then open `game.rbxl` in Roblox Studio, play-test it, publish the place as
a Public experience, and fill in `PLAY.json` with its place and universe
ids. The play link for this entry is added once the place is published.
