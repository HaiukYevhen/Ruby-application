require "json"
require "csv"
require "yaml"

module HaiukApplication
  class ItemCollection
    include ItemContainer
    include Enumerable

    attr_reader :items

    def initialize
      @items = []
      HaiukApplication::LoggerManager.log_processed_file("Створено порожню колекцію ItemCollection")
    end

    # ======================
    # ENUMERABLE
    # ======================
    def each(&block)
      @items.each(&block)
    end

    # ======================
    # ЗБЕРЕЖЕННЯ У ФАЙЛИ
    # ======================

    def save_to_file(path = "output/items.txt")
      File.open(path, "w") do |f|
        @items.each { |item| f.puts item.to_s }
      end
      HaiukApplication::LoggerManager.log_processed_file("Збережено у текстовий файл: #{path}")
    end

    def save_to_json(path = "output/items.json")
      data = @items.map(&:to_h)
      File.write(path, JSON.pretty_generate(data))
      HaiukApplication::LoggerManager.log_processed_file("Збережено у JSON файл: #{path}")
    end

    def save_to_csv(path = "output/items.csv")
      CSV.open(path, "w") do |csv|
        csv << @items.first.to_h.keys
        @items.each { |item| csv << item.to_h.values }
      end
      HaiukApplication::LoggerManager.log_processed_file("Збережено у CSV файл: #{path}")
    end

    def save_to_yml(directory = "output/yml_items")
      Dir.mkdir(directory) unless Dir.exist?(directory)

      @items.each_with_index do |item, i|
        File.write("#{directory}/item_#{i + 1}.yaml", item.to_h.to_yaml)
      end

      HaiukApplication::LoggerManager.log_processed_file("Збережено YAML-файли у папку #{directory}")
    end

    # ======================
    # Генерація тестових даних
    # ======================
    def generate_test_items(count = 5)
      count.times do
        item = HaiukApplication::Item.generate_fake
        add_item(item)
        HaiukApplication::ItemCollection.increment_counter
      end
    end

    # ======================
    # Методи Enumerable
    # ======================
    def find_by_name(name)
      find { |item| item.name == name }
    end

    def total_price
      reduce(0) { |sum, item| sum + item.price.to_f }
    end

    def items_more_than(price)
      select { |item| item.price.to_f > price }
    end

    def unique_categories
      map(&:category).uniq
    end

  end
end
