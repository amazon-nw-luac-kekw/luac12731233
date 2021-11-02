local LegalScreen = {
  Properties = {
    Controls = {
      default = EntityId()
    },
    ButtonAccept = {
      default = EntityId()
    },
    EnableExitSurveyCheckbox = {
      default = EntityId()
    },
    EmberEffect = {
      default = EntityId()
    },
    BGImage = {
      default = EntityId()
    },
    Container = {
      default = EntityId()
    },
    Black = {
      default = EntityId()
    },
    CopyrightText = {
      default = EntityId()
    },
    BackgroundHolder = {
      default = EntityId()
    },
    BlackIntroReveal = {
      default = EntityId()
    },
    VideoRenderTarget = {
      default = EntityId()
    },
    CodeOfConduct = {
      Window = {
        default = EntityId()
      },
      AcceptButton = {
        default = EntityId()
      },
      DividerTop = {
        default = EntityId()
      },
      DividerBottom = {
        default = EntityId()
      },
      LinkToCocDescription1 = {
        default = EntityId()
      },
      LinkToCocDescription2 = {
        default = EntityId()
      },
      CodeOfConductLink = {
        default = EntityId()
      }
    },
    SeizureWarning = {
      Window = {
        default = EntityId()
      },
      SeizureTitle = {
        default = EntityId()
      },
      SeizureDescription1 = {
        default = EntityId()
      },
      SeizureDescription2 = {
        default = EntityId()
      },
      SeizureWarning = {
        default = EntityId()
      },
      SeizureBg = {
        default = EntityId()
      },
      AcceptButton = {
        default = EntityId()
      }
    }
  },
  notificationHandlers = {},
  canProceed = false,
  proceedToIntro = false,
  connectionErrorTitle = "@mm_connection_error_title",
  connectionErrorMessage = "@mm_connection_error_title",
  errorTimeoutEventId = "Popup_ErrorTimeout",
  videoIsPlaying = false,
  fadeOutTime = 0.4,
  showSeizureWarning = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(LegalScreen)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local DataLayer = RequireScript("LyShineUI.UiDataLayer")
function LegalScreen:OnInit()
  BaseScreen.OnInit(self)
  DataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableSeizureWarning", function(self, enable)
    self.showSeizureWarning = enable
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-exit-survey", function(self, exitSurveyEnabled)
    if exitSurveyEnabled == nil then
      return
    end
    self.exitSurveyEnabled = exitSurveyEnabled
    if not exitSurveyEnabled then
      UiElementBus.Event.SetIsEnabled(self.Properties.EnableExitSurveyCheckbox, false)
    end
  end)
  self.requireCodeOfConduct = self.dataLayer:GetDataFromNode("UIFeatures.require-code-of-conduct")
  self.ScriptedEntityTweener:Set(self.Properties.CodeOfConduct.Window, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.SeizureWarning.Window, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Black, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Container, {opacity = 1})
  UiElementBus.Event.SetIsEnabled(self.Properties.CodeOfConduct.Window, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.SeizureWarning.Window, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Black, false)
  UiTextBus.Event.SetFontSize(self.Properties.CopyrightText, self.UIStyle.FONT_SIZE_BODY_NEW)
  local alpha = 0.5
  self.ScriptedEntityTweener:Set(self.Properties.CodeOfConduct.DividerTop, {opacity = alpha})
  self.ScriptedEntityTweener:Set(self.Properties.CodeOfConduct.DividerBottom, {opacity = alpha})
  AudioPreloadComponentRequestBus.Event.LoadPreload(EntityId(), "MainMenu")
  self:BusConnect(InputChannelNotificationBus)
  self:BusConnect(UiLoginScreenNotificationBus)
  self:BusConnect(BinkEventBus)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self.ButtonAccept:SetText("@ui_continue")
  self.ButtonAccept:SetCallback(self.OnContinue, self)
  self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_HERO)
  self.ButtonAccept:SetSoundOnFocus(self.audioHelper.OnHover_LegalScreen)
  self.ButtonAccept:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  self.CodeOfConduct.AcceptButton:SetText("@legal_codeofconduct_agree")
  self.CodeOfConduct.AcceptButton:SetCallback("codeOfConductAccept", self)
  self.CodeOfConduct.AcceptButton:SetButtonStyle(self.CodeOfConduct.AcceptButton.BUTTON_STYLE_CTA)
  self.CodeOfConduct.AcceptButton:SetSoundOnFocus(self.audioHelper.OnHover_LegalScreen)
  self.CodeOfConduct.AcceptButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  self.SeizureWarning.AcceptButton:SetText("@ui_ok")
  self.SeizureWarning.AcceptButton:SetCallback(self.SeizureWarningAccept, self)
  self.SeizureWarning.AcceptButton:SetButtonStyle(self.SeizureWarning.AcceptButton.BUTTON_STYLE_CTA)
  self.SeizureWarning.AcceptButton:SetSoundOnFocus(self.audioHelper.OnHover_LegalScreen)
  self.SeizureWarning.AcceptButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  self.EnableExitSurveyCheckbox:SetText("@ui_options_take_exit_survey")
  self.EnableExitSurveyCheckbox:SetTextSize(self.UIStyle.FONT_SIZE_BODY_NEW)
  self.EnableExitSurveyCheckbox:SetCallback(self, self.OnEnableExitSurveyChanged)
  SetTextStyle(self.SeizureWarning.SeizureTitle, self.UIStyle.FONT_STYLE_HEADER_TAN)
  SetTextStyle(self.SeizureWarning.SeizureDescription1, self.UIStyle.FONT_STYLE_BODY)
  SetTextStyle(self.SeizureWarning.SeizureDescription2, self.UIStyle.FONT_STYLE_BODY)
  SetTextStyle(self.SeizureWarning.SeizureWarning, self.UIStyle.FONT_STYLE_BODY)
  self.ScriptedEntityTweener:Set(self.SeizureWarning.SeizureWarning, {
    textColor = self.UIStyle.COLOR_BLACK
  })
  UiTextBus.Event.SetTextWithFlags(self.SeizureWarning.SeizureTitle, "@ui_seizure_title", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.SeizureWarning.SeizureDescription1, "@ui_seizure_description1", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.SeizureWarning.SeizureDescription2, "@ui_seizure_description2", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.SeizureWarning.SeizureWarning, "@ui_seizure_warning", eUiTextSet_SetLocalized)
  AdjustElementToCanvasSize(self.SeizureWarning.SeizureBg, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:ToggleElementsVisibilityAfterVideoEnd(false)
  local cocDesc1TextWidth = UiTextBus.Event.GetTextSize(self.Properties.CodeOfConduct.LinkToCocDescription1).x
  local cocDesc2TextWidth = UiTextBus.Event.GetTextSize(self.Properties.CodeOfConduct.LinkToCocDescription2).x
  local linkWidth = UiTextBus.Event.GetTextSize(self.Properties.CodeOfConduct.CodeOfConductLink).x
  local totalWidth = cocDesc1TextWidth + linkWidth + 8 + cocDesc2TextWidth
  UiTransformBus.Event.SetLocalPositionX(self.Properties.CodeOfConduct.LinkToCocDescription1, totalWidth * 0.5 * -1)
end
function LegalScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  self:CleanupVideo()
  UiFlipbookAnimationBus.Event.Stop(self.EmberEffect)
end
function LegalScreen:OnInputChannelEvent(inputChannel, hasBeenConsumed)
  if inputChannel.deviceName == "keyboard" and self.videoIsPlaying then
    self:OnPlaybackStopped()
  end
end
function LegalScreen:OnTick(deltaTime, timePoint)
  self:CleanupVideo()
  if self.tickBusHandler ~= nil then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
end
function LegalScreen:ShowVideoControls(showVideo)
  UiElementBus.Event.SetIsEnabled(self.Properties.Controls, not showVideo)
  UiElementBus.Event.SetIsEnabled(self.Properties.BGImage, not showVideo)
  UiElementBus.Event.SetIsEnabled(self.Properties.EmberEffect, not showVideo)
end
function LegalScreen:OnPlaybackStopped()
  if self.tickBusHandler == nil then
    self.tickBusHandler = TickBus.Connect(self)
    self.videoIsPlaying = false
    self:ShowVideoControls(false)
    self:ToggleElementsVisibilityAfterVideoEnd(true)
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Default)
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_First)
    self.audioHelper:PlaySound(self.audioHelper.PlayMenuMusic)
  end
end
function LegalScreen:CleanupVideo()
  if BinkRequestBus.Broadcast.IsPlaying() then
    BinkRequestBus.Broadcast.CloseVideoFile()
    self:ToggleElementsVisibilityAfterVideoEnd(true)
  end
end
function LegalScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self:CloseCodeOfConduct()
  self:CloseSeizureWarning()
  self.ftue = FtueSystemRequestBus.Broadcast.IsFtue()
  local isFirstRun = GameRequestsBus.Broadcast.IsFirstRun()
  if isFirstRun then
    local isPlaying = BinkRequestBus.Broadcast.IsPlaying()
    self:ShowVideoControls(isPlaying)
  else
    self:CloseCodeOfConduct()
    self:CloseSeizureWarning()
    LyShineManagerBus.Broadcast.SetState(3881446394)
    self.videoIsPlaying = false
    self:ToggleElementsVisibilityAfterVideoEnd(true)
    local ftueFlow = ConfigProviderEventBus.Broadcast.GetBool("javelin.use-new-character-creation-flow")
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Default)
    if not self.ftue and not ftueFlow then
      self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
      self.audioHelper:PlaySound(self.audioHelper.PlayMenuMusic)
    else
      self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
      self.audioHelper:PlaySound(self.audioHelper.PlayMenuMusic)
    end
  end
  if self.exitSurveyEnabled then
    local state = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled")
    self.EnableExitSurveyCheckbox:SetState(state)
  end
end
function LegalScreen:ToggleElementsVisibilityAfterVideoEnd(showElements)
  self.ButtonAccept:StartStopImageSequence(showElements)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonAccept, showElements)
  UiElementBus.Event.SetIsEnabled(self.Properties.VideoRenderTarget, not showElements)
  if self.exitSurveyEnabled then
    UiElementBus.Event.SetIsEnabled(self.Properties.EnableExitSurveyCheckbox, showElements)
  end
  if showElements then
    self:BeginBootFlow()
  end
end
function LegalScreen:OnLoadingScreenDismissed()
  local introCinematicDisabled = self.dataLayer:GetDataFromNode("UIFeatures.g_uiDisableIntroCinematic")
  if introCinematicDisabled then
    self:ToggleElementsVisibilityAfterVideoEnd(true)
    return
  end
  local isFirstRun = GameRequestsBus.Broadcast.IsFirstRun()
  if isFirstRun then
    UiImageBus.Event.SetRenderTargetName(self.Properties.VideoRenderTarget, "$AgsLogo")
    BinkRequestBus.Broadcast.SetUseRenderTarget(true)
    BinkRequestBus.Broadcast.PlayFromSource("@assets@/LyShineUI/Videos/AgsLogo.bk2", true)
    self.ScriptedEntityTweener:Play(self.Properties.VideoRenderTarget, 1, {opacity = 1, ease = "QuadOut"})
    if BinkRequestBus.Broadcast.IsPlaying() then
      self.videoIsPlaying = true
    else
      self:ShowVideoControls(false)
      self:ToggleElementsVisibilityAfterVideoEnd(true)
    end
  end
end
function LegalScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.ButtonAccept:StartStopImageSequence(false)
  GameRequestsBus.Broadcast.ClearFirstRun()
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function LegalScreen:OnAction(entityId, actionName)
  if BaseScreen.OnAction(self, entityId, actionName) then
    return
  end
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function LegalScreen:OnContinue()
  if self.hasPressedAccept then
    return
  end
  self.hasPressedAccept = true
  self:SetScreenVisible(false)
  local isFirstRun = GameRequestsBus.Broadcast.IsFirstRun()
  if isFirstRun then
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_First)
  else
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
  end
  self.audioHelper:PlaySound(self.audioHelper.Set_State_FrontEnd_News)
end
function LegalScreen:BeginBootFlow()
  if self.isBootFlowStarted then
    return
  end
  self.isBootFlowStarted = true
  local lastAcceptedConductVer = OptionsDataBus.Broadcast.GetCodeOfConductVersion()
  local currentConductVer = tonumber(LyShineScriptBindRequestBus.Broadcast.LocalizeText("@legal_codeofconduct_version"))
  local shouldShowSeizureWarning = self.requireCodeOfConduct and lastAcceptedConductVer < currentConductVer
  if self.showSeizureWarning and shouldShowSeizureWarning then
    self:ShowSeizureWarning()
  else
    self:CloseSeizureWarning()
    self:TryShowCodeOfConduct()
  end
end
function LegalScreen:SetScreenVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.BlackIntroReveal, 0.6, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.8
    })
  else
    local animDuration = 0.6
    self.ScriptedEntityTweener:Play(self.Properties.BlackIntroReveal, animDuration, {opacity = 0}, {
      opacity = 1,
      ease = "QuadIn",
      delay = self.fadeOutTime / 2,
      onComplete = function()
        LyShineManagerBus.Broadcast.SetState(3881446394)
      end
    })
  end
end
function LegalScreen:legalCancel(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.Cancel)
  GameRequestsBus.Broadcast.RequestDisconnect(eExitGameDestination_Desktop)
end
function LegalScreen:SeizureWarningAccept()
  self.SeizureWarning.AcceptButton:SetEnabled(false)
  self:CloseSeizureWarning(true)
end
function LegalScreen:CloseSeizureWarning(triggerCodeOfConduct)
  self.ScriptedEntityTweener:Play(self.Properties.SeizureWarning.Window, self.fadeOutTime, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.2,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.SeizureWarning.Window, false)
      if triggerCodeOfConduct then
        self:TryShowCodeOfConduct()
      end
    end
  })
end
function LegalScreen:ShowSeizureWarning()
  UiElementBus.Event.SetIsEnabled(self.Properties.SeizureWarning.Window, true)
  self.ScriptedEntityTweener:Play(self.Properties.SeizureWarning.Window, 0.3, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
end
function LegalScreen:codeOfConductAccept()
  self.CodeOfConduct.AcceptButton:SetEnabled(false)
  local isFirstRun = GameRequestsBus.Broadcast.IsFirstRun()
  if isFirstRun then
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_First)
  else
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
  end
  local currentConductVer = tonumber(LyShineScriptBindRequestBus.Broadcast.LocalizeText("@legal_codeofconduct_version"))
  OptionsDataBus.Broadcast.SetCodeOfConductVersion(currentConductVer)
  self:CloseCodeOfConduct()
  timingUtils:Delay(self.fadeOutTime, self, function(self)
    self:SetScreenVisible(true)
  end)
end
function LegalScreen:codeOfConductCancel()
  self.audioHelper:PlaySound(self.audioHelper.Cancel)
  self:CloseCodeOfConduct()
end
function LegalScreen:TryShowCodeOfConduct()
  local lastAcceptedConductVer = OptionsDataBus.Broadcast.GetCodeOfConductVersion()
  local currentConductVer = tonumber(LyShineScriptBindRequestBus.Broadcast.LocalizeText("@legal_codeofconduct_version"))
  local shouldShowCodeOfConduct = self.requireCodeOfConduct and lastAcceptedConductVer < currentConductVer
  if not shouldShowCodeOfConduct then
    self:CloseCodeOfConduct()
    self:SetScreenVisible(true)
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CodeOfConduct.Window, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.Black, true)
  self.ScriptedEntityTweener:Play(self.Properties.Black, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CodeOfConduct.Window, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.CodeOfConduct.DividerTop:SetVisible(true, 1, {delay = 0.1})
  self.CodeOfConduct.DividerBottom:SetVisible(true, 1, {delay = 0.1})
end
function LegalScreen:CloseCodeOfConduct()
  self.ScriptedEntityTweener:Play(self.Properties.Black, self.fadeOutTime, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.ScriptedEntityTweener:Play(self.Properties.CodeOfConduct.Window, self.fadeOutTime, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    delay = 0.2,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.CodeOfConduct.Window, false)
      self.CodeOfConduct.DividerTop:SetVisible(false, 0)
      self.CodeOfConduct.DividerBottom:SetVisible(false, 0)
    end
  })
end
function LegalScreen:ShowTerms()
  self.audioHelper:PlaySound(self.audioHelper.OnClick)
  OptionsDataBus.Broadcast.OpenTermsInBrowser()
end
function LegalScreen:ShowPrivacy()
  self.audioHelper:PlaySound(self.audioHelper.OnClick)
  OptionsDataBus.Broadcast.OpenPrivacyInBrowser()
end
function LegalScreen:ShowNotices()
  self.audioHelper:PlaySound(self.audioHelper.OnClick)
  OptionsDataBus.Broadcast.OpenNoticesInBrowser()
end
function LegalScreen:OpenCodeofConductInBrowser()
  self.audioHelper:PlaySound(self.audioHelper.OnClick)
  OptionsDataBus.Broadcast.OpenCodeOfConductInBrowser()
end
function LegalScreen:OnHoverLink()
  self.ScriptedEntityTweener:Play(self.Properties.CodeOfConduct.CodeOfConductLink, 0.1, {
    textColor = self.UIStyle.COLOR_WHITE
  })
end
function LegalScreen:OnUnhoverLink()
  self.ScriptedEntityTweener:Play(self.Properties.CodeOfConduct.CodeOfConductLink, 0.1, {
    textColor = self.UIStyle.COLOR_YELLOW
  })
end
function LegalScreen:OnHoverStart(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LegalScreen)
end
function LegalScreen:OnEnableExitSurveyChanged(isChecked)
  if not self.exitSurveyEnabled then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled", isChecked)
  OptionsDataBus.Broadcast.SerializeOptions()
end
function LegalScreen:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.SeizureWarning.SeizureBg, self.canvasId)
  end
end
return LegalScreen
