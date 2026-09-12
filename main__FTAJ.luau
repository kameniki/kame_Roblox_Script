local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local events = {
	"KorbloxEvent",
	"FakeChatEvent",
	"PlayAnim",
	"SpawnDinoEvent",
	"TransformDragon"
}

local fakeChatLoop = false

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteTester"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(340, 350)
window.Position = UDim2.new(0.5, -170, 0.5, -175)
window.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
window.BorderSizePixel = 0
window.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = window

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 65)
header.BackgroundTransparency = 1
header.Parent = window

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 32)
title.Position = UDim2.fromOffset(15, 8)
title.BackgroundTransparency = 1
title.Text = "FTAJ.is.dumb"
title.TextColor3 = Color3.fromRGB(245, 245, 248)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 18)
subtitle.Position = UDim2.fromOffset(15, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "made by kameniki"
subtitle.TextColor3 = Color3.fromRGB(145, 145, 155)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -30, 0, 1)
divider.Position = UDim2.fromOffset(15, 65)
divider.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
divider.BorderSizePixel = 0
divider.Parent = window

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -30, 0, 260)
container.Position = UDim2.fromOffset(15, 78)
container.BackgroundTransparency = 1
container.Parent = window

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

for _, eventName in ipairs(events) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 43)
	button.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	button.BorderSizePixel = 0
	button.Text = eventName
	button.TextColor3 = Color3.fromRGB(235, 235, 240)
	button.TextSize = 14
	button.Font = Enum.Font.GothamMedium
	button.AutoButtonColor = false
	button.Parent = container

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 9)
	buttonCorner.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
	end)

	button.MouseLeave:Connect(function()
		if eventName == "FakeChatEvent" and fakeChatLoop then
			button.BackgroundColor3 = Color3.fromRGB(55, 125, 75)
		else
			button.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
		end
	end)

	button.MouseButton1Click:Connect(function()
		local event = ReplicatedStorage:FindFirstChild(eventName)

		if not event or not event:IsA("RemoteEvent") then
			button.Text = "RemoteEvent not found"

			task.delay(1, function()
				if button.Parent then
					button.Text = eventName
				end
			end)

			return
		end

		if eventName == "FakeChatEvent" then
			fakeChatLoop = not fakeChatLoop

			if fakeChatLoop then
				button.Text = "● FakeChatEvent  ON"
				button.BackgroundColor3 = Color3.fromRGB(55, 125, 75)
			else
				button.Text = "○ FakeChatEvent  OFF"
				button.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
			end
		else
			event:FireServer()

			local oldText = button.Text
			button.Text = "✓  " .. eventName

			task.delay(0.7, function()
				if button.Parent then
					button.Text = oldText
				end
			end)
		end
	end)
end

RunService.Heartbeat:Connect(function()
	if not fakeChatLoop then
		return
	end

	local event = ReplicatedStorage:FindFirstChild("FakeChatEvent")

	if event and event:IsA("RemoteEvent") then
		event:FireServer()
	end
end)

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = window.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		window.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)
