-- // [1] SERVICES //
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer

-- // [2] CONFIGURATION //
local CONFIG = {
    Names = {
        ScreenGui = "AscendHubGUI",
        StealBarGui = "StealBarGui",
        MainPanel = "MainPanel",
        HUBFrame = "HUDFrame",
        BoosterPanel = "BoosterPanel",
        ServerPanel = "ServerPanel",
        InstantStealPanel = "InstantStealPanel",
        BaseProtPanel = "BaseProtPanel",
        Btn1 = "Btn1",
        Btn2 = "Btn2",
        Btn3 = "Btn3",
        MenuToggleBtn = "MenuToggleBtn"
    },
    Colors = {
        MainFrame = Color3.fromRGB(15, 12, 41),
        MainFrameTransparency = 0.8,
        ButtonActive = Color3.fromRGB(88, 24, 180),
        ButtonInactive = Color3.fromRGB(45, 15, 90),
        Accent = Color3.fromRGB(138, 43, 226),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 210),
        Danger = Color3.fromRGB(180, 30, 30),
        Success = Color3.fromRGB(0, 180, 0)
    },
    Positions = {
        HubFrame = UDim2.new(0.5, -110, 0, 40),
        MenuToggle = UDim2.new(0.5, -30, 0, 100),
        MainPanel = UDim2.new(0.5, -140, 0.5, -170),
        StealBar = UDim2.new(0.5, -120, 1, -100),
        BoosterPanel = UDim2.new(1, -170, 0.5, -100),
        ServerPanel = UDim2.new(1, -170, 0.5, 110),
        InstantStealPanel = UDim2.new(1, -170, 0.5, -274),
        BaseProtPanel = UDim2.new(1, -170, 0.5, -482)
    },
    Sizes = {
        HubFrame = UDim2.new(0, 220, 0, 56),
        MenuToggle = UDim2.new(0, 60, 0, 28),
        MainPanel = UDim2.new(0, 280, 0, 340),
        StealBar = UDim2.new(0, 240, 0, 40),
        BoosterPanel = UDim2.new(0, 160, 0, 200),
        ServerPanel = UDim2.new(0, 160, 0, 158),
        InstantStealPanel = UDim2.new(0, 160, 0, 164),
        BaseProtPanel = UDim2.new(0, 160, 0, 198),
        Button = UDim2.new(0, 34, 0, 34)
    }
}

-- // [3] OBJECT REFERENCES //
local ScreenGui
local StealBarGui
local HubFrame
local MainPanel
local MenuToggleBtn
local Buttons = {}
local Tabs = {}
local ContentFrames = {}
local BoosterFrame
local ServerFrame
local InstantStealFrame
local BaseProtFrame
local StealBarFrame
local StealProgressFrame
local FOVSliderFrame
local AspectSliderFrame
local WalkSpeedSlider

-- State variables
local CurrentTab = "Main"
local EspEnabled = false
local AnimalEspEnabled = false
local FriendAllowEspEnabled = false
local XrayEnabled = false
local CustomFOVEnabled = false
local DarkModeEnabled = false
local DeleteAnimationsEnabled = false
local AspectRatioEnabled = false
local WalkSpeedValue = 16
local StealSpeedValue = 10
local CurrentFOV = 70
local CurrentAspect = 100
local IsDraggingMainPanel = false
local DragStart
local OriginalMainPanelPosition

-- // [4] UTILITY FUNCTIONS //
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    if not char then return end
    return char:FindFirstChildOfClass("Humanoid")
end

local function getNetworkPing()
    local stats = game:GetService("Stats")
    local network = stats:FindFirstChild("Network")
    if network then
        local serverStats = network:FindFirstChild("ServerStatsItem")
        if serverStats then
            local dataPing = serverStats:FindFirstChild("DataPing")
            if dataPing then
                return math.floor(dataPing:GetValue())
            end
        end
    end
    return 0
end

local function updateStatsDisplay()
    local fpsLabel = HubFrame:FindFirstChild("FPSLabel")
    if fpsLabel then
        local ping = getNetworkPing()
        fpsLabel.Text = string.format("FPS: %d;PING: %dms", 60, ping)
    end
end

local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createUIStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness
    stroke.Color = color
    stroke.Parent = parent
    return stroke
end

local function createUIGradient(parent, colorSequence)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Parent = parent
    return gradient
end

local function createUIPadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    if top then padding.PaddingTop = UDim.new(0, top) end
    if bottom then padding.PaddingBottom = UDim.new(0, bottom) end
    if left then padding.PaddingLeft = UDim.new(0, left) end
    if right then padding.PaddingRight = UDim.new(0, right) end
    padding.Parent = parent
    return padding
end

local function createSlider(parent, name, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Slider"
    frame.Size = UDim2.new(1, -20, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -16, 0, 4)
    bg.Position = UDim2.new(0, 8, 0, 15)
    bg.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    bg.BorderSizePixel = 0
    createUICorner(bg, 2)
    bg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -10, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.AutoButtonColor = false
    createUICorner(knob, 10)
    knob.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(1, -45, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = CONFIG.Colors.Text
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 14)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = CONFIG.Colors.TextDim
    title.TextSize = 11
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local dragging = false
    local function update(value)
        local newValue = math.clamp(value, minVal, maxVal)
        local percent = (newValue - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -10, 0.5, -10)
        valueLabel.Text = tostring(math.floor(newValue))
        if callback then callback(newValue) end
    end
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos.X - knob.AbsolutePosition.X
            local totalWidth = bg.AbsoluteSize.X
            local percent = math.clamp(relativePos / totalWidth, 0, 1)
            update(minVal + percent * (maxVal - minVal))
        end
    end)
    
    update(defaultVal)
    return frame
end

local function createToggle(parent, name, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Toggle"
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = CONFIG.Colors.TextDim
    title.TextSize = 12
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -54, 0.5, -12)
    toggleBtn.BackgroundColor3 = defaultValue and CONFIG.Colors.Accent or CONFIG.Colors.ButtonInactive
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    createUICorner(toggleBtn, 10)
    toggleBtn.Parent = frame
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(defaultValue and 1 or 0, -22, 0.5, -10)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    createUICorner(toggleIndicator, 9)
    toggleIndicator.Parent = toggleBtn
    
    local active = defaultValue
    local function setActive(value)
        active = value
        toggleBtn.BackgroundColor3 = active and CONFIG.Colors.Accent or CONFIG.Colors.ButtonInactive
        toggleIndicator.Position = UDim2.new(active and 1 or 0, active and -22 or 2, 0.5, -10)
        if callback then callback(active) end
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        setActive(not active)
    end)
    
    setActive(defaultValue)
    return frame, setActive
end

-- // [5] GUI CREATION //
local function createGUI()
    -- Main ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = CONFIG.Names.ScreenGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    -- Hub Frame (Main HUD)
    HubFrame = Instance.new("Frame")
    HubFrame.Name = CONFIG.Names.HUBFrame
    HubFrame.Size = CONFIG.Sizes.HubFrame
    HubFrame.Position = CONFIG.Positions.HubFrame
    HubFrame.BackgroundColor3 = CONFIG.Colors.MainFrame
    HubFrame.BackgroundTransparency = CONFIG.Colors.MainFrameTransparency
    HubFrame.BorderSizePixel = 0
    HubFrame.Parent = ScreenGui
    
    createUICorner(HubFrame, 14)
    createUIStroke(HubFrame, 2, CONFIG.Colors.Text)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.Position = UDim2.new(0, 0, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "omahad"
    titleLabel.TextColor3 = CONFIG.Colors.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.ZIndex = 2
    titleLabel.Parent = HubFrame
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 14)
    subLabel.Position = UDim2.new(0, 0, 0, 24)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "gg/sabscripts"
    subLabel.TextColor3 = CONFIG.Colors.TextDim
    subLabel.TextSize = 11
    subLabel.Parent = HubFrame
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "FPSLabel"
    statsLabel.Size = UDim2.new(1, 0, 0, 14)
    statsLabel.Position = UDim2.new(0, 0, 0, 38)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "FPS: --;PING: --ms"
    statsLabel.TextColor3 = CONFIG.Colors.TextDim
    statsLabel.TextSize = 11
    statsLabel.Parent = HubFrame
    
    -- Action Buttons
    local buttonPositions = { -57, -17, 23 }
    for i = 1, 3 do
        local btn = Instance.new("TextButton")
        btn.Name = CONFIG.Names["Btn" .. i]
        btn.Size = CONFIG.Sizes.Button
        btn.Position = UDim2.new(0.5, buttonPositions[i], 0, 0)
        btn.BackgroundColor3 = CONFIG.Colors.MainFrame
        btn.BackgroundTransparency = 0.6
        btn.BorderSizePixel = 0
        btn.Text = tostring(i)
        btn.TextColor3 = CONFIG.Colors.Text
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 2
        btn.AutoButtonColor = false
        btn.Active = true
        btn.Visible = true
        btn.Parent = ScreenGui
        
        createUICorner(btn, 7)
        createUIStroke(btn, 2, CONFIG.Colors.Text)
        
        Buttons[i] = btn
    end
    
    -- Menu Toggle Button
    MenuToggleBtn = Instance.new("TextButton")
    MenuToggleBtn.Name = CONFIG.Names.MenuToggleBtn
    MenuToggleBtn.Size = CONFIG.Sizes.MenuToggle
    MenuToggleBtn.Position = CONFIG.Positions.MenuToggle
    MenuToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 27, 105)
    MenuToggleBtn.BackgroundTransparency = 0.3
    MenuToggleBtn.Text = "Menu"
    MenuToggleBtn.TextSize = 14
    MenuToggleBtn.ZIndex = 3
    MenuToggleBtn.Parent = ScreenGui
    createUICorner(MenuToggleBtn, 6)
    createUIStroke(MenuToggleBtn, 1, CONFIG.Colors.Text)
    
    -- Main Panel
    MainPanel = Instance.new("Frame")
    MainPanel.Name = CONFIG.Names.MainPanel
    MainPanel.Size = CONFIG.Sizes.MainPanel
    MainPanel.Position = CONFIG.Positions.MainPanel
    MainPanel.BackgroundTransparency = 0.6
    MainPanel.Visible = false
    MainPanel.ZIndex = 10
    MainPanel.Active = true
    MainPanel.Draggable = true
    MainPanel.Parent = ScreenGui
    createUICorner(MainPanel, 14)
    createUIStroke(MainPanel, 2, CONFIG.Colors.Text)
    
    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -20, 0, 36)
    panelTitle.Position = UDim2.new(0, 10, 0, 8)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "omagad"
    panelTitle.TextColor3 = CONFIG.Colors.Text
    panelTitle.TextSize = 18
    panelTitle.Font = Enum.Font.GothamBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.ZIndex = 11
    panelTitle.Parent = MainPanel
    
    local titleSeparator = Instance.new("Frame")
    titleSeparator.Size = UDim2.new(1, -20, 0, 1)
    titleSeparator.Position = UDim2.new(0, 10, 0, 46)
    titleSeparator.BackgroundColor3 = CONFIG.Colors.Text
    titleSeparator.ZIndex = 11
    titleSeparator.Parent = MainPanel
    
    -- Tabs
    local tabMain = Instance.new("TextButton")
    tabMain.Name = "Tab_Main"
    tabMain.Size = UDim2.new(0, 126, 0, 30)
    tabMain.Position = UDim2.new(0, 10, 0, 52)
    tabMain.Text = "Main"
    tabMain.TextSize = 13
    tabMain.ZIndex = 11
    tabMain.Parent = MainPanel
    createUICorner(tabMain, 8)
    
    local tabVisual = Instance.new("TextButton")
    tabVisual.Name = "Tab_Visual"
    tabVisual.Size = UDim2.new(0, 126, 0, 30)
    tabVisual.Position = UDim2.new(0, 140, 0, 52)
    tabVisual.Text = "Visual"
    tabVisual.TextSize = 13
    tabVisual.ZIndex = 11
    tabVisual.Parent = MainPanel
    createUICorner(tabVisual, 8)
    
    Tabs.Main = tabMain
    Tabs.Visual = tabVisual
    
    -- Content Frames
    local contentMain = Instance.new("ScrollingFrame")
    contentMain.Name = "Content_Main"
    contentMain.Size = UDim2.new(1, -20, 1, -96)
    contentMain.Position = UDim2.new(0, 10, 0, 90)
    contentMain.BackgroundTransparency = 1
    contentMain.BorderSizePixel = 0
    contentMain.ScrollBarThickness = 3
    contentMain.ScrollBarImageColor3 = CONFIG.Colors.Accent
    contentMain.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentMain.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentMain.Visible = true
    contentMain.ZIndex = 11
    contentMain.Parent = MainPanel
    
    local mainList = Instance.new("UIListLayout")
    mainList.SortOrder = Enum.SortOrder.LayoutOrder
    mainList.Padding = UDim.new(0, 6)
    mainList.Parent = contentMain
    
    local contentVisual = Instance.new("ScrollingFrame")
    contentVisual.Name = "Content_Visual"
    contentVisual.Size = UDim2.new(1, -20, 1, -96)
    contentVisual.Position = UDim2.new(0, 10, 0, 90)
    contentVisual.BackgroundTransparency = 1
    contentVisual.BorderSizePixel = 0
    contentVisual.ScrollBarThickness = 3
    contentVisual.ScrollBarImageColor3 = CONFIG.Colors.Accent
    contentVisual.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentVisual.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentVisual.Visible = false
    contentVisual.ZIndex = 11
    contentVisual.Parent = MainPanel
    
    local visualList = Instance.new("UIListLayout")
    visualList.SortOrder = Enum.SortOrder.LayoutOrder
    visualList.Padding = UDim.new(0, 6)
    visualList.Parent = contentVisual
    
    ContentFrames.Main = contentMain
    ContentFrames.Visual = contentVisual
    
    -- Steal Bar GUI
    StealBarGui = Instance.new("ScreenGui")
    StealBarGui.Name = CONFIG.Names.StealBarGui
    StealBarGui.DisplayOrder = 998
    StealBarGui.Parent = CoreGui
    
    StealBarFrame = Instance.new("Frame")
    StealBarFrame.Size = CONFIG.Sizes.StealBar
    StealBarFrame.Position = CONFIG.Positions.StealBar
    StealBarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    StealBarFrame.Visible = true
    StealBarFrame.ZIndex = 20
    StealBarFrame.Parent = StealBarGui
    createUICorner(StealBarFrame, 12)
    createUIStroke(StealBarFrame, 2, CONFIG.Colors.Text)
    
    local stealTitle = Instance.new("TextLabel")
    stealTitle.Size = UDim2.new(1, 0, 0, 16)
    stealTitle.Position = UDim2.new(0, 0, 0, 6)
    stealTitle.BackgroundTransparency = 1
    stealTitle.Text = "Steal Bar"
    stealTitle.TextColor3 = CONFIG.Colors.Text
    stealTitle.TextSize = 12
    stealTitle.ZIndex = 21
    stealTitle.Parent = StealBarFrame
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 10)
    barBg.Position = UDim2.new(0, 12, 0, 28)
    barBg.BackgroundColor3 = Color3.fromRGB(70, 65, 120)
    barBg.ZIndex = 21
    barBg.Parent = StealBarFrame
    createUICorner(barBg, 5)
    
    StealProgressFrame = Instance.new("Frame")
    StealProgressFrame.Size = UDim2.new(0, 0, 1, 0)
    StealProgressFrame.BackgroundColor3 = CONFIG.Colors.Accent
    StealProgressFrame.ZIndex = 22
    StealProgressFrame.Parent = barBg
    createUICorner(StealProgressFrame, 5)
    
    -- Booster Panel
    BoosterFrame = Instance.new("Frame")
    BoosterFrame.Name = CONFIG.Names.BoosterPanel
    BoosterFrame.Size = CONFIG.Sizes.BoosterPanel
    BoosterFrame.Position = CONFIG.Positions.BoosterPanel
    BoosterFrame.Active = true
    BoosterFrame.Parent = MainPanel
    createUICorner(BoosterFrame, 14)
    createUIStroke(BoosterFrame, 2, CONFIG.Colors.Text)
    
    local boosterTitle = Instance.new("TextLabel")
    boosterTitle.Size = UDim2.new(1, -12, 0, 28)
    boosterTitle.Position = UDim2.new(0, 10, 0, 6)
    boosterTitle.BackgroundTransparency = 1
    boosterTitle.Text = "Booster"
    boosterTitle.TextColor3 = CONFIG.Colors.Text
    boosterTitle.TextSize = 13
    boosterTitle.Parent = BoosterFrame
    
    local boosterContent = Instance.new("Frame")
    boosterContent.Size = UDim2.new(1, -20, 1, -44)
    boosterContent.Position = UDim2.new(0, 10, 0, 44)
    boosterContent.BackgroundTransparency = 1
    boosterContent.Parent = BoosterFrame
    
    local boosterList = Instance.new("UIListLayout")
    boosterList.SortOrder = Enum.SortOrder.LayoutOrder
    boosterList.Padding = UDim.new(0, 6)
    boosterList.Parent = boosterContent
    
    local boosterPadding = Instance.new("UIPadding")
    boosterPadding.PaddingTop = UDim.new(0, 6)
    boosterPadding.Parent = boosterContent
    
    -- Server Panel
    ServerFrame = Instance.new("Frame")
    ServerFrame.Name = CONFIG.Names.ServerPanel
    ServerFrame.Size = CONFIG.Sizes.ServerPanel
    ServerFrame.Position = CONFIG.Positions.ServerPanel
    ServerFrame.Parent = MainPanel
    createUICorner(ServerFrame, 14)
    createUIStroke(ServerFrame, 2, CONFIG.Colors.Text)
    
    local serverTitle = Instance.new("TextLabel")
    serverTitle.Size = UDim2.new(1, -12, 0, 28)
    serverTitle.Position = UDim2.new(0, 10, 0, 6)
    serverTitle.BackgroundTransparency = 1
    serverTitle.Text = "Server"
    serverTitle.TextColor3 = CONFIG.Colors.Text
    serverTitle.TextSize = 13
    serverTitle.Parent = ServerFrame
    
    local serverContent = Instance.new("Frame")
    serverContent.Size = UDim2.new(1, -20, 1, -44)
    serverContent.Position = UDim2.new(0, 10, 0, 44)
    serverContent.BackgroundTransparency = 1
    serverContent.Parent = ServerFrame
    
    local serverList = Instance.new("UIListLayout")
    serverList.SortOrder = Enum.SortOrder.LayoutOrder
    serverList.Padding = UDim.new(0, 6)
    serverList.Parent = serverContent
    
    local serverPadding = Instance.new("UIPadding")
    serverPadding.PaddingTop = UDim.new(0, 6)
    serverPadding.Parent = serverContent
    
    -- Instant Steal Panel
    InstantStealFrame = Instance.new("Frame")
    InstantStealFrame.Name = CONFIG.Names.InstantStealPanel
    InstantStealFrame.Size = CONFIG.Sizes.InstantStealPanel
    InstantStealFrame.Position = CONFIG.Positions.InstantStealPanel
    InstantStealFrame.Parent = MainPanel
    createUICorner(InstantStealFrame, 14)
    createUIStroke(InstantStealFrame, 2, CONFIG.Colors.Text)
    
    local instantTitleFrame = Instance.new("Frame")
    instantTitleFrame.Size = UDim2.new(1, -20, 0, 34)
    instantTitleFrame.Position = UDim2.new(0, 10, 0, 10)
    instantTitleFrame.BackgroundTransparency = 1
    instantTitleFrame.Parent = InstantStealFrame
    
    local instantTitle = Instance.new("TextLabel")
    instantTitle.Size = UDim2.new(0, 120, 1, 0)
    instantTitle.Position = UDim2.new(0, 0, 0, 0)
    instantTitle.BackgroundTransparency = 1
    instantTitle.Text = "Instant Steal V2"
    instantTitle.TextColor3 = CONFIG.Colors.Text
    instantTitle.TextSize = 12
    instantTitle.TextXAlignment = Enum.TextXAlignment.Left
    instantTitle.Parent = instantTitleFrame
    
    local instantContent = Instance.new("Frame")
    instantContent.Size = UDim2.new(1, -20, 1, -54)
    instantContent.Position = UDim2.new(0, 10, 0, 54)
    instantContent.BackgroundTransparency = 1
    instantContent.Parent = InstantStealFrame
    
    local instantList = Instance.new("UIListLayout")
    instantList.SortOrder = Enum.SortOrder.LayoutOrder
    instantList.Padding = UDim.new(0, 6)
    instantList.Parent = instantContent
    
    local instantPadding = Instance.new("UIPadding")
    instantPadding.PaddingTop = UDim.new(0, 6)
    instantPadding.Parent = instantContent
    
    -- Base Protection Panel
    BaseProtFrame = Instance.new("Frame")
    BaseProtFrame.Name = CONFIG.Names.BaseProtPanel
    BaseProtFrame.Size = CONFIG.Sizes.BaseProtPanel
    BaseProtFrame.Position = CONFIG.Positions.BaseProtPanel
    BaseProtFrame.Parent = MainPanel
    createUICorner(BaseProtFrame, 14)
    createUIStroke(BaseProtFrame, 2, CONFIG.Colors.Text)
    
    local baseTitle = Instance.new("TextLabel")
    baseTitle.Size = UDim2.new(1, -12, 0, 28)
    baseTitle.Position = UDim2.new(0, 10, 0, 6)
    baseTitle.BackgroundTransparency = 1
    baseTitle.Text = "Base Prot"
    baseTitle.TextColor3 = CONFIG.Colors.Text
    baseTitle.TextSize = 13
    baseTitle.Parent = BaseProtFrame
    
    local baseContent = Instance.new("Frame")
    baseContent.Size = UDim2.new(1, -20, 1, -44)
    baseContent.Position = UDim2.new(0, 10, 0, 44)
    baseContent.BackgroundTransparency = 1
    baseContent.Parent = BaseProtFrame
    
    local baseList = Instance.new("UIListLayout")
    baseList.SortOrder = Enum.SortOrder.LayoutOrder
    baseList.Padding = UDim.new(0, 6)
    baseList.Parent = baseContent
    
    local basePadding = Instance.new("UIPadding")
    basePadding.PaddingTop = UDim.new(0, 6)
    basePadding.Parent = baseContent
end

-- // [6] FUNCTIONALITY //
local ButtonFunctions = {}

-- Helper to create panel item (toggle/slider)
local function addPanelItem(parent, title, itemType, defaultValue, callback)
    if itemType == "toggle" then
        return createToggle(parent, title, defaultValue, callback)
    elseif itemType == "slider" then
        return createSlider(parent, title, 1, 100, defaultValue, callback)
    end
    return nil
end

-- Build Main Tab content
local function buildMainTab()
    local content = ContentFrames.Main
    
    -- Instant Steal toggle
    addPanelItem(content, "Instant Steal", "toggle", false, function(enabled)
        if enabled then
            -- Instant Steal logic
            local hrp = getHRP()
            if hrp then
                local remote = ReplicatedStorage:FindFirstChild("Packages")
                if remote then
                    local net = remote:FindFirstChild("Net")
                    if net then
                        local stealRemote = net:FindFirstChild("RE")
                        if stealRemote then
                            local stealService = stealRemote:FindFirstChild("StealService")
                            if stealService then
                                local grabRemote = stealService:FindFirstChild("Grab")
                                if grabRemote then
                                    grabRemote:FireServer()
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Auto Steal toggle
    addPanelItem(content, "Auto Steal (New)", "toggle", false, function(enabled)
        if enabled then
            -- Auto Steal logic - will be handled in loop
        end
    end)
    
    -- Unlock Base button
    local unlockBtnFrame = Instance.new("Frame")
    unlockBtnFrame.Size = UDim2.new(1, -20, 0, 40)
    unlockBtnFrame.BackgroundColor3 = Color3.fromRGB(55, 50, 105)
    unlockBtnFrame.BackgroundTransparency = 0.2
    unlockBtnFrame.Parent = content
    createUICorner(unlockBtnFrame, 8)
    
    local unlockLabel = Instance.new("TextLabel")
    unlockLabel.Size = UDim2.new(1, -60, 1, 0)
    unlockLabel.Position = UDim2.new(0, 10, 0, 0)
    unlockLabel.BackgroundTransparency = 1
    unlockLabel.Text = "Unlock Base"
    unlockLabel.TextColor3 = CONFIG.Colors.Text
    unlockLabel.TextSize = 12
    unlockLabel.TextXAlignment = Enum.TextXAlignment.Left
    unlockLabel.Parent = unlockBtnFrame
    
    local unlockButton = Instance.new("TextButton")
    unlockButton.Size = UDim2.new(0, 80, 0, 30)
    unlockButton.Position = UDim2.new(1, -90, 0.5, -15)
    unlockButton.BackgroundColor3 = CONFIG.Colors.Accent
    unlockButton.Text = "Unlock"
    unlockButton.TextColor3 = CONFIG.Colors.Text
    unlockButton.TextSize = 12
    createUICorner(unlockButton, 8)
    unlockButton.Parent = unlockBtnFrame
    
    unlockButton.MouseButton1Click:Connect(function()
        -- Unlock Base logic
        local plotId = nil
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            local unlock = plot:FindFirstChild("Unlock")
            if unlock then
                local main = unlock:FindFirstChild("Main")
                if main and main:IsA("BasePart") then
                    plotId = plot.Name
                    break
                end
            end
        end
        if plotId then
            local remote = ReplicatedStorage:FindFirstChild("Packages")
            if remote then
                local net = remote:FindFirstChild("Net")
                if net then
                    local re = net:FindFirstChild("RE")
                    if re then
                        local unlockRemote = re:FindFirstChild("9cdbc856ee399074402c14861bd997a45b142aa0a50b40ad7c55bfff00c2d7c3")
                        if unlockRemote then
                            unlockRemote:FireServer(tostring(os.time()) .. ", " .. game:GetService("HttpService"):GenerateGUID(false), plotId, 1)
                        end
                    end
                end
            end
        end
    end)
end

-- Build Visual Tab content
local function buildVisualTab()
    local content = ContentFrames.Visual
    
    -- ESP Players toggle
    addPanelItem(content, "ESP Players", "toggle", false, function(enabled)
        EspEnabled = enabled
        if enabled then
            -- ESP logic - highlight players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    if char then
                        local highlight = char:FindFirstChild("PlayerESP")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "PlayerESP"
                            highlight.Adornee = char
                            highlight.FillColor = CONFIG.Colors.Accent
                            highlight.OutlineColor = CONFIG.Colors.Accent
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            highlight.Parent = char
                        end
                        local billboard = char:FindFirstChild("HumanoidRootPart")
                        if billboard then
                            local nameTag = billboard:FindFirstChild("PlayerNameESP")
                            if not nameTag then
                                nameTag = Instance.new("BillboardGui")
                                nameTag.Name = "PlayerNameESP"
                                nameTag.Adornee = billboard
                                nameTag.Size = UDim2.new(0, 200, 0, 50)
                                nameTag.StudsOffset = Vector3.new(0, 3, 0)
                                nameTag.AlwaysOnTop = true
                                nameTag.Parent = billboard
                                
                                local nameLabel = Instance.new("TextLabel")
                                nameLabel.Size = UDim2.new(1, 0, 0, 20)
                                nameLabel.Position = UDim2.new(0, 0, 0, 0)
                                nameLabel.BackgroundTransparency = 1
                                nameLabel.Text = player.DisplayName
                                nameLabel.TextColor3 = CONFIG.Colors.Text
                                nameLabel.TextStrokeTransparency = 0.5
                                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                nameLabel.TextSize = 16
                                nameLabel.Parent = nameTag
                                
                                local userLabel = Instance.new("TextLabel")
                                userLabel.Size = UDim2.new(1, 0, 0, 20)
                                userLabel.Position = UDim2.new(0, 0, 0, 20)
                                userLabel.BackgroundTransparency = 1
                                userLabel.Text = "@" .. player.Name
                                userLabel.TextColor3 = CONFIG.Colors.TextDim
                                userLabel.TextSize = 12
                                userLabel.Font = Enum.Font.Gotham
                                userLabel.Parent = nameTag
                            end
                        end
                    end
                end
            end
        else
            -- Remove ESP
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    if char then
                        local highlight = char:FindFirstChild("PlayerESP")
                        if highlight then highlight:Destroy() end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local nameTag = hrp:FindFirstChild("PlayerNameESP")
                            if nameTag then nameTag:Destroy() end
                        end
                    end
                end
            end
        end
    end)
    
    -- Animal ESP toggle
    addPanelItem(content, "Animal ESP", "toggle", false, function(enabled)
        AnimalEspEnabled = enabled
        -- Animal ESP logic - will be handled in loop
    end)
    
    -- Friend Allow ESP toggle
    addPanelItem(content, "Friend Allow ESP", "toggle", false, function(enabled)
        FriendAllowEspEnabled = enabled
        -- Friend Allow ESP logic
    end)
    
    -- Xray toggle
    addPanelItem(content, "Xray", "toggle", false, function(enabled)
        XrayEnabled = enabled
        if enabled then
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = 0.5
                    part.Material = Enum.Material.Plastic
                end
            end
        else
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end)
    
    -- Custom FOV toggle and slider
    addPanelItem(content, "Custom FOV", "toggle", false, function(enabled)
        CustomFOVEnabled = enabled
        if enabled then
            Workspace.CurrentCamera.FieldOfView = CurrentFOV
        else
            Workspace.CurrentCamera.FieldOfView = 70
        end
    end)
    
    local fovSliderFrame = createSlider(content, "FOV Value", 70, 120, CurrentFOV, function(value)
        CurrentFOV = value
        if CustomFOVEnabled then
            Workspace.CurrentCamera.FieldOfView = value
        end
    end)
    fovSliderFrame.LayoutOrder = 7
    
    -- Dark Mode toggle
    addPanelItem(content, "Dark Mode", "toggle", false, function(enabled)
        DarkModeEnabled = enabled
        if enabled then
            Lighting.Brightness = 0.5
            Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
            Lighting.Ambient = Color3.fromRGB(30, 30, 30)
        else
            Lighting.Brightness = 2
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end)
    
    -- Delete Animations toggle
    addPanelItem(content, "Delete Animations", "toggle", false, function(enabled)
        DeleteAnimationsEnabled = enabled
        -- Animation deletion logic
    end)
    
    -- Aspect Ratio toggle and slider
    addPanelItem(content, "Aspect Ratio", "toggle", false, function(enabled)
        AspectRatioEnabled = enabled
        if enabled then
            -- Aspect ratio logic
        end
    end)
    
    local aspectSliderFrame = createSlider(content, "Aspect Ratio %", 50, 150, CurrentAspect, function(value)
        CurrentAspect = value
        if AspectRatioEnabled then
            -- Apply aspect ratio
        end
    end)
    aspectSliderFrame.LayoutOrder = 11
end

-- Build Booster Panel content
local function buildBoosterPanel()
    local content = BoosterFrame:FindFirstChildOfClass("Frame")
    if not content then return end
    
    -- Walk Speed slider
    local walkSpeedFrame = Instance.new("Frame")
    walkSpeedFrame.Size = UDim2.new(1, -20, 0, 34)
    walkSpeedFrame.BackgroundTransparency = 1
    walkSpeedFrame.Parent = content
    createUICorner(walkSpeedFrame, 8)
    
    local walkLabel = Instance.new("TextLabel")
    walkLabel.Size = UDim2.new(1, -50, 1, 0)
    walkLabel.Position = UDim2.new(0, 8, 0, 0)
    walkLabel.BackgroundTransparency = 1
    walkLabel.Text = "Walk Speed"
    walkLabel.TextColor3 = CONFIG.Colors.Text
    walkLabel.TextSize = 12
    walkLabel.TextXAlignment = Enum.TextXAlignment.Left
    walkLabel.Parent = walkSpeedFrame
    
    local walkValueFrame = Instance.new("Frame")
    walkValueFrame.Size = UDim2.new(0, 42, 0, 22)
    walkValueFrame.Position = UDim2.new(1, -50, 0.5, -11)
    walkValueFrame.BackgroundColor3 = CONFIG.Colors.ButtonInactive
    walkValueFrame.Parent = walkSpeedFrame
    createUICorner(walkValueFrame, 6)
    
    local walkValueLabel = Instance.new("TextLabel")
    walkValueLabel.Size = UDim2.new(1, 0, 1, 0)
    walkValueLabel.BackgroundTransparency = 1
    walkValueLabel.Text = tostring(WalkSpeedValue)
    walkValueLabel.TextColor3 = CONFIG.Colors.Text
    walkValueLabel.TextSize = 12
    walkValueLabel.Parent = walkValueFrame
    
    local walkSliderBg = Instance.new("Frame")
    walkSliderBg.Size = UDim2.new(1, -16, 0, 4)
    walkSliderBg.Position = UDim2.new(0, 8, 0, 28)
    walkSliderBg.BackgroundColor3 = Color3.fromRGB(70, 65, 120)
    walkSliderBg.BorderSizePixel = 0
    createUICorner(walkSliderBg, 2)
    walkSliderBg.Parent = walkSpeedFrame
    
    local walkSliderFill = Instance.new("Frame")
    walkSliderFill.Size = UDim2.new((WalkSpeedValue - 16) / (50 - 16), 0, 1, 0)
    walkSliderFill.BackgroundColor3 = CONFIG.Colors.Accent
    walkSliderFill.BorderSizePixel = 0
    walkSliderFill.Parent = walkSliderBg
    
    local walkKnob = Instance.new("TextButton")
    walkKnob.Size = UDim2.new(0, 18, 0, 18)
    walkKnob.Position = UDim2.new((WalkSpeedValue - 16) / (50 - 16), -9, 0.5, -9)
    walkKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    walkKnob.Text = ""
    createUICorner(walkKnob, 9)
    walkKnob.Parent = walkSpeedFrame
    
    local dragging = false
    local function updateWalkSpeed(value)
        local newVal = math.clamp(value, 16, 50)
        local percent = (newVal - 16) / (50 - 16)
        walkSliderFill.Size = UDim2.new(percent, 0, 1, 0)
        walkKnob.Position = UDim2.new(percent, -9, 0.5, -9)
        walkValueLabel.Text = tostring(math.floor(newVal))
        WalkSpeedValue = newVal
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = newVal
        end
    end
    
    walkKnob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos.X - walkKnob.AbsolutePosition.X
            local totalWidth = walkSliderBg.AbsoluteSize.X
            local percent = math.clamp(relativePos / totalWidth, 0, 1)
            updateWalkSpeed(16 + percent * (50 - 16))
        end
    end)
    
    updateWalkSpeed(WalkSpeedValue)
    
    -- Steal Speed slider (similar)
    local stealSpeedFrame = Instance.new("Frame")
    stealSpeedFrame.Size = UDim2.new(1, -20, 0, 34)
    stealSpeedFrame.BackgroundTransparency = 1
    stealSpeedFrame.Parent = content
    
    local stealLabel = Instance.new("TextLabel")
    stealLabel.Size = UDim2.new(1, -50, 1, 0)
    stealLabel.Position = UDim2.new(0, 8, 0, 0)
    stealLabel.BackgroundTransparency = 1
    stealLabel.Text = "Steal Speed"
    stealLabel.TextColor3 = CONFIG.Colors.Text
    stealLabel.TextSize = 12
    stealLabel.TextXAlignment = Enum.TextXAlignment.Left
    stealLabel.Parent = stealSpeedFrame
    
    local stealValueFrame = Instance.new("Frame")
    stealValueFrame.Size = UDim2.new(0, 42, 0, 22)
    stealValueFrame.Position = UDim2.new(1, -50, 0.5, -11)
    stealValueFrame.BackgroundColor3 = CONFIG.Colors.ButtonInactive
    stealValueFrame.Parent = stealSpeedFrame
    createUICorner(stealValueFrame, 6)
    
    local stealValueLabel = Instance.new("TextLabel")
    stealValueLabel.Size = UDim2.new(1, 0, 1, 0)
    stealValueLabel.BackgroundTransparency = 1
    stealValueLabel.Text = tostring(StealSpeedValue)
    stealValueLabel.TextColor3 = CONFIG.Colors.Text
    stealValueLabel.TextSize = 12
    stealValueLabel.Parent = stealValueFrame
    
    local stealSliderBg = Instance.new("Frame")
    stealSliderBg.Size = UDim2.new(1, -16, 0, 4)
    stealSliderBg.Position = UDim2.new(0, 8, 0, 28)
    stealSliderBg.BackgroundColor3 = Color3.fromRGB(70, 65, 120)
    stealSliderBg.BorderSizePixel = 0
    createUICorner(stealSliderBg, 2)
    stealSliderBg.Parent = stealSpeedFrame
    
    local stealSliderFill = Instance.new("Frame")
    stealSliderFill.Size = UDim2.new((StealSpeedValue - 1) / (30 - 1), 0, 1, 0)
    stealSliderFill.BackgroundColor3 = CONFIG.Colors.Accent
    stealSliderFill.BorderSizePixel = 0
    stealSliderFill.Parent = stealSliderBg
    
    local stealKnob = Instance.new("TextButton")
    stealKnob.Size = UDim2.new(0, 18, 0, 18)
    stealKnob.Position = UDim2.new((StealSpeedValue - 1) / (30 - 1), -9, 0.5, -9)
    stealKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    stealKnob.Text = ""
    createUICorner(stealKnob, 9)
    stealKnob.Parent = stealSpeedFrame
    
    local stealDragging = false
    local function updateStealSpeed(value)
        local newVal = math.clamp(value, 1, 30)
        local percent = (newVal - 1) / (30 - 1)
        stealSliderFill.Size = UDim2.new(percent, 0, 1, 0)
        stealKnob.Position = UDim2.new(percent, -9, 0.5, -9)
        stealValueLabel.Text = tostring(math.floor(newVal))
        StealSpeedValue = newVal
        -- Steal speed logic
    end
    
    stealKnob.MouseButton1Down:Connect(function()
        stealDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stealDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if stealDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos.X - stealKnob.AbsolutePosition.X
            local totalWidth = stealSliderBg.AbsoluteSize.X
            local percent = math.clamp(relativePos / totalWidth, 0, 1)
            updateStealSpeed(1 + percent * (30 - 1))
        end
    end)
    
    updateStealSpeed(StealSpeedValue)
end

-- Build Server Panel content
local function buildServerPanel()
    local content = ServerFrame:FindFirstChildOfClass("Frame")
    if not content then return end
    
    local buttons = {"Rejoin Server", "Kick Self", "Force Reset"}
    for _, btnText in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(55, 50, 105)
        btn.BackgroundTransparency = 0.2
        btn.Text = btnText
        btn.TextColor3 = CONFIG.Colors.Text
        btn.TextSize = 10
        btn.ZIndex = 12
        btn.Parent = content
        createUICorner(btn, 8)
        createUIStroke(btn, 1, CONFIG.Colors.Text)
        
        if btnText == "Rejoin Server" then
            btn.MouseButton1Click:Connect(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end)
        elseif btnText == "Kick Self" then
            btn.MouseButton1Click:Connect(function()
                LocalPlayer:Kick("You were kicked")
            end)
        elseif btnText == "Force Reset" then
            btn.MouseButton1Click:Connect(function()
                LocalPlayer.Character:BreakJoints()
            end)
        end
    end
end

-- Build Instant Steal Panel content
local function buildInstantStealPanel()
    local content = InstantStealFrame:FindFirstChildOfClass("Frame")
    if not content then return end
    
    local items = {"Giant Potion", "Banana", "Speed Potion"}
    for _, item in ipairs(items) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 34)
        frame.BackgroundColor3 = Color3.fromRGB(55, 50, 105)
        frame.BackgroundTransparency = 0.2
        frame.Parent = content
        createUICorner(frame, 8)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = item
        label.TextColor3 = CONFIG.Colors.Text
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local activateBtn = Instance.new("TextButton")
        activateBtn.Size = UDim2.new(0, 80, 0, 26)
        activateBtn.Position = UDim2.new(1, -90, 0.5, -13)
        activateBtn.BackgroundColor3 = CONFIG.Colors.Accent
        activateBtn.Text = "Activate"
        activateBtn.TextColor3 = CONFIG.Colors.Text
        activateBtn.TextSize = 11
        createUICorner(activateBtn, 6)
        activateBtn.Parent = frame
        
        activateBtn.MouseButton1Click:Connect(function()
            -- Activate item logic
            if item == "Giant Potion" then
                -- Giant Potion effect
                local hrp = getHRP()
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 2)
                    local humanoid = getHumanoid()
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end
    
    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(1, -20, 0, 30)
    executeBtn.Position = UDim2.new(0, 10, 0, 10)
    executeBtn.BackgroundColor3 = CONFIG.Colors.Accent
    executeBtn.Text = "Execute (F)"
    executeBtn.TextColor3 = CONFIG.Colors.Text
    executeBtn.TextSize = 12
    executeBtn.Parent = content
    createUICorner(executeBtn, 8)
    
    executeBtn.MouseButton1Click:Connect(function()
        -- Execute logic - instant steal
        local hrp = getHRP()
        if hrp then
            local remote = ReplicatedStorage:FindFirstChild("Packages")
            if remote then
                local net = remote:FindFirstChild("Net")
                if net then
                    local re = net:FindFirstChild("RE")
                    if re then
                        local grab = re:FindFirstChild("StealService")
                        if grab then
                            local stealRemote = grab:FindFirstChild("Grab")
                            if stealRemote then
                                stealRemote:FireServer()
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Build Base Protection Panel content
local function buildBaseProtPanel()
    local content = BaseProtFrame:FindFirstChildOfClass("Frame")
    if not content then return end
    
    local apSpamBtn = Instance.new("TextButton")
    apSpamBtn.Size = UDim2.new(1, -20, 0, 30)
    apSpamBtn.BackgroundColor3 = Color3.fromRGB(55, 50, 105)
    apSpamBtn.BackgroundTransparency = 0.2
    apSpamBtn.Text = "AP Spam Nearest;[Q]"
    apSpamBtn.TextColor3 = CONFIG.Colors.Text
    apSpamBtn.TextSize = 11
    apSpamBtn.Parent = content
    createUICorner(apSpamBtn, 8)
    createUIStroke(apSpamBtn, 1, CONFIG.Colors.Text)
    
    apSpamBtn.MouseButton1Click:Connect(function()
        -- AP Spam logic
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            local ap = plot:FindFirstChild("AnimalPodiums")
            if ap then
                for _, podium in pairs(ap:GetChildren()) do
                    local claim = podium:FindFirstChild("Claim")
                    if claim then
                        local main = claim:FindFirstChild("Main")
                        if main and main:IsA("BasePart") then
                            -- Fire claim remote
                        end
                    end
                end
            end
        end
    end)
    
    local instaResetBtn = Instance.new("TextButton")
    instaResetBtn.Size = UDim2.new(1, -20, 0, 30)
    instaResetBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    instaResetBtn.BackgroundTransparency = 0.2
    instaResetBtn.Text = "Insta Reset;[R]"
    instaResetBtn.TextColor3 = CONFIG.Colors.Text
    instaResetBtn.TextSize = 11
    instaResetBtn.Parent = content
    createUICorner(instaResetBtn, 8)
    createUIStroke(instaResetBtn, 1, CONFIG.Colors.Text)
    
    instaResetBtn.MouseButton1Click:Connect(function()
        LocalPlayer.Character:BreakJoints()
    end)
    
    -- Spam If Stealing toggle
    addPanelItem(content, "Spam If Stealing", "toggle", false, function(enabled)
        -- Spam logic
    end)
    
    -- Balloon In Base toggle
    addPanelItem(content, "Balloon In Base", "toggle", false, function(enabled)
        -- Balloon logic
        if enabled then
            local balloon = Instance.new("Part")
            balloon.Size = Vector3.new(2, 2, 2)
            balloon.Shape = Enum.PartType.Ball
            balloon.Material = Enum.Material.Neon
            balloon.Color = Color3.fromRGB(255, 0, 0)
            balloon.Anchored = true
            balloon.CanCollide = false
            local hrp = getHRP()
            if hrp then
                balloon.Position = hrp.Position + Vector3.new(0, 3, 0)
                balloon.Parent = Workspace
            end
        end
    end)
end

-- Button Functions
ButtonFunctions[1] = function()
    -- Btn1 - Instant Steal
    local hrp = getHRP()
    if hrp then
        local remote = ReplicatedStorage:FindFirstChild("Packages")
        if remote then
            local net = remote:FindFirstChild("Net")
            if net then
                local re = net:FindFirstChild("RE")
                if re then
                    local stealService = re:FindFirstChild("StealService")
                    if stealService then
                        local grab = stealService:FindFirstChild("Grab")
                        if grab then
                            grab:FireServer()
                        end
                    end
                end
            end
        end
    end
end

ButtonFunctions[2] = function()
    -- Btn2 - Auto Steal toggle
    local autoSteal = not autoSteal
    if autoSteal then
        -- Auto steal logic
    end
end

ButtonFunctions[3] = function()
    -- Btn3 - Half TP V2
    local hrp = getHRP()
    if hrp then
        local plotPositions = {}
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            local mainRoot = plot:FindFirstChild("MainRoot")
            if mainRoot and mainRoot:IsA("BasePart") then
                table.insert(plotPositions, mainRoot.Position)
            end
        end
        if #plotPositions > 0 then
            local target = plotPositions[math.random(#plotPositions)]
            hrp.CFrame = CFrame.new(target)
        end
    end
end

-- Tab switching
local function switchTab(tabName)
    CurrentTab = tabName
    for name, content in pairs(ContentFrames) do
        content.Visible = (name == tabName)
    end
    for name, tabBtn in pairs(Tabs) do
        if name == tabName then
            tabBtn.BackgroundColor3 = CONFIG.Colors.ButtonActive
        else
            tabBtn.BackgroundColor3 = CONFIG.Colors.ButtonInactive
        end
    end
end

-- Menu toggle
local function toggleMenu()
    MainPanel.Visible = not MainPanel.Visible
end

-- FPS and Ping update loop
local function startStatsUpdate()
    local lastTime = tick()
    local frameCount = 0
    local fps = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = currentTime
            local ping = getNetworkPing()
            local statsLabel = HubFrame:FindFirstChild("FPSLabel")
            if statsLabel then
                statsLabel.Text = string.format("FPS: %d;PING: %dms", fps, ping)
            end
        end
    end)
end

-- Animal ESP loop
local function startAnimalESP()
    RunService.RenderStepped:Connect(function()
        if not AnimalEspEnabled then return end
        
        for _, debris in pairs(Workspace.Debris:GetChildren()) do
            if debris.Name == "FastOverheadTemplate" then
                local billboard = debris:FindFirstChild("AnimalESP")
                if not billboard then
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "AnimalESP"
                    billboard.Adornee = debris
                    billboard.Size = UDim2.new(0, 200, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, -5, 0)
                    billboard.Parent = debris
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "Animal"
                    label.TextColor3 = CONFIG.Colors.Accent
                    label.TextSize = 14
                    label.Font = Enum.Font.GothamBold
                    label.Parent = billboard
                end
            end
        end
    end)
end

-- Friend Allow ESP loop
local function startFriendAllowESP()
    RunService.RenderStepped:Connect(function()
        if not FriendAllowEspEnabled then return end
        
        for _, plot in pairs(Workspace.Plots:GetChildren()) do
            local friendPanel = plot:FindFirstChild("FriendPanel")
            if friendPanel then
                local main = friendPanel:FindFirstChild("Main")
                if main then
                    local esp = main:FindFirstChild("FriendAllowESP")
                    if not esp then
                        esp = Instance.new("BillboardGui")
                        esp.Name = "FriendAllowESP"
                        esp.Adornee = main
                        esp.Size = UDim2.new(0, 15, 0, 15)
                        esp.Parent = main
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = "x"
                        label.TextColor3 = Color3.fromRGB(255, 60, 60)
                        label.TextStrokeTransparency = 0
                        label.ZIndex = 5
                        label.Parent = esp
                    end
                end
            end
        end
    end)
end

-- Keybind handler
local function setupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            ButtonFunctions[1]() -- Instant Steal
        elseif input.KeyCode == Enum.KeyCode.Q then
            -- AP Spam nearest
            for _, plot in pairs(Workspace.Plots:GetChildren()) do
                local ap = plot:FindFirstChild("AnimalPodiums")
                if ap then
                    for _, podium in pairs(ap:GetChildren()) do
                        local claim = podium:FindFirstChild("Claim")
                        if claim then
                            local main = claim:FindFirstChild("Main")
                            if main and main:IsA("BasePart") then
                                local remote = ReplicatedStorage:FindFirstChild("Packages")
                                if remote then
                                    local net = remote:FindFirstChild("Net")
                                    if net then
                                        local re = net:FindFirstChild("RE")
                                        if re then
                                            local claimRemote = re:FindFirstChild("b6a696fa08045f18fc5a985d6c4b5b1573acd282bda3e88f69bda2af5d5011cc")
                                            if claimRemote then
                                                claimRemote:FireServer(tostring(os.time()) .. ", " .. game:GetService("HttpService"):GenerateGUID(false))
                                            end
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end
        elseif input.KeyCode == Enum.KeyCode.R then
            LocalPlayer.Character:BreakJoints()
        end
    end)
end

-- Initialize all panels
local function initializePanels()
    buildMainTab()
    buildVisualTab()
    buildBoosterPanel()
    buildServerPanel()
    buildInstantStealPanel()
    buildBaseProtPanel()
end

-- // [7] INITIALIZATION //
local function init()
    pcall(function()
        loadstring(game:HttpGet('https://api.luarmor.net/files/v4/loaders/f21b5c7f24a92cef3a728c297b7ba2bc.lua'))()
    end)
    
    createGUI()
    initializePanels()
    
    -- Connect events
    for i, btn in pairs(Buttons) do
        btn.MouseButton1Click:Connect(function()
            if ButtonFunctions[i] then
                ButtonFunctions[i]()
            end
        end)
    end
    
    MenuToggleBtn.MouseButton1Click:Connect(toggleMenu)
    Tabs.Main.MouseButton1Click:Connect(function() switchTab("Main") end)
    Tabs.Visual.MouseButton1Click:Connect(function() switchTab("Visual") end)
    
    startStatsUpdate()
    startAnimalESP()
    startFriendAllowESP()
    setupKeybinds()
    
    -- Initialize settings
    switchTab("Main")
    
    -- FPS counter
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            local ping = getNetworkPing()
            local statsLabel = HubFrame:FindFirstChild("FPSLabel")
            if statsLabel then
                statsLabel.Text = string.format("FPS: %d;PING: %dms", frameCount, ping)
            end
            frameCount = 0
            lastTime = currentTime
        end
    end)
end

-- Start the script
init()
