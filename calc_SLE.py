from netCDF4 import Dataset
import numpy as np


yrs=['2015', '2060', '2100', '2200', '2300']
first=True
for yr in yrs:
   fname=f'mali_grd_remapped_{yr}.nc'
   
   rhoi=910.
   rhosw=1028.
   scaleVol=1.0e12 / rhoi
   SLscale = 1.0 / 3.62e14 * rhoi / rhosw
   
   f=Dataset(fname, 'r')
   a=f.variables['area'][:]
   H=f.variables['thickness'][:]
   bed=f.variables['bedTopography'][:]
   Haf = np.maximum(0.0, H*910/1028+bed)
   
   r=6357e3 # m
   
   am2 = a * r**2
   volaf = (am2 * Haf).sum()
   vol = (am2 * H).sum()
   
   ocnarea = 361.e6 * 1.e3**2 # m2 (361 million square kilometers)


   if first==True:
       volaf0=volaf
       vol0=vol
       first=False
   print(f'YEAR={yr}')
   print(f'Haf: icevol={volaf/scaleVol} Gt , SLE={volaf*SLscale} m')
   print(f'H:   icevol={vol/scaleVol} Gt , SLE={vol*SLscale} m')
   print("DIFFERENCES")
   print(f'Haf: icevol={(volaf-volaf0)/scaleVol} Gt , SLE={(volaf-volaf0)*SLscale} m')
   print(f'H:   icevol={(vol-vol0)/scaleVol} Gt , SLE={(vol-vol0)*SLscale} m')
   print("")
