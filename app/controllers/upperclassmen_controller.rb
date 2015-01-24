class UpperclassmenController < ApplicationController
  before_action :authenticate_upperclassman!

  def index
    # Define title
    @title = "Upperclassmen Signatures"

    @upperclassmen = []
    # Gets the upperclassmen and how many signatures they have
    uppers = Upperclassman.where(alumni: false)
    uppers.each do |u|
      signatures = u.signatures.includes(:freshman).where("freshmen.doing_packet" => true)
      @upperclassmen.push([u, signatures.length])
      end
    # Sort the upperclassmen based on highest signature count, then alphabetically
    @upperclassmen.sort! {|a,b| [b[1],a[0].name.downcase] <=> [a[1],b[0].name.downcase]}
  end

  def show
    # If no paramaters are given, make the it user's page.
    if not params[:id]
      params[:id] = @current_upperclassman.id
    end

    # If upperclassman exists, get upperclassman object, otherwise redirect
    if Upperclassman.exists?(params[:id])
      @upperclassman = Upperclassman.find(params[:id])
    else
      flash[:error] = "Invalid upperclassman page"
      redirect_to upperclassmen_path
      return
    end

    # Define title
    @title = "#{@upperclassman.name}'s Signatures"

    # Get all freshmen objects doing the packet
    freshmen = Freshman.where(doing_packet: true).order(name: :asc)
    
    # Get the signed freshmen
    @signed_freshmen = []
    @upperclassman.signatures.each do |s|
      if s.freshman.doing_packet
        @signed_freshmen.push(s.freshman)
      end
    end

    # Sort the signed freshmen array alphabetically
    @signed_freshmen.sort_by!{ |s| s.name }
    
    # Get the unsigned freshmen
    @unsigned_freshmen = freshmen - @signed_freshmen
    
    # Gets the information for the progress bar
    @progress = (100.0 * @signed_freshmen.length / freshmen.length).round(2).to_s
    @freshmen_length = freshmen.length
  end
end
