local __MAIN = function()

--[[
    MEREDIOS v7.7.5 — оперативный контур
    Roblox / Delta X Mobile
    t.me//meredioshub
]]

print("[M1] top of script")

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
local RS           = game:GetService("ReplicatedStorage")

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
        Card=Color3.fromRGB(255,255,255), CardEdge=Color3.fromRGB(200,208,224),
        Text=Color3.fromRGB(22,28,42), SubText=Color3.fromRGB(120,130,152),
        Track=Color3.fromRGB(205,212,226), Knob=Color3.fromRGB(70,82,108),
        Divider=Color3.fromRGB(225,230,240),
    },
    Dark = {
        Bg=Color3.fromRGB(24,29,41), BgGlass=Color3.fromRGB(31,37,52),
        Card=Color3.fromRGB(38,45,62), CardEdge=Color3.fromRGB(90,105,140),
        Text=Color3.fromRGB(235,240,250), SubText=Color3.fromRGB(145,158,182),
        Track=Color3.fromRGB(60,70,92), Knob=Color3.fromRGB(245,250,255),
        Divider=Color3.fromRGB(58,68,88),
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

local Logger = {
    buffer = { server = {}, script = {} },
    maxLen = 400,
    listeners = {},
    activeTab = "script",
}

local ThemeReg = {}
local function reg(inst, prop, key)
    table.insert(ThemeReg, {inst, prop, key})
    if inst and inst.Parent ~= nil then inst[prop] = P[key] end
end

local SwitchRegistry = {}
local LogTabButtons = {}
local CardStrokes = {}

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
    for _, s in ipairs(CardStrokes) do
        if s.stroke and s.stroke.Parent then s.stroke.Color = P.CardEdge end
    end
end

print("[M2] theme OK")

--=============================================================
-- LOGGER FUNCTIONS + CLIPBOARD
--=============================================================
local function logLine(channel, text)
    local buf = Logger.buffer[channel]
    if not buf then return end
    local ok, t = pcall(function() return os.date("%H:%M:%S") end)
    if not ok or not t then t = "??:??:??" end
    table.insert(buf, "[" .. t .. "] " .. text)
    while #buf > Logger.maxLen do table.remove(buf, 1) end
    for _, cb in ipairs(Logger.listeners) do pcall(cb, channel) end
end

local function logScript(text) logLine("script", text) end
local function logServer(text) logLine("server", text) end

local function copyToClipboard(text)
    for _, fn in ipairs({ setclipboard, toclipboard, writeclipboard }) do
        if type(fn) == "function" then
            if pcall(fn, text) then return true end
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
-- HITBOX
--=============================================================
local HitboxChanger = { Enabled = false, View = false, Size = 12, Original = {} }

local function hitboxParts(char)
    if not char then return {} end
    local list = {}
    for _, name in ipairs({ "HumanoidRootPart", "Head", "UpperTorso", "Torso", "LowerTorso" }) do
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
                part.Size = orig.Size; part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide; part.CanQuery = orig.CanQuery
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
        if plr ~= LP and plr.Character then
            for _, part in ipairs(hitboxParts(plr.Character)) do
                local v = part:FindFirstChild("MerediosHitboxView")
                if v then v.Size = part.Size end
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
    for _, name in ipairs({ "Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart" }) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local hit = workspace:Raycast(origin, part.Position - origin, params)
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
        h.FillColor = VISIBLE_COLOR; h.OutlineColor = VISIBLE_COLOR
        h.FillTransparency = 0.55; h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.Occluded
    else
        h.FillColor = ESP.Color; h.OutlineColor = ESP.Color
        h.FillTransparency = 0.75; h.OutlineTransparency = 0
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
-- WALLBANG
--=============================================================
local Wallbang = {
    Enabled = false, ByteNetRemote = nil, Patches = 0,
    LastError = "", LastEnemy = "", HookArmed = false,
}

local OFF_PLAYER_POS  = 2
local OFF_SHOT_ORIGIN = 58
local OFF_LOOK_VECTOR = 70
local SHOT_PACKET_LEN = 93

local function vec3Read(buf, off)
    local ok1, x = pcall(function() return buffer.readf32(buf, off) end)
    local ok2, y = pcall(function() return buffer.readf32(buf, off+4) end)
    local ok3, z = pcall(function() return buffer.readf32(buf, off+8) end)
    if not (ok1 and ok2 and ok3) then return nil end
    return Vector3.new(x, y, z)
end

local function vec3Write(buf, off, v)
    return pcall(function()
        buffer.writef32(buf, off, v.X)
        buffer.writef32(buf, off+4, v.Y)
        buffer.writef32(buf, off+8, v.Z)
    end)
end

local function isShotPacket(buf)
    if typeof(buf) ~= "buffer" then return false end
    local okL, len = pcall(function() return buffer.len(buf) end)
    if not okL or len ~= SHOT_PACKET_LEN then return false end
    local ok1, b0 = pcall(function() return buffer.readu8(buf, 0) end)
    local ok2, b1 = pcall(function() return buffer.readu8(buf, 1) end)
    if not (ok1 and ok2) then return false end
    return b0 == 0x21 and b1 == 0x01
end

local function getNearestHead(fromPos)
    local best, bestName, bestDist = nil, nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                local d = (head.Position - fromPos).Magnitude
                if d < bestDist then
                    best, bestName, bestDist = head.Position, plr.Name, d
                end
            end
        end
    end
    return best, bestName
end

local function wallbangPatch(buf)
    local playerPos = vec3Read(buf, OFF_PLAYER_POS)
    if not playerPos then Wallbang.LastError = "no playerPos"; return false end
    local enemyHead, enemyName = getNearestHead(playerPos)
    if not enemyHead then Wallbang.LastError = "no enemy"; return false end
    local toEnemy = enemyHead - playerPos
    if toEnemy.Magnitude < 0.5 then Wallbang.LastError = "too close"; return false end
    local newDir = toEnemy.Unit
    local newOrigin = playerPos + newDir * 10.28
    local ok1 = vec3Write(buf, OFF_SHOT_ORIGIN, newOrigin)
    local ok2 = vec3Write(buf, OFF_LOOK_VECTOR, newDir)
    if not (ok1 and ok2) then Wallbang.LastError = "write fail"; return false end
    Wallbang.Patches = Wallbang.Patches + 1
    Wallbang.LastEnemy = enemyName
    return true
end

task.spawn(function()
    for _ = 1, 60 do
        local r = RS:FindFirstChild("ByteNetReliable")
        if r and r:IsA("RemoteEvent") then Wallbang.ByteNetRemote = r; break end
        task.wait(0.5)
    end
end)

do
    local okMT, mt = pcall(function() return getrawmetatable(game) end)
    if okMT and mt and type(newcclosure) == "function" and type(setreadonly) == "function" then
        local oldNamecall = mt.__namecall
        if oldNamecall then
            local installed = pcall(function()
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    local ok, result = pcall(function()
                        local method = "?"
                        if type(getnamecallmethod) == "function" then
                            local ok2, m = pcall(getnamecallmethod)
                            if ok2 and m then method = m end
                        end

                        if method == "FireServer"
                           and Wallbang.Enabled
                           and Wallbang.ByteNetRemote
                           and self == Wallbang.ByteNetRemote then
                            local args = table.pack(...)
                            if isShotPacket(args[1]) then
                                local newBuf = buffer.create(SHOT_PACKET_LEN)
                                pcall(function() buffer.copy(newBuf, 0, args[1], 0, SHOT_PACKET_LEN) end)
                                if wallbangPatch(newBuf) then
                                    args[1] = newBuf
                                    return { patched = true, args = args }
                                end
                            end
                        end
                        return nil
                    end)

                    if ok and result and result.patched then
                        local a = result.args
                        return oldNamecall(self, table.unpack(a, 1, a.n))
                    end
                    return oldNamecall(self, ...)
                end)
                setreadonly(mt, true)
            end)

            if installed then
                Wallbang.HookArmed = true
                logScript("WALLBANG hook armed (safe)")
            else
                pcall(function() setreadonly(mt, true) end)
                logScript("WALLBANG hook install failed — disabled")
            end
        end
    else
        logScript("WALLBANG hook unavailable")
    end
end

print("[M3] wallbang block OK")

--=============================================================
-- AIMBOT
--=============================================================
local Aimbot = {
    Enabled = false,
    FOV = 140,
    Color = Color3.fromRGB(30, 64, 175),
    ShowCircle = true,
    VisibleOnly = false,
    ReleaseThreshold = 45,
    ReleaseWindow = 0.12,
    MoveAccum = 0,
    LockReleaseUntil = 0,
    AdjustUntil = 0,
    Target = nil,
    ActiveGameTouch = nil,
}

local fovCircle = new("Frame", {
    Name = "MerediosFOVCircle",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, Aimbot.FOV * 2, 0, Aimbot.FOV * 2),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Visible = false, ZIndex = 5000,
})
round(fovCircle, Aimbot.FOV)
local fovStroke = new("UIStroke", {
    Thickness = 3, Color = Aimbot.Color, Transparency = 0,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
})
fovStroke.Parent = fovCircle
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
                if Aimbot.VisibleOnly and not hasLineOfSight(plr.Character) then
                    pos = nil
                end
                if pos then
                    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                    if onScreen and screenPos.Z > 0 then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if d <= bestDist then best, bestDist = plr, d end
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

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        Aimbot.ActiveGameTouch = input
    end
end)
UIS.InputEnded:Connect(function(input)
    if input == Aimbot.ActiveGameTouch then Aimbot.ActiveGameTouch = nil end
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

    if Aimbot.Enabled and Aimbot.ShowCircle then
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
        Aimbot.Target = nil
        prevTargetLogged = nil
        return
    end

    local target = findNearestTarget()
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
local __bindOk = pcall(function()
    RunService:BindToRenderStep("MerediosAimbot", Enum.RenderPriority.Camera.Value + 1, aimbotStep)
end)
if not __bindOk then
    RunService.Heartbeat:Connect(aimbotStep)
end

print("[M4] aimbot block OK")

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
    local toClear = {}
    for part in pairs(HitboxChanger.Original) do
        if part and part.Parent and plr.Character
           and part:IsDescendantOf(plr.Character) then
            table.insert(toClear, part)
        end
    end
    for _, part in ipairs(toClear) do
        local orig = HitboxChanger.Original[part]
        if orig then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
                part.CanQuery = orig.CanQuery
            end)
        end
        HitboxChanger.Original[part] = nil
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

print("[M5] player hooks OK")

--=============================================================
-- STARTUP
--=============================================================
print("[M5.1] before STARTUP")

local startup = new("TextButton", {
    Name = "MerediosStartup",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 300, 0, 160),
    BackgroundColor3 = P.BgGlass,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Active = true,
    Selectable = true,
    ZIndex = 10,
})
round(startup, 20)
local startupStroke = new("UIStroke", {
    Thickness = 1, Transparency = 0.08,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1,1,1),
})
startupStroke.Parent = startup
new("UIGradient", { Color = GradientColors, Rotation = 30 }).Parent = startupStroke
startup.Parent = ScreenGui
reg(startup, "BackgroundColor3", "BgGlass")

print("[M6] startup created")

local startupTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 22, 0, 18),
    Size = UDim2.new(1, -44, 0, 30),
    Text = "Meredios",
    TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 26,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
})
startupTitle.Parent = startup
reg(startupTitle, "TextColor3", "Text")

local startupSub = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 22, 0, 48),
    Size = UDim2.new(1, -44, 0, 12),
    Text = "// meridian core v7.7.5 · t.me//meredioshub",
    TextColor3 = P.SubText,
    Font = Enum.Font.Code, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
})
startupSub.Parent = startup
reg(startupSub, "TextColor3", "SubText")

local startupTapLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 22, 0, 70),
    Size = UDim2.new(1, -44, 0, 14),
    Text = "▸ tap anywhere to start",
    TextColor3 = Accent.Main,
    Font = Enum.Font.GothamBold, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
})
startupTapLbl.Parent = startup

local startPill = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 1, -46),
    Size = UDim2.new(0, 200, 0, 36),
    BackgroundColor3 = Accent.Main,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 11,
})
round(startPill, 10)
startPill.Parent = startup

local startPillLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "НАЧАТЬ",
    TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 13,
    ZIndex = 12,
})
startPillLbl.Parent = startPill

--=============================================================
-- MENU
--=============================================================
local MENU_W, MENU_H = 420, 400

local menu = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, MENU_W, 0, MENU_H),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.04,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
round(menu, 20)
local menuStroke = new("UIStroke", {
    Thickness = 1, Transparency = 0.05,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1,1,1),
})
menuStroke.Parent = menu
new("UIGradient", { Color = GradientColors, Rotation = 30 }).Parent = menuStroke
menuStroke.Transparency = 1
menu.Parent = ScreenGui
reg(menu, "BackgroundColor3", "BgGlass")

local topGlow = new("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = P.Card,
    BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 1,
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
    Text = "MEREDIOS", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
})
brand.Parent = topBar
reg(brand, "TextColor3", "Text")

local subBrand = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 28),
    Size = UDim2.new(0, 320, 0, 12),
    Text = "v7.7.5 // t.me//meredioshub",
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
    Size = UDim2.new(1, -24, 0, 30),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.X, ZIndex = 2,
})
tabBar.Parent = menu
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}).Parent = tabBar

local contentBox = new("Frame", {
    Position = UDim2.new(0, 12, 0, 94),
    Size = UDim2.new(1, -24, 1, -106),
    BackgroundTransparency = 1, ZIndex = 2, ClipsDescendants = true,
})
contentBox.Parent = menu

local TABS = { "MAIN", "LOG", "COMBAT", "NEW" }
local tabButtons = {}
local contentPages = {}
local pageScrolls = {}
local activeTab = "MAIN"

local function switchTab(name)
    if activeTab == name and contentPages[name] and contentPages[name].Visible then return end
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
            page.Position = UDim2.new(0.12, 0, 0, 0)
            page.GroupTransparency = 0.6
            tween(page, 0.32, {
                Position = UDim2.new(0, 0, 0, 0),
                GroupTransparency = 0,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        elseif page.Visible then
            local p = page
            tween(p, 0.18, {
                Position = UDim2.new(-0.12, 0, 0, 0),
                GroupTransparency = 0.6,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.18, function()
                if activeTab ~= tName then
                    p.Visible = false
                    p.Position = UDim2.new(0, 0, 0, 0)
                end
            end)
        end
    end
    local cur = contentPages[name]
    if cur then
        cur.Position = UDim2.new(0, 0, 0, 0)
        cur.GroupTransparency = 0
        cur.Visible = true
    end
end

local function makePage(name)
    local page = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, GroupTransparency = 0,
        Visible = false, ZIndex = 2,
    })
    page.Parent = contentBox

    local scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Accent.Main,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 2,
    })
    scroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    scroll.Parent = page
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }).Parent = scroll

    contentPages[name] = page
    pageScrolls[name] = scroll
    return scroll
end

local function makeTab(name, order)
    local btn = new("TextButton", {
        Size = UDim2.new(0, 68, 0, 26),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.85,
        Text = name, TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = order,
    })
    round(btn, 8)
    local st = new("UIStroke", {
        Thickness = 1, Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Color3.new(1,1,1),
    })
    st.Parent = btn
    new("UIGradient", { Color = GradientColors, Rotation = 30 }).Parent = st
    btn.Parent = tabBar
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabButtons[name] = btn
    return btn
end

for i, name in ipairs(TABS) do makeTab(name, i) end

local function makeCard(parent, order, title, desc, height)
    height = height or 60
    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, LayoutOrder = order, ZIndex = 10,
    })
    round(card, 12)
    local stroke = new("UIStroke", {
        Thickness = 1, Transparency = 0.1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = P.CardEdge,
    })
    stroke.Parent = card
    table.insert(CardStrokes, { stroke = stroke, card = card })
    card.Parent = parent
    reg(card, "BackgroundColor3", "Card")

    local accentBar = new("Frame", {
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0, 3, 0, 12),
        BackgroundColor3 = Accent.Main,
        BorderSizePixel = 0, ZIndex = 2,
    })
    round(accentBar, 2)
    accentBar.Parent = card

    local t = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 6),
        Size = UDim2.new(1, -30, 0, 14),
        Text = title, TextColor3 = P.Text,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
    })
    t.Parent = card
    reg(t, "TextColor3", "Text")

    if desc then
        local d = new("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 20),
            Size = UDim2.new(1, -30, 0, 12),
            Text = desc, TextColor3 = P.SubText,
            Font = Enum.Font.Gotham, TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
        })
        d.Parent = card
        reg(d, "TextColor3", "SubText")
    end
    return card, accentBar
end

local function makeSwitch(card, y, onChanged, initial)
    local track = new("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -52, 0, y - 10),
        BackgroundColor3 = P.Track, BorderSizePixel = 0, ZIndex = 2,
    })
    round(track, 10); track.Parent = card

    local knob = new("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 3,
    })
    round(knob, 8); knob.Parent = track

    local lbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -80, 0, y - 16),
        Size = UDim2.new(0, 24, 0, 12),
        Text = "OFF", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 2,
    })
    lbl.Parent = card

    local entry = { state = false, track = track, knob = knob, lbl = lbl, card = card }
    table.insert(SwitchRegistry, entry)

    local function set(v)
        entry.state = v
        tween(knob, 0.24, { Position = v and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) })
        tween(track, 0.24, { BackgroundColor3 = v and Accent.Main or P.Track })
        lbl.Text = v and "ON" or "OFF"
        lbl.TextColor3 = v and Accent.Main or P.SubText
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

--=============================================================
-- MAIN PAGE
--=============================================================
local mainScroll = makePage("MAIN")

do
    local card = makeCard(mainScroll, 1, "SPEED WALK", "8–500")
    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(0, 56, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(Speed.Value), TextColor3 = P.Text,
        Font = Enum.Font.Code, TextSize = 11,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true, ZIndex = 2,
    })
    round(box, 6); box.Parent = card
    reg(box, "BackgroundColor3", "Bg"); reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then Speed.Value = math.clamp(math.floor(n), 8, 500) end
        box.Text = tostring(Speed.Value)
        logScript("Speed value = " .. tostring(Speed.Value))
    end)

    makeSwitch(card, 48, function(v)
        Speed.Enabled = v
        if not v then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        logScript("Speed " .. (v and "ON" or "OFF"))
    end)
end

do
    local card = makeCard(mainScroll, 2, "ANTI-FLING", "гасит флинг")
    makeSwitch(card, 34, function(v)
        AntiFling.Enabled = v
        logScript("Anti-Fling " .. (v and "ON" or "OFF"))
    end)
end

do
    local card = makeCard(mainScroll, 3, "REJOIN", "к текущему серверу", 66)
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "REJOIN", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(btn, 8); btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        logScript("Rejoin initiated")
        pcall(function() TeleportSvc:Teleport(game.PlaceId, LP) end)
    end)
end

--=============================================================
-- LOG PAGE
--=============================================================
local logScroll = makePage("LOG")
local logPage = contentPages["LOG"]
pageScrolls["LOG"].ScrollingEnabled = false

local logViewport = new("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, -34),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.06,
    BorderSizePixel = 0, ZIndex = 10,
})
round(logViewport, 12)
do
    local st = new("UIStroke", {
        Thickness = 1, Transparency = 0.15,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = P.CardEdge,
    })
    st.Parent = logViewport
    table.insert(CardStrokes, { stroke = st, card = logViewport })
end
logViewport.Parent = logPage
reg(logViewport, "BackgroundColor3", "Card")

local logInner = new("ScrollingFrame", {
    Position = UDim2.new(0, 10, 0, 10),
    Size = UDim2.new(1, -20, 1, -20),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Accent.Main,
    ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 2,
})
logInner.Parent = logViewport
local logLayout = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
logLayout.Parent = logInner

local serverTabBtn = new("TextButton", {
    Position = UDim2.new(0, 0, 1, -28),
    Size = UDim2.new(0.32, -2, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "SERVER", TextColor3 = P.SubText,
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
})
round(serverTabBtn, 8); serverTabBtn.Parent = logPage

local scriptTabBtn = new("TextButton", {
    Position = UDim2.new(0.32, 0, 1, -28),
    Size = UDim2.new(0.32, -2, 0, 26),
    BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.05,
    Text = "SCRIPT", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
})
round(scriptTabBtn, 8); scriptTabBtn.Parent = logPage

table.insert(LogTabButtons, { name = "server", btn = serverTabBtn })
table.insert(LogTabButtons, { name = "script", btn = scriptTabBtn })

local copyBtn = new("TextButton", {
    Position = UDim2.new(0.64, 0, 1, -28),
    Size = UDim2.new(0.18, -2, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "COPY", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
})
round(copyBtn, 8); copyBtn.Parent = logPage
reg(copyBtn, "BackgroundColor3", "Card"); reg(copyBtn, "TextColor3", "Text")

local clearBtn = new("TextButton", {
    Position = UDim2.new(0.82, 2, 1, -28),
    Size = UDim2.new(0.18, -2, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "CLR", TextColor3 = Color3.fromRGB(255, 90, 90),
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
})
round(clearBtn, 8); clearBtn.Parent = logPage
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
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1, Text = "",
            TextColor3 = P.Text, Font = Enum.Font.Code, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #logLineCache + 1, ZIndex = 2,
        })
        lbl.Parent = logInner
        table.insert(logLineCache, lbl)
        reg(lbl, "TextColor3", "Text")
    end
    for i, lbl in ipairs(logLineCache) do
        if i <= #buf then lbl.Text = buf[i]; lbl.Visible = true else lbl.Visible = false end
    end
    task.defer(function()
        logInner.CanvasPosition = Vector2.new(0, math.max(0, logLayout.AbsoluteContentSize.Y - logInner.AbsoluteSize.Y))
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
    copyBtn.Text = ok and "OK" or "ERR"
    task.delay(1.0, function() copyBtn.Text = "COPY" end)
    logScript(ok and ("Logs copied (" .. #text .. "b)") or "Copy failed")
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
local combatScroll = makePage("COMBAT")

do
    local card = makeCard(combatScroll, 1, "HITBOX CHANGER", "размер 1–50", 66)
    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(0, 56, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(HitboxChanger.Size), TextColor3 = P.Text,
        Font = Enum.Font.Code, TextSize = 11,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true, ZIndex = 2,
    })
    round(box, 6); box.Parent = card
    reg(box, "BackgroundColor3", "Bg"); reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            HitboxChanger.Size = math.clamp(math.floor(n), 1, 50)
            if HitboxChanger.Enabled then restoreAllHitboxes(); applyAllHitboxes() end
            if HitboxChanger.View then refreshAllHitboxViews() end
        end
        box.Text = tostring(HitboxChanger.Size)
    end)

    makeSwitch(card, 48, function(v)
        HitboxChanger.Enabled = v
        if v then applyAllHitboxes() else restoreAllHitboxes() end
        logScript("Hitbox " .. (v and "ON" or "OFF"))
    end)

    local viewBtn = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 36),
        Size = UDim2.new(0, 64, 0, 22),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.3,
        Text = "VIEW", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(viewBtn, 6); viewBtn.Parent = card
    local st = new("UIStroke", {
        Thickness = 1, Transparency = 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1,1,1),
    })
    st.Parent = viewBtn
    new("UIGradient", { Color = GradientColors, Rotation = 30 }).Parent = st
    reg(viewBtn, "BackgroundColor3", "Card")

    local viewState = false
    local function setView(v)
        viewState = v; HitboxChanger.View = v
        if v then
            tween(viewBtn, 0.2, { BackgroundColor3 = Accent.Main, TextColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.15 })
            applyAllHitboxViews()
        else
            tween(viewBtn, 0.2, { BackgroundColor3 = P.Card, TextColor3 = P.SubText, BackgroundTransparency = 0.3 })
            removeAllHitboxViews()
        end
        logScript("Hitbox View " .. (v and "ON" or "OFF"))
    end
    viewBtn.MouseButton1Click:Connect(function() setView(not viewState) end)
end

do
    local card = makeCard(combatScroll, 2, "ESP", "зелёный = виден из-за стены", 110)
    makeSwitch(card, 40, function(v)
        ESP.Enabled = v
        refreshAllESP()
        logScript("ESP " .. (v and "ON" or "OFF"))
    end)

    local visLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 52),
        Size = UDim2.new(1, -100, 0, 14),
        Text = "VISIBILITY", TextColor3 = P.SubText,
        Font = Enum.Font.GothamMedium, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
    })
    visLbl.Parent = card
    reg(visLbl, "TextColor3", "SubText")

    local rebuildESPPalette
    makeSwitch(card, 72, function(v)
        ESP.VisibilityCheck = v
        reapplyAllESPStyles()
        if rebuildESPPalette then rebuildESPPalette() end
        logScript("ESP visibility " .. (v and "ON" or "OFF"))
    end, true)

    local palRow = new("Frame", {
        Position = UDim2.new(0, 14, 0, 82),
        Size = UDim2.new(1, -28, 0, 26),
        BackgroundTransparency = 1, ZIndex = 2,
    })
    palRow.Parent = card
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    }).Parent = palRow

    local swatchMap = {}
    rebuildESPPalette = function()
        for _, s in pairs(swatchMap) do pcall(function() s.btn:Destroy() end) end
        swatchMap = {}
        for i, entry in ipairs(espPaletteCurrent()) do
            local swatch = new("TextButton", {
                Size = UDim2.new(0, 24, 0, 24),
                BackgroundColor3 = entry.color, BackgroundTransparency = 0,
                Text = "", AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2,
            })
            round(swatch, 6)
            local st2 = new("UIStroke", {
                Thickness = 1, Transparency = 0.6,
                Color = Color3.fromRGB(255,255,255),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            })
            st2.Parent = swatch
            swatch.Parent = palRow
            local isCur = (entry.color == ESP.Color)
            st2.Transparency = isCur and 0 or 0.6
            st2.Thickness = isCur and 2 or 1
            swatchMap[entry.name] = { btn = swatch, stroke = st2, entry = entry }
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
    task.defer(rebuildESPPalette)
end

do
    local card = makeCard(combatScroll, 3, "WALLBANG", "ByteNet shot patch", 100)
    makeSwitch(card, 40, function(v)
        Wallbang.Enabled = v
        Wallbang.Patches = 0
        logScript("Wallbang " .. (v and "ON" or "OFF"))
    end)

    local statusLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 54),
        Size = UDim2.new(1, -28, 0, 34),
        Text = "", TextColor3 = P.SubText,
        Font = Enum.Font.Code, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, ZIndex = 2,
    })
    statusLbl.Parent = card
    reg(statusLbl, "TextColor3", "SubText")

    task.spawn(function()
        while card.Parent do
            statusLbl.Text = "remote:" .. (Wallbang.ByteNetRemote and "OK" or "wait")
                .. " hook:" .. (Wallbang.HookArmed and "OK" or "FAIL")
                .. " patches:" .. Wallbang.Patches
                .. (Wallbang.LastEnemy ~= "" and (" →" .. Wallbang.LastEnemy) or "")
                .. (Wallbang.LastError ~= "" and (" [" .. Wallbang.LastError .. "]") or "")
            task.wait(0.4)
        end
    end)
end

local aimSettingsBtnRef = nil
do
    local card = makeCard(combatScroll, 4, "AIMBOT", "hard-lock на голову", 66)
    makeSwitch(card, 40, function(v)
        Aimbot.Enabled = v
        if not v then Aimbot.MoveAccum = 0 end
        logScript("Aimbot " .. (v and "ON" or "OFF"))
    end)

    local settingsBtn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(0, 92, 0, 22),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.25,
        Text = "⚙ НАСТРОЙКИ", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(settingsBtn, 6); settingsBtn.Parent = card
    aimSettingsBtnRef = settingsBtn
end

--=============================================================
-- AIMBOT SETTINGS PANEL
--=============================================================
local aimSettings = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 320, 0, 300),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 8,
})
round(aimSettings, 16)
local aimSettingsStroke = new("UIStroke", {
    Thickness = 1, Transparency = 0.12,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1,1,1),
})
aimSettingsStroke.Parent = aimSettings
new("UIGradient", { Color = GradientColors, Rotation = 30 }).Parent = aimSettingsStroke
aimSettingsStroke.Transparency = 1
aimSettings.Parent = menu
reg(aimSettings, "BackgroundColor3", "BgGlass")

local asTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 12),
    Size = UDim2.new(1, -70, 0, 16),
    Text = "AIMBOT SETTINGS", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
asTitle.Parent = aimSettings
reg(asTitle, "TextColor3", "Text")

local asClose = new("TextButton", {
    Position = UDim2.new(1, -36, 0, 8),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 16,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 9,
})
round(asClose, 8); asClose.Parent = aimSettings
reg(asClose, "BackgroundColor3", "Card"); reg(asClose, "TextColor3", "Text")

local asRow1 = new("Frame", {
    Position = UDim2.new(0, 18, 0, 48),
    Size = UDim2.new(1, -36, 0, 40),
    BackgroundTransparency = 1, ZIndex = 9,
})
asRow1.Parent = aimSettings

local asLbl1 = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, -60, 0, 14),
    Text = "AIM ONLY IF VISIBLE",
    TextColor3 = P.Text, Font = Enum.Font.GothamBold, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
asLbl1.Parent = asRow1
reg(asLbl1, "TextColor3", "Text")

local asSub1 = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 14),
    Size = UDim2.new(1, -60, 0, 12),
    Text = "aim + visibility + esp вместе",
    TextColor3 = P.SubText, Font = Enum.Font.Gotham, TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
asSub1.Parent = asRow1
reg(asSub1, "TextColor3", "SubText")

local asVisTrack = new("Frame", {
    Size = UDim2.new(0, 40, 0, 20),
    Position = UDim2.new(1, -40, 0, 10),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = P.Track, BorderSizePixel = 0, ZIndex = 9,
})
round(asVisTrack, 10); asVisTrack.Parent = asRow1

local asVisKnob = new("Frame", {
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(0, 10, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 10,
})
round(asVisKnob, 8); asVisKnob.Parent = asVisTrack

local asVisState = false
local function setVisibleOnly(v)
    asVisState = v
    tween(asVisKnob, 0.24, { Position = v and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) })
    tween(asVisTrack, 0.24, { BackgroundColor3 = v and Accent.Main or P.Track })
    Aimbot.VisibleOnly = v
    if v then
        ESP.Enabled = true; ESP.VisibilityCheck = true
        refreshAllESP()
        logScript("AIM visible-only ON")
    else
        logScript("AIM visible-only OFF")
    end
end
local asVisBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 11,
})
asVisBtn.Parent = asVisTrack
asVisBtn.MouseButton1Click:Connect(function() setVisibleOnly(not asVisState) end)

local asRow2 = new("Frame", {
    Position = UDim2.new(0, 18, 0, 96),
    Size = UDim2.new(1, -36, 0, 30),
    BackgroundTransparency = 1, ZIndex = 9,
})
asRow2.Parent = aimSettings

local asLbl2 = new("TextLabel", {
    BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0),
    Text = "SHOW FOV CIRCLE",
    TextColor3 = P.Text, Font = Enum.Font.GothamBold, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
asLbl2.Parent = asRow2
reg(asLbl2, "TextColor3", "Text")

local asCircTrack = new("Frame", {
    Size = UDim2.new(0, 40, 0, 20),
    Position = UDim2.new(1, -40, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = Accent.Main, BorderSizePixel = 0, ZIndex = 9,
})
round(asCircTrack, 10); asCircTrack.Parent = asRow2

local asCircKnob = new("Frame", {
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(1, -10, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 10,
})
round(asCircKnob, 8); asCircKnob.Parent = asCircTrack

local asCircState = true
local function setShowCircle(v)
    asCircState = v
    Aimbot.ShowCircle = v
    tween(asCircKnob, 0.24, { Position = v and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) })
    tween(asCircTrack, 0.24, { BackgroundColor3 = v and Accent.Main or P.Track })
    if not v then fovCircle.Visible = false end
    logScript("AIM circle " .. (v and "ON" or "OFF"))
end
local asCircBtn = new("TextButton", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 11,
})
asCircBtn.Parent = asCircTrack
asCircBtn.MouseButton1Click:Connect(function() setShowCircle(not asCircState) end)

local asFovLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 134),
    Size = UDim2.new(1, -36, 0, 14),
    Text = "FOV (px)", TextColor3 = P.SubText,
    Font = Enum.Font.GothamMedium, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
asFovLbl.Parent = aimSettings
reg(asFovLbl, "TextColor3", "SubText")

local asFovTrack = new("Frame", {
    Position = UDim2.new(0, 18, 0, 152),
    Size = UDim2.new(1, -100, 0, 5),
    BackgroundColor3 = P.Track, BorderSizePixel = 0, ZIndex = 9,
})
round(asFovTrack, 3); asFovTrack.Parent = aimSettings

local asFovFill = new("Frame", {
    Size = UDim2.new((Aimbot.FOV - 40) / 360, 0, 1, 0),
    BackgroundColor3 = Accent.Main, BorderSizePixel = 0, ZIndex = 10,
})
round(asFovFill, 3); asFovFill.Parent = asFovTrack

local asFovKnob = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new((Aimbot.FOV - 40) / 360, 0, 0.5, 0),
    Size = UDim2.new(0, 14, 0, 14),
    BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 11,
})
round(asFovKnob, 7); asFovKnob.Parent = asFovTrack

local asFovVal = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -84, 0, 143),
    Size = UDim2.new(0, 66, 0, 14),
    Text = tostring(Aimbot.FOV),
    TextColor3 = P.Text, Font = Enum.Font.Code, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 9,
})
asFovVal.Parent = aimSettings
reg(asFovVal, "TextColor3", "Text")

local asFovDragging = false
local function asFovSet(x)
    local rel = math.clamp((x - asFovTrack.AbsolutePosition.X) / math.max(asFovTrack.AbsoluteSize.X, 1), 0, 1)
    local v = math.floor(40 + 360 * rel + 0.5)
    asFovFill.Size = UDim2.new(rel, 0, 1, 0)
    asFovKnob.Position = UDim2.new(rel, 0, 0.5, 0)
    asFovVal.Text = tostring(v)
    Aimbot.FOV = v
    updateFOVCircle()
    Aimbot.AdjustUntil = tick() + 1.5
end
asFovTrack.InputBegan:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        asFovDragging = true; asFovSet(input.Position.X)
    end
end)
UIS.InputChanged:Connect(function(input)
    if not asFovDragging then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
        asFovSet(input.Position.X)
    end
end)
UIS.InputEnded:Connect(function(input)
    if not asFovDragging then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        asFovDragging = false
    end
end)

local asPalLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 176),
    Size = UDim2.new(1, -36, 0, 14),
    Text = "FOV COLOR", TextColor3 = P.SubText,
    Font = Enum.Font.GothamMedium, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
asPalLbl.Parent = aimSettings
reg(asPalLbl, "TextColor3", "SubText")

local asPalRow = new("Frame", {
    Position = UDim2.new(0, 18, 0, 196),
    Size = UDim2.new(1, -36, 0, 26),
    BackgroundTransparency = 1, ZIndex = 9,
})
asPalRow.Parent = aimSettings
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}).Parent = asPalRow

local AIM_PRESETS = {
    Color3.fromRGB(30, 64, 175),
    Color3.fromRGB(15, 40, 120),
    Color3.fromRGB(0, 210, 255),
    Color3.fromRGB(255, 60, 60),
    Color3.fromRGB(80, 220, 100),
    Color3.fromRGB(255, 220, 60),
    Color3.fromRGB(160, 95, 255),
    Color3.fromRGB(255, 255, 255),
}
local asSwatches = {}
local function aimSelectColor(c)
    Aimbot.Color = c
    updateFOVCircle()
    for _, s in ipairs(asSwatches) do
        local cur = s.color == c
        s.stroke.Transparency = cur and 0 or 0.6
        s.stroke.Thickness = cur and 2 or 1
    end
    logScript(string.format("AIM color RGB(%d,%d,%d)", c.R*255, c.G*255, c.B*255))
end
for i, c in ipairs(AIM_PRESETS) do
    local sw = new("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = c, BackgroundTransparency = 0,
        Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, LayoutOrder = i, ZIndex = 9,
    })
    round(sw, 6)
    local st3 = new("UIStroke", {
        Thickness = 1, Transparency = 0.6,
        Color = Color3.fromRGB(255,255,255),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    st3.Parent = sw
    if c.R > 0.95 and c.G > 0.95 and c.B > 0.95 then
        local blackSt = new("UIStroke", {
            Thickness = 2, Transparency = 0.15,
            Color = Color3.fromRGB(0,0,0),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
        blackSt.Parent = sw
    end
    sw.Parent = asPalRow
    table.insert(asSwatches, { bg = sw, stroke = st3, color = c })
    sw.MouseButton1Click:Connect(function() aimSelectColor(c) end)
end
aimSelectColor(Aimbot.Color)

if aimSettingsBtnRef then
    aimSettingsBtnRef.MouseButton1Click:Connect(function()
        _G.MerediosSettingsOpen = true
        aimSettings.Visible = true
        aimSettings.GroupTransparency = 1
        aimSettings.BackgroundTransparency = 1
        aimSettingsStroke.Transparency = 1
        aimSettings.Size = UDim2.new(0, 290, 0, 270)
        tween(aimSettings, 0.4, {
            GroupTransparency = 0,
            BackgroundTransparency = 0.02,
            Size = UDim2.new(0, 320, 0, 300),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(aimSettingsStroke, 0.4, { Transparency = 0.12 })
    end)
end

asClose.MouseButton1Click:Connect(function()
    _G.MerediosSettingsOpen = false
    tween(aimSettings, 0.3, {
        GroupTransparency = 1, BackgroundTransparency = 1,
        Size = UDim2.new(0, 290, 0, 270),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(aimSettingsStroke, 0.3, { Transparency = 1 })
    task.delay(0.3, function()
        aimSettings.Visible = false
        aimSettings.Size = UDim2.new(0, 320, 0, 300)
        aimSettings.GroupTransparency = 0
        aimSettings.BackgroundTransparency = 0.02
        aimSettingsStroke.Transparency = 0.12
    end)
end)

--=============================================================
-- NEW PAGE
--=============================================================
local newScroll = makePage("NEW")

do
    local card = makeCard(newScroll, 1, "ОБНОВЛЕНИЕ v7.7.5", "t.me//meredioshub", 300)
    local body = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 44),
        Size = UDim2.new(1, -36, 0, 250),
        Text = table.concat({
            "• FIX: весь скрипт в __MAIN + pcall",
            "• FIX: return true убран из глобала",
            "• FIX: диагностика ошибки на экран",
            "• FIX: os.date в pcall",
            "• FIX: Logger выше applyTheme",
            "• FIX: makeSwitch y работает",
            "• FIX: PlayerRemoving через буфер",
            "• WALLBANG — safe namecall hook",
            "• AIMBOT — visible-only, FOV, палитра",
            "• Telegram: t.me//meredioshub",
        }, "\n"),
        TextColor3 = P.Text,
        Font = Enum.Font.Gotham, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, ZIndex = 2,
    })
    body.Parent = card
    reg(body, "TextColor3", "Text")
end

do
    local card = makeCard(newScroll, 2, "TELEGRAM", "t.me//meredioshub", 66)
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -24, 0, 24),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.2,
        Text = "СКОПИРОВАТЬ TG", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 2,
    })
    round(btn, 8); btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        copyToClipboard("t.me//meredioshub")
        btn.Text = "СКОПИРОВАНО"
        task.delay(1.2, function() btn.Text = "СКОПИРОВАТЬ TG" end)
    end)
end

--=============================================================
-- GENERAL SETTINGS
--=============================================================
local settings = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 320, 0, 220),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 8,
})
round(settings, 16)
local settingsStroke = new("UIStroke", {
    Thickness = 1, Transparency = 0.12,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1,1,1),
})
settingsStroke.Parent = settings
new("UIGradient", { Color = GradientColors, Rotation = 30 }).Parent = settingsStroke
settingsStroke.Transparency = 1
settings.Parent = menu
reg(settings, "BackgroundColor3", "BgGlass")

local sTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 14),
    Size = UDim2.new(1, -70, 0, 16),
    Text = "SETTINGS · t.me//meredioshub", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
})
sTitle.Parent = settings
reg(sTitle, "TextColor3", "Text")

local sClose = new("TextButton", {
    Position = UDim2.new(1, -38, 0, 10),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 16,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 9,
})
round(sClose, 8); sClose.Parent = settings
reg(sClose, "BackgroundColor3", "Card"); reg(sClose, "TextColor3", "Text")

local function sRow(y, titleText)
    local row = new("Frame", {
        Position = UDim2.new(0, 18, 0, y),
        Size = UDim2.new(1, -36, 0, 30),
        BackgroundTransparency = 1, ZIndex = 9,
    })
    row.Parent = settings
    local lbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Text = titleText, TextColor3 = P.SubText,
        Font = Enum.Font.GothamMedium, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    })
    lbl.Parent = row
    reg(lbl, "TextColor3", "SubText")
    return row
end

local function segControl(parent, options, current, onSelect)
    local seg = new("Frame", {
        Position = UDim2.new(0, 90, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -90, 0, 24),
        BackgroundTransparency = 1, ZIndex = 9,
    })
    seg.Parent = parent
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }).Parent = seg
    local btns = {}
    local function refresh(sel)
        for k, b in pairs(btns) do
            local on = k == sel
            tween(b, 0.2, {
                BackgroundTransparency = on and 0.05 or 0.82,
                TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText,
            })
        end
    end
    for i, opt in ipairs(options) do
        local b = new("TextButton", {
            Size = UDim2.new(0, 52, 1, 0),
            BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.82,
            Text = opt, TextColor3 = P.SubText,
            Font = Enum.Font.GothamBold, TextSize = 8,
            AutoButtonColor = false, BorderSizePixel = 0,
            LayoutOrder = i, ZIndex = 9,
        })
        round(b, 6); b.Parent = seg
        btns[opt] = b
        b.MouseButton1Click:Connect(function() refresh(opt); if onSelect then onSelect(opt) end end)
    end
    refresh(current)
    return seg, refresh
end

segControl(sRow(52, "THEME"), { "LIGHT", "DARK" }, Theme.mode:upper(), function(v)
    Theme.mode = v == "DARK" and "Dark" or "Light"; applyTheme()
end)

segControl(sRow(88, "ACCENT"), { "DARKBLUE", "NAVY", "CYAN", "PURPLE", "PINK" }, "DARKBLUE", function(v)
    local map = { DARKBLUE = "DarkBlue", NAVY = "Navy", CYAN = "Cyan", PURPLE = "Purple", PINK = "Pink" }
    Theme.accent = map[v] or "DarkBlue"
    refreshPalettes(); applyTheme()
end)

segControl(sRow(124, "ANIM"), { "ON", "OFF" }, "ON", function(v) Theme.anim = (v == "ON") end)

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
reg(mBtn, "BackgroundColor3", "BgGlass"); reg(mBtn, "TextColor3", "Text")

local mBtnStroke = new("UIStroke", {
    Thickness = 1.5, Transparency = 0.05,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
    Color = Color3.new(1,1,1),
})
mBtnStroke.Parent = mBtn
local mBtnGrad = new("UIGradient", { Color = BluePinkSeq, Rotation = 30 })
mBtnGrad.Parent = mBtnStroke

task.spawn(function()
    while mBtn.Parent do
        local startRot = mBtnGrad.Rotation
        local tw = TS:Create(mBtnGrad,
            TweenInfo.new(3.2, Enum.EasingStyle.Linear),
            { Rotation = startRot + 360 })
        tw:Play(); tw.Completed:Wait()
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
    Thickness = 2, Transparency = 0.75,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    LineJoinMode = Enum.LineJoinMode.Round,
    Color = Color3.new(1,1,1),
})
mGlowStroke.Parent = mGlow
new("UIGradient", { Color = BluePinkSeq, Rotation = 30 }).Parent = mGlowStroke
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
    Text = "2 times to open", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 11,
    BorderSizePixel = 0, TextTransparency = 1, Visible = false, ZIndex = 60,
})
round(tapHint, 9)
local tapHintStroke = new("UIStroke", {
    Thickness = 1, Transparency = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.new(1,1,1),
})
tapHintStroke.Parent = tapHint
new("UIGradient", { Color = BluePinkSeq, Rotation = 30 }).Parent = tapHintStroke
tapHint.Parent = mBtn
reg(tapHint, "BackgroundColor3", "BgGlass"); reg(tapHint, "TextColor3", "Text")

local function showTapHint()
    tapHint.Visible = true
    tapHint.TextTransparency = 1
    tapHint.BackgroundTransparency = 1
    tapHintStroke.Transparency = 1
    tween(tapHint, 0.15, { TextTransparency = 0, BackgroundTransparency = 0.1 }, Enum.EasingStyle.Quint)
    tween(tapHintStroke, 0.15, { Transparency = 0.3 }, Enum.EasingStyle.Quint)
end
local function hideTapHint()
    tween(tapHint, 0.2, { TextTransparency = 1, BackgroundTransparency = 1 }, Enum.EasingStyle.Quint)
    tween(tapHintStroke, 0.2, { Transparency = 1 }, Enum.EasingStyle.Quint)
    task.delay(0.2, function()
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
            mBtn.Position = UDim2.new(
                0, math.clamp(startAbs.X + d.X, 0, vp.X - 52),
                0, math.clamp(startAbs.Y + d.Y, 0, vp.Y - 52))
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
                tapCount = 0; hideTapHint()
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
    for tName, page in pairs(contentPages) do
        page.Visible = (tName == activeTab)
        if tName == activeTab then
            page.Position = UDim2.new(0, 0, 0, 0)
            page.GroupTransparency = 0
        end
    end
    for tName, btn in pairs(tabButtons) do
        local on = (tName == activeTab)
        btn.BackgroundTransparency = on and 0.05 or 0.85
        btn.TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText
        local st = btn:FindFirstChildOfClass("UIStroke")
        if st then st.Transparency = on and 0 or 0.5 end
    end

    menu.Visible = true
    menu.GroupTransparency = 1
    menu.BackgroundTransparency = 0.04
    menuStroke.Transparency = 1
    tween(menu, 0.35, { GroupTransparency = 0 })
    tween(menuStroke, 0.35, { Transparency = 0.05 })
end

local function closeMenu()
    _G.MerediosSettingsOpen = false
    closeToken = closeToken + 1
    local myToken = closeToken
    tween(menu, 0.3, { GroupTransparency = 1 })
    tween(menuStroke, 0.3, { Transparency = 1 })
    tween(settings, 0.3, { GroupTransparency = 1, BackgroundTransparency = 1 })
    tween(settingsStroke, 0.3, { Transparency = 1 })
    tween(aimSettings, 0.3, { GroupTransparency = 1, BackgroundTransparency = 1 })
    tween(aimSettingsStroke, 0.3, { Transparency = 1 })
    task.delay(0.3, function()
        if closeToken ~= myToken then return end
        menu.Visible = false
        menu.GroupTransparency = 0
        settings.Visible = false
        settings.GroupTransparency = 1
        settings.BackgroundTransparency = 0.02
        settingsStroke.Transparency = 0.12
        aimSettings.Visible = false
        aimSettings.GroupTransparency = 1
        aimSettings.BackgroundTransparency = 0.02
        aimSettingsStroke.Transparency = 0.12
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
            mBtn.TextColor3 = BluePinkSeq:Evaluate(((tick() - t0) / 0.55) % 1)
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
    settings.Size = UDim2.new(0, 290, 0, 200)
    tween(settings, 0.4, {
        GroupTransparency = 0, BackgroundTransparency = 0.02,
        Size = UDim2.new(0, 320, 0, 220),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    tween(settingsStroke, 0.4, { Transparency = 0.12 })
end)

sClose.MouseButton1Click:Connect(function()
    _G.MerediosSettingsOpen = false
    local myToken = closeToken + 1
    closeToken = myToken
    tween(settings, 0.3, {
        GroupTransparency = 1, BackgroundTransparency = 1,
        Size = UDim2.new(0, 290, 0, 200),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(settingsStroke, 0.3, { Transparency = 1 })
    task.delay(0.3, function()
        if closeToken ~= myToken then return end
        settings.Visible = false
        settings.Size = UDim2.new(0, 320, 0, 220)
        settings.GroupTransparency = 0
        settings.BackgroundTransparency = 0.02
        settingsStroke.Transparency = 0.12
    end)
end)

--=============================================================
-- START HANDLER
--=============================================================
local started_lock = false
local function onStartBtn()
    if started_lock then return end
    started_lock = true
    started = true
    logScript("START pressed")
    pcall(function()
        tween(startup, 0.4, { BackgroundTransparency = 1 })
        tween(startupStroke, 0.4, { Transparency = 1 })
        tween(startupTitle, 0.4, { TextTransparency = 1 })
        tween(startupSub, 0.4, { TextTransparency = 1 })
        tween(startupTapLbl, 0.4, { TextTransparency = 1 })
        tween(startPill, 0.4, { BackgroundTransparency = 1 })
        tween(startPillLbl, 0.4, { TextTransparency = 1 })
    end)
    task.delay(0.4, function()
        startup.Visible = false
        openMenu()
        logScript("Meredios HUD v7.7.5 started")
    end)
end

startup.MouseButton1Click:Connect(onStartBtn)
startup.Activated:Connect(onStartBtn)
pcall(function() startup.TouchTap:Connect(onStartBtn) end)
pcall(function() startup.TouchLongPress:Connect(onStartBtn) end)

startPill.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        onStartBtn()
    end
end)

UIS.InputBegan:Connect(function(input)
    if started_lock then return end
    if not startup or not startup.Visible then return end
    if input.UserInputType == Enum.UserInputType.Touch
       or input.UserInputType == Enum.UserInputType.MouseButton1 then
        onStartBtn()
    end
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
aimSettings.Visible = false
aimSettings.GroupTransparency = 1
aimSettings.BackgroundTransparency = 0.02
aimSettingsStroke.Transparency = 1
mBtn.Visible = false

logScript("Kernel loaded · v7.7.5")
logScript("t.me//meredioshub")
logScript("START: tap anywhere on panel")
renderLog()

print("[M7] end of script")

end  -- __MAIN

local __ok, __err = pcall(__MAIN)
if not __ok then
    warn("[MEREDIOS ERROR] " .. tostring(__err))
    local sg = Instance.new("ScreenGui")
    sg.Name = "MerediosErr"
    sg.DisplayOrder = 100000
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then
        pcall(function() sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 3) end)
    end
    if sg.Parent then
        local box = Instance.new("TextLabel")
        box.Size = UDim2.new(0, 520, 0, 240)
        box.Position = UDim2.new(0, 20, 0, 20)
        box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        box.BackgroundTransparency = 0.1
        box.TextColor3 = Color3.fromRGB(255, 90, 90)
        box.Text = "MEREDIOS ERROR:\n\n" .. tostring(__err)
        box.TextWrapped = true
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Font = Enum.Font.Code
        box.TextSize = 13
        box.Parent = sg
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = box
    end
end
