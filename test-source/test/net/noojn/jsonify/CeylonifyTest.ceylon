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
	jsonValue,
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
		value expected = Class1("foo", "bar");
		value jo = JSONObject({ "b"->"foo", "c"->"bar" });
		testEquals<Class1>(expected, jo.string);
	}

	test
	shared void testCelonify_ObjectNested() {
		value expected = Class2(2048, Class1("baz", "woo"));
		value jo = JSONObject({ "d"->2048, "e" -> JSONObject({ "b"->"baz", "c"->"woo" }) });
		testEquals<Class2>(expected, jo.string);
	}

	test
	shared void testCelonify_Array() {
		value expected = { 1, 2, 3 };
		value jo = JSONArray({ 1, 2, 3 });
		testEquals<{Integer*}>(expected, jo.string);
	}

	test
	shared void testCelonify_NestedArray() {
		value expected = Class3(74.588, { "das", "haus", "vom", "niko-laus" });
		value jo = JSONObject({ "float"->74.588, "values" -> JSONArray({ "das", "haus", "vom", "niko-laus" }) });
		testEquals<Class3>(expected, jo.string);
	}

	test
	shared void testCelonify_Interface() {
		value expected = Class4(0.002, Instant(0).dateTime(timeZone.utc));
		value jo = JSONObject({ "float"->0.002, "date" -> "1970-01-01T00:00:00.000" });
		testEqualsConsumer<Class4>(expected, jo.string, map({`DateTime`.declaration
			->((ObjectValue date){assert(is String date);return parseDateTime(date);})}));
	}

	void testEquals<T>(T expected, String json)
			given T satisfies Object {
		value actual = ceylonify<T>(json);
		assert (exists actual);
		if (is Iterable<Anything> actual, is Iterable<Anything> expected) {
			assertEquals(actual, expected, "iterables not equal!", compareIterables);
		} else {
			assertEquals(actual, expected);
		}
	}

	void testEqualsConsumer<T>(T expected, String json, JsonConsumerMap consumers)
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

Boolean compareIterables(Anything a, Anything b) {
	if (is Iterable<Anything> a, is Iterable<Anything> b) {
		if (a.size != b.size) {
			return false;
		}
		variable value va = a;
		variable value vb = a;
		while (exists aa = va.first, exists bb = vb.first) {
			if (aa != bb) {
				return false;
			}
			va = va.rest;
			vb = vb.rest;
		}
		return true;
	}
	return false;
}

class Class1(
	jsonValue
	shared String b,
	jsonValue
	shared String c) {
	shared actual Boolean equals(Object that) {
		if (is Class1 that) {
			return b==that.b &&
					c==that.c;
		} else {
			return false;
		}
	}
	shared actual String string => "Class1 [b '``b``', c '``c``']";
}

class Class2(
	jsonValue
	shared Integer d,
	jsonValue
	shared Class1 e) {
	shared actual Boolean equals(Object that) {
		if (is Class2 that) {
			return d==that.d &&
					e==that.e;
		} else {
			return false;
		}
	}
	shared actual String string => "Class2 [d '``d``', e '``e``']";
}

class Class3(
	jsonValue
	shared Float float,
	jsonValue
	shared {String*} values) {
	shared actual Boolean equals(Object that) {
		if (is Class3 that) {
			return float==that.float &&
					compareIterables(values, that.values);
		} else {
			return false;
		}
	}
	shared actual String string => "Class3 [float: '``float``', values: '``values``']";
}

class Class4(
	jsonValue
	shared Float float,
	jsonValue
	shared DateTime date) {
	shared actual Boolean equals(Object that) {
		if (is Class4 that) {
			return float==that.float &&
					date==that.date;
		} else {
			return false;
		}
	}
	shared actual String string => "Class4 [float: '``float``', date: '``date``']";
}
