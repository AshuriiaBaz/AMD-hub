-- AMD Hub - Made by AMD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Création de la fenêtre principale
local Window = Rayfield:CreateWindow({
    Name = "AMD Hub",
    LoadingTitle = "Chargement de AMD Hub",
    LoadingSubtitle = "Made by AMD",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "AMDHubConfig", 
       FileName = "Config"
    },
    Discord = {
       Enabled = false,
    },
    KeySystem = false, 
})

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

----------------------------------------------------
-- Onglet Player
----------------------------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Variables
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 50
local infiniteJump = false
local godMode = false

-- WalkSpeed Slider
PlayerTab:CreateSlider({
   Name = "Vitesse du joueur",
   Range = {16, 200}, 
   Increment = 1,
   Suffix = " WalkSpeed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

-- JumpPower Slider
PlayerTab:CreateSlider({
   Name = "Force de saut",
   Range = {50, 300}, 
   Increment = 5,
   Suffix = " JumpPower",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
   end,
})

-- Noclip Toggle
PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
        noclipEnabled = Value
   end,
})

RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly function
local function Fly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Parent = hrp

    RunService.RenderStepped:Connect(function()
        if not flyEnabled then
            if bv and bv.Parent then
                bv:Destroy()
            end
            return
        end

        local vel = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            vel = vel + (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            vel = vel - (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            vel = vel - (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            vel = vel + (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0,flySpeed,0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel - Vector3.new(0,flySpeed,0)
        end

        bv.Velocity = vel
    end)
end

-- Fly Toggle
PlayerTab:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            Fly()
        end
   end,
})

-- Fly Speed Slider
PlayerTab:CreateSlider({
   Name = "Vitesse du Fly",
   Range = {10, 300}, 
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
        flySpeed = Value
   end,
})

-- Fly Keybind
PlayerTab:CreateKeybind({
    Name = "Fly Keybind",
    CurrentKeybind = "F", 
    HoldToInteract = false,
    Flag = "FlyKeybind",
    Callback = function()
        flyEnabled = not flyEnabled
        if flyEnabled then
            Fly()
        end
    end,
})

-- Infinite Jump Toggle
PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
        infiniteJump = Value
   end,
})

UIS.JumpRequest:Connect(function()
    if infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- GodMode Toggle
PlayerTab:CreateToggle({
   Name = "GodMode",
   CurrentValue = false,
   Flag = "GodModeToggle",
   Callback = function(Value)
        godMode = Value
        if godMode and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = math.huge
            player.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if godMode then
                    player.Character.Humanoid.Health = math.huge
                end
            end)
        end
   end,
})

-- Reset Stats Button
PlayerTab:CreateButton({
   Name = "Reset Stats (Walk/Jump)",
   Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
   end,
})

-- Sit Button
PlayerTab:CreateButton({
   Name = "S'asseoir",
   Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Sit = true
        end
   end,
})

-- Respawn Button
PlayerTab:CreateButton({
   Name = "Respawn",
   Callback = function()
        player:LoadCharacter()
   end,
})

----------------------------------------------------
-- Onglet Teleport
----------------------------------------------------
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- TP vers joueur
local function updatePlayerList()
    local list = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        table.insert(list, plr.Name)
    end
    return list
end

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "TP vers un joueur",
    Options = updatePlayerList(),
    CurrentOption = {},
    Flag = "TPPlayerDropdown",
    Callback = function(Option)
        local target = game.Players:FindFirstChild(Option)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            player.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(2,0,2))
        end
    end,
})

-- Mettre à jour la liste si nouveau joueur rejoint
game.Players.PlayerAdded:Connect(function()
    playerDropdown:Refresh(updatePlayerList())
end)
game.Players.PlayerRemoving:Connect(function()
    playerDropdown:Refresh(updatePlayerList())
end)

-- TP vers coordonnées
TeleportTab:CreateInput({
    Name = "Coordonnées (X,Y,Z)",
    PlaceholderText = "ex: 0,50,0",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local coords = string.split(Text, ",")
        if #coords == 3 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
            if x and y and z then
                player.Character:MoveTo(Vector3.new(x,y,z))
            end
        end
    end,
})

-- Waypoints
local waypoints = {}

TeleportTab:CreateButton({
    Name = "Sauvegarder position",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(waypoints, player.Character.HumanoidRootPart.Position)
            Rayfield:Notify({
                Title = "Waypoint ajouté",
                Content = "Ta position a été sauvegardée ("..tostring(#waypoints)..")",
                Duration = 3
            })
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP au dernier Waypoint",
    Callback = function()
        if #waypoints > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character:MoveTo(waypoints[#waypoints])
        else
            Rayfield:Notify({
                Title = "Erreur",
                Content = "Aucun waypoint sauvegardé",
                Duration = 3
            })
        end
    end,
})

-- FullBright
local fullBrightEnabled = false
TeleportTab:CreateToggle({
   Name = "FullBright",
   CurrentValue = false,
   Flag = "FullBrightToggle",
   Callback = function(Value)
        fullBrightEnabled = Value
        if Value then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 1e5
            game.Lighting.GlobalShadows = false
        else
            game.Lighting.GlobalShadows = true
        end
   end,
})

-- NoFog
TeleportTab:CreateToggle({
   Name = "NoFog",
   CurrentValue = false,
   Flag = "NoFogToggle",
   Callback = function(Value)
        if Value then
            game.Lighting.FogEnd = 1e5
        else
            game.Lighting.FogEnd = 1000
        end
   end,
})
