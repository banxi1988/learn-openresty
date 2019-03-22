local test = require "u-test"

test.test_get_suffix = function()
  test.equal(string.match("123.txt", ".+(%..+)$"), ".txt")
  test.equal(string.match("goodname.jpg.txt", ".+(%..+)$"), ".txt")
end
