local FlyoutRow_PlayerHeader = {
  Properties = {
    NameText = {
      default = EntityId(),
      order = 1
    },
    GuildNameText = {
      default = EntityId(),
      order = 2
    },
    Portrait = {
      default = EntityId(),
      order = 4
    },
    PortraitIcon = {
      default = EntityId(),
      order = 5
    },
    GuildCrest = {
      default = EntityId(),
      order = 7
    },
    GuildCrestIcon = {
      default = EntityId(),
      order = 8
    },
    Level = {
      default = EntityId(),
      order = 13
    },
    LevelText = {
      default = EntityId(),
      order = 14
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_PlayerHeader)
function FlyoutRow_PlayerHeader:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildNameText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Portrait, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Level, false)
end
function FlyoutRow_PlayerHeader:OnShutdown()
end
function FlyoutRow_PlayerHeader:SetData(data)
  if not data then
    Log("[FlyoutRow_PlayerHeader] Error: invalid data passed to SetData")
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildNameText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Portrait, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Level, false)
  if data.name then
    UiTextBus.Event.SetText(self.Properties.NameText, data.name)
  end
  if data.icon then
    self.PortraitIcon:SetIcon(data.icon)
    UiImageBus.Event.SetColor(self.Properties.PortraitIcon, data.iconBg)
    UiElementBus.Event.SetIsEnabled(self.Properties.Portrait, true)
  end
  local hasGuild = data.guildName and data.guildName ~= ""
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildNameText, hasGuild)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrest, hasGuild)
  if hasGuild then
    UiTextBus.Event.SetText(self.Properties.GuildNameText, data.guildName)
  end
  if data.crest and data.crest.backgroundImagePath and #data.crest.backgroundImagePath > 0 then
    self.GuildCrestIcon:SetSmallIcon(data.crest)
  end
  if data.level and data.level ~= 0 then
    UiElementBus.Event.SetIsEnabled(self.Properties.Level, true)
    UiTextBus.Event.SetText(self.Properties.LevelText, tostring(data.level))
  end
end
return FlyoutRow_PlayerHeader
