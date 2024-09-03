#!/bin/bash
#SBATCH  --job-name=slm
#SBATCH  --nodes=1
#SBATCH  --exclusive
#SBATCH  --time=01:00:00

date
srun -n 1 ./runslm
date
