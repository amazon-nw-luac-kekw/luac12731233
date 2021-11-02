local markerCommon = RequireScript("LyShineUI.Markers.MarkerCommon")
local MarkerManager = {
  Properties = {
    MarkerTypes = {
      GenericMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type"
      },
      GatherableMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type"
      },
      StructureMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Structure"
      },
      AIMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type AI"
      },
      FullPlayerMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Player"
      },
      MediumPlayerMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Player"
      },
      SimplePlayerMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Player"
      },
      GroupPlayerMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Player"
      },
      ClaimPointMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Claim Point"
      },
      SiegeWeaponMarkers = {
        default = {
          EntityId()
        },
        description = "List of slice type Siege Weapon"
      },
      StaticPositionMarkers = {
        default = {
          EntityId()
        },
        description = "Slice type Static Position"
      }
    },
    InteractCardTypes = {
      StructureInteract = {
        default = EntityId(),
        description = "Interact card for structure interactables, will default to this when not found"
      },
      GatherableInteract = {
        default = EntityId(),
        description = "Interact card for gatherables"
      }
    },
    MarkerMode = {
      default = true,
      description = "If marker mode, only markers are initialized, otherwise only interacts are initialized"
    }
  },
  defaultMarkerId = "DefaultNoMarker",
  screenStateDesiredVisibility = true,
  giveUpIsVisible = false
}
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local markerTypeData = RequireScript("LyShineUI.Markers.MarkerData")
local profiler = RequireScript("LyShineUI._Common.Profiler")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local MARKER_TYPE_KEY_INDEX = 1
local MARKER_LIST_INDEX = 2
local MARKER_PRIMARY_TYPE_INDEX = 3
local MARKER_SECONDARY_TYPE_INDEX = 4
local GATHERABLE_MARKERS = 5
local GENERIC_MARKERS = 1
local STRUCTURE_MARKERS = 4
local AI_MARKERS = 4
local SIMPLE_PLAYER_MARKERS = 16
local MEDIUM_PLAYER_MARKERS = 4
local FULL_PLAYER_MARKERS = 1
local GROUP_MARKERS = 5
local WAR_CAPTURE_MARKERS = 9
local SIEGE_WEAPON_MARKERS = 5
local STATIC_POSITION_MARKERS = 10
function MarkerManager:OnActivate()
  self.registrar = registrar
  self.dataLayer = dataLayer
  self.screenStatesToDisable = markerCommon.screenStatesToDisable
  self.enableAsyncCanvasLoading = self.dataLayer:GetDataFromNode("UIFeatures.multithreadCanvases")
  if self.enableAsyncCanvasLoading then
    MEDIUM_PLAYER_MARKERS = 10
    FULL_PLAYER_MARKERS = 5
  end
  local enableNameplateSlider = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enableNameplateSlider")
  if enableNameplateSlider then
    local nameplateAdditionalQuantity = math.floor(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Video.NameplateQuantity"))
    FULL_PLAYER_MARKERS = math.floor(math.max(1, nameplateAdditionalQuantity * 0.33))
    MEDIUM_PLAYER_MARKERS = math.max(1, nameplateAdditionalQuantity - FULL_PLAYER_MARKERS)
  end
  if self.tickBusHandler == nil then
    self.markerTypeData = markerTypeData
    self.typeToMarkerMap = {
      {
        "SiegeStructure",
        self.Properties.MarkerTypes.ClaimPointMarkers,
        "SiegeStructure"
      },
      {
        "Harvester",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Dwelling",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Structure",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "HouseInteract",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures",
        "NoOffset"
      },
      {
        "Station",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures",
        "HigherDot"
      },
      {
        "CraftingStation",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures",
        "HigherDot"
      },
      {
        "Generating",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Lighting",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Camp",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures",
        "Camp"
      },
      {
        "Claim",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Master_Plants",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable",
        "MediumLowerDot"
      },
      {
        "Farm",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Master_Bush",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Master_Log",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Master_Minerals",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable",
        "LowerDot"
      },
      {
        "Master_Stones",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable",
        "LowerDot"
      },
      {
        "Master_Tree",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Master_Alchemy",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Master_Darkness",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Master_Quest",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Darkness_CorruptedCore_A",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Darkness_CorruptedFissure_A",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Darkness_CorruptedGrowth_A",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Darkness_CorruptedPylon_A",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "DroppedItem",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "POI_LootContainer",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures"
      },
      {
        "Bear",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Bear"
      },
      {
        "Wolf",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Wolf"
      },
      {
        "Cat",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Cat"
      },
      {
        "Alligator",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Alligator"
      },
      {
        "Turkey",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Turkey"
      },
      {
        "GuardDog",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Wolf"
      },
      {
        "Boar",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Boar"
      },
      {
        "Elk",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Elk"
      },
      {
        "Bison",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Bison"
      },
      {
        "Buffalo",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Elk"
      },
      {
        "Cow",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Cow"
      },
      {
        "Goat",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Goat"
      },
      {
        "Pig",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Boar"
      },
      {
        "Ghost",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Ghost"
      },
      {
        "Hound",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Hound"
      },
      {
        "Skeleton_Crawler",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAICrawl"
      },
      {
        "Skeleton",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAI"
      },
      {
        "Ancient",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAI"
      },
      {
        "Damned_LongSwordsman_Commander",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Commander"
      },
      {
        "Heavy",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAITall"
      },
      {
        "HumanAITall",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAITall"
      },
      {
        "Empress",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Empress"
      },
      {
        "Naga_AngryEarth",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Naga_AngryEarth"
      },
      {
        "Naga",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Naga"
      },
      {
        "Isabella",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Isabella"
      },
      {
        "Tendril",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Tendril"
      },
      {
        "Spriggan_Corrupted",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "SprigganAITall"
      },
      {
        "Spriggan_Forest",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "SprigganAITall"
      },
      {
        "Invasion_Spriggan",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "SprigganAITall"
      },
      {
        "Spriggan",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "SprigganAITall"
      },
      {
        "Brute",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Brute"
      },
      {
        "Damned",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAI"
      },
      {
        "Humanoid",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAI"
      },
      {
        "Grunt",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Grunt"
      },
      {
        "Rabbit_snowshoe",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Rabbit_snowshoe"
      },
      {
        "Rabbit_spotted",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "Rabbit_spotted"
      },
      {
        "Master_LootContainer",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "FTUE_Chest",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "Risen",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAI"
      },
      {
        "RootPlayer",
        self.Properties.MarkerTypes.FullPlayerMarkers,
        "Health",
        "Player"
      },
      {
        "Drowned_sailor",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "HumanAI"
      },
      {
        "LoreItems",
        self.Properties.MarkerTypes.GatherableMarkers,
        "LoreReader",
        "LowerDot"
      },
      {
        "Conversation",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "Conversation"
      },
      {
        "Inn",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "Conversation"
      },
      {
        "OutpostRush",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "Conversation"
      },
      {
        "FTUECaptain",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "Conversation",
        "FTUEConversation"
      },
      {
        "TownCenter_Crafting",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "TownCenter"
      },
      {
        "TownCenter",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "TownCenter"
      },
      {
        "MyHouse",
        self.Properties.MarkerTypes.StaticPositionMarkers,
        "TownCenter"
      },
      {
        "SiegeWeapon",
        self.Properties.MarkerTypes.SiegeWeaponMarkers,
        "SiegeWeapon"
      },
      {
        "DungeonObjective",
        self.Properties.MarkerTypes.GatherableMarkers,
        "Gatherable"
      },
      {
        "IceGauntlet",
        self.Properties.MarkerTypes.AIMarkers,
        "AI",
        "IceGauntlet"
      },
      {
        "OR_Outpost_Gate_T1",
        self.Properties.MarkerTypes.StructureMarkers,
        "Structures",
        "OutpostRush"
      }
    }
    if self.Properties.MarkerMode then
      self.isLoadingScreenShowing = LoadScreenBus.Broadcast.IsLoadingScreenShown()
      LyShineDataLayerBus.Broadcast.SetData("Global.OnLoadingScreenDismissed", not self.isLoadingScreenShowing)
      self.loadScreenHandler = LoadScreenNotificationBus.Connect(self, self.entityId)
      self.markersInitializationData = {
        GenericMarkers = {
          initialize = true,
          register = false,
          identifier = "u"
        },
        GatherableMarkers = {
          initialize = true,
          register = false,
          identifier = "g"
        },
        StructureMarkers = {
          initialize = true,
          register = false,
          identifier = "s"
        },
        AIMarkers = {
          initialize = true,
          register = false,
          identifier = "a"
        },
        FullPlayerMarkers = {
          initialize = true,
          register = false,
          identifier = "p"
        },
        MediumPlayerMarkers = {
          initialize = true,
          register = false,
          identifier = "pm"
        },
        SimplePlayerMarkers = {
          initialize = true,
          register = false,
          identifier = "ps"
        },
        GroupPlayerMarkers = {
          initialize = false,
          register = true,
          identifier = nil
        },
        ClaimPointMarkers = {
          initialize = false,
          register = true,
          identifier = nil
        },
        SiegeWeaponMarkers = {
          initialize = true,
          register = false,
          identifier = "sw"
        },
        StaticPositionMarkers = {
          initialize = true,
          register = false,
          identifier = "w"
        }
      }
      dataLayer:RegisterAndExecuteDataCallback(self, "Hud.Markers.LocalPlayerMarkerSet", function(self, isSet)
        if isSet then
          local isComponentInitialized = LocalPlayerMarkerRequestBus.Broadcast.IsReadyToDisplay()
          if isComponentInitialized then
            return
          end
          local playerMarkerIds = {"p"}
          local playerMarkerSizeInfo = vector_int()
          playerMarkerSizeInfo:push_back(FULL_PLAYER_MARKERS)
          playerMarkerSizeInfo:push_back(MEDIUM_PLAYER_MARKERS)
          playerMarkerSizeInfo:push_back(SIMPLE_PLAYER_MARKERS)
          playerMarkerIds = {
            "p",
            "pm",
            "ps"
          }
          local playerMarkerUpdateRate = vector_int()
          playerMarkerUpdateRate:push_back(2)
          playerMarkerUpdateRate:push_back(2)
          playerMarkerUpdateRate:push_back(6)
          local genericMarkerSizeInfo = vector_int()
          genericMarkerSizeInfo:push_back(GENERIC_MARKERS)
          local gatherableMarkerSizeInfo = vector_int()
          gatherableMarkerSizeInfo:push_back(GATHERABLE_MARKERS)
          local structureMarkerSizeInfo = vector_int()
          structureMarkerSizeInfo:push_back(STRUCTURE_MARKERS)
          local aiMarkerSizeInfo = vector_int()
          aiMarkerSizeInfo:push_back(AI_MARKERS)
          local staticMarkerSizeInfo = vector_int()
          staticMarkerSizeInfo:push_back(STATIC_POSITION_MARKERS)
          local siegeMarkerSizeInfo = vector_int()
          siegeMarkerSizeInfo:push_back(WAR_CAPTURE_MARKERS)
          local siegeWeaponMarkerSizeInfo = vector_int()
          siegeWeaponMarkerSizeInfo:push_back(SIEGE_WEAPON_MARKERS)
          local listToInfo = {}
          local fullPlayerMarkers = self.Properties.MarkerTypes.FullPlayerMarkers
          listToInfo[fullPlayerMarkers] = {
            sizes = playerMarkerSizeInfo,
            identifier = playerMarkerIds,
            updateRate = playerMarkerUpdateRate
          }
          listToInfo[self.Properties.MarkerTypes.GenericMarkers] = {sizes = genericMarkerSizeInfo, identifier = "u"}
          listToInfo[self.Properties.MarkerTypes.GatherableMarkers] = {sizes = gatherableMarkerSizeInfo, identifier = "g"}
          listToInfo[self.Properties.MarkerTypes.StructureMarkers] = {sizes = structureMarkerSizeInfo, identifier = "s"}
          listToInfo[self.Properties.MarkerTypes.AIMarkers] = {sizes = aiMarkerSizeInfo, identifier = "a"}
          listToInfo[self.Properties.MarkerTypes.StaticPositionMarkers] = {sizes = staticMarkerSizeInfo, identifier = "w"}
          listToInfo[self.Properties.MarkerTypes.ClaimPointMarkers] = {sizes = siegeMarkerSizeInfo, identifier = "c"}
          listToInfo[self.Properties.MarkerTypes.SiegeWeaponMarkers] = {sizes = siegeWeaponMarkerSizeInfo, identifier = "sw"}
          local isDataCached = CountAssociativeTable(self.markerTypeData.cachedTypes) > 0
          local emptyUpdateRate = vector_int()
          for _, markerData in ipairs(self.typeToMarkerMap) do
            local markerTypeName = markerData[MARKER_TYPE_KEY_INDEX]
            local typeInfo = ShallowCopy(self:GetInitialTypeInfo(markerData[MARKER_PRIMARY_TYPE_INDEX]))
            local subTypeName = markerData[MARKER_SECONDARY_TYPE_INDEX]
            if subTypeName and typeInfo.SubTypes then
              local subtypeInfo = typeInfo.SubTypes[subTypeName]
              if subtypeInfo then
                Merge(typeInfo, subtypeInfo, true, false, true)
              end
            end
            local markerParams = MarkerParams()
            markerParams.wX = typeInfo.wX
            markerParams.wY = typeInfo.wY
            markerParams.wZ = typeInfo.wZ
            markerParams.sX = typeInfo.sX
            markerParams.sY = typeInfo.sY
            markerParams.allowWorldOcclusion = typeInfo.allowWorldOcclusion
            markerParams.maxAlpha = typeInfo.maxAlpha
            markerParams.minAlpha = typeInfo.minAlpha
            markerParams.maxScale = typeInfo.maxScale
            markerParams.scaleStart = typeInfo.scaleStart
            markerParams.scaleDistance = typeInfo.scaleDistance
            markerParams.minScale = typeInfo.minScale
            if typeInfo.fadeDelta then
              markerParams.fadeDelta = typeInfo.fadeDelta
            else
              markerParams.fadeStart = typeInfo.fadeStart
              markerParams.fadeDistance = typeInfo.fadeDistance
            end
            if typeInfo.usePlayerDistancePriorities then
              local distancePriorities = markerTypeData.distancePriorities
              local vec = markerParams.distancePriorities
              for _, pri in ipairs(distancePriorities) do
                vec:push_back(pri)
              end
              markerParams.distancePriorities = vec
            end
            if typeInfo.offsetOnDeath then
              markerParams.offsetOnDeath = true
              markerParams.deathPosOffset = typeInfo.deathPosOffset
            end
            if typeInfo.keepOnScreen then
              markerParams.keepOnScreen = true
            end
            if typeInfo.clampYToScreen then
              markerParams.clampYToScreen = true
            end
            if typeInfo.delayBeforeApplyDeathOffset then
              markerParams.delayBeforeApplyDeathOffset = typeInfo.delayBeforeApplyDeathOffset
            end
            if typeInfo.interactWorldZOffset then
              markerParams.interactWorldZOffset = typeInfo.interactWorldZOffset
            end
            LocalPlayerMarkerRequestBus.Broadcast.SetMarkerParams(markerTypeName, markerParams)
            if not isDataCached then
              markerTypeData:CacheType(markerTypeName, typeInfo)
            end
            local info = listToInfo[markerData[MARKER_LIST_INDEX]]
            if not info.types then
              info.types = vector_basic_string_char_char_traits_char()
            end
            info.types:push_back(markerTypeName)
          end
          local identifierVector = vector_basic_string_char_char_traits_char()
          for _, info in pairs(listToInfo) do
            if info.types then
              identifierVector:clear()
              if type(info.identifier) == "table" then
                for _, id in ipairs(info.identifier) do
                  identifierVector:push_back(id)
                end
              else
                identifierVector:push_back(info.identifier)
              end
              LocalPlayerMarkerRequestBus.Broadcast.SetMarkerDisplayBuckets(info.types, info.sizes, identifierVector, info.updateRate and info.updateRate or emptyUpdateRate)
            end
          end
          self:TryCloneAndInitializeMarkers()
        end
      end)
    end
    self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    self.lootTickerBusHandler = DynamicBus.LootTickerNotifications.Connect(self.entityId, self)
    self.interactTypeChangedCallbackData = {
      callingSelf = self,
      callback = self.UpdateFocusedInteractable
    }
  end
end
function MarkerManager:OnLoadingScreenDismissed()
  LyShineDataLayerBus.Broadcast.SetData("Global.OnLoadingScreenDismissed", true)
end
function MarkerManager:OnTick(deltaTime, timePoint)
  self:InitScreen()
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
end
function MarkerManager:InitializeMarker(markerEntity, identifier)
  local markerTable = self.registrar:GetEntityTable(markerEntity)
  if markerTable then
    local dataPath = "Hud.LocalPlayer.Markers." .. identifier
    markerTable:Init(dataPath, self.interactTypeChangedCallbackData)
  else
    Debug.Log("MarkerManager: Unable to initialize marker with identifier " .. tostring(identifier))
  end
end
function MarkerManager:ResizeMarkers(markerName, desiredTotalMarkers)
  if self.hasInitializedMultithreading then
    return
  end
  if self.Properties.MarkerTypes[markerName] then
    local markerVector = self.Properties.MarkerTypes[markerName]
    local vectorSize = CountAssociativeTable(markerVector)
    local sizeDifference = desiredTotalMarkers - vectorSize + 1
    if 0 < sizeDifference then
      local doInitialization = false
      local registerDataPaths = false
      local identifier
      if self.markersInitializationData[markerName] then
        doInitialization = self.markersInitializationData[markerName].initialize
        identifier = self.markersInitializationData[markerName].identifier
        registerDataPaths = self.markersInitializationData[markerName].register
      end
      local markerId = markerVector[0]
      if doInitialization then
        self:InitializeMarker(markerId, identifier .. tostring(0))
      end
      local entityParentId = UiElementBus.Event.GetParent(markerId)
      local emptyEntityId = EntityId()
      UiElementBus.Event.Reparent(markerId, entityParentId, emptyEntityId)
      for i = vectorSize, vectorSize + sizeDifference - 1 do
        local clonedId = UiCanvasBus.Event.CloneElement(self.canvasId, markerId, entityParentId, emptyEntityId)
        markerVector[i] = clonedId
        if doInitialization then
          self:InitializeMarker(clonedId, identifier .. tostring(i))
        elseif registerDataPaths then
          local markerTable = self.registrar:GetEntityTable(clonedId)
          if markerTable then
            markerTable:RegisterDatapaths(i)
          end
        end
      end
    elseif sizeDifference < 0 then
      for i = vectorSize - 1, vectorSize + sizeDifference, -1 do
        UiElementBus.Event.DestroyElement(markerVector[i])
        markerVector[i] = nil
      end
    end
  end
end
function MarkerManager:TryCloneAndInitializeMarkers()
  if not self.markersInitialized and CountAssociativeTable(self.markerTypeData.cachedTypes) > 0 and self.canvasId then
    self.markersInitialized = true
    self:ResizeMarkers("GatherableMarkers", GATHERABLE_MARKERS)
    self:ResizeMarkers("GenericMarkers", GENERIC_MARKERS)
    self:ResizeMarkers("StructureMarkers", STRUCTURE_MARKERS)
    self:ResizeMarkers("AIMarkers", AI_MARKERS)
    self:ResizeMarkers("SimplePlayerMarkers", SIMPLE_PLAYER_MARKERS + MEDIUM_PLAYER_MARKERS + FULL_PLAYER_MARKERS)
    self:ResizeMarkers("MediumPlayerMarkers", MEDIUM_PLAYER_MARKERS + FULL_PLAYER_MARKERS)
    self:ResizeMarkers("FullPlayerMarkers", FULL_PLAYER_MARKERS)
    self:ResizeMarkers("GroupPlayerMarkers", GROUP_MARKERS)
    self:ResizeMarkers("ClaimPointMarkers", WAR_CAPTURE_MARKERS)
    self:ResizeMarkers("SiegeWeaponMarkers", SIEGE_WEAPON_MARKERS)
    self:ResizeMarkers("StaticPositionMarkers", STATIC_POSITION_MARKERS)
    if self.enableAsyncCanvasLoading and not self.hasInitializedMultithreading then
      self.hasInitializedMultithreading = true
      if LyShineManagerBus.Broadcast.CanvasSupportsMultithreading(self.canvasId) then
        UiCanvasBus.Event.InitializeMultithread(self.canvasId)
      else
        Debug.Log("Error: Failed to start multithreading on markerManager canvas, unsupported component in canvas. This will cause major performance problems/n" .. debug.traceback())
      end
    end
  end
  MarkerRequestBus.Broadcast.TryInitialize()
end
function MarkerManager:InitScreen()
  if not self.canvasId then
    self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
    self.lyShineManagerHandler = LyShineManagerNotificationBus.Connect(self, self.canvasId)
    if self.Properties.MarkerMode then
      self:TryCloneAndInitializeMarkers()
    else
      local structureInfo = self:SetupInteractCardCategory(self.Properties.InteractCardTypes.StructureInteract)
      local gatherableInfo = self:SetupInteractCardCategory(self.Properties.InteractCardTypes.GatherableInteract)
      self.interactCategorySet = {structureInfo, gatherableInfo}
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InteractorEntityId", function(self, interactorEntityId)
        if interactorEntityId then
          if self.uiInteractorComponentNotificationsHandler then
            self.uiInteractorComponentNotificationsHandler:Disconnect()
            self.uiInteractorComponentNotificationsHandler = nil
          end
          self.uiInteractorComponentNotificationsHandler = UiInteractorComponentNotificationsBus.Connect(self, interactorEntityId)
        end
      end)
    end
    if FtueSystemRequestBus.Broadcast.IsFtue() then
      self.ftueMessageHandler = DynamicBus.FtueMessageBus.Connect(self.entityId, self)
    end
  end
end
function MarkerManager:UpdateCanvasVisibility()
  UiCanvasBus.Event.SetEnabled(self.canvasId, self.screenStateDesiredVisibility)
end
function MarkerManager:OnDeactivate()
  if self.canvasId then
    UiCanvasBus.Event.StopMultithread(self.canvasId)
  end
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer:ClearDataTree(471718901)
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
  if self.lootTickerBusHandler then
    DynamicBus.LootTickerNotifications.Disconnect(self.entityId, self)
  end
  if self.loadScreenHandler then
    self.loadScreenHandler:Disconnect()
    self.loadScreenHandler = nil
  end
  if self.uiInteractorComponentNotificationsHandler then
    self.uiInteractorComponentNotificationsHandler:Disconnect()
    self.uiInteractorComponentNotificationsHandler = nil
  end
  if self.lyShineManagerHandler then
    self.lyShineManagerHandler:Disconnect()
    self.lyShineManagerHandler = nil
  end
  if self.ftueMessageHandler then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
    self.ftueMessageHandler = nil
  end
end
function MarkerManager:GetInitialTypeInfo(baseTypeInfo)
  return self.markerTypeData.types[baseTypeInfo]
end
function MarkerManager:GetSpawnDataFromType(typeName)
  for index, markerData in ipairs(self.typeToMarkerMap) do
    local type = markerData[MARKER_TYPE_KEY_INDEX]
    if string.match(typeName, type) then
      return markerData[MARKER_LIST_INDEX], self:GetInitialTypeInfo(markerData[MARKER_PRIMARY_TYPE_INDEX]), markerData[MARKER_SECONDARY_TYPE_INDEX]
    end
  end
  return self.Properties.MarkerTypes.GenericMarkers, self.markerTypeData.types.None, nil
end
function MarkerManager:SetupInteractCardCategory(cardCategoryId)
  local cardIds = UiElementBus.Event.GetChildren(cardCategoryId)
  local interactCardTables = {}
  for i = 1, #cardIds do
    table.insert(interactCardTables, registrar:GetEntityTable(cardIds[i]))
  end
  return {
    cards = interactCardTables,
    num = #interactCardTables,
    currentIndex = 1,
    activeCards = {}
  }
end
function MarkerManager:GetInteractCard(markerId)
  for _, cardInfo in ipairs(self.interactCategorySet) do
    if cardInfo.activeCards[markerId] then
      return cardInfo.activeCards[markerId], cardInfo.activeCards
    end
  end
  return nil
end
function MarkerManager:UpdateFocusedInteractable(isGatherableInteract, isFocused, markerId)
  if isFocused and self.interactCategorySet then
    local interactCardsIndex = isGatherableInteract and 2 or 1
    local interactCards = self.interactCategorySet[interactCardsIndex]
    if interactCards.activeCards[markerId] then
      return
    end
    interactCards.currentIndex = interactCards.currentIndex + 1
    if interactCards.currentIndex > interactCards.num then
      interactCards.currentIndex = 1
    end
    local cardToShow = interactCards.cards[interactCards.currentIndex]
    interactCards.activeCards[markerId] = cardToShow
    return cardToShow
  end
end
function MarkerManager:OnInteractFadeOut(markerId, cardTable)
  local _, activeCards = self:GetInteractCard(markerId)
  if activeCards and activeCards[markerId] == cardTable then
    activeCards[markerId] = nil
  end
end
local defaultPosOffset = Vector2(0, 0)
function MarkerManager:OnInteractFocus(onFocus, hasMarker, markerType)
  if self.focusedCardTable then
  end
  local positionOffset = defaultPosOffset
  if not hasMarker then
    self.focusedCardMarkerId = self.defaultMarkerId .. tostring(onFocus.interactableEntityId)
  else
    self.focusedCardMarkerId = onFocus.markerId
  end
  local tickPositionInLua = false
  local cardTable = self:GetInteractCard(self.focusedCardMarkerId)
  if not cardTable then
    local isGatherableInteract = false
    if onFocus.interactableEntityId == onFocus.interactorEntityId then
      isGatherableInteract = true
    elseif markerType and markerType ~= "" then
      local markerList, typeInfo, subTypeName = self:GetSpawnDataFromType(markerType)
      isGatherableInteract = typeInfo.useGatherableInteract
      if typeInfo.interactOffset then
        positionOffset = typeInfo.interactOffset
      end
      tickPositionInLua = typeInfo.tickInteractPositionInLua
    end
    cardTable = self:UpdateFocusedInteractable(isGatherableInteract, true, self.focusedCardMarkerId)
  else
    positionOffset = cardTable.positionOffset
  end
  if not cardTable then
    return
  end
  cardTable:OnInteractFocus(onFocus, hasMarker, positionOffset, tickPositionInLua)
  self.focusedCardTable = cardTable
end
function MarkerManager:OnInteractUnfocus()
  if not self.focusedCardTable then
    return
  end
  self.focusedCardTable:OnInteractUnfocus({
    callingSelf = self,
    func = self.OnInteractFadeOut,
    markerId = self.focusedCardMarkerId
  })
  self.focusedCardTable = nil
  DynamicBus.InteractNotifications.Broadcast.OnInteractUnfocus()
end
function MarkerManager:OnInteractExecute(onExecute, hasMarker)
  if not self.focusedCardTable then
    return
  end
  self.focusedCardTable:OnInteractExecute(onExecute)
end
function MarkerManager:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] and self.canvasId then
    self.screenStateDesiredVisibility = false
    self:UpdateCanvasVisibility()
  end
end
function MarkerManager:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[fromState] and self.canvasId then
    self.screenStateDesiredVisibility = true
    self:UpdateCanvasVisibility()
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function MarkerManager:OnLootTickerVisibilityChange(isVisible)
  self.isLootTickerVisible = isVisible
end
function MarkerManager:SetElementVisibleForFtue(isVisible)
  UiCanvasBus.Event.SetEnabled(self.canvasId, isVisible)
end
return MarkerManager
