Open Video Digital Library Toolkit
==================================
The Open Video Digital Library Toolkit (OVDLT) project is intended to provide museums, libraries and other institutions holding moving image collections tools to more easily create Web-based digital video libraries. Funded by the Institute of Museum and Library Services and now released as an open source product under the MIT License, the OVDLT project provides a no cost solution for libraries, archives, museums, and other institutions who want to make available their digital video resources through their own Web-based digital library.

OVDLT runs on Linux or Mac OS X 10.5 and 10.6 based on a Ruby on Rails (version 2) framework with MySQL as the database management system.

License
------------------
The base OVDLT code is open source and available under the [MIT License](http://www.opensource.org/licenses/mit-license.php).

The OVSurGen video preview surrogate generator software requires the installation of  [FFmpeg](http://ffmpeg.org) licensed under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and dynamically links to the FFmpeg library.

Requirements
------------------
The base OVDLT product requires a basic Ruby on Rails with MySQL installation. Specifically, the following software should be installed on the server:

* Ruby 1.8.4 or higher (not tested with Ruby 1.9.x)
* RubyGems
* Ruby on Rails 2.3.5+ (not migrated to Rails 3.x)
* Apache or Nginx Web server. Deploying OVDLT with [Phusion Passenger](http://www.modrails.com/) is strongly recommended.
* MySQL 5.0.x or higher

If you don't have the software above currently installed, you might want to follow the documentation at the official [Ruby on Rails site](http://rubyonrails.org/download) to install and get a first Rails application up and running. It's pretty easy.

See the [OVDLT support site](http://ovdlt.tenderapp.com/faqs/installation/) for more on requirements, installation, and configuration.
