SmoreSkills = SmoreSkills or {}
SmoreSkills.UI = SmoreSkills.UI or {}

local UI = SmoreSkills.UI
local FRAME_WIDTH = 440
local FRAME_HEIGHT = 400

function UI:Init()
    if self.frame then
        return
    end
    local f = CreateFrame("Frame", "SmoreSkillsFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    f:Hide()
    tinsert(UISpecialFrames, "SmoreSkillsFrame")

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("S'more Skills")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local findBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    findBtn:SetSize(100, 22)
    findBtn:SetPoint("TOPLEFT", 16, -42)
    findBtn:SetText("Find camps")
    findBtn:SetScript("OnClick", function()
        SmoreSkills.Sync:SeekHere()
    end)

    local hostBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    hostBtn:SetSize(100, 22)
    hostBtn:SetPoint("LEFT", findBtn, "RIGHT", 6, 0)
    hostBtn:SetText("Host camp")
    hostBtn:SetScript("OnClick", function()
        SmoreSkills.Sync:HostHere(true)
    end)

    self.status = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.status:SetPoint("TOPLEFT", 18, -68)
    self.status:SetPoint("RIGHT", -18, 0)
    self.status:SetJustifyH("LEFT")

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 18, -84)
    hint:SetPoint("RIGHT", -18, 0)
    hint:SetJustifyH("LEFT")
        hint:SetText("/smores camp  ·  /smores prof lw  ·  /smores want any")

    local scroll = CreateFrame("ScrollFrame", "SmoreSkillsScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -102)
    scroll:SetPoint("BOTTOMRIGHT", -32, 16)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(FRAME_WIDTH - 56, 10)
    scroll:SetScrollChild(child)

    self.frame = f
    self.list = child
    self.rows = {}
end

function UI:Toggle()
    self:Init()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self:Refresh()
        self.frame:Show()
    end
end

function UI:GetVisibleCamps()
    SmoreSkills_ForgetStaleCamps()
    local mapId, _, _, zone = SmoreSkills_GetPlayerMapPos()
    local seeking = SmoreSkills.Sync:IsSeeking()
    return SmoreSkills_ListVisibleCamps(mapId), zone, seeking
end

function UI:Refresh()
    if not self.frame then
        return
    end
    local camps, zone, seeking = self:GetVisibleCamps()
    local prof = SmoreSkills_GetPlayerProfession()
    local statusParts = {}
    if seeking then
        table.insert(statusParts, "|cffd4a574Seeking|r in " .. (zone or "?"))
    elseif SmoreSkills.Sync:CanResumeSeek() then
        table.insert(statusParts, "|cffd4a574Paused seek|r in " .. (zone or "?"))
    elseif SmoreSkills.Sync:IsHosting() then
        table.insert(statusParts, "|cffd4a574Hosting|r in " .. (zone or "?"))
    else
        table.insert(statusParts, "Zone: " .. (zone or "?"))
    end
    if prof then
        table.insert(statusParts, SmoreSkills_ProfessionLabel(prof))
    else
        table.insert(statusParts, "|cffff6666set /smores prof|r")
    end
    self.status:SetText(table.concat(statusParts, "  ·  "))

    for _, row in ipairs(self.rows) do
        row:Hide()
    end
    local y = 0
    for i, camp in ipairs(camps) do
        local row = self.rows[i]
        if not row then
            row = CreateFrame("Frame", nil, self.list)
            row:SetSize(FRAME_WIDTH - 56, 44)
            row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            row.name:SetPoint("TOPLEFT", 0, 0)
            row.name:SetPoint("RIGHT", 0, 0)
            row.name:SetJustifyH("LEFT")
            row.slots = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.slots:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
            row.slots:SetPoint("RIGHT", 0, 0)
            row.slots:SetJustifyH("LEFT")
            self.rows[i] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -y)
        local filled = SmoreSkills_CountFilledSlots(camp)
        local guildMark = (SmoreSkills_ShowCampGuildMark and SmoreSkills_ShowCampGuildMark(camp)) and "|cff00ff00G|r  " or ""
        local sourceMark = camp.source == "host" and "|cff88ccffH|r " or ""
        row.name:SetText(string.format(
            "%s%s%s  %s   %d/%d   %s",
            sourceMark,
            guildMark,
            camp.zone or "?",
            SmoreSkills_FormatCoords(camp),
            filled,
            SmoreSkills.MAX_SLOTS,
            camp.owner or ""
        ))
        row.slots:SetText(SmoreSkills_FormatSlots(camp))
        row:Show()
        y = y + 48
    end
    self.list:SetHeight(math.max(10, y))
    if #camps == 0 then
        if not self.empty then
            self.empty = self.list:CreateFontString(nil, "OVERLAY", "GameFontDisable")
            self.empty:SetPoint("TOPLEFT", 0, 0)
            self.empty:SetWidth(FRAME_WIDTH - 56)
            self.empty:SetJustifyH("LEFT")
        end
        if seeking then
            self.empty:SetText("No matching camps in this zone. Hosts re-broadcast when you seek.")
        else
            self.empty:SetText("No camps in this zone. Find camps, or host at your fire.")
        end
        self.empty:Show()
    elseif self.empty then
        self.empty:Hide()
    end
end
