#---------------------------------------------------------------------
# Function: InstallMagenio
#    Install Magenio Utilities
#---------------------------------------------------------------------
InstallMagenio() {
  echo -n "Install Magenio Utilities (Redis, Git, HTOP)... ";
  apt_install install redis-server git htop 
  echo -e "[${green}DONE${NC}]\n"
}
