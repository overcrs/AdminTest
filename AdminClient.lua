local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- URL to the server-side script in your GitHub repository
local serverScriptUrl = "https://raw.githubusercontent.com/yourusername/yourrepo/main/AdminScript212.lua"

-- Function to fetch the script content from GitHub
local function fetchScript(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        return result
    else
        warn("Failed to fetch script: " .. result)
        return nil
    end
end

-- Fetch and load the server-side script
local serverScriptContent = fetchScript(serverScriptUrl)
if serverScriptContent then
    local func, err = loadstring(serverScriptContent)
    if func then
        func()
    else
        warn("Failed to load script: " .. err)
    end
end
