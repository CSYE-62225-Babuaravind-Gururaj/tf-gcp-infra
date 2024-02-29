echo "
[Unit]
Description=Go Web Application
After=network.target

[Service]
User=csye6225
Group=csye6225
Environment=DBHOST={$DB_HOST}
Environment=DBPORT={$DB_PORT}
Environment=DBUSER={$USERNAME}
Environment=DBPASS={$PASSWORD}
Environment=DBNAME={$DB_NAME}
ExecStart=/usr/local/bin/webapp

[Install]
WantedBy=multi-user.target"

# sudo echo "Environment=DBHOST= $DB_HOST" >> /home/csye6225/webapp/userdata.yaml
# sudo echo "Environment=DBPORT= $DB_PORT" >> /home/csye6225/webapp/userdata.yaml
# sudo echo "Environment=DBUSER= $USERNAME" >> /home/csye6225/webapp/userdata.yaml
# sudo echo "Environment=DBPASS= $PASSWORD" >> /home/csye6225/webapp/userdata.yaml
# sudo echo "Environment=DBNAME= $DB_NAME" >> /home/csye6225/webapp/userdata.yaml

sudo chown csye6225:csye6225 /usr/local/bin/webapp.service
sudo chmod 750 /usr/local/bin/webapp.service

sudo systemctl daemon-reload
sudo systemctl start webapp.service
sudo systemctl enable webapp.service
sudo systemctl status webapp.service