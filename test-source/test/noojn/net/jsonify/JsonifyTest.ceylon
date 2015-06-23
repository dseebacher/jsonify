import ceylon.test {
	test,
	assertEquals
}
import net.noojn.jsonify {
	jsonify
}
import ceylon.json {
	JSONObject=Object,
	JSONArray=Array
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
		value expected = JSONObject({ "d"->2048, "e"->JSONObject({ "b"->"baz", "c"->"woo" }) }).string;
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
		value expected = JSONObject({ "float"->74.588, "values"->JSONArray({ "das", "haus", "vom", "niko-laus" }) }).string;
		value obj = Class3(74.588, { "das", "haus", "vom", "niko-laus" });
		String? actual = jsonify(obj);
		assertEquals(actual, expected);
	}
}
