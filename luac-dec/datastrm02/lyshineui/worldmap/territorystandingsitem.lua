local TerritoryStandingsItem = {
  Properties = {
    BG = {
      default = EntityId()
    },
    TerritoryName = {
      default = EntityId()
    },
    RankTitle = {
      default = EntityId()
    },
    RankNumber = {
      default = EntityId()
    },
    TokensIndicator = {
      default = EntityId()
    },
    TokensCount = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    TerritoryImage = {
      default = EntityId()
    },
    StandingProgressBar = {
      default = EntityId()
    },
    StandingProgressBarLabel = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryStandingsItem)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function TerritoryStandingsItem:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
end
function TerritoryStandingsItem:SetTerritoryData(data, territoryStandingsPane, cb)
  self.territoryStandingsPane = territoryStandingsPane
  self.cb = cb
  self.territoryId = data.territoryId
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryName, data.nameLocalizationKey, eUiTextSet_SetLocalized)
  local standing = TerritoryDataHandler:GetTerritoryStanding(self.territoryId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RankNumber, standing.rank, eUiTextSet_SetAsIs)
  local titleText = GetLocalizedReplacementText("@ui_standing_title_of", {
    standing = standing.displayName
  })
  local imagePath = "lyshineui/images/map/tooltipImages/mapTooltip_territory" .. self.territoryId .. ".dds"
  local invalidImagePath = "lyshineui/images/map/tooltipImages/mapTooltip_territory_default.dds"
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
    imagePath = invalidImagePath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryImage, imagePath)
  UiTextBus.Event.SetTextWithFlags(self.Properties.RankTitle, titleText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.TokensIndicator, standing.tokens > 0)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TokensCount, tostring(standing.tokens), eUiTextSet_SetAsIs)
  local progressionId = Math.CreateCrc32(tostring(self.territoryId))
  local currentLevel = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, progressionId) or 0
  local currentProgress = CategoricalProgressionRequestBus.Event.GetProgression(self.playerEntityId, progressionId) or 0
  local maxProgress = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, progressionId, currentLevel) or 1
  local percent = currentProgress / maxProgress
  self.ScriptedEntityTweener:Set(self.Properties.StandingProgressBar, {scaleX = percent})
  UiTextBus.Event.SetText(self.Properties.StandingProgressBarLabel, currentProgress .. " / " .. maxProgress)
end
function TerritoryStandingsItem:OnFocus(entity)
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 1})
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function TerritoryStandingsItem:OnUnfocus(entity)
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
end
function TerritoryStandingsItem:OnPressed(entity)
  if self.cb then
    self.cb(self.territoryStandingsPane, self.territoryId)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
return TerritoryStandingsItem
