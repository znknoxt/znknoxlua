-- OPTIMIZED VERSION - HIGH PERFORMANCE / LOW LAG
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local KismetMathLibrary = import("KismetMathLibrary")
local GameplayStatics = import("GameplayStatics")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")

-- ============================================
-- EXPIRE DATE SYSTEM (RUN ONCE)
-- ============================================
local EXPIRE_DATE = "2026-05-28"
local EXPIRATION_CHECK = nil
local function CheckExpiration()
    if EXPIRATION_CHECK ~= nil then return EXPIRATION_CHECK end
    local current = os.date("*t")
    local expire = {}
    EXPIRE_DATE:gsub("(%d+)", function(d) table.insert(expire, tonumber(d)) end)
    expire = {year=expire[1], month=expire[2], day=expire[3]}
    
    if current.year > expire.year or 
       (current.year == expire.year and current.month > expire.month) or
       (current.year == expire.year and current.month == expire.month and current.day > expire.day) then
        EXPIRATION_CHECK = false
        return false
    end
    EXPIRATION_CHECK = true
    return true
end

local function GetDaysRemaining()
    local current = os.date("*t")
    local expire = {}
    EXPIRE_DATE:gsub("(%d+)", function(d) table.insert(expire, tonumber(d)) end)
    expire = {year=expire[1], month=expire[2], day=expire[3], hour=23, min=59, sec=59}
    local current_time = os.time(current)
    local expire_time = os.time(expire)
    return math.ceil((expire_time - current_time) / 86400)
end

local function ShowExpirePopup()
    if _G.ExpirePopupShown then return end
    _G.ExpirePopupShown = true
    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local Web = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
        local function onClickTelegram() if Web then Web:OpenURL("https://t.me/ADITYA_ORG") end end
        Msg.Show(4, "MOD EXPIRED", "YOUR MOD EXPIRE UPDATE NOW\nCONTACT FOR DM @ADITYA_ORG FOR MASSAGE UPDATE FILES", onClickTelegram)
    end)
end

local function ShowDaysRemainingPopup()
    if _G.DaysRemainingShown then return end
    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local days = GetDaysRemaining()
        local message = string.format("MOD ACTIVE - %d DAYS REMAINING\nEXPIRES: %s\nCONTACT FOR @ADITYA_ORG  NEW UPDATED FILES", days, EXPIRE_DATE)
        local function onClickTelegram()
            local Web = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
            if Web then Web:OpenURL("https://t.me/ADITYA_ORG") end
        end
        Msg.Show(4, "MODDED BY @ADITYA_ORG", message, onClickTelegram)
        _G.DaysRemainingShown = true
    end)
end

-- ============================================
-- SKIN SYSTEM CONFIG (CACHED)
-- ============================================
_G.OutfitSkins = {
    Suit = {403317,1406469,1405870,1407140,1407141,1407142,1407550,1406638,1406872,1406971,1407103},
    Bag = {501001,1501001174,1501001220,1501001051,1501001443,1501001265,1501001321,1501001277},
    Helmet = {502001,1502001014,1502001349,1502001012,1502001009,1502001397,1502001390},
}
_G.SuitSkin, _G.BagSkin, _G.HelmetSkin = 0, 0, 0
_G.TargetLobbyThemeID = 202408001
_G.LastAppliedSkins = {suit=0, bag=0, helmet=0} -- OPTIMIZED: cache last applied

function _G.TryShowWelcome()
    if _G.WelcomeShown then return end
    if not CheckExpiration() then ShowExpirePopup() return end
    pcall(function()
        ShowDaysRemainingPopup()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        local Web = package.loaded["client.slua.logic.url.logic_webview_sdk"] or require("client.slua.logic.url.logic_webview_sdk")
        local function onClickDirect()
            if Web then Web:OpenURL("https://t.me/ADITYA_ORG") end
            local UIUtils = require("GameLua.Util.UIUtils")
            if UIUtils and UIUtils.ShowNotice then UIUtils.ShowNotice("[TELE @ADITYA_ORG] ACTIVE") end
        end
        Msg.Show(4, "NOTIFICATION FROM @ADITYA_ORG", "WELCOME TO LUA VIP\nPLAY CAREFULLY AND ENJOY\nADMIN @ADITYA_ORG\nHAVE A GREAT GAME AND DAILY UPDATED FILES FOR JOIN TELEGRAM CHANNEL", onClickDirect)
        _G.WelcomeShown = true
    end)
end

-- ============================================
-- LIVE CONFIG READER (RUN ONCE)
-- ============================================
local CONFIG_READ = false
local function ReadLiveConfig()
    if CONFIG_READ then return end
    if not CheckExpiration() then return end
    CONFIG_READ = true
    pcall(function()
        local f = io.open('/storage/emulated/0/Android/data/com.pubg.imobile/files/config.ini', 'r')
        if not f then return end
        local content = f:read('*all')
        f:close()
        for line in content:gmatch('[^\r\n]+') do
            local k, v = line:match('(%w+)%s*=%s*(%d+)')
            if k and v then
                local val = tonumber(v) + 1
                if k == 'Suit' then _G.SuitSkin = _G.OutfitSkins.Suit[val] or 0
                elseif k == 'Bag' then _G.BagSkin = _G.OutfitSkins.Bag[val] or 0
                elseif k == 'Helmet' then _G.HelmetSkin = _G.OutfitSkins.Helmet[val] or 0
                elseif k == 'LobbyTheme' then _G.TargetLobbyThemeID = tonumber(v)
                end
            end
        end
    end)
end

-- ============================================
-- SKIN INJECTOR (OPTIMIZED - ONLY WHEN CHANGED)
-- ============================================
local function ApplyAllModSkins(p)
    if not CheckExpiration() or not p or not slua.isValid(p) then return end
    -- OPTIMIZED: skip if no skins configured
    if _G.SuitSkin == 0 and _G.BagSkin == 0 and _G.HelmetSkin == 0 then return end
    
    if p.AvatarComponent2 and p.AvatarComponent2.NetAvatarData then
        local applyData = p.AvatarComponent2.NetAvatarData.SlotSyncData
        if applyData then
            local ref = false
            for i = 0, applyData:Num() - 1 do
                local eq = applyData:Get(i)
                if eq and eq.ItemId ~= 0 then
                    local target = 0
                    if eq.SlotID == 5 and _G.SuitSkin ~= 0 and _G.LastAppliedSkins.suit ~= _G.SuitSkin then 
                        target = _G.SuitSkin
                        _G.LastAppliedSkins.suit = _G.SuitSkin
                    elseif eq.SlotID == 8 and _G.BagSkin ~= 0 and _G.LastAppliedSkins.bag ~= _G.BagSkin then 
                        target = _G.BagSkin
                        _G.LastAppliedSkins.bag = _G.BagSkin
                    elseif eq.SlotID == 9 and _G.HelmetSkin ~= 0 and _G.LastAppliedSkins.helmet ~= _G.HelmetSkin then 
                        target = _G.HelmetSkin
                        _G.LastAppliedSkins.helmet = _G.HelmetSkin
                    end
                    if target ~= 0 and eq.ItemId ~= target then
                        eq.ItemId = target
                        applyData:Set(i, eq)
                        ref = true
                    end
                end
            end
            if ref then p.AvatarComponent2:OnRep_BodySlotStateChanged() end
        end
    end
end

local LOBBY_THEME_APPLIED = false
local function ApplyLobbyTheme()
    if LOBBY_THEME_APPLIED then return end
    if not CheckExpiration() then return end
    pcall(function()
        if not _G.TargetLobbyThemeID then return end
        local t = slua.loadObject("Blueprint'/Game/Lobby/Level/LobbyTheme.LobbyTheme'")
        if slua.isValid(t) then
            local obj = slua.createBObj("LobbyTheme", t)
            if slua.isValid(obj) then 
                obj:OnChangeLobbyTheme(_G.TargetLobbyThemeID) 
                LOBBY_THEME_APPLIED = true
            end
        end
    end)
end

-- ============================================
-- 165 FPS LOGIC (RUN ONCE - OPTIMIZED)
-- ============================================
local FPS_PATCHED = false
_G.Enable165FPSLogic = function()
    if FPS_PATCHED then return end
    FPS_PATCHED = true
    pcall(function()
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then
                    local gi = GameplayData.GetGameInstance()
                    if gi then
                        gi:ExecuteCMD("t.MaxFPS", "165")
                        gi:ExecuteCMD("r.FrameRateLimit", "165")
                    end
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
                if gi then
                    gi:ExecuteCMD("t.MaxFPS", tostring(val))
                    gi:ExecuteCMD("r.FrameRateLimit", tostring(val))
                end
            end
            function impl:OnFPSFTAdd3()
                local cur = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB").GetUIData(db.FPSFineTuneNum) or 90
                self:OnFPSFTValueChange3(math.min(165, cur))
            end
            function impl:OnFPSFTMinus3()
                local cur = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB").GetUIData(db.FPSFineTuneNum) or 90
                self:OnFPSFTValueChange3(math.max(MIN, 5))
            end
            impl.OnFPSFTAdd = impl.OnFPSFTAdd3
            impl.OnFPSFTMinus = impl.OnFPSFTMinus3
        end
    end)
end

-- ============================================
-- IPAD VIEW UI (RUN ONCE)
-- ============================================
local IPAD_VIEW_PATCHED = false
_G.EnableiPadViewUI = function()
    if IPAD_VIEW_PATCHED then return end
    IPAD_VIEW_PATCHED = true
    pcall(function()
        local sc = require("client.logic.setting.setting_config")
        if sc then
            if sc.TpViewValue then sc.TpViewValue.max = 140 end
            if sc.FpViewValue then sc.FpViewValue.max = 140 end
        end
        local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if db and db.TpViewValue then db.TpViewValue.max = 140 end
    end)
end

-- Execute FPS and iPad View features (RUN ONCE)
_G.Enable165FPSLogic()
_G.EnableiPadViewUI()

-- ============================================
-- NO GRASS (RUN ONCE)
-- ============================================
local GRASS_REMOVED = false
local function RemoveGrass()
    if GRASS_REMOVED then return end
    if not Client then return end
    if not CheckExpiration() then return end
    GRASS_REMOVED = true
    pcall(function()
        local gi = GameplayData.GetGameInstance()
        if gi then
            gi:ExecuteCMD("grass.DensityScale", "0")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
        end
    end)
end

-- ============================================
-- MAGIC BULLET (RUN ONCE - CACHED PHYSICS)
-- ============================================
local MAGIC_BULLET_APPLIED = false
local PHYSICS_CACHE = {} -- OPTIMIZED: cache modified assets
local function EnableMagicBullet()
    if MAGIC_BULLET_APPLIED then return end
    MAGIC_BULLET_APPLIED = true
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
                        local assetName = (physAsset.GetName and physAsset:GetName()) or tostring(physAsset)
                        if not PHYSICS_CACHE[assetName] then
                            local mb = {
                                ["head"] = 200, ["neck_01"] = 150, ["pelvis"] = 150,
                                ["spine_01"] = 150, ["spine_02"] = 150, ["spine_03"] = 150,
                                ["upperarm_l"] = 150, ["upperarm_r"] = 150, ["lowerarm_l"] = 130,
                                ["lowerarm_r"] = 130, ["hand_l"] = 100, ["hand_r"] = 100,
                                ["thigh_l"] = 150, ["thigh_r"] = 150, ["calf_l"] = 130,
                                ["calf_r"] = 130, ["foot_l"] = 100, ["foot_r"] = 100,
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
                            PHYSICS_CACHE[assetName] = true
                            if mesh.RecreatePhysicsState then mesh:RecreatePhysicsState() end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- AIMBOT FUNCTIONS (OPTIMIZED - APPLIED ONCE PER WEAPON)
-- ============================================
_G._AimbotCurrentPC = nil
local AIMBOT_APPLIED = false
local LAST_WEAPON_ID = 0

local function ApplyHardAimbot()
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end

        local wm = char.WeaponManagerComponent
        if not slua.isValid(wm) then return end

        local weapon = wm.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end
        
        -- OPTIMIZED: only reapply when weapon changes
        local weaponId = weapon.GetName and weapon:GetName() or tostring(weapon)
        if AIMBOT_APPLIED and LAST_WEAPON_ID == weaponId then return end
        LAST_WEAPON_ID = weaponId
        AIMBOT_APPLIED = true

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
                    cfg.Speed = 5.5
                    cfg.RangeRate = 5.5
                    cfg.SpeedRate = 5.5
                    cfg.RangeRateSight = 5.5
                    cfg.SpeedRateSight = 5.5
                    cfg.CrouchRate = 5.5
                    cfg.ProneRate = 5.5
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

-- OPTIMIZED: slower timer for aimbot (0.5s instead of 0.1s)
local AIMBOT_TIMER_ACTIVE = false
local function AttachAimbotTimer()
    if AIMBOT_TIMER_ACTIVE then return end
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        if pc == _G._AimbotCurrentPC then return end
        _G._AimbotCurrentPC = pc
        AIMBOT_TIMER_ACTIVE = true
        if pc.AddGameTimer then
            -- OPTIMIZED: reduced frequency from 0.1s to 0.5s
            pc:AddGameTimer(0.5, true, function()
                if not slua.isValid(_G._AimbotCurrentPC) then
                    _G._AimbotCurrentPC = nil
                    AIMBOT_TIMER_ACTIVE = false
                    return
                end
                ApplyHardAimbot()
            end)
        end
    end)
end

AttachAimbotTimer()

-- OPTIMIZED: monitor for PC changes every 5 seconds instead of 2
pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(5.0, true, function()
            if not slua.isValid(_G._AimbotCurrentPC) then
                _G._AimbotCurrentPC = nil
                AIMBOT_TIMER_ACTIVE = false
                AttachAimbotTimer()
            end
        end)
    end
end)

-- ============================================
-- View Distance Config Patch (RUN ONCE)
-- ============================================
local VIEW_DIST_PATCHED = false
pcall(function()
    if VIEW_DIST_PATCHED then return end
    VIEW_DIST_PATCHED = true
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

-- ============================================
-- ESP AND MARK SYSTEMS (OPTIMIZED - CACHED)
-- ============================================
local ActiveForceMark = nil
local LastMarkUpdate = 0
local OUTLINE_CACHE = {} -- OPTIMIZED: cache outline states per character
local LAST_FOV_VALUE = 0
local LAST_SETTINGS_CHECK = 0
local LAST_SKIN_APPLY = 0

-- OPTIMIZED: cached PostProcessManager
local PPM_CACHE = nil
local function GetPPM()
    if PPM_CACHE and slua.isValid(PPM_CACHE) then return PPM_CACHE end
    PPM_CACHE = import("PostProcessManager").GetInstance()
    return PPM_CACHE
end

local function RegisterAvatarOutline(selfChar)
    if not Client or not CheckExpiration() then return end
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(uPlayerCharacter) then return end
    
    local charKey = tostring(selfChar)
    -- OPTIMIZED: only update outline if team changed
    local currentTeam = selfChar.TeamID
    local shouldOutline = (uPlayerCharacter.TeamID ~= currentTeam)
    
    if OUTLINE_CACHE[charKey] == shouldOutline then return end
    OUTLINE_CACHE[charKey] = shouldOutline

    local uAvatarComp2 = selfChar and selfChar.AvatarComponent2
    if not slua.isValid(uAvatarComp2) then return end

    local PPM = GetPPM()
    if not slua.isValid(PPM) or not PPM.IsPPEnabled then return end

    if shouldOutline then
        PPM.OutlineThickness = 3
        if PPM.OutlineColor then PPM.OutlineColor = { r = 1, g = 0, b = 0, a = 1 } end
        PPM:EnableAvatarOutline(uAvatarComp2, true)
    else
        PPM:EnableAvatarOutline(uAvatarComp2, false)
    end
end

-- OPTIMIZED: mark update every 2 seconds instead of 1
local function UpdateESP_Mark(selfChar)
    if not Client or not CheckExpiration() then return end
    if not slua.isValid(selfChar) then return end

    local local_player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(local_player) then return end

    if local_player.TeamID ~= selfChar.TeamID then
        if selfChar.IsAlive and selfChar:IsAlive() then
            local current_time = os.clock()
            -- OPTIMIZED: reduced mark update frequency
            if current_time - LastMarkUpdate > 2.0 then
                LastMarkUpdate = current_time
                local head_location = nil
                pcall(function() head_location = selfChar:GetHeadLocation(false) end)
                if not head_location then
                    pcall(function() head_location = selfChar:GetFuzzyPosition(FVector(0, 0, 0)) end)
                end
                if head_location then
                    if ActiveForceMark then
                        InGameMarkTools.HideMapMark(ActiveForceMark)
                    end
                    ActiveForceMark = InGameMarkTools.ClientAddMapMark(1003, head_location, 0, "", 4, nil)
                end
            end
        end
    else
        if ActiveForceMark then
            InGameMarkTools.HideMapMark(ActiveForceMark)
            ActiveForceMark = nil
        end
    end
end

-- ============================================
-- MAIN TIMER SYSTEM (OPTIMIZED - REDUCED FREQUENCY)
-- ============================================
local MAIN_TIMER_ACTIVE = false
local function StartAdvancedSystems()
    if MAIN_TIMER_ACTIVE then return end
    if not Client or not CheckExpiration() then return end
    MAIN_TIMER_ACTIVE = true

    local function TimerCallback()
        pcall(function()
            local uLocalPlayer = GameplayData.GetPlayerCharacter()
            if not slua.isValid(uLocalPlayer) then return end

            -- OPTIMIZED: FOV update every 1s instead of every frame
            local currentTime = os.clock()
            if currentTime - LAST_SETTINGS_CHECK > 1.0 then
                LAST_SETTINGS_CHECK = currentTime
                local uTPPCam = uLocalPlayer.ThirdPersonCameraComponent
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
                        if slua.isValid(uTPPCam) and not uLocalPlayer.bIsWeaponAiming then
                            if uTPPCam.FieldOfView ~= targetTPP and targetTPP ~= LAST_FOV_VALUE then
                                uTPPCam.FieldOfView = targetTPP
                                LAST_FOV_VALUE = targetTPP
                            end
                        end
                    end
                end
            end

            UpdateESP_Mark(uLocalPlayer)
            RegisterAvatarOutline(uLocalPlayer)
            
            -- OPTIMIZED: skin apply every 3 seconds
            if currentTime - LAST_SKIN_APPLY > 3.0 then
                LAST_SKIN_APPLY = currentTime
                local p = GameplayData.GetPlayerCharacter()
                if slua.isValid(p) then
                    ApplyAllModSkins(p)
                end
                ApplyLobbyTheme()
            end
        end)
    end

    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        -- OPTIMIZED: main timer reduced from 0.1s to 0.3s
        pc:AddGameTimer(0.3, true, TimerCallback)
    end
end

-- ============================================
-- RECEIVE BEGIN PLAY HOOK
-- ============================================
local HOOK_APPLIED = false
local function OnReceiveBeginPlay()
    if HOOK_APPLIED then return end
    HOOK_APPLIED = true
    if not CheckExpiration() then
        ShowExpirePopup()
        return
    end
    
    pcall(function()
        if Client then
            _G.TryShowWelcome()
            RemoveGrass()
            ReadLiveConfig()
            ApplyLobbyTheme()
            EnableMagicBullet() -- RUN ONCE
            StartAdvancedSystems()
        end
    end)
end

-- ============================================
-- HOOK INTO CHARACTER BASE (RUN ONCE)
-- ============================================
pcall(function()
    local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
    if CCharacterBase and CCharacterBase.ReceiveBeginPlay and not HOOK_APPLIED then
        local original = CCharacterBase.ReceiveBeginPlay
        CCharacterBase.ReceiveBeginPlay = function(self, ...)
            OnReceiveBeginPlay()
            if
