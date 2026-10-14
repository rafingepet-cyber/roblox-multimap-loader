--[[
  NEXUS DELTA v1.3.0 - PATCH (2 bagian)
  BAGIAN 1: ganti seluruh blok dari "local PLACE_IDS = {" sampai SEBELUM "local function detectProfile()"
  BAGIAN 2: tempel tepat setelah tabel FEATURES selesai (sebelum "-- RENDER BARIS FITUR")
  Opsional: di bagian TAB, ubah TextSize = 11 jadi TextSize = 10 (tab lebih muat)
  Opsional: VERSION = "1.3.0" (ingat update API versi kalau mau dialog update jalan)
]]

--==================================================================
-- BAGIAN 1 : PETA, GRUP FITUR, PROFIL
--==================================================================
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

-- Grup fitur (id harus ada di tabel FEATURES)
local G_MOVE  = {"speed", "jump", "fly", "flyspeed", "noclip", "infjump", "gravity", "hipheight", "spin"}
local G_TP    = {"tpplayer", "savepos", "gotopos"}
local G_SKY   = {"skypreset", "skyreset", "clocktime", "fogend", "bloom", "sunrays", "tint", "saturation", "brightness", "shadows"}
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

-- Tiga susunan tab
local TABS_FULL = {tab("Gerak", G_MOVE), tab("Teleport", G_TP), tab("Langit", G_SKY),
                   tab("Karakter", G_CHAR, G_CAM), tab("Fun", G_AURA, G_MUSIC), tab("Sistem", G_SYS)}
local TABS_LITE = {tab("Gerak", {"speed", "jump", "fly", "flyspeed", "infjump"}), tab("Langit", G_SKY),
                   tab("Fun", G_AURA, G_MUSIC), tab("Kamera", G_CAM, G_CHAR), tab("Sistem", G_SYS)}
-- Mode adil (PvP / obby / racing / TD): tanpa fitur gerak
local TABS_FAIR = {tab("Langit", G_SKY), tab("Kamera", G_CAM), tab("Aura", G_CHAR, G_AURA),
                   tab("Musik", G_MUSIC), tab("Sistem", G_SYS)}

local function prof(name, short, c1, c2, tagline, tabs)
    return {name = name, short = short, color = c1, color2 = c2, tagline = tagline, tabs = tabs}
end

local PROFILES = {
    brookhaven = prof("Brookhaven RP", "BH", C.green, C.cyan, "Roleplay  •  Rumah  •  Kendaraan", TABS_FULL),
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

--==================================================================
-- BAGIAN 2 : 50 FITUR BARU (tempel setelah tabel FEATURES)
--==================================================================
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

-- Palet aksen (dipakai halo, cahaya, orbit, trail)
local PAL = {P.color, C.cyan, C.purple, C.pink, C.green, C.orange, C.blue, C.red}
local palIdx = 1
local function accent() return PAL[palIdx] end

--------------------------------------------------------------- LANGIT (10)
local SKY = { -- nama, jam, warna atmosfer, decay, haze, ambient, tint, bintang
    {"Siang Cerah",   14,   Color3.fromRGB(199,215,240), Color3.fromRGB(106,140,200), 0.3, Color3.fromRGB(140,140,140), Color3.new(1,1,1),               3000},
    {"Sunset",        18.2, Color3.fromRGB(255,170,110), Color3.fromRGB(255,100,80),  1.2, Color3.fromRGB(170,110,100), Color3.fromRGB(255,225,200),     3000},
    {"Malam Bintang", 0,    Color3.fromRGB(20,25,60),    Color3.fromRGB(10,15,40),    0.6, Color3.fromRGB(60,65,100),   Color3.fromRGB(200,210,255),     9000},
    {"Galaxy Ungu",   0,    Color3.fromRGB(120,60,200),  Color3.fromRGB(60,20,120),   1.4, Color3.fromRGB(110,70,170),  Color3.fromRGB(230,200,255),     9000},
    {"Neon Cyan",     1,    Color3.fromRGB(0,200,230),   Color3.fromRGB(0,80,140),    1.6, Color3.fromRGB(60,130,160),  Color3.fromRGB(190,245,255),     9000},
    {"Fajar Pink",    6,    Color3.fromRGB(255,170,200), Color3.fromRGB(255,120,160), 1.0, Color3.fromRGB(180,130,150), Color3.fromRGB(255,225,235),     3000},
    {"Kabut Horor",   3,    Color3.fromRGB(90,100,90),   Color3.fromRGB(50,60,50),    2.4, Color3.fromRGB(70,80,70),    Color3.fromRGB(190,200,190),     1000},
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

--------------------------------------------------------------- KAMERA (7)
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

--------------------------------------------------------------- KARAKTER (10: 3 di Gerak, 7 di Karakter)
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
        Color = ColorSequence.new(accent(), P.color2), Transparency = NumberSequence.new(0.1, 1)}, r)
end
FEATURES.trailfx = toggle("Jejak Cahaya", "Trail neon di belakangmu", setTrail)
FEATURES.hidename = toggle("Sembunyikan Nama", "Nama di atas kepalamu", function(on)
    local h = getHum()
    if not h then return false end
    h.DisplayDistanceType = on and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
end)

--------------------------------------------------------------- AURA (7)
local function rainbowSeq()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 230, 60)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(60, 255, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 255)),
    })
end
local SP = "rbxasset://textures/particles/sparkles_main.dds"
local AURA = {
    {"Api",      "rbxasset://textures/particles/fire_main.dds",  ColorSequence.new(Color3.fromRGB(255,210,70), Color3.fromRGB(255,60,20)), 3},
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
        Material = Enum.Material.Neon, Color = accent(), CanCollide = false, CanQuery = false, CanTouch = false,
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
    glowLight = make("PointLight", {Name = "NX_Glow", Range = 18, Brightness = 2, Color = accent()}, r)
end
FEATURES.glowlight = toggle("Cahaya Sekitar", "Karakter memancarkan cahaya", setGlow)

FEATURES.lightcolor = action("Warna Aksen", "Warna halo, cahaya, orbit, trail", "GANTI", function()
    palIdx = palIdx % #PAL + 1
    local col = accent()
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
            Material = Enum.Material.Neon, Color = accent(), Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false}, workspace)
    end
    orb.conn = RunService.Heartbeat:Connect(function()
        local r = getRoot()
        if not r then return end
        local t = tick() * 2
        for i, p in ipairs(orb.parts) do
            local a = t + (i - 1) * math.pi * 2 / 3
            p.Position = r.Position + Vector3.new(math.cos(a) * 3, math.sin(t + i) * 0.8, math.sin(a) * 3)
            p.Color = accent()
        end
    end)
end
FEATURES.orbit = toggle("Bola Orbit", "3 bola neon mengelilingimu", setOrbit)

--------------------------------------------------------------- MUSIK (6)
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

--------------------------------------------------------------- SISTEM / UTILITAS (10)
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

local function copyText(txt, label)
    if setclipboard then
        setclipboard(txt)
        notify(label .. " disalin", P.color)
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
    if sound then sound:Destroy() end
end)
