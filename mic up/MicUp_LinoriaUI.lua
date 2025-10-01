--[[
    Mic Up - LinoriaLib Inspired UI
    Features: Modern UI, Voice Bypass, Admin Commands, Fixed Flying
]]

-- Load Core
local CoreModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Arroi/lgd/refs/heads/main/mic%20up/MicUp_Core.lua"))()
local Config = CoreModule.Config
local MicUp = CoreModule.MicUp

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Variables
local Library = {}
local ScreenGui
local MainFrame
local Tabs = {}
local CurrentTab
local Notifications = {}

-- Theme Colors (LinoriaLib Style)
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(100, 100, 255),
    AccentDark = Color3.fromRGB(80, 80, 200),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 190),
    Border = Color3.fromRGB(40, 40, 50),
    Success = Color3.fromRGB(50, 200, 100),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 200, 50)
}

-- Utility Functions
local function Tween(obj, props, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props)
    tween:Play()
    return tween
end

local function Notify(title, text, duration, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 0)
    notif.Position = UDim2.new(1, -300, 1, 20)
    notif.BackgroundColor3 = color or Theme.Secondary
    notif.BorderSizePixel = 0
    notif.ZIndex = 1000
    notif.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notif
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 18)
    textLabel.Position = UDim2.new(0, 10, 0, 28)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.TextDark
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = notif
    
    Tween(notif, {Size = UDim2.new(0, 280, 0, 55), Position = UDim2.new(1, -300, 1, -75)}, 0.3)
    
    task.delay(duration or 3, function()
        Tween(notif, {Position = UDim2.new(1, -300, 1, 20)}, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end)
    
    table.insert(Notifications, notif)
end

-- Create Main Window
function Library:CreateWindow(title)
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MicUpLinoria"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    -- Main Container
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = MainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Border
    mainStroke.Thickness = 1
    mainStroke.Parent = MainFrame
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = MainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Theme.Secondary
    topBar.BorderSizePixel = 0
    topBar.Parent = MainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 6)
    topCorner.Parent = topBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 25)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Theme.Error}, 0.2)
    end)
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 140, 1, -50)
    tabContainer.Position = UDim2.new(0, 0, 0, 43)
    tabContainer.BackgroundColor3 = Theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = MainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer
    
    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 4)
    tabList.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 6)
    tabPadding.PaddingRight = UDim.new(0, 6)
    tabPadding.PaddingTop = UDim.new(0, 6)
    tabPadding.PaddingBottom = UDim.new(0, 6)
    tabPadding.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -155, 1, -50)
    contentContainer.Position = UDim2.new(0, 148, 0, 43)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = MainFrame
    
    -- Make draggable
    local dragging, dragInput, mousePos, framePos
    
    topBar.InputBegan:Connect(function(input)
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
    
    topBar.InputChanged:Connect(function(input)
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
    
    return {
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = Tabs
    }
end

-- Create Tab
function Library:CreateTab(name)
    local tab = {}
    
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 32)
    tabButton.BackgroundColor3 = Theme.Background
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Theme.TextDark
    tabButton.TextSize = 13
    tabButton.Font = Enum.Font.GothamBold
    tabButton.Parent = MainFrame.TabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = tabButton
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Theme.Accent
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = false
    tabContent.Parent = MainFrame.ContentContainer
    
    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 6)
    contentList.Parent = tabContent
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 6)
    contentPadding.PaddingRight = UDim.new(0, 6)
    contentPadding.PaddingTop = UDim.new(0, 6)
    contentPadding.PaddingBottom = UDim.new(0, 6)
    contentPadding.Parent = tabContent
    
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 12)
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Theme.Background
            t.Button.TextColor3 = Theme.TextDark
        end
        
        tabContent.Visible = true
        tabButton.BackgroundColor3 = Theme.Accent
        tabButton.TextColor3 = Theme.Text
        CurrentTab = name
    end)
    
    tabButton.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            Tween(tabButton, {BackgroundColor3 = Theme.Border}, 0.2)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            Tween(tabButton, {BackgroundColor3 = Theme.Background}, 0.2)
        end
    end)
    
    tab.Button = tabButton
    tab.Content = tabContent
    tab.Name = name
    
    Tabs[name] = tab
    
    if #Tabs == 1 then
        tabButton.BackgroundColor3 = Theme.Accent
        tabButton.TextColor3 = Theme.Text
        tabContent.Visible = true
        CurrentTab = name
    end
    
    function tab:AddToggle(name, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 38)
        toggleFrame.BackgroundColor3 = Theme.Secondary
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = tabContent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.BackgroundColor3 = default and Theme.Accent or Theme.Border
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggle
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        indicator.BackgroundColor3 = Theme.Text
        indicator.BorderSizePixel = 0
        indicator.Parent = toggle
        
        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = indicator
        
        local enabled = default
        
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            
            if enabled then
                Tween(toggle, {BackgroundColor3 = Theme.Accent}, 0.2)
                Tween(indicator, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
            else
                Tween(toggle, {BackgroundColor3 = Theme.Border}, 0.2)
                Tween(indicator, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
            end
            
            if callback then
                callback(enabled)
            end
        end)
    end
    
    function tab:AddButton(name, callback)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, 0, 0, 35)
        buttonFrame.BackgroundColor3 = Theme.Secondary
        buttonFrame.BorderSizePixel = 0
        buttonFrame.Parent = tabContent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = buttonFrame
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = name
        button.TextColor3 = Theme.Text
        button.TextSize = 13
        button.Font = Enum.Font.GothamBold
        button.Parent = buttonFrame
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        button.MouseEnter:Connect(function()
            Tween(buttonFrame, {BackgroundColor3 = Theme.Accent}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            Tween(buttonFrame, {BackgroundColor3 = Theme.Secondary}, 0.2)
        end)
    end
    
    function tab:AddSlider(name, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundColor3 = Theme.Secondary
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = tabContent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = sliderFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Theme.Accent
        valueLabel.TextSize = 13
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, -20, 0, 6)
        sliderBar.Position = UDim2.new(0, 10, 1, -15)
        sliderBar.BackgroundColor3 = Theme.Border
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = sliderFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = sliderBar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        
        local dragging = false
        
        sliderBar.InputBegan:Connect(function(input)
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
                local relativePos = (mousePos.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                relativePos = math.clamp(relativePos, 0, 1)
                
                local value = math.floor(min + (max - min) * relativePos)
                valueLabel.Text = tostring(value)
                fill.Size = UDim2.new(relativePos, 0, 1, 0)
                
                if callback then
                    callback(value)
                end
            end
        end)
    end
    
    function tab:AddDropdown(name, options, default, callback)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, 38)
        dropdownFrame.BackgroundColor3 = Theme.Secondary
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Parent = tabContent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = dropdownFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = dropdownFrame
        
        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(0, 120, 0, 28)
        dropdown.Position = UDim2.new(1, -125, 0.5, -14)
        dropdown.BackgroundColor3 = Theme.Border
        dropdown.BorderSizePixel = 0
        dropdown.Text = default or options[1]
        dropdown.TextColor3 = Theme.Text
        dropdown.TextSize = 12
        dropdown.Font = Enum.Font.Gotham
        dropdown.Parent = dropdownFrame
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 4)
        dropCorner.Parent = dropdown
        
        local dropdownOpen = false
        local dropdownList
        
        dropdown.MouseButton1Click:Connect(function()
            if dropdownOpen then
                if dropdownList then
                    dropdownList:Destroy()
                    dropdownOpen = false
                end
            else
                dropdownList = Instance.new("Frame")
                dropdownList.Size = UDim2.new(0, 120, 0, #options * 26)
                dropdownList.Position = UDim2.new(1, -125, 1, 5)
                dropdownList.BackgroundColor3 = Theme.Background
                dropdownList.BorderSizePixel = 0
                dropdownList.ZIndex = 100
                dropdownList.Parent = dropdownFrame
                
                local listCorner = Instance.new("UICorner")
                listCorner.CornerRadius = UDim.new(0, 4)
                listCorner.Parent = dropdownList
                
                local listStroke = Instance.new("UIStroke")
                listStroke.Color = Theme.Border
                listStroke.Thickness = 1
                listStroke.Parent = dropdownList
                
                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Parent = dropdownList
                
                for _, option in ipairs(options) do
                    local optionBtn = Instance.new("TextButton")
                    optionBtn.Size = UDim2.new(1, 0, 0, 26)
                    optionBtn.BackgroundColor3 = Theme.Background
                    optionBtn.BorderSizePixel = 0
                    optionBtn.Text = option
                    optionBtn.TextColor3 = Theme.TextDark
                    optionBtn.TextSize = 12
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.Parent = dropdownList
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        dropdown.Text = option
                        if callback then
                            callback(option)
                        end
                        dropdownList:Destroy()
                        dropdownOpen = false
                    end)
                    
                    optionBtn.MouseEnter:Connect(function()
                        Tween(optionBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, 0.2)
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        Tween(optionBtn, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDark}, 0.2)
                    end)
                end
                
                dropdownOpen = true
            end
        end)
    end
    
    function tab:AddLabel(text)
        local labelFrame = Instance.new("Frame")
        labelFrame.Size = UDim2.new(1, 0, 0, 30)
        labelFrame.BackgroundTransparency = 1
        labelFrame.Parent = tabContent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, 0)
        label.Position = UDim2.new(0, 5, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.TextDark
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.Parent = labelFrame
        
        return label
    end
    
    function tab:AddSection(name)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(1, 0, 0, 28)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.Parent = tabContent
        
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 3, 1, -6)
        line.Position = UDim2.new(0, 0, 0, 3)
        line.BackgroundColor3 = Theme.Accent
        line.BorderSizePixel = 0
        line.Parent = sectionFrame
        
        local lineCorner = Instance.new("UICorner")
        lineCorner.CornerRadius = UDim.new(1, 0)
        lineCorner.Parent = line
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -15, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sectionFrame
    end
    
    return tab
end

-- Password Protection
local function CreatePasswordGUI()
    local PasswordGui = Instance.new("ScreenGui")
    PasswordGui.Name = "MicUpPassword"
    PasswordGui.ResetOnSpawn = false
    PasswordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    PasswordGui.Parent = CoreGui
    
    -- Blur
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = game:GetService("Lighting")
    Tween(Blur, {Size = 15}, 0.5)
    
    -- Password Frame
    local PasswordFrame = Instance.new("Frame")
    PasswordFrame.Size = UDim2.new(0, 400, 0, 280)
    PasswordFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    PasswordFrame.BackgroundColor3 = Theme.Background
    PasswordFrame.BorderSizePixel = 0
    PasswordFrame.Parent = PasswordGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = PasswordFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Accent
    stroke.Thickness = 2
    stroke.Parent = PasswordFrame
    
    -- Enhanced gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(Theme.Background, Theme.Secondary)
    gradient.Rotation = 45
    gradient.Parent = PasswordFrame
    
    -- Logo
    local Logo = Instance.new("Frame")
    Logo.Size = UDim2.new(0, 70, 0, 70)
    Logo.Position = UDim2.new(0.5, -35, 0, -35)
    Logo.BackgroundColor3 = Theme.Accent
    Logo.BorderSizePixel = 0
    Logo.Parent = PasswordFrame
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 12)
    logoCorner.Parent = Logo
    
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "🎤"
    logoText.TextColor3 = Theme.Text
    logoText.TextSize = 36
    logoText.Font = Enum.Font.GothamBold
    logoText.Parent = Logo
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 55)
    title.BackgroundTransparency = 1
    title.Text = "MIC UP"
    title.TextColor3 = Theme.Text
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = PasswordFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 90)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "LinoriaLib Inspired UI"
    subtitle.TextColor3 = Theme.TextDark
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = PasswordFrame
    
    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, 0, 0, 15)
    version.Position = UDim2.new(0, 0, 1, -20)
    version.BackgroundTransparency = 1
    version.Text = "v3.0 | Undetected"
    version.TextColor3 = Theme.Accent
    version.TextSize = 11
    version.Font = Enum.Font.GothamBold
    version.Parent = PasswordFrame
    
    -- Input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0.85, 0, 0, 45)
    inputFrame.Position = UDim2.new(0.075, 0, 0, 130)
    inputFrame.BackgroundColor3 = Theme.Secondary
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = PasswordFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Theme.Border
    inputStroke.Thickness = 1
    inputStroke.Parent = inputFrame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = "Enter Password..."
    input.TextColor3 = Theme.Text
    input.PlaceholderColor3 = Theme.TextDark
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = inputFrame
    
    -- Submit Button
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.85, 0, 0, 45)
    submitBtn.Position = UDim2.new(0.075, 0, 0, 190)
    submitBtn.BackgroundColor3 = Theme.Accent
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "AUTHENTICATE"
    submitBtn.TextColor3 = Theme.Text
    submitBtn.TextSize = 16
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = PasswordFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = submitBtn
    
    local function CheckPassword()
        if input.Text == Config.Password then
            Tween(PasswordFrame, {Size = UDim2.new(0, 400, 0, 0), Position = UDim2.new(0.5, -200, 0.5, 0)}, 0.4)
            Tween(Blur, {Size = 0}, 0.4)
            task.wait(0.4)
            PasswordGui:Destroy()
            Blur:Destroy()
            InitializeUI()
        else
            input.Text = ""
            -- Shake animation
            for i = 1, 3 do
                Tween(PasswordFrame, {Position = UDim2.new(0.5, -210, 0.5, -140)}, 0.05)
                task.wait(0.05)
                Tween(PasswordFrame, {Position = UDim2.new(0.5, -190, 0.5, -140)}, 0.05)
                task.wait(0.05)
            end
            PasswordFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
            Tween(inputStroke, {Color = Theme.Error}, 0.2)
            task.wait(0.5)
            Tween(inputStroke, {Color = Theme.Border}, 0.2)
        end
    end
    
    submitBtn.MouseButton1Click:Connect(CheckPassword)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then CheckPassword() end
    end)
    
    submitBtn.MouseEnter:Connect(function()
        Tween(submitBtn, {BackgroundColor3 = Theme.AccentDark}, 0.2)
    end)
    
    submitBtn.MouseLeave:Connect(function()
        Tween(submitBtn, {BackgroundColor3 = Theme.Accent}, 0.2)
    end)
end

-- Initialize UI
function InitializeUI()
    local Window = Library:CreateWindow("🎤 Mic Up")

    -- Create Tabs
    local InfoTab = Library:CreateTab("Info")
    local HomeTab = Library:CreateTab("Home")
    local VoiceTab = Library:CreateTab("Voice")
    local MovementTab = Library:CreateTab("Movement")
    local AdminTab = Library:CreateTab("Admin")
    local SettingsTab = Library:CreateTab("Settings")
    
    -- Info Tab (Client Information)
    InfoTab:AddSection("Client Information")
    InfoTab:AddLabel("Script: Mic Up v3.0")
    InfoTab:AddLabel("UI: LinoriaLib Inspired")
    InfoTab:AddLabel("Developer: Arroi")
    InfoTab:AddLabel("Status: ✅ Active")
    
    InfoTab:AddSection("System Information")
    local playerLabel = InfoTab:AddLabel("Player: " .. LocalPlayer.Name)
    local displayLabel = InfoTab:AddLabel("Display: " .. LocalPlayer.DisplayName)
    local userIdLabel = InfoTab:AddLabel("UserID: " .. LocalPlayer.UserId)
    local accountAgeLabel = InfoTab:AddLabel("Account Age: " .. LocalPlayer.AccountAge .. " days")
    
    InfoTab:AddSection("Game Information")
    local gameLabel = InfoTab:AddLabel("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
    local placeIdLabel = InfoTab:AddLabel("Place ID: " .. game.PlaceId)
    local playersLabel = InfoTab:AddLabel("Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
    
    -- Update player count
    task.spawn(function()
        while task.wait(5) do
            if playersLabel then
                playersLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
            end
        end
    end)
    
    InfoTab:AddSection("Features")
    InfoTab:AddLabel("✅ Voice Chat Bypass (4 methods)")
    InfoTab:AddLabel("✅ Advanced Flying System")
    InfoTab:AddLabel("✅ Admin Commands")
    InfoTab:AddLabel("✅ Movement Tools")
    InfoTab:AddLabel("✅ LinoriaLib UI")
    
    InfoTab:AddSection("Credits")
    InfoTab:AddLabel("UI Design: LinoriaLib Inspired")
    InfoTab:AddLabel("Script: Arroi/lgd")
    InfoTab:AddLabel("Educational purposes only")

-- Home Tab
HomeTab:AddLabel("Welcome to Mic Up! Modern voice bypass and movement system.")
HomeTab:AddButton("🚀 Quick Start: Flying", function()
    MicUp:ToggleFlying()
    Notify("Flying", Config.Flying.Enabled and "Enabled" or "Disabled", 2, Theme.Success)
end)

HomeTab:AddButton("🎤 Enable Voice Bypass", function()
    Config.Voice.Enabled = true
    MicUp:BypassVoiceChat()
    Notify("Voice", "Bypass enabled", 2, Theme.Success)
end)

-- Voice Tab
VoiceTab:AddSection("Voice Chat Bypass")
VoiceTab:AddToggle("Voice Bypass", Config.Voice.Enabled, function(enabled)
    Config.Voice.Enabled = enabled
    if enabled then
        MicUp:BypassVoiceChat()
        Notify("Voice", "Bypass enabled", 2, Theme.Success)
    else
        Notify("Voice", "Bypass disabled", 2, Theme.Warning)
    end
end)

VoiceTab:AddLabel("⚠️ Advanced bypass methods enabled. May not work in all games.")

-- Movement Tab
MovementTab:AddSection("Flying")
MovementTab:AddToggle("Flying (F)", Config.Flying.Enabled, function(enabled)
    if enabled then
        MicUp:StartFlying()
    else
        MicUp:StopFlying()
    end
    Notify("Flying", enabled and "Enabled" or "Disabled", 2)
end)

MovementTab:AddSlider("Flying Speed", 10, 200, Config.Flying.Speed, function(value)
    Config.Flying.Speed = value
end)

MovementTab:AddSection("Teleportation")
MovementTab:AddButton("Get TP Tool (T)", function()
    MicUp:CreateTPTool()
    Config.TPTool.Enabled = true
    Notify("TP Tool", "Equipped - Click to teleport", 2)
end)

MovementTab:AddSection("Other Movement")
MovementTab:AddToggle("Spin", Config.Spin.Enabled, function(enabled)
    if enabled then
        MicUp:StartSpin()
    else
        MicUp:StopSpin()
    end
end)

MovementTab:AddSlider("Spin Speed", 1, 20, Config.Spin.Speed, function(value)
    Config.Spin.Speed = value
end)

MovementTab:AddToggle("Sit", Config.Sit.Enabled, function(enabled)
    MicUp:ToggleSit()
end)

MovementTab:AddToggle("Baseplate", Config.Baseplate.Enabled, function(enabled)
    if enabled then
        MicUp:CreateBaseplate()
    else
        MicUp:RemoveBaseplate()
    end
end)

-- Admin Tab
AdminTab:AddSection("Admin Commands")
AdminTab:AddLabel("Select a player and use admin commands")

local selectedPlayer = nil
local playerNames = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerNames, player.Name)
    end
end

AdminTab:AddDropdown("Select Player", playerNames, playerNames[1], function(value)
    selectedPlayer = Players:FindFirstChild(value)
end)

AdminTab:AddLabel("⚠️ Client-side commands only (FE compatible)")

AdminTab:AddButton("View Player", function()
    if selectedPlayer and selectedPlayer.Character then
        Workspace.CurrentCamera.CameraSubject = selectedPlayer.Character.Humanoid
        Notify("Admin", "Viewing " .. selectedPlayer.Name, 2, Theme.Success)
    else
        Notify("Admin", "No player selected", 2, Theme.Error)
    end
end)

AdminTab:AddButton("Reset Camera", function()
    if LocalPlayer.Character then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        Notify("Admin", "Camera reset", 2, Theme.Success)
    end
end)

AdminTab:AddButton("Teleport to Player", function()
    if selectedPlayer and selectedPlayer.Character and LocalPlayer.Character then
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
        end)
        Notify("Admin", "Teleported to " .. selectedPlayer.Name, 2, Theme.Success)
    else
        Notify("Admin", "Cannot teleport", 2, Theme.Error)
    end
end)

AdminTab:AddButton("Bring Player", function()
    if selectedPlayer and selectedPlayer.Character and LocalPlayer.Character then
        pcall(function()
            selectedPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end)
        Notify("Admin", "Brought " .. selectedPlayer.Name, 2, Theme.Success)
    else
        Notify("Admin", "Cannot bring player", 2, Theme.Error)
    end
end)

    -- Settings Tab
    SettingsTab:AddSection("Configuration")
    SettingsTab:AddButton("Reset All Settings", function()
        Config.Flying.Speed = 50
        Notify("Settings", "Reset to defaults", 2, Theme.Success)
    end)

    SettingsTab:AddLabel("Keybinds: F = Flying | T = TP Tool")
    SettingsTab:AddLabel("Version: 3.0 LinoriaLib UI")

    -- Initial notification
    Notify("Mic Up", "LinoriaLib UI loaded successfully!", 3, Theme.Success)
end

-- Start with password protection
CreatePasswordGUI()
