local MasteryRow = {
  Properties = {
    Nodes = {
      default = {
        EntityId()
      }
    }
  },
  padding = 120,
  row = 0,
  numOwnedNodes = 0,
  numSelectedNodes = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MasteryRow)
function MasteryRow:OnInit()
end
function MasteryRow:SetRowNodes(row, nodes)
  self.row = row
  local width = UiTransform2dBus.Event.GetLocalWidth(self.entityId) - self.padding
  local startX = -width * 0.5
  for i, nodeData in ipairs(nodes) do
    local node = self.Nodes[i - 1]
    if node then
      node:SetAbilityData(nodeData)
      local distance = startX + nodeData.treeColPos * node.width
      UiTransformBus.Event.SetLocalPosition(node.entityId, Vector2(distance + node.width * 0.5, 0))
    end
  end
end
function MasteryRow:Reset()
  for i = 0, #self.Nodes do
    self.Nodes[i]:Reset()
  end
end
function MasteryRow:RefreshStatus(availablePoints, selectedAbilityIds, canPurchaseInThisRow)
  self.numOwnedNodes = 0
  self.numSelectedNodes = 0
  for _, node in pairs(self.Nodes) do
    local nodeState = node:RefreshStatus(availablePoints, selectedAbilityIds, canPurchaseInThisRow)
    if nodeState == node.STATE_OWNED then
      self.numOwnedNodes = self.numOwnedNodes + 1
    elseif nodeState == node.STATE_SELECTED then
      self.numSelectedNodes = self.numSelectedNodes + 1
    end
  end
  local ownedPlusSelectedNodeCount = self.numOwnedNodes + self.numSelectedNodes
  self.canPurchaseInNextRow = 1 <= ownedPlusSelectedNodeCount
  return ownedPlusSelectedNodeCount
end
function MasteryRow:GetCanPurchaseInNextRow()
  return self.canPurchaseInNextRow
end
function MasteryRow:GetNumOwnedNodes(includeSelected)
  if includeSelected then
    return self.numOwnedNodes + self.numSelectedNodes
  else
    return self.numOwnedNodes
  end
end
function MasteryRow:SetPlayerEntityId(playerEntityId)
  for _, node in pairs(self.Nodes) do
    node:SetPlayerEntityId(playerEntityId)
  end
end
return MasteryRow
