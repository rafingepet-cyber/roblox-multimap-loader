--[[
  NEXUS DELTA v1.2.0 • Smart Map Hub
  Menu otomatis menyesuaikan map: Brookhaven -> menu Brookhaven saja, dst.
  Map tidak dikenal -> mode Universal.
]]

local VERSION = "1.2.0"
local API_URL = "https://nebul.rf.gd/api.php"
local GITHUB_URL = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA-v1.2.0.lua"

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

local KEYWORDS = {
    {kw = "brookhaven",     id = "brookhaven"},
    {kw = "adopt me",       id = "adoptme"},
    {kw = "murder mystery", id = "mm2"},
    {kw = "blox fruits",    id = "bloxfruits"},
}

local PROFILES = {
    brookhaven = {
        name = "Brookhaven RP", short = "BH", color = C.green, color2 = C.cyan,
        tagline = "Roleplay  •  Rumah  •  Kendaraan",
        tabs = {
            {name = "Gerak",    features = {"speed", "jump", "fly", "flyspeed", "noclip", "infjump"}},
            {name = "Teleport", features = {"tpplayer", "savepos", "gotopos"}},
            {name = "Visual",   features = {"fullbright"}},
            {name = "Sistem",   features = {"antiafk", "rejoin"}},
        },
    },
    adoptme = {
        name = "Adopt Me!", short = "AM", color = C.pink, color2 = C.purple,
        tagline = "Pet  •  Trading  •  Idle farming",
        tabs = {
            {name = "Gerak",    features = {"speed", "jump", "fly", "flyspeed"}},
            {name = "Teleport", features = {"tpplayer", "savepos", "gotopos"}},
            {name = "Sistem",   features = {"antiafk", "rejoin"}},
        },
    },
    mm2 = {
        name = "Murder Mystery 2", short = "MM", color = C.orange, color2 = C.pink,
        tagline = "Gerak cepat  •  Navigasi map",
        tabs = {
            {name = "Gerak",    features = {"speed", "jump", "fly", "flyspeed", "noclip", "infjump"}},
            {name = "Teleport", features = {"tpplayer"}},
            {name = "Visual",   features = {"fullbright"}},
        },
    },
    bloxfruits = {
        name = "Blox Fruits", short = "BF", color = C.blue, color2 = C.cyan,
        tagline = "Sea  •  Eksplorasi pulau",
        tabs = {
            {name = "Gerak",  features = {"speed", "jump", "fly", "flyspeed", "infjump"}},
            {name = "Visual", features = {"fullbright"}},
            {name = "Sistem", features = {"antiafk", "rejoin"}},
        },
    },
    universal = {
        name = "Universal", short = "NX", color = C.purple, color2 = C.cyan,
        tagline = "Map belum punya menu khusus",
        tabs = {
            {name = "Gerak",    features = {"speed", "jump", "fly", "flyspeed", "noclip", "infjump"}},
            {name = "Teleport", features = {"tpplayer", "savepos", "gotopos"}},
            {name = "Visual",   features = {"fullbright"}},
            {name = "Sistem",   features = {"antiafk", "rejoin"}},
        },
    },
}

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
-- STATE & CLEANUP
--==================================================
--==================================================
-- NEXUS UPDATE (gate versi, cara kerja sama seperti v1.1.0)
-- Kalau API_URL melaporkan versi lebih baru, dialog update tampil,
-- script terbaru diunduh dari GITHUB_URL (nama file: NEXUS-DELTA-vX.Y.Z.lua)
-- lalu langsung dijalankan. API boleh mengirim "url" untuk menimpa alamatnya.
--==================================================
local function latestScriptUrl(ver)
    if config and (config.url or config.script_url) then
        return tostring(config.url or config.script_url)
    end
    return (string.gsub(GITHUB_URL, "%-v%d+%.%d+%.%d+%.lua$", "-v" .. ver .. ".lua"))
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

            local fn, compileErr = loadstring(src)
            if not fn then
                warn("[NEXUS] Script tidak valid: " .. tostring(compileErr))
                return fail("Script terbaru tidak valid.")
            end

            if setclipboard then
                pcall(setclipboard, 'loadstring(game:HttpGet("' .. scriptUrl .. '"))()')
            end

            setProgress(1, "Update selesai!", C.green)
            btnLabel.Text = "Selesai ✓"
            tween(btnFill, 0.2, {BackgroundTransparency = 0})
            task.wait(0.7)

            closeAnim()
            showUpdateToast(requiredVersion)

            local runOk, runErr = pcall(fn)
            if not runOk then
                warn("[NEXUS] Gagal menjalankan v" .. requiredVersion .. ": " .. tostring(runErr))
            end
        end)
    end)
end

if config and config.version and compareVersion(config.version, VERSION) > 0 then
    showUpdateDialog(tostring(config.version))
    return
end

--==================================================
-- STATE (lanjutan)
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
        Text = tab.name, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.muted, AutoButtonColor = false, LayoutOrder = i,
    }, tabBar)
    round(tb, 9)
    tabButtons[i] = tb
    tb.Activated:Connect(function() showTab(i) end)
end

showTab(1)

--==================================================
-- DRAG
--==================================================
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
