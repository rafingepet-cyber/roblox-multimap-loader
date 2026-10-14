--[[
╔══════════════════════════════════════════════╗
║           N E X U S   D E L T A              ║
║       AUTO-UPDATE & AUTO-RUN SYSTEM          ║
╚══════════════════════════════════════════════╝
]]

local VERSION = "1.1.0"
local API_URL = "https://nebul.rf.gd/api.php"
local LATEST_SCRIPT_URL = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA-v1.2.0.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Warna Neon
local C = {
    bg       = Color3.fromRGB(10, 14, 28),
    panel    = Color3.fromRGB(18, 24, 45),
    white    = Color3.fromRGB(255, 255, 255),
    muted    = Color3.fromRGB(140, 160, 195),
    cyan     = Color3.fromRGB(0, 245, 255),
    purple   = Color3.fromRGB(190, 60, 255),
    pink     = Color3.fromRGB(255, 45, 180),
    red      = Color3.fromRGB(255, 65, 65),
}

-- Cek Versi ke Hosting
local function fetchConfig()
    local ok, response = pcall(function()
        return game:HttpGet(API_URL .. "?t=" .. tick())
    end)
    if not ok or type(response) ~= "string" then return nil end
    local decoded, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not decoded or type(data) ~= "table" then return nil end
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

local configData = fetchConfig()
local requiredVersion = (configData and configData.version) or "1.2.0"
local needsUpdate = isOutdated(VERSION, requiredVersion)

-- Helper UI sederhana
local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- Bersihkan GUI lama
local old = playerGui:FindFirstChild("NEXUS_DELTA")
if old then old:Destroy() end

local gui = make("ScreenGui", {
    Name = "NEXUS_DELTA",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

-- Jika versi aman/terbaru, jalankan menu utama v1.1.0 (atau lewati)
if not needsUpdate then
    print("[NEXUS] Versi sudah paling baru.")
    return
end

-- ==========================================================
-- TAMPILAN UPDATE PAKSA + AUTO RUN & CLOSE UI LAMA
-- ==========================================================

local lockFrame = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(360, 260),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0
}, gui)

make("UICorner", { CornerRadius = UDim.new(0, 18) }, lockFrame)
make("UIStroke", { Color = C.red, Thickness = 2 }, lockFrame)

local title = make("TextLabel", {
    Position = UDim2.new(0, 20, 0, 18),
    Size = UDim2.new(1, -40, 0, 25),
    BackgroundTransparency = 1,
    Text = "🔄 AUTO-UPDATING NEXUS...",
    Font = Enum.Font.GothamBlack,
    TextSize = 14,
    TextColor3 = C.red
}, lockFrame)

local desc = make("TextLabel", {
    Position = UDim2.new(0, 20, 0, 50),
    Size = UDim2.new(1, -40, 0, 45),
    BackgroundTransparency = 1,
    Text = "Versi lama terdeteksi (v" .. VERSION .. ").\nMenyiapkan pembaruan otomatis ke v" .. requiredVersion .. "...",
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = C.muted,
    TextWrapped = true
}, lockFrame)

-- Progress Bar
local barBack = make("Frame", {
    Position = UDim2.new(0, 20, 0, 110),
    Size = UDim2.new(1, -40, 0, 14),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0
}, lockFrame)
make("UICorner", { CornerRadius = UDim.new(0, 7) }, barBack)

local barFill = make("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = C.cyan,
    BorderSizePixel = 0
}, barBack)
make("UICorner", { CornerRadius = UDim.new(0, 7) }, barFill)

local statusLbl = make("TextLabel", {
    Position = UDim2.new(0, 20, 0, 132),
    Size = UDim2.new(1, -40, 0, 20),
    BackgroundTransparency = 1,
    Text = "Status: Memulai...",
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextColor3 = C.cyan
}, lockFrame)

-- Proses Auto-Update di background
task.spawn(function()
    local steps = {
        {p = 20, msg = "Menghubungkan ke GitHub..."},
        {p = 50, msg = "Mengunduh script versi v" .. requiredVersion .. "..."},
        {p = 80, msg = "Menutup antarmuka versi lama..."},
        {p = 100, msg = "Berhasil! Menjalankan versi terbaru..."}
    }

    for _, step in ipairs(steps) do
        TweenService:Create(barFill, TweenInfo.new(0.4), {Size = UDim2.new(step.p / 100, 0, 1, 0)}):Play()
        statusLbl.Text = "Status: " .. step.msg
        task.wait(0.5)
    end

    task.wait(0.3)

    -- 1. Tutup/Hilangkan UI lama dari kamera user secara halus
    TweenService:Create(lockFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.35)
    gui:Destroy()

    -- 2. Auto-run script terbaru secara otomatis tanpa ribet
    local success, err = pcall(function()
        loadstring(game:HttpGet(LATEST_SCRIPT_URL .. "?t=" .. tick()))()
    end)

    if not success then
        warn("[NEXUS] Gagal auto-run script baru: " .. tostring(err))
    end
end)
