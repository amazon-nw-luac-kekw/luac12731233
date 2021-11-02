local TerritoryBonusPopup = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    RewardsContainer = {
      default = EntityId()
    },
    RewardCardPrototype = {
      default = EntityId()
    },
    TerritoryName = {
      default = EntityId()
    },
    TokenCount = {
      default = EntityId()
    },
    InputBlocker = {
      default = EntityId()
    }
  },
  numRewards = 4,
  shouldUpdateRewards = true,
  shouldUpdateText = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TerritoryBonusPopup)
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function TerritoryBonusPopup:OnInit()
  BaseScreen.OnInit(self)
  self.clonedRewards = {}
  for i = 1, self.numRewards do
    local rewardSlice = CloneUiElement(self.canvasId, self.registrar, self.Properties.RewardCardPrototype, self.Properties.RewardsContainer, true)
    table.insert(self.clonedRewards, rewardSlice)
  end
  self.ScreenHeader:SetText("@ui_redeem_a_reward.")
  self.ScreenHeader:SetHintCallback(self.OnClose, self)
  DynamicBus.TerritoryBonusPopupBus.Connect(self.entityId, self)
  SetTextStyle(self.Properties.TerritoryName, self.UIStyle.FONT_STYLE_SCREEN_HEADER_LABEL)
  SetTextStyle(self.Properties.TokenCount, self.UIStyle.FONT_STYLE_SCREEN_HEADER_DATA)
end
function TerritoryBonusPopup:SetMapCallbacks(showScrim, hideScrim, redeemAnimation, table)
  self.showScreenScrimCallback = showScrim
  self.hideScreenScrimCallback = hideScrim
  self.redeemAnimationCallback = redeemAnimation
  self.mapTable = table
end
function TerritoryBonusPopup:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.TerritoryBonusPopupBus.Disconnect(self.entityId, self)
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  for _, element in ipairs(self.clonedRewards) do
    UiElementBus.Event.DestroyElement(element.entityId)
  end
end
function TerritoryBonusPopup:GetTerritoryId()
  return self.territoryId
end
function TerritoryBonusPopup:OpenTerritoryBonusPopup(territoryId)
  self.territoryId = territoryId
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
end
function TerritoryBonusPopup:IsTerritoryBonusPopupVisible()
  return UiCanvasBus.Event.GetEnabled(self.canvasId)
end
function TerritoryBonusPopup:OnEscapeKeyPressed()
  self:OnClose()
end
function TerritoryBonusPopup:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, true)
  if self.shouldUpdateRewards then
    self:UpdateAvailableRewards()
  end
  self.shouldUpdateRewards = false
  self.shouldUpdateText = false
  timingUtils:Delay(0.8, self, function()
    self.shouldUpdateRewards = true
    self.shouldUpdateText = true
  end)
  self.showScreenScrimCallback(self.mapTable, self)
  self.ScriptedEntityTweener:Play(self.entityId, 0.4, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryStandingOpen)
end
function TerritoryBonusPopup:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function TerritoryBonusPopup:UpdateAvailableRewards()
  self.rewardsData = TerritoryDataHandler:GetRedeemableTerritoryRewards(self.territoryId)
  local standing = TerritoryDataHandler:GetTerritoryStanding(self.territoryId)
  local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(self.territoryId)
  local text = GetLocalizedReplacementText("@ui_territory_tokens", {
    territory = posData.territoryName
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.TokenCount, tostring(standing.tokens), eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryName, text, eUiTextSet_SetAsIs)
  self.lastSlide = standing.tokens == 1
  local spacing = 30
  local contentWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RewardsContainer)
  local contentHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.RewardsContainer)
  local rewardWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.RewardCardPrototype)
  local rewardsCount = #self.rewardsData
  local rewardsWidth = rewardWidth * rewardsCount + (rewardsCount - 1) * spacing
  local firstPos = contentWidth / 2 - rewardsWidth / 2 + rewardWidth / 2
  for i, rewardElement in ipairs(self.clonedRewards) do
    self.ScriptedEntityTweener:Stop(rewardElement.entityId)
    UiInteractableBus.Event.SetIsHandlingEvents(rewardElement.entityId, false)
    local rewardData = self.rewardsData[i]
    if rewardData then
      UiElementBus.Event.SetIsEnabled(rewardElement.entityId, true)
      rewardElement:SetIsSelected(false)
      rewardElement:SetBonusRewardData(rewardData, self, self.OnRewardSelected, posData.territoryName)
      UiFaderBus.Event.SetFadeValue(rewardElement.entityId, 1)
      UiTransformBus.Event.SetPivot(rewardElement.entityId, Vector2(0.5, 0.5))
      UiTransformBus.Event.SetScale(rewardElement.entityId, Vector2(1, 1))
      UiTransform2dBus.Event.SetAnchorsScript(rewardElement.entityId, UiAnchors(0, 0, 0, 0))
      UiTransformBus.Event.SetLocalPosition(rewardElement.entityId, Vector2(contentWidth * 2, contentHeight / 2))
      self.ScriptedEntityTweener:Play(rewardElement.entityId, 0.4, {
        delay = (i - 1) * 0.1,
        x = firstPos + (i - 1) * (rewardWidth + spacing),
        ease = "QuadOut",
        onComplete = function()
          UiInteractableBus.Event.SetIsHandlingEvents(rewardElement.entityId, true)
        end
      })
    else
      UiElementBus.Event.SetIsEnabled(rewardElement.entityId, false)
    end
  end
end
function TerritoryBonusPopup:OnRewardSelected(selectedRewardData)
  if not selectedRewardData.enabled then
    return
  end
  if self.lastSlide then
    self.hideScreenScrimCallback(self.mapTable, self)
    UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, false)
  end
  for i, rewardData in ipairs(self.rewardsData) do
    self.clonedRewards[i]:SetIsSelected(true)
    self.ScriptedEntityTweener:Stop(self.clonedRewards[i].entityId)
    UiInteractableBus.Event.SetIsHandlingEvents(self.clonedRewards[i].entityId, false)
    if rewardData.rewardId == selectedRewardData.rewardId then
      self.clonedRewards[i]:PlayRedeemEffect()
      self.ScriptedEntityTweener:Play(self.clonedRewards[i].entityId, 0.25, {
        opacity = 1,
        ease = "QuadOut",
        onComplete = function()
          TerritoryDataHandler:RedeemTerritoryReward(self.territoryId, selectedRewardData.rewardId, self, self.OnRedeemResult)
        end
      })
      self.selectedIdx = i
    else
      self.ScriptedEntityTweener:Play(self.clonedRewards[i].entityId, 0.25, {opacity = 0, ease = "QuadOut"})
    end
  end
end
function TerritoryBonusPopup:OnRedeemResult(success)
  if success then
    self.clonedRewards[self.selectedIdx]:SetIsSelected(true)
    self.ScriptedEntityTweener:Play(self.clonedRewards[self.selectedIdx].entityId, 0.4, {opacity = 1}, {
      opacity = 0,
      delay = 0.6,
      ease = "QuadOut"
    })
    timingUtils:Delay(0.35, self, function()
      self.redeemAnimationCallback(self.mapTable, self.shouldUpdateText, self)
      if self.lastSlide then
        self:OnClose()
      elseif self.shouldUpdateRewards then
        timingUtils:Delay(0.3, self, function()
          self:UpdateAvailableRewards()
          DynamicBus.Map.Broadcast.UpdateTerritoryInfoContainerBonuses()
          DynamicBus.Map.Broadcast.UpdateUnspentTokensCount()
        end)
      end
    end)
  end
end
function TerritoryBonusPopup:OnClose()
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.Screen_TerritoryStandingClose)
  self.hideScreenScrimCallback(self.mapTable, self)
  DynamicBus.Map.Broadcast.UpdateTerritoryInfoContainerBonuses()
  DynamicBus.Map.Broadcast.UpdateUnspentTokensCount()
end
return TerritoryBonusPopup
