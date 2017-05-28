FROm ubuntu:16.04

# Install OpenSSH
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN echo 'root:root' | chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Install nsscache
RUN apt-get install -y libnss-cache python-pip python-ldap git
RUN pip install --upgrade git+https://github.com/google/nsscache.git@master#egg=nsscache pycurl

COPY nsscache.conf /etc/nsscache.conf
COPY nsswitch.conf /etc/nsswitch.conf

COPY root.pub /root/.ssh/authorized_keys

# Setup AuthorizedKeysCommand for the demo
COPY syncKeys.sh /usr/local/bin/syncKeys.sh
RUN chmod +x /usr/local/bin/syncKeys.sh
RUN echo "AuthorizedKeysCommand /usr/local/bin/syncKeys.sh" >> /etc/ssh/sshd_config
RUN echo "AuthorizedKeysCommandUser root" >> /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]

