SmoreSkills = SmoreSkills or {}

-- A basic campfire holds up to three placed objects. Each player may place one.
SmoreSkills.MAX_SLOTS = 3

-- Short wire codes. Gathering is included — Herbalism incense is a camp object.
SmoreSkills.PROFESSIONS = {
    { id = "alchemy", code = "alch", label = "Alchemy", icon = "Interface\\Icons\\Trade_Alchemy" },
    { id = "blacksmithing", code = "bs", label = "Blacksmithing", icon = "Interface\\Icons\\Trade_Blacksmithing" },
    { id = "enchanting", code = "enc", label = "Enchanting", icon = "Interface\\Icons\\Trade_Engraving" },
    { id = "engineering", code = "eng", label = "Engineering", icon = "Interface\\Icons\\Trade_Engineering" },
    { id = "herbalism", code = "herb", label = "Herbalism", icon = "Interface\\Icons\\Spell_Nature_NatureTouchGrow" },
    { id = "leatherworking", code = "lw", label = "Leatherworking", icon = "Interface\\Icons\\Trade_LeatherWorking" },
    { id = "mining", code = "mine", label = "Mining", icon = "Interface\\Icons\\Trade_Mining" },
    { id = "skinning", code = "skin", label = "Skinning", icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01" },
    { id = "tailoring", code = "tail", label = "Tailoring", icon = "Interface\\Icons\\Trade_Tailoring" },
    { id = "cooking", code = "cook", label = "Cooking", icon = "Interface\\Icons\\INV_Misc_Food_15" },
    { id = "firstaid", code = "fa", label = "First Aid", icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice" },
}

local CODE_TO_PROF = {}
local ID_TO_PROF = {}
local LABEL_TO_ID = {}
local SKILL_NAME_TO_ID = {}
for _, row in ipairs(SmoreSkills.PROFESSIONS) do
    CODE_TO_PROF[row.code] = row
    ID_TO_PROF[row.id] = row
    LABEL_TO_ID[row.label:lower()] = row.id
    LABEL_TO_ID[row.id] = row.id
    LABEL_TO_ID[row.code] = row.id
    SKILL_NAME_TO_ID[row.label:lower()] = row.id
end
-- TBC profession specializations keep the base trade for matching.
local TBC_SPEC_ALIASES = {
    ["spellfire tailoring"] = "tailoring",
    ["shadoweave tailoring"] = "tailoring",
    ["mooncloth tailoring"] = "tailoring",
    ["goblin engineering"] = "engineering",
    ["gnomish engineering"] = "engineering",
    ["dragonscale leatherworking"] = "leatherworking",
    ["elemental leatherworking"] = "leatherworking",
    ["tribal leatherworking"] = "leatherworking",
}
for alias, id in pairs(TBC_SPEC_ALIASES) do
    SKILL_NAME_TO_ID[alias] = id
end

function SmoreSkills_ProfessionIdFromSkillName(skillName)
    if not skillName or skillName == "" then
        return nil
    end
    local lower = strlower(strtrim(skillName))
    if SKILL_NAME_TO_ID[lower] then
        return SKILL_NAME_TO_ID[lower]
    end
    for alias, id in pairs(TBC_SPEC_ALIASES) do
        if lower:find(alias, 1, true) then
            return id
        end
    end
    for _, row in ipairs(SmoreSkills.PROFESSIONS) do
        if lower == row.label:lower() or lower == row.id or lower == row.code then
            return row.id
        end
    end
    return nil
end

function SmoreSkills_GetPlayerProfessions()
    local list = {}
    local seen = {}
    if GetNumSkillLines then
        for i = 1, GetNumSkillLines() do
            local skillName = GetSkillLineInfo(i)
            local id = SmoreSkills_ProfessionIdFromSkillName(skillName)
            if id and not seen[id] then
                seen[id] = true
                table.insert(list, id)
            end
        end
    end
    return list
end

SmoreSkills.SIGNAL_TTL = 3 * 60
-- Classic cooking campfire lasts 5 minutes. Forever campsites may last longer — revisit on beta.
SmoreSkills.CAMPFIRE_DURATION = 5 * 60
SmoreSkills.MAX_PINS_PER_ZONE = 12

function SmoreSkills_ProfessionFromCode(code)
    return code and CODE_TO_PROF[code] or nil
end

function SmoreSkills_ProfessionFromId(id)
    return id and ID_TO_PROF[id] or nil
end

function SmoreSkills_ProfessionLabel(idOrCode)
    local row = SmoreSkills_ProfessionFromId(idOrCode) or SmoreSkills_ProfessionFromCode(idOrCode)
    return row and row.label or (idOrCode or "")
end

function SmoreSkills_ProfessionIcon(idOrCode)
    local row = SmoreSkills_ProfessionFromId(idOrCode) or SmoreSkills_ProfessionFromCode(idOrCode)
    return row and row.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function SmoreSkills_NormalizeProfession(idOrCode)
    local row = SmoreSkills_ProfessionFromId(idOrCode) or SmoreSkills_ProfessionFromCode(idOrCode)
    return row and row.id or nil
end

function SmoreSkills_GetPlayerProfession()
    local settings = SmoreSkillsDB and SmoreSkillsDB.settings
    if settings and settings.profession then
        return SmoreSkills_NormalizeProfession(settings.profession)
    end
    local profs = SmoreSkills_GetPlayerProfessions()
    return profs[1]
end

function SmoreSkills_FormatPlayerProfessions()
    local profs = SmoreSkills_GetPlayerProfessions()
    if #profs == 0 then
        return nil
    end
    local active = SmoreSkills_GetPlayerProfession()
    if #profs == 1 then
        return SmoreSkills_ProfessionLabel(profs[1])
    end
    local parts = {}
    for _, id in ipairs(profs) do
        local label = SmoreSkills_ProfessionLabel(id)
        if id == active then
            table.insert(parts, label .. " (seeking)")
        else
            table.insert(parts, label)
        end
    end
    return table.concat(parts, ", ")
end

function SmoreSkills_SetPlayerProfession(idOrCode)
    SmoreSkillsDB.settings = SmoreSkillsDB.settings or {}
    local id = SmoreSkills_NormalizeProfession(idOrCode)
    if not id then
        return false
    end
    SmoreSkillsDB.settings.profession = id
    return true
end

function SmoreSkills_EnsureSettings()
    SmoreSkillsDB.settings = SmoreSkillsDB.settings or { dataVersion = 1 }
    local s = SmoreSkillsDB.settings
    if s.hostFilterEnabled == nil then
        s.hostFilterEnabled = false
    end
    if s.seekerFilterEnabled == nil then
        s.seekerFilterEnabled = false
    end
    if (s.dataVersion or 1) < 2 then
        s.autoHostOnCampfire = true
        s.dataVersion = 2
    end
    if s.autoHostOnCampfire == nil then
        s.autoHostOnCampfire = true
    end
    if s.hostWant == nil then
        s.hostWant = "any"
    end
    if s.seekerWant == nil then
        s.seekerWant = "any"
    end
    if s.minimapAngle == nil then
        s.minimapAngle = 220
    end
    return s
end

function SmoreSkills_GetHostFilterEnabled()
    return SmoreSkills_EnsureSettings().hostFilterEnabled == true
end

function SmoreSkills_SetHostFilterEnabled(enabled)
    local s = SmoreSkills_EnsureSettings()
    s.hostFilterEnabled = enabled and true or false
    if s.hostFilterEnabled and (not s.hostWant or s.hostWant == "any") then
        s.hostWant = ""
    end
    SmoreSkills_RefreshOwnedCampWant()
end

function SmoreSkills_GetSeekerFilterEnabled()
    return SmoreSkills_EnsureSettings().seekerFilterEnabled == true
end

function SmoreSkills_SetSeekerFilterEnabled(enabled)
    local s = SmoreSkills_EnsureSettings()
    s.seekerFilterEnabled = enabled and true or false
    if s.seekerFilterEnabled and (not s.seekerWant or s.seekerWant == "any") then
        s.seekerWant = ""
    end
end

function SmoreSkills_GetAutoHostOnCampfire()
    return SmoreSkills_EnsureSettings().autoHostOnCampfire == true
end

function SmoreSkills_SetAutoHostOnCampfire(enabled)
    SmoreSkills_EnsureSettings().autoHostOnCampfire = enabled and true or false
end

function SmoreSkills_GetHostProfession()
    local s = SmoreSkills_EnsureSettings()
    local chosen = SmoreSkills_NormalizeProfession(s.hostProfession)
    local learned = SmoreSkills_GetPlayerProfessions()
    if chosen then
        if #learned == 0 then
            return chosen
        end
        for _, id in ipairs(learned) do
            if id == chosen then
                return chosen
            end
        end
    end
    if #learned > 0 then
        return learned[1]
    end
    return SmoreSkills_GetPlayerProfession()
end

function SmoreSkills_SetHostProfession(idOrCode)
    local id = SmoreSkills_NormalizeProfession(idOrCode)
    if not id then
        return false
    end
    SmoreSkills_EnsureSettings().hostProfession = id
    return true
end

function SmoreSkills_ApplyHostProfession(camp)
    if not camp then
        return camp
    end
    local prof = SmoreSkills_GetHostProfession()
    if not prof then
        return camp
    end
    SmoreSkills_EnsureSlots(camp)
    local object = camp.slots[1] and camp.slots[1].object
    SmoreSkills_SetSlot(camp, 1, camp.owner or SmoreSkills_PlayerName(), prof, object)
    return camp
end

function SmoreSkills_GetHostWant()
    local want = SmoreSkills_EnsureSettings().hostWant
    if want == nil or want == "" then
        return ""
    end
    return want
end

function SmoreSkills_GetSeekerWant()
    local want = SmoreSkills_EnsureSettings().seekerWant
    if want == nil or want == "" then
        return ""
    end
    return want
end

function SmoreSkills_GetEffectiveHostWant()
    if not SmoreSkills_GetHostFilterEnabled() then
        return "any"
    end
    local want = SmoreSkills_GetHostWant()
    if want == "" or want == "any" then
        return "none"
    end
    return want
end

function SmoreSkills_RefreshOwnedCampWant()
    local want = SmoreSkills_GetEffectiveHostWant()
    local me = SmoreSkills_PlayerName()
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if SmoreSkills_PlayerNamesMatch(camp.owner, me) then
            camp.want = want
        end
    end
end

function SmoreSkills_GetEffectiveSeekerWant()
    if not SmoreSkills_GetSeekerFilterEnabled() then
        return "any"
    end
    local want = SmoreSkills_GetSeekerWant()
    if want == "" or want == "any" then
        return "none"
    end
    return want
end

function SmoreSkills_SetHostWant(want)
    SmoreSkillsDB.settings = SmoreSkillsDB.settings or {}
    want = strlower(strtrim(want or ""))
    if want == "" or want == "any" then
        SmoreSkillsDB.settings.hostWant = "any"
        return true
    end
    local codes = {}
    for token in string.gmatch(want, "[^,%s]+") do
        local id = SmoreSkills_NormalizeProfession(token)
        if not id then
            return false
        end
        local row = SmoreSkills_ProfessionFromId(id)
        table.insert(codes, row.code)
    end
    if #codes == 0 then
        return false
    end
    SmoreSkillsDB.settings.hostWant = table.concat(codes, ",")
    return true
end

function SmoreSkills_SetSeekerWant(want)
    SmoreSkillsDB.settings = SmoreSkillsDB.settings or {}
    want = strlower(strtrim(want or ""))
    if want == "" or want == "any" then
        SmoreSkillsDB.settings.seekerWant = "any"
        return true
    end
    local codes = {}
    for token in string.gmatch(want, "[^,%s]+") do
        local id = SmoreSkills_NormalizeProfession(token)
        if not id then
            return false
        end
        local row = SmoreSkills_ProfessionFromId(id)
        table.insert(codes, row.code)
    end
    if #codes == 0 then
        return false
    end
    SmoreSkillsDB.settings.seekerWant = table.concat(codes, ",")
    return true
end

function SmoreSkills_WantHasProfession(wantKey, profId)
    local want = wantKey == "seekerWant" and SmoreSkills_GetSeekerWant() or SmoreSkills_GetHostWant()
    if not want or want == "" or want == "any" then
        return false
    end
    return SmoreSkills_WantAccepts(want, profId)
end

function SmoreSkills_ToggleWantProfession(wantKey, profId)
    SmoreSkills_EnsureSettings()
    local row = SmoreSkills_ProfessionFromId(profId)
    if not row then
        return false
    end
    local want = wantKey == "seekerWant" and SmoreSkills_GetSeekerWant() or SmoreSkills_GetHostWant()
    local codes = {}
    local found = false
    if want and want ~= "" and want ~= "any" then
        for token in string.gmatch(want, "[^,]+") do
            if token == row.code or token == row.id then
                found = true
            else
                table.insert(codes, token)
            end
        end
    end
    if not found then
        table.insert(codes, row.code)
    end
    if wantKey == "seekerWant" then
        SmoreSkillsDB.settings.seekerWant = #codes > 0 and table.concat(codes, ",") or ""
    else
        SmoreSkillsDB.settings.hostWant = #codes > 0 and table.concat(codes, ",") or ""
        SmoreSkills_RefreshOwnedCampWant()
    end
    return true
end

function SmoreSkills_FormatWant(want)
    if not want or want == "any" then
        return "Anyone"
    end
    if want == "none" or want == "" then
        return "None selected"
    end
    local labels = {}
    for token in string.gmatch(want, "[^,]+") do
        local id = SmoreSkills_NormalizeProfession(token)
        table.insert(labels, SmoreSkills_ProfessionLabel(id or token))
    end
    return table.concat(labels, ", ")
end

function SmoreSkills_WantAccepts(want, professionId)
    want = want or "any"
    if want == "any" then
        return true
    end
    if want == "none" or want == "" then
        return false
    end
    if not professionId then
        return false
    end
    local prof = SmoreSkills_ProfessionFromId(professionId)
    if not prof then
        return false
    end
    for token in string.gmatch(want, "[^,]+") do
        if token == prof.code or token == prof.id then
            return true
        end
    end
    return false
end

function SmoreSkills_CollectSeekerProfessions(primary)
    local seen = {}
    local list = {}
    local function add(id)
        id = SmoreSkills_NormalizeProfession(id)
        if id and not seen[id] then
            seen[id] = true
            table.insert(list, id)
        end
    end
    add(primary)
    add(SmoreSkills_GetPlayerProfession())
    for _, id in ipairs(SmoreSkills_GetPlayerProfessions()) do
        add(id)
    end
    return list
end

function SmoreSkills_WantAcceptsAny(want, professionOrList)
    if type(professionOrList) ~= "table" then
        return SmoreSkills_WantAccepts(want, professionOrList)
    end
    if (want or "any") == "any" then
        return true
    end
    if #professionOrList == 0 then
        return SmoreSkills_WantAccepts(want, nil)
    end
    for _, id in ipairs(professionOrList) do
        if SmoreSkills_WantAccepts(want, id) then
            return true
        end
    end
    return false
end

function SmoreSkills_FormatProfessionList(professionOrList)
    if type(professionOrList) ~= "table" then
        local label = SmoreSkills_ProfessionLabel(professionOrList)
        return label ~= "" and label or "no profession"
    end
    if #professionOrList == 0 then
        return "no profession"
    end
    local labels = {}
    for _, id in ipairs(professionOrList) do
        table.insert(labels, SmoreSkills_ProfessionLabel(id))
    end
    return table.concat(labels, ", ")
end

function SmoreSkills_CountEmptySlots(camp)
    return SmoreSkills.MAX_SLOTS - SmoreSkills_CountFilledSlots(camp)
end

function SmoreSkills_HostMatchesSeeker(host, mapId, seekerProfession)
    if not host or not mapId then
        return false
    end
    if host.faction and host.faction ~= SmoreSkills_PlayerFaction() then
        return false
    end
    if host.mapId ~= mapId then
        return false
    end
    if SmoreSkills_CountEmptySlots(host) < 1 then
        return false
    end
    local hostWant = host.want or "any"
    return SmoreSkills_WantAcceptsAny(hostWant, seekerProfession)
end

function SmoreSkills_SeekerWantsCamp(camp, seekerWant)
    if not seekerWant or seekerWant == "any" then
        return true
    end
    if seekerWant == "none" or seekerWant == "" then
        return false
    end
    SmoreSkills_EnsureSlots(camp)
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        if slot and slot.profession and SmoreSkills_WantAccepts(seekerWant, slot.profession) then
            return true
        end
    end
    local hostWant = camp.want or "any"
    if hostWant ~= "any" and hostWant ~= "none" and hostWant ~= "" then
        for token in string.gmatch(seekerWant, "[^,]+") do
            local id = SmoreSkills_NormalizeProfession(token)
            if id and SmoreSkills_WantAccepts(hostWant, id) then
                return true
            end
        end
    end
    return false
end

function SmoreSkills_CampPinActive(camp)
    if not camp then
        return false
    end
    if SmoreSkills_CountEmptySlots(camp) < 1 then
        return false
    end
    if camp.packed then
        return false
    end
    local lit = tonumber(camp.litAt) or tonumber(camp.updatedAt) or 0
    return (SmoreSkills_Now() - lit) < (SmoreSkills.CAMPFIRE_DURATION or 300)
end

function SmoreSkills_CampVisibleToSeeker(camp, mapId, seekerProfession)
    if not camp then
        return false
    end
    if not SmoreSkills_CampPinActive(camp) then
        return false
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        return true
    end
    if not mapId then
        return false
    end
    if not SmoreSkills_HostMatchesSeeker(camp, mapId, seekerProfession) then
        return false
    end
    return SmoreSkills_SeekerWantsCamp(camp, SmoreSkills_GetEffectiveSeekerWant())
end

local function EmptySlots()
    local slots = {}
    for i = 1, SmoreSkills.MAX_SLOTS do
        slots[i] = { index = i }
    end
    return slots
end

function SmoreSkills_CampId(mapId, x, y)
    return string.format("%d:%.3f:%.3f", tonumber(mapId) or 0, tonumber(x) or 0, tonumber(y) or 0)
end

function SmoreSkills_GetPlayerMapPos()
    if not C_Map or not C_Map.GetBestMapForUnit then
        return nil
    end
    local mapId = C_Map.GetBestMapForUnit("player")
    if not mapId then
        return nil
    end
    local pos = C_Map.GetPlayerMapPosition(mapId, "player")
    if not pos then
        return nil
    end
    local x, y = pos:GetXY()
    if not x or not y or (x == 0 and y == 0) then
        return nil
    end
    mapId, x, y = SmoreSkills_ResolveZoneMap(mapId, x, y)
    if not mapId or not x or not y then
        return nil
    end
    return mapId, x, y, GetRealZoneText() or GetZoneText() or "Unknown"
end

local function MapTypeZone()
    return (Enum and Enum.UIMapType and Enum.UIMapType.Zone) or 3
end

function SmoreSkills_ResolveZoneMap(mapId, x, y)
    mapId = tonumber(mapId)
    if not mapId then
        return mapId, x, y
    end
    local info = C_Map.GetMapInfo and C_Map.GetMapInfo(mapId)
    local mapType = info and info.mapType
    if mapType and mapType >= MapTypeZone() then
        return mapId, x, y
    end
    if C_Map.GetMapInfoAtPosition and x and y then
        local child = C_Map.GetMapInfoAtPosition(mapId, x, y)
        if child and child.mapID and child.mapID ~= mapId then
            local pos = C_Map.GetPlayerMapPosition(child.mapID, "player")
            if pos then
                local cx, cy = pos:GetXY()
                if cx and cy and not (cx == 0 and cy == 0) then
                    return child.mapID, cx, cy
                end
            end
        end
    end
    if C_Map.GetMapChildrenInfo then
        local kids = C_Map.GetMapChildrenInfo(mapId, MapTypeZone(), true)
        if kids then
            for i = 1, #kids do
                local child = kids[i]
                if child and child.mapID then
                    local pos = C_Map.GetPlayerMapPosition(child.mapID, "player")
                    if pos then
                        local cx, cy = pos:GetXY()
                        if cx and cy and not (cx == 0 and cy == 0) then
                            return child.mapID, cx, cy
                        end
                    end
                end
            end
        end
    end
    return mapId, x, y
end

local function MakeMapVector(x, y)
    if CreateVector2D then
        return CreateVector2D(x, y)
    end
    return { x = x, y = y, GetXY = function(self) return self.x, self.y end }
end

function SmoreSkills_CampPinPosOnMap(camp, viewMapId)
    if not camp then
        return nil
    end
    viewMapId = tonumber(viewMapId)
    local x, y = tonumber(camp.x), tonumber(camp.y)
    if not x or not y then
        return nil
    end
    local campMapId = tonumber(camp.mapId)
    if not viewMapId or viewMapId == campMapId then
        return x, y
    end
    if SmoreSkills_TranslateMapPos then
        local tx, ty = SmoreSkills_TranslateMapPos(camp.mapId, x, y, viewMapId)
        if tx and ty then
            return tx, ty
        end
    end
    local playerMapId = select(1, SmoreSkills_GetPlayerMapPos())
    if playerMapId and tonumber(playerMapId) == campMapId then
        return x, y
    end
    -- Last resort: zone coords on this canvas. The map widget sometimes reports
    -- Stormwind City while still drawing Elwynn Forest (city in the corner).
    return x, y
end

function SmoreSkills_TranslateMapPos(fromMapId, x, y, toMapId)
    fromMapId = tonumber(fromMapId)
    toMapId = tonumber(toMapId)
    x = tonumber(x)
    y = tonumber(y)
    if not fromMapId or not toMapId or not x or not y then
        return nil
    end
    if fromMapId == toMapId then
        return x, y
    end
    if C_Map.GetWorldPosFromMapPos and C_Map.GetMapPosFromWorldPos then
        local continentId, worldPos = C_Map.GetWorldPosFromMapPos(fromMapId, MakeMapVector(x, y))
        if continentId and worldPos then
            local _, mapPos = C_Map.GetMapPosFromWorldPos(continentId, worldPos, toMapId)
            if mapPos then
                local nx, ny
                if mapPos.GetXY then
                    nx, ny = mapPos:GetXY()
                else
                    nx, ny = mapPos.x, mapPos.y
                end
                if nx and ny and nx >= -0.15 and nx <= 1.15 and ny >= -0.15 and ny <= 1.15 then
                    return nx, ny
                end
            end
        end
    end
    if C_Map.GetMapRectOnMap then
        local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(fromMapId, toMapId)
        if minX and maxX and minY and maxY then
            return minX + x * (maxX - minX), minY + y * (maxY - minY)
        end
    end
    return nil
end

function SmoreSkills_EnsureSlots(camp)
    camp.slots = camp.slots or EmptySlots()
    for i = 1, SmoreSkills.MAX_SLOTS do
        camp.slots[i] = camp.slots[i] or { index = i }
        camp.slots[i].index = i
    end
    return camp.slots
end

function SmoreSkills_CountFilledSlots(camp)
    local n = 0
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots and camp.slots[i]
        if slot and (slot.profession or slot.player or slot.object) then
            n = n + 1
        end
    end
    return n
end

function SmoreSkills_UpsertCamp(incoming)
    if not incoming or not incoming.mapId then
        return nil
    end
    SmoreSkillsDB.camps = SmoreSkillsDB.camps or {}
    local id = incoming.id or SmoreSkills_CampId(incoming.mapId, incoming.x, incoming.y)
    local existing = SmoreSkillsDB.camps[id]
    if existing and (incoming.updatedAt or 0) < (existing.updatedAt or 0) then
        return existing
    end
    incoming.id = id
    incoming.slots = incoming.slots or (existing and existing.slots) or EmptySlots()
    incoming.zone = incoming.zone or (existing and existing.zone)
    incoming.want = incoming.want or (existing and existing.want)
    if existing and existing.source == "host" and incoming.source ~= "host" then
        incoming.source = existing.source
    end
    incoming.source = incoming.source or (existing and existing.source)
    SmoreSkills_EnsureSlots(incoming)
    incoming.updatedAt = incoming.updatedAt or SmoreSkills_Now()
    incoming.litAt = incoming.litAt or (existing and existing.litAt) or incoming.updatedAt
    if existing and existing.packed then
        -- A later host ping from a re-host can revive; anything stamped at or before pack stays packed.
        if (incoming.updatedAt or 0) <= (existing.packedAt or 0) then
            incoming.packed = true
            incoming.packedAt = existing.packedAt
        end
    end
    SmoreSkillsDB.camps[id] = incoming
    return incoming
end

function SmoreSkills_GetOwnedActiveCamp()
    local me = SmoreSkills_PlayerName()
    local best = nil
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if SmoreSkills_PlayerNamesMatch(camp.owner, me) and SmoreSkills_CampPinActive(camp) then
            if not best or (camp.litAt or 0) > (best.litAt or 0) then
                best = camp
            end
        end
    end
    return best
end

function SmoreSkills_GetLocalCamp()
    local mapId, x, y = SmoreSkills_GetPlayerMapPos()
    if not mapId then
        return nil
    end
    local id = SmoreSkills_CampId(mapId, x, y)
    return SmoreSkillsDB.camps and SmoreSkillsDB.camps[id] or nil
end

function SmoreSkills_MarkHere(slots)
    local mapId, x, y, zone = SmoreSkills_GetPlayerMapPos()
    if not mapId then
        return nil, "No map coordinates (leave an instance or wait for the map)."
    end
    local data = {
        mapId = mapId,
        x = x,
        y = y,
        zone = zone,
        faction = SmoreSkills_PlayerFaction(),
        owner = SmoreSkills_PlayerName(),
        updatedAt = SmoreSkills_Now(),
    }
    if slots then
        data.slots = slots
    end
    return SmoreSkills_UpsertCamp(data)
end

function SmoreSkills_SetLocalSlot(index, profession, object)
    local camp, err = SmoreSkills_MarkHere()
    if not camp then
        return nil, err
    end
    local profId = SmoreSkills_NormalizeProfession(profession)
    if not profId then
        return nil, "Unknown profession."
    end
    SmoreSkills_SetSlot(camp, index, SmoreSkills_PlayerName(), profId, object)
    return camp
end

function SmoreSkills_ClearLocalSlot(index)
    local camp, err = SmoreSkills_MarkHere()
    if not camp then
        return nil, err
    end
    SmoreSkills_EnsureSlots(camp)
    camp.slots[index] = { index = index }
    camp.updatedAt = SmoreSkills_Now()
    return camp
end

function SmoreSkills_SetSlot(camp, index, player, profession, object)
    if not camp or not index or index < 1 or index > SmoreSkills.MAX_SLOTS then
        return false
    end
    SmoreSkills_EnsureSlots(camp)
    camp.slots[index] = {
        index = index,
        player = player,
        profession = profession,
        object = object,
    }
    camp.updatedAt = SmoreSkills_Now()
    return true
end

function SmoreSkills_ListCamps(faction, mapId)
    local list = {}
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if (not faction or camp.faction == faction) and (not mapId or camp.mapId == mapId) then
            table.insert(list, camp)
        end
    end
    table.sort(list, function(a, b)
        local za, zb = a.zone or "", b.zone or ""
        if za ~= zb then
            return za < zb
        end
        return (a.updatedAt or 0) > (b.updatedAt or 0)
    end)
    if mapId and #list > SmoreSkills.MAX_PINS_PER_ZONE then
        while #list > SmoreSkills.MAX_PINS_PER_ZONE do
            table.remove(list)
        end
    end
    return list
end

function SmoreSkills_TestCampsEnabled()
    if SmoreSkillsDB.settings and SmoreSkillsDB.settings.testCamps == false then
        return false
    end
    return SmoreSkills.ENABLE_TEST_CAMPS ~= false
end

function SmoreSkills_IsAshenvale(mapId, zone)
    if mapId == 331 then
        return true
    end
    if zone and strlower(zone):find("ashenvale", 1, true) then
        return true
    end
    return false
end

local function SmoreSkills_ClearTestCamps()
    for id, camp in pairs(SmoreSkillsDB.camps or {}) do
        if camp.owner == "TestCamper" then
            SmoreSkillsDB.camps[id] = nil
            if SmoreSkills.Sync and SmoreSkills.Sync.seekDiscoveredIds then
                SmoreSkills.Sync.seekDiscoveredIds[id] = nil
            end
        end
    end
end

function SmoreSkills_GetTestCampCoords()
    SmoreSkillsDB.settings = SmoreSkillsDB.settings or {}
    local settings = SmoreSkillsDB.settings
    if settings.testCampX and settings.testCampY then
        return settings.testCampX, settings.testCampY
    end
    local hash = 0
    local name = UnitName("player") or "camper"
    for i = 1, #name do
        hash = (hash * 31 + string.byte(name, i)) % 100000
    end
    local x = 0.18 + (hash % 640) / 1000
    local y = 0.18 + ((hash * 17) % 640) / 1000
    settings.testCampX = x
    settings.testCampY = y
    return x, y
end

function SmoreSkills_SeedTestCamp(mapId, zone)
    if not SmoreSkills_TestCampsEnabled() then
        return nil
    end
    if not SmoreSkills_IsAshenvale(mapId, zone) then
        return nil
    end
    SmoreSkills_ClearTestCamps()
    local x, y = SmoreSkills_GetTestCampCoords()
    local camp = SmoreSkills_UpsertCamp({
        mapId = mapId or 331,
        x = x,
        y = y,
        zone = zone or "Ashenvale",
        faction = SmoreSkills_PlayerFaction(),
        owner = "TestCamper",
        want = SmoreSkills_GetEffectiveHostWant(),
        source = "host",
        updatedAt = SmoreSkills_Now(),
    })
    SmoreSkills_SetSlot(camp, 1, "TestCamper", "blacksmithing", "Anvil")
    return camp
end

local function SmoreSkills_MaybeAddVisibleCamp(list, seen, camp, mapId, seekerProfession)
    if not camp or not camp.id or seen[camp.id] then
        return
    end
    if camp.faction and camp.faction ~= SmoreSkills_PlayerFaction() then
        return
    end
    if mapId and camp.mapId ~= mapId then
        if not SmoreSkills_TranslateMapPos(camp.mapId, camp.x, camp.y, mapId) then
            -- WoW sometimes reports Stormwind City while the canvas is still Elwynn.
            -- Keep the camp if the seeker is standing in that zone.
            local playerMapId = select(1, SmoreSkills_GetPlayerMapPos())
            if tonumber(playerMapId) ~= tonumber(camp.mapId) then
                local sync = SmoreSkills.Sync
                local discovered = sync and sync.seekDiscoveredIds and camp.id and sync.seekDiscoveredIds[camp.id]
                if not discovered then
                    return
                end
            end
        end
    end
    if not SmoreSkills_CampVisibleToSeeker(camp, camp.mapId, seekerProfession) then
        return
    end
    table.insert(list, camp)
    seen[camp.id] = true
end

function SmoreSkills_ListVisibleCamps(mapId)
    local seekerProfession = SmoreSkills_CollectSeekerProfessions(SmoreSkills_GetPlayerProfession())
    local list = {}
    local seen = {}
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        SmoreSkills_MaybeAddVisibleCamp(list, seen, camp, mapId, seekerProfession)
    end
    local sync = SmoreSkills.Sync
    local discoveries = sync and sync.seekDiscoveredIds
    if discoveries then
        for id in pairs(discoveries) do
            SmoreSkills_MaybeAddVisibleCamp(list, seen, SmoreSkillsDB.camps and SmoreSkillsDB.camps[id], mapId, seekerProfession)
        end
    end
    table.sort(list, function(a, b)
        local za, zb = a.zone or "", b.zone or ""
        if za ~= zb then
            return za < zb
        end
        return (a.updatedAt or 0) > (b.updatedAt or 0)
    end)
    if mapId and #list > SmoreSkills.MAX_PINS_PER_ZONE then
        while #list > SmoreSkills.MAX_PINS_PER_ZONE do
            table.remove(list)
        end
    end
    return list
end

function SmoreSkills_ListMatchedCamps(mapId, seekerProfession)
    if not mapId then
        return {}
    end
    local list = {}
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if SmoreSkills_CampVisibleToSeeker(camp, mapId, seekerProfession) then
            table.insert(list, camp)
        end
    end
    table.sort(list, function(a, b)
        return (a.updatedAt or 0) > (b.updatedAt or 0)
    end)
    if #list > SmoreSkills.MAX_PINS_PER_ZONE then
        while #list > SmoreSkills.MAX_PINS_PER_ZONE do
            table.remove(list)
        end
    end
    return list
end

function SmoreSkills_ForgetStaleCamps(maxAge)
    maxAge = maxAge or (30 * 60)
    local now = SmoreSkills_Now()
    for id, camp in pairs(SmoreSkillsDB.camps or {}) do
        if (now - (camp.updatedAt or 0)) > maxAge then
            SmoreSkillsDB.camps[id] = nil
            if SmoreSkills.Sync and SmoreSkills.Sync.seekDiscoveredIds then
                SmoreSkills.Sync.seekDiscoveredIds[id] = nil
            end
        end
    end
end

function SmoreSkills_IsGuildie(name)
    if not name or name == "" or not IsInGuild then
        return false
    end
    if not IsInGuild() then
        return false
    end
    if SmoreSkills_PlayerNamesMatch(name, SmoreSkills_PlayerName()) then
        return true
    end
    if UnitIsInMyGuild and UnitIsInMyGuild(name) then
        return true
    end
    local n = GetNumGuildMembers and GetNumGuildMembers() or 0
    for i = 1, n do
        local gname = GetGuildRosterInfo(i)
        if gname then
            if Ambiguate then
                gname = Ambiguate(gname, "guild")
            else
                gname = strsplit("-", gname)
            end
            if SmoreSkills_PlayerNamesMatch(gname, name) then
                return true
            end
        end
    end
    return false
end

function SmoreSkills_CampHasGuildie(camp)
    if not camp then
        return false
    end
    if SmoreSkills_IsGuildie(camp.owner) then
        return true
    end
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots and camp.slots[i]
        if slot and SmoreSkills_IsGuildie(slot.player) then
            return true
        end
    end
    return false
end

function SmoreSkills_FormatCoords(camp)
    if not camp or not camp.x or not camp.y then
        return "?"
    end
    return string.format("%.1f, %.1f", camp.x * 100, camp.y * 100)
end

function SmoreSkills_FormatSlotTooltipLine(camp, index)
    SmoreSkills_EnsureSlots(camp)
    local slot = camp.slots[index]
    if index == 1 then
        if slot and slot.profession then
            local line = "Host: " .. SmoreSkills_ProfessionLabel(slot.profession)
            if slot.object and slot.object ~= "" then
                line = line .. " (" .. slot.object .. ")"
            end
            if slot.player and slot.player ~= "" then
                line = line .. " — " .. slot.player
            elseif camp.owner and camp.owner ~= "" then
                line = line .. " — " .. camp.owner
            end
            return line
        end
        return "Host: " .. (camp.owner or "Unknown")
    end
    local spot = index
    if slot and slot.profession then
        local line = string.format("Spot %d: %s", spot, SmoreSkills_ProfessionLabel(slot.profession))
        if slot.object and slot.object ~= "" then
            line = line .. " (" .. slot.object .. ")"
        end
        if slot.player and slot.player ~= "" then
            line = line .. " — " .. slot.player
        end
        return line
    end
    return string.format("Spot %d: Open", spot)
end

function SmoreSkills_FormatSlots(camp)
    SmoreSkills_EnsureSlots(camp)
    local parts = {}
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        if slot and slot.profession then
            local label = SmoreSkills_ProfessionLabel(slot.profession)
            if slot.object and slot.object ~= "" then
                table.insert(parts, string.format("%s (%s)", label, slot.object))
            else
                table.insert(parts, label)
            end
        else
            table.insert(parts, "empty")
        end
    end
    return table.concat(parts, " · ")
end
