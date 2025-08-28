
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Client = require(ReplicatedStorage.Shared.Inventory.Client)
local Replion = require(ReplicatedStorage.Packages.Replion)
local RAPData = Replion.Client:WaitReplion("ItemRAP")
local InventoryData = Replion.Client:WaitReplion("Inventory")

-- missing something hehe

local CreateListing = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.1.0")
    :WaitForChild("net")
    :WaitForChild("RF/CreatingBoothListing")

local CATEGORIES = { "Sword", "Explosion", "Emote" }
local DEFAULT_DELAY = 0.25

local function UniversalRequest(opts)
    local req = (syn and syn.request) or request or http_request
    if req then
        return req(opts)
    end
    if opts.Method == "POST" then
        local ok, res = pcall(function()
            return { Success = true, StatusCode = 200, Body = game:HttpPost(opts.Url, opts.Body, Enum.HttpContentType.ApplicationJson) }
        end)
        if ok then return res end
    else
        local ok, res = pcall(function()
            return { Success = true, StatusCode = 200, Body = game:HttpGet(opts.Url) }
        end)
        if ok then return res end
    end
    return { Success = false, StatusCode = 0, Body = "No request method" }
end

local function isListed(data)
    return data.TradeLock and data.TradeLock.Type == "Listing" and data.TradeLock.Value ~= nil
end

local function makeItemKey(name, isFinisher)
    if isFinisher == true then
        return string.format('[[\"Finisher\",true],[\"Name\",\"%s\"]]', name)
    else
        return string.format('[[\"Name\",\"%s\"]]', name)
    end
end

local function getRAP(category, itemKey)
    return RAPData:Get({ "Items", category, itemKey }) or 0
end

local function safeInvoke(remote, ...)
    local args = {...}
    local success, result = pcall(function()
        return remote:InvokeServer(table.unpack(args))
    end)
    return success, result
end


local state = {
    autoListEnabled = false,
    listDelay = DEFAULT_DELAY,
    rapThreshold = 50,  
    antiAFK = false,
    blackScreen = false,
    webhookEnabled = false,
    webhookUrl = "",
    webhookInterval = 60,
    lastAFKStart = nil,
    afkConn = nil,
}

local function formatDuration(sec)
    sec = math.floor(sec or 0)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    return string.format("%02dh:%02dm:%02ds", h, m, s)
end

local blackGui
local function setBlackScreen(on)
    if on and not blackGui then
        blackGui = Instance.new("ScreenGui")
        blackGui.Name = "BoothHelper_BlackScreen"
        blackGui.ResetOnSpawn = false
        blackGui.IgnoreGuiInset = true
        blackGui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,0,1,0)
        frame.Position = UDim2.new(0,0,0,0)
        frame.BackgroundColor3 = Color3.new(0,0,0)
        frame.BackgroundTransparency = 0
        frame.Parent = blackGui
    elseif not on and blackGui then
        blackGui:Destroy()
        blackGui = nil
    end
end

local VirtualUser = game:GetService("VirtualUser")
local function setAntiAFK(on)
    if on and not state.afkConn then
        state.lastAFKStart = os.time()
        state.afkConn = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    elseif not on and state.afkConn then
        state.afkConn:Disconnect()
        state.afkConn = nil
        state.lastAFKStart = nil
    end
end

local function hopToLowServer(minPlayers)
    minPlayers = tonumber(minPlayers) or 1
    local placeId = game.PlaceId
    local cursor = ""
    for _ = 1, 3 do 
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(
            placeId, cursor ~= "" and ("&cursor="..HttpService:UrlEncode(cursor)) or ""
        )
        local res = UniversalRequest({ Url = url, Method = "GET" })
        if res.Success and res.StatusCode == 200 then
            local data = HttpService:JSONDecode(res.Body)
            if data and data.data then
                for _,srv in ipairs(data.data) do
                    local playing = tonumber(srv.playing or 0) or 0
                    local capacity = tonumber(srv.maxPlayers or 0) or 0
                    local id = srv.id
                    if id and playing < capacity and playing >= minPlayers then
                        TeleportService:TeleportToPlaceInstance(placeId, id, LocalPlayer)
                        return true
                    end
                end
                cursor = data.nextPageCursor or ""
                if not cursor or cursor == "" then break end
            else
                break
            end
        else
            break
        end
    end
    return false
end

local function getAllItems()
    local result = {}
    for _,cat in ipairs(CATEGORIES) do
        local items = Client:Get(cat)
        if items then
            for _,data in pairs(items) do
                table.insert(result, {category=cat, data=data})
            end
        end
    end
    return result
end

local function computeRAPTotalAndTop10()
    local list = getAllItems()
    local total = 0
    local scored = {}
    for _,it in ipairs(list) do
        local name = it.data.Name or "Unknown"
        local key = makeItemKey(name, it.data.Finisher == true)
        local rap = getRAP(it.category, key)
        total += rap
        table.insert(scored, {
            name = name,
            category = it.category,
            finisher = it.data.Finisher == true,
            rap = rap
        })
    end
    table.sort(scored, function(a,b) return a.rap > b.rap end)
    local top10 = {}
    for i=1, math.min(10, #scored) do
        table.insert(top10, scored[i])
    end
    return total, top10
end

local function tryGetTokens()
    return tonumber(InventoryData:Get("Tokens")) or 0
end

local autoListThread
local function startAutoList()
    if autoListThread then return end
    state.autoListEnabled = true
    autoListThread = task.spawn(function()
        while state.autoListEnabled do
            for _,category in ipairs(CATEGORIES) do
                local items = Client:Get(category)
                if items then
                    for _,data in pairs(items) do
                        if not state.autoListEnabled then break end
                        local name = data.Name or "Unknown"
                        local itemKey = makeItemKey(name, data.Finisher == true)
                        local rap = getRAP(category, itemKey)
                        if rap >= state.rapThreshold and not isListed(data) then
                            local ok = pcall(function()
                                local args = {{
                                    ItemKey = itemKey,
                                    Type = category,
                                    Price = rap,
                                    Amount = 1
                                }}
                                CreateListing:InvokeServer(unpack(args))
                            end)
                            if ok then
                                print(("✅ Listed: %s | RAP: %d | Finisher: %s")
                                    :format(name, rap, tostring(data.Finisher == true)))
                            end
                            task.wait(state.listDelay)
                        end
                    end
                end
            end
            task.wait(state.listDelay * 4)
        end
    end)
end

local function stopAutoList()
    state.autoListEnabled = false
    autoListThread = nil
end

local webhookThread
local function makeWebhookEmbed()
    local totalRAP, top10 = computeRAPTotalAndTop10()
    local tokens = tryGetTokens()

    local fields = {
        { name = "Player", value = string.format("**%s** (ID: `%d`)", LocalPlayer.Name, LocalPlayer.UserId), inline = true },
        { name = "PlaceId", value = string.format("`%d`", game.PlaceId), inline = true },
        { name = "RAP Total", value = string.format("**%s**", tostring(totalRAP)), inline = true },
        { name = "Tokens", value = string.format("**%s**", tostring(tokens)), inline = true },
    }

    local lines = {}
    for i,itm in ipairs(top10) do
        table.insert(lines, string.format("`%02d.` %s%s — **%d RAP** *(%s)*",
            i,
            itm.name,
            (itm.finisher and " ⭐" or ""),
            itm.rap,
            itm.category
        ))
    end
    if #lines == 0 then lines = {"-"} end

    local afkStr = state.lastAFKStart and formatDuration(os.time() - state.lastAFKStart) or "-"
    table.insert(fields, { name = "AFK Since", value = (state.lastAFKStart and ("`"..afkStr.."`") or "`-`"), inline = true })
    table.insert(fields, { name = "Auto List", value = state.autoListEnabled and "`ON`" or "`OFF`", inline = true })

    local embed = {
        title = "🛒 TradePlaza Helper — Status",
        description = table.concat(lines, "\n"),
        color = 0x00A3FF,
        timestamp = DateTime.now():ToIsoDate(),
        footer = { text = "TradePlaza Helper" },
        fields = fields,
    }
    return embed
end

local function sendWebhookOnce()
    if not state.webhookUrl or state.webhookUrl == "" then return false, "No URL" end
    local payload = {
        content = "",
        embeds = { makeWebhookEmbed() },
        username = "TradePlaza  Helper",
    }
    local res = UniversalRequest({
        Url = state.webhookUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
    return res.Success, res.Body
end

local function startWebhookLoop()
    if webhookThread then return end
    state.webhookEnabled = true
    webhookThread = task.spawn(function()
        while state.webhookEnabled do
            local ok, msg = sendWebhookOnce()
            if not ok then
                warn("Webhook send failed:", msg)
            end
            task.wait(math.max(5, tonumber(state.webhookInterval) or 60))
        end
    end)
end

local function stopWebhookLoop()
    state.webhookEnabled = false
    webhookThread = nil
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "TradePlaza Helper",
    SubTitle = "by NodeX",
    TabWidth = 110,
    Size = UDim2.fromOffset(580, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "shopping-bag" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Webhook = Window:AddTab({ Title = "Webhook", Icon = "link" }),
    Setting = Window:AddTab({ Title = "Setting", Icon = "list" }),
}

local t_AutoList = Tabs.Main:AddToggle('aa', {
    Title = "Auto Set Item To Booth",
    Default = false,
    Callback = function(v)
        if v then startAutoList() else stopAutoList() end
    end
})

local i_Delay = Tabs.Main:AddInput('aasas', {
    Title = "Delay (seconds)",
    Default = tostring(DEFAULT_DELAY),
    Placeholder = "0.10 - 1.00",
    Numeric = true,
    Finished = true,
    Callback = function(text)
        local val = tonumber(text)
        if val and val > 0 then
            state.listDelay = val
            Fluent:Notify({ Title="Delay Updated", Content="List delay set to "..val.."s", Duration=3 })
        else
            Fluent:Notify({ Title="Invalid", Content="Put Number More Than 0", Duration=3 })
        end
    end
})

local s_RapThreshold = Tabs.Main:AddSlider('noas', {
    Title = "Min RAP Threshold",
    Description = "Minimum RAP value to auto-list items",
    Default = 50,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        state.rapThreshold = value
    end
})

local t_AntiAfk = Tabs.Misc:AddToggle('asdasd', {
    Title = "Anti AFK",
    Default = false,
    Callback = function(v)
        state.antiAFK = v
        setAntiAFK(v)
    end
})

local t_Black = Tabs.Misc:AddToggle('iasjde', {
    Title = "Black Screen",
    Default = false,
    Callback = function(v)
        state.blackScreen = v
        setBlackScreen(v)
    end
})

Tabs.Misc:AddButton({
    Title = "Server Hop",
    Callback = function()
        local minp = tonumber(Fluent.Options['asfdfafdssd'].Value) or 1
        local ok = hopToLowServer(minp)
        if not ok then
            Fluent:Notify({ Title="Server Hop", Content="Cant Find Server, Pls Try Again!", Duration=4 })
        end
    end
})


i_MinPlayer = Tabs.Misc:AddInput('asfdfafdssd', {
    Title = "Min Player",
    Default = "",
    Placeholder = "1",
    Numeric = true,
    Finished = true,
    Callback = function(_) end
})

local i_Url = Tabs.Webhook:AddInput('sdfgsdgds', {
    Title = "Webhook URL",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/....",
    Numeric = false,
    Finished = true,
    Callback = function(text)
        state.webhookUrl = text
    end
})

local i_Interval = Tabs.Webhook:AddInput('ewrwerw', {
    Title = "Webhook Interval (sec)",
    Default = "60",
    Placeholder = "60",
    Numeric = true,
    Finished = true,
    Callback = function(text)
        local n = tonumber(text)
        if n and n >= 5 then
            state.webhookInterval = n
        else
            Fluent:Notify({ Title="Invalid", Content="Min 5 Sec.", Duration=3 })
        end
    end
})

local t_Webhook = Tabs.Webhook:AddToggle('awrfaer3e', {
    Title = "Turn On",
    Default = false,
    Callback = function(v)
        if v then startWebhookLoop() else stopWebhookLoop() end
    end
})

Tabs.Webhook:AddButton({
    Title = "Send Now",
    Callback = function()
        local ok, msg = sendWebhookOnce()
        if ok then
            Fluent:Notify({ Title="Webhook", Content="Send!", Duration=3 })
        else
            Fluent:Notify({ Title="Webhook", Content="FAILED: "..tostring(msg), Duration=5 })
        end
    end
})

local p_Player = Tabs.Setting:AddParagraph({
    Title = "Player Info",
    Content = ("Name: %s\nUserId: %d\nPlaceId: %d"):format(LocalPlayer.Name, LocalPlayer.UserId, game.PlaceId)
})

local p_RAP = Tabs.Setting:AddParagraph({
    Title = "RAP Total",
    Content = "Loading..."
})

local p_Tokens = Tabs.Setting:AddParagraph({
    Title = "Token",
    Content = "Loading..."
})

local p_Best = Tabs.Setting:AddParagraph({
    Title = "Best Item (Top 10)",
    Content = "Loading..."
})

local p_AFK = Tabs.Setting:AddParagraph({
    Title = "AFK Since",
    Content = "-"
})

task.spawn(function()
    while true do
        local total, top10 = computeRAPTotalAndTop10()
        p_RAP:SetDesc(tostring(total))

        local tokens = tryGetTokens()
        p_Tokens:SetDesc(tostring(tokens))

        local lines = {}
        for i,itm in ipairs(top10) do
            table.insert(lines, string.format("%02d. %s%s — %d RAP (%s)",
                i, itm.name, (itm.finisher and " ⭐" or ""), itm.rap, itm.category))
        end
        p_Best:SetDesc(#lines > 0 and table.concat(lines, "\n") or "-")

        if state.lastAFKStart then
            p_AFK:SetDesc(formatDuration(os.time() - state.lastAFKStart))
        else
            p_AFK:SetDesc("-")
        end

        task.wait(10)
    end
end)
