local SubArmy = {
  Properties = {
    SubtitleText = {
      default = EntityId()
    },
    JoinScreen = {
      default = EntityId()
    },
    CreateScreen = {
      default = EntityId()
    },
    TabbedList = {
      default = EntityId()
    }
  },
  isEnabled = false,
  tickHandler = nil,
  timer = 0,
  cacheTime = 2,
  cacheExpired = true,
  BUTTON_WIDTH = 235,
  BUTTON_STYLE = 2
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SubArmy)
function SubArmy:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isEnabled)
  local listData = {
    {
      text = "@ui_subarmy_tab_join",
      callback = self.OnJoinButton,
      style = self.BUTTON_STYLE,
      width = self.BUTTON_WIDTH
    },
    {
      text = "@ui_subarmy_tab_create",
      callback = self.OnCreateButton,
      style = self.BUTTON_STYLE,
      width = self.BUTTON_WIDTH
    }
  }
  self.TabbedList:SetListData(listData, self)
  self.TabbedList:SetSelected(1)
end
function SubArmy:SetEnabled(isEnabled)
  if self.isEnabled == isEnabled then
    return
  end
  self.isEnabled = isEnabled
  if isEnabled then
    self:OnTransitionIn()
  else
    self:OnTransitionOut()
  end
end
function SubArmy:IsEnabled()
  return self.isEnabled
end
function SubArmy:OnCreateButton()
  local subtitle = self.CreateScreen:GetSubtitle()
  UiTextBus.Event.SetTextWithFlags(self.SubtitleText, subtitle, eUiTextSet_SetAsIs)
  self.CreateScreen:OnCreateScreenVisisble(true)
  UiElementBus.Event.SetIsEnabled(self.JoinScreen.entityId, false)
end
function SubArmy:OnJoinButton()
  local subtitle = self.JoinScreen:GetSubtitle()
  UiTextBus.Event.SetTextWithFlags(self.SubtitleText, subtitle, eUiTextSet_SetAsIs)
  self.CreateScreen:OnCreateScreenVisisble(false)
  UiElementBus.Event.SetIsEnabled(self.JoinScreen.entityId, true)
  self:RefreshJoinScreen()
end
function SubArmy:RefreshJoinScreen()
  if self.cacheExpired then
    self.JoinScreen:Refresh()
    self.cacheExpired = false
    self.timer = 0
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function SubArmy:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer >= self.cacheTime then
    self:BusDisconnect(self.tickHandler)
    self.cacheExpired = true
  end
end
function SubArmy:OnTransitionIn()
  if UiElementBus.Event.IsEnabled(self.JoinScreen.entityId) then
    self:RefreshJoinScreen()
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {x = -430, opacity = 0}, {
    x = 65,
    opacity = 1,
    ease = "QuadOut"
  })
end
function SubArmy:OnTransitionOut()
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {x = 65, opacity = 1}, {
    x = -430,
    opacity = 0,
    ease = "QuadIn",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
    end
  })
end
return SubArmy
