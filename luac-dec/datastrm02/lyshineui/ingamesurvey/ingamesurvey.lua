local InGameSurvey = {
  Properties = {
    FeedbackText = {
      default = EntityId()
    },
    Stars = {
      default = {
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId()
      }
    },
    StarDescriptions = {
      default = {
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId(),
        EntityId()
      }
    },
    ScreenScrim = {
      default = EntityId()
    },
    StarPrompt = {
      default = EntityId()
    },
    Message = {
      default = EntityId()
    },
    ButtonSubmit = {
      default = EntityId()
    },
    ButtonCancel = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    PopupHolder = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    FrameHeader = {
      default = EntityId()
    }
  },
  starRating = 0,
  starFocused = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(InGameSurvey)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function InGameSurvey:OnInit()
  BaseScreen.OnInit(self)
  DynamicBus.InGameSurvey.Connect(self.entityId, self)
  self.maxFeedbackLength = UiTextInputBus.Event.GetMaxStringLength(self.Properties.FeedbackText)
  SetTextStyle(self.Properties.Message, self.UIStyle.FONT_STYLE_SURVEY_MESSAGE)
  SetTextStyle(self.Properties.StarPrompt, self.UIStyle.FONT_STYLE_SURVEY_MESSAGE)
  local starDescriptions = {
    {
      text = "@ui_in_game_survey_rating_bad",
      color = self.UIStyle.COLOR_SURVEY_1
    },
    {
      text = "@ui_in_game_survey_rating_soso",
      color = self.UIStyle.COLOR_SURVEY_2
    },
    {
      text = "@ui_in_game_survey_rating_good",
      color = self.UIStyle.COLOR_SURVEY_3
    },
    {
      text = "@ui_in_game_survey_rating_great",
      color = self.UIStyle.COLOR_SURVEY_4
    },
    {
      text = "@ui_in_game_survey_rating_fantastic",
      color = self.UIStyle.COLOR_SURVEY_5
    }
  }
  for i = 0, #self.Properties.StarDescriptions do
    local data = starDescriptions[i + 1]
    local entityId = self.Properties.StarDescriptions[i]
    SetTextStyle(entityId, self.UIStyle.FONT_STYLE_SURVEY_STAR_DESC)
    UiTextBus.Event.SetTextWithFlags(entityId, data.text, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(entityId, data.color)
  end
  self.CloseButton:SetCallback(self.OnClose, self)
  self.ButtonSubmit:SetButtonStyle(self.ButtonSubmit.BUTTON_STYLE_CTA)
  self.ButtonSubmit:SetText("@ui_in_game_survey_button_submit")
  self.ButtonSubmit:SetCallback(self.OnSubmit, self)
  self.ButtonCancel:SetText("@ui_in_game_survey_button_cancel")
  self.ButtonCancel:SetCallback(self.OnClose, self)
  self.FrameHeader:SetText("@ui_in_game_survey_header")
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  UiTextInputBus.Event.SetText(self.Properties.FeedbackText, "")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-in-game-survey", function(self, enableInGameSurvey)
    self.inGameSurveyEnabled = enableInGameSurvey
  end)
end
function InGameSurvey:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.InGameSurvey.Disconnect(self.entityId, self)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
end
function InGameSurvey:TryShowInGameSurvey()
  if not self.inGameSurveyEnabled then
    return
  end
  local response = OptionsDataBus.Broadcast.ShouldShowInGameSurvey()
  if response.showSurvey then
    self.playerAge = response.playerAge
    self.threshold = response.threshold
    LyShineManagerBus.Broadcast.SetState(978471761)
  end
end
function InGameSurvey:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.starRating = 0
  self.starFocused = 0
  self:UpdateStars()
  self:UpdateSubmitButton()
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  self.ScriptedEntityTweener:Play(self.Properties.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.PopupHolder, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function InGameSurvey:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function InGameSurvey:SendAnalytics(isDeclined)
  local eventName = isDeclined and "InGameSurveyDeclined" or "InGameSurvey"
  local event = UiAnalyticsEvent(eventName)
  if not isDeclined then
    event:AddMetric("Stars", self.starRating)
    local feedbackText = UiTextInputBus.Event.GetText(self.Properties.FeedbackText)
    event:AddAttribute("FeedbackText", feedbackText)
  end
  event:AddMetric("PlayedMinutes", self.playerAge:ToMinutes())
  event:AddMetric("ThresholdMinutes", self.threshold)
  local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  event:AddAttribute("territory_id", claimKey)
  event:VoluntarySend()
end
function InGameSurvey:OnEscapeKeyPressed()
  self:OnClose()
end
function InGameSurvey:OnEnterPressed()
  local feedbackText = UiTextInputBus.Event.GetText(self.Properties.FeedbackText)
  if #feedbackText < self.maxFeedbackLength then
    feedbackText = feedbackText .. "\n"
    UiTextInputBus.Event.SetText(self.Properties.FeedbackText, feedbackText)
    TimingUtils:Delay(0.1, self, function()
      UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.Properties.FeedbackText, false)
      UiTextInputBus.Event.BeginEdit(self.Properties.FeedbackText)
    end)
  end
end
function InGameSurvey:OnSubmit()
  if not self.inGameSurveyEnabled or self.starRating == 0 then
    return
  end
  local isDeclined = false
  self:SendAnalytics(isDeclined)
  UiTextInputBus.Event.SetText(self.Properties.FeedbackText, "")
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_feedback_submitted"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  LyShineManagerBus.Broadcast.ExitState(978471761)
end
function InGameSurvey:OnHoverStart(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_Feedback)
end
function InGameSurvey:OnOkPressed(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function InGameSurvey:UpdateStars()
  local duration = 0.2
  for i = 0, #self.Properties.Stars do
    local rating = i + 1
    if self.starFocused > self.starRating and rating > self.starRating and rating <= self.starFocused then
      self.ScriptedEntityTweener:Play(self.Properties.Stars[i], duration, {
        imgColor = self.UIStyle.COLOR_WHITE,
        ease = "QuadOut"
      })
    elseif rating > self.starRating then
      self.ScriptedEntityTweener:Play(self.Properties.Stars[i], duration, {
        imgColor = self.UIStyle.COLOR_GRAY_30,
        ease = "QuadOut"
      })
    else
      self.ScriptedEntityTweener:Play(self.Properties.Stars[i], duration, {
        imgColor = self.UIStyle.COLOR_YELLOW_GOLD,
        ease = "QuadOut"
      })
    end
  end
end
function InGameSurvey:UpdateSubmitButton()
  local isEnabled = self.starRating > 0
  local tooltip = isEnabled and "" or "@ui_in_game_survey_button_submit_disabled_tooltip"
  self.ButtonSubmit:SetEnabled(isEnabled)
  self.ButtonSubmit:SetTooltip(tooltip)
end
function InGameSurvey:OnStar(entityId, action)
  for i = 0, #self.Properties.Stars do
    if self.Properties.Stars[i] == entityId then
      self.starRating = i + 1
    end
  end
  self:UpdateStars()
  self:UpdateSubmitButton()
end
function InGameSurvey:OnStarFocus(entityId, action)
  for i = 0, #self.Properties.Stars do
    if self.Properties.Stars[i] == entityId then
      self.starFocused = i + 1
    end
  end
  self:UpdateStars()
end
function InGameSurvey:StartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
end
function InGameSurvey:EndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
end
function InGameSurvey:OnClose()
  local isDeclined = true
  self:SendAnalytics(isDeclined)
  LyShineManagerBus.Broadcast.ExitState(978471761)
end
return InGameSurvey
