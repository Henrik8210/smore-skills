SmoreSkills = SmoreSkills or {}

-- A basic campfire holds up to three placed objects. Each player may place one.
SmoreSkills.MAX_SLOTS = 3

-- Short wire codes. Gathering is included — Herbalism incense is a camp object.
SmoreSkills.PROFESSIONS = {
    { id = "alchemy", code = "alch", label = "Alchemy" },
    { id = "blacksmithing", code = "bs", label = "Blacksmithing" },
    { id = "enchanting", code = "enc", label = "Enchanting" },
    { id = "engineering", code = "eng", label = "Engineering" },
    { id = "herbalism", code = "herb", label = "Herbalism" },
    { id = "leatherworking", code = "lw", label = "Leatherworking" },
    { id = "mining", code = "mine", label = "Mining" },
    { id = "skinning", code = "skin", label = "Skinning" },
    { id = "tailoring", code = "tail", label = "Tailoring" },
    { id = "cooking", code = "cook", label = "Cooking" },
    { id = "firstaid", code = "fa", label = "First Aid" },
}

local CODE_TO_PROF = {}
local ID_TO_PROF = {}
for _, row in ipairs(SmoreSkills.PROFESSIONS) do
    CODE_TO_PROF[row.code] = row
    ID_TO_PROF[row.id] = row
end

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
    return mapId, x, y, GetRealZoneText() or GetZoneText() or "Unknown"
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
    SmoreSkills_EnsureSlots(incoming)
    incoming.updatedAt = incoming.updatedAt or SmoreSkills_Now()
    SmoreSkillsDB.camps[id] = incoming
    return incoming
end

function SmoreSkills_MarkHere(slots)
    local mapId, x, y, zone = SmoreSkills_GetPlayerMapPos()
    if not mapId then
        return nil, "No map coordinates (leave an instance or wait for the map)."
    end
    local camp = SmoreSkills_UpsertCamp({
        mapId = mapId,
        x = x,
        y = y,
        zone = zone,
        faction = SmoreSkills_PlayerFaction(),
        owner = SmoreSkills_PlayerName(),
        slots = slots or EmptySlots(),
        updatedAt = SmoreSkills_Now(),
    })
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

function SmoreSkills_ListCamps(faction)
    local list = {}
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if not faction or camp.faction == faction then
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
    return list
end

function SmoreSkills_ForgetStaleCamps(maxAge)
    maxAge = maxAge or (30 * 60)
    local now = SmoreSkills_Now()
    for id, camp in pairs(SmoreSkillsDB.camps or {}) do
        if (now - (camp.updatedAt or 0)) > maxAge then
            SmoreSkillsDB.camps[id] = nil
        end
    end
end

function SmoreSkills_FormatCoords(camp)
    if not camp or not camp.x or not camp.y then
        return "?"
    end
    return string.format("%.1f, %.1f", camp.x * 100, camp.y * 100)
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
