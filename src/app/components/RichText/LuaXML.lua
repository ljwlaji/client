local luaXML = class("luaXML")
local XMLNode = import(".LuaXMLNode")

function luaXML:ToXmlString(value)
    value = string.gsub(value, "&", "&amp;"); -- '&' -> "&amp;"
    value = string.gsub(value, "<", "&lt;"); -- '<' -> "&lt;"
    value = string.gsub(value, ">", "&gt;"); -- '>' -> "&gt;"
    value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
    value = string.gsub(value, "([^%w%&%;%p%\t% ])",
        function(c)
            return string.format("&#x%X;", string.byte(c))
        end);
    return value;
end

function luaXML:FromXmlString(value)
    value = string.gsub(value, "&#x([%x]+)%;",
        function(h)
            return string.char(tonumber(h, 16))
        end);
    value = string.gsub(value, "&#([0-9]+)%;",
        function(h)
            return string.char(tonumber(h, 10))
        end);
    value = string.gsub(value, "&quot;", "\"");
    value = string.gsub(value, "&apos;", "'");
    value = string.gsub(value, "&gt;", ">");
    value = string.gsub(value, "&lt;", "<");
    value = string.gsub(value, "&amp;", "&");
    return value;
end

function luaXML:ParseArgs(node, s)
    string.gsub(s, "(%w+)=([\"'])(.-)%2", function(w, _, a)
        node:addProperty(w, self:FromXmlString(a))
    end)
end

function luaXML:tryDealWithSpacieCharacter(stack, char)
    local goted = false
    if char and string.len(char) == 1 then
        if string.byte(char) == 10 then
            release_print("Got New Line")
            stack[#stack]:setValue(char)
            goted = true
        end
    end
    return goted
end

function luaXML:ParseXmlText(xmlText)
    local stack = {}
    local top = XMLNode:create()
    table.insert(stack, top)
    local ni, c, label, xarg, empty
    local i, j = 1, 1
    while true do
        ni, j, c, label, xarg, empty = string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
        if not ni then break end
        local text = string.sub(xmlText, i, ni - 1)
        if not self:tryDealWithSpacieCharacter(stack, text) then
            if not string.find(text, "^%s*$") then
                local lVal = (top:value() or "") .. self:FromXmlString(text)
                stack[#stack]:setValue(lVal)
            end
        end
        if empty == "/" then -- empty element tag
            local lNode = XMLNode:create(label)
            self:ParseArgs(lNode, xarg)
            top:addChild(lNode)
        elseif c == "" then -- start tag
            local lNode = XMLNode:create(label)
            self:ParseArgs(lNode, xarg)
            table.insert(stack, lNode)
            top = lNode
        else -- end tag
            local toclose = table.remove(stack) -- remove top

            top = stack[#stack]
            if #stack < 1 then
                error("XmlParser: nothing to close with " .. label)
            end
            if toclose:getType() ~= label then
                error("XmlParser: trying to close " .. toclose.name .. " with " .. label)
            end
            top:addChild(toclose)
        end
        i = j + 1
    end
    local text = string.sub(xmlText, i);
    if #stack > 1 then
        error("XmlParser: unclosed " .. stack[#stack]:name())
    end
    return top.___children[1]
end

function luaXML:loadFile(xmlFilename, base)
    if not base then
        base = system.ResourceDirectory
    end

    local path = system.pathForFile(xmlFilename, base)
    local hFile, err = io.open(path, "r");

    if hFile and not err then
        local xmlText = hFile:read("*a"); -- read file content
        io.close(hFile);
        return self:ParseXmlText(xmlText), nil;
    else
        print(err)
        return nil
    end
end

return luaXML