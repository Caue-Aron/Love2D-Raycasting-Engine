local M = {}

PI = 3.1415926535
DEG1 = 0.0174533
DEG3 = 0.0523599
DEG90 = PI/2
DEG270 = 3*DEG90
DEG360 = 2*PI

min = math.min
floor = math.floor
tan = math.tan
cos, sin = math.cos, math.sin

function M.tableCopy(t1, t2)
    local t = {}
    for k,v in pairs(t1) do
        t[k] = v
    end

    if t2 then
        t2 = t
    end
    return t
end

function M.trunc(x)
    return  x > 0 and floor(x) or -floor(-x)
end

function M.serialize(tbl, indent)
    if not indent then
        indent = 0
    end
    local toprint = string.rep(" ", indent) .. "{\r\n"

    indent = indent + 2

    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if (type(k) == "number") then
            toprint = toprint .. "[" .. k .. "] = "
        elseif (type(k) == "string") then
            toprint = toprint .. k .. "= "
        end
        if (type(v) == "number") then
            toprint = toprint .. v .. ",\r\n"
        elseif (type(v) == "string") then
            toprint = toprint .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then
            toprint = toprint .. M.serialize(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
end

function M.distance(ax,ay, bx,by)
    local d = math.sqrt((ax-bx)*(ax-bx) + (ay-by)*(ay-by))
    return d
end

function M.keepAngle(a)
    if a < 0 then
        a = a + DEG360
    end
    if a > DEG360 then
        a = a - DEG360
    end

    return a
end

function M.extractColors(t)
    return t.r, t.g, t.b
end

function M.colorMul(t1, t2)
    if type(t2) == "number" then
        local t = {}
        t.r = t1.r * t2.r
        t.g = t1.g * t2.g
        t.b = t1.b * t2.bi

        return t

    elseif type(t2) == "table" then
        local t = {}
        t.r = t1.r * t2
        t.g = t1.g * t2
        t.b = t1.b * t2

        return t

    end
end

function M.compareColors(c1, c2)
    return
        c1.r == c2.r and
        c1.g == c2.g and
        c1.b == c2.b
end

function M.isColorBlack(c1)
    return M.compareColors(c1, {r=0, g=0, b=0})
end

local function exportstring(s)
    return string.format("%q", s)
end

--// The Save Function
function table.save(tbl, filename)
    local charS, charE = "   ", "\n"
    local file, err = io.open(filename, "wb")
    if err then return err end

    -- initiate variables for save procedure
    local tables, lookup = { tbl }, { [tbl] = 1 }
    file:write("return {" .. charE)

    for idx, t in ipairs(tables) do
        file:write("-- Table: {" .. idx .. "}" .. charE)
        file:write("{" .. charE)
        local thandled = {}

        for i, v in ipairs(t) do
            thandled[i] = true
            local stype = type(v)
            -- only handle value
            if stype == "table" then
                if not lookup[v] then
                    table.insert(tables, v)
                    lookup[v] = #tables
                end
                file:write(charS .. "{" .. lookup[v] .. "}," .. charE)
            elseif stype == "string" then
                file:write(charS .. exportstring(v) .. "," .. charE)
            elseif stype == "number" then
                file:write(charS .. tostring(v) .. "," .. charE)
            end
        end

        for i, v in pairs(t) do
            -- escape handled values
            if (not thandled[i]) then
                local str = ""
                local stype = type(i)
                -- handle index
                if stype == "table" then
                    if not lookup[i] then
                        table.insert(tables, i)
                        lookup[i] = #tables
                    end
                    str = charS .. "[{" .. lookup[i] .. "}]="
                elseif stype == "string" then
                    str = charS .. "[" .. exportstring(i) .. "]="
                elseif stype == "number" then
                    str = charS .. "[" .. tostring(i) .. "]="
                end

                if str ~= "" then
                    stype = type(v)
                    -- handle value
                    if stype == "table" then
                        if not lookup[v] then
                            table.insert(tables, v)
                            lookup[v] = #tables
                        end
                        file:write(str .. "{" .. lookup[v] .. "}," .. charE)
                    elseif stype == "string" then
                        file:write(str .. exportstring(v) .. "," .. charE)
                    elseif stype == "number" then
                        file:write(str .. tostring(v) .. "," .. charE)
                    end
                end
            end
        end
        file:write("}," .. charE)
    end
    file:write("}")
    file:close()
end

--// The Load Function
function table.load(sfile)
    local ftables, err = loadfile(sfile)
    if err then return _, err end
    local tables = ftables()
    for idx = 1, #tables do
        local tolinki = {}
        for i, v in pairs(tables[idx]) do
            if type(v) == "table" then
                tables[idx][i] = tables[v[1]]
            end
            if type(i) == "table" and tables[i[1]] then
                table.insert(tolinki, { i, tables[i[1]] })
            end
        end
        -- link indices
        for _, v in ipairs(tolinki) do
            tables[idx][v[2]], tables[idx][v[1]] = tables[idx][v[1]], nil
        end
    end
    return tables[1]
end

return M