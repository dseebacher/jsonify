import ceylon.collection {
	ArrayList
}
import ceylon.json {
	JSONObject=Object,
	parse,
	JSONArray=Array,
	Value,
	ObjectValue
}
import ceylon.language.meta {
	typeLiteral,
	type
}
import ceylon.language.meta.declaration {
	ValueDeclaration,
	ClassOrInterfaceDeclaration
}
import ceylon.language.meta.model {
	ClassOrInterface,
	Type,
	Class,
	CallableConstructor
}

shared interface JsonConsumer => Anything(ObjectValue);
shared interface JsonConsumerMap => Map<ClassOrInterfaceDeclaration,JsonConsumer>;

"Try to map a JSON string to a Ceylon type."
shared T? ceylonify<T>(String json, JsonConsumerMap consumers = emptyMap)
		given T satisfies Object {
	return ceylonifyNode<T>(parse(json), consumers);
}

T? ceylonifyNode<T>(Value root, JsonConsumerMap consumers)
		given T satisfies Object {
	switch (root)
	case (is Null) {
		return null;
	}
	case (is String&T|Integer&T|Float&T|Boolean&T) {
		return root;
	}
	case (is JSONArray) {
		assert (is ClassOrInterface<T> clazz = typeLiteral<T>());
		assert (exists param = `interface Iterable`.typeParameterDeclarations[0]);
		assert (exists nodeType = clazz.typeArguments[param], is ClassOrInterface<Anything> nodeType);

		value t2 = typeLiteral<Iterable<Anything,Null>>();
		if (clazz.subtypeOf(t2)) {
			value o = `function ceylonifyArray`.invoke([nodeType], root, nodeType, consumers);
			// TODO: check if nonempty iterables required and cast..
			assert (is T o);
			return o;
		}

		throw Exception("JSON arrays can only be mapped to iterables!");
	}
	case (is JSONObject) {
		value t = typeLiteral<T>();
		// TODO: handle special case if p is a container interface like map and not a json arrays/iterables
		if (is Class<T> t) {
			value clazz = t.declaration;
			variable [Anything*] param = [];
			// TODO: clean up code...
			if (exists declaration = clazz.parameterDeclarations) {
				for (i->paramDeclaration in declaration.indexed) {
					if (is ValueDeclaration paramDeclaration) {
						String name
								= if (exists annotation = paramDeclaration.annotations<JsonValueAnnotation>().first, annotation.name != "") then annotation.name else
							paramDeclaration.name;

						// get value
						if (exists jsonVal = root.get(name)) {
							CallableConstructor<T,Nothing>? defaultConstructor = t.defaultConstructor;
							if (exists defaultConstructor, exists paramType = defaultConstructor.parameterTypes.get(i)) {
								param = param.append([compileParam(paramType, jsonVal, consumers)]);
							}
							// got any default?
						} else {
							if (!paramDeclaration.defaulted) {
								throw Exception("No member '``name``' in JSON object!");
							}
						}
					}
				}
			}

			value o = clazz.instantiate([], *param);
			assert (is T o);
			return o;
		}
		throw Exception("Only classes as ceylon members allowed besides Iterables.");
	}
	else {
		throw Exception("Expected type '``type(`T`)``' , but found '``type(root)``'.");
	}
}

Iterable<T> ceylonifyArray<T>(JSONArray root, ClassOrInterface<Anything> nodeType, JsonConsumerMap consumers) {
	value output = ArrayList<T>();
	for (i in root) {
		value oo = `function ceylonifyNode`.invoke([nodeType], i, consumers);
		assert (is T oo);
		output.add(oo);
	}
	return output;
}

Anything compileParam(Type<Anything> paramType, ObjectValue val, JsonConsumerMap consumers) {
	if (is ClassOrInterface<Anything> paramType) {
		for (satType in paramType.satisfiedTypes.prepend([paramType])) {
			if (exists consumer = consumers.get(satType.declaration)) {
				return consumer(val);
			}
		}
	}

	return `function ceylonifyNode`.invoke([paramType], val, consumers);
}
