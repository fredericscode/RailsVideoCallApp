## How to build a video call app in Ruby on Rails 6.0.1
The first thing you'll need to do is to create the ruby on rails app using the rails command:

```terminal
rails new VideoCall --database=postgresql
```

The command above will create the application, install all the default gems, and initialize webpacker for us. What the --database flag does is simply letting rails know that we want to use postgresql as our database for this project. Rails uses the sqlite3 database by default. After, in the terminal, using the cd command, get into your project folder. 

### I- Installing Bootstrap 4

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

### II- User authentication with Devise

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
You can now get your auth pages on ```/users/sign_in``` and ```/users/sign_up```.
Let's change those links into ```/login``` and ```/register```. (You don't have to do this. This is just a personal preference). Go to your ```config/routes.rb``` and add the following code.
```ruby
devise_scope :user do
   get 'login', to: 'devise/sessions#new'
   get 'register', to: 'devise/registrations#new'
   delete 'logout', to: 'devise/sessions#destroy'
end
```
Now you can go to ```/login``` and ```/register``` for your login and register pages respectively. But that's not it:
Because we have not changed the default links, we just added new ones. To get rid of the ```/users/sign_in``` and ```/users/sign_up``` links, we need to go to ```app/views/devise/shared/_links.html.erb``` and chage this
```html
<%- if controller_name != 'sessions' %>
  <%= link_to "Log in", new_session_path(resource_name) %><br />
<% end %>

<%- if devise_mapping.registerable? && controller_name != 'registrations' %>
  <%= link_to "Sign up", new_registration_path(resource_name) %><br />
<% end %>
```
to this
```html
<%- if controller_name != 'sessions' %>
  <%= link_to "Log in", login_path %><br />
<% end %>

<%- if devise_mapping.registerable? && controller_name != 'registrations' %>
  <%= link_to "Sign up", register_path %><br />
<% end %>
```
Now let's add some attributes to our user model. 
```terminal
rails g migration addDetailsToUsers name:string avatar:string level:string github_link:string state:integer
```
Go to the newly create migration file and make some changes for the state field
```ruby
t.integer :state,             null: false, default: 0
```
and run ```rails db:migrate```.
This is going to add those fields to the users table.

We can finally start building the front-end of our app. We are going to start with the home page. 
Go to ```views/home/index.html.erb``` file and add the following code.
```html
<%= render 'home/partials/nav' %>
  
<%= render 'home/partials/header' %>

<%= render developers %>
```
We are just rendering partials (that we haven't created yet) for the different sections of our home page. 
Inside the home folder, create a ```partials``` folder. Then inside that ```partials``` folder, create the following files: ```_nav.html.erb```, ```_header.html.erb``` and ```_developers.html.erb```. Starting with the navbar, add the following code to the ```_nav.html.erb``` file.
```html
<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container">
        <a class="navbar-brand" href="#"><i class="fas fa-adjust"></i>Navbar</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
          <span class="toggler"><i class="fas fa-bars text-white"></i></span>
        </button>
      
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
          <ul class="navbar-nav ml-auto">
            <%= render links %>
          </ul>
        </div>
    </div>
</nav>
```
This is a bootstrap navbar that I modified to suit the needs of our application. Notice the ```<%= render links %>``` part? This is going to render the result of a ```links``` method depending on the authentication status of the user. So, if the user is logged in, we want to display that user's name, and if the user is not logged in, we just display the authentication links (Login and SignUp). To create the ```links``` method, go to ```helpers/home_helper.rb``` file and add the following code:
```ruby
def links
   if user_signed_in?
     'home/partials/nav/dropdown'
   else
     'home/partials/nav/auth_links'
   end
end
```
Create the ```home/partials/nav/dropdown.html.erb``` file and add the following code for when the user is logged in:
```html
<li class="nav-item">
    <%= render change_state_btn %>
</li>

<li class="nav-item dropdown">
    <a class="nav-link mx-3 dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" 
    aria-haspopup="true" aria-expanded="false">
        <%= current_user.name %>
    </a>
        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
            <%= link_to 'Logout', logout_path, class: 'dropdown-item', method: :delete %>
            <a class="dropdown-item" href="#">Action</a>
            <a class="dropdown-item" href="#">Another action</a>
            <div class="dropdown-divider"></div>
            <a class="dropdown-item" href="#">Something else here</a>
        </div>
</li>
```
Then create the ```home/partials/nav/auth_links.html.erb``` for when the user is not logged in. Add the following code to it:
```html
<li class="nav-item">
    <%= link_to 'Sign Up', register_path, class: 'nav-link signup-btn btn btn-success py-1 mx-3' %>
</li>
<li class="nav-item">
    <%= link_to 'Log In', login_path, class: 'nav-link mx-3' %>
</li>
```
Now when you go to ```localhost:3000```, you can see our navbar. But it doesn't look really good, so let's style it.
Go to ```app/assets/stylesheets/``` and create a ```variables.scss``` file. Add the following code to that file:
```sass
$grayColor:  #8A8D91;
$lightGray: #E8EBED;
$greenColor: #3DC794;


@mixin btn {
  background-color: $greenColor;
  color: white;
  border-color: $greenColor;
  border-radius: 10px;
  font-weight: 500;
}
```
This is where we are going to keep our sass variables for our styles.
Now go to ```app/assets/stylesheets/home.scss``` and add this:
```css
@import "./variables";

body {
  font-family: 'Muli', sans-serif;
  position: relative;
}
/* ======= NAVBAR ======= */
.navbar {
  background-color: #141B5D !important;
  .navbar-brand {
  color: white !important ;
  font-size: 26px;
  font-weight: 700;
  }
}

.navbar-toggler {
    border-color: white !important;
}




.nav-link {
  color: white !important;
  font-size: 16px;
  font-weight: 600;
  &.signup-btn {
    background-color: $greenColor;
    border-color: $greenColor;
  }
  i {
    font-size: 12px;
  }
}
```


















