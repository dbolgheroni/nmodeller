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
    printf("opening raster\n");

    GDALDatasetH hDataset;
    GDALAllRegister();
    hDataset = GDALOpen("temp_avg.tif", GA_ReadOnly);
}
 
/* functions */
static const struct luaL_Reg lgdal [] = {
    {"mysin", l_sin},
    {NULL, NULL} /* sentinel */
};
 
/* main function */
int luaopen_lgdal (lua_State *L) {
    luaL_register(L, "lgdal", lgdal); /* 5.1 */
    //luaL_newlib(L, mylib); /* 5.2 */
    return 1;
}
