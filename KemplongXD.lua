-- KemplongXD v1.8.2 — Responsive, Lengkap, Tema Dark, Tanpa Emotikon, Animasi Smooth, Anti Lag
-- Baru v1.8.2: Sisa analisa K3-K16 — koneksi drag dilepas, PopIn pakai ulang UIScale, HoverPairs dibersihkan, SetToggleKey validasi KeyCode, flag Animasi, SetAccent turunkan Accent2, clamp aman, guard Player, Server Hop pcall, Global Search pakai atribut judul, sanitasi nama config
-- Ciri khas: Bahasa Indonesia, dark-only 6 tema, aksen ungu xD, mobile-first FAB, tanpa emotikon
-- Perbaikan v1.4.0: SetWhitelist aman untuk id tidak valid, AutoLoad kini kembalikan modul baru via OnLoaded
-- Sebelumnya v1.3.1: Perbaikan bug — tema kini benar-benar berubah di semua kontrol, ToggleUI sembunyikan bayangan, Notify tidak bocor, accent tidak hilang
-- Library GUI Luau untuk Roblox (PC + Android / Mobile + Tablet + Console)
-- Script Hub Library | Dark Theme | Tema bisa diubah
-- Pakai sebagai ModuleScript: local KemplongXD = require(script.Parent.KemplongXD)
-- Contoh hub lengkap ada di KemplongXD_Hub.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
-- v1.8.2 (K12): nil-guard — di Studio/server LocalPlayer bisa nil saat require; GUI tetap
-- dibuat tanpa error di baris ini (parent nil), fungsi yang butuh Player tetap memakai Player.
local PlayerGui = Player and Player:WaitForChild("PlayerGui") or nil
local Camera = workspace.CurrentCamera

local KemplongXD = {}
KemplongXD.Version = "1.8.2"
KemplongXD.Animations = true
KemplongXD.MaxNotifications = 3

-- ============================================================================
-- DETEKSI PERANGKAT & RESPONSIF
-- ============================================================================
local IsTouch = UserInputService.TouchEnabled
local IsKeyboard = UserInputService.KeyboardEnabled
local IsMobile = IsTouch and not IsKeyboard

local function ViewportSize()
	local cam = workspace.CurrentCamera
	if cam then return cam.ViewportSize end
	if Camera then return Camera.ViewportSize end
	return Vector2.new(800, 500)
end
local function IsSmallScreen()
	return ViewportSize().X < 650 or IsMobile
end
-- Skala UI: HP kecil -> 0.82, tablet -> 0.92, PC -> 1
local function UIScaleValue()
	local vp = ViewportSize()
	if vp.X < 480 then return 0.78
	elseif vp.X < 650 then return 0.88
	elseif vp.X < 900 then return 0.95
	else return 1 end
end

-- ============================================================================
-- TEMA — 6 tema bawaan, bisa diganti runtime: Window:SetTheme("Ocean")
-- ============================================================================
KemplongXD.Themes = {
	Dark = {
		Name = "Dark", Background = Color3.fromRGB(17, 17, 23), Sidebar = Color3.fromRGB(22, 22, 30),
		Element = Color3.fromRGB(29, 29, 39), ElementHover = Color3.fromRGB(38, 38, 51),
		Stroke = Color3.fromRGB(48, 48, 64), Text = Color3.fromRGB(236, 236, 246),
		SubText = Color3.fromRGB(151, 151, 172), Accent = Color3.fromRGB(124, 92, 255),
		Accent2 = Color3.fromRGB(88, 101, 242), Green = Color3.fromRGB(46, 204, 113),
		Red = Color3.fromRGB(231, 76, 60), Yellow = Color3.fromRGB(241, 196, 15),
	},
	Midnight = {
		Name = "Midnight", Background = Color3.fromRGB(8, 10, 18), Sidebar = Color3.fromRGB(12, 14, 26),
		Element = Color3.fromRGB(18, 20, 34), ElementHover = Color3.fromRGB(26, 28, 46),
		Stroke = Color3.fromRGB(36, 40, 62), Text = Color3.fromRGB(230, 236, 255),
		SubText = Color3.fromRGB(139, 149, 178), Accent = Color3.fromRGB(0, 212, 255),
		Accent2 = Color3.fromRGB(124, 92, 255), Green = Color3.fromRGB(0, 210, 160),
		Red = Color3.fromRGB(255, 92, 92), Yellow = Color3.fromRGB(255, 200, 60),
	},
	Ocean = {
		Name = "Ocean", Background = Color3.fromRGB(10, 22, 32), Sidebar = Color3.fromRGB(14, 28, 40),
		Element = Color3.fromRGB(20, 36, 50), ElementHover = Color3.fromRGB(28, 48, 66),
		Stroke = Color3.fromRGB(42, 66, 88), Text = Color3.fromRGB(224, 242, 255),
		SubText = Color3.fromRGB(140, 168, 190), Accent = Color3.fromRGB(0, 170, 255),
		Accent2 = Color3.fromRGB(0, 220, 200), Green = Color3.fromRGB(46, 204, 113),
		Red = Color3.fromRGB(231, 76, 60), Yellow = Color3.fromRGB(241, 196, 15),
	},
	Neon = {
		Name = "Neon", Background = Color3.fromRGB(12, 12, 12), Sidebar = Color3.fromRGB(16, 16, 16),
		Element = Color3.fromRGB(24, 24, 24), ElementHover = Color3.fromRGB(34, 34, 34),
		Stroke = Color3.fromRGB(55, 55, 55), Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(160, 160, 160), Accent = Color3.fromRGB(0, 255, 170),
		Accent2 = Color3.fromRGB(255, 0, 128), Green = Color3.fromRGB(0, 255, 170),
		Red = Color3.fromRGB(255, 60, 90), Yellow = Color3.fromRGB(255, 230, 0),
	},
	Purple = {
		Name = "Purple", Background = Color3.fromRGB(16, 12, 24), Sidebar = Color3.fromRGB(21, 16, 32),
		Element = Color3.fromRGB(28, 22, 42), ElementHover = Color3.fromRGB(38, 30, 56),
		Stroke = Color3.fromRGB(52, 42, 76), Text = Color3.fromRGB(240, 234, 255),
		SubText = Color3.fromRGB(168, 158, 198), Accent = Color3.fromRGB(168, 85, 247),
		Accent2 = Color3.fromRGB(124, 92, 255), Green = Color3.fromRGB(46, 204, 113),
		Red = Color3.fromRGB(231, 76, 60), Yellow = Color3.fromRGB(241, 196, 15),
	},
	Crimson = {
		Name = "Crimson", Background = Color3.fromRGB(20, 12, 14), Sidebar = Color3.fromRGB(26, 15, 18),
		Element = Color3.fromRGB(34, 20, 23), ElementHover = Color3.fromRGB(46, 26, 30),
		Stroke = Color3.fromRGB(62, 36, 40), Text = Color3.fromRGB(255, 232, 235),
		SubText = Color3.fromRGB(190, 150, 158), Accent = Color3.fromRGB(239, 68, 68),
		Accent2 = Color3.fromRGB(255, 105, 120), Green = Color3.fromRGB(46, 204, 113),
		Red = Color3.fromRGB(231, 76, 60), Yellow = Color3.fromRGB(241, 196, 15),
	},
}
local CurrentTheme = KemplongXD.Themes.Dark
local CustomAccent = nil
local CustomAccent2 = nil
-- v1.8.2 (K10): turunan Accent2 dari aksen custom — sedikit lebih gelap, supaya gradient
-- aksen tidak lagi campuran aksen baru + Accent2 tema lama.
local function DeriveAccent2(color)
	local h, s, v = Color3.toHSV(color)
	return Color3.fromHSV(h, s, math.clamp(v * 0.75, 0, 1))
end

-- Tambah tema buatan sendiri: KemplongXD:AddTheme("Namaku", {Background=..., Accent=...})
function KemplongXD:AddTheme(name, theme)
	if not name or name == "" or typeof(theme) ~= "table" then return false end
	-- Merge dengan Dark sebagai default, lalu validasi semua field wajib Color3.
	-- Tanpa ini, tema custom yang tidak lengkap membuat T().Element dll. jadi nil.
	local base = table.clone(KemplongXD.Themes.Dark)
	for k, v in pairs(theme) do base[k] = v end
	for _, field in ipairs({ "Background", "Sidebar", "Element", "ElementHover", "Stroke", "Text", "SubText", "Accent", "Accent2", "Green", "Red", "Yellow" }) do
		if typeof(base[field]) ~= "Color3" then return false end
	end
	KemplongXD.Themes[name] = base
	return true
end
-- Ganti warna aksen saja tanpa ganti tema penuh (tetap tersimpan saat ganti tema via SetAccent)
function KemplongXD:SetAccent(color)
	CustomAccent = color
	CustomAccent2 = DeriveAccent2(color)
	CurrentTheme = table.clone(CurrentTheme)
	CurrentTheme.Accent = color
	CurrentTheme.Accent2 = CustomAccent2
end
function KemplongXD:ResetAccent()
	CustomAccent = nil
	CustomAccent2 = nil
end
function KemplongXD:GetThemes()
	local list = {}
	for name in pairs(KemplongXD.Themes) do table.insert(list, name) end
	table.sort(list)
	return list
end
-- ============================================================================
-- CONFIG FILE v1.3.0 — simpan ke file executor (writefile/readfile), fallback memori
-- Folder: KemplongXD/Configs/<nama>.json  |  Key tersimpan: KemplongXD/saved_key.txt
-- ============================================================================
KemplongXD.ConfigFolder = "KemplongXD/Configs"
KemplongXD.Configs = KemplongXD.Configs or {}
local function HasFileFuncs()
	return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
end
local function EnsureConfigFolder()
	if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
		pcall(function()
			if not isfolder("KemplongXD") then makefolder("KemplongXD") end
			if not isfolder(KemplongXD.ConfigFolder) then makefolder(KemplongXD.ConfigFolder) end
		end)
	end
end
local function EncodeFlagValue(v)
	if typeof(v) == "Color3" then
		return { __type = "Color3", hex = v:ToHex() }
	elseif typeof(v) == "EnumItem" then
		return { __type = "Enum", name = v.Name, enumType = tostring(v.EnumType) }
	elseif typeof(v) == "table" then
		local out = {}
		for k, val in pairs(v) do out[k] = EncodeFlagValue(val) end
		return out
	else
		return v
	end
end
local function DecodeFlagValue(v)
	if typeof(v) == "table" and v.__type == "Color3" then
		local ok, col = pcall(Color3.fromHex, v.hex or "7C5CFF")
		return ok and col or Color3.fromRGB(124, 92, 255)
	elseif typeof(v) == "table" and v.__type == "Enum" then
		local ok, enumType = pcall(function() return Enum[v.enumType] end)
		if ok and enumType then
			local ok2, item = pcall(function() return enumType[v.name] end)
			if ok2 then return item end
		end
		return Enum.KeyCode.F
	elseif typeof(v) == "table" then
		local out = {}
		for k, val in pairs(v) do out[k] = DecodeFlagValue(val) end
		return out
	else
		return v
	end
end
-- v1.8.2 (K16): sanitasi nama config supaya "../" tidak bisa menulis di luar folder Configs.
local function SanitizeConfigName(name)
	name = tostring(name or "Default")
	name = string.gsub(name, "[/\\]", "_")
	name = string.gsub(name, "%.%.", "_")
	if name == "" then name = "Default" end
	return name
end
function KemplongXD:SaveConfigFile(name, data)
	name = SanitizeConfigName(name)
	if HasFileFuncs() then
		EnsureConfigFolder()
		local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
		if ok then
			local wok = pcall(writefile, KemplongXD.ConfigFolder .. "/" .. name .. ".json", json)
			if wok then return true end
		end
	end
	KemplongXD.Configs[name] = data
	return false
end
function KemplongXD:LoadConfigFile(name)
	name = SanitizeConfigName(name)
	if HasFileFuncs() then
		local ok, exists = pcall(isfile, KemplongXD.ConfigFolder .. "/" .. name .. ".json")
		if ok and exists then
			local rok, content = pcall(readfile, KemplongXD.ConfigFolder .. "/" .. name .. ".json")
			if rok and content and content ~= "" then
				local dok, data = pcall(function() return HttpService:JSONDecode(content) end)
				if dok and typeof(data) == "table" then return data end
			end
		end
	end
	return KemplongXD.Configs[name]
end
function KemplongXD:ListConfigFiles()
	local out = {}
	if HasFileFuncs() and typeof(listfiles) == "function" then
		local ok, files = pcall(listfiles, KemplongXD.ConfigFolder)
		if ok and files then
			for _, f in ipairs(files) do
				local name = string.match(f, "([^/\\]+)%.json$")
				if name then table.insert(out, name) end
			end
		end
	end
	for name in pairs(KemplongXD.Configs) do
		if not table.find(out, name) then table.insert(out, name) end
	end
	table.sort(out)
	return out
end
function KemplongXD:DeleteConfigFile(name)
	name = SanitizeConfigName(name)
	KemplongXD.Configs[name] = nil
	if HasFileFuncs() and typeof(delfile) == "function" then
		pcall(delfile, KemplongXD.ConfigFolder .. "/" .. name .. ".json")
	end
end

local function T() return CurrentTheme end

-- ============================================================================
-- HELPERS + ANIMASI
-- ============================================================================
local function New(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	inst.Parent = parent
	return inst
end
local function Corner(p, r) return New("UICorner", { CornerRadius = UDim.new(0, r or 10) }, p) end
local function Stroke(p, c, th) return New("UIStroke", { Color = c or T().Stroke, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function Padding(p, l, t, r, b) return New("UIPadding", { PaddingLeft = UDim.new(0, l or 10), PaddingTop = UDim.new(0, t or 8), PaddingRight = UDim.new(0, r or 10), PaddingBottom = UDim.new(0, b or 8) }, p) end
local function Gradient(p, c1, c2, rot)
	local g = New("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rot or 90 }, p)
	return g
end
local function Tween(inst, time, props, style, dir)
	if not KemplongXD.Animations then
		for k, v in pairs(props) do
			pcall(function() inst[k] = v end)
		end
		return nil
	end
	local tw = TweenService:Create(inst, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play() return tw
end
-- v1.8.2 (K11): clamp yang aman kalau min > max (misal config rusak) — math.clamp biasa error.
local function SafeClamp(v, lo, hi)
	if lo > hi then lo, hi = hi, lo end
	return math.clamp(v, lo, hi)
end
local function PopIn(frame)
	-- Animasi buka window: scale 0.97 -> 1 dengan easing Quad (tanpa Back, sesuai v1.1.0).
	-- v1.8.2 (K4): pakai ulang UIScale milik PopIn (ditandai atribut PopInScale) supaya
	-- ToggleUI berulang tidak menumpuk instance; UIScale lain (misal GuiScale responsif) tidak disentuh.
	local s = nil
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("UIScale") then
			local ok, marked = pcall(function() return child:GetAttribute("PopInScale") end)
			if ok and marked then s = child break end
		end
	end
	if not s then
		s = New("UIScale", { Scale = 0.97 }, frame)
		pcall(function() s:SetAttribute("PopInScale", true) end)
	end
	s.Scale = 0.97
	TweenService:Create(s, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end
-- HoverRegistry v1.3.1: AddHover menyimpan role warna (element/accent/...) bukan nilai beku,
-- supaya setelah ganti tema hover memakai warna tema baru.
local HoverPairs = {}
local function InferThemeRole(c)
	local th = T()
	if c == th.Element then return "element"
	elseif c == th.ElementHover then return "elementhover"
	elseif c == th.Accent then return "accent"
	elseif c == th.Accent2 then return "accent2"
	elseif c == th.Sidebar then return "sidebar"
	elseif c == th.Background then return "bg"
	elseif c == th.Stroke then return "stroke" end
	return "custom"
end
local function RoleColor(role, th)
	if role == "element" then return th.Element
	elseif role == "elementhover" then return th.ElementHover
	elseif role == "accent" then return th.Accent
	elseif role == "accent2" then return th.Accent2
	elseif role == "sidebar" then return th.Sidebar
	elseif role == "bg" then return th.Background
	elseif role == "stroke" then return th.Stroke end
	return nil
end
local function AddHover(btn, base, hover)
	-- v1.8.2 (K5): bersihkan entri tombol yang sudah dihancurkan di sini juga, bukan cuma
	-- saat ganti tema — buat-destroy hub berulang tanpa ganti tema tidak lagi menumpuk daftar.
	for i = #HoverPairs, 1, -1 do
		local e = HoverPairs[i]
		if not e.Btn or not e.Btn.Parent then table.remove(HoverPairs, i) end
	end
	local entry = { Btn = btn, Base = base, Hover = hover, BaseRole = InferThemeRole(base), HoverRole = InferThemeRole(hover) }
	table.insert(HoverPairs, entry)
	btn.MouseEnter:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = entry.Hover }) end)
	btn.MouseLeave:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = entry.Base }) end)
end
local function RefreshHoverPairs(th)
	for i = #HoverPairs, 1, -1 do
		local e = HoverPairs[i]
		if not e.Btn or not e.Btn.Parent then table.remove(HoverPairs, i) end
	end
	for _, e in ipairs(HoverPairs) do
		if e.Btn and e.Btn.Parent then
			local nb = RoleColor(e.BaseRole, th)
			local nh = RoleColor(e.HoverRole, th)
			if nb then e.Base = nb end
			if nh then e.Hover = nh end
		end
	end
end
local function AddPress(btn)
	-- Efek tekan: mengecil 3% lalu kembali
	local scale = btn:FindFirstChildOfClass("UIScale") or New("UIScale", {}, btn)
	btn.MouseButton1Down:Connect(function() TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.97 }):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = 1 }):Play() end)
end
-- Ripple sengaja stub kosong (anti-lag v1.1.0): dipanggil di tempatnya supaya komponen lain
-- tidak perlu cek, tapi tidak membuat efek apa pun. Jangan diisi loop animasi.
local function Ripple(btn) end
local function MakeDraggable(frame, handle)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = frame.Position
			pcall(function() frame:SetAttribute("Dragged", true) end)
			-- v1.8.2 (K3): koneksi input.Changed ini dilepas saat drag selesai, tidak menumpuk per drag.
			local changedConn
			changedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if changedConn then changedConn:Disconnect() end
				end
			end)
		end
	end)
	return UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			-- v1.8.0: clamp saat drag — window/FAB tidak boleh diseret sampai hilang dari layar.
			local vp = ViewportSize()
			local absX = newPos.X.Scale * vp.X + newPos.X.Offset
			local absY = newPos.Y.Scale * vp.Y + newPos.Y.Offset
			local w = frame.AbsoluteSize.X
			absX = math.clamp(absX, -(w - 80), math.max(0, vp.X - 80))
			absY = math.clamp(absY, 0, math.max(0, vp.Y - 52))
			frame.Position = UDim2.new(newPos.X.Scale, absX - newPos.X.Scale * vp.X, newPos.Y.Scale, absY - newPos.Y.Scale * vp.Y)
		end
	end)
end
-- Shimmer sengaja stub kosong (anti-lag v1.1.0), sama seperti Ripple di atas.
local function Shimmer(frame) end

-- ============================================================================
-- NOTIFY — bertumpuk, ada tipe & animasi slide
-- ============================================================================
local NotifyGui = nil
local NotifyList = {}
KemplongXD.NotificationHistory = KemplongXD.NotificationHistory or {}
function KemplongXD:GetNotifications()
	local out = {}
	for i, e in ipairs(KemplongXD.NotificationHistory) do out[i] = e end
	return out
end
function KemplongXD:ClearNotifications()
	table.clear(KemplongXD.NotificationHistory)
end
function KemplongXD:Notify(title, desc, duration, kind)
	duration = duration or 3.5
	kind = kind or "Info"
	local colors = { Success = T().Green, Error = T().Red, Info = T().Accent, Warning = T().Yellow }
	if not NotifyGui then
		NotifyGui = New("ScreenGui", { Name = "KemplongXD_Notify", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000 }, PlayerGui)
	end
	if #NotifyList >= (KemplongXD.MaxNotifications or 3) then
		local oldest = NotifyList[1]
		if oldest then table.remove(NotifyList, 1) oldest:Destroy() end
	end
	local idx = #NotifyList + 1
	local y = 16 + (idx - 1) * 76
	local w = IsSmallScreen() and math.min(ViewportSize().X - 32, 340) or 320
	local n = New("Frame", { Size = UDim2.new(0, w, 0, 64), Position = UDim2.new(1, 20, 0, y), BackgroundColor3 = T().Element, BorderSizePixel = 0, ClipsDescendants = true }, NotifyGui)
	table.insert(NotifyList, n)
	table.insert(KemplongXD.NotificationHistory, 1, { Title = title or "KemplongXD", Desc = desc or "", Kind = kind, Time = os.date("%H:%M:%S") })
	if #KemplongXD.NotificationHistory > 50 then table.remove(KemplongXD.NotificationHistory) end
	Corner(n, 12) Stroke(n)
	New("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = colors[kind] or T().Accent, BorderSizePixel = 0 }, n)
	New("TextLabel", { Text = (title or "KemplongXD"), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 8), Size = UDim2.new(1, -28, 0, 20), TextXAlignment = Enum.TextXAlignment.Left }, n)
	New("TextLabel", { Text = desc or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 30), Size = UDim2.new(1, -28, 0, 28), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true }, n)
	local bar = New("Frame", { BackgroundColor3 = colors[kind] or T().Accent, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -3), Size = UDim2.new(1, 0, 0, 3) }, n)
	Tween(n, 0.22, { Position = UDim2.new(1, -w - 16, 0, y) }, Enum.EasingStyle.Quad)
	Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
	task.delay(duration + 0.3, function()
		Tween(n, 0.3, { Position = UDim2.new(1, 20, 0, y) })
		task.wait(0.32)
		local pos = table.find(NotifyList, n)
		if pos then table.remove(NotifyList, pos) end
		n:Destroy()
		for i, other in ipairs(NotifyList) do
			if other.Parent then Tween(other, 0.2, { Position = UDim2.new(1, -other.AbsoluteSize.X - 16, 0, 16 + (i - 1) * 76) }) end
		end
	end)
end


-- ============================================================================
-- KEY SYSTEM v1.3.0 — gerbang key sebelum hub dibuka
-- Pakai: KemplongXD:CreateKeySystem({ Key = "KEMPLONG-123", GetKeyLink = "https://...", OnSuccess = function() ... end })
-- Key bisa string, tabel string, atau fungsi Validate(key) -> boolean.
-- Key benar tersimpan ke file KemplongXD/saved_key.txt kalau RememberKey = true.
-- ============================================================================
function KemplongXD:CreateKeySystem(config)
	config = config or {}
	local keys = config.Key or config.Keys or "KEMPLONG"
	local getLink = config.GetKeyLink or config.KeyLink or ""
	local remember = config.RememberKey ~= false
	local onSuccess = config.OnSuccess or function() end
	local title = config.Title or "KemplongXD"
	local subtitle = config.Subtitle or "Masukkan key untuk membuka hub."
	local function IsValidKey(k)
		if typeof(config.Validate) == "function" then
			local ok, res = pcall(config.Validate, k)
			return ok and res == true
		end
		if typeof(keys) == "table" then return table.find(keys, k) ~= nil end
		return k == keys
	end
	if remember and HasFileFuncs() then
		local ok, exists = pcall(isfile, "KemplongXD/saved_key.txt")
		if ok and exists then
			local rok, saved = pcall(readfile, "KemplongXD/saved_key.txt")
			if rok and saved and saved ~= "" and IsValidKey(saved:gsub("%s+", "")) then
				task.spawn(onSuccess)
				return { Success = true, Skipped = true }
			end
		end
	end
	local old = PlayerGui:FindFirstChild("KemplongXD_KeySystem")
	if old then old:Destroy() end
	local Gui = New("ScreenGui", { Name = "KemplongXD_KeySystem", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 2000 }, PlayerGui)
	-- v1.8.0: kartu tidak boleh lebih lebar dari layar (HP kecil 320px).
	local keyW = math.min(360, ViewportSize().X - 24)
	local Main = New("Frame", { Size = UDim2.new(0, keyW, 0, 240), Position = UDim2.new(0.5, -keyW / 2, 0.5, -120), BackgroundColor3 = T().Background, BorderSizePixel = 0, ClipsDescendants = true }, Gui)
	Corner(Main, 14) Stroke(Main)
	PopIn(Main)
	New("TextLabel", { Text = title, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, 0, 0, 24) }, Main)
	New("TextLabel", { Text = subtitle, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 18) }, Main)
	local box = New("TextBox", { Text = "", PlaceholderText = "Masukkan key di sini...", PlaceholderColor3 = T().SubText, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, -32, 0, 38), Position = UDim2.new(0, 16, 0, 78), ClearTextOnFocus = false }, Main)
	Corner(box, 9) Padding(box, 10, 0, 10, 0)
	local errLbl = New("TextLabel", { Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Red, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 120), Size = UDim2.new(1, -32, 0, 18) }, Main)
	local submit = New("TextButton", { Text = "Buka Hub", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(1, -32, 0, 38), Position = UDim2.new(0, 16, 0, 146), AutoButtonColor = false }, Main)
	Corner(submit, 10) AddPress(submit)
	local getKey = New("TextButton", { Text = "Dapatkan Key", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Element, Size = UDim2.new(1, -32, 0, 32), Position = UDim2.new(0, 16, 0, 192), AutoButtonColor = false }, Main)
	Corner(getKey, 9) Stroke(getKey)
	local function TryOpen()
		local k = box.Text:gsub("%s+", "")
		if k == "" then errLbl.Text = "Key masih kosong." return end
		if IsValidKey(k) then
			if remember and HasFileFuncs() then
				EnsureConfigFolder()
				pcall(writefile, "KemplongXD/saved_key.txt", k)
			end
			Gui:Destroy()
			task.spawn(onSuccess)
		else
			errLbl.Text = "Key salah. Coba lagi."
			Tween(Main, 0.1, { Position = UDim2.new(0.5, -170, 0.5, -120) })
			task.wait(0.1)
			Tween(Main, 0.1, { Position = UDim2.new(0.5, -180, 0.5, -120) })
		end
	end
	submit.MouseButton1Click:Connect(TryOpen)
	box.FocusLost:Connect(function(enter) if enter then TryOpen() end end)
	getKey.MouseButton1Click:Connect(function()
		if getLink ~= "" then
			if setclipboard then pcall(setclipboard, getLink) errLbl.Text = "Link key disalin ke clipboard." else errLbl.Text = getLink end
		else
			errLbl.Text = "Belum ada link key yang diatur."
		end
	end)
	return { Gui = Gui, Close = function() Gui:Destroy() end }
end

-- ============================================================================
-- WHITELIST v1.4.0 — batasi hub hanya untuk UserId tertentu
-- Pakai: KemplongXD:CheckWhitelist({ UserIds = {12345678, 87654321}, Kick = false })
--   UserIds = tabel angka UserId (lihat di URL profil Roblox). Names = tabel nama
--   (opsional, dicek juga kalau UserId tidak ada di daftar). Validate = fungsi
--   kustom function(player) -> boolean. Kick = true -> pemain ditendang saat
--   ditolak (default false, hanya blokir hub + notifikasi). Catatan: Kick hanya
--   bekerja dari server — dari LocalScript executor, Player:Kick() tidak
--   berfungsi dan errornya ditelan pcall, jadi whitelist di sini hanya gerbang UI lokal.
--   OnDenied = callback.
--   Tanpa daftar sama sekali (UserIds dan Names kosong) = terbuka untuk semua.
--   Kembalikan true kalau diizinkan, false kalau ditolak. Aman dipanggil
--   sebelum CreateWindow; tidak merusak apa pun kalau gagal.
-- ============================================================================
KemplongXD.Whitelist = nil
function KemplongXD:SetWhitelist(userIds, names, configHwids)
	local ids = {}
	if typeof(userIds) == "table" then
		for _, id in ipairs(userIds) do local n = tonumber(id) if n then ids[n] = true end end
	elseif tonumber(userIds) then
		ids[tonumber(userIds)] = true
	end
	local nms = {}
	if typeof(names) == "table" then
		for _, n in ipairs(names) do nms[string.lower(tostring(n))] = true end
	end
	local hwids = {}
	if typeof(configHwids) == "table" then
		for _, h in ipairs(configHwids) do if h and h ~= "" then hwids[tostring(h)] = true end end
	end
	KemplongXD.Whitelist = { Ids = ids, Names = nms, Hwids = hwids }
	return KemplongXD.Whitelist
end
function KemplongXD:ClearWhitelist()
	KemplongXD.Whitelist = nil
end
-- HWID executor (gethwid), kalau tidak ada executor yang mendukung -> nil (tidak dipakai).
function KemplongXD:GetHWID()
	if typeof(gethwid) == "function" then
		local ok, hwid = pcall(gethwid)
		if ok and hwid and hwid ~= "" then return tostring(hwid) end
	end
	return nil
end
function KemplongXD:IsWhitelisted(playerOrId)
	local plr = playerOrId
	if typeof(plr) == "number" or typeof(plr) == "string" then
		local id = tonumber(plr)
		if KemplongXD.Whitelist then
			return KemplongXD.Whitelist.Ids[id] == true
		end
		return true
	end
	if typeof(plr) ~= "Instance" then plr = Player end
	if not plr then return false end
	if not KemplongXD.Whitelist then return true end
	if KemplongXD.Whitelist.Ids[plr.UserId] then return true end
	if KemplongXD.Whitelist.Names[string.lower(plr.Name)] then return true end
	if KemplongXD.Whitelist.Hwids then
		local hwid = self:GetHWID()
		if hwid and KemplongXD.Whitelist.Hwids[hwid] then return true end
	end
	return false
end
function KemplongXD:CheckWhitelist(config)
	config = config or {}
	if config.UserIds or config.Names or config.Hwids then
		self:SetWhitelist(config.UserIds, config.Names, config.Hwids)
	end
	local plr = config.Player or Player
	if typeof(config.Validate) == "function" then
		local ok, res = pcall(config.Validate, plr)
		if ok and res == true then return true end
		if ok and res == false then
			local msg = config.DenyMessage or "Kamu tidak ada di whitelist hub ini."
			self:Notify("Akses Ditolak", msg, 4, "Error")
			if typeof(config.OnDenied) == "function" then task.spawn(config.OnDenied, plr) end
			if config.Kick and plr and plr.Kick then pcall(function() plr:Kick(msg) end) end
			return false
		end
		-- Validate error: jangan blokir pemain karena bug di fungsi kustom.
		return true
	end
	if self:IsWhitelisted(plr) then return true end
	local msg = config.DenyMessage or ("UserId " .. tostring(plr and plr.UserId or "?") .. " tidak ada di whitelist hub ini.")
	self:Notify("Akses Ditolak", msg, 4, "Error")
	if typeof(config.OnDenied) == "function" then task.spawn(config.OnDenied, plr) end
	if config.Kick and plr and plr.Kick then pcall(function() plr:Kick(msg) end) end
	return false
end

-- Whitelist dari URL (async, v1.5.0): daftar diambil dari JSON, misal
-- {"UserIds":[123,456],"Names":["Putri"],"Hwids":["abc-123"]}.
-- Pakai: KemplongXD:CheckWhitelistRemote({ RemoteUrl = "https://.../whitelist.json",
--   OnAllowed = function() OpenHub() end, OnDenied = function() end, Kick = false })
-- Gagal ambil daftar = ditolak (fail-closed) kecuali AllowOnError = true.
function KemplongXD:CheckWhitelistRemote(config)
	config = config or {}
	local url = config.RemoteUrl or config.Url or ""
	if url == "" then
		if typeof(config.OnDenied) == "function" then task.spawn(config.OnDenied, "RemoteUrl belum diisi.") end
		return false
	end
	task.spawn(function()
		local ok, body = pcall(function() return game:HttpGet(url) end)
		if not ok or typeof(body) ~= "string" or body == "" then
			if config.AllowOnError then
				if typeof(config.OnAllowed) == "function" then task.spawn(config.OnAllowed) end
			elseif typeof(config.OnDenied) == "function" then
				task.spawn(config.OnDenied, "Gagal mengambil whitelist dari URL.")
			end
			return
		end
		local dok, data = pcall(function() return HttpService:JSONDecode(body) end)
		if not dok or typeof(data) ~= "table" then
			if typeof(config.OnDenied) == "function" then task.spawn(config.OnDenied, "Isi whitelist.json tidak valid.") end
			return
		end
		self:SetWhitelist(data.UserIds or data.userIds, data.Names or data.names, data.Hwids or data.hwids)
		local cfg2 = { Player = config.Player, Validate = config.Validate, Kick = config.Kick, DenyMessage = config.DenyMessage, OnDenied = config.OnDenied }
		if self:CheckWhitelist(cfg2) then
			if typeof(config.OnAllowed) == "function" then task.spawn(config.OnAllowed) end
		end
	end)
	return true
end

-- ============================================================================
-- CEK UPDATE v1.4.0 — bandingkan versi lokal dengan file di GitHub (raw)
-- Pakai: KemplongXD:CheckForUpdate({
--   VersionUrl = "https://raw.githubusercontent.com/<user>/<repo>/main/version.txt",
--   LibraryUrl = "https://raw.githubusercontent.com/<user>/<repo>/main/KemplongXD.lua", -- opsional
--   OnUpdate = function(remoteVersion) ... end, -- dipanggil kalau ada versi baru
--   AutoLoad = false, -- true = langsung loadstring versi baru (hanya dari repo yang kamu percaya)
-- })
--   version.txt cukup berisi satu baris, misal: 1.4.1  (atau JSON {"version":"1.4.1"}).
--   Berjalan async (task.spawn + pcall), jadi hub tetap jalan kalau internet /
--   HttpService mati: gagal cek = diam-diam dilewati, kecuali OnError diisi.
--   Kembalikan tabel { Status = "Checking" } saat dipanggil; hasil akhir lewat callback.
-- ============================================================================
local function ParseVersion(v)
	local parts = {}
	if typeof(v) ~= "string" then v = tostring(v or "") end
	for num in string.gmatch(v, "(%d+)") do table.insert(parts, tonumber(num)) end
	return parts
end
function KemplongXD:CompareVersions(a, b)
	local pa, pb = ParseVersion(a), ParseVersion(b)
	local n = math.max(#pa, #pb)
	for i = 1, n do
		local x, y = pa[i] or 0, pb[i] or 0
		if x < y then return -1 end
		if x > y then return 1 end
	end
	return 0
end
function KemplongXD:CheckForUpdate(config)
	config = config or {}
	local versionUrl = config.VersionUrl or config.RawUrl or config.Url or ""
	local libraryUrl = config.LibraryUrl or config.LoadUrl or ""
	local current = config.CurrentVersion or KemplongXD.Version
	local showNotify = config.Notify ~= false
	local result = { Status = "Checking", Current = current, Remote = nil }
	if versionUrl == "" then
		result.Status = "NoUrl"
		if typeof(config.OnError) == "function" then task.spawn(config.OnError, "VersionUrl belum diisi.") end
		return result
	end
	task.spawn(function()
		local ok, body = pcall(function() return game:HttpGet(versionUrl) end)
		if not ok or typeof(body) ~= "string" or body == "" then
			result.Status = "Error"
			if typeof(config.OnError) == "function" then task.spawn(config.OnError, "Gagal mengambil versi dari GitHub. Cek URL dan HttpService.") end
			return
		end
		local remote = nil
		local trimmed = body:gsub("^%s+", ""):gsub("%s+$", "")
		if string.sub(trimmed, 1, 1) == "{" then
			local dok, data = pcall(function() return HttpService:JSONDecode(trimmed) end)
			if dok and typeof(data) == "table" then remote = data.version or data.Version end
		end
		if not remote then remote = string.match(trimmed, "(%d+%.%d+%.%d+)") or string.match(trimmed, "(%d+%.%d+)") end
		if not remote then
			result.Status = "Error"
			if typeof(config.OnError) == "function" then task.spawn(config.OnError, "Isi version.txt tidak dikenali (harapkan misal: 1.4.1).") end
			return
		end
		result.Remote = remote
		if self:CompareVersions(current, remote) >= 0 then
			result.Status = "UpToDate"
			if typeof(config.OnNoUpdate) == "function" then task.spawn(config.OnNoUpdate, remote) end
			return
		end
		result.Status = "UpdateAvailable"
		if showNotify then self:Notify("Update Tersedia", "KemplongXD v" .. remote .. " sudah ada (kamu pakai v" .. current .. ").", 5, "Info") end
		if typeof(config.OnUpdate) == "function" then task.spawn(config.OnUpdate, remote) end
		if config.AutoLoad and libraryUrl ~= "" then
			local lok, src = pcall(function() return game:HttpGet(libraryUrl) end)
			if lok and typeof(src) == "string" and src ~= "" then
				local fn, err = loadstring(src)
				if fn then
					local rok, newModule = pcall(fn)
					if rok and typeof(newModule) == "table" then
						result.NewModule = newModule
						-- Catatan: modul baru TIDAK otomatis mengganti Window yang sudah dibuka.
						-- Pakai OnLoaded untuk require ulang / buka ulang hub dengan modul baru.
						if typeof(config.OnLoaded) == "function" then task.spawn(config.OnLoaded, newModule, remote) end
					elseif not rok and typeof(config.OnError) == "function" then
						task.spawn(config.OnError, "Gagal memuat versi baru: " .. tostring(newModule))
					end
				elseif typeof(config.OnError) == "function" then
					task.spawn(config.OnError, "Kode versi baru tidak valid: " .. tostring(err))
				end
			elseif typeof(config.OnError) == "function" then
				task.spawn(config.OnError, "Gagal mengunduh library versi baru.")
			end
		end
	end)
	return result
end

-- ============================================================================
-- LOADING SCREEN v1.6.0 — layar pembuka sebelum hub tampil
-- Pakai: KemplongXD:ShowLoading({ Title = "KemplongXD", Subtitle = "Memuat hub...",
--   Duration = 1.5, OnDone = function() OpenHub() end })
-- ============================================================================
function KemplongXD:ShowLoading(config)
	config = config or {}
	local duration = config.Duration or 1.5
	local old = PlayerGui:FindFirstChild("KemplongXD_Loading")
	if old then old:Destroy() end
	local Gui = New("ScreenGui", { Name = "KemplongXD_Loading", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 3000 }, PlayerGui)
	-- v1.8.0: kartu tidak boleh lebih lebar dari layar (HP kecil 320px).
	local cardW = math.min(320, ViewportSize().X - 32)
	local Card = New("Frame", { Size = UDim2.new(0, cardW, 0, 150), Position = UDim2.new(0.5, -cardW / 2, 0.5, -75), BackgroundColor3 = T().Background, BorderSizePixel = 0, ClipsDescendants = true }, Gui)
	Corner(Card, 14) Stroke(Card)
	PopIn(Card)
	New("TextLabel", { Text = "xD", Font = Enum.Font.GothamBold, TextSize = 28, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 16), Size = UDim2.new(1, 0, 0, 34) }, Card)
	New("TextLabel", { Text = config.Title or "KemplongXD", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 52), Size = UDim2.new(1, 0, 0, 22) }, Card)
	New("TextLabel", { Text = config.Subtitle or ("Script Hub  •  v" .. KemplongXD.Version), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 76), Size = UDim2.new(1, 0, 0, 18) }, Card)
	local barBg = New("Frame", { Size = UDim2.new(1, -48, 0, 8), Position = UDim2.new(0, 24, 0, 112), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, Card)
	Corner(barBg, 99)
	local barFill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, barBg)
	Corner(barFill, 99)
	local done = false
	local function Close()
		if done then return end
		done = true
		Gui:Destroy()
		if typeof(config.OnDone) == "function" then task.spawn(config.OnDone) end
	end
	Tween(barFill, duration, { Size = UDim2.new(1, 0, 1, 0) }, Enum.EasingStyle.Quad)
	task.delay(duration + 0.15, Close)
	return { Gui = Gui, Close = Close }
end

-- ============================================================================
-- SISTEM PLUGIN v1.7.0 — script lain bisa menambah tab/komponen ke hub yang sama.
-- Pakai: KemplongXD:RegisterPlugin("Nama Plugin", function(Window)
--   local tab = Window:CreateTab("Plugin")
--   tab:CreateToggle("Fitur Plugin", false, function(v) end)
-- end)
-- Lalu panggil Window:LoadPlugins() (atau Window:LoadPlugin("Nama Plugin")) setelah
-- semua tab utama dibuat. Plugin yang error tidak merusak hub (pcall + Notify).
-- ============================================================================
KemplongXD.Plugins = KemplongXD.Plugins or {}
function KemplongXD:RegisterPlugin(name, setup)
	if typeof(name) == "table" then
		setup = name.Setup
		name = name.Name
	end
	if not name or name == "" or typeof(setup) ~= "function" then return false end
	self.Plugins[name] = { Name = name, Setup = setup }
	return true
end
function KemplongXD:GetPlugins()
	local out = {}
	for _, pl in pairs(self.Plugins) do table.insert(out, pl) end
	table.sort(out, function(a, b) return a.Name < b.Name end)
	return out
end

-- ============================================================================
-- WINDOW
-- ============================================================================
function KemplongXD:CreateWindow(config)
	config = config or {}
	local title = config.Name or "KemplongXD"
	local subtitle = config.Subtitle or ("Script Hub  •  v" .. KemplongXD.Version)
	local themeName = config.Theme or "Dark"
	if KemplongXD.Themes[themeName] then CurrentTheme = KemplongXD.Themes[themeName] end
	if config.Accent then CurrentTheme = table.clone(CurrentTheme); CurrentTheme.Accent = config.Accent end
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	-- v1.8.1 (S1): semua koneksi window didaftarkan di sini supaya Destroy bisa memutuskannya.
	local conns = {}
	local defaultSize = config.Size or UDim2.new(0, 600, 0, 400)

	local old = PlayerGui:FindFirstChild("KemplongXD")
	if old then old:Destroy() end

	local ScreenGui = New("ScreenGui", { Name = "KemplongXD", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 }, PlayerGui)
	local GuiScale = New("UIScale", { Scale = UIScaleValue() }, ScreenGui)

	-- Bayangan lembut di belakang window
	local Shadow = New("Frame", { Size = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.55, BorderSizePixel = 0 }, ScreenGui)
	Corner(Shadow, 18)

	local Main = New("Frame", { Name = "Main", Size = defaultSize, Position = UDim2.new(0.5, -defaultSize.X.Offset / 2, 0.5, -defaultSize.Y.Offset / 2), BackgroundColor3 = T().Background, BorderSizePixel = 0, ClipsDescendants = true }, ScreenGui)
	Corner(Main, 14) Stroke(Main)

	-- TopBar + gradient aksen
	local TopBar = New("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0 }, Main)
	Corner(TopBar, 14)
	New("Frame", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0 }, TopBar)
	local AccentBar = New("Frame", { Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3), BackgroundTransparency = 1, BorderSizePixel = 0 }, TopBar)
	local AccentGradient = Gradient(AccentBar, T().Accent, T().Accent2, 0)
	-- buat bar terlihat: pakai frame berwarna gradient via UIGradient butuh BackgroundColor3 putih
	AccentBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	AccentBar.BackgroundTransparency = 0

	local Logo = New("TextLabel", { Text = "xD", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(0, 28, 0, 28) }, TopBar)
	local TitleLbl = New("TextLabel", { Text = title, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 42, 0, 7), Size = UDim2.new(0, 280, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, TopBar)
	local SubLbl = New("TextLabel", { Text = subtitle, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 42, 0, 28), Size = UDim2.new(0, 280, 0, 16), TextXAlignment = Enum.TextXAlignment.Left }, TopBar)

	local function TopBtn(text, x, bg)
		local b = New("TextButton", { Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = bg or T().Element, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, x, 0, 11), AutoButtonColor = false }, TopBar)
		Corner(b, 8) AddPress(b) return b
	end
	local MenuBtn = TopBtn("M", -150, T().Element)
	local ThemeBtn = TopBtn("T", -114, T().Element)
	local MinBtn = TopBtn("-", -78, T().Element)
	local CloseBtn = TopBtn("X", -42, T().Red)
	-- di HP, tombol menu penting; di PC sembunyikan menu
	MenuBtn.Visible = IsSmallScreen()

	-- Sidebar (desktop: kiri vertikal | mobile: atas horizontal)
	local Sidebar = New("Frame", { Size = UDim2.new(0, 158, 1, -52), Position = UDim2.new(0, 0, 0, 52), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0 }, Main)
	-- Global Search v1.6.0: cari tab + elemen di semua tab (di HP disembunyikan, pakai SearchBox per tab)
	local SearchFrame = New("Frame", { Size = UDim2.new(1, -16, 0, 32), Position = UDim2.new(0, 8, 0, 6), BackgroundColor3 = T().Element, BorderSizePixel = 0 }, Sidebar)
	Corner(SearchFrame, 8) Stroke(SearchFrame)
	local GlobalSearchBox = New("TextBox", { Text = "", PlaceholderText = "Cari...", PlaceholderColor3 = T().SubText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0), ClearTextOnFocus = false }, SearchFrame)
	local TabList = New("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -46), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, Sidebar)
	local TabLayout = New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, TabList)
	Padding(TabList, 10, 6, 10, 6)

	local Content = New("Frame", { Size = UDim2.new(1, -158, 1, -52), Position = UDim2.new(0, 158, 0, 52), BackgroundTransparency = 1 }, Main)

	table.insert(conns, MakeDraggable(Main, TopBar))
	PopIn(Main)

	-- Floating Action Button (khusus HP — karena tidak ada RightShift)
	local FAB = nil
	if IsMobile then
		FAB = New("TextButton", { Text = "xD", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(1, -72, 1, -72), AutoButtonColor = false, ZIndex = 10 }, ScreenGui)
		Corner(FAB, 99) Stroke(FAB, Color3.fromRGB(255,255,255), 1)
		table.insert(conns, MakeDraggable(FAB, FAB))
	end

	local Window = { ScreenGui = ScreenGui, Main = Main, Tabs = {}, _minimized = false, _registry = {}, _refreshers = {}, _selectedTab = nil, _currentTheme = themeName, Flags = {}, AutoSave = false, AutoSaveName = "Default", _autoSavePending = false, _userScale = config.Scale or 1, _keybinds = {}, _transparency = 0, _conns = conns, _destroyed = false }
	-- Registry tema: {obj, role} role: bg|sidebar|element|accent|text|subtext|stroke
	local function TrackConn(c) table.insert(conns, c) return c end
	function Window:_track(obj, role) table.insert(self._registry, { Obj = obj, Role = role }) end
	function Window:_addRefresher(fn) table.insert(self._refreshers, fn) end
	Window:_track(Main, "bg") Window:_track(TopBar, "sidebar") Window:_track(Sidebar, "sidebar")

	function Window:RegisterFlag(name, getFn, setFn)
		if not name or name == "" then return end
		self.Flags[name] = { Get = getFn, Set = setFn }
	end
	function Window:GetFlag(name)
		local f = self.Flags[name]
		return f and f.Get and f.Get() or nil
	end
	function Window:SetFlag(name, value)
		local f = self.Flags[name]
		if f and f.Set then task.spawn(function() pcall(f.Set, value) end) end
	end
	function Window:_maybeAutoSave()
		if not self.AutoSave or self._autoSavePending then return end
		self._autoSavePending = true
		task.delay(0.6, function()
			self._autoSavePending = false
			if self.AutoSave then self:SaveConfig(self.AutoSaveName, true) end
		end)
	end
	function Window:SetAutoSave(enabled, name)
		self.AutoSave = enabled == true
		if name and name ~= "" then self.AutoSaveName = name end
		if self.AutoSave then self:SaveConfig(self.AutoSaveName, true) end
	end
	function Window:ListConfigs() return KemplongXD:ListConfigFiles() end
	function Window:DeleteConfig(name)
		KemplongXD:DeleteConfigFile(name or "Default")
		KemplongXD:Notify("Config dihapus", "Config '" .. (name or "Default") .. "' dihapus.", 2, "Info")
	end
	function Window:SetTheme(name, keepAccent, silent)
		local th = KemplongXD.Themes[name]
		if not th then if not silent then KemplongXD:Notify("Tema tidak ditemukan", name, 2, "Error") end return end
		if not keepAccent then CustomAccent = nil CustomAccent2 = nil end
		CurrentTheme = table.clone(th)
		if CustomAccent then CurrentTheme.Accent = CustomAccent end
		if CustomAccent2 then CurrentTheme.Accent2 = CustomAccent2 end
		th = CurrentTheme
		self._currentTheme = name
		RefreshHoverPairs(th)
		for _, e in ipairs(self._registry) do
			local o = e.Obj
			if o and o.Parent then
				if e.Role == "bg" then o.BackgroundColor3 = th.Background
				elseif e.Role == "sidebar" then o.BackgroundColor3 = th.Sidebar
				elseif e.Role == "element" then o.BackgroundColor3 = th.Element
				elseif e.Role == "accent" then o.BackgroundColor3 = th.Accent
				elseif e.Role == "text" then o.TextColor3 = th.Text
				elseif e.Role == "subtext" then o.TextColor3 = th.SubText
				elseif e.Role == "stroke" then o.Color = th.Stroke end
			end
		end
		-- update warna khusus (bug v1.3.0: judul/subjudul/tombol atas/gradient aksen tidak ikut berubah)
		Logo.TextColor3 = th.Accent
		if TitleLbl then TitleLbl.TextColor3 = th.Text end
		if SubLbl then SubLbl.TextColor3 = th.SubText end
		if MenuBtn then MenuBtn.BackgroundColor3 = th.Element end
		if ThemeBtn then ThemeBtn.BackgroundColor3 = th.Element end
		if MinBtn then MinBtn.BackgroundColor3 = th.Element end
		if CloseBtn then CloseBtn.BackgroundColor3 = th.Red end
		if AccentGradient then AccentGradient.Color = ColorSequence.new(th.Accent, th.Accent2) end
		if FAB then FAB.BackgroundColor3 = th.Accent end
		-- tab terpilih kembali ke Accent (registry sempat mengembalikan semua ke Element)
		for _, t in ipairs(self.Tabs) do
			if t.Page.Visible then
				t.Button.BackgroundColor3 = th.Accent
				t.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				t.Button.BackgroundColor3 = th.Element
				t.Button.TextColor3 = th.SubText
			end
		end
		for _, fn in ipairs(self._refreshers) do pcall(fn) end
		if not silent then KemplongXD:Notify("Tema diganti", "Tema " .. name .. " aktif.", 2, "Success") end
	end
	function Window:GetTheme() return self._currentTheme end
	function Window:SetAnimations(enabled)
		KemplongXD.Animations = enabled
	end
	-- v1.5.0: skala UI (0.8 kecil, 1 normal, 1.2 besar). Dikalikan dengan skala responsif.
	function Window:SetScale(scale)
		scale = math.clamp(tonumber(scale) or 1, 0.5, 2)
		self._userScale = scale
		GuiScale.Scale = UIScaleValue() * scale
	end
	function Window:GetScale() return self._userScale or 1 end
	-- v1.5.0: ganti tombol buka/tutup UI saat hub sudah jalan (PC).
	function Window:SetToggleKey(key)
		-- v1.8.2 (K8): harus EnumItem KeyCode — Enum.UserInputType tidak akan pernah cocok
		-- dengan perbandingan KeyCode di InputBegan, jadi ditolak di sini.
		if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then toggleKey = key return true end
		return false
	end
	function Window:GetToggleKey() return toggleKey end
	-- v1.7.0: transparansi UI (0 opaque, 0.5 tembus pandang). Hanya Main/TopBar/Sidebar.
	function Window:SetTransparency(alpha)
		alpha = math.clamp(tonumber(alpha) or 0, 0, 0.5)
		self._transparency = alpha
		Main.BackgroundTransparency = alpha
		TopBar.BackgroundTransparency = alpha
		Sidebar.BackgroundTransparency = alpha
	end
	function Window:GetTransparency() return self._transparency or 0 end
	-- v1.7.0: muat plugin terdaftar (lihat KemplongXD:RegisterPlugin).
	function Window:LoadPlugin(name)
		local pl = KemplongXD.Plugins[name]
		if not pl then return false end
		local ok, err = pcall(pl.Setup, self)
		if not ok then KemplongXD:Notify("Plugin Error", tostring(name) .. ": " .. tostring(err), 3, "Error") end
		return ok
	end
	function Window:LoadPlugins()
		local count = 0
		for _, pl in ipairs(KemplongXD:GetPlugins()) do
			if self:LoadPlugin(pl.Name) then count += 1 end
		end
		return count
	end
	-- v1.6.0: ukuran window (dipakai Resize handle + SetSize, dipertahankan saat rotasi)
	function Window:SetSize(size)
		if typeof(size) ~= "UDim2" then return false end
		local vp = ViewportSize()
		local w = math.clamp(size.X.Offset, 420, math.max(420, vp.X - 20))
		local h = math.clamp(size.Y.Offset, 300, math.max(300, vp.Y - 20))
		self._customSize = UDim2.new(0, w, 0, h)
		Main.Size = self._customSize
		if not Main:GetAttribute("Dragged") then Main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2) end
		return true
	end
	function Window:GetSize() return Main.Size end
	if config.Transparency then Window:SetTransparency(config.Transparency) end
	-- v1.6.0: cari dari luar (misal Window:Search("farm"))
	function Window:Search(query)
		GlobalSearchBox.Text = query or ""
	end
	-- v1.6.0: Settings Tab otomatis (tema + config + skala + toggle key + animasi).
	-- Kalau tab "Settings" sudah ada, dipakai ulang supaya tidak duplikat.
	function Window:CreateSettingsTab()
		if self._settingsTab then return self._settingsTab end
		local existing = nil
		for _, t in ipairs(self.Tabs) do if t.Name == "Settings" then existing = t break end end
		local tab = existing or self:CreateTab("Settings")
		self._settingsTab = tab
		tab:CreateThemePicker()
		tab:CreateSection("Config — Tersimpan ke File")
		tab:CreateConfigManager()
		tab:CreateSection("Performa dan Animasi")
		-- v1.8.2 (K9): flag "AnimasiSmooth" supaya statusnya tersimpan di config seperti
		-- Skala/Transparansi; nilai awal mengikuti KemplongXD.Animations, bukan selalu true.
		tab:CreateToggleDesc("Animasi Smooth", "Matikan jika perangkat terasa berat.", KemplongXD.Animations, function(v)
			self:SetAnimations(v)
			KemplongXD:Notify("Animasi", v and "Animasi AKTIF" or "Animasi MATI (mode hemat)", 2, "Info")
		end, "AnimasiSmooth")
		tab:CreateSection("UI")
		tab:CreatePreciseSlider("Skala UI", 0.8, 1.2, 1, self:GetScale(), function(v) self:SetScale(v) end, "SkalaUI")
		tab:CreatePreciseSlider("Transparansi UI", 0, 0.4, 2, self:GetTransparency(), function(v) self:SetTransparency(v) end, "TransparansiUI")
		tab:CreateKeybind("Tombol Buka/Tutup UI", self:GetToggleKey(), function(k) self:SetToggleKey(k) end, "ToggleUIKey")
		tab:CreateButton("Reset Accent ke Default Tema", function()
			KemplongXD:ResetAccent()
			self:SetTheme(self:GetTheme())
		end, "Secondary")
		tab:CreateButton("Tutup Hub", function() self:Destroy() end, "Danger")
		return tab
	end
	function Window:SaveConfig(name, silent)
		name = name or "Default"
		local flags = {}
		for flagName, f in pairs(self.Flags) do
			local ok, val = pcall(f.Get)
			if ok and val ~= nil then flags[flagName] = EncodeFlagValue(val) end
		end
		local data = { Theme = self._currentTheme, Accent = CurrentTheme.Accent:ToHex(), Flags = flags, AutoSave = self.AutoSave, SavedAt = os.time(), Version = KemplongXD.Version }
		local toFile = KemplongXD:SaveConfigFile(name, data)
		if not silent then
			KemplongXD:Notify("Config disimpan", "Config '" .. name .. "' tersimpan" .. (toFile and " ke file." or " ke memori (file tidak didukung)."), 2, "Success")
		end
		return data
	end
	function Window:LoadConfig(name, silent)
		name = name or "Default"
		local cfg = KemplongXD:LoadConfigFile(name)
		if not cfg then
			if not silent then KemplongXD:Notify("Config tidak ada", "Config '" .. name .. "' belum disimpan.", 2, "Error") end
			return false
		end
		if cfg.Theme and KemplongXD.Themes[cfg.Theme] then Window:SetTheme(cfg.Theme, true, true) end
		if cfg.Accent and typeof(cfg.Accent) == "string" then
			local ok, col = pcall(Color3.fromHex, cfg.Accent)
			if ok then KemplongXD:SetAccent(col) Window:SetTheme(self._currentTheme, true, true) end
		end
		if cfg.AutoSave ~= nil then self.AutoSave = cfg.AutoSave == true end
		if cfg.Flags then
			for flagName, raw in pairs(cfg.Flags) do
				local f = self.Flags[flagName]
				if f and f.Set then
					local val = DecodeFlagValue(raw)
					if typeof(val) == "table" and val[1] ~= nil and f.SetRange then
						pcall(f.SetRange, val[1], val[2])
					else
						pcall(f.Set, val)
					end
				end
			end
		end
		if not silent then KemplongXD:Notify("Config dimuat", "Config '" .. name .. "' dimuat.", 2, "Success") end
		return true
	end
	function Window:SetAccent(color, silent)
		KemplongXD:SetAccent(color)
		Window:SetTheme(self._currentTheme, true, silent)
	end
	function Window:ToggleUI()
		Main.Visible = not Main.Visible
		Shadow.Visible = Main.Visible
		if FAB then FAB.Visible = true end
		if Main.Visible then PopIn(Main) end
	end
	function Window:Destroy()
		if self._destroyed then return end
		self._destroyed = true
		if self.AutoSave then pcall(function() self:SaveConfig(self.AutoSaveName, true) end) end
		-- v1.8.1 (S1): putuskan SEMUA koneksi window (viewport, toggle key, drag komponen,
		-- RenderStepped, dll.) supaya window yang sudah dihancurkan tidak terus berjalan.
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		table.clear(conns)
		-- Bersihkan HoverPairs milik window ini (tombol yang sudah dihancurkan).
		for i = #HoverPairs, 1, -1 do
			local e = HoverPairs[i]
			if not e.Btn or not e.Btn.Parent or not e.Btn:IsDescendantOf(ScreenGui) then table.remove(HoverPairs, i) end
		end
		table.clear(self._registry)
		table.clear(self._refreshers)
		table.clear(self.Flags)
		table.clear(self._keybinds)
		ScreenGui:Destroy()
		if NotifyGui then NotifyGui:Destroy() NotifyGui = nil end
		table.clear(NotifyList)
	end

	-- Responsif: ubah layout saat layar kecil / rotasi HP
	local function ApplyResponsive()
		if Window._destroyed then return end
		GuiScale.Scale = UIScaleValue() * (Window._userScale or 1)
		local small = IsSmallScreen()
		local vp = ViewportSize()
		MenuBtn.Visible = small
		SearchFrame.Visible = not small
		if Window._resizeHandle then Window._resizeHandle.Visible = not small end
		-- v1.8.0: TopBar responsif — judul mengecil dan subtitle disembunyikan di layar
		-- sempit, supaya tidak tertumpuk tombol Menu/Tema/Min/Close.
		if small then
			TitleLbl.Size = UDim2.new(1, -200, 0, 22)
			SubLbl.Visible = false
		else
			TitleLbl.Size = UDim2.new(0, 280, 0, 22)
			SubLbl.Visible = true
		end
		-- v1.8.0: lebar window menurut mode, tapi kalau sedang minimize tingginya tetap 52
		-- supaya rotasi layar tidak membuka sendiri window yang diminimize.
		local w, h
		if small then
			w = math.min(vp.X * 0.96, 620)
			h = math.min(vp.Y * 0.82, 560)
		else
			local ds = Window._customSize or defaultSize
			w, h = ds.X.Offset, ds.Y.Offset
		end
		if Window._minimized then
			Main.Size = UDim2.new(0, w, 0, 52)
		else
			Main.Size = UDim2.new(0, w, 0, h)
		end
		if small then
			TabList.Size = UDim2.new(1, 0, 1, 0)
			TabList.Position = UDim2.new(0, 0, 0, 0)
			-- HP: window hampir fullscreen, tab jadi bar horizontal di atas
			if not Main:GetAttribute("Dragged") then Main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2) end
			Sidebar.Size = UDim2.new(1, 0, 0, 48)
			Sidebar.Position = UDim2.new(0, 0, 0, 52)
			TabList.AutomaticCanvasSize = Enum.AutomaticSize.X
			TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
			TabLayout.FillDirection = Enum.FillDirection.Horizontal
			TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			Content.Size = UDim2.new(1, 0, 1, -100)
			Content.Position = UDim2.new(0, 0, 0, 100)
			for _, t in ipairs(Window.Tabs) do t.Button.Size = UDim2.new(0, 110, 0, 34) end
		else
			TabList.Size = UDim2.new(1, 0, 1, -46)
			TabList.Position = UDim2.new(0, 0, 0, 40)
			if not Main:GetAttribute("Dragged") then Main.Position = UDim2.new(0.5, -Main.Size.X.Offset / 2, 0.5, -Main.Size.Y.Offset / 2) end
			Sidebar.Size = UDim2.new(0, 158, 1, -52)
			Sidebar.Position = UDim2.new(0, 0, 0, 52)
			TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
			TabLayout.FillDirection = Enum.FillDirection.Vertical
			Content.Size = UDim2.new(1, -158, 1, -52)
			Content.Position = UDim2.new(0, 158, 0, 52)
			for _, t in ipairs(Window.Tabs) do t.Button.Size = UDim2.new(1, 0, 0, 38) end
		end
		-- v1.8.0: clamp posisi window ke dalam viewport — setelah drag lalu rotasi
		-- (layar mengecil), window tidak boleh hilang ke luar layar. Sisakan min 80px
		-- lebar dan TopBar 52px supaya selalu bisa diseret kembali.
		local pos = Main.Position
		local absX = pos.X.Scale * vp.X + pos.X.Offset
		local absY = pos.Y.Scale * vp.Y + pos.Y.Offset
		absX = math.clamp(absX, -(Main.Size.X.Offset - 80), math.max(0, vp.X - 80))
		absY = math.clamp(absY, 0, math.max(0, vp.Y - 52))
		Main.Position = UDim2.new(pos.X.Scale, absX - pos.X.Scale * vp.X, pos.Y.Scale, absY - pos.Y.Scale * vp.Y)
		Shadow.Size = Main.Size
		Shadow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + 4, Main.Position.Y.Scale, Main.Position.Y.Offset + 6)
	end
	-- v1.8.0: paksa layout ulang dari luar, misal setelah rotasi manual: Window:RefreshResponsive()
	Window.RefreshResponsive = ApplyResponsive
	-- update shadow mengikuti Main
	Main:GetPropertyChangedSignal("Position"):Connect(function()
		Shadow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + 4, Main.Position.Y.Scale, Main.Position.Y.Offset + 6)
	end)
	Main:GetPropertyChangedSignal("Size"):Connect(function() Shadow.Size = Main.Size end)
	if Camera then
		table.insert(conns, Camera:GetPropertyChangedSignal("ViewportSize"):Connect(ApplyResponsive))
	end
	table.insert(conns, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local cam = workspace.CurrentCamera
		if cam then table.insert(conns, cam:GetPropertyChangedSignal("ViewportSize"):Connect(ApplyResponsive)) end
		ApplyResponsive()
	end))
	task.spawn(function() task.wait(0.1) ApplyResponsive() end)

	CloseBtn.MouseButton1Click:Connect(function() Window:Destroy() end)
	MinBtn.MouseButton1Click:Connect(function()
		Window._minimized = not Window._minimized
		if Window._minimized then
			Tween(Main, 0.25, { Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, 52) })
			Sidebar.Visible = false Content.Visible = false MinBtn.Text = "+"
		else
			ApplyResponsive()
			Sidebar.Visible = true Content.Visible = true MinBtn.Text = "-"
		end
	end)
	ThemeBtn.MouseButton1Click:Connect(function()
		local order = KemplongXD:GetThemes()
		local idx = table.find(order, Window._currentTheme) or 1
		Window:SetTheme(order[idx % #order + 1])
	end)
	MenuBtn.MouseButton1Click:Connect(function()
		Sidebar.Visible = not Sidebar.Visible
		if Sidebar.Visible and IsSmallScreen() then
			Content.Position = UDim2.new(0, 0, 0, 100)
			Content.Size = UDim2.new(1, 0, 1, -100)
		else
			if IsSmallScreen() then
				Content.Position = UDim2.new(0, 0, 0, 52)
				Content.Size = UDim2.new(1, 0, 1, -52)
			end
		end
	end)
	if FAB then
		-- Guard drag-vs-klik: bandingkan posisi FAB saat ditekan vs saat dilepas.
		-- Kalau bergeser > 10px berarti user sedang menggeser FAB, bukan mengetuknya.
		local fabStartPos = nil
		FAB.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				fabStartPos = FAB.Position
			end
		end)
		FAB.MouseButton1Click:Connect(function()
			local moved = false
			if fabStartPos then
				local dx = FAB.Position.X.Offset - fabStartPos.X.Offset
				local dy = FAB.Position.Y.Offset - fabStartPos.Y.Offset
				moved = (dx * dx + dy * dy) > 100
			end
			fabStartPos = nil
			if not moved then Window:ToggleUI() end
		end)
	end
	TrackConn(UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == toggleKey then Window:ToggleUI() end
	end))

	-- ================================================================
	-- TAB
	-- ================================================================
	function Window:CreateTab(tabName, tabIcon)
		local Page = New("ScrollingFrame", { Name = tabName, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = T().Stroke, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false }, Content)
		New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, Page)
		Padding(Page, 14, 12, 14, 12)

		-- v1.7.0: ikon tab otomatis — huruf pertama nama tab kalau tidak diberi ikon.
		-- Beri "" (string kosong) kalau memang tidak mau ada ikon.
		local iconText = tabIcon
		if iconText == nil then iconText = string.sub(tabName, 1, 1) end
		local tabLabel = (iconText ~= "" and iconText .. "  " or "") .. tabName
		local TabBtn = New("TextButton", { Text = tabLabel, Font = Enum.Font.GothamBold, TextSize = IsSmallScreen() and 12 or 13, TextColor3 = T().SubText, BackgroundColor3 = T().Element, Size = IsSmallScreen() and UDim2.new(0, 110, 0, 34) or UDim2.new(1, 0, 0, 38), AutoButtonColor = false }, TabList)
		Corner(TabBtn, 9)
		Window:_track(TabBtn, "element")

		local function Select()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, 0.15, { BackgroundColor3 = T().Element })
				t.Button.TextColor3 = T().SubText
			end
			Page.Visible = true
			-- Animasi pindah tab: geser halus dari kanan
			Page.Position = UDim2.new(0, 14, 0, 0)
			Tween(Page, 0.25, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quad)
			Tween(TabBtn, 0.15, { BackgroundColor3 = T().Accent })
			TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		TabBtn.MouseButton1Click:Connect(Select)
		AddHover(TabBtn, T().Element, T().ElementHover)

		local Tab = { Name = tabName, Page = Page, Button = TabBtn, Select = Select }
		table.insert(Window.Tabs, Tab)
		if #Window.Tabs == 1 then Select() end

		local function H() return IsSmallScreen() and 50 or 46 end -- tinggi elemen responsif
		local function ElementFrame(height)
			local f = New("Frame", { Size = UDim2.new(1, 0, 0, height or H()), BackgroundColor3 = T().Element, BorderSizePixel = 0 }, Page)
			Corner(f, 11) Stroke(f) Window:_track(f, "element")
			pcall(function() f:SetAttribute("Searchable", true) end)
			return f
		end
		local function TitleLabel(parent, text, pos, size)
			local l = New("TextLabel", { Text = text, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T().Text, BackgroundTransparency = 1, Position = pos or UDim2.new(0, 12, 0, 0), Size = size or UDim2.new(1, -70, 1, 0), TextXAlignment = Enum.TextXAlignment.Left }, parent)
			-- v1.8.2 (K15): simpan judul di atribut SearchTitle supaya Global Search / SearchBox
			-- tidak bergantung pada urutan child TextLabel di dalam frame.
			pcall(function() parent:SetAttribute("SearchTitle", text or "") end)
			Window:_track(l, "text") return l
		end
		-- v1.3.1: refresher tema — tiap kontrol mendaftarkan cara mewarnai ulang dirinya
		-- dari state saat ini, supaya SetTheme benar-benar mengubah semua kontrol.
		local function AddRefresher(fn) Window:_addRefresher(fn) end
		-- v1.3.0: daftarkan elemen ke Flag registry supaya bisa disimpan / dimuat config file.
		local function BindFlag(name, getFn, setFn, setRangeFn)
			if name and name ~= "" then
				Window:RegisterFlag(name, getFn, setFn)
				if setRangeFn then Window.Flags[name].SetRange = setRangeFn end
			end
		end

		-- -- -- Dasar -- -- --
		function Tab:CreateSection(text)
			local l = New("TextLabel", { Text = string.upper(text or "SECTION"), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, Page)
			Window:_track(l, "subtext") return l
		end
		function Tab:CreateDivider()
			return New("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, Page)
		end
		function Tab:CreateLabel(text)
			local l = New("TextLabel", { Text = text or "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, Page)
			Window:_track(l, "text") return l
		end
		function Tab:CreateParagraph(title, text)
			local f = ElementFrame(68)
			TitleLabel(f, title or "", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local d = New("TextLabel", { Text = text or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 32), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true }, f)
			Window:_track(d, "subtext") return f
		end
		function Tab:CreateImage(assetId, height)
			local img = New("ImageLabel", { Image = assetId or "", BackgroundColor3 = T().Element, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height or 120), ScaleType = Enum.ScaleType.Crop }, Page)
			Corner(img, 11) Stroke(img) Shimmer(img) return img
		end
		function Tab:CreateSearchBox(placeholder, callback)
			local f = ElementFrame(44)
			local box = New("TextBox", { Text = "", PlaceholderText = "" .. (placeholder or "Cari..."), PlaceholderColor3 = T().SubText, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0.5, -15), ClearTextOnFocus = false }, f)
			Corner(box, 8) Padding(box, 10, 0, 10, 0)
			box:GetPropertyChangedSignal("Text"):Connect(function()
				if callback then task.spawn(callback, box.Text) return end
				-- Tanpa callback: filter elemen di tab ini berdasarkan judulnya (v1.3.0, diperbaiki v1.3.1:
				-- hanya elemen Searchable yang difilter, dropdown list / accordion yang semula
				-- tersembunyi tidak ikut dimunculkan)
				local q = string.lower(box.Text)
				for _, child in ipairs(Page:GetChildren()) do
					if child ~= f and child:GetAttribute("Searchable") then
						local hay = string.lower(child:GetAttribute("SearchTitle") or "")
						if hay == "" then
							local title = child:FindFirstChildOfClass("TextLabel")
							hay = title and string.lower(title.Text) or ""
						end
						if hay == "" then
							local tb = child:FindFirstChildOfClass("TextBox")
							if tb then hay = string.lower(tb.PlaceholderText or "") end
						end
						child.Visible = q == "" or string.find(hay, q, 1, true) ~= nil
					end
				end
			end)
			return box
		end

		-- -- -- Button (4 varian + ripple + press) -- -- --
		function Tab:CreateButton(text, callback, style)
			style = style or "Primary"
			local bg = style == "Danger" and T().Red or style == "Secondary" and T().Element or style == "Ghost" and T().Background or T().Accent
			local tc = style == "Secondary" and T().Text or Color3.fromRGB(255, 255, 255)
			local btn = New("TextButton", { Text = text or "Button", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = tc, BackgroundColor3 = bg, Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, ClipsDescendants = true }, Page)
			Corner(btn, 10) if style ~= "Primary" and style ~= "Danger" then Stroke(btn) end
			Window:_track(btn, style == "Primary" and "accent" or "element")
			AddPress(btn) Ripple(btn)
			if style == "Primary" then AddHover(btn, T().Accent, T().Accent2) end
			btn.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
			return btn
		end

		-- -- -- Toggle -- -- --
		function Tab:CreateToggle(text, default, callback, flag)
			local state = default or false
			local f = ElementFrame()
			TitleLabel(f, text or "Toggle")
			local track = New("Frame", { Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(1, -62, 0.5, -13), BackgroundColor3 = state and T().Accent or T().Stroke, BorderSizePixel = 0 }, f)
			Corner(track, 99)
			local knob = New("Frame", { Size = UDim2.new(0, 20, 0, 20), Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, track)
			Corner(knob, 99)
			local btn = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)
			local Toggle = {}
			function Toggle:Set(v)
				state = v
				Tween(track, 0.2, { BackgroundColor3 = state and T().Accent or T().Stroke }, Enum.EasingStyle.Quad)
				Tween(knob, 0.22, { Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10) }, Enum.EasingStyle.Quad)
				if callback then task.spawn(callback, state) end
				Window:_maybeAutoSave()
			end
			function Toggle:Get() return state end
			AddRefresher(function() if track.Parent then track.BackgroundColor3 = state and T().Accent or T().Stroke end end)
			BindFlag(flag, Toggle.Get, Toggle.Set)
			btn.MouseButton1Click:Connect(function() Toggle:Set(not state) end)
			return Toggle
		end

		-- -- -- Checkbox -- -- --
		function Tab:CreateCheckbox(text, default, callback, flag)
			local state = default or false
			local f = ElementFrame()
			TitleLabel(f, text or "Checkbox")
			local box = New("Frame", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -36, 0.5, -12), BackgroundColor3 = state and T().Accent or T().Sidebar, BorderSizePixel = 0 }, f)
			Corner(box, 7) Stroke(box)
			local check = New("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0.5, -6, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Visible = state }, box)
			Corner(check, 3)
			local btn = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)
			local Cb = {}
			function Cb:Set(v)
				state = v
				check.Visible = v
				Tween(box, 0.15, { BackgroundColor3 = v and T().Accent or T().Sidebar }, Enum.EasingStyle.Quad)
				if callback then task.spawn(callback, v) end
				Window:_maybeAutoSave()
			end
			function Cb:Get() return state end
			AddRefresher(function() if box.Parent then box.BackgroundColor3 = state and T().Accent or T().Sidebar end end)
			BindFlag(flag, Cb.Get, Cb.Set)
			btn.MouseButton1Click:Connect(function() Cb:Set(not state) end)
			return Cb
		end

		-- -- -- Radio Group -- -- --
		function Tab:CreateRadio(text, options, default, callback, flag)
			options = options or {}
			local selected = default or options[1]
			local f = ElementFrame(44 + #options * 34)
			TitleLabel(f, text or "Pilih satu", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 20))
			local Radio = {}
			local buttons = {}
			local function Refresh()
				for opt, b in pairs(buttons) do
					b.Dot.Visible = (opt == selected)
					Tween(b.Outer, 0.15, { BackgroundColor3 = opt == selected and T().Accent or T().Sidebar })
				end
			end
			for i, opt in ipairs(options) do
				local row = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 30), Position = UDim2.new(0, 8, 0, 28 + (i - 1) * 32) }, f)
				local outer = New("Frame", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 4, 0.5, -10), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0 }, row)
				Corner(outer, 99) Stroke(outer)
				local dot = New("Frame", { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, Visible = opt == selected }, outer)
				Corner(dot, 99)
				New("TextLabel", { Text = opt, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -32, 1, 0), TextXAlignment = Enum.TextXAlignment.Left }, row)
				buttons[opt] = { Outer = outer, Dot = dot }
				row.MouseButton1Click:Connect(function()
					selected = opt
					Refresh()
					if callback then task.spawn(callback, opt) end
				end)
			end
			function Radio:Set(v)
				selected = v
				Refresh()
				if callback then task.spawn(callback, v) end
				Window:_maybeAutoSave()
			end
			function Radio:Get() return selected end
			AddRefresher(function() Refresh() end)
			BindFlag(flag, Radio.Get, Radio.Set)
			Refresh()
			return Radio
		end

		-- -- -- Slider -- -- --
		function Tab:CreateSlider(text, min, max, default, callback, flag)
			min = min or 0; max = max or 100; default = default or min
			local value = default
			local f = ElementFrame(60)
			TitleLabel(f, text or "Slider", UDim2.new(0, 12, 0, 7), UDim2.new(1, -70, 0, 18))
			local valLbl = New("TextLabel", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(1, -62, 0, 7), Size = UDim2.new(0, 50, 0, 18), TextXAlignment = Enum.TextXAlignment.Right }, f)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 38), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new((max > min) and (value - min) / (max - min) or 0, 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Corner(fill, 99)
			local knob = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((max > min) and (value - min) / (max - min) or 0, -9, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, ZIndex = 2 }, bar)
			Corner(knob, 99) Stroke(knob, T().Accent, 2)
			local Slider = {}
			local lastCb = 0
			local function SetFromPos(x, force)
				if max <= min then return end
				local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * pct + 0.5)
				valLbl.Text = tostring(value)
				fill.Size = UDim2.new(pct, 0, 1, 0)
				knob.Position = UDim2.new(pct, -9, 0.5, -9)
				local now = os.clock()
				if force or (now - lastCb > 0.08) then
					lastCb = now
					if callback then task.spawn(callback, value) end
				end
			end
			function Slider:Set(v)
				value = SafeClamp(v, min, max)
				valLbl.Text = tostring(value)
				local pct = (max > min) and (value - min) / (max - min) or 0
				fill.Size = UDim2.new(pct, 0, 1, 0)
				knob.Position = UDim2.new(pct, -9, 0.5, -9)
				if callback then task.spawn(callback, value) end
				Window:_maybeAutoSave()
			end
			function Slider:Get() return value end
			AddRefresher(function()
				if not fill.Parent then return end
				fill.BackgroundColor3 = T().Accent
				bar.BackgroundColor3 = T().Stroke
				valLbl.TextColor3 = T().Accent
				pcall(function() Stroke(knob, T().Accent, 2) end)
			end)
			BindFlag(flag, Slider.Get, Slider.Set)
			local dragging = false
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					SetFromPos(input.Position.X)
				end
			end)
			TrackConn(UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then SetFromPos(input.Position.X) end end))
			TrackConn(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if dragging and callback then task.spawn(callback, value) end
					dragging = false
				end
			end))
			return Slider
		end

		-- -- -- Dropdown (single) -- -- --
		function Tab:CreateDropdown(text, options, default, callback, flag)
			options = options or {}
			local selected = default or options[1] or "None"
			local f = ElementFrame()
			TitleLabel(f, text or "Dropdown", UDim2.new(0, 12, 0, 0), UDim2.new(0.45, 0, 1, 0))
			local btn = New("TextButton", { Text = selected .. "  v", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -162, 0.5, -15), AutoButtonColor = false, ClipsDescendants = true }, f)
			Corner(btn, 8) AddPress(btn) Ripple(btn)
			local list = New("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = T().Element, BorderSizePixel = 0, Visible = false, ClipsDescendants = true }, Page)
			Corner(list, 10) Stroke(list) Window:_track(list, "element")
			New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)
			Padding(list, 6, 6, 6, 6)
			local open = false
			local Dropdown = {}
			local function RefreshList()
				for _, c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
				for _, opt in ipairs(options) do
					local ob = New("TextButton", { Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, 0, 0, 32), AutoButtonColor = false }, list)
					Corner(ob, 8) AddHover(ob, T().Sidebar, T().ElementHover)
					ob.MouseButton1Click:Connect(function() Dropdown:Set(opt) open = false list.Visible = false end)
				end
			end
			function Dropdown:Set(v) selected = v btn.Text = v .. "  v" if callback then task.spawn(callback, v) end Window:_maybeAutoSave() end
			function Dropdown:Get() return selected end
			AddRefresher(function() if btn.Parent then btn.BackgroundColor3 = T().Accent end end)
			BindFlag(flag, Dropdown.Get, Dropdown.Set)
			function Dropdown:SetOptions(o) options = o if not table.find(options, selected) then selected = options[1] or "None" btn.Text = selected .. "  v" end RefreshList() end
			btn.MouseButton1Click:Connect(function()
				open = not open
				if open then RefreshList() list.Visible = true Tween(list, 0.25, { Size = UDim2.new(1, 0, 0, #options * 36 + 8) }, Enum.EasingStyle.Quad) btn.Text = selected .. "  ^"
				else Tween(list, 0.18, { Size = UDim2.new(1, 0, 0, 0) }) task.delay(0.18, function() if not open then list.Visible = false end end) btn.Text = selected .. "  v" end
			end)
			RefreshList() return Dropdown
		end

		-- -- -- Multi Dropdown -- -- --
		function Tab:CreateMultiDropdown(text, options, defaults, callback, flag)
			options = options or {}
			local chosen = {}
			for _, d in ipairs(defaults or {}) do chosen[d] = true end
			local f = ElementFrame()
			TitleLabel(f, text or "Pilih banyak", UDim2.new(0, 12, 0, 0), UDim2.new(0.45, 0, 1, 0))
			local btn = New("TextButton", { Text = "Pilih...  v", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -162, 0.5, -15) }, f)
			Corner(btn, 8)
			local list = New("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = T().Element, BorderSizePixel = 0, Visible = false, ClipsDescendants = true }, Page)
			Corner(list, 10) Stroke(list)
			New("UIListLayout", { Padding = UDim.new(0, 4) }, list) Padding(list, 6, 6, 6, 6)
			local function UpdateText()
				local n = 0 for _ in pairs(chosen) do n += 1 end
				btn.Text = n == 0 and "Pilih...  v" or n .. " dipilih  v"
			end
			local open = false
			for _, opt in ipairs(options) do
				local ob = New("TextButton", { Text = (chosen[opt] and "[x]  " or "[ ]  ") .. opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, 0, 0, 32) }, list)
				Corner(ob, 8)
				ob.MouseButton1Click:Connect(function()
					chosen[opt] = not chosen[opt]
					ob.Text = (chosen[opt] and "[x]  " or "[ ]  ") .. opt
					UpdateText()
					if callback then local out = {} for k in pairs(chosen) do table.insert(out, k) end task.spawn(callback, out) end
				end)
			end
			UpdateText()
			btn.MouseButton1Click:Connect(function()
				open = not open list.Visible = open
				Tween(list, 0.25, { Size = open and UDim2.new(1, 0, 0, #options * 36 + 8) or UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quad)
			end)
			local Md = {}
			function Md:Get() local out = {} for k in pairs(chosen) do table.insert(out, k) end return out end
			function Md:Set(list2)
				chosen = {}
				for _, d in ipairs(list2 or {}) do chosen[d] = true end
				UpdateText()
				if callback then task.spawn(callback, Md:Get()) end
				Window:_maybeAutoSave()
			end
			AddRefresher(function() if btn.Parent then btn.BackgroundColor3 = T().Accent end end)
			BindFlag(flag, Md.Get, Md.Set)
			return Md
		end

		-- -- -- Input / TextBox (teks & angka + validasi) -- -- --
		function Tab:CreateInput(text, placeholder, default, callback, numberOnly, flag)
			local f = ElementFrame()
			TitleLabel(f, text or "Input", UDim2.new(0, 12, 0, 0), UDim2.new(0.4, 0, 1, 0))
			local lastValid = default or ""
			local box = New("TextBox", { Text = default or "", PlaceholderText = placeholder or "Ketik di sini...", PlaceholderColor3 = T().SubText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 190, 0, 30), Position = UDim2.new(1, -202, 0.5, -15), ClearTextOnFocus = false }, f)
			Corner(box, 8) Stroke(box) Padding(box, 10, 0, 10, 0)
			box.FocusLost:Connect(function(enter)
				if not enter then return end
				local v = box.Text
				if numberOnly then
					local n = tonumber(v)
					if not n then
						KemplongXD:Notify("Input salah", "Harus angka!", 2, "Error")
						box.Text = tostring(lastValid)
						return
					end
					v = n
				end
				lastValid = v
				if callback then task.spawn(callback, v) end
				Window:_maybeAutoSave()
			end)
			BindFlag(flag, function() return box.Text end, function(v) box.Text = tostring(v or "") end)
			return box
		end
		Tab.CreateTextbox = Tab.CreateInput -- alias v1

		-- -- -- Progress Bar (animasi) -- -- --
		function Tab:CreateProgressBar(text, default)
			local pct = default or 0
			local f = ElementFrame(58)
			TitleLabel(f, text or "Progress", UDim2.new(0, 12, 0, 7), UDim2.new(1, -70, 0, 18))
			local val = New("TextLabel", { Text = math.floor(pct * 100) .. "%", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(1, -62, 0, 7), Size = UDim2.new(0, 50, 0, 18), TextXAlignment = Enum.TextXAlignment.Right }, f)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 10), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = T().Stroke, BorderSizePixel = 0, ClipsDescendants = true }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Gradient(fill, T().Accent, T().Accent2, 0)
			fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
			local P = {}
			function P:Set(v)
				pct = math.clamp(v, 0, 1)
				val.Text = math.floor(pct * 100) .. "%"
				Tween(fill, 0.5, { Size = UDim2.new(pct, 0, 1, 0) }, Enum.EasingStyle.Quad)
			end
			function P:Get() return pct end
			Window:_addRefresher(function()
				if fill.Parent then fill.BackgroundColor3 = T().Accent end
				if val.Parent then val.TextColor3 = T().Accent end
			end)
			return P
		end

		-- -- -- Color Picker LENGKAP: Hue slider + Hex + preset -- -- --
		function Tab:CreateColorPicker(text, defaultColor, callback, flag)
			-- v1.6.0: ColorPicker 2D — kotak SV (Saturation x Value) + hue bar + Hex + preset.
			local current = defaultColor or T().Accent
			local h, s, v = current:ToHSV()
			local f = ElementFrame(202)
			TitleLabel(f, text or "Warna", UDim2.new(0, 12, 0, 8), UDim2.new(0.5, 0, 0, 20))
			local preview = New("Frame", { Size = UDim2.new(0, 44, 0, 28), Position = UDim2.new(1, -56, 0, 8), BackgroundColor3 = current, BorderSizePixel = 0 }, f)
			Corner(preview, 8) Stroke(preview, Color3.fromRGB(255,255,255), 1)
			-- Kotak SV: dasar warna hue penuh, overlay putih (kiri) + hitam (bawah)
			local svPad = New("Frame", { Size = UDim2.new(1, -24, 0, 96), Position = UDim2.new(0, 12, 0, 36), BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0, ClipsDescendants = true }, f)
			Corner(svPad, 8)
			local whiteOv = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, svPad)
			New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Rotation = 0 }, whiteOv)
			local blackOv = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0 }, svPad)
			New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }), Rotation = 90 }, blackOv)
			local svKnob = New("Frame", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(s, -8, 1 - v, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 3 }, svPad)
			Corner(svKnob, 99) Stroke(svKnob, Color3.fromRGB(0, 0, 0), 1)
			-- Hue bar (pelangi)
			local hueBar = New("Frame", { Size = UDim2.new(1, -24, 0, 14), Position = UDim2.new(0, 12, 0, 140), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0 }, f)
			Corner(hueBar, 99)
			New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)), ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)), ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)), ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)), ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1)) }), Rotation = 0 }, hueBar)
			local hueKnob = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(h, -9, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0 }, hueBar)
			Corner(hueKnob, 99) Stroke(hueKnob, Color3.fromRGB(0,0,0), 1)
			local hexBox = New("TextBox", { Text = "#" .. current:ToHex(), PlaceholderText = "#7C5CFF", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 110, 0, 28), Position = UDim2.new(0, 12, 0, 164), ClearTextOnFocus = false }, f)
			Corner(hexBox, 8) Padding(hexBox, 8, 0, 8, 0)
			local presets = { Color3.fromRGB(231,76,60), Color3.fromRGB(230,126,34), Color3.fromRGB(241,196,15), Color3.fromRGB(46,204,113), Color3.fromRGB(52,152,219), Color3.fromRGB(124,92,255), Color3.fromRGB(255,105,180), Color3.fromRGB(255,255,255) }
			-- v1.8.0: preset mengecil di layar sempit supaya tidak terpotong elemen.
			local presetSize, presetGap = 22, 28
			if ViewportSize().X < 360 then presetSize, presetGap = 16, 19
			elseif IsSmallScreen() then presetSize, presetGap = 18, 24 end
			for i, c in ipairs(presets) do
				local b = New("TextButton", { Text = "", BackgroundColor3 = c, Size = UDim2.new(0, presetSize, 0, presetSize), Position = UDim2.new(0, 126 + (i - 1) * presetGap, 0, 167) }, f)
				Corner(b, 99) AddPress(b)
				b.MouseButton1Click:Connect(function()
					-- Inline (bukan ApplyColor): ApplyColor baru didefinisikan setelah loop ini,
					-- jadi handler ini tidak bisa menangkapnya (lexical scope Luau).
					h, s, v = c:ToHSV()
					current = c
					preview.BackgroundColor3 = c
					hexBox.Text = "#" .. c:ToHex()
					svPad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					svKnob.Position = UDim2.new(s, -8, 1 - v, -8)
					hueKnob.Position = UDim2.new(h, -9, 0.5, -9)
					if callback then task.spawn(callback, c) end
				end)
			end
			local function ApplyColor()
				current = Color3.fromHSV(h, s, v)
				preview.BackgroundColor3 = current
				hexBox.Text = "#" .. current:ToHex()
				svPad.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				svKnob.Position = UDim2.new(s, -8, 1 - v, -8)
				hueKnob.Position = UDim2.new(h, -9, 0.5, -9)
			end
			local function ApplyHue(x)
				h = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				ApplyColor()
				if callback then task.spawn(callback, current) end
			end
			local function ApplySV(x, y)
				s = math.clamp((x - svPad.AbsolutePosition.X) / svPad.AbsoluteSize.X, 0, 1)
				v = 1 - math.clamp((y - svPad.AbsolutePosition.Y) / svPad.AbsoluteSize.Y, 0, 1)
				ApplyColor()
				if callback then task.spawn(callback, current) end
			end
			local dragHue, dragSV = false, false
			hueBar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragHue = true
					ApplyHue(i.Position.X)
				end
			end)
			svPad.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragSV = true
					ApplySV(i.Position.X, i.Position.Y)
				end
			end)
			TrackConn(UserInputService.InputChanged:Connect(function(i)
				if dragHue then ApplyHue(i.Position.X)
				elseif dragSV then ApplySV(i.Position.X, i.Position.Y) end
			end))
			TrackConn(UserInputService.InputEnded:Connect(function() dragHue = false dragSV = false end))
			hexBox.FocusLost:Connect(function(enter)
				if not enter then return end
				local hex = hexBox.Text:gsub("#", "")
				if #hex == 6 then
					local ok, col = pcall(Color3.fromHex, hex)
					if ok then
						current = col
						h, s, v = col:ToHSV()
						ApplyColor()
						if callback then task.spawn(callback, col) end
					end
				end
			end)
			local Cp = { Get = function() return current end, Set = function(c)
				current = c
				h, s, v = c:ToHSV()
				ApplyColor()
				if callback then task.spawn(callback, c) end
				Window:_maybeAutoSave()
			end }
			AddRefresher(function()
				if hexBox.Parent then hexBox.BackgroundColor3 = T().Sidebar end
			end)
			BindFlag(flag, Cp.Get, Cp.Set)
			return Cp
		end

		-- -- -- SCRIPT HUB: Kartu Script (nama + deskripsi + tombol Execute) -- -- --
		function Tab:CreateScriptCard(name, desc, callback)
			local f = ElementFrame(72)
			local titleLbl = New("TextLabel", { Text = name or "Script", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 9), Size = UDim2.new(1, -120, 0, 20), TextXAlignment = Enum.TextXAlignment.Left }, f)
			Window:_track(titleLbl, "text")
			local descLbl = New("TextLabel", { Text = desc or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 32), Size = UDim2.new(1, -120, 0, 32), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true }, f)
			Window:_track(descLbl, "subtext")
			local runBtn = New("TextButton", { Text = "Execute", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Green, Size = UDim2.new(0, 96, 0, 32), Position = UDim2.new(1, -108, 0.5, -16), AutoButtonColor = false, ClipsDescendants = true }, f)
			Corner(runBtn, 9)
			AddPress(runBtn)
			Ripple(runBtn)
			runBtn.MouseButton1Click:Connect(function()
				runBtn.Text = "Running..."
				task.spawn(function()
					local ok, err = pcall(callback or function() end)
					if ok then
						runBtn.Text = "Done"
						KemplongXD:Notify(name or "Script", "Berhasil dijalankan.", 2, "Success")
					else
						runBtn.Text = "Error"
						KemplongXD:Notify(name or "Script", tostring(err), 3, "Error")
					end
					task.wait(1.2)
					runBtn.Text = "Execute"
				end)
			end)
			return runBtn
		end
		Tab.CreateScriptButton = Tab.CreateScriptCard

		-- -- -- SCRIPT HUB: Theme Picker (dropdown tema + color picker aksen) -- -- --
		function Tab:CreateThemePicker()
			Tab:CreateSection("Tema — Dark & Bisa Diubah")
			Tab:CreateDropdown("Pilih Tema", KemplongXD:GetThemes(), Window:GetTheme(), function(v)
				Window:SetTheme(v)
			end)
			Tab:CreateColorPicker("Warna Accent", T().Accent, function(c)
				Window:SetAccent(c, true)
			end)
			Tab:CreateLabel("Tip: klik tombol T di atas untuk ganti tema dengan cepat.")
			return true
		end

		-- -- -- InfoBox (banner warna, tanpa emotikon) -- -- --
		function Tab:CreateInfoBox(title, text, kind)
			kind = kind or "Info"
			local colors = { Success = T().Green, Error = T().Red, Info = T().Accent, Warning = T().Yellow }
			local f = ElementFrame(58)
			local bar = New("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = colors[kind] or T().Accent, BorderSizePixel = 0 }, f)
			Window:_addRefresher(function()
				if not bar.Parent then return end
				local c = { Success = T().Green, Error = T().Red, Info = T().Accent, Warning = T().Yellow }
				bar.BackgroundColor3 = c[kind] or T().Accent
			end)
			TitleLabel(f, title or "Info", UDim2.new(0, 14, 0, 7), UDim2.new(1, -28, 0, 18))
			local d = New("TextLabel", { Text = text or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 28), Size = UDim2.new(1, -28, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
			Window:_track(d, "subtext")
			return f
		end

		-- -- -- TextArea (input multi-baris) -- -- --
		function Tab:CreateTextArea(text, placeholder, default, callback)
			local f = ElementFrame(96)
			TitleLabel(f, text or "Catatan", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local box = New("TextBox", { Text = default or "", PlaceholderText = placeholder or "Tulis di sini...", PlaceholderColor3 = T().SubText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, -24, 0, 58), Position = UDim2.new(0, 12, 0, 30), ClearTextOnFocus = false, MultiLine = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, f)
			Corner(box, 8) Padding(box, 8, 6, 8, 6)
			box.FocusLost:Connect(function(enter) if enter and callback then task.spawn(callback, box.Text) end end)
			return box
		end

		-- -- -- Toggle dengan deskripsi -- -- --
		function Tab:CreateToggleDesc(text, desc, default, callback, flag)
			local state = default or false
			local f = ElementFrame(58)
			TitleLabel(f, text or "Toggle", UDim2.new(0, 12, 0, 7), UDim2.new(1, -70, 0, 18))
			local d = New("TextLabel", { Text = desc or "", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -70, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
			Window:_track(d, "subtext")
			local track = New("Frame", { Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(1, -62, 0.5, -13), BackgroundColor3 = state and T().Accent or T().Stroke, BorderSizePixel = 0 }, f)
			Corner(track, 99)
			local knob = New("Frame", { Size = UDim2.new(0, 20, 0, 20), Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, track)
			Corner(knob, 99)
			local btn = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, f)
			local Tg = {}
			function Tg:Set(v)
				state = v
				Tween(track, 0.18, { BackgroundColor3 = state and T().Accent or T().Stroke })
				Tween(knob, 0.18, { Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10) })
				if callback then task.spawn(callback, state) end
				Window:_maybeAutoSave()
			end
			function Tg:Get() return state end
			AddRefresher(function() if track.Parent then track.BackgroundColor3 = state and T().Accent or T().Stroke end end)
			BindFlag(flag, Tg.Get, Tg.Set)
			btn.MouseButton1Click:Connect(function() Tg:Set(not state) end)
			return Tg
		end

		-- -- -- ListBox (daftar pilih, scroll) -- -- --
		function Tab:CreateListBox(text, items, default, callback, flag)
			items = items or {}
			local selected = default or items[1]
			local f = ElementFrame(150)
			TitleLabel(f, text or "Daftar", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local list = New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 108), Position = UDim2.new(0, 12, 0, 32), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T().Stroke, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, f)
			Corner(list, 8)
			New("UIListLayout", { Padding = UDim.new(0, 4) }, list) Padding(list, 5, 5, 5, 5)
			local Lb = {}
			local btns = {}
			local function Refresh()
				for item, b in pairs(btns) do Tween(b, 0.12, { BackgroundColor3 = item == selected and T().Accent or T().Element }) b.TextColor3 = item == selected and Color3.fromRGB(255, 255, 255) or T().Text end
			end
			for _, item in ipairs(items) do
				local b = New("TextButton", { Text = item, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Element, Size = UDim2.new(1, 0, 0, 28), AutoButtonColor = false }, list)
				Corner(b, 7) AddHover(b, T().Element, T().ElementHover)
				btns[item] = b
				b.MouseButton1Click:Connect(function() selected = item Refresh() if callback then task.spawn(callback, item) end end)
			end
			function Lb:Set(v) selected = v Refresh() if callback then task.spawn(callback, v) end Window:_maybeAutoSave() end
			function Lb:Get() return selected end
			Refresh()
			BindFlag(flag, Lb.Get, Lb.Set)
			return Lb
		end

		-- -- -- Searchable Dropdown (dropdown + kotak cari) -- -- --
		function Tab:CreateSearchableDropdown(text, options, default, callback, flag)
			options = options or {}
			local selected = default or options[1] or "None"
			local f = ElementFrame()
			TitleLabel(f, text or "Pilih", UDim2.new(0, 12, 0, 0), UDim2.new(0.45, 0, 1, 0))
			local btn = New("TextButton", { Text = selected .. "  v", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -162, 0.5, -15) }, f)
			Corner(btn, 8)
			local list = New("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = T().Element, BorderSizePixel = 0, Visible = false, ClipsDescendants = true }, Page)
			Corner(list, 10) Stroke(list)
			local search = New("TextBox", { Text = "", PlaceholderText = "Cari...", PlaceholderColor3 = T().SubText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, -12, 0, 28), Position = UDim2.new(0, 6, 0, 6), ClearTextOnFocus = false }, list)
			Corner(search, 7) Padding(search, 8, 0, 8, 0)
			local holder = New("ScrollingFrame", { Size = UDim2.new(1, -12, 1, -46), Position = UDim2.new(0, 6, 0, 40), BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, list)
			New("UIListLayout", { Padding = UDim.new(0, 4) }, holder)
			local open = false
			local Dd = {}
			local function Build(filter)
				for _, c in pairs(holder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
				local shown = 0
				for _, opt in ipairs(options) do
					if not filter or filter == "" or string.find(string.lower(opt), string.lower(filter), 1, true) then
						shown += 1
						local ob = New("TextButton", { Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, 0, 0, 30) }, holder)
						Corner(ob, 7)
						ob.MouseButton1Click:Connect(function() Dd:Set(opt) open = false list.Visible = false end)
					end
				end
				list.Size = UDim2.new(1, 0, 0, math.min(shown, 5) * 34 + 46)
			end
			function Dd:Set(v) selected = v btn.Text = v .. "  v" if callback then task.spawn(callback, v) end Window:_maybeAutoSave() end
			function Dd:Get() return selected end
			BindFlag(flag, Dd.Get, Dd.Set)
			search:GetPropertyChangedSignal("Text"):Connect(function() Build(search.Text) end)
			btn.MouseButton1Click:Connect(function()
				open = not open
				if open then search.Text = "" Build("") list.Visible = true Tween(list, 0.2, { Size = UDim2.new(1, 0, 0, math.min(#options, 5) * 34 + 46) }) else list.Visible = false end
			end)
			return Dd
		end

		-- -- -- Slider + Input angka (sinkron) -- -- --
		function Tab:CreateSliderInput(text, min, max, default, callback, flag)
			min = min or 0; max = max or 100
			local value = default or min
			local f = ElementFrame(60)
			TitleLabel(f, text or "Nilai", UDim2.new(0, 12, 0, 7), UDim2.new(1, -80, 0, 18))
			local box = New("TextBox", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(1, -72, 0, 4), ClearTextOnFocus = false }, f)
			Corner(box, 7) Padding(box, 6, 0, 6, 0)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 38), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new((max > min) and (value - min) / (max - min) or 0, 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Corner(fill, 99)
			local Si = {}
			local lastCb = 0
			local function Apply(v, force)
				value = math.clamp(math.floor(v + 0.5), min, max)
				box.Text = tostring(value)
				fill.Size = UDim2.new((max > min) and (value - min) / (max - min) or 0, 0, 1, 0)
				local now = os.clock()
				if force or (now - lastCb > 0.08) then lastCb = now if callback then task.spawn(callback, value) end end
			end
			function Si:Set(v) Apply(v, true) Window:_maybeAutoSave() end
			function Si:Get() return value end
			BindFlag(flag, Si.Get, Si.Set)
			box.FocusLost:Connect(function(enter) if enter then local n = tonumber(box.Text) if n then Apply(n, true) else box.Text = tostring(value) end end end)
			local dragging = false
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					Apply(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), false)
				end
			end)
			TrackConn(UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					Apply(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), false)
				end
			end))
			TrackConn(UserInputService.InputEnded:Connect(function(input)
				if dragging then dragging = false if callback then task.spawn(callback, value) end end
			end))
			return Si
		end

		-- -- -- Dual Button (2 tombol sejajar) -- -- --
		function Tab:CreateDualButton(text1, cb1, text2, cb2)
			local row = New("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 }, Page)
			local b1 = New("TextButton", { Text = text1 or "Kiri", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0, 0, 0, 0), AutoButtonColor = false }, row)
			Corner(b1, 10) AddPress(b1)
			local b2 = New("TextButton", { Text = text2 or "Kanan", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().Text, BackgroundColor3 = T().Element, Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0), AutoButtonColor = false }, row)
			Corner(b2, 10) Stroke(b2) AddPress(b2)
			b1.MouseButton1Click:Connect(function() if cb1 then task.spawn(cb1) end end)
			b2.MouseButton1Click:Connect(function() if cb2 then task.spawn(cb2) end end)
			return b1, b2
		end

		-- -- -- Player Dropdown (daftar pemain, ada Refresh) -- -- --
		function Tab:CreatePlayerDropdown(text, callback)
			local names = {}
			for _, plr in ipairs(Players:GetPlayers()) do if plr ~= Player then table.insert(names, plr.Name) end end
			if #names == 0 then names = { "Tidak ada pemain lain" } end
			local dd = Tab:CreateDropdown(text or "Pilih Pemain", names, names[1], callback)
			Tab:CreateButton("Refresh Daftar Pemain", function()
				local fresh = {}
				for _, plr in ipairs(Players:GetPlayers()) do if plr ~= Player then table.insert(fresh, plr.Name) end end
				if #fresh > 0 then dd:SetOptions(fresh) KemplongXD:Notify("Pemain", "Daftar pemain diperbarui.", 2, "Success") end
			end, "Secondary")
			return dd
		end

		-- -- -- Status (dot berdenyut halus, 1 tween saja) -- -- --
		function Tab:CreateStatus(text, online)
			local f = ElementFrame(44)
			local dot = New("Frame", { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 14, 0.5, -5), BackgroundColor3 = online and T().Green or T().Red, BorderSizePixel = 0 }, f)
			Window:_addRefresher(function() if dot.Parent then dot.BackgroundColor3 = online and T().Green or T().Red end end)
			Corner(dot, 99)
			if KemplongXD.Animations then
				TweenService:Create(dot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.45 }):Play()
			end
			TitleLabel(f, text or "Status", UDim2.new(0, 32, 0, 0), UDim2.new(1, -44, 1, 0))
			return f
		end

		-- -- -- Config Buttons (Simpan / Muat, pakai Window:SaveConfig) -- -- --
		function Tab:CreateConfigButtons()
			Tab:CreateDualButton("Simpan Config", function() Window:SaveConfig("Default") end, "Muat Config", function() Window:LoadConfig("Default") end)
			Tab:CreateToggleDesc("AutoSave Config", "Simpan otomatis ke file setiap ada perubahan.", Window.AutoSave, function(s)
				Window:SetAutoSave(s, "Default")
			end, "AutoSave")
			Tab:CreateButton("Hapus Config Default", function() Window:DeleteConfig("Default") end, "Secondary")
			Tab:CreateLabel("Config tersimpan ke file KemplongXD/Configs/Default.json (tema + aksen + semua Flag). Fallback ke memori kalau executor tidak dukung file.")
			return true
		end

		-- -- -- v1.5.0: ConfigManager (profil config bernama: pilih / simpan / muat / hapus) -- -- --
		function Tab:CreateConfigManager()
			Tab:CreateSection("Profil Config")
			local selected = "Default"
			local function ProfileList()
				local list = Window:ListConfigs()
				if #list == 0 then return { "Default" } end
				return list
			end
			local dd = Tab:CreateDropdown("Profil", ProfileList(), selected, function(v) selected = v end)
			local nameBox = Tab:CreateInput("Nama Profil Baru", "Contoh: Farm Malam", "", nil, false)
			local function CurrentName()
				local t = nameBox.Text or ""
				t = t:gsub("^%s+", ""):gsub("%s+$", "")
				if t == "" then return selected end
				return t
			end
			Tab:CreateDualButton("Simpan Profil", function()
				local n = CurrentName()
				Window:SaveConfig(n)
				selected = n
				dd:SetOptions(ProfileList())
				dd:Set(n)
			end, "Muat Profil", function()
				Window:LoadConfig(selected)
			end)
			Tab:CreateDualButton("Hapus Profil", function()
				Window:DeleteConfig(selected)
				dd:SetOptions(ProfileList())
				selected = ProfileList()[1]
				dd:Set(selected)
			end, "Refresh Daftar", function()
				dd:SetOptions(ProfileList())
				KemplongXD:Notify("Config", "Daftar profil diperbarui.", 2, "Info")
			end)
			Tab:CreateToggleDesc("AutoSave Config", "Simpan otomatis ke profil Default setiap ada perubahan.", Window.AutoSave, function(v)
				Window:SetAutoSave(v, "Default")
			end, "AutoSave")
			Tab:CreateLabel("Profil tersimpan di KemplongXD/Configs/<nama>.json (tema + aksen + semua Flag).")
			return { GetSelected = function() return selected end }
		end

		-- -- -- Header (judul besar + subjudul) -- -- --
		function Tab:CreateHeader(title, subtitle)
			local t = New("TextLabel", { Text = title or "", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), TextXAlignment = Enum.TextXAlignment.Left }, Page)
			Window:_track(t, "text")
			if subtitle and subtitle ~= "" then
				local s = New("TextLabel", { Text = subtitle, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, Page)
				Window:_track(s, "subtext")
			end
			return t
		end
		function Tab:CreateDividerText(text)
			local row = New("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1 }, Page)
			New("Frame", { Size = UDim2.new(0.35, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, row)
			local l = New("TextLabel", { Text = text or "", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.35, 0, 0, 0) }, row)
			Window:_track(l, "subtext")
			New("Frame", { Size = UDim2.new(0.35, 0, 0, 1), Position = UDim2.new(0.65, 0, 0.5, 0), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, row)
			return row
		end
		function Tab:CreateSpacer(height)
			return New("Frame", { Size = UDim2.new(1, 0, 0, height or 8), BackgroundTransparency = 1 }, Page)
		end

		-- -- -- StatCard (angka + bar) -- -- --
		function Tab:CreateStatCard(title, valueText, pct)
			pct = pct or 0
			local f = ElementFrame(62)
			TitleLabel(f, title or "Stat", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local val = New("TextLabel", { Text = valueText or "0", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, f)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 4), Position = UDim2.new(0, 12, 1, -10), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Corner(fill, 99)
			Window:_addRefresher(function()
				if val.Parent then val.TextColor3 = T().Accent end
				if fill.Parent then fill.BackgroundColor3 = T().Accent end
			end)
			return { Set = function(v, p2) val.Text = v if p2 ~= nil then Tween(fill, 0.3, { Size = UDim2.new(math.clamp(p2, 0, 1), 0, 1, 0) }) end end, Get = function() return val.Text end }
		end

		-- -- -- Stepper (minus / plus) -- -- --
		function Tab:CreateStepper(text, min, max, step, default, callback, flag)
			min = min or 0; max = max or 100; step = step or 1
			local value = default or min
			local f = ElementFrame()
			TitleLabel(f, text or "Jumlah")
			local minus = New("TextButton", { Text = "-", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 32, 0, 30), Position = UDim2.new(1, -128, 0.5, -15) }, f)
			Corner(minus, 8) AddPress(minus)
			local valLbl = New("TextLabel", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Text, BackgroundTransparency = 1, Size = UDim2.new(0, 52, 0, 30), Position = UDim2.new(1, -92, 0.5, -15) }, f)
			local plus = New("TextButton", { Text = "+", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 32, 0, 30), Position = UDim2.new(1, -36, 0.5, -15) }, f)
			Corner(plus, 8) AddPress(plus)
			local St = {}
			local function Apply(v)
				value = SafeClamp(v, min, max)
				valLbl.Text = tostring(value)
				if callback then task.spawn(callback, value) end
			end
			function St:Set(v) Apply(v) Window:_maybeAutoSave() end
			function St:Get() return value end
			BindFlag(flag, St.Get, St.Set)
			minus.MouseButton1Click:Connect(function() Apply(value - step) end)
			plus.MouseButton1Click:Connect(function() Apply(value + step) end)
			return St
		end

		-- -- -- Segmented (pilihan bentuk pil) -- -- --
		function Tab:CreateSegmented(text, options, default, callback, flag)
			options = options or {}
			local selected = default or options[1]
			local f = ElementFrame(72)
			TitleLabel(f, text or "Pilih", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local row = New("Frame", { Size = UDim2.new(1, -24, 0, 32), Position = UDim2.new(0, 12, 0, 32), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0 }, f)
			Corner(row, 99)
			local seg = {}
			local btns = {}
			local w = 1 / math.max(#options, 1)
			for i, opt in ipairs(options) do
				local b = New("TextButton", { Text = opt, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().SubText, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Size = UDim2.new(w, -4, 1, -6), Position = UDim2.new(w * (i - 1), 2, 0, 3), AutoButtonColor = false }, row)
				Corner(b, 99)
				btns[opt] = b
				b.MouseButton1Click:Connect(function() seg:Set(opt) end)
			end
			local function Refresh()
				for opt, b in pairs(btns) do
					if opt == selected then b.BackgroundTransparency = 0 b.BackgroundColor3 = T().Accent b.TextColor3 = Color3.fromRGB(255, 255, 255) else b.BackgroundTransparency = 1 b.TextColor3 = T().SubText end
				end
			end
			function seg:Set(v) selected = v Refresh() if callback then task.spawn(callback, v) end Window:_maybeAutoSave() end
			function seg:Get() return selected end
			Refresh()
			AddRefresher(function() Refresh() end)
			BindFlag(flag, seg.Get, seg.Set)
			return seg
		end

		-- -- -- CheckboxGroup (banyak checkbox dalam satu kartu) -- -- --
		function Tab:CreateCheckboxGroup(text, options, defaults, callback, flag)
			options = options or {}
			local chosen = {}
			for _, d in ipairs(defaults or {}) do chosen[d] = true end
			local f = ElementFrame(40 + #options * 32)
			TitleLabel(f, text or "Pilih", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local Cg = {}
			for i, opt in ipairs(options) do
				local row = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 28 + (i - 1) * 30) }, f)
				local box = New("Frame", { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 4, 0.5, -10), BackgroundColor3 = chosen[opt] and T().Accent or T().Sidebar, BorderSizePixel = 0 }, row)
				Corner(box, 6) Stroke(box)
				local dot = New("Frame", { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Visible = chosen[opt] == true }, box)
				Corner(dot, 3)
				New("TextLabel", { Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -32, 1, 0), TextXAlignment = Enum.TextXAlignment.Left }, row)
				row.MouseButton1Click:Connect(function()
					chosen[opt] = not chosen[opt]
					dot.Visible = chosen[opt] == true
					Tween(box, 0.15, { BackgroundColor3 = chosen[opt] and T().Accent or T().Sidebar })
					if callback then task.spawn(callback, Cg:Get()) end
				end)
			end
			function Cg:Get() local out = {} for k, v in pairs(chosen) do if v then table.insert(out, k) end end return out end
			function Cg:Set(list2) chosen = {} for _, d in ipairs(list2 or {}) do chosen[d] = true end if callback then task.spawn(callback, Cg:Get()) end end
			BindFlag(flag, Cg.Get, Cg.Set)
			return Cg
		end

		-- -- -- RangeSlider (dua knob: min dan max) -- -- --
		function Tab:CreateRangeSlider(text, min, max, defMin, defMax, callback, flag)
			min = min or 0; max = max or 100
			local lo = defMin or min
			local hi = defMax or max
			local f = ElementFrame(62)
			TitleLabel(f, text or "Range", UDim2.new(0, 12, 0, 7), UDim2.new(1, -24, 0, 18))
			local lbl = New("TextLabel", { Text = tostring(lo) .. " - " .. tostring(hi), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(1, -110, 0, 7), Size = UDim2.new(0, 98, 0, 18), TextXAlignment = Enum.TextXAlignment.Right }, f)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 38), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new((hi - lo) / (max - min), 0, 1, 0), Position = UDim2.new((lo - min) / (max - min), 0, 0, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Corner(fill, 99)
			local knobLo = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((lo - min) / (max - min), -9, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 2 }, bar)
			Corner(knobLo, 99) Stroke(knobLo, T().Accent, 2)
			local knobHi = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((hi - min) / (max - min), -9, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 2 }, bar)
			Corner(knobHi, 99) Stroke(knobHi, T().Accent, 2)
			local Rs = {}
			local lastCb = 0
			local function Update(force)
				if max <= min then return end
				lbl.Text = tostring(lo) .. " - " .. tostring(hi)
				fill.Position = UDim2.new((lo - min) / (max - min), 0, 0, 0)
				fill.Size = UDim2.new((hi - lo) / (max - min), 0, 1, 0)
				knobLo.Position = UDim2.new((lo - min) / (max - min), -9, 0.5, -9)
				knobHi.Position = UDim2.new((hi - min) / (max - min), -9, 0.5, -9)
				local now = os.clock()
				if force or (now - lastCb > 0.08) then lastCb = now if callback then task.spawn(callback, lo, hi) end end
			end
			function Rs:Get() return lo, hi end
			function Rs:Set(a, b) lo = math.clamp(a, min, hi) hi = math.clamp(b, lo, max) Update(true) end
			BindFlag(flag, function() return { lo, hi } end, function(v) if typeof(v) == "table" then Rs:Set(v[1] or lo, v[2] or hi) end end, function(a, b) Rs:Set(a, b) end)
			local dragging = nil
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if max <= min then return end
					local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					local v = math.floor(min + (max - min) * pct + 0.5)
					if math.abs(v - lo) < math.abs(v - hi) then dragging = "lo" lo = math.clamp(v, min, hi) else dragging = "hi" hi = math.clamp(v, lo, max) end
					Update(false)
				end
			end)
			TrackConn(UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					local v = math.floor(min + (max - min) * pct + 0.5)
					if dragging == "lo" then lo = math.clamp(v, min, hi) else hi = math.clamp(v, lo, max) end
					Update(false)
				end
			end))
			TrackConn(UserInputService.InputEnded:Connect(function(input)
				if dragging then dragging = nil if callback then task.spawn(callback, lo, hi) end end
			end))
			return Rs
		end

		-- -- -- LogBox (konsol log di dalam tab) -- -- --
		function Tab:CreateLogBox(title)
			local f = ElementFrame(150)
			TitleLabel(f, title or "Log", UDim2.new(0, 12, 0, 8), UDim2.new(1, -80, 0, 18))
			local clearBtn = New("TextButton", { Text = "Clear", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T().SubText, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 56, 0, 24), Position = UDim2.new(1, -68, 0, 6) }, f)
			Corner(clearBtn, 7)
			local holder = New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 106), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = T().Background, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, f)
			Corner(holder, 8)
			New("UIListLayout", { Padding = UDim.new(0, 2) }, holder) Padding(holder, 6, 6, 6, 6)
			local Lb = {}
			function Lb:AddLog(text, kind)
				local colors = { Info = T().Text, Success = T().Green, Error = T().Red, Warning = T().Yellow }
				local l = New("TextLabel", { Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(text), Font = Enum.Font.Code, TextSize = 11, TextColor3 = colors[kind or "Info"] or T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left }, holder)
				task.delay(0.05, function() pcall(function() holder.CanvasPosition = Vector2.new(0, holder.CanvasSize.Y.Offset) end) end)
				return l
			end
			function Lb:Clear() for _, c in pairs(holder:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end end
			clearBtn.MouseButton1Click:Connect(function() Lb:Clear() end)
			return Lb
		end

		-- -- -- CodeBox (tampilkan kode + tombol Copy) -- -- --
		function Tab:CreateCodeBox(code)
			local f = ElementFrame(96)
			local lbl = New("TextLabel", { Text = code or "", Font = Enum.Font.Code, TextSize = 11, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -84, 0, 80), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true }, f)
			local copyBtn = New("TextButton", { Text = "Copy", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 60, 0, 28), Position = UDim2.new(1, -72, 0, 8) }, f)
			Corner(copyBtn, 8) AddPress(copyBtn)
			copyBtn.MouseButton1Click:Connect(function()
				if setclipboard then pcall(setclipboard, code or "") KemplongXD:Notify("Disalin", "Kode berhasil disalin.", 2, "Success") else KemplongXD:Notify("Clipboard", "setclipboard tidak tersedia di executor ini.", 2, "Warning") end
			end)
			return f
		end
		function Tab:CreateCopyButton(text, value)
			local btn = New("TextButton", { Text = text or "Copy", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Element, Size = UDim2.new(1, 0, 0, 38), AutoButtonColor = false }, Page)
			Corner(btn, 10) Stroke(btn) AddPress(btn)
			btn.MouseButton1Click:Connect(function()
				if setclipboard then pcall(setclipboard, value or "") KemplongXD:Notify("Disalin", tostring(value or ""), 2, "Success") else KemplongXD:Notify("Clipboard", "setclipboard tidak tersedia.", 2, "Warning") end
			end)
			return btn
		end

		-- -- -- Accordion (buka / tutup isi teks) -- -- --
		function Tab:CreateAccordion(title, content)
			local f = ElementFrame(44)
			local btn = New("TextButton", { Text = title or "Detail", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextXAlignment = Enum.TextXAlignment.Left }, f)
			local arrow = New("TextLabel", { Text = "v", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -36, 0.5, -14) }, f)
			local body = New("TextLabel", { Text = content or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Visible = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, Page)
			local open = false
			local function Toggle()
				open = not open
				body.Visible = open
				arrow.Text = open and "^" or "v"
				if open then Tween(f, 0.2, { Size = UDim2.new(1, 0, 0, 44) }) body.Size = UDim2.new(1, 0, 0, 48) end
			end
			btn.MouseButton1Click:Connect(Toggle)
			return { Toggle = Toggle, IsOpen = function() return open end }
		end

		-- -- -- Rating (1-5 kotak) -- -- --
		function Tab:CreateRating(text, maxStars, default, callback, flag)
			maxStars = maxStars or 5
			local value = default or 0
			local f = ElementFrame()
			TitleLabel(f, text or "Rating")
			local Rt = {}
			local boxes = {}
			for i = 1, maxStars do
				local b = New("TextButton", { Text = tostring(i), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = i <= value and T().Accent or T().Sidebar, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -36 - (maxStars - i) * 32, 0.5, -14) }, f)
				Corner(b, 7) AddPress(b)
				boxes[i] = b
				b.MouseButton1Click:Connect(function() Rt:Set(i) end)
			end
			function Rt:Set(v)
				value = math.clamp(v, 0, maxStars)
				for i, b in ipairs(boxes) do Tween(b, 0.15, { BackgroundColor3 = i <= value and T().Accent or T().Sidebar }) end
				if callback then task.spawn(callback, value) end
				Window:_maybeAutoSave()
			end
			function Rt:Get() return value end
			AddRefresher(function()
				for i, b in ipairs(boxes) do if b.Parent then b.BackgroundColor3 = i <= value and T().Accent or T().Sidebar end end
			end)
			BindFlag(flag, Rt.Get, Rt.Set)
			return Rt
		end

		-- -- -- ChipGroup (pilihan bentuk chip horizontal) -- -- --
		function Tab:CreateChipGroup(text, options, default, callback, flag)
			options = options or {}
			local selected = default or options[1]
			local f = ElementFrame(72)
			TitleLabel(f, text or "Pilih", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local row = New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 32), Position = UDim2.new(0, 12, 0, 32), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X }, f)
			local layout = New("UIListLayout", { Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal }, row)
			local Ch = {}
			local btns = {}
			for _, opt in ipairs(options) do
				local b = New("TextButton", { Text = opt, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T().SubText, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, #opt * 8 + 28, 0, 30), AutoButtonColor = false }, row)
				Corner(b, 99)
				btns[opt] = b
				b.MouseButton1Click:Connect(function() Ch:Set(opt) end)
			end
			local function Refresh()
				for opt, b in pairs(btns) do
					if opt == selected then b.BackgroundColor3 = T().Accent b.TextColor3 = Color3.fromRGB(255, 255, 255) else b.BackgroundColor3 = T().Sidebar b.TextColor3 = T().SubText end
				end
			end
			function Ch:Set(v) selected = v Refresh() if callback then task.spawn(callback, v) end Window:_maybeAutoSave() end
			function Ch:Get() return selected end
			Refresh()
			AddRefresher(function() Refresh() end)
			BindFlag(flag, Ch.Get, Ch.Set)
			return Ch
		end

		-- -- -- PlayerCard (avatar + nama pemain lokal) -- -- --
		function Tab:CreatePlayerCard()
			local f = ElementFrame(68)
			local img = New("ImageLabel", { BackgroundColor3 = T().Sidebar, BorderSizePixel = 0, Size = UDim2.new(0, 52, 0, 52), Position = UDim2.new(0, 8, 0.5, -26) }, f)
			Corner(img, 99)
			task.spawn(function()
				local ok, thumb = pcall(function() return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
				if ok and img.Parent then img.Image = thumb end
			end)
			TitleLabel(f, Player.DisplayName or Player.Name, UDim2.new(0, 70, 0, 10), UDim2.new(1, -82, 0, 20))
			local sub = New("TextLabel", { Text = "@" .. Player.Name .. "  •  ID: " .. tostring(Player.UserId), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 32), Size = UDim2.new(1, -82, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, f)
			Window:_track(sub, "subtext")
			return f
		end

		-- -- -- AsyncButton (tombol dengan status Loading / Done) -- -- --
		function Tab:CreateAsyncButton(text, callback)
			local btn = New("TextButton", { Text = text or "Jalankan", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false }, Page)
			Corner(btn, 10) AddPress(btn)
			local busy = false
			btn.MouseButton1Click:Connect(function()
				if busy then return end
				busy = true
				btn.Text = "Loading..."
				task.spawn(function()
					local ok, err = pcall(callback or function() end)
					btn.Text = ok and "Done" or "Error"
					if not ok then KemplongXD:Notify("Error", tostring(err), 3, "Error") end
					task.wait(1)
					btn.Text = text or "Jalankan"
					busy = false
				end)
			end)
			return btn
		end

		-- -- -- Timer (hitung mundur, 1 detik sekali, berhenti saat UI ditutup) -- -- --
		function Tab:CreateTimer(text, seconds, callback)
			local left = seconds or 60
			local f = ElementFrame()
			TitleLabel(f, text or "Timer")
			local lbl = New("TextLabel", { Text = tostring(left) .. "s", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Accent, BackgroundTransparency = 1, Size = UDim2.new(0, 70, 1, 0), Position = UDim2.new(1, -82, 0, 0), TextXAlignment = Enum.TextXAlignment.Right }, f)
			local stopped = false
			task.spawn(function()
				while left > 0 and not stopped and f.Parent do
					task.wait(1)
					left -= 1
					if f.Parent then lbl.Text = tostring(left) .. "s" end
				end
				if not stopped and f.Parent and callback then task.spawn(callback) end
			end)
			return { Stop = function() stopped = true end, Get = function() return left end }
		end

		-- -- -- Keybind -- -- --
		function Tab:CreateKeybind(text, defaultKey, callback, flag)
			local current = defaultKey or Enum.KeyCode.F
			local f = ElementFrame()
			TitleLabel(f, text or "Keybind")
			local btn = New("TextButton", { Text = current.Name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 90, 0, 30), Position = UDim2.new(1, -102, 0.5, -15) }, f)
			Corner(btn, 8) Stroke(btn) AddPress(btn)
			local listening = false
			btn.MouseButton1Click:Connect(function()
				listening = true
				btn.Text = "..."
				Tween(btn, 0.15, { BackgroundColor3 = T().Accent })
			end)
			TrackConn(UserInputService.InputBegan:Connect(function(input, gpe)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					current = input.KeyCode
					btn.Text = current.Name
					Tween(btn, 0.15, { BackgroundColor3 = T().Sidebar })
					if callback then task.spawn(callback, current) end
				elseif not listening and not gpe and input.KeyCode == current then
					if callback then task.spawn(callback, current) end
				end
			end))
			local Kb = { Get = function() return current end, Set = function(k) current = k btn.Text = current.Name if callback then task.spawn(callback, current) end end }
			Window._keybinds = Window._keybinds or {}
			table.insert(Window._keybinds, { Text = text or "Keybind", Get = Kb.Get })
			BindFlag(flag, Kb.Get, Kb.Set)
			return Kb
		end

		-- -- -- v1.3.0: Toggle + Keybind dalam satu baris -- -- --
		function Tab:CreateToggleKeybind(text, defaultState, defaultKey, stateCallback, keyCallback, flag)
			local state = defaultState or false
			local current = defaultKey or Enum.KeyCode.F
			local f = ElementFrame()
			TitleLabel(f, text or "Toggle + Keybind", UDim2.new(0, 12, 0, 0), UDim2.new(0.45, 0, 1, 0))
			local track = New("Frame", { Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -116, 0.5, -12), BackgroundColor3 = state and T().Accent or T().Stroke, BorderSizePixel = 0 }, f)
			Corner(track, 99)
			local knob = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0 }, track)
			Corner(knob, 99)
			local keyBtn = New("TextButton", { Text = current.Name, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 52, 0, 26), Position = UDim2.new(1, -58, 0.5, -13) }, f)
			Corner(keyBtn, 7) Stroke(keyBtn) AddPress(keyBtn)
			local Tk = {}
			function Tk:Set(v)
				state = v
				Tween(track, 0.18, { BackgroundColor3 = state and T().Accent or T().Stroke })
				Tween(knob, 0.18, { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) })
				if stateCallback then task.spawn(stateCallback, state) end
				Window:_maybeAutoSave()
			end
			function Tk:Get() return state end
			function Tk:GetKey() return current end
			function Tk:SetKey(k) current = k keyBtn.Text = current.Name if keyCallback then task.spawn(keyCallback, current) end end
			local trackBtn = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(0, 58, 1, 0), Position = UDim2.new(1, -122, 0, 0) }, f)
			trackBtn.MouseButton1Click:Connect(function() Tk:Set(not state) end)
			local listening = false
			keyBtn.MouseButton1Click:Connect(function() listening = true keyBtn.Text = "..." end)
			TrackConn(UserInputService.InputBegan:Connect(function(input, gpe)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false Tk:SetKey(input.KeyCode)
				elseif not listening and not gpe and input.KeyCode == current then
					Tk:Set(not state)
				end
			end))
			AddRefresher(function() if track.Parent then track.BackgroundColor3 = state and T().Accent or T().Stroke end end)
			BindFlag(flag, Tk.Get, Tk.Set)
			if flag and flag ~= "" then BindFlag(flag .. "_Key", Tk.GetKey, Tk.SetKey) end
			return Tk
		end

		-- -- -- v1.3.0: ColorPalette (pilihan warna preset, tanpa buka picker) -- -- --
		function Tab:CreateColorPalette(text, colors, default, callback, flag)
			colors = colors or { Color3.fromRGB(231, 76, 60), Color3.fromRGB(230, 126, 34), Color3.fromRGB(241, 196, 15), Color3.fromRGB(46, 204, 113), Color3.fromRGB(52, 152, 219), Color3.fromRGB(124, 92, 255), Color3.fromRGB(255, 105, 180), Color3.fromRGB(255, 255, 255) }
			local selected = default or colors[1]
			local f = ElementFrame(64)
			TitleLabel(f, text or "Warna", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local Cp = {}
			local btns = {}
			for i, c in ipairs(colors) do
				local b = New("TextButton", { Text = "", BackgroundColor3 = c, Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 12 + (i - 1) * 32, 0, 30) }, f)
				Corner(b, 99) Stroke(b, Color3.fromRGB(255, 255, 255), 1) AddPress(b)
				btns[c] = b
				b.MouseButton1Click:Connect(function() Cp:Set(c) end)
			end
			local function Refresh()
				for c, b in pairs(btns) do
					b.Size = c == selected and UDim2.new(0, 30, 0, 30) or UDim2.new(0, 26, 0, 26)
				end
			end
			function Cp:Set(c) selected = c Refresh() if callback then task.spawn(callback, c) end Window:_maybeAutoSave() end
			function Cp:Get() return selected end
			Refresh()
			BindFlag(flag, Cp.Get, Cp.Set)
			return Cp
		end

		-- -- -- v1.3.0: ServerButtons (Rejoin + Server Hop) -- -- --
		function Tab:CreateServerButtons()
			local TeleportService = game:GetService("TeleportService")
			Tab:CreateDualButton("Rejoin Server", function()
				local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
				if not ok then KemplongXD:Notify("Rejoin gagal", tostring(err), 3, "Error") end
			end, "Server Hop", function()
				task.spawn(function()
					local ok, servers = pcall(function()
						return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
					end)
					if ok and servers and servers.data then
						for _, srv in ipairs(servers.data) do
							if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
								-- v1.8.2 (K14): dibungkus pcall seperti Rejoin — gagal teleport kini
								-- beri Notify dan coba server berikutnya, bukan error diam-diam.
								local hopOk, hopErr = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, Player) end)
								if hopOk then return end
								KemplongXD:Notify("Server Hop gagal", tostring(hopErr), 3, "Error")
							end
						end
					end
					KemplongXD:Notify("Server Hop", "Tidak ada server lain yang tersedia.", 2, "Warning")
				end)
			end)
			return true
		end

		-- -- -- v1.3.0: InputNumber (angka + tombol - / +) -- -- --
		function Tab:CreateInputNumber(text, min, max, step, default, callback, flag)
			min = min or 0; max = max or 100; step = step or 1
			local value = default or min
			local f = ElementFrame()
			TitleLabel(f, text or "Angka")
			local minus = New("TextButton", { Text = "-", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 32, 0, 30), Position = UDim2.new(1, -160, 0.5, -15) }, f)
			Corner(minus, 8) AddPress(minus)
			local box = New("TextBox", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(1, -124, 0.5, -15), ClearTextOnFocus = false }, f)
			Corner(box, 8) Padding(box, 6, 0, 6, 0)
			local plus = New("TextButton", { Text = "+", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 32, 0, 30), Position = UDim2.new(1, -40, 0.5, -15) }, f)
			Corner(plus, 8) AddPress(plus)
			local In = {}
			local function Apply(v, silent)
				value = SafeClamp(v, min, max)
				box.Text = tostring(value)
				if not silent and callback then task.spawn(callback, value) end
				Window:_maybeAutoSave()
			end
			function In:Set(v) Apply(v) end
			function In:Get() return value end
			minus.MouseButton1Click:Connect(function() Apply(value - step) end)
			plus.MouseButton1Click:Connect(function() Apply(value + step) end)
			box.FocusLost:Connect(function(enter)
				if enter then local n = tonumber(box.Text) if n then Apply(n) else box.Text = tostring(value) end end
			end)
			BindFlag(flag, In.Get, In.Set)
			return In
		end

		-- -- -- v1.3.0: PreciseSlider (desimal, contoh 0.5 / 0.1) -- -- --
		function Tab:CreatePreciseSlider(text, min, max, decimals, default, callback, flag)
			min = min or 0; max = max or 100; decimals = decimals or 1
			local mult = 10 ^ decimals
			local value = default or min
			local f = ElementFrame(60)
			TitleLabel(f, text or "Nilai", UDim2.new(0, 12, 0, 7), UDim2.new(1, -80, 0, 18))
			local valLbl = New("TextLabel", { Text = string.format("%." .. decimals .. "f", value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(1, -72, 0, 7), Size = UDim2.new(0, 60, 0, 18), TextXAlignment = Enum.TextXAlignment.Right }, f)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 38), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new((max > min) and (value - min) / (max - min) or 0, 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Corner(fill, 99)
			local knob = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((max > min) and (value - min) / (max - min) or 0, -9, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 2 }, bar)
			Corner(knob, 99) Stroke(knob, T().Accent, 2)
			local Ps = {}
			local lastCb = 0
			local function Apply(v, force)
				value = math.floor((SafeClamp(v, min, max) * mult) + 0.5) / mult
				valLbl.Text = string.format("%." .. decimals .. "f", value)
				local pct = (max > min) and (value - min) / (max - min) or 0
				fill.Size = UDim2.new(pct, 0, 1, 0)
				knob.Position = UDim2.new(pct, -9, 0.5, -9)
				local now = os.clock()
				if force or (now - lastCb > 0.08) then lastCb = now if callback then task.spawn(callback, value) end end
			end
			function Ps:Set(v) Apply(v, true) Window:_maybeAutoSave() end
			function Ps:Get() return value end
			local dragging = false
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true Apply(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), false) end
			end)
			TrackConn(UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Apply(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), false) end
			end))
			TrackConn(UserInputService.InputEnded:Connect(function() if dragging then dragging = false if callback then task.spawn(callback, value) end Window:_maybeAutoSave() end end))
			BindFlag(flag, Ps.Get, Ps.Set)
			return Ps
		end

		-- -- -- v1.3.0: PlayerList (daftar semua pemain, klik = callback) -- -- --
		function Tab:CreatePlayerList(text, callback)
			local f = ElementFrame(170)
			TitleLabel(f, text or "Pemain di Server", UDim2.new(0, 12, 0, 8), UDim2.new(1, -90, 0, 18))
			local refreshBtn = New("TextButton", { Text = "Refresh", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 66, 0, 24), Position = UDim2.new(1, -78, 0, 6) }, f)
			Corner(refreshBtn, 7)
			local list = New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 126), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T().Stroke, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, f)
			Corner(list, 8)
			New("UIListLayout", { Padding = UDim.new(0, 4) }, list) Padding(list, 5, 5, 5, 5)
			local Pl = {}
			function Pl:Refresh()
				if not list.Parent then return end
				for _, c in pairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
				for _, plr in ipairs(Players:GetPlayers()) do
					local b = New("TextButton", { Text = plr.DisplayName .. " (@" .. plr.Name .. ")", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Element, Size = UDim2.new(1, 0, 0, 28), AutoButtonColor = false }, list)
					Corner(b, 7) AddHover(b, T().Element, T().ElementHover)
					b.MouseButton1Click:Connect(function() if callback then task.spawn(callback, plr) end end)
				end
			end
			refreshBtn.MouseButton1Click:Connect(function() Pl:Refresh() end)
			Players.PlayerAdded:Connect(function() Pl:Refresh() end)
			Players.PlayerRemoving:Connect(function() Pl:Refresh() end)
			Pl:Refresh()
			return Pl
		end

		-- -- -- v1.5.0: PerformanceCard (FPS + Ping, update 1 detik, berhenti saat dihancurkan) -- -- --
		function Tab:CreatePerformanceCard()
			local f = ElementFrame(62)
			TitleLabel(f, "Performa", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local fpsLbl = New("TextLabel", { Text = "FPS: --", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(0.5, -12, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, f)
			local pingLbl = New("TextLabel", { Text = "Ping: -- ms", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 30), Size = UDim2.new(0.5, -12, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, f)
			Window:_track(fpsLbl, "text") Window:_track(pingLbl, "text")
			local fps, ping, stopped = 0, 0, false
			local frames = 0
			local conn = RunService.RenderStepped:Connect(function() frames += 1 end)
			task.spawn(function()
				while not stopped and f.Parent do
					frames = 0
					task.wait(1)
					if not f.Parent then break end
					fps = frames
					local ok, p = pcall(function() return Player:GetNetworkPing() end)
					ping = ok and math.floor((p or 0) * 1000 + 0.5) or 0
					fpsLbl.Text = "FPS: " .. tostring(fps)
					pingLbl.Text = "Ping: " .. tostring(ping) .. " ms"
					fpsLbl.TextColor3 = fps >= 50 and T().Green or fps >= 30 and T().Yellow or T().Red
				end
				-- v1.8.1 (S2): lepas RenderStepped saat kartu dihancurkan, bukan cuma saat Stop().
				pcall(function() conn:Disconnect() end)
			end)
			Window:_addRefresher(function()
				if fpsLbl.Parent then fpsLbl.TextColor3 = fps >= 50 and T().Green or fps >= 30 and T().Yellow or T().Red end
			end)
			return { Stop = function() stopped = true pcall(function() conn:Disconnect() end) end, GetFPS = function() return fps end, GetPing = function() return ping end }
		end

		-- -- -- v1.5.0: ClockCard (jam + tanggal, update 1 detik) -- -- --
		function Tab:CreateClockCard()
			local f = ElementFrame(62)
			TitleLabel(f, "Waktu", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local timeLbl = New("TextLabel", { Text = os.date("%H:%M:%S"), Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(0.5, -12, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, f)
			local dateLbl = New("TextLabel", { Text = os.date("%d-%m-%Y"), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 30), Size = UDim2.new(0.5, -12, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, f)
			Window:_track(timeLbl, "text") Window:_track(dateLbl, "subtext")
			local stopped = false
			task.spawn(function()
				while not stopped and f.Parent do
					task.wait(1)
					if f.Parent then timeLbl.Text = os.date("%H:%M:%S") dateLbl.Text = os.date("%d-%m-%Y") end
				end
			end)
			return { Stop = function() stopped = true end }
		end

		-- -- -- v1.5.0: Banner (gambar + judul di atas gambar) -- -- --
		function Tab:CreateBanner(title, subtitle, assetId, height)
			local h = height or 120
			local f = New("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = T().Element, BorderSizePixel = 0, ClipsDescendants = true }, Page)
			Corner(f, 11) Stroke(f) Window:_track(f, "element")
			pcall(function() f:SetAttribute("Searchable", true) end)
			local img = New("ImageLabel", { Image = assetId or "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScaleType = Enum.ScaleType.Crop }, f)
			local shade = New("Frame", { Size = UDim2.new(1, 0, 0, 56), Position = UDim2.new(0, 0, 1, -56), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0 }, f)
			local t = New("TextLabel", { Text = title or "", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Position = UDim2.new(0, 12, 1, -48), Size = UDim2.new(1, -24, 0, 22), TextXAlignment = Enum.TextXAlignment.Left }, f)
			if subtitle and subtitle ~= "" then
				New("TextLabel", { Text = subtitle, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(230, 230, 230), BackgroundTransparency = 1, Position = UDim2.new(0, 12, 1, -26), Size = UDim2.new(1, -24, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, f)
			end
			return f
		end

		-- -- -- v1.5.0: StepSlider (slider yang melompat per step, misal kelipatan 5) -- -- --
		function Tab:CreateStepSlider(text, min, max, step, default, callback, flag)
			min = min or 0; max = max or 100; step = step or 1
			local value = default or min
			local f = ElementFrame(60)
			TitleLabel(f, text or "Nilai", UDim2.new(0, 12, 0, 7), UDim2.new(1, -70, 0, 18))
			local valLbl = New("TextLabel", { Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T().Accent, BackgroundTransparency = 1, Position = UDim2.new(1, -62, 0, 7), Size = UDim2.new(0, 50, 0, 18), TextXAlignment = Enum.TextXAlignment.Right }, f)
			local bar = New("Frame", { Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 0, 38), BackgroundColor3 = T().Stroke, BorderSizePixel = 0 }, f)
			Corner(bar, 99)
			local fill = New("Frame", { Size = UDim2.new((max > min) and (value - min) / (max - min) or 0, 0, 1, 0), BackgroundColor3 = T().Accent, BorderSizePixel = 0 }, bar)
			Corner(fill, 99)
			local knob = New("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new((max > min) and (value - min) / (max - min) or 0, -9, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 2 }, bar)
			Corner(knob, 99) Stroke(knob, T().Accent, 2)
			local Ss = {}
			local lastCb = 0
			local function Apply(v, force)
				if max <= min then return end
				value = math.clamp(min + step * math.floor((v - min) / step + 0.5), min, max)
				valLbl.Text = tostring(value)
				local pct = (value - min) / (max - min)
				fill.Size = UDim2.new(pct, 0, 1, 0)
				knob.Position = UDim2.new(pct, -9, 0.5, -9)
				local now = os.clock()
				if force or (now - lastCb > 0.08) then lastCb = now if callback then task.spawn(callback, value) end end
			end
			function Ss:Set(v) Apply(v, true) Window:_maybeAutoSave() end
			function Ss:Get() return value end
			local dragging = false
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					Apply(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), false)
				end
			end)
			TrackConn(UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					Apply(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), false)
				end
			end))
			TrackConn(UserInputService.InputEnded:Connect(function(input)
				if dragging then dragging = false if callback then task.spawn(callback, value) end Window:_maybeAutoSave() end
			end))
			Window:_addRefresher(function()
				if fill.Parent then fill.BackgroundColor3 = T().Accent end
				if valLbl.Parent then valLbl.TextColor3 = T().Accent end
			end)
			BindFlag(flag, Ss.Get, Ss.Set)
			return Ss
		end

		-- -- -- v1.5.0: CommandBar (ketik prefix + perintah, misal ;fly 100) -- -- --
		function Tab:CreateCommandBar(prefix, commands)
			prefix = prefix or ";"
			commands = commands or {}
			local f = ElementFrame(96)
			TitleLabel(f, "Command Bar  (" .. prefix .. "<perintah>)", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local names = {}
			for name in pairs(commands) do table.insert(names, name) end
			table.sort(names)
			local hint = New("TextLabel", { Text = #names > 0 and ("Perintah: " .. table.concat(names, ", ")) or "Belum ada perintah terdaftar.", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 16), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, f)
			Window:_track(hint, "subtext")
			local box = New("TextBox", { Text = "", PlaceholderText = prefix .. "fly", PlaceholderColor3 = T().SubText, Font = Enum.Font.Code, TextSize = 12, TextColor3 = T().Text, BackgroundColor3 = T().Sidebar, Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0, 12, 0, 54), ClearTextOnFocus = false }, f)
			Corner(box, 8) Padding(box, 10, 0, 10, 0)
			local function Run(raw)
				local text = raw or ""
				text = text:gsub("^%s+", ""):gsub("%s+$", "")
				if text:sub(1, #prefix) == prefix then text = text:sub(#prefix + 1) end
				if text == "" then return end
				local parts = {}
				for w in string.gmatch(text, "%S+") do table.insert(parts, w) end
				local name = string.lower(parts[1] or "")
				table.remove(parts, 1)
				local fn = commands[name]
				if not fn then
					KemplongXD:Notify("Command", "Perintah '" .. name .. "' tidak dikenal.", 2, "Warning")
					return
				end
				local ok, err = pcall(fn, parts, table.concat(parts, " "))
				if ok then
					KemplongXD:Notify("Command", "'" .. name .. "' dijalankan.", 2, "Success")
				else
					KemplongXD:Notify("Command Error", tostring(err), 3, "Error")
				end
			end
			box.FocusLost:Connect(function(enter)
				if enter then Run(box.Text) box.Text = "" end
			end)
			return { Run = Run, Box = box }
		end

		-- -- -- v1.6.0: NotificationHistory (riwayat notifikasi, max 50) -- -- --
		function Tab:CreateNotificationHistory()
			local f = ElementFrame(170)
			TitleLabel(f, "Riwayat Notifikasi", UDim2.new(0, 12, 0, 8), UDim2.new(1, -90, 0, 18))
			local clearBtn = New("TextButton", { Text = "Clear", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T().SubText, BackgroundColor3 = T().Sidebar, Size = UDim2.new(0, 66, 0, 24), Position = UDim2.new(1, -78, 0, 6) }, f)
			Corner(clearBtn, 7)
			local list = New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 126), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T().Stroke, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, f)
			Corner(list, 8)
			New("UIListLayout", { Padding = UDim.new(0, 4) }, list) Padding(list, 5, 5, 5, 5)
			local Nh = {}
			function Nh:Refresh()
				if not list.Parent then return end
				for _, c in pairs(list:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
				local items = KemplongXD:GetNotifications()
				if #items == 0 then
					New("TextLabel", { Text = "Belum ada notifikasi.", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left }, list)
					return
				end
				for _, e in ipairs(items) do
					local colors = { Success = T().Green, Error = T().Red, Info = T().Accent, Warning = T().Yellow }
					New("TextLabel", { Text = "[" .. (e.Time or "") .. "] " .. (e.Title or "") .. " — " .. (e.Desc or ""), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = colors[e.Kind] or T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, list)
				end
			end
			clearBtn.MouseButton1Click:Connect(function() KemplongXD:ClearNotifications() Nh:Refresh() end)
			Nh:Refresh()
			return Nh
		end

		-- -- -- v1.6.0: DiscordButton (salin link invite Discord) -- -- --
		function Tab:CreateDiscordButton(text, inviteLink)
			local btn = New("TextButton", { Text = text or "Join Discord", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(88, 101, 242), Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false }, Page)
			Corner(btn, 10) AddPress(btn)
			btn.MouseButton1Click:Connect(function()
				if inviteLink and inviteLink ~= "" then
					if setclipboard then pcall(setclipboard, inviteLink) KemplongXD:Notify("Discord", "Link invite disalin ke clipboard.", 2, "Success")
					else KemplongXD:Notify("Discord", inviteLink, 3, "Info") end
				else
					KemplongXD:Notify("Discord", "Belum ada link invite yang diatur.", 2, "Warning")
				end
			end)
			return btn
		end

		-- -- -- v1.7.0: UserCard (avatar + nama + UserId pemain lokal) -- -- --
		function Tab:CreateUserCard()
			local f = ElementFrame(64)
			local avatar = New("ImageLabel", { BackgroundColor3 = T().Sidebar, BorderSizePixel = 0, Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(0, 12, 0, 8), ScaleType = Enum.ScaleType.Crop }, f)
			Corner(avatar, 99) Stroke(avatar)
			local nameLbl = New("TextLabel", { Text = Player.Name, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T().Text, BackgroundTransparency = 1, Position = UDim2.new(0, 72, 0, 8), Size = UDim2.new(1, -84, 0, 20), TextXAlignment = Enum.TextXAlignment.Left }, f)
			local infoLbl = New("TextLabel", { Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 72, 0, 30), Size = UDim2.new(1, -84, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, f)
			Window:_track(nameLbl, "text") Window:_track(infoLbl, "subtext")
			local Uc = {}
			function Uc:Refresh()
				if not f.Parent then return end
				nameLbl.Text = Player.DisplayName .. " (@" .. Player.Name .. ")"
				infoLbl.Text = "UserId: " .. tostring(Player.UserId) .. "  •  Umur akun: " .. tostring(Player.AccountAge) .. " hari"
				local ok, thumb = pcall(function()
					return game:GetService("Players"):GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
				if ok and thumb then avatar.Image = thumb end
			end
			Uc:Refresh()
			return Uc
		end

		-- -- -- v1.7.0: ServerCard (info server + salin JobId) -- -- --
		function Tab:CreateServerCard()
			local f = ElementFrame(86)
			TitleLabel(f, "Server", UDim2.new(0, 12, 0, 8), UDim2.new(1, -110, 0, 18))
			local copyBtn = New("TextButton", { Text = "Salin JobId", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = T().Accent, Size = UDim2.new(0, 92, 0, 26), Position = UDim2.new(1, -104, 0, 6) }, f)
			Corner(copyBtn, 7)
			local line1 = New("TextLabel", { Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, f)
			local line2 = New("TextLabel", { Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 54), Size = UDim2.new(1, -24, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, f)
			Window:_track(line1, "subtext") Window:_track(line2, "subtext")
			local Sc = {}
			function Sc:Refresh()
				if not f.Parent then return end
				local pls = game:GetService("Players")
				line1.Text = "PlaceId: " .. tostring(game.PlaceId) .. "  •  Pemain: " .. tostring(#pls:GetPlayers()) .. "/" .. tostring(pls.MaxPlayers)
				line2.Text = "JobId: " .. tostring(game.JobId):sub(1, 12) .. "..."
			end
			copyBtn.MouseButton1Click:Connect(function()
				if setclipboard then pcall(setclipboard, game.JobId) KemplongXD:Notify("JobId", "JobId disalin ke clipboard.", 2, "Success")
				else KemplongXD:Notify("JobId", game.JobId, 3, "Info") end
			end)
			Sc:Refresh()
			return Sc
		end

		-- -- -- v1.7.0: KeybindList (daftar semua keybind yang terdaftar di Window) -- -- --
		function Tab:CreateKeybindList()
			local f = ElementFrame(150)
			TitleLabel(f, "Daftar Keybind", UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 18))
			local list = New("ScrollingFrame", { Size = UDim2.new(1, -24, 0, 106), Position = UDim2.new(0, 12, 0, 32), BackgroundColor3 = T().Sidebar, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T().Stroke, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, f)
			Corner(list, 8)
			New("UIListLayout", { Padding = UDim.new(0, 4) }, list) Padding(list, 5, 5, 5, 5)
			local Kl = {}
			function Kl:Refresh()
				if not list.Parent then return end
				for _, c in pairs(list:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
				local items = Window._keybinds or {}
				if #items == 0 then
					New("TextLabel", { Text = "Belum ada keybind terdaftar.", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().SubText, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left }, list)
					return
				end
				for _, e in ipairs(items) do
					local keyName = "?"
					local ok, k = pcall(e.Get)
					if ok and k then keyName = k.Name or tostring(k) end
					New("TextLabel", { Text = (e.Text or "Keybind") .. "  —  " .. keyName, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T().Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }, list)
				end
			end
			Kl:Refresh()
			return Kl
		end

		return Tab
	end

	-- Logika Global Search: cocokkan nama tab atau judul elemen Searchable di tab itu.
	GlobalSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(GlobalSearchBox.Text or "")
		local firstVisible = nil
		for _, t in ipairs(Window.Tabs) do
			local match = q == "" or string.find(string.lower(t.Name), q, 1, true) ~= nil
			if not match and q ~= "" then
				for _, child in ipairs(t.Page:GetChildren()) do
					if child:GetAttribute("Searchable") then
						local hay = string.lower(child:GetAttribute("SearchTitle") or "")
						if hay == "" then
							local title = child:FindFirstChildOfClass("TextLabel")
							hay = title and string.lower(title.Text) or ""
						end
						if hay ~= "" and string.find(hay, q, 1, true) then match = true break end
					end
				end
			end
			t.Button.Visible = match
			if match and not firstVisible then firstVisible = t end
		end
		if q ~= "" and firstVisible and not firstVisible.Page.Visible then
			firstVisible.Select()
		end
	end)

	-- Resize handle v1.6.0: seret sudut kanan-bawah untuk ubah ukuran (PC saja).
	local ResizeHandle = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(1, -22, 1, -22), ZIndex = 5 }, Main)
	Window._resizeHandle = ResizeHandle
	-- garis grip diagonal (3 garis kecil)
	for i = 1, 3 do
		New("Frame", { Size = UDim2.new(0, 10 - (i - 1) * 3, 0, 1), Position = UDim2.new(1, -14, 1, -6 - (i - 1) * 3), BackgroundColor3 = T().SubText, BorderSizePixel = 0, Rotation = -45 }, Main)
	end
	ResizeHandle.InputBegan:Connect(function(input)
		if IsSmallScreen() then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local startPos = input.Position
			local startSize = Main.Size
			local conn
			conn = TrackConn(UserInputService.InputChanged:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
					local d = inp.Position - startPos
					local vp = ViewportSize()
					local w = math.clamp(startSize.X.Offset + d.X, 420, math.max(420, vp.X - 20))
					local h = math.clamp(startSize.Y.Offset + d.Y, 300, math.max(300, vp.Y - 20))
					Window._customSize = UDim2.new(0, w, 0, h)
					Main.Size = Window._customSize
				end
			end))
			TrackConn(UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					pcall(function() conn:Disconnect() end)
				end
			end))
		end
	end)

	ApplyResponsive()
	return Window
end

return KemplongXD
