module Web
  class InviteController < ApplicationWebController
    before_action :set_user, only: %i[edit update]

    def edit
      @user.add_each_friends(@friend.id)
      return if @user.name == '' || @user.addr_city.zero? || @user.addr_postal.zero? || @user.address == ''

      redirect_to web_invite_join_path
    end

    def update
      result = @user.update(user_params)
      if result
        redirect_to web_invite_join_path
      else
        render action: 'edit', alert: I18n.t('Website.Note.Update_Fail', name: @user.line_name.to_s)
      end
    end

    def join
      redirect_to APP_CONFIG[:line_at_url], allow_other_host: true
    end

    private

    def set_user
      @user = current_user
      @friend = User.find_by_id(params[:friend_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit!
    end
  end
end
