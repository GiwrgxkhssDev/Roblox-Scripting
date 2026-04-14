local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GIWRGXKHSSDEV | Emergency Hamburg",
   LoadingTitle = "GIWRGXKHSSDEV Interface Suite",
   LoadingSubtitle = "by giwrgxkhssdev",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GIWRGXKHSSDEV"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

--// Random Stuff
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/flerci42/ESP/main/.lua'))()
local player = game.Players.LocalPlayer
local minHealth = 1
local choosenWeapon

-- Create locator parts for buildings
local JewelryPart = Instance.new("Part")
JewelryPart.Parent = game:GetService("Workspace").Buildings.Jeweler
JewelryPart.Name = "JewelryLocator"
JewelryPart.Anchored = true
JewelryPart.CanCollide = false
JewelryPart.Transparency = 1
JewelryPart.CFrame = CFrame.new(-394.5513, 5.52547216, 3568.09302)

local bankPart = Instance.new("Part")
bankPart.Parent = game:GetService("Workspace").Buildings.Bank
bankPart.Name = "BankLocator"
bankPart.Anchored = true
bankPart.CanCollide = false   
bankPart.Transparency = 1
bankPart.CFrame = CFrame.new(-1167.87585, 7.87799263, 3161.57544)

local gasStation1Part = Instance.new("Part")
gasStation1Part.Parent = game:GetService("Workspace").Buildings["GasStation-GasNGo"]
gasStation1Part.Name = "gasStationLocator"
gasStation1Part.Anchored = true
gasStation1Part.CanCollide = false
gasStation1Part.Transparency = 1
gasStation1Part.CFrame = CFrame.new(-1531.9585, 5.74999857, 3769.5564)

local gasStation2Part = Instance.new("Part")
gasStation2Part.Parent = game:GetService("Workspace").Buildings["GasStation-Ares"]
gasStation2Part.Name = "gasStationLocator"
gasStation2Part.Anchored = true
gasStation2Part.CanCollide = false
gasStation2Part.Transparency = 1
gasStation2Part.CFrame = CFrame.new(-867.554138, 5.04301023, 1543.24878)

local toolShopPart = Instance.new("Part")
toolShopPart.Parent = game:GetService("Workspace").Buildings.ToolShop
toolShopPart.Name = "toolShopLocator"
toolShopPart.Anchored = true
toolShopPart.CanCollide = false
toolShopPart.Transparency = 1
toolShopPart.CFrame = CFrame.new(-746.765015, 5.51895142, 636.716064)

--// Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483345875)
local VehicleTab = Window:CreateTab("Vehicle", 4483362748)
local WeaponTab = Window:CreateTab("Weapons", 4483345737)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

Rayfield:Notify({
   Title = "Important Notification",
   Content = "This script is new and may contain bugs. Please report any issues to our Discord server.",
   Duration = 6.5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("Notification dismissed")
         end
      },
   },
})

--// Main Tab

local PlayerInfoSection = MainTab:CreateSection("Player Information")

MainTab:CreateParagraph({
   Title = "Player Information", 
   Content = "Username: "..player.Name.. 
   "\nDisplay Name: "..player.DisplayName..
   "\nPlayer Id: "..player.UserId
})

local GameInfoSection = MainTab:CreateSection("Game Information")

MainTab:CreateParagraph({
   Title = "Game Information", 
   Content = "Game Name: Emergency Hamburg"..
   "\nGame Id: "..game.GameId
})

--// Player Tab

local PlayerSection = PlayerTab:CreateSection("Player Options")

local EscapeSection = PlayerTab:CreateSection("Escape Jail")

MainTab:CreateLabel("By clicking the button your character will reset, meaning you will lose your items.")
MainTab:CreateLabel("Make sure to click this when you are in jail!")

local EscapeButton = PlayerTab:CreateButton({
   Name = "Escape Jail",
   Callback = function()
      game:GetService("Players").LocalPlayer.Character.Head:Destroy()
      Rayfield:Notify({
         Title = "Escape",
         Content = "Character reset to escape jail!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local AutoEatSection = PlayerTab:CreateSection("Auto Eat")

PlayerTab:CreateLabel("By enabling this toggle, you will automatically eat a cookie when low on health.")

local MinHealthSlider = PlayerTab:CreateSlider({
   Name = "Minimum Health",
   Range = {1, 100},
   Increment = 1,
   Suffix = "HP",
   CurrentValue = 50,
   Flag = "MinHealthSlider",
   Callback = function(Value)
      minHealth = Value
   end,
})

local AutoEatToggle = PlayerTab:CreateToggle({
   Name = "Auto Eat",
   CurrentValue = false,
   Flag = "AutoEatToggle",
   Callback = function(Value)
      getgenv().autoEat = Value
      while true do
         if not getgenv().autoEat then return end
         local LPH = game:GetService("Players").LocalPlayer.Character.Humanoid.Health

         if LPH < minHealth then
            print("Health is under "..minHealth)
            local args = {
               [1] = "Cookie"
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("events-vqp"):WaitForChild("4faf9ae9-9bd7-476f-8c36-9a3965c2f9dc"):FireServer(unpack(args))
            wait(0.8)
            local args = {
               [1] = game:GetService("Players").LocalPlayer.Character.Cookie
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("events-vqp"):WaitForChild("c8bc12bd-7a75-40f8-8b12-988efcb4b124"):FireServer(unpack(args))
            wait(3)
         else
            print("Health is safe.")
         end
         task.wait()
      end
   end,
})

local OtherSection = PlayerTab:CreateSection("Other Options")

local GodModeToggle = PlayerTab:CreateToggle({
   Name = "God Mode",
   CurrentValue = false,
   Flag = "GodModeToggle",
   Callback = function(Value)
      getgenv().godMode = Value
      while true do
         if not getgenv().godMode then return end
         game.Players.LocalPlayer.Character.Humanoid.Health = 100
         task.wait()
      end
   end,
})

-- // Vehicle Tab

local VehicleSection = VehicleTab:CreateSection("Vehicle Modifications")

local CarGodModeToggle = VehicleTab:CreateToggle({
   Name = "Car God Mode / Inf Fuel",
   CurrentValue = false,
   Flag = "CarGodModeToggle",
   Callback = function(Value)
      getgenv().carGodMode = Value
      if getgenv().carGodMode == true then
         workspace.Vehicles[player.Name]:SetAttribute("IsOn", Value)
      else
         workspace.Vehicles[player.Name]:SetAttribute("IsOn", Value)
      end
   end,
})

local TowableToggle = VehicleTab:CreateToggle({
   Name = "Towable",
   CurrentValue = true,
   Flag = "TowableToggle",
   Callback = function(Value)
      workspace.Vehicles[player.Name]:SetAttribute("Towable", Value)
   end,
})

local MaxSpeedSlider = VehicleTab:CreateSlider({
   Name = "Max Speed",
   Range = {1, 400},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "MaxSpeedSlider",
   Callback = function(Value)
      workspace.Vehicles[player.Name]:SetAttribute("MaxSpeed", Value)
   end,
})

local ReverseMaxSpeedSlider = VehicleTab:CreateSlider({
   Name = "Reverse Max Speed",
   Range = {1, 400},
   Increment = 1,
   Suffix = "",
   CurrentValue = 50,
   Flag = "ReverseMaxSpeedSlider",
   Callback = function(Value)
      workspace.Vehicles[player.Name]:SetAttribute("ReverseMaxSpeed", Value)
   end,
})

local AccelerateForceSlider = VehicleTab:CreateSlider({
   Name = "Accelerate Force",
   Range = {1, 1000},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "AccelerateForceSlider",
   Callback = function(Value)
      workspace.Vehicles[player.Name]:SetAttribute("MaxAccelerateForce", Value)
      workspace.Vehicles[player.Name]:SetAttribute("MinAccelerateForce", Value)
   end,
})

local BrakeForceSlider = VehicleTab:CreateSlider({
   Name = "Brake Force",
   Range = {1, 1000},
   Increment = 1,
   Suffix = "",
   CurrentValue = 100,
   Flag = "BrakeForceSlider",
   Callback = function(Value)
      workspace.Vehicles[player.Name]:SetAttribute("MaxBrakeForce", Value)
      workspace.Vehicles[player.Name]:SetAttribute("MinBrakeForce", Value)
   end,
})

local CarColorPicker = VehicleTab:CreateColorPicker({
   Name = "Car Color",
   Color = Color3.fromRGB(255,255,255),
   Flag = "CarColorPicker",
   Callback = function(Value)
      game:GetService("Workspace").Vehicles[""..player.Name].Body.Body.Color = Value
   end
})

-- // Weapon Tab

local WeaponSection = WeaponTab:CreateSection("Weapon Modification")

WeaponTab:CreateLabel("Make sure you are holding the gun you want to modify!")

local AimDelaySlider = WeaponTab:CreateSlider({
   Name = "Aim Delay",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "AimDelaySlider",
   Callback = function(Value)
      for i,v in next, game.Workspace[player.Name]:GetChildren() do
         if v:IsA("Tool") then
            v:SetAttribute("AimDelay", Value)
         else
            print("ADMINUS - You aren't holding a weapon!")
         end
      end
   end,
})

local AimFOVSlider = WeaponTab:CreateSlider({
   Name = "Aim FOV",
   Range = {50, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "AimFOVSlider",
   Callback = function(Value)
      for i,v in next, game.Workspace[player.Name]:GetChildren() do
         if v:IsA("Tool") then
            v:SetAttribute("AimFieldOfView", Value)
         else
            print("ADMINUS - You aren't holding a weapon!")
         end
      end
   end,
})

local MagSizeSlider = WeaponTab:CreateSlider({
   Name = "Mag Size",
   Range = {17, 999},
   Increment = 1,
   Suffix = " rounds",
   CurrentValue = 17,
   Flag = "MagSizeSlider",
   Callback = function(Value)
      for i,v in next, game.Workspace[player.Name]:GetChildren() do
         if v:IsA("Tool") then
            v:SetAttribute("MagMaxSize", Value)
            v:SetAttribute("MagCurrentSize", Value)
         else
            print("ADMINUS - You aren't holding a weapon!")
         end
      end
   end,
})

local ReloadTimeSlider = WeaponTab:CreateSlider({
   Name = "Reload Time",
   Range = {0, 3},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 2.3,
   Flag = "ReloadTimeSlider",
   Callback = function(Value)
      for i,v in next, game.Workspace[player.Name]:GetChildren() do
         if v:IsA("Tool") then
            v:SetAttribute("ReloadTime", Value)
         else
            print("ADMINUS - You aren't holding a weapon!")
         end
      end
   end,
})

local ShootDelaySlider = WeaponTab:CreateSlider({
   Name = "Shoot Delay",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "ShootDelaySlider",
   Callback = function(Value)
      for i,v in next, game.Workspace[player.Name]:GetChildren() do
         if v:IsA("Tool") then
            v:SetAttribute("ShootDelay", Value)
         else
            print("ADMINUS - You aren't holding a weapon!")
         end
      end
   end,
})

-- // Visuals Tab

local PlayerVisualsSection = VisualsTab:CreateSection("Player Visuals")

local ESPToggle = VisualsTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.enabled = Value
      ESP.teamSettings.friendly.enabled = Value
   end,
})

local BoxToggle = VisualsTab:CreateToggle({
   Name = "Box",
   CurrentValue = false,
   Flag = "BoxToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.box = Value
      ESP.teamSettings.friendly.box = Value
      ESP.teamSettings.enemy.boxColor = { "Team Color", 1 }
      ESP.teamSettings.friendly.boxColor = { "Team Color", 1 }
   end,
})

local Box3DToggle = VisualsTab:CreateToggle({
   Name = "Box 3D",
   CurrentValue = false,
   Flag = "Box3DToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.box3d = Value
      ESP.teamSettings.friendly.box3d = Value
      ESP.teamSettings.enemy.box3dColor = { "Team Color", 1 }
      ESP.teamSettings.friendly.box3dColor = { "Team Color", 1 }
   end,
})

local HealthBarToggle = VisualsTab:CreateToggle({
   Name = "Health Bar",
   CurrentValue = false,
   Flag = "HealthBarToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.healthBar = Value
      ESP.teamSettings.friendly.healthBar = Value
   end,
})

local HealthTextToggle = VisualsTab:CreateToggle({
   Name = "Health Text",
   CurrentValue = false,
   Flag = "HealthTextToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.healthText = Value
      ESP.teamSettings.friendly.healthText = Value
   end,
})

local NameTextToggle = VisualsTab:CreateToggle({
   Name = "Name Text",
   CurrentValue = false,
   Flag = "NameTextToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.name = Value
      ESP.teamSettings.friendly.name = Value
   end,
})

local WeaponTextToggle = VisualsTab:CreateToggle({
   Name = "Weapon Text",
   CurrentValue = false,
   Flag = "WeaponTextToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.weapon = Value
      ESP.teamSettings.friendly.weapon = Value
   end,
})

local DistanceTextToggle = VisualsTab:CreateToggle({
   Name = "Distance Text",
   CurrentValue = false,
   Flag = "DistanceTextToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.distance = Value
      ESP.teamSettings.friendly.distance = Value
   end,
})

local TracerToggle = VisualsTab:CreateToggle({
   Name = "Tracer",
   CurrentValue = false,
   Flag = "TracerToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.tracer = Value
      ESP.teamSettings.friendly.tracer = Value
      ESP.teamSettings.enemy.tracerColor = { "Team Color", 1 }
      ESP.teamSettings.friendly.tracerColor = { "Team Color", 1 }
   end,
})

local ChamsToggle = VisualsTab:CreateToggle({
   Name = "Chams",
   CurrentValue = false,
   Flag = "ChamsToggle",
   Callback = function(Value)
      ESP.teamSettings.enemy.chams = Value
      ESP.teamSettings.friendly.chams = Value
      ESP.teamSettings.enemy.chamsFillColor  = { "Team Color", 0.5 }
      ESP.teamSettings.friendly.chamsFillColor = { "Team Color", 0.5 }
      ESP.teamSettings.enemy.chamsOutlineColor = { "Team Color", 0 }
      ESP.teamSettings.friendly.chamsOutlineColor = { "Team Color", 0 }
   end,
})

local BuildingVisualsSection = VisualsTab:CreateSection("Building Visuals")

local BankToggle = VisualsTab:CreateToggle({
   Name = "Bank",
   CurrentValue = false,
   Flag = "BankToggle",
   Callback = function(Value)
      local object = ESP.AddInstance(game:GetService("Workspace").Buildings.Bank.BankLocator, {
         text = "Bank",
         textColor = { Color3.new(1,1,1), 1 },
         textOutline = true,
         textOutlineColor = Color3.new(),
         textSize = 20,
         textFont = 2,
         limitDistance = false,
         maxDistance = 150
      })
      object.options.enabled = Value
   end,
})

local JewelryToggle = VisualsTab:CreateToggle({
   Name = "Jewelry",
   CurrentValue = false,
   Flag = "JewelryToggle",
   Callback = function(Value)
      local object = ESP.AddInstance(game:GetService("Workspace").Buildings.Jeweler.JewelryLocator, {
         text = "Jewelry",
         textColor = { Color3.new(1,1,1), 1 },
         textOutline = true,
         textOutlineColor = Color3.new(),
         textSize = 20,
         textFont = 2,
         limitDistance = false,
         maxDistance = 150
      })
      object.options.enabled = Value
   end,
})

local GasStationToggle = VisualsTab:CreateToggle({
   Name = "Gas Station",
   CurrentValue = false,
   Flag = "GasStationToggle",
   Callback = function(Value)
      local object = ESP.AddInstance(game:GetService("Workspace").Buildings["GasStation-Ares"].gasStationLocator, {
         text = "Gas Station",
         textColor = { Color3.new(1,1,1), 1 },
         textOutline = true,
         textOutlineColor = Color3.new(),
         textSize = 20,
         textFont = 2,
         limitDistance = false,
         maxDistance = 150
      })
      local object2 = ESP.AddInstance(game:GetService("Workspace").Buildings["GasStation-GasNGo"].gasStationLocator, {
         text = "Gas Station",
         textColor = { Color3.new(1,1,1), 1 },
         textOutline = true,
         textOutlineColor = Color3.new(),
         textSize = 20,
         textFont = 2,
         limitDistance = false,
         maxDistance = 150
      })
      object.options.enabled = Value
      object2.options.enabled = Value
   end,
})

local ToolShopToggle = VisualsTab:CreateToggle({
   Name = "Tool Shop",
   CurrentValue = false,
   Flag = "ToolShopToggle",
   Callback = function(Value)
      local object = ESP.AddInstance(game:GetService("Workspace").Buildings.ToolShop.toolShopLocator, {
         text = "Tool Shop",
         textColor = { Color3.new(1,1,1), 1 },
         textOutline = true,
         textOutlineColor = Color3.new(),
         textSize = 20,
         textFont = 2,
         limitDistance = false,
         maxDistance = 150
      })
      object.options.enabled = Value
   end,
})

ESP.Load()

-- // Settings Tab

local SettingsSection = SettingsTab:CreateSection("Settings")

local CloseButton = SettingsTab:CreateButton({
   Name = "Close Adminus",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
