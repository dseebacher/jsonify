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
print("debug: ceylonify :``json``");
	return ceylonifyNode<T>(parse(json), consumers);
}

T? ceylonifyNode<T>(Value root, JsonConsumerMap consumers)
		given T satisfies Object {
print("debug: expect type ``typeLiteral<T>()``");
	switch (root)
	case (is Null) {
		return null;
	}
	case (is String&T|Integer&T|Float&T|Boolean&T) {
		return root;
	}
	case (is JSONArray) {
variable value c = typeLiteral<T>();
print("debug: array ``root``");
//	if(is IntersectionType<T> intersect = c ) {
//		assert (intersect.satisfiedTypes.size == 2);
//print("debug: intersect_0");
//
//		value cc = intersect.satisfiedTypes[0];
//		assert (is ClassOrInterface<T> cc);
//print("debug: intersect_1 ``cc``");
//		c = cc;
//print("debug: intersect_2");
//	}
//
//		assert (is ClassOrInterface<T> clazz = c);
		assert (is ClassOrInterface<T> clazz = c);
print("debug: array_c_1 ");
		//assert (exists param = `interface Iterable`.typeParameterDeclarations[0]);
//print("debug: array_c_2");
		assert (exists nodeType = clazz.typeArgumentList[0], is ClassOrInterface<Anything> nodeType);
print("debug: array_c_3, nodetype: ``nodeType``");

		value t2 = typeLiteral<Iterable<Anything,Null>>();
print("debug: array2, type literal: ``clazz``");
		if (clazz.subtypeOf(t2)) {
print("debug: array3");
//value o = ceylonifyArray(root, nodeType, consumers);
			value o = `function ceylonifyArray`.invoke([nodeType], root, nodeType, consumers);
			// TODO: check if nonempty iterables required and cast..
			assert (is T o);
print("debug: array4, result: ``o``");
			return o;
		}
		throw Exception("JSON arrays can only be mapped to iterables!");
	}
	case (is JSONObject) {
		value t = typeLiteral<T>();
print("debug: object ``root``, expect ``t``");
		// TODO: handle special case if p is a container interface like map and not a json arrays/iterables
		if (is Class<T> t) {
			value clazz = t.declaration;
			variable [Anything*] param = [];
			// TODO: clean up code...
			if (exists declaration = clazz.parameterDeclarations) {
				for (i->paramDeclaration in declaration.indexed) {
					if (is ValueDeclaration paramDeclaration) {
						if (exists jsonVal = root.get(paramDeclaration.name)) {
							CallableConstructor<T,Nothing>? defaultConstructor = t.defaultConstructor;
							if (exists defaultConstructor, exists paramType = defaultConstructor.parameterTypes.get(i)) {
								param = param.append([compileParam(paramType, jsonVal, consumers)]);
							}
						} else {
							if (!paramDeclaration.defaulted) {
								throw Exception("No member '``paramDeclaration.name``' in JSON object!");
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
print ("debug: ceyArr1");
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
