require 'scalarm/database/utils'

module Scalarm
  module Database
    module MongoActiveRecordUtils
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def attr_join(attribute_name, attribute_class, params={})
          # use cache by default
          params[:cached] = true unless params.include? :cached
          if params[:cached]
            define_method attribute_name do
              cached = instance_variable_get("@#{attribute_name}")
              unless cached
                attribute_id = self.send("#{attribute_name}_id")
                cached = attribute_id ? attribute_class.find_by_id(attribute_id) : nil
                instance_variable_set("@#{attribute_name}", cached)
              end
              cached
            end
          else
            define_method attribute_name do
              attribute_id = self.send("#{attribute_name}_id")
              attribute_id ? attribute_class.find_by_id(attribute_id) : nil
            end
          end
        end

        def use_collection(name)
          define_singleton_method :collection_name do
            name
          end
        end

        def parse_json_if_string(attribute)
          define_method attribute do
            Utils::parse_json_if_string(get_attribute(attribute.to_s))
          end
        end

        def create_index(attribute)
          @_indexed_attributes << attribute
          # puts "Create index: #{attribute} - #{@_indexed_attributes}"
        end

        def inherited(subclass)
          instance_var = "@_indexed_attributes"
          subclass.instance_variable_set(instance_var, [])
        end

      end
    end
  end
end
