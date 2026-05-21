local function Notify(msg)
    local s = "[Lexus VIP] " .. tostring(msg)
    pcall(function() if _G.LexusNotify then _G.LexusNotify(s) end end)
    pcall(function()
        local sh = import("ScriptHelperClient")
        if sh and sh.AddOnScreenDebugMessage then
            sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1, G=1, B=0, A=1}, {X=1.2, Y=1.2})
        end
    end)
    print(s)
end

Notify("Đang nạp hệ thống VIP từ Server...")

local _slua = rawget(_G, "slua")

local function Valid(obj)
    if not obj then return false end
    if _slua and _slua.isValid then
        if not _slua.isValid(obj) then return false end
    end
    return true
end

-- ==========================================
-- 1. HỆ THỐNG BIẾN TOÀN CẦU LƯU TRỮ TRẠNG THÁI
-- ==========================================
_G.LexusConfig = _G.LexusConfig or {
    WelcomeShown = false,
    mOt = 10,
    mEw = false,  -- ESP Wall (Khung + HP Bar Mới)
    mSm = false,  -- ESP Khung Xương Động (ĐÃ FIX CHUẨN)
    mMr = false,  -- ESP Định vị Bản đồ
    mRc = false,  -- Less Recoil
    mAt = "None", -- Aimbot Target
    mAk = false,  -- Aimbot Enable
    mEo = false,  -- ESP Outline
    mCh = false,  -- Crosshair
    mAc = false,  -- Accuracy
    mZb = false,  -- Zero Bounce
    mWp = false,  -- White Player
    mGm = false,  -- God Mode
    mMs = false   -- Magic Bullet
}

_G.LexusState = _G.LexusState or { 
    LoopToken = 0,
    EnemyMarks = {},
    LastMarkTime = {},
    TrackedMarks = {},
    AK_NativeESP_Ready = false,
    BypassLoaded = false 
}

-- ==========================================
-- HÀM QUẢN LÝ MARK AN TOÀN (BỎ QUA LỖI)
-- ==========================================
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.LexusState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools then
            if InGameMarkTools.ClientRemoveMapMark then InGameMarkTools.ClientRemoveMapMark(mark) end
            if InGameMarkTools.HideMapMark then InGameMarkTools.HideMapMark(mark) end
        end
    end)
    _G.LexusState.TrackedMarks[mark] = nil
end

-- =====================================================================
-- BỘ CHỐNG BAN (BYPASS ANTI-CHEAT CAO CẤP DAT CUTI V4.4)
-- =====================================================================
local function empty_func() end
local function empty_table() return {} end
local function zero_func() return 0 end
local function false_func() return false end
local function true_func() return true end
local function nil_func() return nil end

local function SafeRequire(...)
    local paths = {...}
    for _, path in ipairs(paths) do
        if package.loaded[path] then return package.loaded[path] end
        local status, lib = pcall(require, path)
        if status and lib then return lib end
    end
    return nil
end

local function DisableGlobalAntiCheat()
    pcall(function()
        local Engine = import("Engine")
        if Engine then
            Engine.bEnableAntiCheat = false
            Engine.bEnableClientSideAntiCheat = false
            Engine.bEnableServerSideAntiCheat = false
        end
        local GameInstance = import("GameInstance")
        if GameInstance then
            GameInstance.bEnableAntiCheat = false
            GameInstance.bEnableBanSystem = false
        end
        _G.bEnableAntiCheat = false; _G.bEnableClientReport = false
        _G.bEnableDSReport = false; _G.bEnableHiggsBoson = false
        _G.bEnablePacketInspect = false; _G.bEnableMemoryScan = false
        _G.bEnableBanSystem = false; _G.bEnableKickSystem = false
        _G.bEnableViolationSystem = false
    end)
end

local function InitializeAntiReport()
    pcall(function()
        local ClientReport = SafeRequire("GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem")
        if ClientReport then
            local funcs = {"OnInit", "_OnPlayerKilledOtherPlayer", "_RecordFatalDamager", "_OnDeathReplayDataWhenFatalDamaged", "_RecordMurdererFromDeathReplayData", "_RecordTeammatePlayerInfo", "_OnBattleResult", "_OnShowQuickReportMutualExclusiveUI", "ReportPlayer", "SendReportToDS", "OnClientDamage", "ReportCheat", "ReportSuspicious"}
            for _, v in ipairs(funcs) do ClientReport[v] = empty_func end
            ClientReport.GetFatalDamagerMap = empty_table
            ClientReport.GetCachedTeammateName2InfoMap = empty_table
            ClientReport.GetTeammateName2InfoMapDuringBattle = empty_table
            ClientReport.GetCurrentNotInTeamHistoricalTeammateMap = empty_table
            ClientReport.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
            ClientReport.bEnableReporting = false
        end
    end)

    pcall(function()
        local DSReport = SafeRequire("GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem", "GameLua.Mod.BaseMod.Client.Security.DSReportPlayerSubsystem")
        if DSReport then
            local funcs = {"OnInit", "_OnNearDeathOrRescued", "_OnCharacterDied", "_OnTeammateDamage", "_OnPlayerSettlementStart", "_AddKnockDownerToBattleResult", "_AddKillerToBattleResult", "_AddTeammateMurderToBattleResult", "_AddFatalDamagerMapToBattleResult", "_AddMLKillerUIDToBattleResult", "_SaveHistoricalTeammateInfo", "_RecordFatalDamager", "_RecordTeammateMurderer", "ReportSuspiciousActivity"}
            for _, v in ipairs(funcs) do DSReport[v] = empty_func end
            DSReport.ValidatePlayerReport = true_func; DSReport.bEnableDSReporting = false
        end
    end)
end

local function InitializeAntiCheatBypass()
    pcall(function()
        local Higgs = SafeRequire("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            local funcs = {"ControlMHActive", "Tick", "OnTick", "ReceiveTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "OnReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord", "ShowSecurityAlert", "StaticShowSecurityAlertInDev", "StaticShowSecurityAlert"}
            for _, v in ipairs(funcs) do Higgs[v] = empty_func end
            Higgs.GetNetAvatarItemIDs = empty_table; Higgs.GetCurWeaponSkinID = zero_func
            Higgs.CheckAbnormalMovement = false_func; Higgs.CheckAbnormalSpeed = false_func
            Higgs.CheckAbnormalAim = false_func; Higgs.CheckAbnormalRecoil = false_func
            Higgs.bEnableCheck = false; Higgs.bMHActive = false
            Higgs.bEnableAvatarCheck = false; Higgs.bEnableWeaponCheck = false
            Higgs.bEnableMovementCheck = false; Higgs.bEnableReport = false
            if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
        end
    end)

    pcall(function()
        local SubsystemMgr = SafeRequire("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local banSub = SubsystemMgr:Get("BanSubsystem")
            if banSub then banSub.BanPlayer = empty_func; banSub.BanPlayerByUID = empty_func; banSub.CheckBanStatus = false_func; banSub.IsPlayerBanned = false_func end
            local vioSub = SubsystemMgr:Get("ViolationSubsystem")
            if vioSub then vioSub.RecordViolation = empty_func; vioSub.GetViolationLevel = zero_func; vioSub.CheckViolation = false_func end
        end
    end)

    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = empty_func
        _G.AvatarCheckCallback.OnReportItemID = empty_func
        _G.AvatarCheckCallback.ReportCheat = empty_func
        _G.AvatarCheckCallback.bEnableCheck = false
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(pc)
            if slua.isValid(pc) then
                if pc.HiggsBosonComponent then
                    pcall(function() pc.HiggsBosonComponent:ControlMHActive(0); pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bEnableCheck = false end)
                end
                pc.bEnableAntiCheat = false
            end
        end
    end
end

local function InitializeDeepProtection()
    local bypassModules = {
        { path = "client.slua.logic.common.security.MemoryScanner", funcs = {"Scan", "ReportScanResult", "OnMemoryViolation"}, bools = {"IsMemoryClean"}, flags = {"bEnableScanning", "bEnableReporting"} },
        { path = "client.slua.logic.common.security.ClientAntiTamper", funcs = {"ReportTamper", "OnTamperDetected", "StartCheck"}, bools = {"CheckIntegrity"}, flags = {"bEnableTamperCheck"} },
        { path = "GameLua.Mod.BaseMod.Common.Security.PacketInspector", funcs = {"InspectPacket", "ReportSuspiciousPacket", "OnPacketViolation"}, bools = {"ValidatePacket"}, flags = {"bEnableInspection"} },
        { path = "client.slua.logic.common.ClientErrorHandler", funcs = {"HandleError", "ReportError", "OnClientCrash"}, flags = {"bEnableErrorReporting"} }
    }
    for _, modDef in ipairs(bypassModules) do
        pcall(function()
            local mod = SafeRequire(modDef.path)
            if mod then
                for _, f in ipairs(modDef.funcs or {}) do mod[f] = empty_func end
                for _, f in ipairs(modDef.bools or {}) do mod[f] = true_func end
                for _, f in ipairs(modDef.flags or {}) do mod[f] = false end
            end
        end)
    end
end

local function InitializeGameplayAndNetwork()
    pcall(function()
        local gc = _G.GameplayCallbacks or _G.GC
        if gc and not gc.IsBypassed then
            local blockedFuncs = { "ReportAttackFlow", "ReportSecAttackFlow", "ReportHurtFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "SendDSErrorLogToLobby", "SendDSHawkEyePatrolLogToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportHeavyWeaponBoxSpawnFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportDSNetSaturation", "SendClientStats", "ReportCircleFlow", "ReportJumpFlow", "SendSecTLog", "SendDataMiningTLog", "SendActivityTLog", "SendBehaviorScoreTLog", "SendDSAntiCheatTLog", "SendBanRequest", "SendViolationReport", "SendCheatDetectionLog" }
            for _, f in ipairs(blockedFuncs) do gc[f] = empty_func end
            gc.GetWeaponReport = empty_table; gc.GetGeneralTLogData = nil_func; gc.IsBypassed = true
        end
    end)
end

local function InitializeUnrealNetworkShield()
    pcall(function()
        local UnrealNetwork = SafeRequire("Client.Network.UnrealNetwork", "GameLua.Mod.BaseMod.Common.UnrealNetwork")
        if UnrealNetwork then
            UnrealNetwork.HandleNetworkEvent = empty_func
            UnrealNetwork.HandleBattleExceptionReport = empty_func
           
            local orig_HandleNetworkException = UnrealNetwork.HandleNetworkException
            UnrealNetwork.HandleNetworkException = function(ExceptionType, ErrorMessage, bShouldWait, ...)
                local errStr = string.lower(tostring(ErrorMessage))
                local typeStr = string.lower(tostring(ExceptionType))
                local isCheatKick = string.find(errStr, "cheatdetected") or string.find(errStr, "kicked") or string.find(errStr, "banned") or string.find(errStr, "abnormal") or string.find(typeStr, "actorchannelerror")
                if isCheatKick then return end
                if orig_HandleNetworkException then pcall(orig_HandleNetworkException, ExceptionType, ErrorMessage, bShouldWait, ...) end
            end
            
            local orig_PostShowMsgBox = UnrealNetwork.PostShowMsgBox
            UnrealNetwork.PostShowMsgBox = function(ExceptionType, ErrorMessage, curStatus, bShouldWait)
                local errStr = string.lower(tostring(ErrorMessage))
                if string.find(errStr, "noplantocheatclient") or string.find(errStr, "kicked") then return end
                if orig_PostShowMsgBox then pcall(orig_PostShowMsgBox, ExceptionType, ErrorMessage, curStatus, bShouldWait) end
            end
        end
    end)

    pcall(function()
        local ProtocolFeature = SafeRequire("Client.Network.Protocol.NetworkProtocolFeature", "GameLua.Mod.BaseMod.Protocol.NetworkProtocolFeature")
        if ProtocolFeature then ProtocolFeature.SendGetClientReportReq = empty_func; ProtocolFeature.SendChatRateLogReq = empty_func; ProtocolFeature.SendClientOpResultReq = empty_func end
    end)
end

local function InitializeConnectionGuard()
    pcall(function()
        local GC = _G.GameplayCallbacks or _G.GC
        if not GC then return end

        local original_OnDSPlayerStateChanged = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            local sState = InPlayerState and string.lower(tostring(InPlayerState)) or ""
            local sReason = ParamReason and string.lower(tostring(ParamReason)) or ""
            local blockKeywords = { "cheatdetected", "connectionlost", "connectiontimeout", "connectionexception", "netdrivererror", "ban", "kick", "antihack", "speedhack", "aimbot", "wallhack", "modifiedfiles", "violation", "suspicious", "detected", "banned", "tempban", "1day", "7day", "1month" }
            for _, keyword in ipairs(blockKeywords) do
                if string.find(sState, keyword) or string.find(sReason, keyword) then return end
            end
            if original_OnDSPlayerStateChanged then pcall(original_OnDSPlayerStateChanged, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
        end

        local safeFuncs = {"OnPlayerNetConnectionClosed", "OnPlayerActorChannelError", "OnPlayerRPCValidateFailed", "OnPlayerSpectateException", "OnShutdownAfterError", "OnClientConnectionLost", "OnServerTravelFailure", "KickPlayer", "BanPlayer"}
        for _, f in ipairs(safeFuncs) do GC[f] = empty_func end
    end)
end

local function InitializeSyncProcessShield() end

local function InitAllAnti()
    local GameplayData = SafeRequire("GameLua.GameCore.Data.GameplayData")
    if not GameplayData then return end
    DisableGlobalAntiCheat()
    InitializeAntiReport()
    InitializeAntiCheatBypass()
    InitializeDeepProtection()
    InitializeGameplayAndNetwork()
    InitializeUnrealNetworkShield()
    InitializeConnectionGuard()
    InitializeSyncProcessShield()
end

-- ==========================================
-- 2. KHỞI TẠO TĨNH (UI MENU, 165FPS, IPAD)
-- ==========================================
local function TryShowWelcome() 
    if _G.LexusConfig.WelcomeShown then return end 
    
    pcall(function() 
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        _G.LexusConfig.WelcomeShown = true 

        local function FinalAction()
            local UIUtils = require("GameLua.Util.UIUtils")
            if UIUtils and UIUtils.ShowNotice then 
                UIUtils.ShowNotice("MENU HOÀN TẤT - CHÚC BẠN CHƠI GAME VUI VẺ!") 
            end
        end

        local function Step13_ZeroRecoilBounce() Msg.Show(2, "LESS SHAKE", "BẠN CÓ MUỐN BẬT GIẢM RUNG KHÔNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: KHÔNG BẬT", function() _G.LexusConfig.mZb = true; FinalAction() end, function() _G.LexusConfig.mZb = false; FinalAction() end) end
        local function Step12_MagicSilent() Msg.Show(2, "MAGIC BULLET", "BẠN CÓ MUỐN BẬT TĂNG HITBOX (MAGIC BULLET) KHÔNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: KHÔNG BẬT", function() _G.LexusConfig.mMs = true; Step13_ZeroRecoilBounce() end, function() _G.LexusConfig.mMs = false; Step13_ZeroRecoilBounce() end) end
        local function Step10_Accuracy() Msg.Show(2, "ĐƯỜNG ĐẠN", "BẠN MUỐN ĐẠN KHÔNG TỎA VÀ THẲNG HAY KHÔNG?\n\n[ĐỒNG Ý]: ĐẠN THẲNG KHÔNG TỎA\n[HỦY]: ĐẠN BÌNH THƯỜNG", function() _G.LexusConfig.mAc = true; Step12_MagicSilent() end, function() _G.LexusConfig.mAc = false; Step12_MagicSilent() end) end
        local function Step9_Crosshair() Msg.Show(2, "TÂM SÚNG", "BẠN MUỐN TÂM NHỎ HAY TÂM THƯỜNG?\n\n[ĐỒNG Ý]: TÂM NHỎ\n[HỦY]: TÂM THƯỜNG", function() _G.LexusConfig.mCh = true; Step10_Accuracy() end, function() _G.LexusConfig.mCh = false; Step10_Accuracy() end) end
        local function Step6_Aimbot() Msg.Show(2, "CÀI ĐẶT AIMBOT", "BẠN MUỐN BẬT AIMBOT XA HAY GẦN?\n\n[ĐỒNG Ý]: AIMBOT GẦN\n[HỦY]: AIMBOT XA", function() _G.LexusConfig.mAt = "Close"; _G.LexusConfig.mAk = true; Step9_Crosshair() end, function() _G.LexusConfig.mAt = "Far"; _G.LexusConfig.mAk = true; Step9_Crosshair() end) end
        local function Step5_Recoil() Msg.Show(2, "LESS RECOIL", "BẠN MUỐN BẬT GIẢM GIẬT KHÔNG?\n\n[ĐỒNG Ý]: BẬT GIẢM GIẬT\n[HỦY]: KHÔNG BẬT", function() _G.LexusConfig.mRc = true; Step6_Aimbot() end, function() _G.LexusConfig.mRc = false; Step6_Aimbot() end) end
        local function Step4_WhitePlayer() Msg.Show(2, "NGƯỜI TRẮNG", "BẠN CÓ MUỐN BẬT NGƯỜI TRẮNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: TẮT", function() _G.LexusConfig.mWp = true; Step5_Recoil() end, function() _G.LexusConfig.mWp = false; Step5_Recoil() end) end
        local function Step3_8_Stickman() Msg.Show(2, "ESP KHUNG XƯƠNG", "BẠN MUỐN BẬT KHUNG XƯƠNG (STICKMAN) KHÔNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: TẮT", function() _G.LexusConfig.mSm = true; Step4_WhitePlayer() end, function() _G.LexusConfig.mSm = false; Step4_WhitePlayer() end) end
        local function Step3_5_MapRadar() Msg.Show(2, "ESP ĐỊNH VỊ BẢN ĐỒ", "BẠN MUỐN BẬT CHẤM ĐỊNH VỊ TRÊN BẢN ĐỒ KHÔNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: TẮT", function() _G.LexusConfig.mMr = true; Step3_8_Stickman() end, function() _G.LexusConfig.mMr = false; Step3_8_Stickman() end) end
        local function Step3_WallHack() Msg.Show(2, "ESP KHUNG VÀ MÁU", "BẠN MUỐN BẬT HIỆN KHUNG VÀ THANH MÁU KẺ ĐỊCH KHÔNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: TẮT", function() _G.LexusConfig.mEw = true; Step3_5_MapRadar() end, function() _G.LexusConfig.mEw = false; Step3_5_MapRadar() end) end
        local function Step2_OutlineSize() Msg.Show(2, "ĐỘ DÀY VIỀN", "BẠN MUỐN VIỀN MÀU TO HAY NHỎ?\n\n[ĐỒNG Ý]: TO (Dày 10)\n[HỦY]: NHỎ (Dày 2)", function() _G.LexusConfig.mOt = 10; Step3_WallHack() end, function() _G.LexusConfig.mOt = 2; Step3_WallHack() end) end
        local function Step1_OutlineToggle() Msg.Show(2, "VIỀN ĐỊCH", "BẠN MUỐN BẬT VIỀN ĐỊCH HAY KHÔNG?\n\n[ĐỒNG Ý]: BẬT\n[HỦY]: TẮT", function() _G.LexusConfig.mEo = true; Step2_OutlineSize() end, function() _G.LexusConfig.mEo = false; Step3_WallHack() end) end
        local function Step0_Welcome() Msg.Show(2, "CHÀO MỪNG ĐẾN VỚI LUA VIP", "HÃY CHƠI MỘT CÁCH CẨN THẬN\nADMIN @Thanhdat1690", function() Step1_OutlineToggle() end, function() Step1_OutlineToggle() end) end
        Step0_Welcome()
    end)
end

local function InitSystemOnce()
    if _G.LexusSystemInitialized then return end
    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165"); gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end
        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
        end
    end)
    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg and SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 140 end
        if GraphicSettingDB and GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 140 end
    end)
    _G.LexusSystemInitialized = true
end

-- ==========================================
-- 3. XỬ LÝ VŨ KHÍ & MAGIC BULLET
-- ==========================================
local function ApplyWeaponMods(localPlayer)
    if not Valid(localPlayer) then return end
    pcall(function()
        local weapon = nil
        if localPlayer.GetCurrentWeapon then weapon = localPlayer:GetCurrentWeapon() end
        if not Valid(weapon) and localPlayer.GetCurrentShootWeapon then weapon = localPlayer:GetCurrentShootWeapon() end
        if not Valid(weapon) then return end
        
        local entity = weapon.ShootWeaponEntity_GEN_VARIABLE or weapon.ShootWeaponEntity or weapon.ShootWeaponEntityComp
        if not Valid(entity) then return end
        
        if _G.LexusConfig.mGm then
            entity.GameDeviationFactor = 0.0; entity.GameDeviationAccuracy = 0.0
            if entity.RecoilKickHIP then entity.RecoilKickHIP = 0.1 end
            if entity.ShotDeviationMax then entity.ShotDeviationMax = 0.0 end
            if entity.BulletFireSpeed then entity.BulletFireSpeed = 999999.0 end
            if entity.ShootInterval then entity.ShootInterval = 0.02 end 
            entity.BaseDamage = 150.0; entity.HitDamage = 150.0
        end

        if _G.LexusConfig.mCh then entity.GameDeviationFactor = 0.1 end
        if _G.LexusConfig.mAc then entity.GameDeviationAccuracy = 0.1 end
        if _G.LexusConfig.mRc then 
            entity.AccessoriesVRecoilFactor = 0.3 
            entity.AccessoriesHRecoilFactor = 0.3 
        end
        
        if _G.LexusConfig.mZb then
            entity.RecoilKick = 0.0; entity.RecoilKickADS = 0.01; entity.AnimationKick = 0.0
            if entity.RecoilInfo then
                entity.RecoilInfo.VerticalRecoilMin = 0; entity.RecoilInfo.VerticalRecoilMax = 0
                entity.RecoilInfo.RecoilSpeedVertical = 0; entity.RecoilInfo.RecoilSpeedHorizontal = 0
            end
            entity.RecoilModifierStand = 0; entity.RecoilModifierCrouch = 0; entity.RecoilModifierProne = 0
        end

        if _G.LexusConfig.mAk then
            entity.GameDeviationFactor = 0.1; entity.GameDeviationAccuracy = 0.1                 
            if entity.AutoAimingConfig then
                local cfg = entity.AutoAimingConfig
                if cfg.OuterRange then
                    cfg.OuterRange.Speed = 9.0; cfg.OuterRange.RangeRate = 9.0; cfg.OuterRange.SpeedRate = 9.0
                    cfg.OuterRange.RangeRateSight = 9.0; cfg.OuterRange.SpeedRateSight = 9.0; cfg.OuterRange.DyingRate = 0.0
                end
                if cfg.InnerRange then
                    cfg.InnerRange.Speed = 9.0; cfg.InnerRange.RangeRate = 9.0; cfg.InnerRange.SpeedRate = 9.0
                    cfg.InnerRange.RangeRateSight = 9.0; cfg.InnerRange.SpeedRateSight = 9.0; cfg.InnerRange.DyingRate = 0.0
                end
                entity.AutoAimingConfig = cfg
            end
        end
    end)
end

local function AKMOD_MAGIC_SILENT()
    if not _G.LexusConfig.mMs then return end 

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not okData or not GameplayData then return end
    
    local slua_mod = _G.slua or import("slua")
    local uLocalPlayer = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
    if not slua_mod or not slua_mod.isValid(uLocalPlayer) then return end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    for _, enemy in pairs(allCharacters) do
        if slua_mod.isValid(enemy) and enemy ~= uLocalPlayer and enemy.TeamID ~= uLocalPlayer.TeamID then
            local bIsActive = false
            pcall(function()
                local bDead = false
                if type(enemy.IsDead) == "function" then bDead = enemy:IsDead()
                elseif enemy.bIsDead ~= nil then bDead = enemy.bIsDead
                elseif enemy.bIsDeadFlag ~= nil then bDead = enemy.bIsDeadFlag end
                if enemy.Health and enemy.Health <= 0 then bDead = true end
                
                local bKnock = false
                if type(enemy.IsNearDeath) == "function" then bKnock = enemy:IsNearDeath()
                elseif enemy.bIsNearDeath ~= nil then bKnock = enemy.bIsNearDeath end
                
                if not bDead and not bKnock then bIsActive = true end
            end)

            if bIsActive then
                local mesh = enemy.Mesh or (enemy.getAvatarComponent2 and enemy:getAvatarComponent2())
                if slua_mod.isValid(mesh) and not mesh.AKMOD_INJECT_HOOK then
                    pcall(function()
                        local physAsset = mesh.PhysicsAssetOverride
                        if not slua_mod.isValid(physAsset) and mesh.SkeletalMesh then physAsset = mesh.SkeletalMesh.PhysicsAsset end

                        if slua_mod.isValid(physAsset) and physAsset.SkeletalBodySetups then
                            local AKMOD_HOOK_SILENT = { ["pelvis"] = { X=35, Y=33, Z=69.5 }, ["spine_03"] = { X=40, Y=33, Z=69.5 } }
                            local MAGIC_SILENT_CUSTOM_AKMOD = 3.0 
                            local bodySetups = physAsset.SkeletalBodySetups
                            
                            for i = 1, 50 do 
                                local bodySetup = nil
                                pcall(function() bodySetup = type(bodySetups.Get) == "function" and bodySetups:Get(i-1) or bodySetups[i] end)
                                if not bodySetup then break end
                                
                                if slua_mod.isValid(bodySetup) then
                                    local boneNameStr = string.lower(tostring(bodySetup.BoneName))
                                    local matchKey = nil
                                    for k, _ in pairs(AKMOD_HOOK_SILENT) do
                                        if string.find(boneNameStr, k) then matchKey = k break end
                                    end
                                    
                                    if matchKey then
                                        local baseSize = AKMOD_HOOK_SILENT[matchKey]
                                        local aggGeom = bodySetup.AggGeom
                                        local boxElems = aggGeom and aggGeom.BoxElems or bodySetup.BoxElems
                                        
                                        if boxElems then
                                            local box = type(boxElems.Get) == "function" and boxElems:Get(0) or boxElems[1]
                                            if box then
                                                box.X = baseSize.X * MAGIC_SILENT_CUSTOM_AKMOD
                                                box.Y = baseSize.Y * MAGIC_SILENT_CUSTOM_AKMOD
                                                box.Z = baseSize.Z * MAGIC_SILENT_CUSTOM_AKMOD
                                                
                                                if type(boxElems.Set) == "function" then boxElems:Set(0, box) else boxElems[1] = box end
                                                if aggGeom then aggGeom.BoxElems = boxElems; bodySetup.AggGeom = aggGeom else bodySetup.BoxElems = boxElems end
                                            end
                                        end
                                    end
                                end
                            end
                            pcall(function() if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end end)
                        end
                    end)            
                    mesh.AKMOD_INJECT_HOOK = true
                end
            end
        end
    end
end

-- ==========================================
-- 4. XỬ LÝ NHÂN VẬT & ESP
-- ==========================================
local function ApplyPlayerMods(localPlayer, pc, GameplayData)
    local FVector = import("Vector") or _G.FVector
    local zeroVec = FVector and FVector(0,0,0) or nil

    -- WHITE PLAYER & FOV
    pcall(function()
        if _G.LexusConfig.mWp then
            local lsg = require("client.slua.logic.setting.logic_setting_graphics")
            local gi = lsg.GetGameInstance and lsg.GetGameInstance()
            if gi then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5") 
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
            end
        end

        local SettingSubsystem = _G.SubsystemMgr and _G.SubsystemMgr:Get("SettingSubsystem")
        if SettingSubsystem then
            local rawSliderValue = SettingSubsystem:GetUserSettings_Int("TpViewValue") or 90
            local targetTPP = (rawSliderValue > 80 and rawSliderValue <= 90) and (80 + (rawSliderValue - 80) * 6.0) or rawSliderValue
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            end
        end
    end)

    -- [FIX XUYÊN TƯỜNG] Tắt kiểm tra vật cản của hệ thống Máu Native
    if not _G.LexusState.AK_NativeESP_Ready then
        pcall(function()
            local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
            local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
            
            if currentMarkCfg then
                if currentMarkCfg[1006] then
                    currentMarkCfg[1006].bBindBlocked = true     
                    currentMarkCfg[1006].bBindOutScreen = true   
                    currentMarkCfg[1006].MaxWidgetNum = 99
                    currentMarkCfg[1006].MaxShowDistance = 6000000
                    currentMarkCfg[1006].bScaleByDistance = false
                    currentMarkCfg[1006].BindSocketName = "root"
                    currentMarkCfg[1006].bUseLuaWorldSocketName = true
                    currentMarkCfg[1006].WorldPositionOffset = zeroVec and FVector(0, 0, -30)
                end

                if not currentMarkCfg[9999] then
                    currentMarkCfg[9999] = {
                        UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                        MaxWidgetNum = 99, MaxShowDistance = 6000000,
                        bBindOutScreen = true, bBindBlocked = true, bIsBindingActor = true,
                        BindSocketName = "head", bUseLuaWorldSocketName = true,
                        WorldPositionOffset = zeroVec and FVector(0, 0, 50), bNeedPreLoad = true, Priority = 2
                    }
                    local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
                    if InGameMarkTools and InGameMarkTools.ScreenMarkManager and InGameMarkTools.ScreenMarkManager.OnInitMarkGroupData then
                        pcall(function() InGameMarkTools.ScreenMarkManager:OnInitMarkGroupData(9999) end)
                    end
                end
            end

            local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
            local hpSub = SubsystemMgr:Get("ClientHPBarSubSystem")
            if hpSub then
                if hpSub.SetPauseCheck then hpSub:SetPauseCheck(true) end
                if hpSub.FocusActorCheckParam then
                    hpSub.FocusActorCheckParam.CheckBlock = false 
                    hpSub.FocusActorCheckParam.CheckDistance = 1000000
                end
            end
            
            local UIManager = _G.UIManager or import("UIManager")
            if UIManager and UIManager.GetUI then
                local enemyHpMain = UIManager.GetUI(UIManager.UI_Config_InGame.EnemyHpWidgetsMain)
                if Valid(enemyHpMain) then
                    if enemyHpMain.SetCheckBlock then enemyHpMain:SetCheckBlock(false) end
                end
            end
        end)
        _G.LexusState.AK_NativeESP_Ready = true
    end

    -- VÒNG LẶP ESP (KIỂM TRA BỎ QUA KNOCK / CHẾT)
    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then
            for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
        end

        local PPM = import("PostProcessManager"):GetInstance()
        local MyHUD = pc and pc.MyHUD
        local currentTime = os.clock()

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local eID = tostring(enemy.PlayerKey or enemy)
                
                local bIsActive = false
                pcall(function()
                    local bDead = false
                    if type(enemy.IsDead) == "function" then bDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bDead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then bDead = enemy.bIsDeadFlag end
                    if enemy.Health and enemy.Health <= 0 then bDead = true end

                    local bKnock = false
                    if type(enemy.IsNearDeath) == "function" then bKnock = enemy:IsNearDeath()
                    elseif enemy.bIsNearDeath ~= nil then bKnock = enemy.bIsNearDeath end
                    
                    if not bDead and not bKnock then bIsActive = true end
                end)

                -- CHỈ HIỂN THỊ KHI ĐỊCH CÒN SỐNG VÀ ĐỨNG YÊN (KHÔNG KNOCK/CHẾT)
                if bIsActive then
                    
                    -- 1. AVATAR OUTLINE
                    pcall(function()
                        local avatarComp = enemy.getAvatarComponent2 and enemy:getAvatarComponent2()
                        if Valid(avatarComp) and Valid(PPM) then
                            if _G.LexusConfig.mEo then
                                PPM.OutlineThickness = _G.LexusConfig.mOt or 10
                                if PPM.OutlineColor then PPM.OutlineColor = {r = 1, g = 0, b = 0, a = 1} end
                                PPM:EnableAvatarOutline(avatarComp, true)
                            else PPM:EnableAvatarOutline(avatarComp, false) end
                        end
                    end)

                    -- 2. ESP HUD MÁU XUYÊN TƯỜNG (MyHUD:AddDebugText)
                    if _G.LexusConfig.mEw then
                        pcall(function()
                            if Valid(MyHUD) then
                                local d = localPlayer:GetDistanceTo(enemy) / 100
                                if d <= 400 then
                                    local sc = math.max(0.6, 1.0 - (d / 600))
                                    local hp = enemy.Health or 100
                                    local maxHp = enemy.HealthMax or 100
                                    if maxHp <= 0 then maxHp = 100 end
                                    local per = hp / maxHp
                                    
                                    local name = enemy.PlayerName or enemy.Name or "Enemy"
                                    local weapon = enemy.CurrentWeapon or (type(enemy.GetCurrentWeapon)=="function" and enemy:GetCurrentWeapon())
                                    local weaponName = weapon and (weapon.WeaponName or weapon.Name or weapon.ItemName) or "Unarmed"
                                    local info = string.format("%s %.0fm", name, d)
                                    
                                    local c = {R=0, G=255, B=0, A=255}
                                    if per < 0.3 then c = {R=255, G=0, B=0, A=255}
                                    elseif per < 0.7 then c = {R=255, G=255, B=0, A=255} end

                                    local len = 10
                                    local bar = ""
                                    for i = 1, len do bar = bar .. (i <= math.floor(per * len) and "■" or "□") end

                                    local zW = d < 25 and 250 or 260
                                    local zT = d < 25 and 215 or 225
                                    local zB = d < 25 and 180 or 172

                                    MyHUD:AddDebugText("[" .. weaponName .. "]", enemy, 0.15, {X=0, Y=0, Z=zW}, {X=0, Y=0, Z=zW}, {R=255, G=165, B=0, A=255}, true, false, true, nil, 0.95 * sc, true)
                                    MyHUD:AddDebugText(info, enemy, 0.15, {X=0, Y=0, Z=zT}, {X=0, Y=0, Z=zT}, {R=255, G=255, B=255, A=255}, true, false, true, nil, 1.05 * sc, true)
                                    MyHUD:AddDebugText(bar, enemy, 0.15, {X=0, Y=0, Z=zB}, {X=0, Y=0, Z=zB}, c, true, false, true, nil, 0.9 * sc, true)
                                end
                            end
                        end)
                    end

                    -- 3. ESP KHUNG XƯƠNG ĐỘNG (LẤY TỌA ĐỘ BONE THỰC TẾ)
                    if _G.LexusConfig.mSm then
                        pcall(function()
                            if Valid(MyHUD) then
                                local mesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2())
                                if Valid(mesh) and type(mesh.GetSocketLocation) == "function" then
                                    local d = localPlayer:GetDistanceTo(enemy) / 100
                                    if d <= 400 then
                                        local sc = math.max(0.5, 1.0 - (d / 600))
                                        
                                        local aLoc = type(enemy.K2_GetActorLocation) == "function" and enemy:K2_GetActorLocation() or nil
                                        if aLoc then
                                            local cRed = {R=255, G=0, B=0, A=255}
                                            local cCyan = {R=0, G=255, B=255, A=255}
                                            
                                            local boneList = {
                                                "head", "neck_01", "pelvis", "Root",
                                                "upperarm_r", "lowerarm_r", "hand_r",
                                                "upperarm_l", "lowerarm_l", "hand_l",
                                                "thigh_l", "calf_l", "foot_l",
                                                "thigh_r", "calf_r", "foot_r"
                                            }

                                            for _, bName in ipairs(boneList) do
                                                local wLoc = nil
                                                pcall(function() wLoc = mesh:GetSocketLocation(bName) end)
                                                if wLoc then
                                                    -- Tính khoảng cách bù trừ giữa Xương và Tâm nhân vật
                                                    local ox = wLoc.X - aLoc.X
                                                    local oy = wLoc.Y - aLoc.Y
                                                    local oz = wLoc.Z - aLoc.Z
                                                    local offset = {X=ox, Y=oy, Z=oz}
                                                    
                                                    local mark = (bName == "head") and "●" or "o"
                                                    local size = (bName == "head") and (1.0 * sc) or (0.6 * sc)
                                                    local color = (bName == "head") and cRed or cCyan
                                                    
                                                    MyHUD:AddDebugText(mark, enemy, 0.15, offset, offset, color, true, false, true, nil, size, true)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    -- 4. MAP RADAR (1003) 
                    pcall(function()
                        if _G.LexusConfig.mMr then
                            local lastTime = _G.LexusState.LastMarkTime[eID] or 0
                            if (currentTime - lastTime) > 1.0 then
                                _G.LexusState.LastMarkTime[eID] = currentTime

                                local headLoc = nil
                                if type(enemy.GetHeadLocation) == "function" then headLoc = enemy:GetHeadLocation(false) end
                                if not headLoc and type(enemy.GetFuzzyPosition) == "function" and zeroVec then headLoc = enemy:GetFuzzyPosition(zeroVec) end

                                if headLoc then
                                    SafeRemoveMark(_G.LexusState.EnemyMarks[eID])
                                    _G.LexusState.EnemyMarks[eID] = SafeAddMark(1003, headLoc, 0, "", 4, nil)
                                end
                            end
                        else
                            if _G.LexusState.EnemyMarks[eID] then
                                SafeRemoveMark(_G.LexusState.EnemyMarks[eID])
                                _G.LexusState.EnemyMarks[eID] = nil
                            end
                        end
                    end)

                else
                    -- NẾU ĐỊCH CHẾT HOẶC KNOCK (HÒM XÁC) -> XÓA SẠCH DẤU VẾT
                    pcall(function()
                        local avatarComp = enemy.getAvatarComponent2 and enemy:getAvatarComponent2()
                        if Valid(avatarComp) and Valid(PPM) then
                            PPM:EnableAvatarOutline(avatarComp, false)
                        end
                    end)

                    if _G.LexusState.EnemyMarks[eID] then
                        SafeRemoveMark(_G.LexusState.EnemyMarks[eID])
                        _G.LexusState.EnemyMarks[eID] = nil
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 6. VÒNG LẶP CORE CHÍNH
-- ==========================================
local function MainLoop()
    if not _G.LexusState.BypassLoaded then InitAllAnti(); _G.LexusState.BypassLoaded = true end
    if not _G.LexusConfig.WelcomeShown then pcall(TryShowWelcome) end
    pcall(InitSystemOnce)

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not okData or not GameplayData then return end
    
    local pc = nil
    pcall(function() pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController() or GameplayData.GetPlayerController() end)
    
    local localPlayer = nil
    if Valid(pc) and pc.GetPlayerCharacterSafety then
        pcall(function() localPlayer = pc:GetPlayerCharacterSafety() end)
    end
    if not Valid(localPlayer) then
        pcall(function() localPlayer = GameplayData.GetPlayerCharacter() end)
    end

    if Valid(localPlayer) then
        ApplyWeaponMods(localPlayer)
        ApplyPlayerMods(localPlayer, pc, GameplayData)
        pcall(AKMOD_MAGIC_SILENT)
    end
end

_G.LexusState.LoopToken = (_G.LexusState.LoopToken or 0) + 1
local myToken = _G.LexusState.LoopToken

local function FastTick()
    if myToken ~= _G.LexusState.LoopToken then return end
    pcall(MainLoop)
    
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.1, FastTick) 
    end
end

FastTick()
Notify("Đã nạp thành công (Server-Side + Stickman Chuyển Động Xuyên Tường)!")
_G.LexusCoreLoaded = true
