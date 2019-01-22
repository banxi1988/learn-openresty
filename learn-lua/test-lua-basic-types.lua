local test = require "u-test"

test.test_lua_type_fun = function()
  test.equal(type("hello"), "string")
  test.equal(type(print), "function")
  test.equal(type(true), "boolean")
  test.equal(type(360.0), "number")
  test.equal(type(360), "number")
  test.equal(type(nil), "nil")
end
