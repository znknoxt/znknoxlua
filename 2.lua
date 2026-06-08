function BRPlayerCharacterBase:SetMaterialRender(DisableDepth, BlendMode)
    local success, err = pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then
            return
        end
        if player.TeamID == self.TeamID then
            return
        end
        local mesh = self.Mesh
        if not mesh then
            return
        end
        local matInterface = mesh:GetMaterial(0)
        if not matInterface then
            return
        end
        local baseMat = matInterface:GetBaseMaterial()
        if not baseMat then
            return
        end
        baseMat.bDisableDepthTest = DisableDepth
        baseMat.BlendMode = BlendMode
    end)
    if not success then
        _G.WriteLog("SetMaterialRender ERROR: " .. tostring(err))
    end
end

function BRPlayerCharacterBase:ReceiveTick(DeltaTime)
 self:SetMaterialRender(true, 2)
