local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Bow_Ice = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Ice_Range.Bow.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_02",
        particleName = "wFX_Ice_Range.Bow.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "",
        stopTriggerName = "",
        preloadName = "Perks_Bow_Ice"
      }
    },
    tip = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "arrowAttach_tip_jnt",
        particleName = "wFX_Ice_Range.Bow.Tip_01",
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
        particleName = "wFX_Ice_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Ice_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot = {
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Ice_Shot",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    tip_start = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "arrowAttach_tip_jnt",
        particleName = "wFX_Ice_Range.Bow.Tip_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Bow_Ice_Tip",
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
Merge(WeaponEffect_Bow_Ice, WeaponEffectBase, true)
return WeaponEffect_Bow_Ice
