local FlyoutRow_FactionMission = {
  Properties = {
    ContentContainer = {
      default = EntityId()
    },
    TimeLimit = {
      default = EntityId()
    },
    TimeHeader = {
      default = EntityId()
    },
    TimeText = {
      default = EntityId()
    },
    DifficultyText = {
      default = EntityId()
    },
    EnemyLevelRangeText = {
      default = EntityId()
    },
    RewardsContainer = {
      default = EntityId()
    },
    RewardsText = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    }
  }
}
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_FactionMission)
function FlyoutRow_FactionMission:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
end
local difficultyTexts = {
  [eObjectiveDifficulty_None] = "",
  [eObjectiveDifficulty_Easy] = "@ui_easy",
  [eObjectiveDifficulty_Medium] = "@ui_medium",
  [eObjectiveDifficulty_Hard] = "@ui_hard"
}
function FlyoutRow_FactionMission:SetData(data)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, false)
  if not data then
    Log("[FlyoutRow_FactionMission] Error: invalid data passed to SetData")
    return
  end
  if UiElementBus.Event.IsEnabled(self.Properties.TimeLimit) then
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.TimeLimit, 88)
  end
  local detailsList = data.detailsList
  UiTextBus.Event.SetTextWithFlags(self.Properties.DifficultyText, detailsList.difficultyText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.EnemyLevelRangeText, detailsList.enemyRangeStr, eUiTextSet_SetLocalized)
  local modifiers = GameEventRequestBus.Broadcast.GetFactionControlModifiers(eFactionControlBufType_Rewards_FactionMission_Modifier)
  local faction = data.faction
  local taskData = data.task
  local reputationImagePath = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(faction) .. ".dds"
  local tokensImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
  local rewardStr = taskData:GetDetailedRewardsDisplayString(modifiers, "@ui_fcp_faction_mission_bonus_label")
  local successRewardData = ObjectiveDataHelper:GetGameEventDataWithObjectiveRewardData(taskData:GetSuccessRewardId(), Math.CreateCrc32(taskData.objectiveData.id))
  local hasFactionWarInfluence = taskData:GetFactionWarInfluence() ~= ""
  if hasFactionWarInfluence then
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionCommon.factionInfoTable[faction].crestBg)
    UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionCommon.factionInfoTable[faction].crestBgColor)
    local warInfluenceIcon = "<font color=" .. ColorRgbaToHexString(factionCommon.factionInfoTable[faction].crestBgColor) .. ">" .. taskData:GetFactionWarInfluence() .. "</font> "
    local label = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@owg_rewardtype_warinfluence_label")
    label = " <font face=\"lyshineui/fonts/nimbus_medium.font\">" .. label .. "</font>"
    local factionName = factionCommon.factionInfoTable[faction].factionName
    rewardStr = rewardStr .. [[

    ]] .. warInfluenceIcon .. factionName .. label
  end
  local progressionModifier = modifiers.categoricalProgressionRewardModifier
  local factionReputation = GetLocalizedReplacementText("@owg_rewardtype_guildreputation", {
    icon = reputationImagePath,
    amount = tostring(math.floor(successRewardData.factionReputation * progressionModifier))
  })
  local factionTokens = GetLocalizedReplacementText("@owg_rewardtype_guildcurrency", {
    icon = tokensImagePath,
    amount = tostring(math.floor(successRewardData.factionTokens * progressionModifier))
  })
  local localize = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement
  if 1 < progressionModifier then
    factionReputation = factionReputation .. " " .. localize("@ui_fcp_faction_mission_bonus_label", tostring(math.floor(successRewardData.factionReputation * (progressionModifier - 1))))
    factionTokens = factionTokens .. " " .. localize("@ui_fcp_faction_mission_bonus_label", tostring(math.floor(successRewardData.factionTokens * (progressionModifier - 1))))
  end
  rewardStr = factionTokens .. "\n" .. rewardStr
  rewardStr = factionReputation .. "\n" .. rewardStr
  if string.len(successRewardData.itemReward) > 0 then
    local itemRewardText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(StaticItemDataManager:GetItemName(successRewardData.itemReward))
    rewardStr = rewardStr .. "\n" .. itemRewardText
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.RewardsText, rewardStr, eUiTextSet_SetLocalized)
  local isInProgress = data.task:IsInProgress()
  local isAvailable = data.task:IsAvailable()
  local isReadyToComplete = data.task:IsReadyToComplete()
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
  local containerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ContentContainer)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, containerHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, containerHeight)
end
return FlyoutRow_FactionMission
