local TextInputAutoComplete = {
  Properties = {
    Spinner = {
      default = EntityId()
    }
  },
  requestDelay = 1,
  timer = 0,
  maxResults = 25,
  onlineOnly = false,
  isSpinning = false,
  enterCallback = nil,
  enterTable = nil,
  startEditCallback = nil,
  startEditTable = nil,
  endEditCallback = nil,
  endEditTable = nil,
  maxStringLength = 32
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TextInputAutoComplete)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function TextInputAutoComplete:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiTextInputNotificationBus, self.entityId)
  self:SetMaxStringLength(self.maxStringLength)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  if self.Spinner:IsValid() then
    self.ScriptedEntityTweener:Set(self.Spinner, {rotation = 0, opacity = 0})
  end
  self.dataLayer = dataLayer
end
function TextInputAutoComplete:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.socialDataHandler:OnDeactivate()
end
function TextInputAutoComplete:SetText(text)
  UiTextInputBus.Event.SetText(self.entityId, text)
end
function TextInputAutoComplete:GetText()
  return UiTextInputBus.Event.GetText(self.entityId)
end
function TextInputAutoComplete:SetMaxStringLength(value)
  UiTextInputBus.Event.SetMaxStringLength(self.entityId, value)
end
function TextInputAutoComplete:GetMaxStringLength()
  return UiTextInputBus.Event.GetMaxStringLength(self.entityId)
end
function TextInputAutoComplete:SetOnlineOnly(onlineOnly)
  self.onlineOnly = onlineOnly
end
function TextInputAutoComplete:GetOnlineOnly()
  return self.onlineOnly
end
function TextInputAutoComplete:SetMaxResults(maxResults)
  self.maxResults = maxResults
end
function TextInputAutoComplete:GetMaxResults()
  return self.maxResults
end
function TextInputAutoComplete:SetActiveAndBegin()
  UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.entityId, true)
  UiTextInputBus.Event.BeginEdit(self.entityId)
end
function TextInputAutoComplete:StartSpinner()
  if self.Spinner:IsValid() and not self.isSpinning then
    self.ScriptedEntityTweener:Play(self.Spinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isSpinning = true
  end
end
function TextInputAutoComplete:StopSpinner()
  if self.Spinner:IsValid() and self.isSpinning then
    self.ScriptedEntityTweener:Stop(self.Spinner)
    self.ScriptedEntityTweener:Set(self.Spinner, {rotation = 0, opacity = 0})
    self.isSpinning = false
  end
end
function TextInputAutoComplete:OnPlayerListReceived(playerResults)
  local names = vector_basic_string_char_char_traits_char()
  for i = 1, #playerResults do
    if not self.onlineOnly or playerResults[i].isOnline then
      names:push_back(playerResults[i].playerId.playerName)
    end
  end
  UiTextInputAutoCompleteBus.Event.SetTextList(self.entityId, names)
  self:StopSpinner()
end
function TextInputAutoComplete:OnSearchFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    self:ShowErrorNotification("@ui_autocompletethrottled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    self:ShowErrorNotification("@ui_autocompletetimedout")
  end
  self:StopSpinner()
end
function TextInputAutoComplete:ShowErrorNotification(message)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function TextInputAutoComplete:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer > self.requestDelay then
    self.socialDataHandler:RequestSearchPlayers_ServerCall(self, self.OnPlayerListReceived, self.OnSearchFailed, self.currentText, self.maxResults)
    self:StopTick()
  end
end
function TextInputAutoComplete:StartTick()
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function TextInputAutoComplete:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function TextInputAutoComplete:SetEnterCallback(command, table)
  self.enterCallback = command
  self.enterTable = table
end
function TextInputAutoComplete:SetStartEditCallback(command, table)
  self.startEditCallback = command
  self.startEditTable = table
end
function TextInputAutoComplete:SetEndEditCallback(command, table)
  self.endEditCallback = command
  self.endEditTable = table
end
function TextInputAutoComplete:ExecuteCallback(command, table)
  if command ~= nil and table ~= nil then
    if type(command) == "function" then
      command(table)
    elseif type(table[command]) == "function" then
      table[command](table)
    end
  end
end
function TextInputAutoComplete:OnTextInputChange(textString)
  textString = textString or ""
  if textString == self.currentText then
    return
  end
  self.currentText = textString
  local stringLength = string.len(textString)
  if 0 < stringLength then
    self.timer = 0
    self:StartSpinner()
    self:StartTick()
  else
    self:StopSpinner()
    self:StopTick()
  end
end
function TextInputAutoComplete:OnStartEdit()
  self:ExecuteCallback(self.startEditCallback, self.startEditTable)
end
function TextInputAutoComplete:OnEndEdit()
  self:ExecuteCallback(self.endEditCallback, self.endEditTable)
end
function TextInputAutoComplete:OnEnter()
  self:ExecuteCallback(self.enterCallback, self.enterTable)
end
return TextInputAutoComplete
