#!/usr/bin/env bash

# nest-docker.sh
#
# This file is part of NEST.
#
# Copyright (C) 2004 The NEST Initiative
#
# NEST is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# NEST is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NEST.  If not, see <http://www.gnu.org/licenses/>.


NEST_PYTHON_VERSION=2
NEST_WITH_MPI=Off
NEST_WITH_GSL=Off
NEST_WITH_MUSIC=Off
NEST_WITH_LIBNEUROSIM=Off


function nest-docker {

    local PARDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

    if test $# -lt 1; then
        print_usage=true
    else
        case "$1" in
            provision)
            command=provision
            ;;
            run)
            command=run
            ;;
            clean)
            command=clean
            ;;
            --help)
            command=help
            ;;
            *)
            echo "Error: unknown command '$1'"
            command=help
            ;;
        esac
        shift
    fi

    case $command in
        provision)
        echo
        echo "Provisioning needs an argument:"
        echo "'latest', 'nightly', 'dev', 'test' or a NEST version e.g. 2.14.0"
        echo
        while test $# -gt 0; do
            case "$1" in
                latest)
                echo "Build a NEST latest image"
                echo
                docker build \
                -f $PARDIR/latest/Dockerfile \
                -t nest/docker-nest-latest $PARDIR
                echo
                echo "Finished!"
                ;;
                nightly)
                echo "Build a NEST nightly image"
                echo
                docker build \
                -f $PARDIR/nightly/Dockerfile \
                -t nest/docker-nest-nightly $PARDIR
                echo
                echo "Finished!"
                ;;
                master)
                echo
                echo "Build a master image"
                echo
                docker build \
                    -f $PARDIR/src/master/Dockerfile \
                    -t nest/docker-nest-master $PARDIR
                echo
                echo "Finished!"
                ;;
                dev)
                echo "Build a NEST image from github"
                echo
                docker build \
                --build-arg GIT_CHECKOUT=$2 \
                --build-arg PYTHON_VERSION=$NEST_PYTHON_VERSION \
                --build-arg WITH_MPI=$NEST_WITH_MPI \
                --build-arg WITH_GSL=$NEST_WITH_GSL \
                --build-arg WITH_LIBNEUROSIM=$NEST_WITH_LIBNEUROSIM \
                --build-arg WITH_MUSIC=$NEST_WITH_MUSIC \
                -f $PARDIR/src/dev/Dockerfile \
                -t nest/docker-nest-dev $PARDIR
                echo
                echo "Finished!"
                ;;
                test)
                echo "Build a NEST image from the current folder"
                echo
                cp $PARDIR/src/test/Dockerfile $PWD
                cp $PARDIR/entrypoint-py$NEST_PYTHON_VERSION.sh $PWD/entrypoint.sh
                docker build \
                --build-arg PYTHON_VERSION=$NEST_PYTHON_VERSION \
                --build-arg WITH_MPI=$NEST_WITH_MPI \
                --build-arg WITH_GSL=$NEST_WITH_GSL \
                --build-arg WITH_LIBNEUROSIM=$NEST_WITH_LIBNEUROSIM \
                --build-arg WITH_MUSIC=$NEST_WITH_MUSIC \
                -t nest/docker-nest-test .
                echo
                echo "Finished!"
                ;;
                2.*)
                echo
                echo "Build a NEST image for the version $1"
                echo
                vercomp 2.10.0 $1
                if [ "$?" = "2" ] ; then \
                    docker build \
                    --build-arg NEST_VERSION=$1 \
                    --build-arg PYTHON_VERSION=$NEST_PYTHON_VERSION \
                    --build-arg WITH_MPI=$NEST_WITH_MPI \
                    --build-arg WITH_GSL=$NEST_WITH_GSL \
                    --build-arg WITH_LIBNEUROSIM=$NEST_WITH_LIBNEUROSIM \
                    --build-arg WITH_MUSIC=$NEST_WITH_MUSIC \
                    -f $PARDIR/src/release/Dockerfile \
                    -t nest/docker-nest-$1 $PARDIR \
                ; else \
                    docker build \
                    --build-arg NEST_VERSION=$1 \
                    --build-arg PYTHON_VERSION=$NEST_PYTHON_VERSION \
                    -f $PARDIR/src/release-old/Dockerfile \
                    -t nest/docker-nest-$1 $PARDIR \
                ; fi
                echo
                echo "Finished!"
                ;;
                *)
                echo "Error: Unrecognized option '$1'"
                command=help
                ;;
            esac
            shift
        done
        ;;
        run)
        echo
        echo "Run needs three arguments:"
        echo
        echo "  - 'notebook VERSION'"
        echo "  - 'interactive VESRION'"
        echo "  - 'virtual VERSION'"
        echo
        echo "VERSION ist the version of NEST (e.g. latest)"
        echo
        LOCALDIR=$PWD
        while test $# -gt 1; do
            case "$1" in
                notebook)
                echo "Run NEST-$2 with Jupyter Notebook".
                echo
                docker run -it --rm --user nest --name nest-docker-notebook \
                -v $LOCALDIR:/home/nest/data \
                -p 8080:8080 nest/docker-nest-"$2" notebook
                echo
                ;;
                interactive)
                echo "Run NEST-$2 in interactive mode."
                echo
                docker run -it --rm --user nest --name nest-docker-interactive \
                -v $LOCALDIR:/home/nest/data \
                -p 8080:8080 nest/docker-nest-"$2" interactive
                echo
                ;;

                virtual)
                echo "Run NEST-$2 like a virtual machine."
                echo
                docker run -it --rm --user nest --name nest-docker-virtual \
                -v $LOCALDIR:/home/nest/data \
                -p 8080:8080 nest/docker-nest-"$2" /bin/bash
                echo
                ;;
                *)
                echo "Error: Unrecognized option '$1'"
                command=help
                ;;
            esac
            shift
        done
        ;;
        clean)
        echo
        echo "Stops ALL containers and delete ALL NEST Images."
        echo
        docker stop $(docker ps -a -q)
        docker images -a | grep "nest" | awk '{print $3}' | xargs docker rmi
        echo
        echo "Done!"
        echo
        echo "A list of the docker images on your machine:"
        docker images
        ;;
        help)
        echo
        cat $PARDIR/README.md
        echo
        ;;
        *)
        echo
        cat $PARDIR/README.md
        echo
        ;;
    esac

}


vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}
