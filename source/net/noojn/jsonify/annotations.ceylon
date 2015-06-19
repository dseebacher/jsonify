import ceylon.language.meta.declaration {
	ValueDeclaration
}

shared final annotation class JsonValueAnnotation(shared String name)
		satisfies OptionalAnnotation<JsonValueAnnotation,ValueDeclaration> {}

shared annotation JsonValueAnnotation jsonValue(String name = "") => JsonValueAnnotation(name);
