<h2>How to build a live, face-to-face video chat app in Ruby on Rails 6.0.2.1</h2>

####                              DISCLAIMER: This tutorial is not for beginners. 

Thank you for getting this ebook. In this tutorial, we are going to build a face-to-face video chat app in ruby on rails. I decided to build this app because I was not interested in building another blog or todoapp - There are plenty of those out there. I wanted something unique to share with you. That's why I spend quite some time building this app, styling it to make it look good, appealing. 

To build this app, you'll need a few things:

- ruby 2.7.0 and rails 6.0.2.1 (Those are the versions I'm using for this tutorial)
- AWS credentials (access_key_id and secret_access_key)
- AWS S3 bucket
- Tokbox account (Opentok is Tokbox's WebRTC Platform)
- Tokbox credentials (api_key and secret_key)  https://tokbox.com/ (you get $10 credit to try it out)



###                                               Let's code



The first thing you'll need to do is to create the ruby on rails app using the rails command:

```terminal
rails new VideoCall --database=postgresql
```

The command above will create the application, install all the default gems, and initialize webpacker for us. What the --database flag does is simply letting rails know that we want to use postgresql as our database for this project. Rails uses the sqlite3 database by default. After, in the terminal, using the cd command, get into your project folder by running ```cd VideoCall```. 
Next create a database by running ```rails db:create```.


###                      I- Installing Bootstrap 4, adding Font Awesome and Google Fonts

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
Don't forget to add bootstrap javascript links at the bottom of your file. Right before the ending tag of the body element:
```html
   <script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
      <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
      <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
 ```
 
 

The next thing we're going to do is to create a Controller, an action and a template file to display our home page. 

```terminal
rails g controller home index
```
This creates a controller, an index action and a ```app/views/home/index.html.erb``` template to display our home page.

###### ```home_controller.rb```
```ruby
class HomeController < ApplicationController
  def index  
  end 
end
```
Now, we need to modify our route file to handle requests to the root of our application. Go to ```config/routes.rb``` file and add the following code:

###### ```routes.rb```
```ruby
Rails.application.routes.draw do
  root to: 'home#index'
end
```
This piece of code means that every time a user makes a request to the root of our app ('/'), the request is going to be handled by the index action of our home controller.

If you go to ```localhost:3000```, you will see our home page.










<p align="center">
  <img width="600" height="500" src="https://github.com/fredericscode/VideoCall/blob/master/app/assets/images/Screen%20Shot%202020-01-10%20at%204.35.56%20PM.png">
</p>











### II- User authentication with Devise

Before we start building our home page, let's add user authentication to our app. To do that, we are gonna use the devise gem. 
First, add the devise gem to your gemfile.
###### ```gemfile.rb```
```ruby
gem 'devise'
```
Then run ```bundle install```.
Next, run the generator:
```terminal
rails generate devise:install
```
Generate devise views by running: ```rails g devise:views```.

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
And go to ```app/views/devise/shared/_links.html.erb``` and change this:
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
  <%= link_to "Sign up", register_path, data: {turbolinks: false} %><br />
<% end %>
```
We use ```data: {turbolinks: false}``` on the signup link to disable turbolinks. If we don't do that, we won't be able to upload a picture.

Now you can go to ```/login``` and ```/register``` to get to your login and register pages respectively.

### III- Adding custom attributes to the users

To add some attributes to our user model, run this code on your terminal.
```terminal
rails g migration addDetailsToUsers name:string avatar:string github_link:string state:integer
```
Go to the newly created migration file and make some changes to the ```state``` field:
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
              
              <div class="avatar-wrapper">
                  <img class="profile-pic" src="" />
                  <div class="upload-button">
                	  <i class="fa fa-arrow-circle-up" aria-hidden="true"></i>
                  </div>
	                <%= f.file_field :avatar, class: "file-upload form-control" %>
              </div>
            
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
For our signup form to work properly, we need to add some javascript. create a ```script.js``` file in your ```app/javascript/packs``` folder.
For that file to be run by webpacker, let's import it by adding ```import './script.js'``` in our ```app/javascript/packs/application.js``` file. Now add this code to our ```script.js``` file:
```javascript
document.addEventListener('DOMContentLoaded', (event) => {

  /* Avatar upload functionality for user registration */
  var readURL = function(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('.profile-pic').attr('src', e.target.result);
            }
    
            reader.readAsDataURL(input.files[0]);
        }
  }
   
  $(".file-upload").on('change', function(){
      readURL(this);
  });
    
  $(".upload-button").on('click', function() {
      $(".file-upload").click();
  });
  
})
```
###### ```Explanation```
In the code above, we listen for changes on the file input field, and when a file is selected, we read it using the FileReader api, then we change ```src``` attribute of the image tag by the file url. See https://developer.mozilla.org/en-US/docs/Web/API/FileReader .

Now we need to whitelist those new attributes. To do that, we are going to create our own ```registrations``` controller. In ```app/controllers```, create ```registrations_controller.rb``` and add this code:
```ruby
class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :avatar, :github_link, :password)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :github_link, :avatar, :password)
  end
end
```
###### ```Exlanation``` 
We modified the devise's ```sign_up_params``` method by adding our attributes(including the new ones) to ```params.require(:user).permit```.
We did the same thing for the ```account_update_params``` method, although we are not gonna need it.

Now we need to instruct rails to use our newly created ```registrations``` controller, not devise's registrations controller. We can do that ```config/routes.rb``` by replacing ```devise_for :users``` with ```devise_for :users, controllers: { registrations: "registrations" }```.

### IV- Initializing Active Storage

Since we are going to be working with images, let's go ahead and initialize active storage by running ```rails active_storage:install``` and then ```rails db:migrate```. 
Now, add this to your ```models/user.rb``` file:
```ruby
has_one_attached :avatar
```

### V- Building the Home page

  ###### V- 1. Developers section

We can finally start building our home page. 
Go to ```views/home/index.html.erb``` file and add the following code after deleting the content of that file.
```html
<%= render 'home/partials/nav' %>
  
<%= render 'home/partials/header' %>

<%= render developers %>
```
Here, we are just rendering partials (that we haven't created yet) for the different sections of our home page. 
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
This is just to make sure that only signed in users see the developers section.
Create ```views/home/partials/_developers.html.erb``` and ```views/home/partials/_empty.html.erb``` files. 
In the ```home/partials/_developers.html.erb``` file, add the following code:
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
###### ```home_controller.rb```
```ruby
def index
   @users = User.where.not(id: current_user.id) if user_signed_in?
end
```
###### ```Explanation```
If there's a signed in user, we get all the users in the dabatase except that user.


We also need to create a partial to display each user. Create ```views/home/partials/_user-card.html.erb``` file and add the following code:
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
To initialize the tooltip on our github and camera icons, go to your ```script.js``` file and add this: 
```javascript
/* Initialize tooltips */ 
  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })
```
That block of code is provided to us by bootstrap.


  ###### V- 2. Navbar section
  
Inside the ```partials``` folder, create the following files: ```_nav.html.erb```, ```_header.html.erb```. Starting with the navbar, add the following code to the ```_nav.html.erb``` file.
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
This is a bootstrap navbar that I modified to suit the needs of our application. Notice the ```<%= render links %>``` part? This is going to render the result of a ```links``` method depending on the authentication status of the user. So, if the user is logged in, we want to display that user's name and the button the change the state, and if the user is not logged in, we just display the authentication links (Login and SignUp). To create the ```links``` method, go to ```helpers/home_helper.rb``` file and add the following code:
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
        </div>
</li>
```
Define the ```change_state_btn``` method in ```helpers/home_helper.rb```.
```ruby
def change_state_btn
   current_user.online? ? "home/partials/nav/dropdown/gofflinebtn" : "home/partials/nav/dropdown/gonlinebtn"
end
```
The ```online``` method above is not defined. To define it, we gonna use enums. Go to ```app/models/user.rb``` and add this code: 
```ruby
enum state: { offline: 0, online: 1 }
```
###### ```Explanation```
This adds ```online``` and ```offline``` methods to our user model. We can now use ```user.online!``` and ```user.offline!``` to change the user's state (0 to 1, or 1 to 0), but we can also use ```user.online?``` and ```user.offline?``` to check if the user is online or offline. 

Next, create ```home/partials/nav/dropdown/_gofflinebtn.html.erb``` and ```home/partials/nav/dropdown/_gonlinebtn.html.erb``` (leave them empty for now).



Then create the ```home/partials/nav/_auth_links.html.erb``` for when the user is not logged in. Add the following code to it:
```html
<li class="nav-item">
    <%= link_to 'Sign Up', register_path, class: 'nav-link signup-btn btn btn-success py-1 mx-3', data: {turbolinks: false} %>
</li>
<li class="nav-item">
    <%= link_to 'Log In', login_path, class: 'nav-link mx-3' %>
</li>
```
On the signup link, we disabled turbolinks with ```data: {turbolinks: false}``` because we don't want rails to use ajax to get to the signup page. if we don't do that, users will not be able to upload a picture when signing up (because our javascript code will not run).

Now when you go to ```localhost:3000```, you can see our navbar.
















But it doesn't look really good, so let's style it.
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
That's where we are going to keep our sass variables for our styles.
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
}
```
Now our navbar is exactly the way we want it to be.






















  ###### V- 3. Header section
  
Next, let's build the header section.
Go to ```home/partials/_header.html.erb``` and add this:
```html
<div class="jumbotron jumbotron-fluid mb-0">
    <div class="container">
        <div class="update">
            <p class="py-1 px-2"><span class="soon mx-2 p-1">SOON</span>TextChat: Instant text messaging coming out soon <i               class="fas fa-chevron-right"></i>
	    </p>
        </div>
        <h1 class="display-4 text-white">The right way to chat with developers, globally</h1>
        <p class="lead mb-5">Have an idea to share? Need help with a coding challenge? Come chat with your fellow developers.         Do it automatically and around the globe with DevTime. No appointment needed!
	</p>
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
Notice the image that we added at the bottom of the code above? You can get the same at https://usesmash.com for free and add it inside your ```assets/images``` folder.

Now, define the ```btnStart``` method in ```helpers/home_helper.rb```:
```ruby
def btnStart
    if user_signed_in?
        "home/partials/startbtn/scrollbtn"
    else
        "home/partials/startbtn/authbtn"
    end
end
```
Create the ```home/partials/startbtn/_scrollbtn.html.erb``` and ```home/partials/startbtn/_authbtn.html.erb``` files.
In the ```home/partials/startbtn/_scrollbtn.html.erb``` file, add this: 
```html
<%= link_to 'Start now', '#', class: 'start-btn btn btn-success mr-1', id: 'js-start-btn' %>
```
And in the ```home/partials/startbtn/_authbtn.html.erb``` file, add this:
```html
<%= link_to 'Start now', login_path, class: 'start-btn btn btn-success mr-1', id: 'js-start-btn-auth' %>
```
###### ```Explanation```
If the user is signed in, we want to display a 'start' button that is going to scroll down to the developers section when clicked (_scroolbtn.html.erb). 
When the user is not signed in, clicking on the start button is going to redirect that user to the login page.

Now, add this javascript code to handle the scrolling effect. Go to your ```app/javascript/script.js``` file and add this code: 
```javascript
/* Scroll to the developers section when the start button is clicked */
  const startBtn = document.getElementById('js-start-btn')
  const devSection = document.getElementById('js-developers')
  if (startBtn !== null) {
    startBtn.addEventListener('click', (event) => {
      event.preventDefault()
      devSection.scrollIntoView({behavior: 'smooth', block: 'start'})
    })
  }
```


Let's also style our auth pages, our header and the developers section. Add the following code to ```app/assets/stylesheets/home.scss```:
```css
/** =================== HEADER STYLES ================== **/

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

/** =======================DEVELOPERS SECTION ======================== **/

.developers {
  padding: 20px;
  h2 {
    font-weight: 300;
    color: #212CA6;
  }
  .dev-card {
    background-color: #BCDEFA;
    border-radius: 20px;
    img {
      border: 3px solid #EFF8FF;
      border-radius: 50%;
      width: 60px;
      height: 60px;
    }
    .dev-name {
        padding: 0px 10px;
        .appearance {
            color: red;
            font-size: 8px;
            &.online {
                color: green;
            }
            
        }
    }
    .dev-level {
      font-weight: 300;
      color: #2D8F98;
    }
    .dev-icons {
      i {
        font-size: 18px;   
      }
      .github-icon {
        color: black;
      }
      .camera-icon {
        color: $greenColor;
        &.offline {
            display: none;
        }
        
        
      }
    }
  }
}

////////// ================== AUTH FORM ============//////////////

.auth-page {
    background-image: linear-gradient(to right, #141B5D, #4756A7);
    height: 100vh;
}

.form-block {
  margin-top: 80px;
  padding: 25px;
  border-radius: 10px;
  background-color: white;
  h1 {
    text-align: center;
    font-weight: 700;
  }
  .form-body {
  
    //========Avatar upload styles=========//
    .avatar-wrapper{
    	position: relative;
    	height: 100px;
    	width: 100px;
    	margin: 50px auto;
    	border-radius: 50%;
    	overflow: hidden;
    	box-shadow: 1px 1px 15px -5px black;
    	transition: all .3s ease;
    	&:hover{
    		transform: scale(1.05);
    		cursor: pointer;
    	}
    	&:hover .profile-pic{
    		opacity: .5;
    	}
    	.profile-pic {
            height: 100%;
        	width: 100%;
        	transition: all .3s ease;
        	  &:after{
        		  //font-family: FontAwesome;
        		  content: "Upload Avatar";
        		  top: 0px; left: 0;
        		  width: 100%;
        		  height: 100%;
        		  position: absolute;
        		  font-size: 20px;
        		  background: #ecf0f1;
        		  color: #34495e;
        		  text-align: center;
        		  padding-top: 15px;
        	  }
    	}
    	.upload-button {
    		position: absolute;
    		top: 0; left: 0;
    		height: 100%;
    		width: 100%;
    		.fa-arrow-circle-up{
    			position: absolute;
    			font-size: 100px;
    			top: 0px;
    			left: 0px;
    			text-align: center;
    			opacity: 0;
    			transition: all .3s ease;
    			color: #34495e;
    		}
    		&:hover .fa-arrow-circle-up{
    			opacity: .9;
    		}
    	}
    }
    //========Avatar upload styles=========//
    
    
    label, em {
      color: $grayColor;
      text-transform: uppercase;
      font-size: 12px;
    }
    input {
      box-shadow: none;
      background-color: $lightGray;
      &:focus {
        background-color: white;
        border: 2px solid $lightGray;
      }
    }
    input.btn {
      @include btn;
    }
    
    a {
      color: $grayColor;
      font-size: 14px;
    }
    .alert-error {
      background-color: red;
      color: white;
      .close {
        color: white;
        margin-left: 3px;
      }
    }

  }
}//========================== Auth form =====================
```


### VI- Styling Devise notifications with Bootstrap

Devise alerts are really ugly, let's make them look good. First, go to your ```app/views/layouts/application.html.erb``` file and add this code right below the opening tag of the body element (delete the default devise alerts first):
```html
<!-- Devise notification styled with bootstrap -->
<% if notice %>
      <div class="notice alert alert-success alert-dismissible fade show" role="alert">
        <%= notice %>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
<% elsif alert %>
      <div class="danger alert alert-danger alert-dismissible fade show" role="alert">
        <p><%= alert %></p>
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
<% end %>    
```
Then, go to your ```app/assets/stylesheets/home.scss``` and add this:
```css
// ========= Bootstrap notification ==========
.notice, .danger {
  margin: 0px;
  p {
    margin-bottom: 0px;
  }
}// ========= Bootstrap notification ==========
```
That's it!!! Now our home, login and register pages are looking good. But we can't register because we haven't implemented image upload functionality.























### VII- Image upload on AWS S3

Now is time to allow users to choose a profile picture and upload it to aws using active storage.
First, go to ```config/environments/development.rb``` and change ```config.active_storage.service = :local``` to ```config.active_storage.service = :amazon```.  Do the same thing in ```config/environments/production.rb```.

You can use rails credentials to store keys, but I prefer to store mine inside environment variables

Uncomment the amazon section in your ```config/storage.yml``` and add your AWS S3 credentials like this:
```yml
amazon:
  service: S3
  access_key_id: <%= ENV["ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["SECRET_ACCESS_KEY"] %>
  region: your_region
  bucket: you_bucket
```
Let's create a ```config/local_env.yml``` file. And inside that file, we are going to store our credentials like this:
```yml
AWS_ACCESS_KEY_ID: 'my_access_key_id'
AWS_SECRET_ACCESS_KEY: 'my_secret_access_key'
```

 Now, let's store those credentials inside environment variables. In the config/application.rb file, add the below code:
```ruby
config.before_configuration do
  env_file = File.join(Rails.root, 'config', 'local_env.yml')
  YAML.load(File.open(env_file)).each do |key, value|
    ENV[key.to_s] = value
  end if File.exists?(env_file)
end
```
###### ```Explanation```
We read the ```config/local_env.yml``` file and we store our credentials inside environment variables.

Don't forget to add your local_env.yml file in your .gitgnore file.

Next add ```gem "aws-sdk-s3", require: false``` in our gemfile and uncomment the ```image_processing``` gem.

Run ```bundle install```.

Now our users can add a profile picture when signing up and that picture is going to be saved to aws s3.









                                                  GIF












### VIII- Building the online/offline feature using action cable

  ###### VIII- 1. Allowing developers to go from 'online' to 'offline'

In this section, we are going to build the ```online/offline``` feature for the developers in our application. This is how it's going to work: when a developer logs in, he/she is offline by default. When he/she is ready to talk/chat with other developers, he/she can click a button on the navbar and his state will automatically change from ```offline``` to ```online```. And if he/she clicks on that button again, the state will change back to ```offline```. Thats the first part of our feature. To build this functionnality, you should already have the button rendered in your ```app/views/home/partials/nav/_dropdown.html.erb``` file:
```html
<%= render change_state_btn %>
```
Here, we are rendering the result of a ```change_state_btn``` method that we defined earlier in the course. That method will give us a 'Go online' or a 'You are online' button depending on the developer's state.
- If the developer is 'online', a green 'You are online' button will be rendered, and will change to a red 'Go offline' button when hovered on.
- If the developer is 'offline', a outline-green 'Go online' button will be rendered, and will change to a green 'Go online' button when hovered on.

Now, go to your ```app/views/home/partials/nav/dropdown/_gonlinebtn.html.erb``` and add the following code: 
```html
<%= link_to 'Go Online', online_path, class: 'nav-link state-btn offline mx-3 btn btn-outline-success', id: 'js-offlinebtn', remote: true, method: :post %>

<%= link_to 'You are online', offline_path, class: 'nav-link state-btn online d-none mx-3 btn btn-success', id: 'js-onlinebtn', remote: true, method: :post %>
```
Explanation: The 'You are online' button will be hidden by default (d-none). and when the 'Go online' button is clicked, it will be hidden and the 'You are online' button will be displayed. 

Then, go to your ```app/views/home/partials/nav/dropdown/_gofflinebtn.html.erb``` and add tis code:
```html
<%= link_to 'You are online', offline_path, class: 'nav-link state-btn online mx-3 btn btn-success', id: 'js-onlinebtn', remote: true, method: :post %>

<%= link_to 'Go Online', online_path, class: 'nav-link state-btn offline d-none mx-3 btn btn-outline-success', id: 'js-offlinebtn', remote: true, method: :post %> 
```
Explanation: The 'Go online' button will be hidden by default (d-none). and when the 'You are online' button is clicked, it will be hidden and the 'Go online' button will be displayed. 

Now that we have our buttons in place, we need to create 2 routes; one for when the developer goes online (online_path), and another one when the developer goes offline (offline_path). Go to your ```config/routes.rb``` and add this code:
```ruby
post 'online', to: 'home#online'
post 'offline', to: 'home#offline'
```
As you can see, our requests go to 'online' and 'offline' actions in our home controller. Let's create those actions. Add this to your ```app/controllers/home_controller.rb```:
```ruby
def online
    current_user.online!
    respond_to do |format|
        format.js
    end
end

def offline
    current_user.offline!
    respond_to do |format|
        format.js
    end
end
```
Explanation: In the online action, we just change the developer's state to 'online' with ```current_user.online```. After that, since it's an ajax request(remote), we respond with javascript format, which means that Rails is going to look for a ```views/home/online.js.erb``` file and run it. Same for the offline method, Rails is going to look for and run a ```views/home/offline.js.erb```. Create those two files.
In the ```views/home/online.js.erb``` file, add this:
```javascript
var offlineBtn = document.getElementById("js-offlinebtn")
offlineBtn.classList.add("d-none")

var onlineBtn = document.getElementById("js-onlinebtn")
onlineBtn.classList.remove("d-none")
```
And in the ```views/home/offline.js.erb``` file, add this:
```javascript
var onlineBtn = document.getElementById("js-onlinebtn")
onlineBtn.classList.add("d-none")

var offlineBtn = document.getElementById("js-offlinebtn")
offlineBtn.classList.remove("d-none")
```
Explanation: Here, in the ```views/home/online.js.erb``` file, we are just hiding the 'Go online' button to display the 'You are online' button. and in the ```views/home/offline.js.erb``` file, we are hiding the 'You are online' button to display the 'Go online' button.

If you test the app, you can see that it's effectively changing the developer's state when you click on the button. But there's one thing that we need to add. When the developer hovers on the 'You are online' button, we want that button to turn red, and the text to say 'Go offline'. 
In our ```app/javascript/packs/script.js``` file, add the following code:
```javascript

...

/* Change the background color and innerHTML when the online button is hovered */
const onlineBtn = document.getElementById('js-onlinebtn')
if( onlineBtn !== null) {

    onlineBtn.addEventListener('mouseover', (event) => {
        onlineBtn.style.backgroundColor = "red"
        onlineBtn.style.borderColor = "red"
        onlineBtn.innerHTML = "Go offline"

    })

    onlineBtn.addEventListener('mouseout', (event) => {
        onlineBtn.style.backgroundColor = "#3DC794"
        onlineBtn.style.borderColor = "#3DC794"
        onlineBtn.innerHTML = "You are online"

    })
}
```
Explanation: We get the 'You are online' button, and we change its background color, border color, as well as its text when you hover on it. When you remove the mouse, things get back to normal.

Now, let's style the state button by adding this code to ```app/assets/stylesheets/home.scss``` file, inside the nav-link section, just below ```&.signup-btn``` :
```css
&.state-btn {
    border-color: $greenColor;
    color: $greenColor !important;
  }
&.state-btn:hover, &.state-btn.online {
  background-color: $greenColor;
  border-color: $greenColor;
  color: white !important;
}
```
The nav-link section should now look like this
```css
.nav-link {
  color: white !important;
  font-size: 16px;
  font-weight: 600;
  &.signup-btn {
    background-color: $greenColor;
    border-color: $greenColor;
  }
  &.state-btn {
    border-color: $greenColor;
    color: $greenColor !important;
  }
  &.state-btn:hover, &.state-btn.online {
    background-color: $greenColor;
    border-color: $greenColor;
    color: white !important;
  }
  
}
```
Now if you test the app, you will see that everything is working fine. 








                                         GIF










  ###### VIII- 2. Realitme updates for state changes using action cable

We are now going to add realtime updates to the appearance dot(the icon next to the dev's name) everytime a developer's state changes. This means that when a developer goes online, all the developers that are logged in will see the appearance dot on that developer's card change from red to green, and from green to red when the developer goes offline.
To do this, we are going to use action cable. First, let's create an ```appearance``` channel. Run this code in your terminal:
```terminal
rails g channel appearance
```
Also, uncomment the redis gem in your gemfile and run ```bundle install``` in your terminal.
Then, go to your ```app/channels/application_cable/connection.rb``` file to setup our connection. Add this code inside the ```Connection``` class of the file:
```ruby
identified_by :current_user

def connect
  self.current_user = find_verified_user
end

protected

def find_verified_user
  if (current_user = env['warden'].user)
    current_user
  else
    reject_unauthorized_connection
  end
end
```
Explanation: Here ```identified_by``` is a connection identifier. It basically represents the user currently logged in.  ```find_verified_user``` returns the current user by using warden, and reject the connection if the user was not found.

The next thing we need to do is to update 'online' and 'offline' methods in our home controller. Modified those methods to make them look like this:
```ruby
def online
      current_user.online!
      broadcast_change_to_users("online")
      respond_to do |format|
          format.js
      end
  end

  def offline
      current_user.offline!
      broadcast_change_to_users("offline")
      respond_to do |format|
          format.js
      end
  end
```
Then, define the ```broadcast_change_to_users``` function just below them:
```ruby
private 

def broadcast_change_to_users(state)
    ActionCable.server.broadcast(
        "appearance",
        state: state,
        user_id: current_user.id
    )
end
```
Explanation: After the state change, we broadcast to all the other developers that are logged in and subscribed to the 'appearance' stream(that we haven't defined yet). Doing that, we pass in the state, and the user_id of the developer/user. 
Let's define the 'appearance' stream by adding this line of code in the ```subscrided``` method of our ```app/channels/appearance_channel.rb```: 
```ruby
stream_from "appearance"
```
We also need to stop the stream when the channel is unsubscribed. To do that, add this to the ```unsubscribe``` method of the same file:
```ruby
stop_all_streams
```

This broadcast signal is going to be received by the ```received``` function of our ```app/javascript/channels/appearance_channel.js``` file. Inside that function, add this piece of code:
```javascript
//=================== IF THE USER IS ONLINE ============================//////////////
if (data['state'] === "online") {
  var dot = document.getElementById("js-appearance" + data['user_id']);
  //var user_state = document.getElementById("user-state" + data['user_id']);
  var camera_icon = document.getElementById("js-camera-icon" + data['user_id']);
  if (dot !== null && camera_icon !== null) { // This values are null for the current_user (the user that went online)
    dot.classList.remove("offline");
    dot.classList.add("online");
    camera_icon.classList.remove("offline");
    camera_icon.classList.add("online");
  }
  
  
  //===================== IF THE USER IS OFFLINE =========================///////////////
} else if (data['state'] === "offline" ) { // e.g: the user logged out
  var offDot = document.getElementById("js-appearance" + data['user_id']);
  var offCameraIcon = document.getElementById("js-camera-icon" + data['user_id']);
  if (offDot !== null && offCameraIcon !== null) {
    offDot.classList.remove("online");
    offDot.classList.add("offline");
    offCameraIcon.classList.remove("online");
    offCameraIcon.classList.add("offline");
        
  }
  
}
```
Explanation: When we receive the broadcast signal and the data sent in our ```broadcast_change_to_users``` method, we first check the developer's state. If the developer is online, we simply display the camera icon on his card and we also change the color of its appearance dot from red to green. If the developer is offline, we hide the camera icon on his card, and we change the color of its appearance dot from green to red.

Now if you test our feature, you will see that it works perfectly.









                                              GIF









NOTE: If you deploy the application to heroku, don't forget to add the REDIS_TO_GO addon in your app, the copy the REDISTOGO_URL and save it as an environment variable in your ```local_env.yml```, just below your AWS credentials:
```yml
REDISTOGO_URL: 'redis://redistogo:55cea217e43f8912c561f0cc3247ff48@hammerjaw.redistogo.com:11969/'
```
Then, add that url to the action cable production settings on your ```config/cable.yml``` file:

```yml
production:
  adapter: redis
  url: <%= ENV["REDISTOGO_URL"] %>
  channel_prefix: Final_production
```
Also, sometimes you may get broken images on heroku. To fix that, go to your ```config/environment/production.rb``` and set t ```config.assets.compile``` to true.





  ###### VIII- 3. Getting users offline when they log out

At this time, when a user is "online" and logs out, he remains "online" and other developers can see that. We don't want that. We need to make sure the user gets "offline" when logging out. To do that, we are going to extend the ```Devise::SessionsController``` by creating our own and modify the destroy method. Create a ```sessions_controller.rb``` file inside your ```app/controllers``` folder. Add this code inside that file:
```ruby
class SessionsController < Devise::SessionsController
  
  def destroy
       
       if current_user.online?
         current_user.offline!
         broadcast_change_to_users("offline")
       end

       super
  end
  
  private

  def broadcast_change_to_users(state)
      ActionCable.server.broadcast(
        "appearance",
        state: state,
        user_id: current_user.id
      )
  end
  
end
```
###### ```Explanation```
In the ```destroy``` method, we first get the user offline (If he/she is not already). Then, just like we did on our ```home_controller```, we broadcast the change to other users.

Next, we need rails to use our sessions controller, not devise's sessions controller. Go to your ```routes.rb``` file and change this:
```ruby
devise_for :users, controllers: { registrations: "registrations" }
```
To this: 
```ruby
devise_for :users, controllers: { registrations: "registrations", sessions: "sessions" }
```
Finally, in the same file, change ```delete 'logout', to: 'devise/sessions#destroy'``` with ```delete 'logout', to: 'sessions#destroy'```.
Great! now, everything is working as expected.


### IX- Building the video call feature using the opentok platform

  ###### IX- 1. Creating the modals
  
Now we can start building the main feature of our app. To do that, we are going to use the opentok platform. 
OpenTok is the leading WebRTC platform for interactive video, enabling voice, video and messaging for mobile and web with our Live Video API. 
Let's start by adding the bootstrap modals. Create the following files in your views folder:
```app/views/home/partials/modals/_receiver_notif_modal.html.erb```
```app/views/home/partials/modals/_sender_notif_modal.html.erb```
```app/views/home/partials/modals/_session_modal.html.erb```
The first file is for the notification sent to a dev when another dev is calling him/her.
The second file is for the notification that pops up when a dev calls another dev (when you click on the camera icon).
The third file is for the session itself (the video).
Let's code our modals:

###### ```app/views/home/partials/modals/_receiver_notif_modal.html.erb```
```html
<div class="modal fade" id="receiver-notif-modal" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-sm modal-dialog-centered">
    <div class="modal-content">
      <!--<div class="modal-header">
        <h6 class="modal-title" id="exampleModalLabel">Incoming video call</h6>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>-->
      <div class="modal-body">
        <span><strong id="sender_name"></strong> is calling</span>
        <%= link_to '', id:'answer-call' do %>
          <i class="fas fa-video"></i>
        <% end %>
        <h6 id="session_id"></h6>
        <h6 id="sender_id"></h6>
      </div>
    </div>
  </div>
</div> 
```

###### ```app/views/home/partials/modals/_sender_notif_modal.html.erb```
```html
<div class="modal fade" id="sender-notif-modal" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-sm modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-body">
        <span>Calling <strong id="recipient_name_modal"></strong></span>
        <% 3.times do %>
            <div class="spinner-grow text-info" role="status">
              <span class="sr-only">Loading...</span>
            </div>
        <% end %>
      </div>

    </div>
  </div>
</div> 
```

###### ```app/views/home/partials/modals/_session_modal.html.erb```
```html
<div class="modal fade" id="session-modal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <%= link_to '', class:"modal-title", id:"stop-session" do %>
          <i class="fas fa-video-slash"></i>
        <% end %>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body" id="modal-body-session">
        <div class="session">
          <div id="subscriber">

          </div>
          <div id="publisher">

          </div>
        </div>
      </div>

    </div>
  </div>
</div>

</div> 
```
Now that we have our three modals, we need to render them in our `app/views/layouts/application.html.erb` file. Add this code right before the script tags at the bottom of the file.

###### `app/views/layouts/application.html.erb`
```html
<%= render 'home/partials/modals/receiver_notif_modal' %>
<%= render 'home/partials/modals/sender_notif_modal' %>
<%= render 'home/partials/modals/session_modal' %>
```
Then, let's go to our `app/assets/stylesheets/home.scss` file and add some styles to our modals.

###### `app/assets/stylesheets/home.scss`
```css
//===================== Modal =============================
.modal {
  .modal-header {
    //background-color: white;
    .fas {
      margin: 4px 0px 0px 10px;
      color: green;
    }
    .fas.fa-video-slash {
      color: red;
    }

    .modal-title {
      color: white;
    }

  }
  .modal-body {
    .fas {
      font-size: 18px;
      margin-left: 10px;
      color: green;
    }
    #session_id, #sender_id {
      display: none;
    }
  }
  .modal-footer {
    //background-color: #121212;
    //color: white;
  }

}

#modal-body-session {
  padding: 0px;
  height: 400px;
  .session {
    background-color: black;
    position: absolute;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;
    #subscriber {
      position: relative;
      top: 0px;
      left: 0px;
      width: 100%;
      height: 100%;
    }
    #publisher {
      position: absolute;
      width: 30%;
      height: 30%;
      bottom: 0px;
      right: 0px;
      z-index: 1000;

    }
  }
}//==================== Modal ============================
```

  ###### IX- 2. Opentok Setup


###### NOTE: 
David = the sender = the user initiating the call (the one that clicked the camera icon)
Alex = the recipient = the user receiving the call


Now, let's add the opentok gem in our gemfile:
```ruby
gem "opentok", "~> 3.1.0"
```
Run bundle install.

Next, add the opentok client SDK in your ```application.html.erb``` file, just above your bootstrap script tags:
```html
<script src="https://static.opentok.com/v2/js/opentok.min.js"></script>
```
Now just like we stored aws credentials, store your opentok credentials by adding them in your ```local_env.yml``` file like this:
```yml
TOKBOX_API_KEY: 'your_tokbox_api_key'
TOKBOX_SECRET_KEY: 'your_toxbox_secret_key'
```

  ###### IX- 3. Creating the room channel
The next thing we need to do is to create a room channel:
```terminal
rails g channel room
```
  ###### IX- 4. Sending Incoming call notification 
Then, go to your ```javascript/channels/room_channel.js``` and add the ```consumer.subscriptions.create("RoomChannel", {``` block in a constant like this:
```javascript
const roomSubscriber = consumer.subscriptions.create("RoomChannel", {
...
```
Next, export the ```roomSubscriber``` constant at the bottom of the file:
```javascript
export default roomSubscriber
```
Import ```roomSubscriber``` in your ```script.js``` by adding this: 
```javascript
import roomSubscriber from '../channels/room_channel'
```
Now, let's add event listeners to the camera icons. In your ```script.js``` file, add this code:
```javascript
// Add an event listener to call buttons
    var cameraIcons = document.getElementsByClassName('camera-icon');
    for (let item of cameraIcons) {
      item.addEventListener('click', (event) => {
        event.preventDefault();
        var recipient_id = item.getAttribute("data-id");
        var recipient_name = item.getAttribute("data-name");
        console.log(recipient_id);
        console.log(recipient_name);
        var recipient_name_modal = document.getElementById('recipient_name_modal');
        recipient_name_modal.innerHTML = recipient_name;
        $('#sender-notif-modal').modal('show');

        roomSubscriber.call(recipient_id);
      })
    }
```
###### ```Explanation```
When David clicks on Alex's camera icon, the sender modal pops up, filled with Alex's name. Then, we call the ```call``` function of the ```roomSubscriber``` (not yet defined), passing Alex's id as argument.


Let's go ahead and create the ```call``` function. In your ```javascript/channels/room_channel.js``` file, add the call function right below the ```received``` function like this:
```javascript
...

received(data) {
  ...
},

call(recipient_id, recipient_name) {
    return this.perform('call', {
      recipient_id: recipient_id
    });
}
```
In this method, we call the ```call``` method on the our ```app/channels/room_channel.rb``` file (not yet defined). That method is going to be responsible for broadcasting a notification to Alex.

In ```app/channels/room_channel.rb```, add this code below the unsubscribed method:
```ruby
def call(data)
    recipient_id = data['recipient_id']
    @session = create_session
    session_id = @session.session_id
    broadcast_notif_to_recipient(recipient_id, session_id)
end
```
###### ```Explanation```
We create the session, then we get the session id, then we call ```broadcast_notif_to_recipient```, passing in Alex's id and the session id we just got. ```create_session``` and ```broadcast_notif_to_recipient``` are methods that we need to define. Let's do that:
###### ``````app/channels/room_channel.rb```
```ruby
private
  
def broadcast_notif_to_recipient(recipient_id, session_id)
    ActionCable.server.broadcast(
      "room_#{recipient_id}",
      sender_first_name: current_user.name,
      sender_id: current_user.id,
      session_id: session_id,
      step: 'receiving the call'
    )
end

def api_key
    ENV['TOKBOX_API_KEY']
end

def secret_key
    ENV['TOKBOX_SECRET_KEY']
end

def opentok
    OpenTok::OpenTok.new api_key, secret_key
end

def create_session
    opentok.create_session :media_mode => :routed
end

def create_token(session_id)
    opentok.generate_token(session_id)
end

```
As you can see above, we created an opentok instance, passing in the opentok credentials. We then used that instance to create a session with ```opentok.create_session``` (see https://tokbox.com/developer/guides/create-session/ruby/  ). We also generate a token for our session (see https://tokbox.com/developer/guides/create-token/ruby/ ). 
Using ```ActionCable.server.broadcast```, we broadcast to ```room_#{recipient_id}``` (which means that only Alex will get this signal), passing in David's name, his id, the session_id and the ```step```.
The step is very important because it's going to allow us to know what action is taking place(user receiving the call, broadcasting session to the recipient, or broadcasting session to the sender)


To make this work, remove the content of your ```subscribed``` method and add this: 
```ruby
stream_from "room_#{current_user.id}"
```
also, add ```stop_all_streams``` to the ```unsubscribe``` method.

Now let's head to our ```app/javascript/room_channel.js```. Inside the ```received``` function, add this: 

```javascript
if (data['step'] === 'receiving the call'){

     var sender_first_name = data['sender_first_name'];
     var sender_id = data['sender_id'];
     var session_id = data['session_id'];
     var session_id_modal = document.getElementById('session_id');
     session_id_modal.innerHTML = session_id;
     var sender_id_modal = document.getElementById('sender_id');
     sender_id_modal.innerHTML = sender_id;
     var sender_name_modal = document.getElementById('sender_name');
     sender_name_modal.innerHTML = sender_first_name;
     
     // Display the receiver notification modal
     $('#receiver-notif-modal').modal('show');

}
```
###### ```Explanation```
We get the ```step``` value is 'receiving the call', fill Alex's notification modal with David's name and id, then we display it to Alex.

  
  ###### IX- 5. Answering the call

Now, we need to handle the second phase of our feature: answering the call. As you probably saw in the demo, when Alex receives the call (when the notif modal pops up), all he needs to do is click on the red camera icon to start the video session with David. To implement that part of the feature, let's add an event listener that red camera icon. In your ```script.js``` file, add this block of code: 
```javascript
// Call the answer method when the answer_btn is clicked.
    const answerBtn = document.getElementById("answer-call");
    answerBtn.addEventListener('click', (event) => {
      event.preventDefault();
      var session_id = document.getElementById("session_id").innerHTML;
      var sender_id = document.getElementById('sender_id').innerHTML;
      console.log(session_id);
      console.log("answer btn clicked");
      $('#receiver-notif-modal').modal('hide');
      roomSubscriber.answer(session_id, sender_id);
    });
```
###### ```Explanation```
When the red camera icon is clicked, we hide the notification modal and we call the ```answer``` function on ```app/javascript/channels/room_channel.js```(not defined), passing the session_id and David's id as arguments. 

Now, in ```app/javascript/channels/room_channel.js```, let's create the ```answer``` function below the ```call``` function:
```javascript
call(recipient_id, recipient_name) {
	...
}, // Don't forget this comma

answer(session_id, sender_id) {
    console.log(`Hello from the answer method: ${session_id}`);
    return this.perform('answer', {
        session_id: session_id,
        sender_id: sender_id
    });
}
```
Just like in our ```call``` function, all we do here is calling the ```answer``` method on the server side. Let's create that method in our ```app/channels/room_channel.rb``` file.
```ruby
def answer(data)
   session_id = data["session_id"]
   sender_id = data["sender_id"]
   broadcast_session_to_recipient(session_id)
   broadcast_session_to_sender(session_id, sender_id)
end
```
In the ```answer``` method, we broadcast the session to both David and Alex. Define ```broadcast_session_to_recipient``` and ```broadcast_session_to_sender``` methods in the ```private``` section:
```ruby
# Brodcast the session to the recipient
  def broadcast_session_to_recipient(session_id)
    token = create_token(session_id)
    ActionCable.server.broadcast(
      "room_#{current_user.id}",
      apikey: api_key,
      session_id: session_id,
      token: token,
      step: 'Broadcasting session to the recipient'
    )
  end

  def broadcast_session_to_sender(session_id, sender_id)
    token = create_token(session_id)
    ActionCable.server.broadcast(
      "room_#{sender_id}",
      apikey: api_key,
      session_id: session_id,
      token: token,
      step: 'Broadcasting session to the sender'
    )
  end
```
We now need these two steps ('Broadcasting session to the recipient' and 'Broadcasting session to the sender').


  ###### IX- 6. Connecting to the session - disconnecting from the session
  
  
Head back to the ```received``` function of our ```room_channel.js``` file and add this:
```javascript

// ============ BROADCASTING THE SESSION TO THE RECIPIENT.=====================================================
    if (data['step'] === 'Broadcasting session to the recipient') {
      console.log('Broadcasting the session to the recipient');
      // Initialize the session
      const session = OT.initSession(data['apikey'], data['session_id']);

      // Initialize the publisher for the recipient
      var publisherProperties = {insertMode: "append", width: '100%', height: '100%'};
      const publisher = OT.initPublisher('publisher', publisherProperties, function (error) {
        if (error) {
          console.log(`Couldn't initialize the publisher: ${error}`);
        } else {
          console.log("Receiver publisher initialized.");
        }
      });
      $('#session-modal').modal("show");

      // Detect when new streams are created and subscribe to them.
      session.on("streamCreated", function (event) {
        console.log("New stream in the session");
        var subscriberProperties = {insertMode: 'append', width: '100%', height: '100%'};
        const subscriber = session.subscribe(event.stream, 'subscriber', subscriberProperties, function(error) {
          if (error) {
            console.log(`Couldn't subscribe to the stream: ${error}`);
          } else {
            console.log("Receiver subscribed to the sender's stream");
          }
        });
      });

      //When a stream you publish leaves a session, the Publisher object dispatches a streamDestroyed event:
      publisher.on("streamDestroyed", function (event) {
        console.log("The publisher stopped streaming. Reason: "
        + event.reason);

      });

      //When a stream, other than your own, leaves a session, the Session object dispatches a streamDestroyed event:
      session.on("streamDestroyed", function (event) {
        console.log("Stream stopped. Reason: " + event.reason);
      });


      session.on({
        connectionCreated: function (event) {
          if (event.connection.connectionId != session.connection.connectionId) {
            connectionCount++;
            console.log(`Another client connected. ${connectionCount} total.`);
          }
        },
        connectionDestroyed: function connectionDestroyedHandler(event) { // When David hangs up, we end Alex's connection to the session and we hide his session window.
          connectionCount--;
          console.log(`A client disconnected. ${connectionCount} total.`);
          session.disconnect();
          $('#session-modal').modal('hide');


        }
      });

      session.on("sessionDisconnected", function(event) {
        console.log("The session disconnected. " + event.reason);
      });

      // Connect to the session
      // If the connection is successful, publish an audio-video stream.
      session.connect(data['token'], function(error) {
        if (error) {
          console.log("Error connecting to the session:", error.name, error.message);
        } else {
          console.log("Connected to the session.");
          session.publish(publisher, function(error) {
            if (error) {
              console.log(`couldn't publish to the session: ${error}`);
            } else {
              console.log("The receiver is publishing a stream");
            }
          });
        }
      });
      
      // Whenever Alex clicks on the stopSessionBtn(the red camera icon on the session modal), we end his connection to the session and we hide his session modal.
      const stopSessionBtn = document.getElementById("stop-session");
      stopSessionBtn.addEventListener('click', (event)=> {
        event.preventDefault();
        console.log("stop-session btn clicked");
        session.disconnect();
        $('#session-modal').modal('hide');

      });


    }

// ============ BROADCASTING THE SESSION TO THE SENDER.=====================================================
    if (data['step'] === 'Broadcasting session to the sender') {
      console.log('Broadcasting the session to the sender');

      // Initialize the session
      const session = OT.initSession(data['apikey'], data['session_id']);
      console.log(session);
      
      // Hide the modal
      $('#sender-notif-modal').modal("hide");
      
      // Initialize the publisher for the sender
      var publisherProperties = {insertMode: "append", width: '100%', height: '100%'};
      const publisher = OT.initPublisher('publisher', publisherProperties, function (error) {
        if (error) {
          console.log(`Couldn't initialize the publisher: ${error}`);
        } else {
          console.log("Sender publisher initialized.");
        }
      });
      
      // Show the session modal
      $('#session-modal').modal("show");
      
      // Detect when new streams are created and subscribe to them.
      session.on("streamCreated", function (event) {
        console.log("New stream in the session");
        var subscriberProperties = {insertMode: 'append', width: '100%', height: '100%'};
        const subscriber = session.subscribe(event.stream, 'subscriber', subscriberProperties, function(error) {
          if (error) {
            console.log(`Couldn't subscribe to the stream: ${error}`);
          } else {
            console.log("Sender subscribed to the receiver's stream");
          }
        });
      });

      //When a stream you publish leaves a session the Publisher object dispatches a streamDestroyed event:
      publisher.on("streamDestroyed", function (event) {
        console.log("The publisher stopped streaming. Reason: "
        + event.reason);
      });

      //When a stream, other than your own, leaves the Session
      session.on("streamDestroyed", function (event) {
        console.log("Stream stopped. Reason: " + event.reason);
      });

      session.on({
        connectionCreated: function (event) {
          if (event.connection.connectionId != session.connection.connectionId) {
            connectionCount++;
            console.log(`Another client connected. ${connectionCount} total.`);
          }
        },
        connectionDestroyed: function connectionDestroyedHandler(event) { // When Alex hangs up, we end David's connection to the session and we hide his session window.
          connectionCount--;
          console.log(`A client disconnected. ${connectionCount} total.`);
          session.disconnect();
          $('#session-modal').modal('hide');
        }
      });

      session.on("sessionDisconnected", function(event) {
        console.log("The session disconnected. " + event.reason);
      });

      // Connect to the session
      // If the connection is successful, publish an audio-video stream.
      session.connect(data['token'], function(error) {
        if (error) {
          console.log("Error connecting to the session:", error.name, error.message);
        } else {
          console.log("Connected to the session.");
          session.publish(publisher, function(error) {
            if (error) {
              console.log(`couldn't publish to the session: ${error}`);
            } else {
              console.log("The sender is publishing a stream");
            }
          });
        }
      });
	
      // Whenever David clicks on the stopSessionBtn(the red camera icon on the session modal), we end his connection to the session and we hide his session modal.
      const stopSessionBtn = document.getElementById("stop-session");
      stopSessionBtn.addEventListener('click', (event)=> {
        event.preventDefault();
        console.log("stop-ssesion btn clicked");
        session.disconnect();
        $('#session-modal').modal('hide');



      });

    }
```

###### ```Explanation```
I added comments to the code so you can understand it better. 

Waouhh!!! that's a lot of code. But it's fairly self-explanatory. You can always check https://tokbox.com/developer/guides/ if there's something you still don't get.


If you test the app, you'll see that everything is working perfectly. 

Finally, let's add some media queries in our ```home.scss``` file to make our app look good on smaller devices.

###### ```home.scss```
```css
/*================================= MEDIA QUERIES ==============================*/

@media (max-width: 800px) {

  .navbar-nav .state-btn {
     margin: 5px 0px;
  }

  .jumbotron {
    text-align: center;
    h1 {
      font-size: 28px;
      width: 100%;
    }
    p {
      font-size: 14px;
      width: 100%;
    }
  }
  

}
```



###### NOTE:
The screen-sharing functionality only works on https. So localhost:3000 is not going to work. Deploy your app to Heroku to use the screen-sharing functionality. Don't forget to add your opentok credentials in your Heroku app's ```config vars```.



This is the end of our building process (at least for this version of the app) . I'll continue to update this app by adding new functionalities. You will get an email everytime there's a new version (free of charge if you already bought the first version). You can get the full code for this project at https://github.com/fredericscode/Final .


Email me at fredericscode@gmail.com if you have any question.

Thank you for following along. See you next time.

























<p align="center">
  <img src="https://github.com/fredericscode/rails/blob/master/app/assets/images/Workathome.png">
</p>


























