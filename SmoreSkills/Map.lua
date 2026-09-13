SmoreSkills = SmoreSkills or {}
SmoreSkills.Map = SmoreSkills.Map or {}

local Map = SmoreSkills.Map
local ICON = SmoreSkills.ICON or "Interface\\Icons\\Spell_Fire_Fire"
-- QuestieWorldMapButtonTemplate layout (Questie/Modules/WorldMapButton).
local BUTTON_SIZE = 32
local MAP_OFFSET_X = 4
local MAP_OFFSET_Y = 4
local FADE_PERIOD = 2.8
local FADE_MIN = 0.35
local FADE_MAX = 1.0
local FIRE_SCALE = 1.5
local SOCKET_TOOLTIP_SCALE = FIRE_SCALE * 2 * 0.8
local PIN_FRAME_LEVEL = 2016
local TOOLTIP_BG = "Interface\\DialogFrame\\UI-DialogBox-Background"
local TOOLTIP_EDGE = "Interface\\DialogFrame\\UI-DialogBox-Border"
local TOOLTIP_FILL = { 0.11, 0.09, 0.08, 1 }
local TOOLTIP_BORDER = { 0.55, 0.45, 0.28, 1 }
local TITLE_YELLOW = { 1, 0.82, 0 }
local SOLID_TEX = "Interface\\Buttons\\WHITE8X8"
local CIRCLE_BG = "Interface\\Minimap\\UI-Minimap-Background"
local SOCKET_GOLD = { 1, 0.82, 0 }
local SOCKET_RING = 3
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
-- QuestieWorldMapButtonTemplate proportions (Modules/WorldMapButton).
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
local PIN_HIT_SIZE = math.ceil(QUESTIE.btn * FIRE_SCALE + 8)

Map.pins = Map.pins or {}
Map.pinPool = Map.pinPool or {}

local function GetMapCanvas()
    if WorldMapFrame and WorldMapFrame.GetCanvas then
        return WorldMapFrame:GetCanvas()
    end
    if WorldMapFrame and WorldMapFrame.GetCanvasContainer then
        return WorldMapFrame:GetCanvasContainer()
    end
    return WorldMapFrame and (WorldMapFrame.ScrollContainer or WorldMapFrame)
end

local function GetViewMapId()
    if not WorldMapFrame or not WorldMapFrame.GetMapID then
        return nil
    end
    return WorldMapFrame:GetMapID()
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

local function ApplyQuestieCluster(parent, clusterScale, iconPath)
    local bg = parent:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(QUESTIE.bg * clusterScale, QUESTIE.bg * clusterScale)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", parent, "TOPLEFT", QUESTIE.bgX * clusterScale, QUESTIE.bgY * clusterScale)

    local iconSize = QUESTIE.icon * clusterScale
    local icon = parent:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    icon:SetTexture(iconPath or ICON)
    icon:SetPoint("TOPLEFT", parent, "TOPLEFT", QUESTIE.iconX * clusterScale, QUESTIE.iconY * clusterScale)
    AddCircleMask(parent, icon, iconSize)

    local ring = parent:CreateTexture(nil, "OVERLAY")
    ring:SetSize(QUESTIE.border * clusterScale, QUESTIE.border * clusterScale)
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    if ring.SetDrawLayer then
        ring:SetDrawLayer("OVERLAY", 1)
    end

    return bg, icon, ring
end

local function SetSolidColor(texture, r, g, b, a)
    if not texture then
        return
    end
    if texture.SetColorTexture then
        texture:SetColorTexture(r, g, b, a or 1)
    else
        texture:SetTexture(SOLID_TEX)
        texture:SetVertexColor(r, g, b, a or 1)
    end
end

local function SafeDesaturate(texture, desaturated)
    if not texture then
        return
    end
    if texture.SetDesaturated then
        texture:SetDesaturated(desaturated)
    elseif texture.SetVertexColor then
        if desaturated then
            texture:SetVertexColor(0.55, 0.55, 0.55)
        else
            texture:SetVertexColor(1, 1, 1)
        end
    end
end

local function AddTooltipSolidFill(frame)
    if frame.solidFill then
        SetSolidColor(frame.solidFill, TOOLTIP_FILL[1], TOOLTIP_FILL[2], TOOLTIP_FILL[3], TOOLTIP_FILL[4])
        return
    end
    local fill = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    fill:SetAllPoints()
    SetSolidColor(fill, TOOLTIP_FILL[1], TOOLTIP_FILL[2], TOOLTIP_FILL[3], TOOLTIP_FILL[4])
    frame.solidFill = fill
end

local function CreateCircularTooltipSocket(parent, size)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(size, size)

    local goldCircle = holder:CreateTexture(nil, "BACKGROUND")
    goldCircle:SetSize(size, size)
    goldCircle:SetPoint("CENTER")
    goldCircle:SetTexture(CIRCLE_BG)
    goldCircle:SetVertexColor(SOCKET_GOLD[1], SOCKET_GOLD[2], SOCKET_GOLD[3], 1)
    holder.goldCircle = goldCircle

    local innerSize = size - SOCKET_RING * 2
    local inner = holder:CreateTexture(nil, "ARTWORK", nil, -1)
    inner:SetSize(innerSize, innerSize)
    inner:SetPoint("CENTER")
    inner:SetTexture(CIRCLE_BG)
    inner:SetVertexColor(TOOLTIP_FILL[1], TOOLTIP_FILL[2], TOOLTIP_FILL[3], 1)
    holder.fill = inner

    local iconSize = innerSize * 0.72
    local icon = holder:CreateTexture(nil, "ARTWORK", nil, 1)
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("CENTER")
    AddCircleMask(holder, icon, iconSize)
    holder.icon = icon

    return holder
end

local function StyleTooltipSocket(holder, slot)
    holder.goldCircle:SetVertexColor(SOCKET_GOLD[1], SOCKET_GOLD[2], SOCKET_GOLD[3], 1)
    if slot and slot.profession then
        holder.fill:SetVertexColor(0.14, 0.11, 0.09, 1)
        holder.icon:SetTexture(SmoreSkills_ProfessionIcon(slot.profession))
        holder.icon:SetTexCoord(0, 1, 0, 1)
        holder.icon:Show()
        SafeDesaturate(holder.icon, false)
        holder.icon:SetAlpha(1)
    else
        holder.fill:SetVertexColor(TOOLTIP_FILL[1], TOOLTIP_FILL[2], TOOLTIP_FILL[3], 0.85)
        holder.icon:Hide()
    end
end

local function ApplyTooltipChrome(frame)
    AddTooltipSolidFill(frame)
    if not frame.SetBackdrop then
        return
    end
    frame:SetBackdrop({
        bgFile = TOOLTIP_BG,
        edgeFile = TOOLTIP_EDGE,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(TOOLTIP_FILL[1], TOOLTIP_FILL[2], TOOLTIP_FILL[3], 1)
    frame:SetBackdropBorderColor(TOOLTIP_BORDER[1], TOOLTIP_BORDER[2], TOOLTIP_BORDER[3], 1)
end

local function EnsureCampTooltip()
    if Map.campTooltip and Map.campTooltip.tooltipVersion == 4 then
        return Map.campTooltip
    end
    if Map.campTooltip then
        Map.campTooltip:Hide()
        Map.campTooltip = nil
    end
    local tip
    if BackdropTemplateMixin then
        tip = CreateFrame("Frame", "SmoreSkillsCampTooltip", UIParent, "BackdropTemplate")
    else
        tip = CreateFrame("Frame", "SmoreSkillsCampTooltip", UIParent)
    end
    tip:SetFrameStrata("TOOLTIP")
    if tip.SetClampedToScreen then
        tip:SetClampedToScreen(true)
    end
    tip:EnableMouse(false)
    tip:Hide()
    ApplyTooltipChrome(tip)

    tip.title = tip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tip.title:SetPoint("TOPLEFT", 12, -10)
    tip.title:SetJustifyH("LEFT")

    tip.coords = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tip.coords:SetPoint("TOPLEFT", tip.title, "BOTTOMLEFT", 0, -2)
    tip.coords:SetJustifyH("LEFT")
    tip.coords:SetTextColor(0.7, 0.7, 0.7)

    tip.slotsLabel = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tip.slotsLabel:SetPoint("TOPLEFT", tip.coords, "BOTTOMLEFT", 0, -2)
    tip.slotsLabel:SetJustifyH("LEFT")
    tip.slotsLabel:SetTextColor(0.75, 0.75, 0.75)

    local socketRow = CreateFrame("Frame", nil, tip)
    socketRow:SetPoint("TOPLEFT", tip.slotsLabel, "BOTTOMLEFT", -4, -8)
    tip.socketRow = socketRow
    tip.sockets = {}

    local socketSize = QUESTIE.btn * SOCKET_TOOLTIP_SCALE
    local socketGap = 6
    for i = 1, SmoreSkills.MAX_SLOTS do
        local holder = CreateCircularTooltipSocket(socketRow, socketSize)
        holder:SetPoint("LEFT", socketRow, "LEFT", (i - 1) * (socketSize + socketGap), 0)
        tip.sockets[i] = holder
    end
    socketRow:SetSize(SmoreSkills.MAX_SLOTS * socketSize + (SmoreSkills.MAX_SLOTS - 1) * socketGap, socketSize)

    tip.footer = tip:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tip.footer:SetPoint("TOPLEFT", socketRow, "BOTTOMLEFT", 4, -8)
    tip.footer:SetPoint("RIGHT", tip, "RIGHT", -12, 0)
    tip.footer:SetJustifyH("LEFT")
    tip.footer:SetTextColor(0.55, 0.55, 0.55)

    tip.tooltipVersion = 4
    Map.campTooltip = tip
    return tip
end

local function HideCampTooltip()
    if Map.campTooltip then
        Map.campTooltip:Hide()
    end
end

local function ShowPinTooltipFallback(pin, camp)
    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    if GameTooltip.ClearLines then
        GameTooltip:ClearLines()
    end
    local filled = SmoreSkills_CountFilledSlots(camp)
    GameTooltip:SetText(camp.zone or "Camp", 1, 0.82, 0.45)
    GameTooltip:AddLine(SmoreSkills_FormatCoords(camp), 0.7, 0.7, 0.7)
    GameTooltip:AddLine(string.format("%d/%d slots filled", filled, SmoreSkills.MAX_SLOTS), 0.75, 0.75, 0.75)
    for i = 1, SmoreSkills.MAX_SLOTS do
        GameTooltip:AddLine(SmoreSkills_FormatSlotTooltipLine(camp, i), 0.92, 0.92, 0.92)
    end
    if camp.owner == "TestCamper" then
        GameTooltip:AddLine("Test camp (local preview)", 0.55, 0.55, 0.55)
    end
    GameTooltip:Show()
end

local function ShowPinTooltip(pin)
    local camp = pin and pin.camp
    if not camp then
        return
    end
    HideCampTooltip()
    GameTooltip:Hide()
    SmoreSkills_EnsureSlots(camp)

    local ok, err = pcall(function()
        local tip = EnsureCampTooltip()
        local filled = SmoreSkills_CountFilledSlots(camp)
        tip.title:SetText(camp.zone or "Camp")
        tip.title:SetTextColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3])
        tip.coords:SetText(SmoreSkills_FormatCoords(camp))
        tip.slotsLabel:SetText(string.format("%d/%d slots filled", filled, SmoreSkills.MAX_SLOTS))

        for i = 1, SmoreSkills.MAX_SLOTS do
            StyleTooltipSocket(tip.sockets[i], camp.slots[i])
        end

        local footerLines = {}
        for i = 1, SmoreSkills.MAX_SLOTS do
            table.insert(footerLines, SmoreSkills_FormatSlotTooltipLine(camp, i))
        end
        if camp.want and camp.want ~= "any" then
            table.insert(footerLines, "Host wants: " .. SmoreSkills_FormatWant(camp.want))
        end
        if camp.owner == "TestCamper" then
            table.insert(footerLines, "Test camp (local preview)")
        end
        tip.footer:SetText(table.concat(footerLines, "\n"))
        tip.footer:SetWidth(math.max(260, tip.socketRow:GetWidth() + 8))

        local parent = WorldMapFrame or UIParent
        tip:SetParent(parent)
        tip:SetFrameStrata("TOOLTIP")
        local tipLevel = 10000
        if WorldMapFrame and WorldMapFrame.GetFrameLevel then
            tipLevel = WorldMapFrame:GetFrameLevel() + 200
        end
        tip:SetFrameLevel(tipLevel)

        tip:ClearAllPoints()
        tip:SetPoint("TOPLEFT", pin, "TOPRIGHT", 8, 0)
        tip:SetWidth(math.max(280, tip.socketRow:GetWidth() + 24))
        local footerHeight = tip.footer:GetStringHeight() or 40
        tip:SetHeight(10 + 14 + 12 + 12 + tip.socketRow:GetHeight() + 8 + footerHeight + 14)
        tip:Show()
    end)

    if not ok then
        if not Map.campTooltipErrorLogged then
            SmoreSkills_Print("Camp tooltip error (using text fallback): " .. tostring(err))
            Map.campTooltipErrorLogged = true
        end
        ShowPinTooltipFallback(pin, camp)
    end
end

function Map:UpdateTooltip()
    if not self.button then
        return
    end
    local btn = self.button
    local sync = SmoreSkills.Sync
    GameTooltip:SetOwner(btn, "ANCHOR_NONE")
    if GameTooltip.ClearLines then
        GameTooltip:ClearLines()
    end
    GameTooltip:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, 0)
    GameTooltip:SetText("Find campsites in this zone", 1, 1, 1)
    GameTooltip:AddLine("Send a seek signal to other S'more Skills users.", 0.9, 0.9, 0.9, true)

    if sync and sync.IsSeeking and sync:IsSeeking() then
        local left = sync:GetSeekingRemaining()
        local mins = math.floor(left / 60)
        local secs = left % 60
        if mins > 0 then
            GameTooltip:AddLine(string.format("Searching — %dm %ds left. Click to stop.", mins, secs), 0.83, 0.65, 0.45)
        else
            GameTooltip:AddLine(string.format("Searching — %ds left. Click to stop.", secs), 0.83, 0.65, 0.45)
        end
    elseif sync and sync.CanResumeSeek and sync:CanResumeSeek() then
        local left = sync:GetSeekListenRemaining()
        GameTooltip:AddLine(string.format("Paused — %ds left on this ping. Click to resume.", left), 0.83, 0.75, 0.45)
    else
        local cooldown = sync and sync.GetSeekCooldownRemaining and sync:GetSeekCooldownRemaining() or 0
        if cooldown > 0 then
            GameTooltip:AddLine(string.format("New seek signal ready in %d s.", cooldown), 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine("Click to start searching.", 0.5, 0.9, 0.5)
        end
    end
    GameTooltip:AddLine("Right-click to clear camp markers from the map.", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end

function Map:GetVisibleCamps(mapId)
    local sync = SmoreSkills.Sync
    if sync and sync.mapPinsDismissed then
        return {}
    end
    if not SmoreSkills_ListVisibleCamps then
        return {}
    end
    return SmoreSkills_ListVisibleCamps(mapId)
end

function Map:StopTooltipTicker()
    if self.tooltipTicker and self.tooltipTicker.Cancel then
        self.tooltipTicker:Cancel()
    end
    self.tooltipTicker = nil
end

function Map:AnchorButton()
    if not self.button or not WorldMapFrame then
        return
    end
    local btn = self.button
    local canvas = GetMapCanvas()
    btn:SetParent(WorldMapFrame.ScrollContainer or WorldMapFrame)
    btn:SetFrameStrata("TOOLTIP")
    btn:ClearAllPoints()
    btn:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -MAP_OFFSET_X, MAP_OFFSET_Y)
    btn:Show()
end

function Map:PositionPin(pin, x, y)
    local canvas = GetMapCanvas()
    if not canvas or not pin then
        return
    end
    local w = canvas:GetWidth()
    local h = canvas:GetHeight()
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", canvas, "BOTTOMLEFT", (tonumber(x) or 0) * w, (tonumber(y) or 0) * h)
end

function Map:CreatePinFrame()
    local canvas = GetMapCanvas()
    local pin = CreateFrame("Button", nil, canvas)
    pin:SetSize(PIN_HIT_SIZE, PIN_HIT_SIZE)
    pin:SetFrameLevel(PIN_FRAME_LEVEL)

    -- Anchor marks the exact campsite coordinate on the map.
    local anchor = CreateFrame("Frame", nil, pin)
    anchor:SetSize(1, 1)
    anchor:SetPoint("CENTER")
    pin.anchor = anchor

    local fireFrame = CreateFrame("Frame", nil, pin)
    fireFrame:SetSize(QUESTIE.btn * FIRE_SCALE, QUESTIE.btn * FIRE_SCALE)
    fireFrame:SetPoint("CENTER", anchor, "CENTER")
    pin.fireFrame = fireFrame
    pin.fireBg, pin.fireIcon, pin.fireRing = ApplyQuestieCluster(fireFrame, FIRE_SCALE, ICON)

    pin:SetScript("OnEnter", function(self)
        ShowPinTooltip(self)
    end)
    pin:SetScript("OnLeave", function()
        HideCampTooltip()
        GameTooltip:Hide()
    end)
    return pin
end

function Map:AcquirePin()
    local pin = table.remove(self.pinPool)
    if not pin then
        pin = self:CreatePinFrame()
    end
    pin:Show()
    return pin
end

function Map:ReleasePins()
    for id, pin in pairs(self.pins) do
        pin:Hide()
        pin.camp = nil
        pin.campId = nil
        table.insert(self.pinPool, pin)
        self.pins[id] = nil
    end
end

function Map:RefreshPins()
    if not WorldMapFrame or not WorldMapFrame.IsShown or not WorldMapFrame:IsShown() then
        return
    end
    local mapId = GetViewMapId()
    if not mapId or not SmoreSkills_ListVisibleCamps then
        self:ReleasePins()
        return
    end
    local camps = self:GetVisibleCamps(mapId)
    local wanted = {}
    for _, camp in ipairs(camps) do
        if camp.id and camp.x and camp.y then
            wanted[camp.id] = camp
        end
    end
    for id, pin in pairs(self.pins) do
        if not wanted[id] then
            pin:Hide()
            pin.camp = nil
            pin.campId = nil
            table.insert(self.pinPool, pin)
            self.pins[id] = nil
        end
    end
    for id, camp in pairs(wanted) do
        local pin = self.pins[id]
        if not pin then
            pin = self:AcquirePin()
            pin.campId = id
            self.pins[id] = pin
        end
        pin.camp = camp
        self:PositionPin(pin, camp.x, camp.y)
        pin:Show()
    end
end

function Map:HookMapChanges()
    if self.hooksInstalled then
        return
    end
    self.hooksInstalled = true

    if WorldMapFrame.HookScript then
        WorldMapFrame:HookScript("OnShow", function()
            Map:AnchorButton()
            Map:RefreshState()
            Map:RefreshPins()
        end)
        WorldMapFrame:HookScript("OnHide", function()
            Map:ReleasePins()
        end)
    end

    if hooksecurefunc and WorldMapFrame.OnMapChanged then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            Map:AnchorButton()
            C_Timer.After(0, function()
                Map:RefreshPins()
            end)
        end)
    end

    local canvas = GetMapCanvas()
    if canvas and canvas.HookScript then
        canvas:HookScript("OnSizeChanged", function()
            Map:RefreshPins()
        end)
    end

    local mm = WorldMapFrame.BorderFrame and WorldMapFrame.BorderFrame.MaximizeMinimizeFrame
    if mm then
        if mm.SetOnMinimizedCallback then
            mm:SetOnMinimizedCallback(function()
                C_Timer.After(0, function()
                    Map:AnchorButton()
                end)
            end)
        end
        if mm.SetOnMaximizedCallback then
            mm:SetOnMaximizedCallback(function()
                C_Timer.After(0, function()
                    Map:AnchorButton()
                end)
            end)
        end
    end
end

local function ResetSeekFadeCluster(icon, background, border, glow)
    if icon then
        icon:SetAlpha(1)
        icon:SetVertexColor(1, 1, 1)
    end
    if background then
        background:SetAlpha(1)
        background:SetVertexColor(1, 1, 1)
    end
    if border then
        border:SetAlpha(1)
        border:SetVertexColor(1, 1, 1)
    end
    if glow then
        glow:Hide()
        glow:SetAlpha(0)
    end
end

local function ApplySeekFadeCluster(icon, border, glow, phase)
    local alpha = FADE_MIN + (FADE_MAX - FADE_MIN) * phase
    if icon then
        icon:SetAlpha(alpha)
        icon:SetVertexColor(1, 0.65 + 0.3 * phase, 0.15 + 0.4 * phase)
    end
    if border then
        border:SetAlpha(0.8 + 0.2 * phase)
        border:SetVertexColor(1, 0.75 + 0.2 * phase, 0.2 + 0.15 * phase)
    end
    if glow then
        glow:Show()
        glow:SetAlpha(0.1 + 0.5 * phase)
    end
end

local function GetMinimapSeekVisuals()
    local settings = SmoreSkills.Settings
    if not settings or not settings.minimapIcon then
        return nil, nil, nil
    end
    return settings.minimapIcon, settings.minimapBorder, settings.minimapGlow
end

function Map:ResetVisuals()
    ResetSeekFadeCluster(self.icon, self.background, self.border, self.glow)
    local miniIcon, miniBorder, miniGlow = GetMinimapSeekVisuals()
    ResetSeekFadeCluster(miniIcon, nil, miniBorder, miniGlow)
end

function Map:StopSeekFade()
    if self.fadeFrame then
        self.fadeFrame:SetScript("OnUpdate", nil)
        self.fadeFrame:Hide()
    end
    self.fadeFrame = nil
    self:ResetVisuals()
end

function Map:FadeUpdate()
    if not self.icon and not GetMinimapSeekVisuals() then
        return
    end
    if not SmoreSkills.Sync or not SmoreSkills.Sync:IsSeeking() then
        self:StopSeekFade()
        return
    end
    local phase = (math.sin(GetTime() * (2 * math.pi / FADE_PERIOD)) + 1) / 2
    ApplySeekFadeCluster(self.icon, self.border, self.glow, phase)
    local miniIcon, miniBorder, miniGlow = GetMinimapSeekVisuals()
    ApplySeekFadeCluster(miniIcon, miniBorder, miniGlow, phase)
end

function Map:StartSeekFade()
    if self.fadeFrame then
        return
    end
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function()
        Map:FadeUpdate()
    end)
    self.fadeFrame = f
    self:FadeUpdate()
end

function Map:RefreshState()
    if not self.icon and not GetMinimapSeekVisuals() then
        return
    end
    local seeking = SmoreSkills.Sync and SmoreSkills.Sync:IsSeeking()
    if seeking then
        self:StartSeekFade()
    else
        self:StopSeekFade()
    end
end

function Map:CreateButton()
    local parent = WorldMapFrame.ScrollContainer or WorldMapFrame
    local btn = CreateFrame("Button", "SmoreSkillsMapFindButton", parent)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetFrameStrata("TOOLTIP")
    btn:SetFrameLevel(20)
    btn:EnableMouse(true)

    local background = btn:CreateTexture(nil, "BACKGROUND")
    background:SetSize(25, 25)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -4)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetTexture(ICON)
    icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 6, -5)
    AddCircleMask(btn, icon, 20)

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    if border.SetDrawLayer then
        border:SetDrawLayer("OVERLAY", 1)
    end

    local glow = btn:CreateTexture(nil, "OVERLAY")
    glow:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    glow:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Toggle")
    glow:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    glow:SetBlendMode("ADD")
    glow:Hide()

    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    btn:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            if SmoreSkills.Sync and SmoreSkills.Sync.DismissMapPins then
                SmoreSkills.Sync:DismissMapPins()
            end
            Map:RefreshState()
            if GameTooltip:IsOwned(btn) then
                Map:UpdateTooltip()
            end
            return
        end
        if SmoreSkills.Sync and SmoreSkills.Sync.SeekHere then
            SmoreSkills.Sync:SeekHere()
        end
        Map:RefreshState()
        if GameTooltip:IsOwned(btn) then
            Map:UpdateTooltip()
        end
    end)
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(btn, "ANCHOR_NONE")
        Map:UpdateTooltip()
        Map:StopTooltipTicker()
        if C_Timer and C_Timer.NewTicker then
            Map.tooltipTicker = C_Timer.NewTicker(0.25, function()
                if GameTooltip:IsOwned(btn) then
                    Map:UpdateTooltip()
                else
                    Map:StopTooltipTicker()
                end
            end)
        end
    end)
    btn:SetScript("OnLeave", function()
        Map:StopTooltipTicker()
        GameTooltip:Hide()
        Map:RefreshState()
    end)

    self.button = btn
    self.background = background
    self.icon = icon
    self.border = border
    self.glow = glow
end

function Map:Init()
    if self.button or not WorldMapFrame then
        return
    end
    self:CreateButton()
    self:HookMapChanges()
    self:AnchorButton()
    self:RefreshState()
end

function Map:TryInit()
    if self.button then
        Map:AnchorButton()
        return true
    end
    if not WorldMapFrame then
        return false
    end
    self:Init()
    return self.button ~= nil
end

function Map:EnsureInit()
    if self:TryInit() then
        return
    end
    if self.waitFrame then
        return
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(self)
        if SmoreSkills.Map:TryInit() then
            self:UnregisterAllEvents()
        end
    end)
    self.waitFrame = f
end
