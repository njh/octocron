Octocron
========

This repo contains a set of ruby scripts for working with the UK [Octopus Energy Smart Tariffs].
I wanted something that was easy to run and adapt and didn't request a persistent process running.

It was built and tested using Ruby version 3.3.0 but it should work fine with other versions of ruby.



Installation
------------

Install [ruby] and [bundler], then install the gem dependencies:
```
bundle install
```

Copy the example configuration file and edit it:
```
cp config.yml.example config.yml
vim config.yml
```

Then you can start running the scripts below.
The API Key and account number are only needed if the script uses consumption data or account information.


Scripts
-------

*account-info.rb*
The script 


*electricity-agile-check.rb*


*gas-tracker-check.rb*


*list-products.rb*


*octopus-api.rb*




Running Periodically with Cron
------------------------------

Once you are happy with running the scripts manually, you can then configure [cron] to
run them automatically at your desired times.

```
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# For more information see the manual pages of crontab(5) and cron(8)

MAILTO=me@example.com

# m h  dom mon dow   command
13  2  *   *   *     cd ~/octocron/ && ./electricity-agile-check.rb > /dev/null
15  2  *   *   *     cd ~/octocron/ && ./gas-tracker-check.rb > /dev/null
```

In this example we run the scripts that check the electricity and tariffs at 2:13 and 2:15 respectively, every day.
By piping the stdout to `/dev/null`, you will only get an email if someone goes wrong,
or something is written to stderr - such as an alert that the gas tracker rate has got expensive!

