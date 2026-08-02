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
local DECAL_ID = "rbxassetid://89027170969335"  -- 更新済み
local TARGET_TRANSPARENCY = 1.0  -- 完全透明

-- ===== R15 / R6 ボディパーツ名リスト =====
local bodyPartNames = {
    -- R6
    ["Head"] = true,
    ["Torso"] = true,
    ["Left Arm"] = true,
    ["Right Arm"] = true,
    ["Left Leg"] = true,
    ["Right Leg"] = true,
    -- R15
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

-- 元のプロパティ保存用（Material / Color / Transparency）
local originalProps = {}
-- 作成したデカール保存用
local createdDecals = {}

-- ===== エフェクトクリア =====
local function clearEffect()
    for part, data in pairs(originalProps) do
        if part and part.Parent then
            part.Material = data.Material
            part.Color = data.Color
            part.Transparency = data.Transparency
        end
    end
    originalProps = {}

    for _, decalList in pairs(createdDecals) do
        for _, decal in ipairs(decalList) do
            if decal and decal.Parent then decal:Destroy() end
        end
    end
    createdDecals = {}
end

-- ===== エフェクト適用 =====
local function applyDecalEffect()
    local character = LocalPlayer.Character
    if not character then return end

    local searchContainers = {
        character,
        workspace:FindFirstChild("ViewModelRig"),
        workspace.CurrentCamera
    }

    local targets = {}

    for _, container in ipairs(searchContainers) do
        if not container then continue end

        for _, obj in ipairs(container:GetDescendants()) do
            -- 1. Tool / Accessory 配下の全パーツ
            if obj:IsA("Tool") or obj:IsA("Accessory") then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        targets[part] = true
                    end
                end

            -- 2. BasePart の場合
            elseif obj:IsA("BasePart") then
                local part = obj

                -- 2-A: 自分のボディパーツ（R15 / R6）
                if container == character and bodyPartNames[part.Name] then
                    targets[part] = true
                end

                -- 2-B: 武器関連ネームドパーツ（従来の条件）
                if part.Transparency < 0.95 then
                    local nameLower = part.Name:lower()
                    if nameLower:find("knife") or nameLower:find("gun") or
                       nameLower:find("weapon") or nameLower:find("blade") or
                       nameLower:find("mag") or nameLower:find("ammo") then

                        targets[part] = true

                        -- 同親フォルダ/モデル内の兄弟パーツもまとめて対象
                        local parent = part.Parent
                        if parent and (parent:IsA("Model") or parent:IsA("Folder")) and parent ~= workspace and parent ~= character then
                            for _, sibling in ipairs(parent:GetDescendants()) do
                                if sibling:IsA("BasePart") then
                                    targets[sibling] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 現在の対象外をクリア（プロパティ復元＆デカール削除）
    local currentTargets = {}
    for part, _ in pairs(targets) do
        if not part:IsDescendantOf(workspace) and not part:IsDescendantOf(character) then
            targets[part] = nil
        else
            currentTargets[part] = true
        end
    end

    for part, _ in pairs(originalProps) do
        if not currentTargets[part] then
            if part and part.Parent then
                part.Material = originalProps[part].Material
                part.Color = originalProps[part].Color
                part.Transparency = originalProps[part].Transparency
            end
            originalProps[part] = nil
        end
    end

    for part, decalList in pairs(createdDecals) do
        if not currentTargets[part] then
            for _, decal in ipairs(decalList) do
                if decal and decal.Parent then decal:Destroy() end
            end
            createdDecals[part] = nil
        end
    end

    -- 対象パーツにエフェクト適用
    local faces = {
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Left,
        Enum.NormalId.Right,
        Enum.NormalId.Top,
        Enum.NormalId.Bottom
    }

    for part, _ in pairs(currentTargets) do
        -- 元のプロパティ保存（初回のみ）
        if not originalProps[part] then
            originalProps[part] = {
                Material = part.Material,
                Color = part.Color,
                Transparency = part.Transparency
            }
        end

        -- 透明化
        part.Transparency = TARGET_TRANSPARENCY

        -- デカール作成（なければ）／既存はID更新
        if not createdDecals[part] then
            local newDecals = {}
            for _, face in ipairs(faces) do
                local decal = Instance.new("Decal")
                decal.Texture = DECAL_ID
                decal.Face = face
                decal.Parent = part
                table.insert(newDecals, decal)
            end
            createdDecals[part] = newDecals
        else
            for _, decal in ipairs(createdDecals[part]) do
                if decal and decal.Parent then
                    decal.Texture = DECAL_ID
                end
            end
        end
    end
end

-- ===== 常時実行（毎フレーム） =====
RunService.Heartbeat:Connect(applyDecalEffect)

-- ===== プレイヤー離脱時クリーンアップ =====
LocalPlayer.AncestryChanged:Connect(function()
    if not LocalPlayer.Parent then
        clearEffect()
    end
end)

Notify("ボディ＋武器", "ID: 89027170969335 で透明＆デカール適用中", 3)
