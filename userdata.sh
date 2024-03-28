echo "
[Unit]
Description=Go Web Application
After=network.target

[Service]
User=csye6225
Group=csye6225
Environment=DBHOST=${ip_address}
Environment=DBPORT=${db_port}
Environment=DBUSER=${username}
Environment=DBPASS=${password}
Environment=DBNAME=${db_name}
Environment=GCP_PROJECT_ID=${GCP_PROJECT_ID}
ExecStart=/usr/local/bin/webapp

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/webapp.service

sudo chown csye6225:csye6225 /etc/systemd/system/webapp.service
sudo chmod 750 /etc/systemd/system/webapp.service

sudo systemctl daemon-reload
sudo systemctl start webapp.service
sudo systemctl enable webapp.service
sudo systemctl status webapp.service