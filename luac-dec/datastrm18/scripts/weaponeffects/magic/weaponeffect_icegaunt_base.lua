local WeaponEffectBase = RequireScript("Scripts.WeaponEffects.WeaponEffectBase")
WeaponEffect_IceGaunt_Base = {
  effectGroups = {
    idle = {
      {
        type = WeaponEffectBase.EffectTypes.Particle,
        jointName = "right_hand_attach",
        particleName = "wFX_IceGaunt_Base.Idle",
        followType = EmitterFollow,
        killOnStop = true,
        playOnOwner = true
      }
    }
  }
}
Merge(WeaponEffect_IceGaunt_Base, WeaponEffectBase, true)
return WeaponEffect_IceGaunt_Base
