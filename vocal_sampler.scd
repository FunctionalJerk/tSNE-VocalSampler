{ SinOsc.ar * 0.2 ! 2 }.play

///////////////////////////////////////
////////// Initialisierung
//// - Das File "./data/vocalmap.json" muss einmalig
////   mithilfe des Codes "tsne2dict.scd" erzeugt werden.
//// - Audiodaten müssen sich in "./data/Wave",
////   csv-Dateien unter "../data/csv" befinden.

(
var yPosButt, play, switch, emot, expr, mix, speed;
var xSpec, ySpec, bounds, cols, list;
var nodes, playBus, synthBus, resynth;

var dict = File.use("data/vocalmap.json".resolveRelative, "r", {|x| x.readAllString.parseYAML });

var emotions = ["happiness", "sadness", "fear", "disgust", "anger", "surprise", "neutral", "undefined"];
var expressions = ["yes", "no", "question"];

/////////////////////////////////////////////
// SynthDef

playBus = Bus.audio(s, 2);
synthBus = Bus.audio(s, 2);

// Resynthese
SynthDef(\resynth, {|pan=0|

	var freq = \freq.kr(100, 0.02);
	var amp = \amp.kr(0.0, 0.05);
	var sel = \sel.kr(0.0, 0.02);

	Out.ar(synthBus,
		Pan2.ar(
			SelectX.ar(sel.linexp(0.275,1.0,0.001,0.04), [SinOsc.ar(freq), Pulse.ar(freq)] * 4).tanh
			* EnvGate.new
			* AmpCompA.kr(freq)
			* amp
			* 0.18,
			pan)
	)
}).add;

nodes = Array.newClear(dict.size);

resynth = {|index, pan|

	var node = Synth(\resynth, [\pan, pan]);
	var csv = dict.select{|x| x.at("index") == index.asString }.reduce.at("csv");
	csv = CSVFileReader.read(csv.standardizePath, startRow: 1);
	csv = csv.collect{|x| if(x[2]=="NA"){ [0.0, x[3].asFloat, x[4].asFloat] } { [x[2].asFloat, x[3].asFloat, x[4].asFloat] } };

	if(nodes[index].notNil) { nodes[index].release; nodes.put(index, nil) };
	nodes.put(index, node);

	{
		csv.do{|x|

			if(x[0] < 20) { node.set(\amp, 0.0) } {
				node.set(\freq, x[0], \amp, x[1], \sel, x[2]);
			};

			0.001.wait
		};
		node.set(\amp, 0);
		node.release;
		nodes.put(index, nil);

	}.fork
};

// Buffer Playback
SynthDef(\play, {|buf, pan=0|
	Out.ar(playBus, Pan2.ar(PlayBuf.ar(1, buf, doneAction: 2) * 0.4, pan) )
}).add;


// Mixer
SynthDef(\mix, {|mix = 0.0| Out.ar(0, FreeVerb.ar(SelectX.ar(mix, [playBus.ar, synthBus.ar]), 0.2, 0.3) * 0.6) } ).add;

/////////////////////
///// GUI

// Emotionen -> Farben
cols = Dictionary.newFrom([emotions, 8.collect{|x| Color.hsv((x+1) / 12 + 0.33, 0.5.rand + 0.3, 0.6)}.scramble].lace);

emot = [];
expr = [];

i = dict.size.rand;
yPosButt = 30;
play = 0;
switch = 0;
mix = 0.0;
speed = 1.0;

n = ControlSpec(1, dict.size, \linear, 1); // CS for starting point
g = ControlSpec(1, 10, \linear, 0.1, speed, "hz"); // CS for speed

// Window, Buttons & Sliders
w = Window.new("tSNE", Window.screenBounds.insetBy(1,8), resizable: false, border: false, scroll: true);
w.view.background_(Color.new255(60, 60, 60));

emotions[..3].do{|x,i|

	Button(w, Rect(30,yPosButt,80,80)).states_([
		[x, Color.grey, Color.clear],
		[x, Color.black, cols.at(x)]
	]).action_({|state|
		if(state.value.asBoolean) { emot = emot.add(x) } { emot.removeAt(emot.indexOfEqual(x)) }
	});
	yPosButt = yPosButt + 80;
};

yPosButt = 30;

emotions[4..].do{|x,i|

	Button(w, Rect(110,yPosButt,80,80)).states_([
		[x, Color.grey, Color.clear],
		[x, Color.black, cols.at(x)]
	]).action_({|state|
		if(state.value.asBoolean) { emot = emot.add(x) } { emot.removeAt(emot.indexOfEqual(x)) }
	});
	yPosButt = yPosButt + 80;
};

yPosButt = yPosButt + 30;

expressions.do{|x,i|

	Button(w, Rect(30,yPosButt,160,20)).states_([
		[x, Color.grey, Color.clear],
		[x, Color.black, Color.white]
	]).action_({ |state|
		if(state.value.asBoolean) { expr = expr.add(x) } { expr.removeAt(expr.indexOfEqual(x)) }
	});
	yPosButt = yPosButt + 30;
};

Button(w, Rect(30,yPosButt,160,20)).states_([
	["close", Color.black, Color.grey],
	["far", Color.black, Color.grey],
	["rand", Color.black, Color.grey]
]).action_({|state| switch = state.value });

yPosButt = yPosButt + 30;
StaticText(w, Rect(30,yPosButt,300,20)).string_("Vocal").stringColor_(Color.white);
StaticText(w, Rect(195,yPosButt,300,20)).string_("Synth").stringColor_(Color.white);

m = StaticText(w, Rect(116,yPosButt,40,20));
m.string_("0.00");
m.stringColor_(Color.white);
m.align_(\center);

yPosButt = yPosButt + 20;
c = Slider(w, Rect(30,yPosButt,200,20)).action_({ |val|
	val = val.value.round(0.01);
	m.string_(val.asString);
	mix.set(\mix, val);
});
// c.valueAction_(0.0);

yPosButt = yPosButt + 30;
StaticText(w, Rect(30,yPosButt,120,20)).string_("Speed: ").stringColor_(Color.white);
f = StaticText(w, Rect(200,yPosButt,40,20));
f.string_("1.0");
f.stringColor_(Color.white);
yPosButt = yPosButt + 20;
e = Slider(w, Rect(30,yPosButt,200,20)).value_(0.0).action_({|val|
	val = g.map(val.value).round(0.1);
	f.string_(val.asString);
	speed = val.value
});

yPosButt = yPosButt + 30;
StaticText(w, Rect(30,yPosButt,120,20)).string_("Starting Point: ").stringColor_(Color.white);
l = StaticText(w, Rect(200,yPosButt,40,20));
l.string_(i);
l.stringColor_(Color.white);
yPosButt = yPosButt + 20;
d = Slider(w, Rect(30,yPosButt,200,20)).value_(i / dict.size).action_({|val|
	val = n.map(val.value).asInteger;
	l.string_(val.asString);
	if( play.value.asBoolean.not ) { i = val - 1; };
});

yPosButt = yPosButt + 50;
p = Button(w, Rect(30,yPosButt,200,20)).states_([
	["Play", Color.white, Color.black],
	["Stop", Color.white, Color.red]
]).action_({|state|

	play = state.value;
	switch(play,
		0, { d.valueAction_(1.0.rand); },
		1, { list = []; }
	)
});

// draw
bounds = w.view.bounds;

xSpec = ControlSpec(bounds.width * 0.2, bounds.width * 0.9, \linear, 1); // CS for window x
ySpec = ControlSpec(bounds.height * 0.1, bounds.height * 0.8, \linear, 1); // CS for window y

s.waitForBoot({

	var point, pointA, pointB, selection, pan, entry, dist, coord, color;

	// Audio Mixer
	mix = Synth(\mix);

	//// Buffer
	dict.do{|x| Buffer.read(s, x.at("path").standardizePath, bufnum: x.at("index").asInteger) };

	w.front;

	////////////////////////////////////////////
	/////// Vocal-Sampler

	w.drawFunc = Routine{

		loop {

			entry = dict.select{|x| x.at("index").asInteger == i }.reduce;
			color = cols.at(entry.at("emotion"));
			pointA = entry.at("point").collect{|x| x.asFloat };
			pan = pointA[0].linlin(0.0,1.0,-1,1);

			coord = [
				xSpec.map(pointA[0]).asInteger,
				ySpec.map(pointA[1]).asInteger
			];

			// Liste der bisherigen Punkte
			list = list.add([i, coord, color]);

			// draw:
			list.do{|x|
				point = x[1];
				Pen.addOval(Rect(*point++10.dup));
				Pen.fillColor_(x[2]);
				Pen.draw;
			};

			// Übrige Auswahlmöglichkeiten für den nächsten Punkt
			selection = dict.select{|x|
				emot.indexOfEqual(x.at("emotion")).notNil &&
				(expr.indexOfEqual(x.at("expression")).notNil || emot.indexOfEqual(x.at("expression")).notNil)
			}.reject{|x|
				list.collect{|x| x[0] }.indexOfEqual(x.at("index").asInteger).notNil
			};

			if (
				(list.size <= dict.size)
				&& play.value.asBoolean
				&& (selection.size > 0)
				// && entry.notNil
			) {

				// Liste der Abstände (Vektoren) zu den anderen übrigen Punkten
				dist = selection.collect{|y,j|
					pointB = y.at("point").collect{|x| x.asFloat };
					[y.at("index").asInteger, (pointA - pointB).squared.sum.sqrt];
				}.sort{|a,b|
					a[1] < b[1]
				}.flop.at(0);

				// nähster-, weitester- oder zufälliger nächster Punkt
				switch(switch,
					0, { i = dist.at(0) },
					1, { i = dist.pop },
					2, { i = dist.choose }
				);
			} { p.valueAction_(0) };
			0.yield
		}
	};

	{ while { w.isClosed.not } {

		if ( play.value.asBoolean ) {
			resynth.(i, pan);
			Synth(\play, [\buf, i, \pan, pan]);
			w.refresh;
		};
		speed.reciprocal.wait

	} }.fork(AppClock);

})
)

// Ndef(\test, { Out.ar(0, FreeVerb.ar(synthBus.ar)) }).play

