local StaticWorldMarker = {
  Properties = {
    Icon = {
      default = EntityId()
    }
  }
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local uiStyle = RequireScript("LyShineUI._Common.UIStyle")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function StaticWorldMarker:OnActivate()
  self.UIStyle = uiStyle
  tweener:OnActivate()
  registrar:RegisterEntity(self)
end
function StaticWorldMarker:OnDeactivate()
  tweener:OnDeactivate()
  registrar:UnregisterEntity(self)
  dataLayer:UnregisterObservers(self)
  self.markerClass = nil
end
function StaticWorldMarker:GetFactionNpcIcon()
  local rootEntityId = TransformBus.Event.GetRootId(self.markerId)
  if not rootEntityId then
    return
  end
  local npcData = NpcComponentRequestBus.Event.GetNpcData(rootEntityId)
  if not npcData then
    return
  end
  local npcFaction = npcData.GetNpcFactionAlignment(npcData.id)
  if npcFaction ~= eFactionType_None and npcFaction ~= eFactionType_Any then
    return FactionCommon.factionInfoTable[npcFaction].npcIcon
  end
end
function StaticWorldMarker:RefreshFactionNpcIcon()
  local npcIcon = self:GetFactionNpcIcon()
  if npcIcon then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, npcIcon)
  end
end
function StaticWorldMarker:RefreshNpcIcon(type, isInn)
  if not type then
    return
  end
  local imagePath
  local iconWidth = self.defaultWidth
  local iconHeight = self.defaultHeight
  if type == eConversationState_NoObjective then
    imagePath = "LyShineUI\\Images\\Icons\\Objectives\\npc_noObjective.dds"
    self.hasObjective = false
  elseif type == eConversationState_HasObjective then
    imagePath = "LyShineUI\\Images\\Icons\\Objectives\\icon_questAvailable_npc.dds"
    iconWidth = 160
    iconHeight = 160
    self.hasObjective = true
  elseif type == eConversationState_UnavailableObjective then
    imagePath = "LyShineUI\\Images\\Icons\\Objectives\\icon_questAvailable_npc.dds"
    iconWidth = 160
    iconHeight = 160
    self.hasObjective = false
  elseif type == eConversationState_HasFactionMissions then
    imagePath = "LyShineUI\\Images\\Icons\\Objectives\\icon_questAvailable_npc.dds"
    iconWidth = 160
    iconHeight = 160
    self.reupdateForFactionNpc = true
    local npcIcon = self:GetFactionNpcIcon()
    if npcIcon then
      imagePath = npcIcon
    end
    self.hasObjective = true
  elseif type == eConversationState_TurnIn then
    imagePath = "LyShineUI\\Images\\Icons\\Objectives\\icon_questReadyForTurnIn_npc.dds"
    iconWidth = 160
    iconHeight = 160
    self.hasObjective = true
  elseif type == eConversationState_InProgress then
    imagePath = "LyShineUI\\Images\\Icons\\Objectives\\icon_questInProgress_npc.dds"
    iconWidth = 160
    iconHeight = 160
    self.hasObjective = true
  else
    self.hasObjective = false
  end
  if not isInn or self.hasObjective then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePath)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, iconWidth)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, iconHeight)
  elseif isInn then
    self:RefreshInnIcon()
  end
end
function StaticWorldMarker:RefreshInnIcon()
  if self.hasObjective then
    return
  end
  local imagePath
  if self.isInnActive then
    imagePath = "LyShineUI\\Images\\icons\\objectives\\npc_inn.dds"
  else
    imagePath = "LyShineUI\\Images\\icons\\objectives\\npc_inn_inactive.dds"
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePath)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, self.defaultWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, self.defaultHeight)
end
function StaticWorldMarker:Init(dataPath)
  self.markerClass = UiMarkerBus.Event.GetMarker(self.entityId)
  if self.markerClass then
    self.defaultWidth = 50
    self.defaultHeight = 50
    dataLayer:RegisterDataCallback(self, dataPath .. ".MarkerComponentId", function(self, markerId)
      if not markerId then
        return
      end
      self.markerId = markerId
      self.markerClass:Initialize(markerId)
      if self.typeName == "Inn" then
        dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HomePoints.Count", function(self, count)
          local worldPosition = TransformBus.Event.GetWorldTranslation(markerId)
          if worldPosition then
            local territoryId = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryIdByPosition(worldPosition, true)
            if territoryId then
              self.isInnActive = PlayerHousingClientRequestBus.Broadcast.HasFastTravelPointInTerritory(territoryId, true)
              self:RefreshInnIcon()
            end
          end
        end)
        dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".NPCState", function(self, type)
          self:RefreshNpcIcon(type, true)
        end)
      else
        dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HomePoints.Count")
      end
      if self.reupdateForFactionNpc then
        self.reupdateForFactionNpc = false
        self:RefreshFactionNpcIcon()
      end
    end)
    dataLayer:RegisterDataCallback(self, dataPath .. ".StopUpdate", function(self)
      self.markerClass:Uninitialize()
    end)
    dataLayer:RegisterDataObserver(self, dataPath .. ".Type", function(self, typeName)
      self.reupdateForFactionNpc = false
      local imagePath
      local iconColor = self.UIStyle.COLOR_WHITE
      local iconWidth = self.defaultWidth
      local iconHeight = self.defaultHeight
      local isConversation = false
      local isHouse = false
      if typeName == "TownCenter" then
        imagePath = "LyShineUI\\Images\\Map\\Icon\\township.dds"
      elseif typeName == "TownCenter_Crafting" then
        imagePath = "LyShineUI\\Images\\Map\\Icon\\map_settlementClaimed.dds"
      elseif typeName == "MyHouse" then
        isHouse = true
        dataLayer:RegisterAndExecuteDataCallback(self, dataPath .. ".HouseTaxesPaid", function(self, taxesPaid)
          self:UpdateHouse(taxesPaid)
        end)
      elseif typeName == "FTUECaptain" then
        imagePath = "LyShineUI\\Images\\Icons\\Objectives\\icon_questAvailable_npc.dds"
        iconWidth = 160
        iconHeight = 160
      elseif typeName == "OutpostRush" then
        imagePath = "LyShineUI\\Images\\Icons\\OutpostRush\\icon_outpostrush_npc.dds"
        iconWidth = 160
        iconHeight = 160
      elseif typeName == "Conversation" then
        isConversation = true
        dataLayer:RegisterAndExecuteDataObserver(self, dataPath .. ".NPCState", function(self, type)
          self:RefreshNpcIcon(type, false)
        end)
      end
      if not isHouse then
        dataLayer:UnregisterObserver(self, dataPath .. ".HouseTaxesPaid")
      end
      if not isConversation then
        dataLayer:UnregisterObserver(self, dataPath .. ".NPCState")
      end
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, iconWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, iconHeight)
      UiImageBus.Event.SetColor(self.Properties.Icon, iconColor)
      if imagePath then
        UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePath)
      end
      self.typeName = typeName
    end)
    dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
      if self.typeName ~= "Conversation" then
        return
      end
      local npcState = dataLayer:GetDataFromNode(dataPath .. ".NPCState")
      if npcState == eConversationState_HasFactionMissions then
        self:RefreshFactionNpcIcon()
      end
    end)
  else
    Debug.Log("StaticWorldMarker: Unable to initialize marker with path " .. tostring(dataPath))
    return
  end
  dataLayer:RegisterDataObserver(self, dataPath .. ".IsVisible", self.SetIsVisible)
end
function StaticWorldMarker:SetIsVisible(isVisible)
  local isEnabled = isVisible == true
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
end
function StaticWorldMarker:UpdateHouse(taxesPaid)
  if not self.typeName == "MyHouse" then
    return
  end
  local homeIconPath = taxesPaid and "LyShineUI\\Images\\markers\\icon_map_house.dds" or "LyShineUI\\Images\\markers\\icon_map_house_disabled.dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, homeIconPath)
end
return StaticWorldMarker
