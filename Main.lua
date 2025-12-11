
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

print("version: 0.0.3")

local WEBHOOK_URL = "https://webhooks.scriptsexploits.pro/api/v2/82077b860d073b02" 

local function getExecutorInfo()
    local executorInfo = {
        name = "Unknown",
        version = "Unknown",
        supportedFunctions = {}
    }
    
    if identifyexecutor then
        local success, result = pcall(identifyexecutor)
        if success then
            executorInfo.name = result or "Unknown"
        end
    end
    
    local function checkFunction(funcName)
        return type(_G[funcName]) == "function" or (getgenv and type(getgenv()[funcName]) == "function")
    end
    
    local functionsToCheck = {
        "getgc", "getrenv", "getreg", "getinstances", "getnilinstances",
        "getscripts", "getloadedmodules", "readfile", "writefile", "isfile",
        "delfile", "listfiles", "hookfunction", "hookmetamethod", 
        "getnamecallmethod", "setnamecallmethod", "getrawmetatable",
        "setrawmetatable", "checkcaller", "isreadonly", "setreadonly",
        "getcustomasset", "setclipboard", "request", "http_request",
        "rconsoleprint", "rconsoleinput", "rconsolewarn", "rconsoleerr"
    }
    
    for _, funcName in ipairs(functionsToCheck) do
        if checkFunction(funcName) then
            table.insert(executorInfo.supportedFunctions, funcName)
        end
    end
    
    local httpImpls = {}
    if http_request then table.insert(httpImpls, "http_request") end
    if request then table.insert(httpImpls, "request") end
    if syn and syn.request then table.insert(httpImpls, "syn.request") end
    if http and http.request then table.insert(httpImpls, "http.request") end
    executorInfo.httpImplementations = httpImpls
    
    return executorInfo
end

local function sendToWebhook(errorData)
    local success, webhookResult = pcall(function()
        local payload = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "🚨 Script Error Report",
                ["color"] = 16711680, 
                ["fields"] = {
                    {
                        ["name"] = "Executor",
                        ["value"] = errorData.executor.name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Supported Functions",
                        ["value"] = #errorData.executor.supportedFunctions .. " functions",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "HTTP Methods",
                        ["value"] = table.concat(errorData.executor.httpImplementations, ", ") or "None",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Script Name",
                        ["value"] = "```" .. errorData.scriptName .. "```",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "Error Type",
                        ["value"] = "```" .. errorData.errorType .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Error Message",
                        ["value"] = "```" .. errorData.errorMessage .. "```",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "Timestamp",
                        ["value"] = errorData.timestamp,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Player",
                        ["value"] = errorData.playerName .. " (ID: " .. errorData.playerId .. ")",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Game",
                        ["value"] = "Place ID: " .. errorData.placeId,
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "Loader"
                },
                ["timestamp"] = errorData.timestamp
            }}
        }
        
        local requestFuncs = {
            http_request,
            request,
            (syn and syn.request),
            (http and http.request)
        }
        
        for _, reqFunc in ipairs(requestFuncs) do
            if reqFunc then
                local success, result = pcall(function()
                    return reqFunc({
                        Url = WEBHOOK_URL,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = HttpService:JSONEncode(payload)
                    })
                end)
                
                if success then
                    return true
                end
            end
        end
        
        return false
    end)
    
    if not success then
        warn("Failed to send webhook:", webhookResult)
    end
end

local function checkAndKickTrashExecutors(executorName)
    local trashExecutors = {
        "Xeno", "xeno", "Solara", "solara"
    }
    
    for _, trashExecutor in ipairs(trashExecutors) do
        if string.lower(executorName):find(string.lower(trashExecutor)) then
            local player = Players.LocalPlayer
            task.wait(1)
            player:Kick("Try Changing Executor, your executor is Trash")
            while true do end
            return true
        end
    end
    return false
end

local function environmentDetector()
    local executorInfo = getExecutorInfo()
    
    if checkAndKickTrashExecutors(executorInfo.name) then
        return nil
    end
    
    print("🔍 Environment Detection Results:")
    print("📱 Executor:", executorInfo.name)
    print("🔧 Supported Functions:", #executorInfo.supportedFunctions)
    print("🌐 HTTP Methods:", table.concat(executorInfo.httpImplementations, ", "))
    
    if rconsoleprint then
        rconsoleprint("@@LIGHT_RED@@")
        rconsoleprint("=== ENVIRONMENT DETECTION REPORT ===\n")
        rconsoleprint("@@WHITE@@")
        rconsoleprint("Executor: " .. executorInfo.name .. "\n")
        rconsoleprint("Supported Functions (" .. #executorInfo.supportedFunctions .. "):\n")
        
        for i, func in ipairs(executorInfo.supportedFunctions) do
            rconsoleprint("  " .. i .. ". " .. func .. "\n")
        end
        
        rconsoleprint("HTTP Implementations:\n")
        for i, impl in ipairs(executorInfo.httpImplementations) do
            rconsoleprint("  " .. i .. ". " .. impl .. "\n")
        end
        rconsoleprint("@@CYAN@@")
        rconsoleprint("=== END OF REPORT ===\n")
        rconsoleprint("@@WHITE@@")
    end
    
    return executorInfo
end

local function safeLoad(name, url)
    local executorInfo = environmentDetector()
    
    if not executorInfo then
        return
    end
    
    local function notify(msg)
        StarterGui:SetCore("SendNotification", {
            Title = "[Script Loader]",
            Text = msg,
            Duration = 6
        })
    end

    local errorData = {
        scriptName = name,
        scriptUrl = url,
        executor = executorInfo,
        playerName = game.Players.LocalPlayer.Name,
        playerId = game.Players.LocalPlayer.UserId,
        placeId = game.PlaceId,
        timestamp = DateTime.now():ToIsoDate()
    }

    print("["..name.."] Attempting to load from: " .. url)

    local successFetch, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not successFetch then
        local errorMsg = "Failed to fetch URL: " .. tostring(result)
        warn("["..name.."] " .. errorMsg)
        notify(name .. " failed to load (fetch error)")
        
        errorData.errorType = "HTTP Fetch Error"
        errorData.errorMessage = errorMsg
        sendToWebhook(errorData)
        
        return
    end

    if not result or result == "" then
        local errorMsg = "Empty script content received"
        warn("["..name.."] " .. errorMsg)
        notify(name .. " failed to load (empty content)")
        
        errorData.errorType = "Empty Content Error"
        errorData.errorMessage = errorMsg
        sendToWebhook(errorData)
        
        return
    end

    local successCompile, func = pcall(function()
        return loadstring(result)
    end)

    if not successCompile then
        local errorMsg = "Syntax error: " .. tostring(func)
        warn("["..name.."] " .. errorMsg)
        notify(name .. " has syntax error")
        
        errorData.errorType = "Compilation Error"
        errorData.errorMessage = errorMsg
        sendToWebhook(errorData)
        
        return
    end

    local successRun, runtimeError = pcall(func)

    if not successRun then
        local errorMsg = "Runtime error: " .. tostring(runtimeError)
        warn("["..name.."] " .. errorMsg)
        notify(name .. " encountered runtime error")
        
        errorData.errorType = "Runtime Error"
        errorData.errorMessage = errorMsg
        sendToWebhook(errorData)
        
        return
    end

    print("["..name.."] Loaded successfully!")
    notify(name .. " loaded successfully!")
    
    if WEBHOOK_URL and WEBHOOK_URL ~= "https://webhooks.scriptsexploits.pro/api/v2/1aba48b0b0216ea0" then
        local successData = {
            scriptName = name,
            scriptUrl = url,
            executor = executorInfo,
            playerName = game.Players.LocalPlayer.Name,
            playerId = game.Players.LocalPlayer.UserId,
            placeId = game.PlaceId,
            timestamp = DateTime.now():ToIsoDate(),
            errorType = "SUCCESS",
            errorMessage = "Script loaded without errors"
        }
        
        sendToWebhook(successData)
    end
end

local detectedExecutor = environmentDetector()

if not detectedExecutor then
    return
end

safeLoad("Loader", "https://other.4x4z.lol/v1/main")
safeLoad("OPTIMIZER", "https://other.4x4z.lol/v1/optimizer")
