FROM jlphillips/csci3130

LABEL maintainer="Joshua L. Phillips <https://www.cs.mtsu.edu/~jphillips/>"

USER root

# Additional tools
RUN apt-get update && \
    apt-get install -y \
    gromacs \
    gromacs-mpich \
    dnsutils \
    grace \
	
	#Adding slapd and ldap-utils for ldap
    slapd \
    ldap-utils \
    tree \
	
    && apt-get clean

# Start ssh on startup
# Uses sudo so container needs to be started as root
# and also needs to have environment variable GRANT_SUDO set to yes
# Otherwise, this will simply fail to start...
COPY start_ssh_server.sh /usr/local/bin/before-notebook.d/start_ssh_server.sh

# Setup ssh directory
RUN mkdir /home/jovyan/.ssh
RUN chmod 700 /home/jovyan/.ssh

# Install public key into authorized_keys
COPY authorized_keys /home/jovyan/.ssh/.
RUN chmod 644 /home/jovyan/.ssh/authorized_keys

# Install private key in to .ssh
COPY id_rsa /home/jovyan/.ssh/.
RUN chmod 600 /home/jovyan/.ssh/id_rsa

# Install public key into .ssh
COPY id_rsa.pub /home/jovyan/.ssh/.
RUN chmod 644 /home/jovyan/.ssh/id_rsa.pub

# Make current host key auto-login via known_hosts
RUN echo -n "* " >> /home/jovyan/.ssh/known_hosts
RUN cat /etc/ssh/ssh_host_ecdsa_key.pub >> /home/jovyan/.ssh/known_hosts
RUN chmod 600 /home/jovyan/.ssh/known_hosts

# Set ownership on all ssh config above
RUN chown -R jovyan /home/jovyan/.ssh

RUN dpkg-reconfigure slapd
RUN echo $'no\n'
RUN echo $'practice.net\n'
RUN echo $'practice\n'
RUN echo $'password\n'
RUN echo $'password\n'
RUN echo $'yes\n'
RUN echo $'yes\n'

RUN service slapd start



# CSCI 3130
USER $NB_UID
