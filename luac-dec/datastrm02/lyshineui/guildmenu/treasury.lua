local TreasuryTab = {
  Properties = {
    AmountText = {
      default = EntityId(),
      order = 1
    },
    DailyLimitLabelText = {
      default = EntityId(),
      order = 2
    },
    DailyLimitText = {
      default = EntityId(),
      order = 3
    },
    DailyLimitSmallContainer = {
      default = EntityId(),
      order = 4
    },
    DailyLimitSmallText = {
      default = EntityId(),
      order = 5
    },
    InfinityIcon = {
      default = EntityId(),
      order = 6
    },
    DepositButton = {
      default = EntityId(),
      order = 7
    },
    WithdrawalButton = {
      default = EntityId(),
      order = 8
    },
    DailyLimitButton = {
      default = EntityId(),
      order = 9
    },
    TransactionPopup = {
      default = EntityId(),
      order = 10
    },
    SetDailyLimitPopup = {
      default = EntityId(),
      order = 11
    },
    QuestionMark = {
      default = EntityId(),
      order = 12
    },
    TransactionList = {
      RecentTransactionsList = {
        default = EntityId()
      },
      AllTab = {
        default = EntityId()
      },
      InTab = {
        default = EntityId()
      },
      OutTab = {
        default = EntityId()
      }
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TreasuryTab)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local isPreviewMode = false
local transactionFilters = {
  "All",
  "In",
  "Out"
}
function TreasuryTab:OnInit()
  BaseElement.OnInit(self)
  socialDataHandler:OnActivate()
  local iconXPadding = 5
  local coinIconPath = "lyshineui/images/Icon_Crown"
  self.coinImgText = string.format("<img src=\"%s\" xPadding=\"%d\" yOffset=\"0\"></img>", coinIconPath, iconXPadding)
  UiTextBus.Event.SetText(self.AmountText, "-")
  UiTextBus.Event.SetText(self.DailyLimitText, "-")
  UiTextBus.Event.SetText(self.DailyLimitSmallText, "-")
  self.InfinityIcon:SetIcon("lyshineui/images/icons/misc/infinity_tan.png", self.UIStyle.COLOR_WHITE)
  self.DepositButton:SetCallback(self.OnShowDepositPopup, self)
  self.DepositButton:SetText("@ui_treasury_deposit")
  self.WithdrawalButton:SetCallback(self.OnShowWithdrawalPopup, self)
  self.WithdrawalButton:SetText("@ui_treasury_withdrawal")
  self.DailyLimitButton:SetCallback(self.OnShowDailyLimitPopup, self)
  self.DailyLimitButton:SetText("@ui_treasury_changedailywithdrawallimit")
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMark:SetTooltip("@ui_treasury_governor")
  self.transactionFilter = transactionFilters[1]
  self.TransactionList.RecentTransactionsList:SetColumnHeaderData({
    {text = "@ui_type"},
    {text = "@ui_date"},
    {
      text = "@ui_playername"
    },
    {
      text = "@ui_description"
    },
    {text = "@ui_amount"}
  })
  self.TransactionList.RecentTransactionsList:SetColumnWidths({
    100,
    300,
    300,
    600,
    300
  })
  local tabGroup = UiElementBus.Event.GetParent(self.Properties.TransactionList.AllTab)
  UiRadioButtonGroupBus.Event.SetState(tabGroup, self.Properties.TransactionList.AllTab, true)
  self.TransactionList.AllTab:SetPrimaryText("@ui_all")
  self.TransactionList.InTab:SetPrimaryText("@ui_in")
  self.TransactionList.OutTab:SetPrimaryText("@ui_out")
end
function TreasuryTab:OnShutdown()
  socialDataHandler:OnDeactivate()
end
function TreasuryTab:SetVisible(isVisible)
  if isVisible == self.isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    local forceUpdate = true
    self:UpdateTreasuryData(forceUpdate)
    dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Guild.Id", self.OnGuildChanged)
    dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Guild.Rank", self.UpdatePermissions)
    self.ScriptedEntityTweener:Play(self.entityId, 0.4, {opacity = 0}, {opacity = 1})
    self:UpdateTreasuryTransactions()
  else
    dataLayer:UnregisterObservers(self)
    self.ScriptedEntityTweener:Play(self.entityId, 0.4, {opacity = 1}, {opacity = 0})
  end
end
function TreasuryTab:UpdateTreasuryData(forceUpdate)
  socialDataHandler:GetTreasuryData_ServerCall(self, function(self, treasuryData)
    if treasuryData then
      if not forceUpdate and not self:TreasuryDataHasChanged(treasuryData) then
        return
      end
      self.treasuryData = treasuryData
      local rank = dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Rank")
      self:UpdatePermissions(rank)
      local localizedFunds = GetLocalizedCurrency(treasuryData.currentFunds)
      UiTextBus.Event.SetText(self.AmountText, localizedFunds)
      local tabText = GetLocalizedReplacementText("@ui_guildtreasurytab_balance", {
        balance = localizedFunds,
        coinImage = self.coinImgText
      })
      local skipLocalization = true
      if self.tabTable then
        self.tabTable:SetSecondaryText(tabText, skipLocalization)
      end
      UiElementBus.Event.SetIsEnabled(self.DailyLimitText, treasuryData.dailyWithdrawalLimit > 0)
      UiElementBus.Event.SetIsEnabled(self.InfinityIcon.entityId, treasuryData.dailyWithdrawalLimit == 0)
    end
  end, nil)
end
function TreasuryTab:TreasuryDataHasChanged(treasuryData)
  if not self.treasuryData then
    return true
  end
  return treasuryData.currentFunds ~= self.treasuryData.currentFunds or treasuryData.dailyWithdrawalLimit ~= self.treasuryData.dailyWithdrawalLimit or treasuryData.totalWithdrawnToday ~= self.treasuryData.totalWithdrawnToday
end
function TreasuryTab:UpdatePermissions(rank)
  if not self.treasuryData then
    return
  end
  local totalWithdrawnToday = self.treasuryData.totalWithdrawnToday
  local dailyWithdrawalLimit = self.treasuryData.dailyWithdrawalLimit
  local canDeposit = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Treasury_Deposit)
  local hasWithdrawalPrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Treasury_Withdraw)
  local unlimited = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Treasury_Withdraw_Unlimited)
  local noDailyLimit = dailyWithdrawalLimit == 0
  local canWithdraw = hasWithdrawalPrivilege and (unlimited or noDailyLimit or totalWithdrawnToday < dailyWithdrawalLimit)
  local canSetDailyLimit = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Treasury_Set_Daily_Limit)
  self.DepositButton:SetEnabled(canDeposit)
  self.WithdrawalButton:SetEnabled(canWithdraw)
  self.DailyLimitButton:SetEnabled(canSetDailyLimit)
  if not canWithdraw and self.TransactionPopup:IsWithdrawalPopupVisible() then
    self.TransactionPopup:SetVisibility(false)
  end
  local tooltipText = not canDeposit and "@ui_treasury_tooltip_deposit_nopermissons" or nil
  self.DepositButton:SetTooltip(tooltipText)
  tooltipText = nil
  if not canWithdraw then
    local overLimit = totalWithdrawnToday >= dailyWithdrawalLimit
    if not hasWithdrawalPrivilege then
      tooltipText = "@ui_treasury_tooltip_withdrawal_nopermissons"
    elseif overLimit then
      tooltipText = "@ui_treasury_tooltip_withdrawal_overlimit"
    end
  end
  self.WithdrawalButton:SetTooltip(tooltipText)
  tooltipText = not canSetDailyLimit and "@ui_treasury_tooltip_changedailywithdrawallimit_nopermissons" or nil
  self.DailyLimitButton:SetTooltip(tooltipText)
  local showSmallDailyLimit = 0 < dailyWithdrawalLimit and 0 < totalWithdrawnToday and not unlimited
  local dailyLimitLabelText = showSmallDailyLimit and "@ui_treasury_availablewithdrawallimit" or "@ui_treasury_dailywithdrawallimit"
  local localizedDailyLimit = GetLocalizedCurrency(dailyWithdrawalLimit)
  local availableWithdrawal = math.max(dailyWithdrawalLimit - totalWithdrawnToday, 0)
  local dailyLimitText = showSmallDailyLimit and GetLocalizedCurrency(availableWithdrawal) or localizedDailyLimit
  UiElementBus.Event.SetIsEnabled(self.DailyLimitSmallContainer, showSmallDailyLimit)
  UiTextBus.Event.SetTextWithFlags(self.DailyLimitLabelText, dailyLimitLabelText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetText(self.DailyLimitText, dailyLimitText)
  if showSmallDailyLimit then
    UiTextBus.Event.SetText(self.DailyLimitSmallText, localizedDailyLimit)
  end
end
function TreasuryTab:UpdateTreasuryTransactions()
  local listData
  if isPreviewMode then
    local numToShow = 100
    listData = {}
    for i = 1, numToShow do
      table.insert(listData, {
        columnData = {
          self.transactionFilter,
          "November 22 2018 00:00 PM",
          "Player" .. i,
          "Purchased Iron Straight Sword x" .. numToShow - i,
          "+" .. tostring(0.5 * i)
        }
      })
    end
  end
  self.TransactionList.RecentTransactionsList:OnListDataSet(listData)
end
function TreasuryTab:OnGuildChanged(firstJoin)
  if self.TransactionPopup:IsVisible() then
    self.TransactionPopup:SetVisibility(false)
  end
  local forceUpdate = true
  self:UpdateTreasuryData(forceUpdate)
end
function TreasuryTab:ClosePopups()
  if self.TransactionPopup:IsVisible() then
    self.TransactionPopup:SetVisibility(false)
    return true
  end
  if self.SetDailyLimitPopup:IsVisible() then
    self.SetDailyLimitPopup:SetVisibility(false)
    return true
  end
  return false
end
function TreasuryTab:OnShowDepositPopup()
  self.TransactionPopup:SetTransactionPopupData(true, self.treasuryData)
end
function TreasuryTab:OnShowWithdrawalPopup()
  self.TransactionPopup:SetTransactionPopupData(false, self.treasuryData)
end
function TreasuryTab:OnShowDailyLimitPopup()
  self.SetDailyLimitPopup:SetDailyLimitPopupData(self.treasuryData)
end
function TreasuryTab:SetTab(tabTable)
  self.tabTable = tabTable
end
function TreasuryTab:OnTreasuryFilterSelected(entityId)
  local selectedTab = UiRadioButtonGroupBus.Event.GetState(entityId)
  local selectedTabIndex = -1
  local tabs = {
    self.Properties.TransactionList.AllTab,
    self.Properties.TransactionList.InTab,
    self.Properties.TransactionList.OutTab
  }
  for index, tab in pairs(tabs) do
    tab:SetSelected(tab.entityId == selectedTab)
    if tab.entityId == selectedTab then
      selectedTabIndex = index
    end
  end
  if selectedTabIndex == -1 then
    Debug.Log("Warning: Unknown treasury filter selected.")
    selectedTabIndex = 1
  end
  self.transactionFilter = transactionFilters[selectedTabIndex]
  self:UpdateTreasuryTransactions()
end
return TreasuryTab
