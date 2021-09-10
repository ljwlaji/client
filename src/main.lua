cc.FileUtils:getInstance():setPopupNotify(false)

devRequire = function(path)
    if package.loaded[path] then
        package.loaded[path] = nil
    end
    return require(path)
end


require "config"
require "cocos.init"
require "app.components.UITextEx"
require "app.extensions.NodeEx"


__G__TRACKBACK__ = function(msg)
    local tbStr=debug.traceback("", 2)
    release_print("----------------------------------------")
    release_print("LUA ERROR: " .. tostring(msg) .. "\n")
    release_print(tbStr)
    release_print("----------------------------------------")

    -- report lua exception
    if device.platform == "ios" or device.platform == "android" then
        buglyReportLuaException(tostring(tbStr), debug.traceback())
    end

    return msg
end

--Director::restart()

--[[
1. 找出互质数 p q
2. 大数 n = p * q
3. 欧拉函数 (p-1)*(q-1)
4. 找公钥e 1<e<欧拉函数返回值 并且 e与欧拉函数返回值互质
5. 找私钥d e*d / 欧拉返回值 取余为 1


发送大数n和公钥e

对方加密
明文^e / n 求余 = 密文


发钥方解密 
密文^d / n 求余 = 明文



q = 3; p = 7
大数 n = 21

欧拉返回值 192
取公钥 e = 17
私钥 d = 113

]]

--是互质

-- local function f(a, b)
--     return (a-1)*(b-1)
-- end

-- local function check(e, f_foo)
--     local checker = e <= f_foo and e or f_foo
--     local ret = true
--     for i=2, checker do
--         if e % i == f_foo % i then ret = false break end
--     end
--     return ret
-- end

-- local function findPublicKey(f_foo)
--     for i=2, f_foo do
--         if check(i, f_foo) then return i end
--     end
--     assert(false)
-- end

-- local function findPrivateKey(puk, r)
--     for i=1, 999999 do
--         if (puk * i) % r == 1 then release_print(puk * i) return i end
--     end
--     assert(false)
-- end

-- local function encode(str, puk, bigNumber)
--     return str^puk % bigNumber
-- end

-- local function decode(str, pvk, bigNumber)
--     return str^pvk % bigNumber
-- end
local function main()
    -- test()
    -- local p = 13
    -- local q = 17
    -- local bigNumber = p*q
    -- local r = f(p, q)
    -- release_print("R = "..r)
    -- local puk = findPublicKey(r)
    -- release_print("PublicKey = "..puk)
    -- local pvk = findPrivateKey(puk, r)
    -- release_print("PrivateKey = "..pvk)
    -- local enc = encode(5, puk, bigNumber)
    -- release_print("Encoded = "..enc)
    -- local dec = decode(enc, pvk, bigNumber)
    -- release_print("Decode = "..dec)
    -- do return end
    require("app.MyApp"):create():run()
    dump(display.getRunningScene())
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
