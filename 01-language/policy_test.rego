package authz

input_0 = { "name": "fred" }
input_1 = { "name": "pebbles" }

test_allow_fred {
	allow with input as input_0
}

test_deny_pebbles {
	not allow with input as input_1
}
