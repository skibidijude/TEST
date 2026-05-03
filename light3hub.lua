local FFlags = {

    GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,

    LargeReplicatorWrite5 = true,

    LargeReplicatorEnabled9 = true,

    AngularVelociryLimit = 360,

    TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,

    S2PhysicsSenderRate = 15000,

    DisableDPIScale = true,

    MaxDataPacketPerSend = 2147483647,

    PhysicsSenderMaxBandwidthBps = 20000,

    TimestepArbiterHumanoidLinearVelThreshold = 21,

    MaxMissedWorldStepsRemembered = -2147483648,

    PlayerHumanoidPropertyUpdateRestrict = true,

    SimDefaultHumanoidTimestepMultiplier = 0,

    StreamJobNOUVolumeLengthCap = 2147483647,

    DebugSendDistInSteps = -2147483648,

    GameNetDontSendRedundantNumTimes = 1,

    CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,

    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,

    LargeReplicatorSerializeRead3 = true,

    ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,

    CheckPVCachedVelThresholdPercent = 10,

    CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,

    GameNetDontSendRedundantDeltaPositionMillionth = 1,

    InterpolationFrameVelocityThresholdMillionth = 5,

    StreamJobNOUVolumeCap = 2147483647,

    InterpolationFrameRotVelocityThresholdMillionth = 5,

    CheckPVCachedRotVelThresholdPercent = 10,

    WorldStepMax = 30,

    InterpolationFramePositionThresholdMillionth = 5,

    TimestepArbiterHumanoidTurningVelThreshold = 1,

    SimOwnedNOUCountThresholdMillionth = 2147483647,

    GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,

    NextGenReplicatorEnabledWrite4 = true,

    TimestepArbiterOmegaThou = 1073741823,

    MaxAcceptableUpdateDelay = 1,

    LargeReplicatorSerializeWrite4 = true

}

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function respawnar(plr)

    local rcdEnabled, wasHidden = false, false

    if gethidden then

        rcdEnabled, wasHidden = gethidden(workspace, 'RejectCharacterDeletions')

            ~= Enum.RejectCharacterDeletions.Disabled

    end

    if rcdEnabled and replicatesignal then

        replicatesignal(plr.ConnectDiedSignalBackend)

        task.wait(Players.RespawnTime - 0.1)

        replicatesignal(plr.Kill)

    else

        local char = plr.Character

        local hum = char:FindFirstChildWhichIsA('Humanoid')

        if hum then

            hum:ChangeState(Enum.HumanoidStateType.Dead)

        end

        char:ClearAllChildren()

        local newChar = Instance.new('Model')

        newChar.Parent = workspace

        plr.Character = newChar

        task.wait()

        plr.Character = char

        newChar:Destroy()

    end

end

for name, value in pairs(FFlags) do

    pcall(function()

        setfflag(tostring(name), tostring(value))

    end)

end

respawnar(player)
task.wait(5)
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

local oldHub = workspace:FindFirstChild("Tokinu Hub")
if oldHub then
    oldHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Tokinu Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 175)
Frame.Position = UDim2.new(0, 40, 0, 60)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.4
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 14)
FrameCorner.Parent = Frame

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 38, 0, 38)
Logo.Position = UDim2.new(0, 12, 0, 8)
Logo.BackgroundTransparency = 1
Logo.Image = "http://www.roblox.com/asset/?id=18347450507"
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 32)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "tokinu - not main instant steal"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = Frame

local StealButton = Instance.new("TextButton")
StealButton.Size = UDim2.new(1, -30, 0, 70)
StealButton.Position = UDim2.new(0, 15, 0.5, -45)
StealButton.Text = "instant stel"
StealButton.TextColor3 = Color3.fromRGB(50, 200, 255)
StealButton.Font = Enum.Font.FredokaOne
StealButton.TextSize = 22
StealButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StealButton.BackgroundTransparency = 0.3
StealButton.AutoButtonColor = false
StealButton.Parent = Frame

local StealButtonCorner = Instance.new("UICorner")
StealButtonCorner.CornerRadius = UDim.new(0, 12)
StealButtonCorner.Parent = StealButton

local StealButtonGradient = Instance.new("UIGradient")
StealButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))
})
StealButtonGradient.Rotation = 90
StealButtonGradient.Parent = StealButton

local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Size = UDim2.new(1, -30, 0, 20)
DiscordLabel.Position = UDim2.new(0, 15, 0, 130)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "discord.gg/tokinu"
DiscordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.TextSize = 13
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Center
DiscordLabel.Parent = Frame

local promptConnection = ProximityPromptService.PromptButtonHoldEnded:Connect(function(value)
end)
