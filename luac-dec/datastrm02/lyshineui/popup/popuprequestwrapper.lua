local PopupRequestWrapper = {}
function PopupRequestWrapper:SignalOwner(result)
  if self.popupHandler then
    self.popUpHandler:Disconnect(self.currentPopup.eventId)
    self.popupHandler = nil
  end
  if self.currentPopup then
    local currentPopup = self.currentPopup
    self.currentPopup = nil
    if currentPopup.callback then
      currentPopup.callback(currentPopup.callerSelf, result, currentPopup.eventId, currentPopup.data)
    end
  end
end
function PopupRequestWrapper:RequestPopupWithParams(params)
  if self.currentPopup then
    Debug.Log(string.format("Error: There is a popup currently (event name = %s) being shown. Forcing it closed and replacing it.", tostring(self.currentPopup.eventId)))
    self:SignalOwner(ePopupResult_ForceClosed)
  end
  if params.weOwnParams then
    self.currentPopup = params
  else
    self.currentPopup = {
      callerSelf = params.callerSelf,
      callback = params.callback,
      eventId = params.eventId,
      data = params.data
    }
  end
  if params.buttons ~= nil then
    UiPopupBus.Broadcast.ShowPopup(params.buttons, params.title, params.message, params.eventId)
  else
    DynamicBus.PopupScreenRequestsBus.Broadcast.ShowCustomPopup(params)
  end
  self.hasReceivedInput = false
  self.popUpHandler = UiPopupNotificationsBus.Connect(self, self.currentPopup.eventId)
end
function PopupRequestWrapper:RequestPopup(buttons, title, message, eventId, callerSelf, callback, data, showCloseButton, additionalHeight)
  self:RequestPopupWithParams({
    buttons = buttons,
    title = title,
    message = message,
    eventId = eventId,
    callerSelf = callerSelf,
    callback = callback,
    data = data,
    showCloseButton = showCloseButton,
    additionalHeight = additionalHeight,
    weOwnParams = true
  })
end
function PopupRequestWrapper:RequestError(errorId, timepoint, additionalInfo, eventId)
  if self.currentPopup then
    Debug.Log(string.format("Error: There is a popup currently (event name = %s) being shown. Forcing it closed and replacing it.", tostring(self.currentPopup.eventId)))
    self:SignalOwner(ePopupResult_ForceClosed)
  end
  UiPopupBus.Broadcast.ShowError(errorId, timepoint, additionalInfo, eventId)
end
function PopupRequestWrapper:KillPopup(eventId)
  if not self.currentPopup then
    Debug.Log(string.format("Error: Attempt to kill popup %s but there is no current popup.", tostring(eventId)))
    return
  end
  if self.currentPopup.eventId ~= eventId then
    Debug.Log(string.format("Error: Attempt to kill popup for eventId (%s) does not match our eventId (%s)", tostring(eventId), tostring(self.currentPopup.eventId)))
    return
  end
  if self.popupHandler then
    self.popUpHandler:Disconnect(self.currentPopup.eventId)
    self.popupHandler = nil
  end
  UiPopupBus.Broadcast.HidePopup(eventId)
  self.currentPopup = nil
end
function PopupRequestWrapper:Reset()
  if self.currentPopup then
    self:KillPopup(self.currentPopup.eventId)
  end
end
function PopupRequestWrapper:OnPopupResult(result, eventId)
  if self.hasReceivedInput then
    return
  end
  if not self.currentPopup then
    Debug.Log("Error: Unexpected popup result notification. EventId = " .. tostring(eventId))
  end
  if self.currentPopup and eventId ~= self.currentPopup.eventId then
    Debug.Log(string.format("Error: Mismatched popup result notification with eventId = %s but we are waiting for eventId = %s", tostring(eventId), tostring(self.currentPopup.eventId)))
  end
  self.hasReceivedInput = true
  self:SignalOwner(result)
end
return PopupRequestWrapper
