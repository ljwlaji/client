local UTF8 = {}

--截取中英混合的UTF8字符串，endIndex可缺省
function UTF8.sub(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = UTF8.len(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = UTF8.len(str) + endIndex + 1
    end

    if endIndex == nil then 
        return string.sub(str, UTF8.subStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, UTF8.subStringGetTrueIndex(str, startIndex), UTF8.subStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

--获取中英混合UTF8字符串的真实字符数量
function UTF8.len(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = UTF8.byte_count(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function UTF8.subStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = UTF8.byte_count(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function UTF8.byte_count(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end




return UTF8