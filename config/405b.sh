#!/bin/bash
VOCAB_FILE=./train-data/data/gpt2-vocab.json
MERGE_FILE=./train-data/data/gpt2-merges.txt
DATA_PATH=./train-data/data/CodeData-gpt2_text_document

EXP_NAME="405b"

MICRO_BATCH_SIZE=1
GLOBAL_BATCH_SIZE=$((MLP_WORKER_NUM * 8))

TP_SIZE=1
PP_SIZE=4

NHIDDEN=8192
FFN_HIDDEN=12800
NLAYERS=48
NHEADS=64
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

    
  #  --num-layers-per-virtual-pipeline-stage 1 \
    #--tp-comm-overlap \
    #--recompute-granularity selective \
TRAINING_ARGS="
    --micro-batch-size $MICRO_BATCH_SIZE \
    --global-batch-size $GLOBAL_BATCH_SIZE \
    --tensor-model-parallel-size $TP_SIZE \
    --pipeline-model-parallel-size $PP_SIZE \
    --use-distributed-optimizer \
    --sequence-parallel \
    --num-layers-per-virtual-pipeline-stage 1 \
"

DATA_ARGS="
    --data-path $DATA_PATH \
    --vocab-file $VOCAB_FILE \
    --merge-file $MERGE_FILE \
    --split 949,50,1 \
"

OUTPUT_ARGS="
    --log-interval 1 \
    --eval-iters 0 \
    --eval-interval  1000 \
    --save-interval $SAVE_INTERVAL \
    --log-throughput \
    --timing-log-level 0  \
    --log-timers-to-tensorboard \
    --log-memory-to-tensorboard \
"

gpt_options="
    $MODEL_ARGS \
    $TRAINING_ARGS \
    $OPTIMIZER_ARGS \
    $DATA_ARGS \
    $OUTPUT_ARGS \
    --distributed-timeout-minutes 60 \
    --init-method-std 0.01 \
"
