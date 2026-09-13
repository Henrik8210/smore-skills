SmoreSkills = SmoreSkills or {}
SmoreSkills.Sync = SmoreSkills.Sync or {}

local Sync = SmoreSkills.Sync

-- New addon. One prefix. Do not reuse Guildie Crafts prefixes.
local PREFIX = "SmoreSk"
local MSG_CAMP = "C"
local MSG_ASK = "Q"
local ADDON_MSG_MAX = 250
local SHARE_COOLDOWN = 8

local lastShareAt = 0

local function EscapeField(value)
    value = tostring(value or "")
    value = value:gsub(":", ";")
    if value == "" then
        return "-"
    end
    return value
end

local function DecodeField(value)
    if not value or value == "" or value == "-" then
        return nil
    end
    return value:gsub(";", ":")
end

local function CoordWire(n)
    return string.format("%d", math.floor((tonumber(n) or 0) * 10000 + 0.5))
end

local function CoordFromWire(s)
    return (tonumber(s) or 0) / 10000
end

function Sync:Init()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(PREFIX)
    end
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:SetScript("OnEvent", function(_, _, prefix, text, _, sender)
        if prefix == PREFIX then
            self:OnMessage(text, sender)
        end
    end)
end

function Sync:OnLogin()
    -- Ask guild for live camps once. Do not dump everything we have first.
    local function ask()
        if IsInGuild() then
            self:Ask()
        end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(6, ask)
    else
        ask()
    end
end

function Sync:Send(msg)
    if not IsInGuild() then
        return false
    end
    if #msg > ADDON_MSG_MAX then
        return false
    end
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, "GUILD")
        return true
    end
    if SendAddonMessage then
        SendAddonMessage(PREFIX, msg, "GUILD")
        return true
    end
    return false
end

-- C:map:x:y:fac:own:p1:o1:p2:o2:p3:o3:t
function Sync:EncodeCamp(camp)
    if not camp then
        return nil
    end
    SmoreSkills_EnsureSlots(camp)
    local parts = {
        MSG_CAMP,
        tostring(camp.mapId or 0),
        CoordWire(camp.x),
        CoordWire(camp.y),
        EscapeField(camp.faction),
        EscapeField(camp.owner),
    }
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        local prof = slot and (SmoreSkills_ProfessionFromId(slot.profession) or SmoreSkills_ProfessionFromCode(slot.profession))
        table.insert(parts, EscapeField(prof and prof.code or nil))
        table.insert(parts, EscapeField(slot and slot.object or nil))
    end
    table.insert(parts, tostring(camp.updatedAt or SmoreSkills_Now()))
    return table.concat(parts, ":")
end

function Sync:DecodeCamp(text)
    local parts = { strsplit(":", text) }
    if parts[1] ~= MSG_CAMP then
        return nil
    end
    local camp = {
        mapId = tonumber(parts[2]),
        x = CoordFromWire(parts[3]),
        y = CoordFromWire(parts[4]),
        faction = DecodeField(parts[5]),
        owner = DecodeField(parts[6]),
        slots = {},
        updatedAt = tonumber(parts[13]) or SmoreSkills_Now(),
    }
    local idx = 7
    for i = 1, SmoreSkills.MAX_SLOTS do
        local code = DecodeField(parts[idx])
        local object = DecodeField(parts[idx + 1])
        local prof = SmoreSkills_ProfessionFromCode(code)
        camp.slots[i] = {
            index = i,
            profession = prof and prof.id or nil,
            object = object,
        }
        idx = idx + 2
    end
    camp.id = SmoreSkills_CampId(camp.mapId, camp.x, camp.y)
    return camp
end

function Sync:ShareCamp(camp)
    local msg = self:EncodeCamp(camp)
    if not msg then
        return false
    end
    return self:Send(msg)
end

function Sync:ShareHere()
    local camp, err = SmoreSkills_MarkHere()
    if not camp then
        SmoreSkills_Print(err)
        return
    end
    if self:ShareCamp(camp) then
        SmoreSkills_Print(string.format(
            "Shared camp in %s (%s) — %d/%d objects.",
            camp.zone or "?",
            SmoreSkills_FormatCoords(camp),
            SmoreSkills_CountFilledSlots(camp),
            SmoreSkills.MAX_SLOTS
        ))
    else
        SmoreSkills_Print("Could not send. Join a guild, or the ping was too long.")
    end
    if SmoreSkills.UI and SmoreSkills.UI.Refresh then
        SmoreSkills.UI:Refresh()
    end
end

function Sync:Ask()
    self:Send(MSG_ASK)
end

function Sync:ShareKnown(force)
    local now = SmoreSkills_Now()
    if not force and (now - lastShareAt) < SHARE_COOLDOWN then
        return
    end
    lastShareAt = now
    -- Only our faction. Newest first, cap so login does not freeze clients.
    local list = SmoreSkills_ListCamps(SmoreSkills_PlayerFaction())
    local sent = 0
    for _, camp in ipairs(list) do
        if sent >= 12 then
            break
        end
        if self:ShareCamp(camp) then
            sent = sent + 1
        end
    end
end

function Sync:OnMessage(text, sender)
    if not text or SmoreSkills_PlayerNamesMatch(sender, SmoreSkills_PlayerName()) then
        return
    end
    if text == MSG_ASK then
        self:ShareKnown()
        return
    end
    local camp = self:DecodeCamp(text)
    if not camp then
        return
    end
    if camp.faction and camp.faction ~= SmoreSkills_PlayerFaction() then
        return
    end
    SmoreSkills_UpsertCamp(camp)
    if SmoreSkills.UI and SmoreSkills.UI.Refresh then
        SmoreSkills.UI:Refresh()
    end
end
