local RespawnStatRow = {
  Properties = {
    StatLabel = {
      default = EntityId()
    },
    StatLine = {
      default = EntityId()
    },
    StatData = {
      default = EntityId()
    },
    StatDataExtra = {
      default = EntityId()
    },
    StatGuildIcon = {
      default = EntityId()
    },
    StatTwitchIcon = {
      default = EntityId()
    },
    TwitchViewers = {
      default = EntityId()
    },
    WeaponHolder = {
      default = EntityId()
    },
    StatWeaponIcon = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    PlayerIconHolder = {
      default = EntityId()
    },
    PlayerLevelText = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    StatRowInfoHolder = {
      default = EntityId()
    }
  },
  STYLE_TYPE_ITEM = 1,
  STYLE_TYPE_TIME = 2,
  STYLE_TYPE_LEFT_ALIGN = 3,
  STYLE_TYPE_KILLER = 1,
  STYLE_TYPE_KILLER_USED = 2,
  STYLE_TYPE_KILLER_NPC = 3,
  STYLE_TYPE_TWITCH = 4,
  STYLE_TYPE_SURVIVED = 5,
  width = nil,
  height = nil,
  data = nil,
  onFocusCallback = nil,
  onFocusCallbackTable = nil,
  onUnfocusCallback = nil,
  onUnfocusCallbackTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RespawnStatRow)
function RespawnStatRow:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.StatLabel, self.UIStyle.FONT_STYLE_DEATH_STAT_LABEL_TAN)
  SetTextStyle(self.Properties.StatData, self.UIStyle.FONT_STYLE_DEATH_STAT_DATA)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function RespawnStatRow:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function RespawnStatRow:GetWidth()
  return self.width
end
function RespawnStatRow:GetHeight()
  return self.height
end
function RespawnStatRow:SetStatStyle(value)
  if value == self.STYLE_TYPE_KILLER then
    local killerNameSytle = {
      fontFamily = self.UIStyle.FONT_FAMILY_PICA,
      fontSize = 50,
      fontColor = self.UIStyle.COLOR_RED_DARK,
      characterSpacing = 80,
      hAlignment = self.UIStyle.TEXT_HALIGN_LEFT
    }
    local killerGuildStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
      fontSize = 32,
      fontColor = self.UIStyle.COLOR_TAN,
      characterSpacing = 0,
      hAlignment = self.UIStyle.TEXT_HALIGN_LEFT
    }
    SetTextStyle(self.Properties.StatData, killerNameSytle)
    SetTextStyle(self.Properties.StatDataExtra, killerGuildStyle)
    local offsetPosX = 110
    local offsetPosY = -7
    self.ScriptedEntityTweener:Set(self.Properties.StatData, {x = offsetPosX, y = offsetPosY})
  elseif value == self.STYLE_TYPE_KILLER_NPC then
    local killerNameSytle = {
      fontFamily = self.UIStyle.FONT_FAMILY_PICA,
      fontSize = 60,
      fontColor = self.UIStyle.COLOR_RED_DARK,
      characterSpacing = 80,
      textCasing = self.UIStyle.TEXT_CASING_UPPER
    }
    SetTextStyle(self.Properties.StatLabel, self.UIStyle.FONT_STYLE_DEATH_STAT_LABEL_TAN)
    SetTextStyle(self.Properties.StatData, killerNameSytle)
    local offsetPosY = -30
    self.ScriptedEntityTweener:Set(self.Properties.StatData, {y = offsetPosY})
  elseif value == self.STYLE_TYPE_KILLER_USED then
    local killerUsedStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_PICA,
      fontSize = 26,
      fontColor = self.UIStyle.COLOR_TAN,
      characterSpacing = 150,
      textCasing = self.UIStyle.TEXT_CASING_UPPER,
      textWrapping = self.UIStyle.TEXT_WRAP_SETTING_WRAP,
      lineSpacing = 3
    }
    SetTextStyle(self.Properties.StatData, killerUsedStyle)
    local offsetPosX = 92
    local offsetPosY = 6
    self.ScriptedEntityTweener:Set(self.Properties.StatData, {x = offsetPosX, y = offsetPosY})
  elseif value == self.STYLE_TYPE_SURVIVED then
    local survivedTimeStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
      fontSize = 55,
      fontColor = self.UIStyle.COLOR_WHITE,
      characterSpacing = 0
    }
    local personalBestStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
      fontSize = 28,
      fontColor = self.UIStyle.COLOR_WHITE,
      characterSpacing = 0,
      textCasing = self.UIStyle.TEXT_CASING_UPPER
    }
    SetTextStyle(self.Properties.StatData, survivedTimeStyle)
    SetTextStyle(self.Properties.StatDataExtra, personalBestStyle)
    local offsetPosY = self:GetTextDataExtra() ~= "" and -10 or 0
    self.ScriptedEntityTweener:Set(self.Properties.StatData, {y = offsetPosY})
  end
end
function RespawnStatRow:SetFocusCallback(command, table)
  self.onFocusCallback = command
  self.onFocusCallbackTable = table
end
function RespawnStatRow:SetUnfocusCallback(command, table)
  self.onUnfocusCallback = command
  self.onUnfocusCallbackTable = table
end
function RespawnStatRow:SetTwitchInfo(icon, viewers)
  if viewers == nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.StatTwitchIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchViewers, false)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.StatRowInfoHolder, 6)
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StatTwitchIcon, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.TwitchViewers, true)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.StatRowInfoHolder, -3)
  UiTextBus.Event.SetText(self.Properties.TwitchViewers, viewers)
  self.StatTwitchIcon:SetIcon(icon)
end
function RespawnStatRow:SetGuildCrestIcon(enabled, value, foregroundNotVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatGuildIcon, enabled)
  if enabled then
    self.StatGuildIcon:SetIcon(value)
    if foregroundNotVisible then
      self.StatGuildIcon:SetForegroundVisibility(false)
    else
      self.StatGuildIcon:SetForegroundVisibility(true)
    end
  end
end
function RespawnStatRow:SetPlayerId(playerId)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIconHolder, true)
  self.PlayerIcon:SetPlayerId(playerId)
end
function RespawnStatRow:SetWeaponIcon(path)
  self.StatWeaponIcon:SetIcon(path)
  UiElementBus.Event.SetIsEnabled(self.Properties.WeaponHolder, true)
end
function RespawnStatRow:SetFactionIcon(enabled, path, color)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, enabled)
  if enabled then
    UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, path)
    UiImageBus.Event.SetColor(self.Properties.FactionIcon, color)
    self:SetDataExtraOffset(32)
  else
    self:SetDataExtraOffset(3)
  end
end
function RespawnStatRow:SetPlayerLevelText(value)
  UiTextBus.Event.SetText(self.Properties.PlayerLevelText, value)
end
function RespawnStatRow:SetNoIconOffset()
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIconHolder, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatGuildIcon, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, false)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.StatData, 0)
end
function RespawnStatRow:SetDataExtraOffset(value)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.StatDataExtra, value)
end
function RespawnStatRow:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatLabel, value, eUiTextSet_SetLocalized)
end
function RespawnStatRow:ShowStatLine(isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatLine, isVisible)
end
function RespawnStatRow:GetText()
  return UiTextBus.Event.GetText(self.Properties.StatLabel)
end
function RespawnStatRow:SetTextData(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatData, value, eUiTextSet_SetLocalized)
end
function RespawnStatRow:GetTextData()
  return UiTextBus.Event.GetText(self.Properties.StatData)
end
function RespawnStatRow:SetStatInfoHolderPositionX(offset)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.StatRowInfoHolder, offset)
end
function RespawnStatRow:SetTextDataExtra(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.StatDataExtra, value, eUiTextSet_SetLocalized)
end
function RespawnStatRow:GetTextDataExtra()
  return UiTextBus.Event.GetText(self.Properties.StatDataExtra)
end
function RespawnStatRow:OnFocus()
  if self.onFocusCallback ~= nil and self.onFocusCallbackTable ~= nil then
    if type(self.onFocusCallback) == "function" then
      self.onFocusCallback(self.onFocusCallbackTable)
    else
      self.onFocusCallbackTable[self.onFocusCallback](self.onFocusCallbackTable)
    end
    self.audioHelper:PlaySound(self.audioHelper.OnHover)
  end
end
function RespawnStatRow:OnUnfocus()
  if self.onUnfocusCallback ~= nil and self.onUnfocusCallbackTable ~= nil then
    if type(self.onUnfocusCallback) == "function" then
      self.onUnfocusCallback(self.onUnfocusCallbackTable)
    else
      self.onUnfocusCallbackTable[self.onUnfocusCallback](self.onUnfocusCallbackTable)
    end
  end
end
return RespawnStatRow
