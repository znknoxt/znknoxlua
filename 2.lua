-- ============================================
-- MAGIC BULLET (ENLARGED HITBOXES)
-- ============================================
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
                        _G._MBones = _G._MBones or {}
                        local assetName = (physAsset.GetName and physAsset:GetName()) or tostring(physAsset)
                        if not _G._MBones[assetName] then
                            local mb = {
                                ["head"] = 200,
                                ["neck_01"] = 150,
                                ["pelvis"] = 150,
                                ["spine_01"] = 150,
                                ["spine_02"] = 150,
                                ["spine_03"] = 150,
                                ["upperarm_l"] = 150,
                                ["upperarm_r"] = 150,
                                ["lowerarm_l"] = 130,
                                ["lowerarm_r"] = 130,
                                ["hand_l"] = 100,
                                ["hand_r"] = 100,
                                ["thigh_l"] = 150,
                                ["thigh_r"] = 150,
                                ["calf_l"] = 130,
                                ["calf_r"] = 130,
                                ["foot_l"] = 100,
                                ["foot_r"] = 100,
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
                                    -- Box Elements
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
                                    -- Sphyl (Capsule) Elements
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
                                    -- Sphere Elements
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

-- ============================================
-- AIMBOT FUNCTIONS
-- ============================================
_G._AimbotCurrentPC = nil

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
            entity.AutoAimingConfig = entity.AutoAimingConfig
        end

        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C 
                         or char.BP_AutoAimingComponent 
                         or char.AutoAimingComponent
            
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

local function AttachAimbotTimer()
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        if pc == _G._AimbotCurrentPC then return end
        _G._AimbotCurrentPC = pc
        if pc.AddGameTimer then
            pc:AddGameTimer(0.1, true, function()
                if not slua.isValid(_G._AimbotCurrentPC) then
                    _G._AimbotCurrentPC = nil
                    return
                end
                ApplyHardAimbot()
                EnableMagicBullet() -- Magic bullet runs every 0.1 seconds
            end)
        end
    end)
end

AttachAimbotTimer()

pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(2.0, true, function()
            if not slua.isValid(_G._AimbotCurrentPC) then
                _G._AimbotCurrentPC = nil
                AttachAimbotTimer()
            end
        end)
    end
end)
- ============================================
-- IsAIPawn BOT DETECTION + COUNTER
-- ============================================

local function IsAIPawn(pawn)
    if not slua.isValid(pawn) then return false end
    
    -- Primary check: IsAIPawn function
    if pawn.IsAIPawn and type(pawn.IsAIPawn) == "function" then
        return pawn:IsAIPawn()
    end
    
    -- Secondary: Game:IsAI
    if Game.IsAI and type(Game.IsAI) == "function" then
        return Game:IsAI(pawn)
    end
    
    -- Tertiary: Check Controller
    if pawn.GetController then
        local controller = pawn:GetController()
        if slua.isValid(controller) then
            local cName = tostring(controller:GetName() or "")
            if cName:find("AI") or cName:find("Bot") then
                return true
            end
        end
    end
    
    return false
end

local function IsPawnAlive(pawn)
    if not slua.isValid(pawn) then return false end
    if pawn.HealthStatus then
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        return SecurityCommonUtils.IsHealthStatusAlive(pawn.HealthStatus)
    end
    return (pawn.Health or 0) > 0
end

local function GetBotAndRealCount()
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return 0, 0 end
    
    local localPlayer = pc:GetPlayerCharacterSafety()
    if not slua.isValid(localPlayer) then return 0, 0 end
    
    local allChars = Game:GetAllPlayerPawns() or {}
    local myTeamId = localPlayer.TeamID or 0
    
    local botCount = 0
    local realCount = 0
    
    for _, enemy in pairs(allChars) do
        if slua.isValid(enemy) and enemy ~= localPlayer then
            local enemyTeamId = enemy.TeamID or 0
            
            -- Only enemies (different team)
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

local function DrawCounter()
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local localPlayer = pc:GetPlayerCharacterSafety()
        if not slua.isValid(localPlayer) then return end
        
        local hud = pc:GetHUD()
        if not slua.isValid(hud) then return end
        
        local botCount, realCount = GetBotAndRealCount()
        
        -- Display on screen
        hud:AddDebugText(string.format("🤖 BOT: %d", botCount), localPlayer, 1,
            {X=0, Y=0, Z=220}, {X=0, Y=0, Z=220},
            {R=0, G=255, B=255, A=255}, true, false, true, nil, 1.0, true)
        
        hud:AddDebugText(string.format("👤 REAL: %d", realCount), localPlayer, 1,
            {X=0, Y=0, Z=205}, {X=0, Y=0, Z=205},
            {R=255, G=255, B=0, A=255}, true, false, true, nil, 1.0, true)
        
        hud:AddDebugText(string.format("🎯 TOTAL: %d", botCount + realCount), localPlayer, 1,
            {X=0, Y=0, Z=190}, {X=0, Y=0, Z=190},
            {R=255, G=255, B=255, A=255}, true, false, true, nil, 0.9, true)
        
        -- Label each enemy with BOT/REAL tag
        local allChars = Game:GetAllPlayerPawns() or {}
        local myTeamId = localPlayer.TeamID or 0
        local myPos = localPlayer:K2_GetActorLocation()
        
        for _, enemy in pairs(allChars) do
            if slua.isValid(enemy) and enemy ~= localPlayer then
                local enemyTeamId = enemy.TeamID or 0
                if enemyTeamId ~= myTeamId and IsPawnAlive(enemy) then
                    local enemyPos = enemy:K2_GetActorLocation()
                    local dx = enemyPos.X - myPos.X
                    local dy = enemyPos.Y - myPos.Y
                    local dz = enemyPos.Z - myPos.Z
                    local dist = math.sqrt(dx*dx + dy*dy + dz*dz) / 100
                    
                    if dist <= 150 then
                        local isBot = IsAIPawn(enemy)
                        local label = isBot and "🤖 BOT" or "👤 REAL"
                        local color = isBot and {R=0, G=255, B=255, A=255} or {R=255, G=255, B=0, A=255}
                        
                        hud:AddDebugText(label, enemy, 0.8,
                            {X=0, Y=0, Z=100}, {X=0, Y=0, Z=100},
                            color, true, false, true, nil, 0.7, true)
                    end
                end
            end
        end
    end)
end

local function StartCounter()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(0.3, true, DrawCounter)
        print("[IsAIPawn Counter] Activated - BOT vs REAL")
    else
        local fb = slua_GameFrontendHUD or Game
        if fb and slua.isValid(fb) then
            fb:AddGameTimer(1.0, false, StartCounter)
        end
    end
end

-- ============================================
-- MAIN CLASS
-- ============================================

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super._PostConstruct(self)
    end
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    StartCounter()
    print("[BOT COUNTER] Activated - Using IsAIPawn")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    end
    if Client then
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        GameplayData.AddCharacter(self.Object)
    end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    if BRPlayerCharacterBase.__super then
        BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    end
    if Client then
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        GameplayData.RemoveCharacter(self.Object)
    end
end
