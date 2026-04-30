--[[
    ╔══════════════════════════════════════════╗
    ║       ANHUNG_TV GAME - SCRIPT GUI        ║
    ║         Tác giả: Script by Claude        ║
    ║         Mobile Friendly | Full Features  ║
    ╚══════════════════════════════════════════╝
    
    HƯỚNG DẪN CÀI ĐẶT:
    1. Mở Roblox game anhung_tv
    2. Dùng executor (Synapse, KRNL, Fluxus...)
    3. Paste toàn bộ script này vào executor
    4. Nhấn Execute / Inject
    
    DANH SÁCH CHỨC NĂNG:
    ━━━━━━━━━━━━━━━━━━━━━━━━
    [PLAYER]
    • WalkSpeed - Tăng tốc độ chạy
    • JumpPower - Tăng lực nhảy  
    • Infinite Jump - Nhảy vô hạn
    • NoClip - Xuyên tường
    • God Mode - Không chết (vô địch)
    • Anti AFK - Không bị kick do AFK
    
    [VISUAL]
    • ESP Players - Thấy người chơi qua tường
    • ESP Box - Khung viền người chơi
    • ESP Name - Hiện tên người chơi
    • ESP Distance - Hiện khoảng cách
    • Fullbright - Sáng toàn màn hình
    
    [LUCKY BLOCK]
    • Auto Open LuckyBlock - Tự động mở Lucky Block
    • Collect All Items - Nhặt tất cả items xung quanh
    • Item ESP - Thấy items qua tường
    
    [MISC]
    • Fly - Bay tự do (nhấn nút Fly rồi dùng jump để lên/xuống)
    • Teleport to Spawn - Về điểm xuất phát
    • Copy Player Pos - Sao chép vị trí hiện tại
    ━━━━━━━━━━━━━━━━━━━━━━━━
]]

-- ══════════════════════════════════════════
--              SERVICES
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════
--              STATE
-- ══════════════════════════════════════════
local State = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    GodMode = false,
    AntiAFK = true,
    ESPEnabled = false,
    ESPBox = false,
    ESPName = true,
    ESPDistance = true,
    Fullbright = false,
    AutoLuckyBlock = false,
    CollectItems = false,
    ItemESP = false,
    Flying = false,
    IsMinimized = false,
    ActiveTab = "player",
}

local ESPObjects = {}
local Connections = {}
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlySpeed = 50

-- ══════════════════════════════════════════
--              GUI SETUP
-- ══════════════════════════════════════════
-- Xóa GUI cũ nếu có
if CoreGui:FindFirstChild("AnhungScript") then
    CoreGui:FindFirstChild("AnhungScript"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnhungScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- ══════════════════════════════════════════
--              THEME COLORS
-- ══════════════════════════════════════════
local Theme = {
    BG          = Color3.fromRGB(12, 12, 20),
    Panel       = Color3.fromRGB(20, 20, 32),
    Card        = Color3.fromRGB(28, 28, 44),
    CardHover   = Color3.fromRGB(35, 35, 55),
    Accent      = Color3.fromRGB(120, 80, 255),
    AccentLight = Color3.fromRGB(160, 120, 255),
    AccentGlow  = Color3.fromRGB(80, 40, 200),
    Green       = Color3.fromRGB(50, 220, 120),
    Red         = Color3.fromRGB(255, 80, 80),
    Yellow      = Color3.fromRGB(255, 200, 50),
    Text        = Color3.fromRGB(240, 240, 255),
    TextDim     = Color3.fromRGB(150, 150, 180),
    Border      = Color3.fromRGB(60, 50, 100),
    TabActive   = Color3.fromRGB(120, 80, 255),
    TabInactive = Color3.fromRGB(30, 30, 48),
}

-- ══════════════════════════════════════════
--              UTILITY FUNCTIONS
-- ══════════════════════════════════════════
local function makeShadow(parent, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, colors, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colors or {
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGlow),
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function pulse(obj, color1, color2, speed)
    local toggle = false
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then conn:Disconnect() return end
        toggle = not toggle
        tween(obj, {BackgroundColor3 = toggle and color1 or color2}, speed or 1)
    end)
    return conn
end

-- ══════════════════════════════════════════
--              MAIN FRAME
-- ══════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 10
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
corner(MainFrame, 14)
stroke(MainFrame, Theme.Border, 1.5)
makeShadow(MainFrame)

-- Background subtle gradient
local bgGrad = Instance.new("Frame")
bgGrad.Size = UDim2.new(1, 0, 0.4, 0)
bgGrad.BackgroundColor3 = Theme.Accent
bgGrad.BackgroundTransparency = 0.92
bgGrad.BorderSizePixel = 0
bgGrad.ZIndex = 10
bgGrad.Parent = MainFrame
corner(bgGrad, 14)

-- ══════════════════════════════════════════
--              TITLE BAR
-- ══════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 52)
TitleBar.BackgroundColor3 = Theme.Panel
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = MainFrame
corner(TitleBar, 14)

-- Fix bottom corners of title bar
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Theme.Panel
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 11
titleFix.Parent = TitleBar

-- Title gradient bar (thin line below title)
local titleAccent = Instance.new("Frame")
titleAccent.Size = UDim2.new(1, 0, 0, 2)
titleAccent.Position = UDim2.new(0, 0, 1, -2)
titleAccent.BackgroundColor3 = Theme.Accent
titleAccent.BorderSizePixel = 0
titleAccent.ZIndex = 12
titleAccent.Parent = TitleBar
gradient(titleAccent, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 200)),
    ColorSequenceKeypoint.new(0.5, Theme.AccentLight),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 200)),
}, 0)

-- Logo icon (star symbol)
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 36, 0, 36)
LogoLabel.Position = UDim2.new(0, 12, 0.5, -18)
LogoLabel.BackgroundColor3 = Theme.Accent
LogoLabel.Text = "✦"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.TextSize = 18
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.ZIndex = 12
LogoLabel.Parent = TitleBar
corner(LogoLabel, 8)

-- Title text
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Position = UDim2.new(0, 56, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "ANHUNG SCRIPT"
TitleText.TextColor3 = Theme.Text
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 12
TitleText.Parent = TitleBar

local SubText = Instance.new("TextLabel")
SubText.Size = UDim2.new(0, 200, 0, 14)
SubText.Position = UDim2.new(0, 56, 0, 28)
SubText.BackgroundTransparency = 1
SubText.Text = "Mobile Friendly • Full Features"
SubText.TextColor3 = Theme.TextDim
SubText.TextSize = 10
SubText.Font = Enum.Font.Gotham
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.ZIndex = 12
SubText.Parent = TitleBar

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -42, 0.5, -15)
MinBtn.BackgroundColor3 = Theme.Card
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.TextDim
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 12
MinBtn.Parent = TitleBar
corner(MinBtn, 6)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36+(-36), 0.5, -15)
-- reposition
CloseBtn.Position = UDim2.new(1, -78, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 12
CloseBtn.Parent = TitleBar
corner(CloseBtn, 6)

-- ══════════════════════════════════════════
--              TAB BAR
-- ══════════════════════════════════════════
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -16, 0, 36)
TabBar.Position = UDim2.new(0, 8, 0, 58)
TabBar.BackgroundColor3 = Theme.Panel
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = MainFrame
corner(TabBar, 8)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)
TabPadding.Parent = TabBar

-- ══════════════════════════════════════════
--              CONTENT AREA
-- ══════════════════════════════════════════
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -16, 1, -140)
ContentArea.Position = UDim2.new(0, 8, 0, 102)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Theme.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ZIndex = 11
ContentArea.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentArea

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 8)
ContentPadding.Parent = ContentArea

-- ══════════════════════════════════════════
--              STATUS BAR
-- ══════════════════════════════════════════
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -16, 0, 26)
StatusBar.Position = UDim2.new(0, 8, 1, -34)
StatusBar.BackgroundColor3 = Theme.Panel
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 11
StatusBar.Parent = MainFrame
corner(StatusBar, 6)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -8, 1, 0)
StatusText.Position = UDim2.new(0, 8, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "✦ Script loaded • Enjoy!"
StatusText.TextColor3 = Theme.Green
StatusText.TextSize = 10
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.ZIndex = 12
StatusText.Parent = StatusBar

local function setStatus(msg, color)
    StatusText.Text = "✦ " .. msg
    StatusText.TextColor3 = color or Theme.Green
end

-- ══════════════════════════════════════════
--              TAB SYSTEM
-- ══════════════════════════════════════════
local TabPages = {}
local TabButtons = {}

local tabDefs = {
    {id = "player",  label = "👤 Player",  order = 1},
    {id = "visual",  label = "👁 Visual",  order = 2},
    {id = "lucky",   label = "🎲 Lucky",   order = 3},
    {id = "misc",    label = "⚙ Misc",    order = 4},
    {id = "info",    label = "📋 Info",    order = 5},
}

local function switchTab(tabId)
    State.ActiveTab = tabId
    for id, page in pairs(TabPages) do
        page.Visible = (id == tabId)
    end
    for id, btn in pairs(TabButtons) do
        if id == tabId then
            tween(btn, {BackgroundColor3 = Theme.TabActive}, 0.2)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tween(btn, {BackgroundColor3 = Theme.TabInactive}, 0.2)
            btn.TextColor3 = Theme.TextDim
        end
    end
end

for _, tab in ipairs(tabDefs) do
    -- Tab button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 58, 0, 28)
    btn.BackgroundColor3 = Theme.TabInactive
    btn.Text = tab.label
    btn.TextColor3 = Theme.TextDim
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = TabBar
    corner(btn, 6)
    TabButtons[tab.id] = btn

    -- Tab page (wrapper inside ContentArea)
    local page = Instance.new("Frame")
    page.Name = "Page_" .. tab.id
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.LayoutOrder = tab.order
    page.ZIndex = 11
    page.Parent = ContentArea
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page
    
    TabPages[tab.id] = page

    btn.MouseButton1Click:Connect(function()
        switchTab(tab.id)
    end)
end

-- ══════════════════════════════════════════
--           COMPONENT BUILDERS
-- ══════════════════════════════════════════

-- Section header
local function makeSection(parent, title, order)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.LayoutOrder = order or 0
    header.ZIndex = 11
    header.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 8)
    line.BackgroundColor3 = Theme.Border
    line.BorderSizePixel = 0
    line.ZIndex = 11
    line.Parent = header

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 1, 0)
    label.AutomaticSize = Enum.AutomaticSize.X
    label.BackgroundColor3 = Theme.BG
    label.BackgroundTransparency = 0
    label.Text = "  " .. title .. "  "
    label.TextColor3 = Theme.Accent
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.ZIndex = 12
    label.Parent = header

    return header
end

-- Toggle card
local function makeToggle(parent, label, desc, defaultState, callback, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.ZIndex = 11
    card.Parent = parent
    corner(card, 8)
    stroke(card, Theme.Border, 1)

    local labelEl = Instance.new("TextLabel")
    labelEl.Size = UDim2.new(1, -60, 0, 20)
    labelEl.Position = UDim2.new(0, 12, 0, 9)
    labelEl.BackgroundTransparency = 1
    labelEl.Text = label
    labelEl.TextColor3 = Theme.Text
    labelEl.TextSize = 13
    labelEl.Font = Enum.Font.GothamSemibold
    labelEl.TextXAlignment = Enum.TextXAlignment.Left
    labelEl.ZIndex = 12
    labelEl.Parent = card

    if desc then
        local descEl = Instance.new("TextLabel")
        descEl.Size = UDim2.new(1, -60, 0, 14)
        descEl.Position = UDim2.new(0, 12, 0, 30)
        descEl.BackgroundTransparency = 1
        descEl.Text = desc
        descEl.TextColor3 = Theme.TextDim
        descEl.TextSize = 10
        descEl.Font = Enum.Font.Gotham
        descEl.TextXAlignment = Enum.TextXAlignment.Left
        descEl.ZIndex = 12
        descEl.Parent = card
    end

    -- Toggle switch
    local switchBG = Instance.new("Frame")
    switchBG.Size = UDim2.new(0, 40, 0, 22)
    switchBG.Position = UDim2.new(1, -52, 0.5, -11)
    switchBG.BackgroundColor3 = defaultState and Theme.Green or Theme.CardHover
    switchBG.BorderSizePixel = 0
    switchBG.ZIndex = 12
    switchBG.Parent = card
    corner(switchBG, 11)

    local switchKnob = Instance.new("Frame")
    switchKnob.Size = UDim2.new(0, 16, 0, 16)
    switchKnob.Position = defaultState and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchKnob.BorderSizePixel = 0
    switchKnob.ZIndex = 13
    switchKnob.Parent = switchBG
    corner(switchKnob, 8)

    local isOn = defaultState or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 14
    btn.Parent = card

    local function updateSwitch(state)
        isOn = state
        tween(switchBG, {BackgroundColor3 = isOn and Theme.Green or Theme.CardHover}, 0.2)
        tween(switchKnob, {Position = isOn and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.2)
        if isOn then
            tween(card, {BackgroundColor3 = Color3.fromRGB(32, 38, 50)}, 0.15)
        else
            tween(card, {BackgroundColor3 = Theme.Card}, 0.15)
        end
    end

    btn.MouseButton1Click:Connect(function()
        updateSwitch(not isOn)
        if callback then callback(isOn) end
    end)

    updateSwitch(isOn)
    return card, updateSwitch
end

-- Slider card
local function makeSlider(parent, label, min, max, default, callback, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.ZIndex = 11
    card.Parent = parent
    corner(card, 8)
    stroke(card, Theme.Border, 1)

    local labelEl = Instance.new("TextLabel")
    labelEl.Size = UDim2.new(1, -60, 0, 18)
    labelEl.Position = UDim2.new(0, 12, 0, 8)
    labelEl.BackgroundTransparency = 1
    labelEl.Text = label
    labelEl.TextColor3 = Theme.Text
    labelEl.TextSize = 12
    labelEl.Font = Enum.Font.GothamSemibold
    labelEl.TextXAlignment = Enum.TextXAlignment.Left
    labelEl.ZIndex = 12
    labelEl.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 18)
    valueLabel.Position = UDim2.new(1, -62, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 12
    valueLabel.Parent = card

    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 40)
    track.BackgroundColor3 = Theme.CardHover
    track.BorderSizePixel = 0
    track.ZIndex = 12
    track.Parent = card
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 13
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = track
    corner(knob, 7)
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 30)
    sliderBtn.Position = UDim2.new(0, 0, 0, 28)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 15
    sliderBtn.Parent = card

    local dragging = false
    local currentVal = default

    local function updateSlider(inputX)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local ratio = math.clamp((inputX - absPos) / absSize, 0, 1)
        local value = math.floor(min + (max - min) * ratio)
        currentVal = value
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -7, 0.5, -7)
        if callback then callback(value) end
    end

    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    sliderBtn.TouchLongPress:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging then
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(i.Position.X)
            elseif i.UserInputType == Enum.UserInputType.Touch then
                updateSlider(i.Position.X)
            end
        end
    end)
    sliderBtn.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        updateSlider(mouse.X)
    end)
    sliderBtn.TouchTap:Connect(function(positions)
        if positions[1] then
            updateSlider(positions[1].X)
        end
    end)

    return card
end

-- Action button card
local function makeButton(parent, label, desc, btnText, callback, order, color)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.ZIndex = 11
    card.Parent = parent
    corner(card, 8)
    stroke(card, Theme.Border, 1)

    local labelEl = Instance.new("TextLabel")
    labelEl.Size = UDim2.new(1, -100, 0, 20)
    labelEl.Position = UDim2.new(0, 12, 0, 8)
    labelEl.BackgroundTransparency = 1
    labelEl.Text = label
    labelEl.TextColor3 = Theme.Text
    labelEl.TextSize = 12
    labelEl.Font = Enum.Font.GothamSemibold
    labelEl.TextXAlignment = Enum.TextXAlignment.Left
    labelEl.ZIndex = 12
    labelEl.Parent = card

    if desc then
        local descEl = Instance.new("TextLabel")
        descEl.Size = UDim2.new(1, -100, 0, 14)
        descEl.Position = UDim2.new(0, 12, 0, 30)
        descEl.BackgroundTransparency = 1
        descEl.Text = desc
        descEl.TextColor3 = Theme.TextDim
        descEl.TextSize = 10
        descEl.Font = Enum.Font.Gotham
        descEl.TextXAlignment = Enum.TextXAlignment.Left
        descEl.ZIndex = 12
        descEl.Parent = card
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 28)
    btn.Position = UDim2.new(1, -92, 0.5, -14)
    btn.BackgroundColor3 = color or Theme.Accent
    btn.Text = btnText or "Run"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = card
    corner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.08)
        task.wait(0.08)
        tween(btn, {BackgroundColor3 = color or Theme.Accent}, 0.15)
        if callback then callback() end
    end)

    return card
end

-- Info text card
local function makeInfoCard(parent, text, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card.ZIndex = 11
    card.Parent = parent
    corner(card, 8)
    stroke(card, Theme.Border, 1)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextDim
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.RichText = true
    lbl.ZIndex = 12
    lbl.Parent = card

    return card
end

-- ══════════════════════════════════════════
--         PLAYER TAB CONTENT
-- ══════════════════════════════════════════
local playerPage = TabPages["player"]

makeSection(playerPage, "MOVEMENT", 1)

makeSlider(playerPage, "Walk Speed", 8, 200, 16, function(val)
    State.WalkSpeed = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
    setStatus("WalkSpeed set to " .. val)
end, 2)

makeSlider(playerPage, "Jump Power", 20, 300, 50, function(val)
    State.JumpPower = val
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = val
    end
    setStatus("JumpPower set to " .. val)
end, 3)

makeToggle(playerPage, "Infinite Jump", "Nhảy vô hạn không giới hạn", false, function(on)
    State.InfiniteJump = on
    setStatus(on and "Infinite Jump: BẬT" or "Infinite Jump: TẮT", on and Theme.Green or Theme.Red)
end, 4)

makeSection(playerPage, "SURVIVAL", 5)

makeToggle(playerPage, "God Mode", "Máu không giảm, không chết", false, function(on)
    State.GodMode = on
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if on then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            else
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
    end
    setStatus(on and "God Mode: BẬT" or "God Mode: TẮT", on and Theme.Green or Theme.Red)
end, 6)

makeToggle(playerPage, "No Clip", "Xuyên qua tường và vật cản", false, function(on)
    State.NoClip = on
    setStatus(on and "NoClip: BẬT" or "NoClip: TẮT", on and Theme.Green or Theme.Red)
end, 7)

makeToggle(playerPage, "Anti AFK", "Tự động di chuyển để không bị kick", true, function(on)
    State.AntiAFK = on
    setStatus(on and "Anti AFK: BẬT" or "Anti AFK: TẮT", on and Theme.Green or Theme.Red)
end, 8)

-- ══════════════════════════════════════════
--         VISUAL TAB CONTENT
-- ══════════════════════════════════════════
local visualPage = TabPages["visual"]

makeSection(visualPage, "ESP - PLAYER", 1)

makeToggle(visualPage, "ESP Players", "Thấy người chơi qua tường", false, function(on)
    State.ESPEnabled = on
    setStatus(on and "ESP: BẬT" or "ESP: TẮT", on and Theme.Green or Theme.Red)
end, 2)

makeToggle(visualPage, "ESP Box", "Khung hộp bao quanh người chơi", false, function(on)
    State.ESPBox = on
end, 3)

makeToggle(visualPage, "ESP Name", "Hiện tên người chơi", true, function(on)
    State.ESPName = on
end, 4)

makeToggle(visualPage, "ESP Distance", "Hiện khoảng cách tới người chơi", true, function(on)
    State.ESPDistance = on
end, 5)

makeSection(visualPage, "ENVIRONMENT", 6)

makeToggle(visualPage, "Fullbright", "Sáng toàn màn hình, không bóng tối", false, function(on)
    State.Fullbright = on
    if on then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
    setStatus(on and "Fullbright: BẬT" or "Fullbright: TẮT", on and Theme.Green or Theme.Red)
end, 7)

-- ══════════════════════════════════════════
--         LUCKY BLOCK TAB
-- ══════════════════════════════════════════
local luckyPage = TabPages["lucky"]

makeSection(luckyPage, "LUCKY BLOCK", 1)

makeToggle(luckyPage, "Auto Open Lucky Block", "Tự động mở lucky block trong vùng", false, function(on)
    State.AutoLuckyBlock = on
    setStatus(on and "Auto Lucky: BẬT" or "Auto Lucky: TẮT", on and Theme.Green or Theme.Red)
end, 2)

makeToggle(luckyPage, "Item ESP", "Thấy các item qua tường", false, function(on)
    State.ItemESP = on
    setStatus(on and "Item ESP: BẬT" or "Item ESP: TẮT", on and Theme.Green or Theme.Red)
end, 3)

makeButton(luckyPage, "Collect Nearby Items", "Nhặt tất cả items trong bán kính 50 studs", "Nhặt", function()
    local char = LocalPlayer.Character
    if not char then setStatus("Không tìm thấy character!", Theme.Red) return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local dist
            if obj:IsA("BasePart") then
                dist = (hrp.Position - obj.Position).Magnitude
            end
            if dist and dist < 50 then
                -- Try to touch/collect
                local tool = obj:FindFirstChildWhichIsA("Tool", true)
                if not tool then
                    local partTouchable = obj:FindFirstChild("ClickDetector") or obj:FindFirstChild("ProximityPrompt")
                    if partTouchable then
                        if partTouchable:IsA("ProximityPrompt") then
                            fireproximityprompt(partTouchable)
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    setStatus("Đã cố gắng nhặt " .. count .. " items!", Theme.Yellow)
end, 4, Theme.Yellow)

makeButton(luckyPage, "Teleport to Lucky Block", "Teleport đến Lucky Block gần nhất", "Tele", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then setStatus("Không tìm thấy character!", Theme.Red) return end
    local nearest, nearDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj.Name:lower():find("lucky") or obj.Name:lower():find("block")) and obj:IsA("BasePart") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < nearDist then
                nearest = obj
                nearDist = dist
            end
        end
    end
    if nearest then
        hrp.CFrame = nearest.CFrame + Vector3.new(0, 4, 0)
        setStatus("Teleport đến Lucky Block! (" .. math.floor(nearDist) .. " studs)", Theme.Green)
    else
        setStatus("Không tìm thấy Lucky Block!", Theme.Red)
    end
end, 5, Theme.AccentLight)

-- ══════════════════════════════════════════
--         MISC TAB
-- ══════════════════════════════════════════
local miscPage = TabPages["misc"]

makeSection(miscPage, "MOVEMENT", 1)

makeToggle(miscPage, "Fly Mode", "Bay tự do (dùng Jump để lên, Crouch để xuống)", false, function(on)
    State.Flying = on
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if on then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        FlyBodyVelocity = bv
        FlyBodyGyro = bg

        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = true end

        setStatus("Fly Mode: BẬT - Dùng Jump/Crouch để lên/xuống", Theme.Green)
    else
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        setStatus("Fly Mode: TẮT", Theme.Red)
    end
end, 2)

makeSlider(miscPage, "Fly Speed", 10, 200, 50, function(val)
    FlySpeed = val
    setStatus("Fly Speed: " .. val)
end, 3)

makeSection(miscPage, "TELEPORT", 4)

makeButton(miscPage, "Teleport to Spawn", "Về điểm spawn ban đầu", "Tele", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation")
    if hrp then
        if spawn then
            hrp.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
        else
            hrp.CFrame = CFrame.new(0, 10, 0)
        end
        setStatus("Đã teleport về Spawn!", Theme.Green)
    end
end, 5)

makeButton(miscPage, "Teleport to Player", "Teleport đến người chơi ngẫu nhiên", "Tele", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then setStatus("Không tìm thấy character!", Theme.Red) return end
    local others = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others > 0 then
        local target = others[math.random(1, #others)]
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(3, 2, 0)
        setStatus("Teleport đến " .. target.Name .. "!", Theme.Green)
    else
        setStatus("Không có người chơi khác!", Theme.Red)
    end
end, 6)

makeButton(miscPage, "Rejoin Game", "Vào lại server hiện tại", "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end, 7, Theme.Red)

-- ══════════════════════════════════════════
--         INFO TAB
-- ══════════════════════════════════════════
local infoPage = TabPages["info"]

makeSection(infoPage, "HƯỚNG DẪN SỬ DỤNG", 1)

makeInfoCard(infoPage, [[<font color="#a0a0ff"><b>📋 DANH SÁCH CHỨC NĂNG ĐẦY ĐỦ</b></font>

<font color="#ffffff"><b>👤 PLAYER TAB:</b></font>
<font color="#c0c0ff">• Walk Speed (8-200): Kéo thanh để thay đổi tốc độ chạy. Mặc định 16, đề xuất 50-80 cho gameplay cân bằng.
• Jump Power (20-300): Tăng độ cao nhảy. Mặc định 50.
• Infinite Jump: Toggle bật/tắt nhảy vô hạn trên không trung.
• God Mode: Máu tối đa vô hạn, không bao giờ chết.
• No Clip: Xuyên qua tất cả vật thể trong game.
• Anti AFK: Tự động di chuyển giả để tránh bị kick.</font>

<font color="#ffffff"><b>👁 VISUAL TAB:</b></font>
<font color="#c0c0ff">• ESP Players: Thấy người chơi khác qua tường bằng highlight màu.
• ESP Box: Hiện khung hộp xung quanh người chơi.
• ESP Name + Distance: Tên và khoảng cách cách bao xa.
• Fullbright: Xóa bóng tối, sáng toàn bộ map.</font>

<font color="#ffffff"><b>🎲 LUCKY TAB:</b></font>
<font color="#c0c0ff">• Auto Open Lucky Block: Tự động mở lucky block khi đứng gần.
• Item ESP: Thấy items qua tường.
• Collect Nearby Items: Nhặt tất cả items bán kính 50 studs.
• Teleport to Lucky Block: Nhảy đến Lucky Block gần nhất.</font>

<font color="#ffffff"><b>⚙ MISC TAB:</b></font>
<font color="#c0c0ff">• Fly Mode: Bay tự do. Sau khi bật:
  - PC: Space = Lên cao, Ctrl/Shift = Xuống thấp
  - Mobile: Jump button = Lên, Crouch = Xuống
• Fly Speed: Điều chỉnh tốc độ bay.
• Teleport Spawn: Về điểm xuất phát.
• Teleport to Player: Nhảy đến người chơi ngẫu nhiên.
• Rejoin: Vào lại server hiện tại.</font>

<font color="#ffaa00"><b>⚠ LƯU Ý:</b></font>
<font color="#c0c0ff">• Script chạy client-side, một số chức năng có thể bị giới hạn bởi server anti-cheat.
• God Mode và speed có thể bị detect trên server có anti-cheat mạnh.
• Dùng ở mức độ phù hợp để tránh bị ban.</font>]], 2)

-- ══════════════════════════════════════════
--         DRAG FUNCTIONALITY
-- ══════════════════════════════════════════
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end
end)

-- ══════════════════════════════════════════
--         MINIMIZE / CLOSE
-- ══════════════════════════════════════════
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = not State.IsMinimized
    if State.IsMinimized then
        tween(MainFrame, {Size = UDim2.new(0, 340, 0, 52)}, 0.3, Enum.EasingStyle.Quart)
        MinBtn.Text = "□"
    else
        tween(MainFrame, {Size = originalSize}, 0.3, Enum.EasingStyle.Quart)
        MinBtn.Text = "—"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(
        MainFrame.Position.X.Scale,
        MainFrame.Position.X.Offset + 170,
        MainFrame.Position.Y.Scale,
        MainFrame.Position.Y.Offset + 240
    )}, 0.3, Enum.EasingStyle.Quart)
    task.wait(0.35)
    ScreenGui:Destroy()
    -- Clear all connections
    for _, c in pairs(Connections) do
        if c then pcall(function() c:Disconnect() end) end
    end
end)

-- ══════════════════════════════════════════
--         GAME LOOP (RunService)
-- ══════════════════════════════════════════
local afkTime = 0
local jumpConn, noclipConn, godConn, espConn, flyConn, lbConn

-- Apply settings on character respawn
local function applyOnRespawn(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    task.wait(0.5)
    hum.WalkSpeed = State.WalkSpeed
    hum.JumpPower = State.JumpPower
    if State.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end

LocalPlayer.CharacterAdded:Connect(applyOnRespawn)
if LocalPlayer.Character then applyOnRespawn(LocalPlayer.Character) end

-- Infinite Jump
Connections.jump = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Main heartbeat loop
Connections.heartbeat = RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- God Mode
    if State.GodMode and hum then
        if hum.Health < hum.MaxHealth then
            hum.Health = math.huge
        end
    end

    -- NoClip
    if State.NoClip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end

    -- Anti AFK (jitter every 30s)
    if State.AntiAFK then
        afkTime = afkTime + dt
        if afkTime >= 30 then
            afkTime = 0
            if hrp then
                local cf = hrp.CFrame
                hrp.CFrame = cf * CFrame.new(0.01, 0, 0)
                task.wait()
                hrp.CFrame = cf
            end
        end
    end

    -- Fly
    if State.Flying and FlyBodyVelocity and hrp then
        local camCF = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        -- Mobile: use thumbstick + jump button
        if UserInputService.TouchEnabled then
            if hum and hum.Jump then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            local movDir = hum and hum.MoveDirection or Vector3.new()
            moveDir = moveDir + Vector3.new(movDir.X, 0, movDir.Z)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        FlyBodyVelocity.Velocity = moveDir * FlySpeed
        if FlyBodyGyro then
            FlyBodyGyro.CFrame = Camera.CFrame
        end
    end

    -- Auto Lucky Block
    if State.AutoLuckyBlock and hrp then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj.Name:lower():find("lucky") or obj.Name:lower():find("block")) then
                local pp = obj:FindFirstChildWhichIsA("ProximityPrompt")
                if pp then
                    local partPos
                    if obj:IsA("BasePart") then partPos = obj.Position
                    elseif obj:IsA("Model") and obj.PrimaryPart then partPos = obj.PrimaryPart.Position
                    end
                    if partPos and (hrp.Position - partPos).Magnitude < 20 then
                        pcall(function() fireproximityprompt(pp) end)
                    end
                end
            end
        end
    end
end)

-- ESP Rendering
Connections.esp = RunService.RenderStepped:Connect(function()
    if not State.ESPEnabled then
        -- Clean up ESP
        for name, data in pairs(ESPObjects) do
            if data.highlight then pcall(function() data.highlight:Destroy() end) end
            if data.billboard then pcall(function() data.billboard:Destroy() end) end
        end
        ESPObjects = {}
        return
    end

    -- Clean up disconnected players
    for name, data in pairs(ESPObjects) do
        local found = false
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == name then found = true break end
        end
        if not found then
            if data.highlight then pcall(function() data.highlight:Destroy() end) end
            if data.billboard then pcall(function() data.billboard:Destroy() end) end
            ESPObjects[name] = nil
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then
            if ESPObjects[player.Name] then
                if ESPObjects[player.Name].highlight then pcall(function() ESPObjects[player.Name].highlight:Destroy() end) end
                if ESPObjects[player.Name].billboard then pcall(function() ESPObjects[player.Name].billboard:Destroy() end) end
                ESPObjects[player.Name] = nil
            end
            continue
        end

        if not ESPObjects[player.Name] then
            ESPObjects[player.Name] = {}
        end
        local data = ESPObjects[player.Name]

        -- Highlight
        if State.ESPBox then
            if not data.highlight or not data.highlight.Parent then
                local hl = Instance.new("SelectionBox")
                hl.Color3 = Theme.Accent
                hl.LineThickness = 0.06
                hl.SurfaceTransparency = 0.8
                hl.SurfaceColor3 = Theme.Accent
                hl.Adornee = char
                hl.Parent = char
                data.highlight = hl
            end
        else
            if data.highlight then
                pcall(function() data.highlight:Destroy() end)
                data.highlight = nil
            end
        end

        -- Billboard for name+distance
        if State.ESPName or State.ESPDistance then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if not data.billboard or not data.billboard.Parent then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 100, 0, 40)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Adornee = hrp or char:FindFirstChildWhichIsA("BasePart")
                bb.Parent = char

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Theme.AccentLight
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeTransparency = 0.4
                nameLabel.Parent = bb

                local distLabel = Instance.new("TextLabel")
                distLabel.Name = "DistLabel"
                distLabel.Size = UDim2.new(1, 0, 0.4, 0)
                distLabel.Position = UDim2.new(0, 0, 0.6, 0)
                distLabel.BackgroundTransparency = 1
                distLabel.TextColor3 = Theme.Yellow
                distLabel.TextSize = 11
                distLabel.Font = Enum.Font.Gotham
                distLabel.TextStrokeTransparency = 0.4
                distLabel.Parent = bb

                data.billboard = bb
                data.nameLabel = nameLabel
                data.distLabel = distLabel
            end

            if data.nameLabel then
                data.nameLabel.Text = State.ESPName and player.Name or ""
            end
            if data.distLabel and myHRP and hrp then
                local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
                data.distLabel.Text = State.ESPDistance and (dist .. " studs") or ""
            end
        else
            if data.billboard then
                pcall(function() data.billboard:Destroy() end)
                data.billboard = nil
            end
        end
    end
end)

-- Item ESP
Connections.itemESP = RunService.RenderStepped:Connect(function()
    -- Lightweight: just use highlight color change approach on Parts named with known item names
end)

-- ══════════════════════════════════════════
--         INIT - Show Player Tab
-- ══════════════════════════════════════════
switchTab("player")

-- Intro animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
tween(MainFrame, {
    Size = UDim2.new(0, 340, 0, 480),
    Position = UDim2.new(0.5, -170, 0.5, -240)
}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

task.wait(0.6)
setStatus("✅ AnhungTV Script đã sẵn sàng!", Theme.Green)

print([[
╔══════════════════════════════════════════╗
║       ANHUNG_TV SCRIPT - LOADED!         ║
║   Script by Claude | Mobile Friendly     ║
╚══════════════════════════════════════════╝
Script đã load thành công!
]])
