--!strict

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local COL = {
    overlay  = Color3.fromRGB(10, 8, 18),
    catBody  = Color3.fromRGB(252, 228, 243),
    catEar   = Color3.fromRGB(236, 72, 153),
    catEye   = Color3.fromRGB(26, 26, 46),
    catNose  = Color3.fromRGB(236, 72, 153),
    catPaw   = Color3.fromRGB(236, 72, 153),
    catTail  = Color3.fromRGB(252, 228, 243),
    whisker  = Color3.fromRGB(200, 200, 210),
    track    = Color3.fromRGB(42, 42, 48),
    fill     = Color3.fromRGB(245, 245, 250),
    title    = Color3.fromRGB(245, 245, 250),
    sub      = Color3.fromRGB(150, 150, 160),
}

local function getParentGui(): Instance
    local ok, hui = pcall(function() return (getgenv().gethui or gethui)() end)
    if ok and hui then return hui end
    local okc, core = pcall(function() return game:GetService("CoreGui") end)
    if okc and core then return core end
    return (Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer):WaitForChild("PlayerGui")
end

type CatData = {
    frame: Frame,
    head: Frame,
    leftEar: Frame,
    rightEar: Frame,
    leftEye: Frame,
    rightEye: Frame,
    leftHL: Frame,
    rightHL: Frame,
    nose: Frame,
    tail: Frame,
    bounce: number,
    tailWag: number,
    blinkTimer: number,
    scale: number,
}

local function makeCat(parent: Instance, scale: number): CatData
    local s = scale
    local cat = Instance.new("Frame")
    cat.Name = "NekoCat"
    cat.AnchorPoint = Vector2.new(0.5, 0.5)
    cat.Position = UDim2.fromScale(0.5, 0.5)
    cat.Size = UDim2.fromOffset(90 * s, 90 * s)
    cat.BackgroundTransparency = 1
    cat.Parent = parent

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0
    uiScale.Parent = cat
    TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

    local leftEar = Instance.new("Frame")
    leftEar.AnchorPoint = Vector2.new(0.5, 0.5)
    leftEar.Position = UDim2.fromScale(0.28, 0.15)
    leftEar.Size = UDim2.fromOffset(20 * s, 20 * s)
    leftEar.BackgroundColor3 = COL.catEar
    leftEar.BorderSizePixel = 0
    leftEar.Rotation = 45
    leftEar.ZIndex = 1
    leftEar.Parent = cat
    local lec = Instance.new("UICorner"); lec.CornerRadius = UDim.new(0, 3); lec.Parent = leftEar

    local rightEar = Instance.new("Frame")
    rightEar.AnchorPoint = Vector2.new(0.5, 0.5)
    rightEar.Position = UDim2.fromScale(0.72, 0.15)
    rightEar.Size = UDim2.fromOffset(20 * s, 20 * s)
    rightEar.BackgroundColor3 = COL.catEar
    rightEar.BorderSizePixel = 0
    rightEar.Rotation = -45
    rightEar.ZIndex = 1
    rightEar.Parent = cat
    local rec = Instance.new("UICorner"); rec.CornerRadius = UDim.new(0, 3); rec.Parent = rightEar

    local tail = Instance.new("Frame")
    tail.AnchorPoint = Vector2.new(0.5, 0.5)
    tail.Position = UDim2.fromScale(0.82, 0.62)
    tail.Size = UDim2.fromOffset(28 * s, 10 * s)
    tail.BackgroundColor3 = COL.catTail
    tail.BorderSizePixel = 0
    tail.ZIndex = 1
    tail.Parent = cat
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = tail

    local head = Instance.new("Frame")
    head.Name = "Head"
    head.AnchorPoint = Vector2.new(0.5, 0.5)
    head.Position = UDim2.fromScale(0.5, 0.42)
    head.Size = UDim2.fromOffset(52 * s, 52 * s)
    head.BackgroundColor3 = COL.catBody
    head.BorderSizePixel = 0
    head.ZIndex = 2
    head.Parent = cat
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(1, 0); hc.Parent = head

    local leftEye = Instance.new("Frame")
    leftEye.AnchorPoint = Vector2.new(0.5, 0.5)
    leftEye.Position = UDim2.fromScale(0.37, 0.38)
    leftEye.Size = UDim2.fromOffset(7 * s, 9 * s)
    leftEye.BackgroundColor3 = COL.catEye
    leftEye.BorderSizePixel = 0
    leftEye.ZIndex = 3
    leftEye.Parent = cat
    local lEC = Instance.new("UICorner"); lEC.CornerRadius = UDim.new(1, 0); lEC.Parent = leftEye

    local rightEye = Instance.new("Frame")
    rightEye.AnchorPoint = Vector2.new(0.5, 0.5)
    rightEye.Position = UDim2.fromScale(0.63, 0.38)
    rightEye.Size = UDim2.fromOffset(7 * s, 9 * s)
    rightEye.BackgroundColor3 = COL.catEye
    rightEye.BorderSizePixel = 0
    rightEye.ZIndex = 3
    rightEye.Parent = cat
    local rEC = Instance.new("UICorner"); rEC.CornerRadius = UDim.new(1, 0); rEC.Parent = rightEye

    local leftHL = Instance.new("Frame")
    leftHL.AnchorPoint = Vector2.new(0.5, 0.5)
    leftHL.Position = UDim2.fromScale(0.35, 0.34)
    leftHL.Size = UDim2.fromOffset(3 * s, 3 * s)
    leftHL.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftHL.BorderSizePixel = 0
    leftHL.ZIndex = 4
    leftHL.Parent = cat
    local lhlc = Instance.new("UICorner"); lhlc.CornerRadius = UDim.new(1, 0); lhlc.Parent = leftHL

    local rightHL = Instance.new("Frame")
    rightHL.AnchorPoint = Vector2.new(0.5, 0.5)
    rightHL.Position = UDim2.fromScale(0.61, 0.34)
    rightHL.Size = UDim2.fromOffset(3 * s, 3 * s)
    rightHL.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rightHL.BorderSizePixel = 0
    rightHL.ZIndex = 4
    rightHL.Parent = cat
    local rhlc = Instance.new("UICorner"); rhlc.CornerRadius = UDim.new(1, 0); rhlc.Parent = rightHL

    local nose = Instance.new("Frame")
    nose.AnchorPoint = Vector2.new(0.5, 0.5)
    nose.Position = UDim2.fromScale(0.5, 0.48)
    nose.Size = UDim2.fromOffset(6 * s, 5 * s)
    nose.BackgroundColor3 = COL.catNose
    nose.BorderSizePixel = 0
    nose.ZIndex = 3
    nose.Parent = cat
    local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(1, 0); nc.Parent = nose

    for i = 0, 2 do
        local y = 0.46 + i * 0.04
        local lw = Instance.new("Frame")
        lw.AnchorPoint = Vector2.new(1, 0.5)
        lw.Position = UDim2.fromScale(0.28, y)
        lw.Size = UDim2.fromOffset(14 * s, 1.5 * s)
        lw.BackgroundColor3 = COL.whisker
        lw.BorderSizePixel = 0
        lw.ZIndex = 3
        lw.Parent = cat

        local rw = Instance.new("Frame")
        rw.AnchorPoint = Vector2.new(0, 0.5)
        rw.Position = UDim2.fromScale(0.72, y)
        rw.Size = UDim2.fromOffset(14 * s, 1.5 * s)
        rw.BackgroundColor3 = COL.whisker
        rw.BorderSizePixel = 0
        rw.ZIndex = 3
        rw.Parent = cat
    end

    return {
        frame = cat, head = head, leftEar = leftEar, rightEar = rightEar,
        leftEye = leftEye, rightEye = rightEye,
        leftHL = leftHL, rightHL = rightHL,
        nose = nose, tail = tail,
        bounce = 0, tailWag = 0, blinkTimer = 0, scale = s,
    }
end

type PawData = {
    frame: Frame,
    children: { Frame },
    offset: number,
}

local function makePawPrint(parent: Instance, scale: number): PawData
    local s = scale
    local paw = Instance.new("Frame")
    paw.Name = "PawPrint"
    paw.AnchorPoint = Vector2.new(0.5, 0.5)
    paw.Size = UDim2.fromOffset(22 * s, 26 * s)
    paw.BackgroundTransparency = 1
    paw.Parent = parent

    local children: { Frame } = {}

    local pad = Instance.new("Frame")
    pad.AnchorPoint = Vector2.new(0.5, 0.5)
    pad.Position = UDim2.fromScale(0.5, 0.68)
    pad.Size = UDim2.fromOffset(12 * s, 9 * s)
    pad.BackgroundColor3 = COL.catPaw
    pad.BorderSizePixel = 0
    pad.Parent = paw
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(1, 0); pc.Parent = pad
    table.insert(children, pad)

    for i = 0, 3 do
        local toe = Instance.new("Frame")
        toe.AnchorPoint = Vector2.new(0.5, 0.5)
        toe.Position = UDim2.fromScale(0.2 + i * 0.27, 0.2)
        toe.Size = UDim2.fromOffset(5 * s, 6 * s)
        toe.BackgroundColor3 = COL.catPaw
        toe.BorderSizePixel = 0
        toe.Parent = paw
        local tcc = Instance.new("UICorner"); tcc.CornerRadius = UDim.new(1, 0); tcc.Parent = toe
        table.insert(children, toe)
    end

    return { frame = paw, children = children, offset = 0 }
end

type LoaderImpl = {
    __index: LoaderImpl,
    new: () -> LoaderInstance,
    setStatus: (self: LoaderInstance, text: any) -> (),
    setProgress: (self: LoaderInstance, p: number) -> (),
    finish: (self: LoaderInstance, callback: (() -> ())?) -> (),
    destroy: (self: LoaderInstance) -> ()
}

export type LoaderInstance = {
    _progress: number,
    _currentProgress: number,
    _lastPct: number,
    _cat: CatData,
    _paws: { PawData },
    _conns: { RBXScriptConnection },
    _blur: BlurEffect,
    _gui: ScreenGui,
    _overlay: Frame,
    _status: TextLabel,
    _fill: Frame,
    _pct: TextLabel
}

local Loader: LoaderImpl = {} :: LoaderImpl
Loader.__index = Loader

function Loader.new(): LoaderInstance
    local self = setmetatable({}, Loader) :: any
    self._progress = 0
    self._currentProgress = 0
    self._lastPct = -1
    self._paws = {}
    self._conns = {}

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isSmall = isMobile or viewport.X < 768 or viewport.Y < 500
    local scale = isSmall and 0.6 or 1.0
    local labelWidth = isSmall and 280 or 400
    local trackWidth = isSmall and 240 or 320

    local blur = Instance.new("BlurEffect")
    blur.Name = "Neko_HubLoadBlur"
    blur.Size = 0
    blur.Parent = Lighting
    self._blur = blur
    TweenService:Create(blur, TweenInfo.new(0.35), { Size = 18 }):Play()

    local gui = Instance.new("ScreenGui")
    gui.Name = "Neko_HubLoader"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getParentGui()
    self._gui = gui

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = COL.overlay
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Parent = gui
    self._overlay = overlay
    TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.35 }):Play()

    local stage = Instance.new("Frame")
    stage.Name = "Stage"
    stage.AnchorPoint = Vector2.new(0.5, 0.5)
    stage.Position = UDim2.fromScale(0.5, 0.40)
    stage.Size = UDim2.fromOffset(0, 0)
    stage.BackgroundTransparency = 1
    stage.Parent = overlay

    self._cat = makeCat(stage, scale)

    local pawY = 52 * scale
    local pawSpacing = 35 * scale
    for i = 0, 3 do
        local pd = makePawPrint(stage, scale)
        pd.offset = i * pawSpacing
        table.insert(self._paws, pd)
    end

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Position = UDim2.fromScale(0.5, 0.64)
    title.Size = UDim2.fromOffset(labelWidth, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "NEKO_HUB"
    title.TextColor3 = COL.title
    title.TextSize = isSmall and 18 or 24
    title.TextTransparency = 1
    title.Parent = overlay
    TweenService:Create(title, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()

    local status = Instance.new("TextLabel")
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Position = UDim2.fromScale(0.5, 0.70)
    status.Size = UDim2.fromOffset(labelWidth, 18)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = "Loading..."
    status.TextColor3 = COL.sub
    status.TextSize = isSmall and 11 or 13
    status.Parent = overlay
    self._status = status

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(0.5, 0.5)
    track.Position = UDim2.fromScale(0.5, 0.755)
    track.Size = UDim2.fromOffset(trackWidth, isSmall and 4 or 6)
    track.BackgroundColor3 = COL.track
    track.BorderSizePixel = 0
    track.Parent = overlay
    local tcc = Instance.new("UICorner"); tcc.CornerRadius = UDim.new(1, 0); tcc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = COL.fill
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fcc = Instance.new("UICorner"); fcc.CornerRadius = UDim.new(1, 0); fcc.Parent = fill
    self._fill = fill

    local pct = Instance.new("TextLabel")
    pct.AnchorPoint = Vector2.new(0.5, 0.5)
    pct.Position = UDim2.fromScale(0.5, 0.80)
    pct.Size = UDim2.fromOffset(labelWidth, 16)
    pct.BackgroundTransparency = 1
    pct.Font = Enum.Font.GothamBold
    pct.Text = "0%"
    pct.TextColor3 = COL.sub
    pct.TextSize = isSmall and 10 or 12
    pct.Parent = overlay
    self._pct = pct

    local cat = self._cat
    local paws = self._paws
    local pawSp = pawSpacing
    local pY = pawY
    local pawSpeed = 55 * scale
    local maxDist = 70 * scale

    local conn = RunService.RenderStepped:Connect(function(dt: number)
        cat.bounce = (cat.bounce + dt * 10) % (math.pi * 2)
        local bounceY = math.sin(cat.bounce) * 6 * cat.scale
        cat.frame.Position = UDim2.new(0.5, 0, 0.5, bounceY)

        cat.tailWag = (cat.tailWag + dt * 5) % (math.pi * 2)
        cat.tail.Rotation = math.sin(cat.tailWag) * 20

        cat.leftEar.Rotation = 45 + math.sin(cat.bounce * 2) * 4
        cat.rightEar.Rotation = -45 - math.sin(cat.bounce * 2) * 4

        cat.blinkTimer = cat.blinkTimer + dt
        local blinkInterval = 3.0
        local blinkDuration = 0.15
        if cat.blinkTimer > blinkInterval then
            local phase = (cat.blinkTimer - blinkInterval) / blinkDuration
            if phase < 1 then
                local eyeH = math.max(1, 9 * cat.scale * math.abs(math.cos(phase * math.pi)))
                cat.leftEye.Size = UDim2.fromOffset(7 * cat.scale, eyeH)
                cat.rightEye.Size = UDim2.fromOffset(7 * cat.scale, eyeH)
                local hlT = math.abs(math.cos(phase * math.pi))
                cat.leftHL.BackgroundTransparency = hlT
                cat.rightHL.BackgroundTransparency = hlT
            else
                cat.blinkTimer = 0
                cat.leftEye.Size = UDim2.fromOffset(7 * cat.scale, 9 * cat.scale)
                cat.rightEye.Size = UDim2.fromOffset(7 * cat.scale, 9 * cat.scale)
                cat.leftHL.BackgroundTransparency = 0
                cat.rightHL.BackgroundTransparency = 0
            end
        end

        for _, paw in ipairs(paws) do
            paw.offset = paw.offset - pawSpeed * dt
            if paw.offset < -pawSp then
                paw.offset = paw.offset + pawSp * 4
            end
            paw.frame.Position = UDim2.fromOffset(paw.offset, pY)
            local dist = math.abs(paw.offset)
            local trans = 0.15 + math.min(dist, maxDist) / maxDist * 0.85
            for _, child in ipairs(paw.children) do
                child.BackgroundTransparency = trans
            end
        end

        local current = self._currentProgress
        local target = self._progress
        if current ~= target then
            local nextProgress = current + (target - current) * (1 - 0.5 ^ (dt * 20))
            if math.abs(target - nextProgress) < 0.001 then
                nextProgress = target
            end
            self._currentProgress = nextProgress
            fill.Size = UDim2.fromScale(nextProgress, 1)

            local pctVal = math.floor(nextProgress * 100 + 0.5)
            if self._lastPct ~= pctVal then
                self._lastPct = pctVal
                pct.Text = tostring(pctVal) .. "%"
            end
        end
    end)
    table.insert(self._conns, conn)

    return self
end

function Loader:setStatus(text: any)
    if self._status then self._status.Text = tostring(text) end
end

function Loader:setProgress(p: number)
    self._progress = math.clamp(p, 0, 1)
end

function Loader:finish(callback: (() -> ())?)
    self:setProgress(1)
    task.delay(0.25, function()
        if self._overlay then
            TweenService:Create(self._overlay, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            for _, ch in ipairs(self._overlay:GetDescendants()) do
                if ch:IsA("TextLabel") then
                    TweenService:Create(ch, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
                elseif ch:IsA("Frame") then
                    TweenService:Create(ch, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
                elseif ch:IsA("UIStroke") then
                    TweenService:Create(ch, TweenInfo.new(0.4), { Transparency = 1 }):Play()
                end
            end
        end
        if self._blur then
            TweenService:Create(self._blur, TweenInfo.new(0.4), { Size = 0 }):Play()
        end
        task.delay(0.45, function()
            self:destroy()
            if type(callback) == "function" then
                local ok, err = pcall(callback :: () -> ())
                if not ok then warn("[Neko_Hub] loader callback error: " .. tostring(err)) end
            end
        end)
    end)
end

function Loader:destroy()
    for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
    self._conns = {}
    if self._gui then pcall(function() self._gui:Destroy() end) end
    if self._blur then pcall(function() self._blur:Destroy() end) end
end

if not (getgenv and getgenv().Neko_HubLoaderModule) then
    task.spawn(function()
        local L = Loader.new()
        L:setStatus("Loading Neko_Hub...")
        local p = 0
        while p < 1 do
            p = math.min(1, p + math.random(2, 6) / 100)
            L:setProgress(p)
            task.wait(0.06)
        end
        L:setStatus("Done!")
        L:finish(function() end)
    end)
end

return Loader
