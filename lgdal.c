#include <stdio.h>
#include <string.h>
#include <math.h>
 
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "gdal.h"
 
/* coringa */
static int l_sin (lua_State *L) {
    double d = luaL_checknumber(L, 1);
    lua_pushnumber(L, sin(d));
    return 1;
}

/* open raster */
static int l_open (lua_State *L) {
    /* a raster is actually a band */
    printf("opening raster\n");
    const char *file;
    file = lua_tostring(L, 1);

    //GDALDatasetH *dataset;

    /* userdata will be a GDALDatasetH */
    //dataset = (GDALDatasetH *)lua_newuserdata(L, sizeof(GDALDatasetH));
    //dataset = GDALOpen(file, GA_ReadOnly); 

    GDALDatasetH hDataset;
    GDALRasterBandH hBand;
    GDALRasterBandH *raster;

    GDALAllRegister(); /* register drivers */
    hDataset = GDALOpen(file, GA_ReadOnly);
    hBand = GDALGetRasterBand(hDataset, 1);

    //raster = &hBand; /* DON'T */
    /* void *lua_newuserdata (lua_State *L, size_t size); */
    raster = (GDALRasterBandH *)lua_newuserdata(L, sizeof(GDALRasterBandH));
    *raster = hBand;

    return 1;
}
 
static int l_nodata (lua_State *L) {
    /* void *lua_touserdata (lua_State *L, int index); */
    GDALRasterBandH *r = (GDALRasterBandH *)lua_touserdata(L, 1);

    double nodata = GDALGetRasterNoDataValue(*r, 0);
    lua_pushnumber(L, nodata);

    return 1;
}

/* functions */
static const struct luaL_Reg lgdal [] = {
    {"mysin", l_sin},
    {"open", l_open},
    {"nodata", l_nodata},
    {NULL, NULL} /* sentinel */
};
 
/* main function */
int luaopen_lgdal (lua_State *L) {
    luaL_register(L, "lgdal", lgdal); /* 5.1 */
    //luaL_newlib(L, mylib); /* 5.2 */
    return 1;
}
