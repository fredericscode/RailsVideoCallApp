<h2>How to build a live, face-to-face video chat app in Ruby on Rails 6.0.2.1</h2>

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
  <%= link_to "Sign up", register_path %><br />
<% end %>
```
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
Go to ```views/home/index.html.erb``` file and add the following code.
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


We also need to create a partial to display each user. Create ```views/home/partials/_user-card.html``` file and add the following code:
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

Next, create ```home/partials/nav/dropdown/_gofflinebtn.html.erb``` and ```home/partials/nav/dropdown/_gonlinebtn.html.erb``` (leave them empty for now) and run the server.



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
Define the ```btnStart``` method in ```helpers/home_helper.rb```:
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
Now our home page looks beautiful.






















### VI- Styling Devise notifications with Bootstrap

Devise alerts are really ugly, let's make them look good. First, go to your ```app/views/layouts/application.html.erb``` file and add this code right below the opening tag of the body element:
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
That's it!!! Now whenever a user logs in, registers or logs out, you have beautiful notifications displayed on top of the navbar.























### VII- Image upload on AWS S3

Now is time to allow users to choose a profile picture and upload it to aws using active storage.
First, go to ```config/environments/development.rb``` and change ```config.active_storage.service = :local``` to ```config.active_storage.service = :amazon```. Then, uncomment the amazon section in your ```config/storage.yml``` and add your AWS S3 credentials.
```yml
# Use rails credentials:edit to set the AWS secrets (as aws:access_key_id|secret_access_key)
amazon:
  service: S3
  access_key_id: <%= ENV["ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["SECRET_ACCESS_KEY"] %>
  region: your_region
  bucket: you_bucket
```
To secure your credentials, you can use rails credentials to store them, but I prefer to store mine inside environment variables. To do that, let's create a ```config/local_env.yml``` file. And inside that file, we are going to store our credentials like this:
```yml
AWS_ACCESS_KEY_ID: 'my_access_key_id'
AWS_SECRET_ACCESS_KEY: 'my_secret_access_key'
```

After setting our variables, we have to set those env variables into config/application.rb file.
In the config/application.rb file, add the below code:
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
Explanation: In the online action, we just change the developer's state to 'online' with ```current_user.online```. After that, since it's an ajax request(remote), we respond with javascript format, which means that Rails is going to look for a ```views/home/online.js.erb``` file and run it. Same for the offline method, Rails is going to look for and run a ```views/home/offline.js.erb```. Let's create those two files.
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
onBtn.classList.add("d-none")

var offlineBtn = document.getElementById("js-offlinebtn")
offBtn.classList.remove("d-none")
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

This broadcast is going to be received by the ```received``` function of our ```app/javascript/channels/appearance_channel.js``` file. Inside that function, add this piece of code:
```javascript
//=================== IF THE USER IS ONLINE ============================//////////////
if (data['state'] === "online") {
  var dot = document.getElementById("js-appearance" + data['user_id']);
  //var user_state = document.getElementById("user-state" + data['user_id']);
  var camera_icon = document.getElementById("js-camera-icon" + data['user_id']);
  if (dot != null && camera_icon != null) { // This values are null for the current_user
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
        <!--class="modal-title" id="exampleModalLabel"-->
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



```css
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
    
```



<p align="center">
  <img src="https://github.com/fredericscode/rails/blob/master/app/assets/images/Workathome.png">
</p>


























