#Written by Efe Özkan 
#This script updates the system and setup the depencies for flask hosting.
#Must run inside the project folder!!
#Reference: https://www.linode.com/docs/guides/flask-and-gunicorn-on-ubuntu/

sudo apt-get update -y
sudo apt-get upgrade -y 
sudo apt-get install nginx -y
sudo apt-get install gunicorn -y
sudo apt-get install unzip -y
sudo pip3 install -r requirements.txt

server_name=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo "server {
    listen 80;
    server_name $server_name;

    location / {
        proxy_pass http://127.0.0.1:8000;
    " > /etc/nginx/sites-enabled/flask_app
echo '
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}' >> /etc/nginx/sites-enabled/flask_app

sudo unlink /etc/nginx/sites-enabled/default
sudo nginx -s reload
#nginx ready

#supervisor config
sudo mkdir /var/log/main
sudo touch /var/log/main/flask_app.out.log
sudo touch /var/log/main/flask_app.err.log

echo "[program:main]
directory=$(pwd)
command=gunicorn -w 10 main:app
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/main/flask_app.err.log
stdout_logfile=/var/log/main/flask_app.out.log" > /etc/supervisor/conf.d/flask_app.conf

#run supervisor
sudo supervisorctl reload

#You can change worker count in here
#main is for run file
gunicorn -w 10 main:app
#start python