xubuntu-16.04-amd64.json : xubuntu-16.04-amd64.yaml
	python3 -c 'import json, yaml; print(json.dumps(yaml.safe_load(open("xubuntu-16.04-amd64.yaml")), indent=4))' > xubuntu-16.04-amd64.json

all : xubuntu-16.04-amd64.json
	; # Do nothing
