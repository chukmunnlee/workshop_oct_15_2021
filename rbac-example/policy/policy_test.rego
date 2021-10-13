package authz

#employees = [
#	{ "name": "fred", "grade": "regular" },
#	{ "name": "barney", "grade": "regular" },
#	{ "name": "wilma", "grade": "team-lead", "reports": [ "fred", "barney" ] }
#]

po_0 = { 
	"name": "fred", 
	"grade": "regular",
	"unitPrice": 100,
	"quantity": 2,
	"expenseLimit": 300
}

po_1 = { 
	"name": "barney", 
	"grade": "regular",
	"unitPrice": 200,
	"quantity": 2,
	"expenseLimit": 400
}

po_2 = { 
	"name": "barney", 
	"grade": "regular",
	"unitPrice": 300,
	"quantity": 2,
	"expenseLimit": 700
}

po_3 = { 
	"name": "wilma", 
	"grade": "team-lead",
	"unitPrice": 200,
	"quantity": 3,
	"expenseLimit": 800
}

po_4 = {
	"name": "pebbles"
}

test_fred_regular_within_expense_limit {
	allow with input as po_0 
}

test_barney_regular_within_expense_limit {
	allow with input as po_1 
}

test_barney_regular_exceed_company_limit {
	not allow with input as po_2 
}

test_wilma_team_lean_within_expense_limit {
	allow with input as po_3 
}

test_pebbles_not_allowed {
	not allow with input as po_4 
}

