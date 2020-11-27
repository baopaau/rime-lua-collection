# rime-lua-collection

配方： ℞ **baopaau/rime-lua-collection**

[Rime](https://rime.im) Lua腳本
 

## 安裝

[東風破](https://github.com/rime/plum) 安裝口令： `bash rime-install baopaau/rime-lua-collection`

授權條款：見 [LICENSE](LICENSE)

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
