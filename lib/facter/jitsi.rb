#!/usr/bin/ruby -w

Facter.add(:jitsi, :type => :aggregate) do
  if File.exist? '/usr/bin/docker'
    docker_output = Facter::Core::Execution.execute('docker ps | grep jitsi/web')[/stable-[^\s]*/]
  else
    docker_output = nil
  end

  chunk(:installed) do
    if File.exist? '/srv/jitsi'
      jitsi = {:installed => true}
    else
      jitsi = {:installed => false}
    end
    jitsi
  end

  chunk(:running) do
    if docker_output == nil
      jitsi = {:running => false}
    else
      jitsi = {:running => true}
    end
    jitsi
  end

  chunk(:version) do
    if docker_output == nil
      jitsi = {:version => "0.0.0"}
    else
      jitsi = {:version => docker_output}
    end
    jitsi
  end
end

