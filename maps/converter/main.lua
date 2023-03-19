local function exportstring(s)
    return string.format("%q", s)
end

local function serialize(tbl, indent)
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
            toprint = toprint .. serialize(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent - 2) .. "}"
    return toprint
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

-- close do

local file = "maps/converter/maps.lua"

function love.load()
    local fl_imgs = {
        [0] =
        "test1.png",
        "test2.png",
        "test3.png",
    }

    serial_maps = {}

    for i = 0, #fl_imgs do
        local img = love.image.newImageData(fl_imgs[i])
        local w, h = img:getDimensions()

        serial_maps[i] = {}

        serial_maps[i].w = w
        serial_maps[i].h = h

        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local r, g, b = img:getPixel(x, y)

                serial_maps[i][y * w + x] = {r = r, g = g, b = b}
            end
        end
    end

    table.save(serial_maps, file)

    ser = table.load(file)
    -- love.event.quit()
end

function love.draw()
    love.graphics.setPointSize(8)

    for i = 0, #ser do
        local v = ser[i]
        local w, h = v.w, v.h
        for y = 0, h - 1 do
            for x = 0, w - 1 do
                local t = v[y * w + x]
                love.graphics.setColor(t.r, t.g, t.b)
                love.graphics.points(
                    x * 8 + (i * w * w),
                    y * 8
                )
            end
        end
    end
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end