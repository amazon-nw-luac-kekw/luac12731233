local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_GreatAxe_Magic = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Mid_01",
        particleName = "wFX_Arcane_Melee.GreatAxe.Idle_01",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "wFX_Arcane_Melee.GreatAxe.Idle_02",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_02",
        particleName = "wFX_Arcane_Melee.GreatAxe.Idle_02",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_GreatAxe_Magic_Idle",
        stopTriggerName = "Stop_WPN_GreatAxe_Magic_Idle",
        preloadName = "Perks_GreatAxe_Magic"
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
        startTriggerName = "Play_WPN_GreatAxe_Magic_Melee",
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
        startTriggerName = "Play_WPN_GreatAxe_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    greataxe_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(-0.1, 1, -0.6),
        rotationDeg = Vector3(0, -25, 0),
        scale = 1.2,
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
        startTriggerName = "Play_WPN_GreatAxe_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    greataxe_primary_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(0.5, 1.7, -0.45),
        rotationDeg = Vector3(-15, 205, 0),
        scale = 1.2,
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
        startTriggerName = "Play_WPN_GreatAxe_Magic_Melee",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    greataxe_heavy_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(0, 0.4, -0.35),
        rotationDeg = Vector3(0, -10, 0),
        scale = 1.3,
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
        startTriggerName = "Play_WPN_GreatAxe_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    },
    greataxe_heavy_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Mid_1",
        positionOffset = Vector3(0, 1.5, -0.35),
        rotationDeg = Vector3(0, 190, 0),
        scale = 1.3,
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
        startTriggerName = "Play_WPN_GreatAxe_Magic_Melee_Charged",
        stopTriggerName = "",
        preloadName = ""
      }
    }
  }
}
Merge(WeaponEffect_GreatAxe_Magic, WeaponEffectBase, true)
return WeaponEffect_GreatAxe_Magic
