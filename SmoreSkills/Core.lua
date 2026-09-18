local ADDON_NAME = ...

if not strtrim then
    function strtrim(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
end

SmoreSkills = SmoreSkills or {}
SmoreSkills.VERSION = "0.5.65"
SmoreSkills.AUTHOR = "Weber8210"
SmoreSkills.TESTER = "Stik"
SmoreSkills.LOGO = "Interface\\AddOns\\SmoreSkills\\Art\\SmoreSkillsLogo"
SmoreSkills.ICON = "Interface\\AddOns\\SmoreSkills\\Art\\SmoreSkillsIcon"

SmoreSkillsDB = SmoreSkillsDB or {
    camps = {},
    settings = { dataVersion = 1 },
}

function SmoreSkills_Now()
    if GetServerTime then
        return GetServerTime()
    end
    return time()
end

function SmoreSkills_Print(msg, force)
    if force ~= true and not SmoreSkills.forceChat then
        if SmoreSkills_GetChatEnabled and not SmoreSkills_GetChatEnabled() then
            return
        end
    end
    print("|cffffff00S'more Skills|r " .. (msg or ""))
end

function SmoreSkills_Reply(msg)
    SmoreSkills_Print(msg, true)
end

function SmoreSkills_PlayerFaction()
    return UnitFactionGroup("player") or "Unknown"
end

function SmoreSkills_PlayerName()
    return UnitName("player") or "Unknown"
end

function SmoreSkills_PlayerNamesMatch(a, b)
    if not a or not b then
        return false
    end
    a = strlower(a)
    b = strlower(b)
    if a == b then
        return true
    end
    local aShort = a:match("^([^%-]+)") or a
    local bShort = b:match("^([^%-]+)") or b
    return aShort == bShort
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        SmoreSkillsDB = SmoreSkillsDB or { camps = {}, settings = { dataVersion = 1 } }
        SmoreSkillsDB.camps = SmoreSkillsDB.camps or {}
        SmoreSkillsDB.settings = SmoreSkillsDB.settings or { dataVersion = 1 }
        SmoreSkillsDB.learnedCamping = SmoreSkillsDB.learnedCamping or {}
        if SmoreSkills.Sync and SmoreSkills.Sync.Init then
            SmoreSkills.Sync:Init()
        end
    elseif event == "PLAYER_LOGIN" then
        SmoreSkills_EnsureSettings()
        SmoreSkills_Print(string.format(
            "%s By %s loaded. Host a camp by placing down a Basic Campfire Kit or find camps in your zone by clicking the s'more on your world map. Happy camping :)",
            SmoreSkills.VERSION,
            SmoreSkills.AUTHOR or "Weber8210"
        ))
        if SmoreSkills.UI and SmoreSkills.UI.Init then
            SmoreSkills.UI:Init()
        end
        if SmoreSkills.Sync and SmoreSkills.Sync.OnLogin then
            SmoreSkills.Sync:OnLogin()
        end
        if SmoreSkills.Settings and SmoreSkills.Settings.EnsureInit then
            SmoreSkills.Settings:EnsureInit()
        end
        if SmoreSkills.Map and SmoreSkills.Map.EnsureInit then
            pcall(function()
                SmoreSkills.Map:EnsureInit()
            end)
        end
        if SmoreSkills_InitLayerWatch then
            SmoreSkills_InitLayerWatch()
        end
    end
end)
