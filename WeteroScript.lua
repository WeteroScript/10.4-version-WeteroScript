-- WeteroScript v1.01
-- Open Coder MOD v1.3 | FIXED BOT MOVEMENT + ROTATION

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ==================== FEATURES STATE ====================
local Features = {
    AntiFling = false,
    WalkFling = false,
    Spin = {Enabled = false, Speed = 50},
    AnimSpeed = {Enabled = false, Speed = 1},
    Freezecam = false,
    FreezePlayer = false,
    MobileFly = {Enabled = false, Speed = 50},
    ESP = {Enabled = false, Color = Color3.fromRGB(255, 0, 0)},
    HPBar = false,
    Hitbox = {Enabled = false, Size = 5},
    Mimic = {Enabled = false, Target = nil, FollowOffset = 5, FollowDelay = 0, RandomTarget = false},
    Bot = {Enabled = false, Speed = 16, SpeedEnabled = false, Waypoints = {}, CurrentWaypointIndex = 0, JumpOnPoint = true, ViewLines = false}
}

local connections = {}
local espStorage = {}
local botConnections = {}
local flyActive = false
local flyHeartbeat = nil
local rainbowStrokes = {}
local autoJumpEnabled = false
local autoJumpHeartbeat = nil
local allBeams = {}
local lastWPToPlayerBeam = nil
local botWaypointParts = {}

-- ==================== CLEANUP FUNCTIONS ====================
local function resetAllHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            for _, p in pairs(plr.Character:GetChildren()) do
                if p:IsA("BasePart") and p.Name == "HumanoidRootPart" then
                    p.Size = Vector3.new(2, 2, 1)
                    p.Transparency = 0
                    p.CanCollide = true
                end
            end
        end
    end
end

local function registerBeam(beam)
    table.insert(allBeams, beam)
end

local function destroyBeam(beam)
    if beam and beam.Parent then beam:Destroy() end
    for i, b in pairs(allBeams) do
        if b == beam then allBeams[i] = nil; break end
    end
end

local function removeLastWPToPlayerBeam()
    if lastWPToPlayerBeam and lastWPToPlayerBeam.Parent then
        destroyBeam(lastWPToPlayerBeam)
    end
    lastWPToPlayerBeam = nil
end

local function createLastWPToPlayerBeam()
    removeLastWPToPlayerBeam()
    if not Player.Character then return end
    local root = Player.Character:FindFirstChild("HumanoidRootPart")
    if not root or #Features.Bot.Waypoints == 0 then return end
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

local function highlightWaypoint(index)
    for i, wp in pairs(Features.Bot.Waypoints) do
        if wp.Part and wp.Part.Parent then
            if i == index then
                wp.Part.Color = Color3.fromRGB(0, 255, 0)
                for _, child in pairs(wp.Part:GetChildren()) do
                    if child:IsA("PointLight") then child.Color = Color3.fromRGB(0, 255, 0) end
                end
            else
                wp.Part.Color = Color3.fromRGB(60, 100, 255)
                for _, child in pairs(wp.Part:GetChildren()) do
                    if child:IsA("PointLight") then child.Color = Color3.fromRGB(60, 100, 255) end
                end
            end
        end
    end
end

local function stopBot()
    Features.Bot.Enabled = false
    Features.Bot.CurrentWaypointIndex = 0
    if botConnections.Walk then botConnections.Walk:Disconnect(); botConnections.Walk = nil end
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    highlightWaypoint(0)
    createLastWPToPlayerBeam()
end

local function stopMimic()
    Features.Mimic.Enabled = false
    if connections.Mimic then connections.Mimic:Disconnect(); connections.Mimic = nil end
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

local function stopMobileFly()
    flyActive = false
    if flyHeartbeat then flyHeartbeat:Disconnect(); flyHeartbeat = nil end
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- ==================== BOT MOVEMENT WITH ROTATION ====================
local function startBotMovement()
    if #Features.Bot.Waypoints == 0 then
        stopBot()
        return
    end
    
    local currentIdx = 1
    local jumpedOnCurrent = false
    
    if botConnections.Walk then
        botConnections.Walk:Disconnect()
    end
    
    botConnections.Walk = RunService.Heartbeat:Connect(function()
        if not Features.Bot.Enabled then return end
        if not Player.Character then return end
        
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character:FindFirstChild("Humanoid")
        
        if not root or not hum or hum.Health <= 0 then return end
        if #Features.Bot.Waypoints == 0 then stopBot(); return end
        
        local wp = Features.Bot.Waypoints[currentIdx]
        if not wp or not wp.Part or not wp.Part.Parent then
            local found = false
            for _ = 1, #Features.Bot.Waypoints do
                currentIdx = currentIdx + 1
                if currentIdx > #Features.Bot.Waypoints then currentIdx = 1 end
                local cw = Features.Bot.Waypoints[currentIdx]
                if cw and cw.Part and cw.Part.Parent then
                    wp = cw
                    found = true
                    break
                end
            end
            if not found then stopBot(); return end
            jumpedOnCurrent = false
            highlightWaypoint(currentIdx)
        end
        
        local targetPos = wp.Position
        local distance = (root.Position - targetPos).Magnitude
        
        -- ПОВОРОТ К ТОЧКЕ
        local direction = (targetPos - root.Position).Unit
        local lookAtCFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        root.CFrame = CFrame.new(root.Position, lookAtCFrame.LookVector)
        
        if distance > 4 then
            jumpedOnCurrent = false
            
            -- ДВИЖЕНИЕ ВПЕРЁД
            local moveDir = (targetPos - root.Position).Unit
            local moveDistance = math.min((Features.Bot.SpeedEnabled and Features.Bot.Speed or 16) * 0.05, distance)
            root.CFrame = root.CFrame + (moveDir * moveDistance)
            
            -- АКТИВАЦИЯ АНИМАЦИИ ХОДЬБЫ
            hum:Move(moveDir, false)
            hum.WalkSpeed = Features.Bot.SpeedEnabled and Features.Bot.Speed or 16
            
            -- ПРЫЖОК ПРИ ПРЕПЯТСТВИИ
            local rayOrigin = root.Position + Vector3.new(0, 1, 0)
            local raycastResult = Workspace:Raycast(rayOrigin, moveDir * 3)
            if raycastResult and raycastResult.Instance and raycastResult.Instance.CanCollide then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        else
            -- ДОСТИГЛИ ТОЧКИ
            if Features.Bot.JumpOnPoint and not jumpedOnCurrent then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                jumpedOnCurrent = true
            end
            
            -- ПЕРЕХОД К СЛЕДУЮЩЕЙ ТОЧКЕ
            currentIdx = currentIdx + 1
            if currentIdx > #Features.Bot.Waypoints then
                currentIdx = 1
            end
            jumpedOnCurrent = false
            Features.Bot.CurrentWaypointIndex = currentIdx
            highlightWaypoint(currentIdx)
        end
    end)
end

-- ==================== GUI CREATION ====================
local WeteroScript = Instance.new("ScreenGui")
WeteroScript.Name = "WeteroScript"
WeteroScript.Parent = CoreGui
WeteroScript.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WeteroScript.ResetOnSpawn = false

-- Draggable Header Button
local HeaderButton = Instance.new("TextButton")
HeaderButton.Name = "HeaderButton"
HeaderButton.Parent = WeteroScript
HeaderButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HeaderButton.BorderSizePixel = 0
HeaderButton.Position = UDim2.new(0.5, -100, 0.5, -150)
HeaderButton.Size = UDim2.new(0, 200, 0, 40)
HeaderButton.Font = Enum.Font.SourceSansBold
HeaderButton.Text = "WeteroScript v1.01"
HeaderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderButton.TextSize = 16
HeaderButton.AutoButtonColor = false
HeaderButton.ZIndex = 100

local HeaderBorder = Instance.new("Frame")
HeaderBorder.Name = "HeaderBorder"
HeaderBorder.Parent = HeaderButton
HeaderBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderBorder.BorderSizePixel = 0
HeaderBorder.Size = UDim2.new(1, 4, 1, 4)
HeaderBorder.Position = UDim2.new(0, -2, 0, -2)
HeaderBorder.ZIndex = 99

local HeaderInner = Instance.new("Frame")
HeaderInner.Name = "HeaderInner"
HeaderInner.Parent = HeaderBorder
HeaderInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HeaderInner.BorderSizePixel = 0
HeaderInner.Size = UDim2.new(1, -4, 1, -4)
HeaderInner.Position = UDim2.new(0, 2, 0, 2)
HeaderInner.ZIndex = 100

local HeaderText = Instance.new("TextLabel")
HeaderText.Name = "HeaderText"
HeaderText.Parent = HeaderInner
HeaderText.BackgroundTransparency = 1
HeaderText.Size = UDim2.new(1, 0, 1, 0)
HeaderText.Font = Enum.Font.SourceSansBold
HeaderText.Text = "WeteroScript v1.01"
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.TextSize = 16
HeaderText.ZIndex = 101

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = WeteroScript
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -108)
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Visible = false
MainFrame.ZIndex = 100
MainFrame.ClipsDescendants = true

local MainBorder = Instance.new("Frame")
MainBorder.Name = "MainBorder"
MainBorder.Parent = MainFrame
MainBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainBorder.BorderSizePixel = 0
MainBorder.Size = UDim2.new(1, 6, 1, 6)
MainBorder.Position = UDim2.new(0, -3, 0, -3)
MainBorder.ZIndex = 99

local MainInner = Instance.new("Frame")
MainInner.Name = "MainInner"
MainInner.Parent = MainBorder
MainInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainInner.BorderSizePixel = 0
MainInner.Size = UDim2.new(1, -6, 1, -6)
MainInner.Position = UDim2.new(0, 3, 0, 3)
MainInner.ZIndex = 100
MainInner.ClipsDescendants = true

-- Tab Buttons
local Tabs = {"Move", "Different", "ESP", "Mimic", "Bot"}
local TabButtons = {}
local TabPages = {}

for i, tabName in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "Tab"
    TabBtn.Parent = MainInner
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Position = UDim2.new(0, 5 + (i-1)*58, 0, 5)
    TabBtn.Size = UDim2.new(0, 55, 0, 22)
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.TextSize = 13
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 101
    TabBtn.BackgroundTransparency = 0

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = tabName .. "Page"
    TabPage.Parent = MainInner
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.Position = UDim2.new(0, 5, 0, 32)
    TabPage.Size = UDim2.new(1, -10, 1, -37)
    TabPage.Visible = (i == 1)
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.ZIndex = 101
    TabPage.ScrollingEnabled = true
    TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = TabPage
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 4)

    TabButtons[i] = TabBtn
    TabPages[i] = TabPage

    TabBtn.MouseButton1Click:Connect(function()
        for _, page in ipairs(TabPages) do
            page.Visible = false
        end
        TabPage.Visible = true
    end)
end

-- Helper Functions
local function CreateToggleWithInput(parent, text, hasInput, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Name = text .. "Frame"
    Frame.Parent = parent
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.ZIndex = 102

    local Toggle = Instance.new("TextButton")
    Toggle.Name = text .. "Toggle"
    Toggle.Parent = Frame
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Toggle.BorderSizePixel = 0
    Toggle.Position = UDim2.new(1, -44, 0, 2)
    Toggle.Size = UDim2.new(0, 40, 0, 20)
    Toggle.Font = Enum.Font.SourceSans
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 12
    Toggle.AutoButtonColor = false
    Toggle.ZIndex = 103

    local Label = Instance.new("TextLabel")
    Label.Name = text .. "Label"
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.Size = UDim2.new(0, 85, 0, 24)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 103

    local InputBox = nil
    if hasInput then
        InputBox = Instance.new("TextBox")
        InputBox.Name = text .. "Input"
        InputBox.Parent = Frame
        InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        InputBox.BorderSizePixel = 0
        InputBox.Position = UDim2.new(0, 92, 0, 2)
        InputBox.Size = UDim2.new(0, 60, 0, 20)
        InputBox.Font = Enum.Font.SourceSans
        InputBox.PlaceholderText = placeholder or ""
        InputBox.Text = ""
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.TextSize = 12
        InputBox.ZIndex = 103
    end

    local toggled = false
    Toggle.MouseButton1Click:Connect(function()
        toggled = not toggled
        Toggle.Text = toggled and "ON" or "OFF"
        Toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        if callback then callback(toggled, InputBox and InputBox.Text) end
    end)
    
    if InputBox then
        InputBox.FocusLost:Connect(function()
            if callback and toggled then callback(toggled, InputBox.Text) end
        end)
    end

    return Frame, Toggle, InputBox
end

local function CreateToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Name = text .. "Frame"
    Frame.Parent = parent
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 28)
    Frame.ZIndex = 102

    local Toggle = Instance.new("TextButton")
    Toggle.Name = text .. "Toggle"
    Toggle.Parent = Frame
    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Toggle.BorderSizePixel = 0
    Toggle.Position = UDim2.new(1, -44, 0, 2)
    Toggle.Size = UDim2.new(0, 40, 0, 20)
    Toggle.Font = Enum.Font.SourceSans
    Toggle.Text = "OFF"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 12
    Toggle.AutoButtonColor = false
    Toggle.ZIndex = 103

    local Label = Instance.new("TextLabel")
    Label.Name = text .. "Label"
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 4, 0, 0)
    Label.Size = UDim2.new(0, 85, 0, 24)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 103

    local toggled = false
    Toggle.MouseButton1Click:Connect(function()
        toggled = not toggled
        Toggle.Text = toggled and "ON" or "OFF"
        Toggle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        if callback then callback(toggled) end
    end)

    return Frame, Toggle
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BorderSizePixel = 0
    Btn.Size = UDim2.new(1, 0, 0, 24)
    Btn.Font = Enum.Font.SourceSans
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.AutoButtonColor = false
    Btn.ZIndex = 103
    if callback then Btn.MouseButton1Click:Connect(callback) end
    return Btn
end

local function CreateLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Font = Enum.Font.SourceSans
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 103
    return Label
end

-- ==================== POPULATE TABS ====================

-- MOVE TAB
CreateToggle(TabPages[1], "Anti-Fling", function(e) Features.AntiFling = e end)
CreateToggle(TabPages[1], "WalkFling", function(e) Features.WalkFling = e end)
CreateToggleWithInput(TabPages[1], "Spin", true, "50", function(e, val) Features.Spin.Enabled = e; Features.Spin.Speed = tonumber(val) or 50 end)
CreateToggleWithInput(TabPages[1], "Anim Speed", true, "1", function(e, val) Features.AnimSpeed.Enabled = e; Features.AnimSpeed.Speed = tonumber(val) or 1 end)
CreateToggle(TabPages[1], "Freezecam", function(e) Features.Freezecam = e end)
CreateToggle(TabPages[1], "Freezeplayer", function(e) Features.FreezePlayer = e; if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart"); if root then root.Anchored = e end end end)
CreateToggleWithInput(TabPages[1], "MobileFly", true, "50", function(e, val) Features.MobileFly.Enabled = e; Features.MobileFly.Speed = tonumber(val) or 50; if not e then stopMobileFly() end end)

-- ESP TAB
CreateToggle(TabPages[3], "ESP", function(e) Features.ESP.Enabled = e end)
CreateToggle(TabPages[3], "HP BAR", function(e) Features.HPBar = e end)
CreateToggleWithInput(TabPages[3], "HitBoxChanger", true, "5", function(e, val) Features.Hitbox.Enabled = e; Features.Hitbox.Size = tonumber(val) or 5; if not e then resetAllHitboxes() end end)

CreateButton(TabPages[3], "Color Palette", function() end)

-- MIMIC TAB
CreateToggle(TabPages[4], "Start Mimic", function(e) 
    Features.Mimic.Enabled = e
    MimicButton.Visible = e
    MimicMenu.Visible = e
    if not e then stopMimic() end
end)
CreateToggleWithInput(TabPages[4], "Follow offset", true, "5", function(e, val) Features.Mimic.FollowOffset = tonumber(val) or 5 end)
CreateToggleWithInput(TabPages[4], "Follow delay", true, "0", function(e, val) Features.Mimic.FollowDelay = tonumber(val) or 0 end)
CreateToggle(TabPages[4], "Random Target", function(e) Features.Mimic.RandomTarget = e end)

local RefreshBtn = CreateButton(TabPages[4], "Refresh player list")
local TimerLabel = CreateLabel(TabPages[4], "Timer: 10")
local ViewCloseBtn = CreateButton(TabPages[4], "View/Close Player List")

-- BOT TAB
CreateToggleWithInput(TabPages[5], "Speed bot", true, "16", function(e, val) Features.Bot.SpeedEnabled = e; Features.Bot.Speed = tonumber(val) or 16 end)
CreateToggle(TabPages[5], "View Lines", function(e) Features.Bot.ViewLines = e; if e then createLastWPToPlayerBeam() else removeLastWPToPlayerBeam() end end)
CreateToggle(TabPages[5], "Bot editor", function(e) BotButton.Visible = e; BotEditorMenu.Visible = e; if not e then stopBot() end end)

-- ==================== MIMIC MENU ====================
local MimicMenu = Instance.new("Frame")
MimicMenu.Name = "MimicMenu"
MimicMenu.Parent = MainInner
MimicMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MimicMenu.BorderSizePixel = 0
MimicMenu.Position = UDim2.new(0, 310, 0, 0)
MimicMenu.Size = UDim2.new(0, 180, 0, 200)
MimicMenu.Visible = false
MimicMenu.ZIndex = 110
MimicMenu.ClipsDescendants = true

local MimicMenuBorder = Instance.new("Frame")
MimicMenuBorder.Name = "MimicMenuBorder"
MimicMenuBorder.Parent = MimicMenu
MimicMenuBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MimicMenuBorder.BorderSizePixel = 0
MimicMenuBorder.Size = UDim2.new(1, 6, 1, 6)
MimicMenuBorder.Position = UDim2.new(0, -3, 0, -3)
MimicMenuBorder.ZIndex = 109

local MimicMenuInner = Instance.new("Frame")
MimicMenuInner.Name = "MimicMenuInner"
MimicMenuInner.Parent = MimicMenuBorder
MimicMenuInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MimicMenuInner.BorderSizePixel = 0
MimicMenuInner.Size = UDim2.new(1, -6, 1, -6)
MimicMenuInner.Position = UDim2.new(0, 3, 0, 3)
MimicMenuInner.ZIndex = 110

local MimicTitle = Instance.new("TextLabel")
MimicTitle.Parent = MimicMenuInner
MimicTitle.BackgroundTransparency = 1
MimicTitle.Size = UDim2.new(1, 0, 0, 20)
MimicTitle.Font = Enum.Font.SourceSansBold
MimicTitle.Text = "Mimic Menu"
MimicTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MimicTitle.TextSize = 14
MimicTitle.ZIndex = 111

local MimicMenuScrolling = Instance.new("ScrollingFrame")
MimicMenuScrolling.Parent = MimicMenuInner
MimicMenuScrolling.BackgroundTransparency = 1
MimicMenuScrolling.BorderSizePixel = 0
MimicMenuScrolling.Position = UDim2.new(0, 0, 0, 25)
MimicMenuScrolling.Size = UDim2.new(1, 0, 1, -25)
MimicMenuScrolling.ScrollBarThickness = 4
MimicMenuScrolling.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
MimicMenuScrolling.ZIndex = 111
MimicMenuScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y

local MimicMenuLayout = Instance.new("UIListLayout")
MimicMenuLayout.Parent = MimicMenuScrolling
MimicMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
MimicMenuLayout.Padding = UDim.new(0, 4)

CreateToggleWithInput(MimicMenuScrolling, "Follow offset", true, "5", function(e, val) Features.Mimic.FollowOffset = tonumber(val) or 5 end)
CreateToggleWithInput(MimicMenuScrolling, "Follow delay", true, "0", function(e, val) Features.Mimic.FollowDelay = tonumber(val) or 0 end)
CreateToggle(MimicMenuScrolling, "Random Target", function(e) Features.Mimic.RandomTarget = e end)

-- ==================== BOT EDITOR MENU ====================
local BotEditorMenu = Instance.new("Frame")
BotEditorMenu.Name = "BotEditorMenu"
BotEditorMenu.Parent = MainInner
BotEditorMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotEditorMenu.BorderSizePixel = 0
BotEditorMenu.Position = UDim2.new(0, 310, 0, 210)
BotEditorMenu.Size = UDim2.new(0, 180, 0, 180)
BotEditorMenu.Visible = false
BotEditorMenu.ZIndex = 110
BotEditorMenu.ClipsDescendants = true

local BotEditorBorder = Instance.new("Frame")
BotEditorBorder.Name = "BotEditorBorder"
BotEditorBorder.Parent = BotEditorMenu
BotEditorBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BotEditorBorder.BorderSizePixel = 0
BotEditorBorder.Size = UDim2.new(1, 6, 1, 6)
BotEditorBorder.Position = UDim2.new(0, -3, 0, -3)
BotEditorBorder.ZIndex = 109

local BotEditorInner = Instance.new("Frame")
BotEditorInner.Name = "BotEditorInner"
BotEditorInner.Parent = BotEditorBorder
BotEditorInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotEditorInner.BorderSizePixel = 0
BotEditorInner.Size = UDim2.new(1, -6, 1, -6)
BotEditorInner.Position = UDim2.new(0, 3, 0, 3)
BotEditorInner.ZIndex = 110

local BotEditorTitle = Instance.new("TextLabel")
BotEditorTitle.Parent = BotEditorInner
BotEditorTitle.BackgroundTransparency = 1
BotEditorTitle.Size = UDim2.new(1, 0, 0, 20)
BotEditorTitle.Font = Enum.Font.SourceSansBold
BotEditorTitle.Text = "Bot Editor"
BotEditorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BotEditorTitle.TextSize = 14
BotEditorTitle.ZIndex = 111

local BotEditorScrolling = Instance.new("ScrollingFrame")
BotEditorScrolling.Parent = BotEditorInner
BotEditorScrolling.BackgroundTransparency = 1
BotEditorScrolling.BorderSizePixel = 0
BotEditorScrolling.Position = UDim2.new(0, 0, 0, 25)
BotEditorScrolling.Size = UDim2.new(1, 0, 1, -25)
BotEditorScrolling.ScrollBarThickness = 4
BotEditorScrolling.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
BotEditorScrolling.ZIndex = 111
BotEditorScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y

local BotEditorLayout = Instance.new("UIListLayout")
BotEditorLayout.Parent = BotEditorScrolling
BotEditorLayout.SortOrder = Enum.SortOrder.LayoutOrder
BotEditorLayout.Padding = UDim.new(0, 4)

-- BOT EDITOR BUTTONS
CreateButton(BotEditorScrolling, "Create waypoint", function()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local pos = root.Position
    local n = #Features.Bot.Waypoints + 1
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = pos
    part.Anchored = true
    part.CanCollide = false
    part.Color = Color3.fromRGB(60, 100, 255)
    part.Material = Enum.Material.Neon
    part.Parent = Workspace
    local light = Instance.new("PointLight")
    light.Brightness = 1
    light.Range = 10
    light.Color = Color3.fromRGB(60, 100, 255)
    light.Parent = part
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 20)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "WP #" .. n
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.Parent = bb
    table.insert(Features.Bot.Waypoints, {Part = part, Position = pos})
    table.insert(botWaypointParts, part)
    if Features.Bot.ViewLines then createLastWPToPlayerBeam() end
end)

CreateButton(BotEditorScrolling, "Delete last waypoint", function()
    if #Features.Bot.Waypoints == 0 then return end
    local lastWp = Features.Bot.Waypoints[#Features.Bot.Waypoints]
    if lastWp and lastWp.Part and lastWp.Part.Parent then
        lastWp.Part:Destroy()
    end
    table.remove(Features.Bot.Waypoints, #Features.Bot.Waypoints)
    if #botWaypointParts > 0 then table.remove(botWaypointParts, #botWaypointParts) end
    removeLastWPToPlayerBeam()
    if Features.Bot.ViewLines and #Features.Bot.Waypoints > 0 then createLastWPToPlayerBeam() end
end)

CreateButton(BotEditorScrolling, "Delete all waypoints", function()
    for _, wp in pairs(Features.Bot.Waypoints) do
        if wp.Part and wp.Part.Parent then wp.Part:Destroy() end
    end
    Features.Bot.Waypoints = {}
    botWaypointParts = {}
    removeLastWPToPlayerBeam()
    if Features.Bot.Enabled then stopBot() end
end)

local StartBotBtn = CreateButton(BotEditorScrolling, "Start bot")
StartBotBtn.MouseButton1Click:Connect(function()
    Features.Bot.Enabled = not Features.Bot.Enabled
    if Features.Bot.Enabled then
        if #Features.Bot.Waypoints == 0 then
            Features.Bot.Enabled = false
            return
        end
        startBotMovement()
        StartBotBtn.Text = "Stop bot"
        StartBotBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    else
        stopBot()
        StartBotBtn.Text = "Start bot"
        StartBotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- ==================== MIMIC & BOT BUTTONS ====================
local MimicButton = Instance.new("TextButton")
MimicButton.Name = "MimicButton"
MimicButton.Parent = WeteroScript
MimicButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MimicButton.BorderSizePixel = 2
MimicButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
MimicButton.Position = UDim2.new(0.5, 100, 0.5, 100)
MimicButton.Size = UDim2.new(0, 50, 0, 50)
MimicButton.Font = Enum.Font.SourceSansBold
MimicButton.Text = "Mimic"
MimicButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MimicButton.TextSize = 12
MimicButton.AutoButtonColor = false
MimicButton.Visible = false
MimicButton.ZIndex = 200
MimicButton.MouseButton1Click:Connect(function()
    MimicMenu.Visible = not MimicMenu.Visible
end)

local BotButton = Instance.new("TextButton")
BotButton.Name = "BotButton"
BotButton.Parent = WeteroScript
BotButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotButton.BorderSizePixel = 2
BotButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
BotButton.Position = UDim2.new(0.5, 100, 0.5, 160)
BotButton.Size = UDim2.new(0, 50, 0, 50)
BotButton.Font = Enum.Font.SourceSansBold
BotButton.Text = "Bot"
BotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BotButton.TextSize = 12
BotButton.AutoButtonColor = false
BotButton.Visible = false
BotButton.ZIndex = 200
BotButton.MouseButton1Click:Connect(function()
    BotEditorMenu.Visible = not BotEditorMenu.Visible
end)

-- ==================== PLAYER LIST ====================
local PlayerListFrame = Instance.new("Frame")
PlayerListFrame.Name = "PlayerListFrame"
PlayerListFrame.Parent = MainInner
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Position = UDim2.new(0, 310, 0, 0)
PlayerListFrame.Size = UDim2.new(0, 150, 0, 300)
PlayerListFrame.Visible = false
PlayerListFrame.ZIndex = 105
PlayerListFrame.ClipsDescendants = true

local PlayerListScrolling = Instance.new("ScrollingFrame")
PlayerListScrolling.Parent = PlayerListFrame
PlayerListScrolling.BackgroundTransparency = 1
PlayerListScrolling.BorderSizePixel = 0
PlayerListScrolling.Size = UDim2.new(1, 0, 1, 0)
PlayerListScrolling.ScrollBarThickness = 4
PlayerListScrolling.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
PlayerListScrolling.ZIndex = 106
PlayerListScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Parent = PlayerListScrolling
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function UpdatePlayerList()
    for _, child in ipairs(PlayerListScrolling:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Parent = PlayerListScrolling
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.Size = UDim2.new(1, 0, 0, 24)
            PlayerBtn.Font = Enum.Font.SourceSans
            PlayerBtn.Text = player.Name
            PlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerBtn.TextSize = 12
            PlayerBtn.AutoButtonColor = false
            PlayerBtn.ZIndex = 107
            PlayerBtn.MouseButton1Click:Connect(function()
                Features.Mimic.Target = player
            end)
        end
    end
end

local timer = 10
RunService.Heartbeat:Connect(function(dt)
    timer = timer - dt
    TimerLabel.Text = "Timer: " .. math.max(0, math.floor(timer))
    if timer <= 0 then
        UpdatePlayerList()
        timer = 10
    end
end)

ViewCloseBtn.MouseButton1Click:Connect(function()
    PlayerListFrame.Visible = not PlayerListFrame.Visible
end)

RefreshBtn.MouseButton1Click:Connect(function()
    UpdatePlayerList()
end)

UpdatePlayerList()

-- ==================== DRAGGABLE HEADER ====================
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    local newX = startPos.X.Offset + delta.X
    local newY = startPos.Y.Offset + delta.Y
    local screenSize = workspace.CurrentCamera.ViewportSize
    newX = math.clamp(newX, -HeaderButton.Size.X.Offset + 50, screenSize.X - 50)
    newY = math.clamp(newY, 0, screenSize.Y - HeaderButton.Size.Y.Offset)
    HeaderButton.Position = UDim2.new(0, newX, 0, newY)
end

HeaderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = HeaderButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

HeaderButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        updateDrag(input)
    end
end)

local clickThreshold = 5
local mouseDownPos = nil

HeaderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDownPos = input.Position
    end
end)

HeaderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and mouseDownPos then
        local distance = (input.Position - mouseDownPos).Magnitude
        if distance < clickThreshold then
            MainFrame.Visible = not MainFrame.Visible
            MainFrame.Position = UDim2.new(0, HeaderButton.Position.X.Offset - 50, 0, HeaderButton.Position.Y.Offset + HeaderButton.Size.Y.Offset + 2)
        end
    end
    mouseDownPos = nil
end)

-- ==================== RAINBOW EFFECT ====================
local rainbowOffset = 0
RunService.RenderStepped:Connect(function(deltaTime)
    rainbowOffset = (rainbowOffset + deltaTime * 0.5) % 1
    local hue = rainbowOffset
    local color = Color3.fromHSV(hue, 1, 1)
    HeaderBorder.BackgroundColor3 = color
    MainBorder.BackgroundColor3 = color
    MimicMenuBorder.BackgroundColor3 = color
    BotEditorBorder.BackgroundColor3 = color
end)

-- ==================== RESPAWN HANDLER ====================
Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Features.FreezePlayer then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = true end
    end
    if Features.Bot.ViewLines then createLastWPToPlayerBeam() end
end)
