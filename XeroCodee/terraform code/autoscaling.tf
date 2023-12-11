variable "keyName" {}

data "aws_ami" "linuxAMI"{
    most_recent = true
    owners = ["XXXXXXXXXXXX"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211129"]
    }
}

resource "aws_launch_configuration" "lc" {
    name_prefix = "${var.project}"
    image_id = data.aws_ami.linuxAMI.id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.sg.id]
    key_name = var.keyName
    lifecycle {
      create_before_destroy = true
    }
   user_data = <<EOF
#!/bin/bash
export HOME=/home/ubuntu
#echo "">log
sudo apt-get update                                   #update
sudo apt-get install python3                          #install python
#whereis python >> ~/log              
sudo apt-get install -y python3-pip                   #install pip
#whereis pip >> ~/log
sudo apt-get install -y mysql-client                     #install mysql client
#whereis mysql >> ~/log
sudo pip install PyMySQL                             #install pymysql
#whereis pip >> ~/log
sudo pip install flask                               #install flask
#whereis flask >> ~/log
sudo pip install boto3				                       #install boto3
#whereis boto3 >> ~/log
sudo apt install -y awscli                           #install awscli
pip3 install --upgrade awscli
#whereis awscli >> ~/log
sudo apt-get install -y nginx
sudo apt-get install -y gunicorn


#installing awscli
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

#git clone repository
mkdir ~/mock
git clone https://github.com/lokinegalur/mock ~/mock

#adding credentials to .aws/credentials file
# mkdir ~/.aws
# touch ~/.aws/credentials
# touch ~/.aws/config

# echo "[default]
# aws_access_key_id = XXXXXXXXXXXXXXXXXXXXXXXXXX
# aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# " | sudo tee    ~/.aws/credentials

# #adding configuration to .aws/config file
# echo "[default]
# s3 =
#     signature_version = s3v4
# region = ap-south-1" | sudo tee  ~/.aws/config

# touch ~/tf_key_pair.pem
# echo "-----BEGIN RSA PRIVATE KEY-----
#----------------------------------------------------
#RSA KEY
#
#----------------------------------------------------
# -----END RSA PRIVATE KEY-----" | sudo tee  ~/tf_key_pair.pem
# chmod 400 ~/tf_key_pair.pem
# chown ubuntu ~/*
EOF
/*echo "server{ 
              listen 80;
              server_name $(dig @resolver4.opendns.com myip.opendns.com +short);
              
              location / {
                      proxy_pass http://127.0.0.1:8000;          
                   }    

         }" | sudo tee /etc/nginx/sites-enabled/flaskapp
sudo service nginx restart
*/


}

resource "aws_autoscaling_group" "asg" {
  name                 = "asg-${var.project}"
  launch_configuration = aws_launch_configuration.lc.name
  #load_balancers = [ aws_lb.lb.id ]
  target_group_arns = [aws_lb_target_group.tg.arn]
  min_size             = 1
  max_size             = 2
  desired_capacity = 1
  vpc_zone_identifier = [aws_subnet.pubsub-1.id,aws_subnet.pubsub-2.id]
  lifecycle {
    create_before_destroy = true
  }

  
}


# Starup script for ec2
#!/bin/bash
#yum update -y
#yum install -y httpd.x86_64
#systemctl start httpd.service
#systemctl enable httpd.service
#echo “Hello World from $(hostname -f)” > /var/www/html/index.html
