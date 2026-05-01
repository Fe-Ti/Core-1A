
## riscv-opc.c:
```c
/* GOST custom instructions.  */
{"kuznk32bssl", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNK32BSSL, MASK_KUZNK32BSSL, match_opcode, 0},
{"kuznk32bssr", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNK32BSSR, MASK_KUZNK32BSSR, match_opcode, 0},
{"kuznk32ellh", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNK32ELLH, MASK_KUZNK32ELLH, match_opcode, 0},
{"kuznk32elll", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNK32ELLL, MASK_KUZNK32ELLL, match_opcode, 0},
{"kuznk64rfwd", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNK64RFWD, MASK_KUZNK64RFWD, match_opcode, 0},
{"kuznk64rinv", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNK64RINV, MASK_KUZNK64RINV, match_opcode, 0},
{"kuznkdblsll", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNKDBLSLL, MASK_KUZNKDBLSLL, match_opcode, 0},
{"kuznkdblsrl", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_KUZNKDBLSRL, MASK_KUZNKDBLSRL, match_opcode, 0},
{"kuznksboxfwd", 0, INSN_CLASS_XKKMGOST, "d,s", MATCH_KUZNKSBOXFWD, MASK_KUZNKSBOXFWD, match_opcode, 0},
{"kuznksboxinv", 0, INSN_CLASS_XKKMGOST, "d,s", MATCH_KUZNKSBOXINV, MASK_KUZNKSBOXINV, match_opcode, 0},

{"magma32edf",  0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_MAGMA32EDF, MASK_MAGMA32EDF, match_opcode, 0},
{"magma64edrh", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_MAGMA64EDRH, MASK_MAGMA64EDRH, match_opcode, 0},
{"magma64edrl", 0, INSN_CLASS_XKKMGOST, "d,s,t", MATCH_MAGMA64EDRL, MASK_MAGMA64EDRL, match_opcode, 0},
```

## riscv.h:
Add to the enum:
```c
enum riscv_insn_class
{
	...
	INSN_CLASS_XKKMGOST
}
```



## riscv-opc.h:
Place in appropriate places this:
```c
/* GOST custom instruction for Kuznyechik and Magma */
#define MATCH_KUZNK32BSSL 0x4000100b
#define MASK_KUZNK32BSSL 0xfe00707f
#define MATCH_KUZNK32BSSR 0x100b
#define MASK_KUZNK32BSSR 0xfe00707f
#define MATCH_KUZNK32ELLH 0xb
#define MASK_KUZNK32ELLH 0xfe00707f
#define MATCH_KUZNK32ELLL 0x4000000b
#define MASK_KUZNK32ELLL 0xfe00707f
#define MATCH_KUZNK64RFWD 0xb
#define MASK_KUZNK64RFWD 0xfe00707f
#define MATCH_KUZNK64RINV 0x100b
#define MASK_KUZNK64RINV 0xfe00707f
#define MATCH_KUZNKDBLSLL 0x500b
#define MASK_KUZNKDBLSLL 0xfe00707f
#define MATCH_KUZNKDBLSRL 0x400b
#define MASK_KUZNKDBLSRL 0xfe00707f
#define MATCH_KUZNKSBOXFWD 0x200b
#define MASK_KUZNKSBOXFWD 0xfff0707f
#define MATCH_KUZNKSBOXINV 0x300b
#define MASK_KUZNKSBOXINV 0xfff0707f
#define MATCH_MAGMA32EDF 0x700b
#define MASK_MAGMA32EDF 0xfe00707f
#define MATCH_MAGMA64EDRH 0x4000700b
#define MASK_MAGMA64EDRH 0xfe00707f
#define MATCH_MAGMA64EDRL 0x700b
#define MASK_MAGMA64EDRL 0xfe00707f
```
And this:
```c
/* GOST custom instructions for Kuznyechik and Magma accel */
DECLARE_INSN(kuznk32bssl, MATCH_KUZNK32BSSL, MASK_KUZNK32BSSL)
DECLARE_INSN(kuznk32bssr, MATCH_KUZNK32BSSR, MASK_KUZNK32BSSR)
DECLARE_INSN(kuznk32ellh, MATCH_KUZNK32ELLH, MASK_KUZNK32ELLH)
DECLARE_INSN(kuznk32elll, MATCH_KUZNK32ELLL, MASK_KUZNK32ELLL)
DECLARE_INSN(kuznk64rfwd, MATCH_KUZNK64RFWD, MASK_KUZNK64RFWD)
DECLARE_INSN(kuznk64rinv, MATCH_KUZNK64RINV, MASK_KUZNK64RINV)
DECLARE_INSN(kuznkdblsll, MATCH_KUZNKDBLSLL, MASK_KUZNKDBLSLL)
DECLARE_INSN(kuznkdblsrl, MATCH_KUZNKDBLSRL, MASK_KUZNKDBLSRL)
DECLARE_INSN(kuznksboxfwd, MATCH_KUZNKSBOXFWD, MASK_KUZNKSBOXFWD)
DECLARE_INSN(kuznksboxinv, MATCH_KUZNKSBOXINV, MASK_KUZNKSBOXINV)
DECLARE_INSN(magma32edf, MATCH_MAGMA32EDF, MASK_MAGMA32EDF)
DECLARE_INSN(magma64edrh, MATCH_MAGMA64EDRH, MASK_MAGMA64EDRH)
DECLARE_INSN(magma64edrl, MATCH_MAGMA64EDRL, MASK_MAGMA64EDRL)
```


## elfxx-riscv.c
Add to struct:
```c
static const struct riscv_supported_ext riscv_supported_vendor_x_ext[] =
{
  ...
  {"xkkmgost",		ISA_SPEC_CLASS_DRAFT,	1, 0, 0 },
  ...
```

Add a case to switches in functions below:
```c
bool
riscv_multi_subset_supports (riscv_parse_subset_t *rps,
			     enum riscv_insn_class insn_class)
	...
    case INSN_CLASS_XKKMGOST:
      return riscv_subset_supports (rps, "xkkmgost");
	...
```

```c
const char *
riscv_multi_subset_supports_ext (riscv_parse_subset_t *rps,
				 enum riscv_insn_class insn_class)
	...
    case INSN_CLASS_XKKMGOST:
      return "xkkmgost";
	...
```

