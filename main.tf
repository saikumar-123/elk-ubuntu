provider "aws" {
  region  = "us-east-1"
 # access_key = "${var.aws_access_key}"
 # secret_key = "${var.aws_secret_key}"
  shared_credentials_file = "/home/sai.d/.aws/credentials"
  profile                 = "default"

}
/*data "template_file" "elk"{
  template = "${file("./elk-vars.json.tpl")}"
  vars = {
        server_ip = "${aws_instance.ansible-elk.private_ip}"
  }
}
resource "local_file" "elk-vars" {
  content = data.template_file.elk.rendered
  filename = "./elk-vars.json"
}
*/

resource "aws_instance" "ansible-elk" {
	ami = "ami-07ebfd5b3428b6f4d"
	instance_type = "t2.medium"
        key_name = "maagcpoc"
	subnet_id = "subnet-0de41be28e67725f4"
	iam_instance_profile = "ec2_role_for_maagc"
	root_block_device {
            volume_type= "standard"
            volume_size = "30"
          }
	tags = { Name = "Enabling-elk" }
	security_groups = "${compact(split(",", var.security_groups["security_groups"]))}"
        provisioner "local-exec" {
	   command = " echo 'server_ip: ${aws_instance.ansible-elk.private_ip}' > elk-vars.yml"
        }

	provisioner "local-exec" {
          command = "ansible-playbook --private-key=/home/sai.d/maagcpoc.pem -u ubuntu -i ${aws_instance.ansible-elk.private_ip}, playbook.yml --extra-vars '@elk-vars.yml'"
	}
}
