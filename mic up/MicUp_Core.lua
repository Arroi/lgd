--[[
    Mic Up - Voice Chat Bypass & Movement Script
    Features: Voice Bypass, Flying, TP Tool, Follow, Orbit, Spin, Sit, Baseplates
]]

local MicUp = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VoiceChatService = game:GetService("VoiceChatService")
local HttpService = game:GetService("HttpService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    Password = "MicUp2025",
    Voice = {
        Enabled = false,
        Bypassed = false,
        FakeEnabled = false
    },
    Flying = {
        Enabled = false,
        Speed = 50,
        Keybind = Enum.KeyCode.F
    },
    TPTool = {
        Enabled = false,
        Keybind = Enum.KeyCode.T
    },
    Follow = {
        Enabled = false,
        Target = nil,
        Distance = 5
    },
    Orbit = {
        Enabled = false,
        Target = nil,
        Radius = 10,
        Speed = 2,
        Angle = 0
    },
    Spin = {
        Enabled = false,
        Speed = 5
    },
    Sit = {
        Enabled = false
    },
    Baseplate = {
        Enabled = false,
        Size = 2048,
        Transparency = 0.3,
        Color = Color3.fromRGB(100, 100, 100)
    }
}

-- State Variables
local FlyConnection
local BaseplateInstance
local TPToolInstance
local FollowConnection
local OrbitConnection
local SpinConnection

-- Voice Chat Bypass
function MicUp:BypassVoiceChat()
    if not Config.Voice.Enabled then return end
    
    pcall(function()
        -- Method 1: Spoof voice state
        local success = pcall(function()
            if VoiceChatService then
                -- Enable voice chat if suspended
                if not VoiceChatService:IsVoiceEnabledForUserIdAsync(LocalPlayer.UserId) then
                    Config.Voice.Bypassed = true
                    Config.Voice.FakeEnabled = true
                end
            end
        end)
        
        -- Method 2: Hook voice chat functions
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "IsVoiceEnabledForUserIdAsync" then
                return true
            elseif method == "GetVoiceState" then
                return Enum.VoiceState.Talking
            end
            
            return oldNamecall(self, ...)
        end)
        
        Config.Voice.Bypassed = true
    end)
end

-- Flying System
function MicUp:ToggleFlying()
    Config.Flying.Enabled = not Config.Flying.Enabled
    
    if Config.Flying.Enabled then
        self:StartFlying()
    else
        self:StopFlying()
    end
end

function MicUp:StartFlying()
    if FlyConnection then return end
    
    -- Disable default character controls
    Humanoid.PlatformStand = true
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Config.Flying.Enabled then return end
        
        local Camera = Workspace.CurrentCamera
        local MoveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveDirection = MoveDirection + (Camera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveDirection = MoveDirection - (Camera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveDirection = MoveDirection - (Camera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveDirection = MoveDirection + (Camera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Smooth movement with CFrame lerp
        if MoveDirection.Magnitude > 0 then
            local targetCFrame = HumanoidRootPart.CFrame + (MoveDirection.Unit * (Config.Flying.Speed / 10))
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(targetCFrame, 0.3)
        end
        
        -- Keep character upright and facing camera direction
        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + Camera.CFrame.LookVector)
    end)
end

function MicUp:StopFlying()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    -- Re-enable character controls
    Humanoid.PlatformStand = false
    
    for _, obj in ipairs(HumanoidRootPart:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
            obj:Destroy()
        end
    end
end

-- TP Tool
function MicUp:CreateTPTool()
    if TPToolInstance then
        TPToolInstance:Destroy()
    end
    
    local Tool = Instance.new("Tool")
    Tool.Name = "TP Tool"
    Tool.RequiresHandle = false
    Tool.CanBeDropped = false
    
    Tool.Activated:Connect(function()
        local Mouse = LocalPlayer:GetMouse()
        if Mouse.Target then
            HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end)
    
    Tool.Parent = LocalPlayer.Backpack
    TPToolInstance = Tool
end

function MicUp:RemoveTPTool()
    if TPToolInstance then
        TPToolInstance:Destroy()
        TPToolInstance = nil
    end
end

-- Follow Player
function MicUp:StartFollow(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    Config.Follow.Enabled = true
    Config.Follow.Target = targetPlayer
    
    if FollowConnection then
        FollowConnection:Disconnect()
    end
    
    FollowConnection = RunService.Heartbeat:Connect(function()
        if not Config.Follow.Enabled or not Config.Follow.Target then return end
        
        local target = Config.Follow.Target
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local direction = (targetPos - HumanoidRootPart.Position).Unit
            local newPos = targetPos - (direction * Config.Follow.Distance)
            
            HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
        end
    end)
end

function MicUp:StopFollow()
    Config.Follow.Enabled = false
    Config.Follow.Target = nil
    
    if FollowConnection then
        FollowConnection:Disconnect()
        FollowConnection = nil
    end
end

-- Orbit Player
function MicUp:StartOrbit(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    Config.Orbit.Enabled = true
    Config.Orbit.Target = targetPlayer
    Config.Orbit.Angle = 0
    
    if OrbitConnection then
        OrbitConnection:Disconnect()
    end
    
    OrbitConnection = RunService.Heartbeat:Connect(function(dt)
        if not Config.Orbit.Enabled or not Config.Orbit.Target then return end
        
        local target = Config.Orbit.Target
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            
            Config.Orbit.Angle = Config.Orbit.Angle + (Config.Orbit.Speed * dt)
            
            local x = math.cos(Config.Orbit.Angle) * Config.Orbit.Radius
            local z = math.sin(Config.Orbit.Angle) * Config.Orbit.Radius
            
            local newPos = targetPos + Vector3.new(x, 0, z)
            HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
        end
    end)
end

function MicUp:StopOrbit()
    Config.Orbit.Enabled = false
    Config.Orbit.Target = nil
    
    if OrbitConnection then
        OrbitConnection:Disconnect()
        OrbitConnection = nil
    end
end

-- Spin
function MicUp:ToggleSpin()
    Config.Spin.Enabled = not Config.Spin.Enabled
    
    if Config.Spin.Enabled then
        self:StartSpin()
    else
        self:StopSpin()
    end
end

function MicUp:StartSpin()
    if SpinConnection then return end
    
    local BG = Instance.new("BodyGyro")
    BG.MaxTorque = Vector3.new(0, 9e9, 0)
    BG.P = 10000
    BG.Parent = HumanoidRootPart
    
    SpinConnection = RunService.Heartbeat:Connect(function()
        if not Config.Spin.Enabled then return end
        
        BG.CFrame = BG.CFrame * CFrame.Angles(0, math.rad(Config.Spin.Speed), 0)
    end)
end

function MicUp:StopSpin()
    if SpinConnection then
        SpinConnection:Disconnect()
        SpinConnection = nil
    end
    
    for _, obj in ipairs(HumanoidRootPart:GetChildren()) do
        if obj:IsA("BodyGyro") then
            obj:Destroy()
        end
    end
end

-- Sit
function MicUp:ToggleSit()
    Config.Sit.Enabled = not Config.Sit.Enabled
    if Config.Sit.Enabled then
        Humanoid.Sit = true
    else
        Humanoid.Sit = false
        Humanoid.Jump = true
    end
end

-- Baseplate
function MicUp:ToggleBaseplate()
    Config.Baseplate.Enabled = not Config.Baseplate.Enabled
    
    if Config.Baseplate.Enabled then
        self:CreateBaseplate()
    else
        self:RemoveBaseplate()
    end
end

function MicUp:CreateBaseplate()
    if BaseplateInstance then
        BaseplateInstance:Destroy()
    end
    
    local Baseplate = Instance.new("Part")
    Baseplate.Name = "MicUpBaseplate"
    Baseplate.Size = Vector3.new(Config.Baseplate.Size, 1, Config.Baseplate.Size)
    Baseplate.Anchored = true
    Baseplate.Transparency = Config.Baseplate.Transparency
    Baseplate.Color = Config.Baseplate.Color
    Baseplate.Material = Enum.Material.SmoothPlastic
    Baseplate.TopSurface = Enum.SurfaceType.Smooth
    Baseplate.BottomSurface = Enum.SurfaceType.Smooth
    Baseplate.CanCollide = true
    
    -- Position below player at origin
    Baseplate.CFrame = CFrame.new(0, HumanoidRootPart.Position.Y - 5, 0)
    
    Baseplate.Parent = Workspace
    BaseplateInstance = Baseplate
end

function MicUp:RemoveBaseplate()
    if BaseplateInstance then
        BaseplateInstance:Destroy()
        BaseplateInstance = nil
    end
end

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    -- Reapply active features
    task.wait(1)
    
    if Config.Flying.Enabled then
        MicUp:StopFlying()
        MicUp:StartFlying()
    end
    
    if Config.Baseplate.Enabled then
        MicUp:CreateBaseplate()
    end
    
    if Config.TPTool.Enabled then
        MicUp:CreateTPTool()
    end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.Flying.Keybind then
        MicUp:ToggleFlying()
    elseif input.KeyCode == Config.TPTool.Keybind then
        if Config.TPTool.Enabled then
            MicUp:RemoveTPTool()
            Config.TPTool.Enabled = false
        else
            MicUp:CreateTPTool()
            Config.TPTool.Enabled = true
        end
    end
end)

return {Config = Config, MicUp = MicUp}
