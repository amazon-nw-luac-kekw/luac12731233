local QuitGamePopup = {
  mQuitPopupInCombatTitle = "@ui_quitpopup_incombat_title",
  mQuitPopupInCombatMessage = "@ui_quitpopup_incombat_message",
  mQuitPopupTickTimer = 0,
  mQuitPopupDefaultTitle = "",
  mQuitPopupDefaultMessage = "",
  mQuitPopupTitle = "",
  mQuitPopupMessage = "",
  mQuitPopupRawMessage = "",
  mQuitPopupEndTimePoint = TimePoint:Now(),
  mQuitPopupEndMaxDurationSeconds = -1
}
function QuitGamePopup:AttachQuitGamePopup(attachToTable)
  Merge(attachToTable, QuitGamePopup, true)
end
function QuitGamePopup:ShowQuitGamePopup(buttons, defaultTitle, defaultMessage, eventId, showExitSurvey)
  self:ClearCustomParts()
  self.mPopupType = "QuitGamePopup"
  self.mEventId = eventId
  self.mQuitPopupDefaultTitle = defaultTitle
  self.mQuitPopupDefaultMessage = defaultMessage
  self.timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.CombatStatus.IsInCombat", self.SetQuitGameTitleAndMessageText)
  self:SetQuitGameTitleAndMessageText()
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHolderOk, buttons == ePopupButtons_OK)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonHolderYesNo, buttons == ePopupButtons_YesNo)
  local showExitSurvey = self.exitSurveyEnabled and showExitSurvey == true
  UiElementBus.Event.SetIsEnabled(self.Properties.EnableExitSurveyCheckbox, showExitSurvey)
  if showExitSurvey then
    local state = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled")
    self.EnableExitSurveyCheckbox:SetState(state)
    self.bottomPadding = self.exitSurveyEnabled and 30 or 0
  end
  self:ResizePopup()
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
end
function QuitGamePopup:OnTickQuitGamePopup(deltaTime, timePoint)
  self.mQuitPopupTickTimer = self.mQuitPopupTickTimer + deltaTime
  if self.mQuitPopupTickTimer > 1 then
    self.mQuitPopupTickTimer = 0
    local timeRemaining = self.mQuitPopupEndTimePoint:Subtract(TimePoint:Now()):ToSeconds()
    if 0 < self.mQuitPopupEndMaxDurationSeconds and timeRemaining > self.mQuitPopupEndMaxDurationSeconds then
      timeRemaining = self.mQuitPopupEndMaxDurationSeconds
    end
    local updatedMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(self.mQuitPopupRawMessage, self.timeHelpers:ConvertSecondsToHrsMinSecString(timeRemaining))
    UiTextBus.Event.SetTextWithFlags(self.Properties.PopupMessage, updatedMessage, eUiTextSet_SetLocalized)
  end
end
function QuitGamePopup:SetQuitGameTitleAndMessageText()
  local isInCombat = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.IsInCombat")
  local rootPlayerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local inCombatDurationSeconds = -1
  local isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  local isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, 2444859928)
  if not isFtue and isInCombat and not isInOutpostRush then
    inCombatDurationSeconds = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.InCombatTimePoint"):Subtract(TimePoint:Now()):ToSeconds()
  end
  if inCombatDurationSeconds < 0 then
    self.mQuitPopupTitle = self.mQuitPopupDefaultTitle
    self.mQuitPopupMessage = self.mQuitPopupDefaultMessage
    self:StopTick()
  else
    self.mQuitPopupTitle = self.mQuitPopupInCombatTitle
    self.mQuitPopupRawMessage = self.mQuitPopupInCombatMessage
    self.mQuitPopupEndTimePoint = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.InCombatTimePoint")
    self.mQuitPopupMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(self.mQuitPopupInCombatMessage, self.timeHelpers:ConvertSecondsToHrsMinSecString(inCombatDurationSeconds))
    self:StartTick()
  end
  self.FrameHeader:SetText(self.mQuitPopupTitle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PopupMessage, self.mQuitPopupMessage, eUiTextSet_SetLocalized)
end
function QuitGamePopup:CleanUpQuitGamePopup()
  self.dataLayer:UnregisterObservers(self)
end
return QuitGamePopup
