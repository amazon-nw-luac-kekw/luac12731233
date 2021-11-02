local ContractBrowser = {
  Properties = {
    OutpostFilterContainer = {
      default = EntityId()
    },
    PrimaryTabBrowseContent = {
      default = EntityId()
    },
    PrimaryTabSellContent = {
      default = EntityId()
    },
    PrimaryTabMyOrdersContent = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    BrowseTab = {
      default = EntityId()
    },
    SellTab = {
      default = EntityId()
    },
    MyOrdersTab = {
      default = EntityId()
    },
    TabsContainer = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    StationBg = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineTop1 = {
      default = EntityId()
    },
    LineTop2 = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    ConfirmTransactionPopup = {
      default = EntityId()
    },
    PostOrderPopup = {
      default = EntityId()
    },
    CancelPopup = {
      default = EntityId()
    },
    PerkSelectionPopup = {
      default = EntityId()
    },
    PopupBlackBackground = {
      default = EntityId()
    },
    LandingPage = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(ContractBrowser)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function ContractBrowser:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent("Contracts", self.canvasId)
  DynamicBus.ContractBrowser.Connect(self.entityId, self)
  local SlashCommands = RequireScript("LyShineUI.SlashCommands")
  SlashCommands:RegisterSlashCommand("contracts", function()
    LyShineManagerBus.Broadcast.QueueState(156281203)
  end, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  self.currentTabContent = self.PrimaryTabBrowseContent
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.OutpostFilterContainer:SetCallback(self.OnOutpostFilterChange, self)
end
function ContractBrowser:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  local outpostId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.OutpostId")
  if not self.hasOpenedBefore then
    self.PrimaryTabMyOrdersContent:TryRefresh()
    self.hasOpenedBefore = true
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_Contracts", 0.5)
  DynamicBus.StationPropertiesBus.Broadcast.SetBackButtonKeybind("toggleMenuComponent")
  DynamicBus.StationPropertiesBus.Broadcast.SetBackButtonCallback(self.OnExit, self)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Crafting)
  self.ScriptedEntityTweener:Play(self.Background, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.TabsContainer, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.LineLeft:SetVisible(true, 2)
  self.LineTop1:SetVisible(true, 1.5)
  self.LineTop2:SetVisible(true, 1.5, {delay = 0.5})
  self.LineRight:SetVisible(true, 2, {delay = 0.5})
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 0
  self.targetDOFBlur = 0.95
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  if self.inventoryId and self.inventoryId:IsValid() and not self.containerEventHandler then
    self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
  end
  contractsDataHandler:RequestReplicateStorage(outpostId)
  self.OutpostFilterContainer:RefreshOutpostList()
  self.OutpostFilterContainer:RefreshCapitalDistances()
  self:OnBrowseTabSelected(nil, true)
  self.PrimaryTabBrowseContent.ItemSearchBar:ClearSearchField()
  if self.PrimaryTabSellContent.ItemSearchBar:IsValid() then
    self.PrimaryTabSellContent.ItemSearchBar:ClearSearchField()
  end
  UiElementBus.Event.SetIsEnabled(self.PopupBlackBackground, false)
  self.interactKeyHandler = CryActionNotificationsBus.Connect(self, "ui_interact")
  self.lastOutpostId = outpostId
  if self.dataLayer:GetDataFromNode("UIFeatures.g_enableContractsV2") then
    self.LandingPage:SetContractLandingVisibility(true)
  end
  timingUtils:StopDelay(self)
end
function ContractBrowser:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  local interactorEntityNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntityNode then
    local interactorEntity = interactorEntityNode:GetData()
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_Contracts", 0.5)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Outro)
  self.audioHelper:onUIStateChanged(self.audioHelper.UIState_Default)
  self.PrimaryTabBrowseContent.ItemSearchBar:ClearSearchField()
  if self.PrimaryTabSellContent.ItemSearchBar:IsValid() then
    self.PrimaryTabSellContent.ItemSearchBar:ClearSearchField()
  end
  self.ConfirmTransactionPopup:SetConfirmPopupVisibility(false)
  self.PostOrderPopup:SetVisibility(false)
  self.CancelPopup:SetVisibility(false)
  self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ConfirmTransactionPopup, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PostOrderPopup, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CancelPopup, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.PerkSelectionPopup, false)
  UiElementBus.Event.SetIsEnabled(self.PopupBlackBackground, false)
  self.LineLeft:SetVisible(false, 0)
  self.LineTop1:SetVisible(false, 0)
  self.LineTop2:SetVisible(false, 0)
  self.LineRight:SetVisible(false, 0)
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  if self.containerEventHandler then
    self:BusDisconnect(self.containerEventHandler)
    self.containerEventHandler = nil
  end
  if self.tickBus then
    self:BusDisconnect(self.tickBus)
    self.tickBus = nil
  end
  self.OutpostFilterContainer:CollapseDropdown()
  local cacheTimeout = 300
  timingUtils:Delay(cacheTimeout, self, function(self)
    contractsDataHandler:ClearQuantitiesCache()
  end)
  self:BusDisconnect(self.interactKeyHandler)
  self.interactKeyHandler = nil
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function ContractBrowser:OnCryAction(actionName, value)
  if UiCanvasBus.Event.GetEnabled(self.canvasId) then
    local wasKeyPress = 0 < value
    if wasKeyPress then
      self:OnExit()
    end
  end
end
function ContractBrowser:OnContainerChanged()
  if not self.tickBus then
    self.tickBus = self:BusConnect(DynamicBus.UITickBus)
  end
end
function ContractBrowser:OnTick()
  self:BusDisconnect(self.tickBus)
  self.tickBus = nil
  if self.currentTabContent.entityId == self.PrimaryTabSellContent.entityId then
    self.currentTabContent:FillInventoryList(true)
  elseif self.currentTabContent.entityId ~= self.PrimaryTabBrowseContent.entityId then
    self.currentTabContent:RefreshCurrentList()
  end
end
function ContractBrowser:OnContractSelected(contractId)
end
function ContractBrowser:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.ContractBrowser.Disconnect(self.entityId, self)
end
function ContractBrowser:OnExit()
  LyShineManagerBus.Broadcast.ExitState(156281203)
end
function ContractBrowser:OnEscapeKeyPressed()
  if self.PerkSelectionPopup:IsVisible() then
    self.PerkSelectionPopup:SetPerkSelectionPopupVisibility(false)
  elseif self.ConfirmTransactionPopup:IsVisible() then
    self.ConfirmTransactionPopup:SetConfirmPopupVisibility(false)
  elseif self.PostOrderPopup:IsVisible() then
    self.PostOrderPopup:SetVisibility(false)
  elseif self.CancelPopup:IsVisible() then
    self.CancelPopup:SetVisibility(false)
  else
    self:OnExit()
  end
end
function ContractBrowser:OnOutpostFilterChange(refreshContracts)
  if refreshContracts then
    self.currentTabContent:RefreshCurrentList(nil, true)
  end
end
function ContractBrowser:OnMyOrdersUpdate()
  if self.currentTabContent ~= self.PrimaryTabMyOrdersContent then
    UiTextBus.Event.SetTextWithFlags(self.MyOrdersTab.Text, "@ui_my_orders_notify", eUiTextSet_SetLocalized)
  end
end
function ContractBrowser:OnSellTabSelected(entityId)
  self.PrimaryTabSellContent:SetTabVisibility(true)
  self.PrimaryTabBrowseContent:SetTabVisibility(false)
  self.PrimaryTabMyOrdersContent:SetTabVisibility(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostFilterContainer, true)
  self.currentTabContent = self.PrimaryTabSellContent
  self.audioHelper:PlaySound(self.audioHelper.Contracts_Tab_Select)
end
function ContractBrowser:OnMyOrdersTabSelected(entityId)
  self.PrimaryTabMyOrdersContent:SetTabVisibility(true)
  self.PrimaryTabSellContent:SetTabVisibility(false)
  self.PrimaryTabBrowseContent:SetTabVisibility(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostFilterContainer, false)
  self.currentTabContent = self.PrimaryTabMyOrdersContent
  UiTextBus.Event.SetTextWithFlags(self.MyOrdersTab.Text, "@ui_my_orders", eUiTextSet_SetLocalized)
  self.audioHelper:PlaySound(self.audioHelper.Contracts_Tab_Select)
end
function ContractBrowser:OnBrowseTabSelected(entityId, onScreenOpen)
  self.PrimaryTabBrowseContent:SetTabVisibility(true, onScreenOpen)
  self.PrimaryTabMyOrdersContent:SetTabVisibility(false)
  self.PrimaryTabSellContent:SetTabVisibility(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OutpostFilterContainer, true)
  self.currentTabContent = self.PrimaryTabBrowseContent
  self.audioHelper:PlaySound(self.audioHelper.Contracts_Tab_Select)
  UiRadioButtonGroupCommunicationBus.Event.RequestRadioButtonStateChange(self.Properties.TabsContainer, self.BrowseTab.entityId, true)
end
function ContractBrowser:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function ContractBrowser:GetSelectedOutposts()
  return self.OutpostFilterContainer:GetSelectedOutposts()
end
return ContractBrowser
