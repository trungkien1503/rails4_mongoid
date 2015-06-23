class Article
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  field :name, type: String
  field :content, type: String
  field :published_on, type: Date
  validates :name, presence: true
  embeds_many :comments
end
