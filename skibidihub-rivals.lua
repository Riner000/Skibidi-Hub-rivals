-- ============================================================
-- [PHẦN 1/5] KHỞI TẠO + FLUENT ICONS + NÚT SKIBIDI
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local Stats = game:GetService("Stats")

local StartTime = tick()
local isUIOpen = true

-- ==================== FLUENT ICONS ====================
local Icons = {
    Home = "󰋗",
    Target = "󰎧",
    Eye = "󰌶",
    People = "󰋼",
    Settings = "󰒓",
    Globe = "󰧮",
    Close = "󰅙",
    Minimize = "󰆏",
    Maximize = "󰆐",
    Premium = "󰐩",
    Refresh = "󰑙",
    User = "󰀀",
    Clock = "󰅐",
    Signal = "󰍟",
    Speed = "󰅂",
    Heart = "󱂊",
    Shield = "󰅡",
    Star = "󰐩",
    Link = "󰌒",
    Discord = "󰙯",
    YouTube = "󰗃",
    Twitter = "󱆚",
    Instagram = "󰙧",
    Telegram = "󰯐",
    Check = "󰄬",
    X = "󰅖",
    Menu = "󰝰",
    Play = "󰐨",
    Stop = "󰅱",
    Lock = "󰌾",
    Unlock = "󰌿",
    Info = "󰋼",
}

-- ==================== CÀI ĐẶT ====================
local Settings = {
    AIM = {Enabled = false, FOV = 100, AimMode = "Fire", AimPart = "Head"},
    ESP = {Enabled = false, MaxDistance = 500, ShowLine = false, ShowBox = false, ShowPlayer = false},
    Player = {Speed = 16, JumpPower = 50, FlySpeed = 50, NoClip = false, Fly = false, InfJump = false}
}

-- ==================== NÚT SKIBIDI TOILET ====================
local SkibidiButton = nil
local buttonDragging = false
local dragStart = nil
local startPos = nil

local function CreateSkibidiButton()
    if SkibidiButton and SkibidiButton.Parent then return SkibidiButton end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SkibidiButtonUI"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false

    local button = Instance.new("ImageButton")
    button.Name = "SkibidiButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(0, 15, 0, 100)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(100, 150, 255)
    button.Image = "rbxassetid://1000174591"
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.ScaleType = Enum.ScaleType.Fit
    button.Parent = gui

    -- Glow
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1000174591"
    glow.ImageColor3 = Color3.fromRGB(100, 150, 255)
    glow.ImageTransparency = 0.6
    glow.ZIndex = 0
    glow.Parent = button

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 14)
    label.Position = UDim2.new(0, 0, 1, 2)
    label.BackgroundTransparency = 1
    label.Text = "SKIBIDI"
    label.TextColor3 = Color3.fromRGB(100, 150, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.TextStrokeTransparency = 0.3
    label.Parent = button

    -- Animation glow xoay
    spawn(function()
        local angle = 0
        while button and button.Parent do
            angle = angle + 0.5
            if glow then glow.Rotation = angle end
            task.wait(0.05)
        end
    end)

    -- Hover
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 70, 0, 70),
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.2,
            Size = UDim2.new(1.6, 0, 1.6, 0),
            Position = UDim2.new(-0.3, 0, -0.3, 0)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 60, 0, 60),
            BackgroundTransparency = 0.2
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.2), {
            ImageTransparency = 0.6,
            Size = UDim2.new(1.4, 0, 1.4, 0),
            Position = UDim2.new(-0.2, 0, -0.2, 0)
        }):Play()
    end)

    -- Click toggle UI
    button.MouseButton1Click:Connect(function()
        isUIOpen = not isUIOpen
        local mainUI = game.CoreGui:FindFirstChild("SkibidiHub")
        if mainUI then mainUI.Enabled = isUIOpen end
        if isUIOpen then
            TweenService:Create(button, TweenInfo.new(0.3), {
                Rotation = 0,
                ImageColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.3), {
                Rotation = 360,
                ImageColor3 = Color3.fromRGB(100, 150, 255)
            }):Play()
        end
    end)

    -- Drag
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            buttonDragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end

    local function updateDrag(input)
        if buttonDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end

    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            buttonDragging = false
        end
    end

    button.InputBegan:Connect(startDrag)
    UserInputService.InputChanged:Connect(updateDrag)
    UserInputService.InputEnded:Connect(endDrag)

    SkibidiButton = button
    return button
end

spawn(function()
    wait(0.5)
    CreateSkibidiButton()
end)
-- ============================================================
-- [PHẦN 2/5] TẠO UI CHÍNH + HEADER + SIDEBAR
-- ============================================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkibidiHub"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = true

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 820, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -410, 0.5, -280)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    MainFrame.BackgroundTransparency = 0
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 22, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
    })
    Gradient.Parent = MainFrame

    -- Blur Effect
    local Blur = Instance.new("Frame")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Blur.BackgroundTransparency = 0.3
    Blur.BorderSizePixel = 0
    Blur.Parent = MainFrame

    -- Border Glow
    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(1, 2, 1, 2)
    Border.Position = UDim2.new(0, -1, 0, -1)
    Border.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    Border.BackgroundTransparency = 0.2
    Border.BorderSizePixel = 0
    Border.Parent = MainFrame

    -- ==================== HEADER ====================
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 65)
    Header.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    -- Logo
    local Logo = Instance.new("ImageLabel")
    Logo.Size = UDim2.new(0, 40, 0, 40)
    Logo.Position = UDim2.new(0, 15, 0.5, -20)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://1000174591"
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = Header

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 180, 0, 30)
    Title.Position = UDim2.new(0, 65, 0.5, -15)
    Title.BackgroundTransparency = 1
    Title.Text = "Skibidi Hub"
    Title.TextColor3 = Color3.fromRGB(100, 150, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Premium Badge
    local Premium = Instance.new("TextLabel")
    Premium.Size = UDim2.new(0, 90, 0, 18)
    Premium.Position = UDim2.new(0, 65, 0.5, 12)
    Premium.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    Premium.BackgroundTransparency = 0.15
    Premium.BorderSizePixel = 1
    Premium.BorderColor3 = Color3.fromRGB(100, 150, 255)
    Premium.Text = Icons.Star .. " PREMIUM"
    Premium.TextColor3 = Color3.fromRGB(100, 150, 255)
    Premium.TextSize = 10
    Premium.Font = Enum.Font.GothamBold
    Premium.TextXAlignment = Enum.TextXAlignment.Left
    Premium.Parent = Header

    -- Window Controls
    local WinControls = Instance.new("Frame")
    WinControls.Size = UDim2.new(0, 90, 1, 0)
    WinControls.Position = UDim2.new(1, -95, 0, 0)
    WinControls.BackgroundTransparency = 1
    WinControls.Parent = Header

    local controls = {
        {Icon = Icons.Minimize, Color = Color3.fromRGB(255, 200, 0)},
        {Icon = Icons.Maximize, Color = Color3.fromRGB(0, 200, 255)},
        {Icon = Icons.Close, Color = Color3.fromRGB(255, 50, 50)}
    }

    for i, ctrl in pairs(controls) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.Position = UDim2.new((i-1) * 0.33, 2, 0.5, -14)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        btn.Text = ctrl.Icon
        btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = WinControls

        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = ctrl.Color
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.5
            btn.TextColor3 = Color3.fromRGB(200, 200, 220)
        end)

        if i == 3 then
            btn.MouseButton1Click:Connect(function()
                ScreenGui.Enabled = false
                isUIOpen = false
            end)
        end
    end

    -- ==================== SIDEBAR ====================
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -65)
    Sidebar.Position = UDim2.new(0, 0, 0, 65)
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
    Sidebar.BackgroundTransparency = 0.4
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SideGradient = Instance.new("UIGradient")
    SideGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 15, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 20))
    })
    SideGradient.Parent = Sidebar

    -- Sidebar Title
    local SideTitle = Instance.new("TextLabel")
    SideTitle.Size = UDim2.new(1, 0, 0, 35)
    SideTitle.Position = UDim2.new(0, 10, 0, 5)
    SideTitle.BackgroundTransparency = 1
    SideTitle.Text = Icons.Menu .. " MENU"
    SideTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
    SideTitle.TextSize = 14
    SideTitle.Font = Enum.Font.GothamBold
    SideTitle.TextXAlignment = Enum.TextXAlignment.Left
    SideTitle.Parent = Sidebar

    -- Tab Buttons
    local Tabs = {
        {Icon = Icons.Home, Name = "Home", Tab = "Home"},
        {Icon = Icons.Target, Name = "Aim", Tab = "Aim"},
        {Icon = Icons.Eye, Name = "ESP", Tab = "ESP"},
        {Icon = Icons.People, Name = "Player", Tab = "Player"},
        {Icon = Icons.Settings, Name = "Settings", Tab = "Settings"},
        {Icon = Icons.Globe, Name = "Community", Tab = "Community"},
    }

    local TabButtons = {}
    local CurrentTab = "Home"
    local TabContents = {}

    for i, tab in pairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 42)
        btn.Position = UDim2.new(0, 10, 0, 45 + (i-1) * 48)
        btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        btn.BackgroundTransparency = 0.85
        btn.BorderSizePixel = 0
        btn.Text = tab.Icon .. "  " .. tab.Name
        btn.TextColor3 = Color3.fromRGB(180, 180, 210)
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.Parent = Sidebar

        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.6
            btn.TextColor3 = Color3.fromRGB(100, 150, 255)
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= tab.Tab then
                btn.BackgroundTransparency = 0.85
                btn.TextColor3 = Color3.fromRGB(180, 180, 210)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            CurrentTab = tab.Tab
            for _, tb in pairs(TabButtons) do
                tb.BackgroundTransparency = 0.85
                tb.TextColor3 = Color3.fromRGB(180, 180, 210)
            end
            btn.BackgroundTransparency = 0.5
            btn.TextColor3 = Color3.fromRGB(100, 150, 255)

            for name, content in pairs(TabContents) do
                content.Visible = (name == tab.Tab)
            end
        end)

        TabButtons[tab.Tab] = btn
    end

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -160, 1, -65)
    ContentArea.Position = UDim2.new(0, 160, 0, 65)
    ContentArea.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
    ContentArea.BackgroundTransparency = 0.2
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainFrame

    return ScreenGui, MainFrame, ContentArea, TabContents, Tabs
end

local ScreenGui, MainFrame, ContentArea, TabContents, Tabs = CreateUI()
-- ============================================================
-- [PHẦN 3/5] TAB HOME
-- ============================================================
local HomeContent = Instance.new("Frame")
HomeContent.Size = UDim2.new(1, -40, 1, -40)
HomeContent.Position = UDim2.new(0, 20, 0, 20)
HomeContent.BackgroundTransparency = 1
HomeContent.Visible = true
HomeContent.Parent = ContentArea
TabContents["Home"] = HomeContent

-- Welcome
local Welcome = Instance.new("TextLabel")
Welcome.Size = UDim2.new(1, 0, 0, 45)
Welcome.BackgroundTransparency = 1
Welcome.Text = Icons.Home .. "  Welcome to Skibidi Hub"
Welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
Welcome.TextSize = 26
Welcome.Font = Enum.Font.GothamBlack
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.Parent = HomeContent

local SubWelcome = Instance.new("TextLabel")
SubWelcome.Size = UDim2.new(1, 0, 0, 25)
SubWelcome.Position = UDim2.new(0, 0, 0, 42)
SubWelcome.BackgroundTransparency = 1
SubWelcome.Text = "The ultimate hub for RIVALS players"
SubWelcome.TextColor3 = Color3.fromRGB(160, 160, 190)
SubWelcome.TextSize = 14
SubWelcome.Font = Enum.Font.Gotham
SubWelcome.TextXAlignment = Enum.TextXAlignment.Left
SubWelcome.Parent = HomeContent

-- Stats
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, 0, 0, 100)
StatsFrame.Position = UDim2.new(0, 0, 0, 75)
StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
StatsFrame.BackgroundTransparency = 0.4
StatsFrame.BorderSizePixel = 1
StatsFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
StatsFrame.Parent = HomeContent

local StatsTitle = Instance.new("TextLabel")
StatsTitle.Size = UDim2.new(1, 0, 0, 25)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Text = Icons.Speed .. "  System Overview"
StatsTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
StatsTitle.TextSize = 14
StatsTitle.Font = Enum.Font.GothamBold
StatsTitle.Parent = StatsFrame

local StatsGrid = Instance.new("Frame")
StatsGrid.Size = UDim2.new(1, 0, 1, -25)
StatsGrid.Position = UDim2.new(0, 0, 0, 25)
StatsGrid.BackgroundTransparency = 1
StatsGrid.Parent = StatsFrame

local function CreateStat(icon, label, value, x, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 170, 0, 30)
    frame.Position = UDim2.new(x, 0, y, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = StatsGrid
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = icon .. " " .. label
    lbl.TextColor3 = Color3.fromRGB(140, 140, 170)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.5, 0, 1, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = frame
    
    return val
end

local PlayerCount = CreateStat(Icons.People, "Players:", "0", 0, 0)
local FPSStat = CreateStat(Icons.Speed, "FPS:", "0", 0.35, 0)
local PingStat = CreateStat(Icons.Signal, "Ping:", "0ms", 0, 0.5)
local PlaytimeStat = CreateStat(Icons.Clock, "Playtime:", "00:00:00", 0.35, 0.5)

-- Update stats
spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local count = 0
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                    count = count + 1
                end
            end
            PlayerCount.Text = tostring(count)
            
            local ping = Stats.PerformanceStats.Ping:GetValue()
            PingStat.Text = math.floor(ping) .. "ms"
            
            local fps = math.floor(1 / task.wait())
            FPSStat.Text = tostring(fps)
            
            local elapsed = tick() - StartTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = math.floor(elapsed % 60)
            PlaytimeStat.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end)
    end
end)

-- Quick Access
local QuickFrame = Instance.new("Frame")
QuickFrame.Size = UDim2.new(1, 0, 0, 60)
QuickFrame.Position = UDim2.new(0, 0, 0, 185)
QuickFrame.BackgroundTransparency = 1
QuickFrame.Parent = HomeContent

local QuickTitle = Instance.new("TextLabel")
QuickTitle.Size = UDim2.new(1, 0, 0, 20)
QuickTitle.BackgroundTransparency = 1
QuickTitle.Text = Icons.Arrow .. "  Quick Access"
QuickTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
QuickTitle.TextSize = 14
QuickTitle.Font = Enum.Font.GothamBold
QuickTitle.Parent = QuickFrame

local QuickButtons = {
    {Icon = Icons.Target, Name = "Aim", Tab = "Aim"},
    {Icon = Icons.Eye, Name = "ESP", Tab = "ESP"},
    {Icon = Icons.People, Name = "Player", Tab = "Player"},
    {Icon = Icons.Settings, Name = "Settings", Tab = "Settings"},
}

for i, btn in pairs(QuickButtons) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 0, 30)
    b.Position = UDim2.new((i-1) * 0.25, 5, 0, 25)
    b.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    b.BackgroundTransparency = 0.7
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(100, 150, 255)
    b.Text = btn.Icon .. " " .. btn.Name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = QuickFrame
    
    b.MouseEnter:Connect(function()
        b.BackgroundTransparency = 0.4
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundTransparency = 0.7
    end)
    
    b.MouseButton1Click:Connect(function()
        -- Chuyển tab
        for name, content in pairs(TabContents) do
            content.Visible = (name == btn.Tab)
        end
        for _, tb in pairs(TabButtons) do
            tb.BackgroundTransparency = 0.85
            tb.TextColor3 = Color3.fromRGB(180, 180, 210)
        end
    end)
end
-- ============================================================
-- [PHẦN 4/5] TAB AIM + ESP
-- ============================================================
-- ==================== TAB AIM ====================
local AimContent = Instance.new("Frame")
AimContent.Size = UDim2.new(1, -40, 1, -40)
AimContent.Position = UDim2.new(0, 20, 0, 20)
AimContent.BackgroundTransparency = 1
AimContent.Visible = false
AimContent.Parent = ContentArea
TabContents["Aim"] = AimContent

local AimTitle = Instance.new("TextLabel")
AimTitle.Size = UDim2.new(1, 0, 0, 40)
AimTitle.BackgroundTransparency = 1
AimTitle.Text = Icons.Target .. "  AIM Settings"
AimTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
AimTitle.TextSize = 24
AimTitle.Font = Enum.Font.GothamBlack
AimTitle.TextXAlignment = Enum.TextXAlignment.Left
AimTitle.Parent = AimContent

local function CreateToggle(parent, label, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(40, 38, 60)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 150, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -70, 0.5, -15)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    toggle.BorderSizePixel = 0
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            toggle.Text = "ON"
        else
            toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            toggle.Text = "OFF"
        end
        callback(state)
    end)
    
    return frame
end

-- AIM Toggle
CreateToggle(AimContent, "AIM Enabled", 50, function(val)
    Settings.AIM.Enabled = val
end)

-- FOV Slider
local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(0, 300, 0, 40)
FOVFrame.Position = UDim2.new(0, 0, 0, 100)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Parent = AimContent

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0, 100, 1, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: 100"
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
FOVLabel.TextSize = 14
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = FOVFrame

local FOVSlider = Instance.new("Frame")
FOVSlider.Size = UDim2.new(0, 180, 0, 6)
FOVSlider.Position = UDim2.new(0, 100, 0.5, -3)
FOVSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
FOVSlider.BorderSizePixel = 0
FOVSlider.Parent = FOVFrame

local FOVFill = Instance.new("Frame")
FOVFill.Size = UDim2.new(0.3, 0, 1, 0)
FOVFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
FOVFill.BorderSizePixel = 0
FOVFill.Parent = FOVSlider

local FOVValue = 100
local function UpdateFOV(mouseX)
    local relX = math.clamp(mouseX - FOVSlider.AbsolutePosition.X, 0, FOVSlider.AbsoluteSize.X)
    local percent = relX / FOVSlider.AbsoluteSize.X
    FOVValue = math.floor(percent * 360)
    FOVFill.Size = UDim2.new(percent, 0, 1, 0)
    FOVLabel.Text = "FOV: " .. FOVValue
    Settings.AIM.FOV = FOVValue
end

FOVSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateFOV(input.Position.X)
    end
end)

-- Aim Mode
local function CreateDropdown(parent, label, yPos, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(40, 38, 60)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 100, 0, 30)
    dropdown.Position = UDim2.new(1, -110, 0.5, -15)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
    dropdown.BorderSizePixel = 1
    dropdown.BorderColor3 = Color3.fromRGB(100, 150, 255)
    dropdown.Text = options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextSize = 12
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = frame
    
    local index = 1
    dropdown.MouseButton1Click:Connect(function()
        index = index % #options + 1
        dropdown.Text = options[index]
        callback(options[index])
    end)
    
    return frame
end

CreateDropdown(AimContent, "AIM Mode", 150, {"Fire", "Lock"}, function(val)
    Settings.AIM.AimMode = val
end)

CreateDropdown(AimContent, "AIM Part", 200, {"Head", "Body", "Legs", "Random"}, function(val)
    Settings.AIM.AimPart = val
end)

-- ==================== TAB ESP ====================
local ESPContent = Instance.new("Frame")
ESPContent.Size = UDim2.new(1, -40, 1, -40)
ESPContent.Position = UDim2.new(0, 20, 0, 20)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false
ESPContent.Parent = ContentArea
TabContents["ESP"] = ESPContent

local ESPTitle = Instance.new("TextLabel")
ESPTitle.Size = UDim2.new(1, 0, 0, 40)
ESPTitle.BackgroundTransparency = 1
ESPTitle.Text = Icons.Eye .. "  ESP Settings"
ESPTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
ESPTitle.TextSize = 24
ESPTitle.Font = Enum.Font.GothamBlack
ESPTitle.TextXAlignment = Enum.TextXAlignment.Left
ESPTitle.Parent = ESPContent

-- ESP Toggle
CreateToggle(ESPContent, "ESP Enabled", 50, function(val)
    Settings.ESP.Enabled = val
end)

-- ESP Options
local espOptions = {"Show Line", "Show Box", "Show Player"}
local espSettings = {"ShowLine", "ShowBox", "ShowPlayer"}

for i, opt in pairs(espOptions) do
    CreateToggle(ESPContent, opt, 100 + (i-1) * 50, function(val)
        Settings.ESP[espSettings[i]] = val
    end)
end

-- Distance Slider
local DistFrame = Instance.new("Frame")
DistFrame.Size = UDim2.new(0, 300, 0, 40)
DistFrame.Position = UDim2.new(0, 0, 0, 260)
DistFrame.BackgroundTransparency = 1
DistFrame.Parent = ESPContent

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 120, 1, 0)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Distance: 500m"
DistLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
DistLabel.TextSize = 14
DistLabel.Font = Enum.Font.Gotham
DistLabel.TextXAlignment = Enum.TextXAlignment.Left
DistLabel.Parent = DistFrame

local DistSlider = Instance.new("Frame")
DistSlider.Size = UDim2.new(0, 160, 0, 6)
DistSlider.Position = UDim2.new(0, 120, 0.5, -3)
DistSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
DistSlider.BorderSizePixel = 0
DistSlider.Parent = DistFrame

local DistFill = Instance.new("Frame")
DistFill.Size = UDim2.new(1, 0, 1, 0)
DistFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
DistFill.BorderSizePixel = 0
DistFill.Parent = DistSlider

local DistValue = 500
local function UpdateDist(mouseX)
    local relX = math.clamp(mouseX - DistSlider.AbsolutePosition.X, 0, DistSlider.AbsoluteSize.X)
    local percent = relX / DistSlider.AbsoluteSize.X
    DistValue = math.floor(percent * 500)
    DistFill.Size = UDim2.new(percent, 0, 1, 0)
    DistLabel.Text = "Distance: " .. DistValue .. "m"
    Settings.ESP.MaxDistance = DistValue
end

DistSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UpdateDist(input.Position.X)
    end
end)
-- ============================================================
-- [PHẦN 1/2] TAB PLAYER + SETTINGS (TIẾP)
-- ============================================================

SettingsTitle.Font = Enum.Font.GothamBlack
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Parent = SettingsContent

-- Performance Section
local PerfTitle = Instance.new("TextLabel")
PerfTitle.Size = UDim2.new(1, 0, 0, 25)
PerfTitle.Position = UDim2.new(0, 0, 0, 50)
PerfTitle.BackgroundTransparency = 1
PerfTitle.Text = Icons.Speed .. "  Performance"
PerfTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
PerfTitle.TextSize = 16
PerfTitle.Font = Enum.Font.GothamBold
PerfTitle.TextXAlignment = Enum.TextXAlignment.Left
PerfTitle.Parent = SettingsContent

-- FPS Toggle
local FPSFrame = Instance.new("Frame")
FPSFrame.Size = UDim2.new(0, 250, 0, 40)
FPSFrame.Position = UDim2.new(0, 0, 0, 80)
FPSFrame.BackgroundColor3 = Color3.fromRGB(40, 38, 60)
FPSFrame.BorderSizePixel = 0
FPSFrame.Parent = SettingsContent

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 150, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "Show FPS"
FPSLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = FPSFrame

local FPSToggle = Instance.new("TextButton")
FPSToggle.Size = UDim2.new(0, 60, 0, 30)
FPSToggle.Position = UDim2.new(1, -70, 0.5, -15)
FPSToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FPSToggle.BorderSizePixel = 0
FPSToggle.Text = "OFF"
FPSToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSToggle.TextSize = 12
FPSToggle.Font = Enum.Font.GothamBold
FPSToggle.Parent = FPSFrame

local fpsEnabled = false
FPSToggle.MouseButton1Click:Connect(function()
    fpsEnabled = not fpsEnabled
    if fpsEnabled then
        FPSToggle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        FPSToggle.Text = "ON"
    else
        FPSToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        FPSToggle.Text = "OFF"
    end
end)

-- Ping Toggle
local PingFrame = Instance.new("Frame")
PingFrame.Size = UDim2.new(0, 250, 0, 40)
PingFrame.Position = UDim2.new(0, 0, 0, 130)
PingFrame.BackgroundColor3 = Color3.fromRGB(40, 38, 60)
PingFrame.BorderSizePixel = 0
PingFrame.Parent = SettingsContent

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 150, 1, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "Show Ping"
PingLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
PingLabel.TextSize = 14
PingLabel.Font = Enum.Font.Gotham
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.Parent = PingFrame

local PingToggle = Instance.new("TextButton")
PingToggle.Size = UDim2.new(0, 60, 0, 30)
PingToggle.Position = UDim2.new(1, -70, 0.5, -15)
PingToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
PingToggle.BorderSizePixel = 0
PingToggle.Text = "OFF"
PingToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PingToggle.TextSize = 12
PingToggle.Font = Enum.Font.GothamBold
PingToggle.Parent = PingFrame

local pingEnabled = false
PingToggle.MouseButton1Click:Connect(function()
    pingEnabled = not pingEnabled
    if pingEnabled then
        PingToggle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        PingToggle.Text = "ON"
    else
        PingToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        PingToggle.Text = "OFF"
    end
end)

-- FPS/Ping Display
local function CreateFPSPingUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FPSPingDisplay"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 100, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(100, 150, 255)
    frame.Parent = gui
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0, 25)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.TextSize = 14
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Parent = frame
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(1, 0, 0, 25)
    pingLabel.Position = UDim2.new(0, 0, 0, 25)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0ms"
    pingLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    pingLabel.TextSize = 14
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.Parent = frame
    
    spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                if fpsEnabled then
                    local fps = math.floor(1 / task.wait())
                    fpsLabel.Text = "FPS: " .. fps
                    if fps >= 60 then fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif fps >= 30 then fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    else fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0) end
                    fpsLabel.Visible = true
                else
                    fpsLabel.Visible = false
                end
                
                if pingEnabled then
                    local ping = Stats.PerformanceStats.Ping:GetValue()
                    pingLabel.Text = "Ping: " .. math.floor(ping) .. "ms"
                    if ping <= 50 then pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif ping <= 100 then pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    else pingLabel.TextColor3 = Color3.fromRGB(255, 0, 0) end
                    pingLabel.Visible = true
                else
                    pingLabel.Visible = false
                end
            end)
        end
    end)
end

CreateFPSPingUI()

-- Reload Button
local ReloadBtn = Instance.new("TextButton")
ReloadBtn.Size = UDim2.new(0, 200, 0, 40)
ReloadBtn.Position = UDim2.new(0, 0, 0, 190)
ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
ReloadBtn.BackgroundTransparency = 0.3
ReloadBtn.BorderSizePixel = 1
ReloadBtn.BorderColor3 = Color3.fromRGB(100, 150, 255)
ReloadBtn.Text = Icons.Refresh .. "  Reload UI"
ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ReloadBtn.TextSize = 14
ReloadBtn.Font = Enum.Font.GothamBold
ReloadBtn.Parent = SettingsContent

ReloadBtn.MouseEnter:Connect(function()
    ReloadBtn.BackgroundTransparency = 0.1
end)
ReloadBtn.MouseLeave:Connect(function()
    ReloadBtn.BackgroundTransparency = 0.3
end)

ReloadBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    wait(0.5)
    ScreenGui.Enabled = true
end)

-- Destroy Button
local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(0, 200, 0, 40)
DestroyBtn.Position = UDim2.new(0, 0, 0, 240)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
DestroyBtn.BackgroundTransparency = 0.3
DestroyBtn.BorderSizePixel = 1
DestroyBtn.BorderColor3 = Color3.fromRGB(255, 50, 50)
DestroyBtn.Text = Icons.Close .. "  Destroy UI"
DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyBtn.TextSize = 14
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.Parent = SettingsContent

DestroyBtn.MouseEnter:Connect(function()
    DestroyBtn.BackgroundTransparency = 0.1
end)
DestroyBtn.MouseLeave:Connect(function()
    DestroyBtn.BackgroundTransparency = 0.3
end)

DestroyBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    local fpsGui = game.CoreGui:FindFirstChild("FPSPingDisplay")
    if fpsGui then fpsGui:Destroy() end
    local skibidiGui = game.CoreGui:FindFirstChild("SkibidiButtonUI")
    if skibidiGui then skibidiGui:Destroy() end
    isUIOpen = false
end)
-- ============================================================
-- [PHẦN 2/2] TAB COMMUNITY + HOÀN THIỆN
-- ============================================================

-- ==================== TAB COMMUNITY ====================
local CommunityContent = Instance.new("Frame")
CommunityContent.Size = UDim2.new(1, -40, 1, -40)
CommunityContent.Position = UDim2.new(0, 20, 0, 20)
CommunityContent.BackgroundTransparency = 1
CommunityContent.Visible = false
CommunityContent.Parent = ContentArea
TabContents["Community"] = CommunityContent

local CommunityTitle = Instance.new("TextLabel")
CommunityTitle.Size = UDim2.new(1, 0, 0, 40)
CommunityTitle.BackgroundTransparency = 1
CommunityTitle.Text = Icons.Globe .. "  Community"
CommunityTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
CommunityTitle.TextSize = 24
CommunityTitle.Font = Enum.Font.GothamBlack
CommunityTitle.TextXAlignment = Enum.TextXAlignment.Left
CommunityTitle.Parent = CommunityContent

-- Social Buttons
local socials = {
    {Icon = Icons.Discord, Name = "Discord", Color = Color3.fromRGB(88, 101, 242), Link = "https://discord.gg/"},
    {Icon = "󰗃", Name = "YouTube", Color = Color3.fromRGB(255, 0, 0), Link = "https://youtube.com/"},
    {Icon = "󱆚", Name = "X (Twitter)", Color = Color3.fromRGB(0, 0, 0), Link = "https://x.com/"},
    {Icon = "󰙧", Name = "Instagram", Color = Color3.fromRGB(225, 48, 108), Link = "https://instagram.com/"},
    {Icon = "󰯐", Name = "Telegram", Color = Color3.fromRGB(0, 136, 204), Link = "https://t.me/"},
}

for i, social in pairs(socials) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.Position = UDim2.new((i-1) % 2 * 0.5, 5, math.floor((i-1)/2) * 0.14, 60)
    btn.BackgroundColor3 = social.Color
    btn.BackgroundTransparency = 0.7
    btn.BorderSizePixel = 1
    btn.BorderColor3 = social.Color
    btn.Text = social.Icon .. "  " .. social.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = CommunityContent
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundTransparency = 0.3
        btn.Size = UDim2.new(0, 185, 0, 48)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundTransparency = 0.7
        btn.Size = UDim2.new(0, 180, 0, 45)
    end)
    
    btn.MouseButton1Click:Connect(function()
        setclipboard(social.Link)
        -- Thông báo đã copy
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 200, 0, 30)
        notif.Position = UDim2.new(0.5, -100, 0.5, -15)
        notif.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        notif.BackgroundTransparency = 0.2
        notif.BorderSizePixel = 1
        notif.BorderColor3 = Color3.fromRGB(100, 150, 255)
        notif.Text = "✅ Copied: " .. social.Name
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        notif.TextSize = 14
        notif.Font = Enum.Font.Gotham
        notif.Parent = CommunityContent
        game:GetService("Debris"):AddItem(notif, 2)
    end)
end

-- Script Info
local InfoFrame2 = Instance.new("Frame")
InfoFrame2.Size = UDim2.new(1, 0, 0, 80)
InfoFrame2.Position = UDim2.new(0, 0, 0, 400)
InfoFrame2.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
InfoFrame2.BackgroundTransparency = 0.4
InfoFrame2.BorderSizePixel = 1
InfoFrame2.BorderColor3 = Color3.fromRGB(100, 150, 255)
InfoFrame2.Parent = CommunityContent

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 1, 0)
InfoText.BackgroundTransparency = 1
InfoText.Text = Icons.Info .. "  Script by vietdz\nRivals - Version 1.0"
InfoText.TextColor3 = Color3.fromRGB(160, 160, 190)
InfoText.TextSize = 14
InfoText.Font = Enum.Font.Gotham
InfoText.TextXAlignment = Enum.TextXAlignment.Center
InfoText.TextYAlignment = Enum.TextYAlignment.Center
InfoText.Parent = InfoFrame2

-- ==================== HOÀN THIỆN ====================
-- Set tab Home mặc định được chọn
local function SetDefaultTab()
    for name, content in pairs(TabContents) do
        content.Visible = (name == "Home")
    end
    for tabName, btn in pairs(TabButtons) do
        if tabName == "Home" then
            btn.BackgroundTransparency = 0.5
            btn.TextColor3 = Color3.fromRGB(100, 150, 255)
        else
            btn.BackgroundTransparency = 0.85
            btn.TextColor3 = Color3.fromRGB(180, 180, 210)
        end
    end
end

SetDefaultTab()

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function()
    -- Reset speed khi respawn
    task.wait(0.5)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Settings.Player.Speed
        char.Humanoid.JumpPower = Settings.Player.JumpPower
    end
end)
