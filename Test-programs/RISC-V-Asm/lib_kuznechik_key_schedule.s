Key_schedule_1:
    mv x31, x1
    li x17, 0x6ea276726c487ab8 # Load high part of C_1 into x17
    li x18, 0x5d27bd10dd849401 # Load low  part of C_1 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0xdc87ece4d890f4b3 # Load high part of C_2 into x17
    li x18, 0xba4eb92079cbeb02 # Load low  part of C_2 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0xb2259a96b4d88e0b # Load high part of C_3 into x17
    li x18, 0xe7690430a44f7f03 # Load low  part of C_3 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x7bcd1b0b73e32ba5 # Load high part of C_4 into x17
    li x18, 0xb79cb140f2551504 # Load low  part of C_4 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x156f6d791fab511d # Load high part of C_5 into x17
    li x18, 0xeabb0c502fd18105 # Load low  part of C_5 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0xa74af7efab73df16 # Load high part of C_6 into x17
    li x18, 0x0dd208608b9efe06 # Load low  part of C_6 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0xc9e8819dc73ba5ae # Load high part of C_7 into x17
    li x18, 0x50f5b570561a6a07 # Load low  part of C_7 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0xf6593616e6055689 # Load high part of C_8 into x17
    li x18, 0xadfba18027aa2a08 # Load low  part of C_8 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    mv x1, x31
    ret

Key_schedule_2:
    mv x31, x1
    li x17, 0x98fb40648a4d2c31 # Load high part of C_9 into x17
    li x18, 0xf0dc1c90fa2ebe09 # Load low  part of C_9 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x2adedaf23e95a23a # Load high part of C_10 into x17
    li x18, 0x17b518a05e61c10a # Load low  part of C_10 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x447cac8052ddd882 # Load high part of C_11 into x17
    li x18, 0x4a92a5b083e5550b # Load low  part of C_11 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x8d942d1d95e67d2c # Load high part of C_12 into x17
    li x18, 0x1a6710c0d5ff3f0c # Load low  part of C_12 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0xe3365b6ff9ae0794 # Load high part of C_13 into x17
    li x18, 0x4740add0087bab0d # Load low  part of C_13 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x5113c1f94d76899f # Load high part of C_14 into x17
    li x18, 0xa029a9e0ac34d40e # Load low  part of C_14 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x3fb1b78b213ef327 # Load high part of C_15 into x17
    li x18, 0xfd0e14f071b0400f # Load low  part of C_15 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x2fb26c2c0f0aacd1 # Load high part of C_16 into x17
    li x18, 0x993581c34e975410 # Load low  part of C_16 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    mv x1, x31
    ret

Key_schedule_3:
    mv x31, x1
    li x17, 0x41101a5e6342d669 # Load high part of C_17 into x17
    li x18, 0xc4123cd39313c011 # Load low  part of C_17 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0xf33580c8d79a5862 # Load high part of C_18 into x17
    li x18, 0x237b38e3375cbf12 # Load low  part of C_18 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x9d97f6babbd222da # Load high part of C_19 into x17
    li x18, 0x7e5c85f3ead82b13 # Load low  part of C_19 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x547f77277ce98774 # Load high part of C_20 into x17
    li x18, 0x2ea93083bcc24114 # Load low  part of C_20 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x3add015510a1fdcc # Load high part of C_21 into x17
    li x18, 0x738e8d936146d515 # Load low  part of C_21 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x88f89bc3a47973c7 # Load high part of C_22 into x17
    li x18, 0x94e789a3c509aa16 # Load low  part of C_22 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0xe65aedb1c831097f # Load high part of C_23 into x17
    li x18, 0xc9c034b3188d3e17 # Load low  part of C_23 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0xd9eb5a3ae90ffa58 # Load high part of C_24 into x17
    li x18, 0x34ce2043693d7e18 # Load low  part of C_24 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    mv x1, x31
    ret

Key_schedule_4:
    mv x31, x1
    li x17, 0xb7492c48854780e0 # Load high part of C_25 into x17
    li x18, 0x69e99d53b4b9ea19 # Load low  part of C_25 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x056cb6de319f0eeb # Load high part of C_26 into x17
    li x18, 0x8e80996310f6951a # Load low  part of C_26 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x6bcec0ac5dd77453 # Load high part of C_27 into x17
    li x18, 0xd3a72473cd72011b # Load low  part of C_27 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0xa22641319aecd1fd # Load high part of C_28 into x17
    li x18, 0x835291039b686b1c # Load low  part of C_28 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0xcc843743f6a4ab45 # Load high part of C_29 into x17
    li x18, 0xde752c1346ecff1d # Load low  part of C_29 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x7ea1add5427c254e # Load high part of C_30 into x17
    li x18, 0x391c2823e2a3801e # Load low  part of C_30 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    li x17, 0x1003dba72e345ff6 # Load high part of C_31 into x17
    li x18, 0x643b95333f27141f # Load low  part of C_31 into x18
    mv x15, x4
    mv x16, x5
    jal ra, LSX_K_a
    xor x6, x6, x15
    xor x7, x7, x16
    li x17, 0x5ea7d8581e149b61 # Load high part of C_32 into x17
    li x18, 0xf16ac1459ceda820 # Load low  part of C_32 into x18
    mv x15, x6
    mv x16, x7
    jal ra, LSX_K_a
    xor x4, x4, x15
    xor x5, x5, x16
    mv x1, x31
    ret

