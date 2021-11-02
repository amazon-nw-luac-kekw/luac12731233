local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_LifeStaff_Base = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "wFX_LifeStaff_Base.Idle",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Fire_Idle",
        stopTriggerName = "Stop_WPN_Hatchet_Fire_Idle",
        preloadName = "Perks_Hatchet_Fire"
      }
    }
  }
}
Merge(WeaponEffect_LifeStaff_Base, WeaponEffectBase, true)
return WeaponEffect_LifeStaff_Base
