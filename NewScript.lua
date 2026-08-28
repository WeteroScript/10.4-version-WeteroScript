local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = Workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════
--  КОНФИГ
-- ══════════════════════════════════════════════════════════════
local CFG = {
    AccentColor    = Color3.fromRGB(108, 99, 255),
    AccentColorON  = Color3.fromRGB(80, 255, 160),
    BgColor        = Color3.fromRGB(10, 10, 20),
    CardBg         = Color3.fromRGB(18, 18, 35),
    CardBgHover    = Color3.fromRGB(28, 28, 50),
    TextPrimary    = Color3.fromRGB(230, 230, 255),
    TextSecondary  = Color3.fromRGB(140, 140, 180),
    DangerColor    = Color3.fromRGB(255, 70, 90),
    WalkFlingPower = 80,
    TouchFlingPower= 100,
    ESPColor       = Color3.fromRGB(80, 255, 160),
    AimbotFOV      = 120,
    HitChance      = 85,
    FlySpeed       = 50,
    SpeedMultiplier= 2,
    JumpPower      = 50,
    Gravity        = 196.2,
    CharScale      = 1,
}

-- ══════════════════════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════════════════════
local STATE = {
    -- COMBAT
    ESPBox         = false,
    ESPName        = false,
    ESPDist        = false,
    ESPHealth      = false,
    ESPTracers     = false,
    SilentAim      = false,
    Aimbot         = false,
    AutoParry      = false,
    NoclipPlayers  = false,
    -- MOVEMENT
    WalkFling      = false,
    TouchFling     = false,
    SpeedHack      = false,
    Fly            = false,
    Noclip         = false,
    InfJump        = false,
    AntiAFK        = false,
    -- VISUAL
    Fullbright     = false,
    NoFog          = false,
    FOVChanged     = false,
    Crosshair      = false,
    FPSCounter     = false,
    PingCounter    = false,
    ClockWidget    = false,
    Chams          = false,
    RainbowESP     = false,
    Wireframe      = false,
    -- WORLD
    NoDeathBarrier = false,
    RemoveParts    = false,
    HighlightAll   = false,
    AntiRagdoll    = false,
    FakeLag        = false,
    -- PLAYER
    GodMode        = false,
    InfStamina     = false,
    AutoRespawn    = false,
    -- MISC
    DarkTheme      = true,
}

-- ══════════════════════════════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════════════════════════════
local function GetChar()
    return LocalPlayer.Character
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t or 0.2, style, dir), props):Play()
end

local function RainbowColor(offset)
    offset = offset or 0
    local t = tick() * 0.5 + offset
    return Color3.fromHSV(t % 1, 1, 1)
end

-- ══════════════════════════════════════════════════════════════
--  ESP STORAGE
-- ══════════════════════════════════════════════════════════════
local ESPObjects   = {}
local ESPTracerObjs= {}

local function ClearESP(player)
    if ESPObjects[player] then
        for _, v in pairs(ESPObjects[player]) do
            if v and v.Parent then v:Destroy() end
        end
        ESPObjects[player] = nil
    end
end

local function BuildESP(player)
    if player == LocalPlayer then return end
    ClearESP(player)

    local function waitChar()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local hum  = char:WaitForChild("Humanoid", 5)
        if not root or not hum then return end

        local objs = {}

        -- Billboard
        local bb = Instance.new("BillboardGui")
        bb.Size           = UDim2.new(0, 220, 0, 80)
        bb.StudsOffset    = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop    = true
        bb.MaxDistance    = 500
        bb.Adornee        = root
        bb.Parent         = root

        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size              = UDim2.new(1, 0, 0.4, 0)
        nameLabel.Position          = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text              = player.Name
        nameLabel.TextColor3        = CFG.ESPColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextScaled        = true
        nameLabel.Font              = Enum.Font.GothamBold
        nameLabel.Parent            = bb
        objs.nameLabel              = nameLabel

        -- Dist label
        local distLabel = Instance.new("TextLabel")
        distLabel.Size              = UDim2.new(1, 0, 0.3, 0)
        distLabel.Position          = UDim2.new(0, 0, 0.4, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text              = ""
        distLabel.TextColor3        = Color3.fromRGB(200, 200, 255)
        distLabel.TextStrokeTransparency = 0.3
        distLabel.TextScaled        = true
        distLabel.Font              = Enum.Font.Gotham
        distLabel.Parent            = bb
        objs.distLabel              = distLabel

        -- Health bar (SurfaceGui on part)
        local healthFrame = Instance.new("Frame")
        healthFrame.Size            = UDim2.new(1, 0, 0.25, 0)
        healthFrame.Position        = UDim2.new(0, 0, 0.75, 0)
        healthFrame.BackgroundColor3= Color3.fromRGB(30, 30, 30)
        healthFrame.BackgroundTransparency = 0.3
        healthFrame.BorderSizePixel = 0
        healthFrame.Parent          = bb
        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(0, 3)
        hc.Parent = healthFrame

        local healthFill = Instance.new("Frame")
        healthFill.Size             = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
        healthFill.BorderSizePixel  = 0
        healthFill.Parent           = healthFrame
        local hfc = Instance.new("UICorner")
        hfc.CornerRadius = UDim.new(0, 3)
        hfc.Parent = healthFill
        objs.healthFill = healthFill
        objs.hum        = hum

        -- Box
        local box = Instance.new("BoxHandleAdornment")
        box.Size          = Vector3.new(4.2, 6.5, 2)
        box.Adornee       = root
        box.Color3        = CFG.ESPColor
        box.Transparency  = 0.35
        box.AlwaysOnTop   = true
        box.ZIndex        = 5
        box.Parent        = root
        objs.box = box

        ESPObjects[player] = {bb = bb, box = box, nameLabel = nameLabel,
                               distLabel = distLabel, healthFill = healthFill,
                               hum = hum, root = root}
    end

    task.spawn(waitChar)
end

-- Обновление ESP каждый кадр
RunService.Heartbeat:Connect(function()
    for player, objs in pairs(ESPObjects) do
        if not player or not player.Parent then
            ClearESP(player)
        else
            local root = objs.root
            if root and root.Parent then
                -- Видимость по STATE
                local bb  = objs.bb
                local box = objs.box
                if bb then
                    objs.nameLabel.Visible  = STATE.ESPName
                    objs.distLabel.Visible  = STATE.ESPDist
                    objs.healthFill.Parent.Visible = STATE.ESPHealth
                    bb.Enabled = STATE.ESPBox or STATE.ESPName or STATE.ESPDist or STATE.ESPHealth
                end
                if box then
                    box.Visible = STATE.ESPBox
                end

                -- Дистанция
                if STATE.ESPDist and objs.distLabel then
                    local myRoot = GetRoot()
                    if myRoot then
                        local d = (root.Position - myRoot.Position).Magnitude
                        objs.distLabel.Text = string.format("[%.0fm]", d)
                    end
                end

                -- Здоровье
                if STATE.ESPHealth and objs.healthFill and objs.hum then
                    local hp = objs.hum.Health / objs.hum.MaxHealth
                    objs.healthFill.Size = UDim2.new(hp, 0, 1, 0)
                    objs.healthFill.BackgroundColor3 = Color3.fromRGB(
                        math.floor(255 * (1 - hp)),
                        math.floor(255 * hp),
                        50
                    )
                end

                -- Rainbow ESP
                if STATE.RainbowESP then
                    local rc = RainbowColor()
                    if objs.box then objs.box.Color3 = rc end
                    if objs.nameLabel then objs.nameLabel.TextColor3 = rc end
                end
            end
        end
    end
end)

-- Tracers (Line2D через Drawing API)
local TracerLines = {}

RunService.Heartbeat:Connect(function()
    for _, ln in pairs(TracerLines) do
        if ln then ln.Visible = false end
    end
    if not STATE.ESPTracers then return end
    local myRoot = GetRoot()
    if not myRoot then return end

    local screenCenter = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)

    for i, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    if not TracerLines[i] then
                        TracerLines[i] = Drawing.new("Line")
                        TracerLines[i].Thickness = 1.5
                        TracerLines[i].ZIndex    = 5
                    end
                    TracerLines[i].Visible = true
                    TracerLines[i].From    = screenCenter
                    TracerLines[i].To      = Vector2.new(pos.X, pos.Y)
                    TracerLines[i].Color   = STATE.RainbowESP and RainbowColor(i*0.1) or CFG.ESPColor
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AIMBOT / SILENT AIM
-- ══════════════════════════════════════════════════════════════
local AimbotCircle = Drawing.new("Circle")
AimbotCircle.Thickness = 2
AimbotCircle.Color     = Color3.fromRGB(255, 80, 80)
AimbotCircle.Filled    = false
AimbotCircle.NumSides  = 64
AimbotCircle.Visible   = false

local function GetClosestPlayerInFOV()
    local closest, closestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum  = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist2D = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist2D < CFG.AimbotFOV and dist2D < closestDist then
                        closest     = player
                        closestDist = dist2D
                    end
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    -- FOV circle
    AimbotCircle.Visible = STATE.Aimbot
    if STATE.Aimbot then
        AimbotCircle.Position = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
        AimbotCircle.Radius   = CFG.AimbotFOV
    end

    -- Silent Aim
    if STATE.SilentAim then
        local target = GetClosestPlayerInFOV()
        if target and target.Character then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local hit = math.random(1, 100)
                if hit <= CFG.HitChance then
                    Mouse.Hit = CFrame.new(root.Position)
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  ДВИЖЕНИЕ — WALKFLING ДОРАБОТАН
-- ══════════════════════════════════════════════════════════════
--  Использует BodyVelocity + BodyGyro для стабильного флинга
--  с накоплением скорости и автосбросом после прыжка
-- ══════════════════════════════════════════════════════════════
local walkFlingBV, walkFlingBG
local walkFlingCooldown = false

local function CleanWalkFling()
    if walkFlingBV and walkFlingBV.Parent then walkFlingBV:Destroy() end
    if walkFlingBG and walkFlingBG.Parent then walkFlingBG:Destroy() end
    walkFlingBV = nil
    walkFlingBG = nil
end

RunService.Heartbeat:Connect(function()
    if not STATE.WalkFling then
        CleanWalkFling()
        return
    end
    local root = GetRoot()
    local hum  = GetHum()
    if not root or not hum then CleanWalkFling() return end

    -- Создаём BodyVelocity если нет
    if not walkFlingBV or not walkFlingBV.Parent then
        walkFlingBV           = Instance.new("BodyVelocity")
        walkFlingBV.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
        walkFlingBV.Velocity  = Vector3.new(0, 0, 0)
        walkFlingBV.Parent    = root
    end
    if not walkFlingBG or not walkFlingBG.Parent then
        walkFlingBG              = Instance.new("BodyGyro")
        walkFlingBG.MaxTorque    = Vector3.new(1e5, 1e5, 1e5)
        walkFlingBG.D            = 100
        walkFlingBG.CFrame       = root.CFrame
        walkFlingBG.Parent       = root
    end

    local power  = CFG.WalkFlingPower
    local look   = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    if look.Magnitude > 0 then look = look.Unit end

    -- Движение: накапливаем в направлении взгляда
    local moveDir = Vector3.new(0, 0, 0)
    if hum.MoveDirection.Magnitude > 0.1 then
        moveDir = hum.MoveDirection.Unit
    end

    walkFlingBV.Velocity   = moveDir * power + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    walkFlingBG.CFrame     = CFrame.new(root.Position, root.Position + look)
end)

-- ══════════════════════════════════════════════════════════════
--  TOUCHFLING ДОРАБОТАН
--  Направление к точке касания на экране (ray cast на workspace)
--  Вертикальная составляющая с дугой броска
-- ══════════════════════════════════════════════════════════════
local touchFlingConn
local lastTouchPos = Vector3.new()

UserInputService.TouchBegan:Connect(function(input, gp)
    if gp then return end
    if STATE.TouchFling then
        local root = GetRoot()
        if not root then return end

        -- Рейкаст через точку касания
        local ray = Camera:ScreenPointToRay(input.Position.X, input.Position.Y)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000,
            RaycastParams.new())

        local targetPos
        if result then
            targetPos = result.Position
        else
            targetPos = ray.Origin + ray.Direction * 300
        end

        lastTouchPos = targetPos

        local dir = (targetPos - root.Position)
        local flatDist = Vector3.new(dir.X, 0, dir.Z).Magnitude
        local power = CFG.TouchFlingPower

        -- Угол броска: нормализуем горизонталь, добавляем дугу
        local horizontal = Vector3.new(dir.X, 0, dir.Z)
        if horizontal.Magnitude > 0 then horizontal = horizontal.Unit end

        local liftRatio = math.clamp(1 - flatDist / 200, 0.1, 0.6)
        local velocity = horizontal * power + Vector3.new(0, power * liftRatio + 15, 0)

        -- Применяем через AssemblyLinearVelocity (без создания BV — мгновенный импульс)
        root.AssemblyLinearVelocity = velocity
    end
end)

-- ══════════════════════════════════════════════════════════════
--  FLY
-- ══════════════════════════════════════════════════════════════
local flyBV, flyBG

local function CleanFly()
    if flyBV and flyBV.Parent then flyBV:Destroy() end
    if flyBG and flyBG.Parent then flyBG:Destroy() end
    flyBV, flyBG = nil, nil
end

RunService.Heartbeat:Connect(function()
    if not STATE.Fly then CleanFly() return end
    local root = GetRoot()
    local hum  = GetHum()
    if not root or not hum then CleanFly() return end

    if not flyBV or not flyBV.Parent then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Parent   = root
    end
    if not flyBG or not flyBG.Parent then
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBG.D = 100
        flyBG.Parent = root
    end

    local speed = CFG.FlySpeed
    local cf    = Camera.CFrame
    local vel   = Vector3.new()

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end

    -- Мобильный: используем MoveDirection + камеру
    if hum.MoveDirection.Magnitude > 0.1 then
        vel = vel + (cf.LookVector * Vector3.new(1, 0, 1)).Unit * hum.MoveDirection.Magnitude
    end

    flyBV.Velocity = vel.Magnitude > 0 and vel.Unit * speed or Vector3.new()
    flyBG.CFrame   = cf
    hum.PlatformStand = true
end)

-- ══════════════════════════════════════════════════════════════
--  NOCLIP
-- ══════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    if not STATE.Noclip then return end
    local char = GetChar()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  INFINITE JUMP
-- ══════════════════════════════════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if STATE.InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  SPEED HACK
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local hum = GetHum()
    if not hum then return end
    if STATE.SpeedHack then
        hum.WalkSpeed = 16 * CFG.SpeedMultiplier
    else
        if hum.WalkSpeed > 16 then hum.WalkSpeed = 16 end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  JUMP POWER
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local hum = GetHum()
    if not hum then return end
    hum.JumpPower = CFG.JumpPower
end)

-- ══════════════════════════════════════════════════════════════
--  GRAVITY
-- ══════════════════════════════════════════════════════════════
-- управляется через CFG.Gravity + кнопку в GUI

-- ══════════════════════════════════════════════════════════════
--  GOD MODE
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not STATE.GodMode then return end
    local hum = GetHum()
    if hum then
        hum.Health = hum.MaxHealth
    end
end)

-- ══════════════════════════════════════════════════════════════
--  ANTI-AFK
-- ══════════════════════════════════════════════════════════════
local afkConn
local function StartAntiAFK()
    if afkConn then afkConn:Disconnect() end
    local vrs = LocalPlayer:FindFirstChild("VRService")
    afkConn = RunService.Heartbeat:Connect(function()
        if STATE.AntiAFK then
            -- Симулируем активность через VirtualUser
            local ok, vu = pcall(function()
                return game:GetService("VirtualUser")
            end)
            if ok and vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end
        end
    end)
end
StartAntiAFK()

-- ══════════════════════════════════════════════════════════════
--  AUTO-RESPAWN
-- ══════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    -- пересоздаём ESP для всех после respawn
    for _, p in ipairs(Players:GetPlayers()) do
        BuildESP(p)
    end
    if STATE.Fly then
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then hum.PlatformStand = false end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    CleanFly()
    CleanWalkFling()
    if STATE.AutoRespawn then
        task.wait(0.1)
        LocalPlayer:LoadCharacter()
    end
end)

-- ══════════════════════════════════════════════════════════════
--  FULLBRIGHT
-- ══════════════════════════════════════════════════════════════
local origAmbient, origOutdoor, origBrightness
local function SaveLighting()
    origAmbient    = Lighting.Ambient
    origOutdoor    = Lighting.OutdoorAmbient
    origBrightness = Lighting.Brightness
end
SaveLighting()

local function ApplyFullbright(on)
    if on then
        Lighting.Ambient         = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient  = Color3.fromRGB(178, 178, 178)
        Lighting.Brightness      = 2
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect")
                or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                fx.Enabled = false
            end
        end
    else
        Lighting.Ambient         = origAmbient
        Lighting.OutdoorAmbient  = origOutdoor
        Lighting.Brightness      = origBrightness
    end
end

-- ══════════════════════════════════════════════════════════════
--  NO FOG
-- ══════════════════════════════════════════════════════════════
local origFogEnd, origFogStart
local function SaveFog()
    origFogEnd   = Lighting.FogEnd
    origFogStart = Lighting.FogStart
end
SaveFog()

local function ApplyNoFog(on)
    if on then
        Lighting.FogEnd   = 1e6
        Lighting.FogStart = 1e6
    else
        Lighting.FogEnd   = origFogEnd
        Lighting.FogStart = origFogStart
    end
end

-- ══════════════════════════════════════════════════════════════
--  WIREFRAME
-- ══════════════════════════════════════════════════════════════
local wireframeObjs = {}
local function ApplyWireframe(on)
    if on then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:FindFirstAncestorOfClass("Model") ~= GetChar() then
                local sel = Instance.new("SelectionBox")
                sel.Adornee      = v
                sel.Color3       = Color3.fromRGB(108, 99, 255)
                sel.LineThickness= 0.03
                sel.SurfaceTransparency = 1
                sel.Parent       = v
                table.insert(wireframeObjs, sel)
            end
        end
    else
        for _, s in ipairs(wireframeObjs) do s:Destroy() end
        wireframeObjs = {}
    end
end

-- ══════════════════════════════════════════════════════════════
--  HIGHLIGHT ALL
-- ══════════════════════════════════════════════════════════════
local highlightObjs = {}
local function ApplyHighlight(on)
    if on then
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model ~= GetChar() then
                local h = Instance.new("Highlight")
                h.FillColor    = Color3.fromRGB(108, 99, 255)
                h.OutlineColor = Color3.fromRGB(80, 255, 160)
                h.FillTransparency = 0.6
                h.Parent = model
                table.insert(highlightObjs, h)
            end
        end
    else
        for _, h in ipairs(highlightObjs) do h:Destroy() end
        highlightObjs = {}
    end
end

-- ══════════════════════════════════════════════════════════════
--  CROSSHAIR
-- ══════════════════════════════════════════════════════════════
local crosshairLines = {}
local function BuildCrosshair()
    local center = Camera.ViewportSize / 2
    local size   = 12
    local lines = {
        {from = Vector2.new(center.X - size, center.Y), to = Vector2.new(center.X - 4, center.Y)},
        {from = Vector2.new(center.X + 4, center.Y),   to = Vector2.new(center.X + size, center.Y)},
        {from = Vector2.new(center.X, center.Y - size), to = Vector2.new(center.X, center.Y - 4)},
        {from = Vector2.new(center.X, center.Y + 4),   to = Vector2.new(center.X, center.Y + size)},
    }
    for _, ln in ipairs(crosshairLines) do ln:Remove() end
    crosshairLines = {}
    for _, d in ipairs(lines) do
        local l = Drawing.new("Line")
        l.From      = d.from
        l.To        = d.to
        l.Color     = Color3.fromRGB(255, 255, 255)
        l.Thickness = 1.5
        l.Visible   = STATE.Crosshair
        table.insert(crosshairLines, l)
    end
end

RunService.Heartbeat:Connect(function()
    if STATE.Crosshair and #crosshairLines == 0 then BuildCrosshair() end
    for _, l in ipairs(crosshairLines) do l.Visible = STATE.Crosshair end
end)

-- ══════════════════════════════════════════════════════════════
--  SPECTATE
-- ══════════════════════════════════════════════════════════════
local spectateSubject = nil
RunService.Heartbeat:Connect(function()
    if spectateSubject and spectateSubject.Character then
        local root = spectateSubject.Character:FindFirstChild("HumanoidRootPart")
        if root then
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame     = CFrame.new(root.Position + Vector3.new(0, 5, 10), root.Position)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  SAFE SPOT
-- ══════════════════════════════════════════════════════════════
local savedPosition = nil

local function SavePosition()
    local root = GetRoot()
    if root then savedPosition = root.CFrame end
end

local function TeleportToSaved()
    local root = GetRoot()
    if root and savedPosition then
        root.CFrame = savedPosition
    end
end

-- ══════════════════════════════════════════════════════════════
--  TELEPORT TO TARGET
-- ══════════════════════════════════════════════════════════════
local function TeleportTo(player)
    local root  = GetRoot()
    local troot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and troot then
        root.CFrame = troot.CFrame * CFrame.new(3, 0, 0)
    end
end

-- ══════════════════════════════════════════════════════════════
--  WORKSPACE GRAVITY
-- ══════════════════════════════════════════════════════════════
local function ApplyGravity(val)
    Workspace.Gravity = val
end

-- ══════════════════════════════════════════════════════════════
--  CHARACTER SCALE
-- ══════════════════════════════════════════════════════════════
local function ApplyCharScale(scale)
    local char = GetChar()
    if not char then return end
    local hum = GetHum()
    if not hum then return end
    local desc = hum:GetAppliedDescription()
    desc.HeadScale    = scale
    desc.BodyDepthScale = scale
    desc.BodyHeightScale = scale
    desc.BodyWidthScale  = scale
    hum:ApplyDescription(desc)
end

-- ══════════════════════════════════════════════════════════════
--  TIME OF DAY
-- ══════════════════════════════════════════════════════════════
local function SetTimeOfDay(hour)
    Lighting.TimeOfDay = string.format("%02d:00:00", math.clamp(math.floor(hour), 0, 23))
end

-- ══════════════════════════════════════════════════════════════
--  ANTI-RAGDOLL
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not STATE.AntiRagdoll then return end
    local hum = GetHum()
    if hum then
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll
            or hum:GetState() == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AUTO-PARRY
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not STATE.AutoParry then return end
    -- Обнаруживаем ближайших игроков с анимацией атаки
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local animator = player.Character:FindFirstChildOfClass("Animator")
                          or player.Character:FindFirstChildOfClass("Humanoid")
            if animator and animator:IsA("Humanoid") then
                local anim = animator:FindFirstChildOfClass("Animator")
                if anim then
                    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                        -- Эвристика: если в имени анимации есть attack/swing/slash
                        local name = track.Name:lower()
                        if name:find("attack") or name:find("swing") or name:find("slash") then
                            local hum = GetHum()
                            if hum then
                                hum:ChangeState(Enum.HumanoidStateType.Physics)
                                task.wait(0.05)
                                hum:ChangeState(Enum.HumanoidStateType.Running)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  FPS / PING / CLOCK (Drawing)
-- ══════════════════════════════════════════════════════════════
local statsText = Drawing.new("Text")
statsText.Size     = 16
statsText.Font     = Drawing.Fonts.Monospace
statsText.Color    = Color3.fromRGB(80, 255, 160)
statsText.Outline  = true
statsText.Position = Vector2.new(10, 10)
statsText.Visible  = false

local frameCount = 0
local fps = 0
local lastFPSUpdate = tick()

RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFPSUpdate >= 0.5 then
        fps = math.floor(frameCount / (now - lastFPSUpdate))
        frameCount = 0
        lastFPSUpdate = now
    end

    local visible = STATE.FPSCounter or STATE.PingCounter or STATE.ClockWidget
    statsText.Visible = visible
    if visible then
        local parts = {}
        if STATE.FPSCounter then
            table.insert(parts, string.format("FPS: %d", fps))
        end
        if STATE.PingCounter then
            local ping = LocalPlayer:GetNetworkPing and math.floor(LocalPlayer:GetNetworkPing() * 1000) or 0
            table.insert(parts, string.format("Ping: %dms", ping))
        end
        if STATE.ClockWidget then
            table.insert(parts, os.date("%H:%M:%S"))
        end
        statsText.Text = table.concat(parts, "  |  ")
    end
end)

-- ══════════════════════════════════════════════════════════════
--  CHAMS
-- ══════════════════════════════════════════════════════════════
local chamHighlights = {}
RunService.Heartbeat:Connect(function()
    for player, hl in pairs(chamHighlights) do
        if not player.Parent then
            hl:Destroy()
            chamHighlights[player] = nil
        end
    end
    if not STATE.Chams then
        for _, hl in pairs(chamHighlights) do hl:Destroy() end
        chamHighlights = {}
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not chamHighlights[player] then
                local hl = Instance.new("Highlight")
                hl.FillColor           = Color3.fromRGB(255, 80, 80)
                hl.OutlineColor        = Color3.fromRGB(255, 200, 0)
                hl.FillTransparency    = 0.4
                hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent              = player.Character
                chamHighlights[player] = hl
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  INFINITE STAMINA
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not STATE.InfStamina then return end
    local char = GetChar()
    if not char then return end
    -- Пытаемся найти стандартные значения стамины в разных играх
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("NumberValue") then
            local n = v.Name:lower()
            if n:find("stamina") or n:find("energy") or n:find("endurance") then
                v.Value = v.Value < 10 and 100 or v.Value
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  FAKE LAG
-- ══════════════════════════════════════════════════════════════
local fakeLagConn
local function SetFakeLag(on)
    if on then
        fakeLagConn = RunService.Heartbeat:Connect(function()
            if STATE.FakeLag then
                task.wait(0.1) -- искусственная задержка 100мс
            end
        end)
    else
        if fakeLagConn then fakeLagConn:Disconnect() end
    end
end

-- ══════════════════════════════════════════════════════════════
--  PLAYERS ESP — инициализация
-- ══════════════════════════════════════════════════════════════
for _, p in ipairs(Players:GetPlayers()) do
    BuildESP(p)
end
Players.PlayerAdded:Connect(BuildESP)
Players.PlayerRemoving:Connect(ClearESP)

-- ══════════════════════════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════════════════════════
-- Уничтожаем старый GUI если есть
if LocalPlayer.PlayerGui:FindFirstChild("DeltaXV2") then
    LocalPlayer.PlayerGui:FindFirstChild("DeltaXV2"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name          = "DeltaXV2"
ScreenGui.ResetOnSpawn  = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent        = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Главный фрейм ───────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name                = "MainFrame"
MainFrame.Size                = UDim2.new(0, 360, 0, 580)
MainFrame.Position            = UDim2.new(0.5, -180, 0.5, -290)
MainFrame.BackgroundColor3    = Color3.fromRGB(8, 8, 18)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel     = 0
MainFrame.Active              = true
MainFrame.Draggable           = true
MainFrame.ClipsDescendants    = true
MainFrame.Parent              = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Градиентная рамка (обёртка)
local BorderFrame = Instance.new("Frame")
BorderFrame.Size              = UDim2.new(1, 4, 1, 4)
BorderFrame.Position          = UDim2.new(0, -2, 0, -2)
BorderFrame.BackgroundColor3  = CFG.AccentColor
BorderFrame.BorderSizePixel   = 0
BorderFrame.ZIndex            = 0
BorderFrame.Parent            = MainFrame

local BorderGrad = Instance.new("UIGradient")
BorderGrad.Color    = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 99, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 255, 160)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 180)),
}
BorderGrad.Rotation = 45
BorderGrad.Parent   = BorderFrame

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 17)
BorderCorner.Parent = BorderFrame

-- Перекрываем бордер внутренним фреймом
local InnerBg = Instance.new("Frame")
InnerBg.Size              = UDim2.new(1, 0, 1, 0)
InnerBg.BackgroundColor3  = Color3.fromRGB(8, 8, 18)
InnerBg.BorderSizePixel   = 0
InnerBg.ZIndex            = 1
InnerBg.Parent            = MainFrame
local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 16)
InnerCorner.Parent = InnerBg

-- ─── Шапка ───────────────────────────────────────────────────
local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1, 0, 0, 56)
Header.BackgroundTransparency = 1
Header.ZIndex           = 2
Header.Parent           = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size              = UDim2.new(0, 200, 1, 0)
TitleLabel.Position          = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "⬡  DELTA X"
TitleLabel.TextColor3        = Color3.fromRGB(230, 230, 255)
TitleLabel.TextSize          = 20
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
TitleLabel.ZIndex            = 2
TitleLabel.Parent            = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size               = UDim2.new(0, 200, 0, 18)
SubLabel.Position           = UDim2.new(0, 18, 0, 32)
SubLabel.BackgroundTransparency = 1
SubLabel.Text               = "Android v2.0"
SubLabel.TextColor3         = CFG.AccentColor
SubLabel.TextSize           = 12
SubLabel.Font               = Enum.Font.GothamMedium
SubLabel.TextXAlignment     = Enum.TextXAlignment.Left
SubLabel.ZIndex             = 2
SubLabel.Parent             = Header

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size               = UDim2.new(0, 36, 0, 36)
CloseBtn.Position           = UDim2.new(1, -46, 0, 10)
CloseBtn.BackgroundColor3   = Color3.fromRGB(30, 15, 20)
CloseBtn.Text               = "✕"
CloseBtn.TextColor3         = Color3.fromRGB(255, 80, 100)
CloseBtn.TextSize           = 16
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.ZIndex             = 2
CloseBtn.Parent             = Header
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = CloseBtn
end
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Size = UDim2.new(0, 360, 0, 0)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.26)
    MainFrame.Visible = false
    MainFrame.Size    = UDim2.new(0, 360, 0, 580)
end)

-- Разделитель под шапкой
local Divider = Instance.new("Frame")
Divider.Size            = UDim2.new(1, -32, 0, 1)
Divider.Position        = UDim2.new(0, 16, 0, 55)
Divider.BackgroundColor3= CFG.AccentColor
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel = 0
Divider.ZIndex          = 2
Divider.Parent          = MainFrame
do
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
    }
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.8),
    }
    g.Parent = Divider
end

-- ─── Tab bar ─────────────────────────────────────────────────
local TABS = {
    {name = "COMBAT",   icon = "⚔"},
    {name = "MOVEMENT", icon = "💨"},
    {name = "VISUAL",   icon = "👁"},
    {name = "WORLD",    icon = "🌍"},
    {name = "PLAYER",   icon = "🧍"},
    {name = "MISC",     icon = "⚙"},
}

local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, -32, 0, 44)
TabBar.Position         = UDim2.new(0, 16, 0, 62)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 28)
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 2
TabBar.Parent           = MainFrame
do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = TabBar
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Horizontal
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, 2)
    l.VerticalAlignment = Enum.VerticalAlignment.Center
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent = TabBar
end

local TabButtons  = {}
local TabContents = {}
local ActiveTab   = nil

-- Content container
local ContentArea = Instance.new("Frame")
ContentArea.Size            = UDim2.new(1, 0, 1, -114)
ContentArea.Position        = UDim2.new(0, 0, 0, 114)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants= true
ContentArea.ZIndex          = 2
ContentArea.Parent          = MainFrame

local function SwitchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name
    for tname, content in pairs(TabContents) do
        content.Visible = (tname == name)
    end
    for tname, btn in pairs(TabButtons) do
        local isActive = (tname == name)
        Tween(btn, {
            BackgroundColor3 = isActive and CFG.AccentColor or Color3.fromRGB(14, 14, 28),
            TextColor3       = isActive and Color3.fromRGB(255, 255, 255) or CFG.TextSecondary,
        }, 0.15)
    end
end

for i, tab in ipairs(TABS) do
    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(0, 50, 0, 36)
    btn.BackgroundColor3    = Color3.fromRGB(14, 14, 28)
    btn.Text                = tab.icon
    btn.TextSize            = 18
    btn.Font                = Enum.Font.GothamBold
    btn.TextColor3          = CFG.TextSecondary
    btn.LayoutOrder         = i
    btn.BorderSizePixel     = 0
    btn.ZIndex              = 3
    btn.Parent              = TabBar
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = btn
    end

    -- Tooltip
    local tip = Instance.new("TextLabel")
    tip.Size               = UDim2.new(0, 70, 0, 22)
    tip.Position           = UDim2.new(0.5, -35, 1, 4)
    tip.BackgroundColor3   = Color3.fromRGB(20, 20, 40)
    tip.TextColor3         = Color3.fromRGB(200, 200, 255)
    tip.TextSize           = 10
    tip.Font               = Enum.Font.GothamMedium
    tip.Text               = tab.name
    tip.BackgroundTransparency = 0.2
    tip.Visible            = false
    tip.ZIndex             = 10
    tip.Parent             = btn
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = tip
    end

    btn.MouseEnter:Connect(function() tip.Visible = true end)
    btn.MouseLeave:Connect(function() tip.Visible = false end)

    -- Scroll content per tab
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                    = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency  = 1
    scroll.BorderSizePixel         = 0
    scroll.ScrollBarThickness      = 3
    scroll.ScrollBarImageColor3    = CFG.AccentColor
    scroll.CanvasSize              = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize     = Enum.AutomaticSize.Y
    scroll.Visible                 = false
    scroll.ZIndex                  = 2
    scroll.Parent                  = ContentArea
    do
        local l = Instance.new("UIListLayout")
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Padding   = UDim.new(0, 6)
        l.Parent    = scroll
        local p = Instance.new("UIPadding")
        p.PaddingLeft   = UDim.new(0, 16)
        p.PaddingRight  = UDim.new(0, 16)
        p.PaddingTop    = UDim.new(0, 10)
        p.PaddingBottom = UDim.new(0, 10)
        p.Parent        = scroll
    end

    TabButtons[tab.name]  = btn
    TabContents[tab.name] = scroll

    btn.MouseButton1Click:Connect(function()
        SwitchTab(tab.name)
    end)
end

-- ─── Хелперы для карточек ────────────────────────────────────
local function CreateToggleCard(tabName, label, desc, stateKey, onToggle, order)
    local parent = TabContents[tabName]
    local card   = Instance.new("Frame")
    card.Size               = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3   = CFG.CardBg
    card.BorderSizePixel    = 0
    card.LayoutOrder        = order or 0
    card.ZIndex             = 3
    card.Parent             = parent
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = card
    end

    -- Левая акцентная полоска
    local stripe = Instance.new("Frame")
    stripe.Size             = UDim2.new(0, 3, 0.7, 0)
    stripe.Position         = UDim2.new(0, 0, 0.15, 0)
    stripe.BackgroundColor3 = CFG.AccentColor
    stripe.BorderSizePixel  = 0
    stripe.ZIndex           = 4
    stripe.Parent           = card
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 3); c.Parent = stripe
    end

    local labelEl = Instance.new("TextLabel")
    labelEl.Size               = UDim2.new(0.7, -20, 0.5, 0)
    labelEl.Position           = UDim2.new(0, 14, 0, 6)
    labelEl.BackgroundTransparency = 1
    labelEl.Text               = label
    labelEl.TextColor3         = CFG.TextPrimary
    labelEl.TextSize           = 13
    labelEl.Font               = Enum.Font.GothamSemibold
    labelEl.TextXAlignment     = Enum.TextXAlignment.Left
    labelEl.ZIndex             = 4
    labelEl.Parent             = card

    local descEl = Instance.new("TextLabel")
    descEl.Size                = UDim2.new(0.75, -20, 0.4, 0)
    descEl.Position            = UDim2.new(0, 14, 0.55, 0)
    descEl.BackgroundTransparency = 1
    descEl.Text                = desc
    descEl.TextColor3          = CFG.TextSecondary
    descEl.TextSize            = 10
    descEl.Font                = Enum.Font.Gotham
    descEl.TextXAlignment      = Enum.TextXAlignment.Left
    descEl.ZIndex              = 4
    descEl.Parent              = card

    -- Toggle switch
    local switchBg = Instance.new("Frame")
    switchBg.Size              = UDim2.new(0, 48, 0, 26)
    switchBg.Position          = UDim2.new(1, -58, 0.5, -13)
    switchBg.BackgroundColor3  = Color3.fromRGB(30, 30, 50)
    switchBg.BorderSizePixel   = 0
    switchBg.ZIndex            = 4
    switchBg.Parent            = card
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = switchBg
    end

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 20, 0, 20)
    knob.Position         = UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(140, 140, 160)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 5
    knob.Parent           = switchBg
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = knob
    end

    local togBtn = Instance.new("TextButton")
    togBtn.Size               = UDim2.new(1, 0, 1, 0)
    togBtn.BackgroundTransparency = 1
    togBtn.Text               = ""
    togBtn.ZIndex             = 6
    togBtn.Parent             = card

    local function UpdateVisual(on)
        Tween(switchBg, {BackgroundColor3 = on and CFG.AccentColorON or Color3.fromRGB(30, 30, 50)}, 0.18)
        Tween(knob,     {Position = on and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}, 0.18)
        Tween(knob,     {BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 160)}, 0.18)
        Tween(stripe,   {BackgroundColor3 = on and CFG.AccentColorON or CFG.AccentColor}, 0.18)
    end

    -- Hover эффект
    togBtn.MouseEnter:Connect(function()
        Tween(card, {BackgroundColor3 = CFG.CardBgHover}, 0.1)
    end)
    togBtn.MouseLeave:Connect(function()
        Tween(card, {BackgroundColor3 = CFG.CardBg}, 0.1)
    end)

    togBtn.MouseButton1Click:Connect(function()
        if stateKey then
            STATE[stateKey] = not STATE[stateKey]
            UpdateVisual(STATE[stateKey])
        end
        if onToggle then onToggle(stateKey and STATE[stateKey]) end
    end)

    UpdateVisual(stateKey and STATE[stateKey] or false)
    return card, UpdateVisual
end

local function CreateSliderCard(tabName, label, desc, min, max, default, onChange, order)
    local parent = TabContents[tabName]
    local card   = Instance.new("Frame")
    card.Size               = UDim2.new(1, 0, 0, 80)
    card.BackgroundColor3   = CFG.CardBg
    card.BorderSizePixel    = 0
    card.LayoutOrder        = order or 0
    card.ZIndex             = 3
    card.Parent             = parent
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = card
    end

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.6, 0, 0, 22)
    lbl.Position           = UDim2.new(0, 14, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = CFG.TextPrimary
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.GothamSemibold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 4
    lbl.Parent             = card

    local val = default
    local valLbl = Instance.new("TextLabel")
    valLbl.Size             = UDim2.new(0.35, 0, 0, 22)
    valLbl.Position         = UDim2.new(0.65, -10, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text             = tostring(val)
    valLbl.TextColor3       = CFG.AccentColor
    valLbl.TextSize         = 13
    valLbl.Font             = Enum.Font.GothamBold
    valLbl.TextXAlignment   = Enum.TextXAlignment.Right
    valLbl.ZIndex           = 4
    valLbl.Parent           = card

    local descEl = Instance.new("TextLabel")
    descEl.Size             = UDim2.new(1, -28, 0, 16)
    descEl.Position         = UDim2.new(0, 14, 0, 30)
    descEl.BackgroundTransparency = 1
    descEl.Text             = desc
    descEl.TextColor3       = CFG.TextSecondary
    descEl.TextSize         = 10
    descEl.Font             = Enum.Font.Gotham
    descEl.TextXAlignment   = Enum.TextXAlignment.Left
    descEl.ZIndex           = 4
    descEl.Parent           = card

    local track = Instance.new("Frame")
    track.Size              = UDim2.new(1, -28, 0, 6)
    track.Position          = UDim2.new(0, 14, 0, 54)
    track.BackgroundColor3  = Color3.fromRGB(25, 25, 45)
    track.BorderSizePixel   = 0
    track.ZIndex            = 4
    track.Parent            = card
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = track
    end

    local fill = Instance.new("Frame")
    fill.Size               = UDim2.new((val - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3   = CFG.AccentColor
    fill.BorderSizePixel    = 0
    fill.ZIndex             = 5
    fill.Parent             = track
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = fill
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, CFG.AccentColor),
            ColorSequenceKeypoint.new(1, CFG.AccentColorON),
        }
        g.Parent = fill
    end

    local knob = Instance.new("Frame")
    knob.Size               = UDim2.new(0, 16, 0, 16)
    knob.Position           = UDim2.new((val - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel    = 0
    knob.ZIndex             = 6
    knob.Parent             = track
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = knob
    end

    local dragging = false
    local function UpdateSlider(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * rel)
        fill.Size     = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -8, 0.5, -8)
        valLbl.Text   = tostring(val)
        if onChange then onChange(val) end
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(inp.Position.X)
        end
    end)
    track.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseMovement) then
            UpdateSlider(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    return card
end

local function CreateActionCard(tabName, label, desc, btnText, onClick, order)
    local parent = TabContents[tabName]
    local card   = Instance.new("Frame")
    card.Size               = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3   = CFG.CardBg
    card.BorderSizePixel    = 0
    card.LayoutOrder        = order or 0
    card.ZIndex             = 3
    card.Parent             = parent
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = card
    end

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.6, -10, 0.5, 0)
    lbl.Position           = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = CFG.TextPrimary
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.GothamSemibold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 4
    lbl.Parent             = card

    local descEl = Instance.new("TextLabel")
    descEl.Size             = UDim2.new(0.6, -10, 0.4, 0)
    descEl.Position         = UDim2.new(0, 14, 0.55, 0)
    descEl.BackgroundTransparency = 1
    descEl.Text             = desc
    descEl.TextColor3       = CFG.TextSecondary
    descEl.TextSize         = 10
    descEl.Font             = Enum.Font.Gotham
    descEl.TextXAlignment   = Enum.TextXAlignment.Left
    descEl.ZIndex           = 4
    descEl.Parent           = card

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size          = UDim2.new(0, 80, 0, 32)
    actionBtn.Position      = UDim2.new(1, -90, 0.5, -16)
    actionBtn.BackgroundColor3 = CFG.AccentColor
    actionBtn.Text          = btnText
    actionBtn.TextColor3    = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize      = 11
    actionBtn.Font          = Enum.Font.GothamBold
    actionBtn.ZIndex        = 4
    actionBtn.Parent        = card
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = actionBtn
    end

    actionBtn.MouseButton1Click:Connect(function()
        Tween(actionBtn, {BackgroundColor3 = CFG.AccentColorON}, 0.1)
        task.wait(0.15)
        Tween(actionBtn, {BackgroundColor3 = CFG.AccentColor}, 0.15)
        if onClick then onClick() end
    end)

    return card
end

local function CreateSectionLabel(tabName, text, order)
    local parent = TabContents[tabName]
    local lbl    = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text               = "  " .. text
    lbl.TextColor3         = CFG.AccentColor
    lbl.TextSize           = 10
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.LayoutOrder        = order or 0
    lbl.ZIndex             = 3
    lbl.Parent             = parent
end

-- ══════════════════════════════════════════════════════════════
--  КОНТЕНТ ВКЛАДОК
-- ══════════════════════════════════════════════════════════════

-- ─── COMBAT ──────────────────────────────────────────────────
CreateSectionLabel("COMBAT", "▸ ESP", 1)
CreateToggleCard("COMBAT", "ESP Box",      "Ящик вокруг игрока",       "ESPBox",  nil,   2)
CreateToggleCard("COMBAT", "ESP Name",     "Имя над игроком",           "ESPName", nil,   3)
CreateToggleCard("COMBAT", "ESP Distance", "Дистанция до игрока",       "ESPDist", nil,   4)
CreateToggleCard("COMBAT", "ESP Health",   "Полоска здоровья",          "ESPHealth",nil,  5)
CreateToggleCard("COMBAT", "ESP Tracers",  "Линии к игрокам",           "ESPTracers",nil, 6)
CreateToggleCard("COMBAT", "Rainbow ESP",  "Радужный цвет ESP",         "RainbowESP",nil, 7)
CreateToggleCard("COMBAT", "Chams",        "Обводка врагов сквозь стены","Chams",  nil,   8)

CreateSectionLabel("COMBAT", "▸ AIM", 9)
CreateToggleCard("COMBAT", "Silent Aim",   "Попадание без прицеливания","SilentAim",nil, 10)
CreateToggleCard("COMBAT", "Aimbot",       "Автоприцеливание в FOV",    "Aimbot",  nil,  11)
CreateSliderCard("COMBAT",  "Aimbot FOV",  "Радиус цели (пиксели)",
    50, 300, CFG.AimbotFOV, function(v) CFG.AimbotFOV = v end, 12)
CreateSliderCard("COMBAT",  "Hit Chance",  "Вероятность попадания (%)",
    10, 100, CFG.HitChance, function(v) CFG.HitChance = v end, 13)

CreateSectionLabel("COMBAT", "▸ MISC", 14)
CreateToggleCard("COMBAT", "Auto Parry",   "Автоблок атак",             "AutoParry",nil,  15)
CreateToggleCard("COMBAT", "Wireframe",    "Каркасный вид карты",       "Wireframe",
    function(on) ApplyWireframe(on) end, 16)

-- ─── MOVEMENT ────────────────────────────────────────────────
CreateSectionLabel("MOVEMENT", "▸ FLING", 1)
CreateToggleCard("MOVEMENT", "WalkFling",  "Флинг при ходьбе",         "WalkFling", nil,  2)
CreateSliderCard("MOVEMENT",  "Walk Power","Сила WalkFling",
    10, 200, CFG.WalkFlingPower, function(v) CFG.WalkFlingPower = v end, 3)
CreateToggleCard("MOVEMENT", "TouchFling", "Флинг по точке касания",   "TouchFling",nil,  4)
CreateSliderCard("MOVEMENT",  "Touch Power","Сила TouchFling",
    10, 250, CFG.TouchFlingPower, function(v) CFG.TouchFlingPower = v end, 5)

CreateSectionLabel("MOVEMENT", "▸ MOVE", 6)
CreateToggleCard("MOVEMENT", "Speed Hack", "Ускорение персонажа",      "SpeedHack",nil,   7)
CreateSliderCard("MOVEMENT",  "Speed Mult","Множитель скорости",
    1, 10, CFG.SpeedMultiplier, function(v) CFG.SpeedMultiplier = v end, 8)
CreateToggleCard("MOVEMENT", "Fly",        "Режим полёта",             "Fly",
    function(on)
        if not on then
            CleanFly()
            local hum = GetHum()
            if hum then hum.PlatformStand = false end
        end
    end, 9)
CreateSliderCard("MOVEMENT",  "Fly Speed", "Скорость полёта",
    5, 200, CFG.FlySpeed, function(v) CFG.FlySpeed = v end, 10)
CreateToggleCard("MOVEMENT", "Noclip",     "Сквозь стены",             "Noclip",nil,      11)
CreateToggleCard("MOVEMENT", "Inf Jump",   "Бесконечные прыжки",       "InfJump",nil,     12)
CreateSliderCard("MOVEMENT",  "Jump Power","Высота прыжка",
    5, 200, CFG.JumpPower, function(v) CFG.JumpPower = v end, 13)
CreateSliderCard("MOVEMENT",  "Gravity",   "Гравитация Workspace",
    10, 400, CFG.Gravity, function(v) CFG.Gravity = v; ApplyGravity(v) end, 14)
CreateToggleCard("MOVEMENT", "Anti-AFK",   "Защита от AFK-кика",       "AntiAFK",nil,     15)

CreateSectionLabel("MOVEMENT", "▸ TELEPORT", 16)
CreateActionCard("MOVEMENT", "Save Position","Сохранить текущую точку", "SAVE",
    SavePosition, 17)
CreateActionCard("MOVEMENT", "Go to Saved", "Телепорт к сохранённой",  "GO",
    TeleportToSaved, 18)

-- ─── VISUAL ──────────────────────────────────────────────────
CreateSectionLabel("VISUAL", "▸ LIGHTING", 1)
CreateToggleCard("VISUAL", "Fullbright",   "Максимальная яркость",     "Fullbright",
    function(on) ApplyFullbright(on) end, 2)
CreateToggleCard("VISUAL", "No Fog",       "Убрать туман",             "NoFog",
    function(on) ApplyNoFog(on) end, 3)
CreateSliderCard("VISUAL",  "FOV",         "Угол обзора камеры",
    50, 120, 70, function(v) Camera.FieldOfView = v end, 4)

CreateSectionLabel("VISUAL", "▸ OVERLAY", 5)
CreateToggleCard("VISUAL", "Crosshair",    "Перекрестие прицела",      "Crosshair",nil,   6)
CreateToggleCard("VISUAL", "FPS Counter",  "Счётчик FPS",              "FPSCounter",nil,  7)
CreateToggleCard("VISUAL", "Ping Counter", "Пинг в мс",                "PingCounter",nil, 8)
CreateToggleCard("VISUAL", "Clock",        "Часы (UTC)",               "ClockWidget",nil, 9)

CreateSectionLabel("VISUAL", "▸ WORLD FX", 10)
CreateToggleCard("VISUAL", "Highlight All","Подсветка всех моделей",   "HighlightAll",
    function(on) ApplyHighlight(on) end, 11)

-- ─── WORLD ───────────────────────────────────────────────────
CreateSectionLabel("WORLD", "▸ TIME", 1)
CreateSliderCard("WORLD",   "Time of Day", "Час суток (0–23)",
    0, 23, 12, function(v) SetTimeOfDay(v) end, 2)

CreateSectionLabel("WORLD", "▸ PHYSICS", 3)
CreateSliderCard("WORLD",   "WS Gravity",  "Гравитация (глобальная)",
    10, 400, 196, function(v) ApplyGravity(v) end, 4)

CreateSectionLabel("WORLD", "▸ UTIL", 5)
CreateToggleCard("WORLD", "Anti-Ragdoll", "Отмена рэгдолла",          "AntiRagdoll",nil,  6)
CreateToggleCard("WORLD", "Highlight All","Обводка объектов",         "HighlightAll",
    function(on) ApplyHighlight(on) end, 7)
CreateActionCard("WORLD", "Remove Parts",  "Убрать выделенные детали","REMOVE",
    function()
        -- Убираем непрозрачные BasePart кроме персонажа
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:FindFirstAncestorOfClass("Model") ~= GetChar() then
                v.Transparency = 1
                v.CanCollide   = false
            end
        end
    end, 8)

CreateSectionLabel("WORLD", "▸ SPECTATE", 9)
do
    local playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
    end
    CreateActionCard("WORLD", "Spectate Next",
        "Смотреть за следующим игроком", "SPY",
        function()
            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then table.insert(list, p) end
            end
            if #list == 0 then return end
            local idx = 1
            if spectateSubject then
                for i, p in ipairs(list) do
                    if p == spectateSubject then idx = i % #list + 1 break end
                end
            end
            spectateSubject = list[idx]
        end, 10)
    CreateActionCard("WORLD", "Stop Spectate",
        "Вернуть управление персонажем", "STOP",
        function()
            spectateSubject    = nil
            Camera.CameraType  = Enum.CameraType.Custom
        end, 11)
end

CreateActionCard("WORLD", "TP to Player",
    "Телепорт к случайному игроку", "TP",
    function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p) end
        end
        if #list > 0 then TeleportTo(list[math.random(#list)]) end
    end, 12)

-- ─── PLAYER ──────────────────────────────────────────────────
CreateSectionLabel("PLAYER", "▸ SURVIVAL", 1)
CreateToggleCard("PLAYER", "God Mode",     "Бесконечное здоровье",     "GodMode",nil,     2)
CreateToggleCard("PLAYER", "Inf Stamina",  "Бесконечная стамина",      "InfStamina",nil,  3)
CreateToggleCard("PLAYER", "Auto Respawn", "Авто-возрождение",         "AutoRespawn",nil, 4)

CreateSectionLabel("PLAYER", "▸ BODY", 5)
CreateSliderCard("PLAYER",  "Char Scale",  "Размер персонажа",
    0.3, 3.0, 1.0, function(v)
        CFG.CharScale = v
        ApplyCharScale(v)
    end, 6)

CreateSectionLabel("PLAYER", "▸ NETWORK", 7)
CreateToggleCard("PLAYER", "Fake Lag",     "Искусственная задержка",   "FakeLag",
    function(on) SetFakeLag(on) end, 8)

-- ─── MISC ────────────────────────────────────────────────────
CreateSectionLabel("MISC", "▸ INFO", 1)
CreateActionCard("MISC", "Discord",
    "Наш канал сообщества", "JOIN",
    function()
        setclipboard("https://t.me/MornAiAi")
        -- На телефоне без setclipboard используем StarterGui нотификацию
        StarterGui:SetCore("SendNotification", {
            Title = "Delta X",
            Text  = "Ссылка скопирована!",
            Duration = 3,
        })
    end, 2)

CreateActionCard("MISC", "Script Hub",
    "Загрузить дополнительные скрипты", "OPEN",
    function()
        -- Заглушка: нотификация
        StarterGui:SetCore("SendNotification", {
            Title    = "Script Hub",
            Text     = "Функция скоро",
            Duration = 3,
        })
    end, 3)

CreateActionCard("MISC", "Panic / Hide",
    "Скрыть все элементы GUI", "PANIC",
    function()
        ScreenGui.Enabled = false
        statsText.Visible = false
        for _, l in ipairs(crosshairLines) do l.Visible = false end
        AimbotCircle.Visible = false
        task.wait(5)
        ScreenGui.Enabled = true
    end, 4)

CreateActionCard("MISC", "Toggle Theme",
    "Светлая / тёмная тема", "THEME",
    function()
        STATE.DarkTheme = not STATE.DarkTheme
        local bg = STATE.DarkTheme and Color3.fromRGB(8,8,18) or Color3.fromRGB(240,240,250)
        local card = STATE.DarkTheme and CFG.CardBg or Color3.fromRGB(220,220,235)
        local txt  = STATE.DarkTheme and CFG.TextPrimary or Color3.fromRGB(20,20,40)
        Tween(MainFrame, {BackgroundColor3 = bg}, 0.3)
        Tween(InnerBg,   {BackgroundColor3 = bg}, 0.3)
    end, 5)

CreateSectionLabel("MISC", "▸ CREDITS", 6)
do
    local credCard = Instance.new("Frame")
    credCard.Size             = UDim2.new(1, 0, 0, 80)
    credCard.BackgroundColor3 = CFG.CardBg
    credCard.BorderSizePixel  = 0
    credCard.LayoutOrder      = 7
    credCard.ZIndex           = 3
    credCard.Parent           = TabContents["MISC"]
    do
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = credCard
    end
    local credLbl = Instance.new("TextLabel")
    credLbl.Size              = UDim2.new(1, -28, 1, 0)
    credLbl.Position          = UDim2.new(0, 14, 0, 0)
    credLbl.BackgroundTransparency = 1
    credLbl.Text              = "Delta X Android v2.0\nMORN Synthesis Engine\nt.me/MornAiAi"
    credLbl.TextColor3        = CFG.TextSecondary
    credLbl.TextSize          = 11
    credLbl.Font              = Enum.Font.GothamMedium
    credLbl.TextXAlignment    = Enum.TextXAlignment.Left
    credLbl.ZIndex            = 4
    credLbl.Parent            = credCard
end

-- ══════════════════════════════════════════════════════════════
--  ОТКРЫТИЕ/ЗАКРЫТИЕ — 3-finger tap
-- ══════════════════════════════════════════════════════════════
local touchCount = 0
UserInputService.TouchBegan:Connect(function(input, gp)
    if gp then return end
    touchCount += 1
    task.delay(0.35, function() touchCount -= 1 end)
    if touchCount >= 3 then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Size = UDim2.new(0, 360, 0, 0)
            Tween(MainFrame, {Size = UDim2.new(0, 360, 0, 580)}, 0.28,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  СТАРТОВАЯ ВКЛАДКА + АНИМАЦИЯ ОТКРЫТИЯ
-- ══════════════════════════════════════════════════════════════
SwitchTab("COMBAT")

do
    MainFrame.Size = UDim2.new(0, 360, 0, 0)
    MainFrame.Visible = true
    Tween(MainFrame, {Size = UDim2.new(0, 360, 0, 580)}, 0.35,
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ══════════════════════════════════════════════════════════════
--  RAINBOW GRADIENT ANIMATION на бордере (async)
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        local t = tick() * 0.3
        BorderGrad.Rotation = (t * 60) % 360
        task.wait(0.03)
    end
end)

print("[DELTA X v2.0] :: синтез завершён | MORN")
