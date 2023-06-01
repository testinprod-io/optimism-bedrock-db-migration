# Optimistic Erigon Mainnet Bedrock Migration

Warning: Every calculation assumed every factor is **linearly related**.

## Recon

|   | Goerli | Mainnet |
|---|--------|---------|
| Block Number | $4061223$ | $103529821$ | 
| Account #    | $127608$ | $4071701$ |

Assuming linearity, amplifier for 
- Block Number: $A_{B} = 103529821 / 4061223 \simeq 25.49$
- Account #   : $A_{S} = 4071701 / 127608 \simeq 31.91$ 

## Stat Estimation 

|   | Goerli | Mainnet |
|---|--------|---------|
| Blocks           | $4.6$ GB | $4.6 \times A_{B} \simeq 117.25$ GB  | 
| Receipts         | $3.7$ GB | $3.7 \times A_{B} \simeq 94.31$ GB   |
| Total Difficulty | $15$ MB  | $0.015 \times A_{B} \simeq  0.38$ GB |
| World State Trie | $1.4$ GB | $1.4 \times A_{S} \simeq 44.67$ GB   |
| DB in tar gz     | $7.6$ GB | $7.6 \times \max{(A_{B}, A_{S})} \simeq 242.52$ GB | 
| DB               | $7.7$ GB | $7.7 \times \max{(A_{B}, A_{S})} \simeq 245.71$ GB |
| New DB           | $14$ GB  | $14 \times \max{(A_{B}, A_{S})} \simeq 446.74$ GB |
| New DB in tar gz | $4.6$ GB | $4.6 \times \max{(A_{B}, A_{S})} \simeq 146.79$  GB |

## Storage Estimation 

$446.74$ GB when plain, $146.79$ GB when tarballed.

|   | Goerli | Mainnet |
|---|--------|---------|
| Storage Needed for Migration      | $43.6$ GB | $1338.37$ GB |
| New DB           | $14$ GB  | $446.74$ GB |
| New DB in tar gz | $4.6$ GB | $146.79$ GB |

## Time Estimation

Summation of estimation for [data export](#time-estimation-for-export) and [data import](#time-estimation-for-import).

(Export) $2.20$ h + (Import) $7.69$ h = $9.89$ h

## Time Estimation for Export

|   | Goerli | Mainnet |
|---|--------|---------|
| Export Blocks           | $94$ s   | $94 \times A_{B} \simeq 2396$ s |
| Export Total Difficulty | $82$ s   | $82 \times A_{B} \simeq 2090$ s | 
| Export Receipts         | $310$ s  | $310 \times A_{B} \simeq 7902$ s |
| Export State (jsonl)    | $205$ s  | $205 \times A_{S} \simeq 5225$ s |
| Total Time              | $691$ s  | $\Sigma = 17613$ s $\simeq 4.89$ h |

Parallelizable to reduce to $7902$ s $\simeq 2.20$ h.

## Time Estimation for Import

|   | Goerli | Mainnet |
|---|--------|---------|
| Import Blocks           | $198$ s  | $198 \times A_{B} \simeq 5047$ s |
| Import Total Difficulty | $36$ s   | $36  \times A_{B} \simeq 918$ s |
| Import Receipts         | $100$ s  | $100 \times A_{B} \simeq 2549$ s |
| Import State            | $220$ s  | $220 \times A_{S} \simeq 7021$ s |
| Recover Log Index       | $158$ s  | $158 \times A_{B} \simeq 4028$ s |
| Recover Senders         | $319$ s  | $319 \times A_{B} \simeq 8132$ s |
| Total Time              | $1031$ s | $\Sigma = 27695$ s $\simeq 7.69$ h |
