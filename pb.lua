local S = setmetatable({}, {__index = function(_, k) 
    local srv = game:GetService(k)
    return type(cloneref) == "function" and pcall(cloneref, srv) and cloneref(srv) or srv 
end})

local P, RS, UIS, Http = S.Players, S.RunService, S.UserInputService, S.HttpService
local VIM = S.VirtualInputManager 
local LP, Cam = P.LocalPlayer, workspace.CurrentCamera

local Cfg = { ESP = false, Aim = false, Assist = false, Trig = false, Hitbox = false, HitTgt = "Head", HitSize = 12, Tgt = "Head", Smth = 0.08, Insta = false, Team = true, FOV = 250, Wall = false, PredOn = false, Pred = 0.145, Fps = false, Spd = false, AntiFall = false, Boost = 40 }

-- (GUI setup tetap sama untuk menjaga performa)
local FC = Drawing.new("Circle")
FC.Position, FC.Radius, FC.Filled, FC.Color, FC.Visible, FC.Transparency, FC.Thickness = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2), Cfg.FOV, false, Color3.new(1,1,1), false, 0.8, 1
Cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() FC.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2) end)

local CG = pcall(gethui) and gethui() or S.CoreGui
local SG = Instance.new("ScreenGui")
SG.Name, SG.ResetOnSpawn = "RobloxGui", false
if not pcall(function() SG.Parent = CG end) then SG.Parent = LP:WaitForChild("PlayerGui") end

local function Make(cls, props, parent)
    local i = Instance.new(cls)
    for k, v in pairs(props) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local MF = Make("Frame", {Name="Frame", Size=UDim2.new(0,240,0,410), Position=UDim2.new(0,15,0,15), BackgroundColor3=Color3.fromRGB(10,10,10), BackgroundTransparency=0.3, Active=true, Draggable=true}, SG)
Make("UIStroke", {Color=Color3.fromRGB(255, 50, 50), Thickness=1}, MF) 
local Title = Make("TextLabel", {Name="TextLabel", Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Text="[ KEMPLONGXD HUB V25 ]", TextColor3=Color3.fromRGB(255, 50, 50), TextSize=15, Font=Enum.Font.Code, TextXAlignment=2}, MF)
Make("Frame", {Size=UDim2.new(1,-10,0,1), Position=UDim2.new(0,5,0,30), BackgroundColor3=Color3.fromRGB(255, 50, 50), BorderSizePixel=0}, MF)
local MobBtn = Make("TextButton", {Name="TextButton", Size=UDim2.new(0,40,0,40), Position=UDim2.new(0,15,0,440), BackgroundColor3=Color3.fromRGB(10,10,10), BackgroundTransparency=0.3, TextColor3=Color3.new(1,1,1), Text="KXD", Font=Enum.Font.Code, TextSize=14, Draggable=true, Active=true}, SG)
Make("UIStroke", {Color=Color3.fromRGB(255, 50, 50)}, MobBtn)
MobBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then MF.Visible = not MF.Visible end end)

local Cont = Make("Frame", {Name="Frame", Position=UDim2.new(0,10,0,40), Size=UDim2.new(1,-20,1,-50), BackgroundTransparency=1}, MF)
Make("UIListLayout", {SortOrder=2, Padding=UDim.new(0,2)}, Cont)

local function AddPBBtn(txt, varName, isMode, cb)
    local B = Make("TextButton", {Name="TextButton", Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Font=Enum.Font.Code, TextSize=14, TextXAlignment=0}, Cont)
    local function UpdateTxt()
        if isMode then
            local modeTxt = Cfg[varName]
            if varName == "Tgt" then modeTxt = (Cfg[varName] == "HumanoidRootPart" and "Body" or "Head") end
            B.Text = " -> " .. txt .. " [ " .. modeTxt .. " ]"
            B.TextColor3 = Color3.fromRGB(255, 170, 0)
        else
            B.Text = " -> " .. txt .. (Cfg[varName] and " [ ON ]" or " [ OFF ]")
            B.TextColor3 = Cfg[varName] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        end
    end
    UpdateTxt()
    B.Activated:Connect(function()
        if isMode then
            if varName == "HitTgt" then Cfg[varName] = Cfg[varName] == "Head" and "Body" or "Head"
            else Cfg[varName] = Cfg[varName] == "Head" and "HumanoidRootPart" or "Head" end
        else Cfg[varName] = not Cfg[varName] end
        if cb then cb() end
        UpdateTxt()
    end)
    return B
end

AddPBBtn("Player ESP", "ESP")
AddPBBtn("Auto Aim", "Aim")
AddPBBtn("Aim Assist", "Assist")
AddPBBtn("Instant Lock", "Insta")
AddPBBtn("Aim Target", "Tgt", true)
AddPBBtn("Prediction", "PredOn") 
AddPBBtn("TriggerBot", "Trig") 
AddPBBtn("Expand Hitbox", "Hitbox") 
AddPBBtn("Hitbox Tgt", "HitTgt", true) 
AddPBBtn("Team Check", "Team")
Make("Frame", {Size=UDim2.new(1,0,0,10), BackgroundTransparency=1}, Cont) 
AddPBBtn("FPS Boost", "Fps", false, function() if Cfg.Fps then local L = game:GetService("Lighting") L.GlobalShadows = false L.FogEnd = 9e9 for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end end end end)
AddPBBtn("Speed Hack", "Spd")
AddPBBtn("Anti Fall", "AntiFall")

local DrawESP = {}
local function SetupESP(p)
    if p == LP then return end
    DrawESP[p] = { Box = Drawing.new("Square"), Name = Drawing.new("Text") }
    DrawESP[p].Box.Color, DrawESP[p].Box.Thickness, DrawESP[p].Box.Filled = Color3.fromRGB(255,0,75), 1, false
    DrawESP[p].Name.Size, DrawESP[p].Name.Center, DrawESP[p].Name.Outline, DrawESP[p].Name.Color = 14, true, true, Color3.new(1,1,1)
end
for _, p in ipairs(P:GetPlayers()) do SetupESP(p) end
P.PlayerAdded:Connect(SetupESP)
P.PlayerRemoving:Connect(function(p) if DrawESP[p] then DrawESP[p].Box:Remove(); DrawESP[p].Name:Remove(); DrawESP[p]=nil end end)

local function IsVis(tPart)
    if not Cfg.Wall then return true end
    local char = LP.Character
    if not char then return false end
    local ray = RaycastParams.new()
    ray.FilterDescendantsInstances, ray.FilterType, ray.IgnoreWater = {char, Cam}, Enum.RaycastFilterType.Exclude, true
    local res = workspace:Raycast(Cam.CFrame.Position, (tPart.Position - Cam.CFrame.Position).Unit * (tPart.Position - Cam.CFrame.Position).Magnitude, ray)
    return not res or res.Instance:IsDescendantOf(tPart.Parent)
end

local lastShoot = 0

RS:BindToRenderStep("KXD_Engine", 201, function(dt)
    FC.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    local tData, closest3D = nil, math.huge
    local activeFOV = Cfg.Assist and 35 or Cfg.FOV
    FC.Radius = activeFOV
    FC.Visible = Cfg.Aim

    for _, p in ipairs(P:GetPlayers()) do
        if p == LP then continue end
        local char, esp = p.Character, DrawESP[p]
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
        
        local isAlive = char and char.Parent and hum and hum.Health > 0.1 and hum:GetState() ~= Enum.HumanoidStateType.Dead and root
        local isEnemy = not (Cfg.Team and LP.Team and p.Team == LP.Team)
        
        if isAlive and isEnemy and Cfg.Aim then
            local tp = char:FindFirstChild(Cfg.Tgt) or char:FindFirstChild("Head") or root
            if tp then
                local rPos, onScr = Cam:WorldToViewportPoint(tp.Position)
                local mag = (Vector2.new(rPos.X, rPos.Y) - FC.Position).Magnitude
                if mag < activeFOV and IsVis(tp) then
                    local dist3D = (Cam.CFrame.Position - tp.Position).Magnitude
                    if dist3D < closest3D then tData, closest3D = tp, dist3D end
                end
            end
        end
    end

    -- [UNIFIED AIM ENGINE]
    if Cfg.Aim and tData then
        local pos = tData.Position + (Cfg.PredOn and (tData.AssemblyLinearVelocity * Cfg.Pred) or Vector3.new())
        local lookFrame = CFrame.new(Cam.CFrame.Position, pos)
        
        if Cfg.Insta then 
            Cam.CFrame = lookFrame 
        else
            local smoothFactor = 1 - math.pow(1 - Cfg.Smth, dt * 60)
            Cam.CFrame = Cam.CFrame:Lerp(lookFrame, smoothFactor)
        end

        if Cfg.Trig and (tick() - lastShoot > 0.15) then
            local scPos = Cam:WorldToViewportPoint(tData.Position)
            if (Vector2.new(scPos.X, scPos.Y) - FC.Position).Magnitude < 30 then
                lastShoot = tick()
                VIM:SendMouseButtonEvent(FC.Position.X, FC.Position.Y, 0, true, game, 1)
                task.delay(0.05, function() VIM:SendMouseButtonEvent(FC.Position.X, FC.Position.Y, 0, false, game, 1) end)
            end
        end
    end
end)
