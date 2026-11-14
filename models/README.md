\# models/



Trained model artifacts live here. \*\*Everything in this directory is gitignored\*\* —

models are large, derived artifacts and belong in S3, not git. This README is the

only committed file (see the `!models/README.md` exception in `.gitignore`).



\## Artifact contract



`model.rds` is a single R list written by `train.R`:



| Field | Type | Description |

|---|---|---|

| `model\_id` | character | `hybrid-YYYYMMDD-HHMMSS` |

| `created\_at` | POSIXct | Training timestamp |

| `cf$P` / `cf$Q` | matrix | User/item latent factors; serving = `P\[u,] %\*% t(Q)` |

| `content\_feats` | sparseMatrix | IDF-weighted, L2-normalized item vectors |

| `popularity` | numeric | Time-decayed popularity, aligned to `item\_index` |

| `train\_mat` | sparseMatrix | Training interactions (owned-item exclusion) |

| `user\_index` / `item\_index` | character | id ↔ row/col mapping |

| `weights` | list | Hybrid blend weights |

| `metrics` | list | Evaluation results vs popularity baseline |



We persist factor matrices, not the recosystem object: `Reco` holds a C++

pointer that does not survive `saveRDS()`.



\## Lifecycle



1\. `train.R` writes `models/model.rds` locally

2\. Uploads to `MODEL\_S3\_URI` (versioned bucket) if set

3\. Registers metrics in the `model\_registry` table

4\. API tasks download the artifact at container start



\*\*Promotion rule:\*\* only deploy a model whose NDCG@10 beats the popularity

baseline printed at the end of `train.R`.



\## Rollback



Point `MODEL\_S3\_URI` at the previous object version, then force a new ECS

deployment. The `model\_registry` table records which model\_id produced which metrics.

