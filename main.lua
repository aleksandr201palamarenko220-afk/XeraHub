--[[====================================================== XERA HUB — MONSTER, PLAYER & BATTERY ESP (V0.5 FIX) by Nobody ========================================================]]
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

------------------------------------------------------------
-- Services
------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LHRP = Character:WaitForChild("HumanoidRootPart", 10)

local PointLight = Instance.new("PointLight")
PointLight.Name = "ESP_Light"
PointLight.Range = 60
PointLight.Brightness = 2
PointLight.Shadows = false
PointLight.Enabled = true
if LHRP then PointLight.Parent = LHRP end

------------------------------------------------------------
-- Rayfield GUI
------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Xera Hub",
    LoadingTitle = "Xera Hub",
    LoadingSubtitle = "by Nobody + fixed by Grok",
    Theme = "Dark Blue",
    ToggleUIKeybind = "U",
})

------------------------------------------------------------
-- Notifications & Sounds
------------------------------------------------------------
local function notifytext(text, rgb, dur)
    Rayfield:Notify({
        Title = "Xera notification",
        Content = text,
        Duration = dur or 3,
    })
end

local function playSound(id)
    local s = Instance.new("Sound", LocalPlayer:WaitForChild("PlayerGui"))
    s.SoundId = "rbxassetid://" .. id
    s.Volume = 0.15
    s:Play()
    task.delay(3, function() s:Destroy() end)
end

local function alertnotif() playSound(6176997734) end
local function normalnotif() playSound(4590662766) end

------------------------------------------------------------
-- ESP Settings
------------------------------------------------------------
local Monster_Enabled = true
local Battery_Enabled = true
local Light_Enabled = true
local Player_Enabled = true

local Monster_Drawings = {}
local Battery_Drawings = {}
local Player_Drawings = {}

local KnownMonsters = {}
local KnownBatteries = {}
local BatteryDebounce = {} -- КЛЮЧЕВОЙ ФИКС от фантомок

local MonsterSettings = {}
local BatterySettings = {}
local PlayerSettings = {}

------------------------------------------------------------
-- Drawing Helper
------------------------------------------------------------
local function safeRemove(drawing)
    pcall(function()
        if drawing and drawing.Remove then
            drawing:Remove()
        end
    end)
end

local function CreateESPObject(label, color)
    local box = Drawing.new("Square")
    box.Filled = false
    box.Thickness = 2
    box.Visible = false

    local name = Drawing.new("Text")
    name.Center = true
    name.Size = 16
    name.Font = 2
    name.Outline = true
    name.Visible = false
    name.Text = label or "Entity"

    local dist = Drawing.new("Text")
    dist.Center = true
    dist.Size = 14
    dist.Font = 2
    dist.Outline = true
    dist.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1.5
    tracer.Visible = false

    local health = Drawing.new("Square")
    health.Filled = true
    health.Visible = false
    health.Color = Color3.fromRGB(0, 255, 0)

    return {
        Box = box,
        Name = name,
        Distance = dist,
        Tracer = tracer,
        Health = health,
        Color = color or Color3.fromRGB(255,255,255),
        Label = label or "Entity"
    }
end

------------------------------------------------------------
-- Monsters
------------------------------------------------------------
local MonsterNames = {
    ["monster"] = {label = "A-60", color = Color3.fromRGB(255, 0, 0)},
    ["monster2"] = {label = "A-120/A-200", color = Color3.fromRGB(255, 120, 0)},
    ["Spirit"] = {label = "A-100", color = Color3.fromRGB(140, 0, 255)},
    ["handdebris"] = {label = "A-250", color = Color3.fromRGB(255, 0, 0)},
    ["jack"] = {label = "A-40", color = Color3.fromRGB(200, 200, 200)},
}

local function addMonsterESP(mon)
    if KnownMonsters[mon] then return end
    local info = MonsterNames[mon.Name]
    if not info then return end

    local esp = CreateESPObject(info.label, info.color)
    Monster_Drawings[mon] = {esp = esp, info = info}
    KnownMonsters[mon] = true

    alertnotif()
    notifytext("Monster spawned: " .. info.label, info.color, 3)
end

local function removeMonsterESP(mon)
    local data = Monster_Drawings[mon]
    if not data then return end

    for _, v in pairs(data.esp) do safeRemove(v) end
    Monster_Drawings[mon] = nil
    KnownMonsters[mon] = nil

    normalnotif()
    notifytext("Monster despawned: " .. (data.info and data.info.label or "?"), Color3.fromRGB(100,255,100), 2)
end

------------------------------------------------------------
-- Batteries
------------------------------------------------------------
local function addBatteryESP(obj)
    if not obj or not obj:IsA("Model") or obj.Name ~= "battery" then return end
    if KnownBatteries[obj] or BatteryDebounce[obj] then return end

    BatteryDebounce[obj] = true

    local esp = CreateESPObject("Battery", Color3.fromRGB(255, 143, 74))
    Battery_Drawings[obj] = esp
    KnownBatteries[obj] = true

    notifytext("Battery spawned! Grab it!", Color3.fromRGB(255,143,74), 3)
    normalnotif()

    task.delay(1, function() BatteryDebounce[obj] = nil end)
end

local function removeBatteryESP(obj)
    local esp = Battery_Drawings[obj]
    if not esp then return end

    for _, v in pairs(esp) do safeRemove(v) end
    Battery_Drawings[obj] = nil
    KnownBatteries[obj] = nil
    BatteryDebounce[obj] = nil

    notifytext("Battery gone.", Color3.fromRGB(255,143,74), 2)
    normalnotif()
end

------------------------------------------------------------
-- Player ESP
------------------------------------------------------------
local function addPlayerESP(plr)
    if plr == LocalPlayer or Player_Drawings[plr] then return end
    local esp = CreateESPObject(plr.Name, Color3.fromRGB(50,150,255))
    Player_Drawings[plr] = esp
end

local function removePlayerESP(plr)
    local esp = Player_Drawings[plr]
    if esp then
        for _, v in pairs(esp) do safeRemove(v) end
        Player_Drawings[plr] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do addPlayerESP(p) end
Players.PlayerAdded:Connect(addPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

------------------------------------------------------------
-- Entity Registration
------------------------------------------------------------
workspace.DescendantAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "battery" and child.Parent then
        task.wait() -- ждём полной загрузки модели
        if child.Parent then addBatteryESP(child) end
    elseif MonsterNames[child.Name] then
        addMonsterESP(child)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if MonsterNames[obj.Name] then
        removeMonsterESP(obj)
    elseif obj.Name == "battery" and KnownBatteries[obj] then
        removeBatteryESP(obj)
    end
end)

------------------------------------------------------------
-- GUI Tabs
------------------------------------------------------------
local ESP_Tab = Window:CreateTab("ESP")
local BatteryTab = Window:CreateTab("Battery ESP")
local LightTab = Window:CreateTab("Lighting")

-- Player ESP UI
ESP_Tab:CreateSection("Players")
PlayerSettings = {
    TracerEnabled = true, NameEnabled = true, DistanceEnabled = true,
    BoxEnabled = true, HealthEnabled = true,
    BoxColor = Color3.fromRGB(50,150,255), TracerColor = Color3.fromRGB(50,150,255),
    NameColor = Color3.fromRGB(255,255,255), DistanceColor = Color3.fromRGB(180,180,180),
    HealthColor = Color3.fromRGB(0,255,0),
}

ESP_Tab:CreateToggle({Name = "Player ESP", CurrentValue = true, Callback = function(v) Player_Enabled = v end})
ESP_Tab:CreateToggle({Name = "Player Box", CurrentValue = true, Callback = function(v) PlayerSettings.BoxEnabled = v end})
ESP_Tab:CreateColorPicker({Name = "Player BoxColor", Color = PlayerSettings.BoxColor, Callback = function(c) PlayerSettings.BoxColor = c end})
-- (остальные переключатели игроков — по аналогии, можешь добавить сам, если хочешь)

-- Monster ESP UI
ESP_Tab:CreateSection("Monsters")
ESP_Tab:CreateToggle({Name = "Monster ESP", CurrentValue = true, Callback = function(v) Monster_Enabled = v end})

for _, m in pairs(MonsterNames) do
    MonsterSettings[m.label] = {
        BoxEnabled = true, TracerEnabled = true, NameEnabled = true, DistanceEnabled = true,
        BoxColor = m.color, TracerColor = m.color, NameColor = m.color, DistanceColor = Color3.fromRGB(180,180,180)
    }
end

-- Battery ESP UI
BatteryTab:CreateSection("Battery Settings")
BatterySettings = {
    TracerEnabled = true, NameEnabled = true, DistanceEnabled = true,
    BoxEnabled = true, Color = Color3.fromRGB(255,143,74), DistanceColor = Color3.fromRGB(180,180,180)
}

BatteryTab:CreateToggle({Name = "Battery ESP Enabled", CurrentValue = true, Callback = function(v) Battery_Enabled = v end})
BatteryTab:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) BatterySettings.BoxEnabled = v end})
BatteryTab:CreateToggle({Name = "Tracer", CurrentValue = true, Callback = function(v) BatterySettings.TracerEnabled = v end})
BatteryTab:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) BatterySettings.NameEnabled = v end})
BatteryTab:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) BatterySettings.DistanceEnabled = v end})
BatteryTab:CreateColorPicker({Name = "Battery Color", Color = BatterySettings.Color, Callback = function(c) BatterySettings.Color = c end})

-- Light Control
LightTab:CreateSection("PointLight")
LightTab:CreateToggle({Name = "Enable Light", CurrentValue = true, Callback = function(v) Light_Enabled = v PointLight.Enabled = v end})
LightTab:CreateSlider({Name = "Light Brightness", Range = {0, 5}, Increment = 0.1, CurrentValue = 2, Callback = function(v) PointLight.Brightness = v end})
LightTab:CreateSlider({Name = "Light Range", Range = {10, 100}, Increment = 5, CurrentValue = 60, Callback = function(v) PointLight.Range = v end})

------------------------------------------------------------
-- Render Loop
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- Players
    for plr, esp in pairs(Player_Drawings) do
        local char = plr.Character
        if not Player_Enabled or not char or not char:FindFirstChild("HumanoidRootPart") then
            esp.Box.Visible = false; esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tracer.Visible = false; esp.Health.Visible = false
            continue
        end

        local hrp = char.HumanoidRootPart
        local screen, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            esp.Box.Visible = false; esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tracer.Visible = false; esp.Health.Visible = false
            continue
        end

        local size = 2500 / math.max(screen.Z, 1)
        local boxPos = Vector2.new(screen.X - size/4, screen.Y - size/2)

        esp.Box.Size = Vector2.new(size/2, size)
        esp.Box.Position = boxPos
        esp.Box.Color = PlayerSettings.BoxColor
        esp.Box.Visible = PlayerSettings.BoxEnabled

        -- Health bar
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and esp.Health then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            esp.Health.Size = Vector2.new(4, size * ratio)
            esp.Health.Position = Vector2.new(boxPos.X - 8, boxPos.Y + size - size * ratio)
            esp.Health.Visible = PlayerSettings.HealthEnabled
        end

        esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
        esp.Name.Color = PlayerSettings.NameColor
        esp.Name.Visible = PlayerSettings.NameEnabled

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            esp.Distance.Text = string.format("[%.1f m]", dist)
            esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
            esp.Distance.Color = PlayerSettings.DistanceColor
            esp.Distance.Visible = PlayerSettings.DistanceEnabled
        end

        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
        esp.Tracer.To = Vector2.new(screen.X, screen.Y)
        esp.Tracer.Color = PlayerSettings.TracerColor
        esp.Tracer.Visible = PlayerSettings.TracerEnabled
    end

    -- Monsters
    for mon, data in pairs(Monster_Drawings) do
        if not mon or not mon.Parent then removeMonsterESP(mon) continue end

        local pos = mon.PrimaryPart and mon.PrimaryPart.Position or
                    mon:FindFirstChild("torso") and mon.torso.Position or
                    mon:IsA("BasePart") and mon.Position

        if not pos then continue end

        local screen, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen or not Monster_Enabled then
            data.esp.Box.Visible = false; data.esp.Name.Visible = false; data.esp.Distance.Visible = false; data.esp.Tracer.Visible = false
            continue
        end

        local settings = MonsterSettings[data.esp.Label] or {}
        local size = 2500 / math.max(screen.Z, 1)

        data.esp.Box.Size = Vector2.new(size/2, size)
        data.esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/2)
        data.esp.Box.Color = settings.BoxColor or data.info.color
        data.esp.Box.Visible = settings.BoxEnabled

        data.esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
        data.esp.Name.Color = settings.NameColor or data.info.color
        data.esp.Name.Visible = settings.NameEnabled

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
            data.esp.Distance.Text = string.format("[%.1f m]", dist)
            data.esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
            data.esp.Distance.Color = settings.DistanceColor or Color3.fromRGB(180,180,180)
            data.esp.Distance.Visible = settings.DistanceEnabled
        end

        data.esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
        data.esp.Tracer.To = Vector2.new(screen.X, screen.Y)
        data.esp.Tracer.Color = settings.TracerColor or data.info.color
        data.esp.Tracer.Visible = settings.TracerEnabled
    end

    -- Batteries
    for obj, esp in pairs(Battery_Drawings) do
        if not obj or not obj.Parent then removeBatteryESP(obj) continue end

        local pos = obj.PrimaryPart and obj.PrimaryPart.Position or
                    obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position
        if not pos then continue end

        local screen, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen or not Battery_Enabled then
            esp.Box.Visible = false; esp.Name.Visible = false; esp.Distance.Visible = false; esp.Tracer.Visible = false
            continue
        end

        local size = 800 / math.max(screen.Z, 1)

        esp.Box.Size = Vector2.new(size/2, size/2)
        esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/4)
        esp.Box.Color = BatterySettings.Color
        esp.Box.Visible = BatterySettings.BoxEnabled

        esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 8)
        esp.Name.Color = BatterySettings.Color
        esp.Name.Visible = BatterySettings.NameEnabled

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
            esp.Distance.Text = string.format("[%.1f m]", dist)
            esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 20)
            esp.Distance.Color = BatterySettings.DistanceColor
            esp.Distance.Visible = BatterySettings.DistanceEnabled
        end

        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
        esp.Tracer.To = Vector2.new(screen.X, screen.Y)
        esp.Tracer.Color = BatterySettings.Color
        esp.Tracer.Visible = BatterySettings.TracerEnabled
    end
end)

notifytext("Xera Hub loaded!", Color3.fromRGB(0,255,0), 4)
normalnotif()
