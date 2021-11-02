local CompaniesAtWarListItem = {
  Properties = {
    AttackerNameText = {
      default = EntityId()
    },
    AttackerCrest = {
      default = EntityId()
    },
    DefenderNameText = {
      default = EntityId()
    },
    DefenderCrest = {
      default = EntityId()
    },
    AttackerFaction = {
      default = EntityId()
    },
    DefenderFaction = {
      default = EntityId()
    },
    TerritoryImage = {
      default = EntityId()
    },
    WarDateTimeText = {
      default = EntityId()
    },
    LocationText = {
      default = EntityId()
    },
    WarTimeLabel = {
      default = EntityId()
    },
    LocationLabel = {
      default = EntityId()
    },
    WarContainer = {
      default = EntityId()
    },
    InvasionContainer = {
      default = EntityId()
    },
    InfoContainer = {
      default = EntityId()
    }
  },
  timer = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CompaniesAtWarListItem)
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function CompaniesAtWarListItem:OnInit()
  BaseElement.OnInit(self)
end
function CompaniesAtWarListItem:SetCompaniesAtWarListItemData(data)
  if data.defenderGuildData then
    self.siegeWindow = data.defenderGuildData.siegeWindow
  else
    self.siegeWindow = 0
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.15, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = data.delay
  })
  self.warIndex = data.warIndex
  self.GetWarDetailsFn = data.GetWarDetails
  self.warDetailsFnSelf = data.fnSelf
  self:UpdateWarDetails()
  UiElementBus.Event.SetIsEnabled(self.Properties.WarContainer, not self.isInvasion)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionContainer, self.isInvasion)
  if self.isInvasion then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeLabel, "@ui_siege_signup_invasiontime", eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.InfoContainer, -34)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.LocationLabel, -34)
  else
    UiTransformBus.Event.SetLocalPositionY(self.Properties.InfoContainer, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.LocationLabel, -42)
    local isGuildDataAvailable = data.attackerGuildData and data.defenderGuildData
    UiElementBus.Event.SetIsEnabled(self.Properties.WarContainer, isGuildDataAvailable)
    if isGuildDataAvailable then
      UiTextBus.Event.SetText(self.Properties.AttackerNameText, data.attackerGuildData.guildName)
      self.AttackerCrest:SetIcon(data.attackerGuildData.crestData)
      UiTextBus.Event.SetText(self.Properties.DefenderNameText, data.defenderGuildData.guildName)
      self.DefenderCrest:SetIcon(data.defenderGuildData.crestData)
      local attackerFaction = data.attackerGuildData.faction
      local defenderFaction = data.defenderGuildData.faction
      local attackerFactionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(attackerFaction)]
      local defenderFactionBgColor = self.UIStyle["COLOR_FACTION_BG_" .. tostring(defenderFaction)]
      UiTextBus.Event.SetColor(self.Properties.AttackerFaction, attackerFactionBgColor)
      UiTextBus.Event.SetColor(self.Properties.DefenderFaction, defenderFactionBgColor)
      local attackerFactionName = FactionCommon.factionInfoTable[attackerFaction].factionName
      local defenderFactionName = FactionCommon.factionInfoTable[defenderFaction].factionName
      UiTextBus.Event.SetTextWithFlags(self.Properties.AttackerFaction, attackerFactionName, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.DefenderFaction, defenderFactionName, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.WarTimeLabel, "@ui_wartime", eUiTextSet_SetLocalized)
    end
  end
end
function CompaniesAtWarListItem:GetWarDetails()
  local wars = self.GetWarDetailsFn(self.warDetailsFnSelf)
  return wars[Clamp(self.warIndex, 1, #wars)]
end
function CompaniesAtWarListItem:UpdateWarDetails()
  local warDetails = self:GetWarDetails()
  local timeRemainingSeconds = warDetails.timeRemainingSeconds
  local warPhase = warDetails.warPhase
  self.warPhase = warPhase
  local isInvasion = warDetails.isInvasion
  self.isInvasion = isInvasion
  local territoryId = warDetails.territoryId
  local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  local siegeStartTime = warDetails.siegeStartTime
  local warDateText = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime)
  local warTimeText = dominionCommon:GetSiegeWindowText(self.siegeWindow, true, false)
  local warDateTimeText = GetLocalizedReplacementText("@ui_siege_signup_warstart", {date = warDateText, time = warTimeText})
  UiTextBus.Event.SetTextWithFlags(self.Properties.WarDateTimeText, warDateTimeText, eUiTextSet_SetAsIs)
  local locationText = GetLocalizedReplacementText("@ui_siege_signup_fortressname", {territoryName = territoryName})
  UiTextBus.Event.SetTextWithFlags(self.Properties.LocationText, locationText, eUiTextSet_SetAsIs)
  local imagePath = "lyshineui/images/map/panelImages/mapPanel_territory" .. territoryId .. ".dds"
  local invalidImagePath = "lyshineui/images/map/panelImages/mapPanel_territory_default.dds"
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
    imagePath = invalidImagePath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryImage, imagePath)
end
return CompaniesAtWarListItem
