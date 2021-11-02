local WorldList = {
  Properties = {
    ServerCountEntity = {
      default = EntityId()
    }
  }
}
function WorldList:OnActivate()
  if not self.Properties.ServerCountEntity:IsValid() then
    Debug.Log("WorldList: Lua property ServerCountEntity is not set")
  end
  self.handler = UiWorldListBus.Connect(self, self.entityId)
  UiTextBus.Event.SetIsMarkupEnabled(self.Properties.ServerCountEntity, true)
end
function WorldList:OnDeactivate()
  self.handler:Disconnect()
end
function WorldList:SetWorldCount(worldCount)
  if 0 < worldCount then
    countText = "@mm_serversavailable"
    if worldCount == 1 then
      countText = "@mm_serveravailable"
    end
    local worldCountText = string.format("<font face=\"lyshineui/fonts/CaslonAnt.font\">%d</font>", worldCount)
    worldListCountText = GetLocalizedReplacementText(countText, {numServers = worldCountText})
  else
    worldListCountText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@mm_serverunavailable")
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ServerCountEntity, worldListCountText, eUiTextSet_SetAsIs)
end
return WorldList
