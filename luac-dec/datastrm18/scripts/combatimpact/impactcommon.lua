function IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId)
  return PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true or PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true
end
function GetImpactAudioOcclusionType(attackerEntityId)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) then
    return eAudioObstructionType_None
  else
    return eAudioObstructionType_SingleRay
  end
end
function ImpactTable:PlayImpactSoundAtPosition(soundName, impactPos, attackerEntityId, targetEntityId)
  if not self.audioTriggerOptions then
    self.audioTriggerOptions = AudioTriggerOptions()
  end
  if IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId) then
    if PlayerComponentRequestsBus.Event.IsLocalPlayer(attackerEntityId) == true then
      self.playerEntityId = attackerEntityId
    elseif PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true then
      self.playerEntityId = targetEntityId
    end
    if self.playerEntityId ~= nil then
      local playerPosition = TransformBus.Event.GetWorldTranslation(self.playerEntityId)
      local distance
      if impactPos ~= nil then
        distance = Vector3.GetDistance(playerPosition, impactPos)
      else
        distance = Vector3.GetDistance(playerPosition, targetEntityId)
      end
      if distance ~= nil and distance <= 30 then
        self.audioTriggerOptions.environmentName = AudioEnvironmentComponentRequestBus.Event.GetCachedEnvironmentName(self.playerEntityId)
        self.audioTriggerOptions.environmentValue = AudioEnvironmentComponentRequestBus.Event.GetCachedEnvironmentAmount(self.playerEntityId)
      else
        self.audioTriggerOptions.environmentName = nil
        self.audioTriggerOptions.environmentValue = 0
      end
    end
  else
    self.audioTriggerOptions.environmentName = nil
    self.audioTriggerOptions.environmentValue = 0
  end
  self.audioTriggerOptions.obstructionType = GetImpactAudioOcclusionType(attackerEntityId)
  self.audioTriggerOptions.rtpcName = "rtpc_IMP_LocalPlayer"
  if IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId) then
    self.audioTriggerOptions.rtpcValue = 1
  else
    self.audioTriggerOptions.rtpcValue = 0
  end
  AudioUtilsBus.Broadcast.ExecuteAudioTriggerAtPositionWithOptions(soundName, impactPos, self.audioTriggerOptions)
end
function PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, soundName, isBlocked, isCrit)
  if IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId) then
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(targetEntityId, "rtpc_IMP_LocalPlayer", 1)
  else
    AudioRtpcComponentRequestBus.Event.SetRtpcValue(targetEntityId, "rtpc_IMP_LocalPlayer", 0)
  end
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, soundName)
  if isBlocked == false and PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_Impact_Global_LocPlayer")
  end
  if isCrit then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_Crit_Hit_A")
  end
end
function HandleBlockSFX(targetEntityId, attackerEntityId, shieldBlockEffect, weaponBlockEffect)
  local isShieldBlock = PaperdollUtils:WeaponHasItemClass(targetEntityId, ePaperdollSlotAlias_ActiveOffHandWeapon, eItemClass_Shield)
  if isShieldBlock then
    PaperdollUtils:PlayWeaponBlockSound(shieldBlockEffect, attackerEntityId, targetEntityId)
  else
    PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, weaponBlockEffect, true)
  end
end
function PlayLocalPlayerOnlyImpact(targetEntityId, soundName, isBlocked)
  if PlayerComponentRequestsBus.Event.IsLocalPlayer(targetEntityId) == true then
    AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, soundName)
  end
end
function ImpactTable:CritDefault_MD(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.CRIT.base_MD", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  AudioTriggerComponentRequestBus.Event.ExecuteTrigger(targetEntityId, "Play_Crit_Hit_A")
end
function ImpactTable:EnvironmentDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.MD_01", impactPos, impactNormal * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_PunchUnarmed_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentDirt(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentCorruptionCore(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Slash_Omni", impactPos, direction * 1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_npc_Corruption.Impact_Slash_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  self:PlayImpactSoundAtPosition("Play_Imp_Corruption_Core", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentFabric(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.FABRIC.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordWood_Cloth", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentMetal(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.METAL.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_SwordMetal_Metal", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentRock(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.15, 0.2, 5, "materials/vfx/decals/impacts/impact_rock001")
  self:PlayImpactSoundAtPosition("Play_Imp_SpearMetal_Stone", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentWood(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.MD_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.15, 0.2, 5, "materials/vfx/decals/impacts/impact_wood002")
  self:PlayImpactSoundAtPosition("Play_Imp_SpearWood_Wood", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentWater(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WATER.MD_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Water", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentDirt_LG(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.DIRT.LG_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.45, 0.55, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Dirt", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentMetal_LG(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.METAL.LG_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Metal", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentRock_LG(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.STONE.LG_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.3, 0.35, 5, "materials/vfx/decals/impacts/impact_rock001")
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Stone", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentWood_LG(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WOOD.LG_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.35, 0.5, 5, "materials/vfx/decals/impacts/impact_wood001")
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Wood", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentWater_LG(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts_ENV.WATER.LG_01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_GreatAxe_Water", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:EnvironmentFiresword(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_DamnedCommander.Fire_Groundimpact01", impactPos, Vector3(0, 0, 1), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  ParticleManagerBus.Broadcast.SpawnDecal(impactPos, impactNormal, 0.25, 0.25, 5, "materials/vfx/decals/impacts/impact_dirt001")
  self:PlayImpactSoundAtPosition("Play_Imp_Bullet_Flesh", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:NoEnvironment(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  return
end
function ImpactTable:HolyShield_Proj(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  self:PlayImpactSoundAtPosition("Play_Imp_Proj_HolyShield", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:HolyShield_FireProj(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  self:PlayImpactSoundAtPosition("Play_Imp_FireProj_HolyShield", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:HolyShield_LifeProj(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  self:PlayImpactSoundAtPosition("Play_Imp_LifeProj_HolyShield", impactPos, attackerEntityId, targetEntityId)
end
