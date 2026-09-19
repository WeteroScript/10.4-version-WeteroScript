--[[
    MEREDIOS v9.2 · Game + Visual
    key-gate + 2 вкладки: GAME / VISUAL
    part actions: подметить / убрать / покрасить (модалка)
]]

--==== SERVICES ====
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local TeleportSvc= game:GetService("TeleportService")
local HttpSvc    = game:GetService("HttpService")
local RS         = game:GetService("ReplicatedStorage")
local LIGHT      = game:GetService("Lighting")
local CAM        = workspace.CurrentCamera
local LP = Players.LocalPlayer
if not LP then repeat task.wait(0.1); LP = Players.LocalPlayer until LP end
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.3)

--==== THEME ====
local P, Accent
local ThemeReg, SwitchRegistry, SegRegistry = {}, {}, {}
local ScreenGui, startup, menu, settings, mBtn
local Logger
local keyValidated = false

local Theme = { mode="Dark", accent="DarkBlue", anim=true }
local Palettes = {
    Light = { Bg=Color3.fromRGB(245,247,252), BgGlass=Color3.fromRGB(252,253,255),
        Card=Color3.fromRGB(255,255,255), CardEdge=Color3.fromRGB(225,230,240),
        Text=Color3.fromRGB(22,28,42), SubText=Color3.fromRGB(120,130,152),
        Track=Color3.fromRGB(205,212,226), Knob=Color3.fromRGB(70,82,108),
        Divider=Color3.fromRGB(225,230,240), Shadow=Color3.fromRGB(180,190,210) },
    Dark = { Bg=Color3.fromRGB(24,29,41), BgGlass=Color3.fromRGB(31,37,52),
        Card=Color3.fromRGB(38,45,62), CardEdge=Color3.fromRGB(58,68,88),
        Text=Color3.fromRGB(235,240,250), SubText=Color3.fromRGB(145,158,182),
        Track=Color3.fromRGB(60,70,92), Knob=Color3.fromRGB(245,250,255),
        Divider=Color3.fromRGB(58,68,88), Shadow=Color3.fromRGB(0,0,0) },
}
local Accents = {
    DarkBlue={Main=Color3.fromRGB(30,64,175),Dim=Color3.fromRGB(20,45,130)},
    Navy={Main=Color3.fromRGB(15,40,120),Dim=Color3.fromRGB(10,28,88)},
    Cyan={Main=Color3.fromRGB(0,210,255),Dim=Color3.fromRGB(0,140,190)},
    Purple={Main=Color3.fromRGB(160,95,255),Dim=Color3.fromRGB(100,55,180)},
    Pink={Main=Color3.fromRGB(255,95,175),Dim=Color3.fromRGB(190,55,130)},
}
local FlowColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(30,64,175)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(90,130,240)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(160,95,255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255,95,175)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30,64,175)),
})
local BluePinkSeq = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20,45,130)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(90,130,240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,95,175)),
})
local function refreshPalettes() P=Palettes[Theme.mode]; Accent=Accents[Theme.accent] end
refreshPalettes()

--==== HELPERS ====
local function new(c,p) local o=Instance.new(c); if p then for k,v in pairs(p) do o[k]=v end end; return o end
local function tween(o,t,p,s,d) local i=TweenInfo.new(t or 0.28, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out); local tw=TS:Create(o,i,p); tw:Play(); return tw end
local function round(o,r) local c=new("UICorner",{CornerRadius=UDim.new(0,r or 12)}); c.Parent=o; return c end
local function reg(inst,prop,key) table.insert(ThemeReg,{inst,prop,key}); if inst and inst.Parent then inst[prop]=P[key] end end

local AnimatedGradients = {}
local function registerGrad(g,speed)
    if not g then return end
    table.insert(AnimatedGradients,{g=g,speed=speed or 25,base=g.Rotation or 0})
end
do
    local last=0
    RunService.Heartbeat:Connect(function()
        local now=os.clock(); if now-last<0.03 then return end; last=now
        for i=#AnimatedGradients,1,-1 do
            local e=AnimatedGradients[i]
            if not e.g or not e.g.Parent then table.remove(AnimatedGradients,i)
            else e.g.Rotation=(e.base+now*e.speed)%360 end
        end
    end)
end

local function gradientStroke(parent, thickness, transparency, rotation)
    local s = new("UIStroke", { Thickness=thickness or 2, Transparency=transparency or 0.05,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, LineJoinMode=Enum.LineJoinMode.Round, Color=Color3.new(1,1,1) })
    s.Parent = parent
    local g = new("UIGradient", { Color=FlowColors, Rotation=rotation or 35 }); g.Parent = s
    registerGrad(g,30); return s, g
end

local function dragify(frame, handle, canDrag)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if canDrag and not canDrag() then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then dragging = false end
    end)
end

Logger = { buffer = { script = {} }, maxLen = 200 }
local function logScript(t)
    table.insert(Logger.buffer.script, "["..os.date("%H:%M:%S").."] "..t)
    while #Logger.buffer.script > Logger.maxLen do table.remove(Logger.buffer.script,1) end
end

local function applyTheme()
    refreshPalettes()
    for _,e in ipairs(ThemeReg) do
        local inst,prop,key=e[1],e[2],e[3]
        if inst and inst.Parent then tween(inst,0.32,{[prop]=P[key]}) end
    end
    for _,s in ipairs(SwitchRegistry) do
        if s.card and s.card.Parent then
            s.track.BackgroundColor3 = s.state and Accent.Main or P.Track
            s.knob.BackgroundColor3 = P.Knob
            s.lbl.TextColor3 = s.state and Accent.Main or P.SubText
        end
    end
    for _,seg in ipairs(SegRegistry) do
        if seg.refresh then seg.refresh(seg.get_current()) end
    end
end

--==== SCREEN GUI ====
do
    local targets={}
    pcall(function() table.insert(targets, game:GetService("CoreGui")) end)
    pcall(function() table.insert(targets, LP:WaitForChild("PlayerGui",5)) end)
    for _,p in ipairs(targets) do if p then for _,g in ipairs(p:GetChildren()) do
        if g.Name=="MerediosHUD" then pcall(function() g:Destroy() end) end
    end end end
end
ScreenGui = new("ScreenGui")
ScreenGui.Name="MerediosHUD"; ScreenGui.ResetOnSpawn=false; ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.DisplayOrder=999
do
    local parented=false
    local okH,hui = pcall(function() return gethui() end)
    if okH and hui then local ok=pcall(function() ScreenGui.Parent=hui end); parented = ok and ScreenGui.Parent~=nil end
    if not parented then
        local okC,cg = pcall(function() return game:GetService("CoreGui") end)
        if okC and cg then local ok=pcall(function() ScreenGui.Parent=cg end); parented = ok and ScreenGui.Parent~=nil end
    end
    if not parented then ScreenGui.Parent = LP:WaitForChild("PlayerGui",10) or LP.PlayerGui end
end

--================================================================
--  KEY GATE
--================================================================
local API_URL    = "https://bot-1789589906-7119-weterochina.bothost.tech/validate"
local API_SECRET = "hK2pX9qLm4vN8sT1wZ6yB3cD7fG0jR5aQxYzWvUtSrPo"
local AUTO_KICK  = false
local KICK_STATUS = { not_found=true, revoked=true, expired=true, hwid_mismatch=true, missing_fields=true }
local STATUS_TEXT = {
    not_found="ключ не найден", revoked="ключ отозван",
    expired="ключ истёк", hwid_mismatch="HWID занят",
    unauthorized="API-секрет неверный", bad_json="ошибка формата",
    missing_fields="пустой ключ",
}
local HWID
do
    local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if ok and id then HWID = id else HWID = tostring(LP.UserId)..":"..tostring(game.PlaceId) end
end
local function httpRequest(opts)
    local fns = {}
    if syn and syn.request then table.insert(fns,syn.request) end
    if http and http.request then table.insert(fns,http.request) end
    if type(request)=="function" then table.insert(fns,request) end
    if type(http_request)=="function" then table.insert(fns,http_request) end
    for _,fn in ipairs(fns) do
        local ok, resp = pcall(fn, opts)
        if ok and resp then
            local body = resp.Body or resp.body
            if body then return body end
        end
    end
    return nil
end
local function requestValidate(key)
    local body = HttpSvc:JSONEncode({ key=key, hwid=HWID })
    local resp = httpRequest({ Url=API_URL, Method="POST", Body=body,
        Headers={ ["Content-Type"]="application/json", ["X-Api-Secret"]=API_SECRET } })
    if not resp then return nil end
    local ok, data = pcall(function() return HttpSvc:JSONDecode(resp) end)
    if not ok then return nil end
    return data
end

--================================================================
--  STARTUP PANEL
--================================================================
do
    local STARTUP_W, STARTUP_H = 300, 200
    startup = new("CanvasGroup", {AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,STARTUP_W,0,STARTUP_H),BackgroundColor3=P.BgGlass,BackgroundTransparency=0.05,
        BorderSizePixel=0,GroupTransparency=1})
    round(startup,18)
    local startupStroke = gradientStroke(startup, 2.5, 0.08, 30); startupStroke.Transparency = 1
    startup.Parent = ScreenGui
    reg(startup, "BackgroundColor3", "BgGlass")

    local startupTitle = new("TextLabel", {BackgroundTransparency=1,Position=UDim2.new(0,-60,0,16),
        Size=UDim2.new(1,-32,0,26),Text="Meredios",TextColor3=P.Text,
        Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1})
    startupTitle.Parent = startup; reg(startupTitle,"TextColor3","Text")
    local startupSub = new("TextLabel", {BackgroundTransparency=1,Position=UDim2.new(0,-40,0,42),
        Size=UDim2.new(1,-32,0,12),Text="// v9.2",TextColor3=P.SubText,
        Font=Enum.Font.Code,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1})
    startupSub.Parent = startup; reg(startupSub,"TextColor3","SubText")

    local keyRow = new("Frame", {Position=UDim2.new(0,18,0,66),Size=UDim2.new(1,-36,0,30),
        BackgroundTransparency=1,Visible=false})
    keyRow.Parent = startup
    local keyBox = new("TextBox")
    keyBox.Parent = keyRow; keyBox.Position = UDim2.new(0,0,0,0); keyBox.Size = UDim2.new(1,-38,1,0)
    keyBox.BackgroundColor3 = P.Bg; keyBox.BackgroundTransparency = 0.3; keyBox.BorderSizePixel = 0
    keyBox.Text = ""; keyBox.PlaceholderText = "MerediosHUB-XXXX..."
    keyBox.TextColor3 = P.Text; keyBox.PlaceholderColor3 = P.SubText
    keyBox.Font = Enum.Font.Code; keyBox.TextSize = 11; keyBox.ClearTextOnFocus = false
    keyBox.TextXAlignment = Enum.TextXAlignment.Left
    round(keyBox,7)
    do local kp = new("UIPadding"); kp.PaddingLeft = UDim.new(0,8); kp.Parent = keyBox end
    reg(keyBox,"BackgroundColor3","Bg"); reg(keyBox,"TextColor3","Text"); reg(keyBox,"PlaceholderColor3","SubText")

    local keyClear = new("TextButton")
    keyClear.Parent = keyRow; keyClear.AnchorPoint = Vector2.new(1,0)
    keyClear.Position = UDim2.new(1,0,0,0); keyClear.Size = UDim2.new(0,32,1,0)
    keyClear.BackgroundColor3 = Color3.fromRGB(52,40,56); keyClear.Text = "✕"
    keyClear.TextColor3 = Color3.fromRGB(255,120,140); keyClear.Font = Enum.Font.GothamBold
    keyClear.TextSize = 13; keyClear.AutoButtonColor = false; keyClear.BorderSizePixel = 0
    round(keyClear,7)

    local keyStatus = new("TextLabel", {BackgroundTransparency=1,Position=UDim2.new(0,18,0,100),
        Size=UDim2.new(1,-36,0,14),Text="",TextColor3=Color3.fromRGB(255,90,90),
        Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Visible=false})
    keyStatus.Parent = startup

    local checkBtn = new("TextButton", {Position=UDim2.new(0,18,1,-50),Size=UDim2.new(0,100,0,28),
        BackgroundColor3=Accent.Main,BackgroundTransparency=1,Text="CHECK KEY",
        TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=10,
        AutoButtonColor=false,BorderSizePixel=0,TextTransparency=1})
    round(checkBtn,8); checkBtn.Parent = startup
    local startBtn = new("TextButton", {AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,1,-50),
        Size=UDim2.new(0,110,0,28),BackgroundColor3=Accent.Main,BackgroundTransparency=1,
        Text="НАЧАТЬ",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,
        TextSize=11,AutoButtonColor=false,BorderSizePixel=0,TextTransparency=1})
    round(startBtn,8); startBtn.Parent = startup

    tween(startup,0.45,{GroupTransparency=0})
    tween(startupStroke,0.45,{Transparency=0.08})

    task.spawn(function()
        task.wait(0.6)
        if not startup.Parent then return end
        tween(startupTitle,0.45,{Position=UDim2.new(0,18,0,16),TextTransparency=0})
        tween(startupSub,0.45,{Position=UDim2.new(0,18,0,42),TextTransparency=0})
        task.wait(0.15)
        keyRow.Visible = true; keyStatus.Visible = true
        tween(checkBtn,0.35,{BackgroundTransparency=0.15,TextTransparency=0})
        tween(startBtn,0.35,{BackgroundTransparency=0.85,TextTransparency=0.4})
    end)

    keyClear.MouseButton1Click:Connect(function() keyBox.Text=""; keyStatus.Text="" end)

    local checking = false
    local function doKeyCheck()
        if checking then return end
        local key = keyBox.Text:gsub("%s","")
        if #key < 8 then
            keyStatus.Text = "слишком короткий ключ"; keyStatus.TextColor3 = Color3.fromRGB(255,90,90); return
        end
        checking = true; local prev = checkBtn.Text; checkBtn.Text = "..."; keyStatus.Text = ""
        task.spawn(function()
            local resp = requestValidate(key)
            checking = false; checkBtn.Text = prev
            if not resp then
                keyStatus.Text = "сервер недоступен"; keyStatus.TextColor3 = Color3.fromRGB(255,90,90); return
            end
            if resp.ok then
                keyValidated = true
                keyStatus.Text = "✅ "..tostring(resp.days_left or 0).." дн."
                keyStatus.TextColor3 = Color3.fromRGB(80,220,100)
                tween(checkBtn,0.3,{BackgroundTransparency=0.6,TextTransparency=0.4})
                tween(startBtn,0.3,{BackgroundTransparency=0.1,TextTransparency=0})
                logScript("Key OK")
                return
            end
            keyStatus.Text = "❌ "..(STATUS_TEXT[resp.status] or tostring(resp.status))
            keyStatus.TextColor3 = Color3.fromRGB(255,90,90)
            if AUTO_KICK and KICK_STATUS[resp.status] then
                task.wait(0.9); pcall(function() LP:Kick("key is not allowed") end)
            end
        end)
    end
    checkBtn.MouseButton1Click:Connect(doKeyCheck)
    keyBox.FocusLost:Connect(function(enter) if enter then doKeyCheck() end end)

    _G.Meredios_startBtn = startBtn
    _G.Meredios_startup = startup
    _G.Meredios_startupStroke = startupStroke
end

--================================================================
--  MENU SKELETON
--================================================================
local makePage, makeTab, makeRow, makeSwitch, makeColorPaletteDynamic
local tabBar, contentBox, tabButtons, contentPages
local activeTab = "GAME"

do
    local MENU_W, MENU_H = 420, 420
    menu = new("CanvasGroup", {AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,MENU_W,0,MENU_H),BackgroundColor3=P.BgGlass,BackgroundTransparency=0.04,
        BorderSizePixel=0,GroupTransparency=1,Visible=false,ZIndex=1})
    round(menu,20)
    local menuStroke = gradientStroke(menu, 2.5, 0.05, 30); menuStroke.Transparency = 1
    menu.Parent = ScreenGui; reg(menu,"BackgroundColor3","BgGlass")

    local topBar = new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,ZIndex=2}); topBar.Parent=menu
    local brand = new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,18,0,10),Size=UDim2.new(0,220,0,18),
        Text="MEREDIOS v9.2",TextColor3=P.Text,Font=Enum.Font.GothamBold,TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2}); brand.Parent=topBar; reg(brand,"TextColor3","Text")
    local subBrand = new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,18,0,28),Size=UDim2.new(0,320,0,12),
        Text="game + visual",TextColor3=P.SubText,Font=Enum.Font.Code,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2}); subBrand.Parent=topBar; reg(subBrand,"TextColor3","SubText")

    local onlineDot = new("Frame",{Position=UDim2.new(0,140,0,32),Size=UDim2.new(0,5,0,5),
        BackgroundColor3=Color3.fromRGB(80,220,100),BorderSizePixel=0,ZIndex=3}); round(onlineDot,3); onlineDot.Parent=topBar
    task.spawn(function() while onlineDot.Parent do
        tween(onlineDot,1.2,{BackgroundTransparency=0.6},Enum.EasingStyle.Sine); task.wait(1.2); if not onlineDot.Parent then break end
        tween(onlineDot,1.2,{BackgroundTransparency=0},Enum.EasingStyle.Sine); task.wait(1.2)
    end end)

    local topDiv = new("Frame",{Position=UDim2.new(0,18,0,50),Size=UDim2.new(1,-36,0,1),
        BackgroundColor3=P.Divider,BorderSizePixel=0,ZIndex=2})
    topDiv.Parent = topBar; reg(topDiv,"BackgroundColor3","Divider")

    local rightBox = new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-14,0,26),
        Size=UDim2.new(0,68,0,28),BackgroundTransparency=1,ZIndex=2}); rightBox.Parent=topBar
    local gearBtn = new("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,0,0,0),
        BackgroundColor3=P.Card,BackgroundTransparency=0.15,Text="⚙",TextColor3=P.Text,
        Font=Enum.Font.GothamBold,TextSize=14,AutoButtonColor=false,BorderSizePixel=0,ZIndex=2})
    round(gearBtn,9); gearBtn.Parent=rightBox; reg(gearBtn,"BackgroundColor3","Card"); reg(gearBtn,"TextColor3","Text")
    local closeBtn = new("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,40,0,0),
        BackgroundColor3=P.Card,BackgroundTransparency=0.15,Text="×",TextColor3=P.Text,
        Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=false,BorderSizePixel=0,ZIndex=2})
    round(closeBtn,9); closeBtn.Parent=rightBox; reg(closeBtn,"BackgroundColor3","Card"); reg(closeBtn,"TextColor3","Text")
    dragify(menu, topBar, function() return not (_G.MerediosSettingsOpen == true) end)

    tabBar = new("ScrollingFrame",{Position=UDim2.new(0,12,0,58),Size=UDim2.new(1,-24,0,32),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,
        ScrollingDirection=Enum.ScrollingDirection.X,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.X,ZIndex=2}); tabBar.Parent=menu
    new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center}).Parent=tabBar
    contentBox = new("Frame",{Position=UDim2.new(0,12,0,96),Size=UDim2.new(1,-24,1,-108),
        BackgroundTransparency=1,ZIndex=2}); contentBox.Parent=menu
    tabButtons={}; contentPages={}
    _G.Meredios_gearBtn=gearBtn; _G.Meredios_closeBtn=closeBtn; _G.Meredios_menuStroke=menuStroke
end

do
    local function animPage(page)
        page.Position = UDim2.new(0,0,0,26)
        tween(page,0.38,{Position=UDim2.new(0,0,0,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        local idx = 0
        for _,child in ipairs(page:GetChildren()) do
            if child:IsA("Frame") then
                idx=idx+1
                local tb=child.BackgroundTransparency
                local st=child:FindFirstChildOfClass("UIStroke"); local ts=st and st.Transparency or 0
                child.BackgroundTransparency=1; if st then st.Transparency=1 end
                task.delay((idx-1)*0.04, function()
                    if not child.Parent then return end
                    tween(child,0.32,{BackgroundTransparency=tb})
                    if st then tween(st,0.32,{Transparency=ts}) end
                end)
            end
        end
    end
    _G.Meredios_animPage = animPage

    local function switchTab(name)
        activeTab = name
        for tName,btn in pairs(tabButtons) do
            local on = tName==name
            tween(btn,0.22,{ BackgroundTransparency = on and 0.05 or 0.85,
                TextColor3 = on and Color3.fromRGB(255,255,255) or P.SubText })
            local st = btn:FindFirstChildOfClass("UIStroke"); if st then st.Transparency = on and 0 or 0.5 end
        end
        for tName,page in pairs(contentPages) do
            if tName==name then page.Visible=true; animPage(page) else page.Visible=false end
        end
    end

    makePage = function(name)
        local page = new("ScrollingFrame", {Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=3,ScrollBarImageColor3=Accent.Main,ScrollBarImageTransparency=0.4,
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false,ZIndex=2,ClipsDescendants=true})
        page.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        page.Parent = contentBox; contentPages[name] = page; return page
    end

    makeTab = function(name, order)
        local btn = new("TextButton",{Size=UDim2.new(0,68,0,28),BackgroundColor3=Accent.Main,BackgroundTransparency=0.85,
            Text=name,TextColor3=P.SubText,Font=Enum.Font.GothamBold,TextSize=10,
            AutoButtonColor=false,BorderSizePixel=0,LayoutOrder=order})
        round(btn,9); gradientStroke(btn,2,0.5,30); btn.Parent=tabBar
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabButtons[name]=btn; return btn
    end

    makeRow = function(page, order, title, desc, height)
        height = height or (desc and 54 or 42)
        local border = new("Frame",{Size=UDim2.new(1,-14,0,height+4),BackgroundColor3=Color3.new(1,1,1),
            BorderSizePixel=0,LayoutOrder=order,ZIndex=1})
        round(border,14)
        local bg = new("UIGradient",{Color=FlowColors,Rotation=0}); bg.Parent=border; registerGrad(bg,25)
        border.Parent = page
        local card = new("Frame",{Position=UDim2.new(0,2,0,2),Size=UDim2.new(1,-4,1,-4),
            BackgroundColor3=P.Card,BackgroundTransparency=0.02,BorderSizePixel=0,ZIndex=2})
        round(card,12); card.Parent=border; reg(card,"BackgroundColor3","Card")
        local accentBar = new("Frame",{Position=UDim2.new(0,10,0,12),Size=UDim2.new(0,3,0,desc and 12 or 16),
            BackgroundColor3=Accent.Main,BorderSizePixel=0,ZIndex=3})
        round(accentBar,2); accentBar.Parent=card
        local t = new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,20,0,desc and 8 or 12),
            Size=UDim2.new(1,-90,0,16),Text=title,TextColor3=P.Text,Font=Enum.Font.GothamBold,
            TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3})
        t.Parent=card; reg(t,"TextColor3","Text")
        if desc then
            local d = new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,20,0,26),
                Size=UDim2.new(1,-32,0,22),Text=desc,TextColor3=P.SubText,Font=Enum.Font.Gotham,
                TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
                TextWrapped=true,ZIndex=3})
            d.Parent=card; reg(d,"TextColor3","SubText")
        end
        return card, border
    end

    makeSwitch = function(card, y, onChanged, initial)
        local track = new("Frame",{Size=UDim2.new(0,40,0,20),Position=UDim2.new(1,-50,0,y or 12),
            BackgroundColor3=P.Track,BorderSizePixel=0,ZIndex=3})
        round(track,10); track.Parent=card
        local knob = new("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,10,0.5,0),
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=P.Knob,BorderSizePixel=0,ZIndex=4})
        round(knob,8); knob.Parent=track
        local lbl = new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-78,0,(y or 12)+3),
            Size=UDim2.new(0,22,0,12),Text="OFF",TextColor3=P.SubText,Font=Enum.Font.GothamBold,
            TextSize=9,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3})
        lbl.Parent = card
        local entry = { state=false, track=track, knob=knob, lbl=lbl, card=card }
        table.insert(SwitchRegistry, entry)
        local function set(v)
            entry.state = v
            tween(knob,0.26,{Position = v and UDim2.new(1,-10,0.5,0) or UDim2.new(0,10,0.5,0)})
            tween(track,0.26,{BackgroundColor3 = v and Accent.Main or P.Track})
            lbl.Text = v and "ON" or "OFF"
            lbl.TextColor3 = v and Accent.Main or P.SubText
            if onChanged then onChanged(v) end
        end
        local btn = new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5})
        btn.Parent = track
        btn.MouseButton1Click:Connect(function() set(not entry.state) end)
        if initial then set(true) end
        return set
    end

    makeColorPaletteDynamic = function(parent, y, getPalette, getCurrent, onSelect, swatchSize)
        swatchSize = swatchSize or 22
        local row = new("Frame",{Position=UDim2.new(0,12,0,y),Size=UDim2.new(1,-24,0,swatchSize),
            BackgroundTransparency=1,ZIndex=3})
        row.Parent = parent
        new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),
            SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Left}).Parent=row
        local map = {}
        local function rebuild()
            for _,s in pairs(map) do pcall(function() s.btn:Destroy() end) end
            map = {}
            local palette, current = getPalette(), getCurrent()
            for i, entry in ipairs(palette) do
                local swatch = new("TextButton",{Size=UDim2.new(0,swatchSize,0,swatchSize),
                    BackgroundColor3=entry.color,BackgroundTransparency=0,Text="",
                    AutoButtonColor=false,BorderSizePixel=0,LayoutOrder=i,ZIndex=3})
                round(swatch,6)
                local st = new("UIStroke",{Thickness=1,Transparency=0.6,Color=Color3.fromRGB(255,255,255),
                    ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
                st.Parent = swatch; swatch.Parent = row
                local isCur = (entry.name == current)
                st.Transparency = isCur and 0 or 0.6
                st.Thickness = isCur and 2 or 1
                map[entry.name] = { btn=swatch, stroke=st, entry=entry }
                swatch.MouseButton1Click:Connect(function()
                    for _,s in pairs(map) do
                        local cur = (s.entry.name == entry.name)
                        s.stroke.Transparency = cur and 0 or 0.6
                        s.stroke.Thickness = cur and 2 or 1
                    end
                    if onSelect then onSelect(entry.name, entry.color) end
                end)
            end
        end
        rebuild()
        return rebuild
    end
end

for i, name in ipairs({"GAME","VISUAL"}) do makeTab(name, i) end

--================================================================
--  GAME · auto-gas + infinite wheelie
--================================================================
local Scooter = {
    INPUT=nil, MOUNT=nil, scooter=nil,
    baseStamp=0, baseClock=0, ready=false, lastFire=0, hz=30,
    gas=false, wheelie=false, steer=0,
}
do
    local f = RS:FindFirstChild("ScooterRemotes")
    if f then
        Scooter.INPUT = f:FindFirstChild("ScooterInput")
        Scooter.MOUNT = f:FindFirstChild("ScooterMount")
    end
end

function Scooter.findModel()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:GetAttribute("OwnerUserId") == LP.UserId then
            local pr = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if pr and (pr.Position - hrp.Position).Magnitude < 30 then return obj end
        end
    end
    return nil
end

function Scooter.getStamp()
    if Scooter.ready then return Scooter.baseStamp + (os.clock() - Scooter.baseClock) end
    return workspace.DistributedGameTime
end

do
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if m == "FireServer" and self == Scooter.INPUT then
            local d = ...
            if type(d) == "table" then
                if type(d.stamp) == "number" then
                    Scooter.baseStamp = d.stamp; Scooter.baseClock = os.clock(); Scooter.ready = true
                end
                if type(d.steer) == "number" then Scooter.steer = d.steer end
                if Scooter.wheelie and d.dismount == true then
                    local n = {}; for k,v in pairs(d) do n[k]=v end
                    n.dismount=false; n.brake=0; n.throttle=1
                    return old(self, n)
                end
            end
        end
        if Scooter.wheelie and typeof(self)=="Instance" and self:IsA("Humanoid") then
            if m=="ChangeState" then
                local st = ...
                if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown
                   or st==Enum.HumanoidStateType.Physics then return end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

RunService.Heartbeat:Connect(function()
    if not Scooter.wheelie then return end
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end)
    if hum.SeatPart==nil and Scooter.MOUNT then pcall(function() Scooter.MOUNT:FireServer(true) end) end
end)

RunService.Heartbeat:Connect(function(dt)
    if not Scooter.INPUT or not Scooter.ready then return end
    if not Scooter.gas and not Scooter.wheelie then return end
    Scooter.lastFire = Scooter.lastFire + dt
    if Scooter.lastFire < 1/Scooter.hz then return end
    Scooter.lastFire = 0
    pcall(function()
        Scooter.INPUT:FireServer({
            throttle=1, stamp=Scooter.getStamp(), brake=0,
            dismount=false, wheelie=Scooter.wheelie and 1 or 0, steer=Scooter.steer,
        })
    end)
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1.5)
        if not Scooter.scooter or not Scooter.scooter.Parent then Scooter.scooter = Scooter.findModel() end
    end
end)

do
    local page = makePage("GAME")
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center}).Parent=page

    do
        local card = makeRow(page, 1, "АВТО-ГАЗ", "держит газ сам · 30 Hz")
        makeSwitch(card, 12, function(v)
            Scooter.gas = v
            if not v and not Scooter.wheelie and Scooter.INPUT then
                pcall(function()
                    Scooter.INPUT:FireServer({throttle=0, stamp=Scooter.getStamp(), brake=0,
                        dismount=false, wheelie=0, steer=Scooter.steer})
                end)
            end
            logScript("Auto-gas "..(v and "ON" or "OFF"))
        end)
    end
    do
        local card = makeRow(page, 2, "INFINITE WHEELIE", "фиксирует угол · переживает падение", 70)
        makeSwitch(card, 12, function(v)
            Scooter.wheelie = v
            logScript("Infinite wheelie "..(v and "ON" or "OFF"))
        end)
    end
end

--================================================================
--  VISUAL · cam / ui / lights
--================================================================
local Vis = {
    freezeCam=false, savedCamType=nil, savedCamCFrame=nil,
    hideUI=false, uiSnapshot={},
    fullbright=false, lightingSnapshot=nil,
    noFog=false, noArms=false,
}
do
    RunService.RenderStepped:Connect(function()
        if Vis.freezeCam and Vis.savedCamCFrame then pcall(function() CAM.CFrame = Vis.savedCamCFrame end) end
    end)
    RunService.Heartbeat:Connect(function()
        if Vis.noArms then
            local char = LP.Character; if not char then return end
            for _,n in ipairs({"RightHand","LeftHand","RightLowerArm","LeftLowerArm","RightUpperArm","LeftUpperArm"}) do
                local p = char:FindFirstChild(n)
                if p and p:IsA("BasePart") then pcall(function() p.LocalTransparencyModifier=1 end) end
            end
        end
    end)
end

local function setFreezeCam(on)
    pcall(function()
        if on then
            Vis.savedCamType = CAM.CameraType
            Vis.savedCamCFrame = CAM.CFrame
            CAM.CameraType = Enum.CameraType.Scriptable
            CAM.CFrame = Vis.savedCamCFrame
        else
            if Vis.savedCamType then CAM.CameraType = Vis.savedCamType end
            Vis.savedCamCFrame = nil
        end
    end)
end
local function setHideUI(on)
    local pg = LP:FindFirstChild("PlayerGui"); if not pg then return end
    if on then
        Vis.uiSnapshot = {}
        for _,g in ipairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and g.Name~="MerediosHUD" then
                table.insert(Vis.uiSnapshot,{obj=g,enabled=g.Enabled}); g.Enabled=false
            end
        end
    else
        for _,s in ipairs(Vis.uiSnapshot) do
            pcall(function() if s.obj and s.obj.Parent then s.obj.Enabled=s.enabled end end)
        end
        Vis.uiSnapshot = {}
    end
end
local function setFullbright(on)
    if on then
        if not Vis.lightingSnapshot then
            Vis.lightingSnapshot = { Ambient=LIGHT.Ambient, OutdoorAmbient=LIGHT.OutdoorAmbient,
                Brightness=LIGHT.Brightness, ClockTime=LIGHT.ClockTime, GlobalShadows=LIGHT.GlobalShadows }
        end
        pcall(function()
            LIGHT.Ambient=Color3.fromRGB(200,200,200); LIGHT.OutdoorAmbient=Color3.fromRGB(200,200,200)
            LIGHT.Brightness=3; LIGHT.ClockTime=14; LIGHT.GlobalShadows=false
        end)
    else
        if Vis.lightingSnapshot then
            pcall(function()
                LIGHT.Ambient=Vis.lightingSnapshot.Ambient; LIGHT.OutdoorAmbient=Vis.lightingSnapshot.OutdoorAmbient
                LIGHT.Brightness=Vis.lightingSnapshot.Brightness; LIGHT.ClockTime=Vis.lightingSnapshot.ClockTime
                LIGHT.GlobalShadows=Vis.lightingSnapshot.GlobalShadows
            end)
        end
    end
end
local function setNoFog(on)
    if on then pcall(function() LIGHT.FogEnd=1e10; LIGHT.FogStart=1e10 end)
    else pcall(function() LIGHT.FogEnd=100000; LIGHT.FogStart=0 end) end
end
local function setNoArms(on)
    Vis.noArms = on
    if not on then
        local char = LP.Character; if not char then return end
        for _,n in ipairs({"RightHand","LeftHand","RightLowerArm","LeftLowerArm","RightUpperArm","LeftUpperArm"}) do
            local p = char:FindFirstChild(n)
            if p and p:IsA("BasePart") then pcall(function() p.LocalTransparencyModifier=0 end) end
        end
    end
end

--================================================================
--  SCOOTER PARTS · anchor + radius + extra
--================================================================
local Paint = { color=Color3.fromRGB(0,200,255), rainbow=false, snapshots={}, hidden={} }

Paint.PARTS = {
    {label="Задний бампер",          anchor="backbumper",     radius=1.5},
    {label="Передний бампер",        anchor="frontbumper",    radius=1.5},
    {label="Заднее крыло",           anchor="backfender",     radius=1.2, extra={"visualbackfender","backfender_pivot"}},
    {label="Переднее крыло",         anchor="frontfender",    radius=1.2, extra={"frontfork"}},
    {label="Передний маятник",       anchor="frontsuspension",radius=1.5, extra={"frontfork"}},
    {label="Задний маятник",         anchor="backsuspension", radius=1.5},
    {label="Ручка переднего тормоза",anchor="handle1",        radius=1.2},
    {label="Ручка заднего тормоза",  anchor="handle2",        radius=1.2},
    {label="Бортовой компьютер",     anchor="screen",         radius=1.8, extra={"headlight"}},
    {label="Фара",                   anchor="headlight",      radius=1.5},
    {label="Задний фонарь",          anchor="taillight",      radius=1.5},
    {label="Руль",                   anchor="handle1",        radius=2.2, extra={"handle2"}},
    {label="Рулевая стойка",         anchor="hull",           radius=1.5, extra={"vsett"}},
    {label="Дека",                   anchor="untitled",       radius=1.5, extra={"box106"}},
    {label="Корпус",                 anchor="body",           radius=1.2},
    {label="Наклейки",               anchor="sticker",        radius=1.0, extra={"stickers"}},
    {label="Заднее колесо",          anchor="backwheel",      radius=1.5, extra={"backtiresafetycollider"}},
    {label="Переднее колесо",        anchor="frontwheel",     radius=1.5, extra={"fronttiresafetycollider"}},
    {label="Все коллайдеры",         anchor="boundarycollider",radius=1.2, extra={"deckhitbox","crashguard"}},
}

local function scooterDescendants()
    local sc = Scooter.scooter
    if not sc or not sc.Parent then
        Scooter.scooter = Scooter.findModel()
        sc = Scooter.scooter
    end
    if not sc then return {} end
    return sc:GetDescendants()
end

local function matchParts(entry)
    local out = {}
    local all = scooterDescendants()
    local anchorPart = nil
    for _, d in ipairs(all) do
        if (d:IsA("BasePart") or d:IsA("MeshPart")) and d.Name:lower():find(entry.anchor, 1, true) then
            anchorPart = d; break
        end
    end
    if not anchorPart then return out end
    table.insert(out, anchorPart)
    if entry.extra then
        for _, d in ipairs(all) do
            if (d:IsA("BasePart") or d:IsA("MeshPart")) and d ~= anchorPart then
                local n = d.Name:lower()
                for _, pat in ipairs(entry.extra) do
                    if n:find(pat, 1, true) then table.insert(out, d); break end
                end
            end
        end
    end
    local r = entry.radius or 1.5
    for _, d in ipairs(all) do
        if (d:IsA("BasePart") or d:IsA("MeshPart")) and d ~= anchorPart then
            local already = false
            for _, o in ipairs(out) do if o == d then already = true; break end end
            if not already then
                local dist = (d.Position - anchorPart.Position).Magnitude
                if dist <= r then table.insert(out, d) end
            end
        end
    end
    return out
end

local function snap(p)
    local k = tostring(p)
    if Paint.snapshots[k] then return end
    Paint.snapshots[k] = { Color=p.Color, Material=p.Material, Transparency=p.Transparency, Reflectance=p.Reflectance }
end

local function restoreAll()
    for k,s in pairs(Paint.snapshots) do
        for _, p in ipairs(workspace:GetDescendants()) do
            if tostring(p)==k and p:IsA("BasePart") then
                pcall(function()
                    p.Color=s.Color; p.Material=s.Material
                    p.Transparency=s.Transparency; p.Reflectance=s.Reflectance
                end)
                break
            end
        end
    end
    Paint.snapshots = {}
end

-- loops: rainbow + hidden
RunService.Heartbeat:Connect(function()
    if not Scooter.scooter or not Scooter.scooter.Parent then Scooter.scooter = Scooter.findModel() end
    if not Scooter.scooter then return end
    if Paint.rainbow then
        local c = Color3.fromHSV((os.clock()*0.3)%1,1,1)
        for _,p in ipairs(Scooter.scooter:GetDescendants()) do
            if p:IsA("BasePart") then snap(p); pcall(function() p.Color=c end) end
        end
    end
    for _, entry in ipairs(Paint.PARTS) do
        if Paint.hidden[entry.label] then
            for _, p in ipairs(matchParts(entry)) do snap(p); pcall(function() p.Transparency=1 end) end
        end
    end
end)

--================================================================
--  VISUAL PAGE
--================================================================
do
    local page = makePage("VISUAL")
    new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center}).Parent=page

    do
        local card = makeRow(page, 1, "FREEZE CAM", "камера замирает на месте")
        makeSwitch(card, 12, function(v) Vis.freezeCam=v; setFreezeCam(v); logScript("FreezeCam "..(v and "ON" or "OFF")) end)
    end
    do
        local card = makeRow(page, 2, "СКРЫТЬ UI ИГРЫ", "прячет игровые кнопки")
        makeSwitch(card, 12, function(v) Vis.hideUI=v; setHideUI(v); logScript("HideUI "..(v and "ON" or "OFF")) end)
    end
    do
        local card = makeRow(page, 3, "FULLBRIGHT", "яркое освещение")
        makeSwitch(card, 12, function(v) Vis.fullbright=v; setFullbright(v) end)
    end
    do
        local card = makeRow(page, 4, "УБРАТЬ ТУМАН", "дальность прорисовки максимальная")
        makeSwitch(card, 12, function(v) Vis.noFog=v; setNoFog(v) end)
    end
    do
        local card = makeRow(page, 5, "УБРАТЬ РУКИ", "руки невидимы в первом лице")
        makeSwitch(card, 12, function(v) setNoArms(v) end)
    end

    -- Список частей с модалкой действий
    do
        local CUR_COLORS = {
            {name="CYAN",color=Color3.fromRGB(0,200,255)},
            {name="RED",color=Color3.fromRGB(255,50,50)},
            {name="GREEN",color=Color3.fromRGB(50,255,50)},
            {name="WHITE",color=Color3.fromRGB(255,255,255)},
            {name="BLACK",color=Color3.fromRGB(20,20,20)},
            {name="PURPLE",color=Color3.fromRGB(160,95,255)},
            {name="YELLOW",color=Color3.fromRGB(255,220,60)},
            {name="PINK",color=Color3.fromRGB(255,95,175)},
        }
        local currentColor = CUR_COLORS[1].color
        local currentColorName = "CYAN"

        local card = makeRow(page, 6, "СПИСОК ЧАСТЕЙ", "тапни — откроются действия: подметить / убрать / покрасить", 30 + #Paint.PARTS*26 + 40)
        local y = 40
        for i, entry in ipairs(Paint.PARTS) do
            local btn = new("TextButton", {
                Position=UDim2.new(0,12,0,y), Size=UDim2.new(1,-24,0,22),
                BackgroundColor3=P.Bg, BackgroundTransparency=0.4,
                Text=tostring(i)..". "..entry.label.."  ›", TextColor3=P.Text,
                Font=Enum.Font.Gotham, TextSize=10,
                AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            round(btn,6); btn.Parent=card
            reg(btn,"BackgroundColor3","Bg"); reg(btn,"TextColor3","Text")
            do local pad=new("UIPadding",{PaddingLeft=UDim.new(0,8)}); pad.Parent=btn end
            y = y + 26

            btn.MouseButton1Click:Connect(function()
                local overlay = new("Frame", {
                    Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(0,0,0),
                    BackgroundTransparency=0.5, ZIndex=500, Parent=contentBox,
                })
                local dlg = new("Frame", {
                    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
                    Size=UDim2.new(0,300,0,260), BackgroundColor3=P.Card,
                    BorderSizePixel=0, ZIndex=501, Parent=overlay,
                })
                round(dlg,14)
                local dTitle = new("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.new(0,12,0,10),
                    Size=UDim2.new(1,-40,0,18), Text=entry.label,
                    TextColor3=P.Text, Font=Enum.Font.GothamBold, TextSize=12,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=502, Parent=dlg,
                })
                reg(dTitle,"TextColor3","Text")
                local dClose = new("TextButton", {
                    Position=UDim2.new(1,-32,0,8), Size=UDim2.new(0,24,0,24),
                    BackgroundColor3=Color3.fromRGB(140,50,50), BorderSizePixel=0,
                    Text="×", TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold, TextSize=14, AutoButtonColor=false,
                    ZIndex=502, Parent=dlg,
                })
                round(dClose,7)
                dClose.MouseButton1Click:Connect(function() overlay:Destroy() end)

                local b1 = new("TextButton", {
                    Position=UDim2.new(0,12,0,42), Size=UDim2.new(1,-24,0,34),
                    BackgroundColor3=Color3.fromRGB(80,60,120), BorderSizePixel=0,
                    Text="1. ПОДМЕТИТЬ", TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold, TextSize=11, AutoButtonColor=false,
                    ZIndex=502, Parent=dlg,
                })
                round(b1,8)
                b1.MouseButton1Click:Connect(function()
                    local parts = matchParts(entry)
                    for _, p in ipairs(parts) do
                        local hl = Instance.new("Highlight")
                        hl.Adornee = p
                        hl.FillColor = Color3.fromRGB(255,100,200)
                        hl.FillTransparency = 0.4
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = p
                        task.delay(3, function() pcall(function() hl:Destroy() end) end)
                    end
                    b1.Text = "ПОДМЕТИЛ ("..#parts..")"
                    task.delay(2, function() if b1.Parent then b1.Text = "1. ПОДМЕТИТЬ" end end)
                end)

                local b2 = new("TextButton", {
                    Position=UDim2.new(0,12,0,84), Size=UDim2.new(1,-24,0,34),
                    BackgroundColor3=Paint.hidden[entry.label] and Color3.fromRGB(60,130,80) or Color3.fromRGB(140,60,60),
                    BorderSizePixel=0,
                    Text=(Paint.hidden[entry.label] and "2. ВЕРНУТЬ" or "2. УБРАТЬ"),
                    TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold, TextSize=11, AutoButtonColor=false,
                    ZIndex=502, Parent=dlg,
                })
                round(b2,8)
                b2.MouseButton1Click:Connect(function()
                    Paint.hidden[entry.label] = not Paint.hidden[entry.label]
                    local on = Paint.hidden[entry.label]
                    local parts = matchParts(entry)
                    for _, p in ipairs(parts) do
                        snap(p)
                        if on then
                            pcall(function() p.Transparency = 1 end)
                        else
                            local s = Paint.snapshots[tostring(p)]
                            pcall(function() p.Transparency = s and s.Transparency or 0 end)
                        end
                    end
                    b2.Text = on and "2. ВЕРНУТЬ" or "2. УБРАТЬ"
                    b2.BackgroundColor3 = on and Color3.fromRGB(60,130,80) or Color3.fromRGB(140,60,60)
                end)

                local b3 = new("TextButton", {
                    Position=UDim2.new(0,12,0,126), Size=UDim2.new(1,-24,0,34),
                    BackgroundColor3=Color3.fromRGB(60,110,180), BorderSizePixel=0,
                    Text="3. ПОКРАСИТЬ", TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold, TextSize=11, AutoButtonColor=false,
                    ZIndex=502, Parent=dlg,
                })
                round(b3,8)
                b3.MouseButton1Click:Connect(function()
                    local parts = matchParts(entry)
                    for _, p in ipairs(parts) do
                        snap(p); pcall(function() p.Color = currentColor end)
                    end
                    b3.Text = "ПОКРАШЕНО ("..#parts..")"
                    task.delay(1.5, function() if b3.Parent then b3.Text = "3. ПОКРАСИТЬ" end end)
                end)

                local pLabel = new("TextLabel", {
                    BackgroundTransparency=1, Position=UDim2.new(0,12,0,168),
                    Size=UDim2.new(1,-24,0,14), Text="ЦВЕТ:",
                    TextColor3=P.SubText, Font=Enum.Font.GothamBold, TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=502, Parent=dlg,
                })
                reg(pLabel,"TextColor3","SubText")

                local pRow = new("Frame", {
                    Position=UDim2.new(0,12,0,188), Size=UDim2.new(1,-24,0,26),
                    BackgroundTransparency=1, ZIndex=502, Parent=dlg,
                })
                new("UIListLayout", {
                    FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5),
                    SortOrder=Enum.SortOrder.LayoutOrder,
                }).Parent = pRow
                for i, c in ipairs(CUR_COLORS) do
                    local sw = new("TextButton", {
                        Size=UDim2.new(0,26,0,26), BackgroundColor3=c.color,
                        BorderSizePixel=0, Text="", AutoButtonColor=false,
                        LayoutOrder=i, ZIndex=503, Parent=pRow,
                    })
                    round(sw,6)
                    local st = new("UIStroke", {
                        Thickness=(c.name==currentColorName) and 2 or 1,
                        Transparency=(c.name==currentColorName) and 0 or 0.6,
                        Color=Color3.fromRGB(255,255,255),
                        ApplyStrokeMode=Enum.ApplyStrokeMode.Border, ZIndex=503,
                    })
                    st.Parent = sw
                    sw.MouseButton1Click:Connect(function()
                        currentColor = c.color
                        currentColorName = c.name
                        for _, ch in ipairs(pRow:GetChildren()) do
                            if ch:IsA("TextButton") then
                                local s = ch:FindFirstChildOfClass("UIStroke")
                                if s then s.Transparency = 0.6; s.Thickness = 1 end
                            end
                        end
                        st.Transparency = 0; st.Thickness = 2
                    end)
                end

                local rb = new("TextButton", {
                    Position=UDim2.new(0,12,0,222), Size=UDim2.new(1,-24,0,26),
                    BackgroundColor3=Color3.fromRGB(120,80,200), BorderSizePixel=0,
                    Text="РАДУГА (для всей модели)",
                    TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.GothamBold, TextSize=10, AutoButtonColor=false,
                    ZIndex=502, Parent=dlg,
                })
                round(rb,7)
                rb.MouseButton1Click:Connect(function()
                    Paint.rainbow = not Paint.rainbow
                    rb.Text = Paint.rainbow and "РАДУГА: ВКЛ" or "РАДУГА: ВЫКЛ"
                end)
            end)
        end

        local y2 = y + 6
        local resetAll = new("TextButton", {
            Position=UDim2.new(0,12,0,y2), Size=UDim2.new(1,-24,0,26),
            BackgroundColor3=Color3.fromRGB(140,60,60), BackgroundTransparency=0.2,
            Text="ВЕРНУТЬ ВСЁ (цвет + вернуть части)",
            TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.GothamBold, TextSize=10, AutoButtonColor=false, BorderSizePixel=0, ZIndex=3,
        })
        round(resetAll,7); resetAll.Parent=card
        resetAll.MouseButton1Click:Connect(function()
            restoreAll(); Paint.hidden = {}; Paint.rainbow = false
        end)
    end
end

--================================================================
--  THEME PANEL
--================================================================
do
    settings = new("CanvasGroup", {AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,320,0,250),BackgroundColor3=P.BgGlass,BackgroundTransparency=0.02,
        BorderSizePixel=0,GroupTransparency=1,Visible=false,ZIndex=5})
    round(settings,16)
    local settingsStroke = gradientStroke(settings, 2.5, 0.12, 30); settingsStroke.Transparency=1
    settings.Parent = menu; reg(settings,"BackgroundColor3","BgGlass")

    local sTitle = new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,18,0,14),
        Size=UDim2.new(1,-70,0,16),Text="SETTINGS",TextColor3=P.Text,
        Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
    sTitle.Parent=settings; reg(sTitle,"TextColor3","Text")

    local sClose = new("TextButton",{Position=UDim2.new(1,-38,0,10),Size=UDim2.new(0,26,0,26),
        BackgroundColor3=P.Card,BackgroundTransparency=0.15,Text="×",TextColor3=P.Text,
        Font=Enum.Font.GothamBold,TextSize=16,AutoButtonColor=false,BorderSizePixel=0,ZIndex=6})
    round(sClose,8); sClose.Parent=settings; reg(sClose,"BackgroundColor3","Card"); reg(sClose,"TextColor3","Text")

    local function sRow(y, titleText)
        local row = new("Frame",{Position=UDim2.new(0,18,0,y),Size=UDim2.new(1,-36,0,32),
            BackgroundTransparency=1,ZIndex=6})
        row.Parent = settings
        local lbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,80,1,0),
            Text=titleText,TextColor3=P.SubText,Font=Enum.Font.GothamMedium,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
        lbl.Parent = row; reg(lbl,"TextColor3","SubText")
        return row
    end

    local function segControl(parent, options, current, onSelect)
        local seg = new("Frame",{Position=UDim2.new(0,90,0.5,0),AnchorPoint=Vector2.new(0,0.5),
            Size=UDim2.new(1,-90,0,26),BackgroundTransparency=1,ZIndex=6})
        seg.Parent = parent
        new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),
            SortOrder=Enum.SortOrder.LayoutOrder}).Parent=seg
        local btns = {}; local currentVal = current
        local function refresh(sel)
            currentVal = sel
            for k,b in pairs(btns) do
                local on = k==sel
                tween(b,0.22,{ BackgroundTransparency=on and 0.05 or 0.82,
                    TextColor3=on and Color3.fromRGB(255,255,255) or P.SubText })
            end
        end
        for i,opt in ipairs(options) do
            local b = new("TextButton",{Size=UDim2.new(0,56,1,0),BackgroundColor3=Accent.Main,
                BackgroundTransparency=0.82,Text=opt,TextColor3=P.SubText,
                Font=Enum.Font.GothamBold,TextSize=8,AutoButtonColor=false,BorderSizePixel=0,
                LayoutOrder=i,ZIndex=6})
            round(b,7); b.Parent=seg; btns[opt]=b
            b.MouseButton1Click:Connect(function() refresh(opt); if onSelect then onSelect(opt) end end)
        end
        refresh(current)
        table.insert(SegRegistry,{ btns=btns, get_current=function() return currentVal end, refresh=refresh })
    end

    local row1 = sRow(52, "THEME")
    segControl(row1,{"LIGHT","DARK"},Theme.mode:upper(),function(v)
        Theme.mode = v=="DARK" and "Dark" or "Light"; applyTheme()
    end)
    local row2 = sRow(90, "ACCENT")
    segControl(row2,{"DARKBLUE","NAVY","CYAN","PURPLE","PINK"},"DARKBLUE",function(v)
        local map={DARKBLUE="DarkBlue",NAVY="Navy",CYAN="Cyan",PURPLE="Purple",PINK="Pink"}
        Theme.accent=map[v] or "DarkBlue"; refreshPalettes(); applyTheme()
    end)
    local row3 = sRow(128, "ANIMATIONS")
    segControl(row3,{"ON","OFF"},"ON",function(v) Theme.anim=(v=="ON") end)

    _G.Meredios_settings=settings; _G.Meredios_settingsStroke=settingsStroke; _G.Meredios_sClose=sClose
end

--================================================================
--  M BUTTON + MORPH + OPEN/CLOSE
--================================================================
do
    mBtn = new("TextButton",{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,60,0.35,0),
        BackgroundColor3=P.BgGlass,BackgroundTransparency=0.08,Text="M",TextColor3=P.Text,
        Font=Enum.Font.GothamBold,TextSize=20,AutoButtonColor=false,BorderSizePixel=0,Visible=false})
    round(mBtn,26); mBtn.Parent=ScreenGui
    reg(mBtn,"BackgroundColor3","BgGlass"); reg(mBtn,"TextColor3","Text")

    local mBtnStroke = new("UIStroke",{Thickness=2.5,Transparency=0.05,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,LineJoinMode=Enum.LineJoinMode.Round,Color=Color3.new(1,1,1)})
    mBtnStroke.Parent=mBtn
    local mBtnGrad = new("UIGradient",{Color=BluePinkSeq,Rotation=30}); mBtnGrad.Parent=mBtnStroke
    registerGrad(mBtnGrad,90)

    local drag, dragStart, startAbs, moved = false, nil, nil, false
    local tapCount, lastTapTime, TAP_WINDOW = 0, 0, 1.5
    mBtn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
            drag=true; moved=false; dragStart=input.Position; startAbs=mBtn.AbsolutePosition
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not drag then return end
        local t = input.UserInputType
        if t==Enum.UserInputType.MouseMovement or t==Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X)>4 or math.abs(d.Y)>4 then moved=true end
            if not moved then return end
            local vp = CAM.ViewportSize
            mBtn.Position = UDim2.new(0, math.clamp(startAbs.X+d.X,0,vp.X-52),
                                      0, math.clamp(startAbs.Y+d.Y,0,vp.Y-52))
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not drag then return end
        local t = input.UserInputType
        if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
            drag=false
            if not moved then
                local now = tick()
                if now-lastTapTime > TAP_WINDOW then tapCount=0 end
                tapCount=tapCount+1; lastTapTime=now
                if tapCount>=2 then tapCount=0; if _G.MerediosMorph then _G.MerediosMorph() end end
            end
        end
    end)
end

do
    local morphing, started, closeToken = false, false, 0
    _G.Meredios_markStarted = function() started = true end

    local function openMenu()
        menu.Visible = true
        menu.GroupTransparency = 1
        menu.BackgroundTransparency = 0.04
        _G.Meredios_menuStroke.Transparency = 1
        tween(menu,0.35,{GroupTransparency=0})
        tween(_G.Meredios_menuStroke,0.35,{Transparency=0.05})
        task.defer(function()
            if _G.Meredios_animPage and contentPages[activeTab] then _G.Meredios_animPage(contentPages[activeTab]) end
        end)
    end

    local function closeMenu()
        _G.MerediosSettingsOpen = false
        if _G.Meredios_settings then _G.Meredios_settings.Visible=false end
        closeToken=closeToken+1; local myToken=closeToken
        tween(menu,0.30,{GroupTransparency=1})
        tween(_G.Meredios_menuStroke,0.30,{Transparency=1})
        if _G.Meredios_settings then tween(_G.Meredios_settings,0.30,{GroupTransparency=1,BackgroundTransparency=1}) end
        if _G.Meredios_settingsStroke then tween(_G.Meredios_settingsStroke,0.30,{Transparency=1}) end
        task.delay(0.30, function()
            if closeToken ~= myToken then return end
            menu.Visible = false
            menu.GroupTransparency = 0
            if _G.Meredios_settings then _G.Meredios_settings.GroupTransparency=1; _G.Meredios_settings.BackgroundTransparency=0.02 end
            if _G.Meredios_settingsStroke then _G.Meredios_settingsStroke.Transparency=0.12 end
            mBtn.Visible = true
            mBtn.BackgroundTransparency = 1; mBtn.TextTransparency = 1
            tween(mBtn,0.32,{BackgroundTransparency=0.08,TextTransparency=0})
        end)
    end

    _G.MerediosMorph = function()
        if not started or morphing or menu.Visible then return end
        morphing = true
        local oSize, oPos, oText = mBtn.Size, mBtn.Position, mBtn.Text
        tween(mBtn,0.32,{Size=UDim2.new(0,140,0,52)})
        task.wait(0.10)
        mBtn.Text = "MEREDIOS"; mBtn.TextSize = 14
        task.wait(0.55)
        tween(mBtn,0.28,{BackgroundTransparency=1,TextTransparency=1})
        tween(mBtnStroke,0.28,{Transparency=1})
        task.wait(0.28)
        mBtn.Visible = false
        mBtn.BackgroundTransparency=0.08; mBtn.TextTransparency=0
        mBtn.Text=oText; mBtn.TextSize=20; mBtn.Size=oSize; mBtn.Position=oPos
        mBtn.TextColor3 = P.Text
        mBtnStroke.Transparency = 0.05
        morphing = false
        openMenu()
    end

    _G.Meredios_closeMenu = closeMenu
    _G.MerediosOpenSettings = function()
        _G.MerediosSettingsOpen = true
        local s = _G.Meredios_settings
        s.Visible = true; s.GroupTransparency = 1; s.BackgroundTransparency = 1
        _G.Meredios_settingsStroke.Transparency = 1
        s.Size = UDim2.new(0,280,0,220)
        tween(s,0.40,{GroupTransparency=0,BackgroundTransparency=0.02,Size=UDim2.new(0,320,0,250)},
            Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tween(_G.Meredios_settingsStroke,0.40,{Transparency=0.12})
    end
    _G.MerediosCloseSettings = function()
        _G.MerediosSettingsOpen = false
        local myToken = closeToken + 1; closeToken = myToken
        tween(_G.Meredios_settings,0.30,{GroupTransparency=1,BackgroundTransparency=1,Size=UDim2.new(0,280,0,220)},
            Enum.EasingStyle.Quint,Enum.EasingDirection.In)
        tween(_G.Meredios_settingsStroke,0.30,{Transparency=1})
        task.delay(0.30, function()
            if closeToken ~= myToken then return end
            _G.Meredios_settings.Visible=false
            _G.Meredios_settings.Size=UDim2.new(0,320,0,250)
            _G.Meredios_settings.GroupTransparency=0
            _G.Meredios_settings.BackgroundTransparency=0.02
            _G.Meredios_settingsStroke.Transparency=0.12
        end)
    end
end

_G.Meredios_gearBtn.MouseButton1Click:Connect(function() _G.MerediosOpenSettings() end)
_G.Meredios_sClose.MouseButton1Click:Connect(function() _G.MerediosCloseSettings() end)
_G.Meredios_closeBtn.MouseButton1Click:Connect(function() _G.Meredios_closeMenu() end)

--================================================================
--  START
--================================================================
_G.Meredios_startBtn.MouseButton1Click:Connect(function()
    if not keyValidated then return end
    if _G.Meredios_markStarted then _G.Meredios_markStarted() end
    tween(_G.Meredios_startup,0.4,{GroupTransparency=1})
    tween(_G.Meredios_startupStroke,0.4,{Transparency=1})
    task.delay(0.4, function()
        _G.Meredios_startup.Visible = false
        mBtn.Visible = true
        mBtn.BackgroundTransparency = 1; mBtn.TextTransparency = 1
        tween(mBtn,0.32,{BackgroundTransparency=0.08,TextTransparency=0})
        logScript("Meredios v9.2 started")
    end)
end)

for _,e in ipairs(ThemeReg) do
    local inst,prop,key=e[1],e[2],e[3]
    if inst and inst.Parent then inst[prop]=P[key] end
end

logScript("Kernel loaded · v9.2")
return true
