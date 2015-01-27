require "moon_rabbit/version"

module MoonRabbit
  class Makefile
    def initialize( file_path = "Makefile", &block )
      @compile = {
        :tool         => "",
        :target       => "",
        :srcs         => [],
        :obj_dir      => ".",
        :inc_dirs     => [],
        :options      => [],
        :defines      => []
      }
      @link    = {
        :static_libs  => [],
        :shared_libs  => [],
        :options      => []
      }
      
      instance_eval( &block )
      
      output( file_path )
    end
    
    def compile( options )
      @compile.merge!( options )
      
      @compile[ :objs ] = []
      @compile[ :deps ] = []
      @compile[ :srcs ].each{|src|
        obj = "#{@compile[ :obj_dir ]}/#{sub_ext( src, '.o' )}"
        @compile[ :objs ].push obj
        @compile[ :deps ].push sub_ext( obj, ".d" )
      }
      @compile[ :src_ext ] = File.extname( @compile[ :srcs ].first )
      @compile[ :inc_dirs ].each{|inc_dir|
        @compile[ :options ].push "-I#{inc_dir}"
      }
      @compile[ :target_ext ] = File.extname( @compile[ :target ] )
    end
    
    def link( options )
      @link.merge!( options )
    end
    
    def output( file_path )
      open( file_path, "wb" ){|f|
        f.puts <<EOS
COMPILER        = #{@compile[ :tool ]}
COMPILE_OPTIONS = #{@compile[ :options ].join( " " )}
LINK_OPTIONS    = #{@link[ :shared_libs ].join( " " )}
RM              = rm -f
MKDIR           = mkdir -p
TARGET          = #{@compile[ :target ]}
SRCS            = #{@compile[ :srcs ].join( " " )}
OBJS            = #{@compile[ :objs ].join( " " )}
OBJ_DIR         = #{@compile[ :obj_dir ]}
STATIC_LIBS     = #{@link[ :static_libs ].join( " " )}
DEPS            = #{@compile[ :deps ].join( " " )}

.PHONY: all obj clean

all: $(TARGET)

obj: $(OBJS)

clean:
	$(RM) #{@compile[ :target ]} $(OBJS) $(DEPS)

$(OBJ_DIR)/%.o: %#{@compile[ :src_ext ]}
	[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(COMPILE_OPTIONS) -c $< -o $@
	
	$(COMPILER) $(COMPILE_OPTIONS) -MM -MG -MP $< \\
		| sed "s/.*\\.o/$(subst /,\\/,$@) $(subst /,\\/,$(patsubst %.o,%.d,$@))/g" > $(patsubst %.o,%.d,$@); \\
		[ -s $(patsubst %.o,%.d,$@) ] || $(RM) $(patsubst %.o,%.d,$@)

-include $(DEPS)

EOS
        
        case @compile[ :target_ext ]
        when ".a"
          f.puts <<EOS
AR  = ar r

$(TARGET): $(OBJS) $(STATIC_LIBS)
	$(AR) $@ $^
EOS
        else
          f.puts <<EOS
$(TARGET): $(OBJS) $(STATIC_LIBS)
	$(CC) $(LINK_OPTIONS) -o $@ $^
EOS
        end
      }
    end
    
protected
    def sub_ext( file_path, ext )
      file_path.sub( /\..+$/, ext )
    end
  end
end
