-- LocalScript (place inside StarterPlayerScripts or StarterGui)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
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

-- LIGHT label (starts invisible and small for swell-in)
local lightLabel = Instance.new("TextLabel")
lightLabel.Size = UDim2.new(0.01, 0, 0.01, 0)
lightLabel.Position = UDim2.new(0.5, 0, 0.33, 0)
lightLabel.AnchorPoint = Vector2.new(0.5, 0.5)
lightLabel.BackgroundTransparency = 1
lightLabel.Text = "LIGHT"
lightLabel.Font = Enum.Font.GothamBlack
lightLabel.TextScaled = true
lightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lightLabel.TextStrokeTransparency = 0.1
lightLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
lightLabel.TextTransparency = 1
lightLabel.ZIndex = 10
lightLabel.Parent = screenGui

-- HUB label (starts invisible and small for swell-in)
local hubLabel = Instance.new("TextLabel")
hubLabel.Size = UDim2.new(0.01, 0, 0.01, 0)
hubLabel.Position = UDim2.new(0.5, 0, 0.63, 0)
hubLabel.AnchorPoint = Vector2.new(0.5, 0.5)
hubLabel.BackgroundTransparency = 1
hubLabel.Text = "HUB"
hubLabel.Font = Enum.Font.GothamBlack
hubLabel.TextScaled = true
hubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hubLabel.TextStrokeTransparency = 0.1
hubLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hubLabel.TextTransparency = 1
hubLabel.ZIndex = 10
hubLabel.Parent = screenGui

-- =====================
-- SWELL IN ANIMATION
-- =====================

-- LIGHT swells in first
TweenService:Create(lightLabel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0.95, 0, 0.24, 0),
	TextTransparency = 0,
}):Play()

-- HUB swells in slightly after
task.delay(0.2, function()
	TweenService:Create(hubLabel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.95, 0, 0.24, 0),
		TextTransparency = 0,
	}):Play()
end)

-- =====================
-- TYPEWRITER SOUND
-- =====================

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://6042053626"
sound.Volume = 1.0
sound.Looped = true
sound.Parent = SoundService
sound:Play()

task.delay(4.5, function()
	TweenService:Create(sound, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
end)

task.delay(6.1, function()
	sound:Stop()
	sound:Destroy()
end)

-- =====================
-- RAINBOW + FLASH (starts after swell finishes)
-- =====================

local rainbowActive = true
local flashActive   = true
local hue = 0

task.delay(0.85, function()
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

local slideOut = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

TweenService:Create(lightLabel, slideOut, {
	Position = UDim2.new(-0.6, 0, 0.33, 0)
}):Play()

TweenService:Create(hubLabel, slideOut, {
	Position = UDim2.new(1.6, 0, 0.63, 0)
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
