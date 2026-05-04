# resource "aws_security_group" "bastion_sg" {
#   name        = "bastion-sg"
#   description = "Allow SSH to bastion"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "SSH from my IP"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["81.111.74.195/32"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "bastion-sg"
#   }
# }

resource "aws_instance" "bastion" {
  ami                         = "ami-0a94c8e4ca2674d5a"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnet_az1_id
  vpc_security_group_ids      = [module.security_groups.bastion_security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}