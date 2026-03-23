--[[
    SHHHH V2.2 - Targeting Module
    Silent Aim, Aim Assist, TriggerBot, Auto-Prediction, FOV Circles
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Pull config from global
local Config = getgenv().Shhhh
local State = {
    SilentEnabled = Config.Silent.Enabled,
    AimAssistEnabled = Config.AimAssist.Enabled,
    AimAssistLocked = false,
    AimAssistTarget = nil,
    TriggerBotEnabled = Config.TriggerBot.Enabled,
    FrameSkipEnabled = false,
    PanicActive = false,
    Ping = 0,
}

-- ═══════════════════════════════════════════
-- SHARED UTILITIES (inline for standalone)
-- ═══════════════════════════════════════════
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "Shhhh", Text = text or "", Duration = dur or 3 })
    end)
end

local function GetPing()
    local p = 0
    pcall(function() p = LocalPlayer:GetNetworkPing() * 1000 end)
    State.Ping = p
    return p
end

local function IsAlive(plr)
    local c = plr and plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") ~= nil
end

local function IsKnocked(plr)
    if not Config.Checks.Knocked then return false end
    local c = plr and plr.Character
    if not c then return false end
    local be = c:FindFirstChild("BodyEffects")
    if be then
        local ko = be:FindFirstChild("K.O")
        if ko and ko:IsA("BoolValue") and ko.Value then return true end
    end
    return false
end

local function IsGrabbed(plr)
    if not Config.Checks.Grabbed then return false end
    local c = plr and plr.Character
    if not c then return false end
    if c:FindFirstChild("YOURGRABBEDLOL") then return true end
    local be = c:FindFirstChild("BodyEffects")
    if be then
        local g = be:FindFirstChild("Grabbed")
        if g and g:IsA("BoolValue") and g.Value then return true end
    end
    return false
end

local function IsInAir(plr)
    local c = plr and plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.FloorMaterial == Enum.Material.Air
end

local function TeamCheck(plr)
    if not Config.Universal.TeamCheck then return true end
    if not LocalPlayer.Team or not plr.Team then return true end
    return LocalPlayer.Team ~= plr.Team
end

local function CrewCheck(plr)
    if not Config.Checks.Crew_Check then return true end
    return true
end

local function WallCheck(origin, target)
    if not Config.Checks.Wall then return true end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local ignore = {LocalPlayer.Character, Camera}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(ignore, p.Character) end
    end
    rp.FilterDescendantsInstances = ignore
    return Workspace:Raycast(origin, target - origin, rp) == nil
end

local function ValidTarget(plr)
    return plr ~= LocalPlayer and IsAlive(plr) and not IsKnocked(plr)
        and not IsGrabbed(plr) and TeamCheck(plr) and CrewCheck(plr)
end

local function GetHitPart(char, partName)
    if partName == 'Random' then
        local parts = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'}
        partName = parts[math.random(1, #parts)]
    end
    return char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
end

local function GetNearestPoint(char, mousePos)
    local best, bestDist = nil, math.huge
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            local sp, vis = Camera:WorldToViewportPoint(p.Position)
            if vis then
                local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                if d < bestDist then bestDist = d; best = p end
            end
        end
    end
    return best
end

local function MapGun(name)
    local m = {
        ["[Double-Barrel SG]"]="DoubleBarrel",["Double-Barrel SG"]="DoubleBarrel",
        ["[Revolver]"]="Revolver",["Revolver"]="Revolver",
        ["[Rifle]"]="Rifle",["Rifle"]="Rifle",
        ["[Shotgun]"]="Shotgun",["Shotgun"]="Shotgun",
        ["[SMG]"]="Smg",["SMG"]="Smg",
        ["[TacticalShotgun]"]="TacticalShotgun",["TacticalShotgun"]="TacticalShotgun",
        ["[Silencer]"]="Silencer",["Silencer"]="Silencer",
        ["[AK47]"]="AK47",["AK47"]="AK47",
        ["[AR]"]="AR",["AR"]="AR",
    }
    return m[name]
end

local function GetGunOverrides(gunName, dist, airshot)
    if not Config.GunFov.Enabled then return nil end
    local key = MapGun(gunName)
    if not key or not Config.GunFov[key] then return nil end
    local g = Config.GunFov[key]
    local pfx = ""
    if Config.GunFov.AirShot and airshot then pfx = "AirShot_"
    elseif Config.GunFov.Range then
        if dist <= Config.GunFov.Close then pfx = "Close_"
        elseif dist <= Config.GunFov.Mid then pfx = "Mid_"
        else pfx = "Far_" end
    end
    return {
        Fov = g[pfx.."Fov"] or g["Fov"],
        Prediction = g[pfx.."Prediction"] or g["Prediction"],
        HitChance = g[pfx.."HitChance"] or g["HitChance"],
        Smoothness = g[pfx.."Smoothness"] or g["Smoothness"],
    }
end

-- ═══════════════════════════════════════════
-- FOV CIRCLES (Drawing API)
-- ═══════════════════════════════════════════
local SilentCircle, AimAssistCircle

pcall(function()
    SilentCircle = Drawing.new("Circle")
    SilentCircle.Color = Config.Fov.Silent.Color
    SilentCircle.Thickness = Config.Fov.Silent.Thickness
    SilentCircle.Radius = Config.Fov.Silent.Size
    SilentCircle.Filled = Config.Fov.Silent.Filled
    SilentCircle.Transparency = 1 - Config.Fov.Silent.Transparency
    SilentCircle.Visible = Config.Fov.Silent.Visible
    SilentCircle.NumSides = 64

    AimAssistCircle = Drawing.new("Circle")
    AimAssistCircle.Color = Config.Fov.AimAssist.Color
    AimAssistCircle.Thickness = Config.Fov.AimAssist.Thickness
    AimAssistCircle.Radius = Config.Fov.AimAssist.Size
    AimAssistCircle.Filled = Config.Fov.AimAssist.Filled
    AimAssistCircle.Transparency = 1 - Config.Fov.AimAssist.Transparency
    AimAssistCircle.Visible = Config.Fov.AimAssist.Visible
    AimAssistCircle.NumSides = 64
end)

-- Update FOV circle positions
RunService.RenderStepped:Connect(function()
    if State.PanicActive then
        if SilentCircle then SilentCircle.Visible = false end
        if AimAssistCircle then AimAssistCircle.Visible = false end
        return
    end
    local center = Camera.ViewportSize / 2
    local offset = Vector2.new(Config.Fov.Silent.Set[1] or 0, Config.Fov.Silent.Set[2] or 0)
    if SilentCircle then
        SilentCircle.Position = center + offset
        SilentCircle.Radius = Config.Fov.Silent.Size
        SilentCircle.Visible = Config.Fov.Silent.Visible and State.SilentEnabled
    end
    local offset2 = Vector2.new(Config.Fov.AimAssist.Set[1] or 0, Config.Fov.AimAssist.Set[2] or 0)
    if AimAssistCircle then
        AimAssistCircle.Position = center + offset2
        AimAssistCircle.Radius = Config.Fov.AimAssist.Size
        AimAssistCircle.Visible = Config.Fov.AimAssist.Visible and State.AimAssistEnabled
    end
end)

-- ═══════════════════════════════════════════
-- AUTO-PREDICTION (ping-based)
-- ═══════════════════════════════════════════
local function GetAutoPrediction()
    if not Config.AutoPrediction.Enabled then return Config.Silent.Prediction end
    local ping = GetPing()
    local ranges = {
        {20,30,"p20_30"},{30,40,"p30_40"},{40,50,"p40_50"},{50,60,"p50_60"},
        {60,70,"p60_70"},{70,80,"p70_80"},{80,90,"p80_90"},{90,100,"p90_100"},
        {100,110,"p100_110"},{110,120,"p110_120"},{120,130,"p120_130"},
        {130,140,"p130_140"},{140,150,"p140_150"},{150,160,"p150_160"},
        {160,170,"p160_170"},{170,180,"p170_180"},{180,190,"p180_190"},{190,200,"p190_200"},
    }
    for _, r in ipairs(ranges) do
        if ping >= r[1] and ping < r[2] then
            return Config.AutoPrediction[r[3]] or Config.Silent.Prediction
        end
    end
    return Config.Silent.Prediction
end

-- ═══════════════════════════════════════════
-- RESOLVER (Anti-Aim Detection)
-- ═══════════════════════════════════════════
local ResolverData = {}
local function ResolvePlayer(plr)
    if not Config.Resolver.Enabled then return Vector3.zero end
    local char = plr.Character
    if not char then return Vector3.zero end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.zero end

    local id = plr.UserId
    if not ResolverData[id] then
        ResolverData[id] = { lastPos = hrp.Position, lastVel = hrp.Velocity, tick = tick() }
    end
    local rd = ResolverData[id]
    local dt = tick() - rd.tick
    if dt > 0 then
        local realVel = (hrp.Position - rd.lastPos) / dt
        local serverVel = hrp.Velocity
        local diff = (realVel - serverVel)
        rd.lastPos = hrp.Position
        rd.lastVel = serverVel
        rd.tick = tick()
        if diff.Magnitude > 15 then
            return -diff * 0.5
        end
    end
    return Vector3.zero
end

-- ═══════════════════════════════════════════
-- SILENT AIM
-- ═══════════════════════════════════════════
local function GetSilentTarget()
    if not State.SilentEnabled or State.PanicActive then return nil, nil end

    local fovSize = Config.Fov.Silent.Size
    local mousePos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, fovSize

    -- Gun overrides
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local gunName = tool and tool.Name or ""

    for _, plr in ipairs(Players:GetPlayers()) do
        if ValidTarget(plr) then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local airshot = IsInAir(plr)
                if Config.Checks.NoGroundShots or not (not airshot and Config.Checks.Airshot) then
                    local targetPart
                    if Config.Silent.NearestCursorHitpart and Config.Silent.HitPart_Mode == 'Nearest Point' then
                        targetPart = GetNearestPoint(char, mousePos)
                    elseif Config.Silent.NearestCursorHitpart and Config.Silent.HitPart_Mode == 'Nearest Part' then
                        targetPart = GetNearestPoint(char, mousePos)
                    else
                        targetPart = GetHitPart(char, Config.Silent.HitParts)
                    end

                    if targetPart then
                        local sp, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude

                            -- Apply gun-specific FOV
                            local gunOverride = GetGunOverrides(gunName, (hrp.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero)).Magnitude, airshot)
                            local activeFov = fovSize
                            if gunOverride and Config.GunFov.Fov then
                                activeFov = gunOverride.Fov
                            end

                            if dist < activeFov and dist < closestDist then
                                if Config.Checks.Wall then
                                    if WallCheck(Camera.CFrame.Position, targetPart.Position) then
                                        closestDist = dist
                                        closest = {Player = plr, Part = targetPart, Airshot = airshot, GunOverride = gunOverride}
                                    end
                                else
                                    closestDist = dist
                                    closest = {Player = plr, Part = targetPart, Airshot = airshot, GunOverride = gunOverride}
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

-- Namecall Hook for Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
        if State.SilentEnabled and not State.PanicActive then
            local target = GetSilentTarget()
            if target then
                local part = target.Part
                local prediction = GetAutoPrediction()

                -- Gun-specific prediction
                if target.GunOverride and Config.GunFov.Prediction then
                    prediction = target.GunOverride.Prediction
                end

                -- Hit chance
                local hc = Config.Silent.HitChance
                if target.Airshot then hc = Config.Silent.AirShot_HitChance end
                if target.GunOverride and Config.GunFov.HitChance then
                    hc = target.GunOverride.HitChance
                end

                if math.random(1, 300) <= hc then
                    local hrp = target.Player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = hrp.Velocity
                        local resolverOffset = ResolvePlayer(target.Player)
                        local predictedPos = part.Position + (vel * prediction) + resolverOffset

                        -- Shake
                        if Config.Shake.Enabled then
                            local sx, sy, sz = Config.Shake.X, Config.Shake.Y, Config.Shake.Z
                            if target.Airshot and Config.Shake.AirShot then
                                sx = Config.Shake.Airshot___X
                                sy = Config.Shake.Airshot___Y
                                sz = Config.Shake.Airshot___Z
                            end
                            predictedPos = predictedPos + Vector3.new(
                                math.random(-sx, sx) * 0.1,
                                math.random(-sy, sy) * 0.1,
                                math.random(-sz, sz) * 0.1
                            )
                        end

                        local origin = Camera.CFrame.Position
                        local direction = (predictedPos - origin).Unit * 1000
                        args[1] = Ray.new(origin, direction)
                    end
                end
            end
        end
    end

    return oldNamecall(self, unpack(args))
end))

-- ═══════════════════════════════════════════
-- AIM ASSIST
-- ═══════════════════════════════════════════
local AimAssistTarget = nil
local AimAssistActive = false

local function GetAimAssistTarget()
    local fovSize = Config.Fov.AimAssist.Size
    local mousePos = UserInputService:GetMouseLocation()
    local closest, closestDist = nil, Config.Fov.AimAssist.Use_Fov and fovSize or math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if ValidTarget(plr) then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        if not Config.Checks.Wall or WallCheck(Camera.CFrame.Position, hrp.Position) then
                            closestDist = dist
                            closest = plr
                        end
                    end
                end
            end
        end
    end
    return closest
end

local easingMap = {
    Linear = Enum.EasingStyle.Linear,
    Sine = Enum.EasingStyle.Sine,
    Back = Enum.EasingStyle.Back,
    Quad = Enum.EasingStyle.Quad,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Exponential = Enum.EasingStyle.Exponential,
    Circular = Enum.EasingStyle.Circular,
    Cubic = Enum.EasingStyle.Cubic,
}

RunService.RenderStepped:Connect(function()
    if not Config.AimAssist.Enabled or not AimAssistActive or State.PanicActive then return end

    -- Unlock checks
    if Config.AimAssist.UnLockWhenTyping and UserInputService:GetFocusedTextBox() then return end

    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if Config.AimAssist.UnlockWhenNotHoldingGun and not tool then return end

    -- Camera mode check
    local isFirstPerson = (Camera.CFrame.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head.Position or Camera.CFrame.Position)).Magnitude < 1
    if isFirstPerson and not Config.AimAssist.FirstPerson then return end
    if not isFirstPerson and not Config.AimAssist.ThirdPerson then return end

    -- Get or validate target
    if not AimAssistTarget or not IsAlive(AimAssistTarget) or IsKnocked(AimAssistTarget) then
        if Config.AimAssist.Mode == 'Auto' then
            AimAssistTarget = GetAimAssistTarget()
        end
        if not AimAssistTarget then return end
    end

    -- Disable outside FOV check
    if Config.Fov.AimAssist.Disable_Outside_Fov then
        local hrp = AimAssistTarget.Character and AimAssistTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local sp = Camera:WorldToViewportPoint(hrp.Position)
            local mousePos = UserInputService:GetMouseLocation()
            if (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude > Config.Fov.AimAssist.Size then
                AimAssistTarget = nil
                return
            end
        end
    end

    local char = AimAssistTarget.Character
    if not char then return end
    local airshot = IsInAir(AimAssistTarget)

    local hitPartName = Config.AimAssist.HitPart
    if airshot and Config.AimAssist.Use_AirShotHitPart then
        hitPartName = Config.AimAssist.AirShotHitPart
    end

    local targetPart
    if Config.AimAssist.NearestCursorHitpart then
        targetPart = GetNearestPoint(char, UserInputService:GetMouseLocation())
    else
        targetPart = GetHitPart(char, hitPartName)
    end
    if not targetPart then return end

    local prediction = Config.AimAssist.Prediction
    local smoothVal = Config.AimAssist.SmoothValue
    if airshot then smoothVal = Config.AimAssist.AirShot_SmoothValue end

    -- Gun-specific smoothness
    local gunName = tool and tool.Name or ""
    local gunOvr = GetGunOverrides(gunName, 0, airshot)
    if gunOvr and Config.GunFov.Smoothness then
        smoothVal = gunOvr.Smoothness
    end
    if gunOvr and Config.GunFov.Prediction then
        prediction = gunOvr.Prediction
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local resolverOffset = ResolvePlayer(AimAssistTarget)
    local predictedPos = targetPart.Position
    if Config.AimAssist.Predict then
        predictedPos = predictedPos + (hrp.Velocity * prediction) + resolverOffset
    end

    -- Frame Skip
    if State.FrameSkipEnabled and Config.AimAssist.FrameSkip.Enabled then
        return
    end

    -- Smooth aim
    if Config.AimAssist.Smooth then
        local goalCF = CFrame.new(Camera.CFrame.Position, predictedPos)
        local easeStyle1 = easingMap[Config.AimAssist.EasingStyle.First] or Enum.EasingStyle.Linear
        Camera.CFrame = Camera.CFrame:Lerp(goalCF, smoothVal)
    else
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
    end
end)

-- ═══════════════════════════════════════════
-- TRIGGERBOT
-- ═══════════════════════════════════════════
spawn(function()
    while true do
        if State.TriggerBotEnabled and not State.PanicActive then
            local mousePos = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            rp.FilterDescendantsInstances = {LocalPlayer.Character}
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
            if result and result.Instance then
                local hit = result.Instance
                local model = hit:FindFirstAncestorOfClass("Model")
                if model then
                    local plr = Players:GetPlayerFromCharacter(model)
                    if plr and ValidTarget(plr) then
                        mouse1click()
                        wait(Config.TriggerBot.Delay)
                    end
                end
            end
        end
        wait(0.01)
    end
end)

-- ═══════════════════════════════════════════
-- INPUT HANDLING (Keybinds)
-- ═══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- Panic Key
    if Config.Panic.Enabled and input.KeyCode == Enum.KeyCode[Config.Panic.Key] then
        State.PanicActive = not State.PanicActive
        Notify("Shhhh", State.PanicActive and "PANIC: OFF" or "PANIC: ON")
    end

    -- Silent Aim Toggle
    if Config.Silent.Enable_KeyBind and input.KeyCode == Enum.KeyCode[Config.Silent.KeyBind:upper()] then
        State.SilentEnabled = not State.SilentEnabled
        if Config.Silent.Notification then
            Notify("Silent Aim", State.SilentEnabled and "Enabled" or "Disabled")
        end
    end

    -- Aim Assist Toggle
    if Config.AimAssist.Mode == 'KeyBind' then
        if input.KeyCode == Enum.KeyCode[Config.AimAssist.KeyBind:upper()] then
            if Config.AimAssist.Hold_KeyBind then
                AimAssistActive = true
                AimAssistTarget = GetAimAssistTarget()
            else
                AimAssistActive = not AimAssistActive
                if AimAssistActive then
                    AimAssistTarget = GetAimAssistTarget()
                else
                    AimAssistTarget = nil
                end
            end
        end
    elseif Config.AimAssist.Mode == 'Mouse' then
        if input.UserInputType == Config.AimAssist.MouseBind then
            AimAssistActive = true
            AimAssistTarget = GetAimAssistTarget()
        end
    elseif Config.AimAssist.Mode == 'Auto' then
        AimAssistActive = true
    end

    -- TriggerBot Toggle
    if Config.TriggerBot.Use_KeyBind then
        if Config.TriggerBot.Mode == "KeyBind" and input.KeyCode == Config.TriggerBot.KeyBind then
            State.TriggerBotEnabled = not State.TriggerBotEnabled
            if Config.TriggerBot.Notification then
                Notify("TriggerBot", State.TriggerBotEnabled and "Enabled" or "Disabled")
            end
        end
    end

    -- Frame Skip Toggle
    if Config.AimAssist.FrameSkip.UseKeyBind and input.KeyCode == Enum.KeyCode[Config.AimAssist.FrameSkip.ToggleKeyBind:upper()] then
        State.FrameSkipEnabled = not State.FrameSkipEnabled
        if Config.AimAssist.FrameSkip.Notification then
            Notify("FrameSkip", State.FrameSkipEnabled and "Enabled" or "Disabled")
        end
    end

    -- ESP Toggle
    if Config.Esp.Use_KeyBind and input.KeyCode == Config.Esp.KeyBind then
        Config.Esp.Enabled = not Config.Esp.Enabled
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    -- Aim Assist Hold Release
    if Config.AimAssist.Mode == 'KeyBind' and Config.AimAssist.Hold_KeyBind then
        if input.KeyCode == Enum.KeyCode[Config.AimAssist.KeyBind:upper()] then
            AimAssistActive = false
            AimAssistTarget = nil
        end
    elseif Config.AimAssist.Mode == 'Mouse' then
        if input.UserInputType == Config.AimAssist.MouseBind then
            AimAssistActive = false
            AimAssistTarget = nil
        end
    end

    -- TriggerBot Hold Release
    if Config.TriggerBot.Mode == "Hold" and input.KeyCode == Config.TriggerBot.KeyBind then
        State.TriggerBotEnabled = false
    end
end)

Notify("Shhhh V2.2", "Targeting module loaded!", 3)
