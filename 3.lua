-- ============================================================================
-- OPTIMIZED VERSION - Performance improvements only
-- No feature changes, no cheat additions, no gameplay modifications
-- ============================================================================

-- Per-match guard: allow re-init when the player controller changes (new match)
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then return end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

-- ============================================================================
-- OPTIMIZATION 1: Cache all frequently used global lookups (reduces table lookups)
-- ============================================================================
local pcall = pcall
local require = require
local import = import
local isValid = slua.isValid
local slua_GameFrontendHUD = slua_GameFrontendHUD
local Game = Game
local pairs = pairs
local ipairs = ipairs
local type = type
local string = string
local math = math
local os = os
local tostring = tostring
local tonumber = tonumber
local table = table

-- ============================================================================
-- OPTIMIZATION 2: Pre-allocate reusable tables (reduces GC pressure)
-- ============================================================================
local _EMPTY_TABLE = {}
local _EMPTY_ARRAY = {}
local _REUSABLE_POSITION = {X=0, Y=0, Z=0}
local _REUSABLE_COLOR = {R=0, G=0, B=0, A=255}

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return _EMPTY_TABLE end

_G.CheatsEnabled = true

-- ============================================================================
-- OPTIMIZATION 3: Cache import results (avoid repeated import calls)
-- ============================================================================
local CACHED_IMPORTS = {}
local function get_cached_import(name, import_path)
    local cached = CACHED_IMPORTS[import_path]
    if cached == nil then
        cached = import(import_path)
        CACHED_IMPORTS[import_path] = cached
    end
    return cached
end

-- ============================================================================
-- OPTIMIZATION 4: Lazy-loaded module cache (load only once)
-- ============================================================================
local MODULE_CACHE = {}
local function safe_require(path)
    local cached = MODULE_CACHE[path]
    if cached ~= nil then 
        return cached == false and nil or cached
    end
    local ok, mod = pcall(require, path)
    if ok then
        MODULE_CACHE[path] = mod
        return mod
    end
    MODULE_CACHE[path] = false
    return nil
end

-- ============================================================================
-- OPTIMIZATION 5: Pre-load GameplayData once
-- ============================================================================
local GameplayData = nil
local ok_gd, gd = pcall(require, "GameLua.GameCore.Data.GameplayData")
if ok_gd then GameplayData = gd end

-- ============================================================================
-- COMPLETE BYPASS (Merged pcall blocks - reduces overhead)
-- ============================================================================

-- 1-2. SLUA + MD5 BYPASS (Merged)
pcall(function()
    -- SLUA bypass
    if slua and slua.getSignature then
        slua.getSignature = function() return 0xDEADBEEF end
    end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
        if loader.verifyBytecode then loader.verifyBytecode = nop end
        if loader.checkIntegrity then loader.checkIntegrity = nop end
    end
    local slua_serialize = package.loaded["slua.serialize"]
    if slua_serialize and slua_serialize.check then
        slua_serialize.check = nop
    end
    
    -- MD5/PAK bypass
    local console = get_cached_import("KismetSystemLibrary", "KismetSystemLibrary")
    if console then
        console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
        console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
        console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
    end
    local CreativeModeLib = get_cached_import("CreativeModeBlueprintLibrary", "CreativeModeBlueprintLibrary")
    if CreativeModeLib then
        CreativeModeLib.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
        CreativeModeLib.MD5HashFile = function() return "BYPASSED_MD5_HASH" end
        CreativeModeLib.GetContentDiffData = function() return true, "BYPASSED" end
    end
    if _G.MD5Hash then
        _G.MD5Hash = function() return "00000000000000000000000000000000" end
    end
    local STExtraLib = get_cached_import("STExtraBlueprintFunctionLibrary", "STExtraBlueprintFunctionLibrary")
    if STExtraLib then
        if STExtraLib.CheckMD5 then STExtraLib.CheckMD5 = nop end
        if STExtraLib.GetMD5 then STExtraLib.GetMD5 = function() return "BYPASS" end end
    end
end)

-- 3. MAIN BYPASS (Merged security kills)
pcall(function()
    local stExtra = get_cached_import("STExtraBlueprintFunctionLibrary", "STExtraBlueprintFunctionLibrary")
    if stExtra and stExtra.IsDevelopment then stExtra.IsDevelopment = nop end
    if Client then Client.IsDevelopment = nop; Client.IsShipping = retFalse end
    if Server then Server.IsShipping = retFalse end

    local ToolReport = safe_require("client.slua.logic.report.ToolReportUtil")
    if ToolReport then
        ToolReport.IsReleaseVersion = retFalse
        ToolReport.IsWhite = retFalse
        ToolReport.GetReportSwitch = retFalse
    end

    -- Reduced kill list with numeric loop (faster than ipairs)
    local callbacks = _G.GameplayCallbacks or _G.GC
    if callbacks then
        local kills = {
            "SendTssSdkAntiDataToLobby","SendDSErrorLogToLobby","SendDSHawkEyePatrolLogToLobby",
            "SendSecTLog","SendDataMiningTLog","SendActivityTLog","SendClientMemUsage","SendClientFPS",
            "OnClientCrashReport","OnNetworkLossDetected","ReportMatchRoomData","ReportPlayersPing",
            "SendClientStats","SendServerAvgTickDelta","ReportHitFlow","OnPlayerActorChannelError"
        }
        for i = 1, #kills do
            local fn = kills[i]
            if callbacks[fn] then callbacks[fn] = nop end
        end
    end

    if _G.TApmHelper then _G.TApmHelper.postEvent = nop end

    local PC = _G.PacketCallbacks
    if PC then
        PC.player_report_cheat = nop
        PC.upload_loots_rsp = nop
        PC.watch_player_exit = nop
        PC.player_login_report = nop
        PC.player_logout_report = nop
        PC.server_time_report = nop
    end

    local BanLogic = safe_require("client.slua.logic.ban.ClientBanLogic")
    if BanLogic then
        BanLogic.OnSyncBanInfo = nop
        BanLogic.OnVoiceBanNotify = nop
        BanLogic.OnRealTimeVoiceBanNotify = nop
        BanLogic.OnVoiceBanSuccess = nop
        BanLogic.OnSyncMicSuspicious = nop
        BanLogic.OnSyncMicPreFilter = nop
        BanLogic.OnNotifyWarningTips = nop
        BanLogic.ReqBanInfo = nop
    end

    local BanUtil = package.loaded["client.common.ban_util"] or _G.ban_util
    if BanUtil then
        BanUtil.CheckBanStatus = retFalse
        BanUtil.GetBanTime = retZero
        BanUtil.IsBanForever = retFalse
    end
end)

-- 4-10. HIGGS, CORONA, SECURITY BYPASS (Merged)
pcall(function()
    -- Higgs Boson
    local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if Higgs then
        local methods = {
            "ControlMHActive","Tick","OnTick","MHActiveLogic","TriggerAvatarCheck","StartAvatarCheck",
            "ReportItemID","ReceiveAnyDamage","OnWeaponHitRecord","ShowSecurityAlert","ServerReportAvatar",
            "ClientReportNetAvatar","SendHisarData","ValidateSecurityData"
        }
        for i = 1, #methods do
            local m = methods[i]
            if Higgs[m] then Higgs[m] = nop end
        end
        Higgs.GetNetAvatarItemIDs = retEmpty
        Higgs.GetCurWeaponSkinID = retZero
    end
    
    -- Corona Lab
    if _G.CoronaLab then
        _G.CoronaLab.ReportData = nop
        _G.CoronaLab.SendData = nop
        _G.CoronaLab.CollectData = nop
    end
    
    -- Player Security Info
    if _G.PlayerSecurityInfo then
        _G.PlayerSecurityInfo.ReportCheat = nop
        _G.PlayerSecurityInfo.ReportSuspicious = nop
        _G.PlayerSecurityInfo.SendSecurityData = nop
    end
    
    -- Client Circle Flow
    local CircleFlow = safe_require("GameLua.Mod.BaseMod.Client.Security.ClientCircleFlowSubsystem")
    if CircleFlow then
        CircleFlow.ReportCircleFlow = nop
        CircleFlow.SendCircleData = nop
        CircleFlow.ReportPlayerPosition = nop
    end
    if _G.IsEnableReportPlayerKillFlow then _G.IsEnableReportPlayerKillFlow = retFalse end
    if _G.IsEnableReportMrpcsInCircleFlow then _G.IsEnableReportMrpcsInCircleFlow = retFalse end
    if _G.IsEnableReportMrpcsFlow then _G.IsEnableReportMrpcsFlow = retFalse end
    
    -- Shoot Verify
    local ShootVerify = safe_require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if ShootVerify then
        ShootVerify.OnShootVerifyFailed = nop
        ShootVerify.SendVerifyData = nop
        ShootVerify.ReportBulletHit = nop
    end
end)

-- 11-17. REPORT & TLOG BYPASS (Merged)
pcall(function()
    local clientReport = safe_require("GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem")
    if clientReport then
        local funcs = {"OnInit","_OnPlayerKilledOtherPlayer","SendPacket","ReportSuspiciousPlayer","SubmitReport"}
        for i = 1, #funcs do
            if clientReport[funcs[i]] then clientReport[funcs[i]] = nop end
        end
    end
    
    local tlogModules = {
        "client.network.Protocol.ClientTlogHandler",
        "client.network.Protocol.BattleReportHandler",
        "client.network.Protocol.ClientErrorReportHandler",
        "client.slua.config.tlog.tlog_report_utils",
        "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem"
    }
    for i = 1, #tlogModules do
        local mod = package.loaded[tlogModules[i]]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" and (k:find("Log") or k:find("Report") or k:find("Send")) then
                    pcall(function() mod[k] = nop end)
                end
            end
        end
    end
end)

-- ============================================================================
-- OPTIMIZATION 6: Network filter with pre-compiled patterns
-- ============================================================================
local BLACKLIST_PATTERNS = {
    "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","crash2",
    "privacy.qq","privacy.tencent","mdt.qq","analytics","report.qq","anticheatexpert",
    "crashsight","wetest","log.tav","sngd","tracer","intlsdk","bugly","beacon",
    "helpshift","tdm","apm","firebase","googleapis","facebook","gvoice"
}

local function isBlacklisted(str)
    if type(str) ~= "string" then return false end
    local low = str:lower()
    for i = 1, #BLACKLIST_PATTERNS do
        if low:find(BLACKLIST_PATTERNS[i], 1, true) then
            return true
        end
    end
    return false
end

-- ============================================================================
-- OPTIMIZATION 7: Single security subsystem killer (reduces overhead)
-- ============================================================================
local function KillSecuritySubsystems()
    pcall(function()
        local subMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local subsystemsToKill = {
            "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem","ShootVerifySubSystemClient","HiggsBosonComponent",
            "ClientReportPlayerSubsystem","DSReportPlayerSubsystem","ClientHawkEyePatrolSubsystem",
            "AFKReportorSubsystem","BehaviorScoreSubsystem"
        }
        for i = 1, #subsystemsToKill do
            local sub = subMgr:Get(subsystemsToKill[i])
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload")) then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- OPTIMIZATION 8: Master timer (single timer for all periodic tasks)
-- ============================================================================
local _MASTER_TIMER_PC = nil
local _MASTER_TIMER_HANDLE = nil
local _MASTER_TICK_COUNTER = 0

-- Object cache (reduces repeated lookups)
local _CACHED_PC = nil
local _CACHED_PAWN = nil
local _CACHED_PAWN_VALID = false
local _LAST_CACHE_REFRESH = 0

local function refresh_object_cache()
    local now = os.clock()
    if now - _LAST_CACHE_REFRESH > 0.5 then
        _LAST_CACHE_REFRESH = now
        _CACHED_PC = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(_CACHED_PC) then
            _CACHED_PAWN = _CACHED_PC:GetCurPawn()
            _CACHED_PAWN_VALID = isValid(_CACHED_PAWN)
        else
            _CACHED_PAWN = nil
            _CACHED_PAWN_VALID = false
        end
    end
    return _CACHED_PC, _CACHED_PAWN, _CACHED_PAWN_VALID
end

local function master_tick()
    pcall(function()
        _MASTER_TICK_COUNTER = _MASTER_TICK_COUNTER + 1
        local tick = _MASTER_TICK_COUNTER
        
        refresh_object_cache()
        
        -- Phase 1: Every 4 ticks (2 seconds)
        if tick % 4 == 1 then
            KillSecuritySubsystems()
        end
        
        -- Phase 2: Every 20 ticks (10 seconds)
        if tick % 20 == 1 and _CACHED_PAWN_VALID then
            if _G.ApplyLocalPlayerSkins then
                pcall(_G.ApplyLocalPlayerSkins, _CACHED_PAWN)
            end
        end
        
        if _MASTER_TICK_COUNTER >= 1000 then
            _MASTER_TICK_COUNTER = 0
        end
    end)
end

local function start_master_timer()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if isValid(pc) then
        if _MASTER_TIMER_HANDLE and isValid(_MASTER_TIMER_PC) then
            pcall(function() _MASTER_TIMER_PC:RemoveGameTimer(_MASTER_TIMER_HANDLE) end)
        end
        _MASTER_TIMER_PC = pc
        _MASTER_TICK_COUNTER = 0
        _MASTER_TIMER_HANDLE = pc:AddGameTimer(0.5, true, master_tick)
        return true
    end
    return false
end

-- ============================================================================
-- OPTIMIZATION 9: ESP with reduced draw calls and caching
-- ============================================================================
local SecurityCommonUtils = nil

-- Static data (allocated once, reused forever)
local _BONE_NAMES = {"head","neck_01","spine_01","spine_02","spine_03","pelvis"}
local _COLOR_RED = {R=255,G=0,B=0,A=255}
local _COLOR_GREEN = {R=0,G=255,B=0,A=255}
local _COLOR_YELLOW = {R=255,G=255,B=0,A=255}
local _COLOR_WHITE = {R=255,G=255,B=255,A=255}
local _COLOR_GOLD = {R=255,G=200,B=0,A=255}
local _COLOR_VISIBLE = {R=255,G=255,B=0,A=255}
local _COLOR_HIDDEN = {R=255,G=100,B=100,A=255}

-- Pawn cache (reused table)
local _CACHED_PAWNS = {}
local _LAST_PAWN_REFRESH = 0
local _PAWN_REFRESH_INTERVAL = 1.0

-- HP bar segments (pre-computed)
local _HP_BAR_SEGMENTS = {"    ", "▁   ", "▁▁  ", "▁▁▁ ", "▁▁▁▁"}
local function HPBar(pct)
    local idx = math.floor(pct * 4) + 1
    return _HP_BAR_SEGMENTS[idx] or _HP_BAR_SEGMENTS[5]
end

local function TextScale(distM)
    return 0.35 - math.min(distM, 400) * 0.0005
end

local function IsPawnAlive(p)
    if not isValid(p) then return false end
    if p.HealthStatus then
        if not SecurityCommonUtils then
            SecurityCommonUtils = safe_require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        end
        if SecurityCommonUtils then
            return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus)
        end
    end
    if p.IsAlive then return p:IsAlive() end
    return (p.GetHealth and (p:GetHealth() or 0) > 0) or false
end

local function ESPTick()
    if not _G.CheatsEnabled then return end
    
    local pc, currentPawn, pawnValid = refresh_object_cache()
    if not pawnValid or not isValid(pc) then return end
    
    local myTeamId = 0
    pcall(function()
        local char = pc:GetPlayerCharacterSafety()
        if isValid(char) and char.TeamID then
            myTeamId = char.TeamID
        elseif currentPawn.TeamID then
            myTeamId = currentPawn.TeamID
        end
    end)
    
    local myPos = currentPawn:K2_GetActorLocation()
    if not myPos then return end
    
    local HUD = pc:GetHUD()
    if not isValid(HUD) then return end
    
    -- Refresh pawn list at reduced frequency
    local now = os.clock()
    if now - _LAST_PAWN_REFRESH > _PAWN_REFRESH_INTERVAL then
        _LAST_PAWN_REFRESH = now
        local allPawns = Game:GetAllPlayerPawns() or {}
        for k, v in pairs(allPawns) do
            _CACHED_PAWNS[k] = v
        end
    end
    
    local botCount = 0
    local playerCount = 0
    
    for _, tPawn in pairs(_CACHED_PAWNS) do
        if isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId then
            if IsPawnAlive(tPawn) then
                local enemyPos = tPawn:K2_GetActorLocation()
                if enemyPos then
                    local dx = enemyPos.X - myPos.X
                    local dy = enemyPos.Y - myPos.Y
                    local dz = enemyPos.Z - myPos.Z
                    local distSq = dx*dx + dy*dy + dz*dz
                    
                    -- Skip beyond 200m
                    if distSq < 4000000 then
                        local isBot = false
                        pcall(function() isBot = Game:IsAI(tPawn) end)
                        if isBot then botCount = botCount + 1 else playerCount = playerCount + 1 end
                        
                        local distM = math.sqrt(distSq) / 100
                        local name = tPawn.PlayerName or "UNKNOWN"
                        local hp = tPawn.Health
                        local maxHp = tPawn.HealthMax
                        
                        local isKnock = false
                        local hpPercent = 0
                        if not hp or not maxHp or maxHp <= 0 or hp <= 0 then
                            isKnock = true
                        else
                            hpPercent = hp / maxHp
                        end
                        
                        local hpColor = _COLOR_GREEN
                        if isKnock then
                            hpColor = _COLOR_RED
                        elseif hpPercent < 0.3 then
                            hpColor = _COLOR_RED
                        elseif hpPercent < 0.7 then
                            hpColor = _COLOR_YELLOW
                        end
                        
                        local hpText = isKnock and "DOWN" or HPBar(hpPercent)
                        
                        -- Head marker position
                        local headPos = nil
                        local mesh = tPawn.Mesh
                        if isValid(mesh) then
                            headPos = mesh:GetSocketLocation("head")
                        end
                        
                        local origin = enemyPos
                        local headZ = headPos and (headPos.Z - origin.Z) or 90
                        local hpOffset = headZ + 70 + math.min(distM, 60) * 3
                        local nameOffset = -80 - math.min(distM, 60) * 0.33
                        
                        local hz = headPos and (headPos.Z - origin.Z + 15)
                        if hz then
                            HUD:AddDebugText("●", tPawn, TextScale(distM),
                                {X=0,Y=0,Z=hz}, {X=0,Y=0,Z=hz},
                                _COLOR_RED, true, false, true, nil, 0.5, true)
                        end
                        
                        HUD:AddDebugText(hpText, tPawn, TextScale(distM),
                            {X=0,Y=0,Z=hpOffset}, {X=0,Y=0,Z=hpOffset},
                            hpColor, true, false, true, nil, 0.5, true)
                        
                        HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), tPawn, TextScale(distM),
                            {X=0,Y=0,Z=nameOffset}, {X=0,Y=0,Z=nameOffset},
                            _COLOR_VISIBLE, true, false, true, nil, 0.5, true)
                    end
                end
            end
        end
    end
    
    -- Status text
    if HUD and currentPawn then
        HUD:AddDebugText(string.format("BOT: %d | PLAYER: %d", botCount, playerCount), currentPawn, 1,
            {X=0,Y=0,Z=170}, {X=0,Y=0,Z=170}, _COLOR_WHITE, true, false, true, nil, 0.5, true)
        HUD:AddDebugText("MOD ACTIVE", currentPawn, 1,
            {X=0,Y=0,Z=145}, {X=0,Y=0,Z=145}, _COLOR_GOLD, true, false, true, nil, 0.5, true)
    end
end

-- ESP timer (reduced rate)
local _ESP_TIMER_HANDLE = nil
local _ESP_TIMER_PAWN = nil

local function start_esp_timer()
    local pc, pawn, pawnValid = refresh_object_cache()
    if pawnValid then
        if _ESP_TIMER_HANDLE and isValid(_ESP_TIMER_PAWN) then
            pcall(function() _ESP_TIMER_PAWN:RemoveGameTimer(_ESP_TIMER_HANDLE) end)
        end
        _ESP_TIMER_PAWN = pawn
        _ESP_TIMER_HANDLE = pawn:AddGameTimer(0.25, true, function() pcall(ESPTick) end)
    end
end

-- ============================================================================
-- OPTIMIZATION 10: Skin system with reduced file I/O
-- ============================================================================
local BASE_PATH = "/storage/emulated/0/Android/data/com.pubg.imobile/files/"
local CONFIG_PATH = BASE_PATH .. "config.ini"
local SAVE_KILL_PATH = BASE_PATH .. "kill_counts.txt"

_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.SkinLoadedCache = _G.SkinLoadedCache or {}
_G.KillData = _G.KillData or { kills = {} }

local _KILL_SAVE_DIRTY = 0

local function SaveKillsDelayed()
    _KILL_SAVE_DIRTY = _KILL_SAVE_DIRTY + 1
    if _KILL_SAVE_DIRTY >= 5 then
        pcall(function()
            local file = io.open(SAVE_KILL_PATH, "w")
            if file then
                for id, count in pairs(_G.KillData.kills) do
                    file:write(string.format("%d:%d\n", id, count))
                end
                file:close()
            end
        end)
        _KILL_SAVE_DIRTY = 0
    end
end

_G.get_skin_id = function(weaponID)
    if not weaponID or weaponID == 0 then return nil end
    local mapped = _G.WeaponSkinMap[weaponID]
    return (mapped and mapped > 0) and mapped or nil
end

_G.download_item = function(i)
    if not i or _G.SkinLoadedCache[i] then return end
    pcall(function()
        local PM = safe_require("client.slua.logic.download.puffer.puffer_manager")
        local PC = safe_require("client.slua.logic.download.puffer_const")
        if PM and PC then
            if PM.GetState(PC.ENUM_DownloadType.ODPAK, {i}) ~= PC.ENUM_DownloadState.Done then
                PM.Download(PC.ENUM_DownloadType.ODPAK, {i})
            end
            _G.SkinLoadedCache[i] = true
        end
    end)
end

_G.ReadLiveConfig = function()
    pcall(function()
        local f = io.open(CONFIG_PATH, "r")
        if not f then return end
        local content = f:read("*all")
        f:close()
        for line in content:gmatch("[^\r\n]+") do
            local k, v = line:match("^([^#=]+)=(.+)$")
            if k and v then
                k = k:gsub("^%s+", ""):gsub("%s+$", "")
                if k == "cheats" then
                    _G.CheatsEnabled = (v == "1" or v:lower() == "on" or v:lower() == "true")
                end
                local val = tonumber(v)
                if val then
                    if k == "Suit" then _G.OutfitMap.Suit = val
                    elseif k == "Hat" then _G.OutfitMap.Hat = val
                    elseif k == "Mask" then _G.OutfitMap.Mask = val
                    elseif k == "Glasses" then _G.OutfitMap.Glasses = val
                    elseif k == "Pants" then _G.OutfitMap.Pants = val
                    elseif k == "Shoes" then _G.OutfitMap.Shoes = val
                    elseif k == "Bag" then _G.OutfitMap.Bag = val
                    elseif k == "Helmet" then _G.OutfitMap.Helmet = val
                    elseif k == "Pet" then _G.OutfitMap.Pet = val
                    elseif k == "M416" then _G.WeaponSkinMap[101004] = val
                    elseif k == "AKM" then _G.WeaponSkinMap[101001] = val
                    elseif k == "SCAR" then _G.WeaponSkinMap[101003] = val
                    elseif k == "M762" then _G.WeaponSkinMap[101008] = val
                    elseif k == "Kar98" then _G.WeaponSkinMap[103001] = val
                    elseif k == "M24" then _G.WeaponSkinMap[103002] = val
                    elseif k == "AWM" then _G.WeaponSkinMap[103003] = val
                    end
                end
            end
        end
    end)
end

_G.ApplyLocalPlayerSkins = function(p)
    if not isValid(p) then return end
    
    local wm = p:GetWeaponManager()
    if isValid(wm) then
        for i = 1, 3 do
            local wpn = wm:GetInventoryWeaponByPropSlot(i)
            if isValid(wpn) then
                local target = _G.get_skin_id(wpn:GetWeaponID())
                if target and target > 0 then
                    _G.download_item(target)
                    pcall(function()
                        if wpn.synData then
                            local data = wpn.synData:Get(7)
                            if data and data.defineID and data.defineID.TypeSpecificID ~= target then
                                data.defineID.TypeSpecificID = target
                                wpn.synData:Set(7, data)
                                if wpn.OnWeaponSkinUpdate then wpn:OnWeaponSkinUpdate() end
                            end
                        end
                    end)
                end
            end
        end
    end
    
    local ac = p:getAvatarComponent2()
    if isValid(ac) and ac.NetAvatarData then
        local applyData = ac.NetAvatarData.SlotSyncData
        if isValid(applyData) then
            for i = 0, applyData:Num() - 1 do
                local eq = applyData:Get(i)
                if eq and eq.ItemId ~= 0 then
                    local target = 0
                    if eq.SlotID == 5 and _G.OutfitMap.Suit then
                        target = _G.OutfitMap.Suit
                    elseif eq.SlotID == 8 and _G.OutfitMap.Bag and _G.OutfitMap.Bag ~= 501001 then
                        target = _G.OutfitMap.Bag
                    elseif eq.SlotID == 9 and _G.OutfitMap.Helmet and _G.OutfitMap.Helmet ~= 502001 then
                        target = _G.OutfitMap.Helmet
                    end
                    if target ~= 0 and eq.ItemId ~= target then
                        _G.download_item(target)
                        eq.ItemId = target
                        applyData:Set(i, eq)
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- OPTIMIZATION 11: FPS Boost (no changes, just clean execution)
-- ============================================================================
_G.Enable165FPSLogic = function()
    pcall(function()
        local graphics = safe_require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then
                    self:ExecuteCMD("t.MaxFPS", "165")
                    self:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end
    end)
end

_G.EnableiPadViewUI = function()
    pcall(function()
        local sc = safe_require("client.logic.setting.setting_config")
        if sc then
            if sc.TpViewValue then sc.TpViewValue.max = 140 end
            if sc.FpViewValue then sc.FpViewValue.max = 140 end
        end
    end)
end

-- ============================================================================
-- START ALL OPTIMIZED SYSTEMS
-- ============================================================================
_G.Enable165FPSLogic()
_G.EnableiPadViewUI()
start_master_timer()
start_esp_timer()
_G.ReadLiveConfig()

print("[OPTIMIZED] Performance improvements active:")
print("  ✓ Single master timer (reduced overhead)")
print("  ✓ Cached imports and modules")
print("  ✓ Reusable tables (reduced GC)")
print("  ✓ Reduced ESP tick rate (0.25s)")
print("  ✓ Pawn cache with 1s refresh")
print("  ✓ Distance culling at 200m")
print("  ✓ Batched file saves")
print("  ✓ Merged pcall blocks")
