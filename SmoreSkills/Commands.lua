SLASH_SMORESKILLS1 = "/smores"
SLASH_SMORESKILLS2 = "/sms"
SLASH_SMORESKILLS3 = "/smoreskills"

local function PrintProfessions()
    local parts = {}
    for _, row in ipairs(SmoreSkills.PROFESSIONS) do
        table.insert(parts, row.code)
    end
    SmoreSkills_Print("Professions: " .. table.concat(parts, ", "))
end

SlashCmdList["SMORESKILLS"] = function(msg)
    msg = strtrim(msg or "")
    local lower = strlower(msg)

    if lower == "here" or lower == "share" then
        SmoreSkills.Sync:ShareHere()
        return
    end
    if lower == "find" or lower == "seek" then
        SmoreSkills.Sync:SeekHere()
        return
    end
    if lower == "host" then
        SmoreSkills.Sync:HostHere()
        return
    end
    if lower == "stop" then
        SmoreSkills.Sync:StopHosting()
        SmoreSkills_Print("Stopped hosting.")
        return
    end
    if lower == "test" then
        local enabled = SmoreSkills_TestCampsEnabled()
        SmoreSkills_Print("Test camps: " .. (enabled and "on" or "off") .. " (/smores test on | off)")
        return
    end
    if lower == "test on" then
        SmoreSkillsDB.settings = SmoreSkillsDB.settings or {}
        SmoreSkillsDB.settings.testCamps = true
        SmoreSkills_Print("Test camps enabled (Ashenvale sample on seek).")
        return
    end
    if lower == "test off" then
        SmoreSkillsDB.settings = SmoreSkillsDB.settings or {}
        SmoreSkillsDB.settings.testCamps = false
        SmoreSkills_Print("Test camps disabled.")
        return
    end
    if lower == "list" then
        local mapId = select(1, SmoreSkills_GetPlayerMapPos())
        local camps = SmoreSkills_ListVisibleCamps(mapId)
        if #camps == 0 then
            SmoreSkills_Print("No camps stored.")
            return
        end
        for _, camp in ipairs(camps) do
            local guildMark = SmoreSkills_CampHasGuildie(camp) and " [guild] " or " "
            local tag = camp.source == "host" and "[host] " or ""
            SmoreSkills_Print(string.format(
                "%s%s%s(%s) %d/%d — %s",
                tag,
                camp.zone or "?",
                guildMark,
                SmoreSkills_FormatCoords(camp),
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
            SmoreSkills_Print("Detected: " .. table.concat(detected, ", "))
        end
        if current then
            SmoreSkills_Print("Seeking as: " .. SmoreSkills_ProfessionLabel(current) .. " (/smores prof <code> to change)")
        else
            SmoreSkills_Print("No seek profession set. /smores prof <code>")
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
            SmoreSkills_Print("Profession set to " .. SmoreSkills_ProfessionLabel(code) .. ".")
        else
            SmoreSkills_Print("Unknown profession. Try: lw, bs, tail, …")
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
        SmoreSkills_Print("Host want list: " .. SmoreSkills_FormatWant(SmoreSkills_GetEffectiveHostWant()) .. " (/smores want any | bs,lw, …)")
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
            SmoreSkills_Print("Host want list: " .. SmoreSkills_FormatWant(SmoreSkills_GetEffectiveHostWant()))
        else
            SmoreSkills_Print("Unknown profession in want list.")
            PrintProfessions()
        end
        return
    end
    if lower:match("^slot ") then
        local rest = strtrim(lower:match("^slot%s+(.+)") or "")
        local indexStr, profCode, objectName = rest:match("^(%d+)%s+(%S+)(?:%s+(.+))?$")
        local index = tonumber(indexStr)
        if not index or index < 1 or index > SmoreSkills.MAX_SLOTS then
            SmoreSkills_Print("Usage: /smores slot <1-3> <prof> [object name]")
            return
        end
        if profCode == "clear" or profCode == "empty" then
            local camp, err = SmoreSkills_ClearLocalSlot(index)
            if not camp then
                SmoreSkills_Print(err)
                return
            end
            SmoreSkills_Print(string.format("Cleared slot %d.", index))
            if SmoreSkills.Sync:IsHosting() then
                SmoreSkills.Sync:HostHere()
            end
            return
        end
        local camp, err = SmoreSkills_SetLocalSlot(index, profCode, objectName)
        if not camp then
            SmoreSkills_Print(err)
            PrintProfessions()
            return
        end
        SmoreSkills_Print(string.format(
            "Slot %d: %s%s",
            index,
            SmoreSkills_ProfessionLabel(profCode),
            objectName and (" (" .. objectName .. ")") or ""
        ))
        if SmoreSkills.Sync:IsHosting() then
            SmoreSkills.Sync:HostHere()
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
