SavingsOrganizer::Application.routes.draw do

  root "users#signin" # specifes default web page for application

  get "users/signin"
  get "users/registration"
  get "users/welcome"
  get "accounts/create"
  get "categories/create"
  get "entries/add"
  get "entries/deduct"
  get "entries/view"

  post "users/signin"
  post "users/registration"
  post "users/welcome"
  post "accounts/create"
  post "categories/create"
  post "entries/add"
  post "entries/deduct"
  post "entries/view"

end
