all: rails-jade-16-04-mssql.box rails-jade-18-04-mssql.box rails-jade-16-04-pg.box rails-jade-18-04-pg.box

rails-jade-16-04-mssql.box: ubuntu-16-04-large/ubuntu-16-04-large.ovf
	packer build -force -var-file variables-16-04-mssql.json template.db.json

rails-jade-18-04-mssql.box: ubuntu-18-04-large/ubuntu-18-04-large.ovf
	packer build -force -var-file variables-18-04-mssql.json template.db.json

rails-jade-16-04-pg.box: ubuntu-16-04-small/ubuntu-16-04-small.ovf
	packer build -force -var-file variables-16-04-pg.json template.db.json

rails-jade-18-04-pg.box: ubuntu-18-04-small/ubuntu-18-04-small.ovf
	packer build -force template.db.json

ubuntu-16-04-large/ubuntu-16-04-large.ovf: variables-16-04-large.json template.json
	packer build -force -var-file variables-16-04-large.json template.json

ubuntu-18-04-large/ubuntu-18-04-large.ovf: variables-18-04-large.json template.json
	packer build -force -var-file variables-18-04-large.json template.json

ubuntu-16-04-small/ubuntu-16-04-small.ovf: variables-16-04-small.json template.json
	packer build -force -var-file variables-16-04-small.json template.json

ubuntu-18-04-small/ubuntu-18-04-small.ovf: template.json
	packer build -force template.json
