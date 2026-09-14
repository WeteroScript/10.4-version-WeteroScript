-- language: Lua, file: meredios.lua, target: Roblox / Delta X Mobile
-- v7.6: aimbot settings page, compact row layout, tab slide animations, FOV circle styling

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

local LP = Players.LocalPlayer
if not LP then repeat task.wait(0.1); LP = Players.LocalPlayer until LP end
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.4)

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

local GradientColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(30, 64, 175)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(90, 130, 240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(160, 95, 255)),
})

local BluePinkSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 45, 130)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(90, 130, 240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 95, 175)),
})

local P, Accent
local function refreshPalettes() P = Palettes[Theme.mode]; Accent = Accents[Theme.accent] end
refreshPalettes()

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
        Thickness = thickness or 1,
        Transparency = transparency or 0.05,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
        Color = Color3.new(1, 1, 1),
    })
    stroke.Parent = parent
    local grad = new("UIGradient", { Color = GradientColors, Rotation = rotation or 35 })
    grad.Parent = stroke
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
local LogTabButtons = {}

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
            if s.lbl then s.lbl.TextColor3 = s.state and Accent.Main or P.SubText end
        end
    end
    for _, entry in ipairs(LogTabButtons) do
        local active = (entry.name == Logger.activeTab)
        entry.btn.BackgroundColor3 = active and Accent.Main or P.Card
        entry.btn.TextColor3 = active and Color3.fromRGB(255,255,255) or P.SubText
    end
end

--=============================================================
-- LOGGER + CLIPBOARD
--=============================================================
local Logger = {
    buffer = { server = {}, script = {} },
    maxLen = 400,
    listeners = {},
    activeTab = "script",
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
    VisibilityCheck = true,
    Highlights = {},
    LastCheck = {},
    CheckInterval = 0.12,
}

local ESP_PALETTE = {
    { name = "PINK",   color = Color3.fromRGB(255, 95, 175) },
    { name = "RED",    color = Color3.fromRGB(255, 60, 60) },
    { name = "ORANGE", color = Color3.fromRGB(255, 140, 40) },
    { name = "YELLOW", color = Color3.fromRGB(255, 220, 60) },
    { name = "CYAN",   color = Color3.fromRGB(0, 210, 255) },
    { name = "BLUE",   color = Color3.fromRGB(30, 64, 175) },
    { name = "PURPLE", color = Color3.fromRGB(160, 95, 255) },
    { name = "WHITE",  color = Color3.fromRGB(255, 255, 255) },
}
local ESP_GREEN = { name = "GREEN", color = VISIBLE_COLOR }

local function espPaletteCurrent()
    local list = {}
    for _, e in ipairs(ESP_PALETTE) do table.insert(list, e) end
    if not ESP.VisibilityCheck then table.insert(list, ESP_GREEN) end
    return list
end

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
-- SPEED / ANTI-FLING
--=============================================================
local Speed = { Enabled = false, Value = 32 }

RunService.Heartbeat:Connect(function()
    if not Speed.Enabled then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= Speed.Value then hum.WalkSpeed = Speed.Value end
end)

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
-- WALLBANG + diagnostics
--=============================================================
local Wallbang = { Enabled = false, Active = false }
local RemoteDiag = { Enabled = false, Count = 0, Max = 80, Window = 0 }

local function fmtArg(a)
    local t = typeof(a)
    if t == "Vector3" then
        return string.format("V3(%.1f,%.1f,%.1f)", a.X, a.Y, a.Z)
    elseif t == "CFrame" then
        return "CFrame"
    elseif t == "Instance" then
        local ok, n = pcall(function() return a:GetFullName() end)
        return ok and n or "Instance"
    elseif t == "table" then
        return "{table}"
    else
        return tostring(a)
    end
end

local function logRemoteFire(self, args)
    if not RemoteDiag.Enabled then return end
    if RemoteDiag.Count >= RemoteDiag.Max then return end
    if tick() > RemoteDiag.Window then return end
    RemoteDiag.Count = RemoteDiag.Count + 1
    local parts = {}
    for i, a in ipairs(args) do parts[i] = fmtArg(a) end
    local full
    local ok = pcall(function() full = self:GetFullName() end)
    if not ok then full = "Unknown" end
    logScript("FireServer→" .. full .. " | " .. table.concat(parts, ", "))
end

local function buildWallbangParams(originalParams)
    local chars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(chars, p.Character) end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = chars
    params.IgnoreWater = true
    if originalParams then
        pcall(function() params.CollisionGroup = originalParams.CollisionGroup end)
    end
    return params
end

do
    local okMT, mt = pcall(function() return getrawmetatable(game) end)
    if okMT and mt and type(newcclosure) == "function" and type(setreadonly) == "function" then
        local oldNamecall = mt.__namecall
        if oldNamecall then
            pcall(setreadonly, mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod and getnamecallmethod() or nil
                if method == "FireServer" and RemoteDiag.Enabled then
                    logRemoteFire(self, {...})
                end
                if Wallbang.Enabled and Wallbang.Active and method == "Raycast" then
                    local ok, isWorkspace = pcall(function() return self == workspace end)
                    if ok and isWorkspace then
                        local origin, direction, params = ...
                        local newParams = buildWallbangParams(params)
                        logScript("WALLBANG Raycast intercepted")
                        return oldNamecall(self, origin, direction, newParams)
                    end
                end
                return oldNamecall(self, ...)
            end)
            pcall(setreadonly, mt, true)
            logScript("Hook armed · Raycast + FireServer diag")
        end
    else
        logScript("Hook unavailable — no metatable access")
    end
end

--=============================================================
-- AIMBOT v7.6
--=============================================================
local Aimbot = {
    Enabled = false,
    FOV = 140,
    Color = Color3.fromRGB(30, 64, 175),
    ReleaseThreshold = 45,
    ReleaseWindow = 0.12,
    MoveAccum = 0,
    LockReleaseUntil = 0,
    AdjustUntil = 0,
    Target = nil,
    ActiveGameTouch = nil,
    -- v7.6 settings
    OnlyVisible = false,      -- работа только при видимости цели
    ShowCircle = true,        -- показ FOV круга
}

local fovCircle = new("Frame", {
    Name = "MerediosFOVCircle",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, Aimbot.FOV * 2, 0, Aimbot.FOV * 2),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5000,
})
round(fovCircle, Aimbot.FOV)

-- основной обвод
local fovStroke = new("UIStroke", {
    Thickness = 3, Color = Aimbot.Color, Transparency = 0,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
})
fovStroke.Parent = fovCircle

-- внутренний glow
local fovGlow = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, -6, 1, -6),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5001,
})
round(fovGlow, Aimbot.FOV - 3)
local fovGlowStroke = new("UIStroke", {
    Thickness = 1, Color = Aimbot.Color, Transparency = 0.55,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
})
fovGlowStroke.Parent = fovGlow
fovGlow.Parent = fovCircle

-- чёрная обводка для белого цвета (внешняя тонкая)
local fovBlackStroke = new("UIStroke", {
    Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
})
fovBlackStroke.Parent = fovCircle

fovCircle.Parent = ScreenGui

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0, Aimbot.FOV * 2, 0, Aimbot.FOV * 2)
    local corner = fovCircle:FindFirstChildOfClass("UICorner")
    if corner then corner.CornerRadius = UDim.new(0, Aimbot.FOV) end
    fovGlow.Size = UDim2.new(1, -6, 1, -6)
    local gc = fovGlow:FindFirstChildOfClass("UICorner")
    if gc then gc.CornerRadius = UDim.new(0, Aimbot.FOV - 3) end
    fovStroke.Color = Aimbot.Color
    fovGlowStroke.Color = Aimbot.Color
    -- белый цвет → чёрная обводка снаружи
    local isWhite = (Aimbot.Color.R > 0.95 and Aimbot.Color.G > 0.95 and Aimbot.Color.B > 0.95)
    fovBlackStroke.Transparency = isWhite and 0 or 1
    fovBlackStroke.Thickness = isWhite and 2 or 1
end

local function getHeadPos(plr)
    local char = plr.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head.Position end
    return nil
end

local function findNearestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local best, bestDist = nil, Aimbot.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local pos = getHeadPos(plr)
            if pos then
                -- v7.6: фильтр видимости если включён OnlyVisible
                if Aimbot.OnlyVisible and ESP.VisibilityCheck then
                    if not hasLineOfSight(plr.Character) then continue end
                end
                local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                if onScreen and screenPos.Z > 0 then
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if d <= bestDist then best, bestDist = plr, d end
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

    -- v7.6: круг показываем только если включён ShowCircle
    if Aimbot.Enabled and Aimbot.ShowCircle and now < Aimbot.AdjustUntil then
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    if not Aimbot.Enabled then
        Aimbot.MoveAccum = 0
        Aimbot.Target = nil
        prevTargetLogged = nil
        return
    end

    if UIS.GetFocusedTextBox and UIS:GetFocusedTextBox() then return end

    if Aimbot.MoveAccum >= Aimbot.ReleaseThreshold then
        Aimbot.LockReleaseUntil = now + Aimbot.ReleaseWindow
        Aimbot.MoveAccum = 0
    end

    if now < Aimbot.LockReleaseUntil then
        if Aimbot.Target and prevTargetLogged then
            logScript("Aimbot release")
            prevTargetLogged = nil
        end
        Aimbot.Target = nil
        return
    end

    local target = findNearestTarget()
    Aimbot.Target = target

    if target then
        snapCameraTo(target)
        if target ~= prevTargetLogged then
            logScript("Aimbot hard-lock → " .. target.Name)
            prevTargetLogged = target
        end
    else
        prevTargetLogged = nil
    end
end

pcall(function() RunService:UnbindFromRenderStep("MerediosAimbot") end)
RunService:BindToRenderStep("MerediosAimbot", Enum.RenderPriority.Camera.Value + 1, aimbotStep)

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

    for part, _ in pairs(HitboxChanger.Original) do
        if part and part.Parent and plr.Character
           and part:IsDescendantOf(plr.Character) then
            pcall(function()
                local orig = HitboxChanger.Original[part]
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
-- STARTUP
--=============================================================
local startup = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 300, 0, 140),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.05,
    BorderSizePixel = 0, GroupTransparency = 1,
})
round(startup, 20)
local startupStroke = gradientStroke(startup, 1, 0.08, 30)
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
    Text = "// meridian core v7.6 · t.me//meredioshub",
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

--=============================================================
-- MENU
--=============================================================
local MENU_W, MENU_H = 420, 380

local menu = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, MENU_W, 0, MENU_H),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.04,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
round(menu, 20)
local menuStroke = gradientStroke(menu, 1, 0.05, 30)
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
new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Accent.Main),
        ColorSequenceKeypoint.new(1, Accent.Dim),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Rotation = 90,
}).Parent = topGlow

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
    Text = "v7.6 // t.me//meredioshub",
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
new("UIGradient", {
    Color = GradientColors,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.2),
    }),
    Rotation = 0,
}).Parent = topDivider

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
    BackgroundTransparency = 1, ZIndex = 2,
    ClipsDescendants = true,
})
contentBox.Parent = menu

local TABS = { "MAIN", "LOG", "COMBAT", "AIMBOT", "NEW" }
local tabButtons = {}
local contentPages = {}
local activeTab = "MAIN"
local tabSwitching = false

-- v7.6: анимация переключения вкладок — slide + fade
local function animatePageIn(page, fromLeft)
    if not Theme.anim then
        page.Position = UDim2.new(0, 0, 0, 0)
        page.GroupTransparency = 0
        return
    end
    local offset = fromLeft and -40 or 40
    page.Position = UDim2.new(0, offset, 0, 0)
    page.GroupTransparency = 1
    tween(page, 0.35, {
        Position = UDim2.new(0, 0, 0, 0),
        GroupTransparency = 0,
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end

local function switchTab(name)
    if tabSwitching or name == activeTab then return end
    tabSwitching = true

    local oldName = activeTab
    activeTab = name

    -- определяем направление
    local oldIdx, newIdx = 1, 1
    for i, t in ipairs(TABS) do
        if t == oldName then oldIdx = i end
        if t == name then newIdx = i end
    end
    local fromLeft = newIdx > oldIdx

    -- кнопки вкладок
    for tName, btn in pairs(tabButtons) do
        local on = tName == name
        tween(btn, 0.22, {
            BackgroundTransparency = on and 0.05 or 0.85,
            TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText,
        })
        local st = btn:FindFirstChildOfClass("UIStroke")
        if st then st.Transparency = on and 0 or 0.5 end
    end

    -- старая страница уезжает
    local oldPage = contentPages[oldName]
    local newPage = contentPages[name]

    if oldPage and oldPage ~= newPage then
        if Theme.anim then
            local outOffset = fromLeft and 40 or -40
            tween(oldPage, 0.22, {
                Position = UDim2.new(0, outOffset, 0, 0),
                GroupTransparency = 1,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.22, function()
                oldPage.Visible = false
                oldPage.Position = UDim2.new(0, 0, 0, 0)
                oldPage.GroupTransparency = 0
            end)
        else
            oldPage.Visible = false
        end
    end

    -- новая страница въезжает
    if newPage then
        newPage.Visible = true
        animatePageIn(newPage, fromLeft)
    end

    task.delay(0.35, function()
        tabSwitching = false
    end)
end

local function makePage(name)
    local page = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        GroupTransparency = 0,
        Visible = false, ZIndex = 2,
    })
    local scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Accent.Main,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    })
    scroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    scroll.Parent = page
    page.Parent = contentBox
    contentPages[name] = page
    page._scroll = scroll
    return page, scroll
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
    gradientStroke(btn, 1, 0.5, 30)
    btn.Parent = tabBar
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabButtons[name] = btn
    return btn
end

for i, name in ipairs(TABS) do makeTab(name, i) end

--=============================================================
-- COMPACT ROW BUILDER v7.6
-- [Функция] [вкл/выкл] — компактные строки
--=============================================================
local function makeRow(parent, order, title, desc)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, desc and 52 or 40),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, LayoutOrder = order,
    })
    round(row, 12)
    gradientStroke(row, 1, 0.2, 35)
    row.Parent = parent
    reg(row, "BackgroundColor3", "Card")

    -- левый акцентный бар
    local accentBar = new("Frame", {
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 3, 0, desc and 28 or 16),
        BackgroundColor3 = Accent.Main,
        BorderSizePixel = 0, ZIndex = 2,
    })
    round(accentBar, 2)
    accentBar.Parent = row

    local t = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, desc and 6 or 0),
        Size = UDim2.new(1, -80, 0, desc and 18 or row.Size.Y.Offset),
        Text = title, TextColor3 = P.Text,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = desc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        ZIndex = 2,
    })
    t.Parent = row
    reg(t, "TextColor3", "Text")

    if desc then
        local d = new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 26),
            Size = UDim2.new(1, -80, 0, 20),
            Text = desc, TextColor3 = P.SubText,
            Font = Enum.Font.Gotham, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, ZIndex = 2,
        })
        d.Parent = row
        reg(d, "TextColor3", "SubText")
    end

    return row, accentBar
end

local function makeCompactSwitch(row, onChanged, initial)
    local track = new("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = P.Track, BorderSizePixel = 0, ZIndex = 2,
    })
    round(track, 10); track.Parent = row

    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 3,
    })
    round(knob, 7); knob.Parent = track

    local entry = { state = false, track = track, knob = knob, lbl = nil, card = row }
    table.insert(SwitchRegistry, entry)

    local function set(v)
        entry.state = v
        tween(knob, 0.24, { Position = v and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) })
        tween(track, 0.24, { BackgroundColor3 = v and Accent.Main or P.Track })
        if onChanged then onChanged(v) end
    end
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 4,
    })
    btn.Parent = track
    btn.MouseButton1Click:Connect(function() set(not entry.state) end)
    if initial then set(true) end
    return set
end

local function makeCompactSlider(row, min, max, initial, onChange)
    local track = new("Frame", {
        Position = UDim2.new(0, 12, 1, -14),
        Size = UDim2.new(1, -90, 0, 5),
        BackgroundColor3 = P.Track,
        BorderSizePixel = 0, ZIndex = 2,
    })
    round(track, 3); track.Parent = row

    local fill = new("Frame", {
        Size = UDim2.new((initial - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Accent.Main,
        BorderSizePixel = 0, ZIndex = 3,
    })
    round(fill, 3); fill.Parent = track

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((initial - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = P.Knob,
        BorderSizePixel = 0, ZIndex = 4,
    })
    round(knob, 6); knob.Parent = track

    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -74, 0, 8),
        Size = UDim2.new(0, 62, 0, 14),
        Text = tostring(initial),
        TextColor3 = P.Text, Font = Enum.Font.Code, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 2,
    })
    valLbl.Parent = row
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

--=============================================================
-- MAIN PAGE
--=============================================================
local mainPage, mainScroll = makePage("MAIN")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}).Parent = mainScroll

do
    local row = makeRow(mainScroll, 1, "SPEED WALK", "ускоряет ходьбу. диапазон 8–500.")
    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(0, 56, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(Speed.Value), TextColor3 = P.Text,
        Font = Enum.Font.Code, TextSize = 11,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true, ZIndex = 2,
    })
    round(box, 6); box.Parent = row
    reg(box, "BackgroundColor3", "Bg")
    reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then Speed.Value = math.clamp(math.floor(n), 8, 500) end
        box.Text = tostring(Speed.Value)
        logScript("Speed value = " .. tostring(Speed.Value))
    end)

    makeCompactSwitch(row, function(v)
        Speed.Enabled = v
        if not v then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        logScript("Speed " .. (v and "ON" or "OFF"))
    end)
end

do
    local row = makeRow(mainScroll, 2, "ANTI-FLING", "гасит флинг и раскрутку от физики и чужих эксплойтов.")
    makeCompactSwitch(row, function(v)
        AntiFling.Enabled = v
        logScript("Anti-Fling " .. (v and "ON" or "OFF"))
    end)
end

do
    local row = makeRow(mainScroll, 3, "REJOIN", "переподключает к текущему серверу.")
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "REJOIN", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(btn, 8); btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        logScript("Rejoin initiated")
        pcall(function() TeleportSvc:Teleport(game.PlaceId, LP) end)
    end)
    btn.MouseEnter:Connect(function() tween(btn, 0.2, { BackgroundTransparency = 0.02 }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.2, { BackgroundTransparency = 0.2 }) end)
end

--=============================================================
-- LOG PAGE
--=============================================================
local logPage = makePage("LOG")
local logScrollFrame = logPage._scroll
logScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
logScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
logScrollFrame.CanvasSize = UDim2.new(1, 0, 1, 0)
logScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Never
logScrollFrame.ScrollingEnabled = false

local logViewport = new("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, -34),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
})
round(logViewport, 12)
gradientStroke(logViewport, 1, 0.25, 35)
logViewport.Parent = logScrollFrame
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
})
logScroll.Parent = logViewport
local logLayout = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
logLayout.Parent = logScroll

local serverTabBtn = new("TextButton", {
    Position = UDim2.new(0, 0, 1, -28),
    Size = UDim2.new(0.32, -2, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "SERVER", TextColor3 = P.SubText,
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(serverTabBtn, 9)
gradientStroke(serverTabBtn, 1, 0.5, 30)
serverTabBtn.Parent = logScrollFrame

local scriptTabBtn = new("TextButton", {
    Position = UDim2.new(0.32, 0, 1, -28),
    Size = UDim2.new(0.32, -2, 0, 28),
    BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.05,
    Text = "SCRIPT", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(scriptTabBtn, 9)
gradientStroke(scriptTabBtn, 1, 0.3, 30)
scriptTabBtn.Parent = logScrollFrame

table.insert(LogTabButtons, { name = "server", btn = serverTabBtn })
table.insert(LogTabButtons, { name = "script", btn = scriptTabBtn })

local copyBtn = new("TextButton", {
    Position = UDim2.new(0.64, 0, 1, -28),
    Size = UDim2.new(0.18, -2, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "COPY", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(copyBtn, 9)
gradientStroke(copyBtn, 1, 0.5, 30)
copyBtn.Parent = logScrollFrame
reg(copyBtn, "BackgroundColor3", "Card"); reg(copyBtn, "TextColor3", "Text")

local clearBtn = new("TextButton", {
    Position = UDim2.new(0.82, 2, 1, -28),
    Size = UDim2.new(0.18, -2, 0, 28),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "CLR", TextColor3 = Color3.fromRGB(255, 90, 90),
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(clearBtn, 9)
gradientStroke(clearBtn, 1, 0.5, 30)
clearBtn.Parent = logScrollFrame
reg(clearBtn, "BackgroundColor3", "Card")

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
            LayoutOrder = #logLineCache + 1,
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
local combatPage, combatScroll = makePage("COMBAT")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}).Parent = combatScroll

-- HITBOX
do
    local row = makeRow(combatScroll, 1, "HITBOX CHANGER", "увеличивает хитбокс игроков.")

    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(0, 50, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(HitboxChanger.Size), TextColor3 = P.Text,
        Font = Enum.Font.Code, TextSize = 11,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true, ZIndex = 2,
    })
    round(box, 6); box.Parent = row
    reg(box, "BackgroundColor3", "Bg"); reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            HitboxChanger.Size = math.clamp(math.floor(n), 1, 50)
            if HitboxChanger.Enabled then restoreAllHitboxes(); applyAllHitboxes() end
            if HitboxChanger.View then refreshAllHitboxViews() end
            logScript("Hitbox size = " .. tostring(HitboxChanger.Size))
        end
        box.Text = tostring(HitboxChanger.Size)
    end)

    local viewBtn = new("TextButton", {
        Position = UDim2.new(0, 70, 0, 8),
        Size = UDim2.new(0, 56, 0, 22),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.3,
        Text = "VIEW", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(viewBtn, 6)
    gradientStroke(viewBtn, 1, 0.5, 30)
    viewBtn.Parent = row
    reg(viewBtn, "BackgroundColor3", "Card")

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
    viewBtn.MouseButton1Click:Connect(function() setView(not viewState) end)

    makeCompactSwitch(row, function(v)
        HitboxChanger.Enabled = v
        if v then applyAllHitboxes()
        else
            restoreAllHitboxes()
            if HitboxChanger.View then removeAllHitboxViews(); HitboxChanger.View = false; setView(false) end
        end
        logScript("Hitbox " .. (v and "ON" or "OFF"))
    end)
end

-- ESP
do
    local row = makeRow(combatScroll, 2, "ESP", "подсвечивает игроков. зелёный = доступен для стрельбы.")
    makeCompactSwitch(row, function(v)
        ESP.Enabled = v
        refreshAllESP()
        logScript("ESP " .. (v and "ON" or "OFF"))
    end)
end

-- ESP VISIBILITY
do
    local row = makeRow(combatScroll, 3, "ESP VISIBILITY", "зелёный = виден из-за стены.")
    makeCompactSwitch(row, function(v)
        ESP.VisibilityCheck = v
        reapplyAllESPStyles()
        logScript("ESP visibility " .. (v and "ON" or "OFF"))
    end, true)
end

-- ESP COLOR
do
    local row = makeRow(combatScroll, 4, "ESP COLOR", "палитра подсветки.")
    local palRow = new("Frame", {
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1, ZIndex = 2,
    })
    palRow.Parent = row
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }).Parent = palRow

    local swatchMap = {}
    local list = espPaletteCurrent()
    for i, entry in ipairs(list) do
        local swatch = new("TextButton", {
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundColor3 = entry.color, BackgroundTransparency = 0,
            Text = "", AutoButtonColor = false,
            BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2,
        })
        round(swatch, 5)
        local st = new("UIStroke", {
            Thickness = 1, Transparency = 0.6,
            Color = Color3.fromRGB(255, 255, 255),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
        st.Parent = swatch
        swatch.Parent = palRow
        local isCur = (entry.color == ESP.Color)
        st.Transparency = isCur and 0 or 0.6
        st.Thickness = isCur and 2 or 1
        swatchMap[entry.name] = { btn = swatch, stroke = st, entry = entry }
        swatch.MouseButton1Click:Connect(function()
            ESP.Color = entry.color
            for _, s in pairs(swatchMap) do
                local cur = (s.entry.color == entry.color)
                s.stroke.Transparency = cur and 0 or 0.6
                s.stroke.Thickness = cur and 2 or 1
            end
            reapplyAllESPStyles()
            logScript("ESP color = " .. entry.name)
        end)
    end
end

-- WALLBANG
do
    local row = makeRow(combatScroll, 5, "WALLBANG", "хук на Raycast. DIAG для диагностики.")
    makeCompactSwitch(row, function(v)
        Wallbang.Enabled = v
        logScript("Wallbang " .. (v and "ON" or "OFF"))
    end)
end

-- WALLBANG DIAG
do
    local row = makeRow(combatScroll, 6, "WALLBANG DIAG", "сниффер remote-вызовов. 30с окно.")
    makeCompactSwitch(row, function(v)
        RemoteDiag.Enabled = v
        if v then
            RemoteDiag.Count = 0
            RemoteDiag.Window = tick() + 30
            logScript("DIAG armed · 30s window")
        else
            logScript("DIAG off")
        end
    end)
end

-- DIAG BUTTONS
do
    local row = makeRow(combatScroll, 7, "DIAG CONTROLS", nil)
    local dumpBtn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(0.48, -8, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "DUMP", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(dumpBtn, 7); dumpBtn.Parent = row

    dumpBtn.MouseButton1Click:Connect(function()
        logScript("=== REMOTE DIAG DUMP ===")
        logScript("captured: " .. RemoteDiag.Count .. "/" .. RemoteDiag.Max)
    end)

    local resetBtn = new("TextButton", {
        Position = UDim2.new(0.52, 0, 0, 8),
        Size = UDim2.new(0.48, -8, 0, 24),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.2,
        Text = "RESET", TextColor3 = P.Text,
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(resetBtn, 7); resetBtn.Parent = row
    reg(resetBtn, "BackgroundColor3", "Card"); reg(resetBtn, "TextColor3", "Text")

    resetBtn.MouseButton1Click:Connect(function()
        RemoteDiag.Count = 0
        RemoteDiag.Window = tick() + 30
        logScript("DIAG reset · 30s window")
    end)
end

--=============================================================
-- AIMBOT PAGE v7.6
--=============================================================
local aimbotPage, aimbotScroll = makePage("AIMBOT")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}).Parent = aimbotScroll

-- AIMBOT MASTER
do
    local row = makeRow(aimbotScroll, 1, "AIMBOT", "жёсткий лок на голову. движение камеры отпускает.")
    makeCompactSwitch(row, function(v)
        Aimbot.Enabled = v
        if not v then Aimbot.MoveAccum = 0 end
        logScript("Aimbot " .. (v and "ON" or "OFF"))
    end)
end

-- ONLY VISIBLE
do
    local row = makeRow(aimbotScroll, 2, "ONLY VISIBLE", "работает только при видимости цели. включает ESP + visibility.")
    makeCompactSwitch(row, function(v)
        Aimbot.OnlyVisible = v
        if v then
            -- принудительно включаем ESP и visibility
            if not ESP.Enabled then
                ESP.Enabled = true
                refreshAllESP()
            end
            if not ESP.VisibilityCheck then
                ESP.VisibilityCheck = true
                reapplyAllESPStyles()
            end
            logScript("OnlyVisible ON · ESP + visibility forced")
        else
            logScript("OnlyVisible OFF")
        end
    end)
end

-- SHOW CIRCLE
do
    local row = makeRow(aimbotScroll, 3, "SHOW FOV CIRCLE", "показ круга поля зрения.")
    makeCompactSwitch(row, function(v)
        Aimbot.ShowCircle = v
        if not v then fovCircle.Visible = false end
        logScript("FOV circle " .. (v and "ON" or "OFF"))
    end, true)
end

-- FOV SLIDER
do
    local row = makeRow(aimbotScroll, 4, "FOV RADIUS", "размер круга в пикселях.")
    makeCompactSlider(row, 40, 400, Aimbot.FOV, function(v)
        Aimbot.FOV = v
        updateFOVCircle()
        Aimbot.AdjustUntil = tick() + 1.5
    end)
end

-- FOV COLOR
do
    local row = makeRow(aimbotScroll, 5, "FOV COLOR", "белый = чёрная обводка по краям.")
    local PRESETS = {
        Color3.fromRGB(30, 64, 175),
        Color3.fromRGB(15, 40, 120),
        Color3.fromRGB(0, 210, 255),
        Color3.fromRGB(255, 60, 60),
        Color3.fromRGB(80, 220, 100),
        Color3.fromRGB(255, 220, 60),
        Color3.fromRGB(160, 95, 255),
        Color3.fromRGB(255, 255, 255),
    }
    local swatchRow = new("Frame", {
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1, ZIndex = 2,
    })
    swatchRow.Parent = row
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }).Parent = swatchRow

    local swatches = {}
    local function selectColor(c)
        Aimbot.Color = c
        updateFOVCircle()
        for _, s in ipairs(swatches) do
            local isCur = s.color == c
            s.stroke.Transparency = isCur and 0 or 0.6
            s.stroke.Thickness = isCur and 2 or 1
        end
        logScript(string.format("Aimbot color = RGB(%d,%d,%d)", c.R * 255, c.G * 255, c.B * 255))
    end
    for i, c in ipairs(PRESETS) do
        local swatch = new("TextButton", {
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundColor3 = c, BackgroundTransparency = 0,
            Text = "", AutoButtonColor = false,
            BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2,
        })
        round(swatch, 5)
        local st = new("UIStroke", {
            Thickness = 1, Transparency = 0.6,
            Color = Color3.fromRGB(255,255,255),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
        st.Parent = swatch
        swatch.Parent = swatchRow
        table.insert(swatches, { bg = swatch, stroke = st, color = c })
        swatch.MouseButton1Click:Connect(function() selectColor(c) end)
    end
    selectColor(Aimbot.Color)
end

--=============================================================
-- NEW PAGE
--=============================================================
local newPage, newScroll = makePage("NEW")
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}).Parent = newScroll

do
    local row = makeRow(newScroll, 1, "ОБНОВЛЕНИЕ v7.6", "t.me//meredioshub — все апдейты и сборки там.")
    local body = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 28),
        Size = UDim2.new(1, -36, 0, 200),
        Text = table.concat({
            "• Aimbot — отдельная вкладка AIMBOT",
            "• OnlyVisible — работа только при",
            "  видимости цели, форсит ESP",
            "• Show FOV Circle — скрыть круг",
            "• FOV Radius — слайдер 40–400px",
            "• FOV Color — палитра, белый с",
            "  чёрной обводкой по краям",
            "• GUI — компактные строки",
            "  [функция] [вкл/выкл]",
            "• Анимации вкладок — slide + fade",
            "• Исправлено перекрытие обводки",
            "• Telegram: t.me//meredioshub",
        }, "\n"),
        TextColor3 = P.Text,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, ZIndex = 2,
    })
    body.Parent = row
    reg(body, "TextColor3", "Text")
end

do
    local row = makeRow(newScroll, 2, "TELEGRAM", "t.me//meredioshub")
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "СКОПИРОВАТЬ t.me//meredioshub", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(btn, 8); btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        logScript("TG link copied")
        copyToClipboard("t.me//meredioshub")
        btn.Text = "СКОПИРОВАНО"
        task.delay(1.2, function() btn.Text = "СКОПИРОВАТЬ t.me//meredioshub" end)
    end)
end

--=============================================================
-- SETTINGS
--=============================================================
local settings = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 320, 0, 250),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 5,
})
round(settings, 16)
local settingsStroke = gradientStroke(settings, 1, 0.12, 30)
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
    local function refresh(sel)
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
    Thickness = 1.5,
    Transparency = 0.05,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
    Color = Color3.new(1, 1, 1),
})
mBtnStroke.Parent = mBtn
local mBtnGrad = new("UIGradient", {
    Color = BluePinkSeq,
    Rotation = 30,
})
mBtnGrad.Parent = mBtnStroke

task.spawn(function()
    while mBtn.Parent do
        local startRot = mBtnGrad.Rotation
        local tw = TS:Create(mBtnGrad,
            TweenInfo.new(3.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
            { Rotation = startRot + 360 })
        tw:Play()
        tw.Completed:Wait()
        if not mBtn.Parent then break end
        mBtnGrad.Rotation = startRot
    end
end)

local mGlow = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 12, 1, 12),
    BackgroundTransparency = 1, ZIndex = mBtn.ZIndex - 1,
})
round(mGlow, 30)
local mGlowStroke = new("UIStroke", {
    Thickness = 2,
    Transparency = 0.75,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
    Color = Color3.new(1, 1, 1),
})
mGlowStroke.Parent = mGlow
local mGlowGrad = new("UIGradient", {
    Color = BluePinkSeq,
    Rotation = 30,
})
mGlowGrad.Parent = mGlowStroke
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
    BorderSizePixel = 0,
    TextTransparency = 1,
    Visible = false,
    ZIndex = 60,
})
round(tapHint, 9)
local tapHintStroke = new("UIStroke", {
    Thickness = 1, Transparency = 1,
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
        if now - lastTapTime > TAP_WINDOW then
            tapCount = 0
        end
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
-- TRANSITIONS
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
    -- показать активную вкладку
    local page = contentPages[activeTab]
    if page then
        page.Visible = true
        page.Position = UDim2.new(0, 0, 0, 0)
        page.GroupTransparency = 0
    end
end

local function closeMenu()
    _G.MerediosSettingsOpen = false
    closeToken = closeToken + 1
    local myToken = closeToken
    tween(menu, 0.30, { GroupTransparency = 1 })
    tween(menuStroke, 0.30, { Transparency = 1 })
    tween(settings, 0.30, { GroupTransparency = 1, BackgroundTransparency = 1 })
    tween(settingsStroke, 0.30, { Transparency = 1 })
    task.delay(0.30, function()
        if closeToken ~= myToken then return end
        menu.Visible = false
        menu.GroupTransparency = 0
        settings.Visible = false
        settings.GroupTransparency = 1
        settings.BackgroundTransparency = 0.02
        settingsStroke.Transparency = 0.12
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
        GroupTransparency = 1,
        BackgroundTransparency = 1,
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

startBtn.MouseButton1Click:Connect(function()
    started = true
    tween(startup, 0.4, { GroupTransparency = 1 })
    tween(startupStroke, 0.4, { Transparency = 1 })
    task.delay(0.4, function()
        startup.Visible = false
        openMenu()
        logScript("Meredios HUD v7.6 started · t.me//meredioshub")
    end)
end)

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
mBtn.Visible = false
startup.Visible = true
startup.GroupTransparency = 1
startupStroke.Transparency = 1

logScript("Kernel loaded · v7.6")
logScript("t.me//meredioshub")
logScript("Aimbot hard-lock · OnlyVisible · FOV=" .. Aimbot.FOV)
logScript("GUI compact rows · tab slide animations")
renderLog()

return true
