SmoreSkills = SmoreSkills or {}
SmoreSkills.Settings = SmoreSkills.Settings or {}

local Settings = SmoreSkills.Settings
local ICON = SmoreSkills.ICON or "Interface\\Icons\\Spell_Fire_Fire"
local POPUP_WIDTH = 318
local POPUP_HEIGHT = 340
local SIDEBAR_WIDTH = 68
local MINIMAP_RADIUS = 80
local BUTTON_SIZE = 31
local PANEL_BG = "Interface\\DialogFrame\\UI-DialogBox-Background"
local PANEL_EDGE = "Interface\\DialogFrame\\UI-DialogBox-Border"
local PANEL_FILL = { 0.11, 0.09, 0.08, 1 }
local PANEL_BORDER = { 0.55, 0.45, 0.28, 1 }
local BODY_FILL = { 0.08, 0.07, 0.06, 1 }
local TAB_SIZE = 40
local TAB_INACTIVE_ALPHA = 0.42
local TITLE_YELLOW = "ffd200"
local GOLD = { 1, 0.82, 0 }
local QUESTIE = {
    btn = 32,
    bg = 25,
    bgX = 2,
    bgY = -4,
    icon = 20,
    iconX = 6,
    iconY = -5,
    border = 54,
}
local TAB_ICONS = {
    general = ICON,
    host = "Interface\\Icons\\Ability_Hunter_SniperShot",
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
    local fillColor = inset and BODY_FILL or PANEL_FILL
    AddSolidFill(frame, fillColor)
    if not frame.SetBackdrop then
        return
    end
    frame:SetBackdrop({
        bgFile = PANEL_BG,
        edgeFile = PANEL_EDGE,
        tile = true,
        tileSize = 16,
        edgeSize = inset and 12 or 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(fillColor[1], fillColor[2], fillColor[3], 1)
    frame:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], 1)
end

local function ApplyRingCluster(parent, scale, iconPath)
    local bg = parent:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(QUESTIE.bg * scale, QUESTIE.bg * scale)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", parent, "TOPLEFT", QUESTIE.bgX * scale, QUESTIE.bgY * scale)

    local iconSize = QUESTIE.icon * scale
    local icon = parent:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    icon:SetTexture(iconPath or ICON)
    icon:SetPoint("TOPLEFT", parent, "TOPLEFT", QUESTIE.iconX * scale, QUESTIE.iconY * scale)

    local ring = parent:CreateTexture(nil, "OVERLAY")
    ring:SetSize(QUESTIE.border * scale, QUESTIE.border * scale)
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    if ring.SetDrawLayer then
        ring:SetDrawLayer("OVERLAY", 1)
    end

    return bg, icon, ring
end

local function OpenWorldMapForSeek()
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
    label:SetPoint("TOPLEFT", 12, y)
    label:SetPoint("RIGHT", -16, 0)
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
    row:SetHeight(24)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -6)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, 0)

    local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("LEFT", 0, 0)

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    text:SetJustifyH("LEFT")
    if text.SetWordWrap then
        text:SetWordWrap(true)
    end
    text:SetText(label)

    row.checkbox = cb
    return row
end

local function CreateProfGrid(parent, wantKey)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetPoint("TOPLEFT", 0, 0)
    panel:SetPoint("TOPRIGHT", 0, 0)
    panel.checks = {}
    panel.wantKey = wantKey
    local col = 0
    local row = 0
    local rowHeight = 24
    for i, prof in ipairs(SmoreSkills.PROFESSIONS) do
        local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        cb:SetSize(22, 22)
        cb:SetPoint("TOPLEFT", col * 118, -row * rowHeight)
        cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        cb.text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
        cb.text:SetText(prof.label)
        cb.text:SetTextColor(0.92, 0.92, 0.92)
        cb.profId = prof.id
        cb:SetScript("OnClick", function()
            SmoreSkills_ToggleWantProfession(wantKey, cb.profId)
            Settings:RefreshProfessionGrid(panel, wantKey)
            RefreshAll()
        end)
        panel.checks[i] = cb
        col = col + 1
        if col > 1 then
            col = 0
            row = row + 1
        end
    end
    panel:SetHeight((row + 1) * rowHeight + 4)
    return panel
end

local function CreateSidebarTab(parent, index, tabKey, tooltip)
    local clusterScale = TAB_SIZE / QUESTIE.btn
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(TAB_SIZE, TAB_SIZE)
    btn:SetPoint("TOP", parent, "TOP", 0, -10 - (index - 1) * (TAB_SIZE + 12))

    local cluster = CreateFrame("Frame", nil, btn)
    cluster:SetSize(QUESTIE.btn * clusterScale, QUESTIE.btn * clusterScale)
    cluster:SetPoint("CENTER")
    cluster:EnableMouse(false)

    local bg, icon, ring = ApplyRingCluster(cluster, clusterScale, TAB_ICONS[tabKey] or ICON)
    ring:Hide()
    btn.cluster = cluster
    btn.bgTex = bg
    btn.iconTex = icon
    btn.ring = ring
    btn.tabKey = tabKey
    btn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip, 1, GOLD[1], GOLD[2])
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
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
            if active then
                btn.ring:Show()
                btn.ring:SetAlpha(1)
            else
                btn.ring:Hide()
            end
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
    icon:SetPoint("TOPLEFT", 6, -5)

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
        if SmoreSkills.Sync and SmoreSkills.Sync.SeekHere then
            SmoreSkills.Sync:SeekHere()
        end
        OpenWorldMapForSeek()
        if SmoreSkills.Map and SmoreSkills.Map.RefreshState then
            SmoreSkills.Map:RefreshState()
        end
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
        GameTooltip:AddLine("Left-click: find camps on the world map.", 1, 0.82, 0)
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

    self.autoHost = CreateFrame("Frame", nil, panel)
    self.autoHost:SetHeight(24)
    self.autoHost:SetPoint("TOPLEFT", 12, -14)
    self.autoHost:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, 0)
    local autoCb = CreateFrame("CheckButton", nil, self.autoHost, "UICheckButtonTemplate")
    autoCb:SetSize(24, 24)
    autoCb:SetPoint("LEFT", 0, 0)
    self.autoHost.checkbox = autoCb
    local autoLabel = self.autoHost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    autoLabel:SetPoint("LEFT", autoCb, "RIGHT", 4, 0)
    autoLabel:SetPoint("RIGHT", self.autoHost, "RIGHT", 0, 0)
    autoLabel:SetJustifyH("LEFT")
    if autoLabel.SetWordWrap then
        autoLabel:SetWordWrap(true)
    end
    autoLabel:SetText("Auto host when lighting a campfire")
    autoCb:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetAutoHostOnCampfire(selfCb:GetChecked())
        RefreshAll()
    end)
    return panel
end

function Settings:BuildHostPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local title = CreateSectionTitle(panel, "Host", -8)
    self.hostFilter = CreateCheckbox(panel, "Only invite specific professions", title, -10)
    self.hostFilter.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetHostFilterEnabled(selfCb:GetChecked())
        Settings:Refresh()
        RefreshAll()
    end)

    self.hostGridArea = CreateFrame("Frame", nil, panel)
    self.hostGridArea:SetPoint("TOPLEFT", self.hostFilter, "BOTTOMLEFT", 0, -10)
    self.hostGridArea:SetPoint("BOTTOMRIGHT", -12, 10)
    self.hostGrid = CreateProfGrid(self.hostGridArea, "hostWant")
    return panel
end

function Settings:BuildSeekerPanel(parent)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local title = CreateSectionTitle(panel, "Seeker", -8)
    self.seekerFilter = CreateCheckbox(panel, "Only show matching camps", title, -10)
    self.seekerFilter.checkbox:SetScript("OnClick", function(selfCb)
        SmoreSkills_SetSeekerFilterEnabled(selfCb:GetChecked())
        Settings:Refresh()
        RefreshAll()
    end)

    self.seekerGridArea = CreateFrame("Frame", nil, panel)
    self.seekerGridArea:SetPoint("TOPLEFT", self.seekerFilter, "BOTTOMLEFT", 0, -10)
    self.seekerGridArea:SetPoint("BOTTOMRIGHT", -12, 10)
    self.seekerGrid = CreateProfGrid(self.seekerGridArea, "seekerWant")
    return panel
end

function Settings:Init()
    if self.frame then
        return
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

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("|cff" .. TITLE_YELLOW .. "S'more skills settings|r")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function()
        Settings:HidePopup()
    end)

    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetPoint("TOPLEFT", 8, -32)
    sidebar:SetPoint("BOTTOMLEFT", 8, 8)
    sidebar:SetWidth(SIDEBAR_WIDTH)

    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], 0.85)
    divider:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 4, 0)
    divider:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMRIGHT", 4, 0)
    divider:SetWidth(1)

    local body = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    body:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    body:SetPoint("BOTTOMRIGHT", -8, 8)
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
