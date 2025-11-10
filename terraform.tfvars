ami             = "ami-06e383b56033e3f71"
instance_type   = "t3.micro"
key_name        = "key2025"
aws_region      = "us-west-2"
security_groups = ["sg-0bbb30ae0506da736"]
instance_count  = 1
instance_names  = ["jenkins-master"]
slave_instance_names  = ["jenkins-slave1", "jenkins-slave2"]

