local HousingHUD = {
  Properties = {
    HouseNameLabel = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    },
    HintContainer = {
      default = EntityId()
    },
    DisabledHousingTooltip = {
      default = EntityId()
    },
    DrawnLineTop = {
      default = EntityId()
    },
    DrawnLineBottom = {
      default = EntityId()
    }
  },
  hintMaxWidth = 180
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(HousingHUD)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function HousingHUD:OnInit()
  BaseScreen.OnInit(self)
  self.DrawnLineTop:SetLength(1000)
  self.DrawnLineBottom:SetLength(1000)
  self.DrawnLineTop:SetColor(self.UIStyle.COLOR_HOUSING_HUD_BUTTON_TEXT)
  self.DrawnLineBottom:SetColor(self.UIStyle.COLOR_HOUSING_HUD_BUTTON_TEXT)
  self.DrawnLineTop:SetVisible(self.UIStyle.COLOR_HOUSING_HUD_BUTTON_TEXT, 1.4)
  self.DrawnLineBottom:SetVisible(self.UIStyle.COLOR_HOUSING_HUD_BUTTON_TEXT, 1.4)
  self.dataLayer:RegisterDataObserver(self, self.dataLayer:GetIsScreenOpenDatapath("HousingManagement"), function(self, isManagementShowing)
    UiCanvasBus.Event.SetEnabled(self.canvasId, not isManagementShowing)
  end)
  self.clonedElements = {}
  self.hintData = {
    {
      displayStr = "@ui_house_hint_exit",
      actionName = "housing_exit",
      actionMap = "housing"
    },
    {
      displayStr = "@ui_photomode"
    },
    {
      displayStr = "@ui_housing_pay_taxes",
      actionName = "housing_menu",
      actionMap = "housing",
      showOnlyInOwnHouse = true
    },
    {
      displayStr = "@ui_house_hint_decorate",
      actionName = "housing_decorate",
      actionMap = "housing",
      showOnlyInOwnHouse = true,
      requiresTaxesPaid = true,
      disabledHint = "@ui_decoration_mode_unpaid"
    }
  }
  local hasUnpaidTaxes = PlayerHousingClientRequestBus.Broadcast.GetHouseHasUnpaidTaxes()
  local hintParent = UiElementBus.Event.GetParent(self.Properties.Hint)
  UiElementBus.Event.SetIsEnabled(self.Properties.DisabledHousingTooltip, hasUnpaidTaxes)
  for i, hintInfo in ipairs(self.hintData) do
    local hint
    if i == 1 then
      hint = self.Hint
    else
      hint = CloneUiElement(self.canvasId, self.registrar, self.Properties.Hint, hintParent, true)
      table.insert(self.clonedElements, hint.entityId)
    end
    local isDisabled = hintInfo.requiresTaxesPaid and hasUnpaidTaxes == true
    hint:SetHousingHudHint(hintInfo.displayStr, hintInfo.actionName, hintInfo.actionMap, isDisabled, isDisabled and hintInfo.disabledHint or hintInfo.enabledHint)
    if hintInfo.displayStr == "@ui_photomode" then
      hint:SetHintText("@photomode_keybind")
      local hintWidth = hint:GetHintWidth()
      local labelWidth = hint:GetLabelWidth()
      local labelPadding = 30
      local totalWidth = hintWidth + labelWidth + labelPadding
      if totalWidth >= self.hintMaxWidth then
        local newLabelWidth = self.hintMaxWidth - (hintWidth + labelPadding)
        hint:SetLabelWidth(newLabelWidth)
      end
    end
    if hintInfo.displayStr == "@ui_housing_pay_taxes" then
      self.payTaxesHint = hint
      hint:SetHighlightVisible(hasUnpaidTaxes)
    end
    hintInfo.entityTable = hint
    hintInfo.defaultWidth = UiLayoutCellBus.Event.GetTargetWidth(hint.entityId)
  end
  self.dataLayer:RegisterDataCallback(self, "Hud.Housing.RequestExitPlot", function(self)
    self:RequestExitPlot()
  end)
  self.cryActionHandlers = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.Housing.IsWithinAPlot", function(self, isInPlot)
    UiCanvasBus.Event.SetEnabled(self.canvasId, isInPlot)
    self.isInPlot = isInPlot
    UIInputRequestsBus.Broadcast.SetActionMapEnabled("housing", isInPlot)
    if isInPlot then
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Housing, self.audioHelper.MusicState_Housing_Default)
      self:RefreshHud()
    else
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Housing, self.audioHelper.MusicState_Housing_None)
      self:ResetHudRuntime()
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.Housing.OnPayTaxResponse", function(self, successResponse)
    if successResponse and self.isInPlot then
      TimingUtils:DelayFrames(10, self, function(self)
        self:RefreshHud()
      end)
    end
  end)
  self.dataLayer:RegisterDataObserver(self, self.dataLayer:GetIsScreenOpenDatapath("NewInventory"), function(self, isInventoryShowing)
    if self.isInPlot then
      UiCanvasBus.Event.SetEnabled(self.canvasId, not isInventoryShowing)
    end
  end)
end
function HousingHUD:ResetHudRuntime()
  for _, handler in ipairs(self.cryActionHandlers) do
    self:BusDisconnect(handler)
  end
  ClearTable(self.cryActionHandlers)
  if self.decorationBusHandler then
    self:BusDisconnect(self.decorationBusHandler)
    self.decorationBusHandler = nil
  end
  TimingUtils:StopDelay(self)
end
function HousingHUD:RefreshHud(forceTaxesUnpaid)
  self:ResetHudRuntime()
  local hasEnteredOwnHouse = PlayerHousingClientRequestBus.Broadcast.HasEnteredOwnHouse()
  local hasUnpaidTaxes = PlayerHousingClientRequestBus.Broadcast.GetHouseHasUnpaidTaxes() or forceTaxesUnpaid
  UiElementBus.Event.SetIsEnabled(self.Properties.DisabledHousingTooltip, hasUnpaidTaxes)
  local replicatedHouseData = PlayerHousingClientRequestBus.Broadcast.GetMyPhasedHousingPlotData()
  if replicatedHouseData then
    local taxesDueInSec = replicatedHouseData.taxesDue:Subtract(timeHelpers:ServerNow()):ToSeconds()
    local timeRemainingSeconds = math.max(taxesDueInSec, 0)
    if 0 < timeRemainingSeconds then
      TimingUtils:Delay(timeRemainingSeconds, self, function(self)
        self:RefreshHud(true)
      end)
    end
  end
  for i, hintInfo in ipairs(self.hintData) do
    local hintAction = hintInfo.actionName
    if hintAction and (not hintInfo.showOnlyInOwnHouse or hintInfo.showOnlyInOwnHouse and hasEnteredOwnHouse) then
      local handler = self:BusConnect(CryActionNotificationsBus, hintAction)
      table.insert(self.cryActionHandlers, handler)
    end
    if hintInfo.displayStr == "@ui_housing_pay_taxes" then
      self.payTaxesHint:SetHighlightVisible(hasUnpaidTaxes)
    end
    if hintInfo.showOnlyInOwnHouse then
      local width = hasEnteredOwnHouse and hintInfo.defaultWidth or 0
      UiLayoutCellBus.Event.SetTargetWidth(hintInfo.entityTable.entityId, width)
      UiElementBus.Event.SetIsEnabled(hintInfo.entityTable.entityId, hasEnteredOwnHouse)
    end
    if hasEnteredOwnHouse then
      local isDisabled = hintInfo.requiresTaxesPaid and hasUnpaidTaxes == true
      hintInfo.entityTable:SetIsDisabled(isDisabled)
      hintInfo.entityTable:SetTooltip(isDisabled and hintInfo.disabledHint or hintInfo.enabledHint)
    end
  end
  if not self.decorationBusHandler then
    self.decorationBusHandler = self:BusConnect(HousingDecorationEventBus)
  end
  if hasEnteredOwnHouse then
    local playerName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PlayerName")
    UiTextBus.Event.SetText(self.Properties.HouseNameLabel, playerName)
    self.ScriptedEntityTweener:Set(self.entityId, {w = 1300})
  else
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.House.LastEnteredHouseOwnerCharacterId", function(self, ownerCharacterId)
      if ownerCharacterId and ownerCharacterId ~= "" then
        UiTextBus.Event.SetText(self.Properties.HouseNameLabel, "")
        SocialDataHandler:GetPlayerIdentification_ServerCall(self, function(self, result)
          local ownerName = ""
          if 0 < #result then
            ownerName = result[1].playerId.playerName
          end
          if not ownerName or ownerName == "" then
            ownerName = "@ui_no_home_owners"
            UiTextBus.Event.SetTextWithFlags(self.Properties.HouseNameLabel, ownerName, eUiTextSet_SetLocalized)
          else
            UiTextBus.Event.SetText(self.Properties.HouseNameLabel, ownerName)
          end
        end, function(self)
        end, ownerCharacterId)
      else
        local ownerName = "@ui_no_home_owners"
        UiTextBus.Event.SetTextWithFlags(self.Properties.HouseNameLabel, ownerName, eUiTextSet_SetLocalized)
      end
    end)
    self.ScriptedEntityTweener:Set(self.entityId, {w = 800})
  end
end
function HousingHUD:OnShutdown()
  BaseScreen.OnShutdown(self)
  for _, elementId in ipairs(self.clonedElements) do
    UiElementBus.Event.DestroyElement(elementId)
  end
end
function HousingHUD:OnCryAction(actionName, value)
  if self.isFadingOut then
    return
  end
  if actionName == "housing_decorate" and HousingDecorationRequestBus.Broadcast.CanOpenDecorationScreen() then
    LyShineManagerBus.Broadcast.ToggleState(2640373987)
  elseif actionName == "housing_menu" then
    LyShineManagerBus.Broadcast.ToggleState(2437603339)
  elseif actionName == "housing_exit" then
    self:RequestExitPlot()
  end
end
function HousingHUD:OnModeChanged(modeEnum, newModeEnum)
  local showHud = newModeEnum == eHousingDecorationMode_Disabled
  UiCanvasBus.Event.SetEnabled(self.canvasId, showHud)
  if showHud then
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0, y = -100}, {
      opacity = 1,
      y = 72,
      ease = "QuadOut"
    })
  end
end
function HousingHUD:RequestExitPlot()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.isFadingOut = true
  DynamicBus.FullScreenFader.Broadcast.ExecuteFadeInOut(0.3, 0.3, 0.4, self, function()
    PlayerHousingClientRequestBus.Broadcast.RequestExitPlot()
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end, function()
    if self.isInPlot == false then
      UiCanvasBus.Event.SetEnabled(self.canvasId, false)
      UiElementBus.Event.SetIsEnabled(self.entityId, true)
      self.isFadingOut = false
    end
  end)
end
return HousingHUD
