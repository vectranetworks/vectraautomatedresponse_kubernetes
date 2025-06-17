# Vectra Automated Response - Kubernetes

## Introduction

This is a Kubernetes definition to run the Vectra Automated Response framework in a container. The below has been tested with K3S 

This uses the [vectraautomatedrespones](https://github.com/vectranetworks/vectraautomatedresponse) github repository within the container.


## Configuration

Below are the files that need to be modified in order to use this tool:
  1. [vectra-automated-response-deployment.yaml](./vectra-automated-response-deployment.yaml)
  1. [config-configmap.yaml](./config-configmap.yaml)
  1. integration configmaps located in [configmaps](./configmaps/) directory


- vectra-automated-response-deployment.yaml

  This file handles the secrets that the container will use to interact with the Brain(s) and the selected EDR(s).

  - Brain
    - Replace the <brain_url> in following with URL of the corresponding Brain
      - <brain_url>_Client_ID
      - <brain_url>_Secret_Key
    - **Note:** This can be used multiple times for multiple Brains

  - Integrations
    - For each integration configured in [config.py](./config.py), uncomment the related variables. If a variable has `<>` surrounding text, this identifies unique information that will need to be provided in that section of the variable similar to the Brain configuration.

  - Debug Logs
    - `VAR_DEBUG: True` will turn logging debug on.

- config-configmap.yaml and integration configmaps

  These are the same configuration files used in [vectraautomatedrespones](https://github.com/vectranetworks/vectraautomatedresponse). Follow the guidance in that repository for configuration.


## Docker Build and Local Registry
  - The container will need to be built in a local registry. Run the following command to build the container (assumes docker is available).
    ```
    $ docker build -t vectra-automated-response:latest vectra_automated_response/. --no-cache
    ```
  
  -  If not already utilizing private repositories, create `registry.yaml` file for K3S with the following content:
      ```
      mirror:
        "127.0.0.1:5000":
          endpoint: "http://127.0.0.1:5000"
      ```

  - Deploy a registry container in Docker and push the built container into it

    ```
    $ docker run -d -p 5000:5000 --name registry registry:2
    $ docker tag vectra-automated-response:latest 127.0.0.1:5000/vectra-automated-response:latest
    $ docker push 127.0.0.1:5000/vectra-automated-response:latest
    ```

  - Modify the `image` value in [vectra-automated-response-deployment.yaml](./vectra-automated-response-deployment.yaml) to match the pushed container in the example

## Deployment
- Once the configuration files are modified correctly and the container is available in the local registry, you are ready to begin the deployment

  - Create a namespace

  ```
  $ sudo kubectl namespace var
  ```

  - Apply the config maps

  ```
  $ sudo kubectl apply -f config-configmap.yaml -n var
  $ for file in configmaps/*; do sudo kubectl apply -f $file -n var; done
  ```

  - Apply the deployment file

  ```
  $ sudo kubectl apply -f vectra-automated-response-deployment.yaml -n var
  ```

  - Alternatively, there is a [var.sh](./var.sh) script that will handle this part of the deployment. It assumes that the container is available at the configured image location

## Validation Command Examples

```
$ sudo kubectl get pods -n var
$ sudo kubectl describe pod <pod>
$ sudo kubectl logs <pod>
```