# -*- encoding : utf-8 -*-
class Admin::HealthController < ApplicationController
    include LineHelper

    def send_message
        uid = params[:uid]
        phone = params[:phone]
        bmi = params[:bmi]
        heart_rate = params[:heart_rate]
        blood_pressure1 = params[:blood_pressure1]
        blood_pressure2 = params[:blood_pressure2]
        blood_sugar = params[:blood_sugar]
        temperature = params[:temperature]
        blood_oxygen = params[:blood_oxygen]

        if !params[:uid].present?
            render json: { status: 'error', message: 'error parameter' }, status: :ok
        else
            #user = User.where("account == ? AND phone == ?", uid , phone)
            user = User.where("account == ?", uid).first
            if user.nil?
                render json: { status: 'error', message: 'error user' }, status: :ok
            else
                text  = "Hi , 你有一份健康報告 : \n"
                text += "BMI: #{bmi}\n"
                text += "心跳: #{heart_rate}\n"
                text += "收縮壓: #{blood_pressure1}\n"
                text += "舒張壓: #{blood_pressure2}\n"
                text += "血糖: #{blood_sugar}\n"
                text += "體溫: #{temperature}\n"
                text += "血氧: #{blood_oxygen}"
                puts "AAAAAAAAAAAA"
                puts text
                message = message_package_text(text)
                message_push(user.account, message)
                render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
            end
        end 

    end

end
