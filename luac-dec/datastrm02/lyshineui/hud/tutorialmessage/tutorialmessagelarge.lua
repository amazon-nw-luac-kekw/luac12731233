local ETutorialMessageLargeState = {Hidden = 0, Message = 1}
local TutorialMessageLarge = {
  Properties = {
    ScreenHolder = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    TitleDivider = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    TutorialMask = {
      default = EntityId()
    },
    KeyBindingLinesContainer = {
      default = EntityId()
    },
    MainBg = {
      default = EntityId()
    }
  },
  prevState = ETutorialMessageLargeState.Hidden,
  state = ETutorialMessageLargeState.Hidden,
  keyBindingLineSlicePath = "LyShineUI\\HUD\\TutorialMessage\\Tutorial_KeyBindingLine",
  keyBindingLinesEntities = {},
  isHeavyAttackHeld = false,
  isHeavyAttackAnimPlayed = false,
  heavyAttackHeldThreshold = 3,
  heavyAttackHeldCount = 0,
  mainBgInitHeight = 340,
  mainBgOffsetHeight = 290,
  isBlockBreakMessage = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TutorialMessageLarge)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(TutorialMessageLarge)
function TutorialMessageLarge:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(TutorialComponentNotificationsBus, self.canvasId)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.KeyBindingLinesContainer)
  DynamicBus.TutorialMessageLarge.Connect(self.entityId, self)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  local titleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 42,
    fontColor = self.UIStyle.WHITE
  }
  local descriptionStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 24,
    fontColor = self.UIStyle.WHITE
  }
  SetTextStyle(self.Properties.Title, titleStyle)
  SetTextStyle(self.Properties.Description, descriptionStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, "@TUT_AdvCombatMsg1", eUiTextSet_SetLocalized)
end
function TutorialMessageLarge:OnTutorialLargeActivated(titleMsg, playRevealSound)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, titleMsg, eUiTextSet_SetLocalized)
  if titleMsg == "@TUT_Title_Combat3" then
    self.isBlockBreakMessage = true
    UiElementBus.Event.SetIsEnabled(self.Properties.Description, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.KeyBindingLinesContainer, 70)
    self.ScriptedEntityTweener:Set(self.Properties.MainBg, {
      h = self.mainBgOffsetHeight
    })
    UiTransformBus.Event.SetLocalPositionY(self.entityId, 50)
  else
    self.isBlockBreakMessage = false
    UiElementBus.Event.SetIsEnabled(self.Properties.Description, false)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.KeyBindingLinesContainer, 0)
    self.ScriptedEntityTweener:Set(self.Properties.MainBg, {
      h = self.mainBgInitHeight
    })
    UiTransformBus.Event.SetLocalPositionY(self.entityId, 0)
  end
  local msgList = self:BuildMessagesList()
  for i = 1, #msgList do
    self:SpawnSlice(self.Properties.KeyBindingLinesContainer, self.keyBindingLineSlicePath, self.OnKeyBindingLineSpawned, msgList[i])
  end
  self:SetState(ETutorialMessageLargeState.Message)
  if playRevealSound then
    self.audioHelper:PlaySound(self.audioHelper.InitialToastShow)
  end
  self:ShowTransitionIn()
end
function TutorialMessageLarge:SetState(newState)
  if newState ~= self.state then
    self.prevState = self.state
    self.state = newState
  end
end
function TutorialMessageLarge:ShowTransitionIn()
  self:SetActionHandlersActive(true)
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.TutorialMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.TutorialMask)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {
    opacity = 1,
    ease = "QuadOut",
    onComplete = function()
      self:OnTransitionInCompleted()
    end
  })
  self.ScriptedEntityTweener:Play(self.Title, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  self.ScriptedEntityTweener:Play(self.TitleDivider, 1.6, {scaleX = 0}, {
    scaleX = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  self.ScriptedEntityTweener:Play(self.KeyBindingLinesContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.3
  })
  self.audioHelper:PlaySound(self.audioHelper.InitialToastShow)
  self.audioHelper:PlaySound(self.audioHelper.WhisperSounds)
end
function TutorialMessageLarge:GetTutorialComponentId()
  return self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Tutorial.LocalPlayerId")
end
function TutorialMessageLarge:OnTransitionInCompleted()
  local tutorialComponentId = self:GetTutorialComponentId()
  TutorialUIRequestsBus.Event.OnTransitionInCompleted(tutorialComponentId)
end
function TutorialMessageLarge:ShowTransitionOut()
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {
    opacity = 0,
    ease = "QuadIn",
    onComplete = function()
      self:OnTransitionOutCompleted()
    end
  })
  self:SetState(ETutorialMessageLargeState.Hidden)
end
function TutorialMessageLarge:OnTransitionOutCompleted()
  self:SetActionHandlersActive(false)
  self:ClearKeyBindingEntities()
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  if self.continueTutorialSteps then
    local tutorialComponentId = self:GetTutorialComponentId()
    TutorialUIRequestsBus.Event.OnTransitionOutCompleted(tutorialComponentId)
  end
end
function TutorialMessageLarge:OnTutorialLargeDeactivated(continueTutorialSteps)
  self.continueTutorialSteps = continueTutorialSteps
  if self.state ~= ETutorialMessageLargeState.Hidden then
    self:ShowTransitionOut()
  elseif self.continueTutorialSteps then
    self:OnTransitionOutCompleted()
  end
end
function TutorialMessageLarge:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function TutorialMessageLarge:OnCryAction(actionName, value)
  if actionName == "attack_primary_hold" and self.heavyAttackHeldCount < self.heavyAttackHeldThreshold then
    self.heavyAttackHeldCount = self.heavyAttackHeldCount + 1
    if self.heavyAttackHeldCount >= self.heavyAttackHeldThreshold and not self.isHeavyAttackHeld then
      self.isHeavyAttackHeld = true
      self.isHeavyAttackAnimPlayed = false
    else
      self.isHeavyAttackHeld = false
      self.isHeavyAttackAnimPlayed = false
    end
    return
  elseif actionName ~= "attack_primary_hold" then
    self.heavyAttackHeldCount = 0
    self.isHeavyAttackHeld = false
    self.isHeavyAttackAnimPlayed = false
  end
  for i = 1, #self.keyBindingLinesEntities do
    local currentItemKeybinding = self.keyBindingLinesEntities[i].data.keyBindings[1].keyBinding
    if actionName == currentItemKeybinding then
      local currentEntityTable = self.keyBindingLinesEntities[i].entityTable
      if actionName == "attack_primary_hold" and self.isHeavyAttackHeld and not self.isHeavyAttackAnimPlayed then
        currentEntityTable:SetFlashVisible(true)
        self.isHeavyAttackAnimPlayed = true
        if not self.isBlockBreakMessage then
          local attackEntityTable = self.keyBindingLinesEntities[1].entityTable
          attackEntityTable:SetFlashVisible(false)
        end
        break
      end
      if actionName ~= "attack_primary_hold" then
        currentEntityTable:SetFlashVisible(true)
      end
      break
    end
  end
end
function TutorialMessageLarge:OnKeyBindingLineSpawned(lineEntity, data)
  self.keyBindingLinesEntities[#self.keyBindingLinesEntities + 1] = {
    entityId = lineEntity.entityId,
    entityTable = lineEntity,
    data = data
  }
  lineEntity:SetLine(data.msgText, data.keyBindings)
end
function TutorialMessageLarge:ClearKeyBindingEntities()
  for i = 1, #self.keyBindingLinesEntities do
    UiElementBus.Event.DestroyElement(self.keyBindingLinesEntities[i].entityId)
  end
  self.keyBindingLinesEntities = {}
end
function TutorialMessageLarge:BuildMessagesList()
  local tutorialComponentId = self:GetTutorialComponentId()
  local msgList = {}
  local messageLinesCount = LargeToastRequestBus.Event.GetMessageLinesCount(tutorialComponentId)
  for i = 1, messageLinesCount do
    local messageLine = {}
    messageLine.msgText = LargeToastRequestBus.Event.GetMessageText(tutorialComponentId, i)
    messageLine.keyBindings = {}
    local bindingsCount = LargeToastRequestBus.Event.GetBindingsCount(tutorialComponentId, i)
    for bindingIndex = 1, bindingsCount do
      local binding = {}
      binding.keyBinding = LargeToastRequestBus.Event.GetBindingParam(tutorialComponentId, i, bindingIndex, "keyBinding")
      binding.keyCategory = LargeToastRequestBus.Event.GetBindingParam(tutorialComponentId, i, bindingIndex, "keyCategory")
      binding.separator = LargeToastRequestBus.Event.GetBindingParam(tutorialComponentId, i, bindingIndex, "separator")
      messageLine.keyBindings[#messageLine.keyBindings + 1] = binding
    end
    msgList[#msgList + 1] = messageLine
  end
  return msgList
end
function TutorialMessageLarge:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.ScreenHolder, self.canvasId)
  end
end
function TutorialMessageLarge:SetActionHandlersActive(value)
  if value then
    self.attackKeyHandler = CryActionNotificationsBus.Connect(self, "attack_primary")
    self.attackHeavyKeyHandler = CryActionNotificationsBus.Connect(self, "attack_primary_hold")
    self.blockKeyHandler = CryActionNotificationsBus.Connect(self, "block")
    self.dodgeKeyHandler = CryActionNotificationsBus.Connect(self, "dodge")
  else
    self:BusDisconnect(self.attackKeyHandler)
    self:BusDisconnect(self.attackHeavyKeyHandler)
    self:BusDisconnect(self.blockKeyHandler)
    self:BusDisconnect(self.dodgeKeyHandler)
  end
end
function TutorialMessageLarge:OnShutdown()
  self:SetActionHandlersActive(false)
  DynamicBus.TutorialMessageLarge.Disconnect(self.entityId, self)
end
return TutorialMessageLarge
