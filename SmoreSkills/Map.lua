SmoreSkills = SmoreSkills or {}
SmoreSkills.Map = SmoreSkills.Map or {}

local Map = SmoreSkills.Map
local ICON = SmoreSkills.ICON or "Interface\\Icons\\Spell_Fire_Fire"
local CAMP_PIN_ICON = "Interface\\Icons\\Spell_Fire_Fire"
-- QuestieWorldMapButtonTemplate layout (Questie/Modules/WorldMapButton).
local BUTTON_SIZE = 32
-- Inset from the map's bottom-right so we don't cover the Map & Quest Log hide tab.
local MAP_OFFSET_X = 38
local MAP_OFFSET_Y = 4
local FADE_PERIOD = 2.8
local FADE_MIN = 0.35
local FADE_MAX = 1.0
local FIRE_SCALE = 1.5
local SOCKET_TOOLTIP_SCALE = FIRE_SCALE * 2 * 0.8
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
local function GetFireScale()
    local pct = 100
    if SmoreSkills_GetPinScalePct then
        pct = SmoreSkills_GetPinScalePct()
    end
    return FIRE_SCALE * (pct / 100)
end

local function GetPinHitSize()
    return math.ceil(QUESTIE.btn * GetFireScale() + 8)
end

Map.pins = Map.pins or {}
Map.pinPool = Map.pinPool or {}

local function GetButtonHost()
    if WorldMapFrame and WorldMapFrame.ScrollContainer then
        return WorldMapFrame.ScrollContainer
    end
    return WorldMapFrame
end

local function ApplyPinStrata(pin)
    if not pin then
        return
    end
    -- Map tiles are mouse-transparent, so hover still works while the fire art
    -- sits under them. Draw the pin above the parchment on windowed and fullscreen.
    if not pcall(pin.SetFrameStrata, pin, "FULLSCREEN_DIALOG") then
        pin:SetFrameStrata("TOOLTIP")
    end
    if pin.SetFrameLevel then
        pin:SetFrameLevel(400)
    end
    if pin.SetToplevel then
        pin:SetToplevel(true)
    end
    if pin.fireFrame then
        if not pcall(pin.fireFrame.SetFrameStrata, pin.fireFrame, "FULLSCREEN_DIALOG") then
            pin.fireFrame:SetFrameStrata("TOOLTIP")
        end
        if pin.fireFrame.SetFrameLevel then
            pin.fireFrame:SetFrameLevel(401)
        end
    end
    if pin.fireIcon and pin.fireIcon.SetDrawLayer then
        pin.fireIcon:SetDrawLayer("OVERLAY", 6)
    end
    if pin.fireRing and pin.fireRing.SetDrawLayer then
        pin.fireRing:SetDrawLayer("OVERLAY", 7)
    end
end

local function ApplyOverlayStrata(frame, bump)
    if not frame then
        return
    end
    local parent = frame.GetParent and frame:GetParent()
    local strata = "HIGH"
    if parent and parent.GetFrameStrata then
        strata = parent:GetFrameStrata() or strata
    elseif WorldMapFrame and WorldMapFrame.GetFrameStrata then
        strata = WorldMapFrame:GetFrameStrata() or strata
    end
    frame:SetFrameStrata(strata)
    local level = bump or 80
    if parent and parent.GetFrameLevel then
        level = (parent:GetFrameLevel() or 1) + (bump or 80)
    end
    if frame.SetFrameLevel then
        frame:SetFrameLevel(math.min(level, 9000))
    end
end

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
    if not WorldMapFrame then
        return nil
    end
    if WorldMapFrame.GetMapID then
        local id = WorldMapFrame:GetMapID()
        if id then
            return id
        end
    end
    return WorldMapFrame.mapID
end

local function MapName(mapId)
    mapId = tonumber(mapId)
    if not mapId or not C_Map or not C_Map.GetMapInfo then
        return nil
    end
    local info = C_Map.GetMapInfo(mapId)
    return info and info.name or nil
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
    local mask = AddCircleMask(parent, icon, iconSize)

    local ring = parent:CreateTexture(nil, "OVERLAY")
    ring:SetSize(QUESTIE.border * clusterScale, QUESTIE.border * clusterScale)
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    if ring.SetDrawLayer then
        ring:SetDrawLayer("OVERLAY", 1)
    end

    return bg, icon, ring, mask
end

local function ResizeQuestieCluster(pin, clusterScale)
    local fireFrame = pin and pin.fireFrame
    if not fireFrame then
        return
    end
    fireFrame:SetSize(QUESTIE.btn * clusterScale, QUESTIE.btn * clusterScale)
    if pin.fireBg then
        pin.fireBg:SetSize(QUESTIE.bg * clusterScale, QUESTIE.bg * clusterScale)
        pin.fireBg:ClearAllPoints()
        pin.fireBg:SetPoint("TOPLEFT", fireFrame, "TOPLEFT", QUESTIE.bgX * clusterScale, QUESTIE.bgY * clusterScale)
    end
    local iconSize = QUESTIE.icon * clusterScale
    if pin.fireIcon then
        pin.fireIcon:SetSize(iconSize, iconSize)
        pin.fireIcon:ClearAllPoints()
        pin.fireIcon:SetPoint("TOPLEFT", fireFrame, "TOPLEFT", QUESTIE.iconX * clusterScale, QUESTIE.iconY * clusterScale)
    end
    if pin.fireMask then
        pin.fireMask:SetSize(iconSize, iconSize)
    end
    if pin.fireRing then
        pin.fireRing:SetSize(QUESTIE.border * clusterScale, QUESTIE.border * clusterScale)
        pin.fireRing:ClearAllPoints()
        pin.fireRing:SetPoint("TOPLEFT", fireFrame, "TOPLEFT", 0, 0)
    end
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

    local iconSize = innerSize * 0.80
    local icon = holder:CreateTexture(nil, "ARTWORK", nil, 1)
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    AddCircleMask(holder, icon, iconSize)
    holder.icon = icon

    return holder
end

local EMPTY_SOCKET_ICON = SmoreSkills.ICON or ICON
local EMPTY_SOCKET_ALPHA = 0.22

local function StyleTooltipSocket(holder, slot)
    holder.goldCircle:SetVertexColor(SOCKET_GOLD[1], SOCKET_GOLD[2], SOCKET_GOLD[3], 1)
    holder.fill:SetVertexColor(0.14, 0.11, 0.09, 1)
    holder.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    holder.icon:Show()
    if slot and slot.profession then
        holder.icon:SetTexture(SmoreSkills_SlotIcon(slot))
        SafeDesaturate(holder.icon, false)
        holder.icon:SetVertexColor(1, 1, 1)
        holder.icon:SetAlpha(1)
    else
        holder.icon:SetTexture(EMPTY_SOCKET_ICON)
        SafeDesaturate(holder.icon, true)
        holder.icon:SetVertexColor(0.65, 0.65, 0.65)
        holder.icon:SetAlpha(EMPTY_SOCKET_ALPHA)
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
    if Map.campTooltip and Map.campTooltip.tooltipVersion == 8 then
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

    local function MakeTipText(parent, template)
        local fs = parent:CreateFontString(nil, "OVERLAY", template)
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        if fs.SetWordWrap then
            fs:SetWordWrap(true)
        end
        if fs.SetNonSpaceWrap then
            fs:SetNonSpaceWrap(true)
        end
        return fs
    end

    tip.title = MakeTipText(tip, "GameFontNormal")
    tip.title:SetPoint("TOPLEFT", 12, -10)

    tip.coords = MakeTipText(tip, "GameFontHighlightSmall")
    tip.coords:SetPoint("TOPLEFT", tip.title, "BOTTOMLEFT", 0, -2)
    tip.coords:SetTextColor(0.7, 0.7, 0.7)

    tip.slotsLabel = MakeTipText(tip, "GameFontHighlightSmall")
    tip.slotsLabel:SetPoint("TOPLEFT", tip.coords, "BOTTOMLEFT", 0, -2)
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

    tip.footer = MakeTipText(tip, "GameFontHighlightSmall")
    tip.footer:SetPoint("TOPLEFT", socketRow, "BOTTOMLEFT", 4, -8)
    tip.footer:SetTextColor(1, 1, 1)

    tip.hint = MakeTipText(tip, "GameFontHighlightSmall")
    tip.hint:SetPoint("TOPLEFT", tip.footer, "BOTTOMLEFT", 0, -6)
    tip.hint:SetTextColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3])

    tip.tooltipVersion = 8
    Map.campTooltip = tip
    return tip
end

local function HideCampTooltip()
    if Map.campTooltip then
        Map.campTooltip:Hide()
    end
end

local function CampLayerTooltipText(camp)
    local own = camp and SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName())
    local layer = SmoreSkills_ResolveCampLayer and SmoreSkills_ResolveCampLayer(camp) or (camp and camp.layer)
    return SmoreSkills_FormatLayerCompare and SmoreSkills_FormatLayerCompare(layer, camp and camp.mapId, own, camp and camp.layerOrdinal)
end

local function ShowPinTooltipFallback(pin, camp)
    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    if GameTooltip.ClearLines then
        GameTooltip:ClearLines()
    end
    local filled = SmoreSkills_CountFilledSlots(camp)
    GameTooltip:SetText(camp.zone or "Camp", 1, 0.82, 0.45)
    if SmoreSkills_ShowCampGuildMark and SmoreSkills_ShowCampGuildMark(camp) then
        GameTooltip:AddLine("Guildie at this camp", 0, 1, 0)
    end
    GameTooltip:AddLine(SmoreSkills_FormatCoords(camp), 0.7, 0.7, 0.7)
    local layerText = CampLayerTooltipText(camp)
    if layerText then
        GameTooltip:AddLine(layerText, 1, 0.82, 0)
    end
    GameTooltip:AddLine(string.format("%d/%d slots filled", filled, SmoreSkills.MAX_SLOTS), 0.75, 0.75, 0.75)
    for i = 1, SmoreSkills.MAX_SLOTS do
        GameTooltip:AddLine(SmoreSkills_FormatSlotTooltipLine(camp, i), 0.92, 0.92, 0.92)
    end
        if camp.want and camp.want ~= "any" then
        local wantLines = {}
        SmoreSkills_AppendHostWantTooltipLines(wantLines, camp.want, camp.wantItems)
        for _, line in ipairs(wantLines) do
            GameTooltip:AddLine(line, 0.92, 0.92, 0.92)
        end
    end
    if SmoreSkills_IsTestCamp and SmoreSkills_IsTestCamp(camp) then
        GameTooltip:AddLine("Test camp (local preview)", 0.55, 0.55, 0.55)
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        GameTooltip:AddLine("Right-click to pack up this campsite.", 1, 0.82, 0)
    else
        GameTooltip:AddLine("Left-click to whisper the host for an invite.", 1, 0.82, 0)
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
        local zoneTitle = camp.zone or "Camp"
        if SmoreSkills_ShowCampGuildMark and SmoreSkills_ShowCampGuildMark(camp) then
            zoneTitle = zoneTitle .. "  |cff00ff00G|r"
        end
        tip.title:SetText(zoneTitle)
        tip.title:SetTextColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3])
        tip.coords:SetText(SmoreSkills_FormatCoords(camp))
        local layerText = CampLayerTooltipText(camp)
        if layerText then
            tip.coords:SetText(SmoreSkills_FormatCoords(camp) .. "  ·  " .. layerText)
        end
        tip.slotsLabel:SetText(string.format("%d/%d slots filled", filled, SmoreSkills.MAX_SLOTS))

        for i = 1, SmoreSkills.MAX_SLOTS do
            StyleTooltipSocket(tip.sockets[i], camp.slots[i])
        end

        local footerLines = {}
        for i = 1, SmoreSkills.MAX_SLOTS do
            table.insert(footerLines, SmoreSkills_FormatSlotTooltipLine(camp, i))
        end
        if camp.want and camp.want ~= "any" then
            SmoreSkills_AppendHostWantTooltipLines(footerLines, camp.want, camp.wantItems)
        end
        if SmoreSkills_IsTestCamp and SmoreSkills_IsTestCamp(camp) then
            table.insert(footerLines, "|cff888888Test camp (local preview)|r")
        end
        tip.footer:SetText(table.concat(footerLines, "\n"))
        if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
            tip.hint:SetText("Right-click to pack up this campsite.")
        else
            tip.hint:SetText("Left-click to whisper the host for an invite.")
        end
        tip.hint:Show()

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
        local innerW = math.max(260, (tip.socketRow:GetWidth() or 0) + 8)
        local tipW = innerW + 24
        tip:SetWidth(tipW)
        if tip.title.SetWidth then
            tip.title:SetWidth(innerW)
        end
        if tip.coords.SetWidth then
            tip.coords:SetWidth(innerW)
        end
        if tip.slotsLabel.SetWidth then
            tip.slotsLabel:SetWidth(innerW)
        end
        tip.footer:SetWidth(innerW)
        tip.hint:SetWidth(innerW)
        tip:SetHeight(400)
        tip:Show()
        local function lineH(fs)
            if not fs then
                return 0
            end
            return math.max(fs:GetStringHeight() or 0, 8)
        end
        local h = 10
            + lineH(tip.title) + 2
            + lineH(tip.coords) + 2
            + lineH(tip.slotsLabel) + 8
            + (tip.socketRow:GetHeight() or 0) + 8
            + lineH(tip.footer) + 6
            + lineH(tip.hint) + 14
        local top = tip.title:GetTop()
        local bottom = tip.hint:GetBottom()
        if top and bottom then
            h = math.max(h, (top - bottom) + 10 + 14)
        end
        tip:SetHeight(h)
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
    GameTooltip:AddLine("Right-click to clear other camp markers. Your own camp stays until the fire ends.", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end

function Map:GetVisibleCamps(mapId)
    local sync = SmoreSkills.Sync
    if not SmoreSkills_ListVisibleCamps then
        return {}
    end
    local camps = SmoreSkills_ListVisibleCamps(mapId)
    local seen = {}
    for _, camp in ipairs(camps) do
        if camp.id then
            seen[camp.id] = true
        end
    end
    local playerMapId = select(1, SmoreSkills_GetPlayerMapPos())
    if playerMapId and tonumber(playerMapId) ~= tonumber(mapId) then
        for _, camp in ipairs(SmoreSkills_ListVisibleCamps(playerMapId)) do
            if camp.id and not seen[camp.id] then
                table.insert(camps, camp)
                seen[camp.id] = true
            end
        end
    end
    if sync and sync.seekDiscoveredIds and SmoreSkillsDB.camps then
        local seekerProfession = SmoreSkills_CollectSeekerProfessions(SmoreSkills_GetPlayerProfession())
        for id in pairs(sync.seekDiscoveredIds) do
            local camp = SmoreSkillsDB.camps[id]
            if camp and camp.id and not seen[camp.id]
                and SmoreSkills_CampVisibleToSeeker(camp, camp.mapId, seekerProfession) then
                table.insert(camps, camp)
                seen[camp.id] = true
            end
        end
    end
    if not (sync and sync.mapPinsDismissed) then
        return camps
    end
    local mine = {}
    local me = SmoreSkills_PlayerName()
    for _, camp in ipairs(camps) do
        if SmoreSkills_PlayerNamesMatch(camp.owner, me) then
            table.insert(mine, camp)
        end
    end
    return mine
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
    local host = GetButtonHost()
    if not host then
        return
    end
    -- Host is the visible window (ScrollContainer), not the zoomable canvas.
    -- Anchoring to the canvas puts the button off-screen when ElvUI/Leatrix
    -- shrinks or zooms the map.
    btn:SetParent(host)
    ApplyOverlayStrata(btn, 80)
    btn:ClearAllPoints()
    btn:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -MAP_OFFSET_X, MAP_OFFSET_Y)
    if WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
        btn:Show()
    else
        btn:Hide()
    end
end

function Map:PositionPin(pin, x, y)
    local canvas = GetMapCanvas()
    if not canvas or not pin then
        return
    end
    if pin.GetParent and pin:GetParent() ~= canvas then
        pin:SetParent(canvas)
    end
    ApplyPinStrata(pin)
    local w = canvas:GetWidth()
    local h = canvas:GetHeight()
    if not w or w < 1 or not h or h < 1 then
        pin:Hide()
        return
    end
    pin:ClearAllPoints()
    -- C_Map y is 0 at the top of the map; canvas Y grows up from BOTTOMLEFT.
    pin:SetPoint("CENTER", canvas, "TOPLEFT", (tonumber(x) or 0) * w, -(tonumber(y) or 0) * h)
end

function Map:CreatePinFrame()
    local canvas = GetMapCanvas()
    local pin = CreateFrame("Button", nil, canvas)
    pin:SetSize(GetPinHitSize(), GetPinHitSize())
    ApplyPinStrata(pin)

    -- Anchor marks the exact campsite coordinate on the map.
    local anchor = CreateFrame("Frame", nil, pin)
    anchor:SetSize(1, 1)
    anchor:SetPoint("CENTER")
    pin.anchor = anchor

    local fireScale = GetFireScale()
    local fireFrame = CreateFrame("Frame", nil, pin)
    fireFrame:SetSize(QUESTIE.btn * fireScale, QUESTIE.btn * fireScale)
    fireFrame:SetPoint("CENTER", anchor, "CENTER")
    pin.fireFrame = fireFrame
    pin.fireBg, pin.fireIcon, pin.fireRing, pin.fireMask = ApplyQuestieCluster(fireFrame, fireScale, CAMP_PIN_ICON)
    local guildMark = pin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMark:SetPoint("BOTTOMRIGHT", fireFrame, "BOTTOMRIGHT", 4, -2)
    guildMark:SetText("|cff00ff00G|r")
    if guildMark.SetDrawLayer then
        guildMark:SetDrawLayer("OVERLAY", 7)
    end
    guildMark:Hide()
    pin.guildMark = guildMark
    if fireFrame.EnableMouse then
        fireFrame:EnableMouse(false)
    end
    pin:EnableMouse(true)

    local function OnOwnPinRightClick(self)
        local camp = self.camp
        if not camp or not SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
            return
        end
        HideCampTooltip()
        GameTooltip:Hide()
        Map:ConfirmPackUp(camp)
    end

    if pin.RegisterForClicks then
        pcall(function()
            pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        end)
    end
    pin:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
            OnOwnPinRightClick(self)
            return
        end
        if self.camp and SmoreSkills_PlayerNamesMatch(self.camp.owner, SmoreSkills_PlayerName()) then
            if SmoreSkills.HostPanel and SmoreSkills.HostPanel.ShowFor then
                SmoreSkills.HostPanel:ShowFor(self.camp)
            end
            return
        end
        Map:WhisperHost(self.camp)
    end)

    pin:SetScript("OnEnter", function(self)
        ShowPinTooltip(self)
    end)
    pin:SetScript("OnLeave", function()
        HideCampTooltip()
        GameTooltip:Hide()
    end)
    return pin
end

function Map:WhisperHost(camp)
    if not camp or not camp.owner or camp.owner == "" then
        return
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        return
    end
    local name = camp.owner
    if ChatFrame_SendTell then
        ChatFrame_SendTell(name)
    elseif ChatFrame_OpenChat then
        ChatFrame_OpenChat("/w " .. name .. " ")
    end
end

function Map:ConfirmPackUp(camp)
    if not camp then
        return
    end
    self.pendingPackCamp = camp
    local function DoPack(target)
        local toPack = target or Map.pendingPackCamp
        Map.pendingPackCamp = nil
        if toPack and SmoreSkills.Sync and SmoreSkills.Sync.PackUpCamp then
            SmoreSkills.Sync:PackUpCamp(toPack)
        end
    end
    if not StaticPopup_Show then
        DoPack(camp)
        return
    end
    if not StaticPopupDialogs then
        StaticPopupDialogs = {}
    end
    StaticPopupDialogs["SMORESKILLS_PACK_CAMP"] = {
        text = "Are you sure you wish to pack up your campsite? Other campers will not be able to find your campsite on the map if you do.",
        button1 = YES or "Yes",
        button2 = NO or "No",
        OnAccept = function(self, data)
            DoPack(data or (self and self.data) or Map.pendingPackCamp)
        end,
        OnCancel = function()
            Map.pendingPackCamp = nil
        end,
        OnShow = function(self)
            if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
                self:SetFrameStrata("TOOLTIP")
                local level = 10000
                if WorldMapFrame.GetFrameLevel then
                    level = WorldMapFrame:GetFrameLevel() + 500
                end
                self:SetFrameLevel(level)
            end
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }
    local popup = StaticPopup_Show("SMORESKILLS_PACK_CAMP")
    if popup then
        popup.data = camp
        if popup.SetFrameStrata then
            popup:SetFrameStrata("TOOLTIP")
        end
        if popup.SetFrameLevel then
            local level = 10000
            if WorldMapFrame and WorldMapFrame.GetFrameLevel then
                level = WorldMapFrame:GetFrameLevel() + 500
            end
            popup:SetFrameLevel(level)
        end
    end
end

function Map:ApplyPinScale(pin)
    if not pin then
        return
    end
    local scale = GetFireScale()
    pin:SetSize(GetPinHitSize(), GetPinHitSize())
    ApplyPinStrata(pin)
    ResizeQuestieCluster(pin, scale)
end

function Map:UpdatePinGuildMark(pin)
    if not pin or not pin.guildMark then
        return
    end
    local show = pin.camp and SmoreSkills_ShowCampGuildMark and SmoreSkills_ShowCampGuildMark(pin.camp)
    pin.guildMark:SetShown(show and true or false)
end

function Map:AcquirePin()
    local pin = table.remove(self.pinPool)
    if not pin then
        pin = self:CreatePinFrame()
    end
    self:ApplyPinScale(pin)
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

function Map:ShowPlayerZone(mapId)
    mapId = tonumber(mapId) or select(1, SmoreSkills_GetPlayerMapPos())
    if not mapId or not WorldMapFrame then
        return
    end
    if WorldMapFrame.SetMapID then
        WorldMapFrame:SetMapID(mapId)
    end
end

local function MaybeHintWrongMapZone(self, playerMapId, viewId)
    local sync = SmoreSkills.Sync
    if not sync or not sync.IsSeeking or not sync:IsSeeking() then
        return
    end
    if not playerMapId or not viewId or not SmoreSkills_ListVisibleCamps then
        return
    end
    local me = SmoreSkills_PlayerName and SmoreSkills_PlayerName()
    local zoneCamps = SmoreSkills_ListVisibleCamps(playerMapId)
    local foundOther = false
    if zoneCamps then
        for _, camp in ipairs(zoneCamps) do
            if camp and not SmoreSkills_PlayerNamesMatch(camp.owner, me) then
                foundOther = true
                break
            end
        end
    end
    if not foundOther then
        return
    end
    local now = (GetTime and GetTime()) or 0
    if self.wrongMapHintAt and (now - self.wrongMapHintAt) <= 15 then
        return
    end
    self.wrongMapHintAt = now
    SmoreSkills_Print(string.format(
        "Camp(s) are in %s — zoom the map to that zone (you are viewing %s).",
        MapName(playerMapId) or "your zone",
        MapName(viewId) or "another map"
    ))
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
    if SmoreSkills_MapViewShowsCampPins and not SmoreSkills_MapViewShowsCampPins(mapId) then
        self:ReleasePins()
        local playerMapId = select(1, SmoreSkills_GetPlayerMapPos())
        MaybeHintWrongMapZone(self, playerMapId, mapId)
        return
    end
    local camps = self:GetVisibleCamps(mapId)
    local wanted = {}
    local placed = 0
    local skippedWrongMap = 0
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
        self:ApplyPinScale(pin)
        self:UpdatePinGuildMark(pin)
        if pin.fireIcon then
            pin.fireIcon:SetTexture(CAMP_PIN_ICON)
        end
        local viewMapId = GetViewMapId()
        local px, py
        if SmoreSkills_CampPinPosOnMap then
            px, py = SmoreSkills_CampPinPosOnMap(camp, viewMapId)
        else
            px, py = camp.x, camp.y
        end
        if not px or not py then
            pin:Hide()
            skippedWrongMap = skippedWrongMap + 1
        else
            self:PositionPin(pin, px, py)
            pin:Show()
            placed = placed + 1
        end
    end
    if placed == 0 then
        local playerMapId = select(1, SmoreSkills_GetPlayerMapPos())
        local viewId = GetViewMapId()
        if playerMapId and viewId and playerMapId ~= viewId then
            MaybeHintWrongMapZone(self, playerMapId, viewId)
        end
    end
end

function Map:Relayout()
    self:AnchorButton()
    self:RefreshState()
    self:RefreshPins()
end

local function SafeHookScript(frame, script, handler)
    if not frame or not script or not handler or not frame.HookScript then
        return
    end
    if frame.HasScript and not frame:HasScript(script) then
        return
    end
    pcall(frame.HookScript, frame, script, handler)
end

function Map:HookMapChanges()
    if self.hooksInstalled then
        return
    end
    self.hooksInstalled = true

    local function RelayoutSoon()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                Map:Relayout()
            end)
            C_Timer.After(0.15, function()
                Map:Relayout()
            end)
        else
            Map:Relayout()
        end
    end

    SafeHookScript(WorldMapFrame, "OnShow", function()
        RelayoutSoon()
    end)
    SafeHookScript(WorldMapFrame, "OnHide", function()
        Map:ReleasePins()
        if Map.button then
            Map.button:Hide()
        end
    end)
    SafeHookScript(WorldMapFrame, "OnSizeChanged", function()
        Map:Relayout()
    end)

    if hooksecurefunc and WorldMapFrame.OnMapChanged then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            RelayoutSoon()
        end)
    end

    local host = GetButtonHost()
    if host and host ~= WorldMapFrame then
        SafeHookScript(host, "OnSizeChanged", function()
            Map:Relayout()
        end)
    end

    SafeHookScript(GetMapCanvas(), "OnSizeChanged", function()
        Map:RefreshPins()
    end)

    local mm = WorldMapFrame.BorderFrame and WorldMapFrame.BorderFrame.MaximizeMinimizeFrame
    if mm then
        -- Forever: this is a Frame with MinimizeButton / MaximizeButton children.
        -- Frames do not support OnClick — hooking it errors and aborts map init.
        if mm.SetOnMinimizedCallback then
            pcall(function()
                mm:SetOnMinimizedCallback(RelayoutSoon)
            end)
        end
        if mm.SetOnMaximizedCallback then
            pcall(function()
                mm:SetOnMaximizedCallback(RelayoutSoon)
            end)
        end
        SafeHookScript(mm.MinimizeButton, "OnClick", RelayoutSoon)
        SafeHookScript(mm.MaximizeButton, "OnClick", RelayoutSoon)
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

function Map:ResetVisuals()
    ResetSeekFadeCluster(self.icon, self.background, self.border, self.glow)
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
    if not self.icon then
        return
    end
    if not SmoreSkills.Sync or not SmoreSkills.Sync:IsSeeking() then
        self:StopSeekFade()
        return
    end
    local phase = (math.sin(GetTime() * (2 * math.pi / FADE_PERIOD)) + 1) / 2
    ApplySeekFadeCluster(self.icon, self.border, self.glow, phase)
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
    if not self.icon then
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
    local parent = GetButtonHost()
    local btn = CreateFrame("Button", "SmoreSkillsMapFindButton", parent)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    ApplyOverlayStrata(btn, 80)
    btn:EnableMouse(true)

    local background = btn:CreateTexture(nil, "BACKGROUND")
    background:SetSize(25, 25)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -4)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetTexture(ICON)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
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

function Map:StartPinWatch()
    if self.pinWatch then
        return
    end
    if not C_Timer or not C_Timer.NewTicker then
        return
    end
    self.pinWatch = C_Timer.NewTicker(5, function()
        if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
            Map:AnchorButton()
            Map:RefreshPins()
        end
    end)
end

function Map:Init()
    if self.button or not WorldMapFrame then
        return
    end
    self:CreateButton()
    self:HookMapChanges()
    self:StartPinWatch()
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
