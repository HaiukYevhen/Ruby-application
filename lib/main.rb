require "httparty"
require "nokogiri"
require "json"
require "csv"
require_relative "../lib/app_config_loader"
require_relative "../lib/logger_manager"
require_relative "../lib/item"
require_relative "../lib/item_container"
require_relative "../lib/item_collection"

include HaiukApplication
# 2. Завантаження конфігів
config = AppConfigLoader.config(
  "config/yaml_config/default_config.yaml",
  "config/yaml_config"
)

# Перевірка
AppConfigLoader.pretty_print_config_data

LoggerManager.setup(config)
LoggerManager.log_processed_file("Конфігурації успішно завантажені.")
LoggerManager.log_error("Це тестове повідомлення про помилку.")

# ============= ТЕСТ ЕТАПУ 3.2 =============
puts "\n=== ТЕСТ ItemCollection ==="
cart = HaiukApplication::ItemCollection.new

cart.generate_test_items(3)
cart.show_all_items

puts "\n=== Тест Enumerable ==="
puts "Загальна сума: #{cart.total_price}"
puts "Унікальні категорії: #{cart.unique_categories}"

expensive = cart.items_more_than(200)
puts "\nТовари дорожчі за 200:"
expensive.each { |i| puts i.name }

cart.save_to_json
cart.save_to_csv
cart.save_to_file
cart.save_to_yml

# ============= ТЕСТ 3.2 ВИДАЛЕННЯ АЙТЕМА =============
# puts "\n=== ТЕСТ ВИДАЛЕННЯ АЙТЕМА ==="

# puts "Початкова колекція:"
# cart.show_all_items

# item_to_remove = cart.items.first

# if item_to_remove
#   puts "\nВидаляємо айтем: #{item_to_remove.name}"
  
#   cart.remove_item(item_to_remove)
  
#   puts "\nКолекція після видалення:"
#   cart.show_all_items
  
#   puts "\nКількість айтемів після видалення: #{cart.items.count}"
# else
#   puts "Немає айтемів для видалення"
# end

# puts "\n=== ТЕСТ ОЧИЩЕННЯ ВСІЄЇ КОЛЕКЦІЇ ==="
# puts "Кількість айтемів перед очищенням: #{cart.items.count}"
# cart.delete_items
# puts "Кількість айтемів після очищення: #{cart.items.count}"

# puts "Колекція після очищення:"
# cart.show_all_items


# ============= ТЕСТ ЕТАПУ 3.1 =============
# puts "\n=== Тест створення Item ==="
# item1 = HaiukApplication::Item.new(name: "Молоко", price: 40) do |i|
#   i.category = "Продукти"
#   i.description = "Свіже фермерське молоко"
# end
# puts item1.info

# puts "\n=== Тест update ==="
# item1.update do |i|
#   i.price = 55
# end
# puts item1.info

# puts "\n=== Тест generate_fake ==="
# fake_item = HaiukApplication::Item.generate_fake
# puts fake_item.info

# puts "\n=== Тест Comparable ==="
# item2 = HaiukApplication::Item.new(price: 100)
# puts "Дешевше?" if item1 < item2


URL = "https://quotes.toscrape.com/"

def fetch_page(url)
  response = HTTParty.get(url)
  Nokogiri::HTML(response.body)
end

def parse_quotes
  page = fetch_page(URL)
  quotes = []

  page.css(".quote").each do |q|
    quotes << {
      text: q.css(".text").text.strip,
      author: q.css(".author").text.strip,
      tags: q.css(".tag").map(&:text)
    }
  end

  quotes
end

def save_json(data)
  File.write("output/data.json", JSON.pretty_generate(data))
end

def save_csv(data)
  CSV.open("output/data.csv", "w") do |csv|
    csv << %w[text author tags]
    data.each do |q|
      csv << [q[:text], q[:author], q[:tags].join(", ")]
    end
  end
end

data = parse_quotes
save_json(data)
save_csv(data)

puts "Парсинг завершено! Дані збережені."
