#!/usr/bin/env lua51

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
print("x = " .. raster:x())
print("y = " .. raster:y())
