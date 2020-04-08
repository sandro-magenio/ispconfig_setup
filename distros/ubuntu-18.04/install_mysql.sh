#---------------------------------------------------------------------
# Function: InstallSQLServer
#    Install and configure SQL Server
#---------------------------------------------------------------------
InstallSQLServer() {
  if [ "$CFG_SQLSERVER" == "MySQL" ]; then
    echo -n "Installing Database server (MySQL)... "
    echo "mysql-server-5.5 mysql-server/root_password password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    echo "mysql-server-5.5 mysql-server/root_password_again password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
    apt_install mysql-client mysql-server
    sed -i 's/bind-address		= 127.0.0.1/#bind-address		= 127.0.0.1/' /etc/mysql/my.cnf
    echo -e "[${green}DONE${NC}]\n"
    echo -n "Restarting MySQL... "
    service mysql restart
    echo -e "[${green}DONE${NC}]\n"
  
  elif [ "$CFG_SQLSERVER" == "Percona" ]; then
   echo -n "Installing GnuPG..."
   	apt_install gnupg2
   echo -n "Downloading Percona apt and enable it... "
	wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
	dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
	percona-release setup ps57
	apt-get update 
	
   echo -n "Installing Database server (Percona)... "
   	echo "percona-server-server-5.7 percona-server-server-5.7/root-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
   	echo "percona-server-server-5.7 percona-server-server-5.7/re-root-pass password $CFG_MYSQL_ROOT_PWD" | debconf-set-selections
   	apt_install percona-server-server-5.7
    echo -e "[${green}DONE${NC}]\n"
    echo "lets configure percona."

	mysql --defaults-file/etc/mysql/debian.cnf <<EOF
	CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so';
	CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so';
	CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so';
	EOF
    echo -n "Restarting Percon MySQL Server... "
    service mysql restart
    echo -e "[${green}DONE${NC}]\n"
  fi	

  
 }
