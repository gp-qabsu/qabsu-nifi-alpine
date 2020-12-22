# Qabsu NiFi Image with Toolkit
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

NiFi properties used during the provisioning of the container are as follows:

| Property                                  | Environment Variable                   |
|-------------------------------------------|----------------------------------------|
| nifi.cluster.is.node                      | NIFI_WEB_HTTP_PORT                     |



#### Secure Standalone Instance (TLS)
