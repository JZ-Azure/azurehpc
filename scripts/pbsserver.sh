#!/bin/bash
set -e

admin_user=$(whoami)

if [ "$(rpm -qa pbspro-server)" = "" ];then
    rpm=pbspro-server-19.1.1-0.x86_64.rpm
    if [ -e $rpm ]; then
        yum install -y $rpm
    else
        if [ -e pbspro_19.1.1.centos7/$rpm ]; then
            yum install -y pbspro_19.1.1.centos7/$rpm
        else
            echo "RPM not found"
            exit 1
        fi
    fi

    systemctl enable pbs
    systemctl start pbs
    /opt/pbs/bin/qmgr -c "s s managers += ${admin_user}@*"
    /opt/pbs/bin/qmgr -c 's s flatuid=t'
    /opt/pbs/bin/qmgr -c 's s job_history_enable=t'
    /opt/pbs/bin/qmgr -c 'c r pool_name type=string,flag=h'

    # Update the sched_config file to schedule jobs that request pool_name
    sed -i "s/^resources: \"ncpus,/resources: \"ncpus, pool_name,/g" /var/spool/pbs/sched_priv/sched_config
    systemctl restart pbs
else
    echo "PBSPro already installed"
fi
