SmoreSkills = SmoreSkills or {}
SmoreSkills.Sync = SmoreSkills.Sync or {}

local Sync = SmoreSkills.Sync

-- Community channel: anyone with the addon. Not guild chat.
local PREFIX = "SmoreSk"
local CHANNEL_NAME = "SmoreSkills"
local MSG_CAMP = "C"
local MSG_SEEK = "S"
local MSG_HOST = "H"
local MSG_PACK = "X"
local ADDON_MSG_MAX = 250
local OUTBOUND_COOLDOWN = 8
local SEEK_COOLDOWN = 45
local HOST_COOLDOWN = 90

local lastHandledAt = {}

local function ShouldHandleMessage(text, sender)
    local key = tostring(sender or "") .. "|" .. tostring(text or "")
    local now = (GetTime and GetTime()) or SmoreSkills_Now()
    local prev = lastHandledAt[key]
    if prev and (now - prev) < 2 then
        return false
    end
    lastHandledAt[key] = now
    return true
end

local lastOutboundAt = 0
local lastSeekAt = 0
local lastCampfireHostAt = 0
local lastSeekReplyPrintAt = 0
local placeBlockedUntil = 0
local channelId = 0
local joinAttempts = 0
local MAX_JOIN_ATTEMPTS = 8
local sendPump

-- Place a fire: TBC spell 818, Forever item Use of a Campfire Kit, or a
-- spell whose name contains campfire. Cooking Create of the kit is not a
-- place — even if the profession window closes before the craft lands.
-- Sitting at a fire is not a host.
local CAMPFIRE_SPELL_IDS = {
    [818] = true,
}
local craftCastGuids = {}
local professionCastFallbackUntil = 0

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

local pendingWhispers = {}
local pendingChannel = {}
local pendingCampfireAt = 0

-- Never call ChatFrame_RemoveChannel — that taints Blizzard chat and shows
-- "Interface action failed because of an AddOn". Hide our payloads with a filter.
-- Sync uses the named channel; we must not occupy /1 General, /2 Trade, /3 Local Defense.
local function InstallChatFilters()
    if not ChatFrame_AddMessageEventFilter then
        return
    end
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_, _, text)
        if type(text) == "string" and #text >= #PREFIX and text:sub(1, #PREFIX) == PREFIX then
            return true
        end
        return false
    end)
end

local function IsSmoreChannelName(name)
    return name and strlower(tostring(name)):find(strlower(CHANNEL_NAME), 1, true)
end

-- GetChannelName(n) is the roster the chat box uses ([3. General - Zephras Isle]).
-- GetChannelList can omit zone channels or use a shorter name.
local function EnumChatChannels()
    local out = {}
    local seen = {}
    local function add(id, name)
        id = tonumber(id)
        if not id or id < 1 or seen[id] or type(name) ~= "string" or name == "" then
            return
        end
        seen[id] = true
        out[#out + 1] = { id = id, name = name }
    end
    for i = 1, 20 do
        local id, name = GetChannelName(i)
        add(id, name)
    end
    if GetChannelList then
        local list = { GetChannelList() }
        for i = 1, #list, 3 do
            add(list[i], list[i + 1])
        end
    end
    return out
end

local function ZonePreferredSlot(name)
    name = strlower(tostring(name or ""))
    name = name:gsub("^%d+%.%s*", "")
    local head = strtrim(name:match("^(.-)%s+%-%s+") or name)
    local compact = head:gsub("%s+", "")
    local function compactLabel(label)
        if not label or label == "" then
            return nil
        end
        return strlower(tostring(label)):gsub("%s+", "")
    end
    if compact == "general" or compact == compactLabel(GENERAL) then
        return 1
    end
    if compact == "trade" or compact == compactLabel(TRADE) then
        return 2
    end
    if compact == "localdefense" or compact:find("localdefense", 1, true) or compact == compactLabel(LOCAL_DEFENSE) then
        return 3
    end
    return nil
end

-- Forever/Mainline: SwapChatChannelsByChannelIndex(id, id). Name-swap is optional.
local function SwapChannelSlots(a, b)
    a, b = tonumber(a), tonumber(b)
    if not a or not b or a == b or a < 1 or b < 1 then
        return false
    end
    local before = select(2, GetChannelName(a))
    if C_ChatInfo and C_ChatInfo.SwapChatChannelsByChannelIndex then
        local ok = pcall(C_ChatInfo.SwapChatChannelsByChannelIndex, a, b)
        if ok and select(2, GetChannelName(a)) ~= before then
            return true
        end
    end
    if C_ChatInfo and C_ChatInfo.SwapChatChannelsByChannelName then
        local _, nameA = GetChannelName(a)
        local _, nameB = GetChannelName(b)
        if nameA and nameB then
            local ok = pcall(C_ChatInfo.SwapChatChannelsByChannelName, nameA, nameB)
            if ok and select(2, GetChannelName(a)) ~= before then
                return true
            end
        end
    end
    return false
end

local function EditBoxAttr(editBox, key)
    if editBox.GetAttribute then
        return editBox:GetAttribute(key)
    end
    return editBox[key]
end

local function SetEditBoxAttr(editBox, key, value)
    if editBox.SetAttribute then
        editBox:SetAttribute(key, value)
    else
        editBox[key] = value
    end
end

local function EachChatEditBox(callback)
    local seen = {}
    local function visit(editBox)
        if editBox and not seen[editBox] then
            seen[editBox] = true
            callback(editBox)
        end
    end
    local n = NUM_CHAT_WINDOWS or 10
    for i = 1, n do
        local frame = _G["ChatFrame" .. i]
        visit(frame and frame.editBox)
    end
    visit(DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox)
    if ChatEdit_GetActiveWindow then
        visit(ChatEdit_GetActiveWindow())
    end
end

local function EditBoxTargetsSmore(editBox)
    if EditBoxAttr(editBox, "chatType") ~= "CHANNEL" then
        return false
    end
    local id = tonumber(EditBoxAttr(editBox, "channelTarget"))
    if not id then
        return false
    end
    local _, name = GetChannelName(id)
    return IsSmoreChannelName(name)
end

-- If the box is aimed at SmoreSkills, put it on /1 General when that slot is
-- General; otherwise SAY. Numbers can change under us after a swap.
local restoringEdit = false
local function RestoreChatEditIfOnSmoreChannel()
    if restoringEdit then
        return
    end
    restoringEdit = true
    EachChatEditBox(function(editBox)
        if not EditBoxTargetsSmore(editBox) then
            return
        end
        local id1, name1 = GetChannelName(1)
        if id1 and id1 > 0 and ZonePreferredSlot(name1) == 1 then
            SetEditBoxAttr(editBox, "chatType", "CHANNEL")
            SetEditBoxAttr(editBox, "channelTarget", "1")
        else
            SetEditBoxAttr(editBox, "chatType", "SAY")
            SetEditBoxAttr(editBox, "channelTarget", nil)
        end
        if ChatEdit_UpdateHeader then
            pcall(ChatEdit_UpdateHeader, editBox)
        end
    end)
    restoringEdit = false
end

local function ChannelNamed(kind)
    for _, ch in ipairs(EnumChatChannels()) do
        if ZonePreferredSlot(ch.name) == kind then
            return ch
        end
    end
    return nil
end

-- Give General / Trade / Local Defense /1 /2 /3 back. Sending uses GetChannelName
-- after this, so sync still works at whatever number we land on.
local function YieldZoneChatSlots()
    Sync:RefreshChannelId()
    local swaps = 0
    while channelId > 0 and channelId <= 3 and swaps < 5 do
        local partner = ChannelNamed(channelId)
        if (not partner or partner.id == channelId) then
            partner = nil
            for _, ch in ipairs(EnumChatChannels()) do
                if ch.id > 3 and not IsSmoreChannelName(ch.name) then
                    if not partner or ch.id > partner.id then
                        partner = ch
                    end
                end
            end
        end
        if not partner or not SwapChannelSlots(channelId, partner.id) then
            break
        end
        swaps = swaps + 1
        Sync:RefreshChannelId()
    end
    RestoreChatEditIfOnSmoreChannel()
end

local function ScheduleYieldZoneChatSlots()
    YieldZoneChatSlots()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, YieldZoneChatSlots)
        C_Timer.After(0.2, YieldZoneChatSlots)
        C_Timer.After(1, YieldZoneChatSlots)
    end
end

local function InstallChatEditGuard()
    if Sync._chatEditGuarded then
        return
    end
    Sync._chatEditGuarded = true
    if hooksecurefunc and ChatEdit_UpdateHeader then
        hooksecurefunc("ChatEdit_UpdateHeader", function()
            RestoreChatEditIfOnSmoreChannel()
        end)
    end
    EachChatEditBox(function(editBox)
        if editBox.HookScript then
            editBox:HookScript("OnShow", RestoreChatEditIfOnSmoreChannel)
        end
    end)
end

-- Temporary join, no chat window. JoinPermanentChannel stickies in chat-config
-- and can become /1 on the next login before General exists.
local function JoinHiddenChannel()
    if JoinChannelByName then
        local ok, id = pcall(JoinChannelByName, CHANNEL_NAME)
        if ok and tonumber(id) and tonumber(id) > 0 then
            channelId = tonumber(id)
        end
        return
    end
    if JoinTemporaryChannel then
        local ok, id = pcall(JoinTemporaryChannel, CHANNEL_NAME)
        if ok and tonumber(id) and tonumber(id) > 0 then
            channelId = tonumber(id)
        end
        return
    end
    if JoinPermanentChannel then
        pcall(JoinPermanentChannel, CHANNEL_NAME)
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
    if SmoreSkills.HostPanel and SmoreSkills.HostPanel.Refresh then
        SmoreSkills.HostPanel:Refresh()
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
    if SmoreSkills.Map and SmoreSkills.Map.RefreshPins then
        SmoreSkills.Map:RefreshPins()
    end
    RefreshUI()
    local own = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
    if own then
        SmoreSkills_Print("Cleared other camp markers. Your campsite stays until the fire ends or you pack it up.")
    else
        SmoreSkills_Print("Cleared camp markers from the map.")
    end
end

function Sync:EncodePacked(camp)
    if not camp then
        return nil
    end
    return table.concat({
        MSG_PACK,
        tostring(camp.mapId or 0),
        CoordWire(camp.x),
        CoordWire(camp.y),
        EscapeField(camp.owner),
        tostring(SmoreSkills_Now()),
    }, ":")
end

function Sync:DecodePacked(text)
    local parts = { strsplit(":", text) }
    if parts[1] ~= MSG_PACK then
        return nil
    end
    return {
        mapId = tonumber(parts[2]),
        x = CoordFromWire(parts[3]),
        y = CoordFromWire(parts[4]),
        owner = DecodeField(parts[5]),
        packedAt = tonumber(parts[6]) or SmoreSkills_Now(),
    }
end

function Sync:ApplyPacked(info, sender)
    if not info then
        return
    end
    local id = SmoreSkills_CampId(info.mapId, info.x, info.y)
    local camp = SmoreSkillsDB.camps and SmoreSkillsDB.camps[id]
    if not camp then
        return
    end
    if info.owner and camp.owner and not SmoreSkills_PlayerNamesMatch(info.owner, camp.owner) then
        return
    end
    if sender and camp.owner and not SmoreSkills_PlayerNamesMatch(sender, camp.owner) then
        return
    end
    camp.packed = true
    camp.packedAt = info.packedAt or SmoreSkills_Now()
    if self.seekDiscoveredIds then
        self.seekDiscoveredIds[id] = nil
    end
end

function Sync:PackUpCamp(camp, opts)
    opts = opts or {}
    camp = camp or SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
    if not camp then
        if not opts.silent then
            SmoreSkills_Print("No campsite to pack up.")
        end
        return false
    end
    camp.packed = true
    camp.packedAt = SmoreSkills_Now()
    self:StopHosting()
    local msg = self:EncodePacked(camp)
    if msg then
        if opts.silent then
            self.pendingPacked = self.pendingPacked or {}
            table.insert(self.pendingPacked, camp)
        else
            self:Send(msg, { chat = true })
        end
    end
    if self.seekDiscoveredIds and camp.id then
        self.seekDiscoveredIds[camp.id] = nil
    end
    RefreshUI()
    if not opts.silent then
        SmoreSkills_Print("Packed up your campsite. Other campers will no longer see it on the map.")
    end
    return true
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
        return true
    end
    channelId = 0
    return false
end

function Sync:GetChannelStatus()
    local ok = self:RefreshChannelId()
    return ok, channelId
end

local function GetActiveHostCamp()
    if Sync.hostCampId and SmoreSkillsDB.camps then
        local hosted = SmoreSkillsDB.camps[Sync.hostCampId]
        if hosted and (not SmoreSkills_CampPinActive or SmoreSkills_CampPinActive(hosted)) then
            return hosted
        end
    end
    if SmoreSkills_GetOwnedActiveCamp then
        local owned = SmoreSkills_GetOwnedActiveCamp()
        if owned then
            return owned
        end
    end
    return SmoreSkills_GetLocalCamp()
end

-- SendChatMessage is only legal from a hardware click/slash. Timers after campfire
-- or CHAT_MSG taint it ("Interface action failed") and the H: never leaves.
function Sync:FlushHardwareShare()
    if self.pendingPacked then
        for i = 1, #self.pendingPacked do
            local packed = self.pendingPacked[i]
            local msg = packed and self:EncodePacked(packed)
            if msg then
                self:Send(msg, { chat = true })
            end
        end
        self.pendingPacked = nil
    end
    if not self:IsHosting() then
        return false
    end
    local camp = GetActiveHostCamp()
    if not camp then
        return false
    end
    local sent = self:ShareHost(camp, { chat = true })
    if sent then
        self.pendingHostShare = nil
        self.needsHardwareShare = nil
        lastOutboundAt = SmoreSkills_Now()
    end
    return sent
end

function Sync:JoinCommunity(allowJoin)
    if self:RefreshChannelId() then
        joinAttempts = 0
        ScheduleYieldZoneChatSlots()
        return true
    end
    -- Join is Blizzard-only. Login, zoning, spellcast, and timers are tainted
    -- on Forever and pop the blocked-action dialog.
    if not allowJoin then
        YieldZoneChatSlots()
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        return false
    end
    if joinAttempts >= MAX_JOIN_ATTEMPTS then
        return false
    end
    joinAttempts = joinAttempts + 1
    JoinHiddenChannel()
    if self:RefreshChannelId() then
        joinAttempts = 0
        ScheduleYieldZoneChatSlots()
        return true
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(1.5, function()
            if self:RefreshChannelId() then
                joinAttempts = 0
                YieldZoneChatSlots()
                return
            end
            if joinAttempts < MAX_JOIN_ATTEMPTS then
                SmoreSkills_Print("Could not join the hidden S'more Skills channel yet. Click Find or /smores host once.")
            else
                SmoreSkills_Print("Could not join the hidden S'more Skills channel. Leave a chat channel if you are at the 10-channel limit, then /reload.")
            end
        end)
    end
    return false
end

local function SpellDisplayName(spellId)
    if not spellId then
        return nil
    end
    if C_Spell and C_Spell.GetSpellName then
        local name = C_Spell.GetSpellName(spellId)
        if name then
            return name
        end
    end
    if GetSpellInfo then
        return GetSpellInfo(spellId)
    end
    return nil
end

local function FrameIsShown(f)
    return f and f.IsShown and f:IsShown()
end

local function IsProfessionUiOpen()
    local professions = _G.ProfessionsFrame
    if FrameIsShown(professions) then
        return true
    end
    if professions and FrameIsShown(professions.CraftingPage) then
        return true
    end
    if FrameIsShown(_G.TradeSkillFrame) or FrameIsShown(_G.CraftFrame) then
        return true
    end
    if C_TradeSkillUI then
        if C_TradeSkillUI.IsRecipeRepeating then
            local ok, repeating = pcall(C_TradeSkillUI.IsRecipeRepeating)
            if ok and repeating then
                return true
            end
        end
    end
    return false
end

local function ParseCastArgs(a, b)
    local spellId, spellName, castGUID
    if type(a) == "string" and type(b) == "number" then
        spellId = b
        if a:find("Cast-", 1, true) then
            castGUID = a
        else
            spellName = a
        end
    elseif type(b) == "number" then
        spellId = b
        if type(a) == "string" then
            spellName = a
        end
    elseif type(a) == "number" then
        spellId = a
    elseif type(a) == "string" then
        spellName = a
    end
    return spellId, spellName, castGUID
end

local function RememberProfessionCast(castGUID)
    if not IsProfessionUiOpen() then
        return
    end
    if castGUID and castGUID ~= "" then
        craftCastGuids[castGUID] = true
        return
    end
    professionCastFallbackUntil = (GetTime and GetTime() or 0) + 3
end

local function WasProfessionCast(castGUID)
    if castGUID and craftCastGuids[castGUID] then
        craftCastGuids[castGUID] = nil
        return true
    end
    if castGUID and castGUID ~= "" then
        return false
    end
    local now = GetTime and GetTime() or 0
    return now < professionCastFallbackUntil
end

local function ForgetProfessionCast(castGUID)
    if castGUID then
        craftCastGuids[castGUID] = nil
    end
end

local function NameLooksLikePlacedFire(spellName)
    if not spellName or spellName == "" then
        return false
    end
    local key = strlower(spellName)
    if key:find("nearby", 1, true) then
        return false
    end
    if key:find("campfire", 1, true) then
        return true
    end
    if key:find("campsite", 1, true) then
        return true
    end
    if key:find("camp", 1, true) and key:find("kit", 1, true) then
        return true
    end
    return false
end

local function IsBasicCampfire(spellId, spellName)
    spellId = tonumber(spellId)
    if spellId and CAMPFIRE_SPELL_IDS[spellId] then
        return true
    end
    if (not spellName or spellName == "") and spellId then
        spellName = SpellDisplayName(spellId)
    end
    if NameLooksLikePlacedFire(spellName) then
        if spellId then
            CAMPFIRE_SPELL_IDS[spellId] = true
        end
        return true
    end
    local localized = SpellDisplayName(818)
    if localized and spellName and strlower(localized) == strlower(spellName) then
        return true
    end
    return false
end

function Sync:Init()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(PREFIX)
    end
    InstallChatFilters()
    InstallChatEditGuard()
    self:StartOutboundPump()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:RegisterEvent("CHAT_MSG_CHANNEL")
    frame:RegisterEvent("CHANNEL_UI_UPDATE")
    frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_ADDON" then
            local prefix, text, _, sender = ...
            if prefix and (prefix == PREFIX or tostring(prefix):sub(1, #PREFIX) == PREFIX) then
                self:OnMessage(text, sender)
            end
        elseif event == "CHAT_MSG_CHANNEL" then
            local text, sender, _, chFull, _, _, _, _, chName = ...
            local function isSmoreChannel(name)
                return name and strlower(tostring(name)):find(strlower(CHANNEL_NAME), 1, true)
            end
            if isSmoreChannel(chName) or isSmoreChannel(chFull) then
                local payload = text or ""
                if #payload >= #PREFIX and payload:sub(1, #PREFIX) == PREFIX then
                    payload = strtrim(payload:sub(#PREFIX + 1))
                    self:OnMessage(payload, sender)
                end
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            joinAttempts = 0
            self:JoinCommunity(false)
        else
            self:RefreshChannelId()
            if channelId > 0 then
                YieldZoneChatSlots()
            end
        end
    end)
    self:WatchCampfires()
end

local function SlotItemLink(bag, slot)
    if C_Container and C_Container.GetContainerItemLink then
        return C_Container.GetContainerItemLink(bag, slot)
    end
    if GetContainerItemLink then
        return GetContainerItemLink(bag, slot)
    end
    return nil
end

local function SlotItemName(bag, slot, link)
    if C_Container and C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemName and info.itemName ~= "" then
            return info.itemName
        end
    end
    if link then
        local name = link:match("%[(.-)%]")
        if name then
            return name
        end
    end
    return nil
end

local function ItemUseSpell(link)
    if not link then
        return nil, nil
    end
    if C_Item and C_Item.GetItemSpell then
        local ok, name, spellId = pcall(C_Item.GetItemSpell, link)
        if ok and (name or spellId) then
            if type(name) == "number" then
                return nil, name
            end
            if type(spellId) == "number" then
                return name, spellId
            end
            return name, nil
        end
    end
    if GetItemSpell then
        local a, b, c = GetItemSpell(link)
        if type(a) == "number" then
            return nil, a
        end
        if type(b) == "number" then
            return a, b
        end
        if type(c) == "number" then
            return a, c
        end
        return a, nil
    end
    return nil, nil
end

function Sync:RefreshKitSpells()
    local lastBag = NUM_BAG_SLOTS or 4
    for bag = 0, lastBag do
        local slots
        if C_Container and C_Container.GetContainerNumSlots then
            slots = C_Container.GetContainerNumSlots(bag)
        elseif GetContainerNumSlots then
            slots = GetContainerNumSlots(bag)
        end
        if slots then
            for slot = 1, slots do
                local link = SlotItemLink(bag, slot)
                local name = SlotItemName(bag, slot, link)
                if NameLooksLikePlacedFire(name) then
                    local spellName, spellId = ItemUseSpell(link)
                    if spellId then
                        CAMPFIRE_SPELL_IDS[spellId] = true
                    end
                    if NameLooksLikePlacedFire(spellName) and spellId then
                        CAMPFIRE_SPELL_IDS[spellId] = true
                    end
                end
            end
        end
    end
end

function Sync:NoteLastCast(spellId, spellName)
    self.lastCastId = tonumber(spellId)
    if spellName and spellName ~= "" then
        self.lastCastName = spellName
    else
        self.lastCastName = SpellDisplayName(spellId)
    end
end

function Sync:WatchCampfires()
    if self.campfireFrame then
        return
    end
    local f = CreateFrame("Frame")
    local unitEvents = {
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_SUCCEEDED",
        "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_FAILED",
    }
    for i = 1, #unitEvents do
        if f.RegisterUnitEvent then
            f:RegisterUnitEvent(unitEvents[i], "player")
        else
            f:RegisterEvent(unitEvents[i])
        end
    end
    f:RegisterEvent("UI_ERROR_MESSAGE")
    if not pcall(f.RegisterEvent, f, "BAG_UPDATE_DELAYED") then
        f:RegisterEvent("BAG_UPDATE")
    end
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_SPELLCAST_START" then
            local unit, a, b = ...
            self:OnUnitSpellcastStart(unit, a, b)
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, a, b = ...
            self:OnUnitSpellcastSucceeded(unit, a, b)
        elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
            local _, a, b = ...
            local _, _, castGUID = ParseCastArgs(a, b)
            ForgetProfessionCast(castGUID)
        elseif event == "UI_ERROR_MESSAGE" then
            self:OnUiError(...)
        else
            self:RefreshKitSpells()
        end
    end)
    self.campfireFrame = f
    self:RefreshKitSpells()
end

function Sync:OnUiError(errorType, message)
    if type(errorType) == "string" and (message == nil or type(message) ~= "string") then
        message = errorType
    end
    if type(message) ~= "string" then
        return
    end
    local key = strlower(message)
    if key:find("campfire", 1, true) and (key:find("100", 1, true) or key:find("within", 1, true)) then
        placeBlockedUntil = (GetTime and GetTime() or 0) + 2
    end
end

function Sync:OnUnitSpellcastStart(unit, a, b)
    if unit ~= "player" then
        return
    end
    local _, _, castGUID = ParseCastArgs(a, b)
    RememberProfessionCast(castGUID)
end

function Sync:OnUnitSpellcastSucceeded(unit, a, b)
    if unit ~= "player" then
        return
    end
    local spellId, spellName, castGUID = ParseCastArgs(a, b)
    self:NoteLastCast(spellId, spellName)
    if WasProfessionCast(castGUID) or IsProfessionUiOpen() then
        return
    end
    if IsBasicCampfire(spellId, spellName) then
        self:OnBasicCampfirePlaced()
    end
end

function Sync:OnBasicCampfirePlaced()
    if not SmoreSkills_GetAutoHostOnCampfire() then
        return
    end
    local nowTime = GetTime and GetTime() or 0
    if nowTime < placeBlockedUntil then
        return
    end
    local now = SmoreSkills_Now()
    if (now - lastCampfireHostAt) < 3 then
        return
    end
    lastCampfireHostAt = now
    -- Fire landed. Host locally after a short delay (interrupted casts never get here).
    -- Do not SendChatMessage from this timer — it taints ("Interface action failed").
    if C_Timer and C_Timer.After then
        C_Timer.After(0.25, function()
            self:HostHere(false, true)
        end)
    else
        pendingCampfireAt = (GetTime and GetTime() or 0) + 0.25
    end
end

function Sync:OnLogin()
    joinAttempts = 0
    self:JoinCommunity(false)
end

function Sync:TryOutbound()
    local now = SmoreSkills_Now()
    if (now - lastOutboundAt) < OUTBOUND_COOLDOWN then
        return false, "Wait a moment before sending again."
    end
    lastOutboundAt = now
    return true
end

function Sync:SendAddonWhisper(msg, target)
    if type(msg) ~= "string" or msg == "" or #msg > ADDON_MSG_MAX then
        return false
    end
    if type(target) ~= "string" or target == "" then
        return false
    end
    target = target:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if Ambiguate then
        target = Ambiguate(target, "short")
    end
    if not target or target == "" then
        return false
    end
    -- One attempt. Retrying a second name prints a second "Unable to whisper".
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        local ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, msg, "WHISPER", target)
        return ok and result ~= false
    end
    if SendAddonMessage then
        return pcall(SendAddonMessage, PREFIX, msg, "WHISPER", target)
    end
    return false
end

function Sync:DeliverAddonChannel(msg)
    if type(msg) ~= "string" or msg == "" then
        return false
    end
    if not self:RefreshChannelId() then
        return false
    end
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        local ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, msg, "CHANNEL", channelId)
        if (not ok or result == false) and CHANNEL_NAME then
            ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, msg, "CHANNEL", CHANNEL_NAME)
        end
        return ok and result ~= false
    end
    if SendAddonMessage then
        return pcall(SendAddonMessage, PREFIX, msg, "CHANNEL", channelId)
    end
    return false
end

function Sync:DeliverChat(msg)
    if type(msg) ~= "string" or msg == "" or not SendChatMessage then
        return false
    end
    if not self:RefreshChannelId() or not channelId or channelId <= 0 then
        return false
    end
    local chatMsg = PREFIX .. " " .. msg
    if #chatMsg > 255 then
        return false
    end
    return pcall(SendChatMessage, chatMsg, "CHANNEL", nil, channelId)
end

local function QueueJob(list, job)
    table.insert(list, job)
    while #list > 12 do
        table.remove(list, 1)
    end
end

function Sync:StartOutboundPump()
    if sendPump then
        return
    end
    sendPump = CreateFrame("Frame")
    sendPump:SetScript("OnUpdate", function()
        local now = (GetTime and GetTime()) or 0
        if pendingCampfireAt > 0 and now >= pendingCampfireAt then
            pendingCampfireAt = 0
            Sync:HostHere(false, true)
        end
        local i = 1
        while i <= #pendingWhispers do
            local job = pendingWhispers[i]
            if job and now >= (job.readyAt or 0) then
                table.remove(pendingWhispers, i)
                if not Sync:SendAddonWhisper(job.msg, job.target) then
                    SmoreSkills_Print("Could not send your camp to " .. tostring(job.target or "?") .. ".")
                end
            else
                i = i + 1
            end
        end
        i = 1
        while i <= #pendingChannel do
            local job = pendingChannel[i]
            if job and now >= (job.readyAt or 0) then
                table.remove(pendingChannel, i)
                Sync:DeliverAddonChannel(job.msg)
            else
                i = i + 1
            end
        end
    end)
end

function Sync:Send(msg, opts)
    opts = opts or {}
    if type(msg) ~= "string" or #msg > ADDON_MSG_MAX then
        return false
    end
    -- Addon CHANNEL from a timer is blocked on Forever the same way chat is.
    -- Only send addon from a hardware click (Find / /smores host).
    if opts.chat then
        self:DeliverAddonChannel(msg)
    end
    if opts.whisperTo then
        self:SendAddonWhisper(msg, opts.whisperTo)
    end
    if opts.chat then
        return self:DeliverChat(msg)
    end
    return true
end

local function AppendSlotParts(parts, camp, dropObjects)
    SmoreSkills_EnsureSlots(camp)
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        local prof = slot and (SmoreSkills_ProfessionFromId(slot.profession) or SmoreSkills_ProfessionFromCode(slot.profession))
        table.insert(parts, EscapeField(prof and prof.code or nil))
        local object = (not dropObjects) and slot and slot.object or nil
        table.insert(parts, EscapeField(object))
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

-- S:map:fac:prof:t[:extraCodes]:layer
function Sync:EncodeSeek(mapId, professionId)
    local codes = {}
    local seen = {}
    local function add(id)
        local prof = SmoreSkills_ProfessionFromId(SmoreSkills_NormalizeProfession(id))
        if prof and not seen[prof.code] then
            seen[prof.code] = true
            table.insert(codes, prof.code)
        end
    end
    add(professionId)
    if SmoreSkills_GetPlayerProfessions then
        for _, id in ipairs(SmoreSkills_GetPlayerProfessions()) do
            add(id)
        end
    end
    local parts = {
        MSG_SEEK,
        tostring(mapId or 0),
        EscapeField(SmoreSkills_PlayerFaction()),
        EscapeField(codes[1]),
        tostring(SmoreSkills_Now()),
    }
    if #codes > 1 then
        table.insert(parts, table.concat(codes, ","))
    end
    table.insert(parts, tostring((SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId()) or 0))
    return table.concat(parts, ":")
end

function Sync:DecodeSeek(text)
    local parts = { strsplit(":", text) }
    if parts[1] ~= MSG_SEEK then
        return nil
    end
    local professions = {}
    local seen = {}
    local function addField(field)
        field = DecodeField(field)
        if not field then
            return
        end
        for token in string.gmatch(field, "[^,]+") do
            local prof = SmoreSkills_ProfessionFromCode(strtrim(token))
            if prof and not seen[prof.id] then
                seen[prof.id] = true
                table.insert(professions, prof.id)
            end
        end
    end
    addField(parts[4])
    local n = #parts
    local layer = 0
    if n >= 7 then
        addField(parts[6])
        layer = tonumber(parts[n]) or 0
    elseif n == 6 then
        local extra = parts[6]
        if extra and extra:find(",", 1, true) then
            addField(extra)
        else
            local asLayer = tonumber(extra)
            if asLayer then
                layer = asLayer
            else
                addField(extra)
            end
        end
    end
    if layer == 0 then
        layer = nil
    end
    return {
        mapId = tonumber(parts[2]),
        faction = DecodeField(parts[3]),
        profession = professions[1],
        professions = professions,
        updatedAt = tonumber(parts[5]) or SmoreSkills_Now(),
        layer = layer,
    }
end

-- H:map:x:y:fac:own:want:p1:o1:p2:o2:p3:o3:t:layer[/ord]
-- If the payload would exceed 250 bytes, drop extras rather than fail silent.
-- Order: want-items, then object display names, then shorten own. Revisit if
-- Forever two-part names + full item lists still clip useful tooltip data.
function Sync:EncodeHost(camp)
    if not camp then
        return nil
    end
    local function layerField()
        local layerId = tonumber(camp.layer) or 0
        local field = tostring(layerId)
        local ord = layerId > 0 and SmoreSkills_LayerOrdinal and SmoreSkills_LayerOrdinal(layerId, camp.mapId) or nil
        if ord and ord > 0 then
            field = field .. "/" .. tostring(ord)
        end
        return field
    end
    local function build(wantItems, dropObjects, owner)
        local parts = {
            MSG_HOST,
            tostring(camp.mapId or 0),
            CoordWire(camp.x),
            CoordWire(camp.y),
            EscapeField(camp.faction),
            EscapeField(owner),
            EscapeField(SmoreSkills_JoinWantWire(camp.want or "any", wantItems)),
        }
        AppendSlotParts(parts, camp, dropObjects)
        table.insert(parts, tostring(camp.litAt or camp.updatedAt or SmoreSkills_Now()))
        table.insert(parts, layerField())
        return table.concat(parts, ":")
    end
    local owner = camp.owner
    local msg = build(camp.wantItems, false, owner)
    local stripped = {}
    if #msg > ADDON_MSG_MAX then
        msg = build(nil, false, owner)
        table.insert(stripped, "host item list")
    end
    if #msg > ADDON_MSG_MAX then
        msg = build(nil, true, owner)
        table.insert(stripped, "object names")
    end
    if #msg > ADDON_MSG_MAX then
        local short = tostring(owner or "")
        if #short > 24 then
            short = short:sub(1, 24)
        end
        msg = build(nil, true, short)
        table.insert(stripped, "shortened name")
    end
    if #msg > ADDON_MSG_MAX then
        return nil, stripped
    end
    return msg, stripped
end

function Sync:DecodeHost(text)
    local parts = { strsplit(":", text) }
    if parts[1] ~= MSG_HOST then
        return nil
    end
    local wantRaw = DecodeField(parts[7]) or "any"
    local want, wantItems = SmoreSkills_SplitWantWire(wantRaw)
    -- Timestamp and layer are the last two fields so extra colons in the middle
    -- cannot turn the layer id (e.g. 15654) into an "expired" unix time.
    -- Layer field is "zoneUID" or "zoneUID/ordinal" (ordinal is the host's Layer N).
    local n = #parts
    local updatedAt, layer, ordinal = nil, 0, nil
    if n >= 15 then
        local last = parts[n]
        local slash = last and last:find("/", 1, true) or nil
        if slash then
            layer = tonumber(last:sub(1, slash - 1)) or 0
            ordinal = tonumber(last:sub(slash + 1))
        else
            layer = tonumber(last) or 0
        end
        updatedAt = tonumber(parts[n - 1])
    elseif n >= 14 then
        updatedAt = tonumber(parts[n])
    end
    updatedAt = SmoreSkills_SanitizeCampTime(updatedAt)
    if layer == 0 then
        layer = nil
    end
    if ordinal and ordinal <= 0 then
        ordinal = nil
    end
    local camp = {
        mapId = tonumber(parts[2]),
        x = CoordFromWire(parts[3]),
        y = CoordFromWire(parts[4]),
        faction = DecodeField(parts[5]),
        owner = DecodeField(parts[6]),
        want = want or "any",
        wantItems = wantItems,
        slots = {},
        litAt = updatedAt,
        updatedAt = updatedAt,
        layer = layer,
        layerOrdinal = ordinal,
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

function Sync:ShareOwnedCampFromClick()
    local camp = GetActiveHostCamp()
    if not camp then
        SmoreSkills_NotifyHostCampUi()
        return false
    end
    self:JoinCommunity(true)
    local sent = self:ShareHost(camp, { chat = true })
    if sent then
        lastOutboundAt = SmoreSkills_Now()
        self.pendingHostShare = nil
        self.needsHardwareShare = nil
    else
        self.pendingHostShare = camp
        self.needsHardwareShare = true
    end
    RefreshUI()
    return sent
end

function Sync:ShareHost(camp, opts)
    opts = opts or {}
    SmoreSkills_ApplyHostWantToCamp(camp)
    camp.updatedAt = SmoreSkills_Now()
    local layer = SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId()
    if layer then
        camp.layer = layer
    end
    local msg, stripped = self:EncodeHost(camp)
    if not msg then
        if not self.hostEncodeFailedNoted then
            self.hostEncodeFailedNoted = true
            SmoreSkills_Print("Could not share this camp: the signal is still over 250 bytes after shrinking.")
        end
        return false
    end
    if stripped and stripped[1] and not self.hostShrinkNoted then
        self.hostShrinkNoted = true
        SmoreSkills_Print(string.format(
            "Camp signal was too long; seekers still see the pin (%s left off the wire).",
            table.concat(stripped, ", ")
        ))
    end
    -- Prefer the hidden channel. Addon WHISPER on TBC Anniversary often prints
    -- "Unable to whisper ... Blizzard services may be unavailable" even when /w works.
    local sendOpts = { chat = opts.chat }
    if opts.whisperTo and not self:RefreshChannelId() then
        sendOpts.whisperTo = opts.whisperTo
    end
    return self:Send(msg, sendOpts)
end

function Sync:SeekHere()
    -- Find / slash is hardware. Join + H: are legal here (campfire timers are not).
    self:JoinCommunity(true)
    self:FlushHardwareShare()

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
    local professions = SmoreSkills_CollectSeekerProfessions(SmoreSkills_GetPlayerProfession())
    local profession = professions[1]
    if not profession then
        SmoreSkills_Print("Set your profession first: /smores prof lw (or bs, tail, …).")
        return
    end

    if self:CanResumeSeek() then
        self.mapPinsDismissed = false
        self:StartListening()
        if SmoreSkills.Map and SmoreSkills.Map.ShowPlayerZone then
            SmoreSkills.Map:ShowPlayerZone(mapId)
        end
        local matches = SmoreSkills_ListMatchedCamps(mapId, professions)
        for _, camp in ipairs(matches) do
            self:RecordSeekDiscovery(camp)
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
    local msg = self:EncodeSeek(mapId, profession)
    if not self:Send(msg, { chat = true }) then
        SmoreSkills_Print("Could not send seek signal. Wait for the community channel.")
        return
    end
    lastOutboundAt = now
    lastSeekAt = now
    self.seekListenUntil = now + SmoreSkills.SIGNAL_TTL
    self.mapPinsDismissed = false
    self:StartListening()
    if SmoreSkills.Map and SmoreSkills.Map.ShowPlayerZone then
        SmoreSkills.Map:ShowPlayerZone(mapId)
    end

    local matches = SmoreSkills_ListMatchedCamps(mapId, professions)
    for _, camp in ipairs(matches) do
        self:RecordSeekDiscovery(camp)
    end
    local visible = SmoreSkills_ListVisibleCamps and SmoreSkills_ListVisibleCamps(mapId) or matches
    local others = 0
    local me = SmoreSkills_PlayerName and SmoreSkills_PlayerName()
    for _, camp in ipairs(visible) do
        if not SmoreSkills_PlayerNamesMatch(camp.owner, me) then
            others = others + 1
        end
    end
    SmoreSkills_Print(string.format(
        "Looking for camps in %s as %s — %d other camp(s) right now. Open the %s zone map (not the continent).",
        zone or "?",
        SmoreSkills_FormatProfessionList(professions),
        others,
        zone or "zone"
    ))
    RefreshUI()
    if C_Timer and C_Timer.After then
        C_Timer.After(0.15, function()
            if SmoreSkills.Map and SmoreSkills.Map.RefreshPins then
                SmoreSkills.Map:RefreshPins()
            end
        end)
    end
end

function Sync:StopHosting()
    self.hostingUntil = 0
    self.hostCampId = nil
    self.pendingHostShare = nil
    self.hostShrinkNoted = nil
    self.hostEncodeFailedNoted = nil
    if SmoreSkills.HostPanel and SmoreSkills.HostPanel.Hide then
        SmoreSkills.HostPanel:Hide()
    end
    local handle = self.hostTickHandle
    self.hostTickHandle = nil
    if not handle then
        return
    end
    if type(handle) == "table" and handle.Cancel then
        pcall(function()
            handle:Cancel()
        end)
    elseif C_Timer and C_Timer.CancelTimer then
        pcall(function()
            C_Timer.CancelTimer(handle)
        end)
    end
end

function Sync:ReplyToSeeker(camp, seekerName)
    camp = camp or GetActiveHostCamp()
    if not camp or not self:IsHosting() then
        return
    end
    if SmoreSkills_ApplyHostProfession then
        SmoreSkills_ApplyHostProfession(camp)
    end
    SmoreSkills_ApplyHostWantToCamp(camp)
    local live = GetActiveHostCamp() or camp
    self.pendingHostShare = live
    self.needsHardwareShare = true
end

function Sync:HostHeartbeat()
    if not self:IsHosting() then
        self:StopHosting()
        return
    end
    local camp = GetActiveHostCamp()
    if not camp then
        if C_Timer and C_Timer.After then
            self.hostTickHandle = C_Timer.After(HOST_COOLDOWN, function()
                self:HostHeartbeat()
            end)
        end
        return
    end
    if not SmoreSkills_CampPinActive(camp) then
        self:StopHosting()
        return
    end
    SmoreSkills_ApplyHostWantToCamp(camp)
    SmoreSkills_ApplyHostProfession(camp)
    self.hostTickHandle = C_Timer and C_Timer.After(HOST_COOLDOWN, function()
        self:HostHeartbeat()
    end)
end

function Sync:HostHere(fromHardware, newFire)
    local mapId, x, y = SmoreSkills_GetPlayerMapPos()
    local retiredFrom = nil
    if newFire and mapId and SmoreSkills_ForEachOwnedActiveCamp then
        local stale = {}
        SmoreSkills_ForEachOwnedActiveCamp(function(owned)
            if not SmoreSkills_CampsShareSite(owned, mapId, x, y) then
                table.insert(stale, owned)
            end
        end)
        for i = 1, #stale do
            if not retiredFrom then
                retiredFrom = stale[i].zone or "the previous zone"
            end
            self:PackUpCamp(stale[i], { silent = true })
        end
    end
    local camp, err = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp() or nil
    if camp and newFire and mapId and SmoreSkills_CampsShareSite and not SmoreSkills_CampsShareSite(camp, mapId, x, y) then
        camp = nil
    end
    if not camp then
        camp, err = SmoreSkills_MarkHere()
        if not camp then
            SmoreSkills_Print(err)
            return
        end
    end
    SmoreSkills_ApplyHostProfession(camp)
    camp.source = "host"
    local wasPacked = camp.packed
    camp.packed = nil
    camp.packedAt = nil
    -- 3/3 still hosts; seekers who need an empty slot simply will not match.
    SmoreSkills_ApplyHostWantToCamp(camp)
    camp.layer = (SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId()) or camp.layer
    local now = SmoreSkills_Now()
    -- New physical fire starts a fresh 10 min pin. Walking away / slash host keep litAt.
    if newFire or wasPacked or not camp.litAt or (now - camp.litAt) >= SmoreSkills.CAMPFIRE_DURATION then
        camp.litAt = now
    end
    self.hostShrinkNoted = nil
    self.hostEncodeFailedNoted = nil
    local sent = false
    if fromHardware then
        self:JoinCommunity(true)
        if self.pendingPacked then
            for i = 1, #self.pendingPacked do
                local packed = self.pendingPacked[i]
                local msg = packed and self:EncodePacked(packed)
                if msg then
                    self:Send(msg, { chat = true })
                end
            end
            self.pendingPacked = nil
        end
        local ok, outboundErr = true, nil
        if not self.needsHardwareShare then
            ok, outboundErr = self:TryOutbound()
        end
        if ok then
            sent = self:ShareHost(camp, { chat = true })
            lastOutboundAt = SmoreSkills_Now()
        elseif outboundErr then
            SmoreSkills_Print(outboundErr .. " Click Find to share the fire.")
        end
        if sent then
            self.pendingHostShare = nil
            self.needsHardwareShare = nil
        else
            self.pendingHostShare = camp
            self.needsHardwareShare = true
            self:JoinCommunity(true)
        end
    else
        -- Campfire timer: local pin only. Do not join, send addon, or SendChatMessage.
        self.pendingHostShare = camp
        self.needsHardwareShare = true
    end
    if self.hostTickHandle and C_Timer and C_Timer.CancelTimer then
        C_Timer.CancelTimer(self.hostTickHandle)
    end
    if self.hostTickHandle and type(self.hostTickHandle) == "table" and self.hostTickHandle.Cancel then
        pcall(function()
            self.hostTickHandle:Cancel()
        end)
    end
    self.hostTickHandle = nil
    self.hostCampId = camp.id
    self.hostingUntil = camp.litAt + SmoreSkills.CAMPFIRE_DURATION
    if C_Timer and C_Timer.After then
        self.hostTickHandle = C_Timer.After(HOST_COOLDOWN, function()
            self:HostHeartbeat()
        end)
    end
    local layerText = SmoreSkills_FormatLayer and SmoreSkills_FormatLayer(camp.layer, camp.mapId)
    local layerHint = layerText and (" · " .. layerText) or " · target an NPC to detect your layer"
    local moved = ""
    if retiredFrom then
        moved = string.format(" Previous camp in %s is packed up. ", retiredFrom)
    end
    SmoreSkills_Print(string.format(
        "Hosting in %s (%s) — %d/%d objects, want: %s%s. %sPin lasts %d min from this fire (same clock for every seeker).",
        camp.zone or "?",
        SmoreSkills_FormatCoords(camp),
        SmoreSkills_CountFilledSlots(camp),
        SmoreSkills.MAX_SLOTS,
        SmoreSkills_FormatWant(camp.want, camp.wantItems),
        layerHint,
        moved,
        math.floor(SmoreSkills.CAMPFIRE_DURATION / 60)
    ))
    if self.needsHardwareShare then
        SmoreSkills_Print("Click Find or /smores host once so other campers can see this fire.")
    end
    RefreshUI()
    if SmoreSkills.HostPanel and SmoreSkills.HostPanel.ShowFor then
        SmoreSkills.HostPanel:ShowFor(camp)
    end
end

function Sync:OnMessage(text, sender)
    if not text or text == "" then
        return
    end
    if SmoreSkills_PlayerNamesMatch(sender, SmoreSkills_PlayerName()) then
        return
    end
    if not ShouldHandleMessage(text, sender) then
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
            local professions = SmoreSkills_CollectSeekerProfessions(SmoreSkills_GetPlayerProfession())
            if mapId and SmoreSkills_CampVisibleToSeeker(camp, mapId, professions) then
                self:RecordSeekDiscovery(camp)
                SmoreSkills_Print(string.format(
                    "Camp found: %s (%s) — %s. Switch the map to %s if the pin is missing.",
                    camp.zone or "?",
                    SmoreSkills_FormatCoords(camp),
                    SmoreSkills_FormatSlots(camp),
                    camp.zone or "that zone"
                ))
            else
                local hostWant = camp.want or "any"
                if not SmoreSkills_WantAcceptsAny(hostWant, professions) then
                    SmoreSkills_Print(string.format(
                        "Heard %s's camp in %s, but none of your professions match (they want: %s; you are: %s).",
                        camp.owner or "a host",
                        camp.zone or "this zone",
                        SmoreSkills_FormatWant(camp.want, camp.wantItems),
                        SmoreSkills_FormatProfessionList(professions)
                    ))
                else
                    local why = SmoreSkills_CampHiddenReason and SmoreSkills_CampHiddenReason(camp, mapId, professions)
                    SmoreSkills_Print(string.format(
                        "Heard %s's camp in %s, but it is not shown (%s).",
                        camp.owner or "a host",
                        camp.zone or "this zone",
                        why or "full, packed, expired, or a seeker filter"
                    ))
                end
            end
        end
        RefreshUI()
    elseif msgType == MSG_PACK then
        local info = self:DecodePacked(text)
        self:ApplyPacked(info, sender)
        RefreshUI()
    elseif msgType == MSG_SEEK then
        local seek = self:DecodeSeek(text)
        if not seek or seek.faction ~= SmoreSkills_PlayerFaction() then
            return
        end
        if not self:IsHosting() then
            return
        end
        local camp = GetActiveHostCamp()
        if not camp then
            return
        end
        if camp.mapId ~= seek.mapId and not SmoreSkills_MapsShareZone(camp.mapId, seek.mapId) then
            return
        end
        local seekProfs = seek.professions
        if not seekProfs or #seekProfs == 0 then
            seekProfs = seek.profession
        end
        if not SmoreSkills_HostMatchesSeeker(camp, seek.mapId, seekProfs) then
            return
        end
        if not SmoreSkills_GetCrossLayerEnabled or not SmoreSkills_GetCrossLayerEnabled() then
            local hostLayer = tonumber(camp.layer) or (SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId()) or nil
            local seekLayer = tonumber(seek.layer)
            if hostLayer and seekLayer and hostLayer ~= 0 and seekLayer ~= 0 and hostLayer ~= seekLayer then
                return
            end
        end
        local now = SmoreSkills_Now()
        if now - lastSeekReplyPrintAt > 10 then
            lastSeekReplyPrintAt = now
            SmoreSkills_Print("Someone is looking for camps in this zone. Click Find or /smores host to share yours.")
        end
        self:ReplyToSeeker(camp, sender)
    end
end
