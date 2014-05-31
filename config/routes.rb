SavingsOrganizer::Application.routes.draw do

  root "users#signin" # specifes default web page for application

  get "users/signin"
  get "users/registration"
  get "users/welcome"
  get "users/view"
  get "accounts/create"
  get "accounts/view"  
  get "categories/create"
  get "categories/view"
  get "entries/add"
  get "entries/deduct"
  get "entries/view"

  post "users/signin"
  post "users/registration"
  post "users/welcome"
  post "users/view"  
  post "accounts/create"
  post "accounts/view"  
  post "categories/create"
  post "categories/view"  
  post "entries/add"
  post "entries/deduct"
  post "entries/view"

end
