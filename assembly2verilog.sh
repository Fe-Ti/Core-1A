#!/bin/bash
export USAGE="""\n
assembly2verilog.sh IFILE [OFILE] \n
When OFILE is ommited resulted files are placed where the script\n
is executed.\n
"""
source ./env

# export TOOLCHAIN_PREFIX="riscv64-linux-gnu-"
export TOOLCHAIN_PREFIX="riscv64-unknown-elf-"
export ASSEMBLER_EXEC="as"
export OBJCOPY_EXEC="objcopy"

export MARCH='-march=rv64i_xkkmgost'
#export ENDIANNESS="-mbig-endian"
export ENDIANNESS="-mlittle-endian"

export instruction_width=4 # 4 Bytes

export ifilename=$1
export ofilename=$2
export obj_filename=${ofilename}_objfile.out

if [ -z $ifilename ]; then
    echo -e $USAGE
    exit
fi

if [ -z $ofilename ]; then
    export ofilename=$(echo $ifilename | awk -F '/' '{ print $NF }'| awk -F. '{ print $(NF - 1) }')
    export obj_filename=$ofilename.out
    export ofilename=$ofilename.hex
fi

# echo $ifilename
# echo $obj_filename
# echo $ofilename
errors=0

echo "Assembling..."
$TOOLCHAIN_PREFIX$ASSEMBLER_EXEC $MARCH $ENDIANNESS -o $obj_filename $ifilename
errors=$(( $errors + $? ))
echo "Converting into verilog mem format ($instruction_width bytes width)..."
$TOOLCHAIN_PREFIX$OBJCOPY_EXEC --verilog-data-width $instruction_width -O verilog $obj_filename $ofilename
errors=$(( $errors + $? ))
if [[ $errors == "0" ]]; then
echo -e "\nCheck out:\nObject file --- $obj_filename\nMemory file --- $ofilename\n"
else
echo "Something went wrong!"
fi
