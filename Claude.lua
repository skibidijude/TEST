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
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- LIGHT label
local lightLabel = Instance.new("TextLabel")
lightLabel.Size = UDim2.new(1, 0, 0.35, 0)
lightLabel.Position = UDim2.new(0, 0, 0.25, 0)
lightLabel.BackgroundTransparency = 1
lightLabel.Text = "LIGHT"
lightLabel.Font = Enum.Font.GothamBold
lightLabel.TextScaled = true
lightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lightLabel.Parent = frame

-- HUB label
local hubLabel = Instance.new("TextLabel")
hubLabel.Size = UDim2.new(1, 0, 0.35, 0)
hubLabel.Position = UDim2.new(0, 0, 0.52, 0)
hubLabel.BackgroundTransparency = 1
hubLabel.Text = "HUB"
hubLabel.Font = Enum.Font.GothamBold
hubLabel.TextScaled = true
hubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hubLabel.Parent = frame

-- Rainbow + Flash logic
local rainbowActive = true
local flashActive = true
local hue = 0

-- Rainbow color cycling
task.spawn(function()
	while rainbowActive do
		hue = (hue + 1) % 360
		local color = Color3.fromHSV(hue / 360, 1, 1)
		lightLabel.TextColor3 = color
		hubLabel.TextColor3 = color
		task.wait(0.03)
	end
end)

-- Flashing effect
task.spawn(function()
	while flashActive do
		lightLabel.Visible = not lightLabel.Visible
		hubLabel.Visible = not hubLabel.Visible
		task.wait(0.35)
	end
	lightLabel.Visible = true
	hubLabel.Visible = true
end)

-- After 8 seconds, stop flashing and slide out
task.wait(8)

flashActive = false
rainbowActive = false
task.wait(0.1)
lightLabel.Visible = true
hubLabel.Visible = true

-- Slide LIGHT left, HUB right
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local lightTween = TweenService:Create(lightLabel, tweenInfo, {
	Position = UDim2.new(-1.2, 0, 0.25, 0)
})
local hubTween = TweenService:Create(hubLabel, tweenInfo, {
	Position = UDim2.new(1.2, 0, 0.52, 0)
})

lightTween:Play()
hubTween:Play()

task.wait(0.9)
screenGui:Destroy()

-- =====================
-- PART 2: OVERHEAD GUI
-- =====================

task.spawn(function()
	-- Wait for character
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "OverheadTag"
	billboardGui.Size = UDim2.new(0, 220, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
	billboardGui.AlwaysOnTop = false
	billboardGui.Adornee = head
	billboardGui.Parent = head

	local tagLabel = Instance.new("TextLabel")
	tagLabel.Size = UDim2.new(1, 0, 1, 0)
	tagLabel.BackgroundTransparency = 1
	tagLabel.Text = ".gg/UpeQbF32qj"
	tagLabel.Font = Enum.Font.GothamBold
	tagLabel.TextScaled = true
	tagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	tagLabel.TextStrokeTransparency = 0.4
	tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	tagLabel.Parent = billboardGui

	-- Rainbow on overhead tag too
	local tagHue = 0
	while true do
		tagHue = (tagHue + 1) % 360
		tagLabel.TextColor3 = Color3.fromHSV(tagHue / 360, 1, 1)
		task.wait(0.03)
	end
end)
