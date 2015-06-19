import ceylon.language.meta.declaration {
	ValueDeclaration
}
import ceylon.language.meta {
	type
}
import ceylon.json {
	Object
}

shared final annotation class JsonValueAnnotation()
		satisfies OptionalAnnotation<JsonValueAnnotation,ValueDeclaration> {}

shared annotation JsonValueAnnotation jsonValue() => JsonValueAnnotation();

shared String jsonify(Anything root) {
	switch (root)
	case (is String) {
		return root;
	}
	case (is Integer|Float) {
		return root.string;
	}
	else {
		if (exists root) {
			value obj = Object();
			value member = type(root).declaration.annotatedMemberDeclarations<ValueDeclaration,JsonValueAnnotation>();
			if (member.size == 0) {
				return root.string;
			}
			for (v in member) {
				
				value o = v.memberGet(root);
				if (exists o) {
				}
				
				obj.put(v.name, jsonify(v.memberGet(root)));
			}
			return obj.string;
		}
		return "";
	}
}
