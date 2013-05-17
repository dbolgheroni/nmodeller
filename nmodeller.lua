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

-- some initial definitions
prefix = "[nmodeller] "

job = arg[1]
-- check for the file describing the job
if job and io.open(job) then -- TODO: deal with an empty jog
    dofile(job)
    print(prefix .. job .. " opened succesfully")
else
    print("no file describing the job")
    os.exit(1)
end

print(prefix .. #occ .. " occurrence points found")

raster = gdal.open("temp_avg.tif")
print("DEBUG")
print("nodata = " .. raster:nodata())
print("xmax = " .. raster:xmax())
print("ymax = " .. raster:ymax())

print("lonlat2xy()") 
print(gdal.lonlat2xy(-11.15, -68.85))
