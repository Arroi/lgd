--[[
    MK2 GUI - Murder Mystery 2 Interface
    Password Gateway + Feature Controls
]]

local CoreModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/MK2_MM2.lua"))()
local Config = CoreModule.Config
local MK2 = CoreModule.MK2

-- GUI Variables
local ScreenGui
local MainFrame
local PasswordFrame
local Authenticated = false

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

-- Create GUI
local function CreatePasswordGUI()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MK2_GUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Password Frame
    PasswordFrame = Instance.new("Frame")
    PasswordFrame.Name = "PasswordFrame"
    PasswordFrame.Size = UDim2.new(0, 400, 0, 250)
    PasswordFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    PasswordFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    PasswordFrame.BorderSizePixel = 0
    PasswordFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = PasswordFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 50, 50)
    UIStroke.Thickness = 2
    UIStroke.Parent = PasswordFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MK2 - Murder Mystery 2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.Parent = PasswordFrame
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0, 50)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Enter Password to Continue"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Parent = PasswordFrame
    
    -- Password Input
    local PasswordInput = Instance.new("TextBox")
    PasswordInput.Name = "PasswordInput"
    PasswordInput.Size = UDim2.new(0.8, 0, 0, 40)
    PasswordInput.Position = UDim2.new(0.1, 0, 0, 100)
    PasswordInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    PasswordInput.BorderSizePixel = 0
    PasswordInput.Text = ""
    PasswordInput.PlaceholderText = "Password..."
    PasswordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasswordInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    PasswordInput.TextSize = 16
    PasswordInput.Font = Enum.Font.Gotham
    PasswordInput.ClearTextOnFocus = false
    PasswordInput.Parent = PasswordFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = PasswordInput
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0.8, 0, 0, 40)
    SubmitButton.Position = UDim2.new(0.1, 0, 0, 160)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "SUBMIT"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 18
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = PasswordFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = SubmitButton
    
    -- Submit Function
    local function CheckPassword()
        local input = PasswordInput.Text
        
        if input == Config.Password then
            Authenticated = true
            Notify("MK2", "Authentication Successful!", 3)
            
            local tween = CreateTween(PasswordFrame, {Position = UDim2.new(0.5, -200, -0.5, 0)}, 0.5)
            tween:Play()
            
            task.wait(0.5)
            PasswordFrame:Destroy()
            CreateMainGUI()
        else
            Notify("MK2", "Invalid Password!", 3)
            PasswordInput.Text = ""
            
            -- Shake animation
            for i = 1, 3 do
                PasswordFrame.Position = UDim2.new(0.5, -210, 0.5, -125)
                task.wait(0.05)
                PasswordFrame.Position = UDim2.new(0.5, -190, 0.5, -125)
                task.wait(0.05)
            end
            PasswordFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
        end
    end
    
    SubmitButton.MouseButton1Click:Connect(CheckPassword)
    PasswordInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            CheckPassword()
        end
    end)
    
    -- Hover Effect
    SubmitButton.MouseEnter:Connect(function()
        CreateTween(SubmitButton, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}, 0.2):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        CreateTween(SubmitButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.2):Play()
    end)
    
    ScreenGui.Parent = PlayerGui
end

-- Create Main GUI
function CreateMainGUI()
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -250, 1.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 50, 50)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Animate in
    CreateTween(MainFrame, {Position = UDim2.new(0.5, -250, 0.5, -225)}, 0.5):Play()
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "MK2 - Murder Mystery 2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -45, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        CreateTween(MainFrame, {Position = UDim2.new(0.5, -250, 1.5, 0)}, 0.5):Play()
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
    
    -- Content Frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -70)
    ContentFrame.Position = UDim2.new(0, 10, 0, 60)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 6
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = ContentFrame
    
    -- Auto-resize canvas
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Create Toggle Function
    local function CreateToggle(name, description, configPath, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 60)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = ContentFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "Label"
        ToggleLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
        ToggleLabel.Position = UDim2.new(0, 15, 0, 5)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 16
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Name = "Description"
        ToggleDesc.Size = UDim2.new(0.7, 0, 0.5, 0)
        ToggleDesc.Position = UDim2.new(0, 15, 0.5, 0)
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Text = description
        ToggleDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        ToggleDesc.TextSize = 12
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDesc.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "Button"
        ToggleButton.Size = UDim2.new(0, 50, 0, 25)
        ToggleButton.Position = UDim2.new(1, -65, 0.5, -12.5)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = ToggleButton
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Name = "Indicator"
        ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
        ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -10.5)
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = ToggleButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator
        
        -- Get initial state
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
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ToggleIndicator.Position = UDim2.new(1, -23, 0.5, -10.5)
        end
        
        ToggleButton.MouseButton1Click:Connect(function()
            enabled = not enabled
            setConfigValue(enabled)
            
            if enabled then
                CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.2):Play()
                CreateTween(ToggleIndicator, {Position = UDim2.new(1, -23, 0.5, -10.5)}, 0.2):Play()
            else
                CreateTween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.2):Play()
                CreateTween(ToggleIndicator, {Position = UDim2.new(0, 2, 0.5, -10.5)}, 0.2):Play()
            end
            
            if callback then
                callback(enabled)
            end
        end)
    end
    
    -- Create Slider Function
    local function CreateSlider(name, description, configPath, min, max, increment)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name .. "Slider"
        SliderFrame.Size = UDim2.new(1, 0, 0, 70)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = ContentFrame
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "Label"
        SliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
        SliderLabel.Position = UDim2.new(0, 15, 0, 5)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = name
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 16
        SliderLabel.Font = Enum.Font.GothamBold
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local SliderValue = Instance.new("TextLabel")
        SliderValue.Name = "Value"
        SliderValue.Size = UDim2.new(0.3, 0, 0, 20)
        SliderValue.Position = UDim2.new(0.7, 0, 0, 5)
        SliderValue.BackgroundTransparency = 1
        SliderValue.Text = "0"
        SliderValue.TextColor3 = Color3.fromRGB(255, 50, 50)
        SliderValue.TextSize = 16
        SliderValue.Font = Enum.Font.GothamBold
        SliderValue.TextXAlignment = Enum.TextXAlignment.Right
        SliderValue.Parent = SliderFrame
        
        local SliderDesc = Instance.new("TextLabel")
        SliderDesc.Name = "Description"
        SliderDesc.Size = UDim2.new(1, -30, 0, 15)
        SliderDesc.Position = UDim2.new(0, 15, 0, 25)
        SliderDesc.BackgroundTransparency = 1
        SliderDesc.Text = description
        SliderDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        SliderDesc.TextSize = 12
        SliderDesc.Font = Enum.Font.Gotham
        SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
        SliderDesc.Parent = SliderFrame
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Name = "Bar"
        SliderBar.Size = UDim2.new(1, -30, 0, 6)
        SliderBar.Position = UDim2.new(0, 15, 1, -15)
        SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        SliderBar.BorderSizePixel = 0
        SliderBar.Parent = SliderFrame
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = SliderBar
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "Fill"
        SliderFill.Size = UDim2.new(0, 0, 1, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBar
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill
        
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
    
    -- ESP Section
    CreateToggle("ESP Enabled", "Toggle ESP visibility", {"ESP", "Enabled"})
    CreateToggle("Skeleton ESP", "Show player skeletons", {"ESP", "Skeleton"})
    CreateToggle("Box ESP", "Show player boxes", {"ESP", "Box"})
    CreateToggle("Tracer ESP", "Show tracers to players", {"ESP", "Tracers"})
    CreateToggle("Show Murderer", "Display murderer ESP", {"ESP", "ShowMurderer"})
    CreateToggle("Show Sheriff", "Display sheriff ESP", {"ESP", "ShowSheriff"})
    CreateToggle("Show Innocent", "Display innocent ESP", {"ESP", "ShowInnocent"})
    
    -- Aimbot Section
    CreateToggle("Aimbot Enabled", "Toggle aimbot", {"Aimbot", "Enabled"})
    CreateToggle("Show FOV Circle", "Display FOV circle", {"Aimbot", "ShowFOV"})
    CreateSlider("Aimbot FOV", "Field of view radius", {"Aimbot", "FOV"}, 50, 500, 10)
    CreateSlider("Aimbot Smoothness", "Aim smoothness (lower = faster)", {"Aimbot", "Smoothness"}, 0.01, 1, 0.01)
    
    -- Camlock Section
    CreateToggle("Camlock Enabled", "Toggle camlock (Press Q)", {"Camlock", "Enabled"})
    CreateToggle("Predict Movement", "Predict target movement", {"Camlock", "PredictMovement"})
    CreateSlider("Camlock Smoothness", "Camera smoothness", {"Camlock", "Smoothness"}, 0.01, 1, 0.01)
    CreateSlider("Prediction Strength", "Movement prediction strength", {"Camlock", "PredictionStrength"}, 0.01, 0.5, 0.01)
    
    -- Make draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Initialize
CreatePasswordGUI()

Notify("MK2", "Script loaded! Enter password to continue.", 5)
