class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :destroy]
  before_action :job, only: [:show, :progress, :short_url, :status, :validation, :convert, :download_validation, :download_convert]

  def index
    @jobs = Job.find_my_job(current_user).page(params[:page])
  end

  def show
    if @job.is_terminated?
      redirect_to @job.format_convert.present? ? convert_job_path(@job) : validation_job_path(@job)
    else
      progress_steps
    end
  end

  def progress
    progress_steps
    render json: @datas
  end

  def short_url
    respond_to do |format|
      format.js
    end
  end

  def status
    respond_to do |format|
      format.js
    end
  end

  def validation
    @default_view = params[:default_view] ? params[:default_view].to_sym : :files
    @action_report = @job.action_report
    @validation_report = ValidationService.new(@job.validation_report, @action_report, params[:q])
    if @default_view == :files
      @elements_to_paginate = @filenames = Kaminari.paginate_array(@validation_report.filenames).page(params[:page]).per(ENV['NUMBER_RESULTS_PER_PAGE'])
      @lines = @validation_report.lines
      @total_elements = @validation_report.filenames.count
    else
      @elements_to_paginate = @lines = Kaminari.paginate_array(@validation_report.lines).page(params[:page]).per(ENV['NUMBER_RESULTS_PER_PAGE'])
      @filenames = @validation_report.filenames
      @total_elements = @validation_report.lines.count
    end
    @tests = @validation_report.tests
    @search = @validation_report.search
  end

  def convert; end

  def download_validation
    validation_report = ValidationService.new(@job.validation_report, @job.action_report)
    validation_report.default_view = params[:default_view]
    send_data validation_report.to_csv, filename: "#{@job.name.parameterize}-#{@job.id}-#{Time.current.to_i}.csv"
  end

  def download_convert
    file = @job.list_links[:output] ? @job.list_links[:output] : @job.list_links[:data]
    send_data @job.convert_report, filename: File.basename(file), type: 'application/zip'
  end

  def cancel
    job = Job.find_with_id_and_user(params[:id], (user_signed_in? ? current_user.id : nil))
    job.ievkit_cancel_or_delete(:cancel)
    job.destroy
    redirect_to root_path
  end

  def destroy
    job = Job.find_by(id: params[:id], user: current_user)
    job.ievkit_cancel_or_delete(:delete)
    job.destroy
    redirect_to root_path
  end

  private

  def job
    @job = Job.find(params[:id])
  end

  def progress_steps
    @datas = @job.is_terminated? ? { redirect: job_path(@job) } : @job.progress_steps
  end
end
