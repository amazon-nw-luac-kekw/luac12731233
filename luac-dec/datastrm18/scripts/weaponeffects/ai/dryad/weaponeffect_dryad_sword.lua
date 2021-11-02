local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Dryad_Sword = {
  effectGroups = {
    idle = {},
    PowerUp = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "Weapons.Base.Coatings.POISON.Idle_01",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Sword_Fire_Idle",
        stopTriggerName = "",
        preloadName = "Perks_Sword_Fire"
      }
    },
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "Weapons.Base.Coatings.POISON.Swipe_Drip_01",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Sword_Fire_OnAttack",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_Dryad_Sword, WeaponEffectBase, true)
return WeaponEffect_Dryad_Sword
