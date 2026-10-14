
--[[
    NEXUS DELTA v1.2.0
    Smart Map Hub + Automatic Version Updater
    Single-file Lua
]]

local VERSION = "1.2.0"
local REPO_API = "https://api.github.com/repos/rafingepet-cyber/roblox-multimap-loader/contents/delta?ref=main"
local RAW_BASE = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/"
local API_URL = "https://nebul.rf.gd/api.php"

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
    bg = Color3.fromRGB(11,14,27),
    panel = Color3.fromRGB(18,23,42),
    card = Color3.fromRGB(24,31,56),
    card2 = Color3.fromRGB(36,45,80),
    white = Color3.fromRGB(245,248,255),
    muted = Color3.fromRGB(135,150,182),
    line = Color3.fromRGB(48,60,100),
    cyan = Color3.fromRGB(0,229,255),
    purple = Color3.fromRGB(160,95,255),
    pink = Color3.fromRGB(255,80,180),
    green = Color3.fromRGB(60,235,150),
    orange = Color3.fromRGB(255,165,60),
    blue = Color3.fromRGB(70,135,255),
    red = Color3.fromRGB(255,95,110),
}

--==================================================
-- MAP PROFILES
--==================================================

local PLACE_IDS = {
    [4924922222] = "brookhaven",
    [920587237] = "adoptme",
    [142823291] = "mm2",
    [2753915549] = "bloxfruits",
    [4442272183] = "bloxfruits",
    [7449423635] = "bloxfruits",
}

local KEYWORDS = {
    {"brookhaven","brookhaven"},
    {"adopt me","adoptme"},
    {"murder mystery","mm2"},
    {"blox fruits","bloxfruits"},
}

local PROFILES = {
    brookhaven = {
        name="Brookhaven RP", short="BH",
        color=C.green, color2=C.cyan,
        tagline="Roleplay • Rumah • Kendaraan",
        tabs={
            {name="Gerak",features={"speed","jump","fly","flyspeed","noclip","infjump"}},
            {name="Teleport",features={"tpplayer","savepos","gotopos"}},
            {name="Visual",features={"fullbright"}},
            {name="Sistem",features={"antiafk","rejoin"}},
        },
    },
    adoptme = {
        name="Adopt Me!", short="AM",
        color=C.pink, color2=C.purple,
        tagline="Pet • Trading • Eksplorasi",
        tabs={
            {name="Gerak",features={"speed","jump","fly","flyspeed"}},
            {name="Teleport",features={"tpplayer","savepos","gotopos"}},
            {name="Sistem",features={"antiafk","rejoin"}},
        },
    },
    mm2 = {
        name="Murder Mystery 2", short="MM",
        color=C.orange, color2=C.pink,
        tagline="Gerak • Navigasi map",
        tabs={
            {name="Gerak",features={"speed","jump","fly","flyspeed","noclip","infjump"}},
            {name="Teleport",features={"tpplayer"}},
            {name="Visual",features={"fullbright"}},
        },
    },
    bloxfruits = {
        name="Blox Fruits", short="BF",
        color=C.blue, color2=C.cyan,
        tagline="Sea • Eksplorasi pulau",
        tabs={
            {name="Gerak",features={"speed","jump","fly","flyspeed","infjump"}},
            {name="Visual",features={"fullbright"}},
            {name="Sistem",features={"antiafk","rejoin"}},
        },
    },
    universal = {
        name="Universal", short="NX",
        color=C.purple, color2=C.cyan,
        tagline="Menu universal",
        tabs={
            {name="Gerak",features={"speed","jump","fly","flyspeed","noclip","infjump"}},
            {name="Teleport",features={"tpplayer","savepos","gotopos"}},
            {name="Visual",features={"fullbright"}},
            {name="Sistem",features={"antiafk","rejoin"}},
        },
    },
}

local function detectProfile()
    if PLACE_IDS[game.PlaceId] then
        return PLACE_IDS[game.PlaceId]
    end

    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    local name = string.lower((ok and info and info.Name) or game.Name or "")

    for _, entry in ipairs(KEYWORDS) do
        if string.find(name,entry[1],1,true) then
            return entry[2]
        end
    end

    return "universal"
end

local profileId = detectProfile()
local P = PROFILES[profileId] or PROFILES.universal

--==================================================
-- VERSION HELPERS
--==================================================

local function parts(v)
    local a,b,c = tostring(v or "0.0.0"):match("^(%d+)%.(%d+)%.?(%d*)$")
    return {tonumber(a) or 0,tonumber(b) or 0,tonumber(c) or 0}
end

local function compareVersion(a,b)
    local x,y = parts(a),parts(b)

    for i=1,3 do
        if x[i] > y[i] then return 1 end
        if x[i] < y[i] then return -1 end
    end

    return 0
end

local function make(class,props,parent)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj,r)
    return make("UICorner",{CornerRadius=UDim.new(0,r or 12)},obj)
end

local function stroke(obj,color,thickness,transparency)
    return make("UIStroke",{
        Color=color or C.line,
        Thickness=thickness or 1,
        Transparency=transparency or 0,
    },obj)
end

local function grad(obj,c1,c2,rotation)
    return make("UIGradient",{
        Color=ColorSequence.new(c1,c2),
        Rotation=rotation or 0,
    },obj)
end

local function tween(obj,duration,props,style,direction)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            duration,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        props
    )
    t:Play()
    return t
end

local function label(parent,text,pos,size,color,textSize)
    return make("TextLabel",{
        Position=pos,
        Size=size,
        BackgroundTransparency=1,
        Text=text,
        Font=Enum.Font.GothamMedium,
        TextSize=textSize or 12,
        TextColor3=color or C.white,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
    },parent)
end

local function smallBtn(parent,text,pos,size,bg,fg)
    local b = make("TextButton",{
        Position=pos,
        Size=size,
        BackgroundColor3=bg,
        BorderSizePixel=0,
        Text=text,
        Font=Enum.Font.GothamBold,
        TextSize=11,
        TextColor3=fg or C.white,
        AutoButtonColor=false,
    },parent)

    round(b,9)

    local sc = make("UIScale",{Scale=1},b)

    b.Activated:Connect(function()
        tween(sc,0.08,{Scale=0.94})
        task.delay(0.09,function()
            if b.Parent then
                tween(sc,0.12,{Scale=1})
            end
        end)
    end)

    return b
end

--==================================================
-- SERVER CONFIG + GITHUB VERSION DISCOVERY
--==================================================

local function fetchConfig()
    local ok,response = pcall(function()
        return game:HttpGet(API_URL.."?t="..tostring(os.time()))
    end)

    if not ok or type(response) ~= "string" then
        return nil
    end

    local decoded,data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if decoded and type(data) == "table" then
        return data
    end

    return nil
end

local config = fetchConfig()

local function discoverVersions()
    local ok,response = pcall(function()
        return game:HttpGet(REPO_API)
    end)

    if not ok or type(response) ~= "string" then
        return {}, "GitHub tidak dapat diakses"
    end

    local decoded,data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decoded or type(data) ~= "table" then
        return {}, "Respons GitHub tidak valid"
    end

    local versions = {}
    local seen = {}

    for _,item in ipairs(data) do
        local filename = item.name or ""
        local ver = filename:match("^NEXUS%-DELTA%-v(%d+%.%d+%.%d+)%.lua$")

        if ver and not seen[ver] then
            seen[ver] = true

            table.insert(versions,{
                version=ver,
                filename=filename,
                url=item.download_url or (RAW_BASE..filename),
            })
        end
    end

    table.sort(versions,function(a,b)
        return compareVersion(a.version,b.version) > 0
    end)

    return versions
end

--==================================================
-- UPDATE TOAST
--==================================================

local function showUpdateToast(ver)
    local old = playerGui:FindFirstChild("NEXUS_UPDATE_TOAST")
    if old then old:Destroy() end

    local gui = make("ScreenGui",{
        Name="NEXUS_UPDATE_TOAST",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        DisplayOrder=1000,
    },playerGui)

    local box = make("Frame",{
        AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,-85),
        Size=UDim2.fromOffset(310,62),
        BackgroundColor3=C.bg,
        BorderSizePixel=0,
    },gui)

    round(box,16)
    stroke(box,C.green,1.2,0.25)

    local icon = make("Frame",{
        Position=UDim2.fromOffset(14,15),
        Size=UDim2.fromOffset(32,32),
        BackgroundColor3=C.green,
        BorderSizePixel=0,
    },box)

    round(icon,16)

    make("TextLabel",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Text="✓",
        Font=Enum.Font.GothamBlack,
        TextSize=18,
        TextColor3=C.bg,
    },icon)

    label(box,"Update selesai",
        UDim2.fromOffset(58,10),
        UDim2.new(1,-70,0,22),C.white,14)

    label(box,"NEXUS DELTA v"..ver.." siap dijalankan",
        UDim2.fromOffset(58,33),
        UDim2.new(1,-70,0,16),C.muted,10)

    tween(box,0.45,{Position=UDim2.new(0.5,0,0,24)},Enum.EasingStyle.Back)

    task.delay(3.5,function()
        if gui.Parent then
            tween(box,0.3,{Position=UDim2.new(0.5,0,0,-85)})
            task.wait(0.35)
            if gui.Parent then gui:Destroy() end
        end
    end)
end

--==================================================
-- UPDATE DIALOG + VERSION PICKER
--==================================================

local function showUpdateDialog(versions,latest)
    for _,name in ipairs({"NEXUS_DELTA","NEXUS_UPDATE","NEXUS_VERSION_PICKER"}) do
        local old = playerGui:FindFirstChild(name)
        if old then old:Destroy() end
    end

    local reason = tostring(
        (config and (config.reason or config.notes))
        or "Versi terbaru tersedia dengan perbaikan dan pembaruan."
    )
    reason = reason:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")

    local gui = make("ScreenGui",{
        Name="NEXUS_UPDATE",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        DisplayOrder=999,
    },playerGui)

    local overlay = make("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Active=true,
    },gui)

    local card = make("CanvasGroup",{
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(330,350),
        BackgroundColor3=C.bg,
        BorderSizePixel=0,
        GroupTransparency=1,
    },overlay)

    round(card,20)
    stroke(card,C.line,1)
    local scale = make("UIScale",{Scale=0.92},card)

    local accent = make("Frame",{
        Size=UDim2.new(1,0,0,3),
        BackgroundColor3=C.white,
        BorderSizePixel=0,
    },card)
    grad(accent,C.purple,C.cyan)

    local badge = make("Frame",{
        Position=UDim2.fromOffset(20,18),
        Size=UDim2.fromOffset(42,42),
        BackgroundColor3=C.purple,
        BorderSizePixel=0,
    },card)
    round(badge,12)
    grad(badge,C.purple,C.cyan,45)

    make("TextLabel",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Text="↑",
        Font=Enum.Font.GothamBlack,
        TextSize=24,
        TextColor3=C.white,
    },badge)

    local title = label(card,"Nexus Update",
        UDim2.fromOffset(74,18),
        UDim2.new(1,-94,0,23),C.white,17)
    title.Font=Enum.Font.GothamBold

    label(card,"NEXUS DELTA • Update tersedia",
        UDim2.fromOffset(74,42),
        UDim2.new(1,-94,0,18),C.muted,10)

    local versionsRow = make("Frame",{
        Position=UDim2.fromOffset(20,72),
        Size=UDim2.new(1,-40,0,48),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
    },card)
    round(versionsRow,12)

    local currentLabel = make("TextLabel",{
        Position=UDim2.fromOffset(12,0),
        Size=UDim2.new(0.42,0,1,0),
        BackgroundTransparency=1,
        Text="TERPASANG\nv"..VERSION,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextColor3=C.muted,
        TextXAlignment=Enum.TextXAlignment.Left,
    },versionsRow)

    local arrow = make("TextLabel",{
        Position=UDim2.new(0.42,0,0,0),
        Size=UDim2.new(0.16,0,1,0),
        BackgroundTransparency=1,
        Text="→",
        Font=Enum.Font.GothamBold,
        TextSize=18,
        TextColor3=C.cyan,
    },versionsRow)

    local latestLabel = make("TextLabel",{
        Position=UDim2.new(0.58,0,0,0),
        Size=UDim2.new(0.42,-10,1,0),
        BackgroundTransparency=1,
        Text="TERBARU\nv"..latest.version,
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextColor3=C.green,
        TextXAlignment=Enum.TextXAlignment.Left,
    },versionsRow)

    local reasonBox = make("Frame",{
        Position=UDim2.fromOffset(20,130),
        Size=UDim2.new(1,-40,0,46),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
    },card)
    round(reasonBox,12)
    stroke(reasonBox,C.line,1,0.5)

    local reasonLabel = make("TextLabel",{
        Position=UDim2.fromOffset(10,4),
        Size=UDim2.new(1,-20,1,-8),
        BackgroundTransparency=1,
        RichText=true,
        Text='<font color="rgb(0,229,255)"><b>Info update</b></font>\n'..reason,
        Font=Enum.Font.GothamMedium,
        TextSize=10,
        TextColor3=C.muted,
        TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
    },reasonBox)

    local progressBack = make("Frame",{
        Position=UDim2.fromOffset(20,185),
        Size=UDim2.new(1,-40,0,6),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
    },card)
    round(progressBack,3)

    local progressFill = make("Frame",{
        Size=UDim2.fromScale(0,1),
        BackgroundColor3=C.cyan,
        BorderSizePixel=0,
    },progressBack)
    round(progressFill,3)
    grad(progressFill,C.purple,C.cyan)

    local status = label(card,"Siap untuk update",
        UDim2.fromOffset(20,194),
        UDim2.new(1,-85,0,18),C.muted,10)

    local percent = label(card,"0%",
        UDim2.new(1,-65,0,194),
        UDim2.fromOffset(45,18),C.cyan,10)
    percent.TextXAlignment=Enum.TextXAlignment.Right

    local function setProgress(n,text,color)
        tween(progressFill,0.25,{Size=UDim2.fromScale(n,1)})
        percent.Text=tostring(math.floor(n*100)).."%"
        status.Text=text or status.Text
        status.TextColor3=color or C.muted
    end

    local updating=false
    local picker

    local function closeDialog()
        if gui.Parent then
            tween(card,0.2,{GroupTransparency=1})
            tween(scale,0.2,{Scale=0.92})
            tween(overlay,0.2,{BackgroundTransparency=1})
            task.wait(0.22)
            if gui.Parent then gui:Destroy() end
        end
    end

    local function downloadAndRun(item)
        if updating then return end
        updating=true

        if picker and picker.Parent then
            picker:Destroy()
            picker=nil
        end

        local url=item.url or (RAW_BASE..item.filename)
        setProgress(0.15,"Menghubungkan ke GitHub...")
        task.spawn(function()
            local ok,src=pcall(function()
                return game:HttpGet(url.."?t="..tostring(os.time()))
            end)

            if not ok or type(src)~="string" or #src<50 then
                setProgress(0,"Unduhan gagal. Periksa koneksi.",C.red)
                updating=false
                return
            end

            setProgress(0.55,"Memeriksa script...")
            task.wait(0.15)

            if type(loadstring)~="function" then
                setProgress(0,"Executor tidak mendukung loadstring.",C.red)
                updating=false
                return
            end

            local compileOk,fn,compileErr=pcall(loadstring,src)
            if not compileOk or type(fn)~="function" then
                warn("[NEXUS] Compile gagal: "..tostring(compileErr or fn))
                setProgress(0,"Script gagal divalidasi.",C.red)
                updating=false
                return
            end

            setProgress(1,"Berhasil disiapkan!",C.green)
            task.wait(0.3)
            closeDialog()

            task.spawn(function()
                local runOk,runErr=pcall(fn)
                if runOk then
                    showUpdateToast(item.version)
                else
                    warn("[NEXUS] Gagal menjalankan v"..item.version..": "..tostring(runErr))
                end
            end)
        end)
    end

    local updateBtn = make("TextButton",{
        Position=UDim2.fromOffset(20,222),
        Size=UDim2.new(1,-40,0,43),
        BackgroundColor3=C.purple,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=false,
    },card)
    round(updateBtn,12)
    grad(updateBtn,C.purple,C.cyan)

    local updateText = make("TextLabel",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Text="Update Sekarang  ↓",
        Font=Enum.Font.GothamBold,
        TextSize=13,
        TextColor3=C.white,
    },updateBtn)

    updateBtn.Activated:Connect(function()
        downloadAndRun(latest)
    end)

    local pickBtn = smallBtn(card,"PILIH VERSI",
        UDim2.fromOffset(20,273),
        UDim2.new(1,-40,0,36),C.card2,C.white)
    pickBtn.TextSize=12

    local note = label(card,
        "Versi ditemukan: "..tostring(#versions).." • GitHub",
        UDim2.fromOffset(20,313),
        UDim2.new(1,-40,0,18),C.muted,9)
    note.TextXAlignment=Enum.TextXAlignment.Center

    -- Version picker
    local function openPicker()
        if picker and picker.Parent then
            picker:Destroy()
            picker=nil
            return
        end

        picker=make("Frame",{
            Name="NEXUS_VERSION_PICKER",
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.5,0.5),
            Size=UDim2.fromOffset(320,380),
            BackgroundColor3=C.bg,
            BorderSizePixel=0,
            ZIndex=20,
        },gui)

        round(picker,18)
        stroke(picker,C.cyan,1.2)

        local head=label(picker,"Pilih Versi",
            UDim2.fromOffset(16,12),
            UDim2.new(1,-70,0,26),C.white,16)
        head.Font=Enum.Font.GothamBold

        local close=smallBtn(picker,"×",
            UDim2.new(1,-48,0,10),
            UDim2.fromOffset(32,30),C.card2,C.white)
        close.TextSize=18
        close.ZIndex=22
        close.Activated:Connect(function()
            if picker then picker:Destroy() picker=nil end
        end)

        local list=make("ScrollingFrame",{
            Position=UDim2.fromOffset(14,50),
            Size=UDim2.new(1,-28,1,-64),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ScrollBarThickness=3,
            ScrollBarImageColor3=C.cyan,
            CanvasSize=UDim2.new(),
            ZIndex=21,
        },picker)

        local layout=make("UIListLayout",{
            Padding=UDim.new(0,7),
            SortOrder=Enum.SortOrder.LayoutOrder,
        },list)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+4)
        end)

        for index,item in ipairs(versions) do
            local isLatest=item.version==latest.version
            local isCurrent=item.version==VERSION

            local caption="v"..item.version
            if isLatest then
                caption=caption.."   •   TERBARU"
            elseif isCurrent then
                caption=caption.."   •   TERPASANG"
            end

            local b=smallBtn(list,caption,
                UDim2.new(),UDim2.new(1,-6,0,39),
                isLatest and C.card2 or C.card,C.white)

            b.LayoutOrder=index
            b.TextXAlignment=Enum.TextXAlignment.Left
            b.TextSize=11
            b.ZIndex=22

            make("UIPadding",{
                PaddingLeft=UDim.new(0,12),
            },b)

            b.Activated:Connect(function()
                downloadAndRun(item)
            end)
        end
    end

    pickBtn.Activated:Connect(openPicker)

    tween(overlay,0.3,{BackgroundTransparency=0.45})
    tween(card,0.3,{GroupTransparency=0})
    tween(scale,0.4,{Scale=1},Enum.EasingStyle.Back)
end

-- Hanya munculkan dialog jika GitHub memiliki versi lebih baru.
local versions,versionError = discoverVersions()
local latest = versions[1]

if latest and compareVersion(latest.version,VERSION)>0 then
    showUpdateDialog(versions,latest)
    return
end

if #versions==0 then
    warn("[NEXUS] Daftar versi GitHub tidak tersedia: "..tostring(versionError))
end

--==================================================
-- STATE & CHARACTER
--==================================================

local connections={}
local function track(conn)
    table.insert(connections,conn)
    return conn
end

local function getChar()
    return player.Character
end

local function getHum()
    local char=getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char=getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local initialHum=getHum()
local speedDefault=initialHum and initialHum.WalkSpeed or 16
local jumpDefault=(initialHum and initialHum.UseJumpPower and initialHum.JumpPower) or 50

local custom={speed=nil,jump=nil}
local states={}

local function applyMovement()
    local hum=getHum()
    if not hum then return end
    if custom.speed then hum.WalkSpeed=custom.speed end
    if custom.jump then
        hum.UseJumpPower=true
        hum.JumpPower=custom.jump
    end
end

--==================================================
-- FLY
--==================================================

local fly={on=false,speed=50,bv=nil,bg=nil,conn=nil}

local function stopFly()
    fly.on=false

    if fly.conn then
        fly.conn:Disconnect()
        fly.conn=nil
    end

    if fly.bv then
        fly.bv:Destroy()
        fly.bv=nil
    end

    if fly.bg then
        fly.bg:Destroy()
        fly.bg=nil
    end

    local hum=getHum()
    if hum then hum.PlatformStand=false end
end

local function startFly()
    local root,hum=getRoot(),getHum()
    if not root or not hum then return false end

    stopFly()
    fly.on=true

    fly.bv=make("BodyVelocity",{
        MaxForce=Vector3.new(1e9,1e9,1e9),
        Velocity=Vector3.zero,
    },root)

    fly.bg=make("BodyGyro",{
        MaxTorque=Vector3.new(1e9,1e9,1e9),
        P=9e4,
        CFrame=root.CFrame,
    },root)

    hum.PlatformStand=true

    fly.conn=RunService.Heartbeat:Connect(function()
        local r,h=getRoot(),getHum()
        local camera=workspace.CurrentCamera

        if not r or not h or not fly.bv or not camera then return end

        local cf=camera.CFrame
        local flat=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
        local md=h.MoveDirection
        local velocity=Vector3.zero

        if md.Magnitude>0 and flat.Magnitude>0 then
            local forward=math.max(md:Dot(flat.Unit),0)
            velocity=md*fly.speed
                + Vector3.new(0,cf.LookVector.Y*forward*fly.speed,0)
        end

        fly.bv.Velocity=velocity

        if flat.Magnitude>0 then
            fly.bg.CFrame=CFrame.new(r.Position,r.Position+flat)
        end
    end)

    return true
end

track(player.CharacterAdded:Connect(function()
    task.wait(0.6)
    applyMovement()
    if fly.on then startFly() end
end))

--==================================================
-- NOCLIP / INFINITE JUMP
--==================================================

local noclipConn

local function setNoclip(on)
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn=nil
    end

    if on then
        noclipConn=RunService.Stepped:Connect(function()
            local char=getChar()
            if not char then return end

            for _,part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide=false
                end
            end
        end)
    end
end

local infConn

local function setInfJump(on)
    if infConn then
        infConn:Disconnect()
        infConn=nil
    end

    if on then
        infConn=UserInputService.JumpRequest:Connect(function()
            local hum=getHum()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

--==================================================
-- FULLBRIGHT / ANTI AFK
--==================================================

local originalLighting={
    Brightness=Lighting.Brightness,
    ClockTime=Lighting.ClockTime,
    FogEnd=Lighting.FogEnd,
    GlobalShadows=Lighting.GlobalShadows,
    Ambient=Lighting.Ambient,
}

local function setFullbright(on)
    if on then
        Lighting.Brightness=2
        Lighting.ClockTime=14
        Lighting.FogEnd=100000
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(190,190,190)
    else
        for key,value in pairs(originalLighting) do
            Lighting[key]=value
        end
    end
end

local afkConn

local function setAntiAfk(on)
    if afkConn then
        afkConn:Disconnect()
        afkConn=nil
    end

    if on then
        afkConn=player.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end

local savedCF

--==================================================
-- ROOT GUI
--==================================================

local oldGui=playerGui:FindFirstChild("NEXUS_DELTA")
if oldGui then oldGui:Destroy() end

local gui=make("ScreenGui",{
    Name="NEXUS_DELTA",
    ResetOnSpawn=false,
    IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=100,
},playerGui)

local main=make("Frame",{
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.new(0.9,0,0.82,0),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    ClipsDescendants=true,
},gui)

round(main,20)
stroke(main,P.color,1.6,0.15)

make("UISizeConstraint",{
    MinSize=Vector2.new(320,400),
    MaxSize=Vector2.new(520,660),
},main)

local mainScale=make("UIScale",{Scale=0.92},main)
tween(mainScale,0.35,{Scale=1},Enum.EasingStyle.Back)

local accent=make("Frame",{
    Size=UDim2.new(1,0,0,3),
    BackgroundColor3=C.white,
    BorderSizePixel=0,
    ZIndex=5,
},main)

grad(accent,P.color,P.color2)

--==================================================
-- TOAST
--==================================================

local toast=make("TextLabel",{
    AnchorPoint=Vector2.new(0.5,1),
    Position=UDim2.new(0.5,0,1,-40),
    Size=UDim2.fromOffset(250,30),
    BackgroundColor3=C.card2,
    BackgroundTransparency=1,
    TextTransparency=1,
    Text="",
    Font=Enum.Font.GothamMedium,
    TextSize=11,
    TextColor3=C.white,
    ZIndex=60,
    BorderSizePixel=0,
},main)

round(toast,10)

local toastToken=0

local function notify(message,color)
    toastToken+=1
    local token=toastToken

    toast.Text=message
    toast.TextColor3=color or C.white

    tween(toast,0.2,{
        BackgroundTransparency=0.05,
        TextTransparency=0,
    })

    task.delay(2,function()
        if token==toastToken and toast.Parent then
            tween(toast,0.3,{
                BackgroundTransparency=1,
                TextTransparency=1,
            })
        end
    end)
end

--==================================================
-- HEADER
--==================================================

local header=make("Frame",{
    Position=UDim2.fromOffset(0,3),
    Size=UDim2.new(1,0,0,68),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
},main)

local logo=make("Frame",{
    Position=UDim2.new(0,14,0.5,-20),
    Size=UDim2.fromOffset(40,40),
    BackgroundColor3=C.white,
    BorderSizePixel=0,
},header)

round(logo,12)
grad(logo,P.color,P.color2,45)

make("TextLabel",{
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    Text=P.short,
    Font=Enum.Font.GothamBlack,
    TextSize=17,
    TextColor3=C.bg,
},logo)

local title=label(header,P.name,
    UDim2.new(0,64,0,13),
    UDim2.new(1,-150,0,24),C.white,17)
title.Font=Enum.Font.GothamBlack

label(header,"NEXUS DELTA • v"..VERSION,
    UDim2.new(0,65,0,38),
    UDim2.new(1,-150,0,16),P.color,9)

local infoBtn=smallBtn(header,"i",
    UDim2.new(1,-86,0.5,-15),
    UDim2.fromOffset(30,30),C.card2,P.color)
infoBtn.TextSize=14

local closeBtn=smallBtn(header,"×",
    UDim2.new(1,-46,0.5,-15),
    UDim2.fromOffset(30,30),C.card2,C.white)
closeBtn.TextSize=20

local minimizeMenu,openMenu

--==================================================
-- MAP INFO
--==================================================

local mapInfo=make("Frame",{
    Position=UDim2.fromOffset(14,82),
    Size=UDim2.new(1,-28,0,30),
    BackgroundColor3=C.card,
    BorderSizePixel=0,
},main)

round(mapInfo,10)

local dot=make("Frame",{
    Position=UDim2.fromOffset(12,11),
    Size=UDim2.fromOffset(8,8),
    BackgroundColor3=P.color,
    BorderSizePixel=0,
},mapInfo)
round(dot,4)

label(mapInfo,"Map terdeteksi • "..P.tagline,
    UDim2.fromOffset(28,0),
    UDim2.new(1,-36,1,0),C.muted,10)

--==================================================
-- TABS AND CONTENT
--==================================================

local tabBar=make("Frame",{
    Position=UDim2.fromOffset(14,120),
    Size=UDim2.new(1,-28,0,34),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
},main)

round(tabBar,11)

make("UIPadding",{
    PaddingLeft=UDim.new(0,3),
    PaddingRight=UDim.new(0,3),
    PaddingTop=UDim.new(0,3),
    PaddingBottom=UDim.new(0,3),
},tabBar)

make("UIListLayout",{
    FillDirection=Enum.FillDirection.Horizontal,
    Padding=UDim.new(0,3),
    SortOrder=Enum.SortOrder.LayoutOrder,
},tabBar)

local content=make("ScrollingFrame",{
    Position=UDim2.fromOffset(14,162),
    Size=UDim2.new(1,-28,1,-202),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=P.color,
    CanvasSize=UDim2.new(),
},main)

local layout=make("UIListLayout",{
    Padding=UDim.new(0,8),
    SortOrder=Enum.SortOrder.LayoutOrder,
},content)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+8)
end)

label(main,"● ONLINE • Menu khusus map ini",
    UDim2.new(0,16,1,-30),
    UDim2.new(1,-32,0,22),C.green,9)

--==================================================
-- MODALS
--==================================================

local function openModal(titleText,height)
    local dim=make("TextButton",{
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.35,
        Text="",
        AutoButtonColor=false,
        BorderSizePixel=0,
        ZIndex=50,
    },main)

    local box=make("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.new(0.86,0,0,height),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        ZIndex=51,
    },dim)

    round(box,16)
    stroke(box,P.color,1.4)

    local t=label(box,titleText,
        UDim2.fromOffset(16,12),
        UDim2.new(1,-32,0,24),P.color,14)
    t.Font=Enum.Font.GothamBlack

    local closeBtnModal=smallBtn(box,"TUTUP",
        UDim2.new(0,16,1,-46),
        UDim2.new(1,-32,0,34),P.color,C.bg)

    local function close()
        if dim.Parent then dim:Destroy() end
    end

    closeBtnModal.Activated:Connect(close)
    return box,close
end

local function openPlayerPicker()
    local box,close=openModal("Teleport ke Pemain",300)

    local list=make("ScrollingFrame",{
        Position=UDim2.fromOffset(16,44),
        Size=UDim2.new(1,-32,1,-100),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=P.color,
        CanvasSize=UDim2.new(),
    },box)

    local ll=make("UIListLayout",{
        Padding=UDim.new(0,6),
    },list)

    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y)
    end)

    local count=0

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player then
            count+=1

            local b=smallBtn(list,
                plr.DisplayName.."  (@"..plr.Name..")",
                UDim2.new(),UDim2.new(1,-4,0,34),
                C.card2,C.white)

            b.TextSize=10

            b.Activated:Connect(function()
                local root=getRoot()
                local target=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

                if root and target then
                    root.CFrame=target.CFrame*CFrame.new(0,0,3)
                    notify("Teleport ke "..plr.DisplayName,P.color)
                else
                    notify("Pemain belum siap",C.red)
                end

                close()
            end)
        end
    end

    if count==0 then
        label(list,"Tidak ada pemain lain.",
            UDim2.new(),UDim2.new(1,0,0,30),C.muted,11)
    end
end

local function openInfo()
    local box,closeInfo=openModal("Nexus Info",270)

    local serverVersion=config and config.version
    local status

    if not serverVersion then
        status="Server API tidak tersedia."
    elseif compareVersion(serverVersion,VERSION)>0 then
        status="Update server: v"..tostring(serverVersion)
    else
        status="Pemeriksaan versi GitHub aktif."
    end

    local txt=label(box,"",
        UDim2.fromOffset(16,44),
        UDim2.new(1,-32,0,100),C.muted,11)

    txt.TextWrapped=true
    txt.TextYAlignment=Enum.TextYAlignment.Top
    txt.Text="Versi terpasang: v"..VERSION
        .."\nVersi API: "..(serverVersion and ("v"..tostring(serverVersion)) or "-")
        .."\nStatus: "..status
        .."\nMap: "..P.name
        .."\nProfil: "..profileId

    local offBtn=smallBtn(box,"MATIKAN SCRIPT",
        UDim2.new(0,16,1,-90),
        UDim2.new(1,-32,0,34),C.card2,C.red)

    offBtn.Activated:Connect(function()
        closeInfo()
        stopFly()
        setNoclip(false)
        setInfJump(false)
        setFullbright(false)
        setAntiAfk(false)

        for _,conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end

        gui:Destroy()
    end)
end

infoBtn.Activated:Connect(openInfo)

--==================================================
-- FEATURES
--==================================================

local FEATURES={
    speed={
        name="Kecepatan Jalan",
        desc="Atur WalkSpeed karakter",
        kind="stepper",min=16,max=120,step=8,
        get=function() return custom.speed or speedDefault end,
        set=function(v) custom.speed=v applyMovement() end,
    },
    jump={
        name="Tinggi Lompat",
        desc="Atur JumpPower karakter",
        kind="stepper",min=50,max=200,step=25,
        get=function() return custom.jump or jumpDefault end,
        set=function(v) custom.jump=v applyMovement() end,
    },
    fly={
        name="Terbang (Fly)",
        desc="Gerakan mengikuti kamera",
        kind="toggle",
        set=function(on)
            if on then return startFly() end
            stopFly()
        end,
    },
    flyspeed={
        name="Kecepatan Terbang",
        desc="Atur kecepatan Fly",
        kind="stepper",min=20,max=150,step=10,
        get=function() return fly.speed end,
        set=function(v) fly.speed=v end,
    },
    noclip={
        name="Noclip",
        desc="Nonaktifkan tabrakan karakter lokal",
        kind="toggle",
        set=function(on) setNoclip(on) end,
    },
    infjump={
        name="Infinite Jump",
        desc="Lompat berulang saat di udara",
        kind="toggle",
        set=function(on) setInfJump(on) end,
    },
    fullbright={
        name="Fullbright",
        desc="Terangkan pencahayaan lokal",
        kind="toggle",
        set=function(on) setFullbright(on) end,
    },
    antiafk={
        name="Anti-AFK",
        desc="Cegah idle pada klien",
        kind="toggle",
        set=function(on) setAntiAfk(on) end,
    },
    savepos={
        name="Simpan Posisi",
        desc="Simpan lokasi saat ini",
        kind="action",btn="SIMPAN",
        run=function()
            local root=getRoot()
            if root then
                savedCF=root.CFrame
                notify("Posisi tersimpan",P.color)
            else
                notify("Karakter belum siap",C.red)
            end
        end,
    },
    gotopos={
        name="Ke Posisi Tersimpan",
        desc="Kembali ke posisi yang disimpan",
        kind="action",btn="TELEPORT",
        run=function()
            local root=getRoot()

            if not savedCF then
                notify("Belum ada posisi tersimpan",C.red)
                return
            end

            if root then
                root.CFrame=savedCF
                notify("Teleport lokal berhasil",P.color)
            end
        end,
    },
    tpplayer={
        name="Teleport ke Pemain",
        desc="Pilih pemain dalam server",
        kind="action",btn="PILIH",
        run=openPlayerPicker,
    },
    rejoin={
        name="Rejoin Server",
        desc="Coba masuk kembali ke map",
        kind="action",btn="REJOIN",
        run=function()
            notify("Mencoba rejoin...",P.color)
            pcall(function()
                TeleportService:Teleport(game.PlaceId,player)
            end)
        end,
    },
}

--==================================================
-- FEATURE ROWS
--==================================================

local function buildRow(id,def,order)
    local row=make("Frame",{
        Size=UDim2.new(1,-4,0,58),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
        LayoutOrder=order,
    },content)

    round(row,13)
    stroke(row,C.line,1,0.3)

    local bar=make("Frame",{
        Position=UDim2.fromOffset(0,15),
        Size=UDim2.fromOffset(3,28),
        BackgroundColor3=P.color,
        BorderSizePixel=0,
    },row)

    round(bar,2)

    local titleRow=label(row,def.name,
        UDim2.fromOffset(14,9),
        UDim2.new(1,-130,0,20),C.white,12)
    titleRow.Font=Enum.Font.GothamBold

    local description=label(row,def.desc,
        UDim2.fromOffset(14,29),
        UDim2.new(1,-130,0,22),C.muted,9)
    description.TextWrapped=true
    description.TextYAlignment=Enum.TextYAlignment.Top

    if def.kind=="toggle" then
        local on=states[id]==true

        local pill=make("Frame",{
            AnchorPoint=Vector2.new(1,0.5),
            Position=UDim2.new(1,-14,0.5,0),
            Size=UDim2.fromOffset(46,24),
            BackgroundColor3=on and P.color or C.card2,
            BorderSizePixel=0,
        },row)

        round(pill,12)

        local knob=make("Frame",{
            AnchorPoint=Vector2.new(0,0.5),
            Position=on and UDim2.new(1,-22,0.5,0) or UDim2.new(0,2,0.5,0),
            Size=UDim2.fromOffset(20,20),
            BackgroundColor3=C.white,
            BorderSizePixel=0,
        },pill)

        round(knob,10)

        local hit=make("TextButton",{
            Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,
            Text="",
            ZIndex=3,
        },row)

        hit.Activated:Connect(function()
            local want=not states[id]
            local result=def.set(want)

            if result==false then
                notify("Karakter belum siap",C.red)
                return
            end

            states[id]=want

            tween(pill,0.18,{
                BackgroundColor3=want and P.color or C.card2,
            })

            tween(knob,0.18,{
                Position=want and UDim2.new(1,-22,0.5,0)
                    or UDim2.new(0,2,0.5,0),
            })
        end)

    elseif def.kind=="stepper" then
        local box=make("Frame",{
            AnchorPoint=Vector2.new(1,0.5),
            Position=UDim2.new(1,-12,0.5,0),
            Size=UDim2.fromOffset(108,28),
            BackgroundTransparency=1,
        },row)

        local minus=smallBtn(box,"−",
            UDim2.fromOffset(0,0),
            UDim2.fromOffset(28,28),C.card2,C.white)

        local plus=smallBtn(box,"+",
            UDim2.fromOffset(80,0),
            UDim2.fromOffset(28,28),C.card2,C.white)

        local value=make("TextLabel",{
            Position=UDim2.fromOffset(28,0),
            Size=UDim2.fromOffset(52,28),
            BackgroundTransparency=1,
            Text=tostring(math.floor(def.get())),
            Font=Enum.Font.GothamBold,
            TextSize=12,
            TextColor3=P.color,
        },box)

        local function change(delta)
            local v=math.clamp(
                math.floor(def.get())+delta,
                def.min,def.max
            )
            def.set(v)
            value.Text=tostring(v)
        end

        minus.Activated:Connect(function()
            change(-def.step)
        end)

        plus.Activated:Connect(function()
            change(def.step)
        end)

    else
        local b=smallBtn(row,def.btn or "JALANKAN",
            UDim2.new(1,-94,0.5,-14),
            UDim2.fromOffset(82,28),P.color,C.bg)

        b.Activated:Connect(function()
            def.run()
        end)
    end
end

--==================================================
-- TAB RENDERER
--==================================================

local tabButtons={}

local function showTab(index)
    for i,button in ipairs(tabButtons) do
        local active=(i==index)

        tween(button,0.18,{
            BackgroundTransparency=active and 0 or 1,
        })

        button.TextColor3=active and C.bg or C.muted
    end

    for _,child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    content.CanvasPosition=Vector2.zero

    local tab=P.tabs[index]
    if not tab then return end

    for order,id in ipairs(tab.features) do
        local def=FEATURES[id]
        if def then
            buildRow(id,def,order)
        end
    end
end

for i,tab in ipairs(P.tabs) do
    local button=make("TextButton",{
        Size=UDim2.new(
            1/#P.tabs,
            -3*(#P.tabs-1)/#P.tabs,
            1,0
        ),
        BackgroundColor3=P.color,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Text=tab.name,
        Font=Enum.Font.GothamBold,
        TextSize=11,
        TextColor3=C.muted,
        AutoButtonColor=false,
        LayoutOrder=i,
    },tabBar)

    round(button,9)
    tabButtons[i]=button

    button.Activated:Connect(function()
        showTab(i)
    end)
end

showTab(1)

--==================================================
-- FLOATING BUBBLE
--==================================================

local BUBBLE=54

local bubble=make("Frame",{
    Name="NexusBubble",
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.new(1,-44,0,84),
    Size=UDim2.fromOffset(BUBBLE,BUBBLE),
    BackgroundTransparency=1,
    Visible=false,
    ZIndex=10,
},gui)

local bubbleScale=make("UIScale",{Scale=0.01},bubble)

local glow=make("Frame",{
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromScale(1.4,1.4),
    BackgroundColor3=P.color,
    BackgroundTransparency=0.82,
    BorderSizePixel=0,
    ZIndex=1,
},bubble)

round(glow,100)

TweenService:Create(glow,
    TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
    {BackgroundTransparency=0.6}
):Play()

local ring=make("Frame",{
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ZIndex=1,
},bubble)

round(ring,100)

local ringStroke=stroke(ring,P.color,2,0.2)

local pulseInfo=TweenInfo.new(
    1.8,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.Out,
    -1
)

TweenService:Create(ring,pulseInfo,{
    Size=UDim2.fromScale(1.7,1.7),
}):Play()

TweenService:Create(ringStroke,pulseInfo,{
    Transparency=1,
}):Play()

local face=make("TextButton",{
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromScale(1,1),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    Text="",
    AutoButtonColor=false,
    ZIndex=2,
},bubble)

round(face,100)

local faceStroke=stroke(face,C.white,2.5,0)

local faceGrad=make("UIGradient",{
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,P.color),
        ColorSequenceKeypoint.new(0.5,P.color2),
        ColorSequenceKeypoint.new(1,P.color),
    }),
},faceStroke)

make("TextLabel",{
    Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1,
    Text=P.short,
    Font=Enum.Font.GothamBlack,
    TextSize=16,
    TextColor3=P.color,
    ZIndex=3,
},face)

track(RunService.Heartbeat:Connect(function(dt)
    if bubble.Visible then
        faceGrad.Rotation=(faceGrad.Rotation+dt*140)%360
    end
end))

--==================================================
-- OPEN / MINIMIZE
--==================================================

local menuOpen=true
local busy=false
local restorePos=main.Position

minimizeMenu=function()
    if busy or not menuOpen then return end

    busy=true
    menuOpen=false
    restorePos=main.Position

    tween(main,0.35,{
        Position=bubble.Position,
    },Enum.EasingStyle.Quint,Enum.EasingDirection.In)

    tween(mainScale,0.35,{
        Scale=0.05,
    },Enum.EasingStyle.Quint,Enum.EasingDirection.In)

    task.wait(0.34)

    main.Visible=false
    bubbleScale.Scale=0.01
    bubble.Visible=true

    tween(bubbleScale,0.45,{
        Scale=1,
    },Enum.EasingStyle.Back)

    busy=false
end

openMenu=function()
    if busy or menuOpen then return end

    busy=true
    menuOpen=true

    tween(bubbleScale,0.2,{
        Scale=0.01,
    },Enum.EasingStyle.Quad,Enum.EasingDirection.In)

    main.Position=bubble.Position
    mainScale.Scale=0.05
    main.Visible=true

    tween(main,0.5,{
        Position=restorePos,
    },Enum.EasingStyle.Quint)

    tween(mainScale,0.5,{
        Scale=1,
    },Enum.EasingStyle.Back)

    task.wait(0.2)
    bubble.Visible=false
    busy=false
end

closeBtn.Activated:Connect(minimizeMenu)

--==================================================
-- DRAG BUBBLE
--==================================================

local bubbleDrag={
    active=false,
    moved=false,
    start=nil,
    origin=nil,
}

face.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

        bubbleDrag.active=true
        bubbleDrag.moved=false
        bubbleDrag.start=input.Position

        bubbleDrag.origin=Vector2.new(
            bubble.AbsolutePosition.X+bubble.AbsoluteSize.X/2,
            bubble.AbsolutePosition.Y+bubble.AbsoluteSize.Y/2
        )

        tween(bubbleScale,0.1,{Scale=0.92})
    end
end)

track(UserInputService.InputChanged:Connect(function(input)
    if bubbleDrag.active
        and (input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then

        local delta=input.Position-bubbleDrag.start

        if delta.Magnitude>8 then
            bubbleDrag.moved=true
        end

        if bubbleDrag.moved then
            local size=gui.AbsoluteSize

            local x=math.clamp(
                bubbleDrag.origin.X+delta.X,
                BUBBLE/2+6,
                size.X-BUBBLE/2-6
            )

            local y=math.clamp(
                bubbleDrag.origin.Y+delta.Y,
                BUBBLE/2+6,
                size.Y-BUBBLE/2-6
            )

            bubble.Position=UDim2.fromOffset(x,y)
        end
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if bubbleDrag.active
        and (input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch) then

        bubbleDrag.active=false

        tween(bubbleScale,0.18,{
            Scale=1,
        },Enum.EasingStyle.Back)

        if bubbleDrag.moved then
            local size=gui.AbsoluteSize
            local cx=bubble.AbsolutePosition.X+BUBBLE/2
            local cy=bubble.AbsolutePosition.Y+BUBBLE/2

            local targetX

            if cx<size.X/2 then
                targetX=BUBBLE/2+10
            else
                targetX=size.X-BUBBLE/2-10
            end

            tween(bubble,0.35,{
                Position=UDim2.fromOffset(targetX,cy),
            },Enum.EasingStyle.Quint)
        else
            openMenu()
        end
    end
end))

--==================================================
-- DRAG WINDOW
--==================================================

local dragging=false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

        dragging=true
        dragStart=input.Position
        startPos=main.Position
    end
end)

track(UserInputService.InputChanged:Connect(function(input)
    if dragging
        and (input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then

        local delta=input.Position-dragStart

        main.Position=UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset+delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset+delta.Y
        )
    end
end))

track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end))

print("[NEXUS DELTA v"..VERSION.."] Map: "..P.name.." ("..profileId..")")
