local ADDON_NAME = ...

if not strtrim then
    function strtrim(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
end

SmoreSkills = SmoreSkills or {}
SmoreSkills.VERSION = "0.5.7"
SmoreSkills.LOGO = "Interface\\AddOns\\SmoreSkills\\Art\\SmoreSkillsLogo"
SmoreSkills.ICON = "Interface\\AddOns\\SmoreSkills\\Art\\SmoreSkillsIcon"

-- TBC testbed: inject a sample Ashenvale camp when seeking. /smores test off to disable.
SmoreSkills.ENABLE_TEST_CAMPS = true

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

function SmoreSkills_Print(msg)
    print("|cffffff00S'more Skills|r " .. (msg or ""))
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
    return strlower(a) == strlower(b)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        SmoreSkillsDB = SmoreSkillsDB or { camps = {}, settings = { dataVersion = 1 } }
        SmoreSkillsDB.camps = SmoreSkillsDB.camps or {}
        SmoreSkillsDB.settings = SmoreSkillsDB.settings or { dataVersion = 1 }
        if SmoreSkills.Sync and SmoreSkills.Sync.Init then
            SmoreSkills.Sync:Init()
        end
    elseif event == "PLAYER_LOGIN" then
        if SmoreSkills.UI and SmoreSkills.UI.Init then
            SmoreSkills.UI:Init()
        end
        if SmoreSkills.Sync and SmoreSkills.Sync.OnLogin then
            SmoreSkills.Sync:OnLogin()
        end
        if SmoreSkills.Map and SmoreSkills.Map.EnsureInit then
            SmoreSkills.Map:EnsureInit()
        end
        if SmoreSkills.Settings and SmoreSkills.Settings.EnsureInit then
            SmoreSkills.Settings:EnsureInit()
        end
        SmoreSkills_EnsureSettings()
    end
end)
