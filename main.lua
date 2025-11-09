--[[======================================================
   ⚙️ XERA HUB — MONSTER & BATTERY ESP (STABLE CLEANUP)
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
local LHRP = Character:FindFirstChild("HumanoidRootPart")
local PointLight = Instance.new("PointLight")
PointLight.Parent = LHRP
PointLight.Range = 60
PointLight.Brightness = 2
PointLight.Shadows = false
PointLight.Name = "FakeLight"

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
local notificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/xaxas-notification/src.lua"))()

local function notifytext(text, rgb, dur)
	local notifications = notificationLibrary.new({
		NotificationLifetime = dur or 3,
		NotificationPosition = "Middle",
		TextFont = Enum.Font.Jura,
		TextColor = rgb or Color3.fromRGB(255,255,255),
		TextSize = 25,
		TextStrokeTransparency = 0,
		TextStrokeColor = Color3.fromRGB(0, 0, 0),
	})
	notifications:BuildNotificationUI()
	notifications:Notify(text)
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
local function pnevnotif() playSound(8509804480) end

------------------------------------------------------------
-- ⚙️ Настройки ESP
------------------------------------------------------------
local Monster_Enabled = true
local Battery_Enabled = true

local Monster_Drawings = {}
local Battery_Drawings = {}
local KnownMonsters = {}
local KnownBatteries = {}

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

	return {
		Box = box,
		Name = name,
		Distance = dist,
		Tracer = tracer,
		Color = color or Color3.fromRGB(255,255,255),
		Label = label or "Entity"
	}
end

------------------------------------------------------------
-- 👾 Monsters
------------------------------------------------------------
local MonsterNames = {
	["monster"] = {label = "A-60", color = Color3.fromRGB(255, 0, 0)},
	["monster2"] = {label = "A-120/A-200", color = Color3.fromRGB(255, 255, 255)},
	["Spirit"] = {label = "A-100", color = Color3.fromRGB(140, 0, 255)},
	["handdebris"] = {label = "A-250", color = Color3.fromRGB(255, 0, 0)},
	["jack"] = {label = "A-40", color = Color3.fromRGB(200, 200, 200)},
}

local function highlight(obj, color)
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.FillTransparency = 0.1
	hl.OutlineTransparency = 1
	hl.FillColor = color or Color3.fromRGB(255, 255, 255)
	hl.Parent = obj
end

local function addMonsterESP(mon)
	if KnownMonsters[mon] then return end
	local info = MonsterNames[mon.Name]
	if not info then return end

	local esp = CreateESPObject(info.label, info.color)
	Monster_Drawings[mon] = {esp = esp, info = info}
	KnownMonsters[mon] = true

	alertnotif()
	notifytext("⚠ Monster spawned: " .. info.label, info.color, 3)

	if mon.Name == "jack" then
		notifytext("👁 A-40 detected! Highlighting lockers...", Color3.fromRGB(200,200,200), 4)
		highlight(mon.Parent, Color3.fromRGB(255,255,255))
	end
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

	alertnotif()
	if info then
		notifytext("✅ Monster despawned: " .. info.label, Color3.fromRGB(100,255,100), 2)
	end
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
	highlight(obj, Color3.fromRGB(255,143,74))
	normalnotif()
end

local function removeBatteryESP(obj)
	local esp = Battery_Drawings[obj]
	if not esp then return end
	for _,v in pairs(esp) do
		safeRemove(v)
	end
	Battery_Drawings[obj] = nil
	KnownBatteries[obj] = nil
	notifytext("🔋 Battery removed.", Color3.fromRGB(255,0,0), 1)
end

------------------------------------------------------------
-- 🔍 Entity Registration
------------------------------------------------------------
workspace.ChildAdded:Connect(function(obj)
	if MonsterNames[obj.Name] then
		addMonsterESP(obj)
	end
end)

workspace.rooms.DescendantAdded:Connect(function(child)
	if child:IsA("Model") and child.Name == "battery" then
		addBatteryESP(child)
	elseif child:IsA("Model") and MonsterNames[child.Name] then
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
-- 🧠 ESP Tab
------------------------------------------------------------
local ESP_Tab = Window:CreateTab("ESP")
ESP_Tab:CreateSection("Entities")

ESP_Tab:CreateToggle({
	Name = "Monster ESP",
	CurrentValue = true,
	Callback = function(v)
		Monster_Enabled = v
	end
})

ESP_Tab:CreateToggle({
	Name = "Battery ESP",
	CurrentValue = true,
	Callback = function(v)
		Battery_Enabled = v
	end
})

------------------------------------------------------------
-- 🔁 Render Update (Monsters + Batteries)
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	-- 👾 MONSTERS
	for mon, data in pairs(Monster_Drawings) do
		local esp = data.esp
		if not mon or not mon.Parent then
			removeMonsterESP(mon)
			continue
		end

		local target = mon

		if mon.Name == "jack" then
			target = mon.Parent
		end
		local pos
		if mon:IsA("BasePart") then
			pos = Target.Position
		elseif mon:IsA("Model") then
			pos = (target.PrimaryPart and target.PrimaryPart.Position)
				or (target:FindFirstChild("torso") and target.torso.Position)
		end
		if not pos then continue end

		local screen, vis = Camera:WorldToViewportPoint(pos)
		local visible = vis and Monster_Enabled

		esp.Box.Visible = visible
		esp.Name.Visible = visible
		esp.Distance.Visible = visible
		esp.Tracer.Visible = visible
		if not visible then continue end

		local size = 2500 / math.max(screen.Z, 1)
		esp.Box.Size = Vector2.new(size/2, size)
		esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/2)
		esp.Box.Color = esp.Color

		esp.Name.Text = esp.Label
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 10)
		esp.Name.Color = esp.Color

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
			esp.Distance.Text = string.format("[%.1f m]", dist)
			esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 25)
			esp.Distance.Color = Color3.fromRGB(180,180,180)
		end

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = esp.Color
	end

	-- 🔋 BATTERIES
	for obj, esp in pairs(Battery_Drawings) do
		if not obj or not obj.Parent then
			removeBatteryESP(obj)
			continue
		end

		local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
		if not pos then continue end
		local screen, vis = Camera:WorldToViewportPoint(pos)
		local visible = vis and Battery_Enabled

		esp.Box.Visible = visible
		esp.Name.Visible = visible
		esp.Distance.Visible = visible
		esp.Tracer.Visible = visible
		if not visible then continue end

		local size = 800 / math.max(screen.Z, 1)
		esp.Box.Size = Vector2.new(size/2, size/2)
		esp.Box.Position = Vector2.new(screen.X - size/4, screen.Y - size/4)
		esp.Box.Color = esp.Color

		esp.Name.Text = "Battery"
		esp.Name.Position = Vector2.new(screen.X, screen.Y + size/2 + 8)
		esp.Name.Color = esp.Color

		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
			esp.Distance.Text = string.format("[%.1f m]", dist)
			esp.Distance.Position = Vector2.new(screen.X, screen.Y + size/2 + 20)
			esp.Distance.Color = Color3.fromRGB(180,180,180)
		end

		local bottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 50)
		esp.Tracer.From = bottom
		esp.Tracer.To = Vector2.new(screen.X, screen.Y)
		esp.Tracer.Color = esp.Color
	end
end)
