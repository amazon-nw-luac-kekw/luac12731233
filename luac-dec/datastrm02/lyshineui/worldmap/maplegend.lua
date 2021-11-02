local MapLegend = {
  Properties = {
    Forest = {
      default = EntityId(),
      order = 1
    },
    Grassland = {
      default = EntityId(),
      order = 2
    },
    Highland = {
      default = EntityId(),
      order = 3
    },
    Marsh = {
      default = EntityId(),
      order = 4
    },
    Shrubland = {
      default = EntityId(),
      order = 5
    },
    CoastalHills = {
      default = EntityId(),
      order = 6
    },
    Beach = {
      default = EntityId(),
      order = 7
    },
    Icon = {
      default = EntityId(),
      order = 8
    },
    ButtonClose = {
      default = EntityId(),
      order = 9
    },
    ButtonContainer = {
      default = EntityId(),
      order = 10
    },
    Frame = {
      default = EntityId(),
      order = 11
    }
  },
  isVisible = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MapLegend)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function MapLegend:OnInit()
  BaseElement.OnInit(self)
  self.Icon:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_resourceLocation.png", self.UIStyle.COLOR_TAN)
  self.ButtonClose:SetCallback(self.OnCloseMapLegend, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_LEFT)
  self.Frame:SetOffsets(0, 0, 12, 0)
  self.Forest:SetLegendEntryItems({
    "WoodT1",
    "FiberT1",
    "HerbT1"
  })
  self.Grassland:SetLegendEntryItems({"FiberT1", "HerbT1"})
  self.Highland:SetLegendEntryItems({
    "OrePreciousT1",
    "OreT1",
    "StoneT1"
  })
  self.Marsh:SetLegendEntryItems({"OilT1"})
  self.Shrubland:SetLegendEntryItems({"BerryT1", "WoodT1"})
  self.CoastalHills:SetLegendEntryItems({"FlintT1", "WoodT1"})
  self.Beach:SetLegendEntryItems({"FlintT1"})
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.Map.Connect(self.entityId, self)
end
function MapLegend:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function MapLegend:OnShowPanel(panelType)
  self:SetVisibility(panelType == self.panelTypes.MapLegend)
end
function MapLegend:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = -600}, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.ButtonContainer, 0.2, {opacity = 0, delay = 0.2})
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.5, {x = 0}, {
      x = -600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.ButtonContainer, 0.05, {opacity = 1})
  end
end
function MapLegend:IsVisible()
  return self.isVisible
end
function MapLegend:OnCloseMapLegend()
  self:SetVisibility(false)
end
return MapLegend
