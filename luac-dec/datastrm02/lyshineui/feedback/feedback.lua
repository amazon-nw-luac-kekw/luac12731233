local Feedback = {
  Properties = {
    ActionMapActivators = {
      default = {
        "openFeedbackForm",
        "ui_cancel"
      }
    },
    UseActionMapActivators = {default = true},
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
    ErrorText = {
      default = EntityId()
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
    FeedbackFrame = {
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
  STATE_NAME_FEEDBACK = 3525919832,
  invokedFrom = "",
  starRating = 0,
  starFocused = 0,
  errorShowing = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Feedback)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function Feedback:OnInit()
  BaseScreen.OnInit(self)
  SetTextStyle(self.Properties.Message, self.UIStyle.FONT_STYLE_BODY_NEW)
  SetTextStyle(self.Properties.StarPrompt, self.UIStyle.FONT_STYLE_HEADER_SECONDARY)
  self.CloseButton:SetCallback(self.OnClose, self)
  self.ButtonSubmit:SetButtonStyle(self.ButtonSubmit.BUTTON_STYLE_CTA)
  self.ButtonSubmit:SetText("@ui_submit")
  self.ButtonSubmit:SetCallback(self.OnSubmit, self)
  self.ButtonCancel:SetText("@ui_cancel")
  self.ButtonCancel:SetCallback(self.OnClose, self)
  local alpha = 0.5
  self.FeedbackFrame:SetLineAlpha(alpha)
  self.FrameHeader:SetText("@ui_feedback_format")
  UiTextBus.Event.SetFont(self.Properties.ErrorText, self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM)
  UiTextInputBus.Event.SetText(self.Properties.FeedbackText, "")
  self.dataLayer:RegisterOpenEvent("Feedback", self.canvasId)
  self.dataLayer:RegisterDataCallback(self, "UserFeedback.InvokedFrom", function(self, invokedFrom)
    if self.invokedFrom ~= "" then
      return
    end
    self.invokedFrom = invokedFrom
    if self.invokedFrom == "" then
      return
    end
    self.starRating = 0
    self:UpdateStars()
    UiElementBus.Event.SetIsEnabled(self.Properties.ErrorText, false)
    LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_FEEDBACK)
  end)
end
function Feedback:OnEnterPressed()
  local feedbackText = UiTextInputBus.Event.GetText(self.Properties.FeedbackText)
  feedbackText = feedbackText .. "\n"
  UiTextInputBus.Event.SetText(self.Properties.FeedbackText, feedbackText)
  TimingUtils:Delay(0.1, self, function()
    UiCanvasBus.Event.SetActiveInteractable(self.canvasId, self.Properties.FeedbackText, false)
    UiTextInputBus.Event.BeginEdit(self.Properties.FeedbackText)
  end)
end
function Feedback:OnClose()
  LyShineManagerBus.Broadcast.ExitState(0)
end
function Feedback:OnSubmit()
  local feedbackText = UiTextInputBus.Event.GetText(self.Properties.FeedbackText)
  if self.starRating == 0 and feedbackText == "" then
    self:ShowError(true)
    return
  end
  self:ShowError(false)
  local event = UiAnalyticsEvent("PlayerFeedback")
  event:AddMetric("Stars", self.starRating)
  event:AddAttribute("InvokedFrom", self.invokedFrom)
  event:AddAttribute("FeedbackText", feedbackText)
  local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  event:AddAttribute("territory_id", claimKey)
  event:VoluntarySend()
  UiTextInputBus.Event.SetText(self.Properties.FeedbackText, "")
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_feedback_submitted"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  self:OnClose()
end
function Feedback:OnHoverStart(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_Feedback)
end
function Feedback:OnOkPressed(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function Feedback:UpdateStars()
  local duration = 0.2
  for i = 1, 5 do
    if self.starFocused > self.starRating and i > self.starRating and i <= self.starFocused then
      self.ScriptedEntityTweener:Play(self.Properties.Stars[i - 1], duration, {
        imgColor = self.UIStyle.COLOR_WHITE,
        ease = "QuadOut"
      })
    elseif i > self.starRating then
      self.ScriptedEntityTweener:Play(self.Properties.Stars[i - 1], duration, {
        imgColor = self.UIStyle.COLOR_GRAY_30,
        ease = "QuadOut"
      })
    else
      self.ScriptedEntityTweener:Play(self.Properties.Stars[i - 1], duration, {
        imgColor = self.UIStyle.COLOR_YELLOW_GOLD,
        ease = "QuadOut"
      })
    end
  end
  self:ShowError(false)
end
function Feedback:OnStar(entityId, action)
  for i = 1, 5 do
    if self.Properties.Stars[i - 1] == entityId then
      self.starRating = i
    end
  end
  self:UpdateStars()
end
function Feedback:OnStarFocus(entityId, action)
  for i = 1, 5 do
    if self.Properties.Stars[i - 1] == entityId then
      self.starFocused = i
    end
  end
  self:UpdateStars()
end
function Feedback:StartEdit()
  self:ShowError(false)
  SetActionmapsForTextInput(self.canvasId, true)
end
function Feedback:EndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
end
function Feedback:ShowError(show)
  if self.errorShowing ~= show then
    UiElementBus.Event.SetIsEnabled(self.Properties.ErrorText, show)
    self.errorShowing = show
  end
end
function Feedback:OnTransitionIn(stateName, levelName)
  self.ScriptedEntityTweener:Play(self.Properties.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.PopupHolder, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.FeedbackFrame:SetLineVisible(true, 1.5, {delay = 0.2})
end
function Feedback:OnTransitionOut(stateName, levelName)
  self.invokedFrom = ""
  self.FeedbackFrame:SetLineVisible(false, 0.1)
  self.starFocused = 0
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function Feedback:OnShutdown()
end
return Feedback
