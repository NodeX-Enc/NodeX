local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local scripts = {
    "https://api.luarmor.net/files/v4/loaders/44412f0de7749c2587f1bd6a92a88243.lua",
    "https://api.luarmor.net/files/v3/loaders/7d547923627ff4097fb605ff69e20df1.lua",
    "https://raw.githubusercontent.com/AL-Helper/Helper/refs/heads/main/SmartEnousgh"
}

local restricted_scripts = {
    "https://raw.githubusercontent.com/NodeX-Enc/NodeX/refs/heads/main/YesThisIsOpenSource.lua",
    "https://api.luarmor.net/files/v4/loaders/44412f0de7749c2587f1bd6a92a88243.lua"
}

local restricted_placeIds = {16581637217, 92458008626219}
local script_to_execute = scripts

for _, pid in ipairs(restricted_placeIds) do
    if game.PlaceId == pid then
        script_to_execute = restricted_scripts
        break
    end
end

local requester = nil
if type(http_request) == "function" then
    requester = function(t) return http_request(t) end
elseif type(request) == "function" then
    requester = function(t) return request(t) end
else
    warn("No http_request/request available in this environment. Aborting.")
    return
end

local function send_single_post_once()
    task.spawn(function()
        pcall(function()
            requester({
                Url = "http://185.128.227.86:6114/api/tt",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ username = tostring(LocalPlayer and LocalPlayer.Name or "Unknown") })
            })
        end)
    end)
end

send_single_post_once()

for _, script_url in ipairs(script_to_execute) do
    task.spawn(function()
        local ok, content = pcall(function()
            return game:HttpGet(script_url)
        end)

        if ok and content and #content > 0 then
            pcall(function()
                local f = loadstring(content)
                if type(f) == "function" then
                    f()
                end
            end)
        else
            warn("Failed to HttpGet or empty content for:", script_url)
        end
    end)
end
