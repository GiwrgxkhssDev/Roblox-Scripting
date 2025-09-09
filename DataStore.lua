-- Data Save Script Made By GiwrgxkhssDev ! Please Dont Delete Anything From Here!

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local playerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local defaultData = {
    coins = 0
}

local function loadData(player)
    local success, data = pcall(function()
        return playerDataStore:GetAsync(player.UserId)
    end)
    if success and data then
        return data
    else
        return defaultData
    end
end

local function saveData(player, data)
    pcall(function()
        playerDataStore:SetAsync(player.UserId, data)
    end)
end

Players.PlayerAdded:Connect(function(player)
    local data = loadData(player)
    player:SetAttribute("coins", data.coins)
end)

Players.PlayerRemoving:Connect(function(player)
    local data = {
        coins = player:GetAttribute("coins") or 0
    }
    saveData(player, data)
end)

-- Optional: Save data if server shuts down
game:BindToClose(function()
    local playerList = Players:GetPlayers()
    for i, player in playerList do
        local data = {
            coins = player:GetAttribute("coins") or 0
        }
        saveData(player, data)
    end
end)
