# EventDispatcher.lua

### 使用方式
---------------------------------------------------------------------------

--- 单例模式
```
local EventDispatcher = require("EventDispatcher"):getInstance()
```
--- 定义函数eventA，函数返回true会停止后续监听器的执行
```
local function eventA(param1, param2, ...)
  print("function eventA")
  return true
end
```
--- 添加事件EVENT_A监听。第三个参数为优先级，255,-255之间
```
EventDispatcher:addListener("EVENT_A", eventA)
or
EventDispatcher:addListener("EVENT_A", eventA, 15)
```
--- 执行事件EVENT_A，并传递参数param1, param2, ...
```
EventDispatcher:dispatch("EVENT_A", param1, param2, ...)
```
