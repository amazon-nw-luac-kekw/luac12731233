local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Spear_Lightning = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Mid_01",
        particleName = "cFX_npc_Siren.Spear_Idle",
        followType = EmitterFollow,
        killOnStop = true
      },
      {
        type = WeaponEffectBase.EffectTypes.Audio,
        startTriggerName = "Play_WPN_Spear_Lightning_Idle",
        stopTriggerName = "Stop_WPN_Spear_Lightning_Idle",
        preloadName = "Perks_Spear_Lightning"
      }
    }
  }
}
Merge(WeaponEffect_Spear_Lightning, WeaponEffectBase, true)
return WeaponEffect_Spear_Lightning
