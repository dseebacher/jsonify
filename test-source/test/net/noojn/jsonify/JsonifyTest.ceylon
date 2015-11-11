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
	jsonValue
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
		value obj = Class1("foo", "bar");
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	test
	shared void testJsonify_Nested() {
		value expected = JSONObject({ "d"->2048, "e" -> JSONObject({ "b"->"baz", "c"->"woo" }) }).string;
		value obj = Class2(2048, Class1("baz", "woo"));
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
		value obj = Class3(74.588, { "das", "haus", "vom", "niko-laus" });
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
	shared void testJsonify_individualName() {
		value expected = JSONObject({ "new_name"->"123" }).string;
		value obj = Class4("123");
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}

	//*************************************************************//

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
		jsonValue ("new_name")
		shared String name) {}
}
