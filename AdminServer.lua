local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local BansDataStore = DataStoreService:GetDataStore("BansDataStore")

local GroupID = 1252054
local OwnerRank = 255
local AdminRank = 253
local ModeratorRank = 252

-- Check if a player has the required rank
local function hasPermission(player, requiredRank)
	local rank = player:GetRankInGroup(GroupID)
	return rank >= requiredRank
end

-- Fetch the player by username or user ID
local function getPlayerByNameOrID(identifier, requestingPlayer)
	if identifier:lower() == "me" then
		return requestingPlayer
	end

	for _, player in pairs(Players:GetPlayers()) do
		if tonumber(identifier) then
			if player.UserId == tonumber(identifier) then
				return player
			end
		else
			if player.Name:lower():find(identifier:lower()) or player.DisplayName:lower():find(identifier:lower()) then
				return player
			end
		end
	end
	return nil
end

-- Ban and unban functions
local function banPlayer(userId)
	local success, err = pcall(function()
		BansDataStore:SetAsync(tostring(userId), true)
	end)
	if not success then
		warn("Failed to ban player: " .. err)
	end
end

local function unbanPlayer(userId)
	local success, err = pcall(function()
		BansDataStore:RemoveAsync(tostring(userId))
	end)
	if not success then
		warn("Failed to unban player: " .. err)
	end
end

local function isPlayerBanned(userId)
	local success, result = pcall(function()
		return BansDataStore:GetAsync(tostring(userId))
	end)
	if success then
		return result == true
	else
		warn("Failed to check if player is banned: " .. result)
		return false
	end
end

-- Commands
local commands = {
	["kick"] = function(sender, target)
		if not hasPermission(sender, ModeratorRank) then
			return
		end
		local targetPlayer = getPlayerByNameOrID(target, sender)
		if targetPlayer then
			targetPlayer:Kick("You have been kicked from the game.")
		end
	end,

	["ban"] = function(sender, target)
		if not hasPermission(sender, AdminRank) then
			return
		end
		local targetPlayer = getPlayerByNameOrID(target, sender)
		if targetPlayer then
			banPlayer(targetPlayer.UserId)
			targetPlayer:Kick("You have been banned from the game.")
		end
	end,

	["unban"] = function(sender, target)
		if not hasPermission(sender, AdminRank) then
			return
		end
		local userId = tonumber(target)
		if userId then
			unbanPlayer(userId)
		end
	end,

	["tp"] = function(sender, target1, target2)
		if not hasPermission(sender, ModeratorRank) then
			return
		end
		local targetPlayer1 = getPlayerByNameOrID(target1, sender)
		local targetPlayer2 = getPlayerByNameOrID(target2, sender)
		if targetPlayer1 and targetPlayer2 then
			targetPlayer1.Character:SetPrimaryPartCFrame(targetPlayer2.Character.PrimaryPart.CFrame)
		end
	end,
}

-- Player added handler to check if banned
Players.PlayerAdded:Connect(function(player)
	if isPlayerBanned(player.UserId) then
		player:Kick("You are banned from this game.")
	end

	player.Chatted:Connect(function(msg)
		if msg:sub(1, 1) == ";" then
			local args = msg:sub(2):split(" ")
			local cmd = args[1]
			table.remove(args, 1)

			if commands[cmd] then
				commands[cmd](player, unpack(args))
			end
		end
	end)
end)
