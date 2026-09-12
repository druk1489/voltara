-- Sopera test GUI — "Aurora" theme. Standalone UI skeleton (widgets wired to stubs).
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local SoundService    = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local THEMES = {
    Midnight = {
        bg      = Color3.fromRGB(10, 11, 16),
        panel   = Color3.fromRGB(17, 19, 27),
        card    = Color3.fromRGB(24, 27, 38),
        cardHi  = Color3.fromRGB(33, 37, 52),
        border  = Color3.fromRGB(70, 78, 110),
        text    = Color3.fromRGB(232, 235, 245),
        muted   = Color3.fromRGB(140, 147, 170),
        onAccent= Color3.fromRGB(8, 9, 14),
    },
    Slate = {
        bg      = Color3.fromRGB(30, 33, 40),
        panel   = Color3.fromRGB(41, 45, 54),
        card    = Color3.fromRGB(52, 57, 68),
        cardHi  = Color3.fromRGB(66, 72, 86),
        border  = Color3.fromRGB(96, 104, 122),
        text    = Color3.fromRGB(235, 237, 242),
        muted   = Color3.fromRGB(160, 167, 182),
        onAccent= Color3.fromRGB(15, 17, 21),
    },
    Day = {
        bg      = Color3.fromRGB(238, 240, 247),
        panel   = Color3.fromRGB(248, 249, 253),
        card    = Color3.fromRGB(255, 255, 255),
        cardHi  = Color3.fromRGB(240, 242, 250),
        border  = Color3.fromRGB(206, 212, 228),
        text    = Color3.fromRGB(28, 32, 46),
        muted   = Color3.fromRGB(120, 128, 150),
        onAccent= Color3.fromRGB(255, 255, 255),
    },
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local state = {
    theme   = "Midnight",
    hue     = 0.58,
    sat     = 0.72,
    bri     = 1.0,
    scale   = isMobile and 0.8 or 1.0,
    open    = true,
}
local function accent() return Color3.fromHSV(state.hue, state.sat, state.bri) end

local gui = Instance.new("ScreenGui")
gui.Name = "SoperaAurora"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local themeables = {}
local function T(el, role) themeables[#themeables + 1] = { el = el, role = role }; return el end

local function corner(el, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = el; return c end
local function stroke(el, r) local s = Instance.new("UIStroke"); s.Thickness = 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.CornerRadius = UDim.new(0, r or 6); s.Parent = el; return s end
local function pad(el, l, r2, t, b) local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,l); p.PaddingRight = UDim.new(0,r2); p.PaddingTop = UDim.new(0,t); p.PaddingBottom = UDim.new(0,b); p.Parent = el; return p end
local function tween(el, info, props) local t = TweenService:Create(el, info, props); t:Play(); return t end
local function click() pcall(function() local s = Instance.new("Sound"); s.SoundId = "rbxassetid://6001279300"; s.Volume = 0.25; s.PlaybackSpeed = 1.4; s.Parent = SoundService; s:Play(); game:GetService("Debris"):AddItem(s, 0.6) end) end

local S = function(v) return math.floor(v * state.scale + 0.5) end

-- ================= window =================
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, S(560), 0, S(400))
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.Position = UDim2.new(0.5, 0, 0.5, 0)
win.BorderSizePixel = 0
win.BackgroundColor3 = Color3.fromRGB(10,11,16)
win.ClipsDescendants = true
win.Parent = gui
corner(win, S(12))
T(win, "bg")
local winStroke = stroke(win, S(12)); winStroke.Transparency = 0.35; T(winStroke, "border")

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, S(46)); header.BorderSizePixel = 0
header.BackgroundColor3 = Color3.fromRGB(20,22,32); header.ZIndex = 5
header.Parent = win
corner(header, S(12))
T(header, "panel")
local headClip = Instance.new("Frame", header); headClip.Size = UDim2.new(1,0,0,6); headClip.Position = UDim2.new(0,0,1,-6); headClip.BorderSizePixel = 0; headClip.BackgroundColor3 = header.BackgroundColor3; headClip.ZIndex = 5; T(headClip, "panel")
local headGrad = Instance.new("UIGradient", header)
headGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, accent()),
    ColorSequenceKeypoint.new(0.5, accent():Lerp(Color3.fromRGB(255,255,255), 0.15)),
    ColorSequenceKeypoint.new(1, accent()),
}); headGrad.Rotation = 90
task.spawn(function()
    local rot = 0
    while gui and gui.Parent do
        rot = (rot + 1) % 360
        headGrad.Offset = Vector2.new(math.sin(math.rad(rot))*0.4, 0)
        task.wait(0.05)
    end
end)

local titleDot = Instance.new("Frame"); titleDot.Size = UDim2.new(0,S(10),0,S(10)); titleDot.Position = UDim2.new(0,S(16),0.5,-S(5)); titleDot.BorderSizePixel = 0; titleDot.BackgroundColor3 = accent(); titleDot.ZIndex = 6; titleDot.Parent = header; corner(titleDot, 20)
local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(1,-S(170),1,0); titleLbl.Position = UDim2.new(0,S(34),0,0); titleLbl.BackgroundTransparency = 1; titleLbl.Text = "  SOPERA  \226\153\164  Aurora"; titleLbl.TextColor3 = Color3.fromRGB(232,235,245); titleLbl.TextSize = 16; titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6; titleLbl.Parent = header; T(titleLbl, "text")
local statusLbl = Instance.new("TextLabel"); statusLbl.Size = UDim2.new(0,S(120),1,0); statusLbl.Position = UDim2.new(1,-S(150),0,0); statusLbl.BackgroundTransparency = 1; statusLbl.Text = ""; statusLbl.TextColor3 = Color3.fromRGB(150,155,175); statusLbl.TextSize = 11; statusLbl.Font = Enum.Font.Gotham; statusLbl.TextXAlignment = Enum.TextXAlignment.Right; statusLbl.TextTruncate = Enum.TextTruncate.AtEnd; statusLbl.ZIndex = 6; statusLbl.Parent = header; T(statusLbl, "muted")

local function headBtn(txt, xoff)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0,S(28),0,S(28)); b.Position = UDim2.new(1,xoff,0.5,-S(14)); b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(30,33,46); b.Text = txt; b.TextColor3 = Color3.fromRGB(232,235,245); b.TextSize = 15; b.Font = Enum.Font.GothamBold; b.AutoButtonColor = false; b.ZIndex = 6; b.Parent = header; corner(b, 7); T(b, "card"); local s2 = stroke(b, 7); s2.Transparency = 0.55; T(s2, "border")
    b.MouseEnter:Connect(function() tween(b, TweenInfo.new(0.15), {BackgroundColor3 = accent()}) end)
    b.MouseLeave:Connect(function() if b.TextColor3 ~= Color3.new(0,0,0) then end tween(b, TweenInfo.new(0.15), {BackgroundColor3 = THEMES[state.theme].card}) end)
    return b
end
local btnReset = headBtn("⟳", -S(100))
local btnMin = headBtn("–", -S(66))
local btnClose = headBtn("✕", -S(32))

local rail = Instance.new("Frame"); rail.Size = UDim2.new(0,S(96),1,-S(76)); rail.Position = UDim2.new(0,0,0,S(52)); rail.BackgroundTransparency = 1; rail.Parent = win
local railLayout = Instance.new("UIListLayout"); railLayout.Padding = UDim.new(0, S(6)); railLayout.Parent = rail
local railPad = pad(rail, 8, 6, 6, 6)

local body = Instance.new("Frame"); body.Size = UDim2.new(1,-S(100),1,-S(76)); body.Position = UDim2.new(0,S(96),0,S(52)); body.BackgroundTransparency = 1; body.ClipsDescendants = true; body.Parent = win

local foot = Instance.new("Frame"); foot.Size = UDim2.new(1,0,0,S(24)); foot.Position = UDim2.new(0,0,1,-S(24)); foot.BorderSizePixel = 0; foot.BackgroundColor3 = Color3.fromRGB(14,15,22); foot.ZIndex = 5; foot.Parent = win; T(foot, "bg")
local footText = Instance.new("TextLabel"); footText.Size = UDim2.new(1,-16,1,0); footText.Position = UDim2.new(0,8,0,0); footText.BackgroundTransparency = 1; footText.Text = "Sopera · Aurora UI test · drag header to move, ◦ to switch theme"; footText.TextColor3 = Color3.fromRGB(120,128,150); footText.TextSize = 11; footText.Font = Enum.Font.GothamMedium; footText.TextXAlignment = Enum.TextXAlignment.Left; footText.ZIndex = 6; footText.Parent = foot; T(footText, "muted")

local function setStatus(t) statusLbl.Text = t; task.delay(2.5, function() if statusLbl.Text == t then statusLbl.Text = "" end end) end

-- ================= tabs =================
local tabs, pages = {}, {}
local function addTab(name)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,S(40)); btn.BorderSizePixel = 0; btn.BackgroundColor3 = Color3.fromRGB(24,27,38); btn.Text = "  "..name; btn.TextColor3 = Color3.fromRGB(150,155,175); btn.TextSize = 12; btn.Font = Enum.Font.GothamSemibold; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false; btn.ZIndex = 6; btn.Parent = rail; corner(btn, 8); T(btn, "card")
    local page = Instance.new("ScrollingFrame"); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 4; page.ScrollBarImageColor3 = Color3.fromRGB(90,96,120); page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ElasticBehavior = Enum.ElasticBehavior.Never; page.Visible = false; page.ZIndex = 6; page.Parent = body
    local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0, S(8)); lay.Parent = page
    pad(page, 10, 10, 10, 12)
    tabs[name] = btn; pages[name] = page
    return btn, page
end

local function showTab(name)
    for k, b in pairs(tabs) do
        if k == name then
            tween(b, TweenInfo.new(0.15), {BackgroundColor3 = accent(), TextColor3 = THEMES[state.theme].onAccent})
        else
            tween(b, TweenInfo.new(0.15), {BackgroundColor3 = THEMES[state.theme].card, TextColor3 = THEMES[state.theme].muted})
        end
    end
    for k, p in pairs(pages) do p.Visible = (k == name) end
end

-- ================= widgets =================
local function label(text, parent, big)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,big and S(22) or S(16)); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = big and THEMES[state.theme].text or THEMES[state.theme].muted; l.TextSize = big and 14 or 11; l.Font = big and Enum.Font.GothamBold or Enum.Font.Gotham; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 7; l.Parent = parent; if big then T(l, "text") else T(l, "muted") end
    return l
end

local function toggle(text, value, parent, cb)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,S(34)); row.BorderSizePixel = 0; row.BackgroundColor3 = THEMES[state.theme].card; row.ZIndex = 7; row.Parent = parent; corner(row, 8); T(row, "card"); local st = stroke(row, 8); st.Transparency = 0.6; T(st, "border")
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-S(52),1,0); lbl.Position = UDim2.new(0,12,0,0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = THEMES[state.theme].text; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 8; lbl.Parent = row; T(lbl, "text")
    local pill = Instance.new("TextButton"); pill.Size = UDim2.new(0,S(40),0,S(22)); pill.Position = UDim2.new(1,-S(50),0.5,-S(11)); pill.BorderSizePixel = 0; pill.Text = ""; pill.AutoButtonColor = false; pill.ZIndex = 8; pill.Parent = row; corner(pill, 20)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,S(16),0,S(16)); knob.BorderSizePixel = 0; knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.ZIndex = 9; knob.Parent = pill; corner(knob, 20)
    local on = value
    local function refresh()
        pill.BackgroundColor3 = on and accent() or THEMES[state.theme].cardHi
        tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(on and 1 or 0, on and -S(20) or S(3), 0.5, -S(8))})
    end
    pill.MouseButton1Click:Connect(function() on = not on; click(); refresh(); cb(on); setStatus((on and "on: " or "off: ")..text) end)
    refresh()
    return refresh
end

local function slider(text, min, max, val, parent, fmt, cb)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,S(42)); row.BorderSizePixel = 0; row.BackgroundColor3 = THEMES[state.theme].card; row.ZIndex = 7; row.Parent = parent; corner(row, 8); T(row, "card"); local st = stroke(row, 8); st.Transparency = 0.6; T(st, "border")
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-S(70),0,S(16)); lbl.Position = UDim2.new(0,12,0,4); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = THEMES[state.theme].text; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 8; lbl.Parent = row; T(lbl, "text")
    local valLbl = Instance.new("TextLabel"); valLbl.Size = UDim2.new(0,S(60),0,S(16)); valLbl.Position = UDim2.new(1,-S(70),0,4); valLbl.BackgroundTransparency = 1; valLbl.Text = ""; valLbl.TextColor3 = THEMES[state.theme].muted; valLbl.TextSize = 11; valLbl.Font = Enum.Font.GothamBold; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 8; valLbl.Parent = row; T(valLbl, "muted")
    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-S(24),0,S(6)); track.Position = UDim2.new(0,12,1,-S(14)); track.BorderSizePixel = 0; track.BackgroundColor3 = THEMES[state.theme].cardHi; track.ZIndex = 8; track.Parent = row; corner(track, 6); T(track, "cardHi")
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0,0,1,0); fill.BorderSizePixel = 0; fill.BackgroundColor3 = accent(); fill.ZIndex = 9; fill.Parent = track; corner(fill, 6)
    local grab = Instance.new("Frame"); grab.Size = UDim2.new(0,S(12),0,S(12)); grab.Position = UDim2.new(0,-6,0.5,-6); grab.BorderSizePixel = 0; grab.BackgroundColor3 = Color3.fromRGB(255,255,255); grab.ZIndex = 10; grab.Parent = track; corner(grab, 20)
    local cur = math.clamp(val, min, max)
    local function set(v, fire)
        cur = math.clamp(v, min, max)
        local rel = (cur - min) / (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        grab.Position = UDim2.new(rel, -6, 0.5, -6)
        valLbl.Text = fmt and fmt(cur) or tostring(math.floor(cur+0.5))
        if fire and cb then cb(cur) end
    end
    local drag = false
    local function fromX(x) local rel = math.clamp((x - track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1); set(min + rel*(max-min), true) end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; fromX(i.Position.X) end end)
    fill.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; fromX(i.Position.X) end end)
    grab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    set(cur)
    return function(v) set(v, false) end
end

local function button(text, parent, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,S(36)); b.BorderSizePixel = 0; b.BackgroundColor3 = THEMES[state.theme].cardHi; b.Text = text; b.TextColor3 = THEMES[state.theme].text; b.TextSize = 12; b.Font = Enum.Font.GothamBold; b.AutoButtonColor = false; b.ZIndex = 7; b.Parent = parent; corner(b, 8); T(b, "cardHi"); local s2 = stroke(b, 8); s2.Transparency = 0.6; T(s2, "border")
    b.MouseEnter:Connect(function() tween(b, TweenInfo.new(0.15), {BackgroundColor3 = accent(), TextColor3 = THEMES[state.theme].onAccent}) end)
    b.MouseLeave:Connect(function() tween(b, TweenInfo.new(0.15), {BackgroundColor3 = THEMES[state.theme].cardHi, TextColor3 = THEMES[state.theme].text}) end)
    b.MouseButton1Click:Connect(function() click(); cb() end)
    return b
end

local function dropdown(text, options, parent, cb)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,S(34)); btn.BorderSizePixel = 0; btn.BackgroundColor3 = THEMES[state.theme].card; btn.Text = "  "..text..": —"; btn.TextColor3 = THEMES[state.theme].muted; btn.TextSize = 12; btn.Font = Enum.Font.GothamMedium; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false; btn.ZIndex = 7; btn.Parent = parent; corner(btn, 8); T(btn, "card"); local s2 = stroke(btn, 8); s2.Transparency = 0.6; T(s2, "border")
    local pop = Instance.new("Frame"); pop.Size = UDim2.new(0, S(200), 0, 0); pop.AutomaticSize = Enum.AutomaticSize.Y; pop.BorderSizePixel = 0; pop.BackgroundColor3 = THEMES[state.theme].panel; pop.Visible = false; pop.ClipsDescendants = true; pop.ZIndex = 50; pop.Parent = gui; corner(pop, 8); T(pop, "panel"); local ps = stroke(pop, 8); ps.Transparency = 0.3; T(ps, "border")
    local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 2); pl.Parent = pop
    pad(pop, 4, 4, 4, 4)
    for _, o in ipairs(options) do
        local it = Instance.new("TextButton"); it.Size = UDim2.new(1,0,0,S(28)); it.BorderSizePixel = 0; it.BackgroundTransparency = 1; it.Text = "  "..o; it.TextColor3 = THEMES[state.theme].text; it.TextSize = 12; it.Font = Enum.Font.GothamMedium; it.TextXAlignment = Enum.TextXAlignment.Left; it.AutoButtonColor = false; it.ZIndex = 51; it.Parent = pop; corner(it, 6)
        it.MouseEnter:Connect(function() tween(it, TweenInfo.new(0.1), {BackgroundColor3 = accent(), TextColor3 = THEMES[state.theme].onAccent, BackgroundTransparency = 0}) end)
        it.MouseLeave:Connect(function() tween(it, TweenInfo.new(0.1), {BackgroundTransparency = 1, TextColor3 = THEMES[state.theme].text}) end)
        it.MouseButton1Click:Connect(function() btn.Text = "  "..text..": "..o; pop.Visible = false; click(); cb(o); setStatus(text.." = "..o) end)
    end
    btn.MouseButton1Click:Connect(function()
        if pop.Visible then pop.Visible = false; return end
        local ab = btn.AbsolutePosition; pop.Position = UDim2.new(0, ab.X+8, 0, ab.Y + btn.AbsoluteSize.Y + 4)
        for _, p2 in pairs(gui:GetChildren()) do if p2:IsA("Frame") and p2.Name=="SoperaDrop" then p2.Visible=false end end
        pop.Name = "SoperaDrop"; pop.Visible = true; click()
    end)
    UserInputService.InputBegan:Connect(function(i)
        if pop.Visible and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            local m = i.Position; local p0 = pop.AbsolutePosition; local sz = pop.AbsoluteSize
            local b0 = btn.AbsolutePosition; local bsz = btn.AbsoluteSize
            if not (m.X>=p0.X and m.X<=p0.X+sz.X and m.Y>=p0.Y and m.Y<=p0.Y+sz.Y) and not (m.X>=b0.X and m.X<=b0.X+bsz.X and m.Y>=b0.Y and m.Y<=b0.Y+bsz.Y) then pop.Visible = false end
        end
    end)
end

local applyTheme
local reLayout

local function colorRow(text, color, parent, cb)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,0,S(34)); row.BorderSizePixel = 0; row.BackgroundColor3 = THEMES[state.theme].card; row.ZIndex = 7; row.Parent = parent; corner(row, 8); T(row, "card"); local rs = stroke(row, 8); rs.Transparency = 0.6; T(rs, "border")
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-S(70),1,0); lbl.Position = UDim2.new(0,12,0,0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = THEMES[state.theme].text; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 8; lbl.Parent = row; T(lbl, "text")
    local sw = Instance.new("Frame"); sw.Size = UDim2.new(0,S(44),0,S(22)); sw.Position = UDim2.new(1,-S(54),0.5,-S(11)); sw.BorderSizePixel = 0; sw.BackgroundColor3 = color; sw.ZIndex = 8; sw.Parent = row; corner(sw, 6); local sss = stroke(sw, 6); sss.Transparency = 0.4; T(sss, "border")
    local hue = Instance.new("TextButton"); hue.Size = UDim2.new(0,S(30),0,S(22)); hue.Position = UDim2.new(1,-S(54),0.5,-S(11)); hue.BackgroundTransparency = 1; hue.Text = ""; hue.ZIndex = 9; hue.Parent = row
    hue.MouseButton1Click:Connect(function()
        local h,s2,v = Color3.toHSV(state.accent or accent())
        state.hue = (state.hue + 0.11) % 1
        applyTheme(); click(); cb(accent()); setStatus("accent shifted")
    end)
    return function(c) sw.BackgroundColor3 = c end
end

applyTheme = function()
    local t = THEMES[state.theme]
    local a = accent()
    for _, item in ipairs(themeables) do
        local el, role = item.el, item.role
        if role == "bg" then el.BackgroundColor3 = t.bg
        elseif role == "panel" then el.BackgroundColor3 = t.panel
        elseif role == "card" then el.BackgroundColor3 = t.card
        elseif role == "cardHi" then el.BackgroundColor3 = t.cardHi
        elseif role == "border" then el.Color = t.border
        elseif role == "text" then el.TextColor3 = t.text
        elseif role == "muted" then el.TextColor3 = t.muted end
    end
    titleDot.BackgroundColor3 = a
    headGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(0.5, a:Lerp(t.text, 0.15)),
        ColorSequenceKeypoint.new(1, a),
    })
    state.accent = a
end

-- ================= build content =================
local _b, pageBuild = addTab("Build")
local _c, pageConvert = addTab("Convert")
local _p, pagePaint = addTab("Paint")
local _t, pageTheme = addTab("Theme")

label("Auto Build", pageBuild, true)
toggle("Auto Preview", true, pageBuild, function() end)
toggle("Show Block Counts", true, pageBuild, function() end)
toggle("INF Block", false, pageBuild, function() end)
local scl = slider("Build Scale", 0.1, 5, 1, pageBuild, function(v) return string.format("%.1f×", v) end, function() end)
button("Open .Build Browser", pageBuild, function() setStatus("browser (stub)") end)
button("Build From File", pageBuild, function() setStatus("build (stub)") end)

label("Converters", pageConvert, true)
dropdown("Source Type", {"OBJ", "Image JSON", "Minecraft Schem", "Roblox Asset"}, pageConvert, function() end)
slider("Voxel Size", 0.1, 4, 1, pageConvert, function(v) return string.format("%.2f", v) end, function() end)
dropdown("Material", {"PlasticBlock","WoodBlock","MetalBlock","NeonBlock"}, pageConvert, function() end)
button("Convert → .Build", pageConvert, function() setStatus("convert (stub)") end)

label("Paint", pagePaint, true)
colorRow("Primary Color", Color3.fromRGB(90,60,200), pagePaint, function() end)
slider("Shimmer Speed", 1, 30, 6, pagePaint, function(v) return math.floor(v) end, function() end)
button("Paint All", pagePaint, function() setStatus("paint all (stub)") end)

label("Theme & Layout", pageTheme, true)
dropdown("Color Theme", {"Midnight","Slate","Day"}, pageTheme, function(name) state.theme = name; applyTheme(); showTab("Theme"); setStatus("theme: "..name) end)
slider("Accent Hue", 0, 1, state.hue, pageTheme, function(v) return string.format("%.0f°", v*360) end, function(v) state.hue = v; applyTheme() end)
slider("Window Scale", 0.6, 1.5, state.scale, pageTheme, function(v) return string.format("%.0f%%", v*100) end, function(v) state.scale = v; reLayout() end)
button("Reset Layout", pageTheme, function() win.Position = UDim2.new(0.5,0,0.5,0); state.scale = 1; reLayout(); setStatus("layout reset") end)

applyTheme()
showTab("Build")

-- ================= window drag / open orb / min / close =================
local dragging, dStart, dPos = false, nil, nil
header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dStart=i.Position; dPos=win.Position end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        local vp = workspace.CurrentCamera.ViewportSize
        local x = math.clamp(dPos.X.Offset + d.X, -win.AbsoluteSize.X+60, vp.X-60)
        local y = math.clamp(dPos.Y.Offset + d.Y, 0, vp.Y-40)
        win.Position = UDim2.new(0,x,0,y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)

reLayout = function()
    tween(win, TweenInfo.new(0.18), {Size = UDim2.new(0,S(560),0,S(400))})
    applyTheme()
end

local orb = Instance.new("TextButton")
orb.Name="Orb"; orb.Size = UDim2.new(0,S(52),0,S(52)); orb.Position = UDim2.new(0,16,1,-S(72)); orb.AnchorPoint=Vector2.new(0,1); orb.BorderSizePixel=0; orb.BackgroundColor3 = Color3.fromRGB(20,22,32); orb.Text = "◐"; orb.TextColor3 = Color3.fromRGB(232,235,245); orb.TextSize=22; orb.Font=Enum.Font.GothamBold; orb.AutoButtonColor=false; orb.Visible=false; orb.ZIndex = 9999; orb.Parent = gui; corner(orb, 40); T(orb, "panel"); local os2 = stroke(orb, 40); os2.Color = accent(); os2.Transparency = 0.2; os2.Thickness = 2
orb.MouseButton1Click:Connect(function() state.open=true; win.Visible=true; orb.Visible=false; tween(win, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,S(560),0,S(400))}) end)

local function setOpened(v)
    state.open = v
    if v then win.Visible = true; orb.Visible = false else win.Visible = false; orb.Visible = true end
end
btnMin.MouseButton1Click:Connect(function() click(); setOpened(false) end)
btnClose.MouseButton1Click:Connect(function() click(); gui:Destroy() end)
btnReset.MouseButton1Click:Connect(function() click(); win.Position = UDim2.new(0.5,0,0.5,0); setStatus("centered") end)
UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.RightShift then setOpened(not state.open) end end)

print("[Sopera/Aurora] test UI loaded. RightShift = hide/show. Tabs: Build/Convert/Paint/Theme.")
