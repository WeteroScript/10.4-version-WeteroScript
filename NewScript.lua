--[[
    MEREDIOS v6.4 — оперативный контур
    Roblox / Delta X Mobile
--]]

do
    local targets = {}
    pcall(function() table.insert(targets, game:GetService("CoreGui")) end)
    pcall(function() table.insert(targets, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)) end)
    for _, p in ipairs(targets) do
        if p then
            for _, g in ipairs(p:GetChildren()) do
                if g.Name == "MerediosHUD" or g.Name == "MerediosESP" then
                    pcall(function() g:Destroy() end)
                end
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
ScreenGui.DisplayOrder = 100

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

local Theme = { mode = "Light", accent = "Cyan", anim = true }

local Palettes = {
    Light = {
        Bg=Color3.fromRGB(245,247,252), BgGlass=Color3.fromRGB(252,253,255),
        Card=Color3.fromRGB(255,255,255), CardEdge=Color3.fromRGB(225,230,240),
        Text=Color3.fromRGB(22,28,42), SubText=Color3.fromRGB(120,130,152),
        Track=Color3.fromRGB(205,212,226), Knob=Color3.fromRGB(255,255,255),
        Divider=Color3.fromRGB(225,230,240), Shadow=Color3.fromRGB(0,0,0),
    },
    Dark = {
        Bg=Color3.fromRGB(24,29,41), BgGlass=Color3.fromRGB(31,37,52),
        Card=Color3.fromRGB(38,45,62), CardEdge=Color3.fromRGB(58,68,88),
        Text=Color3.fromRGB(235,240,250), SubText=Color3.fromRGB(145,158,182),
        Track=Color3.fromRGB(60,70,92), Knob=Color3.fromRGB(255,255,255),
        Divider=Color3.fromRGB(58,68,88), Shadow=Color3.fromRGB(0,0,0),
    },
}

local Accents = {
    Cyan   = { Main = Color3.fromRGB(0, 210, 255) },
    Purple = { Main = Color3.fromRGB(160, 95, 255) },
    Pink   = { Main = Color3.fromRGB(255, 95, 175) },
}

local GradientColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 210, 255)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(160, 95, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 95, 175)),
})

local P, Accent
local function refreshPalettes() P = Palettes[Theme.mode]; Accent = Accents[Theme.accent] end
refreshPalettes()

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

local function applyTheme()
    refreshPalettes()
    for _, e in ipairs(ThemeReg) do
        local inst, prop, key = e[1], e[2], e[3]
        if inst and inst.Parent then tween(inst, 0.32, {[prop] = P[key]}) end
    end
end

local Logger = {
    buffer = { server = {}, script = {} },
    maxLen = 100,
    listeners = {},
    activeTab = "server",
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

local function shortRemoteName(fullName)
    if not fullName then return "?" end
    local last = fullName:match("([^%.]+)$") or fullName
    if #last < 3 then
        local parts = {}
        for p in fullName:gmatch("[^%.]+") do table.insert(parts, p) end
        if #parts >= 2 then last = parts[#parts - 1] .. "." .. parts[#parts] end
    end
    return last
end

local function describeValue(v, depth)
    depth = depth or 1
    local t = typeof(v)
    if t == "string" then return '"' .. v .. '"'
    elseif t == "Instance" then return v.Name
    elseif t == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then local p = v.Position; return string.format("CF(%.1f,%.1f,%.1f)", p.X, p.Y, p.Z)
    elseif t == "number" then return string.format("%g", v)
    elseif t == "boolean" then return tostring(v)
    elseif t == "table" and depth <= 4 then
        local sub = {}; local count = 0
        for k, sv in pairs(v) do
            count = count + 1
            if count > 6 then sub[#sub + 1] = "…"; break end
            sub[#sub + 1] = tostring(k) .. ":" .. describeValue(sv, depth + 1)
        end
        return "{" .. table.concat(sub, ", ") .. "}"
    end
    return t
end

local function summarizeArgs(args, n)
    local parts = {}
    for i = 1, math.min(n or #args, 6) do
        parts[i] = describeValue(args[i], 1)
    end
    if (n or #args) > 6 then parts[#parts + 1] = "…+" .. ((n or #args) - 6) end
    return table.concat(parts, ", ")
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
            HitboxChanger.Original[part] = { Size = part.Size, Transparency = part.Transparency }
        end
        part.Size = Vector3.new(HitboxChanger.Size, HitboxChanger.Size, HitboxChanger.Size)
        part.Transparency = 1
        part.CanQuery = true
        part.CanTouch = true
    end
end

local function restoreHitboxForChar(char)
    if not char then return end
    for part, orig in pairs(HitboxChanger.Original) do
        if part and part.Parent and part:IsDescendantOf(char) then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
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
    HitboxChanger.Original = {}
end

local function applyHitboxViewToChar(char)
    if not char then return end
    for _, part in ipairs(hitboxParts(char)) do
        if not part:FindFirstChild("MerediosHitboxView") then
            local box = new("BoxHandleAdornment", {
                Name = "MerediosHitboxView",
                Adornee = part,
                AlwaysOnTop = true,
                ZIndex = 5,
                Transparency = 0.5,
                Color3 = Accent.Main,
                Size = part.Size,
            })
            box.Parent = part
        end
    end
end

local function removeHitboxViewFromChar(char)
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d.Name == "MerediosHitboxView" then pcall(function() d:Destroy() end) end
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
local ESP = { Enabled = false, Color = Color3.fromRGB(255, 60, 60), Highlights = {} }

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
    if not ESP.Enabled or plr == LP then return end
    local char = plr.Character
    if not char then return end
    local h = createESPHighlight(char)
    if h then ESP.Highlights[plr] = h end
end

local function refreshAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        updateESPForPlayer(plr)
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
    if speed > 40 then
        local dir = speed > 0 and vel.Unit or Vector3.zero
        hrp.AssemblyLinearVelocity = dir * math.min(speed, 16)
    end
    if ang.Magnitude > 8 then hrp.AssemblyAngularVelocity = Vector3.zero end
    if vel.Y > 30 then hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z) end
    if hrp.Position.Y > 200 then
        hrp.CFrame = CFrame.new(hrp.Position.X, 20, hrp.Position.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end)

local RapidFire = {
    Enabled = false,
    Multiplier = 5,
    Delay = 0.05,
}

local function hookPlayerForCombat(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.25)
        if HitboxChanger.Enabled then applyHitboxToChar(char) end
        if HitboxChanger.View then applyHitboxViewToChar(char) end
        if ESP.Enabled then updateESPForPlayer(plr) end
    end)
    plr.CharacterRemoving:Connect(function(char)
        removeESPFromChar(char)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then hookPlayerForCombat(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LP then hookPlayerForCombat(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    if ESP.Highlights[plr] then
        pcall(function() ESP.Highlights[plr]:Destroy() end)
        ESP.Highlights[plr] = nil
    end
end)

--=============================================================
-- ХУК __namecall
--=============================================================
local hooked = false

local IGNORE_REMOTES = {
    ClientLogging = true,
    LeaderboardEvent = true,
    PingData = true,
}

local function installHook()
    if hooked then return end
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then return end
    hooked = true

    local wrapper
    if type(newcclosure) == "function" then wrapper = newcclosure
    else wrapper = function(f) return f end end

    local ok = pcall(function()
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", wrapper(function(self, ...)
            local method, fullName, shortName, args
            local parseOk = pcall(function()
                method = getnamecallmethod()
                if not method then error("no method") end
                args = table.pack(...)
                fullName = "?"
                if typeof(self) == "Instance" then
                    local okN, n = pcall(function() return self:GetFullName() end)
                    fullName = okN and n or "?"
                else
                    fullName = tostring(self)
                end
                shortName = fullName:match("([^%.]+)$") or fullName
            end)

            if not parseOk then return oldNC(self, ...) end

            if RapidFire.Enabled and shortName == "WeaponReloadRequest" then
                logScript("Reload blocked")
                return nil
            end

            pcall(function()
                local skipLog = IGNORE_REMOTES[shortName] == true
                if not skipLog and (method == "FireServer" or method == "InvokeServer"
                                    or method == "Fire" or method == "Invoke") then
                    logServer(method .. " → " .. shortRemoteName(fullName)
                        .. " (" .. summarizeArgs(args, args.n) .. ")")
                end
            end)

            if RapidFire.Enabled and shortName == "WeaponHit" then
                local okMain, mainResult = pcall(function()
                    return oldNC(self, table.unpack(args, 1, args.n))
                end)
                local extra = math.clamp(RapidFire.Multiplier - 1, 0, 15)
                for i = 1, extra do
                    task.spawn(function()
                        task.wait(RapidFire.Delay * i)
                        pcall(function()
                            oldNC(self, table.unpack(args, 1, args.n))
                        end)
                    end)
                end
                return mainResult
            end

            return oldNC(self, ...)
        end))
    end)
    if not ok then hooked = false end
end
pcall(installHook)

--=============================================================
-- STARTUP
--=============================================================
local startup = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 280, 0, 120),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.05,
    BorderSizePixel = 0, GroupTransparency = 1,
})
round(startup, 18)
gradientStroke(startup, 1.2, 0.12, 30)
startup.Parent = ScreenGui
reg(startup, "BackgroundColor3", "BgGlass")

local startupTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, -60, 0, 24),
    Size = UDim2.new(1, -44, 0, 28),
    Text = "Meredios", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 24,
    TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1,
})
startupTitle.Parent = startup
reg(startupTitle, "TextColor3", "Text")

local startBtn = new("TextButton", {
    Position = UDim2.new(0.5, 0, 1, -52), AnchorPoint = Vector2.new(0.5, 0),
    Size = UDim2.new(0, 130, 0, 34),
    BackgroundColor3 = Accent.Main,
    Text = "НАЧАТЬ", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamMedium, TextSize = 13,
    AutoButtonColor = false, BorderSizePixel = 0,
    TextTransparency = 1, BackgroundTransparency = 1,
})
round(startBtn, 10)
startBtn.Parent = startup

tween(startup, 0.45, { GroupTransparency = 0 })

task.spawn(function()
    task.wait(0.7)
    if not startup.Parent then return end
    tween(startupTitle, 0.5, { Position = UDim2.new(0, 20, 0, 24), TextTransparency = 0 })
    task.wait(0.15)
    tween(startBtn, 0.42, { TextTransparency = 0, BackgroundTransparency = 0 })
end)

--=============================================================
-- МЕНЮ
--=============================================================
local MENU_W, MENU_H = 380, 340

local menu = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, MENU_W, 0, MENU_H),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.04,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false,
})
round(menu, 18)
local menuStroke = gradientStroke(menu, 1.2, 0.08, 30)
menu.Parent = ScreenGui
reg(menu, "BackgroundColor3", "BgGlass")

local topBar = new("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 })
topBar.Parent = menu

local brand = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 8),
    Size = UDim2.new(0, 220, 0, 16),
    Text = "MEREDIOS", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
})
brand.Parent = topBar
reg(brand, "TextColor3", "Text")

local subBrand = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 24),
    Size = UDim2.new(0, 300, 0, 12),
    Text = "оперативный контур // v6.4",
    TextColor3 = P.SubText, Font = Enum.Font.Gotham,
    TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
})
subBrand.Parent = topBar
reg(subBrand, "TextColor3", "SubText")

local rightBox = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0, 24),
    Size = UDim2.new(0, 64, 0, 26), BackgroundTransparency = 1,
})
rightBox.Parent = topBar

local gearBtn = new("TextButton", {
    Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "⚙", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 13,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(gearBtn, 8); gearBtn.Parent = rightBox
reg(gearBtn, "BackgroundColor3", "Card")
reg(gearBtn, "TextColor3", "Text")

local closeBtn = new("TextButton", {
    Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 38, 0, 0),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 16,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(closeBtn, 8); closeBtn.Parent = rightBox
reg(closeBtn, "BackgroundColor3", "Card")
reg(closeBtn, "TextColor3", "Text")

dragify(menu, topBar, function() return not (_G.MerediosSettingsOpen == true) end)

local tabBar = new("ScrollingFrame", {
    Position = UDim2.new(0, 10, 0, 52),
    Size = UDim2.new(1, -20, 0, 30),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.X,
})
tabBar.Parent = menu

local tabLayout = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
})
tabLayout.Parent = tabBar

local contentBox = new("Frame", {
    Position = UDim2.new(0, 10, 0, 88),
    Size = UDim2.new(1, -20, 1, -98),
    BackgroundTransparency = 1,
})
contentBox.Parent = menu

local TABS = { "MAIN", "LOG", "COMBAT" }
for i = 3, 15 do table.insert(TABS, "TEST " .. i) end

local tabButtons = {}
local contentPages = {}
local activeTab = "MAIN"

local function switchTab(name)
    activeTab = name
    for tName, btn in pairs(tabButtons) do
        local on = tName == name
        tween(btn, 0.22, {
            BackgroundTransparency = on and 0.05 or 0.85,
            TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText,
        })
        if btn:FindFirstChild("UIStroke") then
            btn.UIStroke.Transparency = on and 0 or 0.5
        end
    end
    for tName, page in pairs(contentPages) do page.Visible = tName == name end
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
        Visible = false,
    })
    page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    page.Parent = contentBox
    contentPages[name] = page
    return page
end

local function makeTab(name)
    local btn = new("TextButton", {
        Size = UDim2.new(0, 66, 0, 26),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.85,
        Text = name, TextColor3 = P.SubText,
        Font = Enum.Font.GothamMedium, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0,
        LayoutOrder = #tabButtons,
    })
    round(btn, 8)
    gradientStroke(btn, 1, 0.5, 30)
    btn.Parent = tabBar
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabButtons[name] = btn
    return btn
end

for _, name in ipairs(TABS) do makeTab(name) end

local function makeCard(parent, order, title)
    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.06,
        BorderSizePixel = 0, LayoutOrder = order,
    })
    round(card, 12)
    gradientStroke(card, 1, 0.25, 35)
    card.Parent = parent
    reg(card, "BackgroundColor3", "Card")

    local t = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 14),
        Text = title, TextColor3 = P.Text,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    t.Parent = card
    reg(t, "TextColor3", "Text")
    return card
end

local function makeSwitch(card, y, onChanged)
    local track = new("Frame", {
        Size = UDim2.new(0, 40, 0, 18),
        Position = UDim2.new(1, -48, 0, y or 36),
        BackgroundColor3 = P.Track, BorderSizePixel = 0,
    })
    round(track, 9); track.Parent = card

    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = P.Knob, BorderSizePixel = 0, ZIndex = 3,
    })
    round(knob, 7); knob.Parent = track

    local lbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -76, 0, (y or 36) + 3),
        Size = UDim2.new(0, 24, 0, 12),
        Text = "OFF", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    lbl.Parent = card
    reg(lbl, "TextColor3", "SubText")

    local state = false
    local function set(v)
        state = v
        tween(knob, 0.26, { Position = v and UDim2.new(1, -2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
        tween(track, 0.26, { BackgroundColor3 = v and Accent.Main or P.Track })
        lbl.Text = v and "ON" or "OFF"
        lbl.TextColor3 = v and Accent.Main or P.SubText
        if onChanged then onChanged(v) end
    end
    local btn = new("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "" })
    btn.Parent = track
    btn.MouseButton1Click:Connect(function() set(not state) end)
    return set
end

--=============================================================
-- MAIN
--=============================================================
local mainPage = makePage("MAIN")
local listLayout = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
listLayout.Parent = mainPage

do
    local card = makeCard(mainPage, 1, "SPEED WALK")
    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(0, 60, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(Speed.Value), TextColor3 = P.Text,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true,
    })
    round(box, 6); box.Parent = card
    reg(box, "BackgroundColor3", "Bg")
    reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then Speed.Value = math.clamp(math.floor(n), 8, 500) end
        box.Text = tostring(Speed.Value)
        logScript("Speed value set to " .. tostring(Speed.Value))
    end)

    makeSwitch(card, 36, function(v)
        Speed.Enabled = v
        if not v then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        logScript("Speed " .. (v and "ENABLED" or "DISABLED"))
    end)
end

do
    local card = makeCard(mainPage, 2, "ANTI-FLING")
    makeSwitch(card, 36, function(v)
        AntiFling.Enabled = v
        logScript("Anti-Fling " .. (v and "ENABLED" or "DISABLED"))
    end)
end

do
    local card = makeCard(mainPage, 3, "REJOIN")
    local btn = new("TextButton", {
        Position = UDim2.new(0, 12, 0, 34),
        Size = UDim2.new(1, -24, 0, 28),
        BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.25,
        Text = "REJOIN", TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 11,
        AutoButtonColor = false, BorderSizePixel = 0,
    })
    round(btn, 8); btn.Parent = card

    btn.MouseButton1Click:Connect(function()
        logScript("Rejoin initiated")
        pcall(function() TeleportSvc:Teleport(game.PlaceId, LP) end)
    end)
    btn.MouseEnter:Connect(function() tween(btn, 0.2, { BackgroundTransparency = 0.05 }) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.2, { BackgroundTransparency = 0.25 }) end)
end

--=============================================================
-- LOG
--=============================================================
local logPage = makePage("LOG")
logPage.ScrollingDirection = Enum.ScrollingDirection.X
logPage.AutomaticCanvasSize = Enum.AutomaticSize.None
logPage.CanvasSize = UDim2.new(1, 0, 1, 0)
logPage.ElasticBehavior = Enum.ElasticBehavior.Never
logPage.ScrollingEnabled = false

local logViewport = new("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, -32),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
})
round(logViewport, 10)
gradientStroke(logViewport, 1, 0.25, 35)
logViewport.Parent = logPage
reg(logViewport, "BackgroundColor3", "Card")

local logScroll = new("ScrollingFrame", {
    Position = UDim2.new(0, 8, 0, 8),
    Size = UDim2.new(1, -16, 1, -16),
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
    Position = UDim2.new(0, 0, 1, -26),
    Size = UDim2.new(0.44, -2, 0, 26),
    BackgroundColor3 = Accent.Main, BackgroundTransparency = 0.05,
    Text = "SERVER LOG", TextColor3 = Color3.fromRGB(255,255,255),
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(serverTabBtn, 8)
gradientStroke(serverTabBtn, 1, 0.3, 30)
serverTabBtn.Parent = logPage

local scriptTabBtn = new("TextButton", {
    Position = UDim2.new(0.44, 0, 1, -26),
    Size = UDim2.new(0.44, -2, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "SCRIPT LOG", TextColor3 = P.SubText,
    Font = Enum.Font.GothamBold, TextSize = 10,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(scriptTabBtn, 8)
gradientStroke(scriptTabBtn, 1, 0.5, 30)
scriptTabBtn.Parent = logPage
reg(scriptTabBtn, "BackgroundColor3", "Card")
reg(scriptTabBtn, "TextColor3", "SubText")

local clearBtn = new("TextButton", {
    Position = UDim2.new(0.88, 2, 1, -26),
    Size = UDim2.new(0.12, -2, 0, 26),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "CLEAR", TextColor3 = Color3.fromRGB(255, 80, 80),
    Font = Enum.Font.GothamBold, TextSize = 9,
    AutoButtonColor = false, BorderSizePixel = 0,
})
round(clearBtn, 8)
gradientStroke(clearBtn, 1, 0.5, 30)
clearBtn.Parent = logPage
reg(clearBtn, "BackgroundColor3", "Card")

local logLineCache = {}

local function renderLog()
    local buf = Logger.buffer[Logger.activeTab]
    while #logLineCache < #buf do
        local lbl = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = "", TextColor3 = P.Text,
            Font = Enum.Font.Code, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = #logLineCache + 1,
        })
        lbl.Parent = logScroll
        table.insert(logLineCache, lbl)
        reg(lbl, "TextColor3", "Text")
    end
    for i, lbl in ipairs(logLineCache) do
        if i <= #buf then
            lbl.Text = buf[i]
            lbl.Visible = true
        else
            lbl.Visible = false
        end
    end
    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, math.max(0, logLayout.AbsoluteContentSize.Y - logScroll.AbsoluteSize.Y))
    end)
end

local function switchLogTab(which)
    Logger.activeTab = which
    if which == "server" then
        serverTabBtn.BackgroundColor3 = Accent.Main
        serverTabBtn.BackgroundTransparency = 0.05
        serverTabBtn.TextColor3 = Color3.fromRGB(255,255,255)
        scriptTabBtn.BackgroundColor3 = P.Card
        scriptTabBtn.BackgroundTransparency = 0.15
        scriptTabBtn.TextColor3 = P.SubText
    else
        scriptTabBtn.BackgroundColor3 = Accent.Main
        scriptTabBtn.BackgroundTransparency = 0.05
        scriptTabBtn.TextColor3 = Color3.fromRGB(255,255,255)
        serverTabBtn.BackgroundColor3 = P.Card
        serverTabBtn.BackgroundTransparency = 0.15
        serverTabBtn.TextColor3 = P.SubText
    end
    renderLog()
end

serverTabBtn.MouseButton1Click:Connect(function() switchLogTab("server") end)
scriptTabBtn.MouseButton1Click:Connect(function() switchLogTab("script") end)

clearBtn.MouseButton1Click:Connect(function()
    Logger.buffer.server = {}
    Logger.buffer.script = {}
    renderLog()
end)

table.insert(Logger.listeners, function(channel)
    if channel == Logger.activeTab then renderLog() end
end)

--=============================================================
-- COMBAT
--=============================================================
local combatPage = makePage("COMBAT")
local combatList = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
combatList.Parent = combatPage

do
    local card = makeCard(combatPage, 1, "HITBOX CHANGER")

    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(0, 60, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(HitboxChanger.Size), TextColor3 = P.Text,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true,
    })
    round(box, 6); box.Parent = card
    reg(box, "BackgroundColor3", "Bg")
    reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            HitboxChanger.Size = math.clamp(math.floor(n), 1, 50)
            if HitboxChanger.Enabled then
                restoreAllHitboxes()
                applyAllHitboxes()
            end
            if HitboxChanger.View then refreshAllHitboxViews() end
            logScript("Hitbox size set to " .. tostring(HitboxChanger.Size))
        end
        box.Text = tostring(HitboxChanger.Size)
    end)

    makeSwitch(card, 36, function(v)
        HitboxChanger.Enabled = v
        if v then applyAllHitboxes() else restoreAllHitboxes() end
        logScript("Hitbox Changer " .. (v and "ENABLED" or "DISABLED"))
    end)

    local viewBtn = new("TextButton", {
        Position = UDim2.new(1, -104, 0, 36),
        Size = UDim2.new(0, 52, 0, 22),
        BackgroundColor3 = P.Card, BackgroundTransparency = 0.3,
        Text = "VIEW", TextColor3 = P.SubText,
        Font = Enum.Font.GothamBold, TextSize = 10,
        AutoButtonColor = false, BorderSizePixel = 0,
    })
    round(viewBtn, 6)
    gradientStroke(viewBtn, 1, 0.5, 30)
    viewBtn.Parent = card
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
        logScript("Hitbox View " .. (v and "ENABLED" or "DISABLED"))
    end
    viewBtn.MouseButton1Click:Connect(function() setView(not viewState) end)
end

do
    local card = makeCard(combatPage, 2, "RAPID FIRE")

    local box = new("TextBox", {
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(0, 60, 0, 22),
        BackgroundColor3 = P.Bg, BackgroundTransparency = 0.4,
        Text = tostring(RapidFire.Multiplier), TextColor3 = P.Text,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        BorderSizePixel = 0, ClearTextOnFocus = false, TextEditable = true,
    })
    round(box, 6); box.Parent = card
    reg(box, "BackgroundColor3", "Bg")
    reg(box, "TextColor3", "Text")

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then RapidFire.Multiplier = math.clamp(math.floor(n), 1, 15) end
        box.Text = tostring(RapidFire.Multiplier)
        logScript("Rapid Fire multiplier = " .. tostring(RapidFire.Multiplier))
    end)

    makeSwitch(card, 36, function(v)
        RapidFire.Enabled = v
        logScript("Rapid Fire " .. (v and "ENABLED" or "DISABLED"))
    end)
end

do
    local card = makeCard(combatPage, 3, "ESP")
    makeSwitch(card, 36, function(v)
        ESP.Enabled = v
        refreshAllESP()
        logScript("ESP " .. (v and "ENABLED" or "DISABLED"))
    end)
end

for i = 1, 15 do
    local name = "TEST " .. i
    local page = makePage(name)
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = name .. " // раздел в разработке",
        TextColor3 = P.SubText, Font = Enum.Font.Gotham, TextSize = 12,
    })
    lbl.Parent = page
    reg(lbl, "TextColor3", "SubText")
end

switchTab("MAIN")

--=============================================================
-- SETTINGS
--=============================================================
local settings = new("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 300, 0, 210),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ZIndex = 5,
})
round(settings, 14)
gradientStroke(settings, 1.2, 0.15, 30)
settings.Parent = menu
reg(settings, "BackgroundColor3", "BgGlass")

local sTitle = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 12),
    Size = UDim2.new(1, -70, 0, 16),
    Text = "SETTINGS", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
})
sTitle.Parent = settings
reg(sTitle, "TextColor3", "Text")

local sDivider = new("Frame", {
    Position = UDim2.new(0, 16, 0, 36),
    Size = UDim2.new(1, -32, 0, 1),
    BackgroundColor3 = P.Divider, BorderSizePixel = 0, ZIndex = 6,
})
sDivider.Parent = settings
reg(sDivider, "BackgroundColor3", "Divider")

local sClose = new("TextButton", {
    Position = UDim2.new(1, -36, 0, 10),
    Size = UDim2.new(0, 24, 0, 24),
    BackgroundColor3 = P.Card, BackgroundTransparency = 0.15,
    Text = "×", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 15,
    AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 6,
})
round(sClose, 8); sClose.Parent = settings
reg(sClose, "BackgroundColor3", "Card")
reg(sClose, "TextColor3", "Text")

local function sRow(y, titleText)
    local row = new("Frame", {
        Position = UDim2.new(0, 16, 0, y),
        Size = UDim2.new(1, -32, 0, 30),
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
    local div = new("Frame", {
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = P.Divider, BackgroundTransparency = 0.5,
        BorderSizePixel = 0, ZIndex = 6,
    })
    div.Parent = row
    reg(div, "BackgroundColor3", "Divider")
    return row
end

local function segControl(parent, options, current, onSelect)
    local seg = new("Frame", {
        Position = UDim2.new(0, 90, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -90, 0, 24),
        BackgroundTransparency = 1, ZIndex = 6,
    })
    seg.Parent = parent

    local layout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = seg

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
            Font = Enum.Font.GothamMedium, TextSize = 9,
            AutoButtonColor = false, BorderSizePixel = 0,
            LayoutOrder = i, ZIndex = 6,
        })
        round(b, 6); b.Parent = seg
        btns[opt] = b
        b.MouseButton1Click:Connect(function() refresh(opt); if onSelect then onSelect(opt) end end)
    end
    refresh(current)
    return seg, refresh
end

local row1 = sRow(48, "THEME")
segControl(row1, { "LIGHT", "DARK" }, Theme.mode:upper(), function(v)
    Theme.mode = v == "DARK" and "Dark" or "Light"; applyTheme()
end)

local row2 = sRow(82, "ACCENT")
segControl(row2, { "CYAN", "PURPLE", "PINK" }, Theme.accent:upper(), function(v)
    Theme.accent = v:sub(1,1) .. v:sub(2):lower()
    refreshPalettes(); applyTheme()
end)

local row3 = sRow(116, "ANIMATIONS")
segControl(row3, { "ON", "OFF" }, "ON", function(v) Theme.anim = (v == "ON") end)

--=============================================================
-- M BUTTON
--=============================================================
local mBtn = new("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 60, 0.35, 0),
    BackgroundColor3 = P.BgGlass, BackgroundTransparency = 0.08,
    Text = "M", TextColor3 = P.Text,
    Font = Enum.Font.GothamBold, TextSize = 20,
    AutoButtonColor = false, BorderSizePixel = 0, Visible = false,
})
round(mBtn, 25)
gradientStroke(mBtn, 1.4, 0.05, 30)
mBtn.Parent = ScreenGui
reg(mBtn, "BackgroundColor3", "BgGlass")
reg(mBtn, "TextColor3", "Text")

local mGlow = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 10, 1, 10),
    BackgroundTransparency = 1, ZIndex = mBtn.ZIndex - 1,
})
round(mGlow, 28)
gradientStroke(mGlow, 2, 0.75, 30)
mGlow.Parent = mBtn

do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    mBtn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position; startPos = mBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
            mBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
            if not moved and _G.MerediosMorph then _G.MerediosMorph() end
        end
    end)
end

--=============================================================
-- ПЕРЕХОДЫ
--=============================================================
local morphing = false
local started  = false

local function openMenu()
    menu.Visible = true
    menu.GroupTransparency = 1
    menu.BackgroundTransparency = 0.04
    tween(menu, 0.35, { GroupTransparency = 0 })
end

local function closeMenu()
    _G.MerediosSettingsOpen = false
    tween(menu, 0.30, { GroupTransparency = 1 })
    task.delay(0.30, function()
        menu.Visible = false
        menu.GroupTransparency = 0
        settings.Visible = false
        settings.GroupTransparency = 1

        mBtn.Visible = true
        mBtn.BackgroundTransparency = 1
        mBtn.TextTransparency = 1
        tween(mBtn, 0.32, { BackgroundTransparency = 0.08, TextTransparency = 0 })
    end)
end

function _G.MerediosMorph()
    if not started then return end
    if morphing then return end
    if menu.Visible then return end
    morphing = true

    local originalSize = mBtn.Size
    local originalPos  = mBtn.Position
    local originalText = mBtn.Text

    tween(mBtn, 0.32, { Size = UDim2.new(0, 140, 0, 50) })
    task.wait(0.10)
    mBtn.Text = "MEREDIOS"; mBtn.TextSize = 14

    task.spawn(function()
        local t0 = tick()
        while tick() - t0 < 0.55 and mBtn.Parent do
            local phase = (tick() - t0) / 0.55
            mBtn.TextColor3 = GradientColors:Evaluate(phase % 1)
            task.wait(0.03)
        end
    end)

    task.wait(0.55)
    tween(mBtn, 0.28, { BackgroundTransparency = 1, TextTransparency = 1 })
    task.wait(0.28)

    mBtn.Visible = false
    mBtn.BackgroundTransparency = 0.08
    mBtn.TextTransparency = 0
    mBtn.Text = originalText
    mBtn.TextSize = 20
    mBtn.Size = originalSize
    mBtn.Position = originalPos
    mBtn.TextColor3 = P.Text

    morphing = false
    openMenu()
end

closeBtn.MouseButton1Click:Connect(closeMenu)

gearBtn.MouseButton1Click:Connect(function()
    _G.MerediosSettingsOpen = true
    settings.Visible = true
    settings.GroupTransparency = 1
    settings.Size = UDim2.new(0, 260, 0, 180)
    settings.Position = UDim2.new(0.5, 0, 0.5, 0)
    tween(settings, 0.40, {
        GroupTransparency = 0,
        Size = UDim2.new(0, 300, 0, 210),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
end)

sClose.MouseButton1Click:Connect(function()
    _G.MerediosSettingsOpen = false
    tween(settings, 0.30, {
        GroupTransparency = 1,
        Size = UDim2.new(0, 260, 0, 180),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.30, function()
        settings.Visible = false
        settings.Size = UDim2.new(0, 300, 0, 210)
        settings.GroupTransparency = 0
    end)
end)

--=============================================================
-- СТАРТ
--=============================================================
startBtn.MouseButton1Click:Connect(function()
    started = true
    tween(startup, 0.4, { GroupTransparency = 1 })
    task.delay(0.4, function()
        startup.Visible = false
        openMenu()
        logScript("Meredios HUD started")
    end)
end)

for _, e in ipairs(ThemeReg) do
    local inst, prop, key = e[1], e[2], e[3]
    if inst and inst.Parent then inst[prop] = P[key] end
end

menu.Visible = false
menu.GroupTransparency = 0
settings.Visible = false
settings.GroupTransparency = 1
mBtn.Visible = false
startup.Visible = true
startup.GroupTransparency = 1

logScript("Kernel loaded")
renderLog()

return true
