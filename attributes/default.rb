# frozen_string_literal: true

default['base_packages'] = %w[
  zip
  unzip
  curl
  openssh-server
  ca-certificates
  apt-transport-https
  awscli
  default-jre
  wget
  jq
  python
]
default['custom_packages']            = []

default['application']                = 'elasticsearch'
