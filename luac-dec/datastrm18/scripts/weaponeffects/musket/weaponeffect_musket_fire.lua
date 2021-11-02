local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Musket_Fire = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Fire_Range.Musket.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Fire_Idle",
        stopTriggerName = "Stop_WPN_Musket_Fire_Idle",
        preloadName = "Perks_Musket_Fire"
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
        startTriggerName = "Play_WPN_Musket_Fire_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Fire_Melee.z",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Fire_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Fire_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Fire_Melee_Charged_2",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Fire_Range.Musket.MuzzleFlash",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Default_Range.Musket_MuzzleSmoke",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Fire_Shot",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot_charged = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Fire_Range.Musket.MuzzleFlash",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Musket_Sharpshooter.Muzzle_PowerSmoke",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Fire_Shot_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot_charged_clean = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Fire_Range.Musket.MuzzleFlash",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Musket_Sharpshooter.Muzzle_CleanSmoke",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    power_charge = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Musket_Sharpshooter.Power_Charged",
        followType = EmitterFollow,
        killOnStop = true
      }
    }
  }
}
Merge(WeaponEffect_Musket_Fire, WeaponEffectBase, true)
return WeaponEffect_Musket_Fire
