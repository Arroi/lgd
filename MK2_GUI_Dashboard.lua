--[[
    MK2 Dashboard - Modern UI for Murder Mystery 2
    Features: Password Gateway, Dashboard Layout, Real-time Stats
]]

local CoreModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/MK2_MM2.lua"))()
local Config = CoreModule.Config
local MK2 = CoreModule.MK2

-- Import utility functions from core
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

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local ScreenGui
local DashboardFrame
local PasswordFrame
local Authenticated = false
local StatusLabels = {}
local FeatureFrames = {} -- Store all feature frames for search filtering
local SearchActive = false

-- Utility Functions
local function CreateTween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

-- Password Gateway
local function CreatePasswordGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MK2_Dashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Background Blur
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 0
    BlurEffect.Parent = game:GetService("Lighting")
    
    CreateTween(BlurEffect, {Size = 24}, 0.5):Play()
    
    -- Password Frame
    PasswordFrame = Instance.new("Frame")
    PasswordFrame.Name = "PasswordFrame"
    PasswordFrame.Size = UDim2.new(0, 450, 0, 300)
    PasswordFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    PasswordFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    PasswordFrame.BorderSizePixel = 0
    PasswordFrame.BackgroundTransparency = 0.1
    PasswordFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = PasswordFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 50, 80)
    UIStroke.Thickness = 3
    UIStroke.Transparency = 0.3
    UIStroke.Parent = PasswordFrame
    
    CreateGradient(PasswordFrame, Color3.fromRGB(20, 20, 30), Color3.fromRGB(30, 20, 40))
    
    -- Glow Effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Shadow.ImageColor3 = Color3.fromRGB(255, 50, 80)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = 0
    Shadow.Parent = PasswordFrame
    
    -- Logo/Icon
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(0, 80, 0, 80)
    LogoFrame.Position = UDim2.new(0.5, -40, 0, -40)
    LogoFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    LogoFrame.BorderSizePixel = 0
    LogoFrame.Parent = PasswordFrame
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 16)
    LogoCorner.Parent = LogoFrame
    
    CreateGradient(LogoFrame, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "MK2"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 32
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Parent = LogoFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = "MURDER MYSTERY 2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.Parent = PasswordFrame
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0, 110)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Advanced Combat System"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 170)
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = PasswordFrame
    
    -- Password Input
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(0.85, 0, 0, 50)
    InputFrame.Position = UDim2.new(0.075, 0, 0, 155)
    InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = PasswordFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputFrame
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(60, 60, 80)
    InputStroke.Thickness = 2
    InputStroke.Parent = InputFrame
    
    local PasswordInput = Instance.new("TextBox")
    PasswordInput.Size = UDim2.new(1, -20, 1, 0)
    PasswordInput.Position = UDim2.new(0, 10, 0, 0)
    PasswordInput.BackgroundTransparency = 1
    PasswordInput.Text = ""
    PasswordInput.PlaceholderText = "Enter Password..."
    PasswordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasswordInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    PasswordInput.TextSize = 16
    PasswordInput.Font = Enum.Font.Gotham
    PasswordInput.TextXAlignment = Enum.TextXAlignment.Left
    PasswordInput.ClearTextOnFocus = false
    PasswordInput.Parent = InputFrame
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(0.85, 0, 0, 50)
    SubmitButton.Position = UDim2.new(0.075, 0, 0, 220)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "AUTHENTICATE"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 18
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = PasswordFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = SubmitButton
    
    CreateGradient(SubmitButton, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
    
    -- Submit Function
    local function CheckPassword()
        local input = PasswordInput.Text
        
        if input == Config.Password then
            Authenticated = true
            Notify("MK2", "Access Granted!", 3)
            
            CreateTween(PasswordFrame, {Size = UDim2.new(0, 450, 0, 0), Position = UDim2.new(0.5, -225, 0.5, 0)}, 0.5):Play()
            CreateTween(BlurEffect, {Size = 0}, 0.5):Play()
            
            task.wait(0.5)
            PasswordFrame:Destroy()
            BlurEffect:Destroy()
            CreateDashboard()
        else
            Notify("MK2", "Access Denied!", 3)
            PasswordInput.Text = ""
            
            -- Shake animation
            for i = 1, 4 do
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -235, 0.5, -150)}, 0.05):Play()
                task.wait(0.05)
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -215, 0.5, -150)}, 0.05):Play()
                task.wait(0.05)
            end
            PasswordFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
            
            -- Flash red
            CreateTween(InputStroke, {Color = Color3.fromRGB(255, 50, 50)}, 0.2):Play()
            task.wait(0.5)
            CreateTween(InputStroke, {Color = Color3.fromRGB(60, 60, 80)}, 0.3):Play()
        end
    end
    
    SubmitButton.MouseButton1Click:Connect(CheckPassword)
    PasswordInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            CheckPassword()
        end
    end)
    
    -- Hover Effects
    SubmitButton.MouseEnter:Connect(function()
        CreateTween(SubmitButton, {Size = UDim2.new(0.87, 0, 0, 52)}, 0.2):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        CreateTween(SubmitButton, {Size = UDim2.new(0.85, 0, 0, 50)}, 0.2):Play()
    end)
    
    InputFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            CreateTween(InputStroke, {Color = Color3.fromRGB(255, 50, 80), Thickness = 3}, 0.2):Play()
        end
    end)
    
    InputFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            CreateTween(InputStroke, {Color = Color3.fromRGB(60, 60, 80), Thickness = 2}, 0.2):Play()
        end
    end)
    
    ScreenGui.Parent = PlayerGui
end

-- Dashboard Creation
function CreateDashboard()
    DashboardFrame = Instance.new("Frame")
    DashboardFrame.Name = "Dashboard"
    DashboardFrame.Size = UDim2.new(0, 700, 0, 500)
    DashboardFrame.Position = UDim2.new(0.5, -350, 1.5, 0)
    DashboardFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    DashboardFrame.BorderSizePixel = 0
    DashboardFrame.BackgroundTransparency = 0.05
    DashboardFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = DashboardFrame
    
    CreateGradient(DashboardFrame, Color3.fromRGB(15, 15, 25), Color3.fromRGB(25, 15, 35))
    
    -- Animate in
    CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -350, 0.5, -250)}, 0.6):Play()
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = DashboardFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 16)
    TopCorner.Parent = TopBar
    
    local TopFill = Instance.new("Frame")
    TopFill.Size = UDim2.new(1, 0, 0, 30)
    TopFill.Position = UDim2.new(0, 0, 1, -30)
    TopFill.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TopFill.BorderSizePixel = 0
    TopFill.Parent = TopBar
    
    -- Logo in Top Bar
    local TopLogo = Instance.new("Frame")
    TopLogo.Size = UDim2.new(0, 40, 0, 40)
    TopLogo.Position = UDim2.new(0, 15, 0.5, -20)
    TopLogo.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    TopLogo.BorderSizePixel = 0
    TopLogo.Parent = TopBar
    
    local TopLogoCorner = Instance.new("UICorner")
    TopLogoCorner.CornerRadius = UDim.new(0, 10)
    TopLogoCorner.Parent = TopLogo
    
    CreateGradient(TopLogo, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
    
    local TopLogoText = Instance.new("TextLabel")
    TopLogoText.Size = UDim2.new(1, 0, 1, 0)
    TopLogoText.BackgroundTransparency = 1
    TopLogoText.Text = "M2"
    TopLogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopLogoText.TextSize = 18
    TopLogoText.Font = Enum.Font.GothamBold
    TopLogoText.Parent = TopLogo
    
    local TopTitle = Instance.new("TextLabel")
    TopTitle.Size = UDim2.new(0, 200, 1, 0)
    TopTitle.Position = UDim2.new(0, 65, 0, 0)
    TopTitle.BackgroundTransparency = 1
    TopTitle.Text = "MK2 Dashboard"
    TopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TopTitle.TextSize = 20
    TopTitle.Font = Enum.Font.GothamBold
    TopTitle.TextXAlignment = Enum.TextXAlignment.Left
    TopTitle.Parent = TopBar
    
    local TopSubtitle = Instance.new("TextLabel")
    TopSubtitle.Size = UDim2.new(0, 200, 0, 15)
    TopSubtitle.Position = UDim2.new(0, 65, 0, 35)
    TopSubtitle.BackgroundTransparency = 1
    TopSubtitle.Text = "Murder Mystery 2"
    TopSubtitle.TextColor3 = Color3.fromRGB(150, 150, 170)
    TopSubtitle.TextSize = 12
    TopSubtitle.Font = Enum.Font.Gotham
    TopSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    TopSubtitle.Parent = TopBar
    
    -- Status Indicator
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(0, 120, 0, 35)
    StatusFrame.Position = UDim2.new(1, -135, 0.5, -17.5)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = TopBar
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusDot = Instance.new("Frame")
    StatusDot.Size = UDim2.new(0, 10, 0, 10)
    StatusDot.Position = UDim2.new(0, 10, 0.5, -5)
    StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    StatusDot.BorderSizePixel = 0
    StatusDot.Parent = StatusFrame
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = StatusDot
    
    -- Pulse animation
    task.spawn(function()
        while StatusDot and StatusDot.Parent do
            CreateTween(StatusDot, {BackgroundTransparency = 0.3}, 0.8):Play()
            task.wait(0.8)
            CreateTween(StatusDot, {BackgroundTransparency = 0}, 0.8):Play()
            task.wait(0.8)
        end
    end)
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -30, 1, 0)
    StatusText.Position = UDim2.new(0, 25, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "ACTIVE"
    StatusText.TextColor3 = Color3.fromRGB(50, 255, 100)
    StatusText.TextSize = 14
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusFrame
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -50, 0.5, -17.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TopBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -350, 1.5, 0)}, 0.5):Play()
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        CreateTween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 70, 100)}, 0.2):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        CreateTween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 80)}, 0.2):Play()
    end)
    
    -- Search Bar
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 300, 0, 40)
    SearchFrame.Position = UDim2.new(0.5, -150, 1, 10)
    SearchFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    SearchFrame.BorderSizePixel = 0
    SearchFrame.Parent = DashboardFrame
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 10)
    SearchCorner.Parent = SearchFrame
    
    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Color3.fromRGB(60, 60, 80)
    SearchStroke.Thickness = 2
    SearchStroke.Parent = SearchFrame
    
    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size = UDim2.new(0, 30, 1, 0)
    SearchIcon.Position = UDim2.new(0, 5, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 170)
    SearchIcon.TextSize = 18
    SearchIcon.Font = Enum.Font.Gotham
    SearchIcon.Parent = SearchFrame
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -80, 1, 0)
    SearchBox.Position = UDim2.new(0, 35, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search features..."
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = SearchFrame
    
    local ClearButton = Instance.new("TextButton")
    ClearButton.Size = UDim2.new(0, 30, 0, 30)
    ClearButton.Position = UDim2.new(1, -35, 0.5, -15)
    ClearButton.BackgroundTransparency = 1
    ClearButton.Text = "✕"
    ClearButton.TextColor3 = Color3.fromRGB(150, 150, 170)
    ClearButton.TextSize = 16
    ClearButton.Font = Enum.Font.GothamBold
    ClearButton.Visible = false
    ClearButton.Parent = SearchFrame
    
    -- Search functionality
    local function FilterFeatures(query)
        query = query:lower()
        local visibleCount = 0
        
        for _, frameData in ipairs(FeatureFrames) do
            local frame = frameData.Frame
            local name = frameData.Name:lower()
            local desc = frameData.Description:lower()
            
            if query == "" or name:find(query) or desc:find(query) then
                frame.Visible = true
                visibleCount = visibleCount + 1
            else
                frame.Visible = false
            end
        end
        
        ClearButton.Visible = query ~= ""
        SearchActive = query ~= ""
        
        if query ~= "" then
            CreateTween(SearchStroke, {Color = Color3.fromRGB(255, 50, 80), Thickness = 3}, 0.2):Play()
        else
            CreateTween(SearchStroke, {Color = Color3.fromRGB(60, 60, 80), Thickness = 2}, 0.2):Play()
        end
    end
    
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        FilterFeatures(SearchBox.Text)
    end)
    
    ClearButton.MouseButton1Click:Connect(function()
        SearchBox.Text = ""
        FilterFeatures("")
    end)
    
    ClearButton.MouseEnter:Connect(function()
        CreateTween(ClearButton, {TextColor3 = Color3.fromRGB(255, 50, 80)}, 0.2):Play()
    end)
    
    ClearButton.MouseLeave:Connect(function()
        CreateTween(ClearButton, {TextColor3 = Color3.fromRGB(150, 150, 170)}, 0.2):Play()
    end)
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -20, 1, -130)
    ContentArea.Position = UDim2.new(0, 10, 0, 120)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = DashboardFrame
    
    -- Left Panel (Stats & Info)
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Size = UDim2.new(0.35, -5, 1, 0)
    LeftPanel.Position = UDim2.new(0, 0, 0, 0)
    LeftPanel.BackgroundTransparency = 1
    LeftPanel.Parent = ContentArea
    
    -- Stats Cards
    local function CreateStatCard(name, icon, yPos)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 80)
        Card.Position = UDim2.new(0, 0, 0, yPos)
        Card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        Card.BorderSizePixel = 0
        Card.Parent = LeftPanel
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 12)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Color3.fromRGB(40, 40, 60)
        CardStroke.Thickness = 1
        CardStroke.Transparency = 0.5
        CardStroke.Parent = Card
        
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 50, 0, 50)
        IconLabel.Position = UDim2.new(0, 15, 0.5, -25)
        IconLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
        IconLabel.BorderSizePixel = 0
        IconLabel.Text = icon
        IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        IconLabel.TextSize = 24
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.Parent = Card
        
        local IconCorner = Instance.new("UICorner")
        IconCorner.CornerRadius = UDim.new(0, 10)
        IconCorner.Parent = IconLabel
        
        CreateGradient(IconLabel, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -80, 0, 20)
        NameLabel.Position = UDim2.new(0, 75, 0, 15)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
        NameLabel.TextSize = 12
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Card
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(1, -80, 0, 30)
        ValueLabel.Position = UDim2.new(0, 75, 0, 35)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = "0"
        ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueLabel.TextSize = 20
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
        ValueLabel.Parent = Card
        
        return ValueLabel
    end
    
    StatusLabels.GameMode = CreateStatCard("Game Mode", "🎮", 0)
    StatusLabels.Players = CreateStatCard("Players Detected", "👥", 90)
    StatusLabels.Murderer = CreateStatCard("Murderer Status", "🔪", 180)
    StatusLabels.Target = CreateStatCard("Current Target", "🎯", 270)
    StatusLabels.Distance = CreateStatCard("Target Distance", "📏", 360)
    
    -- Right Panel (Controls)
    local RightPanel = Instance.new("ScrollingFrame")
    RightPanel.Size = UDim2.new(0.65, -5, 1, 0)
    RightPanel.Position = UDim2.new(0.35, 5, 0, 0)
    RightPanel.BackgroundTransparency = 1
    RightPanel.BorderSizePixel = 0
    RightPanel.ScrollBarThickness = 4
    RightPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 80)
    RightPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightPanel.Parent = ContentArea
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = RightPanel
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        RightPanel.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Section Header Function
    local function CreateSection(title)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, 0, 0, 40)
        Section.BackgroundTransparency = 1
        Section.Parent = RightPanel
        
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 4, 1, -10)
        Line.Position = UDim2.new(0, 0, 0, 5)
        Line.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
        Line.BorderSizePixel = 0
        Line.Parent = Section
        
        local LineCorner = Instance.new("UICorner")
        LineCorner.CornerRadius = UDim.new(1, 0)
        LineCorner.Parent = Line
        
        CreateGradient(Line, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100))
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -15, 1, 0)
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = title
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 18
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Section
    end
    
    -- Toggle Switch Function
    local function CreateToggle(name, description, configPath, keybind)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 70)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = RightPanel
        
        -- Register for search
        table.insert(FeatureFrames, {
            Frame = ToggleFrame,
            Name = name,
            Description = description
        })
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 12)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = Color3.fromRGB(40, 40, 60)
        ToggleStroke.Thickness = 1
        ToggleStroke.Transparency = 0.5
        ToggleStroke.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Size = UDim2.new(0.6, 0, 0, 20)
        ToggleLabel.Position = UDim2.new(0, 15, 0, 10)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 15
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Size = UDim2.new(0.6, 0, 0, 15)
        ToggleDesc.Position = UDim2.new(0, 15, 0, 32)
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Text = description
        ToggleDesc.TextColor3 = Color3.fromRGB(120, 120, 140)
        ToggleDesc.TextSize = 11
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDesc.Parent = ToggleFrame
        
        -- Keybind Display
        if keybind then
            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Size = UDim2.new(0, 60, 0, 20)
            KeybindLabel.Position = UDim2.new(0, 15, 1, -25)
            KeybindLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            KeybindLabel.BorderSizePixel = 0
            KeybindLabel.Text = "Key: " .. keybind
            KeybindLabel.TextColor3 = Color3.fromRGB(255, 50, 80)
            KeybindLabel.TextSize = 10
            KeybindLabel.Font = Enum.Font.GothamBold
            KeybindLabel.Parent = ToggleFrame
            
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 6)
            KeyCorner.Parent = KeybindLabel
        end
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 60, 0, 30)
        ToggleButton.Position = UDim2.new(1, -75, 0.5, -15)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = ToggleButton
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 26, 0, 26)
        ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -13)
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = ToggleButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator
        
        -- Get config value
        local function getConfigValue()
            local current = Config
            for _, key in ipairs(configPath) do
                current = current[key]
            end
            return current
        end
        
        local function setConfigValue(value)
            local current = Config
            for i = 1, #configPath - 1 do
                current = current[configPath[i]]
            end
            current[configPath[#configPath]] = value
        end
        
        local enabled = getConfigValue()
        
        if enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
            ToggleIndicator.Position = UDim2.new(1, -28, 0.5, -13)
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            CreateGradient(ToggleButton, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            enabled = not enabled
            setConfigValue(enabled)
            
            if enabled then
                CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 80)}, 0.3):Play()
                CreateTween(ToggleIndicator, {Position = UDim2.new(1, -28, 0.5, -13), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.3):Play()
                CreateTween(ToggleStroke, {Color = Color3.fromRGB(255, 50, 80), Transparency = 0.3}, 0.3):Play()
                CreateGradient(ToggleButton, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
                Notify("MK2", name .. " Enabled", 2)
            else
                CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.3):Play()
                CreateTween(ToggleIndicator, {Position = UDim2.new(0, 2, 0.5, -13), BackgroundColor3 = Color3.fromRGB(180, 180, 200)}, 0.3):Play()
                CreateTween(ToggleStroke, {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}, 0.3):Play()
                for _, child in ipairs(ToggleButton:GetChildren()) do
                    if child:IsA("UIGradient") then
                        child:Destroy()
                    end
                end
                Notify("MK2", name .. " Disabled", 2)
            end
        end)
        
        ToggleButton.MouseEnter:Connect(function()
            CreateTween(ToggleButton, {Size = UDim2.new(0, 62, 0, 32)}, 0.2):Play()
        end)
        
        ToggleButton.MouseLeave:Connect(function()
            CreateTween(ToggleButton, {Size = UDim2.new(0, 60, 0, 30)}, 0.2):Play()
        end)
    end
    
    -- Slider Function
    local function CreateSlider(name, description, configPath, min, max, increment)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 80)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = RightPanel
        
        -- Register for search
        table.insert(FeatureFrames, {
            Frame = SliderFrame,
            Name = name,
            Description = description
        })
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 12)
        SliderCorner.Parent = SliderFrame
        
        local SliderStroke = Instance.new("UIStroke")
        SliderStroke.Color = Color3.fromRGB(40, 40, 60)
        SliderStroke.Thickness = 1
        SliderStroke.Transparency = 0.5
        SliderStroke.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
        SliderLabel.Position = UDim2.new(0, 15, 0, 10)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = name
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 15
        SliderLabel.Font = Enum.Font.GothamBold
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderValue = Instance.new("TextLabel")
        SliderValue.Size = UDim2.new(0.3, 0, 0, 20)
        SliderValue.Position = UDim2.new(0.7, 0, 0, 10)
        SliderValue.BackgroundTransparency = 1
        SliderValue.Text = "0"
        SliderValue.TextColor3 = Color3.fromRGB(255, 50, 80)
        SliderValue.TextSize = 15
        SliderValue.Font = Enum.Font.GothamBold
        SliderValue.TextXAlignment = Enum.TextXAlignment.Right
        SliderValue.Parent = SliderFrame
        
        local SliderDesc = Instance.new("TextLabel")
        SliderDesc.Size = UDim2.new(1, -30, 0, 15)
        SliderDesc.Position = UDim2.new(0, 15, 0, 32)
        SliderDesc.BackgroundTransparency = 1
        SliderDesc.Text = description
        SliderDesc.TextColor3 = Color3.fromRGB(120, 120, 140)
        SliderDesc.TextSize = 11
        SliderDesc.Font = Enum.Font.Gotham
        SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
        SliderDesc.Parent = SliderFrame
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Size = UDim2.new(1, -30, 0, 8)
        SliderBar.Position = UDim2.new(0, 15, 1, -20)
        SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        SliderBar.BorderSizePixel = 0
        SliderBar.Parent = SliderFrame
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = SliderBar
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new(0, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBar
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill
        
        CreateGradient(SliderFill, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
        
        -- Get initial value
        local function getConfigValue()
            local current = Config
            for _, key in ipairs(configPath) do
                current = current[key]
            end
            return current
        end
        
        local function setConfigValue(value)
            local current = Config
            for i = 1, #configPath - 1 do
                current = current[configPath[i]]
            end
            current[configPath[#configPath]] = value
        end
        
        local currentValue = getConfigValue()
        SliderValue.Text = tostring(currentValue)
        SliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        
        local dragging = false
        
        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                CreateTween(SliderStroke, {Color = Color3.fromRGB(255, 50, 80), Transparency = 0.3}, 0.2):Play()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                CreateTween(SliderStroke, {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}, 0.2):Play()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local relativePos = (mousePos.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                relativePos = math.clamp(relativePos, 0, 1)
                
                local value = min + (max - min) * relativePos
                value = math.floor(value / increment + 0.5) * increment
                value = math.clamp(value, min, max)
                
                currentValue = value
                setConfigValue(value)
                SliderValue.Text = tostring(value)
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            end
        end)
    end
    
    -- Build UI Sections
    CreateSection("🎯 COMBAT FEATURES")
    CreateToggle("Aimbot", "Auto-aim at targets within FOV", {"Aimbot", "Enabled"}, "E")
    CreateToggle("Camlock", "Lock camera to target", {"Camlock", "Enabled"}, "Q")
    CreateToggle("Prioritize Murderer", "Target murderer first", {"Aimbot", "PrioritizeMurderer"})
    CreateSlider("Aimbot FOV", "Field of view radius", {"Aimbot", "FOV"}, 50, 500, 10)
    CreateSlider("Aimbot Smoothness", "Lower = faster aim", {"Aimbot", "Smoothness"}, 0.01, 1, 0.01)
    CreateSlider("Camlock Smoothness", "Camera tracking speed", {"Camlock", "Smoothness"}, 0.01, 1, 0.01)
    CreateSlider("Prediction", "Movement prediction", {"Camlock", "PredictionStrength"}, 0.01, 0.5, 0.01)
    
    CreateSection("👁️ ESP FEATURES")
    CreateToggle("ESP Master", "Toggle all ESP features", {"ESP", "Enabled"})
    CreateToggle("Skeleton ESP", "Show player skeletons", {"ESP", "Skeleton"})
    CreateToggle("Box ESP", "Show bounding boxes", {"ESP", "Box"})
    CreateToggle("Tracer ESP", "Draw lines to players", {"ESP", "Tracers"})
    CreateToggle("Show Murderer", "Display murderer ESP", {"ESP", "ShowMurderer"})
    CreateToggle("Show Sheriff", "Display sheriff ESP", {"ESP", "ShowSheriff"})
    CreateToggle("Show Innocent", "Display innocent ESP", {"ESP", "ShowInnocent"})
    
    CreateSection("⚙️ SETTINGS")
    CreateToggle("Show FOV Circle", "Display aimbot FOV", {"Aimbot", "ShowFOV"})
    CreateToggle("Visibility Check", "Only target visible players", {"Aimbot", "VisibilityCheck"})
    CreateToggle("Predict Movement", "Enable movement prediction", {"Camlock", "PredictMovement"})
    
    -- Make draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = DashboardFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            DashboardFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    
    -- Real-time Stats Update
    task.spawn(function()
        while DashboardFrame and DashboardFrame.Parent do
            -- Detect game mode
            local murdererCount = 0
            local sheriffCount = 0
            local murdererNames = {}
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local role = GetPlayerRole(player)
                    if role == "Murderer" then
                        murdererCount = murdererCount + 1
                        table.insert(murdererNames, player.Name)
                    elseif role == "Sheriff" then
                        sheriffCount = sheriffCount + 1
                    end
                end
            end
            
            -- Update game mode
            if murdererCount > 1 or sheriffCount > 1 then
                Config.GameMode = "MvS"
                StatusLabels.GameMode.Text = "Murders vs Sheriffs"
                StatusLabels.GameMode.TextColor3 = Color3.fromRGB(255, 150, 50)
            else
                Config.GameMode = "Classic"
                StatusLabels.GameMode.Text = "Classic Mode"
                StatusLabels.GameMode.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
            
            -- Player count
            local playerCount = #Players:GetPlayers() - 1
            StatusLabels.Players.Text = tostring(playerCount)
            
            -- Murderer status
            if murdererCount == 0 then
                StatusLabels.Murderer.Text = "None"
            elseif murdererCount == 1 then
                StatusLabels.Murderer.Text = murdererNames[1]
            else
                StatusLabels.Murderer.Text = murdererCount .. " Murderers"
            end
            
            -- Current target
            if Config.Camlock.Locked and Config.Camlock.Target then
                local targetRole = GetPlayerRole(Config.Camlock.Target)
                StatusLabels.Target.Text = Config.Camlock.Target.Name .. " (" .. targetRole .. ")"
                
                -- Distance
                if Config.Camlock.Target.Character and Config.Camlock.Target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (Config.Camlock.Target.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    StatusLabels.Distance.Text = string.format("%.1f studs", distance)
                else
                    StatusLabels.Distance.Text = "N/A"
                end
            else
                StatusLabels.Target.Text = "None"
                StatusLabels.Distance.Text = "N/A"
            end
            
            task.wait(0.5)
        end
    end)
end

-- Initialize
CreatePasswordGUI()
Notify("MK2", "Script loaded! Enter password.", 5)
