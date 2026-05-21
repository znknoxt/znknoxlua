-- ============================================
-- VISUAL ASSISTANCE SYSTEM (OPTIMIZED)
-- ============================================
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")

-- OPTIMIZED: Static cached objects
local COLOR_RED = FLinearColor(1, 0, 0, 1)
local COLOR_HP_GREEN = FLinearColor(0, 1, 0, 0.95)
local COLOR_HP_YELLOW = FLinearColor(1, 1, 0, 0.95)
local COLOR_HP_RED = FLinearColor(1, 0, 0, 0.95)
local COLOR_BG = FLinearColor(0, 0, 0, 0.55)
local VEC_Z85, VEC_Z90 = FVector(0, 0, 85), FVector(0, 0, 90)

-- ============================================
-- EXPIRE DATE SYSTEM (CACHED)
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

-- ============================================
-- SKIN SYSTEM (ADDED FROM PREVIOUS MOD)
-- ============================================
_G.OutfitSkins = {
    Suit = {403317,1406469,1405870,1407140,1407141,1407142,1407550,1406638,1406872,1406971,1407103},
    Bag = {501001,1501001174,1501001220,1501001051,1501001443,1501001265,1501001321,1501001277},
    Helmet = {502001,1502001014,1502001349,1502001012,1502001009,1502001397,1502001390},
}
_G.SuitSkin, _G.BagSkin, _G.HelmetSkin = 0, 0, 0
_G.LastAppliedSkins = {suit=0, bag=0, helmet=0}

local function ApplyAllModSkins(p)
    if not CheckExpiration() or not p or not slua.isValid(p) then return end
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

-- ============================================
-- AIMBOT (ADDED FROM PREVIOUS MOD)
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

-- ============================================
-- MAGIC BULLET (ADDED FROM PREVIOUS MOD)
-- ============================================
local MAGIC_BULLET_APPLIED = false
local PHYSICS_CACHE = {}

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
-- NO GRASS (ADDED)
-- ============================================
local GRASS_REMOVED = false
local function RemoveGrass()
    if GRASS_REMOVED then return end
    if not Client then return end
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
-- 165 FPS LOGIC (ADDED)
-- ============================================
local FPS_PATCHED = false
local function Enable165FPS()
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
    end)
end

-- ============================================
-- IPAD VIEW (ADDED)
-- ============================================
local IPAD_VIEW_PATCHED = false
local function EnableiPadView()
    if IPAD_VIEW_PATCHED then return end
    IPAD_VIEW_PATCHED = true
    pcall(function()
        local sc = require("client.logic.setting.setting_config")
        if sc then
            if sc.TpViewValue then sc.TpViewValue.max = 140 end
            if sc.FpViewValue then sc.FpViewValue.max = 140 end
        end
    end)
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function IsPawnAlive(p)
    if not slua.isValid(p) then return false end
    if p.HealthStatus then return SecurityCommonUtils.IsHealthStatusAlive(p.HealthStatus) end
    if p.IsAlive then return p:IsAlive() end
    return p.GetHealth and (p:GetHealth() or 0) > 0 or false
end

local function GetPawnHealthRatio(p)
    local hp = p.GetHealth and p:GetHealth() or 100
    local maxHp = p.GetHealthMax and p.GetHealthMax() or 100
    return math.max(0, math.min(1, hp / (maxHp <= 0 and 100 or maxHp)))
end

local function SetRedFrameUI(p)
    if not slua.isValid(p) then return end
    if p.Replay_SetFrameUIColor then p:Replay_SetFrameUIColor(COLOR_RED)
    elseif p.SetEnemyFrameColor then p:SetEnemyFrameColor(COLOR_RED)
    elseif p.SetFrameColor then p:SetFrameColor(COLOR_RED)
    elseif p.SetOutlineColor then p:SetOutlineColor(COLOR_RED) end
end

-- ============================================
-- MAIN VISUAL ASSISTANCE (OPTIMIZED TIMER)
-- ============================================
local SharedVisualAssistOwner = nil
local function StartVisualAssistance(self)
    if not Client or not CheckExpiration() then return end
    if SharedVisualAssistOwner and SharedVisualAssistOwner ~= self then return end

    SharedVisualAssistOwner = self
    local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
    local cachedMarks, cachedPawns, lastPawnRefresh = {}, {}, 0
    local lastSkinApply = 0
    local lastAimbotApply = 0

    local timer = self:AddGameTimer(0.1, true, function()
        if not slua.isValid(self) then
            for _, markId in pairs(cachedMarks) do
                if type(markId) ~= "table" and markId then InGameMarkTools.HideMapMark(markId) end
            end
            cachedMarks, SharedVisualAssistOwner = {}, nil
            return
        end

        local uCon = slua_GameFrontendHUD:GetPlayerController()
        if not (slua.isValid(uCon) and Game:IsClassOf(uCon, ASTExtraPlayerController)) then return end

        local currentPawn = uCon:GetCurPawn()
        if not slua.isValid(currentPawn) then return end

        local now = os.clock()
        
        if now - lastSkinApply > 3.0 then
            lastSkinApply = now
            ApplyAllModSkins(currentPawn)
        end
        
        if now - lastAimbotApply > 0.5 then
            lastAimbotApply = now
            ApplyHardAimbot()
        end

        local myTeamId, myPos = currentPawn.TeamID, currentPawn:K2_GetActorLocation()

        if now - lastPawnRefresh > 1.0 then
            lastPawnRefresh = now
            cachedPawns = Game:GetAllPlayerPawns() or {}
            for pawnPtr, markId in pairs(cachedMarks) do
                if pawnPtr ~= "_time" then
                    local found = false
                    for _, p in pairs(cachedPawns) do if p == pawnPtr then found = true break end end
                    if not found and markId then
                        InGameMarkTools.HideMapMark(markId)
                        cachedMarks[pawnPtr] = nil
                    end
                end
            end
        end

        for _, tPawn in pairs(cachedPawns) do
            if slua.isValid(tPawn) and tPawn ~= currentPawn and tPawn.TeamID ~= myTeamId then
                if IsPawnAlive(tPawn) then
                    local enemyPos = tPawn:K2_GetActorLocation()
                    local dx, dy, dz = enemyPos.X - myPos.X, enemyPos.Y - myPos.Y, enemyPos.Z - myPos.Z
                    local distSq = dx*dx + dy*dy + dz*dz

                    if distSq < 600000 then
                        if tPawn.Replay_CreateEnemyFrameUI then tPawn:Replay_CreateEnemyFrameUI(true, true) end
                        SetRedFrameUI(tPawn)
                        if tPawn.Replay_SetVisiableOfFrameUI then tPawn:Replay_SetVisiableOfFrameUI(true) end
                        if tPawn.SetPlayerNameVisible then tPawn:SetPlayerNameVisible(true) end

                        local dist = math.sqrt(distSq)
                        local headPos, rootPos
                        if dist > 150000 then
                            headPos, rootPos = enemyPos + VEC_Z85, enemyPos - VEC_Z85
                        else
                            local realHead = tPawn:GetHeadLocation(false)
                            headPos = realHead or (enemyPos + VEC_Z85)
                            rootPos = realHead and (enemyPos - VEC_Z90) or (enemyPos - VEC_Z85)
                        end

                        cachedMarks._time = cachedMarks._time or {}
                        if now - (cachedMarks._time[tPawn] or 0) > 1.5 then
                            cachedMarks._time[tPawn] = now
                            if cachedMarks[tPawn] then
                                InGameMarkTools.UpdateMapMarkLocation(cachedMarks[tPawn], headPos)
                            else
                                cachedMarks[tPawn] = InGameMarkTools.ClientAddMapMark(1006, headPos, 0, "", 4, tPawn)
                            end
                        end

                        local HUD = uCon:GetHUD()
                        local Canvas = slua.isValid(HUD) and HUD.Canvas or nil
                        if Canvas then
                            local headScreen, rootScreen = FVector2D(0,0), FVector2D(0,0)
                            if uCon:ProjectWorldLocationToScreen(headPos, false, headScreen) and 
                               uCon:ProjectWorldLocationToScreen(rootPos, false, rootScreen) then
                                
                                local screenHeight = math.max(25, math.abs(headScreen.Y - rootScreen.Y))
                                local scaleFactor = math.max(0.3, math.min(1.5, 15000 / math.max(10000, dist)))
                                local barWidth, barHeight = 4 * scaleFactor, screenHeight * scaleFactor
                                local barX, barY = headScreen.X - (barWidth * 1.5), headScreen.Y
                                local hp = GetPawnHealthRatio(tPawn)
                                
                                local color = hp < 0.3 and COLOR_HP_RED or (hp < 0.6 and COLOR_HP_YELLOW or COLOR_HP_GREEN)

                                Canvas:K2_DrawBox(FVector2D(barX, barY), FVector2D(barWidth, barHeight), 1, COLOR_BG)
                                Canvas:K2_DrawBox(FVector2D(barX, barY + barHeight * (1 - hp)), FVector2D(barWidth, barHeight * hp), 1, color)
                            end
                        end
                    end
                else
                    if tPawn.Replay_SetVisiableOfFrameUI then tPawn:Replay_SetVisiableOfFrameUI(false) end
                    if cachedMarks[tPawn] then
                        InGameMarkTools.HideMapMark(cachedMarks[tPawn])
                        cachedMarks[tPawn] = nil
                    end
                end
            end
        end
    end)
    
    return timer
end

-- ============================================
-- CHARACTER HOOK (ENTRY POINT)
-- ============================================
local function HookCharacterBase()
    pcall(function()
        local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
        if CharacterBase and CharacterBase.ReceiveBeginPlay then
            local original = CharacterBase.ReceiveBeginPlay
            CharacterBase.ReceiveBeginPlay = function(self, ...)
                if Client then
                    Enable165FPS()
                    EnableiPadView()
                    RemoveGrass()
                    EnableMagicBullet()
                    StartVisualAssistance(self)
                end
                
                if original then
                    return original(self, ...)
                end
            end
        end
    end)
end

-- Initialize everything
pcall(function()
    HookCharacterBase()
    
    if Client then
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            local pawn = pc:GetCurPawn()
            if slua.isValid(pawn) then
                Enable165FPS()
                EnableiPadView()
                RemoveGrass()
                EnableMagicBullet()
                StartVisualAssistance(pawn)
            end
        end
    end
end)
