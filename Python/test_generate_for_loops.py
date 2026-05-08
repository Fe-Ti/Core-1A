# Copyright 2026 Fe-Ti
# REV8 and BREV8 blocks (byte and bit reversal)
# 'Generator for loop' idx correctness testing

import numpy as np

gv_rev8 = 0;

while True:
	if gv_rev8 >= 8:
		break
	print(f"assign rev8[{(gv_rev8+1)*8}, down 8 bits] to arg1[{(8-gv_rev8)*8}, down 8 bits];")
	# ~ assign rev8[(gv_rev8+1)*8 -: 8] = arg1[(8-gv_rev8)*8 -: 8];
	gv_brev8 = 0;
	while True:
		if gv_brev8 >= 8:
			break
		print(f"assign brev8[{(gv_rev8+1)*8 - gv_brev8}] = arg1[{(gv_rev8)*8 + gv_brev8 + 1}]")
		gv_brev8 += 1
	gv_rev8 += 1


