class UpdateHealthReport
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform

    User.all.map do |user|
        # Get current time including milliseconds
        current_time = Time.now
        milliseconds = (current_time.to_f * 1000).to_i % 1000
        formatted_time = "#{current_time.strftime('%Y-%m-%d %H:%M:%S')}.#{milliseconds.to_s.rjust(3, '0')}"
        puts "Processing user: #{user.id}, at time: #{formatted_time}"
        user.update(nhi_id: formatted_time)
  end
end
