# Note: May need to add a sleep 30 somehow. When building box completely
# in Packer, the wisdom was to have a 30 s sleep after the image was built,
# but before running the provisioners.

BOXES = rails-jade-16-04-mssql \
	rails-jade-18-04-mssql \
	rails-jade-16-04-pg \
	rails-jade-18-04-pg

all-vagrant-dev-boxes: $(BOXES)

rails-jade-16-04-mssql.box: template.json build.sh variables-16-04-mssql.json Vagrantfile.16.04.mssql
	packer build -force -var-file variables-16-04-mssql.json template.json

rails-jade-18-04-mssql.box: template.json build.sh variables-18-04-mssql.json Vagrantfile.18.04.mssql
	packer build -force -var-file variables-18-04-mssql.json template.json

rails-jade-16-04-pg.box: template.json build.sh variables-16-04-pg.json Vagrantfile.16.04.pg
	packer build -force -var-file variables-16-04-pg.json template.json

rails-jade-18-04-pg.box: template.json build.sh Vagrantfile.18.04.pg
	packer build -force template.json

vagrantfiles: Vagrantfile.18.04.pg Vagrantfile.16.04.pg Vagrantfile.18.04.mssql Vagrantfile.16.04.mssql

Vagrantfile.16.04.mssql: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template | \
		sed -e 's;vb.memory = "1024";vb.memory = "4096";' >$@

Vagrantfile.18.04.mssql: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template | \
		sed -e 's;vb.memory = "1024";vb.memory = "4096";' >$@

Vagrantfile.16.04.pg: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template >$@

Vagrantfile.18.04.pg: Vagrantfile.template Vagrantfile.header
	cat Vagrantfile.header Vagrantfile.template >$@

.PHONY: install
install: $(BOXES)

clean:
	rm Vagrantfile.[0-9][0-9].[0-9][0-9].* *.box
	
%: %.box
	vagrant box add $? --force --name $@
