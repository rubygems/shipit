# frozen_string_literal: true

# Monkey-patch Sprockets 3.7.2 to use keyword arguments for ERB.new,
# which is required by Ruby 4.0+ (positional args were removed).
# This can be removed once shipit-engine allows sprockets >= 4.
if RUBY_VERSION >= "4.0"
  module Sprockets
    class ERBProcessor
      def call(input)
        engine = ::ERB.new(input[:data], trim_mode: '<>')
        context = input[:environment].context_class.new(input)
        klass = (class << context; self; end)
        klass.class_eval(&@block) if @block
        engine.def_method(klass, :_evaluate_template, input[:filename])
        data = context._evaluate_template
        context.metadata.merge(data: data)
      end
    end
  end
end
