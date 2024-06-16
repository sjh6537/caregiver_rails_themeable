class NotifySender
    include Sidekiq::Worker
    include LineHelper
    sidekiq_options retry: false
    
    def perform(recipients, line_message, send_type = LINE_MSG_TYPE_TEXT)
        recipient_name = ""
        recipients.each do |recipient|
            line_user = User.find_by_id(recipient)
            if line_user
                message_push(line_user.account, line_message)
            end
            recipient_name << line_user.line_name
        end
        result = {notice: I18n.t("Website.Note.Line_send_person_success", name: "#{recipient_name}")}
    end


end
