resource "aws_instance" "jenkins_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups
  count                  = var.instance_count
  user_data              = file("./userdata.sh")
  tags = {
    Name = var.instance_names[count.index]
  }

}
resource "aws_instance" "jenkins_instance_slave" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups
  count                  = var.instance_count
  user_data              = file("./slavesetup.sh")
  tags = {
    Name = var.slave_instance_names[count.index]
  }
  depends_on = [aws_instance.jenkins_instance]

}
#data "aws_availability_zones" "available" {
#  state = "available"
#}
#resource "aws_ebs_volume" "jenkins_volume" {
#  availability_zone = data.aws_availability_zones.available.names[0]
#  size              = 10
#  type              = "gp3"  # Using gp3 for better performance and cost
#  encrypted         = true    # Enable encryption for better security
#  tags = {
#  Name = "jenkins_volume"
#  }
#}
#
## Volume attachment (if you want to attach it to your Jenkins instance)
#resource "aws_volume_attachment" "jenkins_volume_attachment" {
#  device_name = "/dev/xvdf"
#  volume_id   = aws_ebs_volume.jenkins_volume.id
#  instance_id = aws_instance.jenkins_instance[0].id  # Attaching to the first instance (master)
#}