-- KXD Responsive Refactor Build (macOS Native Style Edition)
-- Fully responsive, touch-friendly, and optimized.

local CG, RS, Plrs, VU, TS = game:GetService("CoreGui"), game:GetService("ReplicatedStorage"), game:GetService("Players"), game:GetService("VirtualUser"), game:GetService("TweenService")
local UIS, HS, LP = game:GetService("UserInputService"), game:GetService("HttpService"), Plrs.LocalPlayer

local GP;
pcall(function() GP = gethui and gethui() end); if not GP then pcall(function() GP = CG; local _ = CG.Name end) end;
GP = GP or LP:WaitForChild("PlayerGui")

local HN = "KXD_MacHub_Premium"
if GP:FindFirstChild(HN) then GP[HN]:Destroy() end

-- macOS Dark Theme Palette
local C = {
    BG = Color3.fromRGB(30, 30, 30),     -- Main Window Background
    SB = Color3.fromRGB(40, 40, 40),     -- Sidebar Background (Slightly lighter)
    TB = Color3.fromRGB(40, 40, 40),     -- Title Bar matches sidebar
    Ac = Color3.fromRGB(0, 122, 255),    -- macOS Accent Blue
    Tx = Color3.fromRGB(255, 255, 255),  -- Primary Text
    TD = Color3.fromRGB(160, 160, 160),  -- Secondary/Disabled Text
    El = Color3.fromRGB(45, 45, 45),     -- Element Background (Buttons, Inputs)
    On = Color3.fromRGB(48, 209, 88),    -- macOS Toggle On (Green)
    Off = Color3.fromRGB(60, 60, 60),    -- Toggle Off
    Sp = Color3.fromRGB(70, 70, 70),     -- Separators & Strokes
    Hv = Color3.fromRGB(65, 65, 65)      -- Hover state
}

local T_Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_Med = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local T_PopIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local T_PopOut = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function Mk(c, p) 
    local i = Instance.new(c);
    for k, v in pairs(p) do i[k] = v end;
    return i 
end

-- Responsive Device Layer
local Camera = workspace.CurrentCamera
local function IsMobileDevice()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local function GetMainWindowSize()
    local vp = Camera and Camera.ViewportSize or Vector2.new(1280,720)
    if vp.X < 700 then
        -- Mobile Portrait or Small Screen
        return UDim2.fromScale(0.95, 0.90)
    elseif vp.X < 1100 then
        -- Tablet / Mobile Landscape
        return UDim2.fromScale(0.85, 0.85)
    else
        -- Desktop (Standard macOS Window Size)
        return UDim2.new(0, 800, 0, 500)
    end
end

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    self.Tbs = {}
    self.S = {}
    self.IM = false
    self.ActiveTab = nil
    
    self.SG = Mk("ScreenGui", {Name=HN, Parent=GP, ResetOnSpawn=false})
    
    -- Main Window
    self.MF = Mk("Frame", {Size=GetMainWindowSize(), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), BackgroundColor3=C.BG, Active=true, ClipsDescendants=true, Parent=self.SG})
    Mk("UICorner", {CornerRadius=UDim.new(0,10), Parent=self.MF})
    Mk("UIStroke", {Color=Color3.fromRGB(20,20,20), Thickness=1, Parent=self.MF}) -- Outer Shadow/Border illusion
    
    self.Scale = Mk("UIScale", {Scale=0, Parent=self.MF})
    TS:Create(self.Scale, T_PopIn, {Scale=1}):Play()
    
    -- macOS Title Bar
    self.TB = Mk("Frame", {Size=UDim2.new(1,0,0,38), BackgroundColor3=C.TB, BorderSizePixel=0, Parent=self.MF})
    Mk("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=title or "KemplongXD Hub", TextColor3=C.TD, TextXAlignment=Enum.TextXAlignment.Center, Font=Enum.Font.GothamMedium, TextSize=13, Parent=self.TB})
    
    -- macOS Traffic Lights (Window Controls)
    local controlContainer = Mk("Frame", {Size=UDim2.new(0,60,1,0), Position=UDim2.new(0,15,0,0), BackgroundTransparency=1, Parent=self.TB})
    Mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8), VerticalAlignment=Enum.VerticalAlignment.Center, Parent=controlContainer})
    
    local cR = Mk("TextButton", {Size=UDim2.new(0,12,0,12), BackgroundColor3=Color3.fromRGB(255,95,86), Text="", Parent=controlContainer})
    Mk("UICorner", {CornerRadius=UDim.new(1,0), Parent=cR})
    Mk("UIStroke", {Color=Color3.fromRGB(224,68,62), Thickness=1, Parent=cR})
    
    local cY = Mk("TextButton", {Size=UDim2.new(0,12,0,12), BackgroundColor3=Color3.fromRGB(255,189,46), Text="", Parent=controlContainer})
    Mk("UICorner", {CornerRadius=UDim.new(1,0), Parent=cY})
    Mk("UIStroke", {Color=Color3.fromRGB(222,161,34), Thickness=1, Parent=cY})
    
    local cG = Mk("TextButton", {Size=UDim2.new(0,12,0,12), BackgroundColor3=Color3.fromRGB(39,201,63), Text="", Parent=controlContainer})
    Mk("UICorner", {CornerRadius=UDim.new(1,0), Parent=cG})
    Mk("UIStroke", {Color=Color3.fromRGB(26,171,41), Thickness=1, Parent=cG})
    
    -- Sidebar (Left)
    self.SB = Mk("Frame", {Size=UDim2.new(0,180,1,-38), Position=UDim2.new(0,0,0,38), BackgroundColor3=C.SB, BorderSizePixel=0, Parent=self.MF})
    Mk("Frame", {Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,0,0,0), BackgroundColor3=C.Sp, BorderSizePixel=0, Parent=self.SB}) -- Sidebar Separator Line
    
    self.SBScroll = Mk("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0, Parent=self.SB})
    Mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4), HorizontalAlignment=Enum.HorizontalAlignment.Center, Parent=self.SBScroll})
    Mk("UIPadding", {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), Parent=self.SBScroll})
    
    -- Page Container (Right)
    self.PC = Mk("Frame", {Size=UDim2.new(1,-180,1,-38), Position=UDim2.new(0,180,0,38), BackgroundTransparency=1, Parent=self.MF})
    
    -- Notification Area
    self.NC = Mk("Frame", {Size=UDim2.new(0,300,1,-20), Position=UDim2.new(1,-320,0,10), BackgroundTransparency=1, Parent=self.SG})
    Mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,12), VerticalAlignment=Enum.VerticalAlignment.Bottom, Parent=self.NC})
    
    cR.MouseButton1Click:Connect(function() 
        TS:Create(self.Scale, T_PopOut, {Scale=0}):Play()
        task.wait(0.3)
        self.SG:Destroy() 
    end)
    
    cY.MouseButton1Click:Connect(function() 
        self.IM = not self.IM
        TS:Create(self.MF, T_Med, {Size=self.IM and UDim2.new(0,800,0,38) or GetMainWindowSize()}):Play()
        if not self.IM then task.wait(0.1) end
        self.SB.Visible = not self.IM
        self.PC.Visible = not self.IM 
    end)
    
    return self
end

function Window:LogStr(n)
    if type(n)~="table" then return tostring(n) end
    local s,f="{",true
    for k,v in pairs(n) do
        if not f then s=s..", " end
        s=s..tostring(k)..": "..self:LogStr(v); f=false
    end
    return s.."}"
end

function Window:Notif(title, desc, tm)
    pcall(function()
        local f = Mk("Frame", {Size=UDim2.new(1,0,0,70), BackgroundColor3=C.SB, Parent=self.NC})
        Mk("UICorner", {CornerRadius=UDim.new(0,10), Parent=f})
        Mk("UIStroke", {Color=C.Sp, Thickness=1, Parent=f})
        Mk("TextLabel", {Size=UDim2.new(1,-30,0,22), Position=UDim2.new(0,15,0,10), BackgroundTransparency=1, Text=title, TextColor3=C.Tx, TextXAlignment=0, Font=Enum.Font.GothamMedium, TextSize=14, Parent=f})
        Mk("TextLabel", {Size=UDim2.new(1,-30,0,30), Position=UDim2.new(0,15,0,32), BackgroundTransparency=1, Text=tostring(desc), TextColor3=C.TD, TextXAlignment=0, TextYAlignment=0, Font=Enum.Font.Gotham, TextSize=12, TextWrapped=true, Parent=f})
        
        f.Position = UDim2.new(1,40,0,0)
        TS:Create(f, T_Med, {Position=UDim2.new(0,0,0,0)}):Play()
        task.delay(tm or 3, function() 
            TS:Create(f, T_Med, {Position=UDim2.new(1,40,0,0), BackgroundTransparency=1}):Play()
            task.wait(0.3); f:Destroy() 
        end)
    end)
end

function Window:AddTab(name)
    local isFirst = (#self.Tbs == 0)
    if isFirst then self.ActiveTab = name end
    
    local b = Mk("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=isFirst and C.Ac or C.SB, Text="  "..name, TextColor3=isFirst and C.Tx or C.Tx, TextXAlignment=0, Font=Enum.Font.GothamMedium, TextSize=13, BorderSizePixel=0, Parent=self.SBScroll})
    Mk("UICorner", {CornerRadius=UDim.new(0,6), Parent=b})
    Mk("UIPadding", {PaddingLeft=UDim.new(0,10), Parent=b})
    
    local p = Mk("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=C.Sp, Visible=isFirst, Parent=self.PC})
    Mk("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,12), HorizontalAlignment=Enum.HorizontalAlignment.Center, Parent=p})
    Mk("UIPadding", {PaddingTop=UDim.new(0,20), PaddingBottom=UDim.new(0,20), PaddingLeft=UDim.new(0,20), PaddingRight=UDim.new(0,15), Parent=p})
    
    local tabData = {Button=b, Container=p, Name=name}
    table.insert(self.Tbs, tabData)
    
    b.MouseEnter:Connect(function() if self.ActiveTab ~= name then TS:Create(b, T_Fast, {BackgroundColor3=C.El}):Play() end end)
    b.MouseLeave:Connect(function() if self.ActiveTab ~= name then TS:Create(b, T_Fast, {BackgroundColor3=C.SB}):Play() end end)

    b.MouseButton1Click:Connect(function() 
        self.ActiveTab = name
        for _, t in ipairs(self.Tbs) do 
            local sl = (t.Name == name)
            t.Container.Visible = sl
            TS:Create(t.Button, T_Fast, {BackgroundColor3=sl and C.Ac or C.SB}):Play()
        end 
    end)
    
    local Tab = {}
    Tab.__index = Tab
    local selfTab = setmetatable({}, Tab)
    selfTab.Window = self
    selfTab.Container = p

    function Tab:AddLabel(text, height)
        local c = Mk("Frame",{Size=UDim2.new(1,0,0,height or 90),BackgroundColor3=C.El,Parent=self.Container})
        Mk("UICorner",{CornerRadius=UDim.new(0,8),Parent=c})
        Mk("UIStroke",{Color=C.Sp,Thickness=1,Parent=c})
        Mk("TextLabel",{Size=UDim2.new(1,-30,1,-20),Position=UDim2.new(0,15,0,10),BackgroundTransparency=1,Text=text,TextColor3=C.TD,TextXAlignment=0,TextYAlignment=Enum.TextYAlignment.Top,Font=Enum.Font.Gotham,TextSize=13,TextWrapped=true,Parent=c})
        return c
    end

    function Tab:AddButton(text, callback)
        -- Touch friendly height 45px
        local btn = Mk("TextButton",{Size=UDim2.new(1,0,0,45),BackgroundColor3=C.El,Text=text,TextColor3=C.Tx,Font=Enum.Font.GothamMedium,TextSize=13,Parent=self.Container})
        Mk("UICorner",{CornerRadius=UDim.new(0,8),Parent=btn})
        Mk("UIStroke",{Color=C.Sp,Thickness=1,Parent=btn})
        
        btn.MouseEnter:Connect(function() TS:Create(btn, T_Fast, {BackgroundColor3=C.Hv}):Play() end)
        btn.MouseLeave:Connect(function() TS:Create(btn, T_Fast, {BackgroundColor3=C.El}):Play() end)
        
        btn.MouseButton1Click:Connect(function() 
            TS:Create(btn, T_Fast, {BackgroundColor3=C.Sp}):Play()
            task.wait(0.1)
            TS:Create(btn, T_Fast, {BackgroundColor3=C.Hv}):Play()
            if callback then callback() end 
        end)
        return btn
    end

    function Tab:AddToggle(text, callback)
        local Toggle = {}
        Toggle.__index = Toggle
        local selfToggle = setmetatable({}, Toggle)
        selfToggle.State = false
        selfToggle.Callback = callback
        
        -- Touch friendly height 50px
        local c = Mk("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=C.El,Parent=self.Container})
        Mk("UICorner",{CornerRadius=UDim.new(0,8),Parent=c})
        Mk("UIStroke",{Color=C.Sp,Thickness=1,Parent=c})
        Mk("TextLabel",{Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,Text=text,TextColor3=C.Tx,TextXAlignment=0,Font=Enum.Font.GothamMedium,TextSize=13,Parent=c})
        
        -- macOS style toggle knob
        selfToggle.BG = Mk("Frame",{Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-60,0.5,-12),BackgroundColor3=C.Off,Parent=c})
        Mk("UICorner",{CornerRadius=UDim.new(1,0),Parent=selfToggle.BG})
        selfToggle.Knob = Mk("Frame",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,2,0.5,-10),BackgroundColor3=Color3.new(1,1,1),Parent=selfToggle.BG})
        Mk("UICorner",{CornerRadius=UDim.new(1,0),Parent=selfToggle.Knob})
        Mk("UIStroke",{Color=Color3.fromRGB(0,0,0), Transparency=0.8, Thickness=1, Parent=selfToggle.Knob})
        
        local btn = Mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=c})
        
        function Toggle:Set(newState)
            self.State = newState
            TS:Create(self.Knob, T_Fast, {Position=self.State and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)}):Play()
            TS:Create(self.BG, T_Fast, {BackgroundColor3=self.State and C.On or C.Off}):Play()
            if self.Callback then self.Callback(self.State) end
        end

        btn.MouseButton1Click:Connect(function() selfToggle:Set(not selfToggle.State) end)
        return function(newState) selfToggle:Set(newState) end
    end

    function Tab:AddInput(placeholder, default)
        -- Touch friendly height 45px
        local c = Mk("Frame",{Size=UDim2.new(1,0,0,45),BackgroundColor3=C.El,Parent=self.Container})
        Mk("UICorner",{CornerRadius=UDim.new(0,8),Parent=c})
        Mk("UIStroke",{Color=C.Sp,Thickness=1,Parent=c})
        
        local i = Mk("TextBox",{Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Text=default,PlaceholderText=placeholder,TextColor3=C.Tx,TextXAlignment=0,Font=Enum.Font.Gotham,TextSize=13,Parent=c})
        return i
    end

    function Tab:AddSeparator()
        Mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Sp,BorderSizePixel=0,Parent=self.Container})
    end

    function Tab:AddDropdown(text, options, callback)
        local Dropdown = {}
        Dropdown.__index = Dropdown
        local selfDrop = setmetatable({}, Dropdown)
        selfDrop.Options = options or {}
        selfDrop.Callback = callback
        selfDrop.Title = text
        selfDrop.IsOpen = false
        
        -- Touch friendly height 50px
        selfDrop.Container = Mk("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=C.El,Parent=self.Container,ClipsDescendants=true})
        Mk("UICorner",{CornerRadius=UDim.new(0,8),Parent=selfDrop.Container})
        Mk("UIStroke",{Color=C.Sp,Thickness=1,Parent=selfDrop.Container})
        
        selfDrop.MainBtn = Mk("TextButton",{Size=UDim2.new(1,-20,0,50),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Text=text.." : Select",TextColor3=C.Tx,TextXAlignment=0,Font=Enum.Font.GothamMedium,TextSize=13,Parent=selfDrop.Container})
        selfDrop.Icon = Mk("TextLabel",{Size=UDim2.new(0,30,0,50),Position=UDim2.new(1,-35,0,0),BackgroundTransparency=1,Text="▼",TextColor3=C.TD,Font=Enum.Font.Gotham,TextSize=12,Parent=selfDrop.Container})
        
        selfDrop.Scroll = Mk("ScrollingFrame",{Size=UDim2.new(1,0,0,150),Position=UDim2.new(0,0,0,50),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=C.Sp,Parent=selfDrop.Container})
        Mk("UIListLayout",{Parent=selfDrop.Scroll})
        
        function Dropdown:Toggle()
            self.IsOpen = not self.IsOpen
            self.Icon.Text = self.IsOpen and "▲" or "▼"
            TS:Create(self.Container, T_Med, {Size=self.IsOpen and UDim2.new(1,0,0,200) or UDim2.new(1,0,0,50)}):Play()
        end

        function Dropdown:Refresh(newOptions)
            self.Options = newOptions
            for _, v in ipairs(self.Scroll:GetChildren()) do 
                if v:IsA("TextButton") then v:Destroy() end 
            end
            self.Scroll.CanvasSize = UDim2.new(0,0,0,#self.Options*40) -- 40px touch targets for items
            
            for _, opt in ipairs(self.Options) do
                local ob = Mk("TextButton",{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.El,BackgroundTransparency=1,Text="   "..opt,TextColor3=C.TD,TextXAlignment=0,Font=Enum.Font.Gotham,TextSize=13,Parent=self.Scroll})
                Mk("UICorner",{CornerRadius=UDim.new(0,6),Parent=ob})
                
                ob.MouseEnter:Connect(function() TS:Create(ob, T_Fast, {BackgroundTransparency=0.5, TextColor3=C.Tx}):Play() end)
                ob.MouseLeave:Connect(function() TS:Create(ob, T_Fast, {BackgroundTransparency=1, TextColor3=C.TD}):Play() end)
                
                ob.MouseButton1Click:Connect(function() 
                    self.MainBtn.Text = self.Title.." : "..opt
                    if self.IsOpen then self:Toggle() end
                    if self.Callback then self.Callback(opt) end 
                end) 
            end
        end

        selfDrop.MainBtn.MouseButton1Click:Connect(function() selfDrop:Toggle() end)
        selfDrop:Refresh(selfDrop.Options)
        return selfDrop
    end

    return selfTab
end

local Net = {CR=nil, SM=nil, CF=nil, ET=nil, SI=nil, CnF=nil, PW=nil, ONFN=nil, RC=nil, EI=nil}
function Net:Init(u) 
    task.spawn(function() 
        local pk=RS:WaitForChild("Packages",10); 
        if pk then 
            pcall(function() 
                local n=pk._Index["sleitnick_net@0.2.0"].net; 
                self.CR=n:FindFirstChild("RF/ChargeFishingRod"); 
                self.SM=n:FindFirstChild("RF/RequestFishingMinigameStarted"); 
                self.CF=n:FindFirstChild("RE/FishingCompleted"); 
                self.ET=n:FindFirstChild("RE/EquipToolFromHotbar"); 
                self.SI=n:FindFirstChild("RF/SellAllItems"); 
                self.CnF=n:FindFirstChild("RF/CancelFishingInputs"); 
                self.PW=n:FindFirstChild("RF/PurchaseWeatherEvent"); 
                self.ONFN=n:FindFirstChild("RE/ObtainedNewFishNotification"); 
                self.RC=n:FindFirstChild("RE/ReplicateCutscene"); 
                
                if self.CF then 
                    self.CF.OnClientEvent:Connect(function(...) u:Notif("Fisherman", u:LogStr({...}), 4) end) 
                end; 
                u:Notif("System", "Sistem Jaringan Terkoneksi.", 3) 
            end) 
        else 
            u:Notif("Error", "Jaringan gagal dimuat.", 5) 
        end 
    end) 
end

local function getTargetPos()
    local c = LP.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        local p = c.HumanoidRootPart.Position + (c.HumanoidRootPart.CFrame.LookVector * 15)
        return p.X, p.Y, p.Z
    end
    return 0, 0, 0
end

local hub = Window.new("KemplongXD Hub")
local pFsh = hub:AddTab("Auto Fishing")
local pSl = hub:AddTab("Auto Sell")
local pWth = hub:AddTab("Weather Magic")
local pPlr = hub:AddTab("Player Mod")
local pTp = hub:AddTab("Teleportation")
local pMsc = hub:AddTab("Miscellaneous")
Net:Init(hub)

local tLg, tAm

tLg = pFsh:AddToggle("Legit Fishing", function(s) 
    hub.S.Lg = s
    if s then 
        if hub.S.Am then tAm(false) end
        hub:Notif("Fishing", "Legit Aktif (Always Perfect)", 2)
        task.spawn(function() 
            while hub.S.Lg do 
                local t = tick()
                local tx, ty, tz = getTargetPos()
                pcall(function() if Net.CR then Net.CR:InvokeServer(tx, ty, tz, 100) end end)
                task.wait(0.5)
                if not hub.S.Lg then break end
                pcall(function() if Net.SM then Net.SM:InvokeServer(tx, ty, 100) end end)
                task.wait(0.5)
                if not hub.S.Lg then break end
                pcall(function() if Net.CF then Net.CF:FireServer() end end)
                task.wait(1) 
            end 
        end) 
    else 
        pcall(function() if Net.CnF then Net.CnF:InvokeServer() end end) 
    end 
end)

pFsh:AddSeparator()
local iAD = pFsh:AddInput("Delay Cast (s)", "1")
local iAC = pFsh:AddInput("Delay Cancel (s)", "0.5")

tAm = pFsh:AddToggle("Instan Fishing", function(s) 
    hub.S.Am = s
    if s then 
        if hub.S.Lg then tLg(false) end 
        hub:Notif("Fishing", "Instan Fishing Aktif (Always Perfect)", 2) 
        task.spawn(function() 
            while hub.S.Am do 
                local cD, cnD = tonumber(iAD.Text) or 1, tonumber(iAC.Text) or 0.5 
                task.spawn(function() 
                    local t = tick() + math.random(-10,10)/1000 
                    local tx, ty, tz = getTargetPos()
                    pcall(function() if Net.CR then Net.CR:InvokeServer(tx, ty, tz, 100) end end)
                    pcall(function() if Net.SM then Net.SM:InvokeServer(tx, ty, 100) end end) 
                    pcall(function() if Net.CF then Net.CF:FireServer() end end) 
                    task.wait(cnD)
                    pcall(function() if Net.CnF then Net.CnF:InvokeServer() end end) 
                end) 
                task.wait(cD) 
            end 
        end) 
    else 
        pcall(function() if Net.CnF then Net.CnF:InvokeServer() end end) 
    end 
end)

pFsh:AddSeparator()
pFsh:AddToggle("Auto Equip (Slot 1)", function(s) 
    hub.S.AE = s
    task.spawn(function() 
        while hub.S.AE do 
            pcall(function() if Net.ET then Net.ET:FireServer(1) end end) 
            task.wait(3) 
        end 
    end) 
end)

pFsh:AddButton("Force Cancel Fishing", function() 
    pcall(function() if Net.CnF then Net.CnF:InvokeServer() end end) 
end)

local iSD = pSl:AddInput("Delay Sell (s)", "15")
pSl:AddToggle("Auto Sell All", function(s) 
    hub.S.AS = s
    task.spawn(function() 
        while hub.S.AS do 
            task.spawn(function() 
                local x,r = pcall(function() return Net.SI and Net.SI:InvokeServer() end)
                if x and r then hub:Notif("Market", "Terjual: "..hub:LogStr(r), 3) end 
            end) 
            task.wait(math.clamp(tonumber(iSD.Text) or 15, 1, 3600)) 
        end 
    end) 
end)
pSl:AddButton("Sell All Now", function() 
    task.spawn(function() 
        local x,r = pcall(function() return Net.SI and Net.SI:InvokeServer() end)
        if x and r then hub:Notif("Market", "Terjual: "..hub:LogStr(r), 3) end 
    end) 
end)

local allWeathers = {
    "Storm", "Cloudy", "Snow", "Wind", "Radiant", "Shark Hunt", 
    "Present Rain", "Worm Hunt", "Valentines Event", "Megalodon Hunt", 
    "Treasure Hunt", "Mutated", "Increased Luck", "Ghost Shark Hunt", "Sparkling Cove","BloodMoon Hunt", "ADMIN - Galaxy Storm", "ADMIN - 2025 Christmas", "PurpleMoon","Purple Moon","Purplemoon","Bloodmoon","BloodMoon","Blood Moon"
}
local selectedWeather = "Storm"

pWth:AddDropdown("Pilih Weather", allWeathers, function(s)
    selectedWeather = s
end)

pWth:AddToggle("Auto Buy Selected Weather", function(s)
    hub.S.ABW = s
    task.spawn(function()
        while hub.S.ABW do
            pcall(function()
                if Net.PW then Net.PW:InvokeServer(selectedWeather) end
            end)
            task.wait(300)
        end
    end)
end)

pWth:AddButton("Buy All Weather Now", function()
    pcall(function()
        if Net.PW then
            for _, w in ipairs(allWeathers) do
                Net.PW:InvokeServer(w)
            end
        end
    end)
    hub:Notif("Weather", "Mencoba membeli semua cuaca...", 2)
end)

local iWS = pPlr:AddInput("WalkSpeed", "50")
pPlr:AddToggle("Enable WalkSpeed", function(s) 
    hub.S.WS = s
    task.spawn(function() 
        while hub.S.WS do 
            pcall(function() LP.Character.Humanoid.WalkSpeed = tonumber(iWS.Text) or 16 end) 
            task.wait(0.1) 
        end
        pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end) 
    end) 
end)

local iJP = pPlr:AddInput("JumpPower", "100")
pPlr:AddToggle("Enable JumpPower", function(s) 
    hub.S.JP = s
    task.spawn(function() 
        while hub.S.JP do 
            pcall(function() LP.Character.Humanoid.UseJumpPower=true; LP.Character.Humanoid.JumpPower=tonumber(iJP.Text) or 50 end) 
            task.wait(0.1) 
        end
        pcall(function() LP.Character.Humanoid.JumpPower=50 end) 
    end) 
end)

local iFS = pPlr:AddInput("Fly Speed", "50")
local fv, fg
pPlr:AddToggle("Enable Fly", function(s) 
    hub.S.Fly = s 
    local c = LP.Character 
    local h = c and c:FindFirstChild("HumanoidRootPart") 
    if not h then return end 
    if s then 
        fv=Instance.new("BodyVelocity",h) 
        fv.MaxForce=Vector3.new(9e9,9e9,9e9) 
        fg=Instance.new("BodyGyro",h) 
        fg.MaxTorque=Vector3.new(9e9,9e9,9e9) 
        fg.P=10000 
        pcall(function() c.Humanoid.PlatformStand=true end) 
        task.spawn(function() 
            local PM=LP:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") 
            local Crl=require(PM):GetControls() 
            while hub.S.Fly and fv and fv.Parent do 
                local cm=workspace.CurrentCamera 
                local m=Crl:GetMoveVector() 
                local d=(cm.CFrame.LookVector * -m.Z)+(cm.CFrame.RightVector * m.X) 
                if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end 
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end 
                fv.Velocity=d*(tonumber(iFS.Text) or 50) 
                fg.CFrame=cm.CFrame 
                task.wait() 
            end 
            if fv then fv:Destroy() end 
            if fg then fg:Destroy() end 
            pcall(function() LP.Character.Humanoid.PlatformStand=false end) 
        end) 
    else 
        if fv then fv:Destroy() end
        if fg then fg:Destroy() end 
        pcall(function() LP.Character.Humanoid.PlatformStand=false end) 
    end 
end)

local iNm = pPlr:AddInput("New Name (Local)", "Guest")
pPlr:AddButton("Change Name", function() 
    local nN = iNm.Text 
    local c = LP.Character 
    if c then 
        pcall(function() c.Humanoid.DisplayName = nN end) 
        for _,v in pairs(c:GetDescendants()) do 
            if (v:IsA("TextLabel") or v:IsA("TextButton")) and v:FindFirstAncestorOfClass("BillboardGui") then 
                pcall(function() v.Text = nN end) 
            end 
        end 
    end 
    hub:Notif("System", "Nama diubah ke "..nN, 2) 
end)

local Tp = {
    ["Iron Cavern"] = Vector3.new(-8795.22, -585.00, 91.66),
    ["Fisherman Island"] = Vector3.new(41.07, 9.66, 2806.15),
    ["Kohana"] = Vector3.new(-651.91, 16.04, 603.68),
    ["Kohana Volcano"] = Vector3.new(-562.00, 21.29, 156.00),
    ["Coral Reef"] = Vector3.new(-3272.00, 2.50, 2232.00),
    ["Farm Enchant Stone"] = Vector3.new(3232.00, -1302.85, 1401.00),
    ["Tropical Grove"] = Vector3.new(-2034.16, 6.27, 3715.66),
    ["Crater Island"] = Vector3.new(1052.00, 2.21, 5022.02),
    ["Sisyphus Statue"] = Vector3.new(-3701.88, -135.57, -1016.46),
    ["Treasure Room"] = Vector3.new(-3603.00, -266.57, -1578.01),
    ["Ancient Jungle"] = Vector3.new(1494.11, 7.41, -436.36),
    ["Sacred Temple"] = Vector3.new(1481.89, -21.85, -632.26),
    ["Ancient Ruin"] = Vector3.new(6089.02, -585.92, 4635.00),
    ["Underground Cellar"] = Vector3.new(2134.00, -91.20, -692.01)
}
local lN={}; for n in pairs(Tp) do table.insert(lN, n) end; table.sort(lN)
local sT=nil

pTp:AddDropdown("Pilih Lokasi", lN, function(s) sT = s end)
pTp:AddButton("Teleport ke Lokasi", function() 
    if sT and Tp[sT] then 
        pcall(function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(Tp[sT]) end)
        hub:Notif("Teleport", "Menuju: "..sT, 2) 
    end 
end)

pTp:AddSeparator()
local function getPlrs() 
    local l={}
    for _,v in ipairs(Plrs:GetPlayers()) do 
        if v~=LP then table.insert(l,v.Name) end 
    end
    table.sort(l)
    return l 
end

local sPlr = nil
local dropPlr = pTp:AddDropdown("Pilih Player", getPlrs(), function(s) sPlr = s end)
pTp:AddButton("Refresh List Player", function() 
    dropPlr:Refresh(getPlrs()) 
    hub:Notif("Teleport", "Daftar Player Diperbarui", 2) 
end)
pTp:AddButton("Teleport ke Player", function() 
    if sPlr then 
        local p=Plrs:FindFirstChild(sPlr) 
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
            LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
            hub:Notif("Teleport", "Berhasil teleport ke "..sPlr, 2) 
        else 
            hub:Notif("Error", "Player/Karakter tidak ditemukan", 3) 
        end 
    else 
        hub:Notif("Error", "Pilih player terlebih dahulu!", 3) 
    end 
end)

pMsc:AddToggle("Disable Cutscene", function(s) 
    hub.S.DC=s
    if Net.RC and getconnections then 
        for _, c in ipairs(getconnections(Net.RC.OnClientEvent)) do 
            if s then c:Disable() else c:Enable() end 
        end
        hub:Notif("System", "Cutscene "..(s and "Mati" or "Nyala"), 2) 
    else 
        hub:Notif("Error", "Fungsi getconnections tidak didukung", 3) 
    end 
end)

local cachedVFX = {}
pMsc:AddToggle("Disable VFX", function(s)
    hub.S.DVFX = s
    local vfxF = RS:FindFirstChild("VFX")
    if vfxF then
        if s then
            for _, v in ipairs(vfxF:GetChildren()) do
                cachedVFX[v.Name] = v
                v.Parent = nil
                local m = Instance.new("Model")
                m.Name = v.Name
                m.Parent = vfxF
            end
            hub:Notif("System", "VFX Berhasil Dimatikan", 2)
        else
            for _, v in ipairs(vfxF:GetChildren()) do
                v:Destroy()
            end
            for _, v in pairs(cachedVFX) do
                v.Parent = vfxF
            end
            cachedVFX = {}
            hub:Notif("System", "VFX Dikembalikan", 2)
        end
    else
        hub:Notif("Error", "Folder VFX tidak ditemukan", 3)
    end
end)

pMsc:AddToggle("Boost FPS", function(s)
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    
    if s then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end
        hub:Notif("System", "Boost FPS Aktif", 2)
    else
        Lighting.GlobalShadows = true
        hub:Notif("System", "Boost FPS Dimatikan", 3)
    end
end)

pMsc:AddToggle("Anti-AFK", function(s) hub.S.AFK = s end)
LP.Idled:Connect(function() 
    if hub.S.AFK then 
        VU:CaptureController()
        VU:ClickButton2(Vector2.new()) 
    end 
end)

-- Floating Hide/Show Button
local ToggleGui = Instance.new("TextButton")
ToggleGui.Name = "ToggleGui"
ToggleGui.Size = UDim2.fromOffset(50,50)
ToggleGui.Position = UDim2.new(0,20,0.5,0)
ToggleGui.BackgroundColor3 = C.El
ToggleGui.Text = "Menu"
ToggleGui.TextColor3 = C.Tx
ToggleGui.Font = Enum.Font.GothamMedium
ToggleGui.TextSize = 12
ToggleGui.Parent = hub.SG
local tc = Instance.new("UICorner", ToggleGui)
tc.CornerRadius = UDim.new(1,0)
Mk("UIStroke", {Color=C.Sp, Thickness=1, Parent=ToggleGui})

ToggleGui.MouseButton1Click:Connect(function()
    hub.MF.Visible = not hub.MF.Visible
end)
