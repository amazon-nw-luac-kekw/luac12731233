local SettlementWarsMenu = {
  Properties = {
    Crest = {
      default = EntityId()
    },
    SettlementNameText = {
      default = EntityId()
    },
    OwnedByText = {
      default = EntityId()
    },
    NumWarsText = {
      default = EntityId()
    },
    CompaniesAtWarList = {
      default = EntityId()
    },
    ButtonWar = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SettlementWarsMenu)
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function SettlementWarsMenu:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  UiTextBus.Event.SetColor(self.Properties.NumWarsText, self.UIStyle.COLOR_RED)
  self.ButtonClose:SetCallback(self.OnCloseSettlementWarsMenu, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_LEFT)
  self.Frame:SetOffsets(0, 0, 12, 0)
end
function SettlementWarsMenu:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function SettlementWarsMenu:OnShowPanel(panelType, settlementKey)
  if panelType ~= self.panelTypes.SettlementWar then
    self:SetVisibility(false)
    return
  end
  self:SetVisibility(true, settlementKey)
end
function SettlementWarsMenu:SetVisibility(isVisible, settlementKey)
  if self.isVisible == isVisible and self.settlementKey == settlementKey then
    return
  end
  self.isVisible = isVisible
  self.settlementKey = settlementKey
  if isVisible and settlementKey then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(settlementKey)
    self.guildId = ownerData.guildId
    self.guildName = ownerData.guildName
    self.guildCrestData = ownerData.guildCrestData
    local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(settlementKey)
    UiTextBus.Event.SetTextWithFlags(self.Properties.SettlementNameText, posData.territoryName, eUiTextSet_SetLocalized)
    self.Crest:SetSmallIcon(ownerData.guildCrestData)
    local ownedByText = GetLocalizedReplacementText("@ui_mapmenu_ownedby", {
      colorHex = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE),
      guildName = ownerData.guildName
    })
    UiTextBus.Event.SetText(self.Properties.OwnedByText, ownedByText)
    local numWars = WarDataServiceBus.Broadcast.GetNumWarsForGuild(ownerData.guildId) or 0
    if numWars == 0 then
      UiTextBus.Event.SetTextWithFlags(self.NumWarsText, "@ui_mapmenu_noactivewars", eUiTextSet_SetLocalized)
    elseif numWars == 1 then
      UiTextBus.Event.SetTextWithFlags(self.NumWarsText, "@ui_activewars_oneactivewar", eUiTextSet_SetLocalized)
    else
      local numWarsText = GetLocalizedReplacementText("@ui_activewars_numactivewars", {numWars = numWars})
      UiTextBus.Event.SetText(self.NumWarsText, numWarsText)
    end
    self.ButtonWar:SetData({
      settlementKey = settlementKey,
      callback = self.OnWarButtonClick,
      callbackTable = self
    })
    local forceUpdate = true
    self.CompaniesAtWarList:SetIsVisible(0 < numWars, ownerData.guildId, forceUpdate)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = -600}, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.ButtonContainer, 0.2, {opacity = 0, delay = 0.2})
  else
    self.ButtonWar:OnMenuClosed()
    self.CompaniesAtWarList:SetIsVisible(false)
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {x = 0}, {
      x = -600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.ButtonContainer, 0.05, {opacity = 1})
  end
end
function SettlementWarsMenu:IsVisible()
  return self.isVisible
end
function SettlementWarsMenu:OnWarButtonClick()
  warDeclarationPopupHelper:ShowWarDeclarationPopup(self.guildId, self.guildName, self.guildCrestData, self.settlementKey)
end
function SettlementWarsMenu:OnCloseSettlementWarsMenu()
  self:SetVisibility(false)
end
return SettlementWarsMenu
