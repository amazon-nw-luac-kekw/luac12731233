local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Musket_Magic = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Arcane_Range.Musket.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Magic_Idle",
        stopTriggerName = "Stop_WPN_Musket_Magic_Idle",
        preloadName = "Perks_Musket_Magic"
      }
    },
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Musket_Magic_Melee_Charged_2",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Arcane_Range.Musket.MuzzleFlash",
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
        startTriggerName = "Play_WPN_Musket_Magic_Shot",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot_charged = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Arcane_Range.Musket.MuzzleFlash",
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
        startTriggerName = "Play_WPN_Musket_Magic_Shot_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    shot_charged_clean = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Arcane_Range.Musket.MuzzleFlash",
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
Merge(WeaponEffect_Musket_Magic, WeaponEffectBase, true)
return WeaponEffect_Musket_Magic
