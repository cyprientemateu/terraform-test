# Define the EC2 instance
resource "aws_instance" "prometheus_grafana" {
  ami             = data.aws_ami.ubuntu_22_04.id # Ubuntu AMI (update if necessary)
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.ec2_sg.id]
  subnet_id       = data.aws_subnet.public-01.id


  root_block_device {
    volume_size = var.root_volume
    volume_type = var.volume_type
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update and install dependencies
              apt-get update -y
              apt-get install -y wget curl unzip

              # Install Prometheus
              useradd --no-create-home --shell /bin/false prometheus
              mkdir /etc/prometheus /var/lib/prometheus
              wget https://github.com/prometheus/prometheus/releases/download/v2.50.0/prometheus-2.50.0.linux-amd64.tar.gz
              tar -xvf prometheus-2.50.0.linux-amd64.tar.gz
              mv prometheus-2.50.0.linux-amd64/prometheus /usr/local/bin/
              mv prometheus-2.50.0.linux-amd64/promtool /usr/local/bin/
              mv prometheus-2.50.0.linux-amd64/consoles /etc/prometheus/
              mv prometheus-2.50.0.linux-amd64/console_libraries /etc/prometheus/
              mv prometheus-2.50.0.linux-amd64/prometheus.yml /etc/prometheus/
              chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
              cat <<-EOP > /etc/systemd/system/prometheus.service
              [Unit]
              Description=Prometheus
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=prometheus
              ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/

              [Install]
              WantedBy=multi-user.target
              EOP
              systemctl daemon-reload
              systemctl enable prometheus
              systemctl start prometheus

              # Install Grafana
              # Add Grafana repository
              curl https://packages.grafana.com/gpg.key | apt-key add -
              echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list
              apt-get update -y
              apt-get install -y grafana

              # Enable and start Grafana service
              systemctl enable grafana-server
              systemctl start grafana-server
            EOF

  tags = {
    Name = "Prometheus-Grafana-Server"
  }
}
