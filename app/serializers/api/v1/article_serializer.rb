# class Api::V1::ArticleSerializer < ActiveModel::Serializer
#   attributes :id, :title, :url, :published, :medium_name
#   # , :image, :categories, :deleted_at

#   def medium_name
#     Medium.find(object.medium_id).name ||= "" # guard nil
#   end
# end
