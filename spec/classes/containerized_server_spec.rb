# frozen_string_literal: true

require 'spec_helper'

describe 'jitsi::containerized_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to compile
        is_expected.to contain_vcsrepo('/srv/jitsi/')
        is_expected.to contain_file('/src/jitsi/.env')
        # is_expected.to contain_docker_compose('jitsi')
      end
    end
  end
end
