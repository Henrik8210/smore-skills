SmoreSkills = SmoreSkills or {}
SmoreSkills.Settings = SmoreSkills.Settings or {}

local Settings = SmoreSkills.Settings
local SETTINGS_UI_BUILD = 65
local ICON = SmoreSkills.ICON or "Interface\\Icons\\Spell_Fire_Fire"
local POPUP_WIDTH = 720
local POPUP_HEIGHT = 620
local SIDEBAR_WIDTH = 88
local HEADER_HEIGHT = 34
local HEADER_INSET = 10
local CLOSE_INSET = 48
local BODY_PAD = 14
local GAP_TITLE = 8
local GAP_HINT = 3
local GAP_SECTION = 16
local GRID_COL_GAP = 16
local GRID_LEFT_INSET = 2
local GRID_RIGHT_INSET = 6
local TAB_LABEL_GAP = 10
local MINIMAP_RADIUS = 80
local BUTTON_SIZE = 31
local PANEL_BG = "Interface\\FrameGeneral\\UI-Background-Rock"
local PANEL_EDGE = "Interface\\DialogFrame\\UI-DialogBox-Border"
local PANEL_FILL = { 0.24, 0.19, 0.14, 0.97 }
local PANEL_BORDER = { 0.48, 0.40, 0.30, 1 }
local BODY_FILL = { 0.16, 0.13, 0.09, 0.95 }
local TAB_ICON_SIZE = 40
local TAB_GOLD_RING = 2
local TAB_LABEL_HEIGHT = 14
local TAB_INACTIVE_ALPHA = 0.55
local TAB_LABEL_ACTIVE = { 1, 0.82, 0.15 }
local TAB_LABEL_INACTIVE = { 0.55, 0.55, 0.55 }
local TITLE_YELLOW = "ffd200"
local SETTINGS_TITLE_SIZE = 13
local SETTINGS_SMALL_SIZE = 12
local SETTINGS_CHECK_SIZE = SETTINGS_TITLE_SIZE + 3
local SETTINGS_SMALL_CHECK = 14
local TINY_ICON = 16
local GOLD = { 1, 0.82, 0 }
local TAB_RING_ACTIVE = { 1, 0.82, 0, 1 }
local TAB_RING_INACTIVE = { 0.55, 0.45, 0.18, 0.9 }
local CIRCLE_BG = "Interface\\Minimap\\UI-Minimap-Background"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local TAB_ICONS = {
    general = ICON,
    host = "Interface\\Icons\\INV_Misc_Head_Dwarf_01",
    seeker = "Interface\\Icons\\Ability_EyeOfTheOwl",
}

local function RefreshAll()
    if SmoreSkills.Map and SmoreSkills.Map.RefreshPins then
        SmoreSkills.Map:RefreshPins()
    end
end

local function AddSolidFill(frame, color)
    if frame.solidFill then
        frame.solidFill:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
        return frame.solidFill
    end
    local fill = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    fill:SetAllPoints()
    fill:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
    frame.solidFill = fill
    return fill
end

local function ApplyPanelChrome(frame, inset)
    if not frame.SetBackdrop then
        AddSolidFill(frame, inset and BODY_FILL or PANEL_FILL)
        return
    end
    local fillColor = inset and BODY_FILL or PANEL_FILL
    frame:SetBackdrop({
        bgFile = inset and "Interface\\Buttons\\WHITE8X8" or PANEL_BG,
        edgeFile = PANEL_EDGE,
        tile = true,
        tileSize = inset and 16 or 32,
        edgeSize = inset and 10 or 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    frame:SetBackdropColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4] or 1)
    frame:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], 1)
end

local function AddCircleMask(owner, texture, size)
    if not owner.CreateMaskTexture or not texture.AddMaskTexture then
        return nil
    end
    local mask = owner:CreateMaskTexture(nil, "ARTWORK")
    mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(size, size)
    mask:SetPoint("CENTER", texture, "CENTER")
    texture:AddMaskTexture(mask)
    return mask
end

local function ApplyTabIcon(parent, iconPath)
    local outer = TAB_ICON_SIZE + TAB_GOLD_RING * 2
    parent:SetSize(outer, outer)

    local ring = parent:CreateTexture(nil, "BACKGROUND")
    ring:SetSize(outer, outer)
    ring:SetPoint("CENTER")
    ring:SetTexture(CIRCLE_BG)
    ring:SetVertexColor(TAB_RING_ACTIVE[1], TAB_RING_ACTIVE[2], TAB_RING_ACTIVE[3], TAB_RING_ACTIVE[4])
    AddCircleMask(parent, ring, outer)

    local bg = parent:CreateTexture(nil, "BORDER")
    bg:SetSize(TAB_ICON_SIZE, TAB_ICON_SIZE)
    bg:SetPoint("CENTER")
    bg:SetTexture(CIRCLE_BG)
    bg:SetVertexColor(0.08, 0.07, 0.06, 1)
    AddCircleMask(parent, bg, TAB_ICON_SIZE)

    local icon = parent:CreateTexture(nil, "ARTWORK")
    icon:SetSize(TAB_ICON_SIZE, TAB_ICON_SIZE)
    icon:SetPoint("CENTER")
    icon:SetTexture(iconPath or ICON)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    AddCircleMask(parent, icon, TAB_ICON_SIZE)

    return bg, icon, ring
end

local function OpenWorldMap()
    if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
        if SmoreSkills.Map then
            SmoreSkills.Map:EnsureInit()
            if SmoreSkills.Map.RefreshPins then
                SmoreSkills.Map:RefreshPins()
            end
        end
        return
    end
    if ToggleWorldMap then
        ToggleWorldMap()
    elseif WorldMapFrame and WorldMapFrame.Show then
        WorldMapFrame:Show()
    end
    if SmoreSkills.Map then
        SmoreSkills.Map:EnsureInit()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if SmoreSkills.Map.AnchorButton then
                    SmoreSkills.Map:AnchorButton()
                end
                if SmoreSkills.Map.RefreshPins then
                    SmoreSkills.Map:RefreshPins()
                end
            end)
        end
    end
end

local function GetMinimapAngle()
    return SmoreSkills_EnsureSettings().minimapAngle or 220
end

local function SetMinimapAngle(angle)
    SmoreSkills_EnsureSettings().minimapAngle = angle
end

local function IsRightClick(mouseButton)
    return mouseButton == "RightButton" or mouseButton == "RightButtonUp"
end

local function ApplyFontSize(fs, size)
    if not fs or not fs.SetFont then
        return
    end
    local fontPath, _, flags = fs:GetFont()
    fs:SetFont(fontPath or "Fonts\\FRIZQT__.TTF", size, flags)
end

local function ApplyTitleFont(fs)
    ApplyFontSize(fs, SETTINGS_TITLE_SIZE)
end

local function ApplySmallFont(fs)
    ApplyFontSize(fs, SETTINGS_SMALL_SIZE)
end

local CHECK_NATIVE = 32

local function MakeCheckButton(parent, size)
    local hold = CreateFrame("Frame", nil, parent)
    hold:SetSize(size, size)
    local cb = CreateFrame("CheckButton", nil, hold, "UICheckButtonTemplate")
    cb:SetSize(CHECK_NATIVE, CHECK_NATIVE)
    cb:ClearAllPoints()
    cb:SetPoint("TOPLEFT", hold, "TOPLEFT", 0, 0)
    cb:SetScale(size / CHECK_NATIVE)
    hold.checkbox = cb
    return hold, cb
end

local function ClickCheck(cb)
    if cb and cb.Click then
        cb:Click()
    end
end

local function MakeCheckLabel(parent, cb, applyFont)
    local btn = CreateFrame("Button", nil, parent)
    if btn.RegisterForClicks then
        btn:RegisterForClicks("LeftButtonUp")
    end
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", 0, 0)
    text:SetPoint("RIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("MIDDLE")
    if applyFont then
        applyFont(text)
    end
    btn:SetScript("OnClick", function()
        ClickCheck(cb)
    end)
    btn:SetScript("OnEnter", function()
        if cb and cb.LockHighlight then
            cb:LockHighlight()
        end
    end)
    btn:SetScript("OnLeave", function()
        if cb and cb.UnlockHighlight then
            cb:UnlockHighlight()
        end
    end)
    btn.label = text
    return btn, text
end

local function MakeTinyIcon(parent, texture)
    local icon = parent:CreateTexture(nil, "ARTWORK")
    icon:SetSize(TINY_ICON, TINY_ICON)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    if texture then
        icon:SetTexture(texture)
    end
    return icon
end

local function CreateSectionTitle(parent, text, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", BODY_PAD, y)
    label:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)
    label:SetJustifyH("LEFT")
    label:SetText("|cff" .. TITLE_YELLOW .. text .. "|r")
    return label
end

local function CreateItemHeading(parent, text, anchor, yOff)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -GAP_SECTION)
    row:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)

    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetPoint("TOPRIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    if label.SetWordWrap then
        label:SetWordWrap(true)
    end
    ApplyTitleFont(label)
    label:SetTextColor(1, 1, 1)
    label:SetText(text)
    row.label = label

    local function sizeHeading()
        local h = math.max(22, (label:GetStringHeight() or 18) + 6)
        if math.abs((row:GetHeight() or 0) - h) > 0.5 then
            row:SetHeight(h)
        end
    end
    row:SetScript("OnSizeChanged", sizeHeading)
    sizeHeading()
    return row
end

local function CreateHint(parent, text, anchor, yOff)
    local hint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    local attach = anchor and anchor.label or anchor
    hint:SetPoint("TOPLEFT", attach, "BOTTOMLEFT", 0, yOff or -GAP_HINT)
    hint:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText(text)
    hint:SetTextColor(0.65, 0.65, 0.65)
    return hint
end

local COMMAND_HELP = {
    { "/smores", "Open these settings. Also /sms or /smoreskills." },
    { "/smores find", "Look for camps in this zone. Also /smores seek." },
    { "/smores host", "Share your campfire with seekers." },
    { "/smores camp", "Open the host camp panel again if you closed it. Also left-click your map pin." },
    { "/smores stop", "Stop hosting." },
    { "/smores pack", "Pack up your camp (asks you to confirm, same as the map pin)." },
    { "/smores status", "Show channel, hosting, and seeking status." },
    { "/smores list", "List camps stored for this zone." },
    { "/smores prof <code>", "This session only (testing). Reload uses learned trades." },
    { "/smores want <list>", "Host want list, e.g. any or bs,lw." },
}

local function CreateCommandHelp(parent, anchor)
    local block = CreateFrame("Frame", nil, parent)
    block:SetPoint("LEFT", parent, "LEFT", BODY_PAD, 0)
    block:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)
    block:SetPoint("TOP", anchor, "BOTTOM", 0, -GAP_SECTION)

    local heading = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetPoint("TOPLEFT", 0, 0)
    heading:SetPoint("RIGHT", 0, 0)
    heading:SetJustifyH("LEFT")
    ApplyTitleFont(heading)
    heading:SetTextColor(1, 1, 1)
    heading:SetText("Commands")

    local lines = {}
    for i, row in ipairs(COMMAND_HELP) do
        local line = block:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        ApplySmallFont(line)
        line:SetJustifyH("LEFT")
        if line.SetWordWrap then
            line:SetWordWrap(true)
        end
        line:SetText("|cff" .. TITLE_YELLOW .. row[1] .. "|r  |cffbcbcbc" .. row[2] .. "|r")
        lines[i] = line
    end

    local function layoutHelp()
        local y = (heading:GetStringHeight() or 14) + GAP_TITLE
        for _, line in ipairs(lines) do
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", 0, -y)
            line:SetPoint("RIGHT", 0, 0)
            y = y + (line:GetStringHeight() or SETTINGS_SMALL_SIZE) + 4
        end
        block:SetHeight(math.max(y, 20))
    end
    block:SetScript("OnSizeChanged", layoutHelp)
    layoutHelp()
    return block
end

local function CreateCheckbox(parent, label, anchor, yOff)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOP", anchor, "BOTTOM", 0, yOff or -GAP_SECTION)
    row:SetPoint("LEFT", parent, "LEFT", BODY_PAD, 0)
    row:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)

    local hold, cb = MakeCheckButton(row, SETTINGS_CHECK_SIZE)
    hold:SetPoint("TOPLEFT", 0, 0)

    local labelBtn, text = MakeCheckLabel(row, cb, ApplyTitleFont)
    labelBtn:SetPoint("TOPLEFT", hold, "TOPRIGHT", 4, 0)
    labelBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    text:SetJustifyV("TOP")
    if text.SetWordWrap then
        text:SetWordWrap(true)
    end
    text:SetTextColor(1, 1, 1)
    text:SetText(label)
    local h = math.max(SETTINGS_CHECK_SIZE + 2, (text:GetStringHeight() or SETTINGS_TITLE_SIZE) + 4)
    row:SetHeight(h)
    labelBtn:SetHeight(h)

    row.checkbox = cb
    row.label = text
    return row
end

local function CreatePercentSlider(parent, label, anchor, yOff, minV, maxV, step)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -GAP_SECTION)
    row:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)

    local title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    title:SetJustifyH("LEFT")
    ApplyTitleFont(title)
    title:SetTextColor(1, 1, 1)
    title:SetText(label)

    local slider = CreateFrame("Slider", nil, row)
    slider:SetHeight(16)
    slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -GAP_TITLE)
    slider:SetPoint("RIGHT", row, "RIGHT", -52, 0)
    slider:SetOrientation("HORIZONTAL")
    slider:EnableMouse(true)
    slider:SetMinMaxValues(minV, maxV)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    if track.SetColorTexture then
        track:SetColorTexture(0.10, 0.08, 0.06, 0.95)
    else
        track:SetTexture("Interface\\Buttons\\WHITE8X8")
        track:SetVertexColor(0.10, 0.08, 0.06, 0.95)
    end
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    if thumb.SetColorTexture then
        thumb:SetColorTexture(0.85, 0.72, 0.28, 0.95)
    else
        thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
        thumb:SetVertexColor(0.85, 0.72, 0.28, 0.95)
    end
    thumb:SetSize(14, 22)
    slider:SetThumbTexture(thumb)

    local value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    value:SetPoint("LEFT", slider, "RIGHT", 8, 0)
    value:SetWidth(44)
    value:SetJustifyH("LEFT")

    local low = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -GAP_HINT)
    low:SetText(tostring(minV) .. "%")
    local high = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -GAP_HINT)
    high:SetText(tostring(maxV) .. "%")

    row.slider = slider
    row.value = value
    local titleH = title:GetStringHeight() or SETTINGS_TITLE_SIZE
    row:SetHeight(titleH + GAP_TITLE + 16 + GAP_HINT + 12)
    return row
end

local function LayoutProfGrid(panel)
    if not panel or not panel.checks then
        return
    end
    local rowHeight = SETTINGS_SMALL_CHECK + 4
    local maxLabel = 40
    for _, row in ipairs(panel.checks) do
        local w = row.label and row.label.GetStringWidth and row.label:GetStringWidth()
        if w and w > maxLabel then
            maxLabel = w
        end
    end
    local colW = SETTINGS_SMALL_CHECK + 4 + TINY_ICON + 4 + maxLabel + 2
    local gap = GRID_COL_GAP
    local col, gridRow = 0, 0
    for _, row in ipairs(panel.checks) do
        local x = GRID_LEFT_INSET + col * (colW + gap)
        row:ClearAllPoints()
        row:SetSize(colW, rowHeight)
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", x, -gridRow * rowHeight)
        col = col + 1
        if col > 1 then
            col = 0
            gridRow = gridRow + 1
        end
    end
    local rows = gridRow + (col == 0 and 0 or 1)
    if rows < 1 then
        rows = 1
    end
    panel:SetHeight(rows * rowHeight + 4)
    local area = panel:GetParent()
    if area and area.SetHeight then
        area:SetHeight(panel:GetHeight() or 1)
    end
end

local function CreateProfGrid(parent, wantKey)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", 0, 0)
    panel:SetPoint("TOPRIGHT", 0, 0)
    panel.checks = {}
    panel.wantKey = wantKey
    for i, prof in ipairs(SmoreSkills.PROFESSIONS) do
        local row = CreateFrame("Frame", nil, panel)
        row:SetHeight(SETTINGS_SMALL_CHECK + 4)
        row.profId = prof.id
        local hold, cb = MakeCheckButton(row, SETTINGS_SMALL_CHECK)
        hold:SetPoint("LEFT", 0, 0)
        local icon = MakeTinyIcon(row, SmoreSkills_ProfessionIcon(prof.id))
        icon:SetPoint("LEFT", hold, "RIGHT", 4, 0)
        local labelBtn, text = MakeCheckLabel(row, cb, ApplySmallFont)
        labelBtn:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        labelBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        labelBtn:SetPoint("TOP", row, "TOP", 0, 0)
        labelBtn:SetPoint("BOTTOM", row, "BOTTOM", 0, 0)
        text:SetText(prof.label)
        text:SetTextColor(0.92, 0.92, 0.92)
        row.checkbox = cb
        row.label = text
        row.profIcon = icon
        cb:SetScript("OnClick", function()
            SmoreSkills_ToggleWantProfession(wantKey, row.profId)
            Settings:RefreshProfessionGrid(panel, wantKey)
            if wantKey == "seekerWant" then
                Settings:LayoutSeekerPage()
            else
                Settings:LayoutHostPage()
            end
            RefreshAll()
        end)
        panel.checks[i] = row
    end
    panel:SetScript("OnSizeChanged", function()
        if panel._layouting then
            return
        end
        panel._layouting = true
        LayoutProfGrid(panel)
        panel._layouting = nil
    end)
    LayoutProfGrid(panel)
    return panel
end

local function CreateSidebarTab(parent, index, tabKey, labelText)
    local outer = TAB_ICON_SIZE + TAB_GOLD_RING * 2
    local slotHeight = outer + TAB_LABEL_GAP + TAB_LABEL_HEIGHT + 10

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(SIDEBAR_WIDTH, slotHeight)
    btn:SetPoint("TOP", parent, "TOP", 0, -8 - (index - 1) * slotHeight)

    local cluster = CreateFrame("Frame", nil, btn)
    cluster:SetPoint("TOP", btn, "TOP", 0, 0)
    cluster:EnableMouse(false)

    local bg, icon, ring = ApplyTabIcon(cluster, TAB_ICONS[tabKey] or ICON)
    btn.cluster = cluster
    btn.bgTex = bg
    btn.iconTex = icon
    btn.ring = ring
    btn.tabKey = tabKey

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOP", icon, "BOTTOM", 0, -TAB_LABEL_GAP)
    label:SetJustifyH("CENTER")
    label:SetText(labelText)
    btn.label = label

    btn:SetScript("OnClick", function()
        Settings:SelectTab(tabKey)
    end)
    return btn
end

function Settings:RefreshProfessionGrid(panel, wantKey)
    if not panel or not panel.checks then
        return
    end
    for _, row in ipairs(panel.checks) do
        local cb = row.checkbox or row
        local id = row.profId or cb.profId
        cb:SetChecked(SmoreSkills_WantHasProfession(wantKey, id))
    end
end

local ITEM_ROW_H = SETTINGS_SMALL_CHECK + 4
local PAGE_SCROLLBAR_W = 14

local function SyncPageScroll(page)
    if not page or not page.scroll or not page.bar then
        return
    end
    local view = page.scroll:GetHeight() or 0
    local content = page.content and page.content:GetHeight() or 0
    local maxScroll = math.max(0, content - view)
    page._syncingBar = true
    page.bar:SetMinMaxValues(0, maxScroll)
    page.bar:SetValue(page.scroll:GetVerticalScroll() or 0)
    page._syncingBar = false
    page.bar:SetShown(maxScroll > 1)
end

local function WheelPage(page, delta)
    if not page or not page.scroll or not page.content then
        return
    end
    local view = page.scroll:GetHeight() or 0
    local maxScroll = math.max(0, (page.content:GetHeight() or 0) - view)
    local cur = page.scroll:GetVerticalScroll() or 0
    page.scroll:SetVerticalScroll(math.max(0, math.min(maxScroll, cur - delta * 36)))
    SyncPageScroll(page)
end

local function CreatePageScroll(parent)
    local page = {}
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetPoint("TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", -PAGE_SCROLLBAR_W - 4, 0)
    scroll:EnableMouseWheel(true)
    page.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(200)
    content:SetHeight(40)
    scroll:SetScrollChild(content)
    page.content = content

    local bar = CreateFrame("Slider", nil, parent)
    bar:SetWidth(PAGE_SCROLLBAR_W)
    bar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -2)
    bar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
    bar:SetOrientation("VERTICAL")
    bar:SetMinMaxValues(0, 0)
    bar:SetValue(0)
    bar:SetValueStep(12)
    if bar.SetObeyStepOnDrag then
        bar:SetObeyStepOnDrag(true)
    end
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(0.10, 0.08, 0.06, 0.95)
    local thumb = bar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(0.85, 0.72, 0.28, 0.95)
    thumb:SetSize(PAGE_SCROLLBAR_W - 2, 36)
    bar:SetThumbTexture(thumb)
    bar:Hide()
    page.bar = bar

    parent:EnableMouseWheel(true)
    parent:SetScript("OnMouseWheel", function(_, delta)
        WheelPage(page, delta)
    end)
    scroll:SetScript("OnMouseWheel", function(_, delta)
        WheelPage(page, delta)
    end)
    bar:SetScript("OnValueChanged", function(_, value)
        if page._syncingBar then
            return
        end
        scroll:SetVerticalScroll(value or 0)
    end)
    return page
end

local function CreateItemPicker(parent, wantKey)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetPoint("TOPLEFT", 0, 0)
    wrap:SetPoint("TOPRIGHT", 0, 0)
    wrap.wantKey = wantKey
    wrap.groups = {}
    wrap.child = wrap

    local empty = wrap:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    empty:SetPoint("TOPLEFT", 2, -2)
    empty:SetPoint("RIGHT", wrap, "RIGHT", 0, 0)
    empty:SetJustifyH("LEFT")
        empty:SetText("Tick a profession above to pick camping objects.")
    wrap.empty = empty

    for _, prof in ipairs(SmoreSkills.PROFESSIONS) do
        local group = { profId = prof.id, rows = {} }
        local header = CreateFrame("Frame", nil, wrap)
        header:SetHeight(TINY_ICON)
        local headerIcon = MakeTinyIcon(header, SmoreSkills_ProfessionIcon(prof.id))
        headerIcon:SetPoint("LEFT", 0, 0)
        local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerText:SetPoint("LEFT", headerIcon, "RIGHT", 4, 0)
        headerText:SetPoint("RIGHT", header, "RIGHT", 0, 0)
        headerText:SetJustifyH("LEFT")
        ApplySmallFont(headerText)
        headerText:SetText("|cff" .. TITLE_YELLOW .. prof.label .. "|r")
        group.header = header
        for _, item in ipairs(SmoreSkills_ItemsForProfession(prof.id)) do
            local row = CreateFrame("Frame", nil, wrap)
            row:SetHeight(ITEM_ROW_H)
            row.itemId = item.id
            local hold, cb = MakeCheckButton(row, SETTINGS_SMALL_CHECK)
            hold:SetPoint("LEFT", 0, 0)
            local icon = MakeTinyIcon(row, SmoreSkills_CampingObjectIcon(item) or SmoreSkills_ProfessionIcon(item.profession))
            icon:SetPoint("LEFT", hold, "RIGHT", 4, 0)
            row.itemIcon = icon
            row.item = item
            local labelBtn, text = MakeCheckLabel(row, cb, ApplySmallFont)
            labelBtn:SetPoint("LEFT", icon, "RIGHT", 4, 0)
            labelBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            labelBtn:SetPoint("TOP", row, "TOP", 0, 0)
            labelBtn:SetPoint("BOTTOM", row, "BOTTOM", 0, 0)
            local label = item.label
            if item.note then
                label = label .. " — " .. item.note
            end
            text:SetText(label)
            text:SetTextColor(0.92, 0.92, 0.92)
            row.checkbox = cb
            local function ShowItemTip(anchor)
                if SmoreSkills_ShowCampingItemTooltip then
                    SmoreSkills_ShowCampingItemTooltip(anchor or labelBtn, item)
                end
                if cb and cb.LockHighlight then
                    cb:LockHighlight()
                end
            end
            local function HideItemTip()
                if GameTooltip then
                    GameTooltip:Hide()
                end
                if cb and cb.UnlockHighlight then
                    cb:UnlockHighlight()
                end
            end
            labelBtn:SetScript("OnEnter", function()
                ShowItemTip(labelBtn)
            end)
            labelBtn:SetScript("OnLeave", HideItemTip)
            if cb.SetScript then
                cb:SetScript("OnEnter", function()
                    ShowItemTip(cb)
                end)
                cb:SetScript("OnLeave", HideItemTip)
            end
            cb:SetScript("OnClick", function()
                if not SmoreSkills_ToggleWantItem(wantKey, item.id) then
                    cb:SetChecked(SmoreSkills_WantHasItem(wantKey, item.id))
                end
                Settings:RefreshItemPicker(wantKey)
                RefreshAll()
            end)
            table.insert(group.rows, row)
        end
        table.insert(wrap.groups, group)
    end
    return wrap
end

function Settings:LayoutItemPicker(picker)
    if not picker or not picker.groups then
        return
    end
    local wantKey = picker.wantKey
    local host = picker.child or picker
    local y = 0
    local shown = 0
    local firstGroup = true
    for _, group in ipairs(picker.groups) do
        local profOn = SmoreSkills_WantHasProfession(wantKey, group.profId)
        group.header:SetShown(profOn)
        if profOn then
            if not firstGroup then
                y = y + GAP_SECTION
            end
            firstGroup = false
            group.header:ClearAllPoints()
            group.header:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -y)
            group.header:SetPoint("RIGHT", host, "RIGHT", 0, 0)
            y = y + (group.header:GetHeight() or SETTINGS_SMALL_SIZE) + GAP_TITLE
            for _, row in ipairs(group.rows) do
                row:Show()
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", host, "TOPLEFT", 4, -y)
                row:SetPoint("RIGHT", host, "RIGHT", 0, 0)
                if row.checkbox then
                    row.checkbox:SetChecked(SmoreSkills_WantHasItem(wantKey, row.itemId))
                end
                if row.itemIcon then
                    row.itemIcon:SetTexture(
                        (row.item and SmoreSkills_CampingObjectIcon(row.item))
                            or SmoreSkills_ProfessionIcon(row.item and row.item.profession)
                    )
                end
                y = y + ITEM_ROW_H
                shown = shown + 1
            end
        else
            for _, row in ipairs(group.rows) do
                row:Hide()
            end
        end
    end
    if picker.empty then
        picker.empty:SetShown(shown == 0)
    end
    local h = shown == 0 and 22 or (y + 8)
    picker:SetHeight(h)
    local area = picker:GetParent()
    if area and area ~= picker then
        area:SetHeight(h)
    end
end

function Settings:RefreshItemPicker(wantKey)
    local picker = wantKey == "seekerWant" and self.seekerItemPicker or self.hostItemPicker
    self:LayoutItemPicker(picker)
end

function Settings:LayoutPage(page)
    if not page or not page.scroll or not page.content then
        return
    end
    local w = page.scroll:GetWidth() or 400
    if w > 20 then
        page.content:SetWidth(w)
    end
    if page.layoutItems then
        page.layoutItems()
    end
    local last = page.bottom
    local h = 80
    if last then
        local top = page.content.GetTop and page.content:GetTop()
        local bot = last.GetBottom and last:GetBottom()
        if top and bot and top > bot then
            h = top - bot + 18
        else
            h = 300 + (last.GetHeight and last:GetHeight() or 0)
        end
    end
    page.content:SetHeight(math.max(h, 1))
    SyncPageScroll(page)
end

function Settings:LayoutHostPage()
    if not self.hostPage then
        return
    end
    if self.hostGrid then
        LayoutProfGrid(self.hostGrid)
    end
    self:RefreshItemPicker("hostWant")
    local last = self.hostFilter
    if SmoreSkills_GetHostFilterEnabled() and self.hostItemArea then
        last = self.hostItemArea
    end
    self.hostPage.bottom = last
    self:LayoutPage(self.hostPage)
end

function Settings:LayoutSeekerPage()
    if not self.seekerPage then
        return
    end
    if self.seekerGrid then
        LayoutProfGrid(self.seekerGrid)
    end
    self:RefreshItemPicker("seekerWant")
    local last = self.seekerFilter
    if SmoreSkills_GetSeekerFilterEnabled() and self.seekerItemArea then
        last = self.seekerItemArea
    end
    self.seekerPage.bottom = last
    self:LayoutPage(self.seekerPage)
end

function Settings:LayoutGeneralPage()
    if not self.generalPage then
        return
    end
    if self.pinScaleRow and self.autoHostHint then
        local after = self.autoHostHint
        if self.hostNowBtn and self.hostNowBtn:IsShown() then
            after = self.hostNowBtn
        end
        self.pinScaleRow:ClearAllPoints()
        self.pinScaleRow:SetPoint("TOPLEFT", after, "BOTTOMLEFT", 0, -GAP_SECTION)
        self.pinScaleRow:SetPoint("RIGHT", self.generalPage.content, "RIGHT", -BODY_PAD, 0)
    end
    self.generalPage.bottom = self.commandHelp or self.crossLayerHint or self.guildHint or self.guildMark or self.chatHint or self.hostNowBtn
    self:LayoutPage(self.generalPage)
end

function Settings:SelectTab(tabKey)
    self.activeTab = tabKey
    for key, btn in pairs(self.tabs or {}) do
        local active = key == tabKey
        local alpha = active and 1 or TAB_INACTIVE_ALPHA
        if btn.iconTex then
            btn.iconTex:SetAlpha(alpha)
            btn.iconTex:SetDesaturated(not active)
        end
        if btn.bgTex then
            btn.bgTex:SetAlpha(alpha)
        end
        if btn.ring then
            btn.ring:Show()
            local c = active and TAB_RING_ACTIVE or TAB_RING_INACTIVE
            btn.ring:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
        end
        if btn.label then
            local c = active and TAB_LABEL_ACTIVE or TAB_LABEL_INACTIVE
            btn.label:SetTextColor(c[1], c[2], c[3])
        end
    end
    if self.panels then
        for key, panel in pairs(self.panels) do
            if key == tabKey then
                panel:Show()
            else
                panel:Hide()
            end
        end
    end
    if tabKey == "host" then
        self:LayoutHostPage()
    elseif tabKey == "seeker" then
        self:LayoutSeekerPage()
    elseif tabKey == "general" then
        self:LayoutGeneralPage()
    end
end

function Settings:RefreshHostProfessionPicker()
    local block = self.hostProfBlock
    if not block or not block.rows then
        return
    end
    local learned = SmoreSkills_GetPlayerProfessions()
    local learnedSet = {}
    for _, id in ipairs(learned) do
        learnedSet[id] = true
    end
    local active = SmoreSkills_GetHostProfession()
    local headingH = (block.heading and block.heading:GetStringHeight()) or 20
    local y = -(headingH + GAP_TITLE)
    local shown = 0
    for _, row in ipairs(block.rows) do
        local show = learnedSet[row.profId] == true
        row:SetShown(show)
        if show then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", block, "TOPLEFT", 0, y)
            row:SetPoint("RIGHT", block, "RIGHT", 0, 0)
            row.checkbox:SetChecked(row.profId == active)
            y = y - (SETTINGS_SMALL_CHECK + 4)
            shown = shown + 1
        end
    end
    if block.empty then
        block.empty:SetShown(shown == 0)
        if shown == 0 then
            block.empty:ClearAllPoints()
            block.empty:SetPoint("TOPLEFT", block.heading or block, "BOTTOMLEFT", 0, -GAP_TITLE)
            block.empty:SetPoint("RIGHT", 0, 0)
        end
    end
    block:SetHeight(math.max(headingH + 14, headingH + GAP_TITLE + math.max(shown, shown == 0 and 1 or 0) * (SETTINGS_SMALL_CHECK + 4)))
end

function Settings:BuildHostProfessionPicker(parent, anchor)
    local block = CreateFrame("Frame", nil, parent)
    block:SetPoint("TOP", anchor, "BOTTOM", 0, -GAP_TITLE)
    block:SetPoint("LEFT", parent, "LEFT", BODY_PAD, 0)
    block:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)

    local label = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetPoint("RIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    ApplyTitleFont(label)
    label:SetTextColor(1, 1, 1)
    label:SetText("Default profession when you host a camp")
    block.heading = label

    local empty = block:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    empty:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -GAP_TITLE)
    empty:SetPoint("RIGHT", 0, 0)
    empty:SetJustifyH("LEFT")
    empty:SetText("No professions detected yet.")
    empty:Hide()
    block.empty = empty

    block.rows = {}
    for i, prof in ipairs(SmoreSkills.PROFESSIONS) do
        local row = CreateFrame("Frame", nil, block)
        row:SetHeight(SETTINGS_SMALL_CHECK + 4)
        row.profId = prof.id
        local hold, cb = MakeCheckButton(row, SETTINGS_SMALL_CHECK)
        hold:SetPoint("LEFT", 0, 0)
        local icon = MakeTinyIcon(row, SmoreSkills_ProfessionIcon(prof.id))
        icon:SetPoint("LEFT", hold, "RIGHT", 4, 0)
        local labelBtn, text = MakeCheckLabel(row, cb, ApplySmallFont)
        labelBtn:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        labelBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        labelBtn:SetPoint("TOP", row, "TOP", 0, 0)
        labelBtn:SetPoint("BOTTOM", row, "BOTTOM", 0, 0)
        text:SetText(prof.label)
        row.checkbox = cb
        row.label = text
        row.profIcon = icon
        cb:SetScript("OnClick", function()
            SmoreSkills_SetHostProfession(prof.id)
            Settings:RefreshHostProfessionPicker()
            local camp = (SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp())
                or (SmoreSkills_GetLocalCamp and SmoreSkills_GetLocalCamp())
            if camp then
                SmoreSkills_ApplyHostProfession(camp, true)
                if SmoreSkills.Sync and SmoreSkills.Sync.IsHosting and SmoreSkills.Sync:IsHosting() then
                    SmoreSkills_ShareOwnedCampFromClick()
                end
            end
            RefreshAll()
        end)
        block.rows[i] = row
    end
    self.hostProfBlock = block
    self:RefreshHostProfessionPicker()
    return block
end

function Settings:RefreshHostButton()
    if self.hostNowBtn then
        self.hostNowBtn:SetShown(not SmoreSkills_GetAutoHostOnCampfire())
    end
    self:LayoutGeneralPage()
end

function Settings:RefreshFilterVisibility()
    local hostOn = SmoreSkills_GetHostFilterEnabled()
    local seekerOn = SmoreSkills_GetSeekerFilterEnabled()
    if self.hostGridArea then
        self.hostGridArea:SetShown(hostOn)
    end
    if self.hostFilterHint then
        self.hostFilterHint:SetShown(hostOn)
    end
    if self.hostItemHint then
        self.hostItemHint:SetShown(hostOn)
    end
    if self.hostItemArea then
        self.hostItemArea:SetShown(hostOn)
    end
    if self.seekerGridArea then
        self.seekerGridArea:SetShown(seekerOn)
    end
    if self.seekerFilterHint then
        self.seekerFilterHint:SetShown(seekerOn)
    end
    if self.seekerItemHint then
        self.seekerItemHint:SetShown(seekerOn)
    end
    if self.seekerItemSubtext then
        self.seekerItemSubtext:SetShown(seekerOn)
    end
    if self.seekerItemArea then
        self.seekerItemArea:SetShown(seekerOn)
    end
end

function Settings:Refresh()
    if not self.frame then
        return
    end
    SmoreSkills_EnsureSettings()

    if self.autoHost and self.autoHost.checkbox then
        self.autoHost.checkbox:SetChecked(SmoreSkills_GetAutoHostOnCampfire())
    end
    if self.showMinimap and self.showMinimap.checkbox then
        self.showMinimap.checkbox:SetChecked(SmoreSkills_GetShowMinimapButton())
    end
    if self.lockMinimap and self.lockMinimap.checkbox then
        self.lockMinimap.checkbox:SetChecked(SmoreSkills_GetLockMinimapButton())
    end
    if self.chatToggle and self.chatToggle.checkbox then
        self.chatToggle.checkbox:SetChecked(SmoreSkills_GetChatEnabled())
    end
    if self.guildMark and self.guildMark.checkbox then
        self.guildMark.checkbox:SetChecked(SmoreSkills_GetShowGuildMark())
    end
    if self.crossLayer and self.crossLayer.checkbox then
        self.crossLayer.checkbox:SetChecked(SmoreSkills_GetCrossLayerEnabled())
    end
    if self.pinScaleRow and self.pinScaleRow.slider then
        local pct = SmoreSkills_GetPinScalePct()
        self.pinScaleRow._syncing = true
        self.pinScaleRow.slider:SetValue(pct)
        if self.pinScaleRow.value then
            self.pinScaleRow.value:SetText(tostring(pct) .. "%")
        end
        self.pinScaleRow._syncing = false
    end
    if self.hostFilter and self.hostFilter.checkbox then
        self.hostFilter.checkbox:SetChecked(SmoreSkills_GetHostFilterEnabled())
    end
    if self.seekerFilter and self.seekerFilter.checkbox then
        self.seekerFilter.checkbox:SetChecked(SmoreSkills_GetSeekerFilterEnabled())
    end
    self:RefreshFilterVisibility()
    self:RefreshHostButton()
    self:RefreshHostProfessionPicker()
    self:RefreshProfessionGrid(self.hostGrid, "hostWant")
    self:RefreshProfessionGrid(self.seekerGrid, "seekerWant")
    self:LayoutHostPage()
    self:LayoutSeekerPage()
    self:LayoutGeneralPage()
    self:ApplyMinimapButtonVisibility()
end

function Settings:CenterPopup()
    if not self.frame then
        return
    end
    if self.popupPlaced then
        return
    end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.popupPlaced = true
end

function Settings:HidePopup()
    if self.frame then
        self.frame:Hide()
    end
end

function Settings:ShowPopup()
    self:Init()
    self:Refresh()
    self:SelectTab(self.activeTab or "general")
    self:CenterPopup()
    self.frame:Show()
    if SmoreSkills.HostPanel and SmoreSkills.HostPanel.HideMenu then
        SmoreSkills.HostPanel:HideMenu()
    end
    local function relayout()
        Settings:LayoutHostPage()
        Settings:LayoutSeekerPage()
        Settings:LayoutGeneralPage()
    end
    relayout()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, relayout)
    end
end

function Settings:TogglePopup()
    self:Init()
    if self.frame:IsShown() then
        self:HidePopup()
    else
        self:ShowPopup()
    end
end

function Settings:Toggle()
    self:TogglePopup()
end

function Settings:UpdateMinimapButton()
    if not self.minimapButton or not Minimap then
        return
    end
    local angle = math.rad(GetMinimapAngle())
    local radius = MINIMAP_RADIUS
    if Minimap.GetWidth then
        local w = Minimap:GetWidth()
        if w and w > 20 then
            radius = (w / 2) + 2
        end
    end
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function Settings:ApplyMinimapButtonVisibility()
    if not self.minimapButton then
        return
    end
    if SmoreSkills_GetShowMinimapButton() then
        self.minimapButton:Show()
        self:UpdateMinimapButton()
    else
        self.minimapButton:Hide()
    end
end

function Settings:RemoveLegacyMinimapSeekButton()
    local legacy = _G.SmoreSkillsMinimapSeekButton
    if legacy then
        legacy:Hide()
        legacy:EnableMouse(false)
        legacy:SetParent(nil)
        _G.SmoreSkillsMinimapSeekButton = nil
    end
end

function Settings:CreateMinimapButton()
    if self.minimapButton or not Minimap then
        return
    end

    local btn = CreateFrame("Button", "SmoreSkillsMinimapButton", Minimap)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetFrameStrata("HIGH")
    local miniLevel = (Minimap.GetFrameLevel and Minimap:GetFrameLevel()) or 20
    btn:SetFrameLevel(miniLevel + 10)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(25, 25)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", 2, -4)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetTexture(ICON)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetPoint("TOPLEFT", 6, -5)
    AddCircleMask(btn, icon, 20)

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT", 0, 0)

    local glow = btn:CreateTexture(nil, "OVERLAY")
    glow:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    glow:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Toggle")
    glow:SetPoint("TOPLEFT", 0, 0)
    glow:SetBlendMode("ADD")
    glow:Hide()

    if btn.RegisterForClicks then
        pcall(function()
            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        end)
    end
    btn:RegisterForDrag("LeftButton")

    btn:SetScript("OnClick", function(_, mouseButton)
        if IsRightClick(mouseButton) then
            Settings:TogglePopup()
            return
        end
        Settings:HidePopup()
        OpenWorldMap()
    end)

    btn:SetScript("OnDragStart", function(selfBtn)
        if SmoreSkills_GetLockMinimapButton() then
            return
        end
        selfBtn:LockHighlight()
        selfBtn:SetScript("OnUpdate", function(s)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            SetMinimapAngle(math.deg(math.atan2(py - my, px - mx)))
            Settings:UpdateMinimapButton()
        end)
    end)

    btn:SetScript("OnDragStop", function(selfBtn)
        selfBtn:UnlockHighlight()
        selfBtn:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_LEFT")
        GameTooltip:SetText("S'more Skills", 1, 1, 1)
        GameTooltip:AddLine("Left-click: open world map.", 1, 0.82, 0)
        GameTooltip:AddLine("Right-click: campsite settings.", 1, 0.82, 0)
        if SmoreSkills_GetLockMinimapButton() then
            GameTooltip:AddLine("Minimap icon is locked.", 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine("Drag to move icon.", 1, 0.82, 0)
        end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.minimapButton = btn
    self.minimapIcon = icon
    self.minimapBackground = bg
    self.minimapBorder = border
    self.minimapGlow = glow
    self:UpdateMinimapButton()
    self:ApplyMinimapButtonVisibility()
    if SmoreSkills.Map and SmoreSkills.Map.RefreshState then
        SmoreSkills.Map:RefreshState()
    end
end

function Settings:EnsureMinimapButton()
    self:RemoveLegacyMinimapSeekButton()
    if self.minimapButton then
        self:ApplyMinimapButtonVisibility()
        return true
    end
    if Minimap then
        self:CreateMinimapButton()
        return self.minimapButton ~= nil
    end
    if self.minimapWaitFrame then
        return false
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(self)
        if Settings:EnsureMinimapButton() then
            self:UnregisterAllEvents()
        end
    end)
    self.minimapWaitFrame = f
    return false
end

function Settings:BuildGeneralPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    local page = CreatePageScroll(panel)
    panel:SetScript("OnSizeChanged", function()
        Settings:LayoutGeneralPage()
    end)
    self.generalPage = page
    local content = page.content

    local title = CreateSectionTitle(content, "General", -GAP_TITLE)
    self.autoHost = CreateCheckbox(content, "Auto host when placing a Basic Campfire Kit", title, -GAP_TITLE)
    self.autoHostHint = CreateHint(
        content,
        "Use a Campfire Kit (or light a campfire) in the world to host locally. Crafting the kit at the cooking window does not host. Click Find or /smores host so seekers get the pin.",
        self.autoHost,
        -GAP_HINT
    )
    self.autoHost.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetAutoHostOnCampfire(selfCb:GetChecked())
        Settings:RefreshHostButton()
        RefreshAll()
    end)

    self.hostNowBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    self.hostNowBtn:SetSize(120, 22)
    self.hostNowBtn:SetPoint("TOPLEFT", self.autoHostHint, "BOTTOMLEFT", 0, -GAP_SECTION)
    self.hostNowBtn:SetText("Host camp")
    self.hostNowBtn:SetScript("OnClick", function()
        if SmoreSkills.Sync and SmoreSkills.Sync.HostHere then
            SmoreSkills.Sync:HostHere(true)
        end
    end)

    self.pinScaleRow = CreatePercentSlider(
        content,
        "Camp icon size on the world map",
        self.hostNowBtn,
        -GAP_SECTION,
        50,
        150,
        5
    )
    self.pinScaleRow.slider:SetScript("OnValueChanged", function(_, val)
        if self.pinScaleRow._syncing then
            return
        end
        local pct = SmoreSkills_SetPinScalePct(val)
        if self.pinScaleRow.value then
            self.pinScaleRow.value:SetText(tostring(pct) .. "%")
        end
        RefreshAll()
    end)

    self.showMinimap = CreateCheckbox(content, "Show minimap button", self.pinScaleRow, -GAP_SECTION)
    self.showMinimap.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetShowMinimapButton(selfCb:GetChecked())
        Settings:ApplyMinimapButtonVisibility()
    end)
    self.showMinimapHint = CreateHint(
        content,
        "If hidden, /smores still opens settings.",
        self.showMinimap,
        -GAP_HINT
    )

    self.lockMinimap = CreateCheckbox(content, "Lock minimap button", self.showMinimapHint, -GAP_SECTION)
    self.lockMinimap.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetLockMinimapButton(selfCb:GetChecked())
    end)

    self.chatToggle = CreateCheckbox(content, "Show chat messages from this addon", self.lockMinimap, -GAP_SECTION)
    self.chatToggle.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetChatEnabled(selfCb:GetChecked())
    end)
    self.chatHint = CreateHint(
        content,
        "When off, automatic messages are hidden. Slash commands like /smores still reply in chat.",
        self.chatToggle,
        -GAP_HINT
    )

    self.guildMark = CreateCheckbox(content, "Show guild mark on camp pins", self.chatHint, -GAP_SECTION)
    self.guildMark.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetShowGuildMark(selfCb:GetChecked())
        RefreshAll()
        if SmoreSkills.UI and SmoreSkills.UI.Refresh then
            SmoreSkills.UI:Refresh()
        end
    end)
    self.guildHint = CreateHint(
        content,
        "A green G means a guildie is at that camp. Hidden on your own pin.",
        self.guildMark,
        -GAP_HINT
    )

    self.crossLayer = CreateCheckbox(content, "Include camps on other layers", self.guildHint, -GAP_SECTION)
    self.crossLayer.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetCrossLayerEnabled(selfCb:GetChecked())
        RefreshAll()
        if SmoreSkills.UI and SmoreSkills.UI.Refresh then
            SmoreSkills.UI:Refresh()
        end
    end)
    self.crossLayerHint = CreateHint(
        content,
        "Off: Find and Host only match your current layer. On (default): also show and answer other layers (tooltip still says if it matches).",
        self.crossLayer,
        -GAP_HINT
    )

    self.commandHelp = CreateCommandHelp(content, self.crossLayerHint)

    page.bottom = self.commandHelp
    self:RefreshHostButton()
    return panel
end

function Settings:BuildHostPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    local page = CreatePageScroll(panel)
    page.relayout = function()
        Settings:LayoutHostPage()
    end
    panel:SetScript("OnSizeChanged", function()
        Settings:LayoutHostPage()
    end)
    self.hostPage = page
    local content = page.content

    local title = CreateSectionTitle(content, "Host defaults", -GAP_TITLE)
    self.hostDefaultsHint = CreateHint(
        content,
        "These apply every time you host a new camp. The camp panel can change them for the fire you have up now — that does not edit these defaults.",
        title,
        -GAP_HINT
    )
    local profBlock = self:BuildHostProfessionPicker(content, self.hostDefaultsHint)
    self.hostFilter = CreateCheckbox(
        content,
        "By default, only show your camp to players with specific professions",
        profBlock,
        -GAP_SECTION
    )
    self.hostFilter.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetHostFilterEnabled(selfCb:GetChecked())
        Settings:Refresh()
        RefreshAll()
    end)
    self.hostFilterHint = CreateHint(
        content,
        "Choose at least one profession or your camp won't appear to anyone.",
        self.hostFilter,
        -GAP_HINT
    )

    self.hostGridArea = CreateFrame("Frame", nil, content)
    self.hostGridArea:SetPoint("TOP", self.hostFilterHint, "BOTTOM", 0, -GAP_TITLE)
    self.hostGridArea:SetPoint("LEFT", content, "LEFT", BODY_PAD, 0)
    self.hostGridArea:SetPoint("RIGHT", content, "RIGHT", -BODY_PAD, 0)
    self.hostGrid = CreateProfGrid(self.hostGridArea, "hostWant")

    self.hostItemHint = CreateItemHeading(
        content,
        "Optional default: request camping objects you want campers to bring.",
        self.hostGridArea,
        -GAP_SECTION
    )
    self.hostItemArea = CreateFrame("Frame", nil, content)
    self.hostItemArea:SetPoint("TOP", self.hostItemHint, "BOTTOM", 0, -GAP_TITLE)
    self.hostItemArea:SetPoint("LEFT", content, "LEFT", BODY_PAD, 0)
    self.hostItemArea:SetPoint("RIGHT", content, "RIGHT", -BODY_PAD, 0)
    self.hostItemPicker = CreateItemPicker(self.hostItemArea, "hostWant")
    page.bottom = self.hostItemArea
    return panel
end

function Settings:BuildSeekerPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()
    local page = CreatePageScroll(panel)
    panel:SetScript("OnSizeChanged", function()
        Settings:LayoutSeekerPage()
    end)
    self.seekerPage = page
    local content = page.content

    local title = CreateSectionTitle(content, "Seeker", -GAP_TITLE)
    self.seekerFilter = CreateCheckbox(content, "Only discover camps with specific professions", title, -GAP_TITLE)
    self.seekerFilter.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetSeekerFilterEnabled(selfCb:GetChecked())
        Settings:Refresh()
        RefreshAll()
    end)
    self.seekerFilterHint = CreateHint(
        content,
        "Choose at least one profession or you won't discover any camps.",
        self.seekerFilter,
        -GAP_HINT
    )

    self.seekerGridArea = CreateFrame("Frame", nil, content)
    self.seekerGridArea:SetPoint("TOP", self.seekerFilterHint, "BOTTOM", 0, -GAP_TITLE)
    self.seekerGridArea:SetPoint("LEFT", content, "LEFT", BODY_PAD, 0)
    self.seekerGridArea:SetPoint("RIGHT", content, "RIGHT", -BODY_PAD, 0)
    self.seekerGrid = CreateProfGrid(self.seekerGridArea, "seekerWant")

    self.seekerItemHint = CreateItemHeading(
        content,
        "Optional: Only find camps that have at least one of these camping objects.",
        self.seekerGridArea,
        -GAP_SECTION
    )
    self.seekerItemSubtext = CreateHint(
        content,
        "If all are unchecked, you see all camps matching the professions you checked above.",
        self.seekerItemHint,
        -GAP_HINT
    )
    self.seekerItemArea = CreateFrame("Frame", nil, content)
    self.seekerItemArea:SetPoint("TOP", self.seekerItemSubtext, "BOTTOM", 0, -GAP_TITLE)
    self.seekerItemArea:SetPoint("LEFT", content, "LEFT", BODY_PAD, 0)
    self.seekerItemArea:SetPoint("RIGHT", content, "RIGHT", -BODY_PAD, 0)
    self.seekerItemPicker = CreateItemPicker(self.seekerItemArea, "seekerWant")
    page.bottom = self.seekerItemArea
    return panel
end

function Settings:Init()
    if self.frame and self.uiBuild == SETTINGS_UI_BUILD then
        return
    end
    if self.frame then
        self.frame:Hide()
        self.frame = nil
        self.tabs = nil
        self.panels = nil
        self.body = nil
        self.hostGrid = nil
        self.seekerGrid = nil
        self.hostGridArea = nil
        self.seekerGridArea = nil
        self.hostItemArea = nil
        self.seekerItemArea = nil
        self.hostItemPicker = nil
        self.seekerItemPicker = nil
        self.hostItemHint = nil
        self.hostDefaultsHint = nil
        self.seekerItemHint = nil
        self.seekerItemSubtext = nil
        self.hostFilter = nil
        self.hostFilterHint = nil
        self.seekerFilter = nil
        self.seekerFilterHint = nil
        self.autoHost = nil
        self.autoHostHint = nil
        self.hostNowBtn = nil
        self.hostProfBlock = nil
        self.hostPage = nil
        self.seekerPage = nil
        self.generalPage = nil
        self.pinScaleRow = nil
        self.showMinimap = nil
        self.showMinimapHint = nil
        self.lockMinimap = nil
        self.chatToggle = nil
        self.chatHint = nil
        self.guildMark = nil
        self.guildHint = nil
        self.crossLayer = nil
        self.crossLayerHint = nil
        self.commandHelp = nil
        self.popupPlaced = nil
    end

    local f
    if BackdropTemplateMixin then
        f = CreateFrame("Frame", "SmoreSkillsSettingsFrame", UIParent, "BackdropTemplate")
    else
        f = CreateFrame("Frame", "SmoreSkillsSettingsFrame", UIParent)
    end
    f:SetSize(POPUP_WIDTH, POPUP_HEIGHT)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    if f.SetClampedToScreen then
        f:SetClampedToScreen(true)
    end
    f:Hide()
    ApplyPanelChrome(f, false)
    tinsert(UISpecialFrames, "SmoreSkillsSettingsFrame")

    local headerBar = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    headerBar:SetHeight(HEADER_HEIGHT)
    headerBar:SetPoint("TOPLEFT", HEADER_INSET, -8)
    headerBar:SetPoint("TOPRIGHT", -CLOSE_INSET, -8)
    ApplyPanelChrome(headerBar, true)
    headerBar:EnableMouse(true)
    headerBar:RegisterForDrag("LeftButton")
    headerBar:SetScript("OnDragStart", function()
        f:StartMoving()
    end)
    headerBar:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
    end)

    local title = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", headerBar, "CENTER", 0, 0)
    title:SetText("|cff" .. TITLE_YELLOW .. "S'more Skills Settings|r")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetFrameLevel((headerBar:GetFrameLevel() or 1) + 20)
    if close.SetHitRectInsets then
        close:SetHitRectInsets(-6, -6, -6, -6)
    end
    close:EnableMouse(true)
    close:SetScript("OnClick", function()
        Settings:HidePopup()
    end)

    local sidebarTop = -(8 + HEADER_HEIGHT + 6)
    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetPoint("TOPLEFT", HEADER_INSET, sidebarTop)
    sidebar:SetPoint("BOTTOMLEFT", HEADER_INSET, 10)
    sidebar:SetWidth(SIDEBAR_WIDTH)

    local body = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    body:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 6, 0)
    body:SetPoint("BOTTOMRIGHT", -HEADER_INSET, 10)
    ApplyPanelChrome(body, true)

    self.tabs = {
        general = CreateSidebarTab(sidebar, 1, "general", "General"),
        host = CreateSidebarTab(sidebar, 2, "host", "Host"),
        seeker = CreateSidebarTab(sidebar, 3, "seeker", "Seeker"),
    }

    self.panels = {
        general = self:BuildGeneralPanel(body),
        host = self:BuildHostPanel(body),
        seeker = self:BuildSeekerPanel(body),
    }

    close:SetFrameLevel((f:GetFrameLevel() or 1) + 80)

    -- Parent to the window, not the sidebar, so the four lines sit under Seeker.
    local credits = CreateFrame("Frame", nil, f)
    credits:SetSize(SIDEBAR_WIDTH, 64)
    credits:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", HEADER_INSET, 12)
    credits:SetFrameStrata(f:GetFrameStrata() or "FULLSCREEN_DIALOG")
    credits:SetFrameLevel((f:GetFrameLevel() or 1) + 90)
    credits:EnableMouse(false)

    local function CreditLine(anchor, text, r, g, b, template)
        local fs = credits:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
        fs:SetWidth(SIDEBAR_WIDTH - 4)
        if anchor then
            fs:SetPoint("BOTTOM", anchor, "TOP", 0, 1)
        else
            fs:SetPoint("BOTTOM", credits, "BOTTOM", 0, 0)
        end
        fs:SetJustifyH("CENTER")
        fs:SetText(text)
        if r then
            fs:SetTextColor(r, g, b)
        end
        return fs
    end

    local stik = CreditLine(nil, SmoreSkills.TESTER or "Stik", 0.85, 0.75, 0.45, "GameFontHighlightSmall")
    local tested = CreditLine(stik, "Tested by", 0.55, 0.55, 0.55, "GameFontDisableSmall")
    local weber = CreditLine(tested, SmoreSkills.AUTHOR or "Weber8210", 0.85, 0.75, 0.45, "GameFontHighlightSmall")
    CreditLine(weber, "Created by", 0.55, 0.55, 0.55, "GameFontDisableSmall")

    f:SetScript("OnHide", function()
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end
    end)

    self.frame = f
    self.body = body
    self.uiBuild = SETTINGS_UI_BUILD
    self.activeTab = "general"
    self:SelectTab("general")
    self:Refresh()
end

function Settings:EnsureInit()
    self:EnsureMinimapButton()
    if not self.frame then
        self:Init()
    end
end
