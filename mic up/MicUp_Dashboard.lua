--[[
    Mic Up Dashboard - Multi-Page Interface
    Features: Password Gateway, Command Bar, Notifications, Multiple Pages
]]

local CoreModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/MicUp_Core.lua"))()
local Config = CoreModule.Config
local MicUp = CoreModule.MicUp

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
local CommandBar
local NotificationContainer
local Authenticated = false
local CurrentPage = "Home"
local Pages = {}
local GUIVisible = true

-- Utility Functions
local function CreateTween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    return TweenService:Create(instance, tweenInfo, properties)
end

local function Notify(title, text, duration, color)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 300, 0, 0)
    NotifFrame.Position = UDim2.new(1, -320, 1, 20)
    NotifFrame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 45)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotificationContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = NotifFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 200, 255)
    Stroke.Thickness = 2
    Stroke.Parent = NotifFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = NotifFrame
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -20, 0, 20)
    Text.Position = UDim2.new(0, 10, 0, 30)
    Text.BackgroundTransparency = 1
    Text.Text = text
    Text.TextColor3 = Color3.fromRGB(200, 200, 220)
    Text.TextSize = 13
    Text.Font = Enum.Font.Gotham
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextWrapped = true
    Text.Parent = NotifFrame
    
    -- Animate in
    CreateTween(NotifFrame, {Size = UDim2.new(0, 300, 0, 60), Position = UDim2.new(1, -320, 1, -80)}, 0.4):Play()
    
    -- Auto dismiss
    task.delay(duration or 3, function()
        CreateTween(NotifFrame, {Position = UDim2.new(1, -320, 1, 20)}, 0.3):Play()
        task.wait(0.3)
        NotifFrame:Destroy()
    end)
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(color1, color2)
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

-- Command Processing
function ProcessCommand(cmd)
    cmd = cmd:lower():gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    local args = {}
    for word in cmd:gmatch("%S+") do
        table.insert(args, word)
    end
    
    local command = args[1]
    
    if command == "fly" then
        MicUp:ToggleFlying()
        Notify("Command", "Flying " .. (Config.Flying.Enabled and "enabled" or "disabled"), 2)
    elseif command == "tp" or command == "tptool" then
        if Config.TPTool.Enabled then
            MicUp:RemoveTPTool()
            Config.TPTool.Enabled = false
            Notify("Command", "TP Tool removed", 2)
        else
            MicUp:CreateTPTool()
            Config.TPTool.Enabled = true
            Notify("Command", "TP Tool equipped", 2)
        end
    elseif command == "follow" then
        if args[2] then
            local targetPlayer = FindPlayer(args[2])
            if targetPlayer then
                MicUp:StartFollow(targetPlayer)
                Notify("Command", "Following " .. targetPlayer.Name, 2)
            else
                Notify("Error", "Player not found", 2, Color3.fromRGB(255, 80, 80))
            end
        else
            MicUp:StopFollow()
            Notify("Command", "Stopped following", 2)
        end
    elseif command == "orbit" then
        if args[2] then
            local targetPlayer = FindPlayer(args[2])
            if targetPlayer then
                MicUp:StartOrbit(targetPlayer)
                Notify("Command", "Orbiting " .. targetPlayer.Name, 2)
            else
                Notify("Error", "Player not found", 2, Color3.fromRGB(255, 80, 80))
            end
        else
            MicUp:StopOrbit()
            Notify("Command", "Stopped orbiting", 2)
        end
    elseif command == "spin" then
        MicUp:ToggleSpin()
        Notify("Command", "Spin " .. (Config.Spin.Enabled and "enabled" or "disabled"), 2)
    elseif command == "sit" then
        MicUp:ToggleSit()
        Notify("Command", "Sit " .. (Config.Sit.Enabled and "enabled" or "disabled"), 2)
    elseif command == "baseplate" or command == "bp" then
        MicUp:ToggleBaseplate()
        Notify("Command", "Baseplate " .. (Config.Baseplate.Enabled and "enabled" or "disabled"), 2)
    elseif command == "voice" then
        Config.Voice.Enabled = not Config.Voice.Enabled
        if Config.Voice.Enabled then
            MicUp:BypassVoiceChat()
        end
        Notify("Command", "Voice bypass " .. (Config.Voice.Enabled and "enabled" or "disabled"), 2)
    elseif command == "help" then
        Notify("Commands", "fly, tp, follow [player], orbit [player], spin, sit, baseplate, voice", 5)
    else
        Notify("Error", "Unknown command. Type 'help' for list.", 2, Color3.fromRGB(255, 80, 80))
    end
end

function FindPlayer(name)
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(name) or player.DisplayName:lower():find(name) then
            return player
        end
    end
    return nil
end

-- Password Gateway
local function CreatePasswordGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MicUpDashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Notification Container
    NotificationContainer = Instance.new("Frame")
    NotificationContainer.Size = UDim2.new(1, 0, 1, 0)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.ZIndex = 1000
    NotificationContainer.Parent = ScreenGui
    
    -- Blur Effect
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 0
    BlurEffect.Parent = game:GetService("Lighting")
    
    CreateTween(BlurEffect, {Size = 20}, 0.5):Play()
    
    -- Password Frame
    PasswordFrame = Instance.new("Frame")
    PasswordFrame.Size = UDim2.new(0, 400, 0, 280)
    PasswordFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    PasswordFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    PasswordFrame.BorderSizePixel = 0
    PasswordFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = PasswordFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 200, 255)
    Stroke.Thickness = 3
    Stroke.Transparency = 0.3
    Stroke.Parent = PasswordFrame
    
    CreateGradient(PasswordFrame, Color3.fromRGB(20, 20, 30), Color3.fromRGB(30, 40, 60))
    
    -- Logo
    local Logo = Instance.new("Frame")
    Logo.Size = UDim2.new(0, 70, 0, 70)
    Logo.Position = UDim2.new(0.5, -35, 0, -35)
    Logo.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    Logo.BorderSizePixel = 0
    Logo.Parent = PasswordFrame
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 14)
    LogoCorner.Parent = Logo
    
    CreateGradient(Logo, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 255), 45)
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "🎤"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 36
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Parent = Logo
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 55)
    Title.BackgroundTransparency = 1
    Title.Text = "MIC UP"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 28
    Title.Font = Enum.Font.GothamBold
    Title.Parent = PasswordFrame
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0, 95)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Voice Chat Bypass & Movement Hub"
    Subtitle.TextColor3 = Color3.fromRGB(150, 170, 200)
    Subtitle.TextSize = 13
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = PasswordFrame
    
    -- Input Frame
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(0.85, 0, 0, 45)
    InputFrame.Position = UDim2.new(0.075, 0, 0, 140)
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
    PasswordInput.TextSize = 15
    PasswordInput.Font = Enum.Font.Gotham
    PasswordInput.TextXAlignment = Enum.TextXAlignment.Left
    PasswordInput.ClearTextOnFocus = false
    PasswordInput.Parent = InputFrame
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Size = UDim2.new(0.85, 0, 0, 45)
    SubmitButton.Position = UDim2.new(0.075, 0, 0, 200)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "AUTHENTICATE"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 16
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = PasswordFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = SubmitButton
    
    CreateGradient(SubmitButton, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 255), 45)
    
    -- Submit Function
    local function CheckPassword()
        if PasswordInput.Text == Config.Password then
            Authenticated = true
            Notify("Mic Up", "Access Granted!", 3, Color3.fromRGB(50, 200, 100))
            
            CreateTween(PasswordFrame, {Size = UDim2.new(0, 400, 0, 0), Position = UDim2.new(0.5, -200, 0.5, 0)}, 0.5):Play()
            CreateTween(BlurEffect, {Size = 0}, 0.5):Play()
            
            task.wait(0.5)
            PasswordFrame:Destroy()
            BlurEffect:Destroy()
            CreateDashboard()
        else
            Notify("Mic Up", "Invalid Password!", 3, Color3.fromRGB(255, 80, 80))
            PasswordInput.Text = ""
            
            -- Shake
            for i = 1, 3 do
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -210, 0.5, -140)}, 0.05):Play()
                task.wait(0.05)
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -190, 0.5, -140)}, 0.05):Play()
                task.wait(0.05)
            end
            PasswordFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
            
            CreateTween(InputStroke, {Color = Color3.fromRGB(255, 50, 50)}, 0.2):Play()
            task.wait(0.5)
            CreateTween(InputStroke, {Color = Color3.fromRGB(60, 60, 80)}, 0.3):Play()
        end
    end
    
    SubmitButton.MouseButton1Click:Connect(CheckPassword)
    PasswordInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then CheckPassword() end
    end)
    
    SubmitButton.MouseEnter:Connect(function()
        CreateTween(SubmitButton, {Size = UDim2.new(0.87, 0, 0, 47)}, 0.2):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        CreateTween(SubmitButton, {Size = UDim2.new(0.85, 0, 0, 45)}, 0.2):Play()
    end)
    
    ScreenGui.Parent = PlayerGui
end

-- Dashboard Creation
function CreateDashboard()
    DashboardFrame = Instance.new("Frame")
    DashboardFrame.Name = "Dashboard"
    DashboardFrame.Size = UDim2.new(0, 750, 0, 550)
    DashboardFrame.Position = UDim2.new(0.5, -375, 1.5, 0)
    DashboardFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    DashboardFrame.BorderSizePixel = 0
    DashboardFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = DashboardFrame
    
    CreateGradient(DashboardFrame, Color3.fromRGB(15, 15, 25), Color3.fromRGB(25, 35, 50))
    
    CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -375, 0.5, -275)}, 0.6):Play()
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = DashboardFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 16)
    TopCorner.Parent = TopBar
    
    local TopFill = Instance.new("Frame")
    TopFill.Size = UDim2.new(1, 0, 0, 28)
    TopFill.Position = UDim2.new(0, 0, 1, -28)
    TopFill.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TopFill.BorderSizePixel = 0
    TopFill.Parent = TopBar
    
    -- Logo
    local TopLogo = Instance.new("TextLabel")
    TopLogo.Size = UDim2.new(0, 40, 0, 40)
    TopLogo.Position = UDim2.new(0, 12, 0.5, -20)
    TopLogo.BackgroundTransparency = 1
    TopLogo.Text = "🎤"
    TopLogo.TextSize = 24
    TopLogo.Font = Enum.Font.GothamBold
    TopLogo.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 60, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Mic Up Dashboard"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Toggle GUI Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 35, 0, 35)
    ToggleButton.Position = UDim2.new(1, -90, 0.5, -17.5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "—"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = TopBar
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        GUIVisible = not GUIVisible
        if GUIVisible then
            CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -375, 0.5, -275)}, 0.4):Play()
        else
            CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -375, 1.5, 0)}, 0.4):Play()
        end
    end)
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -45, 0.5, -17.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TopBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -375, 1.5, 0)}, 0.5):Play()
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
    
    -- Command Bar
    CommandBar = Instance.new("Frame")
    CommandBar.Size = UDim2.new(1, -20, 0, 40)
    CommandBar.Position = UDim2.new(0, 10, 0, 65)
    CommandBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    CommandBar.BorderSizePixel = 0
    CommandBar.Parent = DashboardFrame
    
    local CmdCorner = Instance.new("UICorner")
    CmdCorner.CornerRadius = UDim.new(0, 10)
    CmdCorner.Parent = CommandBar
    
    local CmdStroke = Instance.new("UIStroke")
    CmdStroke.Color = Color3.fromRGB(60, 60, 80)
    CmdStroke.Thickness = 2
    CmdStroke.Parent = CommandBar
    
    local CmdIcon = Instance.new("TextLabel")
    CmdIcon.Size = UDim2.new(0, 30, 1, 0)
    CmdIcon.Position = UDim2.new(0, 5, 0, 0)
    CmdIcon.BackgroundTransparency = 1
    CmdIcon.Text = ">"
    CmdIcon.TextColor3 = Color3.fromRGB(100, 200, 255)
    CmdIcon.TextSize = 18
    CmdIcon.Font = Enum.Font.GothamBold
    CmdIcon.Parent = CommandBar
    
    local CmdInput = Instance.new("TextBox")
    CmdInput.Size = UDim2.new(1, -40, 1, 0)
    CmdInput.Position = UDim2.new(0, 35, 0, 0)
    CmdInput.BackgroundTransparency = 1
    CmdInput.Text = ""
    CmdInput.PlaceholderText = "Type command... (e.g., fly, tp, follow [player])"
    CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CmdInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    CmdInput.TextSize = 14
    CmdInput.Font = Enum.Font.Gotham
    CmdInput.TextXAlignment = Enum.TextXAlignment.Left
    CmdInput.ClearTextOnFocus = false
    CmdInput.Parent = CommandBar
    
    -- Command Processing
    CmdInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and CmdInput.Text ~= "" then
            ProcessCommand(CmdInput.Text)
            CmdInput.Text = ""
        end
    end)
    
    -- Sidebar (Navigation)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -125)
    Sidebar.Position = UDim2.new(0, 10, 0, 115)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = DashboardFrame
    
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 8)
    SidebarList.Parent = Sidebar
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -180, 1, -125)
    ContentArea.Position = UDim2.new(0, 170, 0, 115)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = DashboardFrame
    
    -- Create Pages
    CreatePages(Sidebar, ContentArea)
    
    -- Make Draggable
    local dragging, dragInput, mousePos, framePos
    
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
    
    Notify("Mic Up", "Dashboard loaded! Use command bar or buttons.", 4)
end

-- Switch Page Function
function SwitchPage(pageName, sidebar)
    CurrentPage = pageName
    
    -- Hide all pages
    for name, page in pairs(Pages) do
        page.Visible = false
    end
    
    -- Show selected page
    if Pages[pageName] then
        Pages[pageName].Visible = true
    end
    
    -- Update sidebar buttons
    for _, button in ipairs(sidebar:GetChildren()) do
        if button:IsA("TextButton") then
            if button.Text == pageName then
                button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
                button.TextColor3 = Color3.fromRGB(200, 200, 220)
            end
        end
    end
end

-- Create Pages
function CreatePages(sidebar, contentArea)
    local pageNames = {"Home", "Voice", "Movement", "Players", "Settings"}
    
    for i, pageName in ipairs(pageNames) do
        -- Sidebar Button
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.BackgroundColor3 = (pageName == "Home") and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(25, 25, 40)
        Button.BorderSizePixel = 0
        Button.Text = pageName
        Button.TextColor3 = (pageName == "Home") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        Button.TextSize = 14
        Button.Font = Enum.Font.GothamBold
        Button.Parent = sidebar
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 10)
        BtnCorner.Parent = Button
        
        -- Page Frame
        local PageFrame = Instance.new("ScrollingFrame")
        PageFrame.Name = pageName .. "Page"
        PageFrame.Size = UDim2.new(1, 0, 1, 0)
        PageFrame.BackgroundTransparency = 1
        PageFrame.BorderSizePixel = 0
        PageFrame.ScrollBarThickness = 4
        PageFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageFrame.Visible = (pageName == "Home")
        PageFrame.Parent = contentArea
        
        local PageList = Instance.new("UIListLayout")
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 10)
        PageList.Parent = PageFrame
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
        
        Pages[pageName] = PageFrame
        
        -- Button Click
        Button.MouseButton1Click:Connect(function()
            SwitchPage(pageName, sidebar)
        end)
        
        Button.MouseEnter:Connect(function()
            if CurrentPage ~= pageName then
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.2):Play()
            end
        end)
        
        Button.MouseLeave:Connect(function()
            if CurrentPage ~= pageName then
                CreateTween(Button, {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}, 0.2):Play()
            end
        end)
    end
    
    -- Populate Pages
    PopulateHomePage(Pages["Home"])
    PopulateVoicePage(Pages["Voice"])
    PopulateMovementPage(Pages["Movement"])
    PopulatePlayersPage(Pages["Players"])
    PopulateSettingsPage(Pages["Settings"])
end

-- Create Toggle Function
local function CreateToggle(parent, name, description, callback, initialState)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 65)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 60)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(0.7, 0, 0, 15)
    Desc.Position = UDim2.new(0, 15, 0, 35)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(120, 120, 140)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 60, 0, 30)
    ToggleButton.Position = UDim2.new(1, -75, 0.5, -15)
    ToggleButton.BackgroundColor3 = initialState and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(40, 40, 55)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = ToggleButton
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 26, 0, 26)
    Indicator.Position = initialState and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = ToggleButton
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator
    
    local enabled = initialState or false
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if enabled then
            CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(100, 200, 255)}, 0.3):Play()
            CreateTween(Indicator, {Position = UDim2.new(1, -28, 0.5, -13)}, 0.3):Play()
            CreateTween(Stroke, {Color = Color3.fromRGB(100, 200, 255), Transparency = 0.3}, 0.3):Play()
        else
            CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.3):Play()
            CreateTween(Indicator, {Position = UDim2.new(0, 2, 0.5, -13)}, 0.3):Play()
            CreateTween(Stroke, {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}, 0.3):Play()
        end
        
        if callback then
            callback(enabled)
        end
    end)
end

-- Create Button Function
local function CreateButton(parent, name, description, callback, color)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 60)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -20, 0, 15)
    Desc.Position = UDim2.new(0, 10, 0, 35)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(120, 120, 140)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame
    
    Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    Button.MouseEnter:Connect(function()
        CreateTween(Frame, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.2):Play()
        CreateTween(Stroke, {Color = color or Color3.fromRGB(100, 200, 255), Transparency = 0.3}, 0.2):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        CreateTween(Frame, {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}, 0.2):Play()
        CreateTween(Stroke, {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}, 0.2):Play()
    end)
end

-- Populate Home Page
function PopulateHomePage(page)
    local Welcome = Instance.new("TextLabel")
    Welcome.Size = UDim2.new(1, 0, 0, 40)
    Welcome.BackgroundTransparency = 1
    Welcome.Text = "Welcome to Mic Up!"
    Welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
    Welcome.TextSize = 24
    Welcome.Font = Enum.Font.GothamBold
    Welcome.TextXAlignment = Enum.TextXAlignment.Left
    Welcome.Parent = page
    
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, 0, 0, 60)
    Info.BackgroundTransparency = 1
    Info.Text = "Voice chat bypass and advanced movement tools. Use the command bar or navigate through pages to access features."
    Info.TextColor3 = Color3.fromRGB(150, 170, 200)
    Info.TextSize = 13
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextWrapped = true
    Info.Parent = page
    
    CreateButton(page, "🚀 Quick Start: Flying", "Press F or click to toggle flying", function()
        MicUp:ToggleFlying()
        Notify("Flying", Config.Flying.Enabled and "Enabled" or "Disabled", 2)
    end)
    
    CreateButton(page, "🎤 Enable Voice Bypass", "Bypass voice chat suspension", function()
        Config.Voice.Enabled = true
        MicUp:BypassVoiceChat()
        Notify("Voice", "Bypass enabled", 2)
    end, Color3.fromRGB(100, 200, 255))
    
    CreateButton(page, "📍 Get TP Tool", "Equip teleport tool", function()
        MicUp:CreateTPTool()
        Config.TPTool.Enabled = true
        Notify("TP Tool", "Equipped", 2)
    end)
end

-- Populate Voice Page
function PopulateVoicePage(page)
    CreateToggle(page, "Voice Chat Bypass", "Bypass voice chat suspension", function(enabled)
        Config.Voice.Enabled = enabled
        if enabled then
            MicUp:BypassVoiceChat()
            Notify("Voice", "Bypass enabled", 2)
        else
            Notify("Voice", "Bypass disabled", 2)
        end
    end, Config.Voice.Enabled)
    
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, 0, 0, 80)
    Info.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Info.BorderSizePixel = 0
    Info.Text = "⚠️ Voice Bypass Status\n\nThis feature attempts to bypass voice chat restrictions. Effectiveness may vary."
    Info.TextColor3 = Color3.fromRGB(200, 200, 220)
    Info.TextSize = 12
    Info.Font = Enum.Font.Gotham
    Info.TextWrapped = true
    Info.Parent = page
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 12)
    InfoCorner.Parent = Info
end

-- Populate Movement Page
function PopulateMovementPage(page)
    CreateToggle(page, "Flying", "Fly around the map (Keybind: F)", function(enabled)
        if enabled then
            MicUp:StartFlying()
        else
            MicUp:StopFlying()
        end
        Notify("Flying", enabled and "Enabled" or "Disabled", 2)
    end, Config.Flying.Enabled)
    
    CreateToggle(page, "Spin", "Spin your character", function(enabled)
        if enabled then
            MicUp:StartSpin()
        else
            MicUp:StopSpin()
        end
        Notify("Spin", enabled and "Enabled" or "Disabled", 2)
    end, Config.Spin.Enabled)
    
    CreateToggle(page, "Sit", "Force sit your character", function(enabled)
        Config.Sit.Enabled = enabled
        MicUp:ToggleSit()
        Notify("Sit", enabled and "Enabled" or "Disabled", 2)
    end, Config.Sit.Enabled)
    
    CreateToggle(page, "Baseplate", "Create baseplate under you", function(enabled)
        if enabled then
            MicUp:CreateBaseplate()
        else
            MicUp:RemoveBaseplate()
        end
        Notify("Baseplate", enabled and "Enabled" or "Disabled", 2)
    end, Config.Baseplate.Enabled)
    
    CreateButton(page, "Get TP Tool", "Equip teleport tool (Keybind: T)", function()
        MicUp:CreateTPTool()
        Config.TPTool.Enabled = true
        Notify("TP Tool", "Equipped - Click anywhere to teleport", 2)
    end)
end

-- Populate Players Page
function PopulatePlayersPage(page)
    local PlayerList = Instance.new("Frame")
    PlayerList.Size = UDim2.new(1, 0, 0, 300)
    PlayerList.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    PlayerList.BorderSizePixel = 0
    PlayerList.Parent = page
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 12)
    ListCorner.Parent = PlayerList
    
    local ListScroll = Instance.new("ScrollingFrame")
    ListScroll.Size = UDim2.new(1, -10, 1, -10)
    ListScroll.Position = UDim2.new(0, 5, 0, 5)
    ListScroll.BackgroundTransparency = 1
    ListScroll.BorderSizePixel = 0
    ListScroll.ScrollBarThickness = 4
    ListScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListScroll.Parent = PlayerList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = ListScroll
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5)
    end)
    
    -- Populate player list
    local function UpdatePlayerList()
        ListScroll:ClearAllChildren()
        
        local NewLayout = Instance.new("UIListLayout")
        NewLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NewLayout.Padding = UDim.new(0, 5)
        NewLayout.Parent = ListScroll
        
        NewLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, NewLayout.AbsoluteContentSize.Y + 5)
        end)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local PlayerFrame = Instance.new("Frame")
                PlayerFrame.Size = UDim2.new(1, -5, 0, 40)
                PlayerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                PlayerFrame.BorderSizePixel = 0
                PlayerFrame.Parent = ListScroll
                
                local PFCorner = Instance.new("UICorner")
                PFCorner.CornerRadius = UDim.new(0, 8)
                PFCorner.Parent = PlayerFrame
                
                local PlayerName = Instance.new("TextLabel")
                PlayerName.Size = UDim2.new(0.5, 0, 1, 0)
                PlayerName.Position = UDim2.new(0, 10, 0, 0)
                PlayerName.BackgroundTransparency = 1
                PlayerName.Text = player.Name
                PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerName.TextSize = 13
                PlayerName.Font = Enum.Font.GothamBold
                PlayerName.TextXAlignment = Enum.TextXAlignment.Left
                PlayerName.Parent = PlayerFrame
                
                -- Follow Button
                local FollowBtn = Instance.new("TextButton")
                FollowBtn.Size = UDim2.new(0, 60, 0, 28)
                FollowBtn.Position = UDim2.new(1, -190, 0.5, -14)
                FollowBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
                FollowBtn.BorderSizePixel = 0
                FollowBtn.Text = "Follow"
                FollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                FollowBtn.TextSize = 11
                FollowBtn.Font = Enum.Font.GothamBold
                FollowBtn.Parent = PlayerFrame
                
                local FBCorner = Instance.new("UICorner")
                FBCorner.CornerRadius = UDim.new(0, 6)
                FBCorner.Parent = FollowBtn
                
                FollowBtn.MouseButton1Click:Connect(function()
                    MicUp:StartFollow(player)
                    Notify("Follow", "Following " .. player.Name, 2)
                end)
                
                -- Orbit Button
                local OrbitBtn = Instance.new("TextButton")
                OrbitBtn.Size = UDim2.new(0, 60, 0, 28)
                OrbitBtn.Position = UDim2.new(1, -125, 0.5, -14)
                OrbitBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                OrbitBtn.BorderSizePixel = 0
                OrbitBtn.Text = "Orbit"
                OrbitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                OrbitBtn.TextSize = 11
                OrbitBtn.Font = Enum.Font.GothamBold
                OrbitBtn.Parent = PlayerFrame
                
                local OBCorner = Instance.new("UICorner")
                OBCorner.CornerRadius = UDim.new(0, 6)
                OBCorner.Parent = OrbitBtn
                
                OrbitBtn.MouseButton1Click:Connect(function()
                    MicUp:StartOrbit(player)
                    Notify("Orbit", "Orbiting " .. player.Name, 2)
                end)
                
                -- TP Button
                local TPBtn = Instance.new("TextButton")
                TPBtn.Size = UDim2.new(0, 60, 0, 28)
                TPBtn.Position = UDim2.new(1, -60, 0.5, -14)
                TPBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
                TPBtn.BorderSizePixel = 0
                TPBtn.Text = "TP"
                TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TPBtn.TextSize = 11
                TPBtn.Font = Enum.Font.GothamBold
                TPBtn.Parent = PlayerFrame
                
                local TPCorner = Instance.new("UICorner")
                TPCorner.CornerRadius = UDim.new(0, 6)
                TPCorner.Parent = TPBtn
                
                TPBtn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                        Notify("Teleport", "Teleported to " .. player.Name, 2)
                    end
                end)
            end
        end
    end
    
    UpdatePlayerList()
    
    -- Refresh button
    CreateButton(page, "🔄 Refresh Player List", "Update the list of players", function()
        UpdatePlayerList()
        Notify("Players", "List refreshed", 2)
    end)
    
    CreateButton(page, "⏹️ Stop Follow/Orbit", "Stop following or orbiting", function()
        MicUp:StopFollow()
        MicUp:StopOrbit()
        Notify("Stopped", "All player tracking stopped", 2)
    end, Color3.fromRGB(255, 100, 100))
end

-- Populate Settings Page
function PopulateSettingsPage(page)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "Settings & Configuration"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = page
    
    -- Speed Settings
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Size = UDim2.new(1, 0, 0, 80)
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    SpeedFrame.BorderSizePixel = 0
    SpeedFrame.Parent = page
    
    local SpeedCorner = Instance.new("UICorner")
    SpeedCorner.CornerRadius = UDim.new(0, 12)
    SpeedCorner.Parent = SpeedFrame
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(0.7, 0, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 15, 0, 10)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Flying Speed"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 15
    SpeedLabel.Font = Enum.Font.GothamBold
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = SpeedFrame
    
    local SpeedValue = Instance.new("TextLabel")
    SpeedValue.Size = UDim2.new(0.3, 0, 0, 20)
    SpeedValue.Position = UDim2.new(0.7, 0, 0, 10)
    SpeedValue.BackgroundTransparency = 1
    SpeedValue.Text = tostring(Config.Flying.Speed)
    SpeedValue.TextColor3 = Color3.fromRGB(100, 200, 255)
    SpeedValue.TextSize = 15
    SpeedValue.Font = Enum.Font.GothamBold
    SpeedValue.TextXAlignment = Enum.TextXAlignment.Right
    SpeedValue.Parent = SpeedFrame
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Size = UDim2.new(1, -30, 0, 8)
    SpeedSlider.Position = UDim2.new(0, 15, 1, -20)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = SpeedFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SpeedSlider
    
    local SpeedFill = Instance.new("Frame")
    SpeedFill.Size = UDim2.new(Config.Flying.Speed / 200, 0, 1, 0)
    SpeedFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SpeedFill.BorderSizePixel = 0
    SpeedFill.Parent = SpeedSlider
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SpeedFill
    
    local dragging = false
    
    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = (mousePos.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            local value = math.floor(relativePos * 200)
            Config.Flying.Speed = value
            SpeedValue.Text = tostring(value)
            SpeedFill.Size = UDim2.new(relativePos, 0, 1, 0)
        end
    end)
    
    CreateButton(page, "📋 Command List", "View all available commands", function()
        Notify("Commands", "fly, tp, follow [player], orbit [player], spin, sit, baseplate, voice, help", 6)
    end)
    
    CreateButton(page, "🔄 Reset All", "Reset all features to default", function()
        MicUp:StopFlying()
        MicUp:StopFollow()
        MicUp:StopOrbit()
        MicUp:StopSpin()
        MicUp:RemoveBaseplate()
        MicUp:RemoveTPTool()
        Notify("Reset", "All features reset", 2)
    end, Color3.fromRGB(255, 100, 100))
end

-- Initialize
CreatePasswordGUI()
Notify("Mic Up", "Script loaded! Enter password to continue.", 5)
