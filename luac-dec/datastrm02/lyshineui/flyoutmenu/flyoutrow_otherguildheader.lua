local FlyoutRow_OtherGuildHeader = {
  Properties = {
    GuildNameText = {
      default = EntityId()
    },
    GuildMasterText = {
      default = EntityId()
    },
    GuildCrestIcon = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_OtherGuildHeader)
function FlyoutRow_OtherGuildHeader:OnInit()
  BaseElement.OnInit(self)
end
function FlyoutRow_OtherGuildHeader:SetData(data)
  if not data then
    Log("[FlyoutRow_OtherGuildHeader] Error: invalid data passed to SetData")
    return
  end
  UiTextBus.Event.SetText(self.GuildNameText, data.guildName)
  self.GuildCrestIcon:SetSmallIcon(data.crestData)
end
return FlyoutRow_OtherGuildHeader
