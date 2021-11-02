local TerritoryStandingsPane = {
  Properties = {
    ButtonClose = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    TerritoryStandingsScrollBox = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryStandingsPane)
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function TerritoryStandingsPane:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
  self.ButtonClose:SetCallback(self.OnCloseTerritoryStandingsPane, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_LEFT)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.TerritoryStandingsScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.TerritoryStandingsScrollBox)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
end
function TerritoryStandingsPane:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function TerritoryStandingsPane:UpdateTerritories()
  if not self.territories then
    self.territories = {}
    local claims = MapComponentBus.Broadcast.GetClaims()
    for index = 1, #claims do
      local capital = claims[index]
      local territoryData = {
        index = capital.monikerId,
        territoryId = capital.settlementId
      }
      local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(capital.settlementId)
      territoryData.nameLocalizationKey = territoryDefn.nameLocalizationKey
      table.insert(self.territories, territoryData)
    end
  end
  for _, territoryData in pairs(self.territories) do
    local standing = TerritoryDataHandler:GetTerritoryStanding(territoryData.territoryId)
    territoryData.tokens = standing.tokens
    territoryData.rank = standing.rank
  end
  table.sort(self.territories, function(a, b)
    if a.tokens ~= b.tokens then
      return a.tokens > b.tokens
    elseif a.rank ~= b.rank then
      return a.rank > b.rank
    else
      local aLoc = LyShineScriptBindRequestBus.Broadcast.LocalizeText(a.nameLocalizationKey)
      local bLoc = LyShineScriptBindRequestBus.Broadcast.LocalizeText(b.nameLocalizationKey)
      return aLoc < bLoc
    end
  end)
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.TerritoryStandingsScrollBox)
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.TerritoryStandingsScrollBox, 0)
end
function TerritoryStandingsPane:UpdateTerritoryInfoContainerBonuses()
  self:UpdateTerritories()
end
function TerritoryStandingsPane:GetTotalUnspentTokens()
  self:UpdateTerritories()
  local unspent = 0
  for i, territory in ipairs(self.territories) do
    local standing = TerritoryDataHandler:GetTerritoryStanding(territory.territoryId)
    unspent = unspent + standing.tokens
  end
  return unspent
end
function TerritoryStandingsPane:OnShowPanel(panelType, settlementKey)
  if panelType ~= self.panelTypes.TerritoryStanding then
    self:SetVisibility(false)
    return
  end
  self:UpdateTerritories()
  self:SetVisibility(true, settlementKey)
end
function TerritoryStandingsPane:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = -600}, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.2, {opacity = 0, delay = 0.2})
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {x = 0}, {
      x = -600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.ButtonContainer, 0.05, {opacity = 1})
  end
end
function TerritoryStandingsPane:IsVisible()
  return self.isVisible
end
function TerritoryStandingsPane:OnCloseTerritoryStandingsPane()
  self:SetVisibility(false)
end
function TerritoryStandingsPane:OnTerritoryClick(territoryId)
  local standing = TerritoryDataHandler:GetTerritoryStanding(territoryId)
  if standing.tokens > 0 then
    DynamicBus.TerritoryBonusPopupBus.Broadcast.OpenTerritoryBonusPopup(territoryId)
  else
    DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Territory, territoryId)
  end
end
function TerritoryStandingsPane:GetNumElements()
  local numElements = 0
  if self.territories then
    numElements = #self.territories
  end
  return numElements
end
function TerritoryStandingsPane:OnElementBecomingVisible(rootEntity, index)
  local listItem = self.registrar:GetEntityTable(rootEntity)
  listItem:SetTerritoryData(self.territories[index + 1], self, self.OnTerritoryClick)
end
return TerritoryStandingsPane
