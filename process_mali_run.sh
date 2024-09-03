
MAPFILE=/lustre/scratch5/mhoffman/SLC_AIS_FOR_TIDES_20240830/MALI_data__processing/mapping_file/mapfile_mali_to_slm.nc
MAPFILE=/lustre/scratch5/mhoffman/SLC_AIS_FOR_TIDES_20240830/MALI_data__processing/mapping_file/mapfile_mali_to_slm.s2n.nc
CTRL_PATH=/lustre/scratch5/mhoffman/SLC_AIS_FOR_TIDES_20240830/MALI_data__processing/mali_output/ctrlAE

REMOVE_CONTROL=1

for yr in '2015' '2060' '2100' '2200' '2300'; do

if [ $REMOVE_CONTROL -eq 1 ]; then

echo "get initial ctrl thickness"
lithk_ctrl_init=$exp_out_path/preprocessed/lithk_${name_base_string}_ctrl_init.nc
ncks -O -d time,0 $ctrl_lithk_20152100 $lithk_ctrl_init
ncwa -O -a time $lithk_ctrl_init ${lithk_ctrl_init}_notime

echo "calculate ctrl anomaly over time"
lithk_ctrl_anom=$exp_out_path/preprocessed/lithk_${name_base_string}_ctrl_anomaly.nc
ncdiff -O $ctrl_lithk_20152100 ${lithk_ctrl_init}_notime $lithk_ctrl_anom
ncdiff -O 

echo "get last 86 time levels of projection"
# some runs have 87 instead of 86
# some models used nonstandard filenames, so use wildcard to find the correct file
lithkfile=`ls -1 $exp_in_path/*lithk_*.nc`
lithk_20152100=$exp_out_path/preprocessed/lithk_${IS}_${INST}_${ISM}_2015-2100.nc
ncks -O -d time,-86, $lithkfile $lithk_20152100

echo "remove ctrl anomaly from projection"
lithk_anom_adj=$exp_out_path/preprocessed/lithk_${name_base_string}_anomaly_adjusted.nc
ncdiff -O $lithk_20152100 $lithk_ctrl_anom $lithk_anom_adj

echo "ensure no negative thickness!"
lithk_anom_adj_cln=$exp_out_path/preprocessed/lithk_${name_base_string}_anomaly_adjusted_cleaned.nc
ncap2 -O -s "where(lithk<0.0) lithk=0.0" $lithk_anom_adj $lithk_anom_adj_cln

fi


   echo $yr
   ncap2 -O -s "where(thickness*910/1028+bedTopography<0) thickness=0.0" mali_${yr}.nc mali_grd_${yr}.nc
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
