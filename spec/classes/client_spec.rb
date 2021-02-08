# frozen_string_literal: true

require 'spec_helper'

describe 'jitsi::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to compile
        is_expected.to contain_remote_file('jitsi_AppImage')
        is_expected.to contain_file('/usr/local/bin/jitsi').with(
          'target' => '/usr/local/bin/jitsi-meet-x86_64.AppImage',
        )
      end
    end
  end
end
