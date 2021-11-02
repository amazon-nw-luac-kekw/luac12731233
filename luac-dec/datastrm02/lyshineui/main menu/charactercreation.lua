local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local ECACScreenState = {
  Invalid = -1,
  Archetype = 0,
  Appearance = 2,
  Identity = 3,
  Text = 4
}
local ECACStateCameraNames = {}
local CharacterCreation = {
  Properties = {
    ScreenHolder = {
      default = EntityId()
    },
    ArchetypeMenu = {
      default = EntityId()
    },
    AppearanceMenu = {
      default = EntityId()
    },
    IdentityMenu = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    PortraitLine = {
      default = EntityId()
    },
    PortraitTitle = {
      default = EntityId()
    },
    PortraitTitleBg = {
      default = EntityId()
    },
    Header = {
      default = EntityId()
    },
    HeaderHolder = {
      default = EntityId()
    },
    HeaderClone = {
      default = EntityId()
    },
    ButtonsFooter = {
      default = EntityId()
    },
    ButtonNext = {
      default = EntityId()
    },
    ButtonBack = {
      default = EntityId()
    },
    ButtonRandomize = {
      default = EntityId()
    },
    ButtonCreate = {
      default = EntityId()
    },
    IntroText1 = {
      default = EntityId()
    },
    IntroText2 = {
      default = EntityId()
    },
    IntroText3 = {
      default = EntityId()
    },
    IntroText4 = {
      default = EntityId()
    },
    IntroText5 = {
      default = EntityId()
    },
    IntroText6 = {
      default = EntityId()
    },
    IntroText7 = {
      default = EntityId()
    },
    IntroText8 = {
      default = EntityId()
    },
    IntroText9 = {
      default = EntityId()
    },
    IntroText10 = {
      default = EntityId()
    },
    IntroText11 = {
      default = EntityId()
    },
    IntroText12 = {
      default = EntityId()
    },
    IntroText13 = {
      default = EntityId()
    },
    IntroTextFadeInTime = {default = 0.5},
    IntroTextFadeOutTime = {default = 0.25}
  },
  CreateCharacterPopupTitle = "@ftue_createcharacter_title",
  CreateCharacterPopupText = "@ftue_createcharacter_message",
  CreateCharacterEventId = "CreateCharacterPopup",
  QuitCharacterCreationTitle = "@ftue_quitcreation_title",
  QuitCharacterCreationText = "@ftue_quitcreation_message",
  QuitCharacterCreationEventId = "QuitCharacterCreationPopup",
  state = ECACScreenState.Archetype,
  cutscene = false,
  cinematicState = {},
  headerElements = {},
  headerCloneWidth = 300,
  continuingToFtue = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(CharacterCreation)
function CharacterCreation:OnInit()
  BaseScreen.OnInit(self)
  ECACStateCameraNames[ECACScreenState.Archetype] = "MenuA"
  ECACStateCameraNames[ECACScreenState.Appearance] = "MenuC"
  ECACStateCameraNames[ECACScreenState.Identity] = "MenuD"
  self:BusConnect(IntroControllerComponentNotificationsBus, self.canvasId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.dataLayer:RegisterOpenEvent("CharacterCreation", self.canvasId)
  self:SetVisualElements()
  self.ArchetypeIds = {
    "fighter",
    "sharpshooter",
    "crafter"
  }
  self.isIntroSceneLevel = ConfigProviderEventBus.Broadcast.GetBool("javelin.use-new-character-creation-flow")
  self.showBackstory = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableBackstorySelection")
end
function CharacterCreation:OnShutdown()
  BaseScreen.OnShutdown(self)
  for i = 1, #self.headerElements do
    local currentItem = self.headerElements[i].entityId
    UiElementBus.Event.DestroyElement(currentItem)
  end
  ClearTable(self.headerElements)
end
function CharacterCreation:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.ScreenHolder, self.canvasId)
    AdjustElementToCanvasWidth(self.Header, self.canvasId)
  end
end
function CharacterCreation:SetVisualElements()
  local headerData = {
    {
      state = ECACScreenState.Appearance,
      text = "@ui_appearance"
    },
    {
      state = ECACScreenState.Identity,
      text = "@ui_identity"
    }
  }
  for i = 1, #headerData do
    local currentItem = self:CloneElement(self.HeaderClone.entityId, self.HeaderHolder, true)
    currentItem:SetText(headerData[i].text)
    currentItem:SetPrefix(GetRomanFromNumber(i) .. tostring("."))
    currentItem:SetState(headerData[i].state)
    table.insert(self.headerElements, currentItem)
  end
  local headerHolderWidth = #headerData * self.headerCloneWidth
  UiTransform2dBus.Event.SetLocalWidth(self.HeaderHolder, headerHolderWidth)
  UiTextBus.Event.SetTextWithFlags(self.PortraitTitle, "@ui_portrait_title", eUiTextSet_SetLocalized)
  local textSize = UiTextBus.Event.GetTextSize(self.PortraitTitle)
  local textWidth = textSize.x
  local padding = 120
  UiTransform2dBus.Event.SetLocalWidth(self.PortraitTitleBg, textWidth + padding)
  self.ButtonNext:SetText("@ui_next")
  self.ButtonNext:SetCallback("navNext", self)
  self.ButtonNext:SetButtonStyle(self.ButtonNext.BUTTON_STYLE_CTA)
  self.ButtonNext:SetSoundOnFocus(self.audioHelper.FrontEnd_OnNextHover)
  self.ButtonNext:SetSoundOnPress(self.audioHelper.FrontEnd_OnNextPress)
  self.ButtonBack:SetText("@ui_back")
  self.ButtonBack:SetCallback("navBack", self)
  self.ButtonBack:SetSoundOnFocus(self.audioHelper.FrontEnd_OnBackHover)
  self.ButtonBack:SetSoundOnPress(self.audioHelper.FrontEnd_OnBackPress)
  self.ButtonRandomize:SetText("@ui_randomize")
  self.ButtonRandomize:SetCallback("navRandomize", self)
  self.ButtonRandomize:SetSoundOnFocus(self.audioHelper.FrontEnd_OnRandomizeHover)
  self.ButtonRandomize:SetSoundOnPress(self.audioHelper.FrontEnd_OnRandomizePress)
  self.ButtonCreate:SetText("@ui_createcharacter")
  self.ButtonCreate:SetCallback("navPlay", self)
  self.ButtonCreate:SetButtonStyle(self.ButtonCreate.BUTTON_STYLE_HERO)
  self.ButtonCreate:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCreateCharacterHover)
  self.ButtonCreate:SetSoundOnPress(self.audioHelper.FrontEnd_OnCreateCharacterPress)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCreate, false)
end
function CharacterCreation:OnAction(entityId, action)
  if BaseScreen.OnAction(self, entityId, action) then
    return
  end
  if type(self[action]) == "function" then
    self[action](self, entityId, action)
  end
  if self.ArchetypeMenu then
    self.ArchetypeMenu:OnAction(entityId, action)
  end
  if self.AppearanceMenu then
    self.AppearanceMenu:OnAction(entityId, action)
  end
  if self.IdentityMenu then
    self.IdentityMenu:OnAction(entityId, action)
  end
end
function CharacterCreation:OnCryAction(actionName)
  if not self.cutscene and not self.isTransitioning then
    self:backOut()
  end
end
function CharacterCreation:OnTransitionIn(stateName, levelName)
  if self.AppearanceMenu then
    self.AppearanceMenu:OnTransitionIn(stateName, levelName)
  end
  if self.IdentityMenu then
    self.IdentityMenu:OnTransitionIn(stateName, levelName)
  end
  self.escapeKeyHandler = self:BusConnect(CryActionNotificationsBus, "toggleMenuComponent")
  if self.showBackstory then
    self:SetState(ECACScreenState.Archetype)
  else
    self:SetState(ECACScreenState.Appearance)
  end
end
function CharacterCreation:OnTransitionOut(stateName, levelName)
  self.audioHelper:PlaySound(self.audioHelper.OnHide)
  self.AppearanceMenu:OnTransitionOut(stateName, levelName)
  self.IdentityMenu:OnTransitionOut(stateName, levelName)
  if self.escapeKeyHandler then
    self:BusDisconnect(self.escapeKeyHandler)
    self.escapeKeyHandler = nil
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function CharacterCreation:CreateCharacter()
  if self.ArchetypeMenu and self.AppearanceMenu and self.IdentityMenu then
    local selectedWorldId = MainMenuSystemRequestBus.Broadcast.GetSelectedWorldId()
    local characterEntity = self.AppearanceMenu.characterEntityId
    local characterName = self.IdentityMenu.validatedName
    local guildName = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@guild_default_name", characterName)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonCreate, false)
    if string.len(selectedWorldId) then
      if not self.showBackstory then
        local defaultBackstoryId = ConfigProviderEventBus.Broadcast.GetString("javelin.default-backstory-id")
        CustomizableCharacterRequestBus.Event.SetBackstory(self.ArchetypeMenu.characterEntityId, defaultBackstoryId)
      end
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonBack, false)
      self.ScriptedEntityTweener:Play(self.Properties.ButtonBack, 0.4, {opacity = 0, ease = "QuadOut"})
      self.IdentityMenu:SetOnCreateCharacterFailedResult(self, function()
        UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonBack, true)
        self.ScriptedEntityTweener:Play(self.Properties.ButtonBack, 0.4, {opacity = 1, ease = "QuadOut"})
      end)
      UiCharacterServiceRequestBus.Broadcast.CreateCharacter(selectedWorldId, characterName, guildName, characterEntity)
      self.IdentityMenu:StartCreateCharacterTimer()
    end
    self.ArchetypeMenu:SendArchetypeTelemetry()
  end
end
function CharacterCreation:OnPopupResult(result, eventId)
  if eventId == self.CreateCharacterEventId then
    if result == ePopupResult_Yes then
      self:CreateCharacter()
    end
  elseif eventId == self.QuitCharacterCreationEventId and result == ePopupResult_Yes then
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
    AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger("Stop_FTUE_All", true, EntityId())
    IntroControllerComponentRequestBus.Broadcast.OnExit()
  end
end
function CharacterCreation:navPlay(entityId, actionName)
  if self.IdentityMenu:IsNameValid() then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, self.CreateCharacterPopupTitle, self.CreateCharacterPopupText, self.CreateCharacterEventId, self, self.OnPopupResult)
  end
end
function CharacterCreation:navBack(entityId, actionName)
  self:backOut()
end
function CharacterCreation:backOut()
  if self.state == ECACScreenState.Archetype or self.state == ECACScreenState.Appearance then
    if self.isIntroSceneLevel then
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, self.QuitCharacterCreationTitle, self.QuitCharacterCreationText, self.QuitCharacterCreationEventId, self, self.OnPopupResult)
    else
      LyShineManagerBus.Broadcast.SetState(3881446394)
    end
  elseif self.cutscene then
    IntroControllerComponentRequestBus.Broadcast.OnMenuBack()
  elseif self.state == ECACScreenState.Identity then
    self:SetState(ECACScreenState.Appearance)
  end
end
function CharacterCreation:navNext(entityId, actionName)
  if self.cutscene then
    IntroControllerComponentRequestBus.Broadcast.OnMenuNext()
  elseif self.state == ECACScreenState.Archetype then
    self:SetState(ECACScreenState.Appearance)
  elseif self.state == ECACScreenState.Appearance then
    self:SetState(ECACScreenState.Identity)
  end
end
function CharacterCreation:navRandomize(entityId, actionName)
  if self.state == ECACScreenState.Appearance then
    self.AppearanceMenu:OnRandomize()
  end
end
function CharacterCreation:editPlayerName(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnText)
end
function CharacterCreation:editCompanyName(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnText)
end
function CharacterCreation:SetState(newState)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonNext, newState ~= ECACScreenState.Identity and newState ~= ECACScreenState.Text)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonBack, newState ~= ECACScreenState.Text)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonCreate, newState == ECACScreenState.Identity)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonRandomize, newState == ECACScreenState.Appearance)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonNext, newState ~= ECACScreenState.Archetype)
  local animDelay = 0
  if newState == ECACScreenState.Identity then
    self.IdentityMenu:ValidateName()
    self.IdentityMenu:StopCreateCharacterTimer()
    animDelay = self.IdentityMenu:GetAnimDelay()
    SetTextStyle(self.PortraitTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC)
  end
  if newState == ECACScreenState.Archetype then
    if self.isIntroSceneLevel then
      self.ButtonBack:SetText("@ui_quit")
    end
    self.ArchetypeMenu:ValidateArchetype()
    animDelay = self.ArchetypeMenu:GetAnimDelay()
  else
    self.ButtonBack:SetText("@ui_back")
  end
  if newState == ECACScreenState.Appearance then
    animDelay = self.AppearanceMenu:GetAnimDelay()
    SetTextStyle(self.PortraitTitle, self.UIStyle.FONT_STYLE_TITLE_GENERIC_GRAY_90)
    self.ButtonBack:SetText("@ui_quit")
    self.ButtonNext:SetEnabled(true)
  end
  if newState == ECACScreenState.Text then
    LyShineManagerBus.Broadcast.RemoveMouseOwner(self.canvasId)
  else
    LyShineManagerBus.Broadcast.AddMouseOwner(self.canvasId)
  end
  self.ArchetypeMenu:SetScreenVisible(newState == ECACScreenState.Archetype)
  self.AppearanceMenu:SetScreenVisible(newState == ECACScreenState.Appearance)
  self.IdentityMenu:SetScreenVisible(newState == ECACScreenState.Identity)
  self:SetHeaderVisible(newState ~= ECACScreenState.Text)
  self:SetFooterVisible(newState ~= ECACScreenState.Text, animDelay)
  self.state = newState
  for i = 1, #self.headerElements do
    local currentItem = self.headerElements[i]
    local currentItemState = currentItem:GetState()
    local isActive = currentItemState == self.state
    currentItem:SetActive(isActive)
  end
end
function CharacterCreation:SetHeaderVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Stop(self.Properties.Header)
    self.ScriptedEntityTweener:Play(self.Properties.Header, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.1
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.Header, 0.3, {opacity = 0, ease = "QuadIn"})
  end
end
function CharacterCreation:SetFooterVisible(isVisible, delayTime)
  local animDelay = delayTime and delayTime or 0.1
  if isVisible then
    self:SetButtonIsHandlingEvents(false)
    self.ScriptedEntityTweener:Play(self.Properties.ButtonsFooter, 0.3, {y = 30, opacity = 0}, {
      y = 0,
      opacity = 1,
      ease = "QuadOut",
      delay = animDelay,
      onComplete = function()
        self:SetButtonIsHandlingEvents(true)
      end
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.ButtonsFooter, 0.1, {
      x = 0,
      onComplete = function()
        self:SetButtonIsHandlingEvents(false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonsFooter, 0.3, {
      y = 30,
      opacity = 0,
      ease = "QuadIn"
    })
  end
end
function CharacterCreation:SetPlayerIconVisible(isVisible)
  local animDelay = 0.4
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.PortraitTitle, 0.3, {y = 30, opacity = 0}, {
      y = 0,
      opacity = 1,
      ease = "QuadOut",
      delay = animDelay
    })
    self.ScriptedEntityTweener:Play(self.Properties.PortraitTitleBg, 0.3, {y = 12, opacity = 0}, {
      y = -18,
      opacity = 1,
      ease = "QuadOut",
      delay = animDelay
    })
    self.ScriptedEntityTweener:Play(self.Properties.PortraitLine, 0.3, {y = 30, opacity = 0}, {
      y = 0,
      opacity = 1,
      ease = "QuadOut",
      delay = animDelay
    })
    self.ScriptedEntityTweener:Play(self.Properties.PlayerIcon, 0.3, {y = 30, opacity = 0}, {
      y = 0,
      opacity = 1,
      ease = "QuadOut",
      delay = animDelay
    })
    self.PortraitLine:SetVisible(true, 1.2, {delay = animDelay})
  else
    self.ScriptedEntityTweener:Play(self.Properties.PortraitTitle, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PortraitTitleBg, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PortraitLine, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PlayerIcon, 0.3, {opacity = 0, ease = "QuadOut"})
    self.PortraitLine:SetVisible(false, 0.6, {delay = 0})
  end
end
function CharacterCreation:SetButtonIsHandlingEvents(isHandlingEvents)
  self.isTransitioning = not isHandlingEvents
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonNext, isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonBack, isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonCreate, isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ButtonRandomize, isHandlingEvents)
end
function CharacterCreation:OnSkinnedMeshCreated(entityId)
  self.AppearanceMenu:OnSkinnedMeshCreated()
end
function CharacterCreation:ShowIntroText(id, textDuration)
  local localizedText
  local introText = self.Properties["IntroText" .. id]
  if id == "5" or id == "10" then
    local archetypeIndex = IntroControllerComponentRequestBus.Broadcast.GetCurrentArchetypeIndex()
    local localizedTextId = self:GetLocalizedIntroTextId(archetypeIndex, tonumber(id) / 5)
    localizedText = LyShineScriptBindRequestBus.Broadcast.LocalizeText(localizedTextId)
  elseif id == "11" then
    local keys = vector_basic_string_char_char_traits_char()
    local values = vector_basic_string_char_char_traits_char()
    keys:push_back("player_name")
    values:push_back(self.IdentityMenu.validatedName)
    localizedText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ftue_intro_11", keys, values)
  else
    localizedText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ftue_intro_" .. id)
  end
  UiTextBus.Event.SetTextWithFlags(introText, localizedText, eUiTextSet_SetAsIs)
  self.ScriptedEntityTweener:Play(introText, self.Properties.IntroTextFadeInTime, {
    opacity = 1,
    onComplete = function()
      self:OnShowTextCompleted(introText, textDuration)
    end
  })
end
function CharacterCreation:GetLocalizedIntroTextId(archetypeIndex, introTextIndex)
  local localizedTextId = "@ftue_intro_"
  if archetypeIndex <= 0 or archetypeIndex > #self.ArchetypeIds then
    archetypeIndex = #self.ArchetypeIds
    IntroControllerComponentRequestBus.Broadcast.SetCurrentArchetypeIndex(archetypeIndex)
  end
  localizedTextId = localizedTextId .. self.ArchetypeIds[archetypeIndex]
  if introTextIndex == 1 then
    localizedTextId = localizedTextId .. "_1st"
  elseif introTextIndex == 2 then
    localizedTextId = localizedTextId .. "_2nd"
  end
  return localizedTextId
end
function CharacterCreation:OnShowTextCompleted(introText, textDuration)
  self.ScriptedEntityTweener:Play(introText, self.Properties.IntroTextFadeOutTime, {opacity = 0, delay = textDuration})
end
function CharacterCreation:SetCreationState(creationState)
  if not self.ArchetypeMenu:IsArchetypeSelected() and creationState ~= ECACScreenState.Archetype and creationState ~= ECACScreenState.Text then
    creationState = ECACScreenState.Archetype
  end
  if creationState == ECACScreenState.Archetype then
    self:SetState(ECACScreenState.Archetype)
  elseif creationState == ECACScreenState.Appearance then
    self:SetState(ECACScreenState.Appearance)
  elseif creationState == ECACScreenState.Identity then
    self:SetState(ECACScreenState.Identity)
  elseif creationState == ECACScreenState.Text then
    self:SetState(ECACScreenState.Text)
  end
  if creationState ~= ECACScreenState.Text then
    self.audioHelper:PlaySound(self.audioHelper.OnShow)
  end
end
function CharacterCreation:OnCharacterCreated()
  self.cinematicHandler = CinematicEventBus.Connect(self)
  CinematicRequestBus.Broadcast.PlaySequenceByName("Character_Create_03_Sequence")
end
function CharacterCreation:OnCinematicStateChanged(cinematicName, state)
  if self.cinematicState[cinematicName] ~= state then
    self.cinematicState[cinematicName] = state
    if cinematicName == "DeckShip_Sequence" and state == eMovieEvent_BeyondEnd and self.continuingToFtue == false then
      IntroControllerComponentRequestBus.Broadcast.OnContinueToFTUE()
      self.continuingToFtue = true
    elseif cinematicName == "Character_Create_03_Sequence" and state == eMovieEvent_BeyondEnd then
      CinematicRequestBus.Broadcast.PlaySequenceByName("DeckShip_Sequence")
    end
  end
end
function CharacterCreation:ClearText()
  local introText = self.registrar:GetEntityTable(self.Properties.IntroText1)
  if introText then
    introText:Reset()
  end
end
return CharacterCreation
