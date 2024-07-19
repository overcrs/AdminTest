local Players = game:GetService("Players")
local GroupID = 1252054

-- Define group ranks
local OwnerRank = 255
local AdminRank = 253
local ModeratorRank = 252

-- Function to get player rank
local function getPlayerRank(player)
	local success, rank = pcall(function()
		return player:GetRankInGroup(GroupID)
	end)
	return success and rank or 0
end

-- Function to handle commands
local function handleCommand(player, command, ...)
	local rank = getPlayerRank(player)

	if command == "kick" then
		if rank >= ModeratorRank then
			local targetName = ...
			local target = Players:FindFirstChild(targetName)
			if target then
				target:Kick("You have been kicked by " .. player.Name)
				print("Kicked " .. targetName .. " by " .. player.Name)
			else
				print("Player not found.")
			end
		else
			print("You do not have permission to kick players.")
		end
	elseif command == "ban" then
		if rank >= AdminRank then
			local targetName = ...
			local target = Players:FindFirstChild(targetName)
			if target then
				-- Implement banning logic here
				print("Banned " .. targetName .. " by " .. player.Name)
			else
				print("Player not found.")
			end
		else
			print("You do not have permission to ban players.")
		end
	elseif command == "unban" then
		if rank >= AdminRank then
			local targetName = ...
			-- Implement unbanning logic here
			print("Unbanned " .. targetName .. " by " .. player.Name)
		else
			print("You do not have permission to unban players.")
		end
	elseif command == "tp" then
		if rank >= ModeratorRank then
			local fromName, toName = ...
			local fromPlayer = Players:FindFirstChild(fromName)
			local toPlayer = Players:FindFirstChild(toName)
			if fromPlayer and toPlayer then
				fromPlayer.Character.HumanoidRootPart.CFrame = toPlayer.Character.HumanoidRootPart.CFrame
				print("Teleported " .. fromName .. " to " .. toName)
			else
				print("One or both players not found.")
			end
		else
			print("You do not have permission to teleport players.")
		end
	else
		print("Unknown command.")
	end
end

-- Command handler example
local function onPlayerChatted(player, message)
	local args = string.split(message, " ")
	local command = args[1]:lower()
	table.remove(args, 1)
	handleCommand(player, command, unpack(args))
end

-- Connect player chat event
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		onPlayerChatted(player, message)
	end)
end)
