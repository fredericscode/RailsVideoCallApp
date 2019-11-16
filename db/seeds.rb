# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'faker'

20.times do |t|
    User.create(name: Faker::Name.unique.name, email: Faker::Internet.unique.email, level: "Senior", github_link: "https://github.com/frederic92", password: "frederic")
end
