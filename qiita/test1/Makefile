override COMPILER        += gcc
override COMPILE_OPTIONS += -g -Wall -O2
override LINK_OPTIONS    += 
override STATIC_LIBS     += 
RM                        = rm -f
MKDIR                     = mkdir -p
MAIN_TARGET               = main
SRCS                      = main.c
OBJ_DIR                   = .
OBJS                      = ././main.o
DEPS                      = ././main.d

.PHONY: all clean

all: $(MAIN_TARGET)

clean:
	$(RM) $(MAIN_TARGET)
	$(RM) $(OBJS)
	$(RM) $(DEPS)

$(OBJ_DIR)/%.o: %.c
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(COMPILE_OPTIONS) -c $< -o $@
	
	@$(COMPILER) $(COMPILE_OPTIONS) -MM -MG -MP $< \
		| sed "s/.*\.o/$(subst /,\/,$@) $(subst /,\/,$(patsubst %.o,%.d,$@))/g" > $(patsubst %.o,%.d,$@); \
		[ -s $(patsubst %.o,%.d,$@) ] || $(RM) $(patsubst %.o,%.d,$@)

-include $(DEPS)

$(MAIN_TARGET): $(OBJS) $(STATIC_LIBS)
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(LINK_OPTIONS) -o $@ $^

