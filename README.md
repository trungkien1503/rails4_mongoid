# Sử dụng MongoDB trong Ruby on Rails
Trong bàì viết này, tôi cố gắng đưa ra những thông tin cần thiết về NoSQL. NoSQL là gì? NoSQL đề làm gì? Tại sao phải dùng NoSQL? ... và giới thiệu về MongoDB. Ở đây tôi chỉ tập trung vào những điều cốt lõi để tạo bước đẩy cho chúng ta thao tác với NoSQL và MongoDB khi làm việc với Ruby on Rails.

Do đó, nếu bạn chưa biết tới NoSQL hay lần đầu làm việc với MongoDB thì trước tiên bạn nên tìm kiếm và đọc những tài liệu liên quan tới nó.

### 1. NoSQL là gì?

  NoSQL là 1 dạng cở sở dữ liệu (CSDL) mã nguồn mở không sử dụng T-SQL để truy vấn thông tin. NoSQL viết tắt bởi: None-Relational SQL, hay có nơi thường gọi là Not-only SQL.
  
 NoSQL ra đời như một mảnh vá cho những khuyết điểm và thiếu xót cũng như hạn chế của mô hình dữ liệu quan hệ RDBMS về tốc độ, tính năng, khả năng mở rộng, memory cache, ...

 Chắc hản, bạn đã sử dụng một dạng CSDL quan hệ nào đó trước khi đọc bài viết này, có thể là: SQL Server, MySQL. Và tất nhiên không ít lần bạn vất vả trong việc chỉnh sửa các bảng dữ liệu khi liên quan tới khóa chính và khóa ngoài, hay một loại rắc rối khác trong qua trình làm việc. Bời vì đó là CSDL quan hệ.

 Với NoSQL bạn có thể mở rộng dữ liệu mà không lo tới những việc như tạo khóa ngoài, khóa chính, kiểm tra ràng buộc, v.v... Vì NoSQL không hạn ché việc mở rộng dữ liệu nên tồn tại nhiều nhược điểm như: sự phục thuộc vào từng bản ghi, tính nhất quán, toàn vẹn dữ liệu,... nhưng chúng ta có thể chấp nhận những nhược điểm này để khiến ứng dụng cải thiện hiệu suất cao hơn khi giải quyết những bài toán lớn về hệ thống thông tin, phân tán hay lưu trữ dữ liệu.

 NoSQL được sử dụng ở đâu? NoSQl được sử dụng ở rất nhiều công ty, tập đoàn lớn, ví dụ như Facebook sử dụng Cassandra do Facebook phát triển, Google phát triển và sử dụng BigTable, ....

### 2. MongoDB là gì?

 MongoDB là 1 hệ thống CSDL mã nguồn mở được phát triển và hỗ trợ bởi 10gen, là CSDL NoSQL hàng đầu được hàng triệu người sử dụng.

 Thay vì lưu dữ liệu dưới dạng bảng và các tuple như trong các CSDL quan hệ thì nó lưu dữ liệu dưới dạng JSON (trong MongoDB được gọi là dạng BSON vì nó lưu trữ dưới dạng binary từ 1 JSON document). Ưu điểm của BSON là hiệu quả hơn các dạng format trung gian như XML hay JSON cả hiệu tiêu thụ bộ nhớ lẫn hiệu năng xử lý. BSON hỗ trợ toàn bộ dạng dữ liệu mà JSON hỗ trợ (sting, integer, double, boolean, aray, object, null) và thêm một số dạng dữ liệu đặc biệt như regular expression, object ID, dât, binary, code.

### 3. Cài đặt và sử dụng MongoDB

 Trong terminal bạn lần lượt chạy các câu lệnh sau:

 ```
 sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
 sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a    /etc/apt/sources.list.d/10gen.list
 sudo apt-get -y update
 sudo apt-get -y install mongodb-10gen
 ```
### 4. Tạo một ứng dụng Rails với Mongoid

 Generate một ứng dụng Rails:
 
  ```sh
  rails new rail4_mongoid --skip-active-record
  ```
  
  ```--skip-active-record``` là quan trọng bởi vì nó không thêm ActiveRecord trong ứng dụng được tạo. Ta cần sửa Gemfile để bỏ sqlite3 và thêm Mongoid.
  
  Tìm và xóa dòng sau trong Gemfile:
  
  ```ruby
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  ```
  Và thêm các dòng sau:
  ```ruby
  gem 'mongoid', '~> 4', github: 'mongoid/mongoid'
  gem 'bson_ext'
  ```
  Sau khi chạy lệnh bundle cài đặt gem xong. Ta chạy lệnh config mongoid để tạo ra file `/config/mongoid.yml`
  
  ```sh
  rails g mongoid:config
  ```
  
  Mọi thứ đã sẵn sàng để xây dựng một ứng dụng. Đầu tiên tạo một Article model với name, content và published_on bằng lệnh scaffolding:
  ```sh
  rails g scaffold name:string content:text published_on:date
  ```
  Do từ Mongoid 4.0 đã gỡ bỏ MultiParameterAttributes nên khi tạo một acticle  sẽ phát sinh lỗi vì `published_on` là multi attributes. Để khắc phục lỗi này chúng ta tạo file `multi_parameter_attributes.rb` trong thư mục `lib/mongoid`
  
  ```ruby
   # This class is needed since Mongoid doesn't support Multi-parameter
   # attributes in version 4.0 before it's moved to active model in rails 4
   #
   # https://github.com/mongoid/mongoid/issues/2954
   #
 
   # encoding: utf-8
    module Mongoid

      # Adds Rails' multi-parameter attribute support to Mongoid.
      #
      # @todo: Durran: This module needs an overhaul.
      module MultiParameterAttributes

        module Errors

          # Raised when an error occurred while doing a mass assignment to an
          # attribute through the <tt>attributes=</tt> method. The exception
          # has an +attribute+ property that is the name of the offending attribute.
          class AttributeAssignmentError < Mongoid::Errors::MongoidError
            attr_reader :exception, :attribute

            def initialize(message, exception, attribute)
              @exception = exception
              @attribute = attribute
              @message = message
            end
          end

          # Raised when there are multiple errors while doing a mass assignment
          # through the +attributes+ method. The exception has an +errors+
          # property that contains an array of AttributeAssignmentError
          # objects, each corresponding to the error while assigning to an
          # attribute.
          class MultiparameterAssignmentErrors < Mongoid::Errors::MongoidError
            attr_reader :errors

            def initialize(errors)
              @errors = errors
            end
          end
        end

        # Process the provided attributes casting them to their proper values if a
        # field exists for them on the document. This will be limited to only the
        # attributes provided in the suppied +Hash+ so that no extra nil values get
        # put into the document's attributes.
        #
        # @example Process the attributes.
        #   person.process_attributes(:title => "sir", :age => 40)
        #
        # @param [ Hash ] attrs The attributes to set.
        #
        # @since 2.0.0.rc.7
        def process_attributes(attrs = nil)
          if attrs
            errors = []
            attributes = attrs.class.new
            attributes.permit! if attrs.respond_to?(:permitted?) && attrs.permitted?
            multi_parameter_attributes = {}

            attrs.each_pair do |key, value|
              if key =~ /\A([^\(]+)\((\d+)([if])\)$/
                key, index = $1, $2.to_i
                (multi_parameter_attributes[key] ||= {})[index] = value.empty? ? nil : value.send("to_#{$3}")
              else
                attributes[key] = value
              end
            end

            multi_parameter_attributes.each_pair do |key, values|
              begin
                values = (values.keys.min..values.keys.max).map { |i| values[i] }
                field = self.class.fields[database_field_name(key)]
                attributes[key] = instantiate_object(field, values)
              rescue => e
                errors << Errors::AttributeAssignmentError.new(
                  "error on assignment #{values.inspect} to #{key}", e, key
                )
              end
            end

            unless errors.empty?
              raise Errors::MultiparameterAssignmentErrors.new(errors),
                "#{errors.size} error(s) on assignment of multiparameter attributes"
            end
            super(attributes)
          else
            super
          end
        end

        protected

        def instantiate_object(field, values_with_empty_parameters)
          return nil if values_with_empty_parameters.all? { |v| v.nil? }
          values = values_with_empty_parameters.collect { |v| v.nil? ? 1 : v }
          klass = field.type
          if klass == DateTime || klass == Date || klass == Time
            field.mongoize(values)
          elsif klass
            klass.new(*values)
          else
            values
          end
        end
      end
    end
  ```
  Thêm `config.autoload_paths += %W(#{config.root}/lib)` vào `/config/application.rb` để autoload.
  Sau đó thêm dòng `include Mongoid::MultiParameterAttributes` vào `/app/models/article.rb`
  
  ```ruby
    class Article
      include Mongoid::Document
      include Mongoid::MultiParameterAttributes
      field :name, type: String
      field :content, type: String
      field :published_on, type: Date
      validates :name, presence: true
    end
  ```
  Tiếp theo tạo model Comment:
  ```sh
   rails g model comment name:string content:text
  ```
 Định nghĩa quan hệ giữa article và comment. Thêm dòng `embeds_many :comments` trong `/app/models/article.rb`. Thêm dòng `embedded_in :article, inverse_of: :comments` trong `/app/models/comment.rb`
 
 Trong `/config/routes.rb`:
 
 ```ruby
 Rails.application.routes.draw do
  resources :articles do
    resources :comments
  end
 end
 ```
 Generate `comments_controller.rb`:
 
 ```sh
 rails g controller comments
 ```
 Sửa file `comments_controller.rb` như sau:
 
 ```ruby
    class CommentsController < ApplicationController
      def create
        @article = Article.find params[:article_id]
        @comment = @article.comments.create!(comment_params)
        redirect_to @article, notice: "Comment created!"
      end

      private

        def comment_params
          params.require(:comment).permit(:name, :content)
        end
    end
  ```
  Đồng thời sửa file `/app/views/articles/show.html.erb`:
  
  ```ruby
    <p id="notice"><%= notice %></p>

    <p>
      <strong>Name:</strong>
      <%= @article.name %>
    </p>

    <p>
      <strong>Content:</strong>
      <%= @article.content %>
    </p>

    <p>
      <strong>Published on:</strong>
      <%= @article.published_on %>
    </p>

    <% if @article.comments.size > 0 %>
      <h2>Comments</h2>
      <% for comment in @article.comments %>
        <h3><%= comment.name %></h3>
        <p><%= comment.content %></p>
      <% end %>
    <% end %>

    <h2> New Comment</h2>

    <%= form_for [@article, Comment.new] do |f| %>
      <p><%= f.label :name %> <%= f.text_field :name %></p>
      <p><%= f.text_area :content, rows: 10 %></p>
      <p><%= f.submit %></p>
    <% end %>
    <%= link_to 'Edit', edit_article_path(@article) %> |
    <%= link_to 'Back', articles_path %>
 ```
 
 Như vậy là chúng ta đã tạo được một ứng dụng đơn giản sử dụng mongoid. Ta thử kiểm tra kết quả trong `rails console`: 
 
 ```
 2.1.1 :002 > Article.last
  MOPED: 127.0.0.1:27017 QUERY        database=rails4_mongoid_development collection=articles selector={"$query"=>{}, "$orderby"=>{:_id=>-1}} flags=[] limit=-1 skip=0 batch_size=nil fields=nil runtime: 1.0883ms
 => #<Article _id: 558a0e35766965789600000a, name: "Mongoid", content: "That's great", published_on: 2015-06-24 00:00:00 UTC> 
 
 ```
### 5. Kết Luận

Qua bài viết này chúng ta thấy rằng việc cài đặt và sử dụng MongoDB trong Rails không quá phức tạp. Nhưng chúng ta cũng cần chú ý khi nào cần sử dụng và khi nào không cần sử dụng MongoDB. Đối với các dự án vừa và nhỏ thì việc sử dụng CSDL quan hệ sẽ nhanh hơn rất nhiều. Còn những dự án yêu cầu truy xuất dữ liệu lớn thì MongoDB là giải pháp tốt nhất. 

### Tài liệu tham khảo

 - https://gorails.com/blog/rails-4-0-with-mongodb-and-mongoid
 - http://mongoid.org/en/mongoid/docs/documents.html
 - http://asciicasts.com/episodes/238-mongoid