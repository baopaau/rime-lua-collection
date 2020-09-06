# rime-lua-collection
Rime Lua腳本分享

## 使用

rime.lua
```
unicode_translator = require("unicode_translator")
calculator_translator = require("calculator_translator")
```

<your_schema>.custom.yaml
```
patch:
  "engine/translators/@after last": "lua_translator@unicode_translator"
  engine/translators/@next: "lua_translator@calculator_translator"
  recognizer/patterns/unicode: "^U.*$"
  recognizer/patterns/expression: "^=.*$"
```
