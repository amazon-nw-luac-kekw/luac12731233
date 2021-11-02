local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_DryadSwamp_Shaman_Staff = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "cFX_npc_SwampDryadShaman.Staff_Idle",
        followType = EmitterFollow,
        killOnStop = false
      }
    }
  }
}
Merge(WeaponEffect_DryadSwamp_Shaman_Staff, WeaponEffectBase, true)
return WeaponEffect_DryadSwamp_Shaman_Staff
