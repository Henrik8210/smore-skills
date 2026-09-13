SLASH_SMORESKILLS1 = "/smores"
SLASH_SMORESKILLS2 = "/sms"
SLASH_SMORESKILLS3 = "/smoreskills"

SlashCmdList["SMORESKILLS"] = function(msg)
    msg = strtrim(string.lower(msg or ""))
    if msg == "here" or msg == "share" then
        SmoreSkills.Sync:ShareHere()
        return
    end
    if msg == "ask" or msg == "sync" then
        if not IsInGuild() then
            SmoreSkills_Print("You are not in a guild.")
            return
        end
        SmoreSkills.Sync:Ask()
        SmoreSkills_Print("Asked the guild for camps they have.")
        return
    end
    if msg == "list" then
        local camps = SmoreSkills_ListCamps(SmoreSkills_PlayerFaction())
        if #camps == 0 then
            SmoreSkills_Print("No camps stored.")
            return
        end
        for _, camp in ipairs(camps) do
            SmoreSkills_Print(string.format(
                "%s (%s) %d/%d — %s",
                camp.zone or "?",
                SmoreSkills_FormatCoords(camp),
                SmoreSkills_CountFilledSlots(camp),
                SmoreSkills.MAX_SLOTS,
                SmoreSkills_FormatSlots(camp)
            ))
        end
        return
    end
    SmoreSkills.UI:Toggle()
end
