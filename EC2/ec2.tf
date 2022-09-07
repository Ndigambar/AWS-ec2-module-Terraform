resource "aws_security_group" "mysg" {
depends_on = [aws_vpc.myvpc, aws_subnet.mysubnet]
name        = "MySG for Master & Slave"
description = "Allow port no. 22"
vpc_id      = aws_vpc.myvpc.id

ingress {

description = "allow SSH"
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {

from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "My_SG"
}
}



resource "aws_instance" "Slave" {
depends_on = [aws_security_group.mysg]
count = 10
subnet_id = aws_subnet.mysubnet.id
ami           = "ami-0d2986f2e8c0f7d01"
instance_type = "t2.micro"
key_name = "testvm"
associate_public_ip_address = true
vpc_security_group_ids = [ aws_security_group.mysg.id ]
tags = {
Name = "Slave-${count.index + 1}"

}
}

resource "aws_instance" "Master" {
depends_on = [aws_security_group.mysg]
subnet_id = aws_subnet.mysubnet.id
ami           = "ami-0d2986f2e8c0f7d01"
associate_public_ip_address = true
instance_type = "t2.micro"
key_name = "testvm"
vpc_security_group_ids = [ aws_security_group.mysg.id ]
tags = {
Name = "Master"
}
}
/*
resource "local_file" "ipaddr" {
    
    content  = "[Master]\n${aws_instance.Master.public_ip}\n[Slave]\n${aws_instance.Slave[count.index]}\n"
    filename = "/home/deepaksaini/Inventory/inventory.txt"
}*/

/*
resource "local_file" "ipaddr" {
    count = length(tolist([aws_instance.Slave]))
    content  = "[Master]\n ${element(aws_instance.Slave.*.public_ip, count.index,)}\n"
    filename = "/home/deepaksaini/Inventory/inventory.txt"
}
*/



resource "local_file" "ipaddr" {
    
filename = "/home/deepaksaini/Inventory/inventory.txt"
content = <<-EOT
    [Master]
    ${aws_instance.Master.public_ip}
    [Slave]
    %{ for ip in aws_instance.Slave.*.public_ip ~}
    ${ip} 
    %{ endfor ~}
  EOT
}
