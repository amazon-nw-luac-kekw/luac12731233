local OwnershipAudioScript = {
  Properties = {
    Ownership_EntityId = {
      default = EntityId(),
      description = "Entity that has the Ownership Component",
      order = 1
    },
    Local_Player_NetworkTypeRTPC = {
      default = "0",
      description = "Local Player NetworkType RTPC value ",
      order = 2
    },
    Remote_Player_NetworkTypeRTPC = {
      default = "50",
      description = "Remote Player NetworkType RTPC value ",
      order = 3
    },
    RTPC_EntityId = {
      default = EntityId(),
      description = "Entity that has the RTPC Component",
      order = 4
    }
  }
}
function OwnershipAudioScript:OnActivate()
  if not self.Properties.Ownership_EntityId then
    return
  else
    local isLocalPlayer = OwnershipRequestBus.Event.IsOwnedByLocalPlayer(self.Properties.Ownership_EntityId)
    if isLocalPlayer == true then
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.RTPC_EntityId, "NetworkType", self.Properties.Local_Player_NetworkTypeRTPC)
    else
      AudioRtpcComponentRequestBus.Event.SetRtpcValue(self.Properties.RTPC_EntityId, "NetworkType", self.Properties.Remote_Player_NetworkTypeRTPC)
    end
  end
end
function OwnershipAudioScript:OnDeactivate()
end
return OwnershipAudioScript
