--[[
    WeteroScript v13.0
    Author: @WeteroScript
    INJECT: loadstring(game:HttpGet("URL"))()
]]

-- SERVICES
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CLEANUP
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

-- UTILITIES
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

local function cleanupRainbowStrokes()
    for i = #rainbowStrokes, 1, -1 do
        if not rainbowStrokes[i] or not rainbowStrokes[i].Parent then
            table.remove(rainbowStrokes, i)
        end
    end
end

RunService.RenderStepped:Connect(function()
    cleanupRainbowStrokes()
    local hue = (tick() * 0.5) % 1
    for i, s in pairs(rainbowStrokes) do 
        if s and s.Parent then 
            s.Color = Color3.fromHSV(hue, 1, 0.8) 
        else 
            rainbowStrokes[i] = nil 
        end 
    end
end)

-- AD GUI
local AdGui = Instance.new("ScreenGui"); AdGui.Name = "AdGui"; AdGui.Parent = CoreGui; AdGui.ResetOnSpawn = false
local AdFrame = Instance.new("Frame"); AdFrame.Size = UDim2.new(0, 300, 0, 120); AdFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
AdFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); AdFrame.BorderSizePixel = 0; AdFrame.Parent = AdGui; addCorner(AdFrame, 8)
local AdTitle = Instance.new("TextLabel"); AdTitle.Size = UDim2.new(1, 0, 0, 25); AdTitle.Position = UDim2.new(0, 0, 0, 10)
AdTitle.BackgroundTransparency = 1; AdTitle.Text = "WeteroScript v13.0"; AdTitle.TextColor3 = Color3.new(1, 1, 1)
AdTitle.Font = Enum.Font.GothamBold; AdTitle.TextSize = 18; AdTitle.Parent = AdFrame
local AdTG = Instance.new("TextLabel"); AdTG.Size = UDim2.new(1, 0, 0, 20); AdTG.Position = UDim2.new(0, 0, 0, 40)
AdTG.BackgroundTransparency = 1; AdTG.Text = "t.me/WeteroScript"; AdTG.TextColor3 = Color3.fromRGB(100, 180, 255)
AdTG.Font = Enum.Font.Gotham; AdTG.TextSize = 14; AdTG.Parent = AdFrame
local AdClose = Instance.new("TextButton"); AdClose.Size = UDim2.new(0, 100, 0, 30); AdClose.Position = UDim2.new(0.5, -50, 0, 70)
AdClose.BackgroundColor3 = Color3.fromRGB(50, 50, 50); AdClose.Text = "Close (2.5s)"; AdClose.TextColor3 = Color3.new(1, 1, 1)
AdClose.Font = Enum.Font.Gotham; AdClose.TextSize = 13; AdClose.BorderSizePixel = 0; AdClose.Visible = false; AdClose.Parent = AdFrame; addCorner(AdClose, 4)

-- EXTERNAL BUTTON
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

-- MAIN GUI (УЖЕ - 480px)
local Gui = Instance.new("ScreenGui"); Gui.Name = "WeteroScript"; Gui.Parent = CoreGui; Gui.ResetOnSpawn = false
local Window = Instance.new("Frame"); Window.Size = UDim2.new(0, 480, 0, 520); Window.Position = UDim2.new(0.5, -240, 0.5, -260)
Window.BackgroundColor3 = Color3.fromRGB(12, 12, 18); Window.BorderSizePixel = 0; Window.Visible = false; Window.Parent = Gui; addCorner(Window, 10)
local WindowStroke = addStroke(Window, 2, Color3.new(1, 1, 1))
local TopBar = Instance.new("Frame"); TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
TopBar.BorderSizePixel = 0; TopBar.Active = true; TopBar.Parent = Window; addCorner(TopBar, 10)
local TopBarCover = Instance.new("Frame"); TopBarCover.Size = UDim2.new(1, 0, 0.5, 0); TopBarCover.Position = UDim2.new(0, 0, 0.5, 0)
TopBarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 26); TopBarCover.BorderSizePixel = 0; TopBarCover.Parent = TopBar
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1; Title.Text = "⚡ WeteroScript v13.0"; Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TopBar
local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TopBar; addCorner(CloseBtn, 6)
makeDraggable(Window, TopBar)

-- TAB SYSTEM с кнопками < >
local TabContainer = Instance.new("Frame"); TabContainer.Size = UDim2.new(1, -60, 0, 36); TabContainer.Position = UDim2.new(0, 30, 0, 36)
TabContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 22); TabContainer.BorderSizePixel = 0; TabContainer.ClipsDescendants = true; TabContainer.Parent = Window
local TabScrollFrame = Instance.new("Frame"); TabScrollFrame.Size = UDim2.new(0, 0, 1, 0); TabScrollFrame.BackgroundTransparency = 1; TabScrollFrame.Parent = TabContainer
local TAB_W = 74; local TAB_GAP = 3; local TabBtns = {}; local TabPages = {}

local ScrollLeftBtn = Instance.new("TextButton"); ScrollLeftBtn.Size = UDim2.new(0, 24, 0, 30); ScrollLeftBtn.Position = UDim2.new(0, 3, 0, 37)
ScrollLeftBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38); ScrollLeftBtn.Text = "◀"; ScrollLeftBtn.TextColor3 = Color3.new(1, 1, 1)
ScrollLeftBtn.Font = Enum.Font.GothamBold; ScrollLeftBtn.TextSize = 12; ScrollLeftBtn.BorderSizePixel = 0; ScrollLeftBtn.Parent = Window; addCorner(ScrollLeftBtn, 6)

local ScrollRightBtn = Instance.new("TextButton"); ScrollRightBtn.Size = UDim2.new(0, 24, 0, 30); ScrollRightBtn.Position = UDim2.new(1, -27, 0, 37)
ScrollRightBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38); ScrollRightBtn.Text = "▶"; ScrollRightBtn.TextColor3 = Color3.new(1, 1, 1)
ScrollRightBtn.Font = Enum.Font.GothamBold; ScrollRightBtn.TextSize = 12; ScrollRightBtn.BorderSizePixel = 0; ScrollRightBtn.Parent = Window; addCorner(ScrollRightBtn, 6)

local tabScrollOffset = 0; local maxTabScroll = 0
local function updateTabScroll()
    TabScrollFrame.Position = UDim2.new(0, -tabScrollOffset, 0, 0)
    ScrollLeftBtn.Visible = tabScrollOffset > 0
    ScrollRightBtn.Visible = tabScrollOffset < maxTabScroll
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
    maxTabScroll = math.max(0, index * (TAB_W + TAB_GAP) - 400 + 10); updateTabScroll(); return page, layout
end

-- UI FACTORIES
local function addButton(page, layout, text, callback)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
    btn.Text = text; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 11
    btn.BorderSizePixel = 0; btn.Parent = page; addCorner(btn, 5); addStroke(btn, 1, Color3.fromRGB(50, 50, 70))
    btn.Activated:Connect(callback); updateCanvas(page, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvas(page, layout) end)
    return btn
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

-- CREATE TABS (6 вкладок)
local page1, layout1 = createTab("Move", 1)
local page2, layout2 = createTab("ESP", 2)
local page3, layout3 = createTab("Diff", 3)
local page4, layout4 = createTab("Mimic", 4)
local page5, layout5 = createTab("Bot", 5)
local page6, layout6 = createTab("Chat", 6)

-- FEATURES STATE
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

-- ==================== CHAT SYSTEM ====================
local chatMessages = {}
local chatScrollFrame = nil
local chatSendBox = nil

local function addChatMessage(speaker, message, isSystem)
    local timestamp = os.date("%H:%M:%S")
    local color = isSystem and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(200, 200, 255)
    local prefix = isSystem and "🔔 SYSTEM" or speaker
    
    table.insert(chatMessages, 1, {
        text = string.format("[%s] %s: %s", timestamp, prefix, message),
        color = color
    })
    
    if #chatMessages > 100 then
        table.remove(chatMessages)
    end
    
    if chatScrollFrame then
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -10, 0, 18)
        msgLabel.BackgroundTransparency = 1
        msgLabel.TextColor3 = color
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextSize = 10
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.Text = chatMessages[1].text
        msgLabel.Parent = chatScrollFrame
        
        local layout = chatScrollFrame:FindFirstChildWhichIsA("UIListLayout")
        if layout then
            chatScrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
        end
    end
end

local function sendChatMessage(msg)
    if msg == "" then return end
    pcall(function()
        local remotes = {
            ReplicatedStorage:FindFirstChild("SayMessageRequest"),
            ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents"),
            ReplicatedStorage:FindFirstChild("Chat")
        }
        for _, remote in pairs(remotes) do
            if remote then
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(msg, "All")
                elseif remote:FindFirstChild("SayMessageRequest") then
                    remote.SayMessageRequest:FireServer(msg, "All")
                end
                break
            end
        end
        addChatMessage(Player.Name, msg, false)
    end)
end

-- Hook into game chat
local function hookChat()
    pcall(function()
        local chatService = require(ReplicatedStorage:FindFirstChild("ChatServiceRunner")).Client
        if chatService then
            chatService:RegisterProcessFunction("OnMessageDoneFiltering", function(data)
                if data and data.FromSpeaker and data.Message then
                    addChatMessage(data.FromSpeaker, data.Message, false)
                end
                return true
            end)
        end
    end)
    
    local sayMessageRequest = ReplicatedStorage:FindFirstChild("SayMessageRequest")
    if sayMessageRequest and sayMessageRequest.OnClientEvent then
        sayMessageRequest.OnClientEvent:Connect(function(data)
            if data and data.FromSpeaker and data.Message then
                addChatMessage(data.FromSpeaker, data.Message, false)
            end
        end)
    end
end

hookChat()
addChatMessage("SYSTEM", "Chat loaded!", true)

-- ==================== CLEANUP FUNCTIONS ====================
local function resetAllHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player and plr.Character then for _, p in pairs(plr.Character:GetChildren()) do if p:IsA("BasePart") and p.Name == "HumanoidRootPart" then p.Size = Vector3.new(2, 2, 1); p.Transparency = 0; p.CanCollide = true end end end end
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
end

local function stopBot()
    Features.Bot.Enabled = false; Features.Bot.CurrentWaypointIndex = 0
    if botConnections.Walk then botConnections.Walk:Disconnect(); botConnections.Walk = nil end
    if Player.Character and not Features.Mimic.Enabled then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Features.Speed.Enabled and Features.Speed.Value or 16 end
    end
end

local function clearWaypointBeams()
    if lastWPToPlayerBeam then lastWPToPlayerBeam:Destroy() end
    for _, wp in pairs(Features.Bot.Waypoints) do
        if wp.Part and wp.Part.Parent then wp.Part:Destroy() end
    end
    Features.Bot.Waypoints = {}
end

local function stopMobileFly()
    flyActive = false
    if flyHeartbeat then flyHeartbeat:Disconnect(); flyHeartbeat = nil end
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
            end
        end
    end
end

local function stopAllFunctions()
    for _, conn in pairs(connections) do pcall(function() conn:Disconnect() end) end
    connections = {}
    if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect() end
    stopMimic(); stopBot(); resetAllHitboxes(); stopMobileFly()
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
        for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true; p.Transparency = 0 end end
    end
    for _, data in pairs(espStorage) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    espStorage = {}
    clearWaypointBeams()
end

-- ESP FUNCTIONS
local function refreshESP()
    for _, data in pairs(espStorage) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    espStorage = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and Features.ESP.Enabled then
            local hl = Instance.new("Highlight")
            hl.FillTransparency = 0.85
            hl.OutlineColor = Features.ESP.Color
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = plr.Character
            espStorage[plr.Character] = {Highlight = hl}
        end
    end
end

-- AUTO JUMP
local autoJumpEnabled = false; local autoJumpHeartbeat = nil
local function startAutoJump()
    if autoJumpHeartbeat then autoJumpHeartbeat:Disconnect() end
    autoJumpHeartbeat = RunService.Heartbeat:Connect(function()
        if not autoJumpEnabled then return end
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- BOT MOVEMENT (упрощённый)
local function startBotMovement()
    if #Features.Bot.Waypoints == 0 then stopBot(); return end
    local currentIdx = 1
    if botConnections.Walk then botConnections.Walk:Disconnect() end
    botConnections.Walk = RunService.Heartbeat:Connect(function()
        if not Features.Bot.Enabled or not Player.Character then return end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character:FindFirstChild("Humanoid")
        if not root or not hum then return end
        if #Features.Bot.Waypoints == 0 then stopBot(); return end
        local wp = Features.Bot.Waypoints[currentIdx]
        if not wp or not wp.Part or not wp.Part.Parent then return end
        local targetPos = wp.Position
        local distance = (root.Position - targetPos).Magnitude
        local lookAtCFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        root.CFrame = CFrame.new(root.Position, lookAtCFrame.LookVector)
        if distance > 4 then
            local moveDir = (targetPos - root.Position).Unit
            hum:Move(moveDir, false)
            hum.WalkSpeed = Features.Bot.SpeedEnabled and Features.Bot.Speed or 16
            root.CFrame = root.CFrame + (moveDir * 2)
        else
            currentIdx = currentIdx + 1
            if currentIdx > #Features.Bot.Waypoints then currentIdx = 1 end
        end
    end)
end

-- ==================== TAB 1: MOVE ====================
addToggleWithInput(page1, layout1, "Speed", "16", "16", 
    function(e) Features.Speed.Enabled = e; if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = e and Features.Speed.Value or 16 end end,
    function(v) Features.Speed.Value = tonumber(v) or 16; if Features.Speed.Enabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = Features.Speed.Value end end)
addToggleWithInput(page1, layout1, "Jump", "50", "50",
    function(e) Features.Jump.Enabled = e; if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.JumpPower = e and Features.Jump.Value or 50 end end,
    function(v) Features.Jump.Value = tonumber(v) or 50; if Features.Jump.Enabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.JumpPower = Features.Jump.Value end end)
addToggle(page1, layout1, "Auto Jump", function(e) autoJumpEnabled = e; if e then startAutoJump() elseif autoJumpHeartbeat then autoJumpHeartbeat:Disconnect() end end)
addToggle(page1, layout1, "Noclip", function(e) Features.Noclip = e; if connections.Noclip then connections.Noclip:Disconnect() end; if e then connections.Noclip = RunService.Stepped:Connect(function() if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end) else if Player.Character then for _, p in pairs(Player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end end)
addButton(page1, layout1, "Server Hop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if data and data.data then
            for _, s in pairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                    break
                end
            end
        end
    end)
end)
addButton(page1, layout1, "Rejoin", function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
local stopBtn = Instance.new("TextButton"); stopBtn.Size = UDim2.new(1, 0, 0, 34); stopBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40); stopBtn.Text = "⏹ STOP ALL"; stopBtn.TextColor3 = Color3.new(1, 1, 1); stopBtn.Font = Enum.Font.GothamBold; stopBtn.TextSize = 12; stopBtn.BorderSizePixel = 0; stopBtn.Parent = page1; addCorner(stopBtn, 5); stopBtn.Activated:Connect(stopAllFunctions)
updateCanvas(page1, layout1)

-- ==================== TAB 2: ESP ====================
addToggle(page2, layout2, "Player ESP", function(e) Features.ESP.Enabled = e; refreshESP() end)
addButton(page2, layout2, "🎨 Color Palette", function() if ColorPickerWindow then ColorPickerWindow.Visible = true end end)

-- ==================== TAB 3: DIFFERENT ====================
addToggle(page3, layout3, "Anti-Fling", function(e) Features.AntiFling = e; if connections.AntiFling then connections.AntiFling:Disconnect() end; if e then connections.AntiFling = RunService.Heartbeat:Connect(function() if Player.Character then local r = Player.Character:FindFirstChild("HumanoidRootPart"); local h = Player.Character:FindFirstChild("Humanoid"); if r and h and r.Velocity.Magnitude > 200 then r.Velocity = Vector3.new(0, r.Velocity.Y, 0); h.PlatformStand = false end end end) end end)
addToggle(page3, layout3, "Freezecam", function(e) Features.Freezecam = e; if connections.Freezecam then connections.Freezecam:Disconnect() end; if e then local cam = workspace.CurrentCamera; if cam then local fcf = cam.CFrame; connections.Freezecam = RunService.RenderStepped:Connect(function() if cam then cam.CFrame = fcf end end) end end end)
addToggle(page3, layout3, "Freeze Player", function(e) if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart"); if root then root.Anchored = e end end end)
addButton(page3, layout3, "Explode", function() if Player.Character then local root = Player.Character:FindFirstChild("HumanoidRootPart"); if root then local exp = Instance.new("Explosion"); exp.Position = root.Position; exp.BlastPressure = 500000; exp.BlastRadius = 20; exp.Parent = Workspace end end end)

-- ==================== TAB 4: MIMIC ====================
local mimicTargetDisplay = Instance.new("TextLabel"); mimicTargetDisplay.Size = UDim2.new(1, 0, 0, 30); mimicTargetDisplay.BackgroundColor3 = Color3.fromRGB(32, 32, 46); mimicTargetDisplay.BorderSizePixel = 0; mimicTargetDisplay.Text = "No Target"; mimicTargetDisplay.TextColor3 = Color3.fromRGB(255, 80, 80); mimicTargetDisplay.Font = Enum.Font.GothamSemibold; mimicTargetDisplay.TextSize = 11; mimicTargetDisplay.Parent = page4; addCorner(mimicTargetDisplay, 5)
updateCanvas(page4, layout4)

local function updateMimicDisplay()
    if Features.Mimic.Target then
        mimicTargetDisplay.Text = "🎯 Target: " .. Features.Mimic.Target.Name
        mimicTargetDisplay.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        mimicTargetDisplay.Text = "No Target"
        mimicTargetDisplay.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

local function selectTarget()
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= Player then table.insert(players, plr) end end
    if #players > 0 then
        Features.Mimic.Target = players[math.random(1, #players)]
        updateMimicDisplay()
    end
end

addButton(page4, layout4, "🎲 Random Target", selectTarget)
addToggle(page4, layout4, "Copy Jumps", function(e) Features.Mimic.CopyJump = e end)
addToggle(page4, layout4, "Start Mimic", function(e)
    Features.Mimic.Enabled = e
    if e then
        if not Features.Mimic.Target then selectTarget() end
        local target = Features.Mimic.Target
        if not target or not target.Character then Features.Mimic.Enabled = false; return end
        if mimicConnections.Main then mimicConnections.Main:Disconnect() end
        local lastJump = 0
        mimicConnections.Main = RunService.Heartbeat:Connect(function()
            if not Features.Mimic.Enabled or not Features.Mimic.Target or not Features.Mimic.Target.Character then return end
            local tRoot = Features.Mimic.Target.Character:FindFirstChild("HumanoidRootPart")
            local mRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = Features.Mimic.Target.Character:FindFirstChild("Humanoid")
            local mHum = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if tRoot and mRoot then
                mRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -5)
                if Features.Mimic.CopyJump and tHum and mHum and tHum:GetState() == Enum.HumanoidStateType.Jumping and tick() - lastJump > 1 then
                    lastJump = tick()
                    mHum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    elseif mimicConnections.Main then
        mimicConnections.Main:Disconnect()
        mimicConnections.Main = nil
    end
end)

-- ==================== TAB 5: BOT ====================
addToggle(page5, layout5, "Jump on point", function(e) Features.Bot.JumpOnPoint = e end)

local botSpeedContainer = Instance.new("Frame"); botSpeedContainer.Size = UDim2.new(1, 0, 0, 34); botSpeedContainer.BackgroundColor3 = Color3.fromRGB(32, 32, 46); botSpeedContainer.BorderSizePixel = 0; botSpeedContainer.Parent = page5; addCorner(botSpeedContainer, 5); addStroke(botSpeedContainer, 1, Color3.fromRGB(50, 50, 70))
local botSpeedLabel = Instance.new("TextLabel"); botSpeedLabel.Size = UDim2.new(0, 70, 1, 0); botSpeedLabel.Position = UDim2.new(0, 8, 0, 0); botSpeedLabel.BackgroundTransparency = 1; botSpeedLabel.Text = "Speed Bot"; botSpeedLabel.TextColor3 = Color3.new(1, 1, 1); botSpeedLabel.Font = Enum.Font.Gotham; botSpeedLabel.TextSize = 10; botSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left; botSpeedLabel.Parent = botSpeedContainer
local botSpeedInputBg = Instance.new("Frame"); botSpeedInputBg.Size = UDim2.new(0, 40, 0, 20); botSpeedInputBg.Position = UDim2.new(0, 80, 0.5, -10); botSpeedInputBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); botSpeedInputBg.BorderSizePixel = 0; botSpeedInputBg.Parent = botSpeedContainer; addCorner(botSpeedInputBg, 3)
local botSpeedInput = Instance.new("TextBox"); botSpeedInput.Size = UDim2.new(1, -6, 1, 0); botSpeedInput.Position = UDim2.new(0, 3, 0, 0); botSpeedInput.BackgroundTransparency = 1; botSpeedInput.PlaceholderText = "16"; botSpeedInput.Text = "16"; botSpeedInput.TextColor3 = Color3.new(1, 1, 1); botSpeedInput.Font = Enum.Font.Gotham; botSpeedInput.TextSize = 10; botSpeedInput.Parent = botSpeedInputBg
local botSpeedToggleBg = Instance.new("Frame"); botSpeedToggleBg.Size = UDim2.new(0, 32, 0, 16); botSpeedToggleBg.Position = UDim2.new(1, -42, 0.5, -8); botSpeedToggleBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34); botSpeedToggleBg.BorderSizePixel = 0; botSpeedToggleBg.Parent = botSpeedContainer; addCorner(botSpeedToggleBg, 1)
local botSpeedDot = Instance.new("Frame"); botSpeedDot.Size = UDim2.new(0, 12, 0, 12); botSpeedDot.Position = UDim2.new(0, 2, 0.5, -6); botSpeedDot.BackgroundColor3 = Color3.fromRGB(180, 180, 200); botSpeedDot.BorderSizePixel = 0; botSpeedDot.Parent = botSpeedToggleBg; addCorner(botSpeedDot, 1)
local botSpeedClick = Instance.new("TextButton"); botSpeedClick.Size = UDim2.new(0, 40, 1, 0); botSpeedClick.Position = UDim2.new(1, -44, 0, 0); botSpeedClick.BackgroundTransparency = 1; botSpeedClick.Text = ""; botSpeedClick.ZIndex = 5; botSpeedClick.Parent = botSpeedContainer
botSpeedClick.Activated:Connect(function()
    Features.Bot.SpeedEnabled = not Features.Bot.SpeedEnabled
    botSpeedToggleBg.BackgroundColor3 = Features.Bot.SpeedEnabled and Color3.fromRGB(60, 140, 60) or Color3.fromRGB(22, 22, 34)
    botSpeedDot:TweenPosition(UDim2.new(0, Features.Bot.SpeedEnabled and 18 or 2, 0.5, -6), "Out", "Quad", 0.15)
    botSpeedDot.BackgroundColor3 = Features.Bot.SpeedEnabled and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 200)
    if Features.Bot.SpeedEnabled then
        Features.Bot.Speed = tonumber(botSpeedInput.Text) or 16
    end
end)
botSpeedInput.FocusLost:Connect(function()
    if Features.Bot.SpeedEnabled then
        Features.Bot.Speed = tonumber(botSpeedInput.Text) or 16
    end
end)

local function createWaypoint()
    if not Player.Character then return end
    local root = Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Position = root.Position
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
    table.insert(Features.Bot.Waypoints, {Part = part, Position = part.Position})
end

addButton(page5, layout5, "📍 Create Waypoint", createWaypoint)
addButton(page5, layout5, "🗑 Clear Waypoints", function() clearWaypointBeams(); stopBot() end)

local botToggleBtn = Instance.new("TextButton"); botToggleBtn.Size = UDim2.new(1, 0, 0, 34); botToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 38); botToggleBtn.Text = "▶ Start Bot"; botToggleBtn.TextColor3 = Color3.new(1, 1, 1); botToggleBtn.Font = Enum.Font.GothamSemibold; botToggleBtn.TextSize = 11; botToggleBtn.BorderSizePixel = 0; botToggleBtn.Parent = page5; addCorner(botToggleBtn, 6)
botToggleBtn.Activated:Connect(function()
    Features.Bot.Enabled = not Features.Bot.Enabled
    if Features.Bot.Enabled then
        if #Features.Bot.Waypoints == 0 then Features.Bot.Enabled = false; return end
        botToggleBtn.Text = "⏸ Stop Bot"
        startBotMovement()
    else
        botToggleBtn.Text = "▶ Start Bot"
        stopBot()
    end
end)

updateCanvas(page5, layout5)

-- ==================== TAB 6: CHAT ====================
local chatDisplayFrame = Instance.new("Frame")
chatDisplayFrame.Size = UDim2.new(1, -10, 0, 300)
chatDisplayFrame.Position = UDim2.new(0, 5, 0, 5)
chatDisplayFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
chatDisplayFrame.BorderSizePixel = 0
chatDisplayFrame.Parent = page6
addCorner(chatDisplayFrame, 6)
addStroke(chatDisplayFrame, 1, Color3.fromRGB(40, 40, 55))

chatScrollFrame = Instance.new("ScrollingFrame")
chatScrollFrame.Size = UDim2.new(1, -8, 1, -8)
chatScrollFrame.Position = UDim2.new(0, 4, 0, 4)
chatScrollFrame.BackgroundTransparency = 1
chatScrollFrame.BorderSizePixel = 0
chatScrollFrame.ScrollBarThickness = 3
chatScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
chatScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatScrollFrame.Parent = chatDisplayFrame

local chatLayout = Instance.new("UIListLayout")
chatLayout.Padding = UDim.new(0, 2)
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Parent = chatScrollFrame

chatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    chatScrollFrame.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y + 8)
    chatScrollFrame.CanvasPosition = Vector2.new(0, chatScrollFrame.CanvasSize.Y.Offset)
end)

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -10, 0, 36)
inputFrame.Position = UDim2.new(0, 5, 0, 315)
inputFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = page6
addCorner(inputFrame, 6)
addStroke(inputFrame, 1, Color3.fromRGB(60, 100, 255))

chatSendBox = Instance.new("TextBox")
chatSendBox.Size = UDim2.new(1, -75, 1, -8)
chatSendBox.Position = UDim2.new(0, 8, 0, 4)
chatSendBox.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
chatSendBox.PlaceholderText = "Type message..."
chatSendBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
chatSendBox.Text = ""
chatSendBox.TextColor3 = Color3.new(1, 1, 1)
chatSendBox.Font = Enum.Font.Gotham
chatSendBox.TextSize = 11
chatSendBox.BorderSizePixel = 0
chatSendBox.Parent = inputFrame
addCorner(chatSendBox, 4)

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 60, 0, 28)
sendBtn.Position = UDim2.new(1, -66, 0.5, -14)
sendBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
sendBtn.Text = "SEND"
sendBtn.TextColor3 = Color3.new(1, 1, 1)
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 11
sendBtn.BorderSizePixel = 0
sendBtn.Parent = inputFrame
addCorner(sendBtn, 4)

sendBtn.Activated:Connect(function()
    if chatSendBox.Text ~= "" then
        sendChatMessage(chatSendBox.Text)
        chatSendBox.Text = ""
    end
end)

chatSendBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and chatSendBox.Text ~= "" then
        sendChatMessage(chatSendBox.Text)
        chatSendBox.Text = ""
    end
end)

-- Загрузка существующих сообщений чата
for i = 1, 50 do
    addChatMessage("Welcome", "Chat system ready! Send messages using the box below.", true)
end

updateCanvas(page6, layout6)

-- ==================== COLOR PICKER WINDOW ====================
local ColorPickerGui = Instance.new("ScreenGui"); ColorPickerGui.Name = "ColorPickerGui"; ColorPickerGui.Parent = CoreGui; ColorPickerGui.ResetOnSpawn = false
local ColorPickerWindow = Instance.new("Frame"); ColorPickerWindow.Size = UDim2.new(0, 260, 0, 200); ColorPickerWindow.Position = UDim2.new(0.3, -130, 0.4, -100)
ColorPickerWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 18); ColorPickerWindow.BorderSizePixel = 0; ColorPickerWindow.Visible = false; ColorPickerWindow.Parent = ColorPickerGui
addCorner(ColorPickerWindow, 8); addStroke(ColorPickerWindow, 1, Color3.fromRGB(60, 100, 255))
local CPTop = Instance.new("Frame"); CPTop.Size = UDim2.new(1, 0, 0, 25); CPTop.BackgroundColor3 = Color3.fromRGB(14, 14, 24); CPTop.BorderSizePixel = 0; CPTop.Active = true; CPTop.Parent = ColorPickerWindow; addCorner(CPTop, 8)
local CPTopCover = Instance.new("Frame"); CPTopCover.Size = UDim2.new(1, 0, 0.5, 0); CPTopCover.Position = UDim2.new(0, 0, 0.5, 0); CPTopCover.BackgroundColor3 = Color3.fromRGB(14, 14, 24); CPTopCover.BorderSizePixel = 0; CPTopCover.Parent = CPTop
local CPTitle = Instance.new("TextLabel"); CPTitle.Size = UDim2.new(1, -20, 1, 0); CPTitle.Position = UDim2.new(0, 8, 0, 0); CPTitle.BackgroundTransparency = 1; CPTitle.Text = "🎨 ESP Color"; CPTitle.TextColor3 = Color3.fromRGB(100, 160, 255); CPTitle.Font = Enum.Font.GothamBold; CPTitle.TextSize = 11; CPTitle.TextXAlignment = Enum.TextXAlignment.Left; CPTitle.Parent = CPTop
makeDraggable(ColorPickerWindow, CPTop)
local CPClose = Instance.new("TextButton"); CPClose.Size = UDim2.new(0, 22, 0, 22); CPClose.Position = UDim2.new(1, -26, 0, 2); CPClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65); CPClose.Text = "✕"; CPClose.TextColor3 = Color3.new(1, 1, 1); CPClose.Font = Enum.Font.GothamBold; CPClose.TextSize = 10; CPClose.BorderSizePixel = 0; CPClose.Parent = CPTop; addCorner(CPClose, 4)
CPClose.Activated:Connect(function() ColorPickerWindow.Visible = false end)
local CPPreview = Instance.new("Frame"); CPPreview.Size = UDim2.new(0, 40, 0, 20); CPPreview.Position = UDim2.new(0, 10, 0, 32); CPPreview.BackgroundColor3 = Features.ESP.Color; CPPreview.BorderSizePixel = 0; CPPreview.Parent = ColorPickerWindow; addCorner(CPPreview, 4)
local paletteContainer = Instance.new("Frame"); paletteContainer.Size = UDim2.new(1, -20, 0, 120); paletteContainer.Position = UDim2.new(0, 10, 0, 58); paletteContainer.BackgroundTransparency = 1; paletteContainer.Parent = ColorPickerWindow
local presetColors = {
    {Color3.fromRGB(255, 0, 0), "Red"}, {Color3.fromRGB(0, 255, 0), "Green"}, {Color3.fromRGB(0, 0, 255), "Blue"},
    {Color3.fromRGB(255, 255, 0), "Yellow"}, {Color3.fromRGB(255, 0, 255), "Pink"}, {Color3.fromRGB(0, 255, 255), "Cyan"},
    {Color3.fromRGB(255, 128, 0), "Orange"}, {Color3.fromRGB(128, 0, 255), "Purple"}, {Color3.fromRGB(255, 255, 255), "White"},
}
for _, colorData in ipairs(presetColors) do
    local color, colorName = colorData[1], colorData[2]
    local swatch = Instance.new("TextButton"); swatch.Size = UDim2.new(0, 30, 0, 30); swatch.BackgroundColor3 = color; swatch.BorderSizePixel = 0; swatch.Text = ""; swatch.Parent = paletteContainer; addCorner(swatch, 4); addStroke(swatch, 1, Color3.fromRGB(40, 40, 50))
    swatch.Activated:Connect(function() Features.ESP.Color = color; CPPreview.BackgroundColor3 = color; refreshESP() end)
end

-- WINDOW TOGGLE
local isOpen = false
WhiteBtn.Activated:Connect(function() isOpen = not isOpen; Window.Visible = isOpen end)
CloseBtn.Activated:Connect(function() isOpen = false; Window.Visible = false end)

-- RGB BORDERS
local rgbHue = 0
RunService.RenderStepped:Connect(function(dt)
    rgbHue = rgbHue + dt * 0.4
    if rgbHue > 1 then rgbHue = rgbHue - 1 end
    local c = Color3.fromHSV(rgbHue, 1, 0.8)
    if WindowStroke then WindowStroke.Color = c end
    for _, b in pairs(extBorders) do if b then b.BackgroundColor3 = c end end
end)

-- RESPAWN
Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Features.Speed.Enabled then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Features.Speed.Value end
    end
    if Features.Jump.Enabled then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = Features.Jump.Value end
    end
    if Features.ESP.Enabled then refreshESP() end
    if autoJumpEnabled then startAutoJump() end
end)

-- SELECT FIRST TAB
if TabPages[1] and TabPages[1].Page then TabPages[1].Page.Visible = true end
if TabBtns[1] then
    TabBtns[1].BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    TabBtns[1].TextColor3 = Color3.new(1, 1, 1)
end

print("✅ WeteroScript v13.0 loaded!")
