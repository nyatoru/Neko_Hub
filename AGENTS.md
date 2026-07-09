# Neko_Hub — Agent Guide

Roblox exploit hub (Luau) for Violence District. Loaded via executor at runtime. All scripts client-side only. **No build, no tests, no lint, no CI.** No verification commands exist — the only way to check correctness is reading the code or in-game testing via an executor.

## Entry Chain

```
Loader.lua (bootstrap via executor)
 ├── Load.lua (animated loading screen)
 ├── Neko_HubGui/Gui.lua (WindUI window setup + theme)
 ├── Neko_HubGui/Menu.lua (UI tabs → LogicFunction callbacks)
 └── Neko_HubGui/LogicFunction.lua (~2430 lines, core logic)
```

- `Loader.lua` fetches children via `game:HttpGet()` from GitHub raw URLs or local `isfile()`/`readfile()` fallback.
- `Menu.lua` loads `LogicFunction.lua` via `require` → `readfile` → HTTP → `getgenv().Neko_HubLogic`.
- `Gui.lua` fetches **WindUI** from `Footagesus/WindUI` `main` branch at runtime (not a pinned version).
- `Neko_HubGui/Theme.lua` exists but is **unused** — theme dropdown is built directly in `Menu.lua`.
- `neko_hub.lua` is gitignored. It's a standalone legacy script for a **different game** (Obsidian library). Do not copy code or remotes from it.

## Coding & Conventions

- All files use `--!strict`. Services via `game:GetService()`.
- Executor globals used: `getgenv`, `gethui`, `getrawmetatable`, `hookmetamethod`, `newcclosure`, `checkcaller`, `getgc`, `getnamecallmethod`, `isfile`, `readfile`, `writefile`, `makefolder`, `firesignal`, `getcustomasset`/`getsynasset`.
- UI: **WindUI** (Window → Tab → Section → Toggle/Slider/Dropdown/Colorpicker). API note: `Colorpicker` lowercase `p`.
- Config: `Window.ConfigManager:Config("NekoHubConfig")` — saves to `WindUI/Neko_Hub/configs/NekoHubConfig.json`. Every element has a `Flag` (prefix `neko_`). Callbacks call `NekoConfig:Save()`.
- Theme: custom `"NekoTheme"` (pink), set in `Gui.lua`. `HideSearchBar = true`.
- Remotes: `ReplicatedStorage:WaitForChild("Remotes"):...`
- Floating elements: `ScreenGui` parented to `gethui()` or `PlayerGui`, using `TextButton` + `UICorner` (circular, draggable).

## Config Sync Gotcha (#1 trap)

`NekoConfig:Load()` (called at end of `Menu.lua`) restores UI visuals but **does NOT fire callbacks**. So logic variables keep their defaults. To fix this, `LogicFunction.lua` has a config-restore block at the bottom (`task.spawn` at ~line 2370) that reads the JSON directly and sets every logic variable.

**When adding a new UI element + Logic setter**: you must add a corresponding `if cfg.neko_your_flag ~= nil then ... end` line in the config-restore block, or the setting won't persist across reloads.

## LogicFunction.lua Architecture

Exports a single `Logic` table at `getgenv().Neko_HubLogic` with sections:

| Section | Contents |
|---|---|
| `Logic.Combat` | Auto Parry/Dash/Dodge, Auto Pallet, Auto Skillcheck (2 modes), Fast Vault |
| `Logic.ESP` | 6 kinds: Generator/Pallet/Window/Hook/SCP/Player. Per-kind Color3 + color lerp (gen: orange→green). Player state (downed). Hide done gen. |
| `Logic.Aim` | Gun aim (Silent/AimLock) + Veil aim (spear). FOV circles via `Drawing`. Target mode (Killer/Survivor). Wallcheck, predict, smooth (both gun + veil). |
| `Logic.Player` | Unlimited zoom, custom FOV (enforced via `RenderStepped`) |

### Forward declaration pattern

Functions defined later in the file are forward-declared as typed locals so earlier code (Logic table setters, `checkLobby`) can reference them:
- `local syncFloatingIcons: () -> ()` — declared before the `Logic` table; defined in the floating icons section. Aim setters (`SetSilentAim`, `SetAimLock`, `SetVeilSilentAim`, `SetVeilAimLock`) call it to sync icon state.
- `local updateVeilBtnVisibility: () -> ()` — declared before `checkLobby`; called via `pcall` from `checkLobby` to hide/show the veil button on lobby/team change.
- `local setMapContainer`, `local resyncMap` — forward-declared before ESP detection functions.

### ESP internals
- `type ESPKind = "Generator" | "Pallet" | "Window" | "Hook" | "SCP" | "Player"`
- `connsByKind` table **must** have an entry for every ESP kind. Missing entries cause `stopKind()` to silently fail (connections never disconnect). Currently: Generator, Pallet, Window, SCP, Hook, Player.
- Map objects detected via `setMapContainer()` with `DescendantAdded`/`DescendantRemoving`/`Destroying` + periodic 10s resync.
- Per-kind detection: `isGenerator()`, `isPallet()`, `isWindowObj()`, `isHook()`, `isZombie()`.
- `classifyAndTrack()` dispatches by kind. `tracked[model]` stores highlight + billboard.
- `ensureDistLoop()` — single merged loop for all ESP label updates + `lastDistances` cache (skip if dist change <1m).

### Skillcheck modes (`skillCheckMode`)
| Mode | Mechanism | Input |
|---|---|---|
| `"Crossing"` (default) | `RenderStepped` polls `PlayerGui.SkillCheckPromptGui.Check`, detects zone crossing via `Line.Rotation` | `VirtualInputManager:SendKeyEvent(Space)` / `SendTouchEvent` (mobile) |
| `"RotationHook"` | `hookmetamethod(game, "__index")` on `.Rotation` → returns `goal.Rotation + 104`. Detection via `SkillCheckEvent` RemoteEvent under `Remotes.Generator`/`Remotes.Healing`. | `firesignal` or `VirtualInputManager` |

`PlayerGui` must be defined globally: `local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")` at top of file.

### Lobby detection
- `LocalPlayer:GetPropertyChangedSignal("Team")` → `lobbyLocked` flag.
- Team names that trigger lock: `"spectator"`, `""`, `"lobby"`.
- Guards on: combat heartbeat, auto skillcheck, auto pallet, ESP dist loop.
- `checkLobby()` also calls `updateVeilBtnVisibility()` to hide veil button in lobby.

### Floating aim icons
- Two circular `ScreenGui` buttons (`G`/`V`), draggable, at right edge of screen.
- **Always visible** (no RenderStepped override). Green = aim on, red = aim off.
- Click toggles aim config (`silentAimGun`/`aimLock` or `veilSilentAim`/`veilAimLock`) and updates icon color.
- `syncFloatingIcons()` syncs icon state from config — called by aim setters and on init.
- **Veil button** hidden when in lobby or user is not Killer team (`isKillerTeam()` checks team name for "killer"/"hunter"). Gun button always visible.
- **Do not** add a RenderStepped loop to control icon visibility — it overrides user clicks and hides icons when aim is off, making them unclickable.

### Auto Pallet
- `CollectionService:GetTagged("PalletPoint")` cache with signal-based add/remove.
- Drops when player within `PLAYER_INTERACT_DISTANCE` (6) and killer within `TRIGGER_DISTANCE` (default 13.2).
- Debounce per pallet (5s cooldown). Skips if health ≤50 / carrying / doing action.

### Fast Vault
- Hooks `Animator.AnimationPlayed` on character. Replaces `83873880822918` with `136962284480779`. Speed adjustable (1.0–5.0).
- Auto-rehooks on `CharacterAdded`.

### Killer notification
- One-time popup on **match start** (team transitions from spectator/lobby to Survivors/Killer).
- Shows `"⚠ Killer: [name]"` (amber) or `"⚔ You are the Killer"` (red).
- Auto-destroys after 4s. Re-arms on next match via `notifWasInGame` state.

### Auto Dodge (Abysswalker)
- Hooks killer animation `ABYSS_SKILL_ID` ("80411309607666"). On trigger, crouches for `crouchHoldTime` (1.0s) if killer within `dodgeDistance` and has line of sight.
- `dodgeSkillPending` flag prevents re-entry; resets after the skill window expires or a dodge fires.

## Key Gotchas

- After pushing to `nyatoru/Neko_Hub`, remote users load new content immediately via `game:HttpGet()`. No deploy step needed.
- `LogicFunction.lua` is the only file for gameplay logic changes. `Menu.lua` wires UI → Logic setters. Both must be updated when adding a feature (Menu element + Logic setter + config-restore line).
- Config file is at executor-specific path: `WindUI/Neko_Hub/configs/NekoHubConfig.json`.
- GitHub raw URLs point to `nyatoru/Neko_Hub` — update these in `Loader.lua` and `Menu.lua` if repo moves.
- The `initTwistOfFate()` and `initVeil()` aim modules are defined as closures and called at the bottom of `LogicFunction.lua`. They capture `AIM_CONFIG` by reference, so setter changes take effect immediately.
- Silent aim uses a `__namecall` metamethod hook (`installNamecallHook()`). Handlers are stored in `namecallHandlers` and checked on every `FireServer` call.
