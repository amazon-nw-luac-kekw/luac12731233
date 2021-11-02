local MetaAchievementRewardScreen = {
  Properties = {
    NumRewardsToClaimText = {
      default = EntityId()
    },
    ClaimAllButton = {
      default = EntityId()
    },
    ScrollBox = {
      default = EntityId()
    },
    RewardsContent = {
      default = EntityId()
    },
    LeftArrowButton = {
      default = EntityId()
    },
    RightArrowButton = {
      default = EntityId()
    },
    RewardItem = {
      default = EntityId()
    }
  },
  allItemsWidth = 0,
  count = 0,
  itemsPerPage = 4
}
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MetaAchievementRewardScreen)
function MetaAchievementRewardScreen:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.LeftArrowButton:SetCallback(self.OnLeftArrowButtonClicked, self)
  self.RightArrowButton:SetCallback(self.OnRightArrowButtonClicked, self)
  self.ClaimAllButton:SetCallback(self.OnClaimAllButtonClicked, self)
  self.ClaimAllButton:SetText("@ui_meta_achievements_claim_all")
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ScrollBox)
  self:BusConnect(UiScrollBoxNotificationBus, self.Properties.ScrollBox)
  self.originalScrollBoxWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ScrollBox)
  self.itemWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RewardItem)
  SetTextStyle(self.Properties.NumRewardsToClaimText, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_TO_CLAIM)
end
function MetaAchievementRewardScreen:SetOnClaimedRewardsCallback(onClaimedRewardsCallback, onClaimedRewardsTable)
  self.onClaimedRewardsCallback = onClaimedRewardsCallback
  self.onClaimedRewardsCallbackTable = onClaimedRewardsTable
end
function MetaAchievementRewardScreen:SetScreenVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.3, tweenerCommon.fadeInQuadOut)
  end
end
function MetaAchievementRewardScreen:TransitionIn()
  self:SetScreenVisible(true)
end
function MetaAchievementRewardScreen:TransitionOut()
  self:SetScreenVisible(false)
end
function MetaAchievementRewardScreen:UpdateContent(pendingData)
  local numRewardsToClaimText = ""
  self.count = self.dataLayer:GetDataFromNode("MetaAchievements.UnclaimedRewardCount")
  if self.count == 1 then
    numRewardsToClaimText = GetLocalizedReplacementText("@ui_meta_achievements_rewards_available_desc_one", {
      color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW)
    })
  else
    numRewardsToClaimText = GetLocalizedReplacementText("@ui_meta_achievements_rewards_available_desc_mult", {
      color = ColorRgbaToHexString(self.UIStyle.COLOR_YELLOW),
      number = self.count
    })
  end
  UiTextBus.Event.SetText(self.Properties.NumRewardsToClaimText, numRewardsToClaimText)
  self.pendingData = pendingData
  self.allItemsWidth = self.count * self.itemWidth
  if self.allItemsWidth < self.originalScrollBoxWidth then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ScrollBox, self.allItemsWidth)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.RewardsContent, self.allItemsWidth)
    UiElementBus.Event.SetIsEnabled(self.Properties.RightArrowButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.LeftArrowButton, false)
  else
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ScrollBox, self.originalScrollBoxWidth)
    self:RefreshArrowButtons()
    UiScrollBoxBus.Event.SetScrollOffsetX(self.Properties.ScrollBox, 0)
  end
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.RewardsContent, self.allItemsWidth)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
end
function MetaAchievementRewardScreen:RefreshArrowButtons()
  local currentScrollbarOffset = UiScrollBoxBus.Event.GetScrollOffset(self.Properties.ScrollBox).x
  self.maxOffsetValue = (self.count - self.originalScrollBoxWidth / self.itemWidth) * self.itemWidth * -1
  self.getScrollOffset = math.max(currentScrollbarOffset, self.maxOffsetValue)
  UiElementBus.Event.SetIsEnabled(self.Properties.LeftArrowButton, self.getScrollOffset < 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.RightArrowButton, self.getScrollOffset > self.maxOffsetValue)
end
function MetaAchievementRewardScreen:OnRightArrowButtonClicked()
  local amountToScroll = self.getScrollOffset - self.itemWidth * self.itemsPerPage
  UiScrollBoxBus.Event.SetScrollOffsetX(self.Properties.ScrollBox, amountToScroll)
  self:RefreshArrowButtons()
end
function MetaAchievementRewardScreen:OnLeftArrowButtonClicked()
  local amountToScroll = self.getScrollOffset + self.itemWidth * self.itemsPerPage
  UiScrollBoxBus.Event.SetScrollOffsetX(self.Properties.ScrollBox, amountToScroll)
  self:RefreshArrowButtons()
end
function MetaAchievementRewardScreen:OnScrollOffsetChanged()
  self:RefreshArrowButtons()
end
function MetaAchievementRewardScreen:GetNumElements()
  if self.pendingData then
    return self.count
  else
    return 0
  end
end
function MetaAchievementRewardScreen:OnElementBecomingVisible(rootEntity, index)
  if not self.pendingData then
    return
  end
  local data
  local titleId = 0
  local prevIdsCount = 0
  for i = 1, #self.pendingData do
    local currentMetaAchievementData = self.pendingData[i]
    if currentMetaAchievementData ~= nil then
      local titleIds = JavMetaAchievementRequestBus.Broadcast.GetTitlesIdsForMetaAchievement(currentMetaAchievementData.itemData.id)
      local titleIdsCount = #titleIds
      if prevIdsCount + titleIdsCount >= index + 1 then
        data = currentMetaAchievementData
        titleId = titleIds[index + 1 - prevIdsCount]
        break
      end
      prevIdsCount = prevIdsCount + titleIdsCount
    end
  end
  if titleId ~= 0 and data ~= nil then
    local enityTable = self.registrar:GetEntityTable(rootEntity)
    enityTable:SetData(data, titleId)
  end
end
function MetaAchievementRewardScreen:OnClaimAllButtonClicked()
  if self.onClaimedRewardsCallbackTable ~= nil and type(self.onClaimedRewardsCallback) == "function" then
    self.onClaimedRewardsCallback(self.onClaimedRewardsCallbackTable)
  end
  self:TransitionOut()
end
return MetaAchievementRewardScreen
