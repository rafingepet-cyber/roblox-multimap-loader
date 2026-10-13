-- NEXUS DELTA UI — catalog + version gate (UI-only)
-- Version checks and game-specific presentation are driven by the NEXUS hosting JSON.
-- This script intentionally contains no gameplay exploits, automation, teleport, or remote manipulation.

local VERSION = "1.0.0"
local API_URL = "https://nebul.rf.gd/api.php" -- replace with your deployed hosting endpoint
local GITHUB_LOADER_URL = "https://raw.githubusercontent.com/rafingepet-cyber/roblox-multimap-loader/main/delta/NEXUS-DELTA.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function fetchConfig()
    if API_URL:find("YOUR%-DOMAIN") then return nil, "Set API_URL in NEXUS-DELTA.lua first." end
    local ok, response = pcall(function()
        -- Executor HTTP APIs differ. If game:HttpGet is supported, this path works in that environment.
        return game:HttpGet(API_URL)
    end)
    if not ok or type(response) ~= "string" then return nil, "Hosting API unavailable." end
    local parsed, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not parsed or type(data) ~= "table" then return nil, "Invalid hosting JSON." end
    return data
end

local function versionParts(v)
    local a,b,c = tostring(v or "0.0.0"):match("(%d+)%.(%d+)%.?(%d*)")
    return {tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0}
end
local function newer(a,b)
    local x,y = versionParts(a), versionParts(b)
    for i=1,3 do
        if x[i] > y[i] then return true end
        if x[i] < y[i] then return false end
    end
    return false
end

local config, configError = fetchConfig()
-- Never block the UI on a version gate. The UPDATE button always runs the progress flow.

local COLORS = {
    bg = Color3.fromRGB(10,12,18), panel = Color3.fromRGB(17,20,30),
    panel2 = Color3.fromRGB(24,28,41), line = Color3.fromRGB(45,52,72),
    text = Color3.fromRGB(239,242,255), muted = Color3.fromRGB(145,154,179),
    accent = Color3.fromRGB(163,91,255), cyan = Color3.fromRGB(66,208,255),
    green = Color3.fromRGB(95,230,169)
}
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(p, r) make("UICorner", {CornerRadius=UDim.new(0,r or 12)}, p) end
local function stroke(p, color, thickness) make("UIStroke", {Color=color or COLORS.line, Thickness=thickness or 1}, p) end
local function tween(o, p, t) TweenService:Create(o, TweenInfo.new(t or .2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play() end

local old = playerGui:FindFirstChild("NEXUS_DELTA")
if old then old:Destroy() end
local gui = make("ScreenGui", {Name="NEXUS_DELTA", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, playerGui)
local main = make("Frame", {AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.new(.88,0,.76,0), BackgroundColor3=COLORS.bg, BorderSizePixel=0}, gui)
corner(main,18); stroke(main,COLORS.accent,1.2)
make("UISizeConstraint", {MinSize=Vector2.new(295,390), MaxSize=Vector2.new(570,680)}, main)
local header = make("Frame", {Size=UDim2.new(1,0,0,68), BackgroundColor3=COLORS.panel, BorderSizePixel=0}, main); corner(header,18)
make("Frame", {Position=UDim2.new(0,0,1,-18), Size=UDim2.new(1,0,0,18), BackgroundColor3=COLORS.panel, BorderSizePixel=0}, header)
local logo = make("Frame", {Position=UDim2.new(0,14,0.5,-17), Size=UDim2.fromOffset(34,34), BackgroundColor3=COLORS.accent, BorderSizePixel=0}, header); corner(logo,10)
make("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="N", Font=Enum.Font.GothamBlack, TextSize=21, TextColor3=Color3.new(1,1,1)}, logo)
make("TextLabel", {Position=UDim2.new(0,57,0,10), Size=UDim2.new(1,-105,0,27), BackgroundTransparency=1, Text=(config and config.brand) or "NEXUS", Font=Enum.Font.GothamBlack, TextSize=20, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.text}, header)
make("TextLabel", {Position=UDim2.new(0,58,0,37), Size=UDim2.new(1,-110,0,16), BackgroundTransparency=1, Text="CATALOG  •  v"..VERSION, Font=Enum.Font.GothamMedium, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.muted}, header)
local close = make("TextButton", {AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-12,.5,0), Size=UDim2.fromOffset(32,32), BackgroundColor3=COLORS.panel2, Text="×", Font=Enum.Font.GothamBold, TextSize=22, TextColor3=COLORS.text, AutoButtonColor=false}, header); corner(close,10)
close.Activated:Connect(function() tween(main,{Size=UDim2.new(0,0,0,0)},.2); task.wait(.22); gui:Destroy() end)

local body = make("Frame", {Position=UDim2.new(0,0,0,68), Size=UDim2.new(1,0,1,-68), BackgroundTransparency=1}, main)
local gameName = "Unknown Game"
local placeId = tostring(game.PlaceId)
if config and type(config.games)=="table" then
    for _,g in ipairs(config.games) do
        if tostring(g.placeId or "") == placeId then gameName = tostring(g.name or "Game"); break end
    end
end
local gameBanner = make("TextLabel", {Position=UDim2.new(0,14,0,8), Size=UDim2.new(1,-28,0,25), BackgroundTransparency=1, Text="EXPERIENCE  /  "..string.upper(gameName), Font=Enum.Font.GothamBold, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.cyan}, body)
local search = make("TextBox", {Position=UDim2.new(0,14,0,39), Size=UDim2.new(1,-28,0,38), BackgroundColor3=COLORS.panel, PlaceholderText="  Search game catalog...", Text="", Font=Enum.Font.Gotham, TextSize=12, TextColor3=COLORS.text, PlaceholderColor3=COLORS.muted, ClearTextOnFocus=false}, body); corner(search,10); stroke(search,COLORS.line)
local content = make("ScrollingFrame", {Position=UDim2.new(0,14,0,86), Size=UDim2.new(1,-28,1,-130), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=COLORS.accent, CanvasSize=UDim2.new(0,0,0,0)}, body)
local layout = make("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, content)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() content.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+8) end)
local status = make("TextLabel", {Position=UDim2.new(0,14,1,-34), Size=UDim2.new(1,-28,0,20), BackgroundTransparency=1, Text="READY  •  UI ONLY", Font=Enum.Font.GothamMedium, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.green}, body)

local updateBtn = make("TextButton", {AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-14,0,8), Size=UDim2.fromOffset(92,24), BackgroundColor3=COLORS.panel2, Text="↻ UPDATE", Font=Enum.Font.GothamBold, TextSize=9, TextColor3=COLORS.cyan, AutoButtonColor=false}, body)
corner(updateBtn,8); stroke(updateBtn,COLORS.line,1)

local updatePanel = make("Frame", {Visible=false, AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5), Size=UDim2.new(.88,0,0,205), BackgroundColor3=COLORS.panel, BorderSizePixel=0, ZIndex=20}, main)
corner(updatePanel,16); stroke(updatePanel,COLORS.accent,1.2)
make("TextLabel", {Position=UDim2.new(0,16,0,13), Size=UDim2.new(1,-32,0,26), BackgroundTransparency=1, Text="NEXUS UPDATE CENTER", Font=Enum.Font.GothamBlack, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.text, ZIndex=21}, updatePanel)
local updateInfo = make("TextLabel", {Position=UDim2.new(0,16,0,45), Size=UDim2.new(1,-32,0,38), BackgroundTransparency=1, Text="Ready to check hosting version.", Font=Enum.Font.Gotham, TextSize=11, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.muted, ZIndex=21}, updatePanel)
local progressBack = make("Frame", {Position=UDim2.new(0,16,0,91), Size=UDim2.new(1,-32,0,10), BackgroundColor3=COLORS.bg, BorderSizePixel=0, ZIndex=21}, updatePanel)
corner(progressBack,6)
local progressFill = make("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=COLORS.accent, BorderSizePixel=0, ZIndex=22}, progressBack)
corner(progressFill,6)
local progressText = make("TextLabel", {Position=UDim2.new(0,16,0,106), Size=UDim2.new(1,-32,0,18), BackgroundTransparency=1, Text="0% • NOT STARTED", Font=Enum.Font.GothamBold, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.cyan, ZIndex=21}, updatePanel)
local updateAction = make("TextButton", {Position=UDim2.new(0,16,1,-43), Size=UDim2.new(1,-32,0,30), BackgroundColor3=COLORS.accent, Text="CHECK FOR UPDATE", Font=Enum.Font.GothamBold, TextSize=10, TextColor3=Color3.new(1,1,1), AutoButtonColor=false, ZIndex=21}, updatePanel)
corner(updateAction,9)
local updateBusy = false

local function setProgress(percent, label)
    percent = math.clamp(math.floor(tonumber(percent) or 0), 0, 100)
    progressFill.Size = UDim2.new(percent/100,0,1,0)
    local filled = math.floor(percent / 5)
    local bar = string.rep("=", filled) .. string.rep("-", 20 - filled)
    progressText.Text = "["..bar.."] "..tostring(percent).."%  •  "..string.upper(label)
end

updateBtn.Activated:Connect(function()
    updatePanel.Visible = not updatePanel.Visible
    if updatePanel.Visible then
        updateInfo.Text = "Progress tracks version-check stages, not a file download. Executor HTTP support may vary."
    end
end)

updateAction.Activated:Connect(function()
    if updateBusy then return end
    updateBusy = true
    updateAction.Text = "CHECKING..."
    setProgress(0,"starting")
    updateInfo.Text = "Connecting to NEXUS hosting..."
    task.spawn(function()
        task.wait(0.25); setProgress(20,"connecting")
        task.wait(0.25); setProgress(45,"checking version")
        local latest, err = fetchConfig()
        task.wait(0.2); setProgress(70,"validating response")
        if not latest then
            setProgress(100,"failed")
            updateInfo.Text = "Couldn't reach hosting: "..tostring(err or "unknown error").." Check API_URL in the script."
            updateAction.Text = "RETRY"
        elseif newer(latest.version or VERSION, VERSION) then
            setProgress(100,"update available")
            updateInfo.Text = "New version "..tostring(latest.version)..". The running script cannot safely replace itself; copy the trusted source URL and run the new version again."
            updateAction.Text = "COPY UPDATE URL"
            updateAction.Activated:Once(function()
                if setclipboard then pcall(setclipboard, GITHUB_LOADER_URL) end
                if toclipboard then pcall(toclipboard, GITHUB_LOADER_URL) end
                updateInfo.Text = "URL copied if clipboard is supported. Open the GitHub source, then rerun the updated script. "..GITHUB_LOADER_URL
            end)
        else
            setProgress(100,"up to date")
            updateInfo.Text = "NEXUS is up to date. Installed "..VERSION.." • Hosting "..tostring(latest.version or VERSION).."."
            updateAction.Text = "CHECK AGAIN"
        end
        updateBusy = false
    end)
end)

local fallback = {
"Adopt Me!","Blox Fruits","Brookhaven RP","Murder Mystery 2","DOORS","Blade Ball","Arsenal","Pet Simulator 99","Tower of Hell","Jailbreak","BedWars","Evade","Natural Disaster Survival","Dress To Impress","The Strongest Battlegrounds","Shindo Life","Anime Adventures","King Legacy","Piggy","Rainbow Friends","Build A Boat For Treasure","Royale High","MeepCity","Welcome to Bloxburg","Phantom Forces","Combat Warriors","Fisch","Bee Swarm Simulator","Theme Park Tycoon 2","Restaurant Tycoon 2","Work at a Pizza Place","Epic Minigames","Breaking Point","Catalog Avatar Creator","Speed Run 4"
}
local gameEntries = (config and type(config.games)=="table" and #config.games>0) and config.games or {}
if #gameEntries == 0 then for _,n in ipairs(fallback) do table.insert(gameEntries,{name=n,category="Roblox",enabled=true}) end end
local function clear()
    for _,v in ipairs(content:GetChildren()) do if v~=layout then v:Destroy() end end
end
local function makeCard(g, index)
    if g.enabled == false then return end
    local name = tostring(g.name or "Untitled")
    local row = make("Frame", {Size=UDim2.new(1,-2,0,58), BackgroundColor3=COLORS.panel, BorderSizePixel=0}, content)
    row.LayoutOrder=index; corner(row,12); stroke(row,COLORS.line,1)
    local icon = make("Frame", {Position=UDim2.new(0,10,.5,-16), Size=UDim2.fromOffset(32,32), BackgroundColor3=COLORS.panel2, BorderSizePixel=0}, row); corner(icon,9)
    make("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=string.format("%02d",index), Font=Enum.Font.GothamBold, TextSize=10, TextColor3=COLORS.cyan}, icon)
    make("TextLabel", {Position=UDim2.new(0,51,0,8), Size=UDim2.new(1,-104,0,22), BackgroundTransparency=1, Text=name, Font=Enum.Font.GothamSemibold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, TextColor3=COLORS.text}, row)
    make("TextLabel", {Position=UDim2.new(0,51,0,31), Size=UDim2.new(1,-104,0,15), BackgroundTransparency=1, Text=tostring(g.category or "CATALOG ENTRY"), Font=Enum.Font.GothamMedium, TextSize=8, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=COLORS.muted}, row)
    local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-9,.5,0),Size=UDim2.fromOffset(42,30),BackgroundColor3=COLORS.panel2,Text="VIEW",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COLORS.cyan,AutoButtonColor=false},row); corner(b,8)
    b.Activated:Connect(function()
        status.Text="PROFILE  •  "..string.upper(name); status.TextColor3=COLORS.cyan
        updatePanel.Visible = true
        updateInfo.Text = "Selected profile: "..name.."\\nPlaceId: "..tostring(g.placeId or "not supplied").."\\nCategory: "..tostring(g.category or "Roblox").."\\nThis build provides UI/catalog information only; it does not inject game-specific gameplay cheats."
        setProgress(100,"profile loaded")
        updateAction.Text = "CHECK FOR UPDATE"
        tween(row,{BackgroundColor3=Color3.fromRGB(28,26,45)},.14)
        task.delay(.3,function() if row.Parent then tween(row,{BackgroundColor3=COLORS.panel},.2) end end)
    end)
end
local function render(q)
    clear(); local shown=0; q=string.lower(q or "")
    for i,g in ipairs(gameEntries) do
        if g.enabled ~= false and (q=="" or string.find(string.lower(tostring(g.name or "")),q,1,true)) then
            shown+=1; makeCard(g,i)
        end
    end
    if shown==0 then make("TextLabel",{Size=UDim2.new(1,0,0,45),BackgroundTransparency=1,Text="No games found",Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=COLORS.muted},content) end
    status.Text=string.format("%02d ENTRIES  •  v%s",shown,(config and config.version) or VERSION); status.TextColor3=COLORS.green
end
search:GetPropertyChangedSignal("Text"):Connect(function() render(search.Text) end)
render("")

-- Drag support for mouse/touch.
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position
        input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input==dragInput then
        local d=input.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

if not config then
    status.Text="OFFLINE MODE  •  "..tostring(configError or "using built-in catalog")
    status.TextColor3=Color3.fromRGB(255,190,90)
end
