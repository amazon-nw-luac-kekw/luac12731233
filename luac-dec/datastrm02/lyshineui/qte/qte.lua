local qte = {
  Properties = {
    PromptHolder = {
      default = EntityId()
    },
    PromptMask = {
      default = EntityId()
    },
    PromptText = {
      default = EntityId()
    },
    PromptHint = {
      default = EntityId()
    },
    PromptHintText = {
      default = EntityId()
    }
  },
  states = {},
  isPastPrimaryAttack = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(qte)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function qte:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(CinematicEventBus)
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
end
function qte:OnCinematicStateChanged(cinematicName, state)
  if not string.find(cinematicName, "QTE_") then
    return
  end
  if self.states[cinematicName] ~= state then
    if state == eMovieEvent_Started then
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("movement", false)
      if cinematicName == "QTE_Sequence_A" then
        DynamicBus.FtueMessageBus.Broadcast.SetElementVisibleForFtue(false)
        LyShineDataLayerBus.Broadcast.SetData("Ftue.SetElementVisibleForFtue", false)
        UIInputRequestsBus.Broadcast.EnableInputFilter("LockWeapons", false)
        UIInputRequestsBus.Broadcast.SetActionMapEnabled("ui", false)
        UIInputRequestsBus.Broadcast.SetActionMapEnabled("default", false)
        UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", false)
      elseif cinematicName == "QTE_Sequence_A1" then
        UiCanvasBus.Event.SetEnabled(self.canvasId, true)
        TimingUtils:Delay(0.1, self, function()
          self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, "quickslot-weapon1")
          self.actionHandler2 = self:BusConnect(CryActionNotificationsBus, "sheathe")
          self.PromptHint:SetActionMap("player")
          self.PromptHint:SetKeybindMapping("sheathe")
          UiTextBus.Event.SetTextWithFlags(self.Properties.PromptText, "@ftue_qte_draw_your_weapon", eUiTextSet_SetLocalized)
          self:SetPromptVisible(true)
        end)
      elseif cinematicName == "QTE_Sequence_B" then
      elseif cinematicName == "QTE_Sequence_C" then
        self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, "block")
        self.PromptHint:SetActionMap("player")
        self.PromptHint:SetKeybindMapping("block")
        UiTextBus.Event.SetTextWithFlags(self.Properties.PromptText, "@ftue_qte_block", eUiTextSet_SetLocalized)
        self:SetPromptVisible(true)
      elseif cinematicName == "QTE_Sequence_D" then
      elseif cinematicName == "QTE_Sequence_E" then
        self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, "attack_primary")
        self.PromptHint:SetActionMap("player")
        self.PromptHint:SetKeybindMapping("attack_primary")
        UiTextBus.Event.SetTextWithFlags(self.Properties.PromptText, "@ftue_qte_attack", eUiTextSet_SetLocalized)
        self:SetPromptVisible(true)
      elseif cinematicName == "QTE_Sequence_F" then
      elseif cinematicName == "QTE_Sequence_G" then
        TimingUtils:Delay(0.05, self, function()
          self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, "dodge")
          self.PromptHint:SetActionMap("player")
          self.PromptHint:SetKeybindMapping("dodge")
          UiTextBus.Event.SetTextWithFlags(self.Properties.PromptText, "@ftue_qte_dodge", eUiTextSet_SetLocalized)
          self:SetPromptVisible(true)
        end)
      elseif cinematicName == "QTE_Sequence_H" then
      elseif cinematicName == "QTE_Sequence_I" then
        TimingUtils:Delay(0.3, self, function()
          self.actionHandler1 = self:BusConnect(CryActionNotificationsBus, "attack_primary_hold")
          self.PromptHint:SetActionMap("player")
          self.PromptHint:SetKeybindMapping("attack_primary_hold")
          self.ScriptedEntityTweener:Set(self.Properties.PromptHintText, {opacity = 1})
          UiTextBus.Event.SetTextWithFlags(self.Properties.PromptText, "@ftue_qte_heavy_attack", eUiTextSet_SetLocalized)
          UiTextBus.Event.SetTextWithFlags(self.Properties.PromptHintText, "@TUT_Hold", eUiTextSet_SetLocalized)
          local hintSpacing = 10
          local hintScale = 1.5
          local widthHint = self.PromptHint:GetWidth() * hintScale
          local widthHoldText = UiTextBus.Event.GetTextWidth(self.Properties.PromptHintText)
          local widthTotal = widthHint + widthHoldText + hintSpacing
          local widthCentered = widthTotal / 2 - widthHint / 2
          local posXHint = widthCentered
          local posXHoldText = widthHoldText + widthHint / 2 + hintSpacing - widthCentered
          UiTransformBus.Event.SetLocalPosition(self.Properties.PromptHint, Vector2(posXHint, 0))
          UiTransformBus.Event.SetLocalPosition(self.Properties.PromptHintText, Vector2(-posXHoldText, 0))
          self:SetPromptVisible(true)
        end)
      elseif cinematicName == "QTE_Sequence_Jay" then
        self:SetPromptVisible(false)
        UIInputRequestsBus.Broadcast.EnableInputFilter("LockWeapons", true)
        UIInputRequestsBus.Broadcast.EnableInputFilter("LockCombat", true)
        UIInputRequestsBus.Broadcast.EnableInputFilter("LockInventory", true)
        DynamicBus.FtueMessageBus.Broadcast.OnTutorialRevealUIElement("Health")
      end
    end
    if state == eMovieEvent_BeyondEnd then
      if cinematicName == "QTE_Sequence_A" then
        CinematicRequestBus.Broadcast.PlaySequenceByName("QTE_Sequence_A1")
      elseif cinematicName == "QTE_Sequence_B" then
        CinematicRequestBus.Broadcast.PlaySequenceByName("QTE_Sequence_C")
      elseif cinematicName == "QTE_Sequence_D" then
        CinematicRequestBus.Broadcast.PlaySequenceByName("QTE_Sequence_E")
      elseif cinematicName == "QTE_Sequence_F" then
        CinematicRequestBus.Broadcast.PlaySequenceByName("QTE_Sequence_G")
      elseif cinematicName == "QTE_Sequence_H" then
        CinematicRequestBus.Broadcast.PlaySequenceByName("QTE_Sequence_I")
      end
    end
    if state == eMovieEvent_Stopped and cinematicName == "QTE_Sequence_Jay" then
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_A")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_A1")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_B")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_C")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_D")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_E")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_F")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_G")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_H")
      CinematicRequestBus.Broadcast.StopSequence("QTE_Sequence_I")
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("movement", true)
      UiCanvasBus.Event.SetEnabled(self.canvasId, false)
      JavCameraControllerRequestBus.Broadcast.MakeActiveView(0.75, 0.75, 0.75)
      DynamicBus.FtueMessageBus.Broadcast.SetElementVisibleForFtue(true)
      LyShineDataLayerBus.Broadcast.SetData("Ftue.SetElementVisibleForFtue", true)
      UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", true)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("ui", true)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("default", true)
      UIInputRequestsBus.Broadcast.SetActionMapEnabled("camera", true)
    end
    self.states[cinematicName] = state
  end
end
function qte:SetPromptVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Stop(self.Properties.PromptHolder)
    self.ScriptedEntityTweener:Set(self.Properties.PromptHolder, {opacity = 1})
    self.PromptHint:SetHighlightVisible(true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.PromptMask, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.PromptMask)
    self.audioHelper:PlaySound(self.audioHelper.WhisperSounds)
  else
    self.ScriptedEntityTweener:Play(self.Properties.PromptHolder, 0.3, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.PromptHint:SetHighlightScale(1.8, 0.2)
    self.audioHelper:PlaySound(self.audioHelper.FTUEPromptComplete)
  end
end
function qte:OnCryAction(actionName, value)
  local event
  if actionName == "sheathe" or actionName == "quickslot-weapon1" then
    self:SetNextSequence("QTE_Sequence_B")
    event = UiAnalyticsEvent("ftue_combat_sheathe")
  elseif actionName == "block" then
    self:SetNextSequence("QTE_Sequence_D")
    event = UiAnalyticsEvent("ftue_combat_block")
  elseif actionName == "attack_primary" and not self.isPastPrimaryAttack then
    self.isPastPrimaryAttack = true
    self:SetNextSequence("QTE_Sequence_F")
    event = UiAnalyticsEvent("ftue_combat_light_attack")
  elseif actionName == "dodge" then
    self:SetNextSequence("QTE_Sequence_H")
    event = UiAnalyticsEvent("ftue_combat_dodge")
  elseif actionName == "attack_primary_hold" then
    self.isPastPrimaryAttack = false
    self:SetNextSequence("QTE_Sequence_Jay")
    event = UiAnalyticsEvent("ftue_combat_block_breaker")
  end
  if event ~= nil then
    event:Send()
  end
end
function qte:SetNextSequence(value)
  TimingUtils:StopDelay(self)
  CinematicRequestBus.Broadcast.PlaySequenceByName(value)
  self:BusDisconnect(self.actionHandler1)
  self:BusDisconnect(self.actionHandler2)
  self:BusDisconnect(self.actionHandler3)
  self:SetPromptVisible(false)
end
return qte
