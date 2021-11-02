local ChatWidget_Alert = {
  Properties = {
    ChatAlert = {
      default = EntityId()
    },
    AlertsList = {
      default = EntityId()
    },
    DisableAlertsButton = {
      default = EntityId()
    }
  },
  MAX_ALERTS = 3,
  visibleAlertCount = 0,
  enableAlertsOptionDataPath = "Hud.LocalPlayer.Options.Chat.ChatEnableAlerts",
  currentAlertIndex = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ChatWidget_Alert)
local chatData = RequireScript("LyShineUI.HUD.Chat.ChatData")
function ChatWidget_Alert:OnInit()
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.enableAlertsOptionDataPath, function(self, isEnabled)
    if isEnabled ~= nil then
      self.isAlertsEnabled = isEnabled
      self:UpdateAlertsEnabled()
    end
  end)
  self.clonedElements = {
    self.ChatAlert
  }
  self.ChatAlert:SetHideCallback(self.OnAlertHidden, self)
  for i = #self.clonedElements + 1, self.MAX_ALERTS do
    local clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.ChatAlert, self.Properties.AlertsList, false)
    clonedElement:SetHideCallback(self.OnAlertHidden, self)
    table.insert(self.clonedElements, clonedElement)
  end
  UiFaderBus.Event.SetFadeValue(self.Properties.DisableAlertsButton, 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.DisableAlertsButton, false)
  self.isButtonVisible = false
  self.DisableAlertsButton:SetText("@ui_disable_alerts")
  self.DisableAlertsButton:SizeToText()
  self.DisableAlertsButton:SetCallback(function()
    LyShineDataLayerBus.Broadcast.SetData(self.enableAlertsOptionDataPath, false)
    OptionsDataBus.Broadcast.SerializeOptions()
  end, self)
end
function ChatWidget_Alert:OnShutdown()
  if self.clonedElements then
    for _, chatAlert in ipairs(self.clonedElements) do
      if chatAlert.entityId ~= self.Properties.ChatAlert then
        UiElementBus.Event.DestroyElement(chatAlert.entityId)
      end
    end
  end
  if self.chatNotificationsHandler then
    DynamicBus.ChatNotifications.Disconnect(self.entityId, self)
    self.chatNotificationsHandler = nil
  end
end
function ChatWidget_Alert:OnWidgetVisibilityChanged(isWidgetVisible)
  self.isWidgetVisible = isWidgetVisible
  self:UpdateAlertsEnabled()
end
function ChatWidget_Alert:UpdateAlertsEnabled()
  local isEnabled = self.isAlertsEnabled and self.isWidgetVisible
  if self.isEnabled ~= isEnabled then
    if isEnabled then
      if not self.chatNotificationsHandler then
        self.chatNotificationsHandler = DynamicBus.ChatNotifications.Connect(self.entityId, self)
      end
    elseif self.chatNotificationsHandler then
      DynamicBus.ChatNotifications.Disconnect(self.entityId, self)
      self.chatNotificationsHandler = nil
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
    self.isEnabled = isEnabled
  end
end
function ChatWidget_Alert:UpdateButtonVisibility()
  local isButtonVisible = self.visibleAlertCount > 0
  if self.isButtonVisible == isButtonVisible then
    return
  end
  self.ScriptedEntityTweener:Stop(self.Properties.DisableAlertsButton)
  if isButtonVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.DisableAlertsButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.DisableAlertsButton, 0.3, {
      opacity = 1,
      delay = 0.2,
      ease = "QuadOut"
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.DisableAlertsButton, 1, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.DisableAlertsButton, false)
      end
    })
  end
  self.isButtonVisible = isButtonVisible
end
local invalidEntityId = EntityId()
function ChatWidget_Alert:OnChatMessageReceived(chatMessageData)
  if chatMessageData.isPingMessage or chatMessageData.isOwnMessage or DynamicBus.ChatBus.Broadcast.IsInWidgetState() then
    return
  end
  local showAlert = chatMessageData.alertOnReceive
  if not showAlert then
    local chatTypesToStates = OptionsDataBus.Broadcast.GetChatTypeStates()
    for i = 1, #chatTypesToStates do
      local typeToState = chatTypesToStates[i]
      if typeToState.messageType == chatMessageData.chatType then
        showAlert = typeToState.messageState == eChatMessageTypeState_Alert
        break
      end
    end
  end
  if showAlert then
    local chatMessageToUse = self.clonedElements[self.currentAlertIndex]
    UiElementBus.Event.Reparent(chatMessageToUse.entityId, self.Properties.AlertsList, invalidEntityId)
    if not chatMessageToUse:GetIsVisible() then
      self.visibleAlertCount = self.visibleAlertCount + 1
    end
    chatMessageToUse:SetMessageData(chatMessageData)
    chatMessageToUse:SetAlertIsVisible(true)
    if self.currentAlertIndex == self.MAX_ALERTS then
      self.currentAlertIndex = 1
    else
      self.currentAlertIndex = self.currentAlertIndex + 1
    end
    self:UpdateButtonVisibility()
  end
end
function ChatWidget_Alert:OnAlertHidden()
  self.visibleAlertCount = self.visibleAlertCount - 1
  if self.visibleAlertCount < 0 then
    self.visibleAlertCount = 0
  end
  self:UpdateButtonVisibility()
end
return ChatWidget_Alert
