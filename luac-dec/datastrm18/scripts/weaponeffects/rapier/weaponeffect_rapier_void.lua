local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Rapier_Void = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Void_Melee.Rapier.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Idle",
        stopTriggerName = "Stop_WPN_Rapier_Void_Idle",
        preloadName = "Perks_Rapier_Void"
      }
    },
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Void_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Void_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    thrust_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Void_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Thrust",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    thrust_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Void_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Thrust_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    rapier_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Void_Melee.Stab_MD",
        positionOffset = Vector3(0, 0, 0),
        rotationDeg = Vector3(0, 0, 0),
        scale = 1,
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Void_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Thrust",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    rapier_primary_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(0, 1.25, -0.3),
        rotationDeg = Vector3(0, -12, 40),
        scale = 0.8,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Void_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    rapier_primary_3 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(-0.1, 2.1, -0.1),
        rotationDeg = Vector3(0, 170, -15),
        scale = 0.8,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Void_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Rapier_Void_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_Rapier_Void, WeaponEffectBase, true)
return WeaponEffect_Rapier_Void
