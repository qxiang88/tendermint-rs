----------------------------- MODULE MC_n5_f1 -------------------------------
CONSTANT Proposer \* the proposer function from 0..NRounds to 1..N

\* the variables declared in TendermintAcc3
VARIABLES
  round, step, decision, lockedValue, lockedRound, validValue, validRound,
  msgsPropose, msgsPrevote, msgsPrecommit, evidence

\* an operator for type annotations
a <: b == a

INSTANCE TendermintAccDebug3 WITH
  Corr <- {"c1", "c2", "c3", "c4"},
  Defective <- {} <: {STRING},
  Byzantine <- {"f5"},
  N <- 5,
  T <- 1,
  ValidValues <- { "v0", "v1" },
  InvalidValues <- {"v2"},
  MaxRound <- 2

\* run Apalache with --cinit=ConstInit
ConstInit == \* the proposer is arbitrary -- works for safety
  Proposer \in [Rounds -> AllProcs]

=============================================================================    
