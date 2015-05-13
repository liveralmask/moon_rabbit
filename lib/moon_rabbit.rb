require "moon_rabbit/version"

module MoonRabbit
  class Makefile
    attr_accessor   :file_path, :compile, :link
    
    def initialize( file_path = nil, &block )
      @file_path = file_path
      
      @compile = {
        :compiler     => "",
        :main_target  => "",
        :srcs         => [],
        :obj_dir      => ".",
        :options      => [],
      }
      
      @link = {
        :static_libs  => [],
        :options      => [],
      }
      
      instance_eval( &block )
    end
    
    def add( makefile )
      makefile.compile.each{|key, value|
        if @compile[ key ].instance_of?( String )
          @compile[ key ] = value
        elsif @compile[ key ].instance_of?( Array )
          @compile[ key ].concat value
        end
      }
      
      makefile.link.each{|key, value|
        @link[ key ].concat value
      }
    end
    
    def compiler( compiler )
      @compile[ :compiler ] = compiler
    end
    
    def main_target( main_target )
      @compile[ :main_target ] = main_target
    end
    
    def src( src )
      @compile[ :srcs ].push src
    end
    
    def srcs( srcs )
      srcs.each{|src|
        self.src src
      }
    end
    
    def obj_dir( obj_dir )
      @compile[ :obj_dir ] = obj_dir
    end
    
    def compile_option( compile_option )
      @compile[ :options ].push compile_option
    end
    
    def compile_options( compile_options )
      compile_options.each{|compile_option|
        self.compile_option compile_option
      }
    end
    
    def static_lib( static_lib )
      @link[ :static_libs ].push static_lib
    end
    
    def static_libs( static_libs )
      static_libs.each{|static_lib|
        self.static_lib static_lib
      }
    end
    
    def link_option( link_option )
      @link[ :options ].push link_option
    end
    
    def link_options( link_options )
      link_options.each{|link_option|
        self.link_option link_option
      }
    end
    
    def output
      return if @file_path.nil?
      
      objs = []
      deps = []
      @compile[ :srcs ].each{|src|
        obj = "#{@compile[ :obj_dir ]}/#{sub_ext( src, '.o' )}"
        objs.push obj
        deps.push sub_ext( obj, ".d" )
      }
      src_ext = @compile[ :srcs ].empty? ? nil : File.extname( @compile[ :srcs ].first )
      main_target_ext = File.extname( @compile[ :main_target ] )
      
      open( @file_path, "wb" ){|f|
        f.puts <<EOS
COMPILER                  = #{@compile[ :compiler ]}
override COMPILE_OPTIONS += #{@compile[ :options ].join( " " )}
override LINK_OPTIONS    += #{@link[ :options ].join( " " )}
override STATIC_LIBS     += #{@link[ :static_libs ].join( " " )}
RM                        = rm -f
MKDIR                     = mkdir -p
MAIN_TARGET               = #{@compile[ :main_target ]}
SRCS                      = #{@compile[ :srcs ].join( " " )}
OBJ_DIR                   = #{@compile[ :obj_dir ]}
OBJS                      = #{objs.join( " " )}
DEPS                      = #{deps.join( " " )}

.PHONY: all obj clean

all: $(MAIN_TARGET)

obj: $(OBJS)

clean:
	$(RM) $(MAIN_TARGET)
	$(RM) $(OBJS)
	$(RM) $(DEPS)

EOS
        
        if ! src_ext.nil?
          f.puts <<EOS
$(OBJ_DIR)/%.o: %#{src_ext}
	@[ -e $(dir $@) ] || $(MKDIR) $(dir $@)
	
	$(COMPILER) $(COMPILE_OPTIONS) -c $< -o $@
	
	@$(COMPILER) $(COMPILE_OPTIONS) -MM -MG -MP $< \\
		| sed "s/.*\\.o/$(subst /,\\/,$@) $(subst /,\\/,$(patsubst %.o,%.d,$@))/g" > $(patsubst %.o,%.d,$@); \\
		[ -s $(patsubst %.o,%.d,$@) ] || $(RM) $(patsubst %.o,%.d,$@)

-include $(DEPS)

EOS
        end
        
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
  
  module PermanentProcess
    def self.watch( command, &block )
      begin
        pid = Process.spawn( command )
        
        Process.waitpid( pid )
      end while instance_exec( $?, &block )
    end
  end
end
