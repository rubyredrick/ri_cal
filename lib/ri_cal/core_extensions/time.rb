#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
require "ri_cal/core_extensions/time/conversions.rb"
require "ri_cal/core_extensions/time/tzid_access.rb"
require "ri_cal/core_extensions/time/week_day_predicates.rb"
require "ri_cal/core_extensions/time/calculations.rb"

class Time #:nodoc:
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations  
  include RiCal::CoreExtensions::Time::Conversions
  include RiCal::CoreExtensions::Time::TzidAccess
  
	def self.get_zone(time_zone)
		return time_zone if time_zone.nil? || time_zone.is_a?(ActiveSupport::TimeZone)
		# lookup timezone based on identifier (unless we've been passed a TZInfo::Timezone)
		unless time_zone.respond_to?(:period_for_local)
			time_zone = ActiveSupport::TimeZone[time_zone] || TZInfo::Timezone.get(time_zone) rescue nil
		end
		# Return if a TimeZone instance, or wrap in a TimeZone instance if a TZInfo::Timezone
		if time_zone
			time_zone.is_a?(ActiveSupport::TimeZone) ? time_zone : ActiveSupport::TimeZone.create(time_zone.name, nil, time_zone)
		end
	end

end