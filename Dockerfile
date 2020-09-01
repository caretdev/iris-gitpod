ARG IMAGE=iris-community:2020.3.0.200.0
FROM containers.intersystems.com/intersystems/${IMAGE} as iris

RUN iris start $ISC_PACKAGE_INSTANCENAME && \
    /bin/echo -e "" \
        " do ##class(Security.Users).Create(\"gitpod\", \"%ALL\",\"SYS\",\"User in Gitpod\")" \
        " do ##class(Security.Users).UnExpireUserPasswords(\"*\")" \
        " halt" \
    | iris session $ISC_PACKAGE_INSTANCENAME -U%SYS && \
    iris stop $ISC_PACKAGE_INSTANCENAME quietly && \
    rm -rf /usr/irissys/mgr/IRIS.WIJ && \
    rm -rf /usr/irissys/mgr/journal/*

FROM gitpod/workspace-full

USER root 

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      iproute2 \
      iputils-ping \
      krb5-multidev \
      libkrb5-dev \
      net-tools \
      wget \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y sysstat \
 && rm -rf /var/lib/apt/lists/*

COPY --from=iris --chown=gitpod:gitpod /usr/irissys /usr/irissys
COPY --from=iris --chown=gitpod:gitpod /home/irisowner/irissys /home/gitpod/irissys

ENV IRISSYS=/home/gitpod/irissys
ENV ISC_PACKAGE_INSTALLDIR=/usr/irissys
ENV ISC_PACKAGE_INSTANCENAME=IRIS
ENV ISC_PACKAGE_IRISGROUP=gitpod
ENV ISC_PACKAGE_IRISUSER=gitpod
ENV ISC_PACKAGE_MGRGROUP=gitpod
ENV ISC_PACKAGE_MGRUSER=gitpod

# Activate Durable %SYS
# ENV ISC_DATA_DIRECTORY=/home/gitpod/.iris

COPY irisstart.sh /home/gitpod/.bashrc.d/90-iris

# user irisowner replaced by gitpod, fix links 
RUN \
 ln -s /usr/irissys/dev/Container/changePassword.sh /usr/bin/changePassword.sh && \
 ln -s /usr/irissys/dev/Cloud/ICM/configLicense.sh /usr/bin/configLicense.sh && \
 ln -s /usr/irissys/dev/Cloud/ICM/waitISC.sh /usr/bin/waitISC.sh && \
 ln -s /home/gitpod/irissys/iris /usr/bin/iris && \
 ln -s /home/gitpod/irissys/irissession /usr/bin/irissession && \
 ln -sf irissession /home/gitpod/irissys/irisdb && \
 sed -i 's/irisuser/gitpod/' /usr/irissys/httpd/conf/httpd.conf

USER gitpod