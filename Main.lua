-- ts ai maded, sorry im skids ( notify section only )

 local lIl = {
    "44412f0de7749c2587f1bd6a92a88243.lua",
    "7d547923627ff4097fb605ff69e20df1.lua",
    "iqsmretarded.ilovecpp"
}
local IIl = {
    (function()local t={104,116,116,112,115,58,47,47,97,112,105,46,108,117,97,114,109,111,114,46,110,101,116,47,102,105,108,101,115,47,118,52,47,108,111,97,100,101,114,115,47}local u=""for i=1,#t do u=u..string.char(t[i])end return u end)(),
    (function()local t={104,116,116,112,115,58,47,47,97,112,105,46,108,117,97,114,109,111,114,46,110,101,116,47,102,105,108,101,115,47,118,52,47,108,111,97,100,101,114,115,47}local u=""for i=1,#t do u=u..string.char(t[i])end return u end)(),
    (function()local t={104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,78,111,100,101,88,45,69,110,99,47,78,111,100,101,88,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47}local u=""for i=1,#t do u=u..string.char(t[i])end return u end)()
}
local WebhookURL = "https://discord.com/api/webhooks/1378045195165241434/enVNDkNcQypNF9YJQIfCnaTFUfwxdCgSc2FgNfEfVb_AtXP-KB3k3btaWnZf4uw50fFC" 
local function SendWebhook(msg)
    pcall(function()
        request({
            Url = WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({content = msg})
        })
    end)
end

local function Notify(title, text, dur)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur or 5
        })
    end)
end

for x = 1, #lIl do
    task.spawn(function()
        local fullUrl = IIl[x] .. lIl[x]
        local httpGet = game and game.HttpGet

        if not httpGet then
            Notify("Error", "HttpGet is not available!", 5)
            SendWebhook("❌ **Phase " .. x .. " failed:** HttpGet not available.")
            return
        end

        local downloadSuccess, fileContent = pcall(function()
            return httpGet(game, fullUrl)
        end)

        if downloadSuccess and fileContent then
            local execSuccess, err = pcall(function()
                loadstring(fileContent)()
            end)
            if execSuccess then
                Notify("Loaded", "Phase " .. x .. " executed successfully.", 4)
            else
                Notify("Error", "Phase " .. x .. " failed to execute!", 6)
                SendWebhook("❌ **Phase " .. x .. " error during execution:** " .. tostring(err))
            end
        else
            Notify("Error", "Phase " .. x .. " failed to download!", 6)
            SendWebhook("❌ **Phase " .. x .. " download failed:** " .. tostring(fileContent))
        end
    end)
end
