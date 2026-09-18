local ADDON_NAME = ...

if not strtrim then
    function strtrim(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
end

SmoreSkills = SmoreSkills or {}
SmoreSkills.VERSION = "0.5.78"
SmoreSkills.AUTHOR = "Weber8210"
SmoreSkills.TESTER = "Stik"
SmoreSkills.LOGO = "Interface\\AddOns\\SmoreSkills\\Art\\SmoreSkillsLogo"
SmoreSkills.ICON = "Interface\\AddOns\\SmoreSkills\\Art\\SmoreSkillsIcon"

-- Camp TTL uses the realm clock only. `time()` is the PC clock (Denmark);
-- GetServerTime is the US realm. Mixing them is a 9 hour jump and burns the pin.
function SmoreSkills_Now()
    local t = GetServerTime and GetServerTime()
    t = tonumber(t)
    if t and t > 1000000000000 then
        t = math.floor(t / 1000)
    end
    if t and t > 0 then
        return t
    end
    return 0
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
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        SmoreSkillsDB = SmoreSkillsDB or { camps = {}, settings = { dataVersion = 1 } }
        SmoreSkillsDB.camps = SmoreSkillsDB.camps or {}
        SmoreSkillsDB.settings = SmoreSkillsDB.settings or { dataVersion = 1 }
        SmoreSkillsDB.learnedCamping = SmoreSkillsDB.learnedCamping or {}
        if type(SmoreSkillsHostDB) ~= "table" then
            SmoreSkillsHostDB = {}
        end
        -- 0.5.70 test builds mirrored the host snapshot account-wide. Drop those leftovers.
        SmoreSkillsDB.hostByChar = nil
        SmoreSkillsDB.sessionCount = nil
        for key in pairs(SmoreSkillsDB) do
            if type(key) == "string" and key:sub(1, 2) == "h_" then
                SmoreSkillsDB[key] = nil
            end
        end
        if SmoreSkills_RestoreOwnedHost then
            SmoreSkills_RestoreOwnedHost()
        end
        if ReloadUI and hooksecurefunc and not SmoreSkills._snapshotOnReloadHook then
            SmoreSkills._snapshotOnReloadHook = true
            hooksecurefunc("ReloadUI", function()
                if SmoreSkills_SnapshotOwnedHost then
                    SmoreSkills_SnapshotOwnedHost()
                end
            end)
        end
        if SmoreSkills.Sync and SmoreSkills.Sync.Init then
            SmoreSkills.Sync:Init()
        end
    elseif event == "PLAYER_LOGOUT" then
        if SmoreSkills_SnapshotOwnedHost then
            SmoreSkills_SnapshotOwnedHost()
        end
    elseif event == "PLAYER_LOGIN" then
        SmoreSkills_EnsureSettings()
        SmoreSkills_Print(string.format(
            "%s By %s loaded. Host a camp by placing down a Basic Campfire Kit or find camps in your zone by clicking the s'more on your world map. Happy camping :)",
            SmoreSkills.VERSION,
            SmoreSkills.AUTHOR or "Weber8210"
        ))
        if SmoreSkills.UI and SmoreSkills.UI.Init then
            local ok, err = pcall(function()
                SmoreSkills.UI:Init()
            end)
            if not ok then
                SmoreSkills_Print("UI init failed: " .. tostring(err))
            end
        end
        if SmoreSkills.Sync and SmoreSkills.Sync.OnLogin then
            local ok, err = pcall(function()
                SmoreSkills.Sync:OnLogin()
            end)
            if not ok then
                SmoreSkills_Print("Host restore failed: " .. tostring(err))
            end
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
    elseif event == "PLAYER_ENTERING_WORLD" then
        if SmoreSkills.Sync and SmoreSkills.Sync.RestoreHostSession then
            pcall(function()
                SmoreSkills.Sync:RestoreHostSession()
            end)
        end
        if SmoreSkills.Map and SmoreSkills.Map.RefreshPins then
            pcall(function()
                SmoreSkills.Map:RefreshPins()
            end)
        end
    end
end)
