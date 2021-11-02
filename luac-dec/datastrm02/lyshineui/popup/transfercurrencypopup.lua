local TransferCurrencyPopup = {
  Properties = {
    PopupHolder = {
      default = EntityId(),
      order = 1
    },
    CoinMessage = {
      default = EntityId(),
      order = 2
    },
    Frame = {
      default = EntityId(),
      order = 4
    },
    FrameHeader = {
      default = EntityId(),
      order = 5
    },
    ScreenScrim = {
      default = EntityId(),
      order = 6
    },
    PlayerNameContainer = {
      default = EntityId(),
      order = 7
    },
    PlayerNameTextInput = {
      default = EntityId(),
      order = 8
    },
    UpdateMessaging = {
      default = EntityId(),
      order = 9
    },
    ClearFieldButton = {
      default = EntityId(),
      order = 10
    },
    SearchIcon = {
      default = EntityId(),
      order = 11
    },
    SearchbarBackground = {
      default = EntityId(),
      order = 12
    },
    CompanyBalanceLabel = {
      default = EntityId(),
      order = 13
    },
    CompanyBalanceAmount = {
      default = EntityId(),
      order = 14
    },
    CurrencySlider = {
      default = EntityId(),
      order = 18
    },
    ButtonAccept = {
      default = EntityId(),
      order = 19
    },
    ButtonCancel = {
      default = EntityId(),
      order = 20
    },
    ButtonClose = {
      default = EntityId(),
      order = 21
    },
    DepositLimit = {
      default = EntityId(),
      order = 22
    },
    TabbedList = {
      default = EntityId()
    }
  },
  chosenPlayerNameValid = false,
  totalCurrency = 0,
  playerCurrency = 0,
  treasuryLimit = 0,
  treasuryDepositLimit = 0,
  BUTTON_STYLE = 2,
  BUTTON_WIDTH = 380
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TransferCurrencyPopup)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
function TransferCurrencyPopup:OnInit()
  BaseScreen.OnInit(self)
  local listData = {
    {
      text = "@ui_currency_toplayer",
      callback = self.OnPlayerToggled,
      style = self.BUTTON_STYLE,
      width = self.BUTTON_WIDTH
    },
    {
      text = "@ui_currency_totreasury",
      callback = self.OnTreasuryToggled,
      style = self.BUTTON_STYLE,
      width = self.BUTTON_WIDTH
    }
  }
  self.TAB_PLAYER = 1
  self.TAB_TREASURY = 2
  self.TabbedList:SetListData(listData, self)
  self.TabbedList:SetSelected(self.TAB_PLAYER)
  self.treasuryEnabled = false
  self.treasuryWalletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-company")
  local coinCappedTooltip = GetLocalizedReplacementText("@ui_coin_max_deposit_tooltip", {
    amount = GetLocalizedCurrency(self.treasuryWalletCap)
  })
  self.DepositLimit:SetTooltip(coinCappedTooltip)
  self.DepositLimit:SetButtonStyle(self.DepositLimit.BUTTON_STYLE_QUESTION_MARK)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableCompanyTreasury", function(self, treasuryEnabled)
    if treasuryEnabled ~= nil then
      self.treasuryEnabled = treasuryEnabled
      self:UpdateTreasuryAccess()
    end
  end)
  self.PlayerNameTextInput:SetEnterCallback(self.OnSubmitPlayerName, self)
  self.PlayerNameTextInput:SetStartEditCallback(self.OnStartEdit, self)
  self.PlayerNameTextInput:SetEndEditCallback(self.OnEndEdit, self)
  self.PlayerNameTextInput:SetOnlineOnly(true)
  UiTextInputBus.Event.SetTextSelectionColor(self.Properties.PlayerNameTextInput, self.UIStyle.COLOR_INPUT_SELECTION)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.FrameHeader:SetTextAlignment(self.FrameHeader.TEXT_ALIGN_CENTER)
  self.FrameHeader:SetText("@ui_transfercrown")
  self.ButtonAccept:SetText("@ui_trade_send_title")
  self.ButtonAccept:SetCallback(self.OnAccept, self)
  self.ButtonAccept:SetButtonStyle(self.ButtonAccept.BUTTON_STYLE_CTA)
  self.ButtonCancel:SetText("@ui_cancel")
  self.ButtonCancel:SetCallback(self.OnCancel, self)
  self.ButtonClose:SetCallback(self.OnCancel, self)
  self.ButtonAccept:SetEnabled(false)
  self.CurrencySlider:SetCurrencyDisplay(true)
  self.CurrencySlider:SetSliderStyle(self.CurrencySlider.SLIDER_STYLE_1)
  self.CurrencySlider:SetCallback(self.OnCurrencySliderChanged, self)
  self.CurrencySlider:SetSliderValue(0)
  self.CurrencySlider:ResetSlider(0)
end
function TransferCurrencyPopup:OnShutdown()
  self.socialDataHandler:OnDeactivate()
  BaseScreen.OnShutdown(self)
end
function TransferCurrencyPopup:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self:ClearSearchField()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", self.UpdateCurrency)
  self:UpdateTreasuryAccess()
  if not self.autoCompleteBusHandler then
    self.autoCompleteBusHandler = self:BusConnect(UiTextInputAutoCompleteBus, self.PlayerNameTextInput.entityId)
  end
  if self.treasuryEnabled then
    self.treasuryCurrentFunds = nil
    UiTextBus.Event.SetText(self.CompanyBalanceAmount, "-")
    self.socialDataHandler:GetTreasuryData_ServerCall(self, function(self, treasuryData)
      if treasuryData then
        self.treasuryCurrentFunds = treasuryData.currentFunds
        local newBalance = treasuryData.currentFunds + self.CurrencySlider:GetSliderValue()
        UiTextBus.Event.SetText(self.CompanyBalanceAmount, GetLocalizedCurrency(newBalance))
        self.treasuryLimit = self.treasuryWalletCap - self.treasuryCurrentFunds
        self.treasuryDepositLimit = math.min(self.playerCurrency, self.treasuryLimit)
        self:UpdateCurrencySlider()
      end
    end, nil)
  end
  self.ScriptedEntityTweener:Play(self.PopupHolder, 0.8, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ScreenScrim, 0.5, {opacity = 0}, {opacity = 0.8, ease = "QuadOut"})
end
function TransferCurrencyPopup:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.autoCompleteBusHandler then
    self:BusDisconnect(self.autoCompleteBusHandler, self.PlayerNameTextInput.entityId)
    self.autoCompleteBusHandler = nil
  end
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Currency.Amount")
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.CurrencySlider:SetSliderValue(0)
  self.CurrencySlider:ResetSlider(0)
end
function TransferCurrencyPopup:UpdateCurrencySlider()
  if self.CurrencySlider then
    local isToPlayer = self.TabbedList:GetSelected().index == self.TAB_PLAYER
    local maxCurrency
    if isToPlayer then
      maxCurrency = self.playerCurrency
    else
      maxCurrency = self.treasuryDepositLimit
    end
    self.CurrencySlider:SetSliderMaxValue(maxCurrency)
    if maxCurrency > self.totalCurrency then
      self.CurrencySlider:SetSliderValue(0)
    end
    self.totalCurrency = maxCurrency
    UiElementBus.Event.SetIsEnabled(self.Properties.DepositLimit, not isToPlayer and self.treasuryDepositLimit < self.playerCurrency)
  end
end
function TransferCurrencyPopup:OnCurrencySliderChanged(slider)
  if self.treasuryCurrentFunds then
    local newBalance = self.treasuryCurrentFunds + slider:GetValue()
    UiTextBus.Event.SetText(self.CompanyBalanceAmount, GetLocalizedCurrency(newBalance))
  end
  self.ButtonAccept:SetEnabled(self:CurrencySettingsValid())
end
function TransferCurrencyPopup:UpdateCurrency(currencyAmount)
  if currencyAmount == nil then
    return
  end
  self.playerCurrency = currencyAmount
  self.treasuryDepositLimit = math.min(self.playerCurrency, self.treasuryLimit)
  self:UpdateCurrencySlider()
end
function TransferCurrencyPopup:UpdateTreasuryAccess()
  local canDeposit = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Treasury_Deposit)
  local canAccessTreasury = self.treasuryEnabled and canDeposit
  local isToTreasury = self.TabbedList:GetSelected().index == self.TAB_TREASURY
  if not canAccessTreasury and isToTreasury then
    self.TabbedList:SetSelected(self.TAB_PLAYER)
  end
  local treasuryTab = self.TabbedList:GetIndex(self.TAB_TREASURY)
  treasuryTab:SetEnabled(canAccessTreasury)
  UiInteractableBus.Event.SetIsHandlingEvents(treasuryTab.entityId, canAccessTreasury)
end
function TransferCurrencyPopup:OnPlayerToggled()
  self:OnToggleDestination(true)
end
function TransferCurrencyPopup:OnTreasuryToggled()
  self:OnToggleDestination(false)
end
function TransferCurrencyPopup:OnToggleDestination(isToPlayer)
  local animDuration = 0.15
  local playerOpacity = isToPlayer and 1 or 0
  local treasuryOpacity = isToPlayer and 0 or 1
  self:UpdateCurrencySlider()
  self.ScriptedEntityTweener:Play(self.PlayerNameContainer, animDuration, {opacity = playerOpacity, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.CoinMessage, animDuration, {opacity = playerOpacity, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.CompanyBalanceLabel, animDuration, {opacity = treasuryOpacity, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.CompanyBalanceAmount, animDuration, {opacity = treasuryOpacity, ease = "QuadOut"})
  self.ButtonAccept:SetEnabled(self:CurrencySettingsValid())
end
function TransferCurrencyPopup:OnAccept()
  if self:TransferCurrency() then
    self:ClearSearchField()
    LyShineManagerBus.Broadcast.ExitState(2729122569)
  end
end
function TransferCurrencyPopup:OnCancel()
  self:ClearSearchField()
  LyShineManagerBus.Broadcast.ExitState(2729122569)
end
function TransferCurrencyPopup:TransferCurrency()
  if not self:CurrencySettingsValid() then
    return false
  end
  local currencyAmount = self.CurrencySlider:GetSliderValue()
  if currencyAmount == 0 then
    return false
  end
  local isToPlayer = self.TabbedList:GetSelected().index == self.TAB_PLAYER
  if isToPlayer then
    return ClientCurrencyRequestBus.Broadcast.RequestTransferFundsToPlayer(currencyAmount, self.chosenCharacterId)
  else
    GuildsComponentBus.Broadcast.RequestDepositGuildTreasuryFunds(currencyAmount)
    return true
  end
end
function TransferCurrencyPopup:OnSubmitPlayerName()
  local playerName = self.PlayerNameTextInput:GetText()
  self.chosenPlayerNameValid = false
  self.ButtonAccept:SetEnabled(self:CurrencySettingsValid())
  if playerName == "" then
    return
  end
  local localPlayerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
  if localPlayerName and playerName == localPlayerName then
    self:DisplaySearchFieldMessage(self.UIStyle.FONT_STYLE_SOCIAL_ERROR_MESSAGING, "@ui_currency_self")
    return
  end
  self.socialDataHandler:GetPlayerIdentificationByName_ServerCall(self, self.OnRemotePlayerIdReady, self.OnRemotePlayerIdFailed, playerName)
end
function TransferCurrencyPopup:OnRemotePlayerIdReady(result)
  if 0 < #result then
    local playerId = result[1].playerId
    self.chosenCharacterId = playerId:GetCharacterIdString()
    self:DisplaySearchFieldMessage(self.UIStyle.FONT_STYLE_SOCIAL_MESSAGING, "@ui_currency_namevalid")
    self.chosenPlayerNameValid = true
  else
    Log("ERR - TransferCurrencyPopup:OnPlayerIdentificationReady: Player not found")
    self.chosenCharacterId = nil
    self:DisplaySearchFieldMessage(self.UIStyle.FONT_STYLE_SOCIAL_ERROR_MESSAGING, "@ui_currency_nameinvalid")
    self.chosenPlayerNameValid = false
  end
  self.ButtonAccept:SetEnabled(self:CurrencySettingsValid())
end
function TransferCurrencyPopup:OnRemotePlayerIdFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - TransferCurrencyPopup:OnPlayerIdentificationFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - TransferCurrencyPopup:OnPlayerIdentificationFailed: Timed Out")
  end
  self.ButtonAccept:SetEnabled(self:CurrencySettingsValid())
end
function TransferCurrencyPopup:DisplaySearchFieldMessage(style, message)
  UiTextBus.Event.SetTextWithFlags(self.UpdateMessaging, message, eUiTextSet_SetLocalized)
  SetTextStyle(self.UpdateMessaging, style)
  self.ScriptedEntityTweener:Stop(self.UpdateMessaging)
  self.ScriptedEntityTweener:Play(self.UpdateMessaging, 0.18, {x = -30, opacity = 0}, {
    x = 0,
    opacity = 1,
    ease = "QuadOut"
  })
end
function TransferCurrencyPopup:ClearSearchField()
  self.PlayerNameTextInput:SetText("")
  self.PlayerNameTextInput:SetActiveAndBegin()
end
function TransferCurrencyPopup:OnStartEdit()
  SetActionmapsForTextInput(self.canvasId, true)
  self.ScriptedEntityTweener:Set(self.SearchIcon, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 1})
  UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, true)
  self.ScriptedEntityTweener:Set(self.SearchbarBackground, {opacity = 0.4})
  self.ScriptedEntityTweener:Play(self.UpdateMessaging, 0.23, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function TransferCurrencyPopup:OnEndEdit()
  SetActionmapsForTextInput(self.canvasId, false)
  self.ScriptedEntityTweener:Set(self.SearchIcon, {opacity = 0.5})
  self.ScriptedEntityTweener:Set(self.ClearFieldButton, {opacity = 0})
  UiElementBus.Event.SetIsEnabled(self.ClearFieldButton, false)
  self.ScriptedEntityTweener:Set(self.SearchbarBackground, {opacity = 0.25})
  self:OnSubmitPlayerName()
end
function TransferCurrencyPopup:CurrencySettingsValid()
  local isToPlayer = self.TabbedList:GetSelected().index == self.TAB_PLAYER
  return tonumber(self.CurrencySlider:GetSliderValue()) > 0 and (not isToPlayer or self.chosenPlayerNameValid and self.chosenCharacterId)
end
function TransferCurrencyPopup:OnUpdateMatchingList(matchingList)
  if 0 < #matchingList then
    self:OnSubmitPlayerName()
  else
    self.chosenPlayerNameValid = false
    self.ButtonAccept:SetEnabled(self:CurrencySettingsValid())
  end
end
return TransferCurrencyPopup
