

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()


local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Key System Configuration
local KeySystemConfig = {
    Enabled = true,
    KeyLink = "https://discord.gg/fc4UPvqx4T", -- Link to get the key
    
    -- Web-based key validation (you can host your own key checker)
    ValidKeys = {
        "Hola Senior",
        "VoxyHub26",
        "PapiDaddy"
    },
    
    -- Optional: Use a web API for key validation
    UseWebAPI = false,
    APIEndpoint = "https://yourwebsite.com/api/validatekey?key=",
}

-- Function to check if key is valid
local function ValidateKey(key)
    -- Method 1: Check against list
    for _, validKey in pairs(KeySystemConfig.ValidKeys) do
        if key == validKey then
            return true
        end
    end
    
    -- Method 2: Optional web API validation
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

-- Function to generate HWID (Hardware ID alternative)
local function GetHWID()
    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    return hwid
end

-- Session storage (resets when script reloads)
_G.VoxyHubKeyValid = _G.VoxyHubKeyValid or false
_G.VoxyHubUserKey = _G.VoxyHubUserKey or nil

-- Check if key is already validated in this session
local keyValid = _G.VoxyHubKeyValid

-- Create Key System Window if key not valid
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
    
    local KeyTab = KeyWindow:AddTab({ Title = "Key System", Icon = "key" })
    
    KeyTab:AddParagraph({
        Title = "Welcome to Voxy Hub!",
        Content = "Please enter your key to access the script.\nJoin our Discord to get a key!"
    })
    
    -- Display HWID for whitelist systems
    KeyTab:AddParagraph({
        Title = "Your HWID",
        Content = "HWID: " .. GetHWID() .. "\n(Click button below to copy)"
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
    
    local KeyInput = KeyTab:AddInput("KeyInput", {
        Title = "Enter Key",
        Description = "Type or paste your key here",
        Default = "",
        Placeholder = "Enter key here...",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            enteredKey = Value
        end
    })
    
    KeyTab:AddButton({
        Title = "Submit Key",
        Description = "Click to verify your key",
        Callback = function()
            if ValidateKey(enteredKey) then
                keyValid = true
                _G.VoxyHubKeyValid = true
                _G.VoxyHubUserKey = enteredKey
                
                Fluent:Notify({
                    Title = "Success!",
                    Content = "Key verified! Loading Voxy Hub...",
                    Duration = 3
                })
                
                -- Output success message (alternative to print)
                warn("[VOXY HUB] ✓ Key validation successful")
                warn("[VOXY HUB] ✓ User: " .. LocalPlayer.Name)
                warn("[VOXY HUB] ✓ Key: " .. string.sub(enteredKey, 1, 4) .. "..." .. string.sub(enteredKey, -4))
                warn("[VOXY HUB] ✓ Loading main script...")
                
                task.wait(1)
                KeyWindow:Destroy()
                
                -- Reload script to load main content
                loadstring(game:HttpGet("https://raw.githubusercontent.com/sh4rkfn/open-source-hub/refs/heads/main/openwindow.lua"))()
            else
                Fluent:Notify({
                    Title = "Invalid Key",
                    Content = "The key you entered is incorrect. Please try again.",
                    Duration = 5
                })
                warn("[VOXY HUB] ✗ Invalid key attempt: " .. enteredKey)
            end
        end
    })
    
    KeyTab:AddButton({
        Title = "Get Key (Copy Discord Link)",
        Description = "Click to copy the Discord link",
        Callback = function()
            setclipboard(KeySystemConfig.KeyLink)
            Fluent:Notify({
                Title = "Copied!",
                Content = "Discord link copied to clipboard!",
                Duration = 4
            })
        end
    })
    
    KeyTab:AddButton({
        Title = "Try Free Key",
        Description = "Use the free key: VoxyHub2024",
        Callback = function()
            Fluent:Notify({
                Title = "Free Key",
                Content = "Free Key: VoxyHub2024\n(Click to copy)",
                Duration = 8
            })
            setclipboard("VoxyHub2024")
        end
    })
    
    KeyTab:AddParagraph({
        Title = "Valid Keys",
        Content = "• VoxyHub2024 (Free)\n• VoxyPremium2024 (Premium)\n• VoxyVIP2024 (VIP)"
    })
    
    -- Stop here if key is not valid
    return
end

-- ============================================================
-- MAIN SCRIPT STARTS HERE (Only loads if key is valid)
-- ============================================================

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Locals
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuration
local Config = {
    -- Combat
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmoothing = 0.2,
    TeamCheck = true,
    ShowFOV = true,
    AimbotKey = Enum.UserInputType.MouseButton2,
    
    -- ESP
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    ESPTeamCheck = true,
    
    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    Flight = false,
    FlightSpeed = 50,
    NoClip = false,
    InfiniteJump = false,
    
    -- Character
    GodMode = false,
    
    -- Visual
    Fullbright = false,
    NoFog = false,
}

-- State
local State = {
    Connections = {},
    ESPObjects = {},
    FlightConnection = nil,
    NoClipConnection = nil,
    AimbotConnection = nil,
    FOVCircle = nil,
    GodModeConnection = nil,
    OriginalLighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
}

-- Utility Functions
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
    return player.Team == LocalPlayer.Team
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Config.AimbotFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if not Config.TeamCheck or not IsTeamMate(player) then
                local character = GetCharacter(player)
                local rootPart = GetRootPart(character)
                
                if rootPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local screenPosVec = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mousePos - screenPosVec).Magnitude
                        
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

-- Logging function (alternative to print)
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

-- ESP Functions
local function CreateESP(player)
    if State.ESPObjects[player] then
        return
    end
    
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
    
    -- Box settings
    ESPData.Box.Thickness = 1
    ESPData.Box.Filled = false
    ESPData.Box.Color = Config.ESPColor
    ESPData.Box.Transparency = 1
    
    ESPData.BoxOutline.Thickness = 3
    ESPData.BoxOutline.Filled = false
    ESPData.BoxOutline.Color = Color3.new(0, 0, 0)
    ESPData.BoxOutline.Transparency = 1
    
    -- Text settings
    ESPData.Name.Size = 13
    ESPData.Name.Center = true
    ESPData.Name.Outline = true
    ESPData.Name.Color = Color3.new(1, 1, 1)
    ESPData.Name.Transparency = 1
    
    ESPData.Distance.Size = 13
    ESPData.Distance.Center = true
    ESPData.Distance.Outline = true
    ESPData.Distance.Color = Color3.new(1, 1, 1)
    ESPData.Distance.Transparency = 1
    
    -- Health bar settings
    ESPData.HealthBar.Thickness = 1
    ESPData.HealthBar.Filled = true
    ESPData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    ESPData.HealthBar.Transparency = 1
    
    ESPData.HealthBarOutline.Thickness = 1
    ESPData.HealthBarOutline.Filled = false
    ESPData.HealthBarOutline.Color = Color3.new(0, 0, 0)
    ESPData.HealthBarOutline.Transparency = 1
    
    ESPData.HealthBarBackground.Thickness = 1
    ESPData.HealthBarBackground.Filled = true
    ESPData.HealthBarBackground.Color = Color3.fromRGB(50, 50, 50)
    ESPData.HealthBarBackground.Transparency = 0.5
    
    -- Tracer settings
    ESPData.Tracer.Thickness = 1
    ESPData.Tracer.Color = Config.ESPColor
    ESPData.Tracer.Transparency = 1
    
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
        if player and IsAlive(player) and player ~= LocalPlayer then
            if Config.ESPEnabled and (not Config.ESPTeamCheck or not IsTeamMate(player)) then
                local character = GetCharacter(player)
                local rootPart = GetRootPart(character)
                local humanoid = GetHumanoid(character)
                
                if rootPart and humanoid then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2, 0))
                        local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        
                        -- Update Box
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
                        
                        -- Update Name
                        if Config.ESPNames then
                            ESPData.Name.Visible = true
                            ESPData.Name.Text = player.Name
                            ESPData.Name.Position = Vector2.new(rootPos.X, headPos.Y - 15)
                        else
                            ESPData.Name.Visible = false
                        end
                        
                        -- Update Distance
                        if Config.ESPDistance then
                            local distance = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
                            ESPData.Distance.Visible = true
                            ESPData.Distance.Text = tostring(distance) .. "m"
                            ESPData.Distance.Position = Vector2.new(rootPos.X, legPos.Y + 5)
                        else
                            ESPData.Distance.Visible = false
                        end
                        
                        -- Update Health Bar
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
                        
                        -- Update Tracer
                        if Config.ESPTracers then
                            ESPData.Tracer.Visible = true
                            ESPData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            ESPData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        else
                            ESPData.Tracer.Visible = false
                        end
                    else
                        for _, drawing in pairs(ESPData) do
                            drawing.Visible = false
                        end
                    end
                else
                    for _, drawing in pairs(ESPData) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(ESPData) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(ESPData) do
                drawing.Visible = false
            end
        end
    end
end

-- Create FOV Circle
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

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Voxy Hub | Universal",
    SubTitle = "by Voxy Team - Key Verified ✓",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Combat = Window:AddTab({ Title = " Combat", Icon = "sword" }),
    Player = Window:AddTab({ Title = " Player", Icon = "user" }),
    Visual = Window:AddTab({ Title = " Visual", Icon = "eye" }),
    Misc = Window:AddTab({ Title = " Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "cog" })
}

-- Notification
Fluent:Notify({
    Title = "Voxy Hub",
    Content = "Key verified! Welcome " .. LocalPlayer.Name,
    Duration = 5
})

Log("Script loaded successfully", "success")
Log("User: " .. LocalPlayer.Name, "info")
Log("HWID: " .. GetHWID(), "info")

-- ============================================================
-- COMBAT TAB
-- ============================================================

Tabs.Combat:AddParagraph({
    Title = " Aimbot",
    Content = "Advanced aimbot with FOV circle and smoothing"
})

local AimbotToggle = Tabs.Combat:AddToggle("AimbotToggle", {
    Title = "Enable Aimbot",
    Description = "Hold right mouse button to aim at nearest player",
    Default = false,
    Callback = function(Value)
        Config.AimbotEnabled = Value
        
        if Value then
            CreateFOVCircle()
            Log("Aimbot enabled", "success")
            
            if State.AimbotConnection then
                State.AimbotConnection:Disconnect()
            end
            
            State.AimbotConnection = RunService.RenderStepped:Connect(function()
                if Config.AimbotEnabled and UserInputService:IsMouseButtonPressed(Config.AimbotKey) then
                    local target = GetClosestPlayerToCursor()
                    
                    if target then
                        local character = GetCharacter(target)
                        local head = character and character:FindFirstChild("Head")
                        
                        if head then
                            local targetPos = Camera:WorldToViewportPoint(head.Position)
                            local mousePos = UserInputService:GetMouseLocation()
                            
                            local smoothTarget = Vector2.new(
                                mousePos.X + (targetPos.X - mousePos.X) * Config.AimbotSmoothing,
                                mousePos.Y + (targetPos.Y - mousePos.Y) * Config.AimbotSmoothing
                            )
                            
                            mousemoverel(
                                (smoothTarget.X - mousePos.X),
                                (smoothTarget.Y - mousePos.Y)
                            )
                        end
                    end
                end
                
                if State.FOVCircle then
                    State.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    State.FOVCircle.Radius = Config.AimbotFOV
                    State.FOVCircle.Visible = Config.AimbotEnabled and Config.ShowFOV
                end
            end)
            
            Fluent:Notify({
                Title = "Aimbot",
                Content = "Aimbot enabled! Hold right click",
                Duration = 3
            })
        else
            Log("Aimbot disabled", "info")
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

local ShowFOVToggle = Tabs.Combat:AddToggle("ShowFOV", {
    Title = "Show FOV Circle",
    Description = "Display the aimbot FOV circle",
    Default = true,
    Callback = function(Value)
        Config.ShowFOV = Value
        if State.FOVCircle then
            State.FOVCircle.Visible = Value and Config.AimbotEnabled
        end
    end
})

local TeamCheckToggle = Tabs.Combat:AddToggle("TeamCheck", {
    Title = "Team Check",
    Description = "Don't target teammates",
    Default = true,
    Callback = function(Value)
        Config.TeamCheck = Value
    end
})

local FOVSlider = Tabs.Combat:AddSlider("FOVSlider", {
    Title = "Aimbot FOV",
    Description = "Field of view for aimbot targeting",
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.AimbotFOV = Value
    end
})

local SmoothingSlider = Tabs.Combat:AddSlider("SmoothingSlider", {
    Title = "Smoothing",
    Description = "How smooth the aimbot moves (lower = smoother)",
    Default = 0.2,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Config.AimbotSmoothing = Value
    end
})

-- ============================================================
-- PLAYER TAB
-- ============================================================

Tabs.Player:AddParagraph({
    Title = "🏃 Movement",
    Content = "Enhance your character's movement abilities"
})

local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Change your walking speed",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.WalkSpeed = Value
        local character = GetCharacter(LocalPlayer)
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

local JumpPowerSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Change your jump height",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.JumpPower = Value
        local character = GetCharacter(LocalPlayer)
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid.JumpPower = Value
            humanoid.UseJumpPower = true
        end
    end
})

local FlightToggle = Tabs.Player:AddToggle("Flight", {
    Title = "Flight",
    Description = "Fly around the map (WASD + Space/Ctrl)",
    Default = false,
    Callback = function(Value)
        Config.Flight = Value
        
        if Value then
            Log("Flight enabled", "success")
            local character = GetCharacter(LocalPlayer)
            local rootPart = GetRootPart(character)
            
            if not rootPart then return end
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlightVelocity"
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
            
            if State.FlightConnection then
                State.FlightConnection:Disconnect()
            end
            
            State.FlightConnection = RunService.Heartbeat:Connect(function()
                if not Config.Flight then return end
                
                local char = GetCharacter(LocalPlayer)
                local hrp = GetRootPart(char)
                local bv = hrp and hrp:FindFirstChild("FlightVelocity")
                
                if not bv then return end
                
                local velocity = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + (Camera.CFrame.LookVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - (Camera.CFrame.LookVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - (Camera.CFrame.RightVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + (Camera.CFrame.RightVector * Config.FlightSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, Config.FlightSpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    velocity = velocity - Vector3.new(0, Config.FlightSpeed, 0)
                end
                
                bv.Velocity = velocity
            end)
            
            Fluent:Notify({
                Title = "Flight",
                Content = "Flight enabled! Use WASD + Space/Ctrl",
                Duration = 4
            })
        else
            Log("Flight disabled", "info")
            if State.FlightConnection then
                State.FlightConnection:Disconnect()
                State.FlightConnection = nil
            end
            
            local character = GetCharacter(LocalPlayer)
            local rootPart = GetRootPart(character)
            if rootPart then
                local bv = rootPart:FindFirstChild("FlightVelocity")
                if bv then
                    bv:Destroy()
                end
            end
        end
    end
})

local FlightSpeedSlider = Tabs.Player:AddSlider("FlightSpeed", {
    Title = "Flight Speed",
    Description = "How fast you fly",
    Default = 50,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Config.FlightSpeed = Value
    end
})

local NoClipToggle = Tabs.Player:AddToggle("NoClip", {
    Title = "NoClip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(Value)
        Config.NoClip = Value
        
        if Value then
            Log("NoClip enabled", "success")
            if State.NoClipConnection then
                State.NoClipConnection:Disconnect()
            end
            
            State.NoClipConnection = RunService.Stepped:Connect(function()
                if not Config.NoClip then return end
                
                local character = GetCharacter(LocalPlayer)
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            Log("NoClip disabled", "info")
            if State.NoClipConnection then
                State.NoClipConnection:Disconnect()
                State.NoClipConnection = nil
            end
            
            local character = GetCharacter(LocalPlayer)
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

local InfiniteJumpToggle = Tabs.Player:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = "Jump infinitely in the air",
    Default = false,
    Callback = function(Value)
        Config.InfiniteJump = Value
        if Value then
            Log("Infinite Jump enabled", "success")
        else
            Log("Infinite Jump disabled", "info")
        end
    end
})

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local character = GetCharacter(LocalPlayer)
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Tabs.Player:AddParagraph({
    Title = "💪 Character",
    Content = "Character modifications"
})

local GodModeToggle = Tabs.Player:AddToggle("GodMode", {
    Title = "God Mode",
    Description = "Constantly regenerate health (client-side)",
    Default = false,
    Callback = function(Value)
        Config.GodMode = Value
        
        if Value then
            Log("God Mode enabled", "success")
            if State.GodModeConnection then
                State.GodModeConnection:Disconnect()
            end
            
            State.GodModeConnection = RunService.Heartbeat:Connect(function()
                if not Config.GodMode then return end
                
                local character = GetCharacter(LocalPlayer)
                local humanoid = GetHumanoid(character)
                if humanoid and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        else
            Log("God Mode disabled", "info")
            if State.GodModeConnection then
                State.GodModeConnection:Disconnect()
                State.GodModeConnection = nil
            end
        end
    end
})

Tabs.Player:AddButton({
    Title = "Reset Character",
    Description = "Respawn your character",
    Callback = function()
        local character = GetCharacter(LocalPlayer)
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.Health = 0
                Log("Character reset", "info")
            end
        end
    end
})

-- ============================================================
-- VISUAL TAB
-- ============================================================

Tabs.Visual:AddParagraph({
    Title = "👁️ ESP (Extra Sensory Perception)",
    Content = "See players through walls with boxes, names, and health"
})

local ESPToggle = Tabs.Visual:AddToggle("ESP", {
    Title = "Enable ESP",
    Description = "Show ESP for all players",
    Default = false,
    Callback = function(Value)
        Config.ESPEnabled = Value
        
        if Value then
            Log("ESP enabled", "success")
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESP(player)
                end
            end
            
            Fluent:Notify({
                Title = "ESP",
                Content = "ESP enabled!",
                Duration = 3
            })
        else
            Log("ESP disabled", "info")
            for player, _ in pairs(State.ESPObjects) do
                for _, drawing in pairs(State.ESPObjects[player]) do
                    drawing.Visible = false
                end
            end
        end
    end
})

local BoxToggle = Tabs.Visual:AddToggle("ESPBoxes", {
    Title = "Boxes",
    Description = "Show boxes around players",
    Default = true,
    Callback = function(Value)
        Config.ESPBoxes = Value
    end
})

local NameToggle = Tabs.Visual:AddToggle("ESPNames", {
    Title = "Names",
    Description = "Show player names",
    Default = true,
    Callback = function(Value)
        Config.ESPNames = Value
    end
})

local DistanceToggle = Tabs.Visual:AddToggle("ESPDistance", {
    Title = "Distance",
    Description = "Show distance to players",
    Default = true,
    Callback = function(Value)
        Config.ESPDistance = Value
    end
})

local HealthToggle = Tabs.Visual:AddToggle("ESPHealth", {
    Title = "Health Bar",
    Description = "Show player health bars",
    Default = true,
    Callback = function(Value)
        Config.ESPHealth = Value
    end
})

local TracerToggle = Tabs.Visual:AddToggle("ESPTracers", {
    Title = "Tracers",
    Description = "Draw lines to players",
    Default = false,
    Callback = function(Value)
        Config.ESPTracers = Value
    end
})

local ESPTeamCheckToggle = Tabs.Visual:AddToggle("ESPTeamCheck", {
    Title = "ESP Team Check",
    Description = "Don't show ESP for teammates",
    Default = true,
    Callback = function(Value)
        Config.ESPTeamCheck = Value
    end
})

Tabs.Visual:AddParagraph({
    Title = "💡 Lighting",
    Content = "Modify the game's lighting"
})

local FullbrightToggle = Tabs.Visual:AddToggle("Fullbright", {
    Title = "Fullbright",
    Description = "Remove darkness",
    Default = false,
    Callback = function(Value)
        Config.Fullbright = Value
        
        if Value then
            Log("Fullbright enabled", "success")
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Log("Fullbright disabled", "info")
            Lighting.Brightness = State.OriginalLighting.Brightness
            Lighting.ClockTime = State.OriginalLighting.ClockTime
            Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
            Lighting.OutdoorAmbient = State.OriginalLighting.OutdoorAmbient
        end
    end
})

local NoFogToggle = Tabs.Visual:AddToggle("NoFog", {
    Title = "No Fog",
    Description = "Remove fog effects",
    Default = false,
    Callback = function(Value)
        Config.NoFog = Value
        Lighting.FogEnd = Value and 100000 or State.OriginalLighting.FogEnd
        if Value then
            Log("No Fog enabled", "success")
        else
            Log("No Fog disabled", "info")
        end
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================

Tabs.Misc:AddParagraph({
    Title = "🔧 Utility",
    Content = "Useful utilities and functions"
})

Tabs.Misc:AddButton({
    Title = "Rejoin Server",
    Description = "Rejoin the current server",
    Callback = function()
        Log("Rejoining server...", "info")
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.Misc:AddButton({
    Title = "Server Hop",
    Description = "Join a different server",
    Callback = function()
        Log("Attempting to server hop...", "info")
        local success, servers = pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
        end)
        
        if success and servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    Log("Server hop successful", "success")
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        else
            Log("Failed to find servers", "error")
            Fluent:Notify({
                Title = "Server Hop",
                Content = "Failed to find servers",
                Duration = 3
            })
        end
    end
})

Tabs.Misc:AddButton({
    Title = "Copy Game ID",
    Description = "Copy the current game's ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
        Log("Game ID copied: " .. game.PlaceId, "info")
        Fluent:Notify({
            Title = "Copied",
            Content = "Game ID copied to clipboard!",
            Duration = 3
        })
    end
})

Tabs.Misc:AddButton({
    Title = "Copy HWID",
    Description = "Copy your Hardware ID",
    Callback = function()
        setclipboard(GetHWID())
        Log("HWID copied", "info")
        Fluent:Notify({
            Title = "Copied",
            Content = "HWID copied to clipboard!",
            Duration = 3
        })
    end
})

Tabs.Misc:AddParagraph({
    Title = " Key System",
    Content = "Current Session Key: " .. (_G.VoxyHubUserKey or "Unknown")
})

Tabs.Misc:AddButton({
    Title = "Clear Session Key",
    Description = "Clear key from current session (requires re-entry)",
    Callback = function()
        _G.VoxyHubKeyValid = false
        _G.VoxyHubUserKey = nil
        Log("Session key cleared", "info")
        Fluent:Notify({
            Title = "Key Cleared",
            Content = "Session key cleared. Reload script to re-enter.",
            Duration = 4
        })
    end
})

Tabs.Misc:AddParagraph({
    Title = "📊 Information",
    Content = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\nPlayers: " .. #Players:GetPlayers()
})

Tabs.Misc:AddParagraph({
    Title = "ℹ️ Credits",
    Content = "Voxy Hub Universal\nVersion 3.2\n\nMade with ❤️ by Voxy Team\nUI Library: Fluent"
})

Tabs.Misc:AddButton({
    Title = "Join Discord",
    Description = "Copy Discord invite",
    Callback = function()
        setclipboard("https://discord.gg/voxyuhub")
        Fluent:Notify({
            Title = "Discord",
            Content = "Discord invite copied!",
            Duration = 4
        })
    end
})

-- ============================================================
-- SETTINGS TAB
-- ============================================================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("VoxyHub")
SaveManager:SetFolder("VoxyHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

-- ============================================================
-- PLAYER EVENTS
-- ============================================================

Players.PlayerAdded:Connect(function(player)
    if Config.ESPEnabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.1)
    
    local humanoid = GetHumanoid(character)
    if humanoid then
        if Config.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = Config.WalkSpeed
        end
        if Config.JumpPower ~= 50 then
            humanoid.JumpPower = Config.JumpPower
            humanoid.UseJumpPower = true
        end
    end
    
    if Config.Flight then
        task.wait(0.5)
        local rootPart = GetRootPart(character)
        if rootPart and not rootPart:FindFirstChild("FlightVelocity") then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlightVelocity"
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        UpdateESP()
    end
end)

-- ============================================================
-- FINAL NOTIFICATION
-- ============================================================

warn("═══════════════════════════════════════")
warn("  VOXY HUB LOADED SUCCESSFULLY")
warn("  Version: 3.2 (Web Key System)")
warn("  User: " .. LocalPlayer.Name)
warn("  Key Status: Verified ✓")
warn("  HWID: " .. GetHWID())
warn("═══════════════════════════════════════")

Log("All systems operational", "success")
Log("Press Left Ctrl to minimize UI", "info")

Fluent:Notify({
    Title = "Ready!",
    Content = "All features loaded. Press Left Ctrl to minimize. Enjoy!",
    Duration = 5
})
