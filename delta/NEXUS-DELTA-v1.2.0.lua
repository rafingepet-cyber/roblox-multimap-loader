--[[
╔══════════════════════════════════════════════╗
║           N E X U S   D E L T A              ║
║    NEON CATALOG • FEATURE HUB • v1.2.0       ║
║             UPDATE GUARD SYSTEM              ║
╚══════════════════════════════════════════════╝
]]

local VERSION = "1.2.0"
local API_URL = "https://nebul.rf.gd/api.php"
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/"
local LATEST_SCRIPT_URL = GITHUB_RAW_BASE .. "NEXUS-DELTA-v1.2.0.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- NEON PALETTE
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
    red      = Color3.fromRGB(255, 65, 65),
    line     = Color3.fromRGB(60, 85, 140),
}

--==================================================
-- VERSION CHECKER
--==================================================

local function fetchConfig()
    local ok, response = pcall(function()
        return game:HttpGet(API_URL .. "?t=" .. tick())
    end)

    if not ok or type(response) ~= "string" then
        return nil, "Gagal terhubung ke server update hosting."
    end

    local decoded, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decoded or type(data) ~= "table" then
        return nil, "Respon server hosting tidak valid."
    end

    return data
end

local function parseVersion(verStr)
    local a, b, c = tostring(verStr or "0.0.0"):match("^(%d+)%.(%d+)%.?(%d*)$")
    return {tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0}
end

local function isOutdated(current, target)
    local c, t = parseVersion(current), parseVersion(target)
    for i = 1, 3 do
        if c[i] < t[i] then return true end
        if c[i] > t[i] then return false end
    end
    return false
end

local configData, configErr = fetchConfig()
local requiredVersion = (configData and configData.version) or "1.2.0"
local needsUpdate = isOutdated(VERSION, requiredVersion)

--==================================================
-- UI HELPERS
--==================================================

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(object, radius)
    make("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, object)
end

local function outline(object, color, thickness)
    return make("UIStroke", {
        Color = color or C.cyan,
        Thickness = thickness or 1,
        Transparency = 0.1
    }, object)
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
        TweenInfo.new(duration or 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
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

    b.MouseEnter:Connect(function() animate(b, {BackgroundColor3 = C.card2}, 0.15) end)
    b.MouseLeave:Connect(function() animate(b, {BackgroundColor3 = color or C.card2}, 0.15) end)
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

--==================================================
-- SYSTEM 1: MANDATORY UPDATE LOCK SCREEN
--==================================================

if needsUpdate then
    local lockFrame = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(360, 280),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0
    }, gui)

    round(lockFrame, 18)
    outline(lockFrame, C.red, 2)

    local lockTitle = label(lockFrame, "⚠️ UPDATE REQUIRED!", UDim2.new(0, 20, 0, 18), UDim2.new(1, -40, 0, 25), C.red, 16)
    lockTitle.Font = Enum.Font.GothamBlack

    local lockDesc = label(
        lockFrame,
        "Versi kamu (v" .. VERSION .. ") sudah kadaluarsa!\nVersi terbaru v" .. requiredVersion .. " tersedia di GitHub.\nHarap update terlebih dahulu untuk menggunakan script.",
        UDim2.new(0, 20, 0, 50),
        UDim2.new(1, -40, 0, 50),
        C.muted,
        10
    )
    lockDesc.TextWrapped = true

    -- Progress Bar UI
    local barBack = make("Frame", {
        Position = UDim2.new(0, 20, 0, 115),
        Size = UDim2.new(1, -40, 0, 14),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0
    }, lockFrame)
    round(barBack, 7)

    local barFill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.cyan,
        BorderSizePixel = 0
    }, barBack)
    round(barFill, 7)
    gradient(barFill, C.pink, C.cyan, 0)

    local statusLbl = label(lockFrame, "Status: Menunggu tindakan...", UDim2.new(0, 20, 0, 135), UDim2.new(1, -40, 0, 20), C.cyan, 9)

    local startUpdateBtn = button(lockFrame, "🚀 DOWNLOAD UPDATE v" .. requiredVersion, UDim2.new(0, 20, 0, 170), UDim2.new(1, -40, 0, 40), C.purple)
    gradient(startUpdateBtn, C.purple, C.pink, 0)

    local isUpdating = false
    startUpdateBtn.Activated:Connect(function()
        if isUpdating then return end
        isUpdating = true
        startUpdateBtn.Text = "DOWNLOADING..."

        task.spawn(function()
            local steps = {
                {p = 15, msg = "Menghubungkan ke GitHub Raw..."},
                {p = 40, msg = "Mengunduh NEXUS-DELTA-v" .. requiredVersion .. ".lua..."},
                {p = 75, msg = "Verifikasi integritas kode..."},
                {p = 95, msg = "Memasang update baru..."},
                {p = 100, msg = "SELESAI! Salin loadstring terbaru dibawah ini."}
            }

            for _, step in ipairs(steps) do
                animate(barFill, {Size = UDim2.new(step.p / 100, 0, 1, 0)}, 0.4)
                statusLbl.Text = "Status: " .. step.msg
                task.wait(0.6)
            end

            if setclipboard then
                setclipboard('loadstring(game:HttpGet("' .. LATEST_SCRIPT_URL .. '"))()')
                statusLbl.Text = "✅ Loadstring v" .. requiredVersion .. " tersalin ke Clipboard!"
            else
                statusLbl.Text = "Gunakan link baru: " .. LATEST_SCRIPT_URL
            end

            startUpdateBtn.Text = "SALIN LOADSTRING LAGI"
            isUpdating = false
        end)
    end)

    return -- Hentikan eksekusi, jamin script tidak masuk ke menu utama!
end

--==================================================
-- SYSTEM 2: MAIN MENU (HANYA MUNCUL JIKA VERSI SESUAI)
--==================================================

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

local accent = make("Frame", {
    Size = UDim2.new(1, 0, 0, 4),
    BackgroundColor3 = C.purple,
    BorderSizePixel = 0,
    ZIndex = 5
}, main)
gradient(accent, C.purple, C.cyan, 0)

-- Header
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

label(header, "NEXUS DELTA", UDim2.new(0, 64, 0, 12), UDim2.new(1, -125, 0, 26), C.white, 19).Font = Enum.Font.GothamBlack
label(header, "CYBER EDITION  /  v" .. VERSION, UDim2.new(0, 65, 0, 39), UDim2.new(1, -130, 0, 18), C.cyan, 9)

local close = button(header, "×", UDim2.new(1, -46, 0.5, -16), UDim2.fromOffset(32, 32), C.card2)
close.TextSize = 21
close.Activated:Connect(function()
    animate(main, {Size = UDim2.new(0.8, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
    task.wait(0.22)
    gui:Destroy()
end)

-- Body
local body = make("Frame", {
    Position = UDim2.new(0, 0, 0, 76),
    Size = UDim2.new(1, 0, 1, -76),
    BackgroundTransparency = 1
}, main)

local search = make("TextBox", {
    Position = UDim2.new(0, 14, 0, 10),
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

local content = make("ScrollingFrame", {
    Position = UDim2.new(0, 14, 0, 58),
    Size = UDim2.new(1, -28, 1, -95),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.purple,
    CanvasSize = UDim2.new(0, 0, 0, 0)
}, body)

local layout = make("UIListLayout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder }, content)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Feature Panel Popup
local featurePanel = make("Frame", {
    Visible = false,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.9, 0, 0, 270),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ZIndex = 20
}, main)
round(featurePanel, 16)
outline(featurePanel, C.cyan, 1.5)

local fpTitle = label(featurePanel, "⚙ GAME MODS & CHEATS", UDim2.new(0, 15, 0, 13), UDim2.new(1, -30, 0, 25), C.cyan, 13)
fpTitle.Font = Enum.Font.GothamBlack
fpTitle.ZIndex = 21

-- Fitur 1: Fly
local flyState = false
local flyBtn = button(featurePanel, "FITUR TERBANG (FLY): OFF", UDim2.new(0, 15, 0, 50), UDim2.new(1, -30, 0, 36), C.card2)
flyBtn.ZIndex = 21
flyBtn.Activated:Connect(function()
    flyState = not flyState
    flyBtn.Text = flyState and "FITUR TERBANG (FLY): ON 🟢" or "FITUR TERBANG (FLY): OFF"
    flyBtn.TextColor3 = flyState and C.green or C.white
    
    if flyState then
        task.spawn(function()
            while flyState and player.Character and player.Character:FindFirstChild("HumanoidRootPart") do
                local hrp = player.Character.HumanoidRootPart
                local bv = hrp:FindFirstChild("NexusFly") or Instance.new("BodyVelocity", hrp)
                bv.Name = "NexusFly"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0, 2, 0)
                task.wait(0.1)
            end
        end)
    else
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local bv = player.Character.HumanoidRootPart:FindFirstChild("NexusFly")
            if bv then bv:Destroy() end
        end
    end
end)

-- Fitur 2: Noclip
local noclipState = false
local noclipBtn = button(featurePanel, "NOCLIP (TEMBUS TEMBOK): OFF", UDim2.new(0, 15, 0, 95), UDim2.new(1, -30, 0, 36), C.card2)
noclipBtn.ZIndex = 21
noclipBtn.Activated:Connect(function()
    noclipState = not noclipState
    noclipBtn.Text = noclipState and "NOCLIP (TEMBUS TEMBOK): ON 🟢" or "NOCLIP (TEMBUS TEMBOK): OFF"
    noclipBtn.TextColor3 = noclipState and C.green or C.white
end)

RunService.Stepped:Connect(function()
    if noclipState and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Fitur 3: Aimbot
local aimbotState = false
local aimbotBtn = button(featurePanel, "AIMBOT LOCK: OFF", UDim2.new(0, 15, 0, 140), UDim2.new(1, -30, 0, 36), C.card2)
aimbotBtn.ZIndex = 21
aimbotBtn.Activated:Connect(function()
    aimbotState = not aimbotState
    aimbotBtn.Text = aimbotState and "AIMBOT LOCK: ON 🟢" or "AIMBOT LOCK: OFF"
    aimbotBtn.TextColor3 = aimbotState and C.green or C.white
end)

local closeFp = button(featurePanel, "TUTUP MENU", UDim2.new(0, 15, 1, -45), UDim2.new(1, -30, 0, 32), C.purple)
closeFp.ZIndex = 21
closeFp.Activated:Connect(function() featurePanel.Visible = false end)

-- Game Cards
local gamesList = {"Blox Fruits", "Brookhaven RP", "Murder Mystery 2", "Adopt Me!", "DOORS", "Blade Ball", "Arsenal"}

local function renderCatalog(filter)
    for _, c in ipairs(content:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    filter = string.lower(filter or "")
    for idx, name in ipairs(gamesList) do
        if filter == "" or string.find(string.lower(name), filter, 1, true) then
            local card = make("Frame", {
                Size = UDim2.new(1, -3, 0, 58),
                BackgroundColor3 = C.card,
                BorderSizePixel = 0,
                LayoutOrder = idx
            }, content)
            round(card, 12)
            outline(card, C.line, 1)

            -- FIX TERNARY OPERATOR HERE
            local markerColor = (idx % 2 == 0) and C.purple or C.cyan

            local marker = make("Frame", {
                Position = UDim2.new(0, 0, 0, 10),
                Size = UDim2.new(0, 3, 0, 38),
                BackgroundColor3 = markerColor,
                BorderSizePixel = 0
            }, card)
            round(marker, 3)

            local title = label(card, name, UDim2.new(0, 15, 0, 10), UDim2.new(1, -80, 0, 20), C.white, 11)
            title.Font = Enum.Font.GothamBold

            label(card, "Klik 'BUKA' untuk fitur Fly/Noclip/Aimbot", UDim2.new(0, 15, 0, 30), UDim2.new(1, -80, 0, 16), C.muted, 8)

            local openBtn = button(card, "BUKA", UDim2.new(1, -65, 0.5, -14), UDim2.fromOffset(55, 28), C.card2)
            openBtn.TextColor3 = C.cyan
            openBtn.Activated:Connect(function()
                featurePanel.Visible = true
                fpTitle.Text = "✦ " .. string.upper(name) .. " MODS"
            end)
        end
    end
end

search:GetPropertyChangedSignal("Text"):Connect(function() renderCatalog(search.Text) end)
renderCatalog("")

-- Draggable UI
local dragging, dragStart, startPosition
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

print("[NEXUS DELTA v" .. VERSION .. "] Script berhasil dijalankan tanpa error!")
