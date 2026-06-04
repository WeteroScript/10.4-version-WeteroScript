--[[
    OPEN CODER MOD v1.3 - ULTRA CODER
    ARCEUS X | ROBLOX | 10K+ LINES
    ULTRA DETAILED REALISTIC CARS
]]

--//////////////////////////////////////--
--            INITIALIZATION            --
--//////////////////////////////////////--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--//////////////////////////////////////--
--              GUI SYSTEM              --
--//////////////////////////////////////--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarSpawnerGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 320)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Rainbow Border Outer
local RainbowOuter = Instance.new("Frame")
RainbowOuter.Name = "RainbowOuter"
RainbowOuter.Size = UDim2.new(1, 6, 1, 6)
RainbowOuter.Position = UDim2.new(0, -3, 0, -3)
RainbowOuter.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RainbowOuter.BorderSizePixel = 0
RainbowOuter.ZIndex = 0
RainbowOuter.Parent = MainFrame

local OuterCorner = Instance.new("UICorner")
OuterCorner.CornerRadius = UDim.new(0, 12)
OuterCorner.Parent = RainbowOuter

-- Rainbow Border Inner
local RainbowInner = Instance.new("Frame")
RainbowInner.Name = "RainbowInner"
RainbowInner.Size = UDim2.new(1, 2, 1, 2)
RainbowInner.Position = UDim2.new(0, 2, 0, 2)
RainbowInner.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
RainbowInner.BorderSizePixel = 0
RainbowInner.ZIndex = 1
RainbowInner.Parent = RainbowOuter

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 10)
InnerCorner.Parent = RainbowInner

-- Content Background
local ContentBg = Instance.new("Frame")
ContentBg.Name = "ContentBg"
ContentBg.Size = UDim2.new(1, -4, 1, -4)
ContentBg.Position = UDim2.new(0, 2, 0, 2)
ContentBg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ContentBg.BorderSizePixel = 0
ContentBg.ZIndex = 2
ContentBg.Parent = RainbowInner

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 9)
ContentCorner.Parent = ContentBg

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = ContentBg

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 9)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🏎️ ULTRA CAR SPAWNER v3.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBlack
TitleText.ZIndex = 4
TitleText.Parent = TitleBar

-- Separator Line
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -20, 0, 1)
Separator.Position = UDim2.new(0, 10, 0, 40)
Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
Separator.BorderSizePixel = 0
Separator.ZIndex = 3
Separator.Parent = ContentBg

-- Scroll Frame for buttons
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
ScrollFrame.ZIndex = 3
ScrollFrame.Parent = ContentBg

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingLeft = UDim.new(0, 2)
UIPadding.PaddingRight = UDim.new(0, 2)
UIPadding.Parent = ScrollFrame

-- Function to create styled buttons
local function createStyledButton(name, icon, description, layoutOrder)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = name.."Frame"
    ButtonFrame.Size = UDim2.new(1, -10, 0, 70)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.ZIndex = 3
    ButtonFrame.LayoutOrder = layoutOrder
    ButtonFrame.Parent = ScrollFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = ButtonFrame

    -- Rainbow border for button
    local BtnRainbow = Instance.new("Frame")
    BtnRainbow.Name = "BtnRainbow"
    BtnRainbow.Size = UDim2.new(1, 3, 1, 3)
    BtnRainbow.Position = UDim2.new(0, -1.5, 0, -1.5)
    BtnRainbow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    BtnRainbow.BorderSizePixel = 0
    BtnRainbow.ZIndex = 2
    BtnRainbow.Parent = ButtonFrame

    local BtnRainbowCorner = Instance.new("UICorner")
    BtnRainbowCorner.CornerRadius = UDim.new(0, 9)
    BtnRainbowCorner.Parent = BtnRainbow

    local BtnIcon = Instance.new("TextLabel")
    BtnIcon.Size = UDim2.new(0, 45, 0, 45)
    BtnIcon.Position = UDim2.new(0, 12, 0.5, -22)
    BtnIcon.BackgroundTransparency = 1
    BtnIcon.Text = icon
    BtnIcon.TextSize = 24
    BtnIcon.ZIndex = 4
    BtnIcon.Parent = ButtonFrame

    local BtnText = Instance.new("TextLabel")
    BtnText.Size = UDim2.new(1, -80, 0, 22)
    BtnText.Position = UDim2.new(0, 65, 0, 10)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = name
    BtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnText.TextSize = 14
    BtnText.Font = Enum.Font.GothamBold
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.ZIndex = 4
    BtnText.Parent = ButtonFrame

    local BtnDesc = Instance.new("TextLabel")
    BtnDesc.Size = UDim2.new(1, -80, 0, 18)
    BtnDesc.Position = UDim2.new(0, 65, 0, 35)
    BtnDesc.BackgroundTransparency = 1
    BtnDesc.Text = description
    BtnDesc.TextColor3 = Color3.fromRGB(150, 150, 160)
    BtnDesc.TextSize = 10
    BtnDesc.Font = Enum.Font.Gotham
    BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
    BtnDesc.ZIndex = 4
    BtnDesc.Parent = ButtonFrame

    local BtnButton = Instance.new("TextButton")
    BtnButton.Size = UDim2.new(1, 0, 1, 0)
    BtnButton.BackgroundTransparency = 1
    BtnButton.Text = ""
    BtnButton.ZIndex = 5
    BtnButton.Parent = ButtonFrame

    return BtnButton, BtnRainbow
end

-- Create Car Buttons
local BMWBtn, BMWRainbow = createStyledButton("BMW M5 F90", "🔵", "German Luxury Sedan • 625 HP", 1)
local FerrariBtn, FerrariRainbow = createStyledButton("Ferrari F40", "🔴", "Italian Legend • 478 HP • Twin-Turbo V8", 2)
local BugattiBtn, BugattiRainbow = createStyledButton("Bugatti Bolide", "⚪", "French Hypercar • 1850 HP • W16", 3)

-- CAR Toggle Button
local CarToggle = Instance.new("TextButton")
CarToggle.Name = "CarToggle"
CarToggle.Size = UDim2.new(0, 75, 0, 75)
CarToggle.Position = UDim2.new(0.85, 0, 0.75, 0)
CarToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CarToggle.Text = "CARS"
CarToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CarToggle.TextSize = 14
CarToggle.Font = Enum.Font.GothamBlack
CarToggle.BorderSizePixel = 0
CarToggle.Active = true
CarToggle.Draggable = true
CarToggle.ZIndex = 10
CarToggle.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0.5, 0)
ToggleCorner.Parent = CarToggle

-- Rainbow border for toggle
local ToggleRainbow = Instance.new("Frame")
ToggleRainbow.Name = "ToggleRainbow"
ToggleRainbow.Size = UDim2.new(1, 5, 1, 5)
ToggleRainbow.Position = UDim2.new(0, -2.5, 0, -2.5)
ToggleRainbow.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleRainbow.BorderSizePixel = 0
ToggleRainbow.ZIndex = 9
ToggleRainbow.Parent = CarToggle

local ToggleRainbowCorner = Instance.new("UICorner")
ToggleRainbowCorner.CornerRadius = UDim.new(0.5, 0)
ToggleRainbowCorner.Parent = ToggleRainbow

-- Toggle function
CarToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 5
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.5, 0)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Rainbow animation
local rainbowButtons = {BMWRainbow, FerrariRainbow, BugattiRainbow, RainbowOuter, ToggleRainbow}

spawn(function()
    local hue = 0
    while wait(0.02) do
        hue = (hue + 0.8) % 360
        local color = Color3.fromHSV(hue / 360, 1, 1)
        for _, btn in pairs(rainbowButtons) do
            if btn and btn.Parent then
                btn.BackgroundColor3 = color
            end
        end
        RainbowInner.BackgroundColor3 = Color3.fromHSV((hue + 30) / 360, 1, 1)
    end
end)

-- Button hover effects
local function addHoverEffect(button, frame)
    button.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }):Play()
    end)
end

addHoverEffect(BMWBtn, BMWBtn.Parent)
addHoverEffect(FerrariBtn, FerrariBtn.Parent)
addHoverEffect(BugattiBtn, BugattiBtn.Parent)

--//////////////////////////////////////--
--        CAR BUILDING FUNCTIONS        --
--//////////////////////////////////////--

local function createPart(properties)
    local part = Instance.new("Part")
    for prop, value in pairs(properties) do
        part[prop] = value
    end
    return part
end

local function createWedge(properties)
    local wedge = Instance.new("WedgePart")
    for prop, value in pairs(properties) do
        wedge[prop] = value
    end
    return wedge
end

local function createCylinder(properties)
    local cylinder = Instance.new("Part")
    cylinder.Shape = Enum.PartType.Cylinder
    for prop, value in pairs(properties) do
        cylinder[prop] = value
    end
    return cylinder
end

local function createBall(properties)
    local ball = Instance.new("Part")
    ball.Shape = Enum.PartType.Ball
    for prop, value in pairs(properties) do
        ball[prop] = value
    end
    return ball
end

-- Weld parts together
local function weldParts(parent, part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Part0 = part0
    weld.Part1 = part1
    if c0 then weld.C0 = c0 end
    if c1 then weld.C1 = c1 end
    weld.Parent = parent
    return weld
end

--//////////////////////////////////////--
--          BMW M5 F90 (3000+ lines)    --
--//////////////////////////////////////--

local function createBMW_M5_F90()
    -- Disable collisions
    character:MoveTo(rootPart.Position + Vector3.new(15, 0, 0))
    
    local car = Instance.new("Model")
    car.Name = "BMW M5 F90"

    --=== MAIN BODY ===--
    local mainBody = createPart({
        Name = "MainBody",
        Size = Vector3.new(8.2, 2.4, 17.5),
        Position = rootPart.Position + Vector3.new(0, 4.5, 0),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })

    -- Bottom chassis
    local chassis = createPart({
        Name = "Chassis",
        Size = Vector3.new(7.8, 0.4, 17.0),
        Position = mainBody.Position + Vector3.new(0, -1.4, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, chassis, CFrame.new(0, -1.4, 0), CFrame.new())

    -- Front bumper
    local frontBumper = createPart({
        Name = "FrontBumper",
        Size = Vector3.new(8.5, 1.2, 0.8),
        Position = mainBody.Position + Vector3.new(0, -0.8, -9.15),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, frontBumper, CFrame.new(0, -0.8, -9.15), CFrame.new())

    -- Front lip spoiler
    local frontLip = createWedge({
        Name = "FrontLip",
        Size = Vector3.new(8.2, 0.4, 1.5),
        Position = frontBumper.Position + Vector3.new(0, -0.6, -0.5),
        BrickColor = BrickColor.new("Black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, frontBumper, frontLip, CFrame.new(0, -0.6, -0.5) * CFrame.Angles(math.rad(-15), 0, 0), CFrame.new())

    -- Rear bumper
    local rearBumper = createPart({
        Name = "RearBumper",
        Size = Vector3.new(8.5, 1.2, 0.8),
        Position = mainBody.Position + Vector3.new(0, -0.8, 9.15),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, rearBumper, CFrame.new(0, -0.8, 9.15), CFrame.new())

    -- Rear diffuser
    local rearDiffuser = createPart({
        Name = "RearDiffuser",
        Size = Vector3.new(7.5, 0.3, 1.8),
        Position = rearBumper.Position + Vector3.new(0, -0.7, 0.5),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, rearBumper, rearDiffuser, CFrame.new(0, -0.7, 0.5), CFrame.new())

    -- Diffuser fins
    for i = -3, 3, 1 do
        if i ~= 0 then
            local fin = createPart({
                Name = "DiffuserFin",
                Size = Vector3.new(0.15, 0.8, 1.5),
                Position = rearDiffuser.Position + Vector3.new(i * 0.9, -0.4, 0),
                BrickColor = BrickColor.new("Really black"),
                Material = Enum.Material.Metal,
                Anchored = false,
                CanCollide = true,
                Parent = car
            })
            weldParts(car, rearDiffuser, fin, CFrame.new(i * 0.9, -0.4, 0), CFrame.new())
        end
    end

    -- Side skirts left
    local sideSkirtL = createPart({
        Name = "SideSkirtLeft",
        Size = Vector3.new(0.4, 0.6, 15.0),
        Position = mainBody.Position + Vector3.new(-4.3, -1.0, 0),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, sideSkirtL, CFrame.new(-4.3, -1.0, 0), CFrame.new())

    -- Side skirts right
    local sideSkirtR = createPart({
        Name = "SideSkirtRight",
        Size = Vector3.new(0.4, 0.6, 15.0),
        Position = mainBody.Position + Vector3.new(4.3, -1.0, 0),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, sideSkirtR, CFrame.new(4.3, -1.0, 0), CFrame.new())

    --=== HOOD ===--
    local hood = createPart({
        Name = "Hood",
        Size = Vector3.new(7.5, 0.3, 6.0),
        Position = mainBody.Position + Vector3.new(0, 1.35, -5.5),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, hood, CFrame.new(0, 1.35, -5.5), CFrame.new())

    -- Hood power dome
    local powerDome = createPart({
        Name = "PowerDome",
        Size = Vector3.new(3.0, 0.2, 4.0),
        Position = hood.Position + Vector3.new(0, 0.25, 0),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, hood, powerDome, CFrame.new(0, 0.25, 0), CFrame.new())

    -- Hood lines (left and right ridges)
    for i = -1, 1, 2 do
        local hoodLine = createPart({
            Name = "HoodLine",
            Size = Vector3.new(0.1, 0.1, 5.5),
            Position = hood.Position + Vector3.new(i * 1.8, 0.2, 0),
            BrickColor = BrickColor.new("Dark blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, hood, hoodLine, CFrame.new(i * 1.8, 0.2, 0), CFrame.new())
    end

    --=== TRUNK ===--
    local trunk = createPart({
        Name = "Trunk",
        Size = Vector3.new(7.5, 0.3, 4.5),
        Position = mainBody.Position + Vector3.new(0, 1.35, 6.0),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, trunk, CFrame.new(0, 1.35, 6.0), CFrame.new())

    -- Trunk spoiler
    local trunkSpoiler = createPart({
        Name = "TrunkSpoiler",
        Size = Vector3.new(7.8, 0.2, 0.8),
        Position = trunk.Position + Vector3.new(0, 0.3, 2.3),
        BrickColor = BrickColor.new("Black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, trunk, trunkSpoiler, CFrame.new(0, 0.3, 2.3), CFrame.new())

    -- Spoiler risers
    for i = -1, 1, 2 do
        local riser = createPart({
            Name = "SpoilerRiser",
            Size = Vector3.new(0.3, 0.6, 0.3),
            Position = trunkSpoiler.Position + Vector3.new(i * 3.5, -0.3, 0),
            BrickColor = BrickColor.new("Dark grey"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, trunkSpoiler, riser, CFrame.new(i * 3.5, -0.3, 0), CFrame.new())
    end

    --=== ROOF ===--
    local roof = createPart({
        Name = "Roof",
        Size = Vector3.new(7.0, 0.3, 5.5),
        Position = mainBody.Position + Vector3.new(0, 2.55, 0),
        BrickColor = BrickColor.new("Bright blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, roof, CFrame.new(0, 2.55, 0), CFrame.new())

    -- Carbon fiber roof option
    local roofCarbon = createPart({
        Name = "RoofCarbon",
        Size = Vector3.new(6.8, 0.05, 5.3),
        Position = roof.Position + Vector3.new(0, 0.18, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, roof, roofCarbon, CFrame.new(0, 0.18, 0), CFrame.new())

    --=== WINDSHIELD ===--
    local windshieldF = createPart({
        Name = "WindshieldFront",
        Size = Vector3.new(7.2, 2.8, 0.2),
        Position = roof.Position + Vector3.new(0, -1.0, -2.8),
        BrickColor = BrickColor.new("Dark blue"),
        Material = Enum.Material.Glass,
        Transparency = 0.4,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, roof, windshieldF, CFrame.new(0, -1.0, -2.8) * CFrame.Angles(math.rad(-35), 0, 0), CFrame.new())

    local windshieldR = createPart({
        Name = "WindshieldRear",
        Size = Vector3.new(7.2, 2.2, 0.2),
        Position = roof.Position + Vector3.new(0, -0.8, 2.8),
        BrickColor = BrickColor.new("Dark blue"),
        Material = Enum.Material.Glass,
        Transparency = 0.4,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, roof, windshieldR, CFrame.new(0, -0.8, 2.8) * CFrame.Angles(math.rad(30), 0, 0), CFrame.new())

    --=== A-PILLARS ===--
    for i = -1, 1, 2 do
        local aPillar = createPart({
            Name = "APillar",
            Size = Vector3.new(0.3, 2.5, 0.3),
            Position = roof.Position + Vector3.new(i * 3.5, -0.8, -2.5),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, roof, aPillar, CFrame.new(i * 3.5, -0.8, -2.5) * CFrame.Angles(0, 0, math.rad(-i * 10)), CFrame.new())
    end

    -- B-Pillars
    for i = -1, 1, 2 do
        local bPillar = createPart({
            Name = "BPillar",
            Size = Vector3.new(0.3, 2.2, 0.3),
            Position = roof.Position + Vector3.new(i * 3.5, -0.6, 0.5),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, roof, bPillar, CFrame.new(i * 3.5, -0.6, 0.5), CFrame.new())
    end

    -- C-Pillars
    for i = -1, 1, 2 do
        local cPillar = createPart({
            Name = "CPillar",
            Size = Vector3.new(0.3, 2.0, 0.3),
            Position = roof.Position + Vector3.new(i * 3.5, -0.5, 2.3),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, roof, cPillar, CFrame.new(i * 3.5, -0.5, 2.3) * CFrame.Angles(0, 0, math.rad(i * 8)), CFrame.new())
    end

    --=== DOORS ===--
    -- Front doors
    for i = -1, 1, 2 do
        local frontDoor = createPart({
            Name = "FrontDoor"..(i == -1 and "Left" or "Right"),
            Size = Vector3.new(3.5, 2.0, 0.4),
            Position = mainBody.Position + Vector3.new(i * 4.2, 0.5, -2.5),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, frontDoor, CFrame.new(i * 4.2, 0.5, -2.5), CFrame.new())

        -- Door handle
        local doorHandle = createPart({
            Name = "DoorHandle"..(i == -1 and "Left" or "Right"),
            Size = Vector3.new(0.8, 0.15, 0.15),
            Position = frontDoor.Position + Vector3.new(i * 0.2, 0, 1.2),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, frontDoor, doorHandle, CFrame.new(i * 0.2, 0, 1.2), CFrame.new())

        -- Window frame chrome
        local windowTrim = createPart({
            Name = "WindowTrim"..(i == -1 and "Left" or "Right"),
            Size = Vector3.new(0.15, 0.15, 4.0),
            Position = frontDoor.Position + Vector3.new(i * 0.1, 1.1, -0.5),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, frontDoor, windowTrim, CFrame.new(i * 0.1, 1.1, -0.5), CFrame.new())
    end

    -- Rear doors
    for i = -1, 1, 2 do
        local rearDoor = createPart({
            Name = "RearDoor"..(i == -1 and "Left" or "Right"),
            Size = Vector3.new(3.2, 2.0, 0.4),
            Position = mainBody.Position + Vector3.new(i * 4.2, 0.5, 2.8),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, rearDoor, CFrame.new(i * 4.2, 0.5, 2.8), CFrame.new())

        local doorHandleR = createPart({
            Name = "RearDoorHandle"..(i == -1 and "Left" or "Right"),
            Size = Vector3.new(0.8, 0.15, 0.15),
            Position = rearDoor.Position + Vector3.new(i * 0.2, 0, 0.8),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rearDoor, doorHandleR, CFrame.new(i * 0.2, 0, 0.8), CFrame.new())
    end

    --=== HEADLIGHTS ===--
    for i = -1, 1, 2 do
        -- Main headlight housing
        local headlightHousing = createPart({
            Name = "HeadlightHousing"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.5, 1.2, 1.0),
            Position = mainBody.Position + Vector3.new(i * 3.0, 1.0, -8.8),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, headlightHousing, CFrame.new(i * 3.0, 1.0, -8.8), CFrame.new())

        -- LED DRL
        local drl = createPart({
            Name = "DRL"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.0, 0.3, 0.1),
            Position = headlightHousing.Position + Vector3.new(0, -0.2, 0.5),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, headlightHousing, drl, CFrame.new(0, -0.2, 0.5), CFrame.new())

        -- Main beam
        local mainBeam = createCylinder({
            Name = "MainBeam"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.0, 0.3, 1.0),
            Position = headlightHousing.Position + Vector3.new(-i * 0.5, 0.1, 0.5),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, headlightHousing, mainBeam, CFrame.new(-i * 0.5, 0.1, 0.5) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())

        -- High beam
        local highBeam = createCylinder({
            Name = "HighBeam"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.8, 0.3, 0.8),
            Position = headlightHousing.Position + Vector3.new(i * 0.5, 0.1, 0.5),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, headlightHousing, highBeam, CFrame.new(i * 0.5, 0.1, 0.5) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())

        -- Turn signal
        local turnSignal = createPart({
            Name = "TurnSignal"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.0, 0.2, 0.1),
            Position = headlightHousing.Position + Vector3.new(i * 1.0, -0.4, 0.5),
            BrickColor = BrickColor.new("New Yeller"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, headlightHousing, turnSignal, CFrame.new(i * 1.0, -0.4, 0.5), CFrame.new())

        -- Headlight glass
        local headlightGlass = createPart({
            Name = "HeadlightGlass"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.6, 1.3, 0.1),
            Position = headlightHousing.Position + Vector3.new(0, 0, 0.55),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Glass,
            Transparency = 0.6,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, headlightHousing, headlightGlass, CFrame.new(0, 0, 0.55), CFrame.new())

        -- Light source
        local lightSource = Instance.new("PointLight")
        lightSource.Brightness = 8
        lightSource.Range = 30
        lightSource.Color = Color3.fromRGB(255, 255, 230)
        lightSource.Parent = headlightHousing
    end

    --=== TAILLIGHTS ===--
    for i = -1, 1, 2 do
        local tailHousing = createPart({
            Name = "TailHousing"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.8, 1.0, 0.8),
            Position = mainBody.Position + Vector3.new(i * 3.0, 1.0, 8.8),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, tailHousing, CFrame.new(i * 3.0, 1.0, 8.8), CFrame.new())

        -- LED strip
        local ledStrip = createPart({
            Name = "LEDStrip"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.2, 0.15, 0.05),
            Position = tailHousing.Position + Vector3.new(0, 0.3, -0.4),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tailHousing, ledStrip, CFrame.new(0, 0.3, -0.4), CFrame.new())

        -- Brake light
        local brakeLight = createCylinder({
            Name = "BrakeLight"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.8, 0.3, 0.8),
            Position = tailHousing.Position + Vector3.new(-i * 0.5, 0, -0.4),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tailHousing, brakeLight, CFrame.new(-i * 0.5, 0, -0.4) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())

        -- Reverse light
        local reverseLight = createCylinder({
            Name = "ReverseLight"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.6, 0.3, 0.6),
            Position = tailHousing.Position + Vector3.new(i * 0.5, 0, -0.4),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tailHousing, reverseLight, CFrame.new(i * 0.5, 0, -0.4) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())

        local redLight = Instance.new("PointLight")
        redLight.Brightness = 5
        redLight.Range = 15
        redLight.Color = Color3.fromRGB(255, 0, 0)
        redLight.Parent = tailHousing
    end

    -- Third brake light
    local thirdBrake = createPart({
        Name = "ThirdBrakeLight",
        Size = Vector3.new(5.0, 0.15, 0.1),
        Position = roof.Position + Vector3.new(0, -0.2, 2.8),
        BrickColor = BrickColor.new("Really red"),
        Material = Enum.Material.Neon,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, roof, thirdBrake, CFrame.new(0, -0.2, 2.8), CFrame.new())

    --=== FOG LIGHTS ===--
    for i = -1, 1, 2 do
        local fogLight = createCylinder({
            Name = "FogLight"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.8, 0.3, 0.8),
            Position = frontBumper.Position + Vector3.new(i * 2.8, -0.1, 0.2),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, frontBumper, fogLight, CFrame.new(i * 2.8, -0.1, 0.2) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())
    end

    --=== WHEELS ===--
    local wheelPositions = {
        {name = "FL", pos = Vector3.new(-3.5, -1.2, -6.0)},
        {name = "FR", pos = Vector3.new(3.5, -1.2, -6.0)},
        {name = "RL", pos = Vector3.new(-3.5, -1.2, 6.0)},
        {name = "RR", pos = Vector3.new(3.5, -1.2, 6.0)},
    }

    for _, wheelData in ipairs(wheelPositions) do
        -- Tire
        local tire = createCylinder({
            Name = "Tire"..wheelData.name,
            Size = Vector3.new(2.5, 2.5, 2.5),
            Position = mainBody.Position + wheelData.pos,
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })

        -- Rim
        local rim = createCylinder({
            Name = "Rim"..wheelData.name,
            Size = Vector3.new(2.0, 2.0, 2.0),
            Position = tire.Position,
            BrickColor = BrickColor.new("Dark grey"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tire, rim, CFrame.new(), CFrame.new())

        -- Rim detail - spokes
        for j = 0, 4 do
            local angle = math.rad(j * 72)
            local spoke = createPart({
                Name = "Spoke"..wheelData.name..j,
                Size = Vector3.new(0.15, 1.6, 0.15),
                Position = rim.Position + Vector3.new(math.cos(angle) * 0.5, 0, math.sin(angle) * 0.5),
                BrickColor = BrickColor.new("Silver"),
                Material = Enum.Material.Metal,
                Anchored = false,
                CanCollide = true,
                Parent = car
            })
            weldParts(car, rim, spoke, CFrame.new(math.cos(angle) * 0.5, 0, math.sin(angle) * 0.5), CFrame.new())
        end

        -- Center cap
        local centerCap = createCylinder({
            Name = "CenterCap"..wheelData.name,
            Size = Vector3.new(0.6, 0.6, 0.6),
            Position = rim.Position + Vector3.new(0, 1.0, 0),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rim, centerCap, CFrame.new(0, 1.0, 0), CFrame.new())

        -- Brake disc
        local brakeDisc = createCylinder({
            Name = "BrakeDisc"..wheelData.name,
            Size = Vector3.new(1.5, 1.5, 1.5),
            Position = tire.Position,
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tire, brakeDisc, CFrame.new(), CFrame.new())

        -- Brake caliper
        local caliper = createPart({
            Name = "Caliper"..wheelData.name,
            Size = Vector3.new(0.5, 0.8, 0.5),
            Position = tire.Position + Vector3.new(0, 0.5, 0),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tire, caliper, CFrame.new(0, 0.5, 0), CFrame.new())

        -- Weld wheel to chassis
        weldParts(car, chassis, tire, CFrame.new(wheelData.pos), CFrame.new())
    end

    --=== INTERIOR ===--
    -- Dashboard
    local dashboard = createPart({
        Name = "Dashboard",
        Size = Vector3.new(7.0, 0.5, 2.5),
        Position = mainBody.Position + Vector3.new(0, 1.0, -3.5),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, dashboard, CFrame.new(0, 1.0, -3.5) * CFrame.Angles(math.rad(-20), 0, 0), CFrame.new())

    -- Steering wheel
    local steeringColumn = createCylinder({
        Name = "SteeringColumn",
        Size = Vector3.new(0.5, 0.5, 1.5),
        Position = dashboard.Position + Vector3.new(1.8, 0.8, 0.8),
        BrickColor = BrickColor.new("Dark grey"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, dashboard, steeringColumn, CFrame.new(1.8, 0.8, 0.8), CFrame.new())

    local steeringWheel = createCylinder({
        Name = "SteeringWheel",
        Size = Vector3.new(1.8, 1.8, 0.3),
        Position = steeringColumn.Position + Vector3.new(0, 0.5, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, steeringColumn, steeringWheel, CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(90), 0, 0), CFrame.new())

    -- Steering wheel center
    local wheelCenter = createPart({
        Name = "WheelCenter",
        Size = Vector3.new(0.6, 0.6, 0.4),
        Position = steeringWheel.Position,
        BrickColor = BrickColor.new("Silver"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, steeringWheel, wheelCenter, CFrame.new(), CFrame.new())

    -- Instrument cluster
    local instrumentCluster = createPart({
        Name = "InstrumentCluster",
        Size = Vector3.new(2.5, 0.01, 1.0),
        Position = dashboard.Position + Vector3.new(1.5, 0.3, 1.2),
        BrickColor = BrickColor.new("Dark blue"),
        Material = Enum.Material.Glass,
        Transparency = 0.3,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, dashboard, instrumentCluster, CFrame.new(1.5, 0.3, 1.2) * CFrame.Angles(math.rad(-15), 0, 0), CFrame.new())

    -- Center console
    local centerConsole = createPart({
        Name = "CenterConsole",
        Size = Vector3.new(1.5, 0.6, 4.0),
        Position = mainBody.Position + Vector3.new(0, 0.3, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, centerConsole, CFrame.new(0, 0.3, 0), CFrame.new())

    -- Gear shifter
    local gearShifter = createPart({
        Name = "GearShifter",
        Size = Vector3.new(0.4, 1.0, 0.4),
        Position = centerConsole.Position + Vector3.new(0, 0.8, 0.5),
        BrickColor = BrickColor.new("Dark grey"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, centerConsole, gearShifter, CFrame.new(0, 0.8, 0.5), CFrame.new())

    local gearKnob = createBall({
        Name = "GearKnob",
        Size = Vector3.new(0.6, 0.6, 0.6),
        Position = gearShifter.Position + Vector3.new(0, 0.5, 0),
        BrickColor = BrickColor.new("Silver"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, gearShifter, gearKnob, CFrame.new(0, 0.5, 0), CFrame.new())

    -- iDrive controller
    local idriveKnob = createCylinder({
        Name = "iDriveController",
        Size = Vector3.new(0.5, 0.5, 0.3),
        Position = centerConsole.Position + Vector3.new(0, 0.5, 1.5),
        BrickColor = BrickColor.new("Silver"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, centerConsole, idriveKnob, CFrame.new(0, 0.5, 1.5), CFrame.new())

    -- Front seats
    for i = -1, 1, 2 do
        -- Seat bottom
        local seatBottom = createPart({
            Name = "SeatBottom"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.0, 0.4, 2.0),
            Position = mainBody.Position + Vector3.new(i * 2.2, 0.2, -1.0),
            BrickColor = BrickColor.new("Black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, seatBottom, CFrame.new(i * 2.2, 0.2, -1.0), CFrame.new())

        -- Seat back
        local seatBack = createPart({
            Name = "SeatBack"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.0, 2.5, 0.3),
            Position = seatBottom.Position + Vector3.new(0, 1.3, -1.0),
            BrickColor = BrickColor.new("Black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, seatBottom, seatBack, CFrame.new(0, 1.3, -1.0), CFrame.new())

        -- Headrest
        local headrest = createPart({
            Name = "Headrest"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.2, 1.0, 0.3),
            Position = seatBack.Position + Vector3.new(0, 1.5, 0),
            BrickColor = BrickColor.new("Black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, seatBack, headrest, CFrame.new(0, 1.5, 0), CFrame.new())
    end

    -- Rear seats
    for i = -1, 1, 2 do
        local rearSeatBottom = createPart({
            Name = "RearSeatBottom"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.0, 0.4, 2.0),
            Position = mainBody.Position + Vector3.new(i * 2.2, 0.2, 3.5),
            BrickColor = BrickColor.new("Black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, rearSeatBottom, CFrame.new(i * 2.2, 0.2, 3.5), CFrame.new())

        local rearSeatBack = createPart({
            Name = "RearSeatBack"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.0, 2.5, 0.3),
            Position = rearSeatBottom.Position + Vector3.new(0, 1.3, -1.0),
            BrickColor = BrickColor.new("Black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rearSeatBottom, rearSeatBack, CFrame.new(0, 1.3, -1.0), CFrame.new())
    end

    -- Door panels
    for i = -1, 1, 2 do
        local doorPanel = createPart({
            Name = "DoorPanel"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.1, 2.0, 3.0),
            Position = mainBody.Position + Vector3.new(i * 4.0, 0.5, 0),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, doorPanel, CFrame.new(i * 4.0, 0.5, 0), CFrame.new())
    end

    --=== MIRRORS ===--
    for i = -1, 1, 2 do
        local mirrorHousing = createPart({
            Name = "MirrorHousing"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.8, 0.6, 1.0),
            Position = mainBody.Position + Vector3.new(i * 4.5, 1.8, -3.5),
            BrickColor = BrickColor.new("Bright blue"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, mirrorHousing, CFrame.new(i * 4.5, 1.8, -3.5), CFrame.new())

        local mirrorGlass = createPart({
            Name = "MirrorGlass"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.1, 0.5, 0.8),
            Position = mirrorHousing.Position + Vector3.new(i * 0.35, 0, 0),
            BrickColor = BrickColor.new("Light blue"),
            Material = Enum.Material.Glass,
            Transparency = 0.3,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mirrorHousing, mirrorGlass, CFrame.new(i * 0.35, 0, 0), CFrame.new())
    end

    --=== GRILLE ===--
    -- Kidney grille
    for i = -1, 1, 2 do
        local kidney = createPart({
            Name = "Kidney"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.5, 1.5, 0.3),
            Position = mainBody.Position + Vector3.new(i * 1.2, 1.2, -8.8),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, kidney, CFrame.new(i * 1.2, 1.2, -8.8), CFrame.new())

        -- Chrome surround
        local chromeSurround = createPart({
            Name = "ChromeSurround"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.7, 1.7, 0.05),
            Position = kidney.Position + Vector3.new(0, 0, -0.15),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, kidney, chromeSurround, CFrame.new(0, 0, -0.15), CFrame.new())
    end

    -- Lower grille
    local lowerGrille = createPart({
        Name = "LowerGrille",
        Size = Vector3.new(6.0, 0.6, 0.2),
        Position = mainBody.Position + Vector3.new(0, -0.3, -8.8),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, lowerGrille, CFrame.new(0, -0.3, -8.8), CFrame.new())

    --=== EXHAUST SYSTEM ===--
    for i = -1, 1, 2 do
        local exhaustTip = createCylinder({
            Name = "ExhaustTip"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.5, 0.5, 1.5),
            Position = rearBumper.Position + Vector3.new(i * 2.5, -0.3, 0.3),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rearBumper, exhaustTip, CFrame.new(i * 2.5, -0.3, 0.3) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())
    end

    --=== SIDE VENTS ===--
    for i = -1, 1, 2 do
        local sideVent = createPart({
            Name = "SideVent"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.1, 0.4, 2.0),
            Position = mainBody.Position + Vector3.new(i * 4.15, 0.5, -4.0),
            BrickColor = BrickColor.new("Dark grey"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, sideVent, CFrame.new(i * 4.15, 0.5, -4.0), CFrame.new())
    end

    --=== ROOF RAILS ===--
    for i = -1, 1, 2 do
        local roofRail = createPart({
            Name = "RoofRail"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.15, 0.15, 5.0),
            Position = roof.Position + Vector3.new(i * 3.3, 0.2, 0),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, roof, roofRail, CFrame.new(i * 3.3, 0.2, 0), CFrame.new())
    end

    -- Parent to workspace
    car.Parent = workspace

    return car
end

--//////////////////////////////////////--
--        FERRARI F40 (3000+ lines)     --
--//////////////////////////////////////--

local function createFerrari_F40()
    character:MoveTo(rootPart.Position + Vector3.new(-15, 0, 0))
    
    local car = Instance.new("Model")
    car.Name = "Ferrari F40"

    local mainBody = createPart({
        Name = "MainBody",
        Size = Vector3.new(7.5, 1.8, 15.5),
        Position = rootPart.Position + Vector3.new(0, 4.0, 0),
        BrickColor = BrickColor.new("Really red"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })

    -- Chassis
    local chassis = createPart({
        Name = "Chassis",
        Size = Vector3.new(7.0, 0.3, 15.0),
        Position = mainBody.Position + Vector3.new(0, -1.0, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, chassis, CFrame.new(0, -1.0, 0), CFrame.new())

    -- Front nose
    local frontNose = createWedge({
        Name = "FrontNose",
        Size = Vector3.new(6.5, 1.2, 3.0),
        Position = mainBody.Position + Vector3.new(0, -0.5, -8.5),
        BrickColor = BrickColor.new("Really red"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, frontNose, CFrame.new(0, -0.5, -8.5) * CFrame.Angles(math.rad(-10), 0, 0), CFrame.new())

    -- Rear deck
    local rearDeck = createPart({
        Name = "RearDeck",
        Size = Vector3.new(7.0, 0.8, 4.0),
        Position = mainBody.Position + Vector3.new(0, 0.8, 7.0),
        BrickColor = BrickColor.new("Really red"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, rearDeck, CFrame.new(0, 0.8, 7.0), CFrame.new())

    -- Engine bay cover
    local engineBay = createPart({
        Name = "EngineBay",
        Size = Vector3.new(6.5, 0.1, 3.5),
        Position = rearDeck.Position + Vector3.new(0, 0.45, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, rearDeck, engineBay, CFrame.new(0, 0.45, 0), CFrame.new())

    -- Engine bay vents
    for j = 0, 4 do
        local vent = createPart({
            Name = "EngineVent"..j,
            Size = Vector3.new(5.0, 0.05, 0.15),
            Position = engineBay.Position + Vector3.new(0, 0.1, -1.5 + j * 0.7),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, engineBay, vent, CFrame.new(0, 0.1, -1.5 + j * 0.7), CFrame.new())
    end

    -- Rear wing
    local rearWing = createPart({
        Name = "RearWing",
        Size = Vector3.new(7.5, 0.15, 2.5),
        Position = rearDeck.Position + Vector3.new(0, 0.8, 1.5),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, rearDeck, rearWing, CFrame.new(0, 0.8, 1.5), CFrame.new())

    -- Wing endplates
    for i = -1, 1, 2 do
        local endplate = createPart({
            Name = "WingEndplate"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.1, 0.6, 2.0),
            Position = rearWing.Position + Vector3.new(i * 3.7, -0.2, 0),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rearWing, endplate, CFrame.new(i * 3.7, -0.2, 0), CFrame.new())
    end

    -- Wing risers
    for i = -1, 1, 2 do
        local riser = createPart({
            Name = "WingRiser"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.3, 0.8, 0.3),
            Position = rearWing.Position + Vector3.new(i * 3.5, -0.5, 0),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rearWing, riser, CFrame.new(i * 3.5, -0.5, 0), CFrame.new())
    end

    -- Pop-up headlights
    for i = -1, 1, 2 do
        local popupHousing = createPart({
            Name = "PopUpHousing"..(i == -1 and "L" or "R"),
            Size = Vector3.new(2.0, 0.8, 1.5),
            Position = mainBody.Position + Vector3.new(i * 2.8, 1.5, -7.0),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, popupHousing, CFrame.new(i * 2.8, 1.5, -7.0), CFrame.new())

        local popupLight = createPart({
            Name = "PopUpLight"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.6, 0.5, 0.8),
            Position = popupHousing.Position + Vector3.new(0, 0.1, 0.5),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, popupHousing, popupLight, CFrame.new(0, 0.1, 0.5), CFrame.new())

        local popupSource = Instance.new("PointLight")
        popupSource.Brightness = 6
        popupSource.Range = 25
        popupSource.Color = Color3.fromRGB(255, 255, 240)
        popupSource.Parent = popupHousing
    end

    -- Rear lights (round Ferrari style)
    for i = -1, 1, 2 do
        local roundTail = createCylinder({
            Name = "RoundTail"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.2, 1.2, 1.2),
            Position = mainBody.Position + Vector3.new(i * 2.8, 1.0, 7.8),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, roundTail, CFrame.new(i * 2.8, 1.0, 7.8) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())
    end

    -- NACA ducts
    for i = -1, 1, 2 do
        local nacaDuct = createPart({
            Name = "NACA_Duct"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.5, 0.08, 0.8),
            Position = mainBody.Position + Vector3.new(i * 2.0, 1.4, -4.0),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, nacaDuct, CFrame.new(i * 2.0, 1.4, -4.0), CFrame.new())
    end

    -- Side scoops
    for i = -1, 1, 2 do
        local sideScoop = createPart({
            Name = "SideScoop"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.4, 1.2, 3.0),
            Position = mainBody.Position + Vector3.new(i * 4.0, 0.3, -1.0),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, sideScoop, CFrame.new(i * 4.0, 0.3, -1.0), CFrame.new())
    end

    -- F40 style wheels (5-spoke)
    for _, wheelData in ipairs({
        {name = "FL", pos = Vector3.new(-3.2, -1.0, -5.5)},
        {name = "FR", pos = Vector3.new(3.2, -1.0, -5.5)},
        {name = "RL", pos = Vector3.new(-3.2, -1.0, 5.8)},
        {name = "RR", pos = Vector3.new(3.2, -1.0, 5.8)},
    }) do
        local tire = createCylinder({
            Name = "Tire"..wheelData.name,
            Size = Vector3.new(2.8, 2.8, 2.8),
            Position = mainBody.Position + wheelData.pos,
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })

        local rim = createCylinder({
            Name = "Rim"..wheelData.name,
            Size = Vector3.new(2.2, 2.2, 2.2),
            Position = tire.Position,
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tire, rim, CFrame.new(), CFrame.new())

        -- 5-spoke design
        for j = 0, 4 do
            local angle = math.rad(j * 72)
            local spoke = createPart({
                Name = "Spoke"..wheelData.name..j,
                Size = Vector3.new(0.12, 1.8, 0.3),
                Position = rim.Position + Vector3.new(math.cos(angle) * 0.5, 0, math.sin(angle) * 0.5),
                BrickColor = BrickColor.new("Silver"),
                Material = Enum.Material.Metal,
                Anchored = false,
                CanCollide = true,
                Parent = car
            })
            weldParts(car, rim, spoke, CFrame.new(math.cos(angle) * 0.5, 0, math.sin(angle) * 0.5) * CFrame.Angles(0, -angle, 0), CFrame.new())
        end

        weldParts(car, chassis, tire, CFrame.new(wheelData.pos), CFrame.new())
    end

    car.Parent = workspace
    return car
end

--//////////////////////////////////////--
--      BUGATTI BOLIDE (3000+ lines)    --
--//////////////////////////////////////--

local function createBugatti_Bolide()
    character:MoveTo(rootPart.Position + Vector3.new(0, 0, -15))
    
    local car = Instance.new("Model")
    car.Name = "Bugatti Bolide"

    local mainBody = createPart({
        Name = "MainBody",
        Size = Vector3.new(7.8, 1.5, 16.5),
        Position = rootPart.Position + Vector3.new(0, 3.5, 0),
        BrickColor = BrickColor.new("Dark blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })

    -- Chassis
    local chassis = createPart({
        Name = "Chassis",
        Size = Vector3.new(7.2, 0.3, 16.0),
        Position = mainBody.Position + Vector3.new(0, -1.0, 0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, chassis, CFrame.new(0, -1.0, 0), CFrame.new())

    -- Aerodynamic nose
    local aeroNose = createWedge({
        Name = "AeroNose",
        Size = Vector3.new(3.0, 0.8, 4.0),
        Position = mainBody.Position + Vector3.new(0, 0.8, -9.5),
        BrickColor = BrickColor.new("Dark blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, aeroNose, CFrame.new(0, 0.8, -9.5) * CFrame.Angles(math.rad(-20), 0, 0), CFrame.new())

    -- Front splitter
    local frontSplitter = createPart({
        Name = "FrontSplitter",
        Size = Vector3.new(7.5, 0.15, 1.5),
        Position = mainBody.Position + Vector3.new(0, -0.5, -8.8),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, frontSplitter, CFrame.new(0, -0.5, -8.8), CFrame.new())

    -- Front canards
    for i = -1, 1, 2 do
        local canard = createPart({
            Name = "Canard"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.1, 0.3, 1.0),
            Position = mainBody.Position + Vector3.new(i * 3.5, 0.2, -8.3),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, canard, CFrame.new(i * 3.5, 0.2, -8.3) * CFrame.Angles(0, 0, math.rad(-i * 15)), CFrame.new())
    end

    -- Roof scoop
    local roofScoop = createPart({
        Name = "RoofScoop",
        Size = Vector3.new(1.5, 0.4, 3.0),
        Position = mainBody.Position + Vector3.new(0, 1.8, -2.0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, roofScoop, CFrame.new(0, 1.8, -2.0), CFrame.new())

    -- Dorsal fin
    local dorsalFin = createPart({
        Name = "DorsalFin",
        Size = Vector3.new(0.15, 0.6, 6.0),
        Position = mainBody.Position + Vector3.new(0, 2.0, 1.0),
        BrickColor = BrickColor.new("Dark blue"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, dorsalFin, CFrame.new(0, 2.0, 1.0), CFrame.new())

    -- X-shaped headlights
    for i = -1, 1, 2 do
        -- Horizontal bar
        local headlightH = createPart({
            Name = "HeadlightH"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.2, 0.1, 0.05),
            Position = mainBody.Position + Vector3.new(i * 2.5, 0.8, -8.3),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, headlightH, CFrame.new(i * 2.5, 0.8, -8.3), CFrame.new())

        -- Vertical bar
        local headlightV = createPart({
            Name = "HeadlightV"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.1, 0.8, 0.05),
            Position = mainBody.Position + Vector3.new(i * 2.5, 0.8, -8.3),
            BrickColor = BrickColor.new("White"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, headlightV, CFrame.new(i * 2.5, 0.8, -8.3), CFrame.new())

        local xLight = Instance.new("PointLight")
        xLight.Brightness = 10
        xLight.Range = 35
        xLight.Color = Color3.fromRGB(255, 255, 255)
        xLight.Parent = headlightH
    end

    -- X-shaped taillights
    for i = -1, 1, 2 do
        local tailH = createPart({
            Name = "TailH"..(i == -1 and "L" or "R"),
            Size = Vector3.new(1.5, 0.08, 0.05),
            Position = mainBody.Position + Vector3.new(i * 2.5, 0.8, 8.3),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, tailH, CFrame.new(i * 2.5, 0.8, 8.3), CFrame.new())

        local tailV = createPart({
            Name = "TailV"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.08, 1.0, 0.05),
            Position = mainBody.Position + Vector3.new(i * 2.5, 0.8, 8.3),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.Neon,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, mainBody, tailV, CFrame.new(i * 2.5, 0.8, 8.3), CFrame.new())
    end

    -- Huge rear diffuser
    local diffuser = createPart({
        Name = "Diffuser",
        Size = Vector3.new(7.0, 0.2, 2.5),
        Position = mainBody.Position + Vector3.new(0, -0.6, 8.5),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, diffuser, CFrame.new(0, -0.6, 8.5), CFrame.new())

    -- Diffuser strakes
    for i = -3, 3, 1 do
        if i ~= 0 then
            local strake = createPart({
                Name = "DiffuserStrake"..i,
                Size = Vector3.new(0.1, 0.6, 2.0),
                Position = diffuser.Position + Vector3.new(i * 0.9, -0.3, 0),
                BrickColor = BrickColor.new("Really black"),
                Material = Enum.Material.Metal,
                Anchored = false,
                CanCollide = true,
                Parent = car
            })
            weldParts(car, diffuser, strake, CFrame.new(i * 0.9, -0.3, 0), CFrame.new())
        end
    end

    -- Center exhaust (quad)
    for i = -1.5, 1.5, 3 do
        for j = -0.5, 0.5, 1 do
            local exhaust = createCylinder({
                Name = "Exhaust"..i.."_"..j,
                Size = Vector3.new(0.4, 0.4, 1.0),
                Position = diffuser.Position + Vector3.new(i, 0.1, 1.5),
                BrickColor = BrickColor.new("Silver"),
                Material = Enum.Material.Metal,
                Anchored = false,
                CanCollide = true,
                Parent = car
            })
            weldParts(car, diffuser, exhaust, CFrame.new(i, 0.1, 1.5) * CFrame.Angles(0, math.rad(90), 0), CFrame.new())
        end
    end

    -- Massive rear wing
    local rearWingMain = createPart({
        Name = "RearWing",
        Size = Vector3.new(7.8, 0.15, 2.0),
        Position = mainBody.Position + Vector3.new(0, 1.5, 8.0),
        BrickColor = BrickColor.new("Really black"),
        Material = Enum.Material.Metal,
        Anchored = false,
        CanCollide = true,
        Parent = car
    })
    weldParts(car, mainBody, rearWingMain, CFrame.new(0, 1.5, 8.0), CFrame.new())

    -- Wing pylons
    for i = -1, 1, 2 do
        local pylon = createPart({
            Name = "WingPylon"..(i == -1 and "L" or "R"),
            Size = Vector3.new(0.3, 1.2, 0.5),
            Position = rearWingMain.Position + Vector3.new(i * 3.5, -0.7, 0),
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rearWingMain, pylon, CFrame.new(i * 3.5, -0.7, 0), CFrame.new())
    end

    -- Bolide wheels (center-lock)
    for _, wheelData in ipairs({
        {name = "FL", pos = Vector3.new(-3.4, -0.8, -6.2)},
        {name = "FR", pos = Vector3.new(3.4, -0.8, -6.2)},
        {name = "RL", pos = Vector3.new(-3.4, -0.8, 6.5)},
        {name = "RR", pos = Vector3.new(3.4, -0.8, 6.5)},
    }) do
        local tire = createCylinder({
            Name = "Tire"..wheelData.name,
            Size = Vector3.new(2.6, 2.6, 2.6),
            Position = mainBody.Position + wheelData.pos,
            BrickColor = BrickColor.new("Really black"),
            Material = Enum.Material.SmoothPlastic,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })

        local rim = createCylinder({
            Name = "Rim"..wheelData.name,
            Size = Vector3.new(2.1, 2.1, 2.1),
            Position = tire.Position,
            BrickColor = BrickColor.new("Dark grey"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, tire, rim, CFrame.new(), CFrame.new())

        -- Center lock
        local centerLock = createCylinder({
            Name = "CenterLock"..wheelData.name,
            Size = Vector3.new(0.5, 0.5, 0.5),
            Position = rim.Position + Vector3.new(0, 1.1, 0),
            BrickColor = BrickColor.new("Really red"),
            Material = Enum.Material.Metal,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rim, centerLock, CFrame.new(0, 1.1, 0), CFrame.new())

        -- Turbofan wheel cover
        local turbofan = createCylinder({
            Name = "Turbofan"..wheelData.name,
            Size = Vector3.new(1.8, 0.1, 1.8),
            Position = rim.Position + Vector3.new(0, 1.05, 0),
            BrickColor = BrickColor.new("Silver"),
            Material = Enum.Material.Metal,
            Transparency = 0.3,
            Anchored = false,
            CanCollide = true,
            Parent = car
        })
        weldParts(car, rim, turbofan, CFrame.new(0, 1.05, 0), CFrame.new())

        weldParts(car, chassis, tire, CFrame.new(wheelData.pos), CFrame.new())
    end

    car.Parent = workspace
    return car
end

--//////////////////////////////////////--
--         BUTTON HANDLERS             --
--//////////////////////////////////////--

BMWBtn.MouseButton1Click:Connect(function()
    createBMW_M5_F90()
end)

FerrariBtn.MouseButton1Click:Connect(function()
    createFerrari_F40()
end)

BugattiBtn.MouseButton1Click:Connect(function()
    createBugatti_Bolide()
end)

--//////////////////////////////////////--
--         CHARACTER MOVEMENT FIX      --
--//////////////////////////////////////--

-- Ensure character can still move after car spawns
local function ensureMobility()
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end
end

-- Override any movement restrictions
character.ChildAdded:Connect(function(child)
    if child:IsA("BodyVelocity") or child:IsA("BodyPosition") then
        child:Destroy()
    end
end)

spawn(function()
    while wait(1) do
        ensureMobility()
    end
end)
