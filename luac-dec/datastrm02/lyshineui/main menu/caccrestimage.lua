local CACCrestImage = {
  Properties = {
    Image = {
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
  spawnType = eRewardTypeGuildCrest,
  displayName = "",
  rewardKey = 0,
  imagePath = "",
  hasEntitlementImage = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACCrestImage)
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
function CACCrestImage:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.LockIcon, false)
  UiElementBus.Event.SetIsEnabled(self.EntitlementIcon, false)
  self.focusColor = self.UIStyle.COLOR_WHITE
  self.unfocusColor = self.UIStyle.COLOR_TAN
  self:SetSoundOnFocus(self.audioHelper.OnHover)
  self:SetSoundOnPress(self.audioHelper.Accept)
end
function CACCrestImage:SetRadioButtonGroup(groupEntityId)
  UiRadioButtonGroupBus.Event.AddRadioButton(groupEntityId, self.entityId)
end
function CACCrestImage:GetRadioButton()
  return self.entityId
end
function CACCrestImage:EnableButton(enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, enable)
end
function CACCrestImage:UpdateLockedIcon()
  local xPos = 0
  if self.availableProducts and 0 < #self.availableProducts then
    if self.grantInfo then
      local sourceType = self.grantInfo.grantor.sourceType
      xPos = 2
      local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      if sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_TWITCH then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PRIME then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PREORDER then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        xPos = 8
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_STORE then
        iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      else
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        xPos = 8
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.LockIcon, iconTexture)
    end
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.LockIcon, "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds")
    xPos = 8
  end
  UiTransformBus.Event.SetLocalPositionX(self.Properties.LockIcon, xPos)
end
function CACCrestImage:SetIsLocked(locked)
  self.isLocked = locked
  UiElementBus.Event.SetIsEnabled(self.LockIcon, locked)
  UiElementBus.Event.SetIsEnabled(self.Properties.TooltipButton, locked)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, not locked)
  UiElementBus.Event.SetIsEnabled(self.EntitlementIcon, self.hasEntitlementImage and not locked)
  self.ScriptedEntityTweener:Set(self.Image, {
    opacity = locked and 0.5 or 1
  })
  self:UpdateLockedIcon()
end
function CACCrestImage:SetEntitlementImageSource(pathname)
  if pathname then
    UiImageBus.Event.SetSpritePathname(self.EntitlementIcon, pathname)
  end
  self.hasEntitlementImage = pathname ~= nil
  UiElementBus.Event.SetIsEnabled(self.EntitlementIcon, self.hasEntitlementImage)
end
function CACCrestImage:SetTooltipCallbacks(context, hoverStartCb, hoverEndCb, clickCb)
  self.tooltipCallbacks = {
    context = context,
    hoverStartCb = hoverStartCb,
    hoverEndCb = hoverEndCb,
    clickCb = clickCb
  }
end
function CACCrestImage:SetDisplayName(displayName)
  self.displayName = displayName
end
function CACCrestImage:SetColor(color)
  self.color = color
end
function CACCrestImage:GetColor()
  return self.color
end
function CACCrestImage:SetImageScale(value)
  if self.Image ~= nil then
    self.ScriptedEntityTweener:Set(self.Image, {scaleX = value, scaleY = value})
  end
end
function CACCrestImage:SetImagePath(pathname)
  self.imagePath = pathname
end
function CACCrestImage:GetImagePath()
  return self.imagePath
end
function CACCrestImage:SetImage(pathname)
  if self.Properties.Image ~= nil then
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, pathname)
  end
end
function CACCrestImage:GetImage()
  if self.Properties.Image ~= nil then
    return UiImageBus.Event.GetSpritePathname(self.Properties.Image)
  end
  return ""
end
function CACCrestImage:SetSoundOnFocus(value)
  self.soundOnFocus = value
end
function CACCrestImage:SetSoundOnPress(value)
  self.soundOnPress = value
end
function CACCrestImage:SetAvailableProducts(availableProducts, grantInfo)
  self.availableProducts = availableProducts
  self.grantInfo = grantInfo
  self:UpdateLockedIcon()
end
function CACCrestImage:OnTooltipButtonClicked()
  if self.tooltipCallbacks then
    self.tooltipCallbacks.clickCb(self.tooltipCallbacks.context, self)
  end
  self:OnSelected()
end
function CACCrestImage:OnTooltipButtonHoverStart()
  if self.tooltipCallbacks then
    self.tooltipCallbacks.hoverStartCb(self.tooltipCallbacks.context, self)
  end
  self:OnFocus()
end
function CACCrestImage:OnTooltipButtonHoverEnd()
  if self.tooltipCallbacks then
    self.tooltipCallbacks.hoverEndCb(self.tooltipCallbacks.context, self)
  end
  self:OnUnfocus()
end
function CACCrestImage:OnFocus()
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
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.soundOnFocus)
end
function CACCrestImage:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.entityId)
  if isSelectedState then
    self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8})
  else
    self:OnUnselected()
  end
end
function CACCrestImage:OnSelected(suppressSound)
  self.ScriptedEntityTweener:Play(self.Image, 0.3, {
    imgColor = self.focusColor,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8})
  if suppressSound ~= true then
    self.audioHelper:PlaySound(self.soundOnPress)
  end
end
function CACCrestImage:OnUnselected()
  self.ScriptedEntityTweener:Play(self.Image, 0.3, {
    imgColor = self.unfocusColor,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0, ease = "QuadIn"})
end
function CACCrestImage:SetEntitlementData(entitlementType, id)
  self.spawnType = entitlementType
  self.rewardKey = id
end
function CACCrestImage:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return CACCrestImage
