local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_1hClub_Magic = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "cFX_Weapon_Arcane.1hClub.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Club_Magic_Idle",
        stopTriggerName = "Stop_WPN_Club_Magic_Idle",
        preloadName = "Perks_Club_Magic"
      }
    },
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "cFX_Weapon_Arcane.Sword.Swipe_01",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Club_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "cFX_Weapon_Arcane.Sword.Swipe_01",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Club_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_1hClub_Magic, WeaponEffectBase, true)
return WeaponEffect_1hClub_Magic
