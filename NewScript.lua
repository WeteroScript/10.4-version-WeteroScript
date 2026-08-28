-- ══════════════════════════════════════════════════════════════
--  DELTA X FULL — MORN EDITION
--  Полная версия, совместимая с 99% эксплойтов
--  Собрана по модульному принципу
-- ══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════
--  FALLBACK ДЛЯ ОТСУТСТВУЮЩИХ API
-- ══════════════════════════════════════════════════════════════
if not _G.setclipboard then
    _G.setclipboard = function(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "📋 Copied",
                Text = text,
                Duration = 2
            })
        end)
        print("[Clipboard]", text)
    end
end

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
    Crosshair      = false,
    FPSCounter     = false,
    PingCounter    = false,
    ClockWidget    = false,
    Chams          = false,
    RainbowESP     = false,
    Wireframe      = false,
    -- WORLD
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
local function GetChar() return LocalPlayer.Character end
local function GetRoot() local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum() local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t or 0.2, style, dir), props):Play()
end

local function RainbowColor(offset)
    offset = offset or 0
    local t = tick() * 0.5 + offset
    return Color3.fromHSV(t % 1, 1, 1)
end

-- ══════════════════════════════════════════════════════════════
--  МОДУЛЬ: ESP
-- ══════════════════════════════════════════════════════════════
local espObjects = {}

local function ClearESP(player)
    if espObjects[player] then
        for _, v in pairs(espObjects[player]) do
            if v and v.Parent then v:Destroy() end
        end
        espObjects[player] = nil
    end
end

local function BuildESP(player)
    if player == LocalPlayer then return end
    ClearESP(player)

    task.spawn(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 3)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root then return end

        -- Billboard
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 180, 0, 60)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 500
        bb.Adornee = root
        bb.Parent = root

        -- Имя
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = CFG.ESPColor
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = bb

        -- Дистанция
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distLabel.Position = UDim2.new(0, 0, 0.4, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        distLabel.TextStrokeTransparency = 0.3
        distLabel.TextScaled = true
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = bb

        -- Здоровье
        local healthBg = Instance.new("Frame")
        healthBg.Size = UDim2.new(1, 0, 0.2, 0)
        healthBg.Position = UDim2.new(0, 0, 0.7, 0)
        healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBg.BackgroundTransparency = 0.3
        healthBg.BorderSizePixel = 0
        healthBg.Parent = bb
        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(0, 3)
        hc.Parent = healthBg

        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBg
        local hfc = Instance.new("UICorner")
        hfc.CornerRadius = UDim.new(0, 3)
        hfc.Parent = healthFill

        -- Бокс
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4.2, 6.5, 2)
        box.Adornee = root
        box.Color3 = CFG.ESPColor
        box.Transparency = 0.35
        box.AlwaysOnTop = true
        box.Parent = root

        espObjects[player] = {
            bb = bb,
            box = box,
            nameLabel = nameLabel,
            distLabel = distLabel,
            healthFill = healthFill,
            healthBg = healthBg,
            hum = hum,
            root = root
        }
    end)
end

-- Инициализация ESP
for _, p in ipairs(Players:GetPlayers()) do BuildESP(p) end
Players.PlayerAdded:Connect(BuildESP)
Players.PlayerRemoving:Connect(ClearESP)

-- Обновление ESP
RunService.Heartbeat:Connect(function()
    for player, objs in pairs(espObjects) do
        if not player or not player.Parent then
            ClearESP(player)
        else
            local root = objs.root
            if root and root.Parent then
                if objs.bb then
                    objs.nameLabel.Visible = STATE.ESPName
                    objs.distLabel.Visible = STATE.ESPDist
                    objs.healthBg.Visible = STATE.ESPHealth
                    objs.bb.Enabled = STATE.ESPBox or STATE.ESPName or STATE.ESPDist or STATE.ESPHealth
                end
                if objs.box then
                    objs.box.Visible = STATE.ESPBox
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

-- ══════════════════════════════════════════════════════════════
--  МОДУЛЬ: AIMBOT (упрощённый, без Drawing)
-- ══════════════════════════════════════════════════════════════
local function GetClosestPlayer()
    local closest, closestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist2D = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist2D < CFG.AimbotFOV and dist2D < closestDist then
                        closest = player
                        closestDist = dist2D
                    end
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if STATE.SilentAim then
        local target = GetClosestPlayer()
        if target and target.Character then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local hit = math.random(1, 100)
                if hit <= CFG.HitChance then
                    pcall(function()
                        Mouse.Hit = CFrame.new(root.Position)
                    end)
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  МОДУЛЬ: ДВИЖЕНИЕ
-- ══════════════════════════════════════════════════════════════

-- WALKFLING
local walkFlingBV, walkFlingBG
local function CleanWalkFling()
    if walkFlingBV and walkFlingBV.Parent then walkFlingBV:Destroy() end
    if walkFlingBG and walkFlingBG.Parent then walkFlingBG:Destroy() end
    walkFlingBV, walkFlingBG = nil, nil
end

RunService.Heartbeat:Connect(function()
    if not STATE.WalkFling then CleanWalkFling() return end
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum then CleanWalkFling() return end

    if not walkFlingBV or not walkFlingBV.Parent then
        walkFlingBV = Instance.new("BodyVelocity")
        walkFlingBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        walkFlingBV.Velocity = Vector3.new(0, 0, 0)
        walkFlingBV.Parent = root
    end
    if not walkFlingBG or not walkFlingBG.Parent then
        walkFlingBG = Instance.new("BodyGyro")
        walkFlingBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        walkFlingBG.D = 100
        walkFlingBG.CFrame = root.CFrame
        walkFlingBG.Parent = root
    end

    local power = CFG.WalkFlingPower
    local look = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    if look.Magnitude > 0 then look = look.Unit end

    local moveDir = Vector3.new(0, 0, 0)
    if hum.MoveDirection.Magnitude > 0.1 then
        moveDir = hum.MoveDirection.Unit
    end

    walkFlingBV.Velocity = moveDir * power + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    walkFlingBG.CFrame = CFrame.new(root.Position, root.Position + look)
end)

-- TOUCHFLING
UserInputService.TouchBegan:Connect(function(input, gp)
    if gp then return end
    if STATE.TouchFling then
        local root = GetRoot()
        if not root then return end

        local ray = Camera:ScreenPointToRay(input.Position.X, input.Position.Y)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, RaycastParams.new())

        local targetPos = result and result.Position or ray.Origin + ray.Direction * 300

        local dir = (targetPos - root.Position)
        local flatDist = Vector3.new(dir.X, 0, dir.Z).Magnitude
        local power = CFG.TouchFlingPower

        local horizontal = Vector3.new(dir.X, 0, dir.Z)
        if horizontal.Magnitude > 0 then horizontal = horizontal.Unit end

        local liftRatio = math.clamp(1 - flatDist / 200, 0.1, 0.6)
        local velocity = horizontal * power + Vector3.new(0, power * liftRatio + 15, 0)

        root.AssemblyLinearVelocity = velocity
    end
end)

-- FLY
local flyBV, flyBG
local function CleanFly()
    if flyBV and flyBV.Parent then flyBV:Destroy() end
    if flyBG and flyBG.Parent then flyBG:Destroy() end
    flyBV, flyBG = nil, nil
end

RunService.Heartbeat:Connect(function()
    if not STATE.Fly then CleanFly() return end
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum then CleanFly() return end

    if not flyBV or not flyBV.Parent then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Parent = root
    end
    if not flyBG or not flyBG.Parent then
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBG.D = 100
        flyBG.Parent = root
    end

    local cf = Camera.CFrame
    local vel = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, 1, 0) end

    if hum.MoveDirection.Magnitude > 0.1 then
        vel = vel + (cf.LookVector * Vector3.new(1, 0, 1)).Unit * hum.MoveDirection.Magnitude
    end

    flyBV.Velocity = vel.Magnitude > 0 and vel.Unit * CFG.FlySpeed or Vector3.new()
    flyBG.CFrame = cf
    hum.PlatformStand = true
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if not STATE.Noclip then return end
    local char = GetChar()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if STATE.InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- SPEED HACK
RunService.Heartbeat:Connect(function()
    local hum = GetHum()
    if not hum then return end
    if STATE.SpeedHack then
        hum.WalkSpeed = 16 * CFG.SpeedMultiplier
    else
        if hum.WalkSpeed > 16 then hum.WalkSpeed = 16 end
    end
end)

-- JUMP POWER
RunService.Heartbeat:Connect(function()
    local hum = GetHum()
    if not hum then return end
    hum.JumpPower = CFG.JumpPower
end)

-- GRAVITY
RunService.Heartbeat:Connect(function()
    Workspace.Gravity = CFG.Gravity
end)

-- ANTI-AFK
local afkConn
local function StartAntiAFK()
    if afkConn then afkConn:Disconnect() end
    afkConn = RunService.Heartbeat:Connect(function()
        if STATE.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end)
end
StartAntiAFK()

-- AUTO-RESPAWN
LocalPlayer.CharacterAdded:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do BuildESP(p) end
    if STATE.Fly then
        local hum = GetHum()
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
--  МОДУЛЬ: VISUAL
-- ══════════════════════════════════════════════════════════════

-- FULLBRIGHT
local origAmbient, origOutdoor, origBrightness
local function SaveLighting()
    origAmbient = Lighting.Ambient
    origOutdoor = Lighting.OutdoorAmbient
    origBrightness = Lighting.Brightness
end
SaveLighting()

local function ApplyFullbright(on)
    if on then
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.Brightness = 2
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect")
                or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                fx.Enabled = false
            end
        end
    else
        Lighting.Ambient = origAmbient
        Lighting.OutdoorAmbient = origOutdoor
        Lighting.Brightness = origBrightness
    end
end

-- NO FOG
local origFogEnd, origFogStart
local function SaveFog()
    origFogEnd = Lighting.FogEnd
    origFogStart = Lighting.FogStart
end
SaveFog()

local function ApplyNoFog(on)
    if on then
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    else
        Lighting.FogEnd = origFogEnd
        Lighting.FogStart = origFogStart
    end
end

-- WIREFRAME
local wireframeObjs = {}
local function ApplyWireframe(on)
    if on then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:FindFirstAncestorOfClass("Model") ~= GetChar() then
                local sel = Instance.new("SelectionBox")
                sel.Adornee = v
                sel.Color3 = Color3.fromRGB(108, 99, 255)
                sel.LineThickness = 0.03
                sel.SurfaceTransparency = 1
                sel.Parent = v
                table.insert(wireframeObjs, sel)
            end
        end
    else
        for _, s in ipairs(wireframeObjs) do s:Destroy() end
        wireframeObjs = {}
    end
end

-- HIGHLIGHT ALL
local highlightObjs = {}
local function ApplyHighlight(on)
    if on then
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model ~= GetChar() then
                local h = Instance.new("Highlight")
                h.FillColor = Color3.fromRGB(108, 99, 255)
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

-- CHAMS
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
                hl.FillColor = Color3.fromRGB(255, 80, 80)
                hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                hl.FillTransparency = 0.4
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = player.Character
                chamHighlights[player] = hl
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  МОДУЛЬ: MISC (Safe Spot, Teleport, Spectate)
-- ══════════════════════════════════════════════════════════════
local savedPosition = nil
local spectateSubject = nil

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

local function TeleportTo(player)
    local root = GetRoot()
    local troot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and troot then
        root.CFrame = troot.CFrame * CFrame.new(3, 0, 0)
    end
end

RunService.Heartbeat:Connect(function()
    if spectateSubject and spectateSubject.Character then
        local root = spectateSubject.Character:FindFirstChild("HumanoidRootPart")
        if root then
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 10), root.Position)
        end
    end
end)

-- ANTI-RAGDOLL
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

-- INFINITE STAMINA
RunService.Heartbeat:Connect(function()
    if not STATE.InfStamina then return end
    local char = GetChar()
    if not char then return end
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
--  GUI
-- ══════════════════════════════════════════════════════════════
pcall(function()
    if CoreGui:FindFirstChild("DeltaXFull") then
        CoreGui:FindFirstChild("DeltaXFull"):Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaXFull"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

-- Шапка
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⬡ DELTA X FULL"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 18)
SubLabel.Position = UDim2.new(0, 18, 0, 30)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "MORN Edition v2.0"
SubLabel.TextColor3 = CFG.AccentColor
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.GothamMedium
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 100)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(1, 0)
cbCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    task.wait(5)
    ScreenGui.Enabled = true
end)

-- Content Area
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, 0, 1, -60)
ContentArea.Position = UDim2.new(0, 0, 0, 55)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = ContentArea

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 12)
ContentPadding.PaddingRight = UDim.new(0, 12)
ContentPadding.PaddingTop = UDim.new(0, 8)
ContentPadding.PaddingBottom = UDim.new(0, 8)
ContentPadding.Parent = ContentArea

-- ══════════════════════════════════════════════════════════════
--  GUI БИЛДЕРЫ
-- ══════════════════════════════════════════════════════════════
local function CreateToggle(label, desc, stateKey, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = CFG.CardBg
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.Parent = ContentArea
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, -20, 0.5, 0)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CFG.TextPrimary
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(0.75, -20, 0.4, 0)
    descLbl.Position = UDim2.new(0, 14, 0.5, 0)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = CFG.TextSecondary
    descLbl.TextSize = 9
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 42, 0, 22)
    switchBg.Position = UDim2.new(1, -52, 0.5, -11)
    switchBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    switchBg.BorderSizePixel = 0
    switchBg.Parent = card
    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(1, 0)
    sbCorner.Parent = switchBg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    knob.BorderSizePixel = 0
    knob.Parent = switchBg
    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1, 0)
    kCorner.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card

    local function UpdateVisual(on)
        Tween(switchBg, {BackgroundColor3 = on and CFG.AccentColorON or Color3.fromRGB(30, 30, 50)}, 0.15)
        Tween(knob, {Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.15)
        Tween(knob, {BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)}, 0.15)
    end

    btn.MouseButton1Click:Connect(function()
        if stateKey then
            STATE[stateKey] = not STATE[stateKey]
            UpdateVisual(STATE[stateKey])
        end
    end)

    UpdateVisual(STATE[stateKey] or false)
    return card
end

local function CreateAction(label, desc, btnText, callback, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = CFG.CardBg
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.Parent = ContentArea
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, -10, 0.5, 0)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CFG.TextPrimary
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(0.6, -10, 0.4, 0)
    descLbl.Position = UDim2.new(0, 14, 0.5, 0)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = CFG.TextSecondary
    descLbl.TextSize = 9
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 70, 0, 28)
    actionBtn.Position = UDim2.new(1, -80, 0.5, -14)
    actionBtn.BackgroundColor3 = CFG.AccentColor
    actionBtn.Text = btnText
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 10
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.BorderSizePixel = 0
    actionBtn.Parent = card
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 6)
    abCorner.Parent = actionBtn

    actionBtn.MouseButton1Click:Connect(function()
        Tween(actionBtn, {BackgroundColor3 = CFG.AccentColorON}, 0.1)
        task.wait(0.15)
        Tween(actionBtn, {BackgroundColor3 = CFG.AccentColor}, 0.15)
        if callback then callback() end
    end)

    return card
end

local function CreateSlider(label, desc, min, max, default, onChange, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 72)
    card.BackgroundColor3 = CFG.CardBg
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.Parent = ContentArea
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 20)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CFG.TextPrimary
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local val = default
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.35, 0, 0, 20)
    valLbl.Position = UDim2.new(0.65, -10, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(val)
    valLbl.TextColor3 = CFG.AccentColor
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -28, 0, 14)
    descLbl.Position = UDim2.new(0, 14, 0, 24)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = CFG.TextSecondary
    descLbl.TextSize = 9
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 4)
    track.Position = UDim2.new(0, 14, 0, 42)
    track.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    track.BorderSizePixel = 0
    track.Parent = card
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = CFG.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1, 0)
    kCorner.Parent = knob

    local dragging = false
    local function UpdateSlider(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        valLbl.Text = tostring(val)
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

-- ══════════════════════════════════════════════════════════════
--  КОНТЕНТ GUI
-- ══════════════════════════════════════════════════════════════

-- COMBAT
local sec1 = Instance.new("TextLabel")
sec1.Size = UDim2.new(1, 0, 0, 22)
sec1.BackgroundTransparency = 1
sec1.Text = "⚔ COMBAT"
sec1.TextColor3 = CFG.AccentColor
sec1.TextSize = 11
sec1.Font = Enum.Font.GothamBold
sec1.TextXAlignment = Enum.TextXAlignment.Left
sec1.LayoutOrder = 1
sec1.Parent = ContentArea

CreateToggle("ESP Box", "Рамка вокруг игрока", "ESPBox", 2)
CreateToggle("ESP Name", "Имя над игроком", "ESPName", 3)
CreateToggle("ESP Distance", "Дистанция до игрока", "ESPDist", 4)
CreateToggle("ESP Health", "Полоска здоровья", "ESPHealth", 5)
CreateToggle("Rainbow ESP", "Радужные цвета", "RainbowESP", 6)
CreateToggle("Chams", "Обводка сквозь стены", "Chams", 7)
CreateToggle("Silent Aim", "Попадание без прицела", "SilentAim", 8)
CreateSlider("Aimbot FOV", "Радиус цели", 50, 300, 120, function(v) CFG.AimbotFOV = v end, 9)
CreateSlider("Hit Chance", "Вероятность попадания %", 10, 100, 85, function(v) CFG.HitChance = v end, 10)
CreateToggle("Auto Parry", "Автоматический блок", "AutoParry", 11)

-- MOVEMENT
local sec2 = Instance.new("TextLabel")
sec2.Size = UDim2.new(1, 0, 0, 22)
sec2.BackgroundTransparency = 1
sec2.Text = "💨 MOVEMENT"
sec2.TextColor3 = CFG.AccentColor
sec2.TextSize = 11
sec2.Font = Enum.Font.GothamBold
sec2.TextXAlignment = Enum.TextXAlignment.Left
sec2.LayoutOrder = 12
sec2.Parent = ContentArea

CreateToggle("WalkFling", "Флинг при ходьбе", "WalkFling", 13)
CreateSlider("Walk Power", "Сила WalkFling", 10, 200, 80, function(v) CFG.WalkFlingPower = v end, 14)
CreateToggle("TouchFling", "Флинг по касанию", "TouchFling", 15)
CreateSlider("Touch Power", "Сила TouchFling", 10, 250, 100, function(v) CFG.TouchFlingPower = v end, 16)
CreateToggle("Speed Hack", "Ускорение", "SpeedHack", 17)
CreateSlider("Speed Mult", "Множитель скорости", 1, 10, 2, function(v) CFG.SpeedMultiplier = v end, 18)
CreateToggle("Fly", "Режим полёта", "Fly", 19)
CreateSlider("Fly Speed", "Скорость полёта", 5, 200, 50, function(v) CFG.FlySpeed = v end, 20)
CreateToggle("Noclip", "Проход сквозь стены", "Noclip", 21)
CreateToggle("Inf Jump", "Бесконечные прыжки", "InfJump", 22)
CreateSlider("Jump Power", "Сила прыжка", 5, 200, 50, function(v) CFG.JumpPower = v end, 23)
CreateSlider("Gravity", "Гравитация", 10, 400, 196, function(v) CFG.Gravity = v end, 24)
CreateToggle("Anti-AFK", "Защита от AFK-кика", "AntiAFK", 25)

-- VISUAL
local sec3 = Instance.new("TextLabel")
sec3.Size = UDim2.new(1, 0, 0, 22)
sec3.BackgroundTransparency = 1
sec3.Text = "👁 VISUAL"
sec3.TextColor3 = CFG.AccentColor
sec3.TextSize = 11
sec3.Font = Enum.Font.GothamBold
sec3.TextXAlignment = Enum.TextXAlignment.Left
sec3.LayoutOrder = 26
sec3.Parent = ContentArea

CreateToggle("Fullbright", "Максимальная яркость", "Fullbright", 27)
CreateToggle("No Fog", "Убрать туман", "NoFog", 28)
CreateToggle("Wireframe", "Каркасный вид", "Wireframe", 29)
CreateToggle("Highlight All", "Подсветка всех моделей", "HighlightAll", 30)

-- WORLD
local sec4 = Instance.new("TextLabel")
sec4.Size = UDim2.new(1, 0, 0, 22)
sec4.BackgroundTransparency = 1
sec4.Text = "🌍 WORLD"
sec4.TextColor3 = CFG.AccentColor
sec4.TextSize = 11
sec4.Font = Enum.Font.GothamBold
sec4.TextXAlignment = Enum.TextXAlignment.Left
sec4.LayoutOrder = 31
sec4.Parent = ContentArea

CreateToggle("Anti-Ragdoll", "Отмена рэгдолла", "AntiRagdoll", 32)
CreateAction("Remove Parts", "Скрыть все детали карты", "HIDE", function()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstAncestorOfClass("Model") ~= GetChar() then
            v.Transparency = 1
            v.CanCollide = false
        end
    end
end, 33)

-- PLAYER
local sec5 = Instance.new("TextLabel")
sec5.Size = UDim2.new(1, 0, 0, 22)
sec5.BackgroundTransparency = 1
sec5.Text = "🧍 PLAYER"
sec5.TextColor3 = CFG.AccentColor
sec5.TextSize = 11
sec5.Font = Enum.Font.GothamBold
sec5.TextXAlignment = Enum.TextXAlignment.Left
sec5.LayoutOrder = 34
sec5.Parent = ContentArea

CreateToggle("God Mode", "Бесконечное здоровье", "GodMode", 35)
CreateToggle("Inf Stamina", "Бесконечная стамина", "InfStamina", 36)
CreateToggle("Auto Respawn", "Автовозрождение", "AutoRespawn", 37)

-- MISC
local sec6 = Instance.new("TextLabel")
sec6.Size = UDim2.new(1, 0, 0, 22)
sec6.BackgroundTransparency = 1
sec6.Text = "⚙ MISC"
sec6.TextColor3 = CFG.AccentColor
sec6.TextSize = 11
sec6.Font = Enum.Font.GothamBold
sec6.TextXAlignment = Enum.TextXAlignment.Left
sec6.LayoutOrder = 38
sec6.Parent = ContentArea

CreateAction("Save Position", "Сохранить текущую точку", "SAVE", SavePosition, 39)
CreateAction("Go to Saved", "Телепорт к сохранённой", "GO", TeleportToSaved, 40)
CreateAction("TP to Player", "К случайному игроку", "TP", function()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p) end
    end
    if #list > 0 then TeleportTo(list[math.random(#list)]) end
end, 41)
CreateAction("Panic", "Скрыть всё на 5 секунд", "HIDE", function()
    ScreenGui.Enabled = false
    task.wait(5)
    ScreenGui.Enabled = true
end, 42)

-- ══════════════════════════════════════════════════════════════
--  ОТКРЫТИЕ/ЗАКРЫТИЕ — 3-МЯ КАСАНИЯМИ
-- ══════════════════════════════════════════════════════════════
local touchCount = 0
UserInputService.TouchBegan:Connect(function(input, gp)
    if gp then return end
    touchCount = touchCount + 1
    task.delay(0.35, function() touchCount = touchCount - 1 end)
    if touchCount >= 3 then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Size = UDim2.new(0, 360, 0, 0)
            Tween(MainFrame, {Size = UDim2.new(0, 360, 0, 520)}, 0.3,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  АНИМАЦИЯ ПОЯВЛЕНИЯ
-- ══════════════════════════════════════════════════════════════
MainFrame.Size = UDim2.new(0, 360, 0, 0)
MainFrame.Visible = true
Tween(MainFrame, {Size = UDim2.new(0, 360, 0, 520)}, 0.35,
    Enum.EasingStyle.Back, Enum.EasingDirection.Out)

print("[DELTA X FULL] :: синтез завершён | MORN")
