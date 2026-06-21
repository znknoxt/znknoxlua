-- Per-match guard: allow re-init when the player controller changes (new match)
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then return end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

-- Initialize bypass state ASAP
if not _G.BYPASS_STATE then
    _G.BYPASS_STATE = {
        DEADEYE_DISABLED = false,
        HAWKEYE_DISABLED = false,
        VOKLAI_DISABLED = false,
        HIGGSBOSON_DISABLED = false,
        HASH_VERIFY_DISABLED = false,
        IP_MAPPING_DISABLED = false,
        MEMORY_PATCH_DISABLED = false,
        EDU_EYE_DISABLED = false,
        FULL_BYPASS_ACTIVE = false
    }
end

-- Initialize feature toggles
if _G.Mod_Aimbot_Enabled == nil then _G.Mod_Aimbot_Enabled = true end
if _G.Mod_Wallhack_Enabled == nil then _G.Mod_Wallhack_Enabled = true end

-- Aimbot strength slider (0-100)
if _G.Mod_AimbotStrength == nil then _G.Mod_AimbotStrength = 50 end

local require = require
local import  = import
local isValid = slua.isValid

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
_G.CheatsEnabled = true

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local ok_gd, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
if not ok_gd then GameplayData = nil end

-- ==================== BYPASS ====================
pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
    if not Msg then Msg = require("client.slua.logic.common.logic_common_msg_box") end
    if Msg and Msg.Show then
        Msg.Show(4, "Info", "COMPLETE BYPASS ACTIVE\n8-LAYER ANTI-CHEAT BYPASSED")
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

    local DeleteAccount = package.loaded["client.slua.logic.gdpr.logic_deleteaccount"]
    if DeleteAccount then
        DeleteAccount.ForceDeleteAccount = retFalse
        DeleteAccount.OnReceiveDeleteNotify = nop
    end

    local ComplianceUtil = package.loaded["client.slua.logic.gdpr.compliance_util"]
    if ComplianceUtil then ComplianceUtil.CheckCompliance = nop end
end)

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

    local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
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
        ClientHawk.CanInspectorBroadcast = retFalse
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

    local AmphibiousBoat = safe_require("GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.AmphibiousBoatTLogFeature")
    if AmphibiousBoat then
        AmphibiousBoat.RecordMovement = nop
        AmphibiousBoat.StartRecordMovement = nop
    end
    local ICTLog = safe_require("GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem")
    if ICTLog then ICTLog.SendICExceptionTLog = nop end
    local DSFight = safe_require("GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem")
    if DSFight then
        DSFight.GetSimpleFightData = retEmpty
        DSFight.ReportFightData = nop
        DSFight.ReportPlayerWeapon = nop
    end
    local DSSec = safe_require("GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem")
    if DSSec then
        DSSec._OnReportServerJumpFlow = nop
        DSSec._OnReportTeleportFlow = nop
        DSSec._OnReportSpeedHackFlow = nop
    end
    local DSCommon = safe_require("GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem")
    if DSCommon then DSCommon.HandleKillTlog = nop end

    local PufferTlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
    if PufferTlog then PufferTlog.report_download_tlog = nop end
end)

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
    local WeekReport = package.loaded["client.network.Protocol.WeekRportHandler"]
    if WeekReport then
        WeekReport.send_week_report = nop
        WeekReport.send_week_detail = nop
    end
    local LogicComplaint = package.loaded["client.logic.battle.logic_complaint"]
    if LogicComplaint then
        LogicComplaint.SendComplaintReq = nop
        LogicComplaint.Submit = nop
        LogicComplaint.ReportPlayer = nop
        LogicComplaint.ShowComplaint = nop
        LogicComplaint.ShowHandle = nop
    end
    local OBResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.EscapeBattleResultShowOBResultLogic"]
    if OBResult then
        OBResult.OnBattleResult = nop
        OBResult.OnResultProcessStart = nop
    end
    local NormalOBResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowOBResultLogic"]
    if NormalOBResult then
        NormalOBResult.OnBattleResult = nop
        NormalOBResult.OnResultProcessStart = nop
    end
    local ShowResult = package.loaded["GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultShowResultLogic"]
    if ShowResult then
        ShowResult.OnBattleResult = nop
        ShowResult.OnResultProcessStart = nop
        ShowResult.OnResultProcessContinue = nop
        ShowResult.ReceiveData = nop
        ShowResult.SendEndFlow = nop
        ShowResult.OnReport = nop
        ShowResult.ShowResult = nop
        ShowResult.ShowResultInternal = nop
        ShowResult.StopResultProcess = nop
    end
end)

pcall(function()
    local EmuHandler = package.loaded["client.network.Protocol.EmulatorHandler"]
    if EmuHandler then EmuHandler.send_emulator_info = nop end
    local EmuScanner = package.loaded["client.logic.login.emulator_scanner"]
    if EmuScanner then
        EmuScanner.StartScan = nop
        EmuScanner.GetScanResult = retFalse
        EmuScanner.ReportScanResult = nop
    end
    local LoginVerify = package.loaded["client.network.Protocol.LoginVerifyHandler"]
    if LoginVerify then
        LoginVerify.send_login_verify_req = nop
        LoginVerify.send_device_verify_req = nop
    end
    local DSMonitor = package.loaded["client.logic.data.logic_ds_monitor"]
    if DSMonitor then
        DSMonitor.OnRecordMsg = nop
        DSMonitor.OnReportMsg = nop
    end
    local ClientDataStat = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientDataStatistcsSubsystem"]
    if ClientDataStat then
        ClientDataStat.StartToCheck = nop
        ClientDataStat.OnReceiveRTT = nop
        ClientDataStat.OnReceiveJitter = nop
        ClientDataStat.ReportAbnormal = nop
        ClientDataStat.ResetData = nop
    end
    local shootVerify = safe_require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if shootVerify then
        shootVerify.OnShootVerifyFailed = nop
        shootVerify.SendVerifyData = nop
    end
    local HighlightDS = safe_require("GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker")
    if HighlightDS then HighlightDS.CheckFuncUpgradedWeaponKill = nop end
end)

pcall(function()
    local ProfileReport = package.loaded["client.logic.data.profile_report_cfg"]
    if ProfileReport then ProfileReport.SendReport = nop end
    local VoiceReport = package.loaded["client.slua.logic.chat_voice.logic_chat_voice_report"]
    if VoiceReport then
        VoiceReport.ReportVoiceData = nop
        VoiceReport.ReportVoiceText = nop
    end
    local VoiceDoctor = package.loaded["client.slua.logic.chat_voice.logic_chat_voice_doctor"]
    if VoiceDoctor then
        VoiceDoctor.UploadVoiceLog = nop
        VoiceDoctor.UploadVoiceException = nop
    end
    local HomeAudit = package.loaded["client.slua.logic.home.Audit.logic_home_audit_state"]
    if HomeAudit then
        HomeAudit.SendAuditState = nop
        HomeAudit.ReportAuditResult = nop
    end
    local HomeReport = package.loaded["client.slua.logic.home.logic_home_report"]
    if HomeReport then
        HomeReport.ReportHomeData = nop
        HomeReport.ReportHomeVisitor = nop
    end
    local GemReport = package.loaded["client.logic.store.gem_report_utils"]
    if GemReport then
        GemReport.ReportGemData = nop
        GemReport.ReportGemPurchase = nop
    end
    local SafeStation = package.loaded["client.slua.logic.CustomerService.LogicSafeStation"]
    if SafeStation then
        SafeStation.UploadVideoEvidence = nop
        SafeStation.ReportPlayerBehavior = nop
    end
    local CustomerService = package.loaded["client.slua.logic.CustomerService.LogicCustomerService"]
    if CustomerService then
        CustomerService.SendComplaint = nop
        CustomerService.SendFeedback = nop
    end
end)

pcall(function()
    local znq6Revive = safe_require("GameLua.Mod.TDEvent.ZNQ6th.DS.ZNQ6thDSReviveSubsystem")
    if znq6Revive then znq6Revive.HaveNewItemForRevive = nop end
    local znq7Revive = safe_require("GameLua.Mod.TDEvent.ZNQ7th.DS.ZNQ7DSReviveSubsystem")
    if znq7Revive then znq7Revive.HaveChanceRevival = nop end
    local DataLayer = safe_require("GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem")
    if DataLayer then
        local orig = DataLayer.OnSpectatorReplayChanged
        if orig then
            DataLayer.OnSpectatorReplayChanged = function(dlSelf)
                _G.IsBeingWatched = true
                orig(dlSelf)
            end
        end
    end
    local DSActive = safe_require("GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem")
    if DSActive then
        DSActive.DelayKickOutPlayer = nop
        DSActive.ActiveKickNotify = nop
    end
    local CreativeDev = safe_require("GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem")
    if CreativeDev then CreativeDev.IsDebugPanelEnalbedCli = nop end
    local CreativeDeath = safe_require("GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeModeDeathRecordSubsystem")
    if CreativeDeath then CreativeDeath.OnPlayerKilled = nop end
    if _G.ClientReplayDataReporter then
        _G.ClientReplayDataReporter.ReportIntArrayData = nop
        _G.ClientReplayDataReporter.ReportFloatArrayData = nop
    end
    local SpectateReplay = safe_require("GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem")
    if SpectateReplay then
        SpectateReplay.RequestGotoSpectatingImp = nop
        SpectateReplay.RequestGotoSpectating = nop
    end
    local AIReplay = safe_require("GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem")
    if AIReplay then
        AIReplay.ReportAllPlayerInfo = nop
        AIReplay.ReportFrameData = nop
        AIReplay.ReportPlayerInput = nop
        if AIReplay.uCompletePlayBack then
            AIReplay.uCompletePlayBack.AddRecordMLAIInfo = nop
            AIReplay.uCompletePlayBack.StopRecording = nop
        end
    end
    local AITracking = safe_require("GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem")
    if AITracking then
        AITracking.RealLogoutTimer = nop
        AITracking.LogQueue = {}
        AITracking.AddToLogQue = nop
        AITracking.DoPrint = nop
        AITracking.OnAIPawnDied = nop
        AITracking.OnAIPawnReceiveDamage = nop
        AITracking.OnAIPawnEnemyChange = nop
    end
    local AFKReport = safe_require("GameLua.Mod.BaseMod.DS.Security.AFKReportorSubsystem")
    if AFKReport then
        AFKReport.HandleEnterFighting = nop
        AFKReport.InitializePlayerInputInfo = nop
        AFKReport.AddOneAFKInfo = nop
        AFKReport.SetPlayerAFKState = nop
        AFKReport.ResetPlayerInputInfo = nop
        AFKReport.PlayerHaveAction = nop
    end
    local TDMAFK = safe_require("GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem")
    if TDMAFK then
        TDMAFK.SendAFKTips = nop
        TDMAFK.OnHandleLostConnection = nop
    end
    local DataMgr = package.loaded["client.slua.logic.data.data_mgr"]
    if DataMgr then DataMgr.GetWeaponSkinSoundVolumeInfoByGroup = retZero end
    local CreditLogic = safe_require("GameLua.Mod.BaseMod.Client.ClientInGameCreditLogic")
    if CreditLogic then
        CreditLogic._SendUserReaction2ExitTeamBeforeBoardingReturnLobbyNotice = nop
        CreditLogic.ShowReturnLobbyIfFirstExitTeamBeforeBoarding = retFalse
        CreditLogic.OnReceiveCreditScoreChange = nop
        CreditLogic._IsFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = retFalse
        CreditLogic.SetFirstExitTeamBeforeBoardingReturnLobbyNoticeEnabled = nop
    end
end)

local globalFuncs = {
    "ReportTLogEvent","SendTlog","SendClientStats","ReportHitFlow","ReportAvatarException",
    "SendComplaintReq","SubmitReport","ReportSuspiciousPlayer","SendPacket","OnSyncBanInfo",
    "OnVoiceBanNotify","SendSecTLog","MarkSuspiciousPlayer","ReportPlayerBehaviorData",
    "CheckCompliance","ReportIllegalProgram","UploadVoiceLog"
}
for _, fn in ipairs(globalFuncs) do
    if type(_G[fn]) == "function" then _G[fn] = nop end
end

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
        "client.slua.logic.network.logic_network","client.slua.logic.download.report.puffer_tlog",
        "client.slua.data.BasicData.BasicDataClientReport","GameLua.GameCore.Module.Network.NetworkManager",
        "client.network.Protocol.ClientTlogHandler","client.network.Protocol.BattleReportHandler",
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

-- ==================== 8-LAYER ADVANCED ANTI-CHEAT BYPASS ====================

local FakeData = {
    ping = function() return math.random(20, 45) end,
    deviceID = function()
        local chars = "0123456789ABCDEF"
        local id = ""
        for i = 1, 32 do
            id = id .. chars:sub(math.random(1, #chars), math.random(1, #chars))
        end
        return id
    end,
    ipAddress = function()
        return "192.168." .. math.random(1, 255) .. "." .. math.random(1, 255)
    end,
    macAddress = function()
        return string.format("%02X:%02X:%02X:%02X:%02X:%02X",
            math.random(0,255), math.random(0,255), math.random(0,255),
            math.random(0,255), math.random(0,255), math.random(0,255))
    end,
    buildFingerprint = function()
        return "qcom/msmnile/msmnile:" .. math.random(10, 12) .. "/" .. 
               math.random(100000, 999999) .. "/user/release-keys"
    end,
    kernelVersion = function() return "4.19." .. math.random(100, 200) .. "-generic" end,
    hashValue = function()
        return "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
    end
}

local function KillTable(tbl, keys)
    if not tbl then return end
    for _, key in ipairs(keys) do
        pcall(function()
            if type(tbl[key]) == "function" then
                tbl[key] = function() return true, {} end
            else
                tbl[key] = nil
            end
        end)
    end
end

local function BypassDeadEye()
    if _G.BYPASS_STATE.DEADEYE_DISABLED then return end
    pcall(function()
        if _G.GameplayCallbacks then
            KillTable(_G.GameplayCallbacks, {
                "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow",
                "OnAimDetected", "OnHeadshotDetected", "OnPerfectAccuracy"
            })
        end
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local aimTracker = subsystems:Get("ClientAimTrackingSubsystem")
            if aimTracker then
                aimTracker.GetAimData = function() return {accuracy = math.random(45, 65), headshotRate = math.random(15, 35)} end
                aimTracker.IsAimNormal = function() return true end
            end
        end
    end)
    _G.BYPASS_STATE.DEADEYE_DISABLED = true
end

local function BypassHawkEye()
    if _G.BYPASS_STATE.HAWKEYE_DISABLED then return end
    pcall(function()
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local hawkEye = subsystems:Get("ClientHawkEyePatrolSubsystem")
            if hawkEye then
                hawkEye.GetPatrolData = function() return {} end
                hawkEye.IsBeingWatched = function() return false end
                hawkEye.GetSpectatorCount = function() return 0 end
            end
        end
        if _G.GameplayCallbacks then
            KillTable(_G.GameplayCallbacks, {
                "SendDSErrorLogToLobby", "SendDSHawkEyePatrolLogToLobby", "ReportMatchRoomData"
            })
        end
    end)
    _G.BYPASS_STATE.HAWKEYE_DISABLED = true
end

local function BypassVoklai()
    if _G.BYPASS_STATE.VOKLAI_DISABLED then return end
    pcall(function()
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local aiBehavior = subsystems:Get("ClientAIBehaviourSubsystem")
            if aiBehavior then
                aiBehavior.GetBehaviorScore = function() return math.random(10, 30) end
                aiBehavior.IsSuspicious = function() return false end
                aiBehavior.GetRiskLevel = function() return 0 end
            end
            local stepCheck = subsystems:Get("ClientStepCheckSubsystem")
            if stepCheck then
                stepCheck.GetStepDelta = function() return math.random(5, 50) end
                stepCheck.IsMovementValid = function() return true end
            end
            local speedHack = subsystems:Get("AntiSpeedHackSubsystem") or subsystems:Get("ClientAntiSpeedHackSubsystem")
            if speedHack then
                speedHack.GetSpeed = function() return math.random(300, 600) end
                speedHack.IsSpeedValid = function() return true end
            end
        end
    end)
    _G.BYPASS_STATE.VOKLAI_DISABLED = true
end

local function BypassHiggsBoson()
    if _G.BYPASS_STATE.HIGGSBOSON_DISABLED then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
        local higgsComponent = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if higgsComponent then
            higgsComponent.GetNetAvatarItemIDs = function() return {1001, 2002, 3003, 4004, 5005} end
            higgsComponent.GetCurWeaponSkinID = function() return 6001 end
            higgsComponent.GetCurItemIDs = function() return {7001, 8002} end
            if higgsComponent.BlackList then higgsComponent.BlackList = {} end
        end
        _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
        local mt = getmetatable(_G.GlobalPlayerCoronaData) or {}
        mt.__newindex = function() end
        setmetatable(_G.GlobalPlayerCoronaData, mt)
        _G.BlackList = {}
    end)
    _G.BYPASS_STATE.HIGGSBOSON_DISABLED = true
end

local function BypassHashVerification()
    if _G.BYPASS_STATE.HASH_VERIFY_DISABLED then return end
    pcall(function()
        if _G.TssSdk then
            _G.TssSdk.ScanMemory = function() return true, {code = 0, msg = "clean"} end
            _G.TssSdk.ScanSo = function() return true, {code = 0, msg = "clean"} end
            _G.TssSdk.ScanFile = function() return true, {code = 0} end
            _G.TssSdk.GetRiskFlag = function() return 0 end
            _G.TssSdk.VerifyFileHash = function() return true end
        end
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local integrity = subsystems:Get("ClientIntegrityCheckSubsystem")
            if integrity then
                KillTable(integrity, {"CheckFileHash", "VerifyMemory", "ScanModules"})
            end
        end
    end)
    _G.BYPASS_STATE.HASH_VERIFY_DISABLED = true
end

local function BypassIPMapping()
    if _G.BYPASS_STATE.IP_MAPPING_DISABLED then return end
    pcall(function()
        if _G.GameplayCallbacks then
            KillTable(_G.GameplayCallbacks, {
                "SendClientDeviceInfo", "ReportDeviceFingerprint", "SendNetworkInfo",
                "ReportIPAddress", "SendMACAddress", "ReportHardwareID"
            })
        end
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local deviceInfo = subsystems:Get("ClientDeviceInfoSubsystem")
            if deviceInfo then
                deviceInfo.GetDeviceID = function() return FakeData.deviceID() end
                deviceInfo.GetIPAddress = function() return FakeData.ipAddress() end
                deviceInfo.GetMACAddress = function() return FakeData.macAddress() end
            end
        end
    end)
    _G.BYPASS_STATE.IP_MAPPING_DISABLED = true
end

local function BypassMemoryPatching()
    if _G.BYPASS_STATE.MEMORY_PATCH_DISABLED then return end
    pcall(function()
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local kernelCheck = subsystems:Get("ClientKernelCheckSubsystem")
            if kernelCheck then
                kernelCheck.IsKernelClean = function() return true end
                kernelCheck.GetKernelVersion = function() return FakeData.kernelVersion() end
                kernelCheck.IsBootloaderLocked = function() return true end
            end
            local memoryGuard = subsystems:Get("ClientMemoryGuardSubsystem")
            if memoryGuard then
                memoryGuard.IsMemoryClean = function() return true, {code = 0} end
                memoryGuard.ScanResult = function() return "clean" end
            end
        end
        if _G.TssSdk then
            _G.TssSdk.CheckKernel = function() return true, {status = "verified", tampered = false} end
            _G.TssSdk.VerifyBoot = function() return true, {locked = true, verified = true} end
        end
    end)
    _G.BYPASS_STATE.MEMORY_PATCH_DISABLED = true
end

local function BypassEduEye()
    if _G.BYPASS_STATE.EDU_EYE_DISABLED then return end
    pcall(function()
        local subsystems = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subsystems then
            local renderCheck = subsystems:Get("ClientRenderCheckSubsystem")
            if renderCheck then
                renderCheck.IsRenderClean = function() return true end
                renderCheck.GetRenderState = function() return "normal" end
            end
            local espDetection = subsystems:Get("ClientESPDetectionSubsystem")
            if espDetection then
                espDetection.HasESP = function() return false end
                espDetection.CheckOverlay = function() return "clean" end
            end
            local wallhackDetect = subsystems:Get("ClientWallhackDetectionSubsystem")
            if wallhackDetect then
                wallhackDetect.IsVisionNormal = function() return true end
                wallhackDetect.GetVisibilityRate = function() return math.random(60, 85) end
            end
        end
    end)
    _G.BYPASS_STATE.EDU_EYE_DISABLED = true
end

local function ApplyAllBypasses()
    if _G.BYPASS_STATE.FULL_BYPASS_ACTIVE then return end
    pcall(function()
        BypassDeadEye()
        BypassHawkEye()
        BypassVoklai()
        BypassHiggsBoson()
        BypassHashVerification()
        BypassIPMapping()
        BypassMemoryPatching()
        BypassEduEye()
        _G.BYPASS_STATE.FULL_BYPASS_ACTIVE = true
    end)
end

function _G.GetBypassStatus()
    local state = _G.BYPASS_STATE
    return {
        deadEye = state.DEADEYE_DISABLED,
        hawkEye = state.HAWKEYE_DISABLED,
        voklai = state.VOKLAI_DISABLED,
        higgsBoson = state.HIGGSBOSON_DISABLED,
        hashVerify = state.HASH_VERIFY_DISABLED,
        ipMapping = state.IP_MAPPING_DISABLED,
        memoryPatch = state.MEMORY_PATCH_DISABLED,
        eduEye = state.EDU_EYE_DISABLED,
        fullBypass = state.FULL_BYPASS_ACTIVE
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

pcall(function() ApplyAllBypasses() end)

-- AUTO-ACTIVATE BYPASS MONITOR (Ensures bypasses stay active throughout game session)
pcall(function()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if pc and pc.AddGameTimer then
        pc:AddGameTimer(2.0, true, function()
            if not _G.BYPASS_STATE.FULL_BYPASS_ACTIVE then
                pcall(function() ApplyAllBypasses() end)
            end
        end)
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
        local tlogPaths = {
            "client.slua.config.tlog.tlog_report_utils",
            "client.network.Protocol.ClientTlogHandler",
            "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem"
        }
        for _, path in ipairs(tlogPaths) do
            local mod = package.loaded[path]
            if mod then
                for k, v in pairs(mod) do
                    if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Log")) then
                        pcall(function() mod[k] = nop end)
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
finalStart()

-- ==================== WALLHACK ====================
local function ApplyWallHack(localPlayer, enemy, pc)
    if not _G.CheatsEnabled then return end
    if _G.Mod_Wallhack_Enabled == false then return end
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
                local ok, mat = pcall(function() return comp:GetMaterial(0) end)
                if ok and slua.isValid(mat) then
                    local ok2, base = pcall(function() return mat:GetBaseMaterial() end)
                    if ok2 and slua.isValid(base) then
                        base.bDisableDepthTest = true
                        base.BlendMode = 2
                    end
                end
                comp.UseScopeDistanceCulling = false
                comp.PrimitiveShadingStrategy = 1
                comp.ShadingRate = 6
            end
        end
        local isVisible = false
        if slua.isValid(pc) and slua.isValid(enemy) and type(pc.LineOfSightTo) == "function" then
            pcall(function() isVisible = pc:LineOfSightTo(enemy) end)
        end
        local finalColor = isVisible and {R=1,G=25,B=25,A=1} or {R=25,G=1,B=25,A=1}
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
                            mid:SetVectorParameterValue("颜色", finalColor)
                            mid:SetVectorParameterValue("Color", finalColor)
                            mid:SetVectorParameterValue("BaseColor", finalColor)
                            mid:SetVectorParameterValue("BodyColor", finalColor)
                            mid:SetVectorParameterValue("DiffuseColor", finalColor)
                            mid:SetVectorParameterValue("ParaScaleOffset", scale)
                        end)
                    end
                end
            end
        end
    end)
end

-- ==================== AIMBOT ====================
local pc = slua_GameFrontendHUD:GetPlayerController()
_G._AimbotCurrentPC = nil

local function ApplyHardAimbot()
    if not _G.CheatsEnabled then return end
    if _G.Mod_Aimbot_Enabled == false then return end
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

        -- Use slider value to adjust aimbot strength (0-100)
        local strengthMul = (_G.Mod_AimbotStrength or 50) / 100
        
        entity.GameDeviationFactor = 0.5 * (1 - strengthMul * 0.7)
        entity.WeaponAimInTime = 20
        entity.SwitchFromIdleToBackpackTime = 0.15
        entity.SwitchFromBackpackToIdleTime = 0.15
        entity.ShotGunHorizontalSpread = 0.0
        entity.ShotGunVerticalSpread = 0.0
        entity.RecoilKick = 0.2 * (1 - strengthMul * 0.6)
        entity.RecoilKickADS = 0.2 * (1 - strengthMul * 0.6)
        entity.AnimationKick = 0.2 * (1 - strengthMul * 0.6)
        entity.AccessoriesVRecoilFactor = 0.6 * (1 - strengthMul * 0.4)
        entity.AccessoriesHRecoilFactor = 0.6 * (1 - strengthMul * 0.4)
        entity.GameDeviationFactor = 0.3 * (1 - strengthMul * 0.7)
        if entity.RecoilInfo then
            entity.RecoilInfo.VerticalRecoilMin = 0.2 * (1 - strengthMul * 0.5)
            entity.RecoilInfo.VerticalRecoilMax = 0.2 * (1 - strengthMul * 0.5)
            entity.RecoilInfo.RecoilSpeedVertical = 0.2 * (1 - strengthMul * 0.5)
            entity.RecoilInfo.RecoilSpeedHorizontal = 0.15 * (1 - strengthMul * 0.5)
            entity.RecoilInfo.VerticalRecoveryMax = 0.2 * (1 - strengthMul * 0.5)
        end
        entity.RecoilModifierStand = 0.2 * (1 - strengthMul * 0.5)
        entity.RecoilModifierCrouch = 0.2 * (1 - strengthMul * 0.5)
        entity.RecoilModifierProne = 0.2 * (1 - strengthMul * 0.5)
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 8 * strengthMul
                    cfg.RangeRate = 2 * strengthMul
                    cfg.SpeedRate = 5 * strengthMul
                    cfg.RangeRateSight = 2 * strengthMul
                    cfg.SpeedRateSight = 4 * strengthMul
                    cfg.CrouchRate = 4 * strengthMul
                    cfg.ProneRate = 4 * strengthMul
                    cfg.DyingRate = 0

                    cfg.adsorbMaxRange = 200 * strengthMul
                    cfg.adsorbMinRange = 20
                    cfg.adsorbMinAttenuationDis = 100 * (1 - strengthMul * 0.5)
                    cfg.adsorbMaxAttenuationDis = 8000
                    cfg.adsorbActiveMinRange = 20
                end
            end
            entity.AutoAimingConfig = entity.AutoAimingConfig
        end

        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C
                         or char.BP_AutoAimingComponent
                         or char.AutoAimingComponent

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

AttachAimbotTimer()

pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(2.0, true, function()
            if not isValid(_G._AimbotCurrentPC) then
                _G._AimbotCurrentPC = nil
                AttachAimbotTimer()
            end
        end)
    end
end)

-- ==================== WALLHACK LOOP (applies to all enemies) ====================
pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(0.5, true, function()
            if not _G.CheatsEnabled then return end
            if _G.Mod_Wallhack_Enabled == false then return end
            pcall(function()
                local pc = slua_GameFrontendHUD:GetPlayerController()
                if not isValid(pc) then return end
                local char = pc:GetPlayerCharacterSafety()
                if not isValid(char) then return end
                local allPawns = Game:GetAllPlayerPawns() or {}
                for _, enemy in pairs(allPawns) do
                    if isValid(enemy) and enemy ~= char and enemy.TeamID ~= char.TeamID then
                        ApplyWallHack(char, enemy, pc)
                    end
                end
            end)
        end)
    end
end)

-- ==================== IN-GAME MOD MENU (Only Aimbot + Wallhack) ====================
pcall(function()
    local function nop() end

    local function InitModMenuTab()
        local LocUtil = _G.LocUtil
        if not LocUtil and package.loaded["client.common.LocUtil"] then
            LocUtil = require("client.common.LocUtil")
        end
        
        if LocUtil and not LocUtil._IsModMenuHooked then
            local old_get = LocUtil.GetLocalizeResStr
            LocUtil.GetLocalizeResStr = function(id)
                if type(id) == "string" and not tonumber(id) then
                    return id
                end
                return old_get(id)
            end
            LocUtil._IsModMenuHooked = true
        end

        local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
        local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
        
        if not SettingPageDefine.ModMenu then
            local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
            
            local ModMenuStack = {
                { UI = AliasMap.Title, Text = "SETTING" },
                {
                    Key = "ModMenu_Aimbot",
                    UI = AliasMap.Switcher,
                    Text = "AIMBOT",
                    GetFunc = function() 
                        return _G.Mod_Aimbot_Enabled or false
                    end,
                    SetFunc = function(_, value)
                        _G.Mod_Aimbot_Enabled = value
                        print("[MOD] AIMBOT: " .. (value and "ON ✓" or "OFF ✗"))
                        return true
                    end
                },
                {
                    Key = "ModMenu_AimbotStrength",
                    UI = AliasMap.Slider,
                    Text = "Aimbot Strength",
                    GetFunc = function() 
                        return (_G.Mod_AimbotStrength or 50) / 100
                    end,
                    SetFunc = function(_, value)
                        _G.Mod_AimbotStrength = math.floor(value * 100)
                        print("[MOD] Aimbot Strength: " .. _G.Mod_AimbotStrength .. "%")
                        return true
                    end
                },
                {
                    Key = "ModMenu_Wallhack",
                    UI = AliasMap.Switcher,
                    Text = "WALLHACK",
                    GetFunc = function() 
                        return _G.Mod_Wallhack_Enabled or false
                    end,
                    SetFunc = function(_, value)
                        _G.Mod_Wallhack_Enabled = value
                        print("[MOD] WALLHACK: " .. (value and "ON ✓" or "OFF ✗"))
                        return true
                    end
                }
            }
            
            SettingPageDefine.ModMenu = {
                Key = "ModMenu",
                loc = "MOD MENU",
                UIKey = "Setting_Page_Privacy", 
                Category = {
                    {
                        Key = "ModMenu_Main",
                        loc = "FEATURES", 
                        Stack = ModMenuStack
                    }
                }
            }
            
            table.insert(SettingCatalog, SettingPageDefine.ModMenu)
        end

        local UIManager = _G.UIManager
        if UIManager and not UIManager._IsModMenuHooked then
            local old_ShowUI = UIManager.ShowUI
            UIManager.ShowUI = function(config, ...)
                local args = {...}
                if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                    local catalog = args[1]
                    if catalog and (type(catalog) == "table" or type(catalog) == "userdata") then
                        local hasModMenu = false
                        local newCatalog = {}
                        for _, page in ipairs(catalog) do
                            table.insert(newCatalog, page)
                            if page.Key == "ModMenu" then
                                hasModMenu = true
                            end
                        end
                        
                        if not hasModMenu then
                            table.insert(newCatalog, SettingPageDefine.ModMenu)
                            args[1] = newCatalog
                        end
                    end
                end
                local table_unpack = table.unpack or unpack
                return old_ShowUI(config, table_unpack(args))
            end
            UIManager._IsModMenuHooked = true
        end
    end

    local bypassInit = function()
        pcall(function()
            InitModMenuTab()
        end)
    end

    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(3.0, false, bypassInit)
    else
        bypassInit()
    end
end)
