local PlayerStandoutListItem = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Portrait = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    Rank = {
      default = EntityId()
    },
    Name = {
      default = EntityId()
    },
    Score = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    InvasionBackground = {
      default = EntityId()
    },
    InvasionScore = {
      default = EntityId()
    },
    InvasionHighlight = {
      default = EntityId()
    }
  },
  gameMode = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PlayerStandoutListItem)
local warboardCommon = RequireScript("LyShineUI.Warboard.WarboardCommon")
function PlayerStandoutListItem:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.InvasionHighlight, false)
  SetTextStyle(self.Properties.Rank, self.UIStyle.FONT_STYLE_WARBOARD_STANDOUT_LINE)
  SetTextStyle(self.Properties.Name, self.UIStyle.FONT_STYLE_WARBOARD_STANDOUT_LINE)
  SetTextStyle(self.Properties.Score, self.UIStyle.FONT_STYLE_WARBOARD_STANDOUT_LINE)
  SetTextStyle(self.Properties.InvasionScore, self.UIStyle.FONT_STYLE_WARBOARD_STANDOUT_LINE)
end
function PlayerStandoutListItem:OnShutdown()
end
function PlayerStandoutListItem:SetData(data)
  self.gameMode = DynamicBus.WarboardEndOfMatch.Broadcast.GetGameMode()
  local rank = data.values[warboardCommon.rankIndex]
  local score = self:GetValue(data, WarboardStatsEntry.eWarboardStatType_Score)
  UiTextBus.Event.SetText(self.Properties.Rank, rank)
  UiTextBus.Event.SetText(self.Properties.Name, data.values[warboardCommon.nameIndex])
  UiTextBus.Event.SetText(self.Properties.Score, score)
  UiTextBus.Event.SetText(self.Properties.InvasionScore, score)
  if data.playerId then
    self.PlayerIcon:SetPlayerId(data.playerId)
  end
  if data.color then
    UiImageBus.Event.SetColor(self.Properties.Background, data.color)
    UiImageBus.Event.SetColor(self.Properties.InvasionBackground, data.color)
    local opacity = 0.3
    if rank % 2 == 0 then
      opacity = 0.15
    end
    UiImageBus.Event.SetAlpha(self.Properties.Background, opacity)
    UiImageBus.Event.SetAlpha(self.Properties.InvasionBackground, opacity)
  end
  local highlight = false
  if data.highlight then
    highlight = data.highlight
  end
  local factionColorLight = self.UIStyle.COLOR_WHITE
  if data.factionColorLight then
    factionColorLight = data.factionColorLight
  end
  local isInvasion = false
  if data.isInvasion then
    isInvasion = data.isInvasion
  end
  if highlight then
    UiTextBus.Event.SetColor(self.Properties.Name, self.UIStyle.COLOR_WHITE)
    UiTextBus.Event.SetColor(self.Properties.Score, self.UIStyle.COLOR_WHITE)
    UiTextBus.Event.SetColor(self.Properties.InvasionScore, self.UIStyle.COLOR_WHITE)
  else
    UiTextBus.Event.SetColor(self.Properties.Name, factionColorLight)
    UiTextBus.Event.SetColor(self.Properties.Score, factionColorLight)
    UiTextBus.Event.SetColor(self.Properties.InvasionScore, factionColorLight)
  end
  if not isInvasion then
    UiElementBus.Event.SetIsEnabled(self.Properties.Background, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionBackground, false)
    if highlight then
      UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.InvasionHighlight, false)
      UiImageBus.Event.SetAlpha(self.Properties.Background, 0.1)
      UiImageBus.Event.SetColor(self.Properties.Highlight, factionColorLight)
    end
  end
  if data.isConnected then
    UiDesaturatorBus.Event.SetSaturationValue(self.Properties.PlayerIcon, 1)
    UiTextBus.Event.SetColor(self.Properties.Name, self.UIStyle.COLOR_WHITE)
    self.PlayerIcon:SetDarkener(false)
  else
    UiDesaturatorBus.Event.SetSaturationValue(self.Properties.PlayerIcon, 0)
    UiTextBus.Event.SetColor(self.Properties.Name, self.UIStyle.COLOR_GRAY_50)
    self.PlayerIcon:SetDarkener(true)
  end
  if isInvasion then
    UiElementBus.Event.SetIsEnabled(self.Properties.Background, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.InvasionBackground, true)
    if highlight then
      UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.InvasionHighlight, true)
      UiImageBus.Event.SetAlpha(self.Properties.InvasionBackground, 0.1)
      UiImageBus.Event.SetColor(self.Properties.InvasionHighlight, factionColorLight)
    end
  end
end
function PlayerStandoutListItem:GetValue(data, enumIndex)
  local index = warboardCommon:GetStatIndex(self.gameMode, enumIndex)
  if index ~= warboardCommon.rankIndex then
    return data.values[index]
  end
  return 0
end
return PlayerStandoutListItem
