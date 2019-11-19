# frozen_string_literal: true

name             'elasticsearch_stack'
maintainer       'NETBEARS'
license          'All rights reserved'
description      'Installs/Configures elasticsearch_stack'
long_description 'Installs/Configures elasticsearch_stack'
version          '1.1.0'

depends 'build-essential', '~> 8.0.3'
depends 'poise-service', '~> 1.5.2'
depends 'ntp', '~> 3.5.1'
depends 'logrotate', '~> 2.2.0'
depends 'seven_zip', '~> 2.0.2'
depends 'windows', '~> 3.4.0'

supports 'ubuntu'
