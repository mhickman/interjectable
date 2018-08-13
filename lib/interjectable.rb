require "interjectable/version"

module Interjectable
  def self.included(mod)
    mod.send(:extend, ClassMethods)
  end

  def self.extended(mod)
    mod.send(:extend, ClassMethods)
  end

  module ClassMethods
    # Defines a helper methods on instances that memoize values per-instance.
    # Similar to writing
    #
    #   attr_writer :dependency
    #
    #   def dependency
    #     @dependency ||= instance_eval(&default_block)
    #   end
    def inject(dependency, &default_block)
      attr_writer dependency

      define_method(dependency) do
        ivar_name = "@#{dependency}"
        if instance_variable_defined?(ivar_name)
          instance_variable_get(ivar_name)
        else
          instance_variable_set(ivar_name, instance_eval(&default_block))
        end
      end
    end

    # Defines helper methods on instances that memoize values per-class.
    # (shared across all instances of a class, including instances of subclasses).
    #
    # Calling a second time clears the value (if set) from previous times. This should
    # probably only be called a second time in tests.
    #
    # Similar to writing
    #
    #   cattr_writer :dependency
    #
    #   def dependency
    #     @@dependency ||= instance_eval(&default_block)
    #   end
    def inject_static(dependency, &default_block)
      cvar_name = "@@#{dependency}"
      remove_class_variable(cvar_name) if class_variable_defined?(cvar_name)

      define_method("#{dependency}=") do |value|
        self.class.class_variable_set(cvar_name, value)
      end

      define_method(dependency) do
        if self.class.class_variable_defined?(cvar_name)
          self.class.class_variable_get(cvar_name)
        else
          self.class.class_variable_set(cvar_name, instance_eval(&default_block))
        end
      end
    end
  end
end
