local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local BanDataStore = DataStoreService:GetDataStore("BanList")

local GroupID = 1252054
local OwnerRank = 255
local AdminRank = 253
local ModeratorRank = 252

local MainOwnerUserID = 65687769

local function isOwner(player)
    return player.UserId == MainOwnerUserID or player:GetRankInGroup(GroupID) == OwnerRank
end

local function isAdmin(player)
    return player:GetRankInGroup(GroupID) == AdminRank or isOwner(player)
end

local function isModerator(player)
    return player:GetRankInGroup(GroupID) == ModeratorRank or isAdmin(player)
end

local function isBanned(userId)
    local success, isBanned = pcall(function()
        return BanDataStore:GetAsync(tostring(userId))
    end)
    if success then
        return isBanned
    else
        warn("Failed to access BanDataStore")
        return false
    end
end

local function banPlayer(userId)
    local success, result = pcall(function()
        BanDataStore:SetAsync(tostring(userId), true)
    end)
    if not success then
        warn("Failed to ban player: " .. result)
    end
end

local function unbanPlayer(userId)
    local success, result = pcall(function()
        BanDataStore:RemoveAsync(tostring(userId))
    end)
    if not success then
        warn("Failed to unban player: " .. result)
    end
end

local function findPlayerByName(partialName)
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name):sub(1, #partialName) == string.lower(partialName) then
            return player
        end
    end
    return nil
end

local function handleCommand(player, message)
    if string.sub(message, 1, 1) ~= ";" then return end

    local splitMessage = string.split(string.sub(message, 2), " ")
    local command = splitMessage[1]
    local targetName = splitMessage[2]
    local targetPlayer = findPlayerByName(targetName) or Players:GetPlayerByUserId(tonumber(targetName))

    if command == "kick" and isModerator(player) and targetPlayer then
        targetPlayer:Kick("You have been kicked from the server.")
    elseif command == "ban" and isAdmin(player) and targetPlayer then
        banPlayer(targetPlayer.UserId)
        targetPlayer:Kick("You have been banned from the server.")
    elseif command == "unban" and isAdmin(player) then
        local userId = tonumber(targetName) or Players:GetUserIdFromNameAsync(targetName)
        if userId then
            unbanPlayer(userId)
        end
    elseif command == "tp" and isModerator(player) and splitMessage[3] then
        local targetPlayer2 = findPlayerByName(splitMessage[3]) or Players:GetPlayerByUserId(tonumber(splitMessage[3]))
        if targetPlayer and targetPlayer2 then
            targetPlayer.Character:SetPrimaryPartCFrame(targetPlayer2.Character:GetPrimaryPartCFrame())
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if isBanned(player.UserId) then
        player:Kick("You are banned from this server.")
    end
    player.Chatted:Connect(function(message)
        handleCommand(player, message)
    end)
end)
