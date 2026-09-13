SmoreSkills = SmoreSkills or {}
SmoreSkills.Sync = SmoreSkills.Sync or {}

local Sync = SmoreSkills.Sync

-- Community channel: anyone with the addon. Not guild chat.
local PREFIX = "SmoreSk"
local CHANNEL_NAME = "SmoreSkills"
local MSG_CAMP = "C"
local MSG_SEEK = "S"
local MSG_HOST = "H"
local ADDON_MSG_MAX = 250
local OUTBOUND_COOLDOWN = 8
local SEEK_COOLDOWN = 45
local HOST_COOLDOWN = 90

local lastOutboundAt = 0
local lastSeekAt = 0
local channelId = 0

Sync.seekingActive = false
Sync.seekListenUntil = 0
Sync.hostingUntil = 0
Sync.hostTickHandle = nil
Sync.seekDiscoveredIds = Sync.seekDiscoveredIds or {}
Sync.mapPinsDismissed = false

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

local function HideChannelFromChat()
    local i = 1
    while _G["ChatFrame" .. i] do
        ChatFrame_RemoveChannel(_G["ChatFrame" .. i], CHANNEL_NAME)
        i = i + 1
    end
end

local function RefreshUI()
    if SmoreSkills.UI and SmoreSkills.UI.Refresh then
        SmoreSkills.UI:Refresh()
    end
    if SmoreSkills.Map then
        if SmoreSkills.Map.RefreshState then
            SmoreSkills.Map:RefreshState()
        end
        if SmoreSkills.Map.RefreshPins then
            SmoreSkills.Map:RefreshPins()
        end
    end
end

function Sync:IsSeeking()
    if not self.seekingActive then
        return false
    end
    if SmoreSkills_Now() >= (self.seekListenUntil or 0) then
        self.seekingActive = false
        return false
    end
    return true
end

function Sync:CanResumeSeek()
    if self.seekingActive then
        return false
    end
    return SmoreSkills_Now() < (self.seekListenUntil or 0)
end

function Sync:GetSeekListenRemaining()
    local left = (self.seekListenUntil or 0) - SmoreSkills_Now()
    if left <= 0 then
        return 0
    end
    return math.ceil(left)
end

function Sync:IsHosting()
    return SmoreSkills_Now() < (self.hostingUntil or 0)
end

function Sync:GetSeekCooldownRemaining()
    local remaining = SEEK_COOLDOWN - (SmoreSkills_Now() - lastSeekAt)
    if remaining <= 0 then
        return 0
    end
    return math.ceil(remaining)
end

function Sync:GetSeekingRemaining()
    if not self:IsSeeking() then
        return 0
    end
    return self:GetSeekListenRemaining()
end

function Sync:StopSeeking()
    self.seekingActive = false
    RefreshUI()
end

function Sync:DismissMapPins()
    self.mapPinsDismissed = true
    self.seekDiscoveredIds = {}
    self:StopSeeking()
    if SmoreSkills.Map and SmoreSkills.Map.ReleasePins then
        SmoreSkills.Map:ReleasePins()
    end
    RefreshUI()
    SmoreSkills_Print("Cleared camp markers from the map.")
end

function Sync:StartListening()
    self.seekingActive = true
    RefreshUI()
end

function Sync:RecordSeekDiscovery(camp)
    if not camp or not camp.id then
        return
    end
    self.seekDiscoveredIds = self.seekDiscoveredIds or {}
    self.seekDiscoveredIds[camp.id] = true
end

function Sync:RefreshChannelId()
    local id = GetChannelName(CHANNEL_NAME)
    if id and id > 0 then
        channelId = id
        HideChannelFromChat()
        return true
    end
    channelId = 0
    return false
end

function Sync:JoinCommunity()
    if self:RefreshChannelId() then
        return
    end
    JoinChannelByName(CHANNEL_NAME)
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            self:RefreshChannelId()
        end)
    end
end

function Sync:Init()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(PREFIX)
    end
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:RegisterEvent("CHANNEL_UI_UPDATE")
    frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_ADDON" then
            local prefix, text, _, sender = ...
            if prefix == PREFIX then
                self:OnMessage(text, sender)
            end
        else
            self:RefreshChannelId()
        end
    end)
end

function Sync:OnLogin()
    self:JoinCommunity()
end

function Sync:TryOutbound()
    local now = SmoreSkills_Now()
    if (now - lastOutboundAt) < OUTBOUND_COOLDOWN then
        return false, "Wait a moment before sending again."
    end
    lastOutboundAt = now
    return true
end

function Sync:Send(msg)
    if #msg > ADDON_MSG_MAX then
        return false
    end
    if not self:RefreshChannelId() then
        self:JoinCommunity()
        if not self:RefreshChannelId() then
            return false
        end
    end
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, "CHANNEL", channelId)
        return true
    end
    if SendAddonMessage then
        SendAddonMessage(PREFIX, msg, "CHANNEL", channelId)
        return true
    end
    return false
end

local function AppendSlotParts(parts, camp)
    SmoreSkills_EnsureSlots(camp)
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        local prof = slot and (SmoreSkills_ProfessionFromId(slot.profession) or SmoreSkills_ProfessionFromCode(slot.profession))
        table.insert(parts, EscapeField(prof and prof.code or nil))
        table.insert(parts, EscapeField(slot and slot.object or nil))
    end
end

local function DecodeSlotParts(parts, startIdx)
    local slots = {}
    local idx = startIdx
    for i = 1, SmoreSkills.MAX_SLOTS do
        local code = DecodeField(parts[idx])
        local object = DecodeField(parts[idx + 1])
        local prof = SmoreSkills_ProfessionFromCode(code)
        slots[i] = {
            index = i,
            profession = prof and prof.id or nil,
            object = object,
        }
        idx = idx + 2
    end
    return slots, idx
end

-- C:map:x:y:fac:own:p1:o1:p2:o2:p3:o3:t
function Sync:EncodeCamp(camp)
    if not camp then
        return nil
    end
    local parts = {
        MSG_CAMP,
        tostring(camp.mapId or 0),
        CoordWire(camp.x),
        CoordWire(camp.y),
        EscapeField(camp.faction),
        EscapeField(camp.owner),
    }
    AppendSlotParts(parts, camp)
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
        source = "share",
    }
    camp.slots, _ = DecodeSlotParts(parts, 7)
    camp.id = SmoreSkills_CampId(camp.mapId, camp.x, camp.y)
    return camp
end

-- S:map:fac:prof:t
function Sync:EncodeSeek(mapId, professionId)
    local prof = SmoreSkills_ProfessionFromId(professionId)
    local parts = {
        MSG_SEEK,
        tostring(mapId or 0),
        EscapeField(SmoreSkills_PlayerFaction()),
        EscapeField(prof and prof.code or nil),
        tostring(SmoreSkills_Now()),
    }
    return table.concat(parts, ":")
end

function Sync:DecodeSeek(text)
    local parts = { strsplit(":", text) }
    if parts[1] ~= MSG_SEEK then
        return nil
    end
    local code = DecodeField(parts[4])
    local prof = SmoreSkills_ProfessionFromCode(code)
    return {
        mapId = tonumber(parts[2]),
        faction = DecodeField(parts[3]),
        profession = prof and prof.id or nil,
        updatedAt = tonumber(parts[5]) or SmoreSkills_Now(),
    }
end

-- H:map:x:y:fac:own:want:p1:o1:p2:o2:p3:o3:t
function Sync:EncodeHost(camp)
    if not camp then
        return nil
    end
    local parts = {
        MSG_HOST,
        tostring(camp.mapId or 0),
        CoordWire(camp.x),
        CoordWire(camp.y),
        EscapeField(camp.faction),
        EscapeField(camp.owner),
        EscapeField(camp.want or "any"),
    }
    AppendSlotParts(parts, camp)
    table.insert(parts, tostring(camp.updatedAt or SmoreSkills_Now()))
    return table.concat(parts, ":")
end

function Sync:DecodeHost(text)
    local parts = { strsplit(":", text) }
    if parts[1] ~= MSG_HOST then
        return nil
    end
    local camp = {
        mapId = tonumber(parts[2]),
        x = CoordFromWire(parts[3]),
        y = CoordFromWire(parts[4]),
        faction = DecodeField(parts[5]),
        owner = DecodeField(parts[6]),
        want = DecodeField(parts[7]) or "any",
        slots = {},
        updatedAt = tonumber(parts[14]) or SmoreSkills_Now(),
        source = "host",
    }
    camp.slots, _ = DecodeSlotParts(parts, 8)
    camp.id = SmoreSkills_CampId(camp.mapId, camp.x, camp.y)
    return camp
end

function Sync:ApplyCamp(camp)
    if not camp then
        return
    end
    if camp.faction and camp.faction ~= SmoreSkills_PlayerFaction() then
        return
    end
    if not camp.zone and camp.mapId and C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(camp.mapId)
        if info and info.name then
            camp.zone = info.name
        end
    end
    SmoreSkills_UpsertCamp(camp)
end

function Sync:ShareCamp(camp)
    local msg = self:EncodeCamp(camp)
    if not msg then
        return false
    end
    return self:Send(msg)
end

function Sync:ShareHost(camp)
    camp.want = SmoreSkills_GetEffectiveHostWant()
    camp.updatedAt = SmoreSkills_Now()
    local msg = self:EncodeHost(camp)
    if not msg then
        return false
    end
    return self:Send(msg)
end

function Sync:ShareHere()
    local ok, err = self:TryOutbound()
    if not ok then
        SmoreSkills_Print(err)
        return
    end
    local camp, markErr = SmoreSkills_MarkHere()
    if not camp then
        SmoreSkills_Print(markErr)
        return
    end
    if self:ShareCamp(camp) then
        SmoreSkills_Print(string.format(
            "Shared location in %s (%s) — %d/%d objects.",
            camp.zone or "?",
            SmoreSkills_FormatCoords(camp),
            SmoreSkills_CountFilledSlots(camp),
            SmoreSkills.MAX_SLOTS
        ))
    else
        SmoreSkills_Print("Could not share. Wait for the community channel, or the ping was too long.")
    end
    RefreshUI()
end

function Sync:SeekHere()
    if self:IsSeeking() then
        self:StopSeeking()
        SmoreSkills_Print("Stopped looking for camps.")
        return
    end

    local mapId, _, _, zone = SmoreSkills_GetPlayerMapPos()
    if not mapId then
        SmoreSkills_Print("No map coordinates (leave an instance or wait for the map).")
        return
    end
    local profession = SmoreSkills_GetPlayerProfession()
    if not profession then
        SmoreSkills_Print("Set your profession first: /smores prof lw (or bs, tail, …).")
        return
    end

    if self:CanResumeSeek() then
        self.mapPinsDismissed = false
        self:StartListening()
        if SmoreSkills_SeedTestCamp then
            local testCamp = SmoreSkills_SeedTestCamp(mapId, zone)
            if testCamp and SmoreSkills_CampVisibleToSeeker(testCamp, mapId, profession) then
                self:RecordSeekDiscovery(testCamp)
            end
        end
        SmoreSkills_Print(string.format(
            "Resumed looking for camps in %s (%d s left on this ping).",
            zone or "?",
            self:GetSeekListenRemaining()
        ))
        RefreshUI()
        return
    end

    local cooldown = self:GetSeekCooldownRemaining()
    if cooldown > 0 then
        SmoreSkills_Print(string.format("Wait %d s before sending a new seek signal.", cooldown))
        return
    end

    local now = SmoreSkills_Now()
    local ok, err = self:TryOutbound()
    if not ok then
        SmoreSkills_Print(err)
        return
    end
    local msg = self:EncodeSeek(mapId, profession)
    if not self:Send(msg) then
        SmoreSkills_Print("Could not send seek signal. Wait for the community channel.")
        return
    end
    lastSeekAt = now
    self.seekListenUntil = now + SmoreSkills.SIGNAL_TTL
    self.mapPinsDismissed = false
    self:StartListening()

    if SmoreSkills_SeedTestCamp then
        local testCamp = SmoreSkills_SeedTestCamp(mapId, zone)
        if testCamp and SmoreSkills_CampVisibleToSeeker(testCamp, mapId, profession) then
            self:RecordSeekDiscovery(testCamp)
        end
    end

    local matches = SmoreSkills_ListMatchedCamps(mapId, profession)
    for _, camp in ipairs(matches) do
        self:RecordSeekDiscovery(camp)
    end
    local visible = SmoreSkills_ListVisibleCamps and SmoreSkills_ListVisibleCamps(mapId) or matches
    SmoreSkills_Print(string.format(
        "Looking for camps in %s as %s — %d match(es) right now.",
        zone or "?",
        SmoreSkills_ProfessionLabel(profession),
        #visible
    ))
    RefreshUI()
end

function Sync:StopHosting()
    self.hostingUntil = 0
    if self.hostTickHandle and C_Timer and C_Timer.CancelTimer then
        C_Timer.CancelTimer(self.hostTickHandle)
    end
    self.hostTickHandle = nil
end

function Sync:HostHeartbeat()
    if not self:IsHosting() then
        self:StopHosting()
        return
    end
    local camp = SmoreSkills_GetLocalCamp()
    if not camp then
        self:StopHosting()
        return
    end
    camp.want = SmoreSkills_GetEffectiveHostWant()
    self:ShareHost(camp)
    self.hostTickHandle = C_Timer and C_Timer.After(HOST_COOLDOWN, function()
        self:HostHeartbeat()
    end)
end

function Sync:HostHere()
    local camp, err = SmoreSkills_MarkHere()
    if not camp then
        SmoreSkills_Print(err)
        return
    end
    if SmoreSkills_CountEmptySlots(camp) < 1 then
        SmoreSkills_Print("All three slots are full on this camp.")
        return
    end
    local ok, outboundErr = self:TryOutbound()
    if not ok then
        SmoreSkills_Print(outboundErr)
        return
    end
    camp.want = SmoreSkills_GetEffectiveHostWant()
    if not self:ShareHost(camp) then
        SmoreSkills_Print("Could not host. Wait for the community channel.")
        return
    end
    if self.hostTickHandle and C_Timer and C_Timer.CancelTimer then
        C_Timer.CancelTimer(self.hostTickHandle)
    end
    self.hostTickHandle = nil
    self.hostingUntil = SmoreSkills_Now() + SmoreSkills.SIGNAL_TTL
    if C_Timer and C_Timer.After then
        self.hostTickHandle = C_Timer.After(HOST_COOLDOWN, function()
            self:HostHeartbeat()
        end)
    end
    SmoreSkills_Print(string.format(
        "Hosting in %s (%s) — %d/%d objects, want: %s. Re-broadcasts for %d min.",
        camp.zone or "?",
        SmoreSkills_FormatCoords(camp),
        SmoreSkills_CountFilledSlots(camp),
        SmoreSkills.MAX_SLOTS,
        SmoreSkills_FormatWant(camp.want),
        math.floor(SmoreSkills.SIGNAL_TTL / 60)
    ))
    RefreshUI()
end

function Sync:OnMessage(text, sender)
    if not text or SmoreSkills_PlayerNamesMatch(sender, SmoreSkills_PlayerName()) then
        return
    end
    local msgType = strsub(text, 1, 1)
    if msgType == MSG_CAMP then
        local camp = self:DecodeCamp(text)
        if camp then
            self:ApplyCamp(camp)
            RefreshUI()
        end
    elseif msgType == MSG_HOST then
        local camp = self:DecodeHost(text)
        if not camp then
            return
        end
        self:ApplyCamp(camp)
        if self:IsSeeking() then
            local mapId = select(1, SmoreSkills_GetPlayerMapPos())
            local profession = SmoreSkills_GetPlayerProfession()
            if mapId and SmoreSkills_CampVisibleToSeeker(camp, mapId, profession) then
                self:RecordSeekDiscovery(camp)
                SmoreSkills_Print(string.format(
                    "Camp found: %s (%s) — %s",
                    camp.zone or "?",
                    SmoreSkills_FormatCoords(camp),
                    SmoreSkills_FormatSlots(camp)
                ))
            end
        end
        RefreshUI()
    elseif msgType == MSG_SEEK then
        -- Hosts rebroadcast when someone is seeking in-zone (light nudge, not auto-spam).
        local seek = self:DecodeSeek(text)
        if not seek or seek.faction ~= SmoreSkills_PlayerFaction() then
            return
        end
        if not self:IsHosting() then
            return
        end
        local camp = SmoreSkills_GetLocalCamp()
        if not camp or camp.mapId ~= seek.mapId then
            return
        end
        if not SmoreSkills_HostMatchesSeeker(camp, seek.mapId, seek.profession) then
            return
        end
        local ok = self:TryOutbound()
        if ok then
            camp.want = SmoreSkills_GetEffectiveHostWant()
            self:ShareHost(camp)
        end
    end
end
