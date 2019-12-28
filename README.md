## How to build a video call app in Ruby on Rails 6.0.1
The first thing you'll need to do is to create the ruby on rails app using the rails command:

```terminal
rails new VideoCall --database=postgresql
```

The command above will create the application, install all the default gems, and initialize webpacker for us. What the --database flag does is simply letting rails know that we want to use postgresql as our database for this project. Rails uses the sqlite3 database by default. After, in the terminal, using the cd command, get into your project folder by running ```cd VideoCall```. 
Next create a database by running ```rails db:create```.


### I- Installing Bootstrap 4, adding Font Awesome and Google Fonts

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
Now, we need to modify our route file to handle requests to the root of our application. Go to ```config/routes.rb``` file and add the following code:

#routes.rb
```ruby
Rails.application.routes.draw do
  root to: 'home#index'
end
```
This piece of code means that every time a user makes a request to the root of our app ('/'), the request is going to be handled by the index action of our home controller.

### II- User authentication with Devise

Before we start building our home page, let's add user authentication to our app. To do that, we are gonna use the devise gem. 
First, add the devise gem to your gemfile.
```ruby
gem 'devise'
```
Then run ```bundle install```.
Next, run the generator:
```terminal
rails generate devise:install (Follow instructions)
```
Now it's time to create our user model.
```terminal
rails g devise User
```
Then run ```rails db:migrate```

This will not only create our model, but it will also configure your ```config/routes.rb``` file to point to the Devise controller.
You can now get your authentication pages on ```/users/sign_in``` and ```/users/sign_up```.
Let's change those links into ```/login``` and ```/register```. (You don't have to do this. This is just a personal preference). Go to your ```config/routes.rb``` and add the following code.
```ruby
devise_scope :user do
   get 'login', to: 'devise/sessions#new'
   get 'register', to: 'devise/registrations#new'
   delete 'logout', to: 'devise/sessions#destroy'
end
```
Now you can go to ```/login``` and ```/register``` to get to your login and register pages respectively. But that's not it;
  We have not changed the default links, we just added new ones. To get rid of the ```/users/sign_in``` and ```/users/sign_up``` links, we need to go to ```app/views/devise/shared/_links.html.erb``` and change this:
```html
<%- if controller_name != 'sessions' %>
  <%= link_to "Log in", new_session_path(resource_name) %><br />
<% end %>

<%- if devise_mapping.registerable? && controller_name != 'registrations' %>
  <%= link_to "Sign up", new_registration_path(resource_name) %><br />
<% end %>
```
to this:
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
Go to the newly created migration file and make some changes to the state field
```ruby
add_column :users, :state, :integer, default: 0
```
and run ```rails db:migrate```.
This is going to add those fields to the users table.

Now let's build our login and register pages. Go to ```views/devise/registrations/new.html.erb``` and replace the content of that file by the following code:
```html
<div class="auth-page">
    <div class="container">
    <div class="row">
      <div class="col-sm-6 mx-auto">
        <div class="form-block">
          <h1>Sign up to get started</h1>
          <div class="form-body">
            <%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
              <%= devise_error_messages! %>
    
              <div class="form-row">
                <div class="form-group col-md-6">
                  <%= f.label :name %><br />
                  <%= f.text_field :name, class: "form-control", autocomplete: "name" %>
                </div> 
                <div class="form-group col-md-6">
                  <%= f.label :email %><br />
                  <%= f.email_field :email, class: "form-control", autocomplete: "email" %>
                </div>
                <div class="form-group col-md-6">
                  <%= f.label :github_link %><br />
                  <%= f.text_field :github_link, class: "form-control" %>
                </div>
                <div class="form-group col-md-6">
                  <%= f.label :avatar %><br />
                  <%= f.file_field :avatar, class: "form-control" %>
                </div>
                <div class="form-group col-md-6">
                  <%= f.label :level %><br />
                  <%= f.select :level, [['Junior', 'junior'], ['Senior', 'senior']], class: "form-control" %>
                </div>
                <div class="form-group col-md-6">
                  <%= f.label :password %>
                  <%= f.password_field :password, class: "form-control", autocomplete: "new-password" %>
                </div>
              </div>
    
              <div class="actions form-group">
                <%= f.submit "Sign up", class: "btn" %>
              </div>
            <% end %>
    
            <%= render "devise/shared/links" %>
    
          </div>
        </div>
    
      </div>
    </div>
</div>
<!-- =========================  SIGN UP FORM ==========================-->
</div>
```
Do the same with ```views/devise/sessions/new.html.erb``` by replacing its content with the following code:
```html
<!-- =========================  SIGN IN FORM ==========================-->
<div class="auth-page">
    <div class="container">
        <div class="row">
          <div class="col-sm-6 mx-auto">
            <div class="form-block">
              <h1>Sign in to get started</h1>
              <div class="form-body">
                <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
                  <div class="form-group">
                    <%= f.label :email %><br />
                    <%= f.email_field :email, class: "form-control", autocomplete: "email" %>
                  </div>
        
                  <div class="form-group">
                    <%= f.label :password %><br />
                    <%= f.password_field :password, class: "form-control", autocomplete: "current-password" %>
                  </div>
        
                  <% if devise_mapping.rememberable? -%>
                    <div class="form-group">
                      <%= f.check_box :remember_me %>
                      <%= f.label :remember_me %>
                    </div>
                  <% end -%>
        
                  <div class="actions form-group">
                    <%= f.submit "Log in", class:'btn'%>
                  </div>
                <% end %>
                <%= render "devise/shared/links" %>
              </div>
            </div>
          </div>
        </div>
    </div>
</div>
```

We can finally start building our home page. 
Go to ```views/home/index.html.erb``` file and add the following code.
```html
<%= render 'home/partials/nav' %>
  
<%= render 'home/partials/header' %>

<%= render developers %>
```
We are just rendering partials (that we haven't created yet) for the different sections of our home page. 
Let's define the ```developers``` method in ```helpers/home_helper.rb```:
```ruby
def developers
   if user_signed_in?
       'home/partials/developers'
   else
       'home/partials/empty'
   end
end
```
This is just to make sure that only signed in users see the developers. Create ```home/partials/_developers.html.erb``` and ```home/partials/_empty.html.erb``` files. In the ```home/partials/_developers.html.erb``` file, add the following code:
```html
<section class="developers text-center" id="js-developers">
    <h2 class=title>No appointment needed. Just chat!</h2>
    <div class="container">
        <div class="row my-5">
            
            <% @users.each do |user|  %>
                
                <div class="col-md-3 col-xs-6">
                    <%= render 'home/partials/user-card', user: user %>
                </div>
                
            <% end %>
            
        </div>
    </div>
</section>
```
This code displays all the users in our database. But for this to work properly, we need to do a few things; we need to define the ```@users``` instance variable in the index action of our home controller:
```ruby
def index
   @users = User.where.not(id: current_user.id) if user_signed_in?
end
```
We also need to create a partial to display each user. Create ```home/partials/_user-card.html``` file and add the following code:
```html
<div class="dev-card p-3 my-3 text-center">
    <% if user.avatar.attached? %>
        <%= image_tag user.avatar %>
    <% else %>
        <img src="assets/avatar5.jpeg" alt=""> 
    <% end %>
    
    <h6 class="dev-name text-white">
        <%= user.name %>
        <span class="appearance <%= user.state %>" id="js-appearance<%= user.id %>">
            <i class="fas fa-circle"></i>
        </span>
    </h6>
    <h6 class="dev-level"><%= user.level %></h6>
    <div class="dev-icons">
        
        <%= link_to user.github_link, class:'github-icon m-2', title: "Github page", data: {toggle: "tooltip", placement: "top"} do %>
          <i class="fab fa-github-square"></i>
        <% end %>
      
        <%= link_to '', class:"camera-icon m-2 #{user.state}", id:"js-camera-icon#{user.id}", title: "Start a video call with #{user.name}", data: {id: user.id, name: user.name, toggle: "tooltip", placement: "top"}, remote: true  do %>
          <i class="fas fa-video"></i>
        <% end %>
        
    </div>
</div>
```


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
Create the ```home/partials/nav/_dropdown.html.erb``` file and add the following code for when the user is logged in:
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
Then create the ```home/partials/nav/_auth_links.html.erb``` for when the user is not logged in. Add the following code to it:
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
```css
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
Now our navbar is exactly the way we want it to be.

Next, let's build the header section.
Go to ```home/partials/_header.html.erb``` and add this:
```html
<div class="jumbotron jumbotron-fluid mb-0">
    <div class="container">
        <div class="update">
            <p class="py-1 px-2"><span class="soon mx-2 p-1">SOON</span>TextChat: Instant text messaging coming out soon <i class="fas fa-chevron-right"></i></p>
        </div>
        <h1 class="display-4 text-white">The right way to chat with developers, globally</h1>
        <p class="lead mb-5">Don't let VAT / GST / Sales Tax be the hassle of your billing model. Determine the right rate for every transaction - at item level -, send compliant tax invoices and power your accounting. Do it automatically and around the globe with Octobat.</p>
        <div class="buttons">
            <%= render btnStart %>
            <a class="btn btn-primary disabled" href="#">TextChat coming soon!!!</a>
        </div>
    </div>
</div>
<div class="text-right">
    <img class="header-image d-none d-md-block mt-3" src="<%= image_path('Workathome.png') %>" alt="">
</div>
```

Now let's style our header section
```css
/** =================== JUMBOTRON STYLES ================== **/

.jumbotron {
  background-image: linear-gradient(to right, #141B5D, #4756A7);
  clip-path: polygon(0 0, 100% 0, 100% 70%, 0 100%);
  height: 90vh;
  h1 {
    font-size: 48px;
    line-height: 60px;
    font-weight: 800;
    width: 60%;
  }
  p {
    color: #C9CBDD;
    width: 60%;
  }
  .update {
    margin-bottom: 25px;
    p {
      background-color: #2C3780;
      color: white;
      border-radius: 20px;
      font-size: 14px;
      box-sizing: border-box;
      span {
        font-size: 12px;
        background-color: $greenColor;
        border-radius: 20px;
        margin-bottom: 0px;
      }
    }
    
  }
  .start-btn {
    background-color: $greenColor;
    border-color: $greenColor;
    &:focus, &:active {
      box-shadow: none;
      background-color: $greenColor;
      border-color: $greenColor;
    }
  }
}
 
.header-image {
  position: absolute;
  top: 120px;
  right: 30px;
  width: 600px;
  
}
```


















