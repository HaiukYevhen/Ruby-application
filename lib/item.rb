require "faker"

module HaiukApplication
  class Item
    include Comparable

    attr_accessor :name, :price, :description, :category, :image_path

    # =========================
    #   ІНІЦІАЛІЗАТОР
    # =========================
    def initialize(params = {})
      @name        = params[:name]        || "Невідомий товар"
      @price       = params[:price]       || 0
      @description = params[:description] || "Немає опису"
      @category    = params[:category]    || "Без категорії"
      @image_path  = params[:image_path]  || "media/default.png"

      # Налаштування через блок
      yield(self) if block_given?

      # Логування
      begin
        HaiukApplication::LoggerManager.log_processed_file("Створено Item: #{@name}")
      rescue => e
        puts "Помилка логування: #{e.message}"
      end
    end

    # =========================
    #  ПОРІВНЯННЯ ДЛЯ Comparable
    # =========================
    def <=>(other)
      price <=> other.price
    end

    # =========================
    #  МЕТОД to_s
    # =========================
    def to_s
      begin
        result = "Item:\n"
        instance_variables.each do |var|
          result += "  #{var.to_s.delete('@')}: #{instance_variable_get(var)}\n"
        end
        result
      rescue => e
        HaiukApplication::LoggerManager.log_error("Помилка в to_s: #{e.message}")
        "Помилка відображення об'єкта"
      end
    end

    # =========================
    #  МЕТОД to_h
    # =========================
    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
      end
    end

    # =========================
    #  МЕТОД inspect
    # =========================
    def inspect
      "#<Item name='#{name}', price=#{price}, category='#{category}'>"
    end

    # =========================
    #  UPDATE
    # =========================
    def update
      raise ArgumentError, "Потрібно передати блок" unless block_given?
      yield(self)

      HaiukApplication::LoggerManager.log_processed_file("Item оновлено: #{@name}")
    end

    # =========================
    #  АЛІАС info
    # =========================
    alias_method :info, :to_s

    # =========================
    #   Генерація фейкових даних
    # =========================
    def self.generate_fake
      item = new(
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price(range: 50..1000),
        description: Faker::Lorem.paragraph(sentence_count: 3),
        category: Faker::Commerce.department(max: 1),
        image_path: "media/#{Faker::File.file_name(dir: 'products', ext: 'jpg')}"
      )

      HaiukApplication::LoggerManager.log_processed_file("Згенеровано фейковий Item: #{item.name}")

      item
    end
  end
end
