--[[
    SHHHH V2.2 - Full Feature Recreation
    Core Module: Configuration, Services, Utilities
]]

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════
-- CONFIGURATION (mirrors Shhhh settings)
-- ═══════════════════════════════════════════
getgenv().Shhhh = getgenv().Shhhh or {}
local Config = getgenv().Shhhh

Config.Options = Config.Options or {
    Key = 'keyhere',
    Version = 'V2.2',
    Intro = false,
    UnlockFps = { Enabled = true, FpsCap = 999 },
    CustomTextures = {
        Enabled = false,
        Texture = 'ForceField',
        Color = Color3.fromRGB(255, 198, 254),
        Fog = { Enabled = false, Start = 0, End = 1000, Color = BrickColor.new("Light reddish violet") },
    },
}

Config.Panic = Config.Panic or { Enabled = false, Key = 'K' }

Config.Universal = Config.Universal or {
    Enabled = false, TeamCheck = true, VisibleCheck = true,
    Use_HitChance = true, Visible = true, Predict = false,
    Prediction = 0.115, Size = 150, HitChance = 100,
    HitPart = 'Random',
}

Config.Silent = Config.Silent or {
    Enabled = true, Mode = 'FOV', Enable_KeyBind = true, KeyBind = 'p',
    Notification = true, Predict = true, Prediction = 0.135,
    HitChance = 300, AirShot_HitChance = 300,
    HitParts = 'HumanoidRootPart', NearestCursorHitpart = true,
    HitPart_Mode = 'Nearest Point',
}

Config.AimAssist = Config.AimAssist or {
    Enabled = true, Hold_KeyBind = false,
    Mode = 'KeyBind', KeyBind = 'q',
    MouseBind = Enum.UserInputType.MouseButton2,
    ThirdPerson = true, FirstPerson = true,
    Predict = true, Prediction = 0.115,
    Smooth = true, SmoothValue = 0.014,
    AirShot_SmoothValue = 0.050,
    HitPart = 'HumanoidRootPart',
    Use_AirShotHitPart = false, AirShotHitPart = 'Head',
    NearestCursorHitpart = true,
    UnLockWhenTyping = false, UnlockWhenReloading = false,
    UnlockWhenNotHoldingGun = false,
    EasingStyle = { First = 'Elastic', Second = 'Sine' },
    FrameSkip = { Enabled = false, UseKeyBind = true, Notification = false, ToggleKeyBind = 'g' },
}

Config.Shake = Config.Shake or {
    Enabled = false, X = 5, Y = 5, Z = 5,
    AirShot = false, Airshot___X = 5, Airshot___Y = 5, Airshot___Z = 5,
}

Config.Fov = Config.Fov or {
    Silent = {
        Visible = true, Filled = false, Size = 35, Transparency = 0.14,
        Thickness = 1, Shape = 'Circle', Set = {0, 0},
        Color = Color3.fromRGB(0, 0, 0),
    },
    AimAssist = {
        Visible = false, Use_Fov = false, Disable_Outside_Fov = false,
        Filled = false, Size = 50, Transparency = 1, Thickness = 1,
        Shape = 'Circle', Set = {0, 0},
        Color = Color3.fromRGB(0, 0, 0),
    },
}

Config.Checks = Config.Checks or {
    Wall = true, Knocked = true, Grabbed = true,
    Airshot = true, Crew_Check = false, NoGroundShots = true,
}

Config.Resolver = Config.Resolver or { Enabled = true, Anti_Aim_Viewer = true }

Config.Misc = Config.Misc or {
    Auto360 = { Enabled = false, SpinKeybind = 'Q', SpinSpeed = 1 },
    CloseGame = { Enabled = false, CloseGameKeybind = 'M', UseDelay = true, Delay = 1 },
    FakeSpike = { Enabled = false, FakeSpikeKeybind = 'K', SpikeDuration = 1 },
    AutoReset = { Enabled = false, AutoResetKeybind = 'L', UseDelay = true, Delay = 1 },
    Settings = { AutoLowGFX = false, MuteBoomBox = false, AutoReload = false },
    CheckSnipers = {
        Enabled = true, Notification = true, CloseGame = false,
        Usernames = { 'imlovinit212','username2','username3','username4','username5','username6' },
    },
    TrashTalk = {
        Enabled = false, KeyBind = "t", Method = "2", Delay = 0.3,
        Messages = { 'message','message','message','message','message','message' },
    },
}

Config.TriggerBot = Config.TriggerBot or {
    Enabled = false, Notification = false, Use_KeyBind = true,
    Mode = "KeyBind", KeyBind = Enum.KeyCode.M, Delay = 0.1,
}

Config.Rejoin = Config.Rejoin or { Enabled = false, Keybind = 'Q' }

Config.Noclip_Macro = Config.Noclip_Macro or {
    Enabled = false, KeyBind = Enum.KeyCode.H,
    First_Gun = '[Shotgun]', Second_Gun = '[TacticalShotgun]',
}

Config.Animation = Config.Animation or {
    Lay = false, LayKey = Enum.KeyCode.T,
    Greet = false, GreetKey = Enum.KeyCode.G,
    Speed = false, SpeedKey = Enum.KeyCode.N,
    Sturdy = false, SturdyKey = Enum.KeyCode.H,
    Griddy = false, GriddyKey = Enum.KeyCode.G,
}

Config.GunSorting = Config.GunSorting or {
    Enabled = true, SortFood = true, Keybind = 'Z',
    FirstSlot = '[Double-Barrel SG]', SecondSlot = '[Revolver]',
    ThirdSlot = '[TacticalShotgun]', FourthSlot = '[Shotgun]',
    FifthSlot = '[Katana]',
}

Config.Mod = Config.Mod or {
    Enabled = false, Mode = 'Key', Key = 'L',
    Message = 'lol...', Kick_if_Mod_Joined = true,
}

Config.Macro = Config.Macro or {
    Enabled = true, Hold_Key = false,
    KeyBind = Enum.KeyCode.X, AntiMacroFling = true,
    BypassMacroAbuse = true, Mode = 'Normal',
}

Config.Memory = Config.Memory or { Enabled = false, Start = 971, End = 984, Speed = 1 }

Config.GunFov = Config.GunFov or {
    Enabled = false, Fov = true, Prediction = true,
    HitChance = true, Smoothness = true,
    Default = true, AirShot = false, Range = false,
    Close = 15, Mid = 30, Far = math.huge,
    DoubleBarrel = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    Revolver = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    Rifle = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    Shotgun = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    Smg = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    TacticalShotgun = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    Silencer = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    AK47 = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
    AR = {
        Fov=25, Prediction=0.135, HitChance=300, Smoothness=0.014,
        AirShot_Fov=15, AirShot_Prediction=0.135, AirShot_HitChance=300, AirShot_Smoothness=0.014,
        Close_Fov=15, Close_Prediction=0.135, Close_HitChance=300, Close_Smoothness=0.014,
        Mid_Fov=7, Mid_Prediction=0.135, Mid_HitChance=300, Mid_Smoothness=0.014,
        Far_Fov=4, Far_Prediction=0.135, Far_HitChance=300, Far_Smoothness=0.014,
    },
}

Config.AutoPrediction = Config.AutoPrediction or {
    Enabled = false,
    p20_30=0.1, p30_40=0.11, p40_50=0.119, p50_60=0.123,
    p60_70=0.125, p70_80=0.129, p80_90=0.1295, p90_100=0.13,
    p100_110=0.1315, p110_120=0.1344, p120_130=0.1411,
    p130_140=0.15, p140_150=0.1555, p150_160=0.1574,
    p160_170=0.1663, p170_180=0.1672, p180_190=0.1848, p190_200=0.1865,
}

Config.Chat = Config.Chat or {
    Enabled = false,
    HitChance = '$hc', Silent_Prediction = '$pred',
    Fov_Size = '$fov', AimAssist_Fov_Size = '!fov',
    AimAssist_Smoothness = '!smooth', AimAssist_Prediction = '!pred',
    Revolver_Fov = 'rfov', DoubleBarrel_Fov = 'dfov',
    Shotgun_Fov = 'sfov', TacticalShotgun_Fov = 'tfov',
    Show_Fov_Silent = '$SFS', Show_Fov_AimAssist = '$SFA',
}

Config.Esp = Config.Esp or {
    Enabled = false, Use_KeyBind = true, KeyBind = Enum.KeyCode.L,
    AutoStep = true,
    CharacterSize = Vector3.new(4, 5.75, 1.5),
    CharacterOffset = CFrame.new(0, -0.25, 0),
    UseBoundingBox = false,
    PriorityColor = Color3.new(1, 0.25, 0.25),
    BoxEnabled = true, BoxCorners = true, BoxDynamic = false,
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
        nametag  = { enabled = true, position = 'top', order = 1 },
        name     = { enabled = true, position = 'top', order = 2 },
        health   = { enabled = true, position = 'left', order = 1, bar = 'health' },
        armor    = { enabled = true, position = 'left', order = 2, bar = 'armor' },
        tool     = { enabled = true, position = 'bottom', ammo = true, suffix = '', prefix = '', order = 1 },
        distance = { enabled = true, position = 'bottom', suffix = 'm', order = 2 },
    },
    BarLayout = {
        health = { enabled = true, position = 'left', order = 1, color_empty = Color3.fromRGB(176, 84, 84), color_full = Color3.fromRGB(140, 250, 140) },
        armor  = { enabled = true, position = 'left', order = 2, color_empty = Color3.fromRGB(58, 58, 97), color_full = Color3.fromRGB(72, 72, 250) },
    },
}

-- ═══════════════════════════════════════════
-- INTERNAL STATE
-- ═══════════════════════════════════════════
local State = {
    PanicActive = false,
    SilentEnabled = Config.Silent.Enabled,
    AimAssistEnabled = Config.AimAssist.Enabled,
    AimAssistLocked = false,
    AimAssistTarget = nil,
    TriggerBotEnabled = Config.TriggerBot.Enabled,
    FrameSkipEnabled = false,
    EspEnabled = Config.Esp.Enabled,
    CurrentTarget = nil,
    Ping = 0,
    IsAirshot = false,
}

-- ═══════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Shhhh",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

local function GetPing()
    local ping = 0
    pcall(function()
        ping = LocalPlayer:GetNetworkPing() * 1000
    end)
    State.Ping = ping
    return ping
end

local function IsAlive(plr)
    local char = plr and plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return true
end

local function IsKnocked(plr)
    if not Config.Checks.Knocked then return false end
    local char = plr and plr.Character
    if not char then return false end
    local ko = char:FindFirstChild("BodyEffects")
    if ko then
        local knocked = ko:FindFirstChild("K.O")
        if knocked and knocked:IsA("BoolValue") and knocked.Value == true then
            return true
        end
    end
    return false
end

local function IsGrabbed(plr)
    if not Config.Checks.Grabbed then return false end
    local char = plr and plr.Character
    if not char then return false end
    local gState = char:FindFirstChild("YOURGRABBEDLOL")
    if gState then return true end
    local bEffects = char:FindFirstChild("BodyEffects")
    if bEffects then
        local grabbed = bEffects:FindFirstChild("Grabbed")
        if grabbed and grabbed:IsA("BoolValue") and grabbed.Value == true then
            return true
        end
    end
    return false
end

local function IsOnGround(plr)
    local char = plr and plr.Character
    if not char then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return true end
    return hum.FloorMaterial ~= Enum.Material.Air
end

local function IsInAir(plr)
    local char = plr and plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.FloorMaterial == Enum.Material.Air
end

local function WallCheck(origin, target)
    if not Config.Checks.Wall then return true end
    local direction = (target - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local ignoreList = {LocalPlayer.Character, Camera}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            table.insert(ignoreList, plr.Character)
        end
    end
    rayParams.FilterDescendantsInstances = ignoreList
    local result = Workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

local function TeamCheck(plr)
    if not Config.Universal.TeamCheck then return true end
    if not LocalPlayer.Team or not plr.Team then return true end
    return LocalPlayer.Team ~= plr.Team
end

local function CrewCheck(plr)
    if not Config.Checks.Crew_Check then return true end
    return true -- Da Hood crew check placeholder
end

local function GetHitPart(char, partName)
    if partName == 'Random' then
        local parts = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'}
        partName = parts[math.random(1, #parts)]
    end
    return char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
end

local function HitChanceCalc(chance)
    return math.random(1, 100) <= math.clamp(chance, 0, 100)
end

local function GetClosestPlayerToCursor(fovSize)
    local closest = nil
    local shortestDist = fovSize or math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) and not IsKnocked(plr) and not IsGrabbed(plr) and TeamCheck(plr) and CrewCheck(plr) then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        if Config.Checks.Wall then
                            local camPos = Camera.CFrame.Position
                            if WallCheck(camPos, hrp.Position) then
                                shortestDist = dist
                                closest = plr
                            end
                        else
                            shortestDist = dist
                            closest = plr
                        end
                    end
                end
            end
        end
    end

    return closest
end

local function GetNearestPoint(char, mousePos)
    local closestPart = nil
    local closestDist = math.huge
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                if d < closestDist then
                    closestDist = d
                    closestPart = part
                end
            end
        end
    end
    return closestPart
end

local function GetCurrentGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool
end

local function GetGunName(tool)
    if not tool then return "" end
    return tool.Name or ""
end

local function MapGunToConfig(gunName)
    local map = {
        ["[Double-Barrel SG]"] = "DoubleBarrel",
        ["Double-Barrel SG"] = "DoubleBarrel",
        ["[Revolver]"] = "Revolver", ["Revolver"] = "Revolver",
        ["[Rifle]"] = "Rifle", ["Rifle"] = "Rifle",
        ["[Shotgun]"] = "Shotgun", ["Shotgun"] = "Shotgun",
        ["[SMG]"] = "Smg", ["SMG"] = "Smg",
        ["[TacticalShotgun]"] = "TacticalShotgun", ["TacticalShotgun"] = "TacticalShotgun",
        ["[Silencer]"] = "Silencer", ["Silencer"] = "Silencer",
        ["[AK47]"] = "AK47", ["AK47"] = "AK47",
        ["[AR]"] = "AR", ["AR"] = "AR",
    }
    return map[gunName]
end

local function GetGunSettings(gunName, targetDist, isAirshot)
    if not Config.GunFov.Enabled then return nil end
    local mapped = MapGunToConfig(gunName)
    if not mapped then return nil end
    local gunCfg = Config.GunFov[mapped]
    if not gunCfg then return nil end

    local prefix = ""
    if Config.GunFov.AirShot and isAirshot then
        prefix = "AirShot_"
    elseif Config.GunFov.Range then
        if targetDist <= Config.GunFov.Close then
            prefix = "Close_"
        elseif targetDist <= Config.GunFov.Mid then
            prefix = "Mid_"
        elseif targetDist <= Config.GunFov.Far then
            prefix = "Far_"
        end
    end

    return {
        Fov = gunCfg[prefix .. "Fov"] or gunCfg["Fov"],
        Prediction = gunCfg[prefix .. "Prediction"] or gunCfg["Prediction"],
        HitChance = gunCfg[prefix .. "HitChance"] or gunCfg["HitChance"],
        Smoothness = gunCfg[prefix .. "Smoothness"] or gunCfg["Smoothness"],
    }
end

-- Return shared references
return {
    Config = Config,
    State = State,
    Services = {
        Players = Players, RunService = RunService,
        UserInputService = UserInputService, TweenService = TweenService,
        Camera = Camera, LocalPlayer = LocalPlayer, Mouse = Mouse,
        Workspace = Workspace, StarterGui = StarterGui,
    },
    Util = {
        Notify = Notify, GetPing = GetPing, IsAlive = IsAlive,
        IsKnocked = IsKnocked, IsGrabbed = IsGrabbed,
        IsOnGround = IsOnGround, IsInAir = IsInAir,
        WallCheck = WallCheck, TeamCheck = TeamCheck,
        CrewCheck = CrewCheck, GetHitPart = GetHitPart,
        HitChanceCalc = HitChanceCalc,
        GetClosestPlayerToCursor = GetClosestPlayerToCursor,
        GetNearestPoint = GetNearestPoint,
        GetCurrentGun = GetCurrentGun, GetGunName = GetGunName,
        MapGunToConfig = MapGunToConfig, GetGunSettings = GetGunSettings,
    },
}
