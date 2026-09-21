SLASH_SMORESKILLS1 = "/smores"
SLASH_SMORESKILLS2 = "/sms"
SLASH_SMORESKILLS3 = "/smoreskills"

local function PrintProfessions()
    local parts = {}
    for _, row in ipairs(SmoreSkills.PROFESSIONS) do
        table.insert(parts, row.code)
    end
    SmoreSkills_Reply("Professions: " .. table.concat(parts, ", "))
end

local function HandleSlash(msg)
    msg = strtrim(msg or "")
    local lower = strlower(msg)

    if lower == "here" or lower == "share" then
        SmoreSkills_Reply("That command is gone. Use /smores host to share your campfire.")
        return
    end
    if lower == "find" or lower == "seek" then
        SmoreSkills.Sync:SeekHere()
        return
    end
    if lower == "host" then
        SmoreSkills.Sync:HostHere(true)
        return
    end
    local hostArg = lower:match("^host%s+(.+)$")
    if hostArg then
        local fireType = SmoreSkills_NormalizeFireType and SmoreSkills_NormalizeFireType(hostArg)
        if not fireType then
            SmoreSkills_Reply("Usage: /smores host [basic | journeyman | expert]")
            return
        end
        SmoreSkills.Sync:HostHere(true, false, fireType)
        return
    end
    if lower == "persist" then
        local camp, reason = nil, nil
        if SmoreSkills_RestoreOwnedHost then
            camp, reason = SmoreSkills_RestoreOwnedHost()
        end
        if camp and SmoreSkills.Sync and SmoreSkills.Sync.RestoreHostSession then
            SmoreSkills.Sync:RestoreHostSession()
        end
        camp = camp or (SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp())
        if camp then
            SmoreSkills_Reply(string.format(
                "Persist: %s in %s — %s — %d/%d sockets — %.0fs left",
                (SmoreSkills_FireTypeLabel and SmoreSkills_FireTypeLabel(camp.fireType)) or "Basic",
                camp.zone or "?",
                SmoreSkills_FormatCoords and SmoreSkills_FormatCoords(camp) or "?",
                SmoreSkills_CountFilledSlots and SmoreSkills_CountFilledSlots(camp) or 0,
                SmoreSkills_CampSlotCount and SmoreSkills_CampSlotCount(camp) or 3,
                tonumber(camp.ttlLeft) or (SmoreSkills_OwnedHostRemaining and SmoreSkills_OwnedHostRemaining(camp)) or 0
            ))
        else
            SmoreSkills_Reply("Persist: no camp (" .. tostring(reason or "none") .. ")")
        end
        local server = (type(SmoreSkillsHostDB) == "table" and tonumber(SmoreSkillsHostDB.server))
            or (SmoreSkillsDB and tonumber(SmoreSkillsDB.hostSnap_server))
            or (SmoreSkillsDB and tonumber(SmoreSkillsDB.hostSnap_clock))
            or 0
        local left = (type(SmoreSkillsHostDB) == "table" and tonumber(SmoreSkillsHostDB.remaining))
            or (SmoreSkillsDB and tonumber(SmoreSkillsDB.hostSnapRemaining))
            or 0
        local now = SmoreSkills_Now()
        SmoreSkills_Reply(string.format(
            "TTL: server now %d  saved %d  remaining %.0f  elapsed %ds",
            now,
            server,
            left,
            (now > 0 and server > 0) and (now - server) or 0
        ))
        local blob, source = nil, nil
        if SmoreSkills_ReadHostPersistBlob then
            blob, source = SmoreSkills_ReadHostPersistBlob()
        end
        local channels = SmoreSkills_HostPersistChannels and SmoreSkills_HostPersistChannels() or {}
        SmoreSkills_Reply("HP: " .. (blob and ("yes via " .. tostring(source)) or "no")
            .. "  channels: " .. (#channels > 0 and table.concat(channels, ", ") or "none"))
        local me = SmoreSkills_PlayerName and SmoreSkills_PlayerName() or "?"
        local owner = camp and camp.owner or (SmoreSkillsDB and SmoreSkillsDB.hostSnap_owner) or "?"
        local active = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
        SmoreSkills_Reply(string.format(
            "Owner: %s  me: %s  match: %s  hostCampId: %s  GetOwned: %s",
            tostring(owner),
            tostring(me),
            tostring(SmoreSkills_PlayerNamesMatch and SmoreSkills_PlayerNamesMatch(owner, me)),
            tostring(SmoreSkillsDB and SmoreSkillsDB.hostCampId),
            active and "yes" or "no"
        ))
        return
    end
    if lower == "camp" then
        if SmoreSkills.HostPanel and SmoreSkills.HostPanel.Toggle then
            SmoreSkills.HostPanel:Toggle()
        end
        return
    end
    if lower == "stop" then
        SmoreSkills.Sync:StopHosting()
        SmoreSkills_Reply("Stopped hosting.")
        return
    end
    if lower == "pack" or lower == "packup" then
        local camp = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
        if not camp then
            SmoreSkills_Reply("No campsite to pack up.")
            return
        end
        if SmoreSkills.Map and SmoreSkills.Map.ConfirmPackUp then
            SmoreSkills.Map:ConfirmPackUp(camp)
        else
            SmoreSkills.Sync:PackUpCamp(camp)
        end
        return
    end
    if lower == "castdebug" then
        local sync = SmoreSkills.Sync
        sync.castDebug = not sync.castDebug
        SmoreSkills_Reply("Cast debug: " .. (sync.castDebug and "on" or "off"))
        if sync.castDebug then
            SmoreSkills_Reply("Known place-fire spells: " .. (sync:DescribeKitSpells() or "none"))
        end
        return
    end
    if lower == "status" then
        local sync = SmoreSkills.Sync
        local chOk, chId = sync:GetChannelStatus()
        SmoreSkills_Reply("Share: hidden addon whisper for H:. Find listen: " .. (chOk and "SmoreSkills (joined)" or "SmoreSkills (not joined)"))
        local id1, name1 = GetChannelName(1)
        if id1 and id1 > 0 and name1 then
            SmoreSkills_Reply("/1 is " .. tostring(name1))
        end
        if sync:IsHosting() then
            local left = math.max(0, math.ceil((sync.hostingUntil or 0) - SmoreSkills_Now()))
            local camp = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
            local fireBit = ""
            if camp and SmoreSkills_CampFireType and SmoreSkills_CampFireType(camp) ~= "basic" then
                fireBit = " " .. (SmoreSkills_FireTypeLabel and SmoreSkills_FireTypeLabel(camp.fireType) or camp.fireType)
            end
            SmoreSkills_Reply(string.format("Hosting: yes (%ds left)%s. Want: %s", left, fireBit, SmoreSkills_FormatWant(SmoreSkills_GetEffectiveHostWant(), SmoreSkills_GetEffectiveHostWantItems())))
        else
            SmoreSkills_Reply("Hosting: no")
        end
        local snap = SmoreSkillsHostDB
        if not (type(snap) == "table" and tonumber(snap.mapId) and tonumber(snap.mapId) > 0) then
            snap = {
                mapId = SmoreSkillsDB and SmoreSkillsDB.hostSnap_mapId,
                x = SmoreSkillsDB and SmoreSkillsDB.hostSnap_x,
                y = SmoreSkillsDB and SmoreSkillsDB.hostSnap_y,
                zone = SmoreSkillsDB and SmoreSkillsDB.hostSnap_zone,
                litAt = SmoreSkillsDB and SmoreSkillsDB.hostSnap_litAt,
                remaining = SmoreSkillsDB and (SmoreSkillsDB.hostSnap_remaining or SmoreSkillsDB.hostSnapRemaining),
            }
        end
        if type(snap) == "table" and tonumber(snap.mapId) and tonumber(snap.mapId) > 0 then
            local age = math.max(0, SmoreSkills_Now() - (tonumber(snap.litAt) or 0))
            SmoreSkills_Reply(string.format(
                "Host snapshot: %s at %.0f,%.0f (%ds old, %ds saved)",
                (snap.zone and snap.zone ~= "") and snap.zone or tostring(snap.mapId),
                (tonumber(snap.x) or 0) * 100,
                (tonumber(snap.y) or 0) * 100,
                age,
                tonumber(snap.remaining) or 0
            ))
        else
            SmoreSkills_Reply("Host snapshot: none")
        end
        if SmoreSkills_ReadHostPersistBlob then
            local blob, source = SmoreSkills_ReadHostPersistBlob()
            SmoreSkills_Reply("HP: " .. (blob and ("yes via " .. tostring(source)) or "no"))
        end
        do
            local realm = (GetServerTime and tonumber(GetServerTime())) or 0
            if realm > 1000000000000 then
                realm = math.floor(realm / 1000)
            end
            local pc = (time and tonumber(time())) or 0
            local snapClock = (type(SmoreSkillsHostDB) == "table" and tonumber(SmoreSkillsHostDB.clock))
                or (SmoreSkillsDB and tonumber(SmoreSkillsDB.hostSnap_clock))
                or 0
            SmoreSkills_Reply(string.format(
                "Clock: realm %d  pc %d  snap %d  gap %ds",
                realm,
                pc,
                snapClock,
                (pc > 0 and realm > 0) and (pc - realm) or 0
            ))
        end
        if sync:IsSeeking() then
            SmoreSkills_Reply(string.format("Seeking: yes (%ds left)", sync:GetSeekingRemaining()))
        else
            SmoreSkills_Reply("Seeking: no")
        end
        local profs = SmoreSkills_CollectSeekerProfessions(SmoreSkills_GetPlayerProfession())
        SmoreSkills_Reply("Your trades: " .. SmoreSkills_FormatProfessionList(profs))
        local mapId, _, _, zone = SmoreSkills_GetPlayerMapPos()
        if SmoreSkills_FormatMapStatus and mapId then
            SmoreSkills_Reply("Zone: " .. SmoreSkills_FormatMapStatus(mapId) .. (zone and (" / " .. zone) or ""))
        else
            SmoreSkills_Reply("Zone: " .. (zone or "?"))
        end
        if sync.lastCastId or sync.lastCastName then
            SmoreSkills_Reply(string.format("Last cast: %s %s", tostring(sync.lastCastId or "?"), tostring(sync.lastCastName or "?")))
        end
        local layer = SmoreSkills_FormatLayer and SmoreSkills_FormatLayer(SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId(), mapId)
        if layer then
            SmoreSkills_Reply("Layer: " .. layer)
        else
            SmoreSkills_Reply("Layer: unknown (target an NPC)")
        end
        if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() and WorldMapFrame.GetMapID then
            local viewId = WorldMapFrame:GetMapID()
            if SmoreSkills_FormatMapStatus then
                SmoreSkills_Reply("Map view: " .. SmoreSkills_FormatMapStatus(viewId))
            else
                local viewName = viewId
                if C_Map and C_Map.GetMapInfo and viewId then
                    local info = C_Map.GetMapInfo(viewId)
                    viewName = info and info.name or viewId
                end
                SmoreSkills_Reply("Map view: " .. tostring(viewName))
            end
        end
        SmoreSkills_Reply("Seeker filter: " .. SmoreSkills_FormatWant(SmoreSkills_GetEffectiveSeekerWant(), SmoreSkills_GetEffectiveSeekerWantItems()))
        SmoreSkills_Reply("Cross-layer: " .. ((SmoreSkills_GetCrossLayerEnabled and SmoreSkills_GetCrossLayerEnabled()) and "on" or "off (own layer only)"))
        return
    end
    if lower == "list" then
        local mapId = select(1, SmoreSkills_GetPlayerMapPos())
        local camps = SmoreSkills_ListVisibleCamps(mapId)
        if #camps == 0 then
            SmoreSkills_Reply("No camps stored.")
            return
        end
        for _, camp in ipairs(camps) do
            local guildMark = (SmoreSkills_ShowCampGuildMark and SmoreSkills_ShowCampGuildMark(camp)) and " [guild] " or " "
            local tag = camp.source == "host" and "[host] " or ""
            local own = SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName())
            local layer = SmoreSkills_FormatLayerCompare and SmoreSkills_FormatLayerCompare(camp.layer, camp.mapId, own, camp.layerOrdinal)
            local layerBit = layer and (" " .. layer) or ""
            SmoreSkills_Reply(string.format(
                "%s%s%s(%s)%s %d/%d — %s",
                tag,
                camp.zone or "?",
                guildMark,
                SmoreSkills_FormatCoords(camp),
                layerBit,
                SmoreSkills_CountFilledSlots(camp),
                SmoreSkills_CampSlotCount and SmoreSkills_CampSlotCount(camp) or SmoreSkills.MAX_SLOTS,
                SmoreSkills_FormatSlots(camp)
            ))
        end
        return
    end
    if lower == "prof" or lower == "profession" then
        local profs = SmoreSkills_GetPlayerProfessions()
        local current = SmoreSkills_GetPlayerProfession()
        if #profs > 0 then
            local detected = {}
            for _, id in ipairs(profs) do
                table.insert(detected, SmoreSkills_ProfessionLabel(id))
            end
            SmoreSkills_Reply("Detected: " .. table.concat(detected, ", "))
        end
        if current then
            if SmoreSkills.sessionProfession then
                SmoreSkills_Reply("Seeking as: " .. SmoreSkills_ProfessionLabel(current) .. " (this session only; reload uses your learned trades)")
            else
                SmoreSkills_Reply("Seeking as: " .. SmoreSkills_ProfessionLabel(current) .. " (learned trades)")
            end
        else
            SmoreSkills_Reply("No seek profession set. Learn a trade, or /smores prof <code> this session.")
            PrintProfessions()
        end
        return
    end
    if lower:match("^prof ") or lower:match("^profession ") then
        local code = strtrim(lower:match("^prof%s+(.+)") or lower:match("^profession%s+(.+)") or "")
        if code == "" then
            PrintProfessions()
            return
        end
        if SmoreSkills_SetPlayerProfession(code) then
            SmoreSkills_Reply("Profession set to " .. SmoreSkills_ProfessionLabel(code) .. " until reload (testing). Matching still includes your learned trades.")
        else
            SmoreSkills_Reply("Unknown profession. Try: lw, bs, tail, …")
            PrintProfessions()
        end
        return
    end
    if lower == "settings" or lower == "config" then
        if SmoreSkills.Settings and SmoreSkills.Settings.Toggle then
            SmoreSkills.Settings:Toggle()
        end
        return
    end
    if lower == "want" then
        SmoreSkills_Reply("Host want list: " .. SmoreSkills_FormatWant(SmoreSkills_GetEffectiveHostWant()) .. " (/smores want any | bs,lw, …)")
        return
    end
    if lower:match("^want ") then
        local want = strtrim(lower:match("^want%s+(.+)") or "")
        if SmoreSkills_SetHostWant(want) then
            if want == "any" or want == "" then
                SmoreSkills_SetHostFilterEnabled(false)
            else
                SmoreSkills_SetHostFilterEnabled(true)
            end
            SmoreSkills_Reply("Host want list: " .. SmoreSkills_FormatWant(SmoreSkills_GetEffectiveHostWant()))
        else
            SmoreSkills_Reply("Unknown profession in want list.")
            PrintProfessions()
        end
        return
    end
    if lower:match("^slot ") then
        local rest = strtrim(lower:match("^slot%s+(.+)") or "")
        local indexStr, profCode, objectName = rest:match("^(%d+)%s+(%S+)(?:%s+(.+))?$")
        local index = tonumber(indexStr)
        local maxSlot = SmoreSkills.MAX_SLOTS
        local owned = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
        if owned and SmoreSkills_CampSlotCount then
            maxSlot = SmoreSkills_CampSlotCount(owned)
        end
        if not index or index < 1 or index > maxSlot then
            SmoreSkills_Reply(string.format("Usage: /smores slot <1-%d> <prof> [object name]", maxSlot))
            return
        end
        if profCode == "clear" or profCode == "empty" then
            local camp, err = SmoreSkills_ClearLocalSlot(index)
            if not camp then
                SmoreSkills_Reply(err)
                return
            end
            SmoreSkills_Reply(string.format("Cleared slot %d.", index))
            if SmoreSkills.Sync:IsHosting() then
                SmoreSkills.Sync:HostHere(true)
            end
            return
        end
        local camp, err = SmoreSkills_SetLocalSlot(index, profCode, objectName)
        if not camp then
            SmoreSkills_Reply(err)
            PrintProfessions()
            return
        end
        SmoreSkills_Reply(string.format(
            "Slot %d: %s%s",
            index,
            SmoreSkills_ProfessionLabel(profCode),
            objectName and (" (" .. objectName .. ")") or ""
        ))
        if SmoreSkills.Sync:IsHosting() then
            SmoreSkills.Sync:HostHere(true)
        end
        if SmoreSkills.UI and SmoreSkills.UI.Refresh then
            SmoreSkills.UI:Refresh()
        end
        return
    end

    if SmoreSkills.Settings and SmoreSkills.Settings.Toggle then
        SmoreSkills.Settings:Toggle()
    end
end

SlashCmdList["SMORESKILLS"] = function(msg)
    SmoreSkills.forceChat = true
    local ok, err = pcall(HandleSlash, msg)
    SmoreSkills.forceChat = nil
    if not ok then
        if geterrorhandler then
            geterrorhandler()(err)
        else
            error(err)
        end
    end
end
