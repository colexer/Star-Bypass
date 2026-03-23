--[[

░██████╗██╗░░██╗██╗░░██╗██╗░░██╗██╗░░██╗  ██╗░░░██╗██████╗░░░░██████╗░
██╔════╝██║░░██║██║░░██║██║░░██║██║░░██║  ██║░░░██║╚════██╗░░░╚════██╗
╚█████╗░███████║███████║███████║███████║  ╚██╗░██╔╝░░███╔═╝░░░░░███╔═╝
░╚═══██╗██╔══██║██╔══██║██╔══██║██╔══██║  ░╚████╔╝░██╔══╝░░░░██╔══╝░░
██████╔╝██║░░██║██║░░██║██║░░██║██║░░██║  ░░╚██╔╝░░███████╗░░███████╗
╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝  ░░░╚═╝░░╚══════╝░░╚══════╝

    SHHHH V2.2 - Full Feature Recreation
    Combined Loader - Loads all modules

    Modules:
        shhhh_core.lua      → Config, Services, Utilities
        shhhh_targeting.lua  → Silent Aim, Aim Assist, TriggerBot, FOV, Resolver
        shhhh_esp.lua        → Box/Corner ESP, Skeleton, Chams, Text, Health/Armor Bars
        shhhh_misc.lua       → Macros, Animations, Gun Sort, Chat Cmds, All Utilities

    Features Included:
        ✓ Silent Aim (FOV / Target mode, namecall hook)
        ✓ Aim Assist (Smooth, Easing, Prediction, First/Third Person)
        ✓ TriggerBot (KeyBind / Hold modes)
        ✓ Resolver (Anti-Aim detection + velocity correction)
        ✓ Auto-Prediction (Ping-based dynamic prediction)
        ✓ Gun-Specific Settings (per-gun FOV, prediction, smoothness, hitchance)
        ✓ FOV Circles (Silent + AimAssist, configurable)
        ✓ ESP - Box (Full / Corners / Dynamic)
        ✓ ESP - Skeleton (R15 joint-based)
        ✓ ESP - Chams (Highlight-based, always-on-top)
        ✓ ESP - Text (Name, Distance, Tool/Weapon)
        ✓ ESP - Health & Armor Bars
        ✓ Shake / Recoil offset
        ✓ Panic Key (kill-switch)
        ✓ Wall Check, Knocked Check, Grabbed Check, Crew Check
        ✓ Airshot Detection + NoGroundShots
        ✓ FPS Unlocker
        ✓ Custom Textures + Fog
        ✓ Auto Low GFX
        ✓ Mute BoomBox
        ✓ Gun Sorting (5 slots + food sorting)
        ✓ Macro (Quick switch)
        ✓ Noclip Macro
        ✓ Animations (Lay, Greet, Speed, Sturdy, Griddy)
        ✓ Auto 360 Spin
        ✓ Check Snipers (username watchlist)
        ✓ Mod Detection
        ✓ Trash Talk (random / sequential modes)
        ✓ Chat Commands ($hc, $pred, $fov, !fov, !smooth, !pred, etc.)
        ✓ Auto Reset, Close Game, Fake Spike
        ✓ Rejoin Server
        ✓ Memory (WalkSpeed manipulation)
        ✓ Auto Reload
        ✓ Frame Skip (for Aim Assist)

--]]

-- ═══════════════════════════════════════════
-- CONFIGURATION (edit getgenv().Shhhh in shhhh_core.lua before loading)
-- ═══════════════════════════════════════════

local StarterGui = game:GetService("StarterGui")

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Shhhh",
            Text = text or "",
            Duration = dur or 5,
        })
    end)
end

-- ═══════════ INTRO ═══════════
if getgenv().Shhhh and getgenv().Shhhh.Options and getgenv().Shhhh.Options.Intro then
    Notify("SHHHH V2.2", "Loading...", 3)
    wait(1.5)
end

-- ═══════════ LOAD MODULES ═══════════
-- Option 1: Load from GitHub raw links (replace with your URLs)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR/REPO/main/shhhh_core.lua", true))()
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR/REPO/main/shhhh_targeting.lua", true))()
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR/REPO/main/shhhh_esp.lua", true))()
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR/REPO/main/shhhh_misc.lua", true))()

-- Option 2: If running locally in an executor, use readfile / loadstring
-- Config must be loaded first
pcall(function()
    loadstring(readfile("shhhh_core.lua"))()
end)

pcall(function()
    loadstring(readfile("shhhh_targeting.lua"))()
end)

pcall(function()
    loadstring(readfile("shhhh_esp.lua"))()
end)

pcall(function()
    loadstring(readfile("shhhh_misc.lua"))()
end)

-- ═══════════════════════════════════════════
Notify("SHHHH V2.2", "All modules loaded successfully! 🔥", 5)
print("[SHHHH V2.2] Fully loaded. All features active.")
