local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))
local Camera = Workspace.CurrentCamera


-- CONFIG WITH SAVE/LOAD SYSTEM
local CONFIG = {
    AUTO_STEAL_NEAREST = false,
    INFINITE_JUMP = false,
    BAT_AIMBOT_AUTOBAT = false,
    OPTIMIZER = false,
    ANTI_RAGDOLL = true,
    SPEED_BOOST = false,
}

-- Speed values
local NORMAL_SPEED = 60
local CARRY_SPEED = 30
local speedToggled = false
local autoBatKey = Enum.KeyCode.E

-- Save config function
local function saveConfig()
    local configData = {
        AUTO_STEAL_NEAREST = CONFIG.AUTO_STEAL_NEAREST,
        INFINITE_JUMP = CONFIG.INFINITE_JUMP,
        BAT_AIMBOT_AUTOBAT = CONFIG.BAT_AIMBOT_AUTOBAT,
        OPTIMIZER = CONFIG.OPTIMIZER,
        ANTI_RAGDOLL = CONFIG.ANTI_RAGDOLL,
        SPEED_BOOST = CONFIG.SPEED_BOOST,
        NORMAL_SPEED = NORMAL_SPEED,
        CARRY_SPEED = CARRY_SPEED,
        AUTO_STEAL_PROX_RADIUS = AUTO_STEAL_PROX_RADIUS,
        AUTO_BAT_KEY = autoBatKey.Name,
    }
    writefile("VyseHub_Config.json", game:GetService("HttpService"):JSONEncode(configData))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Vyse Hub",
        Text = "Config saved successfully!",
        Duration = 3
    })
end

-- Load config function
local function loadConfig()
    if isfile("VyseHub_Config.json") then
        local success, configData = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("VyseHub_Config.json"))
        end)
        if success and configData then
            CONFIG.AUTO_STEAL_NEAREST = configData.AUTO_STEAL_NEAREST or false
            CONFIG.INFINITE_JUMP = configData.INFINITE_JUMP or false
            CONFIG.BAT_AIMBOT_AUTOBAT = configData.BAT_AIMBOT_AUTOBAT or false
            CONFIG.OPTIMIZER = configData.OPTIMIZER or false
            CONFIG.ANTI_RAGDOLL = configData.ANTI_RAGDOLL ~= nil and configData.ANTI_RAGDOLL or true
            CONFIG.SPEED_BOOST = configData.SPEED_BOOST or false
            NORMAL_SPEED = configData.NORMAL_SPEED or 60
            CARRY_SPEED = configData.CARRY_SPEED or 30
            if configData.AUTO_STEAL_PROX_RADIUS then
                AUTO_STEAL_PROX_RADIUS = configData.AUTO_STEAL_PROX_RADIUS
            end
            if configData.AUTO_BAT_KEY and Enum.KeyCode[configData.AUTO_BAT_KEY] then
                autoBatKey = Enum.KeyCode[configData.AUTO_BAT_KEY]
            end
            print("[Vyse Hub] Config loaded successfully!")
            return true
        end
    end
    return false
end

-- Variables
local AUTO_STEAL_PROX_RADIUS = 20
local IsStealing = false
local StealProgress = 0
local CurrentStealTarget = nil
local allAnimalsCache = {}
local PromptMemoryCache = {}
local InternalStealCache = {}
local LastPlayerPosition = nil
local PlayerVelocity = Vector3.zero
local stealConnection = nil
local velocityConnection = nil

-- Speed variables
local h, hrp, speedLbl

-- Bat Aimbot variables
local autoBatToggled = false
local hittingCooldown = false
local SAFE_DELAY = 0.08

-- Optimizer variables
local optimizerDescendantConnection = nil
local optimizerLightingConnection = nil

-- CORE FUNCTIONS
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function scanSinglePlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            local animalName = "Unknown"
            local spawn = podium.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        animalName = child.Name
                        local animalInfo = AnimalsData[animalName]
                        if animalInfo and animalInfo.DisplayName then
                            animalName = animalInfo.DisplayName
                        end
                        break
                    end
                end
            end
            table.insert(allAnimalsCache, {
                name = animalName,
                plot = plot.Name,
                slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name .. "_" .. podium.Name,
            })
        end
    end
end

local function initializeScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10)
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then scanSinglePlot(plot) end
    end
    plots.ChildAdded:Connect(function(plot)
        if plot:IsA("Model") then
            task.wait(0.5)
            scanSinglePlot(plot)
        end
    end)
    task.spawn(function()
        while task.wait(5) do
            allAnimalsCache = {}
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanSinglePlot(plot) end
            end
        end
    end)
end

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = PromptMemoryCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plot = workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

local function updatePlayerVelocity()
    local currentHrp = getHRP()
    if not currentHrp then return end
    local currentPos = currentHrp.Position
    if LastPlayerPosition then
        local dt = task.wait()
        if dt > 0 then
            PlayerVelocity = (currentPos - LastPlayerPosition) / dt
        end
    end
    LastPlayerPosition = currentPos
end

local function shouldSteal(animalData)
    if not animalData or not animalData.worldPosition then return false end
    local currentHrp = getHRP()
    if not currentHrp then return false end
    return (currentHrp.Position - animalData.worldPosition).Magnitude <= AUTO_STEAL_PROX_RADIUS
end

local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        InternalStealCache[prompt] = data
    end
end

local function executeInternalStealAsync(prompt, animalData)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    IsStealing = true
    StealProgress = 0
    CurrentStealTarget = animalData
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do 
            pcall(function() fn() end)
        end
        local startTime = tick()
        local stealDuration = 1.3
        while tick() - startTime < stealDuration do
            StealProgress = (tick() - startTime) / stealDuration
            task.wait(0.01)
        end
        StealProgress = 1
        -- INSTANT TRIGGER
        for _, fn in ipairs(data.triggerCallbacks) do 
            pcall(function() fn() end)
        end
        -- Immediate cleanup
        data.ready = true
        IsStealing = false
        StealProgress = 0
        CurrentStealTarget = nil
    end)
    return true
end

local function attemptSteal(prompt, animalData)
    if not prompt or not prompt.Parent then return false end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then return false end
    return executeInternalStealAsync(prompt, animalData)
end

local function getNearestAnimal()
    local currentHrp = getHRP()
    if not currentHrp then return nil end
    local nearest, minDist = nil, math.huge
    for _, animal in ipairs(allAnimalsCache) do
        if isMyBase(animal.plot) then continue end
        local dist = (currentHrp.Position - animal.worldPosition).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = animal
        end
    end
    return nearest
end

-- BAT FUNCTIONS
local function getBat()
    local char = LocalPlayer.Character
    if not char then return nil end

    local tool = char:FindFirstChild("Bat")
    if tool then return tool end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        tool = backpack:FindFirstChild("Bat")
        if tool then
            tool.Parent = char
            return tool
        end
    end
    return nil
end

local function tryHitBat()
    if hittingCooldown then return end
    hittingCooldown = true

    local bat = getBat()
    if bat then
        pcall(function()
            bat:Activate()
            local evt = bat:FindFirstChildWhichIsA("RemoteEvent")
            if evt then
                evt:FireServer()
            end
        end)
    end

    task.delay(SAFE_DELAY, function()
        hittingCooldown = false
    end)
end

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDist = math.huge
    local currentHrp = getHRP()
    if not currentHrp then return nil, math.huge end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = plr.Character.HumanoidRootPart
            local dist = (currentHrp.Position - targetHRP.Position).Magnitude

            if dist < closestDist then
                closestDist = dist
                closestPlayer = plr
            end
        end
    end

    return closestPlayer, closestDist
end

local function flyToFrontOfTarget(targetHRP)
    local currentHrp = getHRP()
    if not currentHrp then return end
    local forward = targetHRP.CFrame.LookVector
    local frontPos = targetHRP.Position + forward * 4

    local direction = (frontPos - currentHrp.Position).Unit
    currentHrp.Velocity = Vector3.new(direction.X * 55, direction.Y * 55, direction.Z * 55)
end

-- Character setup for speed
local function setupChar(char)
    h = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    local head = char:FindFirstChild("Head")
    if head then
        -- Remove any existing billboard first
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("BillboardGui") then
                child:Destroy()
            end
        end
        
        local bb = Instance.new("BillboardGui", head)
        bb.Size = UDim2.new(0,140,0,25)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true

        speedLbl = Instance.new("TextLabel", bb)
        speedLbl.Size = UDim2.new(1,0,1,0)
        speedLbl.BackgroundTransparency = 1
        speedLbl.TextColor3 = Color3.fromRGB(0, 255, 255)
        speedLbl.Font = Enum.Font.GothamBold
        speedLbl.TextScaled = true
        speedLbl.TextStrokeTransparency = 0
        speedLbl.Text = "Speed: 0.0"
    end
end

LocalPlayer.CharacterAdded:Connect(setupChar)
if LocalPlayer.Character then
    setupChar(LocalPlayer.Character)
end

-- ===== GUI CREATION =====
local gui = Instance.new("ScreenGui")
gui.Name = "VyseHubGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 535)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "VYSE HUB"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.BorderSizePixel = 0
titleLabel.Parent = frame

-- Discord Button (under title)
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 280, 0, 25)
discordBtn.Position = UDim2.new(0, 10, 0, 40)
discordBtn.Text = "https://discord.gg/jRsgRcun"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
discordBtn.Parent = frame

-- Helper functions for UI elements
local function makeLbl(txt, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 140, 0, 30)
    l.Position = UDim2.new(0, 10, 0, y)
    l.Text = txt
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.TextColor3 = Color3.fromRGB(255,255,255)
    l.BackgroundTransparency = 1
    l.Parent = frame
    return l
end

local function makeBox(y, placeholder, defaultText)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0, 140, 0, 30)
    b.Position = UDim2.new(0, 150, 0, y)
    b.Text = defaultText or ""
    b.PlaceholderText = placeholder
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.ClearTextOnFocus = false
    b.Parent = frame
    return b
end

local function makeButton(txt, y, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = txt
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = frame
    return btn
end

-- Speed Controls (adjusted Y positions for title)
makeLbl("Normal Speed:", 75)
local normalBox = makeBox(75, tostring(NORMAL_SPEED), tostring(NORMAL_SPEED))

makeLbl("Carry Speed:", 115)
local carryBox = makeBox(115, tostring(CARRY_SPEED), tostring(CARRY_SPEED))

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(0, 280, 0, 30)
modeLabel.Position = UDim2.new(0, 10, 0, 155)
modeLabel.Text = "Mode: Normal"
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextScaled = true
modeLabel.TextColor3 = Color3.fromRGB(255,255,255)
modeLabel.BackgroundTransparency = 1
modeLabel.Parent = frame

-- Auto-Bat Keybind
makeLbl("Auto-Bat Key:", 195)
local autoBatKeyBox = makeBox(195, tostring(autoBatKey.Name), tostring(autoBatKey.Name))

-- Buttons (adjusted Y positions)
local autoBatBtn = makeButton("Auto-Bat", 235, Color3.fromRGB(255,0,0))
local instaGrabBtn = makeButton("Insta Grab", 280, Color3.fromRGB(255,0,0))
local infJumpBtn = makeButton("Infinite Jump", 325, Color3.fromRGB(255,0,0))
local optimizerBtn = makeButton("Optimizer", 370, Color3.fromRGB(255,0,0))
local antiRagdollBtn = makeButton("Anti-Ragdoll", 415, Color3.fromRGB(0,255,0))

-- Save Config Button
local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Size = UDim2.new(0, 130, 0, 25)
saveConfigBtn.Position = UDim2.new(0, 10, 0, 460)
saveConfigBtn.Text = "💾 Save Config"
saveConfigBtn.Font = Enum.Font.GothamBold
saveConfigBtn.TextScaled = true
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
saveConfigBtn.TextColor3 = Color3.new(1,1,1)
saveConfigBtn.Parent = frame

-- Watermark
local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Size = UDim2.new(0, 140, 0, 25)
watermarkLabel.Position = UDim2.new(0, 150, 0, 460)
watermarkLabel.Text = "Vyse Slotted"
watermarkLabel.Font = Enum.Font.GothamBold
watermarkLabel.TextColor3 = Color3.fromRGB(255,255,255)
watermarkLabel.TextScaled = true
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.Parent = frame

-- Line separator
local line = Instance.new("Frame")
line.Size = UDim2.new(0, 280, 0, 2)
line.Position = UDim2.new(0, 10, 0, 492)
line.BackgroundColor3 = Color3.fromRGB(255,255,255)
line.Parent = frame

-- FPS/PING Counter (Top Right)
local fpsFrame = Instance.new("Frame")
fpsFrame.Size = UDim2.new(0, 150, 0, 60)
fpsFrame.Position = UDim2.new(1, -160, 0, 10)
fpsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsFrame.BackgroundTransparency = 0.3
fpsFrame.BorderSizePixel = 1
fpsFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
fpsFrame.Parent = gui

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
fpsLabel.Position = UDim2.new(0, 0, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 60"
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.Parent = fpsFrame

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, 0, 0.5, 0)
pingLabel.Position = UDim2.new(0, 0, 0.5, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "PING: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 16
pingLabel.TextXAlignment = Enum.TextXAlignment.Center
pingLabel.Parent = fpsFrame

-- Progress Bar (Bottom Center - ALWAYS VISIBLE)
local progressBarFrame = Instance.new("Frame")
progressBarFrame.Size = UDim2.new(0, 400, 0, 50)
progressBarFrame.Position = UDim2.new(0.5, -200, 1, -100)
progressBarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
progressBarFrame.BorderSizePixel = 1
progressBarFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
progressBarFrame.Visible = true
progressBarFrame.Parent = gui

local progressPercentLabel = Instance.new("TextLabel")
progressPercentLabel.Size = UDim2.new(0, 40, 0, 15)
progressPercentLabel.Position = UDim2.new(0, 5, 0, 2)
progressPercentLabel.BackgroundTransparency = 1
progressPercentLabel.Text = "0%"
progressPercentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
progressPercentLabel.Font = Enum.Font.GothamBold
progressPercentLabel.TextSize = 12
progressPercentLabel.TextXAlignment = Enum.TextXAlignment.Left
progressPercentLabel.Parent = progressBarFrame

local progressRadiusLabel = Instance.new("TextLabel")
progressRadiusLabel.Size = UDim2.new(0, 80, 0, 15)
progressRadiusLabel.Position = UDim2.new(1, -85, 0, 2)
progressRadiusLabel.BackgroundTransparency = 1
progressRadiusLabel.Text = "Radius: " .. AUTO_STEAL_PROX_RADIUS
progressRadiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
progressRadiusLabel.Font = Enum.Font.GothamBold
progressRadiusLabel.TextSize = 12
progressRadiusLabel.TextXAlignment = Enum.TextXAlignment.Right
progressRadiusLabel.Parent = progressBarFrame

local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0.96, 0, 0, 18)
progressBg.Position = UDim2.new(0.02, 0, 0, 25)
progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
progressBg.BorderSizePixel = 1
progressBg.BorderColor3 = Color3.fromRGB(255, 255, 255)
progressBg.Parent = progressBarFrame

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg

-- Radius Control (below main frame)
local radiusFrame = Instance.new("Frame")
radiusFrame.Size = UDim2.new(0, 300, 0, 50)
radiusFrame.Position = UDim2.new(0, 20, 0, 565)
radiusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
radiusFrame.BorderSizePixel = 1
radiusFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
radiusFrame.Parent = gui

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0, 150, 1, 0)
radiusLabel.Position = UDim2.new(0, 10, 0, 0)
radiusLabel.Text = "GRAB RADIUS:"
radiusLabel.Font = Enum.Font.GothamBold
radiusLabel.TextScaled = true
radiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.Parent = radiusFrame

local radiusValueLabel = Instance.new("TextButton")
radiusValueLabel.Size = UDim2.new(0, 100, 0, 35)
radiusValueLabel.Position = UDim2.new(1, -110, 0.5, -17.5)
radiusValueLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusValueLabel.Text = tostring(AUTO_STEAL_PROX_RADIUS)
radiusValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusValueLabel.Font = Enum.Font.GothamBlack
radiusValueLabel.TextSize = 18
radiusValueLabel.BorderSizePixel = 0
radiusValueLabel.Parent = radiusFrame

-- DISCORD BUTTON FUNCTIONALITY
discordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/jRsgRcun")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Vyse Hub",
        Text = "Discord link copied to clipboard!",
        Duration = 3
    })
end)

-- EDITABLE SPEED BOXES
normalBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(normalBox.Text)
    if val then
        NORMAL_SPEED = val
    end
end)

carryBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(carryBox.Text)
    if val then
        CARRY_SPEED = val
    end
end)

-- AUTO-BAT KEYBIND
autoBatKeyBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newKeyName = autoBatKeyBox.Text:upper()
    if Enum.KeyCode[newKeyName] then
        autoBatKey = Enum.KeyCode[newKeyName]
    end
end)

-- SPEED & AUTO-BAT KEY HANDLING
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Q and CONFIG.SPEED_BOOST then
        speedToggled = not speedToggled
        modeLabel.Text = speedToggled and "Mode: Carry" or "Mode: Normal"
    end

    if input.KeyCode == autoBatKey then
        CONFIG.BAT_AIMBOT_AUTOBAT = not CONFIG.BAT_AIMBOT_AUTOBAT
        autoBatToggled = CONFIG.BAT_AIMBOT_AUTOBAT
        autoBatBtn.BackgroundColor3 = autoBatToggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    end
end)

-- DECLARE autoStealLoop BEFORE IT'S USED
local function autoStealLoop()
    if stealConnection then 
        stealConnection:Disconnect() 
        stealConnection = nil 
    end
    if velocityConnection then 
        velocityConnection:Disconnect() 
        velocityConnection = nil 
    end
    
    velocityConnection = RunService.Heartbeat:Connect(function()
        pcall(updatePlayerVelocity)
    end)
    
    stealConnection = RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_NEAREST then return end
        if IsStealing then return end
        
        local target = getNearestAnimal()
        if not target then return end
        if not shouldSteal(target) then return end
        
        local prompt = PromptMemoryCache[target.uid]
        if not prompt or not prompt.Parent then
            prompt = findProximityPromptForAnimal(target)
        end
        
        if prompt then 
            pcall(function()
                attemptSteal(prompt, target)
            end)
        end
    end)
end

-- BUTTON CLICKS
autoBatBtn.MouseButton1Click:Connect(function()
    CONFIG.BAT_AIMBOT_AUTOBAT = not CONFIG.BAT_AIMBOT_AUTOBAT
    autoBatToggled = CONFIG.BAT_AIMBOT_AUTOBAT
    autoBatBtn.BackgroundColor3 = autoBatToggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end)

instaGrabBtn.MouseButton1Click:Connect(function()
    CONFIG.AUTO_STEAL_NEAREST = not CONFIG.AUTO_STEAL_NEAREST
    instaGrabBtn.BackgroundColor3 = CONFIG.AUTO_STEAL_NEAREST and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    CONFIG.SPEED_BOOST = CONFIG.AUTO_STEAL_NEAREST
    if CONFIG.AUTO_STEAL_NEAREST then
        pcall(autoStealLoop)
    else
        if stealConnection then stealConnection:Disconnect() stealConnection = nil end
        if velocityConnection then velocityConnection:Disconnect() velocityConnection = nil end
    end
end)

infJumpBtn.MouseButton1Click:Connect(function()
    CONFIG.INFINITE_JUMP = not CONFIG.INFINITE_JUMP
    infJumpBtn.BackgroundColor3 = CONFIG.INFINITE_JUMP and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end)

optimizerBtn.MouseButton1Click:Connect(function()
    CONFIG.OPTIMIZER = not CONFIG.OPTIMIZER
    optimizerBtn.BackgroundColor3 = CONFIG.OPTIMIZER and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    if CONFIG.OPTIMIZER then
        pcall(applyAdvancedOptimizer)
    else
        pcall(disableOptimizer)
    end
end)

antiRagdollBtn.MouseButton1Click:Connect(function()
    CONFIG.ANTI_RAGDOLL = not CONFIG.ANTI_RAGDOLL
    antiRagdollBtn.BackgroundColor3 = CONFIG.ANTI_RAGDOLL and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
end)

saveConfigBtn.MouseButton1Click:Connect(function()
    saveConfig()
end)

-- Radius Control
local typing = false
radiusValueLabel.MouseButton1Click:Connect(function()
    if typing then return end
    typing = true
    local tb = Instance.new("TextBox")
    tb.Size = radiusValueLabel.Size
    tb.Position = radiusValueLabel.Position
    tb.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    tb.Text = tostring(AUTO_STEAL_PROX_RADIUS)
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.Font = Enum.Font.GothamBlack
    tb.TextSize = 18
    tb.Parent = radiusFrame
    tb:CaptureFocus()
    tb.FocusLost:Connect(function()
        local num = tonumber(tb.Text)
        if num and num >= 5 and num <= 300 then
            AUTO_STEAL_PROX_RADIUS = num
            radiusValueLabel.Text = tostring(num)
        end
        tb:Destroy()
        typing = false
    end)
end)

-- FEATURE IMPLEMENTATIONS

-- Infinite Jump
local jumpForce = 55
local clampFallSpeed = 120

UserInputService.JumpRequest:Connect(function()
    if not CONFIG.INFINITE_JUMP then return end
    local char = LocalPlayer.Character
    if not char then return end
    local currentHrp = char:FindFirstChild("HumanoidRootPart")
    if currentHrp then currentHrp.Velocity = Vector3.new(currentHrp.Velocity.X, jumpForce, currentHrp.Velocity.Z) end
end)

RunService.Heartbeat:Connect(function()
    if not CONFIG.INFINITE_JUMP then return end
    local char = LocalPlayer.Character
    if not char then return end
    local currentHrp = char:FindFirstChild("HumanoidRootPart")
    if currentHrp and currentHrp.Velocity.Y < -clampFallSpeed then
        currentHrp.Velocity = Vector3.new(currentHrp.Velocity.X, -clampFallSpeed, currentHrp.Velocity.Z)
    end
end)

-- Auto Bat Loop
RunService.Heartbeat:Connect(function()
    if autoBatToggled and h and hrp then
        local target, dist = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = target.Character.HumanoidRootPart
            flyToFrontOfTarget(targetHRP)
            if dist <= 8 then
                tryHitBat()
            end
        end
    end
end)

-- Speed Movement Loop
RunService.RenderStepped:Connect(function()
    if not CONFIG.SPEED_BOOST then return end
    if not (h and hrp) then return end

    local md = h.MoveDirection
    local speed = speedToggled and CARRY_SPEED or NORMAL_SPEED

    if md.Magnitude > 0 then
        hrp.Velocity = Vector3.new(md.X * speed, hrp.Velocity.Y, md.Z * speed)
    end

    if speedLbl then
        local displaySpeed = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
        speedLbl.Text = "Speed: " .. string.format("%.1f", displaySpeed)
    end
end)

-- ULTRA OPTIMIZER (From Document)
local function optimizeObject(v)
    pcall(function()
        if v:IsA("Model") then
            v.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
            v.ModelStreamingMode = Enum.ModelStreamingMode.Nonatomic
        elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.CastShadow = false
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.MaterialVariant = ""
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("MeshPart") then
            v.CastShadow = false
            v.DoubleSided = false
            v.RenderFidelity = Enum.RenderFidelity.Performance
            pcall(function() v.TextureID = 10385902758728957 end)
        elseif v:IsA("SpecialMesh") then
            v.TextureId = 0
        elseif v:IsA("ShirtGraphic") then
            v.Graphic = 0
        elseif v:IsA("Shirt") or v:IsA("Pants") then
            v[v.ClassName.."Template"] = 0
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Beam") then
            v.Enabled = false
        elseif v:IsA("SurfaceAppearance") then
            v:Destroy()
        elseif v:IsA("Debris") then
            v:Destroy()
        elseif v:IsA("Attachment") then
            v.Visible = false
        elseif v:IsA("MaterialVariant") then
            v:Destroy()
        end
    end)
end

function applyAdvancedOptimizer()
    pcall(function() setfpscap(999999999) end)
    
    -- Optimize all workspace objects
    for _, v in pairs(Workspace:GetDescendants()) do
        optimizeObject(v)
    end
    
    -- Destroy all lighting effects
    for _, v in pairs(Lighting:GetDescendants()) do
        pcall(function()
            if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or 
               v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or 
               v:IsA("Clouds") or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end)
    end
    
    -- Ultra performance lighting settings
    pcall(function()
        pcall(function() sethiddenproperty(Lighting, "Technology", 2) end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0
    end)
    
    -- Optimize terrain
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0.7
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end)
    end
    
    -- Monitor new lighting effects and destroy them
    if not optimizerLightingConnection then
        optimizerLightingConnection = Lighting.ChildAdded:Connect(function(v)
            if CONFIG.OPTIMIZER then
                task.spawn(function()
                    pcall(function() v:Destroy() end)
                end)
            end
        end)
    end
    
    -- Monitor new workspace objects
    if not optimizerDescendantConnection then
        optimizerDescendantConnection = Workspace.DescendantAdded:Connect(function(v)
            if CONFIG.OPTIMIZER then
                task.spawn(function()
                    optimizeObject(v)
                end)
            end
        end)
    end
    
    -- Performance rendering settings
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    print("[Vyse Hub] ULTRA Optimizer Enabled - Maximum FPS!")
end

function disableOptimizer()
    if optimizerDescendantConnection then
        optimizerDescendantConnection:Disconnect()
        optimizerDescendantConnection = nil
    end
    
    if optimizerLightingConnection then
        optimizerLightingConnection:Disconnect()
        optimizerLightingConnection = nil
    end
    
    pcall(function() setfpscap(60) end)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    
    print("[Vyse Hub] Optimizer Disabled")
end

-- Anti-Ragdoll (UNDETECTED VERSION)
local RAGDOLL_SPEED = 15.5
local currentCharacter = nil
local ragdollRemoteConnection = nil
local moveConnection = nil
local playerModule = nil
local controls = nil

pcall(function()
    playerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    controls = playerModule:GetControls()
end)

local function cleanupRagdoll()
    if currentCharacter then
        local root = currentCharacter:FindFirstChild("HumanoidRootPart")
        if root then
            local anchor = root:FindFirstChild("RagdollAnchor")
            if anchor then anchor:Destroy() end
        end
    end
    if moveConnection then moveConnection:Disconnect() moveConnection = nil end
end

local function disconnectRemote()
    if ragdollRemoteConnection then ragdollRemoteConnection:Disconnect() ragdollRemoteConnection = nil end
end

local function setupAntiRagdoll(char)
    currentCharacter = char
    cleanupRagdoll()
    disconnectRemote()
    local humanoid = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local head = char:WaitForChild("Head", 5)
    if not (humanoid and root and head) then return end
    
    local ragdollRemote = ReplicatedStorage:WaitForChild("Packages", 8):WaitForChild("Ragdoll", 5):WaitForChild("Ragdoll", 5)
    if not ragdollRemote or not ragdollRemote:IsA("RemoteEvent") then
        warn("[Anti-Ragdoll] Could not find Ragdoll remote")
        return
    end
    
    ragdollRemoteConnection = ragdollRemote.OnClientEvent:Connect(function(arg1, arg2)
        if not CONFIG.ANTI_RAGDOLL then return end
        
        if arg1 == "Make" or arg2 == "manualM" then
            task.wait(0.05)
            
            task.spawn(function()
                for i = 1, 5 do
                    if humanoid and humanoid.Parent then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    task.wait(0.02)
                end
            end)
            
            Camera.CameraSubject = humanoid
            root.CanCollide = true
            
            if controls then 
                pcall(function()
                    controls:Enable()
                end)
            end
            
            task.spawn(function()
                for _, part in pairs(char:GetDescendants()) do
                    pcall(function()
                        if part:IsA("Motor6D") then
                            part.Enabled = true
                        elseif part:IsA("BallSocketConstraint") or part:IsA("NoCollisionConstraint") then
                            task.wait(0.01)
                            part:Destroy()
                        end
                    end)
                end
            end)
            
            task.spawn(function()
                for i = 1, 10 do
                    if root and root.Parent then
                        local currentVel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = currentVel * 0.5
                    end
                    task.wait(0.02)
                end
            end)
        end
        
        if arg1 == "Destroy" or arg2 == "manualD" then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            Camera.CameraSubject = humanoid
            root.CanCollide = true
            if controls then 
                pcall(function()
                    controls:Enable()
                end)
            end
            cleanupRagdoll()
        end
    end)
end

-- PROGRESS BAR MONITORING
task.spawn(function()
    progressBarFrame.Visible = true
    
    while task.wait(0.01) do
        pcall(function()
            progressBarFrame.Visible = true
            progressRadiusLabel.Text = "Radius: " .. AUTO_STEAL_PROX_RADIUS
            
            if not CONFIG.AUTO_STEAL_NEAREST then
                progressPercentLabel.Text = "0%"
                progressFill.Size = UDim2.new(0, 0, 1, 0)
                return
            end
            
            local nearestAnimal = getNearestAnimal()
            local currentHrp = getHRP()
            if nearestAnimal and currentHrp then
                local distance = (currentHrp.Position - nearestAnimal.worldPosition).Magnitude
                if distance <= AUTO_STEAL_PROX_RADIUS or IsStealing then
                    if IsStealing then
                        local fillWidth = math.clamp(StealProgress, 0, 1)
                        local percentage = math.floor(fillWidth * 100)
                        progressPercentLabel.Text = percentage .. "%"
                        TweenService:Create(progressFill, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Size = UDim2.new(fillWidth, 0, 1, 0)}):Play()
                    else
                        local approachProgress = 1 - (distance / AUTO_STEAL_PROX_RADIUS)
                        approachProgress = math.clamp(approachProgress, 0, 1)
                        local percentage = math.floor(approachProgress * 100)
                        progressPercentLabel.Text = percentage .. "%"
                        TweenService:Create(progressFill, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = UDim2.new(approachProgress, 0, 1, 0)}):Play()
                    end
                else
                    progressPercentLabel.Text = "0%"
                    progressFill.Size = UDim2.new(0, 0, 1, 0)
                end
            else
                progressPercentLabel.Text = "0%"
                progressFill.Size = UDim2.new(0, 0, 1, 0)
            end
        end)
    end
end)

-- FPS/PING COUNTER UPDATE
local lastFpsUpdate = tick()
local fpsCounter = 0
task.spawn(function()
    while task.wait() do
        pcall(function()
            fpsCounter = fpsCounter + 1
            
            if tick() - lastFpsUpdate >= 1 then
                local fps = fpsCounter
                fpsLabel.Text = "FPS: " .. fps
                
                if fps >= 60 then
                    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif fps >= 30 then
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
                
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
                ping = string.match(ping, "%d+") or "0"
                local pingNum = tonumber(ping)
                pingLabel.Text = "PING: " .. ping .. "ms"
                
                if pingNum <= 100 then
                    pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif pingNum <= 200 then
                    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    pingLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
                
                fpsCounter = 0
                lastFpsUpdate = tick()
            end
        end)
    end
end)

-- INIT
initializeScanner()
if LocalPlayer.Character then 
    setupAntiRagdoll(LocalPlayer.Character)
    setupChar(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    setupAntiRagdoll(char)
    setupChar(char)
end)
LocalPlayer.CharacterRemoving:Connect(function()
    cleanupRagdoll()
    disconnectRemote()
    currentCharacter = nil
end)

-- LOAD CONFIG ON STARTUP
loadConfig()

-- Apply saved settings to buttons
if CONFIG.AUTO_STEAL_NEAREST then
    instaGrabBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
end
if CONFIG.INFINITE_JUMP then
    infJumpBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
end
if CONFIG.BAT_AIMBOT_AUTOBAT then
    autoBatBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
    autoBatToggled = true
end
if CONFIG.OPTIMIZER then
    optimizerBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
    applyAdvancedOptimizer()
end
if CONFIG.ANTI_RAGDOLL then
    antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
end

-- Update input boxes with loaded values
normalBox.Text = tostring(NORMAL_SPEED)
carryBox.Text = tostring(CARRY_SPEED)
autoBatKeyBox.Text = tostring(autoBatKey.Name)
radiusValueLabel.Text = tostring(AUTO_STEAL_PROX_RADIUS)
