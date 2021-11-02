local GuildFlag = {
  Properties = {
    Foreground = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    Scrim = {
      default = EntityId()
    }
  }
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(GuildFlag)
function GuildFlag:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiGuildFlagNotificationBus, self.canvasId)
end
function GuildFlag:OnGuildCrestChanged(guildCrestData)
  local dimColor = Color(guildCrestData.backgroundColor.r * 0.8, guildCrestData.backgroundColor.g * 0.8, guildCrestData.backgroundColor.b * 0.8, 1)
  UiImageBus.Event.SetColor(self.Properties.Foreground, guildCrestData.foregroundColor)
  UiImageBus.Event.SetColor(self.Properties.Background, guildCrestData.backgroundColor)
  UiImageBus.Event.SetColor(self.Properties.Scrim, dimColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.Foreground, guildCrestData.foregroundImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.Background, guildCrestData.backgroundImagePath)
end
return GuildFlag
