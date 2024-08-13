# PyTorch with OpenMPI singularity container

This is a singularity container which includes PyTorch with MPI backend support. The container is aimed to be used in HPC environments where MPI is the standard for parallel computing. Tested on [Wisteria/BDEC-01(Aquarius)](https://www.cc.u-tokyo.ac.jp/en/supercomputer/wisteria/system.php) cluster at The University of Tokyo.

For use with Wisetria/BDEC-01(Aquarius) cluster, see [wisteria/README.md](wisteria/README.md).

PyTorch from official package does not support MPI backend for distributed learning. By using this image, you can run multi-node distributed learning with PyTorch's DistributedDataParallel module on MPI backend.

## Software versions

This container is built based on `nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04` docker image. The following software versions are included:

- PyTorch v2.4.0
- torchvision v0.19.0
- OpenMPI v4.1.4
- UCX v1.17.0
- CUDA v12.4.1

## Usage

### Build

To build the container, run the following command:

```bash
singularity build --fakeroot container.sif container.def
```

By default, the number of build proccesses is set to 72, the same as the number of available cpu cores on Wisteria's `prepost` resource group. You should change the number by modifying `MAX_JOBS` environment variable in `container.def`.

**Warning:** The build process may take a long time and consumes a lot of memory. Make sure you have enough resources to build the container. In the case of Wisteria/BDEC-01(Aquarius) cluster, you need to use `prepost` resource group to avoid the build process being killed by the system.

### Run

You can run the container with the following command:

```bash
mpirun -np 4 singularity exec container.sif python3 /path/to/your/script.py
```

## Notes

- To improve build time, backends other than MPI (`gloo` and `nccl`) is not built.
- Build process rarely fails due to unexpected reason. In that case, just try again.