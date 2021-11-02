local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Bow_Fire = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Fire_Range.Bow.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_02",
        particleName = "wFX_Fire_Range.Bow.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Fire_Idle",
        stopTriggerName = "Stop_WPN_Bow_Fire_Idle",
        preloadName = "Perks_Bow_Fire"
      }
    },
    tip = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "arrowAttach_tip_jnt",
        particleName = "wFX_Fire_Range.Bow.Tip_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Fire_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Fire_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot = {
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Fire_Shot",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    tip_start = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "arrowAttach_tip_jnt",
        particleName = "wFX_Fire_Range.Bow.Tip_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Fire_Tip",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    bow_charge = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_string",
        particleName = "wFX_Default_Range.Arrow_Charge",
        followType = EmitterFollow,
        killOnStop = true
      }
    }
  }
}
Merge(WeaponEffect_Bow_Fire, WeaponEffectBase, true)
return WeaponEffect_Bow_Fire
