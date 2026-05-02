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
-- SOUND
-- =====================

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://6042053626"
sound.Volume = 0.35
sound.Looped = true
sound.Parent = SoundService
sound:Play()

task.delay(4.5, function()
	TweenService:Create(sound, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
end)

task.delay(6.5, function()
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
		hubLabel.TextColor3   = color
		task.wait(0.03)
	end
end)

-- =====================
-- INTENSE FLICKER HELPER (blocking — waits until done)
-- =====================

local function flickerIn(label, flashes, speed)
	for i = 1, flashes do
		label.Visible = false
		task.wait(speed)
		label.Visible = true
		task.wait(speed)
	end
end

-- =====================
-- PHASE 1: SPELL "LIGHT" FULLY, THEN "HUB" FULLY
-- Each letter flickers intensely on reveal, blocking so order is guaranteed
-- =====================

local lightWord = "LIGHT"
local hubWord   = "HUB"

lightLabel.Visible = true
hubLabel.Visible   = true

-- Spell L I G H T  one letter at a time, each with flicker
for i = 1, #lightWord do
	lightLabel.Text = string.sub(lightWord, 1, i)
	flickerIn(lightLabel, 5, 0.04)   -- 5 rapid flashes, blocking
	task.wait(0.18)                   -- brief settle before next letter
end

-- LIGHT is now fully spelled — short pause so it reads clearly
task.wait(0.45)

-- NOW spell H U B
for i = 1, #hubWord do
	hubLabel.Text = string.sub(hubWord, 1, i)
	flickerIn(hubLabel, 5, 0.04)
	task.wait(0.18)
end

-- Both fully spelled — pause so player reads it
task.wait(0.4)

-- =====================
-- PHASE 2: INTENSE STROBE, RAMPING FASTER (2 seconds)
-- =====================

local fastFlashActive = true
local flashSpeed = 0.12

task.spawn(function()
	for i = 1, 40 do
		flashSpeed = 0.12 - (i / 40) * 0.09  -- ramps from 0.12 to 0.03
		task.wait(0.05)
	end
end)

task.spawn(function()
	while fastFlashActive do
		lightLabel.Visible = false
		hubLabel.Visible   = false
		task.wait(flashSpeed)
		lightLabel.Visible = true
		hubLabel.Visible   = true
		task.wait(flashSpeed)
	end
end)

task.wait(2)

-- =====================
-- STOP FLASH, PAUSE, SLIDE OUT
-- =====================

fastFlashActive = false
rainbowActive   = false

task.wait(0.05)
lightLabel.Visible = true
hubLabel.Visible   = true
task.wait(0.2)

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
