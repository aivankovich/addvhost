#!/bin/sh
hostmaster="hostmaster@test.ru"      # admin's email
www_path="/var/www/"        # path to sites
wwwuser="www-data"                
wwwgroup="www-data"
 
case "$@" in
    "")
        echo "Enter domain name (as root)."
        ;;
    *)
        clear
        echo "making site's directory"
        mkdir -p $www_path$1/html/
        mkdir -p $www_path$1/cgi-bin/
        mkdir -p $www_path$1/log/
        echo "$www_path$1/html/"
        echo "$www_path$1/cgi-bin/"
        echo "$www_path$1/log/"
 
        echo "\nCreating empty index.html "
        echo " " > $www_path$1/html/index.html
        chown -R $wwwuser:$wwwgroup /$www_path$1
        chmod -R 0755 /$www_path$1

        echo "\nadding new host to: /etc/nginx/sites-enabled/$1"
        exec 3>&1 1>/etc/nginx/sites-enabled/$1
        echo "server {"
	echo "	listen 80;"
	echo "	listen [::]:80;"
	echo "	server_name $1;"
	echo "	"
        echo "	"       
    	echo "	location / {"
    	echo "		try_files $uri $uri/ =404;"
    	echo "	}"
    	echo "	#Static files location"
    	echo "	location ~* ^.+.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|js|html|flv|mp3)$ "
    	echo "	{"
     	echo "	root $www_path$1/html/;"
    	echo "}"
    	echo "include /etc/nginx/templates/php-fpm.conf;"
		echo "}"
        exec 1>&3

        sleep 1
        echo "server restart"
        sudo /etc/init.d/nginx restart
        echo "Domain ready, mazafaka"
        echo "meow http://$1"
        ;;
		echo "\nCreating empty repository "
		mkdir -p /var/opt/git/$1.git/
		git init /var/opt/git/$1 --bare
		echo "some deploy hooks"
		exec 3>&1 1>/var/opt/git/$1.git/hooks/post-receive
			echo "#!/bin/sh"
			echo "GIT_WORK_TREE=/var/www/$1/html git checkout -f"
		exec 1>&3
		chown -R git:git /var/opt/git/$1.git/hooks/post-receive
		echo "meow meow"
esac
