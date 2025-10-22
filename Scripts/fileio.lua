local fileio = {}
function fileio.ReadFile(fname)
    local lines = {}
    -- read the lines in table 'lines'
    io.input(fname)
    for line in io.lines() do
        table.insert(lines, line)
    end
    return lines
end

function fileio.WriteFile(fname, lines)
    io.output(fname)
    for i, line in ipairs(lines) do
        io.write(line .. "\n")
    end
    io.flush()
end

function fileio.ReadFileTable(fname)
    local lines = fileio.ReadFile(fname)
    local tab = {}
    for i, line in ipairs(lines) do
        local tokens = string.split(line, ':')
        local key = tokens[1]
        local value = tonumber(tokens[2])
        if value ~= nil then
            tab[key] = value
        else
            tab[key] = tokens[2]
        end
    end
    return tab
end

function fileio.WriteFileTable(fname, tab)
    local lines = {}
    for k, v in pairs(tab) do
        table.insert(lines, string.format("%s:%s", tostring(k), tostring(v)))
    end
    fileio.WriteFile(fname, lines)
end

return fileio
