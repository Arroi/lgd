--[[
    MK2 Dashboard V2 - Multi-Page Modern UI
    Features: Password Gateway, Multiple Pages, Coin Collector, Advanced Aimbot
]]

local CoreModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/MK2_MM2.lua"))()
local Config = CoreModule.Config
local MK2 = CoreModule.MK2

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
    Stroke.Color = Color3.fromRGB(255, 50, 80)
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

-- Get Player Role
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

-- Password Gateway
local function CreatePasswordGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MK2_Dashboard_V2"
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
    PasswordFrame.Size = UDim2.new(0, 450, 0, 300)
    PasswordFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    PasswordFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    PasswordFrame.BorderSizePixel = 0
    PasswordFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = PasswordFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 50, 80)
    Stroke.Thickness = 3
    Stroke.Transparency = 0.3
    Stroke.Parent = PasswordFrame
    
    CreateGradient(PasswordFrame, Color3.fromRGB(20, 20, 30), Color3.fromRGB(30, 40, 60))
    
    -- Logo
    local Logo = Instance.new("Frame")
    Logo.Size = UDim2.new(0, 80, 0, 80)
    Logo.Position = UDim2.new(0.5, -40, 0, -40)
    Logo.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    Logo.BorderSizePixel = 0
    Logo.Parent = PasswordFrame
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 16)
    LogoCorner.Parent = Logo
    
    CreateGradient(Logo, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "MK2"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 36
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Parent = Logo
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = "MURDER MYSTERY 2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 26
    Title.Font = Enum.Font.GothamBold
    Title.Parent = PasswordFrame
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0, 100)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Advanced Combat & Automation System"
    Subtitle.TextColor3 = Color3.fromRGB(150, 170, 200)
    Subtitle.TextSize = 13
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = PasswordFrame
    
    -- Input Frame
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(0.85, 0, 0, 50)
    InputFrame.Position = UDim2.new(0.075, 0, 0, 145)
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
    SubmitButton.Position = UDim2.new(0.075, 0, 0, 215)
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
        if PasswordInput.Text == Config.Password then
            Authenticated = true
            Notify("MK2", "Access Granted!", 3, Color3.fromRGB(50, 200, 100))
            
            CreateTween(PasswordFrame, {Size = UDim2.new(0, 450, 0, 0), Position = UDim2.new(0.5, -225, 0.5, 0)}, 0.5):Play()
            CreateTween(BlurEffect, {Size = 0}, 0.5):Play()
            
            task.wait(0.5)
            PasswordFrame:Destroy()
            BlurEffect:Destroy()
            CreateDashboard()
        else
            Notify("MK2", "Invalid Password!", 3, Color3.fromRGB(255, 80, 80))
            PasswordInput.Text = ""
            
            -- Shake
            for i = 1, 3 do
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -235, 0.5, -150)}, 0.05):Play()
                task.wait(0.05)
                CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -215, 0.5, -150)}, 0.05):Play()
                task.wait(0.05)
            end
            PasswordFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
            
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
        CreateTween(SubmitButton, {Size = UDim2.new(0.87, 0, 0, 52)}, 0.2):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        CreateTween(SubmitButton, {Size = UDim2.new(0.85, 0, 0, 50)}, 0.2):Play()
    end)
    
    ScreenGui.Parent = PlayerGui
end

-- Dashboard Creation
function CreateDashboard()
    DashboardFrame = Instance.new("Frame")
    DashboardFrame.Name = "Dashboard"
    DashboardFrame.Size = UDim2.new(0, 800, 0, 550)
    DashboardFrame.Position = UDim2.new(0.5, -400, 1.5, 0)
    DashboardFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    DashboardFrame.BorderSizePixel = 0
    DashboardFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = DashboardFrame
    
    CreateGradient(DashboardFrame, Color3.fromRGB(15, 15, 25), Color3.fromRGB(25, 35, 50))
    
    CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -400, 0.5, -275)}, 0.6):Play()
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
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
    
    -- Logo
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
    TopLogoText.TextSize = 20
    TopLogoText.Font = Enum.Font.GothamBold
    TopLogoText.Parent = TopLogo
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 65, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MK2 Dashboard"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
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
            CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -400, 0.5, -275)}, 0.4):Play()
        else
            CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -400, 1.5, 0)}, 0.4):Play()
        end
    end)
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -45, 0.5, -17.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
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
        CreateTween(DashboardFrame, {Position = UDim2.new(0.5, -400, 1.5, 0)}, 0.5):Play()
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
    
    -- Sidebar (Navigation)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -80)
    Sidebar.Position = UDim2.new(0, 10, 0, 70)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = DashboardFrame
    
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 8)
    SidebarList.Parent = Sidebar
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -190, 1, -80)
    ContentArea.Position = UDim2.new(0, 180, 0, 70)
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
    
    Notify("MK2", "Dashboard loaded! Navigate through pages.", 4)
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
                button.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
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
    local pageNames = {"Home", "Aimbot", "Combat", "ESP", "Coins", "Settings"}
    
    for i, pageName in ipairs(pageNames) do
        -- Sidebar Button
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 45)
        Button.BackgroundColor3 = (pageName == "Home") and Color3.fromRGB(255, 50, 80) or Color3.fromRGB(25, 25, 40)
        Button.BorderSizePixel = 0
        Button.Text = pageName
        Button.TextColor3 = (pageName == "Home") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
        Button.TextSize = 15
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
        PageFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 80)
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
    PopulateAimbotPage(Pages["Aimbot"])
    PopulateCombatPage(Pages["Combat"])
    PopulateESPPage(Pages["ESP"])
    PopulateCoinsPage(Pages["Coins"])
    PopulateSettingsPage(Pages["Settings"])
end

-- Create Toggle Function
local function CreateToggle(parent, name, description, callback, initialState)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 70)
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
    ToggleButton.BackgroundColor3 = initialState and Color3.fromRGB(255, 50, 80) or Color3.fromRGB(40, 40, 55)
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
    
    if initialState then
        CreateGradient(ToggleButton, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
    end
    
    local enabled = initialState or false
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if enabled then
            CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 80)}, 0.3):Play()
            CreateTween(Indicator, {Position = UDim2.new(1, -28, 0.5, -13)}, 0.3):Play()
            CreateTween(Stroke, {Color = Color3.fromRGB(255, 50, 80), Transparency = 0.3}, 0.3):Play()
            CreateGradient(ToggleButton, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
        else
            CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.3):Play()
            CreateTween(Indicator, {Position = UDim2.new(0, 2, 0.5, -13)}, 0.3):Play()
            CreateTween(Stroke, {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}, 0.3):Play()
            for _, child in ipairs(ToggleButton:GetChildren()) do
                if child:IsA("UIGradient") then
                    child:Destroy()
                end
            end
        end
        
        if callback then
            callback(enabled)
        end
    end)
end

-- Create Button Function
local function CreateButton(parent, name, description, callback, color)
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
        CreateTween(Stroke, {Color = color or Color3.fromRGB(255, 50, 80), Transparency = 0.3}, 0.2):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        CreateTween(Frame, {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}, 0.2):Play()
        CreateTween(Stroke, {Color = Color3.fromRGB(40, 40, 60), Transparency = 0.5}, 0.2):Play()
    end)
end

-- Create Dropdown Function
local function CreateDropdown(parent, name, description, options, currentValue, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 70)
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
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 15, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(0.6, 0, 0, 15)
    Desc.Position = UDim2.new(0, 15, 0, 35)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(120, 120, 140)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0, 150, 0, 35)
    DropdownButton.Position = UDim2.new(1, -165, 0.5, -17.5)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Text = currentValue
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 13
    DropdownButton.Font = Enum.Font.GothamBold
    DropdownButton.Parent = Frame
    
    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 8)
    DropCorner.Parent = DropdownButton
    
    local dropdownOpen = false
    local DropdownList
    
    DropdownButton.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if DropdownList then
                DropdownList:Destroy()
                dropdownOpen = false
            end
        else
            DropdownList = Instance.new("Frame")
            DropdownList.Size = UDim2.new(0, 150, 0, #options * 30)
            DropdownList.Position = UDim2.new(1, -165, 1, 5)
            DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            DropdownList.BorderSizePixel = 0
            DropdownList.ZIndex = 10
            DropdownList.Parent = Frame
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 8)
            ListCorner.Parent = DropdownList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = DropdownList
            
            for _, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = option
                OptionButton.TextColor3 = Color3.fromRGB(200, 200, 220)
                OptionButton.TextSize = 12
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = DropdownList
                
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = option
                    if callback then
                        callback(option)
                    end
                    DropdownList:Destroy()
                    dropdownOpen = false
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 80)}, 0.2):Play()
                    CreateTween(OptionButton, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    CreateTween(OptionButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 45)}, 0.2):Play()
                    CreateTween(OptionButton, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.2):Play()
                end)
            end
            
            dropdownOpen = true
        end
    end)
end

-- Create Slider Function
local function CreateSlider(parent, name, description, min, max, current, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 80)
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
    
    local Value = Instance.new("TextLabel")
    Value.Size = UDim2.new(0.3, 0, 0, 20)
    Value.Position = UDim2.new(0.7, 0, 0, 10)
    Value.BackgroundTransparency = 1
    Value.Text = tostring(current)
    Value.TextColor3 = Color3.fromRGB(255, 50, 80)
    Value.TextSize = 15
    Value.Font = Enum.Font.GothamBold
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.Parent = Frame
    
    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -30, 0, 15)
    Desc.Position = UDim2.new(0, 15, 0, 32)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(120, 120, 140)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -30, 0, 8)
    SliderBar.Position = UDim2.new(0, 15, 1, -20)
    SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Frame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    CreateGradient(SliderFill, Color3.fromRGB(255, 50, 80), Color3.fromRGB(200, 30, 100), 45)
    
    local dragging = false
    
    SliderBar.InputBegan:Connect(function(input)
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
            local relativePos = (mousePos.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            local value = math.floor(min + (max - min) * relativePos)
            Value.Text = tostring(value)
            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            
            if callback then
                callback(value)
            end
        end
    end)
end

-- Populate Home Page
function PopulateHomePage(page)
    local Welcome = Instance.new("TextLabel")
    Welcome.Size = UDim2.new(1, 0, 0, 40)
    Welcome.BackgroundTransparency = 1
    Welcome.Text = "Welcome to MK2!"
    Welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
    Welcome.TextSize = 24
    Welcome.Font = Enum.Font.GothamBold
    Welcome.TextXAlignment = Enum.TextXAlignment.Left
    Welcome.Parent = page
    
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, 0, 0, 60)
    Info.BackgroundTransparency = 1
    Info.Text = "Advanced Murder Mystery 2 combat system with aimbot, ESP, camlock, and coin collection. Navigate through pages to configure features."
    Info.TextColor3 = Color3.fromRGB(150, 170, 200)
    Info.TextSize = 13
    Info.Font = Enum.Font.Gotham
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextWrapped = true
    Info.Parent = page
    
    CreateButton(page, "🎯 Quick Start: Aimbot", "Press E or toggle in Aimbot page", function()
        MK2:ToggleAimbot()
        Notify("Aimbot", Config.Aimbot.Enabled and "Enabled" or "Disabled", 2)
    end)
    
    CreateButton(page, "👁️ Enable ESP", "See all players through walls", function()
        Config.ESP.Enabled = not Config.ESP.Enabled
        Notify("ESP", Config.ESP.Enabled and "Enabled" or "Disabled", 2)
    end, Color3.fromRGB(100, 200, 255))
    
    CreateButton(page, "🪙 Start Coin Collection", "Auto-collect coins (max 40)", function()
        MK2:ToggleCoinCollection()
        Notify("Coins", Config.CoinCollector.Enabled and "Started" or "Stopped", 2)
    end, Color3.fromRGB(255, 200, 50))
end

-- Populate Aimbot Page
function PopulateAimbotPage(page)
    CreateToggle(page, "Aimbot", "Auto-aim at targets (Key: E)", function(enabled)
        Config.Aimbot.Enabled = enabled
        Notify("Aimbot", enabled and "Enabled" or "Disabled", 2)
    end, Config.Aimbot.Enabled)
    
    CreateToggle(page, "Show FOV Circle", "Display aimbot field of view", function(enabled)
        Config.Aimbot.ShowFOV = enabled
    end, Config.Aimbot.ShowFOV)
    
    CreateToggle(page, "Visibility Check", "Only target visible players", function(enabled)
        Config.Aimbot.VisibilityCheck = enabled
    end, Config.Aimbot.VisibilityCheck)
    
    CreateToggle(page, "Prioritize Murderer", "Target murderer first", function(enabled)
        Config.Aimbot.PrioritizeMurderer = enabled
    end, Config.Aimbot.PrioritizeMurderer)
    
    CreateToggle(page, "Ping Compensation", "Compensate for 200-300ms ping", function(enabled)
        Config.Aimbot.PingCompensation = enabled
    end, Config.Aimbot.PingCompensation)
    
    CreateDropdown(page, "Target Part", "Select body part to aim at", 
        Config.Aimbot.TargetParts, 
        Config.Aimbot.TargetPart, 
        function(value)
            Config.Aimbot.TargetPart = value
            Notify("Aimbot", "Target: " .. value, 2)
        end)
    
    CreateSlider(page, "FOV Size", "Field of view radius (pixels)", 50, 500, Config.Aimbot.FOV, function(value)
        Config.Aimbot.FOV = value
    end)
    
    CreateSlider(page, "Smoothness", "Lower = faster aim (0.01-1)", 1, 100, math.floor(Config.Aimbot.Smoothness * 1000), function(value)
        Config.Aimbot.Smoothness = value / 1000
    end)
    
    CreateSlider(page, "Prediction", "Movement prediction multiplier", 1, 50, math.floor(Config.Aimbot.PredictionMultiplier * 100), function(value)
        Config.Aimbot.PredictionMultiplier = value / 100
    end)
end

-- Populate Combat Page
function PopulateCombatPage(page)
    CreateToggle(page, "Camlock", "Lock camera to target (Key: Q)", function(enabled)
        Config.Camlock.Enabled = enabled
        if not enabled then
            Config.Camlock.Locked = false
            Config.Camlock.Target = nil
        end
        Notify("Camlock", enabled and "Enabled" or "Disabled", 2)
    end, Config.Camlock.Enabled)
    
    CreateToggle(page, "Predict Movement", "Enable movement prediction", function(enabled)
        Config.Camlock.PredictMovement = enabled
    end, Config.Camlock.PredictMovement)
    
    CreateToggle(page, "Prioritize Murderer", "Lock to murderer first", function(enabled)
        Config.Camlock.PrioritizeMurderer = enabled
    end, Config.Camlock.PrioritizeMurderer)
    
    CreateSlider(page, "Camlock Smoothness", "Camera tracking speed", 1, 100, math.floor(Config.Camlock.Smoothness * 100), function(value)
        Config.Camlock.Smoothness = value / 100
    end)
    
    CreateSlider(page, "Prediction Strength", "Movement prediction amount", 1, 50, math.floor(Config.Camlock.PredictionStrength * 100), function(value)
        Config.Camlock.PredictionStrength = value / 100
    end)
    
    CreateButton(page, "🔓 Unlock Current Target", "Release camlock target", function()
        Config.Camlock.Locked = false
        Config.Camlock.Target = nil
        Notify("Camlock", "Target unlocked", 2)
    end, Color3.fromRGB(255, 100, 100))
end

-- Populate ESP Page
function PopulateESPPage(page)
    CreateToggle(page, "ESP Master", "Toggle all ESP features", function(enabled)
        Config.ESP.Enabled = enabled
        Notify("ESP", enabled and "Enabled" or "Disabled", 2)
    end, Config.ESP.Enabled)
    
    CreateToggle(page, "Skeleton ESP", "Show player skeletons", function(enabled)
        Config.ESP.Skeleton = enabled
    end, Config.ESP.Skeleton)
    
    CreateToggle(page, "Box ESP", "Show bounding boxes", function(enabled)
        Config.ESP.Box = enabled
    end, Config.ESP.Box)
    
    CreateToggle(page, "Tracer ESP", "Draw lines to players", function(enabled)
        Config.ESP.Tracers = enabled
    end, Config.ESP.Tracers)
    
    CreateToggle(page, "Show Murderer", "Display murderer ESP", function(enabled)
        Config.ESP.ShowMurderer = enabled
    end, Config.ESP.ShowMurderer)
    
    CreateToggle(page, "Show Sheriff", "Display sheriff ESP", function(enabled)
        Config.ESP.ShowSheriff = enabled
    end, Config.ESP.ShowSheriff)
    
    CreateToggle(page, "Show Innocent", "Display innocent ESP", function(enabled)
        Config.ESP.ShowInnocent = enabled
    end, Config.ESP.ShowInnocent)
    
    CreateSlider(page, "ESP Thickness", "Line thickness (1-5)", 1, 5, Config.ESP.Thickness, function(value)
        Config.ESP.Thickness = value
    end)
end

-- Populate Coins Page
function PopulateCoinsPage(page)
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 80)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    StatusLabel.BorderSizePixel = 0
    StatusLabel.Text = "Coins Collected: 0 / 40"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    StatusLabel.TextSize = 20
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Parent = page
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 12)
    StatusCorner.Parent = StatusLabel
    
    -- Update status
    task.spawn(function()
        while StatusLabel and StatusLabel.Parent do
            StatusLabel.Text = string.format("Coins Collected: %d / %d", Config.CoinCollector.CollectedCoins, Config.CoinCollector.MaxCoins)
            task.wait(0.5)
        end
    end)
    
    CreateToggle(page, "Auto Collect Coins", "Automatically collect coins", function(enabled)
        MK2:ToggleCoinCollection()
        Notify("Coins", enabled and "Started collecting" or "Stopped", 2)
    end, Config.CoinCollector.Enabled)
    
    CreateSlider(page, "Max Coins", "Maximum coins to collect", 1, 100, Config.CoinCollector.MaxCoins, function(value)
        Config.CoinCollector.MaxCoins = value
    end)
    
    CreateSlider(page, "Collection Speed", "Delay between coins (seconds)", 1, 20, math.floor(Config.CoinCollector.Speed * 10), function(value)
        Config.CoinCollector.Speed = value / 10
    end)
    
    CreateButton(page, "🔄 Reset Counter", "Reset collected coins counter", function()
        Config.CoinCollector.CollectedCoins = 0
        Notify("Coins", "Counter reset", 2)
    end, Color3.fromRGB(100, 150, 255))
    
    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, 0, 0, 80)
    Info.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Info.BorderSizePixel = 0
    Info.Text = "⚠️ Coin Collection Info\n\nAutomatically teleports to coins in ReplicatedStorage.Coins folder. Stops at max limit."
    Info.TextColor3 = Color3.fromRGB(200, 200, 220)
    Info.TextSize = 12
    Info.Font = Enum.Font.Gotham
    Info.TextWrapped = true
    Info.Parent = page
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 12)
    InfoCorner.Parent = Info
end

-- Populate Settings Page
function PopulateSettingsPage(page)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "Settings & Information"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = page
    
    CreateToggle(page, "Speed Modifier", "Undetectable speed boost", function(enabled)
        MK2:ToggleSpeedModifier()
        Notify("Speed", enabled and "Enabled" or "Disabled", 2)
    end, Config.Speed.Enabled)
    
    CreateSlider(page, "Speed Multiplier", "Movement speed multiplier (1-5x)", 1, 5, Config.Speed.Multiplier, function(value)
        Config.Speed.Multiplier = value
    end)
    
    CreateButton(page, "📋 Keybinds", "E = Aimbot | Q = Camlock", function()
        Notify("Keybinds", "E = Toggle Aimbot\nQ = Toggle Camlock", 5)
    end)
    
    CreateButton(page, "🔄 Reset All Settings", "Reset to default configuration", function()
        Config.Aimbot.FOV = 100
        Config.Aimbot.Smoothness = 0.05
        Config.Camlock.Smoothness = 0.15
        Config.CoinCollector.MaxCoins = 40
        Notify("Settings", "Reset to defaults", 2)
    end, Color3.fromRGB(255, 100, 100))
    
    CreateButton(page, "ℹ️ About MK2", "Script information", function()
        Notify("MK2 V2", "Advanced MM2 script with aimbot, ESP, camlock, and coin collection. Educational purposes only.", 5)
    end, Color3.fromRGB(100, 200, 255))
    
    local InfoBox = Instance.new("TextLabel")
    InfoBox.Size = UDim2.new(1, 0, 0, 140)
    InfoBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    InfoBox.BorderSizePixel = 0
    InfoBox.Text = "📊 Performance Info\n\n• Ping Compensation: Optimized for 200-300ms\n• Aimbot: High accuracy with prediction\n• ESP: Lightweight rendering\n• Coins: Auto-stops at limit\n• Speed: Undetectable BodyVelocity method"
    InfoBox.TextColor3 = Color3.fromRGB(200, 200, 220)
    InfoBox.TextSize = 12
    InfoBox.Font = Enum.Font.Gotham
    InfoBox.TextWrapped = true
    InfoBox.TextYAlignment = Enum.TextYAlignment.Top
    InfoBox.Parent = page
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 12)
    InfoCorner.Parent = InfoBox
end

-- Initialize
CreatePasswordGUI()
Notify("MK2", "Script loaded! Enter password to continue.", 5)
