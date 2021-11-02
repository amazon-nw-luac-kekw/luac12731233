local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Default = {
  effectGroups = {
    idle = {},
    melee_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Default_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    melee_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Sword.Swipe_2",
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      }
    },
    melee_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_01",
        particleName = "wFX_Default_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    melee_charged_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Default_Melee.Swipe_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    thrust_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Default_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    thrust_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Default_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    thrust_charged_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Melee_02",
        particleName = "wFX_Default_Melee.Stab_MD",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    sword_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(0, 1.8, -0.35),
        rotationDeg = Vector3(0, -30, 0),
        scale = 1.25,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      }
    },
    sword_primary_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Fast_1",
        positionOffset = Vector3(0, 2.75, -0.35),
        rotationDeg = Vector3(-10, 195, 0),
        scale = 1.25,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      }
    },
    sword_primary_3 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Spin_Fast_1",
        positionOffset = Vector3(0, 0.65, -0.35),
        rotationDeg = Vector3(0, 0, 0),
        scale = 1.4,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
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
      }
    },
    rapier_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Base_01",
        particleName = "wFX_Default_Melee.Stab_SM",
        positionOffset = Vector3(0, 0, 0),
        rotationDeg = Vector3(0, 0, 0),
        scale = 1,
        followType = EmitterFollow,
        killOnStop = true
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
      }
    },
    warhammer_primary_1 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Wide_Mid",
        positionOffset = Vector3(0, 1.2, -0.35),
        rotationDeg = Vector3(0, 240, -45),
        scale = 0.85,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      }
    },
    warhammer_primary_2 = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Wide_Mid",
        positionOffset = Vector3(0, 2, -0.35),
        rotationDeg = Vector3(0, 45, -45),
        scale = 0.85,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      }
    },
    warhammer_heavy = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "aim_direction",
        particleName = "wFX_Default_Melee.Mesh.Swipe_Wide_Mid",
        positionOffset = Vector3(0, 1.2, -0.35),
        rotationDeg = Vector3(0, -95, -50),
        scale = 1.2,
        followType = EmitterFollow,
        killOnStop = false,
        playOnOwner = true
      }
    },
    shot = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Default_Range.Musket_MuzzleFlash",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Default_Range.Musket_MuzzleSmoke",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    shot_charged = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Default_Range.Musket_MuzzleFlash",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Musket_Sharpshooter.Muzzle_PowerSmoke",
        followType = EmitterFollow,
        killOnStop = false
      }
    },
    shot_charged_clean = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_muzzle",
        particleName = "wFX_Default_Range.Musket_MuzzleFlash",
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
    },
    powder_charge = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Musket_Sharpshooter.Powder_Charged",
        followType = EmitterFollow,
        killOnStop = true
      }
    },
    stopping_charge = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Attach_01",
        particleName = "wFX_Musket_Sharpshooter.Stopping_Charged",
        followType = EmitterFollow,
        killOnStop = true
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
Merge(WeaponEffect_Default, WeaponEffectBase, true)
return WeaponEffect_Default
