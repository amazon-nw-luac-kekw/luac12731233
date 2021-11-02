local PurchaseCelebrationPopup = {
  Properties = {
    StoreProductElement = {
      default = EntityId()
    },
    AcceptButton = {
      default = EntityId()
    },
    NextButton = {
      default = EntityId()
    },
    ApplyButton = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    QuantityText = {
      default = EntityId()
    },
    FlameSequence = {
      default = EntityId()
    },
    BurstSequence1 = {
      default = EntityId()
    },
    BurstSequence2 = {
      default = EntityId()
    },
    FakeGlow = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    RuneA = {
      default = EntityId()
    },
    RuneB = {
      default = EntityId()
    },
    RuneC = {
      default = EntityId()
    },
    StoreProductPopup = {
      default = EntityId()
    },
    OrderHistoryPopup = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PurchaseCelebrationPopup)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
function PurchaseCelebrationPopup:OnInit()
  BaseElement.OnInit(self)
  self.AcceptButton:SetCallback(self.OnCancel, self)
  self.AcceptButton:SetButtonStyle(self.AcceptButton.BUTTON_STYLE_CTA)
  self.AcceptButton:SetText("@ui_accept")
  self.NextButton:SetButtonStyle(self.NextButton.BUTTON_STYLE_CTA)
  self.NextButton:SetEnabled(false)
  self.NextButton:SetCallback(self.NextCelebration, self)
  self.NextButton:SetText("@ui_next")
  self.ApplyButton:SetButtonStyle(self.ApplyButton.BUTTON_STYLE_CTA)
  self.ApplyButton:SetEnabled(false)
  self.ApplyButton:SetCallback(self.OnApplyButton, self)
  self.ApplyButton:SetText("@ui_apply")
  SetTextStyle(self.Properties.TitleText, self.UIStyle.FONT_STYLE_STORE_CELEBRATION_HEADER)
  SetTextStyle(self.Properties.QuantityText, self.UIStyle.FONT_STYLE_STORE_CELEBRATION_QUANTITY)
  self.celebrations = {}
  self.currentCelebration = 0
  self:CacheAnimations()
end
function PurchaseCelebrationPopup:OnShutdown()
end
function PurchaseCelebrationPopup:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.burstIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadIn"
    })
    self.anim.burstOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 0,
      scaleX = 0,
      scaleY = 0,
      ease = "QuadOut"
    })
  end
end
function PurchaseCelebrationPopup:OnConfirm()
  self.onConfirmCallback(self.context, self.StoreProductElement.storeProductData)
end
function PurchaseCelebrationPopup:NextCelebration()
  self.currentCelebration = self.currentCelebration + 1
  if self.currentCelebration > #self.celebrations then
    self:OnCancel()
  end
  self.StoreProductElement:SetStoreProductData(self.celebrations[self.currentCelebration], "Celebration")
  self.StoreProductElement:StyleFeaturedElementByType(nil, "Celebration")
  if not self:IsEnabled() then
    self:SetIsEnabled(true)
  end
  self.currentCelebrationRewards = EntitlementsDataHandler:GetRewardsForOffer(self.celebrations[self.currentCelebration].offer)
  local enableApplyButton = false
  for _, reward in pairs(self.currentCelebrationRewards) do
    enableApplyButton = enableApplyButton or reward.rewardType == eRewardTypeItemSkin
  end
  self.ApplyButton:SetEnabled(enableApplyButton)
end
function PurchaseCelebrationPopup:OnApplyButton()
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  for _, reward in pairs(self.currentCelebrationRewards) do
    if reward.rewardType == eRewardTypeItemSkin then
      ItemSkinningRequestBus.Event.EnableItemSkin(playerEntityId, 0, reward.rewardId)
    end
  end
  self.ApplyButton:SetEnabled(false)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = #self.currentCelebrationRewards > 1 and "@ui_skins_applied" or "@ui_skin_applied"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function PurchaseCelebrationPopup:AddCelebration(storeProductData)
  table.insert(self.celebrations, storeProductData)
  if self.currentCelebration == 0 then
    self:NextCelebration()
  end
end
function PurchaseCelebrationPopup:IsEnabled()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function PurchaseCelebrationPopup:SetIsEnabled(isEnabled)
  if self:IsEnabled() == isEnabled then
    return
  end
  if isEnabled then
    self.ScriptedEntityTweener:Set(self.Properties.FakeGlow, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.RuneA, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.RuneB, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.RuneC, {opacity = 0})
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.FlameSequence, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.FlameSequence)
    UiElementBus.Event.SetIsEnabled(self.Properties.BurstSequence1, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BurstSequence1, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.BurstSequence1)
    UiElementBus.Event.SetIsEnabled(self.Properties.BurstSequence2, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BurstSequence2, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.BurstSequence2)
    self.ScriptedEntityTweener:PlayC(self.Properties.FakeGlow, 0.4, self.anim.burstIn, nil, function()
      self.ScriptedEntityTweener:Play(self.Properties.FakeGlow, 0.35, {opacity = 0, ease = "linear"})
    end)
    self.ScriptedEntityTweener:Play(self.Properties.BurstSequence1, 1.1, {
      scaleX = 1,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.BurstSequence1, false)
        UiElementBus.Event.SetIsEnabled(self.Properties.BurstSequence2, false)
      end
    })
    self.audioHelper:PlaySound(self.audioHelper.BoxOpeningItem_Rarity0)
    self.ScriptedEntityTweener:Play(self.Properties.StoreProductElement, 0.8, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.RuneA, 240, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.RuneB, 90, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    self.ScriptedEntityTweener:Play(self.Properties.RuneC, 180, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:PlayC(self.Properties.RuneB, 0.5, tweenerCommon.fadeInQuadOut, 0.5)
    self.ScriptedEntityTweener:PlayC(self.Properties.RuneC, 0.5, tweenerCommon.fadeInQuadOut, 0.6)
    self.ScriptedEntityTweener:PlayC(self.Properties.RuneA, 0.5, tweenerCommon.fadeInQuadOut, 0.7)
  else
    if self.context and type(self.onCancelCallback) == "function" then
      self.onCancelCallback(self.context)
    end
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.25, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.1,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        UiFlipbookAnimationBus.Event.Stop(self.Properties.FlameSequence)
        UiFlipbookAnimationBus.Event.Stop(self.Properties.BurstSequence1)
        UiFlipbookAnimationBus.Event.Stop(self.Properties.BurstSequence2)
        self.ScriptedEntityTweener:Stop(self.Properties.RuneA)
        self.ScriptedEntityTweener:Stop(self.Properties.RuneB)
        self.ScriptedEntityTweener:Stop(self.Properties.RuneC)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.2, {opacity = 1, y = 0}, {
      opacity = 0,
      y = -10,
      ease = "QuadOut"
    })
  end
end
function PurchaseCelebrationPopup:OnCancel()
  ClearTable(self.celebrations)
  self.currentCelebration = 0
  self:SetIsEnabled(false)
  self.StoreProductPopup:SetIsEnabled(false)
  local notificationData = NotificationData()
  notificationData.type = "Generic"
  notificationData.title = "@ui_notification_unlock_title"
  notificationData.hasChoice = true
  notificationData.contextId = self.entityId
  notificationData.acceptTextOverride = "@ui_view_item"
  notificationData.declineTextOverride = "@ui_dismiss"
  notificationData.callbackName = "ShowOrderHistory"
  notificationData.text = "@ui_notification_unlock_desc"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function PurchaseCelebrationPopup:ShowOrderHistory()
  if not LyShineManagerBus.Broadcast.IsInState(4283914359) then
    LyShineManagerBus.Broadcast.SetState(4283914359)
  end
  self.OrderHistoryPopup:Invoke()
end
return PurchaseCelebrationPopup
