class CommunityResolver
  RESERVED_SUBDOMAINS = %w[www].freeze

  def initialize(request:, params:, session:, admin_subdomain_request:, current_user: nil, current_admin: nil)
    @request = request
    @params = params
    @session = session
    @admin_subdomain_request = admin_subdomain_request
    @current_user = current_user
    @current_admin = current_admin
  end

  def resolve
    return nil unless community_table_ready?

    persist_sn_from_param!

    by_sn = find_by_sn
    return by_sn if by_sn.present?

    by_host = find_by_host
    return by_host if by_host.present?

    by_subdomain = find_by_subdomain
    return by_subdomain if by_subdomain.present?

    by_actor
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    nil
  end

  private

  def community_table_ready?
    Community.table_exists?
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    false
  end

  def persist_sn_from_param!
    sn = @params[:sn].to_s.strip
    return if sn.blank?

    @session[:sn] = sn
  end

  def find_by_sn
    sn = @session[:sn].to_s.strip
    return nil if sn.blank?

    Community.enabled.find_by(sn: sn)
  end

  def find_by_host
    host = @request.host.to_s.downcase
    return nil if host.blank?

    Community.enabled.find_by(host: host)
  end

  def find_by_subdomain
    return nil if @admin_subdomain_request

    subdomain = @request.subdomain.to_s.downcase
    return nil if subdomain.blank? || RESERVED_SUBDOMAINS.include?(subdomain)

    Community.enabled.find_by("LOWER(name_eng) = ?", subdomain)
  end

  def by_actor
    @current_user&.community || @current_admin&.community || Community.enabled.sorted.first
  end
end
