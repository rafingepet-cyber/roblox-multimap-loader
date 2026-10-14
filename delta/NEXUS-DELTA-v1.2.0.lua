
--[[
    NEXUS DELTA v1.2.0
    Smart Map Hub + Version Updater
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

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
    green = Color3.fromRGB(60,235,150),
    red = Color3.fromRGB(255,95,110),
}

local function parts(v)
    local a,b,c = tostring(v or "0.0.0"):match("^(%d+)%.(%d+)%.?(%d*)$")
    return {tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0}
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
    for k,v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj,r)
    make("UICorner",{CornerRadius=UDim.new(0,r or 12)},obj)
end

local function stroke(obj,color,thickness)
    return make("UIStroke",{
        Color=color or C.line,
        Thickness=thickness or 1,
    },obj)
end

local function grad(obj,a,b)
    make("UIGradient",{Color=ColorSequence.new(a,b)},obj)
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

local function button(parent,text,pos,size,bg,fg)
    local b=make("TextButton",{
        Position=pos,
        Size=size,
        BackgroundColor3=bg or C.card2,
        BorderSizePixel=0,
        Text=text,
        Font=Enum.Font.GothamBold,
        TextSize=11,
        TextColor3=fg or C.white,
        AutoButtonColor=false,
    },parent)
    round(b,9)
    return b
end

local function notify(message,color)
    local old=playerGui:FindFirstChild("NEXUS_NOTICE")
    if old then old:Destroy() end

    local gui=make("ScreenGui",{
        Name="NEXUS_NOTICE",
        ResetOnSpawn=false,
        DisplayOrder=1001,
    },playerGui)

    local box=make("TextLabel",{
        AnchorPoint=Vector2.new(.5,0),
        Position=UDim2.new(.5,0,0,-60),
        Size=UDim2.fromOffset(310,48),
        BackgroundColor3=C.bg,
        BorderSizePixel=0,
        Text=message,
        TextColor3=color or C.white,
        TextSize=12,
        TextWrapped=true,
        Font=Enum.Font.GothamBold,
    },gui)
    round(box,12)
    stroke(box,color or C.cyan,1)

    TweenService:Create(box,TweenInfo.new(.3),{
        Position=UDim2.new(.5,0,0,24)
    }):Play()

    task.delay(3.5,function()
        if gui.Parent then gui:Destroy() end
    end)
end

local function fetchConfig()
    local ok,response=pcall(function()
        return game:HttpGet(API_URL.."?t="..os.time())
    end)
    if not ok then return nil end

    local decoded,data=pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if decoded and type(data)=="table" then return data end
    return nil
end

local config=fetchConfig()

local function discoverVersions()
    local ok,response=pcall(function()
        return game:HttpGet(REPO_API)
    end)
    if not ok or type(response)~="string" then
        return {},"GitHub tidak dapat diakses"
    end

    local decoded,data=pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if not decoded or type(data)~="table" then
        return {},"Respons GitHub tidak valid"
    end

    local versions,seen={},{}
    for _,item in ipairs(data) do
        local filename=item.name or ""
        local ver=filename:match("^NEXUS%-DELTA%-v(%d+%.%d+%.%d+)%.lua$")
        if ver and not seen[ver] then
            seen[ver]=true
            table.insert(versions,{
                version=ver,
                filename=filename,
                url=item.download_url or (RAW_BASE..filename),
            })
        end
    end

    table.sort(versions,function(a,b)
        return compareVersion(a.version,b.version)>0
    end)
    return versions
end

local function showUpdateToast(ver,copied)
    notify(
        "NEXUS DELTA v"..ver.." disiapkan"
        ..(copied and " • Link loadstring disalin" or " • Salin link manual"),
        C.green
    )
end

-- UPDATER
local versions,versionError=discoverVersions()
local latest=versions[1]

local function showUpdateDialog(versionList,newest)
    local old=playerGui:FindFirstChild("NEXUS_UPDATE")
    if old then old:Destroy() end

    local gui=make("ScreenGui",{
        Name="NEXUS_UPDATE",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        DisplayOrder=999,
    },playerGui)

    local overlay=make("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=.35,
    },gui)

    local card=make("Frame",{
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromOffset(330,370),
        BackgroundColor3=C.bg,
        BorderSizePixel=0,
    },overlay)
    round(card,18)
    stroke(card,C.cyan,1)

    local accent=make("Frame",{
        Size=UDim2.new(1,0,0,3),
        BackgroundColor3=C.cyan,
        BorderSizePixel=0,
    },card)
    grad(accent,C.purple,C.cyan)

    label(card,"NEXUS UPDATE",
        UDim2.fromOffset(18,14),UDim2.new(1,-36,0,26),C.white,18)

    label(card,"Terpasang v"..VERSION.."  →  Terbaru v"..newest.version,
        UDim2.fromOffset(18,43),UDim2.new(1,-36,0,22),C.cyan,11)

    local status=label(card,"Pilih versi yang ingin dijalankan.",
        UDim2.fromOffset(18,70),UDim2.new(1,-36,0,36),C.muted,10)
    status.TextWrapped=true

    local list=make("ScrollingFrame",{
        Position=UDim2.fromOffset(18,112),
        Size=UDim2.new(1,-36,0,150),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=C.cyan,
        CanvasSize=UDim2.new(),
    },card)
    round(list,10)

    local layout=make("UIListLayout",{
        Padding=UDim.new(0,5),
        SortOrder=Enum.SortOrder.LayoutOrder,
    },list)

    make("UIPadding",{
        PaddingTop=UDim.new(0,6),
        PaddingLeft=UDim.new(0,6),
        PaddingRight=UDim.new(0,6),
    },list)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+12)
    end)

    local selected=newest
    local busy=false

    local selectedLabel=label(card,"Dipilih: v"..selected.version,
        UDim2.fromOffset(18,270),UDim2.new(1,-36,0,22),C.green,11)

    local function selectVersion(item)
        selected=item
        selectedLabel.Text="Dipilih: v"..item.version
        status.Text="Link target: "..item.filename
        status.TextColor3=C.cyan
    end

    for i,item in ipairs(versionList) do
        local caption="v"..item.version
        if item.version==newest.version then caption=caption.." • TERBARU" end
        if item.version==VERSION then caption=caption.." • TERPASANG" end

        local b=button(list,caption,UDim2.new(),UDim2.new(1,-4,0,32),
            item.version==newest.version and C.card2 or C.card,C.white)
        b.LayoutOrder=i
        b.TextXAlignment=Enum.TextXAlignment.Left

        make("UIPadding",{PaddingLeft=UDim.new(0,10)},b)
        b.Activated:Connect(function()
            selectVersion(item)
        end)
    end

    local updateBtn=button(card,"JALANKAN VERSI PILIHAN",
        UDim2.fromOffset(18,302),UDim2.new(1,-36,0,40),C.purple,C.white)
    grad(updateBtn,C.purple,C.cyan)

    local copyBtn=button(card,"SALIN LINK VERSI PILIHAN",
        UDim2.fromOffset(18,347),UDim2.new(1,-36,0,0),C.card2,C.white)
    copyBtn.Visible=false

    -- Menghasilkan link dari item yang dipilih, bukan versi terbaru.
    local function selectedLoadstring(item)
        local url=item.url or (RAW_BASE..item.filename)
        return 'loadstring(game:HttpGet("'..url..'"))()'
    end

    updateBtn.Activated:Connect(function()
        if busy then return end
        busy=true

        local item=selected
        local url=item.url or (RAW_BASE..item.filename)
        status.Text="Mengunduh v"..item.version.."..."
        status.TextColor3=C.cyan

        task.spawn(function()
            local ok,src=pcall(function()
                return game:HttpGet(url..(string.find(url,"?",1,true) and "&" or "?")
                    .."t="..os.time())
            end)

            if not ok or type(src)~="string" or #src<50 then
                status.Text="Unduhan gagal. Coba lagi."
                status.TextColor3=C.red
                busy=false
                return
            end

            if type(loadstring)~="function" then
                status.Text="Executor tidak mendukung loadstring."
                status.TextColor3=C.red
                busy=false
                return
            end

            local compileOk,fn,compileErr=pcall(loadstring,src)
            if not compileOk or type(fn)~="function" then
                status.Text="Kompilasi gagal: "..tostring(compileErr or fn)
                status.TextColor3=C.red
                busy=false
                return
            end

            local code=selectedLoadstring(item)
            local copied=false
            if type(setclipboard)=="function" then
                copied=pcall(setclipboard,code)
            end

            gui:Destroy()
            notify("Menjalankan v"..item.version
                ..(copied and " • Link disalin" or ""),C.green)

            task.spawn(function()
                local runOk,runErr=pcall(fn)
                if not runOk then
                    warn("[NEXUS] Error menjalankan v"..item.version..": "..tostring(runErr))
                    notify("Error saat menjalankan v"..item.version,C.red)
                else
                    showUpdateToast(item.version,copied)
                end
            end)
        end)
    end)

    -- Pilihan salin menggunakan versi yang sedang dipilih.
    local copyOnly=button(card,"SALIN LINK LOADSTRING",
        UDim2.fromOffset(18,347),UDim2.new(1,-36,0,0),C.card2,C.white)
    copyOnly.Visible=false

    local close=button(card,"NANTI SAJA",
        UDim2.fromOffset(18,347),UDim2.new(1,-36,0,0),C.card2,C.white)
    close.Visible=false

    TweenService:Create(card,TweenInfo.new(.3,Enum.EasingStyle.Back),{
        Size=UDim2.fromOffset(330,370)
    }):Play()
end

if latest and compareVersion(latest.version,VERSION)>0 then
    showUpdateDialog(versions,latest)
    return
end

if #versions==0 then
    warn("[NEXUS] Versi GitHub tidak tersedia: "..tostring(versionError))
end

-- MAIN MENU
local oldGui=playerGui:FindFirstChild("NEXUS_DELTA")
if oldGui then oldGui:Destroy() end

local gui=make("ScreenGui",{
    Name="NEXUS_DELTA",
    ResetOnSpawn=false,
    IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
},playerGui)

local main=make("Frame",{
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),
    Size=UDim2.new(.9,0,.8,0),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    ClipsDescendants=true,
},gui)
round(main,18)
stroke(main,C.purple,1)

make("UISizeConstraint",{
    MinSize=Vector2.new(300,380),
    MaxSize=Vector2.new(480,600),
},main)

local header=make("Frame",{
    Size=UDim2.new(1,0,0,65),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
},main)

label(header,"NEXUS DELTA",
    UDim2.fromOffset(16,8),UDim2.new(1,-80,0,26),C.white,18)

label(header,"v"..VERSION.." • Universal",
    UDim2.fromOffset(16,35),UDim2.new(1,-80,0,18),C.cyan,10)

local minimize=button(header,"—",UDim2.new(1,-45,0,15),
    UDim2.fromOffset(30,30),C.card2,C.white)

local body=make("ScrollingFrame",{
    Position=UDim2.fromOffset(12,76),
    Size=UDim2.new(1,-24,1,-88),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=3,
    ScrollBarImageColor3=C.cyan,
    CanvasSize=UDim2.new(),
},main)

local bodyLayout=make("UIListLayout",{
    Padding=UDim.new(0,7),
    SortOrder=Enum.SortOrder.LayoutOrder,
},body)

bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    body.CanvasSize=UDim2.new(0,0,0,bodyLayout.AbsoluteContentSize.Y+8)
end)

local function addFeature(title,description,callback)
    local row=make("Frame",{
        Size=UDim2.new(1,-4,0,58),
        BackgroundColor3=C.card,
        BorderSizePixel=0,
    },body)
    round(row,11)

    label(row,title,UDim2.fromOffset(12,6),
        UDim2.new(1,-105,0,22),C.white,12)

    label(row,description,UDim2.fromOffset(12,29),
        UDim2.new(1,-105,0,20),C.muted,9)

    local b=button(row,"AKTIFKAN",
        UDim2.new(1,-90,.5,-14),UDim2.fromOffset(80,28),C.purple,C.white)

    b.Activated:Connect(function()
        local ok,err=pcall(callback)
        if ok then
            notify(title.." dijalankan",C.green)
        else
            warn("[NEXUS] "..tostring(err))
            notify("Gagal: "..title,C.red)
        end
    end)
end

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local c=getCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c=getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end

addFeature("Kecepatan Jalan","Atur WalkSpeed menjadi 32",function()
    local h=getHumanoid()
    assert(h,"Karakter belum siap")
    h.WalkSpeed=32
end)

addFeature("Lompat","Atur JumpPower menjadi 75",function()
    local h=getHumanoid()
    assert(h,"Karakter belum siap")
    h.UseJumpPower=true
    h.JumpPower=75
end)

addFeature("Fullbright","Terangkan pencahayaan lokal",function()
    Lighting.Brightness=2
    Lighting.ClockTime=14
    Lighting.FogEnd=100000
    Lighting.GlobalShadows=false
    Lighting.Ambient=Color3.fromRGB(190,190,190)
end)

addFeature("Simpan Posisi","Simpan posisi karakter",function()
    local root=getRoot()
    assert(root,"Karakter belum siap")
    _G.NEXUS_SAVED_CFRAME=root.CFrame
    notify("Posisi disimpan",C.cyan)
end)

addFeature("Kembali ke Posisi","Kembali ke posisi tersimpan",function()
    local root=getRoot()
    assert(root,"Karakter belum siap")
    assert(_G.NEXUS_SAVED_CFRAME,"Belum ada posisi tersimpan")
    root.CFrame=_G.NEXUS_SAVED_CFRAME
end)

addFeature("Rejoin","Coba masuk kembali ke experience",function()
    TeleportService:Teleport(game.PlaceId,player)
end)

local bubble=button(gui,"NX",
    UDim2.new(1,-65,0,90),UDim2.fromOffset(52,52),C.bg,C.cyan)
bubble.Name="NexusBubble"
bubble.Visible=false
round(bubble,26)
stroke(bubble,C.cyan,2)

local open=true
minimize.Activated:Connect(function()
    open=false
    main.Visible=false
    bubble.Visible=true
end)

bubble.Activated:Connect(function()
    open=true
    bubble.Visible=false
    main.Visible=true
end)

-- Drag window
local dragging=false
local dragStart,startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        main.Position=UDim2.new(
            startPos.X.Scale,startPos.X.Offset+delta.X,
            startPos.Y.Scale,startPos.Y.Offset+delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

print("[NEXUS DELTA v"..VERSION.."] Loaded")
