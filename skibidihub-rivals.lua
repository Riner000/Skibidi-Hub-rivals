-- ============================================================
-- SKIBIDI HUB RIVALS v2.0 (FIXED)
-- Tác giả: vietdz
-- PHẦN 1/5: SERVICES + VARIABLES + SETTINGS + UTILITY
-- ============================================================

-- ============================================================
-- SECTION 1: SERVICES
-- ============================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local Stats = game:GetService("Stats")

-- ============================================================
-- SECTION 2: VARIABLES
-- ============================================================
local StartTime = tick()
local IsUIOpen = true
local CurrentTarget = nil
local FPSBoostEnabled = false
local IsJumping = false

-- Connections
local FlyConnection = nil
local NoClipConnection = nil
local InfJumpConnection = nil
local Connections = {}
local RenderConnection = nil

-- Drawing Objects
local FOVCircle = nil
local ESPObjects = {}
local ESPData = {}

-- ============================================================
-- SECTION 3: SETTINGS
-- ============================================================
local Settings = {
    AIM = {
        Enabled = false,
        FOV = 200,
        Smoothness = 0.3,
        AimPart = "Head",
        TeamCheck = false,
        VisibleCheck = false,
        RandomOffset = false
    },
    ESP = {
        Enabled = false,
        Box = false,
        Line = false,
        Name = false,
        Distance = false,
        Health = false,
        TeamColor = true,
        MaxDistance = 500,
        Glow = false
    },
    PLAYER = {
        Speed = 16,
        JumpPower = 50,
        Fly = false,
        FlySpeed = 50,
        NoClip = false,
        InfJump = false
    },
    MISC = {
        FPSBoost = false
    }
}

-- ============================================================
-- SECTION 4: UTILITY FUNCTIONS
-- ============================================================
local function AddConnection(connection)
    table.insert(Connections, connection)
    return connection
end

local function ClearConnections()
    for _, conn in pairs(Connections) do
        if conn and conn.Disconnect then
            pcall(conn.Disconnect, conn)
        end
    end
    Connections = {}
end

local function GetAlivePlayers()
    local alive = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(alive, player)
            end
        end
    end
    return alive
end

local function GetPart(player, partName)
    if not player or not player.Character then return nil end
    if partName == "Head" then
        return player.Character:FindFirstChild("Head")
    elseif partName == "Body" then
        return player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
    elseif partName == "Legs" then
        return player.Character:FindFirstChild("LeftLeg") or player.Character:FindFirstChild("RightLeg") or player.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function ApplyPlayerSettings()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = Settings.PLAYER.Speed
    humanoid.JumpPower = Settings.PLAYER.JumpPower
end

-- Random offset cho AIM
local function GetRandomOffset()
    return Vector3.new(
        (math.random() - 0.5) * 0.5,
        (math.random() - 0.5) * 0.3,
        (math.random() - 0.5) * 0.5
    )
end

-- ============================================================
-- SECTION 5: FPS BOOST
-- ============================================================
local FPSBoostState = {
    GlobalShadows = true,
    Brightness = 2,
    Ambient = Color3.fromRGB(127, 127, 127),
    OutdoorAmbient = Color3.fromRGB(127, 127, 127),
    Effects = {}
}

local function SaveFPSBoostState()
    FPSBoostState.GlobalShadows = Lighting.GlobalShadows
    FPSBoostState.Brightness = Lighting.Brightness
    FPSBoostState.Ambient = Lighting.Ambient
    FPSBoostState.OutdoorAmbient = Lighting.OutdoorAmbient
    FPSBoostState.Effects = {}
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or 
           effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
            FPSBoostState.Effects[effect] = effect.Enabled
        end
    end
end

local function ApplyFPSBoost(enabled)
    if enabled then
        if not FPSBoostEnabled then SaveFPSBoostState() end
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            for effect, _ in pairs(FPSBoostState.Effects) do
                if effect and effect.Enabled ~= nil then effect.Enabled = false end
            end
            Workspace.DistributedGameTime = 0.1
        end)
        FPSBoostEnabled = true
    else
        pcall(function()
            Lighting.GlobalShadows = FPSBoostState.GlobalShadows
            Lighting.Brightness = FPSBoostState.Brightness
            Lighting.Ambient = FPSBoostState.Ambient
            Lighting.OutdoorAmbient = FPSBoostState.OutdoorAmbient
            for effect, state in pairs(FPSBoostState.Effects) do
                if effect and effect.Enabled ~= nil then effect.Enabled = state
            end
            Workspace.DistributedGameTime = 0.5
        end)
        FPSBoostEnabled = false
    end
end

print("✅ PHẦN 1/5 ĐÃ LOAD XONG!")
-- ============================================================
-- SKIBIDI HUB RIVALS v2.0 (FIXED)
-- PHẦN 2/5: AIM + ESP
-- ============================================================

-- ============================================================
-- SECTION 6: AIM FUNCTIONS
-- ============================================================
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
    if not Settings.AIM.Enabled then return nil end
    
    local closest = nil
    local closestDist = Settings.AIM.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(GetAlivePlayers()) do
        if not player.Character then continue end
        
        if Settings.AIM.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if Settings.AIM.VisibleCheck and not IsPlayerVisible(player) then continue end
        
        local aimPart = GetPart(player, Settings.AIM.AimPart)
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
        FOVCircle.Transparency = 0.5
    end
    
    local viewport = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
    FOVCircle.Radius = Settings.AIM.FOV
    FOVCircle.Visible = true
end

-- ============================================================
-- SECTION 7: ESP FUNCTIONS (FIXED)
-- ============================================================
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Remove then pcall(obj.Remove, obj) end
    end
    ESPObjects = {}
    ESPData = {}
end

local function GetPlayerColor(player)
    if Settings.ESP.TeamColor and player.Team then
        return player.TeamColor or Color3.fromRGB(255, 255, 255)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- Tạo Glow cho player
local function CreateGlow(player)
    if not player or not player.Character then return end
    if player.Character:FindFirstChild("Highlight") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Glow"
    highlight.Parent = player.Character
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = true
    return highlight
end

local function RemoveGlow(player)
    if not player or not player.Character then return end
    local highlight = player.Character:FindFirstChild("ESP_Glow")
    if highlight then highlight:Destroy() end
end

local function UpdateESP()
    if not Settings.ESP.Enabled then
        ClearESP()
        for _, player in pairs(Players:GetPlayers()) do
            RemoveGlow(player)
        end
        return
    end
    
    local viewport = Camera.ViewportSize
    local currentPlayers = {}
    
    -- Collect alive players
    for _, player in pairs(GetAlivePlayers()) do
        currentPlayers[player.UserId] = player
    end
    
    -- Remove ESP for dead/left players
    for userId, data in pairs(ESPData) do
        if not currentPlayers[userId] then
            for _, obj in pairs(data) do
                if obj and obj.Remove then pcall(obj.Remove, obj) end
            end
            ESPData[userId] = nil
            local player = Players:FindFirstChild(tostring(userId))
            if player then RemoveGlow(player) end
        end
    end
    
    -- Update ESP for alive players
    for _, player in pairs(GetAlivePlayers()) do
        if not player or not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        
        if not humanoid or not rootPart or not head then continue end
        
        -- Distance check
        local distance = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        if distance > Settings.ESP.MaxDistance then 
            RemoveGlow(player)
            continue 
        end
        
        local color = GetPlayerColor(player)
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        
        -- Glow ESP (xuyên tường)
        if Settings.ESP.Glow then
            local glow = CreateGlow(player)
            if glow then
                glow.FillColor = color
                glow.OutlineColor = color
                glow.Enabled = true
            end
        else
            RemoveGlow(player)
        end
        
        -- Get head and foot positions
        local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local footPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        -- Kiểm tra on screen cho box
        local boxHeight = math.abs(headPos.Y - footPos.Y)
        local boxWidth = boxHeight * 0.5
        
        if not ESPData[player.UserId] then ESPData[player.UserId] = {} end
        local data = ESPData[player.UserId]
        
        -- Box ESP
        if Settings.ESP.Box and boxHeight > 0 then
            if not data.Box then
                data.Box = Drawing.new("Square")
                data.Box.Thickness = 2
                data.Box.Filled = false
                data.Box.Transparency = 0.6
                table.insert(ESPObjects, data.Box)
            end
            data.Box.Size = Vector2.new(boxWidth, boxHeight)
            data.Box.Position = Vector2.new(headPos.X - boxWidth/2, headPos.Y)
            data.Box.Color = color
            data.Box.Visible = true
            
            -- Health bar bên cạnh box
            if Settings.ESP.Health then
                if not data.HealthBar then
                    data.HealthBar = Drawing.new("Square")
                    data.HealthBar.Filled = true
                    data.HealthBarBG = Drawing.new("Square")
                    data.HealthBarBG.Filled = true
                    data.HealthBarBG.Color = Color3.fromRGB(20, 20, 20)
                    data.HealthBorder = Drawing.new("Square")
                    data.HealthBorder.Filled = false
                    data.HealthBorder.Thickness = 1
                    data.HealthBorder.Transparency = 0.5
                    data.HealthBorder.Color = Color3.fromRGB(255, 255, 255)
                    table.insert(ESPObjects, data.HealthBar)
                    table.insert(ESPObjects, data.HealthBarBG)
                    table.insert(ESPObjects, data.HealthBorder)
                end
                
                local barWidth = 4
                local barHeight = boxHeight
                local barX = headPos.X + boxWidth/2 + 3
                local barY = headPos.Y
                local healthBarHeight = barHeight * healthPercent
                
                data.HealthBarBG.Size = Vector2.new(barWidth, barHeight)
                data.HealthBarBG.Position = Vector2.new(barX, barY)
                data.HealthBarBG.Visible = true
                
                data.HealthBar.Size = Vector2.new(barWidth, healthBarHeight)
                data.HealthBar.Position = Vector2.new(barX, barY + barHeight - healthBarHeight)
                if healthPercent > 0.5 then
                    data.HealthBar.Color = Color3.fromRGB(0, 255, 50)
                elseif healthPercent > 0.25 then
                    data.HealthBar.Color = Color3.fromRGB(255, 200, 0)
                else
                    data.HealthBar.Color = Color3.fromRGB(255, 0, 0)
                end
                data.HealthBar.Visible = true
                
                data.HealthBorder.Size = Vector2.new(barWidth, barHeight)
                data.HealthBorder.Position = Vector2.new(barX, barY)
                data.HealthBorder.Visible = true
            end
        else
            if data.Box then data.Box.Visible = false end
            if data.HealthBar then data.HealthBar.Visible = false end
            if data.HealthBarBG then data.HealthBarBG.Visible = false end
            if data.HealthBorder then data.HealthBorder.Visible = false end
        end
        
        -- Line ESP (từ cạnh trên màn hình)
        if Settings.ESP.Line then
            if not data.Line then
                data.Line = Drawing.new("Line")
                data.Line.Thickness = 1
                data.Line.Transparency = 0.5
                table.insert(ESPObjects, data.Line)
            end
            data.Line.From = Vector2.new(screenPos.X, 0)
            data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
            data.Line.Color = color
            data.Line.Visible = true
        else
            if data.Line then data.Line.Visible = false end
        end
        
        -- Name ESP
        if Settings.ESP.Name then
            if not data.Name then
                data.Name = Drawing.new("Text")
                data.Name.Size = 14
                data.Name.Center = true
                data.Name.Outline = true
                table.insert(ESPObjects, data.Name)
            end
            data.Name.Text = player.Name
            data.Name.Position = Vector2.new(headPos.X, headPos.Y - 25)
            data.Name.Color = color
            data.Name.Visible = true
        else
            if data.Name then data.Name.Visible = false end
        end
        
        -- Distance ESP
        if Settings.ESP.Distance then
            if not data.Distance then
                data.Distance = Drawing.new("Text")
                data.Distance.Size = 12
                data.Distance.Center = true
                data.Distance.Outline = true
                data.Distance.Color = Color3.fromRGB(200, 200, 200)
                table.insert(ESPObjects, data.Distance)
            end
            data.Distance.Text = math.floor(distance) .. "m"
            data.Distance.Position = Vector2.new(headPos.X, headPos.Y - 10)
            data.Distance.Visible = true
        else
            if data.Distance then data.Distance.Visible = false end
        end
    end
end

print("✅ PHẦN 2/5 ĐÃ LOAD XONG!")
-- ============================================================
-- SKIBIDI HUB RIVALS v2.0 (FIXED)
-- PHẦN 3/5: PLAYER FUNCTIONS
-- ============================================================

-- ============================================================
-- SECTION 8: FLY
-- ============================================================
local function EnableFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    humanoid.PlatformStand = true
    
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    FlyConnection = AddConnection(RunService.Heartbeat:Connect(function()
        if not Settings.PLAYER.Fly then
            DisableFly()
            return
        end
        
        local char = LocalPlayer.Character
        if not char or not char.Parent then
            DisableFly()
            return
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
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
    end))
end

local function DisableFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end
end

-- ============================================================
-- SECTION 9: NOCLIP
-- ============================================================
local function EnableNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    
    NoClipConnection = AddConnection(RunService.Stepped:Connect(function()
        if not Settings.PLAYER.NoClip then
            DisableNoClip()
            return
        end
        
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end))
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
                pcall(function() part.CanCollide = true end)
            end
        end
    end
end

-- ============================================================
-- SECTION 10: INFINITY JUMP (GIỮ NÚT BAY LÊN)
-- ============================================================
local function EnableInfJump()
    if InfJumpConnection then
        InfJumpConnection:Disconnect()
        InfJumpConnection = nil
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    IsJumping = false
    
    InfJumpConnection = AddConnection(RunService.Heartbeat:Connect(function()
        if not Settings.PLAYER.InfJump then
            DisableInfJump()
            return
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Kiểm tra giữ Space
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            else
                -- Đang ở trên không, tiếp tục bay lên
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
                end
            end
        end
    end))
end

local function DisableInfJump()
    if InfJumpConnection then
        InfJumpConnection:Disconnect()
        InfJumpConnection = nil
    end
    IsJumping = false
end

-- ============================================================
-- SECTION 11: RESPAWN HANDLER
-- ============================================================
local function OnCharacterAdded(char)
    task.wait(0.5)
    ApplyPlayerSettings()
    
    if Settings.PLAYER.Fly then EnableFly() end
    if Settings.PLAYER.NoClip then EnableNoClip() end
    if Settings.PLAYER.InfJump then EnableInfJump() end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

print("✅ PHẦN 3/5 ĐÃ LOAD XONG!")
-- ============================================================
-- SKIBIDI HUB RIVALS v2.0 (FIXED)
-- PHẦN 4/5: UI RAYFIELD
-- ============================================================

-- ============================================================
-- SECTION 12: RAYFIELD UI
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Skibidi Hub | RIVALS",
    LoadingTitle = "Skibidi Hub",
    LoadingSubtitle = "by vietdz",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

-- ============================================================
-- SECTION 12A: AIM TAB (THÊM RANDOM OFFSET)
-- ============================================================
local AimTab = Window:CreateTab("AIM", nil)

AimTab:CreateToggle({
    Name = "Enable AIM",
    CurrentValue = false,
    Flag = "AIM_Enable",
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
    Name = "Random Offset",
    CurrentValue = false,
    Flag = "AIM_Random",
    Callback = function(value)
        Settings.AIM.RandomOffset = value
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

-- ============================================================
-- SECTION 12B: ESP TAB (THÊM GLOW)
-- ============================================================
local ESPTab = Window:CreateTab("ESP", nil)

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP_Enable",
    Callback = function(value)
        Settings.ESP.Enabled = value
        if not value then
            ClearESP()
            for _, player in pairs(Players:GetPlayers()) do
                RemoveGlow(player)
            end
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
    Name = "Line ESP (Từ trên xuống)",
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
    Name = "Glow (Xuyên tường)",
    CurrentValue = false,
    Flag = "ESP_Glow",
    Callback = function(value)
        Settings.ESP.Glow = value
        if not value then
            for _, player in pairs(Players:GetPlayers()) do
                RemoveGlow(player)
            end
        end
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
    Flag = "ESP_MaxDistance",
    Callback = function(value)
        Settings.ESP.MaxDistance = value
    end
})

-- ============================================================
-- SECTION 12C: PLAYER TAB
-- ============================================================
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
        ApplyPlayerSettings()
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
        ApplyPlayerSettings()
    end
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Player_Fly",
    Callback = function(value)
        Settings.PLAYER.Fly = value
        if value then EnableFly() else DisableFly() end
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
        if value then EnableNoClip() else DisableNoClip() end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinity Jump (Giữ Space)",
    CurrentValue = false,
    Flag = "Player_InfJump",
    Callback = function(value)
        Settings.PLAYER.InfJump = value
        if value then EnableInfJump() else DisableInfJump() end
    end
})

print("✅ PHẦN 4/5 ĐÃ LOAD XONG!")
-- ============================================================
-- SKIBIDI HUB RIVALS v2.0 (FIXED)
-- PHẦN 5/5: SETTINGS + COMMUNITY + SKIBIDI BUTTON + LOOPS
-- ============================================================

-- ============================================================
-- SECTION 12D: SETTINGS TAB
-- ============================================================
local SettingsTab = Window:CreateTab("SETTINGS", nil)

SettingsTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPS_Boost",
    Callback = function(value)
        Settings.MISC.FPSBoost = value
        ApplyFPSBoost(value)
    end
})

SettingsTab:CreateLabel("FPS Boost sẽ:")
SettingsTab:CreateLabel("- Tắt bóng đổ")
SettingsTab:CreateLabel("- Tắt hiệu ứng ánh sáng")
SettingsTab:CreateLabel("- Tắt Particle/Decal")
SettingsTab:CreateLabel("- Giảm chất lượng đồ họa")

SettingsTab:CreateDivider()

SettingsTab:CreateButton({
    Name = "Reload UI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
            ClearESP()
            DisableFly()
            DisableNoClip()
            DisableInfJump()
            ClearConnections()
            if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
            for _, player in pairs(Players:GetPlayers()) do RemoveGlow(player) end
        end)
        task.wait(0.5)
        loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
            ClearESP()
            DisableFly()
            DisableNoClip()
            DisableInfJump()
            ClearConnections()
            ApplyFPSBoost(false)
            if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
            for _, player in pairs(Players:GetPlayers()) do RemoveGlow(player) end
            local btnGui = game.CoreGui:FindFirstChild("SkibidiButton")
            if btnGui then btnGui:Destroy() end
        end)
    end
})

-- ============================================================
-- SECTION 12E: COMMUNITY TAB
-- ============================================================
local CommunityTab = Window:CreateTab("COMMUNITY", nil)

CommunityTab:CreateButton({
    Name = "Discord",
    Callback = function() setclipboard("https://discord.gg/") end
})

CommunityTab:CreateButton({
    Name = "TikTok",
    Callback = function() setclipboard("https://tiktok.com/") end
})

CommunityTab:CreateButton({
    Name = "YouTube",
    Callback = function() setclipboard("https://youtube.com/") end
})

CommunityTab:CreateButton({
    Name = "Twitter/X",
    Callback = function() setclipboard("https://x.com/") end
})

CommunityTab:CreateButton({
    Name = "Instagram",
    Callback = function() setclipboard("https://instagram.com/") end
})

CommunityTab:CreateButton({
    Name = "Telegram",
    Callback = function() setclipboard("https://t.me/") end
})

CommunityTab:CreateDivider()
CommunityTab:CreateLabel("Script by vietdz")
CommunityTab:CreateLabel("Game: RIVALS")
CommunityTab:CreateLabel("Version: 2.0")

-- ============================================================
-- SECTION 13: SKIBIDI BUTTON
-- ============================================================
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
    task.spawn(function()
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
    
    -- Click mở UI
    btn.MouseButton1Click:Connect(function()
        if dragging then return end
        IsUIOpen = not IsUIOpen
        if Window then Window.Visible = IsUIOpen end
        if IsUIOpen then
            TweenService:Create(btn, TweenInfo.new(0.3), {Rotation = 0, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.3), {Rotation = 360, ImageColor3 = Color3.fromRGB(100, 150, 255)}):Play()
        end
    end)
    
    return btn
end

task.spawn(function()
    task.wait(0.5)
    CreateSkibidiButton()
end)

-- ============================================================
-- SECTION 14: LOOPS (FIXED)
-- ============================================================

-- AIM Loop (sửa FOV)
AddConnection(RunService.RenderStepped:Connect(function()
    pcall(function()
        UpdateFOVCircle()
        
        if Settings.AIM.Enabled then
            local target = GetClosestPlayer()
            CurrentTarget = target
            
            if target and target.Character then
                local aimPart = GetPart(target, Settings.AIM.AimPart)
                if aimPart then
                    local targetPos = aimPart.Position
                    
                    -- Random offset
                    if Settings.AIM.RandomOffset then
                        targetPos = targetPos + GetRandomOffset()
                    end
                    
                    local currentPos = Camera.CFrame.Position
                    local lookAt = CFrame.lookAt(currentPos, targetPos)
                    local smooth = Settings.AIM.Smoothness
                    Camera.CFrame = Camera.CFrame:Lerp(lookAt, smooth)
                end
            end
        end
    end)
end))

-- ESP Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(UpdateESP)
    end
end)

-- ============================================================
-- SECTION 15: CLEANUP
-- ============================================================
local function Cleanup()
    ClearESP()
    DisableFly()
    DisableNoClip()
    DisableInfJump()
    ClearConnections()
    ApplyFPSBoost(false)
    if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
    for _, player in pairs(Players:GetPlayers()) do RemoveGlow(player) end
end

game:BindToClose(function() Cleanup() end)

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then Cleanup() end
end)

print("✅ PHẦN 5/5 ĐÃ LOAD XONG!")
print("==========================================")
print("🎯 SKIBIDI HUB RIVALS v2.0 ĐÃ SẴN SÀNG!")
print("📌 Tác giả: vietdz")
print("==========================================")
