local SiegeMarkerData = {
  ICON_NONE = 0,
  ICON_KEEP = 1,
  ICON_GATE = 2,
  ICON_CONTESTED = 1,
  ICON_LOCKED = 2,
  USAGE_NONE = 0,
  USAGE_SIEGE = 1,
  USAGE_OR = 2,
  USAGE_FCP = 4
}
SiegeMarkerData.siegeData = {}
SiegeMarkerData.siegeData[eFortSpawnId_CapturePoint_A] = {text = "A", icon = nil}
SiegeMarkerData.siegeData[eFortSpawnId_CapturePoint_B] = {text = "B", icon = nil}
SiegeMarkerData.siegeData[eFortSpawnId_CapturePoint_C] = {text = "C", icon = nil}
SiegeMarkerData.siegeData[eFortSpawnId_CapturePoint_Claim] = {
  text = nil,
  icon = SiegeMarkerData.ICON_KEEP
}
SiegeMarkerData.siegeData[eFortSpawnId_Gate_A] = {
  text = nil,
  icon = SiegeMarkerData.ICON_GATE
}
SiegeMarkerData.siegeData[eFortSpawnId_Gate_B] = {
  text = nil,
  icon = SiegeMarkerData.ICON_GATE
}
SiegeMarkerData.siegeData[eFortSpawnId_Gate_C] = {
  text = nil,
  icon = SiegeMarkerData.ICON_GATE
}
SiegeMarkerData.siegeData[eFortSpawnId_Gate_D] = {
  text = nil,
  icon = SiegeMarkerData.ICON_GATE
}
SiegeMarkerData.siegeData[eFortSpawnId_Gate_E] = {
  text = nil,
  icon = SiegeMarkerData.ICON_GATE
}
return SiegeMarkerData
