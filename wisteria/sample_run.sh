#!/bin/sh
module load singularity/3.9.5
singularity run --bind `pwd` --nv container.sif python3 /path/to/your/script.py