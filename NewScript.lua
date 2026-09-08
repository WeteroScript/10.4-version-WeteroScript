--[[
    MEREDIOS // v4.0
    Delta X (mobile)

    UI:
    - Light theme by default
    - Optional Dark theme
    - Smooth opening/closing
    - Draggable GUI
    - Draggable M launcher
    - Vertical scrolling on every page
    - Horizontal tab navigation
    - Main: compact 2-column functions

    ANTI-FLING:
    Local defensive protection only.
    Roblox client cannot reliably identify the network source of a physics impulse,
    so the protection uses a nearby-player + extreme-velocity heuristic.
]]

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================================================
-- CLEAN OLD INSTANCES
-- =========================================================

local oldGui = playerGui:FindFirstChild("MerediosGUI")
if oldGui then
    oldGui:Destroy()
end

local oldBoot = playerGui:FindFirstChild("MerediosBoot")
if oldBoot then
    oldBoot:Destroy()
end

-- =========================================================
-- THEMES
-- =========================================================

local THEMES = {

    Light = {
        bg       = Color3.fromRGB(245, 247, 252),
        panel    = Color3.fromRGB(255, 255, 255),
        panelHi  = Color3.fromRGB(235, 240, 249),

        accent1  = Color3.fromRGB(0, 178, 218),
        accent2  = Color3.fromRGB(115, 82, 235),
        accent3  = Color3.fromRGB(238, 75, 145),

        text     = Color3.fromRGB(28, 31, 42),
        textDim  = Color3.fromRGB(105, 112, 130),

        trackOff = Color3.fromRGB(214, 219, 231),
        knobOff  = Color3.fromRGB(145, 153, 170),

        danger   = Color3.fromRGB(214, 54, 65),
        shadow   = Color3.fromRGB(75, 85, 105),
        line     = Color3.fromRGB(190, 225, 238),
    },

    Dark = {
        bg       = Color3.fromRGB(29, 33, 43),
        panel    = Color3.fromRGB(39, 44, 56),
        panelHi  = Color3.fromRGB(50, 56, 70),

        accent1  = Color3.fromRGB(0, 190, 225),
        accent2  = Color3.fromRGB(125, 95, 240),
        accent3  = Color3.fromRGB(242, 80, 150),

        text     = Color3.fromRGB(238, 241, 248),
        textDim  = Color3.fromRGB(165, 172, 188),

        trackOff = Color3.fromRGB(68, 75, 91),
        knobOff  = Color3.fromRGB(122, 131, 149),

        danger   = Color3.fromRGB(235, 75, 85),
        shadow   = Color3.fromRGB(5, 7, 11),
        line     = Color3.fromRGB(72, 111, 126),
    }
}

-- Белая тема по умолчанию
local currentTheme = "Light"
local COLORS = THEMES[currentTheme]

-- =========================================================
-- TWEENS
-- =========================================================

local TWEEN_FAST = TweenInfo.new(
    0.16,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

local TWEEN_MED = TweenInfo.new(
    0.28,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

local TWEEN_SMOOTH = TweenInfo.new(
    0.36,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

local TWEEN_SLOW = TweenInfo.new(
    0.55,
    Enum.EasingStyle.Quint,
    Enum.EasingDirection.Out
)

local PAGE_COUNT = 16
local SWIPE_THRESHOLD = 120

-- =========================================================
-- HELPERS
-- =========================================================

local function tween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

local function addCorner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
    return c
end

local function addStroke(object, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function createLabel(
    parent,
    text,
    size,
    position,
    textSize,
    font
)
    local l = Instance.new("TextLabel")

    l.Size = size
    l.Position = position

    l.BackgroundTransparency = 1

    l.Text = text
    l.TextColor3 = COLORS.text
    l.TextSize = textSize

    l.Font = font or Enum.Font.Gotham

    l.TextXAlignment = Enum.TextXAlignment.Left

    l.Parent = parent

    return l
end

-- =========================================================
-- STATE
-- =========================================================

local speedValue = 16
local speedEnabled = false

local antiFlingEnabled = false

local humanoid = nil
local rootPart = nil

local mainVisible = false
local settingsOpen = false

local currentPage = 1
local switching = false

local dragging = false
local dragStart = nil
local dragOffset = nil

local mDragging = false
local mDragStart = nil
local mDragOffset = nil

local swipeStart = nil

-- =========================================================
-- CHARACTER
-- =========================================================

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local character = getCharacter()

    if character then
        humanoid = character:FindFirstChildOfClass("Humanoid")
    end

    return humanoid
end

local function getRootPart()
    local character = getCharacter()

    if character then
        rootPart = character:FindFirstChild("HumanoidRootPart")
    end

    return rootPart
end

-- =========================================================
-- ROOT GUI
-- =========================================================

local gui = Instance.new("ScreenGui")

gui.Name = "MerediosGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999

gui.Parent = playerGui

-- =========================================================
-- M LAUNCHER
-- =========================================================

local mButton = Instance.new("TextButton")

mButton.Name = "MerediosLauncher"

mButton.Size = UDim2.fromOffset(58, 58)

mButton.Position = UDim2.new(
    0.5,
    -29,
    0.78,
    0
)

mButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mButton.BorderSizePixel = 0

mButton.Text = "M"

mButton.TextColor3 = COLORS.accent1
mButton.TextSize = 24
mButton.Font = Enum.Font.GothamBlack

mButton.AutoButtonColor = false
mButton.Visible = false

mButton.ZIndex = 50

mButton.Parent = gui

addCorner(mButton, 18)

local mStroke = addStroke(
    mButton,
    COLORS.accent1,
    0.05,
    2
)

-- маленькая обводка букв
mButton.TextStrokeTransparency = 0.78
mButton.TextStrokeColor3 = COLORS.accent2

-- =========================================================
-- MAIN SHADOW
-- =========================================================

local shadow = Instance.new("ImageLabel")

shadow.Name = "Shadow"

shadow.Size = UDim2.fromOffset(
    380,
    318
)

shadow.Position = UDim2.new(
    0.5,
    -190,
    0.5,
    -169
)

shadow.BackgroundTransparency = 1

shadow.Image = "rbxassetid://5554236805"

shadow.ImageColor3 = COLORS.shadow
shadow.ImageTransparency = 1

shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(
    23,
    23,
    277,
    277
)

shadow.Visible = false
shadow.ZIndex = 1

shadow.Parent = gui

-- =========================================================
-- WINDOW
-- =========================================================

local window = Instance.new("CanvasGroup")

window.Name = "Window"

window.Size = UDim2.fromOffset(
    340,
    318
)

window.Position = UDim2.new(
    0.5,
    -170,
    0.5,
    -159
)

window.BackgroundColor3 = COLORS.bg

window.BorderSizePixel = 0

window.Active = true

window.GroupTransparency = 1

window.Visible = false

window.ZIndex = 5

window.Parent = gui

addCorner(window, 20)

local winStroke = addStroke(
    window,
    COLORS.accent1,
    0.20,
    1.5
)

local winGradient = Instance.new("UIGradient")

winGradient.Color = ColorSequence.new({

    ColorSequenceKeypoint.new(
        0,
        COLORS.panel
    ),

    ColorSequenceKeypoint.new(
        0.55,
        COLORS.bg
    ),

    ColorSequenceKeypoint.new(
        1,
        COLORS.panelHi
    ),
})

winGradient.Rotation = 115
winGradient.Parent = window

-- =========================================================
-- HEADER
-- =========================================================

local header = Instance.new("Frame")

header.Name = "Header"

header.Size = UDim2.new(
    1,
    0,
    0,
    70
)

header.BackgroundColor3 = COLORS.panel
header.BorderSizePixel = 0

header.ZIndex = 6

header.Parent = window

addCorner(header, 20)

local headerFix = Instance.new("Frame")

headerFix.Size = UDim2.new(
    1,
    0,
    0,
    18
)

headerFix.Position = UDim2.new(
    0,
    0,
    1,
    -18
)

headerFix.BackgroundColor3 = COLORS.panel
headerFix.BorderSizePixel = 0

headerFix.ZIndex = 6

headerFix.Parent = header

local headerGradient = Instance.new("UIGradient")

headerGradient.Color = ColorSequence.new({

    ColorSequenceKeypoint.new(
        0,
        COLORS.accent1
    ),

    ColorSequenceKeypoint.new(
        0.5,
        COLORS.accent2
    ),

    ColorSequenceKeypoint.new(
        1,
        COLORS.accent3
    ),
})

headerGradient.Transparency = NumberSequence.new({

    NumberSequenceKeypoint.new(
        0,
        0.90
    ),

    NumberSequenceKeypoint.new(
        0.55,
        0.94
    ),

    NumberSequenceKeypoint.new(
        1,
        0.98
    ),
})

headerGradient.Parent = header

-- =========================================================
-- STATUS DOT
-- =========================================================

local statusDot = Instance.new("Frame")

statusDot.Size = UDim2.fromOffset(
    10,
    10
)

statusDot.Position = UDim2.fromOffset(
    16,
    16
)

statusDot.BackgroundColor3 = COLORS.accent1
statusDot.BorderSizePixel = 0

statusDot.ZIndex = 8

statusDot.Parent = header

addCorner(statusDot, 10)

local dotGlow = addStroke(
    statusDot,
    COLORS.accent2,
    0.25,
    2
)

task.spawn(function()

    while statusDot.Parent do

        tween(
            statusDot,
            TweenInfo.new(
                1.1,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                BackgroundColor3 = COLORS.accent2
            }
        ):Play()

        tween(
            dotGlow,
            TweenInfo.new(
                1.1,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Transparency = 0.75
            }
        ):Play()

        task.wait(1.1)

        tween(
            statusDot,
            TweenInfo.new(
                1.1,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                BackgroundColor3 = COLORS.accent1
            }
        ):Play()

        tween(
            dotGlow,
            TweenInfo.new(
                1.1,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Transparency = 0.15
            }
        ):Play()

        task.wait(1.1)

    end

end)

-- =========================================================
-- TITLE
-- =========================================================

local title = createLabel(
    header,
    "M E R E D I O S",
    UDim2.new(1, -105, 0, 27),
    UDim2.fromOffset(34, 9),
    16,
    Enum.Font.GothamBold
)

title.ZIndex = 8

-- Уменьшенная обводка
title.TextStrokeTransparency = 0.82

-- =========================================================
-- SUBTITLE
-- =========================================================

local subtitle = createLabel(
    header,
    "оперативный контур  //  v4.0  //  drag / swipe",
    UDim2.new(1, -115, 0, 16),
    UDim2.fromOffset(34, 39),
    9,
    Enum.Font.Code
)

subtitle.ZIndex = 8
subtitle.TextColor3 = COLORS.textDim

-- =========================================================
-- CLOSE BUTTON
-- =========================================================

local closeBtn = Instance.new("TextButton")

closeBtn.Name = "Close"

closeBtn.Size = UDim2.fromOffset(
    38,
    38
)

closeBtn.Position = UDim2.new(
    1,
    -88,
    0,
    16
)

closeBtn.BackgroundColor3 = COLORS.panelHi

closeBtn.BorderSizePixel = 0

closeBtn.Text = "×"

closeBtn.TextColor3 = COLORS.text
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold

closeBtn.AutoButtonColor = false

closeBtn.ZIndex = 10

closeBtn.Parent = header

addCorner(closeBtn, 13)

local closeStroke = addStroke(
    closeBtn,
    COLORS.line,
    0.25,
    1
)

-- =========================================================
-- SETTINGS BUTTON
-- =========================================================

local settingsBtn = Instance.new("TextButton")

settingsBtn.Name = "Settings"

settingsBtn.Size = UDim2.fromOffset(
    38,
    38
)

settingsBtn.Position = UDim2.new(
    1,
    -45,
    0,
    16
)

settingsBtn.BackgroundColor3 = COLORS.panelHi

settingsBtn.BorderSizePixel = 0

settingsBtn.Text = "⚙"

settingsBtn.TextColor3 = COLORS.textDim

settingsBtn.TextSize = 21
settingsBtn.Font = Enum.Font.GothamBold

settingsBtn.AutoButtonColor = false

settingsBtn.ZIndex = 10

settingsBtn.Parent = header

addCorner(settingsBtn, 13)

local settingsStroke = addStroke(
    settingsBtn,
    COLORS.line,
    0.25,
    1
)

-- =========================================================
-- TAB BAR
-- =========================================================

local tabBar = Instance.new("ScrollingFrame")

tabBar.Name = "TabBar"

tabBar.Size = UDim2.new(
    1,
    -28,
    0,
    48
)

tabBar.Position = UDim2.fromOffset(
    14,
    80
)

tabBar.BackgroundColor3 = COLORS.panelHi

tabBar.BorderSizePixel = 0

tabBar.ScrollBarThickness = 0

tabBar.ScrollingDirection =
    Enum.ScrollingDirection.X

tabBar.CanvasSize =
    UDim2.new(0, 0, 0, 0)

tabBar.AutomaticCanvasSize =
    Enum.AutomaticSize.X

tabBar.ZIndex = 7

tabBar.Parent = window

addCorner(tabBar, 15)

local tabBarStroke = addStroke(
    tabBar,
    COLORS.line,
    0.15,
    1
)

local tabPadding = Instance.new("UIPadding")

tabPadding.PaddingLeft = UDim.new(0, 6)
tabPadding.PaddingRight = UDim.new(0, 6)

tabPadding.PaddingTop = UDim.new(0, 6)
tabPadding.PaddingBottom = UDim.new(0, 6)

tabPadding.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")

tabLayout.FillDirection =
    Enum.FillDirection.Horizontal

tabLayout.Padding =
    UDim.new(0, 6)

tabLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

tabLayout.Parent = tabBar

-- =========================================================
-- CONTENT
-- =========================================================

local contentHolder = Instance.new("Frame")

contentHolder.Name = "Content"

contentHolder.Size = UDim2.new(
    1,
    -28,
    1,
    -142
)

contentHolder.Position =
    UDim2.fromOffset(
        14,
        136
    )

contentHolder.BackgroundTransparency = 1

contentHolder.ClipsDescendants = true

contentHolder.ZIndex = 6

contentHolder.Parent = window

local pages = {}
local scrolls = {}
local tabButtons = {}

local cards = {}
local cardTitles = {}

local accentLabels = {}
local dimLabels = {}

local controlRefs = {}

-- =========================================================
-- CREATE PAGE
-- =========================================================

local function createPage(order)

    local page = Instance.new("CanvasGroup")

    page.Name = "Page" .. order

    page.Size = UDim2.new(
        1,
        0,
        1,
        0
    )

    page.BackgroundTransparency = 1

    page.GroupTransparency = 1

    page.Visible = false

    page.ZIndex = 7

    page.Parent = contentHolder

    -- Каждый раздел имеет собственный вертикальный скролл
    local scroll = Instance.new("ScrollingFrame")

    scroll.Name = "Scroll"

    scroll.Size = UDim2.new(
        1,
        0,
        1,
        0
    )

    scroll.BackgroundTransparency = 1

    scroll.BorderSizePixel = 0

    scroll.ScrollBarThickness = 3

    scroll.ScrollBarImageColor3 =
        COLORS.accent1

    scroll.ScrollingDirection =
        Enum.ScrollingDirection.Y

    scroll.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    scroll.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    scroll.ElasticBehavior =
        Enum.ElasticBehavior.WhenScrollable

    scroll.ZIndex = 8

    scroll.Parent = page

    local padding = Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(0, 2)

    padding.PaddingRight =
        UDim.new(0, 4)

    padding.PaddingTop =
        UDim.new(0, 2)

    padding.PaddingBottom =
        UDim.new(0, 12)

    padding.Parent = scroll

    pages[order] = page
    scrolls[order] = scroll

    return page, scroll
end

-- =========================================================
-- CARD
-- =========================================================

local function makeCard(
    parent,
    height,
    layoutOrder
)

    local card = Instance.new("Frame")

    card.Size = UDim2.new(
        1,
        0,
        0,
        height
    )

    card.BackgroundColor3 =
        COLORS.panel

    card.BorderSizePixel = 0

    card.LayoutOrder =
        layoutOrder or 1

    card.ZIndex = 9

    card.Parent = parent

    addCorner(card, 14)

    local cardStroke = addStroke(
        card,
        COLORS.line,
        0.15,
        1
    )

    local gradient = Instance.new("UIGradient")

    gradient.Color =
        ColorSequence.new({

            ColorSequenceKeypoint.new(
                0,
                COLORS.panelHi
            ),

            ColorSequenceKeypoint.new(
                1,
                COLORS.panel
            ),
        })

    gradient.Rotation = 90

    gradient.Parent = card

    table.insert(
        cards,
        {
            object = card,
            stroke = cardStroke,
            gradient = gradient
        }
    )

    return card
end

local function makeCardTitle(
    card,
    text
)

    local l = createLabel(
        card,
        text,
        UDim2.new(
            1,
            -20,
            0,
            17
        ),
        UDim2.fromOffset(
            10,
            8
        ),
        11,
        Enum.Font.GothamBold
    )

    l.ZIndex = 11

    table.insert(
        cardTitles,
        l
    )

    return l
end

-- =========================================================
-- SMALL TOGGLE
-- =========================================================

local function makeToggle(
    parent,
    text,
    initial,
    callback
)

    local button = Instance.new("TextButton")

    button.Size = UDim2.fromOffset(
        116,
        32
    )

    button.BackgroundColor3 =
        COLORS.trackOff

    button.BorderSizePixel = 0

    button.Text = ""

    button.AutoButtonColor = false

    button.ZIndex = 12

    button.Parent = parent

    addCorner(button, 16)

    local buttonStroke = addStroke(
        button,
        COLORS.line,
        0.25,
        1
    )

    local knob = Instance.new("Frame")

    knob.Size = UDim2.fromOffset(
        24,
        24
    )

    knob.Position = UDim2.fromOffset(
        4,
        4
    )

    knob.BackgroundColor3 =
        COLORS.knobOff

    knob.BorderSizePixel = 0

    knob.ZIndex = 13

    knob.Parent = button

    addCorner(knob, 20)

    local knobStroke = addStroke(
        knob,
        COLORS.panel,
        0.45,
        1
    )

    local toggleText = createLabel(
        button,
        text,
        UDim2.new(
            1,
            -38,
            1,
            0
        ),
        UDim2.fromOffset(
            36,
            0
        ),
        10,
        Enum.Font.GothamBold
    )

    toggleText.ZIndex = 13

    toggleText.TextColor3 =
        COLORS.textDim

    local state = initial

    local function render(
        instant
    )

        local info

        if instant then
            info = TweenInfo.new(0)
        else
            info = TWEEN_SMOOTH
        end

        if state then

            tween(
                button,
                info,
                {
                    BackgroundColor3 =
                        COLORS.accent1
                }
            ):Play()

            tween(
                knob,
                info,
                {
                    Position =
                        UDim2.new(
                            1,
                            -28,
                            0,
                            4
                        ),

                    BackgroundColor3 =
                        COLORS.panel
                }
            ):Play()

            toggleText.Text =
                text .. "  ВКЛ"

            toggleText.TextColor3 =
                COLORS.text

        else

            tween(
                button,
                info,
                {
                    BackgroundColor3 =
                        COLORS.trackOff
                }
            ):Play()

            tween(
                knob,
                info,
                {
                    Position =
                        UDim2.fromOffset(
                            4,
                            4
                        ),

                    BackgroundColor3 =
                        COLORS.knobOff
                }
            ):Play()

            toggleText.Text =
                text .. "  ВЫКЛ"

            toggleText.TextColor3 =
                COLORS.textDim

        end
    end

    button.MouseButton1Click:Connect(function()

        state = not state

        render(false)

        callback(state)

    end)

    render(true)

    table.insert(
        controlRefs,
        {
            type = "toggle",
            button = button,
            knob = knob,
            label = toggleText,
            stroke = buttonStroke,
            knobStroke = knobStroke,
            text = text,
            get = function()
                return state
            end,
            render = render
        }
    )

    return button
end

-- =========================================================
-- MAIN
-- =========================================================

local pageMain, mainScroll =
    createPage(1)

local mainGrid =
    Instance.new("UIGridLayout")

mainGrid.CellPadding =
    UDim2.fromOffset(
        8,
        8
    )

mainGrid.CellSize =
    UDim2.new(
        0.5,
        -4,
        0,
        82
    )

mainGrid.SortOrder =
    Enum.SortOrder.LayoutOrder

mainGrid.Parent = mainScroll

-- =========================================================
-- SPEED WALK
-- =========================================================

local cardSpeed =
    makeCard(
        mainScroll,
        82,
        1
    )

makeCardTitle(
    cardSpeed,
    "SPEED WALK"
)

local speedHint =
    createLabel(
        cardSpeed,
        "скорость",
        UDim2.new(
            1,
            -20,
            0,
            13
        ),
        UDim2.fromOffset(
            10,
            29
        ),
        8,
        Enum.Font.Code
    )

speedHint.TextColor3 =
    COLORS.textDim

speedHint.ZIndex = 11

table.insert(
    dimLabels,
    speedHint
)

local speedInput =
    Instance.new("TextBox")

speedInput.Size =
    UDim2.fromOffset(
        62,
        30
    )

speedInput.Position =
    UDim2.fromOffset(
        10,
        47
    )

speedInput.BackgroundColor3 =
    COLORS.panelHi

speedInput.BorderSizePixel = 0

speedInput.Text = "16"

speedInput.TextColor3 =
    COLORS.text

speedInput.TextSize = 11

speedInput.Font =
    Enum.Font.Code

speedInput.ClearTextOnFocus = false

speedInput.TextXAlignment =
    Enum.TextXAlignment.Center

speedInput.ZIndex = 12

speedInput.Parent = cardSpeed

addCorner(
    speedInput,
    9
)

local speedInputStroke =
    addStroke(
        speedInput,
        COLORS.line,
        0.15,
        1
    )

table.insert(
    controlRefs,
    {
        type = "input",
        object = speedInput,
        stroke = speedInputStroke
    }
)

local speedToggle =
    makeToggle(
        cardSpeed,
        "",
        false,
        function(on)

            speedEnabled = on

            local h =
                getHumanoid()

            if h then

                h.WalkSpeed =
                    on
                    and speedValue
                    or 16

            end

        end
    )

speedToggle.Position =
    UDim2.new(
        1,
        -126,
        0,
        47
    )

speedInput.FocusLost:Connect(
    function()

        local number =
            tonumber(
                speedInput.Text
            )

        if number then

            speedValue =
                math.clamp(
                    number,
                    0,
                    500
                )

            speedInput.Text =
                tostring(
                    speedValue
                )

            if speedEnabled then

                local h =
                    getHumanoid()

                if h then
                    h.WalkSpeed =
                        speedValue
                end

            end

        else

            speedInput.Text =
                tostring(
                    speedValue
                )

        end

    end
)

-- =========================================================
-- ANTI FLING
-- =========================================================

local cardAnti =
    makeCard(
        mainScroll,
        82,
        2
    )

makeCardTitle(
    cardAnti,
    "ANTI-FLING"
)

local antiHint =
    createLabel(
        cardAnti,
        "защита персонажа",
        UDim2.new(
            1,
            -20,
            0,
            13
        ),
        UDim2.fromOffset(
            10,
            29
        ),
        8,
        Enum.Font.Code
    )

antiHint.TextColor3 =
    COLORS.textDim

antiHint.ZIndex = 11

table.insert(
    dimLabels,
    antiHint
)

local antiToggle =
    makeToggle(
        cardAnti,
        "",
        false,
        function(on)

            antiFlingEnabled = on

        end
    )

antiToggle.Position =
    UDim2.new(
        1,
        -126,
        0,
        47
    )

-- =========================================================
-- REJOIN
-- =========================================================

local rejoinCard =
    makeCard(
        mainScroll,
        62,
        3
    )

rejoinCard.Size =
    UDim2.new(
        1,
        0,
        0,
        62
    )

makeCardTitle(
    rejoinCard,
    "REJOIN"
)

local rejoinButton =
    Instance.new("TextButton")

rejoinButton.Size =
    UDim2.new(
        1,
        -20,
        0,
        30
    )

rejoinButton.Position =
    UDim2.fromOffset(
        10,
        27
    )

rejoinButton.BackgroundColor3 =
    COLORS.panelHi

rejoinButton.BorderSizePixel = 0

rejoinButton.Text =
    "⟳   REJOIN"

rejoinButton.TextColor3 =
    COLORS.text

rejoinButton.TextSize = 10

rejoinButton.Font =
    Enum.Font.GothamBold

rejoinButton.AutoButtonColor =
    false

rejoinButton.ZIndex = 12

rejoinButton.Parent =
    rejoinCard

addCorner(
    rejoinButton,
    10
)

local rejoinStroke =
    addStroke(
        rejoinButton,
        COLORS.danger,
        0.15,
        1
    )

rejoinButton.MouseButton1Click:Connect(
    function()

        rejoinButton.Text =
            "⟳   ПОДКЛЮЧЕНИЕ..."

        task.spawn(function()

            pcall(function()

                TeleportService:
                    TeleportToPlaceInstance(
                        game.PlaceId,
                        game.JobId,
                        player
                    )

            end)

        end)

    end
)

-- =========================================================
-- STATUS
-- =========================================================

local statusCard =
    makeCard(
        mainScroll,
        58,
        4
    )

makeCardTitle(
    statusCard,
    "STATUS"
)

local statusText =
    createLabel(
        statusCard,
        "контур активен  //  готов к работе",
        UDim2.new(
            1,
            -20,
            0,
            18
        ),
        UDim2.fromOffset(
            10,
            30
        ),
        9,
        Enum.Font.Code
    )

statusText.TextColor3 =
    COLORS.textDim

statusText.ZIndex = 11

table.insert(
    dimLabels,
    statusText
)

-- =========================================================
-- TEST PAGES
-- =========================================================

for i = 2, PAGE_COUNT do

    local page, scroll =
        createPage(i)

    local list =
        Instance.new("UIListLayout")

    list.Padding =
        UDim.new(
            0,
            8
        )

    list.SortOrder =
        Enum.SortOrder.LayoutOrder

    list.Parent = scroll

    local top =
        createLabel(
            scroll,
            string.format(
                "TEST SECTOR %02d",
                i - 1
            ),
            UDim2.new(
                1,
                -6,
                0,
                22
            ),
            UDim2.fromOffset(
                2,
                3
            ),
            12,
            Enum.Font.GothamBold
        )

    top.TextColor3 =
        COLORS.accent1

    top.ZIndex = 10

    top.LayoutOrder = 1

    table.insert(
        accentLabels,
        top
    )

    local description =
        createLabel(
            scroll,
            "оперативный модуль  //  готов к загрузке",
            UDim2.new(
                1,
                -6,
                0,
                18
            ),
            UDim2.fromOffset(
                2,
                0
            ),
            9,
            Enum.Font.Code
        )

    description.TextColor3 =
        COLORS.textDim

    description.ZIndex = 10

    description.LayoutOrder = 2

    table.insert(
        dimLabels,
        description
    )

    -- Больше элементов специально,
    -- чтобы вертикальный скролл реально работал.
    for module = 1, 8 do

        local moduleCard =
            makeCard(
                scroll,
                54,
                module + 2
            )

        moduleCard.Size =
            UDim2.new(
                1,
                -2,
                0,
                54
            )

        local moduleName =
            createLabel(
                moduleCard,
                string.format(
                    "MODULE %02d",
                    module
                ),
                UDim2.fromOffset(
                    86,
                    54
                ),
                UDim2.fromOffset(
                    10,
                    0
                ),
                9,
                Enum.Font.Code
            )

        moduleName.TextColor3 =
            COLORS.text

        moduleName.TextYAlignment =
            Enum.TextYAlignment.Center

        moduleName.ZIndex = 11

        local slash =
            createLabel(
                moduleCard,
                "//",
                UDim2.fromOffset(
                    32,
                    54
                ),
                UDim2.fromOffset(
                    91,
                    0
                ),
                9,
                Enum.Font.Code
            )

        slash.TextColor3 =
            COLORS.textDim

        slash.TextYAlignment =
            Enum.TextYAlignment.Center

        slash.ZIndex = 11

        local waiting =
            createLabel(
                moduleCard,
                "waiting",
                UDim2.new(
                    1,
                    -140,
                    0,
                    54
                ),
                UDim2.fromOffset(
                    128,
                    0
                ),
                9,
                Enum.Font.Code
            )

        waiting.TextColor3 =
            COLORS.textDim

        waiting.TextYAlignment =
            Enum.TextYAlignment.Center

        waiting.ZIndex = 11

        table.insert(
            dimLabels,
            slash
        )

        table.insert(
            dimLabels,
            waiting
        )

    end

end

-- =========================================================
-- TAB VISUALS
-- =========================================================

local function updateTabVisuals()

    for i, button in pairs(tabButtons) do

        local active =
            i == currentPage

        tween(
            button,
            TWEEN_FAST,
            {
                BackgroundColor3 =
                    active
                    and COLORS.accent1
                    or COLORS.panel,

                TextColor3 =
                    active
                    and Color3.fromRGB(
                        255,
                        255,
                        255
                    )
                    or COLORS.textDim
            }
        ):Play()

    end

end

-- =========================================================
-- CENTER TAB
-- =========================================================

local function centerTab(order)

    local button =
        tabButtons[order]

    if not button then
        return
    end

    task.defer(function()

        local maxX =
            math.max(
                0,
                tabBar.AbsoluteCanvasSize.X
                    - tabBar.AbsoluteSize.X
            )

        local target =
            button.AbsolutePosition.X
            - tabBar.AbsolutePosition.X
            - (
                tabBar.AbsoluteSize.X
                - button.AbsoluteSize.X
            ) / 2

        target =
            math.clamp(
                target,
                0,
                maxX
            )

        tween(
            tabBar,
            TWEEN_MED,
            {
                CanvasPosition =
                    Vector2.new(
                        target,
                        0
                    )
            }
        ):Play()

    end)

end

-- =========================================================
-- SET PAGE
-- =========================================================

local function setPage(
    order,
    direction
)

    if order < 1
        or order > PAGE_COUNT
        or order == currentPage
        or switching
    then
        return
    end

    direction =
        direction
        or (
            order > currentPage
            and 1
            or -1
        )

    switching = true

    local oldPage =
        pages[currentPage]

    local newPage =
        pages[order]

    local newScroll =
        scrolls[order]

    -- ВАЖНО:
    -- currentPage обновляется сразу.
    -- Это убирает старый баг с Test 15 -> Main.
    currentPage = order

    updateTabVisuals()

    centerTab(order)

    -- При переходе на новую вкладку
    -- она всегда начинается сверху.
    if newScroll then

        newScroll.CanvasPosition =
            Vector2.new(
                0,
                0
            )

    end

    newPage.Position =
        UDim2.new(
            0,
            30 * direction,
            0,
            0
        )

    newPage.Visible = true

    newPage.GroupTransparency = 1

    tween(
        oldPage,
        TWEEN_MED,
        {
            Position =
                UDim2.new(
                    0,
                    -30 * direction,
                    0,
                    0
                ),

            GroupTransparency = 1
        }
    ):Play()

    tween(
        newPage,
        TWEEN_MED,
        {
            Position =
                UDim2.new(
                    0,
                    0,
                    0,
                    0
                ),

            GroupTransparency = 0
        }
    ):Play()

    task.delay(
        0.30,
        function()

            if oldPage then

                oldPage.Visible = false

                oldPage.Position =
                    UDim2.new(
                        0,
                        0,
                        0,
                        0
                    )

            end

            switching = false

        end
    )

end

local function nextPage()

    setPage(
        currentPage % PAGE_COUNT + 1,
        1
    )

end

local function previousPage()

    setPage(
        (currentPage - 2)
            % PAGE_COUNT + 1,
        -1
    )

end

-- =========================================================
-- TAB BUTTONS
-- =========================================================

for i = 1, PAGE_COUNT do

    local button =
        Instance.new("TextButton")

    button.Name =
        "TabBtn" .. i

    button.Size =
        UDim2.fromOffset(
            82,
            36
        )

    button.BackgroundColor3 =
        i == 1
        and COLORS.accent1
        or COLORS.panel

    button.BorderSizePixel = 0

    button.Text =
        i == 1
        and "Main"
        or (
            "Test "
            .. string.format(
                "%02d",
                i - 1
            )
        )

    button.TextColor3 =
        i == 1
        and Color3.fromRGB(
            255,
            255,
            255
        )
        or COLORS.textDim

    button.TextSize = 9

    button.Font =
        Enum.Font.GothamBold

    button.LayoutOrder = i

    button.AutoButtonColor = false

    button.ZIndex = 9

    button.Parent = tabBar

    addCorner(
        button,
        11
    )

    addStroke(
        button,
        COLORS.line,
        0.5,
        1
    )

    tabButtons[i] =
        button

    button.MouseButton1Click:Connect(
        function()

            if i ~= currentPage then

                setPage(
                    i,
                    i > currentPage
                    and 1
                    or -1
                )

            end

        end
    )

end

-- =========================================================
-- SETTINGS PANEL
-- =========================================================

local settingsPanel =
    Instance.new("CanvasGroup")

settingsPanel.Name =
    "SettingsPanel"

settingsPanel.Size =
    UDim2.new(
        1,
        -28,
        1,
        -142
    )

settingsPanel.Position =
    UDim2.fromOffset(
        14,
        136
    )

settingsPanel.BackgroundColor3 =
    COLORS.panel

settingsPanel.BorderSizePixel = 0

settingsPanel.GroupTransparency = 1

settingsPanel.Visible = false

settingsPanel.ZIndex = 30

settingsPanel.Parent = window

addCorner(
    settingsPanel,
    17
)

local settingsPanelStroke =
    addStroke(
        settingsPanel,
        COLORS.line,
        0.10,
        1
    )

local settingsTitle =
    createLabel(
        settingsPanel,
        "SETTINGS",
        UDim2.new(
            1,
            -70,
            0,
            24
        ),
        UDim2.fromOffset(
            16,
            16
        ),
        14,
        Enum.Font.GothamBold
    )

settingsTitle.ZIndex = 32

local settingsSub =
    createLabel(
        settingsPanel,
        "оформление и поведение интерфейса",
        UDim2.new(
            1,
            -30,
            0,
            18
        ),
        UDim2.fromOffset(
            16,
            41
        ),
        8,
        Enum.Font.Code
    )

settingsSub.TextColor3 =
    COLORS.textDim

settingsSub.ZIndex = 32

local settingsLine =
    Instance.new("Frame")

settingsLine.Size =
    UDim2.new(
        1,
        -28,
        0,
        1
    )

settingsLine.Position =
    UDim2.fromOffset(
        14,
        68
    )

settingsLine.BackgroundColor3 =
    COLORS.line

settingsLine.BorderSizePixel = 0

settingsLine.ZIndex = 32

settingsLine.Parent =
    settingsPanel

-- =========================================================
-- THEME CARD
-- =========================================================

local themeCard =
    Instance.new("Frame")

themeCard.Size =
    UDim2.new(
        1,
        -28,
        0,
        78
    )

themeCard.Position =
    UDim2.fromOffset(
        14,
        82
    )

themeCard.BackgroundColor3 =
    COLORS.panelHi

themeCard.BorderSizePixel = 0

themeCard.ZIndex = 31

themeCard.Parent =
    settingsPanel

addCorner(
    themeCard,
    13
)

local themeCardStroke =
    addStroke(
        themeCard,
        COLORS.line,
        0.20,
        1
    )

local themeLabel =
    createLabel(
        themeCard,
        "THEME",
        UDim2.new(
            1,
            -150,
            0,
            18
        ),
        UDim2.fromOffset(
            12,
            10
        ),
        10,
        Enum.Font.GothamBold
    )

themeLabel.ZIndex = 33

local themeHint =
    createLabel(
        themeCard,
        "светлая тема включена по умолчанию",
        UDim2.new(
            1,
            -150,
            0,
            16
        ),
        UDim2.fromOffset(
            12,
            33
        ),
        8,
        Enum.Font.Code
    )

themeHint.TextColor3 =
    COLORS.textDim

themeHint.ZIndex = 33

local themeButton =
    Instance.new("TextButton")

themeButton.Size =
    UDim2.fromOffset(
        110,
        38
    )

themeButton.Position =
    UDim2.new(
        1,
        -122,
        0,
        20
    )

themeButton.BackgroundColor3 =
    COLORS.accent1

themeButton.BorderSizePixel = 0

themeButton.Text =
    "LIGHT"

themeButton.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

themeButton.TextSize = 10

themeButton.Font =
    Enum.Font.GothamBold

themeButton.AutoButtonColor = false

themeButton.ZIndex = 33

themeButton.Parent =
    themeCard

addCorner(
    themeButton,
    12
)

local themeButtonStroke =
    addStroke(
        themeButton,
        COLORS.accent1,
        0.15,
        1
    )

-- =========================================================
-- SETTINGS CLOSE
-- =========================================================

local settingsClose =
    Instance.new("TextButton")

settingsClose.Size =
    UDim2.fromOffset(
        34,
        34
    )

settingsClose.Position =
    UDim2.new(
        1,
        -48,
        0,
        13
    )

settingsClose.BackgroundColor3 =
    COLORS.panelHi

settingsClose.BorderSizePixel = 0

settingsClose.Text = "×"

settingsClose.TextColor3 =
    COLORS.textDim

settingsClose.TextSize = 19

settingsClose.Font =
    Enum.Font.GothamBold

settingsClose.AutoButtonColor =
    false

settingsClose.ZIndex = 35

settingsClose.Parent =
    settingsPanel

addCorner(
    settingsClose,
    11
)

local settingsCloseStroke =
    addStroke(
        settingsClose,
        COLORS.line,
        0.20,
        1
    )

-- =========================================================
-- APPLY THEME
-- =========================================================

local function applyTheme()

    COLORS =
        THEMES[currentTheme]

    -- WINDOW

    window.BackgroundColor3 =
        COLORS.bg

    winStroke.Color =
        COLORS.accent1

    winGradient.Color =
        ColorSequence.new({

            ColorSequenceKeypoint.new(
                0,
                COLORS.panel
            ),

            ColorSequenceKeypoint.new(
                0.55,
                COLORS.bg
            ),

            ColorSequenceKeypoint.new(
                1,
                COLORS.panelHi
            )
        })

    shadow.ImageColor3 =
        COLORS.shadow

    -- HEADER

    header.BackgroundColor3 =
        COLORS.panel

    headerFix.BackgroundColor3 =
        COLORS.panel

    headerGradient.Color =
        ColorSequence.new({

            ColorSequenceKeypoint.new(
                0,
                COLORS.accent1
            ),

            ColorSequenceKeypoint.new(
                0.5,
                COLORS.accent2
            ),

            ColorSequenceKeypoint.new(
                1,
                COLORS.accent3
            )
        })

    statusDot.BackgroundColor3 =
        COLORS.accent1

    dotGlow.Color =
        COLORS.accent2

    title.TextColor3 =
        COLORS.text

    subtitle.TextColor3 =
        COLORS.textDim

    -- CLOSE

    closeBtn.BackgroundColor3 =
        COLORS.panelHi

    closeBtn.TextColor3 =
        COLORS.text

    closeStroke.Color =
        COLORS.line

    -- SETTINGS

    settingsBtn.BackgroundColor3 =
        COLORS.panelHi

    settingsBtn.TextColor3 =
        COLORS.textDim

    settingsStroke.Color =
        COLORS.line

    -- TABS

    tabBar.BackgroundColor3 =
        COLORS.panelHi

    tabBarStroke.Color =
        COLORS.line

    updateTabVisuals()

    -- CARDS

    for _, data in ipairs(cards) do

        data.object.BackgroundColor3 =
            COLORS.panel

        data.stroke.Color =
            COLORS.line

        data.gradient.Color =
            ColorSequence.new({

                ColorSequenceKeypoint.new(
                    0,
                    COLORS.panelHi
                ),

                ColorSequenceKeypoint.new(
                    1,
                    COLORS.panel
                )
            })

    end

    for _, l in ipairs(cardTitles) do
        l.TextColor3 =
            COLORS.text
    end

    for _, l in ipairs(accentLabels) do
        l.TextColor3 =
            COLORS.accent1
    end

    for _, l in ipairs(dimLabels) do
        l.TextColor3 =
            COLORS.textDim
    end

    -- INPUT

    speedInput.BackgroundColor3 =
        COLORS.panelHi

    speedInput.TextColor3 =
        COLORS.text

    speedInputStroke.Color =
        COLORS.line

    -- REJOIN

    rejoinButton.BackgroundColor3 =
        COLORS.panelHi

    rejoinButton.TextColor3 =
        COLORS.text

    rejoinStroke.Color =
        COLORS.danger

    -- SETTINGS PANEL

    settingsPanel.BackgroundColor3 =
        COLORS.panel

    settingsPanelStroke.Color =
        COLORS.line

    settingsTitle.TextColor3 =
        COLORS.text

    settingsSub.TextColor3 =
        COLORS.textDim

    settingsLine.BackgroundColor3 =
        COLORS.line

    themeCard.BackgroundColor3 =
        COLORS.panelHi

    themeCardStroke.Color =
        COLORS.line

    themeLabel.TextColor3 =
        COLORS.text

    themeHint.TextColor3 =
        COLORS.textDim

    themeButton.BackgroundColor3 =
        COLORS.accent1

    themeButtonStroke.Color =
        COLORS.accent1

    themeButton.Text =
        currentTheme == "Light"
        and "LIGHT"
        or "DARK"

    settingsClose.BackgroundColor3 =
        COLORS.panelHi

    settingsClose.TextColor3 =
        COLORS.textDim

    settingsCloseStroke.Color =
        COLORS.line

    -- M

    mButton.BackgroundColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    mButton.TextColor3 =
        COLORS.accent1

    mStroke.Color =
        COLORS.accent1

    mButton.TextStrokeColor3 =
        COLORS.accent2

    -- CONTROLS

    for _, ref in ipairs(controlRefs) do

        if ref.type == "toggle" then

            ref.stroke.Color =
                COLORS.line

            ref.knobStroke.Color =
                COLORS.panel

            ref.render(true)

        elseif ref.type == "input" then

            ref.object.BackgroundColor3 =
                COLORS.panelHi

            ref.object.TextColor3 =
                COLORS.text

            ref.stroke.Color =
                COLORS.line

        end

    end

    -- Scrollbars

    for _, scroll in pairs(scrolls) do

        scroll.ScrollBarImageColor3 =
            COLORS.accent1

    end

end

-- =========================================================
-- THEME SWITCH
-- =========================================================

themeButton.MouseButton1Click:Connect(
    function()

        currentTheme =
            currentTheme == "Light"
            and "Dark"
            or "Light"

        applyTheme()

    end
)

-- =========================================================
-- SETTINGS OPEN/CLOSE
-- =========================================================

local function closeSettings()

    if not settingsOpen then
        return
    end

    settingsOpen = false

    tween(
        settingsPanel,
        TWEEN_MED,
        {
            GroupTransparency = 1
        }
    ):Play()

    task.delay(
        0.30,
        function()

            if not settingsOpen then

                settingsPanel.Visible =
                    false

            end

        end
    )

end

local function openSettings()

    if settingsOpen then

        closeSettings()

        return

    end

    settingsOpen = true

    settingsPanel.Visible = true

    settingsPanel.GroupTransparency =
        1

    tween(
        settingsPanel,
        TWEEN_MED,
        {
            GroupTransparency = 0
        }
    ):Play()

end

settingsBtn.MouseButton1Click:Connect(
    openSettings
)

settingsClose.MouseButton1Click:Connect(
    closeSettings
)

-- =========================================================
-- POINT INSIDE
-- =========================================================

local function pointInside(
    object,
    point
)

    local p =
        object.AbsolutePosition

    local s =
        object.AbsoluteSize

    return (
        point.X >= p.X
        and point.X <= p.X + s.X
        and point.Y >= p.Y
        and point.Y <= p.Y + s.Y
    )

end

-- =========================================================
-- WINDOW DRAG
-- =========================================================

window.InputBegan:Connect(
    function(input)

        if input.UserInputType
            ~= Enum.UserInputType.MouseButton1
            and input.UserInputType
            ~= Enum.UserInputType.Touch
        then
            return
        end

        -- Не начинаем drag через кнопки.
        if pointInside(
            closeBtn,
            input.Position
        )
        then
            return
        end

        if pointInside(
            settingsBtn,
            input.Position
        )
        then
            return
        end

        if settingsOpen then
            return
        end

        if pointInside(
            header,
            input.Position
        )
        then

            dragStart =
                input.Position

            dragOffset =
                window.Position

            dragging = true

        end

    end
)

window.InputEnded:Connect(
    function(input)

        if input.UserInputType
            == Enum.UserInputType.MouseButton1
            or input.UserInputType
            == Enum.UserInputType.Touch
        then

            dragging = false

            dragStart = nil
            dragOffset = nil

        end

    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not dragging then
            return
        end

        if input.UserInputType
            ~= Enum.UserInputType.MouseMovement
            and input.UserInputType
            ~= Enum.UserInputType.Touch
        then
            return
        end

        if not dragStart
            or not dragOffset
        then
            return
        end

        local delta =
            input.Position
            - dragStart

        window.Position =
            UDim2.new(
                dragOffset.X.Scale,
                dragOffset.X.Offset
                    + delta.X,

                dragOffset.Y.Scale,
                dragOffset.Y.Offset
                    + delta.Y
            )

        shadow.Position =
            UDim2.new(
                window.Position.X.Scale,
                window.Position.X.Offset
                    - 20,

                window.Position.Y.Scale,
                window.Position.Y.Offset
                    - 10
            )

    end
)

-- =========================================================
-- HORIZONTAL SWIPE
-- =========================================================

window.InputBegan:Connect(
    function(input)

        if settingsOpen
            or dragging
        then
            return
        end

        if input.UserInputType
            == Enum.UserInputType.Touch
            or input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            swipeStart =
                input.Position

        end

    end
)

window.InputEnded:Connect(
    function(input)

        if settingsOpen
            or not swipeStart
        then
            return
        end

        if input.UserInputType
            ~= Enum.UserInputType.Touch
            and input.UserInputType
            ~= Enum.UserInputType.MouseButton1
        then
            return
        end

        local delta =
            input.Position
            - swipeStart

        swipeStart = nil

        local ax =
            math.abs(delta.X)

        local ay =
            math.abs(delta.Y)

        if math.max(
            ax,
            ay
        ) < SWIPE_THRESHOLD
        then
            return
        end

        -- Вертикальный свайп теперь отдан ScrollingFrame.
        if ay > ax * 1.45 then
            return
        end

        if ax > ay * 1.45 then

            if delta.X < 0 then

                nextPage()

            else

                previousPage()

            end

        end

    end
)

-- =========================================================
-- MAIN OPEN
-- =========================================================

local function openMain()

    if mainVisible then
        return
    end

    mainVisible = true

    mButton.Visible = false

    window.Visible = true
    shadow.Visible = true

    window.GroupTransparency = 1
    shadow.ImageTransparency = 1

    winStroke.Transparency = 0.20

    window.Position =
        UDim2.new(
            0.5,
            -170,
            0.5,
            -159
        )

    shadow.Position =
        UDim2.new(
            0.5,
            -190,
            0.5,
            -169
        )

    pages[currentPage].Visible =
        true

    pages[currentPage].GroupTransparency =
        0

    tween(
        window,
        TWEEN_SLOW,
        {
            GroupTransparency = 0
        }
    ):Play()

    tween(
        shadow,
        TWEEN_SLOW,
        {
            ImageTransparency = 0.72
        }
    ):Play()

end

-- =========================================================
-- MAIN CLOSE
-- =========================================================

local function closeMain()

    if not mainVisible then
        return
    end

    mainVisible = false

    settingsOpen = false

    if settingsPanel.Visible then
        settingsPanel.Visible = false
    end

    -- Контент уходит первым.
    tween(
        window,
        TWEEN_SLOW,
        {
            GroupTransparency = 1
        }
    ):Play()

    tween(
        shadow,
        TWEEN_SLOW,
        {
            ImageTransparency = 1
        }
    ):Play()

    -- Обводка исчезает позже.
    tween(
        winStroke,
        TWEEN_MED,
        {
            Transparency = 0.82
        }
    ):Play()

    task.delay(
        0.32,
        function()

            if not mainVisible then

                window.Visible = false

                shadow.Visible = false

                -- Возвращаем нормальную обводку
                -- перед следующим открытием.
                winStroke.Transparency =
                    0.20

                -- Появляется M.
                mButton.Visible = true

                mButton.BackgroundTransparency =
                    0

                mButton.TextTransparency =
                    1

                tween(
                    mButton,
                    TWEEN_MED,
                    {
                        TextTransparency = 0
                    }
                ):Play()

            end

        end
    )

end

closeBtn.MouseButton1Click:Connect(
    closeMain
)

-- =========================================================
-- M DRAG
-- =========================================================

mButton.InputBegan:Connect(
    function(input)

        if input.UserInputType
            ~= Enum.UserInputType.MouseButton1
            and input.UserInputType
            ~= Enum.UserInputType.Touch
        then
            return
        end

        mDragging = true

        mDragStart =
            input.Position

        mDragOffset =
            mButton.Position

    end
)

mButton.InputEnded:Connect(
    function(input)

        if input.UserInputType
            ~= Enum.UserInputType.MouseButton1
            and input.UserInputType
            ~= Enum.UserInputType.Touch
        then
            return
        end

        local movement = 0

        if mDragStart then

            movement =
                (
                    input.Position
                    - mDragStart
                ).Magnitude

        end

        mDragging = false

        mDragStart = nil
        mDragOffset = nil

        -- Маленькое движение = клик.
        if movement < 12 then

            -- M превращается в MEREDIOS.
            tween(
                mButton,
                TWEEN_MED,
                {
                    Size =
                        UDim2.fromOffset(
                            112,
                            42
                        )
                }
            ):Play()

            mButton.Text =
                "MEREDIOS"

            task.delay(
                0.20,
                function()

                    if not mButton.Visible
                        or mDragging
                    then
                        return
                    end

                    tween(
                        mButton,
                        TWEEN_MED,
                        {
                            BackgroundTransparency = 1,
                            TextTransparency = 1
                        }
                    ):Play()

                    task.delay(
                        0.25,
                        function()

                            if not mButton.Visible then
                                return
                            end

                            mButton.Visible =
                                false

                            mButton.BackgroundTransparency =
                                0

                            mButton.TextTransparency =
                                0

                            mButton.Size =
                                UDim2.fromOffset(
                                    58,
                                    58
                                )

                            openMain()

                        end
                    )

                end
            )

        end

    end
)

UserInputService.InputChanged:Connect(
    function(input)

        if not mDragging
            or not mDragStart
            or not mDragOffset
        then
            return
        end

        if input.UserInputType
            ~= Enum.UserInputType.MouseMovement
            and input.UserInputType
            ~= Enum.UserInputType.Touch
        then
            return
        end

        local delta =
            input.Position
            - mDragStart

        mButton.Position =
            UDim2.new(
                mDragOffset.X.Scale,
                mDragOffset.X.Offset
                    + delta.X,

                mDragOffset.Y.Scale,
                mDragOffset.Y.Offset
                    + delta.Y
            )

    end
)

-- =========================================================
-- CHARACTER
-- =========================================================

player.CharacterAdded:Connect(
    function(character)

        humanoid =
            character:WaitForChild(
                "Humanoid"
            )

        rootPart =
            character:WaitForChild(
                "HumanoidRootPart",
                5
            )

        if speedEnabled
            and humanoid
        then

            humanoid.WalkSpeed =
                speedValue

        end

    end
)

-- =========================================================
-- ANTI-FLING DETECTION
-- =========================================================

local playerNearSince = 0

local function getNearestPlayerRoot(
    maxDistance
)

    local myRoot =
        getRootPart()

    if not myRoot then
        return nil, math.huge
    end

    local nearest = nil
    local nearestDistance =
        maxDistance

    for _, otherPlayer in ipairs(
        Players:GetPlayers()
    ) do

        if otherPlayer ~= player then

            local character =
                otherPlayer.Character

            local otherRoot =
                character
                and character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if otherRoot then

                local distance =
                    (
                        otherRoot.Position
                        - myRoot.Position
                    ).Magnitude

                if distance <
                    nearestDistance
                then

                    nearest =
                        otherRoot

                    nearestDistance =
                        distance

                end

            end

        end

    end

    return nearest, nearestDistance

end

-- =========================================================
-- HEARTBEAT
-- =========================================================

RunService.Heartbeat:Connect(
    function()

        -- SPEED WALK

        if speedEnabled then

            local h =
                getHumanoid()

            if h
                and h.WalkSpeed
                    ~= speedValue
            then

                h.WalkSpeed =
                    speedValue

            end

        end

        -- ANTI FLING

        if not antiFlingEnabled then
            return
        end

        local root =
            getRootPart()

        if not root then
            return
        end

        local velocity =
            root.AssemblyLinearVelocity

        local angularVelocity =
            root.AssemblyAngularVelocity

        local nearbyRoot =
            getNearestPlayerRoot(10)

        if nearbyRoot then

            playerNearSince =
                os.clock()

        end

        local horizontalVelocity =
            Vector3.new(
                velocity.X,
                0,
                velocity.Z
            ).Magnitude

        local verticalVelocity =
            math.abs(
                velocity.Y
            )

        local extremeVelocity =
            horizontalVelocity > 85
            or verticalVelocity > 105
            or angularVelocity.Magnitude > 65

        local playerContactWindow =
            nearbyRoot ~= nil
            or (
                os.clock()
                - playerNearSince
            ) < 0.18

        if extremeVelocity
            and playerContactWindow
        then

            -- Не обнуляем всё движение.
            -- Ограничиваем только экстремальный импульс.

            local safeX =
                math.clamp(
                    velocity.X,
                    -45,
                    45
                )

            local safeY =
                math.clamp(
                    velocity.Y,
                    -45,
                    55
                )

            local safeZ =
                math.clamp(
                    velocity.Z,
                    -45,
                    45
                )

            root.AssemblyLinearVelocity =
                Vector3.new(
                    safeX,
                    safeY,
                    safeZ
                )

            if angularVelocity.Magnitude
                > 65
            then

                root.AssemblyAngularVelocity =
                    Vector3.zero

            end

        end

    end
)

-- =========================================================
-- BOOT / ACTIVATION SCREEN
-- =========================================================

local boot =
    Instance.new("ScreenGui")

boot.Name =
    "MerediosBoot"

boot.ResetOnSpawn = false

boot.IgnoreGuiInset = true

boot.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

boot.DisplayOrder = 1000

boot.Parent = playerGui

-- =========================================================
-- BOOT PANEL
-- =========================================================

local bootPanel =
    Instance.new("CanvasGroup")

bootPanel.Size =
    UDim2.fromOffset(
        330,
        250
    )

bootPanel.Position =
    UDim2.new(
        0.5,
        -165,
        0.5,
        -125
    )

bootPanel.BackgroundColor3 =
    THEMES.Light.panel

bootPanel.BorderSizePixel = 0

bootPanel.GroupTransparency = 1

bootPanel.Parent = boot

addCorner(
    bootPanel,
    22
)

local bootStroke =
    addStroke(
        bootPanel,
        THEMES.Light.accent1,
        0.10,
        1.5
    )

-- =========================================================
-- FOUR COLOR CORNERS
-- =========================================================

local cornerLights = {}

local cornerPositions = {

    UDim2.fromOffset(
        10,
        10
    ),

    UDim2.new(
        1,
        -20,
        0,
        10
    ),

    UDim2.new(
        0,
        10,
        1,
        -20
    ),

    UDim2.new(
        1,
        -20,
        1,
        -20
    )
}

for i, position in ipairs(
    cornerPositions
) do

    local dot =
        Instance.new("Frame")

    dot.Size =
        UDim2.fromOffset(
            10,
            10
        )

    dot.Position =
        position

    dot.BackgroundColor3 =
        THEMES.Light.accent1

    dot.BorderSizePixel = 0

    dot.Parent =
        bootPanel

    addCorner(
        dot,
        10
    )

    local dotStroke =
        addStroke(
            dot,
            THEMES.Light.accent2,
            0.20,
            1
        )

    cornerLights[i] = {
        dot = dot,
        stroke = dotStroke
    }

end

-- =========================================================
-- BOOT TITLE
-- =========================================================

local bootTitle =
    createLabel(
        bootPanel,
        "Meredios",
        UDim2.new(
            1,
            -44,
            0,
            48
        ),
        UDim2.fromOffset(
            22,
            67
        ),
        29,
        Enum.Font.GothamBold
    )

bootTitle.TextColor3 =
    THEMES.Light.text

bootTitle.TextTransparency = 1

-- Меньше обводка
bootTitle.TextStrokeTransparency =
    0.88

-- =========================================================
-- BOOT LINE
-- =========================================================

local bootLine =
    Instance.new("Frame")

bootLine.Size =
    UDim2.new(
        0,
        0,
        0,
        2
    )

bootLine.Position =
    UDim2.fromOffset(
        22,
        120
    )

bootLine.BackgroundColor3 =
    THEMES.Light.accent1

bootLine.BorderSizePixel = 0

bootLine.Parent =
    bootPanel

addCorner(
    bootLine,
    2
)

-- =========================================================
-- BOOT SUBTITLE
-- =========================================================

local bootSubtitle =
    createLabel(
        bootPanel,
        "оперативный контур  //  v4.0",
        UDim2.new(
            1,
            -44,
            0,
            20
        ),
        UDim2.fromOffset(
            22,
            133
        ),
        9,
        Enum.Font.Code
    )

bootSubtitle.TextColor3 =
    THEMES.Light.textDim

bootSubtitle.TextTransparency = 1

-- =========================================================
-- START
-- =========================================================

local startButton =
    Instance.new("TextButton")

startButton.Size =
    UDim2.fromOffset(
        220,
        44
    )

startButton.Position =
    UDim2.fromOffset(
        22,
        174
    )

startButton.BackgroundColor3 =
    THEMES.Light.accent1

startButton.BorderSizePixel = 0

startButton.Text =
    "НАЧАТЬ"

startButton.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

startButton.TextSize = 11

startButton.Font =
    Enum.Font.GothamBold

startButton.AutoButtonColor =
    false

startButton.BackgroundTransparency =
    1

startButton.TextTransparency =
    1

startButton.Parent =
    bootPanel

addCorner(
    startButton,
    13
)

local startStroke =
    addStroke(
        startButton,
        THEMES.Light.accent1,
        0.20,
        1
    )

-- =========================================================
-- BOOT CLOSE
-- =========================================================

local bootClose =
    Instance.new("TextButton")

bootClose.Size =
    UDim2.fromOffset(
        34,
        34
    )

bootClose.Position =
    UDim2.new(
        1,
        -48,
        0,
        13
    )

bootClose.BackgroundColor3 =
    THEMES.Light.panelHi

bootClose.BorderSizePixel = 0

bootClose.Text =
    "CLOSE"

bootClose.TextColor3 =
    THEMES.Light.textDim

bootClose.TextSize = 7

bootClose.Font =
    Enum.Font.GothamBold

bootClose.AutoButtonColor =
    false

bootClose.BackgroundTransparency =
    1

bootClose.TextTransparency =
    1

bootClose.Parent =
    bootPanel

addCorner(
    bootClose,
    11
)

local bootCloseStroke =
    addStroke(
        bootClose,
        THEMES.Light.line,
        0.25,
        1
    )

-- =========================================================
-- BOOT CORNER COLOR ANIMATION
-- =========================================================

task.spawn(function()

    local step = 0

    while boot.Parent do

        step += 1

        for i, data in ipairs(
            cornerLights
        ) do

            local phase =
                (
                    step * 0.10
                    + i * 0.23
                ) % 3

            local color

            if phase < 1 then

                color =
                    THEMES.Light.accent1

            elseif phase < 2 then

                color =
                    THEMES.Light.accent2

            else

                color =
                    THEMES.Light.accent3

            end

            tween(
                data.dot,
                TweenInfo.new(
                    0.65,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    BackgroundColor3 =
                        color
                }
            ):Play()

            tween(
                data.stroke,
                TweenInfo.new(
                    0.65,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    Color = color
                }
            ):Play()

        end

        task.wait(0.65)

    end

end)

-- =========================================================
-- BOOT SEQUENCE
-- =========================================================

-- Сначала появляется само меню.
tween(
    bootPanel,
    TWEEN_SLOW,
    {
        GroupTransparency = 0
    }
):Play()

-- Надпись только через 0.7 секунды.
task.delay(
    0.7,
    function()

        if not boot.Parent then
            return
        end

        tween(
            bootTitle,
            TWEEN_SMOOTH,
            {
                TextTransparency = 0,
                Position =
                    UDim2.fromOffset(
                        34,
                        67
                    )
            }
        ):Play()

        tween(
            bootLine,
            TWEEN_SMOOTH,
            {
                Size =
                    UDim2.new(
                        1,
                        -44,
                        0,
                        2
                    )
            }
        ):Play()

        tween(
            bootSubtitle,
            TWEEN_SMOOTH,
            {
                TextTransparency = 0
            }
        ):Play()

    end
)

-- Начать появляется плавно.
task.delay(
    1.25,
    function()

        if not boot.Parent then
            return
        end

        tween(
            startButton,
            TWEEN_SMOOTH,
            {
                BackgroundTransparency = 0,
                TextTransparency = 0
            }
        ):Play()

    end
)

-- CLOSE только через 4 секунды.
task.delay(
    4,
    function()

        if not boot.Parent then
            return
        end

        tween(
            bootClose,
            TWEEN_MED,
            {
                BackgroundTransparency = 0,
                TextTransparency = 0
            }
        ):Play()

    end
)

-- =========================================================
-- CLOSE BOOT
-- =========================================================

local function closeBoot()

    tween(
        bootPanel,
        TWEEN_MED,
        {
            GroupTransparency = 1
        }
    ):Play()

    task.delay(
        0.30,
        function()

            if boot then
                boot:Destroy()
            end

        end
    )

end

bootClose.MouseButton1Click:Connect(
    closeBoot
)

-- =========================================================
-- START BUTTON
-- =========================================================

startButton.MouseButton1Click:Connect(
    function()

        closeBoot()

        task.delay(
            0.30,
            function()
                openMain()
            end
        )

    end
)

-- =========================================================
-- INITIAL THEME
-- =========================================================

applyTheme()

-- =========================================================
-- INITIAL STATE
-- =========================================================

window.Visible = false
shadow.Visible = false
mButton.Visible = false

pages[1].Visible = false
