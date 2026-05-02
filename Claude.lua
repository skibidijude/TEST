-- LocalScript (place inside StarterPlayerScripts or StarterGui)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =====================
-- INTRO SCREEN
-- =====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightHubIntro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- LIGHT label
local lightLabel = Instance.new("TextLabel")
lightLabel.Size = UDim2.new(0.95, 0, 0.24, 0)
lightLabel.Position = UDim2.new(0.5, 0, 0.33, 0)
lightLabel.AnchorPoint = Vector2.new(0.5, 0.5)
lightLabel.BackgroundTransparency = 1
lightLabel.Text = ""
lightLabel.Font = Enum.Font.GothamBlack
lightLabel.TextScaled = true
lightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lightLabel.TextStrokeTransparency = 0.1
lightLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
lightLabel.ZIndex = 10
lightLabel.Parent = screenGui

-- HUB label
local hubLabel = Instance.new("TextLabel")
hubLabel.Size = UDim2.new(0.95, 0, 0.24, 0)
hubLabel.Position = UDim2.new(0.5, 0, 0.63, 0)
hubLabel.AnchorPoint = Vector2.new(0.5, 0.5)
hubLabel.BackgroundTransparency = 1
hubLabel.Text = ""
hubLabel.Font = Enum.Font.GothamBlack
hubLabel.TextScaled = true
hubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hubLabel.TextStrokeTransparency = 0.1
hubLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hubLabel.ZIndex = 10
hubLabel.Parent = screenGui

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

task.delay(6.2, function()
	sound:Stop()
	sound:Destroy()
end)

-- =====================
-- RAINBOW CYCLE
-- =====================

local hue = 0
local rainbowActive = true

task.spawn(function()
	while rainbowActive do
		hue = (hue + 1) % 360
		local color = Color3.fromHSV(hue / 360, 1, 1)
		lightLabel.TextColor3 = color
		hubLabel.TextColor3 = color
		task.wait(0.03)
	end
end)

-- =====================
-- PHASE 1: TYPE IN LETTER BY LETTER (3 seconds total)
-- Both words typed simultaneously, letter by letter, slow
-- =====================

local lightWord = "LIGHT"
local hubWord   = "HUB"
local maxLetters = math.max(#lightWord, #hubWord)
local typeDelay = 3 / maxLetters  -- spread across 3 seconds

-- Flash while typing
local flashActive = true
local flashSpeed = 0.35

task.spawn(function()
	while flashActive do
		lightLabel.Visible = not lightLabel.Visible
		hubLabel.Visible   = not hubLabel.Visible
		task.wait(flashSpeed)
	end
	lightLabel.Visible = true
	hubLabel.Visible   = true
end)

-- Type letters in slowly
for i = 1, maxLetters do
	lightLabel.Text = string.sub(lightWord, 1, math.min(i, #lightWord))
	hubLabel.Text   = string.sub(hubWord,   1, math.min(i, #hubWord))
	task.wait(typeDelay)
end

-- =====================
-- PHASE 2: FAST FLASH for 2 seconds
-- =====================

flashSpeed = 0.35

-- Gradually speed up flash over 2 seconds
task.spawn(function()
	local steps = 20
	local elapsed = 0
	local duration = 2
	while elapsed < duration and flashActive do
		local t = elapsed / duration
		flashSpeed = 0.35 - (t * 0.28) -- goes from 0.35 down to 0.07
		elapsed = elapsed + 0.1
		task.wait(0.1)
	end
end)

task.wait(2)

-- =====================
-- STOP FLASH, THEN SLIDE OUT
-- =====================

flashActive = false
task.wait(0.05)
lightLabel.Visible = true
hubLabel.Visible   = true
rainbowActive = false

-- Small pause so last frame looks clean before slide
task.wait(0.15)

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
-- OVERHEAD TAG
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
