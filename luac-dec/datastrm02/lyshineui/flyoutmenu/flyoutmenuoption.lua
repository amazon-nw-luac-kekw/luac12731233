local FlyoutMenuOption = {
  Properties = {
    ButtonText = {
      default = EntityId()
    },
    ButtonBg = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    }
  },
  isClickable = true,
  socialRequestCount = 0,
  socialResponseCount = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutMenuOption)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function FlyoutMenuOption:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  if type(self.Hint) == "table" then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Hint, false)
  end
end
function FlyoutMenuOption:OnFocus()
  self.hasFocus = true
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.isClickable or not self.isHandlingEvents then
    return
  end
  local animDuration = 0.18
  if self.isCircularMode then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
      imgColor = self.UIStyle.COLOR_WHITE,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {opacity = 0.3, ease = "QuadOut"})
  end
end
function FlyoutMenuOption:ClearFocus()
  local animDuration = 0.18
  if self.isCircularMode then
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {
      imgColor = self.UIStyle.COLOR_TAN,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonText, animDuration, {opacity = 0.6, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ButtonBg, animDuration, {opacity = 0.1, ease = "QuadOut"})
  end
end
function FlyoutMenuOption:OnUnFocus()
  self.hasFocus = false
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if not self.isClickable or not self.isHandlingEvents then
    return
  end
  self:ClearFocus()
end
function FlyoutMenuOption:SetData(data, useHotkeys, useCircularPositioning)
  self.isCircularMode = useCircularPositioning
  if self.isCircularMode then
    self.ScriptedEntityTweener:Set(self.Properties.ButtonBg, {opacity = 1})
  end
  self.useHotkeys = useHotkeys
  if useHotkeys then
    local hintText = LyShineManagerBus.Broadcast.GetKeybind(data.actionName, "flyout")
    self:SetHintText(hintText)
  end
  self:SetTooltip(data.tooltipText)
  self:SetIsHandlingEvents(data.enabled)
  if data.onlineCheckCharacterIdString and data.onlineCheckCharacterIdString ~= "" then
    self:SetOnlineOnly(data.onlineCheckCharacterIdString)
  else
    self.socialRequestCount = 0
    self.socialResponseCount = 0
  end
  self:SetIsClickable(not data.isClickDisabled)
  if not data.isClickDisabled then
    self:SetOnClickActionName(data.actionName)
  end
  if data.buttonIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.ButtonBg, data.buttonIcon)
  end
  if data.buttonText then
    self:SetText(data.buttonText)
  end
  self.table = data.callbackTable
  self.tickCallback = data.tickCallback
  if self.tickCallback then
    self.tickDuration = data.tickDuration or 1
    self.tickTimer = 0
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(TickBus)
    end
  elseif self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self:ClearFocus()
end
function FlyoutMenuOption:OnTick(deltaTime, timePoint)
  self.tickTimer = self.tickTimer + deltaTime
  if self.tickTimer >= self.tickDuration then
    self.tickTimer = self.tickTimer - self.tickDuration
    if self.tickCallback and self.table then
      self.tickCallback(self.table, self)
    end
  end
end
function FlyoutMenuOption:SetOnlineOnly(characterIdString)
  self.socialRequestCount = self.socialRequestCount + 1
  self.socialDataHandler:GetRemotePlayerOnlineStatus_ServerCall(self, self.OnRemotePlayerOnlineStatusReady, self.OnRemotePlayerOnlineStatusFailed, characterIdString)
end
function FlyoutMenuOption:OnRemotePlayerOnlineStatusReady(result)
  self.socialResponseCount = self.socialResponseCount + 1
  if self.socialResponseCount == self.socialRequestCount and 0 < #result and not result[1].isOnline then
    self:SetTooltip("@ui_cannot_interact_offline")
    self:SetIsHandlingEvents(false)
  end
end
function FlyoutMenuOption:OnRemotePlayerOnlineStatusFailed(reason)
  self.socialResponseCount = self.socialResponseCount + 1
  if reason == eSocialRequestFailureReasonThrottled then
    Log("TransferCurrencyPopup:OnRemotePlayerOnlineStatusFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("TransferCurrencyPopup:OnRemotePlayerOnlineStatusFailed: Timed Out")
  end
end
function FlyoutMenuOption:SetIsHandlingEvents(isHandlingEvents)
  self.isHandlingEvents = isHandlingEvents
  if self.isHandlingEvents then
    UiImageBus.Event.SetColor(self.Properties.ButtonBg, self.UIStyle.COLOR_WHITE)
    self:SetTextColor(self.UIStyle.COLOR_WHITE)
    if self.hasFocus then
      self:OnFocus()
    end
  else
    UiImageBus.Event.SetColor(self.Properties.ButtonBg, self.UIStyle.COLOR_GRAY_50)
    self:SetTextColor(self.UIStyle.COLOR_GRAY_30)
    if self.useHokeys then
      self:SetHintColor(self.UIStyle.COLOR_GRAY_30)
    end
    if self.hasFocus then
      self:ClearFocus()
    end
  end
end
function FlyoutMenuOption:IsHandlingEvents()
  return self.isHandlingEvents
end
function FlyoutMenuOption:SetIsClickable(value)
  self:OnUnFocus()
  self.isClickable = value
end
function FlyoutMenuOption:SetOnClickActionName(actionName)
  UiButtonBus.Event.SetOnClickActionName(self.entityId, actionName)
end
function FlyoutMenuOption:SetText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ButtonText, text, eUiTextSet_SetLocalized)
end
function FlyoutMenuOption:SetTextColor(color)
  UiTextBus.Event.SetColor(self.Properties.ButtonText, color)
end
function FlyoutMenuOption:SetHintText(hintText)
  if type(self.Hint) == "table" then
    self.Hint:SetText(hintText)
  end
end
function FlyoutMenuOption:SetHintColor(color)
  if type(self.Hint) == "table" then
    self.Hint:SetTextColor(color)
  end
end
function FlyoutMenuOption:SetTooltip(value)
  if value == nil then
    self.ButtonTooltipSetter:SetSimpleTooltip("")
    self.usingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    self.usingTooltip = true
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function FlyoutMenuOption:OnShutdown()
  if self.socialDataHandler then
    self.socialDataHandler:OnDeactivate()
  end
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
return FlyoutMenuOption
