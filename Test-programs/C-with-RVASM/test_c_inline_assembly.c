/// Test R-transform using extended GCC assembly
void
main () {
    long int half_block_h, half_block_l, 
        out_half_h, out_half_l;
    long int res_h, res_l;
    const long int checkup_1_h = 0x9400000000000000;
    const long int checkup_1_l = 0x0000000000000001;

    asm volatile (
        "kuznk64rfwd %[hbh_out], %[hbl_in], %[hbh_in]"
        "kuznkdblsrl %[hbl_out], %[hbl_in], %[hbh_in]"
        : [hbh_out] "=r" (half_block_h), [hbl_out] "=r" (half_block_l)
        : [hbh_in] "r" (out_half_h), [hbl_in] "r" (out_half_l)
    );
    res_h = checkup_1_h ^ out_half_h;
    res_h = checkup_1_l ^ out_half_l;
    return;
}