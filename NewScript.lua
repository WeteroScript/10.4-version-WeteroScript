--[[
    MEREDIOS HUD v8.6 · register-safe
    t.me//meredioshub
    fixes: do..end scoping, PostAsync -> request, Logger forward-decl,
           UIPadding allocation, new() parent-as-table bug,
           morph started-flag propagation
]]

--================= TOP SERVICES =================
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TS           = game:GetService("TweenService")
local TeleportSvc  = game:GetService("TeleportService")
local HttpSvc      = game:GetService("HttpService")
local LP = Players.LocalPlayer
if not LP then repeat task.wait(0.1); LP = Players.LocalPlayer until LP end
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

--================= SHARED DECLS =================
local P, Accent
local ThemeReg       = {}
local SwitchRegistry = {}
local LogTabButtons  = {}
local SegRegistry    = {}
local Logger
local ESP, HitboxChanger, Speed, AntiFling, Aimbot
local ScreenGui, startup, menu, settings, aimPanel, filterPanel, mBtn
local keyValidated = false

--================= THEME TABLES =================
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
    DarkBlue = { Main = Color3.fromRGB(30,64,175), Dim = Color3.fromRGB(20,45,130) },
    Navy     = { Main = Color3.fromRGB(15,40,120), Dim = Color3.fromRGB(10,28,88) },
    Cyan     = { Main = Color3.fromRGB(0,210,255), Dim = Color3.fromRGB(0,140,190) },
    Purple   = { Main = Color3.fromRGB(160,95,255), Dim = Color3.fromRGB(100,55,180) },
    Pink     = { Main = Color3.fromRGB(255,95,175), Dim = Color3.fromRGB(190,55,130) },
}
local FlowColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(30,64,175)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90,130,240)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(160,95,255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255,95,175)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30,64,175)),
})
local BluePinkSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20,45,130)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(90,130,240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,95,175)),
})
local function refreshPalettes() P = Palettes[Theme.mode]; Accent = Accents[Theme.accent] end
refreshPalettes()

--================= SHARED HELPERS =================
local function new(c, p)
    local o = Instance.new(c); if p then for k,v in pairs(p) do o[k]=v end end; return o
end
local function tween(o, t, p, s, d)
    local info = TweenInfo.new(t or 0.28, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out)
    local tw = TS:Create(o, info, p); tw:Play(); return tw
end
local function round(o, r)
    local c = new("UICorner", { CornerRadius = UDim.new(0, r or 12) }); c.Parent = o; return c
end

local AnimatedGradients = {}
local function registerGrad(g, speed)
    if not g then return end
    table.insert(AnimatedGradients, { g = g, speed = speed or 25, base = g.Rotation or 0 })
end
do
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
end

local function gradientStroke(parent, thickness, transparency, rotation)
    local stroke = new("UIStroke", {
        Thickness = thickness or 2,
        Transparency = transparency or 0.05,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Round,
        Color = Color3.new(1,1,1),
    })
    stroke.Parent = parent
    local grad = new("UIGradient", { Color = FlowColors, Rotation = rotation or 35 })
    grad.Parent = stroke
    registerGrad(grad, 30)
    return stroke, grad
end

local function dragify(frame, handle, canDrag)
    handle = handle or frame
    do
        local dragging, dragStart, startPos = false, nil, nil
        handle.InputBegan:Connect(function(input)
            if canDrag and not canDrag() then return end
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = frame.Position
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then dragging = false end
        end)
    end
end

local function reg(inst, prop, key)
    table.insert(ThemeReg, { inst, prop, key })
    if inst and inst.Parent then inst[prop] = P[key] end
end

local function logLine(channel, text)
    local buf = Logger.buffer[channel]; if not buf then return end
    table.insert(buf, "[" .. os.date("%H:%M:%S") .. "] " .. text)
    while #buf > Logger.maxLen do table.remove(buf, 1) end
    for _, cb in ipairs(Logger.listeners) do pcall(cb, channel) end
end
local function logScript(t) logLine("script", t) end
local function logServer(t) logLine("server", t) end

--================= APPLY THEME =================
local function applyTheme()
    refreshPalettes()
    for _, e in ipairs(ThemeReg) do
        local inst, prop, key = e[1], e[2], e[3]
        if inst and inst.Parent then tween(inst, 0.32, { [prop] = P[key] }) end
    end
    for _, s in ipairs(SwitchRegistry) do
        if s.card and s.card.Parent then
            s.track.BackgroundColor3 = s.state and Accent.Main or P.Track
            s.knob.BackgroundColor3 = P.Knob
            s.lbl.TextColor3 = s.state and Accent.Main or P.SubText
        end
    end
    for _, entry in ipairs(LogTabButtons) do
        local active = Logger and (entry.name == Logger.activeTab)
        entry.btn.BackgroundColor3 = active and Accent.Main or P.Card
        entry.btn.TextColor3 = active and Color3.fromRGB(255,255,255) or P.SubText
    end
    for _, seg in ipairs(SegRegistry) do
        if seg.refresh then seg.refresh(seg.get_current()) end
    end
end

--================= KEY GATE =================
local API_URL    = "https://bot-1789589906-7119-weterochina.bothost.tech/validate"
local API_SECRET = "hK2pX9qLm4vN8sT1wZ6yB3cD7fG0jR5aQxYzWvUtSrPo"
local KICK_REASON = "key is not allowed"
local AUTO_KICK   = false
local KICK_STATUS = { not_found=true, revoked=true, expired=true, hwid_mismatch=true, missing_fields=true }
local STATUS_TEXT = {
    not_found="ключ не найден", revoked="ключ отозван",
    expired="ключ истёк", hwid_mismatch="HWID занят · сбрось в боте",
    unauthorized="API-секрет неверный", bad_json="ошибка формата",
    missing_fields="пустой ключ",
}
local HWID
do
    local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if ok and id then HWID = id else HWID = tostring(LP.UserId) .. ":" .. tostring(game.PlaceId) end
end
local function httpRequest(opts)
    local fns = {}
    if syn and syn.request then table.insert(fns, syn.request) end
    if http and http.request then table.insert(fns, http.request) end
    if type(request) == "function" then table.insert(fns, request) end
    if type(http_request) == "function" then table.insert(fns, http_request) end
    for _, fn in ipairs(fns) do
        local ok, resp = pcall(fn, opts)
        if ok and resp then
            local body = resp.Body or resp.body
            if body then return body end
        end
    end
    return nil
end
local function requestValidate(key)
    local body = HttpSvc:JSONEncode({ key = key, hwid = HWID })
    local resp = httpRequest({
        Url = API_URL, Method = "POST", Body = body,
        Headers = { ["Content-Type"] = "application/json", ["X-Api-Secret"] = API_SECRET },
    })
    if not resp then return nil end
    local okd, data = pcall(function() return HttpSvc:JSONDecode(resp) end)
    if not okd then return nil end
    return data
end

--================= SCREEN GUI =================
do
    local targets = {}
    pcall(function() table.insert(targets, game:GetService("CoreGui")) end)
    pcall(function() table.insert(targets, LP:WaitForChild("PlayerGui", 5)) end)
    for _, p in ipairs(targets) do
        if p then
            for _, g in ipairs(p:GetChildren()) do
                if g.Name == "MerediosHUD" then pcall(function() g:Destroy() end) end
            end
        end
    end
end
ScreenGui = new("ScreenGui")
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

--================= LOGGER =================
Logger = {
    buffer = { server = {}, script = {} }, maxLen = 600,
    listeners = {}, filterListeners = {},
    activeTab = "script", filters = {}, knownRemotes = {},
}

do
    local function copyToClipboard(text)
        local fns = { setclipboard, toclipboard, writeclipboard }
        for _, fn in ipairs(fns) do
            if type(fn) == "function" then
                local ok = pcall(fn, text); if ok then return true end
            end
        end
        return false
    end
    local function buildLogText()
        local out = {}
        table.insert(out, "=== SERVER LOG ===")
        if #Logger.buffer.server == 0 then table.insert(out, "(empty)") end
        for _, l in ipairs(Logger.buffer.server) do table.insert(out, l) end
        table.insert(out, ""); table.insert(out, "=== SCRIPT LOG ===")
        if #Logger.buffer.script == 0 then table.insert(out, "(empty)") end
        for _, l in ipairs(Logger.buffer.script) do table.insert(out, l) end
        return table.concat(out, "\n")
    end
    Logger.copy = copyToClipboard
    Logger.buildText = buildLogText
end

do
    local function fmtArg(a)
        local t = typeof(a)
        if t == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", a.X, a.Y, a.Z)
        elseif t == "Vector2" then return string.format("V2(%.1f,%.1f)", a.X, a.Y)
        elseif t == "CFrame" then return "CFrame"
        elseif t == "Instance" then
            local ok, n = pcall(function() return a:GetFullName() end)
            return ok and n or "Instance"
        elseif t == "table" then return "{table}"
        else return tostring(a) end
    end
    local remoteRateCount, remoteRateWindow = 0, 0
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
        if now > remoteRateWindow then remoteRateWindow = now + 1; remoteRateCount = 0 end
        if remoteRateCount >= MAX_REMOTE_RATE then return end
        remoteRateCount = remoteRateCount + 1
        local parts = {}
        for i = 1, math.min(#args, 8) do parts[i] = fmtArg(args[i]) end
        local suffix = #args > 8 and (" ...(+" .. (#args - 8) .. ")") or ""
        logServer("REMOTE " .. name .. "(" .. table.concat(parts, ", ") .. ")" .. suffix)
    end
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
                if not okSet then logScript("Remote hook failed: " .. tostring(err)) end
            end
        end
    end
end

--================= HITBOX =================
HitboxChanger = { Enabled=false, View=false, Size=12, Original={} }
do
    local function hitboxParts(char)
        if not char then return {} end
        local list = {}
        for _, name in ipairs({"HumanoidRootPart","Head","UpperTorso","Torso","LowerTorso"}) do
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then table.insert(list, p) end
        end
        return list
    end
    HitboxChanger.parts = hitboxParts

    function HitboxChanger.apply(char)
        if not char then return end
        for _, part in ipairs(hitboxParts(char)) do
            if not HitboxChanger.Original[part] then
                HitboxChanger.Original[part] = {
                    Size=part.Size, Transparency=part.Transparency,
                    CanCollide=part.CanCollide, CanQuery=part.CanQuery,
                }
            end
            part.Size = Vector3.new(HitboxChanger.Size, HitboxChanger.Size, HitboxChanger.Size)
            part.Transparency = 1
            part.CanCollide = false
            part.CanQuery = true
        end
    end
    function HitboxChanger.restore(char)
        if not char then return end
        for part, orig in pairs(HitboxChanger.Original) do
            if part and part.Parent and part:IsDescendantOf(char) then
                pcall(function()
                    part.Size=orig.Size; part.Transparency=orig.Transparency
                    part.CanCollide=orig.CanCollide; part.CanQuery=orig.CanQuery
                end)
                HitboxChanger.Original[part] = nil
            end
        end
    end
    function HitboxChanger.applyAll()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then HitboxChanger.apply(plr.Character) end
        end
    end
    function HitboxChanger.restoreAll()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then HitboxChanger.restore(plr.Character) end
        end
    end
    function HitboxChanger.viewOn(char)
        if not char then return end
        for _, part in ipairs(hitboxParts(char)) do
            if not part:FindFirstChild("MerediosHitboxView") then
                new("BoxHandleAdornment", {
                    Name="MerediosHitboxView", Adornee=part,
                    AlwaysOnTop=true, ZIndex=5, Transparency=0.5,
                    Color3=Accent.Main, Size=part.Size,
                }).Parent = part
            end
        end
    end
    function HitboxChanger.viewOff(char)
        if not char then return end
        for _, part in ipairs(hitboxParts(char)) do
            local v = part:FindFirstChild("MerediosHitboxView")
            if v then pcall(function() v:Destroy() end) end
        end
    end
    function HitboxChanger.viewAllOn()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then HitboxChanger.viewOn(plr.Character) end
        end
    end
    function HitboxChanger.viewAllOff()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then HitboxChanger.viewOff(plr.Character) end
        end
    end
    function HitboxChanger.viewRefresh()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _, part in ipairs(hitboxParts(plr.Character)) do
                    local v = part:FindFirstChild("MerediosHitboxView")
                    if v then v.Size = part.Size end
                end
            end
        end
    end
end

--================= ESP =================
do
    local VISIBLE_COLOR = Color3.fromRGB(80,220,100)
    ESP = {
        Enabled=false, Color=Color3.fromRGB(255,95,175), ColorName="PINK",
        VisibilityCheck=false, Highlights={}, LastCheck={}, CheckInterval=0.12,
        Palette = {
            {name="PINK",color=Color3.fromRGB(255,95,175)},
            {name="RED",color=Color3.fromRGB(255,60,60)},
            {name="ORANGE",color=Color3.fromRGB(255,140,40)},
            {name="YELLOW",color=Color3.fromRGB(255,220,60)},
            {name="GREEN",color=VISIBLE_COLOR},
            {name="CYAN",color=Color3.fromRGB(0,210,255)},
            {name="BLUE",color=Color3.fromRGB(30,64,175)},
            {name="PURPLE",color=Color3.fromRGB(160,95,255)},
            {name="WHITE",color=Color3.fromRGB(255,255,255)},
        },
    }
    function ESP.hasLineOfSight(char)
        if not char then return false end
        local cam = workspace.CurrentCamera; if not cam then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LP.Character }
        params.IgnoreWater = true
        local origin = cam.CFrame.Position
        for _, name in ipairs({"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}) do
            local part = char:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                local hit = workspace:Raycast(origin, part.Position - origin, params)
                if hit and hit.Instance and hit.Instance:IsA("BasePart")
                   and hit.Instance:IsDescendantOf(char) then return true end
            end
        end
        return false
    end
    function ESP.style(h, plr)
        local visible = ESP.VisibilityCheck and ESP.hasLineOfSight(plr.Character)
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
    function ESP.update(plr)
        if ESP.Highlights[plr] then
            pcall(function() ESP.Highlights[plr]:Destroy() end); ESP.Highlights[plr] = nil
        end
        ESP.LastCheck[plr] = nil
        if not ESP.Enabled or plr == LP then return end
        local char = plr.Character; if not char then return end
        local existing = char:FindFirstChild("MerediosESP"); if existing then existing:Destroy() end
        local h = Instance.new("Highlight")
        h.Name="MerediosESP"; h.FillColor=ESP.Color; h.FillTransparency=0.75
        h.OutlineColor=ESP.Color; h.OutlineTransparency=0
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=char
        ESP.Highlights[plr] = h
        ESP.style(h, plr); ESP.LastCheck[plr] = tick()
    end
    function ESP.refreshAll()
        for _, plr in ipairs(Players:GetPlayers()) do ESP.update(plr) end
    end
    function ESP.reapplyAll()
        for plr, h in pairs(ESP.Highlights) do
            if h and h.Parent then ESP.style(h, plr) end
        end
    end
    function ESP.removeFromChar(char)
        if not char then return end
        local h = char:FindFirstChild("MerediosESP"); if h then pcall(function() h:Destroy() end) end
    end
    RunService.Heartbeat:Connect(function()
        if not ESP.Enabled or not ESP.VisibilityCheck then return end
        local now = tick()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local h = ESP.Highlights[plr]; local last = ESP.LastCheck[plr] or 0
                if h and h.Parent and (now - last) >= ESP.CheckInterval then
                    ESP.LastCheck[plr] = now; ESP.style(h, plr)
                end
            end
        end
    end)
end

--================= SPEED / ANTI-FLING =================
Speed = { Enabled=false, Value=32 }
AntiFling = { Enabled=false }
RunService.Heartbeat:Connect(function()
    if Speed.Enabled then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= Speed.Value then hum.WalkSpeed = Speed.Value end
    end
    if AntiFling.Enabled then
        local char = LP.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel, ang = hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity
                local speed, spin = vel.Magnitude, ang.Magnitude
                if speed > 200 or spin > 20 or vel.Y > 120 then
                    local finalVel = vel
                    if speed > 200 then finalVel = vel.Unit * math.min(speed, 60) end
                    if vel.Y > 120 then finalVel = Vector3.new(finalVel.X, 0, finalVel.Z) end
                    hrp.AssemblyLinearVelocity = finalVel
                    if spin > 20 then hrp.AssemblyAngularVelocity = ang.Unit * 5 end
                end
            end
        end
    end
end)

--================= AIMBOT =================
Aimbot = {
    Enabled=false, FOV=140, Color=Color3.fromRGB(255,255,255), ColorName="WHITE",
    VisibleOnly=false, ReleaseThreshold=90, ReleaseWindow=0.10,
    MoveAccum=0, LockReleaseUntil=0, Target=nil, LockedTarget=nil, ActiveGameTouch=nil,
}
local fovWrap, fovCircle, fovStroke, fovOuterStroke, updateFOVCircle, setAimbotColor
do
    fovWrap = new("Frame", {
        Name="MerediosFOVWrap",
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0, Aimbot.FOV*2+8, 0, Aimbot.FOV*2+8),
        BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=0,
    })
    round(fovWrap, Aimbot.FOV + 4)
    fovOuterStroke = new("UIStroke", {
        Thickness=2.5, Color=Color3.fromRGB(0,0,0), Transparency=1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, LineJoinMode=Enum.LineJoinMode.Round,
    })
    fovOuterStroke.Parent = fovWrap
    fovCircle = new("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,-8,1,-8), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=1,
    })
    round(fovCircle, Aimbot.FOV)
    fovStroke = new("UIStroke", {
        Thickness=3, Color=Aimbot.Color, Transparency=0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, LineJoinMode=Enum.LineJoinMode.Round,
    })
    fovStroke.Parent = fovCircle
    fovCircle.Parent = fovWrap
    fovWrap.Parent = ScreenGui

    updateFOVCircle = function()
        fovWrap.Size = UDim2.new(0, Aimbot.FOV*2+8, 0, Aimbot.FOV*2+8)
        local wc = fovWrap:FindFirstChildOfClass("UICorner")
        if wc then wc.CornerRadius = UDim.new(0, Aimbot.FOV + 4) end
        local ic = fovCircle:FindFirstChildOfClass("UICorner")
        if ic then ic.CornerRadius = UDim.new(0, Aimbot.FOV) end
        fovStroke.Color = Aimbot.Color
        fovOuterStroke.Transparency = (Aimbot.ColorName == "WHITE") and 0 or 1
    end
    setAimbotColor = function(name, color)
        Aimbot.ColorName = name; Aimbot.Color = color; updateFOVCircle()
    end
    updateFOVCircle()

    Aimbot._fovWrap = fovWrap
    Aimbot._updateFOV = updateFOVCircle
    Aimbot._setColor = setAimbotColor
end

do
    local function getHeadPos(plr)
        local char = plr.Character; if not char then return nil end
        local head = char:FindFirstChild("Head")
        if head and head:IsA("BasePart") then return head.Position end
        return nil
    end
    local function isAlive(plr)
        if not plr then return false end
        local char = plr.Character; if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end
    local function findNearestTarget()
        local cam = workspace.CurrentCamera; if not cam then return nil end
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        local best, bestDist = nil, Aimbot.FOV
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and isAlive(plr) then
                local pos = getHeadPos(plr)
                if pos then
                    local sp, onScreen = cam:WorldToViewportPoint(pos)
                    if onScreen and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d <= bestDist and (not Aimbot.VisibleOnly or ESP.hasLineOfSight(plr.Character)) then
                            best, bestDist = plr, d
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
        local cf = CFrame.new(camPos, pos)
        local rx, ry, _ = cf:ToOrientation()
        cam.CFrame = CFrame.fromOrientation(rx, ry, 0) + camPos
    end
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Touch then Aimbot.ActiveGameTouch = input end
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
        fovWrap.Visible = Aimbot.Enabled
        if not Aimbot.Enabled then
            Aimbot.MoveAccum = 0; Aimbot.Target = nil; Aimbot.LockedTarget = nil
            prevTargetLogged = nil; return
        end
        if UIS.GetFocusedTextBox and UIS:GetFocusedTextBox() then return end
        if Aimbot.MoveAccum >= Aimbot.ReleaseThreshold then
            Aimbot.LockReleaseUntil = now + Aimbot.ReleaseWindow
            Aimbot.MoveAccum = 0; Aimbot.LockedTarget = nil
        end
        if now < Aimbot.LockReleaseUntil then Aimbot.Target = nil; return end
        local target = Aimbot.LockedTarget
        if target then
            if not isAlive(target) then target = nil; Aimbot.LockedTarget = nil
            elseif Aimbot.VisibleOnly and not ESP.hasLineOfSight(target.Character) then
                target = nil; Aimbot.LockedTarget = nil
            end
        end
        if not target then target = findNearestTarget(); Aimbot.LockedTarget = target end
        Aimbot.Target = target
        if target then
            snapCameraTo(target)
            if target ~= prevTargetLogged then
                logScript("Aimbot lock → " .. target.Name); prevTargetLogged = target
            end
        else
            prevTargetLogged = nil
        end
    end
    pcall(function() RunService:UnbindFromRenderStep("MerediosAimbot") end)
    RunService:BindToRenderStep("MerediosAimbot", Enum.RenderPriority.Camera.Value + 10, aimbotStep)
end

--================= PLAYER HOOKS =================
do
    local hookedPlayers = {}
    local function hookPlayerForCombat(plr)
        if hookedPlayers[plr] then return end
        hookedPlayers[plr] = true
        plr.CharacterAdded:Connect(function(char)
            logServer(plr.Name .. " spawned")
            task.wait(0.25)
            if HitboxChanger.Enabled then HitboxChanger.apply(char) end
            if HitboxChanger.View then HitboxChanger.viewOn(char) end
            if ESP.Enabled then ESP.update(plr) end
        end)
        plr.CharacterRemoving:Connect(function(char)
            ESP.removeFromChar(char); HitboxChanger.viewOff(char); HitboxChanger.restore(char)
            logServer(plr.Name .. " despawned")
        end)
        if plr.Character then
            task.spawn(function()
                task.wait(0.2)
                if HitboxChanger.Enabled then HitboxChanger.apply(plr.Character) end
                if HitboxChanger.View then HitboxChanger.viewOn(plr.Character) end
                if ESP.Enabled then ESP.update(plr) end
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
                    part.Size=orig.Size; part.Transparency=orig.Transparency
                    part.CanCollide=orig.CanCollide; part.CanQuery=orig.CanQuery
                end)
                HitboxChanger.Original[part] = nil
            end
        end
        if ESP.Highlights[plr] then
            pcall(function() ESP.Highlights[plr]:Destroy() end); ESP.Highlights[plr] = nil
        end
        ESP.LastCheck[plr] = nil
    end)
    task.spawn(function()
        local ok, chat = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 5)
        end)
        if ok and chat then
            local ev = chat:FindFirstChild("OnMessageDoneFiltering")
            if ev and ev:IsA("RemoteEvent") then
                ev.OnClientEvent:Connect(function(data)
                    if data and data.MessageText and data.FromSpeaker then
                        logServer("CHAT " .. data.FromSpeaker .. ": " .. tostring(data.MessageText))
                    end
                end)
            end
        end
    end)
    LP.CharacterAdded:Connect(function(char)
        logServer("local respawned")
        task.wait(0.25)
        if Speed.Enabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Speed.Value end
        end
    end)
end

--================= SERVER HOP =================
local serverHop, emptyHop
do
    local function httpGet(url) return httpRequest({ Url = url, Method = "GET" }) end
    local function fetchServerList(pages)
        pages = pages or 3
        local all, cursor = {}, nil
        for _ = 1, pages do
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                "/servers/Public?limit=100" .. (cursor and ("&cursor=" .. cursor) or "")
            local body = httpGet(url); if not body then break end
            local ok, data = pcall(function() return HttpSvc:JSONDecode(body) end)
            if not ok or type(data) ~= "table" or type(data.data) ~= "table" then break end
            for _, s in ipairs(data.data) do
                if type(s) == "table" and s.id then table.insert(all, s) end
            end
            cursor = data.nextPageCursor
            if not cursor or cursor == "" then break end
        end
        return all
    end
    local function hopTo(server)
        if not server or not server.id then return false end
        return pcall(function() TeleportSvc:TeleportToPlaceInstance(game.PlaceId, server.id, LP) end)
    end
    serverHop = function()
        logScript("ServerHop: fetching...")
        local servers = fetchServerList(3)
        if not servers or #servers == 0 then logScript("ServerHop: HTTP unavailable"); return end
        local cur = game.JobId; local cand = {}
        for _, s in ipairs(servers) do
            if s.id and s.id ~= cur then
                local pop, cap = tonumber(s.playing), tonumber(s.maxPlayers)
                if pop and cap and pop < cap then table.insert(cand, s) end
            end
        end
        if #cand == 0 then logScript("ServerHop: no open servers"); return end
        local pick = cand[math.random(1, #cand)]
        logScript("ServerHop → " .. pick.id .. " · " .. pick.playing .. "/" .. pick.maxPlayers)
        if not hopTo(pick) then logScript("ServerHop: teleport failed") end
    end
    emptyHop = function()
        logScript("EmptyHop: fetching...")
        local servers = fetchServerList(3)
        if not servers or #servers == 0 then logScript("EmptyHop: HTTP unavailable"); return end
        local cur = game.JobId; local empty, lowest, lowestPop
        for _, s in ipairs(servers) do
            if s.id and s.id ~= cur then
                local pop, cap = tonumber(s.playing), tonumber(s.maxPlayers)
                if pop and cap and pop < cap then
                    if pop == 0 and not empty then empty = s end
                    if not lowest or pop < lowestPop then lowest, lowestPop = s, pop end
                end
            end
        end
        local pick = empty or lowest
        if not pick then logScript("EmptyHop: none found"); return end
        logScript("EmptyHop (" .. (empty and "EMPTY" or ("LOWEST "..lowestPop)) .. ") → " .. pick.id)
        if not hopTo(pick) then logScript("EmptyHop: teleport failed") end
    end
end

--================= STARTUP + KEY GATE =================
do
    local STARTUP_W, STARTUP_H = 300, 200
    startup = new("CanvasGroup", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0, STARTUP_W, 0, STARTUP_H),
        BackgroundColor3=P.BgGlass, BackgroundTransparency=0.05,
        BorderSizePixel=0, GroupTransparency=1,
    })
    round(startup, 18)
    local startupStroke = gradientStroke(startup, 2.5, 0.08, 30)
    startupStroke.Transparency = 1
    startup.Parent = ScreenGui
    reg(startup, "BackgroundColor3", "BgGlass")

    local startupTitle = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0, -60, 0, 16),
        Size=UDim2.new(1, -32, 0, 26), Text="Meredios", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=22,
        TextXAlignment=Enum.TextXAlignment.Left, TextTransparency=1,
    })
    startupTitle.Parent = startup
    reg(startupTitle, "TextColor3", "Text")

    local startupSub = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0, -40, 0, 42),
        Size=UDim2.new(1, -32, 0, 12), Text="// v8.6 · t.me//meredioshub",
        TextColor3=P.SubText, Font=Enum.Font.Code, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left, TextTransparency=1,
    })
    startupSub.Parent = startup
    reg(startupSub, "TextColor3", "SubText")

    local keyRow = new("Frame", {
        Position=UDim2.new(0, 18, 0, 66), Size=UDim2.new(1, -36, 0, 30),
        BackgroundTransparency=1, Visible=false,
    })
    keyRow.Parent = startup

    local keyBox = new("TextBox")
    keyBox.Parent = keyRow
    keyBox.Position = UDim2.new(0, 0, 0, 0)
    keyBox.Size = UDim2.new(1, -38, 1, 0)
    keyBox.BackgroundColor3 = P.Bg
    keyBox.BackgroundTransparency = 0.3
    keyBox.BorderSizePixel = 0
    keyBox.Text = ""
    keyBox.PlaceholderText = "MerediosHUB-XXXX..."
    keyBox.TextColor3 = P.Text
    keyBox.PlaceholderColor3 = P.SubText
    keyBox.Font = Enum.Font.Code
    keyBox.TextSize = 11
    keyBox.ClearTextOnFocus = false
    keyBox.TextXAlignment = Enum.TextXAlignment.Left
    round(keyBox, 7)
    do
        local kp = Instance.new("UIPadding")
        kp.PaddingLeft = UDim.new(0, 8)
        kp.Parent = keyBox
    end
    reg(keyBox, "BackgroundColor3", "Bg")
    reg(keyBox, "TextColor3", "Text")
    reg(keyBox, "PlaceholderColor3", "SubText")

    local keyClear = new("TextButton")
    keyClear.Parent = keyRow
    keyClear.AnchorPoint = Vector2.new(1, 0)
    keyClear.Position = UDim2.new(1, 0, 0, 0)
    keyClear.Size = UDim2.new(0, 32, 1, 0)
    keyClear.BackgroundColor3 = Color3.fromRGB(52, 40, 56)
    keyClear.Text = "✕"
    keyClear.TextColor3 = Color3.fromRGB(255, 120, 140)
    keyClear.Font = Enum.Font.GothamBold
    keyClear.TextSize = 13
    keyClear.AutoButtonColor = false
    keyClear.BorderSizePixel = 0
    round(keyClear, 7)

    local keyStatus = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0, 18, 0, 100),
        Size=UDim2.new(1, -36, 0, 14), Text="",
        TextColor3=Color3.fromRGB(255, 90, 90),
        Font=Enum.Font.Gotham, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left, Visible=false,
    })
    keyStatus.Parent = startup

    local checkBtn = new("TextButton", {
        Position=UDim2.new(0, 18, 1, -50), Size=UDim2.new(0, 100, 0, 28),
        BackgroundColor3=Accent.Main, BackgroundTransparency=1,
        Text="CHECK KEY", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=10,
        AutoButtonColor=false, BorderSizePixel=0, TextTransparency=1,
    })
    round(checkBtn, 8); checkBtn.Parent = startup

    local startBtn = new("TextButton", {
        AnchorPoint=Vector2.new(1, 0), Position=UDim2.new(1, -18, 1, -50),
        Size=UDim2.new(0, 110, 0, 28),
        BackgroundColor3=Accent.Main, BackgroundTransparency=1,
        Text="НАЧАТЬ", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=11,
        AutoButtonColor=false, BorderSizePixel=0, TextTransparency=1,
    })
    round(startBtn, 8); startBtn.Parent = startup

    tween(startup, 0.45, { GroupTransparency = 0 })
    tween(startupStroke, 0.45, { Transparency = 0.08 })

    task.spawn(function()
        task.wait(0.6)
        if not startup.Parent then return end
        tween(startupTitle, 0.45, { Position=UDim2.new(0, 18, 0, 16), TextTransparency=0 })
        tween(startupSub, 0.45, { Position=UDim2.new(0, 18, 0, 42), TextTransparency=0 })
        task.wait(0.15)
        keyRow.Visible = true
        keyStatus.Visible = true
        tween(checkBtn, 0.35, { BackgroundTransparency=0.15, TextTransparency=0 })
        tween(startBtn, 0.35, { BackgroundTransparency=0.85, TextTransparency=0.4 })
    end)

    keyClear.MouseButton1Click:Connect(function()
        keyBox.Text = ""; keyStatus.Text = ""
    end)

    local checking = false
    local function doKeyCheck(auto)
        if checking then return end
        local key = keyBox.Text:gsub("%s", "")
        if #key < 8 then
            keyStatus.Text = "слишком короткий ключ"
            keyStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
            return
        end
        checking = true
        local prevText = checkBtn.Text
        checkBtn.Text = "..."
        keyStatus.Text = ""
        task.spawn(function()
            local resp = requestValidate(key)
            checking = false
            checkBtn.Text = prevText
            if not resp then
                keyStatus.Text = "сервер недоступен"
                keyStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
                return
            end
            if resp.ok then
                keyValidated = true
                keyStatus.Text = "✅ " .. tostring(resp.days_left or 0) .. " дн."
                keyStatus.TextColor3 = Color3.fromRGB(80, 220, 100)
                tween(checkBtn, 0.3, { BackgroundTransparency=0.6, TextTransparency=0.4 })
                tween(startBtn, 0.3, { BackgroundTransparency=0.1, TextTransparency=0 })
                logScript("Key OK · " .. tostring(resp.status))
                return
            end
            keyStatus.Text = "❌ " .. (STATUS_TEXT[resp.status] or tostring(resp.status))
            keyStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
            if AUTO_KICK and KICK_STATUS[resp.status] then
                task.wait(0.9); pcall(function() LP:Kick(KICK_REASON) end)
            end
        end)
    end
    checkBtn.MouseButton1Click:Connect(function() doKeyCheck(false) end)
    keyBox.FocusLost:Connect(function(enter) if enter then doKeyCheck(true) end end)

    _G.Meredios_startBtn = startBtn
    _G.Meredios_startup = startup
    _G.Meredios_startupStroke = startupStroke
end

--================= MENU HELPERS =================
local makePage, makeTab, makeRow, makeSwitch, makeSlider, makeColorPaletteDynamic
local tabBar, contentBox, tabButtons, contentPages
local activeTab = "MAIN"

do
    local MENU_W, MENU_H = 420, 400
    menu = new("CanvasGroup", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0, MENU_W, 0, MENU_H),
        BackgroundColor3=P.BgGlass, BackgroundTransparency=0.04,
        BorderSizePixel=0, GroupTransparency=1, Visible=false, ZIndex=1,
    })
    round(menu, 20)
    local menuStroke = gradientStroke(menu, 2.5, 0.05, 30)
    menuStroke.Transparency = 1
    menu.Parent = ScreenGui
    reg(menu, "BackgroundColor3", "BgGlass")

    local topBar = new("Frame", { Size=UDim2.new(1,0,0,52), BackgroundTransparency=1, ZIndex=2 })
    topBar.Parent = menu

    local brand = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0, 18, 0, 10),
        Size=UDim2.new(0, 220, 0, 18), Text="MEREDIOS",
        TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2,
    })
    brand.Parent = topBar
    reg(brand, "TextColor3", "Text")

    local subBrand = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0, 18, 0, 28),
        Size=UDim2.new(0, 320, 0, 12), Text="v8.6 // t.me//meredioshub",
        TextColor3=P.SubText, Font=Enum.Font.Code, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=2,
    })
    subBrand.Parent = topBar
    reg(subBrand, "TextColor3", "SubText")

    local onlineDot = new("Frame", {
        Position=UDim2.new(0, 165, 0, 32), Size=UDim2.new(0, 5, 0, 5),
        BackgroundColor3=Color3.fromRGB(80, 220, 100), BorderSizePixel=0, ZIndex=3,
    })
    round(onlineDot, 3); onlineDot.Parent = topBar
    task.spawn(function()
        while onlineDot.Parent do
            tween(onlineDot, 1.2, { BackgroundTransparency=0.6 }, Enum.EasingStyle.Sine); task.wait(1.2)
            if not onlineDot.Parent then break end
            tween(onlineDot, 1.2, { BackgroundTransparency=0 }, Enum.EasingStyle.Sine); task.wait(1.2)
        end
    end)

    local topDivider = new("Frame", {
        Position=UDim2.new(0, 18, 0, 50), Size=UDim2.new(1, -36, 0, 1),
        BackgroundColor3=P.Divider, BorderSizePixel=0, ZIndex=2,
    })
    topDivider.Parent = topBar
    reg(topDivider, "BackgroundColor3", "Divider")

    local rightBox = new("Frame", {
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-14,0,26),
        Size=UDim2.new(0, 68, 0, 28), BackgroundTransparency=1, ZIndex=2,
    })
    rightBox.Parent = topBar

    local gearBtn = new("TextButton", {
        Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="⚙", TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=14,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=2,
    })
    round(gearBtn, 9); gearBtn.Parent = rightBox
    reg(gearBtn, "BackgroundColor3", "Card"); reg(gearBtn, "TextColor3", "Text")

    local closeBtn = new("TextButton", {
        Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,40,0,0),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="×", TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=17,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=2,
    })
    round(closeBtn, 9); closeBtn.Parent = rightBox
    reg(closeBtn, "BackgroundColor3", "Card"); reg(closeBtn, "TextColor3", "Text")

    dragify(menu, topBar, function() return not (_G.MerediosSettingsOpen == true) end)

    tabBar = new("ScrollingFrame", {
        Position=UDim2.new(0,12,0,58), Size=UDim2.new(1,-24,0,32),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0,
        ScrollingDirection=Enum.ScrollingDirection.X, CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.X, ZIndex=2,
    })
    tabBar.Parent = menu
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center,
    }).Parent = tabBar

    contentBox = new("Frame", {
        Position=UDim2.new(0,12,0,96), Size=UDim2.new(1,-24,1,-108),
        BackgroundTransparency=1, ZIndex=2, ClipsDescendants=false,
    })
    contentBox.Parent = menu

    tabButtons = {}; contentPages = {}

    _G.Meredios_gearBtn = gearBtn
    _G.Meredios_closeBtn = closeBtn
    _G.Meredios_menuStroke = menuStroke
end

do
    local function animatePageIn(page)
        page.Position = UDim2.new(0,0,0,26)
        tween(page, 0.38, { Position=UDim2.new(0,0,0,0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local idx = 0
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") then
                idx = idx + 1
                local targetBg = child.BackgroundTransparency
                local stroke = child:FindFirstChildOfClass("UIStroke")
                local targetStroke = stroke and stroke.Transparency or 0
                child.BackgroundTransparency = 1
                if stroke then stroke.Transparency = 1 end
                task.delay((idx - 1) * 0.045, function()
                    if not child.Parent then return end
                    tween(child, 0.32, { BackgroundTransparency=targetBg })
                    if stroke then tween(stroke, 0.32, { Transparency=targetStroke }) end
                end)
            end
        end
    end
    _G.Meredios_animatePageIn = animatePageIn

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
            if tName == name then page.Visible = true; animatePageIn(page) else page.Visible = false end
        end
    end
    _G.Meredios_switchTab = switchTab

    makePage = function(name)
        local page = new("ScrollingFrame", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=3, ScrollBarImageColor3=Accent.Main, ScrollBarImageTransparency=0.4,
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollingDirection=Enum.ScrollingDirection.Y, Visible=false, ZIndex=2,
            ClipsDescendants=true,
        })
        page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        page.Parent = contentBox
        contentPages[name] = page
        return page
    end

    makeTab = function(name, order)
        local btn = new("TextButton", {
            Size=UDim2.new(0,68,0,28), BackgroundColor3=Accent.Main, BackgroundTransparency=0.85,
            Text=name, TextColor3=P.SubText, Font=Enum.Font.GothamBold, TextSize=10,
            AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=order,
        })
        round(btn, 9); gradientStroke(btn, 2, 0.5, 30)
        btn.Parent = tabBar
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabButtons[name] = btn
        return btn
    end

    makeRow = function(page, order, title, desc, height)
        height = height or (desc and 54 or 42)
        local border = new("Frame", {
            Size=UDim2.new(1,-14,0,height+4), BackgroundColor3=Color3.new(1,1,1),
            BorderSizePixel=0, LayoutOrder=order, ZIndex=1,
        })
        round(border, 14)
        local bg = new("UIGradient", { Color=FlowColors, Rotation=0 })
        bg.Parent = border; registerGrad(bg, 25)
        border.Parent = page

        local card = new("Frame", {
            Position=UDim2.new(0,2,0,2), Size=UDim2.new(1,-4,1,-4),
            BackgroundColor3=P.Card, BackgroundTransparency=0.02, BorderSizePixel=0, ZIndex=2,
        })
        round(card, 12); card.Parent = border
        reg(card, "BackgroundColor3", "Card")

        local accentBar = new("Frame", {
            Position=UDim2.new(0,10,0,12), Size=UDim2.new(0,3,0,desc and 12 or 16),
            BackgroundColor3=Accent.Main, BorderSizePixel=0, ZIndex=3,
        })
        round(accentBar, 2); accentBar.Parent = card

        local t = new("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,20,0,desc and 8 or 12),
            Size=UDim2.new(1,-90,0,16), Text=title, TextColor3=P.Text,
            Font=Enum.Font.GothamBold, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3,
        })
        t.Parent = card
        reg(t, "TextColor3", "Text")

        if desc then
            local d = new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,20,0,26),
                Size=UDim2.new(1,-32,0,22), Text=desc, TextColor3=P.SubText,
                Font=Enum.Font.Gotham, TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                TextWrapped=true, ZIndex=3,
            })
            d.Parent = card
            reg(d, "TextColor3", "SubText")
        end
        return card, border
    end

    makeSwitch = function(card, y, onChanged, initial)
        local track = new("Frame", {
            Size=UDim2.new(0,40,0,20), Position=UDim2.new(1,-50,0,y or 12),
            BackgroundColor3=P.Track, BorderSizePixel=0, ZIndex=3,
        })
        round(track, 10); track.Parent = card
        local knob = new("Frame", {
            Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,10,0.5,0),
            AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=P.Knob,
            BorderSizePixel=0, ZIndex=4,
        })
        round(knob, 8); knob.Parent = track
        local lbl = new("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(1,-78,0,(y or 12)+3),
            Size=UDim2.new(0,22,0,12), Text="OFF", TextColor3=P.SubText,
            Font=Enum.Font.GothamBold, TextSize=9,
            TextXAlignment=Enum.TextXAlignment.Right, ZIndex=3,
        })
        lbl.Parent = card
        local entry = { state=false, track=track, knob=knob, lbl=lbl, card=card }
        table.insert(SwitchRegistry, entry)
        local function set(v)
            entry.state = v
            tween(knob, 0.26, { Position = v and UDim2.new(1,-10,0.5,0) or UDim2.new(0,10,0.5,0) })
            tween(track, 0.26, { BackgroundColor3 = v and Accent.Main or P.Track })
            lbl.Text = v and "ON" or "OFF"
            lbl.TextColor3 = v and Accent.Main or P.SubText
            if onChanged then onChanged(v) end
        end
        local btn = new("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=5,
        })
        btn.Parent = track
        btn.MouseButton1Click:Connect(function() set(not entry.state) end)
        if initial then set(true) end
        return set
    end

    makeSlider = function(parent, y, min, max, initial, onChange, widthTrim, onDragStart, onDragEnd)
        local track = new("Frame", {
            Position=UDim2.new(0,12,0,y), Size=UDim2.new(1,widthTrim or -84,0,6),
            BackgroundColor3=P.Track, BorderSizePixel=0, ZIndex=3,
        })
        round(track, 3); track.Parent = parent
        local fill = new("Frame", {
            Size=UDim2.new((initial-min)/(max-min),0,1,0),
            BackgroundColor3=Accent.Main, BorderSizePixel=0, ZIndex=4,
        })
        round(fill, 3); fill.Parent = track
        local knob = new("Frame", {
            AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new((initial-min)/(max-min),0,0.5,0),
            Size=UDim2.new(0,14,0,14), BackgroundColor3=P.Knob, BorderSizePixel=0, ZIndex=5,
        })
        round(knob, 7); knob.Parent = track
        local valLbl = new("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(1,-70,0,y-10),
            Size=UDim2.new(0,58,0,14), Text=tostring(initial),
            TextColor3=P.Text, Font=Enum.Font.Code, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Right, ZIndex=3,
        })
        valLbl.Parent = parent
        reg(valLbl, "TextColor3", "Text")
        local dragging = false
        local function setFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local v = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel,0,1,0)
            knob.Position = UDim2.new(rel,0,0.5,0)
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
            local rel = (v-min)/(max-min)
            fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,0,0.5,0)
            valLbl.Text = tostring(v)
            if onChange then onChange(v) end
        end
    end

    makeColorPaletteDynamic = function(parent, y, getPalette, getCurrent, onSelect, swatchSize)
        swatchSize = swatchSize or 22
        local row = new("Frame", {
            Position=UDim2.new(0,12,0,y), Size=UDim2.new(1,-24,0,swatchSize),
            BackgroundTransparency=1, ZIndex=3,
        })
        row.Parent = parent
        new("UIListLayout", {
            FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5),
            SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Left,
        }).Parent = row
        local map = {}
        local function rebuild()
            for _, s in pairs(map) do pcall(function() s.btn:Destroy() end) end
            map = {}
            local palette, current = getPalette(), getCurrent()
            for i, entry in ipairs(palette) do
                local swatch = new("TextButton", {
                    Size=UDim2.new(0,swatchSize,0,swatchSize),
                    BackgroundColor3=entry.color, BackgroundTransparency=0,
                    Text="", AutoButtonColor=false, BorderSizePixel=0,
                    LayoutOrder=i, ZIndex=3,
                })
                round(swatch, 6)
                local st = new("UIStroke", {
                    Thickness=1, Transparency=0.6, Color=Color3.fromRGB(255,255,255),
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
                })
                st.Parent = swatch; swatch.Parent = row
                local isCur = (entry.name == current)
                st.Transparency = isCur and 0 or 0.6
                st.Thickness = isCur and 2 or 1
                map[entry.name] = { btn=swatch, stroke=st, entry=entry }
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
end

for i, name in ipairs({"MAIN","LOG","COMBAT","NEW"}) do makeTab(name, i) end

--================= MAIN PAGE =================
do
    local page = makePage("MAIN")
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center,
    }).Parent = page

    do
        local card = makeRow(page, 1, "SPEED WALK", "ускоряет ходьбу · 8–500")
        local box = new("TextBox", {
            Position=UDim2.new(1,-126,0,12), Size=UDim2.new(0,58,0,22),
            BackgroundColor3=P.Bg, BackgroundTransparency=0.4,
            Text=tostring(Speed.Value), TextColor3=P.Text,
            Font=Enum.Font.Code, TextSize=11,
            BorderSizePixel=0, ClearTextOnFocus=false, TextEditable=true, ZIndex=3,
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
        local card = makeRow(page, 2, "ANTI-FLING", "гасит раскрутку от чужих эксплойтов")
        makeSwitch(card, 12, function(v)
            AntiFling.Enabled = v
            logScript("Anti-Fling " .. (v and "ON" or "OFF"))
        end)
    end

    do
        local card = makeRow(page, 3, "REJOIN", "переподключение к текущему серверу", 58)
        local btn = new("TextButton", {
            Position=UDim2.new(0,12,0,40), Size=UDim2.new(1,-24,0,24),
            BackgroundColor3=Accent.Main, BackgroundTransparency=0.2,
            Text="REJOIN", TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold, TextSize=10,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
        })
        round(btn, 8); btn.Parent = card
        btn.MouseButton1Click:Connect(function()
            logScript("Rejoin initiated")
            pcall(function() TeleportSvc:Teleport(game.PlaceId, LP) end)
        end)
    end

    do
        local card = makeRow(page, 4, "SERVER HOP", "переброс на другой сервер игры", 58)
        local btn = new("TextButton", {
            Position=UDim2.new(0,12,0,40), Size=UDim2.new(1,-24,0,24),
            BackgroundColor3=Accent.Main, BackgroundTransparency=0.2,
            Text="HOP TO RANDOM SERVER", TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold, TextSize=10,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
        })
        round(btn, 8); btn.Parent = card
        btn.MouseButton1Click:Connect(function() task.spawn(serverHop) end)
    end

    do
        local card = makeRow(page, 5, "EMPTY HOP", "сервер с 0 игроков", 58)
        local btn = new("TextButton", {
            Position=UDim2.new(0,12,0,40), Size=UDim2.new(1,-24,0,24),
            BackgroundColor3=Color3.fromRGB(80,220,100), BackgroundTransparency=0.2,
            Text="HOP TO EMPTY SERVER", TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold, TextSize=10,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
        })
        round(btn, 8); btn.Parent = card
        btn.MouseButton1Click:Connect(function() task.spawn(emptyHop) end)
    end
end

--================= LOG PAGE =================
do
    local page = makePage("LOG")
    page.ScrollingDirection = Enum.ScrollingDirection.X
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.CanvasSize = UDim2.new(1,0,1,0)
    page.ElasticBehavior = Enum.ElasticBehavior.Never
    page.ScrollingEnabled = false

    local logBorder = new("Frame", {
        Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,0,1,-34),
        BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=1,
    })
    round(logBorder, 14)
    local logBgGrad = new("UIGradient", { Color=FlowColors, Rotation=0 })
    logBgGrad.Parent = logBorder; registerGrad(logBgGrad, 25)
    logBorder.Parent = page

    local logViewport = new("Frame", {
        Position=UDim2.new(0,2,0,2), Size=UDim2.new(1,-4,1,-4),
        BackgroundColor3=P.Card, BackgroundTransparency=0.02, BorderSizePixel=0, ZIndex=2,
    })
    round(logViewport, 12); logViewport.Parent = logBorder
    reg(logViewport, "BackgroundColor3", "Card")

    local logScroll = new("ScrollingFrame", {
        Position=UDim2.new(0,10,0,10), Size=UDim2.new(1,-20,1,-20),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
        ScrollBarImageColor3=Accent.Main, ScrollBarImageTransparency=0.4,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y, ZIndex=3,
    })
    logScroll.Parent = logViewport
    local logLayout = new("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,4),
        SortOrder=Enum.SortOrder.LayoutOrder,
    })
    logLayout.Parent = logScroll

    local serverTabBtn = new("TextButton", {
        Position=UDim2.new(0.00,0,1,-28), Size=UDim2.new(0.24,-2,0,28),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="SERVER", TextColor3=P.SubText,
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0,
    })
    round(serverTabBtn, 9); gradientStroke(serverTabBtn, 2, 0.5, 30); serverTabBtn.Parent = page

    local scriptTabBtn = new("TextButton", {
        Position=UDim2.new(0.24,0,1,-28), Size=UDim2.new(0.24,-2,0,28),
        BackgroundColor3=Accent.Main, BackgroundTransparency=0.05,
        Text="SCRIPT", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0,
    })
    round(scriptTabBtn, 9); gradientStroke(scriptTabBtn, 2, 0.3, 30); scriptTabBtn.Parent = page

    local filterBtn = new("TextButton", {
        Position=UDim2.new(0.48,0,1,-28), Size=UDim2.new(0.18,-2,0,28),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="FILTER", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0,
    })
    round(filterBtn, 9); gradientStroke(filterBtn, 2, 0.5, 30); filterBtn.Parent = page
    reg(filterBtn, "BackgroundColor3", "Card"); reg(filterBtn, "TextColor3", "Text")

    local copyBtn = new("TextButton", {
        Position=UDim2.new(0.66,2,1,-28), Size=UDim2.new(0.16,-2,0,28),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="COPY", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0,
    })
    round(copyBtn, 9); gradientStroke(copyBtn, 2, 0.5, 30); copyBtn.Parent = page
    reg(copyBtn, "BackgroundColor3", "Card"); reg(copyBtn, "TextColor3", "Text")

    local clearBtn = new("TextButton", {
        Position=UDim2.new(0.82,4,1,-28), Size=UDim2.new(0.18,-4,0,28),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="CLR", TextColor3=Color3.fromRGB(255,90,90),
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0,
    })
    round(clearBtn, 9); gradientStroke(clearBtn, 2, 0.5, 30); clearBtn.Parent = page
    reg(clearBtn, "BackgroundColor3", "Card")

    table.insert(LogTabButtons, { name="server", btn=serverTabBtn })
    table.insert(LogTabButtons, { name="script", btn=scriptTabBtn })

    local logLineCache = {}
    local function renderLog()
        local buf = Logger.buffer[Logger.activeTab]
        if #buf == 0 then
            for _, lbl in ipairs(logLineCache) do pcall(function() lbl:Destroy() end) end
            logLineCache = {}; return
        end
        while #logLineCache < #buf do
            local lbl = new("TextLabel", {
                Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, Text="",
                TextColor3=P.Text, Font=Enum.Font.Code, TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
                TextWrapped=true, AutomaticSize=Enum.AutomaticSize.Y,
                LayoutOrder=#logLineCache+1, ZIndex=3,
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
        local text = Logger.buildText()
        local ok = Logger.copy(text)
        if ok then
            copyBtn.Text = "OK"
            task.delay(1.0, function() copyBtn.Text = "COPY" end)
            logScript("Logs copied (" .. #text .. " bytes)")
        else
            copyBtn.Text = "ERR"
            task.delay(1.0, function() copyBtn.Text = "COPY" end)
            logScript("Copy failed")
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        Logger.buffer.server = {}; Logger.buffer.script = {}; renderLog()
    end)

    table.insert(Logger.listeners, function(channel)
        if channel == Logger.activeTab then renderLog() end
    end)

    _G.Meredios_filterBtn = filterBtn
end

--================= COMBAT PAGE =================
do
    local page = makePage("COMBAT")
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center,
    }).Parent = page

    do
        local card = makeRow(page, 1, "HITBOX CHANGER", "увеличивает хитбокс игроков · VIEW границы", 100)
        local box = new("TextBox", {
            Position=UDim2.new(1,-126,0,46), Size=UDim2.new(0,58,0,22),
            BackgroundColor3=P.Bg, BackgroundTransparency=0.4,
            Text=tostring(HitboxChanger.Size), TextColor3=P.Text,
            Font=Enum.Font.Code, TextSize=11,
            BorderSizePixel=0, ClearTextOnFocus=false, TextEditable=true, ZIndex=3,
        })
        round(box, 7); box.Parent = card
        reg(box, "BackgroundColor3", "Bg"); reg(box, "TextColor3", "Text")
        local viewBtn
        local viewState = false
        local function setView(v)
            viewState = v; HitboxChanger.View = v
            if v then
                tween(viewBtn, 0.22, { BackgroundColor3=Accent.Main, TextColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.15 })
                HitboxChanger.viewAllOn()
            else
                tween(viewBtn, 0.22, { BackgroundColor3=P.Card, TextColor3=P.SubText, BackgroundTransparency=0.3 })
                HitboxChanger.viewAllOff()
            end
            logScript("Hitbox View " .. (v and "ON" or "OFF"))
        end
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then
                HitboxChanger.Size = math.clamp(math.floor(n), 1, 50)
                if HitboxChanger.Enabled then HitboxChanger.restoreAll(); HitboxChanger.applyAll() end
                if viewState then HitboxChanger.viewRefresh() end
                logScript("Hitbox size = " .. tostring(HitboxChanger.Size))
            end
            box.Text = tostring(HitboxChanger.Size)
        end)
        makeSwitch(card, 46, function(v)
            HitboxChanger.Enabled = v
            if v then HitboxChanger.applyAll()
            else HitboxChanger.restoreAll(); if viewState then setView(false) end end
            logScript("Hitbox " .. (v and "ON" or "OFF"))
        end)
        viewBtn = new("TextButton", {
            Position=UDim2.new(0,12,0,72), Size=UDim2.new(0,78,0,22),
            BackgroundColor3=P.Card, BackgroundTransparency=0.3,
            Text="VIEW", TextColor3=P.SubText,
            Font=Enum.Font.GothamBold, TextSize=10,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
        })
        round(viewBtn, 7); gradientStroke(viewBtn, 2, 0.5, 30); viewBtn.Parent = card
        reg(viewBtn, "BackgroundColor3", "Card")
        viewBtn.MouseButton1Click:Connect(function() setView(not viewState) end)
    end

    do
        local card = makeRow(page, 2, "ESP", "подсвечивает игроков · зелёный = виден", 180)
        local setESPEnabled = makeSwitch(card, 12, function(v)
            ESP.Enabled = v; ESP.refreshAll()
            logScript("ESP " .. (v and "ON" or "OFF"))
        end)
        local visLbl = new("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,14,0,74),
            Size=UDim2.new(1,-100,0,16), Text="VISIBILITY  (green = line of sight)",
            TextColor3=P.SubText, Font=Enum.Font.GothamMedium, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3,
        })
        visLbl.Parent = card
        reg(visLbl, "TextColor3", "SubText")
        local rebuildESPPalette
        local setESPVis = makeSwitch(card, 74, function(v)
            ESP.VisibilityCheck = v; ESP.reapplyAll()
            if rebuildESPPalette then rebuildESPPalette() end
            logScript("ESP visibility " .. (v and "ON" or "OFF"))
        end)
        local palLbl = new("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,14,0,124),
            Size=UDim2.new(1,-24,0,14), Text="COLOR",
            TextColor3=P.SubText, Font=Enum.Font.GothamMedium, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3,
        })
        palLbl.Parent = card
        reg(palLbl, "TextColor3", "SubText")
        rebuildESPPalette = makeColorPaletteDynamic(card, 142,
            function() return ESP.Palette end,
            function() return ESP.ColorName end,
            function(name, color)
                ESP.Color = color; ESP.ColorName = name
                ESP.reapplyAll()
                logScript("ESP color = " .. name)
            end, 22)
        _G.Meredios_setESPEnabled = setESPEnabled
        _G.Meredios_setESPVis = setESPVis
    end

    do
        local card = makeRow(page, 3, "AIMBOT", "жёсткий лок на голову · настройки в ⚙", 68)
        local aimGear = new("TextButton", {
            Position=UDim2.new(1,-126,0,40), Size=UDim2.new(0,28,0,22),
            BackgroundColor3=P.Card, BackgroundTransparency=0.15,
            Text="⚙", TextColor3=P.Text,
            Font=Enum.Font.GothamBold, TextSize=12,
            AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
        })
        round(aimGear, 7); aimGear.Parent = card
        reg(aimGear, "BackgroundColor3", "Card"); reg(aimGear, "TextColor3", "Text")
        local statusLbl = new("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,12,0,40),
            Size=UDim2.new(1,-140,0,22),
            Text="FOV " .. Aimbot.FOV .. "px · " .. Aimbot.ColorName,
            TextColor3=P.SubText, Font=Enum.Font.Code, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3,
        })
        statusLbl.Parent = card
        reg(statusLbl, "TextColor3", "SubText")
        _G.MerediosUpdateAimStatus = function()
            statusLbl.Text = "FOV " .. Aimbot.FOV .. "px · " .. Aimbot.ColorName ..
                (Aimbot.VisibleOnly and " · visible-only" or "")
        end
        aimGear.MouseButton1Click:Connect(function()
            if _G.MerediosOpenAimSettings then _G.MerediosOpenAimSettings() end
        end)
        makeSwitch(card, 12, function(v)
            Aimbot.Enabled = v
            if not v then Aimbot.MoveAccum = 0; Aimbot.LockedTarget = nil end
            logScript("Aimbot " .. (v and "ON" or "OFF"))
        end)
    end
end

--================= NEW PAGE =================
do
    local page = makePage("NEW")
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center,
    }).Parent = page

    local card = makeRow(page, 1, "ОБНОВЛЕНИЕ v8.6", "t.me//meredioshub — апдейты там", 220)
    local body = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,52),
        Size=UDim2.new(1,-36,0,160),
        Text=table.concat({
            "• Key gate встроен в стартовую панель",
            "• CHECK KEY + ✕ очистки поля",
            "• НАЧАТЬ активируется после валида",
            "• Aimbot sticky-lock · только по живой цели",
            "• FOV ring под GUI · всплывает на drag",
            "• ESP visibility по умолчанию OFF",
            "• Remote logger + фильтр ✓/✗",
            "• ServerHop · EmptyHop",
            "• t.me//meredioshub",
        }, "\n"),
        TextColor3=P.Text, Font=Enum.Font.Gotham, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, ZIndex=3,
    })
    body.Parent = card
    reg(body, "TextColor3", "Text")

    local card2 = makeRow(page, 2, "TELEGRAM", "t.me//meredioshub", 60)
    local btn = new("TextButton", {
        Position=UDim2.new(0,12,0,44), Size=UDim2.new(1,-24,0,22),
        BackgroundColor3=Accent.Main, BackgroundTransparency=0.2,
        Text="СКОПИРОВАТЬ t.me//meredioshub", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=10,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
    })
    round(btn, 8); btn.Parent = card2
    btn.MouseButton1Click:Connect(function()
        logScript("TG link copied")
        Logger.copy("t.me//meredioshub")
        btn.Text = "СКОПИРОВАНО"
        task.delay(1.2, function() btn.Text = "СКОПИРОВАТЬ t.me//meredioshub" end)
    end)
end

--================= AIM SETTINGS PANEL =================
do
    local AIM_W, AIM_H = 380, 340
    aimPanel = new("CanvasGroup", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0, AIM_W, 0, AIM_H),
        BackgroundColor3=P.BgGlass, BackgroundTransparency=0.02,
        BorderSizePixel=0, GroupTransparency=1, Visible=false, ZIndex=10,
    })
    round(aimPanel, 16)
    local aimPanelStroke = gradientStroke(aimPanel, 2.5, 0.08, 30)
    aimPanelStroke.Transparency = 1
    aimPanel.Parent = menu
    reg(aimPanel, "BackgroundColor3", "BgGlass")

    local apTitle = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,14),
        Size=UDim2.new(1,-70,0,16), Text="AIM SETTINGS · t.me//meredioshub",
        TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=11,
    })
    apTitle.Parent = aimPanel
    reg(apTitle, "TextColor3", "Text")

    local apClose = new("TextButton", {
        Position=UDim2.new(1,-38,0,10), Size=UDim2.new(0,26,0,26),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="×", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=16,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=11,
    })
    round(apClose, 8); apClose.Parent = aimPanel
    reg(apClose, "BackgroundColor3", "Card"); reg(apClose, "TextColor3", "Text")

    local fovLbl = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,52),
        Size=UDim2.new(1,-36,0,14), Text="FOV RADIUS",
        TextColor3=P.SubText, Font=Enum.Font.GothamBold, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=11,
    })
    fovLbl.Parent = aimPanel
    reg(fovLbl, "TextColor3", "SubText")

    local fovSliderHost = new("Frame", {
        Position=UDim2.new(0,0,0,70), Size=UDim2.new(1,0,0,24),
        BackgroundTransparency=1, ZIndex=11,
    })
    fovSliderHost.Parent = aimPanel

    makeSlider(fovSliderHost, 6, 40, 400, Aimbot.FOV, function(v)
        Aimbot.FOV = v; Aimbot._updateFOV()
        if _G.MerediosUpdateAimStatus then _G.MerediosUpdateAimStatus() end
    end, -84,
    function() Aimbot._fovWrap.ZIndex = 6000 end,
    function() Aimbot._fovWrap.ZIndex = 0 end)

    local fovColLbl = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,108),
        Size=UDim2.new(1,-36,0,14), Text="FOV COLOR",
        TextColor3=P.SubText, Font=Enum.Font.GothamBold, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=11,
    })
    fovColLbl.Parent = aimPanel
    reg(fovColLbl, "TextColor3", "SubText")

    local AIM_PALETTE = {
        {name="WHITE",color=Color3.fromRGB(255,255,255)},
        {name="BLUE",color=Color3.fromRGB(30,64,175)},
        {name="NAVY",color=Color3.fromRGB(15,40,120)},
        {name="CYAN",color=Color3.fromRGB(0,210,255)},
        {name="RED",color=Color3.fromRGB(255,60,60)},
        {name="GREEN",color=Color3.fromRGB(80,220,100)},
        {name="YELLOW",color=Color3.fromRGB(255,220,60)},
        {name="PURPLE",color=Color3.fromRGB(160,95,255)},
        {name="PINK",color=Color3.fromRGB(255,95,175)},
    }
    local fovPalHost = new("Frame", {
        Position=UDim2.new(0,0,0,128), Size=UDim2.new(1,0,0,26),
        BackgroundTransparency=1, ZIndex=11,
    })
    fovPalHost.Parent = aimPanel
    makeColorPaletteDynamic(fovPalHost, 0,
        function() return AIM_PALETTE end,
        function() return Aimbot.ColorName end,
        function(name, color)
            Aimbot._setColor(name, color)
            if _G.MerediosUpdateAimStatus then _G.MerediosUpdateAimStatus() end
            logScript("Aimbot FOV color = " .. name)
        end, 24)

    local onlyRow = new("Frame", {
        Position=UDim2.new(0,14,0,172), Size=UDim2.new(1,-28,0,64),
        BackgroundColor3=P.Card, BackgroundTransparency=0.08, BorderSizePixel=0, ZIndex=11,
    })
    round(onlyRow, 12); gradientStroke(onlyRow, 2.5, 0.12, 35)
    onlyRow.Parent = aimPanel
    reg(onlyRow, "BackgroundColor3", "Card")

    local onlyTitle = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,12,0,8),
        Size=UDim2.new(1,-60,0,16), Text="ONLY IN FOV",
        TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12,
    })
    onlyTitle.Parent = onlyRow
    reg(onlyTitle, "TextColor3", "Text")

    local onlySub = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,12,0,26),
        Size=UDim2.new(1,-24,0,32),
        Text="aimbot fires only at visible targets.",
        TextColor3=P.SubText, Font=Enum.Font.Gotham, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, ZIndex=12,
    })
    onlySub.Parent = onlyRow
    reg(onlySub, "TextColor3", "SubText")

    makeSwitch(onlyRow, 22, function(v)
        Aimbot.VisibleOnly = v
        if v then
            if _G.Meredios_setESPEnabled then _G.Meredios_setESPEnabled(true) end
            if _G.Meredios_setESPVis then _G.Meredios_setESPVis(true) end
        end
        if _G.MerediosUpdateAimStatus then _G.MerediosUpdateAimStatus() end
        logScript("Only-in-FOV " .. (v and "ON" or "OFF"))
    end)

    local aimOpenToken = 0
    _G.MerediosOpenAimSettings = function()
        aimOpenToken = aimOpenToken + 1
        aimPanel.Visible = true
        aimPanel.GroupTransparency = 1
        aimPanel.BackgroundTransparency = 1
        aimPanelStroke.Transparency = 1
        aimPanel.Size = UDim2.new(0, AIM_W - 30, 0, AIM_H - 20)
        tween(aimPanel, 0.36, {
            GroupTransparency=0, BackgroundTransparency=0.02,
            Size=UDim2.new(0, AIM_W, 0, AIM_H),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(aimPanelStroke, 0.36, { Transparency=0.08 })
        _G.MerediosSettingsOpen = true
    end
    apClose.MouseButton1Click:Connect(function()
        aimOpenToken = aimOpenToken + 1
        local myToken = aimOpenToken
        tween(aimPanel, 0.28, {
            GroupTransparency=1, BackgroundTransparency=1,
            Size=UDim2.new(0, AIM_W - 30, 0, AIM_H - 20),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(aimPanelStroke, 0.28, { Transparency=1 })
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
end

--================= FILTER PANEL =================
do
    local FLT_W, FLT_H = 340, 320
    filterPanel = new("CanvasGroup", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0, FLT_W, 0, FLT_H),
        BackgroundColor3=P.BgGlass, BackgroundTransparency=0.02,
        BorderSizePixel=0, GroupTransparency=1, Visible=false, ZIndex=12,
    })
    round(filterPanel, 16)
    local filterPanelStroke = gradientStroke(filterPanel, 2.5, 0.08, 30)
    filterPanelStroke.Transparency = 1
    filterPanel.Parent = menu
    reg(filterPanel, "BackgroundColor3", "BgGlass")

    local fpTitle = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,14),
        Size=UDim2.new(1,-70,0,16), Text="LOG FILTERS · remotes",
        TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13,
    })
    fpTitle.Parent = filterPanel
    reg(fpTitle, "TextColor3", "Text")

    local fpClose = new("TextButton", {
        Position=UDim2.new(1,-38,0,10), Size=UDim2.new(0,26,0,26),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="×", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=16,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=13,
    })
    round(fpClose, 8); fpClose.Parent = filterPanel
    reg(fpClose, "BackgroundColor3", "Card"); reg(fpClose, "TextColor3", "Text")

    local fpHint = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,36),
        Size=UDim2.new(1,-36,0,24), Text="✓ = log shown    ✗ = hidden",
        TextColor3=P.SubText, Font=Enum.Font.Gotham, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, ZIndex=13,
    })
    fpHint.Parent = filterPanel
    reg(fpHint, "TextColor3", "SubText")

    local fpShowAll = new("TextButton", {
        Position=UDim2.new(0,18,0,64), Size=UDim2.new(0.48,-10,0,24),
        BackgroundColor3=Color3.fromRGB(80,220,100), BackgroundTransparency=0.2,
        Text="SHOW ALL", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=13,
    })
    round(fpShowAll, 7); fpShowAll.Parent = filterPanel

    local fpHideAll = new("TextButton", {
        Position=UDim2.new(0.52,2,0,64), Size=UDim2.new(0.48,-10,0,24),
        BackgroundColor3=Color3.fromRGB(255,90,90), BackgroundTransparency=0.2,
        Text="HIDE ALL", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=9,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=13,
    })
    round(fpHideAll, 7); fpHideAll.Parent = filterPanel

    local fpScrollWrap = new("Frame", {
        Position=UDim2.new(0,18,0,96), Size=UDim2.new(1,-36,1,-108),
        BackgroundColor3=P.Card, BackgroundTransparency=0.03, BorderSizePixel=0, ZIndex=13,
    })
    round(fpScrollWrap, 10); gradientStroke(fpScrollWrap, 2, 0.3, 35)
    fpScrollWrap.Parent = filterPanel
    reg(fpScrollWrap, "BackgroundColor3", "Card")

    local fpScroll = new("ScrollingFrame", {
        Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,1,-12),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
        ScrollBarImageColor3=Accent.Main, ScrollBarImageTransparency=0.4,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y, ZIndex=14,
    })
    fpScroll.Parent = fpScrollWrap
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,4),
        SortOrder=Enum.SortOrder.LayoutOrder,
    }).Parent = fpScroll

    local fpEmptyLbl = new("TextLabel", {
        Size=UDim2.new(1,0,0,20), BackgroundTransparency=1,
        Text="(no remotes captured yet)", TextColor3=P.SubText,
        Font=Enum.Font.Code, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Center, LayoutOrder=0, ZIndex=14,
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
        if #names == 0 then fpEmptyLbl.Visible = true; return end
        fpEmptyLbl.Visible = false
        for i, name in ipairs(names) do
            local container = new("Frame", {
                Size=UDim2.new(1,0,0,26), BackgroundColor3=P.Bg,
                BackgroundTransparency=0.35, BorderSizePixel=0,
                LayoutOrder=i, ZIndex=14,
            })
            round(container, 6); container.Parent = fpScroll
            local nameLbl = new("TextLabel", {
                BackgroundTransparency=1, Position=UDim2.new(0,8,0,0),
                Size=UDim2.new(1,-44,1,0), Text=name,
                TextColor3=P.Text, Font=Enum.Font.Code, TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left,
                TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=15,
            })
            nameLbl.Parent = container
            reg(nameLbl, "TextColor3", "Text")
            local state = (Logger.filters[name] ~= false)
            local toggle = new("TextButton", {
                AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-6,0.5,0),
                Size=UDim2.new(0,26,0,20),
                BackgroundColor3=state and Color3.fromRGB(80,220,100) or Color3.fromRGB(255,90,90),
                BackgroundTransparency=0.15, Text=state and "✓" or "✗",
                TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.GothamBold, TextSize=12,
                AutoButtonColor=false, BorderSizePixel=0, ZIndex=15,
            })
            round(toggle, 6); toggle.Parent = container
            toggle.MouseButton1Click:Connect(function()
                local cur = (Logger.filters[name] ~= false)
                local nxt = not cur
                Logger.filters[name] = nxt
                toggle.BackgroundColor3 = nxt and Color3.fromRGB(80,220,100) or Color3.fromRGB(255,90,90)
                toggle.Text = nxt and "✓" or "✗"
                logScript("Filter " .. name .. " = " .. (nxt and "shown" or "hidden"))
            end)
            fpRows[name] = { container=container, toggle=toggle }
        end
    end
    fpShowAll.MouseButton1Click:Connect(function()
        for name, _ in pairs(Logger.knownRemotes) do Logger.filters[name] = true end
        rebuildFilters(); logScript("All remotes shown")
    end)
    fpHideAll.MouseButton1Click:Connect(function()
        for name, _ in pairs(Logger.knownRemotes) do Logger.filters[name] = false end
        rebuildFilters(); logScript("All remotes hidden")
    end)
    table.insert(Logger.filterListeners, function()
        if filterPanel.Visible then rebuildFilters() end
    end)

    local fltOpenToken = 0
    local filterBtn = _G.Meredios_filterBtn
    if filterBtn then
        filterBtn.MouseButton1Click:Connect(function()
            fltOpenToken = fltOpenToken + 1
            rebuildFilters()
            filterPanel.Visible = true
            filterPanel.GroupTransparency = 1
            filterPanel.BackgroundTransparency = 1
            filterPanelStroke.Transparency = 1
            filterPanel.Size = UDim2.new(0, FLT_W - 30, 0, FLT_H - 20)
            tween(filterPanel, 0.36, {
                GroupTransparency=0, BackgroundTransparency=0.02,
                Size=UDim2.new(0, FLT_W, 0, FLT_H),
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            tween(filterPanelStroke, 0.36, { Transparency=0.08 })
            _G.MerediosSettingsOpen = true
        end)
    end
    fpClose.MouseButton1Click:Connect(function()
        fltOpenToken = fltOpenToken + 1
        local myToken = fltOpenToken
        tween(filterPanel, 0.28, {
            GroupTransparency=1, BackgroundTransparency=1,
            Size=UDim2.new(0, FLT_W - 30, 0, FLT_H - 20),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(filterPanelStroke, 0.28, { Transparency=1 })
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
end

--================= THEME PANEL =================
do
    settings = new("CanvasGroup", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,320,0,250), BackgroundColor3=P.BgGlass,
        BackgroundTransparency=0.02, BorderSizePixel=0, GroupTransparency=1,
        Visible=false, ZIndex=5,
    })
    round(settings, 16)
    local settingsStroke = gradientStroke(settings, 2.5, 0.12, 30)
    settingsStroke.Transparency = 1
    settings.Parent = menu
    reg(settings, "BackgroundColor3", "BgGlass")

    local sTitle = new("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,18,0,14),
        Size=UDim2.new(1,-70,0,16), Text="SETTINGS · t.me//meredioshub",
        TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
    })
    sTitle.Parent = settings
    reg(sTitle, "TextColor3", "Text")

    local sClose = new("TextButton", {
        Position=UDim2.new(1,-38,0,10), Size=UDim2.new(0,26,0,26),
        BackgroundColor3=P.Card, BackgroundTransparency=0.15,
        Text="×", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=16,
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=6,
    })
    round(sClose, 8); sClose.Parent = settings
    reg(sClose, "BackgroundColor3", "Card"); reg(sClose, "TextColor3", "Text")

    local function sRow(y, titleText)
        local row = new("Frame", {
            Position=UDim2.new(0,18,0,y), Size=UDim2.new(1,-36,0,32),
            BackgroundTransparency=1, ZIndex=6,
        })
        row.Parent = settings
        local lbl = new("TextLabel", {
            BackgroundTransparency=1, Size=UDim2.new(0,80,1,0),
            Text=titleText, TextColor3=P.SubText,
            Font=Enum.Font.GothamMedium, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
        })
        lbl.Parent = row
        reg(lbl, "TextColor3", "SubText")
        return row
    end

    local function segControl(parent, options, current, onSelect)
        local seg = new("Frame", {
            Position=UDim2.new(0,90,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Size=UDim2.new(1,-90,0,26), BackgroundTransparency=1, ZIndex=6,
        })
        seg.Parent = parent
        new("UIListLayout", {
            FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5),
            SortOrder=Enum.SortOrder.LayoutOrder,
        }).Parent = seg
        local btns = {}; local currentVal = current
        local function refresh(sel)
            currentVal = sel
            for k, b in pairs(btns) do
                local on = k == sel
                tween(b, 0.22, {
                    BackgroundTransparency=on and 0.05 or 0.82,
                    TextColor3=on and Color3.fromRGB(255,255,255) or P.SubText,
                })
            end
        end
        for i, opt in ipairs(options) do
            local b = new("TextButton", {
                Size=UDim2.new(0,56,1,0), BackgroundColor3=Accent.Main,
                BackgroundTransparency=0.82, Text=opt, TextColor3=P.SubText,
                Font=Enum.Font.GothamBold, TextSize=8,
                AutoButtonColor=false, BorderSizePixel=0,
                LayoutOrder=i, ZIndex=6,
            })
            round(b, 7); b.Parent = seg
            btns[opt] = b
            b.MouseButton1Click:Connect(function() refresh(opt); if onSelect then onSelect(opt) end end)
        end
        refresh(current)
        table.insert(SegRegistry, {
            btns=btns,
            get_current=function() return currentVal end,
            refresh=refresh,
        })
        return seg, refresh
    end

    local row1 = sRow(52, "THEME")
    segControl(row1, { "LIGHT", "DARK" }, Theme.mode:upper(), function(v)
        Theme.mode = v == "DARK" and "Dark" or "Light"; applyTheme()
    end)
    local row2 = sRow(90, "ACCENT")
    segControl(row2, { "DARKBLUE", "NAVY", "CYAN", "PURPLE", "PINK" }, "DARKBLUE", function(v)
        local map = { DARKBLUE="DarkBlue", NAVY="Navy", CYAN="Cyan", PURPLE="Purple", PINK="Pink" }
        Theme.accent = map[v] or "DarkBlue"; refreshPalettes(); applyTheme()
    end)
    local row3 = sRow(128, "ANIMATIONS")
    segControl(row3, { "ON", "OFF" }, "ON", function(v) Theme.anim = (v == "ON") end)

    _G.Meredios_settings = settings
    _G.Meredios_settingsStroke = settingsStroke
    _G.Meredios_sClose = sClose
end

--================= M BUTTON =================
do
    mBtn = new("TextButton", {
        Size=UDim2.new(0,52,0,52), Position=UDim2.new(0,60,0.35,0),
        BackgroundColor3=P.BgGlass, BackgroundTransparency=0.08,
        Text="M", TextColor3=P.Text,
        Font=Enum.Font.GothamBold, TextSize=20,
        AutoButtonColor=false, BorderSizePixel=0, Visible=false,
    })
    round(mBtn, 26); mBtn.Parent = ScreenGui
    reg(mBtn, "BackgroundColor3", "BgGlass"); reg(mBtn, "TextColor3", "Text")

    local mBtnStroke = new("UIStroke", {
        Thickness=2.5, Transparency=0.05,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        LineJoinMode=Enum.LineJoinMode.Round, Color=Color3.new(1,1,1),
    })
    mBtnStroke.Parent = mBtn
    local mBtnGrad = new("UIGradient", { Color=BluePinkSeq, Rotation=30 })
    mBtnGrad.Parent = mBtnStroke
    registerGrad(mBtnGrad, 90)

    local mGlow = new("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,12,1,12), BackgroundTransparency=1, ZIndex=mBtn.ZIndex-1,
    })
    round(mGlow, 30)
    local mGlowStroke = new("UIStroke", {
        Thickness=2, Transparency=0.75,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        LineJoinMode=Enum.LineJoinMode.Round, Color=Color3.new(1,1,1),
    })
    mGlowStroke.Parent = mGlow
    local mGlowGrad = new("UIGradient", { Color=BluePinkSeq, Rotation=30 })
    mGlowGrad.Parent = mGlowStroke
    registerGrad(mGlowGrad, 60)
    mGlow.Parent = mBtn
    task.spawn(function()
        while mGlow.Parent do
            tween(mGlowStroke, 1.4, { Transparency=0.55 }, Enum.EasingStyle.Sine); task.wait(1.4)
            if not mGlow.Parent then break end
            tween(mGlowStroke, 1.4, { Transparency=0.85 }, Enum.EasingStyle.Sine); task.wait(1.4)
        end
    end)

    local tapHint = new("TextLabel", {
        AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,1,8),
        Size=UDim2.new(0,150,0,26), BackgroundColor3=P.BgGlass,
        BackgroundTransparency=1, Text="2 times to open",
        TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=11,
        BorderSizePixel=0, TextTransparency=1, Visible=false, ZIndex=60,
    })
    round(tapHint, 9)
    local tapHintStroke = new("UIStroke", {
        Thickness=2, Transparency=1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=Color3.new(1,1,1),
    })
    tapHintStroke.Parent = tapHint
    new("UIGradient", { Color=BluePinkSeq, Rotation=30 }).Parent = tapHintStroke
    tapHint.Parent = mBtn
    reg(tapHint, "BackgroundColor3", "BgGlass"); reg(tapHint, "TextColor3", "Text")

    local function showTapHint()
        tapHint.Visible = true
        tapHint.TextTransparency = 1
        tapHint.BackgroundTransparency = 1
        tapHintStroke.Transparency = 1
        tween(tapHint, 0.15, { TextTransparency=0, BackgroundTransparency=0.1 }, Enum.EasingStyle.Quint)
        tween(tapHintStroke, 0.15, { Transparency=0.3 }, Enum.EasingStyle.Quint)
    end
    local function hideTapHint()
        tween(tapHint, 0.20, { TextTransparency=1, BackgroundTransparency=1 }, Enum.EasingStyle.Quint)
        tween(tapHintStroke, 0.20, { Transparency=1 }, Enum.EasingStyle.Quint)
        task.delay(0.20, function()
            if tapHint.TextTransparency > 0.99 then tapHint.Visible = false end
        end)
    end

    local dragging, dragStart, startAbs, moved = false, nil, nil, false
    local tapCount, lastTapTime = 0, 0
    local TAP_WINDOW = 1.5
    mBtn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position; startAbs = mBtn.AbsolutePosition
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
            if not moved then return end
            local cam = workspace.CurrentCamera; if not cam then return end
            local vp = cam.ViewportSize
            mBtn.Position = UDim2.new(0,
                math.clamp(startAbs.X + d.X, 0, vp.X - 52),
                0, math.clamp(startAbs.Y + d.Y, 0, vp.Y - 52))
        end
    end)
    local function handleTap()
        local now = tick()
        if now - lastTapTime > TAP_WINDOW then tapCount = 0 end
        tapCount = tapCount + 1
        lastTapTime = now
        if tapCount >= 2 then
            tapCount = 0; hideTapHint()
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

    _G.Meredios_mBtn = mBtn
    _G.Meredios_mBtnStroke = mBtnStroke
    _G.Meredios_mGlowStroke = mGlowStroke
    _G.Meredios_hideTapHint = hideTapHint
end

--================= OPEN / CLOSE / MORPH =================
do
    local morphing, started, closeToken = false, false, 0
    _G.Meredios_markStarted = function() started = true end

    local function openMenu()
        menu.Visible = true
        menu.GroupTransparency = 1
        menu.BackgroundTransparency = 0.04
        _G.Meredios_menuStroke.Transparency = 1
        tween(menu, 0.35, { GroupTransparency=0 })
        tween(_G.Meredios_menuStroke, 0.35, { Transparency=0.05 })
        task.defer(function()
            if _G.Meredios_animatePageIn then _G.Meredios_animatePageIn(contentPages[activeTab]) end
        end)
    end

    local function hideAllPanels()
        _G.MerediosSettingsOpen = false
        _G.Meredios_settings.Visible = false
        aimPanel.Visible = false
        filterPanel.Visible = false
    end

    local function closeMenu()
        hideAllPanels()
        closeToken = closeToken + 1
        local myToken = closeToken
        tween(menu, 0.30, { GroupTransparency=1 })
        tween(_G.Meredios_menuStroke, 0.30, { Transparency=1 })
        tween(_G.Meredios_settings, 0.30, { GroupTransparency=1, BackgroundTransparency=1 })
        tween(_G.Meredios_settingsStroke, 0.30, { Transparency=1 })
        tween(aimPanel, 0.30, { GroupTransparency=1, BackgroundTransparency=1 })
        tween(filterPanel, 0.30, { GroupTransparency=1, BackgroundTransparency=1 })
        task.delay(0.30, function()
            if closeToken ~= myToken then return end
            menu.Visible = false
            menu.GroupTransparency = 0
            _G.Meredios_settings.GroupTransparency = 1
            _G.Meredios_settings.BackgroundTransparency = 0.02
            _G.Meredios_settingsStroke.Transparency = 0.12
            aimPanel.GroupTransparency = 1
            aimPanel.BackgroundTransparency = 0.02
            filterPanel.GroupTransparency = 1
            filterPanel.BackgroundTransparency = 0.02
            mBtn.Visible = true
            mBtn.BackgroundTransparency = 1; mBtn.TextTransparency = 1
            tween(mBtn, 0.32, { BackgroundTransparency=0.08, TextTransparency=0 })
        end)
    end

    _G.MerediosMorph = function()
        if not started or morphing or menu.Visible then return end
        morphing = true
        if _G.Meredios_hideTapHint then _G.Meredios_hideTapHint() end
        local oSize = mBtn.Size
        local oPos = mBtn.Position
        local oText = mBtn.Text
        tween(mBtn, 0.32, { Size=UDim2.new(0,140,0,52) })
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
        tween(mBtn, 0.28, { BackgroundTransparency=1, TextTransparency=1 })
        tween(_G.Meredios_mBtnStroke, 0.28, { Transparency=1 })
        tween(_G.Meredios_mGlowStroke, 0.28, { Transparency=1 })
        task.wait(0.28)
        mBtn.Visible = false
        mBtn.BackgroundTransparency = 0.08; mBtn.TextTransparency = 0
        mBtn.Text = oText; mBtn.TextSize = 20
        mBtn.Size = oSize; mBtn.Position = oPos
        mBtn.TextColor3 = P.Text
        _G.Meredios_mBtnStroke.Transparency = 0.05
        _G.Meredios_mGlowStroke.Transparency = 0.75
        morphing = false
        openMenu()
    end

    _G.Meredios_closeMenu = closeMenu
    _G.MerediosOpenSettings = function()
        _G.MerediosSettingsOpen = true
        local s = _G.Meredios_settings
        s.Visible = true
        s.GroupTransparency = 1
        s.BackgroundTransparency = 1
        _G.Meredios_settingsStroke.Transparency = 1
        s.Size = UDim2.new(0, 280, 0, 220)
        s.Position = UDim2.new(0.5, 0, 0.5, 0)
        tween(s, 0.40, {
            GroupTransparency=0, BackgroundTransparency=0.02,
            Size=UDim2.new(0, 320, 0, 250),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(_G.Meredios_settingsStroke, 0.40, { Transparency=0.12 })
    end
    _G.MerediosCloseSettings = function()
        _G.MerediosSettingsOpen = false
        local myToken = closeToken + 1
        closeToken = myToken
        tween(_G.Meredios_settings, 0.30, {
            GroupTransparency=1, BackgroundTransparency=1,
            Size=UDim2.new(0, 280, 0, 220),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(_G.Meredios_settingsStroke, 0.30, { Transparency=1 })
        task.delay(0.30, function()
            if closeToken ~= myToken then return end
            _G.Meredios_settings.Visible = false
            _G.Meredios_settings.Size = UDim2.new(0, 320, 0, 250)
            _G.Meredios_settings.GroupTransparency = 0
            _G.Meredios_settings.BackgroundTransparency = 0.02
            _G.Meredios_settingsStroke.Transparency = 0.12
        end)
    end
end

_G.Meredios_gearBtn.MouseButton1Click:Connect(function() _G.MerediosOpenSettings() end)
_G.Meredios_sClose.MouseButton1Click:Connect(function() _G.MerediosCloseSettings() end)
_G.Meredios_closeBtn.MouseButton1Click:Connect(function() _G.Meredios_closeMenu() end)

--================= START BUTTON =================
_G.Meredios_startBtn.MouseButton1Click:Connect(function()
    if not keyValidated then
        return
    end
    if _G.Meredios_markStarted then _G.Meredios_markStarted() end
    tween(_G.Meredios_startup, 0.4, { GroupTransparency=1 })
    tween(_G.Meredios_startupStroke, 0.4, { Transparency=1 })
    task.delay(0.4, function()
        _G.Meredios_startup.Visible = false
        _G.Meredios_mBtn.Visible = true
        _G.Meredios_mBtn.BackgroundTransparency = 1
        _G.Meredios_mBtn.TextTransparency = 1
        tween(_G.Meredios_mBtn, 0.32, { BackgroundTransparency=0.08, TextTransparency=0 })
        logScript("Meredios HUD v8.6 started · t.me//meredioshub")
    end)
end)

--================= FINAL =================
for _, e in ipairs(ThemeReg) do
    local inst, prop, key = e[1], e[2], e[3]
    if inst and inst.Parent then inst[prop] = P[key] end
end

logScript("Kernel loaded · v8.6")
logScript("t.me//meredioshub")
logScript("Aimbot sticky-lock · FOV=" .. Aimbot.FOV .. " · " .. Aimbot.ColorName)

return true
