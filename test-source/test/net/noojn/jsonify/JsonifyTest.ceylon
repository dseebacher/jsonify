import ceylon.json {
	JSONObject=Object,
	JSONArray=Array
}
import ceylon.test {
	test,
	assertEquals
}
import ceylon.time {
	Instant,
	DateTime
}
import ceylon.time.timezone {
	timeZone
}

import net.noojn.jsonify {
	jsonify,
	stringProducer,
	mapProducer
}

shared class JsonifyTest() {
	test
	shared void testJsonify_Null() {
		value expected = "null";
		value obj = null;
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Integer() {
		value expected = "123";
		value obj = 123;
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Float() {
		value expected = "255.2112";
		value obj = 255.2112;
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Boolean() {
		value expected = "false";
		value obj = false;
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_String() {
		value expected = "\"foo bar\"";
		value obj = "foo bar";
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Object1() {
		value expected = JSONObject({ "b"->"foo", "c"->"bar" }).string;
		value obj = TCSimpleClass("foo", "bar");
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Nested() {
		value expected = JSONObject({ "d"->2048, "e" -> JSONObject({ "b"->"baz", "c"->"woo" }) }).string;
		value obj = TCClassAttribute(2048, TCSimpleClass("baz", "woo"));
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testCelonify_Array() {
		value expected = JSONArray({ 1, 2, 3 }).string;
		value obj = { 1, 2, 3 };
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testCelonify_NestedArray() {
		value expected = JSONObject({ "float"->74.588, "values" -> JSONArray({ "das", "haus", "vom", "niko-laus" }) }).string;
		value obj = TCIterableAttribute(74.588, { "das", "haus", "vom", "niko-laus" });
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_StringProducer() {
		value expected = "1970-01-01T00:00:00.000";
		value obj = Instant(0).dateTime(timeZone.utc);
		String? actual = jsonify(obj, map({ `DateTime`.declaration->stringProducer }));
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_IndividualName() {
		value expected = JSONObject({ "new_name"->"123" }).string;
		value obj = TCIndividualName("123");
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Map() {
		value expected = JSONObject({ "k1"->1, "k2"->2 }).string;
		Map<String,Integer> obj = map({ "k1"->1, "k2"->2 });
		String? actual = jsonify(obj, map({ `Map<Object>`.declaration->mapProducer }));
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_MapMixed() {
		value expected = JSONObject({ "k1"->"foo", "k2" -> JSONObject({ "b"->"baz", "c"->"woo" }) }).string;
		Map<String,String|TCSimpleClass> obj = map({ "k1"->"foo", "k2" -> TCSimpleClass("baz", "woo") });
		String? actual = jsonify(obj, map({ `Map<Object>`.declaration->mapProducer }));
		assertEquals(actual, expected);
	}
}
