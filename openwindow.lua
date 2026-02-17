-- lib fluent code


-- +CODE
 -- +UD
 --+TRUST ME BRO



local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Key System Configuration
local KeySystemConfig = {
    Enabled = true,
    KeyLink = "https://discord.gg/fc4UPvqx4T",
    ValidKeys = {
        "Hola Senior",
        "VoxyHub26",
        "PapiDaddy"
    },
    UseWebAPI = false,
    APIEndpoint = "https://yourwebsite.com/api/validatekey?key=",
}

local function ValidateKey(key)
    for _, validKey in pairs(KeySystemConfig.ValidKeys) do
        if key == validKey then
            return true
        end
    end
    
    if KeySystemConfig.UseWebAPI then
        local success, response = pcall(function()
            return game:HttpGet(KeySystemConfig.APIEndpoint .. HttpService:UrlEncode(key))
        end)
        
        if success then
            local data = HttpService:JSONDecode(response)
            return data.valid == true
        end
    end
    
    return false
end

local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return hwid
end

_G.VoxyHubKeyValid = _G.VoxyHubKeyValid or false
_G.VoxyHubUserKey = _G.VoxyHubUserKey or nil

local keyValid = _G.VoxyHubKeyValid

if KeySystemConfig.Enabled and not keyValid then
    local KeyWindow = Fluent:CreateWindow({
        Title = "Voxy Hub | Key System",
        SubTitle = "Enter your key to continue",
        TabWidth = 160,
        Size = UDim2.fromOffset(500, 350),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = nil
    })
    
    local KeyTab = KeyWindow:AddTab({ Title = "🔑 Key System", Icon = "key" })
    
    KeyTab:AddParagraph({
        Title = "Welcome to Voxy Hub!",
        Content = "Please enter your key to access the script."
    })
    
    KeyTab:AddParagraph({
        Title = "Your HWID",
        Content = "HWID: " .. GetHWID()
    })
    
    KeyTab:AddButton({
        Title = "Copy HWID",
        Description = "Copy your Hardware ID",
        Callback = function()
            setclipboard(GetHWID())
            Fluent:Notify({
                Title = "Copied!",
                Content = "HWID copied to clipboard!",
                Duration = 3
            })
        end
    })
    
    local enteredKey = ""
    
    KeyTab:AddInput("KeyInput", {
        Title = "Enter Key",
        Description = "Type or paste your key here",
        Default = "",
        Placeholder = "Enter key here...",
        Callback = function(Value)
            enteredKey = Value
        end
    })
    
    KeyTab:AddButton({
        Title = "Submit Key",
        Description = "Click to verify",
        Callback = function()
            if ValidateKey(enteredKey) then
                keyValid = true
                _G.VoxyHubKeyValid = true
                _G.VoxyHubUserKey = enteredKey
                
                Fluent:Notify({
                    Title = "Success!",
                    Content = "Key verified! Loading...",
                    Duration = 3
                })
                
                warn("[VOXY HUB] ✓ Key validated")
                warn("[VOXY HUB] ✓ User: " .. LocalPlayer.Name)
                
                task.wait(1)
                KeyWindow:Destroy()
                
                loadstring(game:HttpGet("https://raw.githubusercontent.com/sh4rkfn/open-source-hub/refs/heads/main/main.lua"))()
            else
                Fluent:Notify({
                    Title = "Invalid Key",
                    Content = "Incorrect key. Try again.",
                    Duration = 5
                })
            end
        end
    })
    
    KeyTab:AddButton({
        Title = "Get Key",
        Description = "Copy Discord link",
        Callback = function()
            setclipboard(KeySystemConfig.KeyLink)
            Fluent:Notify({
                Title = "Copied!",
                Content = "Discord link copied!",
                Duration = 4
            })
        end
    })
    
    KeyTab:AddButton({
        Title = "Try Free Key",
        Description = "Copy: Hola Senior",
        Callback = function()
            setclipboard("Hola Senior")
            Fluent:Notify({
                Title = "Copied!",
                Content = "Free key copied - paste above",
                Duration = 5
            })
        end
    })
    
    return
end

-- ============================================================
-- MAIN SCRIPT
-- ============================================================

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Camera = Workspace.CurrentCamera

local Config = {
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmoothing = 0.2,
    TeamCheck = true,
    ShowFOV = true,
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    ESPTeamCheck = true,
    WalkSpeed = 16,
    JumpPower = 50,
    Flight = false,
    FlightSpeed = 50,
    NoClip = false,
    InfiniteJump = false,
    GodMode = false,
    Fullbright = false,
    NoFog = false,
}

local State = {
    ESPObjects = {},
    FOVCircle = nil,
    AimbotConnection = nil,
    FlightConnection = nil,
    NoClipConnection = nil,
    GodModeConnection = nil,
    OriginalLighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
}

local function GetCharacter(player)
    return player and player.Character
end

local function GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(player)
    local character = GetCharacter(player)
    local humanoid = GetHumanoid(character)
    return character and humanoid and humanoid.Health > 0
end

local function IsTeamMate(player)
    if not Config.TeamCheck then return false end
    if not LocalPlayer.Team or not player.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Config.AimbotFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if not IsTeamMate(player) then
                local character = GetCharacter(player)
                local head = character and character:FindFirstChild("Head")
                
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen and screenPos.Z > 0 then
                        local mouseLocation = UserInputService:GetMouseLocation()
                        local screenPosVec = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mouseLocation - screenPosVec).Magnitude
                        
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function Log(message, type)
    local prefix = "[VOXY HUB]"
    local timestamp = os.date("%H:%M:%S")
    local fullMessage = string.format("%s [%s] %s", prefix, timestamp, message)
    
    if type == "success" then
        warn("✓ " .. fullMessage)
    elseif type == "error" then
        warn("✗ " .. fullMessage)
    elseif type == "info" then
        warn("ℹ " .. fullMessage)
    else
        warn(fullMessage)
    end
end

local function CreateESP(player)
    if State.ESPObjects[player] then return end
    
    local ESPData = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
    }
    
    ESPData.Box.Thickness = 1
    ESPData.Box.Filled = false
    ESPData.Box.Color = Config.ESPColor
    ESPData.Box.Transparency = 1
    ESPData.Box.Visible = false
    
    ESPData.BoxOutline.Thickness = 3
    ESPData.BoxOutline.Filled = false
    ESPData.BoxOutline.Color = Color3.new(0, 0, 0)
    ESPData.BoxOutline.Transparency = 1
    ESPData.BoxOutline.Visible = false
    
    ESPData.Name.Size = 13
    ESPData.Name.Center = true
    ESPData.Name.Outline = true
    ESPData.Name.Color = Color3.new(1, 1, 1)
    ESPData.Name.Transparency = 1
    ESPData.Name.Visible = false
    
    ESPData.Distance.Size = 13
    ESPData.Distance.Center = true
    ESPData.Distance.Outline = true
    ESPData.Distance.Color = Color3.new(1, 1, 1)
    ESPData.Distance.Transparency = 1
    ESPData.Distance.Visible = false
    
    ESPData.HealthBar.Thickness = 1
    ESPData.HealthBar.Filled = true
    ESPData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    ESPData.HealthBar.Transparency = 1
    ESPData.HealthBar.Visible = false
    
    ESPData.HealthBarOutline.Thickness = 1
    ESPData.HealthBarOutline.Filled = false
    ESPData.HealthBarOutline.Color = Color3.new(0, 0, 0)
    ESPData.HealthBarOutline.Transparency = 1
    ESPData.HealthBarOutline.Visible = false
    
    ESPData.HealthBarBackground.Thickness = 1
    ESPData.HealthBarBackground.Filled = true
    ESPData.HealthBarBackground.Color = Color3.fromRGB(50, 50, 50)
    ESPData.HealthBarBackground.Transparency = 0.5
    ESPData.HealthBarBackground.Visible = false
    
    ESPData.Tracer.Thickness = 1
    ESPData.Tracer.Color = Config.ESPColor
    ESPData.Tracer.Transparency = 1
    ESPData.Tracer.Visible = false
    
    State.ESPObjects[player] = ESPData
end

local function RemoveESP(player)
    if State.ESPObjects[player] then
        for _, drawing in pairs(State.ESPObjects[player]) do
            drawing:Remove()
        end
        State.ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for player, ESPData in pairs(State.ESPObjects) do
        pcall(function()
            if player and IsAlive(player) and player ~= LocalPlayer then
                if Config.ESPEnabled and (not Config.ESPTeamCheck or not IsTeamMate(player)) then
                    local character = GetCharacter(player)
                    local rootPart = GetRootPart(character)
                    local humanoid = GetHumanoid(character)
                    
                    if rootPart and humanoid then
                        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        
                        if onScreen and rootPos.Z > 0 then
                            local headPos = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2, 0))
                            local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                            
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2
                            
                            if Config.ESPBoxes then
                                ESPData.Box.Visible = true
                                ESPData.BoxOutline.Visible = true
                                ESPData.Box.Size = Vector2.new(width, height)
                                ESPData.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                                ESPData.BoxOutline.Size = ESPData.Box.Size
                                ESPData.BoxOutline.Position = ESPData.Box.Position
                            else
                                ESPData.Box.Visible = false
                                ESPData.BoxOutline.Visible = false
                            end
                            
                            if Config.ESPNames then
                                ESPData.Name.Visible = true
                                ESPData.Name.Text = player.Name
                                ESPData.Name.Position = Vector2.new(rootPos.X, headPos.Y - 15)
                            else
                                ESPData.Name.Visible = false
                            end
                            
                            if Config.ESPDistance then
                                local distance = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
                                ESPData.Distance.Visible = true
                                ESPData.Distance.Text = tostring(distance) .. "m"
                                ESPData.Distance.Position = Vector2.new(rootPos.X, legPos.Y + 5)
                            else
                                ESPData.Distance.Visible = false
                            end
                            
                            if Config.ESPHealth then
                                ESPData.HealthBarBackground.Visible = true
                                ESPData.HealthBarOutline.Visible = true
                                ESPData.HealthBar.Visible = true
                                
                                local healthPercent = humanoid.Health / humanoid.MaxHealth
                                local barHeight = height * healthPercent
                                
                                ESPData.HealthBarBackground.Size = Vector2.new(4, height)
                                ESPData.HealthBarBackground.Position = Vector2.new(rootPos.X - width / 2 - 6, rootPos.Y - height / 2)
                                
                                ESPData.HealthBarOutline.Size = Vector2.new(4, height)
                                ESPData.HealthBarOutline.Position = ESPData.HealthBarBackground.Position
                                
                                ESPData.HealthBar.Size = Vector2.new(4, barHeight)
                                ESPData.HealthBar.Position = Vector2.new(rootPos.X - width / 2 - 6, rootPos.Y + height / 2 - barHeight)
                                ESPData.HealthBar.Color = Color3.fromRGB(
                                    255 * (1 - healthPercent),
                                    255 * healthPercent,
                                    0
                                )
                            else
                                ESPData.HealthBarBackground.Visible = false
                                ESPData.HealthBarOutline.Visible = false
                                ESPData.HealthBar.Visible = false
                            end
                            
                            if Config.ESPTracers then
                                ESPData.Tracer.Visible = true
                                ESPData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                ESPData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            else
                                ESPData.Tracer.Visible = false
                            end
                            
                            return
                        end
                    end
                end
            end
            
            for _, drawing in pairs(ESPData) do
                drawing.Visible = false
            end
        end)
    end
end

local function CreateFOVCircle()
    if State.FOVCircle then
        State.FOVCircle:Remove()
    end
    
    State.FOVCircle = Drawing.new("Circle")
    State.FOVCircle.Thickness = 2
    State.FOVCircle.NumSides = 50
    State.FOVCircle.Radius = Config.AimbotFOV
    State.FOVCircle.Filled = false
    State.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    State.FOVCircle.Transparency = 0.5
    State.FOVCircle.Visible = true
    State.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local Window = Fluent:CreateWindow({
    Title = "Voxy Hub | Universal",
    SubTitle = "by Voxy Team - All Features Fixed",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Combat = Window:AddTab({ Title = "⚔️ Combat", Icon = "sword" }),
    Player = Window:AddTab({ Title = "🏃 Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = "👁️ Visual", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "⚙️ Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" })
}

Fluent:Notify({
    Title = "Voxy Hub",
    Content = "Welcome " .. LocalPlayer.Name .. "!",
    Duration = 5
})

Log("Script loaded", "success")

-- COMBAT TAB
Tabs.Combat:AddParagraph({
    Title = "🎯 Aimbot",
    Content = "Hold RIGHT MOUSE to aim"
})

Tabs.Combat:AddToggle("Aimbot", {
    Title = "Enable Aimbot",
    Description = "Lock onto nearest player",
    Default = false,
    Callback = function(Value)
        Config.AimbotEnabled = Value
        
        if Value then
            CreateFOVCircle()
            Log("Aimbot ON - Hold RIGHT MOUSE", "success")
            
            if State.AimbotConnection then
                State.AimbotConnection:Disconnect()
            end
            
            State.AimbotConnection = RunService.RenderStepped:Connect(function()
                if Config.AimbotEnabled then
                    if State.FOVCircle then
                        State.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        State.FOVCircle.Radius = Config.AimbotFOV
                        State.FOVCircle.Visible = Config.ShowFOV
                    end
                    
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                        local target = GetClosestPlayerToCursor()
                        
                        if target then
                            local character = GetCharacter(target)
                            local head = character and character:FindFirstChild("Head")
                            
                            if head then
                                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                                
                                if onScreen and headPos.Z > 0 then
                                    local mouseLocation = UserInputService:GetMouseLocation()
                                    local deltaX = (headPos.X - mouseLocation.X) * Config.AimbotSmoothing
                                    local deltaY = (headPos.Y - mouseLocation.Y) * Config.AimbotSmoothing
                                    mousemoverel(deltaX, deltaY)
                                end
                            end
                        end
                    end
                end
            end)
            
            Fluent:Notify({
                Title = "Aimbot",
                Content = "Hold RIGHT MOUSE to aim!",
                Duration = 3
            })
        else
            Log("Aimbot OFF", "info")
            if State.AimbotConnection then
                State.AimbotConnection:Disconnect()
                State.AimbotConnection = nil
            end
            if State.FOVCircle then
                State.FOVCircle.Visible = false
            end
        end
    end
})

Tabs.Combat:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(Value)
        Config.ShowFOV = Value
        if State.FOVCircle then
            State.FOVCircle.Visible = Value and Config.AimbotEnabled
        end
    end
})

Tabs.Combat:AddToggle("TeamCheck", {
    Title = "Team Check",
    Default = true,
    Callback = function(Value)
        Config.TeamCheck = Value
    end
})

Tabs.Combat:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.AimbotFOV = Value
        if State.FOVCircle then
            State.FOVCircle.Radius = Value
        end
    end
})

Tabs.Combat:AddSlider("Smoothing", {
    Title = "Smoothing",
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Config.AimbotSmoothing = Value
    end
})

-- REST OF TABS (Player, Visual, Misc, Settings) - KEEPING SAME AS BEFORE BUT I'll add complete code

Tabs.Player:AddParagraph({
    Title = "🏃 Movement",
    Content = "Movement enhancements"
})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.WalkSpeed = Value
        local char = GetCharacter(LocalPlayer)
        local hum = GetHumanoid(char)
        if hum then hum.WalkSpeed = Value end
    end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.JumpPower = Value
        local char = GetCharacter(LocalPlayer)
        local hum = GetHumanoid(char)
        if hum then
            hum.JumpPower = Value
            hum.UseJumpPower = true
        end
    end
})

Tabs.Player:AddToggle("Flight", {
    Title = "Flight",
    Default = false,
    Callback = function(Value)
        Config.Flight = Value
        
        if Value then
            local char = GetCharacter(LocalPlayer)
            local root = GetRootPart(char)
            if not root then return end
            
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlightVelocity"
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
            
            if State.FlightConnection then State.FlightConnection:Disconnect() end
            
            State.FlightConnection = RunService.Heartbeat:Connect(function()
                if not Config.Flight then return end
                
                local c = GetCharacter(LocalPlayer)
                local r = GetRootPart(c)
                if not r then return end
                
                local b = r:FindFirstChild("FlightVelocity")
                if not b then return end
                
                local vel = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    vel = vel + (Camera.CFrame.LookVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    vel = vel - (Camera.CFrame.LookVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    vel = vel - (Camera.CFrame.RightVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    vel = vel + (Camera.CFrame.RightVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vel = vel + Vector3.new(0, Config.FlightSpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vel = vel - Vector3.new(0, Config.FlightSpeed, 0)
                end
                
                b.Velocity = vel
            end)
            
            Log("Flight ON", "success")
        else
            if State.FlightConnection then
                State.FlightConnection:Disconnect()
                State.FlightConnection = nil
            end
            
            local char = GetCharacter(LocalPlayer)
            local root = GetRootPart(char)
            if root then
                local bv = root:FindFirstChild("FlightVelocity")
                if bv then bv:Destroy() end
            end
            Log("Flight OFF", "info")
        end
    end
})

Tabs.Player:AddSlider("FlightSpeed", {
    Title = "Flight Speed",
    Default = 50,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.FlightSpeed = Value
    end
})

Tabs.Player:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false,
    Callback = function(Value)
        Config.NoClip = Value
        
        if Value then
            if State.NoClipConnection then State.NoClipConnection:Disconnect() end
            
            State.NoClipConnection = RunService.Stepped:Connect(function()
                if not Config.NoClip then return end
                
                local char = GetCharacter(LocalPlayer)
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            Log("NoClip ON", "success")
        else
            if State.NoClipConnection then
                State.NoClipConnection:Disconnect()
                State.NoClipConnection = nil
            end
            
            local char = GetCharacter(LocalPlayer)
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
            Log("NoClip OFF", "info")
        end
    end
})

Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        Config.InfiniteJump = Value
        Log(Value and "Infinite Jump ON" or "Infinite Jump OFF", Value and "success" or "info")
    end
})

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = GetCharacter(LocalPlayer)
        local hum = GetHumanoid(char)
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Tabs.Player:AddToggle("GodMode", {
    Title = "God Mode",
    Default = false,
    Callback = function(Value)
        Config.GodMode = Value
        
        if Value then
            if State.GodModeConnection then State.GodModeConnection:Disconnect() end
            
            State.GodModeConnection = RunService.Heartbeat:Connect(function()
                if not Config.GodMode then return end
                
                local char = GetCharacter(LocalPlayer)
                local hum = GetHumanoid(char)
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
            Log("God Mode ON", "success")
        else
            if State.GodModeConnection then
                State.GodModeConnection:Disconnect()
                State.GodModeConnection = nil
            end
            Log("God Mode OFF", "info")
        end
    end
})

-- VISUAL TAB
Tabs.Visual:AddParagraph({
    Title = "👁️ ESP",
    Content = "See players through walls"
})

Tabs.Visual:AddToggle("ESP", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(Value)
        Config.ESPEnabled = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESP(player)
                end
            end
            Log("ESP ON", "success")
        else
            for player, _ in pairs(State.ESPObjects) do
                for _, drawing in pairs(State.ESPObjects[player]) do
                    drawing.Visible = false
                end
            end
            Log("ESP OFF", "info")
        end
    end
})

Tabs.Visual:AddToggle("ESPBoxes", {Title = "Boxes", Default = true, Callback = function(v) Config.ESPBoxes = v end})
Tabs.Visual:AddToggle("ESPNames", {Title = "Names", Default = true, Callback = function(v) Config.ESPNames = v end})
Tabs.Visual:AddToggle("ESPDistance", {Title = "Distance", Default = true, Callback = function(v) Config.ESPDistance = v end})
Tabs.Visual:AddToggle("ESPHealth", {Title = "Health Bar", Default = true, Callback = function(v) Config.ESPHealth = v end})
Tabs.Visual:AddToggle("ESPTracers", {Title = "Tracers", Default = false, Callback = function(v) Config.ESPTracers = v end})
Tabs.Visual:AddToggle("ESPTeamCheck", {Title = "Team Check", Default = true, Callback = function(v) Config.ESPTeamCheck = v end})

Tabs.Visual:AddToggle("Fullbright", {
    Title = "Fullbright",
    Default = false,
    Callback = function(Value)
        Config.Fullbright = Value
        
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Log("Fullbright ON", "success")
        else
            Lighting.Brightness = State.OriginalLighting.Brightness
            Lighting.ClockTime = State.OriginalLighting.ClockTime
            Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
            Lighting.OutdoorAmbient = State.OriginalLighting.OutdoorAmbient
            Log("Fullbright OFF", "info")
        end
    end
})

Tabs.Visual:AddToggle("NoFog", {
    Title = "No Fog",
    Default = false,
    Callback = function(Value)
        Config.NoFog = Value
        Lighting.FogEnd = Value and 100000 or State.OriginalLighting.FogEnd
        Log(Value and "No Fog ON" or "No Fog OFF", Value and "success" or "info")
    end
})

-- MISC TAB
Tabs.Misc:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.Misc:AddButton({
    Title = "Server Hop",
    Callback = function()
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end
})

Tabs.Misc:AddButton({
    Title = "Copy Game ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        Fluent:Notify({Title = "Copied", Content = "Game ID copied!", Duration = 3})
    end
})

Tabs.Misc:AddButton({
    Title = "Copy HWID",
    Callback = function()
        setclipboard(GetHWID())
        Fluent:Notify({Title = "Copied", Content = "HWID copied!", Duration = 3})
    end
})

-- SETTINGS
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("VoxyHub")
SaveManager:SetFolder("VoxyHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

-- EVENTS
Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    if Config.ESPEnabled then CreateESP(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.1)
    
    local hum = GetHumanoid(character)
    if hum then
        if Config.WalkSpeed ~= 16 then hum.WalkSpeed = Config.WalkSpeed end
        if Config.JumpPower ~= 50 then
            hum.JumpPower = Config.JumpPower
            hum.UseJumpPower = true
        end
    end
    
    if Config.Flight then
        task.wait(0.5)
        local root = GetRootPart(character)
        if root and not root:FindFirstChild("FlightVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlightVelocity"
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        UpdateESP()
    end
end)

warn("═══════════════════════════════════════")
warn("  VOXY HUB LOADED - ALL FEATURES FIXED")
warn("  Version: 3.3")
warn("  User: " .. LocalPlayer.Name)
warn("  HWID: " .. GetHWID())
warn("═══════════════════════════════════════")

Log("Ready! Hold RIGHT MOUSE for aimbot", "success")

Fluent:Notify({
    Title = "Ready!",
    Content = "All features working! Hold RIGHT MOUSE for aimbot",
    Duration = 5
})
