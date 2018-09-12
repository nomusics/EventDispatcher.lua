--[[

EventDispatcher.lua

Version: 1.0.0

---------------------------------------------------------------------------
使用方式
---------------------------------------------------------------------------

--- 单例模式
local EventDispatcher = require("EventDispatcher"):getInstance()

--- 定义函数eventA
--- 函数返回true会停止后续监听器的执行
local function eventA(param1, param2, ...)
  print("function eventA")
  return true
end

--- 添加事件EVENT_A监听
--- 第三个参数为优先级，255,-255之间
EventDispatcher:addListener("EVENT_A", eventA)
or
EventDispatcher:addListener("EVENT_A", eventA, 15)

--- 执行事件EVENT_A，并传递参数param1, param2, ...
EventDispatcher:dispatch("EVENT_A", param1, param2, ...)


---------------------------------------------------------------------------
参考代码
---------------------------------------------------------------------------

Latest code: https://github.com/daveyang/EventDispatcher

Created by: Dave Yang / Quantumwave Interactive Inc.

Version: 1.3.4

---------------------------------------------------------------------------
数据结构
---------------------------------------------------------------------------
{
  ["name1"] = [
    {_callback = listener1, level = 5},
    {_callback = listener2, level = -255},
  ],
  ["name1"] = [
    {_callback = listener1, level = 5},
    {_callback = listener2, level = -255},
  ]
}

]]


local EventDispatcher = {}

--- 初始化
function EventDispatcher:new(o)
  o = o or {}
  o._listeners = {}
  self.__index = self
  return setmetatable(o, self)
end

--- 添加监听器
-- @param name 事件 (string)
-- @param listener object (function)
-- @param level 优先级，默认为 -255 (int)
-- @return 添加结果 (boolean)
function EventDispatcher:addListener(name, listener, level)

  if name == nil or type(name) ~= "string" or #name == 0 then return false end

  assert( listener )

  if type(listener) ~= "function" then return false end

  self._listeners[name] = self._listeners[name] or {}
  local events = self._listeners[name]

  level = tonumber(level) or - 255

  table.insert(events, { _callback = listener, level = level})

  return true
end

--- 调用监听器
-- @param callback
-- @return 监听器返回值 (boolean)
function EventDispatcher:handler(callback, ...)
  return callback(...)
end

--- 执行事件
--- 监听器返回true的时候，将停止后续监听器的执行
-- @param name 事件 (string)
-- @param ... 可选参数
-- @return 执行结果 (boolean).
function EventDispatcher:dispatch(name, ...)

  if name == nil or type(name) ~= "string" or #name == 0 then return false end

  self._listeners[name] = self._listeners[name] or {}
  local events = self._listeners[name]

  -- 排序
  if next(events) ~= nil then
    local function levelSort(a, b)
      return tonumber(a.level) > tonumber(b.level)
    end
    table.sort(events, levelSort)
  end

  local dispatched = false

  for _, val in next, events do
    if val ~= nil and val._callback ~= nil then
      dispatched = self:handler(val._callback, ...)
      if dispatched then return dispatched end
    end
  end

  return dispatched

end

--- 删除监听器
-- @param name 事件 (string)
-- @param listener 监听器 (function)
-- @return 删除状态 (boolean).
function EventDispatcher:removeListener(name, listener)

  if name == nil or type(name) ~= "string" or #name == 0 then return false end

  assert(listener)

  local events = self._listeners[name] or {}

  if next(events) == nil then return false end

  local removed = false

  for i = #events, 1, - 1 do
    if events[i]._callback == listener then
      table.remove(self._listeners[name], i)
      removed = true
    end
  end

  return removed
end

--- 根据名称删除事件下的所有监听器
--- 如果name为空，则删除所有事件的监听器
-- @param name 事件名称(string)
function EventDispatcher:removeAllListeners(name)

  if name == nil or type(name) ~= "string" or #name == 0 then return false end

  self._listeners[name] = self._listeners[name] or {}

  if name == nil or #name == 0 then
    self._listeners = {}
    return true
  else
    self._listeners[name] = nil
    return true
  end

end

--- 检查是否已存在事件监听器
-- @param name 事件 (string)
-- @param listener 监听器 (function)
-- @return 是否存在 (boolean)
function EventDispatcher:hasListener(name, listener)
end

--- 打印所有已注册的事件监听器
function EventDispatcher:printListeners()

  local listeners = self._listeners
  if listeners == nil then return {} end

  for name, value in next, listeners do
    for key, val in next, value do
      print(name, " : ", key, " = ", tostring(val._callback), " level = ", val.level )
    end
  end
end

--- 销毁单例
function EventDispatcher:destoryInstance()
  self.instance = nil
end

--- 单例
function EventDispatcher:getInstance()

  if self.instance == nil then
    self.instance = EventDispatcher:new()
  end

  return self.instance
end

return EventDispatcher
