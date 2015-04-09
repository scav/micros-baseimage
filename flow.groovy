stage 'inital'

node('docker-image-builder'){

  def docker = new com.vimond.workflow.Docker()

    docker.buildTagPush('vimond.artifactoryonline.com/micros-baseimage')
    
  }