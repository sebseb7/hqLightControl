#!/usr/bin/env coffee

midi = require 'midi'
ceiling = require './g3d2_output'

midi_input = new midi.input
midi_input.openPort 0
midi_input.ignoreTypes false, false, false

midi_out = new midi.output
midi_out.openPort 0


output = new ceiling.Output 'bender', 1341
output2 = new ceiling.Output 'bender', 1340

output2.on 'init' , (info) =>
	console.log info


output.on 'init',  (info) =>
	console.log info;

red = 0
green = 0
blue = 0
white = 0

midi_input.on 'message' , (deltaTime, message) =>

	console.log 'm:' + message + ' d:' + deltaTime
	
	if message[0] is 176
		if message[1] is 0
			red = message[2]
		if message[1] is 1
			green = message[2]
		if message[1] is 2
			blue = message[2]
		if message[1] is 3
			white = message[2]

	output.putCeiling 0,red*2,green*2,blue*2,white*2
	output2.setPixel 0xff,0xff,red*2,green*2,blue*2

