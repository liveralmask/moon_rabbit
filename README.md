# MoonRabbit

Briefly build & process monitoring scripts.

## Installation

Add this line to your application's Gemfile:

    gem 'moon_rabbit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moon_rabbit

## Usage

[sample.rb]
    require "moon_rabbit"
    
    include MoonRabbit
    
    Makefile.new( "Makefile" ){
        compile_options = {
            :tool            => "gcc",
            :target          => "main",
            :srcs            => [
                "src/main.c",
                "src/sub.c"
            ],
            :obj_dir         => "obj",
            :inc_dirs        => [ "inc" ],
            :options         => [ "-g -Wall -O2" ]
        }
        compile( compile_options )
    }

[bash]
ruby sample.rb
make all
./main

## Contributing

1. Fork it ( http://github.com/<my-github-username>/moon_rabbit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
