local _M = {}
local sayHi = function()
  print("Hi,I'm from myluamodule.")
end

_M.sayHi = function()
  sayHi()
end

return _M
