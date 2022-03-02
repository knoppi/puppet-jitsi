#!/usr/bin/ruby -w

Facter.add(:jitsi, type: :aggregate) do
  docker_output = if File.exist? '/usr/bin/docker'
                    Facter::Core::Execution.execute('docker ps | grep jitsi/web')[/stable-[^\s]*/]
                  else
                    nil
                  end

  chunk(:installed) do
    jitsi = if File.exist? '/srv/jitsi'
              { installed: true }
            else
              { installed: false }
            end
    jitsi
  end

  chunk(:running) do
    jitsi = if docker_output.nil?
              { running: false }
            else
              { running: true }
            end
    jitsi
  end

  chunk(:version) do
    jitsi = if docker_output.nil?
              { version: '0.0.0' }
            else
              { version: docker_output }
            end
    jitsi
  end
end
