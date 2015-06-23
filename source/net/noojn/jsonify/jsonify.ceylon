import ceylon.json {
	JSONObject=Object,
	JSONArray=Array,
	Value,
	nil
}
import ceylon.language.meta {
	type
}
import ceylon.language.meta.declaration {
	ValueDeclaration
}

shared final annotation class JsonValueAnnotation()
		satisfies OptionalAnnotation<JsonValueAnnotation,ValueDeclaration> {}

shared annotation JsonValueAnnotation jsonValue() => JsonValueAnnotation();

shared String jsonify(Anything root) {
	switch (root)
	//case (is String) {
	//	return "\"``root``\"";
	//}
	//case (is Integer|Float) {
	//	return root.string;
	//}
	//case (is Iterable<Anything>) {
	//	if (is String root) {
	//		return "\"``root``\"";
	//	}
	//	value arr = JSONArray();
	//	for(e in root) {
	//		arr.add(jsonifyValue(e));
	//	}
	//}
	//else {
	//	if (exists root) {
	//		return jsonifyValue(root).string;
	//	}
	//	return "null";
	//}
	case (is String) {
		return "\"``root``\"";
	}
	else {
		return jsonifyValue(root).string;
	}
}

Value jsonifyValue(Anything root) {
	switch (root)
	case (is Integer|Float) {
		return root;
	}
	case (is Iterable<Anything>) {
		if (is String root) {
			return root;
		}
		value arr = JSONArray();
		for (e in root) {
			arr.add(jsonifyValue(e));
		}
		return arr;
	}
	else {
		if (exists root) {
			value obj = JSONObject();
			value member = type(root).declaration.annotatedMemberDeclarations<ValueDeclaration,JsonValueAnnotation>();
			for (v in member) {
				obj.put(v.name, jsonifyValue(v.memberGet(root)));
			}
			return obj;
		}
		return nil;
	}
}
