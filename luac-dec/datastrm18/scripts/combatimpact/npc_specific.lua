require("Scripts.CombatImpact.ImpactCommon")
function ImpactTable:Regurgitator_VomitballDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Projectile_impact01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Regurgitator_Vomitball", false)
end
function ImpactTable:Regurgitator_VomitballResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Projectile_impact01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Regurgitator_Vomitball", false)
end
function ImpactTable:Regurgitator_VomitballEnvironment(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Projectile_impact01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_Regurgitator_Vomitball_Environment", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:Regurgitator_VomitsprayDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Regurgitator.Spray_impact01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Regurgitator_Vomit", false)
end
function ImpactTable:Impaler_spikeDefault(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_CorruptionImpaler.Impaler_spike_onhit", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Impaler_Spike", false)
end
function ImpactTable:Impaler_spikeResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_CorruptionImpaler.Impaler_spike_onhit", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Blunt, "Play_Block_Impaler_spike")
end
function ImpactTable:Impaler_spikeEnvironment(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_CorruptionImpaler.Impaler_spike_onhit", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  self:PlayImpactSoundAtPosition("Play_Imp_Impaler_Spike_Environment", impactPos, attackerEntityId, targetEntityId)
end
function ImpactTable:Sonicboom(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayLocalPlayerOnlyImpact(targetEntityId, "Play_Imp_WitheredGrunt_SonicBoom", false)
end
function ImpactTable:Torch(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Blunt_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  local attackWeaponEntityId = PaperdollUtils:GetWeaponEntityId(attackerEntityId, ePaperdollSlotAlias_ActiveWeapon)
  if attackWeaponEntityId ~= nil then
    ParticleManagerBus.Broadcast.SpawnParticleAtAttachment(attackWeaponEntityId, "vfx_Tip_01", "cFX_Impacts.BLOOD.Impact_Blunt_Trail", Vector3(0, 0, 0), IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId), EmitterFollow)
  end
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Torch", false)
end
function ImpactTable:TorchResist(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOCK.Default_01", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  HandleBlockSFX(targetEntityId, attackerEntityId, WeaponSoundId.Wpn_Blunt, "Play_Block_Torch_Reg")
end
function ImpactTable:GhostFrozen(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Ghost_Frozen", false)
end
function ImpactTable:GhostFire(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostCharred.Impact_Fire_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Ghost_Fire", false)
end
function ImpactTable:GhostLightning(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Ghost_Electric", false)
end
function ImpactTable:GhostPoison(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Ghost_Poison", false)
end
function ImpactTable:GhostShackled(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_GhostHanged.Curse_Shot_Impact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Ghost_Shackled", false)
end
function ImpactTable:GhostMelee(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_Impacts.BLOOD.Impact_Blunt_Omni", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Ghost_Melee", false)
end
function ImpactTable:CorruptedMagic(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Corruption_Magic", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic", false)
end
function ImpactTable:DynastyMagic(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Dynasty.Impact_Dynasty_Magic", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic", false)
end
function ImpactTable:SunMagic(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Sun.Impact_Sun_Magic", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic", false)
end
function ImpactTable:CorruptedMagic_Legion(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cfx_npc_legionsignifer.TripleShotImpact", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic", false)
end
function ImpactTable:CorruptedMagicEnv(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Corruption_Magic", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic_Environment", false)
end
function ImpactTable:CorruptedSlashEnv(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Isabella.Impact_Corruption_Slash", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic_Environment", false)
end
function ImpactTable:CorruptedSlash(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  ParticleManagerBus.Broadcast.SpawnParticle("cFX_npc_Corruption.Impact_Corruption_Magic", impactPos, direction * -1, IsAttackRelatedToLocalPlayer(attackerEntityId, targetEntityId))
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_CorruptedMagic", false)
end
function ImpactTable:GravediggerLifesteal(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_Gravedigger_Lifesteal", false)
end
function ImpactTable:DryadMagic(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_DryadMagic", false)
end
function ImpactTable:DryadMagicEnv(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_DryadMagic_Environment", false)
end
function ImpactTable:AncientMagic(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_AncientMagic", false)
end
function ImpactTable:AnubianGuardianBruteBody(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_AnubianGuardian_Brute", false)
end
function ImpactTable:AnubianLocustScarabBody(impactPos, impactNormal, direction, powerLevel, attackerEntityId, targetEntityId)
  PlayImpactSoundOnCharacter(targetEntityId, attackerEntityId, "Play_Imp_SwordMetal_Anubian_Lotus_Scarab", false)
end
