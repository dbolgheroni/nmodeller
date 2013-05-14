#include <stdio.h>
#include "gdal.h"
#include "cpl_conv.h"

int main() {
    /* opening the file */
    printf("opening raster\n");

    GDALDatasetH hDataset;
    GDALAllRegister();
    hDataset = GDALOpen("temp_avg.tif", GA_ReadOnly);

    /* fetching a raster band */
    printf("fetching a raster band\n");

    GDALRasterBandH hBand;
    int             nBlockXSize, nBlockYSize;
    int             bGotMin, bGotMax;
    double          adfMinMax[2];

    hBand = GDALGetRasterBand(hDataset, 1);

    /* too gdalinfo specific
    GDALGetBlockSize( hBand, &nBlockXSize, &nBlockYSize );
    printf( "Block=%dx%d Type=%s, ColorInterp=%s\n",
            nBlockXSize, nBlockYSize,
            GDALGetDataTypeName(GDALGetRasterDataType(hBand)),
            GDALGetColorInterpretationName(
                GDALGetRasterColorInterpretation(hBand)) );

    adfMinMax[0] = GDALGetRasterMinimum( hBand, &bGotMin );
    adfMinMax[1] = GDALGetRasterMaximum( hBand, &bGotMax );
    if( ! (bGotMin && bGotMax) )
        GDALComputeRasterMinMax( hBand, TRUE, adfMinMax );

    printf( "Min=%.3fd, Max=%.3f\n", adfMinMax[0], adfMinMax[1] );

    if( GDALGetOverviewCount(hBand) > 0 )
        printf( "Band has %d overviews.\n", GDALGetOverviewCount(hBand));

    if( GDALGetRasterColorTable( hBand ) != NULL )
        printf( "Band has a color table with %d entries.\n", 
                GDALGetColorEntryCount(
                    GDALGetRasterColorTable( hBand ) ) );
    */

    /* reading raster data */
    printf("reading raster data\n");

    float *pafScanline;
    int nXSize = GDALGetRasterBandXSize(hBand);
    int nYSize = GDALGetRasterBandYSize(hBand);

    pafScanline = (float *) CPLMalloc(sizeof (float)*nXSize);

    /* read nodata value */
    double nodata = GDALGetRasterNoDataValue(hBand, 0);
    printf("NoData: %e\n", nodata);

    printf("nXSize: %d; nYSize: %d\n", nXSize, nYSize);

    /* converting coordinates */
    float lon = -68.85;
    float lat = -11.15;
    //printf("Coordinates: x = %.2f, y = %.2f\n", x, y);
    double gt[6];
    if (GDALGetGeoTransform(hDataset, gt) == CE_None) {
        printf("origin = (%f, %f)\n", gt[0], gt[3]);
        printf("pixel size = (%f, %f)\n", gt[1], gt[5]);
        printf("? = (%f, %f)\n", gt[2], gt[4]);

        int y = (lon - gt[0]) / gt[1]; /* line */
        int x = (lat - gt[3]) / gt[5]; /* column */
        printf("(x, y) = (%d, %d)\n", x, y);
    }

    int i, j;
    for (i = 0; i < nYSize; i++) {
        /* read one line */
        GDALRasterIO(hBand,       /* Dataset */
                     GF_Read,     /* RW */
                     0, i,        /* Off */
                     nXSize, 1,   /* Size */
                     pafScanline, /* Data */
                     nXSize, 1,   /* BufSize */
                     GDT_Float32, /* BufType */
                     0,           /* PixelSpace */
                     0);          /* LineSpace */

        /* print line */
        for (j = 0; j < nXSize; j++) {
            /* only print non-no-data values */
            if (pafScanline[j] != nodata) { 
                printf("%dx%d: %f\n", i, j, pafScanline[j]);
            }
            /*
            if (i == 288 && j == 262)
                printf("value = %f\n", pafScanline[j]);
            */
        }
    }
}
