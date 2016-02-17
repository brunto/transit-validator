require 'rails_helper'

RSpec.describe Job, type: :model do
  it 'has a valid factory' do
    expect(build(:job, :import)).to be_valid
  end

  context '#import' do
    let(:job_import) { build(:job, :import) }
    let(:job_import_with_url) { build(:job, :import_with_url) }
    let(:job_import_with_wrong_url) { build(:job, :import_with_wrong_url) }

    it 'has empty format_convert' do
      expect(job_import.format_convert).to be_nil
    end

    it 'has a valid factory with url' do
      User.destroy_all
      expect(job_import_with_url).to be_valid
    end

    it 'has an error on invalid url' do
      job_import_with_wrong_url.valid?
      expect(job_import_with_wrong_url.errors.messages).to have_key(:url)
    end
  end

  context '#export' do
    let(:job_export) { build(:job, :export) }

    it 'has a format_convert' do
      expect(job_export.format).to_not be_nil
      expect(job_export.format_convert).to_not be_nil
      expect(job_export.format_convert).to_not eq(job_export.format)
    end

    it 'has error on same format' do
      job = build(:job, :import_export)
      expect(job).to_not be_valid
      expect(job.errors.messages).to have_key(:format_convert)
    end
  end
end
