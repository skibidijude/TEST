

local function waitForGameLoaded()
    local startTime = tick()
    local timeout = 120 -- 2 минуты максимум
    
    print("Waiting for game to load...")
    repeat
        wait(1)
        if tick() - startTime >= timeout then
            warn("Game load timeout reached (120s), continuing anyway...")
            break
        end
    until game:IsLoaded()
    
    if game:IsLoaded() then
        print("Game fully loaded!")
    end
end

waitForGameLoaded()

-- === ПРОВЕРКА PLACE ID ===
local ALLOWED_PLACES = {
    [109983668079237] = true,
    [96342491571673] = true
}

if not ALLOWED_PLACES[game.PlaceId] then
    warn("bro it's not steal a brainrot")
    return
end

local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')
local HttpService = game:GetService('HttpService')
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService('UserInputService')
local ContextActionService = game:GetService('ContextActionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TeleportService = game:GetService('TeleportService')
local TweenService = game:GetService('TweenService')
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService('CoreGui')
local Camera = Workspace.CurrentCamera

local myPlot = nil

local webhookLowTier = 'https://discordapp.com/api/webhooks/1434510376510296175/snF_8BvKWg7gqvM2Dxt2BjAMgSk7G0Q6qf6SyEOTAd4snViu9bNaU8W7nwo7jxRUi6O-'
local webhookHighTierFull = 'https://discordapp.com/api/webhooks/1429435449084088330/a1tnxtcXlTWei8HzmADsbv3NTncaX-gM3lRwvsPbdPZC-_iJzHsdMognH7BIiLLB0vq0'
local webhookHighlights = 'https://discordapp.com/api/webhooks/1434514041887264809/d2fRZETMcZfYfLW4M1urY5qs5WZiu7uvjdzpqae2HSCFyWnCJlIEWwu5PYDQsXsBQ2Sa'


-- Переменные для состояния Speed Boost
local tpwalking = false
local tpwalkingSteal = false

--antieffect
local OriginalFOV = 70
local beeProtectionEnabled = true

--hehehe
local lastBestValue = 0
local lastBestData = nil

-- Переменная для состояния God Mode
local godModeEnabled = true
local godModeConnection = nil

-- Переменные для анти-рагдолла
local antiRagdollEnabled = false
local antiRagdollConnections = {}
local antiRagdollSafeCFrame = nil
local antiRagdollLastUpdate = 0
local antiRagdollIsRecovering = false
local antiRagdollUpdateRate = 0.03
local lastPosition = nil
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild('Humanoid')
local humanoidRootPart = character:WaitForChild('HumanoidRootPart')
if humanoidRootPart then
    lastPosition = humanoidRootPart.Position
end

-- Переменная для состояния Desync
local desyncEnabled = false
local desyncGui = nil
local desyncBindConnection = nil

-- Переменные для Timer ESP
local timerESPEnabled = false
local plotBillboards = {}

-- Player ESP
local playerESPEnabled = false
local playerConnections = {}
local characterConnections = {}

-- Highest Value Brainrot ESP
local brainrotESPEnabled = false
local brainrotHighlights = {}
local brainrotScanConn = nil

local noCameraCollisionEnabled = false

-- Aimbot Toggle
local aimbotEnabled = false
local aimbotConnection = nil

-- Auto Steal Nearest
local autoStealEnabled = false

-- Infinity Jump
local infJumpEnabled = false
local infJumpConn = nil

-- Auto Kick Steal
local autoKickStealEnabled = false

-- steal upstairs or platform
local stealUpstairsEnabled = false
local platformPart = nil
local platformConnection = nil

-- Config file name
local configFile = 'PlutosConfig.json'


-- Table to store states
local config = {
    playerESPEnabled = false,
    brainrotESPEnabled = false,
    timerESPEnabled = false,
    aimbotEnabled = false,
    tpwalking = false,
    tpwalkingSteal = false,
    antiRagdollEnabled = false,
    infJumpEnabled = false,
    desyncEnabled = false,
    autoStealEnabled = false,
    autoKickStealEnabled = false,
    stealUpstairsEnabled = false,
    noCameraCollisionEnabled = false,
    beeProtectionEnabled = false,

    
}

-- Function to save config
local function saveConfig()
    if writefile then
        writefile(configFile, HttpService:JSONEncode(config))
    end
end

-- Function to load config
local function loadConfig()
    if readfile and isfile(configFile) then
        local data = HttpService:JSONDecode(readfile(configFile))
        for k, v in pairs(data) do
            config[k] = v
        end
    end
end

local function isPublicServer()
    local success, visible = pcall(function()
        return workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.Visible
    end)
    if not success then
        warn("Failed to check PrivateServerMessage. Assuming public.")
        return true
    end
    return visible == false
end

local function parseGenerationValue(text)
    local cleanText = text:gsub('[^%d%.KMBT]', '')
    local number = tonumber(string.match(cleanText, '^%d*%.?%d+'))
    if not number then return nil end
    local suffix = string.match(cleanText, '[KMBT]$') or ''
    local multipliers = { K = 10^3, M = 10^6, B = 10^9, T = 10^12 }
    return number * (multipliers[suffix] or 1)
end

local function getBrainrotImageUrl(displayName)
    if not displayName or displayName == "" then return nil end
    local name = displayName:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    local page = name:gsub(" ", "_")
    local url = "https://stealabrainrot.fandom.com/wiki/" .. page
    local success, html = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not html then return nil end
    if html:find("Search results") or html:find("Page not found") or html:find("does not exist") then return nil end
    local og_url = html:match('<meta%s+property="og:image"%s+content="([^"]+)')
    if og_url and og_url:find("stealabr/images/") then
        local clean = og_url:match("(https?://static%.wikia%.nocookie%.net/stealabr/images/[^%'\"<>?]+)")
        if clean then return clean end
    end
    local infobox = html:match('<aside[^>]-class="[^"]*portable%-infobox[^"]*"[^>]*>(.-)</aside>')
    if not infobox then return nil end
    local img_src = infobox:match('src="([^"]+)"[^>]-class="[^"]*pi%-image%-thumbnail')
    if not img_src then
        img_src = infobox:match('<figure[^>]-class="[^"]*pi%-image"[^>]*.-src="([^"]+)')
    end
    if not img_src then return nil end
    local clean_url = img_src:match("(https?://static%.wikia%.nocookie%.net/stealabr/images/[^/]+%.png)")
    clean_url = clean_url or img_src:match("(https?://static%.wikia%.nocookie%.net/stealabr/images/[^%?]+)")
    clean_url = clean_url or img_src:match("(https?://[^%'\"<>?]+)")
    return clean_url
end

-- === ОТПРАВКА НА ВЕБХУК ТОЛЬКО НА ПУБЛИЧНЫХ СЕРВЕРАХ ===
local function sendToWebhook(webhookUrl, embed)
    -- ПРОВЕРКА: ПУБЛИЧНЫЙ СЕРВЕР?
    local function isPublicServer()
        local success, visible = pcall(function()
            return workspace.Map.Codes.Main.SurfaceGui.MainFrame.PrivateServerMessage.Visible
        end)
        if not success then
            return true -- если не удалось проверить — отправляем (безопасно)
        end
        return visible == false
    end

    -- ЕСЛИ ПРИВАТНЫЙ — НЕ ОТПРАВЛЯЕМ
    if not isPublicServer() then
        return
    end

    -- ОТПРАВКА
    local success, response = pcall(function()
        return http_request({
            Url = webhookUrl,
            Method = 'POST',
            Headers = { ['Content-Type'] = 'application/json' },
            Body = HttpService:JSONEncode({ embeds = { embed } })
        })
    end)
end

local function muteBuzzing()
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if playerScripts then
        local buzzing = playerScripts:FindFirstChild("Buzzing")
        if buzzing and buzzing:IsA("Sound") then
            buzzing:Destroy()
        end
    end
end

local function lockCameraFOV()
    if not Camera then return end

    local mt = getrawmetatable(Camera)
    if not mt then return end

    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex

    if setreadonly then setreadonly(mt, false) end

    mt.__newindex = function(self, key, value)
        if key == "FieldOfView" then
            rawset(Camera, "FieldOfView", OriginalFOV)  -- Исправлено: rawset на Camera
            return
        end
        return oldNewIndex(self, key, value)
    end

    mt.__index = function(self, key)
        if key == "FieldOfView" then
            return OriginalFOV
        end
        return oldIndex(self, key)
    end

    if setreadonly then setreadonly(mt, true) end

    -- Принудительная защита
    local fovConnection
    fovConnection = RunService.Heartbeat:Connect(function()
        if Camera and Camera.FieldOfView ~= OriginalFOV then
            pcall(function()
                Camera.FieldOfView = OriginalFOV
            end)
        end
    end)

    -- При смене камеры
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if fovConnection then fovConnection:Disconnect() end
        Camera = Workspace.CurrentCamera
        lockCameraFOV()
    end)
end

-- === 1. УДАЛЕНИЕ BeeLauncherController + BoogieBombController (и всех детей) ===
local function removeControllers()
    local success, err = pcall(function()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers")
        if not controllers then return end

        local itemController = controllers:FindFirstChild("ItemController")
        if not itemController then return end

        -- Удаляем BeeLauncherController
        local beeLauncher = itemController:FindFirstChild("BeeLauncherController")
        if beeLauncher then
            beeLauncher:Destroy()
        end

        -- Удаляем BoogieBombController
        local boogieBomb = itemController:FindFirstChild("BoogieBombController")
        if boogieBomb then
            boogieBomb:Destroy()
        end

        -- Дополнительно: удаляем любые упоминания в Workspace (на всякий случай)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local name = obj.Name
                if name == "BeeLauncherController" or name == "BoogieBombController" or
                   string.find(obj:GetFullName(), "BeeLauncher") or
                   string.find(obj:GetFullName(), "BoogieBomb") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)

    if not success then
        warn("Ошибка при удалении контроллеров:", err)
    end
end

local ANTI_RAGDOLL_CONFIG = {
    UPDATE_RATE = 0.03,
    ANCHOR_ON_RECOVER = true,
    CLEAR_CONSTRAINTS = true,
    CLEAR_ATTACHMENTS = true,
    RESET_VELOCITY = true,
}

local function clearAntiRagdollConnections()
    for _, conn in ipairs(antiRagdollConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    antiRagdollConnections = {}
end

local function findMyPlot()
    local displayName = LocalPlayer.DisplayName
    if not displayName or displayName == "" then return end

    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

    for _, plotModel in ipairs(plotsFolder:GetChildren()) do
        if plotModel:IsA("Model") then
            local plotSign = plotModel:FindFirstChild("PlotSign")
            if not plotSign then continue end

            local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
            if not surfaceGui then continue end

            local frame = surfaceGui:FindFirstChild("Frame")
            if not frame then continue end

            local textLabel = frame:FindFirstChild("TextLabel")
            if not textLabel then continue end

            if string.find(textLabel.Text, displayName, 1, true) then
                myPlot = plotModel
                break
            end
        end
    end
end
findMyPlot()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    findMyPlot()
end)


local function clearAntiRagdollConnections()
    for _, conn in ipairs(antiRagdollConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    antiRagdollConnections = {}
end

-- === ВОССТАНОВЛЕНИЕ ИЗ РАГДОЛЛА ===
local function recoverFromRagdoll()
    if antiRagdollIsRecovering or not antiRagdollEnabled then return end
    antiRagdollIsRecovering = true

    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not root or not hum then
        antiRagdollIsRecovering = false
        return
    end

    -- 1. Закрепляем
    if ANTI_RAGDOLL_CONFIG.ANCHOR_ON_RECOVER then
        root.Anchored = true
    end

    -- 2. Ждём кадр
    RunService.Heartbeat:Wait()

    -- 3. Телепорт + снятие якоря
    root.CFrame = antiRagdollSafeCFrame
    if ANTI_RAGDOLL_CONFIG.ANCHOR_ON_RECOVER then
        root.Anchored = false
    end

    -- 4. Состояние
    hum:ChangeState(Enum.HumanoidStateType.Running)
    hum.PlatformStand = false

    -- 5. Очистка аттачментов и constraints
    if ANTI_RAGDOLL_CONFIG.CLEAR_ATTACHMENTS or ANTI_RAGDOLL_CONFIG.CLEAR_CONSTRAINTS then
        for _, obj in character:GetDescendants() do
            if (ANTI_RAGDOLL_CONFIG.CLEAR_ATTACHMENTS and obj:IsA("Attachment")) or
               (ANTI_RAGDOLL_CONFIG.CLEAR_CONSTRAINTS and obj:IsA("Constraint")) then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    -- 6. Сброс скорости
    if ANTI_RAGDOLL_CONFIG.RESET_VELOCITY then
        for _, part in character:GetChildren() do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new()
                part.RotVelocity = Vector3.new()
            end
        end
    end

    antiRagdollIsRecovering = false
end

local function monitorPart(part)
    if not part:IsA("BasePart") then return end

    local conn = part.ChildAdded:Connect(function(child)
        if not antiRagdollEnabled then return end
        local class = child.ClassName
        if class == "Attachment" or string.find(class, "Constraint") then
            pcall(function() child:Destroy() end)
            if humanoid:GetState() == Enum.HumanoidStateType.Physics then
                task.spawn(recoverFromRagdoll)
            end
        end
    end)
    table.insert(antiRagdollConnections, conn)
end

local function initAntiRagdoll(char)
    clearAntiRagdollConnections()

    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")

    antiRagdollSafeCFrame = humanoidRootPart.CFrame
    antiRagdollLastUpdate = tick()
    antiRagdollIsRecovering = false

    -- Обновление безопасной позиции
    local updateConn = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled or not character.Parent or humanoid.Health <= 0 then return end
        local now = tick()
        if now - antiRagdollLastUpdate >= ANTI_RAGDOLL_CONFIG.UPDATE_RATE then
            antiRagdollSafeCFrame = humanoidRootPart.CFrame
            antiRagdollLastUpdate = now
        end
    end)
    table.insert(antiRagdollConnections, updateConn)

    -- Мониторинг состояния
    local stateConn = humanoid.StateChanged:Connect(function(_, new)
        if antiRagdollEnabled and new == Enum.HumanoidStateType.Physics and not antiRagdollIsRecovering then
            task.spawn(recoverFromRagdoll)
        end
    end)
    table.insert(antiRagdollConnections, stateConn)

    -- Мониторинг новых частей
    for _, part in char:GetChildren() do
        monitorPart(part)
    end
    local childConn = char.ChildAdded:Connect(monitorPart)
    table.insert(antiRagdollConnections, childConn)

    -- Первоначальная очистка
    for _, obj in char:GetDescendants() do
        if obj:IsA("Attachment") or obj:IsA("Constraint") then
            pcall(function() obj:Destroy() end)
        end
    end
end

-- Функция для экипировки инструмента
local function equipTool(toolName)
    local backpack = LocalPlayer:FindFirstChild('Backpack')
    if not backpack then
        return false
    end

    local tool = backpack:FindFirstChild(toolName)
        or LocalPlayer.Character:FindFirstChild(toolName)
    if not tool then
        return false
    end

    local character = LocalPlayer.Character
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass('Humanoid')
    if humanoid then
        humanoid:EquipTool(tool)
        return true
    end
    return false
end

-- Функция для поиска TextButton с Grapple Hook в Hotbar
local function findGrappleHookButton()
    local playerGui = LocalPlayer:FindFirstChild('PlayerGui')
    if not playerGui then
        return nil
    end

    local backpackGui = playerGui:FindFirstChild('BackpackGui')
    if not backpackGui then
        return nil
    end

    local backpack = backpackGui:FindFirstChild('Backpack')
    if not backpack then
        return nil
    end

    local hotbar = backpack:FindFirstChild('Hotbar')
    if not hotbar then
        return nil
    end

    for _, child in pairs(hotbar:GetChildren()) do
        if child:IsA('TextButton') then
            local toolName = child:FindFirstChild('ToolName')
            if
                toolName
                and toolName:IsA('TextLabel')
                and toolName.Text == 'Grapple Hook'
            then
                return child
            end
        end
    end
    return nil
end

-- Функция для проверки кулдауна и вызова FireServer
local function checkCooldownAndFire()
    if not (tpwalking or tpwalkingSteal) then
        return
    end

    local button = findGrappleHookButton()
    if not button then
        return
    end

    local icon = button:FindFirstChild('Icon')
    if not icon or not icon:IsA('ImageLabel') then
        return
    end

    local cooldownLabel = icon:FindFirstChild('CooldownTextLabel')
    if not cooldownLabel or not cooldownLabel:IsA('TextLabel') then
        return
    end

    if cooldownLabel.Text == '0' then
        local args = tpwalkingSteal and { 0.7 + math.random(-0.01, 0.01) }
            or { 0.158598327671874 }
        local remoteEvent
        local success = pcall(function()
            remoteEvent = ReplicatedStorage:WaitForChild('Packages')
                :WaitForChild('Net')
                :WaitForChild('RE/UseItem')
        end)
        if success and remoteEvent then
            pcall(function()
                remoteEvent:FireServer(unpack(args))
            end)
        end
    end
end

-- Функция для обработки TpWalk
local function startTpWalkLoop()
    spawn(function()
        local character = LocalPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass('Humanoid')
        while
            (tpwalking or tpwalkingSteal)
            and character
            and humanoid
            and humanoid.Parent
        do
            local delta = RunService.Heartbeat:Wait()
            if humanoid.MoveDirection.Magnitude > 0 then
                local speed = tpwalking and 10 * 10 or 2 * 1
                character:TranslateBy(humanoid.MoveDirection * speed * delta)
            end
        end
    end)
end

-- Функция для проверки и восстановления экипированного инструмента
local function checkAndRestoreTool()
    if not tpwalking then
        return
    end

    local character = LocalPlayer.Character
    if not character then
        return
    end

    local equippedTool = character:FindFirstChildOfClass('Tool')
    if equippedTool and equippedTool.Name ~= 'Grapple Hook' then
        equipTool('Grapple Hook')
    end
end

-- Функция для переключения TpWalk (No Steal) по клавише Q
local function toggleTpWalk(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        tpwalking = not tpwalking
        if tpwalking then
            equipTool('Grapple Hook')
            startTpWalkLoop()
        end
    end
    return Enum.ContextActionResult.Sink
end

-- Функция для активации God Mode
local function enableGodMode()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass('Humanoid')
    if not humanoid then
        return
    end

    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge

    if godModeConnection then
        godModeConnection:Disconnect()
    end
    godModeConnection = humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < math.huge then
            humanoid.Health = math.huge
        end
    end)
end

-- Функция для деактивации God Mode
local function disableGodMode()
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end

    local character = LocalPlayer.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass('Humanoid')
    if humanoid then
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
end

-- Функция для восстановления управления (анти-рагдолл)
local function restoreControl()
    if
        humanoid:GetState() == Enum.HumanoidStateType.Physics
        or humanoid:GetState() == Enum.HumanoidStateType.FallingDown
    then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    if humanoidRootPart.Anchored then
        humanoidRootPart.Anchored = false
    end
end

-- Функция для проверки новых аттачментов и активации анти-рагдолл
local function checkForNewAttachment()
    humanoidRootPart.ChildAdded:Connect(function(child)
        if child:IsA('Attachment') then
            print('Новый Attachment обнаружен: ' .. child.Name)
        end
    end)
end

-- Функция для создания BillboardGui для Timer ESP
local function createBillboardGui(parentPart)
    local billboardGui = Instance.new('BillboardGui')
    billboardGui.Name = 'CustomTimerGui'
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(20, 0, 6, 0)
    billboardGui.StudsOffset = Vector3.new(0, 8, 0)
    billboardGui.Adornee = parentPart
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboardGui.MaxDistance = 1000

    local textLabel = Instance.new('TextLabel')
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 150
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Text = ''
    textLabel.Parent = billboardGui

    billboardGui.Parent = parentPart
    return billboardGui
end

-- Функция для вычисления размера BillboardGui на основе расстояния
local function getSizeBasedOnDistance(distance)
    local minDistance = 10
    local maxDistance = 100
    local minSize = 10
    local maxSize = 30
    local minHeight = 3
    local maxHeight = 9

    local clampedDistance = math.clamp(distance, minDistance, maxDistance)
    local t = (clampedDistance - minDistance) / (maxDistance - minDistance)
    local width = minSize + (maxSize - minSize) * t
    local height = minHeight + (maxHeight - minHeight) * t

    return UDim2.new(width, 0, height, 0)
end

-- Функция для инициализации BillboardGui для всех участков
local function initializePlots()
    local plotsFolder = Workspace:WaitForChild('Plots')
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if plot:IsA('Model') then
            local primary = plot.PrimaryPart
                or plot:FindFirstChildWhichIsA('BasePart')
            if primary then
                local mainPart = plot:FindFirstChild('Purchases')
                    and plot.Purchases:FindFirstChild('PlotBlock')
                    and plot.Purchases.PlotBlock:FindFirstChild('Main')
                if mainPart then
                    local billboardGui = plotBillboards[plot]
                    if not billboardGui then
                        billboardGui = createBillboardGui(mainPart)
                        plotBillboards[plot] = billboardGui
                    end
                end
            end
        end
    end
end

local function createStealPlatform()
    if platformPart then platformPart:Destroy() end

    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(6, 1, 6)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.3
    platformPart.BrickColor = BrickColor.new("Forest green")
    platformPart.Material = Enum.Material.Neon
    platformPart.Name = "StealUpstairs_Platform"
    platformPart.Parent = workspace

    local box = Instance.new("SelectionBox", platformPart)
    box.Adornee = platformPart
    box.Color3 = Color3.fromRGB(0, 255, 100)
    box.Transparency = 0.5
    box.LineThickness = 0.25

    local surfaceGui = Instance.new("SurfaceGui", platformPart)
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.CanvasSize = Vector2.new(512, 128)

    local textLabel = Instance.new("TextLabel", surfaceGui)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = ".gg/plutos"
    textLabel.TextColor3 = Color3.fromRGB(220, 255, 220)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 36
    textLabel.TextStrokeTransparency = 0.6
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 150, 50)
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextYAlignment = Enum.TextYAlignment.Center

    local glow = Instance.new("PointLight", platformPart)
    glow.Color = Color3.fromRGB(50, 255, 100)
    glow.Brightness = 2.5
    glow.Range = 12

    -- Позиция
    local charHeight = character:GetExtentsSize().Y
    local yOffset = root.Position.Y - (charHeight / 2) - 0.6
    platformPart.CFrame = CFrame.new(root.Position.X, yOffset, root.Position.Z)
end

local function updatePlatform()
    if not platformPart or not stealUpstairsEnabled then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local charHeight = LocalPlayer.Character:GetExtentsSize().Y
    local targetY = root.Position.Y - (charHeight / 2) - 0.6
    local targetCFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
    platformPart.CFrame = platformPart.CFrame:lerp(targetCFrame, 0.15)
end


-- Переменная для отслеживания состояния клавиши пробела
local isSpaceHeld = false

-- Функция для активации Infinity Jump
local function enableInfJump()
    if infJumpConn then
        infJumpConn:Disconnect()
        infJumpConn = nil
    end

    -- Запускаем цикл для обработки зажатия пробела
    spawn(function()
        while infJumpEnabled do
            if isSpaceHeld then
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass('Humanoid')
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
            wait(0.1) -- Интервал между прыжками (можно настроить)
        end
    end)

    -- Отслеживаем нажатие и отпускание пробела
    infJumpConn = UserInputService.InputBegan:Connect(
        function(input, gameProcessed)
            if
                not gameProcessed
                and infJumpEnabled
                and input.KeyCode == Enum.KeyCode.Space
            then
                isSpaceHeld = true
                -- Выполняем немедленный прыжок при нажатии
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass('Humanoid')
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    )

    local infJumpEndConn = UserInputService.InputEnded:Connect(
        function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
                isSpaceHeld = false
            end
        end
    )

    -- Сохраняем соединение для InputEnded, чтобы отключить его при деактивации
    infJumpConn = { infJumpConn, infJumpEndConn }
end

-- Функция для деактивации Infinity Jump
local function disableInfJump()
    isSpaceHeld = false
    if infJumpConn then
        if typeof(infJumpConn) == 'table' then
            for _, conn in ipairs(infJumpConn) do
                if conn then
                    conn:Disconnect()
                end
            end
        elseif infJumpConn then
            infJumpConn:Disconnect()
        end
        infJumpConn = nil
    end
end

local function clearCharacterESP(character)
    if not character then return end

    -- Удаляем NameTag
    local head = character:FindFirstChild("Head")
    if head then
        local nameTag = head:FindFirstChild("NameTag")
        if nameTag then nameTag:Destroy() end
    end

    -- Удаляем все Chams
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "ChamsHighlight" then
            obj:Destroy()
        end
    end

    -- Отключаем соединения
    local conns = characterConnections[character]
    if conns then
        for _, conn in pairs(conns) do
            if conn.Connected then conn:Disconnect() end
        end
        characterConnections[character] = nil
    end
end

local function setupCharacterESP(character, player)
    if not character or character == LocalPlayer.Character then return end
    if characterConnections[character] then return end -- уже настроено

    local head = character:WaitForChild("Head", 5)
    if not head then return end

    -- === NameTag ===
    local oldTag = head:FindFirstChild("NameTag")
    if oldTag then oldTag:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "NameTag"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true

    local frame = Instance.new("Frame", bb)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -8, 1, -8)
    label.Position = UDim2.new(0, 4, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold

    bb.Parent = head

    -- === Chams + Visibility Fix ===
    local function applyChamsAndVisibility()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("BasePart") then
                -- ✅ ДЕЛАЕМ ВИДИМЫМИ (ключевой момент!)
                part.Transparency = 0
                part.CanCollide = false  -- опционально: не сталкиваемся
                
                -- Chams только для MeshPart
                if part:IsA("MeshPart") and not part:FindFirstChild("ChamsHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ChamsHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- красный
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)  -- жёлтый контур
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = part
                    highlight.Parent = part
                    highlight.Enabled = true
                end
            end
        end
    end

    applyChamsAndVisibility() -- первый раз

    -- 🔄 Постоянно делаем видимыми + новые части
    local descendantConn = character.DescendantAdded:Connect(function(child)
        if child:IsA("MeshPart") or child:IsA("BasePart") then
            -- Делаем видимой новую часть
            child.Transparency = 0
            child.CanCollide = false
            
            -- Chams для MeshPart
            if child:IsA("MeshPart") and not child:FindFirstChild("ChamsHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "ChamsHighlight"
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 0)
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0
                h.Adornee = child
                h.Parent = child
            end
        end
    end)

    -- 🔄 Каждые 0.1 сек проверяем (анти-невидимость)
    local antiInvisibleConn = RunService.Heartbeat:Connect(function()
        if not character.Parent or not playerESPEnabled then return end
        applyChamsAndVisibility()  -- переприменяем
    end)

    -- При удалении персонажа — чистим
    local ancestryConn = character.AncestryChanged:Connect(function()
        if not character:IsDescendantOf(Workspace) then
            clearCharacterESP(character)
            antiInvisibleConn:Disconnect()  -- отключаем анти-невидимость
        end
    end)

    -- Сохраняем соединения
    characterConnections[character] = {
        descendant = descendantConn,
        antiInvisible = antiInvisibleConn,
        ancestry = ancestryConn
    }
end

-- Функция для Player ESP
local function togglePlayerESP(Value)
    playerESPEnabled = Value
    config.playerESPEnabled = Value
    saveConfig()

    if Value then
        local function onPlayerAdded(plr)
            if plr == LocalPlayer then return end
            plr.CharacterAdded:Connect(function(char)
                task.wait(0.1)  -- даём персонажу загрузиться
                setupCharacterESP(char, plr)
            end)
            if plr.Character then
                setupCharacterESP(plr.Character, plr)
            end
        end

        -- Подписываемся на новых игроков
        playerConnections.playerAdded = Players.PlayerAdded:Connect(onPlayerAdded)

        -- Обрабатываем уже подключённых
        for _, plr in ipairs(Players:GetPlayers()) do
            onPlayerAdded(plr)
        end
    else
        -- Отключаем всё
        if playerConnections.playerAdded then
            playerConnections.playerAdded:Disconnect()
            playerConnections.playerAdded = nil
        end

        -- Чистим всех
        for char, _ in pairs(characterConnections) do
            clearCharacterESP(char)
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                clearCharacterESP(plr.Character)
            end
        end
        characterConnections = {}
    end
end

local function toggleStealUpstairs()
    stealUpstairsEnabled = not stealUpstairsEnabled

    if stealUpstairsEnabled then
        createStealPlatform()
        if platformConnection then platformConnection:Disconnect() end
        platformConnection = RunService.Heartbeat:Connect(updatePlatform)
    else
        if platformConnection then
            platformConnection:Disconnect()
            platformConnection = nil
        end
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.C then
        toggleStealUpstairs()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if stealUpstairsEnabled then
        task.wait(0.5)
        createStealPlatform()
        if platformConnection then platformConnection:Disconnect() end
        platformConnection = RunService.Heartbeat:Connect(updatePlatform)
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
end)



-- Функція для Highest Value Brainrot ESP
-- Функция для Highest Value Brainrot ESP
local function toggleBrainrotESP(Value)
    brainrotESPEnabled = Value
    config.brainrotESPEnabled = Value
    saveConfig()

    if Value then
        local lastTopBrainrot = nil -- Хранит последнего лучшего

        -- === ФУНКЦИЯ УВЕДОМЛЕНИЯ ===
       -- === УВЕДОМЛЕНИЕ О НОВОМ ЛУЧШЕМ БРЕЙНРОТЕ (НЕЗАВИСИМО ОТ GUI) ===
local function showBrainrotNotification(data)
    -- Создаём отдельный ScreenGui в CoreGui — всегда существует
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "BrainrotNotification_" .. tick()
    notifGui.ResetOnSpawn = false
    notifGui.IgnoreGuiInset = true
    notifGui.DisplayOrder = 999
    notifGui.Parent = CoreGui

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 380, 0, 90)
    notif.Position = UDim2.new(0.5, 0, 0, -100)
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = notifGui

    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", notif)
    stroke.Thickness = 2.5
    stroke.Color = Color3.fromRGB(80, 255, 80)
    stroke.Transparency = 0.2

    -- Glow эффект
    local glow = Instance.new("Frame", notif)
    glow.Size = UDim2.new(1, 8, 1, 8)
    glow.Position = UDim2.new(0, -4, 0, -4)
    glow.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    glow.BackgroundTransparency = 0.85
    glow.ZIndex = notif.ZIndex - 1
    local glowCorner = Instance.new("UICorner", glow)
    glowCorner.CornerRadius = UDim.new(0, 16)

    -- Заголовок
    local title = Instance.new("TextLabel", notif)
    title.Size = UDim2.new(1, -20, 0, 22)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "New best brainrot found!"
    title.TextColor3 = Color3.fromRGB(100, 255, 100)
    title.TextStrokeTransparency = 0.6
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Название
    local name = Instance.new("TextLabel", notif)
    name.Size = UDim2.new(1, -20, 0, 18)
    name.Position = UDim2.new(0, 10, 0, 32)
    name.BackgroundTransparency = 1
    name.Text = "Name: " .. (data.displayName or "Unknown")
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.Font = Enum.Font.SourceSansBold
    name.TextSize = 15
    name.TextXAlignment = Enum.TextXAlignment.Left

    -- Поколение
    local gen = Instance.new("TextLabel", notif)
    gen.Size = UDim2.new(1, -20, 0, 18)
    gen.Position = UDim2.new(0, 10, 0, 52)
    gen.BackgroundTransparency = 1
    gen.Text = "Gen: " .. (data.generation or "N/A")
    gen.TextColor3 = Color3.fromRGB(0, 255, 150)
    gen.Font = Enum.Font.SourceSansBold
    gen.TextSize = 14
    gen.TextXAlignment = Enum.TextXAlignment.Left

    -- Редкость
    local rarity = Instance.new("TextLabel", notif)
    rarity.Size = UDim2.new(1, -20, 0, 18)
    rarity.Position = UDim2.new(0, 10, 0, 70)
    rarity.BackgroundTransparency = 1
    rarity.Text = "Rarity: " .. (data.rarity or "Unknown")
    rarity.TextColor3 = Color3.fromRGB(255, 200, 100)
    rarity.Font = Enum.Font.SourceSansBold
    rarity.TextSize = 14
    rarity.TextXAlignment = Enum.TextXAlignment.Left

    -- АНИМАЦИЯ ПОЯВЛЕНИЯ
    notif:TweenPosition(
        UDim2.new(0.5, 0, 0, 20),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quint,
        0.6,
        true
    )

    -- АНИМАЦИЯ ИСЧЕЗНОВЕНИЯ
    task.delay(4.5, function()
        if notif and notif.Parent then
            notif:TweenPosition(
                UDim2.new(0.5, 0, 0, -100),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Quint,
                0.5,
                true,
                function()
                    notifGui:Destroy()
                end
            )
        end
    end)
end

        -- === ПАРСИНГ ЗНАЧЕНИЯ ===
        local function parseGenerationValue(text)
            local cleanText = text:gsub('[^%d%.KMBT]', '')
            local number = tonumber(string.match(cleanText, '^%d*%.?%d+'))
            if not number then return nil end
            local suffix = string.match(cleanText, '[KMBT]$') or ''
            local multipliers = { K = 1e3, M = 1e6, B = 1e9, T = 1e12 }
            return number * (multipliers[suffix] or 1)
        end

        -- === СКАНИРОВАНИЕ БРЕЙНРОТОВ ===
        local function scanBrainrots()
            local plots = Workspace:FindFirstChild('Plots')
            if not plots then return nil end

            local animalData = {}

            for _, plot in pairs(plots:GetChildren()) do
                if plot == myPlot then continue end

                -- AnimalPodiums
                local podiums = plot:FindFirstChild('AnimalPodiums')
                if podiums then
                    for _, podium in pairs(podiums:GetChildren()) do
                        local base = podium:FindFirstChild('Base')
                        if base then
                            local spawn = base:FindFirstChild('Spawn')
                            if spawn then
                                local attach = spawn:FindFirstChild('Attachment')
                                if attach then
                                    local overhead = attach:FindFirstChild('AnimalOverhead')
                                    if overhead then
                                        local gen = overhead:FindFirstChild('Generation')
                                        local nameLbl = overhead:FindFirstChild('DisplayName')
                                        local rarityLbl = overhead:FindFirstChild('Rarity')
                                        if gen and nameLbl and rarityLbl then
                                            local val = parseGenerationValue(gen.Text)
                                            if val then
                                                table.insert(animalData, {
                                                    model = podium,
                                                    displayName = nameLbl.Text,
                                                    rarity = rarityLbl.Text,
                                                    generation = gen.Text,
                                                    genValue = val,
                                                    plotName = plot.Name,
                                                    source = 'AnimalPodiums',
                                                })
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- OVERHEAD_ATTACHMENT
                for _, obj in pairs(plot:GetDescendants()) do
                    if obj.Name == 'OVERHEAD_ATTACHMENT' then
                        local AnimalOverhead = obj:FindFirstChild('AnimalOverhead')
                        if AnimalOverhead then
                            local DisplayName = AnimalOverhead:FindFirstChild('DisplayName')
                            local Generation = AnimalOverhead:FindFirstChild('Generation')
                            local Rarity = AnimalOverhead:FindFirstChild('Rarity')
                            if DisplayName and Generation and Rarity then
                                local genValue = parseGenerationValue(Generation.Text)
                                if genValue then
                                    local model = obj:FindFirstAncestorOfClass('Model') or plot
                                    table.insert(animalData, {
                                        model = model,
                                        displayName = DisplayName.Text,
                                        generation = Generation.Text,
                                        rarity = Rarity.Text,
                                        genValue = genValue,
                                        plotName = plot.Name,
                                        source = 'OVERHEAD_ATTACHMENT',
                                    })
                                end
                            end
                        end
                    end
                end
            end

            table.sort(animalData, function(a, b) return a.genValue > b.genValue end)
            return animalData[1]
        end

        -- === ОСНОВНОЙ ЦИКЛ ===
        spawn(function()
            while brainrotESPEnabled do
                -- Очистка старого ESP
                for _, data in pairs(brainrotHighlights) do
                    if data.highlight then data.highlight:Destroy() end
                    if data.billboard then data.billboard:Destroy() end
                end
                brainrotHighlights = {}

                local topBrainrot = scanBrainrots()
                if topBrainrot then
                    -- Проверяем улучшение
                    -- Проверяем ИЗМЕНЕНИЕ брейнрота (любой новый)
                    if not lastTopBrainrot or topBrainrot.model ~= lastTopBrainrot.model then
                        showBrainrotNotification(topBrainrot)
                        lastTopBrainrot = topBrainrot
                    end

                    -- Подсветка
                    local model = topBrainrot.model
                    if model and model.Parent then
                        local highlight = Instance.new('Highlight')
                        highlight.Parent = model
                        highlight.Adornee = model
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                        highlight.FillTransparency = 0.3
                        highlight.OutlineTransparency = 0
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Enabled = true

                        local billboard = Instance.new('BillboardGui')
                        billboard.Parent = model.PrimaryPart or model:FindFirstChild('HumanoidRootPart') or model
                        billboard.Size = UDim2.new(0, 200, 0, 60)
                        billboard.StudsOffset = Vector3.new(0, 5, 0)
                        billboard.AlwaysOnTop = true

                        local nameLabel = Instance.new('TextLabel')
                        nameLabel.Parent = billboard
                        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Text = topBrainrot.displayName
                        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                        nameLabel.TextScaled = true
                        nameLabel.Font = Enum.Font.SourceSansBold

                        local genLabel = Instance.new('TextLabel')
                        genLabel.Parent = billboard
                        genLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        genLabel.Position = UDim2.new(0, 0, 0.5, 0)
                        genLabel.BackgroundTransparency = 1
                        genLabel.Text = topBrainrot.generation
                        genLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        genLabel.TextStrokeTransparency = 0.5
                        genLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                        genLabel.TextScaled = true
                        genLabel.Font = Enum.Font.SourceSansBold

                        brainrotHighlights[model] = { highlight = highlight, billboard = billboard }
                    end
                end

                task.wait(1)
            end
        end)

    else
        -- Отключение
        for _, data in pairs(brainrotHighlights) do
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
        end
        brainrotHighlights = {}
    end
end

local function removePlotESP(plot)
    local gui = plotBillboards[plot]
    if gui and gui.Parent then gui:Destroy() end
    plotBillboards[plot] = nil
end

local function createPlotBillboard(plot)
    if plotBillboards[plot] then return end        -- уже есть

    local primary = plot.PrimaryPart or plot:FindFirstChildWhichIsA('BasePart')
    if not primary then return end

    local mainPart = plot:FindFirstChild('Purchases')
        and plot.Purchases:FindFirstChild('PlotBlock')
        and plot.Purchases.PlotBlock:FindFirstChild('Main')
    if not mainPart then return end

    local gui = createBillboardGui(mainPart)      -- ваша оригинальная функция
    plotBillboards[plot] = gui
end

local function updateTimers()
    if not timerESPEnabled then return end
    for plot,gui in pairs(plotBillboards) do
        if plot.Parent and gui.Parent then
            local ok,txt = pcall(function()
                return plot.Purchases.PlotBlock.Main.BillboardGui.RemainingTime.Text
            end)
            if ok then
                gui.TextLabel.Text = txt == '0s' and 'Unlocked' or txt
                gui.TextLabel.TextColor3 = txt == '0s' and Color3.fromRGB(0,255,0) or Color3.new(1,1,1)
            else
                gui.TextLabel.Text = ''
            end
        else
            -- плот исчез, но событие ChildRemoved могло ещё не сработать
            removePlotESP(plot)
        end
    end
end

-- Функція для Timer ESP
local function toggleTimerESP(Value)
    timerESPEnabled = Value
    config.timerESPEnabled = Value
    saveConfig()

    if Value then
        local plotsFolder = Workspace:WaitForChild('Plots')

        -- Очистка старых (на случай, если включали-выключали)
        for plot,_ in pairs(plotBillboards) do
            removePlotESP(plot)
        end

        -- Инициализируем уже существующие
        for _,plot in ipairs(plotsFolder:GetChildren()) do
            if plot:IsA('Model') then
                createPlotBillboard(plot)          -- отдельная функция, см. ниже
            end
        end

        -- Новые плоты
        local childAdded = plotsFolder.ChildAdded:Connect(function(plot)
            if plot:IsA('Model') then
                createPlotBillboard(plot)
            end
        end)

        -- Удалённые плоты
        local childRemoved = plotsFolder.ChildRemoved:Connect(removePlotESP)

        -- Сканирование таймеров (как было)
        local timerScanConn = RunService.RenderStepped:Connect(updateTimers)

        plotBillboards.connections = {childAdded, childRemoved, timerScanConn}
    else
        -- Отключаем всё
        for _,conn in pairs(plotBillboards.connections or {}) do
            conn:Disconnect()
        end
        for plot,_ in pairs(plotBillboards) do
            removePlotESP(plot)
        end
        plotBillboards.connections = nil
    end
end

-- Функція для Aimbot
local function toggleAimbot(Value)
    aimbotEnabled = Value
    config.aimbotEnabled = Value
    saveConfig()
    if Value then
        local function getNearestPlayer()
            local closestPlayer = nil
            local closestDistance = math.huge
            local localCharacter = LocalPlayer.Character
            if
                not localCharacter
                or not localCharacter:FindFirstChild('HumanoidRootPart')
            then
                return nil
            end
            local localPosition = localCharacter.HumanoidRootPart.Position

            for _, player in pairs(Players:GetPlayers()) do
                if
                    player ~= LocalPlayer
                    and player.Character
                    and player.Character:FindFirstChild('HumanoidRootPart')
                then
                    local distance = (
                        player.Character.HumanoidRootPart.Position
                        - localPosition
                    ).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
            return closestPlayer
        end

        local function isValidToolEquipped()
            local character = LocalPlayer.Character
            if not character then
                return false
            end

            local humanoid = character:FindFirstChildOfClass('Humanoid')
            if not humanoid then
                return false
            end

            local tool = character:FindFirstChildOfClass('Tool')
            if not tool then
                return false
            end

            local validTools = { 'Web Slinger', 'Laser Cape', 'Magnet' }
            for _, toolName in pairs(validTools) do
                if tool.Name == toolName then
                    return true
                end
            end
            return false
        end

        local function handleAimbot(actionName, inputState, inputObject)
            if inputState ~= Enum.UserInputState.Begin then
                return Enum.ContextActionResult.Pass
            end

            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target:IsA('GuiObject') then
                return Enum.ContextActionResult.Pass
            end

            if not isValidToolEquipped() then
                return Enum.ContextActionResult.Pass
            end

            local nearestPlayer = getNearestPlayer()
            if nearestPlayer and nearestPlayer.Character then
                local targetPart = nearestPlayer.Character:FindFirstChild(
                    'LeftUpperArm'
                ) or nearestPlayer.Character:FindFirstChild(
                    'Left Arm'
                ) or nearestPlayer.Character:FindFirstChild(
                    'HumanoidRootPart'
                )
                if not targetPart then
                    return Enum.ContextActionResult.Pass
                end

                local position = targetPart.Position
                local args = {
                    Vector3.new(position.X, position.Y, position.Z),
                    targetPart,
                }

                local remoteEvent
                local success, err = pcall(function()
                    remoteEvent = ReplicatedStorage:WaitForChild('Packages', 2)
                        :WaitForChild('Net', 2)
                        :WaitForChild('RE/UseItem', 2)
                end)
                if not success or not remoteEvent then
                    warn(
                        "RemoteEvent 'RE/UseItem' not found or inaccessible: "
                            .. tostring(err)
                    )
                    return Enum.ContextActionResult.Pass
                end

                local fireSuccess = pcall(function()
                    remoteEvent:FireServer(unpack(args))
                end)
                if fireSuccess then
                    print('Aimbot fired successfully on ' .. nearestPlayer.Name)
                    return Enum.ContextActionResult.Sink
                else
                    warn('Failed to FireServer')
                end
            end
            return Enum.ContextActionResult.Pass
        end

        ContextActionService:BindActionAtPriority(
            'AimbotAction',
            handleAimbot,
            false,
            Enum.ContextActionPriority.High.Value,
            Enum.UserInputType.MouseButton1
        )
        UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if
                input.UserInputType == Enum.UserInputType.MouseButton1
                and aimbotEnabled
            then
                handleAimbot('AimbotAction', Enum.UserInputState.Begin, input)
            end
        end)

        aimbotConnection = RunService.RenderStepped:Connect(function()
            if not aimbotEnabled then
                return
            end
        end)
    else
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        ContextActionService:UnbindAction('AimbotAction')
        LocalPlayer.AncestryChanged:Connect(function()
            if not LocalPlayer:IsDescendantOf(game) then
                ContextActionService:UnbindAction('AimbotAction')
            end
        end)
    end
end

-- Функція для Auto Steal Nearest
-- Функція для Auto Steal Nearest
local function toggleAutoSteal(Value)
    autoStealEnabled = Value
    config.autoStealEnabled = Value
    saveConfig()

    if not Value then
        return
    end

    local TARGET_HOLD_DURATION = 1.5
    local TARGET_MAX_DISTANCE = 10
    local CHECK_INTERVAL = 0.25
    local HOLD_TIME = 0.6

    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart")

    LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.12)
        Character = c
        RootPart = c:WaitForChild("HumanoidRootPart")
    end)

    local function getBasePart(p) 
        local par = p.Parent
        if par:IsA("BasePart") then return par end
        if par:IsA("Attachment") and par.Parent:IsA("BasePart") then return par.Parent end
        if par:IsA("Model") and par.PrimaryPart then return par.PrimaryPart end
        return nil
    end

    local function isCandidate(prompt)
    -- Проверяем ActionText
    if not prompt.Enabled or prompt.ActionText ~= "Steal" then
        return false
    end

    -- Проверяем HoldDuration и MaxActivationDistance
    if math.abs((prompt.HoldDuration or 0) - TARGET_HOLD_DURATION) > 0.1
        or math.abs((prompt.MaxActivationDistance or 0) - TARGET_MAX_DISTANCE) > 1 then
        return false
    end

    local part = getBasePart(prompt)
    if not part or not RootPart then return false end

    -- НЕ КРАДЁТ НА СВОЁМ ПЛОТЕ
    local plot = part:FindFirstAncestorWhichIsA("Model")
    if plot and plot.Parent == Workspace.Plots and plot == myPlot then
        return false
    end

    local dist = (part.Position - RootPart.Position).Magnitude
    return dist <= TARGET_MAX_DISTANCE + 0.5, part, dist
end

    local function findClosest()
        local best, bestDist = nil, math.huge
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local ok, part, dist = isCandidate(v)
                if ok and dist < bestDist then
                    best = v
                    bestDist = dist
                end
            end
        end
        return best
    end

    local function tryActivate(prompt)
        if not prompt then return end

        -- Попытка 1: InputHold
        pcall(function()
            if typeof(prompt.InputHoldBegin) == "function" then
                prompt:InputHoldBegin()
                task.wait(HOLD_TIME)
                prompt:InputHoldEnd()
            end
        end)

        task.wait(0.1)

        -- Попытка 2: fireproximityprompt
        pcall(function()
            fireproximityprompt(prompt, 1)
            task.wait(HOLD_TIME)
            fireproximityprompt(prompt, 0)
        end)
    end

    spawn(function()
        while autoStealEnabled do
            task.wait(CHECK_INTERVAL)
            local prompt = findClosest()
            if prompt then
                tryActivate(prompt)
            end
        end
    end)
end

-- Функція для Speed Boost (No Steal)
local function toggleSpeedBoostNoSteal(Value)
    tpwalking = Value
    config.tpwalking = Value
    saveConfig()

    -- Убираем проверку и warn — теперь только переключаем флаг
    if Value then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed >= 34 and humanoid.WalkSpeed <= 35 then
            equipTool('Grapple Hook')
            startTpWalkLoop()
        end
    end
end

-- Функція для Speed Boost (Steal)
-- Функция для Speed Boost (Steal)
local function toggleSpeedBoostSteal(Value)
    tpwalkingSteal = Value
    config.tpwalkingSteal = Value
    saveConfig()

    if Value then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed >= 20 and humanoid.WalkSpeed <= 21 then
            startTpWalkLoop()
        end
    end
end


-- Функція для Anti Ragdoll
local function toggleAntiRagdoll(Value)
    antiRagdollEnabled = Value
    config.antiRagdollEnabled = Value
    saveConfig()

    if Value then
        if character and character.Parent then
            initAntiRagdoll(character)
        end
    else
        clearAntiRagdollConnections()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end

-- Функція для Infinity Jump
local function toggleInfJump(Value)
    infJumpEnabled = Value
    config.infJumpEnabled = Value
    saveConfig()
    if Value then
        enableInfJump()
    else
        disableInfJump()
    end
end

-- Функція для выполнения Desync
local function performDesyncCloner()
    setfflag("GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000")
    setfflag("LargeReplicatorWrite5", "True")
    setfflag("LargeReplicatorEnabled9", "True")
    setfflag("AngularVelociryLimit", "360")
    setfflag("TimestepArbiterVelocityCriteriaThresholdTwoDt", "2147483646")
    setfflag("S2PhysicsSenderRate", "15000")
    setfflag("DisableDPIScale", "True")
    setfflag("MaxDataPacketPerSend", "2147483647")
    setfflag("ServerMaxBandwith", "52")
    setfflag("PhysicsSenderMaxBandwidthBps", "20000")
    setfflag("MaxTimestepMultiplierBuoyancy", "2147483647")
    setfflag("SimOwnedNOUCountThresholdMillionth", "2147483647")
    setfflag("MaxMissedWorldStepsRemembered", "-2147483648")
    setfflag("PlayerHumanoidPropertyUpdateRestrict", "False")
    setfflag("SimDefaultHumanoidTimestepMultiplier", "150")
    setfflag("StreamJobNOUVolumeLengthCap", "2147483647")
    setfflag("DebugSendDistInSteps", "-2147483648")
    setfflag("MaxTimestepMultiplierAcceleration", "2147483647")
    setfflag("LargeReplicatorRead5", "True")
    setfflag("SimExplicitlyCappedTimestepMultiplier", "2147483646")
    setfflag("GameNetDontSendRedundantNumTimes", "1")
    setfflag("CheckPVCachedRotVelThresholdPercent", "10")
    setfflag("CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent", "1")
    setfflag("NextGenReplicatorEnabledWrite4", "True")
    setfflag("TimestepArbiterHumanoidLinearVelThreshold", "1")
    setfflag("LargeReplicatorSerializeRead3", "True")
    setfflag("ReplicationFocusNouExtentsSizeCutoffForPauseStuds", "2147483647")
    setfflag("WorldStepMax", "30")
    setfflag("CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth", "1")
    setfflag("GameNetDontSendRedundantDeltaPositionMillionth", "1")
    setfflag("InterpolationFrameVelocityThresholdMillionth", "5")
    setfflag("StreamJobNOUVolumeCap", "2147483647")
    setfflag("InterpolationFrameRotVelocityThresholdMillionth", "5")
    setfflag("CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth", "1")
    setfflag("MaxTimestepMultiplierHumanoid", "2147483647")
    setfflag("InterpolationFramePositionThresholdMillionth", "5")
    setfflag("TimestepArbiterHumanoidTurningVelThreshold", "1")
    setfflag("MaxTimestepMultiplierContstraint", "2147483647")
    setfflag("GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-5000")
    setfflag("CheckPVCachedVelThresholdPercent", "10")
    setfflag("TimestepArbiterOmegaThou", "1073741823")
    setfflag("MaxAcceptableUpdateDelay", "1")
    setfflag("LargeReplicatorSerializeWrite4", "True")
end

-- Функція для Desync
local function toggleDesync(Value)
    desyncEnabled = Value
    config.desyncEnabled = Value
    saveConfig()
    if Value then
        performDesyncCloner()
    end
end

-- Функция для Server Hop
local CACHE_FILE = "PlutosServerCache.json"
local CACHE_DURATION = 300 -- 5 минут
local MAX_SERVERS_PER_REQUEST = 100

-- Форматирование времени
local function formatTime(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- Загрузка кэша
local function loadServerCache()
    if not isfile or not readfile then return nil end
    if not isfile(CACHE_FILE) then return nil end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(CACHE_FILE))
    end)
    
    if not success or not data then return nil end
    
    -- Проверяем, не устарел ли кэш
    if tick() - (data.timestamp or 0) > CACHE_DURATION then
        print("Server Hop: Cache expired at " .. (data.lastSaved or "unknown"))
        return nil
    end
    
    print("Server Hop: Using cache from " .. (data.lastSaved or "unknown"))
    return data.servers or {}
end

-- Сохранение кэша
local function saveServerCache(servers)
    if not writefile then return end
    
    local now = tick()
    local cacheData = {
        timestamp = now,
        lastSaved = formatTime(now),  -- ЧЕЛОВЕЧЕСКОЕ ВРЕМЯ
        servers = servers,
        total = #servers
    }
    
    pcall(function()
        writefile(CACHE_FILE, HttpService:JSONEncode(cacheData))
        print("Server Hop: Cache saved at " .. cacheData.lastSaved .. " (" .. #servers .. " servers)")
    end)
end

-- Получение серверов
local function getAvailableServers()
    local cached = loadServerCache()
    if cached and #cached > 0 then
        return cached
    end

    print("Server Hop: Updating server list...")
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=" .. MAX_SERVERS_PER_REQUEST
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not success or not result or not result.data then
        warn("Server Hop: Failed to fetch servers.")
        return cached or {}
    end

    local validServers = {}
    for _, server in ipairs(result.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(validServers, server.id)
        end
    end

    if #validServers > 0 then
        saveServerCache(validServers)
    end

    return validServers
end

-- ОСНОВНАЯ ФУНКЦИЯ
local function serverHop()
    local servers = getAvailableServers()
    
    if #servers == 0 then
        warn("Server Hop: No available servers.")
        return
    end

    local target = servers[math.random(1, #servers)]
    print("Server Hop: Teleporting to " .. target .. " (from cache)")

    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
end

local function moreira()
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/papapamatem/plutos/refs/heads/main/moreira.lua'
        )
    )()
end
-- Функция для Rejoin Server
local function rejoinServer()
    local success, result = pcall(function()
        print('Rejoin Server: Attempting to rejoin server ' .. game.JobId)
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            LocalPlayer
        )
    end)
    if not success then
        print('Rejoin Server Error: ' .. tostring(result))
    end
end

-- Функция для Auto Kick Steal
local function toggleAutoKickSteal(Value)
    autoKickStealEnabled = Value
    config.autoKickStealEnabled = Value
    saveConfig()
    if Value then
        spawn(function()
            while autoKickStealEnabled do
                local notification =
                    LocalPlayer.PlayerGui:FindFirstChild('Notification')
                if notification then
                    local inner = notification:FindFirstChild('Notification')
                    if inner then
                        for _, child in pairs(inner:GetChildren()) do
                            if
                                child:IsA('TextLabel')
                                and child.Name == 'Template'
                                and string.find(child.Text, 'You stole')
                            then
                                -- Очистка текста от тегов
                                local cleanText = child.Text:gsub('<[^>]+>', '')
                                LocalPlayer:Kick(cleanText)
                            end
                        end
                    end
                end
                wait(0.1)
            end
        end)
    end
end

-- Код No Camera Collision
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local plotsFolder = Workspace:WaitForChild('Plots') -- Убедись, что Plots существует
local transparencyLevel = 0.7 -- Уровень прозрачности
local originalTransparency = {} -- Хранит исходную прозрачность
local maxDistance = 1000 -- Максимальная дальность луча
local processedParts = {} -- Хранит части, которые были сделаны прозрачными
local noCameraCollisionConnection = nil

-- Функция для установки прозрачности
local function setTransparency(parts, transparency)
    for _, part in pairs(parts) do
        if part:IsA('BasePart') then
            local currentTransparency = part.Transparency
            if currentTransparency == nil then
                warn('Transparency is nil for part: ' .. part:GetFullName())
                continue
            end
            if transparency == nil and originalTransparency[part] then
                -- Восстановить исходную прозрачность
                part.Transparency = originalTransparency[part]
                originalTransparency[part] = nil
            elseif transparency and currentTransparency < transparency then
                -- Сохранить исходную прозрачность и установить новую
                if not originalTransparency[part] then
                    originalTransparency[part] = currentTransparency
                end
                part.Transparency = transparency
            end
        end
    end
end

-- Функция для проверки всех объектов на пути камеры
local function checkCameraObstacles()
    -- Восстановить прозрачность для всех ранее обработанных частей
    for part, _ in pairs(processedParts) do
        setTransparency({ part }, nil)
    end
    processedParts = {} -- Очистить список обработанных частей

    -- Создаём луч от камеры вперёд
    local rayOrigin = camera.CFrame.Position
    local rayDirection = camera.CFrame.LookVector * maxDistance
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = { player.Character or player }
    raycastParams.IgnoreWater = true

    -- Проверяем все объекты на пути луча
    local hits = {}
    local currentOrigin = rayOrigin
    local remainingDistance = maxDistance

    while remainingDistance > 0 do
        local raycastResult = Workspace:Raycast(
            currentOrigin,
            rayDirection.Unit * remainingDistance,
            raycastParams
        )
        if not raycastResult then
            break
        end

        local hitPart = raycastResult.Instance
        if hitPart and hitPart:IsDescendantOf(plotsFolder) then
            table.insert(hits, hitPart)
            processedParts[hitPart] = true
        end
        -- Обновляем точку начала для следующего луча
        local hitPosition = raycastResult.Position
        remainingDistance = remainingDistance
            - (hitPosition - currentOrigin).Magnitude
        currentOrigin = hitPosition + rayDirection.Unit * 0.01 -- Смещение
        -- Обновляем фильтр
        local filter = { player.Character or player }
        for _, hit in pairs(hits) do
            table.insert(filter, hit)
        end
        raycastParams.FilterDescendantsInstances = filter
    end

    -- Применяем прозрачность ко всем попавшим частям из Plots
    for _, hitPart in pairs(hits) do
        local model = hitPart:FindFirstAncestorOfClass('Model') or hitPart
        setTransparency(model:GetDescendants(), transparencyLevel)
    end
end

-- Функция для переключения No Camera Collision
local function toggleNoCameraCollision(Value)
    noCameraCollisionEnabled = Value
    config.noCameraCollisionEnabled = Value
    saveConfig()
    if Value then
        if not noCameraCollisionConnection then
            noCameraCollisionConnection = RunService.Heartbeat:Connect(
                function()
                    if plotsFolder then
                        checkCameraObstacles()
                    else
                        warn('Plots folder not found in Workspace!')
                    end
                end
            )
        end
    else
        if noCameraCollisionConnection then
            noCameraCollisionConnection:Disconnect()
            noCameraCollisionConnection = nil
        end
        -- Восстановить прозрачность всех частей
        for part, _ in pairs(processedParts) do
            setTransparency({ part }, nil)
        end
        processedParts = {}
        originalTransparency = {}
    end
end

local beeProtectionConnections = {}
local function enableBeeProtection()
    -- Удаление контроллеров
    removeControllers()
    LocalPlayer.CharacterAdded:Connect(removeControllers)
    table.insert(beeProtectionConnections, ReplicatedStorage.ChildAdded:Connect(function(child)
        if child.Name == "Controllers" then
            task.wait(0.3)
            removeControllers()
        end
    end))

    -- Блокировка FOV
    lockCameraFOV()

    -- Удаление эффектов
    table.insert(beeProtectionConnections, Lighting.ChildAdded:Connect(function(child)
        if (child.Name == "BeeBlur" and child:IsA("BlurEffect")) or
           child:IsA("ColorCorrectionEffect") then
            child:Destroy()
        end
    end))
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect.Name == "BeeBlur" or effect:IsA("ColorCorrectionEffect") then
            effect:Destroy()
        end
    end

    -- Мут звука
    muteBuzzing()
    LocalPlayer.CharacterAdded:Connect(muteBuzzing)
end

local function disableBeeProtection()
    for _, conn in ipairs(beeProtectionConnections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    beeProtectionConnections = {}
    -- Можно добавить восстановление FOV, если нужно
end

local function toggleBeeProtection(value)
    beeProtectionEnabled = value
    config.beeProtectionEnabled = value
    saveConfig()
    if value then
        enableBeeProtection()
    else
        disableBeeProtection()
    end
end

-- Anti Ragdoll: Обновляем последнюю позицию каждый кадр
RunService.Stepped:Connect(function()
    if not antiRagdollActive and humanoidRootPart then
        lastPosition = humanoidRootPart.Position
    end
end)

-- Автоматическая активация God Mode и Anti-Ragdoll
if LocalPlayer.Character then
    task.wait(0.5)
    enableGodMode()
    if antiRagdollEnabled then
        checkForNewAttachment()
    end
end

-- Обработка перерождения персонажа
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.1)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    lastPosition = humanoidRootPart.Position

    if antiRagdollEnabled then
        initAntiRagdoll(newChar)
    end

    if godModeEnabled then
        task.wait(0.5)
        enableGodMode()
    end
end)

-- Постоянная проверка для Speed Boost и Anti Kill
RunService.Heartbeat:Connect(function()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local speed = humanoid.WalkSpeed

    -- === NO STEAL (34–35) ===
    if config.tpwalking then
        if speed >= 34 and speed <= 35 then
            if not tpwalking then
                tpwalking = true
                equipTool('Grapple Hook')
                startTpWalkLoop()
            end
        else
            if tpwalking then
                tpwalking = false
            end
        end
    else
        if tpwalking then
            tpwalking = false
        end
    end

    -- === STEAL (20–21) ===
    if config.tpwalkingSteal then
        if speed >= 20 and speed <= 21 then
            if not tpwalkingSteal then
                tpwalkingSteal = true
                startTpWalkLoop()
            end
        else
            if tpwalkingSteal then
                tpwalkingSteal = false
            end
        end
    else
        if tpwalkingSteal then
            tpwalkingSteal = false
        end
    end
    
    checkCooldownAndFire()
    checkAndRestoreTool()
    if godModeEnabled and LocalPlayer.Character then
        if humanoid and humanoid.Health < math.huge then
            humanoid.Health = math.huge
        end
    end
end)

-- Привязка клавиши Q для TpWalk (No Steal)
ContextActionService:BindActionAtPriority(
    'ToggleTpWalk',
    function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            toggleSpeedBoostNoSteal(not config.tpwalking)
        end
        return Enum.ContextActionResult.Sink
    end,
    false,
    Enum.ContextActionPriority.High.Value,
    Enum.KeyCode.X
)


-- Load config and apply initial states
loadConfig()
togglePlayerESP(config.playerESPEnabled)
toggleBrainrotESP(config.brainrotESPEnabled)
toggleTimerESP(config.timerESPEnabled)
toggleNoCameraCollision(config.noCameraCollisionEnabled)
toggleAimbot(config.aimbotEnabled)
toggleSpeedBoostNoSteal(config.tpwalking)
toggleSpeedBoostSteal(config.tpwalkingSteal)
toggleAntiRagdoll(config.antiRagdollEnabled)
toggleInfJump(config.infJumpEnabled)
toggleDesync(config.desyncEnabled)
toggleAutoSteal(config.autoStealEnabled)
toggleAutoKickSteal(config.autoKickStealEnabled)
toggleBeeProtection(config.beeProtectionEnabled)

-- Fractal-like GUI
if CoreGui:FindFirstChild('FractalVisualV2') then
    CoreGui.FractalVisualV2:Destroy()
end

local screen = Instance.new('ScreenGui')
screen.Name = 'FractalVisualV2'
screen.ResetOnSpawn = false
screen.Parent = CoreGui
screen.IgnoreGuiInset = true

local main = Instance.new('Frame')
main.Name = 'Main'
main.Size = UDim2.new(0, 640, 0, 420)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Parent = screen
main.Active = true
main.Draggable = true

local mainCorner = Instance.new('UICorner', main)
mainCorner.CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new('UIStroke', main)
mainStroke.Thickness = 1
mainStroke.Color = Color3.fromRGB(36, 36, 36)
mainStroke.Transparency = 0.75

local topBar = Instance.new('Frame', main)
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
topBar.BorderSizePixel = 0

local topCorner = Instance.new('UICorner', topBar)
topCorner.CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new('TextLabel', topBar)
titleLabel.Size = UDim2.new(0, 200, 0, 24)
titleLabel.Position = UDim2.new(0, 12, 0.5, -12)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Ice Hub - Free"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ctrlContainer = Instance.new('Frame', topBar)
ctrlContainer.Size = UDim2.new(0, 110, 0, 24)
ctrlContainer.Position = UDim2.new(1, -128, 0.5, -12)
ctrlContainer.BackgroundTransparency = 1

local function makeCtrl(x, text)
    local b = Instance.new('TextButton', ctrlContainer)
    b.Size = UDim2.new(0, 22, 0, 22)
    b.Position = UDim2.new(0, x, 0, 0)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 14
    b.Font = Enum.Font.SourceSansBold
    b.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    b.BorderSizePixel = 0
    local c = Instance.new('UICorner', b)
    c.CornerRadius = UDim.new(0, 6)
    local s = Instance.new('UIStroke', b)
    s.Thickness = 1
    s.Color = Color3.fromRGB(50, 50, 50)
    s.Transparency = 0.7
    return b
end

local btnMin = makeCtrl(0, '-')
local btnOther = makeCtrl(28, '□')
local btnClose = makeCtrl(56, 'X')

for _, v in pairs({ btnMin, btnOther, btnClose }) do
    v.MouseEnter:Connect(function()
        TweenService:Create(
            v,
            TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(46, 46, 46) }
        ):Play()
    end)
    v.MouseLeave:Connect(function()
        TweenService:Create(
            v,
            TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(34, 34, 34) }
        ):Play()
    end)
end

-- Обработчик кнопки Other (btnOther) - переключение видимости GUI
btnOther.MouseButton1Click:Connect(function()
    screen.Enabled = not screen.Enabled
    local t1 = TweenService:Create(btnOther, TweenInfo.new(0.12), {
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = Color3.fromRGB(46, 46, 46),
    })
    local t2 = TweenService:Create(btnOther, TweenInfo.new(0.12), {
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Color3.fromRGB(34, 34, 34),
    })
    t1:Play()
    t1.Completed:Wait()
    t2:Play()
end)

btnMin.MouseButton1Click:Connect(function()
    screen.Enabled = not screen.Enabled
    local t1 = TweenService:Create(btnOther, TweenInfo.new(0.12), {
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = Color3.fromRGB(46, 46, 46),
    })
    local t2 = TweenService:Create(btnOther, TweenInfo.new(0.12), {
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundColor3 = Color3.fromRGB(34, 34, 34),
    })
    t1:Play()
    t1.Completed:Wait()
    t2:Play()
end)

-- Обработка клавиши Ctrl для сворачивания/разворачивания GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if
        input.KeyCode == Enum.KeyCode.LeftControl
        or input.KeyCode == Enum.KeyCode.RightControl
    then
        screen.Enabled = not screen.Enabled
        local t1 = TweenService:Create(btnOther, TweenInfo.new(0.12), {
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundColor3 = Color3.fromRGB(46, 46, 46),
        })
        local t2 = TweenService:Create(btnOther, TweenInfo.new(0.12), {
            Size = UDim2.new(0, 22, 0, 22),
            BackgroundColor3 = Color3.fromRGB(34, 34, 34),
        })
        t1:Play()
        t1.Completed:Wait()
        t2:Play()
    end
end)

local leftWidth = 160
local left = Instance.new('Frame', main)
left.Size = UDim2.new(0, leftWidth, 1, -64)
left.Position = UDim2.new(0, 12, 0, 46)
left.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
left.BorderSizePixel = 0

local leftCorner = Instance.new('UICorner', left)
leftCorner.CornerRadius = UDim.new(0, 10)
local leftStroke = Instance.new('UIStroke', left)
leftStroke.Thickness = 1
leftStroke.Color = Color3.fromRGB(34, 34, 34)
leftStroke.Transparency = 0.7

local leftPadding = 12
local leftItems = {}
local tabNames = { 'Helper', 'Player', 'Stealer', 'Finder', 'Server' }
for i = 1, #tabNames do
    local item = Instance.new('TextButton', left)
    item.Size = UDim2.new(1, -leftPadding * 2, 0, 40)
    item.Position = UDim2.new(0, leftPadding, 0, 12 + (i - 1) * 46)
    item.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    item.BorderSizePixel = 0
    item.Text = tabNames[i]
    item.TextColor3 = Color3.fromRGB(255, 255, 255)
    item.TextSize = 14
    item.Font = Enum.Font.SourceSansBold
    item.AutoButtonColor = false

    local itemCorner = Instance.new('UICorner', item)
    itemCorner.CornerRadius = UDim.new(0, 8)
    local itemStroke = Instance.new('UIStroke', item)
    itemStroke.Thickness = 1
    itemStroke.Color = Color3.fromRGB(42, 42, 42)
    itemStroke.Transparency = 0.8

    leftItems[i] = item
end

local right = Instance.new('Frame', main)
right.Size = UDim2.new(1, -leftWidth - 40, 1, -64)
right.Position = UDim2.new(0, leftWidth + 24, 0, 46)
right.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
right.BorderSizePixel = 0
local rightCorner = Instance.new('UICorner', right)
rightCorner.CornerRadius = UDim.new(0, 10)
local rightStroke = Instance.new('UIStroke', right)
rightStroke.Thickness = 1
rightStroke.Color = Color3.fromRGB(40, 40, 40)
rightStroke.Transparency = 0.8

local tabs = {}
local function createTabFrame(name)
    local tabFrame = Instance.new('Frame')
    tabFrame.Name = name
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.Position = UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = right
    tabFrame.Visible = false
    return tabFrame
end

tabs.Helper = createTabFrame('Helper')
tabs.Player = createTabFrame('Player')
tabs.Stealer = createTabFrame('Stealer')
tabs.Finder = createTabFrame('Finder')
tabs.Server = createTabFrame('Server')

local function createToggleRow(
    parent,
    positionY,
    labelText,
    callback,
    initialState
)
    local row = Instance.new('Frame', parent)
    row.Size = UDim2.new(1, -28, 0, 44)
    row.Position = UDim2.new(0, 14, 0, positionY)
    row.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    row.BorderSizePixel = 0
    local rc = Instance.new('UICorner', row)
    rc.CornerRadius = UDim.new(0, 8)
    local rs = Instance.new('UIStroke', row)
    rs.Thickness = 1
    rs.Color = Color3.fromRGB(42, 42, 42)
    rs.Transparency = 0.85

    local label = Instance.new('TextLabel', row)
    label.Size = UDim2.new(0.78, 0, 0, 14)
    label.Position = UDim2.new(0, 12, 0.5, -7)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18 -- Increased font size for function labels
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new('TextButton', row)
    toggle.Size = UDim2.new(0, 56, 0, 26)
    toggle.Position = UDim2.new(1, -78, 0.5, -13)
    toggle.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    toggle.AutoButtonColor = false
    toggle.Text = ''
    local tc = Instance.new('UICorner', toggle)
    tc.CornerRadius = UDim.new(0, 8)
    local ts = Instance.new('UIStroke', toggle)
    ts.Thickness = 1
    ts.Color = Color3.fromRGB(52, 52, 52)
    ts.Transparency = 0.8

    local dot = Instance.new('Frame', toggle)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 6, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
    dot.BorderSizePixel = 0
    local dc = Instance.new('UICorner', dot)
    dc.CornerRadius = UDim.new(1, 0)
    local ds = Instance.new('UIStroke', dot)
    ds.Thickness = 1
    ds.Color = Color3.fromRGB(58, 58, 58)
    ds.Transparency = 0.85

    local state = initialState
    local function updateVisual()
        if state then
            dot.Position = UDim2.new(1, -18, 0.5, -6)
            dot.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
            toggle.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
        else
            dot.Position = UDim2.new(0, 6, 0.5, -6)
            dot.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
            toggle.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
        end
    end
    updateVisual()

    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        TweenService
            :Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(26, 26, 26)
                    or Color3.fromRGB(34, 34, 34),
            })
            :Play()
        callback(state)
    end)

    toggle.MouseEnter:Connect(function()
        TweenService:Create(
            toggle,
            TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(46, 46, 46) }
        ):Play()
    end)
    toggle.MouseLeave:Connect(function()
        TweenService
            :Create(toggle, TweenInfo.new(0.12), {
                BackgroundColor3 = state and Color3.fromRGB(26, 26, 26)
                    or Color3.fromRGB(34, 34, 34),
            })
            :Play()
    end)

    return row
end

-- === УНИВЕРСАЛЬНАЯ ФУНКЦИЯ: TextBox Row (в стиле тогглов и кнопок) ===
-- === УНИВЕРСАЛЬНАЯ ФУНКЦИЯ: TextBox Row с авто-расширением ===
local function createTextBoxRow(parent, positionY, labelText, placeholderText, onEnterCallback)
    local row = Instance.new('Frame', parent)
    row.Size = UDim2.new(1, -28, 0, 44)
    row.Position = UDim2.new(0, 14, 0, positionY)
    row.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    row.BorderSizePixel = 0
    local rc = Instance.new('UICorner', row)
    rc.CornerRadius = UDim.new(0, 8)
    local rs = Instance.new('UIStroke', row)
    rs.Thickness = 1
    rs.Color = Color3.fromRGB(42, 42, 42)
    rs.Transparency = 0.85

    local label = Instance.new('TextLabel', row)
    label.Size = UDim2.new(0.5, 0, 0, 14)
    label.Position = UDim2.new(0, 12, 0.5, -7)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- Контейнер для TextBox (чтобы он мог расширяться)
    local container = Instance.new('Frame', row)
    container.Size = UDim2.new(0, 120, 0, 26)
    container.Position = UDim2.new(1, 0.5, 0.5, -13)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true

    local textBox = Instance.new('TextBox', container)
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.Position = UDim2.new(0, 0, 0, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    textBox.Text = ""
    textBox.PlaceholderText = placeholderText
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.SourceSansBold
    textBox.ClearTextOnFocus = false
    local tbCorner = Instance.new('UICorner', textBox)
    tbCorner.CornerRadius = UDim.new(0, 8)
    local tbStroke = Instance.new('UIStroke', textBox)
    tbStroke.Thickness = 1
    tbStroke.Color = Color3.fromRGB(52, 52, 52)
    tbStroke.Transparency = 0.8

    -- Минимальная и максимальная ширина
    local MIN_WIDTH = 80
    local MAX_WIDTH = 200
    local PADDING = 16 -- внутренний отступ

    -- Функция обновления размера
    local function updateSize()
        local text = textBox.Text
        if text == "" then text = textBox.PlaceholderText end
        local textBounds = game:GetService("TextService"):GetTextSize(
            text,
            textBox.TextSize,
            textBox.Font,
            Vector2.new(math.huge, textBox.AbsoluteSize.Y)
        )
        local targetWidth = math.clamp(textBounds.X + PADDING, MIN_WIDTH, MAX_WIDTH)
        local currentWidth = container.Size.X.Offset

        if math.abs(targetWidth - currentWidth) > 2 then
            TweenService:Create(container, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, targetWidth, 0, 26)
            }):Play()
            -- Смещаем контейнер влево при расширении
            TweenService:Create(container, TweenInfo.new(0.15), {
                Position = UDim2.new(1, -targetWidth - 22, 0.5, -13)
            }):Play()
        end
    end

    -- Анимация фокуса
    textBox.Focused:Connect(function()
        TweenService:Create(textBox, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(46, 46, 46)
        }):Play()
        TweenService:Create(tbStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(100, 180, 255)
        }):Play()
        updateSize()
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textBox, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(34, 34, 34)
        }):Play()
        TweenService:Create(tbStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(52, 52, 52)
        }):Play()
        updateSize()

        if enterPressed and onEnterCallback then
            local input = textBox.Text:gsub("%s+", "")
            if input ~= "" then
                onEnterCallback(input)
                textBox.Text = "" -- очищаем после ввода
                updateSize()
            end
        end
    end)

    -- Обновление при вводе
    textBox:GetPropertyChangedSignal("Text"):Connect(updateSize)

    -- Hover
    textBox.MouseEnter:Connect(function()
        if not textBox.Focused then
            TweenService:Create(textBox, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(42, 42, 42)
            }):Play()
        end
    end)
    textBox.MouseLeave:Connect(function()
        if not textBox.Focused then
            TweenService:Create(textBox, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(34, 34, 34)
            }):Play()
        end
    end)

    -- Инициализация
    updateSize()

    return row, textBox
end

local function createButtonRow(parent, positionY, labelText, callback)
    local row = Instance.new('Frame', parent)
    row.Size = UDim2.new(1, -28, 0, 44)
    row.Position = UDim2.new(0, 14, 0, positionY)
    row.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    row.BorderSizePixel = 0
    local rc = Instance.new('UICorner', row)
    rc.CornerRadius = UDim.new(0, 8)
    local rs = Instance.new('UIStroke', row)
    rs.Thickness = 1
    rs.Color = Color3.fromRGB(42, 42, 42)
    rs.Transparency = 0.85

    local label = Instance.new('TextLabel', row)
    label.Size = UDim2.new(0.78, 0, 0, 14)
    label.Position = UDim2.new(0, 12, 0.5, -7)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18 -- Increased font size for function labels
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new('TextButton', row)
    button.Size = UDim2.new(0, 56, 0, 26)
    button.Position = UDim2.new(1, -78, 0.5, -13)
    button.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    button.AutoButtonColor = false
    button.Text = 'Go'
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.SourceSansBold
    local bc = Instance.new('UICorner', button)
    bc.CornerRadius = UDim.new(0, 8)
    local bs = Instance.new('UIStroke', button)
    bs.Thickness = 1
    bs.Color = Color3.fromRGB(52, 52, 52)
    bs.Transparency = 0.8

    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(46, 46, 46) }
        ):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(34, 34, 34) }
        ):Play()
    end)
    button.MouseButton1Click:Connect(function()
        local t1 = TweenService:Create(
            button,
            TweenInfo.new(0.08),
            { Size = UDim2.new(0, 62, 0, 28) }
        )
        local t2 = TweenService:Create(
            button,
            TweenInfo.new(0.12),
            { Size = UDim2.new(0, 56, 0, 26) }
        )
        t1:Play()
        t1.Completed:Wait()
        t2:Play()
        callback()
    end)

    return row
end

-- Настройка переключения вкладок
local currentTab = tabs.Helper
currentTab.Visible = true
leftItems[1].BackgroundColor3 = Color3.fromRGB(30, 30, 30)

for i, item in ipairs(leftItems) do
    item.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.Visible = false
        end
        for _, btn in ipairs(leftItems) do
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            TweenService:Create(
                btn,
                TweenInfo.new(0.12),
                { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
            ):Play()
        end
        currentTab = tabs[tabNames[i]]
        currentTab.Visible = true
        item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TweenService:Create(
            item,
            TweenInfo.new(0.12),
            { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }
        ):Play()
    end)
    item.MouseEnter:Connect(function()
        if currentTab ~= tabs[tabNames[i]] then
            TweenService:Create(
                item,
                TweenInfo.new(0.12),
                { BackgroundColor3 = Color3.fromRGB(28, 28, 28) }
            ):Play()
        end
    end)
    item.MouseLeave:Connect(function()
        if currentTab ~= tabs[tabNames[i]] then
            TweenService:Create(
                item,
                TweenInfo.new(0.12),
                { BackgroundColor3 = Color3.fromRGB(20, 20, 20) }
            ):Play()
        end
    end)
end

-- Вкладка Player
createToggleRow(
    tabs.Player,
    12,
    'Speed Boost (No Steal)',
    toggleSpeedBoostNoSteal,
    config.tpwalking
)
createToggleRow(
    tabs.Player,
    64,
    'Speed Boost (Steal)',
    toggleSpeedBoostSteal,
    config.tpwalkingSteal
)
createToggleRow(
    tabs.Player,
    116,
    'Anti Ragdoll',
    toggleAntiRagdoll,
    config.antiRagdollEnabled
)
createToggleRow(
    tabs.Player,
    168,
    'Infinity Jump',
    toggleInfJump,
    config.infJumpEnabled
)

-- Вкладка Stealer
createToggleRow(
    tabs.Stealer,
    12,
    'Auto Steal Nearest',
    toggleAutoSteal,
    config.autoStealEnabled
)
createToggleRow(tabs.Stealer, 64, 'Desync (Updated)', toggleDesync, config.desyncEnabled)
createToggleRow(
    tabs.Stealer,
    116,
    'Auto Kick Steal',
    toggleAutoKickSteal,
    config.autoKickStealEnabled
)

createToggleRow(
    tabs.Stealer,
    168,
    'Steal Upstairs (Platform) keybind C',
    toggleStealUpstairs,
    config.stealUpstairsEnabled
)

-- Вкладка Helper
createToggleRow(
    tabs.Helper,
    12,
    'Player ESP',
    togglePlayerESP,
    config.playerESPEnabled
)
createToggleRow(
    tabs.Helper,
    64,
    'Highest Value Brainrot ESP',
    toggleBrainrotESP,
    config.brainrotESPEnabled
)
createToggleRow(
    tabs.Helper,
    116,
    'Timer ESP',
    toggleTimerESP,
    config.timerESPEnabled
)

-- В разделе создания интерфейса вкладки Helper, после последнего createToggleRow:
createToggleRow(
    tabs.Helper,
    220, -- Смещаем позицию вниз, чтобы не перекрывать существующие элементы
    'No Camera Collision',
    toggleNoCameraCollision,
    config.noCameraCollisionEnabled
)

createToggleRow(
    tabs.Helper,
    272,
    'Anti Effect',
    toggleBeeProtection,
    config.beeProtectionEnabled
)

createToggleRow(tabs.Helper, 168, 'Aimbot', toggleAimbot, config.aimbotEnabled)


local serverHopperEnabled = config.serverHopperEnabled or false
local minGenerationRaw = config.minGenerationRaw or 1000000 -- по умолчанию 1M
local hopperActive = false

local function startServerHopper()
    if hopperActive then return end
    hopperActive = true

    spawn(function()
        while serverHopperEnabled and hopperActive do
            local minGen = tonumber(minGenerationRaw)
            if not minGen or minGen <= 0 then
                minGen = 1000000 -- защита
            end

            local found = false
            local plots = Workspace:FindFirstChild('Plots')
            if plots then
                for _, plot in pairs(plots:GetChildren()) do
                    -- AnimalPodiums
                    local podiums = plot:FindFirstChild('AnimalPodiums')
                    if podiums then
                        for _, podium in pairs(podiums:GetChildren()) do
                            local base = podium:FindFirstChild('Base')
                            if base then
                                local spawn = base:FindFirstChild('Spawn')
                                if spawn then
                                    local attach = spawn:FindFirstChild('Attachment')
                                    if attach then
                                        local overhead = attach:FindFirstChild('AnimalOverhead')
                                        if overhead then
                                            local gen = overhead:FindFirstChild('Generation')
                                            if gen then
                                                local val = parseGenerationValue(gen.Text) -- используем старый парсер
                                                if val and val >= minGen then
                                                    found = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if found then break end

                    -- OVERHEAD_ATTACHMENT (дополнительно)
                    for _, obj in pairs(plot:GetDescendants()) do
                        if obj.Name == 'OVERHEAD_ATTACHMENT' then
                            local overhead = obj:FindFirstChild('AnimalOverhead')
                            if overhead then
                                local gen = overhead:FindFirstChild('Generation')
                                if gen then
                                    local val = parseGenerationValue(gen.Text)
                                    if val and val >= minGen then
                                        found = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    if found then break end
                end
            end

            -- === НЕ НАШЛИ → ХОПИМ ===
            if not found then
                print("Server Hopper: No brainrot ≥ " .. minGen .. " found. Hopping...")
                local servers = getAvailableServers()
                if #servers == 0 then
                    warn("Server Hopper: No servers. Retrying in 5s...")
                    task.wait(5)
                else
                    local target = servers[math.random(1, #servers)]
                    -- Устанавливаем автозапуск на следующем сервере
                    pcall(function()
                        queue_on_teleport([[loadstring(game:HttpGet('https://raw.githubusercontent.com/papapamatem/plutos/refs/heads/main/plutos.lua'))()]])
                    end)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
                    task.wait(10)
                end
            else
                -- === НАШЛИ! ===
                print("Server Hopper: Found brainrot ≥ " .. minGen .. "! Stopping.")
                hopperActive = false
                serverHopperEnabled = false
                config.serverHopperEnabled = false
                saveConfig()

                -- Обновляем UI тоггла
                local toggleRow = tabs.Finder:FindFirstChild("ServerHopperToggle")
                if toggleRow then
                    local toggleBtn = toggleRow:FindFirstChild("TextButton")
                    local dot = toggleBtn and toggleBtn:FindFirstChild("Frame")
                    if dot then
                        dot.Position = UDim2.new(0, 6, 0.5, -6)
                        dot.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                    end
                end
                break
            end
        end
    end)
end

-- === Остановка ===
local function stopServerHopper()
    hopperActive = false
end

-- === Тоггл Server Hopper ===
local function toggleServerHopper(value)
    serverHopperEnabled = value
    config.serverHopperEnabled = value
    saveConfig()

    if value then
        startServerHopper()
    else
        stopServerHopper()
    end
end

local _, genTextBox = createTextBoxRow(
    tabs.Finder,
    64,
    "Min Generation (number)",
    "e.g. 10000000",
    function(input)
        local num = tonumber(input)
        if num and num > 0 then
            minGenerationRaw = num
            config.minGenerationRaw = num
            saveConfig()
            print("Server Hopper: Min generation set to " .. num)
        else
            genTextBox.Text = tostring(minGenerationRaw)
            warn("Invalid number! Using: " .. minGenerationRaw)
        end
    end
)
genTextBox.Text = tostring(minGenerationRaw)

createToggleRow(
    tabs.Finder,
    116,
    'Server Hopper',
    toggleServerHopper,
    config.serverHopperEnabled
)

-- Вкладка Finder
createButtonRow(
    tabs.Finder,
    12,
    'Auto Moreira (Need to have good brainrots)',
    moreira
)

createButtonRow(tabs.Server, 64, 'Rejoin Server', rejoinServer)
createButtonRow(tabs.Server, 12, 'Server Hop', serverHop)
createTextBoxRow(
    tabs.Server,
    116, -- позиция под Rejoin Server
    "Job ID Input",
    "Enter Job ID...",
    function(jobId)
        print("Teleporting to Job ID: " .. jobId)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
        end)
    end
)

-- Закрытие GUI (только уничтожаем GUI, не отключаем функции и не сохраняем false в config)
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- === МОБИЛЬНЫЕ КНОПКИ: МАЛЕНЬКИЕ ПРЯМОУГОЛЬНИКИ, БЕЗ БИНДОВ ===
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "PlutosMobile"
MobileGui.ResetOnSpawn = false
MobileGui.Parent = CoreGui
MobileGui.DisplayOrder = 999

local FORCE_MOBILE = false

local function isMobile()
    if FORCE_MOBILE then return true end
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- === ДАННЫЕ КНОПОК ===
local buttons = {
    { name = "Steal Upstairs", key = "stealUpstairsEnabled", func = toggleStealUpstairs },
    { name = "Speed No Steal", key = "tpwalking", func = toggleSpeedBoostNoSteal },
    { name = "Speed Steal",    key = "tpwalkingSteal", func = toggleSpeedBoostSteal },
}

local BUTTON_SIZE = UDim2.new(0, 110, 0, 45)  -- МАЛЕНЬКИЕ!
local PADDING = 12

-- === ОГРАНИЧЕНИЕ ПОЗИЦИИ ===
local function clampPosition(pos)
    local cam = Workspace.CurrentCamera
    local screen = cam.ViewportSize
    local minX = PADDING
    local maxX = screen.X - 110 - PADDING
    local minY = PADDING
    local maxY = screen.Y - 45 - PADDING
    return UDim2.new(0, math.clamp(pos.X.Offset, minX, maxX), 0, math.clamp(pos.Y.Offset, minY, maxY))
end

-- === ДЕФОЛТНАЯ ПОЗИЦИЯ ===
local function getDefaultPosition(index)
    local cam = Workspace.CurrentCamera
    local screen = cam.ViewportSize
    local totalH = 45 * #buttons + 12 * (#buttons - 1)
    local startY = (screen.Y - totalH) / 2 - 60
    local x = screen.X * 0.94 - 55
    local y = startY + (index - 1) * 57
    return UDim2.new(0, x, 0, y)
end

-- === СОЗДАНИЕ КНОПКИ ===
local function createButton(data, index)
    local btn = Instance.new("TextButton")
    btn.Size = BUTTON_SIZE
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = MobileGui

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 14)

    -- Мягкий glow
    local glow = Instance.new("Frame", btn)
    glow.Size = UDim2.new(1, 8, 1, 8)
    glow.Position = UDim2.new(0, -4, 0, -4)
    glow.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    glow.BackgroundTransparency = 0.85
    glow.ZIndex = btn.ZIndex - 1
    local gCorner = Instance.new("UICorner", glow)
    gCorner.CornerRadius = UDim.new(0, 18)

    -- Статус ON/OFF
    local status = Instance.new("TextLabel", btn)
    status.Size = UDim2.new(0, 38, 1, 0)
    status.Position = UDim2.new(0, 0, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "ON"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextScaled = true
    status.Font = Enum.Font.GothamBold

    -- Название
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -42, 1, 0)
    label.Position = UDim2.new(0, 42, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = data.name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    -- === ПЕРВОЕ ПОЯВЛЕНИЕ ===
    local initialized = false
    local function initPosition()
        if initialized then return end
        initialized = true
        local saved = config["mobile_pos_" .. data.key]
        local pos = saved and UDim2.new(0, saved.X, 0, saved.Y) or getDefaultPosition(index)
        btn.Position = clampPosition(pos)
    end

    -- === ДРАГГИНГ ===
    local dragging = false
    local startPos, startMouse

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = btn.Position
            startMouse = input.Position
            initPosition()
        end
    end)

    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startMouse
            btn.Position = clampPosition(UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y))
        end
    end)

    btn.InputEnded:Connect(function(input)
        if dragging then
            dragging = false
            local final = clampPosition(btn.Position)
            btn.Position = final
            config["mobile_pos_" .. data.key] = { X = final.X.Offset, Y = final.Y.Offset }
            saveConfig()
        end
    end)

    -- === ОБНОВЛЕНИЕ СТАТУСА ===
    local function update(state)
        status.Text = state and "ON" or "OFF"
        status.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        glow.BackgroundColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        btn.Visible = true
        initPosition()
    end

    -- === АВТО-ПОДСТРОЙКА ЭКРАНА ===
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        task.wait()
        if config["mobile_pos_" .. data.key] then
            local saved = config["mobile_pos_" .. data.key]
            btn.Position = clampPosition(UDim2.new(0, saved.X, 0, saved.Y))
        else
            initPosition()
        end
    end)

    -- === КЛИК ===
    btn.MouseButton1Click:Connect(function()
        local newState = not config[data.key]
        config[data.key] = newState
        saveConfig()
        data.func(newState)
        update(newState)
    end)

    -- Инициализация
    update(config[data.key])

    return { update = update }
end

-- === СОЗДАНИЕ КНОПОК ===
local buttonObjects = {}
if isMobile() then
    for i, data in ipairs(buttons) do
        buttonObjects[data.key] = createButton(data, i)
    end
end

-- === СИНХРОНИЗАЦИЯ ===
spawn(function()
    while true do
        task.wait(0.3)
        if isMobile() then
            for _, data in ipairs(buttons) do
                if buttonObjects[data.key] and config[data.key] ~= nil then
                    pcall(buttonObjects[data.key].update, config[data.key])
                end
            end
        end
    end
end)

-- === СКРЫТИЕ ПРИ GUI ===
local function updateGui()
    MobileGui.Enabled = isMobile() and not (screen and screen.Enabled)
end
updateGui()
if screen then
    screen:GetPropertyChangedSignal("Enabled"):Connect(updateGui)
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); updateGui() end)


local function scanAndNotify()
    local plots = Workspace:FindFirstChild('Plots')
    if not plots then return end

    local currentBest = nil
    local bestValue = 0

    for _, plot in pairs(plots:GetChildren()) do

        -- AnimalPodiums
        local podiums = plot:FindFirstChild('AnimalPodiums')
        if podiums then
            for _, podium in pairs(podiums:GetChildren()) do
                local base = podium:FindFirstChild('Base')
                if base then
                    local spawn = base:FindFirstChild('Spawn')
                    if spawn then
                        local attach = spawn:FindFirstChild('Attachment')
                        if attach then
                            local overhead = attach:FindFirstChild('AnimalOverhead')
                            if overhead then
                                local gen = overhead:FindFirstChild('Generation')
                                local nameLbl = overhead:FindFirstChild('DisplayName')
                                local rarityLbl = overhead:FindFirstChild('Rarity')
                                if gen and nameLbl and rarityLbl then
                                    local val = parseGenerationValue(gen.Text)
                                    if val and val > bestValue then
                                        bestValue = val
                                        currentBest = {
                                            displayName = nameLbl.Text,
                                            rarity = rarityLbl.Text,
                                            generation = gen.Text,
                                            genValue = val,
                                            plotName = plot.Name,
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- OVERHEAD_ATTACHMENT
        for _, obj in pairs(plot:GetDescendants()) do
            if obj.Name == 'OVERHEAD_ATTACHMENT' then
                local AnimalOverhead = obj:FindFirstChild('AnimalOverhead')
                if AnimalOverhead then
                    local DisplayName = AnimalOverhead:FindFirstChild('DisplayName')
                    local Generation = AnimalOverhead:FindFirstChild('Generation')
                    local Rarity = AnimalOverhead:FindFirstChild('Rarity')
                    if DisplayName and Generation and Rarity then
                        local val = parseGenerationValue(Generation.Text)
                        if val and val > bestValue then
                            bestValue = val
                            currentBest = {
                                displayName = DisplayName.Text,
                                generation = Generation.Text,
                                rarity = Rarity.Text,
                                genValue = val,
                                plotName = plot.Name,
                            }
                        end
                    end
                end
            end
        end
    end

    -- Если ничего не найдено — выходим
    if not currentBest then return end

    -- Если лучше предыдущего — отправляем
    if currentBest.genValue > lastBestValue then
        lastBestValue = currentBest.genValue
        lastBestData = currentBest

        if not isPublicServer() then
            return
        end

        local playerCount = tostring(#Players:GetPlayers()) .. "/8"
        local jobId = game.JobId
        local joinScript = "game:GetService('TeleportService'):TeleportToPlaceInstance(109983668079237, '" .. jobId .. "')"
        local joinLink = "[Click to Join](https://www.roblox.com/games/start?placeId=109983668079237&gameInstanceId=" .. jobId .. ")"
        local timeString = os.date('%H:%M:%S %d/%m/%Y')

        local imageUrl = getBrainrotImageUrl(currentBest.displayName)
        local thumbnail = imageUrl and (imageUrl .. "?width=300") or nil

        if currentBest.genValue >= 10000000 then
            -- 10M+ → 3 вебхука
            local embedFull = {
                title = 'Brainrot found! (10M+)',
                color = 16711680,
                fields = {
                    { name = currentBest.displayName, value = currentBest.rarity .. ' | ' .. currentBest.generation, inline = true },
                    { name = '👥Players', value = playerCount, inline = true },
                    { name = '🆔Job ID (PC)', value = '```' .. jobId .. '```', inline = false },
                    { name = '🆔Job ID (Mobile)', value = '`' .. jobId .. '`', inline = false },
                    { name = '🔗Join Link', value = joinLink, inline = false },
                    { name = '📜Join Script (PC)', value = '```lua\n' .. joinScript .. '\n```', inline = false },
                },
                footer = { text = "Pluto's SAB Notifier • " .. timeString },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            if thumbnail then embedFull.thumbnail = { url = thumbnail } end
            sendToWebhook(webhookHighTierFull, embedFull)

            local embedHighlight = {
                title = 'Brainrot Highlight (10M+)',
                color = 16711680,
                fields = { { name = currentBest.displayName, value = currentBest.rarity .. ' | ' .. currentBest.generation, inline = true } },
                footer = { text = "Pluto's Highlights • " .. timeString },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            if thumbnail then embedHighlight.thumbnail = { url = thumbnail } end
            sendToWebhook(webhookHighlights, embedHighlight)

        elseif currentBest.genValue >= 1000000 then
            -- 1M–10M → Low Tier
            local embed = {
                title = 'Brainrot found! (1M–10M)',
                color = 16763904,
                fields = {
                    { name = currentBest.displayName, value = currentBest.rarity .. ' | ' .. currentBest.generation, inline = true },
                    { name = '👥Players', value = playerCount, inline = true },
                    { name = '🆔Job ID (PC)', value = '```' .. jobId .. '```', inline = false },
                    { name = '🆔Job ID (Mobile)', value = '`' .. jobId .. '`', inline = false },
                    { name = '🔗Join Link', value = joinLink, inline = false },
                    { name = '📜Join Script (PC)', value = '```lua\n' .. joinScript .. '\n```', inline = false },
                },
                footer = { text = "Pluto's SAB Notifier • " .. timeString },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
            if thumbnail then embed.thumbnail = { url = thumbnail } end
            sendToWebhook(webhookLowTier, embed)
        end
    end
end

spawn(function()

    -- Первая проверка
    pcall(scanAndNotify)

    -- Отслеживаем изменения в реальном времени
    local connection
    connection = Workspace.Plots.ChildAdded:Connect(function(child)
        task.wait(1) -- даём спавн
        pcall(scanAndNotify)
    end)

    -- Также проверяем при изменении потомков (новые AnimalOverhead)
    local descendantConn
    descendantConn = Workspace.Plots.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "AnimalOverhead" or descendant.Name == "Generation" then
            task.wait(0.5)
            pcall(scanAndNotify)
        end
    end)
    end)
