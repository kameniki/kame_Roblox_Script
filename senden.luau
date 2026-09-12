local players = game:GetService("Players")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DISPLAY_TEXT = "Get Script:github.com/kameniki Open_source!Best Scripts"
local BOUNCE_SPEED = 0.007
local GLOW_SPEED = 0.6
-- ------------------

if playerGui:FindFirstChild("PureDVDWatermark") then
    playerGui.PureDVDWatermark:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "PureDVDWatermark"
sg.Parent = playerGui
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false

local bg = Instance.new("Frame", sg)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.BorderSizePixel = 0

local msg = Instance.new("TextLabel", bg)
msg.Size = UDim2.new(0, 400, 0, 60) -- メッセージが長い場合はここを広げて
msg.BackgroundTransparency = 1
msg.Text = DISPLAY_TEXT
msg.TextColor3 = Color3.new(1, 1, 1)
msg.TextSize = 30
msg.Font = Enum.Font.FredokaOne
msg.TextStrokeTransparency = 0.5

local posX, posY = math.random(), math.random()
local velX, velY = BOUNCE_SPEED, BOUNCE_SPEED

runService.RenderStepped:Connect(function()

    local hue = (tick() * GLOW_SPEED) % 1
    bg.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 1)

    local absSize = bg.AbsoluteSize
    if absSize.X == 0 then return end

   
    posX = posX + velX
    posY = posY + velY

   
    local sizeRatioX = msg.Size.X.Offset / absSize.X
    local sizeRatioY = msg.Size.Y.Offset / absSize.Y

    if posX <= 0 then
        posX = 0
        velX = -velX
    elseif posX + sizeRatioX >= 1 then
        posX = 1 - sizeRatioX
        velX = -velX
    end

    if posY <= 0 then
        posY = 0
        velY = -velY
    elseif posY + sizeRatioY >= 1 then
        posY = 1 - sizeRatioY
        velY = -velY
    end

    msg.Position = UDim2.new(posX, 0, posY, 0)
    
    msg.TextStrokeColor3 = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
end)
