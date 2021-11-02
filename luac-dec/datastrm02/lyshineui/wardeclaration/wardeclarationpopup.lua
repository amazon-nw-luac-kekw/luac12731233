local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local WarDeclarationPopup = {
  Properties = {
    DeclareScreenHolder = {
      default = EntityId()
    },
    DeclareTitle = {
      default = EntityId()
    },
    DeclareMessage = {
      default = EntityId()
    },
    DeclareIconBgCircle = {
      default = EntityId()
    },
    DeclareIconBgDiamond = {
      default = EntityId()
    },
    DeclareIconBgSwordTop = {
      default = EntityId()
    },
    DeclareIconBgSwordLeft = {
      default = EntityId()
    },
    DeclareIconBgSwordRight = {
      default = EntityId()
    },
    DeclareImage1 = {
      default = EntityId()
    },
    DeclareImage2 = {
      default = EntityId()
    },
    DeclareImage3 = {
      default = EntityId()
    },
    DeclareImageText1 = {
      default = EntityId()
    },
    DeclareImageText2 = {
      default = EntityId()
    },
    DeclareImageText3 = {
      default = EntityId()
    },
    DeclareButtonCancel = {
      default = EntityId()
    },
    DeclareButtonAccept = {
      default = EntityId()
    },
    SiegeScreenHolder = {
      default = EntityId()
    },
    SiegeTitle = {
      default = EntityId()
    },
    SiegeMessage = {
      default = EntityId()
    },
    SiegeIconHandCenter = {
      default = EntityId()
    },
    SiegeIconHandSmall = {
      default = EntityId()
    },
    SiegeIconHandBig = {
      default = EntityId()
    },
    SiegeIconBg = {
      default = EntityId()
    },
    SiegeTimeBg = {
      default = EntityId()
    },
    SiegeTimeTitle = {
      default = EntityId()
    },
    SiegeTimeData = {
      default = EntityId()
    },
    SiegeWarCampRadioGroup = {
      default = EntityId()
    },
    SiegeWarCamp1 = {
      default = EntityId()
    },
    SiegeWarCamp2 = {
      default = EntityId()
    },
    SiegeWarCamp3 = {
      default = EntityId()
    },
    SiegeButtonCancel = {
      default = EntityId()
    },
    SiegeButtonAccept = {
      default = EntityId()
    },
    ConfirmationScreenHolder = {
      default = EntityId()
    },
    ConfirmationTitle = {
      default = EntityId()
    },
    ConfirmationMessage = {
      default = EntityId()
    },
    ConfirmationIconBgCircle = {
      default = EntityId()
    },
    ConfirmationIconBgDiamond = {
      default = EntityId()
    },
    ConfirmationIconBgSwordTop = {
      default = EntityId()
    },
    ConfirmationIconBgSwordLeft = {
      default = EntityId()
    },
    ConfirmationIconBgSwordRight = {
      default = EntityId()
    },
    ConfirmationImage = {
      default = EntityId()
    },
    ConfirmationButtonExit = {
      default = EntityId()
    },
    SelectPaymentPopup = {
      default = EntityId()
    },
    WalletContainer = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    }
  },
  territoryId = 0,
  guildId = GuildId(),
  allowDebug = false,
  debugAtWar = -1,
  isAtWar = false,
  expectedWarCost = 0,
  expectedSiegeWindow = 0,
  epoch = WallClockTimePoint(),
  tickTimer = 1,
  declareWarButtonTemplate = "@ui_wardeclarationpopup_declarebutton",
  coinIconPath = "LyShineUI\\Images\\Icon_Crown",
  coinIconXPadding = 5,
  receivedUpdatedWarInfo = false,
  SCREEN_STATE_DECLARE = 0,
  SCREEN_STATE_SIEGE = 1,
  SCREEN_STATE_SELECTION = 2,
  SCREEN_STATE_CONFIRMATION = 3,
  currentScreen = nil,
  previousScreen = nil,
  currentState = nil,
  previousState = nil,
  screenScaleForward = 1.3,
  screenScaleBackward = 0.7,
  selectedCampEntityId = nil,
  selectedCampEntityTable = nil,
  warCampData = {},
  selectedCampId = 0,
  waitingForDeclarationResult = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WarDeclarationPopup)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function WarDeclarationPopup:OnInit()
  BaseScreen.OnInit(self)
  self.timeHelpers = timeHelpers
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.panelTypes = mapTypes.panelTypes
  self.notificationAcceptBind = LyShineManagerBus.Broadcast.GetKeybind("notificationAccept", "notification")
  self:SetVisualElements()
  self:InitializeWarCampData()
  self.dataLayer:RegisterOpenEvent("WarDeclarationPopup", self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableNewWarDec", function(self, enableNewWarDec)
    self.enableNewWarDec = enableNewWarDec
  end)
end
function WarDeclarationPopup:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", self.UpdateCurrency)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", self.UpdateGuildWarState)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self, warId)
    if not warId then
      return
    end
    self:UpdateGuildWarState()
    if self.waitingForDeclarationResult then
      self:OnLastModifiedGuildWar(warId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Rank", function(self, rank)
    self:UpdateWarCost()
  end)
end
function WarDeclarationPopup:UnregisterObservers()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Id")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Rank")
end
function WarDeclarationPopup:OnShutdown()
  BaseScreen.OnShutdown(self)
  self.socialDataHandler:OnDeactivate()
end
function WarDeclarationPopup:InitializeWarCampData()
  self.warCampData = {
    {
      campId = 0,
      deploymentLimit = 6,
      siegeSupplyRate = "@ui_normal"
    },
    {
      campId = 1,
      deploymentLimit = 8,
      siegeSupplyRate = "@ui_high"
    },
    {
      campId = 2,
      deploymentLimit = 10,
      siegeSupplyRate = "@ui_highest"
    }
  }
  local limitData = PlayerDataManagerBus.Broadcast.GetWarDeployableLimitData(3278957618)
  for _, campData in ipairs(self.warCampData) do
    local attackerTeam = true
    campData.deploymentLimit = limitData:GetLimit(attackerTeam, campData.campId)
  end
  for i = 1, #self.warCampData do
    local currentWarCampItem = self["SiegeWarCamp" .. i]
    currentWarCampItem:SetData(self.warCampData[i])
    currentWarCampItem:SetCallback(self.OnCampItemSelected, self)
  end
end
function WarDeclarationPopup:SetVisualElements()
  local titleTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 46,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local messageTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  local imageTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  local seigeTimeTitleTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  local seigeTimeDataTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
    fontSize = 40,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.Properties.DeclareTitle, titleTextStyle)
  SetTextStyle(self.Properties.DeclareMessage, messageTextStyle)
  SetTextStyle(self.Properties.DeclareImageText1, imageTextStyle)
  SetTextStyle(self.Properties.DeclareImageText2, imageTextStyle)
  SetTextStyle(self.Properties.DeclareImageText3, imageTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DeclareTitle, "@ui_wardeclarationpopup_declare_title", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DeclareMessage, "@ui_wardeclarationpopup_declare_message", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DeclareImageText1, "@ui_wardeclarationpopup_declare_image_war", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DeclareImageText2, "@ui_wardeclarationpopup_declare_image_attack", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DeclareImageText3, "@ui_wardeclarationpopup_declare_image_territory", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.SiegeTitle, titleTextStyle)
  SetTextStyle(self.Properties.SiegeMessage, messageTextStyle)
  SetTextStyle(self.Properties.SiegeTimeTitle, seigeTimeTitleTextStyle)
  SetTextStyle(self.Properties.SiegeTimeData, seigeTimeDataTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeTitle, "@ui_wardeclarationpopup_siege_title", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeMessage, "@ui_wardeclarationpopup_siege_message", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeTimeTitle, "@ui_wardeclarationpopup_siege_time_title", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.ConfirmationTitle, titleTextStyle)
  SetTextStyle(self.Properties.ConfirmationMessage, messageTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ConfirmationTitle, "@ui_wardeclarationpopup_confirmation_title", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ConfirmationMessage, "@ui_wardeclarationpopup_confirmation_message", eUiTextSet_SetLocalized)
  self.DeclareButtonCancel:SetText("@ui_cancel")
  self.DeclareButtonCancel:SetCallback(self.OnCancel, self)
  self.DeclareButtonAccept:SetText("@ui_start")
  self.DeclareButtonAccept:SetCallback(function()
    self:SetScreenState(self.currentState + 1)
  end, self)
  self.DeclareButtonAccept:SetButtonStyle(self.DeclareButtonAccept.BUTTON_STYLE_CTA)
  self.SiegeButtonCancel:SetText("@ui_back")
  self.SiegeButtonCancel:SetCallback(function()
    self:SetScreenState(self.currentState - 1)
  end, self)
  self.SiegeButtonAccept:SetText("@ui_wardeclarationpopup_siege_selection_action")
  self.SiegeButtonAccept:SetCallback(function()
    self:SetScreenState(self.currentState + 1)
  end, self)
  self.SiegeButtonAccept:SetButtonStyle(self.SiegeButtonAccept.BUTTON_STYLE_CTA)
  self.ConfirmationButtonExit:SetText("@ui_exit")
  self.ConfirmationButtonExit:SetCallback("OnCancel", self)
  self.ConfirmationButtonExit:SetButtonStyle(self.ConfirmationButtonExit.BUTTON_STYLE_CTA)
  if self.allowDebug then
    timingUtils:Delay(1, self, function()
      self.ScriptedEntityTweener:Set(self.Properties.DeclareScreenHolder, {
        opacity = 0,
        scaleX = self.screenScaleBackward,
        scaleY = self.screenScaleBackward
      })
      self.ScriptedEntityTweener:Set(self.Properties.SiegeScreenHolder, {
        opacity = 0,
        scaleX = self.screenScaleBackward,
        scaleY = self.screenScaleBackward
      })
      self.ScriptedEntityTweener:Set(self.Properties.ConfirmationScreenHolder, {
        opacity = 0,
        scaleX = self.screenScaleBackward,
        scaleY = self.screenScaleBackward
      })
      self:SetScreenState(self.SCREEN_STATE_DECLARE)
    end)
  end
end
function WarDeclarationPopup:SetScreenState(screenState)
  self.previousButton1 = self.button1
  self.previousButton2 = self.button2
  if self.SCREEN_STATE_DECLARE == screenState then
    self.previousScreen = self.currentScreen
    self.currentScreen = self.Properties.DeclareScreenHolder
    self.previousState = self.currentState
    self.currentState = self.SCREEN_STATE_DECLARE
    self.setVisibleCallback = self.SetDeclareScreenVisible
    self.setTransition = true
    self.currentButton1 = self.Properties.DeclareButtonCancel
    self.currentButton2 = self.Properties.DeclareButtonAccept
  elseif self.SCREEN_STATE_SIEGE == screenState then
    self.previousScreen = self.currentScreen
    self.currentScreen = self.Properties.SiegeScreenHolder
    self.previousState = self.currentState
    self.currentState = self.SCREEN_STATE_SIEGE
    self.setVisibleCallback = self.SetSiegeScreenVisible
    self.setTransition = self.previousState ~= self.SCREEN_STATE_SELECTION
    self.currentButton1 = self.Properties.SiegeButtonCancel
    self.currentButton2 = self.Properties.SiegeButtonAccept
  elseif self.SCREEN_STATE_SELECTION == screenState then
    self.previousScreen = self.currentScreen
    self.currentScreen = self.Properties.SiegeScreenHolder
    self.previousState = self.currentState
    self.currentState = self.SCREEN_STATE_SELECTION
    self.setVisibleCallback = self.SetSelectionScreenVisible
    self.setTransition = self.previousState == self.SCREEN_STATE_CONFIRMATION
    self.currentButton1 = self.Properties.SiegeButtonCancel
    self.currentButton2 = self.Properties.SiegeButtonAccept
  elseif self.SCREEN_STATE_CONFIRMATION == screenState then
    self.previousScreen = self.currentScreen
    self.currentScreen = self.Properties.ConfirmationScreenHolder
    self.previousState = self.currentState
    self.currentState = self.SCREEN_STATE_CONFIRMATION
    self.setVisibleCallback = self.SetConfirmationScreenVisible
    self.setTransition = true
    self.currentButton1 = self.Properties.ConfirmationButtonExit
    self.currentButton2 = nil
  end
  if self.previousButton1 then
    UiInteractableBus.Event.SetIsHandlingEvents(self.previousButton1, false)
  end
  if self.previousButton2 then
    UiInteractableBus.Event.SetIsHandlingEvents(self.previousButton2, false)
  end
  if self.button1 then
    UiInteractableBus.Event.SetIsHandlingEvents(self.currentButton1, true)
  end
  if self.button2 then
    UiInteractableBus.Event.SetIsHandlingEvents(self.currentButton2, true)
  end
  local animDuration = 0.2
  local isForward = self.previousState == nil or self.currentState > self.previousState
  local directionScale = isForward and self.screenScaleForward or self.screenScaleBackward
  if self.setTransition then
    UiElementBus.Event.SetIsEnabled(self.currentScreen, true)
    self.ScriptedEntityTweener:Play(self.currentScreen, 0.5, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.currentScreen, animDuration, {
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    if self.previousScreen then
      self.ScriptedEntityTweener:Play(self.previousScreen, 0.15, {opacity = 0, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.previousScreen, animDuration, {
        scaleX = directionScale,
        scaleY = directionScale,
        ease = "QuadOut",
        onComplete = function()
          if self.previousState ~= self.SCREEN_STATE_SIEGE and self.currentState ~= self.SCREEN_STATE_SELECTION then
            UiElementBus.Event.SetIsEnabled(self.previousScreen, false)
          end
        end
      })
    end
  end
  self:SetIsCampSelectButtonsHandlingEvents(self.currentState == self.SCREEN_STATE_SELECTION)
  self:setVisibleCallback(true)
end
function WarDeclarationPopup:SetDeclareScreenVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgCircle, 20, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgCircle, 0.3, {scaleX = 0.5, scaleY = 0.5}, {
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgDiamond, 0.25, {
      opacity = 0,
      scaleX = 0.5,
      scaleY = 0.5
    }, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut",
      delay = 0.1
    })
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgSwordLeft, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgSwordLeft, 0.3, {x = -20, y = 25}, {
      x = 0,
      y = 0,
      ease = "BackOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgSwordRight, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.DeclareIconBgSwordRight, 0.3, {x = 20, y = 25}, {
      x = 0,
      y = 0,
      ease = "BackOut",
      delay = 0.2
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.DeclareScreenHolder, false)
    self.ScriptedEntityTweener:Set(self.Properties.DeclareScreenHolder, {
      opacity = 0,
      scaleX = self.screenScaleBackward,
      scaleY = self.screenScaleBackward
    })
  end
end
function WarDeclarationPopup:SetSiegeScreenVisible(isVisible)
  if isVisible then
    UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeTitle, "@ui_wardeclarationpopup_siege_title", eUiTextSet_SetLocalized)
    self.SiegeButtonAccept:SetText("@ui_wardeclarationpopup_siege_selection_action")
    self.SiegeButtonAccept:SetCallback(function()
      self:SetScreenState(self.currentState + 1)
    end, self)
    self.SiegeButtonAccept:SetEnabled(true)
    if self.previousState ~= self.SCREEN_STATE_SELECTION then
      local clockSpeed = 5
      self.ScriptedEntityTweener:Play(self.Properties.SiegeIconBg, 20, {rotation = 0}, {timesToPlay = -1, rotation = -359})
      self.ScriptedEntityTweener:Play(self.Properties.SiegeIconBg, 0.3, {scaleX = 0.5, scaleY = 0.5}, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.SiegeIconHandCenter, 0.6, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.SiegeIconHandBig, clockSpeed, {rotation = 0}, {timesToPlay = -1, rotation = 359})
      self.ScriptedEntityTweener:Play(self.Properties.SiegeIconHandSmall, clockSpeed * 7, {rotation = 0}, {timesToPlay = -1, rotation = 359})
    end
    self.ScriptedEntityTweener:Play(self.Properties.SiegeMessage, 0.3, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeTitle, 0.3, {
      opacity = 1,
      y = 0,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeData, 0.25, {
      y = 0,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeBg, 0.3, {h = 200, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeWarCamp1, 0.1, {
      opacity = 0,
      scaleX = 0.75,
      scaleY = 0.75,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeWarCamp2, 0.1, {
      opacity = 0,
      scaleX = 0.75,
      scaleY = 0.75,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeWarCamp3, 0.1, {
      opacity = 0,
      scaleX = 0.75,
      scaleY = 0.75,
      ease = "QuadOut"
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.SiegeScreenHolder, false)
    self.ScriptedEntityTweener:Set(self.Properties.SiegeScreenHolder, {
      opacity = 0,
      scaleX = self.screenScaleBackward,
      scaleY = self.screenScaleBackward
    })
    self.ScriptedEntityTweener:Set(self.Properties.SiegeMessage, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.SiegeTimeTitle, {opacity = 1, y = 0})
    self.ScriptedEntityTweener:Set(self.Properties.SiegeTimeData, {
      y = 0,
      scaleX = 1,
      scaleY = 1
    })
    self.ScriptedEntityTweener:Set(self.Properties.SiegeTimeBg, {h = 200})
  end
end
function WarDeclarationPopup:SetSelectionScreenVisible(isVisible)
  if isVisible then
    UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeTitle, "@ui_wardeclarationpopup_siege_selection_title", eUiTextSet_SetLocalized)
    if self.selectedCampEntityId and self.selectedCampEntityId:IsValid() then
      self.SiegeButtonAccept:SetCallback(function()
        self:OnAccept()
        self:SetScreenState(self.currentState + 1)
      end, self)
      self:UpdateWarCostText(self.expectedWarCost)
      self:UpdateAcceptButton(self.expectedWarCost)
    else
      self.SiegeButtonAccept:SetEnabled(false)
    end
    self.ScriptedEntityTweener:Play(self.Properties.SiegeMessage, 0.25, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeTitle, 0.28, {y = -250, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeTitle, 0.2, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeData, 0.28, {
      y = -260,
      scaleX = 0.75,
      scaleY = 0.75,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeTimeBg, 0.3, {h = 420, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.SiegeWarCamp1, 0.35, {scaleX = 0.75, scaleY = 0.75}, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut",
      delay = 0
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeWarCamp2, 0.35, {scaleX = 0.75, scaleY = 0.75}, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut",
      delay = 0
    })
    self.ScriptedEntityTweener:Play(self.Properties.SiegeWarCamp3, 0.35, {scaleX = 0.75, scaleY = 0.75}, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut",
      delay = 0
    })
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.SiegeScreenHolder, false)
    self.ScriptedEntityTweener:Set(self.Properties.SiegeScreenHolder, {
      opacity = 0,
      scaleX = self.screenScaleBackward,
      scaleY = self.screenScaleBackward
    })
  end
end
function WarDeclarationPopup:SetConfirmationScreenVisible(isVisible)
  if isVisible then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.SiegeButtonCancel, true)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.SiegeButtonAccept, true)
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgCircle, 20, {rotation = 0}, {timesToPlay = -1, rotation = -359})
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgCircle, 0.3, {scaleX = 0.5, scaleY = 0.5}, {
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgDiamond, 0.25, {
      opacity = 0,
      scaleX = 0.5,
      scaleY = 0.5
    }, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadOut",
      delay = 0.1
    })
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgSwordLeft, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgSwordLeft, 0.3, {x = -20, y = 25}, {
      x = 0,
      y = 0,
      ease = "BackOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgSwordRight, 0.4, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.ConfirmationIconBgSwordRight, 0.3, {x = 20, y = 25}, {
      x = 0,
      y = 0,
      ease = "BackOut",
      delay = 0.2
    })
    self.audioHelper:PlaySound(self.audioHelper.Screen_WarDeclarationConfirm)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ConfirmationScreenHolder, false)
    self.ScriptedEntityTweener:Set(self.Properties.ConfirmationScreenHolder, {
      opacity = 0,
      scaleX = self.screenScaleBackward,
      scaleY = self.screenScaleBackward
    })
  end
end
function WarDeclarationPopup:SetIsCampSelectButtonsHandlingEvents(isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.SiegeWarCamp1, isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.SiegeWarCamp2, isHandlingEvents)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.SiegeWarCamp3, isHandlingEvents)
end
function WarDeclarationPopup:OnCampItemSelected(itemData)
  self.selectedCampId = itemData.campId
  self:UpdateWarCostText(itemData.cost)
  self:UpdateAcceptButton(itemData.cost)
end
function WarDeclarationPopup:UpdateWarCost()
  local guildIdValid = self.guildId and self.guildId:IsValid()
  if not guildIdValid then
    return
  end
  local warCostSuccessCallback = function(self, warDeclarationCost)
    if not self.receivedUpdatedWarInfo then
      self.expectedWarCost = warDeclarationCost
    end
    self:UpdateWarCostText(self.expectedWarCost)
    self:UpdateAcceptButton(self.expectedWarCost)
  end
  self.socialDataHandler:GetWarCost_ServerCall(self, warCostSuccessCallback, nil, self.guildId, self.selectedCampId)
  self:UpdateCampTierCosts()
end
function WarDeclarationPopup:UpdateCampTierCosts()
  local campsToUpdate = {
    self.SiegeWarCamp1,
    self.SiegeWarCamp2,
    self.SiegeWarCamp3
  }
  for i, campTable in ipairs(campsToUpdate) do
    self.socialDataHandler:GetWarCost_ServerCall(self, function(self, warDeclarationCost)
      campTable:SetWarCampCost(warDeclarationCost)
    end, nil, self.guildId, i - 1)
  end
end
function WarDeclarationPopup:UpdateWarCostText(warCost)
  self.expectedWarCost = warCost
  local warCostText = GetLocalizedCurrency(warCost)
  local numberFont = self.UIStyle.FONT_FAMILY_CASLON
  local coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\"></img>", self.coinIconPath, self.coinIconXPadding)
  local enabledCostColor = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE)
  local disabledCostColor = ColorRgbaToHexString(self.UIStyle.COLOR_INSUFFICIENT_QUANTITY)
  local enabledCostText = string.format("<font color=%s face=\"%s\">%s</font>", enabledCostColor, numberFont, warCostText)
  local disabledCostText = string.format("<font color=%s face=\"%s\">%s</font>", disabledCostColor, numberFont, warCostText)
  local keys = vector_basic_string_char_char_traits_char()
  keys:push_back("coinImage")
  keys:push_back("cost")
  local values = vector_basic_string_char_char_traits_char()
  values:push_back(coinImgText)
  values:push_back(enabledCostText)
  self.enabledDeclareWarButtonText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(self.declareWarButtonTemplate, keys, values)
  values[2] = disabledCostText
  self.disabledDeclareWarButtonText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(self.declareWarButtonTemplate, keys, values)
end
function WarDeclarationPopup:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WarDeclarationPopup.GuildId")
  self.guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WarDeclarationPopup.GuildName")
  self.guildCrest = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WarDeclarationPopup.GuildCrest")
  self.territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.WarDeclarationPopup.TerritoryId")
  if self.territoryId == nil then
    self.territoryId = 0
  end
  self.receivedUpdatedWarInfo = false
  self.waitingForDeclarationResult = false
  self:RegisterObservers()
  self.prevWarPhase = nil
  local guildIdValid = self.guildId and self.guildId:IsValid()
  local isDebug = self.allowDebug and not guildIdValid
  if guildIdValid or isDebug then
    self:SetData()
  else
    Debug.Log("[WarDeclarationPopup] Error: Invalid guildId " .. tostring(self.guildId))
  end
  self.keyInputNotificationBus = self:BusConnect(KeyInputNotificationBus)
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  self.currentScreen = nil
  self.previousScreen = nil
  self.currentState = nil
  self.previousState = nil
  if self.selectedCampEntityId and self.selectedCampEntityId:IsValid() then
    UiRadioButtonGroupBus.Event.SetAllowUncheck(self.Properties.SiegeWarCampRadioGroup, true)
    UiRadioButtonGroupBus.Event.SetState(self.Properties.SiegeWarCampRadioGroup, self.selectedCampEntityId, false)
    UiRadioButtonGroupBus.Event.SetAllowUncheck(self.Properties.SiegeWarCampRadioGroup, false)
    self.selectedCampEntityTable:OnUnfocus()
    self.selectedCampEntityId = nil
    self.selectedCampEntityTable = nil
  end
  self:SetDeclareScreenVisible(false)
  self:SetSiegeScreenVisible(false)
  self:SetConfirmationScreenVisible(false)
  self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.3, {opacity = 0}, {opacity = 0.9, ease = "QuadOut"})
  self:SetScreenState(self.SCREEN_STATE_DECLARE)
end
function WarDeclarationPopup:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.ScriptedEntityTweener:Stop(self.Properties.DeclareIconBgCircle)
  self.ScriptedEntityTweener:Stop(self.Properties.SiegeIconBg)
  self.ScriptedEntityTweener:Stop(self.Properties.SiegeIconHandSmall)
  self.ScriptedEntityTweener:Stop(self.Properties.SiegeIconHandBig)
  self.ScriptedEntityTweener:Stop(self.Properties.ConfirmationIconBgCircle)
  self:UnregisterObservers()
  self:StopTick()
  self:BusDisconnect(self.keyInputNotificationBus)
end
function WarDeclarationPopup:OnKeyReleased(keyName)
  if keyName ~= "mouse1" and keyName ~= "mouse2" and keyName ~= self.notificationAcceptBind then
    self:OnCancel()
  end
end
function WarDeclarationPopup:UpdateGuildWarState()
  self.isAtWar = IsAtWarWithGuild(self.guildId)
  local warId = WarDataClientRequestBus.Broadcast.GetWarId(self.guildId)
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  if self.isAtWar then
    local warPhase = warDetails:GetWarPhase()
    if warPhase == eWarPhase_War or warPhase == eWarPhase_Conquest then
      self:OnCancel()
      return
    end
    self.prevWarPhase = warPhase
  elseif self.prevWarPhase and self.prevWarPhase == eWarPhase_Resolution then
    self:OnCancel()
    return
  end
  self.socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
    local guildData
    if 0 < #result then
      guildData = type(result[1]) == "table" and result[1].guildData or result[1]
    else
      Log("ERR - WarDeclarationPopup:UpdateGuildWarState: GuildData request returned with no data")
      return
    end
    if guildData and guildData:IsValid() and not self.receivedUpdatedWarInfo then
      self.expectedSiegeWindow = guildData.siegeWindow
      local siegeTime = dominionCommon:GetNextSiegeWindowText(self.expectedSiegeWindow, false, true)
      UiTextBus.Event.SetText(self.Properties.SiegeTimeData, siegeTime)
    end
  end, self.GuildRequestFailed, self.guildId)
  self.warEndTimePoint = WarRequestBus.Broadcast.GetWarEndTime(warId)
  self:UpdateWarCost()
end
function WarDeclarationPopup:GuildRequestFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - GuildMenu:AllGuildsRequestFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - GuildMenu:AllGuildsRequestFailed: Timed Out")
  end
end
function WarDeclarationPopup:SetData()
  self:UpdateGuildWarState()
  if self.allowDebug and self.guildId == self.debugAtWar then
    self.isAtWar = true
  end
  self:StartTick()
end
function WarDeclarationPopup:UpdateAcceptButton(warCost)
  self.selectedCampEntityId = UiRadioButtonGroupBus.Event.GetState(self.Properties.SiegeWarCampRadioGroup)
  if self.selectedCampEntityId:IsValid() then
    self.selectedCampEntityTable = self.registrar:GetEntityTable(self.selectedCampEntityId)
    warCost = self.selectedCampEntityTable:GetWarCampCost()
    if self.currentState == self.SCREEN_STATE_SELECTION then
      local hasEnoughGold = warCost <= self.currencyAmount or warCost <= self.companyCurrencyAmount
      self.SiegeButtonAccept:SetText(self:GetAcceptButtonText(hasEnoughGold, self.isAtWar))
      local warCampTier = self.selectedCampId
      local canDeclareWarResult = WarRequestBus.Broadcast.CanDeclareWar(self.guildId, self.territoryId, warCampTier)
      local isEnabled = canDeclareWarResult == eCanDeclareWarReturnResult_Success
      self.SiegeButtonAccept:SetEnabled(isEnabled)
      self.SiegeButtonAccept:SetCallback(self.OnAccept, self)
      local tooltipText
      if not isEnabled then
        if canDeclareWarResult == eCanDeclareWarReturnResult_NotInAGuild then
          tooltipText = "@ui_war_declare_fail_notInAGuild"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailOwnGuild then
          tooltipText = "@ui_war_declare_fail_ownguild"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailAlreadyAtWar then
          tooltipText = "@ui_war_declare_fail_alreadyAtWar"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailAlreadyInLottery then
          tooltipText = "@ui_war_declare_fail_alreadyInLottery"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_InvasionScheduled then
          tooltipText = "@ui_war_declare_fail_invasionScheduled"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailNoPlayerComponent then
          tooltipText = "@ui_war_declare_fail_noPlayerComponent"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailNoCurrency then
          tooltipText = "@ui_war_declare_fail_NoCurrency"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailNoFaction then
          tooltipText = "@ui_war_declare_fail_NoFaction"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailSameFaction then
          tooltipText = "@ui_war_declare_fail_SameFaction"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailDefenderNoTerritory then
          tooltipText = "@ui_war_declare_fail_NoTerritory"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailBeforeSiegeWindow then
          tooltipText = "@ui_war_declare_fail_beforeSiegeWindow"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailPastSiegeWindow then
          tooltipText = "@ui_war_declare_fail_afterSiegeWindow"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailNoPrivilege then
          tooltipText = "@ui_war_declare_fail_noPermissions"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_FailNoConflictState then
          tooltipText = "@ui_war_declare_fail_noConflictState"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_WarDisabled then
          tooltipText = "@ui_war_declare_fail_warDisabled"
        elseif canDeclareWarResult == eCanDeclareWarReturnResult_InsufficientContribution then
          tooltipText = "@ui_war_declare_fail_InsufficientContribution"
        end
      end
      self.SiegeButtonAccept:SetTooltip(tooltipText)
    end
  end
end
function WarDeclarationPopup:GetAcceptButtonText(isEnabled, isAtWar)
  if isEnabled then
    return self.enabledDeclareWarButtonText
  else
    return self.disabledDeclareWarButtonText
  end
end
function WarDeclarationPopup:OnTick(deltaTime, timePoint)
  self.tickTimer = self.tickTimer + deltaTime
  if self.tickTimer > 1 then
    self.tickTimer = 0
    if not self.isAtWar then
      self:SetData()
    end
  end
end
function WarDeclarationPopup:StartTick()
  if self.tickBusHandler == nil then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function WarDeclarationPopup:StopTick()
  self:BusDisconnect(self.tickBusHandler)
  self.tickBusHandler = nil
end
function WarDeclarationPopup:UpdateCurrency(currencyAmount)
  self.currencyAmount = currencyAmount or 0
  self.socialDataHandler:GetTreasuryData_ServerCall(self, function(self, treasuryData)
    self.companyCurrencyAmount = treasuryData.currentFunds or 0
    self.WalletContainer:SetCurrencyAmount(self.currencyAmount)
    self:UpdateWarCost()
  end, nil)
end
function WarDeclarationPopup:OnAccept()
  self:OnSelectPaymentClicked()
end
function WarDeclarationPopup:OnSelectPaymentClicked()
  self.SelectPaymentPopup:ShowPaymentOptionPopup(self.expectedWarCost, self.OnConfirmPayout, self)
end
function WarDeclarationPopup:OnConfirmPayout(useCompanyWallet)
  if self.isAtWar then
    return
  end
  local socialEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.SocialEntityId")
  self.socialNotificationsHandler = self:BusConnect(SocialNotificationsBus, socialEntityId)
  WarRequestBus.Broadcast.RequestDeclareWar(self.guildId, self.expectedWarCost, self.expectedSiegeWindow, self.territoryId, self.selectedCampId, useCompanyWallet)
  self.SiegeButtonAccept:SetEnabled(false)
  self.waitingForDeclarationResult = true
end
function WarDeclarationPopup:OnWarDeclarationFailed(warId, warCost, siegeWindow)
  self.receivedUpdatedWarInfo = true
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_wardeclarationpopup_unknown"
  if self.expectedSiegeWindow ~= siegeWindow and self.expectedWarCost ~= warCost then
    notificationData.text = "@ui_wardeclarationpopup_siegewindow_and_warcost_changed"
  elseif self.expectedWarCost ~= warCost then
    notificationData.text = "@ui_wardeclarationpopup_warcost_changed"
  elseif self.expectedSiegeWindow ~= siegeWindow then
    notificationData.text = "@ui_wardeclarationpopup_siegewindow_changed"
  end
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  self.expectedSiegeWindow = siegeWindow
  self.expectedWarCost = warCost
  if self.socialNotificationsHandler then
    self:BusDisconnect(self.socialNotificationsHandler)
    self.socialNotificationsHandler = nil
  end
  self.SiegeButtonAccept:SetEnabled(true)
  self.waitingForDeclarationResult = false
  self:UpdateGuildWarState()
  self:UpdateWarCostText(warCost)
  self:UpdateAcceptButton(warCost)
  self:UpdateCampTierCosts()
  self:SetData()
end
function WarDeclarationPopup:OnWarDeclarationPending(defendingGuildId, territoryId)
  if self.socialNotificationsHandler then
    self:BusDisconnect(self.socialNotificationsHandler)
    self.socialNotificationsHandler = nil
  end
  self:SetScreenState(self.SCREEN_STATE_CONFIRMATION)
end
function WarDeclarationPopup:OnWarDeclarationSuccessful(warId)
  if self.socialNotificationsHandler then
    self:BusDisconnect(self.socialNotificationsHandler)
    self.socialNotificationsHandler = nil
  end
  self:SetScreenState(self.SCREEN_STATE_CONFIRMATION)
end
function WarDeclarationPopup:OnWarDeclarationUnsuccessful(defendingGuildId, territoryId)
  self.receivedUpdatedWarInfo = true
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = "@ui_wardeclaration_unsuccessful_notification_text"
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  if self.socialNotificationsHandler then
    self:BusDisconnect(self.socialNotificationsHandler)
    self.socialNotificationsHandler = nil
  end
  self.SiegeButtonAccept:SetEnabled(true)
  self.waitingForDeclarationResult = false
  self:UpdateGuildWarState()
  self:UpdateWarCostText(self.expectedWarCost)
  self:UpdateAcceptButton(self.expectedWarCost)
  self:UpdateCampTierCosts()
  self:SetData()
end
function WarDeclarationPopup:OnLastModifiedGuildWar(warId)
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local warDecSuccess = warDetails:GetAttackerGuildId() == playerGuildId and warDetails:GetDefenderGuildId() == self.guildId
  if warDecSuccess then
    if self.socialNotificationsHandler then
      self:BusDisconnect(self.socialNotificationsHandler)
      self.socialNotificationsHandler = nil
    end
    self.waitingForDeclarationResult = false
    self:SetScreenState(self.SCREEN_STATE_CONFIRMATION)
  end
end
function WarDeclarationPopup:OnCancel()
  self.dataLayer:SetScreenEnabled("WarDeclarationPopup", false)
  local targetPanel = self.panelTypes.Fortress
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    targetPanel = self.panelTypes.Town
  end
  DynamicBus.Map.Broadcast.OnShowPanel(targetPanel, self.territoryId)
end
function WarDeclarationPopup:OnShowWarTutorial()
  DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(GameModeCommon.GAMEMODE_WAR)
end
return WarDeclarationPopup
