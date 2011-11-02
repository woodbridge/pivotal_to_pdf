module PivotalToPdf
  class Pivotal < ActiveResource::Base
    def self.inherited(sub)
      c = ::PivotalToPdf::DiskConfig.config
      sub.site = "https://www.pivotaltracker.com/services/v3/projects/#{c['project_id']}"
      sub.headers['X-TrackerToken'] = c['token']
    end
  end
end

