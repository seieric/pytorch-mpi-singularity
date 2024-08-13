# Wisteria-Aで利用する方法

東京大学情報基盤センターのWisteria-Aでの利用方法について説明します。
まずはじめに、本リポジトリをクローンしてください。

```bash
git clone https://github.com/seieric/pytorch-mpi-singularity.git
cd pytorch-mpi-singularity
```

## ビルド

コンテナのビルドには十分な計算資源が必要であるため、リソースグループ`prepost`を利用してください。
`prepost`を利用せずに、ビルドを行うとシステムによりビルドが強制終了される場合があります（確認済み）。

```bash
pjsub --interact -g $(id -ng) -L rscgrp=prepost -L jobenv=singularity
```

次に、以下のコマンドを実行してコンテナをビルドしてください。もしくは、`./wisteria/build.sh`を実行してください。

```bash
module load singularity/3.9.5
singularity build --fakeroot container.sif container.def
```

正常にビルドが完了すると、`container.sif`が生成されます。
正常にビルドが完了しなかった場合でも、もう一度実行すると成功することがあります。

## 実行

バッチジョブとして実行する方法を説明します。
ジョブ投入用のジョブスクリプトと、各MPIプロセスで実行するスクリプトを作成します。
torchやtorchvision以外のパッケージを利用する場合には、あらかじめ必要なパッケージをインストールしたコンテナをビルドしてください。

### ジョブスクリプト(`sample_job.sh`)

4ノード、32GPUで実行する例です。実行時間制限や所属グループなどは適宜変更してください。
なお、マスターノードのホスト側のOpenMPIは、コンテナ内のOpenMPIと同じバージョン（`4.1.4`）を利用しています。

```bash
#!/bin/sh

#PJM -g <your group name>
#PJM --fs /work
#PJM -j
#PJM --norestart
#PJM -L rscgrp=regular-a
#PJM -L node=4
#PJM -L elapse=0:10:00
#PJM -L jobenv=singularity
#PJM --mpi proc=32

BASE_DIR=$HOME/pytorch-mpi-singularity
module load nvidia/22.7 ompi/4.1.4
mpirun -np ${PJM_MPI_PROC} -machinefile ${PJM_O_NODEINF} \
  -map-by ppr:8:node -mca pml ob1 --mca btl self,tcp -mca btl_tcp_if_include ib0,ib1,ib2,ib3 \
  --wdir ${BASE_DIR} \
  scripts/run.sh
```

### 実行スクリプト(`sample_run.sh`)

各MPIプロセスごとにsingularityコンテナ内でスクリプトを実行します。

```bash
#!/bin/sh
module load singularity/3.9.5
singularity run --bind `pwd` --nv container.sif python3 /path/to/your/script.py
```