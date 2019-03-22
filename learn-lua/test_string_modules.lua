local test = require "u-test"

test.test_slice = function()
  test.assert(string.sub("abcd", 0) == "abcd")
  test.equal(string.sub("abcd", 0), "abcd")
  test.equal(string.sub("abcd", 0, -1), "abcd")
  test.equal(string.sub("abcd", 0, 4), "abcd")
  test.equal(string.sub("abcd", 0, 3), "abc")
  test.equal(string.sub("abcd", 0, 5), "abcd")
  test.equal(string.sub("abcd", -2, -1), "cd")
end

test.test_concat = function()
  test.equal("ab" .. "cd", "abcd")
  local comps = {
    "ab",
    "cd",
    "ef",
    666
  }
  test.equal(table.concat(comps), "abcdef666")
  test.equal(table.concat(comps, ","), "ab,cd,ef,666")
  test.equal(table.concat(comps, ",", 1, 3), "ab,cd,ef")
  test.equal(table.concat(comps, ",", 1, 2), "ab,cd")
  test.equal(table.concat(comps, ",", 1, 1), "ab")
  test.equal(table.concat(comps, ",", 1, 0), "")
end

test.test_format = function()
  test.equal(string.format("%d", 123), "123")
  test.equal(string.format("%d", 123.00), "123")
  test.equal(string.format("%.02f", 123.003), "123.00")
end
