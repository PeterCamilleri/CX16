@ECHO OFF
ECHO CX16 Rebuild

IF NOT EXIST lib  (md lib)
IF NOT EXIST temp (md temp)

ECHO ===================================
ECHO Rebuilding Standard CX16 Binaries

ca65 -o temp/sweet_16.o SW16/sweet_16.a65

IF EXIST lib\cx16.lib  (rm lib\cx16.lib)

ar65 r lib\cx16.lib temp/sweet_16.o

ECHO The library cx16.lib contains:
ar65 t lib\cx16.lib

ECHO ===================================
ECHO Rebuilding Simulator CX16 Binaries

ca65 -D sw16_sim_support -o temp/swim_16.o SW16/sweet_16.a65

IF EXIST lib\sim16.lib  (rm lib\sim16.lib)

ar65 r lib\sim16.lib temp/swim_16.o

ECHO The library sim16.lib contains:
ar65 t lib\sim16.lib
ECHO ===================================

del /Q temp\*.*
rd  /Q temp