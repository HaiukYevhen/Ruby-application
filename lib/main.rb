require "httparty"
require "nokogiri"
require "json"
require "csv"

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
