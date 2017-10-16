ifndef PETALINUX
$(error "Error: PETALINUX environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif

include apps.common.mk


all: build install

build: 


clean:

.PHONY: install image

install:
	$(TARGETINST) -d files/dropbear_rsa_host_key /etc/dropbear/dropbear_rsa_host_key
	$(TARGETINST) -d -p 0755 files/bd_shutdown /etc/init.d/bd_shutdown
	$(TARGETINST) -d -p 0755 files/bd_mount /etc/init.d/bd_mount
	$(TARGETINST) -d -p 0755 files/init_bus_module.sh /home/root/init_bus_module.sh
	$(TARGETINST) -d files/table_hub_update.sh /home/root/table_hub_update.sh
	$(TARGETINST) -d files/repo_version.h /home/root/repo_version.h
	$(TARGETINST) -s /etc/init.d/bd_mount /etc/rc5.d/S00bd_mount
	$(TARGETINST) -s /media/rootfs/bd_startup /etc/rc5.d/S99bd_startup
	$(TARGETINST) -s /etc/init.d/bd_shutdown /etc/rc6.d/S31bd_shutdown
	$(TARGETINST) -s /media/BOOT/interfaces /etc/network/interfaces


help:
	@echo ""
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE) and install to rootfs host copy"
	@echo "  build                  build subsystem"
	@echo "  install                install built objects to rootfs host copy"
