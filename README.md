# Docker image for the NEST simulator

Currently the following docker images are provided

-   Minimal install

    -   nest/docker-nest-latest (~970MB)
        Installs the latest stable release (ppa:nest-simulator/nest).

    -   nest/docker-nest-nightly (~970MB)
        Installs the latest nightly build (ppa:nest-simulator/nest-nightly).

-   Complete install from the source with the configurations
        'WITH_MPI=On', 'WITH_GSL=On',
        'WITH_MUSIC=On' and 'WITH_LIBNEUROSIM=On'

    -   nest/docker-nest-2.12.0 (~3.4GB)
    -   nest/docker-nest-2.14.0 (~3.4GB)

    NOTE: For building both a master docker image (~3,2GB) is created.
    It can be deleted afterwards.

## Usage

    Load the source of the nest-docker function
    source <PATH_TO>/nest-docker.sh

    nest-docker [--help] <command> [<args>] [<version>]

    --help      print this usage information.
    <command>   can be either 'provision', 'run' or 'clean'.
    [<args>]    can be either 'notebook', 'interactice' or 'virtual'.
    [<version>] kind of docker image (e.g. 'latest', 'nightly', '2.x.0').

    Example:    nest-docker provision latest
                nest-docker run notebook latest

## 1 - 2 (- 3)

In the following, VESRION is the kind of docker image you want to use
(right now 'latest', 'nightly', 'dev', 'test', '2.x.0').

Two little steps to get started

### 1 - Provisioning NEST image

    nest-docker provision VERSION

You can adapt some configuration options in nest-docker.sh. For other/more
configuration options please change the 'Dockerfile'. See:
<https://github.com/nest/nest-simulator/blob/v2.14.0/README.md>

### 2 - Run NEST container

-   with Jupyter Notebook

        nest-docker run notebook VERSION  

    VESRION is latest, nightly, dev, test or 2.x.0.               
    Open the displayed URL in your browser and have fun with Jupyter
    Notebook and NEST.

-   in interactive mode

        nest-docker run interactive VERSION

    After the prompt 'Your python script:' enter the filename of the script
    you want to start. Only the filename without any path. The file has to
    be in the path where you start the script.

-   as virtual image

        nest-docker run virtual VERSION

    You are logged in as user 'nest'. Compute the command 'import nest' in the
    python-shell. A 'nest.help()' should display the main help page.

### (3) - Delete NEST images

    nest-docker clean

Be careful. This stops ALL containers and delete ALL images labeling with 'nest'.

## Useful Docker commands

-   Delete ALL Docker images (USE WITH CAUTION!)

        docker system prune -fa

-   Export a Docker image

        docker save nest/docker-nest-latest | gzip -c > nest-docker.tar.gz

-   Import a Docker image

        gunzip -c nest-docker.tar.gz | docker load
