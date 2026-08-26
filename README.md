![Build Status](https://github.com/voxpupuli/puppet-trusted_ca/actions/workflows/ci.yml/badge.svg?branch=master)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-trusted_ca/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-trusted_ca)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/trusted_ca.svg)](https://forge.puppetlabs.com/puppet/trusted_ca)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/trusted_ca.svg)](https://forge.puppetlabs.com/puppet/trusted_ca)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/trusted_ca.svg)](https://forge.puppetlabs.com/puppet/trusted_ca)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/trusted_ca.svg)](https://forge.puppetlabs.com/puppet/trusted_ca)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with trusted_ca](#setup)
    * [What trusted_ca affects](#what-trusted_ca-affects)
    * [Beginning with trusted_ca](#beginning-with-trusted_ca)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Changelog/Contributors](#changelog-contributors)

## Overview

A puppet module to manage the distribution's trusted certificates and install trusted SSL certificates into the system's trusted keystore and java's keystore's.

## Module Description

Many organizations use self-signed SSL certificates for internal services that need to be trusted by other hosts.  This puppet module will install SSL certificates into a host's system-wide trusted CA files (which are used by distribution-provided java packages) as well as a define for installing certificates into java installations not provided by the distribution.

## Setup

### What trusted_ca affects

* Distribution-provided trusted SSL certificates package
* System-wide additional trusted SSL certificates
* SSL certificates installed into java trusted certificate keystore

### Beginning with trusted_ca

To install trusted_ca

```
    puppet module install puppet-trusted_ca
```

Dependencies:

* puppetlabs/stdlib

## Usage

Manage only distribution-specific trusted certificates

```puppet
    class { 'trusted_ca': }
```

Install a self-signed SSL certificate into the system's global trusted keystore from a source file

```puppet
    class { 'trusted_ca': }
    trusted_ca::ca { 'mycompany.org':
      source => 'puppet:///ssl/mycompany.org.crt',
    }
```

Install a self-signed SSL certificate into a java keystore from a source file

```puppet
    class { 'trusted_ca': }
    trusted_ca::java { 'mycompany.org':
      source => 'puppet:///ssl/mycompany.org/crt',
      java_keystore => '/usr/local/java/lib/security/cacerts',
    }
```

Install a certificate into the system's global trusted keystore from a PEM-encoded string (eg from hiera)

```puppet
    class { 'trusted_ca': }
    trusted_ca::ca { 'example.net':
      content => lookup('example-net-x509'),
    }
```

## Reference

Reference documentation for the trusted_ca module is generated using [puppet-strings](https://docs.openvoxproject.org/openvox/latest/openvox_strings.html) and available in [REFERENCE.md](REFERENCE.md)

## Limitations

Tested on:
* EL 6
* EL 7
* Debian 8
* Debian 9
* SLES 11 SP3
* SLES 12 SP4
* SLES 15 SP1
* Ubuntu 16.04 LTS
* Ubuntu 18.04 LTS

This module assumes the keytool and openssl utilities are available.

## Development

Improvements and bug fixes are greatly appreciated.  See the [contributing guide](https://github.com/voxpupuli/puppet-trusted_ca/blob/master/CONTRIBUTING.md) for
information on adding and validating tests for PRs.

## Changelog / Contributors

This module was originally known as jlambert121/trusted_ca but forked to Voxpupuli because the original author no longer responded.

[Changelog](https://github.com/voxpupuli/puppet-trusted_ca/blob/master/CHANGELOG)
[Contributors](https://github.com/voxpupuli/trusted_ca/graphs/contributors)
