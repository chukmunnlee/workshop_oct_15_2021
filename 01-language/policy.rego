package authz

default allow = false 

allow {
	some i, j
		input.name = data.employees[i].name
		data.employees[i].reports_to = data.employees[j].name
		data.employees[j].grade = "manager"
}
