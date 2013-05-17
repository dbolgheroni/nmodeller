/*
 * Copyright (c) 2013, Daniel Bolgheroni. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     1. Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *
 *     2. Redistributions in binary form must reproduce the above copyright
 *        notice, this list of conditions and the following disclaimer in
 *        the documentation and/or other materials provided with the
 *        distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY DANIEL BOLGHERONI ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DANIEL BOLGHERONI OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* DISCLAIMER: This should be the trickiest part of nmodeller. All the
 * complexities of dealing with GDAL libraries should be hidden here.
 * The API presented attend the requirement for the Lua part of
 * nmodeller to be as simple and trivial as possible, and make
 * straighforward to anyone to understand and extend nmodeller.
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
 
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "gdal.h"
 
/* globals */
GDALDatasetH hDataset;

/* open */
static int l_open (lua_State *L) {
    /* a raster is actually a band */
    printf("opening raster\n");
    const char *file;
    file = lua_tostring(L, 1);

    GDALRasterBandH hBand;
    GDALRasterBandH *raster;

    GDALAllRegister(); /* register drivers */
    hDataset = GDALOpen(file, GA_ReadOnly);
    hBand = GDALGetRasterBand(hDataset, 1);

    /* void *lua_newuserdata (lua_State *L, size_t size); */
    raster = (GDALRasterBandH *)lua_newuserdata(L, sizeof(GDALRasterBandH));
    *raster = hBand;

    /* support OO access (PiL2, p.263) */
    luaL_getmetatable(L, "lgdalmt");
    lua_setmetatable(L, -2);

    return 1;
}
 
/* nodata */
static int l_nodata (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALRasterBandH *r = (GDALRasterBandH *)lua_touserdata(L, 1);

    double nodata = GDALGetRasterNoDataValue(*r, 0);
    lua_pushnumber(L, nodata);

    return 1;
}

/* xmax */
static int l_xmax (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALRasterBandH *r = (GDALRasterBandH *)lua_touserdata(L, 1);

    int x = GDALGetRasterBandXSize(*r);
    lua_pushinteger(L, x);

    return 1;
}

/* ymax */
static int l_ymax (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALRasterBandH *r = (GDALRasterBandH *)lua_touserdata(L, 1);

    int y = GDALGetRasterBandYSize(*r);
    lua_pushinteger(L, y);

    return 1;
}

/* lonlat2xy */
static int l_lonlat2xy (lua_State *L) {
    /* lonlat instead of latlon convention, as in openModeller */
    double lat = lua_tonumber(L, 1);
    double lon = lua_tonumber(L, 2);
    printf("lat = %f\n", lat);
    printf("lon = %f\n", lon);

    double gt[6];
    if (GDALGetGeoTransform(hDataset, gt) == CE_None) {
        printf("origin = (%f, %f)\n", gt[0], gt[3]);
        printf("pixel size = (%f, %f)\n", gt[1], gt[5]);
        printf("? = (%f, %f)\n", gt[2], gt[4]);

        int x = (lat - gt[3]) / gt[5]; /* column */
        lua_pushinteger(L, x);

        int y = (lon - gt[0]) / gt[1]; /* line */
        lua_pushinteger(L, y);

        printf("(x, y) = (%d, %d)\n", x, y);
    }

    return 2;
}

/* read */
static int l_read (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALRasterBandH *r = (GDALRasterBandH *)lua_touserdata(L, 1);

    float *pafScanline;
    /* Lua has 3 ways to exchange values between functions: registry,
     * environment, upvalues. We'll use the ... */
    //pafScanline = (float *)CPLMalloc(sizeof (float)*x);

    return 1;
}

/* functions */
static const struct luaL_Reg lgdal_f [] = {
    {"open", l_open},
    {"lonlat2xy", l_lonlat2xy},
    {NULL, NULL} /* sentinel */
};
 
/* methods */
static const struct luaL_Reg lgdal_m [] = {
    {"nodata", l_nodata},
    {"xmax", l_xmax},
    {"ymax", l_ymax},
    {"read", l_read},
    {NULL, NULL} /* sentinel */
};

/* main function */
int luaopen_lgdal (lua_State *L) {
    /* set an environment to share data within module (PiL2, p.254) */
    lua_newtable(L);
    lua_replace(L, LUA_ENVIRONINDEX);

    /* support OO access (PiL2, p.266) */
    luaL_newmetatable(L, "lgdalmt");
    lua_pushvalue(L, -1); /* duplicate the metatable */
    lua_setfield(L, -2, "__index");

    luaL_register(L, NULL, lgdal_m);
    luaL_register(L, "lgdal", lgdal_f); /* 5.1 */
    //luaL_newlib(L, mylib); /* 5.2 */
    return 1;
}
