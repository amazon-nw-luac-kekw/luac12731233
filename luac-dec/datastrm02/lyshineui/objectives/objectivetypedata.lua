local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local objectiveIconDir = "lyshineui/images/icons/objectives/"
local offTypeObjectiveColor = ColorRgba(138, 215, 255, 1)
local ObjectiveTypeData = {
  defaultData = {
    textColor = UIStyle.COLOR_YELLOW,
    iconColor = UIStyle.COLOR_YELLOW,
    iconPath = objectiveIconDir .. "icon_objective_side.dds",
    numberedIconPath = objectiveIconDir .. "icon_objective_side",
    iconTypePath = "default"
  },
  [eObjectiveType_MainStoryQuest] = {
    textColor = UIStyle.COLOR_YELLOW_MSQ,
    iconColor = UIStyle.COLOR_WHITE,
    iconPath = objectiveIconDir .. "icon_objective_quest.dds",
    numberedIconPath = objectiveIconDir .. "icon_objective_quest",
    iconTypePath = "default"
  },
  [eObjectiveType_Darkness_Minor] = {
    textColor = UIStyle.COLOR_RED_MEDIUM,
    iconColor = UIStyle.COLOR_RED_MEDIUM,
    iconPath = objectiveIconDir .. "objective_darkness.dds",
    numberedIconPath = nil,
    iconTypePath = "darkness",
    bgColor = UIStyle.COLOR_RED_DEEP
  },
  [eObjectiveType_Darkness_Major] = {
    textColor = UIStyle.COLOR_RED_MEDIUM,
    iconColor = UIStyle.COLOR_RED_MEDIUM,
    iconPath = objectiveIconDir .. "objective_darkness_major.dds",
    numberedIconPath = nil,
    iconTypePath = "darkness_major",
    bgColor = UIStyle.COLOR_RED_DEEP
  },
  [eObjectiveType_POI] = {
    textColor = UIStyle.COLOR_GREEN_LIGHT,
    iconColor = UIStyle.COLOR_GREEN_LIGHT,
    iconPath = objectiveIconDir .. "icon_objective_side.dds",
    numberedIconPath = nil,
    iconTypePath = "journey"
  },
  [eObjectiveType_Crafting] = {
    textColor = offTypeObjectiveColor,
    iconColor = offTypeObjectiveColor,
    iconPath = objectiveIconDir .. "objective_crafting.dds",
    numberedIconPath = nil,
    iconTypePath = "crafting"
  },
  [eObjectiveType_Arena] = {
    textColor = UIStyle.COLOR_RED_MEDIUM,
    iconColor = UIStyle.COLOR_RED_MEDIUM,
    iconPath = objectiveIconDir .. "icon_objective_dungeon.dds",
    numberedIconPath = nil,
    iconTypePath = "arena"
  },
  [eObjectiveType_Mission] = {
    textColor = offTypeObjectiveColor,
    iconColor = offTypeObjectiveColor,
    iconPath = objectiveIconDir .. "objective_faction.dds",
    numberedIconPath = nil,
    iconTypePath = "mission"
  },
  [eObjectiveType_CommunityGoal] = {
    textColor = offTypeObjectiveColor,
    iconColor = offTypeObjectiveColor,
    iconPath = objectiveIconDir .. "icon_objective_townproject.dds",
    numberedIconPath = objectiveIconDir .. "icon_objective_townProject",
    iconTypePath = "community"
  },
  [eObjectiveType_Dungeon] = {
    textColor = UIStyle.COLOR_RARITY_ORANGE,
    iconColor = UIStyle.COLOR_RARITY_ORANGE,
    iconPath = objectiveIconDir .. "icon_objective_dungeon.dds",
    numberedIconPath = nil,
    iconTypePath = "arena"
  },
  [eObjectiveType_DefendObject] = {
    textColor = UIStyle.COLOR_GREEN_LIGHT,
    iconColor = UIStyle.COLOR_GREEN_LIGHT,
    iconPath = objectiveIconDir .. "icon_Objective_Quest.dds",
    numberedIconPath = nil,
    iconTypePath = "arena"
  },
  [eObjectiveType_DynamicPOI] = {
    textColor = UIStyle.COLOR_GREEN,
    iconColor = UIStyle.COLOR_GREEN,
    iconPath = objectiveIconDir .. "icon_objective_DynamicPOI.dds",
    numberedIconPath = nil,
    iconTypePath = "journey"
  }
}
ObjectiveTypeData.ObjectiveStates = {
  Available = {
    iconPath = objectiveIconDir .. "icon_questAvailable.dds",
    textColor = UIStyle.COLOR_YELLOW
  },
  InProgress = {},
  ReadyToTurnIn = {
    iconPath = objectiveIconDir .. "icon_questReadyForTurnIn.dds",
    textColor = UIStyle.COLOR_GREEN_BRIGHT
  }
}
function ObjectiveTypeData:GetType(type)
  return self[type] or self.defaultData
end
function ObjectiveTypeData:SetFaction(faction)
  local factionData = FactionCommon.factionInfoTable[faction]
  if factionData then
    self[eObjectiveType_Mission].iconPath = factionData.objectiveIcon
    if faction ~= eFactionType_None then
      self[eObjectiveType_Mission].numberedIconPath = string.gsub(factionData.objectiveIcon, ".dds$", "")
    end
  end
end
function ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(objectiveInstanceId)
  local playerEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local objectiveEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ObjectiveEntityId")
  local isObjectiveReadyToTurnIn = ObjectivesComponentRequestBus.Event.IsObjectiveReadyForCompletion(playerEntityId, objectiveInstanceId)
  local objectiveState = self.ObjectiveStates.InProgress
  if isObjectiveReadyToTurnIn then
    objectiveState = self.ObjectiveStates.ReadyToTurnIn
  end
  local objectiveNumber = ObjectivesComponentRequestBus.Event.GetObjectiveSortingPos(objectiveEntityId, objectiveInstanceId)
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveInstanceId)
  local iconStyleData = self:GetType(objectiveType)
  local iconColor = isObjectiveReadyToTurnIn and UIStyle.COLOR_WHITE or iconStyleData.iconColor
  local iconPath = ""
  if objectiveState.iconPath then
    iconPath = objectiveState.iconPath
  elseif iconStyleData.numberedIconPath and objectiveNumber ~= nil and -1 < objectiveNumber then
    iconPath = iconStyleData.numberedIconPath .. "_" .. tostring(objectiveNumber + 1) .. ".dds"
  else
    iconPath = iconStyleData.iconPath
  end
  local textColor = objectiveState.textColor and objectiveState.textColor or iconStyleData.textColor
  return iconPath, iconColor, isObjectiveReadyToTurnIn, textColor
end
function ObjectiveTypeData:GetObjectiveIconForCompletion()
  local iconPath = self.ObjectiveStates.ReadyToTurnIn.iconPath
  local iconColor = UIStyle.COLOR_WHITE
  local textColor = self.ObjectiveStates.ReadyToTurnIn.textColor
  return iconPath, iconColor, textColor
end
function ObjectiveTypeData:GetObjectiveIconByType(typeEnum)
  local iconStyleData = self:GetType(typeEnum)
  local iconPath = iconStyleData.iconPath
  local iconColor = iconStyleData.iconColor
  local textColor = iconStyleData.textColor
  return iconPath, iconColor, textColor
end
return ObjectiveTypeData
