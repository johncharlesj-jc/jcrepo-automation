
# Setup FSS on TestServer1

resource "null_resource" "TestServer1SharedFilesystem" {
  depends_on = [oci_core_instance.TestServer1, oci_file_storage_export.TestExport]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      host = ""
      #private_key = "file(/home/opc/.ssh/id_rsa)"
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '== Start of null_resource.TestServer1SharedFilesystem'",
      "sudo /bin/su -c \"yum install -y -q nfs-utils\"",
      "sudo /bin/su -c \"mkdir -p /sharedfs\"",
      "sudo /bin/su -c \"echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",
      "sudo /bin/su -c \"mount /sharedfs\"",
      "echo '== End of null_resource.TestServer1SharedFilesystem'"
    ]
  }

}


# Setup FSS on  using existing mount point

resource "null_resource" "server1SharedFilesystem" {
  depends_on = [oci_core_instance.server1, oci_file_storage_export.server1Export]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      host = data.oci_core_vnic.server1_VNIC1.private_ip_address
      #host = ""
      #private_key = "file(/home/opc/.ssh/id_rsa)"
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '== Start of null_resource.server1SharedFilesystem'",
      "sudo /bin/su -c \"yum install -y -q nfs-utils\"",
      "sudo /bin/su -c \"mkdir -p /fs\"",
      "sudo /bin/su -c \"echo '${local.mount_target_1_ip_address}:/fs /fs nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",
      "sudo /bin/su -c \"mount /fs\"",
      "echo '== End of null_resource.server1SharedFilesystem'"
    ]
  }

}



# Attachment of block volume to webtest1 in TEST_COMPUTE
resource "null_resource" "webtest1_oci_iscsi_attach" {
  depends_on = [oci_core_volume_attachment.webtest1BlockVolume_attach]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.webtest1_VNIC1.private_ip_address
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"

    }
    inline = ["sudo /bin/su -c \"rm -Rf /home/opc/iscsiattach.sh\""]
  }

  provisioner "file" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.webtest1_VNIC1.private_ip_address
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"

    }
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.webtest1_VNIC1.private_ip_address
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"

    }
    inline = ["sudo /bin/su -c \"chown root /home/opc/iscsiattach.sh\"",
      "sudo /bin/su -c \"chmod u+x /home/opc/iscsiattach.sh\"",
    "sudo /bin/su -c \"/home/opc/iscsiattach.sh\""]
  }

}




# Mount of attached block volume on TF-Prod1
resource "null_resource" "webtest1_oci_u01_fstab" {
  depends_on = [null_resource.webtest1_oci_iscsi_attach]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.webtest1_VNIC1.private_ip_address
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"

    }
    inline = ["echo '== Start of null_resource.webtest1_oci_u01_fstab'",
      "sudo -u root parted /dev/sdb --script -- mklabel gpt",
      "sudo -u root parted /dev/sdb --script -- mkpart primary ext4 0% 100%",
      "sudo -u root mkfs.ext4 -F /dev/sdb1",
      "sudo -u root mkdir /u01",
      "sudo -u root mount /dev/sdb1 /u01",
      "sudo /bin/su -c \"echo '/dev/sdb1              /u01  ext4    defaults,noatime,_netdev    0   0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.webtest1_oci_u01_fstab'",
    ]
  }

}



# Mount of volume group on webtest1
resource "null_resource" "webtest1_oci_VG_fstab" {
  depends_on = [null_resource.webtest1_oci_iscsi_attach]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.webtest1_VNIC1.private_ip_address
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"

    }
    inline = ["echo '== Start of null_resource.webtest1_oci_VG_fstab'",
      "sudo -u root pvcreate -v /dev/sdb",
      "sudo -u root vgcreate -v VGVhosts /dev/sdb",
      "sudo -u root lvcreate -v -L 180G -n LVmbc VGVhosts",
      "sudo -u root mkfs.ext4 -F /dev/VGVhosts/LVmbc",
      "sudo -u root mkdir /srv/webtest1",
      "sudo -u root mount /dev/VGVhosts/LVmbc /srv/webtest1",
      "sudo /bin/su -c \"echo '/dev/mapper/VGVhosts-LVmbc /srv/webtest1 ext4  defaults  0 0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.webtest1_oci_VG_fstab'",
    ]
  }

}



