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
 * straighforward for anyone to understand and extend nmodeller.
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
 
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "gdal.h"
 
/* open */
static int l_open (lua_State *L) {
    const char *file;
    file = lua_tostring(L, 1);

    GDALDatasetH dataset;
    GDALDatasetH *layer;

    /* open -> dataset */
    GDALAllRegister(); /* register drivers */
    dataset = GDALOpen(file, GA_ReadOnly);

    /* void *lua_newuserdata (lua_State *L, size_t size); */
    layer = (GDALDatasetH *)lua_newuserdata(L, sizeof(GDALDatasetH));
    *layer = dataset;

    return 1;
}

static int l_band (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALDatasetH *dataset = (GDALDatasetH *)lua_touserdata(L, 1);

    GDALRasterBandH *band;
    band = (GDALRasterBandH *)lua_newuserdata(L, sizeof(GDALRasterBandH));
    *band = GDALGetRasterBand(*dataset, 1);

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
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALDatasetH *dataset = (GDALDatasetH *)lua_touserdata(L, 1);
    double lon = lua_tonumber(L, 2);
    double lat = lua_tonumber(L, 3);

    double gt[6];
    if (GDALGetGeoTransform(*dataset, gt) == CE_None) {
        int x = (lat - gt[3]) / gt[5];
        lua_pushinteger(L, x);

        int y = (lon - gt[0]) / gt[1];
        lua_pushinteger(L, y);
    }

    return 2;
}

/* read */
static int l_read (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALRasterBandH *r = (GDALRasterBandH *)lua_touserdata(L, 1);

    int x = GDALGetRasterBandXSize(*r);
    int y = GDALGetRasterBandYSize(*r);

    int i, j;
    float *line;
    line = (float *) calloc(sizeof(float), x);

    double nodata = GDALGetRasterNoDataValue(*r, 0);

    lua_newtable(L); /* lines, stack index 2 */
    for (i = 0; i < y; i++) {
        GDALRasterIO(*r, GF_Read, 0, i, x, 1, line,
                     x, 1, GDT_Float32, 0, 0);

        lua_newtable(L); /* columns, stack index 3 */
        for (j = 0; j < x; j++) {
            lua_pushinteger(L, j);
            lua_pushnumber(L, line[j]);
            lua_settable(L, 3);

            //printf("C: %dx%d: %f\n", i, j, line[j]);
        }

        lua_pushinteger(L, i);
        lua_insert(L, 3);
        lua_settable(L, 2);
    }

    free(line);

    return 1;
}

/* functions */
static const struct luaL_Reg lgdal [] = {
    {"open", l_open},
    {"band", l_band},
    {"read", l_read},
    {"lonlat2xy", l_lonlat2xy},
    {"nodata", l_nodata},
    {"xmax", l_xmax},
    {"ymax", l_ymax},
    {"read", l_read},
    {NULL, NULL} /* sentinel */
};
 
/* main function */
int luaopen_lgdal (lua_State *L) {
    /* set an environment to share data within module (PiL2, p.254) */
    //lua_newtable(L);
    //lua_replace(L, LUA_ENVIRONINDEX);

    /* support OO access (PiL2, p.266) */
    //luaL_newmetatable(L, "lgdalmt");
    //lua_pushvalue(L, -1); /* duplicate the metatable */
    //lua_setfield(L, -2, "__index");

    //luaL_register(L, NULL, lgdal_m);
    //luaL_register(L, "lgdal", lgdal_f); /* 5.1 */
    luaL_register(L, "lgdal", lgdal); /* 5.1 */
    //luaL_newlib(L, mylib); /* 5.2 */
    return 1;
}
