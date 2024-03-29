class AlbumsController < ApplicationController
  before_action :set_album, only: %i[edit update destroy delete_image add_image image]

  attr_accessor :render_target

  after_action :analyze_album, only: %i[create add_image]
  after_action :verify_authorized, if: -> { Rails.env.development? }

  # GET /albums
  def index
    authorize Album
    @albums = Album.all.order(created_at: :desc)
    @title  = 'Minden album'
  end

  # GET /albums/myalbums
  def myalbums
    authorize Album
    @albums = Album.where(user: current_user).order(created_at: :desc)
    @title  = 'Albumaim'
    render :index
  end

  # GET /albums/1
  def show
    @album = Album.includes(:album_images).find(params[:id])
    authorize @album
  end

  # GET /albums/new
  def new
    authorize Album
    @album   = Album.new
    @circles = current_user.memberships.where(accepted: true).map(&:circle)

    redirect_to circles_path, notice: 'Nincs körtagsága, nem hozhat létre kört!' if @circles.empty?
  end

  # GET /albums/1/edit
  def edit
    authorize @album
  end

  # POST /albums
  def create
    authorize Album
    @render_target = :new

    @album = Album.new(album_params)
    @album.build_images params[:album][:images]
    @album.user = current_user

    if @album.save
      redirect_to @album, notice: 'Album sikeresen létrehozva.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /albums/1
  def update
    authorize @album
    @render_target = :edit

    if @album.update(album_params)
      redirect_to @album, notice: 'Album sikeresen módosítva.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /albums/1
  def destroy
    authorize @album
    @album.album_images.each do |image|
      image.file.purge
    end

    @album.destroy
    redirect_to albums_url, notice: 'Album sikeresen törölve.'
  end

  # GET /albums/1/image?image_id=1
  def image
    authorize @album
    image = @album.album_images.find_by(id: params[:image_id])
    return render json: { status: 404 }, status: :not_found if image.blank?

    render json: {
      url: url_for(image),
      filename: image.file.blob.filename
    }
  end

  # DELETE one image of the album
  def delete_image
    authorize @album
    image = AlbumImage.find(params[:image_id])
    image.file.purge
    image.destroy!
    redirect_to @album
  end

  # POST add image(s) to the album
  def add_image
    authorize @album
    images = params[:images]
    @album.build_images(images) if images.present?
    @album.save
    redirect_to @album, notice: 'Album sikeresen módosítva.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_album
    @album = Album.find(params[:id])
  end

  # Analyze all the images for their width and height
  def analyze_album
    @album.images.map(&:file).each { |i| i.analyze unless i.analyzed? }
  end

  # Only allow a list of trusted parameters through.
  def album_params
    params.require(:album).permit(:title, :desc, :shared, :public, :tag, :circle_id)
  end
end
