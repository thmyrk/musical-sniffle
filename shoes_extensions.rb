class Shoes
  module Types
    class Stack
      def get_first_element_of_class(klass)
        contents.select { |el| el.is_a?(klass) }[0]
      end
    end
  end
end
