--[[
    WeteroScript v10.3 - FULL SCRIPT WITH OPEN CODER HITBOX
]]

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

pcall(function()
    if CoreGui:FindFirstChild("WeteroScript") then CoreGui.WeteroScript:Destroy() end
    if CoreGui:FindFirstChild("WeteroButton") then CoreGui.WeteroButton:Destroy() end
    if CoreGui:FindFirstChild("FlyBtn") then CoreGui.FlyBtn:Destroy() end
    if CoreGui:FindFirstChild("AdGui") then CoreGui.AdGui:Destroy() end
end)

repeat task.wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

-- ==================== ADVERTISEMENT GUI ====================
local AdGui = Instance.new("ScreenGui")
AdGui.Name = "AdGui"
AdGui.Parent = CoreGui
AdGui.ResetOnSpawn = false

local AdFrame = Instance.new("Frame")
AdFrame.Size = UDim2.new(0, 300, 0, 120)
AdFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
AdFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
AdFrame.BorderSizePixel = 0
AdFrame.Parent = AdGui

local AdCorner = Instance.new("UICorner")
AdCorner.CornerRadius = UDim.new(0, 8)
AdCorner.Parent = AdFrame

local AdTitle = Instance.new("TextLabel")
AdTitle.Size = UDim2.new(1, 0, 0, 25)
AdTitle.Position = UDim2.new(0, 0, 0, 10)
AdTitle.BackgroundTransparency = 1
AdTitle.Text = "WeteroScript"
AdTitle.TextColor3 = Color3.new(1, 1, 1)
AdTitle.Font = Enum.Font.GothamBold
AdTitle.TextSize = 18
AdTitle.Parent = AdFrame

local AdTG = Instance.new("TextLabel")
AdTG.Size = UDim2.new(1, 0, 0, 20)
AdTG.Position = UDim2.new(0, 0, 0, 40)
AdTG.BackgroundTransparency = 1
AdTG.Text = "t.me/WeteroScript"
AdTG.TextColor3 = Color3.fromRGB(100, 180, 255)
AdTG.Font = Enum.Font.Gotham
AdTG.TextSize = 14
AdTG.Parent = AdFrame

local AdClose = Instance.new("TextButton")
AdClose.Size = UDim2.new(0, 100, 0, 30)
AdClose.Position = UDim2.new(0.5, -50, 0, 70)
AdClose.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AdClose.Text = "Close (2.5s)"
AdClose.TextColor3 = Color3.new(1, 1, 1)
AdClose.Font = Enum.Font.Gotham
AdClose.TextSize = 13
AdClose.BorderSizePixel = 0
AdClose.Visible = false
AdClose.Parent = AdFrame
local AdCloseCorner = Instance.new("UICorner")
AdCloseCorner.CornerRadius = UDim.new(0, 4)
AdCloseCorner.Parent = AdClose

-- ==================== EXTERNAL BUTTON ====================
local ExtGui = Instance.new("ScreenGui")
ExtGui.Name = "WeteroButton"
ExtGui.Parent = CoreGui
ExtGui.ResetOnSpawn = false

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(0, 160, 0, 40)
BtnContainer.Position = UDim2.new(0.5, -80, 0.85, 0)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = ExtGui

local extBorders = {}
for i, data in ipairs({
    {Size = UDim2.new(1, 0, 0, 2), Pos = UDim2.new(0, 0, 0, 0)},
    {Size = UDim2.new(1, 0, 0, 2), Pos = UDim2.new(0, 0, 1, -2)},
    {Size = UDim2.new(0, 2, 1, 0), Pos = UDim2.new(0, 0, 0, 0)},
    {Size = UDim2.new(0, 2, 1, 0), Pos = UDim2.new(1, -2, 0, 0)}
}) do
    local b = Instance.new("Frame")
    b.Size = data.Size
    b.Position = data.Pos
    b.BackgroundColor3 = Color3.new(1, 1, 1)
    b.BorderSizePixel = 0
    b.Parent = BtnContainer
    extBorders[i] = b
end

local WhiteBtn = Instance.new("TextButton")
WhiteBtn.Size = UDim2.new(1, -4, 1, -4)
WhiteBtn.Position = UDim2.new(0, 2, 0, 2)
WhiteBtn.BackgroundColor3 = Color3.new(1, 1, 1)
WhiteBtn.Text = "WeteroScript"
WhiteBtn.TextColor3 = Color3.new(0, 0, 0)
WhiteBtn.Font = Enum.Font.GothamBold
WhiteBtn.TextSize = 15
WhiteBtn.BorderSizePixel = 0
WhiteBtn.AutoButtonColor = false
WhiteBtn.Parent = BtnContainer

BtnContainer.Visible = false

AdClose.Activated:Connect(function()
    AdGui:Destroy()
    BtnContainer.Visible = true
end)

task.delay(2.5, function()
    if AdClose then
        AdClose.Visible = true
        AdClose.Text = "Close"
    end
end)

-- Draggable external button
local btnDragging = false
local btnDragStart = nil
local btnStartPos = nil

WhiteBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = BtnContainer.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        BtnContainer.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)

WhiteBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = false
    end
end)

-- ==================== MAIN GUI ====================
local Gui = Instance.new("ScreenGui")
Gui.Name = "WeteroScript"
Gui.Parent = CoreGui
Gui.ResetOnSpawn = false

local Window = Instance.new("Frame")
Window.Size = UDim2.new(0, 420, 0, 350)
Window.Position = UDim2.new(0.5, -210, 0.5, -175)
Window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Window.BorderSizePixel = 0
Window.Visible = false
Window.Parent = Gui

local borders = {}
for i, data in ipairs({
    {Size = UDim2.new(1, 0, 0, 2), Pos = UDim2.new(0, 0, 0, 0)},
    {Size = UDim2.new(1, 0, 0, 2), Pos = UDim2.new(0, 0, 1, -2)},
    {Size = UDim2.new(0, 2, 1, 0), Pos = UDim2.new(0, 0, 0, 0)},
    {Size = UDim2.new(0, 2, 1, 0), Pos = UDim2.new(1, -2, 0, 0)}
}) do
    local b = Instance.new("Frame")
    b.Size = data.Size
    b.Position = data.Pos
    b.BackgroundColor3 = Color3.new(1, 1, 1)
    b.BorderSizePixel = 0
    b.Parent = Window
    borders[i] = b
end

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -4, 0, 30)
TopBar.Position = UDim2.new(0, 2, 0, 2)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = Window

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "WeteroScript v10.3"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -30, 0, 1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local dragging = false
local dragStart = Vector2.new()
local winStart = Vector2.new()
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        winStart = Window.AbsolutePosition
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(0, winStart.X + delta.X, 0, winStart.Y + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local TabBtns = {}
local TabPages = {}

local function createTab(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 26)
    btn.Position = UDim2.new(0, 4 + (index-1)*104, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.Parent = Window

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -8, 1, -66)
    page.Position = UDim2.new(0, 4, 0, 62)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = Window

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = page

    btn.Activated:Connect(function()
        for _, p in pairs(TabPages) do p.Page.Visible = false end
        for _, b in pairs(TabBtns) do b.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)

    table.insert(TabBtns, btn)
    TabPages[index] = {Page = page, Layout = layout}
    return page, layout
end

local function addButton(page, layout, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = page
    btn.Activated:Connect(callback)
    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end)
    return btn
end

local function addToggle(page, layout, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.Parent = page
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -46, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(1, -38, 0.5, -7)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.BorderSizePixel = 0
    dot.Parent = container
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = container
    local enabled = false
    click.Activated:Connect(function()
        enabled = not enabled
        dot.BackgroundColor3 = enabled and Color3.fromRGB(80, 200, 80) or Color3.new(1, 1, 1)
        callback(enabled)
    end)
    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end)
    return container
end

local function addTextBox(page, layout, label, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.Parent = page
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 14)
    lbl.Position = UDim2.new(0, 8, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -16, 0, 20)
    inputBg.Position = UDim2.new(0, 8, 0, 18)
    inputBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    inputBg.BorderSizePixel = 0
    inputBg.Parent = container
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -8, 1, 0)
    tb.Position = UDim2.new(0, 4, 0, 0)
    tb.BackgroundTransparency = 1
    tb.PlaceholderText = placeholder
    tb.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    tb.Text = ""
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 11
    tb.Parent = inputBg
    tb.FocusLost:Connect(function() callback(tb.Text) end)
    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end)
    return tb
end

local function addColorPicker(page, layout, label, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 56)
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderSizePixel = 0
    container.Parent = page
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 14)
    lbl.Position = UDim2.new(0, 8, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 18, 0, 18)
    preview.Position = UDim2.new(0, 8, 0, 18)
    preview.BackgroundColor3 = defaultColor
    preview.BorderSizePixel = 0
    preview.Parent = container
    local function makeInput(x, ph, phColor, defText)
        local inp = Instance.new("TextBox")
        inp.Size = UDim2.new(0, 36, 0, 16)
        inp.Position = UDim2.new(0, x, 0, 19)
        inp.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        inp.BorderSizePixel = 0
        inp.PlaceholderText = ph
        inp.PlaceholderColor3 = phColor
        inp.Text = defText
        inp.TextColor3 = Color3.new(1, 1, 1)
        inp.Font = Enum.Font.Gotham
        inp.TextSize = 10
        inp.Parent = container
        return inp
    end
    local rInput = makeInput(32, "R", Color3.fromRGB(255, 80, 80), tostring(math.floor(defaultColor.R * 255)))
    local gInput = makeInput(72, "G", Color3.fromRGB(80, 255, 80), tostring(math.floor(defaultColor.G * 255)))
    local bInput = makeInput(112, "B", Color3.fromRGB(80, 80, 255), tostring(math.floor(defaultColor.B * 255)))
    local function updateColor()
        local r = math.clamp(tonumber(rInput.Text) or 255, 0, 255)
        local g = math.clamp(tonumber(gInput.Text) or 255, 0, 255)
        local b = math.clamp(tonumber(bInput.Text) or 255, 0, 255)
        local color = Color3.fromRGB(r, g, b)
        preview.BackgroundColor3 = color
        callback(color)
    end
    rInput.FocusLost:Connect(updateColor)
    gInput.FocusLost:Connect(updateColor)
    bInput.FocusLost:Connect(updateColor)
    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end)
    return container
end

-- ==================== CREATE TABS ====================
local page1, layout1 = createTab("Move", 1)
local page2, layout2 = createTab("ESP", 2)
local page3, layout3 = createTab("Different", 3)
local page4, layout4 = createTab("Fly", 4)

-- ==================== FEATURES ====================
local Features = {
    Speed = {Enabled = false, Value = 16},
    Jump = {Enabled = false, Value = 50},
    AutoJump = false,
    ESP = {Enabled = false, Color = Color3.new(1, 0, 0), HPBar = false},
    AntiFling = false,
    Fly = {Enabled = false, Speed = 50},
    Noclip = false,
    Hitbox = {Enabled = false, Size = 5},
    Freezecam = false,
    SpinSpeed = 50,
    Ghost = false,
    AnimSpeed = 1
}
local connections = {}
local espStorage = {}
local hitboxStorage = {}

-- ==================== STOP SCRIPT FUNCTION ====================
local function stopAllFunctions()
    for _, conn in pairs(connections) do
        if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
    end
    connections = {}
    autoJumpEnabled = false
    if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect(); autoJumpHeartbeat = nil end
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0; part.CanCollide = true end
        end
    end
    for _, data in pairs(espStorage) do if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end end
    espStorage = {}
    -- Restore hitboxes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true; hrp.Massless = false end
        end
    end
    hitboxStorage = {}
    pcall(function() if Gui then Gui:Destroy() end end)
    pcall(function() if ExtGui then ExtGui:Destroy() end end)
    pcall(function() if FlyBtnGui then FlyBtnGui:Destroy() end end)
end

-- ==================== MOBILE FLY BUTTON ====================
local FlyBtnGui = Instance.new("ScreenGui")
FlyBtnGui.Name = "FlyBtn"
FlyBtnGui.Parent = CoreGui
FlyBtnGui.Enabled = false
FlyBtnGui.ResetOnSpawn = false

local FlyForwardBtn = Instance.new("TextButton")
FlyForwardBtn.Size = UDim2.new(0, 70, 0, 70)
FlyForwardBtn.Position = UDim2.new(0.85, -35, 0.55, -35)
FlyForwardBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyForwardBtn.Text = "W"
FlyForwardBtn.TextColor3 = Color3.new(1, 1, 1)
FlyForwardBtn.Font = Enum.Font.GothamBold
FlyForwardBtn.TextSize = 24
FlyForwardBtn.BorderSizePixel = 0
FlyForwardBtn.AutoButtonColor = false
FlyForwardBtn.ZIndex = 100
FlyForwardBtn.Parent = FlyBtnGui
local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(1, 0)
FlyCorner.Parent = FlyForwardBtn

local flyButtonPressed = false
FlyForwardBtn.MouseButton1Down:Connect(function() flyButtonPressed = true; FlyForwardBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) end)
FlyForwardBtn.MouseButton1Up:Connect(function() flyButtonPressed = false; FlyForwardBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)
FlyForwardBtn.MouseLeave:Connect(function() flyButtonPressed = false; FlyForwardBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end)

-- ==================== AUTO JUMP ====================
local autoJumpEnabled = false
local autoJumpHeartbeat = nil

local function startAutoJump()
    if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect() end
    autoJumpHeartbeat = RunService.Heartbeat:Connect(function()
        if not autoJumpEnabled then return end
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then
            local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -3.5, 0))
            if rayResult then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

-- ==================== MOVEMENT TAB ====================
addTextBox(page1, layout1, "Speed Value", "16", function(val)
    Features.Speed.Value = tonumber(val) or 16
    if Features.Speed.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = Features.Speed.Value end end
end)
addToggle(page1, layout1, "Speed Enabled", function(enabled)
    Features.Speed.Enabled = enabled
    if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = enabled and Features.Speed.Value or 16 end end
end)
addTextBox(page1, layout1, "Jump Power", "50", function(val)
    Features.Jump.Value = tonumber(val) or 50
    if Features.Jump.Enabled and Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then hum.JumpPower = Features.Jump.Value end end
end)
addToggle(page1, layout1, "Jump Enabled", function(enabled)
    Features.Jump.Enabled = enabled
    if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then hum.JumpPower = enabled and Features.Jump.Value or 50 end end
end)
addToggle(page1, layout1, "Auto Jump", function(enabled)
    autoJumpEnabled = enabled
    if enabled then startAutoJump() else if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect() end end
end)
addToggle(page1, layout1, "Noclip", function(enabled)
    Features.Noclip = enabled
    if connections.Noclip then connections.Noclip:Disconnect() end
    if enabled then connections.Noclip = RunService.Stepped:Connect(function() if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
    else if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end
end)
addButton(page1, layout1, "Rejoin Server", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1, 0, 0, 30)
stopBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
stopBtn.Text = "STOP SCRIPT"
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 12
stopBtn.BorderSizePixel = 0
stopBtn.Parent = page1
stopBtn.Activated:Connect(stopAllFunctions)
page1.CanvasSize = UDim2.new(0, 0, 0, layout1.AbsoluteContentSize.Y + 4)
layout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page1.CanvasSize = UDim2.new(0, 0, 0, layout1.AbsoluteContentSize.Y + 4) end)

-- ==================== ESP TAB ====================
local function refreshESP()
    for char, data in pairs(espStorage) do if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end if data.HPConnection then data.HPConnection:Disconnect() end end
    espStorage = {}
    if not Features.ESP.Enabled then return end
    local function addESP(char)
        if espStorage[char] then return end
        local highlight = Instance.new("Highlight") highlight.FillTransparency = 0.85 highlight.OutlineColor = Features.ESP.Color highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlight.Parent = char
        espStorage[char] = {Highlight = highlight}
        if Features.ESP.HPBar then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local bb = Instance.new("BillboardGui") bb.StudsOffset = Vector3.new(0,3,0) bb.AlwaysOnTop = true bb.Size = UDim2.new(0,55,0,12) bb.Parent = char
                local nl = Instance.new("TextLabel") nl.Size = UDim2.new(1,0,0,7) nl.BackgroundTransparency = 1 nl.Text = char.Name nl.TextColor3 = Color3.new(1,1,1) nl.Font = Enum.Font.Gotham nl.TextSize = 7 nl.Parent = bb
                local bg = Instance.new("Frame") bg.Size = UDim2.new(1,0,0,3) bg.Position = UDim2.new(0,0,0,8) bg.BackgroundColor3 = Color3.new(0,0,0) bg.BorderSizePixel = 0 bg.Parent = bb
                local bar = Instance.new("Frame") bar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0) bar.BackgroundColor3 = Color3.new(0,1,0) bar.BorderSizePixel = 0 bar.Parent = bg
                espStorage[char].Billboard = bb
                espStorage[char].HPConnection = hum:GetPropertyChangedSignal("Health"):Connect(function() if bar and bar.Parent then bar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0) end end)
            end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player and plr.Character then addESP(plr.Character) end end
    if connections.ESP then connections.ESP:Disconnect() end
    connections.ESP = RunService.Stepped:Connect(function() for char, data in pairs(espStorage) do if not char.Parent then if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end if data.HPConnection then data.HPConnection:Disconnect() end espStorage[char] = nil end end end)
end

addToggle(page2, layout2, "Player ESP", function(enabled)
    Features.ESP.Enabled = enabled
    if enabled then refreshESP() else for char, data in pairs(espStorage) do if data.Highlight then data.Highlight:Destroy() end if data.Billboard then data.Billboard:Destroy() end end espStorage = {} if connections.ESP then connections.ESP:Disconnect() end end
end)
addColorPicker(page2, layout2, "ESP Color", Color3.new(1, 0, 0), function(color) Features.ESP.Color = color for _, data in pairs(espStorage) do if data.Highlight then data.Highlight.OutlineColor = color end end end)
addToggle(page2, layout2, "HP Bar", function(enabled) Features.ESP.HPBar = enabled if Features.ESP.Enabled then refreshESP() end end)

-- ==================== HITBOX CHANGER (FROM OPEN CODER) ====================
addTextBox(page2, layout2, "Hitbox Size", "5", function(val) Features.Hitbox.Size = tonumber(val) or 5 end)

addToggle(page2, layout2, "Hitbox Changer", function(enabled)
    Features.Hitbox.Enabled = enabled
    if connections.Hitbox then connections.Hitbox:Disconnect(); connections.Hitbox = nil end
    
    if enabled then
        connections.Hitbox = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(Features.Hitbox.Size, Features.Hitbox.Size, Features.Hitbox.Size)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                        hrp.Massless = true
                    end
                end
            end
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true; hrp.Massless = false end
            end
        end
    end
    return enabled
end)

-- ==================== DIFFERENT TAB ====================
addToggle(page3, layout3, "Anti-Fling", function(enabled)
    Features.AntiFling = enabled
    if connections.AntiFling then connections.AntiFling:Disconnect() end
    if enabled then connections.AntiFling = RunService.Heartbeat:Connect(function() if Player.Character then local r = Player.Character:FindFirstChild("HumanoidRootPart") local h = Player.Character:FindFirstChild("Humanoid") if r and h and (r.Velocity.Magnitude > 200 or r.AssemblyLinearVelocity.Magnitude > 200) then r.Velocity = Vector3.new(0,r.Velocity.Y,0) r.AssemblyLinearVelocity = Vector3.new(0,0,0) h.PlatformStand = false end end end) end
end)
addToggle(page3, layout3, "Freezecam", function(enabled)
    Features.Freezecam = enabled
    if connections.Freezecam then connections.Freezecam:Disconnect() end
    if enabled then local cam = workspace.CurrentCamera if cam then local fcf = cam.CFrame connections.Freezecam = RunService.RenderStepped:Connect(function() cam.CFrame = fcf end) end end
end)
addToggle(page3, layout3, "Freeze Player", function(enabled)
    if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart") if root then root.Anchored = enabled end end
end)
addButton(page3, layout3, "Explode", function()
    if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart") local hum = Player.Character:FindFirstChild("Humanoid") if root then local sh = hum and hum.Health or 100 local exp = Instance.new("Explosion") exp.Position = root.Position exp.BlastPressure = 500000 exp.BlastRadius = 20 exp.DestroyJointRadiusPercent = 0 exp.Parent = Workspace task.wait(0.1) if hum and hum.Parent then hum.Health = sh end end end
end)
addTextBox(page3, layout3, "Spin Speed", "50", function(val) Features.SpinSpeed = math.clamp(tonumber(val) or 50, 1, 500) if connections.Spin and connections.Spin.Parent then connections.Spin.AngularVelocity = Vector3.new(0, Features.SpinSpeed, 0) end end)
addToggle(page3, layout3, "Spin", function(enabled)
    if connections.Spin and connections.Spin.Parent then connections.Spin:Destroy() end
    if enabled then local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") if root then local bav = Instance.new("BodyAngularVelocity") bav.AngularVelocity = Vector3.new(0, Features.SpinSpeed, 0) bav.MaxTorque = Vector3.new(0,9999999,0) bav.P = 100000 bav.Parent = root connections.Spin = bav end end
end)
addToggle(page3, layout3, "Ghost", function(enabled)
    Features.Ghost = enabled
    if Player.Character then for _, part in pairs(Player.Character:GetDescendants()) do if part:IsA("BasePart") then part.Transparency = enabled and 0.7 or 0 part.CanCollide = not enabled end end end
end)
addTextBox(page3, layout3, "Anim Speed", "1", function(val)
    Features.AnimSpeed = math.clamp(tonumber(val) or 1, 0.1, 10)
    if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then local animator = hum:FindFirstChild("Animator") if animator then for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(Features.AnimSpeed) end end end end
end)
addToggle(page3, layout3, "Anim Speed Enabled", function(enabled)
    if enabled then if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then local animator = hum:FindFirstChild("Animator") if not animator then animator = Instance.new("Animator") animator.Parent = hum end connections.AnimSpeed = RunService.Heartbeat:Connect(function() for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(Features.AnimSpeed) end end) end end
    else if connections.AnimSpeed then connections.AnimSpeed:Disconnect() end end
end)

-- ==================== FLY TAB ====================
addTextBox(page4, layout4, "Fly Speed", "50", function(val) Features.Fly.Speed = tonumber(val) or 50 end)
addToggle(page4, layout4, "Fly (W - Forward)", function(enabled)
    Features.Fly.Enabled = enabled
    FlyBtnGui.Enabled = enabled
    if connections.Fly then connections.Fly:Disconnect() end
    if connections.FlyObjects then for _, obj in pairs(connections.FlyObjects) do if obj and obj.Parent then obj:Destroy() end end end
    if enabled then
        local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum.PlatformStand = true
            local bodyVel = Instance.new("BodyVelocity") bodyVel.MaxForce = Vector3.new(9999999,9999999,9999999) bodyVel.Velocity = Vector3.new(0,0,0) bodyVel.P = 1000 bodyVel.Parent = root
            local bodyGyro = Instance.new("BodyGyro") bodyGyro.MaxTorque = Vector3.new(9999999,9999999,9999999) bodyGyro.P = 10000 bodyGyro.CFrame = root.CFrame bodyGyro.Parent = root
            connections.Fly = RunService.Heartbeat:Connect(function()
                if not root or not root.Parent then return end
                local moveDir = Vector3.new()
                local cam = workspace.CurrentCamera
                if UserInputService:IsKeyDown(Enum.KeyCode.W) or flyButtonPressed then moveDir += cam.CFrame.LookVector end
                bodyVel.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * Features.Fly.Speed or Vector3.new(0,0,0)
                bodyGyro.CFrame = cam.CFrame
            end)
            connections.FlyObjects = {bodyVel, bodyGyro}
        end
    else if Player.Character then local hum = Player.Character:FindFirstChild("Humanoid") if hum then hum.PlatformStand = false end end end
end)

-- ==================== WINDOW TOGGLE ====================
local isOpen = false
WhiteBtn.Activated:Connect(function() isOpen = not isOpen Window.Visible = isOpen end)
CloseBtn.Activated:Connect(function() isOpen = false Window.Visible = false end)

-- ==================== RAINBOW ====================
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = hue + dt * 0.3 if hue > 1 then hue = hue - 1 end
    local c = Color3.fromHSV(hue, 1, 0.8)
    for _, b in pairs(borders) do b.BackgroundColor3 = c end
    for _, b in pairs(extBorders) do b.BackgroundColor3 = c end
end)

-- ==================== RESPAWN ====================
Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Features.Speed.Enabled then local hum = char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = Features.Speed.Value end end
    if Features.Jump.Enabled then local hum = char:FindFirstChild("Humanoid") if hum then hum.JumpPower = Features.Jump.Value end end
    if Features.ESP.Enabled then refreshESP() end
    if autoJumpEnabled then startAutoJump() end
    if Features.Ghost then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.Transparency = 0.7 part.CanCollide = false end end end
end)

-- ==================== SELECT FIRST TAB ====================
TabPages[1].Page.Visible = true
TabBtns[1].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
