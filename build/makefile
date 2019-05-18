all-vagrant-dev-boxes: rails-jade-16-04-mssql.box \
	rails-jade-18-04-mssql.box \
	rails-jade-16-04-pg.box \
	rails-jade-18-04-pg.box

rails-jade-16-04-mssql.box: ubuntu-16-04/large/vm/rails-jade.ovf
	packer build -force -var-file variables-16-04-mssql.json template.db.json

rails-jade-18-04-mssql.box: ubuntu-18-04/large/vm/rails-jade.ovf
	packer build -force -var-file variables-18-04-mssql.json template.db.json

rails-jade-16-04-pg.box: ubuntu-16-04/small/vm/rails-jade.ovf
	packer build -force -var-file variables-16-04-pg.json template.db.json

rails-jade-18-04-pg.box: ubuntu-18-04/small/vm/rails-jade.ovf
	packer build -force template.db.json

all-bare-images: ubuntu-16-04/large/vm/rails-jade.ovf \
	ubuntu-16-04/small/vm/rails-jade.ovf \
	ubuntu-18-04/large/vm/rails-jade.ovf \
	ubuntu-18-04/small/vm/rails-jade.ovf

ubuntu-16-04/large/vm/rails-jade.ovf: ubuntu-16-04/large/variables.json template.json
	packer build -force -var-file ubuntu-16-04/large/variables.json template.json

ubuntu-16-04/small/vm/rails-jade.ovf: ubuntu-16-04/small/variables.json template.json
	packer build -force -var-file ubuntu-16-04/small/variables.json template.json

ubuntu-18-04/large/vm/rails-jade.ovf: ubuntu-18-04/large/variables.json template.json
	packer build -force -var-file ubuntu-18-04/large/variables.json template.json

ubuntu-18-04/small/vm/rails-jade.ovf: template.json
	packer build -force template.json
