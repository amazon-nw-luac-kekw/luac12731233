local ETutorialMessageState = {
  Hidden = 0,
  Intro = 1,
  Message = 2
}
local TutorialMessage = {
  Properties = {
    Title = {
      default = EntityId()
    },
    TitleDivider = {
      default = EntityId()
    },
    Message = {
      default = EntityId()
    },
    MainBg = {
      default = EntityId()
    },
    TutorialMask = {
      default = EntityId()
    },
    KeyBindingsList = {
      default = EntityId()
    },
    KeyBindingContainer = {
      default = EntityId()
    },
    OutroLogo = {
      default = EntityId()
    },
    OutroLogoMask = {
      default = EntityId()
    },
    Locators = {
      L1 = {
        default = EntityId()
      },
      L2 = {
        default = EntityId()
      },
      L3 = {
        default = EntityId()
      },
      L4 = {
        default = EntityId()
      },
      L5 = {
        default = EntityId()
      }
    }
  },
  prevState = ETutorialMessageState.Hidden,
  state = ETutorialMessageState.Hidden,
  clickToContinue = false,
  isOutro = false,
  initBgHeight = 170,
  hintFontSize = 32,
  hintMinWidth = 44,
  highlightVisible = true
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TutorialMessage)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function TutorialMessage:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(TutorialComponentNotificationsBus, self.canvasId)
  self.keyBindingList = self.registrar:GetEntityTable(self.Properties.KeyBindingsList)
  self:SetVisualElements()
  DynamicBus.TutorialMessage.Connect(self.entityId, self)
end
function TutorialMessage:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.TutorialMessage.Disconnect(self.entityId, self)
end
function TutorialMessage:SetVisualElements()
  local titleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 40,
    fontColor = self.UIStyle.WHITE
  }
  local messageStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 28,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.Title, titleStyle)
  SetTextStyle(self.Properties.Message, messageStyle)
end
function TutorialMessage:OnTutorialActivated(tutorialMsgId, showTitle, titleMsgId, playRevealSound, clickToContinue, position, msgKeyBindings, keyBindCategories, separators, Width, Height, positionOverride)
  self.clickToContinue = clickToContinue
  local keys = vector_basic_string_char_char_traits_char()
  local values = vector_basic_string_char_char_traits_char()
  for i = 1, #msgKeyBindings do
    keys:push_back(msgKeyBindings[i])
    values:push_back(LyShineManagerBus.Broadcast.GetKeybind(msgKeyBindings[i], keyBindCategories[i]))
  end
  local newText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(tutorialMsgId, keys, values)
  local keyBindings = self:BuildBindingsList(msgKeyBindings, keyBindCategories, separators)
  self.ScriptedEntityTweener:Set(self.Properties.KeyBindingContainer, {opacity = 0})
  self.keyBindingList:SetupBindings(keyBindings, self.hintFontSize, self.hintMinWidth, self.highlightVisible)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, titleMsgId, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.Properties.Message, newText)
  if tutorialMsgId == "" then
    local keybindsNoMessageOffsetPosY = -31
    self.ScriptedEntityTweener:Set(self.Properties.KeyBindingContainer, {y = keybindsNoMessageOffsetPosY})
    self.ScriptedEntityTweener:Set(self.Properties.MainBg, {
      w = 550,
      h = 125,
      y = 5
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleDivider, false)
  else
    local messageHeight = UiTextBus.Event.GetTextHeight(self.Properties.Message)
    local oneLineHeight = 40
    local isOneLine = messageHeight < oneLineHeight
    local keybindOffsetPosY = isOneLine and 5 or 35
    local mainBgOffset = isOneLine and 0 or -5
    local mainBgHeight = isOneLine and self.initBgHeight or self.initBgHeight + 40
    self.ScriptedEntityTweener:Set(self.Properties.KeyBindingContainer, {y = keybindOffsetPosY})
    self.ScriptedEntityTweener:Set(self.Properties.MainBg, {
      w = 650,
      h = mainBgHeight,
      y = mainBgOffset
    })
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleDivider, true)
  end
  self:SetState(ETutorialMessageState.Intro)
  if playRevealSound then
    self.audioHelper:PlaySound(self.audioHelper.InitialToastShow)
  else
    self.audioHelper:PlaySound(self.audioHelper.FollowUpToastShow)
  end
  self.isOutro = false
  if tutorialMsgId == "outro" then
    self.isOutro = true
  else
    self.audioHelper:PlaySound(self.audioHelper.WhisperSounds)
  end
  self:SetPosition(position, positionOverride)
  self:ShowTransitionIn()
end
function TutorialMessage:SetState(newState)
  self.prevState = self.state
  self.state = newState
end
function TutorialMessage:SetPosition(position, positionOverride)
  local location = position == 2 and 2 or 4
  if positionOverride then
    location = positionOverride
  end
  UiElementBus.Event.Reparent(self.entityId, self.Properties.Locators["L" .. tostring(location)], EntityId())
end
function TutorialMessage:ShowTransitionIn()
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  if self.isOutro then
    TimingUtils:Delay(4.5, self, function()
      UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.OutroLogoMask, 0)
      UiFlipbookAnimationBus.Event.Start(self.Properties.OutroLogoMask)
    end)
    self.ScriptedEntityTweener:Play(self.Properties.OutroLogo, 2, {opacity = 0}, {
      opacity = 1,
      ease = "QuadIn",
      delay = 4
    })
    self.ScriptedEntityTweener:Play(self.Properties.OutroLogo, 10, {scaleX = 1.1, scaleY = 1.1}, {
      scaleX = 0.95,
      scaleY = 0.95,
      ease = "QuadOut",
      onComplete = function()
        self:OnTransitionInCompleted()
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.OutroLogo, 2, {
      opacity = 0,
      ease = "QuadOut",
      delay = 12.5
    })
  else
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.TutorialMask, 0)
    UiFlipbookAnimationBus.Event.Start(self.TutorialMask)
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {
      opacity = 1,
      ease = "QuadOut",
      onComplete = function()
        self:OnTransitionInCompleted()
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.Title, 0.5, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Stop(self.Properties.TitleDivider)
    self.ScriptedEntityTweener:Play(self.Properties.TitleDivider, 1.6, {scaleX = 0, opacity = 0}, {
      scaleX = 1,
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.Message, 0.5, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.KeyBindingContainer, 0.5, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.3
    })
  end
end
function TutorialMessage:GetTutorialComponentId()
  return self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Tutorial.LocalPlayerId")
end
function TutorialMessage:OnTransitionInCompleted()
  local tutorialComponentId = self:GetTutorialComponentId()
  TutorialUIRequestsBus.Event.OnTransitionInCompleted(tutorialComponentId)
end
function TutorialMessage:ShowTransitionOut()
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {
    opacity = 0,
    ease = "QuadIn",
    onComplete = function()
      self:OnTransitionOutCompleted()
    end
  })
  self:SetState(ETutorialMessageState.Hidden)
end
function TutorialMessage:OnTransitionOutCompleted()
  self.keyBindingList:ClearKeyBindingEntities()
  UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  local tutorialComponentId = self:GetTutorialComponentId()
  TutorialUIRequestsBus.Event.OnTransitionOutCompleted(tutorialComponentId)
end
function TutorialMessage:OnTutorialDeactivated()
  if self.state ~= ETutorialMessageState.Hidden then
    self:ShowTransitionOut()
  end
end
function TutorialMessage:OnAction(entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function TutorialMessage:BuildBindingsList(msgKeyBindings, keyBindCategories, separators)
  local bindingsList = {}
  for i = 1, #msgKeyBindings do
    local binding = {}
    binding.keyBinding = msgKeyBindings[i]
    binding.keyCategory = keyBindCategories[i]
    if i <= #separators then
      binding.separator = separators[i]
    else
      binding.separator = ""
    end
    bindingsList[#bindingsList + 1] = binding
  end
  return bindingsList
end
return TutorialMessage
