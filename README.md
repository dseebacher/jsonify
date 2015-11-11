A simple JSON library for ceylon.

This library is missing a lot of features compared to known projects in other languages, but it's usable .. at least sometimes (not on JS until 1.2.1).

Here is a simple example:
```ceylon
shared void run() {
	value obj = MyClass("author", 15);
	print(obj);

	value jsonObj = jsonify(obj);
	print(jsonObj);

	value newObj = ceylonify<MyClass>(jsonObj);
	print(newObj);
}

class MyClass(shared String name, jsonValue { name = "lvl"; } shared Integer age) {
	shared actual String string => "MyClass [name:'``name``', age:'``age``']";
}
```
and the output should look like this:
```
MyClass [name:'author', age:'15']
{"lvl":15,"name":"author"}
MyClass [name:'author', age:'15']
```


### Annotation

The `jsonValue` right now supports only `String name = ""` the key name used for the JSON member.


### JSONProducer & JSONConsumer

`JSONProducer` and `JSONConsumer` are functions used together with `jsonify()` and `ceylonify()` to read and write complex classes.

Here we use `JSONConsumerMap` an alias for `Map<ClassOrInterfaceDeclaration,JsonConsumer>`:

```ceylon
shared void run() {
	value json = "{ \"name\":\"foo\", \"date\":\"2015-11-11T11:11:00.000\" }";
	value obj = ceylonify<MyClass>(json, consumer);
	print(obj);
}

JsonConsumerMap consumer => map({ `DateTime`.declaration->consumeDateTime });

DateTime? consumeDateTime(ObjectValue date) {
	assert (is String date);
	return parseDateTime(date);
}

Map
class MyClass(
	shared String name,
	shared DateTime date) {
	shared actual String string => "MyClass [name:'``name``', date:'``date``']";
}
```
