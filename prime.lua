 
repeat task.wait() until game:IsLoaded()
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
 
if not getgenv then getgenv = function() return _G end end
 
local ConfigFileName = "PrimeDuels_Config.json"
 
local Enabled = {
	SpeedBoost = false,
	AntiRagdoll = false,
	SpinBot = false,
	SpeedWhileStealing = false,
	AutoGrab = false,
	Unwalk = false,
	Optimizer = false,
	Galaxy = false,
	SpamBat = false,
	BatAimbot = false,
	AutoDisableSpeed = true,
	GalaxySkyBright = false,
	AutoWalkEnabled = false,
	AutoRightEnabled = false,
	ScriptUserESP = true,
	ESPPlayers = true,
	NoClipPlayers = false,
	Float = false,
	Medusa = false,
}
 
local Values = {
	GUISize = 100,
	BoostSpeed = 60.38,
	SpinSpeed = 30,
	StealingSpeedValue = 30.46,
	STEAL_RADIUS = 8,
	MEDUSA_RADIUS = 20,
	STEAL_DURATION = 0.2,
	DEFAULT_GRAVITY = 196.2,
	GalaxyGravityPercent = 70,
	HOP_POWER = 35,
	HOP_COOLDOWN = 0.08,
}
 
local KEYBINDS = {
	SPEED         = Enum.KeyCode.V,
	SPIN          = Enum.KeyCode.Zero,
	BATAIMBOT     = Enum.KeyCode.X,
	AUTORIGHT     = Enum.KeyCode.Z,
	AUTOWALK      = Enum.KeyCode.G,
	SPAMBOT       = Enum.KeyCode.J,
	SPEEDSTEAL    = Enum.KeyCode.F,
	NOCLIPPLAYERS = Enum.KeyCode.H,
	FLOAT         = Enum.KeyCode.T,
	DROPBRAINROT  = Enum.KeyCode.P,
	MEDUSA        = Enum.KeyCode.M,
}
 
local configLoaded = false
pcall(function()
	if readfile and isfile and isfile(ConfigFileName) then
		local data = HttpService:JSONDecode(readfile(ConfigFileName))
		if data then
			for k, v in pairs(data) do
				if Enabled[k] ~= nil then Enabled[k] = v end
				if Values[k]   ~= nil then Values[k]  = v end
			end
			if data.KEY_SPEED         then KEYBINDS.SPEED         = Enum.KeyCode[data.KEY_SPEED]         end
			if data.KEY_SPIN          then KEYBINDS.SPIN          = Enum.KeyCode[data.KEY_SPIN]          end
			if data.KEY_BATAIMBOT     then KEYBINDS.BATAIMBOT     = Enum.KeyCode[data.KEY_BATAIMBOT]     end
			if data.KEY_AUTORIGHT     then KEYBINDS.AUTORIGHT     = Enum.KeyCode[data.KEY_AUTORIGHT]     end
			if data.KEY_AUTOWALK      then KEYBINDS.AUTOWALK      = Enum.KeyCode[data.KEY_AUTOWALK]      end
			if data.KEY_SPAMBOT       then KEYBINDS.SPAMBOT       = Enum.KeyCode[data.KEY_SPAMBOT]       end
			if data.KEY_SPEEDSTEAL    then KEYBINDS.SPEEDSTEAL    = Enum.KeyCode[data.KEY_SPEEDSTEAL]    end
			if data.KEY_NOCLIPPLAYERS then KEYBINDS.NOCLIPPLAYERS = Enum.KeyCode[data.KEY_NOCLIPPLAYERS] end
			if data.KEY_FLOAT         then KEYBINDS.FLOAT         = Enum.KeyCode[data.KEY_FLOAT]         end
			if data.KEY_DROPBRAINROT  then KEYBINDS.DROPBRAINROT  = Enum.KeyCode[data.KEY_DROPBRAINROT]  end
			if data.KEY_MEDUSA        then KEYBINDS.MEDUSA        = Enum.KeyCode[data.KEY_MEDUSA]          end
			configLoaded = true
		end
	end
end)
 
local function SaveConfig()
	local data = {}
	for k, v in pairs(Enabled) do data[k] = v end
	for k, v in pairs(Values)  do data[k] = v end
	data.KEY_SPEED         = KEYBINDS.SPEED.Name
	data.KEY_SPIN          = KEYBINDS.SPIN.Name
	data.KEY_BATAIMBOT     = KEYBINDS.BATAIMBOT.Name
	data.KEY_AUTORIGHT     = KEYBINDS.AUTORIGHT.Name
	data.KEY_AUTOWALK      = KEYBINDS.AUTOWALK.Name
	data.KEY_SPAMBOT       = KEYBINDS.SPAMBOT.Name
	data.KEY_SPEEDSTEAL    = KEYBINDS.SPEEDSTEAL.Name
	data.KEY_NOCLIPPLAYERS = KEYBINDS.NOCLIPPLAYERS.Name
	data.KEY_FLOAT         = KEYBINDS.FLOAT.Name
	data.KEY_DROPBRAINROT  = KEYBINDS.DROPBRAINROT.Name
	data.KEY_MEDUSA        = KEYBINDS.MEDUSA.Name
	local ok = false
	if writefile then
		pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(data)); ok = true end)
	end
	return ok
end
 
local Connections = {}
 
local function waitForCharacter()
	local char = Player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then return char end
	return Player.CharacterAdded:Wait()
end
task.spawn(waitForCharacter)
 
local function getMovementDirection()
	local c = Player.Character; if not c then return Vector3.zero end
	local hum = c:FindFirstChildOfClass("Humanoid")
	return hum and hum.MoveDirection or Vector3.zero
end
 
local SlapList = {
	{1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},
	{5,"Diamond Slap"},{6,"Emerald Slap"},{7,"Ruby Slap"},
	{8,"Dark Matter Slap"},{9,"Flame Slap"},{10,"Nuclear Slap"},
	{11,"Galaxy Slap"},{12,"Glitched Slap"},
}
 
local function findBat()
	local c = Player.Character
	local bp = Player:FindFirstChildOfClass("Backpack")
	if not c then return nil end
	for _, ch in ipairs(c:GetChildren()) do
		if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
	end
	if bp then
		for _, ch in ipairs(bp:GetChildren()) do
			if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
		end
	end
	for _, i in ipairs(SlapList) do
		local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
		if t then return t end
	end
end
 
local function playSound(id, vol, spd)
	pcall(function()
		local s = Instance.new("Sound", SoundService)
		s.SoundId = id; s.Volume = vol or 0.3; s.PlaybackSpeed = spd or 1
		s:Play(); game:GetService("Debris"):AddItem(s, 1)
	end)
end
 
-- ============================================================
-- POSICOES AUTO WALK
-- ============================================================
local POSITION_L1     = Vector3.new(-476.48, -6.28,  92.73)
local POSITION_LEND   = Vector3.new(-483.12, -4.95,  94.80)
local POSITION_LFINAL = Vector3.new(-473.38, -8.40,  22.34)
local POSITION_R1     = Vector3.new(-476.16, -6.52,  25.62)
local POSITION_REND   = Vector3.new(-483.04, -5.09,  23.14)
local POSITION_RFINAL = Vector3.new(-476.17, -7.91,  97.91)
local FSPD = 60.36
local RSPD = 30.46
local ESPD = 30.46
 
-- ============================================================
-- DROP BRAINROT
-- ============================================================
local function doDropBrainrot()
	local c = Player.Character
	local h = c and c:FindFirstChild("HumanoidRootPart")
	if not h then return end
	task.spawn(function()
		for i = 1, 3 do
			if h and h.Parent then
				h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 120, h.AssemblyLinearVelocity.Z)
			end
			task.wait()
		end
		while h and h.Parent and h.AssemblyLinearVelocity.Y > 0 do
			task.wait()
		end
		if not h or not h.Parent then return end
		local conn
		conn = RunService.Heartbeat:Connect(function()
			if not h or not h.Parent then conn:Disconnect(); return end
			local char = Player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then conn:Disconnect(); return end
			local rayResult = workspace:Raycast(
				h.Position,
				Vector3.new(0, -10, 0),
				RaycastParams.new()
			)
			local distToGround = rayResult and rayResult.Distance or 999
			if distToGround <= 3.5 then
				h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 0, h.AssemblyLinearVelocity.Z)
				conn:Disconnect()
			else
				h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, -120, h.AssemblyLinearVelocity.Z)
			end
		end)
	end)
end
 
-- ============================================================
-- TP MULTI-STEP
-- ============================================================
local TP_MIDDLE = Vector3.new(-472.60, -7.00, 57.52)
local TP_L1     = Vector3.new(-483.59, -5.04, 104.24)
local TP_R1     = Vector3.new(-483.51, -5.10,  18.89)
local TP_LB     = Vector3.new(-472.65, -7.00,  95.69)
local TP_RB     = Vector3.new(-471.76, -7.00,  26.22)
 
local function tpStep(pos)
	local c = Player.Character; if not c then return end
	local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
	h.CFrame = CFrame.new(pos)
	h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
 
local function doTPLeft()
	task.spawn(function()
		tpStep(TP_MIDDLE); task.wait(0.08)
		tpStep(TP_LB);     task.wait(0.08)
		tpStep(TP_L1)
	end)
end
 
local function doTPRight()
	task.spawn(function()
		tpStep(TP_MIDDLE); task.wait(0.08)
		tpStep(TP_RB);     task.wait(0.08)
		tpStep(TP_R1)
	end)
end
 
-- ============================================================
-- SPEED BOOST
-- ============================================================
local function startSpeedBoost()
	if Connections.speed then return end
	Connections.speed = RunService.Heartbeat:Connect(function()
		if not Enabled.SpeedBoost and not Enabled.SpeedWhileStealing then return end
		pcall(function()
			local c = Player.Character; if not c then return end
			local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
			if AutoWalkEnabled or AutoRightEnabled then return end
			local md = getMovementDirection()
			if md.Magnitude > 0.1 then
				local spd
				if Enabled.SpeedWhileStealing and Player:GetAttribute("Stealing") then
					spd = Values.StealingSpeedValue
				elseif Enabled.SpeedBoost then
					spd = Values.BoostSpeed
				end
				if spd then
					h.AssemblyLinearVelocity = Vector3.new(
						md.X * spd,
						h.AssemblyLinearVelocity.Y,
						md.Z * spd
					)
				end
			end
		end)
	end)
end
 
local function stopSpeedBoost()
	if Connections.speed then Connections.speed:Disconnect(); Connections.speed = nil end
end
 
-- ============================================================
-- SPEED WHILE STEALING
-- ============================================================
local function startSpeedWhileStealing()
	if not Connections.speed then startSpeedBoost() end
end
 
local function stopSpeedWhileStealing()
	if not Enabled.SpeedBoost and not Enabled.SpeedWhileStealing then
		stopSpeedBoost()
	end
end
 
-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
local tpSelectedPos = nil
local _lastRagdollTP = 0
local ragConns = {}
local lastVelAR = Vector3.new()
 
local function ragClean(char)
	if not char then char = Player.Character end
	if not char then return end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("NoCollisionConstraint") then
			pcall(function() v:Destroy() end)
		elseif v:IsA("Motor6D") then
			v.Enabled = true
		end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		local anim = hum:FindFirstChildOfClass("Animator")
		if anim then
			for _, t in pairs(anim:GetPlayingAnimationTracks()) do
				local n = (t.Animation and t.Animation.Name or ""):lower()
				if n:find("rag") or n:find("fall") or n:find("hurt") then t:Stop(0) end
			end
		end
	end
end
 
local function startAntiRagdoll()
	for _, c in pairs(ragConns) do pcall(function() c:Disconnect() end) end
	ragConns = {}
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	table.insert(ragConns, hum.StateChanged:Connect(function(_, new)
		if not Enabled.AntiRagdoll then return end
		if new == Enum.HumanoidStateType.Ragdoll
			or new == Enum.HumanoidStateType.FallingDown
			or new == Enum.HumanoidStateType.Physics then
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			workspace.CurrentCamera.CameraSubject = hum
			pcall(function()
				local pm = Player.PlayerScripts:FindFirstChild("PlayerModule")
				if pm then require(pm:FindFirstChild("ControlModule")):Enable() end
			end)
			ragClean(char)
			local now = tick()
			if (now - _lastRagdollTP) > 1 then
				_lastRagdollTP = now
				if tpSelectedPos == "LEFT" then
					task.delay(0.05, doTPLeft)
				elseif tpSelectedPos == "RIGHT" then
					task.delay(0.05, doTPRight)
				end
			end
		end
	end))
	table.insert(ragConns, RunService.Heartbeat:Connect(function()
		if not Enabled.AntiRagdoll then return end
		local c = Player.Character; if not c then return end
		local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
		local vel = hrp.AssemblyLinearVelocity
		if (vel - lastVelAR).Magnitude > 40 and vel.Magnitude > 25 then
			hrp.AssemblyLinearVelocity = vel.Unit * 15
		end
		lastVelAR = vel
		ragClean(c)
	end))
end
 
local function stopAntiRagdoll()
	for _, c in pairs(ragConns) do pcall(function() c:Disconnect() end) end
	ragConns = {}
end
 
-- ============================================================
-- SPIN BOT
-- ============================================================
local spinBAV = nil
local function startSpinBot()
	local c = Player.Character; if not c then return end
	local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	if spinBAV then spinBAV:Destroy(); spinBAV = nil end
	spinBAV = Instance.new("BodyAngularVelocity")
	spinBAV.Name = "SpinBAV"; spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
	spinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0); spinBAV.Parent = hrp
end
local function stopSpinBot()
	if spinBAV then spinBAV:Destroy(); spinBAV = nil end
	local c = Player.Character
	if c then
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if hrp then for _, v in ipairs(hrp:GetChildren()) do if v.Name == "SpinBAV" then v:Destroy() end end end
	end
end
RunService.Heartbeat:Connect(function()
	if Enabled.SpinBot and spinBAV then
		spinBAV.AngularVelocity = Vector3.new(0, Player:GetAttribute("Stealing") and 0 or Values.SpinSpeed, 0)
	end
end)
 
-- ============================================================
-- SPAM BAT
-- ============================================================
local lastBatSwing = 0
local BAT_SWING_COOLDOWN = 0.12
local function startSpamBat()
	if Connections.spamBat then return end
	Connections.spamBat = RunService.Heartbeat:Connect(function()
		if not Enabled.SpamBat then return end
		local c = Player.Character; if not c then return end
		local bat = findBat(); if not bat then return end
		if bat.Parent ~= c then bat.Parent = c end
		local now = tick()
		if now - lastBatSwing < BAT_SWING_COOLDOWN then return end
		lastBatSwing = now
		pcall(function() bat:Activate() end)
	end)
end
local function stopSpamBat()
	if Connections.spamBat then Connections.spamBat:Disconnect(); Connections.spamBat = nil end
end
 
 
-- ============================================================
-- BAT AIMBOT
-- ============================================================
local aimbotTarget   = nil
local lastAimbotSwing = 0
local AIMBOT_SWING_COOLDOWN = 0.08
local AIMBOT_SWING_DIST     = 4.5
local AIMBOT_STICK_DIST     = 3.5
 
local function findNearestEnemy(myHRP)
	local nearest, nearestDist, nearestTorso = nil, math.huge, nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player and p.Character then
			local eh    = p.Character:FindFirstChild("HumanoidRootPart")
			local torso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
			local hum   = p.Character:FindFirstChildOfClass("Humanoid")
			if eh and hum and hum.Health > 0 then
				local d = (eh.Position - myHRP.Position).Magnitude
				if d < nearestDist then
					nearestDist = d; nearest = eh; nearestTorso = torso or eh
				end
			end
		end
	end
	return nearest, nearestDist, nearestTorso
end
 
local function startBatAimbot()
	if Connections.batAimbot then return end
	Connections.batAimbot = RunService.Heartbeat:Connect(function()
		if not Enabled.BatAimbot then return end
		local c = Player.Character; if not c then return end
		local h   = c:FindFirstChild("HumanoidRootPart")
		local hum = c:FindFirstChildOfClass("Humanoid")
		if not h or not hum then return end
 
		local bat = findBat()
		if bat and bat.Parent ~= c then
			pcall(function() hum:EquipTool(bat) end)
		end
 
		local target, dist, torso = findNearestEnemy(h)
		aimbotTarget = torso or target
		if not target or not torso then return end
 
		local targetPos = torso.Position
		local dir    = targetPos - h.Position
		local flat   = Vector3.new(dir.X, 0, dir.Z)
		local flatDist = flat.Magnitude
 
		if flatDist > AIMBOT_SWING_DIST then
			local spd = math.max(Values.BoostSpeed, 55)
			local md  = flat.Unit
			h.AssemblyLinearVelocity = Vector3.new(
				md.X * spd,
				h.AssemblyLinearVelocity.Y,
				md.Z * spd
			)
		else
			local tv   = target.AssemblyLinearVelocity
			local pull = flat.Magnitude > 0.1 and (flat.Unit * (flatDist / AIMBOT_SWING_DIST) * 18) or Vector3.zero
			h.AssemblyLinearVelocity = Vector3.new(
				tv.X + pull.X,
				h.AssemblyLinearVelocity.Y,
				tv.Z + pull.Z
			)
 
			local now = tick()
			if bat and now - lastAimbotSwing >= AIMBOT_SWING_COOLDOWN then
				lastAimbotSwing = now
				if bat.Parent ~= c then
					pcall(function() hum:EquipTool(bat) end)
				end
				pcall(function() bat:Activate() end)
			end
		end
	end)
end
 
local function stopBatAimbot()
	if Connections.batAimbot then
		Connections.batAimbot:Disconnect(); Connections.batAimbot = nil
	end
	aimbotTarget = nil
end
 
 
-- ============================================================
-- GALAXY / INF JUMP
-- ============================================================
local galaxyVectorForce, galaxyAttachment
local galaxyEnabled = false
local hopsEnabled = false
local originalJumpPower = 50
 
local function captureJumpPower()
	local c = Player.Character
	if c then
		local hum = c:FindFirstChildOfClass("Humanoid")
		if hum and hum.JumpPower > 0 then originalJumpPower = hum.JumpPower end
	end
end
task.spawn(function() task.wait(1); captureJumpPower() end)
Player.CharacterAdded:Connect(function() task.wait(1); captureJumpPower() end)
 
local function setupGalaxyForce()
	pcall(function()
		local c = Player.Character
		local h = c and c:FindFirstChild("HumanoidRootPart"); if not h then return end
		if galaxyVectorForce then galaxyVectorForce:Destroy() end
		if galaxyAttachment  then galaxyAttachment:Destroy()  end
		galaxyAttachment = Instance.new("Attachment"); galaxyAttachment.Parent = h
		galaxyVectorForce = Instance.new("VectorForce")
		galaxyVectorForce.Attachment0 = galaxyAttachment
		galaxyVectorForce.ApplyAtCenterOfMass = true
		galaxyVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
		galaxyVectorForce.Force = Vector3.zero
		galaxyVectorForce.Parent = h
	end)
end
 
local function updateGalaxyForce()
	if not galaxyEnabled or not galaxyVectorForce then return end
	local c = Player.Character; if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
	local mass = 0
	for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then mass = mass + p:GetMass() end end
	local cancelRatio = 1 - (Values.GalaxyGravityPercent / 100)
	local targetForce = mass * Values.DEFAULT_GRAVITY * cancelRatio
	local current = galaxyVectorForce.Force.Y
	local smooth = current + (targetForce - current) * 0.25
	galaxyVectorForce.Force = Vector3.new(0, smooth, 0)
end
 
local function adjustGalaxyJump()
	pcall(function()
		local c = Player.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid"); if not hum then return end
		if not galaxyEnabled then hum.JumpPower = originalJumpPower; return end
		local ratio = math.sqrt((Values.DEFAULT_GRAVITY * (Values.GalaxyGravityPercent/100)) / Values.DEFAULT_GRAVITY)
		hum.JumpPower = originalJumpPower * ratio
	end)
end
 
UserInputService.JumpRequest:Connect(function()
	if not galaxyEnabled or not hopsEnabled then return end
	local c = Player.Character; if not c then return end
	local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
	h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, Values.HOP_POWER, h.AssemblyLinearVelocity.Z)
end)
 
local function startGalaxy()
	galaxyEnabled = true; hopsEnabled = true; setupGalaxyForce(); adjustGalaxyJump()
end
local function stopGalaxy()
	galaxyEnabled = false; hopsEnabled = false
	if galaxyVectorForce then galaxyVectorForce:Destroy(); galaxyVectorForce = nil end
	if galaxyAttachment  then galaxyAttachment:Destroy();  galaxyAttachment = nil  end
	adjustGalaxyJump()
end
 
RunService.Heartbeat:Connect(function()
	if not galaxyEnabled then return end
	updateGalaxyForce()
end)
 
-- ============================================================
-- MISC
-- ============================================================
local savedAnimations = {}
local function startUnwalk()
	local c = Player.Character
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
	local anim = c and c:FindFirstChild("Animate")
	if anim then savedAnimations.Animate = anim:Clone(); anim:Destroy() end
end
local function stopUnwalk()
	local c = Player.Character
	if c and savedAnimations.Animate then
		savedAnimations.Animate:Clone().Parent = c; savedAnimations.Animate = nil
	end
end
 
local originalTransparency = {}
local xrayEnabled = false
local function enableOptimizer()
	if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
	if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		Lighting.GlobalShadows = false; Lighting.Brightness = 3; Lighting.FogEnd = 9e9
	end)
	pcall(function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			pcall(function()
				if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
				elseif obj:IsA("BasePart") then obj.CastShadow = false; obj.Material = Enum.Material.Plastic end
			end)
		end
	end)
	xrayEnabled = true
	pcall(function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Anchored and
				(obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
				originalTransparency[obj] = obj.LocalTransparencyModifier
				obj.LocalTransparencyModifier = 0.85
			end
		end
	end)
end
local function disableOptimizer()
	if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
	if xrayEnabled then
		for part, value in pairs(originalTransparency) do
			if part then part.LocalTransparencyModifier = value end
		end
		originalTransparency = {}; xrayEnabled = false
	end
end
 
local originalSkybox, galaxySkyBright, galaxySkyBrightConn
local galaxyPlanets = {}
local galaxyBloom, galaxyCC
local function enableGalaxySkyBright()
	if galaxySkyBright then return end
	originalSkybox = Lighting:FindFirstChildOfClass("Sky")
	if originalSkybox then originalSkybox.Parent = nil end
	galaxySkyBright = Instance.new("Sky")
	for _, face in ipairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do
		galaxySkyBright["Skybox"..face] = "rbxassetid://1534951537"
	end
	galaxySkyBright.StarCount = 10000; galaxySkyBright.CelestialBodiesShown = false
	galaxySkyBright.Parent = Lighting
	galaxyBloom = Instance.new("BloomEffect"); galaxyBloom.Intensity = 1.5
	galaxyBloom.Size = 40; galaxyBloom.Threshold = 0.8; galaxyBloom.Parent = Lighting
	galaxyCC = Instance.new("ColorCorrectionEffect"); galaxyCC.Saturation = 0.8
	galaxyCC.Contrast = 0.3; galaxyCC.TintColor = Color3.fromRGB(180,80,255); galaxyCC.Parent = Lighting
	Lighting.Ambient = Color3.fromRGB(120,60,180); Lighting.Brightness = 3; Lighting.ClockTime = 0
	for i = 1, 2 do
		local p = Instance.new("Part"); p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(800+i*200,800+i*200,800+i*200); p.Anchored = true
		p.CanCollide = false; p.CastShadow = false; p.Material = Enum.Material.Neon
		p.Color = Color3.fromRGB(140+i*20,60+i*10,200+i*15); p.Transparency = 0.3
		p.Position = Vector3.new(math.cos(i*2)*(3000+i*500),1500+i*300,math.sin(i*2)*(3000+i*500))
		p.Parent = workspace; table.insert(galaxyPlanets, p)
	end
	galaxySkyBrightConn = RunService.Heartbeat:Connect(function()
		if not Enabled.GalaxySkyBright then return end
		local t = tick() * 0.5
		Lighting.Ambient = Color3.fromRGB(120+math.sin(t)*60, 50+math.sin(t*0.8)*40, 180+math.sin(t*1.2)*50)
		if galaxyBloom then galaxyBloom.Intensity = 1.2+math.sin(t*2)*0.4 end
	end)
end
local function disableGalaxySkyBright()
	if galaxySkyBrightConn then galaxySkyBrightConn:Disconnect(); galaxySkyBrightConn = nil end
	if galaxySkyBright then galaxySkyBright:Destroy(); galaxySkyBright = nil end
	if originalSkybox then originalSkybox.Parent = Lighting end
	if galaxyBloom then galaxyBloom:Destroy(); galaxyBloom = nil end
	if galaxyCC    then galaxyCC:Destroy();    galaxyCC = nil    end
	for _, obj in ipairs(galaxyPlanets) do if obj then obj:Destroy() end end
	galaxyPlanets = {}
	Lighting.Ambient = Color3.fromRGB(127,127,127); Lighting.Brightness = 2; Lighting.ClockTime = 14
end
 
-- ============================================================
-- PROGRESS BAR (vars declaradas antes do uso)
-- ============================================================
local ProgressBarFill, ProgressLabel, ProgressPercentLabel
local function ResetProgressBar()
	if ProgressLabel        then ProgressLabel.Text = "READY" end
	if ProgressPercentLabel then ProgressPercentLabel.Text = "" end
	if ProgressBarFill      then ProgressBarFill.Size = UDim2.new(0,0,1,0) end
end
 
local function isMyPlotByName(pn)
	local plots = workspace:FindFirstChild("Plots"); if not plots then return false end
	local plot = plots:FindFirstChild(pn); if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign"); if not sign then return false end
	local yb = sign:FindFirstChild("YourBase")
	if yb and yb:IsA("BillboardGui") then return yb.Enabled end
	return false
end
 
local function findNearestPrompt()
	local char = Player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
	local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil
	local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
	for _, plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end
		local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then continue end
		for _, pod in ipairs(podiums:GetChildren()) do
			pcall(function()
				local base = pod:FindFirstChild("Base")
				local spawnPart = base and base:FindFirstChild("Spawn")
				if spawnPart then
					local dist = (spawnPart.Position - hrp.Position).Magnitude
					if dist < nearestDist and dist <= Values.STEAL_RADIUS then
						for _, child in ipairs(spawnPart:GetDescendants()) do
							if child:IsA("ProximityPrompt") and child.Enabled then
								nearestPrompt = child; nearestDist = dist; nearestName = pod.Name; break
							end
						end
					end
				end
			end)
		end
	end
	return nearestPrompt, nearestDist, nearestName
end
 
-- ============================================================
-- AUTO GRAB
-- ============================================================
local stealCache = {}
local isStealing = false
 
local function buildCallbacks(prompt)
	if stealCache[prompt] then return end
	local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
	local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
	if ok1 and type(c1) == "table" then
		for _, conn in ipairs(c1) do
			if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
		end
	end
	local ok2, c2 = pcall(getconnections, prompt.Triggered)
	if ok2 and type(c2) == "table" then
		for _, conn in ipairs(c2) do
			if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
		end
	end
	if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then stealCache[prompt] = data end
end
 
local function execSteal(prompt, name)
	local data = stealCache[prompt]
	if not data or not data.ready then return false end
	data.ready = false; isStealing = true
	if ProgressLabel  then ProgressLabel.Text = name or "GRABBING..." end
	if ProgressBarFill then ProgressBarFill.Size = UDim2.new(1, 0, 1, 0) end
	task.spawn(function()
		for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
		task.wait(0.2)
		for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
		task.wait(0.05)
		data.ready = true; isStealing = false
		ResetProgressBar(); stealCache[prompt] = nil
	end)
	return true
end
 
local function startAutoGrab()
	if Connections.autoGrab then return end
	Connections.autoGrab = RunService.Heartbeat:Connect(function()
		if not Enabled.AutoGrab or isStealing then return end
		local char = Player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			local s = hum:GetState()
			if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown or
				s == Enum.HumanoidStateType.Physics then return end
		end
		local prompt, _, animalName = findNearestPrompt()
		if prompt then buildCallbacks(prompt); execSteal(prompt, animalName) end
	end)
end
local function stopAutoGrab()
	if Connections.autoGrab then Connections.autoGrab:Disconnect(); Connections.autoGrab = nil end
	isStealing = false; ResetProgressBar(); stealCache = {}
end
 
-- ============================================================
-- AUTO WALK / AUTO RIGHT
-- ============================================================
local lastAutoRoute   = "L"
local AutoWalkEnabled = Enabled.AutoWalkEnabled
local AutoRightEnabled = Enabled.AutoRightEnabled
local autoWalkConn, autoRightConn
local aplPhase, aprPhase = 1, 1
local VisualSetters = {}
 
local function getHRP() local c = Player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = Player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
 
local _speedWasActiveBeforeAuto = false
local _speedStealWasActiveBeforeAuto = false
local _spamBatWasActiveBeforeAuto = false
 
local function _disableSpeedForAuto()
	if Enabled.SpeedBoost then
		_speedWasActiveBeforeAuto = true; Enabled.SpeedBoost = false; stopSpeedBoost()
		if VisualSetters.SpeedBoost then VisualSetters.SpeedBoost(false, true) end
	else _speedWasActiveBeforeAuto = false end
	if Enabled.SpeedWhileStealing then
		_speedStealWasActiveBeforeAuto = true; Enabled.SpeedWhileStealing = false; stopSpeedWhileStealing()
		if VisualSetters.SpeedWhileStealing then VisualSetters.SpeedWhileStealing(false, true) end
	else _speedStealWasActiveBeforeAuto = false end
	if Enabled.SpamBat then
		_spamBatWasActiveBeforeAuto = true; Enabled.SpamBat = false; stopSpamBat()
		if VisualSetters.SpamBat then VisualSetters.SpamBat(false, true) end
	else _spamBatWasActiveBeforeAuto = false end
end
 
local function _restoreSpeedAfterAuto()
	if _speedWasActiveBeforeAuto then
		_speedWasActiveBeforeAuto = false; Enabled.SpeedBoost = true; startSpeedBoost()
		if VisualSetters.SpeedBoost then VisualSetters.SpeedBoost(true, true) end
	end
	if _speedStealWasActiveBeforeAuto then
		_speedStealWasActiveBeforeAuto = false; Enabled.SpeedWhileStealing = true; startSpeedWhileStealing()
		if VisualSetters.SpeedWhileStealing then VisualSetters.SpeedWhileStealing(true, true) end
	end
	if _spamBatWasActiveBeforeAuto then
		_spamBatWasActiveBeforeAuto = false; Enabled.SpamBat = true; startSpamBat()
		if VisualSetters.SpamBat then VisualSetters.SpamBat(true, true) end
	end
end
 
local function stopAutoWalk()
	if autoWalkConn then autoWalkConn:Disconnect(); autoWalkConn = nil end
	aplPhase = 1
	local hum = getHum(); if hum then hum:Move(Vector3.zero, false) end
end
local function stopAutoRight()
	if autoRightConn then autoRightConn:Disconnect(); autoRightConn = nil end
	aprPhase = 1
	local hum = getHum(); if hum then hum:Move(Vector3.zero, false) end
end
 
local LOOK_OUT = Vector3.new(1, 0, 0)
 
local function startAutoWalk()
	if autoWalkConn then autoWalkConn:Disconnect() end
	aplPhase = 1; _disableSpeedForAuto()
	lastAutoRoute = "L"
	autoWalkConn = RunService.Heartbeat:Connect(function()
		if not AutoWalkEnabled then return end
		local h, hum = getHRP(), getHum(); if not h or not hum then return end
		if aplPhase == 1 then
			local d = Vector3.new(POSITION_L1.X-h.Position.X,0,POSITION_L1.Z-h.Position.Z)
			if d.Magnitude < 1 then aplPhase = 2; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*FSPD, h.AssemblyLinearVelocity.Y, md.Z*FSPD)
		elseif aplPhase == 2 then
			local d = Vector3.new(POSITION_LEND.X-h.Position.X,0,POSITION_LEND.Z-h.Position.Z)
			if d.Magnitude < 1 then aplPhase = 3; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*FSPD, h.AssemblyLinearVelocity.Y, md.Z*FSPD)
		elseif aplPhase == 0 then return
		elseif aplPhase == 3 then
			local d = Vector3.new(POSITION_L1.X-h.Position.X,0,POSITION_L1.Z-h.Position.Z)
			if d.Magnitude < 1 then aplPhase = 4; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*ESPD, h.AssemblyLinearVelocity.Y, md.Z*ESPD)
		elseif aplPhase == 4 then
			local d = Vector3.new(POSITION_LFINAL.X-h.Position.X,0,POSITION_LFINAL.Z-h.Position.Z)
			if d.Magnitude < 1 then
				hum:Move(Vector3.zero,false); h.AssemblyLinearVelocity = Vector3.zero
				AutoWalkEnabled = false; Enabled.AutoWalkEnabled = false
				if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(false, true) end
				stopAutoWalk(); _restoreSpeedAfterAuto(); return
			end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*RSPD, h.AssemblyLinearVelocity.Y, md.Z*RSPD)
		end
	end)
end
 
local function startAutoRight()
	if autoRightConn then autoRightConn:Disconnect() end
	aprPhase = 1; _disableSpeedForAuto()
	lastAutoRoute = "R"
	autoRightConn = RunService.Heartbeat:Connect(function()
		if not AutoRightEnabled then return end
		local h, hum = getHRP(), getHum(); if not h or not hum then return end
		if aprPhase == 1 then
			local d = Vector3.new(POSITION_R1.X-h.Position.X,0,POSITION_R1.Z-h.Position.Z)
			if d.Magnitude < 1 then aprPhase = 2; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*FSPD, h.AssemblyLinearVelocity.Y, md.Z*FSPD)
		elseif aprPhase == 2 then
			local d = Vector3.new(POSITION_REND.X-h.Position.X,0,POSITION_REND.Z-h.Position.Z)
			if d.Magnitude < 1 then aprPhase = 3; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*FSPD, h.AssemblyLinearVelocity.Y, md.Z*FSPD)
		elseif aprPhase == 0 then return
		elseif aprPhase == 3 then
			local d = Vector3.new(POSITION_R1.X-h.Position.X,0,POSITION_R1.Z-h.Position.Z)
			if d.Magnitude < 1 then aprPhase = 4; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*ESPD, h.AssemblyLinearVelocity.Y, md.Z*ESPD)
		elseif aprPhase == 4 then
			local d = Vector3.new(POSITION_RFINAL.X-h.Position.X,0,POSITION_RFINAL.Z-h.Position.Z)
			if d.Magnitude < 1 then
				hum:Move(Vector3.zero,false); h.AssemblyLinearVelocity = Vector3.zero
				AutoRightEnabled = false; Enabled.AutoRightEnabled = false
				if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(false, true) end
				stopAutoRight(); _restoreSpeedAfterAuto(); return
			end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*RSPD, h.AssemblyLinearVelocity.Y, md.Z*RSPD)
		end
	end)
end
 
-- ============================================================
-- NUKE
-- ============================================================
local ADMIN_KEY = "78a772b6-9e1c-4827-ab8b-04a07838f298"
local REMOTE_EVENT_ID = "352aad58-c786-4998-886b-3e4fa390721e"
local BALLOON_REMOTE = ReplicatedStorage:FindFirstChild(REMOTE_EVENT_ID, true)
local function INSTANT_NUKE(target)
	if not BALLOON_REMOTE or not target then return end
	for _, p in ipairs({"balloon","ragdoll","jumpscare","morph","tiny","rocket","inverse","jail"}) do
		BALLOON_REMOTE:FireServer(ADMIN_KEY, target, p)
	end
end
 
-- ============================================================
-- ESP
-- ============================================================
local espHighlights = {}
local function updateESP()
	if not Enabled.ESPPlayers then
		for _, h in pairs(espHighlights) do if h then h:Destroy() end end
		espHighlights = {}; return
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player and p.Character then
			if not espHighlights[p.Name] or not espHighlights[p.Name].Parent then
				local hl = Instance.new("Highlight")
				hl.Name = "PDESP"; hl.FillColor = Color3.fromRGB(255,255,255)
				hl.OutlineColor = Color3.fromRGB(150,60,255); hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Parent = p.Character; espHighlights[p.Name] = hl
			end
		end
	end
	for name, hl in pairs(espHighlights) do
		if not Players:FindFirstChild(name) then if hl then hl:Destroy() end; espHighlights[name] = nil end
	end
end
RunService.Heartbeat:Connect(updateESP)
Players.PlayerRemoving:Connect(function(p)
	if espHighlights[p.Name] then espHighlights[p.Name]:Destroy(); espHighlights[p.Name] = nil end
end)
 
local coordFolder = Instance.new("Folder", workspace); coordFolder.Name = "PD_CoordESP"
local function makeMarker(pos, label, color)
	local dot = Instance.new("Part", coordFolder)
	dot.Anchored = true; dot.CanCollide = false; dot.CastShadow = false
	dot.Material = Enum.Material.Neon; dot.Color = color
	dot.Shape = Enum.PartType.Ball; dot.Size = Vector3.one; dot.Position = pos; dot.Transparency = 0.2
	local bb = Instance.new("BillboardGui", dot)
	bb.AlwaysOnTop = true; bb.Size = UDim2.new(0,100,0,20); bb.StudsOffset = Vector3.new(0,2,0); bb.MaxDistance = 300
	local tl = Instance.new("TextLabel", bb)
	tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = label; tl.TextColor3 = color
	tl.TextStrokeColor3 = Color3.new(0,0,0); tl.TextStrokeTransparency = 0
	tl.Font = Enum.Font.GothamBold; tl.TextSize = 12
end
makeMarker(POSITION_L1,    "L1",    Color3.fromRGB(200,150,255))
makeMarker(POSITION_LEND,  "L END", Color3.fromRGB(180,120,240))
makeMarker(POSITION_LFINAL,"L FIN", Color3.fromRGB(160,100,220))
makeMarker(POSITION_R1,    "R1",    Color3.fromRGB(200,150,255))
makeMarker(POSITION_REND,  "R END", Color3.fromRGB(180,120,240))
makeMarker(POSITION_RFINAL,"R FIN", Color3.fromRGB(160,100,220))
 
-- ============================================================
-- SPEED BILLBOARD
-- ============================================================
local speedBB = nil
local function makeSpeedBB()
	local char = Player.Character; if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	if speedBB then speedBB:Destroy() end
	speedBB = Instance.new("BillboardGui")
	speedBB.Name = "PDSpeedBB"; speedBB.Adornee = hrp
	speedBB.Size = UDim2.new(0, 120, 0, 36); speedBB.StudsOffset = Vector3.new(0, 4.5, 0)
	speedBB.AlwaysOnTop = true; speedBB.Parent = hrp
	local lbl = Instance.new("TextLabel")
	lbl.Name = "SpeedLbl"; lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(180, 100, 255)
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0); lbl.TextStrokeTransparency = 0
	lbl.Font = Enum.Font.GothamBlack; lbl.TextScaled = true
	lbl.Text = "Speed: 0"; lbl.Parent = speedBB
end
Player.CharacterAdded:Connect(function() task.wait(0.5); makeSpeedBB() end)
if Player.Character then makeSpeedBB() end
RunService.Heartbeat:Connect(function()
	local char = Player.Character; if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	if not speedBB or not speedBB.Parent then makeSpeedBB() end
	local lbl = speedBB and speedBB:FindFirstChild("SpeedLbl"); if not lbl then return end
	local vel = hrp.AssemblyLinearVelocity
	lbl.Text = "Speed: " .. string.format("%.2f", Vector3.new(vel.X, 0, vel.Z).Magnitude)
end)
 
-- ============================================================
-- NOCLIP PLAYERS
-- ============================================================
local noClipConn = nil
local function startNoClipPlayers()
	if noClipConn then return end
	noClipConn = RunService.Heartbeat:Connect(function()
		if not Enabled.NoClipPlayers then return end
		local myChar = Player.Character; if not myChar then return end
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Player and p.Character then
				for _, myPart in ipairs(myChar:GetDescendants()) do
					if myPart:IsA("BasePart") then
						for _, theirPart in ipairs(p.Character:GetDescendants()) do
							if theirPart:IsA("BasePart") then
								pcall(function()
									local nc = workspace:FindFirstChild("PDNC_"..myPart.Name.."_"..theirPart.Name)
									if not nc then
										nc = Instance.new("NoCollisionConstraint")
										nc.Name = "PDNC_"..myPart.Name.."_"..theirPart.Name
										nc.Part0 = myPart; nc.Part1 = theirPart; nc.Parent = workspace
									end
								end)
							end
						end
					end
				end
			end
		end
	end)
end
local function stopNoClipPlayers()
	if noClipConn then noClipConn:Disconnect(); noClipConn = nil end
	for _, v in ipairs(workspace:GetChildren()) do
		if v:IsA("NoCollisionConstraint") and v.Name:sub(1,4) == "PDNC" then v:Destroy() end
	end
end
 
-- ============================================================
-- FLOAT
-- ============================================================
local floatFixedY, floatBF, floatAtt, floatConn = nil, nil, nil, nil
 
local function startFloat()
	local c = Player.Character
	local hrp = c and c:FindFirstChild("HumanoidRootPart")
	floatFixedY = hrp and (hrp.Position.Y + 8) or 8
	floatConn = RunService.Heartbeat:Connect(function()
		if not Enabled.Float then return end
		local c2 = Player.Character; if not c2 then return end
		local hrp2 = c2:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end
		local hum = c2:FindFirstChildOfClass("Humanoid")
		if not floatBF or not floatBF.Parent then
			if floatAtt then floatAtt:Destroy() end
			if floatBF  then floatBF:Destroy()  end
			floatAtt = Instance.new("Attachment"); floatAtt.Parent = hrp2
			floatBF = Instance.new("VectorForce")
			floatBF.Attachment0 = floatAtt; floatBF.ApplyAtCenterOfMass = true
			floatBF.RelativeTo = Enum.ActuatorRelativeTo.World; floatBF.Parent = hrp2
		end
		local mass = 0
		for _, p in ipairs(c2:GetDescendants()) do
			if p:IsA("BasePart") then mass = mass + p:GetMass() end
		end
		local diff = floatFixedY - hrp2.Position.Y
		local gravCancel = mass * workspace.Gravity
		local correction = mass * diff * 18
		local damping = -hrp2.AssemblyLinearVelocity.Y * mass * 6
		floatBF.Force = Vector3.new(0, gravCancel + correction + damping, 0)
		if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false) end
	end)
end
 
local function stopFloat()
	if floatConn then floatConn:Disconnect(); floatConn = nil end
	if floatBF   then floatBF:Destroy();  floatBF = nil  end
	if floatAtt  then floatAtt:Destroy(); floatAtt = nil end
	floatFixedY = nil
	local c = Player.Character
	if c then
		local hum = c:FindFirstChildOfClass("Humanoid")
		if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end
	end
end
 
Player.CharacterAdded:Connect(function()
	task.wait(1)
	if Enabled.Float then stopFloat(); startFloat() end
	if Enabled.NoClipPlayers then stopNoClipPlayers(); startNoClipPlayers() end
end)
 
 
-- ============================================================
-- MEDUSA
-- ============================================================
local medusaConn     = nil
local medusaPhase    = 1
local medusaCooldown = false
local medusaWasInRange = false
 
local MEDUSA_DETECT_RADIUS = 20
Values.MEDUSA_RADIUS = MEDUSA_DETECT_RADIUS
 
local function findMedusaTool()
	local c  = Player.Character
	local bp = Player:FindFirstChildOfClass("Backpack")
	if c  then for _,ch in ipairs(c:GetChildren())  do if ch:IsA("Tool") and ch.Name=="Medusa' Head" then return ch end end end
	if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name=="Medusa' Head" then return ch end end end
	return nil
end
 
local function findNearestPlayerInRadius(radius)
	local hrp = getHRP(); if not hrp then return nil end
	local nearest, nearestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player and p.Character then
			local eh  = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if eh and hum and hum.Health > 0 then
				local d = (eh.Position - hrp.Position).Magnitude
				if d < nearestDist and d <= radius then nearestDist = d; nearest = p end
			end
		end
	end
	return nearest
end
 
local function startMedusa()
	if medusaConn then medusaConn:Disconnect(); medusaConn = nil end
	medusaPhase      = 1
	medusaCooldown   = false
	medusaWasInRange = false
 
	local P1, PEND, PFINAL
	if lastAutoRoute == "R" then
		P1 = POSITION_R1; PEND = POSITION_REND; PFINAL = POSITION_RFINAL
	else
		P1 = POSITION_L1; PEND = POSITION_LEND; PFINAL = POSITION_LFINAL
	end
 
	medusaConn = RunService.Heartbeat:Connect(function()
		if not Enabled.Medusa then return end
		local c = Player.Character; if not c then return end
		local h, hum = getHRP(), getHum(); if not h or not hum then return end
 
		local tool = findMedusaTool()
		if tool and tool.Parent ~= c then
			tool.Parent = c
		end
 
		local target = findNearestPlayerInRadius(MEDUSA_DETECT_RADIUS)
		local inRange = (target ~= nil)
		if inRange and not medusaWasInRange and not medusaCooldown and tool then
			medusaCooldown = true
			pcall(function() tool:Activate() end)
			task.delay(0.8, function() medusaCooldown = false end)
		end
		medusaWasInRange = inRange
 
		if medusaPhase == 1 then
			local d = Vector3.new(P1.X-h.Position.X, 0, P1.Z-h.Position.Z)
			if d.Magnitude < 1 then medusaPhase = 2; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*FSPD, h.AssemblyLinearVelocity.Y, md.Z*FSPD)
		elseif medusaPhase == 2 then
			local d = Vector3.new(PEND.X-h.Position.X, 0, PEND.Z-h.Position.Z)
			if d.Magnitude < 1 then medusaPhase = 3; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*FSPD, h.AssemblyLinearVelocity.Y, md.Z*FSPD)
		elseif medusaPhase == 3 then
			local d = Vector3.new(P1.X-h.Position.X, 0, P1.Z-h.Position.Z)
			if d.Magnitude < 1 then medusaPhase = 4; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*RSPD, h.AssemblyLinearVelocity.Y, md.Z*RSPD)
		elseif medusaPhase == 4 then
			local d = Vector3.new(PFINAL.X-h.Position.X, 0, PFINAL.Z-h.Position.Z)
			if d.Magnitude < 1 then medusaPhase = 1; return end
			local md = d.Unit; hum:Move(md, false)
			h.AssemblyLinearVelocity = Vector3.new(md.X*RSPD, h.AssemblyLinearVelocity.Y, md.Z*RSPD)
		end
	end)
end
 
local function stopMedusa()
	if medusaConn then medusaConn:Disconnect(); medusaConn = nil end
	medusaPhase = 1; medusaCooldown = false; medusaWasInRange = false
	local hum = getHum(); if hum then hum:Move(Vector3.zero, false) end
end
 
-- ============================================================
-- CORES GUI — Prime Duels (roxo/violeta)
-- ============================================================
local C_BG      = Color3.fromRGB(0, 0, 0)      -- fundo principal preto
local C_BG2     = Color3.fromRGB(25, 25, 25)      -- fundo secundário
local C_BG3     = Color3.fromRGB(30, 30, 30)      -- fundo terciário
local C_ITEM    = Color3.fromRGB(20, 20, 20)      -- fundo de cada item
local C_CYAN    = Color3.fromRGB(0, 0, 0)    -- roxo vivo (cor principal)
local C_CYAN2   = Color3.fromRGB(0, 0, 0)    -- roxo escuro
local C_CYANLO  = Color3.fromRGB(255, 255, 255)     -- roxo muito escuro
local C_WHITE   = Color3.fromRGB(255, 255, 255)   -- branco
local C_GREY    = Color3.fromRGB(180, 180, 180)   -- cinza
local C_GREY2   = Color3.fromRGB(60, 60, 60)      -- cinza muito escuro
local C_RED     = Color3.fromRGB(220, 50, 60)     -- vermelho STOP
local C_OFF     = Color3.fromRGB(60, 60, 60)      -- toggle off roxo
local C_BORDER  = Color3.fromRGB(255, 255, 255)    -- borda roxa
local C_PINK=C_CYAN; local C_PINKDIM=C_CYAN2; local C_SEC=C_CYAN
 
local SliderSetters = {}
local KeyButtons    = {}
local waitingForKey = nil
local tpLeftSetSel, tpRightSetSel = nil, nil
local grabCircle    = nil
local guiVisible    = true
local sg, main, scroll
local VisualSetters = {}
local floatPanels   = {}
 
-- ============================================================
-- DRAG UNIVERSAL (mouse + touch mobile)
-- ============================================================
local function makeDraggable(frame, handle)
	handle = handle or frame
	handle.Active = true
	local dragging = false
	local dragStart, startPos
 
	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end
 
	local function moveDrag(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
 
	handle.InputBegan:Connect(beginDrag)
	handle.InputChanged:Connect(moveDrag)
	UserInputService.InputChanged:Connect(moveDrag)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
 
local function addGrad(frame, c0, c1)
    local g = Instance.new("UIGradient", frame)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0),
        ColorSequenceKeypoint.new(1, c1)
    })
    g.Rotation = 90
end
 
-- ============================================================
do -- JANELA (Prime Duels — tema roxo)
-- ============================================================
    sg = Instance.new("ScreenGui")
    sg.Name="PrimeDuels"; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset=true
    sg.Parent=Player.PlayerGui
 
    -- Botão ≡
    local menuBtn=Instance.new("TextButton",sg)
    menuBtn.Size=UDim2.new(0,56,0,56)
    menuBtn.Position=UDim2.new(1,-68,0,14)
    menuBtn.BackgroundColor3=C_CYAN
    menuBtn.BorderSizePixel=0; menuBtn.ZIndex=20; menuBtn.Active=true
    menuBtn.Text="≡"; menuBtn.TextColor3=C_WHITE
    menuBtn.Font=Enum.Font.GothamBlack; menuBtn.TextSize=28
    Instance.new("UICorner",menuBtn).CornerRadius=UDim.new(0,14)
    makeDraggable(menuBtn,menuBtn)
    menuBtn.MouseButton1Click:Connect(function()
        guiVisible=not guiVisible; main.Visible=guiVisible
    end)
 
    -- Painel principal
    main=Instance.new("Frame",sg)
    main.Name="Main"
    main.Size=UDim2.new(0,260,0,420)
    main.Position=UDim2.new(0,10,0,80)
    main.BackgroundColor3=C_BG
    main.BackgroundTransparency=0
    main.BorderSizePixel=0
    main.Active=true; main.Draggable=false; main.ClipsDescendants=true
    Instance.new("UICorner",main).CornerRadius=UDim.new(0,16)
    do
        local s=Instance.new("UIStroke",main)
        s.Color=C_CYAN; s.Thickness=1.5; s.Transparency=0.55
    end
 
    -- Header
    local header=Instance.new("Frame",main)
    header.Size=UDim2.new(1,0,0,52); header.Position=UDim2.new(0,0,0,0)
    header.BackgroundColor3=C_BG2; header.BorderSizePixel=0; header.ZIndex=4; header.Active=true
    Instance.new("UICorner",header).CornerRadius=UDim.new(0,16)
    do
        local hfix=Instance.new("Frame",header)
        hfix.Size=UDim2.new(1,0,0.5,0); hfix.Position=UDim2.new(0,0,0.5,0)
        hfix.BackgroundColor3=C_BG2; hfix.BorderSizePixel=0; hfix.ZIndex=3
        local ht=Instance.new("TextLabel",header)
        ht.Size=UDim2.new(1,-50,1,0); ht.Position=UDim2.new(0,16,0,0)
        ht.BackgroundTransparency=1; ht.Text="Prime Duels"
        ht.TextColor3=C_WHITE; ht.Font=Enum.Font.GothamBlack
        ht.TextSize=20; ht.TextXAlignment=Enum.TextXAlignment.Left; ht.ZIndex=5
        local cb=Instance.new("TextButton",header)
        cb.Size=UDim2.new(0,32,0,32); cb.Position=UDim2.new(1,-42,0.5,-16)
        cb.BackgroundColor3=Color3.fromRGB(50,22,26); cb.BorderSizePixel=0
        cb.Text="×"; cb.TextColor3=C_WHITE
        cb.Font=Enum.Font.GothamBlack; cb.TextSize=18; cb.ZIndex=6
        Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
        local cs=Instance.new("UIStroke",cb)
        cs.Color=C_RED; cs.Thickness=1.2; cs.Transparency=0.4
        cb.MouseButton1Click:Connect(function() main.Visible=false end)
    end
 
    -- Linha separadora
    do
        local hl=Instance.new("Frame",main)
        hl.Size=UDim2.new(1,0,0,1); hl.Position=UDim2.new(0,0,0,52)
        hl.BackgroundColor3=C_BORDER; hl.BorderSizePixel=0; hl.ZIndex=4; hl.BackgroundTransparency=0.5
    end
 
    -- Barra de abas
    local tabBar=Instance.new("Frame",main)
    tabBar.Size=UDim2.new(1,-16,0,34); tabBar.Position=UDim2.new(0,8,0,57)
    tabBar.BackgroundColor3=C_BG3; tabBar.BorderSizePixel=0; tabBar.ZIndex=3
    Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,10)
    do
        local tl=Instance.new("UIListLayout",tabBar)
        tl.FillDirection=Enum.FillDirection.Horizontal
        tl.SortOrder=Enum.SortOrder.LayoutOrder; tl.Padding=UDim.new(0,2)
        local tp=Instance.new("UIPadding",tabBar)
        tp.PaddingLeft=UDim.new(0,3); tp.PaddingRight=UDim.new(0,3)
        tp.PaddingTop=UDim.new(0,3); tp.PaddingBottom=UDim.new(0,3)
    end
 
    -- Scroll
    scroll=Instance.new("ScrollingFrame",main)
    scroll.Size=UDim2.new(1,0,1,-100); scroll.Position=UDim2.new(0,0,0,100)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=C_CYAN
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.ZIndex=2; scroll.ClipsDescendants=true
    do
        local sl=Instance.new("UIListLayout",scroll)
        sl.SortOrder=Enum.SortOrder.LayoutOrder; sl.Padding=UDim.new(0,7)
        local sp=Instance.new("UIPadding",scroll)
        sp.PaddingLeft=UDim.new(0,10); sp.PaddingRight=UDim.new(0,10)
        sp.PaddingTop=UDim.new(0,8); sp.PaddingBottom=UDim.new(0,12)
    end
 
    local tabContents={}
    local tabBtns={}
 
    local function showTab(name)
        for _,child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child.Visible=false end
        end
        if tabContents[name] then
            for _,f in ipairs(tabContents[name]) do f.Visible=true end
        end
        for tname,btn in pairs(tabBtns) do
            if tname==name then
                btn.BackgroundColor3=C_CYAN
                btn.BackgroundTransparency=0
                btn.TextColor3=Color3.fromRGB(18,8,30)
            else
                btn.BackgroundTransparency=1
                btn.TextColor3=C_GREY
            end
        end
    end
 
    local function buildTabs()
        local names={"Combat","Protect","Visual","Settings","Keys"}
        local pw=math.floor((260-6)/#names)
        for i,tname in ipairs(names) do
            local tb=Instance.new("TextButton",tabBar)
            tb.Size=UDim2.new(0,pw,1,0)
            tb.BackgroundTransparency=1; tb.BorderSizePixel=0
            tb.Text=tname; tb.TextColor3=C_GREY
            tb.Font=Enum.Font.GothamBold; tb.TextSize=11
            tb.ZIndex=4; tb.LayoutOrder=i
            Instance.new("UICorner",tb).CornerRadius=UDim.new(0,8)
            tabBtns[tname]=tb
            tb.MouseButton1Click:Connect(function() showTab(tname) end)
        end
    end
    buildTabs()
 
    local function regTab(tabName,frame)
        if not tabContents[tabName] then tabContents[tabName]={} end
        table.insert(tabContents[tabName],frame)
        frame.Visible=false
    end
 
    local function buildKeyOverlay()
        local ko=Instance.new("Frame",sg)
        ko.Name="KeyOverlay"; ko.Size=UDim2.new(1,0,1,0)
        ko.BackgroundColor3=Color3.fromRGB(0,0,0)
        ko.BackgroundTransparency=0.5; ko.BorderSizePixel=0
        ko.ZIndex=100; ko.Visible=false
        local kb=Instance.new("Frame",ko)
        kb.Size=UDim2.new(0,260,0,84); kb.Position=UDim2.new(0.5,-130,0.5,-42)
        kb.BackgroundColor3=C_BG2; kb.BorderSizePixel=0; kb.ZIndex=101
        Instance.new("UICorner",kb).CornerRadius=UDim.new(0,14)
        local ks=Instance.new("UIStroke",kb)
        ks.Color=C_CYAN; ks.Thickness=1.5; ks.Transparency=0.3
        local kt=Instance.new("TextLabel",kb)
        kt.Size=UDim2.new(1,0,0,42); kt.Position=UDim2.new(0,0,0,8)
        kt.BackgroundTransparency=1; kt.Text="PRESSIONE UMA TECLA"
        kt.TextColor3=C_CYAN; kt.Font=Enum.Font.GothamBlack; kt.TextSize=15; kt.ZIndex=102
        local ksb=Instance.new("TextLabel",kb)
        ksb.Size=UDim2.new(1,0,0,24); ksb.Position=UDim2.new(0,0,0,52)
        ksb.BackgroundTransparency=1; ksb.Text="ESC para cancelar"
        ksb.TextColor3=C_GREY; ksb.Font=Enum.Font.GothamBold; ksb.TextSize=12; ksb.ZIndex=102
        _G.PD_showKeyOverlay=function(show) ko.Visible=show end
    end
    buildKeyOverlay()
 
    makeDraggable(main,header)
 
    task.defer(function() showTab("Combat") end)
    _G.PD_regTab=regTab
    _G.PD_scroll=scroll
    _G.PD_sg=sg
    _G.PD_addGrad=addGrad
end
 
-- ============================================================
do -- HELPERS
-- ============================================================
    local itemOrder=0
    local regTab=_G.PD_regTab
    local addGrad=_G.PD_addGrad
 
    local function nextOrder() itemOrder=itemOrder+1; return itemOrder end
 
    local function makeItem(tabName, h)
        local frame=Instance.new("Frame",scroll)
        frame.Size=UDim2.new(1,0,0,h or 56)
        frame.BackgroundColor3=C_ITEM
        frame.BorderSizePixel=0; frame.LayoutOrder=nextOrder(); frame.Visible=false
        Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
        local st=Instance.new("UIStroke",frame)
        st.Color=C_BORDER; st.Thickness=1.2; st.Transparency=0.6
        regTab(tabName,frame)
        return frame
    end
 
    local function mkSwitch(parent,eKey,cb)
        local on=Enabled[eKey] or false
        local tbg=Instance.new("Frame",parent)
        tbg.Size=UDim2.new(0,54,0,30); tbg.Position=UDim2.new(1,-64,0.5,-15)
        tbg.BackgroundColor3=on and C_CYAN or C_OFF
        tbg.BorderSizePixel=0; tbg.ZIndex=4
        Instance.new("UICorner",tbg).CornerRadius=UDim.new(1,0)
        local cir=Instance.new("Frame",tbg)
        cir.Size=UDim2.new(0,22,0,22)
        cir.Position=on and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,4,0.5,-11)
        cir.BackgroundColor3=C_WHITE; cir.BorderSizePixel=0; cir.ZIndex=5
        Instance.new("UICorner",cir).CornerRadius=UDim.new(1,0)
        local grad=nil
        local function setV(state,skip)
            on=state; Enabled[eKey]=state
            if state then
                tbg.BackgroundColor3=C_CYAN
                if not grad then grad=Instance.new("UIGradient",tbg) end
                grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C_CYAN),ColorSequenceKeypoint.new(1,C_CYAN2)})
                grad.Rotation=90
            else
                tbg.BackgroundColor3=C_OFF
                if grad then grad:Destroy(); grad=nil end
            end
            cir.Position=state and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,4,0.5,-11)
            if not skip and cb then cb(state) end
        end
        VisualSetters[eKey]=setV
        return setV,function() setV(not on) end
    end
 
    local function Toggle(tabName,label,eKey,cb)
        local frame=makeItem(tabName)
        local lb=Instance.new("TextLabel",frame)
        lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,14,0,0)
        lb.BackgroundTransparency=1; lb.Text=label; lb.TextColor3=C_WHITE
        lb.Font=Enum.Font.GothamSemibold; lb.TextSize=14
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=3
        local _,clickCb=mkSwitch(frame,eKey,cb)
        local ca=Instance.new("TextButton",frame)
        ca.Size=UDim2.new(1,0,1,0); ca.BackgroundTransparency=1; ca.Text=""; ca.ZIndex=6
        ca.MouseButton1Click:Connect(clickCb)
    end
 
    local function ToggleFloat(tabName,label,eKey,buildFn,cb)
        local frame=makeItem(tabName)
        local lb=Instance.new("TextLabel",frame)
        lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,14,0,0)
        lb.BackgroundTransparency=1; lb.Text=label; lb.TextColor3=C_WHITE
        lb.Font=Enum.Font.GothamSemibold; lb.TextSize=14
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=3
 
        local fp=Instance.new("Frame",sg)
        fp.BackgroundColor3=C_BG
        fp.BorderSizePixel=0; fp.Active=true; fp.Draggable=false
        fp.Visible=false; fp.ZIndex=30
        Instance.new("UICorner",fp).CornerRadius=UDim.new(0,14)
        local fpStroke=Instance.new("UIStroke",fp)
        fpStroke.Color=C_CYAN; fpStroke.Thickness=1.5; fpStroke.Transparency=0.4
 
        local fph=Instance.new("TextButton",fp)
        fph.Size=UDim2.new(1,0,0,44); fph.Position=UDim2.new(0,0,0,0)
        fph.BackgroundColor3=C_BG2; fph.BorderSizePixel=0; fph.Text=""; fph.ZIndex=31
        fph.Active=true
        Instance.new("UICorner",fph).CornerRadius=UDim.new(0,14)
        local fphFix=Instance.new("Frame",fph)
        fphFix.Size=UDim2.new(1,0,0.5,0); fphFix.Position=UDim2.new(0,0,0.5,0)
        fphFix.BackgroundColor3=C_BG2; fphFix.BorderSizePixel=0; fphFix.ZIndex=30
 
        local arrowLbl=Instance.new("TextLabel",fph)
        arrowLbl.Size=UDim2.new(0,24,1,0); arrowLbl.Position=UDim2.new(0,10,0,0)
        arrowLbl.BackgroundTransparency=1; arrowLbl.Text="▲"
        arrowLbl.TextColor3=C_CYAN; arrowLbl.Font=Enum.Font.GothamBold
        arrowLbl.TextSize=13; arrowLbl.ZIndex=32
 
        local fptitle=Instance.new("TextLabel",fph)
        fptitle.Size=UDim2.new(1,-34,1,0); fptitle.Position=UDim2.new(0,30,0,0)
        fptitle.BackgroundTransparency=1; fptitle.Text=label
        fptitle.TextColor3=C_WHITE; fptitle.Font=Enum.Font.GothamBold
        fptitle.TextSize=13; fptitle.TextXAlignment=Enum.TextXAlignment.Left; fptitle.ZIndex=32
 
        local fphLine=Instance.new("Frame",fp)
        fphLine.Size=UDim2.new(1,0,0,1); fphLine.Position=UDim2.new(0,0,0,44)
        fphLine.BackgroundColor3=C_BORDER; fphLine.BorderSizePixel=0; fphLine.ZIndex=33
        fphLine.BackgroundTransparency=0.55
 
        local fpBody=Instance.new("Frame",fp)
        fpBody.BackgroundTransparency=1; fpBody.BorderSizePixel=0; fpBody.ZIndex=31
        local fpLL=Instance.new("UIListLayout",fpBody)
        fpLL.SortOrder=Enum.SortOrder.LayoutOrder; fpLL.Padding=UDim.new(0,6)
        local fpPad=Instance.new("UIPadding",fpBody)
        fpPad.PaddingLeft=UDim.new(0,8); fpPad.PaddingRight=UDim.new(0,8)
        fpPad.PaddingTop=UDim.new(0,7); fpPad.PaddingBottom=UDim.new(0,9)
 
        if buildFn then buildFn(fpBody) end
 
        local fpCollapsed=false
        local function resizeFP()
            if fpCollapsed then
                fp.Size=UDim2.new(0,240,0,44)
                fpBody.Visible=false; fphLine.Visible=false; arrowLbl.Text="▶"
            else
                local bh=fpLL.AbsoluteContentSize.Y+18
                fp.Size=UDim2.new(0,240,0,44+1+bh)
                fpBody.Size=UDim2.new(1,0,0,bh)
                fpBody.Position=UDim2.new(0,0,0,46)
                fpBody.Visible=true; fphLine.Visible=true; arrowLbl.Text="▲"
            end
        end
        fpLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not fpCollapsed then resizeFP() end
        end)
        fph.MouseButton1Click:Connect(function() fpCollapsed=not fpCollapsed; resizeFP() end)
 
        makeDraggable(fp, fph)
 
        local fpIdx=#floatPanels+1
        fp.Position=UDim2.new(0,8,0,80+(fpIdx-1)*10)
        table.insert(floatPanels,fp)
 
        local _,clickCb=mkSwitch(frame,eKey,function(state)
            fp.Visible=state; if cb then cb(state) end
        end)
        fp.Visible=Enabled[eKey] or false
        local ca=Instance.new("TextButton",frame)
        ca.Size=UDim2.new(1,0,1,0); ca.BackgroundTransparency=1; ca.Text=""; ca.ZIndex=6
        ca.MouseButton1Click:Connect(clickCb)
        task.defer(resizeFP)
        return frame,fp,fpBody
    end
 
    local function Slider(parent,label,mn,mx,vKey,cb)
        local row=Instance.new("Frame",parent)
        row.Size=UDim2.new(1,0,0,52); row.BackgroundTransparency=1
        row.BorderSizePixel=0; row.LayoutOrder=nextOrder()
        local lb=Instance.new("TextLabel",row)
        lb.Size=UDim2.new(0.6,0,0,22); lb.Position=UDim2.new(0,0,0,2)
        lb.BackgroundTransparency=1; lb.Text=label; lb.TextColor3=C_GREY
        lb.Font=Enum.Font.GothamSemibold; lb.TextSize=12
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=3
        local dv=Values[vKey] or mn
        local vb=Instance.new("TextButton",row)
        vb.Size=UDim2.new(0,52,0,22); vb.Position=UDim2.new(1,-52,0,2)
        vb.BackgroundColor3=C_BG3; vb.BorderSizePixel=0
        vb.Text=tostring(dv); vb.TextColor3=C_CYAN
        vb.Font=Enum.Font.GothamBlack; vb.TextSize=12; vb.ZIndex=4
        Instance.new("UICorner",vb).CornerRadius=UDim.new(0,6)
        local vi=Instance.new("TextBox",row)
        vi.Size=UDim2.new(0,52,0,22); vi.Position=UDim2.new(1,-52,0,2)
        vi.BackgroundColor3=C_BG3; vi.BorderSizePixel=0; vi.Text=""
        vi.TextColor3=C_WHITE; vi.Font=Enum.Font.GothamBlack; vi.TextSize=12
        vi.ClearTextOnFocus=true; vi.ZIndex=5; vi.Visible=false
        Instance.new("UICorner",vi).CornerRadius=UDim.new(0,6)
        local tr=Instance.new("Frame",row)
        tr.Size=UDim2.new(1,0,0,6); tr.Position=UDim2.new(0,0,0,36)
        tr.BackgroundColor3=C_GREY2; tr.BorderSizePixel=0; tr.ZIndex=3
        Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
        local fl=Instance.new("Frame",tr)
        fl.Size=UDim2.new(math.clamp((dv-mn)/(mx-mn),0,1),0,1,0)
        fl.BackgroundColor3=C_CYAN; fl.BorderSizePixel=0; fl.ZIndex=4
        Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
        addGrad(fl,C_CYAN,C_CYAN2)
        local function apply(raw)
            local n=tonumber(raw); if not n then return end
            n=math.clamp(n,mn,mx)
            if not tostring(raw):find("%.") then n=math.floor(n) end
            vb.Text=tostring(n); Values[vKey]=n
            fl.Size=UDim2.new(math.clamp((n-mn)/(mx-mn),0,1),0,1,0)
            if cb then cb(n) end
        end
        vb.MouseButton1Click:Connect(function() vb.Visible=false;vi.Visible=true;vi.Text=vb.Text;vi:CaptureFocus() end)
        vi.FocusLost:Connect(function() apply(vi.Text);vi.Visible=false;vb.Visible=true end)
        vi:GetPropertyChangedSignal("Text"):Connect(function() vi.Text=vi.Text:gsub("[^%d%.%-]","") end)
        local drag=false
        local tb2=Instance.new("TextButton",tr)
        tb2.Size=UDim2.new(1,0,6,0); tb2.Position=UDim2.new(0,0,-2,0)
        tb2.BackgroundTransparency=1; tb2.Text=""; tb2.ZIndex=6
        tb2.MouseButton1Down:Connect(function() drag=true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or
               i.UserInputType==Enum.UserInputType.Touch then drag=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or
                         i.UserInputType==Enum.UserInputType.Touch) then
                local r=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
                local n=math.clamp(math.floor((mn+(mx-mn)*r)*10+0.5)/10,mn,mx)
                vb.Text=tostring(n);Values[vKey]=n;fl.Size=UDim2.new(r,0,1,0)
                if cb then cb(n) end
            end
        end)
        SliderSetters[vKey]=function(v)
            v=math.clamp(v,mn,mx); vb.Text=tostring(v); Values[vKey]=v
            fl.Size=UDim2.new(math.clamp((v-mn)/(mx-mn),0,1),0,1,0)
        end
        return row
    end
 
    local function BigBtn(parent,eKey,onStart,onStop)
        local row=Instance.new("Frame",parent)
        row.Size=UDim2.new(1,0,0,44); row.BackgroundTransparency=1
        row.BorderSizePixel=0; row.LayoutOrder=nextOrder()
        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.new(1,0,0,38); btn.Position=UDim2.new(0,0,0,3)
        btn.BorderSizePixel=0; btn.ZIndex=3
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
        local on=Enabled[eKey] or false
        local function refresh(state)
            if state then
                btn.BackgroundColor3=C_RED
                btn.Text="STOP"
            else
                btn.BackgroundColor3=C_CYAN
                btn.Text="ON"
            end
            btn.TextColor3=C_WHITE; btn.Font=Enum.Font.GothamBlack; btn.TextSize=15
        end
        refresh(on)
        VisualSetters[eKey]=function(v,_) on=v; refresh(v) end
        btn.MouseButton1Click:Connect(function()
            on=not on; Enabled[eKey]=on; refresh(on)
            if on then if onStart then onStart() end else if onStop then onStop() end end
        end)
        return row
    end
 
    local function FpLabel(parent,txt)
        local row=Instance.new("Frame",parent)
        row.Size=UDim2.new(1,0,0,20); row.BackgroundTransparency=1
        row.BorderSizePixel=0; row.LayoutOrder=nextOrder()
        local lb=Instance.new("TextLabel",row)
        lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
        lb.Text=txt; lb.TextColor3=C_GREY
        lb.Font=Enum.Font.GothamSemibold; lb.TextSize=11
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=3
    end
 
    local function KeyRow(tabName,label,kKey)
        local frame=makeItem(tabName,52)
        local lb=Instance.new("TextLabel",frame)
        lb.Size=UDim2.new(0.55,0,1,0); lb.Position=UDim2.new(0,14,0,0)
        lb.BackgroundTransparency=1; lb.Text=label; lb.TextColor3=C_WHITE
        lb.Font=Enum.Font.GothamSemibold; lb.TextSize=13
        lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=3
        local kb=Instance.new("TextButton",frame)
        kb.Size=UDim2.new(0,70,0,32); kb.Position=UDim2.new(1,-80,0.5,-16)
        kb.BackgroundColor3=C_CYANLO; kb.BorderSizePixel=0
        kb.Text=KEYBINDS[kKey] and KEYBINDS[kKey].Name or "?"
        kb.TextColor3=C_WHITE; kb.Font=Enum.Font.GothamBold; kb.TextSize=11; kb.ZIndex=10
        Instance.new("UICorner",kb).CornerRadius=UDim.new(0,8)
        local kst=Instance.new("UIStroke",kb)
        kst.Color=C_CYAN; kst.Thickness=1.2; kst.Transparency=0.35
        KeyButtons[kKey]=kb
        kb.MouseButton1Click:Connect(function()
            waitingForKey=kKey; kb.Text="..."
            kb.BackgroundColor3=C_CYAN
            if _G.PD_showKeyOverlay then _G.PD_showKeyOverlay(true) end
        end)
    end
 
    -- ============================================================
    -- LAYOUT
    -- ============================================================
 
    -- COMBAT
    ToggleFloat("Combat","Auto Play","AutoWalkEnabled",function(body)
        FpLabel(body,"Auto Left")
        BigBtn(body,"AutoWalkEnabled",
            function() AutoWalkEnabled=true;Enabled.AutoWalkEnabled=true;startAutoWalk() end,
            function() AutoWalkEnabled=false;Enabled.AutoWalkEnabled=false;stopAutoWalk();_restoreSpeedAfterAuto() end)
        FpLabel(body,"Auto Right")
        BigBtn(body,"AutoRightEnabled",
            function() AutoRightEnabled=true;Enabled.AutoRightEnabled=true;startAutoRight() end,
            function() AutoRightEnabled=false;Enabled.AutoRightEnabled=false;stopAutoRight();_restoreSpeedAfterAuto() end)
    end, nil)
 
    ToggleFloat("Combat","Speed Customizer","SpeedBoost",function(body)
        FpLabel(body,"Speed Boost")
        BigBtn(body,"SpeedBoost",function() startSpeedBoost() end,function() stopSpeedBoost() end)
        Slider(body,"Speed",1,70,"BoostSpeed",function(v) Values.BoostSpeed=v end)
        FpLabel(body,"Speed On Steal")
        BigBtn(body,"SpeedWhileStealing",function() startSpeedWhileStealing() end,function() stopSpeedWhileStealing() end)
        Slider(body,"Steal Spd",10,35,"StealingSpeedValue",function(v) Values.StealingSpeedValue=v end)
    end, nil)
 
    ToggleFloat("Combat","Lock","BatAimbot",function(body)
        FpLabel(body,"Lock (Auto Bat)")
        BigBtn(body,"BatAimbot",function() startBatAimbot() end,function() stopBatAimbot() end)
    end, nil)
 
    if Enabled.DropBrainrotFloat==nil then Enabled.DropBrainrotFloat=false end
    ToggleFloat("Combat","Drop","DropBrainrotFloat",function(body)
        FpLabel(body,"Drop Brainrot")
        local row=Instance.new("Frame",body)
        row.Size=UDim2.new(1,0,0,40); row.BackgroundTransparency=1
        row.BorderSizePixel=0; row.LayoutOrder=nextOrder()
        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.new(1,0,0,34); btn.Position=UDim2.new(0,0,0,3)
        btn.BorderSizePixel=0; btn.ZIndex=3
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
        btn.BackgroundColor3=C_RED; btn.Text="DROP"
        btn.TextColor3=C_WHITE; btn.Font=Enum.Font.GothamBlack; btn.TextSize=13
        local dg=Instance.new("UIGradient",btn); dg.Rotation=90
        dg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C_RED),ColorSequenceKeypoint.new(1,Color3.fromRGB(160,30,40))})
        btn.MouseButton1Click:Connect(function() doDropBrainrot() end)
    end, nil)
 
    Toggle("Combat","Auto Grab","AutoGrab",
        function(v) if v then startAutoGrab() else stopAutoGrab() end end)
    do
        local gr=Slider(scroll,"Grab Radius",1,100,"STEAL_RADIUS",function(v)
            Values.STEAL_RADIUS=v
            if grabCircle and grabCircle.Parent then grabCircle.Size=Vector3.new(0.15,v*2,v*2) end
        end)
        gr.Visible=false; regTab("Combat",gr)
    end
 
    -- PROTECT
    Toggle("Protect","Anti Ragdoll","AntiRagdoll",
        function(v) if v then startAntiRagdoll() else stopAntiRagdoll() end end)
    Toggle("Protect","NoClip Players","NoClipPlayers",
        function(v) if v then startNoClipPlayers() else stopNoClipPlayers() end end)
 
    -- VISUAL
    Toggle("Visual","ESP Players","ESPPlayers",function(v)
        Enabled.ESPPlayers=v
        if not v then for _,h in pairs(espHighlights) do if h then h:Destroy() end end; espHighlights={} end
    end)
    Toggle("Visual","No Anims","Unwalk",
        function(v) if v then startUnwalk() else stopUnwalk() end end)
    Toggle("Visual","Optimizer+XRay","Optimizer",
        function(v) if v then enableOptimizer() else disableOptimizer() end end)
    Toggle("Visual","Galaxy Sky","GalaxySkyBright",
        function(v) if v then enableGalaxySkyBright() else disableGalaxySkyBright() end end)
 
    -- SETTINGS
    Toggle("Settings","Inf Jump","Galaxy",
        function(v) if v then startGalaxy() else stopGalaxy() end end)
    do
        local g1=Slider(scroll,"Gravity %",25,130,"GalaxyGravityPercent",function(v) Values.GalaxyGravityPercent=v; if galaxyEnabled then adjustGalaxyJump() end end)
        g1.Visible=false; regTab("Settings",g1)
        local g2=Slider(scroll,"Hop Power",10,80,"HOP_POWER",function(v) Values.HOP_POWER=v end)
        g2.Visible=false; regTab("Settings",g2)
    end
    Toggle("Settings","Spin Bot","SpinBot",
        function(v) if v then startSpinBot() else stopSpinBot() end end)
    do
        local ss=Slider(scroll,"Spin Speed",5,50,"SpinSpeed",function(v) Values.SpinSpeed=v end)
        ss.Visible=false; regTab("Settings",ss)
    end
 
    if Enabled.FloatPanel==nil then Enabled.FloatPanel=false end
    ToggleFloat("Settings","Float","FloatPanel",function(body)
        FpLabel(body,"Float")
        BigBtn(body,"Float",
            function() startFloat() end,
            function() stopFloat() end)
    end, nil)
 
    -- TP
    do
        local tpR=Instance.new("Frame",scroll)
        tpR.Size=UDim2.new(1,0,0,122); tpR.BackgroundTransparency=1
        tpR.BorderSizePixel=0; tpR.LayoutOrder=nextOrder(); tpR.Visible=false
        regTab("Settings",tpR)
        local tpLL=Instance.new("UIListLayout",tpR)
        tpLL.SortOrder=Enum.SortOrder.LayoutOrder; tpLL.Padding=UDim.new(0,7)
        local function tpBtn(lbl,posKey)
            local f=Instance.new("Frame",tpR)
            f.Size=UDim2.new(1,0,0,56); f.BackgroundColor3=C_ITEM
            f.BorderSizePixel=0; f.LayoutOrder=nextOrder()
            Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)
            local st=Instance.new("UIStroke",f); st.Color=C_BORDER; st.Thickness=1.2; st.Transparency=0.6
            local btn=Instance.new("TextButton",f)
            btn.Size=UDim2.new(1,-16,0,38); btn.Position=UDim2.new(0,8,0.5,-19)
            btn.BackgroundColor3=C_BG2; btn.BorderSizePixel=0
            btn.Text=lbl; btn.TextColor3=C_GREY
            btn.Font=Enum.Font.GothamSemibold; btn.TextSize=13; btn.ZIndex=3
            Instance.new("UICorner",btn).CornerRadius=UDim.new(0,9)
            local function setSel(state)
                btn.BackgroundColor3=state and C_CYAN or C_BG2
                btn.TextColor3=state and Color3.fromRGB(18,8,30) or C_GREY
            end
            btn.MouseButton1Click:Connect(function()
                if tpSelectedPos==posKey then tpSelectedPos=nil; setSel(false)
                else tpSelectedPos=posKey; setSel(true) end
            end)
            return setSel
        end
        tpLeftSetSel =tpBtn("Auto TP Left","LEFT")
        tpRightSetSel=tpBtn("Auto TP Right","RIGHT")
    end
    -- Save Config
    do
        local sf=Instance.new("Frame",scroll)
        sf.Size=UDim2.new(1,0,0,52); sf.BackgroundColor3=C_ITEM
        sf.BorderSizePixel=0; sf.LayoutOrder=nextOrder(); sf.Visible=false
        Instance.new("UICorner",sf).CornerRadius=UDim.new(0,12)
        local st=Instance.new("UIStroke",sf); st.Color=C_BORDER; st.Thickness=1.2; st.Transparency=0.6
        regTab("Settings",sf)
        local sbtn=Instance.new("TextButton",sf)
        sbtn.Size=UDim2.new(1,-16,0,38); sbtn.Position=UDim2.new(0,8,0.5,-19)
        sbtn.BackgroundColor3=C_CYAN; sbtn.BorderSizePixel=0
        sbtn.Text="Save Config"; sbtn.TextColor3=Color3.fromRGB(18,8,30)
        sbtn.Font=Enum.Font.GothamBlack; sbtn.TextSize=14; sbtn.ZIndex=3
        Instance.new("UICorner",sbtn).CornerRadius=UDim.new(0,9)
        sbtn.MouseButton1Click:Connect(function()
            local ok=SaveConfig(); print(ok and "[PrimeDuels] Config salva!" or "[PrimeDuels] Falhou!") end)
    end
 
    -- KEYS
    KeyRow("Keys","Speed Boost",   "SPEED")
    KeyRow("Keys","Spin Bot",      "SPIN")
    KeyRow("Keys","Auto Left",     "AUTOWALK")
    KeyRow("Keys","Auto Right",    "AUTORIGHT")
    KeyRow("Keys","Speed On Steal","SPEEDSTEAL")
    KeyRow("Keys","Lock",          "BATAIMBOT")
    KeyRow("Keys","Spam Bat",      "SPAMBOT")
    KeyRow("Keys","NoClip Players","NOCLIPPLAYERS")
    KeyRow("Keys","Float",         "FLOAT")
    KeyRow("Keys","Drop",          "DROPBRAINROT")
end
-- ============================================================
do -- CIRCULO GRAB RADIUS
-- ============================================================
	local function updateCircle()
		local char=Player.Character
		local hrp=char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			if grabCircle then grabCircle.CFrame=CFrame.new(0,-9999,0) end; return
		end
		local r=Values.STEAL_RADIUS or 8
		if not grabCircle or not grabCircle.Parent then
			grabCircle=Instance.new("Part")
			grabCircle.Name="PDGrabCircle"; grabCircle.Anchored=true
			grabCircle.CanCollide=false; grabCircle.CastShadow=false; grabCircle.Locked=true
			grabCircle.Material=Enum.Material.Neon; grabCircle.Shape=Enum.PartType.Cylinder
			grabCircle.Color=Color3.fromRGB(150,60,255); grabCircle.Transparency=0.55
			grabCircle.Parent=workspace
		end
		grabCircle.Size=Vector3.new(0.15,r*2,r*2)
		grabCircle.CFrame=CFrame.new(hrp.Position.X,hrp.Position.Y-2.8,hrp.Position.Z)
			*CFrame.Angles(0,0,math.rad(90))
	end
	RunService.Heartbeat:Connect(updateCircle)
	Player.CharacterAdded:Connect(function() task.wait(0.5); updateCircle() end)
end
 
-- ============================================================
do -- PROGRESS BAR (neon roxo)
-- ============================================================
	local C_NEON_PURPLE  = Color3.fromRGB(255, 255, 255)
	local C_NEON_PURPLE2 = Color3.fromRGB(80, 80, 80)
 
	local pb = Instance.new("Frame", sg)
	pb.Name = "PDProgressBar"
	pb.Size = UDim2.new(0, 340, 0, 36)
	pb.Position = UDim2.new(0.5, -170, 1, -80)
	pb.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	pb.BackgroundTransparency = 0.08
	pb.BorderSizePixel = 0
	pb.Active = true
	pb.Draggable = true
	pb.ZIndex = 60
	pb.ClipsDescendants = false
	Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 8)
 
	local pbStroke = Instance.new("UIStroke", pb)
	pbStroke.Color = C_NEON_PURPLE
	pbStroke.Thickness = 1.5
	pbStroke.Transparency = 0
 
	local pbGlow = Instance.new("Frame", pb)
	pbGlow.Size = UDim2.new(1, 8, 1, 8)
	pbGlow.Position = UDim2.new(0, -4, 0, -4)
	pbGlow.BackgroundColor3 = C_NEON_PURPLE
	pbGlow.BackgroundTransparency = 0.88
	pbGlow.BorderSizePixel = 0
	pbGlow.ZIndex = 59
	Instance.new("UICorner", pbGlow).CornerRadius = UDim.new(0, 11)
 
	ProgressLabel = Instance.new("TextLabel", pb)
	ProgressLabel.Size = UDim2.new(1, -16, 1, 0)
	ProgressLabel.Position = UDim2.new(0, 10, 0, 0)
	ProgressLabel.BackgroundTransparency = 1
	ProgressLabel.Text = "READY"
	ProgressLabel.TextColor3 = Color3.fromRGB(235, 220, 255)
	ProgressLabel.Font = Enum.Font.GothamBlack
	ProgressLabel.TextSize = 13
	ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
	ProgressLabel.ZIndex = 62
 
	ProgressPercentLabel = Instance.new("TextLabel", pb)
	ProgressPercentLabel.Size = UDim2.new(0.5, 0, 1, 0)
	ProgressPercentLabel.Position = UDim2.new(0.5, 0, 0, 0)
	ProgressPercentLabel.BackgroundTransparency = 1
	ProgressPercentLabel.Text = ""
	ProgressPercentLabel.TextColor3 = C_NEON_PURPLE
	ProgressPercentLabel.Font = Enum.Font.GothamBlack
	ProgressPercentLabel.TextSize = 13
	ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Right
	ProgressPercentLabel.ZIndex = 62
 
	local pbTrack = Instance.new("Frame", pb)
	pbTrack.Size = UDim2.new(1, -12, 0, 3)
	pbTrack.Position = UDim2.new(0, 6, 1, -5)
	pbTrack.BackgroundColor3 = Color3.fromRGB(30, 10, 50)
	pbTrack.BorderSizePixel = 0
	pbTrack.ZIndex = 61
	Instance.new("UICorner", pbTrack).CornerRadius = UDim.new(1, 0)
 
	ProgressBarFill = Instance.new("Frame", pbTrack)
	ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
	ProgressBarFill.BackgroundColor3 = C_NEON_PURPLE
	ProgressBarFill.BorderSizePixel = 0
	ProgressBarFill.ZIndex = 62
	Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)
	local pbFillGrad = Instance.new("UIGradient", ProgressBarFill)
	pbFillGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C_NEON_PURPLE),
		ColorSequenceKeypoint.new(1, C_NEON_PURPLE2)
	})
	pbFillGrad.Rotation = 90
 
	RunService.Heartbeat:Connect(function()
		local filled = ProgressBarFill and ProgressBarFill.Size.X.Scale > 0.05
		if pbGlow then
			pbGlow.BackgroundTransparency = filled and (0.82 + math.sin(tick()*6)*0.06) or 0.95
		end
		if pbStroke then
			pbStroke.Transparency = filled and 0 or 0.1
		end
	end)
 
	makeDraggable(pb, pb)
end
 
local function ResetProgressBar()
	if ProgressLabel        then ProgressLabel.Text="READY" end
	if ProgressPercentLabel then ProgressPercentLabel.Text="" end
	if ProgressBarFill      then ProgressBarFill.Size=UDim2.new(0,0,1,0) end
end
 
-- ============================================================
do -- PING / FPS WIDGET
-- ============================================================
	local sw=Instance.new("Frame",sg)
	sw.Size=UDim2.new(0,90,0,42); sw.Position=UDim2.new(0,10,0,10)
	sw.BackgroundColor3=Color3.fromRGB(0,0,0); sw.BackgroundTransparency=0.35
	sw.BorderSizePixel=0; sw.Active=true; sw.Draggable=true; sw.ZIndex=50
	Instance.new("UICorner",sw).CornerRadius=UDim.new(0,6)
	local function sl(txt,xO,r,sz,col,bold)
		local l=Instance.new("TextLabel",sw)
		l.Size=UDim2.new(0,42,0.5,0); l.Position=UDim2.new(0,xO,r==0 and 0 or 0.5,0)
		l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=col or C_GREY
		l.Font=bold and Enum.Font.GothamBlack or Enum.Font.GothamBold
		l.TextSize=sz or 11; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=51
		return l
	end
	sl("FPS:",4,0,11,C_GREY)
	local fv=sl("--",44,0,12,C_WHITE,true)
	sl("PING:",4,1,11,C_GREY)
	local pv=sl("--",44,1,12,C_WHITE,true)
	local fc=0; local lt=tick()
	RunService.Heartbeat:Connect(function()
		fc=fc+1; local now=tick()
		if now-lt>=0.5 then
			fv.Text=tostring(math.floor(fc/(now-lt))); fc=0; lt=now
			local ping=0
			pcall(function() ping=math.floor(Players.LocalPlayer:GetNetworkPing()*1000) end)
			pv.Text=tostring(ping).."ms"
		end
	end)
	makeDraggable(sw, sw)
end
 
-- ============================================================
do -- INPUT
-- ============================================================
	UserInputService.InputBegan:Connect(function(input,gpe)
		if gpe and not waitingForKey then return end
		if waitingForKey and input.KeyCode~=Enum.KeyCode.Unknown then
			local k=input.KeyCode
			if k==Enum.KeyCode.Escape then
				if KeyButtons[waitingForKey] then
					KeyButtons[waitingForKey].Text=KEYBINDS[waitingForKey] and KEYBINDS[waitingForKey].Name or "?"
					KeyButtons[waitingForKey].BackgroundColor3=C_CYANLO
				end
			else
				KEYBINDS[waitingForKey]=k
				if KeyButtons[waitingForKey] then
					KeyButtons[waitingForKey].Text=k.Name
					KeyButtons[waitingForKey].BackgroundColor3=C_CYANLO
				end
			end
			waitingForKey=nil
			if _G.PD_showKeyOverlay then _G.PD_showKeyOverlay(false) end
			return
		end
		if input.KeyCode==Enum.KeyCode.U then guiVisible=not guiVisible; main.Visible=guiVisible; return end
 
		if input.KeyCode==KEYBINDS.SPEED then
			Enabled.SpeedBoost=not Enabled.SpeedBoost
			if VisualSetters.SpeedBoost then VisualSetters.SpeedBoost(Enabled.SpeedBoost) end
			if Enabled.SpeedBoost then startSpeedBoost() else stopSpeedBoost() end
		end
		if input.KeyCode==KEYBINDS.SPIN then
			Enabled.SpinBot=not Enabled.SpinBot
			if VisualSetters.SpinBot then VisualSetters.SpinBot(Enabled.SpinBot) end
			if Enabled.SpinBot then startSpinBot() else stopSpinBot() end
		end
		if input.KeyCode==KEYBINDS.BATAIMBOT then
			Enabled.BatAimbot=not Enabled.BatAimbot
			if VisualSetters.BatAimbot then VisualSetters.BatAimbot(Enabled.BatAimbot) end
			if Enabled.BatAimbot then startBatAimbot() else stopBatAimbot() end
		end
		if input.KeyCode==KEYBINDS.AUTORIGHT then
			AutoRightEnabled=not AutoRightEnabled; Enabled.AutoRightEnabled=AutoRightEnabled
			if VisualSetters.AutoRightEnabled then VisualSetters.AutoRightEnabled(AutoRightEnabled) end
			if AutoRightEnabled then startAutoRight() else stopAutoRight(); _restoreSpeedAfterAuto() end
		end
		if input.KeyCode==KEYBINDS.AUTOWALK then
			AutoWalkEnabled=not AutoWalkEnabled; Enabled.AutoWalkEnabled=AutoWalkEnabled
			if VisualSetters.AutoWalkEnabled then VisualSetters.AutoWalkEnabled(AutoWalkEnabled) end
			if AutoWalkEnabled then startAutoWalk() else stopAutoWalk(); _restoreSpeedAfterAuto() end
		end
		if input.KeyCode==KEYBINDS.SPAMBOT then
			Enabled.SpamBat=not Enabled.SpamBat
			if VisualSetters.SpamBat then VisualSetters.SpamBat(Enabled.SpamBat) end
			if Enabled.SpamBat then startSpamBat() else stopSpamBat() end
		end
		if input.KeyCode==KEYBINDS.SPEEDSTEAL then
			Enabled.SpeedWhileStealing=not Enabled.SpeedWhileStealing
			if VisualSetters.SpeedWhileStealing then VisualSetters.SpeedWhileStealing(Enabled.SpeedWhileStealing) end
			if Enabled.SpeedWhileStealing then startSpeedWhileStealing() else stopSpeedWhileStealing() end
		end
		if input.KeyCode==KEYBINDS.NOCLIPPLAYERS then
			Enabled.NoClipPlayers=not Enabled.NoClipPlayers
			if VisualSetters.NoClipPlayers then VisualSetters.NoClipPlayers(Enabled.NoClipPlayers) end
			if Enabled.NoClipPlayers then startNoClipPlayers() else stopNoClipPlayers() end
		end
		if input.KeyCode==KEYBINDS.FLOAT then
			Enabled.Float=not Enabled.Float
			Enabled.FloatPanel=Enabled.Float
			if VisualSetters.Float then VisualSetters.Float(Enabled.Float) end
			if VisualSetters.FloatPanel then VisualSetters.FloatPanel(Enabled.FloatPanel) end
			if Enabled.Float then startFloat() else stopFloat() end
		end
		if input.KeyCode==KEYBINDS.DROPBRAINROT then
			doDropBrainrot()
		end
		if input.KeyCode==KEYBINDS.MEDUSA then
			Enabled.Medusa=not Enabled.Medusa
			if VisualSetters.Medusa then VisualSetters.Medusa(Enabled.Medusa) end
			if Enabled.Medusa then startMedusa() else stopMedusa() end
		end
	end)
end
 
-- ============================================================
do -- RECONECTAR + INICIAR
-- ============================================================
	Player.CharacterAdded:Connect(function()
		task.wait(1)
		if Enabled.AntiRagdoll then stopAntiRagdoll(); task.wait(0.1); startAntiRagdoll() end
		if Enabled.SpinBot     then stopSpinBot();     task.wait(0.1); startSpinBot()     end
		if Enabled.Galaxy      then setupGalaxyForce(); adjustGalaxyJump()                end
		if Enabled.SpamBat     then stopSpamBat();     task.wait(0.1); startSpamBat()     end
		if Enabled.BatAimbot   then stopBatAimbot();   task.wait(0.1); startBatAimbot()   end
		if Enabled.Unwalk      then startUnwalk()                                         end
	end)
 
	task.spawn(function()
		task.wait(3)
		local c=Player.Character
		if not c or not c:FindFirstChild("HumanoidRootPart") then
			c=Player.CharacterAdded:Wait(); task.wait(1)
		end
		for key,btn in pairs(KeyButtons) do if btn and KEYBINDS[key] then btn.Text=KEYBINDS[key].Name end end
		for key,setter in pairs(VisualSetters) do if Enabled[key] then setter(true,true) end end
		for key,setter in pairs(SliderSetters) do if Values[key]   then setter(Values[key]) end end
		if Enabled.AntiRagdoll     then startAntiRagdoll()       end
		if Enabled.AutoGrab        then startAutoGrab()          end
		if Enabled.Optimizer       then enableOptimizer()        end
		if Enabled.GalaxySkyBright then enableGalaxySkyBright()  end
		task.wait(0.5)
		if Enabled.SpeedBoost         then startSpeedBoost()         end
		if Enabled.SpinBot            then startSpinBot()            end
		if Enabled.SpamBat            then startSpamBat()            end
		if Enabled.BatAimbot          then startBatAimbot()          end
		if Enabled.Galaxy             then startGalaxy()             end
		if Enabled.SpeedWhileStealing then startSpeedWhileStealing() end
		if Enabled.Unwalk             then startUnwalk()             end
		if Enabled.AutoWalkEnabled    then AutoWalkEnabled=true;  startAutoWalk()  end
		if Enabled.AutoRightEnabled   then AutoRightEnabled=true; startAutoRight() end
		if Enabled.NoClipPlayers      then startNoClipPlayers()   end
		if Enabled.Float              then startFloat()            end
		if configLoaded then print("[PrimeDuels] Config aplicada!") end
	end)
end
 
print("[PrimeDuels] Carregado! U=GUI | V=Speed | 0=Spin | X=AutoBat | Z=AutoRight | G=RestamAuto | J=SpamBat | F=SpeedSteal | H=NoClip | T=Float")
