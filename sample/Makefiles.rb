require "moon_rabbit"
include MoonRabbit

Makefiles.add Makefile.new( "Makefile" ){
	compile_options = {
		:tool			=> "gcc",
		:target			=> "main",
		:srcs			=> [
			"src/main.c",
			"src/sub.c"
		],
		:obj_dir		=> "obj",
		:inc_dirs		=> [ "inc" ],
		:options		=> [ "-Wall" ]
	}
	compile( compile_options )
}
