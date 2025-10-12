local scripts = {
    "https://api.luarmor.net/files/v4/loaders/44412f0de7749c2587f1bd6a92a88243.lua",
    "https://raw.githubusercontent.com/CodeE4X-dev/Open-Source/refs/heads/main/Blade-Ball/BETA",
    "https://raw.githubusercontent.com/AL-Helper/Helper/refs/heads/main/SmartEnousgh"
}

local restricted_scripts = {
    "https://raw.githubusercontent.com/NodeX-Enc/NodeX/refs/heads/main/YesThisIsOpenSource.lua",
    "https://api.luarmor.net/files/v4/loaders/44412f0de7749c2587f1bd6a92a88243.lua"
}

local restricted_placeIds = {16581637217, 92458008626219}

local script_to_execute = nil
local is_restricted_place = false

for _, placeId in ipairs(restricted_placeIds) do
    if game.PlaceId == placeId then
        is_restricted_place = true
        break
    end
end

if is_restricted_place then
    script_to_execute = restricted_scripts
else
    script_to_execute = scripts
end

for _, script_url in ipairs(script_to_execute) do
    task.spawn(function()
        local success, content = pcall(function()
            return game:HttpGet(script_url)
        end)

        if success and content then
            pcall(function()
                loadstring(content)()
            end)
        end
    end)
end
