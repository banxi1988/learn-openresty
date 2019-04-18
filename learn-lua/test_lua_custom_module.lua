local test = require "u-test"

test.test_load_myluamodule = function()
  local m = require "myluamodule"
  m.sayHi()
end
