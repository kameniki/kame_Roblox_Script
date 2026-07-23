-- サービス取得
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui", 10)
local RunService = game:GetService("RunService")

-- 1. Coinsテキストラベルを全探索
local function findCoinsText(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "Coins" and child:IsA("TextLabel") then
            return child
        elseif #child:GetChildren() > 0 then
            local found = findCoinsText(child)
            if found then return found end
        end
    end
    return nil
end

local coinsLabel = findCoinsText(PlayerGui)
if not coinsLabel then
    return  -- 見つからなければ何もしない
end

-- FPS計測用
local frameCount = 0
local timeAccum = 0
local currentFPS = 0
local forcedText = "Loading..."

-- 表示テキスト更新
local function updateDisplay()
    local pingSec = LP:GetNetworkPing()
    local pingMs = math.floor(pingSec * 1000)
    forcedText = "Ping: " .. pingMs .. " ms | FPS: " .. tostring(currentFPS)
    coinsLabel.Text = forcedText
end

-- 初回適用
updateDisplay()

-- 毎フレームFPS計測 + 1秒ごとにPing更新
RunService.RenderStepped:Connect(function(delta)
    frameCount = frameCount + 1
    timeAccum = timeAccum + delta
    if timeAccum >= 1 then
        currentFPS = math.floor(frameCount / timeAccum)
        frameCount = 0
        timeAccum = 0
        updateDisplay()
    end
end)

-- ゲーム側が書き換えても即座に戻す強制固定
coinsLabel:GetPropertyChangedSignal("Text"):Connect(function()
    if coinsLabel.Text ~= forcedText then
        coinsLabel.Text = forcedText
    end
end)
