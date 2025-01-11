
# EC2 Instances for Blue, Green, and Yellow pages
resource "aws_instance" "color_instances" {
  count           = 3
  ami             = "ami-0ca9fb66e076a6e32" # Amazon Linux 2 (replace with your region's AMI)
  instance_type   = "t2.micro"
  subnet_id       = element(var.private-subnets, count.index % length(var.private-subnets))
  security_groups = [aws_security_group.instance_sg.id]
  key_name        = "terraform"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              yum install -y net-tools
              PRIVATE_IP=`ifconfig | grep 'inet ' | awk '{print $2}' | head -n 1`

              INSTANCE_INDEX=${count.index}
              if [ "$INSTANCE_INDEX" -eq 0 ]; then
                COLOR="blue"
                GRADIENT="to right, #0000FF, #00FFFF"
              elif [ "$INSTANCE_INDEX" -eq 1 ]; then
                COLOR="green"
                GRADIENT="to right, #00FF00, #008000"
              else
                COLOR="yellow"
                GRADIENT="to right, #FFFF00, #FFD700"
              fi

              echo "<html>
                      <head>
                        <style>
                          body {
                            background: linear-gradient($${GRADIENT});
                            color: white;
                            font-family: Arial, sans-serif;
                            text-align: center;
                            height: 100vh;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                          }
                        </style>
                      </head>
                      <body>
                        <h1>Hello from the $${COLOR} instance at $PRIVATE_IP</h1>
                      </body>
                    </html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "color-instance-${count.index + 1}"
  }
}