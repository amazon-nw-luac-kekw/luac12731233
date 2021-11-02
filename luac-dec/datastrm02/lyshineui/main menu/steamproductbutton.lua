local SteamProductButton = {
  Properties = {
    Spinner = {
      default = EntityId()
    },
    Content = {
      default = EntityId()
    },
    ProductOverlay = {
      default = EntityId()
    },
    Sticker = {
      default = EntityId()
    },
    StickerText = {
      default = EntityId()
    },
    ProductName = {
      default = EntityId()
    },
    ProductDescription = {
      default = EntityId()
    },
    InitialPrice = {
      default = EntityId()
    },
    FinalPrice = {
      default = EntityId()
    },
    FocusImage = {
      default = EntityId()
    }
  },
  color = nil,
  focusColor = nil,
  unfocusColor = nil,
  soundOnFocus = nil,
  soundOnPress = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SteamProductButton)
function SteamProductButton:OnInit()
  BaseElement.OnInit(self)
  self.focusColor = self.UIStyle.COLOR_WHITE
  self.unfocusColor = self.UIStyle.COLOR_TAN
  self:SetSoundOnFocus(self.audioHelper.FrontEnd_OnSelectCharacterHover)
  self:SetSoundOnPress(self.audioHelper.FrontEnd_OnCreateCharacterBeginPress)
end
function SteamProductButton:EnableButton(enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Content, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, enable)
end
function SteamProductButton:SetCallback(context, clickCb)
  self.callbacks = {context = context, clickCb = clickCb}
end
function SteamProductButton:SetSpinnerShowing(isShowing)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, not isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, false)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
    UiElementBus.Event.SetIsEnabled(self.Properties.Content, true)
  end
end
function SteamProductButton:SetButtonImageScale(value)
  if self.Properties.ProductOverlay ~= nil then
    self.ScriptedEntityTweener:Set(self.Properties.ProductOverlay, {scaleX = value, scaleY = value})
  end
end
function SteamProductButton:SetButtonImage(pathname)
  if self.Properties.ProductOverlay ~= nil and string.len(pathname) > 0 then
    UiImageBus.Event.SetSpritePathname(self.Properties.ProductOverlay, pathname)
    UiElementBus.Event.SetIsEnabled(self.Properties.ProductOverlay, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ProductOverlay, false)
  end
end
function SteamProductButton:GetButtonImage()
  if self.Properties.ProductOverlay ~= nil then
    return UiImageBus.Event.GetSpritePathname(self.Properties.ProductOverlay)
  end
  return ""
end
function SteamProductButton:SetEntityText(entityId, text, flags)
  if text and string.len(text) > 0 then
    UiTextBus.Event.SetTextWithFlags(entityId, text, flags or eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(entityId, true)
  else
    UiElementBus.Event.SetIsEnabled(entityId, false)
  end
end
function SteamProductButton:SetSticker(stickerImage, stickerText)
  if stickerImage and string.len(stickerImage) > 0 then
    UiImageBus.Event.SetSpritePathname(self.Properties.Sticker, stickerImage)
    UiElementBus.Event.SetIsEnabled(self.Properties.Sticker, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Sticker, false)
  end
  self:SetEntityText(self.Properties.StickerText, stickerText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.Sticker, false)
end
function SteamProductButton:SetPrices(finalPrice, initialPrice)
  self:SetEntityText(self.Properties.FinalPrice, finalPrice, eUiTextSet_SetLocalized)
  self:SetEntityText(self.Properties.InitialPrice, initialPrice, eUiTextSet_SetLocalized)
end
function SteamProductButton:SetName(name)
  self:SetEntityText(self.Properties.ProductName, name, eUiTextSet_SetLocalized)
end
function SteamProductButton:SetDescription(description)
  self:SetEntityText(self.Properties.ProductDescription, description, eUiTextSet_SetLocalized)
end
function SteamProductButton:SetExpires(expires)
  if not expires or expires > WallClockTimePoint:Now() then
  end
end
function SteamProductButton:SetSoundOnFocus(value)
  self.soundOnFocus = value
end
function SteamProductButton:SetSoundOnPress(value)
  self.soundOnPress = value
end
function SteamProductButton:OnFocus()
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.FocusImage, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
    self.timeline:Add(self.Properties.FocusImage, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.FocusImage, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.FocusImage, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.FocusImage, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.soundOnFocus)
  if self.callbacks and self.callbacks.focusCb then
    self.callbacks.focusCb(self.callbacks.context, self)
  end
end
function SteamProductButton:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.FocusImage, 0.15, {opacity = 0})
  if self.callbacks and self.callbacks.unfocusCb then
    self.callbacks.unfocusCb(self.callbacks.context, self)
  end
end
function SteamProductButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function SteamProductButton:OnClick()
  if self.callbacks and self.callbacks.clickCb then
    self.callbacks.clickCb(self.callbacks.context, self)
  end
end
return SteamProductButton
