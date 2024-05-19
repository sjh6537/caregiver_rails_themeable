# -*- encoding : utf-8 -*-
class LiffController < ApplicationController

    def url_to
        url = params["liff.state"]
        session[:return_to] = url
        cookies[:return_to] = url
        redirect_to url
    end

end
