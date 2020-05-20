# Configure the Packet Provider.
provider "packet" {
  auth_token = var.packet_api_token
}

# Declare your project ID
locals {
  project_id = var.project_id
}

# Create a new VLAN in datacenter "ewr1"
resource "packet_vlan" "provisioning-vlan" {
  description = "provisioning-vlan"
  facility    = "sjc1"
  project_id  = local.project_id
}

# Create a device and add it to tf_project_1
resource "packet_device" "tf-provisioner" {
  hostname         = "tf-provisioner"
  plan             = "c2.medium.x86"
  facilities       = ["sjc1"]
  operating_system = "ubuntu_18_04"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  network_type     = "hybrid"
}

# Create a device and add it to tf_project_1
resource "packet_device" "tf-controller" {
  hostname         = "tf-controller"
  plan             = "c2.medium.x86"
  facilities       = ["sjc1"]
  operating_system = "custom_ipxe"
  ipxe_script_url  = "https://boot.netboot.xyz"
  always_pxe       = "true"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  network_type     = "layer2-individual"
}


# Create a device and add it to tf_project_1
resource "packet_device" "tf-worker1" {
  hostname         = "tf-worker1"
  plan             = "c2.medium.x86"
  facilities       = ["sjc1"]
  operating_system = "custom_ipxe"
  ipxe_script_url  = "https://boot.netboot.xyz"
  always_pxe       = "true"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  network_type     = "layer2-individual"
}

# Create a device and add it to tf_project_1
resource "packet_device" "tf-worker2" {
  hostname         = "tf-worker2"
  plan             = "c2.medium.x86"
  facilities       = ["sjc1"]
  operating_system = "custom_ipxe"
  ipxe_script_url  = "https://boot.netboot.xyz"
  always_pxe       = "true"
  billing_cycle    = "hourly"
  project_id       = local.project_id
  network_type     = "layer2-individual"
}

# Attach VLAN to provisioner
resource "packet_port_vlan_attachment" "provisioner" {
  device_id = packet_device.tf-provisioner.id
  port_name = "eth1"
  vlan_vnid = packet_vlan.provisioning-vlan.vxlan
}

# Attach VLAN to worker
resource "packet_port_vlan_attachment" "controller" {
  device_id = packet_device.tf-controller.id
  port_name = "eth0"
  vlan_vnid = packet_vlan.provisioning-vlan.vxlan
}

# Attach VLAN to worker
resource "packet_port_vlan_attachment" "worker1" {
  device_id = packet_device.tf-worker1.id
  port_name = "eth0"
  vlan_vnid = packet_vlan.provisioning-vlan.vxlan
}

# Attach VLAN to worker
resource "packet_port_vlan_attachment" "worker2" {
  device_id = packet_device.tf-worker2.id
  port_name = "eth0"
  vlan_vnid = packet_vlan.provisioning-vlan.vxlan
}

output "provisioner_ip" {
  value = "${packet_device.tf-provisioner.network[0].address}"
}

output "controller_mac_addr" {
  value = "${packet_device.tf-controller.ports[1].mac}"
}

output "worker1_mac_addr" {
  value = "${packet_device.tf-worker1.ports[1].mac}"
}

output "worker2_mac_addr" {
  value = "${packet_device.tf-worker2.ports[1].mac}"
}
