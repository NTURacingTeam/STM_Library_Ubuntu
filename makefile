PROJNAME := STM_Library
CC := arm-none-eabi-gcc
SRC := $(wildcard src/*.c src/driver/*.c src/CMSIS/*.c)
START := startup/startup_stm32f10x_ld.s
NOD := $(notdir $(SRC)) #SRC w/o dir.
OBJ := $(patsubst %.c,bin/%.o,$(NOD)) $(patsubst %.s,bin/%.o,$(notdir $(START)))
STARTOBJ := $(START:startup/%.s=bin/%.o)
LINKER := linker/stm32_flash.ld
INC := -I include/ -I include/CMSIS/ -I include/driver
CFLAGS := -mthumb -mcpu=cortex-m3 -g -Wa,--warn
LINKFLAGS := -mthumb -mcpu=cortex-m3 -specs=nosys.specs -static -Wl,-cref,-u,Reset_Handler -Wl,-Map=test.map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group
PREPRO := -D STM32F10X_LD -D USE_STDPERIPH_DRIVER

prt:
	@echo $(OBJ)

all: $(OBJ)
	$(CC) $(PREPRO) -o bin/$(PROJNAME).elf $(OBJ) $(LINKFLAGS) -T $(LINKER)
	#$(CC) $(PREPRO) -o bin/$(PROJNAME).elf $(OBJ) $(LINKFLAGS)

bin/%.o: src/%.c
	$(CC) $(PREPRO) $(CFLAGS) $(INC) -c $< -o $@

bin/%.o: src/driver/%.c
	$(CC) $(PREPRO) $(CFLAGS) $(INC) -c $< -o $@

bin/%.o: src/CMSIS/%.c
	$(CC) $(PREPRO) $(CFLAGS) $(INC) -c $< -o $@

$(STARTOBJ): $(START)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm bin/*

flash: 
	openocd -f openocd.cfg -c init -c "reset halt" -c "flash write_image erase bin/$(PROJNAME).elf" -c "reset" -c "exit"
