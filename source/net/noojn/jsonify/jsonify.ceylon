import ceylon.json {
	JSONObject=Object,
	Value,
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

shared final annotation class JsonValueAnnotation()
		satisfies OptionalAnnotation<JsonValueAnnotation,ValueDeclaration> {}

shared annotation JsonValueAnnotation jsonValue() => JsonValueAnnotation();

"Map a ceylon instance to a JSON string."
shared String jsonify(Anything root, Map<ClassOrInterfaceDeclaration,JsonProducer> producers = emptyMap) {
	switch (root)
	case (is String) {
		return "\"``root``\"";
	}
	else {
		value r = jsonifyValue(root, producers);
		if (exists r) {
			return r.string;
		}
		return "null";
	}
}

Value jsonifyValue(Anything root, Map<ClassOrInterfaceDeclaration,JsonProducer> producers) {
	switch (root)
	case (is Null) {
		return null;
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
				return producer.produce(root);
			}
		}

		return JSONObject(type(root).declaration.annotatedMemberDeclarations<ValueDeclaration,JsonValueAnnotation>()
				.collect((ValueDeclaration e) => e.name -> jsonifyValue(e.memberGet(root), producers)));
	}
}

shared interface JsonProducer {
	shared formal ObjectValue produce(Object obj);
}

shared class StringProducer() satisfies JsonProducer {
	shared actual ObjectValue produce(Object obj) => obj.string;
}
