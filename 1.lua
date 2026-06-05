-- ============================================================================
-- MOD MENU TAB INTEGRATION
-- ============================================================================

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
            -- Cheats Master Toggle
            {
                Key = "ModMenu_Cheats",
                UI = AliasMap.Switcher,
                Text = "MASTER CHEAT",
                GetFunc = function() return _G.CheatsEnabled or false end,
                SetFunc = function(_, value)
                    _G.CheatsEnabled = value
                    return true
                end
            },
            -- ESP/Wallhack Toggle
            {
                Key = "ModMenu_ESP",
                UI = AliasMap.Switcher,
                Text = "ESP / WALLHACK",
                GetFunc = function() return (_G.Mod_ESP_Enabled or false) and (_G.CheatsEnabled or false) end,
                SetFunc = function(_, value)
                    _G.Mod_ESP_Enabled = value
                    return true
                end
            },
            -- Aimbot Toggle
            {
                Key = "ModMenu_Aimbot",
                UI = AliasMap.Switcher,
                Text = "AIMBOT",
                GetFunc = function() return (_G.Mod_Aimbot_Enabled or false) and (_G.CheatsEnabled or false) end,
                SetFunc = function(_, value)
                    _G.Mod_Aimbot_Enabled = value
                    return true
                end
            },
            -- No Recoil Toggle
            {
                Key = "ModMenu_NoRecoil",
                UI = AliasMap.Switcher,
                Text = "NO RECOIL",
                GetFunc = function() return (_G.Mod_NoRecoil_Enabled or false) and (_G.CheatsEnabled or false) end,
                SetFunc = function(_, value)
                    _G.Mod_NoRecoil_Enabled = value
                    return true
                end
            },
            -- Title for Skins
            {
                Key = "Title_Skins",
                UI = AliasMap.TitleSwitcher,
                Text = "WEAPON SKINS",
                ExpandIndex = 0,
                GetFunc = function() return _G.Mod_Skins_Expand or false end,
                SetFunc = function(_, value)
                    _G.Mod_Skins_Expand = value
                    return true
                end
            }
        }
        
        -- Weapon Skins List
        local weaponSkinsList = {
            {key = "M416", id = 101004, text = "    M416 SKIN"},
            {key = "AKM", id = 101001, text = "    AKM SKIN"},
            {key = "SCAR", id = 101003, text = "    SCAR SKIN"},
            {key = "M762", id = 101008, text = "    M762 SKIN"},
            {key = "AWM", id = 103003, text = "    AWM SKIN"},
            {key = "Kar98", id = 103001, text = "    KAR98 SKIN"},
        }
        
        for _, weapon in ipairs(weaponSkinsList) do
            table.insert(ModMenuStack, {
                Key = "ModMenu_Skin_" .. weapon.key,
                UI = AliasMap.Edit,
                Text = weapon.text,
                ExpandHandle = "Title_Skins",
                GetFunc = function() 
                    return (_G.WeaponSkinMap and _G.WeaponSkinMap[weapon.id]) or 0 
                end,
                SetFunc = function(_, value)
                    if not _G.WeaponSkinMap then _G.WeaponSkinMap = {} end
                    _G.WeaponSkinMap[weapon.id] = tonumber(value) or 0
                    return true
                end
            })
        end
        
        -- Title for Outfits
        table.insert(ModMenuStack, {
            Key = "Title_Outfits",
            UI = AliasMap.TitleSwitcher,
            Text = "OUTFITS",
            ExpandIndex = 0,
            GetFunc = function() return _G.Mod_Outfits_Expand or false end,
            SetFunc = function(_, value)
                _G.Mod_Outfits_Expand = value
                return true
            end
        })
        
        -- Outfits List
        local outfitsList = {
            {key = "Suit", text = "    SUIT ID"},
            {key = "Hat", text = "    HAT ID"},
            {key = "Mask", text = "    MASK ID"},
            {key = "Glasses", text = "    GLASSES ID"},
            {key = "Pants", text = "    PANTS ID"},
            {key = "Shoes", text = "    SHOES ID"},
            {key = "Bag", text = "    BAG ID"},
            {key = "Helmet", text = "    HELMET ID"},
        }
        
        for _, outfit in ipairs(outfitsList) do
            table.insert(ModMenuStack, {
                Key = "ModMenu_Outfit_" .. outfit.key,
                UI = AliasMap.Edit,
                Text = outfit.text,
                ExpandHandle = "Title_Outfits",
                GetFunc = function()
                    return (_G.OutfitMap and _G.OutfitMap[outfit.key]) or 0
                end,
                SetFunc = function(_, value)
                    if not _G.OutfitMap then _G.OutfitMap = {} end
                    _G.OutfitMap[outfit.key] = tonumber(value) or 0
                    return true
                end
            })
        end
        
        -- Title for Vehicle Skins
        table.insert(ModMenuStack, {
            Key = "Title_Vehicles",
            UI = AliasMap.TitleSwitcher,
            Text = "VEHICLE SKINS",
            ExpandIndex = 0,
            GetFunc = function() return _G.Mod_Vehicles_Expand or false end,
            SetFunc = function(_, value)
                _G.Mod_Vehicles_Expand = value
                return true
            end
        })
        
        -- Vehicle Skins List
        local vehicleSkinsList = {
            {key = "Dacia", id = 1903001, text = "    DACIA SKIN"},
            {key = "UAZ", id = 1908001, text = "    UAZ SKIN"},
            {key = "Buggy", id = 1907001, text = "    BUGGY SKIN"},
        }
        
        for _, vehicle in ipairs(vehicleSkinsList) do
            table.insert(ModMenuStack, {
                Key = "ModMenu_Vehicle_" .. vehicle.key,
                UI = AliasMap.Edit,
                Text = vehicle.text,
                ExpandHandle = "Title_Vehicles",
                GetFunc = function()
                    return (_G.VehicleSkinMap and _G.VehicleSkinMap[vehicle.id]) or 0
                end,
                SetFunc = function(_, value)
                    if not _G.VehicleSkinMap then _G.VehicleSkinMap = {} end
                    _G.VehicleSkinMap[vehicle.id] = tonumber(value) or 0
                    return true
                end
            })
        end
        
        -- ESP Colors Title
        table.insert(ModMenuStack, {
            Key = "Title_ESP_Colors",
            UI = AliasMap.TitleSwitcher,
            Text = "ESP COLORS",
            ExpandIndex = 0,
            GetFunc = function() return _G.Mod_ESP_Color_Expand or false end,
            SetFunc = function(_, value)
                _G.Mod_ESP_Color_Expand = value
                return true
            end
        })
        
        -- ESP Color Options
        local colorNames = {"RED", "YELLOW", "GREEN", "BLUE", "PURPLE"}
        for i, colorName in ipairs(colorNames) do
            table.insert(ModMenuStack, {
                Key = "ModMenu_Color_" .. i,
                UI = AliasMap.Switcher,
                Text = "       " .. colorName,
                ExpandHandle = "Title_ESP_Colors",
                GetFunc = function()
                    return (_G.Mod_ESP_Color_Index or 1) == i and (_G.Mod_ESP_Enabled or false)
                end,
                SetFunc = function(_, value)
                    if value then
                        _G.Mod_ESP_Color_Index = i
                        if _G.EventSystem and _G.EVENTTYPE_SETTING and _G.EVENTID_SETTING_OPTION_FORCEUPDATE then
                            for j = 1, #colorNames do
                                _G.EventSystem:postEvent(_G.EVENTTYPE_SETTING, _G.EVENTID_SETTING_OPTION_FORCEUPDATE, "ModMenu_Color_" .. j)
                            end
                        end
                    end
                    return true
                end
            })
        end
        
        -- FPS Unlock
        table.insert(ModMenuStack, {
            Key = "ModMenu_165FPS",
            UI = AliasMap.Switcher,
            Text = "UNLOCK 165 FPS",
            GetFunc = function() return _G.Mod_165FPS_Enabled or false end,
            SetFunc = function(_, value)
                _G.Mod_165FPS_Enabled = value
                if value and _G.Enable165FPSLogic then
                    _G.Enable165FPSLogic()
                end
                return true
            end
        })
        
        -- iPad View
        table.insert(ModMenuStack, {
            Key = "ModMenu_iPadView",
            UI = AliasMap.Switcher,
            Text = "IPAD VIEW (FOV)",
            GetFunc = function() return _G.Mod_iPadView_Enabled or false end,
            SetFunc = function(_, value)
                _G.Mod_iPadView_Enabled = value
                if value and _G.EnableiPadViewUI then
                    _G.EnableiPadViewUI()
                end
                return true
            end
        })
        
        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            loc = "VIP MOD MENU",
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

    -- Hook UI Manager
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

-- ============================================================================
-- FEATURES INTEGRATION (Merged from bypass)
-- ============================================================================

-- Per-match guard
do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._MOD_LOADED and _G._MOD_PC == pc then 
        InitModMenuTab()
        return 
    end
    _G._MOD_LOADED = true
    _G._MOD_PC = pc
end

-- Default values
_G.CheatsEnabled = true
_G.Mod_ESP_Enabled = true
_G.Mod_Aimbot_Enabled = true
_G.Mod_NoRecoil_Enabled = true
_G.Mod_ESP_Color_Index = 1
_G.Mod_ESP_Color_Expand = false
_G.Mod_Skins_Expand = false
_G.Mod_Outfits_Expand = false
_G.Mod_Vehicles_Expand = false
_G.Mod_165FPS_Enabled = true
_G.Mod_iPadView_Enabled = true

-- Weapon Skin Maps
_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}

local require = require
local import = import
local isValid = slua.isValid

local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end

local function safe_require(path)
    local ok, mod = pcall(require, path)
    return ok and mod or nil
end

local ok_gd, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
if not ok_gd then GameplayData = nil end

-- ==================== COMPLETE BYPASS ====================

-- 1. SLUA BYPASS
pcall(function()
    if slua and slua.getSignature then
        slua.getSignature = function() return 0xDEADBEEF end
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
end)

-- 2. MD5 & PAK BYPASS
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
    if _G.MD5Hash then
        _G.MD5Hash = function() return "00000000000000000000000000000000" end
    end
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if STExtraBlueprintFunctionLibrary then
        if STExtraBlueprintFunctionLibrary.CheckMD5 then STExtraBlueprintFunctionLibrary.CheckMD5 = function() return true end end
        if STExtraBlueprintFunctionLibrary.GetMD5 then STExtraBlueprintFunctionLibrary.GetMD5 = function() return "BYPASS" end end
    end
end)

-- 3. MAIN BYPASS INIT
pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
    if not Msg then Msg = require("client.slua.logic.common.logic_common_msg_box") end
    if Msg and Msg.Show then
        Msg.Show(4, "VIP MOD", "ALL FEATURES ACTIVE\nPlay Safe")
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

-- 4. HIGGS BOSON BYPASS
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

-- 5. CORONA LAB BYPASS
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
end)

-- 6. PLAYER SECURITY INFO BYPASS
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
end)

-- 7. CLIENT CIRCLE FLOW BYPASS
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
end)

-- 8. MODIFIER EXCEPTION BYPASS
pcall(function()
    if _G.bReportedModifierException then _G.bReportedModifierException = false end
    local ModifierSubsystem = safe_require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
    if ModifierSubsystem then
        ModifierSubsystem.ReportException = nop
        ModifierSubsystem.CheckModifier = function() return true end
        ModifierSubsystem.ValidateModifier = function() return true end
    end
end)

-- 9. SIMULATE CHARACTER LOCATION BYPASS
pcall(function()
    local SimulateSubsystem = safe_require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
    if SimulateSubsystem then
        SimulateSubsystem.ReportLocation = nop
        SimulateSubsystem.SendLocationData = nop
    end
end)

-- 10. SHOOT VERIFICATION BYPASS
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
end)

-- 11. BAN LOGIC BYPASS
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

-- 12. REPORT SUBSYSTEM BYPASS
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

-- 13. TLOG BYPASS
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

-- 14. NETWORK PACKET BLOCK
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
            ["report_net_saturate"]=1,["report_speed_hack"]=1,["report_wall_hack"]=1,
            ["report_aim_bot"]=1,["report_esp_usage"]=1,["report_modded_files"]=1,
            ["detect_cheat"]=1,["ban_player"]=1,["client_anti_cheat_report"]=1,
            ["RPC_ClientCoronaLab"]=1,["CoronaLabReport"]=1,["CoronaLabData"]=1,
            ["PlayerSecurityInfo"]=1,["ReportSecurityInfo"]=1,["SendSecurityData"]=1,
            ["ClientCircleFlow"]=1,["IsEnableReportPlayerKillFlow"]=1,
            ["IsEnableReportMrpcsInCircleFlow"]=1,["IsEnableReportMrpcsInPartCircleFlow"]=1,
            ["bReportedModifierException"]=1,["ReportModifierException"]=1,
            ["RPC_Server_ReportSimulateCharacterLocation"]=1,["ReportSimulateCharacterLocation"]=1,
            ["RPC_Client_ShootVertifyRes"]=1,["BulletHitInfoUploadData"]=1,
            ["ShootVerifyFailed"]=1,["report_unrealnet_exception"]=1,["tss_sdk_report"]=1,
        }
        NetUtil.SendPacket = function(packetName, ...)
            if blockedPackets[packetName] then return nil end
            return originalSend(packetName, ...)
        end
        NetUtil.IsBypassed = true
    end
end)

-- 15. KILL ALL SECURITY SUBSYSTEMS
local function KillAllSecuritySubsystems()
    pcall(function()
        local subMgr = safe_require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local subsystemsToKill = {
            "CoronaLabSubsystem","PlayerSecurityInfoSubsystem","ClientCircleFlowSubsystem",
            "ModifierExceptionSubsystem","SimulateCharacterSubsystem","ShootVerifySubSystemClient",
            "HiggsBosonComponent","ClientReportPlayerSubsystem","DSReportPlayerSubsystem",
            "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem","ClientDataStatistcsSubsystem",
            "AFKReportorSubsystem","BehaviorScoreSubsystem","FileCheckSubsystem",
            "MemoryCheckSubsystem","SpeedCheckSubsystem","WallCheckSubsystem",
            "AvatarExceptionSubsystem","GameReportSubsystem","RescueBtnReplayTraceSubsystem"
        }
        for _, name in ipairs(subsystemsToKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate")) then
                        pcall(function() sub[k] = nop end)
                    end
                end
            end
        end
    end)
end

-- 16. PERSISTENT TIMER
local function huntAndKillAll()
    pcall(function()
        local subNames = {
            "ClientHawkEyePatrolSubsystem","DSHawkEyePatrolSubsystem","ClientReportPlayerSubsystem",
            "DSReportPlayerSubsystem","ClientGlueHiaSystem","ClientDataStatistcsSubsystem",
            "ICTLogSubsystem","DSFightTLogSubsystem","DSSecurityTLogSubsystem","AFKReportorSubsystem",
            "BehaviorScoreSubsystem","CoronaLabSubsystem","PlayerSecurityInfoSubsystem",
            "ClientCircleFlowSubsystem","ModifierExceptionSubsystem","SimulateCharacterSubsystem"
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
    KillAllSecuritySubsystems()
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
        print("[BYPASS] Security subsystems killed")
    else
        local fb = slua_GameFrontendHUD or Game
        if fb and isValid(fb) then fb:AddGameTimer(2.0, false, finalStart) end
    end
end
finalStart()

-- ============================================================================
-- SKINS SYSTEM
-- ============================================================================

local BASE_PATH = "/storage/emulated/0/Android/data/com.pubg.imobile/files/"
local CONFIG_PATH = BASE_PATH .. "config.ini"

_G.SkinLoadedCache = _G.SkinLoadedCache or {}

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
                    if     k == "Suit"      then _G.OutfitMap.Suit      = val
                    elseif k == "Hat"       then _G.OutfitMap.Hat       = val
                    elseif k == "Mask"      then _G.OutfitMap.Mask      = val
                    elseif k == "Glasses"   then _G.OutfitMap.Glasses   = val
                    elseif k == "Pants"     then _G.OutfitMap.Pants     = val
                    elseif k == "Shoes"     then _G.OutfitMap.Shoes     = val
                    elseif k == "Bag"       then _G.OutfitMap.Bag       = val
                    elseif k == "Helmet"    then _G.OutfitMap.Helmet    = val
                    elseif k == "M416"      then _G.WeaponSkinMap[101004] = val
                    elseif k == "AKM"       then _G.WeaponSkinMap[101001] = val
                    elseif k == "SCAR"      then _G.WeaponSkinMap[101003] = val
                    elseif k == "M762"      then _G.WeaponSkinMap[101008] = val
                    elseif k == "AWM"       then _G.WeaponSkinMap[103003] = val
                    elseif k == "Kar98"     then _G.WeaponSkinMap[103001] = val
                    elseif k == "Dacia"     then _G.VehicleSkinMap[1903001] = val
                    elseif k == "UAZ"       then _G.VehicleSkinMap[1908001] = val
                    elseif k == "Buggy"     then _G.VehicleSkinMap[1907001] = val
                    end
                end
            end
        end
    end)
end
_G.ReadLiveConfig = ReadLiveConfig

_G.get_skin_id = function(weaponID)
    if not weaponID or weaponID == 0 then return nil end
    local mapped = _G.WeaponSkinMap[weaponID]
    if mapped and mapped > 0 then return mapped end
    return nil
end

_G.ApplyWeaponSkins = function(pawn)
    if not isValid(pawn) then return end
    pcall(function()
        local wm = pawn:GetWeaponManager()
        if not isValid(wm) then return end
        for i = 1, 3 do
            local wpn = wm:GetInventoryWeaponByPropSlot(i)
            if isValid(wpn) then
                local targetID = _G.get_skin_id(wpn:GetWeaponID())
                if targetID and targetID > 0 then
                    if not _G.SkinLoadedCache[targetID] then
                        pcall(_G.download_item, targetID)
                        _G.SkinLoadedCache[targetID] = true
                    end
                    if wpn.SetWeaponAvatarID then
                        wpn:SetWeaponAvatarID(targetID)
                    end
                end
            end
        end
    end)
end

_G.ApplyLocalPlayerSkins = function(p)
    if not isValid(p) then return end
    _G.ApplyWeaponSkins(p)
    
    pcall(function()
        local ac = p:getAvatarComponent2()
        if isValid(ac) and ac.NetAvatarData then
            for slot, id in pairs(_G.OutfitMap) do
                if id and id > 0 then
                    if not _G.SkinLoadedCache[id] then
                        pcall(_G.download_item, id)
                        _G.SkinLoadedCache[id] = true
                    end
                    ac:PutOnCustomEquipmentByID(id, {})
                end
            end
        end
    end)
end

-- ============================================================================
-- ESP / WALLHACK
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

local function ApplyWallHack(localPlayer, enemy, pc)
    if not _G.CheatsEnabled or not _G.Mod_ESP_Enabled then return end
    if not slua.isValid(enemy) then return end
    
    pcall(function()
        if slua.isValid(enemy.Mesh) then
            enemy.Mesh.UseScopeDistanceCulling = false
            enemy.Mesh.PrimitiveShadingStrategy = 1
        end
    end)
end

local function ESPTick()
    if not _G.CheatsEnabled or not _G.Mod_ESP_Enabled then return end
    
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
                local distM = dist / 100

                if dist < 600000 and HUD then
                    local name = tPawn.PlayerName or "UNKNOWN"
                    local colorTable = {
                        [1] = {R=255,G=0,B=0,A=255},   -- RED
                        [2] = {R=255,G=255,B=0,A=255}, -- YELLOW
                        [3] = {R=0,G=255,B=0,A=255},   -- GREEN
                        [4] = {R=0,G=0,B=255,A=255},   -- BLUE
                        [5] = {R=128,G=0,B=128,A=255}, -- PURPLE
                    }
                    local espColor = colorTable[_G.Mod_ESP_Color_Index or 1] or colorTable[1]
                    
                    HUD:AddDebugText(string.format("[%.0fm] %s", distM, name), tPawn, 0.7, 
                        {X=0,Y=0,Z=100}, {X=0,Y=0,Z=100}, espColor, true, false, true, nil, 1.0, true)
                    
                    pcall(ApplyWallHack, currentPawn, tPawn, uCon)
                end
            end
        end
    end
end

pcall(function()
    local function StartESP(targetActor)
        if not isValid(targetActor) then return end
        cachedPawns = {}
        lastPawnRefresh = 0
        _G._ESPTimerHandle = targetActor:AddGameTimer(0.15, true, function()
            pcall(ESPTick)
        end)
    end

    local function Watchdog()
        pcall(function()
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
            local curPawn = pc and pc:GetCurPawn()
            if isValid(curPawn) then
                if _G._ESPTimerHandle and isValid(_G._ESPTimerChar) and _G._ESPTimerChar ~= curPawn then
                    pcall(function() _G._ESPTimerChar:RemoveGameTimer(_G._ESPTimerHandle) end)
                end
                _G._ESPTimerChar = curPawn
                StartESP(curPawn)
            end
        end)
    end

    _G._ESPWatchdogHandle = Game:SetTimer(1.0, true, Watchdog)
    Watchdog()
end)

-- ============================================================================
-- AIMBOT + NO RECOIL
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
        
        -- NO RECOIL (if enabled)
        if _G.Mod_NoRecoil_Enabled then
            shootComp.RecoilKick = 0.0
            shootComp.RecoilKickADS = 0.0
            shootComp.AnimationKick = 0.0
            shootComp.AccessoriesVRecoilFactor = 0.0
            shootComp.AccessoriesHRecoilFactor = 0.0
            shootComp.GameDeviationFactor = 0.0
            shootComp.GameDeviationAccuracy = 0.0
            
            if shootComp.RecoilInfo then
                shootComp.RecoilInfo.VerticalRecoilMin = 0.0
                shootComp.RecoilInfo.VerticalRecoilMax = 0.0
                shootComp.RecoilInfo.RecoilSpeedVertical = 0.0
                shootComp.RecoilInfo.RecoilSpeedHorizontal = 0.0
            end
        end
        
        -- AIMBOT (if enabled)
        if _G.Mod_Aimbot_Enabled then
            if shootComp.AutoAimingConfig then
                if shootComp.AutoAimingConfig.OuterRange then
                    shootComp.AutoAimingConfig.OuterRange.Speed = 8.0
                    shootComp.AutoAimingConfig.OuterRange.SpeedRate = 6.0
                end
                if shootComp.AutoAimingConfig.InnerRange then
                    shootComp.AutoAimingConfig.InnerRange.Speed = 10.0
                    shootComp.AutoAimingConfig.InnerRange.SpeedRate = 8.0
                end
                shootComp.AutoAimingConfig.adsorbMaxRange = 200.0
            end
            
            if shootComp.AimAssistConfig then
                shootComp.AimAssistConfig.bEnableAimAssist = true
                shootComp.AimAssistConfig.AimAssistStrength = 0.85
            end
            
            -- Aim at head
            pcall(function()
                local aimComp = char.BP_AutoAimingComponent_C or char.AutoAimingComponent
                if slua.isValid(aimComp) and aimComp.Bones then
                    pcall(function()
                        if aimComp.Bones.Set then
                            aimComp.Bones:Set(0, "head")
                        else
                            aimComp.Bones[0] = "head"
                        end
                    end)
                end
            end)
        end
    end)
end

local function StartAimbotTimer()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        if _G._AimbotTimerActive and _G._AimbotTimerPC == pc then return end
        
        _G._AimbotTimerPC = pc
        _G._AimbotTimerActive = true
        
        pc:AddGameTimer(0.15, true, function()
            pcall(ApplyAimbotAndNoRecoil)
        end)
    end)
end

StartAimbotTimer()

-- ============================================================================
-- FPS UNLOCK & IPAD VIEW
-- ============================================================================

_G.Enable165FPSLogic = function()
    if not _G.Mod_165FPS_Enabled then return end
    pcall(function()
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then 
                    self:ExecuteCMD("t.MaxFPS", "165")
                    self:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end
    end)
end

_G.EnableiPadViewUI = function()
    if not _G.Mod_iPadView_Enabled then return end
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

-- ============================================================================
-- SKIN TIMER
-- ============================================================================

_G._SetupSkinTimer = function()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not (pc and slua.isValid(pc)) then return end
        if _G.SkinTimerPC == pc then return end
        _G.SkinTimerPC = pc
        
        pc:AddGameTimer(0.5, true, function()
            pcall(function()
                local lpc = slua_GameFrontendHUD:GetPlayerController()
                if not (lpc and slua.isValid(lpc)) then return end
                local pawn = lpc:GetPlayerCharacterSafety()
                if not (pawn and slua.isValid(pawn)) then return end
                
                _G.ReadLiveConfig()
                _G.ApplyLocalPlayerSkins(pawn)
            end)
        end)
    end)
end

_G._SetupSkinTimer()

-- ============================================================================
-- INITIALIZE MOD MENU
-- ============================================================================

InitModMenuTab()

print("[VIP MOD] Fully Loaded - All Features Active")
print("  ✓ ESP / Wallhack")
print("  ✓ Aimbot")
print("  ✓ No Recoil")
print("  ✓ Weapon Skins")
print("  ✓ Outfits")
print("  ✓ Vehicle Skins")
print("  ✓ 165 FPS Unlock")
print("  ✓ iPad View (FOV)")
print("  ✓ Complete Bypass")
