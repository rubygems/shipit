class PingController < ActionController::Base
  def ping
    render plain: 'PONG'
  end

  def revision
    render plain: __revision.to_s
  end

  private

  def __revision
    File.read('REVISION')
  end
end
