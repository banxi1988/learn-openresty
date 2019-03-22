local test = require "u-test"

test.test_file_seek = function()
  local f1 = io.open("/tmp/f001.txt", "w+")
  test.assert(f1)
  f1:write("abcde")
  test.equal(f1:seek(), 5)
  f1:seek("end")
  test.equal(f1:seek(), 5)
end
