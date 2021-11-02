local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Undead_Torch = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "cFX_npc_Lost.Torch",
        followType = EmitterFollow,
        killOnStop = false
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Sword_Fire_Idle",
        stopTriggerName = "",
        preloadName = "Perks_Sword_Fire"
      }
    },
    PowerUp = {},
    melee_1 = {}
  }
}
Merge(WeaponEffect_Undead_Torch, WeaponEffectBase, true)
return WeaponEffect_Undead_Torch
