local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Helper function to create UI elements without storing them
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = parent
end

local function addPadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.Parent = parent
end

local function addListLayout(parent, padding, horizontal)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or 0)
    if horizontal then
        layout.FillDirection = Enum.FillDirection.Horizontal
    end
    layout.Parent = parent
end

-- ==================== THEME SYSTEM ====================
local THEMES = {
    ["Purple"] = {
        Accent = Color3.fromRGB(138, 43, 226),
        Dark = Color3.fromRGB(75, 35, 130),
        Background = Color3.fromRGB(25, 20, 35),
        Frame = Color3.fromRGB(35, 28, 50),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(55, 40, 85)
    },
    ["Rainbow"] = {
        Accent = Color3.fromRGB(255, 50, 50),
        Dark = Color3.fromRGB(40, 40, 40),
        Background = Color3.fromRGB(20, 20, 25),
        Frame = Color3.fromRGB(30, 30, 35),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(50, 50, 55)
    },
    ["BlackWhite"] = {
        Accent = Color3.fromRGB(255, 255, 255),
        Dark = Color3.fromRGB(30, 30, 30),
        Background = Color3.fromRGB(15, 15, 15),
        Frame = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 200, 50),
        Button = Color3.fromRGB(40, 40, 40)
    },
    ["Pink"] = {
        Accent = Color3.fromRGB(255, 105, 180),
        Dark = Color3.fromRGB(180, 60, 120),
        Background = Color3.fromRGB(30, 20, 28),
        Frame = Color3.fromRGB(45, 30, 40),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(70, 45, 60)
    },
    ["GreenRed"] = {
        Accent = Color3.fromRGB(50, 205, 50),
        Dark = Color3.fromRGB(120, 30, 30),
        Background = Color3.fromRGB(20, 28, 20),
        Frame = Color3.fromRGB(30, 40, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(45, 60, 45)
    },
    ["PinkWhite"] = {
        Accent = Color3.fromRGB(255, 182, 193),
        Dark = Color3.fromRGB(200, 150, 160),
        Background = Color3.fromRGB(255, 255, 255),
        Frame = Color3.fromRGB(255, 240, 245),
        Text = Color3.fromRGB(80, 40, 50),
        Button = Color3.fromRGB(255, 200, 210)
    }
}

-- State
local currentTheme = "Purple"
local isOpen = false
local toggleKeybind = Enum.KeyCode.U
local walkspeedToggleKeybind = Enum.KeyCode.V
local aimbotToggleKeybind = Enum.KeyCode.X
local rainbowHue = 0
local waitingForInput = false
local waitingForWalkspeedInput = false
local waitingForAimbotInput = false
local walkspeedToggled = false
local aimbotToggled = false
local noAnimationToggled = false
local fpsPingToggled = false

local function getColors()
    return THEMES[currentTheme]
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- ==================== LOADING NOTIFICATION ====================
local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingNotification"
loadingFrame.Size = UDim2.new(0, 250, 0, 50)
loadingFrame.Position = UDim2.new(0.5, -125, 0, -60)
loadingFrame.BackgroundColor3 = getColors().Frame
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = screenGui
addCorner(loadingFrame, 12)
addStroke(loadingFrame, getColors().Accent, 2)

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(1, 0, 1, 0)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "LightHub V1 Loaded!"
loadingLabel.TextColor3 = getColors().Text
loadingLabel.TextSize = 18
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.Parent = loadingFrame

-- Animate loading notification
local function showLoadingNotification()
    -- Slide down from top
    TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -125, 0, 20)
    }):Play()
    
    -- Wait, then slide up and fade
    task.delay(3, function()
        TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -125, 0, -60)
        }):Play()
        
        task.delay(0.5, function()
            loadingFrame:Destroy()
        end)
    end)
end

showLoadingNotification()

-- ==================== MINIMIZED BUTTON (Circle) ====================
local minimizedBtn = Instance.new("TextButton")
minimizedBtn.Name = "MinimizedButton"
minimizedBtn.Size = UDim2.new(0, 55, 0, 55)
minimizedBtn.Position = UDim2.new(0.5, -27, 0.5, -27)
minimizedBtn.BackgroundColor3 = getColors().Accent
minimizedBtn.BorderSizePixel = 0
minimizedBtn.Text = "LH"
minimizedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedBtn.TextSize = 20
minimizedBtn.Font = Enum.Font.GothamBold
minimizedBtn.Parent = screenGui
addCorner(minimizedBtn, 55)
addStroke(minimizedBtn, Color3.fromRGB(0, 0, 0), 3)

-- ==================== MAIN GUI ====================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
mainFrame.BackgroundColor3 = getColors().Frame
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
addCorner(mainFrame, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = getColors().Accent
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- ==================== HEADER BOX ====================
local headerBox = Instance.new("Frame")
headerBox.Name = "HeaderBox"
headerBox.Size = UDim2.new(1, -20, 0, 50)
headerBox.Position = UDim2.new(0, 10, 0, 10)
headerBox.BackgroundColor3 = getColors().Dark
headerBox.BorderSizePixel = 0
headerBox.Parent = mainFrame
addCorner(headerBox, 8)

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -50, 1, 0)
headerTitle.Position = UDim2.new(0, 15, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Light Hub V1"
headerTitle.TextColor3 = getColors().Text
headerTitle.TextSize = 24
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = headerBox

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = headerBox
addCorner(closeBtn, 6)

-- ==================== CONTENT AREA ====================
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -20, 1, -80)
contentArea.Position = UDim2.new(0, 10, 0, 70)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- ==================== SECTIONS TABS ====================
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.BackgroundColor3 = getColors().Background
tabContainer.BorderSizePixel = 0
tabContainer.Parent = contentArea
addCorner(tabContainer, 8)
addPadding(tabContainer, 5, 0, 5, 0)
addListLayout(tabContainer, 5, true)

-- Settings Tab
local settingsTab = Instance.new("TextButton")
settingsTab.Name = "SettingsTab"
settingsTab.Size = UDim2.new(0, 100, 1, -10)
settingsTab.BackgroundColor3 = getColors().Accent
settingsTab.BorderSizePixel = 0
settingsTab.Text = "Settings"
settingsTab.TextColor3 = getColors().Text
settingsTab.TextSize = 14
settingsTab.Font = Enum.Font.GothamSemibold
settingsTab.Parent = tabContainer
addCorner(settingsTab, 6)

-- Movement Tab
local movementTab = Instance.new("TextButton")
movementTab.Name = "MovementTab"
movementTab.Size = UDim2.new(0, 100, 1, -10)
movementTab.BackgroundColor3 = getColors().Button
movementTab.BorderSizePixel = 0
movementTab.Text = "Movement"
movementTab.TextColor3 = getColors().Text
movementTab.TextSize = 14
movementTab.Font = Enum.Font.GothamSemibold
movementTab.Parent = tabContainer
addCorner(movementTab, 6)

-- Combat Tab
local combatTab = Instance.new("TextButton")
combatTab.Name = "CombatTab"
combatTab.Size = UDim2.new(0, 80, 1, -10)
combatTab.BackgroundColor3 = getColors().Button
combatTab.BorderSizePixel = 0
combatTab.Text = "Combat"
combatTab.TextColor3 = getColors().Text
combatTab.TextSize = 14
combatTab.Font = Enum.Font.GothamSemibold
combatTab.Parent = tabContainer
addCorner(combatTab, 6)

-- Player Tab
local playerTab = Instance.new("TextButton")
playerTab.Name = "PlayerTab"
playerTab.Size = UDim2.new(0, 80, 1, -10)
playerTab.BackgroundColor3 = getColors().Button
playerTab.BorderSizePixel = 0
playerTab.Text = "Player"
playerTab.TextColor3 = getColors().Text
playerTab.TextSize = 14
playerTab.Font = Enum.Font.GothamSemibold
playerTab.Parent = tabContainer
addCorner(playerTab, 6)

-- ==================== MOVEMENT CONTENT ====================
local movementContent = Instance.new("ScrollingFrame")
movementContent.Name = "MovementContent"
movementContent.Size = UDim2.new(1, 0, 1, -45)
movementContent.Position = UDim2.new(0, 0, 0, 40)
movementContent.BackgroundColor3 = getColors().Background
movementContent.BorderSizePixel = 0
movementContent.ScrollBarThickness = 6
movementContent.ScrollBarImageColor3 = getColors().Accent
movementContent.CanvasSize = UDim2.new(0, 0, 0, 500)
movementContent.Visible = false
movementContent.Parent = contentArea
addCorner(movementContent, 8)
addPadding(movementContent, 10, 10, 10, 10)
addListLayout(movementContent, 8)

-- ==================== WALKSPEED TOGGLE BUTTON ====================
local walkspeedToggleSection = Instance.new("Frame")
walkspeedToggleSection.Name = "WalkspeedToggleSection"
walkspeedToggleSection.Size = UDim2.new(1, 0, 0, 50)
walkspeedToggleSection.BackgroundColor3 = getColors().Button
walkspeedToggleSection.BorderSizePixel = 0
walkspeedToggleSection.Parent = movementContent
addCorner(walkspeedToggleSection, 8)

local walkspeedToggleTitle = Instance.new("TextLabel")
walkspeedToggleTitle.Size = UDim2.new(1, -70, 1, 0)
walkspeedToggleTitle.Position = UDim2.new(0, 10, 0, 0)
walkspeedToggleTitle.BackgroundTransparency = 1
walkspeedToggleTitle.Text = "WalkSpeed Toggle"
walkspeedToggleTitle.TextColor3 = getColors().Text
walkspeedToggleTitle.TextSize = 16
walkspeedToggleTitle.Font = Enum.Font.GothamBold
walkspeedToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
walkspeedToggleTitle.Parent = walkspeedToggleSection

local walkspeedToggleBtn = Instance.new("TextButton")
walkspeedToggleBtn.Name = "WalkspeedToggleBtn"
walkspeedToggleBtn.Size = UDim2.new(0, 50, 0, 30)
walkspeedToggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
walkspeedToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
walkspeedToggleBtn.BorderSizePixel = 0
walkspeedToggleBtn.Text = "OFF"
walkspeedToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
walkspeedToggleBtn.TextSize = 14
walkspeedToggleBtn.Font = Enum.Font.GothamBold
walkspeedToggleBtn.Parent = walkspeedToggleSection
addCorner(walkspeedToggleBtn, 6)

local function updateWalkspeedToggleVisual()
    if walkspeedToggled then
        walkspeedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        walkspeedToggleBtn.Text = "ON"
    else
        walkspeedToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        walkspeedToggleBtn.Text = "OFF"
    end
end

walkspeedToggleBtn.MouseButton1Click:Connect(function()
    walkspeedToggled = not walkspeedToggled
    updateWalkspeedToggleVisual()
    -- Apply or reset speed
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if walkspeedToggled then
                humanoid.WalkSpeed = currentWalkspeed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

-- ==================== WALKSPEED SLIDER ====================
local walkspeedSection = Instance.new("Frame")
walkspeedSection.Name = "WalkspeedSection"
walkspeedSection.Size = UDim2.new(1, 0, 0, 80)
walkspeedSection.BackgroundColor3 = getColors().Button
walkspeedSection.BorderSizePixel = 0
walkspeedSection.Parent = movementContent
addCorner(walkspeedSection, 8)

local walkspeedTitle = Instance.new("TextLabel")
walkspeedTitle.Size = UDim2.new(1, -70, 0, 25)
walkspeedTitle.Position = UDim2.new(0, 10, 0, 5)
walkspeedTitle.BackgroundTransparency = 1
walkspeedTitle.Text = "WalkSpeed"
walkspeedTitle.TextColor3 = getColors().Text
walkspeedTitle.TextSize = 16
walkspeedTitle.Font = Enum.Font.GothamBold
walkspeedTitle.TextXAlignment = Enum.TextXAlignment.Left
walkspeedTitle.Parent = walkspeedSection

-- Walkspeed input box
local walkspeedInput = Instance.new("TextBox")
walkspeedInput.Name = "WalkspeedInput"
walkspeedInput.Size = UDim2.new(0, 50, 0, 25)
walkspeedInput.Position = UDim2.new(1, -60, 0, 5)
walkspeedInput.BackgroundColor3 = getColors().Background
walkspeedInput.BorderSizePixel = 0
walkspeedInput.Text = "16"
walkspeedInput.TextColor3 = getColors().Accent
walkspeedInput.TextSize = 14
walkspeedInput.Font = Enum.Font.GothamBold
walkspeedInput.Parent = walkspeedSection
addCorner(walkspeedInput, 6)

-- Walkspeed slider background
local walkspeedSliderBg = Instance.new("Frame")
walkspeedSliderBg.Name = "SliderBg"
walkspeedSliderBg.Size = UDim2.new(1, -20, 0, 8)
walkspeedSliderBg.Position = UDim2.new(0, 10, 0, 38)
walkspeedSliderBg.BackgroundColor3 = getColors().Background
walkspeedSliderBg.BorderSizePixel = 0
walkspeedSliderBg.Parent = walkspeedSection
addCorner(walkspeedSliderBg, 4)

-- Walkspeed slider fill
local walkspeedSliderFill = Instance.new("Frame")
walkspeedSliderFill.Name = "SliderFill"
walkspeedSliderFill.Size = UDim2.new(0, 0, 1, 0)
walkspeedSliderFill.BackgroundColor3 = getColors().Accent
walkspeedSliderFill.BorderSizePixel = 0
walkspeedSliderFill.Parent = walkspeedSliderBg
addCorner(walkspeedSliderFill, 4)

-- Walkspeed slider knob
local walkspeedSliderKnob = Instance.new("Frame")
walkspeedSliderKnob.Name = "SliderKnob"
walkspeedSliderKnob.Size = UDim2.new(0, 18, 0, 18)
walkspeedSliderKnob.Position = UDim2.new(0, 1, 0.5, -9)
walkspeedSliderKnob.BackgroundColor3 = getColors().Text
walkspeedSliderKnob.BorderSizePixel = 0
walkspeedSliderKnob.Parent = walkspeedSection
addCorner(walkspeedSliderKnob, 9)
addStroke(walkspeedSliderKnob, getColors().Accent, 2)

-- Walkspeed slider value label
local walkspeedValueLabel = Instance.new("TextLabel")
walkspeedValueLabel.Size = UDim2.new(0, 50, 0, 20)
walkspeedValueLabel.Position = UDim2.new(0, 10, 0, 55)
walkspeedValueLabel.BackgroundTransparency = 1
walkspeedValueLabel.Text = "16"
walkspeedValueLabel.TextColor3 = getColors().Text
walkspeedValueLabel.TextSize = 12
walkspeedValueLabel.Font = Enum.Font.Gotham
walkspeedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
walkspeedValueLabel.Parent = walkspeedSection

-- Walkspeed slider logic
local walkspeedDragging = false
local minWalkspeed, maxWalkspeed = 16, 90
local currentWalkspeed = 16

local function updateWalkspeedSlider(value, applySpeed)
    currentWalkspeed = math.clamp(math.floor(value), minWalkspeed, maxWalkspeed)
    local percent = (currentWalkspeed - minWalkspeed) / (maxWalkspeed - minWalkspeed)
    walkspeedSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    walkspeedSliderKnob.Position = UDim2.new(0, 10 + (walkspeedSliderBg.AbsoluteSize.X * percent) - 9, 0.5, -9)
    walkspeedInput.Text = tostring(currentWalkspeed)
    walkspeedValueLabel.Text = tostring(currentWalkspeed)
    
    -- Only apply speed if toggle is ON
    if applySpeed ~= false and walkspeedToggled then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = currentWalkspeed
            end
        end
    end
end

walkspeedSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        walkspeedDragging = true
    end
end)

walkspeedSliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        walkspeedDragging = false
    end
end)

walkspeedSection.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        walkspeedDragging = true
    end
end)

walkspeedSection.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        walkspeedDragging = false
    end
end)

walkspeedInput.FocusLost:Connect(function(enterPressed)
    local value = tonumber(walkspeedInput.Text)
    if value then
        updateWalkspeedSlider(value)
    else
        walkspeedInput.Text = tostring(currentWalkspeed)
    end
end)

-- ==================== BRAINROT WALKSPEED SLIDER ====================
local brainrotSection = Instance.new("Frame")
brainrotSection.Name = "BrainrotSection"
brainrotSection.Size = UDim2.new(1, 0, 0, 80)
brainrotSection.BackgroundColor3 = getColors().Button
brainrotSection.BorderSizePixel = 0
brainrotSection.Parent = movementContent

local brainrotSectionCorner = Instance.new("UICorner")
brainrotSectionCorner.CornerRadius = UDim.new(0, 8)
brainrotSectionCorner.Parent = brainrotSection

local brainrotTitle = Instance.new("TextLabel")
brainrotTitle.Size = UDim2.new(1, -70, 0, 25)
brainrotTitle.Position = UDim2.new(0, 10, 0, 5)
brainrotTitle.BackgroundTransparency = 1
brainrotTitle.Text = "Brainrot WalkSpeed"
brainrotTitle.TextColor3 = getColors().Text
brainrotTitle.TextSize = 16
brainrotTitle.Font = Enum.Font.GothamBold
brainrotTitle.TextXAlignment = Enum.TextXAlignment.Left
brainrotTitle.Parent = brainrotSection

-- Brainrot input box
local brainrotInput = Instance.new("TextBox")
brainrotInput.Name = "BrainrotInput"
brainrotInput.Size = UDim2.new(0, 50, 0, 25)
brainrotInput.Position = UDim2.new(1, -60, 0, 5)
brainrotInput.BackgroundColor3 = getColors().Background
brainrotInput.BorderSizePixel = 0
brainrotInput.Text = "16"
brainrotInput.TextColor3 = getColors().Accent
brainrotInput.TextSize = 14
brainrotInput.Font = Enum.Font.GothamBold
brainrotInput.Parent = brainrotSection

local brainrotInputCorner = Instance.new("UICorner")
brainrotInputCorner.CornerRadius = UDim.new(0, 6)
brainrotInputCorner.Parent = brainrotInput

-- Brainrot slider background
local brainrotSliderBg = Instance.new("Frame")
brainrotSliderBg.Name = "SliderBg"
brainrotSliderBg.Size = UDim2.new(1, -20, 0, 8)
brainrotSliderBg.Position = UDim2.new(0, 10, 0, 38)
brainrotSliderBg.BackgroundColor3 = getColors().Background
brainrotSliderBg.BorderSizePixel = 0
brainrotSliderBg.Parent = brainrotSection

local brainrotSliderBgCorner = Instance.new("UICorner")
brainrotSliderBgCorner.CornerRadius = UDim.new(1, 0)
brainrotSliderBgCorner.Parent = brainrotSliderBg

-- Brainrot slider fill
local brainrotSliderFill = Instance.new("Frame")
brainrotSliderFill.Name = "SliderFill"
brainrotSliderFill.Size = UDim2.new(0, 0, 1, 0)
brainrotSliderFill.BackgroundColor3 = getColors().Accent
brainrotSliderFill.BorderSizePixel = 0
brainrotSliderFill.Parent = brainrotSliderBg

local brainrotSliderFillCorner = Instance.new("UICorner")
brainrotSliderFillCorner.CornerRadius = UDim.new(1, 0)
brainrotSliderFillCorner.Parent = brainrotSliderFill

-- Brainrot slider knob
local brainrotSliderKnob = Instance.new("Frame")
brainrotSliderKnob.Name = "SliderKnob"
brainrotSliderKnob.Size = UDim2.new(0, 18, 0, 18)
brainrotSliderKnob.Position = UDim2.new(0, 1, 0.5, -9)
brainrotSliderKnob.BackgroundColor3 = getColors().Text
brainrotSliderKnob.BorderSizePixel = 0
brainrotSliderKnob.Parent = brainrotSection

local brainrotSliderKnobCorner = Instance.new("UICorner")
brainrotSliderKnobCorner.CornerRadius = UDim.new(1, 0)
brainrotSliderKnobCorner.Parent = brainrotSliderKnob

local brainrotSliderKnobStroke = Instance.new("UIStroke")
brainrotSliderKnobStroke.Color = getColors().Accent
brainrotSliderKnobStroke.Thickness = 2
brainrotSliderKnobStroke.Parent = brainrotSliderKnob

-- Brainrot slider value label
local brainrotValueLabel = Instance.new("TextLabel")
brainrotValueLabel.Size = UDim2.new(0, 50, 0, 20)
brainrotValueLabel.Position = UDim2.new(0, 10, 0, 55)
brainrotValueLabel.BackgroundTransparency = 1
brainrotValueLabel.Text = "16"
brainrotValueLabel.TextColor3 = getColors().Text
brainrotValueLabel.TextSize = 12
brainrotValueLabel.Font = Enum.Font.Gotham
brainrotValueLabel.TextXAlignment = Enum.TextXAlignment.Left
brainrotValueLabel.Parent = brainrotSection

-- Brainrot slider logic
local brainrotDragging = false
local minBrainrot, maxBrainrot = 16, 90
local currentBrainrot = 16

local function updateBrainrotSlider(value, applySpeed)
    currentBrainrot = math.clamp(math.floor(value), minBrainrot, maxBrainrot)
    local percent = (currentBrainrot - minBrainrot) / (maxBrainrot - minBrainrot)
    brainrotSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    brainrotSliderKnob.Position = UDim2.new(0, 10 + (brainrotSliderBg.AbsoluteSize.X * percent) - 9, 0.5, -9)
    brainrotInput.Text = tostring(currentBrainrot)
    brainrotValueLabel.Text = tostring(currentBrainrot)
end

brainrotSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        brainrotDragging = true
    end
end)

brainrotSliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        brainrotDragging = false
    end
end)

brainrotSection.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        brainrotDragging = true
    end
end)

brainrotSection.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        brainrotDragging = false
    end
end)

brainrotInput.FocusLost:Connect(function(enterPressed)
    local value = tonumber(brainrotInput.Text)
    if value then
        updateBrainrotSlider(value)
    else
        brainrotInput.Text = tostring(currentBrainrot)
    end
end)

-- Brainrot detection and speed application
local function checkBrainrotHeld()
    local player = game.Players.LocalPlayer
    if not player or not player.Character then return false end
    
    -- Check if player is holding a brainrot (common tool names in Steal a Brainrot)
    local character = player.Character
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            local toolName = string.lower(item.Name)
            if string.find(toolName, "brainrot") or string.find(toolName, "brain") or string.find(toolName, "rot") then
                return true
            end
        end
    end
    
    -- Also check Backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local toolName = string.lower(item.Name)
                if string.find(toolName, "brainrot") or string.find(toolName, "brain") or string.find(toolName, "rot") then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Continuous speed check
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if checkBrainrotHeld() then
                humanoid.WalkSpeed = currentBrainrot
            elseif walkspeedToggled then
                humanoid.WalkSpeed = currentWalkspeed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

-- ==================== COMBAT CONTENT ====================
local combatContent = Instance.new("ScrollingFrame")
combatContent.Name = "CombatContent"
combatContent.Size = UDim2.new(1, 0, 1, -45)
combatContent.Position = UDim2.new(0, 0, 0, 40)
combatContent.BackgroundColor3 = getColors().Background
combatContent.BorderSizePixel = 0
combatContent.ScrollBarThickness = 6
combatContent.ScrollBarImageColor3 = getColors().Accent
combatContent.CanvasSize = UDim2.new(0, 0, 0, 500)
combatContent.Visible = false
combatContent.Parent = contentArea

local combatContentCorner = Instance.new("UICorner")
combatContentCorner.CornerRadius = UDim.new(0, 8)
combatContentCorner.Parent = combatContent

local combatPadding = Instance.new("UIPadding")
combatPadding.PaddingTop = UDim.new(0, 10)
combatPadding.PaddingBottom = UDim.new(0, 10)
combatPadding.PaddingLeft = UDim.new(0, 10)
combatPadding.PaddingRight = UDim.new(0, 10)
combatPadding.Parent = combatContent

local combatLayout = Instance.new("UIListLayout")
combatLayout.SortOrder = Enum.SortOrder.LayoutOrder
combatLayout.Padding = UDim.new(0, 8)
combatLayout.Parent = combatContent

-- ==================== AIMBOT TOGGLE BUTTON ====================
local aimbotToggleSection = Instance.new("Frame")
aimbotToggleSection.Name = "AimbotToggleSection"
aimbotToggleSection.Size = UDim2.new(1, 0, 0, 50)
aimbotToggleSection.BackgroundColor3 = getColors().Button
aimbotToggleSection.BorderSizePixel = 0
aimbotToggleSection.Parent = combatContent

local aimbotToggleSectionCorner = Instance.new("UICorner")
aimbotToggleSectionCorner.CornerRadius = UDim.new(0, 8)
aimbotToggleSectionCorner.Parent = aimbotToggleSection

local aimbotToggleTitle = Instance.new("TextLabel")
aimbotToggleTitle.Size = UDim2.new(1, -70, 1, 0)
aimbotToggleTitle.Position = UDim2.new(0, 10, 0, 0)
aimbotToggleTitle.BackgroundTransparency = 1
aimbotToggleTitle.Text = "Aimbot (Follow Nearest)"
aimbotToggleTitle.TextColor3 = getColors().Text
aimbotToggleTitle.TextSize = 16
aimbotToggleTitle.Font = Enum.Font.GothamBold
aimbotToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
aimbotToggleTitle.Parent = aimbotToggleSection

local aimbotToggleBtn = Instance.new("TextButton")
aimbotToggleBtn.Name = "AimbotToggleBtn"
aimbotToggleBtn.Size = UDim2.new(0, 50, 0, 30)
aimbotToggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
aimbotToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
aimbotToggleBtn.BorderSizePixel = 0
aimbotToggleBtn.Text = "OFF"
aimbotToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotToggleBtn.TextSize = 14
aimbotToggleBtn.Font = Enum.Font.GothamBold
aimbotToggleBtn.Parent = aimbotToggleSection

local aimbotToggleBtnCorner = Instance.new("UICorner")
aimbotToggleBtnCorner.CornerRadius = UDim.new(0, 6)
aimbotToggleBtnCorner.Parent = aimbotToggleBtn

local function updateAimbotToggleVisual()
    if aimbotToggled then
        aimbotToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        aimbotToggleBtn.Text = "ON"
    else
        aimbotToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        aimbotToggleBtn.Text = "OFF"
    end
end

aimbotToggleBtn.MouseButton1Click:Connect(function()
    aimbotToggled = not aimbotToggled
    updateAimbotToggleVisual()
end)

-- Aimbot keybind moved to Settings tab

-- ==================== SETTINGS CONTENT ====================
local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, 0, 1, -45)
settingsContent.Position = UDim2.new(0, 0, 0, 40)
settingsContent.BackgroundColor3 = getColors().Background
settingsContent.BorderSizePixel = 0
settingsContent.ScrollBarThickness = 6
settingsContent.ScrollBarImageColor3 = getColors().Accent
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 600)
settingsContent.Parent = contentArea

local settingsContentCorner = Instance.new("UICorner")
settingsContentCorner.CornerRadius = UDim.new(0, 8)
settingsContentCorner.Parent = settingsContent

local settingsPadding = Instance.new("UIPadding")
settingsPadding.PaddingTop = UDim.new(0, 10)
settingsPadding.PaddingBottom = UDim.new(0, 10)
settingsPadding.PaddingLeft = UDim.new(0, 10)
settingsPadding.PaddingRight = UDim.new(0, 10)
settingsPadding.Parent = settingsContent

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Padding = UDim.new(0, 8)
settingsLayout.Parent = settingsContent

-- ==================== FPS/PING COUNTER TOGGLE ====================
local fpsPingSection = Instance.new("Frame")
fpsPingSection.Name = "FpsPingSection"
fpsPingSection.Size = UDim2.new(1, 0, 0, 50)
fpsPingSection.BackgroundColor3 = getColors().Button
fpsPingSection.BorderSizePixel = 0
fpsPingSection.Parent = settingsContent

local fpsPingSectionCorner = Instance.new("UICorner")
fpsPingSectionCorner.CornerRadius = UDim.new(0, 8)
fpsPingSectionCorner.Parent = fpsPingSection

local fpsPingTitle = Instance.new("TextLabel")
fpsPingTitle.Size = UDim2.new(1, -70, 1, 0)
fpsPingTitle.Position = UDim2.new(0, 10, 0, 0)
fpsPingTitle.BackgroundTransparency = 1
fpsPingTitle.Text = "FPS/Ping Counter"
fpsPingTitle.TextColor3 = getColors().Text
fpsPingTitle.TextSize = 16
fpsPingTitle.Font = Enum.Font.GothamBold
fpsPingTitle.TextXAlignment = Enum.TextXAlignment.Left
fpsPingTitle.Parent = fpsPingSection

local fpsPingToggleBtn = Instance.new("TextButton")
fpsPingToggleBtn.Name = "FpsPingToggleBtn"
fpsPingToggleBtn.Size = UDim2.new(0, 50, 0, 30)
fpsPingToggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
fpsPingToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
fpsPingToggleBtn.BorderSizePixel = 0
fpsPingToggleBtn.Text = "OFF"
fpsPingToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsPingToggleBtn.TextSize = 14
fpsPingToggleBtn.Font = Enum.Font.GothamBold
fpsPingToggleBtn.Parent = fpsPingSection

local fpsPingToggleBtnCorner = Instance.new("UICorner")
fpsPingToggleBtnCorner.CornerRadius = UDim.new(0, 6)
fpsPingToggleBtnCorner.Parent = fpsPingToggleBtn

-- FPS/Ping Display Frame (top left)
local fpsPingDisplay = Instance.new("Frame")
fpsPingDisplay.Name = "FpsPingDisplay"
fpsPingDisplay.Size = UDim2.new(0, 120, 0, 50)
fpsPingDisplay.Position = UDim2.new(0, 10, 0, 10)
fpsPingDisplay.BackgroundColor3 = getColors().Frame
fpsPingDisplay.BorderSizePixel = 0
fpsPingDisplay.Visible = false
fpsPingDisplay.Parent = screenGui

local fpsPingDisplayCorner = Instance.new("UICorner")
fpsPingDisplayCorner.CornerRadius = UDim.new(0, 8)
fpsPingDisplayCorner.Parent = fpsPingDisplay

local fpsPingDisplayStroke = Instance.new("UIStroke")
fpsPingDisplayStroke.Color = getColors().Accent
fpsPingDisplayStroke.Thickness = 2
fpsPingDisplayStroke.Parent = fpsPingDisplay

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -10, 0, 22)
fpsLabel.Position = UDim2.new(0, 5, 0, 3)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = getColors().Accent
fpsLabel.TextSize = 14
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsPingDisplay

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, -10, 0, 22)
pingLabel.Position = UDim2.new(0, 5, 0, 25)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = getColors().Text
pingLabel.TextSize = 14
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = fpsPingDisplay

local function updateFpsPingToggleVisual()
    if fpsPingToggled then
        fpsPingToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        fpsPingToggleBtn.Text = "ON"
    else
        fpsPingToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        fpsPingToggleBtn.Text = "OFF"
    end
end

fpsPingToggleBtn.MouseButton1Click:Connect(function()
    fpsPingToggled = not fpsPingToggled
    updateFpsPingToggleVisual()
    fpsPingDisplay.Visible = fpsPingToggled
end)

-- FPS/Ping calculation loop
local lastTime = tick()
local frames = 0
local fps = 60

RunService.RenderStepped:Connect(function()
    if fpsPingToggled then
        -- Calculate FPS
        frames = frames + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = frames
            frames = 0
            lastTime = currentTime
            fpsLabel.Text = "FPS: " .. tostring(fps)
            
            -- Calculate Ping
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            pingLabel.Text = "Ping: " .. ping
        end
    end
end)

-- ==================== PLAYER CONTENT ====================
local playerContent = Instance.new("ScrollingFrame")
playerContent.Name = "PlayerContent"
playerContent.Size = UDim2.new(1, 0, 1, -45)
playerContent.Position = UDim2.new(0, 0, 0, 40)
playerContent.BackgroundColor3 = getColors().Background
playerContent.BorderSizePixel = 0
playerContent.ScrollBarThickness = 6
playerContent.ScrollBarImageColor3 = getColors().Accent
playerContent.CanvasSize = UDim2.new(0, 0, 0, 500)
playerContent.Visible = false
playerContent.Parent = contentArea

local playerContentCorner = Instance.new("UICorner")
playerContentCorner.CornerRadius = UDim.new(0, 8)
playerContentCorner.Parent = playerContent

local playerPadding = Instance.new("UIPadding")
playerPadding.PaddingTop = UDim.new(0, 10)
playerPadding.PaddingBottom = UDim.new(0, 10)
playerPadding.PaddingLeft = UDim.new(0, 10)
playerPadding.PaddingRight = UDim.new(0, 10)
playerPadding.Parent = playerContent

local playerLayout = Instance.new("UIListLayout")
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 8)
playerLayout.Parent = playerContent

-- ==================== TAB SWITCHING ====================
local currentTab = "Settings"

local function switchTab(tabName)
    currentTab = tabName
    local colors = getColors()
    
    settingsTab.BackgroundColor3 = tabName == "Settings" and colors.Accent or colors.Button
    movementTab.BackgroundColor3 = tabName == "Movement" and colors.Accent or colors.Button
    combatTab.BackgroundColor3 = tabName == "Combat" and colors.Accent or colors.Button
    playerTab.BackgroundColor3 = tabName == "Player" and colors.Accent or colors.Button
    
    settingsContent.Visible = tabName == "Settings"
    movementContent.Visible = tabName == "Movement"
    combatContent.Visible = tabName == "Combat"
    playerContent.Visible = tabName == "Player"
end

settingsTab.MouseButton1Click:Connect(function() switchTab("Settings") end)
movementTab.MouseButton1Click:Connect(function() switchTab("Movement") end)
combatTab.MouseButton1Click:Connect(function() switchTab("Combat") end)
playerTab.MouseButton1Click:Connect(function() switchTab("Player") end)

-- ==================== FOV SLIDER ====================
local fovSection = Instance.new("Frame")
fovSection.Name = "FovSection"
fovSection.Size = UDim2.new(1, 0, 0, 80)
fovSection.BackgroundColor3 = getColors().Button
fovSection.BorderSizePixel = 0
fovSection.Parent = playerContent

local fovSectionCorner = Instance.new("UICorner")
fovSectionCorner.CornerRadius = UDim.new(0, 8)
fovSectionCorner.Parent = fovSection

local fovTitle = Instance.new("TextLabel")
fovTitle.Size = UDim2.new(1, -70, 0, 25)
fovTitle.Position = UDim2.new(0, 10, 0, 5)
fovTitle.BackgroundTransparency = 1
fovTitle.Text = "Field of View"
fovTitle.TextColor3 = getColors().Text
fovTitle.TextSize = 16
fovTitle.Font = Enum.Font.GothamBold
fovTitle.TextXAlignment = Enum.TextXAlignment.Left
fovTitle.Parent = fovSection

-- FOV input box
local fovInput = Instance.new("TextBox")
fovInput.Name = "FovInput"
fovInput.Size = UDim2.new(0, 50, 0, 25)
fovInput.Position = UDim2.new(1, -60, 0, 5)
fovInput.BackgroundColor3 = getColors().Background
fovInput.BorderSizePixel = 0
fovInput.Text = "70"
fovInput.TextColor3 = getColors().Accent
fovInput.TextSize = 14
fovInput.Font = Enum.Font.GothamBold
fovInput.Parent = fovSection

local fovInputCorner = Instance.new("UICorner")
fovInputCorner.CornerRadius = UDim.new(0, 6)
fovInputCorner.Parent = fovInput

-- FOV slider background
local fovSliderBg = Instance.new("Frame")
fovSliderBg.Name = "SliderBg"
fovSliderBg.Size = UDim2.new(1, -20, 0, 8)
fovSliderBg.Position = UDim2.new(0, 10, 0, 38)
fovSliderBg.BackgroundColor3 = getColors().Background
fovSliderBg.BorderSizePixel = 0
fovSliderBg.Parent = fovSection

local fovSliderBgCorner = Instance.new("UICorner")
fovSliderBgCorner.CornerRadius = UDim.new(1, 0)
fovSliderBgCorner.Parent = fovSliderBg

-- FOV slider fill
local fovSliderFill = Instance.new("Frame")
fovSliderFill.Name = "SliderFill"
fovSliderFill.Size = UDim2.new(0, 0, 1, 0)
fovSliderFill.BackgroundColor3 = getColors().Accent
fovSliderFill.BorderSizePixel = 0
fovSliderFill.Parent = fovSliderBg

local fovSliderFillCorner = Instance.new("UICorner")
fovSliderFillCorner.CornerRadius = UDim.new(1, 0)
fovSliderFillCorner.Parent = fovSliderFill

-- FOV slider knob
local fovSliderKnob = Instance.new("Frame")
fovSliderKnob.Name = "SliderKnob"
fovSliderKnob.Size = UDim2.new(0, 18, 0, 18)
fovSliderKnob.Position = UDim2.new(0, 1, 0.5, -9)
fovSliderKnob.BackgroundColor3 = getColors().Text
fovSliderKnob.BorderSizePixel = 0
fovSliderKnob.Parent = fovSection

local fovSliderKnobCorner = Instance.new("UICorner")
fovSliderKnobCorner.CornerRadius = UDim.new(1, 0)
fovSliderKnobCorner.Parent = fovSliderKnob

local fovSliderKnobStroke = Instance.new("UIStroke")
fovSliderKnobStroke.Color = getColors().Accent
fovSliderKnobStroke.Thickness = 2
fovSliderKnobStroke.Parent = fovSliderKnob

-- FOV slider value label
local fovValueLabel = Instance.new("TextLabel")
fovValueLabel.Size = UDim2.new(0, 50, 0, 20)
fovValueLabel.Position = UDim2.new(0, 10, 0, 55)
fovValueLabel.BackgroundTransparency = 1
fovValueLabel.Text = "70"
fovValueLabel.TextColor3 = getColors().Text
fovValueLabel.TextSize = 12
fovValueLabel.Font = Enum.Font.Gotham
fovValueLabel.TextXAlignment = Enum.TextXAlignment.Left
fovValueLabel.Parent = fovSection

-- FOV slider logic
local fovDragging = false
local minFov, maxFov = 70, 120
local currentFov = 70

local function updateFovSlider(value, applyFov)
    currentFov = math.clamp(math.floor(value), minFov, maxFov)
    local percent = (currentFov - minFov) / (maxFov - minFov)
    fovSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    fovSliderKnob.Position = UDim2.new(0, 10 + (fovSliderBg.AbsoluteSize.X * percent) - 9, 0.5, -9)
    fovInput.Text = tostring(currentFov)
    fovValueLabel.Text = tostring(currentFov)
    
    if applyFov ~= false then
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = currentFov
        end
    end
end

fovSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = true
    end
end)

fovSliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = false
    end
end)

fovSection.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = true
    end
end)

fovSection.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = false
    end
end)

fovInput.FocusLost:Connect(function(enterPressed)
    local value = tonumber(fovInput.Text)
    if value then
        updateFovSlider(value)
    else
        fovInput.Text = tostring(currentFov)
    end
end)

-- ==================== STRETCH RES SLIDER ====================
local stretchSection = Instance.new("Frame")
stretchSection.Name = "StretchSection"
stretchSection.Size = UDim2.new(1, 0, 0, 80)
stretchSection.BackgroundColor3 = getColors().Button
stretchSection.BorderSizePixel = 0
stretchSection.Parent = playerContent

local stretchSectionCorner = Instance.new("UICorner")
stretchSectionCorner.CornerRadius = UDim.new(0, 8)
stretchSectionCorner.Parent = stretchSection

local stretchTitle = Instance.new("TextLabel")
stretchTitle.Size = UDim2.new(1, -70, 0, 25)
stretchTitle.Position = UDim2.new(0, 10, 0, 5)
stretchTitle.BackgroundTransparency = 1
stretchTitle.Text = "Stretch Res"
stretchTitle.TextColor3 = getColors().Text
stretchTitle.TextSize = 16
stretchTitle.Font = Enum.Font.GothamBold
stretchTitle.TextXAlignment = Enum.TextXAlignment.Left
stretchTitle.Parent = stretchSection

-- Stretch input box
local stretchInput = Instance.new("TextBox")
stretchInput.Name = "StretchInput"
stretchInput.Size = UDim2.new(0, 50, 0, 25)
stretchInput.Position = UDim2.new(1, -60, 0, 5)
stretchInput.BackgroundColor3 = getColors().Background
stretchInput.BorderSizePixel = 0
stretchInput.Text = "1.00"
stretchInput.TextColor3 = getColors().Accent
stretchInput.TextSize = 14
stretchInput.Font = Enum.Font.GothamBold
stretchInput.Parent = stretchSection

local stretchInputCorner = Instance.new("UICorner")
stretchInputCorner.CornerRadius = UDim.new(0, 6)
stretchInputCorner.Parent = stretchInput

-- Stretch slider background
local stretchSliderBg = Instance.new("Frame")
stretchSliderBg.Name = "SliderBg"
stretchSliderBg.Size = UDim2.new(1, -20, 0, 8)
stretchSliderBg.Position = UDim2.new(0, 10, 0, 38)
stretchSliderBg.BackgroundColor3 = getColors().Background
stretchSliderBg.BorderSizePixel = 0
stretchSliderBg.Parent = stretchSection

local stretchSliderBgCorner = Instance.new("UICorner")
stretchSliderBgCorner.CornerRadius = UDim.new(1, 0)
stretchSliderBgCorner.Parent = stretchSliderBg

-- Stretch slider fill
local stretchSliderFill = Instance.new("Frame")
stretchSliderFill.Name = "SliderFill"
stretchSliderFill.Size = UDim2.new(0, 0, 1, 0)
stretchSliderFill.BackgroundColor3 = getColors().Accent
stretchSliderFill.BorderSizePixel = 0
stretchSliderFill.Parent = stretchSliderBg

local stretchSliderFillCorner = Instance.new("UICorner")
stretchSliderFillCorner.CornerRadius = UDim.new(1, 0)
stretchSliderFillCorner.Parent = stretchSliderFill

-- Stretch slider knob
local stretchSliderKnob = Instance.new("Frame")
stretchSliderKnob.Name = "SliderKnob"
stretchSliderKnob.Size = UDim2.new(0, 18, 0, 18)
stretchSliderKnob.Position = UDim2.new(0, 1, 0.5, -9)
stretchSliderKnob.BackgroundColor3 = getColors().Text
stretchSliderKnob.BorderSizePixel = 0
stretchSliderKnob.Parent = stretchSection

local stretchSliderKnobCorner = Instance.new("UICorner")
stretchSliderKnobCorner.CornerRadius = UDim.new(1, 0)
stretchSliderKnobCorner.Parent = stretchSliderKnob

local stretchSliderKnobStroke = Instance.new("UIStroke")
stretchSliderKnobStroke.Color = getColors().Accent
stretchSliderKnobStroke.Thickness = 2
stretchSliderKnobStroke.Parent = stretchSliderKnob

-- Stretch slider value label
local stretchValueLabel = Instance.new("TextLabel")
stretchValueLabel.Size = UDim2.new(0, 50, 0, 20)
stretchValueLabel.Position = UDim2.new(0, 10, 0, 55)
stretchValueLabel.BackgroundTransparency = 1
stretchValueLabel.Text = "1.00"
stretchValueLabel.TextColor3 = getColors().Text
stretchValueLabel.TextSize = 12
stretchValueLabel.Font = Enum.Font.Gotham
stretchValueLabel.TextXAlignment = Enum.TextXAlignment.Left
stretchValueLabel.Parent = stretchSection

-- Stretch slider logic
local stretchDragging = false
local minStretch, maxStretch = 0.5, 1.75
local currentStretch = 1.0

local function updateStretchSlider(value, applyStretch)
    currentStretch = math.clamp(value, minStretch, maxStretch)
    currentStretch = math.floor(currentStretch * 100) / 100
    local percent = (currentStretch - minStretch) / (maxStretch - minStretch)
    stretchSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    stretchSliderKnob.Position = UDim2.new(0, 10 + (stretchSliderBg.AbsoluteSize.X * percent) - 9, 0.5, -9)
    stretchInput.Text = string.format("%.2f", currentStretch)
    stretchValueLabel.Text = string.format("%.2f", currentStretch)
end

stretchSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stretchDragging = true
    end
end)

stretchSliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stretchDragging = false
    end
end)

stretchSection.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stretchDragging = true
    end
end)

stretchSection.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stretchDragging = false
    end
end)

stretchInput.FocusLost:Connect(function(enterPressed)
    local value = tonumber(stretchInput.Text)
    if value then
        updateStretchSlider(value)
    else
        stretchInput.Text = string.format("%.2f", currentStretch)
    end
end)

-- ==================== NO ANIMATION TOGGLE ====================
local noAnimSection = Instance.new("Frame")
noAnimSection.Name = "NoAnimSection"
noAnimSection.Size = UDim2.new(1, 0, 0, 50)
noAnimSection.BackgroundColor3 = getColors().Button
noAnimSection.BorderSizePixel = 0
noAnimSection.Parent = playerContent

local noAnimSectionCorner = Instance.new("UICorner")
noAnimSectionCorner.CornerRadius = UDim.new(0, 8)
noAnimSectionCorner.Parent = noAnimSection

local noAnimTitle = Instance.new("TextLabel")
noAnimTitle.Size = UDim2.new(1, -70, 1, 0)
noAnimTitle.Position = UDim2.new(0, 10, 0, 0)
noAnimTitle.BackgroundTransparency = 1
noAnimTitle.Text = "No Animation"
noAnimTitle.TextColor3 = getColors().Text
noAnimTitle.TextSize = 16
noAnimTitle.Font = Enum.Font.GothamBold
noAnimTitle.TextXAlignment = Enum.TextXAlignment.Left
noAnimTitle.Parent = noAnimSection

local noAnimToggleBtn = Instance.new("TextButton")
noAnimToggleBtn.Name = "NoAnimToggleBtn"
noAnimToggleBtn.Size = UDim2.new(0, 50, 0, 30)
noAnimToggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
noAnimToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
noAnimToggleBtn.BorderSizePixel = 0
noAnimToggleBtn.Text = "OFF"
noAnimToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noAnimToggleBtn.TextSize = 14
noAnimToggleBtn.Font = Enum.Font.GothamBold
noAnimToggleBtn.Parent = noAnimSection

local noAnimToggleBtnCorner = Instance.new("UICorner")
noAnimToggleBtnCorner.CornerRadius = UDim.new(0, 6)
noAnimToggleBtnCorner.Parent = noAnimToggleBtn

local function updateNoAnimToggleVisual()
    if noAnimationToggled then
        noAnimToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        noAnimToggleBtn.Text = "ON"
    else
        noAnimToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        noAnimToggleBtn.Text = "OFF"
    end
end

local function disableAnimations(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChild("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
    
    -- Set joints to neutral pose (arms by sides)
    local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftHand")
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftFoot")
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightFoot")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    
    -- For R6 characters
    if torso and torso:IsA("BasePart") then
        local leftShoulder = torso:FindFirstChild("Left Shoulder")
        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local leftHip = torso:FindFirstChild("Left Hip")
        local rightHip = torso:FindFirstChild("Right Hip")
        
        if leftShoulder and leftShoulder:IsA("Motor6D") then
            leftShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftShoulder.C1 = CFrame.new(0.5, 0.5, 0)
        end
        if rightShoulder and rightShoulder:IsA("Motor6D") then
            rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightShoulder.C1 = CFrame.new(-0.5, 0.5, 0)
        end
        if leftHip and leftHip:IsA("Motor6D") then
            leftHip.C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftHip.C1 = CFrame.new(-0.5, 1, 0)
        end
        if rightHip and rightHip:IsA("Motor6D") then
            rightHip.C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightHip.C1 = CFrame.new(0.5, 1, 0)
        end
    end
    
    -- For R15 characters
    local upperTorso = character:FindFirstChild("UpperTorso")
    if upperTorso then
        local leftShoulder = upperTorso:FindFirstChild("LeftShoulder")
        local rightShoulder = upperTorso:FindFirstChild("RightShoulder")
        
        if leftShoulder and leftShoulder:IsA("Motor6D") then
            leftShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftShoulder.C1 = CFrame.new(0.5, 0.5, 0)
        end
        if rightShoulder and rightShoulder:IsA("Motor6D") then
            rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightShoulder.C1 = CFrame.new(-0.5, 0.5, 0)
        end
    end
    
    local lowerTorso = character:FindFirstChild("LowerTorso")
    if lowerTorso then
        local leftHip = lowerTorso:FindFirstChild("LeftHip")
        local rightHip = lowerTorso:FindFirstChild("RightHip")
        
        if leftHip and leftHip:IsA("Motor6D") then
            leftHip.C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftHip.C1 = CFrame.new(-0.5, 1, 0)
        end
        if rightHip and rightHip:IsA("Motor6D") then
            rightHip.C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightHip.C1 = CFrame.new(0.5, 1, 0)
        end
    end
end

local function enableAnimations(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Reset joints to default for R6
    local torso = character:FindFirstChild("Torso")
    if torso and torso:IsA("BasePart") then
        local leftShoulder = torso:FindFirstChild("Left Shoulder")
        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local leftHip = torso:FindFirstChild("Left Hip")
        local rightHip = torso:FindFirstChild("Right Hip")
        
        if leftShoulder and leftShoulder:IsA("Motor6D") then
            leftShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftShoulder.C1 = CFrame.new(0.5, 0.5, 0)
        end
        if rightShoulder and rightShoulder:IsA("Motor6D") then
            rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightShoulder.C1 = CFrame.new(-0.5, 0.5, 0)
        end
        if leftHip and leftHip:IsA("Motor6D") then
            leftHip.C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftHip.C1 = CFrame.new(-0.5, 1, 0)
        end
        if rightHip and rightHip:IsA("Motor6D") then
            rightHip.C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightHip.C1 = CFrame.new(0.5, 1, 0)
        end
    end
    
    -- Reset joints to default for R15
    local upperTorso = character:FindFirstChild("UpperTorso")
    if upperTorso then
        local leftShoulder = upperTorso:FindFirstChild("LeftShoulder")
        local rightShoulder = upperTorso:FindFirstChild("RightShoulder")
        
        if leftShoulder and leftShoulder:IsA("Motor6D") then
            leftShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftShoulder.C1 = CFrame.new(0.5, 0.5, 0)
        end
        if rightShoulder and rightShoulder:IsA("Motor6D") then
            rightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightShoulder.C1 = CFrame.new(-0.5, 0.5, 0)
        end
    end
    
    local lowerTorso = character:FindFirstChild("LowerTorso")
    if lowerTorso then
        local leftHip = lowerTorso:FindFirstChild("LeftHip")
        local rightHip = lowerTorso:FindFirstChild("RightHip")
        
        if leftHip and leftHip:IsA("Motor6D") then
            leftHip.C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
            leftHip.C1 = CFrame.new(-0.5, 1, 0)
        end
        if rightHip and rightHip:IsA("Motor6D") then
            rightHip.C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0)
            rightHip.C1 = CFrame.new(0.5, 1, 0)
        end
    end
end

noAnimToggleBtn.MouseButton1Click:Connect(function()
    noAnimationToggled = not noAnimationToggled
    updateNoAnimToggleVisual()
    
    local player = game.Players.LocalPlayer
    if player and player.Character then
        if noAnimationToggled then
            disableAnimations(player.Character)
        else
            enableAnimations(player.Character)
        end
    end
end)

-- Continuous no animation enforcement
RunService.Heartbeat:Connect(function()
    if noAnimationToggled then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChild("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.IsPlaying then
                            track:Stop()
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== KEYBINDS SECTION ====================
local keybindSection = Instance.new("Frame")
keybindSection.Name = "KeybindSection"
keybindSection.Size = UDim2.new(1, 0, 0, 150)
keybindSection.BackgroundColor3 = getColors().Button
keybindSection.BorderSizePixel = 0
keybindSection.Parent = settingsContent

local keybindSectionCorner = Instance.new("UICorner")
keybindSectionCorner.CornerRadius = UDim.new(0, 8)
keybindSectionCorner.Parent = keybindSection

local keybindTitle = Instance.new("TextLabel")
keybindTitle.Size = UDim2.new(1, 0, 0, 30)
keybindTitle.Position = UDim2.new(0, 10, 0, 5)
keybindTitle.BackgroundTransparency = 1
keybindTitle.Text = "Keybinds"
keybindTitle.TextColor3 = getColors().Text
keybindTitle.TextSize = 16
keybindTitle.Font = Enum.Font.GothamBold
keybindTitle.TextXAlignment = Enum.TextXAlignment.Left
keybindTitle.Parent = keybindSection

-- Toggle GUI Keybind Row
local toggleGuiRow = Instance.new("Frame")
toggleGuiRow.Size = UDim2.new(1, -20, 0, 35)
toggleGuiRow.Position = UDim2.new(0, 10, 0, 38)
toggleGuiRow.BackgroundColor3 = getColors().Background
toggleGuiRow.BorderSizePixel = 0
toggleGuiRow.Parent = keybindSection

local toggleGuiRowCorner = Instance.new("UICorner")
toggleGuiRowCorner.CornerRadius = UDim.new(0, 6)
toggleGuiRowCorner.Parent = toggleGuiRow

local toggleGuiLabel = Instance.new("TextLabel")
toggleGuiLabel.Size = UDim2.new(1, -80, 1, 0)
toggleGuiLabel.Position = UDim2.new(0, 10, 0, 0)
toggleGuiLabel.BackgroundTransparency = 1
toggleGuiLabel.Text = "Toggle GUI"
toggleGuiLabel.TextColor3 = getColors().Text
toggleGuiLabel.TextSize = 14
toggleGuiLabel.Font = Enum.Font.GothamSemibold
toggleGuiLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleGuiLabel.Parent = toggleGuiRow

local toggleGuiKey = Instance.new("TextButton")
toggleGuiKey.Size = UDim2.new(0, 60, 1, -10)
toggleGuiKey.Position = UDim2.new(1, -70, 0, 5)
toggleGuiKey.BackgroundColor3 = getColors().Accent
toggleGuiKey.BorderSizePixel = 0
toggleGuiKey.Text = toggleKeybind.Name
toggleGuiKey.TextColor3 = getColors().Text
toggleGuiKey.TextSize = 14
toggleGuiKey.Font = Enum.Font.GothamBold
toggleGuiKey.Parent = toggleGuiRow

local toggleGuiKeyCorner = Instance.new("UICorner")
toggleGuiKeyCorner.CornerRadius = UDim.new(0, 6)
toggleGuiKeyCorner.Parent = toggleGuiKey

toggleGuiKey.MouseButton1Click:Connect(function()
    if waitingForInput then return end
    waitingForInput = true
    toggleGuiKey.Text = "..."
    toggleGuiKey.BackgroundColor3 = getColors().Dark
end)

-- ==================== WALKSPEED TOGGLE KEYBIND ROW ====================
local toggleWalkspeedRow = Instance.new("Frame")
toggleWalkspeedRow.Size = UDim2.new(1, -20, 0, 35)
toggleWalkspeedRow.Position = UDim2.new(0, 10, 0, 73)
toggleWalkspeedRow.BackgroundColor3 = getColors().Background
toggleWalkspeedRow.BorderSizePixel = 0
toggleWalkspeedRow.Parent = keybindSection

local toggleWalkspeedRowCorner = Instance.new("UICorner")
toggleWalkspeedRowCorner.CornerRadius = UDim.new(0, 6)
toggleWalkspeedRowCorner.Parent = toggleWalkspeedRow

local toggleWalkspeedLabel = Instance.new("TextLabel")
toggleWalkspeedLabel.Size = UDim2.new(1, -80, 1, 0)
toggleWalkspeedLabel.Position = UDim2.new(0, 10, 0, 0)
toggleWalkspeedLabel.BackgroundTransparency = 1
toggleWalkspeedLabel.Text = "Toggle WalkSpeed"
toggleWalkspeedLabel.TextColor3 = getColors().Text
toggleWalkspeedLabel.TextSize = 14
toggleWalkspeedLabel.Font = Enum.Font.GothamSemibold
toggleWalkspeedLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleWalkspeedLabel.Parent = toggleWalkspeedRow

local toggleWalkspeedKey = Instance.new("TextButton")
toggleWalkspeedKey.Size = UDim2.new(0, 60, 1, -10)
toggleWalkspeedKey.Position = UDim2.new(1, -70, 0, 5)
toggleWalkspeedKey.BackgroundColor3 = getColors().Accent
toggleWalkspeedKey.BorderSizePixel = 0
toggleWalkspeedKey.Text = walkspeedToggleKeybind.Name
toggleWalkspeedKey.TextColor3 = getColors().Text
toggleWalkspeedKey.TextSize = 14
toggleWalkspeedKey.Font = Enum.Font.GothamBold
toggleWalkspeedKey.Parent = toggleWalkspeedRow

local toggleWalkspeedKeyCorner = Instance.new("UICorner")
toggleWalkspeedKeyCorner.CornerRadius = UDim.new(0, 6)
toggleWalkspeedKeyCorner.Parent = toggleWalkspeedKey

toggleWalkspeedKey.MouseButton1Click:Connect(function()
    if waitingForWalkspeedInput then return end
    waitingForWalkspeedInput = true
    toggleWalkspeedKey.Text = "..."
    toggleWalkspeedKey.BackgroundColor3 = getColors().Dark
end)

-- ==================== AIMBOT TOGGLE KEYBIND ROW ====================
local toggleAimbotRow = Instance.new("Frame")
toggleAimbotRow.Size = UDim2.new(1, -20, 0, 35)
toggleAimbotRow.Position = UDim2.new(0, 10, 0, 108)
toggleAimbotRow.BackgroundColor3 = getColors().Background
toggleAimbotRow.BorderSizePixel = 0
toggleAimbotRow.Parent = keybindSection

local toggleAimbotRowCorner = Instance.new("UICorner")
toggleAimbotRowCorner.CornerRadius = UDim.new(0, 6)
toggleAimbotRowCorner.Parent = toggleAimbotRow

local toggleAimbotLabel = Instance.new("TextLabel")
toggleAimbotLabel.Size = UDim2.new(1, -80, 1, 0)
toggleAimbotLabel.Position = UDim2.new(0, 10, 0, 0)
toggleAimbotLabel.BackgroundTransparency = 1
toggleAimbotLabel.Text = "Toggle Aimbot"
toggleAimbotLabel.TextColor3 = getColors().Text
toggleAimbotLabel.TextSize = 14
toggleAimbotLabel.Font = Enum.Font.GothamSemibold
toggleAimbotLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleAimbotLabel.Parent = toggleAimbotRow

local toggleAimbotKey = Instance.new("TextButton")
toggleAimbotKey.Size = UDim2.new(0, 60, 1, -10)
toggleAimbotKey.Position = UDim2.new(1, -70, 0, 5)
toggleAimbotKey.BackgroundColor3 = getColors().Accent
toggleAimbotKey.BorderSizePixel = 0
toggleAimbotKey.Text = aimbotToggleKeybind.Name
toggleAimbotKey.TextColor3 = getColors().Text
toggleAimbotKey.TextSize = 14
toggleAimbotKey.Font = Enum.Font.GothamBold
toggleAimbotKey.Parent = toggleAimbotRow

local toggleAimbotKeyCorner = Instance.new("UICorner")
toggleAimbotKeyCorner.CornerRadius = UDim.new(0, 6)
toggleAimbotKeyCorner.Parent = toggleAimbotKey

toggleAimbotKey.MouseButton1Click:Connect(function()
    if waitingForAimbotInput then return end
    waitingForAimbotInput = true
    toggleAimbotKey.Text = "..."
    toggleAimbotKey.BackgroundColor3 = getColors().Dark
end)

-- ==================== THEME SECTION ====================
local themeSection = Instance.new("Frame")
themeSection.Name = "ThemeSection"
themeSection.Size = UDim2.new(1, 0, 0, 200)
themeSection.BackgroundColor3 = getColors().Button
themeSection.BorderSizePixel = 0
themeSection.Parent = settingsContent

local themeSectionCorner = Instance.new("UICorner")
themeSectionCorner.CornerRadius = UDim.new(0, 8)
themeSectionCorner.Parent = themeSection

local themeTitle = Instance.new("TextLabel")
themeTitle.Size = UDim2.new(1, 0, 0, 30)
themeTitle.Position = UDim2.new(0, 10, 0, 5)
themeTitle.BackgroundTransparency = 1
themeTitle.Text = "GUI Color"
themeTitle.TextColor3 = getColors().Text
themeTitle.TextSize = 16
themeTitle.Font = Enum.Font.GothamBold
themeTitle.TextXAlignment = Enum.TextXAlignment.Left
themeTitle.Parent = themeSection

local themePadding = Instance.new("UIPadding")
themePadding.PaddingTop = UDim.new(0, 40)
themePadding.PaddingLeft = UDim.new(0, 10)
themePadding.PaddingRight = UDim.new(0, 10)
themePadding.Parent = themeSection

local themeLayout = Instance.new("UIListLayout")
themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeLayout.Padding = UDim.new(0, 5)
themeLayout.Parent = themeSection

local themeButtons = {"Purple", "Rainbow", "BlackWhite", "Pink", "GreenRed", "PinkWhite"}

local function updateTheme(themeName)
    currentTheme = themeName
    local colors = getColors()
    
    mainFrame.BackgroundColor3 = colors.Frame
    mainStroke.Color = colors.Accent
    headerBox.BackgroundColor3 = colors.Dark
    headerTitle.TextColor3 = colors.Text
    tabContainer.BackgroundColor3 = colors.Background
    settingsTab.BackgroundColor3 = currentTab == "Settings" and colors.Accent or colors.Button
    movementTab.BackgroundColor3 = currentTab == "Movement" and colors.Accent or colors.Button
    combatTab.BackgroundColor3 = currentTab == "Combat" and colors.Accent or colors.Button
    playerTab.BackgroundColor3 = currentTab == "Player" and colors.Accent or colors.Button
    settingsContent.BackgroundColor3 = colors.Background
    movementContent.BackgroundColor3 = colors.Background
    combatContent.BackgroundColor3 = colors.Background
    playerContent.BackgroundColor3 = colors.Background
    keybindSection.BackgroundColor3 = colors.Button
    keybindTitle.TextColor3 = colors.Text
    toggleGuiLabel.TextColor3 = colors.Text
    toggleWalkspeedLabel.TextColor3 = colors.Text
    toggleAimbotLabel.TextColor3 = colors.Text
    themeTitle.TextColor3 = colors.Text
    themeSection.BackgroundColor3 = colors.Button
    toggleGuiRow.BackgroundColor3 = colors.Background
    toggleGuiKey.BackgroundColor3 = colors.Accent
    toggleGuiKey.TextColor3 = colors.Text
    toggleWalkspeedRow.BackgroundColor3 = colors.Background
    toggleWalkspeedKey.BackgroundColor3 = colors.Accent
    toggleWalkspeedKey.TextColor3 = colors.Text
    toggleAimbotRow.BackgroundColor3 = colors.Background
    toggleAimbotKey.BackgroundColor3 = colors.Accent
    toggleAimbotKey.TextColor3 = colors.Text
    minimizedBtn.BackgroundColor3 = colors.Accent
    minimizedBtnStroke.Color = colors.Dark
    walkspeedSection.BackgroundColor3 = colors.Button
    walkspeedTitle.TextColor3 = colors.Text
    walkspeedInput.BackgroundColor3 = colors.Background
    walkspeedInput.TextColor3 = colors.Accent
    walkspeedSliderBg.BackgroundColor3 = colors.Background
    walkspeedSliderFill.BackgroundColor3 = colors.Accent
    walkspeedSliderKnob.BackgroundColor3 = colors.Text
    walkspeedSliderKnobStroke.Color = colors.Accent
    walkspeedValueLabel.TextColor3 = colors.Text
    walkspeedToggleSection.BackgroundColor3 = colors.Button
    walkspeedToggleTitle.TextColor3 = colors.Text
    brainrotSection.BackgroundColor3 = colors.Button
    brainrotTitle.TextColor3 = colors.Text
    brainrotInput.BackgroundColor3 = colors.Background
    brainrotInput.TextColor3 = colors.Accent
    brainrotSliderBg.BackgroundColor3 = colors.Background
    brainrotSliderFill.BackgroundColor3 = colors.Accent
    brainrotSliderKnob.BackgroundColor3 = colors.Text
    brainrotSliderKnobStroke.Color = colors.Accent
    brainrotValueLabel.TextColor3 = colors.Text
    aimbotToggleTitle.TextColor3 = colors.Text
    aimbotToggleSection.BackgroundColor3 = colors.Button
    noAnimSection.BackgroundColor3 = colors.Button
    noAnimTitle.TextColor3 = colors.Text
    fpsPingSection.BackgroundColor3 = colors.Button
    fpsPingTitle.TextColor3 = colors.Text
    fpsPingDisplay.BackgroundColor3 = colors.Frame
    fpsPingDisplayStroke.Color = colors.Accent
    fpsLabel.TextColor3 = colors.Accent
    pingLabel.TextColor3 = colors.Text
    if loadingFrame and loadingFrame.Parent then
        loadingFrame.BackgroundColor3 = colors.Frame
        loadingStroke.Color = colors.Accent
        loadingLabel.TextColor3 = colors.Text
    end
end

for _, themeName in ipairs(themeButtons) do
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(1, -20, 0, 30)
    themeBtn.BackgroundColor3 = currentTheme == themeName and getColors().Accent or getColors().Background
    themeBtn.BorderSizePixel = 0
    themeBtn.Text = themeName
    themeBtn.TextColor3 = getColors().Text
    themeBtn.TextSize = 14
    themeBtn.Font = Enum.Font.GothamSemibold
    themeBtn.Parent = themeSection
    
    local themeBtnCorner = Instance.new("UICorner")
    themeBtnCorner.CornerRadius = UDim.new(0, 6)
    themeBtnCorner.Parent = themeBtn
    
    themeBtn.MouseButton1Click:Connect(function()
        updateTheme(themeName)
        for _, btn in ipairs(themeSection:GetChildren()) do
            if btn:IsA("TextButton") then
                local c = getColors()
                btn.BackgroundColor3 = btn.Text == themeName and c.Accent or c.Background
                btn.TextColor3 = c.Text
            end
        end
    end)
end

-- ==================== ANIMATION FUNCTIONS ====================
local function openGUI()
    if isOpen then return end
    isOpen = true
    minimizedBtn.Visible = false
    
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 450, 0, 0)
    mainFrame.BackgroundTransparency = 0.5
    mainStroke.Transparency = 0.5
    
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 350),
        BackgroundTransparency = 0
    }):Play()
    
    TweenService:Create(mainStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Transparency = 0
    }):Play()
end

local function closeGUI()
    if not isOpen then return end
    isOpen = false
    
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 450, 0, 0),
        BackgroundTransparency = 0.5
    }):Play()
    
    TweenService:Create(mainStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Transparency = 0.5
    }):Play()
    
    task.delay(0.3, function()
        mainFrame.Visible = false
        minimizedBtn.Visible = true
    end)
end

local function toggleGUI()
    if isOpen then
        closeGUI()
    else
        openGUI()
    end
end

-- ==================== BUTTON EVENTS ====================
closeBtn.MouseButton1Click:Connect(closeGUI)
minimizedBtn.MouseButton1Click:Connect(openGUI)

minimizedBtn.MouseEnter:Connect(function()
    if not minDragging then
        TweenService:Create(minimizedBtn, TweenInfo.new(0.25), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    end
end)

minimizedBtn.MouseLeave:Connect(function()
    if not minDragging then
        TweenService:Create(minimizedBtn, TweenInfo.new(0.25), {Size = UDim2.new(0, 55, 0, 55)}):Play()
    end
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 80, 80)}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
end)

-- ==================== INPUT HANDLING ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if waitingForInput then
        waitingForInput = false
        toggleKeybind = input.KeyCode
        toggleGuiKey.Text = input.KeyCode.Name
        toggleGuiKey.BackgroundColor3 = getColors().Accent
    elseif waitingForWalkspeedInput then
        waitingForWalkspeedInput = false
        walkspeedToggleKeybind = input.KeyCode
        toggleWalkspeedKey.Text = input.KeyCode.Name
        toggleWalkspeedKey.BackgroundColor3 = getColors().Accent
    elseif input.KeyCode == toggleKeybind then
        toggleGUI()
    elseif waitingForAimbotInput then
        waitingForAimbotInput = false
        aimbotToggleKeybind = input.KeyCode
        toggleAimbotKey.Text = input.KeyCode.Name
        toggleAimbotKey.BackgroundColor3 = getColors().Accent
    elseif input.KeyCode == walkspeedToggleKeybind then
        -- Toggle walkspeed on/off
        walkspeedToggled = not walkspeedToggled
        updateWalkspeedToggleVisual()
        -- Apply or reset speed
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if walkspeedToggled then
                    humanoid.WalkSpeed = currentWalkspeed
                else
                    humanoid.WalkSpeed = 16
                end
            end
        end
    elseif input.KeyCode == aimbotToggleKeybind then
        aimbotToggled = not aimbotToggled
        updateAimbotToggleVisual()
    end
end)

-- ==================== DRAGGING ====================
local dragging = false
local dragStart, startPos
local minDragging = false
local minDragStart, minStartPos

headerBox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

headerBox.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        
        if minDragging then
            local delta = input.Position - minDragStart
            minimizedBtn.Position = UDim2.new(minStartPos.X.Scale, minStartPos.X.Offset + delta.X, minStartPos.Y.Scale, minStartPos.Y.Offset + delta.Y)
        end
        
        if walkspeedDragging then
            local relativeX = (input.Position.X - walkspeedSliderBg.AbsolutePosition.X) / walkspeedSliderBg.AbsoluteSize.X
            local value = minWalkspeed + (maxWalkspeed - minWalkspeed) * math.clamp(relativeX, 0, 1)
            updateWalkspeedSlider(value)
        end
        
        if brainrotDragging then
            local relativeX = (input.Position.X - brainrotSliderBg.AbsolutePosition.X) / brainrotSliderBg.AbsoluteSize.X
            local value = minBrainrot + (maxBrainrot - minBrainrot) * math.clamp(relativeX, 0, 1)
            updateBrainrotSlider(value)
        end
        
        if fovDragging then
            local relativeX = (input.Position.X - fovSliderBg.AbsolutePosition.X) / fovSliderBg.AbsoluteSize.X
            local value = minFov + (maxFov - minFov) * math.clamp(relativeX, 0, 1)
            updateFovSlider(value)
        end
        
        if stretchDragging then
            local relativeX = (input.Position.X - stretchSliderBg.AbsolutePosition.X) / stretchSliderBg.AbsoluteSize.X
            local value = minStretch + (maxStretch - minStretch) * math.clamp(relativeX, 0, 1)
            updateStretchSlider(value)
        end
    end
end)

-- Minimized button dragging
minimizedBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        minDragging = true
        minDragStart = input.Position
        minStartPos = minimizedBtn.Position
    end
end)

minimizedBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        minDragging = false
    end
end)

-- ==================== AIMBOT LOGIC ====================
local function getNearestPlayer()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return nil end
    
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (localRoot.Position - rootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not aimbotToggled then return end
    
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return end
    
    local localHumanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    if not localHumanoid or not localRoot or not camera then return end
    
    local targetPlayer = getNearestPlayer()
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Calculate direction to target
    local targetPosition = targetRoot.Position
    local direction = (targetPosition - localRoot.Position).Unit
    
    -- Make character walk towards target
    localHumanoid:MoveTo(targetPosition)
    
    -- Lock camera to look at target
    local lookCFrame = CFrame.new(localRoot.Position, targetPosition)
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    
    -- Force character to face target
    localRoot.CFrame = CFrame.new(localRoot.Position, targetPosition)
end)

-- ==================== RAINBOW EFFECT ====================
task.spawn(function()
    while true do
        task.wait(0.03)
        if currentTheme == "Rainbow" then
            rainbowHue = (rainbowHue + 0.01) % 1
            local colors = getColors()
            colors.Accent = Color3.fromHSV(rainbowHue, 0.7, 1)
            mainStroke.Color = colors.Accent
            settingsTab.BackgroundColor3 = colors.Accent
            toggleGuiKey.BackgroundColor3 = colors.Accent
            toggleWalkspeedKey.BackgroundColor3 = colors.Accent
            toggleAimbotKey.BackgroundColor3 = colors.Accent
            fovSliderFill.BackgroundColor3 = colors.Accent
            fovSliderKnobStroke.Color = colors.Accent
            fovInput.TextColor3 = colors.Accent
            stretchSliderFill.BackgroundColor3 = colors.Accent
            stretchSliderKnobStroke.Color = colors.Accent
            stretchInput.TextColor3 = colors.Accent
            minimizedBtn.BackgroundColor3 = colors.Accent
            walkspeedSliderFill.BackgroundColor3 = colors.Accent
            walkspeedSliderKnobStroke.Color = colors.Accent
            walkspeedInput.TextColor3 = colors.Accent
            brainrotSliderFill.BackgroundColor3 = colors.Accent
            brainrotSliderKnobStroke.Color = colors.Accent
            brainrotInput.TextColor3 = colors.Accent
            noAnimSection.BackgroundColor3 = colors.Accent
            fpsPingSection.BackgroundColor3 = colors.Accent
            fpsPingDisplayStroke.Color = colors.Accent
            fpsLabel.TextColor3 = colors.Accent
            pingLabel.TextColor3 = colors.Text
            if loadingFrame and loadingFrame.Parent then
                loadingStroke.Color = colors.Accent
            end
        end
    end
end)
