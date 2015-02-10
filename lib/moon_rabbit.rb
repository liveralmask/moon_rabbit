require "moon_rabbit/version"

module MoonRabbit
  class Makefile
    attr_accessor   :file_path
    
    def initialize( file_path = "Makefile", &block )
      @file_path = file_path
      
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
    end
    
    def compile( options )
      # options を汚染しない
      options.each{|key, value|
        @compile[ key ] = value.clone
      }
      
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
      @compile[ :defines ].each{|define|
        @compile[ :options ].push "-D#{define}"
      }
      @compile[ :target_ext ] = File.extname( @compile[ :target ] )
    end
    
    def link( options )
      # options を汚染しない
      options.each{|key, value|
        @link[ key ] = value.clone
      }
      
      @link[ :shared_libs ].each{|shared_lib|
        @link[ :options ].push "-l#{shared_lib}"
      }
    end
    
    def output( file_path = nil )
      file_path = @file_path if file_path.nil?
      
      open( file_path, "wb" ){|f|
        f.puts <<EOS
COMPILER                  = #{@compile[ :tool ]}
override COMPILE_OPTIONS += #{@compile[ :options ].join( " " )}
override LINK_OPTIONS    += #{@link[ :options ].join( " " )}
override STATIC_LIBS     += #{@link[ :static_libs ].join( " " )}
RM                        = rm -f
MKDIR                     = mkdir -p
MAIN_TARGET               = #{@compile[ :target ]}
SRCS                      = #{@compile[ :srcs ].join( " " )}
OBJ_DIR                   = #{@compile[ :obj_dir ]}
OBJS                      = #{@compile[ :objs ].join( " " )}
DEPS                      = #{@compile[ :deps ].join( " " )}

.PHONY: all obj clean

all: $(MAIN_TARGET)

obj: $(OBJS)

clean:
	$(RM) #{@compile[ :target ]}
	$(RM) $(OBJS)
	$(RM) $(DEPS)

$(OBJ_DIR)/%.o: %#{@compile[ :src_ext ]}
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(COMPILE_OPTIONS) -c $< -o $@
	
	@$(COMPILER) $(COMPILE_OPTIONS) -MM -MG -MP $< \\
		| sed "s/.*\\.o/$(subst /,\\/,$@) $(subst /,\\/,$(patsubst %.o,%.d,$@))/g" > $(patsubst %.o,%.d,$@); \\
		[ -s $(patsubst %.o,%.d,$@) ] || $(RM) $(patsubst %.o,%.d,$@)

-include $(DEPS)

EOS
        
        case @compile[ :target_ext ]
        when ".a"
          f.puts <<EOS
AR = ar r

$(MAIN_TARGET): $(OBJS) $(STATIC_LIBS)
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(AR) $@ $^

EOS
        else
          f.puts <<EOS
$(MAIN_TARGET): $(OBJS) $(STATIC_LIBS)
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(LINK_OPTIONS) -o $@ $^

EOS
        end
      }
    end
    
protected
    def sub_ext( file_path, ext )
      "#{File.dirname( file_path )}/#{File.basename( file_path, '.*' )}#{ext}"
    end
  end
  
  class Makefiles
    @@makefiles = []
    
    def self.add( makefile )
      @@makefiles.push makefile
    end
    
    def self.makefiles
      @@makefiles
    end
    
    def self.each
      @@makefiles.each{|makefile|
        yield( makefile )
      }
    end
    
    def self.file_paths
      @@makefiles.collect{|makefile| makefile.file_path}
    end
    
    def self.clear
      @@makefiles = []
    end
  end
  
  class Options
    @@options = {}
    
    def self.merge!( options )
      @@options.merge!( options ){|key, value1, value2| "#{value1} #{value2}"}
    end
    
    def self.to_s
      @@options.collect{|key, value| "#{key}='#{value}'"}.join( " " )
    end
  end
end
