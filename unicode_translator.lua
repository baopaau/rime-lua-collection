-- Rime Script >https://github.com/baopaau/rime-lua-collection/blob/master/unicode_translator.lua
-- Unicode 內碼轉譯（輸出任意Unicode字符）
-- 格式：U<d|x|o><code>
-- d、x、o對應十進制、十六進制、八進制
-- 如 Ux5C13 和 Ud23571 均輸出 `尓`
-- 須在方案增加 `recognizer/patterns/unicode: "^U.*$"`
local string_char = string.char

local function utf8(cp)
  if cp < 128 then
    return string_char(cp)
  end
  local suffix = cp % 64
  local c4 = 128 + suffix
  cp = (cp - suffix) / 64
  if cp < 32 then
    return string_char(192 + cp, c4)
  end
  suffix = cp % 64
  local c3 = 128 + suffix
  cp = (cp - suffix) / 64
  if cp < 16 then
    return string_char(224 + cp, c3, c4)
  end
  suffix = cp % 64
  cp = (cp - suffix) / 64
  return string_char(240 + cp, 128 + suffix, c3, c4)
end

local function unicode_translator(input, seg)
  if string.sub(input, 1, 1) ~= "U" then return end
  
  local dict = { d=10, x=16, o=8 }
  local snd = string.sub(input, 2, 2)
  local n = dict[snd]
  if n == nil then return end
  
  local str = string.sub(input, 3)
  local c = tonumber(str, n)
  if c == nil then return end
  
  local fmt = "U"..snd.."%"..(n==16 and "X" or snd)
  -- 單獨查找
  yield(Candidate("number", seg.start, seg._end,
     utf8(c), string.format(fmt, c)))
  -- 區間查找
  for i = c*n, c*n+n-1 do
    yield(Candidate("number", seg.start, seg._end,
       utf8(i), string.format(fmt, i)))
  end
end

return unicode_translator
