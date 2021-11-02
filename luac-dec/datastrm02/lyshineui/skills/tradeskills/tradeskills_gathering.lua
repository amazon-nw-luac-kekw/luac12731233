local TradeSkills_Gathering = {
  Properties = {
    DetailPanel = {
      default = EntityId()
    },
    SimpleGridItemList = {
      default = EntityId()
    },
    GatherableTradeSkillPrototype = {
      default = EntityId()
    },
    BackButton = {
      default = EntityId()
    },
    MaxGatherLevelSection = {
      default = EntityId()
    },
    MaxGatherLevelLabel = {
      default = EntityId()
    },
    GridLabel = {
      default = EntityId()
    },
    MaxGatherLevelText = {
      default = EntityId()
    },
    NextMaxGatherLevelText = {
      default = EntityId()
    },
    MaxGatherLevelQuestionMark = {
      default = EntityId()
    }
  },
  iconPath = "LyshineUI\\images\\tradeskills\\tradeskill_"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeSkills_Gathering)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TradeSkills_Gathering:OnInit()
  BaseElement.OnInit(self)
  self.fishingHotspotTypes = {
    {name = "broad", crc = 2438252701},
    {name = "rare", crc = 2310445247},
    {name = "secret", crc = 1554180325}
  }
  self.SimpleGridItemList:Initialize(self.GatherableTradeSkillPrototype)
  self.SimpleGridItemList:OnListDataSet(nil)
  self.BackButton:SetText("@ui_back")
  self.BackButton:SetButtonSingleIconPath("lyshineui/images/icons/misc/icon_back.dds")
  self.BackButton:SetButtonSingleIconSize(16)
  self.BackButton:PositionButtonSingleIconToText()
  self.BackButton:SetCallback(self.BackClick, self)
  SetTextStyle(self.Properties.MaxGatherLevelText, self.UIStyle.FONT_STYLE_GATHERING_ITEM_TITLE)
  SetTextStyle(self.Properties.NextMaxGatherLevelText, self.UIStyle.FONT_STYLE_FLAVOR_TEXT)
  self.MaxGatherLevelQuestionMark:SetButtonStyle(self.MaxGatherLevelQuestionMark.BUTTON_STYLE_QUESTION_MARK)
end
function TradeSkills_Gathering:FindDataByIconTypeUnlock(dataTable, iconTypeUnlock)
  for _, data in ipairs(dataTable) do
    if data.iconTypeUnlock == iconTypeUnlock then
      return data
    end
  end
end
function TradeSkills_Gathering:SetVisible(visible, skillData)
  if self.screenVisibleCallback and self.screenVisibleCallbackTable then
    self.screenVisibleCallback(self.screenVisibleCallbackTable, self, visible)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, visible)
  if not visible then
    return
  end
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  local maxRank = CategoricalProgressionRequestBus.Event.GetMaxRank(playerEntityId, skillData.tableId)
  local rankToUse = maxRank < skillData.currentLevel and maxRank or skillData.currentLevel
  local staticRankData = CategoricalProgressionRequestBus.Event.GetStaticTradeskillRankData(playerEntityId, skillData.tableId, rankToUse)
  local isFishing = false
  local myGatheringSpeedBonus = GetFormattedNumber(staticRankData.gatheringEfficiency * 100, 1) .. "%"
  if skillData.tableId == 1975517117 then
    myGatheringSpeedBonus = string.format("%.2f", staticRankData.fishingMaxCastDistanceBonus) .. "m"
    isFishing = true
  end
  local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, skillData.tableId)
  local requiredProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(playerEntityId, skillData.tableId, skillData.currentLevel)
  self.DetailPanel:OnSetDetailPanel({
    currentLevel = skillData.currentLevel,
    progressPercent = skillData.progressPercent,
    currentXp = currentProgress,
    nextLevelXp = requiredProgress,
    maxRank = maxRank
  }, skillData.locName, skillData.icon)
  self.DetailPanel:SetDescription(skillData.descText, myGatheringSpeedBonus)
  self.DetailPanel:SetRequirements(skillData.requireText, skillData.requireSubText, skillData.requireIcon, skillData.requireSubText2, skillData.requireIcon2)
  self.unlockLevels = {}
  self.maxGatherLevels = {}
  local lastMaxGatherLevel = 0
  local currentGatherLevelIndex
  local label1 = "@ui_harvestable_at"
  if isFishing then
    local hotspotsPerLevel = FishingRequestsBus.Event.GetNumHotspotUnlocksPerLevel(playerEntityId)
    for i = 1, #hotspotsPerLevel do
      local data = hotspotsPerLevel[i]
      local numTypes = 0
      local keyData = {}
      for _, type in ipairs(self.fishingHotspotTypes) do
        local num = data:GetNumHotspotsByType(type.crc)
        if 0 < num then
          numTypes = numTypes + 1
          keyData["num" .. numTypes] = num
          keyData["type" .. numTypes] = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_hotspot_" .. type.name)
        end
      end
      local locTag = "@ui_num_hotspot_type_" .. numTypes
      if numTypes == 1 and 1 < keyData.num1 then
        locTag = "@ui_num_hotspot_type_1_plural"
      end
      table.insert(self.unlockLevels, {
        gatherUnlockLevel = data.level,
        trackingUnlockLevel = data.level,
        iconTypeUnlock = "Fishing",
        displayName = GetLocalizedReplacementText(locTag, keyData)
      })
    end
    label1 = "@ui_discoverable_and_trackable_at"
  else
    local targetLevel = -1
    local tradeskillLockedGatherableData = CategoricalProgressionRequestBus.Event.GetTradeskillLockedGatherableData(playerEntityId, skillData.name, targetLevel)
    for i = 1, #tradeskillLockedGatherableData do
      local gatherData = tradeskillLockedGatherableData[i]
      local iconTypeUnlock = gatherData.iconTypeUnlock
      if iconTypeUnlock and iconTypeUnlock ~= "" then
        local tradeskillLevel = gatherData.tradeskillLevel
        local dataToUpdate = self:FindDataByIconTypeUnlock(self.unlockLevels, iconTypeUnlock)
        if not dataToUpdate then
          local displayName = "@iconTypeUnlock_" .. iconTypeUnlock
          table.insert(self.unlockLevels, {
            gatherUnlockLevel = tradeskillLevel,
            iconTypeUnlock = iconTypeUnlock,
            displayName = displayName
          })
        else
          dataToUpdate.gatherUnlockLevel = tradeskillLevel
        end
      end
    end
    local rankDataLevel = 0
    local rankData = CategoricalProgressionRequestBus.Event.GetStaticTradeskillRankData(playerEntityId, skillData.tableId, rankDataLevel)
    while rankData and rankData:IsValid() do
      local iconTypeUnlock = rankData.iconTypeUnlock
      if iconTypeUnlock and iconTypeUnlock ~= "" then
        local dataToUpdate = self:FindDataByIconTypeUnlock(self.unlockLevels, iconTypeUnlock)
        if not dataToUpdate then
          table.insert(self.unlockLevels, {
            trackingUnlockLevel = rankDataLevel,
            iconTypeUnlock = iconTypeUnlock,
            displayName = rankData.displayName
          })
        else
          dataToUpdate.trackingUnlockLevel = rankDataLevel
          dataToUpdate.displayName = rankData.displayName
        end
      end
      if rankData.maxGatherLevel and lastMaxGatherLevel < rankData.maxGatherLevel then
        table.insert(self.maxGatherLevels, {
          skillLevel = rankDataLevel,
          maxGatherLevel = rankData.maxGatherLevel
        })
        if rankDataLevel <= skillData.currentLevel then
          currentGatherLevelIndex = #self.maxGatherLevels
        end
        lastMaxGatherLevel = rankData.maxGatherLevel
      end
      rankDataLevel = rankDataLevel + 1
      rankData = CategoricalProgressionRequestBus.Event.GetStaticTradeskillRankData(playerEntityId, skillData.tableId, rankDataLevel)
    end
  end
  if #self.maxGatherLevels > 0 then
    local currentMaxGatherLevel = self.maxGatherLevels[currentGatherLevelIndex].maxGatherLevel
    UiTextBus.Event.SetText(self.Properties.MaxGatherLevelText, GetLocalizedReplacementText("@ui_canSkinLevel", {
      levelColor = ColorRgbaToHexString(self.UIStyle.COLOR_RED_MEDIUM),
      maxGatherLevel = currentMaxGatherLevel
    }))
    local nextMaxGatherLevelData = self.maxGatherLevels[currentGatherLevelIndex + 1]
    UiElementBus.Event.SetIsEnabled(self.Properties.NextMaxGatherLevelText, nextMaxGatherLevelData ~= nil)
    if nextMaxGatherLevelData then
      local nextMaxGatherLevelString = GetLocalizedReplacementText("@ui_skillToSkinLevel", {
        skillLevel = nextMaxGatherLevelData.skillLevel,
        maxGatherLevel = nextMaxGatherLevelData.maxGatherLevel
      })
      UiTextBus.Event.SetText(self.Properties.NextMaxGatherLevelText, nextMaxGatherLevelString)
    end
    local tooltipString = "<font color=\"#FFFFFF\">"
    local hasClosedColorTag = false
    local locTagForTemplate = "@ui_skillToSkinLevelShort"
    for index, maxGatherLevelData in ipairs(self.maxGatherLevels) do
      if currentGatherLevelIndex < index and not hasClosedColorTag then
        tooltipString = tooltipString .. "</font>"
        hasClosedColorTag = true
      end
      if 1 < index then
        tooltipString = tooltipString .. "\n"
      end
      tooltipString = tooltipString .. GetLocalizedReplacementText(locTagForTemplate, {
        skillLevel = maxGatherLevelData.skillLevel,
        maxGatherLevel = maxGatherLevelData.maxGatherLevel
      })
    end
    self.MaxGatherLevelQuestionMark:SetTooltip(tooltipString)
    UiElementBus.Event.SetIsEnabled(self.Properties.MaxGatherLevelSection, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.SimpleGridItemList, 202)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.SimpleGridItemList, 599)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.MaxGatherLevelSection, false)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.SimpleGridItemList, 1)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.SimpleGridItemList, 800)
  end
  table.sort(self.unlockLevels, function(a, b)
    if a.gatherUnlockLevel == b.gatherUnlockLevel then
      return (a.trackingUnlockLevel and a.trackingUnlockLevel or 0) < (b.trackingUnlockLevel and b.trackingUnlockLevel or 0)
    end
    return (a.gatherUnlockLevel and a.gatherUnlockLevel or 0) < (b.gatherUnlockLevel and b.gatherUnlockLevel or 0)
  end)
  local itemDataList = {}
  for _, levelData in ipairs(self.unlockLevels) do
    local iconTypeUnlock = levelData.iconTypeUnlock
    if #self.maxGatherLevels == 0 then
      table.insert(itemDataList, {
        image = self.iconPath .. iconTypeUnlock .. ".dds",
        imageLabel = levelData.displayName,
        label1 = label1,
        level1 = levelData.gatherUnlockLevel or 0,
        label2 = "@ui_tracked_at",
        level2 = levelData.trackingUnlockLevel or -1,
        currentSkillLevel = skillData.currentLevel
      })
    else
      table.insert(itemDataList, {
        image = self.iconPath .. iconTypeUnlock .. ".dds",
        imageLabel = levelData.displayName,
        label1 = "@ui_tracked_at",
        level1 = levelData.trackingUnlockLevel or -1,
        currentSkillLevel = skillData.currentLevel
      })
    end
    if isFishing then
      itemDataList[#itemDataList].level2 = nil
    end
  end
  self.SimpleGridItemList:OnListDataSet(itemDataList)
  self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
end
function TradeSkills_Gathering:SetBackClick(clickTable, clickFunc)
  self.clickTable = clickTable
  self.clickFunc = clickFunc
end
function TradeSkills_Gathering:BackClick()
  self.clickFunc(self.clickTable)
end
function TradeSkills_Gathering:SetScreenVisibleCallback(callbackFn, callbackTable)
  self.screenVisibleCallback = callbackFn
  self.screenVisibleCallbackTable = callbackTable
end
return TradeSkills_Gathering
