# SidekiqSingle
[ ![Codeship Status for tzachi_fraiman/sidekiq_rejector](https://codeship.com/projects/f57d0400-523a-0133-84fa-3289b2b41ce8/status?branch=master)](https://codeship.com/projects/108052) [![Code Climate](https://codeclimate.com/github/TzachiF/sidekiq_single/badges/gpa.svg)](https://codeclimate.com/github/TzachiF/sidekiq_single) [![Test Coverage](https://codeclimate.com/github/TzachiF/sidekiq_single/badges/coverage.svg)](https://codeclimate.com/github/TzachiF/sidekiq_single/coverage)  
A way to allow a queue to be consumed job by job at any point in time, no matter if there are several processes and each process is using several threads. It will not allow more than one job to run at any given time. the jobs will be exceuted in the same order that they were queued.

## Requirements

Only sidekiq 3 is supported.  
Only basic sidekiq is supported (Pro is not supported!)  
Multiple Redis instances are NOT supported.  
Retries of jobs is NOT supported.  

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_single'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_single

## Usage
When creating a sidekiq worker it should be using a queue with sidekiq_single as a prefix.
```ruby
sidekiq_options queue: :sidekiq_single_my_queue
```
That's all. now the jobs from this queue will be consumed on at a time. don't forget to update the queue in the sidekiq.yaml file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors
- https://github.com/tzachif

### License and Copyrights  
See license for this gem.  

This gem make use of leandromoreira/redlock-rb gem/code.  
Terms of use for leandromoreira/redlock-rb are as follows:  

Copyright (c) 2014-2015, Salvatore Sanfilippo <antirez at gmail dot com>
Copyright (c) 2014-2015, Leandro Moreira <leandro dot ribeiro dot moreira at gmail dot com>
Copyright (c) 2015,      Malte Rohde <malte dot rohde at flavoursys dot com>

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
