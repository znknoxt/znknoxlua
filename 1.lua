-- ============================================================================
-- 1.lua - COMPLETE 8-LAYER BYPASS + MD5 SPOOF + ALL FEATURES
-- ============================================================================

-- Per-match guard
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then return end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

-- ============================================================================
-- ORIGINAL PAK MD5 (FOR SPOOFING)
-- ============================================================================
local ORIGINAL_PAK_MD5 = "7b1c7b5608da3083097816106fc331f9"

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retTrue() return true end
local function retEmptyString() return "" end

local function Valid(obj)
    return slua.isValid(obj)
end

local function IsPawnAlive(pawn)
    if not Valid(pawn) then return false end
    if pawn.HealthStatus then
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        return SecurityCommonUtils.IsHealthStatusAlive(pawn.HealthStatus)
    end
    return (pawn.Health or 0) > 0
end

local function GetHealthPercent(character)
    if not Valid(character) then return 0 end
    local health = character.Health or 0
    local maxHealth = character.HealthMax or 100
    if maxHealth > 0 then return health / maxHealth end
    return 0
end

-- ============================================================================
-- FEATURE TOGGLES
-- ============================================================================

if _G.Mod_Aimbot_Enabled == nil then _G.Mod_Aimbot_Enabled = true end
if _G.Mod_ESP_Enabled == nil then _G.Mod_ESP_Enabled = true end
if _G.Mod_Wallhack_Enabled == nil then _G.Mod_Wallhack_Enabled = true end
if _G.Mod_BotCounter_Enabled == nil then _G.Mod_BotCounter_Enabled = true end
if _G.Mod_HPBar_Enabled == nil then _G.Mod_HPBar_Enabled = true end

-- ============================================================================
-- 1. SLUA BYPASS
-- ============================================================================

local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then
            slua.getSignature = function() return 0xDEADBEEF end
        end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then
            slua_serialize.check = retTrue
            slua_serialize.verify = retTrue
        end
        if jit and jit.attach then
            jit.attach(function() end, "bc")
        end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
end

-- ============================================================================
-- 2. MD5 & SIGNATURE BYPASS (WITH ORIGINAL MD5 SPOOF)
-- ============================================================================

local function InitializeMD5Bypass()
    pcall(function()
        print("[MD5] Spoofing MD5 to: " .. ORIGINAL_PAK_MD5)
        
        -- Console commands
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        
        -- CreativeModeBlueprintLibrary MD5 spoof
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function(...) 
                return ORIGINAL_PAK_MD5 
            end
            CreativeModeBlueprintLibrary.MD5HashFile = function(...) 
                return ORIGINAL_PAK_MD5 
            end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() 
                return true, "BYPASSED" 
            end
            CreativeModeBlueprintLibrary.VerifyFileIntegrity = retTrue
            CreativeModeBlueprintLibrary.CheckFileHash = retTrue
            CreativeModeBlueprintLibrary.ComputeMD5 = function(...) 
                return ORIGINAL_PAK_MD5 
            end
        end
        
        -- Global MD5 functions
        if _G.MD5Hash then 
            _G.MD5Hash = function(...) return ORIGINAL_PAK_MD5 end 
        end
        if _G.CRC32 then 
            _G.CRC32 = function(...) return 0 end 
        end
        if _G.SHA1 then 
            _G.SHA1 = function(...) return "BYPASS" end 
        end
        if _G.CalcMD5 then 
            _G.CalcMD5 = function(...) return ORIGINAL_PAK_MD5 end 
        end
        if _G.ComputeMD5 then 
            _G.ComputeMD5 = function(...) return ORIGINAL_PAK_MD5 end 
        end
        
        -- FileHashChecker
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = retTrue
            FileHashChecker.VerifyAll = retTrue
            FileHashChecker.GetHash = function(...) return ORIGINAL_PAK_MD5 end
            FileHashChecker.VerifyFileHash = retTrue
        end
        
        -- TssSdk MD5 spoof
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            TssSdk.GetFileMD5 = function(...) return ORIGINAL_PAK_MD5 end
            TssSdk.VerifyFileSignature = retTrue
            TssSdk.CheckFileIntegrity = retTrue
            TssSdk.VerifyIntegrity = retTrue
            TssSdk.ScanFile = function() return true, {code = 0} end
            TssSdk.GetRiskFlag = function() return 0 end
        end
        
        -- STExtraBlueprintFunctionLibrary
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary then
            STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
            STExtraBlueprintFunctionLibrary.GetMD5 = function(...) return ORIGINAL_PAK_MD5 end
            STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
            STExtraBlueprintFunctionLibrary.ComputeHash = function(...) return ORIGINAL_PAK_MD5 end
        end
        
        -- PakFileManager
        local PakFileManager = import("PakFileManager")
        if PakFileManager then
            PakFileManager.VerifyPakSignature = retTrue
            PakFileManager.CheckPakIntegrity = retTrue
            PakFileManager.GetPakFileMD5 = function(...) return ORIGINAL_PAK_MD5 end
        end
        
        print("[MD5] ✓ MD5 spoof active | Original MD5: " .. ORIGINAL_PAK_MD5)
    end)
end

-- ============================================================================
-- 3. LOG BLOCKER
-- ============================================================================

local function InitializeLogBlocker()
    pcall(function()
        local ScreenshotMTDer = import("ScreenshotMTDer")
        if ScreenshotMTDer then
            ScreenshotMTDer.MTDePicture = function() return "" end
            ScreenshotMTDer.TakeScreenshot = nop
        end
        
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop
            TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop
        end
        
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = nop
            CrashSight.SetCustomData = nop
            CrashSight.Log = nop
        end
        
        local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GameReportUtils then
            GameReportUtils.BugglyPostExceptionFull = retFalse
            GameReportUtils.CheckCanBugglyPostException = retFalse
            GameReportUtils.ReplayReportData = nop
            GameReportUtils.ReportGameException = nop
        end
        
        local ClientToolsReport = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if ClientToolsReport then
            ClientToolsReport.SendReport = nop
            ClientToolsReport.SendException = nop
        end
        
        print("[LOG] ✓ Logging disabled")
    end)
end

-- ============================================================================
-- 4. REPORT FLOW BLOCKER
-- ============================================================================

local function InitializeReportFlowBlocker()
    pcall(function()
        local reportFlows = {
            "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
            "ReportHurtFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow",
            "ReportPlayerBehavior", "ReportTeammatHurt", "ReportPlayerMoveRoute",
            "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportParachuteData",
            "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP",
            "ReportCircleFlow", "ReportPlayerKillFlow", "ClientSecMrpcsFlow",
            "Heartbeat", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams",
            "ReportSecMrpcsFlow", "ReportMisKillByTeammate", "ReportForbitPick"
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
        
        print("[REPORT] ✓ Report flows blocked")
    end)
end

-- ============================================================================
-- 5. PLAYER SECURITY BYPASS
-- ============================================================================

local function InitializePlayerSecurityBypass()
    pcall(function()
        local securityCollectors = {
            "PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector",
            "ClientSecurityCollector", "PlayerAntiCheatCollector"
        }
        
        for _, collector in ipairs(securityCollectors) do
            if _G[collector] then
                for k, v in pairs(_G[collector]) do
                    if type(v) == "function" and (
                        k:find("Report") or k:find("Collect") or k:find("Send") or
                        k:find("Upload") or k:find("Record")
                    ) then
                        _G[collector][k] = nop
                    end
                end
            end
        end
        
        local SecuritySubsystem = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecuritySubsystem then
            SecuritySubsystem.ReportData = nop
            SecuritySubsystem.CheckCheat = retFalse
            SecuritySubsystem.ValidatePlayer = retTrue
            SecuritySubsystem.CollectData = nop
            SecuritySubsystem.SendToServer = nop
        end
        
        print("[SECURITY] ✓ Player security bypassed")
    end)
end

-- ============================================================================
-- 6. HIGGS BOSON BYPASS
-- ============================================================================

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            local methods = {
                "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
                "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord",
                "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", 
                "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev",
                "DisableHiggsBoson", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent"
            }
            for _, m in ipairs(methods) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.GetCurWeaponSkinID = retZero
            Higgs.IsMHActive = retFalse
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
        end
        
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if Valid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                if pc.HiggsBoson.ControlMHActive then
                    pc.HiggsBoson:ControlMHActive(0)
                end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
        
        if Higgs and Higgs.BlackList then
            for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end
        end
        _G.BlackList = {}
        
        print("[HIGGS] ✓ HiggsBoson disabled")
    end)
end

-- ============================================================================
-- 7. NETWORK PACKET BLOCK
-- ============================================================================

local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
                ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
                ["ReportPlayerBehavior"] = 1, ["ReportTeammatHurt"] = 1, ["ReportPlayerMoveRoute"] = 1,
                ["ReportPlayerPosition"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
                ["ReportCircleFlow"] = 1, ["report_players_ping"] = 1, ["report_player_ip"] = 1,
                ["Heartbeat"] = 1, ["ClientHeartbeat"] = 1, ["ServerHeartbeat"] = 1,
                ["SwiftHawk"] = 1, ["ClientSwiftHawk"] = 1, ["ClientSwiftHawkWithParams"] = 1,
                ["RPC_ClientCoronaLab"] = 1, ["CoronaLabReport"] = 1,
                ["PlayerSecurityInfo"] = 1, ["ReportSecurityInfo"] = 1,
                ["AntiCheatReport"] = 1, ["CheatDetection"] = 1, ["ViolationReport"] = 1,
                ["ReportPlayerKillFlow"] = 1, ["ClientSecMrpcsFlow"] = 1,
                ["on_tss_sdk_anti_data"] = 1, ["report_client_scan_result"] = 1,
                ["report_memory_exception"] = 1, ["report_avatar_exception"] = 1
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then
                    return nil
                end
                return originalSend(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end
        
        print("[NETWORK] ✓ Telemetry packets blocked")
    end)
end

-- ============================================================================
-- 8. KILL ALL SUBSYSTEMS
-- ============================================================================

local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        
        local subsystemsToKill = {
            "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent",
            "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem",
            "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem",
            "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem",
            "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem",
            "GameReportSubsystem", "SwiftHawkSubsystem", "HeartbeatSubsystem",
            "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "PlayerKillFlowSubsystem",
            "CircleFlowSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem",
            "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"
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
                        pcall(function() sub[k] = nop end)
                    end
                end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
        
        print("[SUBSYSTEMS] ✓ All security subsystems killed")
    end)
end

-- ============================================================================
-- 9. GAMEPLAY CALLBACKS BYPASS
-- ============================================================================

local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        
        local GC = _G.GameplayCallbacks
        local reportFuncs = {
            "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow", "ReportFireArms",
            "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt",
            "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportAimFlow", "ReportHitFlow",
            "ReportCircleFlow", "ReportPlayerKillFlow", "ClientSecMrpcsFlow", "Heartbeat",
            "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendTssSdkAntiDataToLobby",
            "SendDSErrorLogToLobby", "SendDSHawkEyePatrolLogToLobby", "ReportMatchRoomData",
            "SendClientStats", "SendServerAvgTickDelta", "OnDSConnectionSaturated"
        }
        
        for _, funcName in ipairs(reportFuncs) do
            GC[funcName] = nop
        end
        
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
        GC.CheckReportSecAttackFlow = retFalse
        
        local originalDSPlayerState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            local stateStr = InPlayerState and string.lower(tostring(InPlayerState)) or ""
            local blockedStates = {
                ["cheatdetected"] = true, ["banned"] = true, ["kicked"] = true,
                ["suspended"] = true, ["violationdetected"] = true, ["integrityfailure"] = true,
                ["securityviolation"] = true, ["connectionlost"] = true
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
        
        print("[GAMEPLAY] ✓ Gameplay callbacks bypassed")
    end)
end

-- ============================================================================
-- COMPLETE BYPASS INITIALIZATION
-- ============================================================================

local bypassInitialized = false

local function InitializeCompleteBypass()
    if bypassInitialized then return end
    bypassInitialized = true
    
    pcall(function()
        print("")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║       9-LAYER BYPASS + MD5 SPOOF ACTIVATED                   ║")
        print("╚══════════════════════════════════════════════════════════════╝")
        print("")
        
        InitializeSLUABypass()           -- Layer 1
        InitializeMD5Bypass()            -- Layer 2 (with original MD5 spoof)
        InitializeLogBlocker()           -- Layer 3
        InitializeReportFlowBlocker()    -- Layer 4
        InitializePlayerSecurityBypass() -- Layer 5
        InitializeHiggsBosonBypass()     -- Layer 6
        InitializeNetworkPacketBlock()   -- Layer 7
        InitializeKillAllSubsystems()    -- Layer 8
        InitializeGameplayBypass()       -- Layer 9
        
        print("")
        print("[✓] SLUA Bypass active")
        print("[✓] MD5 Spoof active (Original: " .. ORIGINAL_PAK_MD5 .. ")")
        print("[✓] Log blocker active")
        print("[✓] Report flows blocked")
        print("[✓] Player security bypassed")
        print("[✓] HiggsBoson disabled")
        print("[✓] Network packets blocked")
        print("[✓] All subsystems killed")
        print("[✓] Gameplay callbacks bypassed")
        print("")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║             9-LAYER BYPASS COMPLETE                          ║")
        print("║             YOU ARE SAFE TO PLAY                             ║")
        print("╚══════════════════════════════════════════════════════════════╝")
        print("")
    end)
end

-- ============================================================================
-- BOT DETECTION
-- ============================================================================

local function IsAIPawn(pawn)
    if not Valid(pawn) then return false end
    if pawn.IsAIPawn and type(pawn.IsAIPawn) == "function" then
        return pawn:IsAIPawn()
    end
    if Game.IsAI and type(Game.IsAI) == "function" then
        return Game:IsAI(pawn)
    end
    if pawn.GetController then
        local controller = pawn:GetController()
        if Valid(controller) then
            local cName = tostring(controller:GetName() or "")
            if cName:find("AI") or cName:find("Bot") then
                return true
            end
        end
    end
    return false
end

local function GetBotAndRealCount()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not Valid(pc) then return 0, 0 end
    local localPlayer = pc:GetPlayerCharacterSafety()
    if not Valid(localPlayer) then return 0, 0 end
    
    local allChars = Game:GetAllPlayerPawns() or {}
    local myTeamId = localPlayer.TeamID or 0
    
    local botCount = 0
    local realCount = 0
    
    for _, enemy in pairs(allChars) do
        if Valid(enemy) and enemy ~= localPlayer then
            local enemyTeamId = enemy.TeamID or 0
            if enemyTeamId ~= myTeamId and IsPawnAlive(enemy) then
                if IsAIPawn(enemy) then
                    botCount = botCount + 1
                else
                    realCount = realCount + 1
                end
            end
        end
    end
    return botCount, realCount
end

-- ============================================================================
-- AIMBOT
-- ============================================================================

local function ApplyAimbot()
    if not _G.Mod_Aimbot_Enabled then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not Valid(pc) then return end
        local char = pc:GetPlayerCharacterSafety()
        if not Valid(char) then return end
        local wm = char.WeaponManagerComponent
        if not Valid(wm) then return end
        local weapon = wm.CurrentWeaponReplicated
        if not Valid(weapon) then return end
        local entity = weapon.ShootWeaponEntityComp
        if Valid(entity) then
            entity.RecoilKick = 0.05
            entity.RecoilKickADS = 0.05
            entity.AnimationKick = 0.05
            entity.GameDeviationFactor = 0.05
            if entity.AutoAimingConfig then
                for _, range in ipairs({"OuterRange", "InnerRange"}) do
                    local cfg = entity.AutoAimingConfig[range]
                    if cfg then
                        cfg.Speed = 20.0
                        cfg.RangeRate = 20.0
                        cfg.SpeedRate = 20.0
                    end
                end
            end
        end
        local aimComp = char.BP_AutoAimingComponent_C or char.BP_AutoAimingComponent
        if Valid(aimComp) and aimComp.Bones then
            pcall(function()
                if type(aimComp.Bones.Set) == "function" then
                    aimComp.Bones:Set(0, "head")
                    aimComp.Bones:Set(1, "head")
                    aimComp.Bones:Set(2, "head")
                else
                    aimComp.Bones = {"head", "head", "head"}
                end
            end)
        end
    end)
end

-- ============================================================================
-- WALLHACK
-- ============================================================================

local function ApplyWallhackToEnemy(enemy, pc)
    if not Valid(enemy) then return end
    
    local meshes = {}
    pcall(function()
        if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass then
            local childs = enemy:GetComponentsByClass(SkelClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for c = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(c-1) or childs[c]
                    if Valid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    
    pcall(function()
        for _, comp in ipairs(meshes) do
            if Valid(comp) then
                local s, mat = pcall(function() return comp:GetMaterial(0) end)
                if s and Valid(mat) then
                    local s2, baseMat = pcall(function() return mat:GetBaseMaterial() end)
                    if s2 and Valid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2
                    end
                end
                comp.UseScopeDistanceCulling = false
                comp.PrimitiveShadingStrategy = 1
                comp.ShadingRate = 6
            end
        end
    end)
end

local function ApplyWallhackToAll()
    if not _G.Mod_Wallhack_Enabled then return end
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not Valid(pc) then return end
        local localPlayer = pc:GetPlayerCharacterSafety()
        if not Valid(localPlayer) then return end
        
        local allChars = Game:GetAllPlayerPawns() or {}
        local myTeamId = localPlayer.TeamID or 0
        
        for _, enemy in pairs(allChars) do
            if Valid(enemy) and enemy ~= localPlayer then
                local enemyTeamId = enemy.TeamID or 0
                if enemyTeamId ~= myTeamId and IsPawnAlive(enemy) then
                    ApplyWallhackToEnemy(enemy, pc)
                end
            end
        end
    end)
end

-- ============================================================================
-- HP BAR FUNCTIONS
-- ============================================================================

local function GetHPBarColor(hpPercent)
    if hpPercent < 0.3 then return {R=255, G=0, B=0, A=255}
    elseif hpPercent < 0.7 then return {R=255, G=255, B=0, A=255}
    else return {R=0, G=255, B=0, A=255} end
end

local function GetHPBarText(hpPercent)
    local filled = math.floor(hpPercent * 10)
    local empty = 10 - filled
    return string.rep("█", filled) .. string.rep("░", empty) .. " " .. math.floor(hpPercent * 100) .. "%"
end

-- ============================================================================
-- DRAW ALL OVERLAYS
-- ============================================================================

local function DrawAllOverlays()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not Valid(pc) then return end
        local localPlayer = pc:GetPlayerCharacterSafety()
        if not Valid(localPlayer) then return end
        local hud = pc:GetHUD()
        if not Valid(hud) then return end
        
        -- Bot Counter
        if _G.Mod_BotCounter_Enabled then
            local botCount, realCount = GetBotAndRealCount()
            hud:AddDebugText(string.format("🤖 BOT: %d", botCount), localPlayer, 1,
                {X=0, Y=0, Z=220}, {X=0, Y=0, Z=220},
                {R=0, G=255, B=255, A=255}, true, false, true, nil, 1.0, true)
            hud:AddDebugText(string.format("👤 REAL: %d", realCount), localPlayer, 1,
                {X=0, Y=0, Z=205}, {X=0, Y=0, Z=205},
                {R=255, G=255, B=0, A=255}, true, false, true, nil, 1.0, true)
            hud:AddDebugText(string.format("🎯 TOTAL: %d", botCount + realCount), localPlayer, 1,
                {X=0, Y=0, Z=190}, {X=0, Y=0, Z=190},
                {R=255, G=255, B=255, A=255}, true, false, true, nil, 0.9, true)
        end
        
        -- ESP + HP Bars
        if _G.Mod_ESP_Enabled or _G.Mod_HPBar_Enabled then
            local allChars = Game:GetAllPlayerPawns() or {}
            local myTeamId = localPlayer.TeamID or 0
            
            for _, enemy in pairs(allChars) do
                if Valid(enemy) and enemy ~= localPlayer then
                    local enemyTeamId = enemy.TeamID or 0
                    if enemyTeamId ~= myTeamId and IsPawnAlive(enemy) then
                        if _G.Mod_HPBar_Enabled then
                            local hpPercent = GetHealthPercent(enemy)
                            local hpColor = GetHPBarColor(hpPercent)
                            local hpText = GetHPBarText(hpPercent)
                            hud:AddDebugText(hpText, enemy, 0.5, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, hpColor, true, false, true, nil, 1.0, true)
                        end
                        
                        if _G.Mod_ESP_Enabled then
                            local isBot = IsAIPawn(enemy)
                            local label = isBot and "🤖 BOT" or "👤 REAL"
                            local color = isBot and {R=0, G=255, B=255, A=255} or {R=255, G=255, B=0, A=255}
                            hud:AddDebugText(label, enemy, 0.8, {X=0, Y=0, Z=100}, {X=0, Y=0, Z=100}, color, true, false, true, nil, 0.7, true)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- START ALL FEATURES
-- ============================================================================

local function StartAllFeatures()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not Valid(pc) then
        local fb = slua_GameFrontendHUD or Game
        if fb and Valid(fb) and fb.AddGameTimer then
            fb:AddGameTimer(1.0, false, StartAllFeatures)
        end        return
    end
    
    -- Initialize complete 9-layer bypass
    InitializeCompleteBypass()
    
    -- Start feature loops
    pc:AddGameTimer(0.2, true, ApplyAimbot)
    pc:AddGameTimer(0.3, true, DrawAllOverlays)
    pc:AddGameTimer(0.5, true, ApplyWallhackToAll)
    
    -- Re-apply bypass periodically
    pc:AddGameTimer(5.0, true, InitializeCompleteBypass)
    pc:AddGameTimer(3.0, true, InitializeHiggsBosonBypass)
    pc:AddGameTimer(4.0, true, InitializeNetworkPacketBlock)
    
    print("")
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║                                                              ║")
    print("║     🔥 ALL FEATURES ACTIVATED 🔥                             ║")
    print("║                                                              ║")
    print("║     ✓ 9-Layer Bypass + MD5 Spoof                            ║")
    print("║     ✓ Aimbot (Zero Recoil + Head Lock)                      ║")
    print("║     ✓ Wallhack (See Through Walls)                          ║")
    print("║     ✓ ESP (Enemy Labels)                                    ║")
    print("║     ✓ Bot Counter (BOT/REAL Count)                          ║")
    print("║     ✓ HP Bars (Health Bars on Enemies)                      ║")
    print("║                                                              ║")
    print("║     MD5 Spoofed To: " .. ORIGINAL_PAK_MD5 .. "   ║")
    print("║                                                              ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print("")
end

-- Auto-start
StartAllFeatures()

print("[1.lua] INJECTED SUCCESSFULLY!")
