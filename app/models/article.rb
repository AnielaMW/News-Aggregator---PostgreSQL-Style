require 'pry'
class Article
  attr_reader :title, :url, :description
  # attr_accessor :errors

  def initialize(article = "")
    @title = article["title"]
    @url = article["url"]
    @description = article["description"]
    # @errors =[]
  end

  def self.all
    article_array = []
    articles = db_connection {|conn| conn.exec("SELECT * FROM articles")}
    articles.each do |article|
      article_array << Article.new(article)
    end
    article_array
  end

  def save
    if valid?
      db_connection do |conn|
        conn.exec_params("INSERT INTO articles (title, url, description) VALUES ($1, $2, $3);",
         [@title, @url, @description])
      end
      true
    else
      false
    end
  end

  def valid?
    complete?(title, url, description) &&
    url_invalid?(url) && url_repeat?(url) && description_too_short?(description)
  end

  def complete?(title, url, description)
    title != "" && url != "" && description != ""
    # if title != "" && url != "" && description != ""
    #   return true
    # else
    #   @errors << "Please completely fill out form"
    #   return false
    # end
  end

  def url_invalid?(url)
    url.start_with?("http")
    # if url.start_with?("http")
    #   return true
    # else
    #   @errors << "Invalid URL"
    #   return false
    # end
  end

  def url_repeat?(url)
    urls_array = []
    Article.all.each do |article|
      urls_array << article.url
    end
    !urls_array.include?(url)
    # unless urls_array.include?(url)
    #   return true
    # else
    #   @errors << "Article with same url already submitted"
    #   return false
    # end
  end

  def description_too_short?(description)
    description.length >= 20
    # if description.length >= 20
    #   return true
    # else
    #   @errors << "Description must be at least 20 characters long"
    #   return false
    # end
  end

  def errors
    errors = []
    if complete?(title, url, description) == false
      errors << "Please completely fill out form"
    end
    if url_invalid?(url) == false
      errors << "Invalid URL"
    end
    if url_repeat?(url) == false
      errors << "Article with same url already submitted"
    end
    if description_too_short?(description) == false
      errors << "Description must be at least 20 characters long"
    end
    errors
  end
end
