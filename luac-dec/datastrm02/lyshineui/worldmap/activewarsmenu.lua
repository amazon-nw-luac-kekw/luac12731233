local ActiveWarsMenu = {
  Properties = {
    NumWarsText = {
      default = EntityId()
    },
    CompaniesAtWarList = {
      default = EntityId()
    },
    ButtonClose = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    NoWarIcon = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ActiveWarsMenu)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
function ActiveWarsMenu:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  self.ButtonClose:SetCallback(self.OnCloseActiveWarsMenu, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_LEFT)
  DynamicBus.Map.Connect(self.entityId, self)
end
function ActiveWarsMenu:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
end
function ActiveWarsMenu:OnCloseActiveWarsMenu()
  self:SetVisibility(false)
end
function ActiveWarsMenu:OnShowPanel(panelType)
  self:SetVisibility(panelType == self.panelTypes.CompaniesAtWar)
end
function ActiveWarsMenu:SetVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    local wars = WarDataServiceBus.Broadcast.GetWars() or {}
    local numWars = 0
    for i = 1, #wars do
      local warDetails = wars[i]
      local warPhase = warDetails:GetWarPhase()
      if warPhase ~= eWarPhase_Resolution and warPhase ~= eWarPhase_Complete then
        numWars = numWars + 1
      end
    end
    if numWars == 0 then
      UiTextBus.Event.SetTextWithFlags(self.NumWarsText, "@ui_mapmenu_noactivewars", eUiTextSet_SetLocalized)
    elseif numWars == 1 then
      UiTextBus.Event.SetTextWithFlags(self.NumWarsText, "@ui_activewars_oneactivewar", eUiTextSet_SetLocalized)
    else
      local numWarsText = GetLocalizedReplacementText("@ui_activewars_numactivewars", {numWars = numWars})
      UiTextBus.Event.SetText(self.NumWarsText, numWarsText)
    end
    self.CompaniesAtWarList:SetIsVisible(0 < numWars)
    UiElementBus.Event.SetIsEnabled(self.Properties.NoWarIcon, numWars == 0)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {x = -600}, {x = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.ButtonContainer, 0.2, {opacity = 0, delay = 0.2})
  else
    self.CompaniesAtWarList:SetIsVisible(false)
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
function ActiveWarsMenu:IsVisible()
  return self.isVisible
end
return ActiveWarsMenu
