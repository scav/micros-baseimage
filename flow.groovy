stage 'inital'

node('docker-image-builder'){

  def docker = new com.vimond.workflow.Docker()

  docker.buildTagPush('micros-baseimage')
    
  }