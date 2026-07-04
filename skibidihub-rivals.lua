-- ============================================================
-- [PHẦN 1/3] KHỞI TẠO + REDZ UI + NÚT SKIBIDI (CÓ KÉO THẢ)
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

-- ==================== CÀI ĐẶT ====================
local Settings = {
    AIM = {
        Enabled = false,
        FOV = 200,
        Smoothness = 0.3,
        AimPart = "Head",
        TeamCheck = false,
        VisibleCheck = false
    },
    ESP = {
        Enabled = false,
        Box = false,
        Line = false,
        Name = false,
        Distance = false,
        Health = false,
        MaxDistance = 500,
        TeamColor = true
    },
    PLAYER = {
        Speed = 16,
        JumpPower = 50,
        Fly = false,
        FlySpeed = 50,
        NoClip = false,
        InfJump = false
    }
}

-- ==================== BIẾN TOÀN CỤC ====================
local ESPObjects = {}
local FlyConnection = nil
local NoClipConnection = nil
local InfJumpConnection = nil
local CurrentTarget = nil
local FOVCircle = nil

-- ==================== NÚT SKIBIDI TOILET (CÓ KÉO THẢ) ====================
local function CreateSkibidiButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkibidiButton"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false
    
    -- Main button
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 15, 0, 100)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(100, 150, 255)
    btn.Image = "rbxassetid://1000174591"
    btn.ScaleType = Enum.ScaleType.Fit
    btn.Parent = gui
    btn.ZIndex = 10
    
    -- Glow
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1000174591"
    glow.ImageColor3 = Color3.fromRGB(100, 150, 255)
    glow.ImageTransparency = 0.5
    glow.ZIndex = 0
    glow.Parent = btn
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 14)
    label.Position = UDim2.new(0, 0, 1, 2)
    label.BackgroundTransparency = 1
    label.Text = "SKIBIDI"
    label.TextColor3 = Color3.fromRGB(100, 150, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.Parent = btn
    
    -- Xoay glow
    spawn(function()
        local angle = 0
        while btn and btn.Parent do
            angle = angle + 0.5
            glow.Rotation = angle
            task.wait(0.05)
        end
    end)
    
    -- ==================== KÉO THẢ NÚT ====================
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            
            -- Giới hạn không cho ra ngoài màn hình
            local viewport = game:GetService("Camera").ViewportSize
            newX = math.clamp(newX, 0, viewport.X - 60)
            newY = math.clamp(newY, 0, viewport.Y - 60)
            
            btn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    -- ==================== CLICK MỞ UI ====================
    btn.MouseButton1Click:Connect(function()
        -- Không mở nếu đang kéo
        if dragging then return end
        
        isUIOpen = not isUIOpen
        if isUIOpen then
            -- Mở REDZ UI
            local redzUI = game.CoreGui:FindFirstChild("REDZ_UI")
            if redzUI then redzUI.Enabled = true end
            TweenService:Create(btn, TweenInfo.new(0.3), {Rotation = 0, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            local redzUI = game.CoreGui:FindFirstChild("REDZ_UI")
            if redzUI then redzUI.Enabled = false end
            TweenService:Create(btn, TweenInfo.new(0.3), {Rotation = 360, ImageColor3 = Color3.fromRGB(100, 150, 255)}):Play()
        end
    end)
    
    return btn
end

spawn(function()
    wait(0.5)
    CreateSkibidiButton()
end)

-- ==================== TẠO UI REDZ ====================
local REDZ = loadstring(game:HttpGet("https://pastebin.com/raw/8PqTZx7L"))()

local Window = REDZ:CreateWindow({
    Name = "Skibidi Hub | RIVALS",
    Size = UDim2.new(0, 500, 0, 400),
    Position = UDim2.new(0.5, -250, 0.5, -200),
    Theme = "Dark",
    Minimizable = true
})

-- ==================== TAB AIM ====================
local AimTab = Window:CreateTab({
    Name = "AIM",
    Icon = "🎯"
})

-- AIM Toggle
AimTab:CreateToggle({
    Name = "Enable AIM",
    Default = false,
    Callback = function(value)
        Settings.AIM.Enabled = value
        if not value then
            CurrentTarget = nil
            if FOVCircle then
                FOVCircle:Remove()
                FOVCircle = nil
            end
        end
    end
})

-- FOV Slider
AimTab:CreateSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 500,
    Default = 200,
    Callback = function(value)
        Settings.AIM.FOV = value
    end
})

-- Smoothness Slider
AimTab:CreateSlider({
    Name = "Smoothness",
    Min = 0.1,
    Max = 1,
    Decimal = true,
    Default = 0.3,
    Callback = function(value)
        Settings.AIM.Smoothness = value
    end
})

-- Aim Part Dropdown
AimTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Body", "Legs"},
    Default = "Head",
    Callback = function(option)
        Settings.AIM.AimPart = option
    end
})

-- Team Check Toggle
AimTab:CreateToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(value)
        Settings.AIM.TeamCheck = value
    end
})

-- Visible Check Toggle
AimTab:CreateToggle({
    Name = "Visible Check",
    Default = false,
    Callback = function(value)
        Settings.AIM.VisibleCheck = value
    end
})

-- ==================== TAB ESP ====================
local ESPTab = Window:CreateTab({
    Name = "ESP",
    Icon = "👁️"
})

-- ESP Toggle
ESPTab:CreateToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(value)
        Settings.ESP.Enabled = value
        if not value then
            ClearESP()
        end
    end
})

-- ESP Options
ESPTab:CreateToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(value)
        Settings.ESP.Box = value
    end
})

ESPTab:CreateToggle({
    Name = "Line ESP",
    Default = false,
    Callback = function(value)
        Settings.ESP.Line = value
    end
})

ESPTab:CreateToggle({
    Name = "Name ESP",
    Default = false,
    Callback = function(value)
        Settings.ESP.Name = value
    end
})

ESPTab:CreateToggle({
    Name = "Distance ESP",
    Default = false,
    Callback = function(value)
        Settings.ESP.Distance = value
    end
})

ESPTab:CreateToggle({
    Name = "Health ESP",
    Default = false,
    Callback = function(value)
        Settings.ESP.Health = value
    end
})

ESPTab:CreateToggle({
    Name = "Team Color",
    Default = true,
    Callback = function(value)
        Settings.ESP.TeamColor = value
    end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Min = 50,
    Max = 1000,
    Default = 500,
    Callback = function(value)
        Settings.ESP.MaxDistance = value
    end
})

-- ==================== TAB PLAYER ====================
local PlayerTab = Window:CreateTab({
    Name = "PLAYER",
    Icon = "👤"
})

-- Speed Slider
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(value)
        Settings.PLAYER.Speed = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

-- Jump Slider
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 40,
    Max = 200,
    Default = 50,
    Callback = function(value)
        Settings.PLAYER.JumpPower = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

-- Fly Toggle
PlayerTab:CreateToggle({
    Name = "Fly",
    Default = false,
    Callback = function(value)
        Settings.PLAYER.Fly = value
        if value then
            EnableFly()
        else
            DisableFly()
        end
    end
})

-- Fly Speed Slider
PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 300,
    Default = 50,
    Callback = function(value)
        Settings.PLAYER.FlySpeed = value
    end
})

-- NoClip Toggle
PlayerTab:CreateToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(value)
        Settings.PLAYER.NoClip = value
        if value then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end
})

-- InfJump Toggle
PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    Default = false,
    Callback = function(value)
        Settings.PLAYER.InfJump = value
        if value then
            EnableInfJump()
        else
            DisableInfJump()
        end
    end
})
-- ============================================================
-- [PHẦN 2/3] CÁC HÀM AIM + ESP (CÓ THANH MÁU BÊN CẠNH BOX)
-- ============================================================

-- ==================== HÀM AIM ====================
local function IsPlayerVisible(player)
    if not player or not player.Character then return false end
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = Workspace:Raycast(Camera.CFrame.Position, rootPart.Position - Camera.CFrame.Position, raycastParams)
    return ray == nil
end

local function GetClosestPlayer()
    local closest = nil
    local closestDist = Settings.AIM.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        -- Team check
        if Settings.AIM.TeamCheck then
            if player.Team == LocalPlayer.Team then continue end
        end
        
        -- Visible check
        if Settings.AIM.VisibleCheck then
            if not IsPlayerVisible(player) then continue end
        end
        
        local aimPart = nil
        local partName = Settings.AIM.AimPart
        if partName == "Head" then
            aimPart = player.Character:FindFirstChild("Head")
        elseif partName == "Body" then
            aimPart = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
        elseif partName == "Legs" then
            aimPart = player.Character:FindFirstChild("LeftLeg") or player.Character:FindFirstChild("RightLeg")
        end
        
        if not aimPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    
    return closest
end

-- ==================== FOV CIRCLE ====================
local function UpdateFOVCircle()
    if not Settings.AIM.Enabled then
        if FOVCircle then
            FOVCircle:Remove()
            FOVCircle = nil
        end
        return
    end
    
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Transparency = 0.7
    end
    
    local viewport = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
    FOVCircle.Radius = Settings.AIM.FOV
    FOVCircle.Visible = true
end

-- ==================== AIM LOOP ====================
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    
    if not Settings.AIM.Enabled then return end
    
    local target = GetClosestPlayer()
    CurrentTarget = target
    
    if target and target.Character then
        local aimPart = nil
        local partName = Settings.AIM.AimPart
        if partName == "Head" then
            aimPart = target.Character:FindFirstChild("Head")
        elseif partName == "Body" then
            aimPart = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("HumanoidRootPart")
        elseif partName == "Legs" then
            aimPart = target.Character:FindFirstChild("LeftLeg") or target.Character:FindFirstChild("RightLeg")
        end
        
        if aimPart then
            local targetPos = aimPart.Position
            local currentPos = Camera.CFrame.Position
            local lookAt = CFrame.lookAt(currentPos, targetPos)
            
            -- Smooth aim
            local smooth = Settings.AIM.Smoothness
            local newCFrame = Camera.CFrame:Lerp(lookAt, smooth)
            Camera.CFrame = newCFrame
        end
    end
end)

-- ==================== HÀM ESP (CÓ THANH MÁU BÊN CẠNH BOX) ====================
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj:IsA("Drawing") then
            obj:Remove()
        end
    end
    ESPObjects = {}
end

local function GetPlayerColor(player)
    if Settings.ESP.TeamColor and player.Team then
        return player.TeamColor or Color3.fromRGB(255, 255, 255)
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESP()
    ClearESP()
    if not Settings.ESP.Enabled then return end
    
    local viewport = Camera.ViewportSize
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        if not rootPart or not head then continue end
        
        -- Distance check
        local distance = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        if distance > Settings.ESP.MaxDistance then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then continue end
        
        local color = GetPlayerColor(player)
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        
        -- Lấy vị trí head và foot để tính box
        local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local footPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        local boxHeight = math.abs(headPos.Y - footPos.Y)
        local boxWidth = boxHeight * 0.5
        
        -- ==================== BOX ESP ====================
        if Settings.ESP.Box then
            local box = Drawing.new("Square")
            box.Size = Vector2.new(boxWidth, boxHeight)
            box.Position = Vector2.new(headPos.X - boxWidth/2, headPos.Y)
            box.Color = color
            box.Thickness = 2
            box.Filled = false
            box.Transparency = 0.5
            box.Visible = true
            table.insert(ESPObjects, box)
            
            -- ==================== THANH MÁU BÊN CẠNH BOX ====================
            if Settings.ESP.Health then
                local barWidth = 4
                local barHeight = boxHeight
                local barX = headPos.X + boxWidth/2 + 3
                local barY = headPos.Y
                
                -- Nền thanh máu (màu đen)
                local bgBar = Drawing.new("Square")
                bgBar.Size = Vector2.new(barWidth, barHeight)
                bgBar.Position = Vector2.new(barX, barY)
                bgBar.Color = Color3.fromRGB(20, 20, 20)
                bgBar.Filled = true
                bgBar.Visible = true
                table.insert(ESPObjects, bgBar)
                
                -- Thanh máu (màu xanh lá)
                local healthBar = Drawing.new("Square")
                local healthBarHeight = barHeight * healthPercent
                healthBar.Size = Vector2.new(barWidth, healthBarHeight)
                healthBar.Position = Vector2.new(barX, barY + barHeight - healthBarHeight)
                -- Màu theo % máu
                if healthPercent > 0.5 then
                    healthBar.Color = Color3.fromRGB(0, 255, 50)  -- Xanh lá
                elseif healthPercent > 0.25 then
                    healthBar.Color = Color3.fromRGB(255, 200, 0) -- Vàng
                else
                    healthBar.Color = Color3.fromRGB(255, 0, 0)   -- Đỏ
                end
                healthBar.Filled = true
                healthBar.Visible = true
                table.insert(ESPObjects, healthBar)
                
                -- Viền thanh máu
                local borderBar = Drawing.new("Square")
                borderBar.Size = Vector2.new(barWidth, barHeight)
                borderBar.Position = Vector2.new(barX, barY)
                borderBar.Color = Color3.fromRGB(255, 255, 255)
                borderBar.Thickness = 1
                borderBar.Filled = false
                borderBar.Transparency = 0.5
                borderBar.Visible = true
                table.insert(ESPObjects, borderBar)
            end
        end
        
        -- ==================== LINE ESP ====================
        if Settings.ESP.Line then
            local line = Drawing.new("Line")
            line.From = Vector2.new(viewport.X / 2, viewport.Y)
            line.To = Vector2.new(screenPos.X, screenPos.Y)
            line.Color = color
            line.Thickness = 1
            line.Transparency = 0.5
            line.Visible = true
            table.insert(ESPObjects, line)
        end
        
        -- ==================== NAME ESP ====================
        if Settings.ESP.Name then
            local nameText = Drawing.new("Text")
            nameText.Text = player.Name
            nameText.Position = Vector2.new(headPos.X, headPos.Y - 25)
            nameText.Color = color
            nameText.Size = 14
            nameText.Center = true
            nameText.Outline = true
            nameText.Visible = true
            table.insert(ESPObjects, nameText)
        end
        
        -- ==================== DISTANCE ESP ====================
        if Settings.ESP.Distance then
            local distText = Drawing.new("Text")
            distText.Text = math.floor(distance) .. "m"
            distText.Position = Vector2.new(headPos.X, headPos.Y - 10)
            distText.Color = Color3.fromRGB(200, 200, 200)
            distText.Size = 12
            distText.Center = true
            distText.Outline = true
            distText.Visible = true
            table.insert(ESPObjects, distText)
        end
        
        -- ==================== HEALTH TEXT (tùy chọn) ====================
        if Settings.ESP.Health and not Settings.ESP.Box then
            -- Nếu không bật box, hiển thị text máu
            local healthText = Drawing.new("Text")
            healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            healthText.Position = Vector2.new(headPos.X, headPos.Y + boxHeight + 10)
            healthText.Color = Color3.fromRGB(0, 255, 50)
            healthText.Size = 12
            healthText.Center = true
            healthText.Outline = true
            healthText.Visible = true
            table.insert(ESPObjects, healthText)
        end
    end
end

-- ESP Loop
spawn(function()
    while true do
        task.wait(0.1)
        if Settings.ESP.Enabled then
            pcall(CreateESP)
        end
    end
end)
-- ============================================================
-- [PHẦN 3/3] CÁC HÀM PLAYER + HOÀN THIỆN
-- ============================================================

-- ==================== HÀM FLY ====================
local function EnableFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    humanoid.PlatformStand = true
    
    if FlyConnection then FlyConnection:Disconnect() end
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.PLAYER.Fly then return end
        if not char or not char.Parent then
            DisableFly()
            return
        end
        
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir + Vector3.new(0, -1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            root.Velocity = moveDir.Unit * Settings.PLAYER.FlySpeed
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function DisableFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- ==================== HÀM NOCLIP ====================
local function EnableNoClip()
    if NoClipConnection then NoClipConnection:Disconnect() end
    
    NoClipConnection = RunService.Stepped:Connect(function()
        if not Settings.PLAYER.NoClip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ==================== HÀM INFINITY JUMP ====================
local function EnableInfJump()
    if InfJumpConnection then InfJumpConnection:Disconnect() end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    InfJumpConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        if Settings.PLAYER.InfJump and newState == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function DisableInfJump()
    if InfJumpConnection then
        InfJumpConnection:Disconnect()
        InfJumpConnection = nil
    end
end

-- ==================== THEO DÕI RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Settings.PLAYER.Speed
        humanoid.JumpPower = Settings.PLAYER.JumpPower
    end
    
    if Settings.PLAYER.Fly then EnableFly() end
    if Settings.PLAYER.NoClip then EnableNoClip() end
    if Settings.PLAYER.InfJump then EnableInfJump() end
end)

-- ==================== TAB SETTINGS ====================
local SettingsTab = Window:CreateTab({
    Name = "SETTINGS",
    Icon = "⚙️"
})

SettingsTab:CreateButton({
    Name = "Reload UI",
    Callback = function()
        Window:Destroy()
        wait(0.5)
        loadstring(game:HttpGet("https://pastebin.com/raw/8PqTZx7L"))()
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Window:Destroy()
        local btnGui = game.CoreGui:FindFirstChild("SkibidiButton")
        if btnGui then btnGui:Destroy() end
        ClearESP()
        DisableFly()
        DisableNoClip()
        DisableInfJump()
        if FOVCircle then
            FOVCircle:Remove()
            FOVCircle = nil
        end
    end
})

-- ==================== TAB COMMUNITY ====================
local CommunityTab = Window:CreateTab({
    Name = "COMMUNITY",
    Icon = "🌐"
})

local socials = {
    {Name = "Discord", Icon = "💬", Link = "https://discord.gg/"},
    {Name = "TikTok", Icon = "🎵", Link = "https://tiktok.com/"},
    {Name = "YouTube", Icon = "▶️", Link = "https://youtube.com/"},
    {Name = "Twitter/X", Icon = "🐦", Link = "https://x.com/"},
    {Name = "Instagram", Icon = "📷", Link = "https://instagram.com/"},
    {Name = "Telegram", Icon = "✈️", Link = "https://t.me/"}
}

for _, social in pairs(socials) do
    CommunityTab:CreateButton({
        Name = social.Icon .. " " .. social.Name,
        Callback = function()
            setclipboard(social.Link)
        end
    })
end

CommunityTab:CreateDivider()

CommunityTab:CreateLabel({
    Text = "Script by vietdz"
})

CommunityTab:CreateLabel({
    Text = "Game: RIVALS"
})

CommunityTab:CreateLabel({
    Text = "Version: 1.0"
})
