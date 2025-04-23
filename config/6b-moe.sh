#!/bin/bash
DATA_PATH=/workspace/infra/Megatron-LM/data/wudao_mistralbpe_content_document
TOKENIZER_MODEL=/workspace/infra/Megatron-LM/data/tokenizer.model

EXP_NAME="6b"

MICRO_BATCH_SIZE=2
GLOBAL_BATCH_SIZE=$((MLP_WORKER_NUM * 128))


TP_SIZE=2
PP_SIZE=2

NHIDDEN=4096
FFN_HIDDEN=14336
NLAYERS=28
NHEADS=32
SEQ_LEN=4096

SAVE_INTERVAL=2500

script_path="pretrain_gpt.py"

OPTIMIZER_ARGS="
    --optimizer adam \
    --adam-beta1 0.9 \
    --adam-beta2 0.95 \
    --adam-eps 1e-8 \
    --lr 1.5e-4 \
    --min-lr 1.0e-5 \
    --lr-decay-style cosine \
    --train-iters 10000
    --lr-decay-iters  9000 \
    --lr-warmup-fraction  .01  \
    --clip-grad 1.0 \
    --weight-decay 1e-2 \
    --hidden-dropout 0.0 \
    --attention-dropout 0.0 \
    --initial-loss-scale 65536 \
"

MODEL_ARGS="
    --bf16 \
    --num-layers $NLAYERS \
    --hidden-size $NHIDDEN \
    --ffn-hidden-size $FFN_HIDDEN \
    --seq-length $SEQ_LEN \
    --tokenizer-type GPT2BPETokenizer \
    --group-query-attention \
    --num-query-groups 2 \
    --max-position-embeddings $SEQ_LEN \
    --num-attention-heads $NHEADS \
    --disable-bias-linear \
    --swiglu \
    --use-flash-attn \
    --transformer-impl transformer_engine \
    --untie-embeddings-and-output-weights \
    --position-embedding-type rope \
    --no-position-embedding \
    --normalization RMSNorm \
    --use-mcore-models \
    --manual-gc \
"

TRAINING_ARGS="
    --micro-batch-size $MICRO_BATCH_SIZE \
    --global-batch-size $GLOBAL_BATCH_SIZE \
    --tensor-model-parallel-size $TP_SIZE \
    --pipeline-model-parallel-size $PP_SIZE \
    --num-layers-per-virtual-pipeline-stage 1 \
    --use-distributed-optimizer \
    --recompute-granularity selective \
    --sequence-parallel \
"

DATA_ARGS="
    --data-path $DATA_PATH \
    --tokenizer-type Llama2Tokenizer \
    --tokenizer-model ${TOKENIZER_MODEL} \
    --split 949,50,1
"

OUTPUT_ARGS="
    --log-interval 1 \
    --eval-iters 10 \
    --eval-interval 1000 \
    --save-interval $SAVE_INTERVAL \
    --log-throughput \
    --timing-log-level 2  \
    --log-timers-to-tensorboard \
    --log-memory-to-tensorboard \
    --tensorboard-dir $LOG  \
"

MOE_ARGS="
    --moe-enable-deepep \
    --moe-token-dispatcher-type flex \
    --num-experts 4 \
    --moe-router-topk 2 \
    --moe-router-load-balancing-type aux_loss \
    --expert-model-parallel-size 2 \
    --moe-aux-loss-coeff 1e-2 \
    --overlap-param-gather \
    --overlap-grad-reduce \
"
   

gpt_options="
    $MODEL_ARGS \
    $TRAINING_ARGS \
    $OPTIMIZER_ARGS \
    $DATA_ARGS \
    $OUTPUT_ARGS \
    $MOE_ARGS \
    --distributed-timeout-minutes 60 \
    --init-method-std 0.01 \
"
