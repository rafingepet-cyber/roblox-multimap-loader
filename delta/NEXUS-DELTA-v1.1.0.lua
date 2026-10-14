--[[
  NEXUS DELTA • Update System v1.1.0
  Dialog update clean + progress asli (download dicek dulu sebelum dijalankan)
]]

local VERSION = "1.1.0"
local API_URL = "https://nebul.rf.gd/api.php"
local LATEST_SCRIPT_URL = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA-v1.2.0.lua"

-- true  = ada tombol "Nanti saja" (update opsional)
-- false = update wajib (dialog tidak bisa ditutup)
local ALLOW_SKIP = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- TEMA
--==================================================
local C = {
    bg     = Color3.fromRGB(14, 17, 30),
    card   = Color3.fromRGB(22, 27, 46),
    line   = Color3.fromRGB(42, 50, 82),
    white  = Color3.fromRGB(245, 248, 255),
    muted  = Color3.fromRGB(135, 148, 178),
    cyan   = Color3.fromRGB(0, 229, 255),
    purple = Color3.fromRGB(150, 90, 255),
    green  = Color3.fromRGB(70, 235, 150),
    red    = Color3.fromRGB(255, 95, 110),
}

--==================================================
-- CEK VERSI
--==================================================
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

if not isOutdated(VERSION, requiredVersion) then
    print("[NEXUS] Versi sudah terbaru.")
    return
end

--==================================================
-- HELPER UI
--==================================================
local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    inst.Parent = parent
    return inst
end

local function round(parent, radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function rgbTag(c)
    return string.format("rgb(%d,%d,%d)", c.R * 255, c.G * 255, c.B * 255)
end

--==================================================
-- BUILD UI
--==================================================
local old = playerGui:FindFirstChild("NEXUS_DELTA")
if old then old:Destroy() end

local gui = make("ScreenGui", {
    Name = "NEXUS_DELTA",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
}, playerGui)

-- Overlay gelap di belakang dialog
local overlay = make("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = true,
}, gui)

local CARD_H = ALLOW_SKIP and 300 or 258

local card = make("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(330, CARD_H),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    GroupTransparency = 1,
}, overlay)
round(card, 20)
make("UIStroke", {Color = C.line, Thickness = 1}, card)
local cardScale = make("UIScale", {Scale = 0.92}, card)

-- Garis aksen tipis di atas
local accent = make("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
}, card)
make("UIGradient", {
    Color = ColorSequence.new(C.purple, C.cyan),
}, accent)

-- Header: ikon + judul
local badge = make("Frame", {
    Position = UDim2.fromOffset(20, 24),
    Size = UDim2.fromOffset(42, 42),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
}, card)
round(badge, 12)
make("UIGradient", {
    Color = ColorSequence.new(C.purple, C.cyan),
    Rotation = 45,
}, badge)
make("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "↑",
    Font = Enum.Font.GothamBlack,
    TextSize = 24,
    TextColor3 = Color3.new(1, 1, 1),
}, badge)

make("TextLabel", {
    Position = UDim2.fromOffset(74, 24),
    Size = UDim2.new(1, -94, 0, 22),
    BackgroundTransparency = 1,
    Text = "Update Tersedia",
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = C.white,
    TextXAlignment = Enum.TextXAlignment.Left,
}, card)

make("TextLabel", {
    Position = UDim2.fromOffset(74, 47),
    Size = UDim2.new(1, -94, 0, 18),
    BackgroundTransparency = 1,
    Text = "NEXUS DELTA",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = C.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, card)

-- Baris versi: sekarang -> terbaru
local row = make("Frame", {
    Position = UDim2.fromOffset(20, 84),
    Size = UDim2.new(1, -40, 0, 54),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0,
}, card)
round(row, 14)

local function versionLabel(xScale, caption, ver, color)
    make("TextLabel", {
        Position = UDim2.fromScale(xScale, 0),
        Size = UDim2.fromScale(0.4, 1),
        BackgroundTransparency = 1,
        RichText = true,
        Text = string.format(
            '<font size="9" color="%s">%s</font>\n<font size="16" color="%s"><b>v%s</b></font>',
            rgbTag(C.muted), caption, rgbTag(color), ver
        ),
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = C.white,
    }, row)
end

versionLabel(0, "SEKARANG", VERSION, C.muted)
make("TextLabel", {
    Position = UDim2.fromScale(0.4, 0),
    Size = UDim2.fromScale(0.2, 1),
    BackgroundTransparency = 1,
    Text = "→",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = C.cyan,
}, row)
versionLabel(0.6, "TERBARU", requiredVersion, C.green)

-- Progress bar
local barBack = make("Frame", {
    Position = UDim2.fromOffset(20, 158),
    Size = UDim2.new(1, -40, 0, 6),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0,
}, card)
round(barBack, 3)

local barFill = make("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
}, barBack)
round(barFill, 3)
make("UIGradient", {Color = ColorSequence.new(C.purple, C.cyan)}, barFill)

local statusLbl = make("TextLabel", {
    Position = UDim2.fromOffset(20, 170),
    Size = UDim2.new(1, -90, 0, 18),
    BackgroundTransparency = 1,
    Text = "Siap untuk update",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = C.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, card)

local percentLbl = make("TextLabel", {
    Position = UDim2.new(1, -70, 0, 170),
    Size = UDim2.fromOffset(50, 18),
    BackgroundTransparency = 1,
    Text = "0%",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = C.cyan,
    TextXAlignment = Enum.TextXAlignment.Right,
}, card)

-- Tombol utama
local updateBtn = make("TextButton", {
    Position = UDim2.fromOffset(20, 200),
    Size = UDim2.new(1, -40, 0, 46),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
    Text = "Update Sekarang",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.new(1, 1, 1),
    AutoButtonColor = false,
}, card)
round(updateBtn, 13)
make("UIGradient", {Color = ColorSequence.new(C.purple, C.cyan)}, updateBtn)
local btnScale = make("UIScale", {Scale = 1}, updateBtn)

updateBtn.MouseButton1Down:Connect(function()
    tween(btnScale, 0.1, {Scale = 0.96})
end)
local function releaseBtn()
    tween(btnScale, 0.15, {Scale = 1}, Enum.EasingStyle.Back)
end
updateBtn.MouseButton1Up:Connect(releaseBtn)
updateBtn.MouseLeave:Connect(releaseBtn)

-- Tombol "Nanti saja" (opsional)
local skipBtn
if ALLOW_SKIP then
    skipBtn = make("TextButton", {
        Position = UDim2.fromOffset(20, 254),
        Size = UDim2.new(1, -40, 0, 30),
        BackgroundTransparency = 1,
        Text = "Nanti saja",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = C.muted,
        AutoButtonColor = false,
    }, card)
end

--==================================================
-- ANIMASI BUKA / TUTUP
--==================================================
local function openAnim()
    tween(overlay, 0.3, {BackgroundTransparency = 0.45})
    tween(card, 0.3, {GroupTransparency = 0})
    tween(cardScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
end

local function closeAnim()
    tween(card, 0.25, {GroupTransparency = 1})
    tween(cardScale, 0.25, {Scale = 0.92}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    tween(overlay, 0.3, {BackgroundTransparency = 1})
    task.wait(0.35)
    gui:Destroy()
end

openAnim()

--==================================================
-- PROSES UPDATE
--==================================================
local function setProgress(p, text, color)
    tween(barFill, 0.35, {Size = UDim2.fromScale(p, 1)})
    percentLbl.Text = math.floor(p * 100) .. "%"
    if text then statusLbl.Text = text end
    statusLbl.TextColor3 = color or C.muted
end

local isUpdating = false

updateBtn.Activated:Connect(function()
    if isUpdating then return end
    isUpdating = true
    updateBtn.Text = "Mengunduh..."
    tween(updateBtn, 0.2, {BackgroundTransparency = 0.35})

    task.spawn(function()
        setProgress(0.2, "Menghubungkan ke GitHub...")
        task.wait(0.3)

        -- Download asli
        local ok, src = pcall(function()
            return game:HttpGet(LATEST_SCRIPT_URL .. "?v=" .. tick())
        end)

        if not ok or type(src) ~= "string" or #src < 20 then
            setProgress(0, "Gagal mengunduh. Cek koneksi lalu coba lagi.", C.red)
            updateBtn.Text = "Coba Lagi"
            tween(updateBtn, 0.2, {BackgroundTransparency = 0})
            isUpdating = false
            return
        end

        setProgress(0.6, "Memeriksa script...")
        task.wait(0.3)

        local fn, compileErr = loadstring(src)
        if not fn then
            warn("[NEXUS] Script tidak valid: " .. tostring(compileErr))
            setProgress(0, "Script terbaru tidak valid.", C.red)
            updateBtn.Text = "Coba Lagi"
            tween(updateBtn, 0.2, {BackgroundTransparency = 0})
            isUpdating = false
            return
        end

        -- Salin loadstring ke clipboard (kalau executor mendukung)
        if setclipboard then
            pcall(setclipboard, 'loadstring(game:HttpGet("' .. LATEST_SCRIPT_URL .. '"))()')
        end

        setProgress(1, "Update selesai!", C.green)
        updateBtn.Text = "Selesai"
        task.wait(0.7)

        closeAnim()

        local runOk, runErr = pcall(fn)
        if not runOk then
            warn("[NEXUS] Gagal menjalankan v" .. requiredVersion .. ": " .. tostring(runErr))
        end
    end)
end)

if skipBtn then
    skipBtn.Activated:Connect(function()
        if isUpdating then return end
        closeAnim()
    end)
end
