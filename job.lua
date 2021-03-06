-- example job
job = {}

-- list of maps used as environmental variables
job.envvars = { "rain_coolest.tif", "temp_avg.tif" }

-- mask
job.mask = "temp_avg.tif"

-- algorithm used
job.algorithm = 1
job.cutoff = 0.674

-- filename of the output model
job.output = "nmmodel.tif"

-- list of species occurrence
job.occ = {
    {  1, "furcata boliviana", -68.85, -11.15, 1 },
    {  2, "furcata boliviana", -67.38, -14.32, 1 },
    {  3, "furcata boliviana", -67.55, -14.33, 1 },
    {  4, "furcata boliviana", -67.58, -14.50, 1 },
    {  5, "furcata boliviana", -68.17, -15.25, 1 },
    {  6, "furcata boliviana", -67.75, -15.27, 1 },
    {  7, "furcata boliviana", -68.46, -15.27, 1 },
    {  8, "furcata boliviana", -68.27, -15.37, 1 },
    {  9, "furcata boliviana", -67.80, -15.45, 1 },
    { 10, "furcata boliviana", -67.87, -15.47, 1 },
    { 11, "furcata boliviana", -67.50, -15.50, 1 },
    { 12, "furcata boliviana", -67.52, -15.50, 1 },
    { 13, "furcata boliviana", -67.15, -15.52, 1 },
    { 14, "furcata boliviana", -67.66, -15.82, 1 },
    { 15, "furcata boliviana", -67.57, -15.83, 1 },
    { 16, "furcata boliviana", -67.92, -15.89, 1 },
    { 17, "furcata boliviana", -64.70, -15.97, 1 },
    { 18, "furcata boliviana", -67.18, -16.03, 1 },
    { 19, "furcata boliviana", -66.74, -16.32, 1 },
    { 20, "furcata boliviana", -67.54, -16.40, 1 },
    { 21, "furcata boliviana", -67.71, -16.41, 1 },
    { 22, "furcata boliviana", -66.96, -16.64, 1 },
    { 23, "furcata boliviana", -65.12, -16.73, 1 },
    { 24, "furcata boliviana", -65.13, -16.80, 1 },
    { 25, "furcata boliviana", -65.40, -16.95, 1 },
    { 26, "furcata boliviana", -65.37, -16.97, 1 },
    { 27, "furcata boliviana", -65.67, -17.08, 1 },
    { 28, "furcata boliviana", -65.52, -17.10, 1 },
    { 29, "furcata boliviana", -63.55, -17.32, 1 },
    { 30, "furcata boliviana", -63.75, -17.40, 1 },
    { 31, "furcata boliviana", -65.02, -17.46, 1 },
    { 32, "furcata boliviana", -63.63, -17.49, 1 },
    { 33, "furcata boliviana", -63.17, -17.80, 1 },
    { 34, "furcata boliviana", -63.61, -18.17, 1 },
    { 35, "furcata boliviana", -63.76, -18.80, 1 },
    { 36, "furcata boliviana", -63.96, -19.21, 1 },
    { 37, "furcata boliviana", -64.06, -19.32, 1 },
    { 38, "furcata boliviana", -64.03, -19.82, 1 },
    { 39, "furcata boliviana", -70.97,  -9.97, 1 },
    { 40, "furcata boliviana", -71.27, -11.92, 1 },
    { 41, "furcata boliviana", -70.92, -12.22, 1 },
    { 42, "furcata boliviana", -72.83, -12.33, 1 },
    { 43, "furcata boliviana", -69.05, -12.53, 1 },
    { 44, "furcata boliviana", -69.18, -12.60, 1 },
    { 45, "furcata boliviana", -70.33, -12.65, 1 },
    { 46, "furcata boliviana", -71.23, -12.67, 1 },
    { 47, "furcata boliviana", -69.73, -12.68, 1 },
    { 48, "furcata boliviana", -69.50, -12.83, 1 },
    { 49, "furcata boliviana", -71.25, -12.83, 1 },
    { 50, "furcata boliviana", -69.28, -12.85, 1 },
    { 51, "furcata boliviana", -71.31, -12.87, 1 },
    { 52, "furcata boliviana", -70.30, -12.92, 1 },
    { 53, "furcata boliviana", -68.88, -12.95, 1 },
    { 54, "furcata boliviana", -71.18, -13.00, 1 },
    { 55, "furcata boliviana", -71.24, -13.12, 1 },
    { 56, "furcata boliviana", -69.60, -13.13, 1 },
    { 57, "furcata boliviana", -70.37, -13.20, 1 },
    { 58, "furcata boliviana", -70.30, -13.28, 1 },
    { 59, "furcata boliviana", -70.59, -13.28, 1 },
    { 60, "furcata boliviana", -70.64, -13.30, 1 },
    { 61, "furcata boliviana", -69.62, -13.37, 1 },
    { 62, "furcata boliviana", -69.68, -13.52, 1 },
    { 63, "furcata boliviana", -69.56, -13.64, 1 },
    { 64, "furcata boliviana", -69.97, -13.80, 1 },
    { 65, "furcata boliviana", -69.66, -13.88, 1 }
}

job.debug = false
