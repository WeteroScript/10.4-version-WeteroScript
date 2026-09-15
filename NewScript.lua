--[[
    MEREDIOS v8.5
    Roblox / Delta X Mobile
    t.me//meredioshub
]]

do
    local targets = {}
    pcall(function() table.insert(targets, game:GetService("CoreGui")) end)
    pcall(function() table.insert(targets, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)) end)
    for _, p in ipairs(targets) do
        if p then
            for _, g in ipairs(p:GetChildren()) do
                if g.Name == "MerediosHUD" then pcall(function() g:Destroy() end) end
            end
        end
    end
end

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TS           = game:GetService("TweenService")
local TeleportSvc  = game:GetService("TeleportService")
local HttpSvc      = game:GetService("HttpService")

local LP = Players.LocalPlayer
if not LP then repeat task.wait(0.1); LP = Players.LocalPlayer until LP end
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.4)
math.randomseed(tick())

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerediosHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

do
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
    local parented = false
    local okH, hui = pcall(function() return gethui() end)
    if okH and hui then
        local ok = pcall(function() ScreenGui.Parent = hui end)
        parented = ok and ScreenGui.Parent ~= nil
    end
    if not parented then
        local okC, cg = pcall(function() return game:GetService("CoreGui") end)
        if okC and cg then
            local ok = pcall(function() ScreenGui.Parent = cg end)
            parented = ok and ScreenGui.Parent ~= nil
        end
    end
    if not parented then
        ScreenGui.Parent = LP:WaitForChild("PlayerGui", 10) or LP.PlayerGui
    end
end

--=============================================================
-- THEME
--=============================================================
local Theme = { mode = "Light", accent = "DarkBlue", anim = true }

local Palettes = {
    Light = {
        Bg=Color3.fromRGB(245,247,252), BgGlass=Color3.fromRGB(252,253,255),
        Card=Color3.fromRGB(255,255,255), CardEdge=Color3.fromRGB(225,230,240),
        Text=Color3.fromRGB(22,28,42), SubText=Color3.fromRGB(120,130,152),
        Track=Color3.fromRGB(205,212,226), Knob=Color3.fromRGB(70,82,108),
        Divider=Color3.fromRGB(225,230,240), Shadow=Color3.fromRGB(180,190,210),
    },
    Dark = {
        Bg=Color3.fromRGB(24,29,41), BgGlass=Color3.fromRGB(31,37,52),
        Card=Color3.fromRGB(38,45,62), CardEdge=Color3.fromRGB(58,68,88),
        Text=Color3.fromRGB(235,240,250), SubText=Color3.fromRGB(145,158,182),
        Track=Color3.fromRGB(60,70,92), Knob=Color3.fromRGB(245,250,255),
        Divider=Color3.fromRGB(58,68,88), Shadow=Color3.fromRGB(0,0,0),
    },
}

local Accents = {
    DarkBlue = { Main = Color3.fromRGB(30, 64, 175),  Dim = Color3.fromRGB(20, 45, 130) },
    Navy     = { Main = Color3.fromRGB(15, 40, 120),  Dim = Color3.fromRGB(10, 28, 88)  },
    Cyan     = { Main = Color3.fromRGB(0, 210, 255),  Dim = Color3.fromRGB(0, 140, 190) },
    Purple   = { Main = Color3.fromRGB(160, 95, 255), Dim = Color3.fromRGB(100, 55, 180) },
    Pink     = { Main = Color3.fromRGB(255, 95, 175), Dim = Color3.fromRGB(190, 55, 130) },
}

-- Cyclic palette — end == start so rotation is seamless
local FlowColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(30, 64, 175)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90, 130, 240)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(160, 95, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 95, 175)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 64, 175)),
})

local GradientColors = FlowColors

local BluePinkSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 45, 130)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(90, 130, 240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 95, 175)),
})

local P, Accent
local function refreshPalettes() P = Palettes[Theme.mode]; Accent = Accents[Theme.accent] end
refreshPalettes()

--=============================================================
-- ANIMATED GRADIENTS (color flow)
--=============================================================
local AnimatedGradients = {}
local function registerGrad(g, speed)
    if not g then return end
    table.insert(AnimatedGradients, { g = g, speed = speed or 25, base = g.Rotation or 0 })
end

local lastGradTick = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastGradTick < 0.03 then return end
    lastGradTick = now
    for i = #AnimatedGradients, 1, -1 do
        local e = AnimatedGradients[i]
        if not e.g or not e.g.Parent then
            table.remove(AnimatedGradients, i)
        else
            e.g.Rotation = (e.base + now * e.speed) % 360
        end
    end
end)

--=============================================================
-- UTILITIES
--=============================================================
local function new(class, props)
    local o = Instance.new(class)
    if props then for k, v in pairs(props) do o[k] = v end end
    return o
end

local function tween(o, time, props, style, dir)
    local info = TweenInfo.new(time or 0.28, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TS:Create(o, info, props); t:Play(); return t
end

local function round(o, r)
    local c = new("UICorner", { CornerRadius = UDim.new(0, r or 12) }); c.Parent = o; return c
end

local function gradientStroke(parent, thickness, transparency, rotation)
    local stroke = new("UIStroke", {
        Thickness = thickness or 2,
        Transparency = transparency or 0.05,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
        Color = Color3.new(1, 1, 1),
    })
    stroke.Parent = parent
    local grad = new("UIGradient", { Color = FlowColors, Rotation = rotation or 35 })
    grad.Parent = stroke
    registerGrad(grad, 30)
    return stroke, grad
end

local function dragify(frame, handle, canDrag)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if canDrag and not canDrag() then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local ThemeReg = {}
local function reg(inst, prop, key)
    table.insert(ThemeReg, {inst, prop, key})
    if inst and inst.Parent ~= nil then inst[prop] = P[key] end
end

local SwitchRegistry = {}
local LogTabButtons  = {}
local SegRegistry    = {}

local function applyTheme()
    refreshPalettes()
    for _, e in ipairs(ThemeReg) do
        local inst, prop, key = e[1], e[2], e[3]
        if inst and inst.Parent then tween(inst, 0.32, {[prop] = P[key]}) end
    end
    for _, s in ipairs(SwitchRegistry) do
        if s.card and s.card.Parent then
            s.track.BackgroundColor3 = s.state and Accent.Main or P.Track
            s.knob.BackgroundColor3 = P.Knob
            s.lbl.TextColor3 = s.state and Accent.Main or P.SubText
        end
    end
    for _, entry in ipairs(LogTabButtons) do
        local active = (entry.name == Logger.activeTab)
        entry.btn.BackgroundColor3 = active and Accent.Main or P.Card
        entry.btn.TextColor3 = active and Color3.fromRGB(255,255,255) or P.SubText
    end
    for _, seg in ipairs(SegRegistry) do
        if seg.refresh then seg.refresh(seg.get_current()) end
    end
end

--=============================================================
-- LOGGER + FILTERS + CLIPBOARD
--=============================================================
local Logger = {
    buffer = { server = {}, script = {} },
    maxLen = 600,
    listeners = {},
    filterListeners = {},
    activeTab = "script",
    filters = {},        -- [remoteName] = true (show) / false (hide); missing = show
    knownRemotes = {},
}

local function logLine(channel, text)
    local buf = Logger.buffer[channel]
    if not buf then return end
    local t = os.date("%H:%M:%S")
    table.insert(buf, "[" .. t .. "] " .. text)
    while #buf > Logger.maxLen do table.remove(buf, 1) end
    for _, cb in ipairs(Logger.listeners) do pcall(cb, channel) end
end
local function logScript(text) logLine("script", text) end
local function logServer(text) logLine("server", text) end

local function fmtArg(a)
    local t = typeof(a)
    if t == "Vector3" then
        return string.format("V3(%.1f,%.1f,%.1f)", a.X, a.Y, a.Z)
    elseif t == "Vector2" then
        return string.format("V2(%.1f,%.1f)", a.X, a.Y)
    elseif t == "CFrame" then return "CFrame"
    elseif t == "Instance" then
        local ok, n = pcall(function() return a:GetFullName() end)
        return ok and n or "Instance"
    elseif t == "table" then return "{table}"
    else return tostring(a) end
end

-- rate limiter for remote spam
local remoteRateCount = 0
local remoteRateWindow = 0
local MAX_REMOTE_RATE = 80

local function rememberRemote(name)
    if not Logger.knownRemotes[name] then
        Logger.knownRemotes[name] = true
        for _, cb in ipairs(Logger.filterListeners) do pcall(cb) end
    end
end

local function logRemote(name, args)
    rememberRemote(name)
    if Logger.filters[name] == false then return end
    local now = tick()
    if now > remoteRateWindow then
        remoteRateWindow = now + 1
        remoteRateCount = 0
    end
    if remoteRateCount >= MAX_REMOTE_RATE then return end
    remoteRateCount = remoteRateCount + 1
    local parts = {}
    for i = 1, math.min(#args, 8) do parts[i] = fmtArg(args[i]) end
    local suffix = #args > 8 and (" ...(+" .. (#args - 8) .. ")") or ""
    logServer("REMOTE " .. name .. "(" .. table.concat(parts, ", ") .. ")" .. suffix)
end

local function copyToClipboard(text)
    local fns = { setclipboard, toclipboard, writeclipboard }
    for _, fn in ipairs(fns) do
        if type(fn) == "function" then
            local ok = pcall(fn, text)
            if ok then return true end
        end
    end
    return false
end

local function buildLogText()
    local out = {}
    table.insert(out, "=== MEREDIOS SERVER LOG ===")
    if #Logger.buffer.server == 0 then table.insert(out, "(empty)") end
    for _, l in ipairs(Logger.buffer.server) do table.insert(out, l) end
    table.insert(out, "")
    table.insert(out, "=== MEREDIOS SCRIPT LOG ===")
    if #Logger.buffer.script == 0 then table.insert(out, "(empty)") end
    for _, l in ipairs(Logger.buffer.script) do table.insert(out, l) end
    return table.concat(out, "\n")
end

--=============================================================
-- REMOTE NAMECALL HOOK (logging only)
--=============================================================
do
    local okMT, mt = pcall(getrawmetatable, game)
    if okMT and mt and newcclosure and setreadonly then
        local oldNamecall = mt.__namecall
        if oldNamecall then
            local okRO = pcall(setreadonly, mt, false)
            if okRO then
                local okSet, err = pcall(function()
                    mt.__namecall = newcclosure(function(self, ...)
                        local method = getnamecallmethod and getnamecallmethod() or nil
                        if method == "FireServer" or method == "InvokeServer" then
                            local ok, nm = pcall(function() return self:GetFullName() end)
                            logRemote(ok and nm or "Unknown", {...})
                        end
                        return oldNamecall(self, ...)
                    end)
                end)
                pcall(setreadonly, mt, true)
                if okSet then
                    logScript("Remote hook armed · FireServer + InvokeServer")
                else
                    logScript("Remote hook failed: " .. tostring(err))
                end
            else
                logScript("Remote hook refused — mt readonly")
            end
        else
            logScript("Remote hook — no __namecall")
        end
    else
        logScript("Remote hook unavailable")
    end
end

--=============================================================
-- HITBOX CHANGER
--=============================================================
local HitboxChanger = { Enabled = false, View = false, Size = 12, Original = {} }

local function hitboxParts(char)
    if not char then return {} end
    local list = {}
    local names = { "HumanoidRootPart", "Head", "UpperTorso", "Torso", "LowerTorso" }
    for _, name in ipairs(names) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then table.insert(list, p) end
    end
    return list
end

local function applyHitboxToChar(char)
    if not char then return end
    for _, part in ipairs(hitboxParts(char)) do
        if not HitboxChanger.Original[part] then
            HitboxChanger.Original[part] = {
                Size = part.Size, Transparency = part.Transparency,
                CanCollide = part.CanCollide, CanQuery = part.CanQuery,
            }
        end
        part.Size = Vector3.new(HitboxChanger.Size, HitboxChanger.Size, HitboxChanger.Size)
        part.Transparency = 1
        part.CanCollide = false
        part.CanQuery = true
    end
end

local function restoreHitboxForChar(char)
    if not char then return end
    for part, orig in pairs(HitboxChanger.Original) do
        if part and part.Parent and part:IsDescendantOf(char) then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
                part.CanQuery = orig.CanQuery
            end)
            HitboxChanger.Original[part] = nil
        end
    end
end

local function applyAllHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then applyHitboxToChar(plr.Character) end
    end
end

local function restoreAllHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then restoreHitboxForChar(plr.Character) end
    end
end

local function applyHitboxViewToChar(char)
    if not char then return end
    for _, part in ipairs(hitboxParts(char)) do
        if not part:FindFirstChild("MerediosHitboxView") then
            local box = new("BoxHandleAdornment", {
                Name = "MerediosHitboxView", Adornee = part,
                AlwaysOnTop = true, ZIndex = 5, Transparency = 0.5,
                Color3 = Accent.Main, Size = part.Size,
            })
            box.Parent = part
        end
    end
end

local function removeHitboxViewFromChar(char)
    if not char then return end
    for _, part in ipairs(hitboxParts(char)) do
        local v = part:FindFirstChild("MerediosHitboxView")
        if v then pcall(function() v:Destroy() end) end
    end
end

local function applyAllHitboxViews()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then applyHitboxViewToChar(plr.Character) end
    end
end

local function removeAllHitboxViews()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then removeHitboxViewFromChar(plr.Character) end
    end
end

local function refreshAllHitboxViews()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                for _, part in ipairs(hitboxParts(char)) do
                    local v = part:FindFirstChild("MerediosHitboxView")
                    if v then v.Size = part.Size end
                end
            end
        end
    end
end

--=============================================================
-- ESP
--=============================================================
local VISIBLE_COLOR = Color3.fromRGB(80, 220, 100)

local ESP = {
    Enabled = false,
    Color = Color3.fromRGB(255, 95, 175),
    ColorName = "PINK",
    VisibilityCheck = false,     -- OFF by default (per request)
    Highlights = {},
    LastCheck = {},
    CheckInterval = 0.12,
}

local ESP_PALETTE = {
    { name = "PINK",   color = Color3.fromRGB(255, 95, 175) },
    { name = "RED",    color = Color3.fromRGB(255, 60, 60) },
    { name = "ORANGE", color = Color3.fromRGB(255, 140, 40) },
    { name = "YELLOW", color = Color3.fromRGB(255, 220, 60) },
    { name = "GREEN",  color = VISIBLE_COLOR },
    { name = "CYAN",   color = Color3.fromRGB(0, 210, 255) },
    { name = "BLUE",   color = Color3.fromRGB(30, 64, 175) },
    { name = "PURPLE", color = Color3.fromRGB(160, 95, 255) },
    { name = "WHITE",  color = Color3.fromRGB(255, 255, 255) },
}

local function hasLineOfSight(char)
    if not char then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    params.IgnoreWater = true
    local origin = cam.CFrame.Position
    local samples = { "Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart" }
    for _, name in ipairs(samples) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local dir = part.Position - origin
            local hit = workspace:Raycast(origin, dir, params)
            if hit and hit.Instance and hit.Instance:IsA("BasePart")
               and hit.Instance:IsDescendantOf(char) then
                return true
            end
        end
    end
    return false
end

local function applyHighlightStyle(h, plr)
    local visible = ESP.VisibilityCheck and hasLineOfSight(plr.Character)
    if visible then
        h.FillColor = VISIBLE_COLOR
        h.OutlineColor = VISIBLE_COLOR
        h.FillTransparency = 0.55
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.Occluded
    else
        h.FillColor = ESP.Color
        h.OutlineColor = ESP.Color
        h.FillTransparency = 0.75
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
end

local function createESPHighlight(char)
    if not char then return nil end
    local existing = char:FindFirstChild("MerediosESP")
    if existing then existing:Destroy() end
    local h = Instance.new("Highlight")
    h.Name = "MerediosESP"
    h.FillColor = ESP.Color
    h.FillTransparency = 0.75
    h.OutlineColor = ESP.Color
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
    return h
end

local function removeESPFromChar(char)
    if not char then return end
    local h = char:FindFirstChild("MerediosESP")
    if h then pcall(function() h:Destroy() end) end
end

local function updateESPForPlayer(plr)
    if ESP.Highlights[plr] then
        pcall(function() ESP.Highlights[plr]:Destroy() end)
        ESP.Highlights[plr] = nil
    end
    ESP.LastCheck[plr] = nil
    if not ESP.Enabled or plr == LP then return end
    local char = plr.Character
    if not char then return end
    local h = createESPHighlight(char)
    if h then
        ESP.Highlights[plr] = h
        applyHighlightStyle(h, plr)
        ESP.LastCheck[plr] = tick()
    end
end

local function refreshAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do updateESPForPlayer(plr) end
end

RunService.Heartbeat:Connect(function()
    if not ESP.Enabled or not ESP.VisibilityCheck then return end
    local now = tick()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local h = ESP.Highlights[plr]
            local last = ESP.LastCheck[plr] or 0
            if h and h.Parent and (now - last) >= ESP.CheckInterval then
                ESP.LastCheck[plr] = now
                applyHighlightStyle(h, plr)
            end
        end
    end
end)

local function reapplyAllESPStyles()
    for plr, h in pairs(ESP.Highlights) do
        if h and h.Parent then applyHighlightStyle(h, plr) end
    end
end

--=============================================================
-- SPEED
--=============================================================
local Speed = { Enabled = false, Value = 32 }

RunService.Heartbeat:Connect(function()
    if not Speed.Enabled then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= Speed.Value then hum.WalkSpeed = Speed.Value end
end)

--=============================================================
-- ANTI-FLING
--=============================================================
local AntiFling = { Enabled = false }

RunService.Heartbeat:Connect(function()
    if not AntiFling.Enabled then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local vel = hrp.AssemblyLinearVelocity
    local ang = hrp.AssemblyAngularVelocity
    local speed = vel.Magnitude
    local spin  = ang.Magnitude
    local isFlingVel  = speed > 200
    local isFlingSpin = spin  > 20
    local isFlingUp   = vel.Y > 120

    if isFlingVel or isFlingSpin or isFlingUp then
        local finalVel = vel
        if isFlingVel then finalVel = vel.Unit * math.min(speed, 60) end
        if isFlingUp then finalVel = Vector3.new(finalVel.X, 0, finalVel.Z) end
        hrp.AssemblyLinearVelocity = finalVel
        if isFlingSpin then hrp.AssemblyAngularVelocity = ang.Unit * 5 end
    end
end)

--=============================================================
-- AIMBOT v8.5 — sticky hard-lock
--=============================================================
local Aimbot = {
    Enabled = false,
    FOV = 140,
    Color = Color3.fromRGB(255, 255, 255),
    ColorName = "WHITE",
    VisibleOnly = false,
    ReleaseThreshold = 90,        -- accumulated camera motion to trigger release
    ReleaseWindow = 0.10,         -- short release window
    MoveAccum = 0,
    LockReleaseUntil = 0,
    Target = nil,
    LockedTarget = nil,           -- sticky target — kept until death / FOV loss / release
    ActiveGameTouch = nil,
    SavedCameraType = nil,
}

-- ----- FOV circle (single clean ring, layered UNDER gui by default) -----
local fovWrap = new("Frame", {
    Name = "MerediosFOVWrap",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, Aimbot.FOV * 2 + 8, 0, Aimbot.FOV * 2 + 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 0,                   -- under menu (menu is ZIndex 1)
})
round(fovWrap, Aimbot.FOV + 4)

local fovOuterStroke = new("UIStroke", {
    Thickness = 2.5,
    Color = Color3.fromRGB(0, 0, 0),
    Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
})
fovOuterStroke.Parent = fovWrap

local fovCircle = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, -8, 1, -8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
})
round(fovCircle, Aimbot.FOV)
local fovStroke = new("UIStroke", {
    Thickness = 3,
    Color = Aimbot.Color,
    Transparency = 0,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
})
fovStroke.Parent = fovCircle
fovCircle.Parent = fovWrap
fovWrap.Parent = ScreenGui

local function updateFOVCircle()
    fovWrap.Size = UDim2.new(0, Aimbot.FOV * 2 + 8, 0, Aimbot.FOV * 2 + 8)
    local wrapCorner = fovWrap:FindFirstChildOfClass("UICorner")
    if wrapCorner then wrapCorner.CornerRadius = UDim.new(0, Aimbot.FOV + 4) end
    local innerCorner = fovCircle:FindFirstChildOfClass("UICorner")
    if innerCorner then innerCorner.CornerRadius = UDim.new(0, Aimbot.FOV) end
    fovStroke.Color = Aimbot.Color
    if Aimbot.ColorName == "WHITE" then
        fovOuterStroke.Transparency = 0
    else
        fovOuterStroke.Transparency = 1
    end
end

updateFOVCircle()

local function setAimbotColor(name, color)
    Aimbot.ColorName = name
    Aimbot.Color = color
    updateFOVCircle()
end

local function getHeadPos(plr)
    local char = plr.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head.Position end
    return nil
end

local function isAlive(plr)
    if not plr then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function isPlayerVisible(plr)
    return hasLineOfSight(plr.Character)
end

local function findNearestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local best, bestDist = nil, Aimbot.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr) then
            local pos = getHeadPos(plr)
            if pos then
                local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                if onScreen and screenPos.Z > 0 then
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if d <= bestDist then
                        if Aimbot.VisibleOnly and not isPlayerVisible(plr) then
                            -- skip
                        else
                            best, bestDist = plr, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local function snapCameraTo(plr)
    local cam = workspace.CurrentCamera
    local pos = getHeadPos(plr)
    if not cam or not pos then return end
    local camPos = cam.CFrame.Position
    local targetCF = CFrame.new(camPos, pos)
    local rx, ry, _ = targetCF:ToOrientation()
    cam.CFrame = CFrame.fromOrientation(rx, ry, 0) + camPos
end

-- ----- input tracking -----
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        Aimbot.ActiveGameTouch = input
    end
end)
UIS.InputEnded:Connect(function(input)
    if input == Aimbot.ActiveGameTouch then
        Aimbot.ActiveGameTouch = nil
    end
end)
UIS.InputChanged:Connect(function(input, gpe)
    if gpe then return end
    if not Aimbot.Enabled then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Delta.Magnitude
        if d > 1.5 then Aimbot.MoveAccum = Aimbot.MoveAccum + d end
    elseif input == Aimbot.ActiveGameTouch then
        local d = input.Delta.Magnitude
        if d > 1.5 then Aimbot.MoveAccum = Aimbot.MoveAccum + d end
    end
end)

local prevTargetLogged = nil

local function aimbotStep()
    local now = tick()

    -- FOV ring visibility: only when aimbot enabled
    fovWrap.Visible = Aimbot.Enabled

    if not Aimbot.Enabled then
        Aimbot.MoveAccum = 0
        Aimbot.Target = nil
        Aimbot.LockedTarget = nil
        prevTargetLogged = nil
        return
    end

    if UIS.GetFocusedTextBox and UIS:GetFocusedTextBox() then return end

    -- release on deliberate user motion
    if Aimbot.MoveAccum >= Aimbot.ReleaseThreshold then
        Aimbot.LockReleaseUntil = now + Aimbot.ReleaseWindow
        Aimbot.MoveAccum = 0
        Aimbot.LockedTarget = nil
    end

    if now < Aimbot.LockReleaseUntil then
        if Aimbot.Target and prevTargetLogged then
            logScript("Aimbot release")
            prevTargetLogged = nil
        end
        Aimbot.Target = nil
        return
    end

    -- sticky target validation
    local target = Aimbot.LockedTarget
    if target then
        -- drop if dead, gone, or (VisibleOnly) no line of sight
        if not isAlive(target) then
            target = nil; Aimbot.LockedTarget = nil
        elseif Aimbot.VisibleOnly and not isPlayerVisible(target) then
            target = nil; Aimbot.LockedTarget = nil
        end
        -- NOTE: keep lock even if target drifts outside FOV — that's the "не упускает цель"
    end

    -- only search when no sticky lock
    if not target then
        target = findNearestTarget()
        Aimbot.LockedTarget = target
    end

    Aimbot.Target = target

    if target then
        snapCameraTo(target)
        if target ~= prevTargetLogged then
            logScript("Aimbot lock → " .. target.Name)
            prevTargetLogged = target
        end
    else
        prevTargetLogged = nil
    end
end

pcall(function() RunService:UnbindFromRenderStep("MerediosAimbot") end)
-- Bind LATE so we override the default camera module's CFrame write.
RunService:BindToRenderStep("MerediosAimbot", Enum.RenderPriority.Camera.Value + 10, aimbotStep)

--=============================================================
-- PLAYER HOOKS
--=============================================================
local hookedPlayers = {}

local function hookPlayerForCombat(plr)
    if hookedPlayers[plr] then return end
    hookedPlayers[plr] = true
    plr.CharacterAdded:Connect(function(char)
        logServer(plr.Name .. " spawned")
        task.wait(0.25)
        if HitboxChanger.Enabled then applyHitboxToChar(char) end
        if HitboxChanger.View then applyHitboxViewToChar(char) end
        if ESP.Enabled then updateESPForPlayer(plr) end
    end)
    plr.CharacterRemoving:Connect(function(char)
        removeESPFromChar(char)
        removeHitboxViewFromChar(char)
        restoreHitboxForChar(char)
        logServer(plr.Name .. " despawned")
    end)
    if plr.Character then
        task.spawn(function()
            task.wait(0.2)
            if HitboxChanger.Enabled then applyHitboxToChar(plr.Character) end
            if HitboxChanger.View then applyHitboxViewToChar(plr.Character) end
            if ESP.Enabled then updateESPForPlayer(plr) end
        end)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then hookPlayerForCombat(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    logServer(plr.Name .. " joined")
    if plr ~= LP then hookPlayerForCombat(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    logServer(plr.Name .. " left")
    hookedPlayers[plr] = nil

    for part, orig in pairs(HitboxChanger.Original) do
        if not part or not part.Parent then
            HitboxChanger.Original[part] = nil
        elseif plr.Character and part:IsDescendantOf(plr.Character) then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
                part.CanQuery = orig.CanQuery
            end)
            HitboxChanger.Original[part] = nil
        end
    end

    if ESP.Highlights[plr] then
        pcall(function() ESP.Highlights[plr]:Destroy() end)
        ESP.Highlights[plr] = nil
    end
    ESP.LastCheck[plr] = nil
end)

-- chat listener
task.spawn(function()
    local ok, chat = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 5) end)
    if ok and chat then
        local msgEvent = chat:FindFirstChild("OnMessageDoneFiltering")
        if msgEvent and msgEvent:IsA("RemoteEvent") then
            msgEvent.OnClientEvent:Connect(function(data)
                if data and data.MessageText and data.FromSpeaker then
                    logServer("CHAT " .. data.FromSpeaker .. ": " .. tostring(data.MessageText))
                end
            end)
        end
    end
end)

if LP then
    LP.CharacterAdded:Connect(function(char)
        logServer("local respawned")
        task.wait(0.25)
        if Speed.Enabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Speed.Value end
        end
    end)
end

--=============================================================
-- SERVER HOP HELPERS
--=============================================================
local function httpGet(url)
    local fns = {}
    if syn and syn.request then table.insert(fns, syn.request) end
    if http and http.request then table.insert(fns, http.request) end
    if type(request) == "function" then table.insert(fns, request) end
    if type(http_request) == "function" then table.insert(fns, http_request) end
    for _, fn in ipairs(fns) do
        local ok, resp = pcall(fn, { Url = url, Method = "GET" })
        if ok and resp then
            local body = resp.Body or resp.body
            if body then return body end
        end
    end
    return nil
end

local function fetchServerList()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
    local body = httpGet(url)
    if not body then return nil end
    local ok, data = pcall(function() return HttpSvc:JSONDecode(body) end)
    if not ok or type(data) ~= "table" or type(data.data) ~= "table" then return nil end
    return data.data
end

local function hopTo(server)
    if not server or not server.id then return false end
    local ok = pcall(function()
        TeleportSvc:TeleportToPlaceInstance(game.PlaceId, server.id, LP)
    end)
    return ok
end

local function serverHop()
    logScript("ServerHop: fetching...")
    local servers = fetchServerList()
    if not servers then logScript("ServerHop: HTTP unavailable"); return end
    local candidates = {}
    local current = game.JobId
    for _, s in ipairs(servers) do
        if s.id ~= current and (s.playing or 0) < (s.maxPlayers or 999) then
            table.insert(candidates, s)
        end
    end
    if #candidates == 0 then logScript("ServerHop: no open servers"); return end
    local pick = candidates[math.random(1, #candidates)]
    logScript("ServerHop → " .. pick.id .. " · " .. (pick.playing or 0) .. "/" .. (pick.maxPlayers or "?") .. " players")
    if not hopTo(pick) then logScript("ServerHop: teleport failed") end
end

local function emptyHop()
    logScript("EmptyHop: fetching...")
    local servers = fetchServerList()
    if not servers then logScript("EmptyHop: HTTP unavailable"); return end
    local current = game.JobId
    local empty
    local lowest
    for _, s in ipairs(servers) do
        if s.id ~= current then
            local pop = s.playing or 0
            if pop == 0 and not empty then empty = s end
            if not lowest or pop < (lowest.playing or 0) then lowest = s end
        end
    end
    local pick = empty or lowest
    if not pick then logScript("EmptyHop: no server"); return end
    local tag = empty and "EMPTY" or "LOWEST"
    logScript("EmptyHop (" .. tag .. ") → " .. pick.id .. " · " .. (pick.playing or 0) .. " players")
    if not hopTo(pick) then logScript("EmptyHop: teleport failed") end
end

--=============================================================
-- UI BUILDERS
--=============================================================

-- ---------- Startup ----------
local startup = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 300, 0, 140),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.05,
    BorderSizePixel = 0, GroupTransparency = 1,
})
round(startup, 20)
local startupStroke = gradientStroke(startup, 2.5, 0.08, 30)
startupStroke.Transparency = 1
startup.Parent = ScreenGui
reg(startup, "BackgroundColor3", "BgGlass")

local startupTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, -60, 0, 20),
    Size = UDim2.new(1, -44, 0, 30),
    Text = "Meredios",
    TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 26,
    TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1,
})
startupTitle.Parent = startup
reg(startupTitle, "TextColor3", "Text")

local startupSub = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, -40, 0, 50),
    Size = UDim2.new(1, -44, 0, 12),
    Text = "// meridian core v8.5 · t.me//meredioshub",
    TextColor3 = P.SubText,
    Font = Enum.Font.Code, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1,
})
startupSub.Parent = startup
reg(startupSub, "TextColor3", "SubText")

local startBtn = new("TextButton", {
    Position = UDim2.new(0.5, 0, 1, -58), AnchorPoint = Vector2.new(0.5, 0),
    Size = UDim2.new(0, 160, 0, 36),
    BackgroundColor3 = Accent.Main,
    Text = "НАЧАТЬ", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 13,
    AutoButtonColor = false, BorderSizePixel = 0,
    TextTransparency = 1, BackgroundTransparency = 1,
})
round(startBtn, 10)
startBtn.Parent = startup

tween(startup, 0.45, { GroupTransparency = 0 })
tween(startupStroke, 0.45, { Transparency = 0.08 })

task.spawn(function()
    task.wait(0.7)
    if not startup.Parent then return end
    tween(startupTitle, 0.5, { Position = UDim2.new(0, 22, 0, 20), TextTransparency = 0 })
    tween(startupSub, 0.5, { Position = UDim2.new(0, 22, 0, 50), TextTransparency = 0 })
    task.wait(0.15)
    tween(startBtn, 0.42, { TextTransparency = 0, BackgroundTransparency = 0 })
end)

-- ---------- Main menu ----------
local MENU_W, MENU_H = 420, 400

local menu = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, MENU_W, 0, MENU_H),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.04,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 1,
})
round(menu, 20)
local menuStroke = gradientStroke(menu, 2.5, 0.05, 30)
menuStroke.Transparency = 1
menu.Parent = ScreenGui
reg(menu, "BackgroundColor3", "BgGlass")

local topGlow = new("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = P.Card,
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0, ZIndex = 1,
})
round(topGlow, 20)
topGlow.Parent = menu

local topBar = new("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, ZIndex = 2 })
topBar.Parent = menu

local brand = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 10),
    Size = UDim2.new(0, 220, 0, 18),
    Text = "MEREDIOS",
    TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
})
brand.Parent = topBar
reg(brand, "TextColor3", "Text")

local subBrand = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 28),
    Size = UDim2.new(0, 320, 0, 12),
    Text = "v8.5 // t.me//meredioshub",
    TextColor3 = P.SubText,
    Font = Enum.Font.Code, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
})
subBrand.Parent = topBar
reg(subBrand, "TextColor3", "SubText")

local onlineDot = new("Frame", {
    Position = UDim2.new(0, 165, 0, 32),
    Size = UDim2.new(0, 5, 0, 5),
    BackgroundColor3 = Color3.fromRGB(80, 220, 100),
    BorderSizePixel = 0, ZIndex = 3,
})
round(onlineDot, 3)
onlineDot.Parent = topBar
task.spawn(function()
    while onlineDot.Parent do
        tween(onlineDot, 1.2, { BackgroundTransparency = 0.6 }, Enum.EasingStyle.Sine)
        task.wait(1.2)
        if not onlineDot.Parent then break end
        tween(onlineDot, 1.2, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine)
        task.wait(1.2)
    end
end)

local topDivider = new("Frame", {
    Position = UDim2.new(0, 18, 0, 50),
    Size = UDim2.new(1, -36, 0, 1),
    BackgroundColor3 = P.Divider, BorderSizePixel = 0, ZIndex = 2,
})
topDivider.Parent = topBar
reg(topDivider, "BackgroundColor3", "Divider")

local rightBox = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0, 26),
    Size = UDim2.new(0, 68, 0, 28), BackgroundTransparency = 1, ZIndex = 2,
})
rightBox.Parent = topBar

local gearBtn = new("TextButton", {
    Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "⚙", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 14,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
})
round(gearBtn, 9); gearBtn.Parent = rightBox
reg(gearBtn, "BackgroundColor3", "Card"); reg(gearBtn, "TextColor3", "Text")

local closeBtn = new("TextButton", {
    Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 40, 0, 0),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 17,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
})
round(closeBtn, 9); closeBtn.Parent = rightBox
reg(closeBtn, "BackgroundColor3", "Card"); reg(closeBtn, "TextColor3", "Text")

dragify(menu, topBar, function() return not (_G.MerediosSettingsOpen == true) end)

local tabBar = new("ScrollingFrame", {
    Position = UDim2.new(0, 12, 0, 58),
    Size = UDim2.new(1, -24, 0, 32),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.X, ZIndex = 2,
})
tabBar.Parent = menu
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}).Parent = tabBar

local contentBox = new("Frame", {
    Position = UDim2.new(0, 12, 0, 96),
    Size = UDim2.new(1, -24, 1, -108),
    BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = false,
})
contentBox.Parent = menu

local TABS = { "MAIN", "LOG", "COMBAT", "NEW" }
local tabButtons = {}
local contentPages = {}
local activeTab = "MAIN"

local function animatePageIn(page)
    page.Position = UDim2.new(0, 0, 0, 26)
    tween(page, 0.38, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local idx = 0
    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("Frame") then
            idx = idx + 1
            local targetBg = child.BackgroundTransparency
            local targetStroke
            if child:IsA("GuiObject") then
                local stroke = child:FindFirstChildOfClass("UIStroke")
                targetStroke = stroke and stroke.Transparency or 0
            end
            child.BackgroundTransparency = 1
            local stroke = child:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = 1 end
            task.delay((idx - 1) * 0.045, function()
                if not child.Parent then return end
                tween(child, 0.32, { BackgroundTransparency = targetBg })
                if stroke then tween(stroke, 0.32, { Transparency = targetStroke }) end
            end)
        end
    end
end

local function switchTab(name)
    activeTab = name
    for tName, btn in pairs(tabButtons) do
        local on = tName == name
        tween(btn, 0.22, {
            BackgroundTransparency = on and 0.05 or 0.85,
            TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText,
        })
        local st = btn:FindFirstChildOfClass("UIStroke")
        if st then st.Transparency = on and 0 or 0.5 end
    end
    for tName, page in pairs(contentPages) do
        if tName == name then
            page.Visible = true
            animatePageIn(page)
        else
            page.Visible = false
        end
    end
end

local function makePage(name)
    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Accent.Main,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false, ZIndex = 2,
        ClipsDescendants = true,
    })
    page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    page.Parent = contentBox
    contentPages[name] = page
    return page
end

local function makeTab(name, order)
    local btn = new("TextButton", {
        Size = UDim2.new(0, 68, 0, 28),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.85,
        Text = name, TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0,
        LayoutOrder = order,
    })
    round(btn, 9)
    gradientStroke(btn, 2, 0.5, 30)
    btn.Parent = tabBar
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabButtons[name] = btn
    return btn
end

for i, name in ipairs(TABS) do makeTab(name, i) end

-- ---------- Card with border-wrapper (border wraps fully, no clipping) ----------
local function makeRow(page, order, title, desc, height)
    height = height or (desc and 54 or 42)

    -- Outer border frame — gradient flows, wraps the inner card fully
    local border = new("Frame", {
        Size = UDim2.new(1, -14, 0, height + 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, LayoutOrder = order,
        ZIndex = 1,
    })
    round(border, 14)
    local borderGrad = new("UIGradient", { Color = FlowColors, Rotation = 0 })
    borderGrad.Parent = border
    registerGrad(borderGrad, 25)
    border.Parent = page

    local card = new("Frame", {
        Position = UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.02,
        BorderSizePixel = 0, ZIndex = 2,
    })
    round(card, 12)
    card.Parent = border
    reg(card, "BackgroundColor3", "Card")

    local accentBar = new("Frame", {
        Position = UDim2.new(0, 10, 0, 12),
        Size = UDim2.new(0, 3, 0, desc and 12 or 16),
        BackgroundColor3 = Accent.Main,
        BorderSizePixel = 0, ZIndex = 3,
    })
    round(accentBar, 2)
    accentBar.Parent = card

    local t = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, desc and 8 or 12),
        Size = UDim2.new(1, -90, 0, 16),
        Text = title, TextColor3 = P.Text,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    })
    t.Parent = card
    reg(t, "TextColor3", "Text")

    if desc then
        local d = new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 26),
            Size = UDim2.new(1, -32, 0, 22),
            Text = desc, TextColor3 = P.SubText,
            Font = Enum.Font.Gotham, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, ZIndex = 3,
        })
        d.Parent = card
        reg(d, "TextColor3", "SubText")
    end
    return card, border
end

local function makeSwitch(card, y, onChanged, initial)
    local track = new("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0, y or 12),
        BackgroundColor3 = P.Track, BorderSizePixel = 0, ZIndex = 3,
    })
    round(track, 10); track.Parent = card

    local knob = new("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 4,
    })
    round(knob, 8); knob.Parent = track

    local lbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -78, 0, (y or 12) + 3),
        Size = UDim2.new(0, 22, 0, 12),
        Text = "OFF", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3,
    })
    lbl.Parent = card

    local entry = { state = false, track = track, knob = knob, lbl = lbl, card = card }
    table.insert(SwitchRegistry, entry)

    local function set(v)
        entry.state = v
        tween(knob, 0.26, { Position = v and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) })
        tween(track, 0.26, { BackgroundColor3 = v and Accent.Main or P.Track })
        lbl.Text = v and "ON" or "OFF"
        lbl.TextColor3 = v and Accent.Main or P.SubText
        if onChanged then onChanged(v) end
    end
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5,
    })
    btn.Parent = track
    btn.MouseButton1Click:Connect(function() set(not entry.state) end)
    if initial then set(true) end
    return set
end

-- slider with drag-start / drag-end callbacks
local function makeSlider(parent, y, min, max, initial, onChange, widthTrim, onDragStart, onDragEnd)
    local track = new("Frame", {
        Position = UDim2.new(0, 12, 0, y),
        Size = UDim2.new(1, widthTrim or -84, 0, 6),
        BackgroundColor3 = P.Track,
        BorderSizePixel = 0, ZIndex = 3,
    })
    round(track, 3); track.Parent = parent

    local fill = new("Frame", {
        Size = UDim2.new((initial - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Accent.Main,
        BorderSizePixel = 0, ZIndex = 4,
    })
    round(fill, 3); fill.Parent = track

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((initial - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = P.Knob,
        BorderSizePixel = 0, ZIndex = 5,
    })
    round(knob, 7); knob.Parent = track

    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, y - 10),
        Size = UDim2.new(0, 58, 0, 14),
        Text = tostring(initial),
        TextColor3 = P.Text, Font = Enum.Font.Code, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 3,
    })
    valLbl.Parent = parent
    reg(valLbl, "TextColor3", "Text")

    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local v = math.floor(min + (max - min) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = tostring(v)
        if onChange then onChange(v) end
    end
    track.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true
            if onDragStart then pcall(onDragStart) end
            setFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
            if onDragEnd then pcall(onDragEnd) end
        end
    end)
    return function(v)
        v = math.clamp(v, min, max)
        local rel = (v - min) / (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = tostring(v)
        if onChange then onChange(v) end
    end
end

-- dynamic palette — swatch set can be rebuilt (needed for ESP visibility toggle)
local function makeColorPaletteDynamic(parent, y, getPalette, getCurrent, onSelect, swatchSize)
    swatchSize = swatchSize or 22
    local row = new("Frame", {
        Position = UDim2.new(0, 12, 0, y),
        Size = UDim2.new(1, -24, 0, swatchSize),
        BackgroundTransparency = 1, ZIndex = 3,
    })
    row.Parent = parent
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    }).Parent = row

    local map = {}
    local function rebuild()
        for _, s in pairs(map) do pcall(function() s.btn:Destroy() end) end
        map = {}
        local palette = getPalette()
        local current = getCurrent()
        for i, entry in ipairs(palette) do
            local swatch = new("TextButton", {
                Size = UDim2.new(0, swatchSize, 0, swatchSize),
                BackgroundColor3 = entry.color, BackgroundTransparency = 0,
                Text = "", AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = i, ZIndex = 3,
            })
            round(swatch, 6)
            local st = new("UIStroke", {
                Thickness = 1, Transparency = 0.6,
                Color = Color3.fromRGB(255, 255, 255),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            st.Parent = swatch
            swatch.Parent = row
            local isCur = (entry.name == current)
            st.Transparency = isCur and 0 or 0.6
            st.Thickness = isCur and 2 or 1
            map[entry.name] = { btn = swatch, stroke = st, entry = entry }
            swatch.MouseButton1Click:Connect(function()
                for _, s in pairs(map) do
                    local cur = (s.entry.name == entry.name)
                    s.stroke.Transparency = cur and 0 or 0.6
                    s.stroke.Thickness = cur and 2 or 1
                end
                if onSelect then onSelect(entry.name, entry.color) end
            end)
        end
    end
    rebuild()
    return rebuild
end

--=============================================================
-- MAIN PAGE
--=============================================================
local mainPage = makePage("MAIN")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}).Parent = mainPage

do
    local card = makeRow(mainPage, 1, "SPEED WALK", "ускоряет ходьбу · 8–500")
    local box = new("TextBox", {
        Position = UDim2.new(1, -126, 0, 12),
        Size = UDim2.new(0, 58, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(Speed.Value), TextColor3 = P.Text,
        Font = Enum.Font.Code, TextSize = 11,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true, ZIndex = 3,
    })
    round(box, 7); box.Parent = card
    reg(box, "BackgroundColor3", "Bg"); reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then Speed.Value = math.clamp(math.floor(n), 8, 500) end
        box.Text = tostring(Speed.Value)
        logScript("Speed value = " .. tostring(Speed.Value))
    end)

    makeSwitch(card, 12, function(v)
        Speed.Enabled = v
        if not v then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        logScript("Speed " .. (v and "ON" or "OFF"))
    end)
end

do
    local card = makeRow(mainPage, 2, "ANTI-FLING", "гасит раскрутку от чужих эксплойтов")
    makeSwitch(card, 12, function(v)
        AntiFling.Enabled = v
        logScript("Anti-Fling " .. (v and "ON" or "OFF"))
    end)
end

do
    local card = makeRow(mainPage, 3, "REJOIN", "переподключение к текущему серверу", 58)
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "REJOIN", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3,
    })
    round(btn, 8); btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        logScript("Rejoin initiated")
        pcall(function() TeleportSvc:Teleport(game.PlaceId, LP) end)
    end)
end

do
    local card = makeRow(mainPage, 4, "SERVER HOP", "переброс на другой сервер этой игры", 58)
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "HOP TO RANDOM SERVER", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3,
    })
    round(btn, 8); btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        task.spawn(serverHop)
    end)
end

do
    local card = makeRow(mainPage, 5, "EMPTY HOP", "ищет сервер с 0 игроков (или с минимальным онлайном)", 58)
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Color3.fromRGB(80, 220, 100), BackgroundTransparency = 0.2,
        Text = "HOP TO EMPTY SERVER", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3,
    })
    round(btn, 8); btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        task.spawn(emptyHop)
    end)
end

--=============================================================
-- LOG PAGE
--=============================================================
local logPage = makePage("LOG")
logPage.ScrollingDirection = Enum.ScrollingDirection.X
logPage.AutomaticCanvasSize = Enum.AutomaticSize.None
logPage.CanvasSize = UDim2.new(1, 0, 1, 0)
logPage.ElasticBehavior = Enum.ElasticBehavior.Never
logPage.ScrollingEnabled = false

local logBorder = new("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, -34),
    BackgroundColor3 = Color3.new(1,1,1),
    BorderSizePixel = 0, ZIndex = 1,
})
round(logBorder, 14)
local logBorderGrad = new("UIGradient", { Color = FlowColors, Rotation = 0 })
logBorderGrad.Parent = logBorder
registerGrad(logBorderGrad, 25)
logBorder.Parent = logPage

local logViewport = new("Frame", {
    Position = UDim2.new(0, 2, 0, 2),
    Size = UDim2.new(1, -4, 1, -4),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, ZIndex = 2,
})
round(logViewport, 12)
logViewport.Parent = logBorder
reg(logViewport, "BackgroundColor3", "Card")

local logScroll = new("ScrollingFrame", {
    Position = UDim2.new(0, 10, 0, 10),
    Size = UDim2.new(1, -20, 1, -20),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Accent.Main,
    ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 3,
})
logScroll.Parent = logViewport
local logLayout = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
logLayout.Parent = logScroll

-- 5 buttons in bottom row
local serverTabBtn = new("TextButton", {
    Position = UDim2.new(0.00, 0, 1, -28),
    Size = UDim2.new(0.24, -2, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "SERVER", TextColor3 = P.SubText,
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(serverTabBtn, 9); gradientStroke(serverTabBtn, 2, 0.5, 30); serverTabBtn.Parent = logPage

local scriptTabBtn = new("TextButton", {
    Position = UDim2.new(0.24, 0, 1, -28),
    Size = UDim2.new(0.24, -2, 0, 28),
    BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.05,
    Text = "SCRIPT", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(scriptTabBtn, 9); gradientStroke(scriptTabBtn, 2, 0.3, 30); scriptTabBtn.Parent = logPage

local filterBtn = new("TextButton", {
    Position = UDim2.new(0.48, 0, 1, -28),
    Size = UDim2.new(0.18, -2, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "FILTER", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(filterBtn, 9); gradientStroke(filterBtn, 2, 0.5, 30); filterBtn.Parent = logPage
reg(filterBtn, "BackgroundColor3", "Card"); reg(filterBtn, "TextColor3", "Text")

local copyBtn = new("TextButton", {
    Position = UDim2.new(0.66, 2, 1, -28),
    Size = UDim2.new(0.16, -2, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "COPY", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(copyBtn, 9); gradientStroke(copyBtn, 2, 0.5, 30); copyBtn.Parent = logPage
reg(copyBtn, "BackgroundColor3", "Card"); reg(copyBtn, "TextColor3", "Text")

local clearBtn = new("TextButton", {
    Position = UDim2.new(0.82, 4, 1, -28),
    Size = UDim2.new(0.18, -4, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "CLR", TextColor3 = Color3.fromRGB(255, 90, 90),
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(clearBtn, 9); gradientStroke(clearBtn, 2, 0.5, 30); clearBtn.Parent = logPage
reg(clearBtn, "BackgroundColor3", "Card")

table.insert(LogTabButtons, { name = "server", btn = serverTabBtn })
table.insert(LogTabButtons, { name = "script", btn = scriptTabBtn })

local logLineCache = {}

local function renderLog()
    local buf = Logger.buffer[Logger.activeTab]
    if #buf == 0 then
        for _, lbl in ipairs(logLineCache) do pcall(function() lbl:Destroy() end) end
        logLineCache = {}
        return
    end
    while #logLineCache < #buf do
        local lbl = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1, Text = "",
            TextColor3 = P.Text, Font = Enum.Font.Code, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #logLineCache + 1, ZIndex = 3,
        })
        lbl.Parent = logScroll
        table.insert(logLineCache, lbl)
        reg(lbl, "TextColor3", "Text")
    end
    for i, lbl in ipairs(logLineCache) do
        if i <= #buf then lbl.Text = buf[i]; lbl.Visible = true else lbl.Visible = false end
    end
    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, math.max(0, logLayout.AbsoluteContentSize.Y - logScroll.AbsoluteSize.Y))
    end)
end

local function switchLogTab(which)
    Logger.activeTab = which
    for _, entry in ipairs(LogTabButtons) do
        local active = (entry.name == which)
        entry.btn.BackgroundColor3 = active and Accent.Main or P.Card
        entry.btn.BackgroundTransparency = active and 0.05 or 0.15
        entry.btn.TextColor3 = active and Color3.fromRGB(255,255,255) or P.SubText
    end
    renderLog()
end

serverTabBtn.MouseButton1Click:Connect(function() switchLogTab("server") end)
scriptTabBtn.MouseButton1Click:Connect(function() switchLogTab("script") end)

copyBtn.MouseButton1Click:Connect(function()
    local text = buildLogText()
    local ok = copyToClipboard(text)
    if ok then
        copyBtn.Text = "OK"
        task.delay(1.0, function() copyBtn.Text = "COPY" end)
        logScript("Logs copied (" .. #text .. " bytes)")
    else
        copyBtn.Text = "ERR"
        task.delay(1.0, function() copyBtn.Text = "COPY" end)
        logScript("Copy failed — no clipboard fn")
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    Logger.buffer.server = {}
    Logger.buffer.script = {}
    renderLog()
end)

table.insert(Logger.listeners, function(channel)
    if channel == Logger.activeTab then renderLog() end
end)

--=============================================================
-- COMBAT PAGE
--=============================================================
local combatPage = makePage("COMBAT")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}).Parent = combatPage

-- HITBOX
do
    local card = makeRow(combatPage, 1, "HITBOX CHANGER",
        "увеличивает хитбокс игроков · VIEW показать границы", 100)

    local box = new("TextBox", {
        Position = UDim2.new(1, -126, 0, 46),
        Size = UDim2.new(0, 58, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(HitboxChanger.Size), TextColor3 = P.Text,
        Font = Enum.Font.Code, TextSize = 11,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true, ZIndex = 3,
    })
    round(box, 7); box.Parent = card
    reg(box, "BackgroundColor3", "Bg"); reg(box, "TextColor3", "Text")

    local viewBtn
    local viewState = false
    local function setView(v)
        viewState = v
        HitboxChanger.View = v
        if v then
            tween(viewBtn, 0.22, { BackgroundColor3 = Accent.Main, TextColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.15 })
            applyAllHitboxViews()
        else
            tween(viewBtn, 0.22, { BackgroundColor3 = P.Card, TextColor3 = P.SubText, BackgroundTransparency = 0.3 })
            removeAllHitboxViews()
        end
        logScript("Hitbox View " .. (v and "ON" or "OFF"))
    end

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            HitboxChanger.Size = math.clamp(math.floor(n), 1, 50)
            if HitboxChanger.Enabled then restoreAllHitboxes(); applyAllHitboxes() end
            if viewState then refreshAllHitboxViews() end
            logScript("Hitbox size = " .. tostring(HitboxChanger.Size))
        end
        box.Text = tostring(HitboxChanger.Size)
    end)

    makeSwitch(card, 46, function(v)
        HitboxChanger.Enabled = v
        if v then
            applyAllHitboxes()
        else
            restoreAllHitboxes()
            if viewState then setView(false) end
        end
        logScript("Hitbox " .. (v and "ON" or "OFF"))
    end)

    viewBtn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 72),
        Size = UDim2.new(0, 78, 0, 22),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.3,
        Text = "VIEW", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3,
    })
    round(viewBtn, 7); gradientStroke(viewBtn, 2, 0.5, 30); viewBtn.Parent = card
    reg(viewBtn, "BackgroundColor3", "Card")
    viewBtn.MouseButton1Click:Connect(function() setView(not viewState) end)
end

-- ESP
local setESPEnabled, setESPVis
do
    local card = makeRow(combatPage, 2, "ESP",
        "подсвечивает игроков · зелёный = виден из-за стены", 180)

    setESPEnabled = makeSwitch(card, 12, function(v)
        ESP.Enabled = v
        refreshAllESP()
        logScript("ESP " .. (v and "ON" or "OFF"))
    end)

    local visLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 74),
        Size = UDim2.new(1, -100, 0, 16),
        Text = "VISIBILITY  (green = line of sight)",
        TextColor3 = P.SubText, Font = Enum.Font.GothamMedium, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    })
    visLbl.Parent = card
    reg(visLbl, "TextColor3", "SubText")

    local rebuildESPPalette
    setESPVis = makeSwitch(card, 74, function(v)
        ESP.VisibilityCheck = v
        reapplyAllESPStyles()
        if rebuildESPPalette then rebuildESPPalette() end
        logScript("ESP visibility " .. (v and "ON" or "OFF"))
    end)

    local palLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 124),
        Size = UDim2.new(1, -24, 0, 14),
        Text = "COLOR",
        TextColor3 = P.SubText, Font = Enum.Font.GothamMedium, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    })
    palLbl.Parent = card
    reg(palLbl, "TextColor3", "SubText")

    rebuildESPPalette = makeColorPaletteDynamic(
        card, 142,
        function()
            -- GREEN swatch only when VisibilityCheck is ON
            local list = {}
            for _, e in ipairs(ESP_PALETTE) do table.insert(list, e) end
            return list
        end,
        function() return ESP.ColorName end,
        function(name, color)
            ESP.Color = color
            ESP.ColorName = name
            reapplyAllESPStyles()
            logScript("ESP color = " .. name)
        end,
        22
    )
end

-- AIMBOT compact row + ⚙
do
    local card = makeRow(combatPage, 3, "AIMBOT",
        "жёсткий лок на голову · настройки в ⚙", 68)

    local aimGear = new("TextButton", {
        Position = UDim2.new(1, -126, 0, 40),
        Size = UDim2.new(0, 28, 0, 22),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
        Text = "⚙", TextColor3 = P.Text,
        Font = Enum.Font.GothamBold, TextSize = 12,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3,
    })
    round(aimGear, 7); aimGear.Parent = card
    reg(aimGear, "BackgroundColor3", "Card"); reg(aimGear, "TextColor3", "Text")

    local statusLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 40),
        Size = UDim2.new(1, -140, 0, 22),
        Text = "FOV " .. Aimbot.FOV .. "px · " .. Aimbot.ColorName,
        TextColor3 = P.SubText, Font = Enum.Font.Code, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    })
    statusLbl.Parent = card
    reg(statusLbl, "TextColor3", "SubText")

    _G.MerediosUpdateAimStatus = function()
        statusLbl.Text = "FOV " .. Aimbot.FOV .. "px · " .. Aimbot.ColorName ..
            (Aimbot.VisibleOnly and " · visible-only" or "")
    end

    aimGear.MouseButton1Click:Connect(function() _G.MerediosOpenAimSettings() end)

    makeSwitch(card, 12, function(v)
        Aimbot.Enabled = v
        if not v then
            Aimbot.MoveAccum = 0
            Aimbot.LockedTarget = nil
        end
        logScript("Aimbot " .. (v and "ON" or "OFF"))
    end)
end

--=============================================================
-- NEW PAGE
--=============================================================
local newPage = makePage("NEW")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}).Parent = newPage

do
    local card = makeRow(newPage, 1, "ОБНОВЛЕНИЕ v8.5",
        "t.me//meredioshub — все апдейты и сборки там.", 300)

    local body = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 52),
        Size = UDim2.new(1, -36, 0, 240),
        Text = table.concat({
            "• Aimbot sticky-lock — цель держится",
            "  пока жива и не ушла из зоны; отпуск",
            "  только по большому движению камеры",
            "• Aimbot игнорирует мёртвых",
            "• Aimbot bind на приоритет +10 —",
            "  перебивает стандартный camera",
            "• FOV ring изначально ПОД меню,",
            "  всплывает НАД, когда тянешь слайдер",
            "• ESP палитра компактнее, 22px",
            "• ESP visibility по умолчанию OFF",
            "• Логгер ловит все FireServer/",
            "  InvokeServer через mt.__namecall",
            "• Фильтр логов: список ремоутов",
            "  с ✓/✗ — ✗ скрывает из логов",
            "• Чат-лог (OnMessageDoneFiltering)",
            "• Карточки через бордер-обёртку —",
            "  обводка покрывает полностью",
            "• Переливание градиентов на каждой",
            "  карточке и меню (авто-ротация)",
            "• ServerHop — случайный сервер",
            "• EmptyHop — сервер с 0 игроков",
            "• Telegram: t.me//meredioshub",
        }, "\n"),
        TextColor3 = P.Text,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, ZIndex = 3,
    })
    body.Parent = card
    reg(body, "TextColor3", "Text")
end

do
    local card = makeRow(newPage, 2, "TELEGRAM", "t.me//meredioshub", 60)
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 44),
        Size = UDim2.new(1, -24, 0, 22),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "СКОПИРОВАТЬ t.me//meredioshub", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 3,
    })
    round(btn, 8); btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        logScript("TG link copied")
        copyToClipboard("t.me//meredioshub")
        btn.Text = "СКОПИРОВАНО"
        task.delay(1.2, function() btn.Text = "СКОПИРОВАТЬ t.me//meredioshub" end)
    end)
end

--=============================================================
-- AIM SETTINGS PANEL
--=============================================================
local AIM_W, AIM_H = 380, 340

local aimPanel = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, AIM_W, 0, AIM_H),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 10,
})
round(aimPanel, 16)
local aimPanelStroke = gradientStroke(aimPanel, 2.5, 0.08, 30)
aimPanelStroke.Transparency = 1
aimPanel.Parent = menu
reg(aimPanel, "BackgroundColor3", "BgGlass")

local apTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 14),
    Size = UDim2.new(1, -70, 0, 16),
    Text = "AIM SETTINGS · t.me//meredioshub",
    TextColor3 = P.Text, Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
})
apTitle.Parent = aimPanel
reg(apTitle, "TextColor3", "Text")

local apClose = new("TextButton", {
    Position = UDim2.new(1, -38, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 16,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 11,
})
round(apClose, 8); apClose.Parent = aimPanel
reg(apClose, "BackgroundColor3", "Card"); reg(apClose, "TextColor3", "Text")

-- FOV slider with z-index lift on drag
local fovLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 52),
    Size = UDim2.new(1, -36, 0, 14),
    Text = "FOV RADIUS  (drag — ring comes to front)",
    TextColor3 = P.SubText, Font = Enum.Font.GothamBold, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
})
fovLbl.Parent = aimPanel
reg(fovLbl, "TextColor3", "SubText")

local fovSliderHost = new("Frame", {
    Position = UDim2.new(0, 0, 0, 70),
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1, ZIndex = 11,
})
fovSliderHost.Parent = aimPanel

makeSlider(fovSliderHost, 6, 40, 400, Aimbot.FOV, function(v)
    Aimbot.FOV = v
    updateFOVCircle()
    if _G.MerediosUpdateAimStatus then _G.MerediosUpdateAimStatus() end
end, -84,
function()
    -- drag start: bring FOV ring above GUI
    fovWrap.ZIndex = 6000
    fovCircle.ZIndex = 1
end,
function()
    -- drag end: push back below GUI
    fovWrap.ZIndex = 0
end)

-- FOV color
local fovColLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 108),
    Size = UDim2.new(1, -36, 0, 14),
    Text = "FOV COLOR  ·  white gets black outline",
    TextColor3 = P.SubText, Font = Enum.Font.GothamBold, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
})
fovColLbl.Parent = aimPanel
reg(fovColLbl, "TextColor3", "SubText")

local AIM_PALETTE = {
    { name = "WHITE",  color = Color3.fromRGB(255,255,255) },
    { name = "BLUE",   color = Color3.fromRGB(30, 64, 175) },
    { name = "NAVY",   color = Color3.fromRGB(15, 40, 120) },
    { name = "CYAN",   color = Color3.fromRGB(0, 210, 255) },
    { name = "RED",    color = Color3.fromRGB(255, 60, 60) },
    { name = "GREEN",  color = Color3.fromRGB(80, 220, 100) },
    { name = "YELLOW", color = Color3.fromRGB(255, 220, 60) },
    { name = "PURPLE", color = Color3.fromRGB(160, 95, 255) },
    { name = "PINK",   color = Color3.fromRGB(255, 95, 175) },
}

local fovPalHost = new("Frame", {
    Position = UDim2.new(0, 0, 0, 128),
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundTransparency = 1, ZIndex = 11,
})
fovPalHost.Parent = aimPanel

makeColorPaletteDynamic(fovPalHost, 0,
    function() return AIM_PALETTE end,
    function() return Aimbot.ColorName end,
    function(name, color)
        setAimbotColor(name, color)
        if _G.MerediosUpdateAimStatus then _G.MerediosUpdateAimStatus() end
        logScript("Aimbot FOV color = " .. name)
    end,
    24
)

-- ONLY IN FOV
local onlyRow = new("Frame", {
    Position = UDim2.new(0, 14, 0, 172),
    Size = UDim2.new(1, -28, 0, 64),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.08,
    BorderSizePixel = 0, ZIndex = 11,
})
round(onlyRow, 12)
gradientStroke(onlyRow, 2.5, 0.12, 35)
onlyRow.Parent = aimPanel
reg(onlyRow, "BackgroundColor3", "Card")

local onlyTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 8),
    Size = UDim2.new(1, -60, 0, 16),
    Text = "ONLY IN FOV",
    TextColor3 = P.Text, Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
})
onlyTitle.Parent = onlyRow
reg(onlyTitle, "TextColor3", "Text")

local onlySub = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 26),
    Size = UDim2.new(1, -24, 0, 32),
    Text = "aimbot fires only at visible targets.\nturning on forces ESP + visibility.",
    TextColor3 = P.SubText, Font = Enum.Font.Gotham, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true, ZIndex = 12,
})
onlySub.Parent = onlyRow
reg(onlySub, "TextColor3", "SubText")

local function setOnlyInFOV(v)
    Aimbot.VisibleOnly = v
    if v then
        if setESPEnabled then setESPEnabled(true) end
        if setESPVis then setESPVis(true) end
    end
    if _G.MerediosUpdateAimStatus then _G.MerediosUpdateAimStatus() end
    logScript("Only-in-FOV " .. (v and "ON" or "OFF"))
end

makeSwitch(onlyRow, 22, setOnlyInFOV)

--=============================================================
-- FILTER PANEL (log filters)
--=============================================================
local FLT_W, FLT_H = 340, 320

local filterPanel = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, FLT_W, 0, FLT_H),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 12,
})
round(filterPanel, 16)
local filterPanelStroke = gradientStroke(filterPanel, 2.5, 0.08, 30)
filterPanelStroke.Transparency = 1
filterPanel.Parent = menu
reg(filterPanel, "BackgroundColor3", "BgGlass")

local fpTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 14),
    Size = UDim2.new(1, -70, 0, 16),
    Text = "LOG FILTERS · remotes",
    TextColor3 = P.Text, Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
})
fpTitle.Parent = filterPanel
reg(fpTitle, "TextColor3", "Text")

local fpClose = new("TextButton", {
    Position = UDim2.new(1, -38, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 16,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 13,
})
round(fpClose, 8); fpClose.Parent = filterPanel
reg(fpClose, "BackgroundColor3", "Card"); reg(fpClose, "TextColor3", "Text")

local fpHint = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 36),
    Size = UDim2.new(1, -36, 0, 24),
    Text = "✓ = log shown    ✗ = hidden",
    TextColor3 = P.SubText, Font = Enum.Font.Gotham, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true, ZIndex = 13,
})
fpHint.Parent = filterPanel
reg(fpHint, "TextColor3", "SubText")

-- bulk buttons
local fpShowAll = new("TextButton", {
    Position = UDim2.new(0, 18, 0, 64),
    Size = UDim2.new(0.48, -10, 0, 24),
    BackgroundColor3 = Color3.fromRGB(80, 220, 100), BackgroundTransparency = 0.2,
    Text = "SHOW ALL", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 13,
})
round(fpShowAll, 7); fpShowAll.Parent = filterPanel

local fpHideAll = new("TextButton", {
    Position = UDim2.new(0.52, 2, 0, 64),
    Size = UDim2.new(0.48, -10, 0, 24),
    BackgroundColor3 = Color3.fromRGB(255, 90, 90), BackgroundTransparency = 0.2,
    Text = "HIDE ALL", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 13,
})
round(fpHideAll, 7); fpHideAll.Parent = filterPanel

local fpScrollWrap = new("Frame", {
    Position = UDim2.new(0, 18, 0, 96),
    Size = UDim2.new(1, -36, 1, -108),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.03,
    BorderSizePixel = 0, ZIndex = 13,
})
round(fpScrollWrap, 10)
gradientStroke(fpScrollWrap, 2, 0.3, 35)
fpScrollWrap.Parent = filterPanel
reg(fpScrollWrap, "BackgroundColor3", "Card")

local fpScroll = new("ScrollingFrame", {
    Position = UDim2.new(0, 6, 0, 6),
    Size = UDim2.new(1, -12, 1, -12),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Accent.Main,
    ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 14,
})
fpScroll.Parent = fpScrollWrap
local fpLayout = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
fpLayout.Parent = fpScroll

local fpEmptyLbl = new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "(no remotes captured yet)",
    TextColor3 = P.SubText, Font = Enum.Font.Code, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    LayoutOrder = 0, ZIndex = 14,
})
fpEmptyLbl.Parent = fpScroll
reg(fpEmptyLbl, "TextColor3", "SubText")

local fpRows = {}

local function rebuildFilters()
    for _, r in pairs(fpRows) do pcall(function() r.container:Destroy() end) end
    fpRows = {}

    local names = {}
    for n, _ in pairs(Logger.knownRemotes) do table.insert(names, n) end
    table.sort(names)

    if #names == 0 then
        fpEmptyLbl.Visible = true
        return
    end
    fpEmptyLbl.Visible = false

    for i, name in ipairs(names) do
        local container = new("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = P.Bg, BackgroundTransparency = 0.35,
            BorderSizePixel = 0, LayoutOrder = i, ZIndex = 14,
        })
        round(container, 6)
        container.Parent = fpScroll

        local nameLbl = new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Text = name,
            TextColor3 = P.Text, Font = Enum.Font.Code, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15,
        })
        nameLbl.Parent = container
        reg(nameLbl, "TextColor3", "Text")

        local state = (Logger.filters[name] ~= false)
        local toggle = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.new(0, 26, 0, 20),
            BackgroundColor3 = state and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(255, 90, 90),
            BackgroundTransparency = 0.15,
            Text = state and "✓" or "✗",
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.GothamBold, TextSize = 12,
            AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 15,
        })
        round(toggle, 6)
        toggle.Parent = container

        toggle.MouseButton1Click:Connect(function()
            local cur = (Logger.filters[name] ~= false)
            local nxt = not cur
            Logger.filters[name] = nxt
            toggle.BackgroundColor3 = nxt and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(255, 90, 90)
            toggle.Text = nxt and "✓" or "✗"
            logScript("Filter " .. name .. " = " .. (nxt and "shown" or "hidden"))
        end)

        fpRows[name] = { container = container, toggle = toggle }
    end
end

fpShowAll.MouseButton1Click:Connect(function()
    for name, _ in pairs(Logger.knownRemotes) do Logger.filters[name] = true end
    rebuildFilters()
    logScript("All remotes shown")
end)

fpHideAll.MouseButton1Click:Connect(function()
    for name, _ in pairs(Logger.knownRemotes) do Logger.filters[name] = false end
    rebuildFilters()
    logScript("All remotes hidden")
end)

table.insert(Logger.filterListeners, function()
    if filterPanel.Visible then rebuildFilters() end
end)

--=============================================================
-- THEME SETTINGS PANEL
--=============================================================
local settings = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 320, 0, 250),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 5,
})
round(settings, 16)
local settingsStroke = gradientStroke(settings, 2.5, 0.12, 30)
settingsStroke.Transparency = 1
settings.Parent = menu
reg(settings, "BackgroundColor3", "BgGlass")

local sTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 14),
    Size = UDim2.new(1, -70, 0, 16),
    Text = "SETTINGS · t.me//meredioshub", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
})
sTitle.Parent = settings
reg(sTitle, "TextColor3", "Text")

local sClose = new("TextButton", {
    Position = UDim2.new(1, -38, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 16,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 6,
})
round(sClose, 8); sClose.Parent = settings
reg(sClose, "BackgroundColor3", "Card"); reg(sClose, "TextColor3", "Text")

local function sRow(y, titleText)
    local row = new("Frame", {
        Position = UDim2.new(0, 18, 0, y),
        Size = UDim2.new(1, -36, 0, 32),
        BackgroundTransparency = 1, ZIndex = 6,
    })
    row.Parent = settings
    local lbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Text = titleText, TextColor3 = P.SubText,
        Font = Enum.Font.GothamMedium, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
    })
    lbl.Parent = row
    reg(lbl, "TextColor3", "SubText")
    return row
end

local function segControl(parent, options, current, onSelect)
    local seg = new("Frame", {
        Position = UDim2.new(0, 90, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -90, 0, 26),
        BackgroundTransparency = 1, ZIndex = 6,
    })
    seg.Parent = parent
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }).Parent = seg

    local btns = {}
    local currentVal = current
    local function refresh(sel)
        currentVal = sel
        for k, b in pairs(btns) do
            local on = k == sel
            tween(b, 0.22, {
                BackgroundTransparency = on and 0.05 or 0.82,
                TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText,
            })
        end
    end
    for i, opt in ipairs(options) do
        local b = new("TextButton", {
            Size = UDim2.new(0, 56, 1, 0),
            BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.82,
            Text = opt, TextColor3 = P.SubText,
            Font = Enum.Font.GothamBold, TextSize = 8,
            AutoButtonColor = false, BorderSizePixel = 0,
            LayoutOrder = i, ZIndex = 6,
        })
        round(b, 7); b.Parent = seg
        btns[opt] = b
        b.MouseButton1Click:Connect(function() refresh(opt); if onSelect then onSelect(opt) end end)
    end
    refresh(current)
    table.insert(SegRegistry, {
        btns = btns,
        get_current = function() return currentVal end,
        refresh = refresh,
    })
    return seg, refresh
end

local row1 = sRow(52, "THEME")
segControl(row1, { "LIGHT", "DARK" }, Theme.mode:upper(), function(v)
    Theme.mode = v == "DARK" and "Dark" or "Light"; applyTheme()
end)

local row2 = sRow(90, "ACCENT")
segControl(row2, { "DARKBLUE", "NAVY", "CYAN", "PURPLE", "PINK" }, "DARKBLUE", function(v)
    local map = { DARKBLUE = "DarkBlue", NAVY = "Navy", CYAN = "Cyan", PURPLE = "Purple", PINK = "Pink" }
    Theme.accent = map[v] or "DarkBlue"
    refreshPalettes(); applyTheme()
end)

local row3 = sRow(128, "ANIMATIONS")
segControl(row3, { "ON", "OFF" }, "ON", function(v) Theme.anim = (v == "ON") end)

--=============================================================
-- M BUTTON
--=============================================================
local mBtn = new("TextButton", {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 60, 0.35, 0),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.08,
    Text = "M", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 20,
    AutoButtonColor = false, BorderSizePixel = 0, Visible = false,
})
round(mBtn, 26)
mBtn.Parent = ScreenGui
reg(mBtn, "BackgroundColor3", "BgGlass")
reg(mBtn, "TextColor3", "Text")

local mBtnStroke = new("UIStroke", {
    Thickness = 2.5, Transparency = 0.05,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
    Color = Color3.new(1, 1, 1),
})
mBtnStroke.Parent = mBtn
local mBtnGrad = new("UIGradient", { Color = BluePinkSeq, Rotation = 30 })
mBtnGrad.Parent = mBtnStroke
registerGrad(mBtnGrad, 90)

local mGlow = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 12, 1, 12),
    BackgroundTransparency = 1, ZIndex = mBtn.ZIndex - 1,
})
round(mGlow, 30)
local mGlowStroke = new("UIStroke", {
    Thickness = 2, Transparency = 0.75,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
    Color = Color3.new(1, 1, 1),
})
mGlowStroke.Parent = mGlow
local mGlowGrad = new("UIGradient", { Color = BluePinkSeq, Rotation = 30 })
mGlowGrad.Parent = mGlowStroke
registerGrad(mGlowGrad, 60)
mGlow.Parent = mBtn

task.spawn(function()
    while mGlow.Parent do
        tween(mGlowStroke, 1.4, { Transparency = 0.55 }, Enum.EasingStyle.Sine)
        task.wait(1.4)
        if not mGlow.Parent then break end
        tween(mGlowStroke, 1.4, { Transparency = 0.85 }, Enum.EasingStyle.Sine)
        task.wait(1.4)
    end
end)

local tapHint = new("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 1, 8),
    Size = UDim2.new(0, 150, 0, 26),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 1,
    Text = "2 times to open",
    TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 11,
    BorderSizePixel = 0, TextTransparency = 1, Visible = false, ZIndex = 60,
})
round(tapHint, 9)
local tapHintStroke = new("UIStroke", {
    Thickness = 2, Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1, 1, 1),
})
tapHintStroke.Parent = tapHint
new("UIGradient", { Color = BluePinkSeq, Rotation = 30 }).Parent = tapHintStroke
tapHint.Parent = mBtn
reg(tapHint, "BackgroundColor3", "BgGlass")
reg(tapHint, "TextColor3", "Text")

local function showTapHint()
    tapHint.Visible = true
    tapHint.TextTransparency = 1
    tapHint.BackgroundTransparency = 1
    tapHintStroke.Transparency = 1
    tween(tapHint, 0.15, { TextTransparency = 0, BackgroundTransparency = 0.1 }, Enum.EasingStyle.Quint)
    tween(tapHintStroke, 0.15, { Transparency = 0.3 }, Enum.EasingStyle.Quint)
end

local function hideTapHint()
    tween(tapHint, 0.20, { TextTransparency = 1, BackgroundTransparency = 1 }, Enum.EasingStyle.Quint)
    tween(tapHintStroke, 0.20, { Transparency = 1 }, Enum.EasingStyle.Quint)
    task.delay(0.20, function()
        if tapHint.TextTransparency > 0.99 then tapHint.Visible = false end
    end)
end

do
    local dragging, dragStart, startAbs, moved = false, nil, nil, false
    local tapCount = 0
    local lastTapTime = 0
    local TAP_WINDOW = 1.5

    mBtn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position
            startAbs = mBtn.AbsolutePosition
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
            if not moved then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local vp = cam.ViewportSize
            local newX = math.clamp(startAbs.X + d.X, 0, vp.X - 52)
            local newY = math.clamp(startAbs.Y + d.Y, 0, vp.Y - 52)
            mBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    local function handleTap()
        local now = tick()
        if now - lastTapTime > TAP_WINDOW then tapCount = 0 end
        tapCount = tapCount + 1
        lastTapTime = now
        if tapCount >= 2 then
            tapCount = 0
            hideTapHint()
            if _G.MerediosMorph then _G.MerediosMorph() end
            return
        end
        showTapHint()
        local myStamp = now
        task.delay(TAP_WINDOW, function()
            if lastTapTime == myStamp and tapCount == 1 then
                tapCount = 0
                hideTapHint()
            end
        end)
    end

    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
            if not moved then handleTap() end
        end
    end)
end

--=============================================================
-- PANEL OPEN/CLOSE
--=============================================================
local morphing = false
local started  = false
local closeToken = 0

local function openMenu()
    menu.Visible = true
    menu.GroupTransparency = 1
    menu.BackgroundTransparency = 0.04
    menuStroke.Transparency = 1
    tween(menu, 0.35, { GroupTransparency = 0 })
    tween(menuStroke, 0.35, { Transparency = 0.05 })
    task.defer(function() animatePageIn(contentPages[activeTab]) end)
end

local function hideAllPanels()
    _G.MerediosSettingsOpen = false
    settings.Visible = false
    aimPanel.Visible = false
    filterPanel.Visible = false
end

local function closeMenu()
    hideAllPanels()
    closeToken = closeToken + 1
    local myToken = closeToken
    tween(menu, 0.30, { GroupTransparency = 1 })
    tween(menuStroke, 0.30, { Transparency = 1 })
    tween(settings, 0.30, { GroupTransparency = 1, BackgroundTransparency = 1 })
    tween(settingsStroke, 0.30, { Transparency = 1 })
    tween(aimPanel, 0.30, { GroupTransparency = 1, BackgroundTransparency = 1 })
    tween(aimPanelStroke, 0.30, { Transparency = 1 })
    tween(filterPanel, 0.30, { GroupTransparency = 1, BackgroundTransparency = 1 })
    tween(filterPanelStroke, 0.30, { Transparency = 1 })
    task.delay(0.30, function()
        if closeToken ~= myToken then return end
        menu.Visible = false
        menu.GroupTransparency = 0
        settings.GroupTransparency = 1
        settings.BackgroundTransparency = 0.02
        settingsStroke.Transparency = 0.12
        aimPanel.GroupTransparency = 1
        aimPanel.BackgroundTransparency = 0.02
        aimPanelStroke.Transparency = 0.08
        filterPanel.GroupTransparency = 1
        filterPanel.BackgroundTransparency = 0.02
        filterPanelStroke.Transparency = 0.08
        mBtn.Visible = true
        mBtn.BackgroundTransparency = 1
        mBtn.TextTransparency = 1
        tween(mBtn, 0.32, { BackgroundTransparency = 0.08, TextTransparency = 0 })
    end)
end

function _G.MerediosMorph()
    if not started or morphing or menu.Visible then return end
    morphing = true
    if tapHint.Visible then hideTapHint() end
    local originalSize = mBtn.Size
    local originalPos  = mBtn.Position
    local originalText = mBtn.Text

    tween(mBtn, 0.32, { Size = UDim2.new(0, 140, 0, 52) })
    task.wait(0.10)
    mBtn.Text = "MEREDIOS"; mBtn.TextSize = 14

    task.spawn(function()
        local t0 = tick()
        while tick() - t0 < 0.55 and mBtn.Parent do
            local phase = (tick() - t0) / 0.55
            mBtn.TextColor3 = BluePinkSeq:Evaluate(phase % 1)
            task.wait(0.03)
        end
    end)
    task.wait(0.55)

    tween(mBtn, 0.28, { BackgroundTransparency = 1, TextTransparency = 1 })
    tween(mBtnStroke, 0.28, { Transparency = 1 })
    tween(mGlowStroke, 0.28, { Transparency = 1 })
    task.wait(0.28)

    mBtn.Visible = false
    mBtn.BackgroundTransparency = 0.08
    mBtn.TextTransparency = 0
    mBtn.Text = originalText
    mBtn.TextSize = 20
    mBtn.Size = originalSize
    mBtn.Position = originalPos
    mBtn.TextColor3 = P.Text
    mBtnStroke.Transparency = 0.05
    mGlowStroke.Transparency = 0.75
    morphing = false
    openMenu()
end

closeBtn.MouseButton1Click:Connect(closeMenu)

-- AIM PANEL
local aimOpenToken = 0
function _G.MerediosOpenAimSettings()
    aimOpenToken = aimOpenToken + 1
    aimPanel.Visible = true
    aimPanel.GroupTransparency = 1
    aimPanel.BackgroundTransparency = 1
    aimPanelStroke.Transparency = 1
    aimPanel.Size = UDim2.new(0, AIM_W - 30, 0, AIM_H - 20)
    tween(aimPanel, 0.36, {
        GroupTransparency = 0,
        BackgroundTransparency = 0.02,
        Size = UDim2.new(0, AIM_W, 0, AIM_H),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(aimPanelStroke, 0.36, { Transparency = 0.08 })
    _G.MerediosSettingsOpen = true
end

apClose.MouseButton1Click:Connect(function()
    aimOpenToken = aimOpenToken + 1
    local myToken = aimOpenToken
    tween(aimPanel, 0.28, {
        GroupTransparency = 1, BackgroundTransparency = 1,
        Size = UDim2.new(0, AIM_W - 30, 0, AIM_H - 20),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(aimPanelStroke, 0.28, { Transparency = 1 })
    _G.MerediosSettingsOpen = false
    task.delay(0.28, function()
        if aimOpenToken ~= myToken then return end
        aimPanel.Visible = false
        aimPanel.Size = UDim2.new(0, AIM_W, 0, AIM_H)
        aimPanel.GroupTransparency = 0
        aimPanel.BackgroundTransparency = 0.02
        aimPanelStroke.Transparency = 0.08
    end)
end)

-- FILTER PANEL
local fltOpenToken = 0
filterBtn.MouseButton1Click:Connect(function()
    fltOpenToken = fltOpenToken + 1
    rebuildFilters()
    filterPanel.Visible = true
    filterPanel.GroupTransparency = 1
    filterPanel.BackgroundTransparency = 1
    filterPanelStroke.Transparency = 1
    filterPanel.Size = UDim2.new(0, FLT_W - 30, 0, FLT_H - 20)
    tween(filterPanel, 0.36, {
        GroupTransparency = 0,
        BackgroundTransparency = 0.02,
        Size = UDim2.new(0, FLT_W, 0, FLT_H),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(filterPanelStroke, 0.36, { Transparency = 0.08 })
    _G.MerediosSettingsOpen = true
end)

fpClose.MouseButton1Click:Connect(function()
    fltOpenToken = fltOpenToken + 1
    local myToken = fltOpenToken
    tween(filterPanel, 0.28, {
        GroupTransparency = 1, BackgroundTransparency = 1,
        Size = UDim2.new(0, FLT_W - 30, 0, FLT_H - 20),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(filterPanelStroke, 0.28, { Transparency = 1 })
    _G.MerediosSettingsOpen = false
    task.delay(0.28, function()
        if fltOpenToken ~= myToken then return end
        filterPanel.Visible = false
        filterPanel.Size = UDim2.new(0, FLT_W, 0, FLT_H)
        filterPanel.GroupTransparency = 0
        filterPanel.BackgroundTransparency = 0.02
        filterPanelStroke.Transparency = 0.08
    end)
end)

-- THEME PANEL
gearBtn.MouseButton1Click:Connect(function()
    _G.MerediosSettingsOpen = true
    settings.Visible = true
    settings.GroupTransparency = 1
    settings.BackgroundTransparency = 1
    settingsStroke.Transparency = 1
    settings.Size = UDim2.new(0, 280, 0, 220)
    settings.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(settings, 0.40, {
        GroupTransparency = 0,
        BackgroundTransparency = 0.02,
        Size = UDim2.new(0, 320, 0, 250),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(settingsStroke, 0.40, { Transparency = 0.12 })
end)

sClose.MouseButton1Click:Connect(function()
    _G.MerediosSettingsOpen = false
    local myToken = closeToken + 1
    closeToken = myToken
    tween(settings, 0.30, {
        GroupTransparency = 1, BackgroundTransparency = 1,
        Size = UDim2.new(0, 280, 0, 220),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(settingsStroke, 0.30, { Transparency = 1 })
    task.delay(0.30, function()
        if closeToken ~= myToken then return end
        settings.Visible = false
        settings.Size = UDim2.new(0, 320, 0, 250)
        settings.GroupTransparency = 0
        settings.BackgroundTransparency = 0.02
        settingsStroke.Transparency = 0.12
    end)
end)

-- ---------- STARTUP ----------
startBtn.MouseButton1Click:Connect(function()
    started = true
    tween(startup, 0.4, { GroupTransparency = 1 })
    tween(startupStroke, 0.4, { Transparency = 1 })
    task.delay(0.4, function()
        startup.Visible = false
        openMenu()
        logScript("Meredios HUD v8.5 started · t.me//meredioshub")
    end)
end)

-- ---------- FINAL STATE ----------
for _, e in ipairs(ThemeReg) do
    local inst, prop, key = e[1], e[2], e[3]
    if inst and inst.Parent then inst[prop] = P[key] end
end

menu.Visible = false
menu.GroupTransparency = 0
menu.BackgroundTransparency = 0.04
menuStroke.Transparency = 1
settings.Visible = false
settings.GroupTransparency = 1
settings.BackgroundTransparency = 0.02
settingsStroke.Transparency = 1
aimPanel.Visible = false
aimPanel.GroupTransparency = 1
aimPanel.BackgroundTransparency = 0.02
aimPanelStroke.Transparency = 1
filterPanel.Visible = false
filterPanel.GroupTransparency = 1
filterPanel.BackgroundTransparency = 0.02
filterPanelStroke.Transparency = 1
mBtn.Visible = false
startup.Visible = true
startup.GroupTransparency = 1
startupStroke.Transparency = 1

logScript("Kernel loaded · v8.5")
logScript("t.me//meredioshub")
logScript("Aimbot sticky-lock · FOV=" .. Aimbot.FOV .. " · " .. Aimbot.ColorName)
logScript("Remote logger armed · see FILTER to hide spam")
renderLog()

return true
