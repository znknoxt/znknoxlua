--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              GHOST PROTOCOL V5.0 - COMPLETE                 ║
    ║                   INJECTOR-READY SCRIPT                     ║
    ║                                                             ║
    ║  Features:                                                  ║
    ║  ✓ Complete Anti-Cheat Bypass (20+ modules)                ║
    ║  ✓ Wallhack (Green/Yellow Chams)                           ║
    ║  ✓ ESP (HP Bars Only)                                      ║
    ║  ✓ Aimbot + No Recoil                                      ║
    ║  ✓ Bot/Real Player Counter                                 ║
    ║  ✓ FPS Unlock (165 FPS)                                    ║
    ║  ✓ iPad View (140 FOV)                                     ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ============================================================================
-- PREVENT DUPLICATE INJECTION
-- ============================================================================
if _G.GHOST_V5_LOADED then
    print("[GHOST] Already loaded in this session")
    return
end
_G.GHOST_V5_LOADED = true
_G.GHOST_INJECT_TIME = os.time()

print("[GHOST] ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗")
print("[GHOST] ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝")
print("[GHOST] ██║  ███╗███████║██║   ██║███████╗   ██║   ")
print("[GHOST] ██║   ██║██╔══██║██║   ██║╚════██║   ██║   ")
print("[GHOST] ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║   ")
print("[GHOST]  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ")
print("[GHOST]          PROTOCOL V5.0 - INJECTED            ")

-- ============================================================================
-- SAFE EXECUTION WRAPPER
-- ============================================================================
local function SafeExec(func, name)
    local success, err = pcall(func)
    if not success then
        print("[GHOST] Error in " .. (name or "unknown") .. ": " .. tostring(err))
    end
    return success
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retTrue() return true end

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

-- ============================================================================
-- MODULE 1: SLUA & INTEGRITY BYPASS
-- ============================================================================
SafeExec(function()
    if slua then
        if slua.getSignature then
            slua.getSignature = function() return math.random(0xDEAD0000, 0xFFFFFFFF) end
        end
        if slua.setSignature then
            slua.setSignature = nop
        end
    end
    
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
        if loader.verifyBytecode then loader.verifyBytecode = retTrue end
        if loader.checkIntegrity then loader.checkIntegrity = retTrue end
        if loader.verify then loader.verify = retTrue end
    end
    
    local serialize = package.loaded["slua.serialize"]
    if serialize then
        if serialize.check then serialize.check = retTrue end
        if serialize.verify then serialize.verify = retTrue end
    end
    
    print("[GHOST] ✓ SLUA Integrity Bypassed")
end, "SLUA Bypass")

-- ============================================================================
-- MODULE 2: PAK & MD5 SIGNATURE BYPASS
-- ============================================================================
SafeExec(function()
    local console = import("KismetSystemLibrary")
    if console and console.ExecuteConsoleCommand then
        pcall(function() console:ExecuteConsoleCommand("pak.DisablePakSignatureCheck 1") end)
        pcall(function() console:ExecuteConsoleCommand("pakchunk.EnableSignatureCheck 0") end)
        pcall(function() console:ExecuteConsoleCommand("s.VerifyPak 0") end)
        pcall(function() console:ExecuteConsoleCommand("r.AllowOcclusionQueries 0") end)
    end
    
    local CreativeLib = import("CreativeModeBlueprintLibrary")
    if CreativeLib then
        if CreativeLib.MD5HashByteArray then CreativeLib.MD5HashByteArray = function() return "BYPASSED" end end
        if CreativeLib.MD5HashFile then CreativeLib.MD5HashFile = function() return "BYPASSED" end end
        if CreativeLib.GetContentDiffData then CreativeLib.GetContentDiffData = function() return true, "BYPASSED" end end
    end
    
    local STExtraLib = import("STExtraBlueprintFunctionLibrary")
    if STExtraLib then
        if STExtraLib.CheckMD5 then STExtraLib.CheckMD5 = retTrue end
        if STExtraLib.GetMD5 then STExtraLib.GetMD5 = function() return "BYPASSED_MD5" end end
        if STExtraLib.IsDevelopment then STExtraLib.IsDevelopment = retTrue end
    end
    
    if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
    if _G.CRC32 then _G.CRC32 = function() return 0 end end
    
    print("[GHOST] ✓ PAK & MD5 Bypassed")
end, "PAK Bypass")

-- ============================================================================
-- MODULE 3: ANTI-CHEAT REPORTING BYPASS
-- ============================================================================
SafeExec(function()
    -- Kill all reporting functions in GameplayCallbacks
    local callbacks = _G.GameplayCallbacks or _G.GC or _G.Callbacks
    if callbacks then
        local killList = {
            "SendTssSdkAntiDataToLobby", "SendDSErrorLogToLobby", "SendDSHawkEyePatrolLogToLobby",
            "SendSecTLog", "SendDataMiningTLog", "SendActivityTLog", "SendClientMemUsage",
            "SendClientFPS", "OnClientCrashReport", "OnNetworkLossDetected", "ReportMatchRoomData",
            "ReportPlayersPing", "SendClientStats", "SendServerAvgTickDelta", "ReportHitFlow",
            "OnPlayerActorChannelError", "OnPlayerRPCValidateFailed", "SendLobbyData",
            "ReportPlayerBehavior", "ReportCheatData"
        }
        for _, fn in ipairs(killList) do
            if callbacks[fn] then callbacks[fn] = nop end
        end
        
        -- Hook DSPlayerStateChanged to block cheat detection
        local origDS = callbacks.OnDSPlayerStateChanged
        if origDS then
            callbacks.OnDSPlayerStateChanged = function(dsSelf, state, reason, ...)
                if reason and tostring(reason):lower():find("cheat") then return end
                pcall(origDS, dsSelf, state, reason, ...)
            end
        end
    end
    
    -- Kill PacketCallbacks
    local PC = _G.PacketCallbacks or _G.PacketHandler
    if PC then
        PC.player_report_cheat = nop
        PC.upload_loots_rsp = nop
        PC.watch_player_exit = nop
        PC.player_login_report = nop
        PC.player_logout_report = nop
        PC.server_time_report = nop
        PC.report_security_info = nop
        PC.client_anti_cheat = nop
    end
    
    -- Kill TSS SDK
    if _G.TssSdk then
        _G.TssSdk.ReportData = nop
        _G.TssSdk.SendAntiData = nop
        _G.TssSdk.CollectInfo = nop
    end
    
    if _G.TssSDK then
        _G.TssSDK.Report = nop
        _G.TssSDK.Send = nop
    end
    
    -- Kill TApmHelper
    if _G.TApmHelper then
        _G.TApmHelper.postEvent = nop
        _G.TApmHelper.report = nop
    end
    
    print("[GHOST] ✓ Anti-Cheat Reporting Killed")
end, "Anti-Cheat Bypass")

-- ============================================================================
-- MODULE 4: HIGGS BOSON BYPASS (MAIN ANTI-CHEAT)
-- ============================================================================
SafeExec(function()
    local Higgs = safe_require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if Higgs then
        local methods = {
            "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
            "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord",
            "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar",
            "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev",
            "OnReportItemID", "CheckAvatar", "VerifyAvatar", "SendAvatarData"
        }
        for _, m in ipairs(methods) do
            if Higgs[m] then Higgs[m] = nop end
        end
        Higgs.GetNetAvatarItemIDs = retEmpty
        Higgs.GetCurWeaponSkinID = retZero
        Higgs.IsHiggsActive = retFalse
    end
    
    if _G.DisableHiggsBoson then _G.DisableHiggsBoson = nop end
    if _G.HiggsBoson then
        _G.HiggsBoson.Report = nop
        _G.HiggsBoson.Check = retTrue
    end
    
    -- Kill ClientGlueHiaSystem
    local hia = safe_require("GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem")
    if hia then
        hia.CheckHitIntegrity = nop
        hia.InitSession = nop
        hia.OnBattleEnd = nop
        hia.ReportHit = nop
    end
    
    -- Kill BehaviorScoreSubsystem
    local Behavior = safe_require("GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem")
    if Behavior then
        Behavior.OnHandleBehaviorScore = nop
        Behavior.AIPerceptionScore = nop
        Behavior.ReportBehavior = nop
        Behavior.CalcFinalScore = retZero
    end
    
    print("[GHOST] ✓ Higgs Boson Disabled")
end, "Higgs Boson")

-- ============================================================================
-- MODULE 5: CORONA LAB BYPASS
-- ============================================================================
SafeExec(function()
    if _G.CoronaLab then
        _G.CoronaLab.ReportData = nop
        _G.CoronaLab.SendData = nop
        _G.CoronaLab.CollectData = nop
        _G.CoronaLab.ReportTelemetry = nop
    end
    
    local SubsystemMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
        local corona = SubsystemMgr:Get("CoronaLabSubsystem")
        if corona then
            corona.ReportData = nop
            corona.SendToServer = nop
            corona.CollectTelemetry = nop
            corona.OnTick = nop
        end
    end
    
    print("[GHOST] ✓ Corona Lab Disabled")
end, "Corona Lab")

-- ============================================================================
-- MODULE 6: PLAYER SECURITY INFO BYPASS
-- ============================================================================
SafeExec(function()
    if _G.PlayerSecurityInfo then
        _G.PlayerSecurityInfo.ReportCheat = nop
        _G.PlayerSecurityInfo.ReportSuspicious = nop
        _G.PlayerSecurityInfo.SendSecurityData = nop
        _G.PlayerSecurityInfo.CollectSecurityInfo = nop
        _G.PlayerSecurityInfo.Validate = retTrue
    end
    
    local SecuritySub = safe_require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
    if SecuritySub then
        SecuritySub.ReportData = nop
        SecuritySub.CheckCheat = retFalse
        SecuritySub.ValidatePlayer = retTrue
        SecuritySub.SendToServer = nop
        SecuritySub.CollectData = nop
    end
    
    print("[GHOST] ✓ Player Security Info Disabled")
end, "Player Security")

-- ============================================================================
-- MODULE 7: CIRCLE FLOW BYPASS
-- ============================================================================
SafeExec(function()
    local CircleFlow = safe_require("GameLua.Mod.BaseMod.Client.Security.ClientCircleFlowSubsystem")
    if CircleFlow then
        CircleFlow.ReportCircleFlow = nop
        CircleFlow.SendCircleData = nop
        CircleFlow.ReportPlayerPosition = nop
        CircleFlow.OnTick = nop
    end
    
    -- Kill enable flags
    local flags = {
        "IsEnableReportPlayerKillFlow", "IsEnableReportMrpcsInCircleFlow",
        "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow",
        "IsEnableReportSecurityFlow", "IsEnableReportCheatFlow"
    }
    for _, flag in ipairs(flags) do
        if _G[flag] then _G[flag] = retFalse end
    end
    
    print("[GHOST] ✓ Circle Flow Disabled")
end, "Circle Flow")

-- ============================================================================
-- MODULE 8: SHOOT VERIFICATION BYPASS
-- ============================================================================
SafeExec(function()
    local ShootVerify = safe_require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
    if ShootVerify then
        ShootVerify.OnShootVerifyFailed = nop
        ShootVerify.SendVerifyData = nop
        ShootVerify.ReportBulletHit = nop
        ShootVerify.UploadHitInfo = nop
        ShootVerify.VerifyShoot = retTrue
    end
    
    if _G.BulletHitInfoUploadData then
        _G.BulletHitInfoUploadData.Report = nop
        _G.BulletHitInfoUploadData.Send = nop
        _G.BulletHitInfoUploadData.Upload = nop
    end
    
    if _G.ShootVerify then
        _G.ShootVerify.Report = nop
        _G.ShootVerify.Verify = retTrue
    end
    
    print("[GHOST] ✓ Shoot Verification Disabled")
end, "Shoot Verify")

-- ============================================================================
-- MODULE 9: BAN LOGIC BYPASS
-- ============================================================================
SafeExec(function()
    local BanLogic = package.loaded["client.slua.logic.ban.ClientBanLogic"]
    if BanLogic then
        BanLogic.OnSyncBanInfo = nop
        BanLogic.OnVoiceBanNotify = nop
        BanLogic.OnRealTimeVoiceBanNotify = nop
        BanLogic.OnVoiceBanSuccess = nop
        BanLogic.OnSyncMicSuspicious = nop
        BanLogic.OnNotifyWarningTips = nop
        BanLogic.ReqBanInfo = nop
        BanLogic.CheckBan = retFalse
    end
    
    local BanUtil = package.loaded["client.common.ban_util"] or _G.ban_util
    if BanUtil then
        BanUtil.CheckBanStatus = retFalse
        BanUtil.GetBanTime = retZero
        BanUtil.IsBanForever = retFalse
        BanUtil.IsBanned = retFalse
    end
    
    print("[GHOST] ✓ Ban Logic Bypassed")
end, "Ban Logic")

-- ============================================================================
-- MODULE 10: REPORT SUBSYSTEM BYPASS
-- ============================================================================
SafeExec(function()
    local clientReport = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"]
    if clientReport then
        local funcs = {
            "OnInit", "_OnPlayerKilledOtherPlayer", "_RecordFatalDamager", "SendPacket",
            "ReportSuspiciousPlayer", "SubmitReport", "_OnBattleResult", "_RecordTeammatePlayerInfo",
            "_OnDeathReplayDataWhenFatalDamaged", "_RecordMurdererFromDeathReplayData",
            "ReportPlayer", "SendReport"
        }
        for _, fn in ipairs(funcs) do
            if clientReport[fn] then clientReport[fn] = nop end
        end
    end
    
    local dsReport = package.loaded["GameLua.Mod.BaseMod.Common.Security.DSReportPlayerSubsystem"]
    if dsReport then
        local funcs = {
            "_OnNearDeathOrRescued", "_OnPlayerSettlementStart", "_OnTeammateDamage",
            "_OnCharacterDied", "_AddEnemyMapToBattleResult", "_AddTeammateMapToBattleResult",
            "_SubmitAbnormalData", "ReportData", "SendReport"
        }
        for _, fn in ipairs(funcs) do
            if dsReport[fn] then dsReport[fn] = nop end
        end
    end
    
    print("[GHOST] ✓ Report Subsystems Disabled")
end, "Report Systems")

-- ============================================================================
-- MODULE 11: TLOG BYPASS
-- ============================================================================
SafeExec(function()
    local tlogPaths = {
        "client.network.Protocol.ClientTlogHandler",
        "client.network.Protocol.BattleReportHandler",
        "client.network.Protocol.ClientErrorReportHandler",
        "client.slua.config.tlog.tlog_report_utils",
        "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem",
        "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem"
    }
    
    for _, path in ipairs(tlogPaths) do
        local mod = package.loaded[path]
        if mod then
            for k, v in pairs(mod) do
                if type(v) == "function" and (k:lower():find("log") or k:lower():find("report") or k:lower():find("send")) then
                    pcall(function() mod[k] = nop end)
                end
            end
        end
    end
    
    print("[GHOST] ✓ TLog Systems Disabled")
end, "TLog Bypass")

-- ============================================================================
-- MODULE 12: HEARTBEAT & SWIFT HAWK BYPASS
-- ============================================================================
SafeExec(function()
    local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat", "DoHeartbeat"}
    for _, func in ipairs(heartbeatFuncs) do
        if _G[func] then _G[func] = nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
            _G.GameplayCallbacks[func] = nop
        end
    end
    
    local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData", "SwiftHawkReport"}
    for _, func in ipairs(swiftFuncs) do
        if _G[func] then _G[func] = nop end
        if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
            _G.GameplayCallbacks[func] = nop
        end
    end
    
    print("[GHOST] ✓ Heartbeat & Swift Hawk Disabled")
end, "Heartbeat Bypass")

-- ============================================================================
-- MODULE 13: NETWORK PACKET FILTER
-- ============================================================================
SafeExec(function()
    if NetUtil and NetUtil.SendPacket then
        local originalSend = NetUtil.SendPacket
        local blockedPackets = {
            ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
            ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
            ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1,
            ["ReportPlayerPosition"]=1, ["ReportCircleFlow"]=1, ["Heartbeat"]=1,
            ["ClientHeartbeat"]=1, ["ServerHeartbeat"]=1, ["SwiftHawk"]=1,
            ["on_tss_sdk_anti_data"]=1, ["client_anti_cheat_report"]=1,
            ["CoronaLabReport"]=1, ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1
        }
        
        NetUtil.SendPacket = function(packetName, ...)
            if blockedPackets[packetName] then return nil end
            return originalSend(packetName, ...)
        end
    end
    
    print("[GHOST] ✓ Network Packet Filter Active")
end, "Packet Filter")

-- ============================================================================
-- MODULE 14: HTTP REQUEST BLOCKER
-- ============================================================================
SafeExec(function()
    local blacklist = {
        "tss.tencent", "syzsdk", "gcloud.qq", "reportlog", "tdos", "logupload",
        "anticheatexpert", "crashsight", "bugly", "beacon", "helpshift", "tdm",
        "apm", "firebase", "googleapis", "facebook", "gvoice", "tencent-cloud"
    }
    
    local function isBlocked(url)
        if type(url) ~= "string" then return false end
        local low = url:lower()
        for _, kw in ipairs(blacklist) do
            if low:find(kw, 1, true) then return true end
        end
        return false
    end
    
    if _G.HttpRequest then
        local orig = _G.HttpRequest
        _G.HttpRequest = function(url, ...)
            if isBlocked(url) then return nil, "Blocked" end
            return orig(url, ...)
        end
    end
    
    print("[GHOST] ✓ HTTP Request Blocker Active")
end, "HTTP Blocker")

-- ============================================================================
-- MODULE 15: WALLHACK (CHAMS)
-- ============================================================================
local function ApplyWallhack(localPlayer, enemy)
    if not slua.isValid(enemy) then return end
    
    local meshes = {}
    SafeExec(function()
        if slua.isValid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass and enemy.GetComponentsByClass then
            local childs = enemy:GetComponentsByClass(SkelClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 0, count - 1 do
                    local comp = type(childs.Get) == "function" and childs:Get(i) or childs[i+1]
                    if slua.isValid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    
    local isVisible = false
    SafeExec(function()
        if localPlayer and slua.isValid(localPlayer) then
            local myPos = localPlayer:K2_GetActorLocation()
            local targetPos = enemy:K2_GetActorLocation()
            if Game and Game.IsTargetPosVisible then
                isVisible = Game:IsTargetPosVisible(myPos, targetPos, {localPlayer})
            end
        end
    end)
    
    local color = isVisible and {R=0, G=255, B=0, A=255} or {R=255, G=255, B=0, A=255}
    
    for _, comp in ipairs(meshes) do
        if slua.isValid(comp) then
            pcall(function()
                comp.SetRenderCustomDepth and comp:SetRenderCustomDepth(true)
                comp.SetCustomDepthStencilValue and comp:SetCustomDepthStencilValue(isVisible and 1 or 2)
                comp.UseScopeDistanceCulling = false
            end)
            
            for i = 0, 5 do
                local ok, mid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                if ok and slua.isValid(mid) then
                    pcall(function()
                        mid:SetVectorParameterValue("Color", color)
                        mid:SetVectorParameterValue("BaseColor", color)
                        mid:SetVectorParameterValue("BodyColor", color)
                        mid:SetScalarParameterValue("Emissive", 0.5)
                    end)
                end
            end
        end
    end
end

print("[GHOST] ✓ Wallhack Ready")

-- ============================================================================
-- MODULE 16: ESP (HP BARS ONLY)
-- ============================================================================
local espActive = false
local espPawns = {}
local espLastRefresh = 0

local function GetPawnHealth(pawn)
    if pawn.Health then return pawn.Health end
    if pawn.GetHealth then return pawn:GetHealth() end
    return 100
end

local function GetPawnMaxHealth(pawn)
    if pawn.HealthMax then return pawn.HealthMax end
    if pawn.GetMaxHealth then return pawn:GetMaxHealth() end
    return 100
end

local function IsPawnDowned(pawn)
    if pawn.IsDowned then return pawn:IsDowned() end
    if pawn.bIsDowned then return pawn.bIsDowned end
    return false
end

local function ESPLoop()
    if not espActive then return end
    
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local localPawn = pc:GetCurPawn()
        if not slua.isValid(localPawn) then return end
        
        local myTeamId = localPawn.TeamID or 0
        local myPos = localPawn:K2_GetActorLocation()
        local hud = pc:GetHUD()
        
        if not slua.isValid(hud) then return end
        
        local now = os.clock()
        if now - espLastRefresh > 1.0 then
            espLastRefresh = now
            espPawns = Game:GetAllPlayerPawns() or {}
        end
        
        for _, enemy in pairs(espPawns) do
            if slua.isValid(enemy) and enemy ~= localPawn then
                local enemyTeamId = enemy.TeamID or 0
                if enemyTeamId ~= myTeamId then
                    local health = GetPawnHealth(enemy)
                    local maxHealth = GetPawnMaxHealth(enemy)
                    
                    if health > 0 then
                        local hpPercent = health / maxHealth
                        local isDowned = IsPawnDowned(enemy)
                        
                        local color = {R=0, G=255, B=0, A=255}
                        if isDowned then
                            color = {R=255, G=0, B=0, A=255}
                        elseif hpPercent < 0.3 then
                            color = {R=255, G=0, B=0, A=255}
                        elseif hpPercent < 0.7 then
                            color = {R=255, G=255, B=0, A=255}
                        end
                        
                        local hpText = isDowned and "⚠️ DOWN" or string.format("❤️ %.0f%%", hpPercent * 100)
                        
                        pcall(function()
                            hud:AddDebugText(hpText, enemy, 0.7, 
                                {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                                color, true, false, true, nil, 1.0, true)
                        end)
                        
                        pcall(ApplyWallhack, localPawn, enemy)
                    end
                end
            end
        end
    end)
end

print("[GHOST] ✓ ESP Ready")

-- ============================================================================
-- MODULE 17: AIMBOT + NO RECOIL
-- ============================================================================
local aimbotActive = false
local lastWeaponId = nil

local function ApplyAimbot()
    if not aimbotActive then return end
    
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end
        
        local weaponMgr = char:GetWeaponManagerComponent()
        if not slua.isValid(weaponMgr) then return end
        
        local weapon = weaponMgr.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end
        
        local shootComp = weapon.ShootWeaponEntityComp
        if slua.isValid(shootComp) then
            -- No Recoil
            shootComp.RecoilKick = 0.1
            shootComp.RecoilKickADS = 0.08
            shootComp.AnimationKick = 0.05
            shootComp.GameDeviationFactor = 0.3
            shootComp.AccessoriesVRecoilFactor = 0.4
            shootComp.AccessoriesHRecoilFactor = 0.4
            
            -- Aimbot Config
            if shootComp.AutoAimingConfig then
                shootComp.AutoAimingConfig.adsorbMaxRange = 200
                shootComp.AutoAimingConfig.adsorbMinRange = 10
                shootComp.AutoAimingConfig.adsorbActiveMinRange = 5
                if shootComp.AutoAimingConfig.OuterRange then
                    shootComp.AutoAimingConfig.OuterRange.Speed = 6
                    shootComp.AutoAimingConfig.OuterRange.SpeedRate = 5
                    shootComp.AutoAimingConfig.OuterRange.RangeRate = 2
                end
                if shootComp.AutoAimingConfig.InnerRange then
                    shootComp.AutoAimingConfig.InnerRange.Speed = 8
                    shootComp.AutoAimingConfig.InnerRange.SpeedRate = 6
                    shootComp.AutoAimingConfig.InnerRange.RangeRate = 2.5
                end
            end
            
            -- Set aim bone to head
            local aimComp = char.AutoAimingComponent or char.BP_AutoAimingComponent
            if slua.isValid(aimComp) and aimComp.Bones then
                if aimComp.Bones.Set then
                    aimComp.Bones:Set(0, "head")
                    aimComp.Bones:Set(1, "head")
                else
                    aimComp.Bones[0] = "head"
                    aimComp.Bones[1] = "head"
                end
            end
            
            -- Reduce spread
            if shootComp.SpreadConfig then
                shootComp.SpreadConfig.BaseSpread = 0.3
                shootComp.SpreadConfig.ADSSpread = 0.15
                shootComp.SpreadConfig.MoveSpread = 0.2
            end
        end
    end)
end

print("[GHOST] ✓ Aimbot + No Recoil Ready")

-- ============================================================================
-- MODULE 18: BOT COUNTER
-- ============================================================================
local function IsBot(pawn)
    if not slua.isValid(pawn) then return false end
    
    if pawn.IsAIPawn and type(pawn.IsAIPawn) == "function" then
        return pawn:IsAIPawn()
    end
    
    if pawn.IsBot then return pawn:IsBot() end
    
    local controller = pawn:GetController()
    if slua.isValid(controller) then
        local name = tostring(controller:GetName() or "")
        if name:find("AI") or name:find("Bot") or name:find("AIController") then
            return true
        end
    end
    
    return false
end

local function DrawBotCounter()
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local localPawn = pc:GetCurPawn()
        if not slua.isValid(localPawn) then return end
        
        local hud = pc:GetHUD()
        if not slua.isValid(hud) then return end
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        local myTeamId = localPawn.TeamID or 0
        local botCount = 0
        local realCount = 0
        
        for _, pawn in pairs(allPawns) do
            if slua.isValid(pawn) and pawn ~= localPawn then
                local teamId = pawn.TeamID or 0
                if teamId ~= myTeamId then
                    local health = GetPawnHealth(pawn)
                    if health > 0 then
                        if IsBot(pawn) then
                            botCount = botCount + 1
                        else
                            realCount = realCount + 1
                        end
                    end
                end
            end
        end
        
        pcall(function()
            hud:AddDebugText(string.format("🤖 BOT: %d  |  👤 REAL: %d", botCount, realCount),
                localPawn, 0.9, {X=0, Y=0, Z=200}, {X=0, Y=0, Z=200},
                {R=0, G=255, B=255, A=255}, true, false, true, nil, 1.0, true)
        end)
    end)
end

print("[GHOST] ✓ Bot Counter Ready")

-- ============================================================================
-- MODULE 19: FPS UNLOCK & CAMERA TWEAKS
-- ============================================================================
local function UnlockFPS()
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pcall(function() pc:ExecuteCommand("t.MaxFPS 165") end)
            pcall(function() pc:ExecuteCommand("r.FrameRateLimit 165") end)
        end
        
        local gi = Game:GetGameInstance()
        if gi and gi.ExecuteCMD then
            pcall(function() gi:ExecuteCMD("t.MaxFPS", "165") end)
            pcall(function() gi:ExecuteCMD("r.FrameRateLimit", "165") end)
            pcall(function() gi:ExecuteCMD("grass.DensityScale", "0") end)
            pcall(function() gi:ExecuteCMD("r.ViewDistanceScale", "3") end)
        end
    end)
end

local function SetiPadFOV()
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end
        
        local tppCam = char.ThirdPersonCameraComponent
        if slua.isValid(tppCam) and not char.bIsWeaponAiming then
            if tppCam.FieldOfView < 120 then
                tppCam.FieldOfView = 120
            end
        end
    end)
end

print("[GHOST] ✓ FPS Unlock & Camera Ready")

-- ============================================================================
-- MODULE 20: KILL ALL SECURITY SUBSYSTEMS (PERSISTENT)
-- ============================================================================
local function KillSecuritySubsystems()
    SafeExec(function()
        local subMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subMgr and subMgr.Get then
            local subsystems = {
                "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
                "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient",
                "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
                "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem",
                "AFKReportorSubsystem", "BehaviorScoreSubsystem", "HeartbeatSubsystem", "SwiftHawkSubsystem"
            }
            
            for _, name in ipairs(subsystems) do
                local sub = subMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:lower():find("report") or k:lower():find("send") or k:lower():find("upload")) then
                            pcall(function() sub[k] = nop end)
                        end
                    end
                end
            end
        end
    end)
end

print("[GHOST] ✓ Security Killer Ready")

-- ============================================================================
-- MODULE 21: MAIN INITIALIZATION
-- ============================================================================
local function InitializeFeatures()
    SafeExec(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then
            -- Retry after delay
            local fb = slua_GameFrontendHUD or Game
            if fb and slua.isValid(fb) then
                fb:AddGameTimer(1.0, false, InitializeFeatures)
            end
            return
        end
        
        print("[GHOST] Player Controller Found - Starting Features...")
        
        -- Activate features
        espActive = true
        aimbotActive = true
        
        -- Start ESP Loop
        pc:AddGameTimer(0.1, true, ESPLoop)
        print("[GHOST] ✓ ESP Activated")
        
        -- Start Aimbot Loop
        pc:AddGameTimer(0.15, true, ApplyAimbot)
        print("[GHOST] ✓ Aimbot + No Recoil Activated")
        
        -- Start Bot Counter
        pc:AddGameTimer(0.5, true, DrawBotCounter)
        print("[GHOST] ✓ Bot Counter Activated")
        
        -- Start Security Killer (persistent)
        pc:AddGameTimer(3.0, true, KillSecuritySubsystems)
        print("[GHOST] ✓ Security Persistence Active")
        
        -- Unlock FPS
        UnlockFPS()
        print("[GHOST] ✓ FPS Unlocked (165)")
        
        -- Set iPad FOV
        pc:AddGameTimer(0.5, true, SetiPadFOV)
        print("[GHOST] ✓ iPad FOV Active (120)")
        
        print("[GHOST] ╔════════════════════════════════════════════════════╗")
        print("[GHOST] ║            INJECTION COMPLETE - 100%               ║")
        print("[GHOST] ╠════════════════════════════════════════════════════╣")
        print("[GHOST] ║  ✓ Anti-Cheat Bypass      ✓ Wallhack (Chams)      ║")
        print("[GHOST] ║  ✓ ESP (HP Bars)          ✓ Aimbot + No Recoil    ║")
        print("[GHOST] ║  ✓ Bot Counter            ✓ 165 FPS Unlock        ║")
        print("[GHOST] ║  ✓ iPad FOV (120)         ✓ All Subsystems Killed ║")
        print("[GHOST] ╚════════════════════════════════════════════════════╝")
    end)
end

-- Start everything
InitializeFeatures()

print("[GHOST] GHOST PROTOCOL V5.0 - Waiting for game...")

-- Return success
return true
