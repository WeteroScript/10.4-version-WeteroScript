--[[
    WeteroScript v11.02 FINAL FIXED v8
    Author: @WeteroScript
]]

-- ==================== SERVICES ====================
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

-- ==================== CLEANUP ====================
pcall(function()
    for _, name in ipairs({"WeteroScript", "WeteroButton", "AdGui", "BotEditorGui", "ColorPickerGui", "MimicMenuGui", "MimicMenuBtn", "FlyGui", "BotButtonGui", "FlyControlGui"}) do
        local inst = CoreGui:FindFirstChild(name)
        if inst then inst:Destroy() end
    end
end)

if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
    Player.CharacterAdded:Wait()
end
repeat task.wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

-- ==================== UTILITY FUNCTIONS ====================
local dragConnections = {}

local function makeDraggable(frame, dragElement)
    local dragging, dragStart, startPos = false, nil, nil
    local conns = {}
    conns[1] = dragElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    conns[2] = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    conns[3] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    table.insert(dragConnections, conns)
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius); c.Parent = parent; return c
end

local function addStroke(parent, thickness, color)
    local s = Instance.new("UIStroke"); s.Thickness = thickness; s.Color = color or Color3.new(1, 1, 1); s.Parent = parent; return s
end

local rainbowStrokes = {}
local function addRainbowStroke(parent, thickness)
    local s = Instance.new("UIStroke"); s.Thickness = thickness; s.Color = Color3.new(1, 1, 1); s.Parent = parent
    table.insert(rainbowStrokes, s); return s
end

RunService.RenderStepped:Connect(function(dt)
    local hue = (tick() * 0.5) % 1
    for i, s in pairs(rainbowStrokes) do if s and s.Parent then s.Color = Color3.fromHSV(hue, 1, 0.8) else rainbowStrokes[i] = nil end end
end)

-- ==================== AD GUI ====================
local AdGui = Instance.new("ScreenGui"); AdGui.Name = "AdGui"; AdGui.Parent = CoreGui; AdGui.ResetOnSpawn = false
local AdFrame = Instance.new("Frame"); AdFrame.Size = UDim2.new(0, 300, 0, 120); AdFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
AdFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); AdFrame.BorderSizePixel = 0; AdFrame.Parent = AdGui; addCorner(AdFrame, 8)
local AdTitle = Instance.new("TextLabel"); AdTitle.Size = UDim2.new(1, 0, 0, 25); AdTitle.Position = UDim2.new(0, 0, 0, 10)
AdTitle.BackgroundTransparency = 1; AdTitle.Text = "WeteroScript v11.02"; AdTitle.TextColor3 = Color3.new(1, 1, 1)
AdTitle.Font = Enum.Font.GothamBold; AdTitle.TextSize = 18; AdTitle.Parent = AdFrame
local AdTG = Instance.new("TextLabel"); AdTG.Size = UDim2.new(1, 0, 0, 20); AdTG.Position = UDim2.new(0, 0, 0, 40)
AdTG.BackgroundTransparency = 1; AdTG.Text = "t.me/WeteroScript"; AdTG.TextColor3 = Color3.fromRGB(100, 180, 255)
AdTG.Font = Enum.Font.Gotham; AdTG.TextSize = 14; AdTG.Parent = AdFrame
local AdClose = Instance.new("TextButton"); AdClose.Size = UDim2.new(0, 100, 0, 30); AdClose.Position = UDim2.new(0.5, -50, 0, 70)
AdClose.BackgroundColor3 = Color3.fromRGB(50, 50, 50); AdClose.Text = "Close (2.5s)"; AdClose.TextColor3 = Color3.new(1, 1, 1)
AdClose.Font = Enum.Font.Gotham; AdClose.TextSize = 13; AdClose.BorderSizePixel = 0; AdClose.Visible = false; AdClose.Parent = AdFrame; addCorner(AdClose, 4)

-- ==================== EXTERNAL BUTTON ====================
local ExtGui = Instance.new("ScreenGui"); ExtGui.Name = "WeteroButton"; ExtGui.Parent = CoreGui; ExtGui.ResetOnSpawn = false
local BtnContainer = Instance.new("Frame"); BtnContainer.Size = UDim2.new(0, 160, 0, 40); BtnContainer.Position = UDim2.new(0.5, -80, 0.85, 0)
BtnContainer.BackgroundTransparency = 1; BtnContainer.Parent = ExtGui
local extBorders = {}
for _, data in ipairs({{UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0)}, {UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 1, -2)}, {UDim2.new(0, 2, 1, 0), UDim2.new(0, 0, 0, 0)}, {UDim2.new(0, 2, 1, 0), UDim2.new(1, -2, 0, 0)}}) do
    local b = Instance.new("Frame"); b.Size = data[1]; b.Position = data[2]; b.BackgroundColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0; b.Parent = BtnContainer; table.insert(extBorders, b)
end
local WhiteBtn = Instance.new("TextButton"); WhiteBtn.Size = UDim2.new(1, -4, 1, -4); WhiteBtn.Position = UDim2.new(0, 2, 0, 2)
WhiteBtn.BackgroundColor3 = Color3.new(1, 1, 1); WhiteBtn.Text = "WeteroScript"; WhiteBtn.TextColor3 = Color3.new(0, 0, 0)
WhiteBtn.Font = Enum.Font.GothamBold; WhiteBtn.TextSize = 15; WhiteBtn.BorderSizePixel = 0; WhiteBtn.AutoButtonColor = false; WhiteBtn.Parent = BtnContainer
BtnContainer.Visible = false
AdClose.Activated:Connect(function() AdGui:Destroy(); BtnContainer.Visible = true end)
task.delay(2.5, function() if AdClose and AdClose.Parent then AdClose.Visible = true; AdClose.Text = "Close" end end)
makeDraggable(BtnContainer, WhiteBtn)

-- ==================== MAIN GUI WINDOW ====================
local Gui = Instance.new("ScreenGui"); Gui.Name = "WeteroScript"; Gui.Parent = CoreGui; Gui.ResetOnSpawn = false
local Window = Instance.new("Frame"); Window.Size = UDim2.new(0, 520, 0, 420); Window.Position = UDim2.new(0.5, -260, 0.5, -210)
Window.BackgroundColor3 = Color3.fromRGB(12, 12, 18); Window.BorderSizePixel = 0; Window.Visible = false; Window.Parent = Gui; addCorner(Window, 10)
local WindowStroke = addStroke(Window, 2, Color3.new(1, 1, 1))
local TopBar = Instance.new("Frame"); TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TopBar.BorderSizePixel = 0; TopBar.Active = true; TopBar.Parent = Window; addCorner(TopBar, 10)
local TopBarCover = Instance.new("Frame"); TopBarCover.Size = UDim2.new(1, 0, 0.5, 0); TopBarCover.Position = UDim2.new(0, 0, 0.5, 0)
TopBarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 26); TopBarCover.BorderSizePixel = 0; TopBarCover.Parent = TopBar
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1; Title.Text = "⚡ WeteroScript v11.02"; Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TopBar
local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TopBar; addCorner(CloseBtn, 6)
makeDraggable(Window, TopBar)

-- ==================== SCROLLABLE TAB SYSTEM ====================
local TabContainer = Instance.new("Frame"); TabContainer.Size = UDim2.new(1, -40, 0, 36); TabContainer.Position = UDim2.new(0, 20, 0, 36)
TabContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 22); TabContainer.BorderSizePixel = 0; TabContainer.ClipsDescendants = true; TabContainer.Parent = Window
local TabScrollFrame = Instance.new("Frame"); TabScrollFrame.Size = UDim2.new(0, 0, 1, 0); TabScrollFrame.BackgroundTransparency = 1; TabScrollFrame.Parent = TabContainer
local ScrollLeftBtn = Instance.new("TextButton"); ScrollLeftBtn.Size = UDim2.new(0, 18, 0, 30); ScrollLeftBtn.Position = UDim2.new(0, 0, 0, 3)
ScrollLeftBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38); ScrollLeftBtn.Text = "◀"; ScrollLeftBtn.TextColor3 = Color3.new(1, 1, 1)
ScrollLeftBtn.Font = Enum.Font.GothamBold; ScrollLeftBtn.TextSize = 10; ScrollLeftBtn.BorderSizePixel = 0; ScrollLeftBtn.Parent = Window; addCorner(ScrollLeftBtn, 4)
local ScrollRightBtn = Instance.new("TextButton"); ScrollRightBtn.Size = UDim2.new(0, 18, 0, 30); ScrollRightBtn.Position = UDim2.new(1, -18, 0, 3)
ScrollRightBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38); ScrollRightBtn.Text = "▶"; ScrollRightBtn.TextColor3 = Color3.new(1, 1, 1)
ScrollRightBtn.Font = Enum.Font.GothamBold; ScrollRightBtn.TextSize = 10; ScrollRightBtn.BorderSizePixel = 0; ScrollRightBtn.Parent = Window; addCorner(ScrollRightBtn, 4)
local tabScrollOffset = 0; local maxTabScroll = 0; local TAB_W = 96; local TAB_GAP = 3; local TabBtns = {}; local TabPages = {}
local function updateTabScroll()
    TabScrollFrame.Position = UDim2.new(0, -tabScrollOffset, 0, 0); ScrollLeftBtn.Visible = tabScrollOffset > 0; ScrollRightBtn.Visible = tabScrollOffset < maxTabScroll
end
ScrollLeftBtn.Activated:Connect(function() tabScrollOffset = math.max(0, tabScrollOffset - (TAB_W + TAB_GAP)); updateTabScroll() end)
ScrollRightBtn.Activated:Connect(function() tabScrollOffset = math.min(maxTabScroll, tabScrollOffset + (TAB_W + TAB_GAP)); updateTabScroll() end)
local function updateCanvas(page, layout) pcall(function() page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8) end) end
local function createTab(name, index)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, TAB_W, 0, 30); btn.Position = UDim2.new(0, (index-1)*(TAB_W + TAB_GAP), 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42); btn.Text = name; btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 10; btn.BorderSizePixel = 0; btn.Parent = TabScrollFrame; addCorner(btn, 5); addStroke(btn, 1, Color3.fromRGB(60, 100, 255))
    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1, -12, 1, -78); page.Position = UDim2.new(0, 6, 0, 72)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55)
    page.CanvasSize = UDim2.new(0, 0, 0, 0); page.Visible = false; page.Parent = Window
    local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 5); layout.Parent = page
    btn.Activated:Connect(function()
        for _, p in pairs(TabPages) do p.Page.Visible = false end
        for _, b in pairs(TabBtns) do b.BackgroundColor3 = Color3.fromRGB(28, 28, 42); b.TextColor3 = Color3.fromRGB(180, 180, 200) end
        page.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80); btn.TextColor3 = Color3.new(1, 1, 1)
    end)
    table.insert(TabBtns, btn); TabPages[index] = {Page = page, Layout = layout}
    maxTabScroll = math.max(0, index * (TAB_W + TAB_GAP) - 480 + 10); updateTabScroll(); return page, layout
end

-- ==================== UI FACTORIES ====================
local function addButton(page, layout, text, callback, btnRef)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
    btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 11
    btn.BorderSizePixel = 0; btn.Parent = page; addCorner(btn, 5); addStroke(btn, 1, Color3.fromRGB(50, 50, 70))
    btn.Activated:Connect(callback); updateCanvas(page, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page, layout) end)
    if btnRef then btnRef[1] = btn end; return btn
end

local function addToggleWithInput(page, layout, text, placeholder, defaultVal, toggleCallback, inputCallback)
    local container = Instance.new("Frame"); container.Size = UDim2.new(1, 0, 0, 34); container.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
    container.BorderSizePixel = 0; container.Parent = page; addCorner(container, 5); addStroke(container, 1, Color3.fromRGB(50, 50, 70))
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0, 100, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.new(1, 1, 1); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = container
    local ibg = Instance.new("Frame"); ibg.Size = UDim2.new(0, 50, 0, 20); ibg.Position = UDim2.new(0, 108, 0.5, -10); ibg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); ibg.BorderSizePixel = 0; ibg.Parent = container; addCorner(ibg, 3)
    local tb = Instance.new("TextBox"); tb.Size = UDim2.new(1, -6, 1, 0); tb.Position = UDim2.new(0, 3, 0, 0); tb.BackgroundTransparency = 1
    tb.PlaceholderText = placeholder; tb.PlaceholderColor3 = Color3.fromRGB(100, 100, 120); tb.Text = defaultVal; tb.TextColor3 = Color3.new(1, 1, 1)
    tb.Font = Enum.Font.Gotham; tb.TextSize = 10; tb.ZIndex = 10; tb.Parent = ibg
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 32, 0, 16); bg.Position = UDim2.new(1, -42, 0.5, -8); bg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); bg.BorderSizePixel = 0; bg.Parent = container; addCorner(bg, 1)
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6); dot.BackgroundColor3 = Color3.fromRGB(180, 180, 200); dot.BorderSizePixel = 0; dot.Parent = bg; addCorner(dot, 1)
    local click = Instance.new("TextButton"); click.Size = UDim2.new(0, 40, 1, 0); click.Position = UDim2.new(1, -44, 0, 0); click.BackgroundTransparency = 1; click.Text = ""; click.ZIndex = 5; click.Parent = container
    local enabled = false
    click.Activated:Connect(function()
        enabled = not enabled; bg.BackgroundColor3 = enabled and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(22, 22, 34)
        dot:TweenPosition(UDim2.new(0, enabled and 18 or 2, 0.5, -6), "Out", "Quad", 0.15)
        dot.BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 200); toggleCallback(enabled)
    end)
    tb.FocusLost:Connect(function() inputCallback(tb.Text) end); tb.Focused:Connect(function() click.Active = false end); tb.FocusLost:Connect(function() click.Active = true end)
    updateCanvas(page, layout); layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page, layout) end); return container, tb
end

local function addToggle(page, layout, text, callback)
    local c = Instance.new("Frame"); c.Size = UDim2.new(1, 0, 0, 32); c.BackgroundColor3 = Color3.fromRGB(32, 32, 46); c.BorderSizePixel = 0; c.Parent = page; addCorner(c, 5); addStroke(c, 1, Color3.fromRGB(50, 50, 70))
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Color3.new(1, 1, 1); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = c
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 32, 0, 16); bg.Position = UDim2.new(1, -42, 0.5, -8); bg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); bg.BorderSizePixel = 0; bg.Parent = c; addCorner(bg, 1)
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6); dot.BackgroundColor3 = Color3.fromRGB(180, 180, 200); dot.BorderSizePixel = 0; dot.Parent = bg; addCorner(dot, 1)
    local click = Instance.new("TextButton"); click.Size = UDim2.new(0, 40, 1, 0); click.Position = UDim2.new(1, -44, 0, 0); click.BackgroundTransparency = 1; click.Text = ""; click.ZIndex = 5; click.Parent = c
    local enabled = false
    click.Activated:Connect(function()
        enabled = not enabled; bg.BackgroundColor3 = enabled and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(22, 22, 34)
        dot:TweenPosition(UDim2.new(0, enabled and 18 or 2, 0.5, -6), "Out", "Quad", 0.15)
        dot.BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 200); callback(enabled)
    end)
    updateCanvas(page, layout); layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page, layout) end); return c
end

-- ==================== CREATE TABS ====================
local page1, layout1 = createTab("Move", 1)
local page2, layout2 = createTab("ESP", 2)
local page3, layout3 = createTab("Different", 3)
local page4, layout4 = createTab("Mimic", 4)
local page5, layout5 = createTab("Bot", 5)

-- ==================== FEATURES STATE ====================
local Features = {
    Speed = {Enabled = false, Value = 16}, Jump = {Enabled = false, Value = 50}, AutoJump = false,
    ESP = {Enabled = false, Color = Color3.new(1, 0, 0), HPBar = false, HPBarOnly = false},
    AntiFling = false, WalkFling = false, Fly = {Enabled = false, Speed = 50}, Noclip = false,
    Hitbox = {Enabled = false, Size = 5}, Freezecam = false, SpinSpeed = 50, AnimSpeed = 1,
    Mimic = {Enabled = false, Target = nil, PositionDelay = 0, CopyJump = true, SmoothFollow = true, FollowOffset = 5, FollowOffsetEnabled = true, FollowDelayEnabled = false},
    Bot = {Enabled = false, Speed = 16, SpeedEnabled = false, JumpOnPoint = false, Waypoints = {}, CurrentWaypointIndex = 0}
}

local connections = {}; local espStorage = {}; local mimicConnections = {}; local botConnections = {}; local botWaypointParts = {}
local lastWPToPlayerBeam = nil; local allBeams = {}
local flyActive = false; local flyHeartbeat

-- ==================== CLEANUP FUNCTIONS ====================
local function resetAllHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player and plr.Character then for _, p in pairs(plr.Character:GetChildren()) do if p:IsA("BasePart") and p.Name == "HumanoidRootPart" then p.Size = Vector3.new(2, 2, 1); p.Transparency = 0; p.CanCollide = true; p.Massless = false end end end end
end

local function hideMimicMenu()
    pcall(function() MimicMenuBtn.Visible = false end)
    pcall(function() MimicMenuWindow.Visible = false end)
end

local function stopMimic()
    Features.Mimic.Enabled = false
    if mimicConnections.Main then mimicConnections.Main:Disconnect(); mimicConnections.Main = nil end
    if Player.Character and not Features.Bot.Enabled then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = Features.Speed.Enabled and Features.Speed.Value or 16
            hum.JumpPower = Features.Jump.Enabled and Features.Jump.Value or 50
        end
    end
    hideMimicMenu()
end

local function resetWaypointColors()
    for _, wp in pairs(Features.Bot.Waypoints) do if wp.Part and wp.Part.Parent then wp.Part.Color = Color3.fromRGB(60, 100, 255); for _, child in pairs(wp.Part:GetChildren()) do if child:IsA("PointLight") then child.Color = Color3.fromRGB(60, 100, 255) end end end end
end

local function registerBeam(beam)
    table.insert(allBeams, beam)
end

local function destroyBeam(beam)
    if beam and beam.Parent then beam:Destroy() end
    for i, b in pairs(allBeams) do if b == beam then allBeams[i] = nil; break end end
end

local function removeLastWPToPlayerBeam()
    if lastWPToPlayerBeam and lastWPToPlayerBeam.Parent then
        destroyBeam(lastWPToPlayerBeam)
    end
    lastWPToPlayerBeam = nil
end

local function createLastWPToPlayerBeam()
    removeLastWPToPlayerBeam()
    if #Features.Bot.Waypoints == 0 then return end
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local lastWp = Features.Bot.Waypoints[#Features.Bot.Waypoints]
    if not lastWp or not lastWp.Part or not lastWp.Part.Parent then return end
    local beam = Instance.new("Beam")
    beam.Attachment0 = Instance.new("Attachment"); beam.Attachment0.Parent = lastWp.Part
    beam.Attachment1 = Instance.new("Attachment"); beam.Attachment1.Parent = root
    beam.Width0 = 0.2; beam.Width1 = 0.2
    beam.Color = ColorSequence.new(Color3.fromRGB(60, 100, 255))
    beam.Transparency = NumberSequence.new(0.3)
    beam.Parent = lastWp.Part
    lastWPToPlayerBeam = beam
    registerBeam(beam)
end

local function fixLastBeamToPreviousWP()
    if #Features.Bot.Waypoints < 2 then return end
    local prevWp = Features.Bot.Waypoints[#Features.Bot.Waypoints - 1]
    local lastWp = Features.Bot.Waypoints[#Features.Bot.Waypoints]
    if prevWp and prevWp.Part and prevWp.Part.Parent and lastWp and lastWp.Part and lastWp.Part.Parent then
        removeLastWPToPlayerBeam()
        local beam = Instance.new("Beam")
        beam.Attachment0 = Instance.new("Attachment"); beam.Attachment0.Parent = prevWp.Part
        beam.Attachment1 = Instance.new("Attachment"); beam.Attachment1.Parent = lastWp.Part
        beam.Width0 = 0.2; beam.Width1 = 0.2
        beam.Color = ColorSequence.new(Color3.fromRGB(60, 100, 255))
        beam.Transparency = NumberSequence.new(0.3)
        beam.Parent = prevWp.Part
        prevWp.Beam = beam
        registerBeam(beam)
    end
end

local function stopBot()
    Features.Bot.Enabled = false; Features.Bot.CurrentWaypointIndex = 0
    if botConnections.Walk then botConnections.Walk:Disconnect(); botConnections.Walk = nil end
    if Player.Character and not Features.Mimic.Enabled then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Features.Speed.Enabled and Features.Speed.Value or 16 end
    end
    resetWaypointColors()
    createLastWPToPlayerBeam()
end

local function clearWaypointBeams()
    removeLastWPToPlayerBeam()
    for _, wp in pairs(Features.Bot.Waypoints) do
        if wp.Beam then destroyBeam(wp.Beam) end
        if wp.Part and wp.Part.Parent then wp.Part:Destroy() end
    end
    for i, b in pairs(allBeams) do if b and b.Parent then b:Destroy() end end
    allBeams = {}
    Features.Bot.Waypoints = {}; botWaypointParts = {}
end

local function stopMobileFly()
    flyActive = false
    if flyHeartbeat then flyHeartbeat:Disconnect(); flyHeartbeat = nil end
    if connections.FlyObjects then for _, obj in pairs(connections.FlyObjects) do if obj and obj.Parent then obj:Destroy() end end; connections.FlyObjects = nil end
    connections.Fly = nil
    pcall(function() FlyGui.Enabled = false end)
    pcall(function() FlyButton.Visible = false end)
    pcall(function() DPad.Visible = false end)
    pcall(function() FlyToggleBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34) end)
    pcall(function() FlyToggleDot.Position = UDim2.new(0, 2, 0.5, -6) end)
    pcall(function() FlyToggleDot.BackgroundColor3 = Color3.fromRGB(180, 180, 200) end)
    if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.PlatformStand = false end end
end

local function stopAllFunctions()
    for _, conn in pairs(connections) do if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end end
    connections = {}; Features.WalkFling = false
    if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect(); autoJumpHeartbeat = nil end
    stopMimic(); stopBot(); resetWaypointColors(); resetAllHitboxes()
    stopMobileFly()
    pcall(function() FlyControlWindow.Visible = false end)
    if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false end; local root = Player.Character:FindFirstChild("HumanoidRootPart"); if root then root.Anchored = false end; for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0; p.CanCollide = true end end end
    for _, data in pairs(espStorage) do if data.Highlight then data.Highlight:Destroy() end; if data.Billboard then data.Billboard:Destroy() end; if data.HPConnection then data.HPConnection:Disconnect() end end; espStorage = {}
    pcall(function() Gui:Destroy() end); pcall(function() ExtGui:Destroy() end); pcall(function() BotEditorGui:Destroy() end); pcall(function() ColorPickerGui:Destroy() end)
    pcall(function() MimicMenuGui:Destroy() end); pcall(function() MimicMenuBtnGui:Destroy() end); pcall(function() FlyGui:Destroy() end); pcall(function() BotButtonGui:Destroy() end)
    pcall(function() FlyControlGui:Destroy() end)
    clearWaypointBeams()
end

-- ==================== ESP FUNCTIONS ====================
local function refreshESP()
    for _, data in pairs(espStorage) do if data.Highlight then data.Highlight:Destroy() end; if data.Billboard then data.Billboard:Destroy() end; if data.HPConnection then data.HPConnection:Disconnect() end end
    espStorage = {}
    local function addHPBarOnly(char)
        if espStorage[char] then return end; espStorage[char] = {}
        local hum = char:FindFirstChild("Humanoid"); if hum then
            local bb = Instance.new("BillboardGui"); bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 55, 0, 12); bb.Parent = char
            local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 0, 7); nl.BackgroundTransparency = 1; nl.Text = char.Name; nl.TextColor3 = Color3.new(1, 1, 1); nl.Font = Enum.Font.Gotham; nl.TextSize = 7; nl.Parent = bb
            local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 3); bg.Position = UDim2.new(0, 0, 0, 8); bg.BackgroundColor3 = Color3.new(0, 0, 0); bg.BorderSizePixel = 0; bg.Parent = bb
            local bar = Instance.new("Frame"); bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0); bar.BackgroundColor3 = Color3.new(0, 1, 0); bar.BorderSizePixel = 0; bar.Parent = bg
            espStorage[char].Billboard = bb; espStorage[char].HPConnection = hum:GetPropertyChangedSignal("Health"):Connect(function() if bar and bar.Parent then bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0) end end)
        end
    end
    local function addFullESP(char)
        if espStorage[char] then return end
        local hl = Instance.new("Highlight"); hl.FillTransparency = 0.85; hl.OutlineColor = Features.ESP.Color; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char; espStorage[char] = {Highlight = hl}
        if Features.ESP.HPBar then
            local hum = char:FindFirstChild("Humanoid"); if hum then
                local bb = Instance.new("BillboardGui"); bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 55, 0, 12); bb.Parent = char
                local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 0, 7); nl.BackgroundTransparency = 1; nl.Text = char.Name; nl.TextColor3 = Color3.new(1, 1, 1); nl.Font = Enum.Font.Gotham; nl.TextSize = 7; nl.Parent = bb
                local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 0, 3); bg.Position = UDim2.new(0, 0, 0, 8); bg.BackgroundColor3 = Color3.new(0, 0, 0); bg.BorderSizePixel = 0; bg.Parent = bb
                local bar = Instance.new("Frame"); bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0); bar.BackgroundColor3 = Color3.new(0, 1, 0); bar.BorderSizePixel = 0; bar.Parent = bg
                espStorage[char].Billboard = bb; espStorage[char].HPConnection = hum:GetPropertyChangedSignal("Health"):Connect(function() if bar and bar.Parent then bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0) end end)
            end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player and plr.Character then if Features.ESP.HPBarOnly and not Features.ESP.Enabled then addHPBarOnly(plr.Character) elseif Features.ESP.Enabled then addFullESP(plr.Character) end end end
    if connections.ESP then connections.ESP:Disconnect() end
    connections.ESP = RunService.Stepped:Connect(function() for char, data in pairs(espStorage) do if not char.Parent then if data.Highlight then data.Highlight:Destroy() end; if data.Billboard then data.Billboard:Destroy() end; if data.HPConnection then data.HPConnection:Disconnect() end; espStorage[char] = nil end end end)
end

-- ==================== AUTO JUMP ====================
local autoJumpEnabled = false; local autoJumpHeartbeat = nil
local function startAutoJump()
    if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect() end
    autoJumpHeartbeat = RunService.Heartbeat:Connect(function()
        if not autoJumpEnabled then return end
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- ==================== COLOR PICKER ====================
local ColorPickerGui = Instance.new("ScreenGui"); ColorPickerGui.Name = "ColorPickerGui"; ColorPickerGui.Parent = CoreGui; ColorPickerGui.ResetOnSpawn = false
local ColorPickerWindow = Instance.new("Frame"); ColorPickerWindow.Size = UDim2.new(0, 260, 0, 200); ColorPickerWindow.Position = UDim2.new(0.3, -130, 0.4, -100)
ColorPickerWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 18); ColorPickerWindow.BorderSizePixel = 0; ColorPickerWindow.Visible = false; ColorPickerWindow.Parent = ColorPickerGui
addCorner(ColorPickerWindow, 8); addStroke(ColorPickerWindow, 1, Color3.fromRGB(60, 100, 255))
local CPTop = Instance.new("Frame"); CPTop.Size = UDim2.new(1, 0, 0, 25); CPTop.BackgroundColor3 = Color3.fromRGB(14, 14, 24); CPTop.BorderSizePixel = 0; CPTop.Active = true; CPTop.Parent = ColorPickerWindow; addCorner(CPTop, 8)
local CPTopCover = Instance.new("Frame"); CPTopCover.Size = UDim2.new(1, 0, 0.5, 0); CPTopCover.Position = UDim2.new(0, 0, 0.5, 0); CPTopCover.BackgroundColor3 = Color3.fromRGB(14, 14, 24); CPTopCover.BorderSizePixel = 0; CPTopCover.Parent = CPTop
local CPTitle = Instance.new("TextLabel"); CPTitle.Size = UDim2.new(1, -20, 1, 0); CPTitle.Position = UDim2.new(0, 8, 0, 0); CPTitle.BackgroundTransparency = 1; CPTitle.Text = "🎨 ESP Color Palette"; CPTitle.TextColor3 = Color3.fromRGB(100, 160, 255); CPTitle.Font = Enum.Font.GothamBold; CPTitle.TextSize = 11; CPTitle.TextXAlignment = Enum.TextXAlignment.Left; CPTitle.Parent = CPTop
makeDraggable(ColorPickerWindow, CPTop)
local CPClose = Instance.new("TextButton"); CPClose.Size = UDim2.new(0, 22, 0, 22); CPClose.Position = UDim2.new(1, -26, 0, 2); CPClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65); CPClose.Text = "✕"; CPClose.TextColor3 = Color3.new(1, 1, 1); CPClose.Font = Enum.Font.GothamBold; CPClose.TextSize = 10; CPClose.BorderSizePixel = 0; CPClose.Parent = CPTop; addCorner(CPClose, 4)
CPClose.Activated:Connect(function() ColorPickerWindow.Visible = false end)
local CPPreview = Instance.new("Frame"); CPPreview.Size = UDim2.new(0, 40, 0, 20); CPPreview.Position = UDim2.new(0, 10, 0, 32); CPPreview.BackgroundColor3 = Features.ESP.Color; CPPreview.BorderSizePixel = 0; CPPreview.Parent = ColorPickerWindow; addCorner(CPPreview, 4)
local CPPreviewLabel = Instance.new("TextLabel"); CPPreviewLabel.Size = UDim2.new(0, 100, 0, 20); CPPreviewLabel.Position = UDim2.new(0, 55, 0, 32); CPPreviewLabel.BackgroundTransparency = 1; CPPreviewLabel.Text = "Selected Color"; CPPreviewLabel.TextColor3 = Color3.fromRGB(200, 200, 200); CPPreviewLabel.Font = Enum.Font.Gotham; CPPreviewLabel.TextSize = 10; CPPreviewLabel.TextXAlignment = Enum.TextXAlignment.Left; CPPreviewLabel.Parent = ColorPickerWindow
local paletteContainer = Instance.new("Frame"); paletteContainer.Size = UDim2.new(1, -20, 0, 120); paletteContainer.Position = UDim2.new(0, 10, 0, 58); paletteContainer.BackgroundTransparency = 1; paletteContainer.Parent = ColorPickerWindow
local paletteGrid = Instance.new("UIGridLayout"); paletteGrid.CellSize = UDim2.new(0, 24, 0, 24); paletteGrid.CellPadding = UDim2.new(0, 3, 0, 3); paletteGrid.FillDirection = Enum.FillDirection.Horizontal; paletteGrid.SortOrder = Enum.SortOrder.LayoutOrder; paletteGrid.Parent = paletteContainer
local presetColors = {
    {Color3.fromRGB(255, 0, 0), "Red"}, {Color3.fromRGB(0, 255, 0), "Green"}, {Color3.fromRGB(0, 0, 255), "Blue"},
    {Color3.fromRGB(255, 255, 0), "Yellow"}, {Color3.fromRGB(255, 0, 255), "Magenta"}, {Color3.fromRGB(0, 255, 255), "Cyan"},
    {Color3.fromRGB(255, 128, 0), "Orange"}, {Color3.fromRGB(128, 0, 255), "Purple"}, {Color3.fromRGB(255, 255, 255), "White"},
    {Color3.fromRGB(255, 105, 180), "Pink"}, {Color3.fromRGB(0, 255, 128), "Mint"}, {Color3.fromRGB(128, 255, 0), "Lime"},
    {Color3.fromRGB(255, 50, 50), "Light Red"}, {Color3.fromRGB(50, 255, 50), "Light Green"}, {Color3.fromRGB(50, 50, 255), "Light Blue"},
    {Color3.fromRGB(255, 200, 0), "Gold"}, {Color3.fromRGB(200, 0, 200), "Dark Magenta"}, {Color3.fromRGB(0, 200, 200), "Teal"},
    {Color3.fromRGB(150, 75, 0), "Brown"}, {Color3.fromRGB(100, 100, 100), "Gray"},
}
for _, colorData in ipairs(presetColors) do
    local color, colorName = colorData[1], colorData[2]
    local swatch = Instance.new("TextButton"); swatch.Size = UDim2.new(0, 24, 0, 24); swatch.BackgroundColor3 = color; swatch.BorderSizePixel = 0; swatch.Text = ""; swatch.Parent = paletteContainer; addCorner(swatch, 2); addStroke(swatch, 1, Color3.fromRGB(40, 40, 50))
    swatch.Activated:Connect(function() Features.ESP.Color = color; CPPreview.BackgroundColor3 = color; CPPreviewLabel.Text = "Selected: " .. colorName; for _, data in pairs(espStorage) do if data.Highlight then data.Highlight.OutlineColor = color end end end)
end

-- ==================== MIMIC MENU ====================
local MimicMenuGui = Instance.new("ScreenGui"); MimicMenuGui.Name = "MimicMenuGui"; MimicMenuGui.Parent = CoreGui; MimicMenuGui.ResetOnSpawn = false
local MimicMenuWindow = Instance.new("Frame"); MimicMenuWindow.Size = UDim2.new(0, 220, 0, 280); MimicMenuWindow.Position = UDim2.new(0.7, -110, 0.3, -140)
MimicMenuWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 18); MimicMenuWindow.BorderSizePixel = 0; MimicMenuWindow.Visible = false; MimicMenuWindow.Parent = MimicMenuGui
addCorner(MimicMenuWindow, 8); addRainbowStroke(MimicMenuWindow, 2)
local MMTop = Instance.new("Frame"); MMTop.Size = UDim2.new(1, 0, 0, 25); MMTop.BackgroundColor3 = Color3.fromRGB(14, 14, 24); MMTop.BorderSizePixel = 0; MMTop.Active = true; MMTop.Parent = MimicMenuWindow; addCorner(MMTop, 8)
local MMTopCover = Instance.new("Frame"); MMTopCover.Size = UDim2.new(1, 0, 0.5, 0); MMTopCover.Position = UDim2.new(0, 0, 0.5, 0); MMTopCover.BackgroundColor3 = Color3.fromRGB(14, 14, 24); MMTopCover.BorderSizePixel = 0; MMTopCover.Parent = MMTop
local MMTitle = Instance.new("TextLabel"); MMTitle.Size = UDim2.new(1, -20, 1, 0); MMTitle.Position = UDim2.new(0, 8, 0, 0); MMTitle.BackgroundTransparency = 1; MMTitle.Text = "🎯 Mimic Menu"; MMTitle.TextColor3 = Color3.fromRGB(100, 160, 255); MMTitle.Font = Enum.Font.GothamBold; MMTitle.TextSize = 11; MMTitle.TextXAlignment = Enum.TextXAlignment.Left; MMTitle.Parent = MMTop
makeDraggable(MimicMenuWindow, MMTop)
local MMClose = Instance.new("TextButton"); MMClose.Size = UDim2.new(0, 22, 0, 22); MMClose.Position = UDim2.new(1, -26, 0, 2); MMClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65); MMClose.Text = "✕"; MMClose.TextColor3 = Color3.new(1, 1, 1); MMClose.Font = Enum.Font.GothamBold; MMClose.TextSize = 10; MMClose.BorderSizePixel = 0; MMClose.Parent = MMTop; addCorner(MMClose, 4)
MMClose.Activated:Connect(function() MimicMenuWindow.Visible = false end)
local MMMimicTargetLabel = Instance.new("TextLabel"); MMMimicTargetLabel.Size = UDim2.new(1, -16, 0, 20); MMMimicTargetLabel.Position = UDim2.new(0, 8, 0, 35); MMMimicTargetLabel.BackgroundTransparency = 1; MMMimicTargetLabel.Text = "No Target"; MMMimicTargetLabel.TextColor3 = Color3.fromRGB(255, 80, 80); MMMimicTargetLabel.Font = Enum.Font.GothamSemibold; MMMimicTargetLabel.TextSize = 10; MMMimicTargetLabel.Parent = MimicMenuWindow

local function updateMMMimicTarget()
    if Features.Mimic.Target and Features.Mimic.Target.Parent then MMMimicTargetLabel.Text = "🎯 Target: " .. Features.Mimic.Target.Name; MMMimicTargetLabel.TextColor3 = Color3.fromRGB(80, 255, 80) else MMMimicTargetLabel.Text = "No Target"; MMMimicTargetLabel.TextColor3 = Color3.fromRGB(255, 80, 80) end
end

local function teleportToTarget()
    if not Features.Mimic.Target or not Features.Mimic.Target.Parent then return end
    local target = Features.Mimic.Target; if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetRoot = target.Character.HumanoidRootPart; local myRoot = Player.Character.HumanoidRootPart
    local tc = targetRoot.CFrame; local offset = Features.Mimic.FollowOffsetEnabled and Features.Mimic.FollowOffset or 0
    myRoot.CFrame = CFrame.new(tc.Position + (-tc.LookVector * offset), tc.Position)
end

local function startMimicFollow()
    if not Features.Mimic.Target or not Features.Mimic.Target.Parent then return end
    local target = Features.Mimic.Target
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end

    if mimicConnections.Main then mimicConnections.Main:Disconnect(); mimicConnections.Main = nil end

    local targetRoot = target.Character.HumanoidRootPart
    local myRoot = Player.Character.HumanoidRootPart
    local tc = targetRoot.CFrame
    myRoot.CFrame = CFrame.new(tc.Position + (-tc.LookVector * (Features.Mimic.FollowOffsetEnabled and Features.Mimic.FollowOffset or 5)), tc.Position)

    local lastCFrame = targetRoot.CFrame
    if Player.Character then
        local myHum = Player.Character:FindFirstChild("Humanoid")
        if myHum then myHum.WalkSpeed = 0 end
    end

    local lastJump = 0
    mimicConnections.Main = RunService.Heartbeat:Connect(function()
        if not Features.Mimic.Enabled then return end
        if not target.Parent then stopMimic(); return end
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        local tRoot = target.Character.HumanoidRootPart
        local tHum = target.Character:FindFirstChild("Humanoid")
        local mRoot = Player.Character.HumanoidRootPart
        local mHum = Player.Character:FindFirstChild("Humanoid")
        if not mRoot or not mHum then return end
        local tc = tRoot.CFrame
        local offset = Features.Mimic.FollowOffsetEnabled and Features.Mimic.FollowOffset or 0
        local offPos = tc.Position + (-tc.LookVector * offset)
        local delay = Features.Mimic.FollowDelayEnabled and Features.Mimic.PositionDelay or 0
        if delay > 0 then task.wait(delay) end
        if Features.Mimic.SmoothFollow and lastCFrame then
            mRoot.CFrame = CFrame.new(mRoot.Position:Lerp(offPos, 0.15), tc.Position)
        else
            mRoot.CFrame = CFrame.new(offPos, tc.Position)
        end
        lastCFrame = tc
        if Features.Mimic.CopyJump and tHum then
            local now = tick()
            if tHum:GetState() == Enum.HumanoidStateType.Jumping and (now - lastJump) > 1 then
                lastJump = now
                mHum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local GotoTargetBtn = Instance.new("TextButton"); GotoTargetBtn.Size = UDim2.new(1, -16, 0, 32); GotoTargetBtn.Position = UDim2.new(0, 8, 0, 60); GotoTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 255); GotoTargetBtn.Text = "📍 Goto Target"; GotoTargetBtn.TextColor3 = Color3.new(1, 1, 1); GotoTargetBtn.Font = Enum.Font.GothamBold; GotoTargetBtn.TextSize = 11; GotoTargetBtn.BorderSizePixel = 0; GotoTargetBtn.Parent = MimicMenuWindow; addCorner(GotoTargetBtn, 5)
GotoTargetBtn.Activated:Connect(function()
    if not Features.Mimic.Target or not Features.Mimic.Target.Parent then return end
    teleportToTarget()
    if Features.Mimic.Enabled then startMimicFollow() end
end)

local RandomTargetBtn = Instance.new("TextButton"); RandomTargetBtn.Size = UDim2.new(1, -16, 0, 32); RandomTargetBtn.Position = UDim2.new(0, 8, 0, 98); RandomTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 255); RandomTargetBtn.Text = "🎲 Random Target"; RandomTargetBtn.TextColor3 = Color3.new(1, 1, 1); RandomTargetBtn.Font = Enum.Font.GothamBold; RandomTargetBtn.TextSize = 11; RandomTargetBtn.BorderSizePixel = 0; RandomTargetBtn.Parent = MimicMenuWindow; addCorner(RandomTargetBtn, 5)
RandomTargetBtn.Activated:Connect(function()
    local players = {}; for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player then table.insert(players, plr) end end
    if #players > 0 then
        Features.Mimic.Target = players[math.random(1, #players)]
        updateMMMimicTarget()
        updateMimicDisplay()
        teleportToTarget()
        if Features.Mimic.Enabled then startMimicFollow() end
    end
end)

local MMFollowOffsetContainer = Instance.new("Frame"); MMFollowOffsetContainer.Size = UDim2.new(1, -16, 0, 34); MMFollowOffsetContainer.Position = UDim2.new(0, 8, 0, 138); MMFollowOffsetContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 46); MMFollowOffsetContainer.BorderSizePixel = 0; MMFollowOffsetContainer.Parent = MimicMenuWindow; addCorner(MMFollowOffsetContainer, 5); addStroke(MMFollowOffsetContainer, 1, Color3.fromRGB(50, 50, 70))
local MMFOOffsetLabel = Instance.new("TextLabel"); MMFOOffsetLabel.Size = UDim2.new(0, 90, 1, 0); MMFOOffsetLabel.Position = UDim2.new(0, 5, 0, 0); MMFOOffsetLabel.BackgroundTransparency = 1; MMFOOffsetLabel.Text = "Follow Offset"; MMFOOffsetLabel.TextColor3 = Color3.new(1, 1, 1); MMFOOffsetLabel.Font = Enum.Font.Gotham; MMFOOffsetLabel.TextSize = 9; MMFOOffsetLabel.TextXAlignment = Enum.TextXAlignment.Left; MMFOOffsetLabel.Parent = MMFollowOffsetContainer
local MMFOInput = Instance.new("TextBox"); MMFOInput.Size = UDim2.new(0, 40, 0, 18); MMFOInput.Position = UDim2.new(0, 95, 0.5, -9); MMFOInput.BackgroundColor3 = Color3.fromRGB(22, 22, 34); MMFOInput.BorderSizePixel = 0; MMFOInput.Text = "5"; MMFOInput.TextColor3 = Color3.new(1, 1, 1); MMFOInput.Font = Enum.Font.Gotham; MMFOInput.TextSize = 9; MMFOInput.Parent = MMFollowOffsetContainer; addCorner(MMFOInput, 3)
local MMFOButton = Instance.new("TextButton"); MMFOButton.Size = UDim2.new(0, 36, 0, 18); MMFOButton.Position = UDim2.new(1, -42, 0.5, -9); MMFOButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60); MMFOButton.Text = "ON"; MMFOButton.TextColor3 = Color3.new(1, 1, 1); MMFOButton.Font = Enum.Font.GothamBold; MMFOButton.TextSize = 9; MMFOButton.BorderSizePixel = 0; MMFOButton.Parent = MMFollowOffsetContainer; addCorner(MMFOButton, 3)
local function applyFollowOffset() if Features.Mimic.FollowOffsetEnabled then Features.Mimic.FollowOffset = tonumber(MMFOInput.Text) or 5; if Features.Mimic.Enabled and Features.Mimic.Target then teleportToTarget() end else Features.Mimic.FollowOffset = 0 end end
MMFOButton.Activated:Connect(function()
    Features.Mimic.FollowOffsetEnabled = not Features.Mimic.FollowOffsetEnabled
    if Features.Mimic.FollowOffsetEnabled then MMFOButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60); MMFOButton.Text = "ON"; MMFOButton.TextColor3 = Color3.new(1, 1, 1) else MMFOButton.BackgroundColor3 = Color3.fromRGB(22, 22, 34); MMFOButton.Text = "OFF"; MMFOButton.TextColor3 = Color3.fromRGB(180, 180, 200) end
    applyFollowOffset()
end)
MMFOInput.FocusLost:Connect(function() if Features.Mimic.FollowOffsetEnabled then applyFollowOffset() end end)

local MMFollowDelayContainer = Instance.new("Frame"); MMFollowDelayContainer.Size = UDim2.new(1, -16, 0, 34); MMFollowDelayContainer.Position = UDim2.new(0, 8, 0, 178); MMFollowDelayContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 46); MMFollowDelayContainer.BorderSizePixel = 0; MMFollowDelayContainer.Parent = MimicMenuWindow; addCorner(MMFollowDelayContainer, 5); addStroke(MMFollowDelayContainer, 1, Color3.fromRGB(50, 50, 70))
local MMFDLabel = Instance.new("TextLabel"); MMFDLabel.Size = UDim2.new(0, 90, 1, 0); MMFDLabel.Position = UDim2.new(0, 5, 0, 0); MMFDLabel.BackgroundTransparency = 1; MMFDLabel.Text = "Follow Delay"; MMFDLabel.TextColor3 = Color3.new(1, 1, 1); MMFDLabel.Font = Enum.Font.Gotham; MMFDLabel.TextSize = 9; MMFDLabel.TextXAlignment = Enum.TextXAlignment.Left; MMFDLabel.Parent = MMFollowDelayContainer
local MMFDInput = Instance.new("TextBox"); MMFDInput.Size = UDim2.new(0, 40, 0, 18); MMFDInput.Position = UDim2.new(0, 95, 0.5, -9); MMFDInput.BackgroundColor3 = Color3.fromRGB(22, 22, 34); MMFDInput.BorderSizePixel = 0; MMFDInput.Text = "0"; MMFDInput.TextColor3 = Color3.new(1, 1, 1); MMFDInput.Font = Enum.Font.Gotham; MMFDInput.TextSize = 9; MMFDInput.Parent = MMFollowDelayContainer; addCorner(MMFDInput, 3)
local MMFDButton = Instance.new("TextButton"); MMFDButton.Size = UDim2.new(0, 36, 0, 18); MMFDButton.Position = UDim2.new(1, -42, 0.5, -9); MMFDButton.BackgroundColor3 = Color3.fromRGB(22, 22, 34); MMFDButton.Text = "OFF"; MMFDButton.TextColor3 = Color3.fromRGB(180, 180, 200); MMFDButton.Font = Enum.Font.GothamBold; MMFDButton.TextSize = 9; MMFDButton.BorderSizePixel = 0; MMFDButton.Parent = MMFollowDelayContainer; addCorner(MMFDButton, 3)
local function applyFollowDelay() if Features.Mimic.FollowDelayEnabled then Features.Mimic.PositionDelay = tonumber(MMFDInput.Text) or 0 else Features.Mimic.PositionDelay = 0 end end
MMFDButton.Activated:Connect(function()
    Features.Mimic.FollowDelayEnabled = not Features.Mimic.FollowDelayEnabled
    if Features.Mimic.FollowDelayEnabled then MMFDButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60); MMFDButton.Text = "ON"; MMFDButton.TextColor3 = Color3.new(1, 1, 1) else MMFDButton.BackgroundColor3 = Color3.fromRGB(22, 22, 34); MMFDButton.Text = "OFF"; MMFDButton.TextColor3 = Color3.fromRGB(180, 180, 200) end
    applyFollowDelay()
end)
MMFDInput.FocusLost:Connect(function() if Features.Mimic.FollowDelayEnabled then applyFollowDelay() end end)

local MimicMenuBtnGui = Instance.new("ScreenGui"); MimicMenuBtnGui.Name = "MimicMenuBtn"; MimicMenuBtnGui.Parent = CoreGui; MimicMenuBtnGui.ResetOnSpawn = false
local MimicMenuBtn = Instance.new("TextButton"); MimicMenuBtn.Size = UDim2.new(0, 50, 0, 50); MimicMenuBtn.Position = UDim2.new(0.02, 0, 0.55, -25); MimicMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); MimicMenuBtn.Text = "🎯"; MimicMenuBtn.TextColor3 = Color3.new(1, 1, 1); MimicMenuBtn.Font = Enum.Font.GothamBold; MimicMenuBtn.TextSize = 20; MimicMenuBtn.BorderSizePixel = 0; MimicMenuBtn.AutoButtonColor = false; MimicMenuBtn.Visible = false; MimicMenuBtn.Parent = MimicMenuBtnGui; addCorner(MimicMenuBtn, 25); addRainbowStroke(MimicMenuBtn, 2)
MimicMenuBtn.Activated:Connect(function() MimicMenuWindow.Visible = not MimicMenuWindow.Visible end)
makeDraggable(MimicMenuBtn, MimicMenuBtn)

-- ==================== FLY CONTROL GUI ====================
local FlyControlGui = Instance.new("ScreenGui"); FlyControlGui.Name = "FlyControlGui"; FlyControlGui.Parent = CoreGui; FlyControlGui.ResetOnSpawn = false
local FlyControlWindow = Instance.new("Frame"); FlyControlWindow.Size = UDim2.new(0, 180, 0, 130); FlyControlWindow.Position = UDim2.new(0.8, -90, 0.5, -65)
FlyControlWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 18); FlyControlWindow.BorderSizePixel = 0; FlyControlWindow.Visible = false; FlyControlWindow.Parent = FlyControlGui
addCorner(FlyControlWindow, 8); addRainbowStroke(FlyControlWindow, 2)
local FCTop = Instance.new("Frame"); FCTop.Size = UDim2.new(1, 0, 0, 25); FCTop.BackgroundColor3 = Color3.fromRGB(14, 14, 24); FCTop.BorderSizePixel = 0; FCTop.Active = true; FCTop.Parent = FlyControlWindow; addCorner(FCTop, 8)
local FCTopCover = Instance.new("Frame"); FCTopCover.Size = UDim2.new(1, 0, 0.5, 0); FCTopCover.Position = UDim2.new(0, 0, 0.5, 0); FCTopCover.BackgroundColor3 = Color3.fromRGB(14, 14, 24); FCTopCover.BorderSizePixel = 0; FCTopCover.Parent = FCTop
local FCTitle = Instance.new("TextLabel"); FCTitle.Size = UDim2.new(1, -20, 1, 0); FCTitle.Position = UDim2.new(0, 8, 0, 0); FCTitle.BackgroundTransparency = 1; FCTitle.Text = "✈ Fly Control"; FCTitle.TextColor3 = Color3.fromRGB(100, 160, 255); FCTitle.Font = Enum.Font.GothamBold; FCTitle.TextSize = 11; FCTitle.TextXAlignment = Enum.TextXAlignment.Left; FCTitle.Parent = FCTop
makeDraggable(FlyControlWindow, FCTop)
local FCClose = Instance.new("TextButton"); FCClose.Size = UDim2.new(0, 22, 0, 22); FCClose.Position = UDim2.new(1, -26, 0, 2); FCClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65); FCClose.Text = "✕"; FCClose.TextColor3 = Color3.new(1, 1, 1); FCClose.Font = Enum.Font.GothamBold; FCClose.TextSize = 10; FCClose.BorderSizePixel = 0; FCClose.Parent = FCTop; addCorner(FCClose, 4)
FCClose.Activated:Connect(function() FlyControlWindow.Visible = false end)

local FlyToggleContainer = Instance.new("Frame"); FlyToggleContainer.Size = UDim2.new(1, -16, 0, 34); FlyToggleContainer.Position = UDim2.new(0, 8, 0, 35); FlyToggleContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 46); FlyToggleContainer.BorderSizePixel = 0; FlyToggleContainer.Parent = FlyControlWindow; addCorner(FlyToggleContainer, 5); addStroke(FlyToggleContainer, 1, Color3.fromRGB(50, 50, 70))
local FlyToggleLabel = Instance.new("TextLabel"); FlyToggleLabel.Size = UDim2.new(0, 80, 1, 0); FlyToggleLabel.Position = UDim2.new(0, 10, 0, 0); FlyToggleLabel.BackgroundTransparency = 1; FlyToggleLabel.Text = "Fly ON/OFF"; FlyToggleLabel.TextColor3 = Color3.new(1, 1, 1); FlyToggleLabel.Font = Enum.Font.Gotham; FlyToggleLabel.TextSize = 10; FlyToggleLabel.TextXAlignment = Enum.TextXAlignment.Left; FlyToggleLabel.Parent = FlyToggleContainer
local FlyToggleBg = Instance.new("Frame"); FlyToggleBg.Size = UDim2.new(0, 32, 0, 16); FlyToggleBg.Position = UDim2.new(1, -42, 0.5, -8); FlyToggleBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); FlyToggleBg.BorderSizePixel = 0; FlyToggleBg.Parent = FlyToggleContainer; addCorner(FlyToggleBg, 1)
local FlyToggleDot = Instance.new("Frame"); FlyToggleDot.Size = UDim2.new(0, 12, 0, 12); FlyToggleDot.Position = UDim2.new(0, 2, 0.5, -6); FlyToggleDot.BackgroundColor3 = Color3.fromRGB(180, 180, 200); FlyToggleDot.BorderSizePixel = 0; FlyToggleDot.Parent = FlyToggleBg; addCorner(FlyToggleDot, 1)
local FlyToggleClick = Instance.new("TextButton"); FlyToggleClick.Size = UDim2.new(0, 40, 1, 0); FlyToggleClick.Position = UDim2.new(1, -44, 0, 0); FlyToggleClick.BackgroundTransparency = 1; FlyToggleClick.Text = ""; FlyToggleClick.ZIndex = 5; FlyToggleClick.Parent = FlyToggleContainer
FlyToggleClick.Activated:Connect(function()
    flyActive = not flyActive
    FlyToggleBg.BackgroundColor3 = flyActive and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(22, 22, 34)
    FlyToggleDot:TweenPosition(UDim2.new(0, flyActive and 18 or 2, 0.5, -6), "Out", "Quad", 0.15)
    FlyToggleDot.BackgroundColor3 = flyActive and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 200)
    if flyActive then startMobileFly() else stopMobileFly() end
end)

local FlySpeedContainer = Instance.new("Frame"); FlySpeedContainer.Size = UDim2.new(1, -16, 0, 34); FlySpeedContainer.Position = UDim2.new(0, 8, 0, 75); FlySpeedContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 46); FlySpeedContainer.BorderSizePixel = 0; FlySpeedContainer.Parent = FlyControlWindow; addCorner(FlySpeedContainer, 5); addStroke(FlySpeedContainer, 1, Color3.fromRGB(50, 50, 70))
local FlySpeedLabel = Instance.new("TextLabel"); FlySpeedLabel.Size = UDim2.new(0, 80, 1, 0); FlySpeedLabel.Position = UDim2.new(0, 10, 0, 0); FlySpeedLabel.BackgroundTransparency = 1; FlySpeedLabel.Text = "Speed"; FlySpeedLabel.TextColor3 = Color3.new(1, 1, 1); FlySpeedLabel.Font = Enum.Font.Gotham; FlySpeedLabel.TextSize = 10; FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left; FlySpeedLabel.Parent = FlySpeedContainer
local FlySpeedInputBg = Instance.new("Frame"); FlySpeedInputBg.Size = UDim2.new(0, 60, 0, 20); FlySpeedInputBg.Position = UDim2.new(1, -70, 0.5, -10); FlySpeedInputBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); FlySpeedInputBg.BorderSizePixel = 0; FlySpeedInputBg.Parent = FlySpeedContainer; addCorner(FlySpeedInputBg, 3)
local FlySpeedInput = Instance.new("TextBox"); FlySpeedInput.Size = UDim2.new(1, -6, 1, 0); FlySpeedInput.Position = UDim2.new(0, 3, 0, 0); FlySpeedInput.BackgroundTransparency = 1
FlySpeedInput.PlaceholderText = "50"; FlySpeedInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120); FlySpeedInput.Text = "50"; FlySpeedInput.TextColor3 = Color3.new(1, 1, 1)
FlySpeedInput.Font = Enum.Font.Gotham; FlySpeedInput.TextSize = 10; FlySpeedInput.ZIndex = 10; FlySpeedInput.Parent = FlySpeedInputBg
FlySpeedInput.FocusLost:Connect(function()
    local val = tonumber(FlySpeedInput.Text)
    if val then Features.Fly.Speed = math.clamp(val, 10, 500); FlySpeedInput.Text = tostring(Features.Fly.Speed)
    else FlySpeedInput.Text = tostring(Features.Fly.Speed) end
    FlySpeedText.Text = tostring(Features.Fly.Speed)
end)

-- ==================== MOBILE FLY GUI ====================
local FlyGui = Instance.new("ScreenGui"); FlyGui.Name = "FlyGui"; FlyGui.Parent = CoreGui; FlyGui.ResetOnSpawn = false; FlyGui.Enabled = false; FlyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local FlyButton = Instance.new("TextButton"); FlyButton.Size = UDim2.new(0, 60, 0, 60); FlyButton.Position = UDim2.new(0.8, -30, 0.7, -30); FlyButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0); FlyButton.Text = "✈"; FlyButton.TextColor3 = Color3.new(1, 1, 1); FlyButton.Font = Enum.Font.GothamBold; FlyButton.TextSize = 28; FlyButton.BorderSizePixel = 0; FlyButton.AutoButtonColor = false; FlyButton.Parent = FlyGui; addCorner(FlyButton, 30); addRainbowStroke(FlyButton, 2)
local FlySpeedText = Instance.new("TextLabel"); FlySpeedText.Size = UDim2.new(1, 0, 0, 12); FlySpeedText.Position = UDim2.new(0, 0, 1, -14); FlySpeedText.BackgroundTransparency = 1; FlySpeedText.Text = "50"; FlySpeedText.TextColor3 = Color3.new(1, 1, 1); FlySpeedText.Font = Enum.Font.GothamBold; FlySpeedText.TextSize = 10; FlySpeedText.Parent = FlyButton
local DPad = Instance.new("Frame"); DPad.Size = UDim2.new(0, 160, 0, 160); DPad.Position = UDim2.new(0.05, 0, 0.55, -80); DPad.BackgroundTransparency = 1; DPad.Parent = FlyGui
local function createDPadButton(name, position, text, color)
    local btn = Instance.new("TextButton"); btn.Name = name; btn.Size = UDim2.new(0, 45, 0, 45); btn.Position = position; btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40); btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 18; btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Parent = DPad; addCorner(btn, 8); addStroke(btn, 1, Color3.fromRGB(60, 100, 255)); return btn
end
local UpBtn = createDPadButton("Up", UDim2.new(0.5, -22, 0, 10), "▲"); local DownBtn = createDPadButton("Down", UDim2.new(0.5, -22, 0, 105), "▼")
local LeftBtn = createDPadButton("Left", UDim2.new(0, 10, 0.5, -22), "◀"); local RightBtn = createDPadButton("Right", UDim2.new(1, -55, 0.5, -22), "▶")
local flyDirection = Vector3.new(); local inputStates = {Up = false, Down = false, Left = false, Right = false, Space = false, Ctrl = false}
local function updateFlyVelocity() if not flyActive then return end; local dir = Vector3.new(); if inputStates.Up then dir += workspace.CurrentCamera.CFrame.LookVector end; if inputStates.Down then dir -= workspace.CurrentCamera.CFrame.LookVector end; if inputStates.Left then dir -= workspace.CurrentCamera.CFrame.RightVector end; if inputStates.Right then dir += workspace.CurrentCamera.CFrame.RightVector end; if inputStates.Space then dir += Vector3.new(0, 1, 0) end; if inputStates.Ctrl then dir -= Vector3.new(0, 1, 0) end; flyDirection = dir end
local function connectDPadButton(btn, key)
    btn.MouseButton1Down:Connect(function() inputStates[key] = true; btn.BackgroundColor3 = Color3.fromRGB(60, 100, 255); updateFlyVelocity() end)
    btn.MouseButton1Up:Connect(function() inputStates[key] = false; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); updateFlyVelocity() end)
    btn.MouseLeave:Connect(function() if inputStates[key] then inputStates[key] = false; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); updateFlyVelocity() end end)
end
connectDPadButton(UpBtn, "Up"); connectDPadButton(DownBtn, "Down"); connectDPadButton(LeftBtn, "Left"); connectDPadButton(RightBtn, "Right")
local lastTap = 0; FlyButton.Activated:Connect(function() local now = tick(); if now - lastTap < 0.3 then inputStates.Space = not inputStates.Space; updateFlyVelocity() end; lastTap = now end)
local draggingFlyBtn = false; local dragStartX = 0
FlyButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then draggingFlyBtn = true; dragStartX = input.Position.X end end)
UserInputService.InputChanged:Connect(function(input) if draggingFlyBtn and input.UserInputType == Enum.UserInputType.Touch then local delta = input.Position.X - dragStartX; Features.Fly.Speed = math.clamp(50 + delta * 0.5, 10, 500); FlySpeedText.Text = tostring(math.floor(Features.Fly.Speed)); FlySpeedInput.Text = tostring(math.floor(Features.Fly.Speed)) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then draggingFlyBtn = false end end)
makeDraggable(FlyButton, FlyButton)

local function startMobileFly()
    if flyHeartbeat then flyHeartbeat:Disconnect() end
    local hum = Player.Character and Player.Character:FindFirstChild("Humanoid"); local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end; hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9999999, 9999999, 9999999); bv.Velocity = Vector3.new(); bv.P = 1000; bv.Parent = root
    local bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(9999999, 9999999, 9999999); bg.P = 10000; bg.CFrame = root.CFrame; bg.Parent = root
    FlyGui.Enabled = true; FlyButton.Visible = true; DPad.Visible = true
    FlyToggleBg.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
    FlyToggleDot.Position = UDim2.new(0, 18, 0.5, -6)
    FlyToggleDot.BackgroundColor3 = Color3.new(1, 1, 1)
    flyHeartbeat = RunService.Heartbeat:Connect(function() if not root or not root.Parent or not flyActive then return end; updateFlyVelocity(); local vel = flyDirection.Magnitude > 0 and flyDirection.Unit * Features.Fly.Speed or Vector3.new(); bv.Velocity = vel; bg.CFrame = workspace.CurrentCamera.CFrame end)
    connections.Fly = flyHeartbeat; connections.FlyObjects = {bv, bg}
end

-- ==================== TAB 1: MOVE ====================
addToggleWithInput(page1, layout1, "Speed", "16", "16", function(e) Features.Speed.Enabled = e; if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = e and Features.Speed.Value or 16 end end end, function(v) Features.Speed.Value = tonumber(v) or 16; if Features.Speed.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = Features.Speed.Value end end end end)
addToggleWithInput(page1, layout1, "Jump", "50", "50", function(e) Features.Jump.Enabled = e; if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.JumpPower = e and Features.Jump.Value or 50 end end end, function(v) Features.Jump.Value = tonumber(v) or 50; if Features.Jump.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.JumpPower = Features.Jump.Value end end end end)
addToggle(page1, layout1, "Auto Jump", function(e) autoJumpEnabled = e; if e then startAutoJump() else if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect(); autoJumpHeartbeat = nil end end end)
addToggle(page1, layout1, "Noclip", function(e) Features.Noclip = e; if connections.Noclip then connections.Noclip:Disconnect() end; if e then connections.Noclip = RunService.Stepped:Connect(function() if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) else if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end end)
addButton(page1, layout1, "Server Hop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if data and data.data and #data.data > 0 then
            local servers = {}
            for _, s in pairs(data.data) do if s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(servers, s.id) end end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player) end
        end
    end)
end)
addButton(page1, layout1, "Rejoin Server", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
local stopBtn = Instance.new("TextButton"); stopBtn.Size = UDim2.new(1, 0, 0, 34); stopBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40); stopBtn.Text = "⏹ STOP SCRIPT"; stopBtn.TextColor3 = Color3.new(1, 1, 1); stopBtn.Font = Enum.Font.GothamBold; stopBtn.TextSize = 12; stopBtn.BorderSizePixel = 0; stopBtn.Parent = page1; addCorner(stopBtn, 5); stopBtn.Activated:Connect(stopAllFunctions)
updateCanvas(page1, layout1); layout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page1, layout1) end)

-- ==================== TAB 2: ESP ====================
addToggle(page2, layout2, "Player ESP", function(e) Features.ESP.Enabled = e; Features.ESP.HPBarOnly = false; if e then refreshESP() else if not Features.ESP.HPBar then for _, data in pairs(espStorage) do if data.Highlight then data.Highlight:Destroy() end; if data.Billboard then data.Billboard:Destroy() end; if data.HPConnection then data.HPConnection:Disconnect() end end; espStorage = {}; if connections.ESP then connections.ESP:Disconnect(); connections.ESP = nil end end end end)
addButton(page2, layout2, "🎨 Open Color Palette", function() ColorPickerWindow.Visible = true end)
addToggle(page2, layout2, "HP Bar", function(e) Features.ESP.HPBar = e; if not Features.ESP.Enabled and e then Features.ESP.HPBarOnly = true; refreshESP() end; if Features.ESP.Enabled then refreshESP() end; if not e and not Features.ESP.Enabled then for _, data in pairs(espStorage) do if data.Billboard then data.Billboard:Destroy() end; if data.HPConnection then data.HPConnection:Disconnect() end end; espStorage = {}; if connections.ESP then connections.ESP:Disconnect(); connections.ESP = nil end end end)
addToggleWithInput(page2, layout2, "Hitbox", "5", "5", function(e) Features.Hitbox.Enabled = e; if connections.Hitbox then connections.Hitbox:Disconnect(); connections.Hitbox = nil end; if e then local function apply(p) if p == Player then return end; if p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size = Vector3.new(Features.Hitbox.Size, Features.Hitbox.Size, Features.Hitbox.Size); hrp.Transparency = 0.7 end end end; for _, plr in pairs(Players:GetPlayers()) do apply(plr) end; local function onAdd(p) if p == Player then return end; apply(p); if p.CharacterAdded then local conn = p.CharacterAdded:Connect(function(ch) task.wait(0.5); local hrp = ch:FindFirstChild("HumanoidRootPart"); if hrp and Features.Hitbox.Enabled then hrp.Size = Vector3.new(Features.Hitbox.Size, Features.Hitbox.Size, Features.Hitbox.Size); hrp.Transparency = 0.7 end end); if not connections.HitboxExtras then connections.HitboxExtras = {} end; table.insert(connections.HitboxExtras, conn) end end; local ac = Players.PlayerAdded:Connect(onAdd); if not connections.HitboxExtras then connections.HitboxExtras = {} end; table.insert(connections.HitboxExtras, ac); connections.Hitbox = RunService.Heartbeat:Connect(function() if not Features.Hitbox.Enabled then return end; for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player and plr.Character then local hrp = plr.Character:FindFirstChild("HumanoidRootPart"); if hrp then local sz = Vector3.new(Features.Hitbox.Size, Features.Hitbox.Size, Features.Hitbox.Size); if hrp.Size ~= sz then hrp.Size = sz end; if hrp.Transparency ~= 0.7 then hrp.Transparency = 0.7 end end end end end) else resetAllHitboxes(); if connections.HitboxExtras then for _, c in pairs(connections.HitboxExtras) do pcall(function() c:Disconnect() end) end; connections.HitboxExtras = nil end end end, function(v) Features.Hitbox.Size = tonumber(v) or 5 end)

-- ==================== TAB 3: DIFFERENT ====================
addToggle(page3, layout3, "Anti-Fling", function(e) Features.AntiFling = e; if connections.AntiFling then connections.AntiFling:Disconnect() end; if e then connections.AntiFling = RunService.Heartbeat:Connect(function() if Player.Character then local r = Player.Character:FindFirstChild("HumanoidRootPart"); local h = Player.Character:FindFirstChild("Humanoid"); if r and h and (r.Velocity.Magnitude > 200 or r.AssemblyLinearVelocity.Magnitude > 200) then r.Velocity = Vector3.new(0, r.Velocity.Y, 0); r.AssemblyLinearVelocity = Vector3.new(); h.PlatformStand = false end end end) end end)
addToggle(page3, layout3, "WalkFling", function(e) Features.WalkFling = e; if connections.WalkFling then connections.WalkFling:Disconnect(); connections.WalkFling = nil end; if e then Features.Noclip = true; if connections.Noclip then connections.Noclip:Disconnect() end; connections.Noclip = RunService.Stepped:Connect(function() if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end); local movel = 0.1; connections.WalkFling = RunService.Heartbeat:Connect(function() if not Features.WalkFling then return end; local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end; local vel = root.Velocity; root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0); RunService.RenderStepped:Wait(); if root and root.Parent then root.Velocity = vel end; RunService.Stepped:Wait(); if root and root.Parent then root.Velocity = vel + Vector3.new(0, movel, 0); movel = movel * -1 end end) else Features.Noclip = false; if connections.Noclip then connections.Noclip:Disconnect(); connections.Noclip = nil end; if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end end)
addToggle(page3, layout3, "Freezecam", function(e) Features.Freezecam = e; if connections.Freezecam then connections.Freezecam:Disconnect() end; if e then local cam = workspace.CurrentCamera; if cam then local fcf = cam.CFrame; connections.Freezecam = RunService.RenderStepped:Connect(function() cam.CFrame = fcf end) end end end)
addToggle(page3, layout3, "Freeze Player", function(e) if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart"); if root then root.Anchored = e end end end)
addButton(page3, layout3, "Explode", function() if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart"); local hum = Player.Character:FindFirstChild("Humanoid"); if root then local sh = hum and hum.Health or 100; local exp = Instance.new("Explosion"); exp.Position = root.Position; exp.BlastPressure = 500000; exp.BlastRadius = 20; exp.DestroyJointRadiusPercent = 0; exp.Parent = Workspace; task.wait(0.1); if hum and hum.Parent then hum.Health = sh end end end end)
addToggleWithInput(page3, layout3, "Spin Speed", "50", "50", function(e) if connections.Spin and connections.Spin.Parent then connections.Spin:Destroy() end; if e then local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"); if root then local bav = Instance.new("BodyAngularVelocity"); bav.AngularVelocity = Vector3.new(0, Features.SpinSpeed, 0); bav.MaxTorque = Vector3.new(0, 9999999, 0); bav.P = 100000; bav.Parent = root; connections.Spin = bav end end end, function(v) Features.SpinSpeed = math.clamp(tonumber(v) or 50, 1, 500); if connections.Spin and connections.Spin.Parent then connections.Spin.AngularVelocity = Vector3.new(0, Features.SpinSpeed, 0) end end)
addToggleWithInput(page3, layout3, "Anim Speed", "1", "1", function(e) if e then if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then local animator = hum:FindFirstChild("Animator"); if not animator then animator = Instance.new("Animator"); animator.Parent = hum end; connections.AnimSpeed = RunService.Heartbeat:Connect(function() for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(Features.AnimSpeed) end end) end end else if connections.AnimSpeed then connections.AnimSpeed:Disconnect() end end end, function(v) Features.AnimSpeed = math.clamp(tonumber(v) or 1, 0.1, 10); if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then local animator = hum:FindFirstChild("Animator"); if animator then for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(Features.AnimSpeed) end end end end end)
addToggle(page3, layout3, "Fly (Mobile)", function(e)
    Features.Fly.Enabled = e
    if e then FlyControlWindow.Visible = true; FlyButton.Visible = true; DPad.Visible = true; FlyGui.Enabled = true; FlySpeedInput.Text = tostring(Features.Fly.Speed); FlySpeedText.Text = tostring(Features.Fly.Speed)
    else stopMobileFly(); FlyControlWindow.Visible = false; FlyButton.Visible = false; DPad.Visible = false; FlyGui.Enabled = false end
end)

-- ==================== TAB 4: MIMIC ====================
local mimicTargetDisplay = Instance.new("TextLabel"); mimicTargetDisplay.Size = UDim2.new(1, 0, 0, 30); mimicTargetDisplay.BackgroundColor3 = Color3.fromRGB(32, 32, 46); mimicTargetDisplay.BorderSizePixel = 0; mimicTargetDisplay.Text = "No Target Selected"; mimicTargetDisplay.TextColor3 = Color3.fromRGB(255, 80, 80); mimicTargetDisplay.Font = Enum.Font.GothamSemibold; mimicTargetDisplay.TextSize = 11; mimicTargetDisplay.Parent = page4; addCorner(mimicTargetDisplay, 5)
local refreshTimerLabel = Instance.new("TextLabel"); refreshTimerLabel.Size = UDim2.new(1, 0, 0, 20); refreshTimerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30); refreshTimerLabel.BorderSizePixel = 0; refreshTimerLabel.Text = "⏳ Refresh time: 10"; refreshTimerLabel.TextColor3 = Color3.fromRGB(100, 160, 255); refreshTimerLabel.Font = Enum.Font.GothamSemibold; refreshTimerLabel.TextSize = 10; refreshTimerLabel.Parent = page4; addCorner(refreshTimerLabel, 4)
updateCanvas(page4, layout4); layout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page4, layout4) end)

local playerListOpen = false; local playerListScrollingFrame = nil; local playerListBtnRef = {}
local function closePlayerList()
    if playerListScrollingFrame and playerListScrollingFrame.Parent then playerListScrollingFrame:Destroy() end
    playerListScrollingFrame = nil; playerListOpen = false
    if playerListBtnRef[1] then playerListBtnRef[1].Text = "📋 Open Player List" end
    updateCanvas(page4, layout4)
end
local function togglePlayerList()
    playerListOpen = not playerListOpen
    if playerListOpen then
        if playerListBtnRef[1] then playerListBtnRef[1].Text = "📋 Close Player List" end
        playerListScrollingFrame = Instance.new("ScrollingFrame"); playerListScrollingFrame.Size = UDim2.new(1, 0, 0, 150); playerListScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30); playerListScrollingFrame.BorderSizePixel = 0; playerListScrollingFrame.ScrollBarThickness = 3; playerListScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 55); playerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0); playerListScrollingFrame.Parent = page4; addCorner(playerListScrollingFrame, 5); addStroke(playerListScrollingFrame, 1, Color3.fromRGB(60, 100, 255))
        local plLayout = Instance.new("UIListLayout"); plLayout.Padding = UDim.new(0, 2); plLayout.Parent = playerListScrollingFrame
        plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() playerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, plLayout.AbsoluteContentSize.Y + 8) end)
        for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player then
            local plrBtn = Instance.new("TextButton"); plrBtn.Size = UDim2.new(1, -8, 0, 24); plrBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 46); plrBtn.Text = "🎯 " .. plr.Name; plrBtn.TextColor3 = Color3.new(1, 1, 1); plrBtn.Font = Enum.Font.Gotham; plrBtn.TextSize = 10; plrBtn.BorderSizePixel = 0; plrBtn.Parent = playerListScrollingFrame; addCorner(plrBtn, 4)
            plrBtn.Activated:Connect(function() Features.Mimic.Target = plr; updateMimicDisplay(); updateMMMimicTarget(); closePlayerList() end)
        end end
        local count = 0; for _, _ in pairs(Players:GetPlayers()) do count = count + 1 end
        playerListScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (count - 1) * 26 + 8); updateCanvas(page4, layout4)
    else closePlayerList() end
end
addButton(page4, layout4, "📋 Open Player List", togglePlayerList, playerListBtnRef)

local function updateMimicDisplay()
    if Features.Mimic.Target and Features.Mimic.Target.Parent then mimicTargetDisplay.Text = "🎯 Target: " .. Features.Mimic.Target.Name; mimicTargetDisplay.TextColor3 = Color3.fromRGB(80, 255, 80) else mimicTargetDisplay.Text = "No Target Selected"; mimicTargetDisplay.TextColor3 = Color3.fromRGB(255, 80, 80); Features.Mimic.Target = nil end
end

addToggle(page4, layout4, "Copy Jumps", function(e) Features.Mimic.CopyJump = e end)
addToggle(page4, layout4, "Smooth Follow", function(e) Features.Mimic.SmoothFollow = e end)

addToggle(page4, layout4, "Start Mimic", function(e)
    Features.Mimic.Enabled = e
    if e then
        MimicMenuBtn.Visible = true; MimicMenuWindow.Visible = true
        Features.Mimic.FollowOffset = 5; Features.Mimic.FollowOffsetEnabled = true
        Features.Mimic.PositionDelay = 0; Features.Mimic.FollowDelayEnabled = false
        MMFOInput.Text = "5"; MMFOButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60); MMFOButton.Text = "ON"; MMFOButton.TextColor3 = Color3.new(1, 1, 1)
        MMFDInput.Text = "0"; MMFDButton.BackgroundColor3 = Color3.fromRGB(22, 22, 34); MMFDButton.Text = "OFF"; MMFDButton.TextColor3 = Color3.fromRGB(180, 180, 200)
        if not Features.Mimic.Target or not Features.Mimic.Target.Parent then updateMimicDisplay(); updateMMMimicTarget(); Features.Mimic.Enabled = false; hideMimicMenu(); return end
        local target = Features.Mimic.Target
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then Features.Mimic.Enabled = false; hideMimicMenu(); return end
        startMimicFollow()
    else stopMimic(); hideMimicMenu() end
end)

local refreshCountdown = 10
local refreshTimerConnection = RunService.Heartbeat:Connect(function(dt) refreshCountdown = refreshCountdown - dt; if refreshCountdown <= 0 then refreshCountdown = 10; updateMimicDisplay(); updateMMMimicTarget() end; refreshTimerLabel.Text = "⏳ Refresh time: " .. math.ceil(refreshCountdown) end)
table.insert(connections, refreshTimerConnection)
addButton(page4, layout4, "🔄 Refresh Now", function() refreshCountdown = 10; updateMimicDisplay(); updateMMMimicTarget() end)

-- ==================== TAB 5: BOT ====================
local botSpeedContainer = Instance.new("Frame"); botSpeedContainer.Size = UDim2.new(1, 0, 0, 34); botSpeedContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
botSpeedContainer.BorderSizePixel = 0; botSpeedContainer.Parent = page5; addCorner(botSpeedContainer, 5); addStroke(botSpeedContainer, 1, Color3.fromRGB(50, 50, 70))
local botSpeedLabel = Instance.new("TextLabel"); botSpeedLabel.Size = UDim2.new(0, 70, 1, 0); botSpeedLabel.Position = UDim2.new(0, 8, 0, 0)
botSpeedLabel.BackgroundTransparency = 1; botSpeedLabel.Text = "Speed Bot"; botSpeedLabel.TextColor3 = Color3.new(1, 1, 1); botSpeedLabel.Font = Enum.Font.Gotham; botSpeedLabel.TextSize = 10; botSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left; botSpeedLabel.Parent = botSpeedContainer
local botSpeedInputBg = Instance.new("Frame"); botSpeedInputBg.Size = UDim2.new(0, 40, 0, 20); botSpeedInputBg.Position = UDim2.new(0, 80, 0.5, -10); botSpeedInputBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); botSpeedInputBg.BorderSizePixel = 0; botSpeedInputBg.Parent = botSpeedContainer; addCorner(botSpeedInputBg, 3)
local botSpeedInput = Instance.new("TextBox"); botSpeedInput.Size = UDim2.new(1, -6, 1, 0); botSpeedInput.Position = UDim2.new(0, 3, 0, 0); botSpeedInput.BackgroundTransparency = 1
botSpeedInput.PlaceholderText = "16"; botSpeedInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120); botSpeedInput.Text = "16"; botSpeedInput.TextColor3 = Color3.new(1, 1, 1)
botSpeedInput.Font = Enum.Font.Gotham; botSpeedInput.TextSize = 10; botSpeedInput.ZIndex = 10; botSpeedInput.Parent = botSpeedInputBg
local botSpeedToggleBg = Instance.new("Frame"); botSpeedToggleBg.Size = UDim2.new(0, 32, 0, 16); botSpeedToggleBg.Position = UDim2.new(1, -42, 0.5, -8); botSpeedToggleBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); botSpeedToggleBg.BorderSizePixel = 0; botSpeedToggleBg.Parent = botSpeedContainer; addCorner(botSpeedToggleBg, 1)
local botSpeedDot = Instance.new("Frame"); botSpeedDot.Size = UDim2.new(0, 12, 0, 12); botSpeedDot.Position = UDim2.new(0, 2, 0.5, -6); botSpeedDot.BackgroundColor3 = Color3.fromRGB(180, 180, 200); botSpeedDot.BorderSizePixel = 0; botSpeedDot.Parent = botSpeedToggleBg; addCorner(botSpeedDot, 1)
local botSpeedClick = Instance.new("TextButton"); botSpeedClick.Size = UDim2.new(0, 40, 1, 0); botSpeedClick.Position = UDim2.new(1, -44, 0, 0); botSpeedClick.BackgroundTransparency = 1; botSpeedClick.Text = ""; botSpeedClick.ZIndex = 5; botSpeedClick.Parent = botSpeedContainer
botSpeedClick.Activated:Connect(function()
    Features.Bot.SpeedEnabled = not Features.Bot.SpeedEnabled
    botSpeedToggleBg.BackgroundColor3 = Features.Bot.SpeedEnabled and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(22, 22, 34)
    botSpeedDot:TweenPosition(UDim2.new(0, Features.Bot.SpeedEnabled and 18 or 2, 0.5, -6), "Out", "Quad", 0.15)
    botSpeedDot.BackgroundColor3 = Features.Bot.SpeedEnabled and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 200)
    if Features.Bot.SpeedEnabled then Features.Bot.Speed = tonumber(botSpeedInput.Text) or 16; if Features.Bot.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = Features.Bot.Speed end end
    else Features.Bot.Speed = 16; botSpeedInput.Text = "16"; if Features.Bot.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = 16 end end end
end)
botSpeedInput.FocusLost:Connect(function() if Features.Bot.SpeedEnabled then Features.Bot.Speed = tonumber(botSpeedInput.Text) or 16; if Features.Bot.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = Features.Bot.Speed end end end end)

-- ==================== BOT EDITOR ====================
local BotEditorGui = Instance.new("ScreenGui"); BotEditorGui.Name = "BotEditorGui"; BotEditorGui.Parent = CoreGui; BotEditorGui.ResetOnSpawn = false
local BotEditorWindow = Instance.new("Frame"); BotEditorWindow.Size = UDim2.new(0, 280, 0, 260); BotEditorWindow.Position = UDim2.new(0.7, -140, 0.3, -130); BotEditorWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 18); BotEditorWindow.BorderSizePixel = 0; BotEditorWindow.Visible = false; BotEditorWindow.Parent = BotEditorGui; addCorner(BotEditorWindow, 12); addStroke(BotEditorWindow, 2, Color3.fromRGB(60, 100, 255))
local beTopBar = Instance.new("Frame"); beTopBar.Size = UDim2.new(1, 0, 0, 35); beTopBar.BackgroundColor3 = Color3.fromRGB(14, 14, 24); beTopBar.BorderSizePixel = 0; beTopBar.Active = true; beTopBar.Parent = BotEditorWindow; addCorner(beTopBar, 12)
local beTopCover = Instance.new("Frame"); beTopCover.Size = UDim2.new(1, 0, 0.5, 0); beTopCover.Position = UDim2.new(0, 0, 0.5, 0); beTopCover.BackgroundColor3 = Color3.fromRGB(14, 14, 24); beTopCover.BorderSizePixel = 0; beTopCover.Parent = beTopBar
local beTitle = Instance.new("TextLabel"); beTitle.Size = UDim2.new(1, -40, 1, 0); beTitle.Position = UDim2.new(0, 12, 0, 0); beTitle.BackgroundTransparency = 1; beTitle.Text = "🤖 Bot Editor"; beTitle.TextColor3 = Color3.fromRGB(100, 160, 255); beTitle.Font = Enum.Font.GothamBold; beTitle.TextSize = 13; beTitle.TextXAlignment = Enum.TextXAlignment.Left; beTitle.Parent = beTopBar
local beClose = Instance.new("TextButton"); beClose.Size = UDim2.new(0, 26, 0, 26); beClose.Position = UDim2.new(1, -30, 0, 4); beClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65); beClose.Text = "✕"; beClose.TextColor3 = Color3.new(1, 1, 1); beClose.Font = Enum.Font.GothamBold; beClose.TextSize = 12; beClose.BorderSizePixel = 0; beClose.Parent = beTopBar; addCorner(beClose, 6)
makeDraggable(BotEditorWindow, beTopBar); beClose.Activated:Connect(function() BotEditorWindow.Visible = false end)
local beContent = Instance.new("Frame"); beContent.Size = UDim2.new(1, -16, 1, -45); beContent.Position = UDim2.new(0, 8, 0, 40); beContent.BackgroundTransparency = 1; beContent.Parent = BotEditorWindow
local beLayout = Instance.new("UIListLayout"); beLayout.Padding = UDim.new(0, 6); beLayout.Parent = beContent

local function addBEBtn(text, cb)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 34); btn.BackgroundColor3 = Color3.fromRGB(22, 22, 38); btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 11; btn.BorderSizePixel = 0; btn.Parent = beContent; addCorner(btn, 6); addStroke(btn, 1, Color3.fromRGB(40, 40, 60)); btn.Activated:Connect(cb); return btn
end

local function highlightWaypoint(index)
    resetWaypointColors()
    if index > 0 and index <= #Features.Bot.Waypoints then
        local wp = Features.Bot.Waypoints[index]; if wp.Part and wp.Part.Parent then wp.Part.Color = Color3.fromRGB(0, 255, 0); for _, child in pairs(wp.Part:GetChildren()) do if child:IsA("PointLight") then child.Color = Color3.fromRGB(0, 255, 0) end end end
    end
end

addBEBtn("📍 Create Waypoint", function()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart; local pos = root.Position; local n = #Features.Bot.Waypoints + 1
    local part = Instance.new("Part"); part.Size = Vector3.new(1, 1, 1); part.Position = pos; part.Anchored = true; part.CanCollide = false; part.Color = Color3.fromRGB(60, 100, 255); part.Material = Enum.Material.Neon; part.Parent = Workspace
    local light = Instance.new("PointLight"); light.Brightness = 1; light.Range = 10; light.Color = Color3.fromRGB(60, 100, 255); light.Parent = part
    local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 100, 0, 20); bb.StudsOffset = Vector3.new(0, 2, 0); bb.AlwaysOnTop = true; bb.Parent = part
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = "WP #" .. n; lbl.TextColor3 = Color3.new(1, 1, 1); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.Parent = bb
    if n > 1 then fixLastBeamToPreviousWP() end
    table.insert(Features.Bot.Waypoints, {Part = part, Position = pos})
    table.insert(botWaypointParts, part)
    createLastWPToPlayerBeam()
end)

addBEBtn("🗑 Delete Last Point", function()
    if #Features.Bot.Waypoints == 0 then return end
    local lastWp = Features.Bot.Waypoints[#Features.Bot.Waypoints]
    if lastWp then if lastWp.Beam then destroyBeam(lastWp.Beam) end; if lastWp.Part and lastWp.Part.Parent then lastWp.Part:Destroy() end end
    table.remove(Features.Bot.Waypoints, #Features.Bot.Waypoints)
    if #botWaypointParts > 0 then table.remove(botWaypointParts, #botWaypointParts) end
    if #Features.Bot.Waypoints > 0 then local newLastWp = Features.Bot.Waypoints[#Features.Bot.Waypoints]; if newLastWp and newLastWp.Beam then destroyBeam(newLastWp.Beam) end end
    removeLastWPToPlayerBeam()
    if #Features.Bot.Waypoints > 0 then createLastWPToPlayerBeam() end
    if Features.Bot.Enabled then if Features.Bot.CurrentWaypointIndex > #Features.Bot.Waypoints then Features.Bot.CurrentWaypointIndex = 1 end; if #Features.Bot.Waypoints > 0 then highlightWaypoint(Features.Bot.CurrentWaypointIndex) end end
end)

addBEBtn("🗑 Clear Waypoints", function() clearWaypointBeams(); stopBot() end)

local botToggleBtn = Instance.new("TextButton"); botToggleBtn.Size = UDim2.new(1, 0, 0, 34); botToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 38); botToggleBtn.Text = "▶ Start Bot"; botToggleBtn.TextColor3 = Color3.new(1, 1, 1); botToggleBtn.Font = Enum.Font.GothamSemibold; botToggleBtn.TextSize = 11; botToggleBtn.BorderSizePixel = 0; botToggleBtn.Parent = beContent; addCorner(botToggleBtn, 6); local botToggleStroke = addStroke(botToggleBtn, 1, Color3.fromRGB(40, 40, 60))
botToggleBtn.Activated:Connect(function()
    Features.Bot.Enabled = not Features.Bot.Enabled
    if Features.Bot.Enabled then
        if #Features.Bot.Waypoints == 0 then Features.Bot.Enabled = false; return end
        if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = Features.Bot.SpeedEnabled and Features.Bot.Speed or 16 end end
        botToggleBtn.Text = "⏸ Stop Bot"; botToggleStroke.Color = Color3.fromRGB(60, 140, 60)
        removeLastWPToPlayerBeam()
        Features.Bot.CurrentWaypointIndex = 1; highlightWaypoint(Features.Bot.CurrentWaypointIndex)
        botConnections.Walk = RunService.Heartbeat:Connect(function()
            if not Features.Bot.Enabled then return end
            if not Player.Character then return end
            local root = Player.Character:FindFirstChild("HumanoidRootPart")
            local hum = Player.Character:FindFirstChild("Humanoid")
            if not root or not hum or hum.Health <= 0 then return end
            if #Features.Bot.Waypoints == 0 then stopBot(); return end
            local wp = Features.Bot.Waypoints[Features.Bot.CurrentWaypointIndex]
            if not wp or not wp.Part or not wp.Part.Parent then
                local found = false
                for _ = 1, #Features.Bot.Waypoints do
                    Features.Bot.CurrentWaypointIndex = Features.Bot.CurrentWaypointIndex + 1
                    if Features.Bot.CurrentWaypointIndex > #Features.Bot.Waypoints then Features.Bot.CurrentWaypointIndex = 1 end
                    local cw = Features.Bot.Waypoints[Features.Bot.CurrentWaypointIndex]
                    if cw and cw.Part and cw.Part.Parent then wp = cw; found = true; break end
                end
                if not found then stopBot(); return end
                highlightWaypoint(Features.Bot.CurrentWaypointIndex)
            end
            local targetPos = wp.Position
            local direction = targetPos - root.Position
            local distance = direction.Magnitude
            local directionUnit = direction.Unit
            
            local lookDir = Vector3.new(directionUnit.X, 0, directionUnit.Z)
            if lookDir.Magnitude > 0.1 then
                root.CFrame = CFrame.new(root.Position, root.Position + lookDir)
            end
            
            if distance > 3 then
                local speed = Features.Bot.SpeedEnabled and Features.Bot.Speed or 16
                root.Velocity = directionUnit * speed
                highlightWaypoint(Features.Bot.CurrentWaypointIndex)
            else
                if Features.Bot.JumpOnPoint then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                Features.Bot.CurrentWaypointIndex = Features.Bot.CurrentWaypointIndex + 1
                if Features.Bot.CurrentWaypointIndex > #Features.Bot.Waypoints then Features.Bot.CurrentWaypointIndex = 1 end
                highlightWaypoint(Features.Bot.CurrentWaypointIndex)
            end
        end)
    else
        botToggleBtn.Text = "▶ Start Bot"; botToggleStroke.Color = Color3.fromRGB(40, 40, 60)
        stopBot()
    end
end)

local BotButtonGui = Instance.new("ScreenGui"); BotButtonGui.Name = "BotButtonGui"; BotButtonGui.Parent = CoreGui; BotButtonGui.ResetOnSpawn = false
local BotButton = Instance.new("TextButton"); BotButton.Size = UDim2.new(0, 50, 0, 50); BotButton.Position = UDim2.new(0.02, 0, 0.35, -25); BotButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0); BotButton.Text = "🤖"; BotButton.TextColor3 = Color3.new(1, 1, 1); BotButton.Font = Enum.Font.GothamBold; BotButton.TextSize = 20; BotButton.BorderSizePixel = 0; BotButton.AutoButtonColor = false; BotButton.Visible = false; BotButton.Parent = BotButtonGui; addCorner(BotButton, 25); addRainbowStroke(BotButton, 2)
BotButton.Activated:Connect(function() BotEditorWindow.Visible = not BotEditorWindow.Visible end); makeDraggable(BotButton, BotButton)

addToggle(page5, layout5, "Edit Bot (Open Editor)", function(e) BotEditorWindow.Visible = e; BotButton.Visible = e; if not e then stopBot() else createLastWPToPlayerBeam() end end)
updateCanvas(page5, layout5); layout5:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page5, layout5) end)

-- ==================== WINDOW TOGGLE ====================
local isOpen = false
WhiteBtn.Activated:Connect(function() isOpen = not isOpen; Window.Visible = isOpen end)
CloseBtn.Activated:Connect(function() isOpen = false; Window.Visible = false end)

-- ==================== RGB ANIMATION ====================
local rgbHue = 0
RunService.RenderStepped:Connect(function(dt) rgbHue = rgbHue + dt * 0.4; if rgbHue > 1 then rgbHue = rgbHue - 1 end; local c = Color3.fromHSV(rgbHue, 1, 0.8); WindowStroke.Color = c; for _, b in pairs(extBorders) do b.BackgroundColor3 = c end end)

-- ==================== RESPAWN HANDLER ====================
Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Features.Speed.Enabled then local hum = char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = Features.Speed.Value end end
    if Features.Jump.Enabled then local hum = char:FindFirstChild("Humanoid"); if hum then hum.JumpPower = Features.Jump.Value end end
    if Features.ESP.Enabled or Features.ESP.HPBarOnly then refreshESP() end
    if autoJumpEnabled then startAutoJump() end
    if not Features.Bot.Enabled then createLastWPToPlayerBeam() end
end)

-- ==================== SELECT FIRST TAB ====================
TabPages[1].Page.Visible = true; TabBtns[1].BackgroundColor3 = Color3.fromRGB(60, 60, 80); TabBtns[1].TextColor3 = Color3.new(1, 1, 1)
