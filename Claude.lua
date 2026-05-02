-- LocalScript (place inside StarterPlayerScripts or StarterGui)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =====================
-- PART 1: INTRO SCREEN
-- =====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightHubIntro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- LIGHT label
local lightLabel = Instance.new("TextLabel")
lightLabel.Size = UDim2.new(0.85, 0, 0.22, 0)
lightLabel.Position = UDim2.new(0.075, 0, 0.22, 0)
lightLabel.AnchorPoint = Vector2.new(0, 0)
lightLabel.BackgroundTransparency = 1
lightLabel.Text = "LIGHT"
lightLabel.Font = Enum.Font.GothamBlack
lightLabel.TextScaled = true
lightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lightLabel.TextStrokeTransparency = 0.1
lightLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
lightLabel.ZIndex = 10
lightLabel.ClipsDescendants = true  -- shine is clipped INSIDE the label bounds
lightLabel.Parent = screenGui

-- HUB label
local hubLabel = Instance.new("TextLabel")
hubLabel.Size = UDim2.new(0.85, 0, 0.22, 0)
hubLabel.Position = UDim2.new(0.075, 0, 0.52, 0)
hubLabel.AnchorPoint = Vector2.new(0, 0)
hubLabel.BackgroundTransparency = 1
hubLabel.Text = "HUB"
hubLabel.Font = Enum.Font.GothamBlack
hubLabel.TextScaled = true
hubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hubLabel.TextStrokeTransparency = 0.1
hubLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hubLabel.ZIndex = 10
hubLabel.ClipsDescendants = true  -- shine clipped inside label
hubLabel.Parent = screenGui

-- =====================
-- SHINE EFFECT (clipped inside each label)
-- =====================

local function createShine(parent)
	local shine = Instance.new("Frame")
	shine.Size = UDim2.new(0.15, 0, 2.5, 0)
	shine.Position = UDim2.new(-0.25, 0, -0.75, 0)
	shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shine.BackgroundTransparency = 0.0
	shine.BorderSizePixel = 0
	shine.Rotation = 18
	shine.ZIndex = 13
	shine.Parent = parent  -- parented directly to the label so ClipsDescendants cuts it

	local grad = Instance.new("UIGradient")
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   1),
		NumberSequenceKeypoint.new(0.4, 0.15),
		NumberSequenceKeypoint.new(0.5, 0.0),
		NumberSequenceKeypoint.new(0.6, 0.15),
		NumberSequenceKeypoint.new(1,   1),
	})
	grad.Rotation = 90
	grad.Parent = shine

	return shine
end

local lightShine = createShine(lightLabel)
local hubShine   = createShine(hubLabel)

local function runShine(shine, label)
	task.spawn(function()
		while label.Parent do
			shine.Position = UDim2.new(-0.25, 0, -0.75, 0)
			TweenService:Create(shine, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Position = UDim2.new(1.1, 0, -0.75, 0)
			}):Play()
			task.wait(2.0)
		end
	end)
end

runShine(lightShine, lightLabel)
task.delay(1.0, function() runShine(hubShine, hubLabel) end)

-- =====================
-- RAINBOW + FLASH
-- =====================

local rainbowActive = true
local flashActive   = true
local hue = 0

task.spawn(function()
	while rainbowActive do
		hue = (hue + 1) % 360
		local color = Color3.fromHSV(hue / 360, 1, 1)
		lightLabel.TextColor3 = color
		hubLabel.TextColor3   = color
		task.wait(0.03)
	end
end)

task.spawn(function()
	while flashActive do
		lightLabel.Visible = not lightLabel.Visible
		hubLabel.Visible   = not hubLabel.Visible
		task.wait(0.35)
	end
	lightLabel.Visible = true
	hubLabel.Visible   = true
end)

-- =====================
-- AFTER 6 SECONDS: SLIDE OUT
-- =====================

task.wait(6)

flashActive   = false
rainbowActive = false
task.wait(0.05)
lightLabel.Visible = true
hubLabel.Visible   = true

local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

TweenService:Create(lightLabel, tweenInfo, {
	Position = UDim2.new(-1.2, 0, 0.22, 0)
}):Play()

TweenService:Create(hubLabel, tweenInfo, {
	Position = UDim2.new(1.2, 0, 0.52, 0)
}):Play()

task.wait(0.85)
screenGui:Destroy()

-- =====================
-- PART 2: OVERHEAD TAG
-- =====================

task.spawn(function()
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "OverheadTag"
	billboardGui.Size = UDim2.new(0, 230, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
	billboardGui.AlwaysOnTop = false
	billboardGui.Adornee = head
	billboardGui.Parent = head

	local tagLabel = Instance.new("TextLabel")
	tagLabel.Size = UDim2.new(1, 0, 1, 0)
	tagLabel.BackgroundTransparency = 1
	tagLabel.Text = ".gg/UpeQbF32qj"
	tagLabel.Font = Enum.Font.GothamBlack
	tagLabel.TextScaled = true
	tagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	tagLabel.TextStrokeTransparency = 0.3
	tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	tagLabel.Parent = billboardGui

	local tagHue = 0
	while true do
		tagHue = (tagHue + 1) % 360
		tagLabel.TextColor3 = Color3.fromHSV(tagHue / 360, 1, 1)
		task.wait(0.03)
	end
end)
