# Note: May need to add a sleep 30 somehow. When building box completely
# in Packer, the wisdom was to have a 30 s sleep after the image was built,
# but before running the provisioners.

all-vagrant-dev-boxes: rails-jade-16-04-mssql.box \
	rails-jade-18-04-mssql.box \
	rails-jade-16-04-pg.box \
	rails-jade-18-04-pg.box

rails-jade-16-04-mssql.box: template.dev.json build.sh variables-16-04-mssql.json Vagrantfile.16.04.mssql
	packer build -force -var-file variables-16-04-mssql.json template.dev.json

rails-jade-18-04-mssql.box: template.dev.json build.sh variables-18-04-mssql.json Vagrantfile.18.04.mssql
	packer build -force -var-file variables-18-04-mssql.json template.dev.json

rails-jade-16-04-pg.box: template.dev.json build.sh variables-16-04-pg.json Vagrantfile.16.04.pg
	packer build -force -var-file variables-16-04-pg.json template.dev.json

rails-jade-18-04-pg.box: template.dev.json build.sh Vagrantfile.18.04.pg
	packer build -force template.dev.json

vagrantfiles: Vagrantfile.18.04.pg Vagrantfile.16.04.pg Vagrantfile.18.04.mssql Vagrantfile.16.04.mssql

Vagrantfile.18.04.pg: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template | sed -e 's;config.vm.box = "BOX_NAME";config.vm.box = "jadesystems/rails-jade-18-04-pg";' >$@

Vagrantfile.16.04.pg: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template | sed -e 's;config.vm.box = "BOX_NAME";config.vm.box = "jadesystems/rails-jade-16-04-pg";' >$@

Vagrantfile.18.04.mssql: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template | sed -e 's;config.vm.box = "BOX_NAME";config.vm.box = "jadesystems/rails-jade-18-04-mssql";' >$@

Vagrantfile.16.04.mssql: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template | sed -e 's;config.vm.box = "BOX_NAME";config.vm.box = "jadesystems/rails-jade-16-04-mssql";' >$@

clean: Vagrantfile.18.04.pg \
	Vagrantfile.16.04.pg \
	Vagrantfile.18.04.mssql \
	Vagrantfile.16.04.mssql
	rm $?
	
