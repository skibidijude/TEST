local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- OWNER TAG
do
    local Owners = { ["supremekida2"] = true, ["LLzen0"] = true }
    local tagged = {}
    local function CreateOwnerTag(p)
        if tagged[p] then return end
        local char = p.Character; if not char then return end
        local head = char:FindFirstChild("Head"); if not head then return end
        if char:FindFirstChild("drAk_OTag") then return end
        tagged[p] = true
        local bb = Instance.new("BillboardGui")
        bb.Name = "drAk_OTag"; bb.Size = UDim2.new(0,120,0,26)
        bb.StudsOffset = Vector3.new(0,2.5,0); bb.AlwaysOnTop = true; bb.Parent = char
        local fr = Instance.new("Frame"); fr.Size = UDim2.new(1,0,1,0)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BorderSizePixel = 0; fr.Parent = bb
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,16)
        local st = Instance.new("UIStroke", fr); st.Color = Color3.fromRGB(255,255,255)
        st.Thickness = 1.5; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local lbl = Instance.new("TextLabel", fr); lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
        lbl.TextColor3 = Color3.fromRGB(255,215,0); lbl.Text = "drΛk ᴏᴡɴᴇʀ 👑"
        p.CharacterRemoving:Connect(function() tagged[p] = nil end)
    end
    local function check(p)
        if not Owners[p.Name] then return end
        if p.Character then CreateOwnerTag(p) end
        p.CharacterAdded:Connect(function() task.wait(0.5); CreateOwnerTag(p) end)
    end
    for _, p in ipairs(Players:GetPlayers()) do check(p) end
    Players.PlayerAdded:Connect(check)
end



local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "drΛkDuel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Color Palette
local COLORS = {
    MainBG = Color3.fromRGB(6, 6, 8),
    TabBG = Color3.fromRGB(8, 8, 10),
    Border = Color3.fromRGB(220, 220, 220),
    TextActive = Color3.fromRGB(255, 255, 255),
    TextInactive = Color3.fromRGB(48, 48, 48),
    RowBG = Color3.fromRGB(10, 10, 12)
}

-- Nine Hub style colors for oval buttons
local NH = {
    BG      = Color3.fromRGB(8, 8, 8),
    ACTIVE  = Color3.fromRGB(30, 30, 30),
    BORDER  = Color3.fromRGB(50, 50, 50),
    TEXT    = Color3.fromRGB(210, 210, 210),
    DOT_OFF = Color3.fromRGB(50, 50, 50),
    DOT_ON  = Color3.fromRGB(100, 220, 100),
}

-------------------------------------------------------------------------
-- UI CORE ENGINE
-------------------------------------------------------------------------
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    obj.Parent = props.Parent
    return obj
end

local ToggleIcon = create("TextButton", {
    Size = UDim2.new(0, 70, 0, 36), Position = UDim2.new(0.05, 0, 0.2, 0),
    BackgroundColor3 = COLORS.MainBG, Text = "drΛk", TextColor3 = COLORS.Border,
    Font = "GothamBold", TextSize = 14, Parent = ScreenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ToggleIcon})
create("UIStroke", {Color = COLORS.Border, Thickness = 1.5, Parent = ToggleIcon})

local MainFrame = create("Frame", {
    Size = UDim2.new(0, 340, 0, 380), Position = UDim2.new(0.5, -170, 0.5, -190),
    BackgroundColor3 = COLORS.MainBG, BackgroundTransparency = 0.2, Visible = false, Parent = ScreenGui
})
create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
create("UIStroke", {Color = COLORS.Border, Thickness = 2, Parent = MainFrame})

local Header = create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = MainFrame})
create("TextLabel", {
    Text = "drΛk ᴅᴜᴇʟ", TextColor3 = COLORS.Border, Font = "GothamBold", TextSize = 18,
    Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
    BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Header
})

local TabContainer = create("Frame", {
    Size = UDim2.new(0.92, 0, 0, 30), Position = UDim2.new(0.04, 0, 0.13, 0),
    BackgroundColor3 = COLORS.TabBG, Parent = MainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabContainer})
local TabList = create("UIListLayout", {FillDirection = "Horizontal", HorizontalAlignment = "Center", Parent = TabContainer})

local PageContainer = create("Frame", {
    Size = UDim2.new(1, 0, 0.75, 0), Position = UDim2.new(0, 0, 0.22, 0),
    BackgroundTransparency = 1, Parent = MainFrame
})

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
    local Page = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
        ScrollBarThickness = 0, AutomaticCanvasSize = "Y", Parent = PageContainer
    })
    create("UIListLayout", {HorizontalAlignment = "Center", Padding = UDim.new(0, 8), Parent = Page})
    Pages[name] = Page
    local TabBtn = create("TextButton", {
        Size = UDim2.new(0.25, 0, 1, 0), BackgroundTransparency = 1,
        Text = name, TextColor3 = COLORS.TextInactive, Font = "GothamBold", TextSize = 10,
        Parent = TabContainer
    })
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = COLORS.TextInactive end
        Page.Visible = true
        TabBtn.TextColor3 = COLORS.TextActive
    end)
    TabButtons[name] = TabBtn
end

local ToggleSetters = {}
local ToggleVisuals = {}

local function AddToggle(pageName, labelText, default, callback)
    local active = default
    local Row = create("Frame", {
        Size = UDim2.new(0.92, 0, 0, 50), BackgroundColor3 = COLORS.RowBG,
        BackgroundTransparency = 0.5, Parent = Pages[pageName]
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Row})
    create("UIStroke", {Color = COLORS.Border, Thickness = 1, Transparency = 0.8, Parent = Row})
    create("TextLabel", {
        Text = labelText, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
        TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 13,
        BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Row
    })
    local TglBg = create("Frame", {
        Size = UDim2.new(0, 42, 0, 20), Position = UDim2.new(0.95, -42, 0.5, -10),
        BackgroundColor3 = active and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(18, 18, 20), Parent = Row
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TglBg})
    local Circle = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16), Position = active and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), Parent = TglBg
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})
    local Btn = create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = Row})
    local function updateVisual(val)
        active = val
        TweenService:Create(TglBg, TweenInfo.new(0.2), {BackgroundColor3 = val and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(18, 18, 20)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = val and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0)}):Play()
    end
    local function setState(val)
        if active == val then return end
        updateVisual(val)
        callback(val)
    end
    ToggleSetters[labelText] = setState
    ToggleVisuals[labelText] = updateVisual
    Btn.MouseButton1Click:Connect(function()
        setState(not active)
    end)
end

for _, tab in ipairs({"Combat", "Protect", "Visual", "Settings"}) do CreatePage(tab) end

local function AddButton(pageName, labelText, callback)
    local Row = create("Frame", {
        Size = UDim2.new(0.92, 0, 0, 50), BackgroundColor3 = COLORS.RowBG,
        BackgroundTransparency = 0.5, Parent = Pages[pageName]
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Row})
    create("UIStroke", {Color = COLORS.Border, Thickness = 1, Transparency = 0.8, Parent = Row})
    create("TextLabel", {
        Text = labelText, Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
        TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 13,
        BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Row
    })
    local arrow = create("TextLabel", {
        Text = "▶", Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -34, 0.5, -12),
        TextColor3 = Color3.fromRGB(180, 180, 200), Font = "GothamBold", TextSize = 14,
        BackgroundTransparency = 1, Parent = Row
    })
    local Btn = create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = Row})
    Btn.MouseButton1Click:Connect(function() callback() end)
end

local function AddInput(pageName, labelText, defaultVal, suffix, callback)
    suffix = suffix or ""
    local Row = create("Frame", {
        Size = UDim2.new(0.92, 0, 0, 50), BackgroundColor3 = COLORS.RowBG,
        BackgroundTransparency = 0.5, Parent = Pages[pageName]
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Row})
    create("UIStroke", {Color = COLORS.Border, Thickness = 1, Transparency = 0.8, Parent = Row})
    create("TextLabel", {
        Text = labelText, Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0),
        TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 12,
        BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Row
    })
    local stroke = create("UIStroke", {Color = Color3.fromRGB(32, 32, 32), Thickness = 1.5})
    local box = create("TextBox", {
        Size = UDim2.new(0.3, 0, 0, 28), Position = UDim2.new(0.95, -74, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        Text = tostring(defaultVal) .. suffix,
        TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 13,
        ClearTextOnFocus = true, Parent = Row
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = box})
    stroke.Parent = box
    box.Focused:Connect(function() stroke.Color = Color3.fromRGB(220,220,220) end)
    box.FocusLost:Connect(function()
        stroke.Color = Color3.fromRGB(32, 32, 32)
        local n = tonumber(box.Text:gsub("[^%d%.]",""))
        if n then
            callback(n)
            box.Text = tostring(n) .. suffix
        else
            box.Text = tostring(defaultVal) .. suffix
        end
    end)
end

TabButtons["Combat"].TextColor3 = COLORS.TextActive
Pages["Combat"].Visible = true

-------------------------------------------------------------------------
-- TIGY VELOCITY HELPER
-------------------------------------------------------------------------
local function tigyApplyVelocity(root, moveDir, speed)
    if not root then return end
    local flat = Vector3.new(moveDir.X, 0, moveDir.Z)
    if flat.Magnitude > 0.05 then
        flat = flat.Unit
        root.AssemblyLinearVelocity = Vector3.new(flat.X * speed, root.AssemblyLinearVelocity.Y, flat.Z * speed)
    else
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * 0.82, v.Y, v.Z * 0.82)
    end
end

-------------------------------------------------------------------------
-- SPEED MODULE
-------------------------------------------------------------------------
local Speed = {
    Enabled    = false,
    SpeedValue = 57.9,
    StealValue = 29.9,
    JumpValue  = 45,
    HeartbeatConn = nil,
    JumpConn      = nil,
    _charConn     = nil,
    SpeedUI        = nil,
}

local function createSpeedUI()
    local SpeedScreenGui = create("ScreenGui", {
        Name = "NimbusSpeed", ResetOnSpawn = false, Parent = CoreGui
    })
    local MainFrameS = create("Frame", {
        Name = "SpeedMainFrame",
        Size = UDim2.new(0, 240, 0, 220),
        Position = UDim2.new(1, -250, 0, 325),
        BackgroundColor3 = Color3.fromRGB(8, 8, 10),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0, Active = true, Draggable = false,
        Parent = SpeedScreenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrameS})
    create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Parent = MainFrameS})
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1, Text = "drΛk Speed Customizer",
        TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold, Parent = MainFrameS
    })
    local Header = create("Frame", {
        Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28), BorderSizePixel = 0,
        Parent = MainFrameS
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Header})
    local ToggleBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "ON", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 18,
        Font = Enum.Font.GothamBold, Parent = Header
    })
    local function createInputRow(labelText, defaultValue, pos)
        create("TextLabel", {
            Size = UDim2.new(0.6, 0, 0, 30), Position = UDim2.new(0, 12, 0, pos),
            BackgroundTransparency = 1, Text = labelText,
            TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, Parent = MainFrameS
        })
        local box = create("TextBox", {
            Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(1, -90, 0, pos),
            BackgroundColor3 = Color3.fromRGB(10, 10, 12),
            Text = tostring(defaultValue), TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold, ClearTextOnFocus = true, Parent = MainFrameS
        })
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = box})
        return box
    end
    local SpeedInput = createInputRow("Speed",    Speed.SpeedValue, 100)
    local StealInput = createInputRow("Steal Spd",Speed.StealValue, 140)
    local JumpInput  = createInputRow("Jump",     Speed.JumpValue,  180)

    ToggleBtn.MouseButton1Click:Connect(function()
        if Speed.Enabled then
            Speed.Enabled = false
            if Speed.HeartbeatConn then Speed.HeartbeatConn:Disconnect(); Speed.HeartbeatConn = nil end
            ToggleBtn.Text = "OFF"
            Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        else
            Speed.Enabled = true
            if Speed.HeartbeatConn then Speed.HeartbeatConn:Disconnect() end
            Speed.HeartbeatConn = RunService.Heartbeat:Connect(function()
                if not Speed.Enabled then return end
                local char = lp.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end
                local isSteal = hum.WalkSpeed < 25
                local targetSpd = isSteal and Speed.StealValue or Speed.SpeedValue
                tigyApplyVelocity(root, hum.MoveDirection, targetSpd)
            end)
            ToggleBtn.Text = "ON"
            Header.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        end
    end)

    local function validateInput(box, field, min, max)
        box.FocusLost:Connect(function()
            local num = tonumber(box.Text)
            if num then
                num = math.clamp(num, min, max)
                Speed[field] = num
                box.Text = string.format("%.2f", num):gsub("%.?0+$", "")
            else
                box.Text = string.format("%.2f", Speed[field]):gsub("%.?0+$", "")
            end
        end)
    end
    validateInput(SpeedInput, "SpeedValue", 1, 200)
    validateInput(StealInput, "StealValue", 1, 200)
    validateInput(JumpInput,  "JumpValue",  1, 200)

    -- Autosave: write speed values whenever a box loses focus
    local function saveSpeedConfig()
        pcall(function()
            writefile("drAkSpeed.txt",
                tostring(Speed.SpeedValue) .. "," ..
                tostring(Speed.StealValue) .. "," ..
                tostring(Speed.JumpValue)
            )
        end)
    end
    SpeedInput.FocusLost:Connect(saveSpeedConfig)
    StealInput.FocusLost:Connect(saveSpeedConfig)
    JumpInput.FocusLost:Connect(saveSpeedConfig)

    -- =====================================================================
    -- MOBILE-FRIENDLY DRAG (works on iPad, iPhone, PC)
    -- =====================================================================
    local dragSpeed = false
    local startPos = nil
    local startMousePos = nil

    local function onSpeedDragBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragSpeed = true
            startPos = MainFrameS.Position
            startMousePos = Vector2.new(input.Position.X, input.Position.Y)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragSpeed = false
                end
            end)
        end
    end

    local function onSpeedDragChanged(input)
        if not dragSpeed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = Vector2.new(
                input.Position.X - startMousePos.X,
                input.Position.Y - startMousePos.Y
            )
            MainFrameS.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end

    local function onSpeedDragEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragSpeed = false
        end
    end

    MainFrameS.InputBegan:Connect(onSpeedDragBegan)
    MainFrameS.InputEnded:Connect(onSpeedDragEnded)
    UserInputService.InputChanged:Connect(onSpeedDragChanged)
    -- =====================================================================

    return {
        ScreenGui  = SpeedScreenGui,
        ToggleBtn  = ToggleBtn,
        SpeedInput = SpeedInput,
        StealInput = StealInput,
        JumpInput  = JumpInput,
    }
end

local function enableSpeedCustomizer()
    if Speed.Enabled then return end

    if not Speed.SpeedUI then
        Speed.SpeedUI = createSpeedUI()
        Speed.SpeedValue = 57.9
        Speed.StealValue = 29.9
        Speed.JumpValue  = 45
        Speed.SpeedUI.SpeedInput.Text = "57.9"
        Speed.SpeedUI.StealInput.Text = "29.9"
        Speed.SpeedUI.JumpInput.Text  = "45"
    else
        Speed.SpeedUI.ScreenGui.Enabled = true
    end

    Speed.Enabled = true
    Speed.SpeedUI.ToggleBtn.Text = "ON"

    if not Speed._charConn then
        Speed._charConn = lp.CharacterAdded:Connect(function() end)
    end

    Speed.HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not Speed.Enabled then return end
        local char = lp.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        local isSteal = hum.WalkSpeed < 25
        local targetSpd = isSteal and Speed.StealValue or Speed.SpeedValue
        tigyApplyVelocity(root, hum.MoveDirection, targetSpd)
    end)
end

local function enableSpeedSilent()
    if Speed.Enabled then return end
    Speed.SpeedValue = 57.9
    Speed.StealValue = 29.9
    Speed.JumpValue  = 45
    Speed.Enabled = true
    if not Speed._charConn then
        Speed._charConn = lp.CharacterAdded:Connect(function() end)
    end
    Speed.HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not Speed.Enabled then return end
        local char = lp.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        local isSteal = hum.WalkSpeed < 25
        local targetSpd = isSteal and Speed.StealValue or Speed.SpeedValue
        tigyApplyVelocity(root, hum.MoveDirection, targetSpd)
    end)
end

local function showSpeedGuiOff()
    if not Speed.SpeedUI then
        Speed.SpeedUI = createSpeedUI()
    end
    Speed.SpeedUI.ScreenGui.Enabled = true
    Speed.SpeedUI.ToggleBtn.Text = "OFF"
    Speed.SpeedUI.SpeedInput.Text = tostring(Speed.SpeedValue)
    Speed.SpeedUI.StealInput.Text = tostring(Speed.StealValue)
    Speed.SpeedUI.JumpInput.Text  = tostring(Speed.JumpValue)
end

local function disableSpeedCustomizer()
    if not Speed.Enabled then return end
    Speed.Enabled = false
    if Speed.SpeedUI then
        Speed.SpeedUI.ToggleBtn.Text = "OFF"
        Speed.SpeedUI.ScreenGui.Enabled = false
    end
    if Speed._charConn  then Speed._charConn:Disconnect();  Speed._charConn  = nil end
    if Speed.HeartbeatConn then Speed.HeartbeatConn:Disconnect(); Speed.HeartbeatConn = nil end
    if Speed.JumpConn   then Speed.JumpConn:Disconnect();   Speed.JumpConn   = nil end
end

local SpeedCustomizer = Speed

-- Autosave: load saved speed values on startup
do
    local ok, data = pcall(readfile, "drAkSpeed.txt")
    if ok and data and data ~= "" then
        local parts = {}
        for v in data:gmatch("[^,]+") do table.insert(parts, tonumber(v)) end
        if parts[1] then Speed.SpeedValue = parts[1] end
        if parts[2] then Speed.StealValue = parts[2] end
        if parts[3] then Speed.JumpValue  = parts[3] end
    end
end

-------------------------------------------------------------------------
-- SAFE FOLLOW MODULE (Lock Target)
-------------------------------------------------------------------------
local SafeFollow = {
    Enabled = false, Locked = false, FOLLOW_DISTANCE = 6,
    lastMove = 0, gui = nil, btn = nil,
    targetChar = nil, heartbeatConn = nil, charAddedConn = nil
}
local function createSafeFollowUI()
    SafeFollow.gui = Instance.new("ScreenGui"); SafeFollow.gui.Name = "NimbusFollow"
    SafeFollow.gui.ResetOnSpawn = false; SafeFollow.gui.Enabled = false; SafeFollow.gui.Parent = CoreGui
    SafeFollow.btn = Instance.new("TextButton")
    SafeFollow.btn.Size = UDim2.new(0, 120, 0, 40); SafeFollow.btn.Position = UDim2.new(0.5, -60, 0.8, 0)
    SafeFollow.btn.Text = "LOCK: OFF"; SafeFollow.btn.Font = Enum.Font.GothamBold
    SafeFollow.btn.TextSize = 14; SafeFollow.btn.TextColor3 = Color3.new(1, 1, 1)
    SafeFollow.btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32); SafeFollow.btn.AutoButtonColor = true
    SafeFollow.btn.Parent = SafeFollow.gui
    local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 8); uiCorner.Parent = SafeFollow.btn
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        SafeFollow.btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    SafeFollow.btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = SafeFollow.btn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    SafeFollow.btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
    SafeFollow.btn.MouseButton1Click:Connect(function()
        SafeFollow.Locked = not SafeFollow.Locked
        if SafeFollow.Locked then SafeFollow.btn.Text = "LOCK: ON"; SafeFollow.btn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        else SafeFollow.btn.Text = "LOCK: OFF"; SafeFollow.btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32) end
    end)
end
local function getNearestPlayer(character, hrp)
    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then dist = d; nearest = p.Character end
        end
    end
    return nearest
end
local function startSafeFollow()
    if SafeFollow.heartbeatConn then SafeFollow.heartbeatConn:Disconnect() end
    SafeFollow.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not SafeFollow.Enabled then return end
        local character = lp.Character; if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        local nearest = getNearestPlayer(character, hrp); if not nearest then return end
        local trgHRP = nearest:FindFirstChild("HumanoidRootPart")
        local trgHum = nearest:FindFirstChild("Humanoid")
        if not trgHRP or not trgHum or trgHum.Health <= 0 then return end
        local dir = Vector3.new(trgHRP.Position.X - hrp.Position.X, 0, trgHRP.Position.Z - hrp.Position.Z)
        if dir.Magnitude > 0 then
            hum:MoveTo(trgHRP.Position)
            if Speed.Enabled then
                tigyApplyVelocity(hrp, dir, Speed.SpeedValue)
            end
        end
    end)
end
local function enableSafeFollow()
    if SafeFollow.Enabled then return end
    SafeFollow.Enabled = true
    if not SafeFollow.gui then createSafeFollowUI() end
    SafeFollow.gui.Enabled = true; SafeFollow.Locked = false
    if SafeFollow.btn then SafeFollow.btn.Text = "LOCK: OFF"; SafeFollow.btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32) end
    startSafeFollow()
    SafeFollow.charAddedConn = lp.CharacterAdded:Connect(function(c)
        local hum = c:WaitForChild("Humanoid", 5); if hum then hum.AutoRotate = true end
    end)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.AutoRotate = true end
end
local function disableSafeFollow()
    if not SafeFollow.Enabled then return end
    SafeFollow.Enabled = false; SafeFollow.Locked = false
    if SafeFollow.gui then SafeFollow.gui.Enabled = false end
    if SafeFollow.heartbeatConn then SafeFollow.heartbeatConn:Disconnect(); SafeFollow.heartbeatConn = nil end
    if SafeFollow.charAddedConn then SafeFollow.charAddedConn:Disconnect(); SafeFollow.charAddedConn = nil end
    SafeFollow.targetChar = nil
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.AutoRotate = true end
end

-------------------------------------------------------------------------
-- IMPROVED ANTI-RAGDOLL MODULE
-------------------------------------------------------------------------
local AntiRagdoll = {
    Enabled = false, RAGDOLL_SPEED = 16, currentCharacter = nil,
    ragdollRemoteConnection = nil, moveConnection = nil, playerModule = nil, controls = nil
}
pcall(function()
    AntiRagdoll.playerModule = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    AntiRagdoll.controls = AntiRagdoll.playerModule:GetControls()
end)
local function cleanupRagdoll()
    if AntiRagdoll.currentCharacter then
        local root = AntiRagdoll.currentCharacter:FindFirstChild("HumanoidRootPart")
        if root then local anchor = root:FindFirstChild("RagdollAnchor"); if anchor then anchor:Destroy() end end
    end
    if AntiRagdoll.moveConnection then AntiRagdoll.moveConnection:Disconnect(); AntiRagdoll.moveConnection = nil end
end
local function disconnectRemote()
    if AntiRagdoll.ragdollRemoteConnection then AntiRagdoll.ragdollRemoteConnection:Disconnect(); AntiRagdoll.ragdollRemoteConnection = nil end
end
local function setupAntiRagdoll(char)
    AntiRagdoll.currentCharacter = char; cleanupRagdoll(); disconnectRemote()
    local humanoid = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local head = char:WaitForChild("Head", 5)
    if not (humanoid and root and head) then return end
    local ragdollRemote = ReplicatedStorage:WaitForChild("Packages", 8):WaitForChild("Ragdoll", 5):WaitForChild("Ragdoll", 5)
    if not ragdollRemote or not ragdollRemote:IsA("RemoteEvent") then warn("[Anti-Ragdoll] Could not find Ragdoll remote"); return end
    AntiRagdoll.ragdollRemoteConnection = ragdollRemote.OnClientEvent:Connect(function(arg1, arg2)
        if not AntiRagdoll.Enabled then return end
        if arg1 == "Make" or arg2 == "manualM" then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            Workspace.CurrentCamera.CameraSubject = head; root.CanCollide = false
            if AntiRagdoll.controls then pcall(AntiRagdoll.controls.Enable, AntiRagdoll.controls) end
            cleanupRagdoll()
            local anchor = Instance.new("BodyPosition"); anchor.Name = "RagdollAnchor"
            anchor.MaxForce = Vector3.new(1e6, 1e6, 1e6); anchor.P = 5000; anchor.D = 1000
            anchor.Position = root.Position; anchor.Parent = root
            AntiRagdoll.moveConnection = RunService.RenderStepped:Connect(function()
                if not AntiRagdoll.Enabled or not anchor or not anchor.Parent then
                    if AntiRagdoll.moveConnection then AntiRagdoll.moveConnection:Disconnect(); AntiRagdoll.moveConnection = nil end
                    return
                end
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then anchor.Position = root.Position + moveDir.Unit * AntiRagdoll.RAGDOLL_SPEED
                else anchor.Position = root.Position end
            end)
        end
        if arg1 == "Destroy" or arg2 == "manualD" then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            Workspace.CurrentCamera.CameraSubject = humanoid; root.CanCollide = true
            if AntiRagdoll.controls then pcall(AntiRagdoll.controls.Enable, AntiRagdoll.controls) end
            cleanupRagdoll()
        end
    end)
end
lp.CharacterAdded:Connect(function(char) if AntiRagdoll.Enabled then setupAntiRagdoll(char) end end)
lp.CharacterRemoving:Connect(function() cleanupRagdoll(); disconnectRemote(); AntiRagdoll.currentCharacter = nil end)

-------------------------------------------------------------------------
-- ANTI TURRET
-------------------------------------------------------------------------
local AntiTurret = { Enabled = false, Target = nil, Conn = nil, Dist = 60, Pull = -5 }
local function getWeapon() return lp.Backpack:FindFirstChild("Bat") or (lp.Character and lp.Character:FindFirstChild("Bat")) end
local function findTurret()
    local char = lp.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local ownerId = obj.Name:match("Sentry_(%d+)")
            if ownerId and tonumber(ownerId) == lp.UserId then continue end
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and (char.HumanoidRootPart.Position - part.Position).Magnitude <= AntiTurret.Dist then return obj end
        end
    end
end

-------------------------------------------------------------------------
-- XRAY BASE MODULE
-------------------------------------------------------------------------
local XrayBase = { Enabled = false, OriginalTransparency = {}, Connections = {}, BaseKeywords = {"base", "claim"} }
local function isPlayerBase(obj)
    if not (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation")) then return false end
    local n = obj.Name:lower(); local p = obj.Parent and obj.Parent.Name:lower() or ""
    for _, keyword in ipairs(XrayBase.BaseKeywords) do if n:find(keyword) or p:find(keyword) then return true end end
    return false
end
local function applyTransparency(obj) if isPlayerBase(obj) then if not XrayBase.OriginalTransparency[obj] then XrayBase.OriginalTransparency[obj] = obj.LocalTransparencyModifier end; obj.LocalTransparencyModifier = 0.8 end end
local function restoreTransparency(obj) if XrayBase.OriginalTransparency[obj] then obj.LocalTransparencyModifier = XrayBase.OriginalTransparency[obj]; XrayBase.OriginalTransparency[obj] = nil end end
local function enableXrayBase()
    if XrayBase.Enabled then return end; XrayBase.Enabled = true
    for _, obj in ipairs(Workspace:GetDescendants()) do applyTransparency(obj) end
    XrayBase.Connections.descendantAdded = Workspace.DescendantAdded:Connect(function(obj) applyTransparency(obj) end)
    XrayBase.Connections.characterAdded = lp.CharacterAdded:Connect(function() task.wait(0.5); for _, obj in ipairs(Workspace:GetDescendants()) do applyTransparency(obj) end end)
end
local function disableXrayBase()
    if not XrayBase.Enabled then return end; XrayBase.Enabled = false
    for _, conn in pairs(XrayBase.Connections) do conn:Disconnect() end; XrayBase.Connections = {}
    for obj, original in pairs(XrayBase.OriginalTransparency) do obj.LocalTransparencyModifier = original end; XrayBase.OriginalTransparency = {}
end

-------------------------------------------------------------------------
-- NO ANIMATIONS MODULE
-------------------------------------------------------------------------
local NoAnim = { Enabled = false, CharacterConnections = {} }
local function disableAnims(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop() end
    if NoAnim.CharacterConnections[character] then NoAnim.CharacterConnections[character]:Disconnect() end
    NoAnim.CharacterConnections[character] = humanoid.AnimationPlayed:Connect(function(track) track:Stop() end)
end
local function enableNoAnim()
    if NoAnim.Enabled then return end; NoAnim.Enabled = true
    if lp.Character then disableAnims(lp.Character) end
    NoAnim.CharacterConnections.characterAdded = lp.CharacterAdded:Connect(function(char) disableAnims(char) end)
end
local function disableNoAnim()
    if not NoAnim.Enabled then return end; NoAnim.Enabled = false
    if NoAnim.CharacterConnections.characterAdded then NoAnim.CharacterConnections.characterAdded:Disconnect(); NoAnim.CharacterConnections.characterAdded = nil end
    for character, conn in pairs(NoAnim.CharacterConnections) do if character ~= "characterAdded" then conn:Disconnect(); NoAnim.CharacterConnections[character] = nil end end
    if lp.Character then local humanoid = lp.Character:FindFirstChildOfClass("Humanoid"); if humanoid then if NoAnim.CharacterConnections[lp.Character] then NoAnim.CharacterConnections[lp.Character]:Disconnect(); NoAnim.CharacterConnections[lp.Character] = nil end end end
end

-------------------------------------------------------------------------
-- PLAYER ESP MODULE
-------------------------------------------------------------------------
local PlayerESP = { Enabled = false, ESP_COLOR = Color3.fromRGB(220, 220, 220), Highlights = {}, Billboards = {}, Connections = {} }
local function createHighlight(character)
    local h = Instance.new("Highlight"); h.Name = "NimbusESP"; h.Adornee = character
    h.FillColor = PlayerESP.ESP_COLOR; h.FillTransparency = 0.25; h.OutlineColor = PlayerESP.ESP_COLOR
    h.OutlineTransparency = 0; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = CoreGui
    return h
end
local function createBillboard(character, player)
    local hrp = character:WaitForChild("HumanoidRootPart", 5); if not hrp then return nil end
    local bb = Instance.new("BillboardGui"); bb.Name = "NimbusESPName"; bb.Adornee = hrp
    bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 100, 0, 20); bb.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    bb.MaxDistance = 600; bb.Parent = CoreGui
    local bg = Instance.new("Frame", bb); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0); bg.BackgroundTransparency = 0.4
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    local txt = Instance.new("TextLabel", bg); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamSemibold; txt.TextSize = 13; txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0.2; txt.Text = player.DisplayName
    return bb
end
local function attachESP(player)
    if player == lp then return end
    local function apply(character)
        if PlayerESP.Highlights[player] then pcall(function() PlayerESP.Highlights[player]:Destroy() end) end
        if PlayerESP.Billboards[player] then pcall(function() PlayerESP.Billboards[player]:Destroy() end) end
        PlayerESP.Highlights[player] = createHighlight(character)
        PlayerESP.Billboards[player] = createBillboard(character, player)
    end
    if player.Character then apply(player.Character) end
    local conn = player.CharacterAdded:Connect(apply); table.insert(PlayerESP.Connections, conn)
end
local function removeESP(player)
    if PlayerESP.Highlights[player] then pcall(function() PlayerESP.Highlights[player]:Destroy() end); PlayerESP.Highlights[player] = nil end
    if PlayerESP.Billboards[player] then pcall(function() PlayerESP.Billboards[player]:Destroy() end); PlayerESP.Billboards[player] = nil end
end
local function enableESP()
    if PlayerESP.Enabled then return end; PlayerESP.Enabled = true
    for _, p in ipairs(Players:GetPlayers()) do attachESP(p) end
    table.insert(PlayerESP.Connections, Players.PlayerAdded:Connect(function(p) attachESP(p) end))
    table.insert(PlayerESP.Connections, Players.PlayerRemoving:Connect(function(p) removeESP(p) end))
end
local function disableESP()
    if not PlayerESP.Enabled then return end; PlayerESP.Enabled = false
    for _, h in pairs(PlayerESP.Highlights) do pcall(function() h:Destroy() end) end
    for _, b in pairs(PlayerESP.Billboards) do pcall(function() b:Destroy() end) end
    for _, c in ipairs(PlayerESP.Connections) do pcall(function() c:Disconnect() end) end
    PlayerESP.Highlights = {}; PlayerESP.Billboards = {}; PlayerESP.Connections = {}
end

-------------------------------------------------------------------------
-- INFINITE JUMP MODULE
-------------------------------------------------------------------------
local InfiniteJump = { Enabled = false, JUMP_POWER = 50, COOLDOWN = 0.15, lastJump = 0, JumpConnection = nil }
local function handleJumpRequest()
    if not InfiniteJump.Enabled then return end
    local character = lp.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if hrp and humanoid then
        if humanoid.FloorMaterial == Enum.Material.Air then
            local now = tick()
            if now - InfiniteJump.lastJump >= InfiniteJump.COOLDOWN then
                InfiniteJump.lastJump = now
                hrp.AssemblyLinearVelocity = Vector3.new(
                    hrp.AssemblyLinearVelocity.X,
                    InfiniteJump.JUMP_POWER,
                    hrp.AssemblyLinearVelocity.Z
                )
            end
        end
    end
end
local function enableInfJump() if InfiniteJump.Enabled then return end; InfiniteJump.Enabled = true; InfiniteJump.JumpConnection = UserInputService.JumpRequest:Connect(handleJumpRequest) end
local function disableInfJump() if not InfiniteJump.Enabled then return end; InfiniteJump.Enabled = false; if InfiniteJump.JumpConnection then InfiniteJump.JumpConnection:Disconnect(); InfiniteJump.JumpConnection = nil end end

-------------------------------------------------------------------------
-- MELEE AIMBOT MODULE
-------------------------------------------------------------------------
local Aimbot = {
    Enabled  = false,
    Running  = false,
    GuiOpen  = false,
    RANGE    = 70,
    SPEED    = 50,
    Conn     = nil,
    Attach   = nil,
    LinVel   = nil,
    Align    = nil,
    gui      = nil,
    btn      = nil,
}

local function getMeleeWeapon(char)
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
    end
    for _, t in ipairs(lp.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
    end
    return nil
end

local function getNearestEnemy(hrp)
    local nearest, dmin = nil, Aimbot.RANGE
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local eHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local eHum = p.Character:FindFirstChildOfClass("Humanoid")
            if eHRP and eHum and eHum.Health > 0 then
                local d = (eHRP.Position - hrp.Position).Magnitude
                if d < dmin then nearest = eHRP; dmin = d end
            end
        end
    end
    return nearest
end

local function startMeleeLogic()
    if Aimbot.Conn then return end
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    Aimbot.Attach = Instance.new("Attachment", hrp)

    Aimbot.LinVel = Instance.new("LinearVelocity", hrp)
    Aimbot.LinVel.Attachment0    = Aimbot.Attach
    Aimbot.LinVel.MaxForce       = 1e9
    Aimbot.LinVel.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    Aimbot.LinVel.MaxAxesForce   = Vector3.new(1e9, 1e9, 1e9)
    Aimbot.LinVel.RelativeTo     = Enum.ActuatorRelativeTo.World
    Aimbot.LinVel.VectorVelocity = Vector3.zero
    Aimbot.LinVel.Enabled        = false

    Aimbot.Align = Instance.new("AlignOrientation", hrp)
    Aimbot.Align.Attachment0    = Aimbot.Attach
    Aimbot.Align.MaxTorque      = math.huge
    Aimbot.Align.Responsiveness = 200
    Aimbot.Align.Enabled        = false

    local lockedTarget = nil

    Aimbot.Conn = RunService.Heartbeat:Connect(function()
        if not Aimbot.Running then return end
        char = lp.Character; if not char then return end
        hrp  = char:FindFirstChild("HumanoidRootPart")
        hum  = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if lockedTarget and lockedTarget.Parent then
            local tHum = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then lockedTarget = nil end
        else
            lockedTarget = nil
        end

        if not lockedTarget then
            lockedTarget = getNearestEnemy(hrp)
        end

        if not lockedTarget then
            Aimbot.LinVel.Enabled = false
            Aimbot.Align.Enabled  = false
            hum.AutoRotate = true
            return
        end

        hum.AutoRotate = false

        local targetFront = lockedTarget.Position + lockedTarget.CFrame.LookVector * 0.4

        local dir = targetFront - hrp.Position
        local spd = 58.76

        Aimbot.LinVel.Enabled        = true
        Aimbot.LinVel.MaxAxesForce   = Vector3.new(1e9, 1e9, 1e9)
        Aimbot.LinVel.VectorVelocity = dir.Magnitude > 0.1
            and Vector3.new(dir.Unit.X * spd, dir.Unit.Y * spd, dir.Unit.Z * spd)
            or  Vector3.new(0, 0, 0)

        hum.AutoRotate = false
        local targetFacePos = lockedTarget.Position + lockedTarget.CFrame.LookVector * 2
        local lookDir = Vector3.new(targetFacePos.X - hrp.Position.X, 0, targetFacePos.Z - hrp.Position.Z)
        if lookDir.Magnitude > 0.01 then
            Aimbot.Align.Enabled = true
            Aimbot.Align.CFrame  = CFrame.lookAt(hrp.Position, hrp.Position + lookDir)
        end

        local tool = getMeleeWeapon(char)
        if tool then
            if tool.Parent ~= char then hum:EquipTool(tool) end
            tool:Activate()
            local handle = tool:FindFirstChild("Handle")
            if handle then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                        if tHRP and (tHRP.Position - hrp.Position).Magnitude <= 8 then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    pcall(function() firetouchinterest(handle, part, 0) end)
                                    pcall(function() firetouchinterest(handle, part, 1) end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopMeleeLogic()
    Aimbot.Running = false
    if Aimbot.Conn   then Aimbot.Conn:Disconnect();  Aimbot.Conn   = nil end
    if Aimbot.LinVel then Aimbot.LinVel:Destroy();   Aimbot.LinVel = nil end
    if Aimbot.Align  then Aimbot.Align:Destroy();    Aimbot.Align  = nil end
    if Aimbot.Attach then Aimbot.Attach:Destroy();   Aimbot.Attach = nil end
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local function enableMeleeAimbot()
    Aimbot.Running = true
    startMeleeLogic()
end

local function disableMeleeAimbot()
    Aimbot.Running = false
    stopMeleeLogic()
end
-------------------------------------------------------------------------
-- OVAL BUTTON STACK (Nine Hub Style) - Float / Lock Target / Drop Brainrot
-------------------------------------------------------------------------
local OvalGui = Instance.new("ScreenGui")
OvalGui.Name = "NimbusOvalStack"
OvalGui.ResetOnSpawn = false
OvalGui.Enabled = false
OvalGui.Parent = CoreGui

local ovalWasDragged = false

local function attachOvalDrag(btn)
    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ovalWasDragged = false
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
            if delta.Magnitude > 5 then
                ovalWasDragged = true
                btn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Nine Hub style button creator
local function CreateOvalButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 165, 0, 37)
    btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    btn.BackgroundTransparency = 0.05
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 9)
    uiCorner.Parent = btn

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = NH.BORDER
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.2
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = btn

    local dot = Instance.new("Frame")
    dot.Name = "StatusDot"
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 9, 0.5, -3)
    dot.BackgroundColor3 = NH.DOT_OFF
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    dot.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = NH.TEXT
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local gear = Instance.new("TextLabel")
    gear.Size = UDim2.new(0, 16, 0, 16)
    gear.Position = UDim2.new(1, -22, 0.5, -8)
    gear.BackgroundTransparency = 1
    gear.Text = "⚙"
    gear.TextColor3 = Color3.fromRGB(40, 40, 40)
    gear.Font = Enum.Font.Gotham
    gear.TextSize = 13
    gear.Parent = btn

    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.Parent = OvalGui
    return btn
end

local function setNHButtonState(btn, isOn)
    pcall(function()
        btn.BackgroundColor3 = isOn and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(8, 8, 8)
        btn.BackgroundTransparency = 0
        local dot = btn:FindFirstChild("StatusDot")
        if dot then dot.BackgroundColor3 = isOn and NH.DOT_ON or NH.DOT_OFF end
    end)
end

local lockOvalBtn  = CreateOvalButton("Lock Target");   lockOvalBtn.Position  = UDim2.new(0.5, -252, 0, 78)
local dropOvalBtn  = CreateOvalButton("Drop Brainrot"); dropOvalBtn.Position  = UDim2.new(0.5, -82,  0, 78)
local floatOvalBtn = CreateOvalButton("Float");         floatOvalBtn.Position = UDim2.new(0.5,  88,  0, 78)
local tauntOvalBtn = CreateOvalButton("Taunt");         tauntOvalBtn.Position = UDim2.new(0.5, -167, 0, 120)
local spinOvalBtn  = CreateOvalButton("Spin Body");     spinOvalBtn.Position  = UDim2.new(0.5,   3,  0, 120)

task.defer(function()
    attachOvalDrag(lockOvalBtn)
    attachOvalDrag(dropOvalBtn)
    attachOvalDrag(tauntOvalBtn)
    attachOvalDrag(floatOvalBtn)
    attachOvalDrag(spinOvalBtn)
end)

local OvalBtnStates = { lock=false, drop=false, taunt=false, float=false, spin=false }

local function updateOvalVisibility()
    OvalGui.Enabled = OvalBtnStates.lock or OvalBtnStates.drop or OvalBtnStates.taunt or OvalBtnStates.float or OvalBtnStates.spin
end

local function showOvalBtn(btn)
    pcall(function()
        btn.BackgroundTransparency = 0.15
        btn.Active = true
        local lbl = btn:FindFirstChild("Label")
        if lbl then lbl.TextTransparency = 0 end
        local dot = btn:FindFirstChild("StatusDot")
        if dot then dot.BackgroundTransparency = 0 end
        for _, c in ipairs(btn:GetChildren()) do
            if c:IsA("UIStroke") then c.Transparency = 0.2 end
        end
    end)
end

local function hideOvalBtn(btn)
    pcall(function()
        btn.BackgroundTransparency = 1
        btn.Active = false
        local lbl = btn:FindFirstChild("Label")
        if lbl then lbl.TextTransparency = 1 end
        local dot = btn:FindFirstChild("StatusDot")
        if dot then dot.BackgroundTransparency = 1 end
        for _, c in ipairs(btn:GetChildren()) do
            if c:IsA("UIStroke") then c.Transparency = 1 end
        end
    end)
end

task.defer(function()
    hideOvalBtn(lockOvalBtn)
    hideOvalBtn(dropOvalBtn)
    hideOvalBtn(tauntOvalBtn)
    hideOvalBtn(floatOvalBtn)
    hideOvalBtn(spinOvalBtn)
end)

local LockTarget = { Enabled = false }

lockOvalBtn.MouseButton1Click:Connect(function()
    if ovalWasDragged then ovalWasDragged = false; return end
    Aimbot.Running = not Aimbot.Running
    setNHButtonState(lockOvalBtn, Aimbot.Running)
    local lbl = lockOvalBtn:FindFirstChild("Label")
    if lbl then lbl.Text = Aimbot.Running and "Lock Target [ON]" or "Lock Target" end
    if Aimbot.Running then startMeleeLogic() else stopMeleeLogic() end
end)

local function enableLockTarget()
    if LockTarget.Enabled then return end
    LockTarget.Enabled = true
    showOvalBtn(lockOvalBtn)
    OvalBtnStates.lock = true
    setNHButtonState(lockOvalBtn, false)
    local lbl = lockOvalBtn:FindFirstChild("Label")
    if lbl then lbl.Text = "Lock Target" end
    Aimbot.Running = false
    updateOvalVisibility()
end

local function disableLockTarget()
    if not LockTarget.Enabled then return end
    LockTarget.Enabled = false
    Aimbot.Running = false
    stopMeleeLogic()
    hideOvalBtn(lockOvalBtn)
    OvalBtnStates.lock = false
    updateOvalVisibility()
end

AddToggle("Combat", "Lock Target", false, function(v)
    if v then enableLockTarget() else disableLockTarget() end
end)

-------------------------------------------------------------------------
-- AUTO GRAB MODULE (v4 steal engine)
-------------------------------------------------------------------------
local Grab_Enabled        = false
local Grab_RADIUS         = 3.1
local Grab_STEAL_DURATION = 0.1
local Grab_STEAL_GPS      = -1
local Grab_isStealing     = false
local Grab_stealStartTime = nil
local Grab_StealProgress  = 0
local Grab_StealData      = {}
local Grab_loopThread     = nil
local Grab_Gui            = nil
local Grab_pctLabel       = nil
local Grab_progressConn   = nil

local function agGetHRP()
    local c = lp.Character
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso"))
end
local function agIsMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots"); local plot = plots and plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then local yb = sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end
local function agIsGrabPrompt(p)
    if not p or not p:IsA("ProximityPrompt") then return false end
    return ((p.ObjectText or ""):lower():find("steal")) or ((p.ActionText or ""):lower():find("steal"))
end
local function agFindNearestPrompt()
    local myHRP = agGetHRP(); if not myHRP then return nil, nil end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil, nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if agIsMyBase(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local podPart = pod:IsA("BasePart") and pod
                    or pod:FindFirstChildWhichIsA("BasePart")
                    or (pod:IsA("Model") and pod.PrimaryPart)
                if not podPart then
                    local base = pod:FindFirstChild("Base")
                    podPart = base and base:FindFirstChild("Spawn")
                end
                if podPart then
                    local dist = (podPart.Position - myHRP.Position).Magnitude
                    if dist < nd and dist <= Grab_RADIUS then
                        for _, desc in ipairs(pod:GetDescendants()) do
                            if agIsGrabPrompt(desc) and desc.Enabled then
                                np, nd, nn = desc, dist, pod.Name
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nn
end
local function agBuildCallbacks(prompt)
    if Grab_StealData[prompt] then return Grab_StealData[prompt] end
    local data = { hold = {}, trigger = {}, ready = true }
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(data.hold, c.Function) end end
            for _, c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(data.trigger, c.Function) end end
        end
    end)
    Grab_StealData[prompt] = data; return data
end
local function agResetProgressBar() Grab_StealProgress = 0; if Grab_pctLabel then Grab_pctLabel.Text = "0%" end end
local function agExecuteSteal(prompt, name)
    if Grab_isStealing then return end
    local data = agBuildCallbacks(prompt); if not data.ready then return end
    data.ready = false; Grab_isStealing = true; Grab_stealStartTime = tick(); Grab_StealProgress = 0
    if Grab_progressConn then Grab_progressConn:Disconnect() end
    Grab_progressConn = RunService.Heartbeat:Connect(function()
        if not Grab_isStealing then Grab_progressConn:Disconnect(); return end
        local prog = math.clamp((tick() - Grab_stealStartTime) / Grab_STEAL_DURATION, 0, 1)
        Grab_StealProgress = prog * 100
    end)
    task.spawn(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local savedAnchor = nil
        if root then
            savedAnchor = root:FindFirstChild("RagdollAnchor")
            if savedAnchor then savedAnchor.MaxForce = Vector3.new(0, 0, 0) end
        end
        for _, fn in ipairs(data.hold) do task.spawn(fn) end
        local elapsed = 0; while elapsed < Grab_STEAL_DURATION do elapsed = elapsed + task.wait() end
        for _, fn in ipairs(data.trigger) do task.spawn(fn) end
        if savedAnchor and savedAnchor.Parent then
            savedAnchor.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        end
        if Grab_progressConn then Grab_progressConn:Disconnect() end
        Grab_StealProgress = 100
        task.wait(0.3); agResetProgressBar()
        data.ready = true; Grab_isStealing = false
    end)
end
local function agLoop()
    while Grab_Enabled do
        if Grab_STEAL_GPS > 0 then
            task.wait(1 / Grab_STEAL_GPS)
        else
            task.wait()
        end
        if not Grab_isStealing then
            local prompt, name = agFindNearestPrompt()
            if prompt and prompt.Enabled then agExecuteSteal(prompt, name) end
        end
    end
end
local function agCreateGui()
    if Grab_Gui then Grab_Gui:Destroy() end
    local sg = Instance.new("ScreenGui"); sg.Name = "NimbusSteal"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999; sg.Parent = CoreGui

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 420, 0, 36)
    bar.Position = UDim2.new(0.5, -210, 0, 8)
    bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bar.BackgroundTransparency = 0.15
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.Parent = sg
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = bar
    local bs = Instance.new("UIStroke"); bs.Color = Color3.fromRGB(220, 220, 220); bs.Thickness = 1.5; bs.Transparency = 0.4; bs.Parent = bar

    local function makeDivider(xPos)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, 1, 0, 20); d.Position = UDim2.new(0, xPos, 0.5, -10)
        d.BackgroundColor3 = Color3.fromRGB(40, 40, 40); d.BorderSizePixel = 0; d.Parent = bar
    end

    local function makeLabel(text, xPos, width, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, width, 1, 0); lbl.Position = UDim2.new(0, xPos, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = text
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
        lbl.TextColor3 = color or Color3.fromRGB(160, 160, 160)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = bar
        return lbl
    end

    makeLabel("drΛk Grab", 10, 100, Color3.fromRGB(255, 255, 255))
    makeDivider(114)
    makeLabel("FPS", 122, 30, Color3.fromRGB(160, 160, 160))
    local fpsVal = makeLabel("0", 154, 36, Color3.fromRGB(255, 255, 255))
    makeDivider(194)
    makeLabel("PING", 202, 36, Color3.fromRGB(160, 160, 160))
    local pingVal = makeLabel("0ms", 240, 46, Color3.fromRGB(255, 255, 255))
    makeDivider(290)

    local radTitleLbl = Instance.new("TextLabel")
    radTitleLbl.Size = UDim2.new(0, 64, 1, 0); radTitleLbl.Position = UDim2.new(0, 300, 0, 0)
    radTitleLbl.BackgroundTransparency = 1; radTitleLbl.Text = "RADIUS"
    radTitleLbl.Font = Enum.Font.GothamBold; radTitleLbl.TextSize = 14
    radTitleLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    radTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; radTitleLbl.Parent = bar

    local radInputFrame = Instance.new("Frame")
    radInputFrame.Size = UDim2.new(0, 46, 0, 26); radInputFrame.Position = UDim2.new(0, 366, 0.5, -13)
    radInputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); radInputFrame.BorderSizePixel = 0; radInputFrame.Parent = bar
    local ric = Instance.new("UICorner"); ric.CornerRadius = UDim.new(0, 6); ric.Parent = radInputFrame
    local ris = Instance.new("UIStroke"); ris.Color = Color3.fromRGB(200, 200, 200); ris.Thickness = 1.2; ris.Transparency = 0.4; ris.Parent = radInputFrame
    local radBox = Instance.new("TextBox"); radBox.Size = UDim2.new(1, -4, 1, 0); radBox.Position = UDim2.new(0, 2, 0, 0)
    radBox.BackgroundTransparency = 1; radBox.Text = tostring(Grab_RADIUS); radBox.Font = Enum.Font.GothamBold; radBox.TextSize = 14
    radBox.TextColor3 = Color3.fromRGB(255, 255, 255); radBox.TextXAlignment = Enum.TextXAlignment.Center; radBox.ClearTextOnFocus = false; radBox.Parent = radInputFrame
    radBox.Focused:Connect(function() ris.Transparency = 0 end)
    radBox.FocusLost:Connect(function()
        ris.Transparency = 0.4
        local n = tonumber(radBox.Text)
        if n and n > 0 then Grab_RADIUS = n; radBox.Text = tostring(n)
        else radBox.Text = tostring(Grab_RADIUS) end
    end)

    local progressRow = Instance.new("Frame")
    progressRow.Size = UDim2.new(0, 420, 0, 22)
    progressRow.Position = UDim2.new(0.5, -210, 0, 48)
    progressRow.BackgroundTransparency = 1
    progressRow.BorderSizePixel = 0
    progressRow.Parent = sg

    local stealRowLbl = Instance.new("TextLabel")
    stealRowLbl.Size = UDim2.new(0, 52, 1, 0); stealRowLbl.Position = UDim2.new(0, 0, 0, 0)
    stealRowLbl.BackgroundTransparency = 1; stealRowLbl.Text = "STEAL"
    stealRowLbl.Font = Enum.Font.GothamBold; stealRowLbl.TextSize = 13
    stealRowLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    stealRowLbl.TextXAlignment = Enum.TextXAlignment.Left; stealRowLbl.Parent = progressRow

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 362, 1, 0)
    progressBg.Position = UDim2.new(0, 56, 0, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = progressRow
    local pgbc = Instance.new("UICorner"); pgbc.CornerRadius = UDim.new(1, 0); pgbc.Parent = progressBg
    local pgs = Instance.new("UIStroke"); pgs.Color = Color3.fromRGB(32, 32, 32); pgs.Thickness = 1; pgs.Parent = progressBg

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBg
    local pgfc = Instance.new("UICorner"); pgfc.CornerRadius = UDim.new(1, 0); pgfc.Parent = progressFill

    Grab_pctLabel = Instance.new("TextLabel")
    Grab_pctLabel.Visible = false; Grab_pctLabel.Parent = sg
    local dragging, dragStart, startPos
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = Vector2.new(input.Position.X, input.Position.Y); startPos = bar.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
            local nx = startPos.X.Scale; local nxo = startPos.X.Offset + delta.X
            local ny = startPos.Y.Scale; local nyo = startPos.Y.Offset + delta.Y
            bar.Position = UDim2.new(nx, nxo, ny, nyo)
            progressRow.Position = UDim2.new(nx, nxo, ny, nyo + 44)
        end
    end)

    local frameCount, lastFPSTime, currentFPS = 0, tick(), 0
    task.spawn(function()
        while sg and sg.Parent do
            task.wait(0.05)
            frameCount = frameCount + 1
            local now = tick()
            if now - lastFPSTime >= 0.5 then
                currentFPS = math.floor(frameCount / (now - lastFPSTime))
                frameCount = 0; lastFPSTime = now
            end
            fpsVal.Text = tostring(currentFPS)
            local ok, ms = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            pingVal.Text = (ok and tostring(ms) or "?") .. "ms"
            local pct = math.clamp(Grab_StealProgress / 100, 0, 1)
            progressFill.Size = UDim2.new(pct, 0, 1, 0)
            if radBox and not radBox:IsFocused() then radBox.Text = tostring(Grab_RADIUS) end
        end
    end)
    Grab_Gui = sg
end

-- Lag Guard
local LagGuard = {
    Conn = nil,
    IsFrozen = false,
    LastPosition = nil,
    FREEZE_TIME = 0.03,
    STEAL_THRESHOLD = 10,
    RUN_THRESHOLD = 23,
    _users = 0,
}
local function lagGuardStart()
    LagGuard._users = LagGuard._users + 1
    if LagGuard.Conn then return end
    LagGuard.IsFrozen = false
    LagGuard.LastPosition = nil
    LagGuard.Conn = RunService.Heartbeat:Connect(function()
        if LagGuard.IsFrozen then return end
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local currentPos = root.Position
            if LagGuard.LastPosition then
                local currentSpeed = root.AssemblyLinearVelocity.Magnitude
                local dynamicThreshold = LagGuard.STEAL_THRESHOLD
                if currentSpeed > 65 then
                    dynamicThreshold = LagGuard.RUN_THRESHOLD
                elseif currentSpeed > 40 then
                    dynamicThreshold = 15
                end
                local distance = (currentPos - LagGuard.LastPosition).Magnitude
                if distance > dynamicThreshold then
                    LagGuard.IsFrozen = true
                    root.Anchored = true
                    local parts = {}
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then parts[v] = v.Color; v.Color = Color3.fromRGB(255, 0, 0) end
                    end
                    task.delay(LagGuard.FREEZE_TIME, function()
                        if root then root.Anchored = false end
                        LagGuard.IsFrozen = false
                        for part, color in pairs(parts) do
                            if part and part.Parent then part.Color = color end
                        end
                    end)
                end
            end
            LagGuard.LastPosition = currentPos
        else
            LagGuard.LastPosition = nil
        end
    end)
end
local function lagGuardStop()
    LagGuard._users = math.max(0, LagGuard._users - 1)
    if LagGuard._users > 0 then return end
    if LagGuard.Conn then LagGuard.Conn:Disconnect(); LagGuard.Conn = nil end
    LagGuard.IsFrozen = false; LagGuard.LastPosition = nil
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = false end
end

local function enableAutoGrab() if Grab_Enabled then return end; Grab_Enabled = true; agCreateGui(); Grab_loopThread = task.spawn(agLoop); lagGuardStart() end
local function disableAutoGrab()
    if not Grab_Enabled then return end; Grab_Enabled = false; Grab_isStealing = false; agResetProgressBar(); Grab_loopThread = nil; lagGuardStop()
    if Grab_progressConn then Grab_progressConn:Disconnect(); Grab_progressConn = nil end
    if Grab_Gui then Grab_Gui:Destroy(); Grab_Gui = nil end; Grab_pctLabel = nil; Grab_StealData = {}
end
AddToggle("Combat", "Auto Grab", false, function(v) if v then enableAutoGrab() else disableAutoGrab() end end)

-------------------------------------------------------------------------
-- AUTO WALK MODULE
-------------------------------------------------------------------------
local AutoWalk = {
    Enabled = false, SelectedSide = nil, WalkConn = nil, PickerGui = nil,
    DESTINATIONS = {
        Right = Vector3.new(-421.60, -7.69, 59.23),
        Left  = Vector3.new(-421.60, -7.69, 59.23),
    }
}
local function destroyAutoWalkPicker() if AutoWalk.PickerGui then AutoWalk.PickerGui:Destroy(); AutoWalk.PickerGui = nil end end
local function stopAutoWalk()
    AutoWalk.Enabled = false
    if AutoWalk.WalkConn then AutoWalk.WalkConn:Disconnect(); AutoWalk.WalkConn = nil end
    destroyAutoWalkPicker(); AutoWalk.SelectedSide = nil
    local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:MoveTo(char.HumanoidRootPart.Position) end
end
local function startAutoWalk(side)
    AutoWalk.SelectedSide = side; destroyAutoWalkPicker()
    local dest = AutoWalk.DESTINATIONS[side]
    AutoWalk.WalkConn = RunService.Heartbeat:Connect(function()
        if not AutoWalk.Enabled then return end
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        local dist = (hrp.Position - dest).Magnitude
        if dist > 4 then
            hum:MoveTo(dest)
            if Speed.Enabled then
                local dir = (dest - hrp.Position)
                tigyApplyVelocity(hrp, dir, Speed.SpeedValue)
            end
        else
            hum:MoveTo(hrp.Position); AutoWalk.WalkConn:Disconnect(); AutoWalk.WalkConn = nil
        end
    end)
end
local function showAutoWalkPicker(onClose)
    destroyAutoWalkPicker()
    local sg = Instance.new("ScreenGui"); sg.Name = "NimbusWalk"; sg.ResetOnSpawn = false; sg.Parent = CoreGui
    AutoWalk.PickerGui = sg
    local frame = create("Frame", {
        Size = UDim2.new(0, 240, 0, 130), Position = UDim2.new(0.5, -120, 0.5, -65),
        BackgroundColor3 = Color3.fromRGB(6, 6, 8), BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = frame})
    create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Parent = frame})
    create("TextLabel", {Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = "Left or Right?", TextColor3 = Color3.fromRGB(255, 255, 255), Font = "GothamBold", TextSize = 15, Parent = frame})
    local leftBtn = create("TextButton", {Size = UDim2.new(0.42, 0, 0, 40), Position = UDim2.new(0.05, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Text = "LEFT", TextColor3 = Color3.fromRGB(255, 255, 255), Font = "GothamBold", TextSize = 14, Parent = frame})
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = leftBtn}); create("UIStroke", {Color = Color3.fromRGB(220, 220, 220), Thickness = 1.5, Parent = leftBtn})
    local rightBtn = create("TextButton", {Size = UDim2.new(0.42, 0, 0, 40), Position = UDim2.new(0.53, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Text = "RIGHT", TextColor3 = Color3.fromRGB(255, 255, 255), Font = "GothamBold", TextSize = 14, Parent = frame})
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = rightBtn}); create("UIStroke", {Color = Color3.fromRGB(220, 220, 220), Thickness = 1.5, Parent = rightBtn})
    local cancelBtn = create("TextButton", {Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, 97), BackgroundTransparency = 1, Text = "Cancel", TextColor3 = Color3.fromRGB(52, 52, 52), Font = "Gotham", TextSize = 12, Parent = frame})
    leftBtn.MouseButton1Click:Connect(function() startAutoWalk("Left") end)
    rightBtn.MouseButton1Click:Connect(function() startAutoWalk("Right") end)
    cancelBtn.MouseButton1Click:Connect(function() destroyAutoWalkPicker(); onClose() end)
end
AddToggle("Combat", "Auto Walk", false, function(v)
    if v then AutoWalk.Enabled = true; showAutoWalkPicker(function() AutoWalk.Enabled = false end)
    else stopAutoWalk() end
end)

-------------------------------------------------------------------------
-- AUTO PLAY MODULE
-------------------------------------------------------------------------
local AutoPlay = {
    Running = false, Side = "Left", Zone1Speed = 55.3, Zone2Speed = 27.2,
    StartDelay = 0, ZoneStop = 0.1, Thread = nil, Gui = nil, _apPaused = false,
}
local AP_WAYPOINTS = {
    Left = {
        { pos = Vector3.new(-475.00, -7.69, 97.55),  zone = 1 },
        { pos = Vector3.new(-487.88, -5.44, 97.51),  zone = 2, stop = true },
        { pos = Vector3.new(-475.00, -7.69, 97.55),  zone = "ramp" },
        { pos = Vector3.new(-474.85, -7.69, 23.81),  zone = 2 },
        { pos = Vector3.new(-487.75, -5.49, 23.28),  zone = 2 },
    },
    Right = {
        { pos = Vector3.new(-474.85, -7.69, 23.81),  zone = 1 },
        { pos = Vector3.new(-487.75, -5.49, 23.28),  zone = 2, stop = true },
        { pos = Vector3.new(-474.85, -7.69, 23.81),  zone = "ramp" },
        { pos = Vector3.new(-475.00, -7.69, 97.55),  zone = 2 },
        { pos = Vector3.new(-475.00, -7.69, 97.55),  zone = 2 },
    },
}

local function apMoveToWaypoint(hrp, hum, dest, zone)
    if zone == 1 then
        AutoPlay._apPaused = true
    else
        AutoPlay._apPaused = false
    end
    local totalDist = Vector3.new(dest.X - hrp.Position.X, 0, dest.Z - hrp.Position.Z).Magnitude
    local moveAlive = true
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not AutoPlay.Running then conn:Disconnect(); return end
        local dir = Vector3.new(dest.X - hrp.Position.X, 0, dest.Z - hrp.Position.Z)
        if dir.Magnitude > 3 then
            local spd
            if zone == "ramp" then
                local progress = math.clamp(1 - (dir.Magnitude / math.max(totalDist, 1)), 0, 1)
                spd = 26.5 + (AutoPlay.Zone2Speed - 26.5) * progress
            elseif zone == 2 then
                spd = AutoPlay.Zone2Speed
            else
                spd = Speed.Enabled
                    and math.max(AutoPlay.Zone1Speed, Speed.SpeedValue)
                    or  AutoPlay.Zone1Speed
            end
            tigyApplyVelocity(hrp, dir, spd)
        else
            conn:Disconnect()
        end
    end)
    while AutoPlay.Running do
        task.wait(0.05)
        if (hrp.Position - dest).Magnitude <= 2.5 then break end
    end
    moveAlive = false
    if conn.Connected then conn:Disconnect() end
end

local function startAutoPlayLoop()
    if AutoPlay.Thread then task.cancel(AutoPlay.Thread) end
    AutoPlay.Thread = task.spawn(function()
        if AutoPlay.StartDelay > 0 then task.wait(AutoPlay.StartDelay) end
        while AutoPlay.Running do
            local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then task.wait(0.5); continue end
            local waypoints = AP_WAYPOINTS[AutoPlay.Side]
            for _, wp in ipairs(waypoints) do
                if not AutoPlay.Running then break end
                apMoveToWaypoint(hrp, hum, wp.pos, wp.zone)
                if wp.stop and AutoPlay.Running then hum:MoveTo(hrp.Position); task.wait(AutoPlay.ZoneStop) end
            end
        end
    end)
end
local function stopAutoPlay()
    AutoPlay.Running = false
    if AutoPlay.Thread then task.cancel(AutoPlay.Thread); AutoPlay.Thread = nil end
    AutoPlay._apPaused = false
    local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then hum:MoveTo(hrp.Position) end
end
local function destroyAutoPlayGui() if AutoPlay.Gui and AutoPlay.Gui.Parent then AutoPlay.Gui:Destroy(); AutoPlay.Gui = nil end end
local function showAutoPlayGui(onToggleOff)
    destroyAutoPlayGui()
    local sg = Instance.new("ScreenGui"); sg.Name = "NimbusAutoPlay"; sg.ResetOnSpawn = false; sg.Parent = CoreGui
    AutoPlay.Gui = sg

    local collapsed = false
    local FULL_HEIGHT = 308
    local COLLAPSED_HEIGHT = 36

    local frame = create("Frame", {
        Size = UDim2.new(0, 220, 0, FULL_HEIGHT), Position = UDim2.new(1, -230, 1, -318),
        BackgroundColor3 = Color3.fromRGB(5, 5, 5), BackgroundTransparency = 0,
        BorderSizePixel = 0, Active = true, Draggable = true, Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = frame})
    create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1.5, Parent = frame})

    local titleBar = create("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = frame})
    create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1,
        Text = "Auto Play", TextColor3 = Color3.fromRGB(255, 255, 255), Font = "GothamBold", TextSize = 15,
        TextXAlignment = "Left", Parent = titleBar
    })

    local dropBtn = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30), Text = "▼",
        TextColor3 = Color3.fromRGB(180, 180, 180), Font = "GothamBold", TextSize = 12,
        AutoButtonColor = false, Parent = titleBar
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = dropBtn})

    local body = create("Frame", {
        Size = UDim2.new(1, 0, 1, -36), Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1, BorderSizePixel = 0, Parent = frame
    })

    local playBtn = create("TextButton", {
        Size = UDim2.new(1, -24, 0, 42), Position = UDim2.new(0, 12, 0, 4),
        BackgroundColor3 = Color3.fromRGB(34, 197, 60), Text = "PLAY",
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = "GothamBold", TextSize = 18,
        AutoButtonColor = false, Parent = body
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = playBtn})
    create("Frame", {Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0, 56), BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0, Parent = body})

    local selectorBg = create("Frame", {Size = UDim2.new(1, -24, 0, 36), Position = UDim2.new(0, 12, 0, 65), BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, Parent = body})
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = selectorBg}); create("UIStroke", {Color = Color3.fromRGB(22, 22, 22), Thickness = 1, Parent = selectorBg})
    local leftSel = create("TextButton", {Size = UDim2.new(0.5, -2, 1, -4), Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Text = "LEFT", TextColor3 = Color3.fromRGB(0, 0, 0), Font = "GothamBold", TextSize = 13, AutoButtonColor = false, Parent = selectorBg})
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = leftSel})
    local rightSel = create("TextButton", {Size = UDim2.new(0.5, -2, 1, -4), Position = UDim2.new(0.5, 0, 0, 2), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Text = "RIGHT", TextColor3 = Color3.fromRGB(48, 48, 48), Font = "GothamBold", TextSize = 13, AutoButtonColor = false, Parent = selectorBg})
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = rightSel})

    local function selectSide(side)
        AutoPlay.Side = side
        leftSel.BackgroundColor3  = side == "Left"  and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,25,25)
        leftSel.TextColor3        = side == "Left"  and Color3.fromRGB(0,0,0)       or Color3.fromRGB(48, 48, 48)
        rightSel.BackgroundColor3 = side == "Right" and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,25,25)
        rightSel.TextColor3       = side == "Right" and Color3.fromRGB(0,0,0)       or Color3.fromRGB(48, 48, 48)
    end
    leftSel.MouseButton1Click:Connect(function() selectSide("Left") end)
    rightSel.MouseButton1Click:Connect(function() selectSide("Right") end)
    selectSide("Left")

    create("Frame", {Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0, 111), BackgroundColor3 = Color3.fromRGB(40, 40, 40), BorderSizePixel = 0, Parent = body})

    local function makeRow(label, getValue, setValue, yPos, suffix)
        suffix = suffix or ""
        create("TextLabel", {Size = UDim2.new(0.5, 0, 0, 30), Position = UDim2.new(0, 14, 0, yPos), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(200, 200, 200), Font = "Gotham", TextSize = 13, TextXAlignment = "Left", Parent = body})
        local boxFrame = create("Frame", {Size = UDim2.new(0, 76, 0, 30), Position = UDim2.new(1, -90, 0, yPos), BackgroundColor3 = Color3.fromRGB(5, 5, 5), BorderSizePixel = 0, Parent = body})
        create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = boxFrame})
        local rowStroke = create("UIStroke", {Color = Color3.fromRGB(24, 24, 24), Thickness = 1.5, Parent = boxFrame})
        local box = create("TextBox", {Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Text = tostring(getValue()) .. suffix, TextColor3 = Color3.fromRGB(255, 255, 255), Font = "GothamBold", TextSize = 13, ClearTextOnFocus = true, Parent = boxFrame})
        box.Focused:Connect(function() rowStroke.Color = Color3.fromRGB(180, 180, 180) end)
        box.FocusLost:Connect(function()
            rowStroke.Color = Color3.fromRGB(24, 24, 24)
            local n = tonumber(box.Text); if n then setValue(n); box.Text = tostring(n) .. suffix else box.Text = tostring(getValue()) .. suffix end
        end)
    end
    makeRow("Zone 1",      function() return AutoPlay.Zone1Speed end, function(v) AutoPlay.Zone1Speed = v end, 120)
    makeRow("Zone 2",      function() return AutoPlay.Zone2Speed end, function(v) AutoPlay.Zone2Speed = v end, 156)
    makeRow("Start Delay", function() return AutoPlay.StartDelay end, function(v) AutoPlay.StartDelay = v end, 192, "s")
    makeRow("Zone Stop",   function() return AutoPlay.ZoneStop   end, function(v) AutoPlay.ZoneStop   = v end, 228, "s")

    dropBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        if collapsed then
            body.Visible = false
            frame.Size = UDim2.new(0, 220, 0, COLLAPSED_HEIGHT)
            dropBtn.Text = "▶"
        else
            body.Visible = true
            frame.Size = UDim2.new(0, 220, 0, FULL_HEIGHT)
            dropBtn.Text = "▼"
        end
    end)
    playBtn.MouseButton1Click:Connect(function()
        if AutoPlay.Running then
            stopAutoPlay(); playBtn.Text = "PLAY"; playBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 60)
            local vis = ToggleVisuals["Auto Play"]; if vis then vis(false) end
        else
            AutoPlay.Running = true; playBtn.Text = "STOP"; playBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            local vis = ToggleVisuals["Auto Play"]; if vis then vis(true) end
            startAutoPlayLoop()
        end
    end)
    if AutoPlay.Running then playBtn.Text = "STOP"; playBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) end
    sg.AncestryChanged:Connect(function()
        if not sg.Parent then
            stopAutoPlay()
            if onToggleOff then onToggleOff() end
        end
    end)
end
AddToggle("Combat", "Auto Play", false, function(v)
    if v then
        showAutoPlayGui(function()
            AutoPlay.Running = false
            local vis = ToggleVisuals["Auto Play"]; if vis then vis(false) end
        end)
    else
        stopAutoPlay(); destroyAutoPlayGui()
        local vis = ToggleVisuals["Auto Play"]; if vis then vis(false) end
    end
end)

-------------------------------------------------------------------------
-- AUTO CORRECT MODULE
-------------------------------------------------------------------------
local AutoCorrect = {
    Enabled = false, Conn = nil, THRESHOLD = 8, CORRECT_SPEED = 30,
    _prevPos = nil, _frozenUntil = 0, LAGBACK_THRESHOLD = 12, FREEZE_DURATION = 3,
}
local AP_PATH_LEFT = {
    Vector3.new(-475.00, -7.69, 97.55),
    Vector3.new(-487.88, -5.44, 97.51),
    Vector3.new(-474.85, -7.69, 23.81),
    Vector3.new(-487.75, -5.49, 23.28),
}
local AP_PATH_RIGHT = {
    Vector3.new(-474.85, -7.69, 23.81),
    Vector3.new(-487.75, -5.49, 23.28),
    Vector3.new(-475.00, -7.69, 97.55),
}
local function acGetNearestPathPoint(hrp, path)
    local nearest, dist = nil, math.huge
    for _, pt in ipairs(path) do
        local d = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(pt.X, 0, pt.Z)).Magnitude
        if d < dist then dist = d; nearest = pt end
    end
    return nearest, dist
end
local function enableAutoCorrect()
    if AutoCorrect.Enabled then return end; AutoCorrect.Enabled = true
    AutoCorrect._prevPos = nil; AutoCorrect._frozenUntil = 0
    lagGuardStart()
    AutoCorrect.Conn = RunService.Heartbeat:Connect(function()
        if not AutoCorrect.Enabled then return end; if not AutoPlay.Running then return end
        if AutoPlay._apPaused then return end
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then AutoCorrect._prevPos = nil; return end
        local now = tick(); local currentPos = hrp.Position
        if AutoCorrect._prevPos then
            local delta = Vector3.new(currentPos.X - AutoCorrect._prevPos.X, 0, currentPos.Z - AutoCorrect._prevPos.Z).Magnitude
            if delta > AutoCorrect.LAGBACK_THRESHOLD then AutoCorrect._frozenUntil = now + AutoCorrect.FREEZE_DURATION end
        end
        AutoCorrect._prevPos = currentPos
        if now < AutoCorrect._frozenUntil then
            tigyApplyVelocity(hrp, Vector3.zero, 0)
            return
        end
        local path = AutoPlay.Side == "Left" and AP_PATH_LEFT or AP_PATH_RIGHT
        local nearest, dist = acGetNearestPathPoint(hrp, path)
        if nearest and dist > AutoCorrect.THRESHOLD then
            local dir = Vector3.new(nearest.X - currentPos.X, 0, nearest.Z - currentPos.Z)
            tigyApplyVelocity(hrp, dir, AutoCorrect.CORRECT_SPEED)
        end
    end)
end
local function disableAutoCorrect()
    AutoCorrect.Enabled = false; AutoCorrect._prevPos = nil; AutoCorrect._frozenUntil = 0
    if AutoCorrect.Conn then AutoCorrect.Conn:Disconnect(); AutoCorrect.Conn = nil end
    lagGuardStop()
end
AddToggle("Combat", "Auto Correct", false, function(v) if v then enableAutoCorrect() else disableAutoCorrect() end end)

-------------------------------------------------------------------------
-- AUTO TP MODULE
-------------------------------------------------------------------------
local AutoTP = {
    Enabled = false, Side = "Left", Gui = nil, RagdollConn = nil, StateConn = nil, GrabRagConn = nil,
    CHECKPOINT = Vector3.new(-424.16, -7.69, 57.49),
    FINAL = {
        Left  = Vector3.new(-487.89, -5.42, 97.74),
        Right = Vector3.new(-487.69, -5.32, 23.53)
    },
    GRAB_RAG = {
        Left  = Vector3.new(-442.55, -7.30, 83.93),
        Right = Vector3.new(-446.64, -7.30, 37.51)
    },
}
local function atpMove(pos)
    local char = lp.Character; if not char then return end
    char:PivotTo(CFrame.new(pos)); local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
end
local function atpIsRagdolled()
    local char = lp.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum:GetState() == Enum.HumanoidStateType.Physics
end
local function atpExecute()
    if not AutoTP.Enabled then return end; local side = AutoTP.Side
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local savedAnchor = nil
    local savedForce = nil
    if root then
        savedAnchor = root:FindFirstChild("RagdollAnchor")
        if savedAnchor then
            savedForce = savedAnchor.MaxForce
            savedAnchor.MaxForce = Vector3.new(0, 0, 0)
        end
        root.CanCollide = true
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    task.wait(0.05)
    atpMove(AutoTP.CHECKPOINT)
    task.wait(0.3)
    atpMove(AutoTP.FINAL[side])
    task.wait(0.1)
    if savedAnchor and savedAnchor.Parent and savedForce then
        savedAnchor.MaxForce = savedForce
        if savedAnchor.Parent then
            savedAnchor.Position = savedAnchor.Parent.Position
        end
    end
end
local function atpStartDetection()
    if AutoTP.StateConn then AutoTP.StateConn:Disconnect(); AutoTP.StateConn = nil end
    if AutoTP.RagdollConn then AutoTP.RagdollConn:Disconnect(); AutoTP.RagdollConn = nil end
    if AutoTP.GrabRagConn then AutoTP.GrabRagConn:Disconnect(); AutoTP.GrabRagConn = nil end
    local char = lp.Character; if not char then return end
    local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
    AutoTP.StateConn = hum.StateChanged:Connect(function(old, new)
        if not AutoTP.Enabled then return end
        if new == Enum.HumanoidStateType.Physics then atpExecute() end
    end)
    task.spawn(function()
        local remote = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Ragdoll") and ReplicatedStorage.Packages.Ragdoll:FindFirstChild("Ragdoll")
        if remote and remote:IsA("RemoteEvent") then
            AutoTP.RagdollConn = remote.OnClientEvent:Connect(function(arg1, arg2)
                if not AutoTP.Enabled then return end
                if arg1 == "Make" or arg2 == "manualM" then atpExecute() end
            end)
        end
    end)
end
local function atpStopDetection()
    if AutoTP.StateConn then AutoTP.StateConn:Disconnect(); AutoTP.StateConn = nil end
    if AutoTP.RagdollConn then AutoTP.RagdollConn:Disconnect(); AutoTP.RagdollConn = nil end
    if AutoTP.GrabRagConn then AutoTP.GrabRagConn:Disconnect(); AutoTP.GrabRagConn = nil end
end
local function destroyAutoTPGui() if AutoTP.Gui and AutoTP.Gui.Parent then AutoTP.Gui:Destroy(); AutoTP.Gui = nil end end
local function showAutoTPGui()
    destroyAutoTPGui()
    local sg = Instance.new("ScreenGui"); sg.Name = "NimbusTP"; sg.ResetOnSpawn = false; sg.Parent = CoreGui
    AutoTP.Gui = sg

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 220, 0, 100)
    MainFrame.Position = UDim2.new(0, 10, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg
    local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 12); frameCorner.Parent = MainFrame
    local frameStroke = Instance.new("UIStroke"); frameStroke.Color = Color3.fromRGB(255, 255, 255); frameStroke.Thickness = 2.5; frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; frameStroke.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35); Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1; Title.Text = "Ragdoll TP Position"
    Title.Font = Enum.Font.GothamBold; Title.TextColor3 = Color3.new(1, 1, 1); Title.TextSize = 16
    Title.Parent = MainFrame

    local ButtonHolder = Instance.new("Frame")
    ButtonHolder.Size = UDim2.new(1, -20, 0, 45); ButtonHolder.Position = UDim2.new(0, 10, 0, 45)
    ButtonHolder.BackgroundTransparency = 1; ButtonHolder.Parent = MainFrame
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Parent = ButtonHolder

    local function CreateBaseButton(name, text, isSelected)
        local btn = Instance.new("TextButton")
        btn.Name = name; btn.Size = UDim2.new(0.48, 0, 1, 0)
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Text = text; btn.AutoButtonColor = false
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 10); btnCorner.Parent = btn
        local btnStroke = Instance.new("UIStroke"); btnStroke.Color = Color3.fromRGB(255, 255, 255); btnStroke.Thickness = 1.5; btnStroke.Parent = btn
        local function UpdateVisuals(selected)
            if selected then btn.BackgroundColor3 = Color3.fromRGB(0, 176, 80); btn.TextColor3 = Color3.new(1, 1, 1)
            else btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btn.TextColor3 = Color3.new(0, 0, 0) end
        end
        UpdateVisuals(isSelected); btn.Parent = ButtonHolder
        return btn, UpdateVisuals
    end

    local base1, update1 = CreateBaseButton("Base1", "BASE 1", AutoTP.Side == "Left" or AutoTP.Side == nil)
    local base2, update2 = CreateBaseButton("Base2", "BASE 2", AutoTP.Side == "Right")

    local function selectSide(side)
        AutoTP.Side = side
        update1(side == "Left"); update2(side == "Right")
        destroyAutoTPGui()
        atpStartDetection()
    end

    base1.MouseButton1Click:Connect(function() selectSide("Left") end)
    base2.MouseButton1Click:Connect(function() selectSide("Right") end)
end
lp.CharacterAdded:Connect(function() if AutoTP.Enabled then task.wait(1); atpStartDetection() end end)
AddToggle("Combat", "Auto TP", false, function(v)
    if v then AutoTP.Enabled = true; showAutoTPGui()
    else AutoTP.Enabled = false; atpStopDetection(); destroyAutoTPGui() end
end)

-------------------------------------------------------------------------
-- DROP MODULE
-------------------------------------------------------------------------
local AutoDrop = { Enabled = false, Conn = nil }

dropOvalBtn.MouseButton1Click:Connect(function()
    if ovalWasDragged then ovalWasDragged = false; return end
    if not AutoDrop.Enabled then return end
    local char = lp.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 100, hrp.AssemblyLinearVelocity.Z)
    task.spawn(function()
        local timeout = tick() + 3
        repeat task.wait() until hrp.AssemblyLinearVelocity.Y <= 0 or tick() > timeout
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -150, hrp.AssemblyLinearVelocity.Z)
    end)
end)

local function enableAutoDrop()
    if AutoDrop.Enabled then return end
    AutoDrop.Enabled = true
    showOvalBtn(dropOvalBtn)
    OvalBtnStates.drop = true
    setNHButtonState(dropOvalBtn, false)
    updateOvalVisibility()
end
local function disableAutoDrop()
    if not AutoDrop.Enabled then return end
    AutoDrop.Enabled = false
    if AutoDrop.Conn then AutoDrop.Conn:Disconnect(); AutoDrop.Conn = nil end
    hideOvalBtn(dropOvalBtn)
    OvalBtnStates.drop = false
    updateOvalVisibility()
end
AddToggle("Combat", "Drop", false, function(v) if v then enableAutoDrop() else disableAutoDrop() end end)

-------------------------------------------------------------------------
-- DECENT SETTINGS FLOATING BUTTON
-------------------------------------------------------------------------
local DecentSettingsGui = Instance.new("ScreenGui")
DecentSettingsGui.Name = "NimbusSettings"; DecentSettingsGui.ResetOnSpawn = false; DecentSettingsGui.Parent = CoreGui

local DecentBtn = Instance.new("TextButton")
DecentBtn.Name = "DecentSettingsButton"
DecentBtn.Size = UDim2.new(0, 180, 0, 48)
DecentBtn.Position = UDim2.new(0, 10, 1, -58)
DecentBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DecentBtn.BorderSizePixel = 0
DecentBtn.AutoButtonColor = true
DecentBtn.Text = "Decent Settings"
DecentBtn.Font = Enum.Font.GothamBold
DecentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DecentBtn.TextSize = 14
DecentBtn.TextStrokeTransparency = 0.8
DecentBtn.Parent = DecentSettingsGui

local _dc = Instance.new("UICorner"); _dc.CornerRadius = UDim.new(0, 12); _dc.Parent = DecentBtn
local _ds = Instance.new("UIStroke"); _ds.Color = Color3.fromRGB(255, 255, 255); _ds.Thickness = 2.5; _ds.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; _ds.Parent = DecentBtn

local _dragging, _dragStart, _startPos, _dragInput
DecentBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        _dragging = true
        _dragStart = Vector2.new(input.Position.X, input.Position.Y)
        _startPos = DecentBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then _dragging = false end end)
    end
end)
DecentBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        _dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == _dragInput and _dragging then
        local delta = Vector2.new(input.Position.X - _dragStart.X, input.Position.Y - _dragStart.Y)
        DecentBtn.Position = UDim2.new(_startPos.X.Scale, _startPos.X.Offset + delta.X, _startPos.Y.Scale, _startPos.Y.Offset + delta.Y)
    end
end)

DecentBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        if not Grab_Enabled then Grab_RADIUS = 3.1; enableAutoGrab() end
        if not InfiniteJump.Enabled then enableInfJump() end
        if not PlayerESP.Enabled then enableESP() end
        showSpeedGuiOff()
        if not AutoDrop.Enabled then enableAutoDrop() end
        Workspace.Terrain.WaterWaveSize = 0; game:GetService("Lighting").GlobalShadows = false
        AutoPlay.Zone1Speed = 55.3; AutoPlay.Zone2Speed = 27.2; AutoPlay.StartDelay = 0; AutoPlay.ZoneStop = 0.1
        showAutoPlayGui()
        local features = {"Auto Grab","Drop","Infinite Jump","ESP Players","Taunt","Lock Target","Float","Spin Body","No Player Collision","Anti Ragdoll 1","No Camera Collision","Xray Base","Auto TP"}
        for _, name in ipairs(features) do
            if name == "Float" or name == "Spin Body" then
                local vis = ToggleVisuals[name]; if vis then vis(true) end
                if name == "Float" then
                    showOvalBtn(floatOvalBtn); OvalBtnStates.float = true
                    setNHButtonState(floatOvalBtn, false)
                elseif name == "Spin Body" then
                    showOvalBtn(spinOvalBtn); OvalBtnStates.spin = true
                    setNHButtonState(spinOvalBtn, false)
                end
                updateOvalVisibility()
            else
                local setter = ToggleSetters[name]; if setter then setter(true) end
                local vis = ToggleVisuals[name]; if vis then vis(true) end
            end
        end
        DecentBtn.Text = "Applied!"
        DecentBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(1)
        DecentBtn.Text = "Decent Settings"
        DecentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end)

-------------------------------------------------------------------------
-- AUTO MEDUSA MODULE
-------------------------------------------------------------------------
local AutoMedusa = { Enabled = false, RANGE = 8, Conn = nil }
local function getMedusaHead(char)
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name == "Medusa's Head" then return t end end
    for _, t in ipairs(lp.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name == "Medusa's Head" then return t end end
    return nil
end
local function getNearestPlayerMedusa(hrp)
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local tHRP = p.Character:FindFirstChild("HumanoidRootPart"); local tHum = p.Character:FindFirstChild("Humanoid")
            if tHRP and tHum and tHum.Health > 0 then
                local d = (hrp.Position - tHRP.Position).Magnitude
                if d < dist and d <= AutoMedusa.RANGE then dist = d; nearest = p end
            end
        end
    end
    return nearest
end
local function enableAutoMedusa()
    if AutoMedusa.Enabled then return end; AutoMedusa.Enabled = true
    AutoMedusa.Conn = RunService.Heartbeat:Connect(function()
        if not AutoMedusa.Enabled then return end
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid"); if not hrp or not hum then return end
        local target = getNearestPlayerMedusa(hrp); if not target then return end
        local tool = getMedusaHead(char); if not tool then return end
        if tool.Parent ~= char then hum:EquipTool(tool) end; tool:Activate()
    end)
end
local function disableAutoMedusa() AutoMedusa.Enabled = false; if AutoMedusa.Conn then AutoMedusa.Conn:Disconnect(); AutoMedusa.Conn = nil end end
AddToggle("Combat", "Auto Medusa", false, function(v) if v then enableAutoMedusa() else disableAutoMedusa() end end)

local batConn = nil
AddToggle("Combat", "Auto Bat", false, function(v)
    if v then
        batConn = RunService.Heartbeat:Connect(function()
            local c = lp.Character; local b = getWeapon()
            if b and c and c:FindFirstChild("Humanoid") then if b.Parent ~= c then c.Humanoid:EquipTool(b) end; b:Activate() end
        end)
    else if batConn then batConn:Disconnect(); batConn = nil end end
end)
AddToggle("Combat", "Infinite Jump", false, function(v) if v then enableInfJump() else disableInfJump() end end)

-- PROTECT TAB
local AntiFPS = { Conn = nil, Boosting = false }
AddToggle("Protect", "Anti FPS Devourer", false, function(v)
    AntiFPS.Boosting = v
    if v then
        game:GetService("Lighting").GlobalShadows = false
        Workspace.Terrain.WaterWaveSize = 0; Workspace.Terrain.WaterWaveSpeed = 0
        game:GetService("Lighting").FogEnd = 100000
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic end
            if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled = false end
        end
        AntiFPS.Conn = game.DescendantAdded:Connect(function(obj)
            if not AntiFPS.Boosting then return end
            if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic end
            if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled = false end
        end)
    else
        if AntiFPS.Conn then AntiFPS.Conn:Disconnect(); AntiFPS.Conn = nil end
        game:GetService("Lighting").GlobalShadows = true
        Workspace.Terrain.WaterWaveSize = 0.5; Workspace.Terrain.WaterWaveSpeed = 10
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 0 end
        end
    end
end)
AddToggle("Protect", "Anti Ragdoll 1", false, function(v)
    AntiRagdoll.Enabled = v
    if v and lp.Character then setupAntiRagdoll(lp.Character)
    else cleanupRagdoll(); disconnectRemote() end
end)

-- ANTI RAGDOLL 2
local AR2 = { mode = nil, connections = {}, charData = {}, isBoosting = false, BOOST_SPEED = 400, DEFAULT_SPEED = 16 }
local function ar2Cache() local char = lp.Character; if not char then return false end; local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart"); if not hum or not root then return false end; AR2.charData = { character = char, humanoid = hum, root = root }; return true end
local function ar2DisconnectAll() for _, c in ipairs(AR2.connections) do pcall(function() c:Disconnect() end) end; AR2.connections = {} end
local function ar2IsRagdolled() if not AR2.charData.humanoid then return false end; local state = AR2.charData.humanoid:GetState(); if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then return true end; local endTime = lp:GetAttribute("RagdollEndTime"); if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then return true end; return false end
local function ar2ForceExit() if not AR2.charData.humanoid or not AR2.charData.root then return end; pcall(function() lp:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end); for _, d in ipairs(AR2.charData.character:GetDescendants()) do if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then d:Destroy() end end; if not AR2.isBoosting then AR2.isBoosting = true; AR2.charData.humanoid.WalkSpeed = AR2.BOOST_SPEED end; if AR2.charData.humanoid.Health > 0 then AR2.charData.humanoid:ChangeState(Enum.HumanoidStateType.Running) end; AR2.charData.root.Anchored = false end
local function ar2Loop() while AR2.mode == "on" do task.wait(); if ar2IsRagdolled() then ar2ForceExit() elseif AR2.isBoosting then AR2.isBoosting = false; if AR2.charData.humanoid then AR2.charData.humanoid.WalkSpeed = AR2.DEFAULT_SPEED end end end end
local function enableAR2() if AR2.mode == "on" then return end; if not ar2Cache() then return end; AR2.mode = "on"; table.insert(AR2.connections, RunService.RenderStepped:Connect(function() local cam = workspace.CurrentCamera; if cam and AR2.charData.humanoid then cam.CameraSubject = AR2.charData.humanoid end end)); table.insert(AR2.connections, lp.CharacterAdded:Connect(function() AR2.isBoosting = false; task.wait(0.5); ar2Cache() end)); task.spawn(ar2Loop) end
local function disableAR2() AR2.mode = nil; if AR2.isBoosting and AR2.charData.humanoid then AR2.charData.humanoid.WalkSpeed = AR2.DEFAULT_SPEED end; AR2.isBoosting = false; ar2DisconnectAll(); AR2.charData = {} end
AddToggle("Protect", "Anti Ragdoll 2", false, function(v) if v then enableAR2() else disableAR2() end end)

AddToggle("Protect", "Optimizer", false, function(v)
    if v then
        do
            local Lighting    = game:GetService("Lighting")
            local SoundService = game:GetService("SoundService")
            local BATCH_SIZE  = 50

            local function batchLoop(list, fn)
                for _, obj in ipairs(list) do
                    fn(obj)
                end
            end

            local function forceGC()
                collectgarbage("collect")
                collectgarbage("collect")
            end

            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            pcall(function() settings().Rendering.Shadows = false end)
            pcall(function() settings().Rendering.AntiAliasing = false end)
            pcall(function() UserSettings():GetService("UserGameSettings").GraphicsQualityLevel = 1 end)

            Lighting.GlobalShadows = false
            Lighting.FogEnd        = 1000
            Lighting.FogStart      = 900
            Lighting.Brightness    = 2
            Lighting.ClockTime     = 12
            batchLoop(Lighting:GetDescendants(), function(obj)
                if obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect")
                or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect")
                or obj:IsA("ColorCorrectionEffect") then
                    pcall(function() obj.Enabled = false end)
                end
            end)

            local cam = Workspace.CurrentCamera
            if cam then
                for _, fx in ipairs(cam:GetChildren()) do
                    if fx:IsA("BloomEffect") or fx:IsA("DepthOfFieldEffect")
                    or fx:IsA("ColorCorrectionEffect") or fx:IsA("BlurEffect")
                    or fx:IsA("SunRaysEffect") then
                        pcall(function() fx.Enabled = false end)
                    end
                end
            end

            Workspace.Terrain.WaterWaveSize  = 0
            Workspace.Terrain.WaterWaveSpeed = 0

            pcall(function()
                Workspace.StreamingMinRadius    = 32
                Workspace.StreamingTargetRadius = 96
            end)

            pcall(function()
                SoundService.DistanceFactor = 3
                SoundService.DopplerScale   = 0
                SoundService.RolloffScale   = 2
            end)
            batchLoop(workspace:GetDescendants(), function(s)
                if s:IsA("Sound") then
                    pcall(function()
                        s.RollOffMaxDistance = math.min(s.RollOffMaxDistance, 100)
                        if s.Looped and s.Volume < 0.05 then s:Stop() end
                    end)
                end
            end)

            batchLoop(workspace:GetDescendants(), function(obj)
                pcall(function()
                    if obj:IsA("ParticleEmitter") then obj.Enabled = false; obj.Rate = 0
                    elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false
                    elseif obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled = false
                    end
                end)
            end)

            batchLoop(workspace:GetDescendants(), function(obj)
                if obj:IsA("Humanoid") then
                    local p = Players:GetPlayerFromCharacter(obj.Parent)
                    if p and p ~= lp then
                        pcall(function() obj.EvaluateStateMachine = false end)
                    end
                end
            end)

            batchLoop(workspace:GetDescendants(), function(obj)
                if obj:IsA("BasePart") then
                    if obj.Transparency > 0.9 then obj.CanCollide = false end
                    pcall(function() obj.CastShadow = false end)
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Shadows = false
                end
            end)

            forceGC()

            lp.CharacterAdded:Connect(function()
                task.wait(2)
                pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                Lighting.GlobalShadows = false
                batchLoop(workspace:GetDescendants(), function(obj)
                    pcall(function()
                        if obj:IsA("ParticleEmitter") then obj.Enabled = false; obj.Rate = 0
                        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false
                        elseif obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled = false
                        end
                    end)
                end)
                forceGC()
            end)

            task.spawn(function()
                while true do
                    task.wait(45)
                    forceGC()
                end
            end)

            task.spawn(function()
                while true do
                    task.wait(2)
                    local t = tick()
                    RunService.RenderStepped:Wait()
                    local fps = 1 / math.max(tick() - t, 0.001)
                    if fps < 20 then
                        task.spawn(function()
                            batchLoop(workspace:GetDescendants(), function(obj)
                                pcall(function()
                                    if obj:IsA("ParticleEmitter") then obj.Enabled = false; obj.Rate = 0
                                    elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false
                                    elseif obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled = false
                                    end
                                end)
                            end)
                            forceGC()
                        end)
                    end
                end
            end)
        end
    end
end)
local NoCollision = { Conn = nil, CharConns = {} }

local function applyNoCollision(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    char.DescendantAdded:Connect(function(part)
        if NoCollision.Conn and part:IsA("BasePart") then
            part.CanCollide = false
        end
    end)
end

AddToggle("Protect", "No Player Collision", false, function(v)
    if v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                applyNoCollision(p.Character)
            end
        end
        NoCollision.Conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                if NoCollision.Conn then applyNoCollision(char) end
            end)
        end)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local c = p.CharacterAdded:Connect(function(char)
                    task.wait(0.1)
                    if NoCollision.Conn then applyNoCollision(char) end
                end)
                table.insert(NoCollision.CharConns, c)
            end
        end
        local hbConn
        hbConn = RunService.Heartbeat:Connect(function()
            if not NoCollision.Conn then hbConn:Disconnect(); return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        table.insert(NoCollision.CharConns, hbConn)
    else
        if NoCollision.Conn then NoCollision.Conn:Disconnect(); NoCollision.Conn = nil end
        for _, c in ipairs(NoCollision.CharConns) do pcall(function() c:Disconnect() end) end
        NoCollision.CharConns = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
end)

-- VISUAL TAB
AddToggle("Visual", "ESP Players", false, function(v) if v then enableESP() else disableESP() end end)
AddToggle("Visual", "No Walk Animation", false, function(v) if v then enableNoAnim() else disableNoAnim() end end)
AddToggle("Visual", "Xray Base", false, function(v) if v then enableXrayBase() else disableXrayBase() end end)
local NoCamCol = { Conn = nil }
AddToggle("Visual", "No Camera Collision", false, function(v)
    if v then
        NoCamCol.Conn = RunService.RenderStepped:Connect(function()
            if lp.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            end
        end)
    else
        if NoCamCol.Conn then NoCamCol.Conn:Disconnect(); NoCamCol.Conn = nil end
        pcall(function() lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom end)
    end
end)
AddToggle("Visual", "Speed Customizer", false, function(v) if v then enableSpeedCustomizer() else disableSpeedCustomizer() end end)

-------------------------------------------------------------------------
-- SPIN BODY MODULE
-------------------------------------------------------------------------
do
local SpinBody = { Force = nil, CharConn = nil }

local function startSpinBody()
    local char = lp.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root or SpinBody.Force then return end
    SpinBody.Force = Instance.new("BodyAngularVelocity")
    SpinBody.Force.AngularVelocity = Vector3.new(0, 25, 0)
    SpinBody.Force.MaxTorque = Vector3.new(0, math.huge, 0)
    SpinBody.Force.P = 1250
    SpinBody.Force.Parent = root
end

local function stopSpinBody()
    if SpinBody.Force then SpinBody.Force:Destroy(); SpinBody.Force = nil end
end

local function enableSpinBody()
    startSpinBody()
    SpinBody.CharConn = lp.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        startSpinBody()
    end)
end

local function disableSpinBody()
    stopSpinBody()
    if SpinBody.CharConn then SpinBody.CharConn:Disconnect(); SpinBody.CharConn = nil end
end

local SpinBodyActive = false
spinOvalBtn.MouseButton1Click:Connect(function()
    if ovalWasDragged then ovalWasDragged = false; return end
    SpinBodyActive = not SpinBodyActive
    setNHButtonState(spinOvalBtn, SpinBodyActive)
    local lbl = spinOvalBtn:FindFirstChild("Label")
    if lbl then lbl.Text = SpinBodyActive and "Spin Body [ON]" or "Spin Body" end
    if SpinBodyActive then enableSpinBody() else disableSpinBody() end
end)

AddToggle("Visual", "Spin Body", false, function(v)
    if v then
        showOvalBtn(spinOvalBtn)
        OvalBtnStates.spin = true
        setNHButtonState(spinOvalBtn, false)
        local lbl = spinOvalBtn:FindFirstChild("Label")
        if lbl then lbl.Text = "Spin Body" end
        updateOvalVisibility()
    else
        disableSpinBody()
        SpinBodyActive = false
        setNHButtonState(spinOvalBtn, false)
        local lbl = spinOvalBtn:FindFirstChild("Label")
        if lbl then lbl.Text = "Spin Body" end
        hideOvalBtn(spinOvalBtn)
        OvalBtnStates.spin = false
        updateOvalVisibility()
    end
end)

-------------------------------------------------------------------------
-- FLOAT MODULE
-------------------------------------------------------------------------
local Float = { Enabled = false, Height = 8, Conn = nil, Attachment = nil, Force = nil, CachedMass = 0, LastMassUpdate = 0 }
local function setupFloatForce()
    pcall(function()
        local c = lp.Character; if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart"); if not rp then return end
        if Float.Force then Float.Force:Destroy(); Float.Force = nil end
        if Float.Attachment then Float.Attachment:Destroy(); Float.Attachment = nil end
        Float.Attachment = Instance.new("Attachment"); Float.Attachment.Parent = rp
        Float.Force = Instance.new("VectorForce"); Float.Force.Attachment0 = Float.Attachment
        Float.Force.ApplyAtCenterOfMass = true; Float.Force.RelativeTo = Enum.ActuatorRelativeTo.World
        Float.Force.Force = Vector3.new(0, 0, 0); Float.Force.Parent = rp
    end)
end
local function enableFloat()
    if Float.Enabled then return end; Float.Enabled = true; Float.CachedMass = 0; Float.LastMassUpdate = 0
    showOvalBtn(floatOvalBtn)
    OvalBtnStates.float = true
    setNHButtonState(floatOvalBtn, true)
    local lbl = floatOvalBtn:FindFirstChild("Label")
    if lbl then lbl.Text = "Float [ON]" end
    updateOvalVisibility()
    setupFloatForce()
    if Float.Conn then Float.Conn:Disconnect() end
    Float.Conn = RunService.Heartbeat:Connect(function()
        if not Float.Enabled then return end
        pcall(function()
            local c = lp.Character; if not c then return end
            local rp = c:FindFirstChild("HumanoidRootPart"); if not rp then return end
            local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local now = tick()
            if now - Float.LastMassUpdate > 2 or Float.CachedMass == 0 then
                Float.CachedMass = 0
                for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then Float.CachedMass = Float.CachedMass + p:GetMass() end end
                Float.LastMassUpdate = now
            end
            local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {c}; rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local result = Workspace:Raycast(rp.Position, Vector3.new(0, -500, 0), rayParams)
            local groundY = result and result.Position.Y or (rp.Position.Y - Float.Height)
            local targetY = groundY + Float.Height; local diff = targetY - rp.Position.Y; local velY = rp.AssemblyLinearVelocity.Y
            if math.abs(diff) < 0.1 and math.abs(velY) < 0.5 then diff = 0; velY = 0 end
            if Float.Force then Float.Force.Force = Vector3.new(0, Float.CachedMass * (500 * diff - 80 * velY + Workspace.Gravity), 0) end
            hum.JumpPower = 0
        end)
    end)
end
local function disableFloat()
    if not Float.Enabled then return end; Float.Enabled = false; Float.CachedMass = 0
    setNHButtonState(floatOvalBtn, false)
    local lbl = floatOvalBtn:FindFirstChild("Label")
    if lbl then lbl.Text = "Float" end
    if Float.Conn then Float.Conn:Disconnect(); Float.Conn = nil end
    if Float.Force then Float.Force:Destroy(); Float.Force = nil end
    if Float.Attachment then Float.Attachment:Destroy(); Float.Attachment = nil end
    pcall(function()
        local c = lp.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local rp = c:FindFirstChild("HumanoidRootPart"); if not rp then return end
        hum.JumpPower = 50
        local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {c}; rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = Workspace:Raycast(rp.Position, Vector3.new(0, -500, 0), rayParams)
        if result then rp.CFrame = CFrame.new(rp.Position.X, result.Position.Y + rp.Size.Y / 2 + 0.1, rp.Position.Z); rp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end)
end

floatOvalBtn.MouseButton1Click:Connect(function()
    if ovalWasDragged then ovalWasDragged = false; return end
    if Float.Enabled then
        disableFloat()
    else
        enableFloat()
    end
end)

AddToggle("Visual", "Float", false, function(v)
    if v then
        showOvalBtn(floatOvalBtn)
        OvalBtnStates.float = true
        setNHButtonState(floatOvalBtn, false)
        local lbl = floatOvalBtn:FindFirstChild("Label")
        if lbl then lbl.Text = "Float" end
        updateOvalVisibility()
    else
        disableFloat()
        hideOvalBtn(floatOvalBtn)
        OvalBtnStates.float = false
        updateOvalVisibility()
    end
end)

-------------------------------------------------------------------------
-- TAUNT FLOATING BUTTON
-------------------------------------------------------------------------
local TauntEnabled = false

tauntOvalBtn.MouseButton1Click:Connect(function()
    if ovalWasDragged then ovalWasDragged = false; return end
    task.spawn(function()
        pcall(function()
            local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync("ᴅʀΛᴋ ɪѕ вᴇᴛᴛᴇʀ")
            end
        end)
    end)
    local lbl = tauntOvalBtn:FindFirstChild("Label")
    if lbl then lbl.Text = "Sent!" end
    task.delay(0.6, function()
        if lbl then lbl.Text = "Taunt" end
    end)
end)

AddToggle("Visual", "Taunt", false, function(v)
    TauntEnabled = v
    if v then
        showOvalBtn(tauntOvalBtn)
        OvalBtnStates.taunt = true
        setNHButtonState(tauntOvalBtn, false)
        updateOvalVisibility()
    else
        local lbl = tauntOvalBtn:FindFirstChild("Label")
        if lbl then lbl.Text = "Taunt" end
        hideOvalBtn(tauntOvalBtn)
        OvalBtnStates.taunt = false
        updateOvalVisibility()
    end
end)

end -- close spin/float/taunt do block


-------------------------------------------------------------------------
-- FLING MODULE (anti lock-target counter)
-------------------------------------------------------------------------
do
local Fling = { Enabled = false, Force = nil, CharConn = nil }

local function startFlingBody()
    local char = lp.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or Fling.Force then return end
    Fling.Force = Instance.new("BodyAngularVelocity")
    Fling.Force.AngularVelocity = Vector3.new(0, 150, 0)
    Fling.Force.MaxTorque = Vector3.new(0, math.huge, 0)
    Fling.Force.P = 1250
    Fling.Force.Parent = root
end

local function stopFlingBody()
    if Fling.Force then Fling.Force:Destroy(); Fling.Force = nil end
end

local function enableFling()
    if Fling.Enabled then return end
    Fling.Enabled = true
    startFlingBody()
    if Fling.CharConn then Fling.CharConn:Disconnect() end
    Fling.CharConn = lp.CharacterAdded:Connect(function()
        task.wait(0.3)
        if Fling.Enabled then startFlingBody() end
    end)
end

local function disableFling()
    Fling.Enabled = false
    stopFlingBody()
    if Fling.CharConn then Fling.CharConn:Disconnect(); Fling.CharConn = nil end
end

AddToggle("Combat", "Fling", false, function(v)
    if v then enableFling() else disableFling() end
end)

_G.drAkFlingEnable  = enableFling
_G.drAkFlingDisable = disableFling
end -- close fling do block



-- SETTINGS TAB / KEYBINDS
do
local Keybinds = { SpeedCustomizer = nil, AutoWalk = nil, AutoPlay = nil, LockTarget = nil, SpinBody = nil, Float = nil, Fling = nil }
local KeybindToggles = { SpeedCustomizer = false, AutoWalk = false, AutoPlay = false, LockTarget = false, SpinBody = false, Float = false, Fling = false }
local KeybindActions = {
    SpeedCustomizer = function(v) if v then enableSpeedCustomizer() else disableSpeedCustomizer() end end,
    AutoWalk = function(v) if v then AutoWalk.Enabled = true; showAutoWalkPicker(function() AutoWalk.Enabled = false end) else stopAutoWalk() end end,
    AutoPlay = function(v) if v then showAutoPlayGui() end end,
    LockTarget = function(v) if v then enableLockTarget() else disableLockTarget() end end,
    SpinBody = function(v) if v then enableSpinBody() else disableSpinBody() end end,
    Fling = function(v)
        if v then if _G.drAkFlingEnable then _G.drAkFlingEnable() end
        else if _G.drAkFlingDisable then _G.drAkFlingDisable() end end
    end,
}
local CONFIG_FILE_KB = "NimbusConfig.txt"
local KeyBtnRefs = {}
local function saveKBConfig()
    local lines = {}
    for name, keyCode in pairs(Keybinds) do if keyCode then table.insert(lines, name .. "=" .. tostring(keyCode):gsub("Enum.KeyCode.", "")) end end
    pcall(function() writefile(CONFIG_FILE_KB, table.concat(lines, "\n")) end)
end
local function loadKBConfig()
    local ok, exists = pcall(isfile, CONFIG_FILE_KB); if not ok or not exists then return end
    local ok2, content = pcall(readfile, CONFIG_FILE_KB); if not ok2 or not content then return end
    for line in content:gmatch("[^\n]+") do
        local key, val = line:match("^(.-)=(.+)$")
        if key and val then
            local okKc, kc = pcall(function() return Enum.KeyCode[val] end)
            if okKc and kc and tostring(kc) ~= "Enum.KeyCode.Unknown" then
                Keybinds[key] = kc; if KeyBtnRefs[key] then KeyBtnRefs[key].Text = val end
            end
        end
    end
end
local HeaderRow = create("Frame", {Size = UDim2.new(0.92, 0, 0, 30), BackgroundTransparency = 1, Parent = Pages["Settings"]})
create("TextLabel", {Text = "━━━  KEYBINDS  ━━━", Size = UDim2.new(1, 0, 1, 0), TextColor3 = COLORS.Border, Font = "GothamBold", TextSize = 13, BackgroundTransparency = 1, TextXAlignment = "Center", Parent = HeaderRow})
local function addKeybindRow(featureName, displayName)
    local Row = create("Frame", {Size = UDim2.new(0.92, 0, 0, 50), BackgroundColor3 = COLORS.RowBG, BackgroundTransparency = 0.5, Parent = Pages["Settings"]})
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Row}); create("UIStroke", {Color = COLORS.Border, Thickness = 1, Transparency = 0.8, Parent = Row})
    create("TextLabel", {Text = displayName, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.05, 0, 0, 0), TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 12, BackgroundTransparency = 1, TextXAlignment = "Left", Parent = Row})
    local KeyBtn = create("TextButton", {Size = UDim2.new(0.38, 0, 0, 30), Position = UDim2.new(0.95, -110, 0.5, -15), BackgroundColor3 = Color3.fromRGB(5, 5, 5), Text = "None", TextColor3 = Color3.new(1,1,1), Font = "GothamBold", TextSize = 12, Parent = Row})
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeyBtn}); create("UIStroke", {Color = Color3.fromRGB(32, 32, 32), Thickness = 1.5, Parent = KeyBtn})
    KeyBtnRefs[featureName] = KeyBtn
    local listening = false
    KeyBtn.MouseButton1Click:Connect(function()
        if listening then return end; listening = true; KeyBtn.Text = "..."; KeyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                if keyName == "Backspace" or keyName == "Delete" then Keybinds[featureName] = nil; KeyBtn.Text = "None"
                else Keybinds[featureName] = input.KeyCode; KeyBtn.Text = keyName end
                KeyBtn.TextColor3 = Color3.new(1,1,1); listening = false; conn:Disconnect()
            end
        end)
    end)
end
addKeybindRow("SpeedCustomizer", "Speed Customizer")
addKeybindRow("AutoWalk",        "Auto Walk")
addKeybindRow("AutoPlay",        "Auto Play")
addKeybindRow("LockTarget",      "Lock Target")
addKeybindRow("SpinBody",        "Spin Body")
addKeybindRow("Float",           "Float")
addKeybindRow("Fling",           "Fling")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for featureName, keyCode in pairs(Keybinds) do
        if keyCode and input.KeyCode == keyCode then
            KeybindToggles[featureName] = not KeybindToggles[featureName]
            local action = KeybindActions[featureName]; if action then action(KeybindToggles[featureName]) end
        end
    end
end)
local function drag(f)
    local d, ds, sp
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true
            ds = Vector2.new(i.Position.X, i.Position.Y)
            sp = f.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(i.Position.X - ds.X, i.Position.Y - ds.Y)
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = false
        end
    end)
end
drag(MainFrame); drag(ToggleIcon)
ToggleIcon.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-------------------------------------------------------------------------
-- SPEED HUD (billboard above head)
-------------------------------------------------------------------------
do
local SpeedHUD = { Conn = nil, BB = nil, Label = nil }
local function createSpeedHUD(char)
    if SpeedHUD.BB then SpeedHUD.BB:Destroy(); SpeedHUD.BB = nil; SpeedHUD.Label = nil end
    local hrp = char:WaitForChild("HumanoidRootPart", 5); if not hrp then return end
    local bb = Instance.new("BillboardGui"); bb.Name = "NimbusSpeedHUD"; bb.Adornee = hrp
    bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 90, 0, 22); bb.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0); bb.Parent = CoreGui
    SpeedHUD.BB = bb
    local bg = Instance.new("Frame", bb); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0); bg.BackgroundTransparency = 0.4; bg.BorderSizePixel = 0
    local bgc = Instance.new("UICorner", bg); bgc.CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", bg); lbl.Name = "SpeedLabel"; lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextStrokeTransparency = 0.3; lbl.Text = "Speed: 0"
    SpeedHUD.Label = lbl
end
local function startSpeedHUD()
    if SpeedHUD.Conn then SpeedHUD.Conn:Disconnect() end
    SpeedHUD.Conn = RunService.RenderStepped:Connect(function()
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not SpeedHUD.Label or not SpeedHUD.Label.Parent then return end
        local vel = hrp.AssemblyLinearVelocity
        local speed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude * 100 + 0.5) / 100
        SpeedHUD.Label.Text = "Speed: " .. string.format("%.2f", speed):gsub("%.?0+$", "")
    end)
end
if lp.Character then createSpeedHUD(lp.Character) end
startSpeedHUD()
lp.CharacterAdded:Connect(function(char) task.wait(0.5); createSpeedHUD(char) end)
end -- close speed hud do block

-------------------------------------------------------------------------
print("✅ drΛk ᴅᴜᴇʟ loaded")
end -- close keybinds do block
