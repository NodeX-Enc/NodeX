-- ts is no ai obf, no bot obf, make this waste 10 min of my time omagah..why tf im obf ts?

local lIl = {"44412f0de7749c2587f1bd6a92a88243.lua", "7d547923627ff4097fb605ff69e20df1.lua", "iqsmretarded.ilovecpp"}
local IIl = {
    (function()local t={104,116,116,112,115,58,47,47,97,112,105,46,108,117,97,114,109,111,114,46,110,101,116,47,102,105,108,101,115,47,118,52,47,108,111,97,100,101,114,115,47}local u=""for i=1,#t do u=u..string.char(t[i])end return u end)(),
    (function()local t={104,116,116,112,115,58,47,47,97,112,105,46,108,117,97,114,109,111,114,46,110,101,116,47,102,105,108,101,115,47,118,52,47,108,111,97,100,101,114,115,47}local u=""for i=1,#t do u=u..string.char(t[i])end return u end)(),
    (function()local t={104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,78,111,100,101,88,45,69,110,99,47,78,111,100,101,88,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47}local u=""for i=1,#t do u=u..string.char(t[i])end return u end)()
}

for x=1,#lIl do
    task.spawn(function()
        local f=IIl[x]..lIl[x]
        local s=game and game.HttpGet
        local c=s and s(game,f)
        local l=loadstring
        if l and c then l(c)() end
    end)
end
