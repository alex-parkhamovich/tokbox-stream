class StreamsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  
  def index
  end

  def new
    if current_user && current_user.stream
      redirect_to current_user.stream
    else
      create_stream_with_tok_session_service
      redirect_to stream, notice: 'Nice! You are ready to start a stream!'
    end
  end

  def show
    populate_gon_vars
  end

  def create
    if create_stream_with_tok_session_service
      redirect_to stream, notice: 'Nice! You are ready to start a stream!'
    else
      flash.now[:alert] = 'Please fix these errors first: %s' % stream.errors.full_messages.first
      render :new
    end
  end

  private

  def create_stream_with_tok_session_service
    stream.title = "#{current_user.email.split('@').first}'s stream"
    session = OpenTokClient.create_session
    stream.session_id = session.session_id
    stream.save
  end

  def stream
    @stream ||= if params[:id]
                  Stream.find(params[:id])
                else
                  current_user.build_stream(stream_params)
                end
  end
  helper_method :stream

  def streams
    @streams ||= Stream.all
  end
  helper_method :streams

  def populate_gon_vars
    role = stream_role_for_user(user: current_user, stream: stream)
    gon.opentok = {
        sessionId: stream.session_id,
        apiKey: Figaro.env.opentok_api_key,
        token: OpenTokClient.generate_token(stream.session_id, {role: role}),
        role: role
    }
  end

  def stream_role_for_user(stream:, user:)
    user && user.id == stream.user_id ? :publisher : :subscriber
  end

  private

  def stream_params
    params.fetch(:stream, {}).permit(:title, :desc)
  end

end
