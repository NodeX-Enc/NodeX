-- chatgpt made it lol me so lazy to make gui
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local DISCORD_INVITE = "https://discord.gg/SkUd5SG9Vw"
local GUI_NAME = "PatchNoticeGUI"

if player:FindFirstChild(GUI_NAME) then
    player[GUI_NAME]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(520, 220)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(28, 30, 33)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 1
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 48)
title.Position = UDim2.new(0, 12, 0, 12)
title.BackgroundTransparency = 1
title.Text = "Notice"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -24, 0, 1)
sep.Position = UDim2.new(0, 12, 0, 66)
sep.BackgroundColor3 = Color3.fromRGB(60, 62, 66)
sep.BorderSizePixel = 0
sep.Parent = frame

local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -24, 0, 96)
message.Position = UDim2.new(0, 12, 0, 76)
message.BackgroundTransparency = 1
message.TextWrapped = true
message.Text = "Attention: The script is currently being patched. Please wait until our developers finish unpatching it. For more information and updates, feel free to join our official Discord server."
message.Font = Enum.Font.Gotham
message.TextSize = 16
message.TextColor3 = Color3.fromRGB(220, 220, 220)
message.Parent = frame

local msgCorner = Instance.new("UICorner", message)
msgCorner.CornerRadius = UDim.new(0, 6)

local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -24, 0, 40)
buttonFrame.Position = UDim2.new(0, 12, 1, -52)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = frame

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 220, 1, 0)
discordBtn.Position = UDim2.new(0, 0, 0, 0)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.AutoButtonColor = true
discordBtn.Text = "Join Discord"
discordBtn.Font = Enum.Font.GothamSemibold
discordBtn.TextSize = 16
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.Parent = buttonFrame

local discordCorner = Instance.new("UICorner", discordBtn)
discordCorner.CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 1, 0)
closeBtn.Position = UDim2.new(1, -100, 0, 0)
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 62, 66)
closeBtn.AutoButtonColor = true
closeBtn.Text = "Close"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 15
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
closeBtn.Parent = buttonFrame

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

-- drag system
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- button actions
discordBtn.Activated:Connect(function()
    if setclipboard then
        setclipboard(DISCORD_INVITE)
        StarterGui:SetCore("SendNotification", { Title = "Discord"; Text = "Invite link copied to clipboard."; Duration = 4 })
    else
        StarterGui:SetCore("SendNotification", { Title = "Discord"; Text = "Copy manually: " .. DISCORD_INVITE; Duration = 4 })
    end
end)

closeBtn.Activated:Connect(function()
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(450, 180)
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

-- spawn animation
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromOffset(450, 180)
TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Size = UDim2.fromOffset(520, 220)
}):Play()
