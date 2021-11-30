# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleDecorator do
  let(:article) { Article.new.extend ArticleDecorator }
  subject { article }
  it { should be_a Article }
end
