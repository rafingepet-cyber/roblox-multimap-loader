--[[
  NEXUS DELTA v1.3.0 • Smart Map Hub
  Menu otomatis menyesuaikan map: Brookhaven -> menu Brookhaven saja, dst.
  Map tidak dikenal -> mode Universal.
  Baru: langit, lagu, aura, kamera, karakter, utilitas (50 fitur) + 50 map baru.
]]

local VERSION = "1.3.0"
local API_URL = "https://nebul.rf.gd/api.php"
local GITHUB_URL = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA-v1.3.0.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- PALET
--==================================================
local C = {
    bg     = Color3.fromRGB(11, 14, 27),
    panel  = Color3.fromRGB(18, 23, 42),
    card   = Color3.fromRGB(24, 31, 56),
    card2  = Color3.fromRGB(36, 45, 80),
    white  = Color3.fromRGB(245, 248, 255),
    muted  = Color3.fromRGB(135, 150, 182),
    line   = Color3.fromRGB(48, 60, 100),
    cyan   = Color3.fromRGB(0, 229, 255),
    purple = Color3.fromRGB(160, 95, 255),
    pink   = Color3.fromRGB(255, 80, 180),
    green  = Color3.fromRGB(60, 235, 150),
    orange = Color3.fromRGB(255, 165, 60),
    blue   = Color3.fromRGB(70, 135, 255),
    red    = Color3.fromRGB(255, 95, 110),
}

--==================================================
-- PROFIL MAP (tampilan + fitur beda per map)
--==================================================
-- Tambah map baru: isi PLACE_IDS atau KEYWORDS, lalu buat profil di PROFILES.
local PLACE_IDS = {
    [4924922222] = "brookhaven",
    [920587237]  = "adoptme",
    [142823291]  = "mm2",
    [2753915549] = "bloxfruits",
    [4442272183] = "bloxfruits",
    [7449423635] = "bloxfruits",
}

-- 4 map lama + 50 map baru (dicocokkan lewat nama game)
local KEYWORDS = {
    {kw = "brookhaven", id = "brookhaven"}, {kw = "adopt me", id = "adoptme"},
    {kw = "murder mystery", id = "mm2"}, {kw = "blox fruits", id = "bloxfruits"},
    -- RP / sosial (8)
    {kw = "bloxburg", id = "rp"}, {kw = "royale high", id = "rp"}, {kw = "livetopia", id = "rp"},
    {kw = "berry avenue", id = "rp"}, {kw = "meepcity", id = "rp"}, {kw = "dress to impress", id = "rp"},
    {kw = "work at a pizza place", id = "rp"}, {kw = "roblox high school", id = "rp"},
    -- Simulator / idle (9)
    {kw = "pet simulator", id = "sim"}, {kw = "bubble gum simulator", id = "sim"}, {kw = "mining simulator", id = "sim"},
    {kw = "bee swarm simulator", id = "sim"}, {kw = "saber simulator", id = "sim"}, {kw = "grow a garden", id = "sim"},
    {kw = "steal a brainrot", id = "sim"}, {kw = "plants vs brainrots", id = "sim"}, {kw = "fisch", id = "sim"},
    -- Tycoon (4)
    {kw = "theme park tycoon", id = "tycoon"}, {kw = "lumber tycoon", id = "tycoon"},
    {kw = "restaurant tycoon", id = "tycoon"}, {kw = "car dealership tycoon", id = "tycoon"},
    -- Horror (4)
    {kw = "doors", id = "horror"}, {kw = "piggy", id = "horror"}, {kw = "the mimic", id = "horror"}, {kw = "rainbow friends", id = "horror"},
    -- Survival / sandbox (4)
    {kw = "99 nights", id = "survival"}, {kw = "dead rails", id = "survival"},
    {kw = "natural disaster", id = "survival"}, {kw = "build a boat", id = "survival"},
    -- Obby (4)
    {kw = "tower of hell", id = "obby"}, {kw = "mega easy obby", id = "obby"},
    {kw = "difficulty chart obby", id = "obby"}, {kw = "flee the facility", id = "obby"},
    -- PvP / shooter (11)
    {kw = "arsenal", id = "pvp"}, {kw = "phantom forces", id = "pvp"}, {kw = "rivals", id = "pvp"},
    {kw = "bad business", id = "pvp"}, {kw = "criminality", id = "pvp"}, {kw = "counter blox", id = "pvp"},
    {kw = "strongest battlegrounds", id = "pvp"}, {kw = "blade ball", id = "pvp"}, {kw = "da hood", id = "pvp"},
    {kw = "jailbreak", id = "pvp"}, {kw = "combat warriors", id = "pvp"},
    -- Tower defense (3)
    {kw = "tower defense simulator", id = "td"}, {kw = "all star tower defense", id = "td"}, {kw = "anime vanguards", id = "td"},
    -- Racing (3)
    {kw = "driving empire", id = "racing"}, {kw = "vehicle simulator", id = "racing"}, {kw = "car crushers", id = "racing"},
}

local PROFILES
do
    local G_MOVE  = {"speed", "jump", "fly", "flyspeed", "noclip", "infjump", "gravity", "hipheight", "spin"}
    local G_TP    = {"tpplayer", "savepos", "gotopos"}
    local G_SKY   = {"skypreset", "skyreset", "clocktime", "fogend", "bloom", "sunrays", "tint", "saturation", "brightness", "shadows", "fullbright"}
    local G_CAM   = {"fov", "maxzoom", "firstperson", "camoffset", "hidehud", "cinebars", "hidechat"}
    local G_CHAR  = {"sit", "rainbowchar", "chartrans", "neonchar", "resetchar", "trailfx", "hidename"}
    local G_AURA  = {"aurason", "aurastyle", "aurasize", "halo", "glowlight", "lightcolor", "orbit"}
    local G_MUSIC = {"musicplay", "musicpause", "musicstop", "musicvol", "musicpitch", "musicloop"}
    local G_SYS   = {"antiafk", "rejoin", "serverhop", "fpsboost", "fpscounter", "pingcounter", "copyplaceid", "copyjobid", "snow", "rain", "stars", "resetall"}

    local function tab(name, ...)
        local f = {}
        for _, g in ipairs({...}) do
            for _, id in ipairs(g) do f[#f + 1] = id end
        end
        return {name = name, features = f}
    end

    local TABS_FULL = {tab("Gerak", G_MOVE), tab("Teleport", G_TP), tab("Langit", G_SKY),
                       tab("Karakter", G_CHAR, G_CAM), tab("Fun", G_AURA, G_MUSIC), tab("Sistem", G_SYS)}
    local TABS_BROOKHAVEN = {tab("Gerak", G_MOVE), tab("Teleport", G_TP), tab("RP Tools", {"buildtext", "dropitem", "avatarinfo", "sit"}, G_MUSIC),
                       tab("Langit", G_SKY), tab("Karakter", G_CHAR, G_CAM), tab("Aura", G_AURA), tab("Sistem", G_SYS)}
    local TABS_LITE = {tab("Gerak", {"speed", "jump", "fly", "flyspeed", "infjump"}), tab("Langit", G_SKY),
                       tab("Fun", G_AURA, G_MUSIC), tab("Kamera", G_CAM, G_CHAR), tab("Sistem", G_SYS)}
    -- Mode adil (PvP / obby / racing / TD): tanpa fitur gerak
    local TABS_FAIR = {tab("Langit", G_SKY), tab("Kamera", G_CAM), tab("Aura", G_CHAR, G_AURA),
                       tab("Musik", G_MUSIC), tab("Sistem", G_SYS)}

    local function prof(name, short, c1, c2, tagline, tabs)
        return {name = name, short = short, color = c1, color2 = c2, tagline = tagline, tabs = tabs}
    end

    PROFILES = {
        brookhaven = prof("Brookhaven RP", "BH", C.green, C.cyan, "Roleplay  •  Rumah  •  Kendaraan", TABS_BROOKHAVEN),
        adoptme    = prof("Adopt Me!", "AM", C.pink, C.purple, "Pet  •  Trading  •  Idle farming", TABS_FULL),
        mm2        = prof("Murder Mystery 2", "MM", C.orange, C.pink, "Gerak cepat  •  Navigasi map", TABS_LITE),
        bloxfruits = prof("Blox Fruits", "BF", C.blue, C.cyan, "Sea  •  Eksplorasi pulau", TABS_LITE),
        universal  = prof("Universal", "NX", C.purple, C.cyan, "Map belum punya menu khusus", TABS_FULL),
        rp         = prof("Roleplay / Sosial", "RP", C.green, C.cyan, "Avatar  •  Nongkrong  •  Estetik", TABS_FULL),
        sim        = prof("Simulator / Idle", "SM", C.orange, C.pink, "Koleksi  •  Idle  •  Grinding", TABS_FULL),
        tycoon     = prof("Tycoon", "TY", C.blue, C.green, "Bangun  •  Kelola  •  Santai", TABS_FULL),
        horror     = prof("Horror", "HR", C.red, C.purple, "Suasana  •  Kamera  •  Musik", TABS_LITE),
        survival   = prof("Survival / Sandbox", "SV", C.green, C.orange, "Eksplorasi  •  Bertahan  •  Bangun", TABS_FULL),
        obby       = prof("Obby / Parkour", "OB", C.cyan, C.purple, "Mode adil: visual, kamera, musik", TABS_FAIR),
        pvp        = prof("PvP / Shooter", "PV", C.red, C.orange, "Mode adil: visual, kamera, musik", TABS_FAIR),
        td         = prof("Tower Defense", "TD", C.purple, C.blue, "Strategi  •  Visual  •  Musik", TABS_FAIR),
        racing     = prof("Racing / Kendaraan", "RC", C.orange, C.red, "Kamera  •  Visual  •  Musik", TABS_FAIR),
    }
end

local function detectProfile()
    local byId = PLACE_IDS[game.PlaceId]
    if byId then return byId end

    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    local name = string.lower((ok and info and info.Name) or game.Name or "")
    for _, entry in ipairs(KEYWORDS) do
        if string.find(name, entry.kw, 1, true) then return entry.id end
    end
    return "universal"
end

local profileId = detectProfile()
local P = PROFILES[profileId]

--==================================================
-- CEK VERSI SERVER
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

local function parts(v)
    local a, b, c = tostring(v or "0.0.0"):match("^(%d+)%.(%d+)%.?(%d*)$")
    return {tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0}
end

local function compareVersion(a, b)
    local x, y = parts(a), parts(b)
    for i = 1, 3 do
        if x[i] > y[i] then return 1 end
        if x[i] < y[i] then return -1 end
    end
    return 0
end

local config = fetchConfig()

--==================================================
-- HELPER UI
--==================================================
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, r) return make("UICorner", {CornerRadius = UDim.new(0, r or 12)}, obj) end

local function stroke(obj, color, thickness, transparency)
    return make("UIStroke", {Color = color or C.line, Thickness = thickness or 1, Transparency = transparency or 0}, obj)
end

local function grad(obj, c1, c2, rotation)
    return make("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rotation or 0}, obj)
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function label(parent, text, pos, size, color, textSize)
    return make("TextLabel", {
        Position = pos, Size = size, BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.GothamMedium, TextSize = textSize or 12, TextColor3 = color or C.white,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function smallBtn(parent, text, pos, size, bg, fg)
    local b = make("TextButton", {
        Position = pos, Size = size, BackgroundColor3 = bg, BorderSizePixel = 0,
        Text = text, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = fg or C.white, AutoButtonColor = false,
    }, parent)
    round(b, 9)
    local sc = make("UIScale", {Scale = 1}, b)
    b.MouseButton1Down:Connect(function() tween(sc, 0.08, {Scale = 0.94}) end)
    local function up() tween(sc, 0.12, {Scale = 1}) end
    b.MouseButton1Up:Connect(up)
    b.MouseLeave:Connect(up)
    return b
end

--==================================================
-- NEXUS UPDATE (gate versi, cara kerja sama seperti v1.1.0)
-- Kalau API_URL melaporkan versi lebih baru, dialog update tampil,
-- script terbaru diunduh dari GITHUB_URL (nama file: NEXUS-DELTA-vX.Y.Z.lua)
-- lalu langsung dijalankan. API boleh mengirim "url" untuk menimpa alamatnya.
--==================================================
local function latestScriptUrl(ver)
    ver = tostring(ver or VERSION)
    -- URL dari API hanya dipakai jika memang untuk versi yang diminta.
    -- Ini mencegah memilih v1.3.0 tetapi mengunduh/menyalin URL v1.4.0.
    local apiVersion = config and tostring(config.version or "") or ""
    local apiUrl = config and (config.url or config.script_url) or nil
    if apiUrl and apiVersion == ver and string.match(tostring(apiUrl), "^https://") then
        return tostring(apiUrl)
    end
    local derived = string.gsub(GITHUB_URL, "%-v%d+%.%d+%.%d+%.lua([?#].*)?$", "-v" .. ver .. ".lua")
    if derived == GITHUB_URL then
        derived = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA-v" .. ver .. ".lua"
    end
    return derived
end

local function rgbTag(c)
    return string.format("rgb(%d,%d,%d)", c.R * 255, c.G * 255, c.B * 255)
end

local function showUpdateToast(ver)
    local old = playerGui:FindFirstChild("NEXUS_UPDATE_TOAST")
    if old then old:Destroy() end

    local tg = make("ScreenGui", {
        Name = "NEXUS_UPDATE_TOAST", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000,
    }, playerGui)
    local toast = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -90),
        Size = UDim2.fromOffset(310, 62), BackgroundColor3 = C.bg, BorderSizePixel = 0,
    }, tg)
    round(toast, 16)
    stroke(toast, C.green, 1.2, 0.3)

    local check = make("Frame", {
        Position = UDim2.fromOffset(14, 15), Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = C.green, BorderSizePixel = 0,
    }, toast)
    round(check, 16)
    make("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✓",
        Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = C.bg,
    }, check)
    local t1 = label(toast, "Update selesai", UDim2.fromOffset(58, 12), UDim2.new(1, -70, 0, 20), C.white, 14)
    t1.Font = Enum.Font.GothamBold
    label(toast, "NEXUS DELTA v" .. ver .. " siap digunakan", UDim2.fromOffset(58, 33), UDim2.new(1, -70, 0, 16), C.muted, 11)

    tween(toast, 0.45, {Position = UDim2.new(0.5, 0, 0, 24)}, Enum.EasingStyle.Back)
    task.delay(3.6, function()
        tween(toast, 0.3, {Position = UDim2.new(0.5, 0, 0, -90)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.35)
        tg:Destroy()
    end)
end

local function showUpdateDialog(requiredVersion)
    for _, n in ipairs({"NEXUS_DELTA", "NEXUS_UPDATE"}) do
        local o = playerGui:FindFirstChild(n)
        if o then o:Destroy() end
    end

    local scriptUrl = latestScriptUrl(requiredVersion)
    local reasonText = tostring((config and (config.reason or config.notes))
        or "Versi lama sudah tidak didukung. Update membawa perbaikan bug, fitur baru, dan performa lebih stabil.")
    reasonText = (reasonText:gsub("&", "&amp;"):gsub("<", "&lt;"))

    local ugui = make("ScreenGui", {
        Name = "NEXUS_UPDATE", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
    }, playerGui)
    local overlay = make("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true,
    }, ugui)

    local card = make("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(330, 296), BackgroundColor3 = C.bg,
        BorderSizePixel = 0, GroupTransparency = 1,
    }, overlay)
    round(card, 20)
    stroke(card, C.line, 1)
    local cardScale = make("UIScale", {Scale = 0.92}, card)

    local accentBar = make("Frame", {Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = C.white, BorderSizePixel = 0}, card)
    grad(accentBar, C.purple, C.cyan)

    local badge = make("Frame", {
        Position = UDim2.fromOffset(20, 22), Size = UDim2.fromOffset(42, 42),
        BackgroundColor3 = C.white, BorderSizePixel = 0,
    }, card)
    round(badge, 12)
    grad(badge, C.purple, C.cyan, 45)
    make("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "↑",
        Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = Color3.new(1, 1, 1),
    }, badge)

    local ttl = label(card, "Nexus Update", UDim2.fromOffset(74, 22), UDim2.new(1, -94, 0, 22), C.white, 17)
    ttl.Font = Enum.Font.GothamBold
    label(card, "NEXUS DELTA • Update tersedia", UDim2.fromOffset(74, 45), UDim2.new(1, -94, 0, 18), C.muted, 11)

    -- Baris versi
    local row = make("Frame", {
        Position = UDim2.fromOffset(20, 78), Size = UDim2.new(1, -40, 0, 50),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    }, card)
    round(row, 14)
    local function verLabel(x, caption, ver, color)
        make("TextLabel", {
            Position = UDim2.fromScale(x, 0), Size = UDim2.fromScale(0.4, 1), BackgroundTransparency = 1,
            RichText = true, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.white,
            Text = string.format('<font size="9" color="%s">%s</font>\n<font size="16" color="%s"><b>v%s</b></font>',
                rgbTag(C.muted), caption, rgbTag(color), ver),
        }, row)
    end
    verLabel(0, "SEKARANG", VERSION, C.muted)
    make("TextLabel", {
        Position = UDim2.fromScale(0.4, 0), Size = UDim2.fromScale(0.2, 1), BackgroundTransparency = 1,
        Text = "→", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = C.cyan,
    }, row)
    verLabel(0.6, "TERBARU", requiredVersion, C.green)

    -- Kenapa harus update
    local reasonBox = make("Frame", {
        Position = UDim2.fromOffset(20, 136), Size = UDim2.new(1, -40, 0, 48),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    }, card)
    round(reasonBox, 12)
    stroke(reasonBox, C.line, 1, 0.5)
    local reasonLbl = make("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, RichText = true,
        Text = '<font color="' .. rgbTag(C.cyan) .. '"><b>Kenapa harus update?</b></font>\n' .. reasonText,
        Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = C.muted, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    }, reasonBox)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
    }, reasonLbl)

    -- Progress
    local barBack = make("Frame", {
        Position = UDim2.fromOffset(20, 196), Size = UDim2.new(1, -40, 0, 6),
        BackgroundColor3 = C.card, BorderSizePixel = 0,
    }, card)
    round(barBack, 3)
    local barFill = make("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.white, BorderSizePixel = 0}, barBack)
    round(barFill, 3)
    grad(barFill, C.purple, C.cyan)

    local statusLbl = label(card, "Siap untuk update", UDim2.fromOffset(20, 207), UDim2.new(1, -90, 0, 18), C.muted, 11)
    local percentLbl = label(card, "0%", UDim2.new(1, -70, 0, 207), UDim2.fromOffset(50, 18), C.cyan, 11)
    percentLbl.Font = Enum.Font.GothamBold
    percentLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Tombol (gradient di frame terpisah supaya teks tetap terlihat)
    local btn = make("TextButton", {
        Position = UDim2.fromOffset(20, 234), Size = UDim2.new(1, -40, 0, 46),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
    }, card)
    local btnScale = make("UIScale", {Scale = 1}, btn)
    local btnFill = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.white, BorderSizePixel = 0}, btn)
    round(btnFill, 13)
    grad(btnFill, C.purple, C.cyan)
    local btnLabel = make("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Update Sekarang",
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1, 1, 1), ZIndex = 2,
    }, btn)
    btn.MouseButton1Down:Connect(function() tween(btnScale, 0.1, {Scale = 0.96}) end)
    local function release() tween(btnScale, 0.15, {Scale = 1}, Enum.EasingStyle.Back) end
    btn.MouseButton1Up:Connect(release)
    btn.MouseLeave:Connect(release)

    -- Animasi buka
    tween(overlay, 0.3, {BackgroundTransparency = 0.45})
    tween(card, 0.3, {GroupTransparency = 0})
    tween(cardScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)

    local function closeAnim()
        tween(card, 0.25, {GroupTransparency = 1})
        tween(cardScale, 0.25, {Scale = 0.92}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(overlay, 0.3, {BackgroundTransparency = 1})
        task.wait(0.35)
        ugui:Destroy()
    end

    local function setProgress(p, text, color)
        tween(barFill, 0.35, {Size = UDim2.fromScale(p, 1)})
        percentLbl.Text = math.floor(p * 100) .. "%"
        if text then statusLbl.Text = text end
        statusLbl.TextColor3 = color or C.muted
    end

    local updating = false
    local function fail(msg)
        setProgress(0, msg, C.red)
        btnLabel.Text = "Coba Lagi"
        tween(btnFill, 0.2, {BackgroundTransparency = 0})
        updating = false
    end

    btn.Activated:Connect(function()
        if updating then return end
        updating = true
        btnLabel.Text = "Mengunduh..."
        tween(btnFill, 0.2, {BackgroundTransparency = 0.35})

        task.spawn(function()
            setProgress(0.2, "Menghubungkan ke GitHub...")
            task.wait(0.3)

            local ok, src = pcall(function()
                return game:HttpGet(scriptUrl .. "?v=" .. tick())
            end)
            if not ok or type(src) ~= "string" or #src < 20 then
                return fail("Gagal mengunduh. Cek koneksi lalu coba lagi.")
            end

            setProgress(0.6, "Memeriksa script...")
            task.wait(0.3)

            if not string.find(src, "NEXUS DELTA", 1, true) or #src < 1000 then
                return fail("Isi unduhan tidak cocok dengan NEXUS DELTA.")
            end
            local compileOk, fn, compileErr = pcall(loadstring, src)
            if not compileOk or type(fn) ~= "function" then
                warn("[NEXUS] Script tidak valid: " .. tostring(compileErr or fn))
                return fail("Script terbaru tidak valid.")
            end

            local copied = false
            if type(setclipboard) == "function" then
                copied = pcall(setclipboard, 'loadstring(game:HttpGet("' .. scriptUrl .. '"))()')
            end

            setProgress(1, copied and "Valid • link disalin" or "Valid • clipboard tidak tersedia", C.green)
            btnLabel.Text = "Menjalankan v" .. requiredVersion .. "..."
            tween(btnFill, 0.2, {BackgroundTransparency = 0})
            task.wait(0.5)

            closeAnim()
            local runOk, runErr = pcall(fn)
            if runOk then
                showUpdateToast(requiredVersion)
            else
                warn("[NEXUS] Gagal menjalankan v" .. requiredVersion .. ": " .. tostring(runErr))
                -- Beri tahu kegagalan eksekusi; jangan klaim update berhasil.
                task.defer(function()
                    pcall(function()
                        local bad = make("ScreenGui", {Name = "NEXUS_UPDATE_ERROR", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1001}, playerGui)
                        local panel = make("TextLabel", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 24), Size = UDim2.fromOffset(310, 48), BackgroundColor3 = C.bg, TextColor3 = C.red, Text = "Update v" .. requiredVersion .. " terunduh, tetapi gagal dijalankan.", TextWrapped = true, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0}, bad)
                        round(panel, 12); stroke(panel, C.red, 1, 0.2)
                        task.delay(4, function() if bad.Parent then bad:Destroy() end end)
                    end)
                end)
            end
        end)
    end)
end

if config and config.version and compareVersion(config.version, VERSION) > 0 then
    showUpdateDialog(tostring(config.version))
    return
end

--==================================================
-- STATE
--==================================================
local conns = {}
local function track(c) table.insert(conns, c) return c end

local function getChar() return player.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local hum0 = getHum()
local speedDefault = hum0 and hum0.WalkSpeed or 16
local jumpDefault = (hum0 and hum0.UseJumpPower and hum0.JumpPower) or 50
local custom = {speed = nil, jump = nil}
local states = {}

local function applyMovement()
    local h = getHum()
    if not h then return end
    if custom.speed then h.WalkSpeed = custom.speed end
    if custom.jump then h.UseJumpPower = true h.JumpPower = custom.jump end
end

--==================================================
-- FITUR (implementasi)
--==================================================
-- Fly (ikuti joystick + arah kamera, aman untuk HP)
local fly = {on = false, speed = 50, bv = nil, bg = nil, conn = nil}

local function stopFly()
    fly.on = false
    if fly.conn then fly.conn:Disconnect() fly.conn = nil end
    if fly.bv then fly.bv:Destroy() fly.bv = nil end
    if fly.bg then fly.bg:Destroy() fly.bg = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
end

local function startFly()
    local root, h = getRoot(), getHum()
    if not root or not h then return false end
    stopFly()
    fly.on = true

    fly.bv = make("BodyVelocity", {MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero}, root)
    fly.bg = make("BodyGyro", {MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 9e4, CFrame = root.CFrame}, root)
    h.PlatformStand = true

    fly.conn = RunService.Heartbeat:Connect(function()
        local r, hh = getRoot(), getHum()
        if not r or not hh or not fly.bv then return end
        local cf = workspace.CurrentCamera.CFrame
        local flat = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        local md = hh.MoveDirection
        local vel = Vector3.zero
        if md.Magnitude > 0 and flat.Magnitude > 0 then
            local fwd = math.max(md:Dot(flat.Unit), 0)
            vel = md * fly.speed + Vector3.new(0, cf.LookVector.Y * fwd * fly.speed, 0)
        end
        fly.bv.Velocity = vel
        if flat.Magnitude > 0 then
            fly.bg.CFrame = CFrame.new(r.Position, r.Position + flat)
        end
    end)
    return true
end

track(player.CharacterAdded:Connect(function()
    task.wait(0.6)
    applyMovement()
    if fly.on then startFly() end
end))

-- Noclip
local noclipConn
local function setNoclip(on)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local c = getChar()
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end

-- Infinite jump
local infConn
local function setInfJump(on)
    if infConn then infConn:Disconnect() infConn = nil end
    if on then
        infConn = UserInputService.JumpRequest:Connect(function()
            local h = getHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

-- Fullbright
local origLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
}
local function setFullbright(on)
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e5
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(190, 190, 190)
    else
        for k, v in pairs(origLight) do Lighting[k] = v end
    end
end

-- Anti-AFK
local afkConn
local function setAntiAfk(on)
    if afkConn then afkConn:Disconnect() afkConn = nil end
    if on then
        afkConn = player.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end

local savedCF

local function shutdown(gui)
    stopFly()
    setNoclip(false)
    setInfJump(false)
    if states.fullbright then setFullbright(false) end
    setAntiAfk(false)
    custom.speed, custom.jump = nil, nil
    local h = getHum()
    if h then h.WalkSpeed = speedDefault h.UseJumpPower = true h.JumpPower = jumpDefault end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end

--==================================================
-- ROOT UI
--==================================================
local oldGui = playerGui:FindFirstChild("NEXUS_DELTA")
if oldGui then oldGui:Destroy() end

local gui = make("ScreenGui", {
    Name = "NEXUS_DELTA", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100,
}, playerGui)

local main = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.9, 0, 0.82, 0), BackgroundColor3 = C.bg,
    BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
round(main, 20)
stroke(main, P.color, 1.6, 0.15)
make("UISizeConstraint", {MinSize = Vector2.new(320, 400), MaxSize = Vector2.new(520, 660)}, main)
local mainScale = make("UIScale", {Scale = 0.92}, main)
tween(mainScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back)

local accent = make("Frame", {Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = C.white, BorderSizePixel = 0, ZIndex = 5}, main)
grad(accent, P.color, P.color2)

-- Toast
local toast = make("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -40),
    Size = UDim2.fromOffset(250, 30), BackgroundColor3 = C.card2, BackgroundTransparency = 1,
    TextTransparency = 1, Text = "", Font = Enum.Font.GothamMedium, TextSize = 11,
    TextColor3 = C.white, ZIndex = 60, BorderSizePixel = 0,
}, main)
round(toast, 10)
local toastToken = 0
local function notify(text, color)
    toastToken += 1
    local my = toastToken
    toast.Text = text
    toast.TextColor3 = color or C.white
    tween(toast, 0.2, {BackgroundTransparency = 0.05, TextTransparency = 0})
    task.delay(2, function()
        if my == toastToken then tween(toast, 0.3, {BackgroundTransparency = 1, TextTransparency = 1}) end
    end)
end

--==================================================
-- HEADER
--==================================================
local header = make("Frame", {
    Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 0, 68),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, main)

local logo = make("Frame", {
    Position = UDim2.new(0, 14, 0.5, -20), Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = C.white, BorderSizePixel = 0,
}, header)
round(logo, 12)
grad(logo, P.color, P.color2, 45)
make("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = P.short,
    Font = Enum.Font.GothamBlack, TextSize = 17, TextColor3 = C.bg,
}, logo)

local title = label(header, P.name, UDim2.new(0, 64, 0, 13), UDim2.new(1, -150, 0, 24), C.white, 17)
title.Font = Enum.Font.GothamBlack
label(header, "NEXUS DELTA  •  v" .. VERSION, UDim2.new(0, 65, 0, 38), UDim2.new(1, -150, 0, 16), P.color, 9)

local infoBtn = smallBtn(header, "i", UDim2.new(1, -86, 0.5, -15), UDim2.fromOffset(30, 30), C.card2, P.color)
infoBtn.TextSize = 14
local closeBtn = smallBtn(header, "×", UDim2.new(1, -46, 0.5, -15), UDim2.fromOffset(30, 30), C.card2, C.white)
closeBtn.TextSize = 20

local minimizeMenu, openMenu -- diisi di bagian BUBBLE

closeBtn.Activated:Connect(function()
    minimizeMenu()
end)

-- Info map
local mapInfo = make("Frame", {
    Position = UDim2.fromOffset(14, 82), Size = UDim2.new(1, -28, 0, 30),
    BackgroundColor3 = C.card, BorderSizePixel = 0,
}, main)
round(mapInfo, 10)
local dot = make("Frame", {
    Position = UDim2.fromOffset(12, 11), Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = P.color, BorderSizePixel = 0,
}, mapInfo)
round(dot, 4)
label(mapInfo, "Map terdeteksi  •  " .. P.tagline, UDim2.fromOffset(28, 0), UDim2.new(1, -36, 1, 0), C.muted, 10)

-- Tabs
local tabBar = make("Frame", {
    Position = UDim2.fromOffset(14, 120), Size = UDim2.new(1, -28, 0, 34),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, main)
round(tabBar, 11)
make("UIPadding", {PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3)}, tabBar)
make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, tabBar)

-- Konten
local content = make("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 162), Size = UDim2.new(1, -28, 1, -202),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = P.color, CanvasSize = UDim2.new(),
}, main)
local layout = make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, content)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
end)

-- Footer
label(main, "●  ONLINE   •   Menu khusus map ini", UDim2.new(0, 16, 1, -30), UDim2.new(1, -32, 0, 22), C.green, 9)

--==================================================
-- MODAL
--==================================================
local function openModal(titleText, height)
    local dim = make("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.35, Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 50,
    }, main)
    local box = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.86, 0, 0, height), BackgroundColor3 = C.panel, BorderSizePixel = 0,
    }, dim)
    round(box, 16)
    stroke(box, P.color, 1.4)
    local t = label(box, titleText, UDim2.fromOffset(16, 12), UDim2.new(1, -32, 0, 24), P.color, 14)
    t.Font = Enum.Font.GothamBlack
    local closeM = smallBtn(box, "TUTUP", UDim2.new(0, 16, 1, -46), UDim2.new(1, -32, 0, 34), P.color, C.bg)
    local function close() dim:Destroy() end
    closeM.Activated:Connect(close)
    return box, close
end

local function openPlayerPicker()
    local box, close = openModal("Teleport ke Pemain", 300)
    local list = make("ScrollingFrame", {
        Position = UDim2.fromOffset(16, 44), Size = UDim2.new(1, -32, 1, -100),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = P.color, CanvasSize = UDim2.new(),
    }, box)
    local ll = make("UIListLayout", {Padding = UDim.new(0, 6)}, list)
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y)
    end)

    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            count += 1
            local b = smallBtn(list, plr.DisplayName .. "  (@" .. plr.Name .. ")", UDim2.new(), UDim2.new(1, -4, 0, 34), C.card2, C.white)
            b.TextSize = 10
            b.Activated:Connect(function()
                local r = getRoot()
                local tr = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if r and tr then
                    r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
                    notify("Teleport ke " .. plr.DisplayName, P.color)
                else
                    notify("Pemain belum siap", C.red)
                end
                close()
            end)
        end
    end
    if count == 0 then
        label(list, "Tidak ada pemain lain di server.", UDim2.new(), UDim2.new(1, 0, 0, 30), C.muted, 11)
    end
end

local function openInfo()
    local box, closeInfo = openModal("Nexus Update", 270)
    local serverVer = config and config.version
    local status
    if not serverVer then
        status = "Server tidak dapat diakses."
    elseif compareVersion(serverVer, VERSION) > 0 then
        status = "Update tersedia: v" .. tostring(serverVer)
    else
        status = "Kamu memakai versi terbaru."
    end
    local txt = label(box, "", UDim2.fromOffset(16, 44), UDim2.new(1, -32, 0, 96), C.muted, 11)
    txt.TextWrapped = true
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.Text = "Versi terpasang:  v" .. VERSION
        .. "\nVersi server:  " .. (serverVer and ("v" .. tostring(serverVer)) or "-")
        .. "\nStatus:  " .. status
        .. "\nMap:  " .. P.name

    local offBtn = smallBtn(box, "MATIKAN SCRIPT", UDim2.new(0, 16, 1, -90), UDim2.new(1, -32, 0, 34), C.card2, C.red)
    offBtn.Activated:Connect(function()
        closeInfo()
        shutdown(gui)
    end)
end
infoBtn.Activated:Connect(openInfo)

--==================================================
-- DEFINISI FITUR
--==================================================
local FEATURES = {
    speed = {
        name = "Kecepatan Jalan", desc = "Atur WalkSpeed karakter", kind = "stepper",
        min = 16, max = 120, step = 8,
        get = function() return custom.speed or speedDefault end,
        set = function(v) custom.speed = v applyMovement() end,
    },
    jump = {
        name = "Tinggi Lompat", desc = "Atur JumpPower karakter", kind = "stepper",
        min = 50, max = 200, step = 25,
        get = function() return custom.jump or jumpDefault end,
        set = function(v) custom.jump = v applyMovement() end,
    },
    fly = {
        name = "Terbang (Fly)", desc = "Gerakkan joystick, arah mengikuti kamera", kind = "toggle",
        set = function(on)
            if on then return startFly() end
            stopFly()
        end,
    },
    flyspeed = {
        name = "Kecepatan Terbang", desc = "Atur kecepatan saat Fly aktif", kind = "stepper",
        min = 20, max = 150, step = 10,
        get = function() return fly.speed end,
        set = function(v) fly.speed = v end,
    },
    noclip = {
        name = "Noclip", desc = "Tembus dinding dan objek", kind = "toggle",
        set = function(on) setNoclip(on) end,
    },
    infjump = {
        name = "Lompat Tanpa Batas", desc = "Lompat terus di udara", kind = "toggle",
        set = function(on) setInfJump(on) end,
    },
    fullbright = {
        name = "Fullbright", desc = "Terangkan seluruh map", kind = "toggle",
        set = function(on) setFullbright(on) end,
    },
    antiafk = {
        name = "Anti-AFK", desc = "Cegah kick karena diam terlalu lama", kind = "toggle",
        set = function(on) setAntiAfk(on) end,
    },
    savepos = {
        name = "Simpan Posisi", desc = "Simpan lokasi kamu sekarang", kind = "action", btn = "SIMPAN",
        run = function()
            local r = getRoot()
            if r then savedCF = r.CFrame notify("Posisi tersimpan", P.color) else notify("Karakter belum siap", C.red) end
        end,
    },
    gotopos = {
        name = "Ke Posisi Tersimpan", desc = "Kembali ke lokasi yang disimpan", kind = "action", btn = "TELEPORT",
        run = function()
            local r = getRoot()
            if not savedCF then notify("Belum ada posisi tersimpan", C.red) return end
            if r then r.CFrame = savedCF notify("Teleport berhasil", P.color) end
        end,
    },
    tpplayer = {
        name = "Teleport ke Pemain", desc = "Pilih pemain lain di server", kind = "action", btn = "PILIH",
        run = openPlayerPicker,
    },
    rejoin = {
        name = "Rejoin Server", desc = "Masuk ulang ke map ini", kind = "action", btn = "REJOIN",
        run = function()
            notify("Rejoin...", P.color)
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end,
    },
}

--==================================================
-- 50 FITUR BARU v1.3.0 (langit, kamera, karakter, aura, musik, sistem)
--==================================================
do
    local SoundService = game:GetService("SoundService")
    local StarterGui = game:GetService("StarterGui")
    local Stats = game:GetService("Stats")
    local function cam() return workspace.CurrentCamera end

    local origOutdoor, origExposure = Lighting.OutdoorAmbient, Lighting.ExposureCompensation
    local origGravity, origFov = workspace.Gravity, cam().FieldOfView
    local origZoom = player.CameraMaxZoomDistance
    local origHip = (hum0 and hum0.HipHeight) or 2

    local function stepper(name, desc, min, max, step, getter, apply)
        return {name = name, desc = desc, kind = "stepper", min = min, max = max, step = step, get = getter, set = apply}
    end
    local function toggle(name, desc, fn) return {name = name, desc = desc, kind = "toggle", set = fn} end
    local function action(name, desc, btn, fn) return {name = name, desc = desc, kind = "action", btn = btn, run = fn} end

    local function fx(class)
        local n = "NX_" .. class
        return Lighting:FindFirstChild(n) or make(class, {Name = n}, Lighting)
    end
    local function skyObj() return Lighting:FindFirstChildOfClass("Sky") or make("Sky", {Name = "NX_Sky"}, Lighting) end

    -- Palet aksen (halo, cahaya, orbit, trail)
    local PAL = {P.color, C.cyan, C.purple, C.pink, C.green, C.orange, C.blue, C.red}
    local palIdx = 1
    local function accentCol() return PAL[palIdx] end

    ------------------------------------------------------------ LANGIT (10)
    local SKY = { -- nama, jam, warna atmosfer, decay, haze, ambient, tint, bintang
        {"Siang Cerah",   14,   Color3.fromRGB(199,215,240), Color3.fromRGB(106,140,200), 0.3, Color3.fromRGB(140,140,140), Color3.new(1,1,1),           3000},
        {"Sunset",        18.2, Color3.fromRGB(255,170,110), Color3.fromRGB(255,100,80),  1.2, Color3.fromRGB(170,110,100), Color3.fromRGB(255,225,200), 3000},
        {"Malam Bintang", 0,    Color3.fromRGB(20,25,60),    Color3.fromRGB(10,15,40),    0.6, Color3.fromRGB(60,65,100),   Color3.fromRGB(200,210,255), 9000},
        {"Galaxy Ungu",   0,    Color3.fromRGB(120,60,200),  Color3.fromRGB(60,20,120),   1.4, Color3.fromRGB(110,70,170),  Color3.fromRGB(230,200,255), 9000},
        {"Neon Cyan",     1,    Color3.fromRGB(0,200,230),   Color3.fromRGB(0,80,140),    1.6, Color3.fromRGB(60,130,160),  Color3.fromRGB(190,245,255), 9000},
        {"Fajar Pink",    6,    Color3.fromRGB(255,170,200), Color3.fromRGB(255,120,160), 1.0, Color3.fromRGB(180,130,150), Color3.fromRGB(255,225,235), 3000},
        {"Kabut Horor",   3,    Color3.fromRGB(90,100,90),   Color3.fromRGB(50,60,50),    2.4, Color3.fromRGB(70,80,70),    Color3.fromRGB(190,200,190), 1000},
    }
    local skyIdx = 0

    local function applySky(i)
        local s = SKY[i]
        Lighting.ClockTime = s[2]
        local a = Lighting:FindFirstChildOfClass("Atmosphere") or fx("Atmosphere")
        a.Color, a.Decay, a.Haze, a.Density = s[3], s[4], s[5], 0.35
        Lighting.OutdoorAmbient = s[6]
        fx("ColorCorrectionEffect").TintColor = s[7]
        skyObj().StarCount = s[8]
    end

    local function resetSky()
        for _, o in ipairs(Lighting:GetChildren()) do
            if string.sub(o.Name, 1, 3) == "NX_" then o:Destroy() end
        end
        for k, v in pairs(origLight) do Lighting[k] = v end
        Lighting.OutdoorAmbient, Lighting.ExposureCompensation = origOutdoor, origExposure
        skyIdx = 0
    end

    local TINTS = {
        {"Normal", Color3.new(1,1,1)}, {"Hangat", Color3.fromRGB(255,225,190)}, {"Dingin", Color3.fromRGB(190,220,255)},
        {"Pink", Color3.fromRGB(255,200,230)}, {"Hijau", Color3.fromRGB(200,255,210)},
    }
    local tintIdx = 1

    FEATURES.skypreset = action("Preset Langit", "Siang, sunset, galaxy, neon, dll", "GANTI", function()
        skyIdx = skyIdx % #SKY + 1
        applySky(skyIdx)
        notify("Langit: " .. SKY[skyIdx][1], P.color)
    end)
    FEATURES.skyreset = action("Reset Visual", "Kembalikan langit & cahaya asli", "RESET", function()
        resetSky()
        notify("Visual dikembalikan", P.color)
    end)
    FEATURES.clocktime = stepper("Jam Dunia", "Atur waktu siang/malam", 0, 24, 2,
        function() return math.floor(Lighting.ClockTime) end, function(v) Lighting.ClockTime = v end)
    FEATURES.fogend = stepper("Jarak Kabut", "Makin kecil makin berkabut", 100, 3000, 300,
        function() return math.floor(Lighting.FogEnd) end, function(v) Lighting.FogEnd = v end)
    FEATURES.bloom = toggle("Bloom", "Cahaya berpendar lembut", function(on)
        local b = fx("BloomEffect")
        b.Intensity, b.Size, b.Threshold, b.Enabled = 1, 24, 0.8, on
    end)
    FEATURES.sunrays = toggle("Sun Rays", "Sinar matahari dramatis", function(on)
        local s = fx("SunRaysEffect")
        s.Intensity, s.Spread, s.Enabled = 0.25, 1, on
    end)
    FEATURES.tint = action("Warna Filter", "Ganti nuansa warna layar", "GANTI", function()
        tintIdx = tintIdx % #TINTS + 1
        fx("ColorCorrectionEffect").TintColor = TINTS[tintIdx][2]
        notify("Filter: " .. TINTS[tintIdx][1], P.color)
    end)
    FEATURES.saturation = stepper("Saturasi", "Warna lebih pekat / pudar", -10, 10, 2,
        function() return math.floor(fx("ColorCorrectionEffect").Saturation * 10 + 0.5) end,
        function(v) fx("ColorCorrectionEffect").Saturation = v / 10 end)
    FEATURES.brightness = stepper("Eksposur", "Terang / gelapkan layar", -3, 3, 1,
        function() return math.floor(Lighting.ExposureCompensation) end,
        function(v) Lighting.ExposureCompensation = v end)
    FEATURES.shadows = toggle("Matikan Bayangan", "Lebih ringan & terang", function(on) Lighting.GlobalShadows = not on end)

    ------------------------------------------------------------ KAMERA (7)
    FEATURES.fov = stepper("Field of View", "Sudut pandang kamera", 40, 120, 10,
        function() return math.floor(cam().FieldOfView) end, function(v) cam().FieldOfView = v end)
    FEATURES.maxzoom = stepper("Zoom Maksimal", "Jarak kamera terjauh", 20, 500, 40,
        function() return math.floor(player.CameraMaxZoomDistance) end, function(v) player.CameraMaxZoomDistance = v end)
    FEATURES.firstperson = toggle("Orang Pertama", "Kunci kamera first person", function(on)
        player.CameraMode = on and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
    end)
    FEATURES.camoffset = stepper("Geser Kamera", "Geser kamera kiri/kanan", -6, 6, 2,
        function() local h = getHum() return h and math.floor(h.CameraOffset.X) or 0 end,
        function(v) local h = getHum() if h then h.CameraOffset = Vector3.new(v, 0, 0) end end)
    FEATURES.hidehud = toggle("Sembunyikan HUD", "Untuk screenshot bersih", function(on)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not on) end)
    end)
    FEATURES.hidechat = toggle("Sembunyikan Chat", "Matikan jendela chat", function(on)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not on) end)
    end)

    local cine
    local function setCine(on)
        if cine then cine:Destroy() cine = nil end
        if on then
            cine = make("ScreenGui", {Name = "NX_CINE", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 50}, playerGui)
            make("Frame", {Size = UDim2.new(1, 0, 0.12, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0}, cine)
            make("Frame", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0.12, 0),
                BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0}, cine)
        end
    end
    FEATURES.cinebars = toggle("Mode Sinematik", "Garis hitam atas & bawah", setCine)

    ------------------------------------------------------------ KARAKTER (10)
    FEATURES.gravity = stepper("Gravitasi", "Rendah = melayang, tinggi = berat", 20, 400, 20,
        function() return math.floor(workspace.Gravity) end, function(v) workspace.Gravity = v end)
    FEATURES.hipheight = stepper("Tinggi Badan", "Atur HipHeight karakter", 0, 30, 2,
        function() local h = getHum() return h and math.floor(h.HipHeight) or 2 end,
        function(v) local h = getHum() if h then h.HipHeight = v end end)

    local spinConn
    FEATURES.spin = toggle("Berputar", "Karakter berputar terus", function(on)
        if spinConn then spinConn:Disconnect() spinConn = nil end
        if on then
            spinConn = RunService.Heartbeat:Connect(function(dt)
                local r = getRoot()
                if r then r.CFrame = r.CFrame * CFrame.Angles(0, dt * 8, 0) end
            end)
        end
    end)
    FEATURES.sit = action("Duduk", "Duduk di tempat", "DUDUK", function()
        local h = getHum()
        if h then h.Sit = true end
    end)

    local function isBody(p) return p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and not string.find(p.Name, "^NX_") end

    local rb = {conn = nil, orig = {}}
    local function setRainbow(on)
        if rb.conn then
            rb.conn:Disconnect() rb.conn = nil
            for p, c in pairs(rb.orig) do if p.Parent then p.Color = c end end
            rb.orig = {}
        end
        if on then
            local c = getChar()
            if not c then return false end
            for _, p in ipairs(c:GetDescendants()) do
                if isBody(p) then rb.orig[p] = p.Color end
            end
            rb.conn = RunService.Heartbeat:Connect(function()
                local col = Color3.fromHSV((tick() * 0.3) % 1, 0.8, 1)
                for p in pairs(rb.orig) do if p.Parent then p.Color = col end end
            end)
        end
    end
    FEATURES.rainbowchar = toggle("Karakter Pelangi", "Warna badan berganti-ganti", setRainbow)

    local ctrans = 0
    local function setCharTrans(v)
        ctrans = v
        local c = getChar()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if isBody(p) then p.Transparency = v / 10 end
        end
    end
    FEATURES.chartrans = stepper("Transparansi Badan", "0 = normal, 10 = tak terlihat", 0, 10, 1,
        function() return ctrans end, setCharTrans)

    local neon = {orig = {}}
    local function setNeon(on)
        for p, m in pairs(neon.orig) do if p.Parent then p.Material = m end end
        neon.orig = {}
        if on then
            local c = getChar()
            if not c then return false end
            for _, p in ipairs(c:GetDescendants()) do
                if isBody(p) then neon.orig[p] = p.Material p.Material = Enum.Material.Neon end
            end
        end
    end
    FEATURES.neonchar = toggle("Badan Neon", "Material neon menyala", setNeon)
    FEATURES.resetchar = action("Reset Karakter", "Respawn karakter", "RESET", function()
        local h = getHum()
        if h then h.Health = 0 end
    end)

    local function setTrail(on)
        local r = getRoot()
        if r then
            for _, n in ipairs({"NX_Trail", "NX_TrailA", "NX_TrailB"}) do
                local o = r:FindFirstChild(n)
                if o then o:Destroy() end
            end
        end
        if not on then return end
        if not r then return false end
        local a0 = make("Attachment", {Name = "NX_TrailA", Position = Vector3.new(0, 1, 0)}, r)
        local a1 = make("Attachment", {Name = "NX_TrailB", Position = Vector3.new(0, -1, 0)}, r)
        make("Trail", {Name = "NX_Trail", Attachment0 = a0, Attachment1 = a1, Lifetime = 0.7, LightEmission = 1,
            Color = ColorSequence.new(accentCol(), P.color2), Transparency = NumberSequence.new(0.1, 1)}, r)
    end
    FEATURES.trailfx = toggle("Jejak Cahaya", "Trail neon di belakangmu", setTrail)
    FEATURES.hidename = toggle("Sembunyikan Nama", "Nama di atas kepalamu", function(on)
        local h = getHum()
        if not h then return false end
        h.DisplayDistanceType = on and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
    end)

    ------------------------------------------------------------ AURA (7)
    local function rainbowSeq()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 230, 60)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(60, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 255)),
        })
    end
    local SP = "rbxasset://textures/particles/sparkles_main.dds"
    local AURA = {
        {"Api",      "rbxasset://textures/particles/fire_main.dds", ColorSequence.new(Color3.fromRGB(255,210,70), Color3.fromRGB(255,60,20)), 3},
        {"Es",       SP, ColorSequence.new(Color3.fromRGB(200,245,255), Color3.fromRGB(90,170,255)), 1},
        {"Listrik",  SP, ColorSequence.new(Color3.fromRGB(255,255,150), Color3.fromRGB(120,200,255)), 6},
        {"Pelangi",  SP, rainbowSeq(), 2},
        {"Galaxy",   SP, ColorSequence.new(Color3.fromRGB(190,110,255), Color3.fromRGB(60,40,160)), 1},
        {"Hati",     SP, ColorSequence.new(Color3.fromRGB(255,140,200), Color3.fromRGB(255,60,120)), 2},
        {"Bayangan", "rbxasset://textures/particles/smoke_main.dds", ColorSequence.new(Color3.fromRGB(60,0,90), Color3.fromRGB(10,10,20)), 1},
        {"Emas",     SP, ColorSequence.new(Color3.fromRGB(255,235,140), Color3.fromRGB(255,170,30)), 2},
    }
    local aura = {style = 1, size = 3, em = nil}

    local function clearAura()
        if aura.em then aura.em:Destroy() aura.em = nil end
    end
    local function buildAura()
        clearAura()
        local r = getRoot()
        if not r then return false end
        local s = AURA[aura.style]
        aura.em = make("ParticleEmitter", {
            Name = "NX_Aura", Texture = s[2], Color = s[3], Rate = 45, Lifetime = NumberRange.new(0.8, 1.5),
            Speed = NumberRange.new(s[4], s[4] + 2), SpreadAngle = Vector2.new(180, 180), LightEmission = 1,
            RotSpeed = NumberRange.new(-120, 120), Size = NumberSequence.new(aura.size * 0.6, 0),
            Transparency = NumberSequence.new(0.2, 1), Shape = Enum.ParticleEmitterShape.Sphere,
        }, r)
        return true
    end

    FEATURES.aurason = toggle("Aura Karakter", "Partikel aura di sekeliling badan", function(on)
        if on then return buildAura() end
        clearAura()
    end)
    FEATURES.aurastyle = action("Gaya Aura", "Api, es, listrik, pelangi, galaxy...", "GANTI", function()
        aura.style = aura.style % #AURA + 1
        if aura.em then buildAura() end
        notify("Aura: " .. AURA[aura.style][1], P.color)
    end)
    FEATURES.aurasize = stepper("Ukuran Aura", "Besar partikel aura", 1, 10, 1,
        function() return aura.size end, function(v) aura.size = v if aura.em then buildAura() end end)

    local halo
    local function setHalo(on)
        if halo then halo:Destroy() halo = nil end
        if not on then return end
        local c = getChar()
        local head = c and c:FindFirstChild("Head")
        if not head then return false end
        halo = make("Part", {Name = "NX_Halo", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.15, 3, 3),
            Material = Enum.Material.Neon, Color = accentCol(), CanCollide = false, CanQuery = false, CanTouch = false,
            Massless = true, CFrame = head.CFrame * CFrame.new(0, 1.8, 0) * CFrame.Angles(0, 0, math.pi / 2)}, c)
        make("WeldConstraint", {Part0 = head, Part1 = halo}, halo)
    end
    FEATURES.halo = toggle("Halo", "Cincin neon di atas kepala", setHalo)

    local glowLight
    local function setGlow(on)
        if glowLight then glowLight:Destroy() glowLight = nil end
        if not on then return end
        local r = getRoot()
        if not r then return false end
        glowLight = make("PointLight", {Name = "NX_Glow", Range = 18, Brightness = 2, Color = accentCol()}, r)
    end
    FEATURES.glowlight = toggle("Cahaya Sekitar", "Karakter memancarkan cahaya", setGlow)

    FEATURES.lightcolor = action("Warna Aksen", "Warna halo, cahaya, orbit, trail", "GANTI", function()
        palIdx = palIdx % #PAL + 1
        local col = accentCol()
        if glowLight then glowLight.Color = col end
        if halo then halo.Color = col end
        if states.trailfx then setTrail(true) end
        notify("Warna aksen diganti", col)
    end)

    local orb = {conn = nil, parts = {}}
    local function setOrbit(on)
        if orb.conn then orb.conn:Disconnect() orb.conn = nil end
        for _, p in ipairs(orb.parts) do p:Destroy() end
        orb.parts = {}
        if not on then return end
        for i = 1, 3 do
            orb.parts[i] = make("Part", {Name = "NX_Orb", Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7),
                Material = Enum.Material.Neon, Color = accentCol(), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false}, workspace)
        end
        orb.conn = RunService.Heartbeat:Connect(function()
            local r = getRoot()
            if not r then return end
            local t = tick() * 2
            for i, p in ipairs(orb.parts) do
                local a = t + (i - 1) * math.pi * 2 / 3
                p.Position = r.Position + Vector3.new(math.cos(a) * 3, math.sin(t + i) * 0.8, math.sin(a) * 3)
                p.Color = accentCol()
            end
        end)
    end
    FEATURES.orbit = toggle("Bola Orbit", "3 bola neon mengelilingimu", setOrbit)

    ------------------------------------------------------------ MUSIK (6)
    local sound
    local function getSound()
        if not sound or not sound.Parent then
            sound = make("Sound", {Name = "NX_Music", Volume = 0.5, Looped = false}, SoundService)
        end
        return sound
    end

    FEATURES.musicplay = action("Putar Lagu", "Masukkan Asset ID audio", "PUTAR", function()
        local box, close = openModal("Putar Musik (Asset ID)", 230)
        local tb = make("TextBox", {
            Position = UDim2.fromOffset(16, 44), Size = UDim2.new(1, -32, 0, 36), BackgroundColor3 = C.card2,
            BorderSizePixel = 0, Text = "", PlaceholderText = "Tempel ID audio, contoh: 123456789",
            PlaceholderColor3 = C.muted, TextColor3 = C.white, Font = Enum.Font.GothamMedium, TextSize = 12,
            ClearTextOnFocus = false,
        }, box)
        round(tb, 10)
        local go = smallBtn(box, "PUTAR", UDim2.fromOffset(16, 90), UDim2.new(1, -32, 0, 34), P.color, C.bg)
        go.Activated:Connect(function()
            local id = (tb.Text:gsub("%D", ""))
            if id == "" then notify("ID tidak valid", C.red) return end
            local s = getSound()
            s:Stop()
            s.SoundId = "rbxassetid://" .. id
            s:Play()
            notify("Memutar audio " .. id, P.color)
            close()
        end)
    end)
    FEATURES.musicpause = toggle("Jeda Lagu", "Jeda / lanjutkan", function(on)
        local s = getSound()
        if on then s:Pause() else s:Resume() end
    end)
    FEATURES.musicstop = action("Stop Lagu", "Hentikan musik", "STOP", function()
        if sound then sound:Stop() end
    end)
    FEATURES.musicvol = stepper("Volume Musik", "0 - 10", 0, 10, 1,
        function() return math.floor(getSound().Volume * 10 + 0.5) end, function(v) getSound().Volume = v / 10 end)
    FEATURES.musicpitch = stepper("Kecepatan Lagu", "10 = normal (x1.0)", 5, 20, 1,
        function() return math.floor(getSound().PlaybackSpeed * 10 + 0.5) end, function(v) getSound().PlaybackSpeed = v / 10 end)
    FEATURES.musicloop = toggle("Ulangi Lagu", "Putar berulang", function(on) getSound().Looped = on end)

    ------------------------------------------------------------ SISTEM / UTILITAS (10)
    local showFps, showPing, fpsSmooth = false, false, 60
    local statsGui, statsConn
    local function refreshStats()
        if statsConn then statsConn:Disconnect() statsConn = nil end
        if statsGui then statsGui:Destroy() statsGui = nil end
        if not (showFps or showPing) then return end
        statsGui = make("ScreenGui", {Name = "NX_STATS", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 60}, playerGui)
        local l = make("TextLabel", {Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(150, 20),
            BackgroundColor3 = C.bg, BackgroundTransparency = 0.3, TextColor3 = P.color,
            Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0}, statsGui)
        round(l, 8)
        local acc = 0
        statsConn = RunService.Heartbeat:Connect(function(dt)
            fpsSmooth = fpsSmooth * 0.9 + (1 / dt) * 0.1
            acc += dt
            if acc < 0.5 then return end
            acc = 0
            local txt = {}
            if showFps then txt[#txt + 1] = math.floor(fpsSmooth) .. " FPS" end
            if showPing then
                local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
                txt[#txt + 1] = (ok and tostring(math.floor(v)) or "?") .. " ms"
            end
            l.Text = table.concat(txt, "  •  ")
        end)
    end
    FEATURES.fpscounter = toggle("Penghitung FPS", "Tampilkan FPS di layar", function(on) showFps = on refreshStats() end)
    FEATURES.pingcounter = toggle("Penghitung Ping", "Tampilkan ping di layar", function(on) showPing = on refreshStats() end)

    FEATURES.fpsboost = toggle("FPS Boost", "Grafis rendah agar lebih ringan", function(on)
        pcall(function()
            settings().Rendering.QualityLevel = on and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end)
        Lighting.GlobalShadows = not on
    end)

    FEATURES.serverhop = action("Pindah Server", "Cari server lain di game ini", "PINDAH", function()
        notify("Mencari server...", P.color)
        task.spawn(function()
            local ok, res = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if ok and res and res.data then
                for _, s in ipairs(res.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player) end)
                        return
                    end
                end
            end
            notify("Server lain tidak ditemukan", C.red)
        end)
    end)

    local function copyText(txt, name)
        if setclipboard then
            setclipboard(txt)
            notify(name .. " disalin", P.color)
        else
            notify("Executor tidak mendukung clipboard", C.red)
        end
    end
    FEATURES.copyplaceid = action("Salin Place ID", "Salin ID map ini", "SALIN", function() copyText(tostring(game.PlaceId), "Place ID") end)
    FEATURES.copyjobid = action("Salin Job ID", "Salin ID server ini", "SALIN", function() copyText(tostring(game.JobId), "Job ID") end)

    local weather = {}
    local function setWeather(kind, on)
        if weather[kind] then weather[kind].conn:Disconnect() weather[kind].part:Destroy() weather[kind] = nil end
        if not on then return end
        local cfg = kind == "snow"
            and {rate = 250, sp = 6, col = Color3.new(1, 1, 1), sz = 0.35, life = 9}
            or {rate = 450, sp = 70, col = Color3.fromRGB(150, 190, 255), sz = 0.18, life = 1.6}
        local part = make("Part", {Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
            Transparency = 1, Size = Vector3.new(90, 1, 90), Name = "NX_Weather"}, workspace)
        make("ParticleEmitter", {Texture = SP, Rate = cfg.rate, Lifetime = NumberRange.new(cfg.life), Speed = NumberRange.new(cfg.sp),
            EmissionDirection = Enum.NormalId.Bottom, Color = ColorSequence.new(cfg.col), Size = NumberSequence.new(cfg.sz),
            LightEmission = 0.3, SpreadAngle = Vector2.new(8, 8)}, part)
        weather[kind] = {part = part, conn = RunService.Heartbeat:Connect(function()
            part.CFrame = CFrame.new(cam().CFrame.Position + Vector3.new(0, 35, 0))
        end)}
    end
    FEATURES.snow = toggle("Salju", "Efek salju (hanya terlihat olehmu)", function(on) setWeather("snow", on) end)
    FEATURES.rain = toggle("Hujan", "Efek hujan (hanya terlihat olehmu)", function(on) setWeather("rain", on) end)
    FEATURES.stars = toggle("Langit Berbintang", "Tambah bintang di langit", function(on) skyObj().StarCount = on and 6000 or 3000 end)

    local function resetAll()
        workspace.Gravity = origGravity
        cam().FieldOfView = origFov
        player.CameraMaxZoomDistance = origZoom
        local h = getHum()
        if h then h.CameraOffset = Vector3.zero h.HipHeight = origHip end
        setCharTrans(0)
    end
    FEATURES.resetall = action("Reset Semua Nilai", "Gravitasi, FOV, zoom, tinggi badan", "RESET", function()
        resetAll()
        notify("Nilai dikembalikan", P.color)
    end)

    ------------------------------------------------------------ BROOKHAVEN ROLEPLAY TOOLS (lokal)
    local localProps = {}
    local propIndex = 0
    FEATURES.dropitem = action("Drop Item Dekorasi", "Letakkan prop dekoratif yang hanya terlihat olehmu", "DROP", function()
        local root = getRoot()
        if not root then notify("Karakter belum siap", C.red) return end
        propIndex = propIndex % 4 + 1
        local shapes = {
            {name = "NX_RP_Crate", shape = Enum.PartType.Block, size = Vector3.new(1.5, 1.5, 1.5), color = Color3.fromRGB(150, 100, 60), material = Enum.Material.Wood},
            {name = "NX_RP_Gem", shape = Enum.PartType.Ball, size = Vector3.new(1, 1, 1), color = C.cyan, material = Enum.Material.Neon},
            {name = "NX_RP_Cone", shape = Enum.PartType.Ball, size = Vector3.new(0.8, 1.2, 0.8), color = C.orange, material = Enum.Material.SmoothPlastic},
            {name = "NX_RP_Cube", shape = Enum.PartType.Block, size = Vector3.new(1, 1, 1), color = C.purple, material = Enum.Material.Neon},
        }
        local cfg = shapes[propIndex]
        local part = make("Part", {Name = cfg.name, Shape = cfg.shape, Size = cfg.size, Color = cfg.color, Material = cfg.material,
            Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
            CFrame = root.CFrame * CFrame.new(0, -1.5, -4)}, workspace)
        table.insert(localProps, part)
        while #localProps > 30 do local first = table.remove(localProps, 1); if first then first:Destroy() end end
        notify("Prop lokal dibuat (" .. propIndex .. "/4)", P.color)
    end)

    FEATURES.buildtext = action("Build Text 3D", "Tampilkan tulisan roleplay lokal di depanmu", "BUAT", function()
        local root = getRoot()
        if not root then notify("Karakter belum siap", C.red) return end
        local box, close = openModal("Build Text 3D • Lokal", 230)
        local tb = make("TextBox", {Position = UDim2.fromOffset(16, 44), Size = UDim2.new(1, -32, 0, 38),
            BackgroundColor3 = C.card2, BorderSizePixel = 0, Text = "HELLO BROOKHAVEN", PlaceholderText = "Maksimal 40 karakter",
            PlaceholderColor3 = C.muted, TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 12, ClearTextOnFocus = false}, box)
        round(tb, 10)
        local go = smallBtn(box, "BUAT TEKS", UDim2.fromOffset(16, 92), UDim2.new(1, -32, 0, 34), P.color, C.bg)
        go.Activated:Connect(function()
            local textValue = string.sub((tb.Text or ""):gsub("[%c]", " "), 1, 40)
            if textValue:gsub("%s", "") == "" then notify("Teks masih kosong", C.red) return end
            local anchor = make("Part", {Name = "NX_RP_TextAnchor", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1,
                Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
                CFrame = root.CFrame * CFrame.new(0, 2.5, -6)}, workspace)
            local board = make("BillboardGui", {Name = "NX_RP_Text", Size = UDim2.fromOffset(260, 64), AlwaysOnTop = true, StudsOffset = Vector3.new(0, 0, 0), Adornee = anchor}, anchor)
            local textLabel = make("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = textValue,
                TextColor3 = P.color, TextStrokeTransparency = 0.2, TextScaled = true, Font = Enum.Font.GothamBlack}, board)
            table.insert(localProps, anchor)
            while #localProps > 30 do local first = table.remove(localProps, 1); if first then first:Destroy() end end
            notify("Teks lokal dibuat", P.color)
            close()
        end)
    end)

    FEATURES.avatarinfo = action("Info Avatar Pemain", "Lihat nama dan ID pemain untuk roleplay", "PILIH", function()
        local box, close = openModal("Info Avatar Pemain", 300)
        local list = make("ScrollingFrame", {Position = UDim2.fromOffset(16, 44), Size = UDim2.new(1, -32, 1, -100),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = P.color, CanvasSize = UDim2.new()}, box)
        local ll = make("UIListLayout", {Padding = UDim.new(0, 6)}, list)
        ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() list.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y) end)
        local count = 0
        for _, target in ipairs(Players:GetPlayers()) do
            count += 1
            local b = smallBtn(list, target.DisplayName .. "  •  @" .. target.Name, UDim2.new(), UDim2.new(1, -4, 0, 34), C.card2, C.white)
            b.Activated:Connect(function()
                notify(target.DisplayName .. "  |  UserId: " .. tostring(target.UserId), P.color)
                close()
            end)
        end
        if count == 0 then label(list, "Tidak ada pemain.", UDim2.new(), UDim2.new(1, 0, 0, 30), C.muted, 11) end
    end)

    -- Hidupkan lagi efek setelah respawn
    track(player.CharacterAdded:Connect(function()
        task.wait(1)
        if states.aurason then buildAura() end
        if states.halo then setHalo(true) end
        if states.glowlight then setGlow(true) end
        if states.trailfx then setTrail(true) end
    end))

    -- Bersihkan semuanya saat script dimatikan
    gui.Destroying:Connect(function()
        pcall(resetSky)
        if spinConn then spinConn:Disconnect() end
        pcall(setRainbow, false)
        pcall(setNeon, false)
        pcall(setTrail, false)
        pcall(setGlow, false)
        pcall(setHalo, false)
        pcall(setOrbit, false)
        pcall(clearAura)
        pcall(setWeather, "snow", false)
        pcall(setWeather, "rain", false)
        showFps, showPing = false, false
        pcall(refreshStats)
        pcall(setCine, false)
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
            player.CameraMode = Enum.CameraMode.Classic
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end)
        pcall(resetAll)
        for _, prop in ipairs(localProps) do pcall(function() prop:Destroy() end) end
        table.clear(localProps)
        if sound then sound:Destroy() end
    end)
end

--==================================================
-- RENDER BARIS FITUR
--==================================================
local function buildRow(id, def, order)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 58), BackgroundColor3 = C.card,
        BorderSizePixel = 0, LayoutOrder = order,
    }, content)
    round(row, 13)
    stroke(row, C.line, 1, 0.3)

    local bar = make("Frame", {
        Position = UDim2.fromOffset(0, 15), Size = UDim2.fromOffset(3, 28),
        BackgroundColor3 = P.color, BorderSizePixel = 0,
    }, row)
    round(bar, 2)

    local t = label(row, def.name, UDim2.fromOffset(14, 9), UDim2.new(1, -130, 0, 20), C.white, 12)
    t.Font = Enum.Font.GothamBold
    local d = label(row, def.desc, UDim2.fromOffset(14, 29), UDim2.new(1, -130, 0, 22), C.muted, 9)
    d.TextWrapped = true
    d.TextYAlignment = Enum.TextYAlignment.Top

    if def.kind == "toggle" then
        local on = states[id] == true
        local pill = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(46, 24), BackgroundColor3 = on and P.color or C.card2, BorderSizePixel = 0,
        }, row)
        round(pill, 12)
        local knob = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = on and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(20, 20), BackgroundColor3 = C.white, BorderSizePixel = 0,
        }, pill)
        round(knob, 10)
        local hit = make("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 3,
        }, row)
        hit.Activated:Connect(function()
            local want = not states[id]
            if def.set(want) == false then notify("Karakter belum siap", C.red) return end
            states[id] = want
            tween(pill, 0.18, {BackgroundColor3 = want and P.color or C.card2})
            tween(knob, 0.18, {Position = want and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
        end)

    elseif def.kind == "stepper" then
        local box = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(108, 28), BackgroundTransparency = 1,
        }, row)
        local minus = smallBtn(box, "−", UDim2.fromOffset(0, 0), UDim2.fromOffset(28, 28), C.card2, C.white)
        local plus = smallBtn(box, "+", UDim2.fromOffset(80, 0), UDim2.fromOffset(28, 28), C.card2, C.white)
        local val = make("TextLabel", {
            Position = UDim2.fromOffset(28, 0), Size = UDim2.fromOffset(52, 28), BackgroundTransparency = 1,
            Text = tostring(math.floor(def.get())), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = P.color,
        }, box)
        local function change(delta)
            local v = math.clamp(math.floor(def.get()) + delta, def.min, def.max)
            def.set(v)
            val.Text = tostring(v)
        end
        minus.Activated:Connect(function() change(-def.step) end)
        plus.Activated:Connect(function() change(def.step) end)

    else
        local b = smallBtn(row, def.btn or "JALANKAN", UDim2.new(1, -94, 0.5, -14), UDim2.fromOffset(82, 28), P.color, C.bg)
        b.Activated:Connect(function() def.run() end)
    end
end

--==================================================
-- TAB
--==================================================
local tabButtons = {}
local activeTab = 0

local function showTab(index)
    activeTab = index
    for i, tb in ipairs(tabButtons) do
        local on = (i == index)
        tween(tb, 0.18, {BackgroundTransparency = on and 0 or 1})
        tb.TextColor3 = on and C.bg or C.muted
    end
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    content.CanvasPosition = Vector2.zero
    for order, id in ipairs(P.tabs[index].features) do
        local def = FEATURES[id]
        if def then buildRow(id, def, order) end
    end
end

for i, tab in ipairs(P.tabs) do
    local tb = make("TextButton", {
        Size = UDim2.new(1 / #P.tabs, -3 * (#P.tabs - 1) / #P.tabs, 1, 0),
        BackgroundColor3 = P.color, BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = tab.name, Font = Enum.Font.GothamBold, TextSize = 10,
        TextColor3 = C.muted, AutoButtonColor = false, LayoutOrder = i,
    }, tabBar)
    round(tb, 9)
    tabButtons[i] = tb
    tb.Activated:Connect(function() showTab(i) end)
end

showTab(1)

--==================================================
-- BUBBLE (ikon neon mengambang saat menu ditutup)
--==================================================
local BUBBLE = 54

local bubble = make("Frame", {
    Name = "NexusBubble",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(1, -44, 0, 84),
    Size = UDim2.fromOffset(BUBBLE, BUBBLE),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 10,
}, gui)
local bubbleScale = make("UIScale", {Scale = 0.01}, bubble)

-- Glow lembut di belakang (bernapas pelan)
local glow = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1.4, 1.4), BackgroundColor3 = P.color,
    BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 1,
}, bubble)
round(glow, 100)
TweenService:Create(glow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {BackgroundTransparency = 0.6}):Play()

-- Ring pulse yang melebar lalu memudar
local ring = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1,
}, bubble)
round(ring, 100)
local ringStroke = stroke(ring, P.color, 2, 0.2)
local pulseInfo = TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1)
TweenService:Create(ring, pulseInfo, {Size = UDim2.fromScale(1.7, 1.7)}):Play()
TweenService:Create(ringStroke, pulseInfo, {Transparency = 1}):Play()

-- Badan ikon + garis neon yang berputar
local face = make("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg, BorderSizePixel = 0,
    Text = "", AutoButtonColor = false, ZIndex = 2,
}, bubble)
round(face, 100)
local faceStroke = stroke(face, C.white, 2.5, 0)
local faceGrad = make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, P.color),
        ColorSequenceKeypoint.new(0.5, P.color2),
        ColorSequenceKeypoint.new(1, P.color),
    }),
}, faceStroke)
make("TextLabel", {
    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = P.short,
    Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = P.color, ZIndex = 3,
}, face)

track(RunService.Heartbeat:Connect(function(dt)
    if bubble.Visible then
        faceGrad.Rotation = (faceGrad.Rotation + dt * 140) % 360
    end
end))

-- Buka / tutup menu dengan animasi
local menuOpen = true
local busy = false
local restorePos = main.Position

minimizeMenu = function()
    if busy or not menuOpen then return end
    busy, menuOpen = true, false
    restorePos = main.Position

    tween(main, 0.35, {Position = bubble.Position}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(mainScale, 0.35, {Scale = 0.05}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.wait(0.34)

    main.Visible = false
    bubbleScale.Scale = 0.01
    bubble.Visible = true
    tween(bubbleScale, 0.45, {Scale = 1}, Enum.EasingStyle.Back)
    busy = false
end

openMenu = function()
    if busy or menuOpen then return end
    busy, menuOpen = true, true

    tween(bubbleScale, 0.2, {Scale = 0.01}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    main.Position = bubble.Position
    mainScale.Scale = 0.05
    main.Visible = true
    tween(main, 0.5, {Position = restorePos}, Enum.EasingStyle.Quint)
    tween(mainScale, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
    task.wait(0.2)
    bubble.Visible = false
    busy = false
end

-- Geser ikon (snap ke sisi layar) / ketuk untuk membuka
local bDrag = {active = false, moved = false, start = nil, origin = nil}

face.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bDrag.active = true
        bDrag.moved = false
        bDrag.start = input.Position
        bDrag.origin = Vector2.new(
            bubble.AbsolutePosition.X + bubble.AbsoluteSize.X / 2,
            bubble.AbsolutePosition.Y + bubble.AbsoluteSize.Y / 2
        )
        tween(bubbleScale, 0.1, {Scale = 0.92})
    end
end)

track(UserInputService.InputChanged:Connect(function(input)
    if bDrag.active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - bDrag.start
        if delta.Magnitude > 8 then bDrag.moved = true end
        if bDrag.moved then
            local sz = gui.AbsoluteSize
            local x = math.clamp(bDrag.origin.X + delta.X, BUBBLE / 2 + 6, sz.X - BUBBLE / 2 - 6)
            local y = math.clamp(bDrag.origin.Y + delta.Y, BUBBLE / 2 + 6, sz.Y - BUBBLE / 2 - 6)
            bubble.Position = UDim2.fromOffset(x, y)
        end
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if bDrag.active and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        bDrag.active = false
        tween(bubbleScale, 0.18, {Scale = 1}, Enum.EasingStyle.Back)
        if bDrag.moved then
            local sz = gui.AbsoluteSize
            local cx = bubble.AbsolutePosition.X + BUBBLE / 2
            local cy = bubble.AbsolutePosition.Y + BUBBLE / 2
            local tx = (cx < sz.X / 2) and (BUBBLE / 2 + 10) or (sz.X - BUBBLE / 2 - 10)
            tween(bubble, 0.35, {Position = UDim2.fromOffset(tx, cy)}, Enum.EasingStyle.Quint)
        else
            openMenu()
        end
    end
end))

--==================================================
-- DRAG WINDOW
--==================================================
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

print("[NEXUS DELTA v" .. VERSION .. "] Map: " .. P.name .. " (" .. profileId .. ")")
