# Qabsu NiFi Image with Toolkit
![GitHub repo size](https://img.shields.io/github/repo-size/gp-qabsu/qabsu-nifi-alpine)
![GitHub contributors](https://img.shields.io/github/contributors/gp-qabsu/qabsu-nifi-alpine)
![GitHub forks](https://img.shields.io/github/forks/gp-qabsu/qabsu-nifi-alpine?style=social)

The following repository contains Apache NiFi and Toolkit provisioned on the Alpine Linux distribution.  The image supports running in standalone mode either unsecured or with user authentication provided via
* Two-way SSL client certificates
* Lightweight Directory Access Protocol (LDAP)

## Quick Start
### Build
The docker image can be built using the following command:
```shell
docker build -t qabsu/apache-nifi:1.12.1 .
```
Note:  The default version of Apache NiFi specified in the Dockerfile is 1.12.1 which is the latest stable version as at time of creation.  To build an image for a different version, the `NIFI_VERSION` build argument can be overwritten with the following command:
```shell
docker build --build-arg=NIFI_VERSION={desiredVersion} -t qabsu/apache-nifi:{desiredVersion} .
```
### Starting Container
#### Unsecure Standalone Instance
The minimum to run an instance of Apache NiFi is as follows:
```shell
docker run --name nifi \
  -p 8080:8080 \
  -d \
  qabsu/apache-nifi:1.12.1
```
This will provision an instance of Apache Nifi with the NiFi toolkit, exposing the instance UI to the host system on port 8080, viewable at `http://localhost:8080/nifi`

#### Secure Standalone Instance (TLS)
In this configuration, the user will need to provide certificates and the associated configuration information.
Of particular note, is the `AUTH` environment variable which is set to `tls`.  Additionally, the user must provide an
the DN as provided by an accessing client certificate in the `INITIAL_ADMIN_IDENTITY` environment variable.
This value will be used to seed the instance with an initial user with administrative privileges.
Finally, this command makes use of a volume to provide certificates on the host system to the container instance.

```shell
docker run --name nifi \
    -v /Users/qabsu/local.nifi/opt/certs:/opt/certs \
    -p 8443:8443 \
    -e AUTH=tls \
    -e KEYSTORE_PATH=/opt/certs/keystore.jks \
    -e KEYSTORE_TYPE=JKS \
    -e KEYSTORE_PASSWORD=${keystore-password} \
    -e TRUSTSTORE_PATH=/opt/certs/truststore.jks \
    -e TRUSTSTORE_PASSWORD=${truststore-password} \
    -e TRUSTSTORE_TYPE=JKS \
    -e INITIAL_ADMIN_IDENTITY='CN=Qabsu, O=Apache, OU=NiFi, C=AU' \
    -d \
    qabsu/apache-nifi:1.12.1
```
