--[[====================================================== ⚙️ XERA HUB — MONSTER, PLAYER & BATTERY ESP (V0.4 BASED ON V0.3) by Nobody ========================================================]]
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
local Monster_Enabled = true
local Battery_Enabled = true
local Light_Enabled = true
local Player_Enabled = true

local Monster_Drawings = {}
local Battery_Drawings = {}
local KnownMonsters = {}
local KnownBatteries = {}

local MonsterSettings = {}
local BatterySettings = {}

local Player_Drawings = {}
local PlayerSettings = {}

------------------------------------------------------------
-- 🎨 Drawing Helper
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

	-- ХП бар (используем для игроков, для монстров/батареек просто игнорится)
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
	local info = MonsterNames[mon.Name]
	if not info then return end

	local esp = CreateESPObject(info.label, info.color)
	Monster_Drawings[mon] = {esp = esp, info = info}
	KnownMonsters[mon] = true

	alertnotif()
	notifytext("⚠ Monster spawned: " .. info.label, info.color, 3)
end

local function removeMonsterESP(mon)
	local data = Monster_Drawings[mon]
	if not data then return end
	local esp, info = data.esp, data.info

	for _,v in pairs(esp) do
		safeRemove(v)
	end
	Monster_Drawings[mon] = nil
	KnownMonsters[mon] = nil

	normalnotif()
	notifytext("✅ Monster despawned: " .. (info and info.label or "?"), Color3.fromRGB(100,255,100), 2)
end

------------------------------------------------------------
-- 🔋 Batteries
------------------------------------------------------------
local function addBatteryESP(obj)
	if KnownBatteries[obj] then return end
	local esp = CreateESPObject("Battery", Color3.fromRGB(255, 143, 74))
	Battery_Drawings[obj] = esp
	KnownBatteries[obj] = true
	notifytext("🔋 Battery spawned! Grab it!", Color3.fromRGB(255,143,74), 3)
	normalnotif()
end

local function removeBatteryESP(obj)
	local esp = Battery_Drawings[obj]
	if not esp then return end
	for _,v in pairs(esp) do
		safeRemove(v)
	end
	Battery_Drawings[obj] = nil
	notifytext("🔋 Battery gone.", Color3.fromRGB(255,143,74), 3)
	normalnotif()
	KnownBatteries[obj] = nil
end

------------------------------------------------------------
-- 🧍 Player ESP
------------------------------------------------------------
local function addPlayerESP(plr)
	if plr == LocalPlayer then return end
	if Player_Drawings[plr] then return end
	local esp = CreateESPObject(plr.Name, Color3.fromRGB(50,150,255))
	Player_Drawings[plr] = esp
end

local function removePlayerESP(plr)
	local esp = Player_Drawings[plr]
	if esp then
		for _,v in pairs(esp) do
			safeRemove(v)
		end
	end
	Player_Drawings[plr] = nil
end

for _,p in ipairs(Players:GetPlayers()) do
	addPlayerESP(p)
end
Players.PlayerAdded:Connect(addPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

------------------------------------------------------------
-- 🔍 Entity Registration
------------------------------------------------------------
workspace.ChildAdded:Connect(function(obj)
	if MonsterNames[obj.Name] then addMonsterESP(obj) end
end)

workspace.DescendantAdded:Connect(function(child)
	if child:IsA("Model") and child.Name == "battery" then
		task.wait(0.2)
		addBatteryESP(child)
	elseif MonsterNames[child.Name] then
		task.wait(0.2)
		addMonsterESP(child)
	end
end)

workspace.DescendantRemoving:Connect(function(obj)
	if MonsterNames[obj.Name] then
		removeMonsterESP(obj)
	elseif obj.Name == "battery" then
		removeBatteryESP(obj)
	end
end)

------------------------------------------------------------
-- 🧠 ESP Tabs
------------------------------------------------------------
local ESP_Tab = Window:CreateTab("ESP")

------------------------------------------------------------
-- 👤 Player ESP UI
------------------------------------------------------------
ESP_Tab:CreateSection("Players")

PlayerSettings = {
	TracerEnabled = true,
	NameEnabled = true,
	DistanceEnabled = true,
	BoxEnabled = true,
	HealthEnabled = true,

	BoxColor = Color3.fromRGB(50,150,255),
	TracerColor = Color3.fromRGB(50,150,255),
	NameColor = Color3.fromRGB(255,255,255),
	DistanceColor = Color3.fromRGB(180,180,180),
	HealthColor = Color3.fromRGB(0,255,0),
}

ESP_Tab:CreateToggle({
	Name = "Player ESP",
	CurrentValue = true,
	Callback = function(v)
		Player_Enabled = v
	end
})

ESP_Tab:CreateToggle({
	Name = "Player Box",
	CurrentValue = true,
	Callback = function(Value)
		PlayerSettings.BoxEnabled = Value
	end
})

ESP_Tab:CreateColorPicker({
	Name = "Player BoxColor",
	Color = PlayerSettings.BoxColor,
	Callback = function(Value)
		PlayerSettings.BoxColor = Value
	end
})

ESP_Tab:CreateToggle({
	Name = "Player Tracer",
	CurrentValue = true,
	Callback = function(Value)
		PlayerSettings.TracerEnabled = Value
	end
})

ESP_Tab:CreateColorPicker({
	Name = "Player TracerColor",
	Color = PlayerSettings.TracerColor,
	Callback = function(Value)
		PlayerSettings.TracerColor = Value
	end
})

ESP_Tab:CreateToggle({
	Name = "Player Name",
	CurrentValue = true,
	Callback = function(Value)
		PlayerSettings.NameEnabled = Value
	end
})

ESP_Tab:CreateColorPicker({
	Name = "Player NameColor",
	Color = PlayerSettings.NameColor,
	Callback = function(Value)
		PlayerSettings.NameColor = Value
	end
})

ESP_Tab:CreateToggle({
	Name = "Player Distance",
	CurrentValue = true,
	Callback = function(Value)
		PlayerSettings.DistanceEnabled = Value
	end
})

ESP_Tab:CreateColorPicker({
	Name = "Player DistanceColor",
	Color = PlayerSettings.DistanceColor,
	Callback = function(Value)
		PlayerSettings.DistanceColor = Value
	end
})

ESP_Tab:CreateToggle({
	Name = "Player Health Bar",
	CurrentValue = true,
	Callback = function(Value)
		PlayerSettings.HealthEnabled = Value
	end
})

ESP_Tab:CreateColorPicker({
	Name = "Player HealthColor",
	Color = PlayerSettings.HealthColor,
	Callback = function(Value)
		PlayerSettings.HealthColor = Value
	end
})

------------------------------------------------------------
-- 👾 Monsters ESP UI
------------------------------------------------------------
ESP_Tab:CreateSection("Monsters")

ESP_Tab:CreateToggle({
	Name = "Monster ESP",
	CurrentValue = true,
	Callback = function(v)
		Monster_Enabled = v
	end
})

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
		DistanceColor = Color3.fromRGB(180,180,180),
	}

	ESP_Tab:CreateToggle({
		Name = monster.label.." Box",
		CurrentValue = true,
		Callback = function(Value)
			MonsterSettings[monster.label].BoxEnabled = Value
		end
	})

	ESP_Tab:CreateColorPicker({
		Name = monster.label.." BoxColor",
		Color = monster.color,
		Callback = function(Value)
			MonsterSettings[monster.label].BoxColor = Value
		end
	})

	ESP_Tab:CreateToggle({
		Name = monster.label.." Tracer",
		CurrentValue = true,
		Callback = function(Value)
			MonsterSettings[monster.label].TracerEnabled = Value
		end
	})

	ESP_Tab:CreateColorPicker({
		Name = monster.label.." TracerColor",
		Color = monster.color,
		Callback = function(Value)
			MonsterSettings[monster.label].TracerColor = Value
		end
	})

	ESP_Tab:CreateToggle({
		Name = monster.label.." Name",
		CurrentValue = true,
		Callback = function(Value)
			MonsterSettings[monster.label].NameEnabled = Value
		end
	})

	ESP_Tab:CreateColorPicker({
		Name = monster.label.." NameColor",
		Color = monster.color,
		Callback = function(Value)
			MonsterSettings[monster.label].NameColor = Value
		end
	})

	ESP_Tab:CreateToggle({
		Name = monster.label.." Distance",
		CurrentValue = true,
		Callback = function(Value)
			MonsterSettings[monster.label].DistanceEnabled = Value
		end
	})

	ESP_Tab:CreateColorPicker({
		Name = monster.label.." DistanceColor",
		Color = MonsterSettings[monster.label].DistanceColor,
		Callback = function(Value)
			MonsterSettings[monster.label].DistanceColor = Value
		end
	})
end

------------------------------------------------------------
-- 🔋 Battery ESP Tab
------------------------------------------------------------
local BatteryTab = Window:CreateTab("Battery ESP")
BatteryTab:CreateSection("Battery Settings")

BatterySettings = {
	TracerEnabled = true,
	NameEnabled = true,
	DistanceEnabled = true,
	BoxEnabled = true,
	Color = Color3.fromRGB(255,143,74),
	DistanceColor = Color3.fromRGB(180,180,180),
}

BatteryTab:CreateToggle({
	Name = "Battery ESP Enabled",
	CurrentValue = true,
	Callback = function(Value)
		Battery_Enabled = Value
	end
})

BatteryTab:CreateToggle({
	Name = "Box",
	CurrentValue = true,
	Callback = function(Value)
		BatterySettings.BoxEnabled = Value
	end
})

BatteryTab:CreateToggle({
	Name = "Tracer",
	CurrentValue = true,
	Callback = function(Value)
		BatterySettings.TracerEnabled = Value
	end
})

BatteryTab:CreateToggle({
	Name = "Name",
	CurrentValue = true,
	Callback = function(Value)
		BatterySettings.NameEnabled = Value
	end
})

BatteryTab:CreateToggle({
	Name = "Distance",
	CurrentValue = true,
	Callback = function(Value)
		BatterySettings.DistanceEnabled = Value
	end
})

BatteryTab:CreateColorPicker({
	Name = "Battery Color",
	Color = BatterySettings.Color,
	Callback = function(Value)
		BatterySettings.Color = Value
	end
})

BatteryTab:CreateColorPicker({
	Name = "Battery DistanceColor",
	Color = BatterySettings.DistanceColor,
	Callback = function(Value)
		BatterySettings.DistanceColor = Value
	end
})

------------------------------------------------------------
-- 💡 Light Control
------------------------------------------------------------
local LightTab = Window:CreateTab("Lighting")
LightTab:CreateSection("PointLight")

LightTab:CreateToggle({
	Name = "Enable Light",
	CurrentValue = true,
	Callback = function(Value)
		Light_Enabled = Value
		PointLight.Enabled = Value
	end
})

LightTab:CreateSlider({
	Name = "Light Brightness",
	Range = {0, 5},
	Increment = 0.1,
	CurrentValue = 2,
	Callback = function(Value)
		PointLight.Brightness = Value
	end
})

LightTab:CreateSlider({
	Name = "Light Range",
	Range = {10, 100},
	Increment = 5,
	CurrentValue = 60,
	Callback = function(Value)
		PointLight.Range = Value
	end
})

------------------------------------------------------------
-- 🔁 Render Update
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	--------------------------------------------------------
	-- 👤 PLAYERS
	--------------------------------------------------------
	for plr, esp in pairs(Player_Drawings) do
		local char = plr.Character
		if not Player_Enabled or not char or not char:FindFirstChild("HumanoidRootPart") then
			esp.Box.Visible = false
			esp.Name.Visible = false
			esp.Distance.Visible = false
			esp.Tracer.Visible = false
			if esp.Health then esp.Health.Visible = false end
			continue
		end

		local hrp = char.HumanoidRootPart
		local screen, vis = Camera:WorldToViewportPoint(hrp.Position)
		if not vis then
			esp.Box.Visible = false
			esp.Name.Visible = false
			esp.Distance.Visible = false
			esp.Tracer.Visible = false
			if esp.Health then esp.Health.Visible = false end
			continue
		end

		local size = 2500 / math.max(screen.Z, 1)
		local boxPos = Vector2.new(screen.X - size/4, screen.Y - size/2)

		esp.Box.Size = Vector2.new(size/2, size)
		esp.Box.Position = boxPos
		esp.Box.Color = PlayerSettings.BoxColor
		esp.Box.Visible = PlayerSettings.BoxEnabled

		local hum = char:FindFirstChildOfClass("Humanoid")
		local hpRatio = 1
		if hum and hum.MaxHealth > 0 then
			hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
		end

		if esp.Health then
			local hpHeight = size * hpRatio
			esp.Health.Size = Vector2.new(3, hpHeight)
			esp.Health.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (size - hpHeight))
			esp.Health.Color = PlayerSettings.HealthColor
			esp.Health.Visible = PlayerSettings.HealthEnabled
		end

		esp.Name.Text = plr.Name
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
		esp.Name.Color = PlayerSettings.NameColor
		esp.Name.Visible = PlayerSettings.NameEnabled

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			esp.Distance.Text = string.format("[%.1f m]", dist)
			esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
			esp.Distance.Color = PlayerSettings.DistanceColor
			esp.Distance.Visible = PlayerSettings.DistanceEnabled
		else
			esp.Distance.Visible = false
		end

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = PlayerSettings.TracerColor
		esp.Tracer.Visible = PlayerSettings.TracerEnabled
	end

	--------------------------------------------------------
	-- 👾 MONSTERS
	--------------------------------------------------------
	for mon, data in pairs(Monster_Drawings) do
		local esp = data.esp
		if not mon or not mon.Parent then
			removeMonsterESP(mon)
			continue
		end

		local pos
		if mon:IsA("BasePart") then
			pos = mon.Position
		elseif mon:IsA("Model") then
			pos = (mon.PrimaryPart and mon.PrimaryPart.Position)
				or (mon:FindFirstChild("torso") and mon.torso.Position)
		end

		-- A-40 (jack) фикс через pcall, как в твоём V0.3
		pcall(function()
			if esp.Label == "A-40" then
				if not mon or not mon.Parent then return end
				if mon.Parent.PrimaryPart then
					pos = mon.Parent.PrimaryPart.Position
				end
			end
		end)

		if not pos then continue end

		local screen, vis = Camera:WorldToViewportPoint(pos)
		local visible = vis and Monster_Enabled
		local settings = MonsterSettings[esp.Label] or {}

		esp.Box.Visible = visible and settings.BoxEnabled
		esp.Name.Visible = visible and settings.NameEnabled
		esp.Distance.Visible = visible and settings.DistanceEnabled
		esp.Tracer.Visible = visible and settings.TracerEnabled

		if not visible then continue end

		local size = 2500 / math.max(screen.Z, 1)
		esp.Box.Size = Vector2.new(size/2, size)
		esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/2)
		esp.Box.Color = settings.BoxColor or data.info.color

		esp.Name.Text = esp.Label
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
		esp.Name.Color = settings.NameColor or data.info.color

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
			esp.Distance.Text = string.format("[%.1f m]", dist)
			esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
			esp.Distance.Color = settings.DistanceColor or Color3.fromRGB(180,180,180)
		end

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = settings.TracerColor or data.info.color
	end

	--------------------------------------------------------
	-- 🔋 BATTERIES
	--------------------------------------------------------
	for obj, esp in pairs(Battery_Drawings) do
		if not obj or not obj.Parent then
			removeBatteryESP(obj)
			continue
		end

		local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
		if not pos then continue end

		local screen, vis = Camera:WorldToViewportPoint(pos)
		local visible = vis and Battery_Enabled

		esp.Box.Visible = visible and BatterySettings.BoxEnabled
		esp.Name.Visible = visible and BatterySettings.NameEnabled
		esp.Distance.Visible = visible and BatterySettings.DistanceEnabled
		esp.Tracer.Visible = visible and BatterySettings.TracerEnabled

		if not visible then continue end

		local size = 800 / math.max(screen.Z, 1)
		esp.Box.Size = Vector2.new(size/2, size/2)
		esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/4)
		esp.Box.Color = BatterySettings.Color

		esp.Name.Text = "Battery"
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 8)
		esp.Name.Color = BatterySettings.Color

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
			esp.Distance.Text = string.format("[%.1f m]", dist)
			esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 20)
			esp.Distance.Color = BatterySettings.DistanceColor
		end

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = BatterySettings.Color
	end
end)
