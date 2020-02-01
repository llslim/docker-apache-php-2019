# docker-apache-php Web Service (php 7.2 apache)

A Docker container to provide a web service for executing applications written in PHP.

The container runs an instance of Apache Webserver for web applications written in PHP to display and retrieve data through standard web protocols. This container also provides connections to other service containers for data storage and sending e-mail messages.

The container is intended to work as a part of an orchestrated bundle of docker containers to provide a platform for developing and testing complete web applications on a laptop or desktop. Along side database and mail service containers, this web service container is an easy and quick way to start a web application using the docker-compose utility. For more information see the [docker-lamp](https://github.com/llslim/docker-lamp) repository.

The intent of this container is for testing and development web applications on a personal laptop or desktop. So security measures against malicious attacks is not a high priority for this container. Using it in a critical environment is NOT recommended.

This container is configured to use the [MSMTP Mail User Agent](http://msmtp.sourceforge.net/) to interpret sendmail calls from the web application and deliver messages to the mail service container.

The default sendmail_path in the php.ini is set to /usr/sbin/sendmail, which is a wrapper for the MSMTP user agent (via the msmtp_mta deb package).

Most often this container is paired with a [MailHog email testing tool for developers](https://github.com/mailhog/MailHog) container. By default the [MailHog container](https://hub.docker.com/r/mailhog/mailhog/) expose and listens to port 1025. The default configuration of MSMTP in the /etc/msmtprc file reflects that setting. The configuration can be change to work with more traditional Mail Transfer Agents like Postfix, Exim, or Mailgun by mounting a new msmtprc file through docker-compose.

In fact any configuration in this container can be overridden by mounting a configuration file as a volume in an docker-compose.yml file.

Error logging paths will be set to the /dev/stderr so docker can display them when we run the following on the command line:

`docker logs <container_name or ID>`.

## Base Container
The [Offical PHP Container](https://hub.docker.com/_/php/) is used as a base container.
