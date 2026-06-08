-- ============================================================================
-- ULTIMATE MERGED BYPASS v6.0 - "GHOST PROTOCOL + AK MOD"
-- Complete Anti-Detection | ESP | Aimbot | Self-Healing
-- Fully Integrated & Optimized for 2026
-- ============================================================================

-- ============================================================================
-- GUARD: Per-match initialization (allow re-init when player controller changes)
-- ============================================================================
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then return end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

-- ============================================================================
-- GLOBALS & UTILITIES
-- ============================================================================
_G.CheatsEnabled = true

local require = require
local import = import
local isValid = slua.isValid

local function nop() end
local function retTrue() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local ok_gd, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
if not ok_gd then GameplayData = nil end

print("[MERGED] Initializing Complete Bypass System...")

-- ============================================================================
-- CORE UTILITIES & OBSCURATION
-- ============================================================================
local GhostCore = {}
GhostCore.Version = "6.0-MERGED"
GhostCore.Active = false

local function SafeExec(func, errorMsg)
    local success, result = pcall(func)
    if not success then return nil end
    return result
end

local function RetTrueMimic()
    if math.random(1, 100) > 5 then return true end
    return false
end

local function RetFalseMimic()
    if math.random(1, 100) > 5 then return false end
    return true
end

local function SafeWrap(originalFunc, mockFunc, mimicChance)
    if type(originalFunc) ~= "function" then return mockFunc end
    mimicChance = mimicChance or 0
    return function(...)
        if mimicChance > 0 and math.random(1, 100) <= mimicChance then
            return originalFunc(...)
        end
        return mockFunc(...)
    end
end

-- ============================================================================
-- MODULE 1: SLUA & INTEGRITY Bypass
-- ============================================================================
local Module_SLuaBypass = {}

function Module_SLuaBypass:Initialize()
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
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then
            slua_serialize.check = SafeWrap(slua_serialize.check, RetTrueMimic, 5)
            slua_serialize.verify = SafeWrap(slua_serialize.verify, RetTrueMimic, 5)
        end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = SafeWrap(_G.slua_verify, RetTrueMimic, 5) end
        if _G.check_slua_integrity then _G.check_slua_integrity = SafeWrap(_G.check_slua_integrity, RetTrueMimic, 5) end
    end)
    print("[MERGED] SLUA Bypass Active")
end

-- ============================================================================
-- MODULE 2: MD5 & Signature Bypass
-- ============================================================================
local Module_MD5Bypass = {}

function Module_MD5Bypass:Initialize()
    SafeExec(function()
        local console = import("KismetSystemLibrary")
        if console then
            local cmds = {
                "pak.DisablePakSignatureCheck 1",
                "pakchunk.EnableSignatureCheck 0",
                "s.VerifyPak 0",
                "sig.Check 0",
                "security.DisableChecks 1"
            }
            for _, cmd in ipairs(cmds) do
                pcall(function() console.ExecuteConsoleCommand(nil, cmd) end)
            end
        end
        
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end
            CreativeModeBlueprintLibrary.MD5HashFile = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "OK" end
            CreativeModeBlueprintLibrary.VerifyFileIntegrity = SafeWrap(CreativeModeBlueprintLibrary.VerifyFileIntegrity, RetTrueMimic, 5)
        end
        
        if _G.MD5Hash then _G.MD5Hash = function() return string.rep(string.format("%x", math.random(0, 255)), 16) end end
        if _G.CRC32 then _G.CRC32 = function() return math.random(0, 0xFFFFFFFF) end end
        if _G.SHA1 then _G.SHA1 = function() return "OK" end end
        
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = SafeWrap(FileHashChecker.CheckFileMD5, RetTrueMimic, 5)
            FileHashChecker.VerifyAll = SafeWrap(FileHashChecker.VerifyAll, RetTrueMimic, 5)
            FileHashChecker.GetHash = function() return "OK" end
        end
        
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            TssSdk.GetFileMD5 = function() return "OK" end
            TssSdk.VerifyFileSignature = SafeWrap(TssSdk.VerifyFileSignature, RetTrueMimic, 5)
        end
        
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary then
            STExtraBlueprintFunctionLibrary.CheckMD5 = SafeWrap(STExtraBlueprintFunctionLibrary.CheckMD5, RetTrueMimic, 5)
            STExtraBlueprintFunctionLibrary.GetMD5 = function() return "OK" end
            STExtraBlueprintFunctionLibrary.VerifyFile = SafeWrap(STExtraBlueprintFunctionLibrary.VerifyFile, RetTrueMimic, 5)
        end
    end)
    print("[MERGED] MD5 Bypass Active")
end

-- ============================================================================
-- MODULE 3: VISUALS & ESP Bypass
-- ============================================================================
local Module_VisualsBypass = {}

function Module_VisualsBypass:Initialize()
    SafeExec(function()
        local puffer_tlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if puffer_tlog then
            puffer_tlog.ReportEvent = nop
            puffer_tlog.ReportDownloadResult = nop
            puffer_tlog.ReportODPTDError = nop
        end
        
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then
            AvatarUtils.CheckIsWeaponInBlackList = RetFalseMimic
            AvatarUtils.IsValidAvatar = SafeWrap(AvatarUtils.IsValidAvatar, RetTrueMimic, 5)
            AvatarUtils.CheckAvatarIntegrity = SafeWrap(AvatarUtils.CheckAvatarIntegrity, RetTrueMimic, 5)
            AvatarUtils.ReportInvalidAvatar = nop
        end
        
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        local fileCheckSubsystem = SubsystemMgr and SubsystemMgr:Get("FileCheckSubsystem")
        if fileCheckSubsystem then
            fileCheckSubsystem.StartCheck = nop
            fileCheckSubsystem.ReportAbnormalFile = nop
            fileCheckSubsystem.StopCheck = nop
        end
        
        local equipmentException = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if equipmentException then
            equipmentException.Report = nop
            equipmentException.SendException = nop
        end
    end)
    print("[MERGED] Visuals Bypass Active")
end

-- ============================================================================
-- MODULE 4: LOG & TELEMETRY Blocker
-- ============================================================================
local Module_LogBlocker = {}

function Module_LogBlocker:Initialize()
    SafeExec(function()
        local ScreenshotMTDer = import("ScreenshotMTDer")
        if ScreenshotMTDer then
            ScreenshotMTDer.MTDePicture = function() return "" end
            ScreenshotMTDer.ReMTDePicture = function() return "" end
            ScreenshotMTDer.HasCaptured = RetFalseMimic
            ScreenshotMTDer.TakeScreenshot = nop
        end
        
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop
            TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop
            TLog.Flush = nop
        end
        
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = nop
            CrashSight.SetCustomData = nop
            CrashSight.Log = nop
            CrashSight.SendCrash = nop
            CrashSight.ReportUserException = nop
        end
        
        local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GameReportUtils then
            GameReportUtils.BugglyPostExceptionFull = RetFalseMimic
            GameReportUtils.CheckCanBugglyPostException = RetFalseMimic
            GameReportUtils.ReplayReportData = nop
            GameReportUtils.ReportGameException = nop
            GameReportUtils.PostException = nop
        end
        
        local ClientToolsReport = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if ClientToolsReport then
            ClientToolsReport.SendReport = nop
            ClientToolsReport.SendException = nop
            ClientToolsReport.UploadLog = nop
        end
        
        local TLogReportUtils = package.loaded["client.slua.config.tlog.tlog_report_utils"]
        if TLogReportUtils then
            TLogReportUtils.ReportTLogEvent = nop
            TLogReportUtils.FlushEvents = nop
        end
        
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]
            if s then
                s.logEvent = nop; s.trackEvent = nop; s.setEnabled = RetFalseMimic
                s.sendEvent = nop; s.report = nop
            end
        end
        
        -- AKMOD Extra log blocking
        local ug = package.loaded["client.slua.logic.ugc.UGCNewTLogReport"] or package.loaded["client.slua.data.BasicData.BasicDataTLogReport"]
        if ug then ug.SendExposeReq = nop; ug.SendInteractionReq = nop; ug.TLogReport = nop end
        local ut = package.loaded["client.slua.logic.ugc.logic_ugc_tlog"]
        if ut then ut.SendModTLog = nop; ut.ReportStay = nop end
        local ctl = safe_require("GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil")
        if ctl then ctl.ReportGeneralCountByBRPhase = nop; ctl.ReportCommonTLogDataByBRPhase = nop end
    end)
    print("[MERGED] Log Blocker Active")
end

-- ============================================================================
-- MODULE 5: SCANNER & VERIFICATION Blocker
-- ============================================================================
local Module_ScannerBlocker = {}

function Module_ScannerBlocker:Initialize()
    SafeExec(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local subsystems = {
                "AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem",
                "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem",
                "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"
            }
            
            for _, name in ipairs(subsystems) do
                local sub = SubsystemMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Send") or k:find("Upload") or 
                            k:find("Verify") or k:find("Check") or k:find("Validate") or
                            k:find("Scan") or k:find("Detect")
                        ) then
                            pcall(function() sub[k] = SafeWrap(sub[k], nop, 5) end)
                        end
                    end
                    if sub.ReportPingDelayTimer then
                        sub:RemoveGameTimer(sub.ReportPingDelayTimer)
                        sub.ReportPingDelayTimer = nil
                    end
                    sub.DelayCount = 0
                end
            end
        end
        
        local AvatarExceptionPlayerInst = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvatarExceptionPlayerInst then
            AvatarExceptionPlayerInst.CheckAvatarException = nop
            AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = nop
            AvatarExceptionPlayerInst.ReportAvatarException = nop
            AvatarExceptionPlayerInst.CheckSlotMeshVisible = RetFalseMimic
            AvatarExceptionPlayerInst.CheckPawnVisible = RetFalseMimic
            AvatarExceptionPlayerInst.CheckCanBugglyPostException = RetFalseMimic
        end
        
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local originalOnRecvData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data)
                if type(data) == "string" and (
                    string.find(data, "report") or string.find(data, "exception") or
                    string.find(data, "cheat") or string.find(data, "violation") or
                    string.find(data, "hack") or string.find(data, "verify")
                ) then
                    return
                end
                if originalOnRecvData then originalOnRecvData(data) end
            end
            TssSdk.SendReportInfo = nop
            TssSdk.ScanMemory = SafeWrap(TssSdk.ScanMemory, RetTrueMimic, 5)
            TssSdk.IsEmulator = RetFalseMimic
            TssSdk.GetTssSdkReportInfo = function() return "" end
            TssSdk.CheckEnvironment = SafeWrap(TssSdk.CheckEnvironment, RetTrueMimic, 5)
            TssSdk.VerifyProcess = SafeWrap(TssSdk.VerifyProcess, RetTrueMimic, 5)
        end
        
        -- AKMOD extra scanner blocking
        local ac = package.loaded["blacklist.slua.logic.lobby_gm.AvatarCheckerModule"]
        if ac then ac.CheckAvatar = RetTrueMimic; ac.ReportException = nop end
        local mw = package.loaded["client.slua.logic.memory_warning.logic_memory_warning"]
        if mw then mw.OnMemoryWarning = nop; mw.ReportMemoryWarning = nop end
    end)
    print("[MERGED] Scanner Blocker Active")
end

-- ============================================================================
-- MODULE 6: REPORT FLOW Blocker
-- ============================================================================
local Module_ReportFlowBlocker = {}

function Module_ReportFlowBlocker:Initialize()
    SafeExec(function()
        local reportFlows = {
            "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
            "ReportHurtFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow",
            "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate",
            "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition",
            "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData",
            "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP",
            "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
            "ReportDSNetRate", "ReportCircleFlow", "ReportPlayerKillFlow",
            "ReportMrpcsFlow", "ReportSecMrpcsFlow"
        }
        
        for _, funcName in ipairs(reportFlows) do
            if _G[funcName] then _G[funcName] = SafeWrap(_G[funcName], nop, 5) end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
                _G.GameplayCallbacks[funcName] = SafeWrap(_G.GameplayCallbacks[funcName], nop, 5)
            end
        end
        
        local checkFuncs = {"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}
        for _, funcName in ipairs(checkFuncs) do
            if _G[funcName] then _G[funcName] = SafeWrap(_G[funcName], RetFalseMimic, 5) end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
                _G.GameplayCallbacks[funcName] = SafeWrap(_G.GameplayCallbacks[funcName], RetFalseMimic, 5)
            end
        end
        
        local enableFlags = {
            "IsEnableReportPlayerKillFlow", "IsEnableReportMrpcsInCircleFlow",
            "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow",
            "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"
        }
        for _, flag in ipairs(enableFlags) do
            if _G[flag] then _G[flag] = SafeWrap(_G[flag], RetFalseMimic, 5) end
        end
        
        -- AKMOD report blocking
        local ToolReport = package.loaded["client.slua.logic.report.ToolReportUtil"]
        if ToolReport then
            ToolReport.IsReleaseVersion = RetFalseMimic
            ToolReport.IsWhite = RetFalseMimic
            ToolReport.GetReportSwitch = RetFalseMimic
        end
        
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
            BanUtil.CheckBanStatus = RetFalseMimic
            BanUtil.GetBanTime = retZero
            BanUtil.IsBanForever = RetFalseMimic
        end
        
        local TTBan = package.loaded["client.logic.login.logic_tt_ban"] or _G.logic_tt_ban
        if TTBan then
            TTBan.CheckIfCanCreateRole = nop
            TTBan.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end
        end
        
        local GodzillaBan = package.loaded["client.network.Protocol.GodzillaBanHandler"]
        if GodzillaBan then
            GodzillaBan.send_godzilla_ban_req = nop
            GodzillaBan.send_godzilla_unban_req = nop
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
    end)
    print("[MERGED] Report Flow Blocker Active")
end

-- ============================================================================
-- MODULE 7: CLIENT FLOW Bypass
-- ============================================================================
local Module_ClientFlowBypass = {}

function Module_ClientFlowBypass:Initialize()
    SafeExec(function()
        local flowSubsystems = {
            "ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem",
            "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"
        }
        
        for _, name in ipairs(flowSubsystems) do
            local sub = package.loaded[name] or _G[name]
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Send") or k:find("Flow") or
                        k:find("Record") or k:find("Process")
                    ) then
                        pcall(function() sub[k] = SafeWrap(sub[k], nop, 5) end)
                    end
                end
            end
        end
        
        local CircleFlow = require("GameLua.Mod.BaseMod.Client.Security.ClientCircleFlowSubsystem")
        if CircleFlow then
            CircleFlow.ReportCircleFlow = nop
            CircleFlow.SendCircleData = nop
            CircleFlow.ReportPlayerPosition = nop
            CircleFlow.ReportCircleData = nop
        end
        
        if _G.ReportPlayerKillFlow then _G.ReportPlayerKillFlow = nop end
        if _G.ClientSecPlayerKillFlow then _G.ClientSecPlayerKillFlow = nop end
        
        -- AKMOD: Kill callbacks in GameplayCallbacks
        local callbacks = _G.GameplayCallbacks or _G.GC
        if callbacks then
            local kills = {
                "SendTssSdkAntiDataToLobby","SendDSErrorLogToLobby","SendDSHawkEyePatrolLogToLobby",
                "SendSecTLog","SendDataMiningTLog","SendActivityTLog","SendClientMemUsage","SendClientFPS",
                "OnClientCrashReport","OnNetworkLossDetected","ReportMatchRoomData","ReportPlayersPing",
                "SendClientStats","SendServerAvgTickDelta","ReportHitFlow","OnPlayerActorChannelError","OnPlayerRPCValidateFailed"
            }
            for _, fn in ipairs(kills) do if callbacks[fn] then callbacks[fn] = nop end end
        end
        
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
        
        local secUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"]
        if secUtils and secUtils.EStrategyTypeInReplay then
            secUtils.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
            secUtils.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
            secUtils.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
            secUtils.EStrategyTypeInReplay.FlyingErrorCnt = 0
        end
    end)
    print("[MERGED] Client Flow Bypass Active")
end

-- ============================================================================
-- MODULE 8: HEARTBEAT & SWIFT HAWK Bypass
-- ============================================================================
local Module_HeartbeatSwiftBypass = {}

function Module_HeartbeatSwiftBypass:Initialize()
    SafeExec(function()
        local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat"}
        for _, func in ipairs(heartbeatFuncs) do
            if _G[func] then _G[func] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
                _G.GameplayCallbacks[func] = nop
            end
        end
        
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local heartbeatSub = SubsystemMgr:Get("HeartbeatSubsystem")
            if heartbeatSub then
                if heartbeatSub.timer then heartbeatSub:RemoveGameTimer(heartbeatSub.timer) end
                heartbeatSub.SendHeartbeat = nop
                heartbeatSub.StartHeartbeat = nop
            end
        end
        
        local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
        for _, func in ipairs(swiftFuncs) do
            if _G[func] then _G[func] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
                _G.GameplayCallbacks[func] = nop
            end
        end
        
        local SwiftHawkSubsystem = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if SwiftHawkSubsystem then
            SwiftHawkSubsystem.ReportData = nop
            SwiftHawkSubsystem.SendReport = nop
            SwiftHawkSubsystem.CollectTelemetry = nop
        end
    end)
    print("[MERGED] Heartbeat & Swift Hawk Bypass Active")
end

-- ============================================================================
-- MODULE 9: HIGGS BOSON & ANTI-CHEAT Bypass
-- ============================================================================
local Module_HiggsAntiCheatBypass = {}

function Module_HiggsAntiCheatBypass:Initialize()
    SafeExec(function()
        local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            local methods = {
                "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
                "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord",
                "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData",
                "ValidateSecurityData", "StaticShowSecurityAlertInDev", "RPC_Client_ShootVertifyRes",
                "RPC_Server_ReportSimulateCharacterLocation", "DisableHiggsBoson", "CheckMHActive",
                "ReportViolation", "ProcessSecurityEvent", "ValidatePlayer", "CheckIntegrity"
            }
            for _, m in ipairs(methods) do
                if Higgs[m] then Higgs[m] = SafeWrap(Higgs[m], nop, 5) end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.IsMHActive = RetFalseMimic
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
            if Higgs.BlackList then
                for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end
            end
        end
        
        -- AKMOD: Higgs bypass per player
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
        
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
        
        if _G.AvatarCheckCallback then
            _G.AvatarCheckCallback.StartAvatarCheck = nop
            _G.AvatarCheckCallback.OnReportItemID = nop
            _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
                if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then
                    PlayerController.HiggsBosonComponent:ControlMHActive(0)
                    PlayerController.HiggsBosonComponent.bMHActive = false
                end
            end
        end
        
        _G.BlackList = {}
        _G.DisableHiggsBoson = nop
    end)
    print("[MERGED] Higgs Boson & Anti-Cheat Bypass Active")
end

-- ============================================================================
-- MODULE 10: ANTI-REPORT & GAMEPLAY Bypass
-- ============================================================================
local Module_AntiReportGameplayBypass = {}

function Module_AntiReportGameplayBypass:Initialize()
    SafeExec(function()
        local paths = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "Client.Security.ClientReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"
        }
        
        for _, path in ipairs(paths) do
            local sub = package.loaded[path]
            if not sub then
                local success, reqModule = pcall(require, path)
                if success and reqModule then sub = reqModule end
            end
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Record") or k:find("Send") or
                        k:find("Upload") or k:find("Notify")
                    ) then
                        pcall(function() sub[k] = SafeWrap(sub[k], nop, 5) end)
                    end
                end
            end
        end
        
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        
        local GC = _G.GameplayCallbacks
        
        local reportFuncs = {
            "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow", "ReportFireArms",
            "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt",
            "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute",
            "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow",
            "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow",
            "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
            "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate",
            "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta",
            "ReportCircleFlow", "ReportPlayerKillFlow", "ClientSecMrpcsFlow", "Heartbeat",
            "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"
        }
        
        for _, funcName in ipairs(reportFuncs) do
            GC[funcName] = SafeWrap(GC[funcName], nop, 5)
        end
        
        GC.CheckReportSecAttackFlowWithAttackFlow = SafeWrap(GC.CheckReportSecAttackFlowWithAttackFlow, RetFalseMimic, 5)
        GC.CheckReportSecAttackFlow = SafeWrap(GC.CheckReportSecAttackFlow, RetFalseMimic, 5)
        
        local originalDSPlayerState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            local stateStr = InPlayerState and string.lower(tostring(InPlayerState)) or ""
            local blockedStates = {
                ["cheatdetected"] = true, ["connectionlost"] = true, ["connectiontimeout"] = true,
                ["connectionexception"] = true, ["netdrivererror"] = true, ["banned"] = true,
                ["kicked"] = true, ["suspended"] = true, ["violationdetected"] = true,
                ["integrityfailure"] = true, ["securityviolation"] = true
            }
            if blockedStates[stateStr] then return end
            if originalDSPlayerState then pcall(originalDSPlayerState, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
        end
        
        GC.OnPlayerNetConnectionClosed = nop
        GC.OnPlayerActorChannelError = nop
        GC.OnPlayerRPCValidateFailed = nop
        GC.OnPlayerSpectateException = nop
        GC.OnShutdownAfterError = nop
        
        GC.IsBypassed = true
        
        -- AKMOD: Client and DS report subsystem blocking
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
        if reportUtils then reportUtils.GetBotType = retZero; reportUtils.IsCharacterDeliverAI = RetFalseMimic end
        
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
        
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local hawk = SubsystemMgr:Get("DSHawkEyePatrolSubsystem")
            if hawk then hawk.MarkSuspiciousPlayer = nop end
        end
        if _G.DSHawkEyePatrolSubsystem then
            _G.DSHawkEyePatrolSubsystem._OnHawkReport = nop
            _G.DSHawkEyePatrolSubsystem._OnHawkImprison = nop
            _G.DSHawkEyePatrolSubsystem.CheckPunishPlayer = nop
        end
        
        local ClientHawk = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
        if ClientHawk then
            local funcs = {"_OnHawkSync","_OnHawkReportSuccess","_StartExitGameTimer","_OnRecvInspectorBroadcastCount","SendReportTLog","ReportCheat"}
            for _, fn in ipairs(funcs) do if ClientHawk[fn] then ClientHawk[fn] = nop end end
            ClientHawk.CanInspectorBroadcast = RetFalseMimic
        end
        
        local InspectClient = package.loaded["GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"]
        if InspectClient then
            local funcs = {"AskForInspector","ReportEnemy","KickOutOneTeam","OnReceiveInspectCmd","ClientReportData","SendReportToInspector","SendKickOutOneTeam","ClientNotifyInspectorImplementation","RecvNotifyInspector"}
            for _, fn in ipairs(funcs) do if InspectClient[fn] then InspectClient[fn] = nop end end
        end
        
        local InspectDS = package.loaded["GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"]
        if InspectDS then
            local funcs = {"ServerKickOutOneTeamByPlayerImplementation","AddReportedCount","AddInspectionRecord","BanPlayerByInspection","BroadCastToAllInspector","ServerReportToInspectorImplementation","InitPlayerInspectionInfo"}
            for _, fn in ipairs(funcs) do if InspectDS[fn] then InspectDS[fn] = nop end end
        end
    end)
    print("[MERGED] Anti-Report & Gameplay Bypass Active")
end

-- ============================================================================
-- MODULE 11: TLOG & PROTOCOL HANDLER BLOCKER
-- ============================================================================
local Module_TLogBlocker = {}

function Module_TLogBlocker:Initialize()
    SafeExec(function()
        local tlogModules = {
            "client.network.Protocol.ClientTlogHandler",
            "client.network.Protocol.BattleReportHandler",
            "client.network.Protocol.ClientErrorReportHandler",
            "client.network.Protocol.LobbyPingReportHandler",
            "client.slua.config.tlog.tlog_report_utils",
            "client.slua.data.BasicData.BasicDataTLogReport",
            "client.slua.data.BasicData.BasicDataClientReport",
            "client.slua.data.BasicData.BasicDataReport",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
            "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"
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
        
        local ClientError = package.loaded["client.network.Protocol.ClientErrorReportHandler"]
        if ClientError then
            ClientError.send_client_error_report = nop
            ClientError.send_client_crash_report = nop
            ClientError.send_client_tools_batch_report_req = nop
        end
        
        local BattleReport = package.loaded["client.network.Protocol.BattleReportHandler"]
        if BattleReport then
            BattleReport.send_battle_report = nop
            BattleReport.send_battle_result = nop
            BattleReport.send_vod_game_report_req = nop
            BattleReport.send_batch_get_vod_info_req = nop
            BattleReport.send_get_game_report_req = nop
            BattleReport.send_batch_get_game_report_req = nop
            BattleReport.send_get_game_report_by_uid_req = nop
        end
        
        local BugHandler = package.loaded["client.network.Protocol.BugHandler"]
        if BugHandler then
            BugHandler.send_report_bug_info = nop
            BugHandler.send_report_bug_feedback = nop
        end
        
        local PingReport = package.loaded["client.network.Protocol.LobbyPingReportHandler"]
        if PingReport then
            PingReport.send_lobby_ping_report = nop
            PingReport.send_ingame_ping_report = nop
        end
        
        local EmuHandler = package.loaded["client.network.Protocol.EmulatorHandler"]
        if EmuHandler then EmuHandler.send_emulator_info = nop end
        
        local EmuScanner = package.loaded["client.logic.login.emulator_scanner"]
        if EmuScanner then
            EmuScanner.StartScan = nop
            EmuScanner.GetScanResult = RetFalseMimic
            EmuScanner.ReportScanResult = nop
        end
        
        local LoginVerify = package.loaded["client.network.Protocol.LoginVerifyHandler"]
        if LoginVerify then
            LoginVerify.send_login_verify_req = nop
            LoginVerify.send_device_verify_req = nop
        end
        
        local LogicComplaint = package.loaded["client.logic.battle.logic_complaint"]
        if LogicComplaint then
            LogicComplaint.SendComplaintReq = nop
            LogicComplaint.Submit = nop
            LogicComplaint.ReportPlayer = nop
            LogicComplaint.ShowComplaint = nop
            LogicComplaint.ShowHandle = nop
        end
    end)
    print("[MERGED] TLog & Protocol Blocker Active")
end

-- ============================================================================
-- MODULE 12: NETWORK PACKET BLOCK
-- ============================================================================
local Module_NetworkBlock = {}

function Module_NetworkBlock:Initialize()
    SafeExec(function()
        if NetUtil and NetUtil.SendPacket and not NetUtil.IsBypassed then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
                ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
                ["ReportPlayerBehavior"] = 1, ["ReportTeammatHurt"] = 1, ["ReportPlayerMoveRoute"] = 1,
                ["ReportPlayerPosition"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
                ["ReportCircleFlow"] = 1, ["report_players_ping"] = 1, ["report_player_ip"] = 1,
                ["report_net_saturate"] = 1, ["report_speed_hack"] = 1, ["report_wall_hack"] = 1,
                ["report_aim_bot"] = 1, ["report_esp_usage"] = 1, ["report_modded_files"] = 1,
                ["detect_cheat"] = 1, ["ban_player"] = 1, ["client_anti_cheat_report"] = 1,
                ["ReportPlayerKillFlow"] = 1, ["ClientSecPlayerKillFlow"] = 1,
                ["ReportMrpcsFlow"] = 1, ["ClientSecMrpcsFlow"] = 1, ["MrpcsData"] = 1,
                ["CheckReportSecAttackFlow"] = 1, ["CheckReportSecAttackFlowWithAttackFlow"] = 1,
                ["RPC_ClientCoronaLab"] = 1, ["CoronaLabReport"] = 1, ["CoronaLabData"] = 1,
                ["PlayerSecurityInfo"] = 1, ["ReportSecurityInfo"] = 1, ["SendSecurityData"] = 1,
                ["ClientCircleFlow"] = 1, ["IsEnableReportPlayerKillFlow"] = 1,
                ["IsEnableReportMrpcsInCircleFlow"] = 1, ["IsEnableReportMrpcsInPartCircleFlow"] = 1,
                ["bReportedModifierException"] = 1, ["ReportModifierException"] = 1,
                ["RPC_Server_ReportSimulateCharacterLocation"] = 1, ["ReportSimulateCharacterLocation"] = 1,
                ["RPC_Client_ShootVertifyRes"] = 1, ["BulletHitInfoUploadData"] = 1,
                ["ShootVerifyFailed"] = 1, ["report_unrealnet_exception"] = 1, ["tss_sdk_report"] = 1,
                ["Heartbeat"] = 1, ["ClientHeartbeat"] = 1, ["ServerHeartbeat"] = 1,
                ["SwiftHawk"] = 1, ["ClientSwiftHawk"] = 1, ["ClientSwiftHawkWithParams"] = 1,
                ["SwiftHawkReport"] = 1, ["SwiftHawkData"] = 1,
                ["AntiCheatReport"] = 1, ["CheatDetection"] = 1, ["ViolationReport"] = 1,
                ["SecurityViolation"] = 1, ["IntegrityCheck"] = 1, ["SignatureVerify"] = 1,
                ["send_ugc_report_uni_mod_expose_req"] = 1, ["send_ugc_report_uni_mod_interactive_req"] = 1,
                ["ReportHeavyWeaponBoxSpawnFlow"] = 1, ["ReportHeavyWeaponBoxActivationFlow"] = 1,
                ["ReportSecTLog"] = 1, ["report_ds_net_saturation"] = 1, ["on_tss_sdk_anti_data"] = 1,
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return nil end
                return originalSend(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end
        
        if _G.SendRPC then
            local originalSendRPC = _G.SendRPC
            local blockedRPCs = {
                "RPC_Server_ReportPlayerKillFlow", "RPC_Server_ClientSecMrpcsFlow",
                "RPC_Server_Heartbeat", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams",
                "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes",
                "RPC_ClientCoronaLab", "RPC_Server_ClientSecAttackFlow",
                "RPC_Server_ReportAttackFlow", "RPC_Server_ReportSecAttackFlow"
            }
            _G.SendRPC = function(rpcName, ...)
                for _, blocked in ipairs(blockedRPCs) do
                    if rpcName == blocked then return nil end
                end
                return originalSendRPC(rpcName, ...)
            end
        end
    end)
    print("[MERGED] Network Packet Block Active")
end

-- ============================================================================
-- MODULE 13: SUBSYSTEM KILLER
-- ============================================================================
local Module_SubsystemKiller = {}

function Module_SubsystemKiller:Initialize()
    SafeExec(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        
        local subsystemsToKill = {
            "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
            "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
            "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem",
            "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem",
            "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
            "AvatarExceptionSubsystem", "GameReportSubsystem", "RescueBtnReplayTraceSubsystem",
            "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "PlayerKillFlowSubsystem",
            "CircleFlowSubsystem", "SwiftHawkSubsystem", "HeartbeatSubsystem",
            "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
            "MD5CheckSubsystem", "PakVerifySubsystem", "InspectionSystemReportClientLogicSubsystem",
            "InspectionSystemReportDSLogicSubsystem"
        }
        
        for _, name in ipairs(subsystemsToKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Send") or k:find("Upload") or 
                        k:find("Verify") or k:find("Check") or k:find("Validate") or
                        k:find("Scan") or k:find("Detect") or k:find("Collect") or
                        k:find("Flow") or k:find("Heartbeat")
                    ) then
                        pcall(function() sub[k] = SafeWrap(sub[k], nop, 5) end)
                    end
                end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
        
        local globalFlags = {
            "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY",
            "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"
        }
        for _, flag in ipairs(globalFlags) do
            if _G[flag] then _G[flag] = false end
        end
        
        local originalRequire = require
        local blockedModules = {
            "HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem",
            "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient",
            "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem",
            "DSHawkEyePatrolSubsystem", "InspectionSystemReportClientLogicSubsystem",
            "InspectionSystemReportDSLogicSubsystem"
        }
        _G.require = function(module)
            for _, blocked in ipairs(blockedModules) do
                if module:find(blocked) then return {} end
            end
            return originalRequire(module)
        end
    end)
    print("[MERGED] Subsystem Killer Active")
end

-- ============================================================================
-- MODULE 14: HTTP REQUEST & FILE IO BLOCKER
-- ============================================================================
local BLACKLIST_HOSTS = {
    "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","feedback.wh","crash2",
    "privacy.qq","privacy.tencent","oth.eve","mdt.qq","act.tencentyun","analytics","report.qq",
    "anticheatexpert","crashsight","wetest","log.tav","sngd","tracer","intlsdk","igamecj",
    "cdn.club","gpubgm","graph.facebook","calendarpushsubscription","googleads","doubleclick",
    "firebaselogging","firebaseremoteconfig","fonts.googleapis","abs.twimg","dl.listdl",
    "igame.gcloudcs","bugly","beacon","helpshift","tdm","apm","safeguard","weiyun","qzone",
    "tencent-cloud","myapp","idqqimg","gtimg","qqmail","tcdn","cloudctrl","sdkostrace",
    "103.134.189.146","mbgame","csoversea","igame","pubgmobile","down.anticheatexpert.com",
    "asia.csoversea.mbgame.anticheatexpert.com","log.tav.qq","syzsdk.qq","logiservice.qcloud",
    "opensdk.tencent","exp.helpshift","loginsdkapi.zingplay","firebase","googleapis","facebook","gvoice"
}
local BLACKLIST_PORTS = {
    "10334","11045","12221","13331","8011","8015","9001","20000","20001","20002","20003","20004",
    "20005","19700","1670","19900","14545","10213","8700","25177","10685","10336","10262","27000",
    "27040","27015","27030","10706","10095","12401","11008","10309","11075","10157","24798","10709",
    "6667","10087","31113","20371","10120","10664","13728","10769","10761","5061","5062","18081",
    "15692","9030","8080","8086","8088"
}
local FILE_KEYWORDS = {
    "tlog","crash","bugly","report","beacon","wetest","analytics","telemetry","trace","dump",
    "exception","feedback","aps_log","mtp_detect","network_loss","client_error","ue4crash","tdm","gcloud"
}

local function isBlacklisted(str)
    if type(str) ~= "string" then return false end
    local low = str:lower()
    for _, kw in ipairs(BLACKLIST_HOSTS) do if low:find(kw,1,true) then return true end end
    for _, port in ipairs(BLACKLIST_PORTS) do if low:find(":"..port) or low:find("/"..port) then return true end end
    return false
end

local Module_HttpFileBlocker = {}

function Module_HttpFileBlocker:Initialize()
    SafeExec(function()
        if _G.HttpRequest then
            local orig = _G.HttpRequest
            _G.HttpRequest = function(url, ...) if isBlacklisted(url) then return nil end return orig(url, ...) end
        end
        if _G.FHttpModule and _G.FHttpModule.CreateRequest then
            local orig = _G.FHttpModule.CreateRequest
            _G.FHttpModule.CreateRequest = function(...) local url = select(1,...); if isBlacklisted(url) then return nil end return orig(...) end
        end
        
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
                if lp:find("tdm") or lp:find("gcloud") or lp:find("beacon") then
                    if mode and (mode == "w" or mode == "a" or mode == "w+") then return nil end
                end
            end
            return orig_io_open(path, mode)
        end
        
        if _G.UnrealEngine and _G.UnrealEngine.CrashContext then
            _G.UnrealEngine.CrashContext = nil
            _G.UnrealEngine.CrashContext = { SetCrashContext = nop, ReportCrash = nop, AddCrashData = nop }
        end
    end)
    print("[MERGED] HTTP & File IO Blocker Active")
end

-- ============================================================================
-- MODULE 15: FEATURE ENHANCEMENTS (FPS, iPad View, etc.)
-- ============================================================================
function _G.Enable165FPSLogic()
    pcall(function()
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then self:ExecuteCMD("t.MaxFPS", "165"); self:ExecuteCMD("r.FrameRateLimit", "165") end
            end
        end
        local fpsComp = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        if fpsComp and fpsComp.__inner_impl then
            local impl = fpsComp.__inner_impl
            function impl.GetMaxFPSLevel() return 8, 8 end
            function impl:InitRealSupportFPS()
                local t = {}; for i = 1, 8 do t[i] = {true, true} end
                local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                if db then db:UpdateUIData(db.RealSupportFPS, t, false) end
                return t
            end
        end
    end)
end

function _G.EnableiPadViewUI()
    pcall(function()
        local sc = require("client.logic.setting.setting_config")
        if sc then
            if sc.TpViewValue then sc.TpViewValue.max = 140 end
            if sc.FpViewValue then sc.FpViewValue.max = 140 end
        end
    end)
end

-- ============================================================================
-- CONFIG SYSTEM
-- ============================================================================
local BASE_PATH = "/storage/emulated/0/Android/data/com.pubg.imobile/files/"
local CONFIG_PATH = BASE_PATH .. "config.ini"

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
            end
        end
    end)
end

_G.ReadLiveConfig = ReadLiveConfig
-- ============================================================================
-- ESP SYSTEM
-- ============================================================================
local SecurityCommonUtils = safe_require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") or {}
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")

local cachedPawns = {}
local lastPawnRefresh = 0

local function IsPawnAlive(p)
    if not isValid(p) then return false end
    if p.HealthStatus then return SecurityCommonUtils.IsHealthStatusAlive and SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus) or (p.HealthStatus == 0) end
    if p.IsAlive then return p:IsAlive() end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

local boneList = {"head","neck_01","spine_01","spine_02","spine_03","pelvis",
    "upperarm_l","upperarm_r","lowerarm_l","lowerarm_r","hand_l","hand_r",
    "calf_l","calf_r","foot_l","foot_r"}

local function TextScale(distM)
    local t = math.min(distM / 400, 1)
    return 0.35 - t * 0.2
end

local function HPBar(pct)
    local n = math.floor((pct * 4) + 0.5)
    local s = ""
    for i = 1, 4 do s = s .. (i <= n and "â–" or " ") end
    return s
end

local function ApplyWallHack(localPlayer, enemy, pc)
    if not _G.CheatsEnabled then return end
    if not slua.isValid(enemy) then return end
    local meshes = {}
    pcall(function()
        if slua.isValid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass then
            local childs = enemy:GetComponentsByClass(SkelClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for c = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(c-1) or childs[c]
                    if slua.isValid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    pcall(function()
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                comp.UseScopeDistanceCulling = false
                comp.PrimitiveShadingStrategy = 1
                comp.ShadingRate = 6
            end
        end
        local isVisible = false
        if slua.isValid(pc) and slua.isValid(enemy) and type(pc.LineOfSightTo) == "function" then
            pcall(function() isVisible = pc:LineOfSightTo(enemy) end)
        end
        local finalColor = isVisible and {R=0,G=25,B=0,A=1} or {R=25,G=25,B=0,A=1}
        local scale = {R=3,G=3,B=0,A=0}
        enemy._WH_MIDs = enemy._WH_MIDs or {}
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                local ck = tostring(comp)
                enemy._WH_MIDs[ck] = enemy._WH_MIDs[ck] or {}
                for i = 0, 10 do
                    local ok3, mi = pcall(function() return comp:GetMaterial(i) end)
                    if not ok3 or not slua.isValid(mi) then break end
                    local mid = enemy._WH_MIDs[ck][i]
                    if not slua.isValid(mid) then
                        local ok4, nm = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                        if ok4 and slua.isValid(nm) then enemy._WH_MIDs[ck][i] = nm; mid = nm end
                    end
                    if slua.isValid(mid) then
                        pcall(function()
                            mid:SetVectorParameterValue("é¢œè‰²", finalColor)
                            mid:SetVectorParameterValue("Color", finalColor)
                            mid:SetVectorParameterValue("BaseColor", finalColor)
                            mid:SetVectorParameterValue("BodyColor", finalColor)
                            mid:SetVectorParameterValue("ParaScaleOffset", scale)
                        end)
                    end
                end
            end
        end
    end)
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
        if isValid(char) and char.TeamID then myTeamId = char.TeamID
        elseif currentPawn.TeamID then myTeamId = currentPawn.TeamID end
    end)
    local myPos = nil
    pcall(function() myPos = currentPawn:K2_GetActorLocation() end)
    if not myPos then return end
    local myEyePos = myPos
    pcall(function()
        if currentPawn.GetHeadLocation then myEyePos = currentPawn:GetHeadLocation(false) or myPos end
    end)
    local HUD = uCon:GetHUD()
    local now = os.clock()

    if now - lastPawnRefresh > 1.0 then
        lastPawnRefresh = now
        cachedPawns = Game:GetAllPlayerPawns() or {}
    end

    local botCount = 0
    local playerCount = 0
    local totalAlive = 0
    for _, p in pairs(cachedPawns) do
        if isValid(p) and p ~= currentPawn and p.TeamID ~= myTeamId and IsPawnAlive(p) then
            totalAlive = totalAlive + 1
        end
    end
    local crowded = totalAlive > 20

    for _, tPawn in pairs(cachedPawns) do
        if isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId then
            if IsPawnAlive(tPawn) then
                local enemyPos = tPawn:K2_GetActorLocation()
                local dx = enemyPos.X - myPos.X
                local dy = enemyPos.Y - myPos.Y
                local dz = enemyPos.Z - myPos.Z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

                local isBot = false
                pcall(function() isBot = Game:IsAI(tPawn) end)
                if isBot then botCount = botCount + 1 else playerCount = playerCount + 1 end

                if dist < 600000 and HUD then
                    local name = tPawn.PlayerName or "UNKNOWN"
                    local distM = dist / 100
                    local hp = tPawn.Health
                    local maxHp = tPawn.HealthMax
                    local isKnock = false
                    local hpPercent = 0
                    if not hp or not maxHp or maxHp <= 0 then
                        isKnock = true
                    elseif hp <= 0 then
                        isKnock = true
                    else
                        hpPercent = hp / maxHp
                    end
                    local hpColor = {R=0,G=255,B=0,A=255}
                    if hpPercent < 0.3 then
                        hpColor = {R=255,G=0,B=0,A=255}
                    elseif hpPercent < 0.7 then
                        hpColor = {R=255,G=255,B=0,A=255}
                    end
                    if isKnock then
                        hpColor = {R=255,G=0,B=0,A=255}
                    end

                    local bones = {}
                    local mesh = tPawn.Mesh
                    if isValid(mesh) then
                        for _, bn in ipairs(boneList) do
                            bones[bn] = mesh:GetSocketLocation(bn)
                        end
                    end
                    local origin = enemyPos
                    local oz = origin.Z
                    local headPos = bones["head"]
                    local footPos = bones["foot_l"]
                    local footRPos = bones["foot_r"]
                    local topZ = headPos and (headPos.Z - oz) or 90
                    local botZ = footPos and math.min(footPos.Z, footRPos and footRPos.Z or footPos.Z) - oz or -85
                    local headZ = headPos and (headPos.Z - oz) or 90
                    local hpOffset = headZ + 70 + math.min(distM, 60) * 3 + math.max(0, distM - 60) * 0.5
                    local nameOffset = -80 - math.min(distM, 60) * 0.33 - math.max(0, distM - 60) * 0.1

                    if crowded then
                        local hz = headPos and (headPos.Z - oz + 15)
                        if hz then HUD:AddDebugText("â—", tPawn, TextScale(distM), {X=0,Y=0,Z=hz}, {X=0,Y=0,Z=hz}, {R=255,G=0,B=0,A=255}, true, false, true, nil, 1.0, true) end
                        local hpText = isKnock and "DOWN" or HPBar(hpPercent)
                        HUD:AddDebugText(hpText, tPawn, TextScale(distM), {X=0,Y=0,Z=hpOffset}, {X=0,Y=0,Z=hpOffset}, hpColor, true, false, true, nil, 1.0, true)
                    else
                        local hz = headPos and (headPos.Z - oz + 15)
                        local headChar = distM <= 25 and "â„" or "â—"
                        if hz then HUD:AddDebugText(headChar, tPawn, TextScale(distM), {X=0,Y=0,Z=hz}, {X=0,Y=0,Z=hz}, {R=255,G=0,B=0,A=255}, true, false, true, nil, 1.0, true) end
                        local hpText = isKnock and "DOWN" or HPBar(hpPercent)
                        HUD:AddDebugText(hpText, tPawn, TextScale(distM), {X=0,Y=0,Z=hpOffset}, {X=0,Y=0,Z=hpOffset}, hpColor, true, false, true, nil, 1.0, true)
                        local nameColor = {R=255,G=255,B=0,A=255}
                        local targetPos = headPos or tPawn:K2_GetActorLocation()
                        pcall(function()
                            if Game:IsTargetPosVisible(myEyePos, targetPos, {currentPawn}) then
                                nameColor = {R=255,G=255,B=0,A=255}
                            else
                                nameColor = {R=255,G=0,B=0,A=255}
                            end
                        end)
                        HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), tPawn, TextScale(distM), {X=0,Y=0,Z=nameOffset}, {X=0,Y=0,Z=nameOffset}, nameColor, true, false, true, nil, 1.0, true)
                    end
                    pcall(ApplyWallHack, currentPawn, tPawn, uCon)
                end
            end
        end
    end

    if not crowded and HUD and currentPawn then
        HUD:AddDebugText(string.format("BOT : %d     PLAYER : %d", botCount, playerCount), currentPawn, 1, {X=0,Y=0,Z=170}, {X=0,Y=0,Z=170}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
        HUD:AddDebugText("WOW BHAIYAAA KYA KHELTE HO", currentPawn, 1, {X=0,Y=0,Z=145}, {X=0,Y=0,Z=145}, {R=255,G=200,B=0,A=255}, true, false, true, nil, 1.0, true)
    end
end

-- ============================================================================
-- AIMBOT SYSTEM
-- ============================================================================
local function ApplyHardAimbot()
    if not _G.CheatsEnabled then return end
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not isValid(pc) then return end
        local char = pc:GetPlayerCharacterSafety()
        if not isValid(char) then return end
        local wm = char.WeaponManagerComponent
        if not isValid(wm) then return end
        local weapon = wm.CurrentWeaponReplicated
        if not isValid(weapon) then return end
        local entity = weapon.ShootWeaponEntityComp
        if not isValid(entity) then return end

        entity.GameDeviationFactor = 0.5
        entity.WeaponAimInTime = 20
        entity.SwitchFromIdleToBackpackTime = 0.15
        entity.SwitchFromBackpackToIdleTime = 0.15
        entity.ShotGunHorizontalSpread = 0.0
        entity.ShotGunVerticalSpread = 0.0
        entity.RecoilKick = 0.2
        entity.RecoilKickADS = 0.2
        entity.AnimationKick = 0.2
        entity.AccessoriesVRecoilFactor = 0.6
        entity.AccessoriesHRecoilFactor = 0.6
        if entity.RecoilInfo then
            entity.RecoilInfo.VerticalRecoilMin = 0.2
            entity.RecoilInfo.VerticalRecoilMax = 0.2
            entity.RecoilInfo.RecoilSpeedVertical = 0.2
            entity.RecoilInfo.RecoilSpeedHorizontal = 0.15
            entity.RecoilInfo.VerticalRecoveryMax = 0.2
        end
        entity.RecoilModifierStand = 0.2
        entity.RecoilModifierCrouch = 0.2
        entity.RecoilModifierProne = 0.2

        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 8
                    cfg.RangeRate = 2
                    cfg.SpeedRate = 5
                    cfg.RangeRateSight = 2
                    cfg.SpeedRateSight = 4
                    cfg.CrouchRate = 4
                    cfg.ProneRate = 4
                    cfg.DyingRate = 0
                    cfg.adsorbMaxRange = 200
                    cfg.adsorbMinRange = 20
                    cfg.adsorbMinAttenuationDis = 100
                    cfg.adsorbMaxAttenuationDis = 8000
                    cfg.adsorbActiveMinRange = 20
                end
            end
        end

        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C or char.BP_AutoAimingComponent or char.AutoAimingComponent
            if isValid(aimComp) and aimComp.Bones then
                pcall(function() aimComp.Bones[0] = "head" end)
                pcall(function() aimComp.Bones[1] = "head" end)
                pcall(function() aimComp.Bones[2] = "head" end)
                pcall(function() aimComp.Bones:Set(0, "head") end)
                pcall(function() aimComp.Bones:Set(1, "head") end)
                pcall(function() aimComp.Bones:Set(2, "head") end)
            end
        end)
    end)
end

-- ============================================================================
-- TIMER MANAGEMENT & INITIALIZATION
-- ============================================================================
_G._AimbotCurrentPC = nil

local function AttachAimbotTimer()
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not isValid(pc) then return end
        if pc == _G._AimbotCurrentPC then return end
        _G._AimbotCurrentPC = pc
        if pc.AddGameTimer then
            pc:AddGameTimer(0.1, true, function()
                if not isValid(_G._AimbotCurrentPC) then
                    _G._AimbotCurrentPC = nil
                    return
                end
                ApplyHardAimbot()
            end)
        end
    end)
end

local function StartESP(targetActor)
    if not isValid(targetActor) then return end
    cachedPawns = {}
    lastPawnRefresh = 0
    _G._ESPTimerChar = targetActor
    _G._ESPTimerHandle = targetActor:AddGameTimer(0.15, true, function()
        pcall(ESPTick)
    end)
end

local function ESPWatchdog()
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

local function StartPersistentHunt()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and isValid(pc) then
        if _G._permHuntTimer then pcall(function() pc:RemoveGameTimer(_G._permHuntTimer) end) end
        _G._permHuntTimer = pc:AddGameTimer(3.0, true, function()
            pcall(function()
                Module_HiggsAntiCheatBypass:Initialize()
                Module_NetworkBlock:Initialize()
                Module_HeartbeatSwiftBypass:Initialize()
                Module_AntiReportGameplayBypass:Initialize()
            end)
        end)
        return true
    end
    return false
end

local function SetupConfigTimer()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not (pc and slua.isValid(pc)) then return end
        if _G.ConfigTimerPC == pc then return end
        _G.ConfigTimerPC = pc
        pc:AddGameTimer(2.0, true, function()
            pcall(function()
                if _G.ReadLiveConfig then _G.ReadLiveConfig() end
            end)
        end)
    end)
end
local function FinalStart()
    if StartPersistentHunt() then
        SetupConfigTimer()
        ESPWatchdog()
        AttachAimbotTimer()
    else
        local fb = slua_GameFrontendHUD or Game
        if fb and isValid(fb) then fb:AddGameTimer(2.0, false, FinalStart) end
    end
end

-- ============================================================================
-- MAIN INITIALIZATION
-- ============================================================================
local function InitializeAllModules()
    SafeExec(function()
        print("[MERGED] Starting complete initialization...")
        
        -- Core Bypasses
        Module_SLuaBypass:Initialize()
        Module_MD5Bypass:Initialize()
        Module_VisualsBypass:Initialize()
        Module_LogBlocker:Initialize()
        Module_ScannerBlocker:Initialize()
        
        -- Flow Bypasses
        Module_ReportFlowBlocker:Initialize()
        Module_ClientFlowBypass:Initialize()
        Module_HeartbeatSwiftBypass:Initialize()
        
        -- Security Bypasses
        Module_HiggsAntiCheatBypass:Initialize()
        Module_AntiReportGameplayBypass:Initialize()
        
        -- Network & System
        Module_TLogBlocker:Initialize()
        Module_NetworkBlock:Initialize()
        Module_SubsystemKiller:Initialize()
        Module_HttpFileBlocker:Initialize()
        
        -- Feature Enhancements
        _G.Enable165FPSLogic()
        _G.EnableiPadViewUI()
        
        -- Read config
        ReadLiveConfig()
        
        GhostCore.Active = true
        print("[MERGED] Complete - All Systems Active")
        print("  âœ“ SLUA + MD5 + PAK Signature Bypass")
        print("  âœ“ Report Flows (Aim/Hit/Attack/Circle/Kill/Mrpcs)")
        print("  âœ“ Player Security & Higgs Boson")
        print("  âœ“ Heartbeat + SwiftHawk + TLog")
        print("  âœ“ Network Packet Block + HTTP/File IO Block")
        print("  âœ“ Subsystem Killer (All Anti-Cheat)")
        print("  âœ“ ESP + Wallhack + Aimbot")
        print("  âœ“ 165 FPS + iPad View")
    end)
end

-- ============================================================================
-- START BYPASS (Staggered Init with Random Delays)
-- ============================================================================
local function StartGhostProtocol()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        local delay = math.random(5000, 15000)
        pc:AddGameTimer(delay/1000, false, InitializeAllModules)
        pc:AddGameTimer(30.0, true, function()
            SafeExec(function()
                if GhostCore.Active then
                    Module_HiggsAntiCheatBypass:Initialize()
                    Module_NetworkBlock:Initialize()
                    Module_HeartbeatSwiftBypass:Initialize()
                    Module_AntiReportGameplayBypass:Initialize()
                end
            end)
        end)
    else
        InitializeAllModules()
    end
    FinalStart()
end

-- ============================================================================
-- MAIN CLASS (BRPlayerCharacterBase)
-- ============================================================================
local Class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass = require("combine_class")

local BRPlayerCharacterBase = {}

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super._PostConstruct(self)
    end
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    StartGhostProtocol()
    print("[MERGED] Ghost Protocol v6.0 Activated - Complete Protection")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    end
    if Client then
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        GameplayData.AddCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    end
    if Client then
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        GameplayData.RemoveCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState) return true end
function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle) end
function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle) end
function BRPlayerCharacterBase:ClearAttachToVehicleTimer() end

local CBRPlayerCharacterBase = Class(CCharacterBase, nil, BRPlayerCharacterBase)

return CombineClass.DeclareFeature(CBRPlayerCharacterBase, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
}, "BRPlayerCharacterBase")

