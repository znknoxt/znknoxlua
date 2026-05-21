-- ============================================
-- SINGLE FILE - ALL FEATURES + BYPASS
-- ============================================

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

print("[VIP] Loading all features...")

-- ============================================
-- SECTION 1: ANTI-BAN BYPASS (FULL)
-- ============================================
local function FullAntiBanBypass()
    pcall(function()
        local nop = function() end
        
        -- 1. Disable TSS Anti-Cheat Callbacks
        local gc = _G.GameplayCallbacks or _G["GC"]
        if gc then
            gc.SendTssSdkAntiDataToLobby = nop
            gc.SendDSErrorLogToLobby = nop
            gc.SendDSHawkEyePatrolLogToLobby = nop
            gc.SendSecTLog = nop
            gc.SendDataMiningTLog = nop
            gc.SendActivityTLog = nop
            gc.OnPlayerRPCValidateFailed = nop
            gc.OnPlayerActorChannelError = nop
            gc.OnPlayerSpectateException = nop
            gc.OnShutdownAfterError = nop
            gc.OnPlayerNetConnectionClosed = nop
        end
        
        -- 2. Disable Higgs Boson Anti-Cheat
        local higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if higgs then
            higgs.ControlMHActive = nop
            higgs.Tick = nop
            higgs.OnTick = nop
            higgs.MHActiveLogic = nop
            higgs.TriggerAvatarCheck = nop
            higgs.StartAvatarCheck = nop
            higgs.ReportItemID = nop
            higgs.GetNetAvatarItemIDs = function() return {} end
            higgs.GetCurWeaponSkinID = function() return 0 end
            higgs.ReceiveAnyDamage = nop
            higgs.OnWeaponHitRecord = nop
            higgs.ShowSecurityAlert = nop
        end
        
        -- 3. Disable Client Report System
        local clientReport = require("GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem")
        if clientReport then
            clientReport.OnInit = nop
            clientReport._OnPlayerKilledOtherPlayer = nop
            clientReport._RecordFatalDamager = nop
            clientReport._OnBattleResult = nop
        end
        
        -- 4. Disable DS Report System
        local dsReport = require("GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem")
        if dsReport then
            dsReport.OnInit = nop
            dsReport._OnCharacterDied = nop
            dsReport._RecordFatalDamager = nop
        end
        
        -- 5. Disable Avatar Check
        if _G.AvatarCheckCallback then
            _G.AvatarCheckCallback.StartAvatarCheck = nop
            _G.AvatarCheckCallback.OnReportItemID = nop
        end
        
        print("[BYPASS] Full anti-ban activated")
    end)
end

-- ============================================
-- SECTION 2: MAGIC BULLET (ENLARGED HITBOXES)
-- ============================================
local scaledAssets = {}

local function EnableMagicBullet()
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
                        local assetName = physAsset:GetName() or tostring(physAsset)
                        if not scaledAssets[assetName] then
                            local mb = {
                                ["head"] = 250,
                                ["neck"] = 180,
                                ["pelvis"] = 180,
                                ["spine"] = 180,
                                ["upperarm"] = 170,
                                ["lowerarm"] = 150,
                                ["hand"] = 120,
                                ["thigh"] = 170,
                                ["calf"] = 150,
                                ["foot"] = 120,
                            }
                            local setups = physAsset.SkeletalBodySetups
                            local scaled = 0
                            for i = 1, 80 do
                                local bs = setups:Get(i-1)
                                if not bs then break end
                                local bn = tostring(bs.BoneName):lower()
                                local pct = nil
                                for pat, val in pairs(mb) do
                                    if string.find(bn, pat) then pct = val; break end
                                end
                                if pct then
                                    local sc = 1.0 + pct / 100.0
                                    -- Scale Boxes
                                    if bs.AggGeom and bs.AggGeom.BoxElems then
                                        local box = bs.AggGeom.BoxElems:Get(0)
                                        if box then
                                            box.X = (box.X or 30) * sc
                                            box.Y = (box.Y or 30) * sc
                                            box.Z = (box.Z or 60) * sc
                                            bs.AggGeom.BoxElems:Set(0, box)
                                            scaled = scaled + 1
                                        end
                                    end
                                    -- Scale Capsules
                                    if bs.AggGeom and bs.AggGeom.SphylElems then
                                        local sphyl = bs.AggGeom.SphylElems:Get(0)
                                        if sphyl then
                                            if sphyl.Radius then sphyl.Radius = sphyl.Radius * sc end
                                            if sphyl.Length then sphyl.Length = sphyl.Length * sc end
                                            bs.AggGeom.SphylElems:Set(0, sphyl)
                                            scaled = scaled + 1
                                        end
                                    end
                                end
                            end
                            if scaled > 0 then
                                scaledAssets[assetName] = true
                                mesh:RecreatePhysicsState()
                                print("[MAGIC] Hitboxes enlarged:", scaled, "bones")
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- SECTION 3: NO RECOIL + ZERO SPREAD
-- ============================================
local function ApplyNoRecoil()
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
        
        -- Zero Recoil
        entity.RecoilKick = 0.0
        entity.RecoilKickADS = 0.0
        entity.AnimationKick = 0.0
        entity.AccessoriesVRecoilFactor = 0.0
        entity.AccessoriesHRecoilFactor = 0.0
        entity.GameDeviationFactor = 0.0
        entity.GameDeviationAccuracy = 0.0
        entity.DeviationMultiplier = 0.0
        entity.ShotGunHorizontalSpread = 0.0
        entity.ShotGunVerticalSpread = 0.0
        
        -- Recoil Info
        if entity.RecoilInfo then
            entity.RecoilInfo.VerticalRecoilMin = 0.0
            entity.RecoilInfo.VerticalRecoilMax = 0.0
            entity.RecoilInfo.RecoilSpeedVertical = 0.0
            entity.RecoilInfo.RecoilSpeedHorizontal = 0.0
        end
        
        -- Fast Aim
        entity.WeaponAimInTime = 0.01
        entity.SwitchFromIdleToBackpackTime = 0.0
        entity.SwitchFromBackpackToIdleTime = 0.0
        
        -- No Camera Shake
        entity.CameraShakeScale = 0.0
        entity.AimCameraShakeScale = 0.0
        entity.ShootCameraShakeScale = 0.0
        
        print("[NO RECOIL] Applied")
    end)
end

-- ============================================
-- SECTION 4: AIMBOT (HEAD LOCK)
-- ============================================
local function ApplyAimbot()
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
        
        -- Auto Aim Config
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 8.0
                    cfg.RangeRate = 8.0
                    cfg.SpeedRate = 8.0
                    cfg.RangeRateSight = 8.0
                    cfg.SpeedRateSight = 8.0
                    cfg.CrouchRate = 8.0
                    cfg.ProneRate = 8.0
                    cfg.DyingRate = 0
                    cfg.adsorbMaxRange = 500
                    cfg.adsorbMinRange = 10
                    cfg.adsorbMinAttenuationDis = 50
                    cfg.adsorbMaxAttenuationDis = 10000
                    cfg.adsorbActiveMinRange = 10
                end
            end
        end
        
        -- Force Headshots
        local aimComp = char.BP_AutoAimingComponent_C or char.BP_AutoAimingComponent or char.AutoAimingComponent
        if slua.isValid(aimComp) and aimComp.Bones then
            pcall(function()
                aimComp.Bones[0] = "head"
                aimComp.Bones[1] = "head" 
                aimComp.Bones[2] = "head"
                if aimComp.Bones.Set then
                    aimComp.Bones:Set(0, "head")
                    aimComp.Bones:Set(1, "head")
                    aimComp.Bones:Set(2, "head")
                end
            end)
        end
        
        print("[AIMBOT] Active - Head lock")
    end)
end

-- ============================================
-- SECTION 5: ESP/WALLHACK (OUTLINE)
-- ============================================
local function EnableESP()
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        
        local allChars = Game:GetAllPlayerPawns() or {}
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= localPlayer then
                if enemy.TeamID ~= localPlayer.TeamID then
                    -- Red outline for enemies
                    local mesh = enemy.Mesh
                    if slua.isValid(mesh) then
                        mesh:SetRenderCustomDepth(true)
                        mesh:SetCustomDepthStencilValue(255)
                        
                        -- Highlight through walls
                        pcall(function()
                            mesh:SetDrawDyeing(true)
                            mesh:SetDrawDyeingMode(1)
                            mesh:SetVisibleDyeingColor(FLinearColor(1, 0, 0, 1))
                            mesh:SetOccludedDyeingColor(FLinearColor(1, 0, 0, 0.5))
                        end)
                    end
                end
            end
        end
        print("[ESP] Wallhack active")
    end)
end

-- ============================================
-- SECTION 6: NO GRASS + REMOVE FOG
-- ============================================
local function RemoveGrassAndFog()
    pcall(function()
        local gi = GameplayData.GetGameInstance()
        if gi then
            gi:ExecuteCMD("grass.DensityScale", "0")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
            gi:ExecuteCMD("foliage.DensityScale", "0")
            gi:ExecuteCMD("r.Fog", "0")
            gi:ExecuteCMD("r.Atmosphere", "0")
            gi:ExecuteCMD("r.LightShafts", "0")
            print("[GRAPHICS] Grass/Fog removed")
        end
    end)
end

-- ============================================
-- SECTION 7: 165 FPS UNLOCK
-- ============================================
local function Unlock165FPS()
    pcall(function()
        local gi = GameplayData.GetGameInstance()
        if gi then
            gi:ExecuteCMD("t.MaxFPS", "165")
            gi:ExecuteCMD("r.FrameRateLimit", "165")
            print("[FPS] 165 FPS unlocked")
        end
        
        -- Patch settings UI
        local graphics = require("client.slua.logic.setting.logic_setting_graphics")
        if graphics and graphics.SetFPS then
            local orig = graphics.SetFPS
            function graphics:SetFPS(lvl)
                if orig then orig(self, lvl) end
                if lvl == 8 then
                    local gameInst = GameplayData.GetGameInstance()
                    if gameInst then
                        gameInst:ExecuteCMD("t.MaxFPS", "165")
                        gameInst:ExecuteCMD("r.FrameRateLimit", "165")
                    end
                end
            end
        end
    end)
end

-- ============================================
-- SECTION 8: IPAD FOV (EXTENDED VIEW)
-- ============================================
local function EnableiPadFOV()
    pcall(function()
        -- Patch configs
        local sc = require("client.logic.setting.setting_config")
        if sc then
            if sc.TpViewValue then sc.TpViewValue.max = 140 end
            if sc.FpViewValue then sc.FpViewValue.max = 140 end
        end
        
        local db = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if db and db.TpViewValue then db.TpViewValue.max = 140 end
        
        -- Apply to camera
        local player = GameplayData.GetPlayerCharacter()
        if slua.isValid(player) then
            local cam = player.ThirdPersonCameraComponent
            if slua.isValid(cam) then
                cam:SetFieldOfView(120)
            end
        end
        print("[FOV] iPad view enabled (120 FOV)")
    end)
end

-- ============================================
-- SECTION 9: FAST WEAPON SWITCH
-- ============================================
local function EnableFastSwitch()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local wm = player.WeaponManagerComponent
        if slua.isValid(wm) then
            wm.EquipDuration = 0.05
            wm.HolsterDuration = 0.05
            wm.SwapDuration = 0.05
        end
        
        local weapon = player:GetCurrentWeapon()
        if slua.isValid(weapon) then
            weapon.EquipTime = 0.01
            weapon.PutDownTime = 0.01
            weapon.ReadyTime = 0.01
        end
        print("[FAST SWITCH] Weapons switch instantly")
    end)
end

-- ============================================
-- SECTION 10: SKIN CHANGER (RARE OUTFITS)
-- ============================================
local function ApplyRareSkins()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        if player.AvatarComponent2 and player.AvatarComponent2.NetAvatarData then
            local applyData = player.AvatarComponent2.NetAvatarData.SlotSyncData
            if applyData then
                for i = 0, applyData:Num() - 1 do
                    local eq = applyData:Get(i)
                    if eq and eq.ItemId ~= 0 then
                        -- Slot 5 = Suit, Slot 8 = Bag, Slot 9 = Helmet
                        if eq.SlotID == 5 then eq.ItemId = 1406469 end  -- Rare suit
                        if eq.SlotID == 8 then eq.ItemId = 1501001174 end -- Rare bag
                        if eq.SlotID == 9 then eq.ItemId = 1502001014 end -- Rare helmet
                        applyData:Set(i, eq)
                    end
                end
                player.AvatarComponent2:OnRep_BodySlotStateChanged()
                print("[SKINS] Rare outfits applied")
            end
        end
    end)
end

-- ============================================
-- MAIN TIMER - RUN EVERYTHING
-- ============================================
local function RunAllFeatures()
    pcall(function()
        ApplyNoRecoil()
        ApplyAimbot()
        EnableESP()
        EnableFastSwitch()
        ApplyRareSkins()
        EnableiPadFOV()
    end)
end

-- ============================================
-- INITIALIZATION
-- ============================================
local function Initialize()
    -- Run bypass first
    FullAntiBanBypass()
    
    -- Run one-time features
    RemoveGrassAndFog()
    Unlock165FPS()
    EnableiPadFOV()
    EnableMagicBullet()
    
    -- Start continuous features
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(0.1, true, EnableMagicBullet)  -- Magic bullet
        pc:AddGameTimer(0.2, true, RunAllFeatures)     -- All other features
        print("")
        print("========================================")
        print("[VIP] ALL FEATURES LOADED SUCCESSFULLY!")
        print("========================================")
        print("  ✅ Anti-Ban Bypass (Full)")
        print("  ✅ Magic Bullet (250% Hitboxes)")
        print("  ✅ No Recoil + Zero Spread")
        print("  ✅ Aimbot (Head Lock)")
        print("  ✅ ESP/Wallhack (Red Outline)")
        print("  ✅ No Grass + No Fog")
        print("  ✅ 165 FPS Unlocked")
        print("  ✅ iPad FOV (120)")
        print("  ✅ Fast Weapon Switch")
        print("  ✅ Rare Skins")
        print("========================================")
    else
        print("[VIP] Error: No player controller found")
    end
end

-- Start after delay
local timer = require("common.time_ticker")
timer.AddTimerOnce(2.0, Initialize)
