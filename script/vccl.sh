#! /bin/bash

TIMESTAMP=$(date +'%Y.%m.%d-%H:%M:%S')

NET_DEVICE="ens99f3"
MLP_GPU=8
MLP_MPI_HOSTFILE=$2
MLP_WORKER_0_PORT=29500
MLP_WORKER_NUM=$3
LOG=tensorboard/
source $1

mkdir -p logs/${EXP_NAME}

mpirun -np $((MLP_WORKER_NUM * MLP_GPU)) \
        --hostfile ${MLP_MPI_HOSTFILE} \
        --allow-run-as-root   \
	--output-filename logs/${TIMESTAMP} \
        -x NCCL_DEBUG=VERSION \
        -x PATH \
	-x LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/workspace/vccl_2.21.51x/build/lib/ \
        -x MASTER_ADDR=$(cat $MLP_MPI_HOSTFILE | head -n 1 | sed -s 's/slots=8//g') \
        -x MASTER_PORT=${MLP_WORKER_0_PORT} \
        -x GLOO_SOCKET_IFNAME=${NET_DEVICE} \
        -x NCCL_SOCKET_IFNAME=${NET_DEVICE} \
	-x NCCL_IB_RETRY_CNT=255 \
	-x NCCL_IB_TIMEOUT=25 \
	-x CUDA_DEVICE_MAX_CONNECTIONS=1 \
	-x NCCL_NVLS_ENABLE=0 \
	-x NCCL_PXN_DISABLE=0 \
        python   ${script_path} ${gpt_options}    2>&1 | tee logs/${EXP_NAME}/output_${TIMESTAMP}.log
