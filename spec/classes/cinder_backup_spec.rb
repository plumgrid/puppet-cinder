#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cinder::backup class
#

require 'spec_helper'

describe 'cinder::backup' do

  let :default_params do
    { :enable               => true,
      :backup_topic         => '<SERVICE DEFAULT>',
      :backup_manager       => '<SERVICE DEFAULT>',
      :backup_api_class     => '<SERVICE DEFAULT>',
      :backup_name_template => '<SERVICE DEFAULT>' }
  end

  let :params do
    {}
  end

  shared_examples_for 'cinder backup' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('cinder::params') }

    it 'installs cinder backup package' do
      if platform_params.has_key?(:backup_package)
        is_expected.to contain_package('cinder-backup').with(
          :name   => platform_params[:backup_package],
          :ensure => 'present',
          :tag    => ['openstack', 'cinder-package'],
        )
        is_expected.to contain_package('cinder-backup').with_before(/Service\[cinder-backup\]/)
      end
    end

    it 'ensure cinder backup service is running' do
      is_expected.to contain_service('cinder-backup').with(
        'hasstatus' => true,
        'tag'       => 'cinder-service',
      )
    end

    it 'configures cinder.conf' do
      is_expected.to contain_cinder_config('DEFAULT/backup_topic').with_value(p[:backup_topic])
      is_expected.to contain_cinder_config('DEFAULT/backup_manager').with_value(p[:backup_manager])
      is_expected.to contain_cinder_config('DEFAULT/backup_api_class').with_value(p[:backup_api_class])
      is_expected.to contain_cinder_config('DEFAULT/backup_name_template').with_value(p[:backup_name_template])
    end

    context 'when overriding backup_name_template' do
      before :each do
        params.merge!(:backup_name_template => 'foo-bar-%s')
      end
      it 'should replace default parameter with new value' do
        is_expected.to contain_cinder_config('DEFAULT/backup_name_template').with_value(p[:backup_name_template])
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge!({ :osfamily => 'Debian' })
    end

    let :platform_params do
      { :backup_package => 'cinder-backup',
        :backup_service => 'cinder-backup' }
    end

    it_configures 'cinder backup'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge!({ :osfamily => 'RedHat' })
    end

    let :platform_params do
      { :backup_service => 'opentack-cinder-backup' }
    end

    it_configures 'cinder backup'
  end

end
