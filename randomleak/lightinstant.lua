-- ========== BEST LEAKER HUB ========== --
-- ========== DUMPED BY @5ohj_ ========== --
-- ========== DISCORD.GG/utuMMTUuFw  ========== --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local gui_parent
pcall(function() gui_parent = game:GetService("CoreGui") end)
if not gui_parent then gui_parent = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("IceHubRealFPS")
    if old then old:Destroy() end
end)

local TWEEN_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ============================================
-- SCREEN GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Discord.gg/utuMMTUuFw"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = gui_parent

-- ============================================
-- INFO PANEL (FPS / PING)
-- ============================================
local InfoPanel = Instance.new("Frame", ScreenGui)
InfoPanel.Name = "DISCORD.GG/REHUB"
InfoPanel.Size = UDim2.new(0, 220, 0, 40)
InfoPanel.Position = UDim2.new(0.5, -85, 0.05, 0)
InfoPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
InfoPanel.BorderSizePixel = 0
InfoPanel.Active = true
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 8)
local infoStroke = Instance.new("UIStroke", InfoPanel)
infoStroke.Color = Color3.fromRGB(60, 60, 80)
infoStroke.Thickness = 1.5

local infoPanelLayout = Instance.new("UIListLayout", InfoPanel)
infoPanelLayout.FillDirection = Enum.FillDirection.Horizontal
infoPanelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
infoPanelLayout.VerticalAlignment = Enum.VerticalAlignment.Center
infoPanelLayout.Padding = UDim.new(0, 10)

local FpsLabel = Instance.new("TextLabel", InfoPanel)
FpsLabel.Size = UDim2.new(0, 130, 1, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "FPS: --  |  Ping: --"
FpsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
FpsLabel.TextSize = 13
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local TpBtn = Instance.new("TextButton", InfoPanel)
TpBtn.Size = UDim2.new(0, 40, 0, 24)
TpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TpBtn.BorderSizePixel = 0
TpBtn.Text = "TP"
TpBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
TpBtn.TextSize = 13
TpBtn.Font = Enum.Font.GothamBlack
TpBtn.AutoButtonColor = false
Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 4)

-- Live FPS + Ping update
local fpsTimer = 0
local frameCount = 0
RunService.RenderStepped:Connect(function(dt)
    frameCount += 1
    fpsTimer += dt
    if fpsTimer >= 0.5 then
        local fps = math.floor(frameCount / fpsTimer)
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        FpsLabel.Text = "FPS: " .. fps .. "  |  Ping: " .. ping
        fpsTimer = 0
        frameCount = 0
    end
end)

-- ============================================
-- MAIN FRAME
-- ============================================
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 260, 0, 250)
Main.Position = UDim2.new(0.5, 17, 0.4, -19)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 2

-- ============================================
-- TITLE BAR
-- ============================================
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "Frame"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

-- fix bottom corners overlap
local tbFix = Instance.new("Frame", TitleBar)
tbFix.Size = UDim2.new(1, 0, 0.5, 0)
tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tbFix.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "discord.gg/rehub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 22
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

local titleGradient = Instance.new("UIGradient", TitleLabel)
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))
})
titleGradient.Rotation = 90

-- Close button
local CloseWrap = Instance.new("Frame", TitleBar)
CloseWrap.Size = UDim2.new(0, 32, 0, 24)
CloseWrap.Position = UDim2.new(1, -40, 0.5, -12)
CloseWrap.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
CloseWrap.BorderSizePixel = 0
Instance.new("UICorner", CloseWrap).CornerRadius = UDim.new(0, 6)
local closeStroke = Instance.new("UIStroke", CloseWrap)
closeStroke.Color = Color3.fromRGB(60, 60, 80)
closeStroke.Thickness = 1

local CloseBtn = Instance.new("TextButton", CloseWrap)
CloseBtn.Size = UDim2.new(1, 0, 1, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = true
local collapsed = false
local FULL_HEIGHT = 250

CloseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        CloseBtn.Text = "+"
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, 40)
        }):Play()
    else
        CloseBtn.Text = "×"
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, FULL_HEIGHT)
        }):Play()
    end
end)

-- ============================================
-- CONTENT AREA
-- ============================================
local ContentFrame = Instance.new("Frame", Main)
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1

-- INSTANT STEAL row
local StealRow = Instance.new("Frame", ContentFrame)
StealRow.Size = UDim2.new(1, -24, 0, 36)
StealRow.Position = UDim2.new(0, 12, 0, 10)
StealRow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
StealRow.BorderSizePixel = 0
Instance.new("UICorner", StealRow).CornerRadius = UDim.new(0, 8)

local StealBtn = Instance.new("TextButton", StealRow)
StealBtn.Size = UDim2.new(1, 0, 1, 0)
StealBtn.BackgroundTransparency = 1
StealBtn.Text = "INSTANT STEAL"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.TextSize = 12
StealBtn.Font = Enum.Font.GothamBold
StealBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
StealBtn.AutoButtonColor = false
StealBtn.ZIndex = 2

local StealKeybind = Instance.new("TextButton", StealRow)
StealKeybind.Size = UDim2.new(0, 24, 0, 24)
StealKeybind.Position = UDim2.new(1, -30, 0.5, -12)
StealKeybind.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StealKeybind.BorderSizePixel = 0
StealKeybind.Text = "E"
StealKeybind.TextColor3 = Color3.fromRGB(180, 180, 200)
StealKeybind.TextSize = 11
StealKeybind.Font = Enum.Font.GothamBold
StealKeybind.AutoButtonColor = false
StealKeybind.ZIndex = 3
Instance.new("UICorner", StealKeybind).CornerRadius = UDim.new(0, 6)

-- Hover effects INSTANT STEAL
StealBtn.MouseEnter:Connect(function()
    TweenService:Create(StealRow, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(44, 44, 59)}):Play()
    TweenService:Create(StealBtn, TWEEN_FAST, {TextColor3 = Color3.fromRGB(0, 200, 255)}):Play()
end)
StealBtn.MouseLeave:Connect(function()
    TweenService:Create(StealRow, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
    TweenService:Create(StealBtn, TWEEN_FAST, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)



-- INSTA LEAVE row
local LeaveRow = Instance.new("Frame", ContentFrame)
LeaveRow.Size = UDim2.new(1, -24, 0, 36)
LeaveRow.Position = UDim2.new(0, 12, 0, 56)
LeaveRow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
LeaveRow.BorderSizePixel = 0
Instance.new("UICorner", LeaveRow).CornerRadius = UDim.new(0, 8)

local LeaveBtn = Instance.new("TextButton", LeaveRow)
LeaveBtn.Size = UDim2.new(1, 0, 1, 0)
LeaveBtn.BackgroundTransparency = 1
LeaveBtn.Text = "INSTA LEAVE"
LeaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LeaveBtn.TextSize = 12
LeaveBtn.Font = Enum.Font.GothamBold
LeaveBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
LeaveBtn.AutoButtonColor = false
LeaveBtn.ZIndex = 2

local LeaveKeybind = Instance.new("TextButton", LeaveRow)
LeaveKeybind.Size = UDim2.new(0, 24, 0, 24)
LeaveKeybind.Position = UDim2.new(1, -30, 0.5, -12)
LeaveKeybind.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LeaveKeybind.BorderSizePixel = 0
LeaveKeybind.Text = "T"
LeaveKeybind.TextColor3 = Color3.fromRGB(180, 180, 200)
LeaveKeybind.TextSize = 11
LeaveKeybind.Font = Enum.Font.GothamBold
LeaveKeybind.AutoButtonColor = false
LeaveKeybind.ZIndex = 3
Instance.new("UICorner", LeaveKeybind).CornerRadius = UDim.new(0, 6)

-- Hover effects INSTA LEAVE
LeaveBtn.MouseEnter:Connect(function()
    TweenService:Create(LeaveRow, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(44, 44, 59)}):Play()
    TweenService:Create(LeaveBtn, TWEEN_FAST, {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
LeaveBtn.MouseLeave:Connect(function()
    TweenService:Create(LeaveRow, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
    TweenService:Create(LeaveBtn, TWEEN_FAST, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)

LeaveBtn.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer:Kick("kicked by insta leave")
end)

-- Progress bar divider
local ProgressTrack = Instance.new("Frame", ContentFrame)
ProgressTrack.Size = UDim2.new(1, -24, 0, 4)
ProgressTrack.Position = UDim2.new(0, 12, 0, 105)
ProgressTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ProgressTrack.BorderSizePixel = 0
Instance.new("UICorner", ProgressTrack).CornerRadius = UDim.new(1, 0)

local ProgressFill = Instance.new("Frame", ProgressTrack)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ProgressFill.BorderSizePixel = 0
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

local filling = false


StealBtn.MouseButton1Click:Connect(function()
    if filling then return end
    if not ProgressFill or not ProgressFill.Parent then return end -- safety check
    filling = true
    StealBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    StealBtn.Text = "STEALING..."
    TweenService:Create(ProgressFill, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()

    task.wait(2.0) 
    StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StealBtn.Text = "INSTANT STEAL"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    filling = false
end)
-- ============================================
-- TOGGLE MAKER
-- ============================================
local ToggleContainer = Instance.new("Frame", ContentFrame)
ToggleContainer.Size = UDim2.new(1, -24, 1, -120)
ToggleContainer.Position = UDim2.new(0, 12, 0, 120)
ToggleContainer.BackgroundTransparency = 1
local toggleLayout = Instance.new("UIListLayout", ToggleContainer)
toggleLayout.Padding = UDim.new(0, 8)
toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeToggle(labelText, order)
    local row = Instance.new("Frame", ToggleContainer)
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    -- Toggle track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, 36, 0, 18)
    track.Position = UDim2.new(1, -42, 0.5, -9)
    track.BackgroundColor3 = Color3.fromRGB(15, 14, 19)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    -- Dot
    local dot = Instance.new("Frame", track)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    -- Invisible click button
    local clickBtn = Instance.new("TextButton", row)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.AutoButtonColor = false
    clickBtn.ZIndex = 2

    local toggled = false
    clickBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            TweenService:Create(track, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
            TweenService:Create(dot, TWEEN_FAST, {
                Position = UDim2.new(1, -16, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            }):Play()
        else
            label.TextColor3 = Color3.fromRGB(180, 180, 200)
            TweenService:Create(track, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(15, 14, 19)}):Play()
            TweenService:Create(dot, TWEEN_FAST, {
                Position = UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(180, 180, 200),
            }):Play()
        end
    end)

    return row, toggled
end

makeToggle(" AUTO GIANT POTION", 1)
makeToggle(" FRIEND ESP", 2)

-- ============================================
-- DRAG (Title Bar)
-- ============================================
local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- KEYBINDS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- E = INSTANT STEAL
    if input.KeyCode == Enum.KeyCode.E then
        if filling then return end
        filling = true
        StealBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        StealBtn.Text = "STEALING..."
        TweenService:Create(ProgressFill, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
        task.wait(2.0)
        StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StealBtn.Text = "INSTANT STEAL"
        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
        filling = false
    end

    -- T = INSTA LEAVE
    if input.KeyCode == Enum.KeyCode.T then
        game.Players.LocalPlayer:Kick("kicked by insta leave")
    end
end)
