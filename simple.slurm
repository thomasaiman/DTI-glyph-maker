#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem=1G
#SBATCH --output=simple%a.out
#SBATCH --array=3-6%200

echo "SLURM_JOBDID: " $SLURM_JOBID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID

export MY_COOL_VARIABLE='suh dude'
echo 'The value we assigned to that variable is...'
echo $MY_COOL_VARIABLE

echo 'we are in task number:'
echo $SLURM_ARRAY_TASK_ID

#uncomment the next two lines to open MATLAB and run 'x = ones(5)' in MATLAB

#module load MATLAB
#matlab -r "x = ones(5)"





