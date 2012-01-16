module ActionController
  # Action Controller Serialization
  #
  # Overrides render :json to check if the given object implements +active_model_serializer+
  # as a method. If so, use the returned serializer instead of calling +to_json+ in the object.
  #
  # This module also provides a serialization_scope method that allows you to configure the
  # +serialization_scope+ of the serializer. Most apps will likely set the +serialization_scope+
  # to the current user:
  #
  #    class ApplicationController < ActionController::Base
  #      serialization_scope :current_user
  #    end
  #
  # If you need more complex scope rules, you can simply override the serialization_scope:
  #
  #    class ApplicationController < ActionController::Base
  #      private
  #
  #      def serialization_scope
  #        current_user
  #      end
  #    end
  #
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_account
    end

    def serialization_scope
      send(_serialization_scope)
    end

    def default_serializer_options
    end

    def _render_option_json(json, options)
      # if json.respond_to?(:to_ary)
      #   options[:root] ||= controller_name
      # end

      if json.respond_to?(:active_model_serializer) && (serializer = json.active_model_serializer)
        options[:scope] = serialization_scope

        if default_options = default_serializer_options
          options = options.merge(default_options)
        end

        json = serializer.new(json, options)
      end
      super
    end

    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end
  end
end
