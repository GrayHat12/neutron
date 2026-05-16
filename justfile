default_asm_file := 'neutron.asm'
default_obj_file := 'build/neutron.obj'
default_out_file := 'build/neutron'

[default]
_list:
  @just --list

@compile asmfile=default_asm_file objfile=default_obj_file outfile=default_out_file:
    @nasm -g -felf64 {{asmfile}} -o {{objfile}} 
    @ld -o {{outfile}} {{objfile}}

@run asmfile=default_asm_file objfile=default_obj_file outfile=default_out_file: (compile asmfile objfile outfile)
    ./{{outfile}}; echo -e "\nexit-code="$?