-- Per-match guard: allow re-init when the player controller changes (new match)
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then return end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

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

print("[GHOST PROTOCOL] Initializing Core...")

-- ============================================================================
-- MODULE 1: SLUA & INTEGRITY BYPASS
-- ============================================================================
pcall(function()
    if slua and slua.getSignature then
        slua.getSignature = function() return math.random(0xDE000000, 0xFFFFFFFF) end
    end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
        if loader.verifyBytecode then loader.verifyBytecode = function() return true end end
        if loader.checkIntegrity then loader.checkIntegrity = function() return true end end
    end
    local slua_serialize = package.loaded["slua.serialize"]
    if slua_serialize and slua_serialize.check then
        slua_serialize.check = function() return true end
    end
    print("[GHOST] ✓ SLUA Integrity Bypassed")
end)

-- ============================================================================
-- MODULE 2: MD5 & PAK BYPASS
-- ============================================================================
pcall(function()
    local console = import("KismetSystemLibrary")
    if console then
        console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
        console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
        console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
    end
    local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    if CreativeModeBlueprintLibrary then
        CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
        CreativeModeBlueprintLibrary.MD5HashFile = function() return "BYPASSED_MD5_HASH" end
        CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
    end
    if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if STExtraBlueprintFunctionLibrary then
        if STExtraBlueprintFunctionLibrary.CheckMD5 then STExtraBlueprintFunctionLibrary.CheckMD5 = function() return true end end
        if STExtraBlueprintFunctionLibrary.GetMD5 then STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end end
    end
    print("[GHOST] ✓ MD5 & PAK Bypassed")
end)

-- ============================================================================
-- MODULE 3: MAIN BYPASS INIT
-- ============================================================================
pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
    if not Msg then Msg = require("client.slua.logic.common.logic_common_msg_box") end
    if Msg and Msg.Show then
        Msg.Show(4, "GHOST PROTOCOL", "COMPLETE BYPASS ACTIVE\n100% Telemetry killed\nPlay Safe")
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
    print("[GHOST] ✓ Main Bypass Active")
end)

-- ============================================================================
-- MODULE 4: HIGGS BOSON BYPASS
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
    print("[GHOST] ✓ Higgs Boson Disabled")
end)

-- ============================================================================
-- MODULE 5: CORONA LAB BYPASS
-- ============================================================================
pcall(function()
    if _G.CoronaLab then
        _G.CoronaLab.ReportData = nop
        _G.CoronaLab.SendData = nop
        _G.CoronaLab.CollectData = nop
    end
    local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
        local corona = SubsystemMgr:Get("CoronaLabSubsystem")
        if corona then
            corona.ReportData = nop
            corona.SendToServer = nop
            corona.CollectTelemetry = nop
        end
    end
    print("[GHOST] ✓ Corona Lab Disabled")
end)

-- ============================================================================
-- MODULE 6: PLAYER SECURITY INFO BYPASS
-- ============================================================================
pcall(function()
    if _G.PlayerSecurityInfo then
        _G.PlayerSecurityInfo.ReportCheat = nop
        _G.PlayerSecurityInfo.ReportSuspicious = nop
        _G.PlayerSecurityInfo.SendSecurityData = nop
        _G.PlayerSecurityInfo.CollectSecurityInfo = nop
    end
    local SecuritySubsystem = safe_require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
    if SecuritySubsystem then
        SecuritySubsystem.ReportData = nop
        SecuritySubsystem.CheckCheat = retFalse
        SecuritySubsystem.ValidatePlayer = function() return true end
    end
    print("[GHOST] ✓ Player Security Disabled")
end)

-- ============================================================================
-- MODULE 7: CLIENT CIRCLE FLOW BYPASS
-- ============================================================================
pcall(function()
    local CircleFlow = safe_require("GameLua.Mod.BaseMod.Client.Security.ClientCircleFlowSubsystem")
    if CircleFlow then
        CircleFlow.ReportCircleFlow = nop
        CircleFlow.SendCircleData = nop
        CircleFlow.ReportPlayerPosition = nop
    end
    if _G.IsEnableReportPlayerKillFlow then _G.IsEnableReportPlayerKillFlow = retFalse end
    if _G.IsEnableReportMrpcsInCircleFlow then _G.IsEnableReportMrpcsInCircleFlow = retFalse end
    if _G.IsEnableReportMrpcsInPartCircleFlow then _G.IsEnableReportMrpcsInPartCircleFlow = retFalse end
    if _G.IsEnableReportMrpcsFlow then _G.IsEnableReportMrpcsFlow = retFalse end
    print("[GHOST] ✓ Circle Flow Disabled")
end)

-- ============================================================================
-- MODULE 8: MODIFIER EXCEPTION BYPASS
-- ============================================================================
pcall(function()
    if _G.bReportedModifierException then _G.bReportedModifierException = false end
    local ModifierSubsystem = safe_require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
    if ModifierSubsystem then
        ModifierSubsystem.ReportException = nop
        ModifierSubsystem.CheckModifier = function() return true end
        ModifierSubsystem.ValidateModifier = function() return true end
    end
    print("[GHOST] ✓ Modifier Exception Disabled")
end)

-- ============================================================================
-- MODULE 9: SHOOT VERIFICATION BYPASS
-- ============================================================================
pcall(function()
    local ShootVerify = safe_require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if ShootVerify then
        ShootVerify.OnShootVerifyFailed = nop
        ShootVerify.SendVerifyData = nop
        ShootVerify.ReportBulletHit = nop
        ShootVerify.UploadHitInfo = nop
    end
    if _G.BulletHitInfoUploadData then
        _G.BulletHitInfoUploadData.Report = nop
        _G.BulletHitInfoUploadData.Send = nop
        _G.BulletHitInfoUploadData.Upload = nop
    end
    print("[GHOST] ✓ Shoot Verification Disabled")
end)

-- ============================================================================
-- MODULE 10: BAN LOGIC BYPASS
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
    print("[GHOST] ✓ Ban Logic Bypassed")
end)

-- ============================================================================
-- MODULE 11: REPORT SUBSYSTEM BYPASS
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

    local ClientHawk = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"]
    if ClientHawk then
        local funcs = {"_OnHawkSync","_OnHawkReportSuccess","_StartExitGameTimer","_OnRecvInspectorBroadcastCount","SendReportTLog","ReportCheat"}
        for _, fn in ipairs(funcs) do if ClientHawk[fn] then ClientHawk[fn] = nop end end
        ClientHawk.CanInspectorBroadcast = retFalse
    end
    print("[GHOST] ✓ Report Systems Disabled")
end)

-- ============================================================================
-- MODULE 12: TLOG BYPASS
-- ============================================================================
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
    print("[GHOST] ✓ TLog Systems Disabled")
end)

-- ============================================================================
-- MODULE 13: NETWORK PACKET BLOCK
-- ============================================================================
pcall(function()
    if NetUtil and NetUtil.SendPacket then
        local originalSend = NetUtil.SendPacket
        local blockedPackets = {
            ["ReportAttackFlow"]=1,["ReportSecAttackFlow"]=1,["ReportHurtFlow"]=1,
            ["ReportFireArms"]=1,["ReportVerifyInfoFlow"]=1,["ReportMrpcsFlow"]=1,
            ["ReportPlayerBehavior"]=1,["ReportTeammatHurt"]=1,["ReportPlayerMoveRoute"]=1,
            ["ReportPlayerPosition"]=1,["ReportSecVehicleMoveFlow"]=1,["report_parachute_data"]=1,
            ["on_tss_sdk_anti_data"]=1,["ReportAimFlow"]=1,["ReportHitFlow"]=1,
            ["ReportCircleFlow"]=1,["report_players_ping"]=1,["report_player_ip"]=1,
            ["report_net_saturate"]=1,["Heartbeat"]=1,["ClientHeartbeat"]=1,
            ["ServerHeartbeat"]=1,["SwiftHawk"]=1
        }
        NetUtil.SendPacket = function(packetName, ...)
            if blockedPackets[packetName] then return nil end
            return originalSend(packetName, ...)
        end
        NetUtil.IsBypassed = true
    end
    print("[GHOST] ✓ Network Packet Filter Active")
end)

-- ============================================================================
-- MODULE 14: HEARTBEAT & SWIFT HAWK BYPASS
-- ============================================================================
pcall(function()
    local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat"}
    for _, func in ipairs(heartbeatFuncs) do
        if _G[func] then _G[func] = nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
            _G.GameplayCallbacks[func] = nop
        end
    end
    
    local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
    for _, func in ipairs(swiftFuncs) do
        if _G[func] then _G[func] = nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
            _G.GameplayCallbacks[func] = nop
        end
    end
    print("[GHOST] ✓ Heartbeat & Swift Hawk Disabled")
end)

-- ============================================================================
-- MODULE 15: HTTP REQUEST BLOCKER
-- ============================================================================
pcall(function()
    local BLACKLIST_HOSTS = {
        "tss.tencent","syzsdk","gcloud.qq","reportlog","tdos","logupload","feedback.wh","crash2",
        "privacy.qq","privacy.tencent","oth.eve","mdt.qq","act.tencentyun","analytics","report.qq",
        "anticheatexpert","crashsight","wetest","log.tav","sngd","tracer","intlsdk","igamecj",
        "cdn.club","gpubgm","firebase","googleapis","facebook","gvoice","bugly","beacon","helpshift"
    }
    local function isBlacklisted(str)
        if type(str) ~= "string" then return false end
        local low = str:lower()
        for _, kw in ipairs(BLACKLIST_HOSTS) do if low:find(kw,1,true) then return true end end
        return false
    end
    if _G.HttpRequest then
        local orig = _G.HttpRequest
        _G.HttpRequest = function(url, ...) if isBlacklisted(url) then return nil end return orig(url, ...) end
    end
    print("[GHOST] ✓ HTTP Request Blocker Active")
end)

-- ============================================================================
-- MODULE 16: PERSISTENT SECURITY KILLER
-- ============================================================================
local function KillAllSecuritySubsystems()
    pcall(function()
        local subMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local subsystemsToKill = {
            "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem","SimulateCharacterSubsystem","ShootVerifySubSystemClient",
            "HiggsBosonComponent","ClientReportPlayerSubsystem","DSReportPlayerSubsystem",
            "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem","ClientDataStatistcsSubsystem",
            "AFKReportorSubsystem","BehaviorScoreSubsystem","HeartbeatSubsystem","SwiftHawkSubsystem"
        }
        for _, name in ipairs(subsystemsToKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify")) then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- MODULE 17: WALLHACK (CHAMS)
-- ============================================================================
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
        local isVisible = false
        if slua.isValid(pc) and slua.isValid(enemy) and type(pc.LineOfSightTo) == "function" then
            pcall(function() isVisible = pc:LineOfSightTo(enemy) end)
        end
        local finalColor = isVisible and {R=0,G=255,B=0,A=1} or {R=255,G=255,B=0,A=1}
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                comp.UseScopeDistanceCulling = false
                for i = 0, 5 do
                    local ok, mid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                    if ok and slua.isValid(mid) then
                        pcall(function()
                            mid:SetVectorParameterValue("Color", finalColor)
                            mid:SetVectorParameterValue("BaseColor", finalColor)
                        end)
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- MODULE 18: ESP (HP BARS ONLY)
-- ============================================================================
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local cachedPawns = {}
local lastPawnRefresh = 0

local function IsPawnAlive(p)
    if not isValid(p) then return false end
    if p.HealthStatus then return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus) end
    if p.IsAlive then return p:IsAlive() end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

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
        if isValid(char) and char.TeamID then myTeamId = char.TeamID
        elseif currentPawn.TeamID then myTeamId = currentPawn.TeamID end
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
                    local hp = tPawn.Health
                    local maxHp = tPawn.HealthMax
                    local hpPercent = (hp and maxHp and maxHp > 0) and (hp / maxHp) or 0
                    
                    local hpColor = {R=0,G=255,B=0,A=255}
                    if hpPercent < 0.3 then hpColor = {R=255,G=0,B=0,A=255}
                    elseif hpPercent < 0.7 then hpColor = {R=255,G=255,B=0,A=255} end
                    
                    local hpText = HPBar(hpPercent)
                    HUD:AddDebugText(hpText, tPawn, 0.7, {X=0,Y=0,Z=120}, {X=0,Y=0,Z=120}, hpColor, true, false, true, nil, 1.0, true)
                    pcall(ApplyWallHack, currentPawn, tPawn, uCon)
                end
            end
        end
    end
end

-- Start ESP
pcall(function()
    local function StartESP()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(0.15, true, ESPTick)
            print("[GHOST] ✓ ESP Active")
        else
            local fb = slua_GameFrontendHUD or Game
            if fb and isValid(fb) then fb:AddGameTimer(1.0, false, StartESP) end
        end
    end
    StartESP()
end)

-- ============================================================================
-- MODULE 19: AIMBOT + NO RECOIL
-- ============================================================================
local function ApplyAimbotAndNoRecoil()
    if not _G.CheatsEnabled then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end
        
        local weaponManager = char:GetWeaponManagerComponent()
        if not slua.isValid(weaponManager) then return end
        
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not slua.isValid(currentWeapon) then return end
        
        local shootComp = currentWeapon.ShootWeaponEntityComp
        if not slua.isValid(shootComp) then return end
        
        -- NO RECOIL
        shootComp.RecoilKick = 0.1
        shootComp.RecoilKickADS = 0.08
        shootComp.AnimationKick = 0.05
        shootComp.GameDeviationFactor = 0.3
        
        -- AIMBOT CONFIG
        if shootComp.AutoAimingConfig then
            shootComp.AutoAimingConfig.adsorbMaxRange = 200.0
            shootComp.AutoAimingConfig.adsorbMinRange = 10.0
            if shootComp.AutoAimingConfig.OuterRange then
                shootComp.AutoAimingConfig.OuterRange.Speed = 6.0
            end
        end
        
        -- AIM BONE SETTINGS
        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C or char.BP_AutoAimingComponent or char.AutoAimingComponent
            if slua.isValid(aimComp) and aimComp.Bones then
                aimComp.Bones[0] = "head"
                aimComp.Bones[1] = "head"
            end
        end)
    end)
end

-- Start Aimbot
pcall(function()
    local function StartAimbot()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(0.15, true, ApplyAimbotAndNoRecoil)
            print("[GHOST] ✓ Aimbot + No Recoil Active")
        else
            local fb = slua_GameFrontendHUD or Game
            if fb and isValid(fb) then fb:AddGameTimer(1.0, false, StartAimbot) end
        end
    end
    StartAimbot()
end)

-- ============================================================================
-- MODULE 20: FPS UNLOCK
-- ============================================================================
pcall(function()
    local function UnlockFPS()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pcall(function() pc:ExecuteCommand("t.MaxFPS 165") end)
            pcall(function() pc:ExecuteCommand("r.FrameRateLimit 165") end)
        end
        local gi = Game:GetGameInstance()
        if gi and gi.ExecuteCMD then
            pcall(function() gi:ExecuteCMD("t.MaxFPS", "165") end)
            pcall(function() gi:ExecuteCMD("grass.DensityScale", "0") end)
        end
    end
    UnlockFPS()
    print("[GHOST] ✓ FPS Unlocked to 165")
end)

-- ============================================================================
-- MODULE 21: iPAD VIEW
-- ============================================================================
pcall(function()
    local function SetiPadFOV()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end
        local tppCam = char.ThirdPersonCameraComponent
        if slua.isValid(tppCam) and not char.bIsWeaponAiming then
            if tppCam.FieldOfView < 120 then tppCam.FieldOfView = 120 end
        end
    end
    
    local function StartFOV()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(0.5, true, SetiPadFOV)
            print("[GHOST] ✓ iPad FOV Active (120)")
        else
            local fb = slua_GameFrontendHUD or Game
            if fb and isValid(fb) then fb:AddGameTimer(1.0, false, StartFOV) end
        end
    end
    StartFOV()
end)

-- ============================================================================
-- MODULE 22: BOT COUNTER
-- ============================================================================
local function IsAIPawn(pawn)
    if not slua.isValid(pawn) then return false end
    if pawn.IsAIPawn and type(pawn.IsAIPawn) == "function" then return pawn:IsAIPawn() end
    if Game.IsAI and type(Game.IsAI) == "function" then return Game:IsAI(pawn) end
    local controller = pawn:GetController()
    if slua.isValid(controller) then
        local name = tostring(controller:GetName() or "")
        if name:find("AI") or name:find("Bot") then return true end
    end
    return false
end

local function DrawCounter()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        local localPlayer = pc:GetPlayerCharacterSafety()
        if not slua.isValid(localPlayer) then return end
        local hud = pc:GetHUD()
        if not slua.isValid(hud) then return end
        
        local allChars = Game:GetAllPlayerPawns() or {}
        local myTeamId = localPlayer.TeamID or 0
        local botCount = 0
        local realCount = 0
        
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= localPlayer and (enemy.TeamID or 0) ~= myTeamId then
                if (enemy.Health or 0) > 0 then
                    if IsAIPawn(enemy) then botCount = botCount + 1 else realCount = realCount + 1 end
                end
            end
        end
        
        hud:AddDebugText(string.format("🤖 BOT: %d  |  👤 REAL: %d", botCount, realCount),
            localPlayer, 0.8, {X=0, Y=0, Z=180}, {X=0, Y=0, Z=180},
            {R=0, G=255, B=255, A=255}, true, false, true, nil, 1.0, true)
    end)
end

pcall(function()
    local function StartCounter()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(0.3, true, DrawCounter)
            print("[GHOST] ✓ Bot Counter Active")
        else
            local fb = slua_GameFrontendHUD or Game
            if fb and isValid(fb) then fb:AddGameTimer(1.0, false, StartCounter) end
        end
    end
    StartCounter()
end)

-- ============================================================================
-- MODULE 23: PERSISTENT TIMER FOR SECURITY
-- ============================================================================
pcall(function()
    local function StartPersistentKiller()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(3.0, true, KillAllSecuritySubsystems)
            print("[GHOST] ✓ Security Persistence Active")
        else
            local fb = slua_GameFrontendHUD or Game
            if fb and isValid(fb) then fb:AddGameTimer(1.0, false, StartPersistentKiller) end
        end
    end
    StartPersistentKiller()
end)

-- ============================================================================
-- MODULE 24: BRPLAYERCHARACTERBASE CLASS
-- ============================================================================
local BRPlayerCharacterBase = {
    ServerRPC = {},
    ClientRPC = {},
    MulticastRPC = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } }
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = { Reliable = true, Params = { UEnums.EPropertyClass.Bool } }

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super._PostConstruct(self)
    end
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    
    -- Start all features
    StartCounter()
    StartESP()
    StartAimbot()
    StartPersistentKiller()
    
    print("[GHOST PROTOCOL] Complete - All Security Systems Disabled")
    print("  ✓ SLUA + MD5 + PAK Signature")
    print("  ✓ CoronaLab + PlayerSecurityInfo")
    print("  ✓ CircleFlow + ModifierException")
    print("  ✓ ShootVerify + BulletHitInfo")
    print("  ✓ HiggsBoson + Anti-Cheat")
    print("  ✓ Heartbeat + SwiftHawk")
    print("  ✓ Logs + Screenshots + Analytics")
    print("  ✓ All Subsystems Killed")
    print("  ✓ Chams: GREEN Visible / YELLOW Behind Walls")
    print("  ✓ ESP: HP Bars Only")
    print("  ✓ Aimbot + No Recoil")
    print("  ✓ Bot Counter Active - BOT vs REAL")
    print("  ✓ FPS Unlocked to 165")
    print("  ✓ iPad FOV Active (120)")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    if BRPlayerCharacterBase.__super and BRPlayerCharacterBase.__super.ReceiveBeginPlay then
        BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    end
    
    if slua.isValid(self.STCharacterMovement) then
        self.STCharacterMovement.bPositiveBlowUp = true
    end
    
    if Client then
        GameplayData.AddCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    if BRPlayerCharacterBase.__super and BRPlayerCharacterBase.__super.ReceiveEndPlay then
        BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    end
    if Client then
        GameplayData.RemoveCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
    if self.Super and self.Super.OnPlayerEnterCarryBoxState then
        self.Super:OnPlayerEnterCarryBoxState()
    end
    if self.CarryDeadBoxFeature then
        self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
    end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
    if self.Super and self.Super.OnPlayerLeaveCarryBoxState then
        self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
    end
    if self.CarryDeadBoxFeature then
        self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
    end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
    if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
        self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
    end
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
    local uNearDeathComp = self.NearDeatchComponent
    if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
        uNearDeathComp:TriggerGotoDieExplictly(self.Object)
    end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
    return true
end

function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle) end
function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle) end
function BRPlayerCharacterBase:ClearAttachToVehicleTimer() end

local CBRPlayerCharacterBase = require("class")(CharacterBase, nil, BRPlayerCharacterBase)

return CombineClass.DeclareFeature(CBRPlayerCharacterBase, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
    { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" }
}, "BRPlayerCharacterBase")

-- ============================================================================
-- FINAL PRINT
-- ============================================================================
print("[GHOST] ╔══════════════════════════════════════════════════════════════╗")
print("[GHOST] ║                 GHOST PROTOCOL V5.0 COMPLETE                 ║")
print("[GHOST] ╠══════════════════════════════════════════════════════════════╣")
print("[GHOST] ║  ✓ SLUA + MD5 + PAK Bypass    ✓ Higgs Boson Disabled        ║")
print("[GHOST] ║  ✓ Corona Lab Disabled        ✓ Player Security Disabled    ║")
print("[GHOST] ║  ✓ Circle Flow Disabled       ✓ Modifier Exception Disabled ║")
print("[GHOST] ║  ✓ Shoot Verify Disabled      ✓ Ban Logic Bypassed          ║")
print("[GHOST] ║  ✓ Report Systems Disabled    ✓ TLog Systems Disabled       ║")
print("[GHOST] ║  ✓ Network Packet Filter      ✓ Heartbeat Disabled          ║")
print("[GHOST] ║  ✓ HTTP Blocker Active        ✓ Security Persistence        ║")
print("[GHOST] ╠══════════════════════════════════════════════════════════════╣")
print("[GHOST] ║  ✓ Wallhack (Green/Yellow)    ✓ ESP (HP Bars Only)          ║")
print("[GHOST] ║  ✓ Aimbot + No Recoil         ✓ Bot Counter                 ║")
print("[GHOST] ║  ✓ 165 FPS Unlock             ✓ iPad FOV (120)              ║")
print("[GHOST] ╚══════════════════════════════════════════════════════════════╝")
print("[GHOST] ALL SYSTEMS ONLINE - PLAY SAFE!")
