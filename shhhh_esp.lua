--[[
    SHHHH V2.2 - ESP & Visuals Module
    Box ESP, Skeleton, Chams, Text Tags (Drawing API)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ensure config always exists with safe defaults
if not getgenv().Shhhh then getgenv().Shhhh = {} end
local cfg = getgenv().Shhhh
if not cfg.Esp then
    cfg.Esp = {
        Enabled = false, Use_KeyBind = true, KeyBind = Enum.KeyCode.L,
        BoxEnabled = true, BoxCorners = true,
        BoxStaticXFactor = 1.3, BoxStaticYFactor = 2.1,
        BoxColor = Color3.fromRGB(255, 255, 255),
        SkeletonEnabled = true, SkeletonColor = Color3.fromRGB(255, 255, 255),
        SkeletonMaxDistance = 300,
        ChamsEnabled = true,
        ChamsInnerColor = Color3.fromRGB(102, 60, 153),
        ChamsOuterColor = Color3.fromRGB(0, 0, 0),
        ChamsInnerTransparency = 0.3, ChamsOuterTransparency = 0,
        TextEnabled = true, TextColor = Color3.fromRGB(255, 255, 255),
        TextLayout = {
            nametag  = { enabled = true }, name = { enabled = true },
            health   = { enabled = true, bar = 'health' },
            armor    = { enabled = true, bar = 'armor' },
            tool     = { enabled = true, suffix = '', prefix = '' },
            distance = { enabled = true, suffix = 'm' },
        },
        BarLayout = {
            health = { enabled = true, color_empty = Color3.fromRGB(176,84,84), color_full = Color3.fromRGB(140,250,140) },
            armor  = { enabled = true, color_empty = Color3.fromRGB(58,58,97),  color_full = Color3.fromRGB(72,72,250) },
        },
    }
end
if not cfg.Universal then cfg.Universal = { TeamCheck = true } end
local Config = cfg

-- ═══════════════════════════════════════════
-- ESP OBJECT MANAGEMENT
-- ═══════════════════════════════════════════
local ESPObjects = {}

local function IsAlive(plr)
    local c = plr and plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") ~= nil
end

local function TeamCheck(plr)
    if not Config.Universal.TeamCheck then return true end
    if not LocalPlayer.Team or not plr.Team then return true end
    return LocalPlayer.Team ~= plr.Team
end

local function CreateESPForPlayer(plr)
    if ESPObjects[plr] then return end
    Config = getgenv().Shhhh  -- refresh in case core loaded after

    local esp = {}

    pcall(function()
        -- Box Lines (4 lines for box, or 8 for corners)
        esp.BoxLines = {}
        for i = 1, 8 do
            local line = Drawing.new("Line")
            line.Color = Config.Esp.BoxColor
            line.Thickness = 1
            line.Visible = false
            esp.BoxLines[i] = line
        end

        -- Corner Lines (8 additional for corner style)
        esp.CornerLines = {}
        for i = 1, 16 do
            local line = Drawing.new("Line")
            line.Color = Config.Esp.BoxColor
            line.Thickness = 1
            line.Visible = false
            esp.CornerLines[i] = line
        end

        -- Skeleton Lines
        esp.SkeletonLines = {}
        for i = 1, 12 do
            local line = Drawing.new("Line")
            line.Color = Config.Esp.SkeletonColor
            line.Thickness = 1
            line.Visible = false
            esp.SkeletonLines[i] = line
        end

        -- Name Text
        esp.NameText = Drawing.new("Text")
        esp.NameText.Color = Config.Esp.TextColor
        esp.NameText.Size = 13
        esp.NameText.Center = true
        esp.NameText.Outline = true
        esp.NameText.OutlineColor = Color3.new(0, 0, 0)
        esp.NameText.Visible = false

        -- Distance Text
        esp.DistText = Drawing.new("Text")
        esp.DistText.Color = Config.Esp.TextColor
        esp.DistText.Size = 12
        esp.DistText.Center = true
        esp.DistText.Outline = true
        esp.DistText.OutlineColor = Color3.new(0, 0, 0)
        esp.DistText.Visible = false

        -- Tool Text
        esp.ToolText = Drawing.new("Text")
        esp.ToolText.Color = Config.Esp.TextColor
        esp.ToolText.Size = 12
        esp.ToolText.Center = true
        esp.ToolText.Outline = true
        esp.ToolText.OutlineColor = Color3.new(0, 0, 0)
        esp.ToolText.Visible = false

        -- Health Bar (vertical line on left)
        esp.HealthBarBg = Drawing.new("Line")
        esp.HealthBarBg.Thickness = 3
        esp.HealthBarBg.Visible = false

        esp.HealthBarFill = Drawing.new("Line")
        esp.HealthBarFill.Thickness = 2
        esp.HealthBarFill.Visible = false

        -- Armor Bar
        esp.ArmorBarBg = Drawing.new("Line")
        esp.ArmorBarBg.Thickness = 3
        esp.ArmorBarBg.Visible = false

        esp.ArmorBarFill = Drawing.new("Line")
        esp.ArmorBarFill.Thickness = 2
        esp.ArmorBarFill.Visible = false
    end)

    -- Chams (Highlight Instance)
    esp.Highlight = nil
    if Config.Esp.ChamsEnabled then
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.FillColor = Config.Esp.ChamsInnerColor
            hl.OutlineColor = Config.Esp.ChamsOuterColor
            hl.FillTransparency = Config.Esp.ChamsInnerTransparency
            hl.OutlineTransparency = Config.Esp.ChamsOuterTransparency
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            esp.Highlight = hl
        end)
    end

    ESPObjects[plr] = esp
end

local function RemoveESPForPlayer(plr)
    local esp = ESPObjects[plr]
    if not esp then return end

    pcall(function()
        for _, line in ipairs(esp.BoxLines or {}) do line:Remove() end
        for _, line in ipairs(esp.CornerLines or {}) do line:Remove() end
        for _, line in ipairs(esp.SkeletonLines or {}) do line:Remove() end
        if esp.NameText then esp.NameText:Remove() end
        if esp.DistText then esp.DistText:Remove() end
        if esp.ToolText then esp.ToolText:Remove() end
        if esp.HealthBarBg then esp.HealthBarBg:Remove() end
        if esp.HealthBarFill then esp.HealthBarFill:Remove() end
        if esp.ArmorBarBg then esp.ArmorBarBg:Remove() end
        if esp.ArmorBarFill then esp.ArmorBarFill:Remove() end
        if esp.Highlight then esp.Highlight:Destroy() end
    end)

    ESPObjects[plr] = nil
end

local function HideESP(esp)
    pcall(function()
        for _, line in ipairs(esp.BoxLines or {}) do line.Visible = false end
        for _, line in ipairs(esp.CornerLines or {}) do line.Visible = false end
        for _, line in ipairs(esp.SkeletonLines or {}) do line.Visible = false end
        if esp.NameText then esp.NameText.Visible = false end
        if esp.DistText then esp.DistText.Visible = false end
        if esp.ToolText then esp.ToolText.Visible = false end
        if esp.HealthBarBg then esp.HealthBarBg.Visible = false end
        if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
        if esp.ArmorBarBg then esp.ArmorBarBg.Visible = false end
        if esp.ArmorBarFill then esp.ArmorBarFill.Visible = false end
        if esp.Highlight then esp.Highlight.Parent = nil end
    end)
end

-- ═══════════════════════════════════════════
-- SKELETON JOINT MAP
-- ═══════════════════════════════════════════
local SkeletonPairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
}

-- ═══════════════════════════════════════════
-- ESP UPDATE LOOP
-- ═══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        if not ESPObjects[plr] then
            CreateESPForPlayer(plr)
        end

        local esp = ESPObjects[plr]
        if not esp then continue end

        if not Config.Esp.Enabled or not IsAlive(plr) or not TeamCheck(plr) then
            HideESP(esp)
            continue
        end

        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then HideESP(esp); continue end

        local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then HideESP(esp); continue end

        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local distance = myHrp and (hrp.Position - myHrp.Position).Magnitude or 0

        -- Calculate box dimensions
        local headPos = char:FindFirstChild("Head")
        local topY, botY = rootPos.Y, rootPos.Y
        if headPos then
            local hp = Camera:WorldToViewportPoint(headPos.Position + Vector3.new(0, 1.5, 0))
            local fp = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            topY = hp.Y
            botY = fp.Y
        end

        local boxH = math.abs(botY - topY)
        local boxW = boxH * 0.6
        local boxX = rootPos.X - boxW / 2
        local boxY = topY

        -- ══ BOX ESP ══
        if Config.Esp.BoxEnabled then
            if Config.Esp.BoxCorners then
                local cornerLen = boxW * 0.25
                local lines = esp.CornerLines
                -- Top-left
                if lines[1] then lines[1].From = Vector2.new(boxX, boxY); lines[1].To = Vector2.new(boxX + cornerLen, boxY); lines[1].Visible = true end
                if lines[2] then lines[2].From = Vector2.new(boxX, boxY); lines[2].To = Vector2.new(boxX, boxY + cornerLen); lines[2].Visible = true end
                -- Top-right
                if lines[3] then lines[3].From = Vector2.new(boxX + boxW, boxY); lines[3].To = Vector2.new(boxX + boxW - cornerLen, boxY); lines[3].Visible = true end
                if lines[4] then lines[4].From = Vector2.new(boxX + boxW, boxY); lines[4].To = Vector2.new(boxX + boxW, boxY + cornerLen); lines[4].Visible = true end
                -- Bottom-left
                if lines[5] then lines[5].From = Vector2.new(boxX, boxY + boxH); lines[5].To = Vector2.new(boxX + cornerLen, boxY + boxH); lines[5].Visible = true end
                if lines[6] then lines[6].From = Vector2.new(boxX, boxY + boxH); lines[6].To = Vector2.new(boxX, boxY + boxH - cornerLen); lines[6].Visible = true end
                -- Bottom-right
                if lines[7] then lines[7].From = Vector2.new(boxX + boxW, boxY + boxH); lines[7].To = Vector2.new(boxX + boxW - cornerLen, boxY + boxH); lines[7].Visible = true end
                if lines[8] then lines[8].From = Vector2.new(boxX + boxW, boxY + boxH); lines[8].To = Vector2.new(boxX + boxW, boxY + boxH - cornerLen); lines[8].Visible = true end
                for i = 9, 16 do if lines[i] then lines[i].Visible = false end end
            else
                local lines = esp.BoxLines
                if lines[1] then lines[1].From = Vector2.new(boxX, boxY); lines[1].To = Vector2.new(boxX + boxW, boxY); lines[1].Visible = true end
                if lines[2] then lines[2].From = Vector2.new(boxX + boxW, boxY); lines[2].To = Vector2.new(boxX + boxW, boxY + boxH); lines[2].Visible = true end
                if lines[3] then lines[3].From = Vector2.new(boxX, boxY + boxH); lines[3].To = Vector2.new(boxX + boxW, boxY + boxH); lines[3].Visible = true end
                if lines[4] then lines[4].From = Vector2.new(boxX, boxY); lines[4].To = Vector2.new(boxX, boxY + boxH); lines[4].Visible = true end
                for i = 5, 8 do if lines[i] then lines[i].Visible = false end end
            end
        else
            for _, line in ipairs(esp.BoxLines or {}) do line.Visible = false end
            for _, line in ipairs(esp.CornerLines or {}) do line.Visible = false end
        end

        -- ══ SKELETON ESP ══
        if Config.Esp.SkeletonEnabled and distance <= Config.Esp.SkeletonMaxDistance then
            for i, pair in ipairs(SkeletonPairs) do
                local p1 = char:FindFirstChild(pair[1])
                local p2 = char:FindFirstChild(pair[2])
                local line = esp.SkeletonLines[i]
                if p1 and p2 and line then
                    local s1, v1 = Camera:WorldToViewportPoint(p1.Position)
                    local s2, v2 = Camera:WorldToViewportPoint(p2.Position)
                    if v1 and v2 then
                        line.From = Vector2.new(s1.X, s1.Y)
                        line.To = Vector2.new(s2.X, s2.Y)
                        line.Color = Config.Esp.SkeletonColor
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                elseif line then
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(esp.SkeletonLines or {}) do line.Visible = false end
        end

        -- ══ CHAMS ══
        if Config.Esp.ChamsEnabled and esp.Highlight then
            esp.Highlight.FillColor = Config.Esp.ChamsInnerColor
            esp.Highlight.OutlineColor = Config.Esp.ChamsOuterColor
            esp.Highlight.FillTransparency = Config.Esp.ChamsInnerTransparency
            esp.Highlight.OutlineTransparency = Config.Esp.ChamsOuterTransparency
            esp.Highlight.Adornee = char
            esp.Highlight.Parent = char
        elseif esp.Highlight then
            esp.Highlight.Parent = nil
        end

        -- ══ TEXT ESP ══
        if Config.Esp.TextEnabled then
            -- Name
            if esp.NameText then
                local nameTag = plr.DisplayName or plr.Name
                esp.NameText.Text = nameTag
                esp.NameText.Position = Vector2.new(rootPos.X, boxY - 16)
                esp.NameText.Color = Config.Esp.TextColor
                esp.NameText.Visible = true
            end
            -- Distance
            if esp.DistText then
                esp.DistText.Text = math.floor(distance) .. "m"
                esp.DistText.Position = Vector2.new(rootPos.X, boxY + boxH + 2)
                esp.DistText.Color = Config.Esp.TextColor
                esp.DistText.Visible = true
            end
            -- Tool
            if esp.ToolText then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    esp.ToolText.Text = tool.Name
                    esp.ToolText.Position = Vector2.new(rootPos.X, boxY + boxH + 14)
                    esp.ToolText.Color = Config.Esp.TextColor
                    esp.ToolText.Visible = true
                else
                    esp.ToolText.Visible = false
                end
            end
        else
            if esp.NameText then esp.NameText.Visible = false end
            if esp.DistText then esp.DistText.Visible = false end
            if esp.ToolText then esp.ToolText.Visible = false end
        end

        -- ══ HEALTH & ARMOR BARS ══
        local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barX = boxX - 6
        if esp.HealthBarBg then
            esp.HealthBarBg.From = Vector2.new(barX, boxY)
            esp.HealthBarBg.To = Vector2.new(barX, boxY + boxH)
            esp.HealthBarBg.Color = Config.Esp.BarLayout.health.color_empty
            esp.HealthBarBg.Visible = Config.Esp.BarLayout.health.enabled
        end
        if esp.HealthBarFill then
            esp.HealthBarFill.From = Vector2.new(barX, boxY + boxH)
            esp.HealthBarFill.To = Vector2.new(barX, boxY + boxH - (boxH * healthPct))
            esp.HealthBarFill.Color = Config.Esp.BarLayout.health.color_full:Lerp(Config.Esp.BarLayout.health.color_empty, 1 - healthPct)
            esp.HealthBarFill.Visible = Config.Esp.BarLayout.health.enabled
        end

        -- Armor bar
        local armorBarX = barX - 4
        local armor = 0
        local be = char:FindFirstChild("BodyEffects")
        if be then
            local av = be:FindFirstChild("Armor")
            if av and av:IsA("NumberValue") then armor = av.Value end
        end
        local armorPct = math.clamp(armor / 100, 0, 1)
        if esp.ArmorBarBg then
            esp.ArmorBarBg.From = Vector2.new(armorBarX, boxY)
            esp.ArmorBarBg.To = Vector2.new(armorBarX, boxY + boxH)
            esp.ArmorBarBg.Color = Config.Esp.BarLayout.armor.color_empty
            esp.ArmorBarBg.Visible = Config.Esp.BarLayout.armor.enabled and armor > 0
        end
        if esp.ArmorBarFill then
            esp.ArmorBarFill.From = Vector2.new(armorBarX, boxY + boxH)
            esp.ArmorBarFill.To = Vector2.new(armorBarX, boxY + boxH - (boxH * armorPct))
            esp.ArmorBarFill.Color = Config.Esp.BarLayout.armor.color_full
            esp.ArmorBarFill.Visible = Config.Esp.BarLayout.armor.enabled and armor > 0
        end
    end
end)

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(plr)
    RemoveESPForPlayer(plr)
end)

pcall(function()
    StarterGui:SetCore("SendNotification", { Title = "Shhhh V2.2", Text = "ESP module loaded!", Duration = 3 })
end)
