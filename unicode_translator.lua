-- Rime Script >https://github.com/baopaau/rime-lua-collection/blob/master/unicode_translator.lua
-- Unicode 內碼轉譯（輸出任意Unicode字符）
-- 格式：U<d|x|o><code>
-- d、x、o對應十進制、十六進制、八進制
-- 如 Ux5C13 和 Ud23571 均輸出 `尓`
-- 須在方案增加 `recognizer/patterns/unicode: "^U.*$"`

local c_type={b=2, o=8, d=10, x=16}

local function yield_cand(code, seg, comment)
  local text= utf8.char(code)
  if text then
    yield( Candidate("number", seg._start, seg._end, text, comment or ""))
  end
end

local function unicode_translator(input, seg, env)
  local t, c = input:match("U([bBoOdDxX])(.+)")
  if not c then return end
  
  local ct= c_type[t:lower()]
  local code = tonumber(c, ct)
  
  yield_cand( code, seg, input)
  
  local base = code * ct
  for i = 0, ct-1 do
    yield_cand( base + i , seg, input "~ " i)
  end
end
return unicode_translator
