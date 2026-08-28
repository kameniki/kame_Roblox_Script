local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
local Players = game:GetService("Players") 
local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local Workspace = game:GetService("Workspace") 
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({Name = "https://github.com/kameniki/ "}) 
local OmniTab = Window:CreateTab("Combat", nil)

local selectedHeight = "Spawn" 
local isLooping = false 
local loopThread = nil

-- Function definitions 
local function getAllPlayers() 
local players = {} 
for _, plr in pairs(Players:GetPlayers()) do 
if plr ~= LocalPlayer then table.insert(players, plr) end 
end 
return players 
end

local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")

local function spamOwnership(hrp) 
if not GrabEvents then return end 
local setOwner = GrabEvents:FindFirstChild("SetNetworkOwner") 
if setOwner and hrp then pcall(function() setOwner:FireServer(hrp, hrp.CFrame) end) end 
end

local function teleportToPlayer(myHrp, targetHrp) 
if not myHrp or not targetHrp then return end 
pcall(function() 
myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 5, 5) 
myHrp.AssemblyLinearVelocity = Vector3.zero 
end) 
end

local function destroyLineOnPlayer(hrp) 
if not GrabEvents then return end 
local createLine = GrabEvents:FindFirstChild("CreateGrabLine") 
local destroyLine = GrabEvents:FindFirstChild("DestroyGrabLine") 
if not createLine or not destroyLine then return end 
pcall(function() 
createLine:FireServer(hrp, CFrame.new(0, 1e9, 0)) 
task.wait() 
destroyLine:FireServer(hrp) 
end) 
end

-- Line lag control 
local lineLagThread = nil 
local lineLagEnabled = false

local function startLineLag() 
if lineLagEnabled then return end 
lineLagEnabled = true 
lineLagThread = coroutine.create(function() 
if not GrabEvents then return end 
local createLine = GrabEvents:FindFirstChild("CreateGrabLine") 
if not createLine then return end 
while lineLagEnabled do 
local spawnLocation = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
if spawnLocation then 
local randomX = math.random(-1e9, 1e9) 
local randomZ = math.random(-1e9, 1e9) 
local directions = {CFrame.new(randomX, 0, randomZ), CFrame.new(-randomX, 0, -randomZ), CFrame.new(randomX, 0, -randomZ), CFrame.new(-randomX, 0, randomZ)} 
for _, pos in pairs(directions) do createLine:FireServer(spawnLocation, pos) end 
end 
task.wait() 
end 
end) 
coroutine.resume(lineLagThread) 
end

local function stopLineLag() 
lineLagEnabled = false 
if lineLagThread then coroutine.close(lineLagThread); lineLagThread = nil end 
end

-- Main Destroy process 
local function performDestroy() 
local height = 8 
startLineLag() 
task.wait(1)

local players = getAllPlayers()
if #players == 0 then
    stopLineLag()
    Rayfield:Notify({Title = "Destroy", Content = "No target players found", Duration = 3})
    return false
end

local myChar = LocalPlayer.Character
local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
if not myHrp then stopLineLag(); return false end

local playerData = {}
for _, plr in ipairs(players) do
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then table.insert(playerData, {player = plr, hrp = hrp}) end
end

for _, data in ipairs(playerData) do
    teleportToPlayer(myHrp, data.hrp)
    task.wait(0.2)
    spamOwnership(data.hrp)
    task.wait()
end

local radius = 12
local angleStep = (math.pi * 2) / #playerData
for idx, data in ipairs(playerData) do
    local angle = (idx - 1) * angleStep
    local x = math.cos(angle) * radius
    local z = math.sin(angle) * radius

    pcall(function()
        data.hrp.CFrame = CFrame.new(x, height, z)
        data.hrp.AssemblyLinearVelocity = Vector3.zero
    end)

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bp.P = 40000000
    bp.Position = Vector3.new(x, height, z)
    bp.Parent = data.hrp
    task.delay(2, function() pcall(function() bp:Destroy() end) end)
    task.wait()
end

for i = 1, 8 do
    for _, data in ipairs(playerData) do destroyLineOnPlayer(data.hrp) end
    task.wait(0.3)
end

Rayfield:Notify({Title = "Destroy", Content = "1 cycle completed!", Duration = 2})
return true

end

-- Loop functions 
local function startLoop() 
if isLooping then 
Rayfield:Notify({Title = "Destroy", Content = "Already running", Duration = 2}) 
return 
end

isLooping = true
loopThread = coroutine.create(function()
    while isLooping do
        local success = performDestroy()
        if not success then
            isLooping = false
            break
        end
        task.wait(2) -- Wait time between cycles (adjustable)
    end
end)
coroutine.resume(loopThread)
Rayfield:Notify({Title = "Destroy", Content = "Loop started!", Duration = 2})

end

local function stopLoop() 
isLooping = false 
if loopThread then 
coroutine.close(loopThread) 
loopThread = nil 
end 
stopLineLag() 
Rayfield:Notify({Title = "Destroy", Content = "Loop stopped", Duration = 2}) 
end

-- UI Elements 
OmniTab:CreateDropdown({ 
Name = "Destroy Height Mode", 
Options = {"Spawn (Ground)", "Heaven (Sky)"}, 
CurrentOption = "Spawn (Ground)", 
Callback = function(Value) 
selectedHeight = (Value == "Heaven (Sky)") and "Heaven" or "Spawn" 
end 
})

OmniTab:CreateButton({ 
Name = "Start Loop Destroy", 
Callback = function() 
startLoop() 
end 
})

OmniTab:CreateButton({ 
Name = "Stop Loop Destroy", 
Callback = function() 
stopLoop() 
end 
})

OmniTab:CreateButton({ 
Name = "Destroy Server (Single)", 
Callback = function() 
task.spawn(function() 
performDestroy() 
end) 
end 
})

OmniTab:CreateButton({ 
Name = "Stop Lag", 
Callback = function() 
stopLineLag() 
Rayfield:Notify({Title = "Lag", Content = "Lag stopped", Duration = 2}) 
end 
})
