local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Hatchet_Magic = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Mid_01",
        particleName = "wFX_Arcane_Melee.Hatchet.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "wFX_Arcane_Melee.Hatchet.Idle_02",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Magic_Idle",
        stopTriggerName = "Stop_WPN_Hatchet_Magic_Idle",
        preloadName = "Perks_Hatchet_Magic"
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
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee",
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
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    hatchet_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(-0.1, 1.2, -0.35),
        rotationDeg = Vector3(0, -60, 0),
        scale = 0.8,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    hatchet_primary_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(-0.1, 2.5, -0.35),
        rotationDeg = Vector3(0, 230, 0),
        scale = 0.8,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    hatchet_primary_3 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(-0.1, 3.75, -0.35),
        rotationDeg = Vector3(0, -60, 0),
        scale = 0.8,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    hatchet_primary_4 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(0.1, 4, -0.35),
        rotationDeg = Vector3(0, -80, 0),
        scale = 0.8,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    hatchet_heavy = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(0.1, 1.25, -0.35),
        rotationDeg = Vector3(0, 70, 0),
        scale = 0.9,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Arcane_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Hatchet_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_Hatchet_Magic, WeaponEffectBase, true)
return WeaponEffect_Hatchet_Magic
