class Api::ApplicationController < ActionController::Base
  # https://railsguides.jp/security.html#csrf%E3%81%B8%E3%81%AE%E5%AF%BE%E5%BF%9C%E7%AD%96
  # https://techtechmedia.com/invalid-authenticity-token-api/
  protect_from_forgery
end