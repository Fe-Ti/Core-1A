
## riscv-common.cc
Place the following into appropriate places in the file:
```c
  ...
  /* XKKMGOST extension */
  {"xkkmgost", ISA_SPEC_CLASS_NONE, 1, 0},
  ...
  
  /* XKKMGOST ext */
  RISCV_EXT_FLAG_ENTRY ("xkkmgost", x_target_flags, MASK_XKKMGOST),
```

riscv.opt
```
Mask(64BIT)

Mask(MUL)

Mask(ATOMIC)

Mask(HARD_FLOAT)

Mask(DOUBLE_FLOAT)

Mask(RVC)

Mask(RVE)

Mask(VECTOR)

Mask(FULL_V)

Mask(XKKMGOST)
```