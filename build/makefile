# Note: May need to add a sleep 30 somehow. When building box completely
# in Packer, the wisdom was to have a 30 s sleep after the image was built,
# but before running the provisioners.

all-vagrant-dev-boxes: rails-jade-16-04-mssql.box \
	rails-jade-18-04-mssql.box \
	rails-jade-16-04-pg.box \
	rails-jade-18-04-pg.box

rails-jade-16-04-mssql.box: ubuntu-16-04/large/vm/rails-jade-disk001.vmdk
	packer build -force -var-file variables-16-04-mssql.json template.db.json

rails-jade-18-04-mssql.box: ubuntu-18-04/large/vm/rails-jade-disk001.vmdk
	packer build -force -var-file variables-18-04-mssql.json template.db.json

rails-jade-16-04-pg.box: ubuntu-16-04/small/vm/rails-jade-disk001.vmdk build.sh
	packer build -force -var-file variables-16-04-pg.json template.db.json

rails-jade-18-04-pg.box: ubuntu-18-04/small/vm/rails-jade-disk001.vmdk build.sh
	packer build -force template.db.json

all-bare-images: ubuntu-16-04/large/vm/rails-jade-disk001.vmdk \
	ubuntu-16-04/small/vm/rails-jade-disk001.vmdk \
	ubuntu-18-04/large/vm/rails-jade-disk001.vmdk \
	ubuntu-18-04/small/vm/rails-jade-disk001.vmdk

ubuntu-16-04/large/vm/rails-jade-disk001.vmdk: ubuntu-16-04/large/variables.json template.json
	packer build -force -var-file ubuntu-16-04/large/variables.json template.json

ubuntu-16-04/small/vm/rails-jade-disk001.vmdk: ubuntu-16-04/small/variables.json template.json
	packer build -force -var-file ubuntu-16-04/small/variables.json template.json

ubuntu-18-04/large/vm/rails-jade-disk001.vmdk: ubuntu-18-04/large/variables.json template.json
	packer build -force -var-file ubuntu-18-04/large/variables.json template.json

ubuntu-18-04/small/vm/rails-jade-disk001.vmdk: template.json
	packer build -force template.json

clean:
	rm -r ubuntu-18-04/small/vm
	
