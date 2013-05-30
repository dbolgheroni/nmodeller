--[[
--
-- Bioclim algorithm module
--
--]]

local M = {}

-- returns an array with the minimal values for each dataset
function M.getmin (samples)
    local min = {}

    -- the size of the tables inside 'samples' is equal the number of
    -- environmental variables
    local nenvvar = #samples[1]

    for n=1,nenvvar do
        local minv
        local first = true

        for _, s in ipairs(samples) do
            if first then
                minv = s[n]
                first = false
            end

            if s[n] < minv then minv = s[n] end
        end

        table.insert(min, minv)
    end

    return min
end

-- returns an array with the maximum values for each dataset
function M.getmax (samples)
    local max = {}

    -- the size of the tables inside 'samples' is equal the number of
    -- environmental variables
    local nenvvar = #samples[1]

    for n=1,nenvvar do
        local maxv
        local first = true

        for _, s in ipairs(samples) do
            if first then
                maxv = s[n]
                first = false
            end

            if s[n] > maxv then maxv = s[n] end
        end

        table.insert(max, maxv)
    end

    return max
end

function M.getmean (samples)
    local mean = {}

    -- the size of the tables inside 'samples' is equal the number of
    -- environmental variables
    local nenvvar = #samples[1]

    for n=1,nenvvar do
        local sum = 0
        local meanv

        for _, s in ipairs(samples) do
            sum = sum + s[n]
        end
        meanv = sum / #samples

        table.insert(mean, meanv)
    end

    return mean
end

function M.getstddev (samples)
    local stddev = {}
    local mean = M.getmean(samples)

    -- the size of the tables inside 'samples' is equal the number of
    -- environmental variables
    local nenvvar = #samples[1]

    -- variance (var2)
    for n=1,nenvvar do
        local sum = 0
        local var2
        local meanv = mean[n] -- TODO: store in a module var
                              -- to not recalculate

        for _, s in ipairs(samples) do
            sum = sum + math.pow(s[n] - meanv, 2)
        end
        var2 = sum / (#samples - 1)

        -- standard deviation
        table.insert(stddev, math.sqrt(var2))
    end

    return stddev
end

return M
