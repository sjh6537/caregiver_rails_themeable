class User::RequestReceiver < ActiveRecord::Base
    belongs_to :request
    belongs_to :receiver , class_name: 'User' , :foreign_key => "receiver_id"
end
