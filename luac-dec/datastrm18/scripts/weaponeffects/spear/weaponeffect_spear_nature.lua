local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Spear_Nature = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Mid_01",
        particleName = "wFX_Nature_Melee.Spear.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Nature_Idle",
        stopTriggerName = "Stop_WPN_Spear_Nature_Idle",
        preloadName = "Perks_Spear_Nature"
      }
    },
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Nature_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Nature_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Nature_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Nature_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    thrust_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Nature_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Nature_Thrust",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    thrust_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Nature_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Nature_Thrust",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    thrust_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Nature_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Nature_Thrust_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_Spear_Nature, WeaponEffectBase, true)
return WeaponEffect_Spear_Nature
