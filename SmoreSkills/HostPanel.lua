SmoreSkills = SmoreSkills or {}
SmoreSkills.HostPanel = SmoreSkills.HostPanel or {}

local HostPanel = SmoreSkills.HostPanel
local ICON = SmoreSkills.ICON or "Interface\\Icons\\Spell_Fire_Fire"
local PANEL_BG = "Interface\\FrameGeneral\\UI-Background-Rock"
local PANEL_EDGE = "Interface\\DialogFrame\\UI-DialogBox-Border"
local CIRCLE_BG = "Interface\\Minimap\\UI-Minimap-Background"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local PANEL_W = 340
local SOCKET_SIZE = 32 * 1.5 * 2 * 0.8
local SOCKET_GAP = 6
local CHIP_H = 20
local MENU_MAX_H = 272
local MENU_SCROLL_W = 10
local SOCKET_GOLD = { 0.92, 0.78, 0.28 }
local TITLE_YELLOW = { 1, 0.82, 0.15 }
local SELECTED_FILL = { 0.42, 0.32, 0.12, 0.95 }
local HOVER_FILL = { 0.42, 0.32, 0.12, 0.40 }
local IDLE_FILL = { 0.10, 0.08, 0.06, 0.90 }
local IDLE_TEXT = { 0.72, 0.72, 0.72 }
local HOVER_TEXT = { 0.90, 0.78, 0.38 }
local PACK_IDLE = { 0.38, 0.16, 0.10, 0.95 }
local PACK_HOVER = { 0.48, 0.26, 0.10, 0.95 }
local SOCKET_GLOW_MIN = 0.16
local SOCKET_GLOW_MAX = 0.34
local SOCKET_PULSE_SPEED = 1.8

local function SetColor(tex, c)
    if tex and c then
        tex:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
    end
end

local function SetTextColor(fs, c)
    if fs and c then
        fs:SetTextColor(c[1], c[2], c[3])
    end
end

local function SafeDesaturate(texture, desaturated)
    if not texture then
        return
    end
    if texture.SetDesaturated then
        texture:SetDesaturated(desaturated)
    elseif texture.SetVertexColor then
        texture:SetVertexColor(desaturated and 0.55 or 1, desaturated and 0.55 or 1, desaturated and 0.55 or 1)
    end
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

local function ApplyChrome(frame)
    if frame.solidFill then
        frame.solidFill:SetColorTexture(0.16, 0.13, 0.09, 0.97)
    else
        local fill = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
        fill:SetAllPoints()
        fill:SetColorTexture(0.16, 0.13, 0.09, 0.97)
        frame.solidFill = fill
    end
    if not frame.SetBackdrop then
        return
    end
    frame:SetBackdrop({
        bgFile = PANEL_BG,
        edgeFile = PANEL_EDGE,
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    frame:SetBackdropColor(0.24, 0.19, 0.14, 0.97)
    frame:SetBackdropBorderColor(0.48, 0.40, 0.30, 1)
end

local function CreateSocket(parent, size)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(size, size)
    local gold = btn:CreateTexture(nil, "BACKGROUND")
    gold:SetSize(size, size)
    gold:SetPoint("CENTER")
    gold:SetTexture(CIRCLE_BG)
    gold:SetVertexColor(SOCKET_GOLD[1], SOCKET_GOLD[2], SOCKET_GOLD[3], 1)
    btn.gold = gold
    local inner = size - 6
    local fill = btn:CreateTexture(nil, "ARTWORK", nil, -1)
    fill:SetSize(inner, inner)
    fill:SetPoint("CENTER")
    fill:SetTexture(CIRCLE_BG)
    fill:SetVertexColor(0.14, 0.11, 0.09, 1)
    btn.fill = fill
    local icon = btn:CreateTexture(nil, "ARTWORK", nil, 1)
    icon:SetSize(inner * 0.80, inner * 0.80)
    icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    AddCircleMask(btn, icon, inner * 0.80)
    btn.icon = icon
    local caption = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    caption:SetPoint("TOP", btn, "BOTTOM", 0, -3)
    caption:SetWidth(size + 8)
    caption:SetJustifyH("CENTER")
    if caption.SetWordWrap then
        caption:SetWordWrap(true)
    end
    caption:SetTextColor(0.75, 0.75, 0.75)
    btn.caption = caption
    local hover = btn:CreateTexture(nil, "OVERLAY", nil, 5)
    hover:SetSize(size, size)
    hover:SetPoint("CENTER")
    hover:SetTexture(CIRCLE_BG)
    hover:SetVertexColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3], 0.22)
    hover:Hide()
    btn.hover = hover
    return btn
end

local function ApplySocketHover(btn)
    if not btn then
        return
    end
    if btn.hover then
        if btn.hovered then
            btn.hover:Show()
        else
            btn.hover:Hide()
        end
    end
    if btn.gold then
        if btn.hovered then
            btn.gold:SetVertexColor(1.0, 0.86, 0.40, 1)
        else
            btn.gold:SetVertexColor(SOCKET_GOLD[1], SOCKET_GOLD[2], SOCKET_GOLD[3], 1)
        end
    end
end

local function StopSocketPulse(btn)
    if not btn then
        return
    end
    btn.needsPulse = false
    if btn.icon then
        if btn.icon.SetBlendMode then
            btn.icon:SetBlendMode("BLEND")
        end
        btn.icon:SetAlpha(1)
        btn.icon:SetVertexColor(1, 1, 1)
    end
    if btn.gold then
        btn.gold:SetAlpha(1)
        btn.gold:SetVertexColor(SOCKET_GOLD[1], SOCKET_GOLD[2], SOCKET_GOLD[3], 1)
    end
end

local function StyleSocket(btn, slot, isYours)
    local open = not (slot and slot.profession)
    if not open then
        StopSocketPulse(btn)
        btn.icon:SetTexture(SmoreSkills_SlotIcon(slot))
        SafeDesaturate(btn.icon, false)
        btn.icon:SetVertexColor(1, 1, 1)
        btn.icon:SetAlpha(1)
        if slot.object and slot.object ~= "" then
            btn.caption:SetText(slot.object)
        else
            btn.caption:SetText(isYours and "You" or SmoreSkills_ProfessionLabel(slot.profession))
        end
        btn.caption:SetTextColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3])
    else
        btn.needsPulse = true
        btn.icon:SetTexture(ICON)
        SafeDesaturate(btn.icon, true)
        btn.icon:SetVertexColor(0.72, 0.62, 0.32)
        btn.icon:SetAlpha(SOCKET_GLOW_MIN)
        btn.caption:SetText(isYours and "You" or "Open")
        btn.caption:SetTextColor(0.65, 0.65, 0.65)
    end
    ApplySocketHover(btn)
end

local function StyleChip(chip, selected)
    chip.selected = selected and true or false
    if chip.selected then
        SetColor(chip.bg, SELECTED_FILL)
        SetTextColor(chip.label, TITLE_YELLOW)
    elseif chip.hovered then
        SetColor(chip.bg, HOVER_FILL)
        SetTextColor(chip.label, HOVER_TEXT)
    else
        SetColor(chip.bg, IDLE_FILL)
        SetTextColor(chip.label, IDLE_TEXT)
    end
end

local function StyleDrop(drop, hovered)
    if not drop then
        return
    end
    if hovered then
        SetColor(drop.bg, HOVER_FILL)
        SetTextColor(drop.label, HOVER_TEXT)
    else
        SetColor(drop.bg, IDLE_FILL)
        SetTextColor(drop.label, IDLE_TEXT)
    end
end

local function PaintMenuLine(btn)
    if not btn then
        return
    end
    if btn.isTitle then
        if btn.hl then
            btn.hl:SetColorTexture(0, 0, 0, 0)
        end
        SetTextColor(btn.label, TITLE_YELLOW)
        return
    end
    if btn.selected then
        SetColor(btn.hl, SELECTED_FILL)
        SetTextColor(btn.label, TITLE_YELLOW)
    elseif btn.hovered then
        SetColor(btn.hl, HOVER_FILL)
        SetTextColor(btn.label, HOVER_TEXT)
    else
        SetColor(btn.hl, { IDLE_FILL[1], IDLE_FILL[2], IDLE_FILL[3], 0.35 })
        SetTextColor(btn.label, IDLE_TEXT)
    end
end

local function LayoutChipRow(chips, wrapWidth, anchor, relPoint)
    local x = 0
    local rowStart = nil
    local prev = nil
    local last = anchor
    for _, chip in ipairs(chips) do
        if chip:IsShown() then
            local w = chip:GetWidth()
            chip:ClearAllPoints()
            if not rowStart then
                chip:SetPoint("TOPLEFT", anchor, relPoint or "BOTTOMLEFT", 0, -8)
                rowStart = chip
                x = w + 6
            elseif x + w > wrapWidth then
                chip:SetPoint("TOPLEFT", rowStart, "BOTTOMLEFT", 0, -4)
                rowStart = chip
                x = w + 6
            else
                chip:SetPoint("LEFT", prev, "RIGHT", 6, 0)
                x = x + w + 6
            end
            prev = chip
            last = rowStart
        end
    end
    return last
end

local function ActiveCamp()
    return SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp() or nil
end

local function ContributionChoices()
    local learned = SmoreSkills_GetPlayerProfessions and SmoreSkills_GetPlayerProfessions() or {}
    if #learned == 0 then
        for _, row in ipairs(SmoreSkills.PROFESSIONS) do
            table.insert(learned, row.id)
        end
    end
    local seen = {}
    local list = { professions = {} }
    for _, id in ipairs(learned) do
        if not seen[id] then
            seen[id] = true
            table.insert(list.professions, id)
        end
    end
    return list
end

function HostPanel:HideMenu()
    if self.menu then
        if self.menu.scroll then
            self.menu.scroll:SetVerticalScroll(0)
        end
        if self.menu.bar then
            self.menu.bar:SetValue(0)
        end
        self.menu:Hide()
    end
    self.menuKind = nil
    self.socketMenuIndex = nil
end

function HostPanel:Hide()
    self:HideMenu()
    if self.frame then
        self.frame:Hide()
    end
end

function HostPanel:Dismiss()
    self.dismissed = true
    self:Hide()
end

function HostPanel:BuildMenu()
    if self.menu and self.menu.scroll then
        return self.menu
    end
    if self.menu then
        self.menu:Hide()
        self.menu = nil
    end
    local menu = CreateFrame("Frame", "SmoreSkillsHostSocketMenu", self.frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    menu:SetFrameStrata("HIGH")
    menu:SetFrameLevel((self.frame:GetFrameLevel() or 1) + 8)
    menu:SetWidth(260)
    menu:SetClampedToScreen(true)
    ApplyChrome(menu)
    menu:Hide()
    menu.buttons = {}

    local scroll = CreateFrame("ScrollFrame", nil, menu)
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -6, 6)
    scroll:EnableMouseWheel(true)
    menu.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(248)
    content:SetHeight(20)
    scroll:SetScrollChild(content)
    menu.content = content

    local bar = CreateFrame("Slider", nil, menu)
    bar:SetWidth(MENU_SCROLL_W)
    bar:SetOrientation("VERTICAL")
    bar:SetPoint("TOPRIGHT", -4, -14)
    bar:SetPoint("BOTTOMRIGHT", -4, 14)
    bar:SetMinMaxValues(0, 0)
    bar:SetValue(0)
    bar:SetValueStep(20)
    if bar.SetObeyStepOnDrag then
        bar:SetObeyStepOnDrag(true)
    end
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(0.10, 0.08, 0.06, 0.95)
    local thumb = bar:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(0.85, 0.72, 0.28, 0.95)
    thumb:SetSize(MENU_SCROLL_W - 2, 28)
    bar:SetThumbTexture(thumb)
    bar:Hide()
    menu.bar = bar

    local function wheel(_, delta)
        local cur = scroll:GetVerticalScroll() or 0
        local _, maxV = bar:GetMinMaxValues()
        maxV = maxV or 0
        local nextV = cur - (delta * 24)
        if nextV < 0 then
            nextV = 0
        elseif nextV > maxV then
            nextV = maxV
        end
        scroll:SetVerticalScroll(nextV)
        bar:SetValue(nextV)
    end
    menu:EnableMouseWheel(true)
    menu:SetScript("OnMouseWheel", wheel)
    scroll:SetScript("OnMouseWheel", wheel)
    bar:SetScript("OnValueChanged", function(_, value)
        if menu._syncingBar then
            return
        end
        scroll:SetVerticalScroll(value or 0)
    end)

    self.menu = menu
    return menu
end

function HostPanel:FinishMenuLayout(contentH)
    local menu = self.menu
    if not menu or not menu.scroll then
        return
    end
    local inner = math.max(contentH or 20, 20)
    menu.content:SetHeight(inner)
    local view = math.min(inner + 12, MENU_MAX_H)
    menu:SetHeight(view)
    local needBar = inner + 12 > MENU_MAX_H
    menu.bar:SetShown(needBar)
    if needBar then
        menu.scroll:SetPoint("BOTTOMRIGHT", -6 - MENU_SCROLL_W - 2, 6)
        menu.content:SetWidth((menu:GetWidth() or 260) - 22)
    else
        menu.scroll:SetPoint("BOTTOMRIGHT", -6, 6)
        menu.content:SetWidth((menu:GetWidth() or 260) - 12)
    end
    local scrollH = math.max(1, view - 12)
    local maxScroll = math.max(0, inner - scrollH)
    menu._syncingBar = true
    menu.bar:SetMinMaxValues(0, maxScroll)
    local keep = menu.scroll:GetVerticalScroll() or 0
    if keep > maxScroll then
        keep = maxScroll
    end
    menu.scroll:SetVerticalScroll(keep)
    menu.bar:SetValue(keep)
    menu._syncingBar = nil
    if menu.bar.GetThumbTexture then
        local thumb = menu.bar:GetThumbTexture()
        if thumb and maxScroll > 0 then
            local thumbH = math.max(18, scrollH * (scrollH / inner))
            thumb:SetSize(MENU_SCROLL_W - 2, thumbH)
        end
    end
end

function HostPanel:AnchorMenu(anchor)
    local menu = self.menu
    if not menu or not anchor then
        return
    end
    menu:SetParent(self.frame)
    menu:SetFrameStrata("HIGH")
    menu:SetFrameLevel((self.frame:GetFrameLevel() or 1) + 20)
    menu:ClearAllPoints()
    menu:SetWidth(260)
    menu:SetClampedToScreen(true)
    menu:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
    if anchor.GetWidth and (anchor:GetWidth() or 0) >= 200 then
        menu:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -2)
    end
end

function HostPanel:ResetMenuButtons()
    local menu = self:BuildMenu()
    for _, btn in ipairs(menu.buttons) do
        btn:Hide()
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        btn:SetScript("OnClick", nil)
        btn:EnableMouse(true)
        btn.hovered = nil
        btn.selected = nil
        btn.isTitle = nil
        btn.tipEnter = nil
        btn.tipLeave = nil
        if btn.hl then
            btn.hl:SetColorTexture(0, 0, 0, 0)
        end
        if btn.icon then
            btn.icon:Hide()
        end
    end
    return menu
end

function HostPanel:AddMenuLine(menu, y, text, onClick, isTitle, selected, iconPath)
    menu._lineIndex = (menu._lineIndex or 0) + 1
    local btn = menu.buttons[menu._lineIndex]
    if not btn then
        btn = CreateFrame("Button", nil, menu)
        btn:SetHeight(20)
        local hl = btn:CreateTexture(nil, "BACKGROUND")
        hl:SetAllPoints()
        hl:SetColorTexture(0, 0, 0, 0)
        btn.hl = hl
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetSize(16, 16)
        btn.icon:SetPoint("LEFT", 6, 0)
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.label:SetPoint("LEFT", 8, 0)
        btn.label:SetPoint("RIGHT", -8, 0)
        btn.label:SetJustifyH("LEFT")
        menu.buttons[menu._lineIndex] = btn
    end
    if menu.content then
        btn:SetParent(menu.content)
    end
    if not btn.hl then
        local hl = btn:CreateTexture(nil, "BACKGROUND")
        hl:SetAllPoints()
        hl:SetColorTexture(0, 0, 0, 0)
        btn.hl = hl
    end
    if not btn.icon then
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetSize(16, 16)
        btn.icon:SetPoint("LEFT", 6, 0)
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    btn:ClearAllPoints()
    local host = menu.content or menu
    btn:SetPoint("TOPLEFT", host, "TOPLEFT", 4, -y)
    btn:SetPoint("RIGHT", host, "RIGHT", -4, 0)
    if iconPath then
        btn.icon:SetTexture(iconPath)
        btn.icon:Show()
        btn.label:SetPoint("LEFT", 26, 0)
    else
        btn.icon:Hide()
        btn.label:SetPoint("LEFT", 8, 0)
    end
    btn.label:SetText(text)
    btn.hovered = false
    btn.selected = selected and true or false
    btn.isTitle = isTitle and true or false
    btn.tipEnter = nil
    btn.tipLeave = nil
    if isTitle then
        btn:EnableMouse(false)
        btn:SetScript("OnClick", nil)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        PaintMenuLine(btn)
    else
        btn:EnableMouse(true)
        PaintMenuLine(btn)
        btn:SetScript("OnClick", function()
            if onClick then
                onClick()
            end
        end)
        btn:SetScript("OnEnter", function()
            btn.hovered = true
            PaintMenuLine(btn)
            if btn.tipEnter then
                btn.tipEnter()
            end
        end)
        btn:SetScript("OnLeave", function()
            btn.hovered = false
            PaintMenuLine(btn)
            if btn.tipLeave then
                btn.tipLeave()
            end
        end)
    end
    btn:Show()
    return btn, y + 20
end

function HostPanel:ShowSocketMenu(index)
    local camp = ActiveCamp()
    if not camp then
        return
    end
    index = tonumber(index) or 1
    if self.menu and self.menu:IsShown() and self.menuKind == "socket" and self.socketMenuIndex == index then
        self:HideMenu()
        return
    end
    local menu = self:ResetMenuButtons()
    menu._lineIndex = 0
    self.menuKind = "socket"
    self.socketMenuIndex = index
    local y = 8
    local btn
    local function addObjectLine(picked)
        local label = picked.label
        if picked.note then
            label = label .. " — " .. picked.note
        end
        btn, y = self:AddMenuLine(menu, y, label, function()
            SmoreSkills_SetCampSlotDeclaration(camp, index, picked.profession, picked.id)
            SmoreSkills_ShareOwnedCampFromClick()
            HostPanel:HideMenu()
        end, false, false, SmoreSkills_CampingObjectIcon(picked))
        btn.tipEnter = function()
            if SmoreSkills_ShowCampingItemTooltip then
                SmoreSkills_ShowCampingItemTooltip(btn, picked, "ANCHOR_LEFT")
            end
        end
        btn.tipLeave = function()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end
    end
    if index > 1 then
        btn, y = self:AddMenuLine(menu, y, "Clear this socket", function()
            SmoreSkills_ClearCampSlotDeclaration(camp, index)
            SmoreSkills_ShareOwnedCampFromClick()
            HostPanel:HideMenu()
        end)
        y = y + 4
        btn, y = self:AddMenuLine(menu, y, "Profession", nil, true)
        for _, row in ipairs(SmoreSkills.PROFESSIONS) do
            local id = row.id
            btn, y = self:AddMenuLine(menu, y, row.label, function()
                SmoreSkills_SetCampSlotDeclaration(camp, index, id)
                SmoreSkills_ShareOwnedCampFromClick()
                HostPanel:HideMenu()
            end, false, false, SmoreSkills_ProfessionIcon(id))
        end
        y = y + 4
        btn, y = self:AddMenuLine(menu, y, "Camping object", nil, true)
        for _, row in ipairs(SmoreSkills.PROFESSIONS) do
            local items = SmoreSkills_ItemsForProfession(row.id)
            if #items > 0 then
                btn, y = self:AddMenuLine(menu, y, row.label, nil, true)
                for _, item in ipairs(items) do
                    addObjectLine(item)
                end
            end
        end
    else
        btn, y = self:AddMenuLine(menu, y, "Your profession", nil, true)
        local choices = ContributionChoices()
        for _, profId in ipairs(choices.professions) do
            local id = profId
            btn, y = self:AddMenuLine(menu, y, SmoreSkills_ProfessionLabel(id), function()
                SmoreSkills_SetCampSlotDeclaration(camp, 1, id)
                SmoreSkills_ShareOwnedCampFromClick()
                HostPanel:HideMenu()
            end, false, false, SmoreSkills_ProfessionIcon(id))
        end
        local learnedObjects = SmoreSkills_LearnedCampingItems and SmoreSkills_LearnedCampingItems() or {}
        if #learnedObjects > 0 then
            y = y + 4
            btn, y = self:AddMenuLine(menu, y, "Camping object", nil, true)
            for _, item in ipairs(learnedObjects) do
                addObjectLine(item)
            end
        end
    end
    self:FinishMenuLayout(y + 4)
    self:AnchorMenu(self.sockets[index] or self.sockets[1])
    menu:Show()
end

function HostPanel:ObjectDropLabel(camp)
    local text = SmoreSkills_FormatItems and SmoreSkills_FormatItems(camp and camp.wantItems)
    if not text or text == "" then
        return "Any camping object"
    end
    if #text > 42 then
        return strsub(text, 1, 39) .. "..."
    end
    return text
end

function HostPanel:ShowObjectMenu(refresh)
    if self._buildingObjectMenu then
        return
    end
    local camp = ActiveCamp()
    if not camp then
        return
    end
    if not refresh and self.menu and self.menu:IsShown() and self.menuKind == "objects" then
        self:HideMenu()
        return
    end
    self._buildingObjectMenu = true
    local menu = self:ResetMenuButtons()
    menu._lineIndex = 0
    self.menuKind = "objects"
    local y = 8
    local btn
    for _, row in ipairs(SmoreSkills.PROFESSIONS) do
        if SmoreSkills_CampWantHasProfession(camp, row.id) then
            local items = SmoreSkills_ItemsForProfession(row.id)
            if #items > 0 then
                y = y + 2
                btn, y = self:AddMenuLine(menu, y, row.label, nil, true)
                for _, item in ipairs(items) do
                    local picked = item
                    local selected = SmoreSkills_CampWantHasObject(camp, picked.id)
                    local label = picked.label
                    if picked.note then
                        label = label .. " — " .. picked.note
                    end
                    btn, y = self:AddMenuLine(menu, y, label, function()
                        if SmoreSkills_ToggleCampWantObject(camp, picked.id) then
                            SmoreSkills_ShareOwnedCampFromClick()
                            HostPanel:ShowObjectMenu(true)
                        end
                    end, false, selected, SmoreSkills_CampingObjectIcon(picked))
                    btn.tipEnter = function()
                        if SmoreSkills_ShowCampingItemTooltip then
                            SmoreSkills_ShowCampingItemTooltip(btn, picked, "ANCHOR_LEFT")
                        end
                    end
                    btn.tipLeave = function()
                        if GameTooltip then
                            GameTooltip:Hide()
                        end
                    end
                end
            end
        end
    end
    self:FinishMenuLayout(y + 4)
    self:AnchorMenu(self.objDrop)
    menu:Show()
    self._buildingObjectMenu = nil
end

function HostPanel:Build()
    if self.frame then
        return self.frame
    end
    local frame = CreateFrame("Frame", "SmoreSkillsHostPanel", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetSize(PANEL_W, 280)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, -90)
    frame:SetFrameStrata("HIGH")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(selfFrame)
        selfFrame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
    end)
    ApplyChrome(frame)
    frame:Hide()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText("Your camp")
    title:SetTextColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3])
    self.title = title

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
    close:SetScript("OnClick", function()
        HostPanel:Dismiss()
    end)

    local where = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    where:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    where:SetPoint("RIGHT", frame, "RIGHT", -14, 0)
    where:SetJustifyH("LEFT")
    where:SetTextColor(0.72, 0.72, 0.72)
    self.where = where

    local socketRow = CreateFrame("Frame", nil, frame)
    socketRow:SetPoint("TOPLEFT", where, "BOTTOMLEFT", 8, -16)
    socketRow:SetSize(SmoreSkills.MAX_SLOTS * SOCKET_SIZE + (SmoreSkills.MAX_SLOTS - 1) * SOCKET_GAP, SOCKET_SIZE + 28)
    self.socketRow = socketRow
    self.sockets = {}
    for i = 1, SmoreSkills.MAX_SLOTS do
        local socket = CreateSocket(socketRow, SOCKET_SIZE)
        socket:SetPoint("LEFT", socketRow, "LEFT", (i - 1) * (SOCKET_SIZE + SOCKET_GAP), 8)
        socket.index = i
        socket:EnableMouse(true)
        socket:SetScript("OnClick", function()
            HostPanel:ShowSocketMenu(i)
        end)
        socket:SetScript("OnEnter", function()
            socket.hovered = true
            ApplySocketHover(socket)
            GameTooltip:SetOwner(socket, "ANCHOR_CURSOR")
            if i == 1 then
                GameTooltip:AddLine("Your socket", 1, 0.82, 0)
                GameTooltip:AddLine("Click to set your profession or a camping object for this fire.", 1, 1, 1, true)
            else
                GameTooltip:AddLine("Guest socket", 1, 0.82, 0)
                GameTooltip:AddLine("Click to mark a profession or camping object here. We cannot see placed objects yet — this is what seekers see on the pin.", 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        socket:SetScript("OnLeave", function()
            socket.hovered = false
            ApplySocketHover(socket)
            GameTooltip:Hide()
        end)
        self.sockets[i] = socket
    end
    socketRow:SetScript("OnUpdate", function()
        local sockets = HostPanel.sockets
        if not sockets then
            return
        end
        local phase = 0.5 + 0.5 * math.sin((GetTime() or 0) * SOCKET_PULSE_SPEED)
        local glowA = SOCKET_GLOW_MIN + (SOCKET_GLOW_MAX - SOCKET_GLOW_MIN) * phase
        for i = 1, #sockets do
            local socket = sockets[i]
            if not socket then
                -- skip
            elseif socket.needsPulse then
                if socket.icon then
                    socket.icon:SetAlpha(glowA)
                end
            end
            ApplySocketHover(socket)
        end
    end)

    local look = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    look:SetPoint("TOPLEFT", socketRow, "BOTTOMLEFT", -8, -8)
    look:SetText("Looking for")
    look:SetTextColor(1, 1, 1)
    self.lookLabel = look

    local lookHint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lookHint:SetPoint("TOPLEFT", look, "BOTTOMLEFT", 0, -2)
    lookHint:SetPoint("RIGHT", frame, "RIGHT", -14, 0)
    lookHint:SetJustifyH("LEFT")
    lookHint:SetText("This camp only. Default settings stay the same until you edit them.")
    lookHint:SetTextColor(0.65, 0.65, 0.65)
    self.lookHint = lookHint

    self.anyoneChip = self:MakeChip(frame, "Anyone")
    self.anyoneChip:SetScript("OnClick", function()
        local camp = ActiveCamp()
        if not camp then
            return
        end
        SmoreSkills_SetCampWantAnyone(camp)
        SmoreSkills_ShareOwnedCampFromClick()
    end)

    self.profChips = {}
    for _, row in ipairs(SmoreSkills.PROFESSIONS) do
        local chip = self:MakeChip(frame, row.label)
        chip.profId = row.id
        chip:SetScript("OnClick", function()
            local camp = ActiveCamp()
            if not camp then
                return
            end
            SmoreSkills_ToggleCampWantProfession(camp, row.id)
            SmoreSkills_ShareOwnedCampFromClick()
        end)
        table.insert(self.profChips, chip)
    end

    local objTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    objTitle:SetText("Camping objects")
    objTitle:SetTextColor(1, 1, 1)
    self.objTitle = objTitle

    local objDrop = CreateFrame("Button", nil, frame)
    objDrop:SetHeight(22)
    local dropBg = objDrop:CreateTexture(nil, "BACKGROUND")
    dropBg:SetAllPoints()
    dropBg:SetColorTexture(0.10, 0.08, 0.06, 0.95)
    objDrop.bg = dropBg
    local dropLabel = objDrop:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dropLabel:SetPoint("LEFT", 8, 0)
    dropLabel:SetPoint("RIGHT", -8, 0)
    dropLabel:SetJustifyH("LEFT")
    dropLabel:SetText("Any camping object")
    objDrop.label = dropLabel
    objDrop:SetScript("OnClick", function()
        HostPanel:ShowObjectMenu()
    end)
    objDrop:SetScript("OnEnter", function()
        objDrop.hovered = true
        StyleDrop(objDrop, true)
    end)
    objDrop:SetScript("OnLeave", function()
        objDrop.hovered = false
        StyleDrop(objDrop, false)
    end)
    self.objDrop = objDrop

    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetJustifyH("LEFT")
    hint:SetJustifyV("TOP")
    if hint.SetWordWrap then
        hint:SetWordWrap(true)
    end
    if hint.SetNonSpaceWrap then
        hint:SetNonSpaceWrap(true)
    end
    hint:SetTextColor(TITLE_YELLOW[1], TITLE_YELLOW[2], TITLE_YELLOW[3])
    self.hint = hint

    local pack = CreateFrame("Button", nil, frame)
    pack:SetSize(96, 22)
    local packBg = pack:CreateTexture(nil, "BACKGROUND")
    packBg:SetAllPoints()
    packBg:SetColorTexture(PACK_IDLE[1], PACK_IDLE[2], PACK_IDLE[3], PACK_IDLE[4])
    pack.bg = packBg
    pack.label = pack:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pack.label:SetPoint("CENTER")
    pack.label:SetText("Pack up")
    pack.label:SetTextColor(1, 0.82, 0.15)
    pack:SetScript("OnClick", function()
        local camp = ActiveCamp()
        if not camp then
            return
        end
        if SmoreSkills.Map and SmoreSkills.Map.ConfirmPackUp then
            SmoreSkills.Map:ConfirmPackUp(camp)
        elseif SmoreSkills.Sync and SmoreSkills.Sync.PackUpCamp then
            SmoreSkills.Sync:PackUpCamp(camp)
        end
    end)
    pack:SetScript("OnEnter", function()
        SetColor(pack.bg, PACK_HOVER)
    end)
    pack:SetScript("OnLeave", function()
        SetColor(pack.bg, PACK_IDLE)
    end)
    self.packBtn = pack

    self.frame = frame
    return frame
end

function HostPanel:MakeChip(parent, text)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(CHIP_H)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.10, 0.08, 0.06, 0.90)
    btn.bg = bg
    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", 8, 0)
    label:SetPoint("RIGHT", -8, 0)
    label:SetText(text)
    btn.label = label
    btn:SetWidth(math.max(52, (label:GetStringWidth() or 40) + 16))
    btn:SetScript("OnEnter", function()
        btn.hovered = true
        StyleChip(btn, btn.selected)
    end)
    btn:SetScript("OnLeave", function()
        btn.hovered = false
        StyleChip(btn, btn.selected)
    end)
    return btn
end

function HostPanel:Refresh()
    if not self.frame or not self.frame:IsShown() then
        return
    end
    local camp = ActiveCamp()
    if not camp then
        self:Hide()
        return
    end
    self.where:SetText(string.format(
        "%s  %s  ·  %d/%d objects",
        camp.zone or "Camp",
        SmoreSkills_FormatCoords and SmoreSkills_FormatCoords(camp) or "",
        SmoreSkills_CountFilledSlots(camp),
        SmoreSkills.MAX_SLOTS
    ))
    SmoreSkills_EnsureSlots(camp)
    if SmoreSkills_ClampHostSlotToLearned then
        SmoreSkills_ClampHostSlotToLearned(camp)
    end
    for i = 1, SmoreSkills.MAX_SLOTS do
        StyleSocket(self.sockets[i], camp.slots[i], i == 1)
    end
    local want = SmoreSkills_SplitWantWire(camp.want or "any")
    local anyone = not want or want == "" or want == "any"
    StyleChip(self.anyoneChip, anyone)

    local wrapW = (self.frame:GetWidth() or PANEL_W) - 28
    local chips = { self.anyoneChip }
    self.anyoneChip:Show()
    for _, chip in ipairs(self.profChips) do
        chip:Show()
        StyleChip(chip, (not anyone) and SmoreSkills_CampWantHasProfession(camp, chip.profId))
        table.insert(chips, chip)
    end
    local last = LayoutChipRow(chips, wrapW, self.lookHint, "BOTTOMLEFT")

    local showObjects = not anyone and want ~= "none"
    self.objTitle:ClearAllPoints()
    self.objDrop:ClearAllPoints()
    self.objTitle:SetShown(showObjects)
    self.objDrop:SetShown(showObjects)
    if showObjects then
        self.objTitle:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -12)
        self.objDrop:SetPoint("TOPLEFT", self.objTitle, "BOTTOMLEFT", 0, -6)
        self.objDrop:SetPoint("RIGHT", self.frame, "RIGHT", -14, 0)
        self.objDrop.label:SetText(self:ObjectDropLabel(camp))
        StyleDrop(self.objDrop, self.objDrop.hovered)
        last = self.objDrop
        if self.menu and self.menu:IsShown() and self.menuKind == "objects" then
            self:ShowObjectMenu(true)
        end
    elseif self.menuKind == "objects" then
        self:HideMenu()
    end

    self.hint:ClearAllPoints()
    self.hint:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -10)
    self.hint:SetPoint("RIGHT", self.frame, "RIGHT", -14, 0)
    if SmoreSkills.Sync and SmoreSkills.Sync.needsHardwareShare then
        self.hint:SetText("Click Find or /smores host once so other campers can see this fire.")
    else
        self.hint:SetText("The pin tooltip uses these requests. Clicking a chip or object shares them.")
    end
    self.hint:Show()

    self.packBtn:ClearAllPoints()
    self.packBtn:SetPoint("TOPLEFT", self.hint, "BOTTOMLEFT", 0, -10)
    self.packBtn:Show()

    local top = self.frame:GetTop()
    local bot = self.packBtn:GetBottom()
    local h = 280
    if top and bot then
        h = math.max(240, top - bot + 18)
    end
    self.frame:SetHeight(h)
end

function HostPanel:ShowFor(camp)
    camp = camp or ActiveCamp()
    if not camp then
        return
    end
    self.dismissed = nil
    self:Build()
    self.frame:Show()
    self:HideMenu()
    self:Refresh()
end

function HostPanel:Toggle()
    local camp = ActiveCamp()
    if not camp then
        SmoreSkills_Reply("Host a camp first (place a Basic Campfire Kit or /smores host).")
        return
    end
    if self.frame and self.frame:IsShown() then
        self:Dismiss()
        return
    end
    self:ShowFor(camp)
end
