require "mongoid"
require 'active_support/all'
require "mongo_auto_increment/version"
require "mongo_auto_increment/config"

module MongoAutoIncrement
  class Error < StandardError; end
  # Your code goes here...

  class Identity
    MAII_TABLE_NAME = 'auto_increment_ids'.freeze

    class << self

      # Generate auto increment id
      # params:
      def generate_id(document)
        if MongoAutoIncrement.cache_enabled?
          cache_key = self.maii_cache_key(document)
          if ids = MongoAutoIncrement.cache_store.read(cache_key)
            cached_id = self.shift_id(ids, cache_key)
            return self.generated_token(cached_id) if !cached_id.blank?
          end
        end

        opts = {
            findAndModify: MAII_TABLE_NAME,
            query: { _id: document.collection_name },
            update: { '$inc' => { c: MongoAutoIncrement.seq_cache_size } },
            upsert: true,
            new: true
        }
        o = Mongoid.default_client.database.command(opts, {})

        last_seq = o.documents[0]['value']['c'].to_i

        if MongoAutoIncrement.cache_enabled?
          ids = ((last_seq - MongoAutoIncrement.seq_cache_size) + 1 .. last_seq).to_a
          self.generated_token(self.shift_id(ids, cache_key))
        else
          self.generated_token(last_seq)
        end
      end

      def generated_token(cache_key)
        return DateTime.now.strftime("%Q").to_i + cache_key
      end

      def shift_id(ids, cache_key)
        return nil if ids.blank?
        first_id = ids.shift
        MongoAutoIncrement.cache_store.write(cache_key, ids)
        first_id
      end

      def maii_cache_key(document)
        "maii-seqs-#{document.collection_name}"
      end
    end
  end

  module Mongoid::Document
    ID_FIELD = '_id'.freeze

    def self.included(base)
      base.class_eval do
        # define Integer for id field
        Mongoid.register_model(self)
        field :_id, type: Integer, overwrite: true, default: -> {Identity.generate_id(self)}
      end
    end

    # hack id nil when Document.new
    def identify
      Identity.new(self).create
      nil
    end

    alias_method :super_as_document, :as_document
    def as_document
      result = super_as_document
      if result[ID_FIELD].blank?
        result[ID_FIELD] = Identity.generate_id(self)
      end
      result
    end
  end
end
