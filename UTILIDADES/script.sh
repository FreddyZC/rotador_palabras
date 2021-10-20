#!bin/bash

for filename in ./UTILIDADES/SEED_FILES/* ; do
    cp $filename ./
done

sed -i 's|parameter BUS_SIZE = 32|parameter BUS_SIZE = '$1'|g' testbench.v muxpar.v probador.v
sed -i 's|parameter WORD_SIZE = 4|parameter WORD_SIZE = '$2'|g' testbench.v muxpar.v probador.v
