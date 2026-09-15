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
    if lower == "status" then
        local sync = SmoreSkills.Sync
        local chOk, chId = sync:GetChannelStatus()
        SmoreSkills_Reply("Channel: " .. (chOk and ("joined (#" .. tostring(chId) .. ")") or "NOT JOINED"))
        if sync:IsHosting() then
            local left = math.max(0, math.ceil((sync.hostingUntil or 0) - SmoreSkills_Now()))
            SmoreSkills_Reply(string.format("Hosting: yes (%ds left). Want: %s", left, SmoreSkills_FormatWant(SmoreSkills_GetEffectiveHostWant(), SmoreSkills_GetEffectiveHostWantItems())))
        else
            SmoreSkills_Reply("Hosting: no")
        end
        if sync:IsSeeking() then
            SmoreSkills_Reply(string.format("Seeking: yes (%ds left)", sync:GetSeekingRemaining()))
        else
            SmoreSkills_Reply("Seeking: no")
        end
        local profs = SmoreSkills_CollectSeekerProfessions(SmoreSkills_GetPlayerProfession())
        SmoreSkills_Reply("Your trades: " .. SmoreSkills_FormatProfessionList(profs))
        local _, _, _, zone = SmoreSkills_GetPlayerMapPos()
        SmoreSkills_Reply("Zone: " .. (zone or "?"))
        local mapId = select(1, SmoreSkills_GetPlayerMapPos())
        local layer = SmoreSkills_FormatLayer and SmoreSkills_FormatLayer(SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId(), mapId)
        if layer then
            SmoreSkills_Reply("Layer: " .. layer)
        else
            SmoreSkills_Reply("Layer: unknown (target an NPC)")
        end
        if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() and WorldMapFrame.GetMapID then
            local viewId = WorldMapFrame:GetMapID()
            local viewName = viewId
            if C_Map and C_Map.GetMapInfo and viewId then
                local info = C_Map.GetMapInfo(viewId)
                viewName = info and info.name or viewId
            end
            SmoreSkills_Reply("Map view: " .. tostring(viewName))
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
                SmoreSkills.MAX_SLOTS,
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
        if not index or index < 1 or index > SmoreSkills.MAX_SLOTS then
            SmoreSkills_Reply("Usage: /smores slot <1-3> <prof> [object name]")
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
