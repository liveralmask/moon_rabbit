# MoonRabbit

Briefly build scripts.

## Installation

Add this line to your application's Gemfile:

    gem 'moon_rabbit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moon_rabbit

## Usage

[Makefiles.rb]  

    MoonRabbit::Makefiles.add MoonRabbit::Makefile.new{
      path              "Makefile"
      compiler          "gcc"
      main_target       "main"
      srcs [
        "src/main.c",
        "src/sub.c"
      ]
      obj_dir           "obj"
      compile_option    "-Iinc -g -Wall -O2"
    }

[Rakefile]  

    require "moon_rabbit"
    require "moon_rabbit/Rakefile"
    require "./Makefiles"
    
    task :default => [ :build ]

[bash]  

    rake output # Output Makefile
    rake build  # Build Makefile
    
    ./main

## Contributing

1. Fork it ( http://github.com/liveralmask/moon_rabbit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
