package main

# warn Cannot deploy to default namespace
warn[msg] {
	"default" == input.metadata.namespace 
	msg := sprintf("%s/%s is deploying to the default namespace", [ input.kind, input.metadata.name ])
}

warn[msg] {
	not input.metadata.namespace 
	msg := sprintf("%s/%s is deploying to the default namespace", [ input.kind, input.metadata.name ])
}

# warn Resources must be labelled
warn[msg] {
	not input.metadata.labels
	msg := sprintf("%s/%s do not have any labels", [ input.kind, input.metadata.name ])
}

# deny Cannot use :latest tag
deny[msg] {
	input.kind = "Deployment"
	some i
		c := input.spec.template.spec.containers[i]
		endswith(c.image, ":latest")
		msg := sprintf("%s/%s is using :latest tag", [ input.kind, c.name ])
}

# deny Cannot run as root
deny[msg] {
	input.kind = "Deployment"
	not input.spec.template.spec.securityContext.runAsNonRoot
		msg := sprintf("%s/%s is running as root", [ input.kind, input.metadata.name ])
}
