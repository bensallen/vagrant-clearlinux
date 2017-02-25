Vagrant.configure(2) do |config|

  config.vm.define "clear" do |clear|

    clear.vm.box = "clear-linux-base"
    clear.vm.guest = :linux

    #clear.ssh.username = "vagrant"
    #clear.ssh.password = "vagrant"

    clear.vm.provider "virtualbox" do |vb|
      vb.name = 'ClearLinux'
      vb.cpus = 1
      vb.memory = 2048
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
      vb.customize ["modifyvm", :id, "--usb", "on"]
      vb.customize ["modifyvm", :id, "--usbxhci", "on"]
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
    end
  end

end
