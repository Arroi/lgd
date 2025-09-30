--[[
    MK2 - Murder Mystery 2 Script
    Features: ESP (Skeleton, Box, Tracers), Camlock, Aimbot, Password Gateway
    Educational purposes only - White-hat hacking demonstration
]]

local MK2 = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    Password = "MK2_2025",
    ESP = {
        Enabled = false,
        Skeleton = true,
        Box = true,
        Tracers = true,
        ShowMurderer = true,
        ShowSheriff = true,
        ShowInnocent = true,
        MurdererColor = Color3.fromRGB(255, 0, 0),
        SheriffColor = Color3.fromRGB(0, 0, 255),
        InnocentColor = Color3.fromRGB(0, 255, 0),
        Thickness = 2
    },
    Aimbot = {
        Enabled = false,
        FOV = 100,
        ShowFOV = true,
        TargetPart = "Head",
        Smoothness = 0.1,
        TeamCheck = true,
        VisibilityCheck = true
    },
    Camlock = {
        Enabled = false,
        Keybind = Enum.KeyCode.Q,
        Locked = false,
        Target = nil,
        Smoothness = 0.15,
        PredictMovement = true,
        PredictionStrength = 0.12
    }
}

-- ESP Storage
local ESPObjects = {}

-- Utility Functions
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

local function GetPlayerRole(player)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    if backpack then
        if backpack:FindFirstChild("Knife") or (character and character:FindFirstChild("Knife")) then
            return "Murderer"
        elseif backpack:FindFirstChild("Gun") or (character and character:FindFirstChild("Gun")) then
            return "Sheriff"
        end
    end
    
    return "Innocent"
end

local function GetRoleColor(role)
    if role == "Murderer" then
        return Config.ESP.MurdererColor
    elseif role == "Sheriff" then
        return Config.ESP.SheriffColor
    else
        return Config.ESP.InnocentColor
    end
end

local function IsVisible(targetPart)
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    return raycastResult == nil
end

local function WorldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen, screenPoint.Z
end

-- ESP Functions
function MK2:CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Player = player,
        Drawings = {},
        Connections = {}
    }
    
    -- Box ESP
    esp.Drawings.Box = {
        TopLeft = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        TopRight = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        BottomLeft = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        BottomRight = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)})
    }
    
    -- Tracer
    esp.Drawings.Tracer = CreateDrawing("Line", {
        Visible = false,
        Thickness = Config.ESP.Thickness,
        Color = Color3.new(1, 1, 1),
        From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
        To = Vector2.new(0, 0)
    })
    
    -- Skeleton
    esp.Drawings.Skeleton = {
        Head_UpperTorso = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        UpperTorso_LowerTorso = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        UpperTorso_LeftUpperArm = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        LeftUpperArm_LeftLowerArm = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        LeftLowerArm_LeftHand = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        UpperTorso_RightUpperArm = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        RightUpperArm_RightLowerArm = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        RightLowerArm_RightHand = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        LowerTorso_LeftUpperLeg = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        LeftUpperLeg_LeftLowerLeg = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        LeftLowerLeg_LeftFoot = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        LowerTorso_RightUpperLeg = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        RightUpperLeg_RightLowerLeg = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)}),
        RightLowerLeg_RightFoot = CreateDrawing("Line", {Visible = false, Thickness = Config.ESP.Thickness, Color = Color3.new(1, 1, 1)})
    }
    
    ESPObjects[player] = esp
end

function MK2:UpdateESP(player, esp)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        self:HideESP(esp)
        return
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local head = character:FindFirstChild("Head")
    
    if not head then
        self:HideESP(esp)
        return
    end
    
    local role = GetPlayerRole(player)
    local color = GetRoleColor(role)
    
    -- Check role filters
    if (role == "Murderer" and not Config.ESP.ShowMurderer) or
       (role == "Sheriff" and not Config.ESP.ShowSheriff) or
       (role == "Innocent" and not Config.ESP.ShowInnocent) then
        self:HideESP(esp)
        return
    end
    
    local rootPos, rootOnScreen = WorldToScreen(humanoidRootPart.Position)
    
    if not rootOnScreen then
        self:HideESP(esp)
        return
    end
    
    -- Box ESP
    if Config.ESP.Box then
        local headPos = WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = WorldToScreen(humanoidRootPart.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height / 2
        
        -- Update box lines
        esp.Drawings.Box.TopLeft.From = Vector2.new(rootPos.X - width / 2, headPos.Y)
        esp.Drawings.Box.TopLeft.To = Vector2.new(rootPos.X - width / 2, legPos.Y)
        esp.Drawings.Box.TopLeft.Color = color
        esp.Drawings.Box.TopLeft.Visible = true
        
        esp.Drawings.Box.TopRight.From = Vector2.new(rootPos.X + width / 2, headPos.Y)
        esp.Drawings.Box.TopRight.To = Vector2.new(rootPos.X + width / 2, legPos.Y)
        esp.Drawings.Box.TopRight.Color = color
        esp.Drawings.Box.TopRight.Visible = true
        
        esp.Drawings.Box.BottomLeft.From = Vector2.new(rootPos.X - width / 2, headPos.Y)
        esp.Drawings.Box.BottomLeft.To = Vector2.new(rootPos.X + width / 2, headPos.Y)
        esp.Drawings.Box.BottomLeft.Color = color
        esp.Drawings.Box.BottomLeft.Visible = true
        
        esp.Drawings.Box.BottomRight.From = Vector2.new(rootPos.X - width / 2, legPos.Y)
        esp.Drawings.Box.BottomRight.To = Vector2.new(rootPos.X + width / 2, legPos.Y)
        esp.Drawings.Box.BottomRight.Color = color
        esp.Drawings.Box.BottomRight.Visible = true
    else
        for _, line in pairs(esp.Drawings.Box) do
            line.Visible = false
        end
    end
    
    -- Tracer ESP
    if Config.ESP.Tracers then
        esp.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        esp.Drawings.Tracer.To = rootPos
        esp.Drawings.Tracer.Color = color
        esp.Drawings.Tracer.Visible = true
    else
        esp.Drawings.Tracer.Visible = false
    end
    
    -- Skeleton ESP
    if Config.ESP.Skeleton then
        local function connectLimbs(part1Name, part2Name, line)
            local part1 = character:FindFirstChild(part1Name)
            local part2 = character:FindFirstChild(part2Name)
            
            if part1 and part2 then
                local pos1, onScreen1 = WorldToScreen(part1.Position)
                local pos2, onScreen2 = WorldToScreen(part2.Position)
                
                if onScreen1 and onScreen2 then
                    line.From = pos1
                    line.To = pos2
                    line.Color = color
                    line.Visible = true
                    return
                end
            end
            line.Visible = false
        end
        
        connectLimbs("Head", "UpperTorso", esp.Drawings.Skeleton.Head_UpperTorso)
        connectLimbs("UpperTorso", "LowerTorso", esp.Drawings.Skeleton.UpperTorso_LowerTorso)
        connectLimbs("UpperTorso", "LeftUpperArm", esp.Drawings.Skeleton.UpperTorso_LeftUpperArm)
        connectLimbs("LeftUpperArm", "LeftLowerArm", esp.Drawings.Skeleton.LeftUpperArm_LeftLowerArm)
        connectLimbs("LeftLowerArm", "LeftHand", esp.Drawings.Skeleton.LeftLowerArm_LeftHand)
        connectLimbs("UpperTorso", "RightUpperArm", esp.Drawings.Skeleton.UpperTorso_RightUpperArm)
        connectLimbs("RightUpperArm", "RightLowerArm", esp.Drawings.Skeleton.RightUpperArm_RightLowerArm)
        connectLimbs("RightLowerArm", "RightHand", esp.Drawings.Skeleton.RightLowerArm_RightHand)
        connectLimbs("LowerTorso", "LeftUpperLeg", esp.Drawings.Skeleton.LowerTorso_LeftUpperLeg)
        connectLimbs("LeftUpperLeg", "LeftLowerLeg", esp.Drawings.Skeleton.LeftUpperLeg_LeftLowerLeg)
        connectLimbs("LeftLowerLeg", "LeftFoot", esp.Drawings.Skeleton.LeftLowerLeg_LeftFoot)
        connectLimbs("LowerTorso", "RightUpperLeg", esp.Drawings.Skeleton.LowerTorso_RightUpperLeg)
        connectLimbs("RightUpperLeg", "RightLowerLeg", esp.Drawings.Skeleton.RightUpperLeg_RightLowerLeg)
        connectLimbs("RightLowerLeg", "RightFoot", esp.Drawings.Skeleton.RightLowerLeg_RightFoot)
    else
        for _, line in pairs(esp.Drawings.Skeleton) do
            line.Visible = false
        end
    end
end

function MK2:HideESP(esp)
    for _, line in pairs(esp.Drawings.Box) do
        line.Visible = false
    end
    esp.Drawings.Tracer.Visible = false
    for _, line in pairs(esp.Drawings.Skeleton) do
        line.Visible = false
    end
end

function MK2:RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, line in pairs(esp.Drawings.Box) do
            line:Remove()
        end
        esp.Drawings.Tracer:Remove()
        for _, line in pairs(esp.Drawings.Skeleton) do
            line:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- Aimbot Functions
local FOVCircle = CreateDrawing("Circle", {
    Visible = false,
    Thickness = 2,
    Color = Color3.fromRGB(255, 255, 255),
    NumSides = 64,
    Radius = 100,
    Filled = false
})

function MK2:GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart)
            
            if targetPart then
                local screenPos, onScreen = WorldToScreen(targetPart.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local distance = (screenPos - mousePos).Magnitude
                    
                    if distance < Config.Aimbot.FOV and distance < shortestDistance then
                        if Config.Aimbot.VisibilityCheck then
                            if IsVisible(targetPart) then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        else
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function MK2:AimbotUpdate()
    if not Config.Aimbot.Enabled then return end
    
    local target = self:GetClosestPlayer()
    
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
        
        if targetPart then
            local targetPosition = targetPart.Position
            local cameraPosition = Camera.CFrame.Position
            local direction = (targetPosition - cameraPosition).Unit
            
            local targetCFrame = CFrame.new(cameraPosition, cameraPosition + direction)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.Smoothness)
        end
    end
end

-- Camlock Functions
function MK2:CamlockUpdate()
    if not Config.Camlock.Enabled or not Config.Camlock.Locked or not Config.Camlock.Target then return end
    
    local target = Config.Camlock.Target
    
    if target.Character then
        local targetPart = target.Character:FindFirstChild("Head")
        
        if targetPart then
            local targetPosition = targetPart.Position
            
            -- Prediction
            if Config.Camlock.PredictMovement then
                local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local velocity = humanoidRootPart.AssemblyLinearVelocity
                    targetPosition = targetPosition + (velocity * Config.Camlock.PredictionStrength)
                end
            end
            
            local cameraPosition = Camera.CFrame.Position
            local direction = (targetPosition - cameraPosition).Unit
            
            local targetCFrame = CFrame.new(cameraPosition, cameraPosition + direction)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Camlock.Smoothness)
        end
    end
end

function MK2:ToggleCamlock()
    if not Config.Camlock.Enabled then return end
    
    if Config.Camlock.Locked then
        Config.Camlock.Locked = false
        Config.Camlock.Target = nil
    else
        local target = self:GetClosestPlayer()
        if target then
            Config.Camlock.Locked = true
            Config.Camlock.Target = target
        end
    end
end

-- Main Loop
local function MainLoop()
    -- Update FOV Circle
    if Config.Aimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.Aimbot.FOV
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    else
        FOVCircle.Visible = false
    end
    
    -- Update ESP
    if Config.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if not ESPObjects[player] then
                MK2:CreateESP(player)
            end
            
            if ESPObjects[player] then
                MK2:UpdateESP(player, ESPObjects[player])
            end
        end
    else
        for _, esp in pairs(ESPObjects) do
            MK2:HideESP(esp)
        end
    end
    
    -- Update Aimbot
    MK2:AimbotUpdate()
    
    -- Update Camlock
    MK2:CamlockUpdate()
end

RunService.RenderStepped:Connect(MainLoop)

-- Player Events
Players.PlayerRemoving:Connect(function(player)
    MK2:RemoveESP(player)
    if Config.Camlock.Target == player then
        Config.Camlock.Locked = false
        Config.Camlock.Target = nil
    end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.Camlock.Keybind then
        MK2:ToggleCamlock()
    end
end)

return {Config = Config, MK2 = MK2}
