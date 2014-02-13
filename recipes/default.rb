#
# Cookbook Name:: amanda
# Recipe:: default
#
# Copyright (c) 2014, The University of Queensland
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# * Neither the name of the The University of Queensland nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE UNIVERSITY OF QUEENSLAND BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Requires GNU tar 1.15 or later.
# Requires Perl version 5.6.0 or later
# Requires Glib 2.2.0 or later
# Requires GNUplot and Awk (for amplot)
# Requires readline library.

amanda_dir = node['amanda']['amanda_dir']

if platform_family?('rhel', 'fedora', 'debian') then
  if node['amanda']['install_client'] then
    package 'amanda-server' do
      action :install
    end
  end
  if node['amanda']['install_server'] then
    package 'amanda-client' do
      action :install
    end
  end
elsif platform_family?('suse') then
  package 'amanda' do
    action :install
  end
else 
  raise 'Teach me about your platform ...'
end

if platform_family?('fedora') then
  amanda_user = 'amandabackup'
else 
  raise 'Teach me about your platform ...'
end

['vtapes/1','vtapes/2','vtapes/3','vtapes/4',
 'holding', 'state/curinfo', 'state/log', 'state/index'].each do |d|
  dir = "#{amanda_dir}/#{d}"
  directory dir do
    owner amanda_user
    recursive true
  end
end

directory "/etc/amanda/#{config_name}" do
  owner amanda_user
  recursive true
end

template "/etc/amanda/#{config_name}/amanda.conf" do
  source "amanda_conf.erb"
  owner amanda_user
  mode 0644
  variables ({
               'config_name' => config_name,
               'amanda_user' => amanda_user,
               'amanda_dir' => amanda_dir,
               'label' => 'MyData'
             })
end

cookbook_file "/etc/amanda/#{config_name}/disklist" do
  source "disklist"
  owner amanda_user
  mode 0644
end
