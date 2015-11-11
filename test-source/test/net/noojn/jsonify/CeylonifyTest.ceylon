import ceylon.json {
	JSONObject=Object,
	JSONArray=Array,
	ObjectValue
}
import ceylon.test {
	assertEquals,
	test
}
import ceylon.time {
	Instant,
	DateTime
}
import ceylon.time.iso8601 {
	parseDateTime
}
import ceylon.time.timezone {
	timeZone
}

import net.noojn.jsonify {
	ceylonify,
	JsonConsumerMap
}

shared class CeylonifyTest() {
	test
	shared void testCelonify_Null() {
		value json = "null";
		String? actual = ceylonify<String>(json);
		assert (is Null actual);
	}

	test
	shared void testCelonify_String() {
		value expected = "foo";
		value json = "\"``expected``\"";
		testEquals<String>(expected, json);
	}

	test
	shared void testCelonify_Integer() {
		value expected = 123456789;
		testEquals<Integer>(expected, expected.string);
	}

	test
	shared void testCelonify_Float() {
		value expected = 2.857;
		testEquals<Float>(expected, expected.string);
	}

	test
	shared void testCelonify_Boolean() {
		value expected = false;
		testEquals<Boolean>(expected, expected.string);
	}

	test
	shared void testCelonify_Object1() {
		value expected = TCSimpleClass("foo", "bar");
		value jo = JSONObject({ "b"->"foo", "c"->"bar" });
		testEquals<TCSimpleClass>(expected, jo.string);
	}

	test
	shared void testCelonify_ObjectNested() {
		value expected = TCClassAttribute(2048, TCSimpleClass("baz", "woo"));
		value jo = JSONObject({ "d"->2048, "e" -> JSONObject({ "b"->"baz", "c"->"woo" }) });
		testEquals<TCClassAttribute>(expected, jo.string);
	}

	test
	shared void testCelonify_Array() {
		value expected = { 1, 2, 3 };
		value jo = JSONArray({ 1, 2, 3 });
		testEquals<{Integer*}>(expected, jo.string);
	}

	test
	shared void testCelonify_NestedArray() {
		value expected = TCIterableAttribute(74.588, { "das", "haus", "vom", "niko-laus" });
		value jo = JSONObject({ "float"->74.588, "values" -> JSONArray({ "das", "haus", "vom", "niko-laus" }) });
		testEquals<TCIterableAttribute>(expected, jo.string);
	}

	test
	shared void testCelonify_Interface() {
		value expected = TCDateTimeAttribute(0.002, Instant(0).dateTime(timeZone.utc));
		value jo = JSONObject({ "float"->0.002, "date"->"1970-01-01T00:00:00.000" });
		testEquals<TCDateTimeAttribute>(expected, jo.string, map({ `DateTime`.declaration
							-> ((ObjectValue date) {
							assert (is String date);
							return parseDateTime(date);
						}) }));
	}

	test
	shared void testCelonify_IndividualName() {
		value expected = TCIndividualName("123");
		value jo = JSONObject({ "new_name" -> "123" });
		testEquals<TCIndividualName>(expected, jo.string);
	}

	//test shared void testCeylonify

	//*************************************************************//

	void testEquals<T>(T expected, String json, JsonConsumerMap consumers = emptyMap)
			given T satisfies Object {
		value actual = ceylonify<T>(json, consumers);
		assert (exists actual);
		if (is Iterable<Anything> actual, is Iterable<Anything> expected) {
			assertEquals(actual, expected, "iterables not equal!", compareIterables);
		} else {
			assertEquals(actual, expected);
		}
	}
}
