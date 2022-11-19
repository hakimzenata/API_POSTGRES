#!/bin/bash

set -Eeuo pipefail

echo '🚀INSTALLER: START'

# upgrade du système
dnf upgrade -y

echo '🚀INSTALLER: install oracle preinstall for oracle DB 21c'

dnf install -y oracle-database-preinstall-21c openssl

echo '🚀INSTALLER: Oracle preinstall and openssl complete'

# creation des dossiers
mkdir -p "$ORACLE_HOME" /u01/appi
ln -s "$ORACLE_BASE" /u01/app/oracle
inventory_location=$(realpath "$ORACLE_BASE"/../oraInventory)
mkdir -p "$inventory_location"

echo '🚀INSTALLER: les dossiers d'oracle ont été créé

# configuration des variable d'envirenement 
cat >> /home/oracle/.bashrc << EOF
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin
EOF


# Installation d'Oracle DB 
unzip /opt/LINUX.X64_213000_db_home.zip -d "$ORACLE_HOME"/
cp /opt/ora-response/db_install.rsp.tmpl /tmp/db_install.rsp
sed -i -e "s|###INVENTORY_LOCATION###|$inventory_location|g" /tmp/db_install.rsp
sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" /tmp/db_install.rsp
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /tmp/db_install.rsp
sed -i -e "s|###ORACLE_EDITION###|$ORACLE_EDITION|g" /tmp/db_install.rsp
chown oracle:oinstall -R "$ORACLE_BASE" "$inventory_location"

su -l oracle -c "yes | $ORACLE_HOME/runInstaller -silent -ignorePrereqFailure -waitforcompletion -responseFile /install/db_install.rsp" || {
  ret=$?
  if [[ $ret -ne 6 ]]; then
    echo 'Installation échoué!'
    exit $ret;
  fi;
}

"$inventory_location"/orainstRoot.sh
"$ORACLE_HOME"/root.sh

echo '🚀INSTALLER: Oracle DB est installer'

# création de sqlnet.ora, listener.ora, et tnsnames.ora
network_admin_dir=$("$ORACLE_HOME"/bin/orabasehome)/network/admin
su -l oracle -c "mkdir -p $network_admin_dir"
su -l oracle -c "echo 'NAME.DIRECTORY_PATH= (TNSNAMES, EZCONNECT, HOSTNAME)' > $network_admin_dir/sqlnet.ora"

# Listener.ora
su -l oracle -c "echo 'LISTENER =
(DESCRIPTION_LIST =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = $LISTENER_PORT))
  )
)

DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
' > $network_admin_dir/listener.ora"

su -l oracle -c "echo '$ORACLE_SID=localhost:$LISTENER_PORT/$ORACLE_SID' > $network_admin_dir/tnsnames.ora"

su -l oracle -c "echo '$ORACLE_PDB=
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = $LISTENER_PORT))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $ORACLE_PDB)
  )
)' >> $network_admin_dir/tnsnames.ora"

# démmarage du LISTENER
su -l oracle -c 'lsnrctl start'

echo 'INSTALLER: Listener est créé'

# génération d'un dossier pour oracle si n'est pas créé
export ORACLE_PWD=${ORACLE_PWD:-"$(openssl rand -base64 8)1"}

cp /vagrant/ora-response/dbca.rsp.tmpl /tmp/dbca.rsp
sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" /tmp/dbca.rsp
sed -i -e "s|###ORACLE_PDB###|$ORACLE_PDB|g" /tmp/dbca.rsp
sed -i -e "s|###ORACLE_CHARACTERSET###|$ORACLE_CHARACTERSET|g" /tmp/dbca.rsp
sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" /tmp/dbca.rsp
sed -i -e "s|###EM_EXPRESS_PORT###|$EM_EXPRESS_PORT|g" /tmp/dbca.rsp

# Création d'une DB
su -l oracle -c 'dbca -silent -createDatabase -responseFile /tmp/dbca.rsp'

# Post DB setup tasks
su -l oracle -c "sqlplus / as sysdba << EOF
   ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;
   EXEC DBMS_XDB_CONFIG.SETGLOBALPORTENABLED (TRUE);
   ALTER SYSTEM SET LOCAL_LISTENER = '(ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = $LISTENER_PORT))' SCOPE=BOTH;
   ALTER SYSTEM REGISTER;
   exit
EOF"

rm /tmp/dbca.rsp

echo 'INSTALLER: Database created'

sed -i -e "\$s|${ORACLE_SID}:${ORACLE_HOME}:N|${ORACLE_SID}:${ORACLE_HOME}:Y|" /etc/oratab
echo 'INSTALLER: Oratab configured'

# configure systemd to start oracle instance on startup
cp /vagrant/scripts/oracle-rdbms.service /etc/systemd/system/
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /etc/systemd/system/oracle-rdbms.service
systemctl daemon-reload
systemctl enable oracle-rdbms
systemctl start oracle-rdbms
echo "INSTALLER: Created and enabled oracle-rdbms systemd's service"

cp /vagrant/scripts/setPassword.sh /home/oracle/
chown oracle:oinstall /home/oracle/setPassword.sh
chmod u=rwx,go=r /home/oracle/setPassword.sh

echo 'INSTALLER: setPassword.sh file setup'

echo 'INSTALLER: Installation complete, database ready to use!'
