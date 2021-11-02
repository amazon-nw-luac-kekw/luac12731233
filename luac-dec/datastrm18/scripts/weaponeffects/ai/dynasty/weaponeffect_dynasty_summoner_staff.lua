local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_Dynasty_Summoner_Staff = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        attachmentName = "vfx_Tip_01",
        particleName = "cFX_npc_Dynasty_Summoner.Staff_Idle_01",
        followType = EmitterFollow,
        killOnStop = false
      }
    }
  }
}
Merge(WeaponEffect_Dynasty_Summoner_Staff, WeaponEffectBase, true)
return WeaponEffect_Dynasty_Summoner_Staff
