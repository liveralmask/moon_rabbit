require "moon_rabbit/version"

module MoonRabbit
  class Makefile
    attr_accessor   :files, :compiles, :links
    
    def initialize( &block )
      @files = {
        :path =>      "",
      }
      
      @compiles = {
        :compiler     => "",
        :main_target  => "",
        :srcs         => [],
        :obj_dir      => ".",
        :options      => [],
      }
      
      @links = {
        :static_libs  => [],
        :options      => [],
      }
      
      instance_eval( &block )
    end
    
    def add( makefile )
      makefile.files.each{|key, value|
        @files[ key ] = value
      }
      
      makefile.compiles.each{|key, value|
        if @compiles[ key ].instance_of?( String )
          @compiles[ key ] = value
        elsif @compiles[ key ].instance_of?( Array )
          @compiles[ key ].concat value
        end
      }
      
      makefile.links.each{|key, value|
        @links[ key ].concat value
      }
    end
    
    def path( path )
      @files[ :path ] = path
    end
    
    def compiler( compiler )
      @compiles[ :compiler ] = compiler
    end
    
    def main_target( main_target )
      @compiles[ :main_target ] = main_target
    end
    
    def src( src )
      @compiles[ :srcs ].push src
    end
    
    def srcs( srcs )
      srcs.each{|src|
        self.src src
      }
    end
    
    def obj_dir( obj_dir )
      @compiles[ :obj_dir ] = obj_dir
    end
    
    def compile_option( compile_option )
      @compiles[ :options ].push compile_option
    end
    
    def compile_options( compile_options )
      compile_options.each{|compile_option|
        self.compile_option compile_option
      }
    end
    
    def static_lib( static_lib )
      @links[ :static_libs ].push static_lib
    end
    
    def static_libs( static_libs )
      static_libs.each{|static_lib|
        self.static_lib static_lib
      }
    end
    
    def link_option( link_option )
      @links[ :options ].push link_option
    end
    
    def link_options( link_options )
      link_options.each{|link_option|
        self.link_option link_option
      }
    end
    
    def output
      objs = []
      deps = []
      @compiles[ :srcs ].each{|src|
        obj = "#{@compiles[ :obj_dir ]}/#{change_ext( src, '.o' )}"
        objs.push obj
        deps.push change_ext( obj, ".d" )
      }
      src_ext = File.extname( @compiles[ :srcs ].first )
      main_target_ext = File.extname( @compiles[ :main_target ] )
      
      open( @files[ :path ], "wb" ){|f|
        f.puts <<EOS
override COMPILER        += #{@compiles[ :compiler ]}
override COMPILE_OPTIONS += #{@compiles[ :options ].join( " " )}
override LINK_OPTIONS    += #{@links[ :options ].join( " " )}
override STATIC_LIBS     += #{@links[ :static_libs ].join( " " )}
RM                        = rm -f
MKDIR                     = mkdir -p
MAIN_TARGET               = #{@compiles[ :main_target ]}
SRCS                      = #{@compiles[ :srcs ].join( " " )}
OBJ_DIR                   = #{@compiles[ :obj_dir ]}
OBJS                      = #{objs.join( " " )}
DEPS                      = #{deps.join( " " )}

.PHONY: all clean

all: $(MAIN_TARGET)

clean:
	$(RM) $(MAIN_TARGET)
	$(RM) $(OBJS)
	$(RM) $(DEPS)

EOS
        
        f.puts <<EOS
$(OBJ_DIR)/%.o: %#{src_ext}
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(COMPILE_OPTIONS) -c $< -o $@
	
	@$(COMPILER) $(COMPILE_OPTIONS) -MM -MG -MP $< \\
		| sed "s/.*\\.o/$(subst /,\\/,$@) $(subst /,\\/,$(patsubst %.o,%.d,$@))/g" > $(patsubst %.o,%.d,$@); \\
		[ -s $(patsubst %.o,%.d,$@) ] || $(RM) $(patsubst %.o,%.d,$@)

-include $(DEPS)

EOS
        
        case main_target_ext
        when ".a"
          f.puts <<EOS
AR = ar r

$(MAIN_TARGET): $(OBJS)
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
    
    def change_ext( file_path, ext )
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
      @@makefiles.collect{|makefile| makefile.files[ :path ]}
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
