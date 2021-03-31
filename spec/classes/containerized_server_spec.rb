# frozen_string_literal: true

require 'spec_helper'

describe 'jitsi::containerized_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to compile
        is_expected.to contain_vcsrepo('/srv/jitsi/')
        is_expected.to contain_file('/srv/jitsi/.env')
        is_expected.to contain_exec('turn off jitsi')
        is_expected.to contain_exec('turn on jitsi')
        [
          '/srv/jitsi/.jitsi-meet-cfg/',
          '/srv/jitsi/.jitsi-meet-cfg/web',
          '/srv/jitsi/.jitsi-meet-cfg/jicofo',
          '/srv/jitsi/.jitsi-meet-cfg/jvb',
          '/srv/jitsi/.jitsi-meet-cfg/prosody',
          '/srv/jitsi/.jitsi-meet-cfg/prosody/config',
          '/srv/jitsi/.jitsi-meet-cfg/prosody/prosody-plugins-custom',
          '/srv/jitsi/.jitsi-meet-cfg/transcripts',
        ].each do |config_directory|
          is_expected.to contain_file(config_directory)
        end
        is_expected.to contain_exec('/usr/bin/rm -Rf /srv/jitsi/.jitsi-meet-cfg')
        is_expected.to contain_file('/srv/jitsi/.jitsi-meet-cfg/web/config.js')

        # check the content of the config file
        content = catalogue.resource(
          'file',
          '/srv/jitsi/.jitsi-meet-cfg/web/config.js',
        ).send(:parameters)[:content]
        expect(content).to match 'config.disableAP = false;'
        expect(content).to match 'config.disableAEC = false;'
        expect(content).to match 'config.disableNS = false;'
        expect(content).to match 'config.disableAGC = true;'
        expect(content).to match 'config.disableHPF = true;'

        # uncomment this for storing the generated catalogue
        # File.write(
        #   'containerized_server.json',
        #   PSON.pretty_generate(catalogue),
        # )
      end
    end
  end
end
