local SessionItem = {
  Properties = {
    PlayerIcon = {
      default = EntityId()
    },
    TwitchNameLabel = {
      default = EntityId()
    },
    RequestButton = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    PendingText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SessionItem)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function SessionItem:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(TwitchSubArmyNotificationBus)
  self.RequestButton:SetText("@ui_subarmy_request_invite")
  self.RequestButton:SetTooltip("@ui_subarmy_join_tooltip")
  self.RequestButton:SetCallback(self.OnRequestButton, self)
  UiElementBus.Event.SetIsEnabled(self.Properties.PendingText, false)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.TwitchNameLabel, -2)
  self.RequestButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE)
end
function SessionItem:SetPlayerName(playerName)
  self.playerName = playerName
  self.PlayerIcon:StartSpinner()
  SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
    if 0 < #result then
      self.playerId = result[1].playerId
      self.PlayerIcon:SetPlayerId(self.playerId)
      self.PlayerIcon:RequestPlayerIconData()
    end
  end, function(self)
    Log("ERR - SessionItem:SetPlayerName: Failed to get playerId")
  end, playerName)
end
function SessionItem:SetTwitchName(twitchName)
  self.twitchName = twitchName
  local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_subarmy_subarmytag", self.twitchName)
  UiTextBus.Event.SetTextWithFlags(self.TwitchNameLabel, text, eUiTextSet_SetLocalized)
end
function SessionItem:OnRequestButton()
  if not self.twitchName then
    return
  end
  TwitchSubArmyRequestBus.Broadcast.RequestJoinSubArmy(self.twitchName)
  UiElementBus.Event.SetIsEnabled(self.RequestButton, false)
  UiElementBus.Event.SetIsEnabled(self.Spinner, true)
  self.ScriptedEntityTweener:Set(self.Spinner, {rotation = 0})
  self.ScriptedEntityTweener:Play(self.Spinner, 1, {timesToPlay = -1, rotation = 359})
end
function SessionItem:OnRequestJoinResultReceived(twitchName, status)
  if twitchName ~= self.twitchName then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Spinner, false)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.TwitchNameLabel, -2)
  UiElementBus.Event.SetIsEnabled(self.Properties.PendingText, false)
  self.RequestButton:SetEnabled(false)
  local buttonText = ""
  local tooltip = ""
  local isButtonVisible = true
  if status == eSubArmyInviteStatus_Pending then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TwitchNameLabel, -10)
    UiElementBus.Event.SetIsEnabled(self.Properties.PendingText, true)
    buttonText = "@ui_subarmy_pending"
    tooltip = "@ui_subarmy_waiting"
    isButtonVisible = false
  elseif status == eSubArmyInviteStatus_Accepted then
    buttonText = "@ui_subarmy_request_accepted"
    tooltip = "@ui_subarmy_accept_tooltip"
    isButtonVisible = true
  elseif status == eSubArmyInviteStatus_Declined then
    buttonText = "@ui_subarmy_request_declined"
    tooltip = "@ui_subarmy_decline_tooltip"
    isButtonVisible = true
  elseif status == eSubArmyInviteStatus_SignupsFull then
    buttonText = "@ui_subarmy_request_session_full"
    tooltip = "@ui_subarmy_full_tooltip"
    isButtonVisible = true
  else
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_subarmy_failed_to_send_request"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    buttonText = "@ui_subarmy_request_invite"
    tooltip = "@ui_subarmy_join_tooltip"
    isButtonVisible = true
    self.RequestButton:SetEnabled(true)
  end
  self.RequestButton:SetText(buttonText)
  self.RequestButton:SetTooltip(tooltip)
  UiElementBus.Event.SetIsEnabled(self.RequestButton, isButtonVisible)
end
return SessionItem
