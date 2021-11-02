local AbilitiesCommon = {
  backgroundPathByCategory = {
    [2052107236] = "lyshineui/images/icons/abilities/abilities_bg1.dds",
    [3325612906] = "lyshineui/images/icons/abilities/abilities_bg2.dds",
    [2925175180] = "lyshineui/images/icons/abilities/abilities_bg3.dds",
    [655788461] = "lyshineui/images/icons/abilities/abilities_bg4.dds",
    [1965507171] = "lyshineui/images/icons/abilities/abilities_bg5.dds",
    [2838003374] = "lyshineui/images/icons/abilities/abilities_bg6.dds"
  },
  passiveBackgroundPathByCategory = {
    [2052107236] = "lyshineui/images/icons/abilities/abilities_bg_passive1.dds",
    [3325612906] = "lyshineui/images/icons/abilities/abilities_bg_passive2.dds",
    [2925175180] = "lyshineui/images/icons/abilities/abilities_bg_passive3.dds",
    [655788461] = "lyshineui/images/icons/abilities/abilities_bg_passive4.dds",
    [1965507171] = "lyshineui/images/icons/abilities/abilities_bg_passive5.dds",
    [2838003374] = "lyshineui/images/icons/abilities/abilities_bg_passive6.dds"
  },
  defaultBackgroundPath = "lyshineui/images/icons/misc/empty.dds",
  emptyIcon = "lyshineui/images/hud/quickslots/quickslots_abilityEmpty.dds"
}
function AbilitiesCommon:GetBackgroundPath(uiCategory, usePassivePaths)
  if usePassivePaths then
    return self.passiveBackgroundPathByCategory[uiCategory] or self.defaultBackgroundPath
  end
  return self.backgroundPathByCategory[uiCategory] or self.defaultBackgroundPath
end
return AbilitiesCommon
