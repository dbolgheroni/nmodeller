--[[
BIOCLIM algorithm module
------------------------

Copyright (c) 2013, Daniel Bolgheroni. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.

THIS SOFTWARE IS PROVIDED BY DANIEL BOLGHERONI ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DANIEL BOLGHERONI OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local M = {}

local gdal = require "lgdal"

-- some initial definitions
M.prefix = "[alg] "

-- avoid costly recalculations
local _min = {}
local _max = {}
local _mean = {}
local _stddev = {}

-- returns an array with the minimal values for each dataset
function getmin (samples)
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

        min[#min+1] = minv
    end

    return min
end

-- returns an array with the maximum values for each dataset
function getmax (samples)
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

        max[#max+1] = maxv
    end

    return max
end

-- returns an array with the mean values for each dataset
function getmean (samples)
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

        mean[#mean+1] = meanv
    end

    return mean
end

-- returns an array with the standard deviation values for each dataset
function getstddev (samples)
    local stddev = {}

    -- avoid costly recalculation
    local mean
    mean = _mean or getmean(samples) 

    -- the size of the tables inside 'samples' is equal the number of
    -- environmental variables
    local nenvvar = #samples[1]

    -- variance (var2)
    for n=1,nenvvar do
        local sum = 0
        local var2
        local meanv = mean[n] 

        for _, s in ipairs(samples) do
            sum = sum + math.pow(s[n] - meanv, 2)
        end
        var2 = sum / (#samples - 1)

        -- standard deviation
        stddev[#stddev+1] = math.sqrt(var2)
    end

    return stddev
end

-- returns an array with the envelope values for each dataset
function getenvelope (cutoff)
    local envelope = {}

    -- avoid costly recalculation
    local mean = _mean or getmean(samples)
    local stddev = _stddev or getstddev(samples)

    -- the size of the tables inside 'samples' is equal the number of
    -- environmental variables
    local nenvvar = #samples[1]

    for n=1,nenvvar do
        local e
        e = mean[n] - cutoff*stddev[n]

        envelope[#envelope+1] = e
    end

    return envelope
end

-- initialize basic values needed for the algorithm
function M.init (samples)
    _min = getmin(samples)
    _max = getmax(samples)
    _mean = getmean(samples)
    _stddev = getstddev(samples)

    io.write(M.prefix .. "Standard deviation cutoff [0.674]: ")
    cutoff = tonumber(io.read("*l")) or 0.674
    _envelope = getenvelope(cutoff)

    -- debug code ------------------------------------------
    if debug then
        print(dbgprefix .. "alg.init: ")

        nenvvar = #samples[1]
        for n=1,nenvvar do
            print(dbgprefix .. "_min[" .. n .. "]      = " .. _min[n])
            print(dbgprefix .. "_max[" .. n .. "]      = " .. _max[n])
            print(dbgprefix .. "_mean[" .. n .. "]     = " .. _mean[n])
            print(dbgprefix .. "_stddev[" .. n .. "]   = " .. _stddev[n])

            print(dbgprefix .. "_envelope[" .. n .. "] = " .. _envelope[n])
        end
    end
    -- end of debug code -----------------------------------
end

-- the kernel of the algorithm
function M.work (raster)
    proj = {}

    nenvvar = #raster -- number of environmental variables
    ymax = #raster[1] -- lines
    xmax = #raster[1][1]

    -- nodata
    local nodata = {}
    for n=1,nenvvar do nodata[#nodata+1] = gdal.nodata(band[n]) end

    -- iterate between each pointer
    for i=1,ymax do -- every line
        line = {}

        for j=1,xmax do -- every line value
            local outlimit = false
            local inenvelope = 0

            -- for each point, look in all envvar for the values
            local first = true -- for debug code
            local printv = true -- for debug code
            for n=1,nenvvar do
                p = raster[n][i][j] -- point value

                if p == nodata[n] then
                    line[#line + 1] = nodata[n]
                    printv = false -- debug code
                    break
                end

                -- debug code ------------------------------------------
                if debug then
                    if first then
                        io.write(dbgprefix)
                        first = false
                    end

                    io.write(string.format("%.02f", p) .. "\t")
                end
                -- end of debug code -----------------------------------

                if p < _min[n] or p > _max[n] then
                    outlimit = true
                    break
                end

                local q = p - _mean[n]
                if q > -_envelope[n] and q < _envelope[n] then
                    inenvelope = inenvelope + 1
                end
            end

            if outlimit then                  -- unsuitable
                line[#line+1] = 0.0
            elseif inenvelope == nenvvar then -- suitable
                line[#line+1] = 1.0
            elseif inenvelope > 0 then        -- marginal
                line[#line+1] = 0.5
            end

            -- debug code ------------------------------------------
            if debug and printv then
                if line[#line] then
                    print(string.format("%.02f", line[#line]))
                end
            end
            -- end of debug code -----------------------------------
        end

        proj[#proj+1] = line
    end

    return proj
end

return M
