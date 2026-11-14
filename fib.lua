local P = game:GetService("Players").LocalPlayer
local CG = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local RunS = game:GetService("RunService")
local Stats = game:GetService("Stats")
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local WebhookURL = "" 
local WebhookMode = "Anonim" 
local WebhookActive = false
local ScriptStartTime = os.time()
local LastWebhookTime = os.time()
local WebhookInterval = 60 

local CustomDisplayName = P.DisplayName
local CustomLevel = "1"
local CustomTitle = "VIP"
local EnableCustomDisplayName = false
local EnableCustomLevel = false
local EnableCustomTitle = false
local ConfigFileName = "KemplongXD_FishingIsland_Config.json"

local QuestStartTime = os.time()
local CurrentActiveQuestId = nil

-- Forward declarations for toggles and UI elements
local WebhookToggle, DefaultQuestZoneDrop, DisplayNameInp, LevelInp, TitleInp, WHBox, ModeDrop, WHIntervalBox
local CustomDisplayNameToggle, CustomLevelToggle, CustomTitleToggle

-- Config System (Auto Save & Load with Extended Features)
local function SaveConfig()
    if not writefile then return end
    local configData = {
        WebhookURL = WebhookURL,
        WebhookMode = WebhookMode,
        WebhookActive = WebhookActive,
        CustomDisplayName = CustomDisplayName,
        CustomLevel = CustomLevel,
        CustomTitle = CustomTitle,
        EnableCustomDisplayName = EnableCustomDisplayName,
        EnableCustomLevel = EnableCustomLevel,
        EnableCustomTitle = EnableCustomTitle,
        WebhookInterval = WebhookInterval,
        AutoQuest = QuestTab and QuestTab.AutoQuest or false,
        AutoCaptainJones = QuestTab and QuestTab.AutoCaptainJones or false,
        AutoSwapRod = QuestTab and QuestTab.AutoSwapRod or true,
        AutoSwapBait = QuestTab and QuestTab.AutoSwapBait or true,
        DefaultQuestZone = QuestTab and QuestTab.DefaultQuestZone or "VerdantIsle",
        AutoBuyWeather = ShopTab and ShopTab.AutoBuy or false,
        AutoTotem = ShopTab and ShopTab.AutoTotem or false,
        AutoSell = FishBot and FishBot.AutoSell or false,
        AutoSellLimit = FishBot and FishBot.AutoSellLimit or 400,
        AntiAFK = MiscTools and MiscTools.AFK or false,
    }
    pcall(function()
        writefile(ConfigFileName, HttpService:JSONEncode(configData))
    end)
end

local function LoadConfig()
    if not isfile or not readfile or not isfile(ConfigFileName) then return end
    pcall(function()
        local content = readfile(ConfigFileName)
        local data = HttpService:JSONDecode(content)
        if type(data) == "table" then
            if data.WebhookURL then 
                WebhookURL = data.WebhookURL 
                if WHBox then WHBox.Text = WebhookURL end
            end
            if data.WebhookMode then 
                WebhookMode = data.WebhookMode 
                if ModeDrop and ModeDrop.Btn then ModeDrop.Btn.Text = "  " .. (WebhookMode == "Anonim" and "Anonymous (KemplongXDOnTop)" or "Real Roblox Username") end
            end
            if data.WebhookActive ~= nil and WebhookToggle then 
                WebhookToggle.SetState(data.WebhookActive) 
            end
            if data.CustomDisplayName then 
                CustomDisplayName = data.CustomDisplayName 
                if DisplayNameInp then DisplayNameInp.Text = CustomDisplayName end
            end
            if data.CustomLevel then
                CustomLevel = data.CustomLevel
                if LevelInp then LevelInp.Text = CustomLevel end
            end
            if data.CustomTitle then
                CustomTitle = data.CustomTitle
                if TitleInp then TitleInp.Text = CustomTitle end
            end
            if data.EnableCustomDisplayName ~= nil and CustomDisplayNameToggle then 
                CustomDisplayNameToggle.SetState(data.EnableCustomDisplayName) 
            end
            if data.EnableCustomLevel ~= nil and CustomLevelToggle then 
                CustomLevelToggle.SetState(data.EnableCustomLevel) 
            end
            if data.EnableCustomTitle ~= nil and CustomTitleToggle then 
                CustomTitleToggle.SetState(data.EnableCustomTitle) 
            end
            pcall(function() ApplyCustomOverheadInfo() end)
            if data.WebhookInterval then 
                WebhookInterval = data.WebhookInterval 
                if WHIntervalBox then WHIntervalBox.Text = tostring(WebhookInterval) end
            end
            if data.AutoQuest ~= nil and QuestTab and QuestTab.AutoQuestToggle then 
                QuestTab.AutoQuestToggle.SetState(data.AutoQuest) 
            end
            if data.AutoCaptainJones ~= nil and QuestTab and QuestTab.AutoCaptainJonesToggle then 
                QuestTab.AutoCaptainJonesToggle.SetState(data.AutoCaptainJones) 
            end
            if data.AutoSwapRod ~= nil and QuestTab and QuestTab.AutoSwapRodToggle then 
                QuestTab.AutoSwapRodToggle.SetState(data.AutoSwapRod) 
            end
            if data.AutoSwapBait ~= nil and QuestTab and QuestTab.AutoSwapBaitToggle then 
                QuestTab.AutoSwapBaitToggle.SetState(data.AutoSwapBait) 
            end
            if data.DefaultQuestZone and QuestTab then 
                QuestTab.DefaultQuestZone = data.DefaultQuestZone 
                if DefaultQuestZoneDrop and DefaultQuestZoneDrop.Btn then DefaultQuestZoneDrop.Btn.Text = "  " .. data.DefaultQuestZone end
            end
            if data.AutoBuyWeather ~= nil and ShopTab and ShopTab.AutoBuyToggle then 
                ShopTab.AutoBuyToggle.SetState(data.AutoBuyWeather) 
            end
            if data.AutoTotem ~= nil and ShopTab and ShopTab.AutoTotemToggle then 
                ShopTab.AutoTotemToggle.SetState(data.AutoTotem) 
            end
            if data.AutoSell ~= nil and FishBot then 
                FishBot.AutoSell = data.AutoSell
                FishBot:UpdateAutoSellUI()
                if FishBot.AutoSellBtn then 
                    FishBot.AutoSellBtn.BackgroundColor3 = FishBot.AutoSell and Color3.fromRGB(0,122,255) or Color3.fromRGB(220,220,220)
                    FishBot.AutoSellBtn.TextColor3 = FishBot.AutoSell and Color3.fromRGB(255,255,255) or Color3.fromRGB(80,80,80)
                end
            end
            if data.AutoSellLimit ~= nil and FishBot then 
                FishBot.AutoSellLimit = data.AutoSellLimit 
                if FishBot.TxtAutoSell then FishBot.TxtAutoSell.Text = tostring(FishBot.AutoSellLimit) end
                FishBot:UpdateAutoSellUI()
            end
            if data.AntiAFK ~= nil and MiscTools and MiscTools.AfkToggle then 
                MiscTools.AfkToggle.SetState(data.AntiAFK) 
            end
        end
    end)
end

-- Dynamic FishList & VariantsList from ReplicatedStorage
local FishListItems = {}
pcall(function()
    local fishFolder = RS.FishingSystem.Assets:WaitForChild("Fish", 5)
    if fishFolder then
        for _, item in ipairs(fishFolder:GetChildren()) do
            table.insert(FishListItems, {name = item.Name, val = item.Name})
        end
    end
end)

local VariantListItems = {}
pcall(function()
    local variantsFolder = RS:WaitForChild("Variants", 5)
    if variantsFolder then
        for _, item in ipairs(variantsFolder:GetChildren()) do
            table.insert(VariantListItems, {name = item.Name, val = item.Name})
        end
    end
end)

local function FormatUptime(seconds)
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if d > 0 then return string.format("%dd %02d:%02d:%02d", d, h, m, s) end
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function SendWebhook(title, contentData, colorHex)
    if not WebhookActive or WebhookURL == "" or typeof(WebhookURL) ~= "string" or not WebhookURL:find("http") then return end
    
    local sendUsername = "KemplongXDOnTop"
    local sendAvatar = "https://cdn.discordapp.com/embed/avatars/0.png"
    
    if WebhookMode == "Asli" then
        sendUsername = (CustomDisplayName ~= "" and CustomDisplayName or P.DisplayName) .. " (@" .. P.Name .. ")"
        pcall(function()
            sendAvatar = game.Players:GetUserThumbnailAsync(P.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
    end
    
    local embed = {
        ["title"] = title,
        ["color"] = colorHex,
        ["footer"] = { ["text"] = "Fishing Island ~ KemplongXD • Automation System" },
        ["timestamp"] = DateTime.now():ToIsoDate()
    }
    
    if type(contentData) == "string" then embed["description"] = contentData
    elseif type(contentData) == "table" then embed["fields"] = contentData end
    
    local data = {
        ["username"] = sendUsername, 
        ["avatar_url"] = sendAvatar, 
        ["embeds"] = { embed }
    }
    
    local jsonData = HttpService:JSONEncode(data)
    local req = http_request or request or HttpPost
    
    if req then
        task.spawn(function()
            pcall(function() req({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = jsonData}) end)
        end)
    end
end

pcall(function() GuiService:SetGameplayPausedNotificationEnabled(false) end)
if CG:FindFirstChild("MacOSFishGUI") then CG.MacOSFishGUI:Destroy() end

local C3, U2 = Color3.fromRGB, UDim2.new
local F_G, F_GM, F_GB = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold

local function C(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if type(k) == "number" then v.Parent = o
        elseif k == "Click" then o.MouseButton1Click:Connect(v)
        elseif k == "Focus" then o.FocusLost:Connect(v)
        else o[k] = v end
    end
    return o
end

local Dropdown = {}
Dropdown.__index = Dropdown
function Dropdown.new(parent, y, title, items, cb, searchable)
    local self = setmetatable({Open=false, Items=items, CB=cb, Filter="", Searchable=searchable or false}, Dropdown)
    C("TextLabel", {Parent=parent, Size=U2(0,120,0,20), Position=U2(0,20,0,y), BackgroundTransparency=1, Text=title, TextColor3=C3(80,80,80), Font=F_GM, TextSize=12, TextXAlignment=0})
    self.Btn = C("TextButton", {Parent=parent, Size=U2(1,-40,0,30), Position=U2(0,20,0,y+20), BackgroundColor3=C3(255,255,255), Text="  Select...", TextColor3=C3(50,50,50), Font=F_G, TextSize=13, TextXAlignment=0, ZIndex=2, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)}), Click=function() self:Toggle() end})
    self.Arrow = C("TextLabel", {Parent=self.Btn, Size=U2(0,20,1,0), Position=U2(1,-25,0,0), BackgroundTransparency=1, Text="▼", TextColor3=C3(150,150,150), Font=F_G, TextSize=10, ZIndex=2})
    if self.Searchable then
        -- Search-enabled dropdown: container with search box on top + scroll list
        self.Container = C("Frame", {Parent=parent, Size=U2(1,-40,0,140), Position=U2(0,20,0,y+53), BackgroundColor3=C3(255,255,255), BorderSizePixel=0, Visible=false, ZIndex=5, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)})})
        self.SearchBox = C("TextBox", {Parent=self.Container, Size=U2(1,-10,0,25), Position=U2(0,5,0,5), BackgroundColor3=C3(245,245,245), Text="", PlaceholderText="Search...", TextColor3=C3(50,50,50), Font=F_G, TextSize=12, ClearTextOnFocus=false, ZIndex=6, C("UICorner",{CornerRadius=UDim.new(0,4)}), C("UIStroke",{Color=C3(220,220,220)})})
        self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            self.Filter = self.SearchBox.Text:lower()
            self:Render()
        end)
        self.Scroll = C("ScrollingFrame", {Parent=self.Container, Size=U2(1,-10,1,-35), Position=U2(0,5,0,32), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ZIndex=6, C("UIListLayout",{Padding=UDim.new(0,2)})})
    else
        self.Scroll = C("ScrollingFrame", {Parent=parent, Size=U2(1,-40,0,100), Position=U2(0,20,0,y+53), BackgroundColor3=C3(255,255,255), BorderSizePixel=0, ScrollBarThickness=4, Visible=false, ZIndex=5, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)}), C("UIListLayout")})
    end
    self:Render()
    return self
end
function Dropdown:Toggle()
    self.Open = not self.Open
    if self.Searchable then self.Container.Visible = self.Open else self.Scroll.Visible = self.Open end
    self.Arrow.Text = self.Open and "▲" or "▼"
end
function Dropdown:Render(nItems)
    if nItems then self.Items = nItems end
    for _, c in pairs(self.Scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local count = 0
    for _, itm in ipairs(self.Items) do
        if (not self.Searchable) or self.Filter == "" or itm.name:lower():find(self.Filter) then
            count = count + 1
            C("TextButton", {Parent=self.Scroll, Size=U2(1,0,0,25), BackgroundColor3=C3(255,255,255), BorderSizePixel=0, Text="  "..itm.name, TextColor3=C3(60,60,60), Font=F_G, TextSize=12, TextXAlignment=0, ZIndex=self.Scroll.ZIndex + 1, Click=function() self.Btn.Text="  "..itm.name; self:Toggle(); if self.CB then self.CB(itm.val) end end})
        end
    end
    self.Scroll.CanvasSize = U2(0,0,0, count*25)
end
function Dropdown:Reset() self.Btn.Text = "  Select..." end

-- Upgraded MultiDropdown with Multi-Select and Search Support
local MultiDropdown = {}
MultiDropdown.__index = MultiDropdown
function MultiDropdown.new(parent, y, title, items, cb)
    local self = setmetatable({Open=false, Items=items, Selected={}, CB=cb, Filter=""}, MultiDropdown)
    for _, itm in ipairs(self.Items) do self.Selected[itm.val] = false end
    
    C("TextLabel", {Parent=parent, Size=U2(0,120,0,20), Position=U2(0,20,0,y), BackgroundTransparency=1, Text=title, TextColor3=C3(80,80,80), Font=F_GM, TextSize=12, TextXAlignment=0})
    self.Btn = C("TextButton", {Parent=parent, Size=U2(1,-40,0,30), Position=U2(0,20,0,y+20), BackgroundColor3=C3(255,255,255), Text="  None Selected", TextColor3=C3(50,50,50), Font=F_G, TextSize=13, TextXAlignment=0, ZIndex=2, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)}), Click=function() self:Toggle() end})
    self.Arrow = C("TextLabel", {Parent=self.Btn, Size=U2(0,20,1,0), Position=U2(1,-25,0,0), BackgroundTransparency=1, Text="▼", TextColor3=C3(150,150,150), Font=F_G, TextSize=10, ZIndex=2})
    
    self.Container = C("Frame", {Parent=parent, Size=U2(1,-40,0,135), Position=U2(0,20,0,y+53), BackgroundColor3=C3(255,255,255), BorderSizePixel=0, Visible=false, ZIndex=5, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)})})
    
    self.SearchBox = C("TextBox", {Parent=self.Container, Size=U2(1,-10,0,25), Position=U2(0,5,0,5), BackgroundColor3=C3(245,245,245), Text="", PlaceholderText="Search...", TextColor3=C3(50,50,50), Font=F_G, TextSize=12, ClearTextOnFocus=false, ZIndex=6, C("UICorner",{CornerRadius=UDim.new(0,4)}), C("UIStroke",{Color=C3(220,220,220)})})
    self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self.Filter = self.SearchBox.Text:lower()
        self:RenderList()
    end)
    
    self.Scroll = C("ScrollingFrame", {Parent=self.Container, Size=U2(1,-10,1,-35), Position=U2(0,5,0,32), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ZIndex=6, C("UIListLayout", {Padding=UDim.new(0,2)})})
    self:RenderList()
    return self
end
function MultiDropdown:Toggle() 
    self.Open = not self.Open; 
    self.Container.Visible = self.Open; 
    self.Arrow.Text = self.Open and "▲" or "▼" 
end
function MultiDropdown:RenderList()
    for _, c in pairs(self.Scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local count = 0
    for _, itm in ipairs(self.Items) do
        if self.Filter == "" or itm.name:lower():find(self.Filter) then
            count = count + 1
            local isSel = self.Selected[itm.val]
            local btn = C("TextButton", {Parent=self.Scroll, Size=U2(1,0,0,25), BackgroundColor3=isSel and C3(0,122,255) or C3(255,255,255), BorderSizePixel=0, Text="  "..itm.name, TextColor3=isSel and C3(255,255,255) or C3(60,60,60), Font=F_G, TextSize=12, TextXAlignment=0, ZIndex=7})
            btn.MouseButton1Click:Connect(function() 
                self.Selected[itm.val] = not self.Selected[itm.val]
                self:UpdateBtnText()
                self:RenderList()
                if self.CB then self.CB(self.Selected) end 
            end)
        end
    end
    self.Scroll.CanvasSize = U2(0,0,0, count * 27)
end
function MultiDropdown:UpdateBtnText()
    local sel = 0
    for _, v in pairs(self.Selected) do if v then sel = sel + 1 end end
    self.Btn.Text = sel == 0 and "  None Selected" or "  Selected ("..sel..")"
end

local UI = { Tabs = {}, Frames = {} }
UI.SG = C("ScreenGui", {Name="MacOSFishGUI", Parent=CG})
UI.MF = C("Frame", {Parent=UI.SG, Size=U2(0,520,0,380), Position=U2(0.5,-260,0.5,-190), BackgroundColor3=C3(245,245,245), Active=true, Draggable=true, ClipsDescendants=true, C("UICorner",{CornerRadius=UDim.new(0,12)}), C("UIStroke",{Color=C3(220,220,220)})})
UI.TB = C("Frame", {Parent=UI.MF, Size=U2(1,0,0,30), BackgroundTransparency=1})
C("TextButton", {Parent=UI.TB, Size=U2(0,12,0,12), Position=U2(0,12,0.5,-6), BackgroundColor3=C3(255,95,86), Text="", C("UICorner",{CornerRadius=UDim.new(1,0)}), Click=function() UI.SG:Destroy() end})
C("TextButton", {Parent=UI.TB, Size=U2(0,12,0,12), Position=U2(0,32,0.5,-6), BackgroundColor3=C3(255,189,46), Text="", C("UICorner",{CornerRadius=UDim.new(1,0)}), Click=function() UI.Min = not UI.Min; UI.CC.Visible = not UI.Min; UI.MF:TweenSize(U2(0,520,0,UI.Min and 30 or 380), "Out", "Quad", 0.3, true) end})
C("Frame", {Parent=UI.TB, Size=U2(0,12,0,12), Position=U2(0,52,0.5,-6), BackgroundColor3=C3(39,201,63), C("UICorner",{CornerRadius=UDim.new(1,0)})})
C("TextLabel", {Parent=UI.TB, Size=U2(1,0,1,0), BackgroundTransparency=1, Text="Fishing Island ~ KemplongXD", TextColor3=C3(100,100,100), Font=F_GM, TextSize=12})
UI.TabC = C("Frame", {Parent=UI.MF, Size=U2(0,480,0,24), Position=U2(0.5,-240,0,35), BackgroundColor3=C3(225,225,225), C("UICorner",{CornerRadius=UDim.new(0,6)})})
UI.CC = C("Frame", {Parent=UI.MF, Size=U2(1,0,1,-70), Position=U2(0,0,0,70), BackgroundTransparency=1})

local NotifContainer = C("Frame", {Parent = UI.SG, Size = U2(0, 300, 1, -40), Position = U2(1, -320, 0, 40), BackgroundTransparency = 1, ZIndex = 100})
C("UIListLayout", {Parent = NotifContainer, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 10)})

local function ShowMacOSNotification(title, text)
    task.spawn(function()
        local wrapper = C("Frame", {Parent=NotifContainer, Size=U2(1,0,0,75), BackgroundTransparency=1, ClipsDescendants=true})
        local notif = C("Frame", {Parent=wrapper, Size=U2(1,0,1,0), Position=U2(1,50,0,0), BackgroundColor3=C3(250,250,250), C("UICorner",{CornerRadius=UDim.new(0,14)}), C("UIStroke",{Color=C3(220,220,220), Thickness=1})})
        local icon = C("ImageLabel", {Parent=notif, Size=U2(0,40,0,40), Position=U2(0,15,0.5,-20), BackgroundColor3=C3(240,240,240), C("UICorner",{CornerRadius=UDim.new(0,10)}), C("UIStroke",{Color=C3(210,210,210)})})
        C("TextLabel", {Parent=icon, Size=U2(1,0,1,0), BackgroundTransparency=1, Text="XD", TextColor3=C3(100,100,100), Font=F_GB, TextSize=14})
        C("TextLabel", {Parent=notif, Size=U2(1,-75,0,20), Position=U2(0,65,0,12), BackgroundTransparency=1, Text=title, TextColor3=C3(40,40,40), Font=F_GB, TextSize=14, TextXAlignment=0})
        C("TextLabel", {Parent=notif, Size=U2(1,-75,0,30), Position=U2(0,65,0,34), BackgroundTransparency=1, Text=text, TextColor3=C3(100,100,100), Font=F_G, TextSize=12, TextXAlignment=0, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top})
        notif:TweenPosition(U2(0,0,0,0), "Out", "Quint", 0.4, true)
        task.wait(5)
        notif:TweenPosition(U2(1,50,0,0), "In", "Quint", 0.4, true)
        task.wait(0.4)
        wrapper:Destroy()
    end)
end

local function MkSection(parent, y, title)
    C("TextLabel", {Parent=parent, Size=U2(1,-40,0,20), Position=U2(0,20,0,y), BackgroundTransparency=1, Text=title, TextColor3=C3(40,40,40), Font=F_GB, TextSize=13, TextXAlignment=0})
    C("Frame", {Parent=parent, Size=U2(1,-40,0,1), Position=U2(0,20,0,y+22), BackgroundColor3=C3(210,210,210), BorderSizePixel=0})
end

local function MkInp(frm, y, txt, def, cb) 
    C("TextLabel", {Parent=frm, Size=U2(0,120,0,25), Position=U2(0,20,0,y), BackgroundTransparency=1, Text=txt, TextColor3=C3(80,80,80), Font=F_G, TextSize=13, TextXAlignment=0});
    local tb = C("TextBox", {Parent=frm, Size=U2(0,150,0,25), Position=U2(1,-170,0,y), BackgroundColor3=C3(255,255,255), Text=def, PlaceholderText="Kosong", TextColor3=C3(50,50,50), Font=F_G, TextSize=13, ClearTextOnFocus=false, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)})})
    tb.FocusLost:Connect(function() cb(tb) end)
    return tb
end

function UI:AddTab(name, pos, active)
    local btn = C("TextButton", {Parent=self.TabC, Size=U2(0.125,0,1,0), Position=pos, BackgroundTransparency=active and 0 or 1, BackgroundColor3=C3(255,255,255), Text=name, TextColor3=active and C3(50,50,50) or C3(120,120,120), Font=F_GM, TextSize=10, C("UICorner",{CornerRadius=UDim.new(0,6)})})
    local frm = C("Frame", {Parent=self.CC, Size=U2(1,0,1,0), BackgroundTransparency=1, Visible=active})
    table.insert(self.Tabs, btn)
    table.insert(self.Frames, frm)
    btn.MouseButton1Click:Connect(function()
        for i, t in ipairs(self.Tabs) do t.BackgroundTransparency=1; t.TextColor3=C3(120,120,120); self.Frames[i].Visible=false end
        btn.BackgroundTransparency=0; btn.TextColor3=C3(50,50,50); frm.Visible=true
    end)
    return frm
end

local Information = { Frm = UI:AddTab("Info", U2(0,0,0,0), true) }
local Leaderboard = { Sort = "Val", Frm = UI:AddTab("Stats", U2(0.125,0,0,0), false) }
local FishBot = { 
    Frm = UI:AddTab("Fish", U2(0.250,0,0,0), false), 
    Active = false, Rod = nil, Caught = 0, UsesLeaderstats = false,
    AutoSell = false, AutoSellLimit = 400, CurrentCatchForSell = 0, AutoSellBtn = nil,
    Delay = 0.5, Dist = 20, DelayRoll = 1.3, DelayCatch = 1, 
    Pet1 = "", Pet2 = "", PetBait = "", AutoPet = false 
}
local QuestTab = { 
    Frm = UI:AddTab("Quest", U2(0.375,0,0,0), false), 
    AutoQuest = false, AutoCaptainJones = false, DefaultQuestZone = "VerdantIsle", AutoSwapRod = false, AutoSwapBait = false
}
local ShopTab = { Frm = UI:AddTab("Auto", U2(0.500,0,0,0), false), AutoBuy = false, AutoTotem = false, AutoSpin = false, TargetAbility = "Both", AutoPlaceTotem = false, TotemCombo = {"Shiny Totem", "Luck Totem", "Mutation Totem"} }
local Teleporter = { Frm = UI:AddTab("Teleport", U2(0.625,0,0,0), false), S_Isl=nil, S_Evt=nil, S_Plr=nil, EventPlat = C("Part",{Parent=workspace,Size=Vector3.new(30,1,30),Anchored=true,Transparency=1,CanCollide=false}) }
local MiscTools = { Frm = UI:AddTab("Misc", U2(0.750,0,0,0), false), AFK=false, SW=false, Ability=false, SWPart=C("Part",{Parent=workspace,Size=Vector3.new(15,1,15),Anchored=true,Transparency=0.5,CanCollide=false}), AutoRoll=false, TargetEnchants={}, EnchantSlot=1 }
local SpinTab = { Frm = UI:AddTab("Spin", U2(0.875,0,0,0), false), AutoSpin = false, SpinType = "10x" }

C("TextLabel", {Parent=Information.Frm, Size=U2(1,0,0,30), Position=U2(0,0,0,25), BackgroundTransparency=1, Text="PREMIUM ACCESS", TextColor3=C3(40,40,40), Font=F_GB, TextSize=20})
C("TextLabel", {Parent=Information.Frm, Size=U2(1,-40,0,100), Position=U2(0,20,0,70), BackgroundTransparency=1, Text="Terima kasih sudah membeli script premium ini.\n\nDukungan kamu sangat membantu KemplongXD untuk terus memberikan update rutin dan menjaga kualitas script agar tetap aman digunakan.\n\nSemua batasan fitur sekarang telah dibuka.", TextColor3=C3(80,80,80), Font=F_G, TextSize=12, TextWrapped=true, TextYAlignment=Enum.TextYAlignment.Top})
local DevContactBtn = C("TextButton", {Parent=Information.Frm, Size=U2(1,-80,0,35), Position=U2(0,40,0,180), BackgroundColor3=C3(40,40,40), Text="Salin Kontak Developer", TextColor3=C3(255,255,255), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,8)}), Click=function() 
    if setclipboard then pcall(function() setclipboard("irfanismee") end); local oldText = DevContactBtn.Text; DevContactBtn.Text = "Disalin ke clipboard"; task.delay(1.5, function() DevContactBtn.Text = oldText end) end 
end})

C("ImageLabel", {Parent=Leaderboard.Frm, Size=U2(0,45,0,45), Position=U2(0,20,0,5), BackgroundColor3=C3(220,220,220), Image=game.Players:GetUserThumbnailAsync(P.UserId,0,0), C("UICorner",{CornerRadius=UDim.new(1,0)})})
local LeaderboardNameLbl = C("TextLabel", {Parent=Leaderboard.Frm, Size=U2(0,150,0,20), Position=U2(0,75,0,8), BackgroundTransparency=1, Text=CustomDisplayName ~= "" and CustomDisplayName or P.DisplayName, TextColor3=C3(40,40,40), Font=F_GB, TextSize=15, TextXAlignment=0})
Leaderboard.LblCaught = C("TextLabel", {Parent=Leaderboard.Frm, Size=U2(0,150,0,15), Position=U2(0,75,0,30), BackgroundTransparency=1, Text="Total Caught: 0", TextColor3=C3(0,122,255), Font=F_GM, TextSize=12, TextXAlignment=0})
Leaderboard.LblStats = C("TextLabel", {Parent=Leaderboard.Frm, Size=U2(0,120,0,45), Position=U2(1,-130,0,8), BackgroundTransparency=1, Text="Ping: 0ms\nFPS: 0\nUptime: 00:00:00", TextColor3=C3(150,150,150), Font=Enum.Font.Code, TextSize=11, TextXAlignment=1})
C("TextLabel", {Parent=Leaderboard.Frm, Size=U2(0,150,0,20), Position=U2(0,20,0,65), BackgroundTransparency=1, Text="Server Leaderboard", TextColor3=C3(100,100,100), Font=F_GM, TextSize=12, TextXAlignment=0})
Leaderboard.BtnSort = C("TextButton", {Parent=Leaderboard.Frm, Size=U2(0,80,0,18), Position=U2(1,-100,0,65), BackgroundColor3=C3(220,220,220), Text="Sort: Coin", TextColor3=C3(80,80,80), Font=F_G, TextSize=11, C("UICorner",{CornerRadius=UDim.new(0,4)}), Click=function() Leaderboard.Sort = Leaderboard.Sort=="Val" and "Name" or "Val"; Leaderboard.BtnSort.Text = "Sort: "..(Leaderboard.Sort=="Val" and "Coin" or "Name"); Leaderboard:Update() end})
Leaderboard.Scroll = C("ScrollingFrame", {Parent=Leaderboard.Frm, Size=U2(1,-40,1,-95), Position=U2(0,20,0,85), BackgroundColor3=C3(255,255,255), BorderSizePixel=0, ScrollBarThickness=4, C("UICorner",{CornerRadius=UDim.new(0,8)}), C("UIStroke",{Color=C3(220,220,220)}), C("UIListLayout",{Padding=UDim.new(0,2)})})

function Leaderboard:Fmt(n) 
    local x=tonumber(n)
    if not x then return tostring(n) end 
    return x>=1e9 and string.format("%.1fB",x/1e9):gsub("%.0","") or (x>=1e6 and string.format("%.1fM",x/1e6):gsub("%.0","") or (x>=1e3 and string.format("%.1fk",x/1e3):gsub("%.0","") or tostring(x))) 
end

function Leaderboard:Update()
    pcall(function()
        for _,c in pairs(self.Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local pd = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            local vC, dC, dF = 0, "0", ""
            if p:FindFirstChild("leaderstats") then
                for _, st in ipairs(p.leaderstats:GetChildren()) do
                    local n = st.Name:lower()
                    if n:find("fish") or n:find("caught") then dF = " | Fish: "..self:Fmt(st.Value) else vC = tonumber(st.Value) or 0; dC = self:Fmt(st.Value) end
                end
            end
            local pName = (p == P and CustomDisplayName ~= "") and CustomDisplayName or p.DisplayName
            table.insert(pd, {n=pName, v=vC, d=dC..dF})
        end
        table.sort(pd, self.Sort=="Val" and function(a,b) return a.v>b.v end or function(a,b) return a.n:lower()<b.n:lower() end)
        for _, d in ipairs(pd) do
            local f = C("Frame", {Parent=self.Scroll, Size=U2(1,0,0,25), BackgroundTransparency=1})
            C("TextLabel", {Parent=f, Size=U2(0.5,0,1,0), Position=U2(0,10,0,0), BackgroundTransparency=1, Text=d.n, TextColor3=C3(60,60,60), Font=F_G, TextSize=12, TextXAlignment=0})
            C("TextLabel", {Parent=f, Size=U2(0.5,-15,1,0), Position=U2(0.5,0,0,0), BackgroundTransparency=1, Text=d.d, TextColor3=C3(0,122,255), Font=F_GM, TextSize=11, TextXAlignment=1})
        end
        self.Scroll.CanvasSize = U2(0,0,0,#pd*27)
    end)
end

local FishScroll = C("ScrollingFrame", {Parent=FishBot.Frm, Size=U2(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=U2(0,0,0,580)})

-- ===== USE ROD (dropdown w/ search) =====
MkSection(FishScroll, 10, "USE ROD")
local RodListItems = {}
pcall(function()
    local allRods = RS:WaitForChild("AvatarSnapshotRods", 5)
    if allRods then
        for _, rod in ipairs(allRods:GetChildren()) do
            if rod:IsA("Instance") and rod.Name ~= "" then table.insert(RodListItems, {name = rod.Name, val = rod.Name}) end
        end
    end
end)
FishBot.SelectedRod = nil
local RodDrop = Dropdown.new(FishScroll, 35, "Select Rod:", RodListItems, function(v)
    FishBot.SelectedRod = v
    FishBot.Rod = v
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("FishingSystem"):WaitForChild("InventoryEvents"):WaitForChild("Inventory_EquipRod"):FireServer(v)
    end)
    if FishBot.LblRod then FishBot.LblRod.Text = v; FishBot.LblRod.TextColor3 = C3(0,122,255) end
    if not FishBot.Active then FishBot.Btn.BackgroundColor3 = C3(0,122,255); FishBot.Btn.Text = "Start Fishing"; FishBot.Btn.AutoButtonColor = true end
    if FishBot.ShowMsg then FishBot:ShowMsg("Use Rod: Equipped " .. v, Color3.fromRGB(0, 122, 255)) end
end, true)
RodDrop.Btn.ZIndex = 12; RodDrop.Scroll.ZIndex = 13; RodDrop:Render()

MkSection(FishScroll, 95, "INSTAN FISHING")
C("TextLabel", {Parent=FishScroll, Size=U2(0,120,0,25), Position=U2(0,20,0,125), BackgroundTransparency=1, Text="Equipped Rod:", TextColor3=C3(80,80,80), Font=F_G, TextSize=13, TextXAlignment=0})
FishBot.LblRod = C("TextLabel", {Parent=FishScroll, Size=U2(0,150,0,25), Position=U2(1,-170,0,125), BackgroundColor3=C3(235,235,235), Text="Detecting...", TextColor3=C3(100,100,100), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)})})

FishBot.TxtDelayRoll = MkInp(FishScroll, 165, "Delay Bfr Roll:", tostring(FishBot.DelayRoll), function(b) local n = tonumber(b.Text); if n then FishBot.DelayRoll = n else b.Text = tostring(FishBot.DelayRoll) end end)
FishBot.TxtDelayCatch = MkInp(FishScroll, 205, "Delay Aftr Mini:", tostring(FishBot.DelayCatch), function(b) local n = tonumber(b.Text); if n then FishBot.DelayCatch = n else b.Text = tostring(FishBot.DelayCatch) end end)
FishBot.Btn = C("TextButton", {Parent=FishScroll, Size=U2(1,-40,0,35), Position=U2(0,20,0,245), BackgroundColor3=C3(180,180,180), Text="Lock: Equip Rod", TextColor3=C3(255,255,255), Font=F_GM, TextSize=14, AutoButtonColor=false, C("UICorner",{CornerRadius=UDim.new(0,8)}), Click=function() FishBot:Start() end})

MkSection(FishScroll, 300, "PET SYSTEM")
local PetOptions = {{name="Axolotl", val="Axolotl"}, {name="Prismalune", val="Prismalune"}, {name="Ringed Python", val="Ringed Python"}, {name="Unicorn", val="Unicorn"}, {name="Capybara", val="Capybara"}, {name="Kitsune", val="Kitsune"}, {name="Polar Bear", val="Polar Bear"}, {name="Seal", val="Seal"}, {name="Arctic Fox", val="Arctic Fox"}, {name="Red Panda", val="Red Panda"}}

-- Use pet (correct remotes for this game: PetFishingVisualStart + PetFishRequest)
local function FirePetOnce(petName, slot, skipUpdate)
    if not petName or petName == "" then return end
    local petRemotes = RS:WaitForChild("PetRemotes", 5)
    if not petRemotes then
        if FishBot.ShowMsg then FishBot:ShowMsg("PetRemotes not found!", Color3.fromRGB(255,59,48)) end
        return
    end
    -- 1) equip/activate ONLY on initial selection (skip during auto cycles)
    if not skipUpdate then
        local updateRem = petRemotes:FindFirstChild(slot == 1 and "UpdatePet" or "UpdateSupportPet")
        if updateRem then pcall(function() updateRem:FireServer(true, petName) end) end
    end
    -- 2) fire the correct pet fishing remotes (same signature as other working fi scripts)
    local VisualStart = petRemotes:FindFirstChild("PetFishingVisualStart")
    local FishReq = petRemotes:FindFirstChild("PetFishRequest")
    if not (VisualStart or FishReq) then
        if FishBot.ShowMsg then FishBot:ShowMsg("Pet fishing remotes missing", Color3.fromRGB(255,59,48)) end
        return
    end
    local hrp = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local basePos = hrp.Position + (hrp.CFrame.LookVector * 15) - Vector3.new(0, 3, 0)
    if slot == 2 then basePos = basePos + (hrp.CFrame.RightVector * 4) end
    if VisualStart then pcall(function() VisualStart:FireServer(petName, basePos, slot) end) end
    if FishReq then
        if FishBot.PetBait and FishBot.PetBait ~= "" then
            pcall(function() FishReq:FireServer(petName, FishBot.PetBait, slot) end)
        else
            pcall(function() FishReq:FireServer(petName, basePos, slot) end)
        end
    end
    if FishBot.ShowMsg then FishBot:ShowMsg("Pet Slot " .. slot .. ": " .. petName .. " fishing", Color3.fromRGB(52, 199, 89)) end
end
local Pet1Drop = Dropdown.new(FishScroll, 330, "Pet Slot 1:", PetOptions, function(v) FishBot.Pet1 = v; pcall(function() game:GetService("ReplicatedStorage").PetRemotes.UpdatePet:FireServer(true, v) end); FirePetOnce(v, 1) end)
Pet1Drop.Btn.ZIndex = 10; Pet1Drop.Scroll.ZIndex = 11; Pet1Drop:Render() 
local Pet2Drop = Dropdown.new(FishScroll, 390, "Pet Slot 2:", PetOptions, function(v) FishBot.Pet2 = v; pcall(function() game:GetService("ReplicatedStorage").PetRemotes.UpdateSupportPet:FireServer(true, v) end); FirePetOnce(v, 2) end)
Pet2Drop.Btn.ZIndex = 8; Pet2Drop.Scroll.ZIndex = 9; Pet2Drop:Render() 

FishBot.TxtBait = MkInp(FishScroll, 450, "Pet Bait:", FishBot.PetBait, function(b) FishBot.PetBait = b.Text end)

local function MkTglFish(y, txt, cb) 
    local s = false; local b = C("TextButton",{Parent=FishScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,y), BackgroundColor3=C3(220,220,220), Text=txt.." [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)})});
    b.MouseButton1Click:Connect(function() s = not s; b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220); b.TextColor3 = s and C3(255,255,255) or C3(80,80,80); cb(s); b.Text = txt..(s and " [ON]" or " [OFF]") end) 
    return {Btn = b, SetState = function(state)
        if s ~= state then
            s = state
            b.Text = txt..(s and " [ON]" or " [OFF]")
            b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220)
            b.TextColor3 = s and C3(255,255,255) or C3(80,80,80)
            cb(s)
        end
    end}
end
MkTglFish(490, "Auto Pet Fish", function(v) FishBot.AutoPet = v end)

FishBot.Notif = C("TextLabel", {Parent=UI.CC, Size=U2(1,0,0,20), Position=U2(0,0,1,-25), BackgroundTransparency=1, Text="", TextColor3=C3(52,199,89), Font=F_GM, TextSize=12, TextTransparency=1})
function FishBot:ShowMsg(msg, col) self.Notif.Text = msg; self.Notif.TextColor3 = col or C3(52,199,89); TS:Create(self.Notif, TweenInfo.new(0.2), {TextTransparency = 0}):Play(); task.delay(2, function() TS:Create(self.Notif, TweenInfo.new(0.5), {TextTransparency = 1}):Play() end) end

function FishBot:DoAutoSell(isManual)
    if not self.AutoSell and not isManual then return end
    task.spawn(function()
        local s, result = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("FishingSystem"):WaitForChild("InventoryEvents"):WaitForChild("Inventory_GetData"):InvokeServer() end)
        if not s then self:ShowMsg("Auto Sell Error: Failed to contact inventory server.", C3(255,59,48)); return end
        
        local fishList = nil
        if type(result) == "table" then if result.Fish then fishList = result.Fish elseif result[1] and type(result[1]) == "table" and result[1].Fish then fishList = result[1].Fish end end
        
        if fishList and type(fishList) == "table" then
            local fishToSell = {}
            for _, fish in pairs(fishList) do if type(fish) == "table" and fish.isFavorited == false and fish.uniqueId then table.insert(fishToSell, { fishId = fish.uniqueId }) end end
            if #fishToSell > 0 then
                local s2, err2 = pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("FishingSystem"):WaitForChild("RE/SellFish"):FireServer("SellAllBatch", fishToSell) end)
                if s2 then self:ShowMsg("Auto Sell: Successfully sold " .. #fishToSell .. " fish!", C3(255,149,0)) else self:ShowMsg("Auto Sell Failed: " .. tostring(err2), C3(255,59,48)) end
            else
                self:ShowMsg("Auto Sell: No fish to sell.", C3(255,149,0))
            end
        end
    end)
    self.CurrentCatchForSell = 0; self:UpdateAutoSellUI()
end

function FishBot:Start()
    if not self.Rod then return end; self.Active = not self.Active
    self.Btn.Text = self.Active and "Stop Fishing" or "Start Fishing"
    self.Btn.BackgroundColor3 = self.Active and C3(255,59,48) or C3(0,122,255)
    if self.Active then task.spawn(function() while self.Active and self.Rod do self:Loop(); task.wait(self.Delay) end end) end
end

function FishBot:Loop()
    local c = P.Character; local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h or not self.Rod then return end
    local castPos = h.Position + (h.CFrame.LookVector * self.Dist); local tp = castPos
    
    local rayOrigin, rayDirection = castPos + Vector3.new(0, 50, 0), Vector3.new(0, -150, 0)
    local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Include; rayParams.FilterDescendantsInstances = {workspace.Terrain}
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)
    if rayResult then tp = rayResult.Position else tp = castPos - Vector3.new(0, 3, 0) end

    local res, successCatch, fishName = "Failed to catch fish", false, "Unknown Fish"
    
    local s, err = pcall(function()
        local FS = RS:WaitForChild("FishingSystem", 0.1) 
        if not FS or not c:FindFirstChild(self.Rod) then return end
        
        FS["RE/CastReplication"]:FireServer(tp, h.Position, self.Rod, 100, nil, nil)
        FS["RE/CastReplication"]:FireServer(nil, nil, nil, nil, tp)
        task.wait(self.DelayRoll)
        if not c:FindFirstChild(self.Rod) then return end

        local d = FS["RF/RollFishServer"]:InvokeServer(self.Rod, 1)
        pcall(function() if FS:FindFirstChild("GetPlayerStats") then FS.GetPlayerStats:InvokeServer() end end)
        
        local fishData = type(d) == "table" and (d[1] or d) or nil
        if type(fishData) == "table" then
            fishName = fishData.name or fishData.Name or "Unknown Fish"
            pcall(function() if FS:FindFirstChild("RE/ReplicateExclaim") then FS["RE/ReplicateExclaim"]:FireServer(fishData.rarity or "Common") end end)
            res = "Caught: " .. tostring(fishName); successCatch = true
        elseif type(d) == "string" then 
            fishName = d; res = "Caught: " .. d; successCatch = true
        end
        
        if FS:FindFirstChild("RE/NotifyMinigameStarted") then FS["RE/NotifyMinigameStarted"]:FireServer() end
        pcall(function() FS.AbilityRemotes.NotifyAbilityCast:InvokeServer() end)
        
        task.wait(self.DelayCatch)
        FS["RE/CleanupCast"]:FireServer()
        FS["RE/FishGiver"]:FireServer({hookPosition = tp})
        if RS:FindFirstChild("FishingCatchSuccess") then RS.FishingCatchSuccess:FireServer() end
        pcall(function()
            local divineEvent = RS:FindFirstChild("FishingSystem") and RS.FishingSystem:FindFirstChild("AbilityRemotes") and RS.FishingSystem.AbilityRemotes:FindFirstChild("DivineBonusFish")
            if divineEvent and firesignal and type(fishData) == "table" then
                firesignal(divineEvent.OnClientEvent, {
                    hookPosition = tp,
                    targetPosition = tp,
                    fishName = fishData.name or fishData.Name or "Unknown Fish",
                    casterName = P.Name,
                    fishRarity = fishData.rarity or "Common",
                    bonusIndex = 1,
                    fishWeight = fishData.weight or fishData.Weight or 12.5,
                    metadata = fishData.metadata or { ScaleMultiplier = 1, IsGiant = false }
                })
            end
        end)
    end)
    
    if s and successCatch and self.Active then 
        if not self.UsesLeaderstats then
            self.Caught = self.Caught + 1; self.CurrentCatchForSell = self.CurrentCatchForSell + 1
            Leaderboard.LblCaught.Text = "Total Caught: " .. self.Caught
            self:UpdateAutoSellUI()
            if self.AutoSell and self.CurrentCatchForSell >= self.AutoSellLimit then self:DoAutoSell() end
        end
        self:ShowMsg(res) 
    end
end

task.spawn(function()
    local leaderstats = P:WaitForChild("leaderstats", 10)
    if leaderstats then
        local targetStat = nil
        for _, st in ipairs(leaderstats:GetChildren()) do if st.Name:lower():find("fish") or st.Name:lower():find("caught") then targetStat = st; break end end
        if targetStat then
            FishBot.UsesLeaderstats = true; local lastVal = targetStat.Value
            targetStat.Changed:Connect(function(newVal)
                if type(newVal) == "number" and type(lastVal) == "number" and newVal > lastVal then
                    local diff = newVal - lastVal
                    FishBot.Caught = FishBot.Caught + diff; FishBot.CurrentCatchForSell = FishBot.CurrentCatchForSell + diff
                    Leaderboard.LblCaught.Text = "Total Caught: " .. FishBot.Caught
                    FishBot:UpdateAutoSellUI()
                    if FishBot.AutoSell and FishBot.CurrentCatchForSell >= FishBot.AutoSellLimit then FishBot:DoAutoSell() end
                end
                lastVal = newVal
            end)
        end
    end
end)

local QuestScroll = C("ScrollingFrame", {Parent=QuestTab.Frm, Size=U2(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=U2(0,0,0,400)})

local function MkTglQuest(y, txt, cb) 
    local s = false; local b = C("TextButton",{Parent=QuestScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,y), BackgroundColor3=C3(220,220,220), Text=txt.." [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)})});
    b.MouseButton1Click:Connect(function() 
        s = not s; 
        b.Text = txt..(s and " [ON]" or " [OFF]"); 
        b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220); 
        b.TextColor3 = s and C3(255,255,255) or C3(80,80,80); 
        cb(s)
        SaveConfig()
    end) 
    return {Btn = b, SetState = function(state)
        if s ~= state then
            s = state
            b.Text = txt..(s and " [ON]" or " [OFF]")
            b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220)
            b.TextColor3 = s and C3(255,255,255) or C3(80,80,80)
            cb(s)
        end
    end}
end

QuestTab.AutoQuestToggle = MkTglQuest(10, "Auto Quest (TP to Zone)", function(v) 
    QuestTab.AutoQuest = v 
    if not v then ShopTab.AutoPlaceTotem = false end
end)

QuestTab.AutoCaptainJonesToggle = MkTglQuest(50, "Auto Captain Jones / Withering Quest", function(v) 
    QuestTab.AutoCaptainJones = v 
    if not v then ShopTab.AutoPlaceTotem = false end
    SaveConfig()
end)

QuestTab.AutoSwapRodToggle = MkTglQuest(90, "Auto Swap Rod", function(v) QuestTab.AutoSwapRod = v end)
QuestTab.AutoSwapBaitToggle = MkTglQuest(130, "Auto Swap Bait", function(v) QuestTab.AutoSwapBait = v end)

local QuestZoneMap = {["Coral Reefs"] = Vector3.new(-3443, 232, 2160), ["Coral Reef"] = Vector3.new(-3443, 232, 2160), ["ElementalIsland"] = Vector3.new(-4851,295,170), ["ClassicIsland"] = Vector3.new(-1844, 232, 392), ["CraterIsland"] = Vector3.new(-3328, 236, -1261), ["CopperCanyon"] = Vector3.new(-3444, 232, -3378), ["StingrayShores"] = Vector3.new(-1327, 236, -3672), ["ShadowfangIsland"] = Vector3.new(1612, 246, -3147), ["VerdantIsle"] = Vector3.new(1922, 239, -111), ["ChristmasIsland"] = Vector3.new(1232,238,2094), ["AncientJungle"] = Vector3.new(-504,237,3540), ["FishermanIsland"] = Vector3.new(-557, 240, -38), ["MyticalIsland"] = Vector3.new(-205, 233, -1948), ["MythicalIsland"] = Vector3.new(-205, 233, -1948), ["StarfallGardens"] = Vector3.new(5147, 436, 5828), ["TheCelestarium"] = Vector3.new(2, 200, -8293), ["Under Water"] = Vector3.new(9103,15,119),["UnderWater"] = Vector3.new(9103,15,119),["Underwater"] = Vector3.new(9103,15,119),["CopperCanyonMines"]=Vector3.new(-3280,-163,-3448),["MachodonEvent"]=Vector3.new(-4852,295,172)}

local function getZonePosition(zoneName)
    if not zoneName then return QuestZoneMap[QuestTab.DefaultQuestZone] end
    if QuestZoneMap[zoneName] then return QuestZoneMap[zoneName] end
    local cleanTarget = tostring(zoneName):lower():gsub("%s+", "")
    for k, pos in pairs(QuestZoneMap) do
        if k:lower():gsub("%s+", "") == cleanTarget then
            return pos
        end
    end
    return QuestZoneMap[QuestTab.DefaultQuestZone]
end

local DefaultZoneList = {}
for k, _ in pairs(QuestZoneMap) do if k ~= "MyticalIsland" then table.insert(DefaultZoneList, {name = k, val = k}) end end
DefaultQuestZoneDrop = Dropdown.new(QuestScroll, 175, "Default Quest Zone", DefaultZoneList, function(v) 
    QuestTab.DefaultQuestZone = v 
    SaveConfig()
end)
DefaultQuestZoneDrop.Btn.Text = "  VerdantIsle"; DefaultQuestZoneDrop.Btn.Size = U2(1,-40,0,25); DefaultQuestZoneDrop.Scroll.Position = U2(0,20,0,220)

local ShopScroll = C("ScrollingFrame", {Parent=ShopTab.Frm, Size=U2(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=U2(0,0,0,1600)})
local spinButtonRef = nil
local totemDrop = nil 

local function MkTglShop(y, txt, cb, passBtnRef) 
    local s = false; local b = C("TextButton",{Parent=ShopScroll, Size=U2(1,-40,0,25), Position=U2(0,20,0,y), BackgroundColor3=C3(220,220,220), Text=txt.." [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)})});
    b.MouseButton1Click:Connect(function() 
        if ShopTab.AutoSpin == false and b.Text:find("Spin") and b.BackgroundColor3 == C3(220,220,220) then s = false end; 
        s = not s; 
        b.Text = txt..(s and " [ON]" or " [OFF]"); 
        b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220); 
        b.TextColor3 = s and C3(255,255,255) or C3(80,80,80); 
        cb(s) 
        SaveConfig()
    end) 
    if passBtnRef then passBtnRef(b) end
    return {Btn = b, SetState = function(state)
        if s ~= state then
            s = state
            b.Text = txt..(s and " [ON]" or " [OFF]")
            b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220)
            b.TextColor3 = s and C3(255,255,255) or C3(80,80,80)
            cb(s)
        end
    end}
end

MkSection(ShopScroll, 10, "  TOTEM")
ShopTab.AutoBuyToggle = MkTglShop(40, "Auto Buy Weather", function(v) ShopTab.AutoBuy = v end)
ShopTab.AutoTotemToggle = MkTglShop(75, "Auto Buy Totems (Stand Alone)", function(v) ShopTab.AutoTotem = v end)

ShopTab.TargetAbility = "Both"
local AbilityTargets = {{name="Deep Born", val="Deep Born"}, {name="Sakura", val="Sakura"}, {name="Glitch", val="Glitch"}}
local abilityDrop = Dropdown.new(ShopScroll, 115, "Target Spin Ability", AbilityTargets, function(v) ShopTab.TargetAbility = v end)
abilityDrop.Btn.Text = " Deep Born / Sakura / Glitch"; abilityDrop.Btn.Size = U2(1,-40,0,25); abilityDrop.Scroll.Position = U2(0,20,0,160)

MkTglShop(180, "Auto Spin Ability", function(v) ShopTab.AutoSpin = v end, function(b) spinButtonRef = b end)

local TotemTargets = {{name="All Totem", val={"Shiny Totem", "Luck Totem", "Mutation Totem"}}, {name="Luck + Mutation", val={"Luck Totem", "Mutation Totem"}}, {name="Shiny + Mutation", val={"Shiny Totem", "Mutation Totem"}}, {name="Shiny + Luck", val={"Shiny Totem", "Luck Totem"}}}
totemDrop = Dropdown.new(ShopScroll, 215, "Select Totem Combo", TotemTargets, function(v) ShopTab.TotemCombo = v end)
totemDrop.Btn.Text = "  All Totem"; totemDrop.Btn.Size = U2(1,-40,0,25); totemDrop.Scroll.Position = U2(0,20,0,260)

MkTglShop(280, "Auto Place Totem", function(v) ShopTab.AutoPlaceTotem = v end)

-- Spin Wheel Tab Content Setup with Requiem Scythe Target Automation
local SpinScroll = C("ScrollingFrame", {Parent=SpinTab.Frm, Size=U2(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=U2(0,0,0,250)})
MkSection(SpinScroll, 10, "SPIN WHEEL AUTOMATION")

local SpinTypeOptions = {{name="10x Spin", val="10x"}, {name="1x Spin", val="1x"}}
local spinTypeDrop = Dropdown.new(SpinScroll, 40, "Spin Type", SpinTypeOptions, function(v) SpinTab.SpinType = v end)
spinTypeDrop.Btn.Text = "  10x Spin"; spinTypeDrop.Btn.Size = U2(1,-40,0,25); spinTypeDrop.Scroll.Position = U2(0,20,0,85)

C("TextLabel", {Parent=SpinScroll, Size=U2(0,120,0,25), Position=U2(0,20,0,115), BackgroundTransparency=1, Text="Target Item:", TextColor3=C3(80,80,80), Font=F_G, TextSize=13, TextXAlignment=0})
C("TextButton", {Parent=SpinScroll, Size=U2(1,-40,0,25), Position=U2(0,20,0,140), BackgroundColor3=C3(235,235,235), Text="  Requiem Scythe (Target)", TextColor3=C3(50,50,50), Font=F_GM, TextSize=12, AutoButtonColor=false, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)})})

local spinWheelState = false
local spinWheelBtn = C("TextButton", {Parent=SpinScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,175), BackgroundColor3=C3(220,220,220), Text="Auto Spin Wheel [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)})})
spinWheelBtn.MouseButton1Click:Connect(function()
    spinWheelState = not spinWheelState
    SpinTab.AutoSpin = spinWheelState
    spinWheelBtn.Text = "Auto Spin Wheel " .. (spinWheelState and "[ON]" or "[OFF]")
    spinWheelBtn.BackgroundColor3 = spinWheelState and C3(0,122,255) or C3(220,220,220)
    spinWheelBtn.TextColor3 = spinWheelState and C3(255,255,255) or C3(80,80,80)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SpinTab.AutoSpin then
            pcall(function()
                local Event = RS:FindFirstChild("SpinWheelRF")
                if Event then
                    local success, result = pcall(function() return Event:InvokeServer(SpinTab.SpinType) end)
                    if success and result then
                        local foundTarget = false
                        local data = result
                        if type(data) == "table" then
                            if data.BestResult and tostring(data.BestResult.RewardName or data.BestResult.Name or ""):lower():find("requiem scythe") then
                                foundTarget = true
                            end
                            if data.AllResults and type(data.AllResults) == "table" then
                                for _, item in ipairs(data.AllResults) do
                                    if type(item) == "table" and tostring(item.RewardName or item.Name or ""):lower():find("requiem scythe") then
                                        foundTarget = true
                                        break
                                    end
                                end
                            end
                        end
                        
                        if foundTarget then
                            SpinTab.AutoSpin = false
                            spinWheelState = false
                            if spinWheelBtn then
                                spinWheelBtn.Text = "Auto Spin Wheel [OFF]"
                                spinWheelBtn.BackgroundColor3 = C3(220, 220, 220)
                                spinWheelBtn.TextColor3 = C3(80, 80, 80)
                            end
                            ShowMacOSNotification("Spin Wheel KemplongXD", "Successfully obtained Requiem Scythe!")
                        end
                    end
                end
            end)
        end
    end
end)

-- Quest Complete Webhook Listener
task.spawn(function()
    pcall(function()
        local questSys = RS:WaitForChild("FishingSystem", 5)
        if questSys then questSys = questSys:WaitForChild("QuestSystem", 5) end
        if questSys and questSys:IsA("RemoteEvent") then
            questSys.OnClientEvent:Connect(function(action, data)
                if action == "QUEST_COMPLETE" and type(data) == "table" then
                    local qName = data.questName or "Unknown Quest"
                    local msg = data.message or "Quest Completed!"
                    local rodName = data.rodName or "None"
                    
                    local durationSec = os.time() - QuestStartTime
                    local durationStr = FormatUptime(durationSec)
                    
                    ShowMacOSNotification("Quest Completed", qName .. " (" .. durationStr .. ")")
                    SendWebhook("Quest Completed!", {
                        {["name"] = "Quest Name", ["value"] = tostring(qName), ["inline"] = false},
                        {["name"] = "Details", ["value"] = tostring(msg), ["inline"] = false},
                        {["name"] = "Reward / Item", ["value"] = tostring(rodName), ["inline"] = true},
                        {["name"] = "Processing Time", ["value"] = tostring(durationStr), ["inline"] = true}
                    }, 3066993)
                    
                    QuestStartTime = os.time()
                    CurrentActiveQuestId = nil
                end
            end)
        end
    end)
end)

local function hasBait(baitName)
    local InvEvent = RS:FindFirstChild("FishingSystem") and RS.FishingSystem:FindFirstChild("InventoryEvents") and RS.FishingSystem.InventoryEvents:FindFirstChild("Inventory_GetData")
    if not InvEvent then return false end
    local s, invResult = pcall(function() return InvEvent:InvokeServer() end)
    if not s then return false end
    local data = nil
    if type(invResult) == "table" then
        if invResult.Baits then data = invResult.Baits elseif invResult[1] and invResult[1].Baits then data = invResult[1].Baits end
    end
    if not data then return false end
    for _, b in pairs(data) do
        if type(b) == "string" and string.lower(b) == string.lower(baitName) then
            return true
        elseif type(b) == "table" and (b.Name == baitName or b.name == baitName) then
            return true
        end
    end
    return false
end

-- Captain Jones / Withering Quest Automation (Unified with Regular AutoQuest Logic)
task.spawn(function()
    while task.wait(3) do
        if QuestTab.AutoCaptainJones then
            pcall(function()
                local cjRemotes = RS:FindFirstChild("CaptainJonesRemotes")
                local questResult = nil
                
                if cjRemotes then
                    for _, remoteName in ipairs({"CaptainJones_GetQuestState", "GetQuestState", "GetState", "CaptainJones_GetData"}) do
                        local cjEvent = cjRemotes:FindFirstChild(remoteName)
                        if cjEvent and cjEvent:IsA("RemoteFunction") then
                            local success, res = pcall(function() return cjEvent:InvokeServer() end)
                            if success and res then
                                questResult = res
                                break
                            end
                        end
                    end
                end
                
                if not questResult then
                    local fishingSys = RS:FindFirstChild("FishingSystem")
                    local qGetData = fishingSys and fishingSys:FindFirstChild("QuestGetData")
                    if qGetData then
                        local success, res = pcall(function() return qGetData:InvokeServer() end)
                        if success and res then
                            questResult = res
                        end
                    end
                end
                
                if questResult then
                    local questsList = nil
                    if type(questResult) == "table" then
                        if questResult.objectives or questResult.zone or questResult.Zone or questResult.completed ~= nil then
                            questsList = {questResult}
                        elseif questResult[1] and type(questResult[1]) == "table" then
                            questsList = questResult
                        elseif questResult[1] and type(questResult[1]) == "table" and questResult[1][1] then
                            questsList = questResult[1]
                        else
                            questsList = {questResult}
                        end
                    end
                    
                    local activeObj = nil
                    local foundQuestId = nil
                    for _, q in pairs(questsList) do
                        if type(q) == "table" and not q.completed then
                            foundQuestId = q.id or q.questId or q.questName or "WitheringQuest"
                            local objs = q.objectives or {q}
                            for _, obj in ipairs(objs) do
                                if type(obj) == "table" then
                                    local current = tonumber(obj.current) or tonumber(obj.Progress) or 0
                                    local required = tonumber(obj.required) or tonumber(obj.Required) or 1
                                    local isCompleted = obj.completed == true or (current >= required)
                                    if not isCompleted then
                                        activeObj = obj
                                        break
                                    end
                                end
                            end
                        end
                        if activeObj then break end
                    end
                    
                    if foundQuestId and foundQuestId ~= CurrentActiveQuestId then
                        CurrentActiveQuestId = foundQuestId
                        QuestStartTime = os.time()
                    end
                    
                    if activeObj then
                        ShopTab.AutoPlaceTotem = true
                        local targetZoneString = activeObj.zoneDisplay or activeObj.zone or activeObj.Zone or QuestTab.DefaultQuestZone
                        local tpPos = getZonePosition(targetZoneString)
                        
                        if tpPos then
                            local char = P.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local dist = hrp and (hrp.Position - tpPos).Magnitude or math.huge
                            if dist > 150 then
                                if FishBot and FishBot.ShowMsg then 
                                    FishBot:ShowMsg("Withering Quest: Auto TP to " .. tostring(targetZoneString), C3(255,149,0)) 
                                end
                                pcall(function() Teleporter:TP(tpPos, true) end)
                            end
                        end
                    else
                        ShopTab.AutoPlaceTotem = false
                        if FishBot and FishBot.ShowMsg then
                            FishBot:ShowMsg("Withering/Captain Jones Quest Completed!", C3(52, 199, 89))
                        end
                    end
                end
            end)
        else
            ShopTab.AutoPlaceTotem = false
        end
    end
end)

task.spawn(function()
    local QuestEvent = RS:WaitForChild("FishingSystem", 5)
    if QuestEvent then QuestEvent = QuestEvent:WaitForChild("QuestGetData", 5) end
    
    local lastTargetRarity = nil 
    
    local function EquipBestRodForQuest(targetRarity)
        if not QuestTab.AutoSwapRod then return end
        local InvEvent = game:GetService("ReplicatedStorage").FishingSystem.InventoryEvents.Inventory_GetData
        local s, invResult = pcall(function() return InvEvent:InvokeServer() end)
        if not s then return end

        local data = nil
        if type(invResult) == "table" then
            if invResult.Rods then data = invResult elseif invResult[1] and invResult[1].Rods then data = invResult[1] end
        end
        if not data then return end

        local rods, enchants, rodToEquip = data.Rods or {}, data.RodEnchants or {}, nil
        local function hasEnchant(rodName, enchantName)
            if not enchants[rodName] then return false end
            for _, e in ipairs(enchants[rodName]) do if string.lower(e) == string.lower(enchantName) then return true end end
            return false
        end
        if targetRarity == "forgotten" then
            for _, r in ipairs(rods) do if hasEnchant(r, "FORGOTTEN Hunter") then rodToEquip = r; break end end
        elseif targetRarity == "secret" then
            for _, r in ipairs(rods) do if hasEnchant(r, "SECRET Hunter") then rodToEquip = r; break end end
        elseif targetRarity == "mytical" or targetRarity == "mitos" then
            for _, r in ipairs(rods) do if hasEnchant(r, "Mytical Hunter") then rodToEquip = r; break end end
        elseif targetRarity == "legendary" then
            for _, r in ipairs(rods) do if not hasEnchant(r, "SECRET Hunter") and not hasEnchant(r, "Mytical Hunter") then rodToEquip = r; break end end
        elseif targetRarity == "epic" then
            for _, r in ipairs(rods) do if r == "Gold Rod" then rodToEquip = r; break end end
        end

        if rodToEquip then
            pcall(function() game:GetService("ReplicatedStorage").FishingSystem.InventoryEvents.Inventory_EquipRod:FireServer(rodToEquip) end)
            if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Quest Auto-Swap: Equipped " .. rodToEquip, Color3.fromRGB(0, 122, 255)) end
        end
    end
    
    while task.wait(5) do
        if QuestTab.AutoQuest and QuestEvent then
            local success, result = pcall(function() return QuestEvent:InvokeServer() end)
            if success and type(result) == "table" then
                local questsList = nil
                if result[1] and type(result[1]) == "table" then
                    if result[1].completed ~= nil then questsList = result elseif result[1][1] and type(result[1][1]) == "table" then questsList = result[1] end
                end
                if not questsList then continue end
                
                local activeObj = nil
                local foundQuestId = nil
                for _, q in pairs(questsList) do
                    if type(q) == "table" and not q.completed and type(q.objectives) == "table" then
                        foundQuestId = q.id or q.questId or q.questName
                        for _, obj in ipairs(q.objectives) do
                            if type(obj) == "table" and (tonumber(obj.current) or 0) < (tonumber(obj.required) or 0) then activeObj = obj; break end
                        end
                    end
                    if activeObj then break end
                end
                
                if foundQuestId and foundQuestId ~= CurrentActiveQuestId then
                    CurrentActiveQuestId = foundQuestId
                    QuestStartTime = os.time()
                end
                
                if activeObj then
                    local targetZoneString = activeObj.zone or QuestTab.DefaultQuestZone
                    local tpPos = getZonePosition(targetZoneString)
                    local targetRarity = tostring(activeObj.rarity or ""):lower()
                    
                    if targetRarity ~= lastTargetRarity then
                        lastTargetRarity = targetRarity
                        if QuestTab.AutoSwapRod then EquipBestRodForQuest(targetRarity) end
                    end
                    
                    if targetRarity == "secret" or targetRarity == "forgotten" then
                        ShopTab.TotemCombo, ShopTab.AutoPlaceTotem = {"Luck Totem", "Mutation Totem"}, true
                        pcall(function() if totemDrop then totemDrop.Btn.Text = "  Luck + Mutation" end end)
                        
                        if QuestTab.AutoSwapBait then
                            local selectedBait = "Floral Bait"
                            if hasBait("Aetherion Bait") then selectedBait = "Aetherion Bait" end
                            pcall(function() game:GetService("ReplicatedStorage").FishingSystem.InventoryEvents.Inventory_EquipBait:FireServer(selectedBait) end)
                        end
                    elseif targetRarity == "mythical" or targetRarity == "mitos" then
                        ShopTab.TotemCombo, ShopTab.AutoPlaceTotem = {"Luck Totem", "Mutation Totem"}, true
                        pcall(function() if totemDrop then totemDrop.Btn.Text = "  Luck + Mutation" end end)
                        if QuestTab.AutoSwapBait then
                            pcall(function() game:GetService("ReplicatedStorage").FishingSystem.InventoryEvents.Inventory_EquipBait:FireServer("Singularity Bait") end)
                        end
                    elseif targetRarity == "legendary" then
                        ShopTab.TotemCombo, ShopTab.AutoPlaceTotem = {"Shiny Totem", "Mutation Totem"}, true
                        pcall(function() if totemDrop then totemDrop.Btn.Text = "  Shiny + Mutation" end end)
                        if QuestTab.AutoSwapBait then
                            pcall(function() game:GetService("ReplicatedStorage").FishingSystem.InventoryEvents.Inventory_EquipBait:FireServer("Royal Bait") end)
                        end
                    elseif targetRarity == "epic" then
                        ShopTab.TotemCombo, ShopTab.AutoPlaceTotem = {"Mutation Totem"}, true
                        pcall(function() if totemDrop then totemDrop.Btn.Text = " Mutation " end end)
                        if QuestTab.AutoSwapBait then
                            pcall(function() game:GetService("ReplicatedStorage").FishingSystem.InventoryEvents.Inventory_EquipBait:FireServer("Beach Ball Bait") end)
                        end
                    end
                    
                    if tpPos then
                        local char = P.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local dist = hrp and (hrp.Position - tpPos).Magnitude or math.huge
                        if dist > 150 then
                            if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Quest: Auto TP to " .. targetZoneString, C3(255,149,0)) end
                            pcall(function() Teleporter:TP(tpPos, true) end)
                        end
                    end
                end
            end
        else
            lastTargetRarity = nil
            ShopTab.AutoPlaceTotem = false
        end
    end
end)

function Teleporter:TP(pos, requirePlatform) 
    local c = P.Character; local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then 
        self.EventPlat.CFrame = CFrame.new(pos) - Vector3.new(0, 3.5, 0); self.EventPlat.CanCollide = true
        h.Anchored = true; h.CFrame = CFrame.new(pos) + Vector3.new(0, 5, 0) 
        if request_stream then pcall(request_stream, pos) end
        task.spawn(function()
            local timeout = tick() + 3
            repeat task.wait(0.1) until (not P.GameplayPaused) or tick() > timeout
            task.wait(0.3); h.Anchored = false
            if not requirePlatform then self.EventPlat.CanCollide = false; self.EventPlat.CFrame = CFrame.new(0, -9999, 0) end
        end)
    end 
end

function Teleporter:GetPlr() 
    local l = {}; 
    pcall(function() for _, p in ipairs(game.Players:GetPlayers()) do if p ~= P then table.insert(l, {name = p.DisplayName .. " (@" .. p.Name .. ")", val = p.Name}) end end end)
    return l 
end

local OriginalIslands = {{name="Classic Island", val=Vector3.new(-1764,245,396)}, {name="Coral Reef", val=Vector3.new(-3405,253,1918)}, {name="Crater Island", val=Vector3.new(-3179,240,-1128)}, {name="Copper Canyon", val=Vector3.new(-3342,256,-3389)},{name="Copper Canyon Mines", val=Vector3.new(-3281,-163,-3447)}, {name="Stingray Shores", val=Vector3.new(-1392,303,-3641)}, {name="Shadowfang Island", val=Vector3.new(1397,337,-3041)}, {name="Verdant Isle", val=Vector3.new(1798,255,-184)}, {name="Christmas Island", val=Vector3.new(1345,258,2098)}, {name="Ancient Jungle", val=Vector3.new(-428,244,3648)}, {name="Fisherman Island", val=Vector3.new(-393,243,-20)}, {name="Mythical Island", val=Vector3.new(-215,250,-1787)}, {name="Starfall Garden", val=Vector3.new(5147, 436, 5828)}, {name="The Celestarium", val=Vector3.new(2, 200, -8293)}, {name="Underwater", val=Vector3.new(9102, 15, 118)}, {name="Elemental Island", val=Vector3.new(-4851,295,170)}}
local Events = {{name="Machodon Event", val={pos=Vector3.new(-1381,310,-1781), plat=false}}, {name="Limited Event", val={pos=Vector3.new(256,273,-841), plat=true}}, {name="Megalodon Event", val={pos=Vector3.new(-507, 234, -598), plat=true}}, {name="Bermuda Triangle", val={pos=Vector3.new(384,233,1525), plat=true}}}

Dropdown.new(Teleporter.Frm, 5, "Select Island", OriginalIslands, function(v) Teleporter.S_Isl = v end)
C("TextButton", {Parent=Teleporter.Frm, Size=U2(1,-40,0,25), Position=U2(0,20,0,52), BackgroundColor3=C3(0,122,255), Text="Teleport to Island", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, ZIndex=1, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() if Teleporter.S_Isl then Teleporter:TP(Teleporter.S_Isl, false) end end})

Dropdown.new(Teleporter.Frm, 82, "Select Event", Events, function(v) Teleporter.S_Evt = v end)
C("TextButton", {Parent=Teleporter.Frm, Size=U2(1,-40,0,25), Position=U2(0,20,0,129), BackgroundColor3=C3(255,149,0), Text="Teleport to Event", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, ZIndex=1, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() if Teleporter.S_Evt then Teleporter:TP(Teleporter.S_Evt.pos, Teleporter.S_Evt.plat) end end})

Teleporter.PlrDrop = Dropdown.new(Teleporter.Frm, 160, "Select Player", Teleporter:GetPlr(), function(v) Teleporter.S_Plr = v end)
C("TextButton", {Parent=Teleporter.Frm, Size=U2(0,60,0,20), Position=U2(1,-80,0,160), BackgroundColor3=C3(0,122,255), Text="Refresh", TextColor3=C3(255,255,255), Font=F_GM, TextSize=11, C("UICorner",{CornerRadius=UDim.new(0,4)}), Click=function() Teleporter.PlrDrop:Render(Teleporter:GetPlr()); Teleporter.PlrDrop:Reset(); Teleporter.S_Plr=nil end})
C("TextButton", {Parent=Teleporter.Frm, Size=U2(1,-40,0,25), Position=U2(0,20,0,207), BackgroundColor3=C3(0,122,255), Text="Teleport to Player", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, ZIndex=1, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() 
    if Teleporter.S_Plr then
        pcall(function()
            local targetPlayer = game:GetService("Players"):FindFirstChild(Teleporter.S_Plr)
            if targetPlayer and targetPlayer.Character then
                local success, cf = pcall(function() return targetPlayer.Character:GetPivot() end)
                if success and cf then Teleporter:TP((cf * CFrame.new(0, 0, 3)).Position, false) else if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Player too far!", C3(255,59,48)) end end
            end 
        end)
    end
end})

local MiscScroll = C("ScrollingFrame", {Parent=MiscTools.Frm, Size=U2(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, CanvasSize=U2(0,0,0,1000)})
local function MkTgl(y, txt, cb) 
    local s = false; local b = C("TextButton",{Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,y), BackgroundColor3=C3(220,220,220), Text=txt.." [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)})});
    b.MouseButton1Click:Connect(function() 
        s = not s; 
        b.Text = txt..(s and " [ON]" or " [OFF]"); 
        b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220); 
        b.TextColor3 = s and C3(255,255,255) or C3(80,80,80); 
        cb(s)
        SaveConfig()
    end) 
    return {Btn = b, SetState = function(state)
        if s ~= state then
            s = state
            b.Text = txt..(s and " [ON]" or " [OFF]")
            b.BackgroundColor3 = s and C3(0,122,255) or C3(220,220,220)
            b.TextColor3 = s and C3(255,255,255) or C3(80,80,80)
            cb(s)
        end
    end}
end

local IdledConnection, AFKLoop = nil, nil
MiscTools.AfkToggle = MkTgl(10, "Anti AFK", function(v) 
    MiscTools.AFK = v 
    if v then
        if getconnections then pcall(function() for _, conn in pairs(getconnections(P.Idled)) do if conn.Disable then conn:Disable() end end end) end
        IdledConnection = P.Idled:Connect(function() if not MiscTools.AFK then return end; pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new(0, 0)) end); pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.F15, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.F15, false, game) end) end)
        AFKLoop = task.spawn(function()
            local cam = workspace.CurrentCamera
            while MiscTools.AFK and task.wait(math.random(12, 18)) do
                pcall(function() game:GetService("ReplicatedStorage").Events.PlayerActive:FireServer() end)
                pcall(function()
                    local vpSize = cam.ViewportSize; local rx, ry = math.random(10, math.max(20, vpSize.X - 10)), math.random(10, math.max(20, vpSize.Y - 10))
                    VIM:SendMouseMovementEvent(rx, ry, game); VIM:SendMouseButtonEvent(rx, ry, 0, true, game, 1); task.wait(0.05); VIM:SendMouseButtonEvent(rx, ry, 0, false, game, 1)
                    cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(math.random(-2, 2)), math.rad(math.random(-2, 2)), 0)
                    local char = P.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and not hrp.Anchored then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-3, 3) / 10), 0) end
                end)
            end
        end)
    else
        if getconnections then pcall(function() for _, conn in pairs(getconnections(P.Idled)) do if conn.Enable then conn:Enable() end end end) end
        if IdledConnection then IdledConnection:Disconnect(); IdledConnection = nil end
        if AFKLoop then task.cancel(AFKLoop); AFKLoop = nil end
    end
end);

MkTgl(50, "Skywalk Platform", function(v) MiscTools.SW = v end)
C("TextButton",{Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,90), BackgroundColor3=C3(0,122,255), Text="Boost FPS (Remove Textures)", TextColor3=C3(255,255,255), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() pcall(function() game.Lighting.GlobalShadows = false; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end end end) end})
C("TextButton",{Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,130), BackgroundColor3=C3(255,149,0), Text="Rejoin Server", TextColor3=C3(255,255,255), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() pcall(function() TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId, P) end) end})
C("TextButton",{Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,170), BackgroundColor3=C3(150,50,255), Text="Server Hop", TextColor3=C3(255,255,255), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() pcall(function() local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")); for _, s in pairs(servers.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then TPS:TeleportToPlaceInstance(game.PlaceId, s.id, P); break end end end) end})

MkSection(MiscScroll, 215, "WEBHOOK SETTINGS")

WebhookToggle = MkTgl(245, "Webhook System", function(v) 
    WebhookActive = v 
    if v then LastWebhookTime = os.time() end
end)

WHBox = C("TextBox", {Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,285), BackgroundColor3=C3(255,255,255), Text="", PlaceholderText="Paste Webhook URL here then press Enter...", TextColor3=C3(50,50,50), Font=F_G, TextSize=11, ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Left, C("UICorner",{CornerRadius=UDim.new(0,6)}), C("UIStroke",{Color=C3(210,210,210)})})
WHBox.FocusLost:Connect(function() 
    if WHBox.Text ~= "" and WHBox.Text:find("http") then 
        WebhookURL = WHBox.Text 
        SaveConfig()
    else 
        if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Invalid Webhook URL!", C3(255,59,48)) end 
    end 
end)

local ModeDropItems = { {name="Anonymous (KemplongXDOnTop)", val="Anonim"}, {name="Real Roblox Username", val="Asli"} }
ModeDrop = Dropdown.new(MiscScroll, 325, "Webhook Profile Mode", ModeDropItems, function(v) 
    WebhookMode = v 
    SaveConfig()
end)
ModeDrop.Btn.Text = "  Anonymous (KemplongXDOnTop)"; ModeDrop.Btn.Size = U2(1,-40,0,25); ModeDrop.Scroll.Position = U2(0,20,0,370)

WHIntervalBox = MkInp(MiscScroll, 405, "Send Every (Mins):", tostring(WebhookInterval), function(b) 
    local n = tonumber(b.Text) 
    if n and n > 0 then 
        WebhookInterval = n; 
        LastWebhookTime = os.time() 
        SaveConfig()
    else 
        b.Text = tostring(WebhookInterval) 
    end 
end)

C("TextButton", {Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,445), BackgroundColor3=C3(0,122,255), Text="Test Send Manual Webhook", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function()
    if WebhookURL == "" then return end
    local upStr = FormatUptime(os.time() - ScriptStartTime)
    SendWebhook("Webhook Manual Test", {{["name"] = "Status", ["value"] = "Connection Successful!", ["inline"] = true}, {["name"] = "Profile Mode", ["value"] = WebhookMode, ["inline"] = true}, {["name"] = "Script Uptime", ["value"] = upStr, ["inline"] = false}, {["name"] = "System", ["value"] = "Fishing Island Automation", ["inline"] = false}}, 3447003)
end})

-- FITUR CUSTOM OVERHEAD INFO (Menargetkan workspace.[namaplayer].Head.OverheadGui.Info.DisplayName, Peringkat, & Title)
local function ApplyCustomOverheadInfo()
    pcall(function()
        local char = P.Character
        if char and char:FindFirstChild("Head") then
            local head = char.Head
            local overheadGui = head:FindFirstChild("OverheadGui")
            if overheadGui then
                local info = overheadGui:FindFirstChild("Info")
                if info then
                    -- DisplayName
                    if info:FindFirstChild("DisplayName") and EnableCustomDisplayName then
                        local dn = info.DisplayName
                        if dn:IsA("TextLabel") or dn:IsA("TextButton") then
                            dn.Text = (CustomDisplayName ~= "" and CustomDisplayName or P.DisplayName)
                        end
                    end
                    -- Peringkat (Level dengan prefix "Level ")
                    if info:FindFirstChild("Peringkat") and EnableCustomLevel then
                        local pr = info.Peringkat
                        if pr:IsA("TextLabel") or pr:IsA("TextButton") then
                            local num = tostring(CustomLevel):gsub("[^0-9]", "")
                            if num == "" then num = "1" end
                            pr.Text = "Level " .. num
                        end
                    end
                    -- Title (VIP Text)
                    if info:FindFirstChild("Title") and EnableCustomTitle then
                        local ttl = info.Title
                        if ttl:IsA("TextLabel") or ttl:IsA("TextButton") then
                            ttl.Text = CustomTitle
                        end
                    end
                end
            end
        end
        if LeaderboardNameLbl and EnableCustomDisplayName then
            LeaderboardNameLbl.Text = CustomDisplayName ~= "" and CustomDisplayName or P.DisplayName
        end
    end)
end

P.CharacterAdded:Connect(function()
    task.wait(1)
    ApplyCustomOverheadInfo()
end)

-- Loop pengecekan berkala agar OverheadGui yang baru dimuat/direfresh server tetap terubah otomatis
task.spawn(function()
    while task.wait(1) do
        ApplyCustomOverheadInfo()
    end
end)

MkSection(MiscScroll, 490, "CUSTOM OVERHEAD INFO")

CustomDisplayNameToggle = MkTgl(520, "Custom Display Name", function(v)
    EnableCustomDisplayName = v
    ApplyCustomOverheadInfo()
    SaveConfig()
end)
DisplayNameInp = MkInp(MiscScroll, 560, "Display Name:", CustomDisplayName, function(b)
    CustomDisplayName = b.Text ~= "" and b.Text or P.DisplayName
    ApplyCustomOverheadInfo()
    SaveConfig()
end)

CustomLevelToggle = MkTgl(600, "Custom Level", function(v)
    EnableCustomLevel = v
    ApplyCustomOverheadInfo()
    SaveConfig()
end)
LevelInp = MkInp(MiscScroll, 640, "Level (Angka):", CustomLevel, function(b)
    local num = b.Text:gsub("[^0-9]", "")
    if num == "" then num = "1" end
    CustomLevel = num
    b.Text = num
    ApplyCustomOverheadInfo()
    SaveConfig()
end)

CustomTitleToggle = MkTgl(680, "Custom Title", function(v)
    EnableCustomTitle = v
    ApplyCustomOverheadInfo()
    SaveConfig()
end)
TitleInp = MkInp(MiscScroll, 720, "Title / VIP Text:", CustomTitle, function(b)
    CustomTitle = b.Text
    ApplyCustomOverheadInfo()
    SaveConfig()
end)

C("TextButton", {Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,760), BackgroundColor3=C3(0,122,255), Text="Apply & Save All Info", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function()
    CustomDisplayName = DisplayNameInp.Text ~= "" and DisplayNameInp.Text or P.DisplayName
    local num = LevelInp.Text:gsub("[^0-9]", "")
    if num == "" then num = "1" end
    CustomLevel = num
    LevelInp.Text = num
    CustomTitle = TitleInp.Text
    ApplyCustomOverheadInfo()
    SaveConfig()
    if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Overhead info updated successfully!", C3(52,199,89)) end
end})

-- FITUR CONFIG OTOMATIS (AUTO CONFIG)
MkSection(MiscScroll, 805, "AUTO CONFIGURATION")
C("TextButton", {Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,835), BackgroundColor3=C3(52,199,89), Text="Save Config Manually", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function()
    SaveConfig()
    if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Configuration saved successfully!", C3(52,199,89)) end
end})
C("TextButton", {Parent=MiscScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,875), BackgroundColor3=C3(0,122,255), Text="Reload Config Manually", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function()
    LoadConfig()
    if DisplayNameInp then DisplayNameInp.Text = CustomDisplayName end
    if LevelInp then LevelInp.Text = CustomLevel end
    if TitleInp then TitleInp.Text = CustomTitle end
    ApplyCustomOverheadInfo()
    if FishBot and FishBot.ShowMsg then FishBot:ShowMsg("Configuration loaded successfully!", C3(52,199,89)) end
end})

MkSection(ShopScroll, 365, "ENCHANT")
local TargetEnchantsList = {{name="Reeler II", val="Reeler II"}, {name="Reeler I", val="Reeler I"}, {name="FORGOTTEN Hunter", val="FORGOTTEN Hunter"}, {name="SECRET Hunter", val="SECRET Hunter"}, {name="Mytical Hunter", val="Mytical Hunter"}, {name="Fairy Hunter", val="Fairy Hunter"}, {name="Mutation Hunter I", val="Mutation Hunter I"}, {name="Mutation Hunter II", val="Mutation Hunter II"}, {name="Mutation Hunter III", val="Mutation Hunter III"}, {name="Cursed I", val="Cursed I"}, {name="Big Hunter I", val="Big Hunter I"}, {name="Empowered I", val="Empowered I"}}
local enchantTargetDrop = MultiDropdown.new(ShopScroll, 395, "Target Enchants (Multi)", TargetEnchantsList, function(v) MiscTools.TargetEnchants = v end)
local Slots = { {name="Slot 1", val=1}, {name="Slot 2", val=2} }
local enchantSlotDrop = Dropdown.new(ShopScroll, 465, "Enchant Slot", Slots, function(v) MiscTools.EnchantSlot = v end); enchantSlotDrop.Btn.Text = "  Slot 1"

local autoRollState, autoRollBtn = false, C("TextButton",{Parent=ShopScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,535), BackgroundColor3=C3(220,220,220), Text="Auto Roll Enchant [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)})})
autoRollBtn.MouseButton1Click:Connect(function() autoRollState = not autoRollState; autoRollBtn.Text = "Auto Roll Enchant"..(autoRollState and" [ON]"or" [OFF]"); autoRollBtn.BackgroundColor3 = autoRollState and C3(0,122,255) or C3(220,220,220); autoRollBtn.TextColor3 = autoRollState and C3(255,255,255) or C3(80,80,80); MiscTools.AutoRoll = autoRollState end)

MkSection(ShopScroll, 580, "INVENTORY & SELL")
local autoSellState = false
FishBot.AutoSellBtn = C("TextButton",{Parent=ShopScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,610), BackgroundColor3=C3(220,220,220), Text="Auto Sell Fish (0/"..tostring(FishBot.AutoSellLimit)..") [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)})})
FishBot.AutoSellBtn.MouseButton1Click:Connect(function() 
    autoSellState = not autoSellState; 
    FishBot.AutoSell = autoSellState; 
    FishBot.AutoSellBtn.BackgroundColor3 = autoSellState and C3(0,122,255) or C3(220,220,220); 
    FishBot.AutoSellBtn.TextColor3 = autoSellState and C3(255,255,255) or C3(80,80,80); 
    FishBot:UpdateAutoSellUI()
    SaveConfig()
end)
FishBot.TxtAutoSell = MkInp(ShopScroll, 650, "Auto Sell Every:", tostring(FishBot.AutoSellLimit), function() 
    local newVal = tonumber(FishBot.TxtAutoSell.Text); 
    if newVal and newVal > 0 then 
        FishBot.AutoSellLimit = newVal 
    else 
        FishBot.TxtAutoSell.Text = tostring(FishBot.AutoSellLimit) 
    end; 
    FishBot:UpdateAutoSellUI()
    SaveConfig()
end)
C("TextButton", {Parent=ShopScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,690), BackgroundColor3=C3(255,149,0), Text="Force Sell All (Unfavorited)", TextColor3=C3(255,255,255), Font=F_GM, TextSize=12, C("UICorner",{CornerRadius=UDim.new(0,6)}), Click=function() FishBot:DoAutoSell(true) end})

-- FITUR AUTO FAVORITE DENGAN LOGIKA DIPERBAIKI
MkSection(ShopScroll, 735, "AUTO FAVORITE (FISH & VARIANTS)")

local AutoFavoriteActive = false
local AutoFavoriteFishSelections = {}
local AutoFavoriteVariantSelections = {}

local autoFavFishDrop = MultiDropdown.new(ShopScroll, 765, "Select Fish to Favorite", FishListItems, function(v) AutoFavoriteFishSelections = v end)
local autoFavVarDrop = MultiDropdown.new(ShopScroll, 825, "Select Variants to Favorite", VariantListItems, function(v) AutoFavoriteVariantSelections = v end)

local autoFavState, autoFavBtn = false, C("TextButton",{Parent=ShopScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,885), BackgroundColor3=C3(220,220,220), Text="Auto Favorite [OFF]", TextColor3=C3(80,80,80), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)})})
autoFavBtn.MouseButton1Click:Connect(function()
    autoFavState = not autoFavState
    AutoFavoriteActive = autoFavState
    autoFavBtn.Text = "Auto Favorite " .. (autoFavState and "[ON]" or "[OFF]")
    autoFavBtn.BackgroundColor3 = autoFavState and C3(0,122,255) or C3(220,220,220)
    autoFavBtn.TextColor3 = autoFavState and C3(255,255,255) or C3(80,80,80)
end)

-- Background Task untuk Auto Favorite dengan Logika Baru
task.spawn(function()
    while task.wait(2) do
        if AutoFavoriteActive then
            pcall(function()
                local InvEvent = RS:WaitForChild("FishingSystem", 5) and RS.FishingSystem:WaitForChild("InventoryEvents", 5) and RS.FishingSystem.InventoryEvents:WaitForChild("Inventory_GetData", 5)
                local ToggleFavEvent = RS:WaitForChild("FishingSystem", 5) and RS.FishingSystem:WaitForChild("InventoryEvents", 5) and RS.FishingSystem.InventoryEvents:WaitForChild("Inventory_ToggleFavorite", 5)
                
                if InvEvent and ToggleFavEvent then
                    local success, result = pcall(function() return InvEvent:InvokeServer() end)
                    if success and type(result) == "table" then
                        local fishList = nil
                        if result.Fish then fishList = result.Fish elseif result[1] and type(result[1]) == "table" and result[1].Fish then fishList = result[1].Fish end
                        
                        if fishList and type(fishList) == "table" then
                            local anyFishSel = false
                            for _, v in pairs(AutoFavoriteFishSelections) do if v then anyFishSel = true; break end end
                            
                            local anyVarSel = false
                            for _, v in pairs(AutoFavoriteVariantSelections) do if v then anyVarSel = true; break end end
                            
                            if anyFishSel or anyVarSel then
                                for _, fish in pairs(fishList) do
                                    if type(fish) == "table" and fish.isFavorited == false and fish.uniqueId then
                                        local fName = fish.name or fish.Name or ""
                                        local fVar = fish.variantId or fish.VariantId or "Normal"
                                        
                                        local matchFish = anyFishSel and AutoFavoriteFishSelections[fName]
                                        local matchVar = anyVarSel and AutoFavoriteVariantSelections[fVar]
                                        
                                        local shouldFav = false
                                        if anyFishSel and anyVarSel then
                                            shouldFav = matchFish and matchVar
                                        elseif anyFishSel then
                                            shouldFav = matchFish
                                        elseif anyVarSel then
                                            shouldFav = matchVar
                                        end
                                        
                                        if shouldFav then
                                            pcall(function()
                                                ToggleFavEvent:InvokeServer(fish.uniqueId)
                                                task.wait(0.1)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- HELPER PRESISI TINGGI UNTUK 100% AKURAT MINIGAME CLICK
local function executePerfectCraft(craftArg, notificationTitle, statusLabelRef)
    task.spawn(function()
        local Remotes = RS:FindFirstChild("BlacksmithRemotes")
        if not Remotes then 
            if statusLabelRef then statusLabelRef.Text = "Status: Error (Remotes not found!)" end
            return 
        end
        
        if statusLabelRef then statusLabelRef.Text = "Status: Checking..." end
        pcall(function() 
            if craftArg then
                Remotes.Blacksmith_CheckCanCraft:InvokeServer(craftArg)
            else
                Remotes.Blacksmith_CheckCanCraft:InvokeServer()
            end
        end)
        
        if statusLabelRef then statusLabelRef.Text = "Status: Starting..." end
        local success, _, res2 = pcall(function() 
            if craftArg then
                return Remotes.Blacksmith_StartCrafting:InvokeServer(craftArg)
            else
                return Remotes.Blacksmith_StartCrafting:InvokeServer()
            end
        end)

        if success and type(res2) == "table" and res2.minigame and res2.minigame.bars then
            local minigameData = res2.minigame
            local rtt = 0.05 
            
            for i, barData in ipairs(minigameData.bars) do
                local period = barData.Period or 1
                local timeToFull = period / 2
                local waitTime = (i == 1) and (timeToFull - (rtt / 2)) or (timeToFull - rtt)
                if waitTime < 0 then waitTime = 0 end
                
                local targetTime = os.clock() + waitTime
                while os.clock() < targetTime do
                    RunS.Heartbeat:Wait()
                end
                
                local invokeStart = os.clock()
                pcall(function() Remotes.Blacksmith_MinigameClick:InvokeServer() end)
                rtt = math.clamp(os.clock() - invokeStart, 0.01, 0.2)
                
                if statusLabelRef then 
                    statusLabelRef.Text = string.format("Status: Perfect %d/%d (Lag: %dms)", i, #minigameData.bars, math.floor(rtt * 1000))
                end
            end
        end
        
        if statusLabelRef then statusLabelRef.Text = "Status: Confirming..." end
        pcall(function() Remotes.Blacksmith_ConfirmCrafting:InvokeServer() end)
        
        if statusLabelRef then statusLabelRef.Text = "Status: Crafted Perfectly!" end
        if ShowMacOSNotification and notificationTitle then
            ShowMacOSNotification("Blacksmith Craft", notificationTitle)
        end
        
        task.wait(2)
        if statusLabelRef then statusLabelRef.Text = "Status: Idle" end
    end)
end

-- AUTO PERFECT WITHERING ROD
MkSection(ShopScroll, 925, "AUTO PERFECT WITHERING ROD")
local rodStatusLabel = C("TextLabel", {Parent=ShopScroll, Size=U2(1,-40,0,20), Position=U2(0,20,0,975), BackgroundTransparency=1, Text="Status: Idle", TextColor3=C3(150,150,150), Font=F_GM, TextSize=12, TextXAlignment=0})
local rodBtn = C("TextButton",{Parent=ShopScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,945), BackgroundColor3=C3(100, 70, 255), Text="Execute Perfect Craft (Rod)", TextColor3=C3(255,255,255), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)})})

rodBtn.MouseButton1Click:Connect(function()
    TS:Create(rodBtn, TweenInfo.new(0.1), {BackgroundColor3 = C3(70, 50, 200)}):Play()
    task.wait(0.1)
    TS:Create(rodBtn, TweenInfo.new(0.1), {BackgroundColor3 = C3(100, 70, 255)}):Play()
    executePerfectCraft(nil, "Perfect Rod Crafting completed!", rodStatusLabel)
end)

-- AUTO PERFECT WITHERING BAIT
MkSection(ShopScroll, 1000, "AUTO PERFECT WITHERING BAIT")
local baitStatusLabel = C("TextLabel", {Parent=ShopScroll, Size=U2(1,-40,0,20), Position=U2(0,20,0,1070), BackgroundTransparency=1, Text="Status: Idle", TextColor3=C3(150,150,150), Font=F_GM, TextSize=12, TextXAlignment=0})
local baitBtn = C("TextButton",{Parent=ShopScroll, Size=U2(1,-40,0,30), Position=U2(0,20,0,1030), BackgroundColor3=C3(100, 70, 255), Text="Execute Perfect Craft (Bait)", TextColor3=C3(255,255,255), Font=F_GM, TextSize=13, C("UICorner",{CornerRadius=UDim.new(0,6)})})

baitBtn.MouseButton1Click:Connect(function()
    TS:Create(baitBtn, TweenInfo.new(0.1), {BackgroundColor3 = C3(70, 50, 200)}):Play()
    task.wait(0.1)
    TS:Create(baitBtn, TweenInfo.new(0.1), {BackgroundColor3 = C3(100, 70, 255)}):Play()
    executePerfectCraft("Bait", "Perfect Bait Crafting completed!", baitStatusLabel)
end)

task.spawn(function()
    local FishingSys = RS:WaitForChild("FishingSystem", 5)
    local RollEvent = FishingSys and FishingSys:WaitForChild("RF/RollEnchantServer", 5)
    local SelectSlotEvent = FishingSys and FishingSys:WaitForChild("RF/SelectEnchantSlotServer", 5)
    
    while task.wait(1.5) do
        if MiscTools.AutoRoll and RollEvent and SelectSlotEvent then
            local hasTarget = false
            for _, isSelected in pairs(MiscTools.TargetEnchants or {}) do if isSelected then hasTarget = true; break end end
            
            if not hasTarget then
                MiscTools.AutoRoll, autoRollState = false, false
                pcall(function() autoRollBtn.Text = "Auto Roll Enchant [OFF]"; autoRollBtn.BackgroundColor3 = C3(220,220,220); autoRollBtn.TextColor3 = C3(80,80,80) end)
                continue
            end
            
            local s, res = pcall(function() return table.pack(RollEvent:InvokeServer()) end)
            if s and type(res) == "table" and res[1] == true and type(res[2]) == "table" then
                local rolledName = res[2].Name
                if MiscTools.TargetEnchants and MiscTools.TargetEnchants[rolledName] then
                    pcall(function() SelectSlotEvent:InvokeServer(MiscTools.EnchantSlot) end)
                    MiscTools.AutoRoll, autoRollState = false, false
                    pcall(function() autoRollBtn.Text = "Auto Roll Enchant [OFF]"; autoRollBtn.BackgroundColor3 = C3(220,220,220); autoRollBtn.TextColor3 = C3(80,80,80) end)
                    ShowMacOSNotification("Enchant KemplongXD", "Successfully got " .. rolledName .. " in Slot " .. MiscTools.EnchantSlot .. "!")
                end
            else task.wait(2) end
        end
    end
end)

function FishBot:UpdateAutoSellUI() if self.AutoSellBtn then self.AutoSellBtn.Text = "Auto Sell Fish ("..self.CurrentCatchForSell.."/"..self.AutoSellLimit..")" .. (self.AutoSell and " [ON]" or " [OFF]") end end

local MyActiveTotems = {}
task.spawn(function()
    local TotemRemotes = RS:WaitForChild("TotemRemotes", 5)
    if not TotemRemotes then return end
    TotemRemotes:WaitForChild("TotemCreated").OnClientEvent:Connect(function(ownerId, totemInst, totemId, duration, totemName) if ownerId == P.UserId then MyActiveTotems[totemId] = {name = totemName, time = duration, inst = totemInst, pos = nil} end end)
    TotemRemotes:WaitForChild("TotemTimerUpdate").OnClientEvent:Connect(function(totemId, timeLeft) if MyActiveTotems[totemId] then MyActiveTotems[totemId].time = timeLeft; if timeLeft <= 0 then MyActiveTotems[totemId] = nil end end end)
end)

task.spawn(function()
    local TotemRemotes = RS:WaitForChild("TotemRemotes", 5)
    while task.wait(1.5) do
        if TotemRemotes and TotemRemotes:FindFirstChild("TotemPickup") then
            local hrp = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for id, data in pairs(MyActiveTotems) do
                    local inst = data.inst
                    if not data.pos and inst and inst.Parent then pcall(function() data.pos = inst:GetPivot().Position end) end
                    if data.pos and (hrp.Position - data.pos).Magnitude > 50 then 
                        pcall(function() TotemRemotes.TotemPickup:FireServer(id) end) 
                        MyActiveTotems[id] = nil 
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    local InvEvent = RS:WaitForChild("FishingSystem", 5)
    if InvEvent then InvEvent = InvEvent:WaitForChild("InventoryEvents", 5) end
    if InvEvent then InvEvent = InvEvent:WaitForChild("Inventory_GetData", 5) end
    
    while task.wait(3.5) do
        if InvEvent then
            local s, res = pcall(function() return InvEvent:InvokeServer() end)
            if s and type(res) == "table" then
                local data = res
                if type(data[1]) == "table" then data = data[1] end
                if data.EquippedBait and type(data.EquippedBait) == "string" then
                    if FishBot.PetBait ~= data.EquippedBait then
                        FishBot.PetBait = data.EquippedBait
                        pcall(function() FishBot.TxtBait.Text = data.EquippedBait end)
                    end
                end
            end
        end
    end
end)

-- Auto Pet Fishing loop (upgraded from previous session; uses FirePetOnce)
task.spawn(function()
    while task.wait(3) do
        if FishBot.AutoPet then
            for _, slotData in ipairs({{FishBot.Pet1, 1}, {FishBot.Pet2, 2}}) do
                local petName, slot = slotData[1], slotData[2]
                if petName and petName ~= "" then
                    FirePetOnce(petName, slot, true)
                    task.wait(0.4)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        Leaderboard:Update()
        local t = P.Character and P.Character:FindFirstChildOfClass("Tool")
        FishBot.Rod = t and t.Name or nil
        if FishBot.Rod then 
            FishBot.LblRod.Text = FishBot.Rod; FishBot.LblRod.TextColor3 = C3(0,122,255); 
            if not FishBot.Active then FishBot.Btn.BackgroundColor3 = C3(0,122,255); FishBot.Btn.Text = "Start Fishing"; FishBot.Btn.AutoButtonColor = true end
        else 
            FishBot.LblRod.Text = "Not Equipped"; FishBot.LblRod.TextColor3 = C3(255,59,48);
            FishBot.Btn.BackgroundColor3 = C3(180,180,180); FishBot.Btn.Text = "Lock: Equip Rod"; FishBot.Btn.AutoButtonColor = false 
        end
        if FishBot.Active and not FishBot.Rod then FishBot.Active = false; FishBot:ShowMsg("Rod Unequipped! Stopped.", C3(255,59,48)) end
    end
end)

task.spawn(function()
    local WeatherRemotes = RS:WaitForChild("WeatherRemotes", 5)
    while task.wait(3) do
        if ShopTab.AutoBuy and WeatherRemotes then
            pcall(function()
                local data = WeatherRemotes.GetWeatherData:InvokeServer()
                if type(data) == "table" then
                    local list = (type(data[1]) == "table" and type(data[1][1]) == "table") and data[1] or data
                    local isNight = (game:GetService("Lighting").ClockTime >= 21 or game:GetService("Lighting").ClockTime <= 5)
                    for _, w in pairs(list) do
                        if type(w) == "table" and w.name and w.isActive == false then
                            local wn = string.lower(tostring(w.name))
                            if (wn:find("aurora") or wn:find("meteor")) and not isNight then continue end
                            WeatherRemotes.BuyWeather:FireServer(w.name); task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    local TotemEvent = RS:WaitForChild("TotemRemotes", 5) and RS.TotemRemotes:WaitForChild("BuyTotem")
    while task.wait(5) do
        if ShopTab.AutoTotem and TotemEvent then for _, totem in ipairs({"Shiny Totem", "Mutation Totem", "Luck Totem"}) do pcall(function() TotemEvent:InvokeServer(totem); task.wait(0.5) end) end end
    end
end)

task.spawn(function()
    local SpinEvent = RS:WaitForChild("FishingSystem", 5) 
    if SpinEvent then SpinEvent = SpinEvent:WaitForChild("AbilityRemotes"):WaitForChild("SpinAbility") end
    while task.wait(2) do
        if ShopTab.AutoSpin and SpinEvent then
            local success, result = pcall(function() return SpinEvent:InvokeServer() end)
            if success and type(result) == "table" then
                local data = (type(result[1]) == "table" and result.success == nil) and result[1] or result
                if data.success == true then
                    local aName = type(data.ability) == "table" and tostring(data.ability.Name or "") or (type(data.ability) == "string" and data.ability or "")
                    if aName ~= "" then
                        local isTargetMatch = (ShopTab.TargetAbility == "Both" and (aName == "Divine" or aName == "Supernova")) or (aName == ShopTab.TargetAbility)
                        if isTargetMatch then
                            ShopTab.AutoSpin = false
                            if spinButtonRef then pcall(function() spinButtonRef.Text = "Auto Spin Ability [OFF]"; spinButtonRef.BackgroundColor3 = C3(220,220,220); spinButtonRef.TextColor3 = C3(80,80,80) end) end
                            ShowMacOSNotification("Ability KemplongXD", "Successfully obtained Ability: " .. aName .. "!")
                        end
                    end
                elseif data.success == false and (tostring(data.reason or ""):lower():find("coin") or tostring(data.reason or ""):lower():find("cukup")) then
                    ShopTab.AutoSpin = false
                    if spinButtonRef then pcall(function() spinButtonRef.Text = "Auto Spin Ability [OFF]"; spinButtonRef.BackgroundColor3 = C3(220,220,220); spinButtonRef.TextColor3 = C3(80,80,80) end) end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if ShopTab.AutoPlaceTotem then
            local TotemRemotes = RS:WaitForChild("TotemRemotes", 5) 
            if TotemRemotes then
                local BuyEvt = TotemRemotes:FindFirstChild("BuyTotem")
                local SpawnEvt = TotemRemotes:FindFirstChild("SpawnTotemRequest")
                local char = P.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp and BuyEvt and SpawnEvt then
                    local currentCounts = {["Shiny Totem"] = 0, ["Luck Totem"] = 0, ["Mutation Totem"] = 0}
                    
                    for id, data in pairs(MyActiveTotems) do
                        if data and data.name and currentCounts[data.name] then
                            currentCounts[data.name] = currentCounts[data.name] + 1
                        else
                            MyActiveTotems[id] = nil
                        end
                    end
                    
                    local placePos = hrp.Position + (hrp.CFrame.RightVector * 5) - Vector3.new(0, 3, 0)
                    local hasPlacedNew = false
                    
                    local combos = ShopTab.TotemCombo
                    if type(combos) == "string" then combos = {combos}
                    elseif type(combos) ~= "table" then combos = {"Shiny Totem", "Luck Totem", "Mutation Totem"} end
                    
                    for _, totem in ipairs(combos) do
                        local activeCount = currentCounts[totem] or 0
                        local needed = 5 - activeCount
                        
                        if needed > 0 then
                            for i = 1, needed do
                                local successBuy = pcall(function() return BuyEvt:InvokeServer(totem) end)
                                task.wait(0.15) 
                                if not successBuy then break end
                            end
                            
                            for i = 1, needed do
                                local successSpawn = pcall(function() SpawnEvt:FireServer(totem, placePos, 3600) end)
                                task.wait(0.2) 
                                if successSpawn then hasPlacedNew = true end
                            end
                        end
                    end
                    
                    if hasPlacedNew and FishBot and FishBot.ShowMsg then
                        FishBot:ShowMsg("Sistem Totem: Mengisi ulang stok aktif!", C3(52,199,89))
                    end
                end
            end
        end
    end
end)

RunS.RenderStepped:Connect(function(dt)
    pcall(function()
        local p = "0"; pcall(function() p = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) end); 
        local upStr = FormatUptime(os.time() - ScriptStartTime)
        Leaderboard.LblStats.Text = "Ping: "..p.."ms\nFPS: "..math.floor(1/dt).."\nUptime: "..upStr
        if MiscTools.SW and P.Character and P.Character:FindFirstChild("HumanoidRootPart") then 
            MiscTools.SWPart.CanCollide = true; MiscTools.SWPart.CFrame = CFrame.new(P.Character.HumanoidRootPart.Position - Vector3.new(0,3.5,0)) 
        else MiscTools.SWPart.CanCollide = false end
    end)
end)

task.spawn(function()
    while task.wait(1) do
        if WebhookActive and WebhookURL ~= "" and WebhookInterval > 0 then
            if os.time() - LastWebhookTime >= (WebhookInterval * 60) then
                LastWebhookTime = os.time()
                local caught = FishBot and FishBot.Caught or 0
                local upStr = FormatUptime(os.time() - ScriptStartTime)
                SendWebhook("Periodic Fishing Progress Report", {{["name"] = "Farming Status", ["value"] = "Active & Running Smoothly", ["inline"] = false}, {["name"] = "Total Fish Caught", ["value"] = tostring(caught) .. " fishes", ["inline"] = true}, {["name"] = "Script Uptime", ["value"] = upStr, ["inline"] = true}, {["name"] = "Interval", ["value"] = tostring(WebhookInterval) .. " Mins Report", ["inline"] = true}}, 5763719)
            end
        end
    end
end)

pcall(function()
    local promptOverlay = CG:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            task.wait(1)
            local errorMsg = "Unknown Disconnect Reason"
            local isRestart = false
            
            pcall(function()
                errorMsg = child.MessageArea.ErrorFrame.ErrorMessage.Text
                local lowerMsg = string.lower(errorMsg)
                if lowerMsg:find("server closed") or lowerMsg:find("shut down") or lowerMsg:find("restart") or lowerMsg:find("maintenance") then
                    isRestart = true
                end
            end)
            
            local caught = FishBot and FishBot.Caught or 0
            local upStr = FormatUptime(os.time() - ScriptStartTime)
            
            if isRestart then
                SendWebhook("Server Shutdown / Restart Detected!", {
                    {["name"] = "Status", ["value"] = "Server is shutting down or restarting", ["inline"] = false},
                    {["name"] = "Message", ["value"] = errorMsg, ["inline"] = false},
                    {["name"] = "Total Fish Secured", ["value"] = tostring(caught) .. " fishes", ["inline"] = true},
                    {["name"] = "Script Uptime", ["value"] = upStr, ["inline"] = true}
                }, 16753920) 
            else
                SendWebhook("Critical: Bot Disconnected!", {
                    {["name"] = "Connection Status", ["value"] = "Lost Connection to Server", ["inline"] = false},
                    {["name"] = "Error Reason", ["value"] = errorMsg, ["inline"] = false},
                    {["name"] = "Total Fish Secured", ["value"] = tostring(caught) .. " fishes", ["inline"] = true},
                    {["name"] = "Script Uptime", ["value"] = upStr, ["inline"] = true}
                }, 16711680) 
            end
        end
    end)
end)

-- Load saved config values after all UI components and variables are initialized
LoadConfig()
