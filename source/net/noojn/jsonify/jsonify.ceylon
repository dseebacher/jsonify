import ceylon.json {
	JSONObject=Object,
	JSONArray=Array,
	Value,
	ObjectValue
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
	case (is Integer|Float|Boolean) {
		return root;
	}
	case (is Iterable<Anything>) {
		if (is String root) {
			return root;
		}
		value arr = JSONArray();
		for (e in root) {
			arr.add(jsonifyValue(e, producers));
		}
		return arr;
	}
	else {
		if (exists root) {
			value obj = JSONObject();

			for (t in type(root).declaration.satisfiedTypes) {
				if (exists producer = producers.get(t.declaration)) {
					return producer.produce(root);
				}
			}
			
			value member = type(root).declaration.annotatedMemberDeclarations<ValueDeclaration,JsonValueAnnotation>();
			for (v in member) {
				obj.put(v.name, jsonifyValue(v.memberGet(root), producers));
			}
			return obj;
		}
		return null;
	}
}

shared interface JsonProducer {
	shared formal ObjectValue produce(Object obj);
}

shared class StringProducer() satisfies JsonProducer {
	shared actual ObjectValue produce(Object obj) => obj.string;
}
