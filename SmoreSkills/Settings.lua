SmoreSkills = SmoreSkills or {}
SmoreSkills.Settings = SmoreSkills.Settings or {}

local Settings = SmoreSkills.Settings
local SETTINGS_UI_BUILD = 18
local ICON = SmoreSkills.ICON or "Interface\\Icons\\Spell_Fire_Fire"
local POPUP_WIDTH = 412
local POPUP_HEIGHT = 392
local SIDEBAR_WIDTH = 88
local HEADER_HEIGHT = 34
local HEADER_INSET = 10
local BODY_PAD = 14
local GRID_COL_GAP = 14
local GRID_LEFT_INSET = 2
local GRID_RIGHT_INSET = 6
local FILTER_GRID_GAP = 20
local TAB_LABEL_GAP = 10
local MINIMAP_RADIUS = 80
local BUTTON_SIZE = 31
local PANEL_BG = "Interface\\FrameGeneral\\UI-Background-Rock"
local PANEL_EDGE = "Interface\\DialogFrame\\UI-DialogBox-Border"
local BODY_BG = "Interface\\Tooltips\\UI-Tooltip-Background"
local PANEL_FILL = { 0.24, 0.19, 0.14, 0.97 }
local PANEL_BORDER = { 0.48, 0.40, 0.30, 1 }
local BODY_FILL = { 0.14, 0.12, 0.10, 0.92 }
local TAB_ICON_SIZE = 40
local TAB_GOLD_RING = 2
local TAB_LABEL_HEIGHT = 14
local TAB_INACTIVE_ALPHA = 0.55
local TAB_LABEL_ACTIVE = { 1, 0.82, 0.15 }
local TAB_LABEL_INACTIVE = { 0.55, 0.55, 0.55 }
local TITLE_YELLOW = "ffd200"
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
        bgFile = inset and BODY_BG or PANEL_BG,
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

local function CreateSectionTitle(parent, text, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", BODY_PAD, y)
    label:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)
    label:SetJustifyH("LEFT")
    label:SetText("|cff" .. TITLE_YELLOW .. text .. "|r")
    return label
end

local function CreateHint(parent, text, anchor, yOff)
    local hint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -4)
    hint:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText(text)
    hint:SetTextColor(0.65, 0.65, 0.65)
    return hint
end

local function CreateCheckbox(parent, label, anchor, yOff)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOP", anchor, "BOTTOM", 0, yOff or -6)
    row:SetPoint("LEFT", parent, "LEFT", BODY_PAD, 0)
    row:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)

    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("TOPLEFT", 0, 0)

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", cb, "TOPRIGHT", 4, -2)
    text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetWordWrap then
        text:SetWordWrap(true)
    end
    text:SetText(label)
    row:SetHeight(math.max(26, (text:GetStringHeight() or 16) + 6))

    row.checkbox = cb
    return row
end

local function LayoutProfGrid(panel)
    if not panel or not panel.checks then
        return
    end
    local w = panel:GetWidth()
    if not w or w < 80 then
        local parent = panel:GetParent()
        w = parent and parent:GetWidth() or 280
    end
    local gap = GRID_COL_GAP
    local innerW = math.max(200, w - GRID_LEFT_INSET - GRID_RIGHT_INSET)
    local colW = math.floor((innerW - gap) / 2)
    local rowHeight = 24
    local col, row = 0, 0
    for _, cb in ipairs(panel.checks) do
        local x = GRID_LEFT_INSET + col * (colW + gap)
        cb:ClearAllPoints()
        cb:SetSize(22, 22)
        cb:SetPoint("TOPLEFT", panel, "TOPLEFT", x, -row * rowHeight)
        cb.text:ClearAllPoints()
        cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        cb.text:SetPoint("RIGHT", panel, "TOPLEFT", x + colW, 0)
        cb.text:SetJustifyH("LEFT")
        if cb.text.SetWordWrap then
            cb.text:SetWordWrap(false)
        end
        if cb.text.SetNonSpaceWrap then
            cb.text:SetNonSpaceWrap(false)
        end
        col = col + 1
        if col > 1 then
            col = 0
            row = row + 1
        end
    end
    panel:SetHeight((row + 1) * rowHeight + 4)
end

local function CreateProfGrid(parent, wantKey)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", 0, 0)
    panel:SetPoint("BOTTOMRIGHT", 0, 0)
    panel.checks = {}
    panel.wantKey = wantKey
    for i, prof in ipairs(SmoreSkills.PROFESSIONS) do
        local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        cb:SetSize(22, 22)
        cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cb.text:SetText(prof.label)
        cb.text:SetTextColor(0.92, 0.92, 0.92)
        cb.profId = prof.id
        cb:SetScript("OnClick", function()
            SmoreSkills_ToggleWantProfession(wantKey, cb.profId)
            Settings:RefreshProfessionGrid(panel, wantKey)
            RefreshAll()
        end)
        panel.checks[i] = cb
    end
    panel:SetScript("OnSizeChanged", function()
        LayoutProfGrid(panel)
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
    for _, cb in ipairs(panel.checks) do
        cb:SetChecked(SmoreSkills_WantHasProfession(wantKey, cb.profId))
    end
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
    local y = -16
    local shown = 0
    for _, row in ipairs(block.rows) do
        local show = learnedSet[row.profId] == true
        row:SetShown(show)
        if show then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", block, "TOPLEFT", 0, y)
            row:SetPoint("RIGHT", block, "RIGHT", 0, 0)
            row.checkbox:SetChecked(row.profId == active)
            y = y - 22
            shown = shown + 1
        end
    end
    if block.empty then
        block.empty:SetShown(shown == 0)
    end
    block:SetHeight(math.max(32, 18 + math.max(shown, shown == 0 and 1 or 0) * 22))
end

function Settings:BuildHostProfessionPicker(parent, anchor)
    local block = CreateFrame("Frame", nil, parent)
    block:SetPoint("TOP", anchor, "BOTTOM", 0, -8)
    block:SetPoint("LEFT", parent, "LEFT", BODY_PAD, 0)
    block:SetPoint("RIGHT", parent, "RIGHT", -BODY_PAD, 0)

    local label = block:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetPoint("RIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText("Profession you are using at this camp")

    local empty = block:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    empty:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
    empty:SetPoint("RIGHT", 0, 0)
    empty:SetJustifyH("LEFT")
    empty:SetText("No professions detected yet.")
    empty:Hide()
    block.empty = empty

    block.rows = {}
    for i, prof in ipairs(SmoreSkills.PROFESSIONS) do
        local row = CreateFrame("Frame", nil, block)
        row:SetHeight(22)
        row.profId = prof.id
        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetSize(22, 22)
        cb:SetPoint("LEFT", 0, 0)
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        text:SetText(prof.label)
        row.checkbox = cb
        cb:SetScript("OnClick", function()
            SmoreSkills_SetHostProfession(prof.id)
            Settings:RefreshHostProfessionPicker()
            local camp = SmoreSkills_GetLocalCamp and SmoreSkills_GetLocalCamp()
            if camp then
                SmoreSkills_ApplyHostProfession(camp)
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
end

function Settings:RefreshFilterVisibility()
    local hostOn = SmoreSkills_GetHostFilterEnabled()
    local seekerOn = SmoreSkills_GetSeekerFilterEnabled()
    if self.hostGridArea then
        self.hostGridArea:SetShown(hostOn)
    end
    if self.seekerGridArea then
        self.seekerGridArea:SetShown(seekerOn)
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
end

function Settings:AnchorPopup()
    if not self.frame or not self.minimapButton then
        return
    end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("TOPRIGHT", self.minimapButton, "BOTTOMRIGHT", 0, -4)
    self.frame:SetFrameLevel(self.minimapButton:GetFrameLevel() + 20)
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
    self:AnchorPopup()
    self.frame:Show()
    local function relayout()
        if Settings.hostGrid then
            LayoutProfGrid(Settings.hostGrid)
        end
        if Settings.seekerGrid then
            LayoutProfGrid(Settings.seekerGrid)
        end
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
    local x = math.cos(angle) * MINIMAP_RADIUS
    local y = math.sin(angle) * MINIMAP_RADIUS
    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
    if self.frame and self.frame:IsShown() then
        self:AnchorPopup()
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
        GameTooltip:AddLine("Drag to move icon.", 1, 0.82, 0)
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
    btn:Show()
    if SmoreSkills.Map and SmoreSkills.Map.RefreshState then
        SmoreSkills.Map:RefreshState()
    end
end

function Settings:EnsureMinimapButton()
    self:RemoveLegacyMinimapSeekButton()
    if self.minimapButton then
        self:UpdateMinimapButton()
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

    local title = CreateSectionTitle(panel, "General", -8)
    self.autoHost = CreateCheckbox(panel, "Auto host when lighting a campfire", title, -10)
    self.autoHostHint = CreateHint(
        panel,
        "Placeholder: lighting Basic Campfire broadcasts this location to seekers. Replace with Forever's campsite API later.",
        self.autoHost,
        -2
    )
    self.autoHost.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetAutoHostOnCampfire(selfCb:GetChecked())
        Settings:RefreshHostButton()
        RefreshAll()
    end)

    self.hostNowBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    self.hostNowBtn:SetSize(120, 22)
    self.hostNowBtn:SetPoint("TOPLEFT", self.autoHostHint, "BOTTOMLEFT", 0, -12)
    self.hostNowBtn:SetText("Host camp")
    self.hostNowBtn:SetScript("OnClick", function()
        if SmoreSkills.Sync and SmoreSkills.Sync.HostHere then
            SmoreSkills.Sync:HostHere()
        end
    end)
    self:RefreshHostButton()
    return panel
end

function Settings:BuildHostPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local title = CreateSectionTitle(panel, "Host", -8)
    local profBlock = self:BuildHostProfessionPicker(panel, title)
    self.hostFilter = CreateCheckbox(
        panel,
        "Only have your camp appear on the map to players with specific professions",
        profBlock,
        -10
    )
    self.hostFilter.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetHostFilterEnabled(selfCb:GetChecked())
        Settings:Refresh()
        RefreshAll()
    end)

    self.hostGridArea = CreateFrame("Frame", nil, panel)
    self.hostGridArea:SetPoint("TOP", self.hostFilter, "BOTTOM", 0, -FILTER_GRID_GAP)
    self.hostGridArea:SetPoint("LEFT", panel, "LEFT", BODY_PAD, 0)
    self.hostGridArea:SetPoint("RIGHT", panel, "RIGHT", -BODY_PAD, 0)
    self.hostGridArea:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
    self.hostGrid = CreateProfGrid(self.hostGridArea, "hostWant")
    return panel
end

function Settings:BuildSeekerPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local title = CreateSectionTitle(panel, "Seeker", -8)
    self.seekerFilter = CreateCheckbox(panel, "Only discover camps with specific professions", title, -10)
    self.seekerFilter.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetSeekerFilterEnabled(selfCb:GetChecked())
        Settings:Refresh()
        RefreshAll()
    end)

    self.seekerGridArea = CreateFrame("Frame", nil, panel)
    self.seekerGridArea:SetPoint("TOP", self.seekerFilter, "BOTTOM", 0, -FILTER_GRID_GAP)
    self.seekerGridArea:SetPoint("LEFT", panel, "LEFT", BODY_PAD, 0)
    self.seekerGridArea:SetPoint("RIGHT", panel, "RIGHT", -BODY_PAD, 0)
    self.seekerGridArea:SetPoint("BOTTOM", panel, "BOTTOM", 0, 12)
    self.seekerGrid = CreateProfGrid(self.seekerGridArea, "seekerWant")
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
        self.hostFilter = nil
        self.seekerFilter = nil
        self.autoHost = nil
        self.autoHostHint = nil
        self.hostNowBtn = nil
        self.hostProfBlock = nil
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
    f:Hide()
    ApplyPanelChrome(f, false)
    tinsert(UISpecialFrames, "SmoreSkillsSettingsFrame")

    local headerBar = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    headerBar:SetHeight(HEADER_HEIGHT)
    headerBar:SetPoint("TOPLEFT", HEADER_INSET, -8)
    headerBar:SetPoint("TOPRIGHT", -HEADER_INSET, -8)
    ApplyPanelChrome(headerBar, true)

    local title = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", headerBar, "CENTER", 0, 0)
    title:SetText("|cff" .. TITLE_YELLOW .. "S'more Skills Settings|r")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
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
