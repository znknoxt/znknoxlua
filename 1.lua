-- ============================================================================
-- ULTIMATE MERGED BYPASS v3.0 + VIP SECURE MOD - COMPLETE
-- ============================================================================
-- VERSION: 4.0 FINAL MERGED
-- ALL FEATURES WORKING TOGETHER
-- ============================================================================

local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local KismetMathLibrary = import("KismetMathLibrary")
local GameplayStatics = import("GameplayStatics")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")

local Class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CombineClass = require("combine_class")

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retNil() return nil end
local function retTrue() return true end
local function retEmptyString() return "" end
local function isValid(obj) return slua.isValid(obj) end

local function safe_require(path)
    local success, result = pcall(require, path)
    if success then return result end
    return nil
end

-- ============================================================================
-- 🔒 SECURE EXPIRE SYSTEM (VIP)
-- ============================================================================
local EXPIRE_DATE = "2026-06-15"

local _CACHED_SERVER_TIME = nil
local _CACHED_TIME_SOURCE = nil

local function GetExpireTimestamp()
    local expire = {}
    EXPIRE_DATE:gsub("(%d+)", function(d) table.insert(expire, tonumber(d)) end)
    return os.time({year=expire[1], month=expire[2], day=expire[3], hour=23, min=59, sec=59})
end

local function GetRealServerTime()
    if _CACHED_SERVER_TIME and _CACHED_SERVER_TIME > 0 then
        local elapsed = os.difftime(os.time(), _CACHED_TIME_SOURCE or os.time())
        return _CACHED_SERVER_TIME + elapsed
    end
    
    local serverTime = nil
    
    pcall(function()
        local GameState = GameplayData.GetGameState()
        if slua.isValid(GameState) and GameState.GetServerWorldTimeSeconds then
            local worldTime = GameState:GetServerWorldTimeSeconds()
            if worldTime and worldTime > 0 then
                local startTime = GameState.K2_GetGameServerStartTime or GameState.ServerStartTime
                if startTime and startTime > 0 then
                    serverTime = startTime + worldTime
                end
            end
        end
    end)
    
    if not serverTime then
        pcall(function()
            local pc = slua_GameFrontendHUD:GetPlayerController()
            if slua.isValid(pc) and pc.GetServerTime then
                local st = pc:GetServerTime()
                if st and st > 0 then serverTime = st end
            end
        end)
    end
    
    if not serverTime then
        pcall(function()
            local Http = import("Http")
            local request = Http:Request("https://worldtimeapi.org/api/timezone/Asia/Kolkata")
            if request then
                request:SetTimeout(3)
                if request:Send() then
                    local response = request:GetResponse()
                    if response then
                        local data = json.decode(response)
                        if data and data.unixtime then
                            serverTime = tonumber(data.unixtime)
                            if serverTime and serverTime > 0 then
                                _CACHED_SERVER_TIME = serverTime
                                _CACHED_TIME_SOURCE = os.time()
                            end
                        end
                    end
                end
            end
        end)
    end
    
    if not serverTime then
        local osTime = os.time()
        local osDate = os.date("*t", osTime)
        if osDate.year >= 2024 and osDate.year <= 2030 then
            serverTime = osTime
        else
            return nil
        end
    end
    
    if serverTime and serverTime > 0 then
        _CACHED_SERVER_TIME = serverTime
        _CACHED_TIME_SOURCE = os.time()
    end
    
    return serverTime
end

local function GetFirstBootTime()
    if _G._SECURE_FIRST_BOOT and _G._SECURE_FIRST_BOOT > 0 then
        return _G._SECURE_FIRST_BOOT
    end
    
    local realTime = GetRealServerTime()
    if not realTime or realTime <= 0 then
        _G._NO_SERVER_TIME = true
        return nil
    end
    
    _G._SECURE_FIRST_BOOT = realTime
    _G._FIRST_BOOT_CHECKSUM = (realTime % 999983) + 12345
    return realTime
end

local function VerifyFirstBootIntegrity()
    if not _G._SECURE_FIRST_BOOT then return true end
    local expectedChecksum = (_G._SECURE_FIRST_BOOT % 999983) + 12345
    if _G._FIRST_BOOT_CHECKSUM ~= expectedChecksum then
        return false
    end
    return true
end

local function CheckExpiration()
    if _G._NO_SERVER_TIME then
        return false
    end
    
    if not VerifyFirstBootIntegrity() then
        _G._MOD_TAMPERED = true
        return false
    end
    
    local currentRealTime = GetRealServerTime()
    
    if not currentRealTime or currentRealTime <= 0 then
        if _CACHED_SERVER_TIME and _CACHED_SERVER_TIME > 0 then
            local elapsed = os.difftime(os.time(), _CACHED_TIME_SOURCE or os.time())
            currentRealTime = _CACHED_SERVER_TIME + elapsed
        else
            _G._NO_SERVER_TIME = true
            return false
        end
    end
    
    local expireTime = GetExpireTimestamp()
    
    if currentRealTime > expireTime then
        return false
    end
    
    local firstBoot = GetFirstBootTime()
    if not firstBoot or firstBoot <= 0 then
        return false
    end
    
    if firstBoot > expireTime then
        return false
    end
    
    if firstBoot > currentRealTime + (86400 * 7) then
        return false
    end
    
    if _G._PREV_CHECK_TIME and currentRealTime < _G._PREV_CHECK_TIME - 3600 then
        return false
    end
    _G._PREV_CHECK_TIME = currentRealTime
    
    return true
end

local function GetDaysRemaining()
    local currentRealTime = GetRealServerTime()
    if not currentRealTime or currentRealTime <= 0 then
        local expireTime = GetExpireTimestamp()
        local osTime = os.time()
        local osDate = os.date("*t", osTime)
        if osDate.year >= 2024 and osDate.year <= 2030 then
            local days = math.ceil((expireTime - osTime) / 86400)
            return days > 0 and days or 0
        end
        return 0
    end
    local expireTime = GetExpireTimestamp()
    local days_remaining = math.ceil((expireTime - currentRealTime) / 86400)
    if days_remaining < 0 then days_remaining = 0 end
    return days_remaining
end

local function ShowExpirePopup()
    if _G._EXPIRY_POPUP_SHOWN then return end
    _G._EXPIRY_POPUP_SHOWN = true
    
    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local Web = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
        
        _G.WH_ESP_Active = false
        _G._MOD_EXPIRED = true
        
        local function onClickTelegram()
            if Web then Web:OpenURL("APNE OWNER SE BAAT KARO") end
            pcall(function()
                local UKismetSystemLibrary = import("KismetSystemLibrary")
                if UKismetSystemLibrary then
                    UKismetSystemLibrary:QuitGame()
                end
            end)
        end
        
        local message = " YOUR MOD HAS EXPIRED! \n\n"
        if _G._NO_SERVER_TIME then
            message = " NO INTERNET CONNECTION! \n\nMOD REQUIRES INTERNET\nTO VERIFY LICENSE!\n\n"
        elseif _G._MOD_TAMPERED then
            message = " MOD TAMPERED! \n\nDATE TRICK DETECTED!\nMOD HAS BEEN LOCKED!\n\n"
        end
        
        Msg.Show(4, " MOD EXPIRED ", message .. "DATE TRICK WILL NOT WORK!\n\n CONTACT: APNE OWNER SE BAAT KARO\nFOR UPDATE FILES", onClickTelegram)
    end)
end

local function ShowDaysRemainingPopup()
    if _G.DaysRemainingShown then return end
    if not CheckExpiration() then ShowExpirePopup(); return end
    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local days = GetDaysRemaining()
        local daysText = days > 0 and string.format("%d DAYS REMAINING", days) or "LAST DAY!"
        local message = string.format(" SECURE MOD ACTIVE - %s \n\n EXPIRES: %s\n\n DATE CHANGE = MOD BANNED\n\n APNE OWNER SE BAAT KARO", daysText, EXPIRE_DATE)
        local function onClickTelegram()
            local Web = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
            if Web then Web:OpenURL("APNE OWNER SE BAAT KARO") end
        end
        Msg.Show(4, " MODDED BY APNE OWNER SE BAAT KARO ", message, onClickTelegram)
        _G.DaysRemainingShown = true
    end)
end

function _G.TryShowWelcome()
    if _G.WelcomeShown then return end
    if not CheckExpiration() then ShowExpirePopup(); return end
    pcall(function()
        ShowDaysRemainingPopup()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local Web = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
        local function onClickDirect()
            if Web then Web:OpenURL("APNE OWNER SE BAAT KARO") end
            local UIUtils = require("GameLua.Util.UIUtils")
            if UIUtils and UIUtils.ShowNotice then UIUtils.ShowNotice("[VIP] ALL FEATURES ACTIVATED") end
        end
        Msg.Show(4, " VIP MOD", " ALL FEATURES ACTIVATED:\n ✓ 165 FPS\n ✓ AIMBOT\n ✓ MAGIC BULLET\n ✓ WALL HACK\n ✓ ESP\n ✓ MINI MAP ESP\n ✓ FOV MOD\n\n APNE OWNER SE BAAT KARO", onClickDirect)
        _G.WelcomeShown = true
    end)
end

-- Anti-tamper monitor
if not _G.ANTI_TAMPER_MONITOR then
    _G.ANTI_TAMPER_MONITOR = true
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(5.0, true, function()
                if not CheckExpiration() then
                    _G.WH_ESP_Active = false
                    ShowExpirePopup()
                end
            end)
        end
    end)
end

-- ============================================================================
-- BRPlayerCharacterBase RPC DEFINITIONS
-- ============================================================================

local BRPlayerCharacterBase = {
    ServerRPC = {},
    ClientRPC = {},
    MulticastRPC = {}
}

-- Base RPC Definitions
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } }
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = { Reliable = true, Params = { UEnums.EPropertyClass.Bool } }

-- Additional RPCs for bypass
BRPlayerCharacterBase.ServerRPC.RPC_Server_ReportSimulateCharacterLocation = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ClientRPC.RPC_Client_ShootVertifyRes = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ClientRPC.RPC_ClientCoronaLab = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.RPC_Server_ReportPlayerKillFlow = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.RPC_Server_ClientSecMrpcsFlow = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.RPC_Server_Heartbeat = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.RPC_Server_SwiftHawk = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.RPC_Server_ClientSwiftHawkWithParams = { Reliable = true, Params = {} }

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
-- 2. MD5 & SIGNATURE BYPASS
-- ============================================================================

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
        if TssSdk then
            TssSdk.GetFileMD5 = function() return "BYPASS" end
            TssSdk.VerifyFileSignature = retTrue
        end
        
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary then
            STExtraBlueprintFunctionLibrary.CheckMD5 = retTrue
            STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end
            STExtraBlueprintFunctionLibrary.VerifyFile = retTrue
        end
    end)
end

-- ============================================================================
-- 3. SKIN & AVATAR BYPASS
-- ============================================================================

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
end

-- ============================================================================
-- 4. LOG BLOCKER - ENHANCED
-- ============================================================================

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
        
        local TLogReportUtils = package.loaded["client.slua.config.tlog.tlog_report_utils"]
        if TLogReportUtils then
            TLogReportUtils.ReportTLogEvent = nop
            TLogReportUtils.FlushEvents = nop
        end
        
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]
            if s then
                s.logEvent = nop; s.trackEvent = nop; s.setEnabled = retFalse
                s.sendEvent = nop; s.report = nop
            end
        end
    end)
end

-- ============================================================================
-- 5. SCANNER & VERIFICATION BLOCKER
-- ============================================================================

local function InitializeScannerBlocker()
    pcall(function()
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
        
        local AvatarExceptionPlayerInst = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvatarExceptionPlayerInst then
            AvatarExceptionPlayerInst.CheckAvatarException = nop
            AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = nop
            AvatarExceptionPlayerInst.ReportAvatarException = nop
            AvatarExceptionPlayerInst.CheckSlotMeshVisible = retFalse
            AvatarExceptionPlayerInst.CheckPawnVisible = retFalse
            AvatarExceptionPlayerInst.CheckCanBugglyPostException = retFalse
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
            TssSdk.ScanMemory = retTrue
            TssSdk.IsEmulator = retFalse
            TssSdk.GetTssSdkReportInfo = retEmptyString
            TssSdk.CheckEnvironment = retTrue
            TssSdk.VerifyProcess = retTrue
        end
    end)
end

-- ============================================================================
-- 6. REPLAY TELEMETRY BLOCKER
-- ============================================================================

local function InitializeReplayTelemetryBlocker()
    pcall(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local replaySystems = {
                "RescueBtnReplayTraceSubsystem", "GameReportSubsystem", "ReplaySubsystem"
            }
            for _, name in ipairs(replaySystems) do
                local sub = SubsystemMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (
                            k:find("Report") or k:find("Trace") or k:find("Replay") or
                            k:find("Record") or k:find("Save")
                        ) then
                            pcall(function() sub[k] = nop end)
                        end
                    end
                end
            end
        end
        
        local logic_report_replay = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logic_report_replay then
            logic_report_replay.ReportReplay = nop
            logic_report_replay.SendReportReq = nop
            logic_report_replay.UploadReplay = nop
        end
    end)
end

-- ============================================================================
-- 7. REPORT FLOW BLOCKER - ENHANCED (ALL FLOW TYPES)
-- ============================================================================

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

-- ============================================================================
-- 8. PLAYER SECURITY COLLECTOR BYPASS
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
        
        if _G.PlayerSecurityInfo then
            _G.PlayerSecurityInfo.ReportCheat = nop
            _G.PlayerSecurityInfo.ReportSuspicious = nop
            _G.PlayerSecurityInfo.SendSecurityData = nop
            _G.PlayerSecurityInfo.CollectSecurityInfo = nop
        end
    end)
end

-- ============================================================================
-- 9. CLIENT FLOW BYPASS (MRPCS, KILL FLOW, CIRCLE FLOW)
-- ============================================================================

local function InitializeClientFlowBypass()
    pcall(function()
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
                        pcall(function() sub[k] = nop end)
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
    end)
end

-- ============================================================================
-- 10. HEARTBEAT BYPASS
-- ============================================================================

local function InitializeHeartbeatBypass()
    pcall(function()
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
    end)
end

-- ============================================================================
-- 11. SWIFT HAWK BYPASS
-- ============================================================================

local function InitializeSwiftHawkBypass()
    pcall(function()
        local swiftFuncs = {"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}
        for _, func in ipairs(swiftFuncs) do
            if _G[func] then _G[func] = nop end
            if _G.GameplayCallbacks and _G.GameplayCallbacks[func] then
                _G.GameplayCallbacks[func] = nop end
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

-- ============================================================================
-- 12. CORONALAB BYPASS
-- ============================================================================

local function InitializeCoronaLabBypass()
    pcall(function()
        if _G.CoronaLab then
            _G.CoronaLab.ReportData = nop
            _G.CoronaLab.SendData = nop
            _G.CoronaLab.CollectData = nop
            _G.CoronaLab.Telemetry = nop
        end
        
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
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

-- ============================================================================
-- 13. MODIFIER EXCEPTION BYPASS
-- ============================================================================

local function InitializeModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then
            _G.bReportedModifierException = false
        end
        
        local ModifierSubsystem = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if ModifierSubsystem then
            ModifierSubsystem.ReportException = nop
            ModifierSubsystem.CheckModifier = retTrue
            ModifierSubsystem.ValidateModifier = retTrue
            ModifierSubsystem.ReportModifierError = nop
        end
    end)
end

-- ============================================================================
-- 14. SIMULATE CHARACTER LOCATION BYPASS
-- ============================================================================

local function InitializeSimulateCharacterLocationBypass()
    pcall(function()
        local SimulateSubsystem = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if SimulateSubsystem then
            SimulateSubsystem.ReportLocation = nop
            SimulateSubsystem.SendLocationData = nop
            SimulateSubsystem.VerifyLocation = retTrue
        end
    end)
end

-- ============================================================================
-- 15. SHOOT VERIFICATION BYPASS
-- ============================================================================

local function InitializeShootVerificationBypass()
    pcall(function()
        local ShootVerify = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if ShootVerify then
            ShootVerify.OnShootVerifyFailed = nop
            ShootVerify.SendVerifyData = nop
            ShootVerify.ReportBulletHit = nop
            ShootVerify.UploadHitInfo = nop
            ShootVerify.VerifyShot = retTrue
        end
        
        if _G.BulletHitInfoUploadData then
            _G.BulletHitInfoUploadData.Report = nop
            _G.BulletHitInfoUploadData.Send = nop
            _G.BulletHitInfoUploadData.Upload = nop
        end
    end)
end

-- ============================================================================
-- 16. COMPLETE NETWORK PACKET BLOCK - ENHANCED
-- ============================================================================

local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local originalSend = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"] = 1, ["ReportSecAttackFlow"] = 1, ["ReportHurtFlow"] = 1,
                ["ReportFireArms"] = 1, ["ReportVerifyInfoFlow"] = 1, ["ReportMrpcsFlow"] = 1,
                ["ReportPlayerBehavior"] = 1, ["ReportTeammatHurt"] = 1, ["ReportPlayerMoveRoute"] = 1,
                ["ReportPlayerPosition"] = 1, ["ReportSecVehicleMoveFlow"] = 1, ["report_parachute_data"] = 1,
                ["on_tss_sdk_anti_data"] = 1, ["ReportAimFlow"] = 1, ["ReportHitFlow"] = 1,
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
                ["SecurityViolation"] = 1, ["IntegrityCheck"] = 1, ["SignatureVerify"] = 1
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then
                    return nil
                end
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
                "RPC_ClientCoronaLab"
            }
            _G.SendRPC = function(rpcName, ...)
                for _, blocked in ipairs(blockedRPCs) do
                    if rpcName == blocked then return nil end
                end
                return originalSendRPC(rpcName, ...)
            end
        end
    end)
end

-- ============================================================================
-- 17. HIGGS BOSON COMPLETE BYPASS
-- ============================================================================

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
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
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.GetCurWeaponSkinID = retZero
            Higgs.IsMHActive = retFalse
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
        end
        
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then
                pc.HiggsBoson.bMHActive = false
                pc.HiggsBoson.bCallPreReplication = false
                if pc.HiggsBoson.ControlMHActive then
                    pc.HiggsBoson:ControlMHActive(0)
                end
            end
            if pc.HiggsBosonComponent then
                pc.HiggsBosonComponent.bMHActive = false
                pc.HiggsBosonComponent.bCallPreReplication = false
                pc.HiggsBosonComponent:ControlMHActive(0)
            end
        end
        
        if Higgs and Higgs.BlackList then
            for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end
        end
        _G.BlackList = {}
    end)
end

-- ============================================================================
-- 18. ANTI CHEAT HOOKS
-- ============================================================================

local function InitializeAntiCheatHooks()
    pcall(function()
        local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent and HiggsBosonComponent.StaticShowSecurityAlertInDev then
            HiggsBosonComponent.StaticShowSecurityAlertInDev = nop
        end
    end)
    
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
end

-- ============================================================================
-- 19. ANTI REPORT SYSTEM
-- ============================================================================

local function InitializeAntiReport()
    pcall(function()
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
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- 20. GAMEPLAY CALLBACKS BYPASS
-- ============================================================================

local function InitializeGameplayBypass()
    pcall(function()
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
            GC[funcName] = nop
        end
        
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse
        GC.CheckReportSecAttackFlow = retFalse
        
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
    end)
end

-- ============================================================================
-- 21. KILL ALL SECURITY SUBSYSTEMS - COMPLETE
-- ============================================================================

local function InitializeKillAllSubsystems()
    pcall(function()
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
            "MD5CheckSubsystem", "PakVerifySubsystem"
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
    end)
end

-- ============================================================================
-- 22. FINAL PROTECTION LAYER
-- ============================================================================

local function InitializeFinalProtection()
    pcall(function()
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
            "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"
        }
        _G.require = function(module)
            for _, blocked in ipairs(blockedModules) do
                if module:find(blocked) then
                    return {}
                end
            end
            return originalRequire(module)
        end
    end)
end

-- ============================================================================
-- EXTENDED BYPASS MODULE (VIP)
-- ============================================================================

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

-- ============================================================================
-- ESP FEATURES TOGGLES (From ZN_KNOX)
-- ============================================================================
_G.AK_Features = {
    { id = "ESP_HP",         name = "ESP Health Bar",     val = 1, type = "toggle" },
    { id = "ESP_BOX",        name = "ESP Box",            val = 1, type = "toggle" },
    { id = "ESP_MAP",        name = "Mini Map ESP",       val = 1, type = "toggle" },
}

function _G.AK_GetVal(featureId)
    for _, feature in ipairs(_G.AK_Features) do
        if feature.id == featureId then return feature.val end
    end
    return 1
end

-- ============================================================================
-- MINI MAP ESP (Distance Marker System from ZN_KNOX)
-- ============================================================================
local distanceMarkerConfig = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
    MaxWidgetNum = 99,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    BindSocketName = "head",
    bUseLuaWorldSocketName = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true,
    Priority = 2
}

local function InitDistanceMarkerSystem()
    if not CheckExpiration() then return end
    pcall(function()
        if InGameMarkTools and InGameMarkTools.ScreenMarkManager and InGameMarkTools.ScreenMarkManager.OnInitMarkGroupData then
            InGameMarkTools.ScreenMarkManager:OnInitMarkGroupData(9999)
        end

        local gameplayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
        local screenMarkConfig = gameplayTools.GetCurrentConfig("ScreenMarkConfig")
        if screenMarkConfig then
            screenMarkConfig[9999] = distanceMarkerConfig
        end

        for moduleName, moduleData in pairs(package.loaded) do
            if type(moduleName) == "string" and string.find(moduleName, "ScreenMarkConfig") then
                if type(moduleData) == "table" then
                    moduleData[9999] = distanceMarkerConfig
                end
            end
        end
    end)
end

if not _G.AK_Active_Marks_Cache then
    _G.AK_Active_Marks_Cache = {}
end

local function createDistanceMarker(enemy)
    if _G.AK_GetVal("ESP_MAP") == 0 then return end
    pcall(function()
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            enemy.NativeDistMark = InGameMarkTools.ClientAddMapMark(9999, FVector(0, 0, 0), 0, "", 4, enemy)
            _G.AK_Active_Marks_Cache[tostring(enemy)] = { actor = enemy, distMark = enemy.NativeDistMark }
        end
    end)
end

local function removeDistanceMarker(enemy)
    pcall(function()
        if InGameMarkTools then
            if InGameMarkTools.ClientRemoveMapMark then
                InGameMarkTools.ClientRemoveMapMark(enemy.NativeDistMark)
            elseif InGameMarkTools.HideMapMark then
                InGameMarkTools.HideMapMark(enemy.NativeDistMark)
            end
        end
        enemy.NativeDistMark = nil
        _G.AK_Active_Marks_Cache[tostring(enemy)] = nil
    end)
end

local function cleanupDeadEnemyMarks()
    for cacheKey, cacheData in pairs(_G.AK_Active_Marks_Cache) do
        local shouldRemove = false
        
        if not slua.isValid(cacheData.actor) then
            shouldRemove = true
        else
            pcall(function()
                local actor = cacheData.actor
                if actor.bHidden or (actor.Mesh and actor.Mesh.bHidden) then
                    shouldRemove = true
                end
                if type(actor.IsDead) == "function" and actor:IsDead() then
                    shouldRemove = true
                elseif actor.bIsDead == true or actor.bIsDeadFlag == true then
                    shouldRemove = true
                end
            end)
        end

        if shouldRemove then
            pcall(function()
                if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then
                    InGameMarkTools.ClientRemoveMapMark(cacheData.distMark)
                end
            end)
            _G.AK_Active_Marks_Cache[cacheKey] = nil
        end
    end
end

local function processEnemyMapESP(enemy, localPlayer)
    if not CheckExpiration() then return end
    if not slua.isValid(enemy) or enemy == localPlayer or enemy.TeamID == localPlayer.TeamID then
        return
    end

    if _G.AK_GetVal("ESP_MAP") == 0 then return end

    local isDead = false
    pcall(function()
        if type(enemy.IsDead) == "function" then
            isDead = enemy:IsDead()
        elseif enemy.bIsDead ~= nil then
            isDead = enemy.bIsDead
        elseif enemy.bIsDeadFlag ~= nil then
            isDead = enemy.bIsDeadFlag
        end
        if enemy.bHidden or (enemy.Mesh and enemy.Mesh.bHidden) then
            isDead = true
        end
        if not isDead then
            local health = 100
            if type(enemy.GetHealth) == "function" then
                health = enemy:GetHealth()
            elseif enemy.Health ~= nil then
                health = enemy.Health
            end
            if health <= 0 then isDead = true end
        end
    end)

    if not isDead then
        if not enemy.bHasAKNativeMapMarker then
            createDistanceMarker(enemy)
            enemy.bHasAKNativeMapMarker = true
        end
    else
        if enemy.bHasAKNativeMapMarker then
            removeDistanceMarker(enemy)
            enemy.bHasAKNativeMapMarker = false
        end
    end
end

-- ============================================================================
-- 165 FPS LOGIC
-- ============================================================================
_G.Enable165FPSLogic = function()
    if not CheckExpiration() then return end
    pcall(function()
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then
                    local gi = GameplayData.GetGameInstance()
                    if gi then gi:ExecuteCMD("t.MaxFPS", "165"); gi:ExecuteCMD("r.FrameRateLimit", "165") end
                end
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
            function impl:UpdateSelectedFPSState(lvl)
                local fps = {[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120}
                for i = 2, 8 do
                    local node = self.UIRoot["NodeFps"..tostring(fps[i] or 120)]
                    if slua.isValid(node) then
                        node:SetIsEnabled(true)
                        pcall(function() node:SetRenderOpacity(1.0) end)
                        local sw = self.UIRoot["WidgetSwitcher_"..tostring(i)]
                        if slua.isValid(sw) then sw:SetActiveWidgetIndex(i == lvl and 0 or 1) end
                    end
                end
            end
        end
        
        local fpsFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        if fpsFT and fpsFT.__inner_impl then
            local impl = fpsFT.__inner_impl
            local MIN = 90
            function impl:ShowOrHide() self:SelfHitTestInvisible(); if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end end
            function impl:InitFPSFTSwitch()
                local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                local on = db:GetUIData(db.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(on, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, on) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end
            function impl:InitFPSFTValue165()
                local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                local r = self.UIRoot
                local on = db:GetUIData(db.FPSFineTuneSwitch)
                local val = on and (db:GetUIData(db.FPSFineTuneNum) or 165) or 165
                if on then
                    r.Slider_screen3:SetLocked(false)
                    r.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1,1,1,1))
                    r.Slider_screen3:SetSliderHandleColor(FLinearColor(1,1,1,1))
                else
                    r.Slider_screen3:SetLocked(true)
                    r.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1,0.625,0.6,1))
                    r.Slider_screen3:SetSliderHandleColor(FLinearColor(1,0.625,0.6,1))
                end
                local norm = (val - MIN) / (165 - MIN)
                r.Veihclescreen3:SetText(tostring(val))
                r.Slider_screen3:SetValue(norm)
                r.ProgressBar_screen3:SetPercent(norm)
            end
            function impl:OnFPSFTValueChange3(val)
                local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                db:UpdateUIData(db.FPSFineTuneNum, val)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gi = GameplayData.GetGameInstance()
                if gi then gi:ExecuteCMD("t.MaxFPS", tostring(val)); gi:ExecuteCMD("r.FrameRateLimit", tostring(val)) end
            end
            function impl:OnFPSFTAdd3()
                local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                local cur = db:GetUIData(db.FPSFineTuneNum) or 90
                self:OnFPSFTValueChange3(math.min(165, cur + 5))
            end
            function impl:OnFPSFTMinus3()
                local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
                local cur = db:GetUIData(db.FPSFineTuneNum) or 90
                self:OnFPSFTValueChange3(math.max(MIN, cur - 5))
            end
            impl.OnFPSFTAdd = impl.OnFPSFTAdd3
            impl.OnFPSFTMinus = impl.OnFPSFTMinus3
        end
    end)
end

-- ============================================================================
-- FOV MOD (View Distance Config)
-- ============================================================================
pcall(function()
    local SettingCfg = require("client.logic.setting.setting_config")
    local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
    if SettingCfg then
        if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 90 end
        if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 90 end
    end
    if GraphicSettingDB then
        if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 90 end
    end
end)

-- ============================================================================
-- MAGIC BULLET (Enlarged Hitboxes)
-- ============================================================================
local function EnableMagicBullet()
    if not CheckExpiration() then return end
    pcall(function()
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
                            local mb = {
                                ["head"] = 0, ["neck_01"] = 150, ["pelvis"] = 150,
                                ["spine_01"] = 120, ["spine_02"] = 120, ["spine_03"] = 120,
                                ["upperarm_l"] = 110, ["upperarm_r"] = 110,
                                ["lowerarm_l"] = 110, ["lowerarm_r"] = 110,
                                ["hand_l"] = 100, ["hand_r"] = 100,
                                ["thigh_l"] = 90, ["thigh_r"] = 90,
                                ["calf_l"] = 80, ["calf_r"] = 80,
                                ["foot_l"] = 70, ["foot_r"] = 70,
                            }
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
                                                b.X = (b.X or 30) * sc
                                                b.Y = (b.Y or 30) * sc
                                                b.Z = (b.Z or 60) * sc
                                                if type(bx.Set) == "function" then bx:Set(0, b) else bx[1] = b end
                                                if ag then bs.AggGeom = ag else bs.BoxElems = bx end
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
                                                if ag then bs.AggGeom = ag else bs.SphylElems = sp end
                                            end
                                        end
                                    end)
                                    pcall(function()
                                        local sr = (ag and ag.SphereElems) or bs.SphereElems
                                        if sr then
                                            local r = (type(sr.Get) == "function") and sr:Get(0) or sr[1]
                                            if r and r.Radius then
                                                r.Radius = r.Radius * sc
                                                if type(sr.Set) == "function" then sr:Set(0, r) else sr[1] = r end
                                                if ag then bs.AggGeom = ag else bs.SphereElems = sr end
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
-- AIMBOT FUNCTIONS
-- ============================================================================
_G._AimbotCurrentPC = nil

local function ApplyHardAimbot()
    if not CheckExpiration() then return end
    pcall(function()
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
        
        entity.RecoilKickADS = 0.01
        entity.GameDeviationFactor = 0.01
        entity.GameDeviationAccuracy = 0.01
        entity.ExtraHitPerformScale = 6
        
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 1.9
                    cfg.RangeRate = 1.8
                    cfg.SpeedRate = 1.7
                    cfg.RangeRateSight = 1.6
                    cfg.SpeedRateSight = 1.5
                    cfg.CrouchRate = 1.4
                    cfg.ProneRate = 1.3
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
            if slua.isValid(aimComp) and aimComp.Bones then
                aimComp.Bones[0] = "head"
                aimComp.Bones[1] = "head"
                aimComp.Bones[2] = "head"
            end
        end)
    end)
end

local function AttachAimbotTimer()
    if not CheckExpiration() then return end
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        if pc == _G._AimbotCurrentPC then return end
        _G._AimbotCurrentPC = pc
        if pc.AddGameTimer then
            pc:AddGameTimer(0.1, true, function()
                if not CheckExpiration() then return end
                if not slua.isValid(_G._AimbotCurrentPC) then _G._AimbotCurrentPC = nil; return end
                ApplyHardAimbot()
                EnableMagicBullet()
            end)
        end
    end)
end

-- ============================================================================
-- WALL HACK SYSTEM (From Original)
-- ============================================================================
_G.WH_ESP_Active = true

local function WH_ApplyVisualMods(localPlayer, enemy, pc)
    if not CheckExpiration() then 
        _G.WH_ESP_Active = false
        return 
    end
    if not _G.WH_ESP_Active then return end
    if not slua.isValid(enemy) then return end
    
    if _G.AK_GetVal("ESP_BOX") == 0 then return end
    
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
        
        local hiddenBodyColor  = { R = 1.5, G = 0.0, B = 0.0, A = 2.0 }
        local visibleBodyColor = { R = 0.0, G = 1.5, B = 0.0, A = 2.0 }
        local hiddenGlowColor  = { R = 2.5, G = 0.0, B = 0.5, A = 2.5 }
        local visibleGlowColor = { R = 0.0, G = 2.5, B = 2.0, A = 2.5 }
        
        local finalBodyColor = isVisible and visibleBodyColor or hiddenBodyColor
        local finalGlowColor = isVisible and visibleGlowColor or hiddenGlowColor
        local scale = { R = 8.0, G = 8.0, B = 0.0, A = 0.0 }
        
        enemy.WH_MIDs = enemy.WH_MIDs or {}
        local stateChanged = (enemy.WH_LastVisible ~= isVisible)
        enemy.WH_LastVisible = isVisible
        
        for _, comp in ipairs(meshes) do
            if slua.isValid(comp) then
                pcall(function()
                    comp.bRenderCustomDepth = true
                    comp.CustomDepthStencilValue = 250
                    comp.CustomDepthStencilWriteMask = 255
                end)
                
                local s, matInterface = pcall(function() return comp:GetMaterial(0) end)
                if s and slua.isValid(matInterface) then
                    local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                    if s2 and slua.isValid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= 2 then baseMat.BlendMode = 2 end
                    end
                end
                comp.UseScopeDistanceCulling = false 
                comp.PrimitiveShadingStrategy = 1
                comp.ShadingRate = 6
                
                local compKey = tostring(comp)
                enemy.WH_MIDs[compKey] = enemy.WH_MIDs[compKey] or {}
                
                for i = 0, 15 do
                    local s2, matInterface2 = pcall(function() return comp:GetMaterial(i) end)
                    if not s2 or not slua.isValid(matInterface2) then break end
                    
                    local isNewMID = false
                    local needCacheUpdate = false
                    local currentCached = enemy.WH_MIDs[compKey][i]
                    
                    if not slua.isValid(currentCached) then
                        local s3, newMid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                        if s3 and slua.isValid(newMid) then 
                            enemy.WH_MIDs[compKey][i] = newMid
                            currentCached = newMid
                            isNewMID = true
                            needCacheUpdate = true 
                        end
                    else
                        if matInterface2 ~= currentCached then 
                            pcall(function() comp:SetMaterial(i, currentCached) end)
                            needCacheUpdate = true 
                        end
                    end
                    
                    if slua.isValid(currentCached) and (stateChanged or isNewMID or needCacheUpdate) then
                        pcall(function()
                            local bodyColorParams = {
                                "颜色", "Extra Light Color", "Para_Color", "Para_ColorTint", 
                                "Para_Color_1", "Tint", "Color", "BaseColor", "BodyColor", 
                                "MainColor", "DiffuseColor", "EmissiveColor",
                                "SubsurfaceColor", "AlbedoColor", "SkinColor",
                                "BaseColorTint", "FillColor", "MaterialColor",
                                "TintColor", "ColorTint", "BodyTint", "MainTint"
                            }
                            for _, param in ipairs(bodyColorParams) do
                                pcall(function() currentCached:SetVectorParameterValue(param, finalBodyColor) end)
                            end
                            
                            local glowColorParams = {
                                "GlowColor", "HighlightColor", "OutlineColor",
                                "FresnelColor", "RimColor", "Glow", 
                                "SelfIlluminateColor", "EmissiveLightColor",
                                "InnerGlowColor", "OuterGlowColor",
                                "EdgeGlowColor", "ScanGlowColor",
                                "HologramColor", "NeonColor", "BloomColor",
                                "RadianceColor", "FlareColor", "LightColor",
                                "EmissionColor", "EmissiveColor", "BloomTint"
                            }
                            for _, param in ipairs(glowColorParams) do
                                pcall(function() currentCached:SetVectorParameterValue(param, finalGlowColor) end)
                            end
                            
                            local glowScalarParams = {
                                "Glow", "GlowAmount", "GlowIntensity", 
                                "GlowPower", "GlowStrength", "GlowBoost",
                                "HighlightPower", "HighlightIntensity",
                                "EmissiveBoost", "EmissiveStrength",
                                "RimPower", "RimIntensity", "RimStrength",
                                "FresnelPower", "FresnelIntensity",
                                "OutlineStrength", "OutlineThickness",
                                "SelfIlluminate", "SelfIllumination",
                                "Brightness", "Opacity", "Intensity",
                                "GlowScale", "EmissionStrength", "BloomIntensity",
                                "Radiance", "LightIntensity", "GlowBrightness"
                            }
                            for _, param in ipairs(glowScalarParams) do
                                pcall(function() currentCached:SetScalarParameterValue(param, 25.0) end)
                            end
                            
                            pcall(function() currentCached:SetVectorParameterValue("ParaScaleOffset", scale) end)
                        end)
                    end
                end
            end
        end
    end)
end

local function WH_DrawDistanceESP(HUD, enemy, localPlayer)
    if not CheckExpiration() then 
        _G.WH_ESP_Active = false
        return 
    end
    if not _G.WH_ESP_Active then return end
    if not slua.isValid(enemy) or not slua.isValid(localPlayer) then return end
    
    if _G.AK_GetVal("ESP_HP") == 1 then
        pcall(function()
            if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
                if not enemy.bHasAKNativeHPBar then
                    enemy.NativeHPBarMark = InGameMarkTools.ClientAddMapMark(1006, FVector(0,0,0), 0, "", 4, enemy)
                    enemy.bHasAKNativeHPBar = true
                end
            end
        end)
    else
        if enemy.bHasAKNativeHPBar then
            pcall(function()
                if InGameMarkTools and InGameMarkTools.ClientRemoveMapMark then
                    InGameMarkTools.ClientRemoveMapMark(enemy.NativeHPBarMark)
                end
                enemy.bHasAKNativeHPBar = false
                enemy.NativeHPBarMark = nil
            end)
        end
    end
    
    local dist = math.floor(localPlayer:GetDistanceTo(enemy) / 100)
    if dist > 400 then return end
    local pos = {X = 0, Y = 0, Z = 95}
    HUD:AddDebugText(string.format("[%dm]", dist), enemy, 0.35, pos, pos, 
        {R=0, G=255, B=255, A=255}, true, false, true, nil, 1.5, true)
    
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) then WH_ApplyVisualMods(localPlayer, enemy, pc) end
end

local function WH_RunESP()
    if not CheckExpiration() then 
        _G.WH_ESP_Active = false
        return 
    end
    _G.WH_ESP_Active = true
    
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        local HUD = pc:GetHUD()
        if not slua.isValid(HUD) then return end
        local myTeamId = localPlayer.TeamID or 0
        local allPawns = Game:GetAllPlayerPawns() or {}
        for _, target in pairs(allPawns) do
            if slua.isValid(target) and target ~= localPlayer and target.TeamID ~= myTeamId then
                local isAlive = false
                pcall(function() isAlive = target:IsAlive() end)
                if isAlive then 
                    WH_DrawDistanceESP(HUD, target, localPlayer)
                    processEnemyMapESP(target, localPlayer)
                end
            end
        end
        cleanupDeadEnemyMarks()
    end)
end

-- ============================================================================
-- START ALL FEATURES
-- ============================================================================

if not _G.WH_ESP_TimerStarted then
    _G.WH_ESP_TimerStarted = true
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            pc:AddGameTimer(0.08, true, WH_RunESP)
        end
    end)
end

if CheckExpiration() then
    _G.Enable165FPSLogic()
    AttachAimbotTimer()
    InitDistanceMarkerSystem()
end

pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(2.0, true, function()
            if not CheckExpiration() then return end
            if not slua.isValid(_G._AimbotCurrentPC) then _G._AimbotCurrentPC = nil; AttachAimbotTimer() end
        end)
    end
end)

-- ============================================================================
-- MAIN BYPASS INITIALIZATION
-- ============================================================================

local function InitializeCompleteBypass()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeSkinBypass()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReplayTelemetryBlocker()
        InitializeReportFlowBlocker()
        InitializePlayerSecurityBypass()
        InitializeClientFlowBypass()
        InitializeHeartbeatBypass()
        InitializeSwiftHawkBypass()
        InitializeCoronaLabBypass()
        InitializeModifierExceptionBypass()
        InitializeSimulateCharacterLocationBypass()
        InitializeShootVerificationBypass()
        InitializeNetworkPacketBlock()
        InitializeHiggsBosonBypass()
        InitializeAntiCheatHooks()
        InitializeAntiReport()
        InitializeGameplayBypass()
        InitializeKillAllSubsystems()
        InitializeFinalProtection()
        
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end

local function StartBypass()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(0.5, false, InitializeCompleteBypass)
        pc:AddGameTimer(3.0, true, function()
            InitializeHiggsBosonBypass()
            InitializeNetworkPacketBlock()
            InitializeHeartbeatBypass()
            InitializeSwiftHawkBypass()
        end)
    else
        InitializeCompleteBypass()
    end
end

-- ============================================================================
-- BRPlayerCharacterBase CLASS (Merged)
-- ============================================================================

function BRPlayerCharacterBase:ctor()
    self.ActiveForceMark = nil
    self.LastMarkUpdate = 0
    self.bHasShownDevNotice = false
    self.AK_NativeESP_Ready = false
end

function BRPlayerCharacterBase:_PostConstruct()
    BRPlayerCharacterBase.__super._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    self:StartAdvancedSystems()
    StartBypass()
    print("[ULTIMATE BYPASS] Complete Protection Activated")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    if not CheckExpiration() then ShowExpirePopup(); return end
    BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    self:RegisterAvatarOutline(false)
    if Client then _G.TryShowWelcome() end
    EventSystem:postEvent(EVENTTYPE_SINGLETRAINING, EVENTID_CHARACTER_BEGINPLAY, self.Object)
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    if self.ActiveForceMark then InGameMarkTools.HideMapMark(self.ActiveForceMark); self.ActiveForceMark = nil end
    BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    if Client and GameplayData.RemoveCharacter then
        GameplayData.RemoveCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:RegisterAvatarOutline(bForce)
    if not Client or not CheckExpiration() then return end
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then return end
    local uAvatarComp2 = self:getAvatarComponent2()
    if not slua.isValid(uAvatarComp2) then return end
    local PPM = import("PostProcessManager").GetInstance()
    if not slua.isValid(PPM) or not PPM.IsPPEnabled then return end
    if uPlayerCharacter.TeamID ~= self.TeamID then
        PPM.OutlineThickness = 3
        if PPM.OutlineColor then PPM.OutlineColor = { r = 1, g = 0, b = 0, a = 1 } end
        PPM:EnableAvatarOutline(uAvatarComp2, true)
    else
        PPM:EnableAvatarOutline(uAvatarComp2, false)
    end
end

function BRPlayerCharacterBase:UpdateESP_Mark()
    if not Client or not CheckExpiration() then return end
    if not slua.isValid(self.Object) then return end
    local local_player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(local_player) then return end
    if local_player.TeamID ~= self.TeamID then
        if self.Object.IsAlive and self.Object:IsAlive() then
            local current_time = os.clock()
            if current_time - self.LastMarkUpdate > 1.0 then
                self.LastMarkUpdate = current_time
                local head_location = self:GetHeadLocation(false)
                if not head_location then head_location = self:GetFuzzyPosition(FVector(0, 0, 0)) end
                if head_location then
                    if self.ActiveForceMark then InGameMarkTools.HideMapMark(self.ActiveForceMark) end
                    self.ActiveForceMark = InGameMarkTools.ClientAddMapMark(1003, head_location, 0, "", 4, nil)
                end
            end
        end
    else
        if self.ActiveForceMark then InGameMarkTools.HideMapMark(self.ActiveForceMark); self.ActiveForceMark = nil end
    end
end

function BRPlayerCharacterBase:ApplyAutoAimHead()
    if not CheckExpiration() then return end
    local autoComp = self.AutoAimComp
    if not autoComp then return end
    autoComp.Bones = {"Head", "Head", "Head"}
end

local EAvatarDamagePosition = import("EAvatarDamagePosition")

function BRPlayerCharacterBase.GetHitBodyType(ImpactResult, InImpactVec)
    return EAvatarDamagePosition.BigHead
end

function BRPlayerCharacterBase.GetHitBodyTypeByHitPos(InImpactVec)
    return EAvatarDamagePosition.BigHead
end

function BRPlayerCharacterBase:GetEnemyTargetsFromActors(radius)
    if not CheckExpiration() then return {} end
    local uPlayerController = self:GetPlayerControllerSafety()
    if not slua.isValid(uPlayerController) then return {} end
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end
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
                if dist <= radius then table.insert(result, actor) end
            end
        end
    end
    return result
end

function BRPlayerCharacterBase:StartAdvancedSystems()
    if not Client or not CheckExpiration() then return end
    
    InitDistanceMarkerSystem()
    
    pcall(function()
        local subsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        local hpBarSubsystem = subsystemMgr:Get("ClientHPBarSubSystem")
        if hpBarSubsystem then
            if hpBarSubsystem.SetPauseCheck then hpBarSubsystem:SetPauseCheck(true) end
            if hpBarSubsystem.FocusActorCheckParam then
                hpBarSubsystem.FocusActorCheckParam.CheckBlock = false
                hpBarSubsystem.FocusActorCheckParam.CheckDistance = 1000000
            end
        end
    end)
    
    self:AddGameTimer(0.1, true, function()
        if not CheckExpiration() then return end
        if not slua.isValid(self.Object) then return end
        
        local uLocalPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(uLocalPlayer) then return end
        
        local uTPPCam = self.Object.ThirdPersonCameraComponent
        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"] or require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
            if SettingSubsystem then
                local rawSliderValue = SettingSubsystem:GetUserSettings_Int("TpViewValue") or 90
                local targetTPP = rawSliderValue
                if rawSliderValue > 80 and rawSliderValue <= 90 then
                    targetTPP = 80 + (rawSliderValue - 80) * 6.0
                elseif rawSliderValue > 90 then
                    targetTPP = rawSliderValue
                end
                if slua.isValid(uTPPCam) and not self.Object.bIsWeaponAiming then
                    if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
                end
            end
        end
        
        self:UpdateESP_Mark()
        self:ApplyAutoAimHead()
    end)
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState) return true end
function BRPlayerCharacterBase:HandleOnAttachedToVehicle(uVehicle) end
function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle) end
function BRPlayerCharacterBase:ClearAttachToVehicleTimer() end

-- ============================================================================
-- CLASS DECLARATION
-- ============================================================================
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = Class(CCharacterBase, nil, BRPlayerCharacterBase)

return CombineClass.DeclareFeature(CBRPlayerCharacterBase, {
    { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
    { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
    { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
    { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
    { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
    { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
    { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
    { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
    { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" }
}, "BRPlayerCharacterBase")
