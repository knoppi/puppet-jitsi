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
        # is_expected.to contain_file('/srv/jitsi/.jitsi-meet-cfg/web/config.js')
        is_expected.to contain_service('jitsi')
        is_expected.to contain_systemd__unit_file('jitsi.service')
        is_expected.to contain_notify('Need to restart jitsi because there is a version change.')

        # check the content of the config file
        # content = catalogue.resource(
        #   'file',
        #   '/srv/jitsi/.jitsi-meet-cfg/web/config.js',
        # ).send(:parameters)[:content]
        # expect(content).to match 'config.disableAP = false;'
        # expect(content).to match 'config.disableAEC = false;'
        # expect(content).to match 'config.disableNS = false;'
        # expect(content).to match 'config.disableAGC = true;'
        # expect(content).to match 'config.disableHPF = true;'

        # check the content of the env file
        content_env = catalogue.resource(
          'file',
          '/srv/jitsi/.env',
        ).send(:parameters)[:content]
        expect(content_env).to match 'JICOFO_COMPONENT_SECRET=JICOFO_COMPONENT_SECRET'
        expect(content_env).to match 'JICOFO_AUTH_PASSWORD=JICOFO_AUTH_PASSWORD'
        expect(content_env).to match 'JVB_AUTH_PASSWORD=JVB_AUTH_PASSWORD'
        expect(content_env).to match 'JIGASI_XMPP_PASSWORD=JIGASI_XMPP_PASSWORD'
        expect(content_env).to match 'JIBRI_RECORDER_PASSWORD=JIBRI_RECORDER_PASSWORD'
        expect(content_env).to match 'JIBRI_XMPP_PASSWORD=JIBRI_XMPP_PASSWORD'

        # uncomment this for storing the generated catalogue
        # File.write(
        #   'containerized_server.json',
        #   PSON.pretty_generate(catalogue),
        # )
      end
    end
  end
end
