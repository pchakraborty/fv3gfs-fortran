#!/bin/bash

# Set variable to allow parallel building in the Docker image creation
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

# Get the dockerfiles for the images to be tested on Piz Daint
dockerfiles=( $( ls docker/Dockerfile.* ) )

for df in ${dockerfiles[@]}; do
   # Grab the architecture tag from the dockerfile filename
   arch=${df:18}

   # Set the names of the new Docker image and tar file
   container=us.gcr.io/vcm-ml/fv3gfs-compiled:$arch
   tar_file=fv3gfs-compiled_${arch}.tar
   
   # Build the docker image and push image to VCM's Google Container Repository
   docker build -f $df --target fv3-bld -t $container .
   docker push $container

   # Copy an archived version of the image to a public Google Storage Bucket
   docker save $container -o $tar_file
   gzip $tar_file
   gsutil copy ${tar_file}.gz gs://vcm-jenkins/${tar_file}.gz
done
