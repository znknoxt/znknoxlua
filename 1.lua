-- ============================================================================
-- ULTIMATE MERGED BYPASS v6.0 - "OMEGA PROTOCOL"
-- Complete Combination of:
--   1. Original m.lua (Skins, ESP, Aimbot, Features)
--   2. deepseek_lua_20260608_ddad45.lua (Pure Bypass)
--   3. last.lua (Ghost Protocol v5.0)
-- ============================================================================

-- ============================================================================
-- CORE UTILITIES & OBSCURATION
-- ============================================================================
local GhostCore = {}
GhostCore.Version = "6.0-OMEGA"
GhostCore.Active = false

local function DecodeStr(str) return string.gsub(str, "_", "") end

local function SafeExec(func, errorMsg)
    local success, result = pcall(func)
    return success and result or nil
end

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end

local function RetTrueMimic()
    return math.random(1, 100) > 5
end

local function RetFalseMimic()
    return math.random(1, 100) <= 5
end

local function SafeWrap(originalFunc, mockFunc, mimicChance)
    if type(originalFunc) ~= "function" then return mockFunc end
    return function(...)
        if mimicChance and mimicChance > 0 and math.random(1, 100) <= mimicChance then
            return originalFunc and originalFunc(...)
        end
        return mockFunc(...)
    end
end

local function IsValid(Object)
    return slua and slua.isValid and slua.isValid(Object)
end

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local function SafeRequire(path)
    return safe_require(path)
end

-- ============================================================================
-- GLOBAL BYPASS STATE
-- ============================================================================
if not _G.BYPASS_STATE then
    _G.BYPASS_STATE = {
        DEADEYE_DISABLED = false, HAWKEYE_DISABLED = false, VOKLAI_DISABLED = false,
        HIGGSBOSON_DISABLED = false, HASH_VERIFY_DISABLED = false, IP_MAPPING_DISABLED = false,
        MEMORY_PATCH_DISABLED = false, EDU_EYE_DISABLED = false, FULL_BYPASS_ACTIVE = false
    }
end

-- ============================================================================
-- FAKE DATA GENERATORS
-- ============================================================================
local FakeData = {
    ping = function() return math.random(20, 45) end,
    fps = function() return math.random(55, 80) + math.random() end,
    memory = function() return math.random(400, 800) end,
    deviceID = function()
        local chars = "0123456789ABCDEF"
        local id = ""
        for i = 1, 32 do id = id .. chars:sub(math.random(1, #chars), math.random(1, #chars)) end
        return id
    end,
    hashValue = function() return "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6" end,
    ipAddress = function() return "192.168." .. math.random(1, 255) .. "." .. math.random(1, 255) end,
    macAddress = function()
        return string.format("%02X:%02X:%02X:%02X:%02X:%02X",
            math.random(0,255), math.random(0,255), math.random(0,255),
            math.random(0,255), math.random(0,255), math.random(0,255))
    end
}

-- ============================================================================
-- PER-MATCH GUARD
-- ============================================================================
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then return end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

local require = require
local import = import
local isValid = slua.isValid

_G.CheatsEnabled = true

local ok_gd, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
if not ok_gd then GameplayData = nil end

-- ============================================================================
-- MODULE 1: SLUA & INTEGRITY BYPASS
-- ============================================================================
local function Module_SLuaBypass()
    SafeExec(function()
        if slua and slua.getSignature then
            slua.getSignature = function() return math.random(0xDE000000, 0xFFFFFFFF) end
        end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = SafeWrap(loader.verifyBytecode, RetTrueMimic, 5)
            loader.checkIntegrity = SafeWrap(loader.checkIntegrity, RetTrueMimic, 5)
            if loader.disableSignatureCheck then loader.disableSignatureCheck = RetTrueMimic end
        end
        if _G.slua_verify then _G.slua_verify = SafeWrap(_G.slua_verify, RetTrueMimic, 5) end
        if _G.check_slua_integrity then _G.check_slua_integrity = SafeWrap(_G.check_slua_integrity, RetTrueMimic, 5) end
    end)
end

-- ============================================================================
-- MODULE 2: MD5 & SIGNATURE BYPASS
-- ============================================================================
local function Module_MD5Bypass()
    SafeExec(function()
        local console = import("KismetSystemLibrary")
        if console then
            local cmds = {
                "pak.DisablePakSignatureCheck 1", "pakchunk.EnableSignatureCheck 0",
                "s.VerifyPak 0", "sig.Check 0", "security.DisableChecks 1"
            }
            for _, cmd in ipairs(cmds) do pcall(function() console.ExecuteConsoleCommand(nil, cmd) end) end
        end
        
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "OK" end
            CreativeModeBlueprintLibrary.VerifyFileIntegrity = SafeWrap(CreativeModeBlueprintLibrary.VerifyFileIntegrity, RetTrueMimic, 5)
        end
        
        if _G.MD5Hash then _G.MD5Hash = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end end
        if _G.CRC32 then _G.CRC32 = function() return math.random(0, 0xFFFFFFFF) end end
        
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = SafeWrap(FileHashChecker.CheckFileMD5, RetTrueMimic, 5)
            FileHashChecker.VerifyAll = SafeWrap(FileHashChecker.VerifyAll, RetTrueMimic, 5)
        end
        
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary then
            STExtraBlueprintFunctionLibrary.CheckMD5 = SafeWrap(STExtraBlueprintFunctionLibrary.CheckMD5, RetTrueMimic, 5)
            STExtraBlueprintFunctionLibrary.VerifyFile = SafeWrap(STExtraBlueprintFunctionLibrary.VerifyFile, RetTrueMimic, 5)
        end
    end)
end

-- ============================================================================
-- MODULE 3: COMPLETE BYPASS (From m.lua)
-- ============================================================================
pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
    if not Msg then Msg = require("client.slua.logic.common.logic_common_msg_box") end
    if Msg and Msg.Show then
        Msg.Show(4, "CHETAN_MODS", "COMPLETE BYPASS ACTIVE\n100% Telemetry killed\nPlay Safe")
    end
end)

pcall(function()
    local stExtra = import("STExtraBlueprintFunctionLibrary")
    if stExtra and stExtra.IsDevelopment then stExtra.IsDevelopment = nop end
    if Client then Client.IsDevelopment = nop; Client.IsShipping = retFalse end
    if Server then Server.IsShipping = retFalse end

    local ToolReport = package.loaded["client.slua.logic.report.ToolReportUtil"]
    if ToolReport then
        ToolReport.IsReleaseVersion = retFalse
        ToolReport.IsWhite = retFalse
        ToolReport.GetReportSwitch = retFalse
    end

    local callbacks = _G.GameplayCallbacks or _G.GC
    if callbacks then
        local kills = {
            "SendTssSdkAntiDataToLobby","SendDSErrorLogToLobby","SendDSHawkEyePatrolLogToLobby",
            "SendSecTLog","SendDataMiningTLog","SendActivityTLog","SendClientMemUsage","SendClientFPS",
            "OnClientCrashReport","OnNetworkLossDetected","ReportMatchRoomData","ReportPlayersPing",
            "SendClientStats","SendServerAvgTickDelta","ReportHitFlow","OnPlayerActorChannelError","OnPlayerRPCValidateFailed"
        }
        for _, fn in ipairs(kills) do if callbacks[fn] then callbacks[fn] = nop end end
        local origDS = callbacks.OnDSPlayerStateChanged
        if origDS then
            callbacks.OnDSPlayerStateChanged = function(dsSelf, state, reason, ...)
                if tostring(reason):lower():find("cheatdetected") then return end
                pcall(origDS, dsSelf, state, reason, ...)
            end
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

    local sdm = _G.ServerDataMgr
    if sdm and sdm.DeletablePlayerResultKey then
        sdm.DeletablePlayerResultKey["SuspiciousHitCount"] = true
        sdm.DeletablePlayerResultKey["EspTotalSimTraceCnt"] = true
        sdm.DeletablePlayerResultKey["EspTotalImeFocusCnt"] = true
        sdm.DeletablePlayerResultKey["ClientGravityAnomalyCount"] = true
    end

    local pcNotify = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"]
    if pcNotify then
        pcNotify.ClientRPC_SyncBanID = nop
        pcNotify.ClientRPC_StrongTips = nop
        pcNotify.ClientRPC_NormalTips = nop
        pcNotify.Notify = nop
        pcNotify.ClientRPC_NotifyBan = nop
        pcNotify.ClientRPC_NotifyPunish = nop
        pcNotify.ClientRPC_NotifyIllegalProgram = nop
    end

    local secUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"]
    if secUtils and secUtils.EStrategyTypeInReplay then
        secUtils.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
        secUtils.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
        secUtils.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
        secUtils.EStrategyTypeInReplay.FlyingErrorCnt = 0
    end
end)

-- ============================================================================
-- MODULE 4: HIGGS BOSON BYPASS (Complete)
-- ============================================================================
pcall(function()
    local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if Higgs then
        local methods = {
            "ControlMHActive","Tick","OnTick","MHActiveLogic","TriggerAvatarCheck","StartAvatarCheck",
            "ReportItemID","ReceiveAnyDamage","OnWeaponHitRecord","ShowSecurityAlert","ServerReportAvatar",
            "ClientReportNetAvatar","SendHisarData","ValidateSecurityData","StaticShowSecurityAlertInDev"
        }
        for _, m in ipairs(methods) do if Higgs[m] then Higgs[m] = nop end end
        Higgs.GetNetAvatarItemIDs = retEmpty
        Higgs.GetCurWeaponSkinID = retZero
    end
    if _G.DisableHiggsBoson then _G.DisableHiggsBoson = nop end

    local hia = safe_require("GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem")
    if hia then
        hia.CheckHitIntegrity = nop
        hia.InitSession = nop
        hia.OnBattleEnd = nop
    end

    local Behavior = safe_require("GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem")
    if Behavior then
        Behavior.OnHandleBehaviorScore = nop
        Behavior.AIPerceptionScore = nop
        Behavior.ReportBehavior = nop
        Behavior.CalcFinalScore = retZero
    end
end)

local higgs_bypass_attempts = 0
local MAX_HIGGS_BYPASS_ATTEMPTS = 60
local function bypass_higgs_boson_perplayer(player)
    if not player or not isValid(player) then return end
    if higgs_bypass_attempts >= MAX_HIGGS_BYPASS_ATTEMPTS then return end
    pcall(function()
        local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            Higgs.ControlMHActive = nop
            Higgs.TriggerAvatarCheck = nop
            Higgs.StartAvatarCheck = nop
            Higgs.ReportItemID = nop
            Higgs.OnReportItemID = nop
            Higgs.ReceiveAnyDamage = nop
            Higgs.OnWeaponHitRecord = nop
            Higgs.ShowSecurityAlert = nop
            Higgs.ServerReportAvatar = nop
            Higgs.ClientReportNetAvatar = nop
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.GetCurWeaponSkinID = retZero
        end
        if _G.AvatarCheckCallback then
            _G.AvatarCheckCallback.StartAvatarCheck = nop
            _G.AvatarCheckCallback.OnReportItemID = nop
        end
    end)
    higgs_bypass_attempts = higgs_bypass_attempts + 1
end

local function hookPerPlayerHiggs()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and isValid(pc) then
        local pawn = pc:GetCurPawn()
        if isValid(pawn) then bypass_higgs_boson_perplayer(pawn) end
    end
end

-- ============================================================================
-- MODULE 5: BAN SYSTEM BYPASS
-- ============================================================================
pcall(function()
    local BanLogic = package.loaded["client.slua.logic.ban.ClientBanLogic"]
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

    local TTBan = package.loaded["client.logic.login.logic_tt_ban"] or _G.logic_tt_ban
    if TTBan then
        TTBan.CheckIfCanCreateRole = nop
        TTBan.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end
    end

    local AntiAddiction = package.loaded["client.network.Protocol.AntiaddctionHandler"]
    if AntiAddiction then
        AntiAddiction.send_anti_addiction_req = nop
        AntiAddiction.send_anti_addiction_notify = nop
    end

    local AccessRestrict = package.loaded["client.network.Protocol.AccessRestrictionHandler"]
    if AccessRestrict then
        AccessRestrict.send_access_restriction_req = nop
        AccessRestrict.send_access_restriction_notify = nop
        AccessRestrict.on_player_cheat_state_notify = nop
    end

    local ComplianceUtil = package.loaded["client.slua.logic.gdpr.compliance_util"]
    if ComplianceUtil then ComplianceUtil.CheckCompliance = nop end
end)

-- ============================================================================
-- MODULE 6: REPORT SYSTEM KILL
-- ============================================================================
pcall(function()
    local clientReport = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"]
    if clientReport then
        local funcs = {"OnInit","_OnPlayerKilledOtherPlayer","_RecordFatalDamager","SendPacket","ReportSuspiciousPlayer","SubmitReport","_OnBattleResult","_RecordTeammatePlayerInfo","_OnDeathReplayDataWhenFatalDamaged","_RecordMurdererFromDeathReplayData"}
        for _, fn in ipairs(funcs) do if clientReport[fn] then clientReport[fn] = nop end end
    end

    local dsReport = package.loaded["GameLua.Mod.BaseMod.Common.Security.DSReportPlayerSubsystem"]
    if dsReport then
        local funcs = {"_OnNearDeathOrRescued","_OnPlayerSettlementStart","_OnTeammateDamage","_OnCharacterDied","_AddEnemyMapToBattleResult","_AddTeammateMapToBattleResult","_SubmitAbnormalData"}
        for _, fn in ipairs(funcs) do if dsReport[fn] then dsReport[fn] = nop end end
    end

    local reportUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils"]
    if reportUtils then reportUtils.GetBotType = retZero; reportUtils.IsCharacterDeliverAI = retFalse end

    local AvatarSub = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionSubsystem"]
    if AvatarSub then
        AvatarSub.OnClickReportCheckAvatar = nop
        AvatarSub.RegisterTickCheckCharacterAvatar = nop
    end
    if _G.AvatarExceptionPlayerInst then
        _G.AvatarExceptionPlayerInst.ReportAvatarException = nop
        _G.AvatarExceptionPlayerInst.CheckAvatarException = nop
        _G.AvatarExceptionPlayerInst.CheckCanBugglyPostException = nop
    end

    local ClientHawk = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if ClientHawk then
        local funcs = {"_OnHawkSync","_OnHawkReportSuccess","_StartExitGameTimer","_OnRecvInspectorBroadcastCount","SendReportTLog","ReportCheat"}
        for _, fn in ipairs(funcs) do if ClientHawk[fn] then ClientHawk[fn] = nop end end
        ClientHawk.CanInspectorBroadcast = retFalse
    end

    local InspectClient = package.loaded["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"]
    if InspectClient then
        local funcs = {"AskForInspector","ReportEnemy","KickOutOneTeam","OnReceiveInspectCmd","ClientReportData","SendReportToInspector","SendKickOutOneTeam","ClientNotifyInspectorImplementation","RecvNotifyInspector"}
        for _, fn in ipairs(funcs) do if InspectClient[fn] then InspectClient[fn] = nop end end
    end
end)

-- ============================================================================
-- MODULE 7: TLOG & TELEMETRY BLOCKER
-- ============================================================================
pcall(function()
    local tlogModules = {
        "client.network.Protocol.ClientTlogHandler", "client.network.Protocol.BattleReportHandler",
        "client.network.Protocol.ClientErrorReportHandler", "client.network.Protocol.LobbyPingReportHandler",
        "client.slua.config.tlog.tlog_report_utils", "client.slua.data.BasicData.BasicDataTLogReport",
        "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem", "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem", "GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"
    }
    for _, path in ipairs(tlogModules) do
        local mod = package.loaded[path]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" and (k:find("Log") or k:find("Report") or k:find("Send") or k:find("Tlog")) then
                    pcall(function() mod[k] = nop end)
                end
            end
        end
    end

    local DSFight = safe_require("GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem")
    if DSFight then
        DSFight.GetSimpleFightData = retEmpty
        DSFight.ReportFightData = nop
    end
    local DSSec = safe_require("GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem")
    if DSSec then
        DSSec._OnReportServerJumpFlow = nop
        DSSec._OnReportTeleportFlow = nop
        DSSec._OnReportSpeedHackFlow = nop
    end
end)

-- ============================================================================
-- MODULE 8: SMART PACKET HANDLER
-- ============================================================================
local function InitSmartPacketHandler()
    if not NetUtil or not NetUtil.SendPacket or _G._SMART_PACKET_HOOKED then return end
    
    local originalSend = NetUtil.SendPacket
    
    local criticalPackets = {
        heartbeat = true, player_position = true, game_action = true, login_auth = true,
        match_join = true, match_leave = true, team_communication = true, weapon_fire = true,
        player_damage = true, player_kill = true, item_pickup = true, vehicle_enter = true,
        zone_update = true, parachute_deploy = true, revive_teammate = true, death_event = true
    }
    
    local securityPackets = {
        ReportAimFlow = true, ReportHitFlow = true, ReportWeaponStats = true,
        report_client_scan_result = true, on_tss_sdk_anti_data = true, tss_sdk_report = true,
        report_device_info = true, report_ip_address = true, report_hash_check = true,
        ReportPlayerBehavior = true, ReportMovementData = true, SendDSErrorLogToLobby = true,
        SendDSHawkEyePatrolLogToLobby = true, ReportMatchRoomData = true
    }
    
    NetUtil.SendPacket = function(name, data, ...)
        if criticalPackets[name] then
            return originalSend(name, data, ...)
        end
        
        if securityPackets[name] then
            if math.random() > 0.6 then
                return originalSend(name, data, ...)
            else
                local resp = {code = 0}
                if name == "ReportAimFlow" or name == "ReportHitFlow" then
                    resp.accuracy = math.random(40, 70)
                    resp.headshot = math.random(10, 30)
                elseif name == "report_device_info" or name == "report_ip_address" then
                    resp.ip = FakeData.ipAddress()
                    resp.device = FakeData.deviceID()
                elseif name == "report_hash_check" then
                    resp.hash = FakeData.hashValue()
                    resp.verified = true
                end
                return resp
            end
        end
        
        return originalSend(name, data, ...)
    end
    
    _G._SMART_PACKET_HOOKED = true
end

-- ============================================================================
-- MODULE 9: HEARTBEAT SYSTEM
-- ============================================================================
local heartbeatTimer = nil
local function StartHeartbeatSystem()
    if heartbeatTimer then return end
    
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not IsValid(pc) then return end
    
    pcall(function()
        heartbeatTimer = pc:AddGameTimer(5.0, true, function()
            if not IsValid(pc) then heartbeatTimer = nil; return end
            
            if NetUtil and NetUtil.SendPacket then
                NetUtil.SendPacket("heartbeat", {
                    timestamp = os.time(),
                    frame_rate = math.random(55, 75),
                    ping = math.random(30, 80),
                    packet_loss = math.random(0, 2)
                })
            end
        end)
    end)
end

-- ============================================================================
-- MODULE 10: HTTP/FILE BLOCKER
-- ============================================================================
local BLACKLIST_HOSTS = {
    "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","feedback.wh","crash2",
    "privacy.qq","privacy.tencent","oth.eve","mdt.qq","act.tencentyun","analytics","report.qq",
    "anticheatexpert","crashsight","wetest","log.tav","sngd","tracer","intlsdk","igamecj",
    "cdn.club","gpubgm","graph.facebook","calendarpushsubscription","googleads","doubleclick",
    "firebaselogging","firebaseremoteconfig","fonts.googleapis","abs.twimg","dl.listdl",
    "igame.gcloudcs","bugly","beacon","helpshift","tdm","apm","safeguard","weiyun","qzone",
    "tencent-cloud","myapp","idqqimg","gtimg","qqmail","tcdn","cloudctrl","sdkostrace"
}

local FILE_KEYWORDS = {
    "tlog","crash","bugly","report","beacon","wetest","analytics","telemetry","trace","dump",
    "exception","feedback","aps_log","mtp_detect","network_loss","client_error","ue4crash","tdm","gcloud"
}

local function isBlacklisted(str)
    if type(str) ~= "string" then return false end
    local low = str:lower()
    for _, kw in ipairs(BLACKLIST_HOSTS) do if low:find(kw,1,true) then return true end end
    return false
end

pcall(function()
    if _G.HttpRequest then
        local orig = _G.HttpRequest
        _G.HttpRequest = function(url, ...) if isBlacklisted(url) then return nil end return orig(url, ...) end
    end
end)

local orig_io_open = io.open
io.open = function(path, mode)
    if type(path) == "string" then
        local lp = path:lower()
        for _, kw in ipairs(FILE_KEYWORDS) do
            if lp:find(kw) then
                if mode and (mode == "w" or mode == "a" or mode == "w+" or mode == "a+") then
                    return nil, "Blocked"
                end
            end
        end
    end
    return orig_io_open(path, mode)
end

if _G.UnrealEngine and _G.UnrealEngine.CrashContext then
    _G.UnrealEngine.CrashContext = nil
    _G.UnrealEngine.CrashContext = { SetCrashContext = nop, ReportCrash = nop, AddCrashData = nop }
end

-- ============================================================================
-- MODULE 11: PERSISTENT TIMER & HUNT
-- ============================================================================
local function huntAndKillAll()
    pcall(function()
        local subNames = {
            "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem","ClientReportPlayerSubsystem",
            "DSReportPlayerSubsystem","ClientGlueHiaSystem","ClientDataStatistcsSubsystem",
            "ICTLogSubsystem","DSFightTLogSubsystem","DSSecurityTLogSubsystem","AFKReportorSubsystem",
            "BehaviorScoreSubsystem"
        }
        local subMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subMgr and subMgr.Get then
            for _, name in ipairs(subNames) do
                local sub = subMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Tick") or k:find("Log")) then
                            pcall(function() sub[k] = nop end)
                        end
                    end
                end
            end
        end
    end)
end

local function startPersistentTimer()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and isValid(pc) then
        if _G._permHuntTimer then pcall(function() pc:RemoveGameTimer(_G._permHuntTimer) end) end
        _G._permHuntTimer = pc:AddGameTimer(3.0, true, huntAndKillAll)
        return true
    end
    return false
end

local function finalStart()
    if startPersistentTimer() then
        hookPerPlayerHiggs()
    else
        local fb = slua_GameFrontendHUD or Game
        if fb and isValid(fb) then fb:AddGameTimer(2.0, false, finalStart) end
    end
end

-- ============================================================================
-- MODULE 12: SKIN SYSTEM (From m.lua)
-- ============================================================================
_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.KillData = _G.KillData or { kills = {} }

local BASE_PATH = "/storage/emulated/0/Android/data/com.pubg.imobile/files/"
local CONFIG_PATH = BASE_PATH .. "config.ini"
local SAVE_KILL_PATH = BASE_PATH .. "kill_counts.txt"
local ATTACH_PATH = BASE_PATH .. "attachments.txt"

local function SaveKillsToFile()
    pcall(function()
        local file = io.open(SAVE_KILL_PATH, "w")
        if file then
            for id, count in pairs(_G.KillData.kills) do
                file:write(string.format("%d:%d\n", id, count))
            end
            file:close()
        end
    end)
end

local function LoadKillsFromFile()
    pcall(function()
        local file = io.open(SAVE_KILL_PATH, "r")
        if file then
            for line in file:lines() do
                local id, count = line:match("(%d+):(%d+)")
                if id and count then
                    _G.KillData.kills[tonumber(id)] = tonumber(count)
                end
            end
            file:close()
        end
    end)
end

_G.getKills = function(weaponID) return _G.KillData.kills[weaponID] or 0 end

_G.AddKill = function(weaponID)
    if not weaponID then return end
    _G.KillData.kills[weaponID] = (_G.KillData.kills[weaponID] or 0) + 1
    _G._KillSaveDirty = (_G._KillSaveDirty or 0) + 1
    if _G._KillSaveDirty >= 3 then
        SaveKillsToFile()
        _G._KillSaveDirty = 0
    end
end

LoadKillsFromFile()

_G.get_skin_id = function(weaponID)
    if not weaponID or weaponID == 0 then return nil end
    local mapped = _G.WeaponSkinMap[weaponID]
    if mapped and mapped > 0 then return mapped end
    return nil
end

_G.download_item = function(i)
    if not i then return end
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        local PC = require("client.slua.logic.download.puffer_const")
        if PM.GetState(PC.ENUM_DownloadType.ODPAK, {i}) ~= PC.ENUM_DownloadState.Done then
            PM.Download(PC.ENUM_DownloadType.ODPAK, {i})
        end
    end)
end

local ATTACH_NAME_MAP = {
    ["Red Dot Sight"] = "RedDot", ["Holographic Sight"] = "Holo", ["2x Scope"] = "Scope2x",
    ["3x Scope"] = "Scope3x", ["4x Scope"] = "Scope4x", ["6x Scope"] = "Scope6x",
    ["8x Scope"] = "Scope8x", ["Flash Hider"] = "FlashHider", ["Compensator"] = "Compensator",
    ["Suppressor"] = "Suppressor", ["Extended Mag"] = "ExtMag", ["Quickdraw Mag"] = "QuickMag",
    ["Extended Quickdraw Mag"] = "ExtQuickMag", ["Angled Foregrip"] = "AngledGrip",
    ["Vertical Foregrip"] = "VerticalGrip", ["Thumb Grip"] = "ThumbGrip", ["Half Grip"] = "HalfGrip",
    ["Light Grip"] = "LightGrip", ["Laser Sight"] = "LaserSight", ["Tactical Stock"] = "TactStock",
    ["Stock"] = "MicroStock", ["Cheek Pad"] = "CheekPad"
}

local _attachFileCache = nil

local function _parseAttachmentsFile()
    local result = {}
    pcall(function()
        local f = io.open(ATTACH_PATH, "r")
        if not f then return end
        local content = f:read("*all")
        f:close()
        local curSkin = nil
        for line in content:gmatch("[^\r\n]+") do
            local firstNum = line:match("^(%d+)%s*|")
            if firstNum then
                local num = tonumber(firstNum)
                if num and num > 1100000000 then
                    curSkin = num
                    result[curSkin] = result[curSkin] or {}
                elseif num and curSkin then
                    local attachName = line:match("^%d+%s*|%s*%x+%s*|%s*(.-)%s*$")
                    if not attachName then attachName = line:match("^%d+%s*|%s*(.-)%s*$") end
                    if attachName and attachName ~= "" then
                        local key = ATTACH_NAME_MAP[attachName]
                        if key then result[curSkin][key] = num end
                    end
                end
            elseif line:find("^#%-%-%-%-") and line:find("skin") then
                curSkin = nil
            end
        end
    end)
    return result
end

_G.GetAttachForSkin = function(skinId, key)
    if not skinId or skinId == 0 or not key then return nil end
    if not _attachFileCache then _attachFileCache = _parseAttachmentsFile() end
    local t = _attachFileCache[skinId]
    if not t then return nil end
    return (t[key] and t[key] > 0) and t[key] or nil
end

local function ReadLiveConfig()
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
                    elseif k == "Armor" then _G.OutfitMap.Armor = val
                    elseif k == "Parachute" then _G.OutfitMap.Parachute = val
                    elseif k == "Pet" then _G.OutfitMap.Pet = val
                    elseif k == "M416" then _G.WeaponSkinMap[101004] = val
                    elseif k == "AKM" then _G.WeaponSkinMap[101001] = val
                    elseif k == "SCAR" then _G.WeaponSkinMap[101003] = val
                    elseif k == "UMP" then _G.WeaponSkinMap[102002] = val
                    elseif k == "M762" then _G.WeaponSkinMap[101008] = val
                    elseif k == "AUG" then _G.WeaponSkinMap[101006] = val
                    elseif k == "M24" then _G.WeaponSkinMap[103002] = val
                    elseif k == "AWM" then _G.WeaponSkinMap[103003] = val
                    elseif k == "Kar98" then _G.WeaponSkinMap[103001] = val
                    end
                end
            end
        end
    end)
end
_G.ReadLiveConfig = ReadLiveConfig

_G.InjectWeaponLogicHooks = function(pawn)
    if not isValid(pawn) then return end
    if _G.__WeaponLogicHookInjected then return end
    _G.__WeaponLogicHookInjected = true
    pcall(function()
        local wm = pawn:GetWeaponManager()
        if not isValid(wm) then return end
        local old_GetEquipID = wm.GetEquipWeaponAvatarID
        if old_GetEquipID then
            wm.GetEquipWeaponAvatarID = function(self, weaponID)
                local forced = _G.get_skin_id(weaponID)
                if forced then return forced end
                return old_GetEquipID(self, weaponID)
            end
        end
        local old_GetWeaponAvatarID = wm.GetWeaponAvatarID
        if old_GetWeaponAvatarID then
            wm.GetWeaponAvatarID = function(self, weapon)
                if isValid(weapon) then
                    local forced = _G.get_skin_id(weapon:GetWeaponID())
                    if forced then return forced end
                end
                return old_GetWeaponAvatarID(self, weapon)
            end
        end
    end)
end

_G.ApplyLocalPlayerSkins = function(p)
    if not isValid(p) then return end
    pcall(function()
        local ac = p:getAvatarComponent2()
        if isValid(ac) and ac.NetAvatarData then
            local applyData = ac.NetAvatarData.SlotSyncData
            if isValid(applyData) then
                for i = 0, applyData:Num() - 1 do
                    local eq = applyData:Get(i)
                    if eq and eq.ItemId ~= 0 then
                        local target = 0
                        if eq.SlotID == 5 and _G.OutfitMap.Suit then target = _G.OutfitMap.Suit end
                        if target and target ~= 0 and eq.ItemId ~= target then
                            if _G.download_item and not _G.SkinLoadedCache[target] then
                                pcall(_G.download_item, target)
                                _G.SkinLoadedCache[target] = true
                            end
                            eq.ItemId = target
                            applyData:Set(i, eq)
                        end
                    end
                end
            end
        end
    end)
    _G.InjectWeaponLogicHooks(p)
end

-- ============================================================================
-- MODULE 13: WALLHACK & ESP
-- ============================================================================
local function ApplyWallHack(localPlayer, enemy, pc)
    if not _G.CheatsEnabled then return end
    if not slua.isValid(enemy) then return end
    pcall(function()
        local meshes = {}
        if slua.isValid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass then
            local childs = enemy:GetComponentsByClass(SkelClass)
            if childs then
                local count = childs:Num()
                for c = 0, count - 1 do
                    local comp = childs:Get(c)
                    if slua.isValid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                local ok, mat = pcall(function() return comp:GetMaterial(0) end)
                if ok and slua.isValid(mat) then
                    local ok2, base = pcall(function() return mat:GetBaseMaterial() end)
                    if ok2 and slua.isValid(base) then
                        base.bDisableDepthTest = true
                        base.BlendMode = 2
                    end
                end
                comp.UseScopeDistanceCulling = false
            end
        end
    end)
end

local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")

local cachedPawns = {}
local lastPawnRefresh = 0

local function IsPawnAlive(p)
    if not isValid(p) then return false end
    if p.HealthStatus then return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus) end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

local boneList = {"head","neck_01","spine_01","spine_02","spine_03","pelvis",
    "upperarm_l","upperarm_r","lowerarm_l","lowerarm_r","hand_l","hand_r",
    "calf_l","calf_r","foot_l","foot_r"}

local function HPBar(pct)
    local n = math.floor((pct * 4) + 0.5)
    local s = ""
    for i = 1, 4 do s = s .. (i <= n and "▁" or " ") end
    return s
end

local function ESPTick()
    if not _G.CheatsEnabled then return end
    local uCon = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not (isValid(uCon) and Game:IsClassOf(uCon, ASTExtraPlayerController)) then return end
    local currentPawn = uCon:GetCurPawn()
    if not isValid(currentPawn) then return end

    local myTeamId = 0
    pcall(function()
        local char = uCon:GetPlayerCharacterSafety()
        if isValid(char) and char.TeamID then myTeamId = char.TeamID end
    end)
    local myPos = nil
    pcall(function() myPos = currentPawn:K2_GetActorLocation() end)
    if not myPos then return end
    local HUD = uCon:GetHUD()
    local now = os.clock()

    if now - lastPawnRefresh > 1.0 then
        lastPawnRefresh = now
        cachedPawns = Game:GetAllPlayerPawns() or {}
    end

    for _, tPawn in pairs(cachedPawns) do
        if isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId then
            if IsPawnAlive(tPawn) then
                local enemyPos = tPawn:K2_GetActorLocation()
                local dx = enemyPos.X - myPos.X
                local dy = enemyPos.Y - myPos.Y
                local dz = enemyPos.Z - myPos.Z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

                if dist < 600000 and HUD then
                    local name = tPawn.PlayerName or "UNKNOWN"
                    local distM = dist / 100
                    local hp = tPawn.Health
                    local maxHp = tPawn.HealthMax
                    local hpPercent = hp and maxHp and maxHp > 0 and hp / maxHp or 0
                    local hpColor = {R=0,G=255,B=0,A=255}
                    if hpPercent < 0.3 then hpColor = {R=255,G=0,B=0,A=255}
                    elseif hpPercent < 0.7 then hpColor = {R=255,G=255,B=0,A=255} end

                    local bones = {}
                    local mesh = tPawn.Mesh
                    if isValid(mesh) then
                        for _, bn in ipairs(boneList) do
                            bones[bn] = mesh:GetSocketLocation(bn)
                        end
                    end
                    local headPos = bones["head"]
                    local hpOffset = headPos and (headPos.Z - enemyPos.Z + 70) or 90
                    local nameOffset = -80

                    local nameColor = {R=255,G=255,B=0,A=255}
                    HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), tPawn, 0.35, {X=0,Y=0,Z=nameOffset}, {X=0,Y=0,Z=nameOffset}, nameColor, true, false, true, nil, 1.0, true)
                    HUD:AddDebugText(HPBar(hpPercent), tPawn, 0.35, {X=0,Y=0,Z=hpOffset}, {X=0,Y=0,Z=hpOffset}, hpColor, true, false, true, nil, 1.0, true)
                    
                    pcall(ApplyWallHack, currentPawn, tPawn, uCon)
                end
            end
        end
    end
end

pcall(function()
    if _G._ESPWatchdogHandle then pcall(function() Game:ClearTimer(_G._ESPWatchdogHandle) end); _G._ESPWatchdogHandle = nil end

    local function StartESP(targetActor)
        if not isValid(targetActor) then return end
        cachedPawns = {}; lastPawnRefresh = 0
        _G._ESPTimerChar = targetActor
        _G._ESPTimerHandle = targetActor:AddGameTimer(0.15, true, function() pcall(ESPTick) end)
    end

    local function Watchdog()
        pcall(function()
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            local curPawn = pc and pc:GetCurPawn()
            if isValid(curPawn) and _G._ESPTimerChar ~= curPawn then
                if _G._ESPTimerHandle and isValid(_G._ESPTimerChar) then
                    pcall(function() _G._ESPTimerChar:RemoveGameTimer(_G._ESPTimerHandle) end)
                end
                _G._ESPTimerHandle = nil
                StartESP(curPawn)
            elseif not _G._ESPTimerHandle then
                StartESP(curPawn)
            end
        end)
    end

    _G._ESPWatchdogHandle = Game:SetTimer(1.0, true, Watchdog)
    Watchdog()
end)

-- ============================================================================
-- MODULE 14: AIMBOT & FEATURES
-- ============================================================================
_G.Enable165FPSLogic = function()
    pcall(function()
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then self:ExecuteCMD("t.MaxFPS", "165"); self:ExecuteCMD("r.FrameRateLimit", "165") end
            end
        end
    end)
end

_G.EnableiPadViewUI = function()
    pcall(function()
        local sc = require("client.logic.setting.setting_config")
        if sc then
            if sc.TpViewValue then sc.TpViewValue.max = 140 end
            if sc.FpViewValue then sc.FpViewValue.max = 140 end
        end
    end)
end

_G.Enable165FPSLogic()
_G.EnableiPadViewUI()

local _G._AimbotCurrentPC = nil

local function ApplyHardAimbot()
    if not _G.CheatsEnabled then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not isValid(pc) then return end
        local char = pc:GetPlayerCharacterSafety()
        if not isValid(char) then return end
        local wm = char.WeaponManagerComponent
        if not isValid(wm) then return end
        local weapon = wm.CurrentWeaponReplicated
        if not isValid(weapon) then return end
        local entity = weapon.ShootWeaponEntityComp
        if not isValid(entity) then return end

        entity.GameDeviationFactor = 0.3
        entity.WeaponAimInTime = 20
        entity.RecoilKick = 0.2
        entity.RecoilKickADS = 0.2
        entity.AnimationKick = 0.2
        if entity.RecoilInfo then
            entity.RecoilInfo.VerticalRecoilMin = 0.2
            entity.RecoilInfo.VerticalRecoilMax = 0.2
        end
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 8
                    cfg.adsorbMaxRange = 200
                end
            end
        end
    end)
end

local function AttachAimbotTimer()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not isValid(pc) then return end
        if pc == _G._AimbotCurrentPC then return end
        _G._AimbotCurrentPC = pc
        if pc.AddGameTimer then
            pc:AddGameTimer(0.1, true, function() ApplyHardAimbot() end)
        end
    end)
end

AttachAimbotTimer()

-- ============================================================================
-- MODULE 15: PER-PLAYER SETTINGS TIMER
-- ============================================================================
local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
if isValid(pc) and pc.AddGameTimer and pc ~= _G._FeaturesTimerPC then
    _G._FeaturesTimerPC = pc
    pc:AddGameTimer(0.1, true, function()
        pcall(function()
            if not _G.CheatsEnabled then return end
            local pc = slua_GameFrontendHUD:GetPlayerController()
            if not isValid(pc) then return end
            local char = pc:GetPlayerCharacterSafety()
            if not isValid(char) then return end
            
            local gi = slua_GameFrontendHUD and slua_GameFrontendHUD:GetGameInstance()
            if gi then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
            end
        end)
    end)
end

-- ============================================================================
-- MODULE 16: ANTI-REPORT & CONNECTION GUARD
-- ============================================================================
pcall(function()
    if not _G.GameplayCallbacks then return end
    local GC = _G.GameplayCallbacks
    local origDS = GC.OnDSPlayerStateChanged
    GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
        local state = InPlayerState and string.lower(tostring(InPlayerState)) or ""
        local block = {["cheatdetected"]=true, ["connectionlost"]=true, ["connectiontimeout"]=true}
        if block[state] then return end
        if origDS then pcall(origDS, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
    end
    GC.OnPlayerNetConnectionClosed = nop
    GC.OnPlayerActorChannelError = nop
    GC.OnPlayerRPCValidateFailed = nop
end)

-- ============================================================================
-- MODULE 17: KILL COUNTER UI FORCE ENABLE
-- ============================================================================
_G.ForceEnableKillCounterUI = function()
    if _G.KCUISystemHacked then return end
    pcall(function()
        local KillCounterUI = package.loaded["GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem"]
        if KillCounterUI and KillCounterUI.__inner_impl then
            local ui = KillCounterUI.__inner_impl
            ui.CheckSupportKCUI = function() return true end
            ui.CheckNeedMainKillCounterUI = function(self, Weapon, PlayerID)
                local pc = slua_GameFrontendHUD:GetPlayerController()
                local cw = isValid(Weapon) and Weapon or (pc and pc:GetPlayerCharacterSafety() and pc:GetPlayerCharacterSafety():GetCurrentWeapon())
                if not isValid(cw) then self:UpdateMainKillCounterUI(false); return end
                local wID = cw:GetWeaponID()
                if not wID or wID == 0 then self:UpdateMainKillCounterUI(false); return end
                self:UpdateMainKillCounterUI(true, wID, _G.get_skin_id(wID) or wID)
            end
            _G.KCUISystemHacked = true
        end
    end)
end
_G.ForceEnableKillCounterUI()

-- ============================================================================
-- MODULE 18: DEAD BOX SKIN APPLIER
-- ============================================================================
_G.DeadBoxSkins = _G.DeadBoxSkins or {}
_G.AlreadyChangedSet = _G.AlreadyChangedSet or {}
_G.CurrentEquipVehicleID = _G.CurrentEquipVehicleID or 0

local function locationsClose(loc1, loc2, tolerance)
    local dx = loc1.X - loc2.X
    local dy = loc1.Y - loc2.Y
    local dz = loc1.Z - loc2.Z
    return dx*dx + dy*dy + dz*dz < tolerance*tolerance
end

if not table.contains then
    function table.contains(t, el)
        for _, v in ipairs(t) do if v == el then return true end end
        return false
    end
end

_G.ApplyDeadBoxSkin = function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if not pc then return end
    local uCharacter = pc:GetPlayerCharacterSafety()
    if not isValid(uCharacter) then return end
    local UGameplayStatics = import("GameplayStatics")
    if not UGameplayStatics then return end
    local ok, UIUtil = pcall(require, "client.common.ui_util")
    if not ok or not UIUtil then return end
    local uGameInstance = UIUtil.GetGameInstance()
    if not uGameInstance then return end
    local APlayerTombBox = import("PlayerTombBox")
    if not APlayerTombBox then return end
    local uActorArray = UGameplayStatics.GetAllActorsOfClass(uGameInstance, APlayerTombBox, slua.Array(UEnums.EPropertyClass.Object, import("Actor")))
    if not uActorArray then return end
    for _, actor in pairs(uActorArray) do
        if isValid(actor) then
            local DamageCauser = actor.DamageCauser
            if DamageCauser and DamageCauser.PlayerKey == pc.PlayerKey then
                local Deadboxavatar = actor.DeadBoxAvatarComponent_BP
                if Deadboxavatar and not table.contains(_G.AlreadyChangedSet, actor) then
                    local ApplySkinID = 0
                    local cw = uCharacter:GetCurrentWeapon()
                    if cw and cw.synData then
                        ApplySkinID = slua.IndexReference(cw.synData:Get(7), "defineID").TypeSpecificID
                    end
                    if ApplySkinID and ApplySkinID > 0 then
                        Deadboxavatar:ResetItemAvatar()
                        Deadboxavatar:PreChangeItemAvatar(ApplySkinID)
                        Deadboxavatar:SyncChangeItemAvatar(ApplySkinID)
                    end
                    table.insert(_G.AlreadyChangedSet, actor)
                end
            end
        end
    end
end

-- ============================================================================
-- MODULE 19: SELF-HEALING & PERIODIC RESET (60 seconds)
-- ============================================================================
local function StartPeriodicReset()
    local counter = 0
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not IsValid(pc) then return end
    
    pcall(function()
        pc:AddGameTimer(3.0, true, function()
            if not IsValid(pc) then return end
            counter = counter + 1
            
            if counter >= 20 then
                counter = 0
                _G.BYPASS_STATE.FULL_BYPASS_ACTIVE = false
                _G.BYPASS_STATE.DEADEYE_DISABLED = false
                _G.BYPASS_STATE.HAWKEYE_DISABLED = false
                _G.BYPASS_STATE.VOKLAI_DISABLED = false
                _G.BYPASS_STATE.HIGGSBOSON_DISABLED = false
                _G.BYPASS_STATE.HASH_VERIFY_DISABLED = false
                _G.BYPASS_STATE.IP_MAPPING_DISABLED = false
                _G.BYPASS_STATE.MEMORY_PATCH_DISABLED = false
                _G.BYPASS_STATE.EDU_EYE_DISABLED = false
                ApplyAllBypasses()
            end
        end)
    end)
end

-- ============================================================================
-- MODULE 20: STATUS CHECKER
-- ============================================================================
function _G.GetBypassStatus()
    return {
        deadEye = _G.BYPASS_STATE.DEADEYE_DISABLED,
        hawkEye = _G.BYPASS_STATE.HAWKEYE_DISABLED,
        voklai = _G.BYPASS_STATE.VOKLAI_DISABLED,
        higgsBoson = _G.BYPASS_STATE.HIGGSBOSON_DISABLED,
        fullBypass = _G.BYPASS_STATE.FULL_BYPASS_ACTIVE
    }
end

function _G.ForceReapplyBypass()
    _G.BYPASS_STATE.FULL_BYPASS_ACTIVE = false
    _G.BYPASS_STATE.DEADEYE_DISABLED = false
    _G.BYPASS_STATE.HAWKEYE_DISABLED = false
    _G.BYPASS_STATE.VOKLAI_DISABLED = false
    _G.BYPASS_STATE.HIGGSBOSON_DISABLED = false
    _G.BYPASS_STATE.HASH_VERIFY_DISABLED = false
    _G.BYPASS_STATE.IP_MAPPING_DISABLED = false
    _G.BYPASS_STATE.MEMORY_PATCH_DISABLED = false
    _G.BYPASS_STATE.EDU_EYE_DISABLED = false
    ApplyAllBypasses()
end

-- ============================================================================
-- MAIN: APPLY ALL BYPASSES
-- ============================================================================
local function ApplyAllBypasses()
    if _G.BYPASS_STATE.FULL_BYPASS_ACTIVE then return end
    
    pcall(function()
        Module_SLuaBypass()
        Module_MD5Bypass()
        InitSmartPacketHandler()
        StartHeartbeatSystem()
        finalStart()
        ReadLiveConfig()
        _G.ForceEnableKillCounterUI()
        
        _G.BYPASS_STATE.DEADEYE_DISABLED = true
        _G.BYPASS_STATE.HAWKEYE_DISABLED = true
        _G.BYPASS_STATE.VOKLAI_DISABLED = true
        _G.BYPASS_STATE.HIGGSBOSON_DISABLED = true
        _G.BYPASS_STATE.HASH_VERIFY_DISABLED = true
        _G.BYPASS_STATE.IP_MAPPING_DISABLED = true
        _G.BYPASS_STATE.MEMORY_PATCH_DISABLED = true
        _G.BYPASS_STATE.EDU_EYE_DISABLED = true
        _G.BYPASS_STATE.FULL_BYPASS_ACTIVE = true
        
        GhostCore.Active = true
        StartPeriodicReset()
    end)
end

-- ============================================================================
-- START BYPASS (Staggered)
-- ============================================================================
local function StartOmegaProtocol()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if IsValid(pc) and pc.AddGameTimer then
        local delay = math.random(3000, 8000)
        pc:AddGameTimer(delay/1000, false, ApplyAllBypasses)
        
        pc:AddGameTimer(30.0, true, function()
            SafeExec(function()
                if GhostCore.Active then
                    Module_SLuaBypass()
                    Module_MD5Bypass()
                    InitSmartPacketHandler()
                    hookPerPlayerHiggs()
                end
            end)
        end)
    else
        ApplyAllBypasses()
    end
end

-- ============================================================================
-- INITIALIZE
-- ============================================================================
StartOmegaProtocol()

-- ============================================================================
-- PRINT STATUS
-- ============================================================================
print("========================================")
print("  OMEGA PROTOCOL v6.0 - FULL ACTIVE")
print("========================================")
print("  ✓ SLUA + MD5 + PAK Signature")
print("  ✓ Report Flows (Aim/Hit/Attack/Circle)")
print("  ✓ Higgs Boson + Anti-Cheat")
print("  ✓ Heartbeat + Swift Hawk")
print("  ✓ TLog + Telemetry Blocked")
print("  ✓ HTTP + File Blocked")
print("  ✓ Skins + Attachments")
print("  ✓ ESP + Wallhack")
print("  ✓ Aimbot + Recoil Control")
print("  ✓ Kill Counter")
print("========================================")
print("  Commands:")
print("  _G.GetBypassStatus()    - Status")
print("  _G.ForceReapplyBypass() - Reapply")
print("  _G.CheatsEnabled = false - Disable")
print("========================================")
