--[[
    SHHHH V2.2 - Miscellaneous Module
    Macros, Animations, Gun Sorting, Chat Commands, Panic, Checks, Utilities
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Config = getgenv().Shhhh

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "Shhhh", Text = text or "", Duration = dur or 3 })
    end)
end

-- ═══════════════════════════════════════════
-- FPS UNLOCKER
-- ═══════════════════════════════════════════
if Config.Options.UnlockFps.Enabled then
    pcall(function()
        setfpscap(Config.Options.UnlockFps.FpsCap)
    end)
end

-- ═══════════════════════════════════════════
-- CUSTOM TEXTURES
-- ═══════════════════════════════════════════
if Config.Options.CustomTextures.Enabled then
    spawn(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent ~= LocalPlayer.Character then
                pcall(function()
                    v.Material = Enum.Material[Config.Options.CustomTextures.Texture]
                    v.Color = Config.Options.CustomTextures.Color
                end)
            end
        end
        if Config.Options.CustomTextures.Fog.Enabled then
            pcall(function()
                Lighting.FogStart = Config.Options.CustomTextures.Fog.Start
                Lighting.FogEnd = Config.Options.CustomTextures.Fog.End
                Lighting.FogColor = Config.Options.CustomTextures.Fog.Color.Color
            end)
        end
    end)
end

-- ═══════════════════════════════════════════
-- AUTO LOW GFX
-- ═══════════════════════════════════════════
if Config.Misc.Settings.AutoLowGFX then
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character or Workspace) then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)
end

-- ═══════════════════════════════════════════
-- MUTE BOOMBOX
-- ═══════════════════════════════════════════
if Config.Misc.Settings.MuteBoomBox then
    spawn(function()
        while wait(1) do
            pcall(function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Sound") and v.Parent and v.Parent:IsA("BasePart") then
                        v.Volume = 0
                    end
                end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════
-- GUN SORTING
-- ═══════════════════════════════════════════
local function SortGuns()
    if not Config.GunSorting.Enabled then return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end

    local slots = {
        Config.GunSorting.FirstSlot,
        Config.GunSorting.SecondSlot,
        Config.GunSorting.ThirdSlot,
        Config.GunSorting.FourthSlot,
        Config.GunSorting.FifthSlot,
    }

    for i, slotName in ipairs(slots) do
        local tool = bp:FindFirstChild(slotName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(slotName))
        if tool then
            pcall(function()
                tool.Parent = LocalPlayer.Character
                wait(0.05)
                tool.Parent = bp
            end)
        end
    end

    if Config.GunSorting.SortFood then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and not table.find(slots, item.Name) then
                pcall(function()
                    item.Parent = LocalPlayer.Character
                    wait(0.05)
                    item.Parent = bp
                end)
            end
        end
    end
end

-- ═══════════════════════════════════════════
-- MACRO (Stomp/Quick Switch)
-- ═══════════════════════════════════════════
local macroActive = false
local function RunMacro()
    if not Config.Macro.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end

    local tools = {}
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end

    if #tools < 2 then return end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        currentTool.Parent = bp
        wait(0.05)
    end

    local t1 = tools[1]
    local t2 = tools[2]
    t1.Parent = char
    wait(0.08)
    t1.Parent = bp
    t2.Parent = char
end

-- ═══════════════════════════════════════════
-- ANIMATIONS
-- ═══════════════════════════════════════════
local AnimationIds = {
    Lay = "rbxassetid://5918726674",
    Greet = "rbxassetid://5917574964",
    Speed = "rbxassetid://5918644345",
    Sturdy = "rbxassetid://12515580635",
    Griddy = "rbxassetid://10714757194",
}

local function PlayAnimation(animName)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animId = AnimationIds[animName]
    if not animId then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = hum:LoadAnimation(anim)
    track:Play()
    anim:Destroy()
end

-- ═══════════════════════════════════════════
-- AUTO 360 SPIN
-- ═══════════════════════════════════════════
local spinning = false
local function StartSpin()
    spinning = true
    spawn(function()
        while spinning do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(360 * Config.Misc.Auto360.SpinSpeed), 0)
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

-- ═══════════════════════════════════════════
-- CHECK SNIPERS (player watchlist)
-- ═══════════════════════════════════════════
if Config.Misc.CheckSnipers.Enabled then
    Players.PlayerAdded:Connect(function(plr)
        for _, name in ipairs(Config.Misc.CheckSnipers.Usernames) do
            if plr.Name:lower() == name:lower() or plr.DisplayName:lower() == name:lower() then
                if Config.Misc.CheckSnipers.Notification then
                    Notify("⚠ SNIPER ALERT", plr.Name .. " joined!", 10)
                end
                if Config.Misc.CheckSnipers.CloseGame then
                    wait(1)
                    game:Shutdown()
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════
-- MOD DETECTION
-- ═══════════════════════════════════════════
if Config.Mod.Enabled then
    Players.PlayerAdded:Connect(function(plr)
        if plr:IsInGroup(0) then return end
        pcall(function()
            local isMod = false
            if plr.MembershipType == Enum.MembershipType.Premium then end
            -- Simple mod detection placeholder
        end)
    end)
end

-- ═══════════════════════════════════════════
-- TRASH TALK
-- ═══════════════════════════════════════════
local trashTalkActive = false
local function RunTrashTalk()
    if not Config.Misc.TrashTalk.Enabled then return end
    trashTalkActive = not trashTalkActive
    if trashTalkActive then
        spawn(function()
            while trashTalkActive do
                local msgs = Config.Misc.TrashTalk.Messages
                if Config.Misc.TrashTalk.Method == "1" then
                    local msg = msgs[math.random(1, #msgs)]
                    pcall(function()
                        ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                            :FindFirstChild("SayMessageRequest"):FireServer(msg, "All")
                    end)
                else
                    for _, msg in ipairs(msgs) do
                        if not trashTalkActive then break end
                        pcall(function()
                            ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                                :FindFirstChild("SayMessageRequest"):FireServer(msg, "All")
                        end)
                        wait(Config.Misc.TrashTalk.Delay)
                    end
                end
                wait(Config.Misc.TrashTalk.Delay)
            end
        end)
    end
end

-- ═══════════════════════════════════════════
-- CHAT COMMANDS
-- ═══════════════════════════════════════════
if Config.Chat.Enabled then
    LocalPlayer.Chatted:Connect(function(msg)
        local args = msg:split(" ")
        local cmd = args[1]
        local val = tonumber(args[2])

        if cmd == Config.Chat.HitChance and val then
            Config.Silent.HitChance = val
            Notify("Chat", "HitChance set to " .. val)
        elseif cmd == Config.Chat.Silent_Prediction and val then
            Config.Silent.Prediction = val
            Notify("Chat", "Silent Prediction set to " .. val)
        elseif cmd == Config.Chat.Fov_Size and val then
            Config.Fov.Silent.Size = val
            Notify("Chat", "Silent FOV set to " .. val)
        elseif cmd == Config.Chat.AimAssist_Fov_Size and val then
            Config.Fov.AimAssist.Size = val
            Notify("Chat", "AimAssist FOV set to " .. val)
        elseif cmd == Config.Chat.AimAssist_Smoothness and val then
            Config.AimAssist.SmoothValue = val
            Notify("Chat", "Smoothness set to " .. val)
        elseif cmd == Config.Chat.AimAssist_Prediction and val then
            Config.AimAssist.Prediction = val
            Notify("Chat", "AimAssist Prediction set to " .. val)
        elseif cmd == Config.Chat.Show_Fov_Silent then
            Config.Fov.Silent.Visible = args[2] == "true"
            Notify("Chat", "Silent FOV visible = " .. tostring(Config.Fov.Silent.Visible))
        elseif cmd == Config.Chat.Show_Fov_AimAssist then
            Config.Fov.AimAssist.Visible = args[2] == "true"
            Notify("Chat", "AimAssist FOV visible = " .. tostring(Config.Fov.AimAssist.Visible))
        end
    end)
end

-- ═══════════════════════════════════════════
-- REJOIN
-- ═══════════════════════════════════════════
local function RejoinServer()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- ═══════════════════════════════════════════
-- NOCLIP MACRO
-- ═══════════════════════════════════════════
local noclipActive = false
local noclipConn
local function ToggleNoclip()
    noclipActive = not noclipActive
    if noclipActive then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

-- ═══════════════════════════════════════════
-- AUTO RELOAD
-- ═══════════════════════════════════════════
if Config.Misc.Settings.AutoReload then
    spawn(function()
        while wait(0.5) do
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local ammo = tool:FindFirstChild("Ammo")
                        if ammo and ammo:IsA("NumberValue") and ammo.Value <= 0 then
                            tool:Activate()
                        end
                    end
                end
            end)
        end
    end)
end

-- ═══════════════════════════════════════════
-- FAKE SPIKE
-- ═══════════════════════════════════════════
local function FakeSpike()
    pcall(function()
        local dur = Config.Misc.FakeSpike.SpikeDuration
        settings().Network.IncomingReplicationLag = dur
        wait(dur)
        settings().Network.IncomingReplicationLag = 0
    end)
end

-- ═══════════════════════════════════════════
-- INPUT BINDINGS (Misc Keybinds)
-- ═══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Gun Sorting
    if Config.GunSorting.Enabled and input.KeyCode == Enum.KeyCode[Config.GunSorting.Keybind:upper()] then
        SortGuns()
    end

    -- Macro
    if Config.Macro.Enabled then
        if input.KeyCode == Config.Macro.KeyBind then
            if Config.Macro.Hold_Key then
                macroActive = true
                RunMacro()
            else
                RunMacro()
            end
        end
    end

    -- Auto360
    if Config.Misc.Auto360.Enabled and input.KeyCode == Enum.KeyCode[Config.Misc.Auto360.SpinKeybind:upper()] then
        if spinning then spinning = false else StartSpin() end
    end

    -- Close Game
    if Config.Misc.CloseGame.Enabled and input.KeyCode == Enum.KeyCode[Config.Misc.CloseGame.CloseGameKeybind:upper()] then
        if Config.Misc.CloseGame.UseDelay then wait(Config.Misc.CloseGame.Delay) end
        game:Shutdown()
    end

    -- Fake Spike
    if Config.Misc.FakeSpike.Enabled and input.KeyCode == Enum.KeyCode[Config.Misc.FakeSpike.FakeSpikeKeybind:upper()] then
        FakeSpike()
    end

    -- Auto Reset
    if Config.Misc.AutoReset.Enabled and input.KeyCode == Enum.KeyCode[Config.Misc.AutoReset.AutoResetKeybind:upper()] then
        if Config.Misc.AutoReset.UseDelay then wait(Config.Misc.AutoReset.Delay) end
        pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
    end

    -- Trash Talk
    if Config.Misc.TrashTalk.Enabled and input.KeyCode == Enum.KeyCode[Config.Misc.TrashTalk.KeyBind:upper()] then
        RunTrashTalk()
    end

    -- Rejoin
    if Config.Rejoin.Enabled and input.KeyCode == Enum.KeyCode[Config.Rejoin.Keybind:upper()] then
        RejoinServer()
    end

    -- Noclip
    if Config.Noclip_Macro.Enabled and input.KeyCode == Config.Noclip_Macro.KeyBind then
        ToggleNoclip()
    end

    -- Mod Panic
    if Config.Mod.Enabled and Config.Mod.Mode == 'Key' and input.KeyCode == Enum.KeyCode[Config.Mod.Key:upper()] then
        game:Shutdown()
    end

    -- Animations
    if Config.Animation.Lay and input.KeyCode == Config.Animation.LayKey then PlayAnimation("Lay") end
    if Config.Animation.Greet and input.KeyCode == Config.Animation.GreetKey then PlayAnimation("Greet") end
    if Config.Animation.Speed and input.KeyCode == Config.Animation.SpeedKey then PlayAnimation("Speed") end
    if Config.Animation.Sturdy and input.KeyCode == Config.Animation.SturdyKey then PlayAnimation("Sturdy") end
    if Config.Animation.Griddy and input.KeyCode == Config.Animation.GriddyKey then PlayAnimation("Griddy") end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if Config.Macro.Enabled and Config.Macro.Hold_Key and input.KeyCode == Config.Macro.KeyBind then
        macroActive = false
    end
end)

-- ═══════════════════════════════════════════
-- MEMORY (Speed Toggle)
-- ═══════════════════════════════════════════
if Config.Memory.Enabled then
    spawn(function()
        while wait(0.1) do
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    hum.WalkSpeed = math.random(Config.Memory.Start, Config.Memory.End) * Config.Memory.Speed
                end
            end)
        end
    end)
end

Notify("Shhhh V2.2", "Misc module loaded!", 3)
