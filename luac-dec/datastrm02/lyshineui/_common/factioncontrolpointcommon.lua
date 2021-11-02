local FactionControlPointCommon = {}
FactionControlPointCommon.buffInfoTable = {
  [eFactionControlBufType_None] = {
    iconImagePath = "lyshineui/images/map/icon/icon_crossedswords_small_white.dds",
    isPercent = false,
    prefix = "+"
  },
  [eFactionControlBufType_InfluencePoints_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_ipincrease.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_ExperiencePoints_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_xpincrease.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_Azoth_FastTravel_GeneralCost_Reduction] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_fasttravelcost.dds",
    isPercent = true,
    prefix = "-"
  },
  [eFactionControlBufType_Azoth_FastTravel_Weight_Reduction] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_fasttravelweight.dds",
    isPercent = false,
    prefix = ""
  },
  [eFactionControlBufType_Azoth_FastTravel_Distance_Reduction] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_fasttraveldistance.dds",
    isPercent = false,
    prefix = ""
  },
  [eFactionControlBufType_Azoth_Crafting_Effectiveness_Modifer] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_craftingeffectiveness.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_Taxes_Crafting_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_craftingtax.dds",
    isPercent = true,
    prefix = "-"
  },
  [eFactionControlBufType_Taxes_Refining_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_refiningtaxes.dds",
    isPercent = true,
    prefix = "-"
  },
  [eFactionControlBufType_Taxes_Trading_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_tradingtaxes.dds",
    isPercent = true,
    prefix = "-"
  },
  [eFactionControlBufType_Taxes_Housing_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_housingtaxes.dds",
    isPercent = true,
    prefix = "-"
  },
  [eFactionControlBufType_Rewards_FactionMission_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_missionrewards.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_Rewards_DarknessEvent_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_darknessevent.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_Rewards_Expedition_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_spriggankey.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_Gathering_Speed_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_gatheringspeed.dds",
    isPercent = true,
    prefix = "+"
  },
  [eFactionControlBufType_Gathering_Volume_Modifier] = {
    iconImagePath = "lyshineui/images/icons/factionbuffs/fc_buff_gatheringvolume.dds",
    isPercent = true,
    prefix = "+"
  }
}
function FactionControlPointCommon:GetTerritoryBonuses(territoryId, forBio)
  local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
  local territoryBonuses = {}
  local j = 0
  for i = 1, territoryDefn.territoryBuffCount do
    local buffId = territoryDefn:GetTerritoryBuff(j)
    j = j + 1
    local territoryBuf = FactionControlDataManagerBus.Broadcast.GetFactionControlDataDefinition(buffId)
    local buffInfo = self.buffInfoTable[buffId]
    if buffInfo then
      local formattedValue, tooltipString = self:BuildTooltipAndValueString(buffId, buffInfo, territoryBuf)
      local bonus = {
        imagePath = buffInfo.iconImagePath,
        bonusName = territoryBuf.name,
        bonusValue = formattedValue,
        tooltiptext = tooltipString
      }
      if forBio then
        bonus.tooltip = tooltipString
        bonus.formattedBonusValue = formattedValue
      end
      table.insert(territoryBonuses, bonus)
    end
  end
  return territoryBonuses
end
function FactionControlPointCommon:GetFactionBonuses(territoryId, forBio)
  local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
  local factionBonuses = {}
  local buffId = territoryDefn.factionControlBuff
  local factionBonusData = FactionControlDataManagerBus.Broadcast.GetFactionControlDataDefinition(buffId)
  local buffInfo = self.buffInfoTable[buffId]
  if buffInfo then
    local formattedValue, tooltipString = self:BuildTooltipAndValueString(buffId, buffInfo, factionBonusData)
    local bonus = {
      imagePath = buffInfo.iconImagePath,
      bonusName = factionBonusData.name,
      bonusValue = formattedValue,
      tooltiptext = tooltipString
    }
    if forBio then
      bonus.tooltip = tooltipString
      bonus.formattedBonusValue = formattedValue
    end
    table.insert(factionBonuses, bonus)
  end
  return factionBonuses
end
function FactionControlPointCommon:BuildReminderString(territoryId)
  if territoryId ~= 0 then
    local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territoryId)
    if warDetails:IsValid() and warDetails:IsWarActive() then
      local siegeTypeString = "@ui_factioncontrol_reminder_type_war"
      if warDetails:IsInvasion() then
        siegeTypeString = "@ui_factioncontrol_reminder_type_invasion"
      end
      return GetLocalizedReplacementText("@ui_factioncontrol_reminder_map_inactive_specific", {siegeType = siegeTypeString, siegeType2 = siegeTypeString})
    end
  end
  return "@ui_factioncontrol_reminder_map_inactive"
end
function FactionControlPointCommon:BuildTooltipAndValueString(buffId, buffInfo, bonusData)
  if buffId == eFactionControlBufType_Azoth_FastTravel_Weight_Reduction then
    local baseEncumbranceCost = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.housing.fast-travel-settlement-encumbranceCost")
    local finalEncumbranceCost = baseEncumbranceCost - bonusData.buffValue
    local weight = GetFormattedNumber(ConfigProviderEventBus.Broadcast.GetUInt64("javelin.housing.fast-travel-settlement-encumbranceScaleFactor") / 10, 0, false)
    return buffInfo.prefix .. finalEncumbranceCost, GetLocalizedReplacementText(bonusData.description, {value = finalEncumbranceCost, scaleFactor = weight})
  end
  if buffId == eFactionControlBufType_Azoth_FastTravel_Distance_Reduction then
    local baseDistanceCost = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.housing.fast-travel-settlement-distCost")
    local finalDistanceCost = baseDistanceCost - bonusData.buffValue
    local distance = GetFormattedNumber(ConfigProviderEventBus.Broadcast.GetFloat("javelin.housing.fast-travel-settlement-additionalDistMod"), 0, false)
    return buffInfo.prefix .. finalDistanceCost, GetLocalizedReplacementText(bonusData.description, {value = finalDistanceCost, scaleFactor = distance})
  end
  local bonusValue = bonusData.buffValue
  if buffInfo.isPercent then
    bonusValue = string.format("%d" .. "%%", bonusData.buffValue * 100)
  end
  return buffInfo.prefix .. bonusValue, GetLocalizedReplacementText(bonusData.description, {value = bonusValue})
end
return FactionControlPointCommon
