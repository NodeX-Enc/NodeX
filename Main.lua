game.Players.LocalPlayer:Kick("Script Is Down, Pls Wait until Owner Fix...10-20 Minute")
--[[
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

print("version: 0.0.7")

local API_URL = "http://31.97.106.155:6767/error"
local WEBHOOK_URL = "https://webhooks.scriptsexploits.pro/api/v2/ca4491cbb627d84d"

local REQUIRED_FUNCTIONS = {
    "hookmetamethod",
    "getnamecallmethod",
    "setnamecallmethod",
    "getrawmetatable",
    "setrawmetatable"
}

local ALL_FUNCTIONS = {
    "getgc","getrenv","getreg","getinstances","getnilinstances",
    "getscripts","getloadedmodules","readfile","writefile","isfile",
    "delfile","listfiles","hookfunction","hookmetamethod",
    "getnamecallmethod","setnamecallmethod","getrawmetatable",
    "setrawmetatable","checkcaller","isreadonly","setreadonly",
    "getcustomasset","setclipboard","request","http_request",
    "rconsoleprint","rconsolewarn","rconsoleerr"
}

local function notify(t)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "[Loader]",
            Text = t,
            Duration = 6
        })
    end)
end

local function getExecutor()
    if identifyexecutor then
        local ok, res = pcall(identifyexecutor)
        if ok then return res end
    end
    return "Unknown"
end

local function hasFunction(n)
    return type(_G[n]) == "function" or (getgenv and type(getgenv()[n]) == "function")
end

local function getSupported()
    local t = {}
    for _, f in ipairs(ALL_FUNCTIONS) do
        if hasFunction(f) then
            table.insert(t, f)
        end
    end
    return t
end

local function getMissing()
    local t = {}
    for _, f in ipairs(REQUIRED_FUNCTIONS) do
        if not hasFunction(f) then
            table.insert(t, f)
        end
    end
    return t
end

local function send(url, payload)
    local body = HttpService:JSONEncode(payload)
    local reqs = {
        http_request,
        request,
        syn and syn.request,
        http and http.request
    }
    for _, r in ipairs(reqs) do
        if r then
            pcall(function()
                r({
                    Url = url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body
                })
            end)
            break
        end
    end
end

local function report(status, err, funcs)
    send(API_URL, {
        username = Players.LocalPlayer.Name,
        executor = getExecutor(),
        status = status,
        error = err,
        functions = funcs,
        timestamp = DateTime.now():ToIsoDate()
    })

    send(WEBHOOK_URL, {
        embeds = {{
            title = "Loader Report",
            color = status == "OK" and 65280 or 16711680,
            fields = {
                { name = "User", value = Players.LocalPlayer.Name, inline = true },
                { name = "Executor", value = getExecutor(), inline = true },
                { name = "Status", value = status, inline = true },
                { name = "Error", value = err, inline = false }
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    })
end

local function safeLoad(name, url)
    local supported = getSupported()
    local missing = getMissing()

    if #missing > 0 then
        report("ERROR", "Missing functions: " .. table.concat(missing, ", "), supported)
        notify("Executor not supported")
        return
    end

    local okFetch, src = pcall(function()
        return game:HttpGet(url)
    end)

    if not okFetch or not src or src == "" then
        report("ERROR", "Fetch failed", supported)
        notify(name .. " failed")
        return
    end

    local okCompile, fn = pcall(loadstring, src)
    if not okCompile then
        report("ERROR", tostring(fn), supported)
        notify(name .. " syntax error")
        return
    end

    local okRun, runErr = pcall(fn)
    if not okRun then
        report("ERROR", tostring(runErr), supported)
        notify(name .. " runtime error")
        return
    end

    report("OK", "No Problem Found", supported)
    notify(name .. " loaded")
end

local universeid = game.GameId

if universeid == 4777817887 then
    safeLoad("Loader", "https://api.getpolsec.com/scripts/hosted/428a7dfe0951f0e7ec76baf7e4964191b2d777c7904fb72b4dcf0813ba66de6e.lua")
    safeLoad("OPTIMIZER", "https://api.getpolsec.com/scripts/hosted/428a7dfe0951f0e7ec76baf7e4964191b2d777c7904fb72b4dcf0813ba66de6e.lua")
else
    pcall(function()
        loadstring(game:HttpGet("https://api.getpolsec.com/scripts/hosted/428a7dfe0951f0e7ec76baf7e4964191b2d777c7904fb72b4dcf0813ba66de6e.lua"))()
    end)
end
]]
