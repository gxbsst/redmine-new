# RedmineCrm

Gem include next functional for Redmine plugins:
  * rcrm_acts_as_taggable
  * rcrm_acts_as_votable
  * rcrm_acts_as_viewable

## Installation

Add this line to your application's Gemfile:

```ruby
gem "redmine_crm"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redmine_crm

Create migration with next code:
```ruby
  require 'redmine_crm/rcrm_acts_as_taggable'

  def self.up
    ActiveRecord::Base.create_taggable_table
  end

  def self.down
    ActiveRecord::Base.drop_taggable_table
  end
end
```
For rcrm_acts_as_viewed You may add column for your model
with help:

```ruby

YourModel.add_viewings_columns

```
It will add two column to your table (views and total_views) 
and view_count will return two number: total view and unique views.
Without this migration you will get only unique views.

Run migration for plugin:

```
rake redmine:plugins:migrate
```

## Usage

Add to model

```ruby
  rcrm_acts_as_taggable
  rcrm_acts_as_votable
```


## Run test

```
  rake test
```

For test for mysql set enviroment variable DB to value 'mysql' and run test.