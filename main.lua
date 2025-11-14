--[[======================================================
   ⚙️ XERA HUB — PLAYER, MONSTER & BATTERY ESP (V0.4 + FIX)
   by Nobody
========================================================]]

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

------------------------------------------------------------
-- 🧩 Services
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
-- 🪟 Rayfield GUI
------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Xera Hub",
	LoadingTitle = "Xera Hub",
	LoadingSubtitle = "by Nobody",
	Theme = "Dark Blue",
	ToggleUIKeybind = "U",
})

------------------------------------------------------------
-- 🔔 Notifications
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
	s.Volume = 0.1
	s:Play()
	game.Debris:AddItem(s, 3)
end
local function alertnotif() playSound(6176997734) end
local function normalnotif() playSound(4590662766) end

------------------------------------------------------------
-- ⚙️ Настройки ESP
------------------------------------------------------------
local Player_Enabled = true
local Monster_Enabled = true
local Battery_Enabled = true
local Light_Enabled = true

local Player_Drawings, Monster_Drawings, Battery_Drawings = {}, {}, {}
local PlayerSettings, MonsterSettings, BatterySettings = {}, {}, {}
local KnownMonsters, KnownBatteries = {}, {}

------------------------------------------------------------
-- 🎨 Drawing Helper
------------------------------------------------------------
local function safeRemove(d)
	pcall(function() if d and d.Remove then d:Remove() end end)
end

local function CreateESPObject(label, color)
	local box = Drawing.new("Square"); box.Filled = false; box.Visible = false
	local health = Drawing.new("Square"); health.Filled = true; health.Visible = false; health.Color = Color3.fromRGB(0,255,0)
	local name = Drawing.new("Text"); name.Center = true; name.Size = 16; name.Font = 2; name.Outline = true; name.Visible = false
	local dist = Drawing.new("Text"); dist.Center = true; dist.Size = 14; dist.Font = 2; dist.Outline = true; dist.Visible = false
	local tracer = Drawing.new("Line"); tracer.Thickness = 1.5; tracer.Visible = false

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
-- 👾 Monsters
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
	local info = MonsterNames[mon.Name]; if not info then return end

	local esp = CreateESPObject(info.label, info.color)
	Monster_Drawings[mon] = {esp = esp, info = info}
	KnownMonsters[mon] = true

	alertnotif()
	notifytext("⚠ Monster spawned: " .. info.label, info.color, 3)
end

local function removeMonsterESP(mon)
	local data = Monster_Drawings[mon]
	if not data then return end
	for _,v in pairs(data.esp) do safeRemove(v) end
	Monster_Drawings[mon] = nil
	KnownMonsters[mon] = nil
end

------------------------------------------------------------
-- 🔋 Batteries (FIXED)
------------------------------------------------------------

-- FIX: защищаем от спама и ложных событий
local function isValidBattery(obj)
	if not obj:IsA("Model") then return false end
	if obj.Name ~= "battery" then return false end
	if not obj:FindFirstChildWhichIsA("BasePart") then return false end
	return true
end

local function addBatteryESP(obj)
	if not isValidBattery(obj) then return end

	-- FIX: не спамить если батарейка уже существует
	if KnownBatteries[obj] then return end

	KnownBatteries[obj] = true

	local esp = CreateESPObject("Battery", Color3.fromRGB(255, 143, 74))
	Battery_Drawings[obj] = esp

	-- FIX: уведомление только при реальном спавне модели
	notifytext("🔋 Battery spawned!", Color3.fromRGB(255,143,74), 2)
end

local function removeBatteryESP(obj)
	if not KnownBatteries[obj] then return end

	local esp = Battery_Drawings[obj]
	if esp then
		for _,v in pairs(esp) do safeRemove(v) end
	end

	Battery_Drawings[obj] = nil
	KnownBatteries[obj] = nil
end

------------------------------------------------------------
-- 🧍 Player ESP
------------------------------------------------------------
local function addPlayerESP(plr)
	if plr == LocalPlayer then return end
	if not plr.Character then return end

	local esp = CreateESPObject(plr.Name, Color3.fromRGB(50,150,255))
	Player_Drawings[plr] = esp
end

local function removePlayerESP(plr)
	local esp = Player_Drawings[plr]
	if esp then for _,v in pairs(esp) do safeRemove(v) end end
	Player_Drawings[plr] = nil
end

for _,p in ipairs(Players:GetPlayers()) do addPlayerESP(p) end
Players.PlayerAdded:Connect(addPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

------------------------------------------------------------
-- 🔍 Entity Registration
------------------------------------------------------------
workspace.ChildAdded:Connect(function(obj)
	if MonsterNames[obj.Name] then addMonsterESP(obj) end
	if isValidBattery(obj) then addBatteryESP(obj) end
end)

workspace.DescendantAdded:Connect(function(child)
	if MonsterNames[child.Name] then
		task.wait(0.15)
		addMonsterESP(child)
	elseif isValidBattery(child) then
		task.wait(0.15)
		addBatteryESP(child)
	end
end)

workspace.DescendantRemoving:Connect(function(obj)
	if MonsterNames[obj.Name] then removeMonsterESP(obj)
	elseif KnownBatteries[obj] then removeBatteryESP(obj)
	end
end)

------------------------------------------------------------
-- ⚙️ Settings Tabs
------------------------------------------------------------
local ESP_Tab = Window:CreateTab("ESP")

------------------------------------------------------------
-- PLAYERS
------------------------------------------------------------
ESP_Tab:CreateSection("Players")

PlayerSettings = {
	BoxEnabled = true,
	TracerEnabled = true,
	NameEnabled = true,
	DistanceEnabled = true,
	HealthEnabled = true,

	BoxColor = Color3.fromRGB(50,150,255),
	TracerColor = Color3.fromRGB(50,150,255),
	NameColor = Color3.fromRGB(255,255,255),
	DistanceColor = Color3.fromRGB(180,180,180),
	HealthColor = Color3.fromRGB(0,255,0)
}

ESP_Tab:CreateToggle({Name="Player ESP",CurrentValue=true,Callback=function(v)Player_Enabled=v end})

ESP_Tab:CreateToggle({Name="Health Bar",CurrentValue=true,Callback=function(v)PlayerSettings.HealthEnabled=v end})
ESP_Tab:CreateColorPicker({Name="Health Color",Color=PlayerSettings.HealthColor,Callback=function(v)PlayerSettings.HealthColor=v end})

------------------------------------------------------------
-- MONSTERS
------------------------------------------------------------
ESP_Tab:CreateSection("Monsters")
ESP_Tab:CreateToggle({Name="Monster ESP",CurrentValue=true,Callback=function(v)Monster_Enabled=v end})

for _,monster in pairs(MonsterNames) do
	ESP_Tab:CreateSection(monster.label)

	MonsterSettings[monster.label] = {
		TracerEnabled = true,
		NameEnabled = true,
		DistanceEnabled = true,
		BoxEnabled = true,

		BoxColor = monster.color,
		TracerColor = monster.color,
		NameColor = monster.color,
		DistanceColor = Color3.fromRGB(180,180,180)
	}

	ESP_Tab:CreateToggle({Name=monster.label.." Box",CurrentValue=true,Callback=function(v)MonsterSettings[monster.label].BoxEnabled=v end})
	ESP_Tab:CreateColorPicker({Name=monster.label.." BoxColor",Color=monster.color,Callback=function(v)MonsterSettings[monster.label].BoxColor=v end})

	ESP_Tab:CreateToggle({Name=monster.label.." Tracer",CurrentValue=true,Callback=function(v)MonsterSettings[monster.label].TracerEnabled=v end})
	ESP_Tab:CreateColorPicker({Name=monster.label.." TracerColor",Color=monster.color,Callback=function(v)MonsterSettings[monster.label].TracerColor=v end})

	ESP_Tab:CreateToggle({Name=monster.label.." Name",CurrentValue=true,Callback=function(v)MonsterSettings[monster.label].NameEnabled=v end})
	ESP_Tab:CreateColorPicker({Name=monster.label.." NameColor",Color=monster.color,Callback=function(v)MonsterSettings[monster.label].NameColor=v end})

	ESP_Tab:CreateToggle({Name=monster.label.." Distance",CurrentValue=true,Callback=function(v)MonsterSettings[monster.label].DistanceEnabled=v end})
end

------------------------------------------------------------
-- BATTERY ESP
------------------------------------------------------------
local BatteryTab = Window:CreateTab("Battery ESP")
BatteryTab:CreateSection("Battery Settings")

BatterySettings = {
	TracerEnabled = true,
	NameEnabled = true,
	DistanceEnabled = true,
	BoxEnabled = true,
	Color = Color3.fromRGB(255,143,74)
}

BatteryTab:CreateToggle({Name="Battery ESP Enabled",CurrentValue=true,Callback=function(v)Battery_Enabled=v end})
BatteryTab:CreateToggle({Name="Box",CurrentValue=true,Callback=function(v)BatterySettings.BoxEnabled=v end})
BatteryTab:CreateToggle({Name="Tracer",CurrentValue=true,Callback=function(v)BatterySettings.TracerEnabled=v end})
BatteryTab:CreateToggle({Name="Name",CurrentValue=true,Callback=function(v)BatterySettings.NameEnabled=v end})
BatteryTab:CreateToggle({Name="Distance",CurrentValue=true,Callback=function(v)BatterySettings.DistanceEnabled=v end})
BatteryTab:CreateColorPicker({Name="Battery Color",Color=BatterySettings.Color,Callback=function(v)BatterySettings.Color=v end})

------------------------------------------------------------
-- 💡 Lighting
------------------------------------------------------------
local LightTab = Window:CreateTab("Lighting")
LightTab:CreateSection("PointLight")

LightTab:CreateToggle({Name="Enable Light",CurrentValue=true,Callback=function(v)Light_Enabled=v PointLight.Enabled=v end})
LightTab:CreateSlider({Name="Brightness",Range={0,5},Increment=0.1,CurrentValue=2,Callback=function(v)PointLight.Brightness=v end})
LightTab:CreateSlider({Name="Range",Range={10,100},Increment=5,CurrentValue=60,Callback=function(v)PointLight.Range=v end})

------------------------------------------------------------
-- 🔁 MAIN RENDER
------------------------------------------------------------
RunService.RenderStepped:Connect(function()

------------------------------------------------------------
-- PLAYER RENDER
------------------------------------------------------------
	for plr, esp in pairs(Player_Drawings) do
		local char = plr.Character
		if not Player_Enabled or not char then
			for _,v in pairs(esp) do v.Visible = false end
			continue
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local screen, vis = Camera:WorldToViewportPoint(hrp.Position)
		if not vis then continue end

		local hum = char:FindFirstChildOfClass("Humanoid")
		local size = 2500 / math.max(screen.Z, 1)
		local boxPos = Vector2.new(screen.X - size/4, screen.Y - size/2)

		esp.Box.Size = Vector2.new(size/2, size)
		esp.Box.Position = boxPos
		esp.Box.Color = PlayerSettings.BoxColor
		esp.Box.Visible = PlayerSettings.BoxEnabled

		if hum then
			local hp = hum.Health / hum.MaxHealth
			local hpHeight = size * hp
			esp.Health.Size = Vector2.new(3, hpHeight)
			esp.Health.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (size - hpHeight))
			esp.Health.Color = PlayerSettings.HealthColor
			esp.Health.Visible = PlayerSettings.HealthEnabled
		end

		esp.Name.Text = plr.Name
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
		esp.Name.Color = PlayerSettings.NameColor
		esp.Name.Visible = PlayerSettings.NameEnabled

		local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
		esp.Distance.Text = string.format("[%.1f m]", dist)
		esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
		esp.Distance.Color = PlayerSettings.DistanceColor
		esp.Distance.Visible = PlayerSettings.DistanceEnabled

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = PlayerSettings.TracerColor
		esp.Tracer.Visible = PlayerSettings.TracerEnabled
	end

------------------------------------------------------------
-- MONSTER RENDER
------------------------------------------------------------
	for mon, data in pairs(Monster_Drawings) do
		local esp = data.esp

		if not mon or not mon.Parent then removeMonsterESP(mon) continue end

		local pos
		pcall(function()
			if data.info.label == "A-40" and mon.Parent.PrimaryPart then
				pos = mon.Parent.PrimaryPart.Position
			end
		end)

		if not pos then
			if mon:IsA("BasePart") then pos = mon.Position end
			if mon:IsA("Model") and mon.PrimaryPart then pos = mon.PrimaryPart.Position end
		end
		if not pos then continue end

		local screen, vis = Camera:WorldToViewportPoint(pos)
		if not vis or not Monster_Enabled then continue end

		local set = MonsterSettings[data.info.label]
		local size = 2500 / math.max(screen.Z, 1)

		esp.Box.Size = Vector2.new(size/2, size)
		esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/2)
		esp.Box.Color = set.BoxColor
		esp.Box.Visible = set.BoxEnabled

		esp.Name.Text = data.info.label
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
		esp.Name.Color = set.NameColor
		esp.Name.Visible = set.NameEnabled

		local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
		esp.Distance.Text = string.format("[%.1f m]", dist)
		esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
		esp.Distance.Color = set.DistanceColor
		esp.Distance.Visible = set.DistanceEnabled

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = set.TracerColor
		esp.Tracer.Visible = set.TracerEnabled
	end

------------------------------------------------------------
-- BATTERY RENDER
------------------------------------------------------------
	for obj, esp in pairs(Battery_Drawings) do
		if not obj or not obj.Parent then removeBatteryESP(obj) continue end

		local pp = obj:FindFirstChildWhichIsA("BasePart")
		if not pp then continue end

		local screen, vis = Camera:WorldToViewportPoint(pp.Position)
		if not vis or not Battery_Enabled then continue end

		local size = 800 / math.max(screen.Z, 1)

		esp.Box.Size = Vector2.new(size/2, size/2)
		esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/4)
		esp.Box.Color = BatterySettings.Color
		esp.Box.Visible = BatterySettings.BoxEnabled

		esp.Name.Text = "Battery"
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
		esp.Name.Visible = BatterySettings.NameEnabled

		local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pp.Position).Magnitude
		esp.Distance.Text = string.format("[%.1f m]", dist)
		esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
		esp.Distance.Color = Color3.fromRGB(180,180,180)
		esp.Distance.Visible = BatterySettings.DistanceEnabled

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = BatterySettings.Color
		esp.Tracer.Visible = BatterySettings.TracerEnabled
	end

end)
