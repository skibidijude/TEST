local Players=game:GetService("Players") local TweenService=game:GetService("TweenService") local RunService=game:GetService("RunService") local UserInputService=game:GetService("UserInputService") local ProximityPromptService=game:GetService("ProximityPromptService") local CoreGui=game:GetService("CoreGui") local Stats=game:GetService("Stats") local TeleportService=game:GetService("TeleportService")
local player=Players.LocalPlayer local PlayerGui=player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui",2)
local CONFIG_FILE="SukaHubConfig.json"
local CONFIG={GUI_POSITION_X=nil,GUI_POSITION_Y=nil,ENABLED=false,SAVED_POSITION=nil,KEYBIND_BASE1="E",KEYBIND_BASE2="R",KEYBIND_SPAM="X"}
local targetPositions={Vector3.new(-481.88,-3.79,138.02),Vector3.new(-481.75,-3.79,89.18),Vector3.new(-481.82,-3.79,30.95),Vector3.new(-481.75,-3.79,-17.79),Vector3.new(-481.80,-3.79,-76.06),Vector3.new(-481.72,-3.79,-124.70),Vector3.new(-337.45,-3.85,-124.72),Vector3.new(-337.37,-3.85,-76.07),Vector3.new(-337.46,-3.79,-17.72),Vector3.new(-337.41,-3.79,30.92),Vector3.new(-337.32,-3.79,89.02),Vector3.new(-337.27,-3.79,137.90),Vector3.new(-337.45,-3.79,196.29),Vector3.new(-337.37,-3.79,244.91),Vector3.new(-481.72,-3.79,196.21),Vector3.new(-481.76,-3.79,244.92)}
local function saveConfig()
	if not writefile then return end
	local cs={}
	for k,v in pairs(CONFIG) do
		if k=="SAVED_POSITION" and v then cs[k]={Position={X=v.Position.X,Y=v.Position.Y,Z=v.Position.Z},LookVector={X=v.LookVector.X,Y=v.LookVector.Y,Z=v.LookVector.Z}}
		else cs[k]=v end
	end
	pcall(function() writefile(CONFIG_FILE,game:GetService("HttpService"):JSONEncode(cs)) end)
end
local function loadConfig()
	if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
	local ok,saved=pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE)) end)
	if ok and saved then
		if saved.GUI_POSITION_X then CONFIG.GUI_POSITION_X=saved.GUI_POSITION_X end
		if saved.GUI_POSITION_Y then CONFIG.GUI_POSITION_Y=saved.GUI_POSITION_Y end
		if saved.ENABLED~=nil then CONFIG.ENABLED=saved.ENABLED end
		if saved.KEYBIND_SPAM then CONFIG.KEYBIND_SPAM=saved.KEYBIND_SPAM end
		if saved.KEYBIND_BASE1 then CONFIG.KEYBIND_BASE1=saved.KEYBIND_BASE1 end
		if saved.KEYBIND_BASE2 then CONFIG.KEYBIND_BASE2=saved.KEYBIND_BASE2 end
		if saved.SAVED_POSITION and saved.SAVED_POSITION.Position and saved.SAVED_POSITION.LookVector then
			local p,l=saved.SAVED_POSITION.Position,saved.SAVED_POSITION.LookVector
			CONFIG.SAVED_POSITION=CFrame.new(Vector3.new(p.X,p.Y,p.Z),Vector3.new(l.X+p.X,l.Y+p.Y,l.Z+p.Z))
		end
	end
end
loadConfig()
local desyncActivated=false
local function activateDesync()
	local flags={{"GameNetPVHeaderRotationalVelocityZeroCutoffExponent","-5000"},{"LargeReplicatorWrite5","true"},{"LargeReplicatorEnabled9","true"},{"AngularVelociryLimit","360"},{"TimestepArbiterVelocityCriteriaThresholdTwoDt","2147483646"},{"S2PhysicsSenderRate","15000"},{"DisableDPIScale","true"},{"MaxDataPacketPerSend","2147483647"},{"ServerMaxBandwith","52"},{"PhysicsSenderMaxBandwidthBps","20000"},{"MaxTimestepMultiplierBuoyancy","2147483647"},{"SimOwnedNOUCountThresholdMillionth","2147483647"},{"MaxMissedWorldStepsRemembered","-2147483648"},{"CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth","1"},{"StreamJobNOUVolumeLengthCap","2147483647"},{"DebugSendDistInSteps","-2147483648"},{"MaxTimestepMultiplierAcceleration","2147483647"},{"LargeReplicatorRead5","true"},{"SimExplicitlyCappedTimestepMultiplier","2147483646"},{"GameNetDontSendRedundantNumTimes","1"},{"CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent","1"},{"CheckPVCachedRotVelThresholdPercent","10"},{"LargeReplicatorSerializeRead3","true"},{"ReplicationFocusNouExtentsSizeCutoffForPauseStuds","2147483647"},{"NextGenReplicatorEnabledWrite4","true"},{"CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth","1"},{"GameNetDontSendRedundantDeltaPositionMillionth","1"},{"InterpolationFrameVelocityThresholdMillionth","5"},{"StreamJobNOUVolumeCap","2147483647"},{"InterpolationFrameRotVelocityThresholdMillionth","5"},{"WorldStepMax","30"},{"TimestepArbiterHumanoidLinearVelThreshold","1"},{"InterpolationFramePositionThresholdMillionth","5"},{"TimestepArbiterHumanoidTurningVelThreshold","1"},{"MaxTimestepMultiplierContstraint","2147483647"},{"GameNetPVHeaderLinearVelocityZeroCutoffExponent","-5000"},{"CheckPVCachedVelThresholdPercent","10"},{"TimestepArbiterOmegaThou","1073741823"},{"MaxAcceptableUpdateDelay","1"},{"LargeReplicatorSerializeWrite4","true"}}
	for _,d in ipairs(flags) do pcall(function() if setfflag then setfflag(d[1],d[2]) end end) end
	pcall(function()
		local char=player.Character
		if char then
			local hum=char:FindFirstChildWhichIsA("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end
			char:ClearAllChildren()
			local tmp=Instance.new("Model",workspace) player.Character=tmp task.wait(0.1) player.Character=char tmp:Destroy()
		end
	end)
	desyncActivated=true
end
local originalPing=nil
local function setPing(v) pcall(function() settings().Network.IncomingReplicationLag=v end) end
local function equipCarpet()
	local bp=player:FindFirstChild("Backpack")
	if bp then local c=bp:FindFirstChild("Flying Carpet") if c and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:EquipTool(c) end end
end
local function findClosestPosition()
	local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best,bestD=nil,math.huge
	for _,v in ipairs(targetPositions) do local d=(hrp.Position-v).Magnitude if d<bestD then bestD=d;best=v end end
	return best and CFrame.lookAt(best,best+Vector3.new(0,0,-1)) or nil
end
local function performTeleport(pos1)
	local char=player.Character if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
	local pos2=findClosestPosition()
	if pos1 then hrp.CFrame=pos1 end
	if pos2 then task.wait(0.05);hrp.CFrame=pos2 end
end
local function findPodiumForDebris(debris)
	if not debris or not debris:IsA("BasePart") then return nil end
	local debrisPos=debris.Position local bestPodium,bestDist=nil,math.huge
	for _,plot in ipairs(workspace.Plots:GetChildren()) do
		local podiums=plot:FindFirstChild("AnimalPodiums") if not podiums then continue end
		for _,podium in ipairs(podiums:GetChildren()) do
			local pp=podium:GetPivot().Position
			local dist=(Vector3.new(pp.X,0,pp.Z)-Vector3.new(debrisPos.X,0,debrisPos.Z)).Magnitude
			if dist<bestDist then bestDist=dist;bestPodium=podium end
		end
	end
	if bestPodium and bestDist<20 then
		local prompt=bestPodium:FindFirstChildWhichIsA("ProximityPrompt",true)
		if not prompt then local att=bestPodium:FindFirstChild("PromptAttachment") if att then prompt=att:FindFirstChildOfClass("ProximityPrompt") end end
		if not prompt then for _,desc in ipairs(bestPodium:GetDescendants()) do if desc:IsA("ProximityPrompt") and desc.Enabled then prompt=desc;break end end end
		return prompt
	end
	return nil
end
local function doTPBase(cf,radius,savedCF)
	local char=player.Character if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end
	if not originalPing then originalPing=settings().Network.IncomingReplicationLag end
	setPing(0.015) equipCarpet() task.wait(0.15) hrp.CFrame=cf task.wait(0.2)
	local closestDebris,closestDist=nil,math.huge
	for _,debris in ipairs(workspace.Debris:GetChildren()) do
		if debris:FindFirstChild("AnimalOverhead") then
			local dist=(debris.Position-hrp.Position).Magnitude
			if dist<closestDist and dist<radius then closestDist=dist;closestDebris=debris end
		end
	end
	if closestDebris then
		local prompt=findPodiumForDebris(closestDebris)
		if prompt and prompt.Enabled then task.wait(0.09) fireproximityprompt(prompt) CONFIG.SAVED_POSITION=savedCF saveConfig() performTeleport(CONFIG.SAVED_POSITION) end
	end
	task.delay(0.5,function() if originalPing then setPing(originalPing) end end)
end
local function doTPBase1() doTPBase(CFrame.new(-335,-5,18),35,CFrame.new(-372,-7,74)) end
local function doTPBase2() doTPBase(CFrame.new(-336,-5,98),25,CFrame.new(-365,-7,62)) end
local promptConnection=nil
local function enablePromptDetection()
	if promptConnection then return end
	if not originalPing then originalPing=settings().Network.IncomingReplicationLag end
	promptConnection=ProximityPromptService.PromptShown:Connect(function(prompt,_)
		if prompt.Name~="Steal" and prompt.ActionText~="Steal" then return end
		if not CONFIG.ENABLED then return end
		local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
		setPing(0.015)
		task.spawn(function() task.wait(0.09) fireproximityprompt(prompt) equipCarpet() performTeleport(CONFIG.SAVED_POSITION) task.delay(0.5,function() if originalPing then setPing(originalPing) end end) end)
	end)
end
local function disablePromptDetection() if promptConnection then promptConnection:Disconnect();promptConnection=nil end end
local autoKickEnabled,autoKickConnection=false,nil
local function hasKeyword(text) if typeof(text)~="string" then return false end return string.find(string.lower(text),"you stole")~=nil end
local function kickImmediately()
	pcall(function() player:Kick("Auto Kicked") end) pcall(function() TeleportService:Teleport(game.PlaceId,player) end)
	pcall(function() if player.Character then player.Character:BreakJoints() end end) task.wait(0.1) pcall(function() game:Shutdown() end)
end
local function startAutoKick()
	if autoKickConnection then return end
	autoKickConnection=RunService.Heartbeat:Connect(function()
		if not autoKickEnabled then return end
		for _,gui in pairs(CoreGui:GetDescendants()) do if(gui:IsA("TextLabel") or gui:IsA("TextButton")) and hasKeyword(gui.Text) then kickImmediately();return end end
		pcall(function() for _,gui in pairs(player.PlayerGui:GetDescendants()) do if(gui:IsA("TextLabel") or gui:IsA("TextButton")) and hasKeyword(gui.Text) then kickImmediately();return end end end)
	end)
end
local function stopAutoKick() if autoKickConnection then autoKickConnection:Disconnect();autoKickConnection=nil end end
local speedAfterSteal,speedConnection,SPEED_BOOST=false,nil,28
ProximityPromptService.PromptTriggered:Connect(function(prompt,plr)
	if plr~=player or not speedAfterSteal then return end
	local char=player.Character if not char then return end
	local hum,hrp=char:FindFirstChildOfClass("Humanoid"),char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end
	if speedConnection then speedConnection:Disconnect() end
	speedConnection=RunService.Heartbeat:Connect(function()
		if not speedAfterSteal or not hrp.Parent then if speedConnection then speedConnection:Disconnect();speedConnection=nil end;return end
		if hum.MoveDirection.Magnitude==0 then return end
		local dir=hum.MoveDirection.Unit hrp.AssemblyLinearVelocity=Vector3.new(dir.X*SPEED_BOOST,hrp.AssemblyLinearVelocity.Y,dir.Z*SPEED_BOOST)
	end)
end)
local SPAM_COMMANDS={{name="rocket",emoji="🚀"},{name="balloon",emoji="🎈"},{name="nightvision",emoji="🌙"},{name="jumpscare",emoji="👻"},{name="ragdoll",emoji="🤸"},{name="inverse",emoji="🔄"},{name="jail",emoji="⛓️"},{name="tiny",emoji="🔬"},{name="morph",emoji="🦎"}}
local spamming,commandStates,spamPanelOpen,spamPanelFrame={},{},false,nil
local function findAdminPanel() return PlayerGui:FindFirstChild("AdminPanel") end
local function getBtnText(desc)
	local txt=desc:IsA("TextButton") and desc.Text or ""
	if txt=="" then for _,c in pairs(desc:GetDescendants()) do if c:IsA("TextLabel") and c.Text~="" then return c.Text end end end
	return txt
end
local function findPlayerButton(tp)
	local ap=findAdminPanel() if not ap then return nil end
	local dn,un=tp.DisplayName,tp.Name
	for _,desc in pairs(ap:GetDescendants()) do
		if desc:IsA("TextButton") or desc:IsA("ImageButton") then
			local txt=getBtnText(desc)
			if txt==dn or txt:find(dn) or txt==un or txt:find(un) then return desc end
		end
	end
end
local function getCommandButtons()
	local buttons={} local ap=findAdminPanel() if not ap then return buttons end
	for _,desc in pairs(ap:GetDescendants()) do
		if desc:IsA("TextButton") or desc:IsA("ImageButton") then
			local txt=getBtnText(desc)
			if txt~="" and (txt:match("^:") or txt:match("^;")) then table.insert(buttons,{button=desc,name=txt}) end
		end
	end
	return buttons
end
local function clickButton(button) pcall(function() for _,conn in pairs(getconnections(button.MouseButton1Click)) do conn:Fire() end for _,conn in pairs(getconnections(button.Activated)) do conn:Fire() end end) end
local function spamExecute(targetPlayer,statusLabel)
	task.spawn(function()
		local pk=targetPlayer.Name
		if not commandStates[pk] then commandStates[pk]={} for _,cmd in pairs(SPAM_COMMANDS) do commandStates[pk][cmd.name]=true end end
		spamming[pk]=true local cmdButtons=getCommandButtons() local toRun={}
		for _,cd in pairs(cmdButtons) do local lower=cd.name:lower() for _,cmd in pairs(SPAM_COMMANDS) do if lower:find(cmd.name) and commandStates[pk][cmd.name] then table.insert(toRun,cd);break end end end
		if #toRun==0 then if statusLabel then statusLabel.Text="No cmds on" end spamming[pk]=false;return end
		for _,cd in pairs(toRun) do if not spamming[pk] then break end local pb=findPlayerButton(targetPlayer) if pb then clickButton(pb);task.wait(0.01) end clickButton(cd.button);task.wait(0.01) end
		spamming[pk]=false if statusLabel then statusLabel.Text="Done!" end task.wait(2) if statusLabel and statusLabel.Parent then statusLabel.Text="Ready" end
	end)
end
if CoreGui:FindFirstChild("MSPHubGui") then CoreGui["MSPHubGui"]:Destroy() end
local screenGui=Instance.new("ScreenGui") screenGui.Name="MSPHubGui" screenGui.ResetOnSpawn=false screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling screenGui.Parent=CoreGui

-- PINK & WHITE COLOR PALETTE
local C={
	BG=Color3.fromRGB(255,240,248),
	Surface=Color3.fromRGB(255,220,238),
	SurfaceDark=Color3.fromRGB(250,200,228),
	Accent=Color3.fromRGB(235,80,150),
	AccentLight=Color3.fromRGB(255,130,185),
	Border=Color3.fromRGB(220,140,180),
	Text=Color3.fromRGB(120,30,75),
	TextDim=Color3.fromRGB(190,120,160),
	ToggleOn=Color3.fromRGB(235,80,150),
	ToggleOff=Color3.fromRGB(220,180,205),
	ToggleKnob=Color3.fromRGB(255,255,255),
	Separator=Color3.fromRGB(230,170,200),
	BtnBg=Color3.fromRGB(255,225,240),
	BtnText=Color3.fromRGB(200,60,120)
}
local WHITE=Color3.fromRGB(255,255,255)
local activeGradients,animAngle={},0
RunService.Heartbeat:Connect(function(dt) animAngle=(animAngle+dt*180)%360 for i=#activeGradients,1,-1 do local g=activeGradients[i] if g and g.Parent then g.Rotation=animAngle else table.remove(activeGradients,i) end end end)
local function addAnimatedStroke(frame,thickness)
	local stroke=Instance.new("UIStroke") stroke.Thickness=thickness or 3 stroke.Transparency=0 stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Parent=frame
	local grad=Instance.new("UIGradient",stroke)
	grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(220,80,140)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,160,210)),ColorSequenceKeypoint.new(1,Color3.fromRGB(220,80,140))})
	grad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.2),NumberSequenceKeypoint.new(1,0)})
	table.insert(activeGradients,grad) return stroke
end
local function mkFrame(props) local f=Instance.new("Frame") for k,v in pairs(props) do f[k]=v end return f end
local function mkLabel(props) local l=Instance.new("TextLabel") l.BackgroundTransparency=1 for k,v in pairs(props) do l[k]=v end return l end
local function mkBtn(props) local b=Instance.new("TextButton") for k,v in pairs(props) do b[k]=v end return b end
local function corner(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function stroke(p,c,t) local s=Instance.new("UIStroke",p) s.Color=c s.Thickness=t return s end
local mainFrame=mkFrame({Name="MainFrame",Size=UDim2.new(0,320,0,430),Position=UDim2.new(0.5,-160,0.5,-215),BackgroundColor3=C.BG,BackgroundTransparency=0,BorderSizePixel=0,Active=true,Draggable=true,Parent=screenGui})
corner(mainFrame,14) addAnimatedStroke(mainFrame,3)
local shadow=mkFrame({Size=UDim2.new(1,16,1,16),Position=UDim2.new(0,-8,0,-8),BackgroundColor3=Color3.fromRGB(255,150,200),BackgroundTransparency=0.82,BorderSizePixel=0,ZIndex=-1,Parent=mainFrame}) corner(shadow,18)
local titleBar=mkFrame({Name="TitleBar",Size=UDim2.new(1,0,0,54),Position=UDim2.new(0,0,0,0),BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=mainFrame}) corner(titleBar,14)
local tbFill=mkFrame({Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=titleBar})
local tbFillGrad=Instance.new("UIGradient",tbFill)
tbFillGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(210,60,120)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,120,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(210,60,120))})
tbFillGrad.Rotation=0
local titleLabel=mkLabel({Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),Text="LIGHT HUB INSTA STEAL",TextColor3=WHITE,TextSize=22,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Center,Parent=titleBar})
local titleGrad=Instance.new("UIGradient",titleBar)
titleGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(210,60,120)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,130,185)),ColorSequenceKeypoint.new(1,Color3.fromRGB(210,60,120))})
titleGrad.Rotation=0
local bgGrad=Instance.new("UIGradient",mainFrame)
bgGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,250)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,220,240))})
bgGrad.Rotation=135
local function createToggle(labelText,yPos,callback)
	local row=mkFrame({Size=UDim2.new(1,-20,0,36),Position=UDim2.new(0,10,0,yPos),BackgroundColor3=C.Surface,BorderSizePixel=0,Parent=mainFrame}) corner(row,8)
	local rowStroke=stroke(row,C.Border,1)
	local rowGrad=Instance.new("UIGradient",row)
	rowGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,228,242)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,210,232))})
	rowGrad.Rotation=90
	row.MouseEnter:Connect(function() TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=C.AccentLight,Thickness=1.5}):Play() end)
	row.MouseLeave:Connect(function() TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=C.Border,Thickness=1}):Play() end)
	mkLabel({Size=UDim2.new(1,-65,1,0),Position=UDim2.new(0,12,0,0),Text=labelText,TextColor3=C.Text,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
	local bg=mkFrame({Size=UDim2.new(0,46,0,24),Position=UDim2.new(1,-52,0.5,-12),BackgroundColor3=C.ToggleOff,BorderSizePixel=0,Parent=row}) corner(bg,999)
	local knob=mkFrame({Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=C.ToggleKnob,BorderSizePixel=0,Parent=bg}) corner(knob,999)
	local knobGlow=Instance.new("UIStroke",knob) knobGlow.Thickness=0 knobGlow.Color=C.AccentLight knobGlow.Transparency=0.5 knobGlow.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	local btn=mkBtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3,Parent=bg})
	local active=false
	btn.MouseButton1Click:Connect(function()
		active=not active
		TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Position=active and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
		TweenService:Create(bg,TweenInfo.new(0.2),{BackgroundColor3=active and C.ToggleOn or C.ToggleOff}):Play()
		TweenService:Create(knobGlow,TweenInfo.new(0.2),{Thickness=active and 3 or 0}):Play()
		callback(active)
	end)
	return btn
end
local function createButton(labelText,yPos,w,xPos)
	local btn=mkBtn({Size=UDim2.new(w or 1,-(w and 0 or 20),0,36),Position=UDim2.new(xPos or 0,xPos and 0 or 10,0,yPos),BackgroundColor3=C.BtnBg,BorderSizePixel=0,Text=labelText,TextColor3=C.BtnText,TextSize=13,Font=Enum.Font.GothamBold,Parent=mainFrame})
	corner(btn,8)
	local btnStroke=stroke(btn,C.Border,1.5)
	local btnGrad=Instance.new("UIGradient",btn)
	btnGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,230,243)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,210,233))})
	btnGrad.Rotation=90
	btn.MouseEnter:Connect(function() TweenService:Create(btnStroke,TweenInfo.new(0.15),{Color=C.AccentLight,Thickness=2}):Play() TweenService:Create(btn,TweenInfo.new(0.15),{TextColor3=C.Accent}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btnStroke,TweenInfo.new(0.15),{Color=C.Border,Thickness=1.5}):Play() TweenService:Create(btn,TweenInfo.new(0.15),{TextColor3=C.BtnText}):Play() end)
	return btn
end
local Y=66
createToggle("Auto Potion",Y,function(s) _G.AutoPotion=s end) Y=Y+42
createToggle("Speed After Steal",Y,function(s) speedAfterSteal=s;if not s and speedConnection then speedConnection:Disconnect();speedConnection=nil end end) Y=Y+42
createToggle("Auto Kick",Y,function(s) autoKickEnabled=s;if s then startAutoKick() else stopAutoKick() end end) Y=Y+42
local sep=mkFrame({Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,Y),BackgroundColor3=C.Separator,BorderSizePixel=0,Parent=mainFrame}) Y=Y+10
local desyncBtn=createButton("— DESYNC —",Y) desyncBtn.BackgroundColor3=C.Accent desyncBtn.TextColor3=WHITE
for _,c in pairs(desyncBtn:GetChildren()) do if c:IsA("UIGradient") then c.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(215,65,130)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,130,185)),ColorSequenceKeypoint.new(1,Color3.fromRGB(215,65,130))}) c.Rotation=0 end end
desyncBtn.MouseButton1Click:Connect(function()
	desyncBtn.Text="— ACTIVATING... —"
	TweenService:Create(desyncBtn,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,2,true),{BackgroundTransparency=0.3}):Play()
	activateDesync()
	task.delay(1.5,function() if desyncBtn and desyncBtn.Parent then desyncBtn.Text="— DESYNC ✓ —" desyncBtn.BackgroundTransparency=0 end end)
end) Y=Y+46
local notifActive=false
local function showDesyncWarning()
	if notifActive then return end notifActive=true
	local notif=mkFrame({Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,Y-4),BackgroundColor3=Color3.fromRGB(255,200,220),BackgroundTransparency=0.1,BorderSizePixel=0,ZIndex=20,Parent=mainFrame}) corner(notif,7)
	local lbl=mkLabel({Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,5,0,0),Text="⚠  Activate DESYNC first!",TextColor3=Color3.fromRGB(200,50,100),TextSize=11,Font=Enum.Font.GothamBold,ZIndex=21,Parent=notif})
	task.delay(2,function() if notif and notif.Parent then notif:Destroy() end notifActive=false end)
end
local halfW=(320-20-8)/2
local tpLeftBtn=mkBtn({Size=UDim2.new(0,halfW,0,36),Position=UDim2.new(0,10,0,Y),BackgroundColor3=C.BtnBg,BorderSizePixel=0,Text="TP BASE 2",TextColor3=C.BtnText,TextSize=12,Font=Enum.Font.GothamBold,Parent=mainFrame}) corner(tpLeftBtn,8)
local tpLeftStroke=stroke(tpLeftBtn,C.Border,1.5)
local tpLeftGrad=Instance.new("UIGradient",tpLeftBtn) tpLeftGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,228,242)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,210,232))}) tpLeftGrad.Rotation=90
tpLeftBtn.MouseEnter:Connect(function() TweenService:Create(tpLeftStroke,TweenInfo.new(0.15),{Color=C.AccentLight,Thickness=2}):Play() end)
tpLeftBtn.MouseLeave:Connect(function() TweenService:Create(tpLeftStroke,TweenInfo.new(0.15),{Color=C.Border,Thickness=1.5}):Play() end)
local tpRightBtn=mkBtn({Size=UDim2.new(0,halfW,0,36),Position=UDim2.new(0,10+halfW+8,0,Y),BackgroundColor3=C.Accent,BorderSizePixel=0,Text="TP BASE 1",TextColor3=WHITE,TextSize=12,Font=Enum.Font.GothamBold,Parent=mainFrame}) corner(tpRightBtn,8)
local tpRightGrad=Instance.new("UIGradient",tpRightBtn) tpRightGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(240,90,155)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(210,55,115)),ColorSequenceKeypoint.new(1,Color3.fromRGB(185,35,90))}) tpRightGrad.Rotation=90
local tpRightStroke=stroke(tpRightBtn,Color3.fromRGB(255,160,200),1)
tpRightBtn.MouseEnter:Connect(function() TweenService:Create(tpRightStroke,TweenInfo.new(0.15),{Thickness=2.5,Color=WHITE}):Play() end)
tpRightBtn.MouseLeave:Connect(function() TweenService:Create(tpRightStroke,TweenInfo.new(0.15),{Thickness=1,Color=Color3.fromRGB(255,160,200)}):Play() end)
tpLeftBtn.MouseButton1Click:Connect(function() if not desyncActivated then showDesyncWarning();return end doTPBase2() end)
tpRightBtn.MouseButton1Click:Connect(function() if not desyncActivated then showDesyncWarning();return end doTPBase1() end) Y=Y+46
local adminSpamEnabled=false local adminSpamBtn=createButton("ADMIN SPAM",Y)
adminSpamBtn.MouseButton1Click:Connect(function()
	adminSpamEnabled=not adminSpamEnabled
	adminSpamBtn.BackgroundColor3=adminSpamEnabled and C.Accent or C.BtnBg
	adminSpamBtn.TextColor3=adminSpamEnabled and WHITE or C.BtnText
	if adminSpamEnabled then
		if spamPanelFrame and spamPanelFrame.Parent then spamPanelFrame.Visible=true;spamPanelOpen=true;return end
		spamPanelFrame=mkFrame({Name="SpamPanel",Size=UDim2.new(0,240,0,34),BackgroundColor3=C.BG,BorderSizePixel=0,ZIndex=1010,Parent=screenGui}) corner(spamPanelFrame,12)
		local spS=Instance.new("UIStroke",spamPanelFrame) spS.Color=C.Accent spS.Thickness=1.5 spS.Transparency=0.3
		local spHeader=mkFrame({Size=UDim2.new(1,0,0,30),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=1011,Parent=spamPanelFrame}) corner(spHeader,12)
		mkFrame({Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=1011,Parent=spHeader})
		mkLabel({Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,10,0,0),Text="ADMIN SPAM",TextColor3=WHITE,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1012,Parent=spHeader})
		local closeBtn=mkBtn({Size=UDim2.new(0,22,0,20),Position=UDim2.new(1,-26,0,5),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.3,BorderSizePixel=0,Text="✕",TextColor3=C.Accent,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=1013,Parent=spHeader}) corner(closeBtn,5)
		closeBtn.MouseButton1Click:Connect(function() spamPanelFrame.Visible=false;spamPanelOpen=false adminSpamEnabled=false adminSpamBtn.BackgroundColor3=C.BtnBg;adminSpamBtn.TextColor3=C.BtnText end)
		local spScroll=Instance.new("ScrollingFrame") spScroll.Size=UDim2.new(1,-8,1,-36) spScroll.Position=UDim2.new(0,4,0,33) spScroll.BackgroundTransparency=1 spScroll.BorderSizePixel=0 spScroll.ScrollBarThickness=3 spScroll.ScrollBarImageColor3=C.Accent spScroll.CanvasSize=UDim2.new(0,0,0,0) spScroll.ZIndex=1011 spScroll.Parent=spamPanelFrame
		local spLayout=Instance.new("UIListLayout") spLayout.SortOrder=Enum.SortOrder.LayoutOrder spLayout.Padding=UDim.new(0,5) spLayout.Parent=spScroll
		local function addPlayerCard(tp)
			local pk=tp.Name
			if not commandStates[pk] then commandStates[pk]={} for _,cmd in pairs(SPAM_COMMANDS) do commandStates[pk][cmd.name]=true end end
			local card=mkFrame({Name=pk,Size=UDim2.new(1,0,0,98),BackgroundColor3=C.Surface,BorderSizePixel=0,ZIndex=1012,Parent=spScroll}) corner(card,8) local cSt=stroke(card,C.Border,1) cSt.Transparency=0.3
			local avF=mkFrame({Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,5,0,5),BackgroundColor3=C.SurfaceDark,BorderSizePixel=0,ZIndex=1013,Parent=card}) corner(avF,6)
			local avImg=Instance.new("ImageLabel") avImg.Size=UDim2.new(1,0,1,0) avImg.BackgroundTransparency=1 avImg.Image="rbxthumb://type=AvatarHeadShot&id="..tp.UserId.."&w=150&h=150" avImg.ZIndex=1014 avImg.Parent=avF corner(avImg,6)
			mkLabel({Size=UDim2.new(0,110,0,14),Position=UDim2.new(0,40,0,5),Text=tp.DisplayName,TextColor3=C.Text,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1013,Parent=card})
			local statusL=mkLabel({Size=UDim2.new(0,110,0,12),Position=UDim2.new(0,40,0,20),Text="Ready",TextColor3=C.TextDim,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1013,Parent=card})
			local spamBtn2=mkBtn({Size=UDim2.new(0,50,0,22),Position=UDim2.new(1,-55,0,7),BackgroundColor3=C.Accent,BorderSizePixel=0,Text="▶ Spam",TextColor3=WHITE,TextSize=9,Font=Enum.Font.GothamBold,ZIndex=1014,Parent=card}) corner(spamBtn2,6)
			mkFrame({Size=UDim2.new(1,-10,0,1),Position=UDim2.new(0,5,0,40),BackgroundColor3=C.Separator,BorderSizePixel=0,ZIndex=1013,Parent=card})
			local cmdGrid=mkFrame({Size=UDim2.new(1,-10,0,50),Position=UDim2.new(0,5,0,44),BackgroundTransparency=1,ZIndex=1013,Parent=card})
			local gridL=Instance.new("UIGridLayout") gridL.CellSize=UDim2.new(0,22,0,22) gridL.CellPadding=UDim2.new(0,3,0,3) gridL.SortOrder=Enum.SortOrder.LayoutOrder gridL.Parent=cmdGrid
			for _,cmd in ipairs(SPAM_COMMANDS) do
				local tog=mkBtn({Name=cmd.name,Size=UDim2.new(0,22,0,22),BackgroundColor3=Color3.fromRGB(255,105,180),BorderSizePixel=0,Text=cmd.emoji,TextSize=12,Font=Enum.Font.Gotham,ZIndex=1014,Parent=cmdGrid}) corner(tog,5)
				local function refreshTog() tog.BackgroundColor3=commandStates[pk][cmd.name] and Color3.fromRGB(255,105,180) or C.SurfaceDark tog.TextTransparency=commandStates[pk][cmd.name] and 0 or 0.4 end
				refreshTog() tog.MouseButton1Click:Connect(function() commandStates[pk][cmd.name]=not commandStates[pk][cmd.name];refreshTog() end)
			end
			spamBtn2.MouseButton1Click:Connect(function()
				if not spamming[pk] then spamming[pk]=true;spamBtn2.Text="⏹ Stop" statusL.Text="Running...";statusL.TextColor3=C.Accent spamExecute(tp,statusL)
				else spamming[pk]=false;spamBtn2.Text="▶ Spam" statusL.Text="Stopped";statusL.TextColor3=C.TextDim end
			end)
			tp.AncestryChanged:Connect(function() if not tp:IsDescendantOf(game) then spamming[pk]=false;commandStates[pk]=nil;card:Destroy() end end)
		end
		for _,plr in pairs(Players:GetPlayers()) do if plr~=player then addPlayerCard(plr) end end
		Players.PlayerAdded:Connect(function(plr) if plr~=player then addPlayerCard(plr) end end)
		local function updatePanelSize()
			local count=0 for _,c in pairs(spScroll:GetChildren()) do if c:IsA("Frame") then count+=1 end end
			spamPanelFrame.Size=UDim2.new(0,240,0,math.min(math.max(count*103+8,10),340)+36)
			spScroll.CanvasSize=UDim2.new(0,0,0,spLayout.AbsoluteContentSize.Y+8)
		end
		spLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePanelSize) task.defer(updatePanelSize)
		task.defer(function() if mainFrame and mainFrame.Parent then local ap=mainFrame.AbsolutePosition local as=mainFrame.AbsoluteSize spamPanelFrame.Position=UDim2.new(0,ap.X+as.X+6,0,ap.Y) end end)
		local spDrag,spDragStart,spDragPos=false,nil,nil
		spHeader.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
				spDrag=true;spDragStart=input.Position;spDragPos=spamPanelFrame.Position
				input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then spDrag=false end end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) and spDrag then
				local delta=input.Position-spDragStart spamPanelFrame.Position=UDim2.new(spDragPos.X.Scale,spDragPos.X.Offset+delta.X,spDragPos.Y.Scale,spDragPos.Y.Offset+delta.Y)
			end
		end)
		spamPanelOpen=true
	else if spamPanelFrame and spamPanelFrame.Parent then spamPanelFrame.Visible=false;spamPanelOpen=false end end
end) Y=Y+46
local rejoinBtn=createButton("— REJOIN —",Y) rejoinBtn.BackgroundColor3=Color3.fromRGB(255,225,240) rejoinBtn.TextColor3=Color3.fromRGB(180,80,130)
rejoinBtn.MouseButton1Click:Connect(function() rejoinBtn.Text="Rejoining..." task.wait(0.5) TeleportService:Teleport(game.PlaceId,player) end) Y=Y+46
mainFrame.Size=UDim2.new(0,320,0,Y+10)
do
	local finalSize=mainFrame.Size
	mainFrame.Size=UDim2.new(0,0,0,0)
	mainFrame.BackgroundTransparency=1
	mainFrame.Position=UDim2.new(0.5,0,0.5,0)
	TweenService:Create(mainFrame,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=finalSize,Position=UDim2.new(0.5,-160,0.5,-(Y+10)/2),BackgroundTransparency=0}):Play()
	for _,child in pairs(mainFrame:GetDescendants()) do
		if child:IsA("GuiObject") and not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIGradient") then
			local origTransp=child.BackgroundTransparency
			if origTransp<1 then child.BackgroundTransparency=1 TweenService:Create(child,TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=origTransp}):Play() end
		end
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			child.TextTransparency=1
			TweenService:Create(child,TweenInfo.new(0.4),{TextTransparency=0}):Play()
		end
	end
end
local keybind1,keybind2,keybindSpam=CONFIG.KEYBIND_BASE1 or "E",CONFIG.KEYBIND_BASE2 or "R",CONFIG.KEYBIND_SPAM or "X"
local listeningFor,settingsOpen=nil,false
local gearBtn=mkBtn({Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0.5,-15),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.4,BorderSizePixel=0,Text="⚙",TextColor3=WHITE,TextSize=16,Font=Enum.Font.GothamBold,ZIndex=10,Parent=titleBar}) corner(gearBtn,7)
local settingsPanel=mkFrame({Size=UDim2.new(0,175,0,175),BackgroundColor3=C.BG,BorderSizePixel=0,ZIndex=1010,Visible=false,Parent=screenGui}) corner(settingsPanel,10) stroke(settingsPanel,C.Accent,1.5)
RunService.RenderStepped:Connect(function() if not settingsPanel.Visible then return end local ap=mainFrame.AbsolutePosition local as=mainFrame.AbsoluteSize settingsPanel.Position=UDim2.new(0,ap.X+as.X+6,0,ap.Y) end)
local spHdr=mkFrame({Size=UDim2.new(1,0,0,28),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=1011,Parent=settingsPanel}) corner(spHdr,10)
mkFrame({Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=1011,Parent=spHdr})
mkLabel({Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,10,0,0),Text="KEYBINDS",TextColor3=WHITE,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1012,Parent=spHdr})
local function makeKeybindRow(ltext,currentKey,yPos,bindId)
	mkLabel({Size=UDim2.new(0.55,0,0,30),Position=UDim2.new(0,10,0,yPos),Text=ltext,TextColor3=C.Text,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1011,Parent=settingsPanel})
	local kb=mkBtn({Size=UDim2.new(0,55,0,22),Position=UDim2.new(1,-65,0,yPos+4),BackgroundColor3=C.Surface,BorderSizePixel=0,Text="["..currentKey.."]",TextColor3=C.Accent,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=1012,Parent=settingsPanel}) corner(kb,6) stroke(kb,C.Border,1)
	kb.MouseButton1Click:Connect(function() if listeningFor then return end listeningFor=bindId;kb.Text="...";kb.TextColor3=Color3.fromRGB(220,120,60) end)
	return kb
end
local key1Btn=makeKeybindRow("TP Base 1",keybind1,34,"base1")
local key2Btn=makeKeybindRow("TP Base 2",keybind2,72,"base2")
local keySpBtn=makeKeybindRow("Admin Spam",keybindSpam,110,"spam")
mkLabel({Size=UDim2.new(1,-12,0,16),Position=UDim2.new(0,10,0,152),Text="Click key then press any key",TextColor3=C.TextDim,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1011,Parent=settingsPanel})
gearBtn.MouseButton1Click:Connect(function() settingsOpen=not settingsOpen;settingsPanel.Visible=settingsOpen end)
UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if listeningFor then
		if input.UserInputType~=Enum.UserInputType.Keyboard then return end
		local kn=tostring(input.KeyCode):gsub("Enum.KeyCode.","")
		if kn=="Escape" then
			if listeningFor=="base1" then key1Btn.Text="["..keybind1.."]";key1Btn.TextColor3=C.Accent
			elseif listeningFor=="base2" then key2Btn.Text="["..keybind2.."]";key2Btn.TextColor3=C.Accent
			else keySpBtn.Text="["..keybindSpam.."]";keySpBtn.TextColor3=C.Accent end
			listeningFor=nil;return
		end
		if listeningFor=="base1" then keybind1=kn;CONFIG.KEYBIND_BASE1=kn key1Btn.Text="["..kn.."]";key1Btn.TextColor3=C.Accent
		elseif listeningFor=="base2" then keybind2=kn;CONFIG.KEYBIND_BASE2=kn key2Btn.Text="["..kn.."]";key2Btn.TextColor3=C.Accent
		else keybindSpam=kn;CONFIG.KEYBIND_SPAM=kn keySpBtn.Text="["..kn.."]";keySpBtn.TextColor3=C.Accent end
		listeningFor=nil;saveConfig();return
	end
	if gameProcessed or input.UserInputType~=Enum.UserInputType.Keyboard then return end
	local kn=tostring(input.KeyCode):gsub("Enum.KeyCode.","") local char=player.Character if not char then return end
	if kn==(CONFIG.KEYBIND_SPAM or "X") then for _,plr in pairs(Players:GetPlayers()) do if plr~=player then spamExecute(plr,nil) end end return end
	if not desyncActivated then return end
	if kn==(CONFIG.KEYBIND_BASE1 or "E") then doTPBase1() elseif kn==(CONFIG.KEYBIND_BASE2 or "R") then doTPBase2() end
end)
local function createBaseESP()
	local espFolder=Instance.new("Folder") espFolder.Name="SakuraHubESP" espFolder.Parent=workspace
	for _,data in ipairs({{name="BASE 1",position=Vector3.new(-335,-5,18)},{name="BASE 2",position=Vector3.new(-336,-5,98)}}) do
		local part=Instance.new("Part") part.Name=data.name part.Size=Vector3.new(1,1,1) part.Position=data.position part.Anchored=true part.CanCollide=false part.Transparency=1 part.Parent=espFolder
		local bb=Instance.new("BillboardGui") bb.Adornee=part bb.Size=UDim2.new(0,200,0,50) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true bb.Parent=part
		local tl=mkLabel({Size=UDim2.new(1,0,0.6,0),Text=data.name,TextColor3=C.Accent,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0),TextSize=22,Font=Enum.Font.GothamBold,Parent=bb})
		local dl=mkLabel({Size=UDim2.new(1,0,0.4,0),Position=UDim2.new(0,0,0.6,0),Text="0 studs",TextColor3=WHITE,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0),TextSize=16,Font=Enum.Font.Gotham,Parent=bb})
		local pos=data.position
		RunService.Heartbeat:Connect(function() local char=player.Character if char then local hrp=char:FindFirstChild("HumanoidRootPart") if hrp then dl.Text=string.format("%.0f studs",(hrp.Position-pos).Magnitude) end end end)
	end
end
createBaseESP()
CONFIG.ENABLED=true enablePromptDetection()
player.CharacterAdded:Connect(function() task.wait(0.5) enablePromptDetection() end)

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
