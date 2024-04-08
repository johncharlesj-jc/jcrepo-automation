
variable "compartment_ocid" {}
variable "instance_availability_domain" {}
#variable "availablity_domain_name3" {}
#variable "shape_id" {}
variable "shape_name" {}
#variable "image_id" {}
variable "subnet_id" {}
variable "region" {}
variable "ssh_key_private" {}
variable "instance_image_ocid" {}
variable "instance_flex_ocpus" {}
variable "instance_flex_memory_in_gbs" {}
variable "boot_volume_size_in_gbs" {}
variable "blockvolume_size" {}
#variable "ssh_public_key" {}
#variable "assign_public_ip" {}
variable "MountTargetIPAddress" {}
variable "instance_variables" { type = map(string) }
variable "blockvolume_variables" { type = map(string) }

variable "instance_create_vnic_details_hostname_label" {}
variable "instance_create_vnic_details_skip_source_dest_check" {}
variable "volume_is_auto_tune_enabled" {}
#variable "instance_display_name" {}
#variable "instance_count" {}
#variable "vnic_name" {}
#variable "hostname_label" {}
#variable "private_ips" {}
#variable "skip_source_dest_check" {}
#variable "mount_target_id" {}


data "oci_core_shapes" "current_ad" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.instance_availability_domain
}

data "oci_core_volume_backup_policies" "test_block_volume_backup_policies" {
  filter {
    name   = "display_name"
    values = ["gold"]
  }
}

##VNIC attachment of webpp
# Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "test_VNIC1_attach" {
  for_each = var.instance_variables
  #availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name") : var.availablity_domain_name2
  availability_domain = var.instance_availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.instance[each.key].id
}


# Compute VNIC DataSource
data "oci_core_vnic" "test_VNIC1" {
  for_each = var.instance_variables
  vnic_id  = data.oci_core_vnic_attachments.test_VNIC1_attach[each.key].vnic_attachments.0.vnic_id
}


locals {
  shapes_config = {
    // prepare data with default values for flex shapes. Used to populate shape_config block with default values
    // Iterate through data.oci_core_shapes.current_ad.shapes (this exclude duplicate data in multi-ad regions) and create a map { name = { memory_in_gbs = "xx"; ocpus = "xx" } }
    for i in data.oci_core_shapes.current_ad.shapes : i.name => {
      memory_in_gbs = i.memory_in_gbs
      ocpus         = i.ocpus
    }
  }
  shape_is_flex = length(regexall("^*.Flex", var.shape_name)) > 0 # evaluates to boolean true when var.shape contains .Flex
}


resource "oci_core_instance" "instance" {
  for_each = var.instance_variables
  #count = var.instance_count
  #availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name") : var.availablity_domain_name2
  availability_domain = var.instance_availability_domain
  compartment_id      = var.compartment_ocid
  #display_name        = var.instance_display_name == "" ? "" : var.instance_count != 1 ? "${var.instance_display_name}_${count.index + 1}" : var.instance_display_name
  #hostname_label = var.instance_hostname_label
  shape          = var.shape_name
  display_name   = each.key
  hostname_label = each.value
  #instance_flex_ocpus         = var.instance_flex_ocpus
  #instance_flex_memory_in_gbs = var.instance_flex_memory_in_gbs
  #source_id      = var.instance_image_ocid
  shape_config {
    // If shape name contains ".Flex" and instance_flex inputs are not null, use instance_flex inputs values for shape_config block
    // Else use values from data.oci_core_shapes.current_ad for var.shape
    memory_in_gbs = local.shape_is_flex == true && var.instance_flex_memory_in_gbs != null ? var.instance_flex_memory_in_gbs : local.shapes_config[var.shape_name]["memory_in_gbs"]
    ocpus         = local.shape_is_flex == true && var.instance_flex_ocpus != null ? var.instance_flex_ocpus : local.shapes_config[var.shape_name]["ocpus"]
    #baseline_ocpu_utilization = var.baseline_ocpu_utilization
  }

  metadata = {
    ssh_authorized_keys = file("/home/opc/.ssh/id_rsa.pub")
    #ssh_authorized_keys = "${var.ssh_public_key}"
    #ssh_authorized_keys = var.ssh_public_key
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
    #boot_volume_size_in_gbs = "100"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }


  create_vnic_details {
    #count        = var.instance_count
    subnet_id        = var.subnet_id
    display_name     = each.key
    hostname_label   = each.value
    assign_public_ip = false

  }
}




# 200 GB Block Volume for test
resource "oci_core_volume" "testBlockVolume" {
  for_each             = var.blockvolume_variables
  is_auto_tune_enabled = var.volume_is_auto_tune_enabled
  #availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name") : var.availablity_domain_name2
  availability_domain = var.instance_availability_domain
  compartment_id      = var.compartment_ocid
  #display_name = var.blockvolume1_display_name
  display_name = each.key
  #hostname_label = each.value
  #size_in_gbs         = "200"
  size_in_gbs = var.blockvolume_size

}

# Attachment of 200 GB Block Volume to test
resource "oci_core_volume_attachment" "testBlockVolume_attach" {
  for_each        = var.blockvolume_variables
  attachment_type = "iscsi"
  #device_name     = "/dev/oracleoci/oraclevdb"
  instance_id = oci_core_instance.instance[each.key].id
  volume_id   = oci_core_volume.testBlockVolume[each.key].id
}

## Adding backup policy for test
resource "oci_core_volume_backup_policy_assignment" "test_block_volume_backup_policy" {
  for_each  = var.blockvolume_variables
  asset_id  = oci_core_volume.testBlockVolume[each.key].id
  policy_id = data.oci_core_volume_backup_policies.test_block_volume_backup_policies.volume_backup_policies[0].id
}

# Attachment of block volume to test in TEST_COMPUTE
resource "null_resource" "test_oci_iscsi_attach" {
  for_each   = var.instance_variables
  depends_on = [oci_core_volume_attachment.testBlockVolume_attach]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.test_VNIC1[each.key].private_ip_address
      port = "22"
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      #script_path = "/home/opc/myssh.sh"
      agent   = false
      timeout = "10m"

    }
    inline = ["sudo /bin/su -c \"rm -Rf /home/opc/iscsiattach.sh\""]
  }

  provisioner "file" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.test_VNIC1[each.key].private_ip_address
      port = "22"
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      #script_path = "/home/opc/myssh.sh"
      agent   = false
      timeout = "10m"

    }
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.test_VNIC1[each.key].private_ip_address
      port = "22"
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      #script_path = "/home/opc/myssh.sh"
      agent   = false
      timeout = "10m"

    }
    inline = ["sudo /bin/su -c \"chown root /home/opc/iscsiattach.sh\"",
      "sudo /bin/su -c \"chmod u+x /home/opc/iscsiattach.sh\"",
    "sudo /bin/su -c \"/home/opc/iscsiattach.sh\""]
  }

}

# Mount of volume group on test
resource "null_resource" "test_oci_VG_fstab" {
  for_each   = var.instance_variables
  depends_on = [null_resource.test_oci_iscsi_attach]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host                = data.oci_core_vnic.Webserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.test_VNIC1[each.key].private_ip_address
      #private_key         = tls_private_key.public_private_key_pair.private_key_pem
      private_key = file(var.ssh_key_private)
      #script_path = "/home/opc/myssh.sh"
      agent   = false
      timeout = "10m"

    }
    inline = ["echo '== Start of null_resource.test_oci_VG_fstab'",
      "sudo -u root pvcreate -v /dev/sdb",
      "sudo -u root vgcreate -v VGVhosts /dev/sdb",
      "sudo -u root lvcreate -v -L 180G -n LVmbc VGVhosts",
      "sudo -u root mkfs.ext4 -F /dev/VGVhosts/LVmbc",
      "sudo -u root mkdir /srv/test1",
      "sudo -u root mount /dev/VGVhosts/LVmbc /srv/test1",
      "sudo /bin/su -c \"echo '/dev/mapper/VGVhosts-LVmbc /srv/test1 ext4  defaults  0 0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.test_oci_VG_fstab'",
    ]
  }

}







resource "oci_file_storage_mount_target" "testmounttarget" {
  #for_each     = var.webppmounttarget_variables
  #display_name = each.key
  #availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.GetAds.availability_domains[1], "name") : var.availablity_domain_name2
  #availability_domain = var.availablity_domain_name
  availability_domain = var.instance_availability_domain
  #availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id = var.compartment_ocid
  #subnet_id      = var.subnet_ocid
  subnet_id    = var.subnet_id
  ip_address   = var.MountTargetIPAddress
  display_name = "testmounttarget"
}



# Export Set

resource "oci_file_storage_export_set" "testExportset" {
  #count               = var.fss_count
  #for_each        = var.ppexportset_variables
  #display_name    = each.key
  mount_target_id = oci_file_storage_mount_target.testmounttarget.id
  #mount_target_id = var.mount_target_id
  #display_name   = var.fss_display_name == "" ? "" : var.fss_count != 1 ? "${var.fss_display_name}_${count.index + 1}" : var.fss_display_name
  display_name = "testExportset"
}



# FileSystem

resource "oci_file_storage_file_system" "testFilesystem" {
  #count               = var.fss_count
  #for_each = var.webppfilesystem_variables
  #availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.GetAds.availability_domains[1], "name") : var.availablity_domain_name2
  #availability_domain = var.availablity_domain_name3
  availability_domain = var.instance_availability_domain
  #availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id = var.compartment_ocid
  #display_name   = each.key
  #display_name   = var.fss_display_name == "" ? "" : var.fss_count != 1 ? "${var.fss_display_name}_${count.index + 1}" : var.fss_display_name
  display_name = "testFilesystem"
}

# Export

resource "oci_file_storage_export" "testExport" {
  #count               = var.fss_count
  #for_each = var.webppexportpath_variables
  #path     = each.key
  #export_set_id  = oci_file_storage_export_set.webppExportset[each.key].id
  export_set_id  = oci_file_storage_mount_target.testmounttarget.export_set_id
  file_system_id = oci_file_storage_file_system.testFilesystem.id
  path           = "/testfs"
}




# FSS Software provision to webpp

# Mount TEST_FSS on existing webpp instance
# Setup FSS on webpp using existing mount point

resource "null_resource" "testSharedFilesystem" {
  for_each   = var.instance_variables
  depends_on = [oci_core_instance.instance, oci_file_storage_export.testExport]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "opc"
      #host = data.oci_core_vnic.disneyemeaserver1_VNIC1.private_ip_address
      host = data.oci_core_vnic.test_VNIC1[each.key].private_ip_address
      #display_name   = each.key
      #hostname_label = each.value
      #host = "10.0.50.191"
      #private_key = "file(/home/opc/.ssh/id_rsa)"
      private_key = file(var.ssh_key_private)
      #script_path = "/home/opc/myssh.sh"
      agent   = false
      timeout = "10m"
    }
    inline = [
      "echo '== Start of null_resource.testSharedFilesystem'",
      "sudo /bin/su -c \"yum install -y -q nfs-utils\"",
      "sudo /bin/su -c \"mkdir -p /srv/dataexchangeshared\"",
      "sudo /bin/su -c \"echo '${var.MountTargetIPAddress}:/testfs /srv/dataexchangeshared nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",
      "sudo /bin/su -c \"mount /srv/dataexchangeshared\"",
      "echo '== End of null_resource.testSharedFilesystem'"
    ]
  }

}








