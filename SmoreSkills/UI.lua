SmoreSkills = SmoreSkills or {}
SmoreSkills.UI = SmoreSkills.UI or {}

local UI = SmoreSkills.UI
local FRAME_WIDTH = 420
local FRAME_HEIGHT = 380

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

    local hereBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    hereBtn:SetSize(110, 22)
    hereBtn:SetPoint("TOPLEFT", 16, -42)
    hereBtn:SetText("Share here")
    hereBtn:SetScript("OnClick", function()
        SmoreSkills.Sync:ShareHere()
    end)

    local askBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    askBtn:SetSize(90, 22)
    askBtn:SetPoint("LEFT", hereBtn, "RIGHT", 8, 0)
    askBtn:SetText("Ask guild")
    askBtn:SetScript("OnClick", function()
        if not IsInGuild() then
            SmoreSkills_Print("You are not in a guild.")
            return
        end
        SmoreSkills.Sync:Ask()
        SmoreSkills_Print("Asked the guild for camps they have.")
    end)

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 18, -70)
    hint:SetPoint("RIGHT", -18, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText("Same-faction camps. Three object slots per fire. Manual share until we can read campfires.")

    local scroll = CreateFrame("ScrollFrame", "SmoreSkillsScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -96)
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

function UI:Refresh()
    if not self.frame then
        return
    end
    SmoreSkills_ForgetStaleCamps()
    local camps = SmoreSkills_ListCamps(SmoreSkills_PlayerFaction())
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
        row.name:SetText(string.format(
            "%s  %s   %d/%d   %s",
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
        end
        self.empty:SetText("No camps yet. Stand at a fire and click Share here.")
        self.empty:Show()
    elseif self.empty then
        self.empty:Hide()
    end
end
