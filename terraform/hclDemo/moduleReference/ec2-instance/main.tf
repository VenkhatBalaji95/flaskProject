resource "aws_instance" "ubuntuInstance" {
	ami = "ami-006d3995d3a6b963b"
	availability_zone = "ap-south-1a"
	instance_type = "t2.micro"
	monitoring = false
	hibernation = false
	key_name = var.sshKeyName
	tags = {
		Name = "instance-terraform"
	}
	subnet_id = var.publicSubnetID
	vpc_security_group_ids = var.sgID

	connection {
	    type = "ssh"
	    host = self.public_ip
	    user = "ubuntu"
	    private_key = file("/home/ubuntu/terraform.pem")
    }

    provisioner "file" {
	    source      = "/home/ubuntu/terraform/ec2-instance/copy"
	    destination = "/home/ubuntu"
  	}

  	provisioner "remote-exec" {
  		inline = [
	      "chmod 777 /home/ubuntu/copy/test.sc",
	      "cd copy",
	      "./test.sc",
	    ]
  	}

  	provisioner "local-exec" {
	    command = "echo ${self.id} >> deletedInstanceList.txt"
	    when = destroy
	}
}
