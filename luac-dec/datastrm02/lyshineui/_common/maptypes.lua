local MapTypes = {}
function MapTypes:Init()
  self.iconTypes = {}
  self.iconTypes.Respawn = "Respawn"
  self.iconTypes.GroupMember = "GroupMember"
  self.iconTypes.LocalPlayer = "LocalPlayer"
  self.iconTypes.EntityTrackingIcon = "EntityTrackingIcon"
  self.iconTypes.PointOfInterest = "PointOfInterest"
  self.iconTypes.Settlement = "Settlement"
  self.iconTypes.FastTravel = "FastTravel"
  self.iconTypes.Outpost = "Outpost"
  self.iconTypes.PersonalPin = "PersonalPin"
  self.iconTypes.Waypoint = "Waypoint"
  self.iconTypes.Territory = "Territory"
  self.iconTypes.Death = "Death"
  self.iconTypes.GroupWaypoint = "GroupWaypoint"
  self.iconTypes.Region = "Region"
  self.iconTypes.AttackNotification = "AttackNotification"
  self.iconTypes.OWGMissionTurnIn = "OWGMissionTurnIn"
  self.iconTypes.TrackedObjective = "TrackedObjective"
  self.iconTypes.AvailableObjective = "AvailableObjective"
  self.iconTypes.RaidGroupLeader = "RaidGroupLeader"
  self.iconTypes.OutpostRushOutpost = "OutpostRushOutpost"
  self.iconTypes.OutpostRushMarkers = "OutpostRushMarkers"
  self.sourceTypes = {}
  self.sourceTypes.Map = "Map"
  self.sourceTypes.MiniMap = "MiniMap"
  self.sourceTypes.Compass = "Compass"
  self.sourceTypes.RespawnMap = "RespawnMap"
  self.sourceTypes.MainMenu = "MainMenu"
  self.panelTypes = {}
  self.panelTypes.Storage = "Storage"
  self.panelTypes.Territory = "Territory"
  self.panelTypes.TerritoryStanding = "TerritoryStanding"
  self.panelTypes.ObjectiveLocationList = "ObjectiveLocationList"
  self.panelTypes.Town = "Town"
  self.panelTypes.Fortress = "Fortress"
  self.panelTypes.SettlementWar = "SettlementWar"
  self.panelTypes.MapLegend = "MapLegend"
  self.panelTypes.Leaderboards = "Leaderboards"
  self.panelTypes.CompaniesAtWar = "CompaniesAtWar"
end
function CreateMapTypes(table)
  table:Init()
end
CreateMapTypes(MapTypes)
return MapTypes
