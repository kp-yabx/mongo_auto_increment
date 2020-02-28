This gem for change Mongoid id field as Integer like MySQL.

Idea from MongoDB document: [How to Make an Auto Incrementing Field](http://www.mongodb.org/display/DOCS/How+to+Make+an+Auto+Incrementing+Field)


## Status
- ![Ruby Gem](https://github.com/guptalakshya92/mongo_auto_increment/workflows/Ruby%20Gem/badge.svg)
- [![Gem Version](https://badge.fury.io/rb/mongo_auto_increment.svg)](https://rubygems.org/gems/mongo_auto_increment)

## Installation

```ruby
gem 'mongo_auto_increment', "0.1.0"
```

## Configure

If you want use sequence cache to reduce MongoDB write, you can enable cache:

config/initializes/mongoid_auto_increment_id.rb

```ruby
# MongoAutoIncrement.cache_store = ActiveSupport::Cache::MemoryStore.new
# First call will generate 200 ids and caching in cache_store
# Then the next 199 ids will return from cache_store
# Until 200 ids used, it will generate next 200 ids again.
MongoAutoIncrement.seq_cache_size = 200
```

> NOTE: 1) mongo_auto_increment is very fast in default config, you may don't need enable that, if you project not need insert huge rows in a moment.
        2) The ID generated will be ***64-bit combination of Timestamp and above sequence*** so that it will be unique in cluster mode and index will also work. ex: Model.last and Model.first
        


## USAGE

```ruby
ruby > post = Post.new(:title => "Hello world")
 => #<Post _id: 1582902420, _type: nil, title: "Hello world", body: nil>
ruby > post.save
 => true
ruby > post.inspect
 => "#<Post _id: 1582902420, _type: nil, title: \"Hello world\", body: nil>"
ruby > Post.find("1582902420")
 => "#<Post _id: 1582902420, _type: nil, title: \"Hello world\", body: nil>"
ruby > Post.find(1582902420)
 => "#<Post _id: 1582902420, _type: nil, title: \"Hello world\", body: nil>"
ruby > Post.desc(:_id).all.to_a.collect { |row| row.id }
 => [1582902420, 1582886820, 1582886818, 1582886729, 1582886728, 1582886722, 1582886720, 1582886714, 1582886696]
```


## Performance

This is a branchmark results run in MacBook Pro Retina.

with `mongoid_auto_increment_id`:

```
       user     system      total        real
Generate 1  0.000000   0.000000   0.000000 (  0.004301)
Post current: 1

Generate 100  0.070000   0.000000   0.070000 (  0.091638)
Post current: 101

Generate 10,000  7.300000   0.570000   7.870000 (  9.962469)
Post current: 10101
```

without:

```
       user     system      total        real
Generate 1  0.000000   0.000000   0.000000 (  0.002569)
Post current: 1

Generate 100  0.050000   0.000000   0.050000 (  0.052045)
Post current: 101

Generate 10,000  5.220000   0.170000   5.390000 (  5.389207)
Post current: 10101
```
