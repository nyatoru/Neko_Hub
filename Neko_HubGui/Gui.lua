--!strict

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))() :: any
getgenv().WindUI = WindUI

WindUI:AddTheme({
    Name = "NekoTheme",

    Accent      = Color3.fromHex("#e91e8c"),
    Dialog      = Color3.fromHex("#2a0a1f"),
    Text        = Color3.fromHex("#fce4f3"),
    Placeholder = Color3.fromHex("#9a6080"),
    Background  = Color3.fromHex("#0f0510"),
    Button      = Color3.fromHex("#c4177a"),
    Icon        = Color3.fromHex("#f472b6"),

    ElementBackground = Color3.fromHex("#1f0d1a"),
    ElementBackgroundTransparency = 0,

    Toggle     = Color3.fromHex("#ec4899"),
    Slider     = Color3.fromHex("#ec4899"),
    Checkbox   = Color3.fromHex("#ec4899"),
    Primary    = Color3.fromHex("#ec4899"),
    Outline    = Color3.fromHex("#f9a8d4"),

    PanelBackground = Color3.fromHex("#ffffff"),
    PanelBackgroundTransparency = 0.95,

    SliderIcon = Color3.fromHex("#f472b6"),
})

-- Get logo asset ID (works on all platforms)
local LOGO_ASSET_ID = "rbxassetid://89249705975584"
local asset = LOGO_ASSET_ID
if (getcustomasset or getsynasset) and writefile then
    local logoPath = "Neko_Hub/Icon/logo.jpg"
    if isfile and not isfile(logoPath) then
        pcall(makefolder, "Neko_Hub")
        pcall(makefolder, "Neko_Hub/Icon")
        local ok, content = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/nyatoru/Neko_Hub/main/Icon/logo.jpg")
        if ok and content then pcall(writefile, logoPath, content) end
    end
    if isfile and isfile(logoPath) then
        local ok, res = pcall((getcustomasset or getsynasset), logoPath)
        if ok and res then asset = res end
    end
end

local Window = WindUI:CreateWindow({
    Title = "Neko_Hub",
    Author = "by nyatoru",
    Folder = "Neko_Hub",
    Icon = asset,
    Theme = "NekoTheme",
    Size = UDim2.fromOffset(580, 460),
    NewElements = true,
    HideSearchBar = false,
    ToggleKey = Enum.KeyCode.RightAlt,
    OpenButton = {
        Title = "Open Neko_Hub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = true,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"),
            Color3.fromHex("#e7ff2f")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default",
    },
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            -- profile click callback
        end
    },
})
getgenv().Window = Window

-- Mouse unlock/restore logic for desktop players
local UserInputService = game:GetService("UserInputService")
if not UserInputService.TouchEnabled then
    local savedMouseBehavior = UserInputService.MouseBehavior
    local savedMouseIconEnabled = UserInputService.MouseIconEnabled
    local behaviorConn, iconConn
    
    local function unlockMouse()
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIconEnabled = UserInputService.MouseIconEnabled
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        UserInputService.ModalEnabled = true
        
        if behaviorConn then behaviorConn:Disconnect() end
        if iconConn then iconConn:Disconnect() end
        
        behaviorConn = UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end)
        
        iconConn = UserInputService:GetPropertyChangedSignal("MouseIconEnabled"):Connect(function()
            if not UserInputService.MouseIconEnabled then
                UserInputService.MouseIconEnabled = true
            end
        end)
    end
    
    local function restoreMouse()
        if behaviorConn then behaviorConn:Disconnect() behaviorConn = nil end
        if iconConn then iconConn:Disconnect() iconConn = nil end
        
        UserInputService.ModalEnabled = false
        UserInputService.MouseBehavior = savedMouseBehavior
        UserInputService.MouseIconEnabled = savedMouseIconEnabled
    end
    
    -- Force unlock on startup since GUI starts open
    unlockMouse()
    
    Window:OnOpen(unlockMouse)
    Window:OnClose(restoreMouse)
end