-- Script Teleporter Script Made By GiwrgxkhssDev ! Please Dont Delete Anything From Here!
-- Just Create Part Called Teleporter and Destination Part
-- Paste The Script On The Part ( Teleporter ) The Script After Line 22

local teleporters = workspace:WaitForChild("Teleporters")

for _, teleporter in pairs(teleporters:GetChildren()) do
	if teleporter:IsA("BasePart") and teleporter.Name:find("Teleporter") then
		local num = string.match(teleporter.Name, "%d+")
		local destination = teleporters:FindFirstChild("Destination"..num)

        if destination then
           teleporter.Touched:Connect(function(hit)
				local character = hit.Parent
				local player = game.Players:GetPlayerFromCharacter(character)
                if player and character:FindFirstChild("HumanoidRootPart") then
					character.HumanoidRootPart.CFrame = destination.CFrame + Vector3.new(0, 3, 0)
				end
			end)
		end
	end
end

-- Paste The Script On The Teleporter Part

local teleporter = script.Parent
local destination = workspace:WaitForChild("DestinationPart")

teleporter.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if player and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = destination.CFrame + Vector3.new(0, 3, 0)
	end
end)
