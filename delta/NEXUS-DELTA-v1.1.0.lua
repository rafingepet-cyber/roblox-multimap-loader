--[[
╔══════════════════════════════════════════════╗
║           N E X U S   D E L T A              ║
║        NEON CATALOG • VERSION CENTER          ║
║                UI VERSION 1.3.0               ║
╚══════════════════════════════════════════════╝

UI-only catalog. No gameplay cheats or automation.
]]

local VERSION = "1.1.0"
local API_URL = "https://nebul.rf.gd/api.php"
local GITHUB_URL =
    "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- NEON PALETTE
--==================================================

local C = {
    bg       = Color3.fromRGB(13, 17, 34),
    panel    = Color3.fromRGB(23, 29, 54),
    card     = Color3.fromRGB(29, 37, 66),
    card2    = Color3.fromRGB(36, 45, 79),
    white    = Color3.fromRGB(246, 249, 255),
    muted    = Color3.fromRGB(163, 178, 208),
    cyan     = Color3.fromRGB(53, 239, 255),
    blue     = Color3.fromRGB(77, 137, 255),
    purple   = Color3.fromRGB(177, 91, 255),
    pink     = Color3.fromRGB(255, 86, 190),
    green    = Color3.fromRGB(81, 255, 174),
    orange   = Color3.fromRGB(255, 190, 88),
    line     = Color3.fromRGB(76, 101, 158),
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
        Transparency = 0.12
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
outline(main, C.cyan, 1.5)
make("UISizeConstraint", {
    MinSize = Vector2.new(300, 410),
    MaxSize = Vector2.new(580, 700)
}, main)

-- Neon accent strip
local accent = make("Frame", {
    Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = C.cyan,
    BorderSizePixel = 0,
    ZIndex = 5
}, main)

gradient(accent, C.cyan, C.pink, 0)

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
gradient(logo, C.purple, C.blue, 45)
outline(logo, C.cyan, 1)

make("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "N",
    Font = Enum.Font.GothamBlack,
    TextSize = 26,
    TextColor3 = C.white
}, logo)

label(
    header,
    (config and tostring(config.brand)) or "NEXUS",
    UDim2.new(0, 64, 0, 12),
    UDim2.new(1, -125, 0, 26),
    C.white,
    19
).Font = Enum.Font.GothamBlack

label(
    header,
    "NEON INTERFACE  /  v" .. VERSION,
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
-- BODY + TOP STATUS
--==================================================

local body = make("Frame", {
    Position = UDim2.new(0, 0, 0, 76),
    Size = UDim2.new(1, 0, 1, -76),
    BackgroundTransparency = 1
}, main)

local experience = label(
    body, "EXPERIENCE  /  LOADING",
    UDim2.new(0, 15, 0, 8),
    UDim2.new(1, -130, 0, 22),
    C.cyan, 10
)
experience.Font = Enum.Font.GothamBold

local updateBtn = button(
    body, "↻ UPDATE",
    UDim2.new(1, -105, 0, 7),
    UDim2.fromOffset(90, 26),
    C.card
)
updateBtn.TextColor3 = C.cyan
updateBtn.TextSize = 9

local search = make("TextBox", {
    Position = UDim2.new(0, 14, 0, 37),
    Size = UDim2.new(1, -28, 0, 39),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "  ⌕   Search game catalog...",
    PlaceholderColor3 = C.muted,
    TextColor3 = C.white,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    ClearTextOnFocus = false
}, body)

round(search, 11)
outline(search, C.line, 1)

local catalogTitle = label(
    body, "GAME CATALOG",
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
    ScrollBarImageColor3 = C.cyan,
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
    body, "●  READY",
    UDim2.new(0, 15, 1, -31),
    UDim2.new(1, -30, 0, 20),
    C.green, 9
)

--==================================================
-- UPDATE CENTER
--==================================================

local updatePanel = make("Frame", {
    Visible = false,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.53),
    Size = UDim2.new(0.88, 0, 0, 228),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ZIndex = 20
}, main)

round(updatePanel, 16)
outline(updatePanel, C.purple, 1.5)

local updateTitle = label(
    updatePanel, "✦  NEXUS UPDATE CENTER",
    UDim2.new(0, 15, 0, 13),
    UDim2.new(1, -30, 0, 25),
    C.cyan, 14
)
updateTitle.Font = Enum.Font.GothamBlack
updateTitle.ZIndex = 21

local updateInfo = label(
    updatePanel,
    "Check the hosting version before updating.",
    UDim2.new(0, 15, 0, 44),
    UDim2.new(1, -30, 0, 43),
    C.muted, 10
)
updateInfo.TextWrapped = true
updateInfo.TextYAlignment = Enum.TextYAlignment.Top
updateInfo.ZIndex = 21

local progressBack = make("Frame", {
    Position = UDim2.new(0, 15, 0, 96),
    Size = UDim2.new(1, -30, 0, 11),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ZIndex = 21
}, updatePanel)

round(progressBack, 6)

local progressFill = make("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = C.cyan,
    BorderSizePixel = 0,
    ZIndex = 22
}, progressBack)

round(progressFill, 6)
gradient(progressFill, C.cyan, C.pink)

local progressText = label(
    updatePanel, "0%  /  NOT STARTED",
    UDim2.new(0, 15, 0, 113),
    UDim2.new(1, -30, 0, 18),
    C.cyan, 9
)
progressText.ZIndex = 21

local checkBtn = button(
    updatePanel, "CHECK FOR UPDATE",
    UDim2.new(0, 15, 1, -47),
    UDim2.new(1, -30, 0, 32),
    C.purple
)
checkBtn.ZIndex = 21
checkBtn.TextSize = 10
gradient(checkBtn, C.purple, C.blue, 0)

local busy = false
local minVersion = "1.3.0"

local function setProgress(percent, text)
    percent = math.clamp(percent, 0, 100)

    animate(progressFill, {
        Size = UDim2.new(percent / 100, 0, 1, 0)
    }, 0.2)

    progressText.Text = string.format(
        "%d%%  /  %s", percent, string.upper(text)
    )
end

updateBtn.Activated:Connect(function()
    updatePanel.Visible = not updatePanel.Visible

    if updatePanel.Visible then
        updateInfo.Text =
            "Checks hosting version only. This is not a file download."
        animate(updatePanel, {
            Position = UDim2.fromScale(0.5, 0.5)
        }, 0.18)
    end
end)

checkBtn.Activated:Connect(function()
    if busy then return end
    busy = true
    checkBtn.Text = "CHECKING..."
    setProgress(0, "connecting")

    task.spawn(function()
        setProgress(20, "connecting")
        local latest, err = fetchConfig()

        if not latest then
            setProgress(100, "failed")
            updateInfo.Text = tostring(err)
            checkBtn.Text = "RETRY"
            busy = false
            return
        end

        setProgress(60, "validating")
        task.wait(0.15)

        local remoteVersion = tostring(latest.version or VERSION)
        minVersion = tostring(latest.minimumVersion or "1.3.0")

        if compareVersion(VERSION, minVersion) < 0 then
            setProgress(100, "update required")
            updateInfo.Text =
                "This version is below minimum " .. minVersion ..
                ". Open the trusted GitHub source and install the new version.\n" ..
                GITHUB_URL
            checkBtn.Text = "COPY SOURCE URL"

        elseif compareVersion(remoteVersion, VERSION) > 0 then
            setProgress(100, "update available")
            updateInfo.Text =
                "Latest: " .. remoteVersion ..
                " | Installed: " .. VERSION ..
                "\nA newer script is available. This check does not download it.\n" ..
                GITHUB_URL
            checkBtn.Text = "COPY SOURCE URL"

        else
            setProgress(100, "up to date")
            updateInfo.Text =
                "NEXUS is up to date.\nInstalled: " .. VERSION ..
                " | Hosting: " .. remoteVersion
            checkBtn.Text = "CHECK AGAIN"
        end

        busy = false
    end)
end)

--==================================================
-- GAME CATALOG
--==================================================

local fallback = {
    "Adopt Me!", "Blox Fruits", "Brookhaven RP",
    "Murder Mystery 2", "DOORS", "Blade Ball",
    "Arsenal", "Pet Simulator 99", "Tower of Hell",
    "Jailbreak", "BedWars", "Evade",
    "Natural Disaster Survival", "Dress To Impress",
    "The Strongest Battlegrounds", "Shindo Life",
    "Anime Adventures", "King Legacy", "Piggy",
    "Rainbow Friends", "Build A Boat For Treasure",
    "Royale High", "MeepCity", "Welcome to Bloxburg",
    "Phantom Forces", "Combat Warriors", "Fisch",
    "Bee Swarm Simulator", "Theme Park Tycoon 2",
    "Restaurant Tycoon 2", "Work at a Pizza Place",
    "Epic Minigames", "Breaking Point",
    "Catalog Avatar Creator", "Speed Run 4"
}

local games = {}

if config and type(config.games) == "table" and #config.games > 0 then
    games = config.games
else
    for _, name in ipairs(fallback) do
        table.insert(games, {
            name = name,
            category = "ROBLOX",
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
        BackgroundColor3 = index % 2 == 0 and C.pink or C.cyan,
        BorderSizePixel = 0
    }, card)

    round(marker, 3)

    local icon = make("Frame", {
        Position = UDim2.new(0, 11, 0.5, -17),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = C.card2,
        BorderSizePixel = 0
    }, card)

    round(icon, 10)
    outline(icon, index % 2 == 0 and C.pink or C.cyan, 1)

    make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = string.format("%02d", index),
        Font = Enum.Font.GothamBlack,
        TextSize = 10,
        TextColor3 = index % 2 == 0 and C.pink or C.cyan
    }, icon)

    local title = label(
        card, name,
        UDim2.new(0, 55, 0, 10),
        UDim2.new(1, -120, 0, 22),
        C.white, 11
    )
    title.Font = Enum.Font.GothamBold
    title.TextTruncate = Enum.TextTruncate.AtEnd

    label(
        card, tostring(gameInfo.category or "GAME PROFILE"),
        UDim2.new(0, 55, 0, 34),
        UDim2.new(1, -120, 0, 17),
        C.muted, 8
    )

    local view = button(
        card, "VIEW",
        UDim2.new(1, -55, 0.5, -14),
        UDim2.fromOffset(45, 28),
        C.card2
    )

    view.TextColor3 = C.cyan
    view.TextSize = 9

    view.Activated:Connect(function()
        updatePanel.Visible = true
        updateTitle.Text = "✦  GAME PROFILE"
        updateInfo.Text =
            name ..
            "\nPlaceId: " .. tostring(gameInfo.placeId or "Not supplied") ..
            "\nCategory: " .. tostring(gameInfo.category or "ROBLOX") ..
            "\nCatalog information only."
        setProgress(100, "profile selected")
        checkBtn.Text = "CHECK FOR UPDATE"

        animate(card, {
            BackgroundColor3 = C.card2
        }, 0.12)

        task.delay(0.25, function()
            if card.Parent then
                animate(card, {
                    BackgroundColor3 = C.card
                }, 0.2)
            end
        end)
    end)
end

local function render(query)
    clearCatalog()

    query = string.lower(query or "")
    local shown = 0

    for i, gameInfo in ipairs(games) do
        local name = string.lower(tostring(gameInfo.name or ""))

        if gameInfo.enabled ~= false
            and (query == "" or string.find(name, query, 1, true)) then
            shown += 1
            makeCard(gameInfo, i)
        end
    end

    if shown == 0 then
        label(
            content, "No games found. Try another search.",
            UDim2.new(), UDim2.new(1, 0, 0, 45), C.muted, 11
        )
    end

    status.Text = string.format(
        "●  %02d ENTRIES   /   v%s",
        shown, tostring(config and config.version or VERSION)
    )
    status.TextColor3 = C.green
end

search:GetPropertyChangedSignal("Text"):Connect(function()
    render(search.Text)
end)

render("")

-- Current experience label
local currentGame = "UNKNOWN EXPERIENCE"
if config and type(config.games) == "table" then
    for _, entry in ipairs(config.games) do
        if tostring(entry.placeId or "") == tostring(game.PlaceId) then
            currentGame = tostring(entry.name or currentGame)
            break
        end
    end
end

experience.Text = "EXPERIENCE  /  " .. string.upper(currentGame)

if not config then
    status.Text = "●  OFFLINE CATALOG  /  " .. tostring(configError)
    status.TextColor3 = C.orange
end

--==================================================
-- DRAG SUPPORT: TOUCH + MOUSE
--==================================================

local dragging = false
local dragStart
local startPosition
local dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Entrance animation
local finalSize = main.Size
main.Size = UDim2.new(0.82, 0, 0.68, 0)
main.BackgroundTransparency = 0.2

animate(main, {
    Size = finalSize,
    BackgroundTransparency = 0
}, 0.32)

print("[NEXUS DELTA] Neon UI loaded • v" .. VERSION)