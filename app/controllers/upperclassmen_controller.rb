class UpperclassmenController < ApplicationController
  def index
    @upperclassmen = []

    # Gets the upperclassmen and how many signatures they have
    uppers = Upperclassman.all
    uppers.each do |u|
      signatures = u.signatures.where(is_signed: true)
      @upperclassmen.push([u, signatures.length])
      end
    # Sort the upperclassmen based on highest signature count, then id
    @upperclassmen.sort! {|a,b| [b[1],a[0].id] <=> [a[1],b[0].id]}
  end

  def show
    # If no paramaters are given, make the it user's page.
    # If exception, redirect to signature/index
    begin
      if !params[:id]
        params[:id] = @user.id
      end
    rescue
      params[:id] = 1
      redirect_to signatures_path
    end

    @upperclassman = Upperclassman.find(params[:id]) # Get the upperclassman object

    # Gets the signatures and freshmen objects needed
    u_signatures = @upperclassman.signatures
    @signatures = []
    signed = 0.0
    u_signatures.each do |s|
      # signatures will be a list of [Freshman, Signature]
      @signatures.push([Freshman.find(s.freshman_id).name, s])
      if s.is_signed
        signed += 1
      end
    end
    # Sort the signatures
    @signatures.sort! {|a,b| b[1] <=> a[1]}

    # Gets the information for the progress bar
    progress = (signed / u_signatures.length * 100).round(2)
    @progress_color = ""
    if progress < 10
      @progress_color = "progress-bar-danger"
    elsif progress < 60
      @progress_color = "progress-bar-warning"
    elsif progress < 100
      @progress_color = "progress-bar-info"
    else
      @progress_color = "progress-bar-success"
    end
    @progress = progress.to_s

  end
end