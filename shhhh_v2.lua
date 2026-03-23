--[[
    SHHHH V2.2 - FULL COMBINED SCRIPT
    ONE FILE - ALL FEATURES
    Silent Aim, Aim Assist, TriggerBot, ESP, Misc, Resolver, Auto-Prediction
]]

-- ═══════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats             = game:GetService("Stats")

local Camera      = Workspace.CurrentCamera
local LP          = Players.LocalPlayer

-- ═══════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════
local Config = {
    Panic = { Enabled = false, Key = 'K' },
    Universal = {
        Enabled = false, TeamCheck = true, VisibleCheck = true,
        Predict = false, Prediction = 0.115, Size = 150,
        HitChance = 100, HitPart = 'Random',
    },
    Silent = {
        Enabled = true, Mode = 'FOV',
        Enable_KeyBind = true, KeyBind = 'p',
        Notification = true, Predict = true, Prediction = 0.135,
        HitChance = 300, AirShot_HitChance = 300,
        HitParts = 'HumanoidRootPart',
        NearestCursorHitpart = true, HitPart_Mode = 'Nearest Point',
    },
    AimAssist = {
        Enabled = true, Hold_KeyBind = false,
        Mode = 'KeyBind', KeyBind = 'q',
        MouseBind = Enum.UserInputType.MouseButton2,
        ThirdPerson = true, FirstPerson = true,
        Predict = true, Prediction = 0.115,
        Smooth = true, SmoothValue = 0.014, AirShot_SmoothValue = 0.050,
        HitPart = 'HumanoidRootPart',
        Use_AirShotHitPart = false, AirShotHitPart = 'Head',
        NearestCursorHitpart = true,
        UnLockWhenTyping = false, UnlockWhenReloading = false,
        UnlockWhenNotHoldingGun = false,
        EasingStyle = { First = 'Elastic', Second = 'Sine' },
        FrameSkip = { Enabled = false, UseKeyBind = true, Notification = false, ToggleKeyBind = 'g' },
    },
    Shake = { Enabled = false, X=5, Y=5, Z=5, AirShot=false, Airshot___X=5, Airshot___Y=5, Airshot___Z=5 },
    Fov = {
        Silent = { Visible=true, Filled=false, Size=35, Transparency=0.14, Thickness=1, Color=Color3.fromRGB(255,0,0), Set={0,0} },
        AimAssist = { Visible=false, Use_Fov=false, Disable_Outside_Fov=false, Filled=false, Size=50, Transparency=1, Thickness=1, Color=Color3.fromRGB(255,255,255), Set={0,0} },
    },
    Checks = { Wall=true, Knocked=true, Grabbed=true, Airshot=true, Crew_Check=false, NoGroundShots=true },
    Resolver = { Enabled=true, Anti_Aim_Viewer=true },
    Esp = {
        Enabled = true,  -- SET TRUE BY DEFAULT SO IT WORKS IMMEDIATELY
        Use_KeyBind = true, KeyBind = Enum.KeyCode.L,
        BoxEnabled = true, BoxCorners = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        SkeletonEnabled = true, SkeletonColor = Color3.fromRGB(255, 255, 255), SkeletonMaxDistance = 300,
        ChamsEnabled = true,
        ChamsInnerColor = Color3.fromRGB(102, 60, 153), ChamsOuterColor = Color3.fromRGB(0,0,0),
        ChamsInnerTransparency = 0.3, ChamsOuterTransparency = 0,
        TextEnabled = true, TextColor = Color3.fromRGB(255, 255, 255),
        BarLayout = {
            health = { enabled=true, color_empty=Color3.fromRGB(176,84,84),  color_full=Color3.fromRGB(140,250,140) },
            armor  = { enabled=true, color_empty=Color3.fromRGB(58,58,97),   color_full=Color3.fromRGB(72,72,250)  },
        },
    },
    TriggerBot = { Enabled=false, Notification=false, Use_KeyBind=true, Mode="KeyBind", KeyBind=Enum.KeyCode.M, Delay=0.1 },
    Rejoin     = { Enabled=false, Keybind='Q' },
    Misc = {
        Auto360   = { Enabled=false, SpinKeybind='Q', SpinSpeed=1 },
        CloseGame = { Enabled=false, CloseGameKeybind='M', UseDelay=true, Delay=1 },
        FakeSpike = { Enabled=false, FakeSpikeKeybind='K', SpikeDuration=1 },
        AutoReset = { Enabled=false, AutoResetKeybind='L', UseDelay=true, Delay=1 },
        Settings  = { AutoLowGFX=false, MuteBoomBox=false, AutoReload=false },
        CheckSnipers = { Enabled=true, Notification=true, CloseGame=false,
            Usernames={'imlovinit212','username2','username3'} },
        TrashTalk = { Enabled=false, KeyBind="t", Method="2", Delay=0.3,
            Messages={'message','message','message'} },
    },
    Animation = {
        Lay=false, LayKey=Enum.KeyCode.T, Greet=false, GreetKey=Enum.KeyCode.G,
        Speed=false, SpeedKey=Enum.KeyCode.N, Sturdy=false, SturdyKey=Enum.KeyCode.H,
        Griddy=false, GriddyKey=Enum.KeyCode.G,
    },
    GunSorting = {
        Enabled=true, SortFood=true, Keybind='Z',
        FirstSlot='[Double-Barrel SG]', SecondSlot='[Revolver]',
        ThirdSlot='[TacticalShotgun]', FourthSlot='[Shotgun]', FifthSlot='[Katana]',
    },
    Macro = { Enabled=true, Hold_Key=false, KeyBind=Enum.KeyCode.X, BypassMacroAbuse=true, Mode='Normal' },
    Noclip_Macro = { Enabled=false, KeyBind=Enum.KeyCode.H },
    Memory = { Enabled=false, Start=971, End=984, Speed=1 },
    AutoPrediction = {
        Enabled=false,
        p20_30=0.1, p30_40=0.11, p40_50=0.119, p50_60=0.123, p60_70=0.125,
        p70_80=0.129, p80_90=0.1295, p90_100=0.13, p100_110=0.1315, p110_120=0.1344,
        p120_130=0.1411, p130_140=0.15, p140_150=0.1555, p150_160=0.1574,
        p160_170=0.1663, p170_180=0.1672, p180_190=0.1848, p190_200=0.1865,
    },
    Chat = {
        Enabled=false, HitChance='$hc', Silent_Prediction='$pred', Fov_Size='$fov',
        AimAssist_Fov_Size='!fov', AimAssist_Smoothness='!smooth', AimAssist_Prediction='!pred',
        Show_Fov_Silent='$SFS', Show_Fov_AimAssist='$SFA',
    },
    GunFov = {
        Enabled=false, Fov=true, Prediction=true, HitChance=true, Smoothness=true,
        Default=true, AirShot=false, Range=false, Close=15, Mid=30, Far=math.huge,
        DoubleBarrel={Fov=25,Prediction=0.135,HitChance=300,Smoothness=0.014,AirShot_Fov=15,AirShot_Prediction=0.135,AirShot_HitChance=300,AirShot_Smoothness=0.014,Close_Fov=15,Close_Prediction=0.135,Close_HitChance=300,Close_Smoothness=0.014,Mid_Fov=7,Mid_Prediction=0.135,Mid_HitChance=300,Mid_Smoothness=0.014,Far_Fov=4,Far_Prediction=0.135,Far_HitChance=300,Far_Smoothness=0.014},
        Revolver={Fov=25,Prediction=0.135,HitChance=300,Smoothness=0.014,AirShot_Fov=15,AirShot_Prediction=0.135,AirShot_HitChance=300,AirShot_Smoothness=0.014,Close_Fov=15,Close_Prediction=0.135,Close_HitChance=300,Close_Smoothness=0.014,Mid_Fov=7,Mid_Prediction=0.135,Mid_HitChance=300,Mid_Smoothness=0.014,Far_Fov=4,Far_Prediction=0.135,Far_HitChance=300,Far_Smoothness=0.014},
        Shotgun={Fov=25,Prediction=0.135,HitChance=300,Smoothness=0.014,AirShot_Fov=15,AirShot_Prediction=0.135,AirShot_HitChance=300,AirShot_Smoothness=0.014,Close_Fov=15,Close_Prediction=0.135,Close_HitChance=300,Close_Smoothness=0.014,Mid_Fov=7,Mid_Prediction=0.135,Mid_HitChance=300,Mid_Smoothness=0.014,Far_Fov=4,Far_Prediction=0.135,Far_HitChance=300,Far_Smoothness=0.014},
        TacticalShotgun={Fov=25,Prediction=0.135,HitChance=300,Smoothness=0.014,AirShot_Fov=15,AirShot_Prediction=0.135,AirShot_HitChance=300,AirShot_Smoothness=0.014,Close_Fov=15,Close_Prediction=0.135,Close_HitChance=300,Close_Smoothness=0.014,Mid_Fov=7,Mid_Prediction=0.135,Mid_HitChance=300,Mid_Smoothness=0.014,Far_Fov=4,Far_Prediction=0.135,Far_HitChance=300,Far_Smoothness=0.014},
        AK47={Fov=25,Prediction=0.135,HitChance=300,Smoothness=0.014,AirShot_Fov=15,AirShot_Prediction=0.135,AirShot_HitChance=300,AirShot_Smoothness=0.014,Close_Fov=15,Close_Prediction=0.135,Close_HitChance=300,Close_Smoothness=0.014,Mid_Fov=7,Mid_Prediction=0.135,Mid_HitChance=300,Mid_Smoothness=0.014,Far_Fov=4,Far_Prediction=0.135,Far_HitChance=300,Far_Smoothness=0.014},
        AR={Fov=25,Prediction=0.135,HitChance=300,Smoothness=0.014,AirShot_Fov=15,AirShot_Prediction=0.135,AirShot_HitChance=300,AirShot_Smoothness=0.014,Close_Fov=15,Close_Prediction=0.135,Close_HitChance=300,Close_Smoothness=0.014,Mid_Fov=7,Mid_Prediction=0.135,Mid_HitChance=300,Mid_Smoothness=0.014,Far_Fov=4,Far_Prediction=0.135,Far_HitChance=300,Far_Smoothness=0.014},
    },
    Mod = { Enabled=false, Mode='Key', Key='L', Message='lol...', Kick_if_Mod_Joined=true },
}

-- ═══════════════════════════════════
-- STATE
-- ═══════════════════════════════════
local State = {
    Panic        = false,
    SilentOn     = Config.Silent.Enabled,
    AimOn        = false,
    AimTarget    = nil,
    TriggerOn    = Config.TriggerBot.Enabled,
    FrameSkip    = false,
    Spinning     = false,
    NoclipOn     = false,
    Ping         = 0,
}

-- ═══════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification",{ Title=title or "Shhhh", Text=text or "", Duration=dur or 3 })
    end)
end

local function GetPing()
    local p = 0
    pcall(function() p = LP:GetNetworkPing() * 1000 end)
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
    local c = plr and plr.Character; if not c then return false end
    local be = c:FindFirstChild("BodyEffects")
    if be then local ko=be:FindFirstChild("K.O"); if ko and ko.Value then return true end end
    return false
end

local function IsGrabbed(plr)
    if not Config.Checks.Grabbed then return false end
    local c = plr and plr.Character; if not c then return false end
    if c:FindFirstChild("YOURGRABBEDLOL") then return true end
    local be = c:FindFirstChild("BodyEffects")
    if be then local g=be:FindFirstChild("Grabbed"); if g and g.Value then return true end end
    return false
end

local function IsInAir(plr)
    local c = plr and plr.Character; if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.FloorMaterial == Enum.Material.Air
end

local function TeamOK(plr)
    if not Config.Universal.TeamCheck then return true end
    if not LP.Team or not plr.Team then return true end
    return LP.Team ~= plr.Team
end

local function WallOK(origin, target)
    if not Config.Checks.Wall then return true end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local ig = {LP.Character, Camera}
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(ig,p.Character) end end
    rp.FilterDescendantsInstances = ig
    return Workspace:Raycast(origin, target-origin, rp) == nil
end

local function ValidTarget(plr)
    return plr ~= LP and IsAlive(plr) and not IsKnocked(plr) and not IsGrabbed(plr) and TeamOK(plr)
end

local function GetHitPart(char, name)
    if name == 'Random' then
        local p={'Head','HumanoidRootPart','UpperTorso','LowerTorso'}
        name = p[math.random(1,#p)]
    end
    return char:FindFirstChild(name) or char:FindFirstChild("HumanoidRootPart")
end

local function NearestPart(char, mPos)
    local best, bd = nil, math.huge
    for _,p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            local sp, vis = Camera:WorldToViewportPoint(p.Position)
            if vis then
                local d = (Vector2.new(sp.X,sp.Y) - mPos).Magnitude
                if d < bd then bd=d; best=p end
            end
        end
    end
    return best
end

local GunMap = {
    ["[Double-Barrel SG]"]="DoubleBarrel",["Double-Barrel SG"]="DoubleBarrel",
    ["[Revolver]"]="Revolver",["Revolver"]="Revolver",
    ["[Shotgun]"]="Shotgun",["Shotgun"]="Shotgun",
    ["[TacticalShotgun]"]="TacticalShotgun",["TacticalShotgun"]="TacticalShotgun",
    ["[AK47]"]="AK47",["AK47"]="AK47",["[AR]"]="AR",["AR"]="AR",
}

local function GetGunOvr(gName, dist, air)
    if not Config.GunFov.Enabled then return nil end
    local key = GunMap[gName]
    if not key or not Config.GunFov[key] then return nil end
    local g = Config.GunFov[key]
    local pfx = ""
    if Config.GunFov.AirShot and air then pfx="AirShot_"
    elseif Config.GunFov.Range then
        if dist<=Config.GunFov.Close then pfx="Close_"
        elseif dist<=Config.GunFov.Mid then pfx="Mid_" else pfx="Far_" end
    end
    return { Fov=g[pfx.."Fov"] or g.Fov, Prediction=g[pfx.."Prediction"] or g.Prediction,
             HitChance=g[pfx.."HitChance"] or g.HitChance, Smoothness=g[pfx.."Smoothness"] or g.Smoothness }
end

local function AutoPred()
    if not Config.AutoPrediction.Enabled then return Config.Silent.Prediction end
    local ping = GetPing()
    local ranges={
        {20,30,"p20_30"},{30,40,"p30_40"},{40,50,"p40_50"},{50,60,"p50_60"},
        {60,70,"p60_70"},{70,80,"p70_80"},{80,90,"p80_90"},{90,100,"p90_100"},
        {100,110,"p100_110"},{110,120,"p110_120"},{120,130,"p120_130"},
        {130,140,"p130_140"},{140,150,"p140_150"},{150,160,"p150_160"},
        {160,170,"p160_170"},{170,180,"p170_180"},{180,190,"p180_190"},{190,200,"p190_200"},
    }
    for _,r in ipairs(ranges) do
        if ping>=r[1] and ping<r[2] then return Config.AutoPrediction[r[3]] or Config.Silent.Prediction end
    end
    return Config.Silent.Prediction
end

-- ═══════════════════════════════════
-- RESOLVER
-- ═══════════════════════════════════
local ResolverData = {}
local function Resolve(plr)
    if not Config.Resolver.Enabled then return Vector3.zero end
    local c = plr.Character; if not c then return Vector3.zero end
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return Vector3.zero end
    local id = plr.UserId
    if not ResolverData[id] then ResolverData[id]={lastPos=hrp.Position,t=tick()}; return Vector3.zero end
    local rd = ResolverData[id]; local dt = tick()-rd.t
    if dt > 0 then
        local rv = (hrp.Position-rd.lastPos)/dt
        local sv = hrp.Velocity
        local diff = rv-sv
        rd.lastPos=hrp.Position; rd.t=tick()
        if diff.Magnitude > 15 then return -diff*0.5 end
    end
    return Vector3.zero
end

-- ═══════════════════════════════════
-- FOV CIRCLES
-- ═══════════════════════════════════
local SilentFov, AimFov
pcall(function()
    SilentFov = Drawing.new("Circle")
    SilentFov.NumSides  = 64
    SilentFov.Radius    = Config.Fov.Silent.Size
    SilentFov.Color     = Config.Fov.Silent.Color
    SilentFov.Thickness = Config.Fov.Silent.Thickness
    SilentFov.Filled    = Config.Fov.Silent.Filled
    SilentFov.Transparency = 1 - Config.Fov.Silent.Transparency
    SilentFov.Visible   = Config.Fov.Silent.Visible

    AimFov = Drawing.new("Circle")
    AimFov.NumSides    = 64
    AimFov.Radius      = Config.Fov.AimAssist.Size
    AimFov.Color       = Config.Fov.AimAssist.Color
    AimFov.Thickness   = Config.Fov.AimAssist.Thickness
    AimFov.Filled      = Config.Fov.AimAssist.Filled
    AimFov.Transparency = 1 - Config.Fov.AimAssist.Transparency
    AimFov.Visible     = Config.Fov.AimAssist.Visible
end)

-- ═══════════════════════════════════
-- SILENT AIM (Namecall Hook)
-- ═══════════════════════════════════
local function GetSilentTarget()
    if not State.SilentOn or State.Panic then return nil end
    local mPos = UserInputService:GetMouseLocation()
    local closest, cDist = nil, Config.Fov.Silent.Size
    for _,plr in ipairs(Players:GetPlayers()) do
        if ValidTarget(plr) then
            local char = plr.Character
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local air = IsInAir(plr)
                local part
                if Config.Silent.NearestCursorHitpart then
                    part = NearestPart(char, mPos)
                else
                    part = GetHitPart(char, Config.Silent.HitParts)
                end
                if part then
                    local sp, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = (Vector2.new(sp.X,sp.Y)-mPos).Magnitude
                        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        local dist3d = myHRP and (hrp.Position-myHRP.Position).Magnitude or 0
                        local ovr = GetGunOvr(LP.Character and LP.Character:FindFirstChildOfClass("Tool") and LP.Character:FindFirstChildOfClass("Tool").Name or "", dist3d, air)
                        local fov = (ovr and Config.GunFov.Fov and ovr.Fov) or Config.Fov.Silent.Size
                        if d < fov and d < cDist then
                            if not Config.Checks.Wall or WallOK(Camera.CFrame.Position, part.Position) then
                                cDist = d
                                closest = {Player=plr, Part=part, Air=air, Ovr=ovr, Dist=dist3d}
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local oldNC
oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if (method=="FindPartOnRayWithIgnoreList" or method=="FindPartOnRay") and State.SilentOn and not State.Panic then
        local t = GetSilentTarget()
        if t then
            local pred = AutoPred()
            if t.Ovr and Config.GunFov.Prediction then pred = t.Ovr.Prediction end
            local hc = t.Air and Config.Silent.AirShot_HitChance or Config.Silent.HitChance
            if t.Ovr and Config.GunFov.HitChance then hc = t.Ovr.HitChance end
            if math.random(1,300) <= hc then
                local hrp = t.Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pPos = t.Part.Position + hrp.Velocity * pred + Resolve(t.Player)
                    if Config.Shake.Enabled then
                        pPos = pPos + Vector3.new(math.random(-Config.Shake.X,Config.Shake.X)*.1,math.random(-Config.Shake.Y,Config.Shake.Y)*.1,math.random(-Config.Shake.Z,Config.Shake.Z)*.1)
                    end
                    args[1] = Ray.new(Camera.CFrame.Position, (pPos - Camera.CFrame.Position).Unit * 1000)
                end
            end
        end
    end
    return oldNC(self, unpack(args))
end))

-- ═══════════════════════════════════
-- AIM ASSIST
-- ═══════════════════════════════════
local function GetAimTarget()
    local mPos = UserInputService:GetMouseLocation()
    local closest, cDist = nil, Config.Fov.AimAssist.Use_Fov and Config.Fov.AimAssist.Size or math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if ValidTarget(plr) then
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, vis = Camera:WorldToViewportPoint(hrp.Position)
                if vis then
                    local d = (Vector2.new(sp.X,sp.Y)-mPos).Magnitude
                    if d < cDist and (not Config.Checks.Wall or WallOK(Camera.CFrame.Position,hrp.Position)) then
                        cDist=d; closest=plr
                    end
                end
            end
        end
    end
    return closest
end

local EaseMap = {Linear=Enum.EasingStyle.Linear,Sine=Enum.EasingStyle.Sine,Back=Enum.EasingStyle.Back,
    Quad=Enum.EasingStyle.Quad,Quart=Enum.EasingStyle.Quart,Quint=Enum.EasingStyle.Quint,
    Bounce=Enum.EasingStyle.Bounce,Elastic=Enum.EasingStyle.Elastic,
    Exponential=Enum.EasingStyle.Exponential,Circular=Enum.EasingStyle.Circular,Cubic=Enum.EasingStyle.Cubic}

-- ═══════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════
local ESPPool = {}
local SkeletonPairs = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
}

local function MakeLine(color, thickness)
    local ok, line = pcall(function()
        local l = Drawing.new("Line")
        l.Color = color or Color3.new(1,1,1)
        l.Thickness = thickness or 1
        l.Visible = false
        return l
    end)
    return ok and line or nil
end

local function MakeText(size, color)
    local ok, t = pcall(function()
        local tx = Drawing.new("Text")
        tx.Size = size or 13
        tx.Color = color or Color3.new(1,1,1)
        tx.Center = true
        tx.Outline = true
        tx.OutlineColor = Color3.new(0,0,0)
        tx.Visible = false
        return tx
    end)
    return ok and t or nil
end

local function BuildESP(plr)
    if ESPPool[plr] then return end
    local e = {}
    -- Box (8 corner lines)
    e.corners = {}
    for i=1,8 do e.corners[i] = MakeLine(Config.Esp.BoxColor, 1.5) end
    -- Skeleton
    e.skel = {}
    for i=1,12 do e.skel[i] = MakeLine(Config.Esp.SkeletonColor, 1) end
    -- Text
    e.name   = MakeText(13, Config.Esp.TextColor)
    e.dist   = MakeText(12, Config.Esp.TextColor)
    e.tool   = MakeText(12, Config.Esp.TextColor)
    -- Health bar
    e.hpBg   = MakeLine(Config.Esp.BarLayout.health.color_empty, 3)
    e.hpFill = MakeLine(Config.Esp.BarLayout.health.color_full,  2)
    e.arBg   = MakeLine(Config.Esp.BarLayout.armor.color_empty,  3)
    e.arFill = MakeLine(Config.Esp.BarLayout.armor.color_full,   2)
    -- Chams
    pcall(function()
        e.hl = Instance.new("Highlight")
        e.hl.FillColor          = Config.Esp.ChamsInnerColor
        e.hl.OutlineColor       = Config.Esp.ChamsOuterColor
        e.hl.FillTransparency   = Config.Esp.ChamsInnerTransparency
        e.hl.OutlineTransparency= Config.Esp.ChamsOuterTransparency
        e.hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    end)
    ESPPool[plr] = e
end

local function HideESP(e)
    for _,l in ipairs(e.corners or {}) do if l then l.Visible=false end end
    for _,l in ipairs(e.skel    or {}) do if l then l.Visible=false end end
    for _,t in ipairs({e.name,e.dist,e.tool,e.hpBg,e.hpFill,e.arBg,e.arFill}) do
        if t then t.Visible=false end
    end
    if e.hl then e.hl.Parent=nil end
end

local function DestroyESP(plr)
    local e = ESPPool[plr]; if not e then return end
    pcall(function()
        for _,l in ipairs(e.corners or {}) do if l then l:Remove() end end
        for _,l in ipairs(e.skel    or {}) do if l then l:Remove() end end
        for _,t in ipairs({e.name,e.dist,e.tool,e.hpBg,e.hpFill,e.arBg,e.arFill}) do
            if t then t:Remove() end
        end
        if e.hl then e.hl:Destroy() end
    end)
    ESPPool[plr] = nil
end

-- ═══════════════════════════════════
-- MISC HELPERS
-- ═══════════════════════════════════
local AnimIds = {
    Lay="rbxassetid://5918726674", Greet="rbxassetid://5917574964",
    Speed="rbxassetid://5918644345", Sturdy="rbxassetid://12515580635",
    Griddy="rbxassetid://10714757194",
}
local function PlayAnim(name)
    local c=LP.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
    local a=Instance.new("Animation"); a.AnimationId=AnimIds[name] or ""
    local t=h:LoadAnimation(a); t:Play(); a:Destroy()
end

local function SortGuns()
    local bp = LP:FindFirstChild("Backpack"); if not bp then return end
    local slots={Config.GunSorting.FirstSlot,Config.GunSorting.SecondSlot,Config.GunSorting.ThirdSlot,Config.GunSorting.FourthSlot,Config.GunSorting.FifthSlot}
    for _,n in ipairs(slots) do
        local t=bp:FindFirstChild(n) or (LP.Character and LP.Character:FindFirstChild(n))
        if t then pcall(function() t.Parent=LP.Character; wait(0.05); t.Parent=bp end) end
    end
end

-- ═══════════════════════════════════
-- MAIN RENDER LOOP
-- ═══════════════════════════════════
RunService.RenderStepped:Connect(function()
    local center = Camera.ViewportSize / 2

    -- FOV Circles
    if SilentFov then
        SilentFov.Position  = center + Vector2.new(Config.Fov.Silent.Set[1],Config.Fov.Silent.Set[2])
        SilentFov.Radius    = Config.Fov.Silent.Size
        SilentFov.Visible   = Config.Fov.Silent.Visible and State.SilentOn and not State.Panic
    end
    if AimFov then
        AimFov.Position  = center + Vector2.new(Config.Fov.AimAssist.Set[1],Config.Fov.AimAssist.Set[2])
        AimFov.Radius    = Config.Fov.AimAssist.Size
        AimFov.Visible   = Config.Fov.AimAssist.Visible and State.AimOn and not State.Panic
    end

    -- Aim Assist
    if State.AimOn and Config.AimAssist.Enabled and not State.Panic then
        if Config.AimAssist.UnLockWhenTyping and UserInputService:GetFocusedTextBox() then
            State.AimTarget = nil
        else
            if not State.AimTarget or not IsAlive(State.AimTarget) or IsKnocked(State.AimTarget) then
                if Config.AimAssist.Mode == 'Auto' then State.AimTarget = GetAimTarget() end
            end
            if State.AimTarget then
                local char = State.AimTarget.Character
                if char then
                    local air = IsInAir(State.AimTarget)
                    local tp = Config.AimAssist.NearestCursorHitpart and NearestPart(char, UserInputService:GetMouseLocation())
                           or GetHitPart(char, air and Config.AimAssist.Use_AirShotHitPart and Config.AimAssist.AirShotHitPart or Config.AimAssist.HitPart)
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if tp and hrp then
                        local sm = air and Config.AimAssist.AirShot_SmoothValue or Config.AimAssist.SmoothValue
                        local pred = Config.AimAssist.Prediction
                        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                        local ovr = tool and GetGunOvr(tool.Name, 0, air)
                        if ovr then
                            if Config.GunFov.Smoothness then sm=ovr.Smoothness end
                            if Config.GunFov.Prediction then pred=ovr.Prediction end
                        end
                        local pPos = tp.Position
                        if Config.AimAssist.Predict then pPos = pPos + hrp.Velocity*pred + Resolve(State.AimTarget) end
                        if not State.FrameSkip then
                            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pPos), sm)
                        end
                    end
                end
            end
        end
    end

    -- ════ ESP LOOP ════
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not ESPPool[plr] then BuildESP(plr) end
        local e = ESPPool[plr]; if not e then continue end

        if not Config.Esp.Enabled or not IsAlive(plr) or not TeamOK(plr) or State.Panic then
            HideESP(e); continue
        end

        local char = plr.Character
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then HideESP(e); continue end

        local rp, onS = Camera:WorldToViewportPoint(hrp.Position)
        if not onS then HideESP(e); continue end

        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist = myHRP and (hrp.Position - myHRP.Position).Magnitude or 0

        -- Box bounds
        local head = char:FindFirstChild("Head")
        local topY, botY = rp.Y, rp.Y
        if head then
            local ht = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
            local bt = Camera:WorldToViewportPoint(hrp.Position  - Vector3.new(0,3,0))
            topY = ht.Y; botY = bt.Y
        end
        local bH = math.abs(botY - topY)
        local bW = bH * 0.55
        local bX = rp.X - bW/2
        local bY = topY

        -- ── BOX / CORNERS ──
        if Config.Esp.BoxEnabled and e.corners[1] then
            local cl = bW * 0.28
            local pts = {
                -- TL
                {Vector2.new(bX,bY),      Vector2.new(bX+cl,bY)},
                {Vector2.new(bX,bY),      Vector2.new(bX,bY+cl)},
                -- TR
                {Vector2.new(bX+bW,bY),   Vector2.new(bX+bW-cl,bY)},
                {Vector2.new(bX+bW,bY),   Vector2.new(bX+bW,bY+cl)},
                -- BL
                {Vector2.new(bX,bY+bH),   Vector2.new(bX+cl,bY+bH)},
                {Vector2.new(bX,bY+bH),   Vector2.new(bX,bY+bH-cl)},
                -- BR
                {Vector2.new(bX+bW,bY+bH),Vector2.new(bX+bW-cl,bY+bH)},
                {Vector2.new(bX+bW,bY+bH),Vector2.new(bX+bW,bY+bH-cl)},
            }
            for i,pt in ipairs(pts) do
                if e.corners[i] then
                    e.corners[i].From    = pt[1]
                    e.corners[i].To      = pt[2]
                    e.corners[i].Color   = Config.Esp.BoxColor
                    e.corners[i].Visible = true
                end
            end
        else
            for _,l in ipairs(e.corners) do if l then l.Visible=false end end
        end

        -- ── SKELETON ──
        if Config.Esp.SkeletonEnabled and dist <= Config.Esp.SkeletonMaxDistance then
            for i, pair in ipairs(SkeletonPairs) do
                local p1 = char:FindFirstChild(pair[1])
                local p2 = char:FindFirstChild(pair[2])
                if p1 and p2 and e.skel[i] then
                    local s1,v1 = Camera:WorldToViewportPoint(p1.Position)
                    local s2,v2 = Camera:WorldToViewportPoint(p2.Position)
                    if v1 and v2 then
                        e.skel[i].From=Vector2.new(s1.X,s1.Y); e.skel[i].To=Vector2.new(s2.X,s2.Y)
                        e.skel[i].Color=Config.Esp.SkeletonColor; e.skel[i].Visible=true
                    else e.skel[i].Visible=false end
                elseif e.skel[i] then e.skel[i].Visible=false end
            end
        else for _,l in ipairs(e.skel) do if l then l.Visible=false end end end

        -- ── CHAMS ──
        if Config.Esp.ChamsEnabled and e.hl then
            e.hl.FillColor=Config.Esp.ChamsInnerColor
            e.hl.OutlineColor=Config.Esp.ChamsOuterColor
            e.hl.FillTransparency=Config.Esp.ChamsInnerTransparency
            e.hl.OutlineTransparency=Config.Esp.ChamsOuterTransparency
            e.hl.Adornee=char; e.hl.Parent=char
        elseif e.hl then e.hl.Parent=nil end

        -- ── TEXT ──
        if Config.Esp.TextEnabled then
            if e.name then e.name.Text=plr.DisplayName or plr.Name; e.name.Position=Vector2.new(rp.X,bY-16); e.name.Visible=true end
            if e.dist then e.dist.Text=math.floor(dist).."m";       e.dist.Position=Vector2.new(rp.X,bY+bH+2); e.dist.Visible=true end
            local toolInst = char:FindFirstChildOfClass("Tool")
            if e.tool then
                if toolInst then e.tool.Text=toolInst.Name; e.tool.Position=Vector2.new(rp.X,bY+bH+15); e.tool.Visible=true
                else e.tool.Visible=false end
            end
        else
            for _,t in ipairs({e.name,e.dist,e.tool}) do if t then t.Visible=false end end
        end

        -- ── HEALTH BAR ──
        local hp = math.clamp(hum.Health/hum.MaxHealth,0,1)
        local barX = bX - 5
        if e.hpBg then  e.hpBg.From=Vector2.new(barX,bY); e.hpBg.To=Vector2.new(barX,bY+bH); e.hpBg.Color=Config.Esp.BarLayout.health.color_empty; e.hpBg.Visible=true end
        if e.hpFill then e.hpFill.From=Vector2.new(barX,bY+bH); e.hpFill.To=Vector2.new(barX,bY+bH-(bH*hp)); e.hpFill.Color=Config.Esp.BarLayout.health.color_full:Lerp(Config.Esp.BarLayout.health.color_empty,1-hp); e.hpFill.Visible=true end

        -- ── ARMOR BAR ──
        local armor = 0
        local be = char:FindFirstChild("BodyEffects")
        if be then local av=be:FindFirstChild("Armor"); if av then armor=av.Value end end
        local arPct = math.clamp(armor/100,0,1)
        local arX = barX - 4
        if e.arBg then  e.arBg.From=Vector2.new(arX,bY); e.arBg.To=Vector2.new(arX,bY+bH); e.arBg.Color=Config.Esp.BarLayout.armor.color_empty; e.arBg.Visible=armor>0 end
        if e.arFill then e.arFill.From=Vector2.new(arX,bY+bH); e.arFill.To=Vector2.new(arX,bY+bH-(bH*arPct)); e.arFill.Color=Config.Esp.BarLayout.armor.color_full; e.arFill.Visible=armor>0 end
    end
end)

-- ═══════════════════════════════════
-- TRIGGERBOT LOOP
-- ═══════════════════════════════════
spawn(function()
    while true do
        task.wait(0.01)
        if State.TriggerOn and not State.Panic then
            local mPos = UserInputService:GetMouseLocation()
            local ray   = Camera:ViewportPointToRay(mPos.X, mPos.Y)
            local rp    = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            rp.FilterDescendantsInstances = {LP.Character}
            local result = Workspace:Raycast(ray.Origin, ray.Direction*1000, rp)
            if result and result.Instance then
                local model = result.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local plr = Players:GetPlayerFromCharacter(model)
                    if plr and ValidTarget(plr) then
                        pcall(mouse1click)
                        task.wait(Config.TriggerBot.Delay)
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════
-- CHAT COMMANDS
-- ═══════════════════════════════════
if Config.Chat.Enabled then
    LP.Chatted:Connect(function(msg)
        local a = msg:split(" ")
        local val = tonumber(a[2])
        if a[1]==Config.Chat.HitChance and val then Config.Silent.HitChance=val; Notify("Chat","HitChance="..val)
        elseif a[1]==Config.Chat.Silent_Prediction and val then Config.Silent.Prediction=val; Notify("Chat","Pred="..val)
        elseif a[1]==Config.Chat.Fov_Size and val then Config.Fov.Silent.Size=val; Notify("Chat","Fov="..val)
        elseif a[1]==Config.Chat.AimAssist_Fov_Size and val then Config.Fov.AimAssist.Size=val; Notify("Chat","AA Fov="..val)
        elseif a[1]==Config.Chat.AimAssist_Smoothness and val then Config.AimAssist.SmoothValue=val; Notify("Chat","Smooth="..val)
        elseif a[1]==Config.Chat.AimAssist_Prediction and val then Config.AimAssist.Prediction=val; Notify("Chat","AA Pred="..val)
        elseif a[1]==Config.Chat.Show_Fov_Silent then Config.Fov.Silent.Visible=a[2]=="true"; Notify("Chat","Silent FOV="..tostring(a[2]))
        elseif a[1]==Config.Chat.Show_Fov_AimAssist then Config.Fov.AimAssist.Visible=a[2]=="true"; Notify("Chat","AA FOV="..tostring(a[2]))
        end
    end)
end

-- ═══════════════════════════════════
-- SNIPER ALERTS
-- ═══════════════════════════════════
if Config.Misc.CheckSnipers.Enabled then
    Players.PlayerAdded:Connect(function(plr)
        for _,name in ipairs(Config.Misc.CheckSnipers.Usernames) do
            if plr.Name:lower()==name:lower() or plr.DisplayName:lower()==name:lower() then
                if Config.Misc.CheckSnipers.Notification then Notify("⚠ SNIPER",plr.Name.." joined!",10) end
                if Config.Misc.CheckSnipers.CloseGame then task.wait(1); game:Shutdown() end
            end
        end
    end)
end

-- ═══════════════════════════════════
-- MISC SETTINGS
-- ═══════════════════════════════════
if Config.Misc.Settings.AutoLowGFX then
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01; Lighting.GlobalShadows=false end)
end
if Config.Misc.Settings.MuteBoomBox then
    spawn(function()
        while task.wait(1) do pcall(function()
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Sound") then v.Volume=0 end
            end
        end) end
    end)
end

-- Noclip
local noclipConn
local function ToggleNoclip()
    State.NoclipOn = not State.NoclipOn
    if State.NoclipOn then
        noclipConn = RunService.Stepped:Connect(function()
            local c=LP.Character; if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else if noclipConn then noclipConn:Disconnect() end end
end

-- Auto Reset
if Config.Misc.Settings.AutoReload then
    spawn(function()
        while task.wait(0.5) do pcall(function()
            local c=LP.Character; if not c then return end
            local t=c:FindFirstChildOfClass("Tool"); if not t then return end
            local am=t:FindFirstChild("Ammo"); if am and am.Value<=0 then t:Activate() end
        end) end
    end)
end

-- ═══════════════════════════════════
-- AUTO 360
-- ═══════════════════════════════════
spawn(function()
    while true do
        task.wait()
        if State.Spinning and Config.Misc.Auto360.Enabled then
            local c=LP.Character; if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(360*Config.Misc.Auto360.SpinSpeed), 0)
            end
        end
    end
end)

-- Memory
if Config.Memory.Enabled then
    spawn(function()
        while task.wait(0.1) do pcall(function()
            local c=LP.Character; if not c then return end
            local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
            h.WalkSpeed = math.random(Config.Memory.Start, Config.Memory.End) * Config.Memory.Speed
        end) end
    end)
end

-- Player cleanup
Players.PlayerRemoving:Connect(function(plr)
    DestroyESP(plr)
    ResolverData[plr.UserId] = nil
end)

-- ═══════════════════════════════════
-- INPUT BINDINGS
-- ═══════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local kc = input.KeyCode

    -- Panic
    if Config.Panic.Enabled and kc == Enum.KeyCode[Config.Panic.Key] then
        State.Panic = not State.Panic
        Notify("Shhhh", State.Panic and "PANIC ON" or "PANIC OFF")
    end

    -- Silent Aim
    if Config.Silent.Enable_KeyBind and kc == Enum.KeyCode[Config.Silent.KeyBind:upper()] then
        State.SilentOn = not State.SilentOn
        if Config.Silent.Notification then Notify("Silent Aim", State.SilentOn and "ON" or "OFF") end
    end

    -- Aim Assist Key
    if Config.AimAssist.Mode == 'KeyBind' then
        if kc == Enum.KeyCode[Config.AimAssist.KeyBind:upper()] then
            if Config.AimAssist.Hold_KeyBind then
                State.AimOn = true; State.AimTarget = GetAimTarget()
            else
                State.AimOn = not State.AimOn
                State.AimTarget = State.AimOn and GetAimTarget() or nil
            end
        end
    elseif Config.AimAssist.Mode == 'Mouse' then
        if input.UserInputType == Config.AimAssist.MouseBind then
            State.AimOn = true; State.AimTarget = GetAimTarget()
        end
    elseif Config.AimAssist.Mode == 'Auto' then
        State.AimOn = true
    end

    -- TriggerBot
    if Config.TriggerBot.Use_KeyBind and Config.TriggerBot.Mode=="KeyBind" and kc==Config.TriggerBot.KeyBind then
        State.TriggerOn = not State.TriggerOn
        if Config.TriggerBot.Notification then Notify("TriggerBot", State.TriggerOn and "ON" or "OFF") end
    end

    -- FrameSkip
    if Config.AimAssist.FrameSkip.UseKeyBind and kc==Enum.KeyCode[Config.AimAssist.FrameSkip.ToggleKeyBind:upper()] then
        State.FrameSkip = not State.FrameSkip
    end

    -- ESP toggle
    if Config.Esp.Use_KeyBind and kc==Config.Esp.KeyBind then
        Config.Esp.Enabled = not Config.Esp.Enabled
        Notify("ESP", Config.Esp.Enabled and "ON" or "OFF")
    end

    -- Gun Sort
    if Config.GunSorting.Enabled and kc==Enum.KeyCode[Config.GunSorting.Keybind:upper()] then SortGuns() end

    -- Macro
    if Config.Macro.Enabled and not Config.Macro.Hold_Key and kc==Config.Macro.KeyBind then
        local c=LP.Character; if c then
            local t=c:FindFirstChildOfClass("Tool"); local bp=LP:FindFirstChild("Backpack")
            if t and bp then t.Parent=bp; task.wait(0.05); t.Parent=c end
        end
    end

    -- Noclip
    if Config.Noclip_Macro.Enabled and kc==Config.Noclip_Macro.KeyBind then ToggleNoclip() end

    -- Auto360
    if Config.Misc.Auto360.Enabled and kc==Enum.KeyCode[Config.Misc.Auto360.SpinKeybind:upper()] then
        State.Spinning = not State.Spinning
    end

    -- Close Game
    if Config.Misc.CloseGame.Enabled and kc==Enum.KeyCode[Config.Misc.CloseGame.CloseGameKeybind:upper()] then
        if Config.Misc.CloseGame.UseDelay then task.wait(Config.Misc.CloseGame.Delay) end
        game:Shutdown()
    end

    -- Auto Reset
    if Config.Misc.AutoReset.Enabled and kc==Enum.KeyCode[Config.Misc.AutoReset.AutoResetKeybind:upper()] then
        if Config.Misc.AutoReset.UseDelay then task.wait(Config.Misc.AutoReset.Delay) end
        pcall(function() LP.Character:FindFirstChildOfClass("Humanoid").Health=0 end)
    end

    -- Rejoin
    if Config.Rejoin.Enabled and kc==Enum.KeyCode[Config.Rejoin.Keybind:upper()] then
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end

    -- Animations
    if Config.Animation.Lay    and kc==Config.Animation.LayKey    then PlayAnim("Lay")    end
    if Config.Animation.Greet  and kc==Config.Animation.GreetKey  then PlayAnim("Greet")  end
    if Config.Animation.Speed  and kc==Config.Animation.SpeedKey  then PlayAnim("Speed")  end
    if Config.Animation.Sturdy and kc==Config.Animation.SturdyKey then PlayAnim("Sturdy") end
    if Config.Animation.Griddy and kc==Config.Animation.GriddyKey then PlayAnim("Griddy") end

    -- Trash Talk
    if Config.Misc.TrashTalk.Enabled and kc==Enum.KeyCode[Config.Misc.TrashTalk.KeyBind:upper()] then
        spawn(function()
            local msgs=Config.Misc.TrashTalk.Messages
            if Config.Misc.TrashTalk.Method=="1" then
                pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msgs[math.random(1,#msgs)],"All") end)
            else
                for _,m in ipairs(msgs) do
                    pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(m,"All") end)
                    task.wait(Config.Misc.TrashTalk.Delay)
                end
            end
        end)
    end

    -- Mod key
    if Config.Mod.Enabled and Config.Mod.Mode=='Key' and kc==Enum.KeyCode[Config.Mod.Key:upper()] then
        game:Shutdown()
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if Config.AimAssist.Mode=='KeyBind' and Config.AimAssist.Hold_KeyBind then
        if input.KeyCode==Enum.KeyCode[Config.AimAssist.KeyBind:upper()] then State.AimOn=false; State.AimTarget=nil end
    elseif Config.AimAssist.Mode=='Mouse' then
        if input.UserInputType==Config.AimAssist.MouseBind then State.AimOn=false; State.AimTarget=nil end
    end
    if Config.TriggerBot.Mode=="Hold" and input.KeyCode==Config.TriggerBot.KeyBind then State.TriggerOn=false end
    if Config.Macro.Enabled and Config.Macro.Hold_Key and input.KeyCode==Config.Macro.KeyBind then end
end)

-- ═══════════════════════════════════
-- DONE
-- ═══════════════════════════════════
Notify("SHHHH V2.2", "Loaded! ESP=L, Silent=P, AimAssist=Q", 6)
print("[SHHHH V2.2] All features active.")
