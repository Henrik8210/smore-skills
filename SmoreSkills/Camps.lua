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
    { id = "fishing", code = "fish", label = "Fishing", icon = "Interface\\Icons\\Trade_Fishing" },
}

-- Confirmed Forever camping objects (Wowhead shared-cooldown with Mana Well, 36 item IDs).
-- Faction Banner is two items (Horde 279972 / Alliance 279973); we show one row.
-- No placeholders. Cooking has no skill-20 camping object (the kit is the fire).
-- icon: Wowhead file; itemId: live GetItemInfo* / C_Item on Forever.
SmoreSkills.PROFESSION_ITEMS = {
    { id = "alch1", profession = "alchemy", label = "Mana Well", itemId = 279956, icon = "Interface\\Icons\\Spell_Arcane_ManaTap", unlock = "Alchemy 20", note = "+10 mana / 5s", skill = "Alchemy (20)", reagents = "Peacebloom, Empty Vial", use = "Constructs a mana well that allows you and others sitting nearby to regenerate 10 Mana every 5 seconds, exclusive with Blessing of Wisdom.", exclusive = "Blessing of Wisdom" },
    { id = "alch2", profession = "alchemy", label = "Fermenter", itemId = 279970, icon = "Interface\\Icons\\INV_Alchemy_90_Cauldron", unlock = "Alchemy 140", note = "Reagents + well", skill = "Alchemy (140)", use = "Places a fermenter that allows the creation of certain reagents, and provides all of the benefits of a Mana Well. May replace a Mana Well." },
    { id = "alch3", profession = "alchemy", label = "Alchemy Laboratory", itemId = 279990, icon = "Interface\\Icons\\10Prof_PortableTable_Alchemy01", unlock = "Alchemy 300", note = "Station + well", skill = "Alchemy (300)", use = "Places an Alchemy Laboratory usable for recipes that require it, and provides all of the benefits of a Mana Well. May replace a Mana Well." },
    { id = "bs1", profession = "blacksmithing", label = "Sharpening Wheel", itemId = 279944, icon = "Interface\\Icons\\INV_Stone_GrindingStone_01", unlock = "Blacksmithing 20", note = "+6 Strength", skill = "Blacksmithing (20)", reagents = "Rough Stone, Copper Bar", use = "Constructs a sharpening wheel that grants you and others sitting nearby 6 increased Strength, exclusive with Strength of Earth Totem.", exclusive = "Strength of Earth Totem" },
    { id = "bs2", profession = "blacksmithing", label = "Anvil", itemId = 279988, icon = "Interface\\Icons\\INV_Blacksmith_Anvil", unlock = "Blacksmithing 140", note = "Replaces wheel", skill = "Blacksmithing (140)", use = "Places an anvil with all Sharpening Wheel benefits. May replace a wheel." },
    { id = "bs3", profession = "blacksmithing", label = "Master Forge", itemId = 279955, icon = "Interface\\Icons\\INV_Mace_1H_Blacksmithing_B_01_Black", unlock = "Blacksmithing 300", note = "Crafting + wheel", skill = "Blacksmithing (300)", use = "Usable for recipes that require it, plus all wheel benefits. May replace a wheel." },
    { id = "enc1", profession = "enchanting", label = "Enchanted Lute", itemId = 279976, icon = "Interface\\Icons\\INV_10_Enchanting2_MagicSwirl_Bronze", unlock = "Enchanting 20", note = "+28 Armor", skill = "Enchanting (20)", reagents = "Simple Wood, Strange Dust", use = "Summons an enchanted lute that allows you and others sitting nearby to gain 28 Increase to Armor, exclusive with Mark of the Wild.", exclusive = "Mark of the Wild" },
    { id = "enc2", profession = "enchanting", label = "Arcane Salvager", itemId = 279985, icon = "Interface\\Icons\\INV_Eng_BottledElements", unlock = "Enchanting 140", note = "Disenchant + lute", skill = "Enchanting (140)", use = "Places an Arcane Salvager that enables more efficient disenchanting, and provides all the benefits of an Enchanted Lute. May replace a lute." },
    { id = "enc3", profession = "enchanting", label = "Arcane Forge", itemId = 279987, icon = "Interface\\Icons\\INV_Enchanting_ModifiedCraftingReagent_Indigo", unlock = "Enchanting 300", note = "Station + lute", skill = "Enchanting (300)", use = "Places an Arcane Forge usable for recipes that require it, and provides all the benefits of an Enchanted Lute. May replace a lute." },
    { id = "eng1", profession = "engineering", label = "Reagent Bot", itemId = 279950, icon = "Interface\\Icons\\INV_Misc_EngGizmos_13", unlock = "Engineering 20", note = "Reagent vendor", skill = "Engineering (20)", use = "Summons a Reagent Bot that allows you and others nearby to purchase reagents." },
    { id = "eng2", profession = "engineering", label = "Repair Bot", itemId = 279949, icon = "Interface\\Icons\\INV_RobotPet", unlock = "Engineering 140", note = "Vendor + repair", skill = "Engineering (140)", use = "Summons a Repair Bot that allows you and others nearby to buy reagents and repair gear. May replace a Reagent Bot." },
    { id = "eng3", profession = "engineering", label = "Anarchist's Workbench", itemId = 279989, icon = "Interface\\Icons\\INV_10_Specialization_ProfessionBook_Engineering_Color1", unlock = "Engineering 300", note = "Engineering station", skill = "Engineering (300)", use = "Places an Anarchist's Workbench usable for recipes that require it." },
    { id = "herb1", profession = "herbalism", label = "Incense Candle", itemId = 279962, icon = "Interface\\Icons\\INV_Misc_Candle_02", unlock = "Herbalism 20", note = "+2 Intellect", skill = "Herbalism (20)", reagents = "Peacebloom, Silverleaf", use = "Ignites an incense candle that allows you and others sitting nearby to gain 2 increased Intellect, exclusive with Arcane Intellect.", exclusive = "Arcane Intellect" },
    { id = "herb2", profession = "herbalism", label = "Greenhouse", itemId = 279964, icon = "Interface\\Icons\\INV_Misc_Herb_08", unlock = "Herbalism 140", note = "Grows herbs + candle", skill = "Herbalism (140)", use = "Places a Greenhouse that will grow herbs over time from seeds planted, and provides all of the benefits of an Incense Candle. May replace a candle." },
    { id = "herb3", profession = "herbalism", label = "Seed Hybridizer", itemId = 279947, icon = "Interface\\Icons\\INV_Farm_HerbSeed", unlock = "Herbalism 300", note = "Seeds + candle", skill = "Herbalism (300)", use = "Places a Seed Hybridizer that allows seeds to be multiplied or combined into rarer tiers, and provides all of the benefits of an Incense Candle. May replace a candle." },
    { id = "lw1", profession = "leatherworking", label = "Camp Tent", itemId = 279978, icon = "Interface\\Icons\\INV_Misc_LeatherScrap_01", unlock = "Leatherworking 20", note = "+5% rest XP", skill = "Leatherworking (20)", reagents = "Light Leather (5)", use = "Builds a tent that allows you and others sitting nearby to increase Rested experience to 5% of a level. No effect if Rested experience already exceeds that value." },
    { id = "lw2", profession = "leatherworking", label = "Tanning Rack", itemId = 279941, icon = "Interface\\Icons\\INV_10_Skinning_Leather_RareHide_Color1", unlock = "Leatherworking 140", note = "Reagents + tent", skill = "Leatherworking (140)", use = "Places a Tanning Rack that allows the creation of certain reagents, and provides all of the benefits of a Camp Tent. May replace a tent." },
    { id = "lw3", profession = "leatherworking", label = "Sewing Machine", itemId = 279945, icon = "Interface\\Icons\\INV_Tailoring_ModifiedCraftingReagent_Orange", unlock = "Leatherworking 300", note = "Station + tent", skill = "Leatherworking (300)", use = "Places a Sewing Machine usable for recipes that require it, and provides all of the benefits of a Camp Tent. May replace a tent." },
    { id = "mine1", profession = "mining", label = "Lodestone", itemId = 279960, icon = "Interface\\Icons\\INV_Misc_Rune_06", unlock = "Mining 20", note = "+12 melee AP", skill = "Mining (20)", reagents = "Rough Stone, Copper Bar", use = "Erects a lodestone that allows you and others sitting nearby to gain 12 increased melee Attack Power, exclusive with Blessing of Might.", exclusive = "Blessing of Might" },
    { id = "mine2", profession = "mining", label = "Rock Garden", itemId = 279948, icon = "Interface\\Icons\\INV_Misc_Powder_Iron", unlock = "Mining 140", note = "Ore node + lodestone", skill = "Mining (140)", use = "Places a Rock Garden that spawns a common mining node over time, and provides all the benefits of a Lodestone. May replace a lodestone." },
    { id = "mine3", profession = "mining", label = "Molten Foundry", itemId = 279952, icon = "Interface\\Icons\\INV_BlacksmithingAlloys_Red", unlock = "Mining 300", note = "Station + lodestone", skill = "Mining (300)", use = "Places a Molten Foundry usable for recipes that require it, and provides all the benefits of a Lodestone. May replace a lodestone." },
    { id = "skin1", profession = "skinning", label = "Camp Chair", itemId = 279979, icon = "Interface\\Icons\\INV_Crate_01", unlock = "Skinning 20", note = "+2% crit", skill = "Skinning (20)", reagents = "Light Leather (3), Simple Wood (2)", use = "Assembles a camp chair that allows you and others sitting nearby to gain 2% increased critical strike chance with all spells and attacks, exclusive with Moonkin Aura.", exclusive = "Moonkin Aura" },
    { id = "skin2", profession = "skinning", label = "Field Guide", itemId = 279969, icon = "Interface\\Icons\\INV_Misc_Book_03", unlock = "Skinning 140", note = "Track Beasts + chair", skill = "Skinning (140)", use = "Places a Field Guide that allows players to read it and gain Track Beasts, and provides all the benefits of a Camp Chair. May replace a chair." },
    { id = "skin3", profession = "skinning", label = "Trapper's Workbench", itemId = 279938, icon = "Interface\\Icons\\INV_Misc_KobySSTools_KnifeTrap_Color3", unlock = "Skinning 300", note = "Trap + chair", skill = "Skinning (300)", use = "Places a Trapper's Workbench containing 1 trap, and provides all the benefits of a Camp Chair. May replace a chair." },
    { id = "tail1", profession = "tailoring", label = "Faction Banner", itemId = 279973, itemIdByFaction = { Alliance = 279973, Horde = 279972 }, icon = "Interface\\Icons\\INV_Banner_03", unlock = "Tailoring 20", note = "+14 Spirit", skill = "Tailoring (20)", reagents = "Bolt of Linen Cloth, Coarse Thread", use = "Unrolls a banner that allows you and other members of your faction sitting nearby to gain 14 increased Spirit, exclusive with Divine Spirit.", exclusive = "Divine Spirit", factionIcons = { Alliance = "Interface\\Icons\\INV_Banner_02", Horde = "Interface\\Icons\\INV_Banner_03" } },
    { id = "tail2", profession = "tailoring", label = "Spinning Wheel", itemId = 279943, icon = "Interface\\Icons\\10Prof_Table_Tailoring01", unlock = "Tailoring 140", note = "Reagents + banner", skill = "Tailoring (140)", use = "Places a Spinning Wheel that allows the creation of certain reagents, and provides all the benefits of a Faction Banner. May replace a banner." },
    { id = "tail3", profession = "tailoring", label = "Loom", itemId = 279959, icon = "Interface\\Icons\\INV_Tailoring_80_TidesprayLinen", unlock = "Tailoring 300", note = "Station + banner", skill = "Tailoring (300)", use = "Places a Loom usable for recipes that require it, and provides all the benefits of a Faction Banner. May replace a banner." },
    { id = "cook2", profession = "cooking", label = "Cookie's Feast", itemId = 279957, icon = "Interface\\Icons\\INV_Cooking_80_MajorFeast", unlock = "Cooking 140", note = "Stamina food", skill = "Cooking (140)", use = "Lay out Cookie's Feast that contains Stamina-boosting food. Requires a Cooking Fire nearby." },
    { id = "cook3", profession = "cooking", label = "Iron Oven", itemId = 279982, icon = "Interface\\Icons\\Achievement_Cooking_MasterOfTheOven", unlock = "Cooking 300", note = "Advanced cooking", skill = "Cooking (300)", use = "Places an Iron Oven required for the most advanced cooking recipes. Requires a Cooking Fire nearby." },
    { id = "fa1", profession = "firstaid", label = "First Aid Kit", itemId = 279968, icon = "Interface\\Icons\\INV_Misc_Bandage_11", unlock = "First Aid 20", note = "+3 Stamina", skill = "First Aid (20)", reagents = "Linen Bandage (3), Refreshing Spring Water", use = "Unpacks a first aid kit that allows you and others sitting nearby to gain 3 increased Stamina, exclusive with Power Word: Fortitude.", exclusive = "Power Word: Fortitude" },
    { id = "fa2", profession = "firstaid", label = "Toxin Study", itemId = 279940, icon = "Interface\\Icons\\INV_Misc_Potion_A3", unlock = "First Aid 140", note = "Potions + kit", skill = "First Aid (140)", use = "Places a Toxin Study that contains healing potions, anti-venom, and provides all of the benefits of a First Aid Kit. May replace a kit." },
    { id = "fa3", profession = "firstaid", label = "Plague Doctor's Laboratory", itemId = 279951, icon = "Interface\\Icons\\INV_10_Alchemy_IncenseHolder_Color1", unlock = "First Aid 300", note = "Potions + kit", skill = "First Aid (300)", use = "Places a Plague Doctor's Laboratory that contains healing potions, poultices, and provides all of the benefits of a First Aid Kit. May replace a kit." },
    { id = "fish1", profession = "fishing", label = "Fish Bowl", itemId = 279967, icon = "Interface\\Icons\\INV_MagicalFishPet", unlock = "Fishing 20", note = "+8% stats", skill = "Fishing (20)", reagents = "Raw Brilliant Smallfish, Empty Vial", use = "Places a small fish bowl that allows you and others sitting nearby to gain 8% increased stats, exclusive with Blessing of Kings.", exclusive = "Blessing of Kings" },
    { id = "fish2", profession = "fishing", label = "Fishing Rack", itemId = 279965, icon = "Interface\\Icons\\INV_Misc_2H_DraenorFishingPole_A_01", unlock = "Fishing 140", note = "Uncommon fish + bowl", skill = "Fishing (140)", use = "Places a Fishing Rack that grants the ability to catch uncommon fish for 1 hour, Fishing Skill lures, and provides all of the benefits of a Fish Bowl. May replace a Fish Bowl." },
    { id = "fish3", profession = "fishing", label = "Fishing Hut", itemId = 279966, icon = "Interface\\Icons\\INV_FishingChair", unlock = "Fishing 300", note = "Rare fish + bowl", skill = "Fishing (300)", use = "Places a Fishing Hut that grants the ability to catch rare fish for 1 hour, Fishing Skill lures, and provides all of the benefits of a Fish Bowl. May replace a Fish Bowl." },
}
local ITEM_BY_ID = {}
local ITEMS_BY_PROF = {}
for _, item in ipairs(SmoreSkills.PROFESSION_ITEMS) do
    ITEM_BY_ID[item.id] = item
    ITEMS_BY_PROF[item.profession] = ITEMS_BY_PROF[item.profession] or {}
    table.insert(ITEMS_BY_PROF[item.profession], item)
end

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
    local function addByName(skillName)
        local id = SmoreSkills_ProfessionIdFromSkillName(skillName)
        if id and not seen[id] then
            seen[id] = true
            table.insert(list, id)
        end
    end
    -- Forever / Mainline: GetProfessions. TBC Anniversary: skill lines.
    if GetProfessions and GetProfessionInfo then
        local profs = { GetProfessions() }
        for i = 1, #profs do
            local index = profs[i]
            if index then
                addByName(GetProfessionInfo(index))
            end
        end
    end
    -- First Aid is still a real Forever trade; GetProfessions often omits it.
    if GetNumSkillLines then
        for i = 1, GetNumSkillLines() do
            addByName(GetSkillLineInfo(i))
        end
    end
    return list
end

function SmoreSkills_GetProfessionSkill(profId)
    if not profId or profId == "" then
        return 0
    end
    if not ID_TO_PROF[profId] then
        profId = SmoreSkills_ProfessionIdFromSkillName(profId)
    end
    if not profId or not ID_TO_PROF[profId] then
        return 0
    end
    local best = 0
    local function consider(name, rank)
        if SmoreSkills_ProfessionIdFromSkillName(name) == profId then
            rank = tonumber(rank) or 0
            if rank > best then
                best = rank
            end
        end
    end
    if GetProfessions and GetProfessionInfo then
        local profs = { GetProfessions() }
        for i = 1, #profs do
            if profs[i] then
                local name, _, rank = GetProfessionInfo(profs[i])
                consider(name, rank)
            end
        end
    end
    if GetNumSkillLines then
        for i = 1, GetNumSkillLines() do
            local name, isHeader, _, rank = GetSkillLineInfo(i)
            if not isHeader then
                consider(name, rank)
            end
        end
    end
    if C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo then
        local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
        if ok and type(info) == "table" then
            consider(info.parentProfessionName or info.professionName or info.profession, info.skillLevel)
        end
    end
    return best
end

SmoreSkills.SIGNAL_TTL = 3 * 60
-- Addon pin TTL. Forever camp was still up after 10 min (18 Sep); pin is 20 min until we time a despawn.
SmoreSkills.CAMPFIRE_DURATION = 20 * 60
SmoreSkills.MAX_PINS_PER_ZONE = 12

-- Wire timestamps are unix seconds. Layer ids (e.g. 15654) must not be treated as times.
function SmoreSkills_SanitizeCampTime(t)
    t = tonumber(t)
    local now = SmoreSkills_Now()
    if not t or t < 1000000000 or t > now + 600 then
        return now
    end
    return t
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

function SmoreSkills_ProfessionIcon(idOrCode)
    local row = SmoreSkills_ProfessionFromId(idOrCode) or SmoreSkills_ProfessionFromCode(idOrCode)
    return row and row.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

local liveObjectIconCache = {}

local function usableTex(tex)
    if tex and tex ~= "" and tex ~= 0 then
        return tex
    end
    return nil
end

local function NormalizeObjectName(name)
    if not name or name == "" then
        return nil
    end
    name = strtrim(tostring(name))
    name = name:gsub("%s*%(Tier%s*[IVX]+%)%s*$", "")
    if name == "" or string.find(name, "Tier %d") then
        return nil
    end
    return name
end

local function CacheLiveObjectIcon(name, tex)
    name = NormalizeObjectName(name)
    tex = usableTex(tex)
    if not name or not tex then
        return
    end
    liveObjectIconCache[strlower(name)] = tex
end

local function SpellTexture(name)
    if not name then
        return nil
    end
    if C_Spell then
        if C_Spell.GetSpellTexture then
            local ok, tex = pcall(C_Spell.GetSpellTexture, name)
            if ok then
                tex = usableTex(tex)
                if tex then
                    return tex
                end
            end
        end
        if C_Spell.GetSpellInfo then
            local ok, info = pcall(C_Spell.GetSpellInfo, name)
            if ok and type(info) == "table" then
                local tex = usableTex(info.iconID or info.originalIconID or info.icon)
                if tex then
                    return tex
                end
            end
        end
    end
    if GetSpellInfo then
        local ok, _, _, icon = pcall(GetSpellInfo, name)
        if ok then
            local tex = usableTex(icon)
            if tex then
                return tex
            end
        end
    end
    return nil
end

local function ItemTexture(name, itemId)
    if itemId then
        if C_Item and C_Item.GetItemIconByID then
            local tex = usableTex(C_Item.GetItemIconByID(itemId))
            if tex then
                return tex
            end
        end
        if GetItemInfoInstant then
            local _, _, _, _, icon = GetItemInfoInstant(itemId)
            local tex = usableTex(icon)
            if tex then
                return tex
            end
        end
        if GetItemInfo then
            local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
            local tex = usableTex(texture)
            if tex then
                return tex
            end
        end
    end
    if not name then
        return nil
    end
    if GetItemInfo then
        local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(name)
        local tex = usableTex(texture)
        if tex then
            return tex
        end
    end
    if C_Item and C_Item.GetItemInfoInstant then
        local _, _, _, _, icon = C_Item.GetItemInfoInstant(name)
        local tex = usableTex(icon)
        if tex then
            return tex
        end
    end
    if GetItemInfoInstant then
        local _, _, _, _, icon = GetItemInfoInstant(name)
        return usableTex(icon)
    end
    return nil
end

local function ResolvedItemId(item)
    if not item then
        return nil
    end
    if item.itemIdByFaction then
        local faction = UnitFactionGroup("player")
        local id = faction and item.itemIdByFaction[faction]
        if id then
            return id
        end
    end
    return item.itemId
end

local function LiveObjectTexture(item)
    local name = NormalizeObjectName(item and item.label)
    if not name then
        return nil
    end
    local cached = liveObjectIconCache[strlower(name)]
    if cached then
        return cached
    end
    local tex = ItemTexture(name, ResolvedItemId(item))
    if not tex then
        tex = SpellTexture(name)
    end
    if not tex and item.profession then
        local prof = SmoreSkills_ProfessionLabel(item.profession)
        if prof and prof ~= "" then
            tex = SpellTexture(prof .. ": " .. name)
        end
    end
    if tex then
        CacheLiveObjectIcon(name, tex)
    end
    return tex
end

local function ScanTrainerObjectIcons()
    local n
    if GetNumTrainerServices then
        local ok, count = pcall(GetNumTrainerServices)
        if ok then
            n = count
        end
    end
    if n and n > 0 then
        for i = 1, n do
            local ok, name, _, serviceType = pcall(GetTrainerServiceInfo, i)
            if ok and type(name) == "string" and serviceType ~= "header" then
                local icon
                if GetTrainerServiceIcon then
                    local okIcon, tex = pcall(GetTrainerServiceIcon, i)
                    if okIcon then
                        icon = tex
                    end
                end
                CacheLiveObjectIcon(name, icon)
            end
        end
    end
    local function texFrom(icon)
        if not icon or not icon.GetTexture then
            return nil
        end
        local ok, tex = pcall(icon.GetTexture, icon)
        if ok then
            return tex
        end
        return nil
    end
    local function textFrom(fs)
        if not fs or not fs.GetText then
            return nil
        end
        local ok, text = pcall(fs.GetText, fs)
        if ok then
            return text
        end
        return nil
    end
    local function takeButton(btn)
        if not btn then
            return
        end
        if btn.IsShown and not btn:IsShown() then
            return
        end
        local name = textFrom(btn.Name) or textFrom(btn.name) or textFrom(btn.Text)
        if (not name or name == "") and btn.GetText then
            local ok, text = pcall(btn.GetText, btn)
            if ok then
                name = text
            end
        end
        local tex = texFrom(btn.Icon) or texFrom(btn.icon) or texFrom(btn.IconTexture)
        if btn.GetName then
            local glob = btn:GetName()
            if glob then
                tex = tex or texFrom(_G[glob .. "Icon"]) or texFrom(_G[glob .. "IconTexture"])
                name = name or textFrom(_G[glob .. "Name"]) or textFrom(_G[glob .. "Text"])
            end
        end
        if type(name) == "string" and name ~= "" then
            CacheLiveObjectIcon(name, tex)
        end
    end
    for i = 1, 32 do
        takeButton(_G["ClassTrainerSkill" .. i])
        takeButton(_G["ClassTrainerScrollFrameButton" .. i])
    end
    local box = ClassTrainerFrame and ClassTrainerFrame.ScrollBox
    if box and box.ForEachFrame then
        pcall(function()
            box:ForEachFrame(takeButton)
        end)
    end
end

local function ScanTradeSkillObjectIcons()
    if not C_TradeSkillUI then
        return
    end
    local ids
    if C_TradeSkillUI.GetAllRecipeIDs then
        local ok, result = pcall(C_TradeSkillUI.GetAllRecipeIDs)
        if ok then
            ids = result
        end
    end
    if type(ids) ~= "table" or not C_TradeSkillUI.GetRecipeInfo then
        return
    end
    for i = 1, #ids do
        local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, ids[i])
        if ok and type(info) == "table" and info.name then
            CacheLiveObjectIcon(info.name, info.icon)
        end
    end
end

local function LearnedCharKey()
    local name = UnitName("player") or "?"
    local realm = (GetNormalizedRealmName and GetNormalizedRealmName()) or GetRealmName() or ""
    return name .. "-" .. realm
end

local function LearnedStore()
    if not SmoreSkillsDB then
        return nil
    end
    SmoreSkillsDB.learnedCamping = SmoreSkillsDB.learnedCamping or {}
    local key = LearnedCharKey()
    local store = SmoreSkillsDB.learnedCamping[key]
    if not store then
        store = { objects = {}, scanned = {} }
        SmoreSkillsDB.learnedCamping[key] = store
    end
    store.objects = store.objects or {}
    store.scanned = store.scanned or {}
    return store
end

local function RecipeIsLearned(info)
    if type(info) ~= "table" then
        return false
    end
    if info.learned ~= nil then
        return info.learned == true
    end
    return true
end

local function CampingItemFromRecipeName(name)
    name = NormalizeObjectName(name)
    if not name then
        return nil
    end
    if SmoreSkills_NormalizeItem then
        local id = SmoreSkills_NormalizeItem(name)
        if id then
            return SmoreSkills_ItemFromId(id)
        end
        local colon = name:match("^[^:]+:%s*(.+)$")
        if colon then
            id = SmoreSkills_NormalizeItem(colon)
            if id then
                return SmoreSkills_ItemFromId(id)
            end
        end
    end
    local lower = strlower(name)
    for _, row in ipairs(SmoreSkills.PROFESSION_ITEMS) do
        if strlower(row.label) == lower then
            return row
        end
    end
    return nil
end

local function MarkLearnedObject(itemId)
    if not itemId then
        return
    end
    local store = LearnedStore()
    if store then
        store.objects[itemId] = true
    end
end

local function ReplaceProfessionLearned(profId, ids)
    local store = LearnedStore()
    if not store or not profId then
        return
    end
    for _, row in ipairs(SmoreSkills.PROFESSION_ITEMS) do
        if row.profession == profId then
            store.objects[row.id] = nil
        end
    end
    for i = 1, #ids do
        store.objects[ids[i]] = true
    end
    store.scanned[profId] = true
end

local function OpenTradeSkillProfessionId()
    if C_TradeSkillUI then
        if C_TradeSkillUI.GetBaseProfessionInfo then
            local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
            if ok and type(info) == "table" then
                local name = info.parentProfessionName or info.professionName or info.profession
                local id = SmoreSkills_ProfessionIdFromSkillName(name)
                if id then
                    return id
                end
            end
        end
        if C_TradeSkillUI.GetChildProfessionInfo then
            local ok, info = pcall(C_TradeSkillUI.GetChildProfessionInfo)
            if ok and type(info) == "table" then
                local id = SmoreSkills_ProfessionIdFromSkillName(info.professionName or info.profession)
                if id then
                    return id
                end
            end
        end
    end
    if GetTradeSkillLine then
        local ok, name = pcall(GetTradeSkillLine)
        if ok then
            local id = SmoreSkills_ProfessionIdFromSkillName(name)
            if id then
                return id
            end
        end
    end
    if GetCraftDisplaySkillLine then
        local ok, name = pcall(GetCraftDisplaySkillLine)
        if ok then
            return SmoreSkills_ProfessionIdFromSkillName(name)
        end
    end
    return nil
end

local function PlayerKnowsSpellName(name)
    if not name or name == "" then
        return false
    end
    local spellId
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, name)
        if ok and type(info) == "table" then
            spellId = info.spellID or info.spellId
        end
    end
    if not spellId and GetSpellInfo then
        local ok, _, _, _, _, _, id = pcall(GetSpellInfo, name)
        if ok then
            spellId = id
        end
    end
    if not spellId then
        return false
    end
    if IsPlayerSpell then
        local ok, known = pcall(IsPlayerSpell, spellId)
        if ok and known then
            return true
        end
    end
    if IsSpellKnown then
        local ok, known = pcall(IsSpellKnown, spellId)
        if ok and known then
            return true
        end
    end
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        local ok, known = pcall(C_SpellBook.IsSpellInSpellBook, spellId)
        if ok and known then
            return true
        end
    end
    return false
end

local function ScanSpellKnownCampingObjects()
    for _, item in ipairs(SmoreSkills.PROFESSION_ITEMS) do
        local names = { item.label }
        local prof = SmoreSkills_ProfessionLabel(item.profession)
        if prof and prof ~= "" then
            table.insert(names, prof .. ": " .. item.label)
        end
        for i = 1, #names do
            if PlayerKnowsSpellName(names[i]) then
                MarkLearnedObject(item.id)
                break
            end
        end
    end
end

local function SkillRequiredForItem(item)
    if not item then
        return nil
    end
    local text = item.skill or item.unlock or ""
    return tonumber(text:match("%((%d+)%)")) or tonumber(text:match("(%d+)"))
end

function SmoreSkills_CampingItemSkillRequired(item)
    return SkillRequiredForItem(item)
end

function SmoreSkills_PlayerMeetsCampingItemSkill(item)
    if not item then
        return false
    end
    local need = SkillRequiredForItem(item)
    if not need then
        return true
    end
    return SmoreSkills_GetProfessionSkill(item.profession) >= need
end

-- Forever First Aid (and other trades) can sit at 46 without GetProfessions listing them.
-- Skill 46 unlocks the 20-skill camping object even if we have not scanned the recipe window.
local function InferLearnedFromProfessionSkill()
    for _, item in ipairs(SmoreSkills.PROFESSION_ITEMS) do
        local need = SkillRequiredForItem(item)
        if need then
            local rank = SmoreSkills_GetProfessionSkill and SmoreSkills_GetProfessionSkill(item.profession) or 0
            if rank >= need then
                MarkLearnedObject(item.id)
            end
        end
    end
end

local function ScanTradeSkillLearnedCampingObjects()
    local found = {}
    local foundByProf = {}
    local function takeName(name, learned)
        if learned == false then
            return
        end
        local item = CampingItemFromRecipeName(name)
        if not item then
            return
        end
        found[item.id] = item
        foundByProf[item.profession] = foundByProf[item.profession] or {}
        foundByProf[item.profession][item.id] = true
    end
    if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs and C_TradeSkillUI.GetRecipeInfo then
        local ok, ids = pcall(C_TradeSkillUI.GetAllRecipeIDs)
        if ok and type(ids) == "table" then
            for i = 1, #ids do
                local okInfo, info = pcall(C_TradeSkillUI.GetRecipeInfo, ids[i])
                if okInfo and type(info) == "table" and info.name then
                    takeName(info.name, RecipeIsLearned(info))
                end
            end
        end
    end
    if GetNumTradeSkills then
        local ok, n = pcall(GetNumTradeSkills)
        if ok and n and n > 0 then
            for i = 1, n do
                local okInfo, name, skillType = pcall(GetTradeSkillInfo, i)
                if okInfo and type(name) == "string" and skillType ~= "header" then
                    takeName(name, true)
                end
            end
        end
    end
    if GetNumCrafts then
        local ok, n = pcall(GetNumCrafts)
        if ok and n and n > 0 then
            for i = 1, n do
                local okInfo, name, craftType = pcall(GetCraftInfo, i)
                if okInfo and type(name) == "string" and craftType ~= "header" then
                    takeName(name, true)
                end
            end
        end
    end
    local openProf = OpenTradeSkillProfessionId()
    if openProf then
        local ids = {}
        local set = foundByProf[openProf] or {}
        for itemId in pairs(set) do
            table.insert(ids, itemId)
        end
        ReplaceProfessionLearned(openProf, ids)
    else
        for itemId in pairs(found) do
            MarkLearnedObject(itemId)
        end
    end
end

function SmoreSkills_PlayerKnowsCampingObject(itemOrId)
    local id = itemOrId
    local item = nil
    if type(itemOrId) == "table" then
        id = itemOrId.id
        item = itemOrId
    elseif type(itemOrId) == "string" then
        id = SmoreSkills_NormalizeItem(itemOrId) or itemOrId
    end
    if not id then
        return false
    end
    local store = LearnedStore()
    if store and store.objects[id] == true then
        return true
    end
    item = item or ITEM_BY_ID[id]
    if item and SmoreSkills_PlayerMeetsCampingItemSkill(item) then
        return true
    end
    return false
end

function SmoreSkills_LearnedCampingItems()
    ScanSpellKnownCampingObjects()
    ScanTradeSkillLearnedCampingObjects()
    InferLearnedFromProfessionSkill()
    local list = {}
    local seen = {}
    local profs = SmoreSkills_GetPlayerProfessions()
    if #profs == 0 then
        return list
    end
    for _, profId in ipairs(profs) do
        for _, item in ipairs(SmoreSkills_ItemsForProfession(profId)) do
            if not seen[item.id] and SmoreSkills_PlayerKnowsCampingObject(item.id) then
                seen[item.id] = true
                table.insert(list, item)
            end
        end
    end
    return list
end

function SmoreSkills_ClampHostSlotToLearned(camp)
    if not camp then
        return false
    end
    SmoreSkills_EnsureSlots(camp)
    local slot = camp.slots and camp.slots[1]
    if not slot or not slot.object or slot.object == "" then
        return false
    end
    if SmoreSkills_PlayerKnowsCampingObject(slot.object) then
        return false
    end
    local store = LearnedStore()
    local prof = slot.profession
    if not store or not prof or not store.scanned[prof] then
        return false
    end
    slot.object = nil
    camp.updatedAt = SmoreSkills_Now()
    return true
end

local function ScanLiveObjectIcons()
    ScanTrainerObjectIcons()
    ScanTradeSkillObjectIcons()
    ScanSpellKnownCampingObjects()
    ScanTradeSkillLearnedCampingObjects()
    InferLearnedFromProfessionSkill()
end

local lastLiveIconScan = 0
local function MaybeScanLiveObjectIcons()
    local now = GetTime and GetTime() or 0
    if now > 0 and (now - lastLiveIconScan) < 0.25 then
        return
    end
    lastLiveIconScan = now
    ScanLiveObjectIcons()
end

local iconScanFrame = CreateFrame("Frame")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "TRAINER_SHOW")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "TRAINER_UPDATE")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "TRADE_SKILL_SHOW")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "TRADE_SKILL_DATA_SOURCE_CHANGED")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "TRADE_SKILL_LIST_UPDATE")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "CRAFT_SHOW")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "CRAFT_UPDATE")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "PLAYER_ENTERING_WORLD")
pcall(iconScanFrame.RegisterEvent, iconScanFrame, "SKILL_LINES_CHANGED")
iconScanFrame:SetScript("OnEvent", function()
    ScanLiveObjectIcons()
    if not (SmoreSkills.HostPanel and SmoreSkills.HostPanel.Refresh) then
        return
    end
    if iconScanFrame._refreshQueued then
        return
    end
    iconScanFrame._refreshQueued = true
    local function flush()
        iconScanFrame._refreshQueued = nil
        local camp = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
        if camp then
            SmoreSkills_ClampHostSlotToLearned(camp)
        end
        SmoreSkills.HostPanel:Refresh()
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0.05, flush)
    else
        flush()
    end
end)
-- Defer: this file is still loading; NormalizeProfession and EnsureSettings come later.
if C_Timer and C_Timer.After then
    C_Timer.After(0, ScanLiveObjectIcons)
else
    ScanLiveObjectIcons()
end

function SmoreSkills_CampingObjectIcon(itemOrIdOrLabel)
    MaybeScanLiveObjectIcons()
    local item = itemOrIdOrLabel
    if type(item) == "string" then
        local id = SmoreSkills_NormalizeItem and SmoreSkills_NormalizeItem(item)
        item = (id and SmoreSkills_ItemFromId and SmoreSkills_ItemFromId(id)) or { label = item }
    end
    if type(item) ~= "table" then
        return nil
    end
    local live = LiveObjectTexture(item)
    if live then
        return live
    end
    if item.factionIcons then
        local faction = UnitFactionGroup("player")
        local facIcon = faction and item.factionIcons[faction]
        if facIcon then
            return facIcon
        end
    end
    if item.icon and item.icon ~= "" then
        return item.icon
    end
    if item.profession then
        return SmoreSkills_ProfessionIcon(item.profession)
    end
    return nil
end

function SmoreSkills_SlotIcon(slot)
    if slot and slot.object and slot.object ~= "" then
        local icon = SmoreSkills_CampingObjectIcon(slot.object)
        if icon then
            return icon
        end
    end
    if slot and slot.profession then
        return SmoreSkills_ProfessionIcon(slot.profession)
    end
    return SmoreSkills.ICON or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function SmoreSkills_NormalizeProfession(idOrCode)
    if idOrCode == nil or idOrCode == "" then
        return nil
    end
    idOrCode = strtrim(tostring(idOrCode))
    local row = SmoreSkills_ProfessionFromId(idOrCode) or SmoreSkills_ProfessionFromCode(idOrCode)
    if row then
        return row.id
    end
    local lower = strlower(idOrCode)
    row = SmoreSkills_ProfessionFromId(lower) or SmoreSkills_ProfessionFromCode(lower)
    if row then
        return row.id
    end
    return SmoreSkills_ProfessionIdFromSkillName(idOrCode)
end

function SmoreSkills_GetPlayerProfession()
    -- /smores prof is session-only (testing). Reload uses this character's learned trades.
    if SmoreSkills.sessionProfession then
        return SmoreSkills_NormalizeProfession(SmoreSkills.sessionProfession)
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
    local id = SmoreSkills_NormalizeProfession(idOrCode)
    if not id then
        return false
    end
    SmoreSkills.sessionProfession = id
    if SmoreSkillsDB and SmoreSkillsDB.settings then
        SmoreSkillsDB.settings.profession = nil
    end
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
    if (s.dataVersion or 2) < 3 then
        s.crossLayerEnabled = true
        s.dataVersion = 3
    end
    if (s.dataVersion or 3) < 4 then
        s.profession = nil
        s.dataVersion = 4
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
    if s.hostWantItems == nil then
        s.hostWantItems = ""
    end
    if s.seekerWantItems == nil then
        s.seekerWantItems = ""
    end
    if s.minimapAngle == nil then
        s.minimapAngle = 220
    end
    if s.chatEnabled == nil then
        s.chatEnabled = true
    end
    if s.showMinimapButton == nil then
        s.showMinimapButton = true
    end
    if s.lockMinimapButton == nil then
        s.lockMinimapButton = false
    end
    if s.showGuildMark == nil then
        s.showGuildMark = true
    end
    if s.crossLayerEnabled == nil then
        s.crossLayerEnabled = true
    end
    if s.pinScalePct == nil then
        s.pinScalePct = 100
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

function SmoreSkills_GetChatEnabled()
    return SmoreSkills_EnsureSettings().chatEnabled ~= false
end

function SmoreSkills_SetChatEnabled(enabled)
    SmoreSkills_EnsureSettings().chatEnabled = enabled and true or false
end

function SmoreSkills_GetShowMinimapButton()
    return SmoreSkills_EnsureSettings().showMinimapButton ~= false
end

function SmoreSkills_SetShowMinimapButton(enabled)
    SmoreSkills_EnsureSettings().showMinimapButton = enabled and true or false
end

function SmoreSkills_GetLockMinimapButton()
    return SmoreSkills_EnsureSettings().lockMinimapButton == true
end

function SmoreSkills_SetLockMinimapButton(enabled)
    SmoreSkills_EnsureSettings().lockMinimapButton = enabled and true or false
end

function SmoreSkills_GetShowGuildMark()
    return SmoreSkills_EnsureSettings().showGuildMark ~= false
end

function SmoreSkills_SetShowGuildMark(enabled)
    SmoreSkills_EnsureSettings().showGuildMark = enabled and true or false
end

function SmoreSkills_GetCrossLayerEnabled()
    return SmoreSkills_EnsureSettings().crossLayerEnabled == true
end

function SmoreSkills_SetCrossLayerEnabled(enabled)
    SmoreSkills_EnsureSettings().crossLayerEnabled = enabled and true or false
end

function SmoreSkills_GetPinScalePct()
    local v = tonumber(SmoreSkills_EnsureSettings().pinScalePct) or 100
    if v < 50 then
        v = 50
    elseif v > 150 then
        v = 150
    end
    return v
end

function SmoreSkills_SetPinScalePct(pct)
    local v = tonumber(pct) or 100
    v = math.floor((v / 5) + 0.5) * 5
    if v < 50 then
        v = 50
    elseif v > 150 then
        v = 150
    end
    SmoreSkills_EnsureSettings().pinScalePct = v
    return v
end

function SmoreSkills_GetHostProfession()
    local s = SmoreSkills_EnsureSettings()
    local chosen = SmoreSkills_NormalizeProfession(s.hostProfession)
    if chosen then
        return chosen
    end
    local learned = SmoreSkills_GetPlayerProfessions()
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

function SmoreSkills_ApplyHostProfession(camp, force)
    if not camp then
        return camp
    end
    if camp.slot1Override and not force then
        return camp
    end
    local prof = SmoreSkills_GetHostProfession()
    if not prof then
        return camp
    end
    SmoreSkills_EnsureSlots(camp)
    local object = camp.slots[1] and camp.slots[1].object
    if force then
        object = nil
        camp.slot1Override = nil
    end
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

function SmoreSkills_GetHostWantItems()
    return SmoreSkills_EnsureSettings().hostWantItems or ""
end

function SmoreSkills_GetSeekerWantItems()
    return SmoreSkills_EnsureSettings().seekerWantItems or ""
end

function SmoreSkills_GetEffectiveHostWantItems()
    if not SmoreSkills_GetHostFilterEnabled() then
        return ""
    end
    if SmoreSkills_GetEffectiveHostWant() == "none" then
        return ""
    end
    return SmoreSkills_GetHostWantItems()
end

function SmoreSkills_GetEffectiveSeekerWantItems()
    if not SmoreSkills_GetSeekerFilterEnabled() then
        return ""
    end
    if SmoreSkills_GetEffectiveSeekerWant() == "none" then
        return ""
    end
    return SmoreSkills_GetSeekerWantItems()
end

function SmoreSkills_ApplyHostWantToCamp(camp, force)
    if not camp then
        return camp
    end
    if camp.wantOverride and not force then
        return camp
    end
    camp.want = SmoreSkills_GetEffectiveHostWant()
    camp.wantItems = SmoreSkills_GetEffectiveHostWantItems()
    camp.wantOverride = nil
    return camp
end

function SmoreSkills_NotifyHostCampUi()
    if SmoreSkills_SnapshotOwnedHost then
        SmoreSkills_SnapshotOwnedHost()
    end
    if SmoreSkills.HostPanel and SmoreSkills.HostPanel.Refresh then
        SmoreSkills.HostPanel:Refresh()
    end
    if SmoreSkills.Map and SmoreSkills.Map.RefreshPins then
        SmoreSkills.Map:RefreshPins()
    end
end

function SmoreSkills_ShareOwnedCampFromClick()
    if SmoreSkills.Sync and SmoreSkills.Sync.ShareOwnedCampFromClick then
        SmoreSkills.Sync:ShareOwnedCampFromClick()
        return
    end
    SmoreSkills_NotifyHostCampUi()
end

function SmoreSkills_RefreshOwnedCampWant()
    local me = SmoreSkills_PlayerName()
    local touched = false
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if SmoreSkills_PlayerNamesMatch(camp.owner, me) then
            SmoreSkills_ApplyHostWantToCamp(camp, true)
            touched = true
        end
    end
    if touched then
        SmoreSkills_NotifyHostCampUi()
        if SmoreSkills.Sync and SmoreSkills.Sync.IsHosting and SmoreSkills.Sync:IsHosting() then
            SmoreSkills_ShareOwnedCampFromClick()
        end
    end
end

function SmoreSkills_CampWantHasProfession(camp, profId)
    if not camp then
        return false
    end
    local want = SmoreSkills_SplitWantWire(camp.want or "any")
    if not want or want == "" or want == "any" or want == "none" then
        return false
    end
    return SmoreSkills_WantAccepts(want, profId)
end

function SmoreSkills_CampWantHasObject(camp, itemId)
    if not camp then
        return false
    end
    itemId = SmoreSkills_NormalizeItem(itemId)
    if not itemId then
        return false
    end
    for _, id in ipairs(SmoreSkills_ParseItemList(camp.wantItems)) do
        if id == itemId then
            return true
        end
    end
    return false
end

function SmoreSkills_SetCampWantAnyone(camp)
    if not camp then
        return camp
    end
    camp.want = "any"
    camp.wantItems = ""
    camp.wantOverride = true
    return camp
end

function SmoreSkills_ToggleCampWantProfession(camp, profId)
    if not camp then
        return false
    end
    local row = SmoreSkills_ProfessionFromId(SmoreSkills_NormalizeProfession(profId))
    if not row then
        return false
    end
    local want = SmoreSkills_SplitWantWire(camp.want or "any")
    local codes = {}
    local found = false
    if want and want ~= "" and want ~= "any" and want ~= "none" then
        for token in string.gmatch(want, "[^,]+") do
            local id = SmoreSkills_NormalizeProfession(strtrim(token))
            if id == row.id then
                found = true
            else
                local other = SmoreSkills_ProfessionFromId(id)
                if other then
                    table.insert(codes, other.code)
                end
            end
        end
    end
    if not found then
        table.insert(codes, row.code)
    else
        camp.wantItems = DropItemsForProfession(camp.wantItems, row.id)
    end
    if #codes == 0 then
        camp.want = "none"
        camp.wantItems = ""
    else
        camp.want = table.concat(codes, ",")
    end
    camp.wantOverride = true
    return true
end

function SmoreSkills_ToggleCampWantObject(camp, itemId)
    if not camp then
        return false
    end
    local item = SmoreSkills_ItemFromId(SmoreSkills_NormalizeItem(itemId))
    if not item then
        return false
    end
    if not SmoreSkills_CampWantHasProfession(camp, item.profession) then
        return false
    end
    local list = SmoreSkills_ParseItemList(camp.wantItems)
    local found = false
    local nextList = {}
    for _, id in ipairs(list) do
        if id == item.id then
            found = true
        else
            table.insert(nextList, id)
        end
    end
    if not found then
        table.insert(nextList, item.id)
    end
    camp.wantItems = table.concat(nextList, ",")
    camp.wantOverride = true
    return true
end

function SmoreSkills_SetCampHostContribution(camp, profession, object)
    return SmoreSkills_SetCampSlotDeclaration(camp, 1, profession, object)
end

function SmoreSkills_SetCampSlotDeclaration(camp, index, profession, object)
    if not camp then
        return false
    end
    index = tonumber(index) or 1
    local profId = SmoreSkills_NormalizeProfession(profession)
    if not profId then
        return false
    end
    if object and object ~= "" then
        local item = SmoreSkills_ItemFromId(SmoreSkills_NormalizeItem(object))
        if item then
            if index == 1 and SmoreSkills_PlayerKnowsCampingObject and not SmoreSkills_PlayerKnowsCampingObject(item.id) then
                object = nil
            else
                profId = item.profession
                object = item.label
            end
        end
    else
        object = nil
    end
    if index == 1 then
        camp.slot1Override = true
    end
    local player = index == 1 and (camp.owner or SmoreSkills_PlayerName()) or nil
    return SmoreSkills_SetSlot(camp, index, player, profId, object)
end

function SmoreSkills_ClearCampSlotDeclaration(camp, index)
    if not camp then
        return false
    end
    index = tonumber(index)
    if not index or index < 2 or index > SmoreSkills.MAX_SLOTS then
        return false
    end
    SmoreSkills_EnsureSlots(camp)
    camp.slots[index] = { index = index }
    camp.updatedAt = SmoreSkills_Now()
    return true
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
    else
        local s = SmoreSkillsDB.settings
        if wantKey == "seekerWant" then
            s.seekerWantItems = DropItemsForProfession(s.seekerWantItems, profId)
        else
            s.hostWantItems = DropItemsForProfession(s.hostWantItems, profId)
        end
    end
    if wantKey == "seekerWant" then
        SmoreSkillsDB.settings.seekerWant = #codes > 0 and table.concat(codes, ",") or ""
    else
        SmoreSkillsDB.settings.hostWant = #codes > 0 and table.concat(codes, ",") or ""
        SmoreSkills_RefreshOwnedCampWant()
    end
    return true
end

function SmoreSkills_SplitWantWire(want)
    want = want or "any"
    local slash = want:find("/", 1, true)
    if not slash then
        return want, nil
    end
    local items = want:sub(slash + 1)
    if items == "" then
        items = nil
    end
    return want:sub(1, slash - 1), items
end

function SmoreSkills_JoinWantWire(want, items)
    want = want or "any"
    if not items or items == "" or items == "any" then
        return want
    end
    return want .. "/" .. items
end

function SmoreSkills_ItemFromId(id)
    return id and ITEM_BY_ID[id] or nil
end

function SmoreSkills_ItemsForProfession(profId)
    return ITEMS_BY_PROF[profId] or {}
end

function SmoreSkills_ItemLabel(id)
    local item = SmoreSkills_ItemFromId(id)
    return item and item.label or (id or "")
end

-- Pin tooltip: "Camp Chair — +2% crit" so seekers see the sit buff, not only the name.
function SmoreSkills_FormatObjectWithNote(name)
    if not name or name == "" then
        return ""
    end
    local id = SmoreSkills_NormalizeItem(name)
    local item = id and SmoreSkills_ItemFromId(id) or nil
    local label = item and item.label or name
    if item and item.note and item.note ~= "" then
        return label .. " — " .. item.note
    end
    return label
end

function SmoreSkills_ShowCampingItemTooltip(owner, item, anchor)
    if not owner or not item or not GameTooltip then
        return
    end
    GameTooltip:SetOwner(owner, anchor or "ANCHOR_NONE")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(item.label, 1, 0.82, 0)
    if item.skill then
        local meets = SmoreSkills_PlayerMeetsCampingItemSkill(item)
            or (SmoreSkills_PlayerKnowsCampingObject and SmoreSkills_PlayerKnowsCampingObject(item))
        if meets then
            GameTooltip:AddLine("Requires " .. item.skill, 0.1, 1, 0.1)
        else
            GameTooltip:AddLine("Requires " .. item.skill, 1, 0.13, 0.13)
        end
    elseif item.unlock then
        GameTooltip:AddLine(item.unlock, 0.7, 0.7, 0.7)
    end
    if item.reagents then
        GameTooltip:AddLine("Reagents: " .. item.reagents, 0.1, 1, 0.1)
    end
    if item.use then
        GameTooltip:AddLine("Use: " .. item.use, 0.1, 1, 0.1, true)
        local useLower = strlower(item.use)
        if not string.find(useLower, "camping features share", 1, true) then
            if string.find(useLower, "cooking fire", 1, true) or string.find(useLower, "campfire", 1, true) then
                GameTooltip:AddLine("All camping features share a cooldown of 1 hour.", 0.1, 1, 0.1, true)
            else
                GameTooltip:AddLine("Requires a Campfire nearby. All camping features share a cooldown of 1 hour.", 0.1, 1, 0.1, true)
            end
        end
    elseif item.note then
        GameTooltip:AddLine(item.note, 0.92, 0.92, 0.92)
    end
    GameTooltip:Show()
    if anchor then
        return
    end
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale() or 1
    if scale == 0 then
        scale = 1
    end
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

function SmoreSkills_NormalizeItem(id)
    if not id or id == "" then
        return nil
    end
    local lower = strlower(strtrim(id))
    local aliases = {
        ["leatherworking tier 1"] = "lw1",
        ["engineering tier 1"] = "eng1",
        ["blacksmithing tier 1"] = "bs1",
        ["alchemy lab"] = "alch3",
        ["alchemy laboratory"] = "alch3",
        ["mana well"] = "alch1",
    }
    if aliases[lower] then
        return aliases[lower]
    end
    if tonumber(lower) then
        for _, row in ipairs(SmoreSkills.PROFESSION_ITEMS) do
            if row.itemId and tostring(row.itemId) == lower then
                return row.id
            end
            if row.itemIdByFaction then
                for _, itemId in pairs(row.itemIdByFaction) do
                    if tostring(itemId) == lower then
                        return row.id
                    end
                end
            end
        end
    end
    local item = ITEM_BY_ID[lower] or ITEM_BY_ID[id]
    if item then
        return item.id
    end
    for _, row in ipairs(SmoreSkills.PROFESSION_ITEMS) do
        if strlower(row.label) == lower or strlower(row.id) == lower then
            return row.id
        end
    end
    return nil
end

function SmoreSkills_ParseItemList(text)
    local list = {}
    local seen = {}
    if not text or text == "" or text == "any" then
        return list
    end
    for token in string.gmatch(text, "[^,]+") do
        local id = SmoreSkills_NormalizeItem(strtrim(token))
        if id and not seen[id] then
            seen[id] = true
            table.insert(list, id)
        end
    end
    return list
end

function SmoreSkills_FormatItems(text)
    local list = SmoreSkills_ParseItemList(text)
    if #list == 0 then
        return nil
    end
    local labels = {}
    for _, id in ipairs(list) do
        table.insert(labels, SmoreSkills_ItemLabel(id))
    end
    return table.concat(labels, ", ")
end

function DropItemsForProfession(text, profId)
    local kept = {}
    for _, id in ipairs(SmoreSkills_ParseItemList(text)) do
        local item = SmoreSkills_ItemFromId(id)
        if item and item.profession ~= profId then
            table.insert(kept, id)
        end
    end
    return table.concat(kept, ",")
end

function SmoreSkills_WantHasItem(wantKey, itemId)
    local text = wantKey == "seekerWant" and SmoreSkills_GetSeekerWantItems() or SmoreSkills_GetHostWantItems()
    itemId = SmoreSkills_NormalizeItem(itemId)
    if not itemId then
        return false
    end
    for _, id in ipairs(SmoreSkills_ParseItemList(text)) do
        if id == itemId then
            return true
        end
    end
    return false
end

function SmoreSkills_CountWantItems(wantKey)
    local text = wantKey == "seekerWant" and SmoreSkills_GetSeekerWantItems() or SmoreSkills_GetHostWantItems()
    return #SmoreSkills_ParseItemList(text)
end

function SmoreSkills_ToggleWantItem(wantKey, itemId)
    SmoreSkills_EnsureSettings()
    local item = SmoreSkills_ItemFromId(SmoreSkills_NormalizeItem(itemId))
    if not item then
        return false
    end
    if not SmoreSkills_WantHasProfession(wantKey, item.profession) then
        return false
    end
    local current = wantKey == "seekerWant" and SmoreSkills_GetSeekerWantItems() or SmoreSkills_GetHostWantItems()
    local list = SmoreSkills_ParseItemList(current)
    local found = false
    local nextList = {}
    for _, id in ipairs(list) do
        if id == item.id then
            found = true
        else
            table.insert(nextList, id)
        end
    end
    if not found then
        table.insert(nextList, item.id)
    end
    local joined = table.concat(nextList, ",")
    if wantKey == "seekerWant" then
        SmoreSkillsDB.settings.seekerWantItems = joined
    else
        SmoreSkillsDB.settings.hostWantItems = joined
        SmoreSkills_RefreshOwnedCampWant()
    end
    return true
end

function SmoreSkills_CampHasItem(camp, itemId)
    local item = SmoreSkills_ItemFromId(SmoreSkills_NormalizeItem(itemId))
    if not camp or not item then
        return false
    end
    SmoreSkills_EnsureSlots(camp)
    local needle = strlower(item.label)
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        if slot then
            local object = slot.object and strlower(strtrim(slot.object)) or ""
            if object ~= "" then
                if object == strlower(item.id) or object == needle or object:find(needle, 1, true) then
                    return true
                end
            elseif slot.profession == item.profession then
                -- TBC stand-in: object name unknown, treat the trade as the item.
                return true
            end
        end
    end
    return false
end

function SmoreSkills_SeekerCanProvideItems(seekerProfession, items)
    local list = SmoreSkills_ParseItemList(items)
    if #list == 0 then
        return true
    end
    local profs = {}
    if type(seekerProfession) == "table" then
        for _, id in ipairs(seekerProfession) do
            local n = SmoreSkills_NormalizeProfession(id)
            if n then
                profs[n] = true
            end
        end
    else
        local n = SmoreSkills_NormalizeProfession(seekerProfession)
        if n then
            profs[n] = true
        end
    end
    for _, itemId in ipairs(list) do
        local item = SmoreSkills_ItemFromId(itemId)
        if item and profs[item.profession] then
            return true
        end
    end
    return false
end

function SmoreSkills_FormatWant(want, items)
    local profs, wireItems = SmoreSkills_SplitWantWire(want)
    items = items or wireItems
    if not profs or profs == "any" then
        return "Anyone"
    end
    if profs == "none" or profs == "" then
        return "None selected"
    end
    local labels = {}
    for token in string.gmatch(profs, "[^,]+") do
        local id = SmoreSkills_NormalizeProfession(token)
        table.insert(labels, SmoreSkills_ProfessionLabel(id or token))
    end
    local text = table.concat(labels, ", ")
    local itemText = SmoreSkills_FormatItems(items)
    if itemText then
        return text .. " — " .. itemText
    end
    return text
end

function SmoreSkills_AppendHostWantTooltipLines(lines, want, items)
    if not lines then
        return lines
    end
    local profs, wireItems = SmoreSkills_SplitWantWire(want)
    items = items or wireItems
    if profs and profs ~= "any" and profs ~= "none" and profs ~= "" then
        table.insert(lines, SmoreSkills_TooltipLabeledLine("Host wants (professions):", SmoreSkills_FormatWant(profs)))
    end
    local itemText = SmoreSkills_FormatItems(items)
    if itemText then
        table.insert(lines, SmoreSkills_TooltipLabeledLine("Host wants (camping objects):", itemText))
    end
    return lines
end

function SmoreSkills_WantAccepts(want, professionId)
    local profs = SmoreSkills_SplitWantWire(want or "any")
    want = profs
    if want == "any" then
        return true
    end
    if want == "none" or want == "" then
        return false
    end
    local need = SmoreSkills_NormalizeProfession(professionId)
    if not need then
        return false
    end
    for token in string.gmatch(want, "[^,]+") do
        if SmoreSkills_NormalizeProfession(strtrim(token)) == need then
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

function SmoreSkills_MapsShareZone(a, b)
    a, b = tonumber(a), tonumber(b)
    if not a or not b then
        return false
    end
    if a == b then
        return true
    end
    if not C_Map or not C_Map.GetMapInfo then
        return false
    end
    local ia = C_Map.GetMapInfo(a)
    local ib = C_Map.GetMapInfo(b)
    return ia and ib and ia.name and ia.name ~= "" and ia.name == ib.name
end

function SmoreSkills_MapIsAncestor(ancestorId, childId)
    ancestorId, childId = tonumber(ancestorId), tonumber(childId)
    if not ancestorId or not childId then
        return false
    end
    local id = childId
    for _ = 1, 8 do
        if id == ancestorId then
            return true
        end
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(id)
        if not info or not info.parentMapID or info.parentMapID == 0 then
            return false
        end
        id = info.parentMapID
    end
    return false
end

function SmoreSkills_MapsAreNested(a, b)
    a, b = tonumber(a), tonumber(b)
    if not a or not b or a == b then
        return false
    end
    return SmoreSkills_MapIsAncestor(a, b) or SmoreSkills_MapIsAncestor(b, a)
end

local lastLayerId = 0
local lastLayerMapId = nil
local announcedLayerMapId = nil
-- Unique shard ids per zone, mapped to Layer 1, 2, 3… for YOUR camp tooltip only.
local layerOrder = {}

local function LayerMapKey(mapId)
    mapId = tonumber(mapId)
    if C_Map and C_Map.GetMapInfo and mapId then
        local info = C_Map.GetMapInfo(mapId)
        if info and info.name and info.name ~= "" then
            return "n:" .. info.name
        end
    end
    if mapId then
        return "m:" .. tostring(mapId)
    end
    return "unknown"
end

function SmoreSkills_NoteLayerId(layerId, mapId)
    layerId = tonumber(layerId)
    if not layerId or layerId <= 0 then
        return
    end
    if not mapId and SmoreSkills_GetPlayerMapPos then
        mapId = select(1, SmoreSkills_GetPlayerMapPos())
    end
    local key = LayerMapKey(mapId)
    local list = layerOrder[key]
    if not list then
        list = {}
        layerOrder[key] = list
    end
    for i = 1, #list do
        if list[i] == layerId then
            return
        end
    end
    table.insert(list, layerId)
    table.sort(list)
end

function SmoreSkills_LayerOrdinal(layerId, mapId)
    layerId = tonumber(layerId)
    if not layerId or layerId <= 0 then
        return nil
    end
    SmoreSkills_NoteLayerId(layerId, mapId)
    local list = layerOrder[LayerMapKey(mapId)]
    if not list then
        return nil
    end
    for i = 1, #list do
        if list[i] == layerId then
            return i
        end
    end
    return nil
end


local function LayerIdFromGuid(guid)
    if not guid or guid == "" then
        return nil
    end
    local unitType, _, _, _, zoneUID = strsplit("-", guid)
    if unitType ~= "Creature" and unitType ~= "Vehicle" and unitType ~= "GameObject" then
        return nil
    end
    local id = tonumber(zoneUID)
    if id and id > 0 then
        return id
    end
    return nil
end

local function LayerIdFromUnit(unit)
    if not unit or unit == "" then
        return nil
    end
    if not UnitExists or not UnitExists(unit) then
        return nil
    end
    if UnitIsPlayer and UnitIsPlayer(unit) then
        return nil
    end
    if UnitPlayerControlled and UnitPlayerControlled(unit) then
        return nil
    end
    return LayerIdFromGuid(UnitGUID(unit))
end

local function CurrentLayerMapId()
    if C_Map and C_Map.GetBestMapForUnit then
        return C_Map.GetBestMapForUnit("player")
    end
    return nil
end

local function ResetLayerIfMapChanged()
    local mapId = CurrentLayerMapId()
    if not mapId then
        return
    end
    if lastLayerMapId and mapId ~= lastLayerMapId
        and not (SmoreSkills_MapsShareZone and SmoreSkills_MapsShareZone(mapId, lastLayerMapId)) then
        lastLayerId = 0
        announcedLayerMapId = nil
    end
    lastLayerMapId = mapId
end

local function MaybeAnnounceLayer(id)
    id = tonumber(id)
    local mapId = CurrentLayerMapId()
    if not id or id <= 0 or not mapId or announcedLayerMapId == mapId then
        return
    end
    announcedLayerMapId = mapId
    if SmoreSkills_GetChatEnabled and not SmoreSkills_GetChatEnabled() then
        return
    end
    local text = SmoreSkills_FormatLayer and SmoreSkills_FormatLayer(id, mapId)
    local zone = GetRealZoneText and GetRealZoneText() or GetZoneText and GetZoneText() or "this zone"
    if text then
        SmoreSkills_Print(text .. " in " .. tostring(zone))
    end
end

function SmoreSkills_ResolveCampLayer(camp)
    if not camp then
        return nil
    end
    local hostLayer = tonumber(camp.layer)
    if hostLayer and hostLayer > 0 then
        SmoreSkills_NoteLayerId(hostLayer, camp.mapId)
        return hostLayer
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        hostLayer = SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId() or nil
        if hostLayer and hostLayer > 0 then
            camp.layer = hostLayer
            return hostLayer
        end
    end
    return nil
end

local function StampOwnedCampLayer(id)
    id = tonumber(id)
    if not id or id <= 0 then
        return
    end
    lastLayerId = id
    lastLayerMapId = CurrentLayerMapId() or lastLayerMapId
    local mapId = SmoreSkills_GetPlayerMapPos and select(1, SmoreSkills_GetPlayerMapPos()) or lastLayerMapId
    SmoreSkills_NoteLayerId(id, mapId)
    local camp = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
    if camp then
        SmoreSkills_NoteLayerId(id, camp.mapId)
        camp.layer = id
    end
    MaybeAnnounceLayer(id)
end

local function RememberLayer(id)
    id = tonumber(id)
    if not id or id <= 0 then
        return nil
    end
    StampOwnedCampLayer(id)
    return id
end

function SmoreSkills_GetPlayerLayerId()
    ResetLayerIfMapChanged()
    local units = {
        "target", "mouseover", "npc",
        "softenemy", "softfriend", "softinteract",
    }
    for i = 1, 4 do
        table.insert(units, "party" .. i)
    end
    for i = 1, 40 do
        table.insert(units, "nameplate" .. i)
    end
    for i = 1, #units do
        local id = LayerIdFromUnit(units[i])
        if id then
            return RememberLayer(id)
        end
    end
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local plates = C_NamePlate.GetNamePlates()
        if plates then
            for i = 1, #plates do
                local plate = plates[i]
                local unit = plate and (plate.namePlateUnitToken or plate.unit or (plate.UnitFrame and plate.UnitFrame.unit))
                if unit then
                    local id = LayerIdFromUnit(unit)
                    if id then
                        return RememberLayer(id)
                    end
                end
            end
        end
    end
    if lastLayerId and lastLayerId > 0 then
        StampOwnedCampLayer(lastLayerId)
        return lastLayerId
    end
    return nil
end

function SmoreSkills_FormatLayer(layerId, mapId, ordinal)
    local n = tonumber(ordinal)
    if not n or n <= 0 then
        n = SmoreSkills_LayerOrdinal(layerId, mapId)
    end
    if not n then
        return nil
    end
    return "Layer " .. tostring(n)
end

function SmoreSkills_FormatLayerCompare(hostLayer, mapId, isOwnCamp, ordinal)
    hostLayer = tonumber(hostLayer)
    local hostText = SmoreSkills_FormatLayer(hostLayer, mapId, (not isOwnCamp) and ordinal or nil)
    if isOwnCamp then
        if hostText then
            return hostText .. " — Your camp"
        end
        return "Layer ? — Your camp"
    end
    if not hostLayer or hostLayer <= 0 then
        return hostText
    end
    local mine = SmoreSkills_GetPlayerLayerId()
    if not mine then
        if hostText then
            return hostText
        end
        return "Layer unknown — target a nearby NPC"
    end
    if mine == hostLayer then
        return (hostText or "Layer ?") .. " — same as you"
    end
    local mineText = SmoreSkills_FormatLayer(mine, mapId)
    if hostText and mineText then
        return hostText .. " — you are on " .. mineText
    end
    return "Different layer"
end

function SmoreSkills_InitLayerWatch()
    if SmoreSkills.layerWatch then
        return
    end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("ZONE_CHANGED_INDOORS")
    local function ScanLayer()
        SmoreSkills_GetPlayerLayerId()
    end
    local function ScanLayerSoon()
        ResetLayerIfMapChanged()
        ScanLayer()
        if C_Timer and C_Timer.After then
            C_Timer.After(0.5, ScanLayer)
            C_Timer.After(2, ScanLayer)
        end
    end
    f:SetScript("OnEvent", function(_, event)
        if event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED"
            or event == "ZONE_CHANGED_INDOORS" or event == "PLAYER_ENTERING_WORLD" then
            ScanLayerSoon()
            return
        end
        ScanLayer()
    end)
    if C_Timer and C_Timer.NewTicker then
        C_Timer.NewTicker(3, ScanLayer)
    end
    SmoreSkills.layerWatch = f
    ScanLayerSoon()
end

function SmoreSkills_HostMatchesSeeker(host, mapId, seekerProfession)
    if not host or not mapId then
        return false
    end
    if host.faction and host.faction ~= SmoreSkills_PlayerFaction() then
        return false
    end
    if host.mapId ~= mapId and not SmoreSkills_MapsShareZone(host.mapId, mapId) then
        return false
    end
    if SmoreSkills_CountEmptySlots(host) < 1 then
        return false
    end
    local hostWant = SmoreSkills_SplitWantWire(host.want or "any")
    -- Any one shared profession is enough. Extra trades on the seeker do not matter.
    if not SmoreSkills_WantAcceptsAny(hostWant, seekerProfession) then
        return false
    end
    return true
end

function SmoreSkills_SeekerWantsCamp(camp, seekerWant, seekerItems)
    local want, wireItems = SmoreSkills_SplitWantWire(seekerWant)
    seekerItems = seekerItems or wireItems
    if not seekerItems or seekerItems == "" then
        seekerItems = SmoreSkills_GetEffectiveSeekerWantItems()
    end
    if not want or want == "any" then
        return true
    end
    if want == "none" or want == "" then
        return false
    end
    local itemList = SmoreSkills_ParseItemList(seekerItems)
    if #itemList > 0 then
        for _, itemId in ipairs(itemList) do
            if SmoreSkills_CampHasItem(camp, itemId) then
                return true
            end
        end
        return false
    end
    local seekerIds = {}
    for token in string.gmatch(want, "[^,]+") do
        local id = SmoreSkills_NormalizeProfession(strtrim(token))
        if id then
            table.insert(seekerIds, id)
        end
    end
    local hostWant = SmoreSkills_SplitWantWire(camp.want or "any")
    -- Any overlap with what the host asked for, or with a placed camp object.
    if SmoreSkills_WantAcceptsAny(hostWant, seekerIds) then
        return true
    end
    SmoreSkills_EnsureSlots(camp)
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        if slot and slot.profession and SmoreSkills_WantAccepts(want, slot.profession) then
            return true
        end
    end
    return false
end

-- Pin clock starts when the fire was lit. Heartbeats must not extend it.
function SmoreSkills_CampLitTime(camp)
    if not camp then
        return 0
    end
    return tonumber(camp.litAt) or tonumber(camp.updatedAt) or 0
end

-- Realm seconds left from a snapshot. Same-scale GetServerTime subtracts elapsed
-- (an hour later the fire is dead). Unit jumps (ms vs sec, now==0) keep remaining.
local function RemainingAfterElapsed(remaining, savedClock)
    remaining = tonumber(remaining)
    if remaining == nil then
        return nil
    end
    local now = SmoreSkills_Now()
    savedClock = tonumber(savedClock)
    if now <= 0 or not savedClock or savedClock <= 0 then
        return remaining
    end
    local nowMs = now > 1000000000000
    local clockMs = savedClock > 1000000000000
    if nowMs ~= clockMs then
        return remaining
    end
    local elapsed = now - savedClock
    if elapsed < -60 then
        return remaining
    end
    return remaining - elapsed
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
    local remain = SmoreSkills_OwnedHostRemaining(camp)
    if remain ~= nil then
        return remain > 0
    end
    local lit = SmoreSkills_CampLitTime(camp)
    if lit <= 0 then
        return false
    end
    return (SmoreSkills_Now() - lit) < (SmoreSkills.CAMPFIRE_DURATION or 1200)
end

-- Seconds left on YOUR fire. Realm elapsed from the snapshot clock, then session GetTime.
function SmoreSkills_OwnedHostRemaining(camp)
    if not camp or camp.packed then
        return nil
    end
    local me = SmoreSkills_PlayerName and SmoreSkills_PlayerName()
    local mine = SmoreSkills_PlayerNamesMatch(camp.owner, me)
        or (SmoreSkillsDB and SmoreSkillsDB.hostCampId and camp.id == SmoreSkillsDB.hostCampId)
    if not mine then
        return nil
    end
    local duration = SmoreSkills.CAMPFIRE_DURATION or 1200
    local db = SmoreSkillsHostDB
    local remaining = type(db) == "table" and tonumber(db.remaining)
    local savedClock = type(db) == "table" and tonumber(db.clock)
    if not remaining and SmoreSkillsDB then
        remaining = tonumber(SmoreSkillsDB.hostSnapRemaining)
        savedClock = savedClock or tonumber(SmoreSkillsDB.hostSnap_clock)
    end
    local realmLeft = RemainingAfterElapsed(remaining, savedClock)
    if realmLeft == nil then
        local lit = SmoreSkills_CampLitTime(camp)
        local now = SmoreSkills_Now()
        if lit > 0 and now > 0 then
            realmLeft = duration - (now - lit)
        end
    end
    if realmLeft ~= nil and realmLeft <= 0 then
        return 0
    end
    local sync = SmoreSkills.Sync
    if sync and tonumber(sync.hostRemainAt) then
        local sessionLeft = (tonumber(sync.hostRemainAt) or 0)
            - (((GetTime and GetTime()) or 0) - (tonumber(sync.hostRemainStarted) or 0))
        if realmLeft ~= nil then
            if sessionLeft < realmLeft then
                return sessionLeft
            end
            return realmLeft
        end
        return sessionLeft
    end
    if realmLeft ~= nil then
        return realmLeft
    end
    return 0
end

function SmoreSkills_CampHiddenReason(camp, mapId, seekerProfession)
    if not camp then
        return "missing"
    end
    if SmoreSkills_CountEmptySlots(camp) < 1 then
        return "full (3/3)"
    end
    if camp.packed then
        return "packed up"
    end
    local lit = SmoreSkills_CampLitTime(camp)
    if lit <= 0 or (SmoreSkills_Now() - lit) >= (SmoreSkills.CAMPFIRE_DURATION or 1200) then
        return "expired"
    end
    if not SmoreSkills_IsHostedCamp(camp) then
        return "not a host pin"
    end
    if mapId and camp.mapId ~= mapId and not SmoreSkills_MapsShareZone(camp.mapId, mapId) then
        return "wrong zone"
    end
    if not SmoreSkills_HostMatchesSeeker(camp, mapId or camp.mapId, seekerProfession) then
        return "does not match"
    end
    if not SmoreSkills_SeekerWantsCamp(camp, SmoreSkills_GetEffectiveSeekerWant()) then
        return "seeker filter"
    end
    if not SmoreSkills_LayerAllowsCamp(camp) then
        return "different layer"
    end
    return nil
end

-- Map pins are hosts only. Seekers never get a pin; leftover C: snapshots do not show.
-- Your own fire lives in SavedVariables — after /reload it is still a host pin.
function SmoreSkills_IsHostedCamp(camp)
    if not camp then
        return false
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        return true
    end
    if camp.source == "host" then
        return true
    end
    local sync = SmoreSkills.Sync
    if sync and camp.id and sync.hostCampId == camp.id and sync.IsHosting and sync:IsHosting() then
        return true
    end
    return false
end

function SmoreSkills_CampVisibleToSeeker(camp, mapId, seekerProfession)
    if not camp then
        return false
    end
    if not SmoreSkills_CampPinActive(camp) then
        return false
    end
    if not SmoreSkills_IsHostedCamp(camp) then
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
    if not SmoreSkills_SeekerWantsCamp(camp, SmoreSkills_GetEffectiveSeekerWant()) then
        return false
    end
    return SmoreSkills_LayerAllowsCamp(camp)
end

function SmoreSkills_LayerAllowsCamp(camp)
    if SmoreSkills_GetCrossLayerEnabled and SmoreSkills_GetCrossLayerEnabled() then
        return true
    end
    if not camp then
        return true
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        return true
    end
    local mine = SmoreSkills_GetPlayerLayerId and SmoreSkills_GetPlayerLayerId() or nil
    local host = tonumber(camp.layer)
    if not mine or not host or host == 0 then
        return true
    end
    return mine == host
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

local function MapTypeWorld()
    return (Enum and Enum.UIMapType and Enum.UIMapType.World) or 1
end

local function MapTypeContinent()
    return (Enum and Enum.UIMapType and Enum.UIMapType.Continent) or 2
end

local function CountChildMaps(mapId, mapType, recursive)
    if not C_Map or not C_Map.GetMapChildrenInfo or not mapId then
        return 0
    end
    local kids = C_Map.GetMapChildrenInfo(mapId, mapType, recursive)
    if not kids then
        return 0
    end
    return #kids
end

-- Pins on the playable map: zone / city / dungeon, and continent-typed
-- leaf islands (Zephras sits under World like Kalimdor but is the zone you
-- camp on). EK / Kalimdor stay empty — they have many zone children.
function SmoreSkills_MapViewShowsCampPins(mapId)
    mapId = tonumber(mapId)
    if not mapId then
        return false
    end
    if not C_Map or not C_Map.GetMapInfo then
        return true
    end
    local info = C_Map.GetMapInfo(mapId)
    local mapType = info and info.mapType
    if not mapType then
        return true
    end
    if mapType > MapTypeContinent() then
        return true
    end
    if mapType <= MapTypeWorld() then
        return false
    end
    local zones = CountChildMaps(mapId, MapTypeZone(), true)
    if zones <= 3 then
        return true
    end
    local best = C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    return tonumber(best) == mapId
end

function SmoreSkills_FormatMapStatus(mapId)
    mapId = tonumber(mapId)
    if not mapId then
        return "?"
    end
    local name, mapType = tostring(mapId), nil
    if C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapId)
        if info then
            name = info.name or name
            mapType = info.mapType
        end
    end
    local typeName = "?"
    local types = Enum and Enum.UIMapType
    if types then
        for key, value in pairs(types) do
            if type(key) == "string" and value == mapType then
                typeName = key
                break
            end
        end
    elseif mapType then
        local fallback = { [0] = "Cosmic", [1] = "World", [2] = "Continent", [3] = "Zone", [4] = "Dungeon", [5] = "Micro", [6] = "Orphan" }
        typeName = fallback[mapType] or tostring(mapType)
    end
    local pins = (not SmoreSkills_MapViewShowsCampPins or SmoreSkills_MapViewShowsCampPins(mapId)) and "pins" or "no pins"
    return string.format("%s (id %s, %s, %s)", name, tostring(mapId), typeName, pins)
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
    if not SmoreSkills_MapViewShowsCampPins(viewMapId) then
        return nil
    end
    -- Same zone, different uiMapID (Elwynn 37 vs 1429). Not Duskwood.
    if SmoreSkills_MapsShareZone(campMapId, viewMapId) then
        return x, y
    end
    -- Nested city/zone only (Stormwind on Elwynn). Sibling zones stay empty.
    if SmoreSkills_MapsAreNested(campMapId, viewMapId) and SmoreSkills_TranslateMapPos then
        local tx, ty = SmoreSkills_TranslateMapPos(camp.mapId, x, y, viewMapId)
        if tx and ty and tx >= 0 and tx <= 1 and ty >= 0 and ty <= 1 then
            return tx, ty
        end
    end
    return nil
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
    incoming.updatedAt = SmoreSkills_SanitizeCampTime(incoming.updatedAt)
    -- A live H: must apply even if a previous decode stored a bogus small timestamp.
    if existing and incoming.source ~= "host" and (incoming.updatedAt or 0) < (existing.updatedAt or 0) then
        return existing
    end
    incoming.id = id
    incoming.slots = incoming.slots or (existing and existing.slots) or EmptySlots()
    incoming.zone = incoming.zone or (existing and existing.zone)
    incoming.want = incoming.want or (existing and existing.want)
    incoming.wantItems = incoming.wantItems or (existing and existing.wantItems)
    if incoming.layer and incoming.layer ~= 0 then
        SmoreSkills_NoteLayerId(incoming.layer, incoming.mapId)
    elseif existing and existing.layer and existing.layer ~= 0 then
        incoming.layer = existing.layer
        SmoreSkills_NoteLayerId(incoming.layer, incoming.mapId)
    end
    if incoming.layerOrdinal and incoming.layerOrdinal ~= 0 then
        -- keep host's display number
    elseif existing and existing.layerOrdinal and existing.layerOrdinal ~= 0 then
        incoming.layerOrdinal = existing.layerOrdinal
    end
    if existing and existing.source == "host" and incoming.source ~= "host" then
        incoming.source = existing.source
    end
    incoming.source = incoming.source or (existing and existing.source)
    SmoreSkills_EnsureSlots(incoming)
    incoming.litAt = incoming.litAt or (existing and existing.litAt) or incoming.updatedAt
    incoming.litAt = tonumber(incoming.litAt) or incoming.updatedAt
    if incoming.source == "host" then
        local stamp = tonumber(incoming.litAt) or incoming.updatedAt or 0
        if existing and existing.packed and existing.packedAt
            and stamp <= existing.packedAt then
            incoming.packed = true
            incoming.packedAt = existing.packedAt
        else
            incoming.packed = nil
            incoming.packedAt = nil
            if existing and existing.packed then
                incoming.litAt = stamp
            elseif existing and existing.litAt then
                -- Keep the original light. Old clients send "now" on every H:.
                local oldLit = tonumber(existing.litAt) or 0
                local live = oldLit > 0 and (SmoreSkills_Now() - oldLit) < (SmoreSkills.CAMPFIRE_DURATION or 1200)
                if live and stamp >= oldLit then
                    incoming.litAt = oldLit
                end
            end
        end
    elseif existing and existing.packed then
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
        if SmoreSkills_PlayerNamesMatch(camp.owner, me) and not camp.packed then
            if (not tonumber(camp.litAt) or tonumber(camp.litAt) <= 0) and camp.updatedAt then
                camp.litAt = tonumber(camp.updatedAt)
            end
            if SmoreSkills_CampPinActive(camp) then
                camp.source = "host"
                if not best or (camp.litAt or 0) > (best.litAt or 0) then
                    best = camp
                end
            end
        end
    end
    return best
end

local function WipeHostDB(db)
    db = db or SmoreSkillsHostDB
    if type(db) ~= "table" then
        SmoreSkillsHostDB = {}
        return SmoreSkillsHostDB
    end
    if wipe then
        wipe(db)
    else
        for k in pairs(db) do
            db[k] = nil
        end
    end
    return db
end

local function EnsureHostDB()
    if type(SmoreSkillsHostDB) ~= "table" then
        SmoreSkillsHostDB = {}
    end
    return SmoreSkillsHostDB
end

function SmoreSkills_ClearOwnedHostSnapshot()
    local db = EnsureHostDB()
    WipeHostDB(db)
    db.v = 1
    if SmoreSkillsDB then
        SmoreSkillsDB.hostCampId = nil
        SmoreSkillsDB.hostSnapRemaining = nil
        for k in pairs(SmoreSkillsDB) do
            if type(k) == "string" and k:sub(1, 9) == "hostSnap_" then
                SmoreSkillsDB[k] = nil
            end
        end
    end
end

local HOST_SNAP_KEYS = {
    "id", "mapId", "x", "y", "zone", "faction", "owner", "want", "wantItems",
    "litAt", "updatedAt", "remaining", "clock", "layer", "layerOrdinal",
    "wantOverride", "slot1Override",
    "p1", "o1", "n1", "p2", "o2", "n2", "p3", "o3", "n3",
}

local function WriteAccountHostSnap(db)
    if type(SmoreSkillsDB) ~= "table" or type(db) ~= "table" then
        return
    end
    for i = 1, #HOST_SNAP_KEYS do
        local k = HOST_SNAP_KEYS[i]
        SmoreSkillsDB["hostSnap_" .. k] = db[k]
    end
    SmoreSkillsDB.hostSnapRemaining = db.remaining
    SmoreSkillsDB.hostCampId = db.id
end

local function ParseHostCampId(id)
    if type(id) ~= "string" or id == "" then
        return nil
    end
    local mapId, x, y = id:match("^(%d+):([%d%.eE+-]+):([%d%.eE+-]+)$")
    mapId, x, y = tonumber(mapId), tonumber(x), tonumber(y)
    if mapId and mapId > 0 and x and y then
        return mapId, x, y
    end
    return nil
end

local function ReadAccountHostSnap()
    if type(SmoreSkillsDB) ~= "table" then
        return nil
    end
    local db = {}
    for i = 1, #HOST_SNAP_KEYS do
        local k = HOST_SNAP_KEYS[i]
        db[k] = SmoreSkillsDB["hostSnap_" .. k]
    end
    if db.remaining == nil then
        db.remaining = SmoreSkillsDB.hostSnapRemaining
    end
    if (not tonumber(db.mapId) or not tonumber(db.x) or not tonumber(db.y)) and SmoreSkillsDB.hostCampId then
        local mapId, x, y = ParseHostCampId(SmoreSkillsDB.hostCampId)
        if mapId then
            db.mapId = db.mapId or mapId
            db.x = db.x or x
            db.y = db.y or y
            db.id = db.id or SmoreSkillsDB.hostCampId
        end
    end
    if tonumber(db.mapId) and tonumber(db.mapId) > 0 and tonumber(db.x) and tonumber(db.y) then
        return db
    end
    return nil
end

local function HostSnapHasCoords(db)
    return type(db) == "table"
        and tonumber(db.mapId) and tonumber(db.mapId) > 0
        and tonumber(db.x) and tonumber(db.y)
end

-- Flat primitives only. Nested camp tables in SmoreSkillsDB.camps did not survive /reload.
function SmoreSkills_SnapshotOwnedHost()
    local camp = SmoreSkills_GetOwnedActiveCamp and SmoreSkills_GetOwnedActiveCamp()
    if camp and SmoreSkills_CampPinActive(camp) then
        -- write below
    else
        local db = SmoreSkillsHostDB
        local rem = RemainingAfterElapsed(
            type(db) == "table" and db.remaining or (SmoreSkillsDB and SmoreSkillsDB.hostSnapRemaining),
            type(db) == "table" and db.clock or (SmoreSkillsDB and SmoreSkillsDB.hostSnap_clock)
        )
        if rem ~= nil and rem <= 0 and SmoreSkills_ClearOwnedHostSnapshot then
            SmoreSkills_ClearOwnedHostSnapshot()
        end
        return
    end
    local db = EnsureHostDB()
    local id = camp.id or SmoreSkills_CampId(camp.mapId, camp.x, camp.y)
    local litAt = tonumber(camp.litAt) or tonumber(camp.updatedAt) or SmoreSkills_Now()
    local updatedAt = tonumber(camp.updatedAt) or litAt
    WipeHostDB(db)
    db.v = 1
    db.id = id
    db.mapId = tonumber(camp.mapId) or 0
    db.x = tonumber(camp.x) or 0
    db.y = tonumber(camp.y) or 0
    db.zone = camp.zone or ""
    db.faction = camp.faction or ""
    db.owner = camp.owner or ""
    db.want = camp.want or "any"
    db.wantItems = camp.wantItems or ""
    db.litAt = litAt
    db.updatedAt = updatedAt
    local duration = SmoreSkills.CAMPFIRE_DURATION or 1200
    local now = SmoreSkills_Now()
    local remaining = SmoreSkills_OwnedHostRemaining(camp)
    if not remaining then
        remaining = duration - (now - litAt)
    end
    if remaining < 0 then
        remaining = 0
    elseif remaining > duration then
        remaining = duration
    end
    db.remaining = remaining
    db.clock = now
    db.layer = tonumber(camp.layer) or 0
    db.layerOrdinal = tonumber(camp.layerOrdinal) or 0
    db.wantOverride = camp.wantOverride and 1 or 0
    db.slot1Override = camp.slot1Override and 1 or 0
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots and camp.slots[i] or {}
        db["p" .. i] = slot.profession or ""
        db["o" .. i] = slot.object or ""
        db["n" .. i] = slot.player or ""
    end
    if SmoreSkillsDB then
        SmoreSkillsDB.hostCampId = id
        SmoreSkillsDB.hostSnapRemaining = remaining
        WriteAccountHostSnap(db)
    end
end

-- Returns camp, or nil plus why it was turned down, so login can say so out loud.
function SmoreSkills_RestoreOwnedHost()
    local db = HostSnapHasCoords(SmoreSkillsHostDB) and SmoreSkillsHostDB or nil
    db = db or ReadAccountHostSnap()
    if not HostSnapHasCoords(db) then
        return nil, "no saved campfire"
    end
    local mapId = tonumber(db.mapId)
    local x, y = tonumber(db.x), tonumber(db.y)
    local camp = {
        id = db.id or SmoreSkills_CampId(mapId, x, y),
        mapId = mapId,
        x = x,
        y = y,
        zone = (db.zone ~= "" and db.zone) or nil,
        faction = (db.faction ~= "" and db.faction) or nil,
        owner = (db.owner ~= "" and db.owner) or nil,
        want = db.want or "any",
        wantItems = db.wantItems or "",
        source = "host",
        litAt = tonumber(db.litAt) or tonumber(db.updatedAt),
        updatedAt = tonumber(db.updatedAt) or tonumber(db.litAt),
        layer = tonumber(db.layer),
        layerOrdinal = tonumber(db.layerOrdinal),
        wantOverride = tonumber(db.wantOverride) == 1 or nil,
        slot1Override = tonumber(db.slot1Override) == 1 or nil,
        slots = {},
    }
    if not camp.litAt or camp.litAt <= 0 then
        camp.litAt = SmoreSkills_Now()
        camp.updatedAt = camp.updatedAt or camp.litAt
    end
    if camp.layer == 0 then
        camp.layer = nil
    end
    if camp.layerOrdinal == 0 then
        camp.layerOrdinal = nil
    end
    for i = 1, SmoreSkills.MAX_SLOTS do
        local p = db["p" .. i]
        local o = db["o" .. i]
        local n = db["n" .. i]
        camp.slots[i] = {
            index = i,
            profession = (type(p) == "string" and p ~= "" and p) or nil,
            object = (type(o) == "string" and o ~= "" and o) or nil,
            player = (type(n) == "string" and n ~= "" and n) or nil,
        }
    end
    local duration = SmoreSkills.CAMPFIRE_DURATION or 1200
    local remaining = tonumber(db.remaining)
    if not remaining and SmoreSkillsDB then
        remaining = tonumber(SmoreSkillsDB.hostSnapRemaining)
    end
    if remaining == nil then
        local now = SmoreSkills_Now()
        local lit = tonumber(camp.litAt) or 0
        if now > 0 and lit > 0 then
            remaining = duration - (now - lit)
        else
            remaining = 0
        end
    else
        remaining = RemainingAfterElapsed(remaining, db.clock or db.litAt or (SmoreSkillsDB and SmoreSkillsDB.hostSnap_clock))
    end
    if not remaining or remaining <= 0 then
        if SmoreSkills_ClearOwnedHostSnapshot then
            SmoreSkills_ClearOwnedHostSnapshot()
        end
        return nil, "the fire burned out"
    end
    if remaining > duration then
        remaining = duration
    end
    camp.ttlLeft = remaining
    local now = SmoreSkills_Now()
    if now > 0 then
        camp.litAt = now - (duration - remaining)
        camp.updatedAt = now
    end
    SmoreSkillsDB = SmoreSkillsDB or { camps = {}, settings = { dataVersion = 1 } }
    SmoreSkillsDB.camps = SmoreSkillsDB.camps or {}
    SmoreSkillsDB.camps[camp.id] = camp
    SmoreSkillsDB.hostCampId = camp.id
    return camp
end

function SmoreSkills_ForEachOwnedActiveCamp(callback)
    if type(callback) ~= "function" then
        return
    end
    local me = SmoreSkills_PlayerName()
    for _, camp in pairs(SmoreSkillsDB.camps or {}) do
        if SmoreSkills_PlayerNamesMatch(camp.owner, me) and SmoreSkills_CampPinActive(camp) and SmoreSkills_IsHostedCamp(camp) then
            callback(camp)
        end
    end
end

-- Same fire, not a new campsite. Nested city maps (Stormwind vs Elwynn) are different sites.
function SmoreSkills_CampsShareSite(camp, mapId, x, y)
    if not camp or not mapId then
        return false
    end
    local cx, cy = tonumber(camp.x), tonumber(camp.y)
    x, y = tonumber(x), tonumber(y)
    if not cx or not cy or not x or not y then
        return false
    end
    if SmoreSkills_CampId(camp.mapId, cx, cy) == SmoreSkills_CampId(mapId, x, y) then
        return true
    end
    if camp.mapId ~= mapId and not SmoreSkills_MapsShareZone(camp.mapId, mapId) then
        return false
    end
    local dx, dy = cx - x, cy - y
    return (dx * dx + dy * dy) < (0.012 * 0.012)
end

function SmoreSkills_AlreadyHaveCampMessage(camp)
    camp = camp or SmoreSkills_GetOwnedActiveCamp()
    local where = (camp and camp.zone and camp.zone ~= "") and (" in " .. camp.zone) or ""
    local left = 0
    if camp then
        local lit = SmoreSkills_CampLitTime(camp)
        if lit <= 0 then
            lit = SmoreSkills_Now()
        end
        left = math.max(0, math.ceil((lit + (SmoreSkills.CAMPFIRE_DURATION or 1200)) - SmoreSkills_Now()))
    end
    local wait
    if left >= 60 then
        wait = string.format("%d min", math.floor(left / 60))
    else
        wait = string.format("%d sec", left)
    end
    return string.format(
        "You already have a camp%s. Wait for it to expire (~%s), or pack it up from the world map pin or with /smores pack.",
        where,
        wait
    )
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
    local owned = SmoreSkills_GetOwnedActiveCamp()
    if owned then
        local id = SmoreSkills_CampId(mapId, x, y)
        if owned.id and owned.id ~= id then
            return nil, SmoreSkills_AlreadyHaveCampMessage(owned)
        end
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

SmoreSkills.TEST_CAMP_OWNER = "S'more-enjoyer"

function SmoreSkills_IsTestCamp(camp)
    local owner = camp and camp.owner
    return owner == SmoreSkills.TEST_CAMP_OWNER or owner == "TestCamper"
end

function SmoreSkills_ClearTestCamps()
    for id, camp in pairs(SmoreSkillsDB.camps or {}) do
        if SmoreSkills_IsTestCamp(camp) then
            SmoreSkillsDB.camps[id] = nil
            if SmoreSkills.Sync and SmoreSkills.Sync.seekDiscoveredIds then
                SmoreSkills.Sync.seekDiscoveredIds[id] = nil
            end
        end
    end
end

-- Other people's pins only after Find recorded them. Your own hosted pin is always local.
function SmoreSkills_CampDiscoveredForSeeker(camp)
    if not camp or not camp.id then
        return false
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        return true
    end
    local sync = SmoreSkills.Sync
    return sync and sync.seekDiscoveredIds and sync.seekDiscoveredIds[camp.id] and true or false
end

local function SmoreSkills_MaybeAddVisibleCamp(list, seen, camp, mapId, seekerProfession)
    if not camp or not camp.id or seen[camp.id] then
        return
    end
    if camp.faction and camp.faction ~= SmoreSkills_PlayerFaction() then
        return
    end
    if not SmoreSkills_CampDiscoveredForSeeker(camp) then
        return
    end
    -- Do not list an Elwynn camp on Duskwood. Nested city maps still list.
    if mapId and camp.mapId ~= mapId and not SmoreSkills_MapsShareZone(camp.mapId, mapId)
        and not (SmoreSkills_MapsAreNested and SmoreSkills_MapsAreNested(camp.mapId, mapId)) then
        return
    end
    if not SmoreSkills_CampVisibleToSeeker(camp, camp.mapId, seekerProfession) then
        return
    end
    table.insert(list, camp)
    seen[camp.id] = true
end

function SmoreSkills_ListVisibleCamps(mapId)
    if SmoreSkills_ClearTestCamps then
        SmoreSkills_ClearTestCamps()
    end
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
    SmoreSkills_ClearTestCamps()
    local now = SmoreSkills_Now()
    local me = SmoreSkills_PlayerName()
    for id, camp in pairs(SmoreSkillsDB.camps or {}) do
        local owned = SmoreSkills_PlayerNamesMatch(camp.owner, me)
        local liveOwned = owned and not camp.packed and SmoreSkills_CampPinActive(camp)
        if liveOwned then
            -- Hosted fire stays until pack / 3/3 / 20 min, including across /reload.
        elseif owned then
            SmoreSkillsDB.camps[id] = nil
            if SmoreSkills.Sync and SmoreSkills.Sync.seekDiscoveredIds then
                SmoreSkills.Sync.seekDiscoveredIds[id] = nil
            end
            -- Only the clock or a pack-up may destroy the snapshot. Everything else can be retried.
            local lit = SmoreSkills_CampLitTime(camp)
            local burnedOut = lit <= 0 or (now - lit) >= (SmoreSkills.CAMPFIRE_DURATION or 1200)
            if (camp.packed or burnedOut)
                and SmoreSkillsHostDB and SmoreSkillsHostDB.id == id
                and SmoreSkills_ClearOwnedHostSnapshot then
                SmoreSkills_ClearOwnedHostSnapshot()
            end
        elseif (now - (camp.updatedAt or camp.litAt or 0)) > maxAge then
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

function SmoreSkills_ShowCampGuildMark(camp)
    if not camp then
        return false
    end
    if not SmoreSkills_GetShowGuildMark or not SmoreSkills_GetShowGuildMark() then
        return false
    end
    if SmoreSkills_PlayerNamesMatch(camp.owner, SmoreSkills_PlayerName()) then
        return false
    end
    return SmoreSkills_CampHasGuildie(camp) and true or false
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

function SmoreSkills_TooltipLabeledLine(title, rest)
    if not rest or rest == "" then
        return "|cffffffff" .. (title or "") .. "|r"
    end
    return "|cffffffff" .. (title or "") .. "|r |cffbcbcbc" .. rest .. "|r"
end

function SmoreSkills_FormatSlotTooltipLine(camp, index)
    SmoreSkills_EnsureSlots(camp)
    local slot = camp.slots[index]
    if index == 1 then
        if slot and slot.profession then
            local rest = SmoreSkills_ProfessionLabel(slot.profession)
            if slot.object and slot.object ~= "" then
                rest = rest .. " (" .. SmoreSkills_FormatObjectWithNote(slot.object) .. ")"
            end
            if slot.player and slot.player ~= "" then
                rest = rest .. " — " .. slot.player
            elseif camp.owner and camp.owner ~= "" then
                rest = rest .. " — " .. camp.owner
            end
            return SmoreSkills_TooltipLabeledLine("Host:", rest)
        end
        return SmoreSkills_TooltipLabeledLine("Host:", camp.owner or "Unknown")
    end
    local title = string.format("Spot %d:", index)
    if slot and slot.profession then
        local rest = SmoreSkills_ProfessionLabel(slot.profession)
        if slot.object and slot.object ~= "" then
            rest = rest .. " (" .. SmoreSkills_FormatObjectWithNote(slot.object) .. ")"
        end
        if slot.player and slot.player ~= "" then
            rest = rest .. " — " .. slot.player
        end
        return SmoreSkills_TooltipLabeledLine(title, rest)
    end
    return SmoreSkills_TooltipLabeledLine(title, "Open")
end

function SmoreSkills_FormatSlots(camp)
    SmoreSkills_EnsureSlots(camp)
    local parts = {}
    for i = 1, SmoreSkills.MAX_SLOTS do
        local slot = camp.slots[i]
        if slot and slot.profession then
            local label = SmoreSkills_ProfessionLabel(slot.profession)
            if slot.object and slot.object ~= "" then
                table.insert(parts, string.format("%s (%s)", label, SmoreSkills_FormatObjectWithNote(slot.object)))
            else
                table.insert(parts, label)
            end
        else
            table.insert(parts, "empty")
        end
    end
    return table.concat(parts, " · ")
end
