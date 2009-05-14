require 'date'
module RiCal
  class PropertyValue
    #- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license
    #
    # RiCal::PropertyValue::CalAddress represents an icalendar Date property value
    # which is defined in
    # RFC 2445 section 4.3.4 p 34
    class Date < PropertyValue

      def self.valid_string?(string) #:nodoc:
        string =~ /^\d{8}$/
      end

      # Returns the value of the reciever as an RFC 2445 iCalendar string
      def value
        if @date_time_value
          @date_time_value.strftime("%Y%m%d")
        else
          nil
        end
      end

      # Set the value of the property to val
      #
      # val may be either:
      #
      # * A string which can be parsed as a DateTime
      # * A Time instance
      # * A Date instance
      # * A DateTime instance
      def value=(val)
        case val
        when nil
          @date_time_value = nil
        when String
          @date_time_value = ::DateTime.parse(::DateTime.parse(val).strftime("%Y%m%d"))
        when ::Time, ::Date, ::DateTime
          @date_time_value = ::DateTime.parse(val.strftime("%Y%m%d"))
        end
      end

      # Nop to allow occurrence list to try to set it
      def tzid=(val)#:nodoc:
      end

      def tzid #:nodoc:
        nil
      end

      def visible_params #:nodoc:
        {"VALUE" => "DATE"}.merge(params)
      end

      # Returns the year (including the century)
      def year
        @date_time_value.year
      end

      # Returns the month of the year (1..12)
      def month
        @date_time_value.month
      end

      # Returns the day of the month
      def day
        @date_time_value.day
      end

      # Returns the ruby representation a ::Date
      def ruby_value
        ::Date.parse(@date_time_value.strftime("%Y%m%d"))
      end

      alias_method :to_ri_cal_ruby_value, :ruby_value

      # Return an instance of RiCal::PropertyValue::DateTime representing the start of this date
      def to_ri_cal_date_time_value
        PropertyValue::DateTime.new(:value => @date_time_value)
      end

      # Return this date property
      def to_ri_cal_date_value(timezone_finder = nil)
        self
      end

      # Return the "Natural' property value for the date_property, in this case the date property itself."
      def to_ri_cal_date_or_date_time_value
        self
      end

      def compute_change(d, options) #:nodoc:
        ::Date.civil((options[:year] || d.year), (options[:month] || d.month), (options[:day] || d.day))
      end

      def compute_advance(d, options) #:nodoc:
        d = d >> options[:years] * 12 if options[:years]
        d = d >> options[:months]     if options[:months]
        d = d +  options[:weeks] * 7  if options[:weeks]
        d = d +  options[:days]       if options[:days]
        compute_change(@date_time_value, :year => d.year, :month => d.month, :day => d.day)
      end

      def advance(options) #:nodoc:
        PropertyValue::Date.new(timezone_finder, :value => compute_advance(@date_time_value, options), :params =>(params ? params.dup : nil) )
      end

      def change(options) #:nodoc:
        PropertyValue::Date.new(timezone_finder,:value => compute_change(@date_time_value, options), :params => (params ? params.dup : nil) )
      end

      def add_date_times_to(required_timezones) #:nodoc:
        # Do nothing since dates don't have a timezone
      end


      # Delegate unknown messages to the wrappered Date instance.
      # TODO: Is this really necessary?
      def method_missing(selector, *args) #:nodoc:
        @date_time_value.send(selector, *args)
      end

      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration) #:nodoc:
        date_time = self.to_ri_cal_date_time_value
        {:start => date_time,
          :end => date_time.advance(:hours => 24, :seconds => -1)}
        end
      end
    end
  end