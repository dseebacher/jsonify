import ceylon.json {
	JSONObject=Object,
	ObjectValue,
	JSONArray=Array
}
import ceylon.language.meta {
	type
}
import ceylon.language.meta.declaration {
	ValueDeclaration,
	ClassOrInterfaceDeclaration
}

import net.noojn.jsonify {
	JsonValueAnnotation
}

shared interface JsonProducer => ObjectValue(Anything);
shared interface JsonProducerMap => Map<ClassOrInterfaceDeclaration,JsonProducer>;

"Map a ceylon instance to a JSON string."
shared String jsonify(Anything root, JsonProducerMap producers = emptyMap) {
	switch (root)
	case (is String) {
		return "\"``root``\"";
	}
	else {
		return jsonifyValue(root, producers).string;
	}
}

ObjectValue jsonifyValue(Anything root, JsonProducerMap producers) {
	switch (root)
	case (is Null) {
		return "null";
	}
	case (is String|Integer|Float|Boolean) {
		return root;
	}
	else {
		if (is {Anything*} root) {
			return JSONArray(root.collect((Anything e) => jsonifyValue(e, producers)));
		}

		for (t in type(root).declaration.satisfiedTypes) {
			if (exists producer = producers.get(t.declaration)) {
				return producer(root);
			}
		}

		return JSONObject(type(root).declaration.memberDeclarations<ValueDeclaration>()
				.filter((ValueDeclaration e) => e.parameter).collect((ValueDeclaration e) {
					return (if (exists annotation = e.annotations<JsonValueAnnotation>().first, annotation.name != "") then annotation.name else e.name) -> jsonifyValue(e.memberGet(root), producers); }));
	}
}

shared ObjectValue stringProducer(Anything obj) {
	assert (is Object obj);
	return obj.string;
}
