fileformat utf8
set compile_env: 0
category: 'accessing'
method: RwDefinitionSetDefinition
addDefinition: aDefinition

	definitions at: aDefinition key put: aDefinition
%
category: 'initialize-release'
method: STONWriter
jsonMode: boolean

	jsonMode := boolean.
	jsonMode
		ifTrue: [
			STONCharacters
				at: $' codePoint + 1 put: #pass;
				at: $" codePoint + 1 put: '\"' ]
		ifFalse: [
			STONCharacters
				at: $" codePoint + 1 put: #pass;
				at: $' codePoint + 1 put: '\''' ]
%
