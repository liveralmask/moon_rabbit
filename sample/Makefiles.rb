require "moon_rabbit"
include MoonRabbit

Makefiles.add Makefile.new( "Makefile" ){
	compiler	"gcc"
	main_target	"main"
	srcs		[
		"src/main.c",
		"src/sub.c"
	]
	obj_dir		"obj"
	compile_option	"-Iinc -g -Wall -O2"
}
