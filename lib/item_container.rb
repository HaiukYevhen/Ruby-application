module HaiukApplication
  module ItemContainer

    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
      base.class_variable_set(:@@items_created, 0)
    end

    # ======================
    #  МЕТОДИ КЛАСУ
    # ======================
    module ClassMethods
      def class_info
        "Клас: #{self.name}, версія: 1.0"
      end

      def increment_counter
        class_variable_set(:@@items_created, class_variable_get(:@@items_created) + 1)
      end

      def items_created
        class_variable_get(:@@items_created)
      end
    end

    # ======================
    #  МЕТОДИ ЕКЗЕМПЛЯРА
    # ======================
    module InstanceMethods
      def add_item(item)
        @items << item
        HaiukApplication::LoggerManager.log_processed_file("Додано товар: #{item.name}")
      end

      def remove_item(item)
        @items.delete(item)
        HaiukApplication::LoggerManager.log_processed_file("Видалено товар: #{item.name}")
      end

      def delete_items
        @items.clear
        HaiukApplication::LoggerManager.log_processed_file("Колекцію очищено")
      end

      # Динамічний метод
      def method_missing(method_name, *args)
        if method_name == :show_all_items
          return @items.each { |i| puts i.info }
        end
        super
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name == :show_all_items || super
      end
    end

  end
end
