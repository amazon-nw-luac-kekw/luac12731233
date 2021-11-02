local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Warhammer_Void = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "wFX_Void_Melee.Warhammer.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_02",
        particleName = "wFX_Void_Melee.Warhammer.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Warhammer_Void_Idle",
        stopTriggerName = "Stop_WPN_Warhammer_Void_Idle",
        preloadName = "Perks_Warhammer_Void"
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
        startTriggerName = "Play_WPN_Warhammer_Void_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    melee_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Void_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
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
        startTriggerName = "Play_WPN_Warhammer_Void_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    thrust_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Void_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    warhammer_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(0, 1.2, -0.35),
        rotationDeg = Vector3(0, 230, 0),
        scale = 0.85,
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
        startTriggerName = "Play_WPN_Warhammer_Void_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    warhammer_primary_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(-0.1, 2, -0.35),
        rotationDeg = Vector3(0, 50, 0),
        scale = 0.85,
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
        startTriggerName = "Play_WPN_Warhammer_Void_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    warhammer_heavy = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(0.1, 1.4, -0.35),
        rotationDeg = Vector3(0, -90, 0),
        scale = 1.3,
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
        startTriggerName = "Play_WPN_Warhammer_Void_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_Warhammer_Void, WeaponEffectBase, true)
return WeaponEffect_Warhammer_Void
