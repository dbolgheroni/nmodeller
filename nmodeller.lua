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
prefix = "[nmodeller] "

-- check for the file describing the job
job = arg[1]
if job and io.open(job) then
    dofile(job)
    print(prefix .. job .. " opened succesfully")
else
    print("no file describing the job")
    os.exit(1)
end

print(prefix .. #occ .. " occurrence points found")

-- 1:1 dataset/band, in other words, there is 1 band (band)
-- for each dataset (only 1 band supported)
dataset = {}
band = {}
raster = {}
for i, file in ipairs(envvars) do
    print(prefix .. "opening " .. file)
    dataset[i] = gdal.open(file) -- TODO: check for error

    print(prefix .. "reading " .. file)
    band[i] = gdal.band(dataset[i]) -- TODO: check for error
    raster[i] = gdal.read(band[i]);
end

function getsamples ()
    local samples = {}

    for i, o in ipairs(occ) do
        local lon = o[3]
        local lat = o[4]
        local occ = {}

        -- cycle between each environmental variable for each occurrence 
        for j, p in ipairs(raster) do
            x, y = gdal.lonlat2xy(dataset[j], lon, lat)
            value = raster[j][x][y]
            table.insert(occ, raster[j][x][y])
        end

        table.insert(samples, occ);
    end

    return samples;
end

-- nmodeller work begins here
samples = {}
samples = getsamples()

-- print samples
for i, v in ipairs(samples) do
    print(prefix .. samples[i][1] .. ", " .. samples[i][2])
end

-- choose algorithm
alg = bioclim

alg.init(samples)
alg.work(raster)
