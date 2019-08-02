#---------------------------------------------------------------------
# Function: InstallphpMyAdmin
#    Install and configure phpMyAdmin
#---------------------------------------------------------------------
InstallphpMyAdmin() {
    phpMyAdmin="4.9.0.1" #phpMyAdmin version 
    blowfish="hu67jty85Fgh6TRfcjiw50720fghTyjT" # blowfish 32 char secret maybe it can be autogenerated
    mkdir /usr/share/phpmyadmin
    mkdir /etc/phpmyadmin
    mkdir -p /var/lib/phpmyadmin/tmp
    chown -R www-data:www-data /var/lib/phpmyadmin
    touch /etc/phpmyadmin/htpasswd.setup
    cd /tmp
    wget https://files.phpmyadmin.net/phpMyAdmin/$phpMyAdmin/phpMyAdmin-$phpMyAdmin-all-languages.tar.gz
    tar xfz phpMyAdmin-$phpMyAdmin-all-languages.tar.gz
    mv phpMyAdmin-$phpMyAdmin-all-languages/* /usr/share/phpmyadmin/
    rm phpMyAdmin-$phpMyAdmin-all-languages.tar.gz
    rm -rf phpMyAdmin-$phpMyAdmin-all-languages
    cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php
    sed -i "s|\$cfg\['blowfish_secret'\]\s=\s'';|\$cfg['blowfish_secret'] = '$blowfish';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "$ a\$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" /usr/share/phpmyadmin/config.inc.php
    echo -n "Creating Apache config file for phpMyAdmin"
    touch /etc/apache2/conf-available/phpmyadmin.conf
    echo "# phpMyAdmin default Apache configuration" >> /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Alias /phpmyadmin /usr/share/phpmyadmin" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\<Directory /usr/share/phpmyadmin>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Options FollowSymLinks" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\DirectoryIndex index.php" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\<IfModule mod_php7.c>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\AddType application/x-httpd-php .php" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\php_flag magic_quotes_gpc Off" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\php_flag track_vars On" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\php_flag register_globals Off" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\php_value include_path ." /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\</IfModule>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\</Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\# Authorize for setup" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\<Directory /usr/share/phpmyadmin/setup>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\<IfModule mod_authn_file.c>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\AuthType Basic"/etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\AuthName 'phpMyAdmin Setup'" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\AuthUserFile /etc/phpmyadmin/htpasswd.setup" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\</IfModule>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Require valid-user" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\</Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\# Disallow web access to directories that don't need it" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\<Directory /usr/share/phpmyadmin/libraries>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Order Deny,Allow" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Deny from All" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\</Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\<Directory /usr/share/phpmyadmin/setup/lib>" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Order Deny,Allow" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\Deny from All" /etc/apache2/conf-available/phpmyadmin.conf
    sed -i "$ a\</Directory>" /etc/apache2/conf-available/phpmyadmin.conf
    a2enconf phpmyadmin
    systemctl restart apache2
    echo -e "[${green}..DONE${NC}]\n"
    echo -e "Configuring phpMyAdmin configuration store (database)."
    echo -n "Entering MariaDB shell..."
    mysql -u root 
    mysql -e "CREATE DATABASE phpmyadmin;"
    mysql -e "CREATE USER 'pma'@'localhost' IDENTIFIED BY $CFG_MYSQL_ROOT_PWD;"
    mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY $CFG_MYSQL_ROOT_PWD WITH GRANT OPTION;"
    mysql -e "FLUSH PRIVILEGES;"
    mysql -e "EXIT;"
    mysql -u root phpmyadmin < /usr/share/phpmyadmin/sql/create_tables.sql
    #\s for white space  change the / to | delimiter add escape char \ in front of [ and ] \[ \] - only required in the search for compassion not the substustion!
    # NOTE '' are ok as its enclosed in " " so no need to escape them!!
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['controlhost'\]\s=\s'';|\$cfg['Servers'][\$i]['controlhost'] = 'localhost';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['controlport'\]\s=\s'';|\$cfg['Servers'][\$i]['controlport'] = '';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['controluser'\]\s=\s'pma';|\$cfg['Servers'][\$i]['controluser'] = 'pma';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['controlpass'\]\s=\s'pmapass';|\$cfg['Servers'][\$i]['controlpass'] = '$CFG_MYSQL_ROOT_PWD';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['pmadb'\]\s=\s'phpmyadmin';|\$cfg['Servers'][\$i]['pmadb'] = 'phpmyadmin';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['bookmarktable'\]\s=\s'pma__bookmark';|\$cfg['Servers'][\$i]['bookmarktable'] = 'pma__bookmark';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['relation'\]\s=\s'pma__relation';|\$cfg['Servers'][\$i]['relation'] = 'pma__relation';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['table_info'\]\s=\s'pma__table_info';|\$cfg['Servers'][\$i]['table_info'] = 'pma__table_info';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['table_coords'\]\s=\s'pma__table_coords';|\$cfg['Servers'][\$i]['table_coords'] = 'pma__table_coords';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['pdf_pages'\]\s=\s'pma__pdf_pages';|\$cfg['Servers'][\$i]['pdf_pages'] = 'pma__pdf_pages';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['column_info'\]\s=\s'pma__column_info';|\$cfg['Servers'][\$i]['column_info'] = 'pma__column_info';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['history'\]\s=\s'pma__history';|\$cfg['Servers'][\$i]['history'] = 'pma__history';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['table_uiprefs'\]\s=\s'pma__table_uiprefs';|\$cfg['Servers'][\$i]['table_uiprefs'] = 'pma__table_uiprefs';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['tracking'\]\s=\s'pma__tracking';|\$cfg['Servers'][\$i]['tracking'] = 'pma__tracking';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['userconfig'\]\s=\s'pma__userconfig';|\$cfg['Servers'][\$i]['userconfig'] = 'pma__userconfig';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['recent'\]\s=\s'pma__recent';|\$cfg['Servers'][\$i]['recent'] = 'pma__recent';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['favorite'\]\s=\s'pma__favorite';|\$cfg['Servers'][\$i]['favorite'] = 'pma__favorite';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['users'\]\s=\s'pma__users';|\$cfg['Servers'][\$i]['users'] = 'pma__users';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['usergroups'\]\s=\s'pma__usergroups';|\$cfg['Servers'][\$i]['usergroups'] = 'pma__usergroups';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['navigationhiding'\]\s=\s'pma__navigationhiding';|\$cfg['Servers'][\$i]['navigationhiding'] = 'pma__navigationhiding';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['savedsearches'\]\s=\s'pma__savedsearches';|\$cfg['Servers'][\$i]['savedsearches'] = 'pma__savedsearches';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['central_columns'\]\s=\s'pma__central_columns';|\$cfg['Servers'][\$i]['central_columns'] = 'pma__central_columns';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['designer_settings'\]\s=\s'pma__designer_settings';|\$cfg['Servers'][\$i]['designer_settings'] = 'pma__designer_settings';|" /usr/share/phpmyadmin/config.inc.php
    sed -i "s|//\s\$cfg\['Servers'\]\[\$i\]\['export_templates'\]\s=\s'pma__export_templates';|\$cfg['Servers'][\$i]['export_templates'] = 'pma__export_templates';|" /usr/share/phpmyadmin/config.inc.php
    echo -e "[${green}..DONE${NC}]\n"
}
