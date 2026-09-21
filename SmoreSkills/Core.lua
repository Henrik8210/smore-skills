local ADDON_NAME = ...

if not strtrim then
    function strtrim(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
end

SmoreSkills = SmoreSkills or {}
SmoreSkills.VERSION = "0.6.8"
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

-- "No Bunda" (UnitName) vs "No-Bunda" (folder) vs "No Bunda-Realm".
-- Do not split on the first hyphen — that is often part of the name.
function SmoreSkills_NormalizePlayerName(name)
    if type(name) ~= "string" then
        return nil
    end
    name = strlower(strtrim(name))
    if name == "" or name == "unknown" or name == "unk" then
        return nil
    end
    local cut = name:match("^(.-)%-.+$")
    if cut and cut:find("%s") then
        name = strtrim(cut)
    end
    name = name:gsub("%-", " "):gsub("%s+", " ")
    return name
end

function SmoreSkills_PlayerNamesMatch(a, b)
    a = SmoreSkills_NormalizePlayerName(a)
    b = SmoreSkills_NormalizePlayerName(b)
    if not a or not b then
        return false
    end
    if a == b then
        return true
    end
    return a:gsub("%s+", "") == b:gsub("%s+", "")
end

local function EnsureAccountDB()
    -- Only fill subkeys if Blizzard already applied the table. Creating
    -- SmoreSkillsDB when it is still nil can make the client skip the file.
    if type(SmoreSkillsDB) ~= "table" then
        return false
    end
    SmoreSkillsDB.camps = SmoreSkillsDB.camps or {}
    SmoreSkillsDB.settings = SmoreSkillsDB.settings or { dataVersion = 1 }
    SmoreSkillsDB.learnedCamping = SmoreSkillsDB.learnedCamping or {}
    SmoreSkillsDB.hostByChar = nil
    SmoreSkillsDB.sessionCount = nil
    for key in pairs(SmoreSkillsDB) do
        if type(key) == "string" and key:sub(1, 2) == "h_" then
            SmoreSkillsDB[key] = nil
        end
    end
    return true
end

local function TryRestoreHost(reason)
    if type(SmoreSkillsDB) == "table" then
        EnsureAccountDB()
    end
    -- Never create an empty SmoreSkillsDB just to have a table. Forever then
    -- skips the SavedVariables file and we lose the camp that is still on disk.
    if type(SmoreSkillsDB) ~= "table" then
        local blob = SmoreSkills_ReadHostPersistBlob and SmoreSkills_ReadHostPersistBlob()
        local hostDb = type(SmoreSkillsHostDB) == "table" and tonumber(SmoreSkillsHostDB.mapId)
        if blob or (hostDb and hostDb > 0) then
            SmoreSkillsDB = { camps = {}, settings = { dataVersion = 1 }, learnedCamping = {} }
        else
            return false
        end
    end
    if SmoreSkills.Sync and SmoreSkills.Sync.RestoreHostSession then
        return pcall(function()
            return SmoreSkills.Sync:RestoreHostSession()
        end)
    end
    if SmoreSkills_RestoreOwnedHost then
        return pcall(SmoreSkills_RestoreOwnedHost)
    end
    return false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        -- Do not create SmoreSkillsHostDB / SmoreSkillsHP here if they are nil.
        -- A late SavedVariables apply will still fill those globals.
        EnsureAccountDB()
        if hooksecurefunc and not SmoreSkills._snapshotOnReloadHook then
            SmoreSkills._snapshotOnReloadHook = true
            local function snapHost()
                if SmoreSkills_SnapshotOwnedHost then
                    SmoreSkills_SnapshotOwnedHost()
                end
                if SmoreSkills_SaveSettings then
                    SmoreSkills_SaveSettings()
                end
            end
            if ReloadUI then
                hooksecurefunc("ReloadUI", snapHost)
            end
            pcall(function()
                if C_UI and C_UI.Reload then
                    hooksecurefunc(C_UI, "Reload", snapHost)
                end
            end)
        end
        if SmoreSkills.Sync and SmoreSkills.Sync.Init then
            SmoreSkills.Sync:Init()
        end
        TryRestoreHost("loaded")
    elseif event == "VARIABLES_LOADED" then
        SmoreSkills._settingsSvReady = true
        TryRestoreHost("vars")
        if SmoreSkills_EnsureSettings then
            SmoreSkills_EnsureSettings()
        end
        if SmoreSkills_SaveSettings then
            SmoreSkills_SaveSettings()
        end
    elseif event == "PLAYER_LOGOUT" then
        if SmoreSkills_SnapshotOwnedHost then
            SmoreSkills_SnapshotOwnedHost()
        end
        if SmoreSkills_SaveSettings then
            SmoreSkills_SaveSettings()
        end
    elseif event == "PLAYER_LOGIN" then
        TryRestoreHost("login")
        if C_Timer and C_Timer.After and not SmoreSkills._hostPersistRetry then
            SmoreSkills._hostPersistRetry = true
            local delays = { 0.5, 1.5, 4, 8 }
            for i = 1, #delays do
                C_Timer.After(delays[i], function()
                    -- SavedVariables had their chance. If the global is still
                    -- missing (pack-up left no persist blob), create settings only.
                    if type(SmoreSkillsDB) ~= "table" and delays[i] >= 4 then
                        SmoreSkillsDB = { camps = {}, settings = { dataVersion = 1 }, learnedCamping = {} }
                    end
                    TryRestoreHost("retry")
                    if SmoreSkills_EnsureSettings then
                        SmoreSkills_EnsureSettings()
                    end
                    if SmoreSkills.Map and SmoreSkills.Map.RefreshPins then
                        pcall(function()
                            SmoreSkills.Map:RefreshPins()
                        end)
                    end
                end)
            end
        end
        if SmoreSkills_EnsureSettings then
            SmoreSkills_EnsureSettings()
        end
        SmoreSkills_Print(string.format(
            "%s By %s loaded. Host a camp by placing a Campfire Kit (Basic, Journeyman, or Expert) or find camps in your zone by clicking the s'more on your world map. Happy camping :)",
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
