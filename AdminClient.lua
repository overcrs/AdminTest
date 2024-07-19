local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local function onPlayerChatted(player, message)
    -- Insert client-side logic here if needed
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if message:sub(1, 1) == ";" then
            onPlayerChatted(player, message:sub(2))
        end
    end)
end)
