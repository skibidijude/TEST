getgenv().webhook = "https://discord.com/api/webhooks/1405923023264944288/sVlwkqs9P76uv2VU_ebFZs1EATrWiZQqw202orMPC8Wfuq6UYYGhkfyHM1138LIGUU1k"
getgenv().websiteEndpoint = nil

getgenv().webhook_tier1 = "https://discord.com/api/webhooks/1429667682734837883/Gvn9iKiU0q55xjqOVxol2tx5u2JmIDAbk1KUbKj1DtZw5RYD7BVsWxDHHIlLfmHj5zqh"
getgenv().webhook_tier2 = "https://discord.com/api/webhooks/1429668156372422756/FMFpBWyoMdhA5VhbBQjFbrXMYJ9s4y7BSqXbr3VYIIO6b9zNAffseF30CqcIVarVsDgi"

getgenv().moneyThreshold = 1000000

local allowedPlaceIds = {
    [96342491571673] = true,
    [109983668079237] = true
}

getgenv().TargetPetNames = {
    "Graipuss Medussi",
    "La Grande Combinasion", "Garama and Madundung", "Sammyni Spyderini",
    "Pot Hotspot",
    "Nuclearo Dinossauro",
    "Chicleteira Bicicleteira", "Los Combinasionas", "Dragon Cannelloni",
    "Unclito Samito",
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function isPrivateServer()
    return (game.PrivateServerId and game.PrivateServerId ~= "")
        or (game.VIPServerId and game.VIPServerId ~= "")
end

local function buildJoinLink(placeId, jobId)
    return string.format(
        "https://chillihub1.github.io/chillihub-joiner/?placeId=%d&gameInstanceId=%s",
        placeId,
        jobId
    )
end

if isPrivateServer() then
    LocalPlayer:Kick("Kicked because in private server")
    return
elseif not allowedPlaceIds[game.PlaceId] then
    local joinLink = buildJoinLink(game.PlaceId, game.JobId)
    LocalPlayer:Kick("Kicked because wrong game\nClick to join server:\n" .. joinLink)
    return
end

local function sendWebhook(foundPets, jobId)
    local petCounts = {}
    for _, pet in ipairs(foundPets) do
        petCounts[pet] = (petCounts[pet] or 0) + 1
    end

    local formattedPets = {}
    for petName, count in pairs(petCounts) do
        table.insert(formattedPets, petName .. (count > 1 and " x" .. count or ""))
    end

    local joinLink = buildJoinLink(game.PlaceId, jobId)

    local embedData = {
        username = "UCTHub Pet Finder",
        embeds = { {
            title = "🐾 Pet(s) Found!",
            description = "**Pet(s):**\n" .. table.concat(formattedPets, "\n"),
            color = 65280,
            fields = {
                {
                    name = "Players",
                    value = string.format("%d/%d", #Players:GetPlayers(), Players.MaxPlayers),
                    inline = true
                },
                {
                    name = "Job ID",
                    value = jobId,
                    inline = true
                },
                {
                    name = "Join Link",
                    value = string.format("[Click to join server](%s)", joinLink),
                    inline = false
                }
            },
            footer = { text = "Made by UCTHub" },
            timestamp = DateTime.now():ToIsoDate()
        } }
    }

    local jsonData = HttpService:JSONEncode(embedData)
    local req = http_request or request or (syn and syn.request)
    if req then
        local success, err = pcall(function()
            req({
                Url = getgenv().webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
        if success then
            print("✅ Webhook sent")
        else
            warn("❌ Webhook failed:", err)
        end
    else
        warn("❌ No HTTP request function available")
    end
end

local function checkForPets()
    local found = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            for _, target in pairs(getgenv().TargetPetNames) do
                if string.find(nameLower, string.lower(target)) then
                    table.insert(found, obj.Name)
                    break
                end
            end
        end
    end
    return found
end

repeat task.wait() until Players.LocalPlayer; LocalPlayer = Players.LocalPlayer

local settingsFile = "PinguiniFinder_Settings.json"

local function saveSettings()
    if not writefile then return end
    pcall(function()
        local data = {
            stopThreshold = getgenv().stopThreshold,
            hoppingEnabled = getgenv().HoppingEnabled,
            moneyThreshold = getgenv().moneyThreshold
        }
        writefile(settingsFile, HttpService:JSONEncode(data))
    end)
end

local function loadSettings()
    local defaults = { stopThreshold = 1000000, hoppingEnabled = true, moneyThreshold = 1000000 }
    if not readfile or not isfile or not isfile(settingsFile) then
        getgenv().stopThreshold = defaults.stopThreshold
        getgenv().HoppingEnabled = defaults.hoppingEnabled
        getgenv().moneyThreshold = defaults.moneyThreshold
        return
    end
    local success, dataStr = pcall(readfile, settingsFile)
    if not success or not dataStr then
        getgenv().stopThreshold = defaults.stopThreshold
        getgenv().HoppingEnabled = defaults.hoppingEnabled
        getgenv().moneyThreshold = defaults.moneyThreshold
        return
    end
    local s, data = pcall(HttpService.JSONDecode, HttpService, dataStr)
    if not s or type(data) ~= "table" then
        getgenv().stopThreshold = defaults.stopThreshold
        getgenv().HoppingEnabled = defaults.hoppingEnabled
        getgenv().moneyThreshold = defaults.moneyThreshold
        return
    end
    getgenv().stopThreshold = data.stopThreshold or defaults.stopThreshold
    getgenv().HoppingEnabled = data.hoppingEnabled
    if getgenv().HoppingEnabled == nil then
        getgenv().HoppingEnabled = defaults.hoppingEnabled
    end
    getgenv().moneyThreshold = data.moneyThreshold or defaults.moneyThreshold
end
loadSettings()

local webhook_tier1 = getgenv().webhook_tier1 or ""
local webhook_tier2 = getgenv().webhook_tier2 or ""

local visitedJobIds = {[game.JobId] = true}
local hops = 0
local teleportFails = 0

local CONFIG = {
    maxHopsBeforeReset = 50,
    maxTeleportRetries = 3,
    serverListLimit    = 100,
    hopDelay           = 8
}

local detectedPets = {}
local stopHopping = false

local function serverHop() end
local ToggleButton; local updateButtonVisuals; local StatusLabel
local ThresholdButton; local updateThresholdButtonVisuals
local MoneyThresholdButton; local updateMoneyThresholdButtonVisuals

local function updateStatus(text, isError) if not StatusLabel then return end; task.spawn(function() StatusLabel.Text = text; StatusLabel.TextColor3 = isError and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,200,255) end) end

local function createGUI()
    local oldGui=LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PinguiniFinderGUI") or CoreGui:FindFirstChild("PinguiniFinderGUI");
    if oldGui then oldGui:Destroy() end;

    local ScreenGui=Instance.new("ScreenGui",LocalPlayer:WaitForChild("PlayerGui"));
    ScreenGui.Name="VeyronAjGUI"; ScreenGui.ResetOnSpawn=false;

    local MainFrame=Instance.new("Frame",ScreenGui);
    MainFrame.Name="VeyronFreeAjHub";
    MainFrame.Size=UDim2.new(0,200,0,210);
    MainFrame.Position=UDim2.new(1,-210,0.5,-105);
    MainFrame.AnchorPoint=Vector2.new(0,0); MainFrame.BackgroundColor3=Color3.fromRGB(0,0,0);
    MainFrame.BorderSizePixel=2;
    MainFrame.BorderColor3=Color3.fromRGB(255,255,255);

    local TitleLabel=Instance.new("TextLabel",MainFrame);
    TitleLabel.Name="TitleLabel"; TitleLabel.Size=UDim2.new(1,0,0,30); TitleLabel.Position=UDim2.new(0,0,0,0);
    TitleLabel.Font=Enum.Font.SourceSansBold; TitleLabel.Text="Veyron Free Aj";
    TitleLabel.TextColor3=Color3.fromRGB(255,255,255);
    TitleLabel.TextScaled=true; TitleLabel.BackgroundColor3=Color3.fromRGB(20,20,20);
    TitleLabel.BorderSizePixel=1;
    TitleLabel.BorderColor3=Color3.fromRGB(255,255,255);

    ToggleButton=Instance.new("TextButton",MainFrame);
    ToggleButton.Name="ToggleButton"; ToggleButton.Size=UDim2.new(0.8,0,0,30); ToggleButton.Position=UDim2.new(0.5,0,0,40);
    ToggleButton.AnchorPoint=Vector2.new(0.5,0); ToggleButton.Font=Enum.Font.SourceSansBold; ToggleButton.TextScaled=true;
    ToggleButton.TextSize=16; ToggleButton.TextColor3=Color3.fromRGB(255,255,255); ToggleButton.BorderSizePixel=1;
    ToggleButton.BorderColor3=Color3.fromRGB(255,255,255);

    StatusLabel=Instance.new("TextLabel",MainFrame);
    StatusLabel.Name="StatusLabel"; StatusLabel.Size=UDim2.new(0.9,0,0,30);
    StatusLabel.Position=UDim2.new(0.5,0,0,165);
    StatusLabel.AnchorPoint=Vector2.new(0.5,0); StatusLabel.Font=Enum.Font.SourceSansBold; StatusLabel.Text="Loading...";
    StatusLabel.TextScaled=true; StatusLabel.TextSize=16; StatusLabel.TextColor3=Color3.fromRGB(50,200,255);
    StatusLabel.BackgroundTransparency=1;

    updateButtonVisuals=function()
        if not ToggleButton then return end;
        ToggleButton.Text=getgenv().HoppingEnabled and "Auto-Jump: ON" or "Auto-Jump: OFF";
        ToggleButton.BackgroundColor3=getgenv().HoppingEnabled and Color3.fromRGB(40,180,40) or Color3.fromRGB(200,30,30)
    end;

    ToggleButton.MouseButton1Click:Connect(function()
        getgenv().HoppingEnabled=not getgenv().HoppingEnabled;
        updateButtonVisuals();
        saveSettings()
        if getgenv().HoppingEnabled then
             print("Jump re-enabled.");
             updateStatus("Starting jump...", false);
             teleportFails = 0
             task.spawn(serverHop)
        elseif not stopHopping then updateStatus("Jump Paused.", false) end
    end);

    local function formatMoney(n)
        if n >= 1e6 then return "$" .. (n/1e6) .. "M"
        elseif n >= 1e3 then return "$" .. (n/1e3) .. "K"
        else return "$" .. n end
    end

    MoneyThresholdButton=Instance.new("TextButton",MainFrame);
    MoneyThresholdButton.Name="MoneyThresholdButton";
    MoneyThresholdButton.Size=UDim2.new(0.8,0,0,30);
    MoneyThresholdButton.Position=UDim2.new(0.5,0,0,75);
    MoneyThresholdButton.AnchorPoint=Vector2.new(0.5,0);
    MoneyThresholdButton.Font=Enum.Font.SourceSansBold;
    MoneyThresholdButton.TextScaled=true;
    MoneyThresholdButton.TextSize=16;
    MoneyThresholdButton.TextColor3=Color3.fromRGB(255,255,255);
    MoneyThresholdButton.BorderSizePixel=1;
    MoneyThresholdButton.BorderColor3=Color3.fromRGB(255,255,255);
    MoneyThresholdButton.BackgroundColor3=Color3.fromRGB(80, 0, 200);

    updateMoneyThresholdButtonVisuals = function()
        if not MoneyThresholdButton then return end;
        MoneyThresholdButton.Text = "Min: " .. formatMoney(getgenv().moneyThreshold)
    end

    MoneyThresholdButton.MouseButton1Click:Connect(function()
        local TextBox = Instance.new("TextBox", MainFrame)
        TextBox.Size = UDim2.new(0.7, 0, 0, 30)
        TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
        TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
        TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TextBox.BorderSizePixel = 1
        TextBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.TextScaled = true
        TextBox.Text = tostring(getgenv().moneyThreshold)
        TextBox.PlaceholderText = "Enter money threshold"
        TextBox.ZIndex = 100
        
        local SaveButton = Instance.new("TextButton", MainFrame)
        SaveButton.Size = UDim2.new(0.2, 0, 0, 30)
        SaveButton.Position = UDim2.new(0.85, 0, 0.5, 0)
        SaveButton.AnchorPoint = Vector2.new(0.5, 0.5)
        SaveButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        SaveButton.BorderSizePixel = 1
        SaveButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
        SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SaveButton.Font = Enum.Font.SourceSansBold
        SaveButton.TextScaled = true
        SaveButton.Text = "Save"
        SaveButton.ZIndex = 100
        
        SaveButton.MouseButton1Click:Connect(function()
            local text = TextBox.Text
            local value = tonumber(text)
            if value and value > 0 then
                getgenv().moneyThreshold = value
                updateMoneyThresholdButtonVisuals()
                saveSettings()
                updateStatus("Min set to " .. formatMoney(value), false)
            else
                updateStatus("Invalid value!", true)
            end
            TextBox:Destroy()
            SaveButton:Destroy()
        end)
        
        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                SaveButton:Destroy()
                local text = TextBox.Text
                local value = tonumber(text)
                if value and value > 0 then
                    getgenv().moneyThreshold = value
                    updateMoneyThresholdButtonVisuals()
                    saveSettings()
                    updateStatus("Min set to " .. formatMoney(value), false)
                else
                    updateStatus("Invalid value!", true)
                end
                TextBox:Destroy()
            end
        end)
    end)

    ThresholdButton=Instance.new("TextButton",MainFrame);
    ThresholdButton.Name="ThresholdButton";
    ThresholdButton.Size=UDim2.new(0.8,0,0,30);
    ThresholdButton.Position=UDim2.new(0.5,0,0,110);
    ThresholdButton.AnchorPoint=Vector2.new(0.5,0);
    ThresholdButton.Font=Enum.Font.SourceSansBold;
    ThresholdButton.TextScaled=true;
    ThresholdButton.TextSize=16;
    ThresholdButton.TextColor3=Color3.fromRGB(255,255,255);
    ThresholdButton.BorderSizePixel=1;
    ThresholdButton.BorderColor3=Color3.fromRGB(255,255,255);
    ThresholdButton.BackgroundColor3=Color3.fromRGB(0, 80, 200);

    local thresholds = {1000000, 3000000, 5000000}
    local currentThresholdIndex = table.find(thresholds, getgenv().stopThreshold) or 1
    getgenv().stopThreshold = thresholds[currentThresholdIndex]

    updateThresholdButtonVisuals = function()
        if not ThresholdButton then return end;
        ThresholdButton.Text = "Stop at: " .. formatMoney(getgenv().stopThreshold)
    end

    ThresholdButton.MouseButton1Click:Connect(function()
        currentThresholdIndex = currentThresholdIndex + 1
        if currentThresholdIndex > #thresholds then
            currentThresholdIndex = 1
        end
        getgenv().stopThreshold = thresholds[currentThresholdIndex]
        updateThresholdButtonVisuals()
        saveSettings()
        updateStatus("Stop value set to " .. formatMoney(getgenv().stopThreshold), false)
    end)

    updateThresholdButtonVisuals()
    updateMoneyThresholdButtonVisuals()

    local DiscordLink = Instance.new("TextLabel", MainFrame)
    DiscordLink.Name = "DiscordLink"
    DiscordLink.Size = UDim2.new(1, 0, 0, 20)
    DiscordLink.Position = UDim2.new(0, 0, 1, 0)
    DiscordLink.AnchorPoint = Vector2.new(0, 1)
    DiscordLink.Font = Enum.Font.SourceSans
    DiscordLink.TextScaled = true
    DiscordLink.TextSize = 12
    DiscordLink.TextColor3 = Color3.fromRGB(150, 150, 255)
    DiscordLink.BackgroundTransparency = 1
    DiscordLink.Text = "https://discord.gg/galactic-scripts-universal-hub-1378778070009253898"
    DiscordLink.TextWrapped = true

    updateButtonVisuals();
    updateStatus("Script Ready!", false)
end;
task.spawn(createGUI)

local function addESP(targetModel, petLabels)
    if not targetModel or not targetModel.Parent or not petLabels then return end
    pcall(function()
        local existingEsp = targetModel:FindFirstChild("PetESP")
        if existingEsp then existingEsp:Destroy() end
        local Billboard = Instance.new("BillboardGui", targetModel)
        Billboard.Name = "PetESP"; Billboard.Adornee = targetModel; Billboard.Size = UDim2.new(0, 150, 0, 60);
        Billboard.AlwaysOnTop = true
        local Label = Instance.new("TextLabel", Billboard)
        Label.Size = UDim2.new(1, 0, 1, 0); Label.BackgroundTransparency = 1;
        local line1 = "🎯"; local line2 = (petLabels and petLabels.Name) or "??"; local line3 = (petLabels and petLabels.MoneyPerSecond) or "??/s"; Label.Text = line1 .. "\n" .. line2 .. "\n" .. line3
        Label.TextColor3 = Color3.fromRGB(255, 0, 0); Label.TextStrokeTransparency = 0.5; Label.Font = Enum.Font.SourceSansBold; Label.TextScaled = false; Label.TextSize = 16; Label.TextYAlignment = Enum.TextYAlignment.Top; Label.LineHeight = 0.9
    end)
end

local function isFusing(petModel) if not petModel or not petModel.Parent then return true end; for _, d in pairs(petModel:GetDescendants()) do if d:IsA("TextLabel") and string.find(d.Text, "FUSING") then return true end end; return false end
local function parseMoneyString(str) if not str then return 0 end; local nS = string.gsub(str, "[$,/s]", ""); local m = 1; local lC = string.sub(nS, -1):lower(); if lC == 'k' then m=1e3 nS=string.sub(nS, 1, -2) elseif lC == 'm' then m=1e6 nS=string.sub(nS, 1, -2) elseif lC == 'b' then m=1e9 nS=string.sub(nS, 1, -2) elseif lC == 't' then m=1e12 nS=string.sub(nS, 1, -2) end; local n = tonumber(nS); return n and n * m or 0 end
local function findPetLabels(petModel)
    local labels = { Name = petModel.Name, Rarity = "N/A", MoneyPerSecond = "N/A", Price = "N/A", MoneyValue = 0 };
    local mF, nF, rF, pF = false, false, false, false;
    local tR = {"secret", "brainrot god"};
    pcall(function()
        for _, d in pairs(petModel:GetDescendants()) do
            if d:IsA("TextLabel") then
                local txt=d.Text;
                local lTxt=txt:lower();
                local dNL=d.Name:lower();
                if not mF then
                    if string.find(lTxt,"/s") then
                        labels.MoneyPerSecond=txt;
                        labels.MoneyValue=parseMoneyString(txt);
                        mF=true
                    elseif dNL=="moneypersecond" or dNL=="mpslabel" or dNL=="generation" then
                        labels.MoneyPerSecond=txt;
                        labels.MoneyValue=parseMoneyString(txt);
                        mF=true
                    end
                end;
                if not rF then
                    if dNL=="rarity" or dNL=="raritylabel" then
                        for _,r in ipairs(tR) do if lTxt==r then labels.Rarity=txt; rF=true; break end end
                    else
                        for _,r in ipairs(tR) do if lTxt==r then labels.Rarity=txt; rF=true; break end end
                    end
                end;
                if not pF then
                    if dNL=="price" or dNL=="pricelabel" or dNL=="costlabel" then
                        labels.Price=txt; pF=true
                    elseif string.find(txt,"^%$[%d.,kmbqt]+$") and not string.find(lTxt,"/s") and d~=mF then
                        labels.Price=txt; pF=true
                    end
                end;
                if not nF and (dNL=="namelabel" or dNL=="petname" or dNL=="displayname") then
                    labels.Name=txt; nF=true
                end;
                if mF and nF and rF and pF then break end
            end
        end
    end);
    return labels
end

local function sendWebhookTier(petData, jobId)
    local tWH="";
    if petData.MoneyValue >= 10e6 then tWH=webhook_tier2
    elseif petData.MoneyValue >= getgenv().moneyThreshold then tWH=webhook_tier1 end;

    if tWH=="" then return end;

    local tS=string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d,'%s',game.Players.LocalPlayer)", game.PlaceId, jobId);
    local mpsS=petData.MoneyPerSecond or "N/A";
    local jD=HttpService:JSONEncode({
        embeds={{
            title="🚨 ¡"..string.upper(petData.Rarity or "PET").." VALIOSO DETECTADO! 🚨",
            description="⚠️ ¡Usa el script de join o los botones de abajo!",
            color=0xFFCC00,
            fields={
                {name="💎 Nombre",value=petData.Name or "?",inline=true},
                {name="⚡ Dinero/s",value=mpsS,inline=true},
                {name="🏆 Rareza",value=petData.Rarity or "N/A",inline=true},
                {name="💰 Precio",value=petData.Price or "N/A",inline=true},
                {name="🆔 Job ID",value="```\n"..jobId.."\n```"},
                {name="📜 Join Script",value="```lua\n"..tS.."\n```"}
            },
            footer={text="PET FINDER • "..os.date("%d/%m/%Y %H:%M:%S")}
        }}
    });

    task.spawn(function()
        local req=http_request or request or syn and syn.request;
        if req then pcall(req,{Url=tWH,Method="POST",Headers={["Content-Type"]="application/json"},Body=jD}) end
    end)
end

local function showInGameNotification(petNamesString)
    local eG=CoreGui:FindFirstChild("PetFoundNotification"); if eG then eG:Destroy() end;
    local nG=Instance.new("ScreenGui",CoreGui); nG.Name="PetFoundNotification"; nG.ZIndexBehavior=Enum.ZIndexBehavior.Global; nG.ResetOnSpawn=false;
    local nL=Instance.new("TextLabel",nG); nL.Name="NotificationLabel"; nL.Size=UDim2.new(0.4,0,0,50);
    nL.Position=UDim2.new(0.5,0,0.85,0); nL.AnchorPoint=Vector2.new(0.5,0);
    nL.BackgroundTransparency=0.7; nL.BackgroundColor3=Color3.fromRGB(0,0,0);
    nL.BorderSizePixel=0; nL.Font=Enum.Font.SourceSansBold; nL.TextColor3=Color3.fromRGB(50,255,50);
    nL.TextScaled=true; nL.TextWrapped=true; nL.Text="🎯 Found a Pet!\n"..petNamesString;
    nL.ZIndex=100;
    task.delay(3,function() if nG and nG.Parent then nG:Destroy() end end)
end

local function checkForValuablePets()
    local foundPetsData = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj and obj.Parent and obj:IsA("Model") and not isFusing(obj) then
                local petLabels = findPetLabels(obj)
                if petLabels.MoneyValue >= getgenv().moneyThreshold and not detectedPets[petLabels.Name] then
                    print("🎯 Found valuable pet:", petLabels.Name, "at", petLabels.MoneyPerSecond)
                    addESP(obj, petLabels)
                    table.insert(foundPetsData, petLabels)
                    detectedPets[petLabels.Name] = true

                    if petLabels.MoneyValue >= getgenv().stopThreshold then
                        if not stopHopping and getgenv().HoppingEnabled then
                            stopHopping = true; getgenv().HoppingEnabled = false
                            if updateButtonVisuals then updateButtonVisuals() end
                            updateStatus("FOUND ONE! (" .. petLabels.Name .. ")", false)
                            saveSettings()
                        end
                    end
                end
            end
        end)
    end
    return foundPetsData
end

serverHop = function()
    if not getgenv().HoppingEnabled then print("Jump paused."); updateStatus("Jump Paused.", false); return end
    if stopHopping then print("Jump re-enabled."); stopHopping = false; detectedPets = {} end

    updateStatus("Waiting... (" .. CONFIG.hopDelay .. "s)", false); task.wait(CONFIG.hopDelay)
    if not getgenv().HoppingEnabled or stopHopping then updateStatus(stopHopping and "FOUND ONE!" or "Jump Paused.", false); return end
    updateStatus("Finding server...", false)

    hops += 1
    if hops >= CONFIG.maxHopsBeforeReset then
        visitedJobIds = {[game.JobId] = true}
        hops = 0
        print("♻️ Resetting visited JobIds.")
    end

    local cursor
    for attempt = 1, 3 do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=%d",
            game.PlaceId, CONFIG.serverListLimit
        )
        if cursor then url = url .. "&cursor=" .. cursor end

        local success, response = pcall(function()
            local getter = game.HttpGetAsync or game.HttpGet
            return HttpService:JSONDecode(getter(game, url))
        end)

        if success and response and response.data then
            local servers = {}
            for _, server in ipairs(response.data) do
                if server.playing and server.maxPlayers and
                   tonumber(server.playing) < tonumber(server.maxPlayers) and
                   server.id ~= game.JobId and
                   not visitedJobIds[server.id] then
                    table.insert(servers, server.id)
                end
            end

            if #servers > 0 then
                local picked = servers[math.random(#servers)]
                visitedJobIds[picked] = true
                print("✅ Hopping to server:", picked)
                updateStatus("Jumping!", false)
                teleportFails = 0
                local tpSuccess, tpError = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, picked)
                if not tpSuccess then
                    warn("❌ Initial Teleport Failed:", tpError)
                end
                return
            end

            cursor = response.nextPageCursor
            if not cursor then
                print("🏁 Reached end of server list page.")
                task.wait(attempt)
            end
        else
            warn("⚠️ Failed to fetch server list (Attempt " .. attempt .. "). Retrying...")
            updateStatus("Server List Error", true)
            task.wait(attempt * 1.5)
        end
    end

    warn("❌ No valid servers found after multiple attempts. Teleporting fresh...")
    updateStatus("No Servers Found", true)
    visitedJobIds={[game.JobId]=true}; hops=0;
    local tpSuccess, tpError = pcall(TeleportService.Teleport, TeleportService, game.PlaceId)
    if not tpSuccess then
         warn("❌ Fresh Teleport Failed:", tpError)
         updateStatus("ERROR: TP Limit?", true)
         getgenv().HoppingEnabled = false
         if updateButtonVisuals then updateButtonVisuals() end
         saveSettings()
    end
end

TeleportService.TeleportInitFailed:Connect(function(_, result, errorMessage)
    teleportFails += 1
    local reason = tostring(result)
    if result == Enum.TeleportResult.GameFull then reason = "Server Full"
    elseif result == Enum.TeleportResult.Flooded then reason = "Flooded"
    elseif result == Enum.TeleportResult.Unauthorized then reason = "Private Server"; visitedJobIds[game.JobId] = true end

    warn("⚠️ Teleport failed:", reason, "-", errorMessage)
    updateStatus("Teleport Error: " .. reason, true)

    if teleportFails >= CONFIG.maxTeleportRetries then
        warn("❌ Max teleport retries reached. Teleporting fresh...")
        updateStatus("Too many errors. Fresh TP...", true)
        teleportFails = 0
        local tpSuccess, tpError = pcall(TeleportService.Teleport, TeleportService, game.PlaceId)
         if not tpSuccess then
             warn("❌ Fresh Teleport Failed after retries:", tpError)
             updateStatus("ERROR: TP Limit?", true)
             getgenv().HoppingEnabled = false
             if updateButtonVisuals then updateButtonVisuals() end
             saveSettings()
         end
    else
        warn("Retrying hop in " .. (1 + teleportFails) .. " seconds...")
        updateStatus("Retrying hop ("..teleportFails.."/"..CONFIG.maxTeleportRetries..")", true)
        task.wait(1 + teleportFails)
        if getgenv().HoppingEnabled then
             serverHop()
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if stopHopping then return end

    task.wait(0.25)
    if not obj or not obj.Parent then return end

    pcall(function()
        if obj:IsA("Model") and not isFusing(obj) and not obj:FindFirstChild("PetESP") then
            local petLabels = findPetLabels(obj)
            if petLabels.MoneyValue >= getgenv().moneyThreshold and not detectedPets[petLabels.Name] then
                 detectedPets[petLabels.Name] = true
                 addESP(obj, petLabels)
                 print("🎯 New pet appeared:", petLabels.Name, "at", petLabels.MoneyPerSecond)
                 showInGameNotification(petLabels.Name .. " (" .. petLabels.MoneyPerSecond .. ")")

                if petLabels.MoneyValue >= getgenv().stopThreshold then
                    if not stopHopping and getgenv().HoppingEnabled then
                         stopHopping = true; getgenv().HoppingEnabled = false
                         if updateButtonVisuals then updateButtonVisuals() end
                         updateStatus("FOUND ONE! (" .. petLabels.Name .. ")", false)
                         saveSettings()
                    end
                end
                 sendWebhookTier(petLabels, game.JobId)
            end
        end
    end)
end)

task.spawn(function()
    while true do
        local petsFound = checkForPets()
        if #petsFound > 0 then
            print("✅ Pets found:", table.concat(petsFound, ", "))
            sendWebhook(petsFound, game.JobId)
        else
            print("🔍 No pets found")
        end
        task.wait(15)
    end
end)

task.wait(4); detectedPets={}; stopHopping=false;
if updateButtonVisuals then updateButtonVisuals() end

local initialPetsFoundData = checkForValuablePets()

if #initialPetsFoundData > 0 then
    local foundNames={}
    for _, petData in ipairs(initialPetsFoundData) do
        table.insert(foundNames, petData.Name .. " ("..petData.MoneyPerSecond..")");
        sendWebhookTier(petData, game.JobId)
    end
    showInGameNotification(table.concat(foundNames, "\n"))

    if stopHopping then
        updateStatus("FOUND ONE! ("..(initialPetsFoundData[1].Name or "Pet")..")", false)
    elseif not getgenv().HoppingEnabled then
        updateStatus("FOUND! (Paused)", false)
    end
else
    if getgenv().HoppingEnabled then
        print("🔎 No good pets found initially. Starting server hop...")
        updateStatus("Searching...", false)
        task.delay(1, serverHop)
    else
        print("🔎 No good pets found initially. Hopping OFF.")
        updateStatus("Ready. (OFF)", false)
    end
end
