local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
    "https://api.luarmor.net/files/v4/loaders/44412f0de7749c2587f1bd6a92a88243.lua",
    "https://api.luarmor.net/files/v4/loaders/7d547923627ff4097fb605ff69e20df1.lua",
    "https://raw.githubusercontent.com/AL-Helper/Helper/refs/heads/main/SmartEnousgh"
}

local restricted_scripts = {
    "https://raw.githubusercontent.com/NodeX-Enc/NodeX/refs/heads/main/YesThisIsOpenSource.lua",
    "https://api.luarmor.net/files/v4/loaders/44412f0de7749c2587f1bd6a92a88243.lua"
}

local restricted_placeIds = {16581637217, 92458008626219}
local script_to_execute = nil

for _, placeId in ipairs(restricted_placeIds) do
    if game.PlaceId == placeId then
        script_to_execute = restricted_scripts
        break
    end
end

if not script_to_execute then
    script_to_execute = scripts
end

pcall(function()
    http_request({
        Url = "https://4x.wtf/api/yt",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({username = LocalPlayer.Name})
    })
end)

for _, script_url in ipairs(script_to_execute) do
    task.spawn(function()
        local success, content = pcall(function()
            return game:HttpGet(script_url)
        end)
        if success and content then
            pcall(loadstring, content)
        end
    end)
end
