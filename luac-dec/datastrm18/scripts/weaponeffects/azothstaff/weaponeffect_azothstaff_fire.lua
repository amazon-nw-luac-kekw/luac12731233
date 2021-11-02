local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_AzothStaff_Fire = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_azothstaff.CarryFlame",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Sword_Fire_Idle",
        stopTriggerName = "Stop_WPN_Sword_Fire_Idle",
        preloadName = "Perks_Sword_Fire"
      }
    }
  }
}
Merge(WeaponEffect_AzothStaff_Fire, WeaponEffectBase, true)
return WeaponEffect_AzothStaff_Fire
