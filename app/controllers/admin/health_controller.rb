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
        body_fat = params[:body_fat]

        if !params[:uid].present?
            render json: { status: 'error', message: 'error parameter' }, status: :ok
        else
            #user = User.where("account == ? AND phone == ?", uid , phone)
            user = User.find(uid.to_i)
            if user.nil?
                render json: { status: 'error', message: 'error user' }, status: :ok
            else

                text = "BMI: #{bmi}\n"
                text += "心跳: #{heart_rate}\n"
                text += "收縮壓: #{blood_pressure1}\n"
                text += "舒張壓: #{blood_pressure2}\n"
                text += "血糖: #{blood_sugar}\n"
                text += "體溫: #{temperature}\n"
                text += "血氧: #{blood_oxygen}\n"
                text += "體脂: #{body_fat}"

                user_text = "Hi , 你有一份健康報告 : \n"
                user_text += text
                message_push(user.account, user_text)

                caregiver = user.caregivers.first
                if !caregiver.nil?
                    caregiver_text = "Hi , 你的照護者「#{user.name}」有一份健康報告 : \n"
                    caregiver_text += text
                    message_push(caregiver.account, caregiver_text)
                end

                report = user.health_reports.new(bmi: bmi, heart_rate: heart_rate, blood_pressure1: blood_pressure1, blood_pressure2: blood_pressure2, blood_sugar: blood_sugar, temperature: temperature, blood_oxygen: blood_oxygen, body_fat: body_fat)
                report.save

                render json: { status: 'success', message: 'Message sent successfully' }, status: :ok
            end
        end

    end

end
