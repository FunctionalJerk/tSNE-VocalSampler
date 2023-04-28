(
// Im Folgenden werden die Einträge aus dem audiotsne.json
// mit den Ergebnissen meiner vorangegangenen Projekte zusammengeführt:

var tsne, exp, emot, point, path, wavePath, csvPath, emotions, expressions, who, index, symb;
var dict;
var csvFolder = PathName("../data/csv".resolveRelative);
var waveFolder = PathName("../data/Wave".resolveRelative);
var new = [];

tsne = File.use("data/audiotsne.json".resolveRelative, "r", {|x| x.readAllString.parseYAML });

emotions = ["happiness", "sadness", "fear", "disgust", "anger", "surprise", "neutral", "undefined"];
expressions = ["yes", "no", "question"];
expressions = (expressions ! 7).flatten.add("undefined");

tsne.do{|x,i|

	point = x.at("point").asFloat;
	path = PathName(x.at("path"));
	who = path.folderName;
	index = path.fileNameWithoutExtension.keep(-3).asInteger - 1;
	index = index.clip2(21);

	csvPath = PathName(csvFolder.fullPath +/+ who +/+ path.fileNameWithoutExtension ++ ".csv");
	wavePath = PathName(waveFolder.fullPath +/+ who +/+ path.fileName);

	exp = expressions.at(index);
	emot = emotions.at((index/3).asInteger); // roundDown-hack :)

	// s. Dokumentation:
	// Die einzelnen "Silben", die aus der Trennung mehrteiliger Ausdrücke entstanden sind,
	// besitzen seitdem keine (intendierte) Bedeutung mehr
	if(who=="XX") { exp = "undefined"; emot = "undefined" };
	if(who.size > 2) { who.pop };

	new = new.add(Dictionary.newFrom(
		[
			"point", point,
			"path", wavePath.fullPath,
			"emotion", emot,
			"expression", exp,
			"index", i,
			"csv", csvPath.fullPath
	]);
	)
};
dict = new;

// Mit den Ergänzungen dann ein neues json-file schreiben:
f = File.new("data/vocalmap.json".resolveRelative, "w");

k = dict[0].keys;

f.write("[");
dict.do{|x,i|
	f.write("{");

	k.do{|y,j|

		f.write("\"" ++ y.asString ++ "\": ");
		// Zahlen und Arrays werden nicht in Anführungszeichen gesetzt
		if( (y=="index") || (y=="point")) {
			f.write(x.at(y).asString);
			if(j < (k.size-1)) { f.write(", ") }
		} {
			f.write("\"" ++ x.at(y).asString ++ "\"");
			if(j < (k.size-1)) { f.write(", ") }
		}
	};

	f.write("}");

	if(i < (dict.size-1)) { f.write(", ") }
};
f.write("]");
f.close;
"done".postln
)

