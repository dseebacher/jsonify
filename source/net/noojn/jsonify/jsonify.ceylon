import ceylon.collection {
	ArrayList
}
import ceylon.json {
	JSONObject=Object,
	JSONArray=Array,
	parse,
	NullInstance,
	Value
}
import ceylon.language.meta {
	type,
	typeLiteral
}
import ceylon.language.meta.declaration {
	ValueDeclaration
}
import ceylon.language.meta.model {
	Class,
	ClassOrInterface,
	Type
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
			value obj = JSONObject();
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

//shared T? ceylonify<T>(String json)
//		given T satisfies Object {
//	value root = parse(json);
//	
//	value clazz = typeLiteral<T>();
//	if (is ClassOrInterface<T> clazz) {
//		value node = ceylonifyDo(root, clazz);
//		if (is T? node) {
//			return node;
//		}
//		throw Exception("E-1: expected type '``clazz``', but found '``type(node)``'");
//	}
//	throw Exception("Type ``clazz`` not a class or interface!"); //TODO: even possible!?
//}
//
//// TODO: handle special case if p is a container interface like class or map
//Anything ceylonifyDo(Value root, ClassOrInterface<Anything> clazz) {
//	print("a new round with class ``clazz`` begins!");
//	
//	switch (root)
//	case (is String|Integer|Float|Boolean) {
//print("C1: found ``type(root)``");
//		if (clazz.supertypeOf(type(root))) {
//			return root;
//		}
//		throw Exception("E0: not a valid type ``type(root)``");
//	}
//	case (is NullInstance) {
//		return null;
//	}
//	case (is JSONArray) {
//print("C2: found ``type(root)``");
//		value tmp = `interface Iterable`;
//		value t2 = typeLiteral<Iterable<Anything,Null>>();
//		assert (exists param = tmp.typeParameterDeclarations[0]);
//		assert (exists nodeType = clazz.typeArguments[param], is ClassOrInterface<Anything> nodeType);
//		if (clazz.subtypeOf(t2)) {
//			return root.map<Anything>((Value element) => ceylonifyDo(element, nodeType));
//			//value output = [];
//			//for(i in root){
//			//	assert(is nodeType o = ceylonifyDo(element, nodeType))
//			//output.append();
//			//}
//		}
//		throw Exception("JSON arrays can only be mapped to iterables!");
//	}
//	case (is JSONObject) {
//		if (is Class<Anything> clazz) {
//			variable [Anything*] param = [];
//			for (i->p in clazz.declaration.parameterDeclarations.indexed) {
//				if (exists v = root.get(p.name)) {
//					if (is JSONObject v) {
//						value pTypes = clazz.parameterTypes;
//						value pType = pTypes.get(i);
//						if (exists pType, is Class<Anything> pType) {
//							value node = ceylonifyDo(v, pType);
//							param = param.append([node]);
//						} else {
//							print("E1: nope :(");
//						}
//					} else {
//						param = param.append([v]);
//					}
//				} else {
//					throw Exception("No member '``p.name``' in JSON object!");
//				}
//			}
//			
//			value o = clazz.declaration.instantiate([], *param);
//			return o;
//		}
//		throw Exception("Can not create a instance of the interface ``clazz``!");
//	}
//	else {
//		throw Exception("expected type ``clazz.declaration.name`` not a ``type(root)``");
//	}
//}

shared T? ceylonify<T>(String json)
		given T satisfies Object {
	value root = parse(json);
	
	return ceylonifyNode<T>(root);
}

T? ceylonifyNode<T>(Value root)
		given T satisfies Object {
	switch (root)
	case (is String&T|Integer&T|Float&T|Boolean&T) {
		return root;
	}
	case (is NullInstance) {
		return null;
	}
	case (is JSONArray) {
		assert(is ClassOrInterface<T> clazz = typeLiteral<T>());
		value tmp = `interface Iterable`;
		value t2 = typeLiteral<Iterable<Anything,Null>>();
		assert (exists param = tmp.typeParameterDeclarations[0]);
		assert (exists nodeType = clazz.typeArguments[param], is ClassOrInterface<Anything> nodeType);
		if (clazz.subtypeOf(t2)) {
			value o = `function ceylonifyArray`.invoke([nodeType], root, nodeType);
			// TODO: check if nonempty iterables required and cast..
			assert (is T o);
			return o;
		}
		throw Exception("JSON arrays can only be mapped to iterables!");
	}
	case (is JSONObject) {
		value t = typeLiteral<T>();
		// TODO: handle special case if p is a container interface like map who are not json arrays/iterables
		if (is Class<T> t) {
			value c = t.declaration;
			variable [Anything*] param = [];
			for (i->p in c.parameterDeclarations.indexed) {
				
				if (exists v = root.get(p.name)) {
					if (is JSONObject v) {
						value pTypes = t.parameterTypes;
						value pType = pTypes.get(i);
						if (exists pType, is Type<Object> pType) {
							value node = `function ceylonifyNode`.invoke([pType], v);
							param = param.append([node]);
						}
					} else {
						param = param.append([v]);
					}
				} else {
					throw Exception("No member '``p.name``' in JSON object!");
				}
			}
			
			value o = c.instantiate([], *param);
			assert (is T o);
			return o;
		}
		throw Exception("Only classes as ceylon members allowed besides Iterables.");
	}
	else {
		throw Exception("Expected type '``type(`T`)``' , but found '``type(root)``'.");
	}
}


Iterable<T> ceylonifyArray<T>(JSONArray root, ClassOrInterface<Anything> nodeType) {
	value output = ArrayList<T>();	
	for(i in root){
		value oo = `function ceylonifyNode`.invoke([nodeType], i);
		assert (is T oo);
		output.add(oo);
	}
	return output;
}
