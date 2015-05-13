require "moon_rabbit"
include MoonRabbit

count = 0
PermanentProcess.watch( "./process" ){|status|
	p status
	
	count = count + 1
	( count <= 3 )
}
