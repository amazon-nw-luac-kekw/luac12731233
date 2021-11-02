local TradeSkillsCommon = {}
TradeSkillsCommon.CraftingSkillsData = {
  {
    name = "Weaponsmithing",
    locName = "@ui_weaponsmithing",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\weaponsmithing.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_blacksmithing.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\forge.dds",
    requireSubText = "@blacksmith_station",
    descText = "@ui_gearscore_bonus",
    tableId = 3463856138
  },
  {
    name = "Armoring",
    locName = "@ui_armoring",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\armoring.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_outfitting.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\tailor.dds",
    requireSubText = "@outfitting_station",
    requireIcon2 = "LyShineUI\\Images\\Icons\\Stations\\forge.dds",
    requireSubText2 = "@blacksmith_station",
    descText = "@ui_gearscore_bonus",
    tableId = 50620476
  },
  {
    name = "Engineering",
    locName = "@ui_engineering",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\engineering.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_engineering.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\workshop.dds",
    requireSubText = "@engineering_station",
    requireIcon2 = "LyShineUI\\Images\\Icons\\Stations\\forge.dds",
    requireSubText2 = "@blacksmith_station",
    descText = "@ui_gearscore_bonus",
    tableId = 242652078
  },
  {
    name = "Jewelcrafting",
    locName = "@ui_jewelcrafting",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\jewelcrafting.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_jewelcrafting.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\tailor.dds",
    requireSubText = "@outfitting_station",
    descText = "@ui_gearscore_bonus",
    tableId = 2853394152
  },
  {
    name = "Arcana",
    locName = "@ui_arcana",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\arcana.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_alchemy.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\arcanist.dds",
    requireSubText = "@alchemy_station",
    descText = "@ui_gearscore_bonus",
    tableId = 1345659118
  },
  {
    name = "Cooking",
    locName = "@ui_cooking",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\cooking.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_provisioning.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\kitchen.dds",
    requireSubText = "@cooking_station",
    descText = "@ui_gearscore_bonus",
    tableId = 1182525034
  },
  {
    name = "Furnishing",
    locName = "@ui_furnishing",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\furnishing.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_furnishing.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\workshop.dds",
    requireSubText = "@engineering_station",
    descText = "@ui_gearscore_bonus",
    tableId = 2953732754
  },
  {
    name = "Smelting",
    locName = "@ui_smelting",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\smelting.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_smelting.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\smelter.dds",
    requireSubText = "@smelting_station",
    descText = "@ui_craftchance_bonus",
    tableId = 580130092
  },
  {
    name = "Woodworking",
    locName = "@ui_woodworking",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\woodworking.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_woodworking.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\woodshop.dds",
    requireSubText = "@carpentry_station",
    descText = "@ui_craftchance_bonus",
    tableId = 2617220015
  },
  {
    name = "Leatherworking",
    locName = "@ui_leatherworking",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\leatherworking.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_leatherworking.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\tanning.dds",
    requireSubText = "@tanning_station",
    descText = "@ui_craftchance_bonus",
    tableId = 1929694176
  },
  {
    name = "Weaving",
    locName = "@ui_weaving",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\weaving.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_weaving.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\loom.dds",
    requireSubText = "@weaving_station",
    descText = "@ui_craftchance_bonus",
    tableId = 1764904178
  },
  {
    name = "Stonecutting",
    locName = "@ui_stonecutting",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\stonecutting.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_masonary.dds",
    requireText = "@ui_requires_station",
    requireIcon = "LyShineUI\\Images\\Icons\\Stations\\mason.dds",
    requireSubText = "@masonry_station",
    descText = "@ui_craftchance_bonus",
    tableId = 749528765
  }
}
TradeSkillsCommon.GatheringSkillsData = {
  {
    name = "Logging",
    locName = "@ui_logging",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\logging.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_logging.dds",
    requireText = "@ui_toolrequired",
    requireIcon = "LyShineUI\\Images\\Icons\\Items\\Drawing\\2hAxe.dds",
    requireSubText = "@ui_axe",
    descText = "@ui_gathering_speed_bonus",
    tableId = 3398787834
  },
  {
    name = "Mining",
    locName = "@ui_mining",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\mining.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_mining.dds",
    requireText = "@ui_toolrequired",
    requireIcon = "LyShineUI\\Images\\Icons\\Items\\Drawing\\1hPick.dds",
    requireSubText = "@ui_pickaxe",
    descText = "@ui_gathering_speed_bonus",
    tableId = 635267670
  },
  {
    name = "Harvesting",
    locName = "@ui_harvesting",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\harvesting.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_harvesting.dds",
    requireText = "@ui_toolrequired",
    requireIcon = "LyShineUI\\Images\\Icons\\Items\\Drawing\\1hSickle.dds",
    requireSubText = "@ui_sickle",
    descText = "@ui_gathering_speed_bonus",
    tableId = 1725414313
  },
  {
    name = "Skinning",
    locName = "@ui_skinning",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\tracking.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_skinning.dds",
    requireText = "@ui_toolrequired",
    requireIcon = "LyShineUI\\Images\\Icons\\Items\\Drawing\\1hSkinningKnife.dds",
    requireSubText = "@ui_skinningknife",
    descText = "@ui_gathering_speed_bonus",
    tableId = 1944192246
  },
  {
    name = "Fishing",
    locName = "@ui_fishing",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\Large\\fishing.dds",
    smallIcon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_fishing.dds",
    requireText = "@ui_toolrequired",
    requireIcon = "LyShineUI\\Images\\Icons\\Items\\Drawing\\2hFishingPole.dds",
    requireSubText = "@ui_fishingpole",
    descText = "@ui_casting_distance_bonus",
    tableId = 1975517117
  }
}
TradeSkillsCommon.StationsData = {
  {
    name = "alchemy",
    icon = "LyShineUI\\Images\\Icons\\Stations\\arcanist.dds"
  },
  {
    name = "blacksmith",
    icon = "LyShineUI\\Images\\Icons\\Stations\\forge.dds"
  },
  {
    name = "cooking",
    icon = "LyShineUI\\Images\\Icons\\Stations\\kitchen.dds"
  },
  {
    name = "engineering",
    icon = "LyShineUI\\Images\\Icons\\Stations\\workshop.dds"
  },
  {
    name = "outfitting",
    icon = "LyShineUI\\Images\\Icons\\Stations\\tailor.dds"
  },
  {
    name = "carpentry",
    icon = "LyShineUI\\Images\\Icons\\Stations\\woodshop.dds"
  },
  {
    name = "masonry",
    icon = "LyShineUI\\Images\\Icons\\Stations\\mason.dds"
  },
  {
    name = "smelting",
    icon = "LyShineUI\\Images\\Icons\\Stations\\smelter.dds"
  },
  {
    name = "tanning",
    icon = "LyShineUI\\Images\\Icons\\Stations\\tanning.dds"
  },
  {
    name = "weaving",
    icon = "LyShineUI\\Images\\Icons\\Stations\\loom.dds"
  },
  {
    name = "camp",
    icon = "LyShineUI\\Images\\Icons\\Tradeskills\\icon_tradeskill_camping.dds"
  }
}
function TradeSkillsCommon:GetTradeSkillDataFromTableId(tableCrc)
  for _, data in pairs(self.CraftingSkillsData) do
    if data.tableId == tableCrc then
      return data
    end
  end
  for _, data in pairs(self.GatheringSkillsData) do
    if data.tableId == tableCrc then
      return data
    end
  end
end
function TradeSkillsCommon:IsGatheringSkill(tableCrc)
  for _, data in pairs(self.GatheringSkillsData) do
    if data.tableId == tableCrc then
      return true
    end
  end
  return false
end
function TradeSkillsCommon:IsCraftingSkill(tableCrc)
  for _, data in pairs(self.CraftingSkillsData) do
    if data.tableId == tableCrc then
      return true
    end
  end
  return false
end
function TradeSkillsCommon:GetStationData(name)
  for _, data in pairs(self.StationsData) do
    if data.name == name then
      return data
    end
  end
end
return TradeSkillsCommon
