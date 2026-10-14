--[[
    NEXUS DELTA v1.1.0
    Auto Version Discovery + Version Picker
    Original UI preserved: Dark / Purple / Cyan
]]

local VERSION = "1.1.0"
local API_URL = "https://nebul.rf.gd/api.php"

local GITHUB_API =
    "https://api.github.com/repos/rafingepet-cyber/roblox-multimap-loader/contents/delta?ref=main"

local RAW_BASE =
    "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/"

local ALLOW_SKIP = false

local DEFAULT_REASON =
    "Versi lama sudah tidak didukung. Update membawa perbaikan bug, fitur baru, dan performa lebih stabil."

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
-- VERSI
--==================================================

local function parseVersion(v)
    local a, b, c = tostring(v or "0.0.0"):match(
        "^(%d+)%.(%d+)%.?(%d*)$"
    )

    return {
        tonumber(a) or 0,
        tonumber(b) or 0,
        tonumber(c) or 0
    }
end

local function compareVersion(a, b)
    local va = parseVersion(a)
    local vb = parseVersion(b)

    for i = 1, 3 do
        if va[i] > vb[i] then
            return 1
        elseif va[i] < vb[i] then
            return -1
        end
    end

    return 0
end

local function isOutdated(current, target)
    return compareVersion(target, current) > 0
end

local function fetchJSON(url)
    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(response) ~= "string" then
        return nil
    end

    local decoded, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decoded or type(data) ~= "table" then
        return nil
    end

    return data
end

local function fetchConfig()
    return fetchJSON(API_URL .. "?t=" .. tostring(os.time()))
end

local function discoverVersions()
    local data = fetchJSON(GITHUB_API .. "&t=" .. tostring(os.time()))
    local versions = {}

    if type(data) ~= "table" then
        warn("[NEXUS] Tidak dapat membaca daftar versi GitHub.")
        return versions
    end

    for _, file in ipairs(data) do
        if type(file) == "table"
            and file.type == "file"
            and type(file.name) == "string" then

            local ver = file.name:match(
                "^NEXUS%-DELTA%-v(%d+%.%d+%.?%d*)%.lua$"
            )

            if ver then
                table.insert(versions, {
                    version = ver,
                    filename = file.name,
                    url = RAW_BASE .. file.name
                })
            end
        end
    end

    table.sort(versions, function(a, b)
        return compareVersion(a.version, b.version) > 0
    end)

    return versions
end

local configData = fetchConfig()
local versions = discoverVersions()

if #versions == 0 then
    warn("[NEXUS] Tidak ada versi yang ditemukan. Periksa folder GitHub delta.")
    return
end

local latest = versions[1]

-- Jika API menyediakan versi yang lebih baru dan file-nya memang
-- ditemukan di GitHub, gunakan file GitHub tersebut sebagai sumber.
local requiredVersion = latest.version

if configData and configData.version then
    for _, item in ipairs(versions) do
        if item.version == tostring(configData.version) then
            if compareVersion(item.version, requiredVersion) > 0 then
                requiredVersion = item.version
                latest = item
            end
            break
        end
    end
end

local reasonText = tostring(
    (configData and (configData.reason or configData.notes))
    or DEFAULT_REASON
)

-- Amankan teks karena alasan ditampilkan menggunakan RichText.
reasonText = reasonText
    :gsub("&", "&amp;")
    :gsub("<", "&lt;")
    :gsub(">", "&gt;")

-- Versi lama yang tidak memiliki pembaruan tidak perlu menampilkan dialog.
if not isOutdated(VERSION, requiredVersion) then
    print("[NEXUS] Versi " .. VERSION .. " sudah terbaru.")
    return
end

--==================================================
-- HELPER UI
--==================================================

local function make(class, props, parent)
    local inst = Instance.new(class)

    for k, v in pairs(props) do
        inst[k] = v
    end

    inst.Parent = parent
    return inst
end

local function round(parent, radius)
    return make("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, parent)
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            style or Enum.EasingStyle.Quad,
            dir or Enum.EasingDirection.Out
        ),
        props
    )

    t:Play()
    return t
end

local function rgbTag(color)
    return string.format(
        "rgb(%d,%d,%d)",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

--==================================================
-- NOTIFIKASI SELESAI
--==================================================

local function showDoneToast(ver)
    local old = playerGui:FindFirstChild("NEXUS_UPDATE_TOAST")

    if old then
        old:Destroy()
    end

    local toastGui = make("ScreenGui", {
        Name = "NEXUS_UPDATE_TOAST",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
    }, playerGui)

    local toast = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -90),
        Size = UDim2.fromOffset(310, 62),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
    }, toastGui)

    round(toast, 16)

    make("UIStroke", {
        Color = C.green,
        Thickness = 1.2,
        Transparency = 0.3,
    }, toast)

    local check = make("Frame", {
        Position = UDim2.fromOffset(14, 15),
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = C.green,
        BorderSizePixel = 0,
    }, toast)

    round(check, 16)

    make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "✓",
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextColor3 = C.bg,
    }, check)

    make("TextLabel", {
        Position = UDim2.fromOffset(58, 12),
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = "Update selesai",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toast)

    make("TextLabel", {
        Position = UDim2.fromOffset(58, 33),
        Size = UDim2.new(1, -70, 0, 16),
        BackgroundTransparency = 1,
        Text = "NEXUS DELTA v" .. ver .. " berhasil dimuat",
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextColor3 = C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, toast)

    tween(
        toast,
        0.45,
        {Position = UDim2.new(0.5, 0, 0, 24)},
        Enum.EasingStyle.Back
    )

    task.delay(3.6, function()
        if not toast.Parent then
            return
        end

        tween(
            toast,
            0.3,
            {Position = UDim2.new(0.5, 0, 0, -90)},
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        )

        task.wait(0.35)

        if toastGui.Parent then
            toastGui:Destroy()
        end
    end)
end

--==================================================
-- BERSIHKAN UI LAMA
--==================================================

for _, name in ipairs({
    "NEXUS_DELTA",
    "NEXUS_UPDATE",
    "NEXUS_VERSION_PICKER"
}) do
    local old = playerGui:FindFirstChild(name)

    if old then
        old:Destroy()
    end
end

--==================================================
-- DIALOG UPDATE UTAMA
--==================================================

local gui = make("ScreenGui", {
    Name = "NEXUS_UPDATE",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
}, playerGui)

local overlay = make("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = true,
}, gui)

local CARD_H = ALLOW_SKIP and 352 or 326

local card = make("CanvasGroup", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(330, CARD_H),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    GroupTransparency = 1,
}, overlay)

round(card, 20)

make("UIStroke", {
    Color = C.line,
    Thickness = 1,
}, card)

local cardScale = make("UIScale", {
    Scale = 0.92,
}, card)

local accent = make("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = C.white,
    BorderSizePixel = 0,
}, card)

make("UIGradient", {
    Color = ColorSequence.new(C.purple, C.cyan),
}, accent)

-- Header
local badge = make("Frame", {
    Position = UDim2.fromOffset(20, 22),
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
    Position = UDim2.fromOffset(74, 22),
    Size = UDim2.new(1, -94, 0, 22),
    BackgroundTransparency = 1,
    Text = "Nexus Update",
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = C.white,
    TextXAlignment = Enum.TextXAlignment.Left,
}, card)

make("TextLabel", {
    Position = UDim2.fromOffset(74, 45),
    Size = UDim2.new(1, -94, 0, 18),
    BackgroundTransparency = 1,
    Text = "NEXUS DELTA • Update tersedia",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = C.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, card)

-- Baris versi
local row = make("Frame", {
    Position = UDim2.fromOffset(20, 78),
    Size = UDim2.new(1, -40, 0, 50),
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
            rgbTag(C.muted),
            caption,
            rgbTag(color),
            ver
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

-- Alasan update
local reasonBox = make("Frame", {
    Position = UDim2.fromOffset(20, 136),
    Size = UDim2.new(1, -40, 0, 48),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0,
}, card)

round(reasonBox, 12)

make("UIStroke", {
    Color = C.line,
    Thickness = 1,
    Transparency = 0.5,
}, reasonBox)

local reasonLbl = make("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    RichText = true,
    Text = '<font color="' .. rgbTag(C.cyan) ..
        '"><b>Kenapa harus update?</b></font>\n' .. reasonText,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = C.muted,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
}, reasonBox)

make("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 4),
}, reasonLbl)

-- Progress bar
local barBack = make("Frame", {
    Position = UDim2.fromOffset(20, 196),
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

make("UIGradient", {
    Color = ColorSequence.new(C.purple, C.cyan),
}, barFill)

local statusLbl = make("TextLabel", {
    Position = UDim2.fromOffset(20, 207),
    Size = UDim2.new(1, -90, 0, 18),
    BackgroundTransparency = 1,
    Text = "Versi baru ditemukan",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = C.muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, card)

local percentLbl = make("TextLabel", {
    Position = UDim2.new(1, -70, 0, 207),
    Size = UDim2.fromOffset(50, 18),
    BackgroundTransparency = 1,
    Text = "0%",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = C.cyan,
    TextXAlignment = Enum.TextXAlignment.Right,
}, card)

--==================================================
-- TOMBOL
--==================================================

local function createGradientButton(parent, position, size, text, colorA, colorB)
    local button = make("TextButton", {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    }, parent)

    local scale = make("UIScale", {
        Scale = 1,
    }, button)

    local fill = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.white,
        BorderSizePixel = 0,
    }, button)

    round(fill, 13)

    make("UIGradient", {
        Color = ColorSequence.new(colorA, colorB),
    }, fill)

    local label = make("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 2,
    }, button)

    button.MouseButton1Down:Connect(function()
        tween(scale, 0.1, {
            Scale = 0.96
        })
    end)

    local function release()
        tween(scale, 0.15, {
            Scale = 1
        }, Enum.EasingStyle.Back)
    end

    button.MouseButton1Up:Connect(release)
    button.MouseLeave:Connect(release)

    return button, label, fill
end

local updateBtn, btnLabel, btnFill = createGradientButton(
    card,
    UDim2.fromOffset(20, 234),
    UDim2.new(1, -40, 0, 42),
    "Update Terbaru  →",
    C.purple,
    C.cyan
)

local versionBtn = make("TextButton", {
    Position = UDim2.fromOffset(20, 282),
    Size = UDim2.new(1, -40, 0, 28),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0,
    Text = "Pilih Versi Lain  ▾",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = C.cyan,
    AutoButtonColor = false,
}, card)

round(versionBtn, 10)

make("UIStroke", {
    Color = C.line,
    Thickness = 1,
}, versionBtn)

local skipBtn

if ALLOW_SKIP then
    skipBtn = make("TextButton", {
        Position = UDim2.fromOffset(20, 316),
        Size = UDim2.new(1, -40, 0, 24),
        BackgroundTransparency = 1,
        Text = "Nanti saja",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = C.muted,
        AutoButtonColor = false,
    }, card)
end

--==================================================
-- ANIMASI
--==================================================

tween(overlay, 0.3, {
    BackgroundTransparency = 0.45
})

tween(card, 0.3, {
    GroupTransparency = 0
})

tween(cardScale, 0.4, {
    Scale = 1
}, Enum.EasingStyle.Back)

local pickerGui
local isUpdating = false
local downloadAndRun

local function closeAnim()
    if not gui or not gui.Parent then
        return
    end

    tween(card, 0.25, {
        GroupTransparency = 1
    })

    tween(cardScale, 0.25, {
        Scale = 0.92
    }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    tween(overlay, 0.3, {
        BackgroundTransparency = 1
    })

    task.wait(0.35)

    if gui.Parent then
        gui:Destroy()
    end
end

local function setProgress(p, text, color)
    tween(barFill, 0.35, {
        Size = UDim2.fromScale(p, 1)
    })

    percentLbl.Text = math.floor(p * 100) .. "%"

    if text then
        statusLbl.Text = text
    end

    statusLbl.TextColor3 = color or C.muted
end

local function failUpdate(msg)
    setProgress(0, msg, C.red)

    btnLabel.Text = "Coba Lagi"
    isUpdating = false
end

--==================================================
-- UNDUH DAN JALANKAN VERSI PILIHAN
--==================================================

downloadAndRun = function(item)
    if isUpdating then
        return
    end

    if type(item) ~= "table"
        or type(item.url) ~= "string"
        or type(item.version) ~= "string" then
        return
    end

    isUpdating = true

    if pickerGui then
        pickerGui:Destroy()
        pickerGui = nil
    end

    btnLabel.Text = "Mengunduh v" .. item.version .. "..."
    setProgress(0, "Menghubungkan ke GitHub...")

    task.spawn(function()
        setProgress(0.15, "Mengunduh v" .. item.version .. "...")

        local ok, src = pcall(function()
            return game:HttpGet(
                item.url .. "?t=" .. tostring(os.time())
            )
        end)

        if not ok or type(src) ~= "string" or #src < 20 then
            failUpdate("Gagal mengunduh. Cek koneksi lalu coba lagi.")
            return
        end

        setProgress(0.65, "Memeriksa kode Lua...")

        local compileOK, fn, compileErr = pcall(function()
            return loadstring(src)
        end)

        if not compileOK or type(fn) ~= "function" then
            warn("[NEXUS] Gagal memeriksa script: " .. tostring(compileErr))
            failUpdate("Script tidak valid atau loadstring tidak tersedia.")
            return
        end

        if setclipboard then
            pcall(function()
                setclipboard(
                    'loadstring(game:HttpGet("' ..
                    item.url ..
                    '"))()'
                )
            end)
        end

        setProgress(1, "Script berhasil diunduh dan diperiksa.", C.green)
        btnLabel.Text = "Selesai ✓"

        task.wait(0.6)
        closeAnim()

        -- Jalankan kode yang telah berhasil dikompilasi.
        local runOK, runErr = pcall(fn)

        if not runOK then
            warn(
                "[NEXUS] Gagal menjalankan v" ..
                item.version .. ": " .. tostring(runErr)
            )
        end

        showDoneToast(item.version)
        isUpdating = false
    end)
end

--==================================================
-- PILIH VERSI
--==================================================

local function chooseVersion()
    if isUpdating then
        return
    end

    if pickerGui then
        pickerGui:Destroy()
        pickerGui = nil
        return
    end

    pickerGui = make("ScreenGui", {
        Name = "NEXUS_VERSION_PICKER",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1001,
    }, playerGui)

    local shade = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
    }, pickerGui)

    local panel = make("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.88, 0, 0.65, 0),
        BackgroundColor3 = C.bg,
        BorderSizePixel = 0,
        GroupTransparency = 1,
    }, shade)

    round(panel, 18)

    make("UIStroke", {
        Color = C.line,
        Thickness = 1,
    }, panel)

    make("TextLabel", {
        Position = UDim2.fromOffset(16, 14),
        Size = UDim2.new(1, -70, 0, 25),
        BackgroundTransparency = 1,
        Text = "Pilih Versi",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)

    local closeBtn = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.fromOffset(32, 30),
        BackgroundColor3 = C.card,
        BorderSizePixel = 0,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = C.muted,
        AutoButtonColor = false,
    }, panel)

    round(closeBtn, 9)

    closeBtn.Activated:Connect(function()
        if pickerGui then
            pickerGui:Destroy()
            pickerGui = nil
        end
    end)

    make("TextLabel", {
        Position = UDim2.fromOffset(16, 41),
        Size = UDim2.new(1, -32, 0, 20),
        BackgroundTransparency = 1,
        Text = "Pilih rilis yang tersedia di GitHub",
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextColor3 = C.muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)

    local list = make("ScrollingFrame", {
        Position = UDim2.fromOffset(12, 68),
        Size = UDim2.new(1, -24, 1, -82),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.cyan,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, panel)

    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    for index, item in ipairs(versions) do
        local isLatest = item.version == latest.version
        local isCurrent = item.version == VERSION

        local labelText = "v" .. item.version

        if isLatest then
            labelText = labelText .. "   •   TERBARU"
        elseif isCurrent then
            labelText = labelText .. "   •   VERSI SAAT INI"
        end

        local entry = make("TextButton", {
            LayoutOrder = index,
            Size = UDim2.new(1, -4, 0, 46),
            BackgroundColor3 = C.card,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, list)

        round(entry, 11)

        make("UIStroke", {
            Color = isLatest and C.cyan or C.line,
            Thickness = 1,
            Transparency = isLatest and 0.1 or 0.45,
        }, entry)

        make("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            Text = labelText,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = isLatest and C.cyan or C.white,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, entry)

        entry.Activated:Connect(function()
            downloadAndRun(item)
        end)
    end

    tween(panel, 0.25, {
        GroupTransparency = 0
    })

    if not panel:FindFirstChildOfClass("UIScale") then
        local scale = make("UIScale", {
            Scale = 0.96
        }, panel)

        tween(scale, 0.3, {
            Scale = 1
        }, Enum.EasingStyle.Back)
    end
end

--==================================================
-- EVENT TOMBOL
--==================================================

updateBtn.Activated:Connect(function()
    downloadAndRun(latest)
end)

versionBtn.Activated:Connect(chooseVersion)

if skipBtn then
    skipBtn.Activated:Connect(function()
        if isUpdating then
            return
        end

        closeAnim()
    end)
end

print(
    "[NEXUS] v" .. VERSION ..
    " | Versi GitHub terbaru: v" .. latest.version ..
    " | Total rilis: " .. #versions
)
