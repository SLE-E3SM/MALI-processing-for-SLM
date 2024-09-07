from netCDF4 import Dataset
import numpy as np


yrs=['2060', '2100', '2200', '2300']
first=True
for yr in yrs:
   fname=f'mali_grd_remapped_{yr}.nc'
   
   rhoi=910.
   rhosw=1028.
   scaleVol=1.0e12 / rhoi
   SLscale = 1.0 / 3.62e14 * rhoi / rhosw
   
   f=Dataset(fname, 'r')
   a=f.variables['area'][:]
   lat=f.variables['lat'][:]
   r=6357e3 # m
   am2 = a * r**2
   f.close()


   f=Dataset(f'SLM_run_{yr}/OUTPUT_SLM/beta1.nc', 'r')
   beta=f.variables['beta'][:]
   f.close()

   f=Dataset(f'SLM_run_{yr}/OUTPUT_SLM/ocean1.nc', 'r')
   ocean=f.variables['ocean'][:]
   f.close()

   f=Dataset(f'SLM_run_{yr}/OUTPUT_SLM/tgrid1.nc', 'r')
   tgrid1=f.variables['tgrid'][:]
   f.close()

   f=Dataset(f'SLM_run_{yr}/OUTPUT_SLM/tgrid0.nc', 'r')
   tgrid0=f.variables['tgrid'][:]
   f.close()

   SLC = tgrid0-tgrid1

   GMSLC = (beta * ocean * SLC * am2).sum() / (beta * ocean * am2).sum()

   lat45=np.nonzero(lat>-45.0)[0]
   GMSLC45 = (beta[lat45,:] * ocean[lat45,:] * SLC[lat45,:] * am2[lat45,:]).sum() / (beta[lat45,:] * ocean[lat45,:] * am2[lat45,:]).sum()
   print(yr, GMSLC, GMSLC45)

