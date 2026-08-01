local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local StarterGui = game:GetService("StarterGui")
local function Notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 2
    })
end

-- ===== 固定設定 =====
local DECAL_ID = "rbxassetid://89027170969335"
local WALL_TRANSPARENCY = 0.0      -- 壁は透明にしない
local BODY_TRANSPARENCY = 1.0      -- 体は完全透明
local UPDATE_INTERVAL = 60         -- 1分（秒）

-- ===== R15 / R6 ボディパーツ名リスト =====
local bodyPartNames = {
    ["Head"] = true,
    ["Torso"] = true,
    ["Left Arm"] = true,
    ["Right Arm"] = true,
    ["Left Leg"] = true,
    ["Right Leg"] = true,
    ["UpperTorso"] = true,
    ["LowerTorso"] = true,
    ["LeftUpperArm"] = true,
    ["LeftLowerArm"] = true,
    ["LeftHand"] = true,
    ["RightUpperArm"] = true,
    ["RightLowerArm"] = true,
    ["RightHand"] = true,
    ["LeftUpperLeg"] = true,
    ["LeftLowerLeg"] = true,
    ["LeftFoot"] = true,
    ["RightUpperLeg"] = true,
    ["RightLowerLeg"] = true,
    ["RightFoot"] = true,
}

-- ===== 貼り付け済みデカール管理 =====
local placedDecals = {}

-- ===== 透明化用の元プロパティ保存 =====
local originalProps = {}

-- ===== 壁判定関数（床・地面も含む） =====
local function isWall(part)
    if not part:IsA("BasePart") then return false end
    if part.Transparency >= 0.95 then return false end
    if part.CanCollide == false then return false end
    local size = part.Size
    if size.X < 0.3 or size.Y < 0.3 or size.Z < 0.3 then return false end
    return true
end

-- ===== デカール貼り付け関数（1パーツにつき6方向） =====
local function applyDecalsToPart(part)
    -- 既存デカール削除
    if placedDecals[part] then
        for _, decal in ipairs(placedDecals[part]) do
            if decal and decal.Parent then decal:Destroy() end
        end
        placedDecals[part] = nil
    end

    local decals = {}
    local faces = {
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Left,
        Enum.NormalId.Right,
        Enum.NormalId.Top,
        Enum.NormalId.Bottom
    }

    for _, face in ipairs(faces) do
        local decal = Instance.new("Decal")
        decal.Texture = DECAL_ID
        decal.Face = face
        decal.Parent = part
        table.insert(decals, decal)
    end

    placedDecals[part] = decals
    return decals
end

-- ===== 全デカールクリア =====
local function clearAllDecals()
    for part, decals in pairs(placedDecals) do
        for _, decal in ipairs(decals) do
            if decal and decal.Parent then decal:Destroy() end
        end
    end
    placedDecals = {}
end

-- ===== 透明化クリア =====
local function clearBodyTransparency()
    for part, data in pairs(originalProps) do
        if part and part.Parent then
            part.Transparency = data.Transparency
        end
    end
    originalProps = {}
end

-- ===== メイン更新関数 =====
local function updateAll()
    local character = LocalPlayer.Character
    if not character then return end

    local totalParts = 0
    local wallCount = 0
    local bodyCount = 0
    local weaponCount = 0

    -- === 1. マップ内の全BasePart（壁・床・地面） ===
    local allParts = workspace:GetDescendants()
    for _, part in ipairs(allParts) do
        if isWall(part) then
            applyDecalsToPart(part)
            wallCount = wallCount + 1
            totalParts = totalParts + 1
        end
    end

    -- === 2. 自分のボディパーツ ===
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and bodyPartNames[part.Name] then
            -- 透明化（初回のみ保存）
            if not originalProps[part] then
                originalProps[part] = {
                    Transparency = part.Transparency
                }
            end
            part.Transparency = BODY_TRANSPARENCY
            applyDecalsToPart(part)
            bodyCount = bodyCount + 1
            totalParts = totalParts + 1
        end
    end

    -- === 3. 武器（Tool / Accessory / 特定ネームドパーツ） ===
    local searchContainers = {
        character,
        workspace:FindFirstChild("ViewModelRig"),
        workspace.CurrentCamera
    }

    for _, container in ipairs(searchContainers) do
        if not container then continue end
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("Tool") or obj:IsA("Accessory") then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not originalProps[part] then
                            originalProps[part] = {
                                Transparency = part.Transparency
                            }
                        end
                        part.Transparency = BODY_TRANSPARENCY
                        applyDecalsToPart(part)
                        weaponCount = weaponCount + 1
                        totalParts = totalParts + 1
                    end
                end
            elseif obj:IsA("BasePart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("knife") or nameLower:find("gun") or
                   nameLower:find("weapon") or nameLower:find("blade") or
                   nameLower:find("mag") or nameLower:find("ammo") then
                    
                    local part = obj
                    if not originalProps[part] then
                        originalProps[part] = {
                            Transparency = part.Transparency
                        }
                    end
                    part.Transparency = BODY_TRANSPARENCY
                    applyDecalsToPart(part)
                    weaponCount = weaponCount + 1
                    totalParts = totalParts + 1

                    local parent = part.Parent
                    if parent and (parent:IsA("Model") or parent:IsA("Folder")) and parent ~= workspace and parent ~= character then
                        for _, sibling in ipairs(parent:GetDescendants()) do
                            if sibling:IsA("BasePart") then
                                if not originalProps[sibling] then
                                    originalProps[sibling] = {
                                        Transparency = sibling.Transparency
                                    }
                                end
                                sibling.Transparency = BODY_TRANSPARENCY
                                applyDecalsToPart(sibling)
                                weaponCount = weaponCount + 1
                                totalParts = totalParts + 1
                            end
                        end
                    end
                end
            end
        end
    end

    Notify("デカール適用", "壁:" .. wallCount .. " 体:" .. bodyCount .. " 武器:" .. weaponCount .. " (計" .. totalParts .. ")", 2)
end

-- ===== 初回実行＆定期実行 =====
task.wait(2)
updateAll()

while true do
    task.wait(UPDATE_INTERVAL)
    clearAllDecals()
    updateAll()
end

-- ===== プレイヤー離脱時クリーンアップ =====
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        clearAllDecals()
        clearBodyTransparency()
    end
end)

Notify("全デカール", "ID: 89027170969335 を全オブジェクトに適用中", 3)
