require "moon_rabbit"
include MoonRabbit

common_makefile = Makefile.new{
  compiler       "gcc"
  obj_dir        "obj"
  compile_option "-g -Wall -O2"
}

Makefiles.add Makefile.new{
  add common_makefile

  path           "Makefile.libtest"
  main_target    "libtest.a"
  src            "libtest.c"
}

Makefiles.add Makefile.new{
  add common_makefile

  path           "Makefile.main"
  main_target    "main"
  src            "main.c"
  static_lib     "libtest.a"
}
