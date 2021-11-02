local ScriptActionQueue = {}
function ScriptActionQueue:QueueCreate()
  local actionQueue = {
    queue = {},
    isEnqueuing = false
  }
  function actionQueue.Add(aqSelf, actionTable, actionFunction, actionArgument)
    local action = {
      actionTable = actionTable,
      actionFunction = actionFunction,
      actionArgument = actionArgument
    }
    if aqSelf.isEnqueuing then
      table.insert(aqSelf.queue, action)
    else
      aqSelf:DoAction(action)
    end
  end
  function actionQueue.Remove(aqSelf, actionTable, actionFunction, actionArgument)
    for i = 1, #aqSelf.queue do
      local action = aqSelf.queue[i]
      if action.actionTable == actionTable and action.actionFunction == actionFunction and action.actionArgument == actionArgument then
        table.remove(aqSelf.queue, i)
        break
      end
    end
  end
  function actionQueue.DoAction(aqSelf, action)
    local actionTable = action.actionTable
    local actionFunction = action.actionFunction
    local actionArgument = action.actionArgument
    if actionFunction ~= nil and actionTable ~= nil and type(actionFunction) == "function" then
      actionFunction(actionTable, actionArgument)
    end
  end
  function actionQueue.DoNext(aqSelf)
    if #aqSelf.queue > 0 then
      local nextAction = table.remove(aqSelf.queue, 1)
      aqSelf:DoAction(nextAction)
    end
  end
  function actionQueue.DoAll(aqSelf)
    for _, action in pairs(aqSelf.queue) do
      aqSelf:DoAction(action)
    end
    aqSelf:Clear()
  end
  function actionQueue.Clear(aqSelf)
    aqSelf.queue = {}
  end
  function actionQueue.SetIsEnqueuing(aqSelf, isEnqueuing)
    aqSelf.isEnqueuing = isEnqueuing
  end
  return actionQueue
end
return ScriptActionQueue
