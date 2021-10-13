package authz

default allow = false

# list of employees - can be passed 
employees = [ "fred", "barney", "betty", "wilma" ]

# Regular employees can expense < 300
allow {
	is_employee
	grade_type("regular")
	input.unitPrice * input.quantity <= input.expenseLimit
	input.unitPrice * input.quantity <= 500
}

# Leads can expense < 500
allow {
	is_employee
	grade_type("team-lead")
	input.unitPrice * input.quantity <= input.expenseLimit
}

deny["not_employee"] = m {
	not is_employee
	m := sprintf("%s is not an employee", [ input.name ])
}

deny["exceed_expense_limit"] = m {
	amount = input.unitPrice * input.quantity 
	amount > input.expenseLimit
	m := sprintf("$%d exceed expense limit of $%d", [ amount, input.expenseLimit ])
}

deny["exceed_grade_limit"] = m {
	grade_type("regular")
	amount = input.unitPrice * input.quantity 
	amount > 500
	m := sprintf("$%d exceed grade limit of $500", [ amount ])
}

is_employee {
	employees[_] = input.name
}

grade_type(type) {
	type = input.grade
}
