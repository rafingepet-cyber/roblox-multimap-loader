--[[
╔══════════════════════════════════════════════╗
║           N E X U S   D E L T A              ║
║     INTERACTIVE UPDATE SYSTEM • v1.1.0       ║
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

-- Palette Neon Cyber
local C = {
    bg       = Color3.fromRGB(10, 14, 28),
    panel    = Color3.fromRGB(18, 24, 45),
    card     = Color3.fromRGB(24, 32, 60),
    card2    = Color3.fromRGB(32, 42, 78),
    white    = Color3.fromRGB(255, 255, 255),
    muted    = Color3.fromRGB(140, 160, 195),
    cyan     = Color3.fromRGB(0, 245, 255),
    purple   = Color3.fromRGB(190, 60, 255),
    pink     = Color3.fromRGB(255, 45, 180),
    green    = Color3.fromRGB(50, 255, 150),
    red      = Color3.fromRGB(255, 65, 65),
}

-- Cek Versi ke Server Hosting
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

-- Clean up GUI lama
local old = playerGui:FindFirstChild("NEXUS_DELTA")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NEXUS_DELTA"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

if not needsUpdate then
    print("[NEXUS] Versi sudah aman/terbaru.")
    return
end

--==================================================
-- UI DIALOG UPDATE (INTERAKTIF & ANIMATED)
--==================================================

local lockFrame = Instance.new("Frame")
lockFrame.AnchorPoint = Vector2.new(0.5, 0.5)
lockFrame.Position = UDim2.fromScale(0.5, 0.5)
lockFrame.Size = UDim2.fromOffset(10, 10) -- Awal animasi zoom-in
lockFrame.BackgroundColor3 = C.bg
lockFrame.BorderSizePixel = 0
lockFrame.ClipsDescendants = true
lockFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = lockFrame

local stroke = Instance.new("UIStroke")
stroke.Color = C.purple
stroke.Thickness = 2
stroke.Parent = lockFrame

-- Animasi Pop-Up Pembuka (Zoom In)
TweenService:Create(lockFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(360, 270)
}):Play()

local title = Instance.new("TextLabel")
title.Position = UDim2.new(0, 20, 0, 18)
title.Size = UDim2.new(1, -40, 0, 25)
title.BackgroundTransparency = 1
title.Text = "⚡ UPDATE TERSEDIA!"
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextColor3 = C.pink
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = lockFrame

local desc = Instance.new("TextLabel")
desc.Position = UDim2.new(0, 20, 0, 48)
desc.Size = UDim2.new(1, -40, 0, 40)
desc.BackgroundTransparency = 1
desc.Text = "Versi " .. VERSION .. " terdeteksi usang.\nVersi terbaru v" .. requiredVersion .. " sudah dirilis di GitHub!"
desc.Font = Enum.Font.GothamMedium
desc.TextSize = 10
desc.TextColor3 = C.muted
desc.TextWrapped = true
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.Parent = lockFrame

-- Progress Bar UI
local barBack = Instance.new("Frame")
barBack.Position = UDim2.new(0, 20, 0, 100)
barBack.Size = UDim2.new(1, -40, 0, 12)
barBack.BackgroundColor3 = C.panel
barBack.BorderSizePixel = 0
barBack.Parent = lockFrame
Instance.new("UICorner", barBack).CornerRadius = UDim.new(0, 6)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = C.cyan
barFill.BorderSizePixel = 0
barFill.Parent = barBack
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 6)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.purple),
    ColorSequenceKeypoint.new(1, C.cyan)
})
gradient.Parent = barFill

local statusLbl = Instance.new("TextLabel")
statusLbl.Position = UDim2.new(0, 20, 0, 120)
statusLbl.Size = UDim2.new(1, -40, 0, 20)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Tekan tombol di bawah untuk memulai update."
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextSize = 9
statusLbl.TextColor3 = C.cyan
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = lockFrame

-- Tombol Update Utama
local updateBtn = Instance.new("TextButton")
updateBtn.Position = UDim2.new(0, 20, 0, 180)
updateBtn.Size = UDim2.new(1, -40, 0, 45)
updateBtn.BackgroundColor3 = C.card2
updateBtn.BorderSizePixel = 0
updateBtn.Text = "🚀 UPDATE SEKARANG (v" .. requiredVersion .. ")"
updateBtn.Font = Enum.Font.GothamBold
updateBtn.TextSize = 11
updateBtn.TextColor3 = C.white
updateBtn.AutoButtonColor = false
updateBtn.Parent = lockFrame

Instance.new("UICorner", updateBtn).CornerRadius = UDim.new(0, 12)
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = C.cyan
btnStroke.Thickness = 1.5
btnStroke.Parent = updateBtn

-- Animasi Hover Tombol
updateBtn.MouseEnter:Connect(function()
    TweenService:Create(updateBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.purple}):Play()
end)
updateBtn.MouseLeave:Connect(function()
    TweenService:Create(updateBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.card2}):Play()
end)

--==================================================
-- PROSES UPDATE & AUTO-RUN
--==================================================

local isUpdating = false
updateBtn.Activated:Connect(function()
    if isUpdating then return end
    isUpdating = true

    -- Animasi Tombol Mengancil Saat Ditekan
    TweenService:Create(updateBtn, TweenInfo.new(0.15), {Size = UDim2.new(1, -50, 0, 40), Position = UDim2.new(0, 25, 0, 182)}):Play()
    task.wait(0.15)
    updateBtn.Text = "DOWLOADING..."

    task.spawn(function()
        local loadstringCode = 'loadstring(game:HttpGet("' .. LATEST_SCRIPT_URL .. '?v=' .. tick() .. '"))()'

        -- Step 1: Minta Akses & Menghubungkan
        TweenService:Create(barFill, TweenInfo.new(0.4), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
        statusLbl.Text = "Status: Menghubungkan ke GitHub Raw..."
        task.wait(0.5)

        -- Step 2: Download Script Terbaru
        TweenService:Create(barFill, TweenInfo.new(0.5), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
        statusLbl.Text = "Status: Mengunduh NEXUS-DELTA-v" .. requiredVersion .. ".lua..."
        task.wait(0.5)

        -- Step 3: Salin Kode Ke HP User (Clipboard)
        if setclipboard then
            setclipboard(loadstringCode)
            statusLbl.Text = "Status: ✅ Perintah Loadstring tersalin ke HP!"
        else
            statusLbl.Text = "Status: Memasang script baru..."
        end

        -- Step 4: Selesai 100%
        TweenService:Create(barFill, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(0.4)

        -- Step 5: Animasi Tutup UI V1.1.0 (Fade Out & Shrink)
        TweenService:Create(lockFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.35)
        gui:Destroy()

        -- Step 6: AUTO-RUN SCRIPT V1.2.0!
        local success, err = pcall(function()
            loadstring(game:HttpGet(LATEST_SCRIPT_URL .. "?v=" .. tick()))()
        end)

        if not success then
            warn("[NEXUS] Gagal Auto-Run v1.2.0: " .. tostring(err))
        end
    end)
end)
