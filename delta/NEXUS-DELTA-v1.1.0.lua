--[[
╔══════════════════════════════════════════════╗
║           N E X U S   D E L T A              ║
║    NEON CATALOG • FEATURE HUB • v1.1.0       ║
║             UPDATE GUARD SYSTEM              ║
╚══════════════════════════════════════════════╝
]]

local VERSION = "1.1.0"
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
-- SYSTEM 1: MANDATORY UPDATE LOCK SCREEN (v1.1.0 OUTDATED)
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

    return -- Hentikan eksekusi di v1.1.0!
end

--==================================================
-- SYSTEM 2: MAIN MENU (JIKA TIDAK KADALUARSA)
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

print("[NEXUS DELTA v" .. VERSION .. "] Script v1.1.0 berjalan!")
