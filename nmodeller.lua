#!/usr/bin/env lua51

--[[
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

local gdal = require "lgdal"
local bioclim = require "alg_bioclim"

-- some initial definitions
prefix = "[mod] "
dbgprefix = "[dbg] "

-- check for the file describing the job
jobfile = arg[1]
if jobfile and io.open(jobfile) then
    dofile(jobfile)
    print(prefix .. jobfile .. " opened succesfully")
else
    print("no file describing the job")
    os.exit(1)
end

print(prefix .. #job.occ .. " occurrence points found")

-- debug code
debug = job.debug

-- 1:1 dataset/band, in other words, there is 1 band (band)
-- for each dataset (only 1 band supported)
dataset = {}
band = {}
raster = {}
for n, file in ipairs(job.envvars) do
    print(prefix .. "opening " .. file)
    dataset[n] = gdal.open(file) -- TODO: check for error

    print(prefix .. "reading " .. file)
    band[n] = gdal.band(dataset[n]) -- TODO: check for error
    raster[n] = gdal.read(band[n]);
end

function getsamples ()
    local samples = {}

    for _, o in ipairs(job.occ) do
        local lon = o[3]
        local lat = o[4]
        local occ = {}

        -- cycle between each environmental variable for each occurrence 
        for j, p in ipairs(raster) do
            local x, y
            x, y = gdal.lonlat2xy(dataset[j], lon, lat)
            x = x + 1 -- offset to match Lua 1-index
            y = y + 1 -- offset to match Lua 1-index

            value = raster[j][x][y]
            occ[#occ+1] = raster[j][x][y]
        end

        samples[#samples+1] = occ
    end

    return samples;
end

samples = {}
samples = getsamples()

-- print samples
if debug then
    print(dbgprefix .. "samples: ")
    for i, v in ipairs(samples) do
        print(dbgprefix .. samples[i][1], samples[i][2])
    end
end

-- choose algorithm
if not job.algorithm then
    print(prefix)
    print(prefix .. "Algorithm selection: ")
    print(prefix .. " [1] BIOCLIM")
    io.write(prefix .. "Option[1]: ")
    job.algorithm = tonumber(io.read("*l")) or 1
end

algparam = {}
if job.algorithm == 1 then
    alg = bioclim

    -- it's optional to pass a table with parameters to the algorithm
    if job.cutoff then algparam.cutoff = job.cutoff end
end

-- main
alg.init(samples, algparam) -- init algorithms with samples from the job file
local nodatav
proj = alg.work(raster) -- the real work

print(prefix .. "projecting model")
--gdal.write(job.mask, proj) -- do the projection
gdal.write(job.mask, proj) -- do the projection
