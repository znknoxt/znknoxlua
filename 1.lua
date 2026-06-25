--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               PAWAN MOD MENU — BR PLAYER SCRIPT             ║
    ║          Merged & Optimized from 5 Source Files              ║
    ║                    All Rights Reserved                       ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local SCRIPT_VERSION = "5.0"
local require = require
local import = import
local isValid = slua.isValid
local pcall = pcall
local pairs = pairs
local ipairs = ipairs
local type = type
local tostring = tostring
local tonumber = tonumber
local math = math
local string = string
local table = table
local os = os

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retTrue() return true end
local function retEmptyString() return "" end

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 1: COMPLETE BYPASS SYSTEM
-- ══════════════════════════════════════════════════════════════

local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then slua_serialize.check = retTrue; slua_serialize.verify = retTrue end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
end

local function InitializeMD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CreativeModeBlueprintLibrary.MD5HashFile = function() return "00000000000000000000000000000000" end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
            CreativeModeBlueprintLibrary.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = retTrue
            FileHashChecker.VerifyAll = retTrue
            FileHashChecker.GetHash = function() return "BYPASS" end
        end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then TssSdk.GetFileMD5 = function() return "BYPASS" end; TssSdk.VerifyFileSignature = retTrue end
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary then
            STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
            STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
            STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
        end
    end)
end

local function InitializeSkinBypass()
    pcall(function()
        local puffer_tlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if puffer_tlog then
            puffer_tlog.ReportEvent = nop
            puffer_tlog.ReportDownloadResult = nop
            puffer_tlog.ReportODPTDError = nop
            puffer_tlog.ReportSkinError = nop
        end
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then
            AvatarUtils.CheckIsWeaponInBlackList = retFalse
            AvatarUtils.IsValidAvatar = retTrue
            AvatarUtils.CheckAvatarIntegrity = retTrue
            AvatarUtils.ReportInvalidAvatar = nop
        end
        local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
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
end

local function InitializeLogBlocker()
    pcall(function()
        local ScreenshotMTDer = import("ScreenshotMTDer")
        if ScreenshotMTDer then
            ScreenshotMTDer.MTDePicture = function() return "" end
            ScreenshotMTDer.ReMTDePicture = function() return "" end
            ScreenshotMTDer.HasCaptured = retTrue
            ScreenshotMTDer.TakeScreenshot = nop
        end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop
            TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop; TLog.Flush = nop
        end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = nop; CrashSight.SetCustomData = nop
            CrashSight.Log = nop; CrashSight.SendCrash = nop; CrashSight.ReportUserException = nop
        end
        local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GameReportUtils then
            GameReportUtils.BugglyPostExceptionFull = retFalse
            GameReportUtils.CheckCanBugglyPostException = retFalse
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
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]
            if s then s.logEvent = nop; s.trackEvent = nop; s.setEnabled = retFalse; s.sendEvent = nop; s.report = nop end
        end
    end)
end

local function InitializeScannerBlocker()
    pcall(function()
        local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
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
                            pcall(function() sub[k] = nop end)
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
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local originalOnRecvData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data)
                if type(data) == "string" and (
                    string.find(data, "report") or string.find(data, "exception") or
                    string.find(data, "cheat") or string.find(data, "violation") or
                    string.find(data, "hack") or string.find(data, "verify")
                ) then return end
                if originalOnRecvData then originalOnRecvData(data) end
            end
            TssSdk.SendReportInfo = nop
            TssSdk.ScanMemory = retTrue
            TssSdk.IsEmulator = retFalse
            TssSdk.GetTssSdkReportInfo = retEmptyString
            TssSdk.CheckEnvironment = retTrue
            TssSdk.VerifyProcess = retTrue
        end
    end)
end

local function InitializeReportFlowBlocker()
    pcall(function()
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
            if _G[funcName] then _G[funcName] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
                _G.GameplayCallbacks[funcName] = nop
            end
        end
        local checkFuncs = {"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}
        for _, funcName in ipairs(checkFuncs) do
            if _G[funcName] then _G[funcName] = retFalse end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
                _G.GameplayCallbacks[funcName] = retFalse
            end
        end
        local enableFlags = {
            "IsEnableReportPlayerKillFlow", "IsEnableReportMrpcsInCircleFlow",
            "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow",
            "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"
        }
        for _, flag in ipairs(enableFlags) do
            if _G[flag] then _G[flag] = retFalse end
        end
    end)
end

local function InitializeSwiftHawkBypass()
    pcall(function()
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
end

local function InitializeCoronaLabBypass()
    pcall(function()
        if _G.CoronaLab then
            _G.CoronaLab.ReportData = nop
            _G.CoronaLab.SendData = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry = nop
        end
        local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local corona = SubsystemMgr:Get("CoronaLabSubsystem")
            if corona then
                corona.ReportData = nop
                corona.SendToServer = nop
                corona.CollectTelemetry = nop
                corona.StopCollection = nop
            end
        end
    end)
end

local function InitializeHeartbeatBypass()
    pcall(function()
        local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat"}
        for _, func in ipairs(heartbeatFuncs) do
            if _G[func] then _G[func] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
                _G.GameplayCallbacks[func] = nop
            end
        end
        local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local heartbeatSub = SubsystemMgr:Get("HeartbeatSubsystem")
            if heartbeatSub then
                if heartbeatSub.timer then heartbeatSub:RemoveGameTimer(heartbeatSub.timer) end
                heartbeatSub.SendHeartbeat = nop
                heartbeatSub.StartHeartbeat = nop
            end
        end
    end)
end

local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
                ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
                ["ReportPlayerBehavior"] = 1, ["ReportTeammatHurt"] = 1, ["ReportPlayerMoveRoute"] = 1,
                ["ReportPlayerPosition"] = 1, ["report_parachute_data"] = 1,
                ["on_tss_sdk_anti_data"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
                ["ReportCircleFlow"] = 1, ["report_players_ping"] = 1, ["report_player_ip"] = 1,
                ["report_net_saturate"] = 1, ["report_speed_hack"] = 1, ["report_wall_hack"] = 1,
                ["report_aim_bot"] = 1, ["report_esp_usage"] = 1, ["report_modded_files"] = 1,
                ["detect_cheat"] = 1, ["ban_player"] = 1, ["client_anti_cheat_report"] = 1,
                ["ReportPlayerKillFlow"] = 1, ["ClientSecPlayerKillFlow"] = 1,
                ["ClientSecMrpcsFlow"] = 1, ["MrpcsData"] = 1,
                ["RPC_ClientCoronaLab"] = 1, ["CoronaLabReport"] = 1, ["CoronaLabData"] = 1,
                ["PlayerSecurityInfo"] = 1, ["ReportSecurityInfo"] = 1, ["SendSecurityData"] = 1,
                ["ClientCircleFlow"] = 1,
                ["RPC_Server_ReportSimulateCharacterLocation"] = 1,
                ["RPC_Client_ShootVertifyRes"] = 1, ["BulletHitInfoUploadData"] = 1,
                ["tss_sdk_report"] = 1, ["Heartbeat"] = 1, ["ClientHeartbeat"] = 1, ["ServerHeartbeat"] = 1,
                ["SwiftHawk"] = 1, ["ClientSwiftHawk"] = 1, ["ClientSwiftHawkWithParams"] = 1,
                ["SwiftHawkReport"] = 1, ["SwiftHawkData"] = 1,
                ["AntiCheatReport"] = 1, ["CheatDetection"] = 1, ["ViolationReport"] = 1,
                ["SecurityViolation"] = 1, ["IntegrityCheck"] = 1, ["SignatureVerify"] = 1
            }
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return nil end
                return originalSend(packetName, ...)
            end
        end
    end)
end

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            local methods = {
                "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
                "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord",
                "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData",
                "ValidateSecurityData", "StaticShowSecurityAlertInDev"
            }
            for _, m in ipairs(methods) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.GetCurWeaponSkinID = retZero
        end
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if pc and isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
        _G.BlackList = {}
    end)
end

local function InitializeBanBypass()
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
    end)
end

local function InitializeExtendedBypass()
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
                "SendTssSdkAntiDataToLobby", "SendDSErrorLogToLobby", "SendDSHawkEyePatrolLogToLobby",
                "SendSecTLog", "SendDataMiningTLog", "SendActivityTLog", "SendClientMemUsage", "SendClientFPS",
                "OnClientCrashReport", "OnNetworkLossDetected", "ReportMatchRoomData", "ReportPlayersPing",
                "SendClientStats", "SendServerAvgTickDelta", "ReportHitFlow", "OnPlayerActorChannelError", "OnPlayerRPCValidateFailed"
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
    end)
end

local function InitializeTlogBlocker()
    pcall(function()
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
    end)
end

local function InitializeClientReportBlocker()
    pcall(function()
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
    end)
end

local function InitializeGameplayCallbacks()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        local GC = _G.GameplayCallbacks
        GC.OnPlayerNetConnectionClosed = nop
        GC.OnPlayerActorChannelError = nop
        GC.OnPlayerRPCValidateFailed = nop
        GC.OnPlayerSpectateException = nop
        GC.OnShutdownAfterError = nop
    end)
end

local function InitializeFinalProtection()
    pcall(function()
        local globalFlags = {
            "ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY",
            "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"
        }
        for _, flag in ipairs(globalFlags) do
            if _G[flag] then _G[flag] = false end
        end
    end)
end

local function huntAndKillAll()
    pcall(function()
        local subMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subMgr and subMgr.Get then
            local subNames = {
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientReportPlayerSubsystem",
                "DSReportPlayerSubsystem", "ClientGlueHiaSystem", "ClientDataStatistcsSubsystem",
                "ICTLogSubsystem", "DSFightTLogSubsystem", "DSSecurityTLogSubsystem", "AFKReportorSubsystem",
                "BehaviorScoreSubsystem"
            }
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
        local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            local methods = {"ControlMHActive","Tick","OnTick","MHActiveLogic","TriggerAvatarCheck","StartAvatarCheck","ReportItemID","ReceiveAnyDamage","OnWeaponHitRecord","ShowSecurityAlert","ServerReportAvatar","ClientReportNetAvatar","SendHisarData","ValidateSecurityData"}
            for _, m in ipairs(methods) do if Higgs[m] then Higgs[m] = nop end end
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.GetCurWeaponSkinID = retZero
        end
    end)
end

local BLACKLIST_HOSTS = {
    "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","feedback.wh","crash2",
    "privacy.qq","privacy.tencent","oth.eve","mdt.qq","act.tencentyun","analytics","report.qq",
    "anticheatexpert","crashsight","wetest","log.tav","sngd","tracer","intlsdk","igamecj",
    "cdn.club","gpubgm","graph.facebook","firebase","googleapis","facebook","gvoice",
    "igame.gcloudcs","bugly","beacon","helpshift","tdm","apm","safeguard","weiyun","qzone",
    "tencent-cloud","myapp","idqqimg","gtimg","qqmail","tcdn","cloudctrl","sdkostrace",
    "103.134.189.146","mbgame","csoversea","igame","pubgmobile","down.anticheatexpert.com",
    "opensdk.tencent","exp.helpshift","loginsdkapi.zingplay"
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

local function InitializeNetworkFilter()
    pcall(function()
        if _G.HttpRequest then
            local orig = _G.HttpRequest
            _G.HttpRequest = function(url, ...) if isBlacklisted(url) then return nil end return orig(url, ...) end
        end
        if _G.FHttpModule and _G.FHttpModule.CreateRequest then
            local orig = _G.FHttpModule.CreateRequest
            _G.FHttpModule.CreateRequest = function(...) local url = select(1,...); if isBlacklisted(url) then return nil end return orig(...) end
        end
        local netMods = {
            "client.slua.logic.network.logic_network", "client.slua.logic.download.report.puffer_tlog",
            "client.slua.data.BasicData.BasicDataClientReport", "GameLua.GameCore.Module.Network.NetworkManager",
            "client.network.Protocol.ClientTlogHandler", "client.network.Protocol.BattleReportHandler",
            "client.network.Protocol.ClientErrorReportHandler"
        }
        for _, mp in ipairs(netMods) do
            local mod = package.loaded[mp]
            if mod then
                for k, v in pairs(mod) do
                    if type(v) == "function" and (k:find("Http") or k:find("Request") or k:find("Send") or k:find("Upload") or k:find("Post") or k:find("Get") or k:find("Report")) then
                        local origf = v
                        mod[k] = function(...)
                            local args = {...}
                            for _, arg in ipairs(args) do if type(arg)=="string" and isBlacklisted(arg) then return nil end end
                            return pcall(origf, ...)
                        end
                    end
                end
            end
        end
    end)
end

local function InitializeFileBlocker()
    pcall(function()
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
    end)
end

local function InitializeAllBypasses()
    pcall(function()
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeSkinBypass()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReportFlowBlocker()
        InitializeSwiftHawkBypass()
        InitializeCoronaLabBypass()
        InitializeHeartbeatBypass()
        InitializeNetworkPacketBlock()
        InitializeHiggsBosonBypass()
        InitializeBanBypass()
        InitializeExtendedBypass()
        InitializeTlogBlocker()
        InitializeClientReportBlocker()
        InitializeGameplayCallbacks()
        InitializeFinalProtection()
        InitializeNetworkFilter()
        InitializeFileBlocker()
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 2: FEATURE STATE VARIABLES
-- ══════════════════════════════════════════════════════════════

_G.LexusConfig = _G.LexusConfig or {
    EnableFOV = false,
    FOVValue = 90,
    EnableWeaponMod = false,
    EnableMagic = false,
    MagicLevel = 70,
    EnableAutoAim = false,
    AutoAimBone = "Head",
    EnableAiming = false,
    AimingLevel = "LOW",
    EnableNoRecoil = false,
    EnableNoShake = false,
    RecoilLevel = "LESS",
    DisableGrass = false,
    BlackSky = false,
    RemoveFog = false,
    RemoveTree = false,
    RemoveWater = false,
    RemoveSmoke = false,
    WhiteBody = false,
    AutoHead = false,
    EnableESP = false,
    ESPName = true,
    ESPWeapon = true,
    ESPDistance = true,
    ESPAI = true,
    ESPTeamId = true,
    ESPBox = false,
    ESPDot = false,
    ESPHPBar = false,
    ESPMiniMap = false,
    ESPSkeleton = false,
    ESPDistanceMarker = false,
    Wallhack = false,
    WallhackBrightness = 25,
    EnableSpeedBoost = false,
    SpeedPercent = 250,
    EnableAntiGravity = false,
    GravityScale = 1.0,
    EnableWallClimb = false,
    EnableCharRotation = false,
    RotationSpeed = 999,
    CharScale = 1.0,
    EnemyScale = 1.0,
    SuperBullet = 1,
    SuperFireRate = false,
    SuperFireRateValue = 0.008,
    InfiniteAmmo = false,
    QuickScope = false,
    FastSwitch = false,
    GunWallbang = false,
    CrossDeviation = false,
    HitEffect = 3.5,
    WeaponLuffy = false,
    WeaponSoul = false,
    WeaponRainbow = false,
    EnableRain = false,
    EnableSnow = false,
    FlashSpeed = false,
    HighJump = false,
    FastCar = false,
    GodMode = false,
    EnableCHAMS = false,
    CHAMSColor = {R=0, G=255, B=0, A=255},
    WeaponMod = {
        [101001] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101002] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101003] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101004] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101005] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101006] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101007] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101008] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101009] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false},
        [101010] = {FireSpeed = false, InstanHit = false, FastSwitch = false, FastScope = false}
    }
}

_G.LexusState = _G.LexusState or {}

local GameplayData = safe_require("GameLua.GameCore.Data.GameplayData")

-- ══════════════════════════════════════════════════════════════
-- SECTION 3: IPAD VIEW / FOV
-- ══════════════════════════════════════════════════════════════

function _G.SetFOV(value)
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local camera = player.ThirdPersonCameraComponent
    if not camera then return end
    camera:SetFieldOfView(value)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 4: WEAPON MODS
-- ══════════════════════════════════════════════════════════════

_G.otherWeapon = function()
    if not _G.LexusConfig.EnableWeaponMod then return end
    local ok, err = pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not slua.isValid(shootComp) then return end
        local wid = shootComp.WeaponID
        if type(wid) ~= "number" then return end
        local cfg = _G.LexusConfig.WeaponMod[wid]
        if not cfg then return end
        if cfg.FireSpeed then shootComp.ShootInterval = 0.07 end
        if cfg.InstanHit then
            local bulletSpeeds = {
                [101001] = 120000, [101002] = 110000, [101003] = 130000,
                [101004] = 130000, [101005] = 130000, [101006] = 130000,
                [101007] = 130000, [101008] = 130000, [101009] = 130000, [101010] = 130000
            }
            shootComp.BulletFireSpeed = bulletSpeeds[wid] or 130000
        end
        if cfg.FastSwitch then
            shootComp.SwitchFromIdleToBackpackTime = 0
            shootComp.SwitchFromBackpackToIdleTime = 0
        end
        if cfg.FastScope then shootComp.WeaponAimInTime = 7 end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 5: MAGIC BULLET (HITBOX EXPAND)
-- ══════════════════════════════════════════════════════════════

_G._MBones = {}

_G.ResetHitbox = function()
    pcall(function()
        local allChars = Game:GetAllPlayerPawns()
        if allChars then
            for _, enemy in pairs(allChars) do
                if slua.isValid(enemy) and slua.isValid(enemy.Mesh) then
                    enemy.Mesh:RecreatePhysicsState()
                    enemy.Mesh:UpdateBounds()
                end
            end
        end
        _G._MBones = {}
    end)
end

_G.Magic = function()
    if not _G.LexusConfig.EnableMagic then
        if _G._MBones and next(_G._MBones) ~= nil then _G.ResetHitbox() end
        return
    end
    pcall(function()
        local char = GameplayData.GetPlayerCharacter()
        if not slua.isValid(char) then return end
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        _G._MBones = _G._MBones or {}
        local currentMagicScale = _G.LexusConfig.MagicLevel or 70
        for _, enemy in pairs(allChars) do
            pcall(function()
                if not slua.isValid(enemy) or enemy == char or enemy.TeamID == char.TeamID then return end
                local mesh = enemy.Mesh
                if not slua.isValid(mesh) then return end
                local physAsset = mesh.PhysicsAssetOverride
                if not slua.isValid(physAsset) and slua.isValid(mesh.SkeletalMesh) then
                    physAsset = mesh.SkeletalMesh.PhysicsAsset
                end
                if not slua.isValid(physAsset) then return end
                local assetName = tostring((physAsset.GetName and physAsset:GetName()) or physAsset)
                if _G._MBones[assetName] then return end
                local setups = physAsset.SkeletalBodySetups
                if not setups then return end
                local scaleMap = { head = currentMagicScale }
                for i = 0, 60 do
                    pcall(function()
                        local bs = (type(setups.Get) == "function" and setups:Get(i)) or setups[i]
                        if not bs or not slua.isValid(bs) then return end
                        local boneName = tostring(bs.BoneName):lower()
                        local scale = nil
                        for pattern, value in pairs(scaleMap) do
                            if string.find(boneName, pattern:lower()) then scale = value; break end
                        end
                        if not scale then return end
                        local ag = bs.AggGeom
                        if not ag then return end
                        pcall(function()
                            local box = ag.BoxElems
                            if box then
                                local elem = (type(box.Get) == "function" and box:Get(0)) or box[1]
                                if elem then elem.X, elem.Y, elem.Z = scale, scale, scale end
                            end
                        end)
                        pcall(function()
                            local sphyl = ag.SphylElems
                            if sphyl then
                                local elem = (type(sphyl.Get) == "function" and sphyl:Get(0)) or sphyl[1]
                                if elem then if elem.Radius then elem.Radius = scale end; if elem.Length then elem.Length = scale end end
                            end
                        end)
                        pcall(function()
                            local sphere = ag.SphereElems
                            if sphere then
                                local elem = (type(sphere.Get) == "function" and sphere:Get(0)) or sphere[1]
                                if elem and elem.Radius then elem.Radius = scale end
                            end
                        end)
                    end)
                end
                pcall(function()
                    mesh:RecreatePhysicsState()
                    mesh:WakeAllRigidBodies()
                    mesh:UpdateBounds()
                end)
                _G._MBones[assetName] = true
            end)
        end
    end)
end

function M.GetHitBodyType(ImpactResult, InImpactVec)
    return EAvatarDamagePosition.BigHead
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 6: AUTO AIM
-- ══════════════════════════════════════════════════════════════

_G.ApplyAutoAim = function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local autoComp = player.AutoAimComp
    if not autoComp then return end
    if _G.LexusConfig.EnableAutoAim then
        local targetBone = _G.LexusConfig.AutoAimBone or "Head"
        autoComp.Bones = { targetBone, targetBone, targetBone }
    else
        autoComp.Bones = nil
    end
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 7: AIMBOT (AUTO AIMING CONFIG)
-- ══════════════════════════════════════════════════════════════

_G.ApplyAimingConfig = function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local weaponManager = player.WeaponManagerComponent
    if not slua.isValid(weaponManager) then return end
    local currentWeapon = weaponManager.CurrentWeaponReplicated
    if not slua.isValid(currentWeapon) then return end
    local shootComp = currentWeapon.ShootWeaponEntityComp
    if not shootComp then return end
    local aa = shootComp.AutoAimingConfig
    if not aa then return end
    if not _G.LexusConfig.EnableAiming then
        local d = { S = 3.5, SR = 1, RR = 1, RRS = 1, SRS = 1, CSR = 1, CR = 0.5, PR = 0.10, DR = 1, GDF = 0 }
        aa.OuterRange.Speed = d.S; aa.InnerRange.Speed = d.S
        aa.OuterRange.SpeedRate = d.SR; aa.InnerRange.SpeedRate = d.SR
        aa.OuterRange.RangeRate = d.RR; aa.InnerRange.RangeRate = d.RR
        aa.OuterRange.RangeRateSight = d.RRS; aa.InnerRange.RangeRateSight = d.RRS
        aa.OuterRange.SpeedRateSight = d.SRS; aa.InnerRange.SpeedRateSight = d.SRS
        aa.OuterRange.CenterSpeedRate = d.CSR; aa.InnerRange.CenterSpeedRate = d.CSR
        aa.OuterRange.CrouchRate = d.CR; aa.InnerRange.CrouchRate = d.CR
        aa.OuterRange.ProneRate = d.PR; aa.InnerRange.ProneRate = d.PR
        aa.OuterRange.DyingRate = d.DR; aa.InnerRange.DyingRate = d.DR
        shootComp.GameDeviationFactor = d.GDF
        return
    end
    local level = _G.LexusConfig.AimingLevel or "LOW"
    local configs = {
        LOW     = { S = 5,  SR = 5,  RR = 1,  RRS = 1,  SRS = 5,  CSR = 3,  CR = 1,   PR = 1,   DR = 0, GDF = 0 },
        MEDIUM  = { S = 7,  SR = 7,  RR = 2,  RRS = 2,  SRS = 7,  CSR = 5,  CR = 2,   PR = 2,   DR = 0, GDF = 0 },
        HARD    = { S = 10, SR = 10, RR = 10, RRS = 10, SRS = 10, CSR = 7,  CR = 2,   PR = 2,   DR = 0, GDF = 0 },
        EXTREME = { S = 50, SR = 20, RR = 20, RRS = 20, SRS = 20, CSR = 15, CR = 5,   PR = 5,   DR = 0, GDF = 0 }
    }
    local c = configs[level] or configs.LOW
    aa.OuterRange.Speed = c.S;              aa.InnerRange.Speed = c.S
    aa.OuterRange.SpeedRate = c.SR;         aa.InnerRange.SpeedRate = c.SR
    aa.OuterRange.RangeRate = c.RR;         aa.InnerRange.RangeRate = c.RR
    aa.OuterRange.RangeRateSight = c.RRS;   aa.InnerRange.RangeRateSight = c.RRS
    aa.OuterRange.SpeedRateSight = c.SRS;   aa.InnerRange.SpeedRateSight = c.SRS
    aa.OuterRange.CenterSpeedRate = c.CSR;  aa.InnerRange.CenterSpeedRate = c.CSR
    aa.OuterRange.CrouchRate = c.CR;        aa.InnerRange.CrouchRate = c.CR
    aa.OuterRange.ProneRate = c.PR;         aa.InnerRange.ProneRate = c.PR
    aa.OuterRange.DyingRate = c.DR;         aa.InnerRange.DyingRate = c.DR
    shootComp.GameDeviationFactor = c.GDF
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 8: NO RECOIL / NO SHAKE
-- ══════════════════════════════════════════════════════════════

_G.ApplyNoRecoil = function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local weaponManager = player.WeaponManagerComponent
    if not slua.isValid(weaponManager) then return end
    local currentWeapon = weaponManager.CurrentWeaponReplicated
    if not slua.isValid(currentWeapon) then return end
    local shootComp = currentWeapon.ShootWeaponEntityComp
    if not shootComp then return end
    local level = (_G.LexusConfig.EnableNoRecoil and _G.LexusConfig.RecoilLevel) or "DEFAULT"
    local r = shootComp.RecoilInfo
    if level == "DEFAULT" then
        shootComp.RecoilKickADS = 0.2
        shootComp.AccessoriesHRecoilFactor = 0.5
        shootComp.AccessoriesRecoveryFactor = 0.6
        shootComp.AccessoriesVRecoilFactor = 0.5
        if r then
            r.VerticalRecoilMin = 0; r.VerticalRecoilMax = 7; r.VerticalRecoveryMax = 5
            r.RecoilValueClimb = 0.75; r.RecoilValueFail = 2.2; r.VerticalRecoveryModifier = 0.5
            r.RecovertySpeedVertical = 9; r.VerticalRecoveryClamp = 10
            r.LeftMax = -0.8; r.RightMax = 0.8; r.HorizontalTendency = 0.1
            r.RecoilHorizontalMinScalar = 0.1; r.RecoilSpeedHorizontal = 11; r.RecoilSpeedVertical = 11
        end
    elseif level == "LESS" then
        shootComp.RecoilKickADS = 0
        shootComp.AccessoriesHRecoilFactor = 0.2
        shootComp.AccessoriesRecoveryFactor = 0.2
        shootComp.AccessoriesVRecoilFactor = 0.2
        if r then
            r.VerticalRecoilMin = 0; r.VerticalRecoilMax = 2; r.VerticalRecoveryMax = 2
            r.RecoilValueClimb = 0.2; r.RecoilValueFail = 2; r.VerticalRecoveryModifier = 0.2
            r.RecovertySpeedVertical = 2; r.VerticalRecoveryClamp = 2
            r.LeftMax = -0.2; r.RightMax = 0.2; r.HorizontalTendency = 0.1
            r.RecoilHorizontalMinScalar = 0.1; r.RecoilSpeedHorizontal = 2; r.RecoilSpeedVertical = 2
        end
    elseif level == "NO" then
        shootComp.RecoilKickADS = 0
        shootComp.AccessoriesHRecoilFactor = 0
        shootComp.AccessoriesRecoveryFactor = 0
        shootComp.AccessoriesVRecoilFactor = 0
        if r then
            r.VerticalRecoilMin = 0; r.VerticalRecoilMax = 0; r.VerticalRecoveryMax = 0
            r.RecoilValueClimb = 0; r.RecoilValueFail = 0; r.VerticalRecoveryModifier = 0
            r.RecovertySpeedVertical = 0; r.VerticalRecoveryClamp = 0
            r.LeftMax = 0; r.RightMax = 0; r.HorizontalTendency = 0
            r.RecoilHorizontalMinScalar = 0; r.RecoilSpeedHorizontal = 0; r.RecoilSpeedVertical = 0
        end
    end
    if _G.LexusConfig.EnableNoShake then shootComp.AnimationKick = 0 end
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 9: NO GRASS
-- ══════════════════════════════════════════════════════════════

_G.DisableGrass = function()
    local logic_setting_graphics = safe_require("client.slua.logic.setting.logic_setting_graphics")
    local gi = logic_setting_graphics and logic_setting_graphics.GetGameInstance and logic_setting_graphics.GetGameInstance()
    if not gi then return end
    if _G.LexusConfig.DisableGrass then
        gi:ExecuteCMD("grass.heightScale", "0")
    else
        gi:ExecuteCMD("grass.heightScale", "1")
    end
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 10: BLACK SKY
-- ══════════════════════════════════════════════════════════════

_G.BlackSky = function()
    local logic_setting_graphics = safe_require("client.slua.logic.setting.logic_setting_graphics")
    local gi = logic_setting_graphics and logic_setting_graphics.GetGameInstance and logic_setting_graphics.GetGameInstance()
    if not gi then return end
    if _G.LexusConfig.BlackSky then
        gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
    else
        gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0")
    end
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 11: ENEMY TARGETS
-- ══════════════════════════════════════════════════════════════

_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end
    local uPlayerController = player:GetPlayerControllerSafety()
    if not slua.isValid(uPlayerController) then return result end
    local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
    if not ASTExtraPlayerCharacter then return result end
    local Actors = Game:GetActorsByClass(ASTExtraPlayerCharacter)
    if not Actors then return result end
    local count = Actors:Num() or 0
    local myTeam = player:GetTeamID()
    for i = 0, count - 1 do
        local actor = Actors:Get(i)
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 12: FPS 165 UNLOCK
-- ══════════════════════════════════════════════════════════════

local FPS_STRINGS = { "15", "20", "25", "30", "40", "60", "90", "120" }
local GSC_FPS = package.loaded["client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS"]
    or require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")

if GSC_FPS and GSC_FPS.__inner_impl then
    local impl = GSC_FPS.__inner_impl
    local origCtor = impl.ctor
    impl.ctor = function(self)
        if origCtor then origCtor(self) end
        self.FPSButtons = {}
        for i = 1, 8 do self.FPSButtons[i] = { false, false } end
    end
    impl.GetMaxFPSLevel = function() return 8, 8 end
    impl.CanChangeQualityAndFPSPreCheck = function() return true end
    impl.InitRealSupportFPS = function(self)
        local tbl = {}
        for i = 1, 8 do tbl[i] = { true, true } end
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, tbl, false) end
        return tbl
    end
    impl.SetFPSAndQualityEnable = function(self, enable)
        if self.UIRoot and self.UIRoot.Image_Mask then
            self:SetWidgetVisible(self.UIRoot.Image_Mask, false)
        end
    end
    impl.Change120FPSConfirm = function(self, cb) if cb then cb() end end
    impl.ClickExpandFPSConfirm = function(self, cb) if cb then cb() end end
end

local GSC_FPSFT = package.loaded["client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT"]
    or require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")

if GSC_FPSFT and GSC_FPSFT.__inner_impl then
    local ft = GSC_FPSFT.__inner_impl
    local MN, MX, ST = 90, 165, 5
    local function clamp(v, l, h) if v < l then return l elseif v > h then return h else return v end end
    ft.ShowOrHide = function(s) s:SelfHitTestInvisible(); if s.InitFPSFTSwitch then s:InitFPSFTSwitch() end end
    ft.InitFPSFTSwitch = function(s)
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if not GraphicSettingDB then return end
        local on = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
        if s.UIRoot.Setting_Switch then s.UIRoot.Setting_Switch:SetSwitcherEnable2(on, true) end
        if s.UIRoot.CanvasPanel_8 then s:SetWidgetVisible(s.UIRoot.CanvasPanel_8, on) end
        if s.UIRoot.WidgetSwitcher_0 then s.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
        if s.InitFPSFTValue165 then s:InitFPSFTValue165() end
    end
    ft.InitFPSFTValue165 = function(s)
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if not GraphicSettingDB then return end
        local r = s.UIRoot
        local on = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
        local v = (on and GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165)
        r.Slider_screen3:SetLocked(not on)
        local n = (v - MN) / (MX - MN)
        r.Slider_screen3:SetValue(n)
    end
    ft.OnFPSFTValueChange3 = function(s, v)
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if not GraphicSettingDB then return end
        v = clamp(v, MN, MX)
        GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, v)
        s:InitFPSFTValue165()
        if s:GetParentUI() then s:GetParentUI():SetDirty(true) end
        local gi = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
        if gi then gi:ExecuteCMD("t.MaxFPS", tostring(v)); gi:ExecuteCMD("r.FrameRateLimit", tostring(v)) end
    end
    ft.OnFPSFTSliderValueChange3 = function(s, nv)
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if not GraphicSettingDB then return end
        if not GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) then return end
        s:OnFPSFTValueChange3(clamp(math.floor((MN + nv*(MX-MN))/ST+0.5)*ST, MN, MX))
    end
    ft.OnFPSFTAdd3 = function(s)
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if not GraphicSettingDB then return end
        local c = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 90
        s:OnFPSFTValueChange3(math.min(MX, c + ST))
    end
    ft.OnFPSFTMinus3 = function(s)
        local GraphicSettingDB = safe_require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if not GraphicSettingDB then return end
        local c = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 90
        s:OnFPSFTValueChange3(math.max(MN, c - ST))
    end
    ft.OnFPSFTAdd = ft.OnFPSFTAdd3; ft.OnFPSFTMinus = ft.OnFPSFTMinus3
    ft.OnFPSFTSliderValueChange = ft.OnFPSFTSliderValueChange3
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 13: WEAPON OUTLINE (RAINBOW)
-- ══════════════════════════════════════════════════════════════

_G.RainbowHue = 0

local function HueToRGB(hue, saturation, value)
    if not saturation then saturation = 1 end
    if not value then value = 1 end
    local index = math.floor(hue * 6)
    local fraction = hue * 6 - index
    local p = value * (1 - saturation)
    local q = value * (1 - fraction * saturation)
    local t = value * (1 - (1 - fraction) * saturation)
    index = index % 6
    if index == 0 then return value, t, p
    elseif index == 1 then return q, value, p
    elseif index == 2 then return p, value, t
    elseif index == 3 then return p, q, value
    elseif index == 4 then return t, p, value
    else return value, p, q end
end

local function GetRainbowColor()
    _G.RainbowHue = (_G.RainbowHue or 0) + 0.05
    if _G.RainbowHue >= 1 then _G.RainbowHue = 0 end
    local r, g, b = HueToRGB(_G.RainbowHue, 1, 1)
    return FLinearColor(r, g, b, 1)
end

local function ApplyOutlineToWeapon(weapon, color)
    if not slua.isValid(weapon) then return false end
    local ok, meshComponent = pcall(function() return import("/Script/Engine.MeshComponent") end)
    if not ok then return false end
    local ok2, components = pcall(function() return weapon:GetComponentsByClass(meshComponent) end)
    if not ok2 then return false end
    local applied = false
    for _, component in pairs(components) do
        if component and slua.isValid(component) then
            if component.SetDrawIdeaOutline then
                pcall(function() component:SetDrawIdeaOutline(true) end)
                if color and component.OverrideIdeaOutlineColor then
                    pcall(function() component:OverrideIdeaOutlineColor(true, color) end)
                end
                if component.OverrideIdeaOutlineThickness then
                    pcall(function() component:OverrideIdeaOutlineThickness(true, 3) end)
                end
                applied = true
            elseif component.SetRenderCustomDepth then
                pcall(function() component:SetRenderCustomDepth(true) end)
                applied = true
            end
        end
    end
    return applied
end

local function ClearOutlineFromWeapon(weapon)
    if not slua.isValid(weapon) then return end
    local ok, meshComponent = pcall(function() return import("/Script/Engine.MeshComponent") end)
    if not ok then return end
    local ok2, components = pcall(function() return weapon:GetComponentsByClass(meshComponent) end)
    if not ok2 then return end
    for _, component in pairs(components) do
        if component and slua.isValid(component) then
            if component.SetDrawIdeaOutline then
                pcall(function() component:SetDrawIdeaOutline(false) end)
            elseif component.SetRenderCustomDepth then
                pcall(function() component:SetRenderCustomDepth(false) end)
            end
        end
    end
end

_G.ClearAllWeaponOutlines = function()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not pc or not isValid(pc) then return end
    local ch = pc:GetCurPawn()
    if not isValid(ch) then return end
    local weaponManager = ch:GetWeaponManager()
    if not isValid(weaponManager) then return end
    for slot = 0, 10 do
        local weapon = nil
        if weaponManager.GetInventoryWeaponByPropSlot then
            weapon = weaponManager:GetInventoryWeaponByPropSlot(slot)
        end
        if isValid(weapon) then ClearOutlineFromWeapon(weapon) end
    end
end

_G.UpdateAllWeaponOutlines = function()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not pc or not isValid(pc) then return end
    local ch = pc:GetCurPawn()
    if not isValid(ch) then return end
    local weaponManager = ch:GetWeaponManager()
    if not isValid(weaponManager) then return end
    local color = GetRainbowColor()
    for slot = 0, 10 do
        local weapon = nil
        if weaponManager.GetInventoryWeaponByPropSlot then
            weapon = weaponManager:GetInventoryWeaponByPropSlot(slot)
        end
        if isValid(weapon) then ApplyOutlineToWeapon(weapon, color) end
    end
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 14: WEAPON ORBIT
-- ══════════════════════════════════════════════════════════════

_G.WeaponOrbitState = _G.WeaponOrbitState or {active = false}

-- ══════════════════════════════════════════════════════════════
-- SECTION 15: SKIN SYSTEM
-- ══════════════════════════════════════════════════════════════

_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.SkinAttachments = _G.SkinAttachments or {}
_G.KillData = _G.KillData or { kills = {} }

local BASE_PATH = "/storage/emulated/0/Android/data/com.pubg.imobile/files/"
local CONFIG_PATH = BASE_PATH .. "config.ini"

_G.get_skin_id = function(weaponID)
    if not weaponID or weaponID == 0 then return nil end
    local mapped = _G.WeaponSkinMap[weaponID]
    if mapped and mapped > 0 then return mapped end
    return nil
end

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

_G.ApplyWeaponSkins = function(pawn)
    if not isValid(pawn) then return end
    _G.InjectWeaponLogicHooks(pawn)
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
                local val = tonumber(v)
                if val then
                    if k == "M416" then _G.WeaponSkinMap[101004] = val
                    elseif k == "AKM" then _G.WeaponSkinMap[101001] = val
                    elseif k == "SCAR" then _G.WeaponSkinMap[101003] = val
                    elseif k == "UMP" then _G.WeaponSkinMap[102002] = val
                    elseif k == "M762" then _G.WeaponSkinMap[101008] = val
                    elseif k == "AUG" then _G.WeaponSkinMap[101006] = val
                    elseif k == "M24" then _G.WeaponSkinMap[103002] = val
                    elseif k == "AWM" then _G.WeaponSkinMap[103003] = val
                    elseif k == "Kar98" then _G.WeaponSkinMap[103001] = val
                    elseif k == "M16A4" then _G.WeaponSkinMap[101002] = val
                    elseif k == "GROZA" then _G.WeaponSkinMap[101005] = val
                    elseif k == "VSS" then _G.WeaponSkinMap[103005] = val
                    elseif k == "Mini14" then _G.WeaponSkinMap[103006] = val
                    elseif k == "SKS" then _G.WeaponSkinMap[103004] = val
                    elseif k == "UZI" then _G.WeaponSkinMap[102001] = val
                    elseif k == "Vector" then _G.WeaponSkinMap[102003] = val
                    elseif k == "Thompson" then _G.WeaponSkinMap[102004] = val
                    elseif k == "MP5K" then _G.WeaponSkinMap[102007] = val
                    elseif k == "P90" then _G.WeaponSkinMap[102105] = val
                    elseif k == "S12K" then _G.WeaponSkinMap[104003] = val
                    elseif k == "DBS" then _G.WeaponSkinMap[104004] = val
                    elseif k == "M249" then _G.WeaponSkinMap[105001] = val
                    elseif k == "DP28" then _G.WeaponSkinMap[105002] = val
                    end
                end
            end
        end
    end)
end
_G.ReadLiveConfig = ReadLiveConfig

-- ══════════════════════════════════════════════════════════════
-- SECTION 16: EXECUTE CONSOLE COMMAND HELPER
-- ══════════════════════════════════════════════════════════════

local function ExecuteConsoleCommand(cmd, value)
    pcall(function()
        local logic_setting_graphics = safe_require("client.slua.logic.setting.logic_setting_graphics")
        local gi = logic_setting_graphics and logic_setting_graphics.GetGameInstance and logic_setting_graphics.GetGameInstance()
        if not gi then gi = slua_GameFrontendHUD and slua_GameFrontendHUD:GetGameInstance() end
        if gi then gi:ExecuteCMD(cmd, tostring(value)) end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 17: NO FOG / NO TREE / NO WATER / NO SMOKE
-- ══════════════════════════════════════════════════════════════

_G.SetFogRemoval = function(enabled)
    ExecuteConsoleCommand("r.Fog", enabled and "0" or "1")
    ExecuteConsoleCommand("r.VolumetricFog", enabled and "0" or "1")
end

_G.SetTreeRemoval = function(enabled)
    ExecuteConsoleCommand("foliage.TreeDensityScale", enabled and "0" or "1")
end

_G.SetWaterRemoval = function(enabled)
    ExecuteConsoleCommand("r.Water", enabled and "0" or "1")
end

_G.SetSmokeRemoval = function(enabled)
    ExecuteConsoleCommand("r.BloomQuality", enabled and "0" or "1")
    ExecuteConsoleCommand("r.TonemapperQuality", enabled and "0" or "1")
    ExecuteConsoleCommand("sg.PostProcessQuality", enabled and "0" or "3")
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 18: WHITE BODY
-- ══════════════════════════════════════════════════════════════

_G.ApplyWhiteBody = function()
    pcall(function()
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local myTeam = player.TeamID or 0
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= player and enemy.TeamID ~= myTeam then
                local mesh = enemy.Mesh
                if slua.isValid(mesh) then
                    if _G.LexusConfig.WhiteBody then
                        if not enemy._whiteMID then
                            enemy._whiteMID = mesh:CreateAndSetMaterialInstanceDynamic(0)
                        end
                        if enemy._whiteMID then
                            pcall(function()
                                local whiteColor = FLinearColor(10, 10, 10, 1)
                                local paramNames = {"Color","BaseColor","BodyColor","Para_Color","Tint","TintColor","MainColor","DiffuseColor"}
                                for _, pname in ipairs(paramNames) do
                                    pcall(function() enemy._whiteMID:SetVectorParameterValue(pname, whiteColor) end)
                                end
                            end)
                        end
                    else
                        enemy._whiteMID = nil
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 19: AUTO HEAD (AUTO HEADSHOT)
-- ══════════════════════════════════════════════════════════════

_G.InitializeAutoHeadHooks = function()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end
        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }
        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local orig_GHBT = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.LexusConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if orig_GHBT then return orig_GHBT(self, ImpactResult, InImpactVec) end
                end
                local orig_GHBTBHP = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.LexusConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if orig_GHBTBHP then return orig_GHBTBHP(self, InImpactVec) end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 20: FLASH SPEED
-- ══════════════════════════════════════════════════════════════

_G.ApplyFlashSpeed = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.FlashSpeed then
            shootComp.WeaponAimInTime = 25.0
        else
            shootComp.WeaponAimInTime = 0.3
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 21: SUPER BULLET / SUPER FIRE RATE / INFINITE AMMO
-- ══════════════════════════════════════════════════════════════

_G.ApplySuperBullet = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.SuperBullet > 1 then
            shootComp.BulletNumSingleShot = _G.LexusConfig.SuperBullet
        else
            shootComp.BulletNumSingleShot = 1
        end
    end)
end

_G.ApplySuperFireRate = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.SuperFireRate then
            shootComp.ShootInterval = _G.LexusConfig.SuperFireRateValue
        else
            shootComp.ShootInterval = 0.1
        end
    end)
end

_G.ApplyInfiniteAmmo = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        shootComp.bClipHasInfiniteBullets = _G.LexusConfig.InfiniteAmmo
        shootComp.bHasInfiniteBullets = _G.LexusConfig.InfiniteAmmo
    end)
end

_G.ApplyQuickScope = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.QuickScope then
            shootComp.WeaponAimInTime = 25.0
        else
            shootComp.WeaponAimInTime = 0.3
        end
    end)
end

_G.ApplyFastSwitch = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.FastSwitch then
            shootComp.SwitchFromBackpackToIdleTime = 0
            shootComp.SwitchFromIdleToBackpackTime = 0
        else
            shootComp.SwitchFromIdleToBackpackTime = 0.5
            shootComp.SwitchFromBackpackToIdleTime = 0.5
        end
    end)
end

_G.ApplyGunWallbang = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.GunWallbang then
            shootComp.WeaponBodyLength = 0
        else
            shootComp.WeaponBodyLength = 100
        end
    end)
end

_G.ApplyCrossDeviation = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.CrossDeviation then
            shootComp.GameDeviationFactor = 0
            shootComp.GameDeviationAccuracy = 0
            shootComp.ShotGunHorizontalSpread = 0
            shootComp.ShotGunVerticalSpread = 0
        end
    end)
end

_G.ApplyHitEffect = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local weaponManager = player.WeaponManagerComponent
        if not slua.isValid(weaponManager) then return end
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not shootComp then return end
        if _G.LexusConfig.HitEffect > 0 then
            shootComp.ExtraHitPerformScale = _G.LexusConfig.HitEffect
        else
            shootComp.ExtraHitPerformScale = 1.0
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 22: SPEED BOOST / ANTI GRAVITY / WALL CLIMB
-- ══════════════════════════════════════════════════════════════

_G.ApplySpeedBoost = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        if enabled then
            local rate = (_G.LexusConfig.SpeedPercent / 100.0) - 1.0
            if player.AttrModifyComp then
                _G._speedModifyId = player.AttrModifyComp:AddModifyItemAndCache("SpeedRate", 0, rate, true, player, false)
            end
        else
            if player.AttrModifyComp and _G._speedModifyId then
                pcall(function() player.AttrModifyComp:RemoveModifyItemFromCache(_G._speedModifyId) end)
                _G._speedModifyId = nil
            end
        end
    end)
end

_G.ApplyAntiGravity = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local movement = player.CharacterMovement or player.CharMoveComp
        if movement then
            if enabled then
                movement.GravityScale = _G.LexusConfig.GravityScale
            else
                movement.GravityScale = 1.0
            end
        end
    end)
end

_G.ApplyWallClimb = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local movement = player.CharacterMovement or player.CharMoveComp
        if movement then
            if enabled then
                movement.WalkableFloorAngle = 199.0
                movement.MaxStepHeight = 999.0
            else
                movement.WalkableFloorAngle = 45.0
                movement.MaxStepHeight = 45.0
            end
        end
    end)
end

_G.ApplyCharScale = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local s = _G.LexusConfig.CharScale
        player:SetActorScale3D(FVector(s, s, s))
    end)
end

_G.ApplyEnemyScale = function()
    pcall(function()
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local myTeam = player.TeamID or 0
        local s = _G.LexusConfig.EnemyScale
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= player and enemy.TeamID ~= myTeam then
                enemy:SetActorScale3D(FVector(s, s, s))
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 23: RAIN / SNOW EFFECTS
-- ══════════════════════════════════════════════════════════════

_G.SetRainEnabled = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local EScreenParticleEffectType = import("EScreenParticleEffectType")
        if EScreenParticleEffectType and player.SetRainyEffectEnable then
            if enabled then
                player:SetRainyEffectEnable(EScreenParticleEffectType.ESPET_Rainy, true, 500)
            else
                player:SetRainyEffectEnable(EScreenParticleEffectType.ESPET_Rainy, false, 0)
            end
        end
    end)
end

_G.SetSnowEnabled = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local EScreenParticleEffectType = import("EScreenParticleEffectType")
        if EScreenParticleEffectType and player.SetRainyEffectEnable then
            if enabled then
                player:SetRainyEffectEnable(EScreenParticleEffectType.ESPET_Snowy, true, 500)
            else
                player:SetRainyEffectEnable(EScreenParticleEffectType.ESPET_Snowy, false, 0)
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 24: FULL ESP SYSTEM (Name, HP Bar, Box, Dot, Distance, Mini Map)
-- ══════════════════════════════════════════════════════════════

_G.AK_Active_HP_Cache = _G.AK_Active_HP_Cache or {}
_G.AK_Active_Marks_Cache = _G.AK_Active_Marks_Cache or {}

local function IsCharacterAlive(character)
    if not slua.isValid(character) then return false end
    if character.IsAlive then return character:IsAlive() end
    if character.GetHealth then return (character:GetHealth() or 0) > 0 end
    return true
end

local function GetWeaponName(character)
    if not _G.LexusConfig.ESPWeapon then return nil end
    local weaponManager = character.GetWeaponManager and character:GetWeaponManager()
    if not slua.isValid(weaponManager) then return nil end
    local currentSlot = weaponManager.GetCurrentUsingPropSlot and weaponManager:GetCurrentUsingPropSlot()
    local currentWeapon = currentSlot and weaponManager.GetInventoryWeaponByPropSlot and weaponManager:GetInventoryWeaponByPropSlot(currentSlot)
    if not slua.isValid(currentWeapon) then return nil end
    local weaponName = currentWeapon.WeaponName or ""
    if weaponName ~= "" then return weaponName:match("^([A-Za-z0-9_%-]+)") or weaponName end
    return nil
end

local function getZOffset(distMeters)
    local step = math.floor(distMeters / 25) * 25
    local t = math.max(0, math.min(1, step / 350))
    return 125 + 450 * t
end

local function getNameFontSize(distMeters, maxDist, minSize, maxSize)
    if distMeters >= maxDist then return minSize end
    local t = (distMeters / maxDist) * (distMeters / maxDist)
    return maxSize - (maxSize - minSize) * t
end

local function GetPoseStateOffset(character)
    local poseState = character.PoseState or 0
    if poseState == 1 then return -30, 50
    elseif poseState == 2 then return -60, 20
    else return 0, 80 end
end

_G.CreateHPBar = function(enemy)
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            enemy.NativeHPBarMark = InGameMarkTools.ClientAddMapMark(1006, FVector(0,0,0), 0, "", 4, enemy)
            _G.AK_Active_HP_Cache[tostring(enemy)] = { actor = enemy, hpMark = enemy.NativeHPBarMark }
        end
    end)
end

_G.RemoveHPBar = function(enemy)
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools then
            if InGameMarkTools.ClientRemoveMapMark and enemy.NativeHPBarMark then
                InGameMarkTools.ClientRemoveMapMark(enemy.NativeHPBarMark)
            elseif InGameMarkTools.HideMapMark and enemy.NativeHPBarMark then
                InGameMarkTools.HideMapMark(enemy.NativeHPBarMark)
            end
        end
        enemy.NativeHPBarMark = nil
        _G.AK_Active_HP_Cache[tostring(enemy)] = nil
    end)
end

_G.CreateDistanceMarker = function(enemy)
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            enemy.NativeDistMark = InGameMarkTools.ClientAddMapMark(9999, FVector(0,0,0), 0, "", 4, enemy)
            _G.AK_Active_Marks_Cache[tostring(enemy)] = { actor = enemy, distMark = enemy.NativeDistMark }
        end
    end)
end

_G.RemoveDistanceMarker = function(enemy)
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools then
            if InGameMarkTools.ClientRemoveMapMark and enemy.NativeDistMark then
                InGameMarkTools.ClientRemoveMapMark(enemy.NativeDistMark)
            elseif InGameMarkTools.HideMapMark and enemy.NativeDistMark then
                InGameMarkTools.HideMapMark(enemy.NativeDistMark)
            end
        end
        enemy.NativeDistMark = nil
        _G.AK_Active_Marks_Cache[tostring(enemy)] = nil
    end)
end

_G.CleanupDeadMarks = function()
    for key, data in pairs(_G.AK_Active_HP_Cache) do
        local shouldRemove = false
        if not slua.isValid(data.actor) then shouldRemove = true
        else pcall(function()
            if data.actor.bHidden or (data.actor.Mesh and data.actor.Mesh.bHidden) then shouldRemove = true end
            if type(data.actor.IsDead) == "function" and data.actor:IsDead() then shouldRemove = true end
        end) end
        if shouldRemove then
            pcall(function()
                local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
                if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then InGameMarkTools.ClientRemoveMapMark(data.hpMark) end
            end)
            _G.AK_Active_HP_Cache[key] = nil
        end
    end
    for key, data in pairs(_G.AK_Active_Marks_Cache) do
        local shouldRemove = false
        if not slua.isValid(data.actor) then shouldRemove = true
        else pcall(function()
            if data.actor.bHidden or (data.actor.Mesh and data.actor.Mesh.bHidden) then shouldRemove = true end
            if type(data.actor.IsDead) == "function" and data.actor:IsDead() then shouldRemove = true end
        end) end
        if shouldRemove then
            pcall(function()
                local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
                if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then InGameMarkTools.ClientRemoveMapMark(data.distMark) end
            end)
            _G.AK_Active_Marks_Cache[key] = nil
        end
    end
end

_G.ESPTick = function()
    if not _G.LexusConfig.EnableESP then return end
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local hud = player:GetPlayerControllerSafety() and player:GetPlayerControllerSafety():GetHUD()
        if not slua.isValid(hud) then return end
        local myTeam = player.TeamID or 0
        local myPos = player:K2_GetActorLocation()
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        for _, character in pairs(allChars) do
            if slua.isValid(character) and character ~= player and IsCharacterAlive(character) then
                local targetTeam = character.TeamID or 0
                if myTeam ~= targetTeam then
                    local enemyPos = character:K2_GetActorLocation()
                    local dx = enemyPos.X - myPos.X
                    local dy = enemyPos.Y - myPos.Y
                    local dz = enemyPos.Z - myPos.Z
                    local distM = math.sqrt(dx*dx + dy*dy + dz*dz) / 100
                    if distM <= 600 then
                        local bodyZ, headZ = GetPoseStateOffset(character)
                        local baseZOffset = getZOffset(distM)
                        local textParts = {}
                        local textZ = baseZOffset
                        local lineH = 22
                        if _G.LexusConfig.ESPName then
                            local name = character.PlayerName or "Unknown"
                            local hp = character.Health or 0
                            local maxHp = character.HealthMax or 100
                            local hpStr = maxHp > 0 and string.format(" %d/%.0f", hp, maxHp) or ""
                            local teamStr = _G.LexusConfig.ESPTeamId and string.format("[%d] ", character.TeamID or 0) or ""
                            table.insert(textParts, teamStr .. name .. hpStr .. string.format(" %.0fm", distM))
                        end
                        if _G.LexusConfig.ESPWeapon then
                            local wn = GetWeaponName(character)
                            if wn then table.insert(textParts, wn) end
                        end
                        if _G.LexusConfig.ESPAI and character.TeamID and character.TeamID > 100 then
                            table.insert(textParts, "AI")
                        end
                        if #textParts > 0 then
                            hud:AddDebugText(table.concat(textParts, "\n"), character, 0.3, {X=0, Y=0, Z=textZ}, {X=0, Y=0, Z=textZ}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 0.6, true)
                        end
                        if _G.LexusConfig.ESPDot and distM <= 200 then
                            pcall(function()
                                local mesh = character.Mesh
                                if slua.isValid(mesh) and type(mesh.GetSocketLocation) == "function" then
                                    for _, bName in ipairs({"head", "neck_01", "pelvis"}) do
                                        local wLoc = mesh:GetSocketLocation(bName)
                                        if wLoc then
                                            local ox = wLoc.X - enemyPos.X
                                            local oy = wLoc.Y - enemyPos.Y
                                            local oz = wLoc.Z - enemyPos.Z
                                            hud:AddDebugText(".", character, 0.3, {X=ox, Y=oy, Z=oz}, {X=ox, Y=oy, Z=oz}, {R=0,G=255,B=255,A=255}, true, false, true, nil, 0.55, true)
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 25: WALLHACK (CHAMS)
-- ══════════════════════════════════════════════════════════════

local function ApplyVisualMods(enemy, enable)
    if not slua.isValid(enemy) then return end
    pcall(function()
        local mesh = enemy.Mesh
        if not slua.isValid(mesh) then return end
        if enable then
            mesh.UseScopeDistanceCulling = false
            mesh:SetRenderCustomDepth(true)
            mesh:SetCustomDepthStencilValue(1)
            mesh:SetCustomDepthStencilWriteMask(1)
            mesh.CustomDepthStencilValue = 1
            local s, mat = pcall(function() return mesh:GetMaterial(0) end)
            if s and slua.isValid(mat) then
                local s2, base = pcall(function() return mat:GetBaseMaterial() end)
                if s2 and slua.isValid(base) then base.bDisableDepthTest = true; base.BlendMode = 2 end
            end
        else
            mesh.UseScopeDistanceCulling = true
            mesh:SetRenderCustomDepth(false)
            mesh:SetCustomDepthStencilValue(0)
            mesh.CustomDepthStencilValue = 0
        end
    end)
end

_G.ApplyWallhack = function()
    if not _G.LexusConfig.Wallhack then return end
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local myTeam = player.TeamID or 0
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= player and enemy.TeamID ~= myTeam then
                if IsCharacterAlive(enemy) then ApplyVisualMods(enemy, true) end
            end
        end
    end)
end

_G.ClearWallhack = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= player then ApplyVisualMods(enemy, false) end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 26: WEAPON LUFFY / SOUL / RAINBOW (Orbit System)
-- ══════════════════════════════════════════════════════════════

_G.WeaponOrbitState = _G.WeaponOrbitState or {active = false}

local function GetAllBackWeapons()
    local weaponList = {}
    local character = GameplayData.GetPlayerCharacter()
    if not slua.isValid(character) then return weaponList end
    local weaponManager = character:GetWeaponManager()
    if not slua.isValid(weaponManager) then return weaponList end
    local currentSlot = nil
    if weaponManager.GetCurrentUsingPropSlot then currentSlot = weaponManager:GetCurrentUsingPropSlot() end
    for slot = 0, 5 do
        local weapon = nil
        if weaponManager.GetInventoryWeaponByPropSlot then weapon = weaponManager:GetInventoryWeaponByPropSlot(slot) end
        if slua.isValid(weapon) and slot ~= currentSlot then table.insert(weaponList, weapon) end
    end
    return weaponList
end

_G.StartWeaponEffects = function()
    if _G.WeaponOrbitState.active then return end
    _G.WeaponOrbitState.active = true
    _G.WeaponOrbitState.accumulatedTime = 0
    _G.WeaponOrbitState.orbitWeapons = {}
    _G.WeaponOrbitState.orbitData = {}
    _G.WeaponOrbitState.savedAttachData = {}
    _G.WeaponOrbitState.detached = false
    local function UpdateOrbit()
        if not _G.WeaponOrbitState.active then return end
        local character = GameplayData.GetPlayerCharacter()
        if not slua.isValid(character) then return end
        if _G.LexusConfig.WeaponLuffy then
            _G.WeaponOrbitState.orbitWeapons = GetAllBackWeapons()
            if #_G.WeaponOrbitState.orbitWeapons > 0 then
                local center = character:K2_GetActorLocation()
                _G.WeaponOrbitState.accumulatedTime = _G.WeaponOrbitState.accumulatedTime + 0.016
                for i, weapon in ipairs(_G.WeaponOrbitState.orbitWeapons) do
                    if slua.isValid(weapon) then
                        local orbitRad = math.rad((360 / #_G.WeaponOrbitState.orbitWeapons) * (i - 1) + _G.WeaponOrbitState.accumulatedTime * 180)
                        local radius = 150
                        local offsetX = radius * math.cos(orbitRad)
                        local offsetY = radius * math.sin(orbitRad)
                        local offsetZ = 50 + math.sin(_G.WeaponOrbitState.accumulatedTime * 3) * 30
                        local newLoc = FVector(center.X + offsetX, center.Y + offsetY, center.Z + offsetZ)
                        pcall(function() weapon:K2_SetActorLocation(newLoc, false, nil, false) end)
                    end
                end
            end
        end
        if _G.LexusConfig.WeaponRainbow then
            local weaponManager = character:GetWeaponManager()
            if slua.isValid(weaponManager) then
                local currentSlot = weaponManager.GetCurrentUsingPropSlot and weaponManager:GetCurrentUsingPropSlot()
                local currentWeapon = currentSlot and weaponManager.GetInventoryWeaponByPropSlot and weaponManager:GetInventoryWeaponByPropSlot(currentSlot)
                if slua.isValid(currentWeapon) then ApplyOutlineToWeapon(currentWeapon, GetRainbowColor()) end
            end
        end
    end
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and pc.AddGameTimer then
        _G.WeaponOrbitState.timer = pc:AddGameTimer(0.016, true, UpdateOrbit)
    end
end

_G.StopWeaponEffects = function()
    if not _G.WeaponOrbitState.active then return end
    _G.WeaponOrbitState.active = false
    if _G.WeaponOrbitState.timer then
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if pc and pc.RemoveGameTimer then pc:RemoveGameTimer(_G.WeaponOrbitState.timer) end
        _G.WeaponOrbitState.timer = nil
    end
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 27: HIGH JUMP / FAST CAR / GOD MODE
-- ══════════════════════════════════════════════════════════════

_G.ApplyHighJump = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local movement = player.CharacterMovement or player.CharMoveComp
        if movement then
            if enabled then
                movement.JumpZVelocity = 2000
            else
                movement.JumpZVelocity = 420
            end
        end
    end)
end

_G.ApplyFastCar = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local vehicle = player.GetCurrentVehicle and player:GetCurrentVehicle()
        if slua.isValid(vehicle) then
            if enabled then
                if vehicle.MaxSpeed then vehicle.MaxSpeed = 50000 end
                if vehicle.EngineMaxRotationSpeed then vehicle.EngineMaxRotationSpeed = 50000 end
            else
                if vehicle.MaxSpeed then vehicle.MaxSpeed = 15000 end
                if vehicle.EngineMaxRotationSpeed then vehicle.EngineMaxRotationSpeed = 7000 end
            end
        end
    end)
end

_G.ApplyGodMode = function(enabled)
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        if enabled then
            player:SetMaxHealth(99999)
            player:SetHealth(99999)
        else
            player:SetMaxHealth(100)
            player:SetHealth(100)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 28: CHAMS (Green/Yellow)
-- ══════════════════════════════════════════════════════════════

_G.ApplyCHAMS = function()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local myTeam = player.TeamID or 0
        local allChars = Game:GetAllPlayerPawns()
        if not allChars then return end
        local color = _G.LexusConfig.CHAMSColor or {R=0, G=255, B=0, A=255}
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= player and enemy.TeamID ~= myTeam and IsCharacterAlive(enemy) then
                local mesh = enemy.Mesh
                if slua.isValid(mesh) then
                    if _G.LexusConfig.EnableCHAMS then
                        if not enemy._chamsMID then
                            enemy._chamsMID = mesh:CreateAndSetMaterialInstanceDynamic(0)
                        end
                        if enemy._chamsMID then
                            pcall(function()
                                local linearColor = FLinearColor(color.R/255, color.G/255, color.B/255, 1)
                                local paramNames = {"Color","BaseColor","BodyColor","Para_Color","Tint","TintColor","MainColor","DiffuseColor"}
                                for _, pname in ipairs(paramNames) do
                                    pcall(function() enemy._chamsMID:SetVectorParameterValue(pname, linearColor) end)
                                end
                            end)
                        end
                    else
                        enemy._chamsMID = nil
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 29: MOD MENU UI (SettingPage Define)
-- ══════════════════════════════════════════════════════════════

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true
    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if type(id) == "string" and not tonumber(id) then return id end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = safe_require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = safe_require("client.logic.NewSetting.SettingCatalog")
    if not SettingPageDefine or not SettingCatalog then return end
    if SettingPageDefine.ModMenu then return end

    local AliasMap = safe_require("client.slua.umg.NewSetting.Item.AliasMap")
    if not AliasMap then return end

    local CombinedStack = {
        {Key = "ModMenu_FOV_Ex", UI = AliasMap.TitleSwitcher, Text = "IPAD VIEW", ExpandIndex = 0,
            GetFunc = function() return _G.LexusConfig.EnableFOV end,
            SetFunc = function(c, v) _G.LexusConfig.EnableFOV = v; if not v then _G.SetFOV(90) else _G.SetFOV(_G.LexusConfig.FOVValue) end; return true end},
        {Key = "ModMenu_FOV_Slider", UI = AliasMap.Slider, Text = "   FOV Value (80-140)", ExpandHandle = "ModMenu_FOV_Ex",
            MinValue = 0, MaxValue = 60, min = 0, max = 60,
            GetFunc = function() return (_G.LexusConfig.FOVValue or 110) - 80 end,
            SetFunc = function(c, v) local finalFOV = v + 80; _G.LexusConfig.FOVValue = finalFOV; if _G.LexusConfig.EnableFOV then _G.SetFOV(finalFOV) end; return true end},
        {Key = "ModMenu_AutoHead", UI = AliasMap.TitleSwitcher, Text = "AUTO HEAD",
            GetFunc = function() return _G.LexusConfig.AutoHead end,
            SetFunc = function(c, v) _G.LexusConfig.AutoHead = v; _G.InitializeAutoHeadHooks(); return true end},
        {Key = "ModMenu_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = "MAGIC BULLET", ExpandIndex = 0,
            GetFunc = function() return _G.LexusConfig.EnableMagic end,
            SetFunc = function(c, v) _G.LexusConfig.EnableMagic = v; _G.ResetHitbox(); return true end},
        {Key = "ModMenu_Magic_Low", UI = AliasMap.Switcher, Text = "   [ LEVEL: LOW ]", ExpandHandle = "ModMenu_Magic_Ex",
            GetFunc = function() return _G.LexusConfig.MagicLevel == 90 end,
            SetFunc = function(c, v) if v then _G.ResetHitbox(); _G.LexusConfig.MagicLevel = 90 end; return true end},
        {Key = "ModMenu_Magic_Med", UI = AliasMap.Switcher, Text = "   [ LEVEL: MEDIUM ]", ExpandHandle = "ModMenu_Magic_Ex",
            GetFunc = function() return _G.LexusConfig.MagicLevel == 120 end,
            SetFunc = function(c, v) if v then _G.ResetHitbox(); _G.LexusConfig.MagicLevel = 120 end; return true end},
        {Key = "ModMenu_Magic_High", UI = AliasMap.Switcher, Text = "   [ LEVEL: HARD ]", ExpandHandle = "ModMenu_Magic_Ex",
            GetFunc = function() return _G.LexusConfig.MagicLevel == 180 end,
            SetFunc = function(c, v) if v then _G.ResetHitbox(); _G.LexusConfig.MagicLevel = 180 end; return true end},
        {Key = "ModMenu_Grass_Ex", UI = AliasMap.TitleSwitcher, Text = "NO GRASS",
            GetFunc = function() return _G.LexusConfig.DisableGrass end,
            SetFunc = function(c, v) _G.LexusConfig.DisableGrass = v; _G.DisableGrass(); return true end},
        {Key = "ModMenu_BlackSky", UI = AliasMap.TitleSwitcher, Text = "BLACK SKY",
            GetFunc = function() return _G.LexusConfig.BlackSky end,
            SetFunc = function(c, v) _G.LexusConfig.BlackSky = v; _G.BlackSky(); return true end},
        {Key = "ModMenu_Fog", UI = AliasMap.TitleSwitcher, Text = "NO FOG",
            GetFunc = function() return _G.LexusConfig.RemoveFog end,
            SetFunc = function(c, v) _G.LexusConfig.RemoveFog = v; _G.SetFogRemoval(v); return true end},
        {Key = "ModMenu_Tree", UI = AliasMap.TitleSwitcher, Text = "NO TREE",
            GetFunc = function() return _G.LexusConfig.RemoveTree end,
            SetFunc = function(c, v) _G.LexusConfig.RemoveTree = v; _G.SetTreeRemoval(v); return true end},
        {Key = "ModMenu_Water", UI = AliasMap.TitleSwitcher, Text = "NO WATER",
            GetFunc = function() return _G.LexusConfig.RemoveWater end,
            SetFunc = function(c, v) _G.LexusConfig.RemoveWater = v; _G.SetWaterRemoval(v); return true end},
        {Key = "ModMenu_Smoke", UI = AliasMap.TitleSwitcher, Text = "NO SMOKE",
            GetFunc = function() return _G.LexusConfig.RemoveSmoke end,
            SetFunc = function(c, v) _G.LexusConfig.RemoveSmoke = v; _G.SetSmokeRemoval(v); return true end},
        {Key = "ModMenu_WhiteBody", UI = AliasMap.TitleSwitcher, Text = "WHITE BODY",
            GetFunc = function() return _G.LexusConfig.WhiteBody end,
            SetFunc = function(c, v) _G.LexusConfig.WhiteBody = v; return true end},
        {Key = "ModMenu_Rain", UI = AliasMap.TitleSwitcher, Text = "RAIN EFFECT",
            GetFunc = function() return _G.LexusConfig.EnableRain end,
            SetFunc = function(c, v) _G.LexusConfig.EnableRain = v; _G.SetRainEnabled(v); return true end},
        {Key = "ModMenu_Snow", UI = AliasMap.TitleSwitcher, Text = "SNOW EFFECT",
            GetFunc = function() return _G.LexusConfig.EnableSnow end,
            SetFunc = function(c, v) _G.LexusConfig.EnableSnow = v; _G.SetSnowEnabled(v); return true end},
    }

    local AimRecoilStack = {
        {Key = "ModMenu_AimConfig_Title", UI = AliasMap.Title, Text = "--- AIMBOT SETTINGS ---"},
        {Key = "ModMenu_AimConfig_Ex", UI = AliasMap.TitleSwitcher, Text = "AIMBOT (AUTO AIMING)", ExpandIndex = 0,
            GetFunc = function() return _G.LexusConfig.EnableAiming end,
            SetFunc = function(c, v) _G.LexusConfig.EnableAiming = v; _G.ApplyAimingConfig(); return true end},
        {Key = "ModMenu_Aim_LOW", UI = AliasMap.Switcher, Text = "   [ LEVEL: LOW ]", ExpandHandle = "ModMenu_AimConfig_Ex",
            GetFunc = function() return _G.LexusConfig.AimingLevel == "LOW" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "LOW"; _G.ApplyAimingConfig() end; return true end},
        {Key = "ModMenu_Aim_MED", UI = AliasMap.Switcher, Text = "   [ LEVEL: MEDIUM ]", ExpandHandle = "ModMenu_AimConfig_Ex",
            GetFunc = function() return _G.LexusConfig.AimingLevel == "MEDIUM" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "MEDIUM"; _G.ApplyAimingConfig() end; return true end},
        {Key = "ModMenu_Aim_HARD", UI = AliasMap.Switcher, Text = "   [ LEVEL: HARD ]", ExpandHandle = "ModMenu_AimConfig_Ex",
            GetFunc = function() return _G.LexusConfig.AimingLevel == "HARD" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "HARD"; _G.ApplyAimingConfig() end; return true end},
        {Key = "ModMenu_Aim_EXTREME", UI = AliasMap.Switcher, Text = "   [ LEVEL: EXTREME ]", ExpandHandle = "ModMenu_AimConfig_Ex",
            GetFunc = function() return _G.LexusConfig.AimingLevel == "EXTREME" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AimingLevel = "EXTREME"; _G.ApplyAimingConfig() end; return true end},
        {Key = "ModMenu_Recoil_Title", UI = AliasMap.Title, Text = "--- RECOIL SETTINGS ---"},
        {Key = "ModMenu_Recoil_Ex", UI = AliasMap.TitleSwitcher, Text = "NO RECOIL", ExpandIndex = 0,
            GetFunc = function() return _G.LexusConfig.EnableNoRecoil end,
            SetFunc = function(c, v) _G.LexusConfig.EnableNoRecoil = v; _G.ApplyNoRecoil(); return true end},
        {Key = "ModMenu_Recoil_LESS", UI = AliasMap.Switcher, Text = "   [ LEVEL: LESS ]", ExpandHandle = "ModMenu_Recoil_Ex",
            GetFunc = function() return _G.LexusConfig.RecoilLevel == "LESS" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.RecoilLevel = "LESS"; _G.ApplyNoRecoil() end; return true end},
        {Key = "ModMenu_Recoil_NO", UI = AliasMap.Switcher, Text = "   [ LEVEL: ZERO ]", ExpandHandle = "ModMenu_Recoil_Ex",
            GetFunc = function() return _G.LexusConfig.RecoilLevel == "NO" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.RecoilLevel = "NO"; _G.ApplyNoRecoil() end; return true end},
        {Key = "ModMenu_NoShake", UI = AliasMap.TitleSwitcher, Text = "NO SHAKE",
            GetFunc = function() return _G.LexusConfig.EnableNoShake end,
            SetFunc = function(c, v) _G.LexusConfig.EnableNoShake = v; _G.ApplyNoRecoil(); return true end},
        {Key = "ModMenu_AutoAim_Ex", UI = AliasMap.TitleSwitcher, Text = "AUTO AIM", ExpandIndex = 0,
            GetFunc = function() return _G.LexusConfig.EnableAutoAim end,
            SetFunc = function(c, v) _G.LexusConfig.EnableAutoAim = v; _G.ApplyAutoAim(); return true end},
        {Key = "ModMenu_Aim_Head", UI = AliasMap.Switcher, Text = "   [ BONE: HEAD ]", ExpandHandle = "ModMenu_AutoAim_Ex",
            GetFunc = function() return _G.LexusConfig.AutoAimBone == "Head" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AutoAimBone = "Head"; _G.ApplyAutoAim() end; return true end},
        {Key = "ModMenu_Aim_Neck", UI = AliasMap.Switcher, Text = "   [ BONE: NECK ]", ExpandHandle = "ModMenu_AutoAim_Ex",
            GetFunc = function() return _G.LexusConfig.AutoAimBone == "neck_01" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AutoAimBone = "neck_01"; _G.ApplyAutoAim() end; return true end},
        {Key = "ModMenu_Aim_Pelvis", UI = AliasMap.Switcher, Text = "   [ BONE: PELVIS ]", ExpandHandle = "ModMenu_AutoAim_Ex",
            GetFunc = function() return _G.LexusConfig.AutoAimBone == "pelvis" end,
            SetFunc = function(c, v) if v then _G.LexusConfig.AutoAimBone = "pelvis"; _G.ApplyAutoAim() end; return true end},
        {Key = "ModMenu_WepMod_Ex", UI = AliasMap.TitleSwitcher, Text = "WEAPON MODS", ExpandIndex = 0,
            GetFunc = function() return _G.LexusConfig.EnableWeaponMod end,
            SetFunc = function(c, v) _G.LexusConfig.EnableWeaponMod = v; return true end},
        {Key = "ModMenu_SuperBullet", UI = AliasMap.TitleSwitcher, Text = "SUPER BULLET",
            GetFunc = function() return _G.LexusConfig.SuperBullet > 1 end,
            SetFunc = function(c, v) _G.LexusConfig.SuperBullet = v and 5 or 1; _G.ApplySuperBullet(); return true end},
        {Key = "ModMenu_SuperFire", UI = AliasMap.TitleSwitcher, Text = "SUPER FIRE RATE",
            GetFunc = function() return _G.LexusConfig.SuperFireRate end,
            SetFunc = function(c, v) _G.LexusConfig.SuperFireRate = v; _G.ApplySuperFireRate(); return true end},
        {Key = "ModMenu_InfAmmo", UI = AliasMap.TitleSwitcher, Text = "INFINITE AMMO",
            GetFunc = function() return _G.LexusConfig.InfiniteAmmo end,
            SetFunc = function(c, v) _G.LexusConfig.InfiniteAmmo = v; _G.ApplyInfiniteAmmo(); return true end},
        {Key = "ModMenu_QuickScope", UI = AliasMap.TitleSwitcher, Text = "QUICK SCOPE",
            GetFunc = function() return _G.LexusConfig.QuickScope end,
            SetFunc = function(c, v) _G.LexusConfig.QuickScope = v; _G.ApplyQuickScope(); return true end},
        {Key = "ModMenu_FastSwitch", UI = AliasMap.TitleSwitcher, Text = "FAST SWITCH",
            GetFunc = function() return _G.LexusConfig.FastSwitch end,
            SetFunc = function(c, v) _G.LexusConfig.FastSwitch = v; _G.ApplyFastSwitch(); return true end},
        {Key = "ModMenu_Wallbang", UI = AliasMap.TitleSwitcher, Text = "GUN WALLBANG",
            GetFunc = function() return _G.LexusConfig.GunWallbang end,
            SetFunc = function(c, v) _G.LexusConfig.GunWallbang = v; _G.ApplyGunWallbang(); return true end},
        {Key = "ModMenu_CrossDev", UI = AliasMap.TitleSwitcher, Text = "NO CROSS DEVIATION",
            GetFunc = function() return _G.LexusConfig.CrossDeviation end,
            SetFunc = function(c, v) _G.LexusConfig.CrossDeviation = v; _G.ApplyCrossDeviation(); return true end},
        {Key = "ModMenu_FlashSpeed", UI = AliasMap.TitleSwitcher, Text = "FLASH SPEED",
            GetFunc = function() return _G.LexusConfig.FlashSpeed end,
            SetFunc = function(c, v) _G.LexusConfig.FlashSpeed = v; _G.ApplyFlashSpeed(); return true end},
    }

    local VisualStack = {
        {Key = "ModMenu_ESP_Title", UI = AliasMap.Title, Text = "--- ESP SETTINGS ---"},
        {Key = "ModMenu_ESP", UI = AliasMap.TitleSwitcher, Text = "ENABLE ESP",
            GetFunc = function() return _G.LexusConfig.EnableESP end,
            SetFunc = function(c, v) _G.LexusConfig.EnableESP = v; return true end},
        {Key = "ModMenu_ESPName", UI = AliasMap.TitleSwitcher, Text = "   ESP NAME",
            GetFunc = function() return _G.LexusConfig.ESPName end,
            SetFunc = function(c, v) _G.LexusConfig.ESPName = v; return true end},
        {Key = "ModMenu_ESPWeapon", UI = AliasMap.TitleSwitcher, Text = "   ESP WEAPON",
            GetFunc = function() return _G.LexusConfig.ESPWeapon end,
            SetFunc = function(c, v) _G.LexusConfig.ESPWeapon = v; return true end},
        {Key = "ModMenu_ESPDist", UI = AliasMap.TitleSwitcher, Text = "   ESP DISTANCE",
            GetFunc = function() return _G.LexusConfig.ESPDistance end,
            SetFunc = function(c, v) _G.LexusConfig.ESPDistance = v; return true end},
        {Key = "ModMenu_ESPDot", UI = AliasMap.TitleSwitcher, Text = "   DOT SELECTION ESP",
            GetFunc = function() return _G.LexusConfig.ESPDot end,
            SetFunc = function(c, v) _G.LexusConfig.ESPDot = v; return true end},
        {Key = "ModMenu_ESPHPBar", UI = AliasMap.TitleSwitcher, Text = "   HP BAR ESP",
            GetFunc = function() return _G.LexusConfig.ESPHPBar end,
            SetFunc = function(c, v) _G.LexusConfig.ESPHPBar = v; return true end},
        {Key = "ModMenu_ESPMiniMap", UI = AliasMap.TitleSwitcher, Text = "   MINI MAP MARKING",
            GetFunc = function() return _G.LexusConfig.ESPMiniMap end,
            SetFunc = function(c, v) _G.LexusConfig.ESPMiniMap = v; return true end},
        {Key = "ModMenu_WH_Title", UI = AliasMap.Title, Text = "--- VISUALS ---"},
        {Key = "ModMenu_Wallhack", UI = AliasMap.TitleSwitcher, Text = "WALLHACK (CHAMS)",
            GetFunc = function() return _G.LexusConfig.Wallhack end,
            SetFunc = function(c, v) _G.LexusConfig.Wallhack = v; if v then _G.ApplyWallhack() else _G.ClearWallhack() end; return true end},
        {Key = "ModMenu_CHAMS", UI = AliasMap.TitleSwitcher, Text = "CHAMS (GREEN)",
            GetFunc = function() return _G.LexusConfig.EnableCHAMS end,
            SetFunc = function(c, v) _G.LexusConfig.EnableCHAMS = v; _G.ApplyCHAMS(); return true end},
        {Key = "ModMenu_WeaponOutline", UI = AliasMap.TitleSwitcher, Text = "WEAPON OUTLINE",
            GetFunc = function() return _G.LexusConfig.WeaponRainbow end,
            SetFunc = function(c, v) _G.LexusConfig.WeaponRainbow = v; if not v then _G.ClearAllWeaponOutlines() end; return true end},
        {Key = "ModMenu_WeaponOrbit", UI = AliasMap.TitleSwitcher, Text = "WEAPON ORBIT (LUFFY)",
            GetFunc = function() return _G.LexusConfig.WeaponLuffy end,
            SetFunc = function(c, v) _G.LexusConfig.WeaponLuffy = v; if v then _G.StartWeaponEffects() end; return true end},
    }

    local MovementStack = {
        {Key = "ModMenu_Mov_Title", UI = AliasMap.Title, Text = "--- MOVEMENT ---"},
        {Key = "ModMenu_Speed", UI = AliasMap.TitleSwitcher, Text = "SPEED BOOST",
            GetFunc = function() return _G.LexusConfig.EnableSpeedBoost end,
            SetFunc = function(c, v) _G.LexusConfig.EnableSpeedBoost = v; _G.ApplySpeedBoost(v); return true end},
        {Key = "ModMenu_AntiGrav", UI = AliasMap.TitleSwitcher, Text = "ANTI GRAVITY",
            GetFunc = function() return _G.LexusConfig.EnableAntiGravity end,
            SetFunc = function(c, v) _G.LexusConfig.EnableAntiGravity = v; _G.ApplyAntiGravity(v); return true end},
        {Key = "ModMenu_WallClimb", UI = AliasMap.TitleSwitcher, Text = "WALL CLIMB",
            GetFunc = function() return _G.LexusConfig.EnableWallClimb end,
            SetFunc = function(c, v) _G.LexusConfig.EnableWallClimb = v; _G.ApplyWallClimb(v); return true end},
        {Key = "ModMenu_HighJump", UI = AliasMap.TitleSwitcher, Text = "HIGH JUMP",
            GetFunc = function() return _G.LexusConfig.HighJump end,
            SetFunc = function(c, v) _G.LexusConfig.HighJump = v; _G.ApplyHighJump(v); return true end},
        {Key = "ModMenu_FastCar", UI = AliasMap.TitleSwitcher, Text = "FAST CAR",
            GetFunc = function() return _G.LexusConfig.FastCar end,
            SetFunc = function(c, v) _G.LexusConfig.FastCar = v; _G.ApplyFastCar(v); return true end},
        {Key = "ModMenu_Rotate", UI = AliasMap.TitleSwitcher, Text = "CHARACTER ROTATION",
            GetFunc = function() return _G.LexusConfig.EnableCharRotation end,
            SetFunc = function(c, v) _G.LexusConfig.EnableCharRotation = v; return true end},
        {Key = "ModMenu_Scale_Title", UI = AliasMap.Title, Text = "--- SCALE ---"},
        {Key = "ModMenu_CharScale", UI = AliasMap.TitleSwitcher, Text = "MY SCALE (BIG)",
            GetFunc = function() return _G.LexusConfig.CharScale > 1.0 end,
            SetFunc = function(c, v) _G.LexusConfig.CharScale = v and 3.0 or 1.0; _G.ApplyCharScale(); return true end},
        {Key = "ModMenu_EnemyScale", UI = AliasMap.TitleSwitcher, Text = "ENEMY SCALE (SMALL)",
            GetFunc = function() return _G.LexusConfig.EnemyScale < 1.0 end,
            SetFunc = function(c, v) _G.LexusConfig.EnemyScale = v and 0.3 or 1.0; _G.ApplyEnemyScale(); return true end},
        {Key = "ModMenu_GodMode", UI = AliasMap.TitleSwitcher, Text = "GOD MODE",
            GetFunc = function() return _G.LexusConfig.GodMode end,
            SetFunc = function(c, v) _G.LexusConfig.GodMode = v; _G.ApplyGodMode(v); return true end},
    }

    pcall(function()
        SettingPageDefine.ModMenu = {
            Index = 60,
            Title = "PAWAN MOD MENU",
            Stack = CombinedStack
        }
        SettingPageDefine.AimRecoil = {
            Index = 61,
            Title = "AIM & RECOIL",
            Stack = AimRecoilStack
        }
        SettingPageDefine.VisualESP = {
            Index = 62,
            Title = "ESP & VISUALS",
            Stack = VisualStack
        }
        SettingPageDefine.Movement = {
            Index = 63,
            Title = "MOVEMENT & MORE",
            Stack = MovementStack
        }
        local catalogIdx = #SettingCatalog + 1
        SettingCatalog[catalogIdx] = {
            Title = "PAWAN MOD",
            Pages = {"ModMenu", "AimRecoil", "VisualESP", "Movement"}
        }
    end)
end

-- ══════════════════════════════════════════════════════════════
-- SECTION 17: MAIN INITIALIZATION
-- ══════════════════════════════════════════════════════════════

local _initialized = false

local function FinalInitialize()
    if _initialized then return end
    _initialized = true

    InitializeAllBypasses()
    ReadLiveConfig()

    pcall(function() _G.InitModMenuTab() end)

    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if pc and isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(3.0, true, huntAndKillAll)
            pc:AddGameTimer(2.0, true, function()
                pcall(function()
                    local char = GameplayData.GetPlayerCharacter()
                    if slua.isValid(char) then
                        _G.InjectWeaponLogicHooks(char)
                        _G.ApplyWeaponSkins(char)
                    end
                end)
                pcall(function()
                    if _G.LexusConfig.EnableWeaponMod then _G.otherWeapon() end
                    if _G.LexusConfig.EnableMagic then _G.Magic() end
                    if _G.LexusConfig.EnableNoRecoil then _G.ApplyNoRecoil() end
                    if _G.LexusConfig.EnableAutoAim then _G.ApplyAutoAim() end
                    if _G.LexusConfig.EnableAiming then _G.ApplyAimingConfig() end
                    if _G.LexusConfig.DisableGrass then _G.DisableGrass() end
                    if _G.LexusConfig.BlackSky then _G.BlackSky() end
                    if _G.LexusConfig.WhiteBody then _G.ApplyWhiteBody() end
                    if _G.LexusConfig.EnableESP then _G.ESPTick() end
                    if _G.LexusConfig.Wallhack then _G.ApplyWallhack() end
                    if _G.LexusConfig.EnableCHAMS then _G.ApplyCHAMS() end
                    if _G.LexusConfig.EnableSpeedBoost then _G.ApplySpeedBoost(true) end
                    if _G.LexusConfig.EnableAntiGravity then _G.ApplyAntiGravity(true) end
                    if _G.LexusConfig.EnableWallClimb then _G.ApplyWallClimb(true) end
                    if _G.LexusConfig.HighJump then _G.ApplyHighJump(true) end
                    if _G.LexusConfig.SuperBullet > 1 then _G.ApplySuperBullet() end
                    if _G.LexusConfig.SuperFireRate then _G.ApplySuperFireRate() end
                    if _G.LexusConfig.InfiniteAmmo then _G.ApplyInfiniteAmmo() end
                    if _G.LexusConfig.QuickScope then _G.ApplyQuickScope() end
                    if _G.LexusConfig.FastSwitch then _G.ApplyFastSwitch() end
                    if _G.LexusConfig.GunWallbang then _G.ApplyGunWallbang() end
                    if _G.LexusConfig.CrossDeviation then _G.ApplyCrossDeviation() end
                    if _G.LexusConfig.HitEffect > 0 then _G.ApplyHitEffect() end
                    if _G.LexusConfig.FlashSpeed then _G.ApplyFlashSpeed() end
                    _G.CleanupDeadMarks()
                end)
            end)
        end
    end)

    print("[PAWAN] Pawan Mod Menu v" .. SCRIPT_VERSION .. " loaded successfully!")
end

pcall(function()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(0.5, false, FinalInitialize)
    else
        local fb = slua_GameFrontendHUD or Game
        if fb and isValid(fb) then fb:AddGameTimer(2.0, false, FinalInitialize) end
    end
end)
