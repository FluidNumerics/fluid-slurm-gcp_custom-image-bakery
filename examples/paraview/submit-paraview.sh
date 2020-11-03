#!/bin/bash
 
 echo "Usage : Port, Slurm Account, Slurm Partition, Num-MPI-procs, Memory-per-rank, Hours needed"
 
 LOGIN=$(hostname -s)
 JOB=$RANDOM
 TEMP_FILE="/tmp/sbatch-script.$JOB.slurm"
 
 echo "Temporary job file: $TEMP_FILE" # show file name
  
 echo "#!/bin/bash"                                           >> $TEMP_FILE
 echo "#SBATCH --account=$2"                                           >> $TEMP_FILE
 echo "#SBATCH --partition=$3"                                           >> $TEMP_FILE
 echo "#SBATCH --ntasks=$4"                                            >> $TEMP_FILE
 echo "#SBATCH --cpus-per-task=1"                                      >> $TEMP_FILE
 echo "#SBATCH --mem-per-cpu=$5g"                                      >> $TEMP_FILE
 echo "#SBATCH --time=$6:00:00"                                        >> $TEMP_FILE
 echo "#SBATCH --job-name=paraview-$JOB"                               >> $TEMP_FILE
 echo "#SBATCH -o paraview-$JOB.log"                               >> $TEMP_FILE
 echo "#SBATCH -e paraview-$JOB.log"                               >> $TEMP_FILE
 echo ""                                                               >> $TEMP_FILE
 echo "source /etc/profile.d/paraview.sh"                              >> $TEMP_FILE
 echo ""                                                               >> $TEMP_FILE
 
 echo "mpirun -np \${SLURM_NTASKS} pvserver -rc -ch=$LOGIN --server-port=$1 --force-offscreen-rendering" >> $TEMP_FILE
 
 # display the job submission
 cat $TEMP_FILE
 
 # submit the job
 /apps/slurm/current/bin/sbatch --get-user-env $TEMP_FILE

 echo 'Waiting for Slurm job to begin..'
 while true; do
  export JOB_STATUS=$(/apps/slurm/current/bin/squeue -n paraview-$JOB --format="%.2t" | tail -n1 | xargs)
  echo "Job Status : $JOB_STATUS"
  if [ "$JOB_STATUS" == "R" ]; then
    echo "Job started!"
    break
  else
    sleep 10
  fi
 done

 echo "Waiting for pvserver to start..."
 while true; do
   PV_STATUS=$(grep "Client connected." paraview-$JOB.log)
   if [ "$PV_STATUS" = "Client connected." ]; then
     echo "Paraview Server connected!"
     break
   else
     echo "Waiting for pvserver to connect to client..."
     sleep 5
   fi
 done
