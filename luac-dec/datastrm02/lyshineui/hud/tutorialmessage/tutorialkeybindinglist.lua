local TutorialKeyBindingList = {
  Properties = {
    KeyBindingSpawner = {
      default = EntityId()
    },
    KeySeparatorSpawner = {
      default = EntityId()
    },
    KeyPrototype = {
      default = EntityId()
    },
    SeparatorProtoype = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TutorialKeyBindingList)
function TutorialKeyBindingList:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.mouseInputNames = {
    "mouse1",
    "mouse2",
    "mouse3",
    "mwheel_up",
    "mwheel_down",
    "maxis_x",
    "maxis_y"
  }
end
function TutorialKeyBindingList:SetupBindings(keyBindings, hintFontSize, hintMinWidth, highlightVisible)
  self:ClearKeyBindingEntities()
  for i = 1, #keyBindings do
    local showHold = false
    if LyShineManagerBus.Broadcast.IsActionActivatedOnHold(keyBindings[i].keyBinding, keyBindings[i].keyCategory) then
      showHold = true
    end
    local keyEntity = CloneUiElement(self.canvasId, self.registrar, self.Properties.KeyPrototype, self.Properties.KeyBindingSpawner, true)
    local inputName = LyShineManagerBus.Broadcast.GetActionInputName(keyBindings[i].keyBinding, keyBindings[i].keyCategory)
    if self:IsMouseInput(inputName) then
      keyEntity:SetMouseBinding(inputName, showHold)
    else
      keyEntity:SetKeyBinding(keyBindings[i].keyBinding, keyBindings[i].keyCategory, showHold, hintFontSize, hintMinWidth, highlightVisible)
    end
    if i < #keyBindings then
      local separatorEntity = CloneUiElement(self.canvasId, self.registrar, self.Properties.SeparatorProtoype, self.Properties.KeyBindingSpawner, true)
      if keyBindings[i].separator ~= "" then
        separatorEntity:SetText(keyBindings[i].separator)
      end
    end
  end
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
end
function TutorialKeyBindingList:ClearKeyBindingEntities()
  local keyChildren = UiElementBus.Event.GetChildren(self.Properties.KeyBindingSpawner)
  for i = 1, #keyChildren do
    UiElementBus.Event.DestroyElement(keyChildren[i])
  end
end
function TutorialKeyBindingList:IsMouseInput(inputName)
  for i, mouseInputName in ipairs(self.mouseInputNames) do
    if inputName == mouseInputName then
      return true
    end
  end
  return false
end
return TutorialKeyBindingList
