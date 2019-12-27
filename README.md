## How to build a video call app in Ruby on Rails 6.0.1
The first thing you'll need to do is to create the ruby on rails app using the rails command:

```terminal
rails new VideoCall --database=postgresql
```

The command above will create the application, install all the default gems, and initialize webpacker for us. What the --database flag does is simply letting rails know that we want to use postgresql as our database for this project. Rails uses the sqlite3 database by default. After, in the terminal, using the cd command, get into your project folder. 

First, let's add bootstrap to our project. Go to the ```views/layouts/application.html.erb``` file and add the bootstrap cdn link in the head tag:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Demo</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.11.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css?family=Muli:300,400,500,600,700,800&display=swap" rel="stylesheet">
  </head>

  <body>
    ...
```
The next thing we're going to do is to create a Controller, an action and a template file to display our home page. 

```terminal
rails g controller home index
```
This creates a controller, an index action and a ```app/views/home/index.html.erb``` template to display our home page.

#home_controller.rb 
```ruby
class HomeController < ApplicationController
  def index  
  end 
end
```
Now, we need to modify our route file to handle requests to the root of our application. Go to your ```config/routes.rb``` file and the following code:

#routes.rb
```ruby
Rails.application.routes.draw do
  root to: 'home#index'
end
```
This piece of code means that every time a user makes a request to the root of our app ('/'), the request is going to be handled by the index action of our home controller.

## User authentication with Devise

Before we start building our home page, let's add user authentication to our app. To do that, we are gonna use the devise gem. 
First, add the devise to your gemfile.
```ruby
gem 'devise'
```
Then run bundle install.
Next, run the generator:
```terminal
rails generate devise:install
```
Now it's time to create our user model.
```terminal
rails g devise User
```
Then run ```rails db:migrate```

This will not only create our model, but it will also configures your ```config/routes.rb``` file to point to the Devise controller.
When you go to ```/users/sign```


