module RailsAdminSettings
  module Uploads
    autoload :CarrierWave, "rails_admin_settings/storage/carrierwave"

    def self.paperclip_options
      if defined?(Rails)
        {}
      else
        {path: "#{File.dirname(__FILE__)}/../../uploads/:filename", url: '/uploads/:filename'}
      end
    end

    def self.included(base)
      # carrierwave
      if base.respond_to?(:mount_uploader)
        # puts "[rails_admin_settings] CarrierWave detected"
        # base.field(:file, type: String)
        base.mount_uploader(:file, RailsAdminSettings::Uploads::CarrierWave)
        Settings.file_uploads_supported = true
        Settings.file_uploads_engine = :carrierwave
      # mongoid-paperclip
      elsif RailsAdminSettings.mongoid? && ::Mongoid.const_defined?('Paperclip')
        base.send(:include, ::Mongoid::Paperclip)
        # puts "[rails_admin_settings] PaperClip detected"
        base.field(:file, type: String)
        base.has_mongoid_attached_file(:file, self.paperclip_options)
        if base.respond_to?(:do_not_validate_attachment_file_type)
          base.do_not_validate_attachment_file_type :file
        end

        Settings.file_uploads_supported = true
        Settings.file_uploads_engine = :paperclip
      elsif RailsAdminSettings.active_record? && defined?(Paperclip)
        base.has_mongoid_attached_file(:file, self.paperclip_options)
        if base.respond_to?(:do_not_validate_attachment_file_type)
          base.do_not_validate_attachment_file_type :file
        end
        Settings.file_uploads_supported = true
        Settings.file_uploads_engine = :paperclip
      else
        # puts "[rails_admin_settings] Uploads disabled"
      end
    end
  end
end

