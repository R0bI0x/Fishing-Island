--[[
    ModernUILib v3.0
    GUI Library untuk Roblox Executor (client-side script)
    - Responsif (auto-detect PC / Mobile / Tablet)
    - Draggable & Resizable window
    - Tab/Section sidebar navigation
    - Komponen: Button, Toggle, Slider, Dropdown, Textbox, Keybind, ColorPicker, Label, Paragraph
    - Notification system
    - Config save/load (writefile/readfile dengan pcall, aman kalau executor gak support)
    - Anti ZIndex bug (semua elemen pakai DisplayOrder + ZIndex terkontrol)
    - Theme system

    Cara pakai:
    local Library = loadstring(readfile("ModernUILib.lua"))()
    -- atau
    local Library = loadstring(game:HttpGet("URL_KAMU"))()
]]

local Library = {}
Library.__index = Library

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Players            = game:GetService("Players")
local CoreGui            = game:GetService("CoreGui")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local GuiService         = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------
-- SAFE CALLS (biar gak error di executor yang beda-beda)
------------------------------------------------------------
local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

local writefile   = writefile or function() end
local readfile    = readfile or function() return nil end
local isfile       = isfile or function() return false end
local makefolder  = makefolder or function() end
local isfolder     = isfolder or function() return false end

------------------------------------------------------------
-- DEVICE DETECTION (RESPONSIF)
------------------------------------------------------------
local function getDeviceType()
    local touch = UserInputService.TouchEnabled
    local mouse = UserInputService.MouseEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)

    if touch and not mouse and not keyboard then
        if viewport.X >= 1000 then
            return "Tablet"
        end
        return "Mobile"
    end
    return "PC"
end

local DeviceType = getDeviceType()

local function getScale()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local baseWidth = 1280
    local scale = math.clamp(viewport.X / baseWidth, 0.55, 1.15)
    if DeviceType == "Mobile" then
        scale = math.clamp(scale * 0.95, 0.55, 0.95)
    end
    return scale
end

------------------------------------------------------------
-- THEME
------------------------------------------------------------
local Theme = {
    Background      = Color3.fromRGB(24, 24, 28),
    Sidebar         = Color3.fromRGB(20, 20, 24),
    Section         = Color3.fromRGB(30, 30, 35),
    Element         = Color3.fromRGB(36, 36, 42),
    ElementHover    = Color3.fromRGB(44, 44, 52),
    Accent          = Color3.fromRGB(90, 120, 255),
    Text            = Color3.fromRGB(240, 240, 245),
    SubText         = Color3.fromRGB(160, 160, 170),
    Stroke          = Color3.fromRGB(50, 50, 58),
    Success         = Color3.fromRGB(80, 200, 120),
    Error           = Color3.fromRGB(230, 80, 80),
    Font            = Enum.Font.GothamMedium,
    FontBold        = Enum.Font.GothamBold,
}

local ThemePresets = {
    Dark = {
        Background = Color3.fromRGB(24, 24, 28), Sidebar = Color3.fromRGB(20, 20, 24),
        Section = Color3.fromRGB(30, 30, 35), Element = Color3.fromRGB(36, 36, 42),
        ElementHover = Color3.fromRGB(44, 44, 52), Accent = Color3.fromRGB(90, 120, 255),
        Text = Color3.fromRGB(240, 240, 245), SubText = Color3.fromRGB(160, 160, 170),
        Stroke = Color3.fromRGB(50, 50, 58),
    },
    Purple = {
        Background = Color3.fromRGB(22, 20, 28), Sidebar = Color3.fromRGB(18, 16, 24),
        Section = Color3.fromRGB(28, 26, 36), Element = Color3.fromRGB(34, 30, 44),
        ElementHover = Color3.fromRGB(42, 38, 54), Accent = Color3.fromRGB(150, 90, 255),
        Text = Color3.fromRGB(240, 238, 245), SubText = Color3.fromRGB(165, 160, 175),
        Stroke = Color3.fromRGB(52, 48, 62),
    },
    Emerald = {
        Background = Color3.fromRGB(18, 24, 22), Sidebar = Color3.fromRGB(15, 20, 18),
        Section = Color3.fromRGB(22, 30, 27), Element = Color3.fromRGB(28, 38, 34),
        ElementHover = Color3.fromRGB(34, 46, 41), Accent = Color3.fromRGB(60, 200, 140),
        Text = Color3.fromRGB(235, 245, 240), SubText = Color3.fromRGB(155, 175, 165),
        Stroke = Color3.fromRGB(42, 55, 49),
    },
    Crimson = {
        Background = Color3.fromRGB(26, 20, 20), Sidebar = Color3.fromRGB(21, 16, 16),
        Section = Color3.fromRGB(32, 24, 24), Element = Color3.fromRGB(40, 30, 30),
        ElementHover = Color3.fromRGB(48, 36, 36), Accent = Color3.fromRGB(235, 80, 90),
        Text = Color3.fromRGB(245, 238, 238), SubText = Color3.fromRGB(175, 158, 158),
        Stroke = Color3.fromRGB(58, 44, 44),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 248), Sidebar = Color3.fromRGB(235, 235, 240),
        Section = Color3.fromRGB(255, 255, 255), Element = Color3.fromRGB(255, 255, 255),
        ElementHover = Color3.fromRGB(230, 230, 236), Accent = Color3.fromRGB(80, 110, 235),
        Text = Color3.fromRGB(25, 25, 30), SubText = Color3.fromRGB(100, 100, 110),
        Stroke = Color3.fromRGB(210, 210, 218),
    },
}

-- Ganti tema global SEBELUM CreateWindow dipanggil (elemen baru akan pakai warna baru)
function Library:SetTheme(nameOrTable)
    local preset = type(nameOrTable) == "string" and ThemePresets[nameOrTable] or nameOrTable
    if not preset then return false end
    for k, v in pairs(preset) do
        Theme[k] = v
    end
    return true
end

function Library:GetThemeNames()
    local names = {}
    for k in pairs(ThemePresets) do table.insert(names, k) end
    return names
end

------------------------------------------------------------
-- UTILITY
------------------------------------------------------------
local function tween(obj, props, duration, style, direction)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(duration, style, direction), props)
    t:Play()
    return t
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function pad(obj, all)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, all)
    p.PaddingRight = UDim.new(0, all)
    p.PaddingTop = UDim.new(0, all)
    p.PaddingBottom = UDim.new(0, all)
    p.Parent = obj
    return p
end

local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local uidCounter = 0
local function genId()
    uidCounter += 1
    return "UILib_" .. uidCounter .. "_" .. tostring(math.random(1000, 9999))
end

------------------------------------------------------------
-- DRAGGABLE (support mouse + touch, anti-glitch)
------------------------------------------------------------
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragStart, startPos
    local dragInput

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        frame.Position = newPos
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

------------------------------------------------------------
-- ROOT GUI
------------------------------------------------------------
local function getGuiParent()
    if gethui then
        return safeCall(gethui) or CoreGui
    elseif syn and syn.protect_gui then
        return CoreGui
    end
    return CoreGui
end

------------------------------------------------------------
-- NOTIFICATION CONTAINER (dibuat sekali, global)
------------------------------------------------------------
local NotifHolder
local function ensureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return NotifHolder end
    local screenGui = make("ScreenGui", {
        Name = "ModernUILib_Notifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 999,
    }, getGuiParent())
    if syn and syn.protect_gui then safeCall(syn.protect_gui, screenGui) end

    NotifHolder = make("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 300, 1, -32),
    }, screenGui)

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, NotifHolder)

    return NotifHolder
end

function Library:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Notification"
    local content = opts.Content or ""
    local duration = opts.Duration or 4
    local notifType = opts.Type or "Info" -- Info, Success, Error

    local holder = ensureNotifHolder()

    local color = Theme.Accent
    if notifType == "Success" then color = Theme.Success end
    if notifType == "Error" then color = Theme.Error end

    local frame = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Section,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
    }, holder)
    corner(frame, 8)
    stroke(frame, Theme.Stroke, 1)
    pad(frame, 12)

    local accentBar = make("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
    }, frame)
    corner(accentBar, 2)

    local titleLbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 18),
        Position = UDim2.new(0, 12, 0, 0),
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local contentLbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 12, 0, 20),
        Font = Theme.Font,
        Text = content,
        TextColor3 = Theme.SubText,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    frame.BackgroundTransparency = 0
    frame.Size = UDim2.new(1, 0, 0, 0)
    task.wait()
    tween(frame, {BackgroundTransparency = 0}, 0.25)

    task.delay(duration, function()
        if frame and frame.Parent then
            local fade = tween(frame, {BackgroundTransparency = 1}, 0.25)
            fade.Completed:Wait()
            for _, c in pairs(frame:GetDescendants()) do
                if c:IsA("TextLabel") then tween(c, {TextTransparency = 1}, 0.2) end
                if c:IsA("UIStroke") then tween(c, {Transparency = 1}, 0.2) end
            end
            task.wait(0.2)
            frame:Destroy()
        end
    end)
end

------------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "ModernUILib"
    local windowSubtitle = config.Subtitle or ""
    local configFolder = config.ConfigFolder or "ModernUILib_Config"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    if not isfolder(configFolder) then
        safeCall(makefolder, configFolder)
    end

    local scale = getScale()
    local isMobileDevice = DeviceType == "Mobile"

    local screenGui = make("ScreenGui", {
        Name = "ModernUILib_" .. genId(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 100,
    }, getGuiParent())
    if syn and syn.protect_gui then safeCall(syn.protect_gui, screenGui) end

    local winWidth = isMobileDevice and 520 or 620
    local winHeight = isMobileDevice and 340 or 400

    local Main = make("Frame", {
        Name = "Main",
        Size = UDim2.new(0, winWidth, 0, winHeight),
        Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, screenGui)
    corner(Main, 10)
    stroke(Main, Theme.Stroke, 1)

    local scaleObj = make("UIScale", {Scale = scale}, Main)

    -- Top bar
    local TopBar = make("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
    }, Main)
    corner(TopBar, 10)
    local topFix = make("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
    }, TopBar)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 4),
        Size = UDim2.new(0.6, 0, 0, 20),
        Font = Theme.FontBold,
        Text = windowTitle,
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TopBar)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 22),
        Size = UDim2.new(0.6, 0, 0, 16),
        Font = Theme.Font,
        Text = windowSubtitle,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, TopBar)

    local CloseBtn = make("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0, 7),
        BackgroundColor3 = Theme.Element,
        Text = "X",
        Font = Theme.FontBold,
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false,
    }, TopBar)
    corner(CloseBtn, 6)
    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {BackgroundColor3 = Theme.Error}, 0.15) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {BackgroundColor3 = Theme.Element}, 0.15) end)

    local MinBtn = make("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -74, 0, 7),
        BackgroundColor3 = Theme.Element,
        Text = "-",
        Font = Theme.FontBold,
        TextColor3 = Theme.Text,
        TextSize = 18,
        AutoButtonColor = false,
    }, TopBar)
    corner(MinBtn, 6)
    MinBtn.MouseEnter:Connect(function() tween(MinBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15) end)
    MinBtn.MouseLeave:Connect(function() tween(MinBtn, {BackgroundColor3 = Theme.Element}, 0.15) end)

    makeDraggable(Main, TopBar)

    local Body -- forward declare, dipakai di closure minimize sebelum dibuat di bawah

    ----------------------------------------------------------------
    -- FLOATING SHOW/HIDE ICON (bubble draggable, opsional)
    -- Berguna terutama di mobile karena gak ada keyboard buat toggleKey.
    -- Matikan dengan config.FloatingIcon = false saat CreateWindow.
    ----------------------------------------------------------------
    local useFloatingIcon = config.FloatingIcon ~= false
    local IconGui, ToggleIcon
    local iconDragStartPos, iconMoved

    if useFloatingIcon then
        local iconSize = isMobileDevice and 46 or 42
        IconGui = make("ScreenGui", {
            Name = "ModernUILib_Icon_" .. genId(),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            DisplayOrder = 150,
        }, getGuiParent())
        if syn and syn.protect_gui then safeCall(syn.protect_gui, IconGui) end

        ToggleIcon = make("TextButton", {
            Name = "ToggleIcon",
            Size = UDim2.new(0, iconSize, 0, iconSize),
            Position = config.FloatingIconPosition or UDim2.new(1, -(iconSize + 14), 0.4, 0),
            BackgroundColor3 = Theme.Accent,
            Text = "",
            AutoButtonColor = false,
            Visible = false, -- muncul cuma pas GUI di-hide
            ZIndex = 50,
        }, IconGui)
        corner(ToggleIcon, iconSize / 2)
        stroke(ToggleIcon, Theme.Stroke, 1)

        make("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.FontBold,
            Text = config.FloatingIconText or "☰",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 18,
        }, ToggleIcon)

        makeDraggable(ToggleIcon, ToggleIcon)

        -- Bedakan drag vs tap: kalau mouse/finger gak geser jauh, anggap tap
        ToggleIcon.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                iconDragStartPos = input.Position
                iconMoved = false
            end
        end)
        ToggleIcon.InputChanged:Connect(function(input)
            if iconDragStartPos and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if (input.Position - iconDragStartPos).Magnitude > 6 then
                    iconMoved = true
                end
            end
        end)
    end

    local isMinimized = false
    local isHidden = false

    local function showWindow()
        isHidden = false
        screenGui.Enabled = true
        if ToggleIcon then ToggleIcon.Visible = false end
        Main.Size = UDim2.new(0, winWidth, 0, 0)
        tween(Main, {Size = UDim2.new(0, winWidth, 0, winHeight)}, 0.2)
    end

    local function hideWindow()
        tween(Main, {Size = UDim2.new(0, winWidth, 0, 0)}, 0.2)
        task.wait(0.2)
        screenGui.Enabled = false
        isHidden = true
        if ToggleIcon then ToggleIcon.Visible = true end
    end

    if ToggleIcon then
        ToggleIcon.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not iconMoved then
                    showWindow()
                end
                iconDragStartPos = nil
            end
        end)
    end

    CloseBtn.MouseButton1Click:Connect(function()
        hideWindow()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(Main, {Size = UDim2.new(0, winWidth, 0, 44)}, 0.2)
            task.delay(0.2, function()
                if isMinimized then Body.Visible = false end
            end)
            MinBtn.Text = "□"
        else
            Body.Visible = true
            tween(Main, {Size = UDim2.new(0, winWidth, 0, winHeight)}, 0.2)
            MinBtn.Text = "-"
        end
    end)

    -- Body: Sidebar (tabs) + Content
    Body = make("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
    }, Main)

    local sidebarWidth = isMobileDevice and 120 or 165
    local showSearch = config.ShowTabSearch ~= false
    local showFooter = config.ShowPlayerFooter ~= false
    local searchHeight = showSearch and 34 or 0
    local footerHeight = showFooter and 48 or 0

    local Sidebar = make("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarWidth, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
    }, Body)

    -- Search bar buat filter tab (kayak script hub kebanyakan)
    local SidebarSearchBox
    if showSearch then
        local SearchHolder = make("Frame", {
            Size = UDim2.new(1, -12, 0, searchHeight - 8),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
        }, Sidebar)
        corner(SearchHolder, 6)
        SidebarSearchBox = make("TextBox", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            PlaceholderText = "Cari fitur...",
            Text = "",
            Font = Theme.Font,
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.SubText,
            TextSize = 12,
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, SearchHolder)
    end

    local SidebarList = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -(searchHeight + footerHeight)),
        Position = UDim2.new(0, 0, 0, searchHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Sidebar)

    local sidebarLayout = make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, SidebarList)
    pad(SidebarList, 6)

    -- Footer: info player + nama game, kayak script hub pada umumnya
    if showFooter then
        local ok, userId = pcall(function() return LocalPlayer.UserId end)
        local thumb = ""
        if ok then
            local okThumb, content = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if okThumb then thumb = content end
        end

        local Footer = make("Frame", {
            Size = UDim2.new(1, 0, 0, footerHeight),
            Position = UDim2.new(0, 0, 1, -footerHeight),
            BackgroundColor3 = Theme.Section,
            BorderSizePixel = 0,
        }, Sidebar)

        local Avatar = make("ImageLabel", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 8, 0.5, -16),
            BackgroundColor3 = Theme.Element,
            Image = thumb,
        }, Footer)
        corner(Avatar, 16)

        make("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -48, 0, 16),
            Position = UDim2.new(0, 46, 0, 6),
            Font = Theme.FontBold,
            Text = LocalPlayer.DisplayName or LocalPlayer.Name,
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, Footer)

        make("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -48, 0, 14),
            Position = UDim2.new(0, 46, 0, 24),
            Font = Theme.Font,
            Text = "@" .. LocalPlayer.Name,
            TextColor3 = Theme.SubText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, Footer)
    end

    local ContentHolder = make("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -sidebarWidth, 1, 0),
        Position = UDim2.new(0, sidebarWidth, 0, 0),
        BackgroundTransparency = 1,
    }, Body)

    -- Toggle GUI visibility via key (PC) - tetap sinkron dengan floating icon
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            if isHidden then
                showWindow()
            else
                hideWindow()
            end
        end
    end)

    -- RESIZE HANDLE (pojok kanan-bawah, drag buat ubah ukuran window)
    if config.Resizable ~= false then
        local ResizeHandle = make("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -18, 1, -18),
            BackgroundTransparency = 1,
            ZIndex = 5,
        }, Main)
        local grip = make("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "◢",
            Font = Theme.FontBold,
            TextColor3 = Theme.SubText,
            TextSize = 14,
            Rotation = 0,
        }, ResizeHandle)

        local resizing = false
        local startMousePos, startSize
        local minW, minH = 420, 260
        local maxW, maxH = 900, 650

        ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                startMousePos = input.Position
                startSize = Main.Size
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startMousePos
                local newW = math.clamp(startSize.X.Offset + delta.X, minW, maxW)
                local newH = math.clamp(startSize.Y.Offset + delta.Y, minH, maxH)
                Main.Size = UDim2.new(0, newW, 0, newH)
            end
        end)
    end

    local Window = {
        ScreenGui = screenGui,
        IconGui = IconGui,
        Main = Main,
        Tabs = {},
        ConfigFolder = configFolder,
        FlagValues = {},
        FlagCallbacks = {},
        _firstTab = nil,
        _tabSearchMap = {},
        _closeOpenPopup = nil,
    }

    function Window:Show() showWindow() end
    function Window:Hide() hideWindow() end
    function Window:Minimize()
        isMinimized = not isMinimized
        if isMinimized then
            tween(Main, {Size = UDim2.new(0, winWidth, 0, 44)}, 0.2)
            task.delay(0.2, function() if isMinimized then Body.Visible = false end end)
            MinBtn.Text = "□"
        else
            Body.Visible = true
            tween(Main, {Size = UDim2.new(0, winWidth, 0, winHeight)}, 0.2)
            MinBtn.Text = "-"
        end
    end
    function Window:Destroy()
        screenGui:Destroy()
        if IconGui then IconGui:Destroy() end
    end

    if SidebarSearchBox then
        SidebarSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = SidebarSearchBox.Text:lower()
            local groupHasMatch = {} -- [groupLabel instance] = true kalau ada minimal 1 tab match di grup itu

            for _, entry in ipairs(Window._tabSearchMap) do
                local match = (q == "" or entry.name:lower():find(q, 1, true)) and true or false
                entry.button.Visible = match
                if entry.currentGroupLabel and match then
                    groupHasMatch[entry.currentGroupLabel] = true
                end
            end

            for _, entry in ipairs(Window._tabSearchMap) do
                if entry.groupLabel then
                    entry.groupLabel.Visible = groupHasMatch[entry.groupLabel] or false
                end
            end
        end)
    end

    ----------------------------------------------------------------
    -- TAB
    ----------------------------------------------------------------
    Window._tabOrder = Window._tabOrder or 0
    Window._lastGroup = Window._lastGroup or nil

    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local icon = tabConfig.Icon -- asset id (rbxassetid://...) atau emoji/teks singkat
        local group = tabConfig.Group -- kategori, kalau beda dari tab sebelumnya bakal muncul header baru

        local groupLabel
        if group and group ~= Window._lastGroup then
            Window._tabOrder = Window._tabOrder + 1
            groupLabel = make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Theme.FontBold,
                Text = group:upper(),
                TextColor3 = Theme.SubText,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = Window._tabOrder,
            }, SidebarList)
            Window._lastGroup = group
            Window._lastGroupLabelInstance = groupLabel
        end
        local currentGroupLabel = group and Window._lastGroupLabelInstance or nil

        Window._tabOrder = Window._tabOrder + 1

        local TabBtn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Element,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = Window._tabOrder,
        }, SidebarList)
        corner(TabBtn, 6)

        local iconOffset = 12
        if icon then
            iconOffset = 34
            if tostring(icon):match("^rbxassetid://") or tostring(icon):match("^rbxthumb://") then
                make("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 10, 0.5, -8),
                    Image = icon,
                    ImageColor3 = Theme.SubText,
                }, TabBtn)
            else
                make("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 10, 0.5, -9),
                    Font = Theme.Font,
                    Text = tostring(icon),
                    TextSize = 14,
                    TextColor3 = Theme.SubText,
                }, TabBtn)
            end
        end

        make("TextLabel", {
            Name = "TabLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -(iconOffset + 6), 1, 0),
            Position = UDim2.new(0, iconOffset, 0, 0),
            Font = Theme.Font,
            Text = tabName,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, TabBtn)

        table.insert(Window._tabSearchMap, {name = tabName, button = TabBtn, groupLabel = groupLabel, currentGroupLabel = currentGroupLabel})

        local Page = make("ScrollingFrame", {
            Name = tabName .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ClipsDescendants = false, -- biar popup dropdown/colorpicker gak ke-crop pas dekat batas bawah scroll
            Visible = false,
        }, ContentHolder)
        pad(Page, 12)
        make("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, Page)

        local Tab = {Button = TabBtn, Page = Page}

        local function selectTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                tween(t.Button, {BackgroundColor3 = Theme.Element}, 0.15)
                local lbl = t.Button:FindFirstChild("TabLabel")
                if lbl then tween(lbl, {TextColor3 = Theme.SubText}, 0.15) end
            end
            Page.Visible = true
            tween(TabBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
            local lbl = TabBtn:FindFirstChild("TabLabel")
            if lbl then tween(lbl, {TextColor3 = Color3.new(1,1,1)}, 0.15) end
        end

        TabBtn.MouseButton1Click:Connect(selectTab)
        TabBtn.MouseEnter:Connect(function()
            if not Page.Visible then tween(TabBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not Page.Visible then tween(TabBtn, {BackgroundColor3 = Theme.Element}, 0.15) end
        end)

        if not Window._firstTab then
            Window._firstTab = true
            selectTab()
        end

        ----------------------------------------------------------------
        -- ELEMENTS
        ----------------------------------------------------------------
        local function newElementBase(height)
            local Holder = make("Frame", {
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
            }, Page)
            corner(Holder, 6)
            return Holder
        end

        -- LABEL
        function Tab:CreateLabel(text)
            local Holder = newElementBase(28)
            Holder.BackgroundTransparency = 1
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.SubText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
            }, Holder)
            return Holder
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(title, content)
            local Holder = newElementBase(0)
            Holder.AutomaticSize = Enum.AutomaticSize.Y
            pad(Holder, 10)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = Theme.FontBold,
                Text = title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 20),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = Theme.Font,
                Text = content,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)
            return Holder
        end

        -- BUTTON
        function Tab:CreateButton(opts)
            opts = opts or {}
            local text = opts.Name or "Button"
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            local Btn = make("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Theme.Font,
                TextColor3 = Theme.Text,
                TextSize = 13,
            }, Holder)

            Btn.MouseEnter:Connect(function() tween(Holder, {BackgroundColor3 = Theme.ElementHover}, 0.15) end)
            Btn.MouseLeave:Connect(function() tween(Holder, {BackgroundColor3 = Theme.Element}, 0.15) end)
            Btn.MouseButton1Click:Connect(function()
                tween(Holder, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.wait(0.1)
                tween(Holder, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                local ok, err = pcall(callback)
                if not ok then
                    warn("[ModernUILib] Button callback error: " .. tostring(err))
                end
            end)
            return {Instance = Holder}
        end

        -- TOGGLE
        function Tab:CreateToggle(opts)
            opts = opts or {}
            local text = opts.Name or "Toggle"
            local default = opts.Default or false
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local Switch = make("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = default and Theme.Accent or Theme.Sidebar,
                BorderSizePixel = 0,
            }, Holder)
            corner(Switch, 10)

            local Dot = make("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
            }, Switch)
            corner(Dot, 8)

            local ClickArea = make("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
            }, Holder)

            local state = default
            Window.FlagValues[flag] = state

            local function setState(newState, fireCallback)
                state = newState
                Window.FlagValues[flag] = state
                tween(Switch, {BackgroundColor3 = state and Theme.Accent or Theme.Sidebar}, 0.15)
                tween(Dot, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.15)
                if fireCallback ~= false then
                    local ok, err = pcall(callback, state)
                    if not ok then warn("[ModernUILib] Toggle callback error: " .. tostring(err)) end
                end
            end

            ClickArea.MouseButton1Click:Connect(function()
                setState(not state)
            end)

            Window.FlagCallbacks[flag] = setState
            return {
                Instance = Holder,
                Set = function(_, v) setState(v) end,
                Get = function() return state end,
            }
        end

        -- SLIDER
        function Tab:CreateSlider(opts)
            opts = opts or {}
            local text = opts.Name or "Slider"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = math.clamp(opts.Default or min, min, max)
            local decimals = opts.Decimals or 0
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(46)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 12, 0, 4),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local ValueLbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -60, 0, 4),
                Font = Theme.Font,
                Text = tostring(default),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, Holder)

            local Track = make("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
            }, Holder)
            corner(Track, 3)

            local function ratio(v) return (v - min) / math.max(max - min, 1e-6) end

            local Fill = make("Frame", {
                Size = UDim2.new(ratio(default), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
            }, Track)
            corner(Fill, 3)

            local dragging = false
            local value = default
            Window.FlagValues[flag] = value

            local function round(n)
                local mult = 10 ^ decimals
                return math.floor(n * mult + 0.5) / mult
            end

            local function setFromInputX(x)
                local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local newVal = round(min + (max - min) * rel)
                value = newVal
                Window.FlagValues[flag] = value
                Fill.Size = UDim2.new(ratio(value), 0, 1, 0)
                ValueLbl.Text = tostring(value)
                local ok, err = pcall(callback, value)
                if not ok then warn("[ModernUILib] Slider callback error: " .. tostring(err)) end
            end

            local inputCatcher = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 1, -20),
                BackgroundTransparency = 1,
                Text = "",
            }, Holder)

            inputCatcher.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    setFromInputX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    setFromInputX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            local function setValue(v)
                v = math.clamp(v, min, max)
                value = round(v)
                Window.FlagValues[flag] = value
                Fill.Size = UDim2.new(ratio(value), 0, 1, 0)
                ValueLbl.Text = tostring(value)
            end

            Window.FlagCallbacks[flag] = setValue
            return {
                Instance = Holder,
                Set = function(_, v) setValue(v) end,
                Get = function() return value end,
            }
        end

        -- DROPDOWN
        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local text = opts.Name or "Dropdown"
            local list = opts.Options or {}
            local default = opts.Default
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end
            local multi = opts.Multi or false

            local Holder = newElementBase(36)
            Holder.ClipsDescendants = false

            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local SelectBtn = make("TextButton", {
                Size = UDim2.new(0.5, -12, 0, 26),
                Position = UDim2.new(0.5, 0, 0.5, -13),
                BackgroundColor3 = Theme.Sidebar,
                Text = "  " .. tostring(default or "Select..."),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.Font,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 5,
            }, Holder)
            corner(SelectBtn, 6)

            local OptionsFrame = make("Frame", {
                Size = UDim2.new(0.5, -12, 0, 0),
                Position = UDim2.new(0.5, 0, 1, 2),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 10,
            }, Holder)
            corner(OptionsFrame, 6)
            stroke(OptionsFrame, Theme.Stroke, 1)

            local OptList = make("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, OptionsFrame)

            local selected = multi and {} or default
            Window.FlagValues[flag] = selected

            local function refreshLabel()
                if multi then
                    local names = {}
                    for k, v in pairs(selected) do
                        if v then table.insert(names, k) end
                    end
                    SelectBtn.Text = "  " .. (#names > 0 and table.concat(names, ", ") or "Select...")
                else
                    SelectBtn.Text = "  " .. tostring(selected or "Select...")
                end
            end

            local open = false
            local function closeDropdown()
                open = false
                tween(OptionsFrame, {Size = UDim2.new(0.5, -12, 0, 0)}, 0.15)
                task.delay(0.15, function() OptionsFrame.Visible = false end)
                if Window._closeOpenPopup == closeDropdown then Window._closeOpenPopup = nil end
            end

            local function rebuildOptions()
                for _, c in pairs(OptionsFrame:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, opt in ipairs(list) do
                    local isSelected = multi and selected[opt] or (selected == opt)
                    local OptBtn = make("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = isSelected and Theme.Accent or Theme.Sidebar,
                        Text = "  " .. tostring(opt),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Theme.Font,
                        TextColor3 = isSelected and Color3.new(1,1,1) or Theme.SubText,
                        TextSize = 12,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex = 11,
                    }, OptionsFrame)
                    OptBtn.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt]
                        else
                            selected = opt
                            closeDropdown()
                        end
                        Window.FlagValues[flag] = selected
                        refreshLabel()
                        rebuildOptions()
                        local ok, err = pcall(callback, selected)
                        if not ok then warn("[ModernUILib] Dropdown callback error: " .. tostring(err)) end
                    end)
                end
            end
            rebuildOptions()
            refreshLabel()

            SelectBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    if Window._closeOpenPopup and Window._closeOpenPopup ~= closeDropdown then
                        Window._closeOpenPopup()
                    end
                    Window._closeOpenPopup = closeDropdown
                    OptionsFrame.Visible = true
                    local h = math.min(#list * 26, 130)
                    tween(OptionsFrame, {Size = UDim2.new(0.5, -12, 0, h)}, 0.15)
                else
                    closeDropdown()
                    if Window._closeOpenPopup == closeDropdown then Window._closeOpenPopup = nil end
                end
            end)

            return {
                Instance = Holder,
                Set = function(_, v) selected = v; Window.FlagValues[flag] = v; refreshLabel(); rebuildOptions() end,
                Get = function() return selected end,
                Refresh = function(_, newList) list = newList; rebuildOptions() end,
            }
        end

        -- TEXTBOX
        function Tab:CreateTextbox(opts)
            opts = opts or {}
            local text = opts.Name or "Textbox"
            local placeholder = opts.Placeholder or "Enter text..."
            local default = opts.Default or ""
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local Box = make("TextBox", {
                Size = UDim2.new(0.6, -12, 0, 26),
                Position = UDim2.new(0.4, 0, 0.5, -13),
                BackgroundColor3 = Theme.Sidebar,
                Text = default,
                PlaceholderText = placeholder,
                Font = Theme.Font,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                TextSize = 12,
                ClearTextOnFocus = false,
            }, Holder)
            corner(Box, 6)
            pad(Box, 8)

            Window.FlagValues[flag] = default

            Box.FocusLost:Connect(function(enterPressed)
                Window.FlagValues[flag] = Box.Text
                local ok, err = pcall(callback, Box.Text, enterPressed)
                if not ok then warn("[ModernUILib] Textbox callback error: " .. tostring(err)) end
            end)

            return {
                Instance = Holder,
                Set = function(_, v) Box.Text = v; Window.FlagValues[flag] = v end,
                Get = function() return Box.Text end,
            }
        end

        -- KEYBIND
        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local text = opts.Name or "Keybind"
            local default = opts.Default or Enum.KeyCode.Unknown
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local BindBtn = make("TextButton", {
                Size = UDim2.new(0, 80, 0, 26),
                Position = UDim2.new(1, -90, 0.5, -13),
                BackgroundColor3 = Theme.Sidebar,
                Text = default.Name,
                Font = Theme.Font,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                AutoButtonColor = false,
            }, Holder)
            corner(BindBtn, 6)

            local currentKey = default
            local binding = false
            Window.FlagValues[flag] = currentKey

            BindBtn.MouseButton1Click:Connect(function()
                binding = true
                BindBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        Window.FlagValues[flag] = currentKey
                        binding = false
                    end
                    return
                end
                if gpe then return end
                if input.KeyCode == currentKey then
                    local ok, err = pcall(callback)
                    if not ok then warn("[ModernUILib] Keybind callback error: " .. tostring(err)) end
                end
            end)

            return {
                Instance = Holder,
                Set = function(_, keycode) currentKey = keycode; BindBtn.Text = keycode.Name; Window.FlagValues[flag] = keycode end,
                Get = function() return currentKey end,
            }
        end

        -- COLOR PICKER (simple HSV via 2 sliders + swatch)
        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local text = opts.Name or "Color"
            local default = opts.Default or Color3.fromRGB(255, 255, 255)
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local Swatch = make("TextButton", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -50, 0.5, -11),
                BackgroundColor3 = default,
                Text = "",
                AutoButtonColor = false,
            }, Holder)
            corner(Swatch, 5)
            stroke(Swatch, Theme.Stroke, 1)

            local Popup = make("Frame", {
                Size = UDim2.new(0, 160, 0, 120),
                Position = UDim2.new(1, -170, 1, 4),
                BackgroundColor3 = Theme.Sidebar,
                Visible = false,
                ZIndex = 20,
            }, Holder)
            corner(Popup, 6)
            stroke(Popup, Theme.Stroke, 1)
            pad(Popup, 8)

            local currentColor = default
            Window.FlagValues[flag] = currentColor

            local function makeChannelSlider(labelText, order, initial, onChange)
                local Row = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    LayoutOrder = order,
                }, Popup)
                make("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 14),
                    Font = Theme.Font,
                    Text = labelText,
                    TextColor3 = Theme.SubText,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, Row)
                local Track = make("Frame", {
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0, 20, 0, 4),
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                }, Row)
                corner(Track, 3)
                local Fill = make("Frame", {
                    Size = UDim2.new(initial, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                }, Track)
                corner(Fill, 3)
                local Catcher = make("TextButton", {
                    Size = UDim2.new(1, 0, 1, 8),
                    Position = UDim2.new(0, 0, 0, -4),
                    BackgroundTransparency = 1,
                    Text = "",
                }, Track)
                local dragging = false
                Catcher.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        Fill.Size = UDim2.new(rel, 0, 1, 0)
                        onChange(rel)
                    end
                end)
            end

            local h, s, v = Color3.toHSV(default)
            local function updateColor()
                currentColor = Color3.fromHSV(h, s, v)
                Swatch.BackgroundColor3 = currentColor
                Window.FlagValues[flag] = currentColor
                local ok, err = pcall(callback, currentColor)
                if not ok then warn("[ModernUILib] ColorPicker callback error: " .. tostring(err)) end
            end

            makeChannelSlider("H", 1, h, function(rel) h = rel; updateColor() end)
            makeChannelSlider("S", 2, s, function(rel) s = rel; updateColor() end)
            makeChannelSlider("V", 3, v, function(rel) v = rel; updateColor() end)
            make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Popup)

            local function closeColorPopup()
                Popup.Visible = false
                if Window._closeOpenPopup == closeColorPopup then Window._closeOpenPopup = nil end
            end

            Swatch.MouseButton1Click:Connect(function()
                if Popup.Visible then
                    closeColorPopup()
                else
                    if Window._closeOpenPopup and Window._closeOpenPopup ~= closeColorPopup then
                        Window._closeOpenPopup()
                    end
                    Window._closeOpenPopup = closeColorPopup
                    Popup.Visible = true
                end
            end)

            return {
                Instance = Holder,
                Set = function(_, c) currentColor = c; Swatch.BackgroundColor3 = c; Window.FlagValues[flag] = c end,
                Get = function() return currentColor end,
            }
        end

        -- DIVIDER
        function Tab:CreateDivider()
            local Holder = make("Frame", {
                Size = UDim2.new(1, 0, 0, 9),
                BackgroundTransparency = 1,
            }, Page)
            make("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
            }, Holder)
            return {Instance = Holder}
        end

        -- SPACER
        function Tab:CreateSpacer(size)
            local Holder = make("Frame", {
                Size = UDim2.new(1, 0, 0, size or 8),
                BackgroundTransparency = 1,
            }, Page)
            return {Instance = Holder}
        end

        -- SECTION (header pemisah kelompok elemen, bukan tab baru)
        function Tab:CreateSection(text)
            local Holder = make("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
            }, Page)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 4),
                Font = Theme.FontBold,
                Text = text,
                TextColor3 = Theme.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)
            return {Instance = Holder}
        end

        -- IMAGE
        function Tab:CreateImage(opts)
            opts = opts or {}
            local imageId = opts.Image or ""
            local height = opts.Height or 140

            local Holder = newElementBase(height)
            local Img = make("ImageLabel", {
                Size = UDim2.new(1, -16, 1, -16),
                Position = UDim2.new(0, 8, 0, 8),
                BackgroundTransparency = 1,
                Image = imageId,
                ScaleType = Enum.ScaleType.Fit,
            }, Holder)
            corner(Img, 6)
            return {
                Instance = Holder,
                SetImage = function(_, id) Img.Image = id end,
            }
        end

        -- PROGRESS BAR (read-only, dikontrol via :Set)
        function Tab:CreateProgressBar(opts)
            opts = opts or {}
            local text = opts.Name or "Progress"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = math.clamp(opts.Default or min, min, max)

            local Holder = newElementBase(46)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 12, 0, 4),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local ValueLbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 4),
                Font = Theme.Font,
                Text = tostring(default) .. "/" .. tostring(max),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, Holder)

            local Track = make("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
            }, Holder)
            corner(Track, 3)

            local function ratio(v) return math.clamp((v - min) / math.max(max - min, 1e-6), 0, 1) end

            local Fill = make("Frame", {
                Size = UDim2.new(ratio(default), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
            }, Track)
            corner(Fill, 3)

            local value = default
            local function setValue(v)
                v = math.clamp(v, min, max)
                value = v
                tween(Fill, {Size = UDim2.new(ratio(value), 0, 1, 0)}, 0.15)
                ValueLbl.Text = tostring(math.floor(value)) .. "/" .. tostring(max)
            end

            return {
                Instance = Holder,
                Set = function(_, v) setValue(v) end,
                Get = function() return value end,
            }
        end

        -- TOGGLE + KEYBIND gabungan (toggle switch dengan bind tombol di sampingnya)
        function Tab:CreateToggleKeybind(opts)
            opts = opts or {}
            local text = opts.Name or "Toggle"
            local default = opts.Default or false
            local defaultKey = opts.DefaultKey or Enum.KeyCode.Unknown
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -140, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local BindBtn = make("TextButton", {
                Size = UDim2.new(0, 70, 0, 24),
                Position = UDim2.new(1, -120, 0.5, -12),
                BackgroundColor3 = Theme.Sidebar,
                Text = defaultKey.Name,
                Font = Theme.Font,
                TextColor3 = Theme.SubText,
                TextSize = 11,
                AutoButtonColor = false,
            }, Holder)
            corner(BindBtn, 6)

            local Switch = make("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -44, 0.5, -10),
                BackgroundColor3 = default and Theme.Accent or Theme.Sidebar,
                BorderSizePixel = 0,
            }, Holder)
            corner(Switch, 10)
            local Dot = make("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
            }, Switch)
            corner(Dot, 8)

            local state = default
            local currentKey = defaultKey
            Window.FlagValues[flag] = state

            local function setState(newState)
                state = newState
                Window.FlagValues[flag] = state
                tween(Switch, {BackgroundColor3 = state and Theme.Accent or Theme.Sidebar}, 0.15)
                tween(Dot, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.15)
                local ok, err = pcall(callback, state)
                if not ok then warn("[ModernUILib] ToggleKeybind callback error: " .. tostring(err)) end
            end

            local ClickArea = make("TextButton", {
                Size = UDim2.new(1, -130, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
            }, Holder)
            ClickArea.MouseButton1Click:Connect(function() setState(not state) end)

            local binding = false
            BindBtn.MouseButton1Click:Connect(function()
                binding = true
                BindBtn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        binding = false
                    end
                    return
                end
                if gpe then return end
                if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                    setState(not state)
                end
            end)

            Window.FlagCallbacks[flag] = setState
            return {
                Instance = Holder,
                Set = function(_, v) setState(v) end,
                Get = function() return state end,
                GetKey = function() return currentKey end,
            }
        end

        -- SEARCH DROPDOWN (dropdown dengan kotak pencarian, cocok buat list panjang)
        function Tab:CreateSearchDropdown(opts)
            opts = opts or {}
            local text = opts.Name or "Search Dropdown"
            local list = opts.Options or {}
            local default = opts.Default
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            Holder.ClipsDescendants = false

            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local SelectBtn = make("TextButton", {
                Size = UDim2.new(0.6, -12, 0, 26),
                Position = UDim2.new(0.4, 0, 0.5, -13),
                BackgroundColor3 = Theme.Sidebar,
                Text = "  " .. tostring(default or "Select..."),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Theme.Font,
                TextColor3 = Theme.SubText,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 5,
            }, Holder)
            corner(SelectBtn, 6)

            local Popup = make("Frame", {
                Size = UDim2.new(0.6, -12, 0, 0),
                Position = UDim2.new(0.4, 0, 1, 2),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 10,
            }, Holder)
            corner(Popup, 6)
            stroke(Popup, Theme.Stroke, 1)

            local SearchBox = make("TextBox", {
                Size = UDim2.new(1, -8, 0, 24),
                Position = UDim2.new(0, 4, 0, 4),
                BackgroundColor3 = Theme.Element,
                PlaceholderText = "Cari...",
                Text = "",
                Font = Theme.Font,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                TextSize = 12,
                ZIndex = 11,
                ClearTextOnFocus = false,
            }, Popup)
            corner(SearchBox, 5)
            pad(SearchBox, 6)

            local OptionsFrame = make("ScrollingFrame", {
                Size = UDim2.new(1, -8, 1, -32),
                Position = UDim2.new(0, 4, 0, 30),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 11,
            }, Popup)
            make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, OptionsFrame)

            local selected = default
            Window.FlagValues[flag] = selected
            local open = false

            local function closeDropdown()
                open = false
                tween(Popup, {Size = UDim2.new(0.6, -12, 0, 0)}, 0.15)
                task.delay(0.15, function() Popup.Visible = false end)
                if Window._closeOpenPopup == closeDropdown then Window._closeOpenPopup = nil end
            end

            local function rebuildOptions(filter)
                for _, c in pairs(OptionsFrame:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                filter = filter and filter:lower() or ""
                local count = 0
                for i, opt in ipairs(list) do
                    if filter == "" or tostring(opt):lower():find(filter, 1, true) then
                        count += 1
                        local isSelected = selected == opt
                        local OptBtn = make("TextButton", {
                            Size = UDim2.new(1, 0, 0, 24),
                            BackgroundColor3 = isSelected and Theme.Accent or Theme.Element,
                            Text = "  " .. tostring(opt),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Font = Theme.Font,
                            TextColor3 = isSelected and Color3.new(1,1,1) or Theme.SubText,
                            TextSize = 12,
                            AutoButtonColor = false,
                            LayoutOrder = i,
                            ZIndex = 11,
                        }, OptionsFrame)
                        corner(OptBtn, 4)
                        OptBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            Window.FlagValues[flag] = selected
                            SelectBtn.Text = "  " .. tostring(selected)
                            closeDropdown()
                            rebuildOptions("")
                            local ok, err = pcall(callback, selected)
                            if not ok then warn("[ModernUILib] SearchDropdown callback error: " .. tostring(err)) end
                        end)
                    end
                end
                return count
            end
            rebuildOptions("")

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                rebuildOptions(SearchBox.Text)
            end)

            SelectBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    if Window._closeOpenPopup and Window._closeOpenPopup ~= closeDropdown then
                        Window._closeOpenPopup()
                    end
                    Window._closeOpenPopup = closeDropdown
                    Popup.Visible = true
                    local h = math.min(#list * 24 + 34, 160)
                    tween(Popup, {Size = UDim2.new(0.6, -12, 0, h)}, 0.15)
                else
                    closeDropdown()
                end
            end)

            return {
                Instance = Holder,
                Set = function(_, v) selected = v; Window.FlagValues[flag] = v; SelectBtn.Text = "  " .. tostring(v) end,
                Get = function() return selected end,
                Refresh = function(_, newList) list = newList; rebuildOptions(SearchBox.Text) end,
            }
        end

        -- INPUT GROUP (beberapa textbox angka berdampingan, contoh: X / Y / Z)
        function Tab:CreateInputGroup(opts)
            opts = opts or {}
            local text = opts.Name or "Input Group"
            local fields = opts.Fields or {"X", "Y", "Z"}
            local defaults = opts.Defaults or {}
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end
            local numbersOnly = opts.NumbersOnly ~= false

            local Holder = newElementBase(56)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -24, 0, 18),
                Position = UDim2.new(0, 12, 0, 4),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local Row = make("Frame", {
                Size = UDim2.new(1, -24, 0, 26),
                Position = UDim2.new(0, 12, 0, 24),
                BackgroundTransparency = 1,
            }, Holder)
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, Row)

            local values = {}
            local boxes = {}
            local fieldCount = math.max(#fields, 1)
            local fieldWidth = (1 / fieldCount)

            for i, fname in ipairs(fields) do
                local FieldHolder = make("Frame", {
                    Size = UDim2.new(fieldWidth, -4, 1, 0),
                    BackgroundColor3 = Theme.Sidebar,
                    LayoutOrder = i,
                }, Row)
                corner(FieldHolder, 5)
                local Box = make("TextBox", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(defaults[i] or defaults[fname] or ""),
                    PlaceholderText = fname,
                    Font = Theme.Font,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.SubText,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                }, FieldHolder)
                pad(Box, 6)
                values[fname] = defaults[i] or defaults[fname]
                boxes[fname] = Box

                Box.FocusLost:Connect(function()
                    local val = Box.Text
                    if numbersOnly then
                        val = tonumber(val)
                        if val == nil and Box.Text ~= "" then
                            Box.Text = tostring(values[fname] or "")
                            return
                        end
                    end
                    values[fname] = val
                    Window.FlagValues[flag] = values
                    local ok, err = pcall(callback, values)
                    if not ok then warn("[ModernUILib] InputGroup callback error: " .. tostring(err)) end
                end)
            end

            Window.FlagValues[flag] = values

            return {
                Instance = Holder,
                Set = function(_, fname, v)
                    values[fname] = v
                    if boxes[fname] then boxes[fname].Text = tostring(v) end
                    Window.FlagValues[flag] = values
                end,
                Get = function() return values end,
            }
        end

        -- RADIO GROUP (single-select, tampil semua opsi sekaligus)
        function Tab:CreateRadioGroup(opts)
            opts = opts or {}
            local text = opts.Name or "Radio Group"
            local list = opts.Options or {}
            local default = opts.Default
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local rowHeight = 24
            local Holder = newElementBase(20 + (#list * rowHeight) + 8)
            pad(Holder, 10)

            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local ListHolder = make("Frame", {
                Size = UDim2.new(1, 0, 0, #list * rowHeight),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1,
            }, Holder)
            make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, ListHolder)

            local selected = default
            Window.FlagValues[flag] = selected
            local circles = {}

            local function refresh()
                for opt, circle in pairs(circles) do
                    local isSel = (opt == selected)
                    tween(circle.Dot, {BackgroundTransparency = isSel and 0 or 1}, 0.1)
                    circle.Outline.BackgroundColor3 = isSel and Theme.Accent or Theme.Stroke
                end
            end

            for i, opt in ipairs(list) do
                local Row = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, rowHeight),
                    BackgroundTransparency = 1,
                    Text = "",
                    LayoutOrder = i,
                }, ListHolder)

                local Outline = make("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, -8),
                    BackgroundColor3 = (opt == selected) and Theme.Accent or Theme.Stroke,
                    BorderSizePixel = 0,
                }, Row)
                corner(Outline, 8)
                local Inner = make("Frame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = Theme.Sidebar,
                    BorderSizePixel = 0,
                }, Outline)
                corner(Inner, 8)
                local Dot = make("Frame", {
                    Size = UDim2.new(1, -8, 1, -8),
                    Position = UDim2.new(0, 4, 0, 4),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = (opt == selected) and 0 or 1,
                    BorderSizePixel = 0,
                }, Inner)
                corner(Dot, 8)

                make("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 24, 0, 0),
                    Font = Theme.Font,
                    Text = tostring(opt),
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, Row)

                circles[opt] = {Dot = Dot, Outline = Outline}

                Row.MouseButton1Click:Connect(function()
                    selected = opt
                    Window.FlagValues[flag] = selected
                    refresh()
                    local ok, err = pcall(callback, selected)
                    if not ok then warn("[ModernUILib] RadioGroup callback error: " .. tostring(err)) end
                end)
            end

            return {
                Instance = Holder,
                Set = function(_, v) selected = v; Window.FlagValues[flag] = v; refresh() end,
                Get = function() return selected end,
            }
        end

        -- CHECKBOX LIST (multi-select, tampil semua opsi sekaligus)
        function Tab:CreateCheckboxList(opts)
            opts = opts or {}
            local text = opts.Name or "Checkbox List"
            local list = opts.Options or {}
            local defaults = opts.Defaults or {}
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local rowHeight = 24
            local Holder = newElementBase(20 + (#list * rowHeight) + 8)
            pad(Holder, 10)

            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local ListHolder = make("Frame", {
                Size = UDim2.new(1, 0, 0, #list * rowHeight),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1,
            }, Holder)
            make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, ListHolder)

            local state = {}
            for _, opt in ipairs(list) do state[opt] = defaults[opt] or false end
            Window.FlagValues[flag] = state

            for i, opt in ipairs(list) do
                local Row = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, rowHeight),
                    BackgroundTransparency = 1,
                    Text = "",
                    LayoutOrder = i,
                }, ListHolder)

                local Box = make("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, -8),
                    BackgroundColor3 = state[opt] and Theme.Accent or Theme.Sidebar,
                    BorderSizePixel = 0,
                }, Row)
                corner(Box, 4)
                stroke(Box, Theme.Stroke, 1)

                local Check = make("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "✓",
                    Font = Theme.FontBold,
                    TextColor3 = Color3.new(1,1,1),
                    TextSize = 12,
                    TextTransparency = state[opt] and 0 or 1,
                }, Box)

                make("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 24, 0, 0),
                    Font = Theme.Font,
                    Text = tostring(opt),
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, Row)

                Row.MouseButton1Click:Connect(function()
                    state[opt] = not state[opt]
                    Window.FlagValues[flag] = state
                    tween(Box, {BackgroundColor3 = state[opt] and Theme.Accent or Theme.Sidebar}, 0.15)
                    tween(Check, {TextTransparency = state[opt] and 0 or 1}, 0.15)
                    local ok, err = pcall(callback, state)
                    if not ok then warn("[ModernUILib] CheckboxList callback error: " .. tostring(err)) end
                end)
            end

            return {
                Instance = Holder,
                Get = function() return state end,
                Set = function(_, opt, v) state[opt] = v; Window.FlagValues[flag] = state end,
            }
        end

        -- STEPPER (input angka dengan tombol +/-)
        function Tab:CreateStepper(opts)
            opts = opts or {}
            local text = opts.Name or "Stepper"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local step = opts.Step or 1
            local default = math.clamp(opts.Default or min, min, max)
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(36)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -140, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local MinusBtn = make("TextButton", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -120, 0.5, -12),
                BackgroundColor3 = Theme.Sidebar,
                Text = "-",
                Font = Theme.FontBold,
                TextColor3 = Theme.Text,
                TextSize = 16,
                AutoButtonColor = false,
            }, Holder)
            corner(MinusBtn, 5)

            local ValueBox = make("TextBox", {
                Size = UDim2.new(0, 56, 0, 24),
                Position = UDim2.new(1, -92, 0.5, -12),
                BackgroundColor3 = Theme.Sidebar,
                Text = tostring(default),
                Font = Theme.Font,
                TextColor3 = Theme.Text,
                TextSize = 12,
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Center,
            }, Holder)
            corner(ValueBox, 5)

            local PlusBtn = make("TextButton", {
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -32, 0.5, -12),
                BackgroundColor3 = Theme.Sidebar,
                Text = "+",
                Font = Theme.FontBold,
                TextColor3 = Theme.Text,
                TextSize = 16,
                AutoButtonColor = false,
            }, Holder)
            corner(PlusBtn, 5)

            local value = default
            Window.FlagValues[flag] = value

            local function setValue(v)
                value = math.clamp(v, min, max)
                Window.FlagValues[flag] = value
                ValueBox.Text = tostring(value)
                local ok, err = pcall(callback, value)
                if not ok then warn("[ModernUILib] Stepper callback error: " .. tostring(err)) end
            end

            MinusBtn.MouseButton1Click:Connect(function() setValue(value - step) end)
            PlusBtn.MouseButton1Click:Connect(function() setValue(value + step) end)
            MinusBtn.MouseEnter:Connect(function() tween(MinusBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15) end)
            MinusBtn.MouseLeave:Connect(function() tween(MinusBtn, {BackgroundColor3 = Theme.Sidebar}, 0.15) end)
            PlusBtn.MouseEnter:Connect(function() tween(PlusBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15) end)
            PlusBtn.MouseLeave:Connect(function() tween(PlusBtn, {BackgroundColor3 = Theme.Sidebar}, 0.15) end)

            ValueBox.FocusLost:Connect(function()
                local n = tonumber(ValueBox.Text)
                if n then setValue(n) else ValueBox.Text = tostring(value) end
            end)

            return {
                Instance = Holder,
                Set = function(_, v) setValue(v) end,
                Get = function() return value end,
            }
        end

        -- RANGE SLIDER (dua handle: min-max)
        function Tab:CreateRangeSlider(opts)
            opts = opts or {}
            local text = opts.Name or "Range Slider"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local defaultLow = math.clamp(opts.DefaultLow or min, min, max)
            local defaultHigh = math.clamp(opts.DefaultHigh or max, min, max)
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local Holder = newElementBase(46)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -100, 0, 20),
                Position = UDim2.new(0, 12, 0, 4),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local ValueLbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 90, 0, 20),
                Position = UDim2.new(1, -100, 0, 4),
                Font = Theme.Font,
                Text = tostring(defaultLow) .. " - " .. tostring(defaultHigh),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, Holder)

            local Track = make("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
            }, Holder)
            corner(Track, 3)

            local function ratio(v) return math.clamp((v - min) / math.max(max - min, 1e-6), 0, 1) end

            local Fill = make("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
            }, Track)
            corner(Fill, 3)

            local function makeHandle()
                local h = make("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                }, Track)
                corner(h, 7)
                stroke(h, Theme.Accent, 2)
                return h
            end
            local LowHandle = makeHandle()
            local HighHandle = makeHandle()

            local lowVal, highVal = defaultLow, defaultHigh
            Window.FlagValues[flag] = {Low = lowVal, High = highVal}

            local function redraw()
                local lr, hr = ratio(lowVal), ratio(highVal)
                LowHandle.Position = UDim2.new(lr, -7, 0.5, -7)
                HighHandle.Position = UDim2.new(hr, -7, 0.5, -7)
                Fill.Position = UDim2.new(lr, 0, 0, 0)
                Fill.Size = UDim2.new(hr - lr, 0, 1, 0)
                ValueLbl.Text = tostring(math.floor(lowVal)) .. " - " .. tostring(math.floor(highVal))
            end
            redraw()

            local function fire()
                Window.FlagValues[flag] = {Low = lowVal, High = highVal}
                local ok, err = pcall(callback, lowVal, highVal)
                if not ok then warn("[ModernUILib] RangeSlider callback error: " .. tostring(err)) end
            end

            local function bindHandle(handle, isLow)
                local dragging = false
                handle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local newVal = min + (max - min) * rel
                        if isLow then
                            lowVal = math.min(newVal, highVal)
                        else
                            highVal = math.max(newVal, lowVal)
                        end
                        redraw()
                        fire()
                    end
                end)
            end
            bindHandle(LowHandle, true)
            bindHandle(HighHandle, false)

            return {
                Instance = Holder,
                Set = function(_, low, high) lowVal = low; highVal = high; redraw() end,
                Get = function() return lowVal, highVal end,
            }
        end

        -- COLLAPSIBLE / ACCORDION (grup elemen yang bisa dibuka-tutup)
        function Tab:CreateCollapsible(opts)
            opts = opts or {}
            local text = opts.Name or "Section"
            local startOpen = opts.Open or false

            local Holder = make("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ClipsDescendants = true,
            }, Page)
            corner(Holder, 6)

            local HeaderBtn = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Text = "",
            }, Holder)

            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -36, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Theme.Font,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, HeaderBtn)

            local Arrow = make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -32, 0, 6),
                Font = Theme.FontBold,
                Text = "▼",
                TextColor3 = Theme.SubText,
                TextSize = 12,
                Rotation = startOpen and 180 or 0,
            }, HeaderBtn)

            local Content = make("Frame", {
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 40),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, Holder)
            local ContentLayout = make("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, Content)

            local open = startOpen
            local function updateSize()
                task.wait()
                if open then
                    Holder.Size = UDim2.new(1, 0, 0, 40 + Content.AbsoluteSize.Y + 8)
                else
                    Holder.Size = UDim2.new(1, 0, 0, 36)
                end
            end

            HeaderBtn.MouseButton1Click:Connect(function()
                open = not open
                tween(Arrow, {Rotation = open and 180 or 0}, 0.15)
                updateSize()
            end)

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then updateSize() end
            end)

            -- sub-elemen dibuat dengan cara sama seperti Tab tapi Parent = Content
            local Sub = {}
            local subBase = newElementBase
            local function newSubElementBase(height)
                local h = make("Frame", {
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor3 = Theme.Section,
                    BorderSizePixel = 0,
                }, Content)
                corner(h, 5)
                return h
            end

            function Sub:CreateButton(o)
                o = o or {}
                local h = newSubElementBase(32)
                local btn = make("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = o.Name or "Button",
                    Font = Theme.Font,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                }, h)
                btn.MouseButton1Click:Connect(function()
                    local ok, err = pcall(o.Callback or function() end)
                    if not ok then warn("[ModernUILib] Collapsible button error: " .. tostring(err)) end
                end)
                return {Instance = h}
            end

            function Sub:CreateToggle(o)
                o = o or {}
                local h = newSubElementBase(32)
                local flag = o.Flag or genId()
                local state = o.Default or false
                make("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -56, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Font = Theme.Font,
                    Text = o.Name or "Toggle",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, h)
                local Switch = make("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -46, 0.5, -9),
                    BackgroundColor3 = state and Theme.Accent or Theme.Sidebar,
                    BorderSizePixel = 0,
                }, h)
                corner(Switch, 9)
                local Dot = make("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel = 0,
                }, Switch)
                corner(Dot, 7)
                local ClickArea = make("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}, h)
                Window.FlagValues[flag] = state
                ClickArea.MouseButton1Click:Connect(function()
                    state = not state
                    Window.FlagValues[flag] = state
                    tween(Switch, {BackgroundColor3 = state and Theme.Accent or Theme.Sidebar}, 0.15)
                    tween(Dot, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.15)
                    local ok, err = pcall(o.Callback or function() end, state)
                    if not ok then warn("[ModernUILib] Collapsible toggle error: " .. tostring(err)) end
                end)
                return {Instance = h, Get = function() return state end}
            end

            if startOpen then task.defer(updateSize) end

            return Sub
        end

        -- TABLE / DATA GRID (tampilan data statis, cocok buat stats/info)
        function Tab:CreateTable(opts)
            opts = opts or {}
            local headers = opts.Headers or {}
            local rows = opts.Rows or {}
            local colCount = math.max(#headers, 1)
            local rowHeight = 26

            local Holder = newElementBase((#rows + 1) * rowHeight + 8)
            pad(Holder, 4)

            local function makeRow(cells, layoutOrder, isHeader)
                local Row = make("Frame", {
                    Size = UDim2.new(1, 0, 0, rowHeight),
                    BackgroundColor3 = isHeader and Theme.Sidebar or Theme.Section,
                    LayoutOrder = layoutOrder,
                }, Holder)
                corner(Row, 4)
                make("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, Row)
                for i, cell in ipairs(cells) do
                    local Cell = make("Frame", {
                        Size = UDim2.new(1 / colCount, 0, 1, 0),
                        BackgroundTransparency = 1,
                        LayoutOrder = i,
                    }, Row)
                    make("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -8, 1, 0),
                        Position = UDim2.new(0, 4, 0, 0),
                        Font = isHeader and Theme.FontBold or Theme.Font,
                        Text = tostring(cell),
                        TextColor3 = isHeader and Theme.Text or Theme.SubText,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    }, Cell)
                end
                return Row
            end

            make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Holder)
            if #headers > 0 then makeRow(headers, 0, true) end
            for i, row in ipairs(rows) do makeRow(row, i, false) end

            return {
                Instance = Holder,
                AddRow = function(_, row)
                    table.insert(rows, row)
                    makeRow(row, #rows, false)
                    Holder.Size = UDim2.new(1, 0, 0, (#rows + 1) * rowHeight + 8)
                end,
            }
        end

        -- CONSOLE / LOG BOX (scrolling text output, berguna buat debug script)
        function Tab:CreateConsole(opts)
            opts = opts or {}
            local title = opts.Name or "Console"
            local height = opts.Height or 140
            local maxLines = opts.MaxLines or 100

            local Holder = newElementBase(height)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 20),
                Position = UDim2.new(0, 8, 0, 4),
                Font = Theme.FontBold,
                Text = title,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, Holder)

            local LogArea = make("ScrollingFrame", {
                Size = UDim2.new(1, -16, 1, -30),
                Position = UDim2.new(0, 8, 0, 26),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
            }, Holder)
            corner(LogArea, 5)
            pad(LogArea, 6)
            make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, LogArea)

            local lineCount = 0
            local function log(text, color)
                lineCount += 1
                make("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Code,
                    Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(text),
                    TextColor3 = color or Theme.SubText,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    LayoutOrder = lineCount,
                }, LogArea)

                if lineCount > maxLines then
                    local first = LogArea:FindFirstChildOfClass("TextLabel")
                    if first then first:Destroy() end
                end
                task.defer(function()
                    LogArea.CanvasPosition = Vector2.new(0, math.huge)
                end)
            end

            return {
                Instance = Holder,
                Log = function(_, text) log(text, Theme.SubText) end,
                LogSuccess = function(_, text) log(text, Theme.Success) end,
                LogError = function(_, text) log(text, Theme.Error) end,
                Clear = function()
                    for _, c in pairs(LogArea:GetChildren()) do
                        if c:IsA("TextLabel") then c:Destroy() end
                    end
                    lineCount = 0
                end,
            }
        end

        -- FILE DROPDOWN (otomatis list file dari folder, pakai listfiles kalau tersedia)
        function Tab:CreateFileDropdown(opts)
            opts = opts or {}
            local text = opts.Name or "File"
            local folder = opts.Folder or Window.ConfigFolder
            local extension = opts.Extension -- contoh: ".json"
            local flag = opts.Flag or genId()
            local callback = opts.Callback or function() end

            local files = {}
            local listfilesFn = listfiles
            if listfilesFn then
                local ok, result = pcall(listfilesFn, folder)
                if ok and result then
                    for _, path in ipairs(result) do
                        local fname = path:match("([^/\\]+)$")
                        if fname then
                            if not extension or fname:sub(-#extension) == extension then
                                table.insert(files, fname)
                            end
                        end
                    end
                end
            end

            -- pakai komponen dropdown biasa
            local dropdown = Tab:CreateDropdown({
                Name = text,
                Options = files,
                Flag = flag,
                Callback = callback,
            })
            dropdown.RefreshFiles = function()
                local newFiles = {}
                if listfilesFn then
                    local ok, result = pcall(listfilesFn, folder)
                    if ok and result then
                        for _, path in ipairs(result) do
                            local fname = path:match("([^/\\]+)$")
                            if fname then
                                if not extension or fname:sub(-#extension) == extension then
                                    table.insert(newFiles, fname)
                                end
                            end
                        end
                    end
                end
                dropdown:Refresh(newFiles)
            end
            return dropdown
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    ----------------------------------------------------------------
    -- CONFIG SAVE / LOAD
    ----------------------------------------------------------------
    function Window:SaveConfig(name)
        name = name or "default"
        local data = {}
        for flag, value in pairs(Window.FlagValues) do
            if typeof(value) == "EnumItem" then
                data[flag] = {__type = "EnumItem", value = value.Name}
            elseif typeof(value) == "Color3" then
                data[flag] = {__type = "Color3", r = value.R, g = value.G, b = value.B}
            else
                data[flag] = value
            end
        end
        local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if ok then
            safeCall(writefile, Window.ConfigFolder .. "/" .. name .. ".json", encoded)
            return true
        end
        return false
    end

    function Window:LoadConfig(name)
        name = name or "default"
        local path = Window.ConfigFolder .. "/" .. name .. ".json"
        if not isfile(path) then return false end
        local content = safeCall(readfile, path)
        if not content then return false end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, content)
        if not ok then return false end

        for flag, value in pairs(data) do
            local realValue = value
            if type(value) == "table" and value.__type == "EnumItem" then
                realValue = nil -- can't fully restore arbitrary enum without category; skip safely
            elseif type(value) == "table" and value.__type == "Color3" then
                realValue = Color3.new(value.r, value.g, value.b)
            end
            if realValue ~= nil and Window.FlagCallbacks[flag] then
                Window.FlagCallbacks[flag](realValue, false)
            end
        end
        return true
    end

    return Window
end

------------------------------------------------------------
-- WATERMARK (bar kecil mengambang, kayak stats HUD di script hub)
------------------------------------------------------------
function Library:CreateWatermark(opts)
    opts = opts or {}
    local title = opts.Title or "ModernUILib"
    local showFPS = opts.ShowFPS ~= false
    local showPing = opts.ShowPing ~= false

    local screenGui = make("ScreenGui", {
        Name = "ModernUILib_Watermark",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 200,
    }, getGuiParent())
    if syn and syn.protect_gui then safeCall(syn.protect_gui, screenGui) end

    local Bar = make("Frame", {
        Size = UDim2.new(0, 220, 0, 26),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
    }, screenGui)
    corner(Bar, 6)
    stroke(Bar, Theme.Stroke, 1)

    local Label = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Font = Theme.Font,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Bar)

    makeDraggable(Bar, Bar)

    local frames = 0
    local lastUpdate = os.clock()
    local fps = 0
    local conn
    if showFPS or showPing then
        conn = RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = os.clock()
            if now - lastUpdate >= 1 then
                fps = frames
                frames = 0
                lastUpdate = now

                local parts = {title}
                if showFPS then table.insert(parts, fps .. " FPS") end
                if showPing then
                    local ping = "N/A"
                    local ok, stat = pcall(function()
                        return LocalPlayer:GetNetworkPing() * 1000
                    end)
                    if ok and stat then ping = math.floor(stat) .. "ms" end
                    table.insert(parts, ping)
                end
                Label.Text = table.concat(parts, " | ")
            end
        end)
    end

    return {
        Instance = Bar,
        ScreenGui = screenGui,
        SetText = function(_, text) Label.Text = text end,
        Destroy = function()
            if conn then conn:Disconnect() end
            screenGui:Destroy()
        end,
    }
end

------------------------------------------------------------
-- KEY SYSTEM (layar verifikasi key sebelum masuk ke Window utama)
------------------------------------------------------------
function Library:CreateKeySystem(opts)
    opts = opts or {}
    local title = opts.Title or "Key System"
    local subtitle = opts.Subtitle or "Masukkan key untuk lanjut"
    local validKeys = opts.Keys or {}
    local saveKey = opts.SaveKey ~= false
    local configFolder = opts.ConfigFolder or "ModernUILib_Config"
    local note = opts.Note or ""
    local onSuccess = opts.OnSuccess or function() end
    local getKeyLink = opts.GetKeyLink

    if not isfolder(configFolder) then safeCall(makefolder, configFolder) end
    local savePath = configFolder .. "/_key.txt"

    local function isValidKey(k)
        if opts.Validate then
            local ok, result = pcall(opts.Validate, k)
            return ok and result
        end
        for _, valid in ipairs(validKeys) do
            if k == valid then return true end
        end
        return false
    end

    -- Auto-check saved key dulu
    if saveKey and isfile(savePath) then
        local saved = safeCall(readfile, savePath)
        if saved and isValidKey(saved) then
            onSuccess()
            return {Skipped = true}
        end
    end

    local screenGui = make("ScreenGui", {
        Name = "ModernUILib_KeySystem",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 300,
    }, getGuiParent())
    if syn and syn.protect_gui then safeCall(syn.protect_gui, screenGui) end

    local Overlay = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.4,
    }, screenGui)

    local Card = make("Frame", {
        Size = UDim2.new(0, 320, 0, 220),
        Position = UDim2.new(0.5, -160, 0.5, -110),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
    }, Overlay)
    corner(Card, 10)
    stroke(Card, Theme.Stroke, 1)
    pad(Card, 20)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 26),
        Font = Theme.Font,
        Text = subtitle,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    local KeyBox = make("TextBox", {
        Size = UDim2.new(1, 0, 0, 34),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundColor3 = Theme.Element,
        Text = "",
        PlaceholderText = "Masukkan key...",
        Font = Theme.Font,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.SubText,
        TextSize = 13,
        ClearTextOnFocus = false,
    }, Card)
    corner(KeyBox, 6)
    pad(KeyBox, 10)

    local StatusLbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 94),
        Font = Theme.Font,
        Text = note,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Card)

    local SubmitBtn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 1, -36),
        BackgroundColor3 = Theme.Accent,
        Text = "Verifikasi",
        Font = Theme.FontBold,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 14,
        AutoButtonColor = false,
    }, Card)
    corner(SubmitBtn, 6)

    if getKeyLink then
        local GetKeyBtn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 1, -74),
            BackgroundColor3 = Theme.Element,
            Text = "Dapatkan Key",
            Font = Theme.Font,
            TextColor3 = Theme.SubText,
            TextSize = 12,
            AutoButtonColor = false,
        }, Card)
        corner(GetKeyBtn, 6)
        GetKeyBtn.MouseButton1Click:Connect(function()
            if setclipboard then safeCall(setclipboard, getKeyLink) end
            StatusLbl.Text = "Link disalin ke clipboard!"
            StatusLbl.TextColor3 = Theme.Success
        end)
    end

    local function attempt()
        local k = KeyBox.Text
        if isValidKey(k) then
            StatusLbl.Text = "Key valid! Membuka..."
            StatusLbl.TextColor3 = Theme.Success
            if saveKey then safeCall(writefile, savePath, k) end
            task.wait(0.3)
            screenGui:Destroy()
            onSuccess()
        else
            StatusLbl.Text = "Key salah / tidak valid."
            StatusLbl.TextColor3 = Theme.Error
            tween(Card, {Position = UDim2.new(0.5, -168, 0.5, -110)}, 0.05)
            task.wait(0.05)
            tween(Card, {Position = UDim2.new(0.5, -160, 0.5, -110)}, 0.05)
        end
    end

    SubmitBtn.MouseButton1Click:Connect(attempt)
    KeyBox.FocusLost:Connect(function(enter) if enter then attempt() end end)

    return {ScreenGui = screenGui}
end

------------------------------------------------------------
-- RESPONSIVE: update scale kalau ukuran layar berubah (rotate device, dll)
------------------------------------------------------------
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        -- Window-window yang sudah dibuat bakal tetap pakai UIScale awal;
        -- kalau mau live-update, simpan reference scaleObj per window dan set ulang di sini.
    end)
end

return Library
