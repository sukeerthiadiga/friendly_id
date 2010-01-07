require File.join(File.dirname(__FILE__), "friendly_id", "helpers")
require File.join(File.dirname(__FILE__), "friendly_id", "slug")
require File.join(File.dirname(__FILE__), "friendly_id", "slug_string")
require File.join(File.dirname(__FILE__), "friendly_id", "config")
require File.join(File.dirname(__FILE__), "friendly_id", "slugged", "finder")
require File.join(File.dirname(__FILE__), "friendly_id", "slugged", "class_methods")
require File.join(File.dirname(__FILE__), "friendly_id", "slugged", "instance_methods")
require File.join(File.dirname(__FILE__), "friendly_id", "simple", "class_methods")
require File.join(File.dirname(__FILE__), "friendly_id", "simple", "instance_methods")

# FriendlyId is a comprehensive Ruby library for slugging and permalinks with
# ActiveRecord.
# @author Norman Clarke
# @author Emilio Tagua
# @author Adrian Mugnolo
module FriendlyId


  # This error is raised when it's not possible to generate a unique slug.
  class SlugGenerationError < StandardError ; end

  # Set up a model to use a friendly_id. This method accepts a hash with
  # {FriendlyId::Config several possible options}.
  #
  # @param [#to_sym] method The column or method that should be used as the
  #   basis of the friendly_id string.
  #
  # @param [Hash] options For valid configuration options, see
  #   {FriendlyId::Config}.
  #
  # @param [block] block An optional block through which to filter the
  #   friendly_id text; see {FriendlyId::Config#normalizer}. Note that
  #   passing a block parameter is now deprecated and will be removed
  #   from FriendlyId 3.0.
  #
  # @example
  #
  #   class User < ActiveRecord::Base
  #     has_friendly_id :user_name
  #   end
  #
  #   class Post < ActiveRecord::Base
  #     has_friendly_id :title, :use_slug => true, :approximate_ascii => true
  #   end
  #
  def has_friendly_id(method, options = {}, &block)
    class_inheritable_accessor :friendly_id_config
    write_inheritable_attribute :friendly_id_config, Config.new(self.class,
      method, options.merge(:normalizer => block))
    load_adapters
  end

  # Parse the sequence and slug name from a friendly_id string.
  def self.parse_friendly_id(string)
    name, sequence = string.split('--')
    sequence ||= "1"
    return name, sequence
  end


  private

  def load_adapters
    if friendly_id_config.use_slug?
      extend Slugged::ClassMethods
      include Slugged::InstanceMethods
    else
      extend Simple::ClassMethods
      include Simple::InstanceMethods
    end
  end

end

# {FriendlyId#has_friendly_id has_friendly_id} is available to all subclasses of
# ActiveRecord::Base.
class ActiveRecord::Base
  extend FriendlyId
end
