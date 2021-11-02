local SetRtpcOnActivate = {
  Properties = {
    rtpcName = {
      default = "",
      description = "Name of the RTPC.",
      order = 0
    },
    rtpcValue = {
      default = "",
      description = "Value of the RTPC to be set on activate",
      order = 1
    }
  }
}
function SetRtpcOnActivate:OnActivate()
  if self.Properties.rtpcName ~= "" then
    if self.Properties.rtpcValue == "" then
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, self.Properties.rtpcName, 0)
    else
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.entityId, self.Properties.rtpcName, self.Properties.rtpcValue)
    end
  end
end
return SetRtpcOnActivate
