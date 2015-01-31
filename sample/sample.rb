require "moon_rabbit"

include MoonRabbit

Makefile.new( "Makefile" ){
	compile_options = {
		:tool			=> "gcc",
		:target			=> "main",
		:srcs			=> [
			"src/main.c",
			"src/sub.c"
		],
		:obj_dir		=> "obj",
		:inc_dirs		=> [ "inc" ],
		:options		=> [ "-g -Wall -O2" ]
	}
	compile( compile_options )
	
	output
}
