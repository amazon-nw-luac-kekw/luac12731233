local MetaAchievementsSummaryScreen = {
  Properties = {
    Content = {
      default = EntityId()
    },
    TotalTitle = {
      default = EntityId()
    },
    TotalPercentInteger = {
      default = EntityId()
    },
    TotalPercentTenth = {
      default = EntityId()
    },
    TotalFraction = {
      default = EntityId()
    },
    TotalBar = {
      default = EntityId()
    },
    TotalProgressBar = {
      default = EntityId()
    },
    RecentlyTitle = {
      default = EntityId()
    },
    RecentlyItem1 = {
      default = EntityId()
    },
    RecentlyItem2 = {
      default = EntityId()
    },
    RecentlyNoAchievementsText = {
      default = EntityId()
    },
    NearlyTitle = {
      default = EntityId()
    },
    NearlyItem1 = {
      default = EntityId()
    },
    NearlyItem2 = {
      default = EntityId()
    },
    NearlyNoAchievementsText = {
      default = EntityId()
    },
    ProgressOverviewTitle = {
      default = EntityId()
    },
    ProgressOverviewList = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MetaAchievementsSummaryScreen)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function MetaAchievementsSummaryScreen:OnInit()
  BaseElement.OnInit(self)
  self.recentlyCompletedAchievementIds = {}
  self.nearlyCompletedAchievementsIds = {}
  self.completedAchievementData = {}
  local headers = {
    TotalTitle = "@ui_meta_achievements_summary_total_completion",
    RecentlyTitle = "@ui_meta_achievements_summary_recently_completed",
    NearlyTitle = "@ui_meta_achievements_summary_nearly_completed",
    ProgressOverviewTitle = "@ui_meta_achievements_summary_progress_overview"
  }
  for key, val in pairs(headers) do
    self[key]:ShowBlueBackground(true)
    self[key]:SetText(val, false)
    self[key]:SetTextVAlignment(self.UIStyle.TEXT_VALIGN_CENTER)
    self[key]:SetTextStyle(self.UIStyle.FONT_STYLE_ACHIEVEMENTS_SUMMARY_HEADING)
  end
  SetTextStyle(self.Properties.TotalPercentInteger, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_TOTAL_PERCENT)
  SetTextStyle(self.Properties.TotalPercentTenth, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_TOTAL_PERCENT)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RecentlyNoAchievementsText, "@ui_meta_achievements_no_completed", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.NearlyNoAchievementsText, "@ui_meta_achievements_no_nearly_completed", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.RecentlyNoAchievementsText, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_BODYTEXT)
  SetTextStyle(self.Properties.NearlyNoAchievementsText, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_BODYTEXT)
  self.TotalProgressBar:EnableTitle(false)
  self.TotalProgressBar:ProgressCountToTopLeftPosition(true)
end
function MetaAchievementsSummaryScreen:SetScreenVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.3, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  end
end
function MetaAchievementsSummaryScreen:TransitionIn()
  self.SetScreenVisible(true)
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
end
function MetaAchievementsSummaryScreen:TransitionOut()
  self.SetScreenVisible(false)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
function MetaAchievementsSummaryScreen:SetOnClickedCallback(onClickedElementCallback, onClickedCallbackTable)
  self.onClickedElementCallback = onClickedElementCallback
  self.onClickedCallbackTable = onClickedCallbackTable
end
function MetaAchievementsSummaryScreen:UpdateSummaryData(recentlyCompletedMetaAchievementData, nearlyCompletedMetaAchievementData, categoryProgressData)
  local overallCompletedCount = 0
  local overallTotalCount = 0
  for i = 1, #categoryProgressData do
    local currentCategoryData = categoryProgressData[i]
    overallCompletedCount = overallCompletedCount + currentCategoryData.completedCount
    overallTotalCount = overallTotalCount + currentCategoryData.totalCount
  end
  local completedOverTotal = overallTotalCount ~= 0 and overallCompletedCount / overallTotalCount or 0
  local completedOverTotalPercentage = completedOverTotal * 100
  local totalCompletedData = {completedCount = overallCompletedCount, totalCount = overallTotalCount}
  UiTextBus.Event.SetText(self.Properties.TotalPercentInteger, tostring(math.floor(completedOverTotalPercentage)))
  UiTextBus.Event.SetText(self.Properties.TotalPercentTenth, string.format(".%d%%", completedOverTotalPercentage * 10 % 10))
  local getTotalPercentIntegerWidth = UiTextBus.Event.GetTextWidth(self.Properties.TotalPercentInteger)
  local getTotalPercentTenthWidth = UiTextBus.Event.GetTextWidth(self.Properties.TotalPercentTenth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TotalPercentInteger, getTotalPercentIntegerWidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TotalPercentTenth, getTotalPercentTenthWidth)
  local totalFraction = GetLocalizedReplacementText("@ui_meta_achievements_summary_fraction", {
    numeratorColor = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE),
    numerator = tostring(overallCompletedCount),
    denominatorColor = ColorRgbaToHexString(self.UIStyle.COLOR_GRAY_50),
    denominator = tostring(overallTotalCount)
  })
  UiTextBus.Event.SetText(self.Properties.TotalFraction, totalFraction)
  self.TotalProgressBar:SetData(totalCompletedData, nil, nil)
  local numRecentlyCompleted = #recentlyCompletedMetaAchievementData
  UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyNoAchievementsText, numRecentlyCompleted == 0)
  if 1 <= numRecentlyCompleted then
    UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyItem1, true)
    self.RecentlyItem1:SetGridItemData(recentlyCompletedMetaAchievementData[1])
    self.firstSlotRecentlyCompletedMetaAchievementData = recentlyCompletedMetaAchievementData[1]
    local hasUniqueSecondMetaAchievement = 2 <= numRecentlyCompleted and recentlyCompletedMetaAchievementData[2].itemData.id ~= self.firstSlotRecentlyCompletedMetaAchievementData.itemData.id
    if hasUniqueSecondMetaAchievement then
      UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyItem2, true)
      self.RecentlyItem2:SetGridItemData(recentlyCompletedMetaAchievementData[2])
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyItem2, false)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyItem1, false)
  end
  local numNearlyCompleted = #nearlyCompletedMetaAchievementData
  UiElementBus.Event.SetIsEnabled(self.Properties.NearlyNoAchievementsText, numNearlyCompleted == 0)
  if 1 <= numNearlyCompleted then
    UiElementBus.Event.SetIsEnabled(self.Properties.NearlyItem1, true)
    self.NearlyItem1:SetGridItemData(nearlyCompletedMetaAchievementData[1])
    if 2 <= numNearlyCompleted then
      UiElementBus.Event.SetIsEnabled(self.Properties.NearlyItem2, true)
      self.NearlyItem2:SetGridItemData(nearlyCompletedMetaAchievementData[2])
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.NearlyItem2, false)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NearlyItem1, false)
  end
  local cellHeight = UiLayoutGridBus.Event.GetCellSize(self.ProgressOverviewList).y
  local numRows = math.ceil(#categoryProgressData / 2)
  UiLayoutCellBus.Event.SetTargetHeight(self.ProgressOverviewList, numRows * cellHeight)
  UiDynamicLayoutBus.Event.SetNumChildElements(self.ProgressOverviewList, #categoryProgressData)
  local childElements = UiElementBus.Event.GetChildren(self.ProgressOverviewList)
  for i = 1, #childElements do
    local id = childElements[i]
    local entityTable = self.registrar:GetEntityTable(id)
    entityTable:SetData(categoryProgressData[i], self.onClickedElementCallback, self.onClickedCallbackTable)
  end
end
function MetaAchievementsSummaryScreen:AddRecentlyCompletedMetaAchievement(recentlyCompletedMetaAchievementData)
  if recentlyCompletedMetaAchievementData == nil then
    return
  end
  local hasExistingItemData = self.firstSlotRecentlyCompletedMetaAchievementData ~= nil
  if hasExistingItemData then
    if recentlyCompletedMetaAchievementData.itemData.id == self.firstSlotRecentlyCompletedMetaAchievementData.itemData.id then
      return
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyItem2, true)
    self.RecentlyItem2:SetGridItemData(self.firstSlotRecentlyCompletedMetaAchievementData)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyNoAchievementsText, false)
  end
  self.firstSlotRecentlyCompletedMetaAchievementData = recentlyCompletedMetaAchievementData
  UiElementBus.Event.SetIsEnabled(self.Properties.RecentlyItem1, true)
  self.RecentlyItem1:SetGridItemData(recentlyCompletedMetaAchievementData)
end
return MetaAchievementsSummaryScreen
