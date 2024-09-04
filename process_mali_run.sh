
MAPFILE=/lustre/scratch5/mhoffman/SLC_AIS_FOR_TIDES_20240830/MALI_data__processing/mapping_file/mapfile_mali_to_slm.nc
MAPFILE=/lustre/scratch5/mhoffman/SLC_AIS_FOR_TIDES_20240830/MALI_data__processing/mapping_file/mapfile_mali_to_slm.s2n.nc
CTRL_PATH=../ctrlAE

REMOVE_CONTROL=1

for yr in '2015' '2060' '2100' '2200' '2300'; do
   echo $yr

   if [ $REMOVE_CONTROL -eq 1 ]; then
      # calculate ctrl drift
      ncdiff -O -v thickness ${CTRL_PATH}/mali_${yr}.nc ${CTRL_PATH}/mali_2015.nc ${CTRL_PATH}/mali_diff_from_2015_${yr}.nc
      # remove ctrl anomaly from projection
      ncdiff -O -v thickness mali_${yr}.nc ${CTRL_PATH}/mali_diff_from_2015_${yr}.nc mali_dedrifted_${yr}.nc
      ncks -A -v bedTopography mali_${yr}.nc mali_dedrifted_${yr}.nc
      ncap2 -O -s "where(thickness<0.0) thickness=0.0" mali_dedrifted_${yr}.nc mali_dedrifted_cleaned_${yr}.nc
      ncap2 -O -s "where(thickness*910/1028+bedTopography<0) thickness=0.0" mali_dedrifted_cleaned_${yr}.nc mali_grd_${yr}.nc
   else
      ncap2 -O -s "where(thickness*910/1028+bedTopography<0) thickness=0.0" mali_${yr}.nc mali_grd_${yr}.nc
   fi

   ncremap -m $MAPFILE -i mali_grd_${yr}.nc -o mali_grd_remapped_${yr}.nc  --add_fll
   #ncatted -a _FillValue,,o,f,0.0 mali_grd_remapped_${yr}.nc
   #ncatted -a _FillValue,,d,, mali_grd_remapped_${yr}.nc
   python /lustre/scratch5/mhoffman/SLC_AIS_FOR_TIDES_20240830/MALI_data__processing/mali_output/reformat_SL_inputdata.py . mali_grd_remapped_${yr}.nc mali_grd_remapped_${yr}.nc 1

   ncatted -a _FillValue,,o,f,0.0 grdice0.nc
   ncatted -a _FillValue,,d,, grdice0.nc
   mv grdice0.nc grdice_${yr}.nc


   echo "set up run directory"
   mkdir -p SLM_run_${yr}/OUTPUT_SLM
   cp ../namelist.sealevel SLM_run_${yr}
   cp ../runslm SLM_run_${yr}
   cp ../job_script.sh SLM_run_${yr}
   cp grdice_2015.nc SLM_run_${yr}/grdice0.nc
   cp grdice_${yr}.nc SLM_run_${yr}/grdice1.nc
   cp topo_initial.nc SLM_run_${yr}
done
