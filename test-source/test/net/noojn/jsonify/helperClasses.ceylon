import ceylon.time {
	DateTime
}

import net.noojn.jsonify {
	jsonValue
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

class TCSimpleClass(
	shared String b,
	shared String c) {
	shared actual Boolean equals(Object that) {
		if (is TCSimpleClass that) {
			return b==that.b &&
					c==that.c;
		} else {
			return false;
		}
	}
	shared actual String string => "Class1 [b '``b``', c '``c``']";
}

class TCClassAttribute(
	jsonValue
	shared Integer d,
	shared TCSimpleClass e) {
	shared actual Boolean equals(Object that) {
		if (is TCClassAttribute that) {
			return d==that.d &&
					e==that.e;
		} else {
			return false;
		}
	}
	shared actual String string => "Class2 [d '``d``', e '``e``']";
}

class TCIterableAttribute(
	shared Float float,
	shared {String*} values) {
	shared actual Boolean equals(Object that) {
		if (is TCIterableAttribute that) {
			return float==that.float &&
					compareIterables(values, that.values);
		} else {
			return false;
		}
	}
	shared actual String string => "Class3 [float: '``float``', values: '``values``']";
}

class TCDateTimeAttribute(
	shared Float float,
	jsonValue
	shared DateTime date) {
	shared actual Boolean equals(Object that) {
		if (is TCDateTimeAttribute that) {
			return float==that.float &&
					date==that.date;
		} else {
			return false;
		}
	}
	shared actual String string => "Class4 [float: '``float``', date: '``date``']";
}

class TCIndividualName(
	jsonValue ("new_name")
	shared String name) {
	shared actual Boolean equals(Object that) {
		if (is TCIndividualName that) {
			return name == that.name;
		} else {
			return false;
		}
	}
	shared actual String string => "TCIndividualName [name: '``name``']";
}
