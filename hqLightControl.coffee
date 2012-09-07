#!/usr/bin/env coffee

midi = require 'midi'
ceiling = require './g3d2_output'

midi_input = new midi.input
midi_input.openPort 0
midi_input.ignoreTypes false, false, false

midi_out = new midi.output
midi_out.openPort 0

step = 0
steps = [43, 44, 42, 41, 45]
steps_rev = [3,2,0,1,4]


#initialize all leds

for num in [32..39].concat([48..55]).concat([64..71]).concat([41..46])
	midi_out.sendMessage [176,num,0]
	
#activate step 1
midi_out.sendMessage [176,43,127]


output = new ceiling.Output 'bender.hq.c3d2.de', 1341
output2 = new ceiling.Output 'bender.hq.c3d2.de', 1340

output.connected = 0
output2.connected = 0

output2.on 'init' , (info) =>
	console.log info
	output2.connected = 1


output.on 'init',  (info) =>
	console.log info;
	output.connected = 1

red = [0,0,0,0,0]
green = [0,0,0,0,0]
blue = [0,0,0,0,0]
white = [0,0,0,0,0]
cycle = 0
pause = 0
currentInterval = 100
activeIntervals = []


intervalStep =  ->
	if cycle and not pause
		for num in [41..45]
			midi_out.sendMessage [176,num,0]

		step++

		if step is 5
			step = 0

		midi_out.sendMessage [176,steps[step],127]
	
		if output.connected
			output.putCeiling 0,red[step]*2,green[step]*2,blue[step]*2,white[step]*2
		if output2.connected
			output2.setPixel 0xff,0xff,red[step]*2,green[step]*2,blue[step]*2
		
		for num in [0..7]
			if red[step] > num*18
				midi_out.sendMessage [176,32+num,127]
			else
				midi_out.sendMessage [176,32+num,0]
			
			if green[step] > num*18
				midi_out.sendMessage [176,48+num,127]
			else
				midi_out.sendMessage [176,48+num,0]
			
			if blue[step] > num*18
				midi_out.sendMessage [176,64+num,127]
			else
				midi_out.sendMessage [176,64+num,0]


	newArray = []
	for timerElement in activeIntervals

		console.log timerElement.interval
		if timerElement.interval isnt currentInterval
			console.log 'clear'
			clearInterval timerElement.timer
		else
			newArray.push(timerElement);
	activeIntervals = newArray;
	console.log '\n';

activeIntervals.push(timer:setInterval(intervalStep,currentInterval), interval:currentInterval)

midi_input.on 'message' , (deltaTime, message) =>

	console.log 'm:' + message + ' d:' + deltaTime

	if message[0] is 176

		# toggle using the cycle key
		if message[1] in steps
			if message[2] 
				for num in [41..45]
					midi_out.sendMessage [176,num,0]
				step = steps_rev[message[1]-41]
				midi_out.sendMessage [176,steps[step],127]
				pause = 1
			else
				pause = 0
		if message[1] is 46
			if message[2] is 0
				if cycle
					midi_out.sendMessage [176,46,0]
					cycle = 0
				else
					midi_out.sendMessage [176,46,127]
					cycle = 1

		#  sliders 1 to 4
		if message[1] is 0
			red[step] = message[2]
		if message[1] is 1
			green[step] = message[2]
		if message[1] is 2
			blue[step] = message[2]
		if message[1] is 3
			white[step] = message[2]
		
		if message[1] in [0,1,2,3,41,42,43,44,45]
			if output.connected
				output.putCeiling 0,red[step]*2,green[step]*2,blue[step]*2,white[step]*2
			if output2.connected
				output2.setPixel 0xff,0xff,red[step]*2,green[step]*2,blue[step]*2
			
		if message[1] is 23
			currentInterval = (message[2]+1)*30;
			
			activeIntervals.push(timer:setInterval(intervalStep,currentInterval), interval:currentInterval)

	
	for num in [0..7]
		if red[step] > num*18
			midi_out.sendMessage [176,32+num,127]
		else
			midi_out.sendMessage [176,32+num,0]
		
		if green[step] > num*18
			midi_out.sendMessage [176,48+num,127]
		else
			midi_out.sendMessage [176,48+num,0]
		
		if blue[step] > num*18
			midi_out.sendMessage [176,64+num,127]
		else
			midi_out.sendMessage [176,64+num,0]
	


	
