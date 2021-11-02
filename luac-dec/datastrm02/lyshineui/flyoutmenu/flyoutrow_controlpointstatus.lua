local FlyoutRow_ControlPointStatus = {
  Properties = {
    ContentContainer = {
      default = EntityId()
    },
    StatusIcon = {
      default = EntityId()
    },
    StatusText = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    ControlledByText = {
      default = EntityId()
    },
    StatusHeaderText = {
      default = EntityId()
    },
    BenefitsHeaderText = {
      default = EntityId()
    },
    ReminderText = {
      default = EntityId()
    },
    TerritoryBonusesHeader = {
      default = EntityId()
    },
    TerritoryBonusContainer = {
      default = EntityId()
    },
    TerritoryBonusList = {
      default = EntityId()
    },
    FactionBonusHeader = {
      default = EntityId()
    },
    FactionBonusContainer = {
      default = EntityId()
    },
    FactionBonusList = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_ControlPointStatus)
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local FcpCommon = RequireScript("LyShineUI._Common.FactionControlPointCommon")
function FlyoutRow_ControlPointStatus:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.StatusHeaderText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_HEADER)
  SetTextStyle(self.Properties.BenefitsHeaderText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_HEADER)
  SetTextStyle(self.Properties.ReminderText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_BODY_TEXT)
  SetTextStyle(self.Properties.TerritoryBonusesHeader, self.UIStyle.FONT_STYLE_FACTIONCONTROL_SUB_HEADER)
  SetTextStyle(self.Properties.FactionBonusHeader, self.UIStyle.FONT_STYLE_FACTIONCONTROL_SUB_HEADER)
  self.defaultReminderTextHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ReminderText)
end
function FlyoutRow_ControlPointStatus:SetData(data)
  if not (data and data.capitalType) or not data.id then
    Log("[FlyoutRow_ControlPointStatus] Error: invalid data passed to SetData")
  end
  self.territoryId = data.id
  if self.landClaimHandler then
    self:BusDisconnect(self.landClaimHandler)
  end
  self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
    if isAvailable == true then
      local factionOwner = LandClaimRequestBus.Broadcast.GetFactionControlOwner(self.territoryId)
      local captureStatus = LandClaimRequestBus.Broadcast.GetFactionControlCaptureStatus(self.territoryId)
      self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
      self:UpdateFactionOwnership(factionOwner)
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable")
    end
  end)
  local containerHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ContentContainer)
  local reminderTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.ReminderText)
  local difference = reminderTextHeight - self.defaultReminderTextHeight
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, containerHeight + difference)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, containerHeight + difference)
  self:SetupBonuses()
end
function FlyoutRow_ControlPointStatus:UpdateFactionOwnership(faction)
  if faction == eFactionType_None then
    UiElementBus.Event.SetIsEnabled(self.Properties.ControlledByText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, false)
    SetTextStyle(self.Properties.StatusText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_STATUS_TEXT)
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, "@ui_factioncontrol_unclaimed", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ReminderText, "@ui_factioncontrol_reminder_unclaimed", eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.StatusIcon, 27)
  else
    local reminderString
    if FactionControlLandClaimClientRequestBus.Broadcast.GetFactionControlIsActive(self.territoryId) then
      reminderString = "@ui_factioncontrol_reminder_map"
    else
      reminderString = FcpCommon:BuildReminderString(self.territoryId)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.ReminderText, reminderString, eUiTextSet_SetLocalized)
    self:UpdateFaction(faction)
  end
end
function FlyoutRow_ControlPointStatus:UpdateFaction(faction)
  local imagePath = "lyshineui/images/icons/territory/icon_whiteflag.dds"
  UiImageBus.Event.SetColor(self.Properties.StatusIcon, self.UIStyle.COLOR_WHITE)
  SetTextStyle(self.Properties.StatusText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_STATUS_TEXT)
  if faction ~= eFactionType_None then
    local factionData = FactionCommon.factionInfoTable[faction]
    if factionData then
      UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionData.crestFgSmall)
      UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionData.crestBgColor)
      local controlledByText = GetLocalizedReplacementText("@ui_factioncontrol_controlledby_inline", {
        factionName = "<font color=" .. ColorRgbaToHexString(factionData.crestBgColor) .. ">" .. factionData.factionName .. "</font>"
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, "@ui_factioncontrol_claimed", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ControlledByText, controlledByText, eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.ControlledByText, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, true)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.StatusIcon, 7)
    end
    if self.isContested then
      imagePath = "lyshineui/images/map/icon/icon_crossedswords_small_white.dds"
      UiImageBus.Event.SetColor(self.Properties.StatusIcon, self.UIStyle.COLOR_CONTESTED_RED)
      SetTextStyle(self.Properties.StatusText, self.UIStyle.FONT_STYLE_FACTIONCONTROL_CONTESTED_BODY_TEXT)
      UiTextBus.Event.SetTextWithFlags(self.Properties.StatusText, "@ui_factioncontrol_contested", eUiTextSet_SetLocalized)
    end
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.StatusIcon, imagePath)
end
function FlyoutRow_ControlPointStatus:OnFactionControlStatusChanged(settlementId, faction, captureStatus, isActive)
  if self.territoryId == settlementId then
    self.isContested = captureStatus == eFactionControlCaptureStatus_Contested
    self:UpdateFactionOwnership(faction)
  end
end
function FlyoutRow_ControlPointStatus:SetupBonuses()
  if self.territoryId == nil then
    return
  end
  self:PopulateBonusList(self.Properties.TerritoryBonusList, FcpCommon:GetTerritoryBonuses(self.territoryId))
  self:PopulateBonusList(self.Properties.FactionBonusList, FcpCommon:GetFactionBonuses(self.territoryId))
end
function FlyoutRow_ControlPointStatus:PopulateBonusList(listEntityId, bonusList)
  if #bonusList == 0 then
    Log("ERROR: FactionControlInfoMenu:PopulateBonusList - Territory Id " .. self.settlementId .. " has no bonuses")
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(listEntityId, #bonusList)
  for i = 1, #bonusList do
    local childElement = UiElementBus.Event.GetChild(listEntityId, i - 1)
    local nameId = UiElementBus.Event.FindChildByName(childElement, "Name")
    UiTextBus.Event.SetTextWithFlags(nameId, bonusList[i].bonusName, eUiTextSet_SetLocalized)
    local valueId = UiElementBus.Event.FindChildByName(childElement, "Stat")
    UiTextBus.Event.SetText(valueId, bonusList[i].bonusValue)
    local iconId = UiElementBus.Event.FindChildByName(childElement, "Icon")
    UiImageBus.Event.SetSpritePathname(iconId, bonusList[i].imagePath)
    local buttonId = UiElementBus.Event.FindChildByName(childElement, "ButtonCircle")
    local buttonItem = self.registrar:GetEntityTable(buttonId)
    buttonItem:SetTooltip(bonusList[i].tooltiptext)
    buttonItem:SetButtonStyle(buttonItem.BUTTON_STYLE_QUESTION_MARK)
  end
end
return FlyoutRow_ControlPointStatus
