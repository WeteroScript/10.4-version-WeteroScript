-- language: Lua, target: Roblox / Delta X executor
-- MEREDIOS v12 — speed bypass + full

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer

local ok_gethui, gethui_val = pcall(function() return gethui() end)
local parent = (ok_gethui and gethui_val) or game:GetService("CoreGui")

local VERSION = "v12"

local C = {
    bg=Color3.fromRGB(9,9,14), surface=Color3.fromRGB(19,19,27),
    surface2=Color3.fromRGB(26,26,36), surface3=Color3.fromRGB(36,36,48),
    line=Color3.fromRGB(50,50,68), text=Color3.fromRGB(250,250,254),
    dim=Color3.fromRGB(150,150,172),
    a1=Color3.fromRGB(160,120,255), a2=Color3.fromRGB(110,200,255),
    a3=Color3.fromRGB(255,130,200), a4=Color3.fromRGB(120,240,210),
    red=Color3.fromRGB(255,90,110), red2=Color3.fromRGB(200,40,60),
    green=Color3.fromRGB(120,235,175), amber=Color3.fromRGB(255,200,90),
}

local function mk(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then o[k] = v end end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end
local function corner(o, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col; s.Thickness = th or 1; s.Transparency = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = o; return s
end
local function grad(o, c1, c2, rot)
    local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0; g.Parent = o; return g
end
local function tween(o, t, props, s, d)
    local tw = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), props)
    tw:Play(); return tw
end

local screen = mk("ScreenGui", {
    Name = "Meredios_" .. tostring(math.random(1e6)),
    ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parent,
})

local W, H = 361, 335
local SIDEBAR_W = 76
local TITLE_H = 58

local glow3 = mk("Frame", {
    Size = UDim2.new(0, W + 56, 0, H + 56),
    Position = UDim2.new(0.5, -(W+56)/2, 0.5, -(H+56)/2),
    BackgroundColor3 = C.a1, BackgroundTransparency = 0.94,
    BorderSizePixel = 0, ZIndex = 0, Parent = screen,
})
corner(glow3, 48)
local glow3Grad = mk("UIGradient", {Parent = glow3})
glow3Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.a1), ColorSequenceKeypoint.new(0.33, C.a2),
    ColorSequenceKeypoint.new(0.66, C.a3), ColorSequenceKeypoint.new(1.00, C.a4),
})

local glow2 = mk("Frame", {
    Size = UDim2.new(0, W + 32, 0, H + 32),
    Position = UDim2.new(0.5, -(W+32)/2, 0.5, -(H+32)/2),
    BackgroundColor3 = C.a2, BackgroundTransparency = 0.9,
    BorderSizePixel = 0, ZIndex = 0, Parent = screen,
})
corner(glow2, 38)

local ring = mk("Frame", {
    Size = UDim2.new(0, W + 6, 0, H + 6),
    Position = UDim2.new(0.5, -(W+6)/2, 0.5, -(H+6)/2),
    BackgroundColor3 = C.a1, BorderSizePixel = 0, ZIndex = 1, Parent = screen,
})
corner(ring, 24)
local ringGrad = mk("UIGradient", {Parent = ring})
ringGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.a1), ColorSequenceKeypoint.new(0.33, C.a2),
    ColorSequenceKeypoint.new(0.66, C.a3), ColorSequenceKeypoint.new(1.00, C.a1),
})

local main = mk("Frame", {
    Name = "Main", Size = UDim2.new(0, W, 0, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true,
    ZIndex = 2, Parent = screen,
})
corner(main, 20)
local mainScale = mk("UIScale", {Scale = 1, Parent = main})

local wash = mk("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.a1,
    BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = 3, Parent = main,
})
corner(wash, 20)
local washGrad = mk("UIGradient", {Parent = wash})
washGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.a1), ColorSequenceKeypoint.new(0.33, C.a2),
    ColorSequenceKeypoint.new(0.66, C.a3), ColorSequenceKeypoint.new(1.00, C.a4),
})

task.spawn(function() while ring.Parent do tween(ringGrad, 9, {Rotation = ringGrad.Rotation + 360}, Enum.EasingStyle.Linear); task.wait(9) end end)
task.spawn(function() while wash.Parent do tween(washGrad, 14, {Rotation = washGrad.Rotation + 360}, Enum.EasingStyle.Linear); task.wait(14) end end)
task.spawn(function() while glow3.Parent do tween(glow3Grad, 9, {Rotation = glow3Grad.Rotation + 360}, Enum.EasingStyle.Linear); task.wait(9) end end)

local titleBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, TITLE_H), BackgroundColor3 = C.surface,
    BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 4, Parent = main,
})
corner(titleBar, 20)
mk("Frame", {
    Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20),
    BackgroundColor3 = C.surface, BackgroundTransparency = 0.15,
    BorderSizePixel = 0, ZIndex = 4, Parent = titleBar,
})
mk("Frame", {
    Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = C.line, BackgroundTransparency = 0.4,
    BorderSizePixel = 0, ZIndex = 5, Parent = titleBar,
})
local topLine = mk("Frame", {
    Size = UDim2.new(1, -52, 0, 1), Position = UDim2.new(0, 26, 0, 0),
    BackgroundColor3 = C.a1, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 5, Parent = titleBar,
})
grad(topLine, C.a1, C.a3, 0)

local brandBox = mk("Frame", {
    Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(0, 20, 0.5, -18),
    BackgroundColor3 = C.a1, BorderSizePixel = 0, ZIndex = 5, Parent = titleBar,
})
corner(brandBox, 12)
local brandGrad = mk("UIGradient", {Parent = brandBox})
brandGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.a1), ColorSequenceKeypoint.new(0.5, C.a2),
    ColorSequenceKeypoint.new(1.00, C.a3),
})
brandGrad.Rotation = 45
local brandGlow = mk("Frame", {
    Size = UDim2.new(1, 10, 1, 10), Position = UDim2.new(0, -5, 0, -5),
    BackgroundColor3 = C.a1, BackgroundTransparency = 0.7,
    BorderSizePixel = 0, ZIndex = 4, Parent = brandBox,
})
corner(brandGlow, 17)
task.spawn(function()
    while brandGlow.Parent do
        tween(brandGlow, 2.2, {BackgroundTransparency = 0.45}, Enum.EasingStyle.Sine); task.wait(2.2)
        tween(brandGlow, 2.2, {BackgroundTransparency = 0.8}, Enum.EasingStyle.Sine); task.wait(2.2)
    end
end)
mk("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = C.bg,
    Text = "M", ZIndex = 6, Parent = brandBox,
})
mk("TextLabel", {
    Size = UDim2.new(0, 200, 0, 18), Position = UDim2.new(0, 66, 0.5, -21),
    BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "MEREDIOS", ZIndex = 5, Parent = titleBar,
})
local verBadge = mk("Frame", {
    Size = UDim2.new(0, 34, 0, 13), Position = UDim2.new(0, 66 + 88, 0.5, -21),
    BackgroundColor3 = C.green, BackgroundTransparency = 0.75,
    BorderSizePixel = 0, ZIndex = 5, Parent = titleBar,
})
corner(verBadge, 6); stroke(verBadge, C.green, 1, 0.3)
mk("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = C.text,
    Text = VERSION, ZIndex = 6, Parent = verBadge,
})

local statusRow = mk("Frame", {
    Size = UDim2.new(0, 200, 0, 12), Position = UDim2.new(0, 66, 0.5, 2),
    BackgroundTransparency = 1, ZIndex = 5, Parent = titleBar,
})
local statusDot = mk("Frame", {
    Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 0, 0.5, -3),
    BackgroundColor3 = C.green, BorderSizePixel = 0, ZIndex = 6, Parent = statusRow,
})
corner(statusDot, 3)
local statusLbl = mk("TextLabel", {
    Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "active", ZIndex = 6, Parent = statusRow,
})
task.spawn(function()
    while statusDot.Parent do
        tween(statusDot, 1.3, {BackgroundTransparency = 0.1}, Enum.EasingStyle.Sine); task.wait(1.3)
        tween(statusDot, 1.3, {BackgroundTransparency = 0.7}, Enum.EasingStyle.Sine); task.wait(1.3)
    end
end)

local closeBtn = mk("TextButton", {
    Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -44, 0.5, -16),
    BackgroundColor3 = C.surface2, BackgroundTransparency = 0.2,
    BorderSizePixel = 0, Text = "X", Font = Enum.Font.GothamBold, TextSize = 12,
    TextColor3 = C.dim, AutoButtonColor = false, ZIndex = 5, Parent = titleBar,
})
corner(closeBtn, 11); stroke(closeBtn, C.line, 1, 0.55)
closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.18, {BackgroundColor3 = C.red, BackgroundTransparency = 0, TextColor3 = Color3.new(1,1,1)})
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.18, {BackgroundColor3 = C.surface2, BackgroundTransparency = 0.2, TextColor3 = C.dim})
end)

local sidebar = mk("Frame", {
    Size = UDim2.new(0, SIDEBAR_W, 1, -TITLE_H), Position = UDim2.new(0, 0, 0, TITLE_H),
    BackgroundColor3 = C.surface, BackgroundTransparency = 0.5,
    BorderSizePixel = 0, ZIndex = 4, Parent = main,
})
mk("Frame", {
    Size = UDim2.new(0, 1, 1, -20), Position = UDim2.new(1, -1, 0, 10),
    BackgroundColor3 = C.line, BackgroundTransparency = 0.5,
    BorderSizePixel = 0, ZIndex = 5, Parent = sidebar,
})

local content = mk("Frame", {
    Size = UDim2.new(1, -SIDEBAR_W, 1, -TITLE_H), Position = UDim2.new(0, SIDEBAR_W, 0, TITLE_H),
    BackgroundTransparency = 1, ZIndex = 4, Parent = main,
})

local PAGES, TAB_BTNS, currentTab = {}, {}, nil

local function makePage(id)
    local page = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.a1, ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 4, Visible = false, Parent = content,
    })
    PAGES[id] = page; return page
end
local function finalizePage(page, ch)
    page.CanvasSize = UDim2.new(0, 0, 0, math.max(ch, H - TITLE_H))
end
local function makeTabBtn(id, label, y)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, -12, 0, 30), Position = UDim2.new(0, 6, 0, y),
        BackgroundColor3 = C.surface2, BackgroundTransparency = 0.55,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        ZIndex = 5, Parent = sidebar,
    })
    corner(btn, 10)
    local indicator = mk("Frame", {
        Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = C.a1,
        BorderSizePixel = 0, ZIndex = 6, Parent = btn,
    })
    corner(indicator, 2); grad(indicator, C.a1, C.a3, 90)
    local lbl = mk("TextLabel", {
        Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
        Text = label, ZIndex = 6, Parent = btn,
    })
    TAB_BTNS[id] = {btn = btn, indicator = indicator, lbl = lbl}
    btn.MouseEnter:Connect(function()
        if currentTab ~= id then
            tween(btn, 0.15, {BackgroundTransparency = 0.35})
            tween(lbl, 0.15, {TextColor3 = C.text})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= id then
            tween(btn, 0.15, {BackgroundTransparency = 0.55})
            tween(lbl, 0.15, {TextColor3 = C.dim})
        end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(id) end)
end

function switchTab(id)
    if currentTab == id then return end
    currentTab = id
    for tid, pg in pairs(PAGES) do
        if tid == id then
            pg.Visible = true
            pg.Position = UDim2.new(0, 8, 0, 0)
            tween(pg, 0.24, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quint)
        else pg.Visible = false end
    end
    for tid, t in pairs(TAB_BTNS) do
        local on = (tid == id)
        tween(t.btn, 0.22, {
            BackgroundColor3 = on and C.a1 or C.surface2,
            BackgroundTransparency = on and 0.15 or 0.55,
        })
        tween(t.indicator, 0.22, {Size = on and UDim2.new(0, 3, 0, 18) or UDim2.new(0, 3, 0, 0)})
        tween(t.lbl, 0.22, {TextColor3 = on and C.text or C.dim})
    end
end

local function sectionHeader(parent, y, label, tint)
    tint = tint or C.a1
    local wrap = mk("Frame", {
        Size = UDim2.new(1, -28, 0, 14), Position = UDim2.new(0, 14, 0, y),
        BackgroundTransparency = 1, ZIndex = 5, Parent = parent,
    })
    mk("TextLabel", {
        Size = UDim2.new(0, 90, 1, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = C.dim,
        TextXAlignment = Enum.TextXAlignment.Left, Text = string.upper(label),
        ZIndex = 5, Parent = wrap,
    })
    local line = mk("Frame", {
        Size = UDim2.new(1, -80, 0, 1), Position = UDim2.new(0, 80, 0.5, 0),
        BackgroundColor3 = tint, BackgroundTransparency = 0.6,
        BorderSizePixel = 0, ZIndex = 5, Parent = wrap,
    })
    grad(line, tint, C.a2, 0)
end

local function attachShine(card)
    local shine = mk("Frame", {
        Size = UDim2.new(0, 70, 1, 0), Position = UDim2.new(0, -90, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.9,
        BorderSizePixel = 0, ZIndex = 7, Parent = card,
    })
    corner(shine, 14)
    card.MouseEnter:Connect(function()
        shine.Position = UDim2.new(0, -90, 0, 0)
        tween(shine, 0.6, {Position = UDim2.new(1, 25, 0, 0)}, Enum.EasingStyle.Quint)
    end)
end

local function toggleCard(parent, y, title, subtitle, tint, tint2, default, callback)
    local state = default and true or false
    local card = mk("Frame", {
        Size = UDim2.new(1, -28, 0, 54), Position = UDim2.new(0, 14, 0, y),
        BackgroundColor3 = C.surface, BackgroundTransparency = 0.15,
        BorderSizePixel = 0, ZIndex = 4, Parent = parent,
    })
    corner(card, 14); stroke(card, C.line, 1, 0.45)
    local tintF = mk("Frame", {
        Size = UDim2.new(0, 90, 1, 0), BackgroundColor3 = tint,
        BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = 4, Parent = card,
    })
    corner(tintF, 14); grad(tintF, tint, C.bg, 0)
    mk("Frame", {
        Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = C.text, BackgroundTransparency = 0.9,
        BorderSizePixel = 0, ZIndex = 5, Parent = card,
    })
    local acc = mk("Frame", {
        Size = UDim2.new(0, 3, 0, 32), Position = UDim2.new(0, 0, 0.5, -16),
        BackgroundColor3 = tint, BorderSizePixel = 0, ZIndex = 6, Parent = card,
    })
    corner(acc, 2); grad(acc, tint, tint2, 90)
    mk("TextLabel", {
        Size = UDim2.new(1, -80, 0, 16), Position = UDim2.new(0, 14, 0.5, -16),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = title, ZIndex = 5, Parent = card,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -80, 0, 12), Position = UDim2.new(0, 14, 0.5, 3),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
        Text = subtitle, ZIndex = 5, Parent = card,
    })
    local track = mk("Frame", {
        Size = UDim2.new(0, 42, 0, 24), Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = state and C.a1 or C.surface3,
        BorderSizePixel = 0, ZIndex = 6, Parent = card,
    })
    corner(track, 12); stroke(track, C.line, 1, 0.4)
    local knob = mk("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = C.text, BorderSizePixel = 0, ZIndex = 8, Parent = track,
    })
    corner(knob, 9)
    local knobGlow = mk("Frame", {
        Size = UDim2.new(1, 10, 1, 10), Position = UDim2.new(0, -5, 0, -5),
        BackgroundColor3 = C.a2, BackgroundTransparency = state and 0.4 or 1,
        BorderSizePixel = 0, ZIndex = 7, Parent = knob,
    })
    corner(knobGlow, 14)
    attachShine(card)
    local function set(v, fire)
        state = v
        track.BackgroundColor3 = state and C.a1 or C.surface3
        tween(knob, 0.24, {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }, Enum.EasingStyle.Back)
        tween(knobGlow, 0.24, {BackgroundTransparency = state and 0.4 or 1})
        if fire and callback then callback(state) end
    end
    local btn = mk("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "", ZIndex = 10, Parent = card,
    })
    btn.MouseEnter:Connect(function() tween(card, 0.15, {BackgroundTransparency = 0}) end)
    btn.MouseLeave:Connect(function() tween(card, 0.15, {BackgroundTransparency = 0.15}) end)
    btn.MouseButton1Click:Connect(function() set(not state, true) end)
    return set
end

local function actionCard(parent, y, title, subtitle, tint, tint2, cb)
    local card = mk("TextButton", {
        Size = UDim2.new(1, -28, 0, 50), Position = UDim2.new(0, 14, 0, y),
        BackgroundColor3 = C.surface, BackgroundTransparency = 0.15,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        ZIndex = 4, Parent = parent,
    })
    corner(card, 14); stroke(card, C.line, 1, 0.45)
    local tintF = mk("Frame", {
        Size = UDim2.new(0, 80, 1, 0), BackgroundColor3 = tint,
        BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = 4, Parent = card,
    })
    corner(tintF, 14); grad(tintF, tint, C.bg, 0)
    mk("Frame", {
        Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = C.text, BackgroundTransparency = 0.9,
        BorderSizePixel = 0, ZIndex = 5, Parent = card,
    })
    local acc = mk("Frame", {
        Size = UDim2.new(0, 3, 0, 28), Position = UDim2.new(0, 0, 0.5, -14),
        BackgroundColor3 = tint, BorderSizePixel = 0, ZIndex = 6, Parent = card,
    })
    corner(acc, 2); grad(acc, tint, tint2, 90)
    mk("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 14, 0.5, -14),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = title, ZIndex = 5, Parent = card,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -40, 0, 12), Position = UDim2.new(0, 14, 0.5, 3),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
        Text = subtitle, ZIndex = 5, Parent = card,
    })
    attachShine(card)
    card.MouseEnter:Connect(function()
        tween(card, 0.15, {BackgroundTransparency = 0})
        tween(acc, 0.15, {Size = UDim2.new(0, 3, 0, 38)})
    end)
    card.MouseLeave:Connect(function()
        tween(card, 0.15, {BackgroundTransparency = 0.15})
        tween(acc, 0.15, {Size = UDim2.new(0, 3, 0, 28)})
    end)
    card.MouseButton1Click:Connect(function()
        tween(card, 0.08, {BackgroundTransparency = 0})
        task.delay(0.15, function() tween(card, 0.2, {BackgroundTransparency = 0.15}) end)
        if cb then cb() end
    end)
end

local function sliderCard(parent, y, title, min, max, default, tint, cb)
    local value = default
    local card = mk("Frame", {
        Size = UDim2.new(1, -28, 0, 54), Position = UDim2.new(0, 14, 0, y),
        BackgroundColor3 = C.surface, BackgroundTransparency = 0.15,
        BorderSizePixel = 0, ZIndex = 4, Parent = parent,
    })
    corner(card, 14); stroke(card, C.line, 1, 0.45)
    mk("TextLabel", {
        Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = title, ZIndex = 5, Parent = card,
    })
    local valLbl = mk("TextLabel", {
        Size = UDim2.new(0, 50, 0, 16), Position = UDim2.new(1, -60, 0, 8),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = C.a2, TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(value), ZIndex = 5, Parent = card,
    })
    local track = mk("Frame", {
        Size = UDim2.new(1, -28, 0, 4), Position = UDim2.new(0, 14, 1, -16),
        BackgroundColor3 = C.surface3, BorderSizePixel = 0, ZIndex = 5, Parent = card,
    })
    corner(track, 2)
    local fill = mk("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = tint, BorderSizePixel = 0, ZIndex = 6, Parent = track,
    })
    corner(fill, 2); grad(fill, tint, C.a2, 0)
    local knob = mk("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = C.text, BorderSizePixel = 0, ZIndex = 7, Parent = track,
    })
    corner(knob, 6)
    local dragging = false
    local function upd(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        valLbl.Text = tostring(value)
        tween(fill, 0.1, {Size = UDim2.new(rel, 0, 1, 0)}, Enum.EasingStyle.Linear)
        tween(knob, 0.1, {Position = UDim2.new(rel, -6, 0.5, -6)}, Enum.EasingStyle.Linear)
        if cb then cb(value) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = true; upd(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local SESSION_CONNS = {}
local function track(c) table.insert(SESSION_CONNS, c); return c end

-- ============================================================
-- STATUS
-- ============================================================
local eggStats = { found=0, spawnable=0, farDist=0, phase="idle", hasEgg=false }
local statusLabelRef = nil
local function updateStatus()
    if statusLabelRef then
        statusLabelRef.Text = string.format(
            "%d eggs · %d free · far %d · %s",
            eggStats.found, eggStats.spawnable,
            math.floor(eggStats.farDist),
            eggStats.phase
        )
    end
end

-- ============================================================
-- SPEED BYPASS
-- ============================================================
local speedOn = false
local speedValue = 60
local speedSpoofValue = 16
local speedBody = nil
local moveConns = {}

local hasHook = type(hookmetamethod) == "function"
    and type(getrawmetatable) == "function"
    and type(newcclosure) == "function"

local hookedMT = false
local origIndex = nil
local hookedMeta = nil

local function installSpeedHook()
    if not hasHook then return false end
    if hookedMT then return true end
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return false end
        local old = mt.__index
        if not old then return false end
        origIndex = old

        mt.__index = newcclosure(function(self, key)
            local caller = checkcaller and checkcaller() or false
            if not caller and self and typeof(self) == "Instance" and self:IsA("Humanoid") then
                if key == "WalkSpeed" then
                    return speedSpoofValue
                elseif key == "JumpPower" then
                    return 50
                elseif key == "UseJumpPower" then
                    return true
                end
            end
            return old(self, key)
        end)
        hookedMT = true
        hookedMeta = mt
    end)
    return hookedMT
end

local function uninstallSpeedHook()
    if hookedMeta and origIndex then
        pcall(function() hookedMeta.__index = origIndex end)
        hookedMT = false
    end
end

installSpeedHook()

local function startSpeed()
    if not speedOn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 5000
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    speedBody = bv

    local conn = RunService.Heartbeat:Connect(function(dt)
        if not speedBody or not speedBody.Parent then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hu = c:FindFirstChildOfClass("Humanoid")
        if not h or not hu then return end

        local md = hu.MoveDirection
        if md.Magnitude > 0.1 then
            local wish = md * speedValue
            local cur = speedBody.Velocity
            local tgt = Vector3.new(wish.X, cur.Y, wish.Z)
            speedBody.Velocity = cur:Lerp(tgt, math.clamp(dt * 12, 0, 1))
        else
            speedBody.Velocity = Vector3.new(0, speedBody.Velocity.Y, 0)
        end
    end)
    table.insert(moveConns, conn)
end

local function stopSpeed()
    for _, c in ipairs(moveConns) do pcall(function() c:Disconnect() end) end
    moveConns = {}
    if speedBody then
        pcall(function() speedBody:Destroy() end)
        speedBody = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then pcall(function() hrp:SetNetworkOwner(nil) end) end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if speedOn then
        stopSpeed()
        task.wait(0.3)
        startSpeed()
    end
end)

-- ============================================================
-- STEALTH
-- ============================================================
local stealthOn = true
local paranoidOn = false

local pingHot = false
task.spawn(function()
    while screen.Parent do
        task.wait(2)
        local p = 0
        pcall(function() p = LocalPlayer:GetNetworkPing() end)
        pingHot = p > 0.32
        if pingHot then
            statusLbl.Text = "watch"
            statusDot.BackgroundColor3 = C.amber
        elseif speedOn then
            statusLbl.Text = "speed " .. speedValue
            statusDot.BackgroundColor3 = C.a2
        elseif stealthOn then
            statusLbl.Text = paranoidOn and "paranoid" or "stealth"
            statusDot.BackgroundColor3 = C.green
        else
            statusLbl.Text = "active"
            statusDot.BackgroundColor3 = C.green
        end
    end
end)

local lastPromptFire = 0
local promptHistory = {}
local PROMPT_COOLDOWN = 20
local fireCounter = 0
local fireWindowStart = tick()

local function canFirePrompt(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return false end
    local t = promptHistory[prompt]
    if t and (tick() - t) < PROMPT_COOLDOWN then return false end
    local now = tick()
    if now - fireWindowStart > 1 then
        fireWindowStart = now; fireCounter = 0
    end
    local cap = paranoidOn and 2 or 4
    if fireCounter >= cap then return false end
    return true
end
local function markPrompt(prompt)
    promptHistory[prompt] = tick()
    fireCounter = fireCounter + 1
end

local function humanJitterPath(hrp, targetVec)
    if not hrp or not hrp.Parent then return end
    local startVec = hrp.Position
    local total = (targetVec - startVec).Magnitude
    if total < 6 then
        pcall(function() hrp.CFrame = CFrame.new(targetVec) end)
        return
    end
    local hopMax = paranoidOn and 12 or (stealthOn and 22 or 500)
    local hops = math.clamp(math.ceil(total / hopMax), 1, 40)
    local stepVec = (targetVec - startVec) / hops

    for i = 1, hops do
        if not hrp or not hrp.Parent then return end
        local jx = (math.random() - 0.5) * 1.4
        local jy = (math.random() - 0.5) * 0.3
        local jz = (math.random() - 0.5) * 1.4
        local newPos = startVec + stepVec * i + Vector3.new(jx, jy, jz)
        local yaw = math.random() * math.pi * 2
        pcall(function()
            hrp.CFrame = CFrame.new(newPos) * CFrame.Angles(0, yaw, 0)
        end)
        local minW = paranoidOn and 0.09 or (stealthOn and 0.055 or 0)
        local maxW = paranoidOn and 0.18 or (stealthOn and 0.115 or 0.01)
        task.wait(minW + math.random() * (maxW - minW))
        if (stealthOn or paranoidOn) and pingHot then
            task.wait(0.4 + math.random() * 0.4)
        end
    end
end

local breakUntil = 0
task.spawn(function()
    while screen.Parent do
        task.wait(45 + math.random() * 25)
        if stealthOn and (collectFarOn or autoCollectOn) then
            breakUntil = tick() + 1 + math.random() * 1.5
        end
    end
end)
local function isOnBreak() return tick() < breakUntil end

local function shuffled(t)
    local out = {}
    for i = 1, #t do out[i] = t[i] end
    for i = #out, 2, -1 do
        local j = math.random(i)
        out[i], out[j] = out[j], out[i]
    end
    return out
end

-- ============================================================
-- EGG DETECTION
-- ============================================================
local function isOwnedEgg(inst)
    local a = inst
    for i = 1, 8 do
        a = a.Parent
        if not a then break end
        local an = a.Name:lower()
        for _, p in ipairs(Players:GetPlayers()) do
            local pn = p.Name:lower()
            if #pn >= 3 and an:find(pn, 1, true) then return true end
        end
        if an:find("base") or an:find("plot") or an:find("house")
        or an:find("inventory") or an:find("owned") or an:find("storage")
        or an:find("collection") or an:find("collected")
        or an:find("display") or an:find("showcase") or an:find("placed") then
            return true
        end
    end
    local owned = false
    pcall(function()
        if inst:GetAttribute("Owner") ~= nil then owned = true end
        if inst:GetAttribute("Player") ~= nil then owned = true end
        if inst:GetAttribute("Collected") == true then owned = true end
        if inst:GetAttribute("Owned") == true then owned = true end
        if inst:GetAttribute("UserId") ~= nil then owned = true end
    end)
    if owned then return true end
    local par2 = inst.Parent
    for i = 1, 4 do
        if not par2 then break end
        if par2:IsA("Backpack") or par2:IsA("Tool")
        or par2:IsA("Accessory") or par2:IsA("Humanoid") then
            return true
        end
        par2 = par2.Parent
    end
    return false
end

local EGG_NAMES_EXTRA = {
    "cracked","rainbow","golden","diamond","galaxy","lava",
    "frozen","crystal","shiny","mystic","star","candy",
    "cyber","neon","shadow","toxic","flame","ice",
}

local function isEggCandidate(inst)
    if not inst:IsA("Model") then return false end
    local low = inst.Name:lower()
    if low:find("shop") or low:find("ui") or low:find("display")
    or low:find("stand") or low:find("pedestal") or low:find("template")
    or low:find("preview") or low:find("icon") then
        return false
    end
    local matches = low:find("egg") ~= nil
    if not matches then
        for _, word in ipairs(EGG_NAMES_EXTRA) do
            if low:find(word, 1, true) then matches = true; break end
        end
    end
    if not matches then return false end
    if not inst:FindFirstChildWhichIsA("BasePart") then return false end
    if isOwnedEgg(inst) then return false end
    return true
end

-- ============================================================
-- FLING / AIMBOT / HITBOX / ESP
-- ============================================================
local flingOn = false
local function startFling()
    flingOn = true
    task.spawn(function()
        while flingOn do
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    pcall(function() hrp:SetNetworkOwner(nil) end)
                    pcall(function()
                        hrp.CustomPhysicalProperties = PhysicalProperties.new(200, 0.3, 0, 1, 1)
                    end)
                    local myPos = hrp.Position
                    local closest, closestDist = nil, 60
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local theirHRP = p.Character:FindFirstChild("HumanoidRootPart")
                            if theirHRP then
                                local d = (theirHRP.Position - myPos).Magnitude
                                if d < closestDist then closestDist = d; closest = theirHRP end
                            end
                        end
                    end
                    local dir = closest and (closest.Position - myPos).Unit or Vector3.new(0, 1, 0)
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = dir * 1500 + Vector3.new(0, 80, 0)
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.P = 4000; bv.Parent = hrp
                    local bav = Instance.new("BodyAngularVelocity")
                    bav.AngularVelocity = Vector3.new(2e4, 2e4, 2e4)
                    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bav.P = 4000; bav.Parent = hrp
                    task.delay(0.08, function()
                        pcall(function() bv:Destroy() end)
                        pcall(function() bav:Destroy() end)
                        pcall(function() hrp.CustomPhysicalProperties = nil end)
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
end
local function stopFling()
    flingOn = false
    local char = LocalPlayer.Character
    if char then
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BodyVelocity") or d:IsA("BodyAngularVelocity") then
                if (d.MaxForce and d.MaxForce.X == math.huge)
                or (d.MaxTorque and d.MaxTorque.X == math.huge) then
                    pcall(function() d:Destroy() end)
                end
            end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then pcall(function() hrp.CustomPhysicalProperties = nil end) end
    end
end

local aimbotOn = false
local aimbotStrength = 25
track(RunService.RenderStepped:Connect(function(dt)
    if not aimbotOn then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local closest, closestMag = nil, 600
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local sp, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < closestMag then closestMag = d; closest = head end
                end
            end
        end
    end
    if closest then
        local alpha = math.clamp(aimbotStrength / 25 * dt * 60, 0, 1)
        local target = CFrame.new(cam.CFrame.Position, closest.Position)
        cam.CFrame = cam.CFrame:Lerp(target, alpha)
    end
end))

local hitboxOn = false
local hitboxSize = 8
local origHRP = {}
local function applyHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hitboxOn then
                    if not origHRP[p] then
                        origHRP[p] = {size = hrp.Size, transparency = hrp.Transparency, massless = hrp.Massless}
                    end
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = 0.7; hrp.Massless = true
                else
                    local o = origHRP[p]
                    if o then
                        pcall(function()
                            hrp.Size = o.size; hrp.Transparency = o.transparency; hrp.Massless = o.massless
                        end)
                        origHRP[p] = nil
                    end
                end
            end
        end
    end
end

local espOn = false
local function applyESPForCharacter(char)
    if not char then return end
    local existing = char:FindFirstChild("MerediosESP")
    if espOn and not existing then
        local hl = Instance.new("Highlight")
        hl.Name = "MerediosESP"
        hl.FillColor = C.a3; hl.FillTransparency = 0.65
        hl.OutlineColor = C.a1; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    elseif not espOn and existing then existing:Destroy() end
end
local function applyESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then applyESPForCharacter(p.Character) end
    end
end
local function hookPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(0.4)
        applyESPForCharacter(char)
        if hitboxOn then applyHitbox() end
    end)
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
track(Players.PlayerAdded:Connect(hookPlayer))

-- ============================================================
-- EGG SYSTEMS
-- ============================================================
local eggESPOn = false
local function applyEggESP()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local existing = v:FindFirstChild("_HL")
            if eggESPOn and isEggCandidate(v) and not existing then
                local hl = Instance.new("Highlight")
                hl.Name = "_HL"
                hl.FillColor = C.amber; hl.FillTransparency = 0.6
                hl.OutlineColor = C.amber; hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = v
            elseif (not eggESPOn or not isEggCandidate(v)) and existing then
                existing:Destroy()
            end
        end
    end
end

local promptCache = {}
local function refreshPromptCache()
    promptCache = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            table.insert(promptCache, v)
        end
    end
end
track(Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then
        table.insert(promptCache, v)
    end
end))
task.spawn(function()
    refreshPromptCache()
    while screen.Parent do
        task.wait(4)
        if #promptCache > 500 then refreshPromptCache() end
    end
end)

local function firePromptRaw(prompt)
    if not canFirePrompt(prompt) then return false end
    if stealthOn then
        task.wait(0.04 + math.random() * 0.08)
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0)
            prompt:InputHoldEnd()
        end)
    end
    markPrompt(prompt)
    if stealthOn then
        task.wait(0.02 + math.random() * 0.05)
    end
    return true
end

local function hasEggInHands()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then
            local n = c.Name:lower()
            if n:find("egg") then return true end
        end
        if c:IsA("Model") then
            local n = c.Name:lower()
            if n:find("egg") then return true end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            if c:IsA("Tool") and c.Name:lower():find("egg") then return true end
        end
    end
    return false
end

local function findPlacementPrompt()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myPos = hrp.Position
    for _, v in ipairs(promptCache) do
        if v and v.Parent and v.Enabled then
            local at = v.ActionText:lower()
            if at:find("place") or at:find("put") or at:find("drop")
            or at:find("deposit") or at:find("store") or at:find("submit")
            or at:find("sell") then
                local parent = v.Parent
                local pos
                if parent:IsA("BasePart") then pos = parent.Position
                elseif parent:IsA("Model") then
                    local bp = parent:FindFirstChildWhichIsA("BasePart")
                    if bp then pos = bp.Position end
                end
                if pos and (pos - myPos).Magnitude < 30 then
                    return v, pos
                end
            end
        end
    end
    return nil
end

local function findMyBase()
    local myNameLower = LocalPlayer.Name:lower()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find(myNameLower) then
                return v.Position
            end
        end
    end
    local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then return sp.Position end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("SpawnLocation") then return v.Position end
    end
    return nil
end

local function tryCollect(model)
    if not model or not model.Parent then return false end
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        local par = model.Parent
        for i = 1, 2 do
            if not par then break end
            prompt = par:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then break end
            par = par.Parent
        end
    end
    if prompt and prompt.Enabled then
        return firePromptRaw(prompt)
    end
    if firetouchinterest then
        local char = LocalPlayer.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        if myHRP then
            local eggPart = model:FindFirstChildWhichIsA("BasePart")
            if eggPart then
                pcall(function()
                    firetouchinterest(myHRP, eggPart, 0)
                    task.wait(0.03)
                    firetouchinterest(myHRP, eggPart, 1)
                end)
                return true
            end
        end
    end
    return false
end

local function collectAllNearby(myPos)
    if isOnBreak() then return end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and isEggCandidate(v) then
            local bp = v:FindFirstChildWhichIsA("BasePart")
            if bp and (bp.Position - myPos).Magnitude < 20 then
                tryCollect(v)
            end
        end
    end
end

-- ============================================================
-- FAR EGG FARM — locked target
-- ============================================================
local collectFarOn = false
local farmTarget = nil
local farmTargetPos = nil
local farmTargetTries = 0
local farmPhase = "idle"

local function pickFarthestEgg(myPos)
    local best, bestPos, bestDist = nil, nil, 0
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and isEggCandidate(v) then
            local bp = v:FindFirstChildWhichIsA("BasePart")
            if bp then
                local d = (bp.Position - myPos).Magnitude
                if d > bestDist then
                    bestDist = d
                    best = v
                    bestPos = bp.Position
                end
            end
        end
    end
    return best, bestPos, bestDist
end

local function targetStillValid()
    if not farmTarget or not farmTarget.Parent then return false end
    if isOwnedEgg(farmTarget) then return false end
    if not farmTarget:FindFirstChildWhichIsA("BasePart") then return false end
    return true
end

local function startCollectFar()
    collectFarOn = true
    farmPhase = "scan"
    farmTarget = nil
    farmTargetPos = nil
    farmTargetTries = 0
    task.spawn(function()
        while collectFarOn do
            if isOnBreak() then
                eggStats.phase = "break"
                updateStatus()
                task.wait(0.5)
            else
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local myPos = hrp.Position
                    eggStats.hasEgg = hasEggInHands()

                    if eggStats.hasEgg then
                        farmPhase = "go_base"
                        eggStats.phase = "go_base"
                        updateStatus()

                        local basePos = findMyBase()
                        if basePos then
                            local safety = 0
                            while collectFarOn and (basePos - hrp.Position).Magnitude > 12 and safety < 60 do
                                humanJitterPath(hrp, basePos + Vector3.new(0, 3, 0))
                                task.wait(0.1)
                                safety = safety + 1
                            end

                            task.wait(0.2)
                            local placePrompt, ppPos = findPlacementPrompt()
                            if placePrompt and ppPos then
                                local newHRP = char:FindFirstChild("HumanoidRootPart")
                                if newHRP then
                                    local safety2 = 0
                                    while collectFarOn and (ppPos - newHRP.Position).Magnitude > 8 and safety2 < 30 do
                                        humanJitterPath(newHRP, ppPos + Vector3.new(0, 3, 0))
                                        task.wait(0.1)
                                        newHRP = char:FindFirstChild("HumanoidRootPart")
                                        if not newHRP then break end
                                        safety2 = safety2 + 1
                                    end
                                    firePromptRaw(placePrompt)
                                    task.wait(0.7)
                                end
                            else
                                eggStats.phase = "wait_place"
                                updateStatus()
                                task.wait(0.4)
                            end
                        else
                            eggStats.phase = "no_base"
                            updateStatus()
                            task.wait(0.5)
                        end
                        farmTarget = nil
                        farmTargetPos = nil
                        farmTargetTries = 0
                        farmPhase = "scan"
                    else
                        if not targetStillValid() then
                            farmTarget = nil
                            farmTargetPos = nil
                            farmTargetTries = 0
                            farmPhase = "scan"
                            eggStats.phase = "scan"
                            updateStatus()

                            local t, tPos, tDist = pickFarthestEgg(myPos)
                            if t then
                                farmTarget = t
                                farmTargetPos = tPos
                                eggStats.farDist = tDist
                                farmPhase = "go_far"
                            else
                                eggStats.phase = "no_eggs"
                                eggStats.farDist = 0
                                updateStatus()
                                task.wait(1)
                            end
                        end

                        if farmTarget and farmTargetPos then
                            local bp = farmTarget:FindFirstChildWhichIsA("BasePart")
                            if bp then
                                farmTargetPos = bp.Position
                                local distToTarget = (farmTargetPos - hrp.Position).Magnitude
                                eggStats.farDist = distToTarget

                                if distToTarget > 8 then
                                    eggStats.phase = "go_far " .. math.floor(distToTarget)
                                    updateStatus()

                                    local startVec = hrp.Position
                                    local hopMax = paranoidOn and 12 or (stealthOn and 22 or 200)
                                    local hop = math.min(hopMax, distToTarget)
                                    local stepVec = (farmTargetPos - startVec).Unit * hop
                                    local newPos = startVec + stepVec
                                    local jx = (math.random() - 0.5) * 1.2
                                    local jy = (math.random() - 0.5) * 0.3
                                    local jz = (math.random() - 0.5) * 1.2
                                    local yaw = math.random() * math.pi * 2
                                    pcall(function()
                                        hrp.CFrame = CFrame.new(newPos + Vector3.new(jx, jy, jz)) * CFrame.Angles(0, yaw, 0)
                                    end)

                                    if stealthOn then
                                        task.wait(0.04 + math.random() * 0.06)
                                    end
                                else
                                    eggStats.phase = "collect"
                                    updateStatus()

                                    local ok = tryCollect(farmTarget)
                                    farmTargetTries = farmTargetTries + 1

                                    if ok and farmTargetTries >= 2 then
                                        task.wait(0.25)
                                        if hasEggInHands() then
                                            farmTarget = nil
                                            farmTargetPos = nil
                                            farmTargetTries = 0
                                            farmPhase = "go_base"
                                        end
                                    end

                                    if farmTargetTries >= 6 then
                                        farmTarget = nil
                                        farmTargetPos = nil
                                        farmTargetTries = 0
                                    end

                                    task.wait(stealthOn and (0.25 + math.random() * 0.15) or 0.2)
                                end
                            else
                                farmTarget = nil
                                farmTargetPos = nil
                                farmTargetTries = 0
                            end
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopCollectFar()
    collectFarOn = false
    farmTarget = nil
    farmTargetPos = nil
    farmTargetTries = 0
    farmPhase = "idle"
    eggStats.phase = "idle"
    updateStatus()
end

local autoCollectOn = false
local function startAutoCollect()
    autoCollectOn = true
    task.spawn(function()
        while autoCollectOn do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then collectAllNearby(hrp.Position) end
            task.wait(stealthOn and (0.3 + math.random() * 0.1) or 0.25)
        end
    end)
end
local function stopAutoCollect() autoCollectOn = false end

local function tpToNearestEgg()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    local closest, closestDist = nil, 1e6
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and isEggCandidate(v) then
            local bp = v:FindFirstChildWhichIsA("BasePart")
            if bp then
                local d = (bp.Position - myPos).Magnitude
                if d < closestDist then closestDist = d; closest = bp.Position end
            end
        end
    end
    if closest then humanJitterPath(hrp, closest + Vector3.new(0, 4, 0)) end
end

local function tpToBase()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local basePos = findMyBase()
    if basePos then humanJitterPath(hrp, basePos + Vector3.new(0, 5, 0)) end
end

-- ============================================================
-- REJOIN / KILL
-- ============================================================
local function rejoin()
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not ok then
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
end

local function killGUI()
    pcall(stopFling); pcall(stopAutoCollect); pcall(stopCollectFar); pcall(stopSpeed)
    aimbotOn, espOn, hitboxOn, eggESPOn = false, false, false, false
    uninstallSpeedHook()
    for _, c in ipairs(SESSION_CONNS) do pcall(function() c:Disconnect() end) end
    SESSION_CONNS = {}
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("MerediosESP")
                if hl then hl:Destroy() end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local o = origHRP[p]
                    if o then hrp.Size = o.size; hrp.Transparency = o.transparency; hrp.Massless = o.massless end
                end
            end
        end
        origHRP = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            local hl = v:FindFirstChild("_HL")
            if hl then hl:Destroy() end
        end
    end)
    pcall(function() screen:Destroy() end)
end

-- ============================================================
-- BUILD PAGES
-- ============================================================
local pgHome   = makePage("home")
local pgCombat = makePage("combat")
local pgVisual = makePage("visual")
local pgEggs   = makePage("eggs")

sectionHeader(pgHome, 10, "menu", C.a1)
actionCard(pgHome, 32, "Rejoin", "переподключиться к серверу", C.a2, C.a4, rejoin)
actionCard(pgHome, 88, "Kill GUI", "убрать интерфейс полностью", C.red, C.red2, killGUI)
finalizePage(pgHome, 154)

sectionHeader(pgCombat, 10, "combat", C.a3)
toggleCard(pgCombat, 32, "Fling", "мягкий толчок игроков", C.a1, C.a2, false, function(v)
    if v then startFling() else stopFling() end
end)
toggleCard(pgCombat, 92, "Aimbot", "плавное наведение камеры", C.a2, C.a4, false, function(v) aimbotOn = v end)
sliderCard(pgCombat, 152, "Aim Strength", 5, 50, 25, C.a2, function(v) aimbotStrength = v end)
toggleCard(pgCombat, 212, "Hitbox Expand", "увеличивает хитбокс игроков", C.a3, C.a1, false, function(v)
    hitboxOn = v; applyHitbox()
end)
sliderCard(pgCombat, 272, "Hitbox Size", 3, 20, 8, C.a3, function(v)
    hitboxSize = v; if hitboxOn then applyHitbox() end
end)
finalizePage(pgCombat, 342)

sectionHeader(pgVisual, 10, "visual", C.a2)
toggleCard(pgVisual, 32, "Player ESP", "подсветка игроков сквозь стены", C.a1, C.a3, false, function(v)
    espOn = v; applyESP()
end)
finalizePage(pgVisual, 102)

sectionHeader(pgEggs, 10, "steal an egg", C.amber)
toggleCard(pgEggs, 32, "Stealth Mode", "обход анти-чита", C.green, C.a4, true, function(v) stealthOn = v end)
toggleCard(pgEggs, 92, "Speed Boost", "ускорение с обходом", C.green, C.a2, false, function(v)
    speedOn = v
    if v then startSpeed() else stopSpeed() end
end)
sliderCard(pgEggs, 152, "Speed Value", 20, 200, 60, C.a2, function(v)
    speedValue = v
end)
toggleCard(pgEggs, 212, "Paranoid Mode", "максимальная осторожность", C.amber, C.red, false, function(v)
    paranoidOn = v
    if v then stealthOn = true end
end)
toggleCard(pgEggs, 272, "Egg ESP", "подсвечивает свободные яйца", C.amber, C.a3, false, function(v)
    eggESPOn = v; applyEggESP()
end)
toggleCard(pgEggs, 332, "Auto Collect", "собирает яйца рядом", C.a2, C.a4, false, function(v)
    if v then startAutoCollect() else stopAutoCollect() end
end)
toggleCard(pgEggs, 392, "Farm Loop", "дальнее яйцо → собрать → база", C.amber, C.a1, false, function(v)
    if v then startCollectFar() else stopCollectFar() end
end)
actionCard(pgEggs, 452, "TP to Egg", "телепорт к ближайшему свободному яйцу", C.amber, C.a3, tpToNearestEgg)
actionCard(pgEggs, 508, "TP to Base", "телепорт на свою базу", C.a2, C.a4, tpToBase)

local statusCard = mk("Frame", {
    Size = UDim2.new(1, -28, 0, 26), Position = UDim2.new(0, 14, 0, 564),
    BackgroundColor3 = C.surface, BackgroundTransparency = 0.4,
    BorderSizePixel = 0, ZIndex = 4, Parent = pgEggs,
})
corner(statusCard, 10); stroke(statusCard, C.line, 1, 0.5)
statusLabelRef = mk("TextLabel", {
    Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 10,
    TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left,
    Text = "0 eggs · 0 free · far 0 · idle", ZIndex = 5, Parent = statusCard,
})
finalizePage(pgEggs, 614)

task.spawn(function()
    while screen.Parent do
        task.wait(0.5)
        if not collectFarOn then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local total, free = 0, 0
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") then
                        local low = v.Name:lower()
                        local looksEgg = low:find("egg") ~= nil
                        if not looksEgg then
                            for _, word in ipairs(EGG_NAMES_EXTRA) do
                                if low:find(word, 1, true) then looksEgg = true; break end
                            end
                        end
                        if looksEgg and v:FindFirstChildWhichIsA("BasePart") then
                            total = total + 1
                            if not isOwnedEgg(v) then free = free + 1 end
                        end
                    end
                end
                eggStats.found = total
                eggStats.spawnable = free
            end
        end
        updateStatus()
    end
end)

makeTabBtn("home", "HOME", 8)
makeTabBtn("combat", "COMBAT", 44)
makeTabBtn("visual", "VISUAL", 80)
makeTabBtn("eggs", "EGGS", 116)

do
    local dragging = false
    local dragStart, startPos
    track(titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        ring.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset - 3, main.Position.Y.Scale, main.Position.Y.Offset - 3)
        glow2.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset - 16, main.Position.Y.Scale, main.Position.Y.Offset - 16)
        glow3.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset - 28, main.Position.Y.Scale, main.Position.Y.Offset - 28)
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

local MS = 58
local mBtn = mk("TextButton", {
    Name = "MToggle", Size = UDim2.new(0, MS, 0, MS),
    Position = UDim2.new(0, 20, 0.5, -MS/2),
    BackgroundColor3 = C.a1, BorderSizePixel = 0, Text = "M",
    Font = Enum.Font.GothamBold, TextSize = 23, TextColor3 = C.text,
    AutoButtonColor = false, ZIndex = 60, Parent = screen,
})
corner(mBtn, MS / 2)
local mGrad = mk("UIGradient", {Parent = mBtn})
mGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.a1), ColorSequenceKeypoint.new(0.5, C.a2),
    ColorSequenceKeypoint.new(1.00, C.a3),
})
local mRing = mk("Frame", {
    Size = UDim2.new(1, 16, 1, 16), Position = UDim2.new(0, -8, 0, -8),
    BackgroundColor3 = C.a1, BackgroundTransparency = 0.55,
    BorderSizePixel = 0, ZIndex = 59, Parent = mBtn,
})
corner(mRing, (MS + 16) / 2)
local mRingGrad = mk("UIGradient", {Parent = mRing})
mRingGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, C.a1), ColorSequenceKeypoint.new(0.5, C.a2),
    ColorSequenceKeypoint.new(1.00, C.a3),
})
local mInner = mk("Frame", {
    Size = UDim2.new(1, -18, 1, -18), Position = UDim2.new(0, 9, 0, 9),
    BackgroundColor3 = C.bg, BackgroundTransparency = 0.6,
    BorderSizePixel = 0, ZIndex = 61, Parent = mBtn,
})
corner(mInner, (MS - 18) / 2)
task.spawn(function()
    while mBtn.Parent do
        tween(mGrad, 5, {Rotation = mGrad.Rotation + 360}, Enum.EasingStyle.Linear)
        tween(mRingGrad, 5, {Rotation = mRingGrad.Rotation + 360}, Enum.EasingStyle.Linear)
        task.wait(5)
    end
end)
task.spawn(function()
    while mRing.Parent do
        tween(mRing, 1.6, {BackgroundTransparency = 0.4}, Enum.EasingStyle.Sine); task.wait(1.6)
        tween(mRing, 1.6, {BackgroundTransparency = 0.72}, Enum.EasingStyle.Sine); task.wait(1.6)
    end
end)
mBtn.MouseEnter:Connect(function() tween(mBtn, 0.22, {Size = UDim2.new(0, MS + 6, 0, MS + 6)}, Enum.EasingStyle.Quint) end)
mBtn.MouseLeave:Connect(function() tween(mBtn, 0.22, {Size = UDim2.new(0, MS, 0, MS)}, Enum.EasingStyle.Quint) end)

local isOpen = true
local OPEN_TIME = 0.32
local VISIBLE_PARTS = {main, ring, glow2, glow3}
local function setAllVisible(v) for _, o in ipairs(VISIBLE_PARTS) do o.Visible = v end end

local function closeUI()
    if not isOpen then return end
    isOpen = false
    local tws = {
        TweenService:Create(main, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}),
        TweenService:Create(mainScale, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {Scale = 0.86}),
        TweenService:Create(ring, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}),
        TweenService:Create(glow2, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}),
        TweenService:Create(glow3, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}),
    }
    for _, tw in ipairs(tws) do tw:Play() end
    task.delay(OPEN_TIME + 0.02, function()
        if not screen.Parent then return end
        setAllVisible(false)
        main.BackgroundTransparency = 0
        mainScale.Scale = 0.86
        ring.BackgroundTransparency = 0
        glow2.BackgroundTransparency = 0.9
        glow3.BackgroundTransparency = 0.94
    end)
end
local function openUI()
    if isOpen then return end
    isOpen = true
    setAllVisible(true)
    main.BackgroundTransparency = 1; mainScale.Scale = 0.86
    ring.BackgroundTransparency = 1
    glow2.BackgroundTransparency = 1; glow3.BackgroundTransparency = 1
    local tws = {
        TweenService:Create(main, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}),
        TweenService:Create(mainScale, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}),
        TweenService:Create(ring, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}),
        TweenService:Create(glow2, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.9}),
        TweenService:Create(glow3, TweenInfo.new(OPEN_TIME, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.94}),
    }
    for _, tw in ipairs(tws) do tw:Play() end
end
closeBtn.MouseButton1Click:Connect(closeUI)

do
    local dragging, moved = false, false
    local start, startPos
    mBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            start = input.Position; startPos = mBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - start
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
        if moved then
            mBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    mBtn.MouseButton1Click:Connect(function()
        if moved then return end
        if isOpen then closeUI() else openUI() end
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.M then
        if isOpen then closeUI() else openUI() end
    end
end)

switchTab("home")
