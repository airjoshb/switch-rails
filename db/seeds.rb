# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Product.create([
  {name: "Gluten-Free Baguette", description: "A fresh, crusty, gluten-free baguette."},
  {name: "Gluten-Free Sandwich Buns", description: "A soft, fluffy bun for your burger or sandwich."},
  {name: "Keto Pecan Bundt Cake", description: "A sugar-free cake worthy of your dessert table."},
  {name: "A Cake for Two", description: "A proper layer cake just big enough to share, or not."}
])