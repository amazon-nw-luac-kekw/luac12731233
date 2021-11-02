local CACCrestColor = {
  Properties = {
    ColorImage = {
      default = EntityId()
    },
    LockIcon = {
      default = EntityId()
    },
    EntitlementIcon = {
      default = EntityId()
    },
    TooltipButton = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    }
  },
  color = nil,
  focusColor = nil,
  unfocusColor = nil,
  soundOnFocus = nil,
  soundOnPress = nil,
  spawnType = 0,
  rewardKey = 0,
  lockDescription = "",
  displayName = "",
  hasEntitlementImage = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACCrestColor)
function CACCrestColor:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.LockIcon, false)
  UiElementBus.Event.SetIsEnabled(self.EntitlementIcon, false)
  self.focusColor = self.UIStyle.COLOR_WHITE
  self.unfocusColor = self.UIStyle.COLOR_TAN_DARKER
  self:SetSoundOnFocus(self.audioHelper.OnHover)
  self:SetSoundOnPress(self.audioHelper.Accept)
end
function CACCrestColor:SetRadioButtonGroup(groupEntityId)
  UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
end
function CACCrestColor:GetRadioButton()
  return self.entityId
end
function CACCrestColor:EnableButton(enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, enable)
end
function CACCrestColor:UpdateLockedIcon()
  if self.availableProducts and #self.availableProducts > 0 then
    if self.grantInfo then
      local sourceType = self.grantInfo.grantor.sourceType
      local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      if sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_TWITCH then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PRIME then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PREORDER then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_STORE then
        iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      else
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.LockIcon, iconTexture)
    end
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.LockIcon, "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds")
  end
end
function CACCrestColor:SetIsLocked(locked)
  self.isLocked = locked
  UiElementBus.Event.SetIsEnabled(self.Properties.LockIcon, locked)
  UiElementBus.Event.SetIsEnabled(self.Properties.TooltipButton, locked)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, not locked)
  UiElementBus.Event.SetIsEnabled(self.EntitlementIcon, self.hasEntitlementImage and not locked)
  self:UpdateLockedIcon()
end
function CACCrestColor:SetEntitlementImageSource(pathname)
  if pathname then
    UiImageBus.Event.SetSpritePathname(self.EntitlementIcon, pathname)
  end
  self.hasEntitlementImage = pathname ~= nil
  UiElementBus.Event.SetIsEnabled(self.EntitlementIcon, self.hasEntitlementImage)
end
function CACCrestColor:SetTooltipCallbacks(context, hoverStartCb, hoverEndCb, clickCb)
  self.tooltipCallbacks = {
    context = context,
    hoverStartCb = hoverStartCb,
    hoverEndCb = hoverEndCb,
    clickCb = clickCb
  }
end
function CACCrestColor:SetDisplayName(displayName)
  self.displayName = displayName
end
function CACCrestColor:SetColor(color)
  self.color = color
  UiImageBus.Event.SetColor(self.ColorImage, color)
end
function CACCrestColor:GetColor()
  return self.color
end
function CACCrestColor:SetSoundOnFocus(value)
  self.soundOnFocus = value
end
function CACCrestColor:SetSoundOnPress(value)
  self.soundOnPress = value
end
function CACCrestColor:OnTooltipButtonClicked()
  if self.tooltipCallbacks then
    self.tooltipCallbacks.clickCb(self.tooltipCallbacks.context, self)
  end
  self:OnSelected()
end
function CACCrestColor:OnTooltipButtonHoverStart()
  if self.tooltipCallbacks then
    self.tooltipCallbacks.hoverStartCb(self.tooltipCallbacks.context, self)
  end
  self:OnFocus()
end
function CACCrestColor:OnTooltipButtonHoverEnd()
  if self.tooltipCallbacks then
    self.tooltipCallbacks.hoverEndCb(self.tooltipCallbacks.context, self)
  end
  self:OnUnfocus()
end
function CACCrestColor:SetAvailableProducts(availableProducts, grantInfo)
  self.availableProducts = availableProducts
  self.grantInfo = grantInfo
  self:UpdateLockedIcon()
end
function CACCrestColor:OnFocus()
  local animDuration = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration, {
    imgColor = self.focusColor,
    ease = "QuadOut"
  })
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animDuration,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.soundOnFocus)
end
function CACCrestColor:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.entityId)
  if isSelectedState then
    self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8})
  else
    self:OnUnselected()
  end
end
function CACCrestColor:OnSelected(suppressSound)
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.3, {
    imgColor = self.focusColor,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8, ease = "QuadIn"})
  if suppressSound ~= true then
    self.audioHelper:PlaySound(self.soundOnPress)
  end
end
function CACCrestColor:OnUnselected()
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.3, {
    imgColor = self.unfocusColor,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 1, ease = "QuadOut"})
end
function CACCrestColor:SetEntitlementData(entitlementType, id)
  self.spawnType = entitlementType
  self.rewardKey = id
end
function CACCrestColor:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return CACCrestColor
