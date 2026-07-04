-- ============================================================
-- [PHẦN 1/3] KHỞI TẠO + RAYFIELD + NÚT SKIBIDI
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

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
local FPSBoostEnabled = false

-- ==================== NÚT SKIBIDI TOILET ====================
local function CreateSkibidiButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkibidiButton"
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false
    
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
    
    -- Kéo thả
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
            local viewport = Camera.ViewportSize
            newX = math.clamp(newX, 0, viewport.X - 60)
            newY = math.clamp(newY, 0, viewport.Y - 60)
            btn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    -- Click mở Rayfield
    btn.MouseButton1Click:Connect(function()
        if dragging then return end
        isUIOpen = not isUIOpen
        if isUIOpen then
            -- Mở Rayfield
            if Rayfield and Rayfield.Window then
                Rayfield.Window.Visible = true
            end
            TweenService:Create(btn, TweenInfo.new(0.3), {Rotation = 0, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            if Rayfield and Rayfield.Window then
                Rayfield.Window.Visible = false
            end
            TweenService:Create(btn, TweenInfo.new(0.3), {Rotation = 360, ImageColor3 = Color3.fromRGB(100, 150, 255)}):Play()
        end
    end)
    
    return btn
end

spawn(function()
    wait(0.5)
    CreateSkibidiButton()
end)

-- ==================== TẠO RAYFIELD UI ====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Skibidi Hub | RIVALS",
    LoadingTitle = "Skibidi Hub",
    LoadingSubtitle = "by vietdz",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- ==================== TAB AIM ====================
local AimTab = Window:CreateTab("AIM", nil)

AimTab:CreateToggle({
    Name = "Enable AIM",
    CurrentValue = false,
    Flag = "AIM_Toggle",
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

AimTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "AIM_FOV",
    Callback = function(value)
        Settings.AIM.FOV = value
    end
})

AimTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 1,
    Suffix = "",
    CurrentValue = 3,
    Flag = "AIM_Smooth",
    Callback = function(value)
        Settings.AIM.Smoothness = value / 10
    end
})

AimTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Body", "Legs"},
    CurrentOption = "Head",
    Flag = "AIM_Part",
    Callback = function(option)
        Settings.AIM.AimPart = option
    end
})

AimTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "AIM_Team",
    Callback = function(value)
        Settings.AIM.TeamCheck = value
    end
})

AimTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Flag = "AIM_Visible",
    Callback = function(value)
        Settings.AIM.VisibleCheck = value
    end
})

-- ==================== TAB ESP ====================
local ESPTab = Window:CreateTab("ESP", nil)

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP_Toggle",
    Callback = function(value)
        Settings.ESP.Enabled = value
        if not value then
            ClearESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "ESP_Box",
    Callback = function(value)
        Settings.ESP.Box = value
    end
})

ESPTab:CreateToggle({
    Name = "Line ESP",
    CurrentValue = false,
    Flag = "ESP_Line",
    Callback = function(value)
        Settings.ESP.Line = value
    end
})

ESPTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "ESP_Name",
    Callback = function(value)
        Settings.ESP.Name = value
    end
})

ESPTab:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Flag = "ESP_Distance",
    Callback = function(value)
        Settings.ESP.Distance = value
    end
})

ESPTab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = false,
    Flag = "ESP_Health",
    Callback = function(value)
        Settings.ESP.Health = value
    end
})

ESPTab:CreateToggle({
    Name = "Team Color",
    CurrentValue = true,
    Flag = "ESP_TeamColor",
    Callback = function(value)
        Settings.ESP.TeamColor = value
    end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {50, 1000},
    Increment = 50,
    Suffix = "m",
    CurrentValue = 500,
    Flag = "ESP_Distance",
    Callback = function(value)
        Settings.ESP.MaxDistance = value
    end
})

-- ==================== TAB PLAYER ====================
local PlayerTab = Window:CreateTab("PLAYER", nil)

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "Player_Speed",
    Callback = function(value)
        Settings.PLAYER.Speed = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {40, 200},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "Player_Jump",
    Callback = function(value)
        Settings.PLAYER.JumpPower = value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Player_Fly",
    Callback = function(value)
        Settings.PLAYER.Fly = value
        if value then
            EnableFly()
        else
            DisableFly()
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 10,
    Suffix = "",
    CurrentValue = 50,
    Flag = "Player_FlySpeed",
    Callback = function(value)
        Settings.PLAYER.FlySpeed = value
    end
})

PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "Player_NoClip",
    Callback = function(value)
        Settings.PLAYER.NoClip = value
        if value then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Flag = "Player_InfJump",
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
-- [PHẦN 2/3] CÁC HÀM AIM + ESP
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

-- ==================== HÀM ESP ====================
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
                
                -- Nền thanh máu
                local bgBar = Drawing.new("Square")
                bgBar.Size = Vector2.new(barWidth, barHeight)
                bgBar.Position = Vector2.new(barX, barY)
                bgBar.Color = Color3.fromRGB(20, 20, 20)
                bgBar.Filled = true
                bgBar.Visible = true
                table.insert(ESPObjects, bgBar)
                
                -- Thanh máu
                local healthBar = Drawing.new("Square")
                local healthBarHeight = barHeight * healthPercent
                healthBar.Size = Vector2.new(barWidth, healthBarHeight)
                healthBar.Position = Vector2.new(barX, barY + barHeight - healthBarHeight)
                if healthPercent > 0.5 then
                    healthBar.Color = Color3.fromRGB(0, 255, 50)
                elseif healthPercent > 0.25 then
                    healthBar.Color = Color3.fromRGB(255, 200, 0)
                else
                    healthBar.Color = Color3.fromRGB(255, 0, 0)
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
-- [PHẦN 3/3] CÁC HÀM PLAYER + FPS BOOST + TAB SETTINGS + COMMUNITY
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

-- ==================== FPS BOOST ====================
local function ToggleFPSBoost(enabled)
    FPSBoostEnabled = enabled
    if enabled then
        -- Tắt hiệu ứng ánh sáng
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        
        -- Tắt bloom và các hiệu ứng
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or 
               effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = false
            end
        end
        
        -- Giảm chất lượng vật thể
        Workspace.DistributedGameTime = 0.1
        Workspace.FallenPartsDestroyHeight = -500
        
        -- Tắt particle và decals
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("BasePart") and v.Material == Enum.Material.Neon then
                v.Material = Enum.Material.Plastic
            end
        end
        
        -- Tối ưu camera
        Camera.FieldOfView = 70
        
        print("⚡ FPS Boost đã bật!")
    else
        -- Khôi phục
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or 
               effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = true
            end
        end
        
        Workspace.DistributedGameTime = 0.5
        
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") then
                v.Enabled = true
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 0
            end
        end
        
        Camera.FieldOfView = 70
        
        print("⚡ FPS Boost đã tắt!")
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
local SettingsTab = Window:CreateTab("SETTINGS", nil)

-- FPS Boost Toggle
SettingsTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPS_Boost",
    Callback = function(value)
        ToggleFPSBoost(value)
    end
})

-- FPS Boost Info
SettingsTab:CreateLabel("FPS Boost sẽ:")
SettingsTab:CreateLabel("- Tắt bóng đổ")
SettingsTab:CreateLabel("- Tắt hiệu ứng ánh sáng")
SettingsTab:CreateLabel("- Tắt Particle/Decal")
SettingsTab:CreateLabel("- Giảm chất lượng đồ họa")
SettingsTab:CreateLabel("=> Tăng FPS tối đa")

SettingsTab:CreateDivider()

-- Reload Button
SettingsTab:CreateButton({
    Name = "Reload UI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
            ClearESP()
            DisableFly()
            DisableNoClip()
            DisableInfJump()
            if FOVCircle then
                FOVCircle:Remove()
                FOVCircle = nil
            end
        end)
        wait(0.5)
        loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end
})

-- Destroy Button
SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
            ClearESP()
            DisableFly()
            DisableNoClip()
            DisableInfJump()
            if FOVCircle then
                FOVCircle:Remove()
                FOVCircle = nil
            end
            local btnGui = game.CoreGui:FindFirstChild("SkibidiButton")
            if btnGui then btnGui:Destroy() end
        end)
        ToggleFPSBoost(false)
    end
})

-- ==================== TAB COMMUNITY ====================
local CommunityTab = Window:CreateTab("COMMUNITY", nil)

CommunityTab:CreateButton({
    Name = "💬 Discord",
    Callback = function()
        setclipboard("https://discord.gg/")
    end
})

CommunityTab:CreateButton({
    Name = "🎵 TikTok",
    Callback = function()
        setclipboard("https://tiktok.com/")
    end
})

CommunityTab:CreateButton({
    Name = "▶️ YouTube",
    Callback = function()
        setclipboard("https://youtube.com/")
    end
})

CommunityTab:CreateButton({
    Name = "🐦 Twitter/X",
    Callback = function()
        setclipboard("https://x.com/")
    end
})

CommunityTab:CreateButton({
    Name = "📷 Instagram",
    Callback = function()
        setclipboard("https://instagram.com/")
    end
})

CommunityTab:CreateButton({
    Name = "✈️ Telegram",
    Callback = function()
        setclipboard("https://t.me/")
    end
})

CommunityTab:CreateDivider()

CommunityTab:CreateLabel("Script by vietdz")
CommunityTab:CreateLabel("Game: RIVALS")
CommunityTab:CreateLabel("Version: 1.0")
