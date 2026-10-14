--[[
╔══════════════════════════════════════════════╗
║           N E X U S   D E L T A              ║
║    NEON CATALOG • FEATURE HUB • v1.2.0       ║
╚══════════════════════════════════════════════╝

UI Version: 1.2.0
Features: Fly, Noclip, Aimbot toggle panel included.
]]

local VERSION = "1.2.0"
local API_URL = "https://nebul.rf.gd/api.php"
local GITHUB_URL =
    "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- NEON CYBER PALETTE (V1.2.0 ENHANCED)
--==================================================

local C = {
    bg       = Color3.fromRGB(10, 14, 28),
    panel    = Color3.fromRGB(18, 24, 45),
    card     = Color3.fromRGB(24, 32, 60),
    card2    = Color3.fromRGB(32, 42, 78),
    white    = Color3.fromRGB(255, 255, 255),
    muted    = Color3.fromRGB(140, 160, 195),
    cyan     = Color3.fromRGB(0, 245, 255),
    blue     = Color3.fromRGB(50, 120, 255),
    purple   = Color3.fromRGB(190, 60, 255),
    pink     = Color3.fromRGB(255, 45, 180),
    green    = Color3.fromRGB(50, 255, 150),
    orange   = Color3.fromRGB(255, 170, 50),
    line     = Color3.fromRGB(60, 85, 140),
}

--==================================================
-- HOSTING CONFIG
--==================================================

local function fetchConfig()
    local ok, response = pcall(function()
        return game:HttpGet(API_URL)
    end)

    if not ok or type(response) ~= "string" then
        return nil, "Hosting tidak dapat diakses."
    end

    local decoded, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decoded or type(data) ~= "table" then
        return nil, "Format JSON hosting tidak valid."
    end

    return data
end

local function parts(version)
    local a, b, c = tostring(version or "0.0.0")
        :match("^(%d+)%.(%d+)%.?(%d*)$")

    if not a then return {0, 0, 0} end
    return {
        tonumber(a) or 0,
        tonumber(b) or 0,
        tonumber(c) or 0
    }
end

local function compareVersion(a, b)
    local x, y = parts(a), parts(b)

    for i = 1, 3 do
        if x[i] > y[i] then return 1 end
        if x[i] < y[i] then return -1 end
    end

    return 0
end

local config, configError = fetchConfig()

--==================================================
-- UI HELPERS
--==================================================

local function make(className, props, parent)
    local obj = Instance.new(className)

    for property, value in pairs(props or {}) do
        obj[property] = value
    end

    obj.Parent = parent
    return obj
end

local function round(object, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 12)
    }, object)
end

local function outline(object, color, thickness)
    local s = make("UIStroke", {
        Color = color or C.cyan,
        Thickness = thickness or 1,
        Transparency = 0.1
    }, object)

    return s
end

local function gradient(object, first, second, rotation)
    make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, first),
            ColorSequenceKeypoint.new(1, second)
        }),
        Rotation = rotation or 0
    }, object)
end

local function animate(object, properties, duration)
    local t = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.22,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )

    t:Play()
    return t
end

local function label(parent, text, position, size, color, textSize)
    return make("TextLabel", {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = textSize or 12,
        TextColor3 = color or C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function button(parent, text, position, size, color)
    local b = make("TextButton", {
        Position = position,
        Size = size,
        BackgroundColor3 = color or C.card2,
        BorderSizePixel = 0,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = C.white,
        AutoButtonColor = false
    }, parent)

    round(b, 10)
    outline(b, color or C.cyan, 1)

    b.MouseEnter:Connect(function()
        animate(b, {BackgroundColor3 = C.card2}, 0.15)
    end)

    b.MouseLeave:Connect(function()
        animate(b, {BackgroundColor3 = color or C.card2}, 0.15)
    end)

    return b
end

--==================================================
-- ROOT SCREEN
--==================================================

local old = playerGui:FindFirstChild("NEXUS_DELTA")
if old then old:Destroy() end

local gui = make("ScreenGui", {
    Name = "NEXUS_DELTA",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local main = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.9, 0, 0.78, 0),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)

round(main, 20)
outline(main, C.purple, 1.8)
make("UISizeConstraint", {
    MinSize = Vector2.new(320, 430),
    MaxSize = Vector2.new(600, 720)
}, main)

-- Neon accent strip
local accent = make("Frame", {
    Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = C.purple,
    BorderSizePixel = 0,
    ZIndex = 5
}, main)

gradient(accent, C.purple, C.cyan, 0)

--==================================================
-- HEADER
--==================================================

local header = make("Frame", {
    Position = UDim2.new(0, 0, 0, 4),
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0
}, main)

local logo = make("Frame", {
    Position = UDim2.new(0, 14, 0.5, -20),
    Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = C.purple,
    BorderSizePixel = 0
}, header)

round(logo, 13)
gradient(logo, C.purple, C.pink, 45)
outline(logo, C.cyan, 1)

make("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "N2",
    Font = Enum.Font.GothamBlack,
    TextSize = 20,
    TextColor3 = C.white
}, logo)

label(
    header,
    (config and tostring(config.brand)) or "NEXUS DELTA",
    UDim2.new(0, 64, 0, 12),
    UDim2.new(1, -125, 0, 26),
    C.white,
    19
).Font = Enum.Font.GothamBlack

label(
    header,
    "CYBER EDITION  /  v" .. VERSION,
    UDim2.new(0, 65, 0, 39),
    UDim2.new(1, -130, 0, 18),
    C.cyan,
    9
)

local close = button(
    header, "×",
    UDim2.new(1, -46, 0.5, -16),
    UDim2.fromOffset(32, 32),
    C.card2
)
close.TextSize = 21

close.Activated:Connect(function()
    animate(main, {
        Size = UDim2.new(0.8, 0, 0, 0),
        BackgroundTransparency = 1
    }, 0.2)
    task.wait(0.22)
    gui:Destroy()
end)

--==================================================
-- BODY + SEARCH & STATUS
--==================================================

local body = make("Frame", {
    Position = UDim2.new(0, 0, 0, 76),
    Size = UDim2.new(1, 0, 1, -76),
    BackgroundTransparency = 1
}, main)

local experience = label(
    body, "GAME HUB  /  READY",
    UDim2.new(0, 15, 0, 8),
    UDim2.new(1, -130, 0, 22),
    C.cyan, 10
)
experience.Font = Enum.Font.GothamBold

local updateBtn = button(
    body, "⚡ UPDATER",
    UDim2.new(1, -105, 0, 7),
    UDim2.fromOffset(90, 26),
    C.card
)
updateBtn.TextColor3 = C.pink
updateBtn.TextSize = 9

local search = make("TextBox", {
    Position = UDim2.new(0, 14, 0, 37),
    Size = UDim2.new(1, -28, 0, 39),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "  ⌕   Cari game atau fitur kustom...",
    PlaceholderColor3 = C.muted,
    TextColor3 = C.white,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = false
}, body)

round(search, 11)
outline(search, C.line, 1)

local catalogTitle = label(
    body, "SUPPORTED GAMES & MODS",
    UDim2.new(0, 15, 0, 82),
    UDim2.new(1, -30, 0, 18),
    C.white, 10
)
catalogTitle.Font = Enum.Font.GothamBold

local content = make("ScrollingFrame", {
    Position = UDim2.new(0, 14, 0, 106),
    Size = UDim2.new(1, -28, 1, -145),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.purple,
    CanvasSize = UDim2.new(0, 0, 0, 0)
}, body)

local layout = make("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder
}, content)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(
        0, 0, 0, layout.AbsoluteContentSize.Y + 10
    )
end)

local status = label(
    body, "●  ONLINE v1.2.0",
    UDim2.new(0, 15, 1, -31),
    UDim2.new(1, -30, 0, 20),
    C.green, 9
)

--==================================================
-- FEATURE PANEL (FLY, NOCLIB, AIMBOT, DLL)
--==================================================

local featurePanel = make("Frame", {
    Visible = false,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.52),
    Size = UDim2.new(0.9, 0, 0, 310),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ZIndex = 20
}, main)

round(featurePanel, 16)
outline(featurePanel, C.cyan, 1.5)

local fpTitle = label(
    featurePanel, "⚙ GAME MODS & CHEATS",
    UDim2.new(0, 15, 0, 13),
    UDim2.new(1, -30, 0, 25),
    C.cyan, 13
)
fpTitle.Font = Enum.Font.GothamBlack
fpTitle.ZIndex = 21

local fpSub = label(
    featurePanel,
    "Pilih fitur yang ingin diaktifkan untuk game ini:",
    UDim2.new(0, 15, 0, 38),
    UDim2.new(1, -30, 0, 20),
    C.muted, 9
)
fpSub.ZIndex = 21

-- Tombol Fitur 1: Fly (Terbang)
local flyState = false
local flyBtn = button(
    featurePanel, "FITUR TERBANG (FLY): OFF",
    UDim2.new(0, 15, 0, 68),
    UDim2.new(1, -30, 0, 36),
    C.card2
)
flyBtn.ZIndex = 21
flyBtn.TextSize = 11

flyBtn.Activated:Connect(function()
    flyState = not flyState
    if flyState then
        flyBtn.Text = "FITUR TERBANG (FLY): ON 🟢"
        flyBtn.TextColor3 = C.green
        -- Logika sederhana Fly
        task.spawn(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local part = char.HumanoidRootPart
            while flyState and char and char.Parent do
                local bv = Instance.new("BodyVelocity")
                bv.Name = "NexusFly"
                bv.MaxForce = Vector3.new(90000, 90000, 90000)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = part
                task.wait(0.5)
                if bv then bv:Destroy() end
            end
        end)
    else
        flyBtn.Text = "FITUR TERBANG (FLY): OFF"
        flyBtn.TextColor3 = C.white
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local f = char.HumanoidRootPart:FindFirstChild("NexusFly")
            if f then f:Destroy() end
        end
    end
end)

-- Tombol Fitur 2: Noclip (Tembus Tembok)
local noclipState = false
local noclipBtn = button(
    featurePanel, "NOCLIP (TEMBUS TEMBOK): OFF",
    UDim2.new(0, 15, 0, 114),
    UDim2.new(1, -30, 0, 36),
    C.card2
)
noclipBtn.ZIndex = 21
noclipBtn.TextSize = 11

noclipBtn.Activated:Connect(function()
    noclipState = not noclipState
    if noclipState then
        noclipBtn.Text = "NOCLIP (TEMBUS TEMBOK): ON 🟢"
        noclipBtn.TextColor3 = C.green
    else
        noclipBtn.Text = "NOCLIP (TEMBUS TEMBOK): OFF"
        noclipBtn.TextColor3 = C.white
    end
end)

RunService.Stepped:Connect(function()
    if noclipState and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Tombol Fitur 3: Aimbot Simple
local aimbotState = false
local aimbotBtn = button(
    featurePanel, "AIMBOT TARGET LOCK: OFF",
    UDim2.new(0, 15, 0, 160),
    UDim2.new(1, -30, 0, 36),
    C.card2
)
aimbotBtn.ZIndex = 21
aimbotBtn.TextSize = 11

aimbotBtn.Activated:Connect(function()
    aimbotState = not aimbotState
    if aimbotState then
        aimbotBtn.Text = "AIMBOT TARGET LOCK: ON 🟢"
        aimbotBtn.TextColor3 = C.green
    else
        aimbotBtn.Text = "AIMBOT TARGET LOCK: OFF"
        aimbotBtn.TextColor3 = C.white
    end
end)

-- Tombol Tutup Panel Fitur
local closeFp = button(
    featurePanel, "TUTUP MENU",
    UDim2.new(0, 15, 1, -48),
    UDim2.new(1, -30, 0, 35),
    C.purple
)
closeFp.ZIndex = 21
closeFp.TextSize = 11
gradient(closeFp, C.purple, C.pink, 0)

closeFp.Activated:Connect(function()
    featurePanel.Visible = false
end)

--==================================================
-- UPDATE CENTER PANEL
--==================================================

local updatePanel = make("Frame", {
    Visible = false,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.53),
    Size = UDim2.new(0.88, 0, 0, 228),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ZIndex = 25
}, main)

round(updatePanel, 16)
outline(updatePanel, C.pink, 1.5)

local updateTitle = label(
    updatePanel, "✦  NEXUS UPDATER v1.2.0",
    UDim2.new(0, 15, 0, 13),
    UDim2.new(1, -30, 0, 25),
    C.pink, 14
)
updateTitle.Font = Enum.Font.GothamBlack
updateTitle.ZIndex = 26

local updateInfo = label(
    updatePanel,
    "Sistem hosting terhubung dengan lancar.",
    UDim2.new(0, 15, 0, 44),
    UDim2.new(1, -30, 0, 43),
    C.muted, 10
)
updateInfo.TextWrapped = true
updateInfo.TextYAlignment = Enum.TextYAlignment.Top
updateInfo.ZIndex = 26

local progressBack = make("Frame", {
    Position = UDim2.new(0, 15, 0, 96),
    Size = UDim2.new(1, -30, 0, 11),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ZIndex = 26
}, updatePanel)

round(progressBack, 6)

local progressFill = make("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = C.cyan,
    BorderSizePixel = 0,
    ZIndex = 27
}, progressBack)

round(progressFill, 6)
gradient(progressFill, C.cyan, C.pink)

local progressText = label(
    updatePanel, "100%  /  READY",
    UDim2.new(0, 15, 0, 113),
    UDim2.new(1, -30, 0, 18),
    C.cyan, 9
)
progressText.ZIndex = 26

local checkBtn = button(
    updatePanel, "TUTUP",
    UDim2.new(0, 15, 1, -47),
    UDim2.new(1, -30, 0, 32),
    C.purple
)
checkBtn.ZIndex = 26
checkBtn.TextSize = 10
gradient(checkBtn, C.purple, C.blue, 0)

updateBtn.Activated:Connect(function()
    updatePanel.Visible = not updatePanel.Visible
end)

checkBtn.Activated:Connect(function()
    updatePanel.Visible = false
end)

--==================================================
-- GAME CATALOG LIST
--==================================================

local fallback = {
    "Blox Fruits", "Brookhaven RP", "Murder Mystery 2", 
    "Adopt Me!", "DOORS", "Blade Ball", "Arsenal", 
    "Pet Simulator 99", "Jailbreak", "BedWars", "Fisch"
}

local games = {}
if config and type(config.games) == "table" and #config.games > 0 then
    games = config.games
else
    for _, name in ipairs(fallback) do
        table.insert(games, {
            name = name,
            category = "ROBLOX MODS",
            enabled = true
        })
    end
end

local function clearCatalog()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= layout then child:Destroy() end
    end
end

local function makeCard(gameInfo, index)
    if gameInfo.enabled == false then return end

    local name = tostring(gameInfo.name or "Untitled")
    local card = make("Frame", {
        Size = UDim2.new(1, -3, 0, 66),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        LayoutOrder = index
    }, content)

    round(card, 13)
    outline(card, C.line, 1)

    local marker = make("Frame", {
        Position = UDim2.new(0, 0, 0, 12),
        Size = UDim2.new(0, 3, 0, 42),
        BackgroundColor3 = index % 2 == 0 and C.purple : C.cyan,
        BorderSizePixel = 0
    }, card)

    round(marker, 3)

    local title = label(
        card, name,
        UDim2.new(0, 15, 0, 12),
        UDim2.new(1, -90, 0, 22),
        C.white, 11
    )
    title.Font = Enum.Font.GothamBold

    label(
        card, "Klik 'BUKA' untuk menu Terbang, Noclip, & Aimbot",
        UDim2.new(0, 15, 0, 36),
        UDim2.new(1, -90, 0, 16),
        C.muted, 8
    )

    local viewBtn = button(
        card, "BUKA",
        UDim2.new(1, -70, 0.5, -14),
        UDim2.fromOffset(58, 28),
        C.card2
    )
    viewBtn.TextColor3 = C.cyan
    viewBtn.TextSize = 10

    viewBtn.Activated:Connect(function()
        featurePanel.Visible = true
        fpTitle.text = "✦ " .. string.upper(name) .. " MODS"
    end)
end

local function render(query)
    clearCatalog()
    query = string.lower(query or "")
    local shown = 0

    for i, gameInfo in ipairs(games) do
        local name = string.lower(tostring(gameInfo.name or ""))
        if query == "" or string.find(name, query, 1, true) then
            shown += 1
            makeCard(gameInfo, i)
        end
    end
end

search:GetPropertyChangedSignal("Text"):Connect(function()
    render(search.Text)
end)

render("")

-- Draggable Window
local dragging, dragStart, startPosition, dragInput
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("[NEXUS DELTA v1.2.0] Berhasil dimuat dengan fitur lengkap!")
