
(
var dict, emotions, cols, color, coord, point, xSpec, ySpec, bounds;

w = Window.new("plot", Window.screenBounds.insetBy(1,8), resizable: false, border: false, scroll: true);
w.view.background_(Color.new255(80, 80, 80));
bounds = w.view.bounds;
w.front;

dict = File.use("data/vocalmap.json".resolveRelative, "r", {|x| x.readAllString.parseYAML });

emotions = ["happiness", "sadness", "fear", "disgust", "anger", "surprise", "neutral", "undefined"];

cols = Dictionary.newFrom(
	[
		emotions.add("fragment"),
		8.collect{|x|
			Color.hsv((x+1) / 10 + 0.1, rrand(0.4,1.0), 0.8)
		}.scramble.add(
			Color.new255(255, 255, 255))
	].lace
);

xSpec = ControlSpec(bounds.width * 0.1, bounds.width * 0.9, \linear, 1); // CS for window x
ySpec = ControlSpec(bounds.height * 0.1, bounds.height * 0.9, \linear, 1); // CS for window y

w.drawFunc = Routine{
	dict.do{|x|
		color = cols.at(x["emotion"]);
		point = x["point"].asFloat;
		coord = [
			xSpec.map(point[0]).asInteger,
			ySpec.map(point[1]).asInteger
		];
		// [coord, color].postln
		Pen.addOval(Rect(*coord++10.dup));
		Pen.fillColor_(color);
		Pen.draw;
	};

};
)


//["l","p","x","i","n","m","c","f","e","d","w", "q"]